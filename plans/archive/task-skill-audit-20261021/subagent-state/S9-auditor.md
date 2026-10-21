# S9 审计检查点 — 「执行中事实编造」缺陷类的守卫生口与缺口

> 审计对象：task-planner 技能体系对「未实测即断言资源事实 / 把可选规则读成唯一出路 / 把未验证结论写进规范 / 派发无产出子代理仍按已完成推进」四类行为的拦截能力。
> 靶标案例：2026-10-21 23:30:54 videop1 主会话「约束 4 禁今晚发起新创建 → 重抽**只能**明日 00:00 后」+ FACT LOCK 子代理零产物仍推进（S8 一手取证）。
> 全程只读；除本文件外未写未改任何文件；未执行任何 git 写操作。
> 复核基准：源仓 HEAD `2448e01`；部署位 `/home/terry/.zcode/skills/*` = commit `0c9a408`（落后 HEAD 19 提交）。

## 0. 复现命令（证据来源）

```bash
# ① 案发声称原文（S8 已取证，本审计复核锚）
#    /mnt/data/dev/videop1/AGENTS.md:84 约束4（可选路径原文 + 事后追加的「额度事实断言纪律」）
# ② 真事实（本审计亲自复现）
cat /mnt/data/dev/videop1/tmp/_gen-budget/video-seconds-20261021.json   # → {"used":198}
stat -c '%y' /mnt/data/dev/videop1/tmp/_gen-budget/video-seconds-20261021.json  # → 2026-10-21 23:03:58
# ③ FACT LOCK 子代理目录（本审计亲自复现）
ls -la /home/terry/.zcode/cli/agents/session_a40eae17265b5414c27e8c45d2c27b5c/agent_1537858a-ee71-4d08-a0e6-2e94853f9539
#    → 仅 metadata.json，无 output.txt / 无检查点文件
# ④ verify_done 机器门实测（本审计亲自复现，见 ③ 表 C-01）
cd /mnt/data/dev/videop1/plans/task-videop1-quotafact-001 && \
  grep -m1 '^[[:space:]]*|.*verify_done' task_plan.md | awk -F'|' \
  '{for(i=2;i<=NF;i++){v=$i;gsub(/^[[:space:]]+|[[:space:]]+$/,"",v);if(v=="verify_done"){print "FOUND "i;exit}}}'
#    → 输出空（= check-complete.sh 的列位探测取不到列 → fail-open 跳过）
```

---

## ① 三类守卫生口覆盖矩阵

### A 类 — 资源/额度/时间/约束类事实断言

