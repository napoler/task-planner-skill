# S1 基线跑批材料（code-runner-agent，2026-10-10）

## 执行命令（在 worktree 内按序执行；只写 baseline-selftest.log）

```
cd /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local
PLAN=plans/task-v164-pointer-worktree-local
: > $PLAN/baseline-selftest.log
for f in skills/task-planner/scripts/selftest-*.sh; do
  out="$(bash "$f" 2>&1)"; rc=$?
  { echo "=== $(basename "$f") rc=$rc"; printf '%s\n' "$out" | grep -E 'Total|PASS|FAIL|OK:' | tail -6; } >> $PLAN/baseline-selftest.log
done
```

- 71 个脚本（`ls skills/task-planner/scripts/selftest-*.sh | wc -l` 应为 71）
- 若单条 bash 超过 120s：给该 bash 调用设 timeout=600000，或拆两批（前 36 + 后 35）分别追加进同一 log
- rc 必须取 `bash "$f"` 的真实退出码（禁管道后取 tail 的 rc）

## 验收（主进程将逐行复核）
- log 含 71 个 `=== selftest-*.sh rc=` 段
- 每段含该脚本 Total/PASS/FAIL 关键行原文（禁自报汇总数字）
- rc≠0 的脚本名逐一列出（= master 既有 FAIL 清单；先例 fix-pointer-race 登记既有 FAIL ~15 个，全部为既有非本次增量）

## 边界
- 只写 `$PLAN/baseline-selftest.log`；禁 git 写操作（add/commit/checkout/reset）；只读 git status/diff/log 允许
- 不改 worktree 内任何其他文件
