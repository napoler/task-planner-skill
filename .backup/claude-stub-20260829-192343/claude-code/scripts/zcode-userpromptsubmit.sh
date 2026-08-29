#!/usr/bin/env bash
# [2026-08-28] zcode-userpromptsubmit.sh — UserPromptSubmit 提醒 hook（task-planner 新指令计划影响判定）
# 职责：用户每条指令到达时，若存在活跃计划（CWD/plans/*/task_plan.md，>24h 未更新视为历史遗留），
#       注入一行 [plan-note] 提醒：先做 A/B/C 影响判定（无影响/扩展/矛盾），
#       B/C 类必须先更新 task_plan.md 对应 Phase/VC/范围 + 同步原生 Todo（S5），再执行。
# [2026-08-28] 节流与完结静默:每会话第 1 条注入,之后每 prompt_note_interval(默认 10)条一次;
#             已完结计划(outcome COMPLETE/BLOCKED)不再提醒——防 token 无效消耗。
# 约束：fail-open —— 任何异常 exit 0 不阻塞指令；无活跃计划时零输出。
#       ZCode 对 hook stdout 做严格 JSON 校验，有提醒时包装为 {"additionalContext": ...}。
#       注意：不回显用户 prompt 内容（可能超长/敏感），只注入固定判定规则。

input="$(cat)"

CWD="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
CWD="${CWD:-$PWD}"

# ─── 探测活跃计划（无则零开销静默退出）───────────────────────────────────────
plan=""
if [ -d "$CWD/plans" ]; then
  plan="$(ls -t "$CWD"/plans/*/task_plan.md 2>/dev/null | head -1)"
fi
[ -z "$plan" ] && exit 0

now="$(date +%s)"
mt="$(stat -c %Y "$plan" 2>/dev/null || echo "$now")"
[ $(( now - mt )) -gt 86400 ] && exit 0

# ─── 完结计划静默（防误报）───────────────────────────────────────────────────
grep -qiE 'outcome: *(COMPLETE|BLOCKED)' "$plan" 2>/dev/null && exit 0

# ─── 会话级节流：第 1 条注入，之后每 prompt_note_interval(默认 10)条一次 ─────
SKILL_ROOT="${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}"
interval="$(jq -r '.properties.prompt_note_interval.default // 10' "$SKILL_ROOT/config.json" 2>/dev/null || true)"
case "$interval" in ''|*[!0-9]*|0) interval=10 ;; esac
UPS_SID="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null | tr -cd 'a-zA-Z0-9' | head -c 40)"
UPS_SID="${UPS_SID:-default}"
ups_state="/tmp/task-planner-ups-${UPS_SID}.state"
n="$(cat "$ups_state" 2>/dev/null || true)"
case "$n" in ''|*[!0-9]*) n=0 ;; esac
n=$(( n + 1 ))
echo "$n" > "$ups_state"
[ "$n" -eq 1 ] || [ $(( n % interval )) -eq 0 ] || exit 0

msg="[plan-note] 新指令到达（活跃计划: ${plan}）——执行前先做影响判定: A 无影响→照常执行; B 扩展/C 矛盾→必须先 Edit task_plan.md 更新对应 Phase/VC/执行范围 + 同步原生 Todo(S5,references/todo-sync.md),复述变更后再执行。禁止口头接受不落盘。"
printf '{"additionalContext": %s}\n' "$(printf '%s' "$msg" | jq -Rs .)"
exit 0
