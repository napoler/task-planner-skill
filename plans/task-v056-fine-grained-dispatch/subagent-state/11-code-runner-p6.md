# Code Runner P6 — Verification Results

## Milestone 1: verify.sh
- Command: `TASK_PLANNER_ROOT=$W bash $W/lib/verify.sh 2>&1 | tail -25`
- Exit code: 1 (3 fails)
- Key output: "summary: 22 pass / 3 fail" + 3 deploy drift failures on claude-code/zcode/opencode full-copy SKILL.md

## Milestone 2: selftest-delegation.sh
- Command: `bash $W/scripts/selftest-delegation.sh 2>&1 | tail -15`
- Exit code: 0
- Key output: "Total: 35 PASS=35 FAIL=0"

## Milestone 3: selftest-fallback.sh
- Command: `bash $W/scripts/selftest-fallback.sh 2>&1 | tail -15`
- Exit code: 0
- Key output: "Total: 21 PASS=21 FAIL=0" (jq syntax warnings from JSON parsing, not test failures)

## Milestone 4: config.json validation
- Command: `jq empty $W/config.json && jq -c '.properties.subagent.default' $W/config.json`
- Exit code: 0
- Key output: All four keys present: step_max_files=2, step_max_lines=100, step_max_minutes=15, prompt_max_chars=3000

## Milestone 5: init-session template circulation
- Command: `rm -rf /tmp/v056-init-test && mkdir -p /tmp/v056-init-test && cd /tmp/v056-init-test && bash $W/scripts/init-session.sh 2>&1 | tail -5`
- Exit code: 0
- Key output: "5/5 planning files verified", created task_plan.md
- File count: 5 .md files generated in plans/task-v056-fine-grained-dispatch/
- S-unit hit: grep found "S-unit 派发单元表" twice in task_plan.md

## Milestone 6: rule text consistency
- Command chain:
  - `grep -c "拆细" $W/references/critical-rules.md` → **2** (expected ≥4 → FAIL)
  - `grep -c "五档兜底" $W/SKILL.md` → **1** (expected =1 → PASS)
  - `wc -l < $W/SKILL.md` → **500** (expected =500 → PASS)
  - `grep -c "S-unit" $W/companion/agents/plan-writer.md` → **7** (expected ≥7 → PASS)
  - `grep -c '^## 9. 上下文预算' $W/templates/subagent_dispatch.md` → **1** (expected =1 → PASS)

---

## Final Conclusions

| # | Test | Result | Details |
|---|------|--------|---------|
| 1 | verify.sh | **FAIL** | 22 pass / 3 fail — claude-code/zcode/opencode deploy drift detected |
| 2 | selftest-delegation.sh | **PASS** | 35/35 pass, exit 0 |
| 3 | selftest-fallback.sh | **PASS** | 21/21 pass, exit 0 |
| 4 | config.json jq | **PASS** | All 4 keys present, valid JSON |
| 5 | init-session template | **PASS** | 5 files generated, S-unit table present (count=2) |
| 6 | rule text checks | **PARTIAL FAIL** | "拆细" count=2 (needs ≥4), other 4 counts OK |

**Overall: 4 PASS / 2 FAIL** (1 partial fail due to low "拆细" occurrence count)
