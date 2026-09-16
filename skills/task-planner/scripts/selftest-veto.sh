#!/usr/bin/env bash
# selftest-veto.sh — task-v073: Rule 32 用户否决与禁令追踪静态守护
# 守护（门控+指针范式，裁决消费为 LLM 行为面无脚本可测，仅防条款误删）:
#   VT-01 critical-rules.md 含 32.1 登记条款（语义锚点: veto / 被否决方案）
#   VT-02 含 32.2 计划期必查条款（语义锚点: 必查 / 禁止进入候选）
#   VT-03 含 32.3 执行期消费条款（语义锚点: 选项列表排除 / Recommended）
#   VT-04 含 32.4 解禁条件条款（语义锚点: veto-lift / 新验证证据 / 禁止静默改回）
#   VT-05 含 32.5 机制条款（语义锚点: veto_enforce）
#   VT-06 31.5 消费侧含「被否决方案」阅读联动
#   VT-07 SKILL.md 摘要行含 Rule 32（防摘要漏联动）
#   VT-08 SKILL.md 含 C20 检查项
#   VT-09 SKILL.md 含「用户否决登记」指针
#   VT-10 SKILL.md 含 Rules 1-3[1-6]（宽容锚: P4 时为 1-32, P5 加 Rule 33/34 后改 1-34, S4 加 Rule 35 后改 1-35, [2026-09-17 task-v079] Rule 36 级联后扩至 1-36 仍命中）
#   VT-11 config.json 含 veto_enforce 键（默认 warn，enum 三档）
#   VT-12 templates/notepad-learnings.md 含「被否决方案」段
#   VT-13 SKILL.md D 询问/特判段无「禁令项作 Recommended」矛盾表述（32.3 语义抽查）
# 13 断言全 PASS exit 0; 任一 FAIL exit 1。只读, 不修改任何文件。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
TPL_NOTEPAD="$SKILL_ROOT/templates/notepad-learnings.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'VT-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'VT-%s FAIL %s\n' "$1" "$2"; }

# VT-01
if grep -q '^32\.1 ' "$CRIT" && grep '32\.1' "$CRIT" | grep -q '被否决方案'; then ok 01 "32.1 禁令登记"; else bad 01 "32.1 登记缺失"; fi
# VT-02
if grep -q '^32\.2 ' "$CRIT" && grep '32\.2' "$CRIT" | grep -q '禁止进入候选'; then ok 02 "32.2 计划期必查"; else bad 02 "32.2 必查缺失"; fi
# VT-03
if grep -q '^32\.3 ' "$CRIT" && grep '32\.3' "$CRIT" | grep -q 'Recommended'; then ok 03 "32.3 执行期消费"; else bad 03 "32.3 消费缺失"; fi
# VT-04
if grep -q '^32\.4 ' "$CRIT" && grep '32\.4' "$CRIT" | grep -q 'veto-lift' && grep '32\.4' "$CRIT" | grep -q '静默改回'; then ok 04 "32.4 解禁条件（两条）"; else bad 04 "32.4 解禁缺失"; fi
# VT-05
if grep -q '^32\.5 ' "$CRIT" && grep '32\.5' "$CRIT" | grep -q 'veto_enforce'; then ok 05 "32.5 机制（开关键）"; else bad 05 "32.5 机制缺失"; fi
# VT-06
if grep '^31\.5 ' "$CRIT" | grep -q '被否决方案'; then ok 06 "31.5 消费侧联动 Rule 32"; else bad 06 "31.5 缺被否决方案联动"; fi
# VT-07
if grep -q 'Rule 32' "$SKILLMD" && grep 'Rule 32' "$SKILLMD" | grep -q '用户否决与禁令追踪'; then ok 07 "SKILL.md 摘要行 Rule 32"; else bad 07 "SKILL.md 摘要缺 Rule 32"; fi
# VT-08
if grep -q '| C20 |' "$SKILLMD" && grep 'C20' "$SKILLMD" | grep -q '32.2'; then ok 08 "SKILL.md C20 检查项"; else bad 08 "SKILL.md 缺 C20"; fi
# VT-09
if grep -q '用户否决登记（Rule 32' "$SKILLMD"; then ok 09 "SKILL.md 用户否决登记指针"; else bad 09 "SKILL.md 缺否决登记指针"; fi
# VT-10
if grep -qE 'Rules 1-3[1-6]' "$SKILLMD"; then ok 10 "SKILL.md Rules 1-3x 范围"; else bad 10 "SKILL.md 缺 Rules 1-3x"; fi
# VT-11
if grep -q '"veto_enforce"' "$CONFIG" && python3 -c "
import json,sys
d=json.load(open('$CONFIG'))
k=d['properties']['veto_enforce']
sys.exit(0 if k.get('default')=='warn' and k.get('enum')==['enforce','warn','off'] else 1)" 2>/dev/null; then
  ok 11 "config.json veto_enforce（warn 默认+三档）"
else
  bad 11 "config.json veto_enforce 缺失/默认非 warn"
fi
# VT-12
if grep -q '被否决方案（User Rejected — Rule 32）' "$TPL_NOTEPAD"; then ok 12 "notepad 模板被否决方案段"; else bad 12 "notepad 模板缺被否决方案段"; fi
# VT-13
if ! grep -qE '禁令.{0,8}(可作|作为).{0,6}Recommended' "$SKILLMD"; then ok 13 "无禁令项作 Recommended 矛盾表述"; else bad 13 "发现禁令项可作 Recommended 矛盾表述"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
