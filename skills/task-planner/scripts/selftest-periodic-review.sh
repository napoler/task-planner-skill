#!/usr/bin/env bash
# selftest-periodic-review.sh — Rule 57 周期性回顾与前后对照静态守护
# task-v142 P3-S1
# 断言 ID：PR-01 到 PR-10
# 全 PASS exit 0; 任一 FAIL exit 1
# 只读，不修改任何文件

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CRIT="$SKILL_ROOT/references/critical-rules.md"
CONFIG="$SKILL_ROOT/config.json"
REGISTRY="$SCRIPT_DIR/selftest-registry.tsv"
SKILL_MD="$SKILL_ROOT/SKILL.md"
PERIODIC_REVIEW="$SCRIPT_DIR/periodic-review.sh"

PASS=0
FAIL=0

ok() {
  echo "$1 PASS $2"
  PASS=$((PASS + 1))
}

bad() {
  echo "$1 FAIL $2"
  FAIL=$((FAIL + 1))
}

# PR-01: Rule 57 条款存在
if grep -q '^### 57 ' "$CRIT"; then
  ok "PR-01" "Rule 57 条款存在"
else
  bad "PR-01" "Rule 57 条款缺失"
fi

# PR-02: Rule 57 含触发时机
if grep -q '触发时机' "$CRIT"; then
  ok "PR-02" "Rule 57 含触发时机"
else
  bad "PR-02" "Rule 57 触发时机缺失"
fi

# PR-03: Rule 57 含前后对照检查维度
if grep -q '前后对照' "$CRIT"; then
  ok "PR-03" "Rule 57 含前后对照检查维度"
else
  bad "PR-03" "Rule 57 前后对照检查维度缺失"
fi

# PR-04: Rule 57 含自动纠正机制
if grep -q '自动纠正' "$CRIT"; then
  ok "PR-04" "Rule 57 含自动纠正机制"
else
  bad "PR-04" "Rule 57 自动纠正机制缺失"
fi

# PR-05: Rule 57 含开关键
if grep -q 'periodic_review_enforce' "$CRIT"; then
  ok "PR-05" "Rule 57 含开关键"
else
  bad "PR-05" "Rule 57 开关键缺失"
fi

# PR-06: periodic-review.sh 存在且可执行
if [ -x "$PERIODIC_REVIEW" ]; then
  ok "PR-06" "periodic-review.sh 存在且可执行"
else
  bad "PR-06" "periodic-review.sh 缺失或不可执行"
fi

# PR-07: config.json 有 periodic_review_enforce 键
if jq -e '.properties.periodic_review_enforce' "$CONFIG" >/dev/null 2>&1; then
  ok "PR-07" "config.json 有 periodic_review_enforce 键"
else
  bad "PR-07" "config.json periodic_review_enforce 键缺失"
fi

# PR-08: config.json 有 periodic_review_interval_calls 键
if jq -e '.properties.periodic_review_interval_calls' "$CONFIG" >/dev/null 2>&1; then
  ok "PR-08" "config.json 有 periodic_review_interval_calls 键"
else
  bad "PR-08" "config.json periodic_review_interval_calls 键缺失"
fi

# PR-09: selftest-registry.tsv 有注册
if grep -q 'selftest-periodic-review.sh' "$REGISTRY"; then
  ok "PR-09" "selftest-registry.tsv 有注册"
else
  bad "PR-09" "selftest-registry.tsv 注册缺失"
fi

# PR-10: SKILL.md 有 C39 引用
if grep -q 'C39' "$SKILL_MD"; then
  ok "PR-10" "SKILL.md 有 C39 引用"
else
  bad "PR-10" "SKILL.md C39 引用缺失"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS + FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
