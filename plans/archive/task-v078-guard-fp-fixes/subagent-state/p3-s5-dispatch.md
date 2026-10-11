# P3 派发单元 S5 任务书（execution-stability 提醒豁免行为用例）

在 task-planner 仓 worktree 中执行本单元：selftest-execution-stability.sh 新增「已交付计划提醒豁免」行为用例。只改这一个文件。

三文件路径（每行一个）：
/mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/task_plan.md
/mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/findings.md
/mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/progress.md
检查点：/mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/subagent-state/p3-s5.md
知识包：/mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/knowledge-brief.md §2/§3（execution-stability 锚点行）

## 目标文件
/mnt/data/dev/task-planner-skill-worktrees/task-v078-guard-fp-fixes/skills/task-planner/scripts/selftest-execution-stability.sh

## 前置
先跑一遍该脚本记录基线 Total（既有用例全 PASS 才继续；FAIL 先 STOP 报告）。

## 改动
先 Read T11a/b（L106-135 一带）与既有 fixture 手法拿范式，然后新增行为用例（命名跟随既有体系）：
- fixture：临时计划目录，task_plan.md 陈旧 mtime（无 outcome 字样），另含 verification.md 内容为前导空格加 `outcome: COMPLETE`（模拟真实落盘格式）
- 执行 POSTTOOL hook（调用手法照 T11a/b：stdin JSON + 干净 sid）
- 断言一：输出不含 plan-compass 与 plan-sync 陈旧提醒（豁免生效——本仓 worktree 的 zcode-posttooluse.sh 已含 verification.md 兜底分支）
- 断言二（因果对照）：同 fixture 删掉 verification.md 再执行 → 输出含陈旧提醒（证明豁免由兜底分支因果生效，非环境巧合）
- 头注释用例清单/计数如有则同步

## 自验
1. 前置基线 Total 记录 + 改后全量 Total：新增用例 PASS 且既有用例无回归，FAIL=0
2. `bash -n` 过
3. `git -C /mnt/data/dev/task-planner-skill-worktrees/task-v078-guard-fp-fixes diff --stat` 仅该文件

## 8 字段严格返回模板
status: done|failed
files_changed: [绝对路径]
acceptance: 3 条自验逐项原文行（含前置基线 Total）
evidence: file:line
issues: none|列表
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/subagent-state/p3-s5.md
findings_written: none
blockers: none|一句话
