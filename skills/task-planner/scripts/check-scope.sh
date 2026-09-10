#!/usr/bin/env bash
# check-scope.sh — PreToolUse guard: verify Write/Edit against session-scoped plan-required sentinel
#
# 哨兵机制：
#   - SessionStart 时 task-plan-init.cjs 写会话私有哨兵 <ROOT>/plans/.plan_required_side/<sidkey>.plan_required
#   - Agent 创建有效计划后调用 plan-created.cjs 清除本会话哨兵
#   - 哨兵存在时，禁止向非 plans/ 路径写入
#
# [2026-09-10 task-planrequired-race] 修改说明：原行为=从 $PWD 向上 4 级盲搜全局共享 .plan-required
#   （B2 位置写串 / B4 无会话归属，他会话写哨兵即误拦本会话）。现改为：
#   - 项目根解析：从 $PWD 向上找含 plans/ 的祖先（≤6 级）；找不到 → 无项目无拦截 exit 0
#   - 会话侧：env TASK_PLANNER_SID（zcode-pretooluse 透传）→ 本会话 side 哨兵判定；
#     check-time 仲裁（D10）：ROOT/plans 下任一 task_plan.md（不含 archive 前缀目录）mtime 晚于
#     哨兵 created_epoch → 视为计划已满足放行（毫秒/秒 epoch 均兼容，取不到时间戳按存在即拦，保守）
#   - legacy 降级：无 sid 或 side 未命中时仅查 <ROOT>/.plan-required 固定位置（原 4 级盲搜已删除）
#   - plans/ 目录豁免 + 文件名豁免表原样保留；set -eu 与 exit code 语义（0=放行 1=拦）不变
#
# Usage (from PreToolUse hook):
#   TASK_PLANNER_SID=<sid> check-scope.sh Write "/path/to/file"
#   check-scope.sh Edit "/path/to/file"            （无 sid → legacy 降级）
#
# Exit codes:
#   0 = ALLOWED (无项目根 / 哨兵不存在 / D10 仲裁放行 / 写 plans/ / 豁免文件名)
#   1 = BLOCKED (哨兵存在且判定未满足，写入 plans/ 外非豁免路径)

set -eu

TOOL="${1:-}"
FILE_PATH="${2:-}"

# 无文件路径 → 允许（如某些工具调用不含路径）
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# ─── ① 项目根解析（plans/ 祖先，≤6 级；根除 B2 的 4 级盲搜与跨项目泄漏）────
ROOT=""
_dir="$PWD"
for _ in 1 2 3 4 5 6; do
  if [ -d "$_dir/plans" ]; then
    ROOT="$_dir"
    break
  fi
  [ "$_dir" = "/" ] && break
  _dir="$(dirname "$_dir")"
done
# 无项目根 → 无拦截语义（无 plans/ 项目不产生哨兵）
[ -z "$ROOT" ] && exit 0

# ─── ② 目标路径 abs 化 + plans/ 目录豁免（原样保留，放行优先复用）──────────
abs_path="$(python3 -c "import os,sys; print(os.path.abspath(sys.argv[1]))" "$FILE_PATH" 2>/dev/null || echo "$FILE_PATH")"

# Walk up from abs_path to find plans/ ancestor
_check_dir="$(dirname "$abs_path")"
while [ "$_check_dir" != "/" ] && [ -n "$_check_dir" ]; do
  if [ "$(basename "$_check_dir")" = "plans" ]; then
    # 写入 plans/ 目录 → 允许（创建计划本身）
    exit 0
  fi
  _check_dir="$(dirname "$_check_dir")"
done

# ─── ③ 特殊豁免：init-session.sh 等计划初始化文件（原豁免表保留）────────────
_base="$(basename "$abs_path")"
case "$_base" in
  task_plan.md|findings.md|progress.md|notepad-learnings.md|verification.md)
    exit 0 ;;
  init-session.sh|init-session.ps1|session-catchup.py|session-catchup.ts)
    exit 0 ;;
  check-complete.sh|check-complete.ps1|check-scope.sh|sync-todos.sh)
    exit 0 ;;
  plan-created.cjs|task-plan-init.cjs)
    exit 0 ;;
esac

