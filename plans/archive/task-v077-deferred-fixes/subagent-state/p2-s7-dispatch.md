# P2 派发单元 S7 任务书（subagent_dispatch 禁自报汇总 + critical-rules 22.4b 行内子句）

在 task-planner 仓 worktree 中执行本单元：「统计类只贴逐项原文行禁自报汇总」契约在两处文件落位。只改下列两个文件。

三文件路径（绝对路径，每行一个）：
/mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/task_plan.md
/mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/findings.md
/mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/progress.md
检查点：/mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/subagent-state/p2-s7.md
知识包：/mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/knowledge-brief.md §3 锚点表

## 背景事实（Rule 31 归因压缩）
子代理自报 selftest 总数算术错已 5 次（v074 三次 + v076 基线 253/回归 313，真值 313/330）。既有纪律「总数=主进程逐 Total 行机械求和」只存在于主进程侧，子代理返回格式（8 字段）无此约束 → 立契约。

## 目标文件与改动（先 Read 目标区段拿原文再精确 Edit）

### 1. /mnt/data/dev/task-planner-skill-worktrees/task-v077-deferred-fixes/skills/task-planner/templates/subagent_dispatch.md
§7 返回格式段（L51-73）字段代码块中 acceptance 行（约 L54）之后，紧跟追加一行同缩进的字段补充说明（代码块内，保持原有对齐风格）：

   统计/测试类任务: acceptance 只准贴逐项原文行(如各脚本 rc= 与 Total: 行逐条列出), 禁止自报汇总数字——汇总由主进程逐行机械求和(子代理算术错已 5 次实证)

### 2. /mnt/data/dev/task-planner-skill-worktrees/task-v077-deferred-fixes/skills/task-planner/references/critical-rules.md
L129 = 22.4b 整行。在行内 `acceptance:`(n/total pass + 逐项 PASS/FAIL 及 ≤20 字原因) 括注之后插入同义子句（保持整行单行格式）：

`;统计/测试类任务 acceptance 只准贴逐项原文行(禁自报汇总数字,汇总由主进程机械求和——子代理算术错多次实证)`

注意该行是一整行长句（多子句以 ; 分隔），只在上述锚点后插入，不动其他文字。

## 自验
1. 两文件 grep '机械求和' 各 ≥1 且位于目标区段（Read 复核上下文）
2. critical-rules.md L129（或新行号）仍为单行（`awk 'NR==129{print NF}'` 类核验或 Read 确认无换行断裂）
3. `git -C /mnt/data/dev/task-planner-skill-worktrees/task-v077-deferred-fixes diff --stat` 输出中本次新增仅这 2 文件

## 8 字段严格返回模板
status: done|failed
files_changed: [绝对路径]
acceptance: 3 条自验逐项原文行
evidence: file:line
issues: none|列表
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/subagent-state/p2-s7.md
findings_written: none
blockers: none|一句话
