# Plan Brief — task-v153-parallel-scheduling

> 供 plan-writer 消费的自包含任务书。产出 = 就地改写 `/mnt/data/dev/task-planner-skill/plans/task-v153-parallel-scheduling/task_plan.md`（模板骨架 503 行已 init，保留其区块结构，填充/替换占位内容）。
> 写法禁令（守卫口径）：本文件内**禁止出现**行首 markdown 编号项（`1.` `2)` 开头的列表行）、圆圈序号 ①-⑮、`step N`/`步骤N`/`第N步` 字样——check-dispatch 步骤枚举门按此计数（上限 4），全部用 `- ` 列表行。

## 一、四文件读写契约（Rule 22.4a，不可收窄）

- 计划：`/mnt/data/dev/task-planner-skill/plans/task-v153-parallel-scheduling/task_plan.md`（你唯一要写的交付物）
- 侦察知识库（**第二动作 Read 全文**）：`/mnt/data/dev/task-planner-skill/plans/task-v153-parallel-scheduling/findings.md`
- 动作日志：`/mnt/data/dev/task-planner-skill/plans/task-v153-parallel-scheduling/progress.md`（只读；如需登记计划产出动作可 append 到 Phase 1 段）
- 知识简报：`/mnt/data/dev/task-planner-skill/plans/task-v153-parallel-scheduling/knowledge-brief.md`（可消费，S-unit 材料包索引可回填）

## 二、用户需求原文（Rule 51.1，须原样进 task_plan「🎯 用户需求原文」区块）

- R1: 「优化当前项目技能的执行并行的效率……在计划初期就分析出哪些任务可以并行」
- R2: 「相互不影响的时候就可以并行执行；存在相互依赖关系就需要逐个串行……一个个击破」
- R3: 「最终我希望以后运行任务的时候,都可以针对可以并行的任务进行并行加速」
- R4: 「workflow 会将所有的任务都丢给一个模型执行……模型消耗资源会不可控」
- R5: 「学习它的并行策略,但是需要保证使用不同的 Agent,以及模型进行运作」
- R6: 「因为当前我发现执行工作非常缓慢,我希望可以优化并行运行」
- R7: 「在规划初期就可以将整个大段任务拆成几个可以并行的小任务……简单来说就是分组，任务分组，分组之后，每个任务更新的时候都可以在组内进行修正，以及比如更新状态之类的，确保可以后期整个运行并行的时候不会出现错乱问题」

全部 R 标注 [目标]，R→VC 映射表每行给可观察证据形态（Rule 51.2/58.4）。

## 三、任务本质（一句话）

给 task-planner 技能新增 **Rule 68：计划期依赖分析、并行分组、组内异构分摊与状态一致性纪律**——把「计划期强制依赖分析→推导并行分组→组内异构 agent/模型分摊→组内状态更新防错乱」固化为规则+模板列+守卫+selftest，纠正现状「声明制靠自觉、组内全同模型、并行更新无组域协议」三缺口；借鉴 dynamic-workflows 的分组思想（先收窄 fan-out、唯一 join、依赖链=串行），不搬其运行时（其 schema 无 per-task 模型，findings §A A4 已证实）。

## 四、设计方向（Phase 1 产出设计稿的骨架，可细化不可推翻）

Rule 68 条款草案结构（编号已预留：`rule-reserve.sh check 68` = held by task-v153）：

