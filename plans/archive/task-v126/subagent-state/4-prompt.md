# S4 任务书：全量 selftest 回归（task-v126 Phase 4）

你是 task-v126 计划 S-unit S4 执行体。任务：在 worktree 内跑全量 selftest 回归并回报汇总。

## 路径与口径
- 回归对象：/home/terry/task-planner-skill-worktrees/task-v126/skills/task-planner/scripts/selftest-*.sh 全集（当前应 45 个，含新建 selftest-lane-advancement.sh）
- 基线对比（Phase 1）：44 脚本 666 PASS / 0 FAIL；本回归预期：45 脚本、PASS=666+14=680 / FAIL=0
- 统计口径：逐脚本跑，取每个脚本输出的末行 `Total: N PASS=N FAIL=N` 中 PASS=/FAIL= 数值求和（禁止 grep 空格模式误抓——格式是 `PASS=数字`，等号后才是真值）
- 循环写法参照（可直接用）：
  cd /home/terry/task-planner-skill-worktrees/task-v126/skills/task-planner/scripts 后 for f in selftest-*.sh 循环 bash "$f"，用 sed -E 's/.*PASS=([0-9]+).*/\1/' 与 's/.*FAIL=([0-9]+).*/\1/' 从 Total 行提取，累加；记录 FAIL>0 或 exit 非 0 的脚本名
- 你的检查点：/mnt/data/dev/task-planner-skill/plans/task-v126/subagent-state/4-code-runner-agent.md（结果落盘）
- 禁止修改任何文件（只读回归）

## 回报要求
- 汇总行：脚本数 / 总 PASS / 总 FAIL / FAIL 脚本清单（无则 none）
- 与预期对比结论：45 脚本 680/0 是否达成
- 若有 FAIL：贴该脚本 FAIL 行原文（不自行修复——回主进程裁决）
- 按八字段模板返回（status:/summary:/files_changed:无/acceptance:/evidence:/issues:/checkpoint:/next:）

## 背景（只读对齐）
- 计划：/mnt/data/dev/task-planner-skill/plans/task-v126/task_plan.md
- 发现：/mnt/data/dev/task-planner-skill/plans/task-v126/findings.md
- 进度：/mnt/data/dev/task-planner-skill/plans/task-v126/progress.md（Phase 1 基线段）
