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
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

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

## Research Findings（2026-11-05 Phase 1 调研收口）
**执行体**：Explore（239k tokens/25 调用），检查点=subagent-state/01-explore-trash.md（主进程代落复核）
**核心结论**：Rule 100 至 100.5 无废弃处置面；tmp/ 随清理链被清→垃圾桶须独立 trash/（持久不清理）；deprecated.md/73.5=内容条目级与文件级垃圾桶互补；媒体现状=原地 -failed/-superseded 重命名堆放（缺陷本体，variant 模板 image-type VC-6/video-type L61/L72 承载）。
**设计决策（低区分度自主裁决，44.2）**：目录定名 `<project-root>/trash/`（项目根/gitignore/不随任务清理——与 tmp 本质区别=废弃可找回 vs 临时可再生）。

## 发现登记（Phase 5 终验期，另行任务）
- check-complete Batch Report 检测器要求区块在位（missing: entire section 拦截），但模板 batch_report 注释称「纯单次任务可删除整个区块」——模板与检测器不一致（与 check-plan-dispatch 列位漂移同族：模板演进检测器未同步）；本计划按检测器口径恢复并如实填报
