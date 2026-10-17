#!/usr/bin/env bash
# selftest-rvc-coverage.sh — P-08「R→VC 双向覆盖核对」行为级 + 静态守护（RVC-01..RVC-09）
#
# What（守护对象 + 运行方式）:
#   守护 P-08 全链落点，9 条编号断言，分两组：
#     · 静态锚（RVC-01..RVC-04）: check-rvc-coverage.sh 在位/可执行/bash -n 通过
#       + 头注 What/Why 双层（Rule 45）+ `[rvc-coverage]` 输出前缀与 exit 0/1/2 语义锚
#       + registry 自登记 =1。
#     · 判定器行为级（RVC-05..RVC-09，mktemp 自建夹具，零外部依赖）:
#         RVC-05 负例 R1 无 VC 引用（R 行在、VC 段在但文本不引用 R1 且无映射表行）→ rc=1 + ✗ R1
#         RVC-06 负例 VC-3 无 R 映射（R1↔VC-1 双向齐备, 但 VC-3 无任何引用面）→ rc=1 + ✗ VC-3
#         RVC-07 正例 R1↔VC-1 双向覆盖（映射表行 `| R1 | VC-1 |`）→ rc=0
#         RVC-08 正例 无 R 段 = 无判定面 → rc=0（SKIP 口径）
#         RVC-09 负例 R 行存在但 VC 段整体缺失（R 行 1、VC 行 0）→ rc=1（判定面全空≠无判定面,
#                 防「计划忘了写 VC 段」静默 PASS）
#   运行方式: `bash scripts/selftest-rvc-coverage.sh`；逐行打印 `RVC-NN PASS/FAIL <说明>`，
#   末行 `Total: N PASS=x FAIL=y`；全 PASS exit 0，任一 FAIL exit 1。夹具全部 mktemp 于 /tmp 并跑毕即删。
#
# Why（机制锚）:
#   根因（P-08 审计缺口）= task_plan.md 的 R 行（🎯 用户需求原文）与 VC 行（Verification Contract）
#   之间无机器校验，VC 设计是否覆盖 Goal 靠模型自觉——「R 无 VC 覆盖」与「VC 无 R 映射」两类
#   缺口都静默通过。P-08 把 R↔VC 双向映射升格为机器不变量；本脚本锁双向正负例 + 无判定面 SKIP
#   口径 + 「VC 段整体缺失」最强形态缺口（防 fail-open 被误用成放行面）。
# 依赖: bash + awk + grep（无 python / 无 jq, 与判定器同口径）。只读仓库 + 写 /tmp 夹具。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RC="$SCRIPT_DIR/check-rvc-coverage.sh"
REG="$SCRIPT_DIR/selftest-registry.tsv"
SELF="$SCRIPT_DIR/selftest-rvc-coverage.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'RVC-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'RVC-%s FAIL %s\n' "$1" "$2"; }

# ── 夹具构造器（heredoc 直写 task_plan.md, 各用例独立）────────────────────────

# ── RVC-01 判定器在位 + 可执行 + bash -n ────────────────────────────────────
if [ -f "$RC" ] && [ -x "$RC" ] && bash -n "$RC" 2>/dev/null; then
    ok 01 "check-rvc-coverage.sh 在位 + 可执行 + bash -n 通过"
else
    bad 01 "check-rvc-coverage.sh 缺失/不可执行/语法错（在位=$([ -f "$RC" ] && echo yes || echo no) 可执行=$([ -x "$RC" ] && echo yes || echo no)）"
fi

# ── RVC-02 头注 What/Why 双层注释（Rule 45）────────────────────────────────
if grep -q '^# What' "$RC" && grep -q '^# Why' "$RC"; then
    ok 02 "头注 What + Why 双层注释齐备（Rule 45）"
else
    bad 02 "头注缺 What 或 Why（Rule 45 双层注释不齐）"
fi

# ── RVC-03 输出前缀 + exit 0/1/2 语义锚 ────────────────────────────────────
if grep -q '\[rvc-coverage\] ✗' "$RC" \
   && grep -qE '^[[:space:]]*exit 1' "$RC" \
   && grep -qE '^[[:space:]]*exit 0' "$RC" \
   && grep -qE '^[[:space:]]*exit 2' "$RC"; then
    ok 03 "输出前缀 [rvc-coverage] ✗ + exit 0/1/2 语义锚在位"
else
    bad 03 "输出前缀或 exit 语义锚缺失（门控输出契约不齐）"
fi

# ── RVC-04 registry 自登记 =1 ──────────────────────────────────────────────
_n="$(grep -c 'selftest-rvc-coverage.sh' "$REG" 2>/dev/null || true)"
if [ "${_n:-0}" -ge 1 ]; then
    ok 04 "selftest-registry.tsv 含本脚本登记行（n=$_n）"
else
    bad 04 "selftest-registry.tsv 缺 selftest-rvc-coverage.sh 登记行（回归不运行本守护；P-08 建时 FAIL 属预期, 登记行后续追加）"
fi

