# task-v127/S2 任务书 — SKILL.md 联动 [parallel-group:impl-wave1]

## 1. 目标
在 **worktree** 的 SKILL.md 做三处联动（净增 ≤10 行，行位替换优先）：① frontmatter 索引字面 1-49→1-50（枚举括注补「50 内容要求权重分级与评级」）；② 摘要区（Critical Rules 列举行/Rule 索引处）补 Rule 50 bullet；③ 媒体路由行（:356 一带「媒体生成工序」行）行内追加消费点「+评级契约（Rule 50）」。本会话只执行本 S-unit。

## 2. 输入(计划三文件,绝对路径 — Rule 22.4a)
- 任务书:本文件
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md — 只读（§Rule 50 设计契约 + §执行范围限制 SKILL 行）
- findings/progress: /mnt/data/dev/task-planner-skill/plans/task-v127/{findings,progress}.md — 只读
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v127/knowledge-brief.md §4（易错点）
- 目标文件: /mnt/data/dev/task-planner-skill-worktrees/task-v127/skills/task-planner/SKILL.md（**只改 worktree 内此文件**）
- 锚现状（worktree 基线）: :9 =「Critical Rules 全集 1-49（…49 单元线多路并行推进…）」；:247/:306 一带「Rules 1-39」字面是计数锚**禁动**；:356-357 媒体路由两行；摘要区 Rule 47/48/49 bullet 形态参照追加 Rule 50 行
## 3. 验收标准(4 条)
- [ ] grep '1-50' 命中 frontmatter 索引行（1-49→1-50 替换+括注补 50 条目名）；grep 'Rule 50\|50 内容要求权重分级' 摘要/索引处 ≥1 新增 bullet
- [ ] 媒体路由行含「评级契约」或「Rule 50」消费点字样（行内追加，不新增行也行）
- [ ] `wc -l` 净增 ≤10 行（记录前后行数入 evidence）；「Rules 1-39」字面（:247/:306）零变化
- [ ] `git -C <worktree> diff --stat` 仅 SKILL.md 一个文件变更
## 4. Scope 禁改清单
- 禁改 worktree 内其他文件；主仓 plans/ 三文件只读；禁 git add/commit；禁碰其他 worktree
## 5. 工作路径
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v127；不切换 CWD
## 6. 时长预算
- executor → 15 分钟；超时返回 partial
## 7. 返回格式(严格 8 字段，之后不得有任何内容)
status: done | partial | failed | timeout
acceptance: <n>/4 pass — [1:PASS ...]
files: <绝对路径>(+N/-M)
evidence: <grep 行 + wc -l 前后值 + git diff --stat>
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/05-s2-executor.md (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
## 8. checkpoint 落盘路径(强制)
- /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/05-s2-executor.md；T5 必写「最终结论」段=第 7 节同一 8 字段块
## 9. 上下文预算
- 只 Read §2 列出文件；SKILL.md 用 grep 定位锚行后 Read 局部（:1-15 frontmatter、:240-320 摘要区、:350-365 路由行），禁全文通读
