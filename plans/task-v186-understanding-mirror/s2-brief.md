# S2 任务书 — 两模板配对格式（task-v186）

## 编辑 1：逐字专档模板
文件：`<worktree>/skills/task-planner/templates/user-session-log.md`
- Read 全文。在「## #N | YYYY-MM-DD | 来源：…」示例条目块（三行引用块）之后、「<!-- 条目格式范式」注释之前，插入：

```
### #N 理解镜像 | YYYY-MM-DD（模型理解同步记录 — Rule 80.7；紧随同号逐字条目追加；非权威对照面，冲突以逐字原文为准）
> <模型对该条请求的整理理解，要点化 ≤10 行：任务对象/范围边界/验收期望/约束假设；理解演进时追加「### #N 理解镜像更正」新块注明改判要点与依据，禁改旧镜像块>
```

- 并在「<!-- 条目格式范式（复制后随正文保留…」注释内的 ③ 条之后追加一行：
  `  ④ 理解镜像配对（Rule 80.7）：每条逐字条目后同号追加理解镜像块（非权威对照面；冲突以逐字原文为准；更正=追加新块禁改旧块；写入者=主进程单写）`

## 编辑 2：计划模板指针区块
文件：`<worktree>/skills/task-planner/templates/task_plan.md`
- Read 全文，定位「🗣️ 用户会话逐字记录」区块内的 `- **恢复协议**：` 行。
- 在该行之后插入一行：
  `- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）`
- 红线：本区块受 SL-08 负断言约束（禁「当前条目数/最近一条」类可变计数）——新增行不含任何计数词，勿添加。

## 自验（worktree 根）
- `grep -c "理解镜像" skills/task-planner/templates/user-session-log.md` ≥2
- `grep -c "理解镜像" skills/task-planner/templates/task_plan.md` =1
- `grep -cE "当前条目数|最近一条" skills/task-planner/templates/task_plan.md` =0

## 检查点
Write `/mnt/data/dev/task-planner-skill/plans/task-v186-understanding-mirror/subagent-state/2-s2-executor.md`（status+grep 原始输出+改动处数）。不匹配→STOP 记录实际字面。
