# regression-s3 (P3-S3 全量 selftest 基线对照)

## 目标
对照主仓 master (af18ad3) 与 worktree (f2555a0) 的全量 selftest 结果，判定新增 FAIL=0（R2）。

## 执行环境与口径
- 时间: 2026-11-15 16:34:01 CST (run start context)
- 口径: `scripts/run-selftests.sh` 在主仓与 worktree 均不存在；按指令采用等价聚合：`for f in skills/task-planner/scripts/selftest-*.sh; do bash "$f"; done`（97 个 selftest 脚本）。
- 基线输出: `/mnt/data/dev/task-planner-skill/tmp/regression-tpl-sediment-baseline.txt`
- worktree 输出: `/mnt/data/dev/task-planner-skill/tmp/regression-tpl-sediment-worktree.txt`

## HEAD 记录（归因用）
- 主仓 HEAD: `af18ad3` (`git -C /mnt/data/dev/task-planner-skill rev-parse --short HEAD`)
- Worktree HEAD: `f2555a0` (`git -C /mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115 rev-parse --short HEAD`)

## 运行结果
- 基线聚合命令退出码: `EXIT=0` (wrapper loop completed)
- Worktree 聚合命令退出码: `EXIT=0`
- 基线 `grep -c "FAIL"` (原始含 FAIL=0 摘要行): `105`
- Worktree `grep -c "FAIL"` (原始含 FAIL=0 摘要行): `105`

## 实际失败断言/套件（两侧一致，均为预存）
1. `T11 FAIL rc=1 att_bb=no att_aa=` (selftest-active-plan，总计 `Total: 29 PASS=28 FAIL=1`)
2. `[FAIL] T11b B1 负例: 改内容后 owner=othersid999 → 重锁不命中(plan_sha256 仍为旧值 且 attested_by_sid 重置为空, 不被洗白)` (selftest-execution-stability，总计 `Total: 19  PASS=18  FAIL=1`)

其余匹配到 `FAIL` token 的行为描述文本中包含“FAIL”字样但标记为 PASS/FAIL=0 的摘要或用例说明，非新增失败。

## comm 对照（新增 FAIL 判定）
- 过滤口径: `grep -E "FAIL" ... | grep -vE 'FAIL=0([^0-9]|$)'` 提取实际含失败/FAIL 语义行集合后排序比较
- 基线过滤行数: 15
- Worktree 过滤行数: 15
- 命令: `comm -13 <(sort baseline-fails.txt) <(sort worktree-fails.txt)`
- 输出: (空)
- `COMM_EXIT=0`

## 归因
- 新增 FAIL（worktree 有而基线无）: 0
- 既有 FAIL: T11 / T11b B1，为主仓与 worktree 共同存在的预存失败（与已知 findings F16 预存项一致方向：active-plan/execution-stability），非本任务改动引入；未观察到环境/时序导致的差异新增。

## 结论
- status: PASS
- acceptance (新增 FAIL=0): PASS
- confidence: high（同口径 97 脚本全量聚合，两侧 HEAD 明确，输出文件与 comm 对照证据完整）
- issues: none
- handoff: 预存 T11/T11b B1 失败仍存在，后续任务若需全绿需另案处理；本任务未引入回归。
