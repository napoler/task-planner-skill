#!/usr/bin/env bash
# selftest-step-placeholders.sh — P-03「计划步骤占位符扫描」行为级 + 静态守护（SP-01..SP-10）
#
# What（守护对象 + 运行方式）:
#   守护 P-03 全链落点，10 条编号断言，分三组：
#     · 静态锚（SP-01..SP-04）: check-step-placeholders.sh 在位/可执行/bash -n 通过
#       + 头注 What/Why 双层（Rule 45）+ `[step-placeholder]` 输出前缀与 exit 0/1/2 语义锚
#       + registry 自登记 =1。
#     · 判定器行为级（SP-05..SP-07，mktemp 自建夹具，零外部依赖）:
#         SP-05 负例 步骤「优化一下性能让它快一点」（模糊动词+零锚）→ rc=1 + ✗ 不可执行步骤
#         SP-06 正例 步骤「在 src/auth.ts:42 增加 token 空值校验并跑 bun test」（路径锚+命令锚）→ rc=0
#         SP-07 输入异常 plan-dir 缺失 / task_plan.md 缺失 → rc=2（双层 fail-fast）
#     · 判定面边界（SP-08..SP-10，防误报面）:
#         SP-08 负例 第二模糊词「处理一下那个 bug」→ rc=1（词表第二词命）
#         SP-09 Phase 段外（`## ` 其他段）checkbox 含模糊词 → rc=0（判定面只认 Phase 段，散文/他段不误报）
#         SP-10 正例 模糊动词「跑一下测试」但带命令锚「bun test」→ rc=0（有锚即放行，动词模糊≠占位）
#   运行方式: `bash scripts/selftest-step-placeholders.sh`；逐行打印 `SP-NN PASS/FAIL <说明>`，
#   末行 `Total: N PASS=x FAIL=y`；全 PASS exit 0，任一 FAIL exit 1。夹具全部 mktemp 于 /tmp 并跑毕即删。
#
# Why（机制锚）:
#   根因 = task_plan.md 的 Phase 步骤行常写成「优化一下/处理一下」式模糊动词占位，
#   既无对象也无验收点，VC/覆盖/一致性全链仍全绿 →「全链通过但步骤空转」。P-03 把步骤行
#   从「形式上有 checkbox」升级为「模糊动词 ∧ 零锚 = 不可执行」机器可判。本脚本锁两件事：
#     ① 判定器行为（正/负例双向：占位必拦、带锚不误伤——防把痛点换成误报面）；
#     ② 判定面边界（Phase 段外散文不进判定面——「等/看看」在散文里合法）。
# 依赖: bash + grep（纯 bash，无 python/jq）。只读仓库 + 写 /tmp 夹具。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REG="$SCRIPT_DIR/selftest-registry.tsv"
CHECKER="$SCRIPT_DIR/check-step-placeholders.sh"
SELF="$SCRIPT_DIR/selftest-step-placeholders.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'SP-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'SP-%s FAIL %s\n' "$1" "$2"; }

# ── 夹具构造器: mktemp plan-dir + task_plan.md（Phase 段 + 可选项「其他段」）──────────
# make_plan <dir> <步骤行内容（换行分隔，逐行成为 Phase 1 内 checkbox）> [他段步骤行]
make_plan() {
    local d="$1" steps="$2" out="${3:-}"
    mkdir -p "$d"
    {
        printf '%s\n' \
            '# Task Plan: P-03 selftest fixture' \
            '' \
            '## Phases' \
            '' \
            '### Phase 1: 执行' \
            '- **Status:** pending'
        printf '%s\n' "$steps"
        if [ -n "$out" ]; then
            printf '%s\n' '' '## 其他段'
            printf '%s\n' "$out"
        fi
    } > "$d/task_plan.md"
}

# ── SP-01 判定器在位 + 可执行 + bash -n ────────────────────────────────────────
if [ -f "$CHECKER" ] && [ -x "$CHECKER" ] && bash -n "$CHECKER" 2>/dev/null; then
    ok 01 "check-step-placeholders.sh 在位 + 可执行 + bash -n 通过"
else
    bad 01 "check-step-placeholders.sh 缺失/不可执行/语法错（在位=$([ -f "$CHECKER" ] && echo yes || echo no) 可执行=$([ -x "$CHECKER" ] && echo yes || echo no)）"
fi

# ── SP-02 头注 What/Why 双层注释（Rule 45）────────────────────────────────────
if grep -q '^# What' "$CHECKER" && grep -q '^# Why' "$CHECKER"; then
    ok 02 "头注 What + Why 双层注释齐备（Rule 45）"
else
    bad 02 "头注缺 What 或 Why（Rule 45 双层注释不齐）"
fi

