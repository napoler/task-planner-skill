#!/usr/bin/env bash
# [2026-11-17 task-auditgate-machine-20261116] selftest-plan-audit-gate.sh — 计划审计门自测（CA-9, Rule 57/84 迭代留痕纪律）
# 覆盖: checker（check-plan-audit-gate.sh）静态/行为断言 16 项 + attest [audit-gate] 接线行为断言（enforce 拒锁不写锁/放行写锁/缓存隔离）
# 权威用例清单: plans/task-auditgate-machine-20261116/verification.md VC-3（R7/R8 增补 r5/r6/r7/legacy SKIP/中间态/fixture a b）; 规格=findings.md D3。
# fixture 纪律（kb §4-64）: 全部 /tmp（mktemp+trap 清理）; 正负例独立 task_plan 内容; attest 用例每例前清 /tmp/attest-cache-*（缓存隔离）。
# attest 用例注: fixture 走真门链需过 51.1 四锚（requirement-gate 无逃生）——fixture task_plan 内建四锚最小合规体;
#   其余门（dispatch/template/fmea/goal/vc）以既有 --skip-* 旗标跳过（本 selftest 只证审计门交互, 披露于此）;
#   tier-consistency 默认 warn 档（fixture 体量不达 standard 不阻断）。
# 依赖: 同目录 check-plan-audit-gate.sh 与 attest-plan.sh 已在位（S1/S2 产物）; 缺任一 → FAIL 退出非 0。

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CK="$SCRIPT_DIR/check-plan-audit-gate.sh"
AT="$SCRIPT_DIR/attest-plan.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'PAG-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'PAG-%s FAIL %s\n' "$1" "$2"; }

ROOT="$(mktemp -d)"
trap 'rm -rf "$ROOT"' EXIT
clear_cache() { rm -f /tmp/attest-cache-*.result; }

# fixture 构造器: task_plan.md（四锚最小合规体——requirement-gate 判据 =## 🎯 用户需求原文/`- **R1**`/R→VC 映射标题/根源覆盖表 ## 标题）
# $1=dir $2=tier(可空) $3=lane(可空) $4=附加内容(可空, 如行首 [plan-audit-skip] 声明行)
mkplan() {
  mkdir -p "$1"
  {
    [ -n "${2:-}" ] && printf 'plan_tier: %s\n' "$2"
    [ -n "${3:-}" ] && printf 'execution_lane: %s\n' "$3"
    printf '# 测试计划 fixture（selftest-plan-audit-gate）\n\n'
    [ -n "${4:-}" ] && printf '%s\n\n' "$4"
    printf '## 🎯 用户需求原文\n- **R1**: 计划审计门机器强门（fixture 需求锚）\n\n'
    printf '### R→VC 映射\n- R1→VC-1\n\n'
    printf '## 🧮 根源覆盖表\n\n| 来源 | 覆盖 |\n|------|------|\n| 51.1 | fixture |\n'
  } > "$1/task_plan.md"
}
# progress.md 构造器
mkprog() { local d="$1"; shift; printf '%s\n' "$@" > "$d/progress.md"; }

run_ck() { bash "$CK" "$1" >"$1/.ag_out" 2>&1; echo $?; }

# ── PAG-01 规范示意形态 APPROVED 通过（r3; `- 问题清单: 无`）──────────────────
D="$ROOT/c01"; mkplan "$D" standard L1
mkprog "$D" '## [plan-audit-R1] fixture' '- 轮次: R1 | 审计体: critic | 结论: **APPROVED**' '- 问题清单: 无'
rc=$(run_ck "$D"); [ "$rc" -eq 0 ] && ok 01 "规范示意 APPROVED rc0" || bad 01 "规范示意 APPROVED 期望 rc0 实得 $rc"

# ── PAG-02 真实生产形态 APPROVED 通过（r7; R6 段字节形态 `- 问题清单（留档，不阻断）:`——R7 I-1）──
D="$ROOT/c02"; mkplan "$D" standard L1
mkprog "$D" '## [plan-audit-R6] 2026-11-17 计划独立审计第 6 轮' '- 轮次: R6 | 审计体: critic | 结论: **APPROVED**（0 CRITICAL / 0 IMPORTANT；残留留档）' '- 问题清单（留档，不阻断）:' '  - W-1[W] 留档' '- 审计体: critic'
rc=$(run_ck "$D"); [ "$rc" -eq 0 ] && ok 02 "真实生产形态 APPROVED rc0（容忍括注 token）" || bad 02 "真实生产形态期望 rc0 实得 $rc"

