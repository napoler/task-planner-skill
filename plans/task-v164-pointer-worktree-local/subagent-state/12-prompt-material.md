# S12 双树行为验证材料（code-runner-agent，2026-10-10）

## 任务
按主进程给定命令原文执行 VC-2 行为验证：①B 树写全局指针后 A 树不受影响（互不感知）②同 sid 双树解析各自正确 ③新树（无全局指针）side→mtime 链正常。**只跑命令+落盘输出，禁改业务文件**。

## 执行命令（worktree 内按序）
```
WT=/mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local
OUT=plans/task-v164-pointer-worktree-local/behavior-verification.log
: > $OUT
# ── B 树（本分支 tip=瞬态化后态）──
git -C $WT worktree add --detach /tmp/v164-btree HEAD >>$OUT 2>&1
bash $WT/skills/task-planner/scripts/set-active-plan.sh task-v160-decision-grading /tmp/v164-btree >>$OUT 2>&1
echo "B全局=$(cat /tmp/v164-btree/plans/.active_plan)" >>$OUT
echo "A全局=$(cat $WT/plans/.active_plan)" >>$OUT
git -C /tmp/v164-btree status --short --untracked-files=all | grep -F 'plans/.active_plan' >>$OUT 2>&1 && echo "B-status=HAS-ENTRY(FAIL)" >>$OUT || echo "B-status=NO-ENTRY(PASS)" >>$OUT
# ── 解析隔离（同 sid 双树）──
echo "resolveB=$(bash $WT/skills/task-planner/scripts/resolve-plan-dir.sh /tmp/v164-btree sid-x)" >>$OUT
echo "resolveA=$(bash $WT/skills/task-planner/scripts/resolve-plan-dir.sh $WT sid-x)" >>$OUT
# ── C 树（无全局指针的新树）──
git -C $WT worktree add --detach /tmp/v164-ctree HEAD >>$OUT 2>&1
ls /tmp/v164-ctree/plans/.active_plan >>$OUT 2>&1 || echo "C全局=不存在(预期)" >>$OUT
echo "resolveC-noside=$(bash $WT/skills/task-planner/scripts/resolve-plan-dir.sh /tmp/v164-ctree sid-y)" >>$OUT; echo "C-noside-rc=$?" >>$OUT
bash $WT/skills/task-planner/scripts/set-active-plan.sh set task-v164-pointer-worktree-local --sid sid-y /tmp/v164-ctree >>$OUT 2>&1
echo "resolveC-side=$(bash $WT/skills/task-planner/scripts/resolve-plan-dir.sh /tmp/v164-ctree sid-y)" >>$OUT
# ── 清理 ──
git -C $WT worktree remove --force /tmp/v164-btree >>$OUT 2>&1
git -C $WT worktree remove --force /tmp/v164-ctree >>$OUT 2>&1
git -C $WT worktree list >>$OUT 2>&1
```

## 期望判读（主进程据 log 复核，你只保证原文落盘）
- B全局=task-v160-decision-grading 且 A全局=task-v164-pointer-worktree-local（A 不受 B 写入影响）
- B-status=NO-ENTRY(PASS)（瞬态文件不入 git status）
- resolveB 含 task-v160-decision-grading/task_plan.md；resolveA 含 task-v164-pointer-worktree-local/task_plan.md
- C全局=不存在；resolveC-noside exit 0 且输出合法 task_plan.md 路径（mtime 兜底）；resolveC-side 含 task-v164-pointer-worktree-local
- 清理后 `git worktree list` 无 /tmp/v164- 残留

## 验收
- behavior-verification.log 存在且含全部上述输出行
- 两个临时 worktree 已清理（worktree list 无残留）
- 主 worktree `git status --short` 无新增非预期条目（除 log 文件本身）

## 边界
- 只写 behavior-verification.log；禁 git add/commit；禁改业务文件；临时 worktree 仅 /tmp/v164-btree、/tmp/v164-ctree 两个且必须清理