- 68.1 计划期强制依赖分析：S-unit 表定稿后、attest 前，对全部 S-unit 过独立性四问静态版（写集相交 / 资源相争 / 输入依赖他者产出 / 验收依赖他者结果），产出 S-unit 表「前置依赖」列显式填写（无依赖填 `-`）。
- 68.2 并行分组推导：`parallel_groups` 声明必须由依赖分析推导——同组成员两两四问全 no；「前置依赖」非空者禁止与其被依赖者同组（机械可校验）；未分析/未声明=串行（沿用 21.4 默认语义，不回退）。
- 68.3 组内异构分摊：同一并行组内成员的 subagent_type 或 model 档位至少一项互不相同；整组「继承同一 Phase Executor」禁止；43.2 最小可承载档位优先级高于异构（不可为异构而升档）。
- 68.4 组内更新与状态一致性（防错乱，R7 专属条款）：组域写隔离——组内成员只写自己 checkpoint 与 findings append（22.4a 既有契约）+ 自己 scope_files；计划三文件状态列/Handoff 表由主进程**按组串行回写**（单写者原则 49.4② 推广到通用 S-unit）；组内成员完成→组批验收→统一翻状态，禁止组内并行成员直接 Edit task_plan.md；跨组状态变更经主进程协调。目标=后期整段并行运行不错乱。
- 68.5 借鉴 workflow 三要点入条款：先收窄再 fan-out、唯一 join（组间汇合点=验收/Aggregator，多 barrier 禁止）、结果即落盘检查点。
- 68.6 守卫：check-plan-dispatch.sh attest 期扩展——hard 档校验组标记与声明组一致性、依赖-同组矛盾；advisory 档校验组内执行体全同 WARN。零新 config 键。
- 68.7 机制=selftest-parallel-scheduling.sh 静态断言 + 合规清单 C 行（编号以合并时 master 实际递推为准，见 §六）。

模板/文档落点：

- `templates/task_plan.md`：S-unit 表加「前置依赖」列（侦察确认加列安全：check-plan-dispatch 只硬校验执行体列）。
- `references/split-pattern-library.md`：新增模式「依赖分批并行（fan-out→join→串行链）」+伴飞映射。
- `SKILL.md`：计划撰写流程加「依赖分析→并行分组→异构分摊」强制步骤行 + 计数级联。
- `references/dispatch-examples.md`：同批不同 agent/模型派发示例（grep 确认落点）。

边界（YAGNI，明确排除）：

- 不做自动依赖推断器/新脚本 analyze-deps.sh。
- 不改 check-dispatch serial_slot_check 全局锁（升级 {lane:ts} 富锁=已登记后续任务项，非本任务）。
- 不动 Rule 21.4 既有语义；不碰 auth/路由/hook 配置。

## 五、计划结构要求

frontmatter 键：`template_type: rule-enhancement` / `new_rule: 68` / `isolation: worktree` / `code_review: required` / `interaction_mode: ask`（文件头无 frontmatter 则新增）。

必含区块：🎯 用户需求原文（§二 七条）+ R→VC 映射 + 🧮 根源覆盖表（53.1，五缺口=计划期无依赖分析 / S-unit 无依赖字段 / 组内无异构机制 / 并行更新无组域协议 / 守卫不校验组结构，每条根治判据三选一）+ 🔍 证据面清单（58.1：自身=本仓规则与守卫现状；对标=dynamic-workflows 官方文档；外部约束=多会话并行合并）+ ✅ VC 表 + 执行范围限制（scope_files）+ FMEA + 隔离决策（worktree）+ 🧰 工具选择 + 委派统计 + Handoff 表头。

五 Phase 结构：

