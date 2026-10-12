#!/bin/bash
# selftest-user-instruction-priority.sh — Rule 56 静态守护
# 守护 56.1-56.5 条款锚 + SKILL 联动锚 + 零新键声明
# [2026-10-06 task-v140] 新增

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(dirname "$SCRIPT_DIR")"
CRITICAL_RULES="$SKILL_ROOT/references/critical-rules.md"
# [task-v171 纪律域搬迁 2026-10-12] Rule 56（用户指令优先与自动执行）属纪律域，56.1-56.5 原文已迁至
#   skills/task-discipline/references/critical-rules-discipline.md（核心 critical-rules.md 只剩 11 条核心规则）；
#   56.1-56.5 条款锚与零新键声明的 CRITICAL_RULES 断言改指 CRIT_D，CRITICAL_RULES 保留指向核心。断言语义零改动。
CRIT_D="$SKILL_ROOT/../task-discipline/references/critical-rules-discipline.md"
SKILL_MD="$SKILL_ROOT/SKILL.md"

FAIL=0

check() {
    local cmd="$1"
    local label="$2"
    if eval "$cmd" >/dev/null 2>&1; then
        echo "✓ $label"
    else
        echo "✗ $label"
        FAIL=1
    fi
}

echo "=== selftest-user-instruction-priority (Rule 56) ==="

# 56.1-56.5 条款锚
check "grep -q '56\.1.*默认自动执行' \"$CRIT_D\"" "56.1 默认自动执行"
check "grep -q '56\.2.*人工审查的触发条件' \"$CRIT_D\"" "56.2 人工审查的触发条件"
check "grep -q '56\.3.*禁止自行添加人工审查' \"$CRIT_D\"" "56.3 禁止自行添加人工审查"
check "grep -q '56\.4.*用户明确说.*不要人工审查.*时.*技能必须遵守' \"$CRIT_D\"" "56.4 用户明确说不要人工审查时技能必须遵守"
check "grep -q '56\.5.*机制' \"$CRIT_D\"" "56.5 机制"

# SKILL 联动锚 [task-v171 核心瘦身]：Rule 56（纪律域）摘要 bullet 随瘦身退役 → 卫星路由表 task-discipline 行枚举 56
#   现象：SKILL.md 瘦身后 '56.*用户指令优先与自动执行' 联动字面零命中（Rule 56 属纪律域，SKILL 侧仅存卫星路由表行），
#     本断言恒 FAIL。
#   根因：非核心域规则摘要/C 行随瘦身退役（Rule 82 禁回潮）；SKILL 侧入口=卫星路由表 discipline 行
#     （56 以区间 53-57 形态覆盖，无整串，用行内含 56 编号断言）。
#   修法：改断言路由表 discipline 行在位（≥1；56 以区间 53-57 形态覆盖，无独立编号字面，逐编号匹配不适用于区间路由表），
#     条款本体锚由 CRIT_D 56.1-56.5 守护（上方既有断言）。
check "grep -qE '^\| task-discipline \|' \"$SKILL_MD\"" "SKILL 联动锚（卫星路由表 discipline 行，区间 53-57 覆盖 Rule 56）"

# 零新键声明
check "grep -q '零新 config 键' \"$CRIT_D\" && grep -q '56' \"$CRIT_D\"" "零新键声明"

if [ "$FAIL" -eq 0 ]; then
    echo "=== ALL PASS ==="
    exit 0
else
    echo "=== FAIL ==="
    exit 1
fi
