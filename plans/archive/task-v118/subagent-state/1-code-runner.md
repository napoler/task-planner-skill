# 1-executor — task-v118 Phase 1 selftest 基线

- 目标目录: /home/terry/task-planner-skill-worktrees/task-v118/skills/task-planner/scripts
- 执行方式: 逐个 `timeout 120 bash <script>`，不并行，只读
- 开始时间: 2026-10-03

|脚本|rc|PASS|FAIL|
|----|----|----|----|
|selftest-active-plan.sh|0|19|0|
|selftest-ask-default-timeout.sh|0|9|0|
|selftest-batch-pilot.sh|0|10|0|
|selftest-check-conflicts.sh|0|7|0|
|selftest-check-drift.sh|0|6|0|
|selftest-conclusion-discipline.sh|0|24|0|
|selftest-context-hygiene.sh|0|12|0|
|selftest-delegation.sh|0|38|0|
|selftest-dispatch.sh|0|31|0|
|selftest-error-loop.sh|0|16|0|

进度: 10/42 完成，前 10 全 rc=0，ΣPASS=172 ΣFAIL=0
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

进度: 20/42 完成，前 20 全 rc=0，ΣPASS=337 ΣFAIL=0
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

进度: 30/42 完成，前 30 全 rc=0，ΣPASS=476 ΣFAIL=0
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

进度: 42/42 完成，全部 rc=0

## 总计

- 脚本数: 42/42 全跑，无跳过，无 timeout（各脚本 <120s 内完成）
- rc 分布: 42 个 rc=0，0 个非零
- **ΣPASS = 666, ΣFAIL = 0**（逐批次: 1-10=172, 11-20=+165=337, 21-30=+139=476, 31-42=+190=666）
- FAIL 明细: 无（全部 FAIL=0，无 FAIL 行可附）
- 交叉佐证: selftest-registry.sh 输出 "registry rows=42, actual selftest=42" 与本次清单一致
- 结论: 基线全绿（GREEN）

注: batch3 行曾误记 ΣPASS=516，已更正为 476（以逐脚本 PASS 求和为准）。
