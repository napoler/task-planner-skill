# 02-general-coder-s2 — verification 模板补「验证区块」结构行

- 时间戳: 2026-11-12T18:28:56+00:00
- 任务: S2（CA-5）在隔离 worktree 为 verification 模板补 Verify command 结构行
- 作用域: 仅 `skills/task-planner/templates/verification.md`

## 变更摘要
1. VC-1..VC-5：每条改为三行结构（判定标准+Evidence+`**Verify command**`），Evidence 统一为 `[file path / command output]`，新增逐字 Verify command 引导行（含禁占位/禁真空/引用产出物/退出码判据）。
2. VC 区块注释追加：`每条 VC 的 **Verify command** 行=attest vc-gate（attest-plan.sh:244-285）判据面——模板必须预置该行（缺失验证区块判例 task-tpl-verify-fix-20261113）。`
3. Phase Gates：Phase 1 的 V-1.1/V-1.2、Phase 2 的 V-2.1/V-2.2 各追加 `  **Verify command**: <命令>` 示例行。

## 自检
- `grep -c 'Verify command' skills/task-planner/templates/verification.md` = 10 (≥7，含 5 VC + 4 Phase 示例 + 注释提及计数)
- `grep -c '禁占位' skills/task-planner/templates/verification.md` = 5 (≥1)
- `git diff --stat -- skills/task-planner/templates/verification.md` = `1 file changed, 16 insertions(+), 6 deletions(-)`

## 风险/备注
- 未触碰 {{VAR}} 与渲染契约注释；未改动其他文件；未 commit（按要求）。
- 仅修改模板示范/引导行，不影响现有已填充计划文件。
