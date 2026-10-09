# Design — Rule 68 计划期依赖分析、并行分组、组内异构分摊与组域写一致性纪律

> task-v153 Phase 1 交付物（主进程，计划系统文件白名单②）。
> 锚点基线 = master ebb5fba（v151 Rule 66 已合并）+ 部署位 ~/.zcode/skills/task-planner（与仓 IDENTICAL 实测 2026-10-09 22:1x）。
> 施工面在 worktree（Phase 2 创建），本稿行号为基线参考，执行体重读时以 worktree 实测为准（v152 施工锚「实施日重验」惯例）。

## 一、条款全文草案（S1 消费：追加到 references/critical-rules.md 文末，66.6 之后）

```markdown
### 68 计划期依赖分析、并行分组、组内异构分摊与组域写一致性纪律（2026-10-09 task-v153，目标：计划初期显式分析依赖→推导并行分组→组内异构 agent/模型分摊→组内更新防错乱，可并行者并行加速、有依赖者串行逐个击破）

68.1 **计划期强制依赖分析（plan-time dependency analysis）**：S-unit 表定稿后、attest 前，对全部 S-unit 过独立性四问静态版（21.4 四问的计划期口径）——①写集相交（scope_files 交集非空）②资源相争（同部署位/分支/交付物/计划文件锚点/额度窗口）③输入依赖他者产出（本单元输入=他单元输出路径或其产物内容）④验收依赖他者结果（本单元验收证据取自他单元产物）。分析结论显式落 S-unit 表「前置依赖」列（无依赖显式填 `-`，多依赖顿号分隔、引用被依赖单元 ID）；未做分析或该列空白=计划无效回炉（59.1 硬门同档）；分析过程在计划内留痕（依赖分析注记/design 稿引用），禁口头心算（54.5 决策依据落盘）。

68.2 **并行分组推导（group derivation）**：`parallel_groups` 声明必须由 68.1 依赖分析推导——同组成员两两四问全 no 才可入组；「前置依赖」非空者禁止与其被依赖者同组（68.6 hard 档机器可校验）；组间按依赖拓扑排序，前组未齐验收不得派后组（21.4 组间串行语义不变，不回退）；未声明组=串行（21.4 默认不回退）。分组目标=在依赖约束下最大化并行度：优先把经四问判定独立的单元划入同一批准组，杜绝「全计划默认串行」的惰性分组。

68.3 **组内异构分摊（heterogeneous allocation）**：同一并行组内成员的执行体 subagent_type 或 model 档位至少一项互不相同；整组「继承」同一 Phase Executor 禁止——并行组内成员的执行体列必须逐行具体化。43.2 最小可承载档位优先级高于异构：禁止为追求异构而升档/降档；同档可承载时优先按 agent 类型差异实现异构（专用体/通用体分工），模型档位差异其次。依据（如实披露）：把所有并行子任务交给单一模型=资源消耗不可控（dynamic-workflows schema 级实证：其 subagent_model 为 run 级单一字段、agent() 无 per-task 模型/类型覆盖——SKILL.md:115,960-963,1023），异构分摊将并行负载分散到不同 agent/模型档位。

68.4 **组域写隔离与状态一致性（group write isolation）**：组内成员只写三类目标——自己检查点（22.8 subagent-state）、findings.md 追加小节（22.4a 契约）、自己 scope_files；计划三文件（task_plan/findings/progress/verification）的状态列、Subagent Handoff 表、Lane 表一律由主进程**按组串行回写**（单写者原则 49.4② 推广到通用 S-unit）。推进序=成员完成→组批验收（22.5 三证据）→主进程统一翻状态（含 [goal:Gn] 证据行，66.3 联动）；禁止组内并行成员直接 Edit 计划三文件（check-delegation 既有拦截为主、68.6 advisory 检测为辅）；跨组状态变更经主进程协调，任何成员不得代表他组翻格。目标=整段并行运行时状态更新不错乱。

68.5 **借鉴 workflow 编排三要点（parallel playbook）**：先收窄再 fan-out（派发前用 Explore/grep 把候选集收窄到可指名文件集，禁对未收窄全集并行派发——dynamic-workflows patterns.md:45-54 同源）；唯一 join 原则（每并行组仅一个汇合点=组批验收或 Aggregator Phase，禁多 barrier 使最慢成员卡住全组后续——SK.md:321-345 同源）；结果即落盘（成员每完成一里程碑立即写检查点，中途被杀不丢产出——22.8 检查点纪律在并行语境的重申）。

68.6 **守卫（guard）**：check-plan-dispatch.sh 计划期扩展两档——hard 档（拒锁）：组标记存在性（frontmatter `parallel_groups` 每个组名在 S-unit 表内有对应 `[parallel-group:<组名>]` 标记行）、依赖-同组矛盾（「前置依赖」列非空的行与其被依赖行同组）、「前置依赖」列存在且逐行非空（无依赖显式 `-`）；advisory 档（WARN 不拒锁）：组内执行体全同（同组内 `subagent_type(model)` 列全部相同→提示异构化）、组内成员执行体全部「继承」。机器边界如实披露：守卫只消费表内显式字段，不做文件集交集自动推断（68.1 分析责任在计划者）；串行槽仍为全局单锁、组间串行为 21.4 既有语义（`{组名: ts}` 富锁升级=已登记后续任务项，非本条范围）。

68.7 **机制（mechanism）**：零新 config 键（沿用 25.4/43.4/66.6 零新键纪律）；机器面=check-plan-dispatch.sh 计划期两档校验 + scripts/selftest-parallel-scheduling.sh 静态守护（68.1-68.7 子条锚 / 模板「前置依赖」列锚 / SKILL 摘要行 / C46 合规行 / registry 登记行 / 零新键负断言 / 21.4 语义未回退负断言）+ selftest-registry.tsv 登记；合规清单 C46（SKILL.md 消费侧）；模板承载=templates/task_plan.md S-unit 表「前置依赖」列（68.1 消费面）；模式库承载=split-pattern-library.md P12 依赖分批并行。
```

