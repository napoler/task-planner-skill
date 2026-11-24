目标：在worktree（/mnt/data/dev/task-planner-skill/tmp/worktrees/task-goal-unattended-protocol-20261124）内按编辑规格对指定文件逐条落地 E29、E30（S19），零偏差。

输入（计划三文件）：
- /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/task_plan.md（只读，对齐 Goal/VC/Scope；状态由主进程翻转，禁改）
- /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/findings.md（可读；仅可追加自己的小节）
- /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/progress.md（可读；仅可追加）
- 同目录 edit-spec.md：唯一施工依据；本单元只做末节「对齐核查补出的引用面与断言面同步」里的 E29、E30 两条，并先遵守「通用纪律」五条。
- 同目录 plan-brief.md：§A 为用户已批准计划，仅作对齐；§B 的 D-13 是本单元背景（用户裁决对齐 GLM-5.4 + max，断言随 frontmatter 锁步、强度不变）。施工细节一律以 edit-spec.md 为准。
- findings 摘要：E30 是把既有断言的锚从 GLM-5.3 改到 GLM-5.4，不是新增断言；规格未点名的行必须零改动。

验收标准：
- E29：agent-coverage.md 第 40 行 decision-arbiter 的字样改为「GLM-5.4 强档 max」；第 13、30 行 complex-planner 的 GLM-5.3 字样不动。
- E30：DA-02 的 What 注释行改为 GLM-5.4，其后新增规格给出的两行注释（逐字）；断言行改为 grep GLM-5.4，ok/bad 文案与规格逐字一致；Why 注释行与其余所有行不动；文件 109 行变 111 行。
- bash -n 通过；在 worktree 根执行 bash skills/task-planner/scripts/selftest-decision-arbiter.sh，把原始输出的汇总行贴进 evidence（预期全 PASS）。
- 回执 evidence 逐条列 E 编号、文件、改后行号。并贴 git diff --stat 原始行。

Scope 禁改清单：只改 /mnt/data/dev/task-planner-skill/tmp/worktrees/task-goal-unattended-protocol-20261124/skills/task-dispatch/references/agent-coverage.md 与 /mnt/data/dev/task-planner-skill/tmp/worktrees/task-goal-unattended-protocol-20261124/skills/task-planner/scripts/selftest-decision-arbiter.sh；禁改其他任何文件（含主仓、worktree 其余文件、运行位、agent 定义）；禁 git commit/push/merge/stash；禁派发子代理。

工作路径：worktree（/mnt/data/dev/task-planner-skill/tmp/worktrees/task-goal-unattended-protocol-20261124）内。文件操作一律用绝对路径。时长预算：10min。

步骤：
Step1 Read edit-spec.md 第 1-16 行（通用纪律）与第 171-200 行（E29、E30）。
Step2 Read 目标行，Edit，再回读改动行，完成 E29、E30。
Step3 跑 bash -n 与 selftest，原样保存输出。
Step4 写 checkpoint 并返回。

返回格式：严格按 /home/terry/.zcode/skills/task-planner/templates/subagent_dispatch.md §7 的 8 个固定字段逐字段返回：status: / acceptance: / files: / evidence: / checkpoint: / findings_written: / blockers: / confidence:——字段名与顺序不得改、不得增删、无内容填 none、不加标题/前言/总结。已填示例：/home/terry/.zcode/skills/task-planner/references/dispatch-examples.md §1。

checkpoint 落盘路径：/mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/19-general-purpose.md（每完成一条编辑追加一行里程碑；末尾「最终结论」段=同一 8 字段块）。

上下文预算：prompt 不超过 3000 字符；只 Read edit-spec 点名的行附近，禁通读整仓。
