#!/usr/bin/env bash
# selftest-conclusion-discipline.sh — task-v076: Rule 35 执行结论纪律静态守护
# 守护（门控+指针范式，三关查证/落盘补救为 LLM 行为面无脚本可测，仅防条款与锚点误删回退）:
#   CD-01 critical-rules.md 含 "### 35 执行结论纪律" 条款标题
#   CD-02~07 六子条 35.1-35.7 各 grep 存在（[2026-09-18 task-v082] 35.6=最小探针原则，原 35.6 机制重编号 35.7，CD-07 改双锚）
#   CD-08 22.4 行含 "Rule 35.3 大输入落盘引用" 补救句
#   CD-09 SKILL.md 含 "Rule 35（P0）执行结论纪律" 列表行
#   CD-10 SKILL.md 含 "| C23 |" 检查项行
#   CD-11 SKILL.md 含 "1-3[5-7]" 宽容锚且计数 ≥3（L9 全集/L278 References/L327 表三处；[2026-09-17 task-v079] 严格 '1-35'→宽容 1-3[5-7]，兼容 SKILL 1-35 现值与 P4 后 1-36）[task-v117 口径扩展] 双锚 1-3[5-9]+1-4[56] 合计 ≥3（L9 全集面已演进为「1-46」[task-v118]，面未缩）[2026-10-08 task-v144 合并级联: SKILL References/索引锚演进 1-62（58/59/60/62 落地）,宽容正则扩 6x 纪元] 双锚面 1-3[5-9]+1-[4-7][0-9] 合计 ≥3（旧纪元面保留兼容，6x 纪元纳入，阈值语义零改动）
#   CD-12 SKILL.md 不再含 "1-34"（防版本字样回退，计数必须=0）
#   CD-13 SKILL.md 五档兜底引用注含 "Rule 35.3 大输入落盘引用"
#   CD-14 check-dispatch.sh 含 "补救(Rule 35.3)" 落盘指引
#   CD-15 check-dispatch.sh 仍含 "⚠ prompt 长度"（防误删破坏 selftest-dispatch FG 断言）
#   CD-16 templates/subagent_dispatch.md 含 "超限补救(Rule 35.3)"
#   CD-17 templates/notepad-learnings.md 含 "🚫 被否决方案"（veto 段名存在，联动 Rule 35.5 消费侧）
#   CD-18 README.md 含 "Rules 1-6[0-9]|1-3[5-9]" 宽容锚（S5 滞后的版本号修复在位，防回退 1-27；[2026-09-17 task-v079] 级联）[2026-10-09 task-v149 对齐 1-65]
#   CD-19 batch-quality-gate.md 含 "隶属 Rules 1-3[5-7]" 宽容锚（S5 同批修复锚；[2026-09-17 task-v079] 级联）
#   CD-20 plan-writer.md 含 "纯数字"（s_unit_id 契约行在位）
#   CD-21 templates/task_plan.md 含 "ID 列一律纯数字"（④ S-unit 注释行在位）
#   CD-22 templates/subagent_dispatch.md 含 "机械求和"（统计类禁自报汇总行在位）
#   CD-23 smart-merge-back.sh 含 "DEPLOY_SRC"（部署源换源在位）且含 "禁回退 SKILL_ROOT"（fail-closed 在位）
#   CD-25 critical-rules.md+SKILL.md 均含 "最小探针"（task-v082 联动锚；编号避让既有标签 CD-24）
# 维护注记: S-unit ID 契约=纯数字（check-plan-dispatch.sh 数据行正则 ^\|\s*S[0-9]+\s*\| 不认字母后缀，task-v076 attest 拒锁教训）
# 2026-09-17 task-v077 扩展: CD-18..CD-23 锁定 S3/S5/S6/S7 四项修复的守护锚（V074 deferred-fixes）
# 2026-09-17 task-v079 S8a: CD-11/CD-18/CD-19 严格 '1-35' 锚改宽容 '1-3[5-7]'（SKILL 1-35→1-36 两阶段过渡自洽；CD-12 '1-34' 反回退锚保留）
# 2026-10-03 task-v118: CD-12 双锚之 n45 面 1-45→1-4[56]（SKILL frontmatter 全集演进 1-46，口径扩展非回退，同 v117 范式；≥3 门槛与 CD-12 '1-34' 反回退锚不变）
# 23 断言全 PASS exit 0; 任一 FAIL exit 1。只读, 不修改任何文件。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$SCRIPT_DIR/../SKILL.md"
RULES="$SCRIPT_DIR/../references/critical-rules.md"
# [task-v171 纪律域搬迁 2026-10-12] Rule 35（执行结论纪律）属纪律域，原文已迁至
#   skills/task-discipline/references/critical-rules-discipline.md（SCRIPT_DIR=<root>/skills/task-planner/scripts，
#   ../../task-discipline 即 skills 平级）；CD-01..CD-07/CD-25 的 RULES 断言改指 CRIT_D，RULES 保留指向核心。
#   注：CD-08 的 22.4 属 task-dispatch 域（批3 CRIT_DP 目标文件），本批不动，暂留批3 重定向。
CRIT_D="$SCRIPT_DIR/../../task-discipline/references/critical-rules-discipline.md"
# [task-v171 派发域搬迁 2026-10-12] Rule 22（子代理派发九字段模板）属 task-dispatch 域，已迁至
#   skills/task-dispatch/references/critical-rules-dispatch.md；CD-08 的 22.4 行断言由 RULES 改指 DISP_RULES
#   （原批3 重定向注记到此执行）。
DISP_RULES="$SCRIPT_DIR/../../task-dispatch/references/critical-rules-dispatch.md"
DISPATCH="$SCRIPT_DIR/check-dispatch.sh"
TMPL="$SCRIPT_DIR/../templates/subagent_dispatch.md"
NOTEPAD_TPL="$SCRIPT_DIR/../templates/notepad-learnings.md"
SMART="$SCRIPT_DIR/smart-merge-back.sh"
README_SKILL="$SCRIPT_DIR/../README.md"
# [task-v171 纪律域搬迁 2026-10-12] batch-quality-gate.md 归属纪律域，迁至 skills/task-discipline/references
#   （SCRIPT_DIR=<root>/skills/task-planner/scripts，../../task-discipline 即 skills 平级）；CD-19 断言语义零改动
BGATE="$SCRIPT_DIR/../../task-discipline/references/batch-quality-gate.md"
PLANWRITER="$SCRIPT_DIR/../companion/agents/plan-writer.md"
TPL_PLAN="$SCRIPT_DIR/../templates/task_plan.md"

