# P5-S2 任务书: registry 双落点登记 selftest-tool-selection（task-v097）

任务: worktree 内把 selftest-tool-selection.sh 登记进 selftest 双落点 registry 并复跑验证。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/task_plan.md（只读: VC-5 判定标准）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/findings.md（只读）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/progress.md（子代理禁写）

## 目标文件（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v097-tool-selection/skills/task-planner/scripts/ 下）
1. selftest-registry.tsv（当前 37 行=表头+36 数据行;追加 1 数据行）
2. selftest-registry.sh（如有行数断言/rows=actual 校验逻辑则同步;先 Read 该文件理解 T02 无缺失/T03 无孤儿口径）

## 操作内容
- tsv 新行四列对齐既有行格式（先 head -5 看表头与示例行）: script=selftest-tool-selection.sh / domain 按既有行风格（如 tool-selection） / trigger_scenarios 写「Rule 40 工具面主动选择;🧰 区块;/goal 对齐;零新 config 键」语义摘要 / dep_anchors 写「critical-rules.md ^40 锚;SKILL Rule 40×5;templates 🧰;mini-lite 豁免;plan-writer 义务行」摘要（以既有行实际列风格为准微调）
- selftest-registry.sh: 若存在硬编码行数/清单断言,按其口径同步（以 Read 实际逻辑为准,不臆造）

## acceptance: 验收标准
1) `grep -c 'selftest-tool-selection' selftest-registry.tsv` ≥1 且 tsv 行数=38（表头+37 数据行,`wc -l` 记录）
2) `bash selftest-registry.sh` Total 行 0 FAIL 且 rows=actual 一致
3) `bash selftest-tool-selection.sh` 复跑仍 12 PASS 0 FAIL
4) `git -C <wt> diff --stat` 本步仅 2 个 registry 文件（selftest-tool-selection.sh 为 S1 存量 untracked）

## checkpoint
完成前把结论与命令实际输出写入 /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/subagent-state/10-executor.md。禁 git commit/add。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P5-S2
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
