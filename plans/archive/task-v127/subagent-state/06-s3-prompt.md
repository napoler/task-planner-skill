# task-v127/S3 任务书 — 2 媒体模板评级契约区块 [parallel-group:impl-wave1]

## 1. 目标
在 **worktree** 给 2 个媒体 variant 模板各追加「📐 评级契约（Rule 50）」区块（纯增量，位置=VC 表之后/Phases 之前）：内容=原子验收条目表（|条目|类型 P/E|层级 H/S|权重|判定刻度|）+ 逐条评级（PASS/PARTIAL/FAIL，程度条目双向判）+ 加权判定一句（全 H 过 + S 加权≥阈值）。本会话只执行本 S-unit。

## 2. 输入(计划三文件,绝对路径 — Rule 22.4a)
- 任务书:本文件
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md — 只读（§Rule 50 设计契约=区块文本基线，含泪痣样例表）
- findings/progress/knowledge-brief: 同上目录 — 只读
- 目标文件（**只改 worktree 内这两件**）: /mnt/data/dev/task-planner-skill-worktrees/task-v127/skills/task-planner/templates/variant/image-type.md 与 .../templates/variant/character-design-type.md
## 3. 验收标准(4 条)
- [ ] 两文件各含「评级契约」区块标题（grep '评级契约' 各 ≥1）且含锚词：`原子验收条目`/`逐条评级`/`双向`
- [ ] 区块含条目表 5 列头（条目/类型/层级/权重/判定刻度）+ 程度条目双向判一句 + 加权判定一句
- [ ] 两文件既有内容零改动（git diff 仅追加行，0 删除）；区块位置在既有 VC/验收区之后、Phases 标题之前
- [ ] `git -C <worktree> diff --stat` 仅这两文件变更
## 4. Scope 禁改清单
- 禁改 worktree 内其他文件（含 qc-defect-type.md——另一并行任务的文件，勿碰）；主仓 plans/ 只读；禁 git add/commit；禁碰其他 worktree
## 5. 工作路径
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v127；不切换 CWD
## 6. 时长预算
- executor → 15 分钟；超时返回 partial
## 7. 返回格式(严格 8 字段，之后不得有任何内容)
status: done | partial | failed | timeout
acceptance: <n>/4 pass — [1:PASS ...]
files: <两绝对路径>(+N/-M 各)
evidence: <grep 锚行 + git diff --stat>
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/06-s3-executor.md (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
## 8. checkpoint 落盘路径(强制)
- /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/06-s3-executor.md；T5 必写「最终结论」段=第 7 节同一 8 字段块
## 9. 上下文预算
- 只 Read §2 列出文件；两模板各读骨架（前 60 行+VC 区段 grep 定位），禁全文通读