## 二、check-plan-dispatch.sh 校验点清单（S4 消费）

插入位：66.5 校验段之后（基线 ~line 410，S4 施工日重验），新段头注释
`# ── [2026-10-09 task-v153 S4] Rule 68 依赖与并行分组校验段 ──`。

| 编号 | 档位 | 校验点 | 判定实现要点 |
|------|------|--------|-------------|
| H1 | hard（add_violation 拒锁） | 「前置依赖」列存在：任一 S-unit 表头含 `前置依赖` 字样；S-unit 表存在但缺该列 → violation | awk 状态机抽各 S-unit 表头行（参照 66.5 Goal 表 awk 状态机写法，禁区间坍缩范式） |
| H2 | hard | 逐行非空：S-unit 数据行「前置依赖」单元格为空（未填 `-`）→ violation | 表头列位定位后按 `|` 切分取对应列；单元格含裸管道=格式漂移按 violation 提示（本仓判例：管道未转义挤列） |
| H3 | hard | 组标记存在性：frontmatter `parallel_groups: [g1, g2]` 声明的每个组名，S-unit 表内至少一行含 `[parallel-group:<组名>]`；声明无成员 → violation | 复用 frontmatter pg 解析 + 全表 grep 标记集 |
| H4 | hard | 依赖-同组矛盾：行 R「前置依赖」含单元 D 的 ID，且 R 与 D 标记同组 → violation | ID→组映射表（awk 单遍）；依赖列顿号分隔解析 |
| W1 | advisory（WARN 不拒锁） | 组内执行体全同：同组内执行体列值全部相同 → WARN 提示异构化（68.3） | 组→执行体集合映射，集合大小=1 且组员 ≥2 → WARN |
| W2 | advisory | 组内成员执行体全部为「继承」→ WARN | 同上口径加「继承」判定 |

档位接线：全部走既有 `add_violation` 管线（enforce=exit 2 / warn=stderr+计数，零新 config 键）；无 S-unit 表的计划（mini/legacy）整体跳过（与 66.5 档位三分支口径一致：standard/full 硬门、无标记跳过）。

## 三、templates/task_plan.md 加列 diff 预览（S3 消费）

基线 line 278（S-unit 表头）：

```diff
-| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
+| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
```

表头注释行同步追加一句：`Rule 68.1 前置依赖列必填,无依赖填 -（多依赖顿号分隔）`；示例行（若模板含）同步加 `-` 单元格。既有列零改动（仅插列）。

## 四、SKILL.md 级联清单（S2 消费；「合并时从 master 实际值递推」，禁止硬编码本稿行号）

