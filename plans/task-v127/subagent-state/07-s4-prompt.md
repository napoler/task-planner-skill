# task-v127/S4 任务书 — qc-defect 模板 + goal-gate 分级语义 [parallel-group:impl-wave1]

## 1. 目标
在 **worktree**：① templates/variant/qc-defect-type.md 追加「📐 评级契约（Rule 50）」区块（形态：原子验收条目表+逐条评级+程度双向判+加权判定，文本基线=task_plan §Rule 50 设计契约与泪痣样例）；② references/goal-gate.md 在退出标准（COMPLETE/PARTIAL/BLOCKED）段后纯增量 1 行 VC 分级语义：内容任务可按 Rule 50 原子验收条目表做分级/加权评级（PASS/PARTIAL/FAIL 逐条 + 加权总分），作为二元三态之上的细化形态，不改变既有三态语义与五条 VC 规则。本会话只执行本 S-unit。

## 2. 输入(计划三文件,绝对路径 — Rule 22.4a)
- 任务书:本文件
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md — 只读（§Rule 50 设计契约）
- findings/progress/knowledge-brief: 同上目录 — 只读
- 目标文件（**只改 worktree 内这两件**）: /mnt/data/dev/task-planner-skill-worktrees/task-v127/skills/task-planner/templates/variant/qc-defect-type.md 与 .../skills/task-planner/references/goal-gate.md（全文仅 17 行）
## 3. 验收标准(4 条)
- [ ] qc-defect-type.md 含「评级契约」区块（grep '评级契约'|'原子验收条目'|'双向' 各 ≥1），位置在既有 VC/验收区之后、Phases 之前
- [ ] goal-gate.md 新增 1 行含「分级」与「Rule 50」字样，位置在退出标准段之后
- [ ] 两文件既有内容零改动（git diff 仅追加行）；goal-gate 既有五条 VC 规则与三态原文零变化
- [ ] `git -C <worktree> diff --stat` 仅这两文件变更
## 4. Scope 禁改清单
- 禁改 worktree 内其他文件（含 image-type.md / character-design-type.md——另一并行任务的文件，勿碰）；主仓 plans/ 只读；禁 git add/commit；禁碰其他 worktree
## 5. 工作路径
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v127；不切换 CWD
## 6. 时长预算
- executor → 12 分钟；超时返回 partial
## 7. 返回格式(严格 8 字段，之后不得有任何内容)
status: done | partial | failed | timeout
acceptance: <n>/4 pass — [1:PASS ...]
files: <两绝对路径>(+N/-M 各)
evidence: <grep 锚行 + git diff --stat>
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/07-s4-executor.md (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
## 8. checkpoint 落盘路径(强制)
- /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/07-s4-executor.md；T5 必写「最终结论」段=第 7 节同一 8 字段块
## 9. 上下文预算
- 只 Read §2 列出文件；qc-defect-type.md 读骨架+VC 区段 grep 定位；goal-gate.md 全文 17 行可全读