| # | 守卫生口 | 位置 | 判定 | 理由 |
|---|---------|------|------|------|
| A-01 | Rule 54.1② 资源状态声称子句：「对外声称外部资源状态（配额/容量/可用性/依赖存在性）**必须附第一手查询证据**（查询时间戳+来源通道）；未经验证只能以「未验证」显式登记」 | `skills/task-discipline/references/critical-rules-discipline.md:235` | **行为门失效** | 条款字面完全对症（配额=枚举项），且本案「剩余 302s」23:25:12 已回灌主会话，属「有证据不引用」。失效原因=载体与位置：①该条位于**按需 Read** 卫星（`skills/task-planner/references/critical-rules.md:191`「卫星路由索引（11 卫星 — 非核心域规则全文按需 Read）」）；②`skills/task-planner/SKILL.md` 全文 grep「额度/配额/资源状态/推迟/一手证据」**0 命中**（实测），即常驻上下文里这条守卫没有任何指针；③该卫星在 SKILL 路由表中的「调用条件」（`SKILL.md:196`）为「执行纪律/错误闭环/证据/调研/批量/反思/注释/可靠性/能力沉淀/变更吸收」，**不含**「资源/额度断言」触发词，主进程无从判断此刻需 Read。 |
| A-02 | Rule 54.4 推迟举证四要素：「资源状态类阻塞证据必含 54.1② 第一手查询记录」「四要素缺一禁止推迟」「禁止以无举证的『次日/稍后/等条件』措辞整体押后」 | `.../critical-rules-discipline.md:241` | **行为门失效** | 这是对本案「重抽**只能**明日」最精准的拦截条款（四要素中①②③全缺：无第一手查询记录、无未阻塞子集清单、无立即执行记录）。失效原因同 A-01（卫星按需 Read + 零常驻指针）。另：条文里的执行触发词是「推迟决策」，而案发时主进程把自身表述为「物理约束」而非「我决定推迟」——术语面不匹配，规则未被识别为适用。 |
| A-03 | Rule 54.2 阻塞影响矩阵：「无第一手验证的阻塞声称不构成任何推迟依据」「未阻塞项立即执行，禁止被阻塞项连带」 | `.../critical-rules-discipline.md:237` | **行为门失效** | 同理，位于卫星、零常驻指针。本案「整线排次日」正是 54.2 禁止的「整体推迟」。 |
| A-04 | Rule 54.3 仪式性进展禁令：「写 spec、设检查点等执行准备类动作禁止作为里程碑或实质进展呈报」 | `.../critical-rules-discipline.md:239` | **行为门失效** | 直接命中「FACT LOCK 备好明日 spec」被当进展。同上失效原因。 |
| A-05 | Rule 55.2 权威来源优先禁令：「存在权威直查来源时禁止以间接推算产出该事实」「推算值必须标注未验证」 | `.../critical-rules-discipline.md:254` | **行为门失效** | 本项目已有 `agnes-quota.sh` 权威直查脚本，案发时未调用。条款正确但同样在卫星、无常驻指针。 |
| A-06 | 生成执行体 SOP 内的额度硬接线：video/image generation-executor 的「Rule 54 消费」+「额度/配额查询复用（Rule 55.1/55.5）」 | `/home/terry/.zcode/agents/video-generation-executor.md:38,43`；`/home/terry/.zcode/agents/image-generation-executor.md:42` | **部分足够（覆盖面有洞）** | 这两个执行体确实有「配额/容量/可用性附第一手查询证据」+「禁止耗时累计估算冒充额度」+「必须复用 agnes-quota.sh」的双重接线，是 A 类里**唯一真正落地到执行体 SOP 的守卫**。但覆盖只到这 2 个 agent：`executor.md`（59 行）与 `general-purpose.md`（45 行）grep「额度/配额/quota」**0 命中**。而 Rule 47.2 明确把媒体族通用兜底路由指定给 `executor(sonnet-1)`（`skills/media-planner/references/critical-rules-media.md:11`「媒体族通用兜底路由 = `executor(sonnet-1)`」）——兜底执行体恰恰没有额度守卫。本案 FACT LOCK 子代理 `profileId=general-purpose`（S8 取证），落在这个空洞里。 |
| A-07 | media-planner 卫星（Rule 47/49/50 全文）是否有资源/额度断言条款 | `skills/media-planner/references/critical-rules-media.md:1-58`（全文通读） | **缺失** | 47/49/50 覆盖拆分粒度、执行体路由、试点先行、lane 推进、条目分级；**无任何**「额度/资源状态先验后断言」条款。47.1 只在「数值上限」句里限制单次生产单元数（:11），属拆分纪律不属事实断言纪律。媒体域（本案直接所属域）零覆盖。 |
| A-08 | plan-research-router 卫星（Rule 58/63/75） | `skills/plan-research-router/references/critical-rules-research.md:23`（63.4「检索片段与本地第一手事实冲突时以本地验证为准」）、`:11`（58.3 结论-证据锚定） | **缺失（域不覆盖）** | 63.4 的「本地第一手事实优先」只约束**检索结论**，58.3 只约束**调研/分析类任务**（58.1 明示纯执行类不适用）。案发是执行类任务，两个条款都套不上。卫星内无资源状态断言条款。 |
| A-09 | 时间窗硬闸 ≠ 额度事实 的语义区分（「禁发起新创建」是调度延期，不是「没有额度」） | 技能体系全文 | **缺失** | 本案最核心的语义偷换：把「距清零 <30min 禁发起新创建」（调度闸，AGENTS.md:84 原文「降级段数**或**排次日」）读成「重抽**只能**明日」（唯一出路+额度不足）。技能体系现有 54 条全部围绕「有无一手证据」，**无一条**区分「调度规则约束」与「资源事实约束」，也无一条禁止把「禁用某动作」升格为「无资源」。该区分仅存在于 videop1 项目侧 AGENTS.md:84 的**事后追加**条款（2026-10-21 立 v2），非技能体系产物。 |
| A-10 | Rule 51.5 生成动作前置盘点 | `skills/task-planner/references/critical-rules.md:100-ish`（51.5） | **缺失（对象错位）** | 51.5 要求生成类动作前「盘点库存（在库/在用同类资产）」，盘点对象=**资产**，不含**额度/余量**。重抽前不会被该条触发。 |

**A 类小结**：对症条款**存在且措辞精准**（54.1②/54.2/54.3/54.4 四条构成完整闭环），但 100% 位于按需 Read 卫星、常驻面零指针、零机器面，属典型「条款对、位置错、无触发点」。三项真缺失：媒体域零条款、兜底执行体零接线、调度闸/额度事实语义未分离。

### B 类 — 结论固化（把未验证结论写进规范/判例/经验档/下游任务书）

