#!/usr/bin/env bash
# selftest-doc-script-paths.sh — 文档脚本/文档引用路径存在性断言（「引用即契约」机械面）
#
# What（做什么）：
#   扫描 skills/*/SKILL.md 与卫星 skills/*/references/*.md 中的路径引用 token，按四级锚点解析为
#   仓库内真实路径并断言存在；缺失即逐条打印 `[doc-path] ✗ <文件:行> <引用>` 并以 exit 1 收口。
#   token 形态三类：
#     F1 skill 限定式（任意位置）：`<skill>/scripts/x.sh`、`../task-planner/references/y.md`、`task-planner/scripts/z.ts`
#     F2 自有技能相对式（仅表格行内、且须是反引号 span 的整段内容）：`scripts/x.sh`、`./scripts/x.sh`、`references/y.md`
#     F3 表格行「目录列 × 文件名列」组合（如 `| \`check-3file-gate.sh\` | … | \`<skill>/scripts/\` |`）
#   可选 --deploy：对 ~/.zcode/skills 同名技能树逐引用对账，仓库有、部署无的悬空引用单独报告。
#
# Why（病灶与取舍，Rule 45 What+Why 双层注释）：
#   2026-10-16 task-v181/P-10 盘点实测：卫星 SKILL.md 与 references 里的脚本引用是「人写路径 + 无机器断言」，
#   v171 专业化拆分（Rule 82 机械层留守主技能 scripts/）后路径串未同步 → 文档宣称的调用路径与磁盘实态不一致，
#   读者按文档执行必然 404。判例（本次实读确认）：verification-gate/SKILL.md:50/59/67-70/72 把主技能脚本标成
#   `<skill>/scripts/`（本卫星）与 `./scripts/`；task-dispatch/SKILL.md:54-55 把两个仍在 task-planner/scripts/
#   的 selftest 标成「随迁」本目录；task-drift-guard/references/critical-rules-drift.md:55 的
#   `<skill>/scripts/ledger-append.sh`、task-discipline/references/critical-rules-discipline.md:254 的
#   `skills/task-planner/references/capability-registry.md` 同属该类漂移。
#   本断言把「声明必须可被机器复核」落成静态存在性检查：不依赖存量计划（不扫 plans/）、不引入 config 键
#   （零新键纪律）——纯读断言，无写副作用。
#
# 锚点（解析顺序 first-hit-wins）与边界（防误报，Why 必读）：
#   ① 文档所在目录 ② 文档所属技能根 ③ 仓库 skills/ ④ 仓库根
#   —— 本仓 docs 混用「文档相对」（`../../task-planner/…`，见 plan-cost-guard/references/cost-control.md:168）
#   与「技能根相对」（`../task-planner/…`，见 progress-tracker/references/critical-rules-progress.md:16）
#   两种既有写法，多锚点是兼容既有约定的最小解；`<skill>` 占位符 = 文档自身所属技能（替换为 skills/<名>）。
#   有意不纳入（避免误报，逐条给理由）：
#     · 非表格行、非反引号整段的裸 token（`scripts/x.sh`）：卫星 docs 用裸 `scripts/` 指主技能机械层（Rule 82），
#       全仓 30+ 处属 v171 拆分遗留的表述债，非「路径契约」；表格行内该写法才是路径契约（F2/F3 覆盖）。
#     · 反引号 span 内含空格/变量的（如 `task-planner scripts/session-catchup.ts`、
#       `${TASK_PLANNER_ROOT:-…}/scripts/x.sh`）：单元格内的人读说明或 env 根路径，非仓库相对引用。
#     · 示例占位符（如 verification-gate/SKILL.md:38 的 `bash scripts/check-x.sh <plan>`）：说明性串非真实引用。
#   机器边界如实披露：本断言只判「文件是否存在」，不判「引用语义是否正确」（路径存在但指向错误文件=判不出）。
#
# 实现注记（Why 性能与可移植）：扫描走纯 bash（`=~` 为 POSIX ERE，leftmost-longest 语义同 grep -oE），
#   逐行不 fork 子进程——全仓 45 文档 5k+ 行实测 <1s；--deploy 面才用 awk/sort 汇总（opt-in 路径）。
#
# 用法：selftest-doc-script-paths.sh [--deploy]
#   退出码：0 = 全 PASS；1 = 存在缺失引用（T03）或断言自检失败（T01/T02）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"   # scripts/ → 技能根 → skills/ → 仓库根（三级）
SKILLS_ROOT="$REPO_ROOT/skills"
DEPLOY_ROOT="${TASK_PLANNER_DEPLOY_ROOT:-$HOME/.zcode/skills}"

