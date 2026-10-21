# Findings & Decisions
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

### [sub:P1-S4] 全量 selftest 回归（2026-10-22）
- 92/92 PASS FAIL=0 零回归；6 个引用 templates/task_plan.md 的守卫逐一确认 PASS：ask-default-timeout 11/11（RT-05 锚在位）、conclusion-discipline 24/24（CD-21）、absorption-discipline 16/0/1skip（AD-13 环境性中性：worktree 无 v162 目录，与改动无关）、decision-drift 23/23、goal-unit-goal-mode 9/9（G-03）、error-loop 16/16（EL-14）
- **守卫面性质结论**：6 守卫全为内容锚断言（区块/关键词在位），非行数定数——模板纯插入行零级联（改前 grep 判定，改后实跑证实）
- **证据**：subagent-state/P1-S4-code-runner.md

### [main] 载体机制确认（2026-10-22）
- init-session.sh 模板解析=项目级 .zcode/plan-templates/ 按文件名覆盖 → 部署位 templates/ 兜底（:62,87）；repo 侧 skills/task-planner/templates/task_plan.md 是部署位模板的源（556 行）
- 本仓 init 实际生效路径：本次 cp 后走项目级覆盖（含两步）；部署位同步后可删覆盖文件回单一源（登记遗留）
- **证据**：init-session.sh:65-97 + worktree init 冒烟（生成 task_plan.md:353/:355 实证两步注入）

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
