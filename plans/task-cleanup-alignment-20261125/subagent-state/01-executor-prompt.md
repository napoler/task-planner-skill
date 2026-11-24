# S-unit 01 — 收尾对齐与清理机制（三段）实施任务包

## 0. 唯一允许写入路径
`/mnt/data/dev/task-planner-skill/tmp/worktrees/task-cleanup-alignment-20261125`（分支 `wt/task-cleanup-alignment-20261125`）。
禁止写主仓根目录、其他 worktree、部署位（`~/.zcode/skills`、`~/.agents/skills` 等）。
例外：验收最后一条 `planctl render` 会写主仓计划目录的派生视图（预期行为，需报告）。

## 1. 背景
用户投诉 task-planner 技能文件堆满无价值历史注释与过期口径。设计已批准（方案 A）：在 todo 与 task 模板建立"任务完成后对齐+清理"的纯文本条款机制。设计文档：`/mnt/data/dev/task-planner-skill/docs/superpowers/specs/2026-11-25-task-cleanup-alignment-design.md`（可读，但本任务不修改它）。

## 2. 铁律（反屎山示范 — 违反即失败）
新增的任何条款/注释**禁止带 task-id、日期戳、"本次改了什么/原行为/判例=用户原话"等修改痕迹**，只写规则语义（做什么、判据、边界）。现有文件的历史注释也不要顺手删——本次不批量清存量，只建机制。

## 3. 三段改动

### P1 — `skills/task-planner/references/todo-sync.md`
1. 第 31 行 S4：在"前置=Rule 84.14 收尾回读梳理迭代已完成"之后追加前置：B17/B18 收尾对齐与清理已完成。
2. 第 35 行 S1 基线组（B1-B16 描述）末尾追加两项（每项 1-2 句，简洁）：
   - **B17 口径对齐**：交付前拉平本任务触及的过期计数/冲突条款；判据=冲突锚 grep 无本任务新增命中；证据落 progress `[align-final]` 行。
   - **B18 垃圾清理**：删除本任务新增的无价值历史注释；保留描述字段语义/消费方/脚本锚点的高价值契约注；含守卫盲区事实的判例注归档 forensics 不直删；证据落 progress `[cleanup-final]` 行。
   - 说明：列表位置在 B16 之后（最后两步），执行时机在 outcome 判定前、B16 合并回之前（清理改动须先落盘提交才能合并）。

### P2 — `skills/task-planner/templates/task_plan.md` + `skills/task-planner/scripts/planctl.py`
1. 模板：在 `## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）` 区块之后新增独立板块：
```
## 🧹 收尾对齐与清理（交付前必填）
| 类别 | 检查项 | 判据 | 证据 |
|---|---|---|---|
| 对齐 | 口径计数 / 冲突条款 / 行数快照 | 冲突锚 grep 无本任务新增命中 | progress `[align-final]` 行 |
| 清理 | 历史注释 / 过期注 / 残留物 | 本任务新增痕迹注为 0 | progress `[cleanup-final]` 行 |

执行时机：outcome 判定之前、合并回动作之前；mini / L0-lite 档豁免本板块。
```
2. `planctl.py` 的 `_render_task_plan`（约 :1506 起，重建式渲染）：在"收尾回读梳理记录"相关输出之后同步输出上述板块。mini / L0-lite 档不输出（与现有 mini-lite 白名单一致），standard/full 输出。用现有 `_md_table` 辅助函数，风格与周边一致；注释只写 What+Why 语义（不写日期/task-id）。

### P3 — `skills/task-planner/SKILL.md`
在终验智能子动作段（`## [A] 终验交付 — 智能子动作` 内，约 :139-147，Rule 84.14 回读条目之后）新增一行指针：
- **收尾对齐与清理**：交付前按 task_plan 模板「🧹 收尾对齐与清理」板块执行——①对齐口径 ②清理本任务新增无价值注释（保留契约注，判例归档 forensics）；执行在 outcome 判定与合并回之前；证据落 progress `[align-final]`/`[cleanup-final]` 行；mini/L0-lite 档豁免。
（同样不带 task-id/日期戳。）

## 4. 验收（逐条执行，报告真实输出）
```
grep -nE 'B17|B18' skills/task-planner/references/todo-sync.md
grep -nF '收尾对齐与清理' skills/task-planner/templates/task_plan.md skills/task-planner/SKILL.md
python3 -m py_compile skills/task-planner/scripts/planctl.py
bash -n skills/task-planner/scripts/*.sh
python3 skills/task-planner/scripts/planctl.py render --plan-dir /mnt/data/dev/task-planner-skill/plans/task-cleanup-alignment-20261125 >/dev/null && grep -nF '收尾对齐与清理' /mnt/data/dev/task-planner-skill/plans/task-cleanup-alignment-20261125/task_plan.md
```
selftest 与 verify 由主进程稍后统一跑，你不跑。

## 5. 检查点落盘纪律
检查点文件已指定（见派发 prompt 的 checkpoint 字段）。每完成一个文件的 Edit → 追加带时间戳里程碑行；遇错写「错误与受阻」段；结束写「最终结论」段（= 8 字段返回块），置 status: done。

## 6. 返回
严格 8 字段（见派发 prompt §7），字段后不得有任何内容。
