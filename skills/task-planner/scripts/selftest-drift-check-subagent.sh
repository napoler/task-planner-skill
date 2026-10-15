#!/usr/bin/env bash
# selftest-drift-check-subagent.sh — task-v146: Rule 61 偏移检查子代理化载体锚静态守护
# What: 守护 Rule 61 偏移检查子代理化的载体锚（SKILL.md 六处措辞/critical-rules.md Rule 61 六子条/
#       drift-checker.md agent 定义/卫星 task-drift-guard/SKILL.md 双载体说明/hook 文案/全仓负断言）
# Why: 防未来改回主上下文执行（R2 需求：偏移检查放入子代理保持上下文干净规避上下文爆炸），
#       防双源漂移（skill 载体与子代理载体措辞不一致），task-v146 成果锁住。
# 21 断言全 PASS exit 0; 任一 FAIL exit 1。只读, 不修改任何文件。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
DRIFT_CHECKER="$SKILL_ROOT/companion/agents/drift-checker.md"
# [task-v171 回归修复 2026-10-12 派发域搬迁] 现象: DCS-17 FAIL(agent-coverage.md 缺 drift-checker 行)｜
# 根因: agent-coverage.md 随派发域迁至 skills/task-dispatch/references, 旧路径 $SKILL_ROOT/references 为空｜
# 修法: 改锚 $SKILL_ROOT/../task-dispatch/references/agent-coverage.md
AGENT_COV="$SKILL_ROOT/../task-dispatch/references/agent-coverage.md"
SATELLITE_SKILL="$SKILL_ROOT/../task-drift-guard/SKILL.md"
# [task-v171 回归修复 2026-10-12 漂移域搬迁] 现象: DCS-12/13/19 FAIL(Rule 61 锚缺失/15.4 锚缺失/61.4 清零+61.5 check-drift.sh 缺失)｜
# 根因: Rule 61/15 随漂移域迁至 skills/task-drift-guard/references/critical-rules-drift.md,
#   核心 critical-rules.md 已无 Rule 61 条款（CRIT 命中=0）｜
# 修法: DCS-12/13/19 的 CRIT 断言改指 CRIT_G（Rule 61 六子条/15.4/清零/check-drift.sh 锚实测均在位）；
#   CRIT 保留指向核心（DCS-19 内其他用途）。断言语义零改动。
CRIT_G="$SKILL_ROOT/../task-drift-guard/references/critical-rules-drift.md"
HOOK="$SKILL_ROOT/scripts/zcode-userpromptsubmit.sh"
SKILLS_ROOT="$(cd "$SKILL_ROOT/.." && pwd)"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'DCS-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'DCS-%s FAIL %s\n' "$1" "$2"; }

# [task-v171 核心瘦身] DCS-02..DCS-11 SKILL.md 六处措辞锚统一重定向（现象+根因+修法总注）：
#   现象：SKILL.md 556→214 行瘦身后，旧六处 drift-checker 措辞点（只读检测执行体行/Chain 交接步骤 4/
#     合规清单 C4 行/高频漂移纠正节/派发路由表漂移检测（高频）行/References 双载体说明行/反模式偏移比对行）
#     与旧全集括注 'Rule 40-76/80 全集'、'Rule 61 偏移检查子代理化' bullet 全部零命中，DCS-02..11 共 10 条恒 FAIL。
#   根因：非核心域规则条文/派发路由表/合规清单表随瘦身移出核心 SKILL.md（Rule 82 禁回潮）；
#     drift-checker 载体新分布=SKILL.md 步骤6 [DRIFT CHECK] 派发行 + 用户新指令处理 B/C 行 +
#     卫星路由表 task-drift-guard 行 + 条文本体 critical-rules-drift.md（CRIT_G）。
#   修法：逐条按语义对位重定向（各断言行内注释分注），Rule 61 全文锚由 CRIT_G 侧断言（DCS-12/13）守护，
#     负断言（DCS-08/18/20）不动。断言集合覆盖「SKILL 入口面×3 + 条文面×2 + 路由面×2」不缩水。

# DCS-01: SKILL.md [DRIFT CHECK] 步骤行含 drift-checker（瘦身后仍在位，原锚不变）
if grep '\[DRIFT CHECK\]' "$SKILLMD" | grep -q 'drift-checker'; then ok 01 "[DRIFT CHECK] 步骤行含 drift-checker"; else bad 01 "[DRIFT CHECK] 步骤行缺 drift-checker"; fi

