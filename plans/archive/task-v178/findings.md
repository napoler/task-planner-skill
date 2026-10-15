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
- 仓结构=分层架构（task-v171）：核心 critical-rules.md 仅 14 条核心域规则（191 行）；Rule 31（错误学习闭环）全文在 `skills/task-discipline/references/critical-rules-discipline.md:68-78`；Rule 38.7 L0-T 档在 `skills/plan-template-kit/references/critical-rules-template.md:49`。证据=本会话 grep/Read。
- 断言面侦察：selftest 全集对 critical-rules-discipline.md 仅文本锚（CRIT_D 变量引用 10+ 处），无行数钉、无 31.x 计数断言；「31.8」编号未被任何文件占用（grep 全仓）——纯增量加行零级联风险。实测证实：加行后 selftest-error-loop 16/16 + fresh 全量 81/81 PASS。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 落点选 Rule 31 新增 31.8 子条（而非新 Rule/Rule 4/Rule 73） | 用户偏差本质=错误学习闭环链路的诉求层级错位（31 管错误→防复发链路）；31.3 已有修正路由但只覆盖 agent 自主归因，未覆盖「用户显式指定制度层交付物」契约；并入既有 Rule 避免新编号级联（Rule 20.6/纪元锚教训），符合 Rule 74 增量默认 |
| 执行通道 L0-T 纯文本档+主仓直做（不开 worktree） | 规则类诉求零脚本零机器门=38.7 L0-T 定义场景；task-v177 先例（4bbc1f6）纯文本 master 直接提交；宪法 §四.6 流程开销与变更体量成比例 |
| 部署位（~/.zcode/skills/task-discipline/）本次不同步 | §六 保护区+历史判例部署同步需用户单独授权；交付报告中列明待授权项 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| 首次 Edit 被写守卫拦截（.plan-required 哨兵，plans/ 外写入禁止） | 按守卫指示走 Skill(task-planner) 建 mini 计划+attest+清哨兵后重试成功——守卫按设计工作，非错误 |
| attest-plan.sh 传目录路径报「no task_plan.md found」 | 该脚本参数语义=task_plan.md 文件路径而非目录；传文件路径后锁定成功（SHA-256 f00229ae…） |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
