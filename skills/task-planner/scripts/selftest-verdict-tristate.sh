#!/usr/bin/env bash
# selftest-verdict-tristate — 三态 verdict 必须显式，BLOCKED 不得静默当 PASS
set -uo pipefail
PASS=0; FAIL=0
ok(){ PASS=$((PASS+1)); echo "PASS $1"; }
bad(){ FAIL=$((FAIL+1)); echo "FAIL $1"; }
# TC-01: BLOCKED 未被确认 → 拒绝（负控制）
bash skills/task-planner/scripts/check-verdict.sh /dev/stdin <<'V' >/dev/null 2>&1 && bad TC-01 || ok TC-01
outcome: BLOCKED
confirmed: false
V
# TC-02: BLOCKED 已确认 → 放行
bash skills/task-planner/scripts/check-verdict.sh /dev/stdin <<'V' >/dev/null 2>&1 && ok TC-02 || bad TC-02
outcome: BLOCKED
confirmed: true
V
echo "[selftest-verdict-tristate] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