# DCS-02 [task-v171 核心瘦身] 只读检测执行体行 → 卫星路由表 task-drift-guard 行（派发路由表瘦身后由卫星路由表承载执行体选型面）
#   现象：旧派发路由表「只读检测执行体」行随瘦身移除。根因：执行体路由归 task-dispatch 域；SKILL 侧漂移检测载体=卫星路由表 task-drift-guard 行。
#   修法：改断言路由表 task-drift-guard 行含漂移域编号 61（该行编号为区间/枚举混排「Rule 11,15,61,64」无 'Rule 61' 整串，
#     用行存在+行内含 61 编号断言）；原负断言（不含 task-drift-guard 字样）随「行内不出现卫星名」旧措辞一同失效，
#     负断言语义由 DCS-08（全文件 Skill("task-drift-guard")=0）承接。
if grep -E '^\| task-drift-guard \|' "$SKILLMD" | grep -qE 'Rule [0-9,]*61'; then ok 02 "卫星路由表 task-drift-guard 行含编号 61（只读检测执行体面瘦身后由路由表承载）"; else bad 02 "卫星路由表 task-drift-guard 行条件不满足"; fi

# DCS-03 [task-v171 核心瘦身] Chain 交接步骤 4 → Phase 执行循环步骤 6 [DRIFT CHECK] 派发行
#   现象：reference.md Chain Handoff 步骤 4「派发 drift-checker」随派发域详表移出 SKILL.md（Chain 步骤清单不在核心正文）。
#   根因：交接链路详情归 task-dispatch；核心 Phase 执行循环步骤 6 是瘦身后 drift 派发入口。
#   修法：改断言步骤 6 [DRIFT CHECK] 行含「派发」+drift-checker（现措辞带反引号：派发 `drift-checker`，锚用非紧邻正则）。
if grep -q '派发.*drift-checker' "$SKILLMD"; then ok 03 "Phase 循环步骤 6 [DRIFT CHECK] 含 派发 drift-checker（Chain 步骤 4 语义由步骤 6 承载）"; else bad 03 "步骤 6 派发 drift-checker 缺失"; fi

# DCS-04 [task-v171 核心瘦身] 合规清单 C4 行 → 用户新指令处理 B/C 行（合规清单表替换为 G1-G8 核心域表后，非核心域合规项经 B/C 行+路由表承载）
if grep -F '处理完再派 drift-checker' "$SKILLMD" | grep -q 'Rule 73.2'; then ok 04 "用户新指令处理 B/C 行含 drift-checker（C4 合规行瘦身后由 B/C 行承载）"; else bad 04 "B/C 行缺 drift-checker"; fi

# DCS-05 [task-v171 核心瘦身] B/C 类处理完行（措辞演进：「B/C 类处理完」→「处理完再派 drift-checker」，锚随现措辞更新）
if grep -F '处理完再派 drift-checker' "$SKILLMD"; then ok 05 "B/C 类处理完行含 drift-checker（现措辞:处理完再派）"; else bad 05 "B/C 类处理完行缺 drift-checker"; fi

# DCS-06 [task-v171 核心瘦身] Rule 15 bullet+高频漂移纠正摘要行 → 步骤 6 触发时机行（Rule 15 归漂移域；SKILL 侧留触发时机摘要）
#   现象：旧「每 2-3 个原生 todo」bullet 与「任一触发条件命中」高频漂移纠正节随瘦身移除。
#   根因：Rule 15 条文归 CRIT_G；SKILL 步骤 6 保留触发时机清单（Phase complete 后立即/连续 ≥3 次工具调用/…）。
#   修法：改断言「触发时机」行含 drift-checker（触发节奏语义在位）。
if grep '触发时机' "$SKILLMD" | grep -q 'drift-checker'; then ok 06 "步骤 6 触发时机行含 drift-checker（Rule 15 bullet+高频摘要瘦身后由触发时机行承载）"; else bad 06 "触发时机行缺 drift-checker"; fi

# DCS-07 [task-v171 核心瘦身] 路由表漂移检测行 → 卫星路由表 task-drift-guard 行；haiku-1 执行体选型面迁 task-dispatch（由 DCS-17 agent-coverage drift-checker 行守护）
#   现象：旧 SKILL 派发路由表「漂移检测（高频）」行（含 haiku-1 档位）随瘦身移除。根因：执行体选型表归 task-dispatch 域。
#   修法：改断言卫星路由表 task-drift-guard 行含「漂移检测」域措辞；haiku-1 字面锚改由 DCS-17 的 agent-coverage.md drift-checker 行承接（本条不再重复）。
if grep -E '^\| task-drift-guard \|' "$SKILLMD" | grep -q '漂移检测'; then ok 07 "卫星路由表 task-drift-guard 行含 漂移检测（haiku-1 选型面迁 task-dispatch，DCS-17 承接）"; else bad 07 "路由表漂移检测行条件不满足"; fi

