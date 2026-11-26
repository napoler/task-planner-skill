#!/usr/bin/env bash
# git-baseline.sh — 修改型任务的 Git 防倒退机器面（基线 / 检查点 / 差异 / 处置 / 还原）
#
# [2026-11-24 task-session-regression-20261124] What: 任务开始先用「真实索引副本」种子生成不可变基线提交与 ref，
#       修改中可打检查点，完成后对照基线/检查点做逐文件差异分析，强制为删除行/越界文件/必保项丢失登记处置，
#       必要时可从基线或指定提交还原工作树（不删除基线后新增文件）。机器证据落在 <plan-dir>/.git-baseline.json。
# [2026-11-24 task-session-regression-20261124] Why: 此前修改型任务没有任何 Git 执行点——无基线、无检查点、
#       完成后不对照差异，出现「修复动作删掉既有设定」而验收全绿的事故。本脚本把 B9/B10/B11 的命令载体固化，
#       供 Phase 翻转门与终验门自动调用；快照必须非侵入（真实索引/HEAD/工作树逐字节不变），否则门自身会污染证据。
#
# 约束: 纯 bash + git + coreutils + jq（不依赖 Python/Node）；路径含空格、以 - 开头安全（一律 -- + 相对路径）；
#       退出码 0=成功 / 1=判定或使用错误 / 2=环境错误 / 3=无基线。
# 仓库根优先级（2026-11-24 补充）: --repo > env TASK_GIT_BASELINE_ROOT >
#       <plan-dir>/plan-state.json 的 .config.worktree_path（须存在目录且本身是 git 工作树根）> 当前目录
#       git rev-parse --show-toplevel。禁止从 <plan-dir> 自身路径推导仓库根（计划目录与实际被改的树不同树）。
#       背景: 实测 12 个在途计划仅 2 个声明 worktree_path，多数任务直接在主仓改，故默认锚定当前目录；
#       声明了 worktree 的任务改动发生在 worktree，若锚到主仓则 B9 快照打错树、worktree 改动在 diff 中不可见。
#
# Usage:
#   git-baseline.sh snapshot  <plan-dir> [--force] [--late] [--repo <path>]
#   git-baseline.sh checkpoint <plan-dir> --label <id> [--repo <path>]
#   git-baseline.sh diff      <plan-dir> [--final] [--from <sha|label>] [--scope <file>] [--repo <path>]
#   git-baseline.sh dispose   <plan-dir> --file <path> --state retained|authorized|restored|fixed --evidence "<text>" [--repo <path>]
#   git-baseline.sh restore   <plan-dir> (--file <path> | --all) [--from <sha>] [--repo <path>]
#   git-baseline.sh status    <plan-dir> [--repo <path>]
#
# 档位: env TASK_PLANNER_GIT_BASELINE_ENFORCE=off → diff 打印 SKIP off 且 rc=0；
#       =warn → diff 照常打印 PASS/FAIL 但 rc 恒 0；其它/缺省 =strict。

set -euo pipefail

# ─────────────────────────── 通用输出与退出 ───────────────────────────

die() { # die <rc> <message...> — 统一错误出口（stdout 保持契约字符串，错误走 stderr）
  local rc="$1"; shift
  printf '[git-baseline] %s\n' "$*" >&2
  exit "$rc"
}

usage() {
  printf '%s\n' \
    'usage: git-baseline.sh <snapshot|checkpoint|diff|manifest|dispose|restore|anchor-auth|anchor-preexisting|status> <plan-dir> [options]' \
    '  snapshot   [--force] [--late]' \
    '  anchor-auth          只刷新授权锚（sidecar.auth_anchor），不动 baseline/checkpoint' \
    '  anchor-preexisting   只刷新存量脏文件锚（sidecar.preexisting_dirty）' \
    '  checkpoint --label <id>' \
    '  diff       [--final] [--from <sha|label>] [--scope <file>]' \
    '  manifest   (只读输出/重生成 .diff-manifest.json，等价 diff --final 的 manifest 部分)' \
    '  dispose    --file <path> --state retained|authorized|restored|fixed --evidence "<text>"' \
    '  restore    (--file <path> | --all) [--from <sha>]' \
    '  status' >&2
  exit 1
}

# 临时目录统一在 EXIT 回收（die 中途退出也不留垃圾）
CLEANUP_DIRS=()
cleanup_all() {
  local d
  for d in "${CLEANUP_DIRS[@]}"; do
    [ -n "$d" ] && rm -rf -- "$d"
  done
  return 0
}
trap cleanup_all EXIT

# ─────────────────────────── 参数解析 ───────────────────────────

cmd="${1:-}"
[ $# -ge 1 ] && shift || true
case "$cmd" in
  snapshot|checkpoint|diff|manifest|dispose|restore|anchor-auth|anchor-preexisting|status) ;;
  -h|--help) usage ;;
  *) usage ;;
esac

plan_dir_arg=""
repo_opt=""
force=0
late=0
label=""
from_arg=""
final=0
scope_file=""
evidence_arg=""
state_arg=""
all_flag=0
RESTORE_FILES=()

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      [ $# -ge 2 ] || die 1 "--repo 缺值"
      repo_opt="$2"; shift 2 ;;
    --force) force=1; shift ;;
    --late) late=1; shift ;;
    --label)
      [ $# -ge 2 ] || die 1 "--label 缺值"
      label="$2"; shift 2 ;;
    --from)
      [ $# -ge 2 ] || die 1 "--from 缺值"
      from_arg="$2"; shift 2 ;;
    --final) final=1; shift ;;
    --scope)
      [ $# -ge 2 ] || die 1 "--scope 缺值"
      scope_file="$2"; shift 2 ;;
    --file)
      [ $# -ge 2 ] || die 1 "--file 缺值"
      RESTORE_FILES+=("$2"); shift 2 ;;
    --state)
      [ $# -ge 2 ] || die 1 "--state 缺值"
      state_arg="$2"; shift 2 ;;
    --evidence)
      [ $# -ge 2 ] || die 1 "--evidence 缺值"
      evidence_arg="$2"; shift 2 ;;
    --all) all_flag=1; shift ;;
    *)
      [ -z "$plan_dir_arg" ] || die 1 "未知参数: $1"
      plan_dir_arg="$1"; shift ;;
  esac
done

[ -n "$plan_dir_arg" ] || die 1 "缺少 <plan-dir>"
[ -d "$plan_dir_arg" ] || die 1 "<plan-dir> 不是目录: $plan_dir_arg"
plan_dir="$(cd -- "$plan_dir_arg" && pwd -P)"
sidecar="${plan_dir}/.git-baseline.json"
report="${plan_dir}/.git-baseline-report.md"
now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# task-id = plan-dir basename，仅保留白名单字符（git ref 组件安全）
task_id="$(basename -- "$plan_dir" | tr -cd 'A-Za-z0-9._-')"
[ -n "$task_id" ] || die 1 "task-id 白名单过滤后为空: $(basename -- "$plan_dir")"

# 档位：off 只影响 diff（门据此跳过），且不依赖 jq/git 环境
enforce="${TASK_PLANNER_GIT_BASELINE_ENFORCE:-strict}"
if [ "$cmd" = diff ] && [ "$enforce" = off ]; then
  printf '[git-baseline] SKIP off\n'
  exit 0
fi

command -v jq >/dev/null 2>&1 || die 2 "jq 不可用（hook 已依赖 jq，此处为环境错误）"

# ─────────────────────────── 仓库根解析（禁止从 plan-dir 推导） ───────────────────────────

repo=""
repo_mode="direct"
resolve_repo() {
  local r="" gd gcd declared wt_top valid=0 declared_present=0
  if [ -n "$repo_opt" ]; then
    r="$repo_opt"
  elif [ -n "${TASK_GIT_BASELINE_ROOT:-}" ]; then
    r="$TASK_GIT_BASELINE_ROOT"
  else
    # 第 3 级: 计划声明的工作树。必须同时满足「非空 + 目录存在 + git 顶层等于自身」，
    # 否则按契约打印 note 并落回第 4 级（当前目录），绝不静默猜树。
    declared="$(jq -r '.config.worktree_path // ""' "${plan_dir}/plan-state.json" 2>/dev/null || true)"
    # 降噪（2026-11-24 实测反馈）：未声明时静默落回当前目录；只有「声明了但失效」才打印 note。
    declared_present=0
    [ -n "$declared" ] && declared_present=1
    if [ -n "$declared" ] && [ -d "$declared" ]; then
      declared="$(cd -- "$declared" && pwd -P)"
      wt_top="$(git -C "$declared" rev-parse --show-toplevel 2>/dev/null || true)"
      if [ -n "$wt_top" ] && [ "$(cd -- "$wt_top" 2>/dev/null && pwd -P)" = "$declared" ]; then
        r="$declared"; valid=1
      fi
    fi
    if [ "$valid" -eq 0 ]; then
      if [ "$declared_present" -eq 1 ]; then
        printf '[git-baseline] note: declared worktree_path invalid or absent, falling back to CWD\n'
      fi
      r="$(git rev-parse --show-toplevel 2>/dev/null || true)"
    fi
  fi
  [ -n "$r" ] && [ -d "$r" ] || return 2
  r="$(cd -- "$r" && pwd -P)"
  [ "$(git -C "$r" rev-parse --is-inside-work-tree 2>/dev/null || true)" = true ] || return 2
  repo="$r"
  # 链接工作树判定：git-dir 与 common-dir 不同即为 worktree
  gd="$(cd -- "$repo" && git rev-parse --absolute-git-dir 2>/dev/null || true)"
  gcd="$(cd -- "$repo" && readlink -f -- "$(git rev-parse --git-common-dir 2>/dev/null || printf '.')" 2>/dev/null || true)"
  if [ -n "$gd" ] && [ -n "$gcd" ] && [ "$gd" != "$gcd" ]; then
    repo_mode="worktree"
  else
    repo_mode="direct"
  fi
  return 0
}

if ! resolve_repo; then
  printf '[git-baseline] SKIP degraded: NO_GIT\n'
  exit 2
fi

