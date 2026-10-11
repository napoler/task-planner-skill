# task-v127/S7 任务书 — CD-11 锚扩口径含 1-50 [parallel-group:impl-wave2]

## 1. 目标
在 **worktree** 扩 `scripts/selftest-conclusion-discipline.sh` 的 CD-11 锚口径：SKILL.md 全集字面 1-49→1-50 后 `1-4[5-9]` 计数下降，扩计数模式为同时匹配 `1-50`（v121 宽容化先例，合计阈值语义零改动）。本会话只执行本 S-unit。

## 2. 输入(计划三文件,绝对路径 — Rule 22.4a)
- 任务书:本文件
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md — 只读（「强制约束·锚定级联防呆」节）
- findings: /mnt/data/dev/task-planner-skill/plans/task-v127/findings.md — 只读
- progress: /mnt/data/dev/task-planner-skill/plans/task-v127/progress.md — 只读
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v127/knowledge-brief.md §4
- 目标文件: /mnt/data/dev/task-planner-skill-worktrees/task-v127/skills/task-planner/scripts/selftest-conclusion-discipline.sh（**只改此一件**；:66/:69-70 一带 CD-11：n35=`grep -cE '1-3[5-9]'` + n45=`grep -cE '1-4[5-9]'` 合计 ≥3）
- 背景事实: worktree SKILL.md:9 现值「全集 1-50」→ n45 计数较基线少 1（1-49 那处消失）；改法=n45 模式扩为 `1-4[5-9]|1-50`（或等效），注释 label 注明 task-v127；「Rules 1-39」计数锚（SKILL.md :248/:309 两处）不受影响勿动
## 3. 验收标准(4 条)
- [ ] selftest-conclusion-discipline.sh 单跑全 PASS（贴 CD-11 相关输出原文行）
- [ ] 改动仅 CD-11 计数模式扩窗 + 注释 label（git diff ≤3 行变更，合计 ≥3 阈值语义不反转）
- [ ] 全脚本其余断言零变化（Total 总数与改前一致——先跑一次改前基线记录 Total，再改，再跑对比）
- [ ] `git -C <worktree> diff --stat` 仅 selftest-conclusion-discipline.sh 一个文件
## 4. Scope 禁改清单
- 禁改 worktree 内其他任何文件（含 registry/selftest-plan-tier.sh——另一并行任务的文件，勿碰）；主仓 plans/ 只读；禁 git add/commit；禁碰其他 worktree
## 5. 工作路径
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v127；不切换 CWD
## 6. 时长预算
- executor → 10 分钟；超时返回 partial
## 7. 返回格式(严格 8 字段，之后不得有任何内容)
status: done | partial | failed | timeout
acceptance: <n>/4 pass — [1:PASS ...]
   统计/测试类: acceptance 只准贴逐项原文行（改前/改后 Total 行逐条列出），禁自报汇总数字
files: <绝对路径>(+N/-M)
evidence: <改前/改后 Total 行 + git diff>
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/10-s7-executor.md (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
## 8. checkpoint 落盘路径(强制)
- /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/10-s7-executor.md；T5 必写「最终结论」段=第 7 节同一 8 字段块
## 9. 上下文预算
- 只 Read §2 列出文件；脚本用 grep 定位 CD-11 区段读局部（±20 行）