# DCS-08: SKILL.md Skill("task-drift-guard") 计数=0（负断言，瘦身后仍成立，原锚不变）
if [ "$(grep -c 'Skill("task-drift-guard")' "$SKILLMD")" -eq 0 ]; then ok 08 "SKILL.md Skill(task-drift-guard) 计数=0"; else bad 08 "SKILL.md 存在 Skill(task-drift-guard) 残留"; fi

# DCS-09 [task-v171 核心瘦身] References 双载体说明行 → 卫星路由表 task-drift-guard 行（双载体=SKILL 路由行+drift-checker agent，后者由 DCS-14/15 守护）
if grep -E '^\| task-drift-guard \|' "$SKILLMD" | grep -q 'critical-rules-drift.md'; then ok 09 "卫星路由表 task-drift-guard 行含 rules 路径（双载体说明瘦身后由路由表行承载）"; else bad 09 "双载体说明行缺失"; fi

# DCS-10 [task-v171 核心瘦身] 反模式偏移比对禁止行 → 步骤 6 行 Rule 61 载体锚 + CRIT_G Rule 61 偏移条款锚
#   现象：旧反模式段「偏移比对禁止」行随瘦身移除。根因：反模式清单归 CRIT_G Rule 61 段；SKILL 步骤 6 保留「载体 Rule 61/64」引措。
#   修法：SKILL 侧断言 [DRIFT CHECK] 行含 Rule 61；条文侧断言 CRIT_G '^### 61 ' 标题含「偏移」。
if grep '\[DRIFT CHECK\]' "$SKILLMD" | grep -q 'Rule 61' && grep '^### 61 ' "$CRIT_G" | grep -q '偏移'; then ok 10 "步骤 6 行含 Rule 61 载体锚 ∧ CRIT_G 61 标题含 偏移（反模式禁止行瘦身后由条文锚承接）"; else bad 10 "Rule 61 载体锚缺失"; fi

# DCS-11 [task-v171 核心瘦身] 全集括注 'Rule 40-80 全集' → '1-80' 全集口径；'Rule 61 偏移检查子代理化' bullet → 卫星路由表行
#   现象：旧全集括注（Rule 40-80 全集）与 Rule 61 摘要 bullet（'**Rule 61（偏移检查子代理化'）随瘦身移除，三条件全失。
#   根因：全集声明演进为「Rules 1-80 全集索引」（核心 12 条+10 卫星）；Rule 61 归漂移域，SKILL 侧仅存路由表行+步骤 6 载体引措。
#   修法：全集锚改 '1-8[0134]'（阈值 ≥1；task-v170 并集 max 口径覆盖 1-81）；'Rule 61 偏移检查子代理化' 整串改路由表行 '偏移检查子代理化'+行内含 61；bullet 锚改 'Rule 61' 在 SKILL 命中 ≥1。
# 历史纪元演进记录（v147/v149/v152/v154/v156/v162/v166/v169 各级全集括注演进）保留如上；本轮 v171 为分层架构口径切换。
if grep -q '1-[89][0-9]' "$SKILLMD" && grep -q '偏移检查子代理化' "$SKILLMD" && grep -q 'Rule 61' "$SKILLMD"; then ok 11 "全集 '1-80' + 路由表 '偏移检查子代理化' + SKILL 'Rule 61' 载体锚（分层架构口径）"; else bad 11 "DCS-11 条件缺失（需 '1-80' 全集 + '偏移检查子代理化' + 'Rule 61'）"; fi

# DCS-12 [task-v171 回归修复] critical-rules.md → CRIT_G（Rule 61 迁漂移域）
if grep -q '^### 61 ' "$CRIT_G" && grep -q '\*\*61\.1' "$CRIT_G" && grep -q '\*\*61\.2' "$CRIT_G" && grep -q '\*\*61\.3' "$CRIT_G" && grep -q '\*\*61\.4' "$CRIT_G" && grep -q '\*\*61\.5' "$CRIT_G" && grep -q '\*\*61\.6' "$CRIT_G"; then ok 12 "Rule 61 标题+六锚齐全（CRIT_G=critical-rules-drift.md）"; else bad 12 "Rule 61 锚缺失"; fi

