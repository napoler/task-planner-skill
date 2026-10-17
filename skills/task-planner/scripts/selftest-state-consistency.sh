#!/usr/bin/env bash
# selftest-state-consistency.sh — P-04 计划状态三源一致性门(check-state-consistency.sh)行为级自测
# 被测对象: check-state-consistency.sh (checkbox ↔ Status ↔ progress 三源交叉, 拦截 caseB-textonly 型
#   「纸面证据链完整但现实未完成」假 COMPLETE)。
# 每个夹具在 /tmp 独立 mktemp 目录构造最小 task_plan.md + progress.md(不依赖仓库, hermetic),
# 实跑被测脚本断言 stdout 关键行 + 退出码。Total 行汇总, 任一 FAIL exit 1; 只读被测脚本,
# 写入仅 /tmp 夹具, 退出清理。
#
# 断言面(对应提案三夹具: B-textonly 型 FAIL / 基线 PASS / pending 误标 complete FAIL):
#   SC-01 B-textonly 型: Phase 存在未勾「- [ ]」但 **Status:** complete → [state-mismatch] S-1a 行 + rc=1
#   SC-02 基线一致: 全勾 + complete + progress 同名段 complete → PASS 行 + rc=0
#   SC-03 plan↔progress: plan Phase complete 但 progress 同名段 in_progress 且段内无 [goal:G 证据行
#           → [state-mismatch] S-2 行 + rc=1
#   SC-04 已勾却挂起(S-1b): Phase 全勾「- [x]」但 **Status:** pending → [state-mismatch] S-1b 行 + rc=1
#   SC-05 S-2 负向守门: plan Phase complete + progress 同名段 in_progress 但段内含 [goal:G 证据行
#           → 不误报(仅 S-2 不触发), 无 S-2 行 + rc=0
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GATE="$SCRIPT_DIR/check-state-consistency.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'SC-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'SC-%s FAIL %s\n' "$1" "$2"; }
diag(){ printf '  detail: %s\n' "$1"; }

# mkfixture <dir> <plan_body> <progress_body>: 写 task_plan.md + progress.md
mkfixture() {
    local d="$1"
    printf '%s\n' "$2" > "$d/task_plan.md"
    printf '%s\n' "$3" > "$d/progress.md"
}

# run_gate <dir>: 实跑被测脚本, stdout→OUT, rc→RC
run_gate() {
    local d="$1"
    OUT="$(bash "$GATE" "$d/task_plan.md" 2>/dev/null)"
    RC=$?
}

OUT=""; RC=0
DIRS=()
cleanup() { for d in "${DIRS[@]}"; do [ -n "$d" ] && rm -rf "$d"; done; return 0; }
trap cleanup EXIT

# ── SC-01 B-textonly 型: Phase 1 未勾 + complete → S-1a FAIL ─────────────────────────────
DIRS+=("$(mktemp -d)")
mkfixture "${DIRS[0]}" \
'### Phase 1: A 类
- [ ] 读脚本头部（未完成）
- [x] 构造夹具
- **Status:** complete

### Phase 2: B 类
- [x] 取证
- **Status:** complete' \
'### Phase 1
- **Status:** in_progress
- **Started:** 2026-10-16 10:30
'
run_gate "${DIRS[0]}"
if [ "$RC" -eq 1 ] && printf '%s' "$OUT" | grep -q '\[state-mismatch\] S-1a Phase 1'; then
    ok 01 "B-textonly 型(未勾+complete) 触发 S-1a rc=1"
else
    bad 01 "B-textonly 型未触发 S-1a (rc=$RC)"; diag "$OUT"
fi

# ── SC-02 基线一致: 全勾+complete, progress 同名段 complete → PASS rc=0 ────────────────
DIRS+=("$(mktemp -d)")
mkfixture "${DIRS[1]}" \
'### Phase 1: A 类
- [x] 读脚本头部
- [x] 构造夹具
- **Status:** complete

### Phase 2: B 类
- [x] 取证
- **Status:** complete' \
'### Phase 1
- **Status:** complete
- [goal:G1] 证据: 复跑 exit 1 PASS

### Phase 2
- **Status:** complete
- [goal:G2] 证据: 复跑 exit 1 PASS
'
run_gate "${DIRS[1]}"
if [ "$RC" -eq 0 ] && printf '%s' "$OUT" | grep -q '\[state-consistency\] PASS'; then
    ok 02 "基线一致 PASS rc=0"
else
    bad 02 "基线一致未 PASS (rc=$RC)"; diag "$OUT"
fi

# ── SC-03 plan↔progress: plan complete 但 progress in_progress 且无 [goal:G → S-2 FAIL ──
DIRS+=("$(mktemp -d)")
mkfixture "${DIRS[2]}" \
'### Phase 1: A 类
- [x] 读脚本头部
- **Status:** complete' \
'### Phase 1
- **Status:** in_progress
- Actions: 实际执行中断
- **Started:** 2026-10-16 10:30
'
run_gate "${DIRS[2]}"
if [ "$RC" -eq 1 ] && printf '%s' "$OUT" | grep -q '\[state-mismatch\] S-2 Phase 1'; then
    ok 03 "plan↔progress 交叉(complete vs in_progress 无证据) 触发 S-2 rc=1"
else
    bad 03 "plan↔progress 交叉未触发 S-2 (rc=$RC)"; diag "$OUT"
fi

# ── SC-04 已勾却挂起(S-1b): 全勾 + pending → S-1b FAIL ─────────────────────────────────
DIRS+=("$(mktemp -d)")
mkfixture "${DIRS[3]}" \
'### Phase 1: A 类
- [x] 读脚本头部
- [x] 构造夹具
- **Status:** pending' \
'### Phase 1
- **Status:** in_progress
'
run_gate "${DIRS[3]}"
if [ "$RC" -eq 1 ] && printf '%s' "$OUT" | grep -q '\[state-mismatch\] S-1b Phase 1'; then
    ok 04 "已勾却挂起(全勾+pending) 触发 S-1b rc=1"
else
    bad 04 "已勾却挂起未触发 S-1b (rc=$RC)"; diag "$OUT"
fi

# ── SC-05 S-2 负向守门: plan complete + progress in_progress 但含 [goal:G 证据 → 不误报 S-2 ──
DIRS+=("$(mktemp -d)")
mkfixture "${DIRS[4]}" \
'### Phase 1: A 类
- [x] 读脚本头部
- **Status:** complete' \
'### Phase 1
- **Status:** in_progress
- [goal:G1] 证据: 复跑 exit 1 PASS
'
run_gate "${DIRS[4]}"
if [ "$RC" -eq 0 ] && ! printf '%s' "$OUT" | grep -q '\[state-mismatch\] S-2'; then
    ok 05 "S-2 负向(含 [goal:G 证据) 不误报 rc=0"
else
    bad 05 "S-2 负向误报或 rc 非 0 (rc=$RC)"; diag "$OUT"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
