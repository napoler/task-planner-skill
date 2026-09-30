# P3-S6 任务书: worktree 全量 selftest 回归求和（task-v098,参考值）

任务: worktree 内全量 selftest 复跑逐 Total 行求和（参考值;主进程之后会复核定数）。禁 git commit/add。禁写任何仓库文件。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/task_plan.md（只读）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/findings.md（只读）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/progress.md（子代理禁写,求和结果写检查点）

## 执行
在 /mnt/data/dev/task-planner-skill-worktrees/task-v098-auto-resolution/skills/task-planner/scripts/ 下:
`for f in selftest-*.sh; do out=$(bash "$f" 2>&1); line=$(echo "$out" | grep -E "^(Total:|==== selftest).*PASS" | tail -1); echo "$f -> $line"; done`
然后逐行求 PASS/FAIL 总和。FAILING 的脚本逐个列名。

## acceptance: 验收标准
1) 输出逐脚本 Total 行清单 + 求和行「scripts=N PASS=x FAIL=y」
2) FAIL=0（任何 FAILING 脚本在 issues 详列）
3) 预期 scripts=38（37 既有+selftest-self-resolution）,PASS ≥616（604 基线+SR 12）

## checkpoint
把求和行与 FAILING 清单（如有）写入 /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/subagent-state/05-runner-p3s6.md。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P3-S6
completed_steps: 求和执行
files_written: 检查点路径
evidence: 求和行原文
issues: FAILING 清单或无
next_step: 一句话
self_check: 对照 acceptance 逐条
