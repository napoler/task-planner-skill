# task-v127/S9 任务书 — fresh 独立复验 + alignment-review [parallel-group:verify]

## 1. 目标
以全新视角（不依赖主进程上下文）双线验证 task-v127 产出：① 独立复跑 selftest-requirement-grading.sh + 抽 3 个既有 selftest（plan-tier/conclusion-discipline/ask-default-timeout）确认与 Phase 3 记录一致；② 按仓内 review-library 的 alignment-review 技能流程（读其 SKILL.md 按 SOP 执行五维全文扫描），对 10 个变更文件做对齐审查，输出 APPROVED/CHANGES_REQUESTED + 变更记录三要素。本会话只执行本 S-unit。

## 2. 输入(计划三文件,绝对路径 — Rule 22.4a)
- 任务书:本文件
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md — 只读（VC 表+执行范围）
- findings: /mnt/data/dev/task-planner-skill/plans/task-v127/findings.md — 只读
- progress: /mnt/data/dev/task-planner-skill/plans/task-v127/progress.md — 只读（Phase 3 Test Results=对照）
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v127/knowledge-brief.md §4
- 审查 SOP: /mnt/data/dev/task-planner-skill/skills/task-planner/review-library/alignment-review/SKILL.md（只读，按其流程执行）
- 审查对象（worktree 内 10 文件）: critical-rules.md / SKILL.md / goal-gate.md / templates/variant/{image-type,character-design-type,qc-defect-type}.md / scripts/{selftest-requirement-grading.sh(新), selftest-registry.tsv, selftest-plan-tier.sh, selftest-conclusion-discipline.sh}
- 对齐基准: git -C <worktree> log --oneline -3 与 git show --stat HEAD~1 HEAD
## 3. 验收标准(3 条)
- [ ] 独立复跑 4 脚本 Total 行与 progress.md Phase 3 记录逐条一致（新 7/7、plan-tier 32/0、conclusion 24/0、ask-timeout 9/0）——贴原文行对照
- [ ] alignment-review 按其 SKILL.md 流程执行完毕，输出结论 APPROVED 或 CHANGES_REQUESTED（附逐文件发现清单；CHANGES_REQUESTED 时逐条列修改建议交主进程，禁自行修改）
- [ ] 变更记录三要素（变更了什么/为什么/影响面）写进 checkpoint「最终结论」段
## 4. Scope 禁改清单
- 禁改任何仓库/worktree 文件（纯只读审查；唯一可写=检查点）；主仓 plans/ 只读；禁 git 写操作；禁碰其他 worktree
## 5. 工作路径
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v127；不切换 CWD
## 6. 时长预算
- executor → 20 分钟；超时返回 partial
## 7. 返回格式(严格 8 字段，之后不得有任何内容)
status: done | partial | failed | timeout
acceptance: <n>/3 pass — [1:PASS ...]
   统计/测试类: acceptance 只准贴逐项原文行，禁自报汇总数字
files: none
evidence: <4 脚本 Total 行对照 + alignment-review 结论行>
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/12-s9-verifier.md (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
## 8. checkpoint 落盘路径(强制)
- /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/12-s9-verifier.md；T5 必写「最终结论」段=第 7 节同一 8 字段块
## 9. 上下文预算
- alignment-review SKILL.md 读流程节；10 个变更文件用 git diff 定位变更区段后读局部，禁全文通读大文件（critical-rules.md 只读 ：484-545 区段）
