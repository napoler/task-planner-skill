# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1: 「优化当前项目技能的执行并行的效率……在计划初期就分析出哪些任务可以并行」——计划期依赖分析是核心诉求 [目标]
- R2: 「相互不影响的时候就可以并行执行；存在相互依赖关系就需要逐个串行……一个个击破」——可并行→并行加速,有依赖→串行 [目标]
- R3: 「最终我希望以后运行任务的时候,都可以针对可以并行的任务进行并行加速」——机制须固化进技能,长期生效 [目标]
- R4: 「workflow 会将所有的任务都丢给一个模型执行……模型消耗资源会不可控」——借鉴 workflow 并行策略,但纠正单模型缺陷 [目标]
- R5: 「学习它的并行策略,但是需要保证使用不同的 Agent,以及模型进行运作」——并行组内异构 agent 类型+模型分摊 [目标]
- R6（原 /goal 首条）:「因为当前我发现执行工作非常缓慢,我希望可以优化并行运行」——动机=执行慢 [目标]

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| dynamic-workflows SKILL/patterns/examples | /opt/ZCode/resources/glm/packages/bundled-skills/skills/dynamic-workflows/ | ☑ 2026-10-09（Explore 侦察） | Research Findings §A |
| task-planner 并行机制现状（Rule 21.4/23.9-23.13/49/43.2/52 + 守卫脚本 + 模板） | ~/.zcode/skills/task-planner/（critical-rules/SKILL/templates/scripts） | ☑ 2026-10-09（Explore 侦察） | Research Findings §B |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### §A dynamic-workflows 并行策略与模型分配（侦察日 2026-10-09，源=SK.md/patterns.md/examples.md）

- **A1 依赖表达=手工 TS 控制流，框架无自动依赖发现**：`await`=顺序依赖、`Promise.all`=fan-out 汇聚点，框架仅编译期静态读代码建依赖图（SK.md:302-306）。「哪些独立可并行」是脚本作者写 `map+Promise.all` vs `await` 的选择——**计划初期的依赖分析=作者脑中决策，不是机器分析**。
- **A2 独立任务并发机制=先发起不 await，join 处统一 await**（SK.md:307-319「Parallelism comes from *not awaiting yet*」）；`Promise.all` 是 barrier；正确模式=一对一阶段链进同一回调、外层只 join 一次（SK.md:321-345，多 barrier=错误示范）；单 item 失败 catch 在回调或 `Promise.allSettled`（SK.md:352-354）。
- **A3 并发上限=max_concurrency（run 级标量），缺省由运行时按 provider 自适应**（SKILL.md:955-959，脚本不决定并发数）。
- **A4 用户缺陷判断被 schema 级证实（核心）**：
  - `subagent_model` 是 **run 级单一字段**，缺省=会话模型（SKILL.md:115「runs on the session's model; there is no per-subagent tool profile or model choice」、960-963、1426-1427）；
  - `agent()` 工厂签名仅 `(name?, persona?)`（SKILL.md:1023），persona 创建后冻结，**无 per-task 模型覆盖、无 per-task agent 类型、无 subagent_type 字段**（三文件 grep 零命中；SKILL.md:115-119「no per-task override」）；
  - **结论：workflow 所有子任务必然跑同一模型，无法异构分摊——这正是 task-planner 的差异点与借鉴边界**。
- **A5 借鉴清单（可直接吸收的并行编排要素）**：① 先收窄再 fan-out（patterns.md:45-54）② 独立项=新上下文每项+Promise.all ③ 唯一 join 原则（SK.md:321-345）④ 命名唯一即身份 ⑤ 并发上限交运行时/用户设定 ⑥ 确定性闸门用 world.run 而非子代理（SK.md:234-241）⑦ 结果即用 report 落盘防丢失（SK.md:516-522）。
- **A6 替换关系**：workflow 的 `Promise.all` 分组 ↔ task-planner 的 `parallel_groups` 声明组；workflow 的 await 链 ↔ S-unit 前置依赖串行——**同构映射成立，可把「脚本作者的依赖决策」搬到「计划期强制依赖分析步骤」**。

### §B task-planner 并行机制现状与缺口（侦察日 2026-10-09）

