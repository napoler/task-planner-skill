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
#   EL-11 SKILL.md frontmatter/References 含 Rules 1-31
#   EL-12 config.json 含 error_loop_enforce 键（默认 warn，enum 三档）
#   EL-13 templates/progress.md Error Log 含 Root Cause / Prevention 列
#   EL-14 templates/task_plan.md Errors 表含 Prevention 指针列
#   EL-15 templates/notepad-learnings.md 含 Rule 31.4/31.5 消费侧契约注释
#   EL-16 check-complete.sh 含 LEARNING-GATE 门控锚点（终验静态校验存在）
# 16 断言全 PASS exit 0; 任一 FAIL exit 1。只读, 不修改任何文件。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
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
if grep -q '^31\.1 ' "$CRIT" && grep '31\.1' "$CRIT" | grep -q '重复反馈'; then ok 01 "31.1 触发条件"; else bad 01 "31.1 触发条件缺失"; fi
# EL-02
if grep -q '^31\.2 ' "$CRIT" && grep '31\.2' "$CRIT" | grep -q '5 Whys'; then ok 02 "31.2 根因分析（5 Whys）"; else bad 02 "31.2 根因分析缺失"; fi
# EL-03
if grep -q '^31\.3 ' "$CRIT" && grep '31\.3' "$CRIT" | grep -q '盲目'; then ok 03 "31.3 修正路由（禁盲目）"; else bad 03 "31.3 修正路由缺失"; fi
# EL-04
if grep -q '^31\.4 ' "$CRIT" && grep '31\.4' "$CRIT" | grep -q "What Didn't Work"; then ok 04 "31.4 沉淀（notepad 两段）"; else bad 04 "31.4 沉淀缺失"; fi
# EL-05
if grep -q '^31\.5 ' "$CRIT" && grep '31\.5' "$CRIT" | grep -q 'Learning Gate'; then ok 05 "31.5 消费侧（Learning Gate）"; else bad 05 "31.5 消费侧缺失"; fi
# EL-06
if grep -q '^31\.6 ' "$CRIT" && grep '31\.6' "$CRIT" | grep -q 'error_loop_enforce'; then ok 06 "31.6 机制（开关键）"; else bad 06 "31.6 机制缺失"; fi
# EL-07
if grep '^### 8 ' "$CRIT" -A2 | grep -q 'Rule 31'; then ok 07 "Rule 8 联动 Rule 31"; else bad 07 "Rule 8 缺 Rule 31 引用"; fi
# EL-08
if grep -q 'Rule 31' "$SKILLMD" && grep 'Rule 31' "$SKILLMD" | grep -q '错误学习闭环'; then ok 08 "SKILL.md 摘要行 Rule 31"; else bad 08 "SKILL.md 摘要行缺 Rule 31"; fi
# EL-09
if grep -q '| C19 |' "$SKILLMD" && grep 'C19' "$SKILLMD" | grep -q 'Rule 31'; then ok 09 "SKILL.md C19 检查项"; else bad 09 "SKILL.md 缺 C19"; fi
# EL-10
if grep -q '错误指出特判' "$SKILLMD"; then ok 10 "SKILL.md 用户新指令处理指针"; else bad 10 "SKILL.md 缺错误指出特判"; fi
# EL-11
if grep -q 'Rules 1-31' "$SKILLMD"; then ok 11 "SKILL.md Rules 1-31 范围"; else bad 11 "SKILL.md 缺 Rules 1-31"; fi
# EL-12
if grep -q '"error_loop_enforce"' "$CONFIG" && python3 -c "
import json,sys
d=json.load(open('$CONFIG'))
k=d['properties']['error_loop_enforce']
sys.exit(0 if k.get('default')=='warn' and k.get('enum')==['enforce','warn','off'] else 1)" 2>/dev/null; then
  ok 12 "config.json error_loop_enforce（warn 默认+三档）"
else
  bad 12 "config.json error_loop_enforce 缺失/默认非 warn"
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
