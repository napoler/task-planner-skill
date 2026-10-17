#!/usr/bin/env bash
# selftest-goal-cjk.sh — P-06「纯中文 Goal 漂移补检（CJK 分词）」行为级 + 静态守护（GCK-01..GCK-11）
#
# What（守护对象 + 运行方式）:
#   守护 check-goal-cjk.sh 全链落点，11 条编号断言，分三组：
#     · 静态锚（GCK-01..GCK-05）: check-goal-cjk.sh 在位/可执行/bash -n 通过 + 头注 What/Why 双层
#       （Rule 45）+ `[goal-cjk]` 输出前缀与 exit 0/1/2 语义锚 + registry 自登记 =1 +
#       CJK 区间定义锚（CJK_RANGE_DEF 非空且含 0x4E00 基本区下界，防分词器被静默掏空）。
#     · 行为级（GCK-06..GCK-09，mktemp 自建夹具，零外部依赖）:
#         GCK-06 负例 人为构造分词失效（纯中文 Goal「提高验证能力确保质量」+ --fault-inject）
#               → rc=1 + 「CJK 分词失败」
#         GCK-07 正例 同句不注入故障 → 抽出 ≥1 CJK 词，rc=0（同输入双向锁定：故障开关是可控面）
#         GCK-08 正例 多词中文 Goal（空白切分 5 词）→ rc=0 + 词数精确值
#         GCK-09 正例 纯 ASCII Goal（无 CJK）→ rc=0（正常跳过，不误拦）
#     · 输入缺失（GCK-10）: 缺 plan-dir / 缺 task_plan.md → rc=2。
#   运行方式: `bash scripts/selftest-goal-cjk.sh`；逐行打印 `GCK-NN PASS/FAIL <说明>`，
#   末行 `Total: N PASS=x FAIL=y`；全 PASS exit 0，任一 FAIL exit 1。夹具全部 mktemp 于 /tmp 并跑毕即删。
#
# Why（机制锚）:
#   根因（P-06 / 探测二 3-miss）=check-drift.sh:187 用 grep -oP '\w+' 抽 Goal 关键词，
#   纯中文 Goal 下 \w 在多数 locale 不含 CJK → 抽词为空 → GOAL-DRIFT 检对中文 Goal 静默永不触发。
#   P-06 补检门先保证「CJK 能抽词」（locale 鲁棒的 od+awk 字节态机分词），本脚本锁两件事：
#     ① 行为双向（负例必拦：CJK 在但 0 词；正例不误伤：ASCII Goal 正常跳过）；
#     ② 静态根因锚（GCK-05：区间定义被掏空时 GCK-06 必红，防「分词器静默回归成恒 0 词」）。
#   断言面只锁 P-06 新增锚，不触碰既有 selftest 断言行（Rule 36.5 纯增量）。
# 依赖: bash + awk + od + mktemp（夹具零外部依赖，同 selftest-evidence-anchor.sh 口径）。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GC="$SCRIPT_DIR/check-goal-cjk.sh"
REG="$SCRIPT_DIR/selftest-registry.tsv"
SELF="$SCRIPT_DIR/selftest-goal-cjk.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'GCK-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'GCK-%s FAIL %s\n' "$1" "$2"; }

# make_goal_fixture <dir> <goal行...> — 构造最小 task_plan.md（## Goal 段 + 一个 ## Phases 收尾）
make_goal_fixture() {
    local d="$1"; shift
    mkdir -p "$d"
    {
        printf '%s\n' '# Task Plan: P-06 selftest fixture' '' '## Goal'
        for line in "$@"; do printf '%s\n' "$line"; done
        printf '%s\n' '' '## Phases' '- [ ] V-1.1'
    } > "$d/task_plan.md"
}

# ── GCK-01 判定器在位 + 可执行 + bash -n ──────────────────────────────────────
if [ -f "$GC" ] && [ -x "$GC" ] && bash -n "$GC" 2>/dev/null; then
    ok 01 "check-goal-cjk.sh 在位 + 可执行 + bash -n 通过"
else
    bad 01 "check-goal-cjk.sh 缺失/不可执行/语法错（在位=$([ -f "$GC" ] && echo yes || echo no) 可执行=$([ -x "$GC" ] && echo yes || echo no)）"
fi

# ── GCK-02 头注 What/Why 双层注释（Rule 45）──────────────────────────────────
if grep -q '^# What' "$GC" && grep -q '^# Why' "$GC"; then
    ok 02 "头注 What + Why 双层注释齐备（Rule 45）"
else
    bad 02 "头注缺 What 或 Why（Rule 45 双层注释不齐）"
fi

# ── GCK-03 输出前缀 + exit 0/1/2 语义锚 ──────────────────────────────────────
if grep -q '\[goal-cjk\] ✗' "$GC" && grep -qE '^[[:space:]]*exit 1' "$GC" \
   && grep -qE '^[[:space:]]*exit 0' "$GC" && grep -qE '^[[:space:]]*exit 2' "$GC"; then
    ok 03 "输出前缀 [goal-cjk] ✗ + exit 0/1/2 三态语义锚在位"
else
    bad 03 "输出前缀或 exit 语义锚缺失（门控输出契约不齐）"
fi

