# S8 任务书：task-discipline SKILL 索引 B1-B5 → B1-B8

## 1. 背景
todo 基线组从 B1-B5 扩为 B1-B8（B6 引擎检测/B7 对齐/B8 worktree 核验，B1-B5 逐字保留）。本单元是 Rule 106 索引位的最后一处同步（S2=唯一事实源 todo-sync.md、S3=Rule 106.5 语义锚+task-planner SKILL 指针，已另派）。

## 2. 目标文件（1 个，绝对路径）
/mnt/data/dev/task-planner-skill/skills/task-discipline/SKILL.md — Rule 索引表第 106 行（现第 86 行）：
`| 106 | 文档修改复检与 todo 驱动对齐纪律（写后回读/派生值基准/同文件二次回归/交付物本体验证/两组 todo B1-B5）· task-docmod-recheck-20261112 | ... |`

## 3. 精确改动
- 把索引行里的 `两组 todo B1-B5` 改为 `两组 todo B1-B8（B6 引擎检测/B7 对齐/B8 worktree 核验）`，其余逐字不动。
- 若文末"本索引现共 54 条全文可消费"等计数句不因本次改动变化（只是描述文字改了，条数没变），则不动计数。

## 4. 硬约束
- 只改这一行的字面描述，不重写整表、不改其它文件、不新增脚本。
- 用 Edit 精确替换；写后 Read 回读第 86 行附近确认无吞锚（Rule 106.1a）。

## 5. 验收
- `grep -n 'B1-B8' <file>` 命中；B1-B5 原描述不再单独出现在 106 行（但 Rule 106.5 正文的 B1-B5 是 S3 管的，不在本文件）。

## 6. 返回契约（8 字段）
status / acceptance / files / evidence（命令+原始输出行）/ checkpoint（写完整记录到 /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S8-discipline-index.md，目录已存在）/ findings_written / blockers / confidence
