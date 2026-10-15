# 6-executor Checkpoint

**状态**: FINAL — 6 文件 x2 行全部切换完成

## Scope 清单（仅 6 文件，每文件恰好 2 处）

基础路径: `/mnt/data/dev/task-planner-skill-worktrees/task-v146/skills/task-planner/templates/variant/`

1. bugfix-type.md
2. deployment-type.md
3. schema-migration-type.md
4. performance-tuning-type.md
5. code-edit-type.md
6. test-writing-type.md

## 切换规则

- 终验行类（`- [ ] ` 开头、含 `Skill("task-drift-guard")` 与 `终验`）：整行替换为 `- [ ] 派发 \`drift-checker\` 子代理偏移检查（Rule 61 载体）终验`
- 周期跑行类（含频次词 + `Skill("task-drift-guard")`）：保留频次词与箭头格式，仅替换调用部分为 `派发 \`drift-checker\` 偏移检查（Rule 61 载体）`

## 进度

- [x] bugfix-type.md (终验 L109 + 周期跑 L158)
- [x] deployment-type.md (终验 L108 + 周期跑 L158)
- [x] schema-migration-type.md (终验 L110 + 周期跑 L160)
- [x] performance-tuning-type.md (终验 L109 + 周期跑 L159)
- [x] code-edit-type.md (终验 L103 + 周期跑 L147)
- [x] test-writing-type.md (终验 L106 + 周期跑 L155)

## 替换前后行摘录

### bugfix-type.md
- 终验: `- [ ] \`Skill("task-drift-guard")\` 终验` → `- [ ] 派发 \`drift-checker\` 子代理偏移检查（Rule 61 载体）终验`
- 周期跑: `- 每 2-3 个 Phase 完成 → 跑 \`Skill("task-drift-guard")\`` → `- 每 2-3 个 Phase 完成 → 派发 \`drift-checker\` 偏移检查（Rule 61 载体）`

### deployment-type.md
- 终验: `- [ ] \`**主进程** \`Skill("task-drift-guard")\`（子代理无 Skill() 工具）\` 终验` → `- [ ] 派发 \`drift-checker\` 子代理偏移检查（Rule 61 载体）终验`
- 周期跑: `- 每 2-3 个 Phase 完成 → 跑 \`Skill("task-drift-guard")\`` → `- 每 2-3 个 Phase 完成 → 派发 \`drift-checker\` 偏移检查（Rule 61 载体）`

### schema-migration-type.md
- 终验: `- [ ] \`**主进程** \`Skill("task-drift-guard")\`（子代理无 Skill() 工具）\` 终验` → `- [ ] 派发 \`drift-checker\` 子代理偏移检查（Rule 61 载体）终验`
- 周期跑: `- 每 2-3 个 Phase 完成 → 跑 \`Skill("task-drift-guard")\`` → `- 每 2-3 个 Phase 完成 → 派发 \`drift-checker\` 偏移检查（Rule 61 载体）`

### performance-tuning-type.md
- 终验: `- [ ] \`**主进程** \`Skill("task-drift-guard")\`（子代理无 Skill() 工具）\` 终验` → `- [ ] 派发 \`drift-checker\` 子代理偏移检查（Rule 61 载体）终验`
- 周期跑: `- 每 2-3 个 Phase 完成 → 跑 \`Skill("task-drift-guard")\`` → `- 每 2-3 个 Phase 完成 → 派发 \`drift-checker\` 偏移检查（Rule 61 载体）`

### code-edit-type.md
- 终验: `- [ ] 运行 \`**主进程** \`Skill("task-drift-guard")\`（子代理无 Skill() 工具）\` 终验` → `- [ ] 派发 \`drift-checker\` 子代理偏移检查（Rule 61 载体）终验`
- 周期跑: `- 每次 Phase 完成 → 调用 \`Skill("task-drift-guard")\`` → `- 每次 Phase 完成 → 派发 \`drift-checker\` 偏移检查（Rule 61 载体）`

### test-writing-type.md
- 终验: `- [ ] \`**主进程** \`Skill("task-drift-guard")\`（子代理无 Skill() 工具）\` 终验` → `- [ ] 派发 \`drift-checker\` 子代理偏移检查（Rule 61 载体）终验`
- 周期跑: `- 每 2-3 个 Phase 完成 → 跑 \`Skill("task-drift-guard")\`` → `- 每 2-3 个 Phase 完成 → 派发 \`drift-checker\` 偏移检查（Rule 61 载体）`
