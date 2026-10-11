# checkpoint: sub:3-executor 回归验证
started: 2026-10-02
scope: 42 个 selftest-*.sh 全量运行 (worktree task-v109, Phase 2 已 commit 84b1dd5)
status: running
milestones:
milestone 5: 5/42 done
milestone: 42/42 done (2026-10-02)

# 最终结论
status: partial
acceptance: 1/4 pass — 42 行逐项原文见 subagent-state/3-executor-results.txt（41 rc=0, 1 rc=1; PASS=684 FAIL=1）
files: /mnt/data/dev/task-planner-skill/plans/task-v109/findings.md(+10, 追加 #### [sub:3-executor] 段); /mnt/data/dev/task-planner-skill/plans/task-v109/progress.md(+1, Phase 2 Actions 下追加 [sub:3] 行); /mnt/data/dev/task-planner-skill/plans/task-v109/subagent-state/3-executor-results.txt(+42 明细, 新建)
evidence: selftest-skill-split.sh:50 "T-迁 template-guide.md 含 16 个" → [FAIL] T-迁 template-guide.md 含 16 个 (Total: 41 PASS=40 FAIL=1); plan-template-kit/references/template-guide.md:32 worktree="17 个" vs 主仓基线="16 个"=Phase 2 级联遗漏
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v109/subagent-state/3-executor.md (status: partial)
findings_written: #### [sub:3-executor] 回归验证
blockers: selftest-skill-split.sh L50 断言硬编码 '16 个' 未纳入 Phase 2 16→17 级联清单 → 需修 1 行断言后复跑该脚本
confidence: HIGH