DEPLOY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --deploy) DEPLOY=1; shift ;;
    *) echo "usage: $0 [--deploy]" >&2; exit 2 ;;
  esac
done

PASS=0; FAIL=0
pass() { PASS=$((PASS+1)); printf 'T%s PASS\n' "$1"; }
fail() { FAIL=$((FAIL+1)); printf 'T%s FAIL %s\n' "$1" "$2"; }

# ─── token 正则（EXT = 受检文件类型；js/ps1/cjs 与 sh/ts/md 同列，避免漏类）────────────
EXT_RE='(sh|ts|cjs|ps1|js|md)'
# F1：skill 限定式（前缀可为 <skill> 占位符 / 技能名 / ./ / ../，可叠加）
RE_F1='(\./|\.\./)*(<skill>|[A-Za-z0-9._-]+)/(scripts|references)/[A-Za-z0-9._-]+\.'"$EXT_RE"
# F2：自有技能相对式（整段形态，仅表格行反引号 span 命中）
RE_F2='^(\./)?(scripts|references)/[A-Za-z0-9._-]+\.'"$EXT_RE"'$'
# F3：表格行目录列（纯目录 span）与文件名列
RE_DIR='^(\./|\.\./)*(<skill>|[A-Za-z0-9._-]+)/(scripts|references)/$'
RE_FILE='^[A-Za-z0-9._-]+\.'"$EXT_RE"'$'
# --deploy 面：裸技能根引用 `../<skill>/`（文档指向另一技能整树）
RE_SKILLDIR='(\.\./)+(<skill>|[A-Za-z0-9._-]+)/'
BT=$'\x60'                                        # 反引号（span 提取用）
RE_BT="${BT}[^${BT}]+${BT}"

