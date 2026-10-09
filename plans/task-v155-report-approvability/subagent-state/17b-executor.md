# S17b executor — SKILL.md 行数上界钉 515→540（worktree 内两 selftest 脚本）

## 最终结论
status: done
acceptance: 4/4 pass — [1:PASS `bash scripts/selftest-skill-split.sh` → `Total: 41  PASS=41  FAIL=0` exit=0; 2:PASS `bash scripts/selftest-goal-unit-goal-mode.sh` → `Total: 9 PASS=9 FAIL=0` exit=0; 3:PASS `grep -c 540` split=3 goal=5（各 ≥2）; 4:PASS SKILL.md=`wc -l`=518 ≤540 逻辑成立]
files: /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/selftest-skill-split.sh(+2/-1); /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/selftest-goal-unit-goal-mode.sh(+5/-5)
evidence: selftest-skill-split.sh:48 → `t "T-主 行数 ≤540（…）…-le 540…"`；跑批末行 `Total: 41  PASS=41  FAIL=0`; selftest-goal-unit-goal-mode.sh:129 → `G-09 PASS SKILL.md 行数=518 ≤540（task-v155 上调后上限，Rule 70 接线 +7 触顶，留余量）`
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/subagent-state/17b-executor.md (status: done)
findings_written: ## Research Findings 段末 `#### [sub:17b-executor] SKILL.md 行数钉上调 515→540（worktree 两 selftest 守卫）`
blockers: none
confidence: HIGH

## 动作明细
- 基线复现（改前）：SKILL.md=518 行；split `Total: 41 PASS=40 FAIL=1`（T-主 ≤515）；goal-mode `Total: 9 PASS=8 FAIL=1`（G-09 518>515）。
- split 脚本：新增注释行 `# [2026-10-10 task-v155 S17b 合并级联] Rule 70 接线净 +7（511→518），钉随演进上调 515→540（留 22 行余量…；≤558 总上限不动）`；断言行 `T-主 行数 ≤515` → `≤540`、`-le 515` → `-le 540`（保留既有演进史文字与 ≤558 上限不动）。
- goal-mode 脚本：G-09 段注释（头部第 26 行 + 段内 What/Why）与 `if [ "$n" -le 515 ]`、ok/bad 文案同步改 540；ok 文案 =「≤540（task-v155 上调后上限，Rule 70 接线 +7 触顶，留余量）」。
- 改后自跑：两脚本 exit=0，Total FAIL=0；`grep -c 540` split=3 / goal=5。
- 未触碰 G-07（17a 已修）及其余断言行；未做任何 git 写操作。

## 约束遵守
- 仅改 scope 内两脚本；未 git add/commit/checkout/reset/push；未碰其他 worktree。
