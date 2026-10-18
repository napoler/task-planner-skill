# 拆分模式库（split-pattern-library）

定位：Rule 21.6 数值上限管「拆得够小」，本库管「拆得对」。消费者=计划期主进程/plan-writer，拆分 S-unit 前必读。

## 消费契约

计划期拆分 S-unit 前必读本库。按任务画像选模式，选型结论入 knowledge-brief §5 与派发任务书。消费纪律见 Rule 21.6.1。

## 来源技能总表

| 技能名 | SKILL.md 绝对路径 |
|--------|------------------|
| writing-plans | ~/.zcode/skills/writing-plans/SKILL.md |
| subagent-driven-development | ~/.agents/skills/subagent-driven-development/SKILL.md |
| dispatching-parallel-agents | ~/.agents/skills/dispatching-parallel-agents/SKILL.md |
| brainstorming | ~/.zcode/skills/brainstorming/SKILL.md |
| sub-agent-protocol | ~/.zcode/skills/sub-agent-protocol/SKILL.md |
| task-drift-guard | ~/.zcode/skills/task-drift-guard/SKILL.md |
| skill-handoff | ~/.zcode/skills/skill-handoff/SKILL.md |
| skill-skill-tool | ~/.zcode/skills/skill-skill-tool/SKILL.md |

### P1 任务边界三判据（Right-Sizing）

- **判据**：每个 S-unit 须满足三判据——独立可验收（有可观察完成证据）、独立可理解（执行者无需读其他 S-unit）、接口清晰（输入/输出/依赖明确）
- **反例**：把「实现用户认证系统」作为一个 S-unit（太大无法独立验收）；或把「写测试」与「实现功能」拆为两个 S-unit（测试依赖实现，不独立）
- **消费时机**：计划期拆分 S-unit 时，对每个候选边界逐条检查三判据
- **来源**：writing-plans §Task Right-Sizing + brainstorming §Design for isolation
- **对低档模型执行明确性的贡献**：边界判据确保每个 S-unit 目标单一明确，低档模型无需猜测任务范围

### P2 Bite-Sized 步级粒度（2-5min）

- **判据**：S-unit 内部步骤每步 2-5 分钟可完成，每步是一个原子动作（写测试/运行/实现/验证/提交）
- **反例**：步骤写「完成用户模块」（太模糊非原子动作）；或步骤间有隐式依赖（未声明的顺序约束）
- **消费时机**：编写 S-unit 任务书时，将任务拆为 2-5 分钟的原子步骤
- **来源**：writing-plans §Bite-Sized Task Granularity
- **对低档模型执行明确性的贡献**：步级粒度确保每步动作明确，低档模型无需规划即可执行

### P3 子系统拆分法

- **判据**：任务涉及多个独立子系统时，按子系统边界拆分，每个子系统独立 spec→plan→impl 循环
- **反例**：按技术层拆分（前端/后端/数据库）而非按子系统拆分（导致跨层依赖，无法独立验收）
- **消费时机**：计划期识别任务是否包含多个独立子系统，决定是否按子系统拆分
- **来源**：brainstorming §Understanding the idea
- **对低档模型执行明确性的贡献**：子系统边界清晰，每个 S-unit 聚焦单一子系统，低档模型无需跨域推理

### P4 任务书 No-Placeholder 与双明确

- **判据**：任务书禁 TBD/待定/占位符；双明确=执行者无需追问即知「做什么（目标一句）+怎么做（方案/步骤）+做到什么程度（验收可观察）」
- **反例**：任务书写「实现错误处理」（占位符无具体方案）；或「参考 Task 3」（执行者需读其他任务才能理解）
- **消费时机**：编写 S-unit 任务书时，逐项检查无占位符+双明确
- **来源**：writing-plans §No Placeholders + /goal 锚定
- **对低档模型执行明确性的贡献**：双明确确保低档模型无需追问即可执行，消除歧义与臆测

### P5 独立性判定法（拆分期域划分）

