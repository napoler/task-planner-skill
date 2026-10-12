#!/usr/bin/env bash
# selftest-template-lifecycle.sh — task-v074 P4-S2: Rule 34 模板生命周期静态守护
# [task-v171 2026-10-12 锚修复] Rule 34/37 随模板域收编入 plan-template-kit（条款断言 target=CRIT_T）；Rule 48 随纪律域
#   收编入 task-discipline（TL-24 target=CRIT_D）；SKILL 联动断言 target=核心卫星路由表行（TL-14）+ plan-template-kit
#   SKILL.md（TL-15）+ task-discipline SKILL.md（TL-23）。守护面语义零改动，详见锚定义处注释。
# 守护（门控+指针范式, 34.3/34.4 沉淀执行为 LLM 行为面无脚本可测, 仅防条款误删+2 条行为级）:
#   TL-01 critical-rules-template.md 含 Rule 34 头（### 34 模板生命周期）
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
#   TL-17 [task-v074 P9] references/template-guide.md 含 rule-enhancement 且计数含「29 个」（四点同步第 4 落点防腐化；task-v115 videop1 回流 12 类 17→29）
#   TL-18 [task-v085 S8] references/template-mapping.md 含 §九 机制适用性矩阵（Rule 37 权威源, 防腐化）
#   TL-19 [task-v112] templates/delivery-summary.md 存在且五要素区块标题计数 = 5（grep -cE '^## [1-5]\.' 实测）
#   TL-20 [task-v112] SKILL.md 含 delivery-summary 指针行 ≥2 处（终验交付段指针 + References 表行）
#   TL-21 [task-v112] plan-template-kit/references/template-guide.md 口径句含 delivery-summary.md（不入口径表述在位）
#   TL-22 [task-v123] templates/delivery-summary.md 可定位性硬规则三锚在位（Rule 48.5: 可定位性硬规则/反模式/定位三要素）
#   TL-23 [task-v123] [task-v171 锚修复] task-discipline SKILL.md 规则索引含 Rule 48 可定位性行（Rule 48.5 机制）
#   TL-24 [task-v123] [task-v171 锚修复] task-discipline critical-rules Rule 48 子条 ≥5 且 48.5「零新 config 键」声明在位（Rule 48.5 机制）
# 24 断言全 PASS exit 0; 任一 FAIL exit 1。行为级 2 条测试产物在 mktemp 目录, 用完即清理。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
# [task-v171 分层收编 2026-10-12 锚修复] 现象: TL-01..07/14/15/23/24 FAIL（grep 目标核心 critical-rules.md/SKILL.md 已无目标文本）｜
# 根因: Rule 34/37 随模板域收编入 plan-template-kit（S25）；Rule 48 随纪律域收编入 task-discipline（S18）；
#   核心 SKILL.md 瘦身（S33）删除 C22 合规行、「模板选取门控与沉淀」段、「可定位性（Rule 48）」括注（Rule 82）｜
# 修法（只改断言 target，断言语义零改动——守护面=规则条款层+SKILL 消费层在位）:
#   TL-01..07 条款断言改指 CRIT_T（critical-rules-template.md:11-21，逐字 verified）；
#   TL-24 Rule 48 子条+零新键声明改指 CRIT_D（critical-rules-discipline.md:208/216，verified）；
#   TL-14 改指核心 SKILL.md 卫星路由表 plan-template-kit 行（原 C22 合规行后继面）；
#   TL-15 改指 plan-template-kit SKILL.md「沉淀指针（Rule 34）」段（原核心「模板选取门控与沉淀」段后继面）；
#   TL-23 改指 task-discipline SKILL.md 规则索引「| 48 | 交付总结可定位性…」行（原核心 SKILL 可定位性括注后继面）。
CRIT_T="$SKILL_ROOT/../plan-template-kit/references/critical-rules-template.md"
CRIT_D="$SKILL_ROOT/../task-discipline/references/critical-rules-discipline.md"
TPL_SKILL="$SKILL_ROOT/../plan-template-kit/SKILL.md"
DISC_SKILL="$SKILL_ROOT/../task-discipline/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
CTT="$SKILL_ROOT/scripts/check-template-type.sh"
ATTEST="$SKILL_ROOT/scripts/attest-plan.sh"
INIT="$SKILL_ROOT/scripts/init-session.sh"
SKILL="$SKILL_ROOT/SKILL.md"
TMAP="$SKILL_ROOT/../plan-template-kit/references/template-mapping.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'TL-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'TL-%s FAIL %s\n' "$1" "$2"; }

