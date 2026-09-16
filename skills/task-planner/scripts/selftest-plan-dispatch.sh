#!/usr/bin/env bash
# selftest-plan-dispatch.sh — task-v058 P3-S3: check-plan-dispatch.sh + attest-plan.sh 集成自测
# [2026-09-09] T01 合规放行(✓) / T02 缺表(✗) / T03 执行体空 / T04 legacy / T05 无文件 fail-open / T06 attest 集成
# [2026-09-13 task-v065 S-1 F-2] 补 T07 有 `- **Executor:**` 行但缺 S-unit 表(修复前被 legacy 判定键误放行) / T08 完全无 Executor 行的 legacy 计划
# [2026-09-16 task-v075 P2-S2] 补 T09-S12 S-unit 数值门控用例(hermetic 夹具): T09 时长超限(16min>step_max_minutes=15)拒绝
# / T10 输入列 3 路径(>step_max_files=2)拒绝 / T11 空时长行 SKIPPED 显式化放行 / T12 全合规数值行通过
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
for d in ok notable blankexec legacy none attest notable2 noexec overmin overin1 emptydur allgood; do mkdir -p "$TMP/$d"; done
P1="$TMP/ok/task_plan.md"; P2="$TMP/notable/task_plan.md"; P3="$TMP/blankexec/task_plan.md"
P4="$TMP/legacy/task_plan.md"; P5="$TMP/none/task_plan.md"; P6="$TMP/attest/task_plan.md"
P7="$TMP/notable2/task_plan.md"; P8="$TMP/noexec/task_plan.md"
P9="$TMP/overmin/task_plan.md"; P10="$TMP/overin1/task_plan.md"
P11="$TMP/emptydur/task_plan.md"; P12="$TMP/allgood/task_plan.md"

# T01 合规: 2 派发型 Phase(Executor=executor(sonnet-1), 7 列 S 表, 执行体=继承) + 1 主进程 Phase(无表)
# [2026-09-13 task-v065 S-1 F-2] 夹具 Executor 行补 `- ` 前缀 = canonical 模板格式
#   (templates/task_plan.md:144 `- **Executor:** explore（mini）`)。裸 `**Executor:**`(无前缀)
#   按新判定键计 legacy → T01/T02/T03/T06 会整体失覆盖，故统一为模板格式。
printf '%s\n' \
'# task_plan' \
'### Phase 1: 实现' \
'- **Executor:** executor(sonnet-1)' \
'| ID | 目标 | 执行体 | 输入 | 验收 | 预估 | 状态 |' \
'| S1 | 写 a.sh | 继承 | spec | bash -n | 5min | 待办 |' \
'| S2 | 写 b.sh | 继承 | spec | bash -n | 5min | 待办 |' \
'' \
'### Phase 2: 验证' \
'- **Executor:** executor(sonnet-1)' \
'| ID | 目标 | 执行体 | 输入 | 验收 | 预估 | 状态 |' \
'| S1 | 跑自测 | 继承 | 代码 | PASS | 5min | 待办 |' \
'' \
'### Phase 3: 收尾' \
'- **Executor:** 主进程' \
'直接收尾,无 S-unit 表' > "$P1"

# T02 缺表: 派发型 Phase 1 无 S-unit 表; Phase 2 合规表(带执行体列)
printf '%s\n' \
'# task_plan' \
'### Phase 1: 实现' \
'- **Executor:** executor(sonnet-1)' \
'(无 S-unit 表)' \
'' \
'### Phase 2: 验证' \
'- **Executor:** executor(sonnet-1)' \
'| ID | 目标 | 执行体 | 输入 | 验收 | 预估 | 状态 |' \
'| S1 | 跑自测 | 继承 | 代码 | PASS | 5min | 待办 |' > "$P2"

# T03 执行体空: 表头 7 列, S 行执行体列空白
printf '%s\n' \
'# task_plan' \
'### Phase 1: 实现' \
'- **Executor:** executor(sonnet-1)' \
'| ID | 目标 | 执行体 | 输入 | 验收 | 预估 | 状态 |' \
'| S1 | 写 a.sh |    | spec | bash -n | 5min | 待办 |' > "$P3"

# T04 legacy: 裸 `**Executor:**`(无 `- ` 前缀) → 不命中判定键 → 跳过门控
printf '%s\n' \
'# task_plan(旧模板)' \
'### Phase 1: 实现' \
'**Executor:** executor(sonnet-1)' \
'- [ ] 写 a.sh' > "$P4"

# T06 夹具 = T02 目录
cp "$P2" "$P6"