# ── SP-03 输出前缀 + exit 0/1/2 语义锚 ───────────────────────────────────────
if grep -q '\[step-placeholder\] ✗' "$CHECKER" \
   && grep -qE '^[[:space:]]*exit 0' "$CHECKER" \
   && grep -qE '^[[:space:]]*exit 1' "$CHECKER" \
   && grep -qE '^[[:space:]]*exit 2' "$CHECKER"; then
    ok 03 "输出前缀 [step-placeholder] ✗ + exit 0/1/2 语义锚在位"
else
    bad 03 "输出前缀或 exit 语义锚缺失（门控输出契约不齐）"
fi

# ── SP-04 registry 自登记 =1 ─────────────────────────────────────────────────
_n="$(grep -c 'selftest-step-placeholders.sh' "$REG" 2>/dev/null || true)"
if [ "${_n:-0}" -ge 1 ]; then
    ok 04 "selftest-registry.tsv 含本脚本登记行（n=$_n）"
else
    bad 04 "selftest-registry.tsv 缺 selftest-step-placeholders.sh 登记行（回归不运行本守护）"
fi

# ── SP-05 负例「优化一下性能让它快一点」→ rc=1 ───────────────────────────────
F5="$(mktemp -d "${TMPDIR:-/tmp}/sp5.XXXXXX")"
make_plan "$F5" '- [ ] 优化一下性能让它快一点'
_o="$(bash "$CHECKER" "$F5" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q '不可执行步骤' \
   && printf '%s' "$_o" | grep -q '优化一下性能让它快一点'; then
    ok 05 "负例「优化一下性能让它快一点」→ rc=1 + ✗ 不可执行步骤（原文回显）"
else
    bad 05 "占位步骤未被拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F5"

# ── SP-06 正例「src/auth.ts:42 增加 token 空值校验并跑 bun test」→ rc=0 ──────
F6="$(mktemp -d "${TMPDIR:-/tmp}/sp6.XXXXXX")"
make_plan "$F6" '- [ ] 在 src/auth.ts:42 增加 token 空值校验并跑 bun test'
_o="$(bash "$CHECKER" "$F6" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && printf '%s' "$_o" | grep -q '✓'; then
    ok 06 "正例（路径锚 src/auth.ts:42 + 命令锚 bun test）→ rc=0（有锚即放行）"
else
    bad 06 "带锚步骤被误拦: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F6"

# ── SP-07 输入异常: plan-dir 缺失 / task_plan.md 缺失 → rc=2 ─────────────────
F7="$(mktemp -d "${TMPDIR:-/tmp}/sp7.XXXXXX")"   # 目录在但无 task_plan.md
_o1="$(bash "$CHECKER" "$F7" 2>&1)"; _rc1=$?
_o2="$(bash "$CHECKER" "${F7}/no-such-dir" 2>&1)"; _rc2=$?
if [ "$_rc1" -eq 2 ] && [ "$_rc2" -eq 2 ] \
   && printf '%s' "$_o1" | grep -q 'task_plan.md 缺失' \
   && printf '%s' "$_o2" | grep -q 'plan-dir 缺失'; then
    ok 07 "输入异常双层 fail-fast: 无 task_plan.md rc=2 + plan-dir 缺失 rc=2"
else
    bad 07 "输入异常语义异常: 缺文件_rc=$_rc1（应 2）缺目录_rc=$_rc2（应 2）"
fi
rm -rf "$F7"

# ── SP-08 负例 词表第二词「处理一下那个 bug」→ rc=1 ──────────────────────────
F8="$(mktemp -d "${TMPDIR:-/tmp}/sp8.XXXXXX")"
make_plan "$F8" '- [ ] 处理一下那个 bug'
_o="$(bash "$CHECKER" "$F8" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ]; then
    ok 08 "负例「处理一下那个 bug」→ rc=1（词表第二词命中）"
else
    bad 08 "词表第二词未拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F8"

# ── SP-09 判定面边界: Phase 段外「其他段」含模糊词 checkbox → rc=0 ───────────
F9="$(mktemp -d "${TMPDIR:-/tmp}/sp9.XXXXXX")"
make_plan "$F9" '- [ ] 在 src/auth.ts:42 增加 token 空值校验并跑 bun test' \
               '- [ ] 看看日志'
_o="$(bash "$CHECKER" "$F9" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ]; then
    ok 09 "Phase 段外「其他段」含模糊词 checkbox → rc=0（判定面只认 Phase 段，散文不误报）"
else
    bad 09 "段外散文被误拦: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F9"

# ── SP-10 正例 模糊动词「跑一下测试」+ 命令锚「bun test」→ rc=0 ──────────────
F10="$(mktemp -d "${TMPDIR:-/tmp}/sp10.XXXXXX")"
make_plan "$F10" '- [ ] 跑一下测试，执行 bun test'
_o="$(bash "$CHECKER" "$F10" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ]; then
    ok 10 "模糊动词+命令锚（跑一下测试，执行 bun test）→ rc=0（有锚即放行，动词模糊≠占位）"
else
    bad 10 "命令锚未豁免: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F10"

echo "----------------------------------------------------------------"
echo "[selftest-step-placeholders] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