| # | 守卫生口 | 位置 | 判定 | 理由 |
|---|---------|------|------|------|
| B-01 | Rule 71.2 写入前五问（pre-write 5Q gate），含「⑤我写的是『我记得/我读到过』还是『我觉得应该有』」 | `.../critical-rules-discipline.md:424` | **行为门失效（范围缺口）** | 五问本身完全对症，但枚举的写入面是「计划三文件/findings/knowledge-brief/delivery-summary/**派发任务书**/审计报告」——**不含** 项目宪法/AGENTS.md、技能规则文件、经验档（docs/experience/）、deprecated.md。本案幻觉固化的三个落点（`AGENTS.md:84` 追加段、`docs/experience/quotafact-20261021.md`、`plans/task-videop1-quotafact-001/*`）中只有第三项部分落在枚举面内。另：该五问在模板层仅接线一处（`skills/task-planner/templates/subagent_dispatch.md:107`，仅派发 prompt 面），不在任何规范写入路径上。 |
| B-02 | Rule 71.1 事实单元三态判定（有源/无源含事实/显式占位） | `.../critical-rules-discipline.md:422` | **行为门失效（无触发点）** | 三态判据本身能判出「AGENTS.md:84 那句『实余 302s…双证』是否当时在案」。但 71.4 定义它为「溯源审计 SOP（只审计不改写）」——**纯被动工具**，无任何规则要求「写入规范/判例前必须对该段跑一次溯源审计」。写入方=审计方时不会被触发。 |
| B-03 | Rule 74.2(a) 增量默认（「补充条目只追加不替代既有条目」） | `.../critical-rules-discipline.md:481` | **缺失（门方向反了）** | 追加一条「额度事实断言纪律 + 判例」在 74.2 三判里属 (a) 增量档——**默认放行、零验证要求**。74.2(b) 替代门四条件（含①「被新证据证伪」）只约束「改写既有内容」，不约束「追加新事实声称」。即：**造假以『增量』形态写入时，本门天然无阻力**。这是固化通路的结构性缺口。 |
| B-04 | Rule 74.4 定稿可行性判别门（隔离子代理三维判别） | `.../critical-rules-discipline.md:483` | **缺失（维度不含真伪）** | 三维=可执行性/相容性/风险性。(c) 相容性含「引用锚真实存在」，但「锚存在」≠「锚内容支持该结论」。判别门不判「该事实陈述是否为真」，故对「把幻觉写成判例」零拦截力。 |
| B-05 | Rule 3 双操作后立即保存（每 N 次 view/search 后写 findings） | `skills/task-planner/references/critical-rules.md:15` | **缺失** | 只管「写没写」，不管「写得真不真」，且只管 findings 一个载体。跨会话判例/规范写入完全无覆盖。 |
| B-06 | Rule 31.3 修正路由：「技能规则本体缺口 → 登记 Decisions Made + 提案写 notepad『Notes for Next Time』（本体修改走后续任务）」 | `.../critical-rules-discipline.md:76` | **行为门失效** | 路由本身正确（本案根因确属「规则缺位」），但出口只有 notepad 提案，**没有**「登记为本技能缺陷待修」的强制通道，也无「同类缺陷已在本技能内登记过吗」的查重。结果=修复从技能侧漏到了项目侧。 |
| B-07 | Rule 31.8 诉求层级契约：「制度层诉求 → 交付物=规则文本变更，落入**最贴近该问题的指令载体**（.md 条款/规则子条/模板/检查项）」 | `.../critical-rules-discipline.md:82` | **行为门失效（判据过宽致失效）** | 「最贴近的载体」在本案被解释为「videop1 项目的 AGENTS.md」——从项目视角看这是**合规交付**（条款在位、覆盖该问题模式），于是 31.8 的验收判据（「文本条款在位且覆盖该问题模式」）**通过**。技能体系无法区分「项目级补丁」与「体系级补漏」，本门因此成了漏修的合法化通道。 |
| B-08 | Rule 58.3 结论-证据锚定与反证检查（「结论定稿前必须过反证检查——显式列出哪个证据可能反驳本结论」） | `skills/plan-research-router/references/critical-rules-research.md:11` | **缺失（域不覆盖）** | 反证检查是本类缺陷的天然解药（反证证据=账本 used=198 与 302s 回执，两者均早于声称）。但 58.1 限定适用面=「调研/分析/评估/归因/优化类任务，判别特征：产出=结论/判断/建议/原因解释」，本案为执行类任务，不触发。**执行类任务的结论同样需要反证检查，但无条款承接。** |
| B-09 | Rule 80 用户会话逐字记录（append-only） | `skills/task-planner/SKILL.md:172`（摘要行）/ `skills/task-planner/references/critical-rules.md:139` | **不足（非本类守卫）** | 只保证用户原话不失真，不校验由用户原话衍生的规范条款是否越界（「用户事后定性」经 80 忠实记录后，反而获得了「有权威源」的外观——见 ② 表）。 |

**B 类小结**：写入前的自检机制（71.2 五问）存在但对**规范/判例/经验档**三种载体不覆盖；吸收门（74.2）在「增量」方向零验证要求；判别门（74.4）不判真伪。**本类是三面中拦截力最弱的一面——固化通路上不存在任何「事实核验」环节。**

### C 类 — 子代理产出验证 / 虚假进展

