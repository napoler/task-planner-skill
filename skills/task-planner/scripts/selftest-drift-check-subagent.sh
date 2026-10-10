#!/usr/bin/env bash
# selftest-drift-check-subagent.sh — task-v146: Rule 61 偏移检查子代理化载体锚静态守护
# What: 守护 Rule 61 偏移检查子代理化的载体锚（SKILL.md 六处措辞/critical-rules.md Rule 61 六子条/
#       drift-checker.md agent 定义/卫星 task-drift-guard/SKILL.md 双载体说明/hook 文案/全仓负断言）
# Why: 防未来改回主上下文执行（R2 需求：偏移检查放入子代理保持上下文干净规避上下文爆炸），
#       防双源漂移（skill 载体与子代理载体措辞不一致），task-v146 成果锁住。
# 20 断言全 PASS exit 0; 任一 FAIL exit 1。只读, 不修改任何文件。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
DRIFT_CHECKER="$SKILL_ROOT/companion/agents/drift-checker.md"
AGENT_COV="$SKILL_ROOT/references/agent-coverage.md"
SATELLITE_SKILL="$SKILL_ROOT/../task-drift-guard/SKILL.md"
HOOK="$SKILL_ROOT/scripts/zcode-userpromptsubmit.sh"
SKILLS_ROOT="$(cd "$SKILL_ROOT/.." && pwd)"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'DCS-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'DCS-%s FAIL %s\n' "$1" "$2"; }

# DCS-01: SKILL.md [DRIFT CHECK] 步骤行含 drift-checker
if grep '\[DRIFT CHECK\]' "$SKILLMD" | grep -q 'drift-checker'; then ok 01 "[DRIFT CHECK] 步骤行含 drift-checker"; else bad 01 "[DRIFT CHECK] 步骤行缺 drift-checker"; fi

# DCS-02: SKILL.md 只读检测执行体行含 drift-checker 且不含 task-drift-guard
if grep '只读检测执行体' "$SKILLMD" | grep -q 'drift-checker' && ! grep '只读检测执行体' "$SKILLMD" | grep -q 'task-drift-guard'; then ok 02 "只读检测执行体行含 drift-checker 无 task-drift-guard"; else bad 02 "只读检测执行体行条件不满足"; fi

# DCS-03: SKILL.md Chain 交接步骤 4 行含 drift-checker
if grep -q '4\. 派发.*drift-checker' "$SKILLMD"; then ok 03 "Chain 步骤 4 含 drift-checker"; else bad 03 "Chain 步骤 4 缺 drift-checker"; fi

# DCS-04: 合规清单 C4 行含 drift-checker
if grep '| C4 |' "$SKILLMD" | grep -q 'drift-checker'; then ok 04 "C4 行含 drift-checker"; else bad 04 "C4 行缺 drift-checker"; fi

# DCS-05: SKILL.md B/C 类处理完行含 drift-checker
if grep 'B/C 类处理完' "$SKILLMD" | grep -q 'drift-checker'; then ok 05 "B/C 类处理完行含 drift-checker"; else bad 05 "B/C 类处理完行缺 drift-checker"; fi

# DCS-06: Rule 15 bullet 行与高频漂移纠正节摘要行各含 drift-checker（两行分别断言）
if grep '每 2-3 个原生 todo' "$SKILLMD" | grep -q 'drift-checker' && grep '任一触发条件命中' "$SKILLMD" | grep -q 'drift-checker'; then ok 06 "Rule 15 bullet+高频漂移纠正摘要行含 drift-checker"; else bad 06 "Rule 15 bullet 或摘要行缺 drift-checker"; fi

# DCS-07: 路由表漂移检测行含 drift-checker 且含 haiku-1
if grep '漂移检测（高频）' "$SKILLMD" | grep -q 'drift-checker' && grep '漂移检测（高频）' "$SKILLMD" | grep -q 'haiku-1'; then ok 07 "路由表漂移检测行含 drift-checker+haiku-1"; else bad 07 "路由表漂移检测行条件不满足"; fi

# DCS-08: SKILL.md Skill("task-drift-guard") 计数=0（负断言）
if [ "$(grep -c 'Skill("task-drift-guard")' "$SKILLMD")" -eq 0 ]; then ok 08 "SKILL.md Skill(task-drift-guard) 计数=0"; else bad 08 "SKILL.md 存在 Skill(task-drift-guard) 残留"; fi

# DCS-09: SKILL.md References 区含 drift-checker 且含 task-drift-guard（双载体说明行）
if grep 'drift-checker.*agent.*偏移检查执行载体' "$SKILLMD" | grep -q 'task-drift-guard'; then ok 09 "References 双载体说明行"; else bad 09 "References 双载体说明行缺失"; fi