# ── GCK-04 registry 自登记 =1 ─────────────────────────────────────────────────
_n="$(grep -c 'selftest-goal-cjk.sh' "$REG" 2>/dev/null || true)"
if [ "${_n:-0}" -ge 1 ]; then
    ok 04 "selftest-registry.tsv 含本脚本登记行（n=$_n）"
else
    bad 04 "selftest-registry.tsv 缺 selftest-goal-cjk.sh 登记行（回归不运行本守护）"
fi

# ── GCK-05 CJK 区间定义锚（基本区下界 0x4E00 = E4 B8 80 在位，防静默掏空）──
if grep -q 'CJK_RANGE_DEF=' "$GC" && ! grep -q "^CJK_RANGE_DEF=''$" "$GC" \
   && grep -qE 'B8' "$GC"; then
    ok 05 "CJK 区间定义锚在位（CJK_RANGE_DEF 非空 + U+4E00 下界 E4B880 在分词器中）"
else
    bad 05 "CJK 区间定义锚缺失/被掏空（分词器可能静默退化为恒 0 词）"
fi

# ── GCK-06 负例 纯中文 Goal + 人为构造分词失效（--fault-inject）→ rc=1 ──────
F6="$(mktemp -d "${TMPDIR:-/tmp}/gck6.XXXXXX")"
make_goal_fixture "$F6" '提高验证能力确保质量'
_o="$(bash "$GC" "$F6" --fault-inject 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q 'CJK 分词失败'; then
    ok 06 "负例 纯中文 Goal「提高验证能力确保质量」+ 人为分词失效 → rc=1 + CJK 分词失败"
else
    bad 06 "分词失效负例未拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F6"

# ── GCK-07 正例 同句不注入故障 → 抽出 ≥1 CJK 词, rc=0（同输入双向锁定）────
F7="$(mktemp -d "${TMPDIR:-/tmp}/gck7.XXXXXX")"
make_goal_fixture "$F7" '提高验证能力确保质量'
_o="$(bash "$GC" "$F7" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && printf '%s' "$_o" | grep -q '抽出 .* 个 CJK 词'; then
    ok 07 "正例 同句不注入故障 → rc=0 且抽出 $(printf '%s' "$_o" | grep -o '[0-9]\+' | head -1) 个 CJK 词（同输入双向锁定）"
else
    bad 07 "正例未通过: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F7"

# ── GCK-08 正例 多词中文 Goal（空白切分 5 词）→ rc=0 且词数=5 ────────────────
F8="$(mktemp -d "${TMPDIR:-/tmp}/gck8.XXXXXX")"
make_goal_fixture "$F8" '提升 验证 能力 与 质量'
_o="$(bash "$GC" "$F8" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && printf '%s' "$_o" | grep -q '抽出 5 个 CJK 词'; then
    ok 08 "正例 多词中文 Goal → rc=0 且词数精确=5（空白切分面锁定）"
else
    bad 08 "多词分词异常: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F8"

# ── GCK-09 正例 纯 ASCII Goal（无 CJK）→ rc=0 正常跳过 ──────────────────────
F9="$(mktemp -d "${TMPDIR:-/tmp}/gck9.XXXXXX")"
make_goal_fixture "$F9" 'Fix the parser bug'
_o="$(bash "$GC" "$F9" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && printf '%s' "$_o" | grep -q '无 CJK'; then
    ok 09 "正例 纯 ASCII Goal → rc=0（无 CJK 正常跳过，不误拦）"
else
    bad 09 "纯 ASCII Goal 误拦: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F9"

# ── GCK-10 输入缺失 → rc=2（缺 plan-dir / 缺 task_plan.md 两态同码）────────
_md="$(mktemp -d "${TMPDIR:-/tmp}/gck10.XXXXXX")"   # 空目录 = task_plan.md 缺
_o1="$(bash "$GC" "$_md" 2>&1)"; _rc1=$?
_o2="$(bash "$GC" "/tmp/gck-no-such-dir-$RANDOM" 2>&1)"; _rc2=$?
if [ "$_rc1" -eq 2 ] && [ "$_rc2" -eq 2 ] && printf '%s' "$_o1" | grep -q 'task_plan.md 缺失' \
   && printf '%s' "$_o2" | grep -q 'plan-dir 缺失或非目录'; then
    ok 10 "输入缺失两态 → rc=2（task_plan.md 缺失 / plan-dir 缺失，各带具体诊断）"
else
    bad 10 "输入缺失语义异常: 缺planfile_rc=$_rc1（应 2）缺dir_rc=$_rc2（应 2）"
fi
rm -rf "$_md"

# ── GCK-11 负断言：判定器零 python3 依赖（纯 bash+awk+od 实现承诺）──────────
_np="$(grep -c 'python3' "$GC" 2>/dev/null || true)"
if [ "${_np:-0}" -eq 0 ]; then
    ok 11 "负断言：check-goal-cjk.sh 无 python3 依赖（纯 bash+awk+od 实现，locale 鲁棒承诺）"
else
    bad 11 "判定器含 python3 字面 n=$_np（违背纯 bash 实现承诺）"
fi

echo "----------------------------------------------------------------"
echo "[selftest-goal-cjk] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
