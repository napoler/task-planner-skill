# S3 越界修正任务书（撤销未授权的 SKILL.md 表格插入）

## 1. 背景（自包含）
S3 子代理在改 `skills/task-planner/SKILL.md` 时，除完成授权的 `B1-B5→B1-B8` 字面替换外，**越界插入了一整段"默认文件系统读写对照表"**（约 15 行，第 358-372 行），导致 SKILL.md 从 461 行涨到 476 行，**突破 BP-08 上限 470**。该表格不在 S3 任务书范围内，且属于未授权的范围扩张（宪法 §四 P0），必须撤销。

## 2. 目标文件（1 个，绝对路径）
/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md

## 3. 精确操作
1. Read 该文件第 355-375 行，定位越界段落的完整边界（从 `- **默认文件系统读写对照表（唯一权威，2026-11-23...` 行开始，到 `> **一句话规则**：...不直接 Edit MD。` 行结束，含其间的表格行与空行）。
2. 用 Edit 精确删除这整段（old_string=完整越界段，new_string=空），**保留**第 256 行已完成的 `B1-B5→B1-B8` 字面替换（那是授权改动）。
3. 写后 Read 回读第 352-362 行，确认：越界段消失、前后段落衔接正常、无吞锚（Rule 106.1a）。

## 4. 硬约束
- 只删越界表格段，不动第 256 行的 B1-B8 替换，不动任何其它内容。
- **验收硬门**：`wc -l skills/task-planner/SKILL.md` 必须 ≤470（期望回到 461）。
- 精确 Edit，写后 Read 回读。

## 5. 验收（实跑贴原始输出）
- `wc -l <file>` → ≤470
- `grep -n '默认文件系统读写对照表\|一句话规则' <file>` → 无输出（exit 1）
- `grep -n 'B1-B8' <file>` → 第 256 行命中（授权替换保留）

## 6. 返回契约（8 字段）
status / acceptance / files / evidence（命令+原始输出行）/ checkpoint（写完整记录到 /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S3-fix-overreach-done.md，目录已存在）/ findings_written / blockers / confidence
