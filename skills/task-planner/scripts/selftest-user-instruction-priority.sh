#!/bin/bash
# selftest-user-instruction-priority.sh — Rule 56 静态守护
# 守护 56.1-56.5 条款锚 + SKILL 联动锚 + 零新键声明
# [2026-10-06 task-v140] 新增

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(dirname "$SCRIPT_DIR")"
CRITICAL_RULES="$SKILL_ROOT/references/critical-rules.md"
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
check "grep -q '56\.1.*默认自动执行' \"$CRITICAL_RULES\"" "56.1 默认自动执行"
check "grep -q '56\.2.*人工审查的触发条件' \"$CRITICAL_RULES\"" "56.2 人工审查的触发条件"
check "grep -q '56\.3.*禁止自行添加人工审查' \"$CRITICAL_RULES\"" "56.3 禁止自行添加人工审查"
check "grep -q '56\.4.*用户明确说.*不要人工审查.*时.*技能必须遵守' \"$CRITICAL_RULES\"" "56.4 用户明确说不要人工审查时技能必须遵守"
check "grep -q '56\.5.*机制' \"$CRITICAL_RULES\"" "56.5 机制"

# SKILL 联动锚
check "grep -q '56.*用户指令优先与自动执行' \"$SKILL_MD\"" "SKILL 联动锚"

# 零新键声明
check "grep -q '零新 config 键' \"$CRITICAL_RULES\" && grep -q '56' \"$CRITICAL_RULES\"" "零新键声明"

if [ "$FAIL" -eq 0 ]; then
    echo "=== ALL PASS ==="
    exit 0
else
    echo "=== FAIL ==="
    exit 1
fi
