# Critical Rules — plan-resume（计划续推）

> 域=计划续推（中断扫描触发时机与自主续推行为契约）。
> 本文件为 plan-resume 卫星技能规则全文，从核心 task-planner `skills/task-planner/references/critical-rules.md` 逐字迁移（标题统一为 `### N 标题`，正文一字未改）；源行区间以 `plans/task-v171-skill-specialization/design-architecture.md` §3 plan-resume 表为准（Rule 24@222-233；设计区间含尾部空行，实际规则正文为 222-232 共 11 行）。
> 本批次（task-v171 S28 / Phase 6）落盘 1 条：Rule 24。
> 源文件核心 critical-rules.md 对应文本本批不删（核心原文删除见后续 Phase 7 核心瘦身阶段 S31 统一执行）。
### 24 plan-resume 被动扫描与自主续推(P1,v0.5 契约)
每个 Phase complete 后,在派发 drift-checker **之前**,主进程**被动**调一次 `Skill("plan-resume")` 扫描工作区其他未完成计划。v0.5 起行为分模式:**当前计划执行中 → 只报告**(防打断进行中工作);**恢复触发点(会话启动无活跃计划 / 用户恢复类指令 / 当前计划交付终态后)→ 自主选 1 个续推**(config `autonomous_resume: true`,详见 plan-resume SKILL.md §7)。本规则保证:恢复场景不再"报告完等用户点名",同时执行中的扫描不抢当前工作。
（2026-09-27 task-v091/A-3 触发点收敛:plan-resume 调用点由「每 Phase complete」收敛为「交付终态/会话恢复触发点」两类(即下述 24.5 恢复触发点),Phase 循环内不再逐 Phase 扫描;v0.5 行为契约(执行中只报告/恢复点自主续推 Top 1)与守卫条款 24.2-24.7 零改动)

24.1 **触发时机**:Phase 状态变更为 `complete` 之后(同 Rule 11 派发 drift-checker 的时机);**不是**每个 todo 完成时(避免噪音)。执行中扫描恒为只报告模式（A-3 收敛后:仅「交付终态/会话恢复」触发点实际调用,见 24 注）
24.2 **扫描源**:用户当前工作目录 `$(pwd)`,scope = 仓库根(扫描 `plans/*/task_plan.md` + `.zcode/plans/plan-sess_*.md` + `openspec/changes/*/tasks.md` + `specs/*/tasks.md` 共 3 种格式);自主续推仅考虑仓内计划,跨仓候选只报告(宪法 §五 跨项目隔离 P0)
24.3 **跳过自身**:当前 plan 的 `task_plan.md` 不进报告(避免重复/自触发);当前 plan 自身状态由三文件罗盘(task_plan/findings/progress)跟踪,不依赖本扫描
24.4 **报告输出**:`<cwd>/.zcode/plans/plan-resume-report.md`(幂等覆盖);主上下文打印摘要(≤5 行):`扫到 N 个中断任务 → M 个推荐 resume / K 个推荐 archive / X 个推荐 drop`;自主续推时必须先打印「选中 task-X + score + 理由」再动手(透明性对冲自主风险)
24.5 **行为契约(v0.5,取代旧"只报告不续推")**:执行中被动扫描**只产出报告,不替用户 resume/archive/drop**;恢复触发点按 plan-resume §7 **自主续推 Top 1**——守卫:单次 1 个计划 / `skip_states` 硬排除 blocked|[awaiting-user]|[hold] / 熔断标记尊重 / 跨仓只报告 / 用户本轮说"不要自动续推"即降级只报告;续推 = 按该计划自身契约接着干(Read 三文件 → 下一 pending Phase),不得改其 Goal/VC/范围
24.6 **失败兜底**:plan-resume 调用失败(脚本缺失/语法错/skill 未安装)→ 主上下文记一行 `[plan-resume] 调用失败: <reason>`,不阻塞当前 Phase 推进
24.7 **不调用/降级例外**:用户已在 prompt 里明确说"不要 plan-resume" → 跳过;说"不要自动续推" → 本轮降级只报告;或本次任务 ≤3 个 phase(噪音大于价值) → 跳过