total=0; ok=0; bad=0
check() { total=$((total+1)); if eval "$1" 2>/dev/null; then ok=$((ok+1)); printf 'CD-%02d PASS %s\n' "$total" "$2"; else bad=$((bad+1)); printf 'CD-%02d FAIL %s\n' "$total" "$2"; fi; }

# CD-01 条款标题
check "grep -qF '### 35 执行结论纪律' \"\$CRIT_D\"" "critical-rules.md 含 '### 35 执行结论纪律'"
# CD-02~07 六子条
check "grep -q '^35\.1 ' \"\$CRIT_D\"" "35.1 触发条款存在"
check "grep -q '^35\.2 ' \"\$CRIT_D\"" "35.2 能力否定三关条款存在"
check "grep -q '^35\.3 ' \"\$CRIT_D\"" "35.3 大输入落盘引用条款存在"
check "grep -q '^35\.4 ' \"\$CRIT_D\"" "35.4 结论上报措辞条款存在"
check "grep -q '^35\.5 ' \"\$CRIT_D\"" "35.5 消费侧条款存在"
check "grep -q '^35\.6 \*\*最小探针原则' \"\$CRIT_D\" && grep -q '^35\.7 \*\*机制\*\*' \"\$CRIT_D\"" "35.6 最小探针原则+35.7 机制条款存在（task-v082 重编号后双锚）"
# CD-25 [task-v171 核心瘦身] 最小探针联动锚：CRIT_D 35.6 条款 + SKILL.md 卫星路由表 task-discipline 行
#   现象：SKILL.md 瘦身后非核心域规则条文不再展开（「最小探针」仅存于 Rule 35.6 条文），SKILL 侧命中=0，本断言恒 FAIL。
#   根因：断言双锚 CRIT_D+SKILL 同词；Rule 35 属纪律域，瘦身后 SKILL 侧联动载体=卫星路由表 task-discipline 行（Rule 82 禁回潮）。
#   修法：SKILL 侧锚改卫星路由表行；CRIT_D 侧 35.6 最小探针条款锚不变。
check "grep -qF '最小探针' \"\$CRIT_D\" && grep -qE '^\| task-discipline \|' \"\$SKILL\"" "CD-25 CRIT_D 含 '最小探针'（35.6 条款）+SKILL.md 卫星路由表 task-discipline 行（联动瘦身后由路由表承载）"
# CD-08 [task-v171 派发域搬迁] 22.4 补救句：22.4 属 task-dispatch 域已迁出，RULES→DISP_RULES
check "grep -qF 'Rule 35.3 大输入落盘引用' \"\$DISP_RULES\" && grep '^22\.4' \"\$DISP_RULES\" | grep -qF 'Rule 35.3 大输入落盘引用'" "22.4 行含 'Rule 35.3 大输入落盘引用'（DISP_RULES=critical-rules-dispatch.md）"
# CD-09 [task-v171 核心瘦身] SKILL Rule 35 联动面：卫星路由表 task-discipline 行（Rule 35 属纪律域，摘要列表行随瘦身移除）
check "grep -qE '^\| task-discipline \|' \"\$SKILL\"" "SKILL.md 含 Rule 35 联动面（卫星路由表 task-discipline 行；原 'Rule 35（P0）执行结论纪律' 列表行随瘦身移除）"
# CD-10 [task-v171 核心瘦身] Rule 35 合规消费点：卫星路由表 task-discipline 行（原 '| C23 |' 检查项行随合规清单表瘦身移除）
check "grep -qE '^\| task-discipline \|' \"\$SKILL\"" "SKILL.md 含 Rule 35 合规消费点（卫星路由表 task-discipline 行；原 '| C23 |' 检查项行移除）"
# CD-11 宽容锚计数 ≥3（兼容 1-35/1-36 过渡，task-v079）
# [task-v117 口径扩展] frontmatter L9 全集面已由「1-39」演进为「1-45」而退出 1-3[5-9] 判定面（命中 3→2），
# 双锚扩面：1-3[5-9] + 1-45 合计 ≥3，阈值不变（守原 L9 全集/References/表 三处面意图，语义零改动，同 WF-10 v116 处置范式）
n35=$(grep -cE '1-3[5-9]' "$SKILL" || true); n35=$((n35+0))
# [task-v118 口径扩展] 1-45→1-4[56]（frontmatter 全集演进 1-46，语义等价，同 v117 先例；2026-10-03）
# [task-v121 预扩] 1-4[56]→1-4[5-9]（2026-10-03，用户裁决）
# [task-v127 口径扩展] 1-4[5-9]→1-4[5-9]|1-50（frontmatter 全集演进 1-50，同 v121 宽容化先例；合计 ≥3 阈值语义零改动）
# [2026-10-08 task-v144 合并级联: SKILL References/索引锚演进 1-62（58/59/60/62 落地）,宽容正则扩 6x 纪元]
# [2026-10-10 task-v160 合并级联: 全集演进 1-72 宽容扩 7x]（保留为历史：v160 演进记录）
# 追加锚 1-7[0-2]（覆盖 1-70/1-71/1-72），n35+n45+n70 合计 ≥3 阈值语义零改动（同 v144 6x 纪元范式）——[2026-10-10 task-v160 合并并集] master 侧 1-[4-7][0-9] 单锚实测命中=5 已覆盖 7x，n70 活跃断言并归入 n45，此行仅存历史
# [2026-10-10 task-v160 合并并集: 保留 v160 演进记录，Rule 72 落地 1-72 纪元]
# 1-4[5-9]|1-5[0-9]→1-[4-7][0-9]（单锚合并扩面: 旧 4x/5x 纪元保留兼容 + 新 6[0-2] 纪元纳入，合计 ≥3 阈值语义零改动）
# [2026-10-10 task-v163 级联: SKILL 计数演进 1-72→1-75（Rule 75 落地），活跃锚 1-[4-7][0-9] 已覆盖 75（1-7[5]），无需扩锚；n35+n45 合计 ≥3 阈值不变]
n45=$(grep -cE '1-[4-7][0-9]' "$SKILL" || true); n45=$((n45+0))
check "test $((n35+n45)) -ge 3" "SKILL.md 宽容锚「1-3[5-9]」$n35 +「1-[4-7][0-9]」$n45 合计 ≥3（兼容 1-35-62 各纪元过渡，task-v144 合并级联: 全集演进 1-62 宽容扩 6x；task-v160 合并并集保留 7x n70 演进记录为历史）"
# CD-12 1-34 零命中（防回退）
n34=$(grep -c '1-34' "$SKILL" || true); n34=$((n34+0))
check "test ${n34} -eq 0" "SKILL.md 不含 '1-34'（防回退，当前=${n34}）"
# CD-13 [task-v171 核心瘦身] 五档兜底引用注：SKILL.md 委派检查点兜底指针（task-dispatch）+ DISP_RULES 22.4 补救句
#   现象：SKILL.md 瘦身后「五档兜底」详表（22.3 ①-⑤）移入 task-dispatch，SKILL 直接引用 'Rule 35.3 大输入落盘引用' 的注行零命中，本断言恒 FAIL。
#   根因：22.3/22.4 属派发域；瘦身后 SKILL.md 2.5 委派检查点仅留「兜底详见卫星 task-dispatch」指针。
#   修法：SKILL 侧断言 2.5 行含 task-dispatch 兜底指针 + DISP_RULES 22.4 行含 'Rule 35.3 大输入落盘引用'（条文锚不丢）。
check "grep -F '兜底' \"\$SKILL\" | grep -qF 'task-dispatch' && grep '^22\.4' \"\$DISP_RULES\" | grep -qF 'Rule 35.3 大输入落盘引用'" "SKILL.md 委派检查点含 task-dispatch 兜底指针 + DISP_RULES 22.4 行含 'Rule 35.3 大输入落盘引用'"
# CD-14 check-dispatch 补救指引
check "grep -qF '补救(Rule 35.3)' \"\$DISPATCH\"" "check-dispatch.sh 含 '补救(Rule 35.3)'"
# CD-15 原提示字面保留
check "grep -q '⚠ prompt 长度' \"\$DISPATCH\"" "check-dispatch.sh 仍含 '⚠ prompt 长度'（selftest-dispatch FG 依赖）"
# CD-16 模板落盘表述
check "grep -qF '超限补救(Rule 35.3)' \"\$TMPL\"" "subagent_dispatch.md 含 '超限补救(Rule 35.3)'"
# CD-17 notepad veto 段名
check "grep -qF '🚫 被否决方案' \"\$NOTEPAD_TPL\"" "notepad-learnings.md 含 '🚫 被否决方案' 段"
# CD-18 README 版本号修复锚
check "grep -qE 'Rules 1-6[0-9]|Rules 1-3[5-9]' \"\$README_SKILL\"" "README.md 含 1-6[0-9]|1-3[5-9] 宽容锚（task-v149 对齐 1-65，兼容 1-35/1-36 过渡）"
# CD-19 batch-gate 版本号修复锚
check "grep -qE '隶属 Rules 1-3[5-8]' \"\$BGATE\"" "batch-quality-gate.md 含 1-3[5-8] 宽容锚（task-v086 级联 1-38）（兼容 1-35/1-36 过渡）"
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
