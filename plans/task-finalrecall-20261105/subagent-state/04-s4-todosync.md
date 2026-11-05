# S4 检查点：todo-sync.md 追加 Rule 84.14 前置引用

- **S-unit**: S4
- **目标文件**: `/mnt/data/dev/task-planner-skill-worktrees/task-finalrecall-20261105/skills/task-planner/references/todo-sync.md`
- **时间**: 2026-11-05
- **状态**: 完成

## 变更
- 行 31（S4 时机表项，动作列）末尾追加：
  `（**前置=Rule 84.14 收尾回读梳理迭代已完成**——收敛出口（连续一轮零新发现）通过后才可终结 Todo 进入终态同步）`
- 其余行未改；S4 仅出现于时机列表一处，追加 1 处。

## 验收证据
1. `grep -n "84.14" <目标>`:
   - `31:| S4 | ...（**前置=Rule 84.14 收尾回读梳理迭代已完成**...） |`
2. `grep -n "收尾回读梳理迭代已完成" <目标>`:
   - `31:| S4 | ...（**前置=Rule 84.14 收尾回读梳理迭代已完成**...） |`
3. `git -C <worktree> diff --stat -- skills/task-planner/references/todo-sync.md`:
   - `skills/task-planner/references/todo-sync.md | 2 +-`
   - `1 file changed, 1 insertion(+), 1 deletion(-)`

## 风险/遗留
- 无。纯追加，未触碰其他段落。
