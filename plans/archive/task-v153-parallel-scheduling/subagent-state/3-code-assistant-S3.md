
## 里程碑 1（完成）— 模板单元插列
- scope 文件: skills/task-planner/templates/task_plan.md（worktree: /mnt/data/dev/task-planner-skill-worktrees/v153-parallel-scheduling）
- 改动: 表头行插「前置依赖」列（伴飞技能与状态之间，基线 :278 → 实施日 :279）;注释行追加 `Rule 68.1 前置依赖列必填,无依赖填 -（多依赖顿号分隔）`;示例数据行 S1/S2 补 `-` 单元格;既有列零改动
- 验证: grep '前置依赖' 命中 2 行（:277 注释 + :279 表头）;git diff --stat master 仅该文件 1 file（5+/4-）;git status 仅此 1 个 modified
- 组域写隔离: 未碰 SKILL.md / references/ / 计划三文件既有内容
- 结论（供主进程回填 findings）: 施工图 §三 diff 与 worktree 实测逐字一致，插列位置=伴飞技能与状态之间，示例行共 2 行（S1/S2）均已补 `-`