| 锚 | 基线形态（ebb5fba） | 改动 |
|----|--------------------|------|
| 文件头 references 行 | 「Critical Rules 全集 1-66（…65 周期性回顾…）」 | 上界递推 1-6X→合并后实际最大编号（含 68）；枚举表尾追加「66 goal 单元固化与 /goal 驱动推进（v151）/67 …（v152 若已合并）/68 计划期依赖分析、并行分组、组内异构分摊与组域写一致性纪律」 |
| Critical Rules 列表区 | Rule 66 摘要 bullet 之后 | 追加 Rule 68 bullet（形态对齐既有 bullet：一句定位+关键子条+机制面） |
| 「详见 references」行 | 「Critical Rules 1-66（含 Rule 40-65 全集…）」 | 上界递推 + 枚举追加 68 |
| References 表 | 「critical-rules.md: Critical Rules 1-66（含…65 周期性…）」 | 同上 |
| 合规清单 | C45（goal 单元自查，v151）之后 | 追加 C46 行：计划期依赖与并行分组自查（Rule 68）——68.1 前置依赖列填写 / 68.2 组由依赖推导 / 68.3 组内异构 / 68.4 组域写隔离；机器面=check-plan-dispatch 两档+selftest-parallel-scheduling.sh；mini 豁免 |
| 计划撰写流程段 | 初始化/规划步骤区 | 加一行强制步骤：「S-unit 表定稿后按 Rule 68.1-68.2 做依赖分析→填前置依赖列→推导并行分组→组内异构分配（68.3）」 |
| selftest 计数钉值 | 若 SKILL 存在「NN 脚本」类总数钉值 | +1（S2 施工日 grep 实测对照） |

## 五、selftest-parallel-scheduling.sh 断言清单（S5 消费）

| 断言 | 内容 | 口径 |
|------|------|------|
| T1 | critical-rules.md `grep -cE '^68\.[1-7] '` =7 | 七子条齐全 |
| T2 | 条款四关键词串在位：依赖分析 / 并行分组 / 异构分摊 / 组域写隔离 | 各 ≥1 |
| T3 | 模板 S-unit 表头含「前置依赖」 | grep ≥1 |
| T4 | check-plan-dispatch.sh 含 hard 串（依赖-同组）与 advisory 串（组内全同） | 各 ≥1 |
| T5 | SKILL.md 含 C46 行与 Rule 68 摘要行；「Critical Rules 1-」上界 = critical-rules.md 实测最大编号（动态对照，禁硬编码） | 动态求值 |
| T6 | selftest-registry.tsv 含 selftest-parallel-scheduling 行 | grep ≥1 |
| T7 | config.json 无新增 parallel/model_allocation 类键（零新键负断言） | grep 0 |
| T8 | 21.4 既有语义未回退负断言：21.4 段「未声明者默认串行」原文锚仍在 | grep ≥1 |
| T9 | 模式库 P12 锚「依赖分批并行」在位 | grep ≥1 |

脚本形态对齐既有 selftest（自含 assert/计数/exit 语义，TAP 风格照抄邻族 selftest-goal-unit-goal-mode.sh）。

## 六、split-pattern-library P12 草案（S6 消费）

```markdown
### P12 依赖分批并行（fan-out→join→串行链）
- **何时用**：S-unit ≥3 且经 68.1 四问存在独立子集（≥2 单元两两独立）的实现类计划。
- **步骤**：四问静态版→「前置依赖」列显式化→拓扑分批推导 parallel_groups→组内异构分配（68.3）→组批验收唯一 join（68.5）→按组域写隔离回写状态（68.4）。
- **反模式**：多 barrier（每单元一个 join 卡全组）；组内执行体全同（单模型整组承运）；并行成员直写计划三文件（状态错乱源）；未收窄全集就 fan-out。
- **伴飞映射**：Rule 68（critical-rules）/ templates/task_plan.md 前置依赖列 / check-plan-dispatch 两档校验。
```

## 七、dispatch-examples 追加节草案（S6 消费）

「同批不同 agent/模型派发示例（Rule 68.2/68.3）」：以 p3-core 三单元为例，给出三条派发 prompt 骨架（executor(sonnet-1) + code-assistant(haiku-1) ×2），每条含 `[parallel-group:p3-core]` 标记、组域写隔离声明（只写 checkpoint+scope 文件）、验收三证据要点；并注明组间串行（前组未验收不派后组）与「组内全同 WARN」后果。

## 八、施工顺序与钉值风险对照

- S1→S2/S3 可并行消费本稿（p3-core）；S4/S5 消费本稿校验点/断言清单（p3-guard，前置=S1 条款在位）；S6（p3-docs）；S7 串行尾（计数级联复核+CHANGELOG+合并预检）。
- 钉值级联三查（S2/S5 施工日执行）：① SKILL「NN 脚本」总数钉值 +1 ② registry 行数钉值（若有）+1 ③ selftest 注释内的断言计数串随实测更新。
- CHANGELOG.md：仓约定历任务有 [Unreleased] 条目 → S7 收尾簿记补一条（范围经 B 类变更入计划 scope，见 Decisions Made）。
