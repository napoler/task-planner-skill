# S8 检查点：progress.md / findings.md token 化

- task-id: task-tplrender-20261024
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-tplrender-20261024
- 状态: done

## 变更（仅 2 文件）
1. skills/task-planner/templates/progress.md
   - `## Session: [DATE]` → `## Session: {{DATE}}`
   - `- **Started:** [YYYY-MM-DD HH:MM]` → `- **Started:** {{DATETIME}}`
   - 首行标题下追加渲染契约注释
2. skills/task-planner/templates/findings.md
   - 无机械占位符；仅首行标题下追加渲染契约注释

## 保留（逐字未动）
- progress.md `### Phase 1: [Title]` / `### Phase 2: [Title]`
- progress.md `<待沉淀>`、`[一句话目标]`、`[plan-resume 跳过原因]`
- findings.md 全部 `-` 空列表占位与注释指引

## 自检
- progress.md `grep -cE '\[DATE\]|\[YYYY-MM-DD HH:MM\]'` = 0
- progress.md `grep -c '{{DATE}}\|{{DATETIME}}'` = 2
- progress.md `grep -c '\[Title\]'` 改前 2 → 改后 3（+1 来自契约注释正文含 `[Title]` 字样，非 Phase 标题变动）
- findings.md 占位 grep = 0
- 行数：progress 66→67，findings 45→46，合计 +2（≤6）

## 风险
- 契约注释含 `[Title]` 字样导致 Title grep 计数 +1，如需 grep 严格一致可去掉注释中的 `[Title]` 示例词。
