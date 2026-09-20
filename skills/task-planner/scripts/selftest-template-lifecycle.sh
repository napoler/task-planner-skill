#!/usr/bin/env bash
# selftest-template-lifecycle.sh — task-v074 P4-S2: Rule 34 模板生命周期静态守护
# 守护（门控+指针范式, 34.3/34.4 沉淀执行为 LLM 行为面无脚本可测, 仅防条款误删+2 条行为级）:
#   TL-01 critical-rules.md 含 Rule 34 头（### 34 模板生命周期）
#   TL-02 含 34.1 选取门控（check-template-type.sh + 白名单动态派生 + general）
#   TL-03 含 34.2 四点同步（template-mapping/plan-writer/SKILL/template-guide 四落点）
#   TL-04 含 34.3 沉淀触发三条件（INDEX+ledger / 类型空缺 / 用户点名）
#   TL-05 含 34.4 沉淀流程（≤100 行新模板 + Decisions Made 登记）
#   TL-06 含 34.5 防滥用（查重 + 禁重复沉淀）
#   TL-07 含 34.6 机制（template_gate_enforce + check-template-type + selftest-template-lifecycle）
#   TL-08 config.json template_gate_enforce 键（默认 warn, enum 三档）
#   TL-09 check-template-type.sh 存在且白名单动态派生（variant ls 派生 + general 兜底, 无硬编码 12 类副本）
#   TL-10 attest-plan.sh 含 check-template-type 调用与 --skip-template-check 逃生
#   TL-11 init-session.sh 含 TASK_TEMPLATE_TYPE env 兜底 + variant 目录 ls 动态派生（P4-S1 产出）
#   TL-12 行为: check-template-type.sh 对 template_type=bugfix 计划 exit 0
#   TL-13 行为: check-template-type.sh 对 template_type=nonexistent 计划 exit 1（测试产物 /tmp 清理）
#   TL-14 SKILL.md 检查清单含 C22 行（Rule 34 attest 门控+沉淀）
#   TL-15 SKILL.md 含「模板选取门控与沉淀」联动段
#   TL-16 references/template-mapping.md 含 Rule 34 门控提示
#   TL-17 [task-v074 P9] references/template-guide.md 含 rule-enhancement 且计数含「13 个」（四点同步第 4 落点防腐化）
#   TL-18 [task-v085 S8] references/template-mapping.md 含 §九 机制适用性矩阵（Rule 37 权威源, 防腐化）
# 18 断言全 PASS exit 0; 任一 FAIL exit 1。行为级 2 条测试产物在 mktemp 目录, 用完即清理。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
CONFIG="$SKILL_ROOT/config.json"
CTT="$SKILL_ROOT/scripts/check-template-type.sh"
ATTEST="$SKILL_ROOT/scripts/attest-plan.sh"
INIT="$SKILL_ROOT/scripts/init-session.sh"
SKILL="$SKILL_ROOT/SKILL.md"
TMAP="$SKILL_ROOT/references/template-mapping.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'TL-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'TL-%s FAIL %s\n' "$1" "$2"; }

# TL-01
if grep -q '^### 34 模板生命周期' "$CRIT"; then ok 01 "Rule 34 头"; else bad 01 "Rule 34 头缺失"; fi
# TL-02
if grep '^34\.1 ' "$CRIT" | grep -q 'check-template-type' && grep '^34\.1 ' "$CRIT" | grep -q 'general'; then ok 02 "34.1 选取门控"; else bad 02 "34.1 门控缺失"; fi
# TL-03
if grep '^34\.2 ' "$CRIT" | grep -q '四点同步' && grep '^34\.2 ' "$CRIT" | grep -q 'template-mapping' && grep '^34\.2 ' "$CRIT" | grep -q 'plan-writer' && grep '^34\.2 ' "$CRIT" | grep -q 'template-guide'; then ok 03 "34.2 四点同步"; else bad 03 "34.2 同步纪律缺失"; fi
# TL-04
r343="$(grep '^34\.3 ' "$CRIT")"
if printf '%s' "$r343" | grep -q 'INDEX.md' && printf '%s' "$r343" | grep -q 'ledger' && printf '%s' "$r343" | grep -q '点名'; then ok 04 "34.3 沉淀触发三条件"; else bad 04 "34.3 触发条件缺失"; fi
# TL-05
if grep '^34\.4 ' "$CRIT" | grep -q '≤100 行' && grep '^34\.4 ' "$CRIT" | grep -q 'Decisions Made'; then ok 05 "34.4 沉淀流程（≤100 行+登记）"; else bad 05 "34.4 沉淀流程缺失"; fi
# TL-06
if grep '^34\.5 ' "$CRIT" | grep -q '查重' && grep '^34\.5 ' "$CRIT" | grep -q '禁重复沉淀'; then ok 06 "34.5 防滥用（查重）"; else bad 06 "34.5 防滥用缺失"; fi
# TL-07
if grep '^34\.6 ' "$CRIT" | grep -q 'template_gate_enforce' && grep '^34\.6 ' "$CRIT" | grep -q 'check-template-type' && grep '^34\.6 ' "$CRIT" | grep -q 'selftest-template-lifecycle'; then ok 07 "34.6 机制（开关键+门控+selftest）"; else bad 07 "34.6 机制缺失"; fi
# TL-08
if jq -e '.properties.template_gate_enforce | .default=="warn" and ((.enum|sort)|. == ["enforce","off","warn"])' "$CONFIG" >/dev/null 2>&1; then
  ok 08 "config.json template_gate_enforce（warn 默认+三档）"
