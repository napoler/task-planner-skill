# P2-S2 checkpoint: selftest-iterative-optimizer.sh + registry 登记（task-v106）

- status: done
- time: 2026-10-01
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v106-iterative-optimizer

## files_written（仅 2 个目标文件）
1. /mnt/data/dev/task-planner-skill-worktrees/task-v106-iterative-optimizer/skills/task-planner/scripts/selftest-iterative-optimizer.sh（新建，IL-01..08）
2. /mnt/data/dev/task-planner-skill-worktrees/task-v106-iterative-optimizer/skills/task-planner/scripts/selftest-registry.tsv（EOF +1 行，4 列 TSV）

## 断言实测锚（动手前 Read S1 产出 96 行 SKILL.md 后核定）
- frontmatter name: iterative-optimizer = 1（head -5）；行数 96 ∈ [90,120]
- 评估 (evaluate)=1 / 诊断弱点 (diagnose=1 / 定向改进 (improve=1 / 门控判定 (gate=1
- plans/loop-<task-id>-state.md = 2；≥3 条=2 / 机器可检查=5 / max_iterations=6 / 默认 5=1
- 禁止宣称 RESOLVED=1 / 连续 2 轮=2；改了什么 (what)=1 / 为什么 (why=1 / 门控结果=4
- banned 词（更好|大致|应该|足够）= 0

## acceptance 复验输出（原文）
```
$ bash selftest-iterative-optimizer.sh
IL-01 PASS iterative-optimizer/SKILL.md 存在且 frontmatter「name: iterative-optimizer」=1
IL-02 PASS SKILL.md 行数 96 ∈ [90,120]
IL-03 PASS 五步锚在位（评估 1 / 诊断弱点 1 / 定向改进 1 / 门控判定 1, 各 ≥1）
IL-04 PASS 状态文件锚 plans/loop-<task-id>-state.md 行 2 ≥1
IL-05 PASS 输入契约锚在位（≥3 条 2 / 机器可检查 5 / max_iterations 6 / 默认 5 1, 各 ≥1）
IL-06 PASS 门控铁律在位（禁止宣称 RESOLVED=1 且 连续 2 轮 2 ≥1）
IL-07 PASS 迭代摘要表头在位（改了什么 (what) 1 / 为什么 (why 1 / 门控结果 4, 各 ≥1）
IL-08 PASS banned 词（更好/大致/应该/足够）命中 0
Total: 8 PASS=8 FAIL=0
exit=0
```
- bash -n 语法 OK；`grep -c '/home/terry' selftest-iterative-optimizer.sh` = 0（S75-D1 合规）
- registry 总行数 43（=42 脚本+表头，SR-12 动态口径咬合）；`grep -c 'selftest-iterative-optimizer' registry` = 1
- SR-12 动态复跑: `bash selftest-self-resolution.sh` → `SR-12 PASS registry selftest-self-resolution 登记行 ≥1 且总行数 43=脚本数+表头（动态）`，`Total: 12 PASS=12 FAIL=0` exit 0
- `git -C <wt> status --short`: `M skills/task-planner/scripts/selftest-registry.tsv` + `?? skills/task-planner/scripts/selftest-iterative-optimizer.sh`（新增 1 脚本 + M registry）；`?? skills/iterative-optimizer/` 为 S1 存量 untracked，非本阶段写入，未 add 未 commit（合规）

## next
P2-S2 完成，待主进程 Verifier 审查后推进下一阶段（合并回合约 §11.3 由主进程执行）。