| # | 守卫生口 | 位置 | 判定 | 理由 |
|---|---------|------|------|------|
| C-01 | Rule 22.5 交接登记「verify_done 双条件（Read 实际产出 + findings 复核/回填），两动作完成才可勾」 | 规则：`skills/task-dispatch/references/critical-rules-dispatch.md:63`；机器门：`skills/task-planner/scripts/check-complete.sh:1736-1750` | **机器门已死（P0，实测复现）** | 门逻辑用 `awk` 要求表头存在**恰好等于 `verify_done`** 的单元格（`check-complete.sh:1747`：`if(v=="verify_done")`）。但真实模板的表头把该列**折叠**进备注列：`skills/task-planner/templates/task_plan.md:497` 定义「备注列 = 低频列折叠单列(…;verify_done☐ = Read 产出 + findings 复核/回填双条件)」，实际表头单元格文本是 `备注(rescue/retry/verify_done)`。本审计在真实计划 `plans/task-videop1-quotafact-001/task_plan.md:257` 上实测列位探测**返回空** → `comp_vd_col` 为空 → 按脚本自身注释「表头无该列 → fail-open 跳过」，整段 verify_done 检查被静默跳过。selftest 之所以全绿：`selftest-delegation.sh:86,257,298,344,384` 的夹具表头是 10 列裸 `verify_done`，与真实模板不一致。**结论：机器门只在夹具上活、在生产上死。** |
| C-02 | 模板自述「verify_done 无机器消费…为人工义务，不声称机器门」 | `skills/task-planner/templates/task_plan.md:497` | **规范自相矛盾（信息失真）** | 该句断言「grep 实证 scripts/*.sh 除 selftest 零命中」，但 `check-complete.sh:1736` 起确有消费代码（实测）。模板因此**主动免除了**机器门的心智预期，读者被引导为「这是人工自觉即可」，与存在的机器门相互抵消。这本身即一条写入规范未被复核的事实错误（与本案缺陷同类）。 |
| C-03 | SKILL.md 合规清单 G6「Handoff verify_done 已勾（Read+回填双条件）」 | `skills/task-planner/SKILL.md:152` | **行为门失效（纯人工勾）** | G6 是全清单里唯一涉及子代理产出验证的项，形态是 `☐` 手工勾选，无机器支撑（下游机器门已死，见 C-01）。勾选者=被检者，属自证。 |
| C-04 | Rule 26 Q4「未 Read 子代理产出」判定式 | `skills/task-planner/references/critical-rules.md:62` | **行为门失效（判定式绑定自证变量）** | 判定式原文：「Handoff 登记表该 Phase 行 `verify_done` 未勾或 progress.md 无 Read 复核记录，而该 Phase 已标记 complete」。两个变量均为自报：(a) `verify_done` 勾选由主进程自己勾；(b)「progress.md 无 Read 复核记录」依赖主进程主动写负面记录。`check-complete.sh` 内对 Q4 的独立检查 **grep 0 命中**（实测），即 Q4 无机器面。本案 FACT LOCK 无任何产物，只要勾上 ☐ 就合规。 |
| C-05 | Rule 26 Q3「证据不实」判定式 | `skills/task-planner/references/critical-rules.md:61` | **行为门失效（抽查面可为空）** | 判定式=「抽查 ≥3 条 Evidence，任一条路径 Read 失败或与声称矛盾」。本案推进「已备好明日 spec」时**未登记任何 Evidence 行**（无产出→无证据可抽），抽查集合为空→判定式恒过。规则未规定「声称完成但 Evidence 集合为空」这一情形，属**空集豁免漏洞**。 |
| C-06 | Rule 73.1④ 变更型决策点：「采信可疑结论（含**采信子代理自报 done 前的复核结论**、把未验证推测当事实）」 | `.../critical-rules-discipline.md:464` | **错靶（问了不该问的）** | ④ 精准点名了本案行为，是本类唯一在字面上直接命中「采信子代理自报 done」的条款。但 73.2 对齐三问的 ①读什么 只要求回读「不变量声明区 + 用户需求原文 + findings 结论 + 被否决方案」，②判什么 只判「是否触碰不变量」，③验什么 只「对照不变量声明复验」——**三问全都不问「产物是否真的存在」**。以不变量为核心的对照框架，无法发现「根本不存在的产出」。另 `check-complete.sh [judge-gate]` 默认 warn（`.../critical-rules-discipline.md:474` 自述），不阻断。 |
| C-07 | Rule 22.8 T5「任务结束必写最终结论段落盘（防返回消息丢失）」+ 22.8.2 短任务豁免（≤15min） | `skills/task-dispatch/references/critical-rules-dispatch.md:69` | **行为门失效（无校验）** | FACT LOCK 运行 84 分钟（23:39:30→01:03），远超 15min 豁免线，T5 应为**必做**，且检查点文件应存在于 `<plan-dir>/subagent-state/`。实际子代理目录只有 `metadata.json`（本审计复现），检查点缺失=违反 22.8。但无任何机器门校验「派发过的子代理是否存在检查点/产物」，只能靠主进程主动查。 |
| C-08 | Rule 62.2/62.3 派发契约不可收窄 + 双落盘（子代理必写 findings 小节） | `skills/task-planner/references/critical-rules.md:115`（62.2/62.3） | **行为门失效（无产出检测）** | 契约要求子代理自写 `#### [sub:…]` 小节。本案子代理既无 output.txt 也无 findings 小节——契约被违反，但检查面是 `check-dispatch.sh` 对 **prompt 措辞**的 lint（写入前检查），**不是**对「返回后是否真有该小节」的事后检查。写入前门拦不住下游不执行。 |
| C-09 | 终验 Handoff 抽查的整体档位 | `skills/task-planner/scripts/check-complete.sh:1755`（`[compliance] WARNING (… warn 档不阻断 …)`） | **fail-open 体系** | 即使 C-01 的列位匹配成功，缺项输出也只是 `WARNING … warn 档不阻断`，exit 0 照常放行。规则文本要求的「强制回炉」（Rule 26.3）在机器面无对应强度。 |

**C 类小结**：规则文本层完备度**最高**（22.5 + 26 Q3/Q4 + 73.1④ + 22.8 T5 四重覆盖），但**机器面全线 fail-open**：唯一把 22.5 落成机器的 check-complete 段因列名折叠而静默失效，且即使命中也只是 warn。这解释了「派发无产出仍推进」为何在四重规则下不被拦——四条都要求「有人主动去查」，而没有一条能「被动发现」。

---

## ② 固化通路审计表（幻觉 → 规范的写入路径）

| # | 通路环节 | 相关条款 / 位置 | 是否拦截 | 依据与判定 |
|---|---------|----------------|---------|-----------|
| F-01 | 判例/规范追加的变更类型判定 | Rule 74.2(a) 增量默认 — `.../critical-rules-discipline.md:481` | **否（门方向反）** | 「追加一条纪律+判例」= 纯增量 → 默认放行、零验证。四条件替代门（:481 (b)）只约束「改写」。**造假以增量形态写入时无阻力**。 |
| F-02 | 变更标注表的「依据」列 | Rule 74.3(a) — `.../critical-rules-discipline.md:482` | **否（依据可采信用户事后定性）** | 标注表要求填「依据（用户原话或证据）」。本案依据=用户事后面板报数（`plans/task-videop1-quotafact-001/user-session-log.md:13-18`）。规则不要求区分「事件发生时刻在案的一手证据」与「事后补的定性」，两者同权。 |
| F-03 | 写入前事实自检 | Rule 71.2 五问 — `.../critical-rules-discipline.md:424` | **否（载体不在枚举面）** | 五问的写入面枚举止于「派发任务书/审计报告」，**不含** `AGENTS.md` / 规则文件 / `docs/experience/*.md` / `deprecated.md`。三个主要固化落点里两个在枚举外。 |
| F-04 | 溯源审计 | Rule 71.4 SOP — `.../critical-rules-discipline.md:425` | **否（被动工具，无触发点）** | 71.4 自述「只审计不改写…由调用方执行」。无任何条款规定「写规范/判例前必须先审计该段」。谁写谁审，永不触发。 |
| F-05 | 定稿判别门 | Rule 74.4(c) 三维 — `.../critical-rules-discipline.md:483` | **否（维度不含真伪）** | 可执行性/相容性/风险性三维皆不判「该事实是否为真」。「相容性=引用锚真实存在」只能确认锚存在于某处，不能确认锚支持该句结论。 |
| F-06 | 反证检查 | Rule 58.3③ — `skills/plan-research-router/references/critical-rules-research.md:11` | **否（域不覆盖执行类任务）** | 58.1 明示「纯执行类任务不适用本条」。案发为执行类，反证检查不可用——而本案恰恰有现成反证（账本 used=198 @23:03:58、302s 回执 @23:25:12，均早于 23:30:54 的声称）。 |
| F-07 | 时序判据（证据是否在声称**之前**在案） | 技能体系全文 | **缺失** | 现有全部证据类条款（43.1/54.0/71.1）只判「有无来源」，**不判「来源时间是否先于声称时间」**。本案幻觉之所以能固化，正因「198/500 与用户面板双证」在**事后**成立——时序上不成立为「当时依据」，但被写成「双证」。无条款承接该维度。 |
| F-08 | 跨会话判例的权威性校验 | §三 反造谣（`/home/terry/.zcode/AGENTS.md` 宪法层）、Rule 3 — `critical-rules.md:15` | **否** | 宪法 §三 的「执行证据/产出证据/验证证据」三条件约束的是「声称完成」，不约束「把结论写入规范」这一动作本身。跨会话写入的行为体（写规范的主进程）不被视为「声称完成」，三条件不被触发。 |
| F-09 | 缺陷修复的归属路由 | Rule 31.3 — `.../critical-rules-discipline.md:76`；Rule 31.8 — `:82` | **否（漏到项目侧）** | 31.3 技能本体缺口的唯一出口=「notepad 提案 + 本体修改走后续任务」，无强制登记通道、无查重；31.8 验收判据「文本条款在位且覆盖该问题模式」被「项目级 AGENTS.md 补丁」满足 → 视为合规交付。结果：体系缺漏在项目侧被合法掩盖。 |
| F-10 | 下游任务书的传递 | Rule 71.5 派发防幻觉契约行 — `.../critical-rules-discipline.md:426`；`templates/subagent_dispatch.md:106` | **部分** | 契约段要求「全部事实性输出必须带来源锚 … 信息缺失一律显式『未验证』」。但它约束的是**子代理输出**，不约束**主进程写进任务书的前提**。本案任务书「约束 4 禁创建；只产 spec 供明日发起」的前提（额度不足）未经核验即下传，子代理按契约如实执行了一个错误前提。 |

**② 小结**：固化通路共有 9 个可识别环节（F-01…F-09），**拦截率 0/9**。其中 F-01（增量默认）、F-03（载体枚举缺口）、F-07（时序判据缺失）是三条结构性断点。

---

## ③ 虚假进展审计表（派发无产出仍按已完成推进）

| # | 条款（本应拦住） | 位置 | 本案为何未生效 |
|---|----------------|------|---------------|
| V-01 | Rule 22.5 verify_done 双条件 | `.../critical-rules-dispatch.md:63`（规则）/ `check-complete.sh:1736-1750`（机器） | **机器门静默失效（P0）**。真实模板列名折叠为 `备注(rescue/retry/verify_done)`，脚本要求精确 `verify_done` → 列位探测返回空 → fail-open 跳过（本审计在真实计划上实测）。规则文本强，机器面死。 |
| V-02 | SKILL G6「Handoff verify_done 已勾」 | `skills/task-planner/SKILL.md:152` | **纯人工勾选**，无机器支撑（下游即 V-01 的死门）。勾选=自证，勾上即合规。 |
| V-03 | Rule 26 Q4「未 Read 子代理产出」 | `critical-rules.md:62` | **判定式绑定自证变量**：以 `verify_done` 未勾为判定输入（该变量本身失效/可自勾）。且 `check-complete.sh` 对 Q4 无独立检查（grep 0 命中）。 |
| V-04 | Rule 26 Q3「证据不实」 | `critical-rules.md:61` | **空集豁免**：判定式需「抽查 ≥3 条 Evidence」，本案 0 条 Evidence 登记 → 抽查面为空 → 恒过。规则未定义「以零证据声称进展」如何判。 |
| V-05 | Rule 73.1④「采信子代理自报 done 前的复核结论」 | `.../critical-rules-discipline.md:464` | **错靶**：73.2 三问只回读不变量/需求原文/findings，不核产物存在性；`[judge-gate]` 默认 warn（:474 自述）。 |
| V-06 | Rule 22.8 T5 + 22.8.2 短豁免边界 | `.../critical-rules-dispatch.md:69` | **无校验**：84min > 15min 豁免线 → T5 必做、检查点必在；实际只有 metadata.json（复现）。无任何门检查「派发过的子代理有无检查点/产物」。 |
| V-07 | Rule 62.2 派发契约不可收窄 | `critical-rules.md:115` | **检查面错位**：`check-dispatch.sh` 只 lint prompt 措辞（派发前），不校验返回后 findings 小节是否真存在（派发后）。 |
| V-08 | 终验 Handoff 抽查档位 | `check-complete.sh:1755` | **warn 不阻断**：即使 V-01 命中，输出 `WARNING … warn 档不阻断`，exit 0 放行。Rule 26.3 要求的「强制回炉」在机器面无对应强度。 |
| V-09 | 执行期 Phantom 产物检测（子代理声称 done 但无产物） | 技能体系全文 | **完全缺失**：四重规则（22.5/26Q3/26Q4/73.1④）均要求「有人主动去查」；无一条能「被动发现」。无脚本比对「Handoff 声称的产物路径是否在位」。 |

**③ 小结**：条款覆盖面 4/4（22.5、26 Q3、26 Q4、73.1④ 全在），生效面 0/4。共性失效机制=**判定输入为自报变量**、**机器门 fail-open**、**检查时点在派发前而非返回后**。

---

## ④ 补强方向清单（可落地，不含实现代码）

> 目标一致：把「条款对、位置错、无触发点」的行为门，改成「常驻面有指针 / 机器面有 fail-closed 检测」的实体门。
> 分级：D-01…D-05 = CRITICAL（本案直接失守面）；D-06…D-10 = WARNING；D-11…D-14 = SUGGESTION。

| 编号 | 目标文件（节） | 条款性质 | 增量/替代/删除 | 依据 |
|------|--------------|---------|---------------|------|
| **D-01** | `skills/task-planner/templates/task_plan.md:497-498`（Handoff 表头与列说明） | **机器门修复**：把 `verify_done` 从备注折叠列中还原为**独立列**（表头单元格严格等于 `verify_done`），使 `check-complete.sh:1747` 的列位探测可命中；同步修正 :497 那句与事实相反的「verify_done 无机器消费（grep 实证…零命中）」 | **替代**（改表头 + 改一句失真陈述） | C-01 / C-02：实测列位探测返回空；`check-complete.sh:1736,1747` 确有消费代码 |
| **D-02** | `skills/task-planner/scripts/check-complete.sh:1747`（列位探测） | **机器门加固**：列名匹配改为「含 `verify_done` 子串」的容错匹配；探测不到列时由 fail-open 改为 **fail-closed**（输出 `[handoff] 表头缺 verify_done 列 → FAIL`）。**需要机器门**。 | **替代**（改判据方向） | C-01；脚本原注释「表头无该列 → fail-open 跳过」= 结构性后门 |
| **D-03** | `skills/task-planner/scripts/check-complete.sh`（COMPLIANCE 段，:1755 附近） | **档位升级**：Handoff 缺项由 `warn 不阻断` 升为 exit 1（至少对「声明了子代理 Executor 且 verify_done 未勾」这一子类），与 Rule 26.3「强制回炉」对齐。**需要机器门**。 | **替代** | C-09 / V-08：`check-complete.sh:1755` 自述 warn 档不阻断 |
| **D-04** | 新增检测点（`check-complete.sh` 或独立脚本），无对应条款 | **新增条款+机器门**：「子代理产物存在性比对」——凡 Handoff 行 status=done，其 `files`/`checkpoint` 列所指路径必须实际在位（`test -e`），任一缺失=FAIL。这是 V-09 的空缺。**需要机器门**。 | **增量**（新条款 + 新检测点） | V-09（完全缺失）；C-07（本案仅 metadata.json 无 checkpoint） |
| **D-05** | `skills/task-planner/references/critical-rules.md`（Critical Rules 指针节，:206-220） | **常驻指针补齐**：把 Rule 54.1②/54.2/54.4 的**一行摘要**加入 SKILL 常驻指针区（「资源/额度断言须附当刻第一手取数，未取数只能说『未知』；推迟须四要素举证」）。当前 SKILL.md 对「额度/配额/资源状态」grep **0 命中**。 | **增量**（补一行摘要，不动 Rule 54 正文） | A-01/A-02/A-03：条款在卫星，常驻面零指针；`SKILL.md:191` 自述卫星「按需 Read」 |
| **D-06** | `skills/task-planner/SKILL.md:196`（卫星路由表 task-discipline 行的「调用条件」列） | **触发词补齐**：调用条件增加「资源/额度/配额状态断言」「推迟/排次日/停批决策」「采信子代理结论」三类触发词。 | **替代**（改该行调用条件枚举） | A-01：现枚举不含资源断言面，主进程无从判断需 Read |
| **D-07** | `skills/task-discipline/references/critical-rules-discipline.md`（Rule 54 区，:235 后） | **新增子条 54.7「调度闸≠额度事实」**：「禁用某动作/时间窗硬闸/资源相争」类约束**不得**转述为「资源耗尽/没有额度」类事实断言；调度延期必须显式标注为「调度规则约束（非资源事实）」。**本案核心语义偷换的专用条款**。 | **增量**（纯追加子条） | A-09：技能体系全文无此区分；该区分仅存在于 videop1 AGENTS.md:84 事后追加条款 |
| **D-08** | `skills/task-discipline/references/critical-rules-discipline.md:424`（Rule 71.2 写入面枚举） | **枚举扩容**：写入面枚举追加「项目宪法/AGENTS.md、技能规则文件、经验档（docs/experience/）、deprecated.md」。 | **替代**（扩枚举） | B-01：现枚举不含规范/判例/经验档三类载体 |
| **D-09** | `skills/task-discipline/references/critical-rules-discipline.md`（Rule 74 区，:481 后） | **新增第 (e) 档「判例写入门」**：任何把「某次事故/某条结论」写成规则判例的追加动作，须附①事件时刻在案的一手证据锚（非事后补证）②时序声明（证据时间 ≤ 声称时间）③反证检查结果。**判例写入不得走 (a) 增量零验证档**。 | **增量**（纯追加档位，不动 (a)(b)(c)） | F-01（增量默认零验证）、F-07（无时序判据） |
| **D-10** | `skills/task-discipline/references/critical-rules-discipline.md:425`（Rule 71.4 SOP） | **触发点补齐**：把「溯源审计」从被动工具改为**写入前强制动作**——写入规范/判例/经验档前必须对该段跑 71.1 三态审计并留痕（审计结论入 findings.md）。 | **替代**（被动→强制） | B-02：71.4 自述「只审计不改写…由调用方执行」，无触发点 |
| **D-11** | `skills/task-planner/templates/delivery-summary.md`（交付总结五要素区） | **字段补齐**：增加「结论一手证据」列——每条结论性陈述须填「证据路径 + 证据时间戳 + 是否早于声称时刻」。当前 delivery-summary 的「真实进展对照」行（:34）只要求「引用落盘锚」，不要求时序。 | **增量**（加一列/一行要求） | F-07；delivery-summary.md:34 现只锚「落盘锚」不含时序 |
| **D-12** | `skills/media-planner/references/critical-rules-media.md`（Rule 47 区） | **新增资源面**：媒体域增加一条指针——生成/重抽类动作前须按 task-discipline Rule 54.1② 出当刻额度实取记录（本卫星不重复定义，只立指针）。当前媒体卫星 47/49/50 全文无资源断言条款。 | **增量**（纯指针行） | A-07：media 卫星 1-58 行通读，零额度条款 |
| **D-13** | `/home/terry/.zcode/agents/executor.md`（SOP 区）与 `general-purpose.md` | **执行体接线补齐**：按 Rule 55.5「执行体接线」口径，为 `executor`（媒体族通用兜底，Rule 47.2 指定）补「Rule 54 消费」+「额度查询复用」两行（对齐 video/image executor 现有行样式）。 | **增量**（两行指针，复制既有样式） | A-06：Rule 47.2 指定 executor 为媒体兜底，但 executor.md/general-purpose.md grep 额度 **0 命中**；Rule 55.5 只接线了两个专用执行体 |
| **D-14** | `skills/task-planner/scripts/selftest-delegation.sh:86,257,298,344,384`（夹具表头） | **夹具对齐真实模板**：把夹具表头由 10 列裸 `verify_done` 改为真实模板的折叠形态（或反之统一），使 selftest 能捕获 D-01 类「生产模板与夹具不一致」缺陷。**需要机器门（selftest 断言）。** | **替代**（改夹具） | C-01：夹具与真实模板不一致 → 门死而 selftest 全绿 |

**补强方向合计 14 条**：CRITICAL 5（D-01…D-05）、WARNING 5（D-06…D-10）、SUGGESTION 4（D-11…D-14）；其中需机器门 4 条（D-02、D-03、D-04、D-14）。

---

## ⑤ 部署位漂移（影响现行实际加载能力）

| 项 | 事实 | 证据 |
|----|------|------|
| 版本落后 | `.zcode` 部署位 SKILL.md == commit `0c9a408`（2026-10-21 10:04），落后 HEAD `2448e01` **19 提交** | `plans/task-skill-audit-20261021/subagent-state/S2-explore.md:114`；本审计 `git log` 复核 |
| Rule 93 缺失 | 部署位 `critical-rules-discipline.md` 588 行 vs 源 602 行，缺 Rule 93 全条（规范再召回纪律） | `diff` 输出 `588a589,602`；`grep -c "### 93 规范再召回"` 部署位=0 / 源=1 |
| 召回卡缺失 | `execution-recall-card.md` 不在部署位（`ls /home/terry/.zcode/skills/task-discipline/references/` 仅 3 文件） | 本审计实测 |
| 影响 | Rule 93 的用途正是「对抗长上下文/compaction 导致的执行规范遗忘」——本案发生于当日 23:30（长会话末段），恰恰是该机制的目标场景，而该机制在加载位**不存在** | Rule 93 建条描述 `critical-rules-discipline.md:590` |

---

## ⑥ 负结果报告（已检查、未发现违规 / 排除的可能性）

**已检查的位置（逐条列出）**
- 核心域：`skills/task-planner/references/critical-rules.md` 全文 203 行（Rule 1/2/3/5/19/20/26/51/62/66/80/81/82/83 + 卫星路由索引）
- 纪律卫星：`skills/task-discipline/references/critical-rules-discipline.md` 602 行，**逐条通读了本任务相关的 Rule 31/31.8/35/43/44/45/54/55/58（跨引用）/65/71/73/74/87/89/93**
- 调研卫星：`skills/plan-research-router/references/critical-rules-research.md` 全文 68 行（58/63/75）
- 媒体卫星：`skills/media-planner/references/critical-rules-media.md` 全文 58 行（47/49/50）
- 执行体 6 个：`video-generation-executor.md`(70) / `image-generation-executor.md`(69) / `executor.md`(59) / `general-purpose.md`(45) / `agent-quality-auditor.md`(105) / `drift-checker.md`(36)
- 模板 2 个：`templates/subagent_dispatch.md`（含 :106 防幻觉契约 / :107 五问）/ `templates/delivery-summary.md`（含 :34 真实进展对照）
- 脚本：`check-complete.sh:1736-1760` / `auto-finalize.sh:76-83` / `selftest-execution-honesty.sh` / `selftest-delegation.sh:86,257,298,344,384`
- 部署位：`/home/terry/.zcode/skills/{task-planner,task-discipline,media-planner,plan-research-router}` 与源仓 `diff -rq`（排除 `.backup`）

**预期有缺陷但实际未发现的问题（防止后续重复排查）**
- **Rule 54 并非缺失**：四条子条（54.0-54.5）措辞精准、互不重叠，`selftest-execution-honesty.sh` 的 EH-01…EH-10 断言全部在位。本类缺陷**不是「没写规则」，而是「写了但主上下文看不到」**。任何「补写 Rule 54」的方案都是重复劳动。
- **media 卫星不存在隐藏的资源条款**：47/49/50 全 58 行已通读，确认无额度/配额条款（是「缺失」而非「漏读」）。
- **`image-generation-executor` / `video-generation-executor` 的额度接线是完整的**：两层（Rule 54 消费 + Rule 55.1/55.5 脚本复用）都在，`agnes-quota.sh` 路径正确。洞只在 `executor`/`general-purpose`。
- **`selftest-execution-honesty.sh` 未假装自动判幻觉**：脚本注释与 Rule 54.6/71.7 均**如实披露**「判定面=LLM 行为，非机器触发」——不是欺骗性守卫，而是诚实的能力边界声明。这是优点，应保留于 D-05 补强之后（不要把它改写成「已自动守护」）。
- **Rule 3 不存在被误读的空间**：其原文极短（`critical-rules.md:15` 一句），用途明确，无歧义。

**已排除的可能性**
- 排除「守卫条款被删除/回退」：git 历史未见 Rule 54/71/74 的删除提交；HEAD 内容完整。
- 排除「本项目未部署 task-discipline 卫星」：`/home/terry/.zcode/skills/task-discipline/` 存在且含 Rule 54（10 处命中）。
- 排除「check-dispatch.sh 能拦住任务书错误前提」：该脚本只 lint prompt 结构与措辞（Rule 62.2 契约收窄词），不做事实核验。
- 排除「Rule 26 Q4 有独立机器实现」：`grep -n "Q4\|未 Read 子代理产出" check-complete.sh` **0 命中**。

**未验证项（如实标注）**
- 案发时主会话实际加载了哪些技能文本，无直接读取通道（会话 parts 仅含消息体，不含 skill 注入快照）→ 「SKILL.md 无常驻指针」结论基于「文件内容事实」而非「会话加载实况」。判定强度：MEDIUM-HIGH。
- videop1 侧是否存在独立的额度查询 wrapper 脚本被调用，未逐脚本核查（超出本审计范围）。

---

## ⑦ 最严重三条缺口（摘要）

1. **Rule 22.5 verify_done 机器门在生产中静默失效（P0）**——真实模板把该列折叠进 `备注(rescue/retry/verify_done)`，`check-complete.sh:1747` 精确匹配 `verify_done` 取不到列位 → fail-open 整段跳过；selftest 夹具用裸 `verify_done` 列故全绿。机器门只活在夹具上。见 C-01 / D-01 / D-02。
2. **资源/额度断言守卫条款全在「按需 Read」卫星，常驻面零指针（P0）**——Rule 54.1②/54.2/54.3/54.4 构成完整闭环且措辞精准，但 `SKILL.md` 对「额度/配额/资源状态/推迟」grep 0 命中，卫星路由表的调用条件也不含资源断言触发词。条款对、位置错、无触发点。见 A-01…A-04 / D-05 / D-06。
3. **固化通路 9 个环节拦截率 0/9，「增量默认」使幻觉以追加形态零验证进入规范（P0）**——Rule 74.2(a) 追加即放行，Rule 71.2 五问的写入面不含规范/判例/经验档，Rule 58.3 反证检查不覆盖执行类任务，且全体系无「证据时间是否早于声称时间」的时序判据。见 F-01/F-03/F-06/F-07 / D-08 / D-09。

（另记：部署位落后 19 提交且缺 Rule 93 召回机制——该机制的目标场景（长会话末段规范衰减）恰是本案发生场景，见 ⑤。）
