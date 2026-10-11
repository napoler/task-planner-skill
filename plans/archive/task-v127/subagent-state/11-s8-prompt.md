# task-v127/S8 任务书 — 全量 selftest 回归 [parallel-group:verify]

## 1. 目标
在 **worktree** 跑全部 selftest-*.sh（应 46 个：45 既有+1 新建），逐脚本收集 Total 行并机械求和，预期 FAIL=0、总数 ≥709 PASS（基线 v126=45 脚本 702/0 + 新脚本 7）。留痕输出到检查点。本会话只执行本 S-unit。

## 2. 输入(计划三文件,绝对路径 — Rule 22.4a)
- 任务书:本文件
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md — 只读（VC-6）
- findings: /mnt/data/dev/task-planner-skill/plans/task-v127/findings.md — 只读
- progress: /mnt/data/dev/task-planner-skill/plans/task-v127/progress.md — 只读（Phase 3 段=对照基线）
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v127/knowledge-brief.md §4
- 执行面: /mnt/data/dev/task-planner-skill-worktrees/task-v127/skills/task-planner/scripts/selftest-*.sh（只读运行）
## 3. 验收标准(3 条)
- [ ] 逐脚本循环跑（for f in selftest-*.sh; do bash "$f"; done 形态），收集每脚本 rc 与 Total 行原文，逐条列进 checkpoint（禁自报汇总数字，汇总由主进程机械求和）
- [ ] 失败脚本（rc≠0 或 Total 含 FAIL>0）逐个单独重跑定位：锚过窄→报告（主进程裁决 v121 宽容化）；内容越界→报告（22.3 拆细回炉）；禁止自行修任何文件
- [ ] 输出统计行：脚本总数 / PASS 总数 / FAIL 总数（机械累加自逐脚本 Total 行）
## 4. Scope 禁改清单
- 禁改任何文件（纯只读回归）；主仓 plans/ 只读；禁 git 写操作；禁碰其他 worktree；单脚本超时 120s（timeout 命令包裹）
## 5. 工作路径
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v127；不切换 CWD
## 6. 时长预算
- code-runner → 20 分钟；超时返回 partial
## 7. 返回格式(严格 8 字段，之后不得有任何内容)
status: done | partial | failed | timeout
acceptance: <n>/3 pass — [1:PASS ...]
   统计/测试类: acceptance 只准贴逐项原文行（各脚本 Total: 行逐条列出），禁自报汇总数字
files: none
evidence: <各脚本 Total 行 + 统计行>
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/11-s8-runner.md (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
## 8. checkpoint 落盘路径(强制)
- /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/11-s8-runner.md；T5 必写「最终结论」段=第 7 节同一 8 字段块
## 9. 上下文预算
- 不读 selftest 脚本内容（只执行）；输出重定向到检查点文件再摘 Total 行，禁把全量输出塞进返回
