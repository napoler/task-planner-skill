# P2 派发单元 S6 任务书（plan-writer 契约 + task_plan 模板各一处置入）

在 task-planner 仓 worktree 中执行本单元：S-unit ID=纯数字 契约在两处文件落位。只改下列两个文件。

三文件路径（绝对路径，每行一个）：
/mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/task_plan.md
/mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/findings.md
/mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/progress.md
检查点：/mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/subagent-state/p2-s6.md
知识包：/mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/knowledge-brief.md §3 锚点表

## 目标文件与改动（先 Read 目标区段拿原文再精确 Edit）

### 1. /mnt/data/dev/task-planner-skill-worktrees/task-v077-deferred-fixes/skills/task-planner/companion/agents/plan-writer.md
产出契约表（约 L106-116，knowledge_brief 行=L116）之后新增一个表行，对齐既有表行列格式：

| **s_unit_id** | S-unit 表 ID 列一律纯数字（S1、S2…全局或每 Phase 内唯一均可，禁字母后缀如 S2a——check-plan-dispatch.sh 数据行正则 `^\|\s*S[0-9]+\s*\|` 不认字母后缀，attest 会以「缺 S-unit 表或数据行」拒锁；task-v076 实证教训） |

### 2. /mnt/data/dev/task-planner-skill-worktrees/task-v077-deferred-fixes/skills/task-planner/templates/task_plan.md
S-unit 表注释块（L182-187，现有 ①②③ 三条）之后追加一行同格式注释：

④ ID 列一律纯数字（S1/S2…），禁字母后缀——check-plan-dispatch.sh 数据行正则不认 S2a 式命名，attest 拒锁（task-v076 教训）

## 自验
1. 两文件 grep '纯数字' 各 ≥1，且新行在目标区段内（Read 复核上下文）
2. plan-writer.md 契约表新行的 `|` 数与 L116 行一致
3. `git -C /mnt/data/dev/task-planner-skill-worktrees/task-v077-deferred-fixes diff --stat` 输出中本次新增仅这 2 文件（此前单元已改文件原样保留）

## 8 字段严格返回模板
status: done|failed
files_changed: [绝对路径]
acceptance: 3 条自验逐项原文行
evidence: file:line
issues: none|列表
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/subagent-state/p2-s6.md
findings_written: none
blockers: none|一句话