- **B1 计划期无强制「依赖分析→并行分组」步骤（最大缺口）**：最接近的是 Rule 21.4 声明制（critical-rules.md:150-157：frontmatter `parallel_groups:` + S-unit 行 `[parallel-group:<组名>]` 标记，**未声明默认串行**）与 Rule 23.9 三层声明面（:210）、23.11 三检测时机（:212，①计划期静态 RefSet 交集仅面向创作单元）。**分组完全依赖计划者 LLM 自觉，机器只在执行期信任放行**。
- **B2 通用 S-unit 表无显式依赖字段**：前置依赖仅两个局部载体——Lane 状态表「前置 S-unit」列（创作单元场景,:210）与 Chain Block `depends_on`（多 skill 接力场景）；S-unit 表无 depends_on/前置列（侦察结论 C 节）。
- **B3 并行组内异构 agent/模型分配机制=零（第二缺口）**：
  - S-unit 表执行体列 `subagent_type(model)` 默认「继承」Phase Executor（critical-rules.md:187 / templates/task_plan.md）；
  - Rule 43.2 档位经济性=最小可承载档（:470）是**成本视角非负载分摊视角**；Rule 52 执行体专业化（:593）是工序视角非并行组视角；
  - parallel_groups 只管调度不管模型；frontmatter 无 model_allocation 类字段；**无任何规则约束并行组内成员用不同 agent/模型**。
- **B4 守卫现状**：check-dispatch.sh serial_slot_check（:604-634）=全局单锁+标记信任放行（双条件：frontmatter 声明∧prompt 标记），不区分组名、不做四问机器校验（:214 如实披露，预声明升级 {lane: ts} 富锁=后续任务项）；check-plan-dispatch.sh 仅硬校验执行体列+粒度三值（:242-249），**不校验 parallel_groups 声明合法性、不校验组内异构**。
- **B5 可复用资产盘点（新机制落点）**：规则层 21.4/23.11/43.2 扩展位、SKILL.md 路由表与计划撰写流程、templates/task_plan.md S-unit 表（加列安全：check-plan-dispatch 只硬校验执行体列）、check-plan-dispatch.sh（attest 期门控位）、analyze-splits.sh（现有拆分分析脚本，无依赖分析）、split-pattern-library.md（21.6.1 计划期必读）、dispatch-examples.md（22.4b 示例唯一落点）、companion/agents/plan-writer.md（计划期产出契约）。
- **B6 Rule 编号现状**：65 landed；66=v151 在途（其计划标题即 Rule 66 但漏声明 new_rule，21:39 已 attest，账本无记录——事实占用）；67=v152 reserved；**本任务已预留 68**（rule-reserve reserve 执行证据，2026-10-09 21:43）。