# ─── 解析器：token → 仓库内绝对路径（四级锚点 first-hit-wins）──────────────────────────
# 结果经全局 RESOLVED 回传（免每 token 一次命令替换 fork）；判别力由 T02 正负控自证。
RESOLVED=""
resolve_path() { # $1=token  $2=文档目录  $3=文档所属技能根
  local t="$1" ddir="$2" skroot="$3" a
  t="${t//<skill>/skills/${skroot##*/}}"          # 占位符 → skills/<文档所属技能>
  t="${t#./}"
  case "$t" in
    /*) [ -e "$t" ] && { RESOLVED="$t"; return 0; }; return 1 ;;   # 绝对路径直判（不做锚点拼接）
  esac
  for a in "$ddir" "$skroot" "$SKILLS_ROOT" "$REPO_ROOT"; do
    if [ -e "$a/$t" ]; then RESOLVED="$a/$t"; return 0; fi
  done
  return 1
}

# 仓库路径 → 部署位路径（仅 skills/ 子树参与对账；其余锚点面不在部署位语义内）
DEPLOY_PATH=""
deploy_map() { # $1=仓库内绝对路径
  case "$1" in
    "$SKILLS_ROOT"/*) DEPLOY_PATH="$(realpath -m "$DEPLOY_ROOT/${1#"$SKILLS_ROOT"/}")"; return 0 ;;
  esac
  return 1
}

DOCS="$(cd "$REPO_ROOT" && ls -1 skills/*/SKILL.md skills/*/references/*.md 2>/dev/null)"
DOC_N=0
TOKEN_N=0; FIND_N=0
FINDINGS=""
DEPLOY_TMP="$(mktemp "${TMPDIR:-/tmp}/doc-path-deploy-XXXXXX")"
trap 'rm -f "$DEPLOY_TMP"' EXIT
DEPLOY_HITS=0

TOKS=""
extract_tokens() { # $1=文本 $2=ERE；命中串（换行分隔）追加到 TOKS
  local s="$1" re="$2" m
  while [[ "$s" =~ $re ]]; do
    m="${BASH_REMATCH[0]}"
    TOKS="${TOKS}${m}"$'\n'
    s="${s#*"$m"}"
  done
}
SPANS=""
extract_spans() { # $1=文本；反引号 span 内容（去反引号，换行分隔）追加到 SPANS
  local s="$1" m
  while [[ "$s" =~ $RE_BT ]]; do
    m="${BASH_REMATCH[0]}"; m="${m#"$BT"}"; m="${m%"$BT"}"
    SPANS="${SPANS}${m}"$'\n'
    s="${s#*"${BASH_REMATCH[0]}"}"
  done
}
add_finding() { # $1=相对文档 $2=行号 $3=引用
  FINDINGS="${FINDINGS}[doc-path] ✗ ${1}:${2} ${3}"$'\n'
  FIND_N=$((FIND_N+1))
}
check_token() { # $1=token $2=相对文档 $3=行号 $4=文档目录 $5=技能根
  TOKEN_N=$((TOKEN_N+1))
  if ! resolve_path "$1" "$4" "$5"; then
    add_finding "$2" "$3" "$1"
    return 1
  fi
  if [ "$DEPLOY" = 1 ] && deploy_map "$RESOLVED" && [ ! -e "$DEPLOY_PATH" ]; then
    DEPLOY_HITS=$((DEPLOY_HITS+1))
    printf '%s|%s:%s|%s\n' "$DEPLOY_PATH" "$2" "$3" "$1" >> "$DEPLOY_TMP"
  fi
  return 0
}

scan_doc() { # $1=仓库相对文档路径
  local rel="$1" doc="$REPO_ROOT/$1" skroot ddir line txt row ln=0
  local tok seen dirs files d f sktoks name span
  case "$rel" in
    skills/*/SKILL.md)     skroot="$REPO_ROOT/${rel%/SKILL.md}" ;;
    skills/*/references/*) skroot="$REPO_ROOT/${rel%%/references/*}" ;;
    *) return 0 ;;
  esac
  ddir="${doc%/*}"
  DOC_N=$((DOC_N+1))
  while IFS= read -r line || [ -n "$line" ]; do
    ln=$((ln+1))
    # 行过滤：只取含路径形态的行（--deploy 面额外纳入裸技能根引用），避免全量逐行开销
    if [ "$DEPLOY" = 1 ]; then
      case "$line" in *scripts/*|*references/*|*../*) ;; *) continue ;; esac
    else
      case "$line" in *scripts/*|*references/*) ;; *) continue ;; esac
    fi
    txt="$line"
    row=0
    [[ "$txt" =~ ^[[:space:]]*\| ]] && row=1
    # F1：skill 限定式（任意位置）
    TOKS=""
    extract_tokens "$txt" "$RE_F1"
    seen=""
    for tok in $TOKS; do
      case "$seen" in *"|$tok|"*) continue ;; esac
      seen="$seen|$tok|"
      check_token "$tok" "$rel" "$ln" "$ddir" "$skroot" || true
    done
    # F2/F3：表格行反引号 span（F2=整段即自有技能相对路径；F3=目录列 × 文件名列组合）
    if [ "$row" = 1 ]; then
      SPANS=""
      extract_spans "$txt"
      dirs=""; files=""
      while IFS= read -r span; do
        [ -n "$span" ] || continue
        if [[ "$span" =~ $RE_F2 ]]; then
          check_token "$span" "$rel" "$ln" "$ddir" "$skroot" || true
        fi
        [[ "$span" =~ $RE_DIR ]] && dirs="$dirs$span"$'\n'
        [[ "$span" =~ $RE_FILE ]] && files="$files$span"$'\n'
      done <<< "$SPANS"
      while IFS= read -r d; do
        [ -n "$d" ] || continue
        while IFS= read -r f; do
          [ -n "$f" ] || continue
          check_token "$d$f" "$rel" "$ln" "$ddir" "$skroot" || true
        done <<< "$files"
      done <<< "$dirs"
    fi
    # --deploy 面：裸技能根引用（仅当名字对应仓内既有技能才纳入，防误报非技能目录）
    if [ "$DEPLOY" = 1 ]; then
      TOKS=""
      extract_tokens "$txt" "$RE_SKILLDIR"
      seen=""
      for tok in $TOKS; do
        case "$seen" in *"|$tok|"*) continue ;; esac
        seen="$seen|$tok|"
        name="$tok"
        while [[ "$name" == ../* ]]; do name="${name#../}"; done
        name="${name%/}"
        [ -d "$SKILLS_ROOT/$name" ] || continue
        if [ ! -d "$DEPLOY_ROOT/$name" ]; then
          DEPLOY_HITS=$((DEPLOY_HITS+1))
          printf '%s|%s:%s|%s\n' "$DEPLOY_ROOT/$name" "$rel" "$ln" "$tok" >> "$DEPLOY_TMP"
        fi
      done
    fi
  done < "$doc"
}

for rel in $DOCS; do scan_doc "$rel"; done

# ─── T01 扫描面在位（防 glob/结构异常致恒绿）─────────────────────────────────────────
if [ "$DOC_N" -ge 20 ] && [ "$TOKEN_N" -ge 60 ]; then
  pass 01
else
  fail 01 "扫描面不足：docs=$DOC_N（阈值 20）tokens=$TOKEN_N（阈值 60）——glob/仓库结构异常，断言可能退化为恒绿"
fi
printf 'T01 面：docs=%s tokens=%s\n' "$DOC_N" "$TOKEN_N"

# ─── T02 检测力自证（正负控：证明 resolve_path 有判别力，非恒真/恒假）───────────────────
ABSENT='scripts/__selftest_doc_path_probe_absent__.sh'
if resolve_path "$ABSENT" "$SCRIPT_DIR" "$SCRIPT_DIR/.."; then
  fail 02 "负控失效：合成缺失路径被解析为存在（$ABSENT）——断言不可信"
elif resolve_path "scripts/run-selftests.sh" "$SCRIPT_DIR" "$SCRIPT_DIR/.."; then
  pass 02
else
  fail 02 "正控失效：同目录真实存在的 scripts/run-selftests.sh 未解析出——断言不可信"
fi

# ─── T03 仓库面引用存在性（核心断言）────────────────────────────────────────────────
[ -n "$FINDINGS" ] && printf '%s' "$FINDINGS"
if [ "$FIND_N" -eq 0 ]; then
  pass 03
else
  fail 03 "存在缺失引用 $FIND_N 处（见上 ✗ 列表）"
fi

# ─── 部署面对账（--deploy，report-only：部署位同步属运维动作待授权，不计入 FAIL）──────────
if [ "$DEPLOY" = 1 ]; then
  if [ ! -d "$DEPLOY_ROOT" ]; then
    echo "[deploy-path] SKIP: 部署根不存在（$DEPLOY_ROOT）"
  elif [ "$DEPLOY_HITS" -eq 0 ]; then
    echo "[deploy-path] ✓ 无悬空引用（仓库有 / 部署有）"
  else
    UNIQ_N="$(cut -d'|' -f1 "$DEPLOY_TMP" | sort -u | grep -c . || true)"
    printf '[deploy-path] ✗ 悬空引用 %s 处（去重后 %s 个部署位路径；仓库有 / 部署无）\n' "$DEPLOY_HITS" "$UNIQ_N"
    awk -F'|' '!seen[$1]++' "$DEPLOY_TMP" | sort -t'|' -k1,1 | while IFS='|' read -r p first tok; do
      printf '  [deploy-path] ✗ %s ← %s %s\n' "$p" "$first" "$tok"
    done
    echo "[deploy-path] 注：report-only 不计入 FAIL——部署位同步属运维动作（待授权，与 registry RRV-13 部署位对账同批）"
  fi
fi

printf 'Total: %d PASS=%d FAIL=%d (docs=%s tokens=%s)\n' "$((PASS+FAIL))" "$PASS" "$FAIL" "$DOC_N" "$TOKEN_N"
exit $((FAIL > 0))
