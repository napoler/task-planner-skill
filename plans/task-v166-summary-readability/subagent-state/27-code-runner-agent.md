# 27-code-runner-agent — v166 并集态全量 selftest 回归

## T1 里程碑 [2026-10-11 14:49:31]
- 并集态实锤: grep -c '1-77' SKILL.md = 3 命中（行9/308/399）；selftest-proactive-research.sh 在位（6329B）
- 全量跑批: selftest-*.sh 实测 77 个，全部执行；76 个 rc=0，1 个 rc=1（selftest-parallel-scheduling.sh P-05）
- registry 对照: registry rows=77 = actual selftest=77（selftest-registry.sh PASS）
- 只读约束: 无任何文件修改、无 git 写操作（git show 均为只读查询）

## 本实例复核记录 [2026-10-11 15:06:16 CST]
- 来源：27-code-runner-agent 于 worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v166-summary-readability` 独立重跑全量 77 脚本（Step1 `grep -c '1-77' SKILL.md`=3、`selftest-proactive-research.sh` 在位实锤；Step2 `for f in skills/task-planner/scripts/selftest-*.sh; do bash "$f"; done`；口径核对：段头数=77 / rc 行数=77 / `ls selftest-*.sh`=77 / registry rows=77 四方一致）。
- 结果与上文 T1/T5 逐字一致：76 个 rc=0；唯一 rc=1 = selftest-parallel-scheduling.sh (P-05 FAIL: 上界 skill=77 vs critical=76)；点名三脚本 Total 行原文与 §点名三脚本段一致。
- FAIL_DETAIL 误匹配排除：grep 'FAIL' 命中中 IP-08 / RR-10 / SM-06 三行均为 PASS 断言说明文字含 "FAIL" 字样，非失败。
- 只读约束遵守：跑批日志仅落 /tmp/v166-full-selftest.log（本 Edit 外，无任何 worktree/项目文件与 git 写操作）。

## 逐行清单（77 脚本：rc | Total 行原文）
- selftest-absorption-discipline.sh rc=0 dur=0s total=[Total: 14 pass, 0 fail, 0 skip]
- selftest-active-plan.sh rc=0 dur=7s total=[Total: 29 PASS=29 FAIL=0]
- selftest-agent-coverage.sh rc=0 dur=0s total=[Total: 9 PASS=9 FAIL=0 SKIPPED=0]
- selftest-ask-default-timeout.sh rc=0 dur=0s total=[Total: 11 PASS=11 FAIL=0]
- selftest-batch-pilot.sh rc=0 dur=0s total=[Total: 10 PASS=10 FAIL=0]
- selftest-capability-persistence.sh rc=0 dur=2s total=[Total: 20 PASS=20 FAIL=0]
- selftest-check-conflicts.sh rc=0 dur=1s total=[Total: 7 PASS=7 FAIL=0]
- selftest-check-drift.sh rc=0 dur=2s total=[Total: 6 PASS=6 FAIL=0]
- selftest-conclusion-discipline.sh rc=0 dur=1s total=[Total: 24 PASS=24 FAIL=0]
- selftest-context-hygiene.sh rc=0 dur=0s total=[Total: 12 PASS=12 FAIL=0]
- selftest-context-pressure.sh rc=0 dur=0s total=[Total: 9 PASS=9 FAIL=0]
- selftest-decision-arbiter.sh rc=0 dur=0s total=[Total: 16 PASS=16 FAIL=0]
- selftest-decision-drift.sh rc=0 dur=0s total=[Total: 23 PASS=23 FAIL=0]
- selftest-decision-grading.sh rc=0 dur=1s total=[Total: PASS=12 FAIL=0 WARN=0]
- selftest-delegation.sh rc=0 dur=3s total=[Total: 38    PASS=38  FAIL=0]
- selftest-dispatch-grain.sh rc=0 dur=2s total=[Total: 10 PASS=10 FAIL=0]
- selftest-dispatch.sh rc=0 dur=7s total=[Total: 31 PASS=31 FAIL=0]
- selftest-drift-check-subagent.sh rc=0 dur=1s total=[Total: 20 PASS=20 FAIL=0]
- selftest-drift-enforcement.sh rc=0 dur=14s total=[Total: 23 PASS=23 FAIL=0]
- selftest-error-fix-prompt-forge.sh rc=0 dur=0s total=[Total: 8 PASS=8 FAIL=0]
- selftest-error-loop.sh rc=0 dur=0s total=[Total: 16 PASS=16 FAIL=0]
- selftest-evidence-goal-gate.sh rc=0 dur=0s total=[Total: 21 PASS=21 FAIL=0]
- selftest-execution-honesty.sh rc=0 dur=1s total=[Total: 14 PASS=14 FAIL=0]
- selftest-execution-stability.sh rc=0 dur=2s total=[Total: 19  PASS=19  FAIL=0]
- selftest-fallback.sh rc=0 dur=2s total=[Total: 31  PASS=31  FAIL=0]
- selftest-final-gate-hash.sh rc=0 dur=18s total=[]
- selftest-fine-grain-steps.sh rc=0 dur=3s total=[Total: 11 PASS=11 FAIL=0]
- selftest-four-file-dataflow.sh rc=0 dur=0s total=[Total: 18 PASS=18 FAIL=0]
- selftest-goal-unit-goal-mode.sh rc=0 dur=0s total=[Total: 9 PASS=9 FAIL=0]
- selftest-interaction.sh rc=0 dur=1s total=[Total: 11 PASS=11 FAIL=0]
- selftest-iteration-persistence.sh rc=0 dur=0s total=[Total: 18 PASS=18 FAIL=0]
- selftest-iterative-optimizer.sh rc=0 dur=0s total=[Total: 8 PASS=8 FAIL=0]
- selftest-knowledge-brief.sh rc=0 dur=1s total=[Total: 16  PASS=16  FAIL=0]
- selftest-lane-advancement.sh rc=0 dur=0s total=[Total: 14 PASS=14 FAIL=0]
- selftest-mechanism-profile.sh rc=0 dur=4s total=[Total: 19 PASS=19 FAIL=0]
- selftest-media-agents.sh rc=0 dur=0s total=[Total: 10 PASS=10 FAIL=0]
- selftest-media-dispatch.sh rc=0 dur=0s total=[Total: 9 PASS=9 FAIL=0]
- selftest-methodology.sh rc=0 dur=1s total=[Total: 16 PASS=16 FAIL=0]
- selftest-parallel-scheduling.sh rc=1 dur=1s total=[Total: 9 PASS=8 FAIL=1]
- selftest-periodic-review.sh rc=0 dur=0s total=[Total: 10 PASS=10 FAIL=0]
- selftest-plan-dispatch.sh rc=0 dur=2s total=[Total: 12 PASS=12 FAIL=0]
- selftest-plan-tier.sh rc=0 dur=12s total=[Total: 32 PASS=32 FAIL=0]
- selftest-pointer-lifecycle.sh rc=0 dur=1s total=[Total: 10 PASS=10 FAIL=0]
- selftest-proactive-research.sh rc=0 dur=0s total=[Total: 15 PASS=15 FAIL=0]
- selftest-reflect-verify.sh rc=0 dur=0s total=[Total: 12 PASS=12 FAIL=0]
- selftest-registry.sh rc=0 dur=0s total=[Total: 5 PASS=5 FAIL=0 (registry rows=77, actual selftest=77)]
- selftest-reliability-institution.sh rc=0 dur=0s total=[Total: 16 PASS=16 FAIL=0]
- selftest-report-reviewability.sh rc=0 dur=1s total=[Total: PASS=13 FAIL=0 WARN=0]
- selftest-requirement-coverage.sh rc=0 dur=13s total=[Total: 23 PASS=23 FAIL=0]
- selftest-requirement-grading.sh rc=0 dur=0s total=[Total: 7 PASS=7 FAIL=0]
- selftest-rescue-chain.sh rc=0 dur=1s total=[Total: 11 PASS=11 FAIL=0]
- selftest-research-first.sh rc=0 dur=0s total=[Total: 12 PASS=12 FAIL=0]
- selftest-review-library.sh rc=0 dur=1s total=[Total: 15 PASS=15 FAIL=0]
- selftest-root-resolution.sh rc=0 dur=1s total=[Total: 17 PASS=17 FAIL=0]
- selftest-rule23-conflict-scan.sh rc=0 dur=1s total=[Total: 3 PASS=3 FAIL=0]
- selftest-rule-reserve.sh rc=0 dur=0s total=[Total: 10 PASS=10 FAIL=0]
- selftest-self-resolution.sh rc=0 dur=1s total=[Total: 13 PASS=13 FAIL=0]
- selftest-shared-tracker.sh rc=0 dur=0s total=[Total: 11 PASS=11 FAIL=0]
- selftest-skill-collab.sh rc=0 dur=0s total=[Total: 25  PASS=25  FAIL=0]
- selftest-skill-modify.sh rc=0 dur=0s total=[Total: 9 PASS=9 FAIL=0 (SKIP=0)]
- selftest-skill-split.sh rc=0 dur=1s total=[Total: 41  PASS=41  FAIL=0]
- selftest-smart-merge.sh rc=0 dur=9s total=[Total: 18 PASS=18 FAIL=0]
- selftest-source-anchor-discipline.sh rc=0 dur=1s total=[Total: 12 pass, 0 fail]
- selftest-split-pattern-library.sh rc=0 dur=0s total=[Total: 13 PASS=13 FAIL=0]
- selftest-subagent-granularity-skill-escort.sh rc=0 dur=0s total=[Total: 23 PASS=23 FAIL=0]
- selftest-subagent-return.sh rc=0 dur=1s total=[Total: 11 PASS=11 FAIL=0]
- selftest-summary-readability.sh rc=0 dur=15s total=[Total: PASS=13 FAIL=0 WARN=0]
- selftest-sync-index.sh rc=0 dur=0s total=[Total: 13 PASS=13 FAIL=0]
- selftest-task-boundary.sh rc=0 dur=0s total=[Total: 11 PASS=11 FAIL=0]
- selftest-template-lifecycle.sh rc=0 dur=1s total=[Total: 24 PASS=24 FAIL=0]
- selftest-template-sense.sh rc=0 dur=4s total=[Total: 8 PASS=8 FAIL=0]
- selftest-tier-b.sh rc=0 dur=2s total=[Total: 18 PASS=18 FAIL=0]
- selftest-tool-selection.sh rc=0 dur=0s total=[Total: 12 PASS=12 FAIL=0]
- selftest-user-instruction-priority.sh rc=0 dur=0s total=[]
- selftest-vc-gate.sh rc=0 dur=17s total=[Total: 11 PASS=11 FAIL=0]
- selftest-veto.sh rc=0 dur=0s total=[Total: 13 PASS=13 FAIL=0]
- selftest-workflow-orchestration.sh rc=0 dur=0s total=[Total: 16 PASS=16 FAIL=0]

## FAIL 明细
- **selftest-parallel-scheduling.sh rc=1，断言 P-05 FAIL**
  - 原文: `P-05 FAIL SKILL.md C46=1（应 =1）/ Rule 68 引用=2（应 ≥1）/ 上界 skill=77 vs critical=76（应相等）`
  - 根因（只读 git 验证）: worktree SKILL.md 上界枚举=1-77（2 处 'Critical Rules 1-77'），references/critical-rules.md 实测最大章节=76（## Rule 76）；worktree 全 skill 目录 'Rule 77' 文本 0 命中；master 侧两者一致=1-75（master 无 'Rule 77'）。→ SKILL 枚举面与条款面漂移（P-05 动态对照断言设计意图即捕获此漂移）。
- 其余 76 脚本: FAIL 明细无。

## 点名三脚本输出行原文（在档）
- selftest-summary-readability.sh rc=0: `Total: PASS=13 FAIL=0 WARN=0`（SRV-01..13 全 PASS）
- selftest-proactive-research.sh rc=0: `Total: 15 PASS=15 FAIL=0`（v163 并入脚本）
- selftest-registry.sh rc=0: `Total: 5 PASS=5 FAIL=0 (registry rows=77, actual selftest=77)`

## 无标准 Total 行脚本的等效汇总行原文（2 个）
- selftest-final-gate-hash.sh rc=0: `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`
- selftest-user-instruction-priority.sh rc=0: `=== ALL PASS ===`

## T5 最终结论 [2026-10-11 14:49:31]
```
status: done
acceptance: 3/3 pass — [1:PASS 2:PASS 3:PASS]
files: none
evidence: grep -c '1-77' SKILL.md→3; 全量 bash selftest-*.sh 77 脚本→76 rc=0 + selftest-parallel-scheduling.sh rc=1 (P-05 FAIL: 上界 skill=77 vs critical=76); selftest-summary-readability.sh→Total: PASS=13 FAIL=0 WARN=0; selftest-proactive-research.sh→Total: 15 PASS=15 FAIL=0; selftest-registry.sh→Total: 5 PASS=5 FAIL=0 (registry rows=77, actual selftest=77)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v166-summary-readability/subagent-state/27-code-runner-agent.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
```
