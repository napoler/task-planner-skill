# S2 Checkpoint: todo-sync.md B1-B5 -> B1-B8

## Status
completed

## Files changed
- `/mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md` (lines 35-40 edited via 5 precise Edits)

## Changes made
1. Line 35: "固定五项 B1-B5" -> "固定八项 B1-B8（B1-B5 逐字保留 + B6 引擎检测/B7 对齐/B8 worktree 核验）"
2. Line 36: appended lifecycle semantics for B6/B7/B8 after existing B1-B5 lifecycle sentence and independent-count note.
3. Line 37: appended gate hooks for B6/B7/B8 after existing B1-B4 gate sentence.
4. Line 38: added "含 B6/B7/B8" to S3 rebuild clause.
5. Line 39: changed "B2-B5 随 mini 档既有豁免面" to "B2-B8 随 mini 档既有豁免面（B1 仍不豁免）".
6. Line 40: appended "B6/B7/B8 同步见 Rule 106.5（task-discipline）语义锚".

## Verification evidence
- `grep -nE 'B1-B5|B1-B8|B6|B7|B8' .../todo-sync.md` shows lines 35-40 covering B1-B8 and preserving B1-B5 original sentences.
- `Read` lines 35-49 confirms 6-item structure intact, no anchor swallowed, section 4 follows at line 42.

## Preservation check
- B1-B5 definition text preserved: "B1 持续项（开启即 in_progress，终验翻 complete，判据=progress 全部 [recheck] 行）；B2 每 Phase 翻转前勾检；B3/B4 终验期；B5 收尾。" (present on line 36)
- B1-B4 gate sentence preserved: "B1 未完成留痕=该修改步禁声称完成；B2 未勾=Phase 禁 complete；B3/B4 未勾=禁出 outcome。" (present on line 37)

## Blockers
None.

## Confidence
High - exact Edit-only changes, grep+Read back verified.
