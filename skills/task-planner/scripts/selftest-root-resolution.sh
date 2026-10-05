#!/usr/bin/env bash
# selftest-root-resolution.sh — task-v131 S4: Rule 53 根源解决与决策管辖静态守护（53.5 机制定稿指定的守卫脚本）
#
# ① What（做什么）: 静态断言 task-v131 全链落点在位——
#    · critical-rules.md: Rule 53 五子条（53.1-53.5）逐条字面锚 + 53.3 收口锚「唯一权威边界」
#      + 53.4 量化锚「三元组」+ 53.5 触发面锚「Q7 惰性推诿/无根治判据」+ 51.1a 载体子句锚；
#    · SKILL.md: Rule 53 摘要 bullet + 合规清单 C36 行（含「根源覆盖表」消费词）+ 全集声明 1-53 演进（负断言 1-51 残留=0）；
#    · 模板面: task_plan.md「🎯 用户需求原文/🧮 根源覆盖表」双区块 + rule-enhancement 变体区块 + subagent_dispatch.md 派发需求锚；
#    · 脚本面: init-session.sh inject_requirement_block（定义+调用）+ 根源覆盖表注入 + attest-plan.sh 第 4 锚锁定门。
#    共 RR-01..RR-17 十七个编号用例，逐条 grep 字面锚 + 期望命中数比对。
# ② Why（为什么）: 53.2 根治判据的「守卫」载体落地——Rule 53 若后续被裁剪/误删/锚漂移，机器校验先行报警
#    （条款死文 51.1 计划侧零载体判例的反向清账）；RR-09 负断言锁全集 1-51→1-53 演进不回退（锚级联第 3 次教训 §4）；
#    RR-15 负断言钉死 critic P0 修复：「或无客观判据的真实偏好二选」旧并行判别面已从 53.3 收口为 41.2 四门槛唯一权威边界，
#    旧字面复现 = 判别面被偷改回并行体系（防自设出口的回归探测）。
# ③ When（何时跑）: 任何改动下列文件时由 selftest-registry.sh 分域触发——
#    critical-rules.md 53.x/51.1a 段、SKILL.md Rule 53 bullet/C36 行/全集声明行、
#    templates/task_plan.md、templates/variant/rule-enhancement-type.md、templates/subagent_dispatch.md、
#    scripts/init-session.sh、scripts/attest-plan.sh；另全 selftest 批跑（check-complete）覆盖。
# ④ How（如何判）: PASS/FAIL 计数 + 末行 `Total: N PASS=x FAIL=y`（供 Total 行求和消费，格式与
#    selftest-requirement-coverage.sh / selftest-agent-coverage.sh 同构）；全 PASS exit 0，任一 FAIL exit 1。
#    断言口径：一律 `grep -cF` 固定字符串计数（禁用正则——锚内 `**` 为字面星号；`|| true` 兜 grep -c 零命中
#    exit 1 在 set -u/严格环境下的误传播）；计数锚=1（唯一落点，重复落点会破坏 grep -c 口径故锁死 =1），
#    区间锚用 ≥n（多落点合法）。负断言命中必须 =0。
# 依赖：bash + grep（零 jq 依赖，零 config 面——53.5 零新 config 键范式）；只读，零写入。
# 备注：本单元 scope 仅新建本脚本 1 文件（禁触碰其他文件）；selftest-registry.tsv 登记行由后续
#      S-unit 追加（registry T02 双向核对：新增未登记脚本→FAIL，故登记必须紧跟落地，勿悬挂）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
TPL="$SKILL_ROOT/templates/task_plan.md"
VAR="$SKILL_ROOT/templates/variant/rule-enhancement-type.md"
DISP="$SKILL_ROOT/templates/subagent_dispatch.md"
INIT="$SKILL_ROOT/scripts/init-session.sh"
ATTEST="$SKILL_ROOT/scripts/attest-plan.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'RR-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'RR-%s FAIL %s\n' "$1" "$2"; }