# TL-01
if grep -q '^### 34 模板生命周期' "$CRIT_T"; then ok 01 "Rule 34 头"; else bad 01 "Rule 34 头缺失"; fi
# TL-02
if grep '^34\.1 ' "$CRIT_T" | grep -q 'check-template-type' && grep '^34\.1 ' "$CRIT_T" | grep -q 'general'; then ok 02 "34.1 选取门控"; else bad 02 "34.1 门控缺失"; fi
# TL-03
if grep '^34\.2 ' "$CRIT_T" | grep -q '四点同步' && grep '^34\.2 ' "$CRIT_T" | grep -q 'template-mapping' && grep '^34\.2 ' "$CRIT_T" | grep -q 'plan-writer' && grep '^34\.2 ' "$CRIT_T" | grep -q 'template-guide'; then ok 03 "34.2 四点同步"; else bad 03 "34.2 同步纪律缺失"; fi
# TL-04
r343="$(grep '^34\.3 ' "$CRIT_T")"
if printf '%s' "$r343" | grep -q 'INDEX.md' && printf '%s' "$r343" | grep -q 'ledger' && printf '%s' "$r343" | grep -q '点名'; then ok 04 "34.3 沉淀触发三条件"; else bad 04 "34.3 触发条件缺失"; fi
# TL-05
if grep '^34\.4 ' "$CRIT_T" | grep -q '≤100 行' && grep '^34\.4 ' "$CRIT_T" | grep -q 'Decisions Made'; then ok 05 "34.4 沉淀流程（≤100 行+登记）"; else bad 05 "34.4 沉淀流程缺失"; fi
# TL-06
if grep '^34\.5 ' "$CRIT_T" | grep -q '查重' && grep '^34\.5 ' "$CRIT_T" | grep -q '禁重复沉淀'; then ok 06 "34.5 防滥用（查重）"; else bad 06 "34.5 防滥用缺失"; fi
# TL-07
if grep '^34\.6 ' "$CRIT_T" | grep -q 'template_gate_enforce' && grep '^34\.6 ' "$CRIT_T" | grep -q 'check-template-type' && grep '^34\.6 ' "$CRIT_T" | grep -q 'selftest-template-lifecycle'; then ok 07 "34.6 机制（开关键+门控+selftest）"; else bad 07 "34.6 机制缺失"; fi
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
# [task-v171 2026-10-12 锚修复] 原行为=核心 SKILL.md grep「| C22 |」检查清单行；C 清单随 S33 瘦身删除，
# 后继权威面=核心 SKILL.md 卫星路由表 plan-template-kit 行（「模板选取/沉淀入库/难度分级/轻量档判定（Rule 16,34,37,38）」）。
# 语义不变（核心 SKILL 对 Rule 34 模板生命周期的路由落位在位）。
if grep -q '模板选取/沉淀入库' "$SKILL"; then ok 14 "核心 SKILL.md 卫星路由表 plan-template-kit 行（Rule 34 落位）"; else bad 14 "核心 SKILL.md 卫星路由表缺 plan-template-kit 行（Rule 34 落位）"; fi
# TL-15
# [task-v171 2026-10-12 锚修复] 原行为=核心 SKILL.md grep「模板选取门控与沉淀」联动段；S33 瘦身后非核心域展开禁入核心（Rule 82），
# 后继权威面=plan-template-kit SKILL.md「沉淀指针（Rule 34）」段（模板生命周期域的 SKILL 消费面）。语义不变（模板门控与沉淀联动段在位）。
if grep -q '沉淀指针（Rule 34）' "$TPL_SKILL"; then ok 15 "plan-template-kit SKILL.md「沉淀指针（Rule 34）」段"; else bad 15 "plan-template-kit SKILL.md 缺「沉淀指针（Rule 34）」段"; fi
# TL-16
if grep -q 'check-template-type' "$TMAP" && grep -q 'Rule 34' "$TMAP"; then ok 16 "template-mapping.md Rule 34 门控提示"; else bad 16 "template-mapping.md 缺 Rule 34 门控提示"; fi
# TL-17
# [task-v095 P3] template-guide 迁至卫星 plan-template-kit，路径与计数断言跟随迁移
TGUIDE="$SKILL_ROOT/../plan-template-kit/references/template-guide.md"
if grep -q 'rule-enhancement' "$TGUIDE" && grep -q '29 个' "$TGUIDE"; then ok 17 "template-guide.md 含 rule-enhancement 且计数 29 个"; else bad 17 "template-guide.md 缺 rule-enhancement/计数 29 个（四点同步第 4 落点腐化）"; fi
# TL-18
if grep -q '^## 九、' "$TMAP"; then ok 18 "template-mapping.md 含 §九 机制适用性矩阵"; else bad 18 "template-mapping.md 缺 §九 机制适用性矩阵（Rule 37 权威源误删）"; fi
# TL-19 [task-v112] delivery-summary.md 存在且五要素区块齐备
TDEL="$SKILL_ROOT/templates/delivery-summary.md"
if [ -f "$TDEL" ] && [ "$(grep -cE '^## [1-5]\.' "$TDEL")" = "5" ]; then ok 19 "delivery-summary.md 存在且五区块=5"; else bad 19 "delivery-summary.md 缺失或五要素区块计数≠5"; fi
# TL-20 [task-v112] SKILL.md delivery-summary 指针行 ≥2 处（终验段指针 + References 行）
if [ "$(grep -c 'delivery-summary' "$SKILL")" -ge 2 ]; then ok 20 "SKILL.md 含 delivery-summary 指针 ≥2"; else bad 20 "SKILL.md delivery-summary 指针 <2"; fi
# TL-21 [task-v112] template-guide.md 口径句含 delivery-summary.md（不入口径表述）
if grep -q 'delivery-summary.md' "$TGUIDE"; then ok 21 "template-guide.md 口径句含 delivery-summary.md"; else bad 21 "template-guide.md 口径句缺 delivery-summary.md"; fi
# TL-22 [task-v123] delivery-summary.md 可定位性硬规则三锚（Rule 48.5）
if [ -f "$TDEL" ] && grep -q '可定位性硬规则' "$TDEL" && grep -q '反模式' "$TDEL" && grep -q '定位三要素' "$TDEL"; then ok 22 "delivery-summary.md 三锚（硬规则/反模式/定位三要素）在位"; else bad 22 "delivery-summary.md 缺可定位性锚（硬规则/反模式/定位三要素）"; fi
# TL-23 [task-v123] SKILL.md 终验段可定位性括注锚
# [task-v171 2026-10-12 锚修复] 原行为=核心 SKILL.md grep「可定位性（Rule 48）」括注；Rule 48 随纪律域收编入 task-discipline，
# S33 后该括注不在核心 SKILL（Rule 82），后继权威面=task-discipline SKILL.md 规则索引「| 48 | 交付总结可定位性与实用性」行。
# 语义不变（Rule 48 可定位性机制在归属域 SKILL 的索引落位在位）。
if grep -E '^\| 48 ' "$DISC_SKILL" | grep -q '可定位性'; then ok 23 "task-discipline SKILL.md 规则索引「| 48 | 交付总结可定位性」行"; else bad 23 "task-discipline SKILL.md 规则索引缺 Rule 48 可定位性行"; fi
# TL-24 [task-v123] critical-rules.md Rule 48 子条 ≥5 + 零新键声明
# [task-v171 2026-10-12 锚修复] 原行为=核心 critical-rules.md grep Rule 48 子条/零新键声明；Rule 48 随纪律域收编入
#   task-discipline（critical-rules-discipline.md:208），条款断言改指 CRIT_D。语义零改动（48.1-48.5 五子条+零新键声明在位）。
if [ "$(grep -cE '^48\.[1-5]' "$CRIT_D")" -ge 5 ] && grep -q '48\.5.*零新 config 键' "$CRIT_D"; then ok 24 "Rule 48 子条≥5 且 48.5 零新键声明在位（task-discipline 域）"; else bad 24 "Rule 48 子条不足或零新键声明缺失"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
