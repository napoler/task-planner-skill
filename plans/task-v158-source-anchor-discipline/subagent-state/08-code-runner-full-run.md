# 08-code-runner-full-run — 全量 selftest 跑批逐行清单（VC-4 独立验收）

- 任务: task-v158-source-anchor-discipline, S-unit = VC-4 独立验收（全量跑批）
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v158-source-anchor-discipline
- 执行日期: 2026-10-10
- 执行方式: 逐脚本 `bash <script>`（绝对路径, 顺序执行, 无并行）; 每脚本 `timeout 75/90`; 记录 rc
- 覆盖核验: 执行清单与 `ls skills/task-planner/scripts/selftest-*.sh` 全集 `comm -3` 差集为空（无遗漏）
- FAIL 项: 无（0 个; 因无 FAIL, 无断言原文可附）
- 写入约束: 仅写本 checkpoint 文件; 未改动任何其他文件

## 逐行清单（原文, 格式 `PASS <脚本名> rc=<n>` 或 `FAIL <脚本名> rc=<n>`）

```
PASS selftest-active-plan.sh rc=0
PASS selftest-agent-coverage.sh rc=0
PASS selftest-ask-default-timeout.sh rc=0
PASS selftest-batch-pilot.sh rc=0
PASS selftest-capability-persistence.sh rc=0
PASS selftest-check-conflicts.sh rc=0
PASS selftest-check-drift.sh rc=0
PASS selftest-conclusion-discipline.sh rc=0
PASS selftest-context-hygiene.sh rc=0
PASS selftest-decision-arbiter.sh rc=0
PASS selftest-delegation.sh rc=0
PASS selftest-dispatch-grain.sh rc=0
PASS selftest-dispatch.sh rc=0
PASS selftest-drift-check-subagent.sh rc=0
PASS selftest-drift-enforcement.sh rc=0
PASS selftest-error-loop.sh rc=0
PASS selftest-evidence-goal-gate.sh rc=0
PASS selftest-execution-honesty.sh rc=0
PASS selftest-execution-stability.sh rc=0
PASS selftest-fallback.sh rc=0
PASS selftest-final-gate-hash.sh rc=0
PASS selftest-fine-grain-steps.sh rc=0
PASS selftest-four-file-dataflow.sh rc=0
PASS selftest-goal-unit-goal-mode.sh rc=0
PASS selftest-interaction.sh rc=0
PASS selftest-iteration-persistence.sh rc=0
PASS selftest-iterative-optimizer.sh rc=0
PASS selftest-knowledge-brief.sh rc=0
PASS selftest-lane-advancement.sh rc=0
PASS selftest-mechanism-profile.sh rc=0
PASS selftest-media-agents.sh rc=0
PASS selftest-media-dispatch.sh rc=0
PASS selftest-methodology.sh rc=0
PASS selftest-parallel-scheduling.sh rc=0
PASS selftest-periodic-review.sh rc=0
PASS selftest-plan-dispatch.sh rc=0
PASS selftest-plan-tier.sh rc=0
PASS selftest-reflect-verify.sh rc=0
PASS selftest-registry.sh rc=0
PASS selftest-reliability-institution.sh rc=0
PASS selftest-requirement-coverage.sh rc=0
PASS selftest-requirement-grading.sh rc=0
PASS selftest-rescue-chain.sh rc=0
PASS selftest-research-first.sh rc=0
PASS selftest-review-library.sh rc=0
PASS selftest-root-resolution.sh rc=0
PASS selftest-rule23-conflict-scan.sh rc=0
PASS selftest-rule-reserve.sh rc=0
PASS selftest-self-resolution.sh rc=0
PASS selftest-shared-tracker.sh rc=0
PASS selftest-skill-collab.sh rc=0
PASS selftest-skill-modify.sh rc=0
PASS selftest-skill-split.sh rc=0
PASS selftest-smart-merge.sh rc=0
PASS selftest-source-anchor-discipline.sh rc=0
PASS selftest-split-pattern-library.sh rc=0
PASS selftest-subagent-granularity-skill-escort.sh rc=0
PASS selftest-sync-index.sh rc=0
PASS selftest-task-boundary.sh rc=0
PASS selftest-template-lifecycle.sh rc=0
PASS selftest-template-sense.sh rc=0
PASS selftest-tier-b.sh rc=0
PASS selftest-tool-selection.sh rc=0
PASS selftest-user-instruction-priority.sh rc=0
PASS selftest-vc-gate.sh rc=0
PASS selftest-veto.sh rc=0
PASS selftest-workflow-orchestration.sh rc=0
```

## 负结果报告

- FAIL 断言原文检索: 未执行/不适用 — 全部脚本 rc=0, 跑批循环中 FAIL 分支（grep -n 'FAIL' 输出）零触发, 无断言原文可引。
- 未检查项: 各脚本内部 T 用例明细（父进程要求仅记录 rc 与脚本名, 已按要求跳过逐 T 输出）。
- 覆盖核验命令原文: `comm -3 <(ls .../selftest-*.sh | xargs -n1 basename | sort) <(printf '<执行清单>' | sort)` → 输出空（差集为空）。