# ── PAG-03 无留痕拒锁（progress.md 存在但空=rc1, R7 Q-2）──────────────────────
D="$ROOT/c03"; mkplan "$D" standard L1; : > "$D/progress.md"
rc=$(run_ck "$D"); [ "$rc" -eq 1 ] && ok 03 "无留痕（空文件）rc1" || bad 03 "无留痕期望 rc1 实得 $rc"

# ── PAG-04 无声明 → rc0 + SKIP legacy-no-decl（W-2 legacy 分支判据）───────────
D="$ROOT/c04"; mkplan "$D" "" ""
rc=$(run_ck "$D"); out=$(cat "$D/.ag_out")
if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -q 'SKIP legacy-no-decl'; then ok 04 "无声明 SKIP legacy-no-decl rc0"; else bad 04 "无声明期望 rc0+SKIP 行, 实得 rc=$rc out=$out"; fi

# ── PAG-05 轻量档行首 [plan-audit-skip] 声明放行 rc0（109.3）──────────────────
D="$ROOT/c05"; mkplan "$D" mini "" '[plan-audit-skip] 109.3 轻量档豁免登记（fixture 声明行）'
rc=$(run_ck "$D"); [ "$rc" -eq 0 ] && ok 05 "轻量档 skip 声明放行 rc0" || bad 05 "轻量档 skip 期望 rc0 实得 $rc"

# ── PAG-06 L1+ 含行首 skip 声明拒锁 rc1（F11 自声明旁路封堵）─────────────────
D="$ROOT/c06"; mkplan "$D" standard L1 '[plan-audit-skip] 试图自声明豁免（fixture）'
rc=$(run_ck "$D"); [ "$rc" -eq 1 ] && ok 06 "L1+ skip 自声明拒锁 rc1" || bad 06 "L1+ skip 期望 rc1 实得 $rc"

# ── PAG-07 mini 单独跳过 rc0（轻量档审计门不适用）────────────────────────────
D="$ROOT/c07"; mkplan "$D" mini ""
rc=$(run_ck "$D"); [ "$rc" -eq 0 ] && ok 07 "mini 单独跳过 rc0" || bad 07 "mini 单独期望 rc0 实得 $rc"

# ── PAG-08 mini×L1 冲突必审 rc1（lane 优先按最严, R1 F6）────────────────────
D="$ROOT/c08"; mkplan "$D" mini L1; : > "$D/progress.md"
rc=$(run_ck "$D"); [ "$rc" -eq 1 ] && ok 08 "mini×L1 冲突必审 rc1" || bad 08 "mini×L1 期望 rc1 实得 $rc"

# ── PAG-09 APPROVED 形态残缺 FAIL rc1（缺 问题清单 token——字面连写冒参见 R7 I-1; 此处彻底缺 token）──
D="$ROOT/c09"; mkplan "$D" standard L1
mkprog "$D" '## [plan-audit-R1] fixture' '- 轮次: R1 | 审计体: critic | 结论: **APPROVED**' '- 备注: 无问题清单行'
rc=$(run_ck "$D"); [ "$rc" -eq 1 ] && ok 09 "形态残缺（缺问题清单 token）rc1" || bad 09 "形态残缺期望 rc1 实得 $rc"

# ── PAG-10 中间态假阳性 rc1（r4: REJECTED 段+后随 H2 修复轮块含反引号 APPROVED 元引用; R6a）──
D="$ROOT/c10"; mkplan "$D" standard L1
mkprog "$D" '## [plan-audit-R1] fixture' '- 轮次: R1 | 审计体: critic | 结论: **REJECTED**' '- 问题清单: C-1' '## 2026-11-17 R1 修复轮' '- 自证: 无审计段级 `结论: **APPROVED**` 预写'
rc=$(run_ck "$D"); [ "$rc" -eq 1 ] && ok 10 "中间态假阳性被拒 rc1" || bad 10 "中间态期望 rc1 实得 $rc"

# ── PAG-11 仅锚定假 PASS 路径（fixture a=r5: REJECTED 段内裸文 APPROVED 意见文本; R7 I-2）──
D="$ROOT/c11"; mkplan "$D" standard L1
mkprog "$D" '## [plan-audit-R1] fixture' '- 轮次: R1 | 审计体: critic | 结论: **REJECTED**' '- 问题清单: C-1' '- 意见: 缺少 结论: **APPROVED** 行，不满足 0C/0I'
rc=$(run_ck "$D"); [ "$rc" -eq 1 ] && ok 11 "fixture a（段内裸文 APPROVED）rc1——锚定约束承重" || bad 11 "fixture a 期望 rc1 实得 $rc"

