P3-S1 开工时间: 2026-11-16T13:32:02+00:00
目标: 在 worktree SKILL.md 中插入「计划独立审计门」区块（design-p3-p4.md §A，11行逐字插入于 Spec 模式触发判定行后、[A] 计划确认标题前）
唯一写入文件路径: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-planaudit-20261116/skills/task-planner/SKILL.md

## 自审
- 改动范围：仅 `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-planaudit-20261116/skills/task-planner/SKILL.md` 插入 11 行（Spec 模式触发判定行与「[A] 计划确认」之间），未触碰其他文件。
- 逐字对照：插入内容与 `design-p3-p4.md` §A ```markdown 围栏内文本逐字一致（标题+10条子项，含阻断语义与边界说明），零改写。
- 既有行：文件其余内容未改动；原 `:66` Spec 判定行保留，原 `[A] 计划确认` 标题后移至 `:80`，空行间距与原风格一致。
- 自验：`grep -c "计划独立审计门"`=1；`grep -n "计划独立审计门" | head -3` => `68:- [ ] [A] **计划独立审计门…`；`wc -l`=318。
