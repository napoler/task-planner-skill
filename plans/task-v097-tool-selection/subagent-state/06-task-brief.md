# P3-S2 任务书: mini-lite 豁免声明行 + dispatch 工具面提示行（task-v097）

任务: worktree 内两个模板文件的小改——mini-lite 豁免声明 + subagent_dispatch 工具面提示行。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/task_plan.md（只读: VC-3 判定标准+强制约束 9）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/findings.md（只读）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/progress.md（子代理禁写）

## 目标文件（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v097-tool-selection 下）
1. skills/task-planner/templates/variant/mini-lite-type.md（当前 44 行,上限 80）
2. skills/task-planner/templates/subagent_dispatch.md（改 §2 输入段,约 L10-18,以内容锚定位）

## 操作内容
### 文件 1: mini-lite-type.md
在头部注释区（template_type/plan_tier 声明附近,以内容锚定位）加 1 行注释:
`<!-- Rule 40.2 豁免声明（task-v097）: mini 档不加「🧰 工具选择与编排」区块——Rule 38.3 轻量模板区块白名单的自然延伸,mini 免计划期工具分析仪式;显式声明以防误判缺区块为违约 -->`
### 文件 2: subagent_dispatch.md
在 §2 输入段末尾加 1 行（对齐该文件现有行文风格,列表项或普通行均可）:
`工具面提示（Rule 40）: 若该 S-unit 执行工具面非 Agent 子代理（如 workflow 编排/机械脚本/卫星技能）,须在本节注明所用工具与选择理由;「🧰 工具选择与编排」区块（计划内）是上游分析记录,本任务书按其结论派发。`

## 硬约束
- 只改这 2 个文件,各只加 1 行;mini-lite 总行数必须 ≤80（selftest-plan-tier T11 断言）。
- 禁动 mini-lite 其余内容与 dispatch 九字段结构（§2/§7/§8 标签逐字保全——check-dispatch 消费）。

## acceptance: 验收标准
1) `grep -c 'Rule 40.2 豁免声明' mini-lite-type.md` =1 且 `wc -l` ≤80（记录实际值）
2) `grep -c '工具面提示' subagent_dispatch.md` =1 且 `grep -c 'status:' subagent_dispatch.md` 等 8 字段标签全部仍在（§7/§8 结构零破坏,以改前 grep 计数为基线对比相等）
3) 复跑 worktree scripts/selftest-plan-tier.sh → Total 行 0 FAIL
4) 复跑 worktree scripts/selftest-dispatch.sh → Total 行 0 FAIL
5) `git -C <wt> diff --stat` 现累计 2 文件（templates/task_plan.md 为 S1 存量+本步 2 文件=3 文件总量）

## checkpoint
完成前把结论与命令实际输出写入 /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/subagent-state/06-executor.md。禁 git commit/add。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P3-S2
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
