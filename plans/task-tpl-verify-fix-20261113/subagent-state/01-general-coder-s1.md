# Checkpoint: 01-general-coder-s1 (CA-1~CA-4)

- **timestamp**: 2026-11-13T02:35:00+08:00
- **task**: S1 — 修正 skills/task-planner/templates/task_plan.md 四处漂移（CA-1~CA-4）
- **worktree**: /mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113
- **target**: skills/task-planner/templates/task_plan.md（仅此一文件，未 commit）

## 四锚前后行号

| 锚点 | 前（基于首读） | 后（自检定位） | 变更摘要 |
|------|----------------|----------------|----------|
| CA-1 S-unit 表 11→10 列 + 注释替换 + 示例加 (A6)/(A7) | 注释 338；表头 340；分隔 341；S1 342；S2 343（含「96 类别」列） | 注释 338；表头 340；分隔 341；S1 342；S2 343（10 列，目标列前缀示范） | 删「96 类别」独立列；注释整行替换为 findings §3.1 口径；示例行改 10 列 |
| CA-2 Goal 列名补空格 | 143、146（`对应S-unit/Phase`） | 143、146（`对应 S-unit/Phase`） | replace_all 仅补空格 |
| CA-3 Phase 4 示例补最小 S-unit 表 | 无（Phase 4 结束后直接 Phase 5，原约 355-357 区间） | 357（注释）+358-360（表头/分隔/示例行）插入于 Executor 行后、Phase 5 前 | 新增 10 列最小表示例+判例注释 |
| CA-4 Batch Report 引导 | 注释块 486-491；字段值 494-501 为空 | 注释追加 496（`留空会被 check-complete 18.6 门拦（判例同上）`）；字段值 500-507 填 `n/a（...）` 引导 | 8 字段全填引导形态 + 注释追加 |

## 自检输出（原文）

```
==96 类别 count==
0
==对应 S-unit/Phase==
143:  列契约（66.1 六列）: goal-id(G1..) | 任务名(≤8字) | 目标(≤1句) | 完整验证方式(命令+判据/路径+关键行/diff形态,三选一必具其一) | 对应 S-unit/Phase | 状态(pending/complete)
146:| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
==| ID |==
340:| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
358:| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
==n/a count==
10
==git diff stat==
 skills/task-planner/templates/task_plan.md | 34 ++++++++++++++++++------------
 1 file changed, 20 insertions(+), 14 deletions(-)
```

## 自审（≤5 行）

- CA-1/CA-3 表头与 check-plan-dispatch.sh 10 列序一致（ID/目标/执行体/输入/验收/预估时长/粒度/伴飞/前置/状态），无「96 类别」独立列；示例目标列含 (A6)/(A7) 前缀。
- CA-2 仅补空格，CA-4 8 字段均为 `n/a（...）` 引导且注释追加判例行。
- `{{VAR}}` 占位符/渲染契约注释未触碰（grep '{{' 仍命中首部契约行与 worktree_path/branch 等）；diff 仅 `skills/task-planner/templates/task_plan.md`。
- 未改 verification.md/其他文件，未 commit；范围符合任务约束。
- 风险：Phase 4 示例 S-unit 为最小占位（继承/空字段），供模板示范用，实际计划期仍需按 Rule 22.6 填实。
