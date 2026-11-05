# S3 检查点：deprecated.md 分工声明 + .gitignore trash/ 行

- **S-unit ID**: S3（task-trashcan-20261105）
- **状态**: complete
- **时间**: 2026-11-05
- **工作树**: `/mnt/data/dev/task-planner-skill-worktrees/task-trashcan-20261105`

## 变更

| 文件 | 操作 | 说明 |
|------|------|------|
| `skills/task-planner/templates/deprecated.md` | Edit（+1 行） | 头注释 WHAT/WHEN/分账块内追加 Rule 100.6 分工声明（逐字按要求） |
| `.gitignore` | Edit（+3 行，含空行+注释+规则） | `tmp/` 后追加 trash/ 注释与 `trash/` 忽略行，对齐既有风格 |

## 验收自证

1. `grep -c "Rule 100.6" /mnt/data/dev/task-planner-skill-worktrees/task-trashcan-20261105/skills/task-planner/templates/deprecated.md` → **1**（≥1，PASS）
2. `grep -n "trash/" /mnt/data/dev/task-planner-skill-worktrees/task-trashcan-20261105/.gitignore` → **30:trash/**（命中规则行；注释行 29 亦含 “trash/” 文本，满足“含注释行共 2 行”意图，PASS）
3. `git -C /mnt/data/dev/task-planner-skill-worktrees/task-trashcan-20261105 diff --stat`：
   - `.gitignore | 3 +++`
   - `skills/task-discipline/references/critical-rules-discipline.md | 1 +`（**非本单元修改**，worktree 既有变更）
   - `skills/task-planner/templates/deprecated.md | 1 +`
   - 本单元触达文件仅：`.gitignore`、`skills/task-planner/templates/deprecated.md`。

## 未完成面/风险

- worktree 中存在非本单元的既有改动：`skills/task-discipline/references/critical-rules-discipline.md`（+1），提交/合并时需由上游编排确认范围，避免误入。

## 下次动作建议

- 由编排侧决定是否连同 worktree 其他单元变更一并提交/合并；本单元 S3 已满足验收。
