# 检查点 07-executor-p4s3（task_plan.md S-unit 表转正）

文件: /mnt/data/dev/task-planner-skill-worktrees/task-v056-fine-grained-dispatch/skills/task-planner/templates/task_plan.md
原始行数(wc -l 修改前): 386

## 里程碑（T1 每次 Edit）
- [x] Edit 1: 删除 Phase 2 后紧跟的 9 行 Subtasks 子表 HTML 注释（原 152-160 行，`<!--`…`-->` 整块），保留其后 `<!-- WHAT: Decide how...` 注释块
- [x] Edit 2: 在 Phase 3 的 `- **Executor:** code-assistant（haiku-1）` 行后插入空行 + S-unit 派发单元表（1 行 HTML 注释 + 表头 + 分隔 + S1 + S2，共 5 行）
- [x] Edit 3: `## Phases` 头注中 Executor 字段行追加 `;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3)`

## 最终结论（T5）
status: success

验收 5 项结果（全部 PASS）:
1. `grep -c "Subtasks 子表"` = 0 ✅（残留 "升级为独立 Phase(Rule 21.1/22.1)" 亦无命中）
2. `grep -n "^| ID | 目标(≤1 句) | 输入(路径 + ≤10 行摘要)"` 命中 1 行 @ 行 174，位于 `### Phase 3: Implementation`(162) 与 `### Phase 4: Testing & Verification`(179) 之间 ✅
3. 表格上方 S-unit 说明注释 @ 行 173：同一行含 `<!--` 与 `-->`（闭合），表格不在注释内 ✅
4. `grep -c "必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3)"` = 1 ✅
5. wc -l: 386 → 383 = 原 − 9 + 6（净 −3）✅

关键行号（修改后）:
- S-unit 说明注释行: 173
- 表头行: 174
- 分隔行: 175
- S1 行: 176
- S2 行: 177

风险排除: 仅改目标 worktree 单文件；未触碰 worktree 外路径；未执行 git 写操作；`<!-- WHAT: Decide` 注释块及 Phase 1/4/5 内容未动。
