#!/usr/bin/env bash
# selftest-decision-arbiter.sh — task-v154 S7: Rule 69 判断裁决子代理化与驳回打回纪律载体锚静态守护
# What: 守护 Rule 69 判断/裁决子代理化的载体锚（decision-arbiter.md agent 定义：四态裁决+驳回单五要素+
#       T1-T6 六触发点+管辖二分 / critical-rules.md Rule 69 六子条+[arbiter-reject] 留痕 / SKILL.md 路由表
#       「判断/裁决」行+触发点标记+C46 合规行 / agent-coverage.md 28 行判断裁决行 / registry 自登记 / 零新 config 键负断言）。
# Why: 防未来把判断类问题改回主进程硬决（R4 需求：判断裁决成为可被派发消费的正式执行体），
#      防四态/驳回单/触发点措辞漂移致裁决消费协议失效（驳回打回闭环断裂），task-v154 成果锁住。
# 16 断言全 PASS exit 0; 任一 FAIL exit 1。只读, 不修改任何文件。
# 演进史注记位: 后续 Rule 69 载体演进（触发点增减/四态改名/上界联动）在此追加注记。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ARBITER="$SKILL_ROOT/companion/agents/decision-arbiter.md"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
AGENT_COV="$SKILL_ROOT/references/agent-coverage.md"
REGISTRY="$SKILL_ROOT/scripts/selftest-registry.tsv"
CONFIG="$SKILL_ROOT/config.json"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'DA-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'DA-%s FAIL %s\n' "$1" "$2"; }

# DA-01 agent 文件存在
# What: companion/agents/decision-arbiter.md 非空在位。
# Why: agent 文件是 Rule 69 执行体唯一载体——被删=判断裁决退回主进程硬决（R4 需求回归）。
if [ -s "$ARBITER" ]; then ok 01 "decision-arbiter.md 在位"; else bad 01 "decision-arbiter.md 缺失/空"; fi

# DA-02 frontmatter model 逐字锚
# What: frontmatter model 值逐字 = account:zai-individual-coding-plan/GLM-5.3（grep -F 固定串）。
# Why: 69.5 声明强模型档 frontmatter 为 truth source、禁降档改判——档位漂移=判断质量承诺失效。
if grep -qF 'account:zai-individual-coding-plan/GLM-5.3' "$ARBITER"; then ok 02 "model 逐字=GLM-5.3 强档"; else bad 02 "model 非 GLM-5.3 强档"; fi

# DA-03..06 四态字面各 1 断言（裁决消费协议 69.3 与 agent 文件字面一致）
# What: agent 文件含 APPROVE/REJECT-REWORK/ESCALATE-USER/INSUFFICIENT-EVIDENCE 四态各 ≥1。
# Why: 四态=裁决消费协议（69.3）唯一枚举面，缺态=主进程收到该态无对应消费动作（驳回打回闭环断裂）。
if grep -qF 'APPROVE' "$ARBITER"; then ok 03 "四态含 APPROVE"; else bad 03 "四态缺 APPROVE"; fi
if grep -qF 'REJECT-REWORK' "$ARBITER"; then ok 04 "四态含 REJECT-REWORK"; else bad 04 "四态缺 REJECT-REWORK"; fi
if grep -qF 'ESCALATE-USER' "$ARBITER"; then ok 05 "四态含 ESCALATE-USER"; else bad 05 "四态缺 ESCALATE-USER"; fi
if grep -qF 'INSUFFICIENT-EVIDENCE' "$ARBITER"; then ok 06 "四态含 INSUFFICIENT-EVIDENCE"; else bad 06 "四态缺 INSUFFICIENT-EVIDENCE"; fi

# DA-07 驳回单五要素段 + T1-T6 六触发点
# What: agent 文件含「驳回单五要素」段锚且 T1-T6 六触发点标记计数 ≥6。
# Why: 五要素=REJECT-REWORK 返工可定位性（69.4）；六触发点=管辖入口矩阵（69.1）——缺一即判断类问题漏出口。
if grep -q '驳回单五要素' "$ARBITER" && [ "$(grep -c 'T[1-6] ' "$ARBITER")" -ge 6 ]; then ok 07 "驳回单五要素段+T1-T6 触发点 ≥6"; else bad 07 "驳回单五要素段或 T1-T6 触发点缺失"; fi

# DA-08 管辖二分四邻
# What: agent 文件含 drift-checker/critic/meta-corrector/complex-planner 四邻词。
# Why: 69.1 管辖二分=防双跑与越权（偏移检测/产物挑刺/自我纠偏/规划升级各归其体）——缺邻=管辖边界模糊。
if grep -q 'drift-checker' "$ARBITER" && grep -q 'critic' "$ARBITER" && grep -q 'meta-corrector' "$ARBITER" && grep -q 'complex-planner' "$ARBITER"; then ok 08 "管辖二分四邻齐全"; else bad 08 "管辖二分四邻缺失"; fi

# DA-09 critical-rules.md Rule 69 六子条锚
# What: critical-rules.md 含 **69.1..**69.6 六个子条锚各 ≥1。
# Why: 六子条=条款语义本体（触发/契约/消费/五要素/强档/机制），缺子条=条款部分语义缺失。
if grep -q '\*\*69\.1' "$CRIT" && grep -q '\*\*69\.2' "$CRIT" && grep -q '\*\*69\.3' "$CRIT" && grep -q '\*\*69\.4' "$CRIT" && grep -q '\*\*69\.5' "$CRIT" && grep -q '\*\*69\.6' "$CRIT"; then ok 09 "Rule 69 六子条齐全"; else bad 09 "Rule 69 子条缺失"; fi

