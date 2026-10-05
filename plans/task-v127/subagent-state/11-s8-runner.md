# S8 checkpoint — 全量 selftest 回归
task: task-v127 / S8 (code-runner-agent → executor 改派)
worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v127
started: 2026-10-04
status: done

## 执行记录
循环形态: for f in selftest-*.sh; do timeout 120 bash "$f"; done（worktree skills/task-planner/scripts/，46 脚本全跑，未切换 CWD）
逐脚本 rc + Total 行原文（留痕）：
selftest-active-plan.sh | rc=0 | Total: 19 PASS=19 FAIL=0
selftest-ask-default-timeout.sh | rc=0 | Total: 9 PASS=9 FAIL=0
selftest-batch-pilot.sh | rc=0 | Total: 10 PASS=10 FAIL=0
selftest-check-conflicts.sh | rc=0 | Total: 7 PASS=7 FAIL=0
selftest-check-drift.sh | rc=0 | Total: 6 PASS=6 FAIL=0
selftest-conclusion-discipline.sh | rc=0 | Total: 24 PASS=24 FAIL=0
selftest-context-hygiene.sh | rc=0 | Total: 12 PASS=12 FAIL=0
selftest-delegation.sh | rc=0 | Total: 38    PASS=38  FAIL=0
selftest-dispatch-grain.sh | rc=0 | Total: 10 PASS=10 FAIL=0
selftest-dispatch.sh | rc=0 | Total: 31 PASS=31 FAIL=0
selftest-error-loop.sh | rc=0 | Total: 16 PASS=16 FAIL=0
selftest-execution-stability.sh | rc=0 | Total: 19  PASS=19  FAIL=0
selftest-fallback.sh | rc=0 | Total: 31  PASS=31  FAIL=0
selftest-final-gate-hash.sh | rc=0 | (no Total line found)
selftest-fine-grain-steps.sh | rc=0 | Total: 11 PASS=11 FAIL=0
selftest-interaction.sh | rc=0 | Total: 11 PASS=11 FAIL=0
selftest-iterative-optimizer.sh | rc=0 | Total: 8 PASS=8 FAIL=0
selftest-knowledge-brief.sh | rc=0 | Total: 16  PASS=16  FAIL=0
selftest-lane-advancement.sh | rc=0 | Total: 14 PASS=14 FAIL=0
selftest-mechanism-profile.sh | rc=0 | Total: 19 PASS=19 FAIL=0
selftest-media-dispatch.sh | rc=0 | Total: 9 PASS=9 FAIL=0
selftest-methodology.sh | rc=0 | Total: 16 PASS=16 FAIL=0
selftest-plan-dispatch.sh | rc=0 | Total: 12 PASS=12 FAIL=0
selftest-plan-tier.sh | rc=0 | Total: 32 PASS=32 FAIL=0
selftest-reflect-verify.sh | rc=0 | Total: 12 PASS=12 FAIL=0
selftest-registry.sh | rc=0 | Total: 5 PASS=5 FAIL=0 (registry rows=46, actual selftest=46)
selftest-reliability-institution.sh | rc=0 | Total: 12 PASS=12 FAIL=0
selftest-requirement-grading.sh | rc=0 | Total: 7 PASS=7 FAIL=0
selftest-rescue-chain.sh | rc=0 | Total: 11 PASS=11 FAIL=0
selftest-review-library.sh | rc=0 | Total: 15 PASS=15 FAIL=0
selftest-rule23-conflict-scan.sh | rc=0 | Total: 3 PASS=3 FAIL=0
selftest-self-resolution.sh | rc=0 | Total: 13 PASS=13 FAIL=0
selftest-shared-tracker.sh | rc=0 | Total: 11 PASS=11 FAIL=0
selftest-skill-collab.sh | rc=0 | Total: 25  PASS=25  FAIL=0
selftest-skill-modify.sh | rc=0 | Total: 9 PASS=9 FAIL=0 (SKIP=0)
selftest-skill-split.sh | rc=1 | Total: 41  PASS=40  FAIL=1
selftest-smart-merge.sh | rc=0 | Total: 17 PASS=17 FAIL=0
selftest-sync-index.sh | rc=0 | Total: 13 PASS=13 FAIL=0
selftest-task-boundary.sh | rc=0 | Total: 11 PASS=11 FAIL=0
selftest-template-lifecycle.sh | rc=0 | Total: 24 PASS=24 FAIL=0
selftest-template-sense.sh | rc=0 | Total: 8 PASS=8 FAIL=0
selftest-tier-b.sh | rc=0 | Total: 18 PASS=18 FAIL=0
selftest-tool-selection.sh | rc=0 | Total: 12 PASS=12 FAIL=0
selftest-vc-gate.sh | rc=0 | Total: 11 PASS=11 FAIL=0
selftest-veto.sh | rc=0 | Total: 13 PASS=13 FAIL=0
selftest-workflow-orchestration.sh | rc=0 | Total: 16 PASS=16 FAIL=0