- **判据**：多任务按根因/问题域分组，每个域内任务独立（无共享状态、无顺序依赖），域间可并行
- **反例**：将「修复 A 文件」与「修复 B 文件」拆为两个 S-unit 但 B 依赖 A 的输出（非独立域，不可并行）
- **消费时机**：计划期拆分后，对 S-unit 组进行独立性判定，确定并行/串行
- **来源**：dispatching-parallel-agents §Identify Independent Domains
- **对低档模型执行明确性的贡献**：独立性判定确保并行任务无冲突，低档模型执行时不会互相干扰

### P6 派发 Prompt 四要素

- **判据**：派发 Prompt 须含四要素——Focused（单一问题域）/ Self-contained（自包含全部上下文）/ Specific output（明确输出格式）/ Constraints（约束边界）
- **反例**：Prompt 写「修复所有测试」（太宽泛无焦点）；或「修复竞态条件」（无上下文，执行者不知在哪）
- **消费时机**：计划期编写 S-unit 任务书时，逐项检查四要素
- **来源**：dispatching-parallel-agents §Agent Prompt Structure
- **对低档模型执行明确性的贡献**：四要素确保低档模型无需追问即知任务范围、上下文、输出格式与约束

### P7 嵌套≤2 层与超时档位

- **判据**：子代理嵌套深度 ≤2 层（主进程→Agent(A)→Agent(B)）；每层超时独立计算——搜索/编辑 ≤600s、构建/测试 ≤1200s
- **反例**：3 层嵌套（主进程→A→B→C）导致失控；或未设超时导致子代理运行 7h+ 未终止
- **消费时机**：计划期确定派发结构时，检查嵌套深度与超时档位
- **来源**：sub-agent-protocol §子代理执行约束
- **对低档模型执行明确性的贡献**：嵌套与超时硬限确保低档模型在可控范围内执行，避免失控与资源耗尽

### P8 简单任务禁 spawn（L0 衔接）

- **判据**：单步搜索/查询 ≤60s 可完成的任务，主进程直做，禁 spawn 子代理
- **反例**：为「查一个文件是否存在」派发子代理（过度开销）；或简单 grep 任务走子代理链路
- **消费时机**：计划期判断任务复杂度时，识别 L0 简单任务并标记主进程直做
- **来源**：sub-agent-protocol §子代理超时熔断
- **对低档模型执行明确性的贡献**：简单任务直做避免不必要的上下文切换，低档模型无需理解子代理协议即可执行

### P9 Spec 自审四查（挂 21.5）

- **判据**：Spec 自审四查——占位符检查（无 TBD/待定）/ 一致性检查（无矛盾）/ 范围检查（无越界）/ 歧义检查（无二义）
- **反例**：Spec 写「实现错误处理」（占位符无具体方案）；或「参考 Task 3」（执行者需读其他任务才能理解）
- **消费时机**：计划期 Spec 完成后、拆分前，执行四查自审
- **来源**：brainstorming §Spec Self-Review
- **对低档模型执行明确性的贡献**：四查确保 Spec 无歧义，低档模型无需追问即可理解任务

### P10 拆细先于升档（本体已有，索引条目）

- **判据**：任务执行失败时，先尝试拆细（拆为更小 S-unit）而非升档（换更强模型）；模型分档路由（mini/haiku-1/sonnet-1/opus 按任务取最小可承载档）
- **反例**：任务失败后直接换更强模型（成本激增）；或未拆细导致模型能力不匹配
- **消费时机**：执行期任务失败时，先拆细重试，再考虑升档
- **来源**：subagent-driven-development §Model Selection + 本体 critical-rules.md Rule 22.3/21.3
- **对低档模型执行明确性的贡献**：拆细确保任务粒度与模型能力匹配，低档模型在明确小任务上可成功执行

### P11 术语语义锚定与理解复述

- **判据**：用户输入中的关键领域名词（定位/设定/角色/题材类）在拆分与任务书编写前必须完成「理解回写」——一句话语义解释 + 溯源锚（用户原文上下文或检索证据）；多义词/领域词禁凭模型先验赋义
- **反例**：用户要求「比格犬是实验犬」——实际语义=狗狗定位为出逃的、实验室替代小白鼠的实验犬；执行体误读为「实验犬=擅长做实验的犬」，理解偏差致定位错误
- **消费时机**：计划期需求转译时 + 任务书编写时（创作类任务=剧本/设定/角色定位的术语理解复述为派发前置）
- **来源**：task-v150 用户判例（2026-10-09）+ 本体 Rule 63.2 检索优先联动
- **对低档模型执行明确性的贡献**：术语语义被显式锚定后，低档模型不再自行赋义，定位类幻觉从源头消除