# ── PAG-12 仅边界假 PASS 路径（fixture b=r6: 后随 H2 块内正规锚定 APPROVED 行; R7 I-2）──
D="$ROOT/c12"; mkplan "$D" standard L1
mkprog "$D" '## [plan-audit-R1] fixture' '- 轮次: R1 | 审计体: critic | 结论: **REJECTED**' '- 问题清单: C-1' '## 2026-11-17 R9 修复轮' '- 轮次: R9 | 审计体: critic | 结论: **APPROVED**' '- 问题清单: 无'
rc=$(run_ck "$D"); [ "$rc" -eq 1 ] && ok 12 "fixture b（后随 H2 块锚定 APPROVED）rc1——边界约束承重" || bad 12 "fixture b 期望 rc1 实得 $rc"

# ── PAG-13 rc2=删除 progress.md 文件（非清空; R7 Q-2 分层契约）+WARN ──────────
D="$ROOT/c13"; mkplan "$D" standard L1; mkprog "$D" 'x'
rm -f "$D/progress.md"
out=$(bash "$CK" "$D" 2>&1); rc=$?
if [ "$rc" -eq 2 ] && printf '%s' "$out" | grep -q 'WARN 判定器输入异常'; then ok 13 "删除 progress.md → rc2+WARN"; else bad 13 "缺文件期望 rc2+WARN, 实得 rc=$rc out=$out"; fi

# ── PAG-14 缓存隔离（enforce→改留痕→enforce 不复用陈旧结果; progress 哈希入 cksum, R1 F4）──
D="$ROOT/c14"; mkplan "$D" standard L1
mkprog "$D" '## [plan-audit-R1] fixture' '- 轮次: R1 | 审计体: critic | 结论: **APPROVED**' '- 问题清单: 无'
clear_cache
SK="--skip-dispatch-check --skip-template-check --skip-fmea-check --skip-goal-check --skip-vc-check"
bash "$AT" $SK "$D/task_plan.md" >/dev/null 2>&1; r_pass=$?
mkprog "$D" '## [plan-audit-R1] fixture' '- 轮次: R1 | 审计体: critic | 结论: **REJECTED**' '- 问题清单: X'
clear_cache
TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce bash "$AT" $SK "$D/task_plan.md" >/dev/null 2>&1; r_rej=$?
if [ "$r_pass" -eq 0 ] && [ "$r_rej" -ne 0 ]; then ok 14 "缓存隔离: APPROVED 后改 REJECTED→enforce 再跑拒锁（progress 哈希入键生效）"; else bad 14 "缓存隔离期望 0/非0, 实得 $r_pass/$r_rej"; fi
rm -f "$D/.plan-attestation"

# ── PAG-15 attest enforce 无留痕 → 拒锁 rc≠0 且不写锁（S2 接线真实链路）────────
D="$ROOT/c15"; mkplan "$D" standard L1; : > "$D/progress.md"
clear_cache
out=$(TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce bash "$AT" $SK "$D/task_plan.md" 2>&1); rc=$?
if [ "$rc" -ne 0 ] && [ ! -f "$D/.plan-attestation" ] && printf '%s' "$out" | grep -q 'audit-gate'; then
  ok 15 "attest enforce 无留痕拒锁 rc≠0 不写锁+audit-gate 行"
else
  bad 15 "enforce 拒锁期望 rc≠0/无锁/含 audit-gate, 实得 rc=$rc 锁=$(test -f "$D/.plan-attestation" && echo 有 || echo 无)"
fi

# ── PAG-16 attest APPROVED → 放行 rc0 且写锁（含 [audit-gate] PASS 行）─────────
mkprog "$D" '## [plan-audit-R1] fixture' '- 轮次: R1 | 审计体: critic | 结论: **APPROVED**' '- 问题清单: 无'
clear_cache
out=$(TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce bash "$AT" $SK "$D/task_plan.md" 2>&1); rc=$?
if [ "$rc" -eq 0 ] && [ -f "$D/.plan-attestation" ] && printf '%s' "$out" | grep -q 'audit-gate'; then
  ok 16 "attest APPROVED 放行 rc0 写锁+audit-gate PASS 行"
else
  bad 16 "APPROVED 放行期望 rc0/有锁/含 audit-gate, 实得 rc=$rc 锁=$(test -f "$D/.plan-attestation" && echo 有 || echo 无)"
fi

clear_cache
printf 'Total: %d PASS=%d FAIL=%d\n' $((PASS+FAIL)) "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