# ─── ④ 会话 side 哨兵判定（TASK_PLANNER_SID 非空）────────────────────────────
_side_sentinel=""
if [ -n "${TASK_PLANNER_SID:-}" ]; then
  # sidkey 规范：剥非字母数字取前 40，再剥 sess 前缀（对齐 norm_sid / check-dispatch 侧）
  _sidkey="$(printf '%s' "$TASK_PLANNER_SID" | tr -cd 'a-zA-Z0-9' | head -c 40)"
  case "$_sidkey" in
    sess*) _sidkey="${_sidkey#sess}" ;;
  esac
  [ -n "$_sidkey" ] && _side_sentinel="$ROOT/plans/.plan_required_side/$_sidkey.plan_required"
fi

if [ -n "$_side_sentinel" ] && [ -f "$_side_sentinel" ]; then
  # 读取 created_epoch:（D10 check-time 仲裁锚点；兼容秒/毫秒，取不到 → 视为存在即拦，保守）
  _created_epoch=""
  while IFS= read -r _line; do
    case "$_line" in
      created_epoch:*)
        _created_epoch="$(printf '%s' "${_line#created_epoch:}" | tr -d '[:space:]')"
        break ;;
    esac
  done < "$_side_sentinel"

  # D10'（2026-09-10 Code Review P0 修正）：仲裁仅锚定【本会话解析链命中的计划目录】
  # （resolve-plan-dir.sh：side→global→mtime），不再全计划目录扫描——原实现下活跃仓里
  # 任一他会话的新计划都会替本会话解锁哨兵（VC-2 保护回归）。解析未命中 → 存在即拦（保守）。
  if [ -n "$_created_epoch" ]; then
    _skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    _rp="$(bash "$_skill_dir/resolve-plan-dir.sh" "$ROOT" "$_sidkey" 2>/dev/null || true)"
    if [ -n "$_rp" ] && [ -f "$_rp" ]; then
      # created_epoch 兼容毫秒（Date.now()）与秒：≥11 位截前 10 位（GNU date -d @ 只吃秒）
      _case_epoch="$_created_epoch"
      if [ "${#_created_epoch}" -ge 11 ]; then _case_epoch="${_created_epoch:0:10}"; fi
      _ref="/tmp/.plan-guard-ref.$$"
      if touch -d "@$_case_epoch" "$_ref" 2>/dev/null; then
        if [ "$_rp" -nt "$_ref" ]; then
          # 本会话解析命中的计划晚于哨兵创建 → 已满足放行（D10' 会话锚定仲裁）
          rm -f "$_ref"
          exit 0
        fi
        rm -f "$_ref"
      fi
    fi
  fi

  # 未满足 → 拦截
  echo "[PLAN-GUARD] 🚫 本会话计划哨兵未满足 (.plan_required_side active: $(basename "$_side_sentinel"))."
  echo "  Tool: $TOOL"
  echo "  File: $FILE_PATH"
  echo ""
  echo "  Steps to proceed:"
  echo "    1. 创建计划（plans/ 写入豁免）: mkdir -p <ROOT>/plans/task-{id}/ && 填写 task_plan.md"
  echo "       （task_plan.md 存在即 D10 仲裁放行，无需手动清哨兵）"
  echo "    2. 或清除本会话哨兵: node .../skills/task-planner/scripts/plan-created.cjs（调用即清）"
  echo "  Or call: Skill(\"task-planner\")"
  exit 1
fi

# ─── ⑤ legacy 降级（无 sid 或 side 未命中）：仅查 <ROOT>/.plan-required 固定位置 ─
# [2026-09-10 task-planrequired-race] 原"向上 4 级盲搜"已删除；B2 根除后 legacy 只查项目根
if [ -f "$ROOT/.plan-required" ]; then
  echo "[PLAN-GUARD] 🚫 No valid plan exists (.plan-required sentinel active)."
  echo "  Tool: $TOOL"
  echo "  File: $FILE_PATH"
  echo ""
  echo "  Steps to proceed:"
  echo "    1. Create plan: mkdir -p plans/task-{id}/ && cd plans/task-{id}/"
  echo "       && bash ~/.zcode/skills/task-planner/scripts/init-session.sh"
  echo "    2. After plan creation: node ~/.zcode/skills/task-planner/scripts/plan-created.cjs"
  echo "  Or call: Skill(\"task-planner\")"
  exit 1
fi

exit 0
