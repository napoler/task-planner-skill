#!/usr/bin/env bash
# selftest-tier-consistency.sh — P-09「档位声明外部复核」行为级 + 静态守护（TC-01..TC-08）
#
# What（守护对象 + 运行方式）:
#   守护 P-09 落点，8 条编号断言，分两组：
#     · 静态锚（TC-01..TC-04）: check-tier-consistency.sh 在位 + bash -n 通过；头注 What/Why
#       双层（Rule 45）；`[tier-consistency]` 输出前缀 + exit 0/1/2 语义锚；registry 自登记 =1
#       （registry 行由主流程后续登记；此刻未登记该条预期 FAIL，属已知挂起面）。
#     · 判定器行为级（TC-05..TC-08，mktemp 自建夹具，零外部依赖）:
#         TC-05 负例 声明 plan_tier=mini 但 Phase 数=3 / VC 数=6 达 standard 级 → rc=1 + 指标行
#         TC-06 正例 声明 plan_tier=standard（体量任意）→ rc=0（不触发 mini 复核面）
#         TC-07 正例 无档位声明（plan_tier/execution_lane 均缺 = 无判定面）→ rc=0（fail-open）
#         TC-08 负例 声明 execution_lane=L0 但多 Phase（Phase 数=2）→ rc=1 + 多 Phase 指标行
#   运行方式: `bash scripts/selftest-tier-consistency.sh`；逐行打印 `TC-NN PASS/FAIL <说明>`，
#   末行 `Total: N PASS=x FAIL=y`；全 PASS exit 0，任一 FAIL exit 1。夹具全部 mktemp 于 /tmp 并跑毕即删。
#
# Why（机制锚）:
#   P-09 痛点 = 档位自声明无外部体量复核（重计划可自声明 mini/L0 降档规避 38.4/38.7 门控）。
#   本脚本锁两件事：① 判定器行为双向（负例必拦——降档声明与体量不符必须 exit 1；正例不误伤——
#   standard 声明与无声明计划零阻断，对齐 38.1 legacy 零影响口径）；② 静态锚（前缀/exit 语义/
#   头注双层/registry 登记）保证门控输出契约与回归可达。
# 依赖: bash + grep/awk/sed + wc。只读仓库 + 写 /tmp 夹具。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TC="$SCRIPT_DIR/check-tier-consistency.sh"
REG="$SCRIPT_DIR/selftest-registry.tsv"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'TC-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'TC-%s FAIL %s\n' "$1" "$2"; }

# ── 夹具构造器：make_tier_fixture <dir> <plan_tier值|none> <execution_lane值|none> [额外体量行...]
make_tier_fixture() {
    local d="$1" tier="$2" lane="$3"; shift 3
    mkdir -p "$d"
    {
        printf '%s\n' '# Task Plan: P-09 selftest fixture'
        [ "$tier" != "none" ] && printf 'plan_tier: %s\n' "$tier"
        [ "$lane" != "none" ] && printf 'execution_lane: %s\n' "$lane"
        printf '%s\n' "$@"
    } > "$d/task_plan.md"
}

# ── TC-01 判定器在位 + bash -n ────────────────────────────────────────────────
if [ -f "$TC" ] && bash -n "$TC" 2>/dev/null; then
    ok 01 "check-tier-consistency.sh 在位 + bash -n 通过"
else
    bad 01 "check-tier-consistency.sh 缺失或语法错（在位=$([ -f "$TC" ] && echo yes || echo no)）"
fi

# ── TC-02 头注 What/Why 双层注释（Rule 45）────────────────────────────────────
if grep -q '^# What' "$TC" && grep -q '^# Why' "$TC"; then
    ok 02 "头注 What + Why 双层注释齐备（Rule 45）"
else
    bad 02 "头注缺 What 或 Why（Rule 45 双层注释不齐）"
fi

