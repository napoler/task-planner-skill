# S3 任务书：规则锚同步 A（Rule 106.5 语义锚 + task-planner SKILL 指针）

## 1. 背景
todo 基线组将从 B1-B5 扩为 B1-B8（B6 引擎检测/B7 对齐/B8 worktree 核验，B1-B5 逐字保留）。本单元负责两处"语义面/指针面"规则锚同步（唯一事实源 todo-sync.md 由 S2 另人负责）。

## 2. 目标文件（2 个，绝对路径）
1. /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md — Rule 106.5 段（现第 747-750 行）
2. /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md — 原生 Todo 同步段（现第 256 行）

## 3. 精确改动
**文件 1（Rule 106.5）**：
- 标题行 `106.5 **两组 todo 驱动对齐...` 保持。
- 基线组清单原句尾部（B5 之后）追加：**B6** 引擎适配性检测（建 todo 时判断是否适用 OpenSpec 规格化/Superpowers 方法论技能，结论落盘 Decisions）；**B7** 对齐核查（吸收 task-align 默认项语义）；**B8** worktree 隔离核验（实现类任务强制隔离）。**B1-B5 原文逐字不动**。
- 门禁挂钩行末尾追加："B6 未留痕=不得声称按专业引擎推进；B7 未勾=对齐核查未完成；B8 未勾=实现类不得直接改主树"。
- Why 句可补半句说明 B6-B8 对应引擎激活/对齐/隔离三缺陷，但保持简洁。

**文件 2（SKILL.md:256）**：
- 仅把 `S1 两组结构（任务组+基线组 B1-B5，Rule 106.5）详见 references/todo-sync.md` 中的 `B1-B5` 改为 `B1-B8`，其余逐字不动。
- **BP-08 硬门**：SKILL.md 当前 461 行，上限 470，净增 ≤9 行；本次改动必须 0 净增（只替换字面，不加行）。

## 4. 硬约束
- B1-B5 五条定义原文在两文件均逐字保留；只做追加/字面替换，禁重写整段。
- 用 Edit 精确替换；写后 Read 回读两处锚点（Rule 106.1/106.1a）。
- 不改其它文件；不新增脚本/hook。

## 5. 验收
- `grep -nE 'B1-B8|B6|B7|B8' <file1> <file2>` 命中；B1-B5 原句仍在。
- `wc -l skills/task-planner/SKILL.md` ≤470（应仍 461）。

## 6. 返回契约（8 字段）
status / acceptance / files / evidence（命令+原始输出行）/ checkpoint（写完整记录到 /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S3-rule-anchors.md，目录已存在）/ findings_written / blockers / confidence
