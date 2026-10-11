# P2 派发单元 S4 任务书（check-dispatch 打包豁免 + selftest-dispatch FG-05）

在 task-planner 仓 worktree 中执行本单元：check-dispatch.sh 打包检测新增双条件豁免 + selftest-dispatch.sh 新增 FG-05 负例。只改这两个文件。

三文件路径（每行一个）：
/mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/task_plan.md
/mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/findings.md
/mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/progress.md
检查点：/mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/subagent-state/p2-s4.md
知识包：/mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/knowledge-brief.md §2/§3（check-dispatch 锚点行）

## 目标文件与改动

### 1. /mnt/data/dev/task-planner-skill-worktrees/task-v078-guard-fp-fixes/skills/task-planner/scripts/check-dispatch.sh
先 Read L255-290 拿原文。在打包检测的 S-unit ID 计数（约 L264 `grep -oE 'S[0-9]+' "$pf" | sort -u` 一带）之前插入双条件豁免（≤5 行，风格照周边）：
- 条件：prompt 文件同时含「任务书」二字 AND 含字面 `subagent-state/`
- 命中 → 输出一行提示（stderr 或与既有提示同通道）：`[dispatch-guard] SKIPPED 打包检测: prompt 引用落盘任务书(Rule 35.3 范式), 打包判定以任务书内容为准`
- 然后 skip 掉本次打包计数与 hits 累计（不进入 L265-269 逻辑）；warn/enforce 两档都因此不阻断
- 旁注一行注释：`# [2026-09-17 task-v078] 双条件豁免: 单条件 subagent-state 会被合规派发的检查点路径命中(废掉打包门), 禁用`
硬约束：除该豁免块外，打包检测既有逻辑（正则/计数/文案/档位分支）与 L45-47 注释口径一字不动。

### 2. /mnt/data/dev/task-planner-skill-worktrees/task-v078-guard-fp-fixes/skills/task-planner/scripts/selftest-dispatch.sh
先 Read FG-03（L254-264）与 FG-04（L266-276）拿写法。FG-04 之后新增 FG-05：
- prompt 文件内容：含「任务书」字样 + 一条 subagent-state/ 路径 + 多个不同的 S 加数字示例（如 执行顺序示例 S1 先 S2 后 S3 收尾）
- 断言两点：输出含 `SKIPPED 打包检测`；输出不含 `S-unit ID`（即未被判打包）
- FG-03 原样保留（无豁免词的多单元 prompt 仍被判打包）——跑全量确认 FG-03 仍 PASS
- 头注释用例清单与计数同步（如有）

## 自验
1. worktree 内 `bash skills/task-planner/scripts/selftest-dispatch.sh 2>&1 | tail -1` → Total 行 FAIL=0（FG-05 新增 + FG-03 不回归）
2. 双条件豁免实跑：临时造 prompt 文件（含「任务书」+subagent-state/ 路径+多个示例 ID），以 enforce 档（TASK_PLANNER_DISPATCH_ENFORCE=enforce）调用 check-dispatch.sh pretool，断言 exit 0 且输出含 SKIPPED 文案
3. 对照实跑：同 prompt 去掉「任务书」二字 → enforce 档 exit 2 且输出含 S-unit ID 文案（豁免确由双条件生效）
4. `bash -n` 两文件语法过；`git -C /mnt/data/dev/task-planner-skill-worktrees/task-v078-guard-fp-fixes diff --stat` 本次新增仅这 2 文件

## 8 字段严格返回模板
status: done|failed
files_changed: [绝对路径]
acceptance: 4 条自验逐项原文行
evidence: file:line
issues: none|列表
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/subagent-state/p2-s4.md
findings_written: none
blockers: none|一句话
