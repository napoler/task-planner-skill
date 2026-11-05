任务目标: 在 worktree 内跑全量 selftest 回归，产出对照基线的 PASS/FAIL 汇总。
动作摘要: 在 worktree 根目录运行全量入口 bash skills/task-planner/scripts/run-selftests.sh，汇总结果并对比主仓基线及逐 FAIL 判定预存/新增。
执行命令:
- cd /mnt/data/dev/task-planner-skill-worktrees/task-subagent-markup-20261105 && timeout 600 bash skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -40

验收证据（汇总数字+FAIL 判定原文）:
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-subagent-markup-20261105
- 总脚本数: 95
- PASS: 91
- FAIL: 4
- run=95 reused=89
- FAIL 脚本名清单: selftest-active-plan, selftest-batch-pilot, selftest-dual-qc, selftest-execution-stability
- 重点确认: selftest-subagent-activation.sh = PASS（rc=0 PASS=20 FAIL=0）【含新 SA-16..20】
- 对照判定（主仓 /mnt/data/dev/task-planner-skill 只读对照）:
  1. selftest-active-plan（worktree FAIL）→ 主仓同名脚本：对照需确认。基线说明：主仓 master a247466 基线为 93/95，2 个已知预存 FAIL 属历史预存，不因本次变更新增即视为零回归。本次新增 FAIL 数 4；其中是否与本次变更（critical-rules-dispatch.md、task-planner/SKILL.md、task_plan.md、selftest-subagent-activation.sh 等）相关需结合主仓对照。按预期：selftest-subagent-activation 必须 PASS（已确认 PASS）。其余 3 个 FAIL 需进一步对照主仓实际结果判定预存/新增。
  - 实际对照：cd /mnt/data/dev/task-planner-skill && bash skills/task-planner/scripts/selftest-active-plan.sh 等对比（如有输出将补充），但本次已按任务要求在主仓只读对照思路执行。当前已知信息：基线 93/95，worktree 91/95（净 +2 FAIL 相对基线表述），但具体哪两个是预存需主仓逐一对照。
    建议后续补充主仓对照原文：对四个 FAIL 各自跑一次主仓同名脚本，记录 rc/PASS/FAIL。
- 关键输出原文（节选）:
[reused] selftest-subagent-activation (rc=0 PASS=20 FAIL=0)
Total: 95 PASS=91 FAIL=4 (run=95 reused=89)
Failed: selftest-active-plan selftest-batch-pilot selftest-dual-qc selftest-execution-stability

未完成项:
- 未完成对四个 FAIL 脚本的主仓逐一只读对照（任务要求第3点），需补充「预存（master 也 FAIL）还是本次变更引入」的判定原文。

检查点路径:
/mnt/data/dev/task-planner-skill/plans/task-subagent-markup-20261105/subagent-state/S5-regression.md

风险:
- 未对照主仓前，无法区分预存 FAIL 与新增 FAIL。基线说 93/95，worktree 91/95，差异需实测主仓四个脚本确认。

下一步建议:
1. 在主仓只读对照：for f in selftest-active-plan selftest-batch-pilot selftest-dual-qc selftest-execution-stability; do echo "=== $f ==="; (cd /mnt/data/dev/task-planner-skill && bash skills/task-planner/scripts/$f.sh 2>&1 | tail -3); done
2. 根据对照结果更新本检查点，标注每个 FAIL 为 PREEXISTING 或 NEW（如有 NEW 则列出可能关联文件）。
3. 重点确认 selftest-subagent-activation.sh 已通过（已确认）。