- Phase 1 设计定稿——条款 68.1-68.7 全文草案 + check-plan-dispatch 校验点清单 + 模板 diff 预览，落 `plans/task-v153-parallel-scheduling/design-rule68.md`；Executor=plan-writer（sonnet-1）。
- Phase 2 worktree+基线——worktree 创建（路径 `/mnt/data/dev/task-planner-skill-worktrees/v153-parallel-scheduling`，分支 `wt/v153-parallel-scheduling`，**从当前 master HEAD 创建并先校验关键文件与主仓一致**，memory「worktree 分支不同步」教训）+ selftest 基线跑批存证；Executor=主进程/git-master。
- Phase 3 实施——S-unit 拆分（**吃狗粮：本计划自己就是新机制的第一个消费者**，声明 parallel_groups 且组内执行体异构）：
  - critical-rules.md Rule 68 条款全文（executor sonnet-1）
  - SKILL.md 流程步骤+计数级联+合规清单行（code-assistant haiku-1）
  - templates/task_plan.md 加列（code-assistant haiku-1）
  - check-plan-dispatch.sh 守卫扩展（executor sonnet-1）
  - selftest-parallel-scheduling.sh 新建+registry.tsv 登记（executor sonnet-1）
  - split-pattern-library.md 新模式 + dispatch-examples.md 示例（code-assistant haiku-1）
  - 合并时计数级联与并集解（依赖前六项，串行尾）
  - 分组草案：p3-core={条款, SKILL, 模板}（文件集不相交、共同输入=design 稿）、p3-guard={守卫, selftest}（文件集不相交、共同输入=design 稿）、p3-docs={模式库, 示例}；合并尾串行。每组内执行体异构（haiku-1/sonnet-1 混）。
- Phase 4 验证——selftest 全量回归（FAIL=0）+ 新 selftest 断言 + CR（Code Reviewer）+ alignment-review（42.6.2）；Executor=code-runner/critic。
- Phase 5 合并部署簿记——smart-merge-back + 部署位对账（三部署位 IDENTICAL）+ land 68 + delivery-summary；Executor=主进程/git-master。

列与字段要求：V-N 验证条目机器可复现（命令+期望输出）；每 Phase `**Executor:**` 必填；S-unit 表列全（S-id/任务/文件/执行体注册类型名/档位/粒度三值 Nf/Nl/Nmin/前置依赖/并行组/检查点）；S-unit 行内编号（如 critical-rules 条款单元）避免用 S 加数字字面散落正文，仅在表内与本 Phase 语境出现。

## 六、关键风险与约束（写进计划风险/FMEA）

- 多会话合并级联（最高风险）：v151（Rule 66，21:39 attest 但账本漏记）与 v152（Rule 67 reserved）都在改 critical-rules.md/SKILL.md 计数。本任务叠 68：**所有计数锚写「合并时从 master 实际值递推」，禁止硬编码当前态**；合并冲突按并集解（v149/v150 判例）。
- 新 selftest 必登记 registry.tsv 且 SKILL 钉值上调（v150 教训）；委派 subagent_type 用注册类型名（带后缀=守卫误报，v150 教训）；派发 prompt 禁用非本单元 S 加数字字面、圈号≤4（v129/v123 守卫纪律）。
- 保护区 P0：技能文件改动必须走 worktree；主仓 plans/ 直写仅限计划文件。
- 并行会话在途：禁触碰 plans/task-v151-*、plans/task-v152-*、其 worktree；check-conflicts 信号已知悉。

## 七、验收（写入 VC 表的底线判据，八条）

- VC-a: critical-rules.md 含 Rule 68 完整条款（68.1-68.7），grep 锚可验证。
- VC-b: templates/task_plan.md S-unit 表含「前置依赖」列。
- VC-c: check-plan-dispatch.sh 扩展校验存在且对「依赖-同组矛盾」reject、「组内全同」WARN 有测试证据。
- VC-d: selftest-parallel-scheduling.sh 存在、registry 登记、断言通过。
- VC-e: 全量 selftest FAIL=0（相对基线零新增失败）。
- VC-f: SKILL.md 计数级联正确（Critical Rules 上界=合并后实际最大编号），含 Rule 68 索引行与合规清单行。
- VC-g: 本计划自身含 parallel_groups 声明 + 组内异构执行体分配 + 组域写隔离协议行（吃狗粮证据）。
- VC-h: 三部署位 IDENTICAL（合并后对账）。

计划产出自身的验收 = frontmatter 键齐、五 Phase 每个有 Executor 字段、S-unit 表列全、R→VC 映射完整、V-N 机器可复现、组内状态一致性条款（68.4）在正文。
