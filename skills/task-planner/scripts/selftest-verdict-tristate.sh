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
# TC-03/TC-04（2026-11-27 终审 P0 判别性对照）：模板字面行 `outcome: COMPLETE / PARTIAL / BLOCKED`
# 必须先被跳过，真实末条 outcome=BLOCKED 才生效；否则 TC-03 会像修复前那样假绿 rc0。
# Why：仅靠 TC-01/TC-02 无法暴露"取首个 outcome"的缺陷——夹具里没有模板干扰行。
# What：同一夹具只翻转 confirmed，分别显式断言 rc==1 / rc==0 且输出含 BLOCKED（禁用 &&/|| 吞码）。
V3="$(mktemp "${TMPDIR:-/tmp}/verdict-tc3-XXXXXX")"
V4="$(mktemp "${TMPDIR:-/tmp}/verdict-tc4-XXXXXX")"
trap 'rm -f "$V3" "$V4"' EXIT
cat > "$V3" <<'V'
outcome: COMPLETE / PARTIAL / BLOCKED
outcome: BLOCKED
confirmed: false
V
cat > "$V4" <<'V'
outcome: COMPLETE / PARTIAL / BLOCKED
outcome: BLOCKED
confirmed: true
V
out="$(bash skills/task-planner/scripts/check-verdict.sh "$V3" 2>&1)"; rc=$?
if [ "$rc" -eq 1 ]; then ok TC-03; else bad TC-03; fi
out="$(bash skills/task-planner/scripts/check-verdict.sh "$V4" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -q 'BLOCKED'; then ok TC-04; else bad TC-04; fi
echo "[selftest-verdict-tristate] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
