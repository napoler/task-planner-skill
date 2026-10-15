#!/usr/bin/env bash
# selftest-error-loop.sh — task-v072: Rule 31 错误学习闭环静态守护
# 守护（与 v063/v068/v071 门控+指针范式一致，归因为 LLM 行为面无脚本可测，仅防条款误删）:
#   EL-01 critical-rules.md 含 31.1 触发条件（语义锚点: 重复反馈）
#   EL-02 含 31.2 根因分析条款（语义锚点: 5 Whys / 禁止跳过）
#   EL-03 含 31.3 修正路由条款（语义锚点: 修正路由 / 盲目）
#   EL-04 含 31.4 沉淀条款（语义锚点: What Didn't Work）
#   EL-05 含 31.5 消费侧条款（语义锚点: 消费 / Learning Gate）
#   EL-06 含 31.6 机制条款（语义锚点: error_loop_enforce）
#   EL-07 Rule 8 含 Rule 31 引用（防 B/C 流程漏联动）
#   EL-08 SKILL.md Critical Rules 摘要行含 Rule 31（防摘要漏联动）
#   EL-09 SKILL.md 含 C19 合规检查项（Rule 31 联动）
#   EL-10 SKILL.md 用户新指令处理含「错误指出特判」指针
#   EL-11 SKILL.md frontmatter/References 含 Rules 1-3[1-6]（宽容锚: P4 时为 1-32, P5 加 Rule 33/34 后改 1-34, S4 加 Rule 35 后改 1-35, [2026-09-17 task-v079] Rule 36 级联后扩至 1-36 仍命中）[2026-10-08 task-v144 合并级联: SKILL References/索引锚演进 1-62（58/59/60/62 落地）,宽容正则扩 6x 纪元 1-(3[1-9]|[4-6][0-9])][2026-10-11 task-v169 Rule 80 落地 1-80 纪元, 末段字符类 [4-7]x→[4-8]x; EL-11 补记: Rule 80 用户会话逐字记录与只写不改纪律 落地, SKILL.md Critical Rules 全集索引演进 1-76→1-80, 宽容正则末段字符类 4-7x→4-8x 扩 8x 纪元]
#   [2026-10-11 task-v170 S10j 纪元扩围（Rule 45 注释）] 宽容正则 '1-(3[1-9]|[4-7][0-9])'→'1-(3[1-9]|[4-7][0-9]|8[01])'：Why=task-v170 落地 Rule 81（计划完成后归档纪律），SKILL.md L314/L406 实态「Critical Rules 1-81」，epoch 上界 79→81；8x 扩 8[01]（覆盖 80/81，负样本 82/90 不得命中，不放开越界值），3x-7x 宽容并集保留、宽容锚不重新钉死
#   EL-12 config.json 含 error_loop_enforce 键（默认 enforce，enum 三档）
#   EL-13 templates/progress.md Error Log 含 Root Cause / Prevention 列
#   EL-14 templates/task_plan.md Errors 表含 Prevention 指针列
#   EL-15 templates/notepad-learnings.md 含 Rule 31.4/31.5 消费侧契约注释
#   EL-16 check-complete.sh 含 LEARNING-GATE 门控锚点（终验静态校验存在）
# 16 断言全 PASS exit 0; 任一 FAIL exit 1。只读, 不修改任何文件。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
# [task-v171 纪律域搬迁 2026-10-12] Rule 31（错误学习闭环）与 Rule 8（新请求强制重新规划）均属纪律域，
#   原文已迁至 skills/task-discipline/references/critical-rules-discipline.md（核心 critical-rules.md 只剩 11 条核心规则），
#   EL-01..EL-07 的 CRIT 断言改指 CRIT_D；CRIT 保留指向核心。断言语义零改动。
CRIT_D="$SKILL_ROOT/../task-discipline/references/critical-rules-discipline.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
TPL_PROGRESS="$SKILL_ROOT/templates/progress.md"
TPL_PLAN="$SKILL_ROOT/templates/task_plan.md"
TPL_NOTEPAD="$SKILL_ROOT/templates/notepad-learnings.md"
CHK_COMPLETE="$SKILL_ROOT/scripts/check-complete.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'EL-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'EL-%s FAIL %s\n' "$1" "$2"; }

