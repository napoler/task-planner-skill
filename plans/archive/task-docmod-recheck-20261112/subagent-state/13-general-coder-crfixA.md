# Checkpoint: 13-general-coder-crfixA (CRfix-A)

- **timestamp:** 2026-11-13
- **worktree:** /mnt/data/dev/task-planner-skill-worktrees/docmod-crfix
- **status:** complete
- **task:** CRfix-A — todo-sync.md (W-1/I-1) + critical-rules-discipline.md (N-1/N-2)

## Changes
1. `skills/task-planner/references/todo-sync.md`
   - W-1: Moved "S1 两组结构..." block (6-item list, verbatim) from between S1 row and S2 row to after S5 row (after full S1-S5 table), restoring single contiguous 5-row table.
   - I-1: Appended to block item 2 (lifecycle) exactly: `；基线组独立计数：B1 持续 in_progress 不受「同时只允许一条 in_progress」约束（该唯一性约束限任务组/Phase 映射条目）`
2. `skills/task-discipline/references/critical-rules-discipline.md`
   - N-1/N-2: Replaced L721 heading with: `### 106 文档修改复检与 todo 驱动对齐纪律（P0 — task-docmod-recheck-20261112，2026-11-13；判例=sess_1378b365「G22-05a 三方时间口径不一致仍放行」）`

## Self-check
- `grep -n '两组结构' skills/task-planner/references/todo-sync.md` → `34:**S1 两组结构...**` (S5 table row is at 32, so block is after table ✓)
- `grep -n '独立计数' skills/task-planner/references/todo-sync.md` → `36:...；基线组独立计数：B1 持续 in_progress 不受「同时只允许一条 in_progress」约束（该唯一性约束限任务组/Phase 映射条目）` (1 hit ✓)
- `grep -n '^### 106 ' skills/task-discipline/references/critical-rules-discipline.md` → `721:### 106 文档修改复检与 todo 驱动对齐纪律（P0 — task-docmod-recheck-20261112，2026-11-13；判例=sess_1378b365「G22-05a 三方时间口径不一致仍放行」）` ✓

## Diff scope (target files)
- Only the two target files have intended edits; `git diff` on them shows only the requested textual changes (table merge + appended clause + title replacement). No other content modified in these files.

## Notes/Risks
- `git diff --name-only` in worktree also lists `skills/task-planner/SKILL.md` and `skills/verification-gate/references/critical-rules-verification.md` as modified; these were pre-existing in worktree state and were not touched by this task.
- No commit performed (as required).
