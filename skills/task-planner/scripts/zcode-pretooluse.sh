#!/usr/bin/env bash
# [2026-08-27] zcode-pretooluse.sh — ZCode PreToolUse 适配器（task-planner 哨兵机制）
# ZCode hook 通过 stdin 传 JSON；本脚本提取 tool_name/file_path 后调用 check-scope.sh，
# 并翻译退出码：check-scope 1(拦截) → ZCode deny 码 2；其余一律放行（fail-open，防止守卫故障阻塞写入）。
input="$(cat)"
tool="$(printf '%s' "$input" | jq -r '.tool_name // .toolName // empty' 2>/dev/null)"
file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.filePath // .tool_input.path // empty' 2>/dev/null)"
bash "/home/terry/.zcode/skills/task-planner/scripts/check-scope.sh" "$tool" "$file"
rc=$?
if [ "$rc" -eq 1 ]; then
  echo 'task-planner: 检测到 .plan-required 哨兵——本会话尚无有效计划，禁止写入 plans/ 之外路径。请先调用 Skill(skill="task-planner") 创建计划。' >&2
  exit 2
fi
exit 0
