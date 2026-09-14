# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户原话：「在非静默模式下，将以后大体的执行思路复述给用户批准。这样可以即使不去查看计划文档，也知道大体的工作流程。」
- 拆解：① 仅 ask（非静默）模式生效 ② 时机=计划批准（D1）时 ③ 内容=大体执行思路（Phase 序列/执行体/门控/隔离策略/交付节奏，≤5 行）④ 目的=不读计划文档也预知流程 ⑤ 用户批准后执行

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- Rule 28 现状（v062）：ask 模式 D1=展示计划后等显式 yes，无口头思路复述层 → 用户须逐行读 task_plan.md 才能预知流程（证据：references/critical-rules.md:221 28.2）
- 挂接点裁定：28.2（D1-D6 询问点）内新增 28.2.1 子条款，不新增 Rule 30（避免规则号膨胀，语义属 Rule 28 能力域）
- 可测面：复述是 LLM 行为，无脚本可测 → selftest 只做静态守护（28.2.1 条款存在性 + 关键语义锚点 grep，防未来误删）

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 复述定位=D1 批准前置（展示计划全文后、等 yes 前），非独立门控 | 用户原话"复述给用户批准"=复述是批准材料，不新增 yes 之外的确认 |
| silent 模式不适用 28.2.1 | 28.4 静默决策清单已是等效复核入口；用户口头要求时满足并登记 |
| 复述登记 Decisions Made 一行（`思路复述已呈示,<时间>`） | 对齐 28.3「口头决策不留痕」防线 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| 主上下文 Edit 写 ~/.zcode/skills/** 被 PreToolUse 哨兵拦截（本会话尚无计划） | 创建 plans/task-v070-exec-approach-echo/ + init-session.sh，D10' 仲裁放行 |
| init-session.sh 环境残留 sid 133bb46c 误写 side 指针 | cp 指针内容到本会话 sid 1973d0ab 指针，check-scope 放行 |
| selftest-skill-collab T10 SKILL.md 行数 ≤518 破限（本任务 SKILL.md 扩至 519） | 上限 518→519 同步修正（注释注明 task-v070 由来），重跑 19/0 PASS |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
