# subagent-state / m5-executor

status: done  # 44/44 脚本全部执行完毕且逐条日志完整；回归非全绿（skill-split 1 FAIL），FAIL 明细与归因方向见下段，交主进程裁决

## 执行环境
- cwd: /mnt/data/dev/task-planner-skill-worktrees/task-v122（未切换，纯只读运行，仓库零写入）
- 命令: for f in skills/task-planner/scripts/selftest-*.sh; do echo "== $f"; timeout 60 bash "$f"; echo "rc=$?"; done
- 44 个脚本 = 43 基线 + 新增 selftest-media-dispatch.sh，全部执行完毕（无 >60s 跳过，rc=124 计数=0）

## 逐脚本结果（原文行保留，全文见 m5-executor-run.log）

| 脚本 | Total/结果行 | rc |
|------|--------------|----|
| selftest-active-plan.sh | Total: 19 PASS=19 FAIL=0 | 0 |
| selftest-ask-default-timeout.sh | Total: 9 PASS=9 FAIL=0 | 0 |
| selftest-batch-pilot.sh | Total: 10 PASS=10 FAIL=0 | 0 |
| selftest-check-conflicts.sh | Total: 7 PASS=7 FAIL=0 | 0 |
| selftest-check-drift.sh | Total: 6 PASS=6 FAIL=0 | 0 |
| selftest-conclusion-discipline.sh | Total: 24 PASS=24 FAIL=0 | 0 |
| selftest-context-hygiene.sh | Total: 12 PASS=12 FAIL=0 | 0 |
| selftest-delegation.sh | Total: 38    PASS=38  FAIL=0 | 0 |
| selftest-dispatch-grain.sh | Total: 10 PASS=10 FAIL=0 | 0 |
| selftest-dispatch.sh | Total: 31 PASS=31 FAIL=0 | 0 |
| selftest-error-loop.sh | Total: 16 PASS=16 FAIL=0 | 0 |
| selftest-execution-stability.sh | Total: 19  PASS=19  FAIL=0 | 0 |
| selftest-fallback.sh | Total: 31  PASS=31  FAIL=0 | 0 |
| selftest-final-gate-hash.sh | ==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ==== | 0 |
| selftest-fine-grain-steps.sh | Total: 11 PASS=11 FAIL=0 | 0 |
| selftest-interaction.sh | Total: 11 PASS=11 FAIL=0 | 0 |
| selftest-iterative-optimizer.sh | Total: 8 PASS=8 FAIL=0 | 0 |
| selftest-knowledge-brief.sh | Total: 16  PASS=16  FAIL=0 | 0 |
| selftest-mechanism-profile.sh | Total: 19 PASS=19 FAIL=0 | 0 |
| selftest-media-dispatch.sh | Total: 9 PASS=9 FAIL=0 | 0 |
| selftest-methodology.sh | Total: 16 PASS=16 FAIL=0 | 0 |
| selftest-plan-dispatch.sh | Total: 12 PASS=12 FAIL=0 | 0 |
| selftest-plan-tier.sh | Total: 32 PASS=32 FAIL=0 | 0 |
| selftest-reflect-verify.sh | Total: 12 PASS=12 FAIL=0 | 0 |
| selftest-registry.sh | Total: 5 PASS=5 FAIL=0 (registry rows=44, actual selftest=44) | 0 |
| selftest-reliability-institution.sh | Total: 12 PASS=12 FAIL=0 | 0 |
| selftest-rescue-chain.sh | Total: 11 PASS=11 FAIL=0 | 0 |
| selftest-review-library.sh | Total: 15 PASS=15 FAIL=0 | 0 |
| selftest-rule23-conflict-scan.sh | Total: 3 PASS=3 FAIL=0 | 0 |
| selftest-self-resolution.sh | Total: 13 PASS=13 FAIL=0 | 0 |
| selftest-shared-tracker.sh | Total: 11 PASS=11 FAIL=0 | 0 |
| selftest-skill-collab.sh | Total: 25  PASS=25  FAIL=0 | 0 |
| selftest-skill-modify.sh | Total: 9 PASS=9 FAIL=0 (SKIP=0) | 0 |
| selftest-skill-split.sh | Total: 41  PASS=40  FAIL=1 | 1 |
| selftest-smart-merge.sh | Total: 17 PASS=17 FAIL=0 | 0 |
| selftest-sync-index.sh | Total: 13 PASS=13 FAIL=0 | 0 |
| selftest-task-boundary.sh | Total: 11 PASS=11 FAIL=0 | 0 |
| selftest-template-lifecycle.sh | Total: 21 PASS=21 FAIL=0 | 0 |
| selftest-template-sense.sh | Total: 8 PASS=8 FAIL=0 | 0 |
| selftest-tier-b.sh | Total: 18 PASS=18 FAIL=0 | 0 |
| selftest-tool-selection.sh | Total: 12 PASS=12 FAIL=0 | 0 |
| selftest-vc-gate.sh | Total: 11 PASS=11 FAIL=0 | 0 |
| selftest-veto.sh | Total: 13 PASS=13 FAIL=0 | 0 |
| selftest-workflow-orchestration.sh | Total: 16 PASS=16 FAIL=0 | 0 |

## FAIL 明细（唯一 1 条）
- 脚本: selftest-skill-split.sh，rc=1，Total: 41 PASS=40 FAIL=1
- FAIL 行原文: `[FAIL] T-主 行数 ≤444（task-v112 交付总结模板指针+2 行;演进 440→442→444）且 ≤558 上限`
- 现场取证（只读）: `wc -l skills/task-planner/SKILL.md` = **447**（> 444 上限，≤558 硬上限未破）
- 归因方向（未验证，供主进程）: task-v122/Phase 2 commit 4bdfa4a「Rule 47 媒体制作派发纪律条款（47.1-47.4）+SKILL 路由表/摘要/references 联动（纯增量 +17/−1）」使 SKILL.md 越过 444 上限；selftest-skill-split.sh 的 444 上限断言在 Rule 47 增量落地时未同步演进。该脚本基线（Phase 1，43 脚本 676/0）时 444 尚满足——FAIL 由 Phase 2 Rule 47 增量引入，而非 S4 新增的 media-dispatch 脚本引入
- 新增脚本贡献: selftest-media-dispatch.sh Total: 9 PASS=9 FAIL=0（与 findings 摘要「预期 9 用例 FAIL=0」一致）；selftest-registry.sh 报 rows=44 / actual=44 与摘要一致