# EL-01
if grep -q '^31\.1 ' "$CRIT_D" && grep '31\.1' "$CRIT_D" | grep -q '重复反馈'; then ok 01 "31.1 触发条件"; else bad 01 "31.1 触发条件缺失"; fi
# EL-02
if grep -q '^31\.2 ' "$CRIT_D" && grep '31\.2' "$CRIT_D" | grep -q '5 Whys'; then ok 02 "31.2 根因分析（5 Whys）"; else bad 02 "31.2 根因分析缺失"; fi
# EL-03
if grep -q '^31\.3 ' "$CRIT_D" && grep '31\.3' "$CRIT_D" | grep -q '盲目'; then ok 03 "31.3 修正路由（禁盲目）"; else bad 03 "31.3 修正路由缺失"; fi
# EL-04
if grep -q '^31\.4 ' "$CRIT_D" && grep '31\.4' "$CRIT_D" | grep -q "What Didn't Work"; then ok 04 "31.4 沉淀（notepad 两段）"; else bad 04 "31.4 沉淀缺失"; fi
# EL-05
if grep -q '^31\.5 ' "$CRIT_D" && grep '31\.5' "$CRIT_D" | grep -q 'Learning Gate'; then ok 05 "31.5 消费侧（Learning Gate）"; else bad 05 "31.5 消费侧缺失"; fi
# EL-06
if grep -q '^31\.6 ' "$CRIT_D" && grep '31\.6' "$CRIT_D" | grep -q 'error_loop_enforce'; then ok 06 "31.6 机制（开关键）"; else bad 06 "31.6 机制缺失"; fi
# EL-07
if grep '^### 8 ' "$CRIT_D" -A2 | grep -q 'Rule 31'; then ok 07 "Rule 8 联动 Rule 31"; else bad 07 "Rule 8 缺 Rule 31 引用"; fi
# EL-08 [task-v171 核心瘦身] SKILL.md Rule 31 摘要/联动面（纪律域摘要行瘦身后由 3c+新指令段两处引措承载）
#   现象：SKILL.md 瘦身后 Critical Rules 摘要 bullet（'Rule 31 错误学习闭环' 行）与合规 C19 行移除，EL-08/09 恒 FAIL。
#   根因：Rule 31 属纪律域；SKILL 侧现存联动=3c 动作留痕行（Rule 31.2 四问根因）+ 新指令处理段末行
#     （'用户指出错误（Rule 31）→先 STOP 走 31.2 四维归因再修（完整闭环见 task-discipline Rule 31/32/33/74）'）。
#   修法：EL-08 改断言 'Rule 31' 在位 ∧ 某命中行含 'task-discipline'（闭环全文指针）；EL-09 的 C19 合规行改断言
#     卫星路由表 discipline 行枚举 Rule 31（Rule 82 禁回潮，C 行不回填）。
if grep -q 'Rule 31' "$SKILLMD" && grep 'Rule 31' "$SKILLMD" | grep -q 'task-discipline'; then ok 08 "SKILL.md Rule 31 联动（新指令段含 task-discipline Rule 31/32/33/74 全文指针）"; else bad 08 "SKILL.md Rule 31 联动缺失"; fi
# EL-09 [task-v171 核心瘦身] C19 合规行 → 卫星路由表 task-discipline 行枚举 31
if grep -E '^\| task-discipline \|' "$SKILLMD" | grep -qE 'Rule [0-9,]*31'; then ok 09 "SKILL.md 卫星路由表 task-discipline 行枚举 Rule 31（C19 合规面瘦身后由路由表承载）"; else bad 09 "SKILL.md 卫星路由表缺 Rule 31 枚举"; fi
# EL-10 [task-v171 核心瘦身] 错误指出特判指针（措辞演进：'错误指出特判'→'用户指出错误（Rule 31）→先 STOP 走 31.2 四维归因'，锚随现措辞更新）
if grep -q '指出错误' "$SKILLMD" && grep '指出错误' "$SKILLMD" | grep -q 'Rule 31'; then ok 10 "SKILL.md 用户新指令处理含错误指出特判指针（Rule 31）"; else bad 10 "SKILL.md 缺错误指出特判"; fi
# EL-11 [2026-10-08 task-v144 合并级联: SKILL References/索引锚演进 1-62（58/59/60/62 落地）,宽容正则扩 6x 纪元]
# [2026-10-10 task-v160 合并并集: 保留演进记录，Rule 72 落地 1-72 纪元]
# [2026-10-11 task-v169 合并级联: Rule 80 落地 1-80 纪元, 末段字符类 4-7x→4-8x]
# [2026-10-11 task-v170 S10j 纪元扩围（Rule 45 注释）] 'Rules 1-(3[1-9]|[4-7][0-9])'→'Rules 1-(3[1-9]|[4-7][0-9]|8[01])'：
# Why=task-v170 落地 Rule 81（计划完成后归档纪律），SKILL.md L314/L406 实态「Critical Rules 1-81」，
# 旧正则上界 7x（覆盖至 79）失配=0，随动补 8[01]（覆盖 80/81，负样本 82/90 不得命中，不放开越界值），
# 3x-7x 宽容并集保留（宽容锚不重新钉死，v118/v131/v132 先例）。
if grep -qE 'Rules 1-(3[1-9]|[4-7][0-9]|8[0-9])' "$SKILLMD"; then ok 11 "SKILL.md Rules 1-3x..7x|8[01] 宽容范围（task-v144 扩 6x 纪元 / task-v170 S10j 扩 81 纪元）"; else bad 11 "SKILL.md 缺 Rules 1-3x..7x|8[01] 宽容锚"; fi
# EL-12 [2026-10-11 task-v168 设置层] error_loop_enforce 默认值 warn→enforce（用户 piv⊙ 设置修复），本钉同步演进；禁回退 warn。
# 原文（修前）: sys.exit(0 if k.get('default')=='warn' ...)，ok 消息「warn 默认+三档」，bad 消息「默认非 warn」
if grep -q '"error_loop_enforce"' "$CONFIG" && python3 -c "
import json,sys
d=json.load(open('$CONFIG'))
k=d['properties']['error_loop_enforce']
sys.exit(0 if k.get('default')=='enforce' and k.get('enum')==['enforce','warn','off'] else 1)" 2>/dev/null; then
  ok 12 "config.json error_loop_enforce（enforce 默认+三档）"
else
  bad 12 "config.json error_loop_enforce 缺失/默认非 enforce"
fi
# EL-13
if grep -q 'Root Cause' "$TPL_PROGRESS" && grep -q 'Prevention' "$TPL_PROGRESS" && grep -q '<待沉淀>' "$TPL_PROGRESS"; then
  ok 13 "progress.md 模板 Error Log 加列"
else
  bad 13 "progress.md 模板缺 Root Cause/Prevention 列"
fi
# EL-14
if grep -q 'Prevention（Rule 31 指针）' "$TPL_PLAN"; then ok 14 "task_plan.md Errors 表 Prevention 指针"; else bad 14 "task_plan.md Errors 表缺 Prevention 列"; fi
# EL-15
if grep -q 'Rule 31.4/31.5' "$TPL_NOTEPAD"; then ok 15 "notepad 模板消费侧契约"; else bad 15 "notepad 模板缺消费侧契约"; fi
# EL-16
if grep -q 'LEARNING-GATE' "$CHK_COMPLETE" && grep -q 'error_loop_enforce' "$CHK_COMPLETE"; then ok 16 "check-complete.sh Learning Gate 锚点"; else bad 16 "check-complete.sh 缺 Learning Gate"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
