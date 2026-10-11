# S1 任务书：critical-rules.md 追加 Rule 49 条款块（task-v126 Phase 2）

你是 task-v126 计划的 S-unit S1 执行体。任务：向 critical-rules.md 文件末尾追加 Rule 49 条款块（纯追加，零改动既有行）。

## 背景与路径
- 本任务在 git worktree 隔离区开发，**目标文件绝对路径**：/home/terry/task-planner-skill-worktrees/task-v126/skills/task-planner/references/critical-rules.md（当前 504 行，文件末尾是「### 48 交付总结可定位性与实用性」块，Rule 49 追加在其后=文件末尾）
- **禁止触碰** worktree 外任何文件、禁止修改目标文件既有行（git diff 必须显示纯追加）
- 计划三文件（只读，按需 Read 相关段不通读）：
  - /mnt/data/dev/task-planner-skill/plans/task-v126/task_plan.md（Goal/VC/S-unit 表）
  - /mnt/data/dev/task-planner-skill/plans/task-v126/findings.md（锚位与设计决策）
  - /mnt/data/dev/task-planner-skill/plans/task-v126/progress.md（Phase 1 基线）
- 你的检查点文件（每完成一个里程碑立即落盘，防中断丢失）：/mnt/data/dev/task-planner-skill/plans/task-v126/subagent-state/1-executor.md

## 追加内容
按草案文件逐字落盘：/mnt/data/dev/task-planner-skill/plans/task-v126/rule49-draft.md（Read 后取「### 49」标题起全部正文追加到目标文件末尾，含块首空行；允许明显笔误修正，不允许语义改动；禁改目标文件既有行）

## 验收自查（执行后必须跑并贴输出）
- grep -c '^49\.[1-5]' 目标文件 应=5
- cd worktree 后 git diff --stat 应仅 critical-rules.md 一文件纯追加（git diff 无删除行）
- 结果写入检查点文件 1-executor.md

## 返回格式（8 字段严格模板）
status: done|partial|failed
summary: 一句话产出
files_changed: 绝对路径清单
acceptance: 验收自查命令与结果
evidence: 关键输出原文粘贴
issues: 无或问题清单
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v126/subagent-state/1-executor.md
next: 建议下一步