# DA-10 [arbiter-reject] 留痕协议字面
# What: critical-rules.md 含 [arbiter-reject] 留痕串。
# Why: 69.3 REJECT-REWORK 强制返工靠 [arbiter-reject] 行留痕——串丢=静默继续原方向无机器面证据。
if grep -qF '[arbiter-reject]' "$CRIT"; then ok 10 "[arbiter-reject] 留痕协议在位"; else bad 10 "[arbiter-reject] 留痕协议缺失"; fi

# DA-11 SKILL.md 路由表「判断/裁决」行
# What: SKILL.md 含路由表「判断/裁决（低频）」行锚。
# Why: 路由行=判断类问题「找得到执行体」的路由面（R4 派发消费入口）——行丢=有体不用退回硬决。
if grep -q '判断/裁决（低频）' "$SKILLMD"; then ok 11 "路由表判断/裁决行在位"; else bad 11 "路由表判断/裁决行缺失"; fi

# DA-12 SKILL.md 触发点标记 ≥5
# What: SKILL.md 执行流程「Rule 69.1 T[1-6]」标记计数 ≥5。
# Why: 触发点标记=六触发点在执行流程的可消费落点（69.6 消费面），<5=触发点未接线到流程。
if [ "$(grep -c 'Rule 69.1 T[1-6]' "$SKILLMD")" -ge 5 ]; then ok 12 "SKILL 触发点标记 ≥5"; else bad 12 "SKILL 触发点标记 <5"; fi

# DA-13 SKILL.md 合规清单 C46 行
# What: SKILL.md 含合规清单 C46 行锚。
# Why: C46=判断裁决委派自查清单项（69.6），行丢=合规检查面缺判断裁决自查。
if grep -q '| C46 |' "$SKILLMD"; then ok 13 "合规清单 C46 行在位"; else bad 13 "合规清单 C46 行缺失"; fi

# DA-14 agent-coverage.md 28 行判断裁决行
# What: agent-coverage.md 含「判断/裁决 | decision-arbiter」行（编号 28）。
# Why: 覆盖矩阵行=Rule 52 选型事实源登记面，行丢=判断裁决体退回未登记态。
if grep -q '判断/裁决 | decision-arbiter' "$AGENT_COV"; then ok 14 "覆盖矩阵 28 行判断裁决行在位"; else bad 14 "覆盖矩阵判断裁决行缺失"; fi

# DA-15 registry 自登记（自指断言）
# What: selftest-registry.tsv 含本脚本登记行。
# Why: 登记面机器守护（Rule 52/69.6）——未登记=registry T02 一致性断言失败，selftest 不可被调度发现。
if grep -q 'selftest-decision-arbiter.sh' "$REGISTRY"; then ok 15 "registry 自登记行在位"; else bad 15 "registry 未登记本脚本"; fi

# DA-16 零新 config 键负断言
# What: config.json 无 arbiter 键字面 (=0) 且新增面（decision-arbiter.md + Rule 69 段）无 _enforce 新键声明 (=0)。
# Why: 69.6 承诺零新 config 键（判定面=LLM 行为+静态守护）——键字面出现=有人给判断裁决加机器门控键（机制漂移）。
# [2026-10-10 task-v154 CR fix] P1 可移植性：原写法 grep -cE '[a-z_]+_enforce' 的 `+` 量词在非 GNU/ugrep 的 POSIX grep 下当字面量，_enforce 计数恒 0（负断言假阴性、守护失效）；修法=两处均改 POSIX BRE/ERE 通吃的 [a-z_][a-z_]*_enforce（去掉 + 量词依赖）。
# [2026-10-10 task-v154 CR fix] P2-1 awk 范围：原写法 awk '/^### 69 /,0' 的 `,0` 结束模式是 GNU awk 扩展（POSIX awk 要求范围结束为 pattern）；修法=显式锚范围 /^### 69 /,/^### 7[0-9] /（69 为末节、下一规则号锚当前不存在→等价至 EOF，未来加 70+ 段自动收口）。
# [2026-10-10 task-v154 CR fix] P2-2 stderr 噪音：文件缺失时 grep 报 No such file 且 [ "" -eq 0 ] 触发 integer expression 报错；修法=文件读取加 2>/dev/null 静默 + 计数比较改字符串 = "0"（判定不变：在位正常计数、缺失则空串≠"0"→FAIL）。
if [ "$(grep -cE 'arbiter' "$CONFIG" 2>/dev/null)" = "0" ] && [ "$(grep -cE '[a-z_][a-z_]*_enforce' "$ARBITER" 2>/dev/null)" = "0" ] && [ "$(awk '/^### 69 /,/^### 7[0-9] /' "$CRIT" 2>/dev/null | grep -cE '[a-z_][a-z_]*_enforce')" = "0" ]; then ok 16 "零新 config 键：arbiter=0 且新增面无 _enforce 键"; else bad 16 "零新 config 键被破（arbiter 键或新增面 _enforce 键）"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
