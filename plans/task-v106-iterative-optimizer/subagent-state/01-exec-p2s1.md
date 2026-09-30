# Checkpoint: 01-exec-p2s1 (task-v106 P2-S1)

- status: done
- file_written: /mnt/data/dev/task-planner-skill-worktrees/task-v106-iterative-optimizer/skills/iterative-optimizer/SKILL.md
- line_count: 96 (within 90-120)
- frontmatter: 恰两字段 name=iterative-optimizer / description
- banned_words grep '更好|大致|应该|足够': NO_HIT
- 五步锚: evaluate=2, diagnose=2, improve=2, gate=2, 收敛 in Goal/Step4; Step0 锚 plans/loop-<task-id>-state.md x2
- 输入契约表: 含「≥3 条」「机器可检查」「max_iterations」「默认 5」
- 门控铁律 5 条 (3x P0 + 2x P1), 含「禁止」x4, PARTIAL 禁止宣称 RESOLVED 在位
- 摘要表头 改了什么/为什么/门控结果 + 结论三枚举 RESOLVED/PARTIAL/BLOCKED
- git status --short: 仅 `?? skills/iterative-optimizer/`
- git commit/add: 未执行
- 八锚: loop-based iterative mode(标题/Goal/目标段), prompt refinement/parameter tuning/defect correction(描述+触发), evaluate/identify weaknesses/apply targeted improvements/decide whether another round(五步), predefined quality criteria(Goal+契约), maximum iteration limit(Goal+契约 max_iterations), stable repeatable(目标段), what changed/why/resolved(摘要表+结论枚举) — 全部在位
- checkpoint: 本文件 (write 先于返回)
- next: verifier 独立复验 acceptance 7 条
