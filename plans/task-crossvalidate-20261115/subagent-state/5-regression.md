# 5-regression 回归分账检查点

## T1 任务
全量回归分账：主仓基线 ΣFAIL vs worktree ΣFAIL 对照，判定无新增 FAIL（VC-5）。

## T2 输入
- 主仓：/mnt/data/dev/task-planner-skill
- worktree：/mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115
- runner：skills/task-planner/scripts/run-selftests.sh

## T3 执行动作
1. 主仓运行：`cd /mnt/data/dev/task-planner-skill && bash skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -25`
2. 写基线整数：`.regression-baseline` = `3`
3. worktree 运行：`cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115 && bash skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -25`
4. 对照 FAIL 数与 Failed 列表差集

## T4 结果
- 主仓 Total 行：`Total: 97 PASS=94 FAIL=3 (run=97 reused=0)`
- 主仓 Failed：`selftest-active-plan selftest-execution-stability selftest-rule-reserve-pairing`
- 基线文件：`/mnt/data/dev/task-planner-skill/plans/task-crossvalidate-20261115/.regression-baseline` 内容 `3`
- worktree Total 行：`Total: 98 PASS=96 FAIL=2 (run=98 reused=0)`
- worktree Failed：`selftest-active-plan selftest-execution-stability`
- FAIL 差集（主仓有、worktree 无）：`selftest-rule-reserve-pairing`（减少，非新增）

## T5 判定
worktree FAIL (2) ≤ baseline FAIL (3) 成立，无新增 FAIL。判定：PASS。

## 最终结论段
status: done
acceptance: 3/3 pass — [1:PASS 2:PASS 3:PASS] 主仓: `Total: 97 PASS=94 FAIL=3 (run=97 reused=0)` | worktree: `Total: 98 PASS=96 FAIL=2 (run=98 reused=0)`
files: /mnt/data/dev/task-planner-skill/plans/task-crossvalidate-20261115/.regression-baseline (+1/-0); /mnt/data/dev/task-planner-skill/plans/task-crossvalidate-20261115/subagent-state/5-regression.md (+35/-0); /mnt/data/dev/task-planner-skill/plans/task-crossvalidate-20261115/findings.md (+5/-0)
evidence: cd /mnt/data/dev/task-planner-skill && bash skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -25 → `Total: 97 PASS=94 FAIL=3 (run=97 reused=0)` / `Failed: selftest-active-plan selftest-execution-stability selftest-rule-reserve-pairing`; cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115 && bash skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -25 → `Total: 98 PASS=96 FAIL=2 (run=98 reused=0)` / `Failed: selftest-active-plan selftest-execution-stability`; printf '3\n' > .regression-baseline
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-crossvalidate-20261115/subagent-state/5-regression.md (status: done)
findings_written: #### [sub:1-regression]（findings.md 仅追加节锚）
blockers: none
confidence: HIGH