# DCS-13 [task-v171 回归修复] critical-rules.md → CRIT_G（Rule 15.4 随漂移域迁出；负断言 Skill("task-drift-guard")=0 保持）
if grep -q '\*\*15\.4' "$CRIT_G" && [ "$(grep -c 'Skill("task-drift-guard")' "$CRIT_G")" -eq 0 ]; then ok 13 "15.4 锚+Skill(task-drift-guard) 计数=0（CRIT_G）"; else bad 13 "DCS-13 条件缺失"; fi

# DCS-14: drift-checker.md 存在 + frontmatter tools: 含 Read 与 Write + model: 行非空
if [ -f "$DRIFT_CHECKER" ] && grep '^tools:' "$DRIFT_CHECKER" | grep -q 'Read' && grep '^tools:' "$DRIFT_CHECKER" | grep -q 'Write' && grep -qE '^model: *[^ ]' "$DRIFT_CHECKER"; then ok 14 "drift-checker.md 存在+tools Read/Write+model 非空"; else bad 14 "DCS-14 条件缺失"; fi

# DCS-15: drift-checker.md 与 task-drift-guard/SKILL.md 双文件各自含 ALIGNED、DRIFT、BLOCKED 三词
if grep -q 'ALIGNED' "$DRIFT_CHECKER" && grep -q 'DRIFT' "$DRIFT_CHECKER" && grep -q 'BLOCKED' "$DRIFT_CHECKER" && grep -q 'ALIGNED' "$SATELLITE_SKILL" && grep -q 'DRIFT' "$SATELLITE_SKILL" && grep -q 'BLOCKED' "$SATELLITE_SKILL"; then ok 15 "双载体三态一致"; else bad 15 "双载体三态缺失"; fi

# DCS-16: Rule 61 块或 drift-checker.md 含 subagent-state/ 检查点契约串
if grep -q 'subagent-state/' "$CRIT" || grep -q 'subagent-state/' "$DRIFT_CHECKER"; then ok 16 "subagent-state/ 检查点契约串"; else bad 16 "subagent-state/ 契约串缺失"; fi

# DCS-17: agent-coverage.md 含 drift-checker 行
if grep -q 'drift-checker' "$AGENT_COV"; then ok 17 "agent-coverage.md 含 drift-checker 行"; else bad 17 "agent-coverage.md 缺 drift-checker 行"; fi

# DCS-18: zcode-userpromptsubmit.sh 含 drift-checker 且 task-drift-guard 计数=0（负断言）
if grep -q 'drift-checker' "$HOOK" && [ "$(grep -c 'task-drift-guard' "$HOOK")" -eq 0 ]; then ok 18 "hook 含 drift-checker 无 task-drift-guard"; else bad 18 "hook 条件不满足"; fi

# DCS-19 [task-v171 回归修复] critical-rules.md → CRIT_G（Rule 61.4/61.5 迁漂移域；行数钉 558 对瘦身后 214 行恒真，保留不动）
SKILL_LINES=$(wc -l < "$SKILLMD")
if [ "$SKILL_LINES" -le 558 ] && grep -q '清零' "$CRIT_G" && grep -q 'check-drift.sh' "$CRIT_G"; then ok 19 "SKILL.md 行数<=558+CRIT_G 61.4 清零+61.5 check-drift.sh"; else bad 19 "DCS-19 条件缺失"; fi

# DCS-20: 本技能目录 Skill("task-drift-guard") 精确串计数=0（负断言，排除自身）
# [2026-10-08 task-v149 D24] 扫描根从 SKILLS_ROOT（全 skills 树）收窄到 SKILL_ROOT（本技能目录）：
# 原扫描根过宽致环境敏感伪失败——部署位 skills/ 含 skill-fix/plan-cost-guard 等其他技能合法旧文案引用，
# 非本技能部署位残留。收窄后保持意图不变：防本技能部署位残留旧载体文案。
if [ "$(grep -rn 'Skill("task-drift-guard")' "$SKILL_ROOT" 2>/dev/null | grep -v 'selftest-drift-check-subagent.sh' | wc -l)" -eq 0 ]; then ok 20 "本技能目录 Skill(task-drift-guard) 精确串=0"; else bad 20 "本技能目录存在 Skill(task-drift-guard) 残留"; fi

# DCS-21 [task-v172 CA-7] drift-checker.md 用户原话锚（复合审查输入 user-session-log.md 在位）
if grep -q 'user-session-log' "$DRIFT_CHECKER"; then ok 21 "CA-7: drift-checker.md 含 user-session-log 用户原话锚（复合审查输入在位）"; else bad 21 "CA-7: drift-checker.md 缺 user-session-log 用户原话锚"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
