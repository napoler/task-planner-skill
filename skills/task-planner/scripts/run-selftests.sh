#!/usr/bin/env bash
# run-selftests.sh — 全量 selftest 回归的统一入口（输入指纹缓存版）
#
# What:
#   枚举 scripts/selftest-*.sh 逐个执行，逐脚本输出 [run]/[reused]/[FAIL]，
#   末行以既有口径汇总 "Total: N PASS=x FAIL=y"（另附 reused=z，簿记可只抄前半）。
#   指纹 = 全部 selftest 脚本内容 + 技能源目录状态戳（git porcelain+HEAD，非 git 仓降级 tree-hash）；
#   指纹未变的脚本命中缓存即跳过重跑（[reused]），rc/FAIL 数照缓存值入账。
#
# Why（病灶与移植来源）：
#   task-planner 实测病灶=单任务固定开销含两轮全量回归（76 脚本 × 5-12s ≈ 6-15min/轮），
#   而两轮之间技能源码常零变更仍全量重跑；且历史上无任何入口/缓存机制，主进程手工 for 循环逐跑。
#   本脚本移植两处外部机制：
#     ① comet 0.4.5 检查证据指纹复用（输入语义匹配即 reused，绝不因缓存粉饰失败）；
#     ② planning-with-files KV-cache 稳定设计（未变化的检查不重复执行）。
#   缓存仅省 CPU，不省正确性：--fresh 可无视缓存全量重跑。
#
# 命名说明（2026-10-11 改名裁决）：
#   原名 selftest-runner.sh 以 selftest- 开头，会被自身 glob selftest-*.sh 命中 → 无参重跑全量
#   无限递归（实测 2000+ 进程）；且 selftest-registry.sh T02 要求每个 selftest-*.sh 登记 registry，
#   而本脚本是"入口"不是"断言脚本"，不该登记。改名 run-selftests.sh 一并规避两者，语义更准确。
#
# 用法：
#   run-selftests.sh                # 跑全部（命中缓存则复用）
#   run-selftests.sh --fresh        # 忽略缓存，全量重跑（新基线/发布前用）
#   run-selftests.sh --only PAT     # 仅跑脚本名匹配 PAT 的子集（如 --only dispatch；"--only PAT" 与 "--only=PAT" 均可）
#   run-selftests.sh --status       # 只读：打印指纹与缓存目录，立即退出（不执行任何脚本）
#
# 环境变量：
#   TASK_PLANNER_SELFTEST_CACHE_DIR   # 自定义缓存根目录（默认 ~/.cache/task-planner-selftest）

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$SKILL_ROOT/../.." && pwd)"

CACHE_DIR="${TASK_PLANNER_SELFTEST_CACHE_DIR:-${HOME}/.cache/task-planner-selftest}"
FRESH=0; ONLY=""; STATUS=0
# 参数解析（2026-10-11 缺陷修正）：while+shift 循环，--only PAT 分离写法与 --only=PAT 相等写法均支持；
# 原 for+PREV 方案中 "--only PAT" 分离写法会在下一轮 case 把 PAT 落入 * 分支误报 usage
while [ $# -gt 0 ]; do
  case "$1" in
    --fresh)   FRESH=1; shift ;;
    --status)  STATUS=1; shift ;;
    --only)    ONLY="${2:-}"; shift 2 ;;
    --only=*)  ONLY="${1#--only=}"; shift ;;
    *) echo "usage: $0 [--fresh] [--only PAT] [--status]" >&2; exit 2 ;;
  esac
done

