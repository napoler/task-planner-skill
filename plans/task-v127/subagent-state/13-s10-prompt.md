# task-v127/S10 任务书 — skill-split 行数锚级联 449→450

## 1. 目标
在 **worktree** 把 `scripts/selftest-skill-split.sh` 的 T-主 行数锚从 449 联动到 450（SKILL.md 因本计划 SKILL 联动步骤净增 1 行所致；v126 同款机制级联 440→442→444→447→449→450；label 注明 task-v127），并复跑该脚本确认全 PASS。本会话只执行本 S-unit。

## 2. 输入(计划三文件,绝对路径 — Rule 22.4a)
- 任务书:本文件
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md — 只读（Decisions D8=B 类扩围授权）
- findings: /mnt/data/dev/task-planner-skill/plans/task-v127/findings.md — 只读
- progress: /mnt/data/dev/task-planner-skill/plans/task-v127/progress.md — 只读
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v127/knowledge-brief.md §4
- 目标文件: /mnt/data/dev/task-planner-skill-worktrees/task-v127/skills/task-planner/scripts/selftest-skill-split.sh（**只改此一件**）
- 失败原文: `[FAIL] T-主 行数 ≤449（task-v126 Rule 49 联动 +2;演进 440→442→444→447→449）且 ≤558 上限`（worktree SKILL.md wc -l=450）
## 3. 验收标准(3 条)
- [ ] 仅改锚数字 449→450 + label 补 task-v127（git diff ≤4 行变更，≤558 钉上限与断言语义零改动）
- [ ] selftest-skill-split.sh 复跑全 PASS rc=0（贴改前/改后 Total 行原文）
- [ ] `git -C <worktree> diff --stat` 仅此一个文件
## 4. Scope 禁改清单
- 禁改 worktree 内其他任何文件；主仓 plans/ 只读；禁 git add/commit；禁碰其他 worktree
## 5. 工作路径
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v127；不切换 CWD
## 6. 时长预算
- executor → 8 分钟；超时返回 partial
## 7. 返回格式(严格 8 字段，之后不得有任何内容)
status: done | partial | failed | timeout
acceptance: <n>/3 pass — [1:PASS ...]
   统计/测试类: acceptance 只准贴逐项原文行（改前/改后 Total 行），禁自报汇总数字
files: <绝对路径>(+N/-M)
evidence: <改前/改后 Total 行 + git diff>
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/13-s10-executor.md (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
## 8. checkpoint 落盘路径(强制)
- /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/13-s10-executor.md；T5 必写「最终结论」段=第 7 节同一 8 字段块
## 9. 上下文预算
- 只 Read 目标脚本 T-主 断言区段（grep 定位 ±10 行），禁全文通读