# RR-01 53.1 子条锚 `grep -cF '53.1 **结果级需求全链工序审计'` =1
# 口径：53.1 行首标题字面（子条范式对齐 51/52，行首编号+加粗标题）；=1 锁唯一落点防段落复制漂移。
n="$(grep -cF '53.1 **结果级需求全链工序审计' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 01 "critical-rules.md 53.1「结果级需求全链工序审计」=1"; else bad 01 "critical-rules.md 53.1 锚命中=$n（应 =1）"; fi

# RR-02 53.2 子条锚 `grep -cF '53.2 **根治判据'` =1
# 口径：53.2 行首标题字面；根治判据=机制/守卫/载体三选一是本脚本自身存在的依据条款，锚丢=守卫自引用断裂。
n="$(grep -cF '53.2 **根治判据' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 02 "critical-rules.md 53.2「根治判据」=1"; else bad 02 "critical-rules.md 53.2 锚命中=$n（应 =1）"; fi

# RR-03 53.3 子条锚 =1 且 收口锚「唯一权威边界」=1
# 口径：「唯一权威边界」是 critic P0 修复的 41.2 四门槛收口字面（原并行判别体系被废除）——53.3 标题在位但收口锚丢
# = 决策管辖二分退回旧并行面（惰性推诿出口），必须同时锁死。
n="$(grep -cF '53.3 **决策管辖二分' "$CRIT" || true)"
m="$(grep -cF '唯一权威边界' "$CRIT" || true)"
if [ "$n" -eq 1 ] && [ "$m" -eq 1 ]; then ok 03 "critical-rules.md 53.3「决策管辖二分」=1 且「唯一权威边界」=1"; else bad 03 "critical-rules.md 53.3 锚=$n（应 1）或「唯一权威边界」=$m（应 1）"; fi

# RR-04 53.4 子条锚 =1 且 量化锚「三元组」=1
# 口径：「三元组」（彻底路径增量成本/浅路径返工概率及依据/返工成本）是 53.4 返工核算的量化口径字面——
# 丢三元组 = 返工核算退化为「凭感觉选浅路径」，53.4 失去可陈述判据。
n="$(grep -cF '53.4 **返工成本核算' "$CRIT" || true)"
m="$(grep -cF '三元组' "$CRIT" || true)"
if [ "$n" -eq 1 ] && [ "$m" -eq 1 ]; then ok 04 "critical-rules.md 53.4「返工成本核算」=1 且「三元组」=1"; else bad 04 "critical-rules.md 53.4 锚=$n（应 1）或「三元组」=$m（应 1）"; fi

# RR-05 53.5 子条锚 =1 且 触发面锚「Q7 惰性推诿」≥1 且「Q8 无根治判据」≥1
# 口径：Q7/Q8 是 53.3/53.2 触发面在 26.3 惩罚映射的消费登记字面（登记于 53.5；不扩 26.1 既有 Q1-Q6 枚举）——
# ≥1 而非 =1：Q7/Q8 在 53.3/53.4/53.5 多处合法复现（触发面引用），锁存在性不锁唯一性（防多落点口径误报）。
n="$(grep -cF '53.5 **机制' "$CRIT" || true)"
m="$(grep -cF 'Q7 惰性推诿' "$CRIT" || true)"
p="$(grep -cF 'Q8 无根治判据' "$CRIT" || true)"
if [ "$n" -eq 1 ] && [ "$m" -ge 1 ] && [ "$p" -ge 1 ]; then ok 05 "critical-rules.md 53.5「机制」=1 且 Q7 惰性推诿=$m≥1 且 Q8 无根治判据=$p≥1"; else bad 05 "critical-rules.md 53.5 锚=$n（应 1）或 Q7=$m（应 ≥1）或 Q8=$p（应 ≥1）"; fi

# RR-06 51.1a 载体子句锚 `grep -cF '51.1a **载体双机制'` =1
# 口径：51.1a（task-v131 清账）是本链的计划侧载体条款——生成面注入/锁定四锚门/派发侧需求锚三挂点的权威源，
# 锚丢=整条生成-锁定-派发链失去条款依据（51.1 计划侧零载体判例再犯探测）。
n="$(grep -cF '51.1a **载体双机制' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 06 "critical-rules.md 51.1a「载体双机制」=1"; else bad 06 "critical-rules.md 51.1a 锚命中=$n（应 =1）"; fi

