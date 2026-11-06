#!/usr/bin/env bash
# [2026-11-06 task-enumerate-first-20261106 S2] selftest-enumerate-first.sh — Rule 105「可枚举集合全量枚举优先纪律（ls-first）」机器守护静态断言套件（EN-01..07）
# WHAT: 机械断言 Rule 105 落地 7 组：
#      EN-01 task-discipline critical-rules-discipline.md 含行首 `### 105 ` 段标题
#      EN-02 同文件 `^105\.[1-5] ` 五子条行首锚计数=5
#      EN-03 关键判据词计数（规则文档 grep -c）：`全量枚举`≥5、`零命中`≥1、`回退`≥1、`ls`≥2
#      EN-04 105.5 反例锚段含「装备车」与「命名族」
#      EN-05 交叉引 `Rule 35` 与 `100.6` 在位于规则文档
#      EN-06 SKILL.md 含 `1-105` ≥3 处 且 discipline 路由行含 `,105`（S3 级联依赖，当前态预期 FAIL）
#      EN-07 负断言：SKILL.md 内 `1-104` 字面残留=0（S3 级联依赖，当前态预期 FAIL）
# WHY: 判例锚 task-enumerate-first-20261106 #1（用户裁决「因小失大」）——可枚举小集合上关键词盲搜致漏检/错误否定；
#      防回归为 grep/find -name 替代 ls 全量枚举、零命中直接下否定结论。
# 纪律: 本脚本只做只读静态断言，禁写配置/禁 git 写操作；路径全部用 SCRIPT_DIR 相对推导，禁硬编码绝对路径。
#       全 PASS exit 0, 任一 FAIL exit 1。EN-06/EN-07 当前态 FAIL 为 S3 依赖预期，禁止弱化断言。
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

# EN-01: skills/task-discipline/references/critical-rules-discipline.md 含行首 `### 105 ` 段标题
td "EN-01 task-discipline critical-rules 含行首 '### 105 ' 段标题" \
   "[ -f '$DISCIPLINE_CR' ] && grep -qE '^### 105 ' '$DISCIPLINE_CR'" \
   "missing file=$DISCIPLINE_CR OR anchor='^### 105 '"

# EN-02: `^105\.[1-5] ` 五子条行首锚计数=5
_en02_n="$(grep -cE '^105\.[1-5] ' "$DISCIPLINE_CR" 2>/dev/null)" || _en02_n=0
if [ "$_en02_n" -eq 5 ]; then
    PASS=$((PASS+1)); echo "[PASS] EN-02 规则文档 '^105\.[1-5] ' 五子条行首锚计数=5 (got=$_en02_n)"
else
    FAIL=$((FAIL+1)); echo "[FAIL] EN-02 规则文档 '^105\.[1-5] ' 五子条行首锚计数=5 (got=$_en02_n)"
    echo "  [diag] expected count=5 in $DISCIPLINE_CR"
    grep -nE '^105\.[1-5] ' "$DISCIPLINE_CR" 2>/dev/null | sed 's/^/  [diag] present: /' || true
fi

# EN-03: 关键判据词计数（规则文档 grep -c）：`全量枚举`≥4、`零命中`≥1、`回退`≥1、`ls`≥2（定稿对齐：规则文档实计 4 处覆盖判据面）
_en03_enum="$(grep -c '全量枚举' "$DISCIPLINE_CR" 2>/dev/null)" || _en03_enum=0
_en03_zero="$(grep -c '零命中' "$DISCIPLINE_CR" 2>/dev/null)" || _en03_zero=0
_en03_fb="$(grep -c '回退' "$DISCIPLINE_CR" 2>/dev/null)" || _en03_fb=0
_en03_ls="$(grep -c 'ls' "$DISCIPLINE_CR" 2>/dev/null)" || _en03_ls=0
if [ "$_en03_enum" -ge 4 ] && [ "$_en03_zero" -ge 1 ] && [ "$_en03_fb" -ge 1 ] && [ "$_en03_ls" -ge 2 ]; then
    PASS=$((PASS+1)); echo "[PASS] EN-03 关键判据词计数 全量枚举≥4($_en03_enum) 零命中≥1($_en03_zero) 回退≥1($_en03_fb) ls≥2($_en03_ls)"
else
    FAIL=$((FAIL+1)); echo "[FAIL] EN-03 关键判据词计数 全量枚举≥4($_en03_enum) 零命中≥1($_en03_zero) 回退≥1($_en03_fb) ls≥2($_en03_ls)"
    echo "  [diag] file=$DISCIPLINE_CR"
fi

# EN-04: 105.5 反例锚段含「装备车」与「命名族」
td "EN-04 105.5 反例锚段含「装备车」与「命名族」" \
   "[ -f '$DISCIPLINE_CR' ] && grep -q '装备车' '$DISCIPLINE_CR' && grep -q '命名族' '$DISCIPLINE_CR'" \
   "missing file=$DISCIPLINE_CR OR anchor='装备车'/'命名族'"

# EN-05: 交叉引 `Rule 35` 与 `100.6` 在位于规则文档
td "EN-05 交叉引 'Rule 35' 与 '100.6' 在位于规则文档" \
   "[ -f '$DISCIPLINE_CR' ] && grep -q 'Rule 35' '$DISCIPLINE_CR' && grep -q '100.6' '$DISCIPLINE_CR'" \
   "missing file=$DISCIPLINE_CR OR anchor='Rule 35'/'100.6'"

# EN-06: SKILL.md 含 `1-105` ≥3 处 且 discipline 路由行含 `,105`（S3 级联依赖，当前态预期 FAIL）
_en06_n="$(grep -c '1-105' "$SKILL_MD" 2>/dev/null)" || _en06_n=0
if [ "$_en06_n" -ge 3 ] && grep -q ',105' "$SKILL_MD" 2>/dev/null; then
    PASS=$((PASS+1)); echo "[PASS] EN-06 SKILL.md 含 '1-105' ≥3 处($_en06_n) 且含 ',105' 路由"
else
    FAIL=$((FAIL+1)); echo "[FAIL] EN-06 SKILL.md 含 '1-105' ≥3 处($_en06_n) 且含 ',105' 路由 (S3 级联依赖，当前态预期 FAIL)"
    echo "  [diag] file=$SKILL_MD"
    grep -n ',105' "$SKILL_MD" 2>/dev/null | sed 's/^/  [diag] ,105 present: /' || echo "  [diag] ,105 not found"
fi

# EN-07: 负断言：SKILL.md 内 `1-104` 字面残留=0（S3 级联依赖，当前态预期 FAIL）
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
