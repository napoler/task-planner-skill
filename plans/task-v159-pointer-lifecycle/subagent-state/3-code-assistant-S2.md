
#### [sub: 代码助手-init 单元] checkpoint 2026-10-09
- **status**: done
- **改动**: skills/task-planner/scripts/init-session.sh :796 前插入 F3 init 侧所有权守卫（净 +27/-1）；写 `${SIDE_DIR}/${SIDKEY}.active_plan` 前扫 `plans/*/.session-owner` 找 `sess${SIDKEY}` 声明者；claimant≠当前 basename $PWD 且其 task_plan.md Status=in_progress → SKIP_SIDE_WRITE=1 + WARN「side 键 sid=… 已被在途计划 <claimant> 声明，skip 写入防沿袭互踩」；claimant complete/不存在 → fail-open 正常写（INFO/WARN 行）。sidmap 逻辑（:759-794）零改动。
- **验证（全过）**:
  1. `bash -n` rc=0
  2. 夹具 /tmp/v159-init-guard：task-ownertest(.session-owner=sessclaimkey2, Status=in_progress) + task-new2 跑 init(sid=sessclaimkey2) → 输出 `[init] WARN: side 键 sid=claimkey2 已被在途计划 task-ownertest 声明，skip 写入防沿袭互踩`，且 `.active_plan_side/` 为空（claimkey2 键未落），init 其余流程完成（6/6 文件 + "Planning files initialized!"）
  3. 夹具 /tmp/v159-init-guard2：claimant Status=complete → `[init] INFO: …fail-open 继续写入` + `active_plan side 指针已指向: task-new2(sid=claimkey2)`，指针文件内容=task-new2
  4. 夹具 /tmp/v159-init-guard3：无 claimant → 正常写指针（fail-open 基线不回归）
  5. `git diff --stat master -- scripts/init-session.sh` = 仅该文件（27+/1-）；worktree 内 set-active-plan.sh 的 M 状态来自并行单元，非本单元写入
- **净改动行数**: +27/-1（28 行 diff stat）
- **open_issues**: none
