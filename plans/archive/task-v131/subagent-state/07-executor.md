# 检查点 07-executor — task-v131 Phase 3 S1（critical-rules.md 四处纯增量）

- 执行体: executor | worktree: /home/terry/task-planner-skill-worktrees/task-v131
- 唯一改动文件: skills/task-planner/references/critical-rules.md（574→586 行）
- 状态: 完成，未 commit

## 四处编辑明细
1. **a) 51.1a 插入**（:560）— 位于 51.1 条文行之后、51.2 之前；正文逐字=knowledge-brief §5「51.1 追加子句定稿」整段（载体双机制 ①init 注入 ②attest 三锚门 ③模板区块 + 派发侧锚需求逐字引用禁转译），格式对齐 51.x 既有子条。
2. **b) Rule 53 区块插入**（:580 起，文件末 Rule 编号序）— 标题 `### 53 根源解决与决策管辖（P0, 2026-10-05 task-v131）` 对齐 51/52 格式；53.1-53.5 逐字=§5 定稿（`grep -c "^53\."` = 5 ✓）。
3. **c) Rule 45.7 死路径修正**（:475 条文行 + :476 头注释）— 先 `git log -S "legacy-comment-audit"` 验证该文件从未入库（仅出现在 c627245/60b2333 提交信息文字中，`git log -- "*legacy-comment-audit*"` 无文件历史）；plans/task-v111/ 目录 ls 实存 7 文件（findings/knowledge-brief/notepad-learnings/progress/subagent-state/task_plan/verification），无 legacy-comment-audit.md，progress.md:18 含「存量补强清单...已落 checkpoint」→ 改指 progress.md；条文行 ③ 改为「存量补强清单（登记于 plans/task-v111/progress.md,交用户裁决范围）」，按 45.4 加头注释注明修改原因/时间/原行为。
4. **d) Rule 16 措辞修正**（:75 条文行 + :76 头注释）— 实测 templates/ 现行 39 文件（主 10 + variant 29）中 35 含「## 📚 必要知识储备」，缺 4 = delivery-summary/knowledge-brief/shared-tracker/variant/mini-lite-type（comm 差集核实）；「全部模板标配」→「白名单模板标配（38.3 豁免 4 类不计入）」，验收口径 `= 35` → `= 35/39` 补如实分母，注明豁免 4 类清单；按 45.4 加头注释（含 findings L-2 锚）。

## 验证证据（全部通过）
- `grep -c "^53\." critical-rules.md` = 5（≥5 ✓）
- `grep -n "^51\.1a"` = :560 命中 ✓
- `plans/task-v111/progress.md` 实存（ls 核实，主仓 plans 目录）✓
- `git diff --stat` = 仅 1 文件（14 insertions / 2 deletions，纯增量，既有行仅 45.7 与 Rule 16 两行为条款内措辞修正，无其他语义改动）✓
- `wc -l` = 574 → 586 ✓
- 未 commit（按 SOP 指令）；worktree 外零写入，未触碰其他文件/其他 worktree