# ── RVC-05 负例 R1 无 VC 引用 → rc=1 ──────────────────────────────────────
# 形态: R1/R2 两行; VC 段 3 条 checkbox; VC-3 文本引用 R2（R2 豁免）, 但 R1 无任何引用面
#       （无映射表行、VC 判据文本不提 R1）→ 仅 R1 报缺口
F5="$(mktemp -d "${TMPDIR:-/tmp}/rvc5.XXXXXX")"
mkdir -p "$F5"
cat > "$F5/task_plan.md" <<'EOF'
# Task Plan: P-08 selftest fixture (RVC-05)

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录）

- **R1**: 「需求一：落地双向覆盖核对判定器。」
- **R2**: 「需求二：selftest 九断言守护。」

## ✅ Verification Contract

- [ ] VC-1: 判定器在位 + bash -n 通过
- [ ] VC-2: 回归 FAIL=0
- [ ] VC-3: R2 selftest 覆盖（引用 R2）
EOF
_o="$(bash "$RC" "$F5" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q '✗ R1 无 VC 覆盖'; then
    ok 05 "负例 R1 无 VC 引用 → rc=1 + [rvc-coverage] ✗ R1 无 VC 覆盖（R2 经 VC-3 文本引用被豁免, 逐条不互带）"
else
    bad 05 "R1 缺口未被拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F5"

# ── RVC-06 负例 VC-3 无 R 映射 → rc=1 ─────────────────────────────────────
# 形态: R1 经映射表行 `| R1 | VC-1 |` 覆盖; VC-1 经同一映射表行豁免; VC-3 无任何引用面
F6="$(mktemp -d "${TMPDIR:-/tmp}/rvc6.XXXXXX")"
mkdir -p "$F6"
cat > "$F6/task_plan.md" <<'EOF'
# Task Plan: P-08 selftest fixture (RVC-06)

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录）

- **R1**: 「需求一：落地双向覆盖核对判定器。」

## ✅ Verification Contract

- [ ] VC-1: 映射表在位且双向覆盖
- [ ] VC-3: 全量回归 FAIL=0（不引用任何 R）

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据 |
|---|---------|----------|
| R1 | VC-1 | 映射表在位 |
EOF
_o="$(bash "$RC" "$F6" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q '✗ VC-3 无 R 映射'; then
    ok 06 "负例 VC-3 无 R 映射 → rc=1 + [rvc-coverage] ✗ VC-3 无 R 映射（VC-1 经映射表行豁免）"
else
    bad 06 "VC-3 缺口未被拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F6"

# ── RVC-07 正例 R1↔VC-1 双向覆盖 → rc=0 ───────────────────────────────────
F7="$(mktemp -d "${TMPDIR:-/tmp}/rvc7.XXXXXX")"
mkdir -p "$F7"
cat > "$F7/task_plan.md" <<'EOF'
# Task Plan: P-08 selftest fixture (RVC-07)

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录）

- **R1**: 「需求一：落地双向覆盖核对判定器。」

## ✅ Verification Contract

- [ ] VC-1: 判定器双向覆盖判定实现（映射表在位即 R1 覆盖证据）

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据 |
|---|---------|----------|
| R1 | VC-1 | R1↔VC-1 双向 |
EOF
_o="$(bash "$RC" "$F7" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && printf '%s' "$_o" | grep -q '✓'; then
    ok 07 "正例 R1↔VC-1 双向覆盖 → rc=0（摘要: $(printf '%s' "$_o" | tail -1)）"
else
    bad 07 "正例被误拦: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F7"

# ── RVC-08 正例 无 R 段 = 无判定面 → rc=0（SKIP）──────────────────────────
F8="$(mktemp -d "${TMPDIR:-/tmp}/rvc8.XXXXXX")"
mkdir -p "$F8"
cat > "$F8/task_plan.md" <<'EOF'
# Task Plan: P-08 selftest fixture (RVC-08)

## ✅ Verification Contract

- [ ] VC-1: 无 Goal 计划（无 R 段）
EOF
_o="$(bash "$RC" "$F8" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && printf '%s' "$_o" | grep -q 'SKIP'; then
    ok 08 "正例 无 R 段（无判定面）→ rc=0 + SKIP（无 Goal 可覆盖, 核对不适用）"
else
    bad 08 "无判定面被误拦: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F8"

# ── RVC-09 负例 R 行在但 VC 段整体缺失 → rc=1（判定面全空≠无判定面）────────
F9="$(mktemp -d "${TMPDIR:-/tmp}/rvc9.XXXXXX")"
mkdir -p "$F9"
cat > "$F9/task_plan.md" <<'EOF'
# Task Plan: P-08 selftest fixture (RVC-09)

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录）

- **R1**: 「需求一：落地双向覆盖核对判定器。」

## Phases

### Phase 1: 执行
EOF
_o="$(bash "$RC" "$F9" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q '✗ R1 无 VC 覆盖'; then
    ok 09 "负例 R 行在但 VC 段缺失 → rc=1（VC 行=0 是最强形态缺口, 不得 SKIP 放行）"
else
    bad 09 "VC 段整体缺失未被拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F9"

echo "----------------------------------------------------------------"
echo "[selftest-rvc-coverage] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
