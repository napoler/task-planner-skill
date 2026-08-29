#!/usr/bin/env bash
# check-scope.sh — PreToolUse guard: verify Write/Edit against .plan-required sentinel
#
# 哨兵机制：
#   - SessionStart 时 task-plan-init.cjs 写入 .plan-required
#   - Agent 创建有效计划后调用 plan-created.cjs 清除哨兵
#   - 哨兵存在时，禁止向非 plans/ 路径写入
#
# Usage (from PreToolUse hook):
#   check-scope.sh Write "/path/to/file"
#   check-scope.sh Edit "/path/to/file"
#
# Exit codes:
#   0 = ALLOWED (sentinel absent OR writing to plans/)
#   1 = BLOCKED (sentinel present, writing outside plans/)

set -eu

TOOL="${1:-}"
FILE_PATH="${2:-}"

# 无文件路径 → 允许（如某些工具调用不含路径）
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# ─── ① 查找哨兵 ──────────────────────────────────────────────────────────────
_sentinel=""
_search="$PWD"
for _ in 1 2 3 4; do
  if [ -f "$_search/.plan-required" ]; then
    _sentinel="$_search"
    break
  fi
  _search="$(dirname "$_search")"
done

# 无哨兵 → 放行（计划已被清除或本次会话未触发 SessionStart）
if [ -z "$_sentinel" ]; then
  exit 0
fi

# ─── ② 检查目标路径是否在 plans/ 目录下 ─────────────────────────────────────
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

# ─── ③ 特殊豁免：init-session.sh 等计划初始化文件 ──────────────────────────
_base="$(basename "$abs_path")"
case "$_base" in
  task_plan.md|findings.md|progress.md|notepad-learnings.md|verification.md)
    # 允许写入这些文件名（可能在任意位置被临时创建，但最终会移到 plans/）
    ;;
  init-session.sh|init-session.ps1|session-catchup.py|session-catchup.ts)
    ;;
  check-complete.sh|check-complete.ps1|check-scope.sh|sync-todos.sh)
    ;;
  plan-created.cjs|task-plan-init.cjs)
    ;;
  *)
    # 非豁免文件 + 哨兵存在 → 阻断
    echo "[PLAN-GUARD] 🚫 No valid plan exists (.plan-required sentinel active)."
    echo "  Tool: $TOOL"
    echo "  File: $FILE_PATH"
    echo ""
    echo "  Steps to proceed:"
    echo "    1. Create plan: mkdir -p plans/task-{id}/ && cd plans/task-{id}/"
    echo "       && bash ~/.claude/skills/task-planner/scripts/init-session.sh"
    echo "    2. After plan creation: node ~/.claude/skills/task-planner/scripts/plan-created.cjs"
    echo "  Or call: Skill(\"task-planner\")"
    exit 1
    ;;
esac

exit 0