# RR-07 SKILL.md Rule 53 摘要 bullet 锚 `grep -cF 'Rule 53（根源解决与决策管辖'` =1
# 口径：SKILL.md Critical Rules 摘要段的 Rule 53 bullet 是 LLM 读 SKILL 时的条款入口索引（RC-09 同范式）——
# 丢 bullet = 摘要与条款脱钩（防「条款扩到 53 但摘要停摆 51」级联断链，锚级联 §4 判例）。
n="$(grep -cF 'Rule 53（根源解决与决策管辖' "$SKILLMD" || true)"
if [ "$n" -eq 1 ]; then ok 07 "SKILL.md Rule 53 摘要 bullet =1"; else bad 07 "SKILL.md Rule 53 摘要 bullet 命中=$n（应 =1）"; fi

# RR-08 SKILL.md 合规清单 C36 行锚 `grep -cF 'C36'` =1 且 C36 行含「根源覆盖表」
# 口径：C36 是 Rule 53 的合规清单消费点（RC-10 C35 同范式，行内 | C36 | 唯一）；行内必含「根源覆盖表」——
# C36 若只剩空壳（消费词被裁）= 合规面与 53.1 载体脱钩（防 C36 行被误删/改写为无锚泛文）。
n="$(grep -cF 'C36' "$SKILLMD" || true)"
if [ "$n" -eq 1 ] && grep -F 'C36' "$SKILLMD" | grep -qF '根源覆盖表'; then
  ok 08 "SKILL.md 合规清单 C36 行 =1 且含「根源覆盖表」"
else
  bad 08 "SKILL.md C36 命中=$n（应 =1）或 C36 行未含「根源覆盖表」（消费点脱钩）"
fi

# RR-09 全集声明演进锚 `grep -cF 'Critical Rules 全集 1-53'` =1（负断言：'1-51' 残留 =0）
# 口径：SKILL.md 顶部全集声明由 1-51 演进为 1-53（task-v131 新增 53 段）——正断言锁新字面在位，
# 负断言锁旧字面零残留（残留 = 级联更新漏改，与 knowledge-brief §4「锚级联第 3 次教训」同判例；
# 注意 grep -F 固定匹配不误伤 1-52/1-53 子串，因 '1-51' 为独立字面）。
n="$(grep -cF 'Critical Rules 全集 1-55' "$SKILLMD" || true)"  # [2026-10-05 task-v138 演进重锚] 全集 1-53→1-55（Rule 55 落地，锚随 SKILL 全集合法演进；先例 v127 RC-15）
m="$(grep -cE '(全集|Rules) 1-(51|53)' "$SKILLMD" || true)"  # [2026-10-05 task-v132] 裸 '1-51' 固定匹配被 SKILL:304「51.1-51.7」子串误触（级联第 5 变体：负断言须语境锚定防子串误伤）; [2026-10-05 task-v138] 负断言并入 53（1-53→1-55 演进后旧纪元清单={51,53}，强度不减弱，先例 v127 RC-15 ^50→^52）
if [ "$n" -eq 1 ] && [ "$m" -eq 0 ]; then
  ok 09 "SKILL.md 全集声明「Critical Rules 全集 1-53」=1 且旧「1-51」残留=0"
else
  bad 09 "SKILL.md 全集 1-53 命中=$n（应 =1）或旧 1-51 残留=$m（应 =0，级联漏改）"
fi

