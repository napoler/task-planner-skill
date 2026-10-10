#!/usr/bin/env bash
# S6 hook 实弹冒烟 — task-v152（code-runner-agent）
# 复用 selftest-drift-enforcement.sh DCE-16/DCE-22 的 fixture 构造法：
#   plans/.drift-rhythm/<sid>.state 置 count 10 / last_inject 0 → 本轮 due=1
#   plans/.active_plan_side/<sid>.active_plan 指针 + 三件套新鲜计划文件（避开优先级 1-3）
#   主计数 /tmp/task-planner-hook-<sid>.state 清零（避开优先级 4，确保走到 end-emit）
# 断言：
#   run1 默认 env → stdout 恰好 1 行合法 JSON，.additionalContext 含 [drift-rhythm] + [context-pressure]
#   run2 TASK_PLANNER_CONTEXT_PRESSURE=off → 含 [drift-rhythm]，不含 [context-pressure]
set -u
WT=/mnt/data/dev/task-planner-skill-worktrees/v152-proactive-context/skills/task-planner
HOOK="$WT/scripts/zcode-posttooluse.sh"
OUTDIR=/mnt/data/dev/task-planner-skill/plans/task-v152-proactive-context/subagent-state
SID="s6smoke$$"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"; rm -f "/tmp/task-planner-hook-${SID}.state"' EXIT

mkdir -p "$TMP/plans/.drift-rhythm" "$TMP/plans/.active_plan_side" "$TMP/plans/smoke-plan"
printf 'smoke-plan\n' > "$TMP/plans/.active_plan_side/${SID}.active_plan"
printf '### Phase 2: test\n- **Status:** in_progress\n' > "$TMP/plans/smoke-plan/task_plan.md"
printf '## Phase 2: test\n- **Started:** %s\n' "$(date -d '-1 hour' '+%Y-%m-%d %H:%M')" > "$TMP/plans/smoke-plan/progress.md"
printf '# Findings\n' > "$TMP/plans/smoke-plan/findings.md"
touch "$TMP/plans/smoke-plan/task_plan.md" "$TMP/plans/smoke-plan/progress.md" "$TMP/plans/smoke-plan/findings.md"

# ── run1: 默认 env ──
rm -f "/tmp/task-planner-hook-${SID}.state"
printf 'count 10\nlast_inject 0\n' > "$TMP/plans/.drift-rhythm/${SID}.state"
OUT1="$(printf '{"cwd":"%s","session_id":"%s"}\n' "$TMP" "$SID" | bash "$HOOK" 2>/dev/null)"
printf '%s\n' "$OUT1" > "$OUTDIR/7-code-runner-S6-run1.out"
L1="$(printf '%s' "$OUT1" | grep -c '' || true)"
V1=0; printf '%s' "$OUT1" | jq -e . >/dev/null 2>&1 && V1=1
AC1="$(printf '%s' "$OUT1" | jq -r .additionalContext 2>/dev/null)"
HAS_R1=0; printf '%s' "$AC1" | grep -q '\[drift-rhythm\]' && HAS_R1=1
HAS_C1=0; printf '%s' "$AC1" | grep -q '\[context-pressure\]' && HAS_C1=1

# ── run2: TASK_PLANNER_CONTEXT_PRESSURE=off（重置 fixture 至与 run1 同初态，模拟下一次节奏触发轮）──
rm -f "/tmp/task-planner-hook-${SID}.state"
printf 'count 10\nlast_inject 0\n' > "$TMP/plans/.drift-rhythm/${SID}.state"
OUT2="$(printf '{"cwd":"%s","session_id":"%s"}\n' "$TMP" "$SID" | TASK_PLANNER_CONTEXT_PRESSURE=off bash "$HOOK" 2>/dev/null)"
printf '%s\n' "$OUT2" > "$OUTDIR/7-code-runner-S6-run2.out"
L2="$(printf '%s' "$OUT2" | grep -c '' || true)"
V2=0; printf '%s' "$OUT2" | jq -e . >/dev/null 2>&1 && V2=1
AC2="$(printf '%s' "$OUT2" | jq -r .additionalContext 2>/dev/null)"
HAS_R2=0; printf '%s' "$AC2" | grep -q '\[drift-rhythm\]' && HAS_R2=1
HAS_C2=0; printf '%s' "$AC2" | grep -q '\[context-pressure\]' && HAS_C2=1

echo "SID=$SID"
echo "run1: lines=$L1 json_valid=$V1 has_drift_rhythm=$HAS_R1 has_context_pressure=$HAS_C1"
echo "run2: lines=$L2 json_valid=$V2 has_drift_rhythm=$HAS_R2 has_context_pressure=$HAS_C2"
if [ "$L1" -eq 1 ] && [ "$V1" -eq 1 ] && [ "$HAS_R1" -eq 1 ] && [ "$HAS_C1" -eq 1 ] \
   && [ "$HAS_R2" -eq 1 ] && [ "$HAS_C2" -eq 0 ]; then
  echo "SMOKE RESULT: PASS"
  exit 0
else
  echo "SMOKE RESULT: FAIL"
  exit 1
fi
