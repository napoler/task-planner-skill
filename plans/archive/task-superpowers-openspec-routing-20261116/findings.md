# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1 [目标]：按任务复杂度在 Superpowers/OpenSpec 两族间择一路由执行（user-session-log.md #1 逐字锚）
- R2 [目标]：引 comet「按复杂度/画像选变体」机制方式引入两族任务解决能力
- R3 [目标]：最小引入难度 + 保持技能整洁（→裁决=既有载体条款扩展，零新文件零脚本）
- R4 [手段]：确认当前集成现状（已答：部分完成，2026-11-15 已落 Spec 模式路由+三族触发矩阵）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- [2026-11-16] general-purpose 调研子代理返回并盘上复核（4 处证据锚 sed 抽查逐字一致）：**A** 仓内已存在显性集成——`task-planner/SKILL.md:65,71,266`（Spec 模式触发+路由 brainstorming/openspec-propose）、`references/spec-mode.md`（路由表+安装引导+反模式+R6 调用不复制铁律）、`plan-collab-router/SKILL.md:17-25` + `references/skill-collaboration.md §二:51-68`（comet→OpenSpec→superpowers 判定顺序触发矩阵）、`task-dispatch 22.3.3 接管评估`、`knowledge-brief.md:70-77 扫描条款`；**B** comet 机制=CLI resolve+IntentFrame/runtime scorer（comet-classic SKILL.md:32-44,78-127），非静态表；**C** superpowers=过程纪律技能族（using-superpowers 强制先查后答）；**D** OpenSpec=spec 驱动 change 生命周期，前置 openspec CLI；**E** 竞合 6 条（双真源/执行控制/TDD 门控重叠等）；**F** 设计建议 5 条（调用不复制/轻量决策表不复制 runtime/知识 brief 复用/建议性 handoff/统一权威源）。
- 全文=同目录 `findings-external-families.md`（135 行，六段 A-F，逐条 file:line 证据锚）。**缺口结论**：①无复杂度显式路由轴 ②无两族整族择一的 comet 式画像决策表 ③comet 画像评分机制未引入。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 载体=既有条款扩展（spec-mode.md §1b + skill-collaboration.md §二初筛段 + SKILL.md:65 指针行） | 用户裁决 Q1；findings F1/F2/F5 一致指向；零新文件零脚本，双真源风险最低 |
| 判据=复杂度主轴（体量分级 L0/mini→L1→L2+）+信号修正（触及已有 spec→OpenSpec 等） | 用户裁决 Q2；沿用 Rule 21 分级零新概念，信号修正防「小规格变更」误路由 |
| 择一语义=同任务同阶段两族择一主导，跨阶段可切换 | findings E1/E2 双真源/控制权分裂风险；comet 式全托管不复制（F4 建议性 handoff） |
| Phase 3 条款实现主进程直做（例外理由②计划系统文件维护） | 本仓=task-planner 技能自身；条款措辞与既有锚强一致，拆派需转述全量设计上下文，收益<风险 |
| worktree 基点=master（禁用 main） | 本仓 main 无共同祖先（记忆判例 main-master-unrelated-histories-branch-gotcha） |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
