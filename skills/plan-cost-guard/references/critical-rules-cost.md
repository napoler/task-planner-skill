# Critical Rules — plan-cost-guard（成本控制）

> 域=成本控制。
> 本文件为 plan-cost-guard 卫星技能规则全文，从核心 task-planner `skills/task-planner/references/critical-rules.md` 逐字迁移（标题统一为 `### N 标题`，正文一字未改）；源行区间以 `plans/task-v171-skill-specialization/design-architecture.md` §1 七卫星收编表（plan-cost-guard：Rule 17@80-91）为准。
> 本批次（task-v171 S27）落盘 1 条：Rule 17。
> 源文件核心 critical-rules.md 原文本批次不删（删除见后续 Phase 删除基线执行）。

### 17 成本控制（P0）— 降低 Opus 使用频率
opus 主会话中嵌套 opus Skill(`systematic-debugging`/`code-review`/`brainstorming`/`writing-plans`/`comet-*`)是隐藏成本源,主进程 + Skill 嵌套 = 每次额外 1 次 opus 计费。详见 `cost-control.md`。

17.1 **opus Skill 节流**:opus 档 Skill 同 phase 内 ≤1 次;超出 → AskUserQuestion「继续/拆型/降级」
17.2 **subagent 嵌套禁止**:禁止 plan-writer 调 plan-writer / code-assistant 调 code-assistant(frontmatter `tools` 不含 Agent/Skill 已防止)
17.3 **任务模板复用**:禁止 plan-writer 重复生成同 task_plan;复用 `Decisions Made` 旧决策
17.4 **drift 检测频次上限**:每 phase 内 `drift-checker` 派发 ≤3 次(2-3 todo + 切模块 + phase complete)
17.5 **opus 调用门控**:单次会话 opus 累计(主进程 + Skill 嵌套 + subagent 升级)≥10 次 → AskUserQuestion
17.6 **复杂任务优先 subagent**:opus 上下文长读文件(>500 行)必派 subagent(沿用 Rule 13)
17.7 **代码 review 必含 `required`**:`task_plan.md#code_review` = `required` 才触发 `Skill("code-review")`
17.8 **每次 opus 调用记 `cost_log.md`**:子代理/Skill 调用记录到 `cost_log.md` 便于复盘;`plan-writer` 产出契约加 `cost_estimate` 字段
