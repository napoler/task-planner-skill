# Checkpoint 16-code-runner-agent — worktree 全量 selftest 回归 round 1

- subagent_type: code-runner-agent(mini)
- 任务: 在 worktree 内跑全量 selftest 回归（round 1），产出每脚本 Total 行逐行清单与 FAIL 明细
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v166-summary-readability（不切换 CWD，只读跑批）
- 跑批命令: `cd /mnt/data/dev/task-planner-skill-worktrees/task-v166-summary-readability && for f in skills/task-planner/scripts/selftest-*.sh; do bash "$f"; done`

## T1 里程碑 — 跑批启动（2026-10-11 10:08:50 CST）

- 脚本数: 76（`ls skills/task-planner/scripts/selftest-*.sh | wc -l` → 76）
- 预检: summary-readability 单跑样本 14.7s rc=0，`Total: PASS=13 FAIL=0 WARN=0`
- 时长预算: 15 分钟；实际 10:08:53 → 10:11:07 ALLDONE，约 2.3 分钟，未超时
- 状态: done（由最终 T5 回填确认）

## T5 最终结论 — 全量回归结果（round 1）

### 5.1 每脚本 Total 行逐行清单（原文逐行抄录）+ exit 码

| # | 脚本 | exit | Total 行原文 |
|---|------|------|--------------|
| 1 | selftest-absorption-discipline | 0 | `Total: 14 pass, 0 fail, 0 skip` |
| 2 | selftest-active-plan | 0 | `Total: 29 PASS=29 FAIL=0` |
| 3 | selftest-agent-coverage | 0 | `Total: 9 PASS=9 FAIL=0 SKIPPED=0` |
| 4 | selftest-ask-default-timeout | 0 | `Total: 11 PASS=11 FAIL=0` |
| 5 | selftest-batch-pilot | 0 | `Total: 10 PASS=10 FAIL=0` |
| 6 | selftest-capability-persistence | 0 | `Total: 20 PASS=20 FAIL=0` |
| 7 | selftest-check-conflicts | 0 | `Total: 7 PASS=7 FAIL=0` |
| 8 | selftest-check-drift | 0 | `Total: 6 PASS=6 FAIL=0` |
| 9 | selftest-conclusion-discipline | 0 | `Total: 24 PASS=24 FAIL=0` |
| 10 | selftest-context-hygiene | 0 | `Total: 12 PASS=12 FAIL=0` |
| 11 | selftest-context-pressure | 0 | `Total: 9 PASS=9 FAIL=0` |
| 12 | selftest-decision-arbiter | 0 | `Total: 16 PASS=16 FAIL=0` |
| 13 | selftest-decision-drift | 0 | `Total: 23 PASS=23 FAIL=0` |
| 14 | selftest-decision-grading | 0 | `Total: PASS=12 FAIL=0 WARN=0` |
| 15 | selftest-delegation | 0 | `Total: 38    PASS=38  FAIL=0` |
| 16 | selftest-dispatch-grain | 0 | `Total: 10 PASS=10 FAIL=0` |
| 17 | selftest-dispatch | 0 | `Total: 31 PASS=31 FAIL=0` |
| 18 | selftest-drift-check-subagent | 0 | `Total: 20 PASS=20 FAIL=0` |
| 19 | selftest-drift-enforcement | 0 | `Total: 23 PASS=23 FAIL=0` |
| 20 | selftest-error-fix-prompt-forge | 0 | `Total: 8 PASS=8 FAIL=0` |
| 21 | selftest-error-loop | 0 | `Total: 16 PASS=16 FAIL=0` |
| 22 | selftest-evidence-goal-gate | 0 | `Total: 21 PASS=21 FAIL=0` |
| 23 | selftest-execution-honesty | 0 | `Total: 14 PASS=14 FAIL=0` |
| 24 | selftest-execution-stability | 0 | `Total: 19  PASS=19  FAIL=0` |
| 25 | selftest-fallback | 0 | `Total: 31  PASS=31  FAIL=0` |
| 26 | selftest-final-gate-hash | 0 | `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====` |
| 27 | selftest-fine-grain-steps | 0 | `Total: 11 PASS=11 FAIL=0` |
| 28 | selftest-four-file-dataflow | 0 | `Total: 18 PASS=18 FAIL=0` |
| 29 | selftest-goal-unit-goal-mode | 0 | `Total: 9 PASS=9 FAIL=0` |
| 30 | selftest-interaction | 0 | `Total: 11 PASS=11 FAIL=0` |
| 31 | selftest-iteration-persistence | 0 | `Total: 18 PASS=18 FAIL=0` |
| 32 | selftest-iterative-optimizer | 0 | `Total: 8 PASS=8 FAIL=0` |
| 33 | selftest-knowledge-brief | 0 | `Total: 16  PASS=16  FAIL=0` |
| 34 | selftest-lane-advancement | 0 | `Total: 14 PASS=14 FAIL=0` |
| 35 | selftest-mechanism-profile | 0 | `Total: 19 PASS=19 FAIL=0` |
| 36 | selftest-media-agents | 0 | `Total: 10 PASS=10 FAIL=0` |
| 37 | selftest-media-dispatch | 0 | `Total: 9 PASS=9 FAIL=0` |
| 38 | selftest-methodology | 0 | `Total: 16 PASS=16 FAIL=0` |
| 39 | selftest-parallel-scheduling | 0 | `Total: 9 PASS=9 FAIL=0` |
| 40 | selftest-periodic-review | 0 | `Total: 10 PASS=10 FAIL=0` |
| 41 | selftest-plan-dispatch | 0 | `Total: 12 PASS=12 FAIL=0` |
| 42 | selftest-plan-tier | 0 | `Total: 32 PASS=32 FAIL=0` |
| 43 | selftest-pointer-lifecycle | 0 | `Total: 10 PASS=10 FAIL=0` |
| 44 | selftest-reflect-verify | 0 | `Total: 12 PASS=12 FAIL=0` |
| 45 | selftest-registry | 0 | `Total: 5 PASS=5 FAIL=0 (registry rows=76, actual selftest=76)` |
| 46 | selftest-reliability-institution | 0 | `Total: 16 PASS=16 FAIL=0` |
| 47 | selftest-report-reviewability | 0 | `Total: PASS=13 FAIL=0 WARN=0` |
| 48 | selftest-requirement-coverage | 0 | `Total: 23 PASS=23 FAIL=0` |
| 49 | selftest-requirement-grading | 0 | `Total: 7 PASS=7 FAIL=0` |
| 50 | selftest-rescue-chain | 0 | `Total: 11 PASS=11 FAIL=0` |
| 51 | selftest-research-first | 0 | `Total: 12 PASS=12 FAIL=0` |
| 52 | selftest-review-library | 0 | `Total: 15 PASS=15 FAIL=0` |
| 53 | selftest-root-resolution | 0 | `Total: 17 PASS=17 FAIL=0` |
| 54 | selftest-rule23-conflict-scan | 0 | `Total: 3 PASS=3 FAIL=0` |
| 55 | selftest-rule-reserve | 0 | `Total: 10 PASS=10 FAIL=0` |
| 56 | selftest-self-resolution | 0 | `Total: 13 PASS=13 FAIL=0` |
| 57 | selftest-shared-tracker | 0 | `Total: 11 PASS=11 FAIL=0` |
| 58 | selftest-skill-collab | 0 | `Total: 25  PASS=25  FAIL=0` |
| 59 | selftest-skill-modify | 0 | `Total: 9 PASS=9 FAIL=0 (SKIP=0)` |
| 60 | selftest-skill-split | 0 | `Total: 41  PASS=41  FAIL=0` |
| 61 | selftest-smart-merge | 0 | `Total: 18 PASS=18 FAIL=0` |
| 62 | selftest-source-anchor-discipline | 0 | `Total: 12 pass, 0 fail` |
| 63 | selftest-split-pattern-library | 0 | `Total: 13 PASS=13 FAIL=0` |
| 64 | selftest-subagent-granularity-skill-escort | 0 | `Total: 23 PASS=23 FAIL=0` |
| 65 | selftest-subagent-return | 0 | `Total: 11 PASS=11 FAIL=0` |
| 66 | selftest-summary-readability | 0 | `Total: PASS=13 FAIL=0 WARN=0` |
| 67 | selftest-sync-index | 0 | `Total: 13 PASS=13 FAIL=0` |
| 68 | selftest-task-boundary | 0 | `Total: 11 PASS=11 FAIL=0` |
| 69 | selftest-template-lifecycle | 0 | `Total: 24 PASS=24 FAIL=0` |
| 70 | selftest-template-sense | 0 | `Total: 8 PASS=8 FAIL=0` |
| 71 | selftest-tier-b | 0 | `Total: 18 PASS=18 FAIL=0` |
| 72 | selftest-tool-selection | 0 | `Total: 12 PASS=12 FAIL=0` |
| 73 | selftest-user-instruction-priority | 0 | `=== ALL PASS ===` |
| 74 | selftest-vc-gate | 0 | `Total: 11 PASS=11 FAIL=0` |
| 75 | selftest-veto | 0 | `Total: 13 PASS=13 FAIL=0` |
| 76 | selftest-workflow-orchestration | 0 | `Total: 16 PASS=16 FAIL=0` |