### §C 用户消息与素材角色判定（2026-10-09）
- 用户 /goal 首条消息=执行目标；中段「workflow 缺陷借鉴」消息=对同一目标的**方向补充（B 类扩展而非新任务）**——合并进本计划 R4/R5。goal 运行时曾报「paused」，用户新消息构成替换性新指令，按 P0-1 以用户当前指令为准。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 新 Rule 独立编号 68 而非扩展 21.4 子条 | 跨「计划期步骤+模板列+守卫+异构分配」四面，子条扩展会撑破 21.4 语义域；66/67 在途防撞号（B6） |
| 计划期强制步骤挂点=21.4 权威源+SKILL 计划撰写流程+S-unit 表加列 | B5 落点盘点；S-unit 加列经侦察确认安全（只硬校验执行体列） |
| 异构分配用「并行组内 agent 类型或模型至少一项不同」的软约束+advisory 校验起步 | 硬 enforce 需模型可用性事实源，先 advisory 防误拦（对照 43.2 既有档位表） |
| 借鉴 workflow 的是「依赖分组思想+唯一 join+先收窄」，不搬运行时调度器 | A4 schema 限制=无 per-task 模型；task-planner 的 Agent() 天然支持 subagent_type+model 异构 |
| 68.2 保留 21.4 组间串行语义不做「跨组同波并行」 | 组间并行需富锁升级（{组名:ts}，已登记后续任务项）；本任务范围内动 21.4 语义=Rule 36.4 需用户逐项确认，收益/风险不成比例；并行度收益由「组声明落地+组内多成员并行」承载 |
| CHANGELOG.md 经 B 类扩 scope 入 S7/Phase 5 范围 | 仓约定 v149/v150 均有 [Unreleased] 条目，初版 plan scope 遗漏（对照发现） |
| v151 Rule 66 已于 22:06 前合并 master（ebb5fba）并部署生效，attest 新增 Goal 单元表硬门 | git log + attest 拒锁实测双证；本计划已补 G1-G8 六列表 |
| p3-core 并行首证：三成员（longcat/agnes/agnes 三面混派）同消息派发 6min 全完成，串行预估 ~40min | 主进程复验锚：worktree critical-rules.md:862/SKILL.md:9,76,220,341/模板:279；R6「执行慢」的机制性对照 |
| master 在本任务执行中前进 ebb5fba→7fa66ac（v151 后续提交改 66.2） | S1 diff 1 deletion 主进程核验=66.2 旧行被 master 新版取代，非 S1 所为；S7 合并按并集解 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| [PLAN TAMPERED] 连续拦截 v150 计划注入：全局活跃指针停留已完成 v150+其 plan 锁定后被两次正当收尾簿记提交修改（git 考古 02c61d7/1a87387），哈希 7d672276→55f844f5 | 非本会话计划，按 Rule 51.7 不重锁（无 Decisions Made 登记的重锁=篡改信号）；已上报用户。根因=本会话指针键位分裂 |
| 本会话指针命名空间分裂：SessionStart 漏写 sidmap（env sid de2c5bba ≠ hook sidkey cbab959f），init-session 指针落 env 键→hook 读全局 v150 假警报 | 补写 `.plan_required_side/de2c5bba*.sidmap`=cbab959f + side 指针同步落 hook 键；resolve-plan-dir.sh 双键验证均命中 task-v153（2026-10-09 21:45 证据） |
| init-session 哨兵 WARN「env sid 无对应哨兵,疑似他会话」 | 同上根因；哨兵 cbab959f 本会话私有，未抢用（正确防抢占行为） |
| plan-writer agent 确定性故障：`model: custom:9e221f47-3040-4ea7-b742-20b813fb79aa:sonnet-1` 两次派发均报 reasoning-level-missing（v152 当日 19:54 曾成功，判为 provider 侧变更/瞬时转持久故障） | 按 Rule 22.3.1 provider 失败改派 general-purpose 接管计划撰写（v127 判例）；**agent 定义属保护区不可自改——故障已上报用户，待授权后修复 plan-writer frontmatter（补 reasoning 档或换 provider）** |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- /opt/ZCode/resources/glm/packages/bundled-skills/skills/dynamic-workflows/SK.md（SKILL.md 同义）/patterns.md/examples.md — workflow 权威文档
- ~/.zcode/skills/task-planner/references/critical-rules.md:150-157（21.4）、:210-214（23.9-23.13）、:470（43.2）、:593（52）
- ~/.zcode/skills/task-planner/scripts/check-dispatch.sh:604-634（serial_slot_check）、check-plan-dispatch.sh:242-249（执行体列校验）
- plans/.rule-reservations.jsonl（68=task-v153 reserved 行）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
- （本任务暂无多模态产出；侦察均为文本源）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

#### [sub:S2] SKILL.md 级联单元结论（2026-10-09）
- 四处上界锚实测（worktree ebb5fba）：frontmatter 全集行 :9（异形 "Critical Rules 全集 1-66"）/ 详见行 :281→改后 :283 / References 表 :362→改后 :365；grep 字面 "Critical Rules 1-66" 命中 3 处（:9 为 "全集 1-66" 子串命中）
- 列表 bullet 区实测含 Rule 65/66 具名 bullet → 按施工图"若含 Rule 66 bullet 则同形态加 Rule 68 bullet"分支追加，非只动上界
- **词序偏差披露**：:9 原词序 "Critical Rules 全集 1-66"，改后 "Critical Rules 1-68 全集"（"全集"后置），原因=验收硬门 grep 'Critical Rules 1-68' ≥3 需 :9 字面命中；S7 复核可裁决是否还原词序（还原则 A 验收降 2 命中）
- 钉值三查（'N 脚本|脚本 N|=N,' 及补充模式）SKILL.md 零命中 → 无钉值 +1 动作；S5 侧 registry 行数钉值与 selftest 断言计数串不在本单元 scope
- 组域写隔离遵守：仅写 SKILL.md（scope）+ 本检查点 + findings 追加小节；critical-rules.md / templates/ 的 worktree 变更属并行成员，未触碰
