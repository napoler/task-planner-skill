# S7 checkpoint — code-runner-agent（task-v187 全量 selftest 回归跑批）

status: done
执行时间: 2026-10-18（本会话）；批跑总耗时 ~323s（91 脚本串行）

## 步骤 1 — 清单枚举（完成）
- 位置: /home/terry/task-planner-skill-worktrees/task-v187-workflow-activation-parallel/skills/task-planner/scripts/
- 原文: `ls selftest-*.sh | wc -l` → **91**
- 执行计数 = 91 = ls 计数（无遗漏，acceptance 1 ✓）

## 步骤 2 — 逐脚本执行（完成）
- 方法: `timeout -k 5 120 bash <script>` 串行；输出 /tmp/s7_out/<script>.sh.log；原始 TSV /tmp/s7_results.tsv；修正后权威表 /tmp/s7_final.tsv
- 解析修正说明（3 处初版解析偏差，均按日志原文复核）:
  - #8 channel-fast-fail: Total 行 `PASS: 6  FAIL: 0`（冒号型）→ 实 P=6 F=0（初版误记 1/1）
  - #38 iteration-persistence: 叙述行含 `PASS-FAIL=1` 字面量干扰 → 权威 Total 行 `PASS=18 FAIL=0`（初版误记 F=1）
  - #29 final-gate-hash: `==== 结果: PASS=22 FAIL=0 ====` 行不含 total 关键字 → P=22 F=0（初版行数计数误记 23/1）
- 修正后逐脚本计数表（91 行）:

