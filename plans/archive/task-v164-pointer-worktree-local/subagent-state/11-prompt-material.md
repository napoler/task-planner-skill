# S11 回归跑批材料（code-runner-agent，2026-10-10）

## 任务
在 v164 worktree（变更后态：S2-S10+锁步全落地）对 selftest-*.sh **全集（72 个）**跑回归，逐脚本真实 rc 与 Total 行落 regression-worktree.log。

## 执行命令（worktree 内）
```
cd /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local
PLAN=plans/task-v164-pointer-worktree-local
: > $PLAN/regression-worktree.log
for f in skills/task-planner/scripts/selftest-*.sh; do
  out="$(bash "$f" 2>&1)"; rc=$?
  { echo "=== $(basename "$f") rc=$rc"; printf '%s\n' "$out" | grep -E 'Total|PASS|FAIL|OK:' | tail -4; } >> $PLAN/regression-worktree.log
done
```
- rc 取 `bash "$f"` 真实退出码（禁管道后取 tail 的 rc）
- 单条 bash 设 timeout=600000；**只跑批+落盘，禁对单个脚本做反复复跑/深验证**（那是主进程的复核动作，你只负责原文落盘）

## 对照口径（主进程求和用）
- 基线 plans/task-v164-pointer-worktree-local/baseline-selftest.log：71 段全 rc=0（2026-10-10 12:xx，master FF 前分支点态）
- 本次 72 个（master FF 新增 selftest-decision-grading.sh）：期望 71 个共同脚本 rc=0 不变 + decision-grading rc=0
- 判读=主进程职责；你的验收只保证 log 完整真实

## 验收
- log 含 72 个 `=== selftest-*.sh rc=` 段；rc≠0 段逐一列出脚本名
- checkpoint 记录开始/结束时间戳与段数

## 边界
- 只写 regression-worktree.log；禁 git 写操作；禁改 worktree 任何文件
