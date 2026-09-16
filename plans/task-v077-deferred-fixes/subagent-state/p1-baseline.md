# P1 Baseline — All 20 Selftest Scripts
Run: worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v077-deferred-fixes`
Working dir: `skills/task-planner/scripts/`
Command per script: `timeout 120 bash "$f" >/tmp/v077-base-$f.log 2>&1; echo "rc=$? $f"; grep -E '^Total:' /tmp/v077-base-$f.log`
Date: 2026-09-17

| 脚本名 | rc | Total 原文行 |
|---|---|---|
| selftest-active-plan.sh | 0 | Total: 19 PASS=19 FAIL=0 |
| selftest-conclusion-discipline.sh | 0 | Total: 17 PASS=17 FAIL=0 |
| selftest-context-hygiene.sh | 0 | Total: 12 PASS=12 FAIL=0 |
| selftest-delegation.sh | 0 | Total: 38    PASS=38  FAIL=0 |
| selftest-dispatch.sh | 0 | Total: 22 PASS=22 FAIL=0 |
| selftest-error-loop.sh | 0 | Total: 16 PASS=16 FAIL=0 |
| selftest-execution-stability.sh | 0 | Total: 17  PASS=17  FAIL=0 |
| selftest-fallback.sh | 0 | Total: 31  PASS=31  FAIL=0 |
| selftest-interaction.sh | 0 | Total: 11 PASS=11 FAIL=0 |
| selftest-knowledge-brief.sh | 0 | Total: 16  PASS=16  FAIL=0 |
| selftest-methodology.sh | 0 | Total: 11 PASS=11 FAIL=0 |
| selftest-plan-dispatch.sh | 0 | Total: 12 PASS=12 FAIL=0 |
| selftest-reflect-verify.sh | 0 | Total: 12 PASS=12 FAIL=0 |
| selftest-rescue-chain.sh | 0 | Total: 11 PASS=11 FAIL=0 |
| selftest-shared-tracker.sh | 0 | Total: 11 PASS=11 FAIL=0 |
| selftest-skill-collab.sh | 0 | Total: 19  PASS=19  FAIL=0 |
| selftest-smart-merge.sh | 0 | Total: 14 PASS=14 FAIL=0 |
| selftest-template-lifecycle.sh | 0 | Total: 17 PASS=17 FAIL=0 |
| selftest-vc-gate.sh | 0 | Total: 11 PASS=11 FAIL=0 |
| selftest-veto.sh | 0 | Total: 13 PASS=13 FAIL=0 |

**Summary**: 20/20 scripts passed (rc=0). Total PASS across all scripts = 330, FAIL = 0.