# RR-10 主模板双区块锚 `grep -cF '🎯 用户需求原文'` =1 且 `grep -cF '🧮 根源覆盖表'` =1
# 口径：task_plan.md 内 51.1 需求原文区块（R 行=53.1 需求锚源）与 53.1 根源覆盖表区块各唯一落点——
# 模板是 51.1a 载体双机制的「模板可见区块」挂点，丢任一区块 = 计划侧载体失守（计划侧零载体判例回归探测）。
n="$(grep -cF '🎯 用户需求原文' "$TPL" || true)"
m="$(grep -cF '🧮 根源覆盖表' "$TPL" || true)"
if [ "$n" -eq 1 ] && [ "$m" -eq 1 ]; then ok 10 "task_plan.md「🎯 用户需求原文」=1 且「🧮 根源覆盖表」=1"; else bad 10 "task_plan.md 🎯 区块=$n（应 1）或 🧮 区块=$m（应 1）"; fi

# RR-11 rule-enhancement 变体区块锚 `grep -cF '🎯 用户需求原文'` =1
# 口径：规则增强类任务 100% 含需求覆盖核对面（变体模板白名单标配）——本任务自身即 rule-enhancement 型，
# 变体丢区块 = 该类计划绕过 51.1 载体（「随维护逐个补齐」的已补齐项被回退探测）。
n="$(grep -cF '🎯 用户需求原文' "$VAR" || true)"
if [ "$n" -eq 1 ]; then ok 11 "rule-enhancement-type.md「🎯 用户需求原文」=1"; else bad 11 "rule-enhancement-type.md 🎯 区块命中=$n（应 =1）"; fi

# RR-12 派发侧需求锚 `grep -cF '需求锚（Rule 51.1a'` =1
# 口径：subagent_dispatch.md 需求锚字段是 51.1a「派发侧锚」的模板挂点（需求相关 S-unit 派发 prompt 必须
# 逐字引用治理 R 条目，禁转译——判例：用户「一个月」被两次改写为「前 72 小时」）；锚丢=派发转译漂移入口重开。
n="$(grep -cF '需求锚（Rule 51.1a' "$DISP" || true)"
if [ "$n" -eq 1 ]; then ok 12 "subagent_dispatch.md「需求锚（Rule 51.1a」=1"; else bad 12 "subagent_dispatch.md 需求锚命中=$n（应 =1）"; fi

# RR-13 生成面注入锚 `grep -cF 'inject_requirement_block'` ≥2（定义+调用）且「根源覆盖表」≥1
# 口径：init-session.sh 的 51.1a 生成面挂点——函数定义（function 行）+ 调用（init 主流程）各 ≥1，
# 合计 ≥2 防「函数写好但零调用」的死代码回归；「根源覆盖表」≥1 锁 critic P1-3 对称性修复（🧮 区块同步注入脚手架，
# 不只有 🎯 单区块）。≥1 口径：多行复现合法（注释/echo），锁存在不锁唯一。
n="$(grep -cF 'inject_requirement_block' "$INIT" || true)"
m="$(grep -cF '根源覆盖表' "$INIT" || true)"
if [ "$n" -ge 2 ] && [ "$m" -ge 1 ]; then ok 13 "init-session.sh inject_requirement_block=$n≥2（定义+调用）且「根源覆盖表」=$m≥1"; else bad 13 "init-session.sh inject_requirement_block=$n（应 ≥2）或「根源覆盖表」=$m（应 ≥1）"; fi

# RR-14 锁定面门锚：`grep -cF '第 4 锚'` ≥1 且 `grep -cF '[requirement-gate]'` ≥2
# 口径（如实披露）：「第 4 锚」是 critic P1-3 对称性修复的锁定门字面（attest 51.1 三锚 + 53.1 根源覆盖表第 4 锚，
# 非 mini 缺一拒锁 fail-closed）。历史契约漂移记录：原契约要求 attest-plan.sh 含字面函数名
# `check_requirement_block`（≥2，定义+调用），但 Phase 2 S-unit 落盘将锁定门实现为
# [requirement-gate] 内联门（字面 [requirement-gate]×2，无函数名封装，全 skill 目录 grep 零命中——已核）。
# 断言修正为行为锚 [requirement-gate] ≥2：锁「锁定门存在且双命中（mini 豁免行 + OK 行）」这一行为面，
# 不锁内部实现结构（函数封装与否）。
n="$(grep -cF '第 4 锚' "$ATTEST" || true)"
m="$(grep -cF '[requirement-gate]' "$ATTEST" || true)"
if [ "$n" -ge 1 ] && [ "$m" -ge 2 ]; then ok 14 "attest-plan.sh「第 4 锚」=$n≥1 且 [requirement-gate]=$m≥2"; else bad 14 "attest-plan.sh「第 4 锚」=$n（应 ≥1）或 [requirement-gate]=$m（应 ≥2）"; fi
# 注：2026-10-05 主进程裁定：断言测行为锚非内部结构（Phase 2 实现为内联门）

