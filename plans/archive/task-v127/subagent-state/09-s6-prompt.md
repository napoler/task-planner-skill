# task-v127/S6 任务书 — PT-08 锚扩口径使 1-50 合法 [parallel-group:impl-wave2]

## 1. 目标
在 **worktree** 扩 `scripts/selftest-plan-tier.sh` 的 PT-08 宽容锚口径，使 SKILL.md frontmatter 现值「Critical Rules 全集 1-50」合法（v121 预扩先例的口径演进，断言语义零改动——只扩匹配窗）。本会话只执行本 S-unit。

## 2. 输入(计划三文件,绝对路径 — Rule 22.4a)
- 任务书:本文件
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md — 只读（「强制约束·锚定级联防呆」节）
- findings: /mnt/data/dev/task-planner-skill/plans/task-v127/findings.md — 只读
- progress: /mnt/data/dev/task-planner-skill/plans/task-v127/progress.md — 只读
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v127/knowledge-brief.md §4
- 目标文件: /mnt/data/dev/task-planner-skill-worktrees/task-v127/skills/task-planner/scripts/selftest-plan-tier.sh（**只改此一件**；:78 一带 PT-08 锚 `grep -qE 'Critical Rules 全集 1-4[5-9]'`）
- 背景事实: SKILL.md:9 现值已为「全集 1-50」，`1-4[5-9]` 不匹配 "1-50"（0 命中→PT-08 bad）；改法参照 v121 先例（如扩为 `1-4[5-9]|1-50` 或等效宽容式），注释 label 注明 task-v127 口径演进
- 旁证脚本（**只跑不改**）: scripts/selftest-ask-default-timeout.sh（RT-08 越界负断言 `1-4[0-9]` 对 "1-50" 天然不命中，跑一遍确认 PASS 即可，禁止修改）
## 3. 验收标准(4 条)
- [ ] selftest-plan-tier.sh 单跑全 PASS，PT-08 断言命中 "1-50"（贴 PT-08 相关输出原文行）
- [ ] 改动仅 PT-08 锚一行内的正则扩窗 + 注释 label（`git diff` 显示 ≤3 行变更，断言语义=「全集行存在且 ≥1-45 覆盖」不反转不放宽为恒真）
- [ ] selftest-ask-default-timeout.sh 单跑全 PASS（零改动，贴 Total 行）
- [ ] `git -C <worktree> diff --stat` 仅 selftest-plan-tier.sh 一个文件
## 4. Scope 禁改清单
- 禁改 worktree 内其他任何文件（含 registry/selftest-requirement-grading.sh——另一并行任务的文件，勿碰；selftest-ask-default-timeout.sh 只跑不改）；主仓 plans/ 只读；禁 git add/commit；禁碰其他 worktree
## 5. 工作路径
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v127；不切换 CWD
## 6. 时长预算
- executor → 12 分钟；超时返回 partial
## 7. 返回格式(严格 8 字段，之后不得有任何内容)
status: done | partial | failed | timeout
acceptance: <n>/4 pass — [1:PASS ...]
   统计/测试类: acceptance 只准贴逐项原文行（各脚本 rc 与 Total: 行逐条列出），禁自报汇总数字
files: <绝对路径>(+N/-M)
evidence: <两脚本运行 Total 行原文 + git diff>
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/09-s6-executor.md (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
## 8. checkpoint 落盘路径(强制)
- /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/09-s6-executor.md；T5 必写「最终结论」段=第 7 节同一 8 字段块
## 9. 上下文预算
- 只 Read §2 列出文件；plan-tier.sh 用 grep 定位 PT-08 区段读局部（±15 行）
