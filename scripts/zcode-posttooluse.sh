#!/usr/bin/env bash
# [2026-08-28] zcode-posttooluse.sh — PostToolUse 周期强制同步 hook（task-planner）
# 职责（对应「强制定期更新计划文件 + 原生 Todo 主动同步」）：
#   1. 按会话统计工具调用次数（状态文件 /tmp/task-planner-hook-<sid>.state）
#   2. 探测活跃计划：CWD/plans/*/task_plan.md 中 mtime 最新者（>24h 未更新视为历史遗留，静默）
#   0. 已完结计划（task_plan.md 含 outcome: COMPLETE/BLOCKED）→ 直接静默（防误报）
#   3. 计划文档超龄（config#plan_update_interval_minutes，默认 15 分钟）且不在冷却期 → 注入强制回写提醒，
#      随后进入 config#stale_remind_cooldown_calls（默认 10 次调用）冷却，防止未修复时每次调用重复轰炸
#   4. 计数达到 config#todo_sync_interval_calls（默认 10）→ 注入轻量 Todo 同步提醒，计数清零
# 约束：fail-open —— 任何异常一律 exit 0 不阻塞工具调用；
#       ZCode 对 hook stdout 做严格 JSON 校验，有提醒时包装为 {"additionalContext": ...}（与
#       zcode-sessionstart.sh 同一约定），无提醒时输出空。

input="$(cat)"

CWD="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
CWD="${CWD:-$PWD}"
SID="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null | tr -cd 'a-zA-Z0-9' | head -c 40)"
SID="${SID:-default}"

# ─── 探测活跃计划（无则零开销静默退出）───────────────────────────────────────
plan=""
if [ -d "$CWD/plans" ]; then
  plan="$(ls -t "$CWD"/plans/*/task_plan.md 2>/dev/null | head -1)"
fi
[ -z "$plan" ] && exit 0

now="$(date +%s)"
mt="$(stat -c %Y "$plan" 2>/dev/null || echo "$now")"
age=$(( now - mt ))
[ "$age" -gt 86400 ] && exit 0   # >24h 未更新 = 历史任务，不打扰

# ─── 完结计划静默（[2026-08-28] 防误报:outcome 已定局的任务不再催）────────────
if grep -qiE 'outcome: *(COMPLETE|BLOCKED)' "$plan" 2>/dev/null; then
  exit 0
fi

# ─── 读阈值（config.json；解析失败兜底默认值，保证 fail-open）────────────────
SKILL_ROOT="${OPENCODE_SKILL_ROOT:-$HOME/.zcode/skills/task-planner}"
todo_n="$(jq -r '.properties.todo_sync_interval_calls.default // 10' "$SKILL_ROOT/config.json" 2>/dev/null || true)"
plan_min="$(jq -r '.properties.plan_update_interval_minutes.default // 15' "$SKILL_ROOT/config.json" 2>/dev/null || true)"
cooldown="$(jq -r '.properties.stale_remind_cooldown_calls.default // 10' "$SKILL_ROOT/config.json" 2>/dev/null || true)"
case "$todo_n" in ''|*[!0-9]*) todo_n=10 ;; esac
case "$plan_min" in ''|*[!0-9]*) plan_min=15 ;; esac
case "$cooldown" in ''|*[!0-9]*) cooldown=10 ;; esac

# ─── 会话级计数 + 冷却（状态格式: <count> <epoch> <cooldown_left>）───────────
state="/tmp/task-planner-hook-${SID}.state"
count="$(cut -d' ' -f1 "$state" 2>/dev/null || true)"
cd_left="$(cut -d' ' -f3 "$state" 2>/dev/null || true)"
case "$count" in ''|*[!0-9]*) count=0 ;; esac
case "$cd_left" in ''|*[!0-9]*) cd_left=0 ;; esac
count=$(( count + 1 ))
[ "$cd_left" -gt 0 ] && cd_left=$(( cd_left - 1 ))

emit() {
  printf '{"additionalContext": %s}\n' "$(printf '%s' "$1" | jq -Rs .)"
}

# ─── 优先级 1：计划文档陈旧且不在冷却期 → 强制回写，随后进入冷却 ─────────────
age_min=$(( age / 60 ))
if [ "$age" -ge "$(( plan_min * 60 ))" ] && [ "$cd_left" -eq 0 ]; then
  echo "0 $(date +%s) $cooldown" > "$state"
  emit "[plan-sync] ⏰ 计划文档已 ${age_min} 分钟未更新（阈值 ${plan_min} 分钟）: ${plan}
强制动作（references/todo-sync.md §4 响应协议，三步立即执行）:
1. Edit task_plan.md 回写进度（当前 Phase checkbox/Status/Errors 表）
2. TodoWrite / TaskUpdate 同步原生 Todo 状态
3. bash ${SKILL_ROOT}/scripts/sync-todos.sh --index 刷新 INDEX.md"
  exit 0
fi

# ─── 优先级 2：调用次数达阈值 → 轻量 Todo 同步提醒 ───────────────────────────
if [ "$count" -ge "$todo_n" ]; then
  echo "0 $(date +%s) $cd_left" > "$state"
  emit "[plan-sync] 🔄 已 ${count} 次工具调用未同步：核对 ${plan} 的 Phase 状态，并用 TodoWrite/TaskUpdate 同步原生 Todo（S2/S3）。"
  exit 0
fi

echo "$count $(date +%s) $cd_left" > "$state"
exit 0
