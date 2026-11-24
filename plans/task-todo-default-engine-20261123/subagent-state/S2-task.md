# S2 任务书：todo-sync.md 基线组 B1-B5 → B1-B8（唯一事实源）

## 1. 背景
用户 /goal 缺陷③：OpenSpec/Superpowers 已声明为引擎却从未激活，对齐等默认项是纯文本契约无产出器；用户指定"依赖 todo 引擎推进=最简单方案"、"之前添加的东西不要丢弃"。方案 A=把 todo 基线组从 B1-B5 扩为 B1-B8：B6 引擎适配性检测（OpenSpec/Superpowers）、B7 对齐核查、B8 worktree 核验。**既有 B1-B5 必须逐字保留**（一个字都不许删改），B6/B7/B8 只做叠加。

## 2. 目标文件（绝对路径）
/mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md
段落：S1 两组结构（现有第 35-40 行，1. S1 建立两组… / 2. 生命周期 / 3. 门禁挂钩 / 4. S3 回写协议 / 5. mini 豁免 / 6. 唯一事实源）。

## 3. 精确改动
1. 第 1 条："固定五项 B1-B5" → "固定八项 B1-B8（B1-B5 逐字保留 + B6 引擎检测/B7 对齐/B8 worktree 核验）"，其余措辞不动。
2. 第 2 条生命周期末尾追加："；B6 建 todo 时检测引擎适配性（OpenSpec 规格化/Superpowers 方法论），结论落盘 Decisions；B7 对齐核查（吸收旧 task-align 默认项语义）；B8 实现类任务 worktree 隔离核验"。
3. 第 3 条门禁挂钩追加："B6 未留痕=不得声称按专业引擎推进；B7 未勾=对齐核查未完成；B8 未勾=实现类不得直接改主树"。
4. 第 4 条 S3 回写重建："基线组条目丢失" 明确覆盖 B6/B7/B8（措辞如"含 B6/B7/B8"）。
5. 第 5 条 mini 豁免："B2-B5 随 mini 档既有豁免面" → "B2-B8 随 mini 档既有豁免面（B1 仍不豁免）"。
6. 第 6 条唯一事实源：保持本文件为唯一事实源，补一句"B6/B7/B8 同步见 Rule 106.5（task-discipline）语义锚"。

## 4. 硬约束
- **逐字保留 B1-B5 定义原文**（B1 持续项…B5 收尾；门禁 B1-B4 原句）。用 Edit 精确替换，禁大段重写整节。
- 单文件改动 ≤40 行新增；不改其它任何文件。
- 不使用脚本批量 sed；用 Edit 精确替换。写后 Read 回读验证锚行保留（Rule 106.1/106.1a）。

## 5. 验收
- `grep -nE 'B1-B5|B1-B8|B6|B7|B8' <file>` 显示 8 项齐备且 B1-B5 原句仍在。
- Read 回读第 35-45 行确认六条结构完整、无吞锚。

## 6. 返回契约（8 字段）
status / acceptance / files / evidence（命令+原始输出行）/ checkpoint（写完整记录到 /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S2-todo-sync.md，目录已存在）/ findings_written / blockers / confidence
