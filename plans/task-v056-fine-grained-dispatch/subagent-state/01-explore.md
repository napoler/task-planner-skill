# 01-explore 检查点 — 拆分粒度机制现状调研（2026-09-09）

> 执行体：Explore（agent_22467eeb）。子代理无 Write 工具，由主进程代写本检查点。内容 = 子代理返回全文，主进程已 Read 复核 critical-rules.md:110-134 与 templates/task_plan.md:125-202。

## 核心结论
现行拆分粒度约束**全部挂在 Phase 层**（数值偏宽松），「小步快跑」理念已由 Rule 21 宣告但**缺步级结构**。

## 逐项事实（均带 文件:行号）

### Q1 Rule 21（critical-rules.md:110-117）
层级=计划阶段拆、执行阶段派；21.1 单 Phase「默认 ≤3 文件且 ≤300 行，或单一可验证产出」；数值上限挂在 **Phase 层**，无单次派发独立的更细上限。

### Q2 Rule 22（critical-rules.md:118-134）
- 22.1：单 Phase 派发 ≤5 次（config `max_per_phase`）；单派发 ≤3 文件/≤300 行
- 22.2：超时档 explore 30 / editor 60 / debugger 60 / executor 120 min
- 22.3：兜底四档 = 改派→降档→主进程接管(≤300行)→AskUser；retry_limit=2。**没有"拆细"档**
- 22.3.1：Provider Scaling（probe/bind `-fb` 变体）
- 22.4：八字段 = 目标1句 / 输入含 findings ≤10 行 / 验收 2-5 条 / Scope 禁改 / 工作路径 / 时长预算 / 返回 ≤3 行 / 检查点路径。**无 prompt 总长度量化上限**
- 22.5：Handoff 登记表 11 列
- 22.6：**Phase 含 ≥3 子任务→写 Subtasks 子表（ID/目标/输入/验收/状态）**——已存在但触发条件是"≥3 子任务"且模板里只是注释
- 22.7：连续失败 ≥2 → STOP
- 22.8：检查点 T1-T5 + resume_from

### Q3 Rule 25（critical-rules.md:159-167）
Executor 字段强制；六项白名单；委派率 <0.7 → PARTIAL。

### Q4 templates/task_plan.md（:125-202, :332）
Phase = checkbox(2-4) + Status + Executor；**Subtasks 子表只存在于 Phase 2 的 HTML 注释示例（:152-160），正文无步级结构，无预估时长字段**。

### Q5 templates/subagent_dispatch.md
八字段完整模板，含知识储备注入包；上下文最小化有雏形（findings ≤10 行、目标 1 句、返回 3 行），**无 prompt 总长度预算**。

### Q6 templates/variant/
12 个变体（bugfix/code-edit/deployment/diagnostic/migration/performance-tuning/publish/refactor/research/schema-migration/test-writing/writing），多数 5 Phase（publish/writing 4 个）；**全部无 Subtasks 正文**（grep "Subtasks" 0 命中）。

### Q7 config.json
subagent.{max_per_phase:5, retry_limit:2, max_files_per_dispatch:3, max_lines_per_dispatch:300, timeout_by_type:{explore:30,editor:60,debugger:60,executor:120}}；delegation_rate_floor:0.7；escalation_threshold:3；provider_fallback（variant_types 4 类、fallback_slugs "agnes-2.5-flash"）。**无步级拆分/预估时长/prompt 预算键**（additionalProperties:false——加键需同步 schema 校验）。

### Q8 plan-writer agent
位置 `skills/task-planner/companion/agents/plan-writer.md`，model=sonnet-1；粒度指导仅「3-7 个 Phase」「Phase >7 过细=执行阻力大」「单 Phase >3 文件或 >300 行禁止」；**无 Phase 内拆步指令**。

### Q9 量化盘点
3-7 Phase、≤3 文件、≤300 行、派发 ≤5/Phase、≥3 子任务触发 Subtasks、超时 30/60/120min——**无预估时长门槛、无 Phase↔派发 1:1 规定**；goal-gate.md/reference.md 零粒度条款。

### Q10 agents 清单
仅 companion/agents/ 3 个：plan-writer(sonnet-1)、article-field-fixer(haiku-1)、article-batch-publisher(sonnet-1)；仓库根无 agents/。

## 优化落点提示（子代理建议，供方案设计参考）
① Subtasks 子表从注释转正为 Phase 内必填 ② config 增步级时长/prompt 预算键 ③ 收紧 21.1/22.1 数值