# DCS-10: SKILL.md 反模式段含偏移比对禁止行且含 Rule 61
if grep '偏移比对' "$SKILLMD" | grep -q 'Rule 61'; then ok 10 "反模式偏移比对禁止行含 Rule 61"; else bad 10 "反模式偏移比对禁止行缺失"; fi

# DCS-11: SKILL.md 含 Rule 40-69 全集 且含 Rule 61 偏移检查子代理化 且含 Rule 61 摘要 bullet
# [2026-10-08 task-v147 合并级联] 'Rule 40-62 全集'→'Rule 40-63 全集'：Rule 63 已落地，头注全集括注同步演进
# [2026-10-08 task-v147 第二代级联] 'Rule 40-63 全集'→'Rule 40-64 全集'：Rule 64 已由 task-v148 落地（64.1-64.6），锚同步演进
# [2026-10-08 task-v149 Rule 65 落地演进] 'Rule 40-64 全集'→'Rule 40-65 全集'：Rule 65 已由 task-v149 落地，锚同步演进
# [2026-10-09 task-v152 Rule 67 落地] '40-65'→'40-67'：Rule 67 已由 task-v152 落地，锚同步演进
# [2026-10-10 task-v154 S5 接线演进] 'Rule 40-65 全集'→'Rule 40-69 全集'：Rule 66(v151)/69(v154) 已落地，章节引言行欠账修正同步
# [2026-10-10 task-v162 合并并集演进] 'Rule 40-(69|71) 全集'→'Rule 40-(69|71|74) 全集'：Rule 74（变更吸收三判）落地，头注全集括注 40-74，宽容交替集扩 74（C 类条件修复）
if grep -qE 'Rule 40-(69|71|74) 全集' "$SKILLMD" && grep -q 'Rule 61 偏移检查子代理化' "$SKILLMD" && grep -q '\*\*Rule 61（偏移检查子代理化' "$SKILLMD"; then ok 11 "索引括注 40-69/40-71/40-74 全集+Rule 61 偏移检查子代理化 保全+Rule 61 摘要 bullet"; else bad 11 "DCS-11 条件缺失"; fi

# DCS-12: critical-rules.md 含 ### 61 标题 + **61.1..**61.6 六锚各 >=1
if grep -q '^### 61 ' "$CRIT" && grep -q '\*\*61\.1' "$CRIT" && grep -q '\*\*61\.2' "$CRIT" && grep -q '\*\*61\.3' "$CRIT" && grep -q '\*\*61\.4' "$CRIT" && grep -q '\*\*61\.5' "$CRIT" && grep -q '\*\*61\.6' "$CRIT"; then ok 12 "Rule 61 标题+六锚齐全"; else bad 12 "Rule 61 锚缺失"; fi

# DCS-13: critical-rules.md 含 **15.4 锚 + 全文 Skill("task-drift-guard") 计数=0（负断言）
if grep -q '\*\*15\.4' "$CRIT" && [ "$(grep -c 'Skill("task-drift-guard")' "$CRIT")" -eq 0 ]; then ok 13 "15.4 锚+Skill(task-drift-guard) 计数=0"; else bad 13 "DCS-13 条件缺失"; fi

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

# DCS-19: SKILL.md wc -l <=558 + critical-rules.md 61.4 防自触发锚（清零）+ 61.5 降级锚（check-drift.sh）
SKILL_LINES=$(wc -l < "$SKILLMD")
if [ "$SKILL_LINES" -le 558 ] && grep -q '清零' "$CRIT" && grep -q 'check-drift.sh' "$CRIT"; then ok 19 "SKILL.md 行数<=558+61.4 清零+61.5 check-drift.sh"; else bad 19 "DCS-19 条件缺失"; fi

# DCS-20: 本技能目录 Skill("task-drift-guard") 精确串计数=0（负断言，排除自身）
# [2026-10-08 task-v149 D24] 扫描根从 SKILLS_ROOT（全 skills 树）收窄到 SKILL_ROOT（本技能目录）：
# 原扫描根过宽致环境敏感伪失败——部署位 skills/ 含 skill-fix/plan-cost-guard 等其他技能合法旧文案引用，
# 非本技能部署位残留。收窄后保持意图不变：防本技能部署位残留旧载体文案。
if [ "$(grep -rn 'Skill("task-drift-guard")' "$SKILL_ROOT" 2>/dev/null | grep -v 'selftest-drift-check-subagent.sh' | wc -l)" -eq 0 ]; then ok 20 "本技能目录 Skill(task-drift-guard) 精确串=0"; else bad 20 "本技能目录存在 Skill(task-drift-guard) 残留"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
