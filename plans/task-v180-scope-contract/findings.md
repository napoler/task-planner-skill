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
- **2026-10-16 撞号排查（用户指令：搞清在途 task-v179 与 87 号用途，避免撞号）**：本计划初判的 Rule 87 与在途 task-v179 双撞号（任务号+Rule 号）。第一手证据：① 台账 `plans/.rule-reservations.jsonl` 第 71 行 `{"rule":87,"status":"reserved","task_id":"task-v179","ts":"2026-10-16"}`（主仓工作区未提交态，`git show HEAD:` 无此行——跨会话视图不一致的根源之一）；② `rule-reserve.sh check 87` → `held by task-v179 (reserved)` exit 3；③ wt/task-v179 已提交 f0a4393「Rule 87 精准执行与极简改动纪律（Karpathy AGENTS.md 七组准则收编）87.1-87.8+双 SKILL+core 索引 1-87」，其 VC-6（合并回 master+worktree 清理）pending；④ 本任务 88 号已 reserve 成功（台账第 72 行，note=任务射程契约）。**处置**：目录改名 task-v180-scope-contract + Rule 改 88 + task_plan.md 全量残留清理 + D4 登记 + 同文件（critical-rules-discipline.md 末段追加）串行化前置——本任务待 task-v179 合并回 master 后再实施，禁并行双写同一追加锚点。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| Rule 87/任务号 v179 与在途 task-v179（Karpathy 准则收编）双撞号——计划期凭 `next` 只读快照定号，快照与 reserve 实写之间存在竞态窗口，且台账未提交导致跨会话视图不一致 | 目录改名 task-v180-scope-contract + Rule 改 88（台账第 72 行 reserve exit 0）；task_plan.md 全量 87→88 残留清理 + D2 过时理由修正 + D4 撞号处置登记；re-attest 重锁新 SHA |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
