#!/usr/bin/env bash
# selftest-conclusion-discipline.sh — task-v076: Rule 35 执行结论纪律静态守护
# 守护（门控+指针范式，三关查证/落盘补救为 LLM 行为面无脚本可测，仅防条款与锚点误删回退）:
#   CD-01 critical-rules.md 含 "### 35 执行结论纪律" 条款标题
#   CD-02~07 六子条 35.1-35.6 各 grep 存在
#   CD-08 22.4 行含 "Rule 35.3 大输入落盘引用" 补救句
#   CD-09 SKILL.md 含 "Rule 35（P0）执行结论纪律" 列表行
#   CD-10 SKILL.md 含 "| C23 |" 检查项行
#   CD-11 SKILL.md 含 "1-35" 且计数 ≥3（L9 全集/L278 References/L327 表三处）
#   CD-12 SKILL.md 不再含 "1-34"（防版本字样回退，计数必须=0）
#   CD-13 SKILL.md 五档兜底引用注含 "Rule 35.3 大输入落盘引用"
#   CD-14 check-dispatch.sh 含 "补救(Rule 35.3)" 落盘指引
#   CD-15 check-dispatch.sh 仍含 "⚠ prompt 长度"（防误删破坏 selftest-dispatch FG 断言）
#   CD-16 templates/subagent_dispatch.md 含 "超限补救(Rule 35.3)"
#   CD-17 templates/notepad-learnings.md 含 "🚫 被否决方案"（veto 段名存在，联动 Rule 35.5 消费侧）
#   CD-18 README.md 含 "Rules 1-35"（S5 滞后的版本号修复在位，防回退 1-27）
#   CD-19 batch-quality-gate.md 含 "隶属 Rules 1-35"（S5 同批修复锚）
#   CD-20 plan-writer.md 含 "纯数字"（s_unit_id 契约行在位）
#   CD-21 templates/task_plan.md 含 "ID 列一律纯数字"（④ S-unit 注释行在位）
#   CD-22 templates/subagent_dispatch.md 含 "机械求和"（统计类禁自报汇总行在位）
#   CD-23 smart-merge-back.sh 含 "DEPLOY_SRC"（部署源换源在位）且含 "禁回退 SKILL_ROOT"（fail-closed 在位）
# 维护注记: S-unit ID 契约=纯数字（check-plan-dispatch.sh 数据行正则 ^\|\s*S[0-9]+\s*\| 不认字母后缀，task-v076 attest 拒锁教训）
# 2026-09-17 task-v077 扩展: CD-18..CD-23 锁定 S3/S5/S6/S7 四项修复的守护锚（V074 deferred-fixes）
# 23 断言全 PASS exit 0; 任一 FAIL exit 1。只读, 不修改任何文件。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$SCRIPT_DIR/../SKILL.md"
RULES="$SCRIPT_DIR/../references/critical-rules.md"
DISPATCH="$SCRIPT_DIR/check-dispatch.sh"
TMPL="$SCRIPT_DIR/../templates/subagent_dispatch.md"
NOTEPAD_TPL="$SCRIPT_DIR/../templates/notepad-learnings.md"
SMART="$SCRIPT_DIR/smart-merge-back.sh"
README_SKILL="$SCRIPT_DIR/../README.md"
BGATE="$SCRIPT_DIR/../references/batch-quality-gate.md"
PLANWRITER="$SCRIPT_DIR/../companion/agents/plan-writer.md"
TPL_PLAN="$SCRIPT_DIR/../templates/task_plan.md"

total=0; ok=0; bad=0
check() { total=$((total+1)); if eval "$1" 2>/dev/null; then ok=$((ok+1)); printf 'CD-%02d PASS %s\n' "$total" "$2"; else bad=$((bad+1)); printf 'CD-%02d FAIL %s\n' "$total" "$2"; fi; }