else
  bad 08 "config.json template_gate_enforce 缺失/默认非 warn/enum 非三档"
fi
# TL-09
[ -f "$CTT" ] && grep -q 'variant' "$CTT" && grep -q 'general' "$CTT" && grep -q 'ls ' "$CTT" && ! grep -q 'research diagnostic' "$CTT" \
  && ok 09 "check-template-type.sh 动态派生白名单" || bad 09 "check-template-type.sh 缺失/硬编码白名单副本"
# TL-10
if grep -q 'check-template-type' "$ATTEST" && grep -q -- '--skip-template-check' "$ATTEST"; then ok 10 "attest 集成门控+逃生"; else bad 10 "attest 缺门控集成"; fi
# TL-11
if grep -q 'TASK_TEMPLATE_TYPE' "$INIT" && grep -q 'variant' "$INIT" && grep -q 'ls ' "$INIT"; then ok 11 "init-session env 兜底+动态派生"; else bad 11 "init-session 缺 env/动态派生"; fi
# TL-12/13 行为级（/tmp 测试计划, 用完即清理）
T=$(mktemp -d /tmp/tl-selftest.XXXXXX)
printf '%s\n' "---" "template_type: bugfix" "---" > "$T/plan-bugfix.md"
printf '%s\n' "---" "template_type: nonexistent" "---" > "$T/plan-bad.md"
if bash "$CTT" "$T/plan-bugfix.md" >/dev/null 2>&1; then ok 12 "行为: bugfix 计划 exit 0"; else bad 12 "行为: bugfix 计划未 exit 0"; fi
if bash "$CTT" "$T/plan-bad.md" >/dev/null 2>&1; then bad 13 "行为: nonexistent 计划应 exit 1 却 exit 0"; else ok 13 "行为: nonexistent 计划 exit 1"; fi
rm -rf "$T"
# TL-14
if grep -q '^| C22 ' "$SKILL"; then ok 14 "SKILL.md 检查清单 C22 行"; else bad 14 "SKILL.md 缺 C22 行"; fi
# TL-15
if grep -q '模板选取门控与沉淀' "$SKILL"; then ok 15 "SKILL.md「模板选取门控与沉淀」段"; else bad 15 "SKILL.md 缺「模板选取门控与沉淀」段"; fi
# TL-16
if grep -q 'check-template-type' "$TMAP" && grep -q 'Rule 34' "$TMAP"; then ok 16 "template-mapping.md Rule 34 门控提示"; else bad 16 "template-mapping.md 缺 Rule 34 门控提示"; fi
# TL-17
TGUIDE="$SKILL_ROOT/references/template-guide.md"
if grep -q 'rule-enhancement' "$TGUIDE" && grep -q '13 个' "$TGUIDE"; then ok 17 "template-guide.md 含 rule-enhancement 且计数 13 个"; else bad 17 "template-guide.md 缺 rule-enhancement/计数 13 个（四点同步第 4 落点腐化）"; fi
# TL-18
if grep -q '^## 九、' "$TMAP"; then ok 18 "template-mapping.md 含 §九 机制适用性矩阵"; else bad 18 "template-mapping.md 缺 §九 机制适用性矩阵（Rule 37 权威源误删）"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