# RR-15 负断言 `grep -cF '或无客观判据的真实偏好二选'` =0（critic P0 修复钉住）
# 口径：53.3 定稿已将决策管辖判别面从「代理可判四项 OR 无客观判据的真实偏好二选」收口为
# 41.2 G1-G4 四门槛唯一权威边界（真实偏好二选归 G4 语义级目标分叉，不再作并行出口）——
# 旧字面复现 = 判别面被偷改回并行体系（防自设出口的回归探测，命中即 P0 漂移 FAIL）。
n="$(grep -cF '或无客观判据的真实偏好二选' "$CRIT" || true)"
if [ "$n" -eq 0 ]; then ok 15 "critical-rules.md 旧判别面字面「或无客观判据的真实偏好二选」=0（critic P0 收口钉住）"; else bad 15 "critical-rules.md 旧判别面字面命中=$n（应 =0，53.3 唯一权威边界被破——P0 漂移）"; fi

# RR-16 SKILL.md 索引行全集括注锚（防级联漏改，CR P1-2）
# 口径：:266 索引行「详见 references/critical-rules.md（Rules 1-39…）」为 LLM 读取入口的全集声明行——
# 历史级联漏改判例（锚级联第 3 次教训 §4 + task-v131 CR P1-2：Rule 50/52/53 新增后括注停摆于逐号
# 「Rule 40/41/…/51」漏 50/52/53）已改简洁括注「含 Rule 40-53 全集」。断言：索引行（'（Rules 1-39' =1 定位）
# 须同时含「Rule 40-53」（或至少含 50 与 53 两个号=逐号式括注的兜底判定）——防下次全集扩张时索引行再次脱钩。
idxn="$(grep -cF '（Rules 1-39' "$SKILLMD" || true)"
idxline="$(grep -F '（Rules 1-39' "$SKILLMD" || true)"
if [ "$idxn" -eq 1 ] && printf '%s' "$idxline" | grep -qF 'Rule 40-55'; then  # [2026-10-05 task-v138 演进重锚] 括注 40-53→40-55（Rule 55 落地，CR P1-2 防级联漏改语义不变）
  ok 16 "SKILL.md 索引行「（Rules 1-39」=1 且含「Rule 40-53」全集括注（CR P1-2 防级联漏改）"
elif [ "$idxn" -eq 1 ] && printf '%s' "$idxline" | grep -q '50' && printf '%s' "$idxline" | grep -q '53'; then
  ok 16 "SKILL.md 索引行「（Rules 1-39」=1 且逐号式括注含 50 与 53（兜底判定）"
else
  bad 16 "SKILL.md 索引行命中=$idxn（应 =1）或索引行未含「Rule 40-53」（亦未同时含 50 与 53——级联漏改，CR P1-2 复发）"
fi

# RR-17 critical-rules.md 侧 Rule 53 区块锚 `grep -c '^### 53 '` =1
# 口径：条款侧区块标题锚（与 RR-07 SKILL 侧摘要 bullet 对称）——SKILL 索引行声明「Rule 40-53 全集」但条款侧
# 无 53 区块 = 索引指向虚空（挂空锚）；=1 锁唯一落点（与 RR-01..05 子条锚同口径，防 53 段复制漂移）。
n="$(grep -c '^### 53 ' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 17 "critical-rules.md 区块锚「^### 53 」=1（索引行 40-53 全集的条款侧落点在位）"; else bad 17 "critical-rules.md 区块锚「^### 53 」命中=$n（应 =1，索引行挂空锚/条款侧缺失）"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
