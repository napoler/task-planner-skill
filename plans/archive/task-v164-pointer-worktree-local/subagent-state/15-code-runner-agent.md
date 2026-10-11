# sub:15-code-runner-agent — S11-r2 合并后态回归（checkpoint）

- status: done
- started_at: 2026-10-10 22:41:22（BATCH_START）
- finished_at: 2026-10-10 22:44:09（BATCH_END，167s，预算 15min 内）
- worktree HEAD: 74691cb（40a72f7 merge master 之后）；全程绝对路径，未切换 CWD
- 段数: 75（regression-worktree-merged.log:1-372）；rc≠0 空集；FAIL=[1-9] 零命中；无 TRUNCATED
- 口径偏差登记: 派发单「72 个」为 merge 前计数；实测全集=75（prior S11 72 + master 并入新增 3: absorption-discipline / decision-drift / subagent-return；diff prior.txt vs now.txt 仅此 3 增）。按「全集」语义跑全 glob，未裁剪。
- progress.md 追加行按真实 75 写入（派发给定模板串含「72 脚本」，为避免失真改为 75+口径注解；Status/Started 未动）。
- 命令: 派发单第 2 节模板原样执行（bash 真实 rc + grep Total|PASS|FAIL|OK: tail -4 逐段落盘）

## 最终结论（第 7 节同一 8 字段块）

