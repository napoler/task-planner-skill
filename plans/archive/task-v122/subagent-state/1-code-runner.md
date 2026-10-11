# 检查点 1-code-runner（sub:1-code-runner，全量 selftest 基线取证）
- status: done
- 运行窗口: 2026-10-03T00:57:10Z ~ 00:58:46Z
- 完整日志: 同目录 1-code-runner.log（逐脚本原文保留）

## 产出文件清单
- /mnt/data/dev/task-planner-skill/plans/task-v122/subagent-state/1-code-runner.log（新增，43 脚本全量逐脚本日志）
- /mnt/data/dev/task-planner-skill/plans/task-v122/findings.md（§2 契约追加：## Research Findings 段末新增 #### [sub:1-code-runner] 小节）
- /mnt/data/dev/task-planner-skill/plans/task-v122/progress.md（§2 契约追加：Phase 1 段 Actions taken 下追加 - [sub:1] 摘要行）

## 最终结论（8 字段块）
status: done
acceptance: 3/3 pass — [逐脚本原文行如下，共 43 个脚本，均 rc=0，FAIL=0；汇总数字由主进程逐行机械求和]
== skills/task-planner/scripts/selftest-active-plan.sh
Total: 19 PASS=19 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-ask-default-timeout.sh
Total: 9 PASS=9 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-batch-pilot.sh
Total: 10 PASS=10 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-check-conflicts.sh
Total: 7 PASS=7 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-check-drift.sh
Total: 6 PASS=6 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-conclusion-discipline.sh
Total: 24 PASS=24 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-context-hygiene.sh
Total: 12 PASS=12 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-delegation.sh
Total: 38    PASS=38  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-dispatch-grain.sh
Total: 10 PASS=10 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-dispatch.sh
Total: 31 PASS=31 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-error-loop.sh
Total: 16 PASS=16 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-execution-stability.sh
Total: 19  PASS=19  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-fallback.sh
Total: 31  PASS=31  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-final-gate-hash.sh
rc=0
== skills/task-planner/scripts/selftest-fine-grain-steps.sh
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-interaction.sh
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-iterative-optimizer.sh
Total: 8 PASS=8 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-knowledge-brief.sh
Total: 16  PASS=16  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-mechanism-profile.sh
Total: 19 PASS=19 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-methodology.sh
Total: 16 PASS=16 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-plan-dispatch.sh
Total: 12 PASS=12 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-plan-tier.sh
Total: 32 PASS=32 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-reflect-verify.sh
Total: 12 PASS=12 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-registry.sh
Total: 5 PASS=5 FAIL=0 (registry rows=43, actual selftest=43)
rc=0
== skills/task-planner/scripts/selftest-reliability-institution.sh
Total: 12 PASS=12 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-rescue-chain.sh
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-review-library.sh
Total: 15 PASS=15 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-rule23-conflict-scan.sh
Total: 3 PASS=3 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-self-resolution.sh
Total: 13 PASS=13 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-shared-tracker.sh
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-skill-collab.sh
Total: 25  PASS=25  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-skill-modify.sh
Total: 9 PASS=9 FAIL=0 (SKIP=0)
rc=0
== skills/task-planner/scripts/selftest-skill-split.sh
Total: 41  PASS=41  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-smart-merge.sh
Total: 17 PASS=17 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-sync-index.sh
Total: 13 PASS=13 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-task-boundary.sh
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-template-lifecycle.sh
Total: 21 PASS=21 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-template-sense.sh
Total: 8 PASS=8 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-tier-b.sh
Total: 18 PASS=18 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-tool-selection.sh
Total: 12 PASS=12 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-vc-gate.sh
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-veto.sh
Total: 13 PASS=13 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-workflow-orchestration.sh
Total: 16 PASS=16 FAIL=0
rc=0
files: /mnt/data/dev/task-planner-skill/plans/task-v122/subagent-state/1-code-runner.log(+1/0); /mnt/data/dev/task-planner-skill/plans/task-v122/subagent-state/1-code-runner.md(+1/0); /mnt/data/dev/task-planner-skill/plans/task-v122/findings.md(+1/0 追加); /mnt/data/dev/task-planner-skill/plans/task-v122/progress.md(+1/0 追加)
evidence: 1-code-runner.log: '== RUN START 2026-10-03T00:57:10Z' → 43 组 '== <脚本名> / (Total|结果): …FAIL=0 / rc=0' → '== RUN END 2026-10-03T00:58:46Z'; selftest-final-gate-hash.sh 末行为自带横幅 '==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ===='（无 Total: 前缀）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v122/subagent-state/1-code-runner.md (status: done)
findings_written: #### [sub:1-code-runner] 全量 selftest 基线（Rule 47 落地前取证）
blockers: none
confidence: HIGH