# 本工具自己的机器证据（sidecar/报告）不参与基线/差异比对：它们由本命令反复改写，
# 若纳入 diff 会self-referential 产生无意义的删除行并让每次 diff 恒 FAIL。
EXCLUDE_PATHSPECS=()
case "$plan_dir" in
  "$repo")
    EXCLUDE_PATHSPECS+=(':(exclude).git-baseline.json' ':(exclude).git-baseline-report.md' ':(exclude).diff-manifest.json') ;;
  "$repo"/*)
    rel_plan="${plan_dir#$repo/}"
    EXCLUDE_PATHSPECS+=(":(exclude)${rel_plan}/.git-baseline.json" ":(exclude)${rel_plan}/.git-baseline-report.md" ":(exclude)${rel_plan}/.diff-manifest.json") ;;
esac

# ─────────────────────────── sidecar 原子写入 ───────────────────────────

sc_get() { # sc_get <jq-filter> — 读 sidecar 单值，缺失给空
  [ -f "$sidecar" ] || { printf ''; return 0; }
  jq -r "$1" "$sidecar" 2>/dev/null || true
}

sc_ensure() { # 首次建立完整骨架（所有契约字段齐全）
  [ -f "$sidecar" ] && return 0
  local tmp
  tmp="$(mktemp "${plan_dir}/.git-baseline.tmp.XXXXXX")" || return 2
  if jq -n --arg tid "$task_id" --arg root "$repo" --arg mode "$repo_mode" --arg at "$now" \
    '{schema:1,task_id:$tid,repo_root:$root,mode:$mode,baseline_ref:"",baseline_sha:"",
      baseline_tree:"",created_at:$at,file_count:0,seed:"real-index-copy",late:false,
      mustkeep:{count:0,empty:true,source:"missing"},checkpoints:[],files:[],
      last_diff:{at:"",from_ref:"",report:"",added:0,modified:0,deleted:0,out_of_scope:0,
                 deleted_lines:0,unresolved:0,mustkeep_lost:0,items:[]},disposal:[]}' > "$tmp"; then
    mv -f -- "$tmp" "$sidecar"
  else
    rm -f -- "$tmp"; return 2
  fi
}

sc_apply() { # sc_apply <filter> [--arg|--argjson NAME VALUE ...] — jq 改 + 同目录 tmp + mv 原子替换
  local filter="$1"; shift
  local opts=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --arg|--argjson) opts+=("$1" "$2" "$3"); shift 3 ;;
      *) return 2 ;;
    esac
  done
  local tmp rc=0
  tmp="$(mktemp "${plan_dir}/.git-baseline.tmp.XXXXXX")" || return 2
  if jq "${opts[@]}" "$filter" "$sidecar" > "$tmp"; then
    mv -f -- "$tmp" "$sidecar"
  else
    rc=$?; rm -f -- "$tmp"; return "$rc"
  fi
}

# ─────────────────────────── 非侵入树生成 ───────────────────────────

CUR_TREE=""
make_tree() {
  # 关键：真实索引副本做种子，不能 mktemp 出 0 字节文件当索引（git 报 index file smaller than expected）；
  # 也不能用空索引 git add -A（仓内嵌套 .git 时报 does not have a commit checked out）。
  # 全过程 GIT_INDEX_FILE 指向工作树外临时索引，真实索引/HEAD/工作树均不被写。
  local idxdir idx realidx rc=0
  idxdir="$(mktemp -d "${TMPDIR:-/tmp}/git-baseline.XXXXXX")" || return 2
  CLEANUP_DIRS+=("$idxdir")
  idx="${idxdir}/index"   # 必须不存在，由 cp 创建
  realidx="$(git -C "$repo" rev-parse --git-path index 2>/dev/null || true)"
  if [ -z "$realidx" ]; then
    printf '[git-baseline] ERROR NO_INDEX\n'; return 2
  fi
  case "$realidx" in /*) ;; *) realidx="${repo}/${realidx}" ;; esac
  if [ ! -f "$realidx" ]; then
    printf '[git-baseline] ERROR NO_INDEX\n'; return 2
  fi
  cp -- "$realidx" "$idx" || return 2
  # [2026-11-24 修 bug] 真实索引带 stat 缓存；「同大小 + 同秒 mtime」的内容改动会被 git add 跳过，
  # 当前树漏掉该改动（实测二进制夹具偶发漏报）。用 ls-files -s | update-index --index-info 重建
  # 临时索引，抹掉 stat 信息，强制 git add 按内容重新 hash；真实索引仍完全不动。
  if ! ( cd -- "$repo" && export GIT_INDEX_FILE="$idx" && git ls-files -s -z | git update-index -z --index-info ); then
    printf '[git-baseline] ERROR INDEX_RESET_FAILED\n' >&2; return 2
  fi

  local -a add_specs=("${EXCLUDE_PATHSPECS[@]}")
  local ent d comp prefix
  declare -A seen_nested=()
  # [2026-11-24] 未出生的嵌套 git 仓（nested/.git 且无 HEAD）会让 git add -A 直接报
  # "does not have a commit checked out"。这类仓不是本次被改的树，显式用 pathspec 排除其顶层路径；
  # 有 HEAD 的嵌套仓仍按 git 原生语义作为 gitlink 放入树，不排除。
  while IFS= read -r -d '' ent; do
    case "$ent" in */) d="${ent%/}" ;; *) continue ;; esac
    local -a parts=()
    IFS='/' read -ra parts <<< "$d"
    prefix=""
    for comp in "${parts[@]}"; do
      prefix="${prefix:+$prefix/}$comp"
      if [ -e "${repo}/${prefix}/.git" ] && [ -z "${seen_nested[$prefix]:-}" ] \
         && ! git -C "${repo}/${prefix}" rev-parse --verify --quiet HEAD >/dev/null 2>&1; then
        add_specs+=(":(exclude)$prefix"); seen_nested["$prefix"]=1
        break
      fi
    done
  done < <(git -C "$repo" ls-files --others --exclude-standard -z 2>/dev/null || true)

  # 有排除项时必须给 " -- . " 作为正 pathspec，否则 git 只按排除模式理解命令
  if ! ( cd -- "$repo" && GIT_INDEX_FILE="$idx" git add -A -- . "${add_specs[@]}" ); then
    printf '[git-baseline] ERROR ADD_FAILED\n' >&2; return 2
  fi
  CUR_TREE="$(cd -- "$repo" && GIT_INDEX_FILE="$idx" git write-tree)" || { rc=$?; return "$rc"; }
  return 0
}

commit_tree() { # commit_tree <tree> <message> [parent] — 输出 sha；HEAD 未出生时不带 -p
  local tree="$1" msg="$2" parent="${3:-}" sha=""
  # 无用户身份的裸环境也要能生成证据提交（不改仓库 config）
  : "${GIT_AUTHOR_NAME:=task-planner}"; export GIT_AUTHOR_NAME
  : "${GIT_AUTHOR_EMAIL:=task-planner@localhost}"; export GIT_AUTHOR_EMAIL
  : "${GIT_COMMITTER_NAME:=task-planner}"; export GIT_COMMITTER_NAME
  : "${GIT_COMMITTER_EMAIL:=task-planner@localhost}"; export GIT_COMMITTER_EMAIL
  if [ -n "$parent" ] && git -C "$repo" cat-file -e "${parent}^{commit}" 2>/dev/null; then
    sha="$(git -C "$repo" commit-tree "$tree" -p "$parent" -m "$msg")" || return 2
  else
    sha="$(git -C "$repo" commit-tree "$tree" -m "$msg")" || return 2
  fi
  printf '%s' "$sha"
}

count_tree_files() { # count_tree_files <tree> — 基线文件数
  git -C "$repo" ls-tree -r --name-only "$1" 2>/dev/null | grep -c . || true
}

# ─────────────────────────── mustkeep 采集 ───────────────────────────

MK_ID=(); MK_VERB=(); MK_TARGET=(); MK_ANCHOR=(); mk_source="missing"
mk_collect() {
  # 调用同目录 lib/plan-recovery.sh mustkeep <plan-dir>；输出 TSV: id \t verbatim \t target \t anchor
  # [2026-11-24] 库尚不存在或调用失败时按空处理并标 source=missing（MUSTKEEP-EMPTY 只是提示，阻断由门决定）
  MK_ID=(); MK_VERB=(); MK_TARGET=(); MK_ANCHOR=(); mk_source="missing"
  local lib script_dir tsv="" rc=0 id vb tg an
  script_dir="$(dirname -- "$(readlink -f -- "$0")")"
  lib="${script_dir}/lib/plan-recovery.sh"
  if [ -f "$lib" ]; then
    tsv="$(bash "$lib" mustkeep "$plan_dir" 2>/dev/null)" || rc=$?
    if [ "$rc" -eq 0 ]; then
      mk_source="lib"
    else
      printf '[git-baseline] WARN mustkeep 库调用失败 rc=%s，按空处理\n' "$rc" >&2
    fi
  fi
  if [ -n "$tsv" ]; then
    while IFS=$'\t' read -r id vb tg an; do
      id="${id%$'\r'}"; vb="${vb%$'\r'}"; tg="${tg%$'\r'}"; an="${an%$'\r'}"
      [ -n "$id" ] || continue
      # [2026-11-24 实测反馈] MK-NA = 计划声明「无既有事实需保」的占位项，verbatim 是理由、target=n/a；
      # 它不是可查证的必保事实，不能计入数量、更不能查证成永久 LOST。大小写不敏感。
      case "${id^^}" in MK-NA) continue ;; esac
      MK_ID+=("$id"); MK_VERB+=("$vb"); MK_TARGET+=("$tg"); MK_ANCHOR+=("${an:-}")
    done <<< "$tsv"
  fi
}

# ─────────────────────────── 授权锚（防事后自补授权） ───────────────────────────

