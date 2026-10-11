# 13-executor — task-v118 终验全量回归

- 执行对象: `/home/terry/task-planner-skill-worktrees/task-v118/skills/task-planner/scripts/selftest-*.sh`（共 43 个,含新增 selftest-dispatch-grain.sh 10 断言版）
- 执行方式: 逐个 `timeout 120 bash <script>` 串行执行,无并行、无跳过
- 原始日志: `/tmp/v118-regression-raw.log`
- 时间: 2026-10-03

## 逐脚本结果（43 行）

|脚本|rc|PASS|FAIL|
|---|---|---|---|
|selftest-active-plan.sh|0|19|0|
|selftest-ask-default-timeout.sh|0|9|0|
|selftest-batch-pilot.sh|0|10|0|
|selftest-check-conflicts.sh|0|7|0|
|selftest-check-drift.sh|0|6|0|
|selftest-conclusion-discipline.sh|0|24|0|
|selftest-context-hygiene.sh|0|12|0|
|selftest-delegation.sh|0|38|0|
|selftest-dispatch-grain.sh|0|10|0|
|selftest-dispatch.sh|0|31|0|
|selftest-error-loop.sh|0|16|0|
|selftest-execution-stability.sh|0|19|0|
|selftest-fallback.sh|0|31|0|
|selftest-final-gate-hash.sh|0|22|0|
|selftest-fine-grain-steps.sh|0|11|0|
|selftest-interaction.sh|0|11|0|
|selftest-iterative-optimizer.sh|0|8|0|
|selftest-knowledge-brief.sh|0|16|0|
|selftest-mechanism-profile.sh|0|19|0|
|selftest-methodology.sh|0|16|0|
|selftest-plan-dispatch.sh|0|12|0|
|selftest-plan-tier.sh|0|32|0|
|selftest-reflect-verify.sh|0|12|0|
|selftest-registry.sh|0|5|0|
|selftest-reliability-institution.sh|0|12|0|
|selftest-rescue-chain.sh|0|11|0|
|selftest-review-library.sh|0|15|0|
|selftest-rule23-conflict-scan.sh|0|3|0|
|selftest-self-resolution.sh|0|13|0|
|selftest-shared-tracker.sh|0|11|0|
|selftest-skill-collab.sh|0|25|0|
|selftest-skill-modify.sh|0|9|0|
|selftest-skill-split.sh|0|41|0|
|selftest-smart-merge.sh|0|17|0|
|selftest-sync-index.sh|0|13|0|
|selftest-task-boundary.sh|0|11|0|
|selftest-template-lifecycle.sh|0|21|0|
|selftest-template-sense.sh|0|8|0|
|selftest-tier-b.sh|0|18|0|
|selftest-tool-selection.sh|0|12|0|
|selftest-vc-gate.sh|0|11|0|
|selftest-veto.sh|0|13|0|
|selftest-workflow-orchestration.sh|0|16|0|

注: 各脚本 Total 行原文示例 ——
- `selftest-delegation.sh`: `Total: 38    PASS=38  FAIL=0`
- `selftest-final-gate-hash.sh`: `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`
- `selftest-registry.sh`: `Total: 5 PASS=5 FAIL=0 (registry rows=43, actual selftest=43)`
- `selftest-skill-modify.sh`: `Total: 9 PASS=9 FAIL=0 (SKIP=0)`

## 总计

- 执行脚本数: 43/43（无跳过、无并行）
- rc=0: 43/43;rc≠0: 0
- ΣPASS = **676**;ΣFAIL = **0**
- 代表原文行:
  - `Total: 41  PASS=41  FAIL=0`（selftest-skill-split.sh,最大断言数）
  - `Total: 10 PASS=10 FAIL=0`（selftest-dispatch-grain.sh,新增 10 断言版）
  - `Total: 5 PASS=5 FAIL=0 (registry rows=43, actual selftest=43)`（selftest-registry.sh,registry 与磁盘脚本数一致 = 43）
- 结论: 全绿,0 FAIL,满足合并回前终验全量回归验收标准。
