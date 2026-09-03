#!/usr/bin/env bash
# [2026-08-27] zcode-pretooluse.sh — ZCode PreToolUse 适配器(task-planner)
# 职责:
#   1. 哨兵期:检查 Write/Edit 是否在 plans/ 外(原有功能)
#   2. 运行时并发检测(Rule 23):写入文件是否命中其他 in_progress plan 的 scope
# 约束:fail-open —— 任何异常 exit 0 不阻塞指令
input="$(cat)"
tool="$(printf '%s' "$input" | jq -r '.tool_name // .toolName // empty' 2>/dev/null)"
file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.filePath // .tool_input.path // empty' 2>/dev/null)"
SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 原有哨兵检查
bash "$SKILL_ROOT/check-scope.sh" "$tool" "$file"
rc=$?
if [ "$rc" -eq 1 ]; then
  echo 'task-planner: 检测到 .plan-required 哨兵——本会话尚无有效计划，禁止写入 plans/ 之外路径。请先调用 Skill(skill="task-planner") 创建计划。' >&2
  exit 2
fi

# Rule 23: 运行时并发冲突检测(仅 Write/Edit)
if [ "$tool" = "Write" ] || [ "$tool" = "Edit" ]; then
  # 探测活跃 plan
  plan=""
  CWD="${PWD}"
  if [ -d "$CWD/plans" ]; then
    plan="$(ls -t "$CWD"/plans/*/task_plan.md 2>/dev/null | head -1)"
  fi
  [ -z "$plan" ] && [ -f "$CWD/task_plan.md" ] && plan="$CWD/task_plan.md"
  
  if [ -n "$plan" ]; then
    plan_dir="$(dirname "$plan")"
    current_scope="$(awk '/^## .*执行范围限制/,/^## /' "$plan" 2>/dev/null | grep '^|' | grep -v '^|---' | awk -F'|' '{for(i=3;i<=NF;i++) if($i ~ /\\.[a-zA-Z]/) printf "%s\n", $i}' | tr -d ' ')"
    # 检查写入文件是否在其他 plan 的 scope 中
    for other_plan in $(ls -t "$CWD/plans"/*/task_plan.md 2>/dev/null); do
      [ "$other_plan" = "$plan" ] && continue
      other_dir="$(dirname "$other_plan")"
      other_scope="$(awk '/^## .*执行范围限制/,/^## /' "$other_plan" 2>/dev/null | grep '^|' | grep -v '^|---' | awk -F'|' '{for(i=3;i<=NF;i++) if($i ~ /\\.[a-zA-Z]/) printf "%s\n", $i}' | tr -d ' ')"
      # 简单字符串匹配(file 在 other_scope 中)
      if echo "$other_scope" | grep -qF "$(basename "$file")"; then
        other_taskid="$(basename "$other_dir")"
        other_session="$(awk '/^session_id:/{print $2; exit}' "$other_plan" 2>/dev/null || echo 'unknown')"
        printf '{"additionalContext": %s}\n' "$(printf '[conflict] 文件 %s 可能与其他 plan(%s, session=%s)冲突,请确认 scope' "$file" "$other_taskid" "$other_session" | jq -Rs .)"
        break
      fi
    done
  fi
fi
exit 0
