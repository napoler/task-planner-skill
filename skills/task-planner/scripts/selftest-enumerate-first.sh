#!/usr/bin/env bash
# [2026-11-06 task-enumerate-first-20261106 S2/R3] selftest-enumerate-first.sh — Rule 105「可枚举集合全量枚举优先纪律（ls-first）」机器守护静态断言套件（EN-01..07）
# WHAT: 机械断言 Rule 105 落地 7 组：
#      EN-01 task-discipline critical-rules-discipline.md 含行首 `### 105 ` 段标题（锚定 SEC105）
#      EN-02 同文件 `^105\.[1-5] ` 五子条行首锚计数=5（锚定 SEC105）
#      EN-03 关键判据词计数（SEC105 grep -c）：`全量枚举`≥4、`零命中`≥1、`回退`≥1、`ls`≥2
#      EN-04 105.5 反例锚段含「装备车」与「命名族」（锚定 SEC105）
#      EN-05 交叉引 `Rule 35` 与 `100.6` 在位于规则文档（锚定 SEC105）
#      EN-06 SKILL.md 含 `1-106` ≥3 处 且 discipline 路由行含 `,106`（全文）
#      EN-07 负断言：SKILL.md 内 `1-104` 字面残留=0（全文）
# WHY: 判例锚 task-enumerate-first-20261106 #1（用户裁决「因小失大」）——可枚举小集合上关键词盲搜致漏检/错误否定；
#      防回归为 grep/find -name 替代 ls 全量枚举、零命中直接下否定结论。
# R3 修复（2026-11-06）：EN-01..05 锚定 Rule 105 段局部文本（SEC105），消除全文 grep 空壳可过风险（I-2）；N-1 头注释与代码阈值对齐（≥4）。
# 纪律: 本脚本只做只读静态断言，禁写配置/禁 git 写操作；路径全部用 SCRIPT_DIR 相对推导，禁硬编码绝对路径。
#       全 PASS exit 0, 任一 FAIL exit 1。禁止弱化断言语义（仅允许纯纪元字面随规则号级联维护）。
# VC-4 自指例外：本脚本 EN-07 负断言实现含 '1-104' 字面——grep 清零验收排除本脚本自身（verification.md R4 注）。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."                    # <repo>/skills/task-planner
DISCIPLINE_CR="$ROOT/../task-discipline/references/critical-rules-discipline.md"
SKILL_MD="$ROOT/SKILL.md"

PASS=0; FAIL=0
t() { # t <name> <cond-expr...>
    local name="$1"; shift
    if "$@" >/dev/null 2>&1; then
        PASS=$((PASS+1)); echo "[PASS] $name"
    else
        FAIL=$((FAIL+1)); echo "[FAIL] $name"
    fi
}
# td: 带诊断输出的断言（失败时打印缺失文件/锚，不吞 stderr）
td() { # td <name> <bash-expr-string> [diag-msg]
    local name="$1" expr="$2" diag="${3:-}"
    if bash -c "$expr" >/dev/null 2>&1; then
        PASS=$((PASS+1)); echo "[PASS] $name"
    else
        FAIL=$((FAIL+1)); echo "[FAIL] $name"
        [ -n "$diag" ] && echo "  [diag] $diag"
    fi
}

# 提取 Rule 105 段局部文本：从 '### 105' 到下一个 '###' 标题前（或 EOF），awk 保证末节不误删（R3：锚定 SEC105 防空壳可过 I-2）
SEC105="$(awk '/^### 105 /{f=1; print; next} f{if(/^### /) exit; print}' "$DISCIPLINE_CR" 2>/dev/null)" || SEC105=""

# EN-01: skills/task-discipline/references/critical-rules-discipline.md 含行首 `### 105 ` 段标题（锚定 SEC105）
if [ -n "$SEC105" ] && printf '%s\n' "$SEC105" | grep -qE '^### 105 '; then
    PASS=$((PASS+1)); echo "[PASS] EN-01 task-discipline critical-rules 含行首 '### 105 ' 段标题(SEC105)"
else
    FAIL=$((FAIL+1)); echo "[FAIL] EN-01 task-discipline critical-rules 含行首 '### 105 ' 段标题(SEC105)"
    echo "  [diag] missing file=$DISCIPLINE_CR OR anchor='^### 105 ' in SEC105"
fi

# EN-02: `^105\.[1-5] ` 五子条行首锚计数=5（锚定 SEC105）
_en02_n="$(printf '%s\n' "$SEC105" | grep -cE '^105\.[1-5] ' 2>/dev/null)" || _en02_n=0
if [ "$_en02_n" -eq 5 ]; then
    PASS=$((PASS+1)); echo "[PASS] EN-02 SEC105 '^105\.[1-5] ' 五子条行首锚计数=5 (got=$_en02_n)"
else
    FAIL=$((FAIL+1)); echo "[FAIL] EN-02 SEC105 '^105\.[1-5] ' 五子条行首锚计数=5 (got=$_en02_n)"
    echo "  [diag] expected count=5 in SEC105 of $DISCIPLINE_CR"
    printf '%s\n' "$SEC105" | grep -nE '^105\.[1-5] ' 2>/dev/null | sed 's/^/  [diag] present: /' || true
