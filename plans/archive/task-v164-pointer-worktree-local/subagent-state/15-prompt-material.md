# S11-r2 合并后态回归材料（code-runner-agent，2026-10-10）

## 任务
对 merge master 后的最终待合并态（merge commit 40a72f7 之后 HEAD）重跑 selftest-*.sh 全集（72 个），逐脚本真实 rc 与 Total 行落 regression-worktree-merged.log。

## 执行命令（worktree 内）
```
cd /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local
PLAN=plans/task-v164-pointer-worktree-local
: > $PLAN/regression-worktree-merged.log
for f in skills/task-planner/scripts/selftest-*.sh; do
  out="$(bash "$f" 2>&1)"; rc=$?
  { echo "=== $(basename "$f") rc=$rc"; printf '%s\n' "$out" | grep -E 'Total|PASS|FAIL|OK:' | tail -4; } >> $PLAN/regression-worktree-merged.log
done
```
- rc 取 bash 真实退出码；单条 bash timeout=600000；只跑批+落盘，禁单脚本反复深验（主进程复核职责）

## 对照口径
- 基线 baseline-selftest.log（71 段 rc=0）+ S11 regression-worktree.log（72 段 rc=0）
- 期望：合并后态仍 72 段 rc=0、零 FAIL（合并引入 26 提交并集，其中 v156 Rule 72/73 相关 selftest 必须仍绿）

## 验收
- log 含 72 个 `=== selftest-*.sh rc=` 段；rc≠0 段逐一列名（空集明示）
- checkpoint 记时间戳与段数

## 边界
- 只写 regression-worktree-merged.log；禁 git 写操作；禁改其他文件
