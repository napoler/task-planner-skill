# 9-executor — task-v118 Phase 4 全量回归

执行方式：`timeout 120 bash <script>` 逐个串行，只读。worktree=/home/terry/task-planner-skill-worktrees/task-v118

|脚本|rc|PASS|FAIL|
|---|---|---|---|
|selftest-active-plan.sh|0|19|0|
|selftest-ask-default-timeout.sh|0|9|0|
|selftest-batch-pilot.sh|0|10|0|
|selftest-check-conflicts.sh|0|7|0|
|selftest-check-drift.sh|0|6|0|
|selftest-conclusion-discipline.sh|1|23|1|
|selftest-context-hygiene.sh|0|12|0|
|selftest-delegation.sh|0|38|0|
|selftest-dispatch-grain.sh|0|9|0|
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

## 总计（43/43 完成）

- ΣPASS = 674，ΣFAIL = 1
- rc≠0 脚本仅 1 个：selftest-conclusion-discipline.sh（rc=1）
- 43 脚本全跑无跳过；全绿 0 FAIL 预期未达成（存在 1 个 FAIL，原样记录）
- FAIL 唯一来源：CD-12（SKILL.md 宽容锚「1-3[5-9]」2 +「1-45」0 合计 ≥3 未达标，task-v117 双锚口径扩展）
- RT-08 PASS（selftest-ask-default-timeout.sh）；dispatch 系列（dispatch / dispatch-grain / plan-dispatch）全 PASS

备注：批次累计校正 — 40/43 时点 ΣPASS=634（批 3-4 计数复核后），最终 43/43 为 674/1（独立重算校验，43 行计数逐行求和一致）。

## FAIL 明细（原样记录）

selftest-conclusion-discipline.sh（rc=1，Total: 24 PASS=23 FAIL=1）：
```
CD-12 FAIL SKILL.md 宽容锚「1-3[5-9]」2 +「1-45」0 合计 ≥3（兼容 1-35-45 过渡，task-v117 双锚口径扩展）
```