# ── TC-03 输出前缀 + exit 语义锚（0/1/2 三态）────────────────────────────────
if grep -q '\[tier-consistency\] ✗' "$TC" && grep -qE '^[[:space:]]*exit 1' "$TC" \
   && grep -qE '^[[:space:]]*exit 0' "$TC" && grep -qE '^[[:space:]]*exit 2' "$TC"; then
    ok 03 "输出前缀 [tier-consistency] ✗ + exit 0/1/2 三态语义锚在位"
else
    bad 03 "输出前缀或 exit 语义锚缺失（门控输出契约不齐）"
fi

# ── TC-04 registry 自登记 =1（此刻预期 FAIL：registry 行由主流程后续登记）────
_n="$(grep -c 'selftest-tier-consistency.sh' "$REG" 2>/dev/null || true)"
if [ "${_n:-0}" -ge 1 ]; then
    ok 04 "selftest-registry.tsv 含本脚本登记行（n=$_n）"
else
    bad 04 "selftest-registry.tsv 缺 selftest-tier-consistency.sh 登记行（回归不运行本守护；P-09 挂起面）"
fi

# ── TC-05 负例 声明 mini 但 Phase/VC 数达 standard 级 → rc=1 ────────────────
F5="$(mktemp -d "${TMPDIR:-/tmp}/tc5.XXXXXX")"
make_tier_fixture "$F5" mini none \
    '## Phases' \
    '### Phase 1: 实施' \
    '### Phase 2: 验收' \
    '### Phase 3: 扩展' \
    '- [ ] VC-1 / VC-2 / VC-3 / VC-4 / VC-5 / VC-6'
_o="$(bash "$TC" "$F5" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q '声明 plan_tier=mini 但体量达 standard 级'; then
    ok 05 "负例 声明 mini 但 Phase=3/VC=6 达 standard 级 → rc=1 + 指标行"
else
    bad 05 "mini 降档声明未拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F5"

# ── TC-06 正例 声明 standard（体量任意）→ rc=0（不触发 mini 复核面）──────────
F6="$(mktemp -d "${TMPDIR:-/tmp}/tc6.XXXXXX")"
make_tier_fixture "$F6" standard L1 \
    '## Phases' \
    '### Phase 1: 实施' \
    '### Phase 2: 验收' \
    '### Phase 3: 扩展' \
    '- [ ] VC-1 / VC-2 / VC-3 / VC-4 / VC-5'
_o="$(bash "$TC" "$F6" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ]; then
    ok 06 "正例 声明 standard + L1（多 Phase 多 VC）→ rc=0（不触发降档复核面）"
else
    bad 06 "standard 声明被误拦: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F6"

# ── TC-07 正例 无档位声明 = 无判定面 → rc=0（fail-open，38.1 legacy 零影响）──
F7="$(mktemp -d "${TMPDIR:-/tmp}/tc7.XXXXXX")"
make_tier_fixture "$F7" none none \
    '## Phases' \
    '### Phase 1: 实施'
_o="$(bash "$TC" "$F7" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && printf '%s' "$_o" | grep -q 'SKIP'; then
    ok 07 "正例 无档位声明 → rc=0 + SKIP（无判定面 fail-open）"
else
    bad 07 "无声明计划误拦: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F7"

# ── TC-08 负例 声明 L0 但多 Phase（Phase 数=2）→ rc=1 ────────────────────────
F8="$(mktemp -d "${TMPDIR:-/tmp}/tc8.XXXXXX")"
make_tier_fixture "$F8" standard L0 \
    '## Phases' \
    '### Phase 1: 实施' \
    '### Phase 2: 验收'
_o="$(bash "$TC" "$F8" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q '声明 execution_lane=L0 但形态超出轻量通道'; then
    ok 08 "负例 声明 L0 但多 Phase（Phase=2）→ rc=1 + 多 Phase 指标行"
else
    bad 08 "L0 多 Phase 未拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F8"

echo "----------------------------------------------------------------"
echo "[selftest-tier-consistency] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