status: done
acceptance: 75/75 pass（派发口径 72；实测全集 75=事前 72+merge 新增 3）— 逐项 rc= 与 Total 行原文（regression-worktree-merged.log，75 段）：
1 === selftest-absorption-discipline.sh rc=0 | Total: 14 pass, 0 fail, 0 skip
2 === selftest-active-plan.sh rc=0 | Total: 29 PASS=29 FAIL=0
3 === selftest-agent-coverage.sh rc=0 | Total: 9 PASS=9 FAIL=0 SKIPPED=0
4 === selftest-ask-default-timeout.sh rc=0 | Total: 11 PASS=11 FAIL=0
5 === selftest-batch-pilot.sh rc=0 | Total: 10 PASS=10 FAIL=0
6 === selftest-capability-persistence.sh rc=0 | Total: 20 PASS=20 FAIL=0
7 === selftest-check-conflicts.sh rc=0 | Total: 7 PASS=7 FAIL=0
8 === selftest-check-drift.sh rc=0 | Total: 6 PASS=6 FAIL=0
9 === selftest-conclusion-discipline.sh rc=0 | Total: 24 PASS=24 FAIL=0
10 === selftest-context-hygiene.sh rc=0 | Total: 12 PASS=12 FAIL=0
11 === selftest-context-pressure.sh rc=0 | Total: 9 PASS=9 FAIL=0
12 === selftest-decision-arbiter.sh rc=0 | Total: 16 PASS=16 FAIL=0
13 === selftest-decision-drift.sh rc=0 | Total: 23 PASS=23 FAIL=0
14 === selftest-decision-grading.sh rc=0 | Total: PASS=12 FAIL=0 WARN=0
15 === selftest-delegation.sh rc=0 | Total: 38    PASS=38  FAIL=0
16 === selftest-dispatch-grain.sh rc=0 | Total: 10 PASS=10 FAIL=0
17 === selftest-dispatch.sh rc=0 | Total: 31 PASS=31 FAIL=0
18 === selftest-drift-check-subagent.sh rc=0 | Total: 20 PASS=20 FAIL=0
19 === selftest-drift-enforcement.sh rc=0 | Total: 23 PASS=23 FAIL=0
20 === selftest-error-fix-prompt-forge.sh rc=0 | Total: 8 PASS=8 FAIL=0
21 === selftest-error-loop.sh rc=0 | Total: 16 PASS=16 FAIL=0
22 === selftest-evidence-goal-gate.sh rc=0 | Total: 21 PASS=21 FAIL=0
23 === selftest-execution-honesty.sh rc=0 | Total: 14 PASS=14 FAIL=0
24 === selftest-execution-stability.sh rc=0 | Total: 19  PASS=19  FAIL=0
25 === selftest-fallback.sh rc=0 | Total: 31  PASS=31  FAIL=0
26 === selftest-final-gate-hash.sh rc=0 | ==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====
27 === selftest-fine-grain-steps.sh rc=0 | Total: 11 PASS=11 FAIL=0
28 === selftest-four-file-dataflow.sh rc=0 | Total: 18 PASS=18 FAIL=0
29 === selftest-goal-unit-goal-mode.sh rc=0 | Total: 9 PASS=9 FAIL=0
30 === selftest-interaction.sh rc=0 | Total: 11 PASS=11 FAIL=0
31 === selftest-iteration-persistence.sh rc=0 | Total: 18 PASS=18 FAIL=0
32 === selftest-iterative-optimizer.sh rc=0 | Total: 8 PASS=8 FAIL=0
33 === selftest-knowledge-brief.sh rc=0 | Total: 16  PASS=16  FAIL=0
34 === selftest-lane-advancement.sh rc=0 | Total: 14 PASS=14 FAIL=0
35 === selftest-mechanism-profile.sh rc=0 | Total: 19 PASS=19 FAIL=0
36 === selftest-media-agents.sh rc=0 | Total: 10 PASS=10 FAIL=0
37 === selftest-media-dispatch.sh rc=0 | Total: 9 PASS=9 FAIL=0
38 === selftest-methodology.sh rc=0 | Total: 16 PASS=16 FAIL=0
39 === selftest-parallel-scheduling.sh rc=0 | Total: 9 PASS=9 FAIL=0
40 === selftest-periodic-review.sh rc=0 | Total: 10 PASS=10 FAIL=0
41 === selftest-plan-dispatch.sh rc=0 | Total: 12 PASS=12 FAIL=0
42 === selftest-plan-tier.sh rc=0 | Total: 32 PASS=32 FAIL=0
43 === selftest-pointer-lifecycle.sh rc=0 | Total: 10 PASS=10 FAIL=0
44 === selftest-reflect-verify.sh rc=0 | Total: 12 PASS=12 FAIL=0
45 === selftest-registry.sh rc=0 | Total: 5 PASS=5 FAIL=0 (registry rows=75, actual selftest=75)
46 === selftest-reliability-institution.sh rc=0 | Total: 16 PASS=16 FAIL=0
47 === selftest-report-reviewability.sh rc=0 | Total: PASS=13 FAIL=0 WARN=0
48 === selftest-requirement-coverage.sh rc=0 | Total: 23 PASS=23 FAIL=0
49 === selftest-requirement-grading.sh rc=0 | Total: 7 PASS=7 FAIL=0
50 === selftest-rescue-chain.sh rc=0 | Total: 11 PASS=11 FAIL=0
51 === selftest-research-first.sh rc=0 | Total: 12 PASS=12 FAIL=0
52 === selftest-review-library.sh rc=0 | Total: 15 PASS=15 FAIL=0
53 === selftest-root-resolution.sh rc=0 | Total: 17 PASS=17 FAIL=0
54 === selftest-rule23-conflict-scan.sh rc=0 | Total: 3 PASS=3 FAIL=0
55 === selftest-rule-reserve.sh rc=0 | Total: 10 PASS=10 FAIL=0
56 === selftest-self-resolution.sh rc=0 | Total: 13 PASS=13 FAIL=0
57 === selftest-shared-tracker.sh rc=0 | Total: 11 PASS=11 FAIL=0
58 === selftest-skill-collab.sh rc=0 | Total: 25  PASS=25  FAIL=0
59 === selftest-skill-modify.sh rc=0 | Total: 9 PASS=9 FAIL=0 (SKIP=0)
60 === selftest-skill-split.sh rc=0 | Total: 41  PASS=41  FAIL=0
61 === selftest-smart-merge.sh rc=0 | Total: 18 PASS=18 FAIL=0
62 === selftest-source-anchor-discipline.sh rc=0 | Total: 12 pass, 0 fail
63 === selftest-split-pattern-library.sh rc=0 | Total: 13 PASS=13 FAIL=0
64 === selftest-subagent-granularity-skill-escort.sh rc=0 | Total: 23 PASS=23 FAIL=0
65 === selftest-subagent-return.sh rc=0 | Total: 11 PASS=11 FAIL=0
66 === selftest-sync-index.sh rc=0 | Total: 13 PASS=13 FAIL=0
67 === selftest-task-boundary.sh rc=0 | Total: 11 PASS=11 FAIL=0
68 === selftest-template-lifecycle.sh rc=0 | Total: 24 PASS=24 FAIL=0
69 === selftest-template-sense.sh rc=0 | Total: 8 PASS=8 FAIL=0
70 === selftest-tier-b.sh rc=0 | Total: 18 PASS=18 FAIL=0
71 === selftest-tool-selection.sh rc=0 | Total: 12 PASS=12 FAIL=0
72 === selftest-user-instruction-priority.sh rc=0 | （无 Total 行；终行 `=== ALL PASS ===`，log:357）
73 === selftest-vc-gate.sh rc=0 | Total: 11 PASS=11 FAIL=0
74 === selftest-veto.sh rc=0 | Total: 13 PASS=13 FAIL=0
75 === selftest-workflow-orchestration.sh rc=0 | Total: 16 PASS=16 FAIL=0
rc≠0 段：空集（0 个）。
files: /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/plans/task-v164-pointer-worktree-local/regression-worktree-merged.log (+372/-0，新建)
evidence: regression-worktree-merged.log:1（首段 rc=0）; :368（末段 rc=0）; rc≠0 段行号清单=空集（grep -v rc=0 输出 EMPTY_SET）; :225（registry rows=75, actual selftest=75）; :356-357（user-instruction-priority rc=0 + ALL PASS）; FAIL=[1-9] 零命中（NO_FAIL_POSITIVE）; TRUNCATED=0; BATCH_START/END 22:41:22/22:44:09（终端输出）
checkpoint: /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/plans/task-v164-pointer-worktree-local/subagent-state/15-code-runner-agent.md (status: done)
findings_written: #### [sub:15-code-runner-agent] S11-r2 合并后态回归
blockers: none — 唯一偏差：派发口径 72 vs 实测全集 75（master 并入新增 3），已按全集全跑并在 checkpoint/findings 登记
confidence: HIGH