AUTH_NDEC=""; AUTH_NLOG=""
refresh_auth_anchor() {
  # [2026-11-24 P1 修复] 授权凭据在 snapshot / anchor-auth 时固化进 sidecar；之后执行体自补
  # plan-state.json.decisions 或自写 user-session-log.md 的 `>` 行都不再被 dispose 采信。
  # decisions = {id, text=decision+rationale}；userlog = `^>` 行去掉 > 前缀后的逐行文本。
  local ps="${plan_dir}/plan-state.json" ulog="${plan_dir}/user-session-log.md"
  local dec='[]' ul='[]'
  if [ -f "$ps" ]; then
    dec="$(jq -c '[.decisions[]? | select(type == "object") | {id:(.id // ""), text:((.decision // "") + " " + (.rationale // ""))}]' "$ps" 2>/dev/null || printf '[]')"
  fi
  if [ -f "$ulog" ]; then
    ul="$(grep -E '^>' "$ulog" 2>/dev/null | sed -e 's/^>[[:space:]]*//' -e 's/\r$//' \
          | jq -Rs 'split("\n") | map(select(length > 0))' 2>/dev/null || printf '[]')"
  fi
  [ -n "$dec" ] || dec='[]'; [ -n "$ul" ] || ul='[]'
  sc_apply '(.auth_anchor = {at:$at,decisions:$dec,userlog:$ul})' \
    --arg at "$now" --argjson dec "$dec" --argjson ul "$ul" || return 2
  AUTH_NDEC="$(printf '%s' "$dec" | jq 'length' 2>/dev/null || printf '0')"
  AUTH_NLOG="$(printf '%s' "$ul" | jq 'length' 2>/dev/null || printf '0')"
  return 0
}

cmd_anchor_auth() { # 只刷新授权锚，不动 baseline / checkpoint
  require_sidecar_repo
  refresh_auth_anchor || die 2 "auth_anchor 写入失败"
  printf '[git-baseline] AUTH ANCHOR decisions=%s userlog=%s\n' "$AUTH_NDEC" "$AUTH_NLOG"
}

# ─────────────────────────── 存量脏文件锚（非本任务偏移） ───────────────────────────

PREEXIST_N=0
refresh_preexisting_anchor() {
  # [2026-11-24] 基线若来自干净 worktree，任务开始前别人留下的未提交改动会被 diff 误判为本任务偏移。
  # 首次 snapshot / 显式 anchor-preexisting 时把当时的工作树脏文件（含未跟踪、相对 HEAD）按内容 blob
  # 固化；diff 时仅当 path 与 blob 都未变才豁免。本任务侧车/报告自身必须排除，否则每轮都会自豁免。
  # [2026-11-24 补漏] D 项（任务前已删除的文件）工作树无内容可 hash，改锚 HEAD:<path> 的 blob 并标
  # deleted=true；否则这类存量删除会被当成任务偏移，终验门永远阻断。
  local -a items=() skips=() paths=()
  local s
  for s in "${EXCLUDE_PATHSPECS[@]}"; do skips+=("${s#:(exclude)}"); done
  local rec st p oldp f blob
  while IFS= read -r -d '' rec; do
    st="${rec:0:2}"; p="${rec:3}"
    case "$st" in R*|C*) IFS= read -r -d '' oldp || oldp="" ;; esac  # 重名记录多一条 old path
    [ -n "$p" ] || continue
    paths=("$p")
    case "$p" in
      */) paths=()
          # status -z 对未跟踪目录只报目录，展开为其中的文件，才能与 diff 的文件级 path 对齐
          while IFS= read -r -d '' f; do paths+=("$f"); done \
            < <(git -C "$repo" ls-files --others --exclude-standard -z -- "$p" 2>/dev/null || true) ;;
    esac
    for f in "${paths[@]}"; do
      local skip=0 q
      for q in "${skips[@]}"; do [ "$q" = "$f" ] && skip=1; done
      [ "$skip" -eq 0 ] || continue
      if [ -f "${repo}/${f}" ]; then
        blob="$(git -C "$repo" hash-object -- "$f" 2>/dev/null || true)"
        [ -n "$blob" ] || continue
        items+=("$(jq -nc --arg path "$f" --arg blob "$blob" '{path:$path,blob:$blob}')")
      else
        # D 项：锚定 HEAD 中该路径的 blob，并标 deleted=true（工作树 hash-object 不可用）
        blob="$(git -C "$repo" rev-parse "HEAD:${f}" 2>/dev/null || true)"
        [ -n "$blob" ] || continue
        items+=("$(jq -nc --arg path "$f" --arg blob "$blob" '{path:$path,blob:$blob,deleted:true}')")
      fi
    done
  done < <(git -C "$repo" status --porcelain -z 2>/dev/null || true)
  local arrjson
  arrjson="[$(IFS=,; printf '%s' "${items[*]:-}")]"
  sc_apply '(.preexisting_dirty = $v)' --argjson v "$arrjson" || return 2
  PREEXIST_N=${#items[@]}
  return 0
}

cmd_anchor_preexisting() {
  require_sidecar_repo
  refresh_preexisting_anchor || die 2 "preexisting_dirty 写入失败"
  printf '[git-baseline] PREEXISTING DIRTY n=%s\n' "$PREEXIST_N"
}

# ─────────────────────────── 路径安全 ───────────────────────────