# T07 夹具(F-2 回归): 有 `- **Executor:**` 行 + 整份计划无 S-unit 表 → 修复前被 legacy 误放行
printf '%s\n' \
'# task_plan' \
'### Phase 1: 实现' \
'- **Executor:** executor(sonnet-1)' \
'- [ ] 写 a.sh(无 S-unit 表)' > "$P7"

# T08 夹具(F-2 回归): 完全无 Executor 行的旧模板 → legacy 放行
printf '%s\n' \
'# task_plan(无 Executor 字段的旧模板)' \
'### Phase 1: 实现' \
'- [ ] 写 a.sh' > "$P8"

# T09 夹具 [task-v075 P2-S2] 时长超限: S1 预估时长 16min > step_max_minutes(15) → 拒绝
printf '%s\n' \
'# task_plan' \
'### Phase 1: 实现' \
'- **Executor:** executor(sonnet-1)' \
'| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 状态 |' \
'| S1 | 写 a.sh | 继承 | a/b.sh | bash -n | 16min | 待办 |' > "$P9"

# T10 夹具 [task-v075 P2-S2] 输入列 3 路径 > step_max_files(2) → 拒绝
printf '%s\n' \
'# task_plan' \
'### Phase 1: 实现' \
'- **Executor:** executor(sonnet-1)' \
'| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 状态 |' \
'| S1 | 写 a.sh | 继承 | p1/a.sh p2/b.sh p3/c.sh | bash -n | 5min | 待办 |' > "$P10"

# T11 夹具 [task-v075 P2-S2] 空时长行: 预估时长列为空 → SKIPPED 显式化, 不阻断
printf '%s\n' \
'# task_plan' \
'### Phase 1: 实现' \
'- **Executor:** executor(sonnet-1)' \
'| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 状态 |' \
'| S1 | 写 a.sh | 继承 | a/b.sh | bash -n |  | 待办 |' > "$P11"

# T12 夹具 [task-v075 P2-S2] 全合规数值行: 2 路径 ≤2 + 12min ≤15 → 通过
printf '%s\n' \
'# task_plan' \
'### Phase 1: 实现' \
'- **Executor:** executor(sonnet-1)' \
'| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 状态 |' \
'| S1 | 写 a.sh | 继承 | a/b.sh a2/b.md | bash -n | 12min | 待办 |' > "$P12"

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

# T07 [F-2] 有 `- **Executor:**` 行但无 S-unit 表 → exit 1(修复前 legacy 判定键误放行 exit 0)
bash "$CHECK" "$P7" > "$TMP/out" 2> "$TMP/err"; RC=$?
COUT="$(cat "$TMP/out")"; CERR="$(cat "$TMP/err")"; assert 07 "$RC" 1 '✗' -

# T08 [F-2] 完全无 Executor 行的旧模板 → legacy 放行 exit 0
bash "$CHECK" "$P8" > "$TMP/out" 2> "$TMP/err"; RC=$?
COUT="$(cat "$TMP/out")"; CERR="$(cat "$TMP/err")"; assert 08 "$RC" 0 'legacy' -

# T09 [task-v075 P11] 时长 16min > step_max_minutes(15) → 提示不阻断: exit 0 且含「提示不阻断」
bash "$CHECK" "$P9" > "$TMP/out" 2> "$TMP/err"; RC=$?
COUT="$(cat "$TMP/out")"; CERR="$(cat "$TMP/err")"; assert 09 "$RC" 0 '提示不阻断' -

# T10 [task-v075 P11] 输入列 3 路径 > step_max_files(2) → 提示不阻断: exit 0 且含「建议拆分」
bash "$CHECK" "$P10" > "$TMP/out" 2> "$TMP/err"; RC=$?
COUT="$(cat "$TMP/out")"; CERR="$(cat "$TMP/err")"; assert 10 "$RC" 0 '建议拆分' -

# T11 [task-v075] 空时长行 → SKIPPED 显式化放行 exit 0 且 stdout 含 SKIPPED
bash "$CHECK" "$P11" > "$TMP/out" 2> "$TMP/err"; RC=$?
COUT="$(cat "$TMP/out")"; CERR="$(cat "$TMP/err")"; assert 11 "$RC" 0 'SKIPPED' -

# T12 [task-v075] 全合规数值行(2 路径 + 12min) → exit 0 且含 ✓
bash "$CHECK" "$P12" > "$TMP/out" 2> "$TMP/err"; RC=$?
COUT="$(cat "$TMP/out")"; CERR="$(cat "$TMP/err")"; assert 12 "$RC" 0 '✓' -

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