# CD-01 条款标题
check "grep -qF '### 35 执行结论纪律' \"\$RULES\"" "critical-rules.md 含 '### 35 执行结论纪律'"
# CD-02~07 六子条
check "grep -q '^35\.1 ' \"\$RULES\"" "35.1 触发条款存在"
check "grep -q '^35\.2 ' \"\$RULES\"" "35.2 能力否定三关条款存在"
check "grep -q '^35\.3 ' \"\$RULES\"" "35.3 大输入落盘引用条款存在"
check "grep -q '^35\.4 ' \"\$RULES\"" "35.4 结论上报措辞条款存在"
check "grep -q '^35\.5 ' \"\$RULES\"" "35.5 消费侧条款存在"
check "grep -q '^35\.6 ' \"\$RULES\"" "35.6 机制条款存在"
# CD-08 22.4 补救句
check "grep -qF 'Rule 35.3 大输入落盘引用' \"\$RULES\" && grep '^22\.4' \"\$RULES\" | grep -qF 'Rule 35.3 大输入落盘引用'" "22.4 行含 'Rule 35.3 大输入落盘引用'"
# CD-09 SKILL 列表行
check "grep -qF 'Rule 35（P0）执行结论纪律' \"\$SKILL\"" "SKILL.md 含 'Rule 35（P0）执行结论纪律' 列表行"
# CD-10 C23 检查项
check "grep -qF '| C23 |' \"\$SKILL\"" "SKILL.md 含 '| C23 |' 检查项行"
# CD-11 1-35 计数 ≥3
n35=$(grep -c '1-35' "$SKILL" || true); n35=$((n35+0))
check "test ${n35} -ge 3" "SKILL.md '1-35' 计数 ≥3（当前=${n35}）"
# CD-12 1-34 零命中（防回退）
n34=$(grep -c '1-34' "$SKILL" || true); n34=$((n34+0))
check "test ${n34} -eq 0" "SKILL.md 不含 '1-34'（防回退，当前=${n34}）"
# CD-13 五档兜底引用注
check "grep -qF 'Rule 35.3 大输入落盘引用' \"\$SKILL\"" "SKILL.md 含 'Rule 35.3 大输入落盘引用'（五档兜底引用注）"
# CD-14 check-dispatch 补救指引
check "grep -qF '补救(Rule 35.3)' \"\$DISPATCH\"" "check-dispatch.sh 含 '补救(Rule 35.3)'"
# CD-15 原提示字面保留
check "grep -q '⚠ prompt 长度' \"\$DISPATCH\"" "check-dispatch.sh 仍含 '⚠ prompt 长度'（selftest-dispatch FG 依赖）"
# CD-16 模板落盘表述
check "grep -qF '超限补救(Rule 35.3)' \"\$TMPL\"" "subagent_dispatch.md 含 '超限补救(Rule 35.3)'"
# CD-17 notepad veto 段名
check "grep -qF '🚫 被否决方案' \"\$NOTEPAD_TPL\"" "notepad-learnings.md 含 '🚫 被否决方案' 段"
# CD-18 README 版本号修复锚
check "grep -qF 'Rules 1-35' \"\$README_SKILL\"" "README.md 含 'Rules 1-35'"
# CD-19 batch-gate 版本号修复锚
check "grep -qF '隶属 Rules 1-35' \"\$BGATE\"" "batch-quality-gate.md 含 '隶属 Rules 1-35'"
# CD-20 plan-writer S-unit 契约行
check "grep -q '纯数字' \"\$PLANWRITER\"" "plan-writer.md 含 '纯数字'（s_unit_id 契约行）"
# CD-21 task_plan 模板 ④ 注释行
check "grep -qF 'ID 列一律纯数字' \"\$TPL_PLAN\"" "task_plan.md 含 'ID 列一律纯数字'（④ 注释行）"
# CD-22 dispatch 模板禁自报汇总行
check "grep -qF '机械求和' \"\$TMPL\"" "subagent_dispatch.md 含 '机械求和'（禁自报汇总行）"
# CD-23 smart-merge-back 部署源换源 + fail-closed
check "grep -qF 'DEPLOY_SRC' \"\$SMART\" && grep -qF '禁回退 SKILL_ROOT' \"\$SMART\"" "smart-merge-back.sh 含 'DEPLOY_SRC' 且含 '禁回退 SKILL_ROOT'（fail-closed）"

printf 'Total: %d PASS=%d FAIL=%d\n' "$total" "$ok" "$bad"
exit $((bad > 0))