# ---- 全局指纹：所有 selftest 内容 + 技能源目录状态 ----
fingerprint() {
  local content_hash state_hash
  content_hash="$(cat "$SCRIPT_DIR"/selftest-*.sh 2>/dev/null | sha256sum | cut -d' ' -f1)"
  if [ -d "$REPO_ROOT/.git" ] && git -C "$REPO_ROOT" rev-parse HEAD >/dev/null 2>&1; then
    # git 仓：HEAD + 未提交变更（含未跟踪）——任何技能源码变动都使指纹失效
    state_hash="$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null; git -C "$REPO_ROOT" status --porcelain "$SKILL_ROOT" 2>/dev/null | sha256sum | cut -d' ' -f1)"
  else
    # 非 git 仓：目录内容 tree-hash（慢路径，仅在无 .git 时触发）
    state_hash="$(find "$SKILL_ROOT" -type f \( -name '*.sh' -o -name '*.md' -o -name '*.json' \) \
      -exec sha256sum {} + 2>/dev/null | sort -k2 | sha256sum | cut -d' ' -f1)"
  fi
  printf '%s' "${content_hash}${state_hash}" | sha256sum | cut -d' ' -f1
}

FP="$(fingerprint)"
if [ "$STATUS" = "1" ]; then
  # --status 只读（2026-10-11 缺陷修正）：打印指纹后立即退出，绝不进入执行循环
  echo "fingerprint=$FP cache_dir=$CACHE_DIR"
  exit 0
fi

TOTAL=0; PASSN=0; FAILN=0; RUNN=0; REUSEDN=0; FAILED_LIST=""
mkdir -p "$CACHE_DIR"

for script in "$SCRIPT_DIR"/selftest-*.sh; do
  # 防御性兜底（2026-10-11）：显式排除自身——即使未来本目录再出现 selftest- 前缀的非断言脚本，
  # 也不会被枚举命中导致递归
  [ "$script" = "$SCRIPT_DIR/run-selftests.sh" ] && continue
  base="$(basename "$script" .sh)"
  if [ -n "$ONLY" ] && ! printf '%s' "$base" | grep -q "$ONLY"; then continue; fi
  TOTAL=$((TOTAL+1))
  cache_key="$(printf '%s' "$FP$base" | sha256sum | cut -d' ' -f1)"
  cache_file="$CACHE_DIR/$cache_key"

  if [ "$FRESH" = "0" ] && [ -f "$cache_file" ]; then
    rc=0; p=0; f=0; read -r rc p f < "$cache_file" 2>/dev/null || true
    REUSEDN=$((REUSEDN+1))
    if [ "${rc:-0}" = "0" ]; then PASSN=$((PASSN+1)); else FAILN=$((FAILN+1)); FAILED_LIST="$FAILED_LIST $base"; fi
    echo "[reused] $base (rc=${rc:-0} PASS=${p:-0} FAIL=${f:-0})"
    continue
  fi

  RUNN=$((RUNN+1))
  out="$(bash "$script" 2>&1)"; rc=$?
  p="$(printf '%s\n' "$out" | grep -oE 'PASS=[0-9]+' | tail -1 | cut -d= -f2)"
  f="$(printf '%s\n' "$out" | grep -oE 'FAIL=[0-9]+' | tail -1 | cut -d= -f2)"
  [ -z "$p" ] && p=0; [ -z "$f" ] && f=0
  # 仅 rc=0 才写缓存；rc≠0 的半途结果不缓存，下轮必须实跑重验
  if [ "$rc" = "0" ]; then printf '%s %s %s\n' "$rc" "$p" "$f" > "$cache_file"; fi
  if [ "$rc" = "0" ]; then PASSN=$((PASSN+1)); echo "[run]    $base (rc=0 PASS=$p FAIL=$f)"; else FAILN=$((FAILN+1)); FAILED_LIST="$FAILED_LIST $base"; echo "[FAIL]   $base (rc=$rc)"; fi
done

echo "Total: $TOTAL PASS=$PASSN FAIL=$FAILN (run=$RUNN reused=$REUSEDN)"
[ -n "$FAILED_LIST" ] && echo "Failed:$FAILED_LIST"
[ "$FAILN" -gt 0 ] && exit 1
exit 0
