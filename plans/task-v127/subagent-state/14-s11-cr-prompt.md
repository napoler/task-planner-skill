# task-v127/S11 任务书 — Code Review Gate（代码面审查）

## 1. 目标
对 **worktree** 本任务全部代码变更（4 个 .sh 文件，基线 48c6952→HEAD）做隔离 Code Review，输出 APPROVED 或 CHANGES_REQUESTED。审查维度：正确性（断言逻辑/边界）、可维护性（注释 What/Why、命名）、安全性（无危险操作）、一致性（对齐仓内既有 selftest 范式）。本会话只执行本 S-unit。

## 2. 输入(计划三文件,绝对路径 — Rule 22.4a)
- 任务书:本文件
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md — 只读
- findings: /mnt/data/dev/task-planner-skill/plans/task-v127/findings.md — 只读
- progress: /mnt/data/dev/task-planner-skill/plans/task-v127/progress.md — 只读
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v127/knowledge-brief.md
- 审查对象（worktree 内，git diff 48c6952..HEAD -- '*.sh'）:
  - scripts/selftest-requirement-grading.sh（新建 ~90 行，重点：断言逻辑正确性/grep 模式/git diff 判定边界）
  - scripts/selftest-plan-tier.sh（+2/-1 锚扩窗）
  - scripts/selftest-conclusion-discipline.sh（+3/-2 锚扩窗）
  - scripts/selftest-skill-split.sh（+1/-1 锚级联）
- 参照基线: git -C <worktree> diff 48c6952..HEAD --stat 与逐文件 diff
## 3. 验收标准(2 条)
- [ ] 4 文件逐 hunk 审查完毕，输出结论行 `APPROVED` 或 `CHANGES_REQUESTED`（后者逐条列 P0/P1/P2 问题+定位 file:line+修改建议，禁自行修改）
- [ ] 发现清单落 checkpoint（每条：严重度/位置/问题/建议；无问题则记「零 P0/P1，P2 备注若干」）
## 4. Scope 禁改清单
- 禁改任何文件（纯只读审查；唯一可写=检查点）；主仓 plans/ 只读；禁 git 写操作
## 5. 工作路径
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v127；不切换 CWD
## 6. 时长预算
- 15 分钟；超时返回 partial
## 7. 返回格式(严格 8 字段，之后不得有任何内容)
status: done | partial | failed | timeout
acceptance: <n>/2 pass — [1:PASS 2:PASS]
files: none
evidence: <结论行 + 发现清单摘要>
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/14-s11-cr.md (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
## 8. checkpoint 落盘路径(强制)
- /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/14-s11-cr.md；T5 必写「最终结论」段=第 7 节同一 8 字段块
## 9. 上下文预算
- 用 git diff 逐文件读变更 hunk（禁全文件通读新脚本以外的大文件）；新脚本可全文读
