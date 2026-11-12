# CRfix-B Checkpoint (general-coder)

- 任务: 在隔离 worktree 修 CR I-2/I-3/N-4（纯文本微修）
- worktree: `/mnt/data/dev/task-planner-skill-worktrees/docmod-crfix`
- status: done (未 commit)

## 改动
1. `skills/verification-gate/references/critical-rules-verification.md` L56: 替换为「分工边界（↔Rule 106）」行（I-2）
2. `skills/task-planner/SKILL.md` L9, L223: 「其余 88 条」→「其余 89 条」(I-3)
3. `skills/task-planner/SKILL.md` L105: `（106.1）`→`（106.1-106.4）` (N-4)

## 自检
- `grep -c '其余 89 条' skills/task-planner/SKILL.md` => 2
- `grep -c '其余 88 条' skills/task-planner/SKILL.md` => 0
- `grep -n '分工边界' skills/verification-gate/references/critical-rules-verification.md` => 1 match (L56)
- `grep -n '106.1-106.4' skills/task-planner/SKILL.md` => 1 match (L105)

## Diff 范围
仅上述两文件、4 处文本改动，无其他文件变更。
