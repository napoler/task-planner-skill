#!/usr/bin/env bash
# selftest-plan-dispatch.sh — task-v058 P3-S3: check-plan-dispatch.sh + attest-plan.sh 集成自测
# [2026-09-09] T01 合规放行(✓) / T02 缺表(✗) / T03 执行体空 / T04 legacy / T05 无文件 fail-open / T06 attest 集成
# hermetic: 全部夹具写 $TMP, 不触真实 plans/。全 PASS exit 0; 任一 FAIL exit 1。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK="$SCRIPT_DIR/check-plan-dispatch.sh"
ATTEST="$SCRIPT_DIR/attest-plan.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
PASS=0; FAIL=0

assert() {   # <T名> <实际rc> <期望rc> <stdout必含|-> <stderr必含|->
  local name="$1" rc="$2" exp="$3" no="$4" ne="$5" ok=1
  [ "$rc" = "$exp" ] || ok=0
  [ "$no" = "-" ] || printf '%s\n' "$COUT" | grep -qF -- "$no" || ok=0
  [ "$ne" = "-" ] || printf '%s\n' "$CERR" | grep -qF -- "$ne" || ok=0
  if [ "$ok" = 1 ]; then PASS=$((PASS+1)); printf 'T%s PASS %s\n' "$name" "$name"
  else FAIL=$((FAIL+1)); printf 'T%s FAIL %s (rc=%s exp=%s)\n' "$name" "$name" "$rc" "$exp"; fi
}

# ── 夹具 ─────────────────────────────────────────────────────────────────────
for d in ok notable blankexec legacy none attest; do mkdir -p "$TMP/$d"; done
P1="$TMP/ok/task_plan.md"; P2="$TMP/notable/task_plan.md"; P3="$TMP/blankexec/task_plan.md"
P4="$TMP/legacy/task_plan.md"; P5="$TMP/none/task_plan.md"; P6="$TMP/attest/task_plan.md"

# T01 合规: 2 派发型 Phase(Executor=executor(sonnet-1), 7 列 S 表, 执行体=继承) + 1 主进程 Phase(无表)
printf '%s\n' \
'# task_plan' \
'### Phase 1: 实现' \
'**Executor:** executor(sonnet-1)' \
'| ID | 目标 | 执行体 | 输入 | 验收 | 预估 | 状态 |' \
'| S1 | 写 a.sh | 继承 | spec | bash -n | 5min | 待办 |' \
'| S2 | 写 b.sh | 继承 | spec | bash -n | 5min | 待办 |' \
'' \
'### Phase 2: 验证' \
'**Executor:** executor(sonnet-1)' \
'| ID | 目标 | 执行体 | 输入 | 验收 | 预估 | 状态 |' \
'| S1 | 跑自测 | 继承 | 代码 | PASS | 5min | 待办 |' \
'' \
'### Phase 3: 收尾' \
'**Executor:** 主进程' \
'直接收尾,无 S-unit 表' > "$P1"

# T02 缺表: 派发型 Phase 1 无 S-unit 表; Phase 2 合规表(带执行体列)使全文不判 legacy
printf '%s\n' \
'# task_plan' \
'### Phase 1: 实现' \
'**Executor:** executor(sonnet-1)' \
'(无 S-unit 表)' \
'' \
'### Phase 2: 验证' \
'**Executor:** executor(sonnet-1)' \
'| ID | 目标 | 执行体 | 输入 | 验收 | 预估 | 状态 |' \
'| S1 | 跑自测 | 继承 | 代码 | PASS | 5min | 待办 |' > "$P2"

# T03 执行体空: 表头 7 列, S 行执行体列空白
printf '%s\n' \
'# task_plan' \
'### Phase 1: 实现' \
'**Executor:** executor(sonnet-1)' \
'| ID | 目标 | 执行体 | 输入 | 验收 | 预估 | 状态 |' \
'| S1 | 写 a.sh |    | spec | bash -n | 5min | 待办 |' > "$P3"

# T04 legacy: 全文无"执行体"字样
printf '%s\n' \
'# task_plan(旧模板)' \
'### Phase 1: 实现' \
'**Executor:** executor(sonnet-1)' \
'- [ ] 写 a.sh' > "$P4"

# T06 夹具 = T02 目录
cp "$P2" "$P6"

# ── 用例 ─────────────────────────────────────────────────────────────────────
# T01 合规 → exit 0 且 stdout 含 ✓
bash "$CHECK" "$P1" > "$TMP/out" 2> "$TMP/err"; RC=$?
COUT="$(cat "$TMP/out")"; CERR="$(cat "$TMP/err")"; assert 01 "$RC" 0 '✓' -

# T02 缺表 → exit 1 且 stdout 含 ✗
bash "$CHECK" "$P2" > "$TMP/out" 2> "$TMP/err"; RC=$?
COUT="$(cat "$TMP/out")"; CERR="$(cat "$TMP/err")"; assert 02 "$RC" 1 '✗' -

# T03 执行体空 → exit 1 且含 执行体为空
bash "$CHECK" "$P3" > "$TMP/out" 2> "$TMP/err"; RC=$?
COUT="$(cat "$TMP/out")"; CERR="$(cat "$TMP/err")"; assert 03 "$RC" 1 '执行体为空' -

# T04 legacy → exit 0 且含 legacy
bash "$CHECK" "$P4" > "$TMP/out" 2> "$TMP/err"; RC=$?
COUT="$(cat "$TMP/out")"; CERR="$(cat "$TMP/err")"; assert 04 "$RC" 0 'legacy' -

# T05 无文件 → fail-open exit 0
bash "$CHECK" "$P5" > "$TMP/out" 2> "$TMP/err"; RC=$?
COUT="$(cat "$TMP/out")"; CERR="$(cat "$TMP/err")"; assert 05 "$RC" 0 - -

# T06 attest 集成(T02 夹具目录): 正常跑 exit 1; --skip-dispatch-check 锁定成功且 stderr 含 WARN
bash "$ATTEST" "$P6" > "$TMP/out" 2> "$TMP/err"; RC=$?
[ "$RC" = 1 ] || { printf 'T06 FAIL attest 应 exit 1 (rc=%s): %s\n' "$RC" "$COUT"; FAIL=$((FAIL+1)); }
bash "$ATTEST" --skip-dispatch-check "$P6" > "$TMP/out" 2> "$TMP/err"; RC=$?
COUT="$(cat "$TMP/out")"; CERR="$(cat "$TMP/err")"
if [ "$RC" = 0 ] && [ -f "$TMP/attest/.plan-attestation" ] && printf '%s\n' "$CERR" | grep -qF 'WARN'; then
  PASS=$((PASS+1)); printf 'T06 PASS attest 集成\n'
else
  FAIL=$((FAIL+1)); printf 'T06 FAIL attest 集成 (rc=%s, attest=%s): %s | %s\n' \
    "$RC" "$([ -f "$TMP/attest/.plan-attestation" ] && echo yes || echo no)" "$COUT" "$CERR"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
