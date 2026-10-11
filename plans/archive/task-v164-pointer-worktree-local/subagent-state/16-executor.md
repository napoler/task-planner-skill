# 16-executor checkpoint — S16 瞬态适配守卫修复

## 最终结论
status: done
acceptance: 4/4 pass — (1) 改为存在性守卫 `_cp_active_ptr=""; [ -f "$PLAN_DIR_GUESS/../.active_plan" ] && _cp_active_ptr="$(...)"`，下方 `if [ -n ... ]` 未动 [check-complete.sh:1376]; (2) `bash -n skills/task-planner/scripts/check-complete.sh` → `rc=0`; (3) /tmp 夹具实测：OLD 变体漏 `/bin/bash: line 9: .../.active_plan: No such file or directory`，NEW 变体 stderr 为空且 fail-open（ptr 空），CASE B(ptr=task-foo) warn FIRED / CASE C(ptr=other-task) silent [夹具 /tmp/v164-fix-test.*, 已清理]; (4) `git diff` 仅 check-complete.sh 一文件 +2/-1（该行+一行 Rule 45 注释）
files: /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/skills/task-planner/scripts/check-complete.sh (+2/-1)
evidence: check-complete.sh:1375(旧)→1376(新); bash -n→rc=0; /tmp 夹具→OLD 漏行/NEW 无漏行; git diff --stat→check-complete.sh | 3 ++-
checkpoint: /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/plans/task-v164-pointer-worktree-local/subagent-state/16-executor.md (status: done)
findings_written: #### [sub:16-executor] S16 瞬态适配守卫修复
blockers: none
confidence: HIGH

## 备注（非返回字段）
- git diff 另见 `plans/.../subagent-state/.dispatch-inflight` 变更（时间戳），系派发机制簿记，非本单元编辑，按 Scope 禁改清单未触碰。
- 真实 plans/ 与真实 .active_plan 未做任何改动；夹具全程在 /tmp。
