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
#   VT-10 SKILL.md 含 Rules 1-3[1-7]（宽容锚: [2026-09-17 task-v079] 扩至 1-36；[2026-09-20 task-v085] Rule 37 级联 1-3[1-7]）[2026-10-08 task-v144 合并级联: SKILL References/索引锚演进 1-62（58/59/60/62 落地）,宽容正则扩 6x 纪元 1-(3[1-9]|[4-6][0-9])][2026-10-10 task-v158 扩 7x 纪元 1-(3[1-9]|[4-7][0-9])][2026-10-11 task-v169 Rule 80 落地 1-80 纪元, 末段字符类 4-7x→4-8x][2026-10-11 task-v070 S10o 扩 81 纪元 1-(3[1-9]|[4-7][0-9]|8[013]([^0-9]|$))^0-9]|$))（Rule 45 注释: Why=task-v170 落地 Rule 81, SKILL.md 实态 Critical Rules 1-81, epoch 上界 80→81; 8x 精化 8[01] 尾边界断言, 负样本 82 不命中）]
#   VT-11 config.json 含 veto_enforce 键（默认 warn，enum 三档）
#   VT-12 templates/notepad-learnings.md 含「被否决方案」段
#   VT-13 SKILL.md D 询问/特判段无「禁令项作 Recommended」矛盾表述（32.3 语义抽查）
# 13 断言全 PASS exit 0; 任一 FAIL exit 1。只读, 不修改任何文件。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
# [task-v171 纪律域搬迁 2026-10-12] Rule 32（用户否决与禁令追踪）与 VT-06 涉及的 Rule 31.5（错误学习闭环
#   消费侧）均属纪律域，原文已迁至 skills/task-discipline/references/critical-rules-discipline.md
#   （核心 critical-rules.md 只剩 11 条核心规则）；VT-01..VT-06 的 CRIT 断言改指 CRIT_D，CRIT 保留指向核心。
#   断言语义零改动。
CRIT_D="$SKILL_ROOT/../task-discipline/references/critical-rules-discipline.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
TPL_NOTEPAD="$SKILL_ROOT/templates/notepad-learnings.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'VT-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'VT-%s FAIL %s\n' "$1" "$2"; }

# VT-01
if grep -q '^32\.1 ' "$CRIT_D" && grep '32\.1' "$CRIT_D" | grep -q '被否决方案'; then ok 01 "32.1 禁令登记"; else bad 01 "32.1 登记缺失"; fi
# VT-02
if grep -q '^32\.2 ' "$CRIT_D" && grep '32\.2' "$CRIT_D" | grep -q '禁止进入候选'; then ok 02 "32.2 计划期必查"; else bad 02 "32.2 必查缺失"; fi
# VT-03
if grep -q '^32\.3 ' "$CRIT_D" && grep '32\.3' "$CRIT_D" | grep -q 'Recommended'; then ok 03 "32.3 执行期消费"; else bad 03 "32.3 消费缺失"; fi
# VT-04
if grep -q '^32\.4 ' "$CRIT_D" && grep '32\.4' "$CRIT_D" | grep -q 'veto-lift' && grep '32\.4' "$CRIT_D" | grep -q '静默改回'; then ok 04 "32.4 解禁条件（两条）"; else bad 04 "32.4 解禁缺失"; fi
# VT-05
if grep -q '^32\.5 ' "$CRIT_D" && grep '32\.5' "$CRIT_D" | grep -q 'veto_enforce'; then ok 05 "32.5 机制（开关键）"; else bad 05 "32.5 机制缺失"; fi
# VT-06
if grep '^31\.5 ' "$CRIT_D" | grep -q '被否决方案'; then ok 06 "31.5 消费侧联动 Rule 32"; else bad 06 "31.5 缺被否决方案联动"; fi
# VT-07 [task-v171 核心瘦身] SKILL 摘要行 Rule 32 → 指针段「用户否决」措辞 + CRIT_D Rule 32 标题锚
#   现象：SKILL.md 瘦身后 Rule 32 摘要 bullet（'Rule 32 用户否决与禁令追踪'）与合规 C20 行移除，VT-07/08 恒 FAIL。
#   根因：Rule 32 属纪律域；SKILL 侧现存联动=「派发与执行纪律指针」段「用户否决」措辞行（L191）；
#     条文本体（用户否决与禁令追踪）在 CRIT_D。
#   修法：VT-07=SKILL 含 '用户否决' ∧ CRIT_D '^### 32 ' 标题含「用户否决」；VT-08=卫星路由表 discipline 行（C20 载体）。
if grep -q '用户否决' "$SKILLMD" && grep '^### 32 ' "$CRIT_D" | grep -q '用户否决'; then ok 07 "SKILL.md 指针段用户否决措辞 ∧ CRIT_D Rule 32 标题（摘要行瘦身后由指针行+条文承载）"; else bad 07 "SKILL.md 摘要缺 Rule 32 联动面"; fi
# VT-08 [task-v171 核心瘦身] C20 检查项 → 卫星路由表 task-discipline 行
if grep -qE '^\| task-discipline \|' "$SKILLMD"; then ok 08 "SKILL.md 卫星路由表 discipline 行（C20 合规面载体）"; else bad 08 "SKILL.md 缺 C20 现载体"; fi
# VT-09 [task-v171 核心瘦身] 否决登记指针 → SKILL「用户否决」指针 + notepad 模板「🚫 被否决方案」消费段
if grep -q '用户否决' "$SKILLMD" && grep -q '被否决方案' "$TPL_NOTEPAD"; then ok 09 "SKILL.md 用户否决指针 ∧ notepad 模板被否决方案段（登记链双载体）"; else bad 09 "SKILL.md 缺否决登记指针"; fi
# VT-10 [2026-10-08 task-v144 合并级联: SKILL References/索引锚演进 1-62（58/59/60/62 落地）,宽容正则扩 6x 纪元][2026-10-10 task-v158 扩 7x 纪元 1-(3[1-9]|[4-7]x)]
# [2026-10-10 task-v160 合并并集: 保留演进记录，Rule 72 落地 1-72 纪元]
# [2026-10-11 task-v169 合并级联: Rule 80 落地 1-80 纪元, 末段字符类 4-7x→4-8x（后由 task-v170 精化为 8[01] 尾边界，禁越界放开 82-89）]
# [2026-10-11 task-v070 S10o 扩 81 纪元（Rule 45 注释）] '1-(3[1-9]|[4-7][0-9])'→'1-(3[1-9]|[4-7][0-9]|8[013]([^0-9]|$))^0-9]|$))'：Why=task-v170 落地 Rule 81（计划完成后归档纪律），SKILL.md 实态「Critical Rules 1-81」（L314/L406），epoch 上界 80→81；8x 精化 8[01] 带尾边界断言（后随非数字或行尾），负样本 82/89/90 不得命中（不放开越界值），EL-11 同族宽容锚不重新钉死
if grep -qE 'Rules 1-(3[1-9]|[4-7][0-9]|8[013]([^0-9]|$))' "$SKILLMD"; then ok 10 "SKILL.md Rules 1-3x..83 宽容范围（task-v144 扩 6x 纪元, task-v158 扩 7x 纪元, task-v070 扩 81 纪元, task-v172 扩 83 纪元）"; else bad 10 "SKILL.md 缺 Rules 1-3x..83 宽容锚"; fi
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