fi

# EN-03: 关键判据词计数（SEC105）：`全量枚举`≥4、`零命中`≥1、`回退`≥1、`ls`≥2（定稿对齐：规则文档实计 4 处覆盖判据面）
_en03_enum="$(printf '%s\n' "$SEC105" | grep -c '全量枚举' 2>/dev/null)" || _en03_enum=0
_en03_zero="$(printf '%s\n' "$SEC105" | grep -c '零命中' 2>/dev/null)" || _en03_zero=0
_en03_fb="$(printf '%s\n' "$SEC105" | grep -c '回退' 2>/dev/null)" || _en03_fb=0
_en03_ls="$(printf '%s\n' "$SEC105" | grep -c 'ls' 2>/dev/null)" || _en03_ls=0
if [ "$_en03_enum" -ge 4 ] && [ "$_en03_zero" -ge 1 ] && [ "$_en03_fb" -ge 1 ] && [ "$_en03_ls" -ge 2 ]; then
    PASS=$((PASS+1)); echo "[PASS] EN-03 SEC105 关键判据词计数 全量枚举≥4($_en03_enum) 零命中≥1($_en03_zero) 回退≥1($_en03_fb) ls≥2($_en03_ls)"
else
    FAIL=$((FAIL+1)); echo "[FAIL] EN-03 SEC105 关键判据词计数 全量枚举≥4($_en03_enum) 零命中≥1($_en03_zero) 回退≥1($_en03_fb) ls≥2($_en03_ls)"
    echo "  [diag] file=$DISCIPLINE_CR (SEC105)"
fi

# EN-04: 105.5 反例锚段含「装备车」与「命名族」（锚定 SEC105；直接测试，避免 td/bash -c 子进程丢失 SEC105）
if [ -n "$SEC105" ] && printf '%s\n' "$SEC105" | grep -q '装备车' && printf '%s\n' "$SEC105" | grep -q '命名族'; then
    PASS=$((PASS+1)); echo "[PASS] EN-04 105.5 反例锚段含「装备车」与「命名族」(SEC105)"
else
    FAIL=$((FAIL+1)); echo "[FAIL] EN-04 105.5 反例锚段含「装备车」与「命名族」(SEC105)"
    echo "  [diag] missing SEC105 OR anchor='装备车'/'命名族'"
fi

# EN-05: 交叉引 `Rule 35` 与 `100.6` 在位于规则文档（锚定 SEC105）
if [ -n "$SEC105" ] && printf '%s\n' "$SEC105" | grep -q 'Rule 35' && printf '%s\n' "$SEC105" | grep -q '100.6'; then
    PASS=$((PASS+1)); echo "[PASS] EN-05 交叉引 'Rule 35' 与 '100.6' 在位于SEC105"
else
    FAIL=$((FAIL+1)); echo "[FAIL] EN-05 交叉引 'Rule 35' 与 '100.6' 在位于SEC105"
    echo "  [diag] missing SEC105 OR anchor='Rule 35'/'100.6'"
fi

# EN-06: SKILL.md 含 `1-106` ≥3 处 且 discipline 路由行含 `,106`
_en06_n="$(grep -c '1-106' "$SKILL_MD" 2>/dev/null)" || _en06_n=0
if [ "$_en06_n" -ge 3 ] && grep -q ',106' "$SKILL_MD" 2>/dev/null; then
    PASS=$((PASS+1)); echo "[PASS] EN-06 SKILL.md 含 '1-106' ≥3 处($_en06_n) 且含 ',106' 路由"
else
    FAIL=$((FAIL+1)); echo "[FAIL] EN-06 SKILL.md 含 '1-106' ≥3 处($_en06_n) 且含 ',106' 路由"
    echo "  [diag] file=$SKILL_MD"
    grep -n ',106' "$SKILL_MD" 2>/dev/null | sed 's/^/  [diag] ,106 present: /' || echo "  [diag] ,106 not found"
fi

# EN-07: 负断言：SKILL.md 内 `1-104` 字面残留=0
_en07_n="$(grep -c '1-104' "$SKILL_MD" 2>/dev/null)" || _en07_n=0
if [ "$_en07_n" -eq 0 ]; then
    PASS=$((PASS+1)); echo "[PASS] EN-07 负断言: SKILL.md '1-104' 字面残留=0"
else
    FAIL=$((FAIL+1)); echo "[FAIL] EN-07 负断言: SKILL.md '1-104' 字面残留=0 (got=$_en07_n, S3 级联依赖，当前态预期 FAIL)"
    echo "  [diag] expected 0 hits in $SKILL_MD"
    grep -n '1-104' "$SKILL_MD" 2>/dev/null | sed 's/^/  [diag] hit: /' || true
fi

# ── 汇总（Total/exit 语义对齐既有 selftest 范式）──
TOTAL=$((PASS + FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
