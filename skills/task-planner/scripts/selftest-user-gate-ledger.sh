#!/usr/bin/env bash
# selftest-user-gate-ledger — 用户门账本（decisions.blocking/confirmed）终验门禁行为回归
# What: TC-01 blocking:true+confirmed:false 必须拒终验；TC-02 confirmed:true 必须放行；
#       TC-03 存量 decisions 无 blocking/confirmed 字段仍放行（向后兼容）。
# Why: 2026-11-27 Task 6 前，decisions 只是说明性字段，未确认的用户决定可被当 COMPLETE 交付；
#       本测试先于门实现落地，红灯证明门有效（非平凡恒真）。
# 夹具形态: 复用 selftest-evidence-goal-gate.sh EG-22 已证明 rc=0 的最小 standard 计划三件套，
#           只额外注入 plan-state.json（权威源 decisions），把 rc 归因收敛到用户门账本。
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CC="$SCRIPT_DIR/check-complete.sh"
PASS=0; FAIL=0
ok(){ PASS=$((PASS+1)); echo "PASS $1"; }
bad(){ FAIL=$((FAIL+1)); echo "FAIL $1 ${2:-}"; }

T="$(mktemp -d /tmp/selftest-user-gate-ledger.XXXXXX)"
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/task-x"

cat > "$T/task-x/task_plan.md" <<'FAKE_EOF'
# 任务计划（selftest fake plan — 非真实任务）
plan_tier: standard

## 🎯 Goal 单元表

| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit | 状态 |
| --- | --- | --- | --- | --- | --- |
| G1 | 探针 | 验证 | 实跑命令词证据 | S1 | complete |

### Phase 1: 实施
- **Status:** complete
- **Executor:** executor
- **V-N:** VC-1

| ID | 目标 | 执行体 | 输入 | 前置依赖 | 验收 | 预估时长 | 状态 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| S1 | 探针执行 | executor | task_plan.md | - | 证据落盘 | 5min | complete |

## Verification

| ID | 验证项 |
| --- | --- |
| VC-1 | 证据行在案 |

## Handoff

| 子代理类型 | 职责 |
| --- | --- |
| executor | 执行体 |
FAKE_EOF
cat > "$T/task-x/findings.md" <<'FAKE_EOF'
# Findings（selftest fake）
- F1: 探针发现 1
- F2: 探针发现 2
- F3: 探针发现 3
FAKE_EOF
printf '%s\n' '# Progress（selftest fake）' \
  '- 2026-10-15 探针任务启动' \
  '- [goal:G1] 实跑：node x' \
  '- [judge] 评判通过' > "$T/task-x/progress.md"

# $1=mode: unconfirmed|confirmed|legacy|missing（legacy 两字段都不写；missing 只写 blocking）
write_state() {
  python3 - "$T/task-x/plan-state.json" "$1" <<'PY'
import json, sys
path, mode = sys.argv[1], sys.argv[2]
doc = {
    "schema_version": 1, "task_id": "task-x", "plan_tier": "standard",
    "execution_lane": "L1", "created_at": "2026-11-27T00:00:00Z",
    "updated_at": "2026-11-27T00:00:00Z",
    "requirements": [], "goals": [], "vcs": [], "phases": [], "findings": [],
    "audits": [], "delegations": [], "tags": [],
    "decisions": [{"id": "D1", "decision": "等待用户裁决", "rationale": "终验前须确认"}],
}
if mode in ("unconfirmed", "confirmed", "missing"):
    doc["decisions"][0]["blocking"] = True
    if mode in ("unconfirmed", "confirmed"):
        doc["decisions"][0]["confirmed"] = (mode == "confirmed")
with open(path, "w", encoding="utf-8") as f:
    json.dump(doc, f, ensure_ascii=False)
PY
}

# 夹具非 git 仓，git-baseline 门恒 FAIL（与用户门无关）；按 selftest-git-baseline T5c 既有档位
# 用 env TASK_PLANNER_GIT_BASELINE_ENFORCE=off 只让该门 SKIP，把 rc 归因收敛到用户门账本。
# TC-01 负控制：blocking:true + confirmed:false → 拒终验（rc=1 + 用户门 FAIL 锚）
write_state unconfirmed
out="$(env TASK_PLANNER_GIT_BASELINE_ENFORCE=off bash "$CC" "$T/task-x/task_plan.md" 2>&1)"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -qF '[user-gate] FAIL'; then
  ok TC-01 "blocking 未确认拒终验 rc=1"
else
  bad TC-01 "blocking 未确认未拒: rc=$rc out=$(printf '%s\n' "$out" | tail -6 | tr '\n' ';')"
fi

# TC-02 正例：blocking:true + confirmed:true → 放行（rc=0，且门不得报 FAIL）
write_state confirmed
out="$(env TASK_PLANNER_GIT_BASELINE_ENFORCE=off bash "$CC" "$T/task-x/task_plan.md" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && ! printf '%s\n' "$out" | grep -qF '[user-gate] FAIL'; then
  ok TC-02 "blocking 已确认放行 rc=0"
else
  bad TC-02 "blocking 已确认未放行: rc=$rc out=$(printf '%s\n' "$out" | tail -6 | tr '\n' ';')"
fi

# TC-03 存量兼容：decisions 无新字段 → 放行（不得破坏旧计划）
write_state legacy
out="$(env TASK_PLANNER_GIT_BASELINE_ENFORCE=off bash "$CC" "$T/task-x/task_plan.md" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && ! printf '%s\n' "$out" | grep -qF '[user-gate] FAIL'; then
  ok TC-03 "存量 decisions 无 blocking 字段 rc=0"
else
  bad TC-03 "存量 decisions 被新门误拒: rc=$rc out=$(printf '%s\n' "$out" | tail -6 | tr '\n' ';')"
fi

# TC-04 边界：blocking:true 但 confirmed 字段缺省 → 按未确认拒（可选字段缺省 false，不得静默放行）
write_state missing
out="$(env TASK_PLANNER_GIT_BASELINE_ENFORCE=off bash "$CC" "$T/task-x/task_plan.md" 2>&1)"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -qF '[user-gate] FAIL'; then
  ok TC-04 "blocking:true + confirmed 缺省拒终验 rc=1"
else
  bad TC-04 "blocking 缺 confirmed 未被拒: rc=$rc out=$(printf '%s\n' "$out" | tail -6 | tr '\n' ';')"
fi

echo "[selftest-user-gate-ledger] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