## 格式说明（机械求和注意）
- selftest-final-gate-hash.sh 的统计行非标准 "Total:" 前缀，原文为：
  `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`
  该脚本 rc=0，22 PASS 0 FAIL；主进程求和时须计入此行（否则漏 22）
- 其余 45 脚本均为 "Total: N PASS=N FAIL=0" 形态（个别含 SKIP=0 尾注）

## 统计行（机械累加自上述逐脚本行，独立复核两次一致）
- 脚本总数: 46（45 既有 + 1 新建 selftest-final-gate-hash，与 registry.tsv 行数=46 一致）
- 有 "Total:" 标准行: 45（其中 44 条 FAIL=0，skill-split 1 条 FAIL=1）；非标结果行: 1（final-gate-hash）
- PASS 总数: 45 个标准 Total 行机械累加 = 686，加 final-gate-hash 22 = **708**
- FAIL 总数（首跑轮）: 45 标准行累加 = 1（仅 skill-split 单条断言），final-gate-hash FAIL=0；FAIL=0 的脚本 45/46，非 0 脚本仅 skill-split
- 对照基线: 预期 709（v126 702 + 新脚本 7）；实测 708 = 709 - 1，缺口恰为 skill-split 锚断言 1 条；锚修至 450 后该脚本 PASS=41，合计即达 709

## 失败脚本定位（§3-2 单独重跑）
- selftest-skill-split.sh（rc=1，Total: 41 PASS=40 FAIL=1）单独重跑复现，FAIL 唯一：
  原文: `[FAIL] T-主 行数 ≤449（task-v126 Rule 49 联动 +2;演进 440→442→444→447→449）且 ≤558 上限`
  根因: worktree skills/task-planner/SKILL.md 实际 450 行（wc -l = 450）> 锚定上限 449，断言 `-le 449` 不过；558 钉上限未破
  判定: **锚过窄**（task-v127 对 SKILL.md 演进使行数 449→450，断言锚未联动 +1），非内容越界
  处置: 未改任何文件（§4 禁改）；报告主进程裁决（v121 宽容化：锚 449→450 联动，与 task-v126 Rule 49 联动 +2 同机制）
- 其余 45 脚本 rc=0 且 FAIL=0，无需重跑

## 最终结论（8 字段块）
status: done
acceptance: 3/3 pass — [1:PASS 逐脚本循环 46/46 已跑，rc+Total 行逐条留痕于上方，汇总数字由主进程机械求和（本 checkpoint 统计行标注累加来源供核对）][2:PASS 唯一失败 skill-split 已单独重跑定位=锚过窄（SKILL.md 450 行 > 锚 449），报告主进程裁决，未改任何文件][3:PASS 统计行已输出于 checkpoint「统计行」段：脚本总数 / PASS 总数 / FAIL 总数（机械累加自逐脚本 Total 行，两次独立复核一致）]
files: none
evidence: 见上方逐脚本 46 行 rc+Total 留痕 + 统计行 + final-gate-hash 非标行原文
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/11-s8-runner.md (status: done)
findings_written: none
blockers: none | skill-split 锚 449 过窄（实际 450）属 v121 宽容化裁决项，预期 FAIL=0 目标因 1 条断言未达，非回归性失败
confidence: HIGH