> 说明: 76 脚本均 exit=0。74 脚本用 `Total:` 行；selftest-final-gate-hash.sh 用 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`；selftest-user-instruction-priority.sh 用 `=== ALL PASS ===`（✓ 断言 7 条），均已逐行抄录不遗漏。

### 5.2 FAIL 明细

**无**。四路独立核查均零 FAIL:
1. `grep 'FAIL:' 全部 log` → NONE（各脚本零 FAIL 断言）
2. `grep -Hn '^Total:.*WARN=[1-9]'` → NONE（零 WARN）
3. exitcodes.txt 76 行均 `exit=0`，无非零退出；后台任务最终 exit code 0
4. 伪命中排除: selftest-mechanism-profile.sh.log 第 18 行 `MP-18 PASS 行为: enforce 档 exit 1 且打 ✗` 为 PASS 断言文本自带 ✗ 字符，非失败标记

### 5.3 ΣPASS 交叉核对（子代理自算，主进程 VC-5 须逐行独立复算）

- 断言总数 ΣPASS = 1153（含 user-instruction-priority 的 7 条 ✓ 断言；final-gate-hash 按 `PASS=22` 计）
- 内部一致性信号: selftest-registry `Total: 5 PASS=5 FAIL=0 (registry rows=76, actual selftest=76)` —— registry 行数=实际脚本数 76
- 计划 deviation（非回归失败）: 本计划 VC-4 预期 `registry rows=74`，实际 registry 自报 76=76 内部一致；差异源于计划期对既有脚本基数的假设，需 S21/终验核对 VC-4 判据口径

### 5.4 最终结论 8 字段块（同第 7 节返回格式）

```
status: done
acceptance: 76/76 pass — [1:PASS 2:PASS … 76:PASS（全部 exit=0 且 FAIL=0；末两脚本非常规格式: final-gate-hash PASS=22 FAIL=0 / user-instruction-priority === ALL PASS ===）]
files: none
evidence: for f in skills/task-planner/scripts/selftest-*.sh; do bash "$f"; done → 76/76 exit=0; grep 'FAIL:' logs → NONE; selftest-summary-readability.sh → Total: PASS=13 FAIL=0 WARN=0 rc=0; selftest-registry.sh → Total: 5 PASS=5 FAIL=0 (registry rows=76, actual selftest=76); ALLDONE 10:11:07
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v166-summary-readability/subagent-state/16-code-runner-agent.md (status: done)
findings_written: none
blockers: 无（唯计划 VC-4 口径偏差登记于 5.3: 预期 registry rows=74，实际 76=脚本实数，内部一致）
confidence: HIGH
```