### P12 依赖分批并行（fan-out→join→串行链）（2026-10-09 Rule 68 配套新增）

- **判据（何时用）**：S-unit ≥3 且经 Rule 68.1 独立性四问静态版存在独立子集（≥2 单元两两四问全 no）的实现类计划——先按依赖拓扑分批，批内并行、批间串行
- **步骤（fan-out→join→串行链）**：①四问静态版逐对判定（写集/资源/输入/验收四问，68.1）→②「前置依赖」列显式化（无依赖显式 `-`，多依赖顿号分隔引用被依赖单元 ID）→③拓扑分批推导 `parallel_groups`（前组未齐验收不派后组，组间串行语义不回退）→④组内异构分摊（68.3：同组执行体 subagent_type 或 model 档位至少一项互不相同，专用体/通用体分工优先于档位差异）→⑤组批验收唯一 join（68.5：每并行组仅一个汇合点，禁多 barrier 使最慢成员卡全组）→⑥按组域写隔离回写状态（68.4：成员只写自己检查点+findings 追加小节+scope 文件，计划三文件由主进程按组串行统一翻状态）
- **反例**：多 barrier（每单元设一个 join 卡全组，退化为准串行）；组内执行体全同（单一 agent/模型档位整组承运，负载不分散、资源消耗不可控）；并行成员直写计划三文件（状态错乱源，违反 68.4 单写者原则）；未收窄候选全集就 fan-out（应先 Explore/grep 收窄到可指名文件集再并行，68.5 先收窄再 fan-out）
- **消费时机**：计划期 S-unit 表定稿后、attest 前，对 S-unit 表过依赖分析并按本模式推导并行分组与组内异构分配
- **来源**：Rule 68.1-68.7（critical-rules）+ 68.5 parallel playbook 三要点（dynamic-workflows patterns.md:45-54、SK.md:321-345 同源）+ 21.4 组间串行默认语义
- **关联映射**：Rule 68（critical-rules 条款本体）/ templates/task_plan.md「前置依赖」列（68.1 消费面）/ check-plan-dispatch.sh 68.6 两档校验（hard 拒锁 + advisory WARN）
- **对低档模型执行明确性的贡献**：分批并行把并行度与隔离责任前移到计划期显式声明，执行体（含低档模型）只需按组执行窄 scope 任务，无需自行判断跨单元依赖

## 伴飞映射表

| 任务画像 | 伴飞技能 | SKILL.md 绝对路径 | 消费说明 |
|---------|---------|------------------|---------|
| 实现类计划 | writing-plans | ~/.zcode/skills/writing-plans/SKILL.md | 计划撰写参考，任务书结构消费 |
| 并行编排计划 | dispatching-parallel-agents | ~/.agents/skills/dispatching-parallel-agents/SKILL.md | 并行任务派发，独立性判定消费 |
| 新系统设计拆分 | brainstorming | ~/.zcode/skills/brainstorming/SKILL.md | 系统设计拆分，子系统边界消费 |
| 子代理管线设计 | subagent-driven-development | ~/.agents/skills/subagent-driven-development/SKILL.md | 子代理管线设计，模型选择消费 |
| 嵌套/长时派发 | sub-agent-protocol | ~/.zcode/skills/sub-agent-protocol/SKILL.md | 嵌套与超时控制，派发约束消费 |
| 技能本体修改 | writing-skills | ~/.agents/skills/writing-skills/SKILL.md | 技能文件撰写/改进，文档规范消费 |
| 对齐审查收尾 | alignment-review | ~/.zcode/skills/alignment-review/SKILL.md | 对齐审查收尾，跨载体一致性消费 |

## 未吸收登记（管辖边界说明）

- task-drift-guard 量化漂移阈值（5%/20%）→ 执行期漂移检测归 Rule 61/64 管辖，不入模式库
- skill-handoff Skill() 降级协议 → 派发容错面，以 59.2 伴飞候选承载，不入模式
- executing-plans/workflow-gate/todo-skill → 本体已有更完整机制，不入库
