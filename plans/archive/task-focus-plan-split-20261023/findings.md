# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1-R4 逐字锚见 task_plan.md「🎯 用户需求原文」+ user-session-log.md #1；语义=新增专注性/计划隔离规范：重大偏差（目标 A→B）→主动询问拆分新 Task Plan→单计划单垂直域防污染
- 诉求层级=制度层（Rule 31.8）：交付物=规则文本条款落入最贴近载体，禁降维修具体 bug 现场

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| Rule 93 落地判例 diff | master `2f1b88f`（git diff 45eda8c..19e66fe，10 文件 +94/−26） | ☑ | §Research Findings 第 1 条 |
| discipline 规则段式 | critical-rules-discipline.md L530-603（88-93 七条 `### N` 段式+子条+建制+衔接+机制 L0-T） | ☑ | §Research Findings 第 3 条 |
| 级联面侦察结论 | subagent-state/01-explore-cascade.md（117 行，1-7 项） | ☑ | §Research Findings 第 2 条 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **[级联判例]** Rule 93 落地（task-v195）净改 10 文件：规则正文（discipline references）+卫星 SKILL 计数 4 处+核心 critical-rules.md 1 行+主 SKILL.md 5 处+CLAUDE/README_zh/planner README/ARCHITECTURE 纪元计数+task_plan 模板（本任务模板面无命中不改）+召回卡新文件。判例未新增 selftest（L0-T 纯文本档先例）；`rule-reserve.sh next`=94。证据：subagent-state/01-explore-cascade.md §1
- **[级联面清单]** 新规则 94 级联触点（归属 discipline 方案）：critical-rules-discipline.md 文件尾插入；discipline SKILL.md L15（44 条→45）/L24/L76/L87；核心 critical-rules.md L194 枚举尾；主 SKILL.md L9/L17/L196/L209（计数 74→75）/L251；CLAUDE.md L33；README_zh.md L136/L229；planner README.md L4/L81/L123/L127；ARCHITECTURE.md L4/L13/L42/L113/L122/L134/L136。SKILL.md 行数边距 267/275（BP-08）可容 +1 指针句。证据：01-explore-cascade.md §3/§4/§7
- **[破裂锚实证]** selftest 机器锚全部为宽容族：CD-11 `1-(3[5-9]|9[0-9])`、RR-09 `Rules 1-[89][0-9]`、EL-11、SL-05 `1-[89][0-9]`、WF-10 变体族（历史注释行恒 PASS）——1-94 落地**零 selftest 破裂**；规则总数断言（44/74/76）为散文声明非机器锚（判例 65ceed7 系 CR 人工级联）。证据：01-explore-cascade.md §5
- **[归属裁决依据]** ①语义同源：新规则=Rule 8.1/8.1.1（新任务边界+E 类确认）的处置动作补强，discipline 已收 8/87/88；②九x纪元先例：90/92/93 全在 discipline，drift 卫星自 v171 冻结 4 条（DCS-09 守护「Rule 11,15,61,64」字面，drift 方案破裂面大）；③Rule 82 归属：决策处置纪律=纪律域非检测机制域。证据：01-explore-cascade.md §2

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 规则 94 六子条结构（94.1 总纲/94.2 判据/94.3 询问门/94.4 隔离处置/94.5 衔接/94.6 机制 L0-T） | 对齐 88-93 既有段式（建制+协议+衔接+机制）；94.2 管辖二分防与 Rule 64/61/8.1/88 双头管辖 |
| 正文插入点=critical-rules-discipline.md 文件尾（Rule 93 段后） | 编号单调递增惯例（93 为当前尾条）；文件尾追加零既有行改动（74.2 增量默认） |

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
