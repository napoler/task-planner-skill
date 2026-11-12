# 05-general-coder-s4 checkpoint

- timestamp: 2026-11-13T00:00:00Z
- target: skills/task-planner/references/todo-sync.md (worktree: /mnt/data/dev/task-planner-skill-worktrees/task-docmod-recheck-20261112)
- insertion: S1 两组结构子块插入于 S1 表行之后、S2 小节表头之前；新增行范围约 L30-L37（标题+6条+空行）

## 自检输出
1. `grep -c '基线' skills/task-planner/references/todo-sync.md` → 5
2. `grep -n '106.5'` → 30,31,33,36；`grep -n '两组'` → 30,31,34（各≥1）
3. `git diff --stat` → `.../references/critical-rules-discipline.md | 15 +++++++++++++++`（既有非本次改动，未触碰）; `skills/task-planner/references/todo-sync.md | 11 +++++++++++`（本次，纯新增）

## 自审
- 6 条契约逐字落位，B1-B5/Rule 106.5/S3 重建/mini 豁免/事实源分工均覆盖。
- 既有 S1-S5 表格与后续小节内容未改，仅在 S1 行与 S2 表头间插入子块。
- 仅编辑目标文件；未执行 git commit；未碰主仓与其他 worktree。