norm_path() { # 拒绝绝对路径与 .. 穿越，去掉开头 ./；路径含空格安全
  local p="$1"
  case "$p" in /*) return 1 ;; esac
  case "/${p}/" in */../*) return 1 ;; esac
  while [ "${p#./}" != "$p" ]; do p="${p#./}"; done
  [ -n "$p" ] || return 1
  printf '%s' "$p"
}

# ─────────────────────────── 处置校验（dispose 与 diff 共用同一规则） ───────────────────────────

DREASON=""
validate_disposal() { # validate_disposal <path> <state> <evidence> [mkitems: 每行 id<TAB>verbatim]
  # [2026-11-24 P1 修复] authorized 只认 snapshot/anchor-auth 固化的 sidecar.auth_anchor，
  # 绝不读当前 plan-state.json / user-session-log.md——执行体可在删必保项后自补 D 与 > 原话洗白。
  #   a) D 号精确命中 auth_anchor.decisions[].id；b) 原话命中 auth_anchor.userlog[] 某行；
  #   c) 该 path 有 mustkeep_lost 时，锚内决定文本必须点名 MK 编号或 verbatim 原文。
  local p="$1" state="$2" evidence="$3" mkitems="${4:-}"
  local seg dpart upart d u rc=0 found f seg2 mid mverb dtext anchor_log
  DREASON=""
  case "$state" in
    retained|fixed)
      [ -n "$evidence" ] || { DREASON="evidence 为空"; return 1; }
      local IFS='|'
      local -a segs=()
      read -ra segs <<< "$evidence"
      [ "${#segs[@]}" -gt 0 ] || { DREASON="evidence 无片段"; return 1; }
      local IFS=$' \t\n'
      for seg in "${segs[@]}"; do
        [ -n "$seg" ] || { DREASON="evidence 含空片段"; return 1; }
        [ "${#seg}" -ge 4 ] || { DREASON="片段不足 4 字: $seg"; return 1; }
        if ! grep -qF -- "$seg" "${repo}/${p}" 2>/dev/null; then
          DREASON="片段未命中当前文件: $seg"; return 1
        fi
      done
      # 该文件存在 mustkeep_lost 时，证据片段必须逐条包含丢失原文（执行体自填其它片段无效）
      if [ -n "$mkitems" ]; then
        while IFS=$'\t' read -r mid mverb; do
          [ -n "$mid$mverb" ] || continue
          found=0
          for seg2 in "${segs[@]}"; do
            if [ -n "$mverb" ] && [ "$seg2" = "$mverb" ]; then found=1; break; fi
          done
          [ "$found" -eq 1 ] || { DREASON="缺少 mustkeep 原文片段: ${mverb:-$mid}"; return 1; }
        done <<< "$mkitems"
      fi
      # [P1 修复] deleted 原文约束：该 path 有 deleted 项时，证据至少含一条被删原文；
      # 只凭「任意 ≥4 字存活片段」不能洗白删除。无 deleted 项时保持旧行为。
      local dverbs
      dverbs="$(jq -r --arg p "$p" '.last_diff.items[]? | select(.kind=="deleted" and .path==$p) | .verbatim' "$sidecar" 2>/dev/null || true)"
      if [ -n "$dverbs" ]; then
        found=0
        while IFS= read -r seg2; do
          [ -n "$seg2" ] || continue
          for seg in "${segs[@]}"; do
            if [ "$seg" = "$seg2" ]; then found=1; break; fi
          done
          if [ "$found" -eq 1 ]; then break; fi
        done <<< "$dverbs"
        [ "$found" -eq 1 ] || { DREASON="retained/fixed 证据未包含被删原文（deleted 项）"; return 1; }
      fi
      return 0 ;;
    authorized)
      local IFS='|'
      local -a parts=()
      read -ra parts <<< "$evidence"
      local IFS=$' \t\n'
      [ "${#parts[@]}" -eq 2 ] || { DREASON="authorized 证据须为 decisions:<D号>|用户原话:<片段>"; return 1; }
      dpart="${parts[0]}"; upart="${parts[1]}"
      case "$dpart" in decisions:*) d="${dpart#decisions:}" ;; *) DREASON="缺少 decisions: 前缀"; return 1 ;; esac
      case "$upart" in 用户原话:*) u="${upart#用户原话:}" ;; *) DREASON="缺少 用户原话: 前缀"; return 1 ;; esac
      [ -n "$d" ] || { DREASON="D 编号为空"; return 1; }
      [ "${#u}" -ge 4 ] || { DREASON="用户原话片段不足 4 字"; return 1; }
      # 授权锚缺失 = 不可授权（老侧车须 snapshot --force 或 anchor-auth 显式补锚）
      if [ "$(jq -r 'if (.auth_anchor|type)=="object" then "1" else "0" end' "$sidecar" 2>/dev/null || printf '0')" != 1 ]; then
        DREASON="AUTH-ANCHOR-MISSING"; return 1
      fi
      # a) D 号精确命中锚内 decisions[].id，同时取出锚内决定文本供 c) 点名核对
      dtext="$(jq -r --arg d "$d" \
        '[.auth_anchor.decisions[]? | select(.id == $d) | .text] | join("\n")' \
        "$sidecar" 2>/dev/null || true)"
      [ "$(printf '%s' "$dtext" | tr -d '[:space:]')" != "" ] \
        || { DREASON="锚内 decisions 查无精确 D 编号 $d"; return 1; }
      # b) 用户原话只认锚内 userlog[] 的某一行（逐行 grep -F，不跨行拼接）
      anchor_log="$(jq -r '.auth_anchor.userlog[]?' "$sidecar" 2>/dev/null || true)"
      if ! printf '%s\n' "$anchor_log" | grep -qF -- "$u"; then
        DREASON="用户原话片段不在授权锚 userlog 中: $u"; return 1
      fi
      # c) 必保项丢失时，决定文本必须点名 MK 编号或 verbatim，防无关授权豁免
      if [ -n "$mkitems" ]; then
        while IFS=$'\t' read -r mid mverb; do
          [ -n "$mid$mverb" ] || continue
          found=0
          if [ -n "$mid" ] && printf '%s\n' "$dtext" | grep -qF -- "$mid"; then found=1; fi
          if [ "$found" -eq 0 ] && [ -n "$mverb" ] && printf '%s\n' "$dtext" | grep -qF -- "$mverb"; then found=1; fi
          [ "$found" -eq 1 ] || { DREASON="授权决定未点名必保项 ${mid:-$mverb}"; return 1; }
        done <<< "$mkitems"
      fi
      return 0 ;;
    restored)
      local sha
      sha="$(sc_get '.baseline_sha // ""')"
      [ -n "$sha" ] || { DREASON="无基线 sha"; return 1; }
      git -C "$repo" cat-file -e "${sha}:${p}" 2>/dev/null || { DREASON="基线中无此路径"; return 1; }
      rc=0
      git -C "$repo" diff --quiet "$sha" -- "$p" 2>/dev/null || rc=$?
      [ "$rc" -eq 0 ] || { DREASON="当前内容与基线不一致"; return 1; }
      return 0 ;;
    *) DREASON="非法 state: $state"; return 1 ;;
  esac
}

mk_verbs_sidecar() { # 从 sidecar.last_diff.items 取指定 path 的丢失项，每行 id<TAB>verbatim
  local p="$1"
  jq -r --arg p "$p" \
    '.last_diff.items[]? | select(.kind=="mustkeep_lost" and .path==$p) | [(.id // ""), (.verbatim // "")] | @tsv' \
    "$sidecar" 2>/dev/null || true
}

# ─────────────────────────── snapshot ───────────────────────────

refresh_baseline_sidecar() { # 幂等/强制共用：刷新基线字段，保留原 created_at
  local sha="$1" tree="$2" ref="$3" cnt created mkcount mkempty
  cnt="$(count_tree_files "$tree")"
  created="$(sc_get '.created_at // ""')"
  [ -n "$created" ] || created="$now"
  mk_collect
  mkcount=${#MK_ID[@]}
  mkempty=true; [ "$mkcount" -eq 0 ] || mkempty=false
  sc_apply '(.repo_root=$root) | (.mode=$mode) | (.baseline_ref=$ref) | (.baseline_sha=$sha) |
    (.baseline_tree=$tree) | (.created_at=$at) | (.file_count=$cnt) | (.seed="real-index-copy") |
    (.late=(if $late=="1" then true else .late end)) |
    (.mustkeep={count:$mkcount,empty:$mkempty,source:$mksrc})' \
    --arg root "$repo" --arg mode "$repo_mode" --arg ref "$ref" --arg sha "$sha" \
    --arg tree "$tree" --arg at "$created" --argjson cnt "$cnt" --arg late "$late" \
    --arg mksrc "$mk_source" --argjson mkcount "$mkcount" --argjson mkempty "$mkempty" \
    || die 2 "sidecar 基线字段写入失败"
  if [ "$mkcount" -eq 0 ]; then printf 'MUSTKEEP-EMPTY\n'; fi
}

cmd_snapshot() {
  local ref="refs/task-baseline/${task_id}" sha tree existing_root
  sc_ensure || die 2 "sidecar 初始化失败"
  existing_root="$(sc_get '.repo_root // ""')"

  # 幂等：ref 已存在且未 --force → 不改基线，只刷新 sidecar
  if [ "$force" -eq 0 ] && git -C "$repo" show-ref --verify --quiet "$ref"; then
    sha="$(git -C "$repo" rev-parse --verify "$ref")"
    tree="$(git -C "$repo" rev-parse --verify "${sha}^{tree}")"
    refresh_baseline_sidecar "$sha" "$tree" "$ref"
    printf '[git-baseline] BASELINE %s (idempotent)\n' "$ref"
    return 0
  fi

  # 强制重打但仓库变了 → 拒绝（防把别的树当基线）
  if [ "$force" -eq 1 ] && [ -n "$existing_root" ] && [ "$existing_root" != "$repo" ]; then
    die 2 "sidecar.repo_root=$existing_root 与本次仓库 $repo 不同；请传 --repo $existing_root"
  fi

  make_tree || die 2 "生成基线树失败"
  tree="$CUR_TREE"
  sha="$(commit_tree "$tree" "task-baseline ${task_id}" "$(git -C "$repo" rev-parse --verify --quiet HEAD 2>/dev/null || true)")" \
    || die 2 "commit-tree 失败"
  git -C "$repo" update-ref "$ref" "$sha" || die 2 "update-ref 失败"
  refresh_baseline_sidecar "$sha" "$tree" "$ref"
  # 仅在真正建/重打基线时固化各锚；幂等重跑不刷新（避免事后自补授权/存量偏移借 snapshot 洗白）
  refresh_auth_anchor || die 2 "snapshot 授权锚写入失败"
  refresh_preexisting_anchor || die 2 "snapshot 存量脏文件锚写入失败"
  printf '[git-baseline] BASELINE %s\n' "$ref"
}

# ─────────────────────────── checkpoint ───────────────────────────

CHECKPOINT_REF=""; CHECKPOINT_SHA=""
write_checkpoint() { # write_checkpoint <ref安全label> <原始label>
  local safe="$1" raw="$2" n ref parent sha tree
  [ -f "$sidecar" ] || return 3
  n="$(jq -r '.checkpoints|length+1' "$sidecar" 2>/dev/null || true)"
  [ -n "$n" ] && [ "$n" != null ] || n=1
  ref="$(printf 'refs/task-checkpoint/%s/%03d-%s' "$task_id" "$n" "$safe")"
  parent="$(jq -r '.checkpoints[-1].sha // ""' "$sidecar" 2>/dev/null || true)"
  if [ -z "$parent" ] || [ "$parent" = null ]; then
    parent="$(git -C "$repo" rev-parse --verify --quiet HEAD 2>/dev/null || true)"
  fi
  make_tree || return 2
  tree="$CUR_TREE"
  sha="$(commit_tree "$tree" "task-checkpoint ${task_id} ${raw}" "$parent")" || return 2
  git -C "$repo" update-ref "$ref" "$sha" || return 2
  sc_apply '(.checkpoints += [{n:$n,label:$label,ref:$ref,sha:$sha,tree:$tree,at:$at}])' \
    --argjson n "$n" --arg label "$raw" --arg ref "$ref" --arg sha "$sha" \
    --arg tree "$tree" --arg at "$now" || return 2
  CHECKPOINT_REF="$ref"; CHECKPOINT_SHA="$sha"
  return 0
}

require_sidecar_repo() { # 有基线 + repo_root 对账，防拿错树做对照
  [ -f "$sidecar" ] || die 3 "NO_BASELINE（先跑 snapshot）"
  local root
  root="$(sc_get '.repo_root // ""')"
  [ "$root" = "$repo" ] || die 2 "sidecar.repo_root=$root 与当前仓库 $repo 不同；请传 --repo $root"
}

cmd_checkpoint() {
  require_sidecar_repo
  [ -n "$label" ] || die 1 "checkpoint 需 --label <id>"
  local safe
  safe="$(printf '%s' "$label" | tr -cd 'A-Za-z0-9._-')"
  [ -n "$safe" ] || die 1 "--label 白名单过滤后为空"
  write_checkpoint "$safe" "$label" || die 2 "checkpoint 写入失败"
  printf '[git-baseline] CHECKPOINT %s\n' "$CHECKPOINT_REF"
}

# ─────────────────────────── diff-audit manifest（删除行锚词对账） ───────────────────────────

DIFF_MANIFEST_FILE=""
DIFF_AUDIT_HITS_JSON="[]"
DIFF_AUDIT_REGISTRY_PRESENT=0

diff_audit_reset() {
  DIFF_AUDIT_HITS_JSON="[]"
  DIFF_AUDIT_REGISTRY_PRESENT=0
}

# emit_diff_audit_manifest <plan-dir> <repo-root> <from-tree> <cur-tree>
# Reads .source-registry.tsv at repo root (4-col TSV: source_path spec_kind anchors_keywords(|sep) scope_tags).
# Scans deleted lines (- prefix, excluding ---/+++) in diff from-tree..cur-tree for anchor keyword hits.
# Writes <plan-dir>/.diff-manifest.json and emits [diff-audit] stdout lines.
# Missing registry => silent skip with one [diff-audit] skip line. Fault-tolerant: never non-zero.
emit_diff_audit_manifest() {
  local pd="$1" rr="$2" ft="$3" ct="$4"
  local reg="${rr}/.source-registry.tsv"
  local manifest="${pd}/.diff-manifest.json"
  DIFF_MANIFEST_FILE="$manifest"
  diff_audit_reset

  # Build files array from git diff numstat+name-status (same trees as diff)
  local files_json="[]"
  local tmpf
  tmpf="$(mktemp "${TMPDIR:-/tmp}/git-baseline-manifest.XXXXXX")" || tmpf=""
  if [ -n "$tmpf" ]; then
    CLEANUP_DIRS+=("$tmpf")
    # files: [{"path","added":n,"deleted":n}]
    local nsf numf
    nsf="$(mktemp "${TMPDIR:-/tmp}/git-baseline-mns.XXXXXX")" || nsf=""
    numf="$(mktemp "${TMPDIR:-/tmp}/git-baseline-mnum.XXXXXX")" || numf=""
    if [ -n "$nsf" ] && [ -n "$numf" ]; then
      CLEANUP_DIRS+=("$nsf" "$numf")
      git -C "$rr" diff --name-status -M -z "$ft" "$ct" > "$nsf" 2>/dev/null || true
      git -C "$rr" diff --numstat -M -z "$ft" "$ct" > "$numf" 2>/dev/null || true
      local -A _MA=() _MD=() _MB=()
      local rec a d p rest oldp
      while IFS= read -r -d '' rec; do
        case "$rec" in *$'\t'*) ;; *) continue ;; esac
        a="${rec%%$'\t'*}"; rest="${rec#*$'\t'}"
        case "$rest" in *$'\t'*) ;; *) continue ;; esac
        d="${rest%%$'\t'*}"; p="${rest#*$'\t'}"
        if [ -z "$p" ]; then
          IFS= read -r -d '' oldp || oldp=""
          IFS= read -r -d '' p || p=""
        fi
        [ -n "$p" ] || continue
        if [ "$a" = "-" ] || [ "$d" = "-" ]; then
          _MB["$p"]=1; _MA["$p"]=0; _MD["$p"]=0
        else
          _MB["$p"]=0; _MA["$p"]="$a"; _MD["$p"]="$d"
        fi
      done < "$numf"
      local st p1 p2 fp
      local fitems=""
      while IFS= read -r -d '' st; do
        IFS= read -r -d '' p1 || break
        case "$st" in R*|C*) IFS= read -r -d '' p2 || p2=""; fp="$p2" ;; *) fp="$p1" ;; esac
        [ -n "$fp" ] || continue
        local aa="${_MA[$fp]:-0}" dd="${_MD[$fp]:-0}"
        local fobj
        fobj="$(jq -nc --arg path "$fp" --argjson added "${aa:-0}" --argjson deleted "${dd:-0}" \
          '{path:$path,added:$added,deleted:$deleted}' 2>/dev/null)" || fobj=""
        [ -n "$fobj" ] || continue
        if [ -n "$fitems" ]; then fitems="${fitems},${fobj}"; else fitems="$fobj"; fi
      done < "$nsf"
      files_json="[${fitems}]"
    fi
  fi

  if [ ! -f "$reg" ]; then
    # No registry: write manifest with empty source_hits, emit skip line
    local gen_at
    gen_at="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || printf '')"
    jq -nc --argjson files "$files_json" --argjson source_hits '[]' --arg generated_at "$gen_at" \
      '{files:$files,source_hits:$source_hits,generated_at:$generated_at}' > "$manifest" 2>/dev/null || true
    printf '[diff-audit] no .source-registry.tsv — skip\n'
    DIFF_AUDIT_HITS_JSON="[]"
    DIFF_AUDIT_REGISTRY_PRESENT=0
    return 0
  fi

  DIFF_AUDIT_REGISTRY_PRESENT=1

  # Parse registry: 4 cols TAB - source_path spec_kind anchors_keywords(|sep) scope_tags
  local -a REG_SRC=() REG_KWS=()
  local line src_path spec_kind anchors scope_tags kw
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    [ -n "$line" ] || continue
    case "$line" in \#*) continue ;; esac
    # split by TAB
    IFS=$'\t' read -r src_path spec_kind anchors scope_tags <<< "$line"
    [ -n "${src_path:-}" ] || continue
    [ -n "${anchors:-}" ] || continue
    REG_SRC+=("$src_path")
    REG_KWS+=("$anchors")
  done < "$reg"

  # Collect deleted lines from diff (unified=0, only - lines excluding ---)
  # We scan per-file deleted text; easier to use git diff -U0 and parse.
  local raw_del
  raw_del="$(git -C "$rr" diff -U0 -M "$ft" "$ct" -- 2>/dev/null || true)"

  local -a HIT_KW=() HIT_SRC=() HIT_EX=()
  local -A HIT_SEEN=()  # dedupe by kw@src@excerpt
  local excerpt dl
  # Iterate deleted lines
  while IFS= read -r dl; do
    case "$dl" in
      ---*) continue ;;
      -*) ;;
      *) continue ;;
    esac
    # strip leading -
    dl="${dl#-}"
    [ -n "$dl" ] || continue
    local ri=0
    for ri in "${!REG_SRC[@]}"; do
      local kws="${REG_KWS[$ri]}"
      local sp="${REG_SRC[$ri]}"
      # split kws by |
      local IFS_SAVE="$IFS"
      IFS='|'
      local -a kwa=()
      read -ra kwa <<< "$kws"
      IFS="$IFS_SAVE"
      local k
      for k in "${kwa[@]}"; do
        [ -n "$k" ] || continue
        if [[ "$dl" == *"$k"* ]]; then
          excerpt="$dl"
          # trim to 60 chars
          if [ "${#excerpt}" -gt 60 ]; then excerpt="${excerpt:0:60}"; fi
          local key="${k}@${sp}@${excerpt}"
          if [ -z "${HIT_SEEN[$key]:-}" ]; then
            HIT_SEEN["$key"]=1
            HIT_KW+=("$k")
            HIT_SRC+=("$sp")
            HIT_EX+=("$excerpt")
          fi
        fi
      done
    done
  done <<< "$raw_del"

  # Build source_hits json
  local hits_items=""
  local hi
  for hi in "${!HIT_KW[@]}"; do
    local hobj
    hobj="$(jq -nc --arg anchor_kw "${HIT_KW[$hi]}" --arg source "${HIT_SRC[$hi]}" --arg first_line_excerpt "${HIT_EX[$hi]}" \
      '{anchor_kw:$anchor_kw,source:$source,first_line_excerpt:$first_line_excerpt}' 2>/dev/null)" || hobj=""
    [ -n "$hobj" ] || continue
    if [ -n "$hits_items" ]; then hits_items="${hits_items},${hobj}"; else hits_items="$hobj"; fi
  done
  DIFF_AUDIT_HITS_JSON="[${hits_items}]"

  # Emit per-source stdout lines (n=0 also output)
  local -A SRC_HITS=() SRC_KWS_SEEN=()
  for hi in "${!HIT_KW[@]}"; do
    local sp="${HIT_SRC[$hi]}" k="${HIT_KW[$hi]}"
    SRC_HITS["$sp"]=$(( ${SRC_HITS[$sp]:-0} + 1 ))
    # accumulate kws (unique-ish, pipe joined for display)
    if [ -z "${SRC_KWS_SEEN[$sp|$k]:-}" ]; then
      SRC_KWS_SEEN["$sp|$k"]=1
      if [ -z "${SRC_KWS_SEEN[$sp]:-}" ]; then SRC_KWS_SEEN["$sp"]="$k"; else SRC_KWS_SEEN["$sp"]="${SRC_KWS_SEEN[$sp]}|$k"; fi
    fi
  done
  local si
  for si in "${!REG_SRC[@]}"; do
    local sp="${REG_SRC[$si]}"
    local n="${SRC_HITS[$sp]:-0}"
    local kws_disp="${SRC_KWS_SEEN[$sp]:-}"
    if [ -z "$kws_disp" ]; then
      # show registry keywords when n=0? contract says "kw=<锚词>" - report matched kw; n=0 means none matched
      kws_disp="-"
    fi
    printf '[diff-audit] %s: deleted-line hits=%s (kw=%s)\n' "$sp" "$n" "$kws_disp"
  done

  local gen_at
  gen_at="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || printf '')"
  jq -nc --argjson files "$files_json" --argjson source_hits "$DIFF_AUDIT_HITS_JSON" --arg generated_at "$gen_at" \
    '{files:$files,source_hits:$source_hits,generated_at:$generated_at}' > "$manifest" 2>/dev/null || true
  # Persist files list into sidecar for init-session overlap/acceptance checks (best-effort)
  if [ -f "$sidecar" ]; then
    local _fpaths
    _fpaths="$(printf '%s' "$files_json" | jq -c '[.[].path]' 2>/dev/null || printf '[]')"
    sc_apply '(.files = $f)' --argjson f "$_fpaths" >/dev/null 2>&1 || true
  fi
  return 0
}

# ─────────────────────────── diff ───────────────────────────

FROM_REF=""; FROM_TREE=""; FROM_SHA=""
resolve_from() { # --from <sha|label> → 检查点 label/ref/sha 或任意 commit/tree
  local arg="$1" idx t
  idx="$(jq -r --arg a "$arg" \
    '.checkpoints | to_entries | map(select(.value.label==$a or .value.ref==$a or .value.sha==$a)) | last | .key // empty' \
    "$sidecar" 2>/dev/null || true)"
  if [ -n "$idx" ] && [ "$idx" != null ]; then
    FROM_REF="$(jq -r --argjson i "$idx" '.checkpoints[$i].ref' "$sidecar")"
    FROM_TREE="$(jq -r --argjson i "$idx" '.checkpoints[$i].tree' "$sidecar")"
    FROM_SHA="$(jq -r --argjson i "$idx" '.checkpoints[$i].sha' "$sidecar")"
    return 0
  fi
  t="$(git -C "$repo" rev-parse --verify --quiet "${arg}^{tree}" 2>/dev/null || true)"
  [ -n "$t" ] || return 1
  FROM_REF="$arg"; FROM_TREE="$t"
  FROM_SHA="$(git -C "$repo" rev-parse --verify --quiet "${arg}^{commit}" 2>/dev/null || printf '%s' "$arg")"
  return 0
}

in_scope() { # in_scope <path> — plans/ 豁免；scope 列表逐条前缀匹配
  local p="$1" s
  case "$p" in plans/*) return 0 ;; esac
  for s in "${SCOPES[@]}"; do
    [ -n "$s" ] || continue
    if [ "$p" = "$s" ] || [[ "$p" == "$s"/* ]]; then return 0; fi
  done
  return 1
}

oos_head_clean() { # <path> — 范围外文件是否被 HEAD 跟踪且相对当前 HEAD 工作树/索引干净
  # [2026-11-24] 他会话在任务开始后提交的范围外文件：相对任务基线有 diff，但相对 HEAD 干净，
  # 不应记为本任务偏移；若本地仍有改动/未跟踪，则照常 unresolved。
  local p="$1" rc=0
  git -C "$repo" cat-file -e "HEAD:${p}" 2>/dev/null || return 1
  git -C "$repo" diff --quiet HEAD -- "$p" 2>/dev/null || rc=$?
  [ "$rc" -eq 0 ]
}

disposal_valid_for() { # 按 dispose 同规则重放 sidecar 中该 path 的每条 ok=true 记录（防事后篡改）
  local p="$1" mkitems="$2" i=0 cnt dp dok ds de
  cnt="$(jq -r '.disposal|length' "$sidecar" 2>/dev/null || printf '0')"
  while [ "$i" -lt "$cnt" ]; do
    dp="$(jq -r --argjson i "$i" '.disposal[$i].path // ""' "$sidecar" 2>/dev/null || true)"
    if [ "$dp" = "$p" ]; then
      dok="$(jq -r --argjson i "$i" '.disposal[$i].ok // false' "$sidecar" 2>/dev/null || true)"
      if [ "$dok" = true ]; then
        ds="$(jq -r --argjson i "$i" '.disposal[$i].state // ""' "$sidecar" 2>/dev/null || true)"
        de="$(jq -r --argjson i "$i" '.disposal[$i].evidence // ""' "$sidecar" 2>/dev/null || true)"
        if validate_disposal "$p" "$ds" "$de" "$mkitems" >/dev/null 2>&1; then return 0; fi
      fi
    fi
    i=$((i + 1))
  done
  return 1
}

cmd_diff() {
  require_sidecar_repo
  # [2026-11-24 S5/S26] ATTTEST 一致性：必保清单随计划 attest 锁定；计划被改而没重新批准时，
  # MK 清单可能已被放宽，此时差异分析即便「必保项全 OK」也不能信——锁存在且 hash 不符即 rc=1 阻断。
  # 锁不存在/无 plan_sha256 行 = 存量计划不可读，WARN 放行（不静默当作通过）。
  local att="${plan_dir}/.plan-attestation" locked="" actual=""
  local warn='[git-baseline] WARN PLAN-NOT-ATTESTED（存量计划兼容；新计划应 attest-plan.sh）'
  if [ -f "$att" ]; then
    locked="$(grep -m1 '^plan_sha256=' "$att" 2>/dev/null | cut -d= -f2- | tr -d '[:space:]' || true)"
    if [ -n "$locked" ] && [ -f "${plan_dir}/task_plan.md" ]; then
      actual="$(sha256sum "${plan_dir}/task_plan.md" 2>/dev/null | cut -d' ' -f1)"
      [ "$actual" = "$locked" ] || die 1 "PLAN TAMPERED: 计划内容在 attest 之后被改动（MK 清单/必保项可能被改写），先重新 attest-plan.sh 再重跑 B11"
    else printf '%s\n' "$warn" >&2; fi
  else printf '%s\n' "$warn" >&2; fi
  local baseline_sha baseline_tree cur_tree td ns num rc=0
  baseline_sha="$(sc_get '.baseline_sha // ""')"
  baseline_tree="$(sc_get '.baseline_tree // ""')"
  [ -n "$baseline_sha" ] && [ -n "$baseline_tree" ] || die 3 "NO_BASELINE（sidecar 缺基线字段）"

  make_tree || die 2 "生成当前树失败"
  cur_tree="$CUR_TREE"

  if [ "$final" -eq 1 ]; then
    FROM_REF="baseline"; FROM_TREE="$baseline_tree"; FROM_SHA="$baseline_sha"
  elif [ -n "$from_arg" ]; then
    resolve_from "$from_arg" || die 1 "无法解析 --from=$from_arg"
  else
    FROM_REF="$(jq -r '.checkpoints[-1].ref // ""' "$sidecar" 2>/dev/null || true)"
    FROM_TREE="$(jq -r '.checkpoints[-1].tree // ""' "$sidecar" 2>/dev/null || true)"
    FROM_SHA="$(jq -r '.checkpoints[-1].sha // ""' "$sidecar" 2>/dev/null || true)"
    if [ -z "$FROM_TREE" ] || [ "$FROM_TREE" = null ]; then
      FROM_REF="baseline"; FROM_TREE="$baseline_tree"; FROM_SHA="$baseline_sha"
      printf '[git-baseline] WARN 无 checkpoint，增量对照回退到基线\n' >&2
    fi
  fi

  td="$(mktemp -d "${TMPDIR:-/tmp}/git-baseline-diff.XXXXXX")" || die 2 "mktemp 失败"
  CLEANUP_DIRS+=("$td")
  ns="${td}/ns"; num="${td}/num"
  git -C "$repo" diff --name-status -M -z "$FROM_TREE" "$cur_tree" > "$ns" || die 2 "git diff --name-status 失败"
  git -C "$repo" diff --numstat -M -z "$FROM_TREE" "$cur_tree" > "$num" || die 2 "git diff --numstat 失败"

  declare -a F_STATUS=() F_PATH=() F_OLD=() F_ADD=() F_DEL=() F_BIN=() F_DL=() F_OOS=() F_OK=()
  declare -A N_ADD=() N_DEL=() N_BIN=()
  local st p1 p2 stx fp old a d p dl nline rec rest oldp
  while IFS= read -r -d '' st; do
    IFS= read -r -d '' p1 || break
    case "$st" in
      R*|C*) IFS= read -r -d '' p2 || p2=""; stx="R"; fp="$p2"; old="$p1" ;;
      *) stx="${st:0:1}"; fp="$p1"; old="" ;;
    esac
    [ -n "$fp" ] || continue
    F_STATUS+=("$stx"); F_PATH+=("$fp"); F_OLD+=("$old")
  done < "$ns"

  # [2026-11-24 修 bug] git diff --numstat -z 的真实格式不是「a\0d\0path\0」：
  #   普通文件一条 NUL 记录 = "added<TAB>deleted<TAB>path"（两个 TAB 在同一记录里）；
  #   重命名文件首记录第三字段为空，old/new 续在随后两条 NUL 记录；二进制仍是 "-<TAB>-<TAB>path"。
  # 旧实现按三条记录读，键全错导致报告总表恒 +0/-0。
  while IFS= read -r -d '' rec; do
    case "$rec" in *$'\t'*) ;; *) continue ;; esac
    a="${rec%%$'\t'*}"
    rest="${rec#*$'\t'}"
    case "$rest" in *$'\t'*) ;; *) continue ;; esac
    d="${rest%%$'\t'*}"
    p="${rest#*$'\t'}"
    if [ -z "$p" ]; then
      IFS= read -r -d '' oldp || oldp=""
      IFS= read -r -d '' p || p=""
    fi
    [ -n "$p" ] || continue
    if [ "$a" = "-" ] || [ "$d" = "-" ]; then
      N_BIN["$p"]=1; N_ADD["$p"]=0; N_DEL["$p"]=0
    else
      N_BIN["$p"]=0; N_ADD["$p"]="$a"; N_DEL["$p"]="$d"
    fi
  done < "$num"

  # scope 列表：--scope 文件优先，否则 plan-state.json.config.scope_files；两者皆无 → plans/ 外全越界
  SCOPES=()
  local slist="" s
  if [ -n "$scope_file" ]; then
    [ -f "$scope_file" ] || die 1 "--scope 文件不存在: $scope_file"
    slist="$(cat -- "$scope_file")"
  else
    slist="$(jq -r '.config.scope_files[]?' "${plan_dir}/plan-state.json" 2>/dev/null || true)"
  fi
  if [ -n "$slist" ]; then
    while IFS= read -r s; do
      s="${s%$'\r'}"
      # 去首尾空白，忽略空行与注释
      s="${s#"${s%%[![:space:]]*}"}"; s="${s%"${s##*[![:space:]]}"}"
      [ -n "$s" ] && [[ "$s" != \#* ]] && SCOPES+=("$s")
    done <<< "$slist"
  fi

  # 逐文件：+/-、删除行、越界判定
  # [P1 修复] 每条删除行同步固化为 last_diff.items(kind=deleted)，供 retained/fixed 证据核对；
  # 片段截 240 字、每文件上限 20 条，避免巨型行/批量删除撑爆侧车。
  local -a DELETED_ITEMS=()
  local deleted_lines=0 n_added=0 n_modified=0 n_deleted=0 n_oos=0 i
  for i in "${!F_PATH[@]}"; do
    p="${F_PATH[$i]}"
    F_ADD[$i]="${N_ADD[$p]:-0}"; F_DEL[$i]="${N_DEL[$p]:-0}"
    case "${F_STATUS[$i]}" in A) n_added=$((n_added + 1)) ;; D) n_deleted=$((n_deleted + 1)) ;; *) n_modified=$((n_modified + 1)) ;; esac
    F_BIN[$i]="${N_BIN[$p]:-0}"; F_DL[$i]=""
    if [ "${F_BIN[$i]}" = 1 ]; then
      F_DL[$i]="Binary"   # 二进制无法逐行比，仍列为待处置
    elif [ "${F_STATUS[$i]}" = M ] || [ "${F_STATUS[$i]}" = D ] || [ "${F_STATUS[$i]}" = R ]; then
      dl="$(git -C "$repo" diff -U0 "$FROM_TREE" "$cur_tree" -- "$p" 2>/dev/null | grep -E '^-' | grep -vE '^---' || true)"
      F_DL[$i]="$dl"
      if [ -n "$dl" ]; then
        nline="$(printf '%s\n' "$dl" | grep -c . || true)"
        deleted_lines=$((deleted_lines + nline))
        local dn=0 vv
        while IFS= read -r vv; do
          [ -n "$vv" ] || continue
          dn=$((dn + 1)); [ "$dn" -le 20 ] || break
          # vv 来自 diff 输出（ "-原文" ）；证据要写真正的行内容，剥掉 diff 的 '-' 标记
          vv="${vv#-}"; vv="${vv:0:240}"
          DELETED_ITEMS+=("$(jq -nc --arg path "$p" --arg verbatim "$vv" \
            '{kind:"deleted",path:$path,verbatim:$verbatim}')")
        done <<< "$dl"
      fi
    fi
    if in_scope "$p"; then F_OOS[$i]=0; else F_OOS[$i]=1; n_oos=$((n_oos + 1)); fi
  done

  # 必保项查证（grep 字面串，不解释正则；路径穿越视为丢失）
  mk_collect
  local mk_lost=0 j id vb tg lost=0
  local -a MK_LOST_PATHS=() MK_LOST_VERBS=() MK_LOST_IDS=() MK_LOST_ITEMS=() MK_ITEMS=()
  for i in "${!MK_ID[@]}"; do
    id="${MK_ID[$i]}"; vb="${MK_VERB[$i]}"; tg="${MK_TARGET[$i]}"
    lost=0
    if [ -z "$vb" ] || [ -z "$tg" ] || [[ "$tg" == /* ]] || [[ "$tg" == *../* ]]; then
      lost=1
    elif [ ! -f "${repo}/${tg}" ]; then
      lost=1
    elif ! grep -qF -- "$vb" "${repo}/${tg}" 2>/dev/null; then
      lost=1
    fi
    if [ "$lost" -eq 1 ]; then
      mk_lost=$((mk_lost + 1))
      printf 'MK%s LOST %s @ %s\n' "$((i + 1))" "$vb" "$tg"
      MK_LOST_PATHS+=("$tg"); MK_LOST_VERBS+=("$vb"); MK_LOST_IDS+=("$id")
      MK_LOST_ITEMS+=("$(jq -nc --arg id "$id" --arg path "$tg" --arg verbatim "$vb" \
        '{kind:"mustkeep_lost",id:$id,path:$path,verbatim:$verbatim}')")
    else
      MK_ITEMS+=("$(jq -nc --arg id "$id" --arg path "$tg" \
        '{kind:"mustkeep_ok",id:$id,path:$path}')")
    fi
  done

  # 待处置需求：有删除行的文件 ∪ 越界文件 ∪ mustkeep_lost 文件（按 path 去重，同 path 合并校验）
  # 范围外且相对当前 HEAD 干净（HEAD 已跟踪、无本地改动）的文件不算本任务偏移；
  # 范围内（F_OOS=0）判定完全不变。
  local -a REQ_PATHS=() F_HEADCLEAN=()
  for i in "${!F_PATH[@]}"; do
    p="${F_PATH[$i]}"; F_HEADCLEAN[$i]=0
    if [ "${F_OOS[$i]}" = 1 ] && oos_head_clean "$p"; then
      F_HEADCLEAN[$i]=1
      continue
    fi
    if [ -n "${F_DL[$i]}" ] || [ "${F_OOS[$i]}" = 1 ]; then REQ_PATHS+=("$p"); fi
  done
  for tg in "${MK_LOST_PATHS[@]}"; do REQ_PATHS+=("$tg"); done
  local -a UNIQ_PATHS=()
  for p in "${REQ_PATHS[@]}"; do
    local seen=0 q
    for q in "${UNIQ_PATHS[@]}"; do [ "$q" = "$p" ] && seen=1; done
    [ "$seen" -eq 0 ] && UNIQ_PATHS+=("$p")
  done

  # [2026-11-24] 存量脏文件豁免：只有锚定过且内容 blob 未变才从待处置集合剔除；
  # 一旦内容被本任务改动（blob 变化）就恢复为普通未处置项。未锚定/字段缺失时行为完全不变。
  # deleted=true 的存量已删项：路径仍不存在且 HEAD blob 未变才豁免；恢复成文件则走普通处置。
  local -a PREEXIST_PATHS=() KEPT_PATHS=()
  local anchored_blob anchored_del cur_blob head_blob
  if [ "$(jq -r 'if (.preexisting_dirty|type)=="array" then "1" else "0" end' "$sidecar" 2>/dev/null || printf '0')" = 1 ]; then
    for p in "${UNIQ_PATHS[@]}"; do
      anchored_blob="$(jq -r --arg p "$p" '[.preexisting_dirty[]? | select(.path==$p) | .blob][0] // empty' "$sidecar" 2>/dev/null || true)"
      anchored_del="$(jq -r --arg p "$p" '[.preexisting_dirty[]? | select(.path==$p) | (.deleted // false)][0] // false' "$sidecar" 2>/dev/null || true)"
      if [ -n "$anchored_blob" ] && [ "$anchored_del" = true ]; then
        # 存量已删：只有路径仍不存在、且 HEAD blob 未变才豁免；被恢复成文件就不再豁免
        if [ ! -e "${repo}/${p}" ]; then
          head_blob="$(git -C "$repo" rev-parse "HEAD:${p}" 2>/dev/null || true)"
          if [ -n "$head_blob" ] && [ "$head_blob" = "$anchored_blob" ]; then
            PREEXIST_PATHS+=("$p"); continue
          fi
        fi
      elif [ -n "$anchored_blob" ] && [ -f "${repo}/${p}" ]; then
        cur_blob="$(git -C "$repo" hash-object -- "$p" 2>/dev/null || true)"
        if [ -n "$cur_blob" ] && [ "$cur_blob" = "$anchored_blob" ]; then
          PREEXIST_PATHS+=("$p"); continue
        fi
      fi
      KEPT_PATHS+=("$p")
    done
    UNIQ_PATHS=("${KEPT_PATHS[@]}")
  fi

  local mkitems="" unresolved=0
  local -a UNRES_ITEMS=()
  for p in "${UNIQ_PATHS[@]}"; do
    mkitems=""
    for j in "${!MK_LOST_PATHS[@]}"; do
      if [ "${MK_LOST_PATHS[$j]}" = "$p" ]; then
        mkitems+="${MK_LOST_IDS[$j]}"$'\t'"${MK_LOST_VERBS[$j]}"$'\n'
      fi
    done
    if disposal_valid_for "$p" "$mkitems"; then
      F_OK+=("1")
    else
      unresolved=$((unresolved + 1))
      UNRES_ITEMS+=("$(jq -nc --arg path "$p" '{kind:"unresolved",path:$path}')")
    fi
  done
  # 处置状态回填到总表（同 path 复用判定结果）
  for i in "${!F_PATH[@]}"; do
    p="${F_PATH[$i]}"
    mkitems=""
    for j in "${!MK_LOST_PATHS[@]}"; do
      if [ "${MK_LOST_PATHS[$j]}" = "$p" ]; then
        mkitems+="${MK_LOST_IDS[$j]}"$'\t'"${MK_LOST_VERBS[$j]}"$'\n'
      fi
    done
    if [ "${F_HEADCLEAN[$i]}" = 1 ]; then
      F_OK[$i]=1
    elif [ -n "${F_DL[$i]}" ] || [ "${F_OOS[$i]}" = 1 ]; then
      if disposal_valid_for "$p" "$mkitems"; then F_OK[$i]=1; else F_OK[$i]=0; fi
    else
      F_OK[$i]=1
    fi
  done

  # 报告（tmp + mv，读者不会看到半截文件）
  local rtmp; rtmp="$(mktemp "${plan_dir}/.git-baseline-report.tmp.XXXXXX")" || die 2 "报告临时文件失败"
  {
    printf '# Git Baseline 差异报告\n\n'
    printf -- '- 任务: %s\n' "$task_id"
    printf -- '- 起点(ref): %s\n' "$FROM_REF"
    printf -- '- 起点(tree): %s / 当前(tree): %s\n' "$FROM_TREE" "$cur_tree"
    printf -- '- 生成时间: %s\n\n' "$now"
    printf '## 总表\n\n'
    printf '| 文件 | 状态 | +/- | 处置状态 |\n| --- | --- | --- | --- |\n'
    for i in "${!F_PATH[@]}"; do
      local fcell="${F_PATH[$i]}"
      fcell="${fcell//|/\\|}"
      local is_pre=0 q2
      for q2 in "${PREEXIST_PATHS[@]}"; do [ "$q2" = "${F_PATH[$i]}" ] && is_pre=1; done
      if [ "$is_pre" -eq 1 ]; then ost="存量豁免"
      elif [ "${F_HEADCLEAN[$i]}" = 1 ]; then ost="范围外·HEAD 干净"
      elif [ "${F_OK[$i]}" = 1 ]; then ost="已处置/无需处置"; else ost="未处置"; fi
      # 二进制在 git numstat 中是 "-/-"，照原样呈现，不再伪装成 +0/-0
      local counts
      if [ "${F_BIN[$i]}" = 1 ]; then counts='-/-'
      else counts="+${F_ADD[$i]}/-${F_DEL[$i]}"; fi
      printf '| %s | %s | %s | %s |\n' "$fcell" "${F_STATUS[$i]}" "$counts" "$ost"
    done
    printf '\n## 逐文件删除行\n\n'
    for i in "${!F_PATH[@]}"; do
      [ -n "${F_DL[$i]}" ] || continue
      printf '### %s\n\n```diff\n%s\n```\n\n' "${F_PATH[$i]}" "${F_DL[$i]}"
    done
    printf '## 必保项(MUSTKEEP)查证\n\n'
    if [ ${#MK_LOST_ITEMS[@]} -eq 0 ] && [ ${#MK_ITEMS[@]} -eq 0 ]; then
      printf '(无必保项)\n'
    else
      for i in "${!MK_ID[@]}"; do
        found=0
        for j in "${!MK_LOST_IDS[@]}"; do
          # id 相同即本条丢失（同 id 多条按 id 计）
          if [ "${MK_ID[$i]}" = "${MK_LOST_IDS[$j]}" ]; then found=1; fi
        done
        if [ "$found" -eq 1 ]; then
          printf -- '- %s LOST %s @ %s\n' "${MK_ID[$i]}" "${MK_VERB[$i]}" "${MK_TARGET[$i]}"
        else
          printf -- '- %s OK %s @ %s\n' "${MK_ID[$i]}" "${MK_VERB[$i]}" "${MK_TARGET[$i]}"
        fi
      done
    fi
    printf '\n## 越界文件\n\n'
    local oos_any=0
    for i in "${!F_PATH[@]}"; do
      if [ "${F_OOS[$i]}" = 1 ]; then printf -- '- %s\n' "${F_PATH[$i]}"; oos_any=1; fi
    done
    [ "$oos_any" -eq 1 ] || printf '(无)\n'
    printf '\n## 存量脏文件（非本任务，锚定时已存在且未变）\n\n'
    if [ ${#PREEXIST_PATHS[@]} -eq 0 ]; then printf '(无)\n'
    else for p in "${PREEXIST_PATHS[@]}"; do printf -- '- %s\n' "$p"; done; fi
    # [2026-11-24 可审计] 被授权豁免的删除必须在报告里一眼可见：逐行列出 sidecar.disposal
    printf '\n## 处置记录\n\n'
    local ndisp di dp ds de
    ndisp="$(jq -r '.disposal|length' "$sidecar" 2>/dev/null || printf '0')"
    if [ "$ndisp" = 0 ]; then
      printf '(无)\n'
    else
      di=0
      while [ "$di" -lt "$ndisp" ]; do
        dp="$(jq -r --argjson i "$di" '.disposal[$i].path // ""' "$sidecar" 2>/dev/null || true)"
        ds="$(jq -r --argjson i "$di" '.disposal[$i].state // ""' "$sidecar" 2>/dev/null || true)"
        de="$(jq -r --argjson i "$di" '.disposal[$i].evidence // ""' "$sidecar" 2>/dev/null || true)"
        de="${de//$'\n'/ }"   # 一条处置记录占一行，证据内换行折叠为空格
        printf -- '- %s | %s | %s\n' "$dp" "$ds" "$de"
        di=$((di + 1))
      done
    fi
    printf '\n## 结论\n\n'
    # [P1 修复] 必保项丢失即使已「处置」也不得 PASS：处置只表示有授权，事实仍缺失。
    if [ "$unresolved" -eq 0 ] && [ "$mk_lost" -eq 0 ]; then printf 'PASS unresolved=0 mustkeep_lost=0\n'
    else printf 'FAIL unresolved=%s mustkeep_lost=%s\n' "$unresolved" "$mk_lost"; fi
  } > "$rtmp"
  mv -f -- "$rtmp" "$report" || die 2 "报告写入失败"

  # sidecar.last_diff 固化（items = 未决项 + MK 丢失项 + deleted 原文项，供 dispose 复核）
  local all_items_json unres_json mk_json del_json
  unres_json="[$(IFS=,; printf '%s' "${UNRES_ITEMS[*]:-}")]"
  mk_json="[$(IFS=,; printf '%s' "${MK_LOST_ITEMS[*]:-}")]"
  del_json="[$(IFS=,; printf '%s' "${DELETED_ITEMS[*]:-}")]"
  # 每段各自是 JSON 数组，jq -s 收成 [[…],…] 后 add 合并，避免 bash 拼串造成多余分隔符
  all_items_json="$(printf '%s\n%s\n%s\n' "$unres_json" "$mk_json" "$del_json" | jq -c -s 'add')" \
    || die 2 "items JSON 合并失败"
  sc_apply '(.last_diff = {at:$at,from_ref:$from,report:$report,added:$added,modified:$modified,
    deleted:$deleted,out_of_scope:$oos,deleted_lines:$dl,unresolved:$unres,mustkeep_lost:$mklost,items:$items})' \
    --arg at "$now" --arg from "$FROM_REF" --arg report "$report" \
    --argjson added "$n_added" --argjson modified "$n_modified" --argjson deleted "$n_deleted" \
    --argjson oos "$n_oos" --argjson dl "$deleted_lines" --argjson unres "$unresolved" \
    --argjson mklost "$mk_lost" --argjson items "$all_items_json" || die 2 "sidecar last_diff 写入失败"

  # diff-audit manifest + [diff-audit] stdout lines (append-only; existing output preserved byte-for-byte above)
  emit_diff_audit_manifest "$plan_dir" "$repo" "$FROM_TREE" "$cur_tree" || true

  if [ "$unresolved" -eq 0 ] && [ "$mk_lost" -eq 0 ]; then
    printf '[git-baseline] PASS unresolved=0 mustkeep_lost=0 report=%s\n' "$report"
    return 0
  fi
  printf '[git-baseline] FAIL unresolved=%s mustkeep_lost=%s report=%s\n' "$unresolved" "$mk_lost" "$report"
  if [ "$enforce" = warn ]; then return 0; fi
  return 1
}

# ─────────────────────────── manifest（只读输出/重生成 manifest） ───────────────────────────

cmd_manifest() {
  require_sidecar_repo
  local baseline_sha baseline_tree cur_tree
  baseline_sha="$(sc_get '.baseline_sha // ""')"
  baseline_tree="$(sc_get '.baseline_tree // ""')"
  [ -n "$baseline_sha" ] && [ -n "$baseline_tree" ] || die 3 "NO_BASELINE（sidecar 缺基线字段）"
  make_tree || die 2 "生成当前树失败"
  cur_tree="$CUR_TREE"
  # manifest 等价 diff --final 的 manifest 部分：以 baseline tree 对照当前树
  emit_diff_audit_manifest "$plan_dir" "$repo" "$baseline_tree" "$cur_tree" || true
  # 输出 manifest 路径便于调用方
  printf '[diff-audit] manifest=%s\n' "${plan_dir}/.diff-manifest.json"
  return 0
}

# ─────────────────────────── dispose ───────────────────────────

cmd_dispose() {
  require_sidecar_repo
  [ -n "$state_arg" ] || die 1 "dispose 需 --state"
  case "$state_arg" in retained|authorized|restored|fixed) ;; *) die 1 "非法 --state: $state_arg" ;; esac
  [ -n "$evidence_arg" ] || die 1 "dispose 需 --evidence"
  [ "${#RESTORE_FILES[@]}" -gt 0 ] || die 1 "dispose 需 --file"
  local p
  p="$(norm_path "${RESTORE_FILES[$(( ${#RESTORE_FILES[@]} - 1 ))]}")" || die 1 "--file 路径非法"
  local mkitems
  mkitems="$(mk_verbs_sidecar "$p")"
  if validate_disposal "$p" "$state_arg" "$evidence_arg" "$mkitems"; then
    sc_apply '(.disposal += [{path:$p,state:$s,evidence:$e,at:$at,ok:true}])' \
      --arg p "$p" --arg s "$state_arg" --arg e "$evidence_arg" --arg at "$now" \
      || die 2 "sidecar disposal 写入失败"
    printf '[git-baseline] DISPOSE OK path=%s state=%s\n' "$p" "$state_arg"
    return 0
  fi
  printf '[git-baseline] DISPOSE REJECT path=%s state=%s reason=%s\n' "$p" "$state_arg" "$DREASON"
  return 1
}

# ─────────────────────────── restore ───────────────────────────

cmd_restore() {
  require_sidecar_repo
  if [ "$all_flag" -eq 0 ] && [ "${#RESTORE_FILES[@]}" -eq 0 ]; then
    die 1 "restore 需 --file <path> 或 --all"
  fi
  local src; src="${from_arg:-}"
  [ -n "$src" ] || src="$(sc_get '.baseline_sha // ""')"
  [ -n "$src" ] && git -C "$repo" cat-file -e "${src}^{commit}" 2>/dev/null || die 1 "--from 不是有效提交: $src"

  # 先自动打检查点，便于还原动作本身可审计/可回退
  write_checkpoint "pre-restore" "pre-restore" || die 2 "还原前 checkpoint 失败"
  printf '[git-baseline] CHECKPOINT %s\n' "$CHECKPOINT_REF"

  local td list; td="$(mktemp -d "${TMPDIR:-/tmp}/git-baseline-restore.XXXXXX")" || die 2 "mktemp 失败"
  CLEANUP_DIRS+=("$td"); list="${td}/paths"
  git -C "$repo" ls-tree -r -z --name-only "$src" > "$list" || die 2 "ls-tree 失败"

  local -a paths=()
  local np req pp hit
  if [ "$all_flag" -eq 1 ]; then
    while IFS= read -r -d '' pp; do paths+=("$pp"); done < "$list"
  else
    for req in "${RESTORE_FILES[@]}"; do
      np="$(norm_path "$req")" || die 1 "--file 路径非法: $req"
      hit=0
      while IFS= read -r -d '' pp; do
        if [ "$pp" = "$np" ]; then hit=1; break; fi
      done < "$list"
      if [ "$hit" -eq 1 ]; then paths+=("$np")
      else printf '[git-baseline] SKIP 源中不存在: %s\n' "$np"; fi
    done
  fi
  [ "${#paths[@]}" -gt 0 ] || die 1 "无可还原路径"

  git -C "$repo" restore --source="$src" --worktree -- "${paths[@]}" || die 1 "git restore 失败"

  local bad=0 rc=0 p
  for p in "${paths[@]}"; do
    rc=0; git -C "$repo" diff --quiet "$src" -- "$p" 2>/dev/null || rc=$?
    if [ "$rc" -ne 0 ]; then printf '[git-baseline] VERIFY FAIL %s\n' "$p"; bad=$((bad + 1)); fi
  done
  if [ "$bad" -eq 0 ]; then
    printf '[git-baseline] RESTORE OK src=%s files=%s\n' "$src" "${#paths[@]}"
    return 0
  fi
  printf '[git-baseline] RESTORE FAIL files=%s\n' "$bad"
  return 1
}

# ─────────────────────────── status ───────────────────────────

cmd_status() {
  if [ ! -f "$sidecar" ]; then
    printf '[git-baseline] ERROR NO_BASELINE\n'
    return 3
  fi
  local u mkl cp ndisp mkempty late
  u="$(sc_get '.last_diff.unresolved // 0')"; [ -n "$u" ] || u=0
  mkl="$(sc_get '.last_diff.mustkeep_lost // 0')"; [ -n "$mkl" ] || mkl=0
  cp="$(sc_get '.checkpoints|length')"
  ndisp="$(sc_get '.disposal|length')"
  mkempty="$(sc_get '.mustkeep.empty')"
  late="$(sc_get '.late')"
  printf '[git-baseline] STATUS task=%s repo=%s mode=%s\n' "$task_id" "$repo" "$repo_mode"
  printf '[git-baseline] baseline_ref=%s sha=%s files=%s late=%s\n' \
    "$(sc_get '.baseline_ref // ""')" "$(sc_get '.baseline_sha // ""')" \
    "$(sc_get '.file_count // 0')" "$late"
  printf '[git-baseline] mustkeep empty=%s count=%s source=%s\n' \
    "$mkempty" "$(sc_get '.mustkeep.count // 0')" "$(sc_get '.mustkeep.source // ""')"
  printf '[git-baseline] checkpoints=%s disposal=%s unresolved=%s mustkeep_lost=%s\n' \
    "$cp" "$ndisp" "$u" "$mkl"
  [ "$u" = 0 ] && return 0 || return 1
}

# ─────────────────────────── 派发 ───────────────────────────

case "$cmd" in
  snapshot) cmd_snapshot ;;
  checkpoint) cmd_checkpoint ;;
  diff) cmd_diff ;;
  manifest) cmd_manifest ;;
  dispose) cmd_dispose ;;
  restore) cmd_restore ;;
  anchor-auth) cmd_anchor_auth ;;
  anchor-preexisting) cmd_anchor_preexisting ;;
  status) cmd_status ;;
esac