| # | 脚本 | PASS | FAIL | exit | 超时 | 耗时s | 计数来源 |
|---|------|------|------|------|------|-------|---------|
| 1 | selftest-absorption-discipline.sh | 13 | 0 | 0 | no | 0 | Total行 13 pass |
| 2 | selftest-active-plan.sh | 29 | 0 | 0 | no | 7 | Total行 FAIL=0 |
| 3 | selftest-agent-coverage.sh | 9 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 4 | selftest-archive-plan.sh | 20 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 5 | selftest-ask-default-timeout.sh | 11 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 6 | selftest-batch-pilot.sh | 10 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 7 | selftest-capability-persistence.sh | 20 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 8 | selftest-channel-fast-fail.sh | 6 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 9 | selftest-check-conflicts.sh | 7 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 10 | selftest-check-drift.sh | 7 | 0 | 0 | no | 3 | Total行 FAIL=0 |
| 11 | selftest-conclusion-discipline.sh | 24 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 12 | selftest-context-hygiene.sh | 12 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 13 | selftest-context-pressure.sh | 9 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 14 | selftest-decision-arbiter.sh | 16 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 15 | selftest-decision-drift.sh | 23 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 16 | selftest-decision-grading.sh | 11 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 17 | selftest-delegation.sh | 38 | 0 | 0 | no | 4 | Total行 FAIL=0 |
| 18 | selftest-dispatch-grain.sh | 10 | 0 | 0 | no | 2 | Total行 FAIL=0 |
| 19 | selftest-dispatch.sh | 31 | 0 | 0 | no | 8 | Total行 FAIL=0 |
| 20 | selftest-doc-script-paths.sh | 3 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 21 | selftest-drift-check-subagent.sh | 21 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 22 | selftest-drift-enforcement.sh | 23 | 0 | 0 | no | 14 | Total行 FAIL=0 |
| 23 | selftest-error-fix-prompt-forge.sh | 8 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 24 | selftest-error-loop.sh | 16 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 25 | selftest-evidence-anchor.sh | 26 | 0 | 0 | no | 37 | Total行 FAIL=0 |
| 26 | selftest-evidence-goal-gate.sh | 23 | 0 | 0 | no | 5 | Total行 FAIL=0 |
| 27 | selftest-execution-honesty.sh | 14 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 28 | selftest-execution-stability.sh | 19 | 0 | 0 | no | 3 | Total行 FAIL=0 |
| 29 | selftest-final-gate-hash.sh | 22 | 0 | 0 | no | 23 | 结果行 PASS=22 FAIL=0 |
| 30 | selftest-fine-grain-steps.sh | 11 | 0 | 0 | no | 3 | Total行 FAIL=0 |
| 31 | selftest-four-file-dataflow.sh | 18 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 32 | selftest-gate-degraded.sh | 16 | 0 | 0 | no | 2 | Total行 FAIL=0 |
| 33 | selftest-gate-injection.sh | 11 | 0 | 0 | no | 8 | Total行 FAIL=0 |
| 34 | selftest-goal-cjk.sh | 11 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 35 | selftest-goal-unit-goal-mode.sh | 9 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 36 | selftest-input-consistency.sh | 5 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 37 | selftest-interaction.sh | 11 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 38 | selftest-iteration-persistence.sh | 18 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 39 | selftest-iterative-optimizer.sh | 8 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 40 | selftest-knowledge-brief.sh | 16 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 41 | selftest-lane-advancement.sh | 14 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 42 | selftest-mechanism-profile.sh | 19 | 0 | 0 | no | 32 | Total行 FAIL=0 |
| 43 | selftest-media-agents.sh | 10 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 44 | selftest-media-dispatch.sh | 9 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 45 | selftest-methodology.sh | 16 | 0 | 0 | no | 2 | Total行 FAIL=0 |
| 46 | selftest-parallel-scheduling.sh | 9 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 47 | selftest-periodic-review.sh | 10 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 48 | selftest-plan-dispatch.sh | 12 | 0 | 0 | no | 3 | Total行 FAIL=0 |
| 49 | selftest-plan-tier.sh | 32 | 0 | 0 | no | 17 | Total行 FAIL=0 |
| 50 | selftest-pointer-lifecycle.sh | 10 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 51 | selftest-proactive-research.sh | 15 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 52 | selftest-reflect-verify.sh | 12 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 53 | selftest-registry.sh | 5 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 54 | selftest-reliability-institution.sh | 16 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 55 | selftest-report-reviewability.sh | 12 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 56 | selftest-requirement-coverage.sh | 23 | 0 | 0 | no | 27 | Total行 FAIL=0 |
| 57 | selftest-requirement-grading.sh | 7 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 58 | selftest-research-first.sh | 12 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 59 | selftest-review-library.sh | 15 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 60 | selftest-root-resolution.sh | 17 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 61 | selftest-rule23-conflict-scan.sh | 3 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 62 | selftest-rule-reserve-pairing.sh | 3 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 63 | selftest-rule-reserve.sh | 10 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 64 | selftest-rvc-coverage.sh | 9 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 65 | selftest-self-resolution.sh | 13 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 66 | selftest-session-log.sh | 12 | 0 | 0 | no | 6 | Total行 FAIL=0 |
| 67 | selftest-shared-tracker.sh | 11 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 68 | selftest-skill-collab.sh | 25 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 69 | selftest-skill-modify.sh | 7 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 70 | selftest-skill-split.sh | 40 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 71 | selftest-smart-merge.sh | 18 | 0 | 0 | no | 10 | Total行 FAIL=0 |
| 72 | selftest-source-anchor-discipline.sh | 12 | 0 | 0 | no | 0 | Total行 12 pass |
| 73 | selftest-split-pattern-library.sh | 13 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 74 | selftest-state-consistency.sh | 5 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 75 | selftest-step-placeholders.sh | 10 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 76 | selftest-subagent-granularity-skill-escort.sh | 23 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 77 | selftest-subagent-return.sh | 12 | 0 | 0 | no | 2 | Total行 FAIL=0 |
| 78 | selftest-summary-readability.sh | 13 | 0 | 0 | no | 29 | Total行 FAIL=0 |
| 79 | selftest-sync-index.sh | 15 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 80 | selftest-task-boundary.sh | 11 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 81 | selftest-template-lifecycle.sh | 24 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 82 | selftest-template-sense.sh | 8 | 0 | 0 | no | 32 | Total行 FAIL=0 |
| 83 | selftest-tier-b.sh | 18 | 0 | 0 | no | 2 | Total行 FAIL=0 |
| 84 | selftest-tier-consistency.sh | 8 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 85 | selftest-tool-selection.sh | 12 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 86 | selftest-user-instruction-priority.sh | 7 | 0 | 0 | no | 0 | ✓ 计数 7 条 + ALL PASS |
| 87 | selftest-vc-gate.sh | 11 | 0 | 0 | no | 22 | Total行 FAIL=0 |
| 88 | selftest-vc-nonvacuous.sh | 13 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 89 | selftest-verification-gate.sh | 13 | 0 | 0 | no | 1 | Total行 FAIL=0 |
| 90 | selftest-veto.sh | 13 | 0 | 0 | no | 0 | Total行 FAIL=0 |
| 91 | selftest-workflow-orchestration.sh | 22 | 0 | 0 | no | 0 | Total行 FAIL=0 |

## 步骤 3 — 汇总（完成）
- **ΣPASS = 1304 / ΣFAIL = 0**（91 脚本全 rc=0，0 超时）
- FAIL>0 脚本: **无** → 无尾 10 行片段可附（负结果报告: FAIL 计数 / rc / timeout 三维逐一核查均零命中；初版 3 例伪阳性已按日志原文排除，非真实断言失败）

## 步骤 4 — 零写入验证（完成）
- worktree git status 执行前 vs 执行后: **完全一致**（3 个 M 文件均前序 S6/S8 产物: critical-rules-collab.md / selftest-tool-selection.sh / selftest-workflow-orchestration.sh）→ acceptance 3 ✓
- 本单元写入 = 仅本检查点；/tmp 中间产物（s7_out/ s7_results.tsv s7_final.tsv s7_table.md）不属仓库

## 结论
全量回归 **91/91 PASS**（ΣPASS=1304 断言，0 FAIL，0 TIMEOUT）。前序 S6/S8 锚级联未引入 selftest 回归破坏。
