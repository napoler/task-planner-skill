#!/usr/bin/env bash
# [2026-08-27] zcode-sessionstart.sh — ZCode SessionStart 适配器（task-planner 哨兵机制）
# 运行 task-plan-init.cjs 写入 .plan-required 哨兵；ZCode 对 hook stdout 做严格 JSON 校验，
# 纯文本输出会被判失败，故将脚本文本包装为 {"additionalContext": ...} 注入会话。
# 永远 exit 0（fail-open）：哨兵写入失败也不阻塞会话。
out="$(node "${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/task-plan-init.cjs" 2>/dev/null)"
rc=$?

# [2026-08-28] 未完成任务恢复提醒:读 CWD/plans/INDEX.md 待处理区,有欠账则追加 [task-resume] 段
# (每会话仅此一次;仅提示,未经用户确认不得自动拉起执行——防新会话意图被旧任务劫持)
idx="$PWD/plans/INDEX.md"
if [ -f "$idx" ]; then
  pending="$(sed -n '/^## 待处理/,/^## 已完成/p' "$idx" | grep -E '^- \*\*' | head -3)"
  if [ -n "$pending" ]; then
    n="$(printf '%s\n' "$pending" | grep -c '^- \*\*')"
    out="${out}
[task-resume] 📋 检测到 ${n} 个未完成任务(plans/INDEX.md 待处理区):
${pending}
开场时向用户提议是否继续;未经用户确认勿自动执行。"
  fi
fi

if [ "$rc" -eq 0 ] && [ -n "$out" ]; then
  printf '{"additionalContext": %s}\n' "$(printf '%s' "$out" | jq -Rs .)"
fi
exit 0
