# P3-S1 任务书: general 模板加「🧰 工具选择与编排」区块（task-v097）

任务: worktree 内 general 模板 templates/task_plan.md 新增「🧰 工具选择与编排」区块（Rule 40.2 模板承载）。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/task_plan.md（只读: VC-3 判定标准;其自身「🧰」区块=L108-121 为格式实例）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/findings.md（只读）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/progress.md（子代理禁写）

## 目标文件（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v097-tool-selection 下）
skills/task-planner/templates/task_plan.md（当前 420 行;插入点=「## Next Step」段末占位行之后、「## Phases」头之前,约 L133 前）

## 硬约束
- 只改该 1 文件,只做插入（其余行零改动）。
- 区块形态=HTML 注释块 + 一个表格 + 两行判定,是纯静态模板文本;**区块内禁止出现 `### Phase N:`、`**Status:**`、`**Executor:**` 三形态伪行**（防 check-delegation 状态机误读,Rule 40.2 原文）。
- 占位文本用 `[ ]` 式示例占位,不预填具体内容。

## 区块内容（逐字使用,可微调排版但语义与关键 token 不得删）
```
## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | [如: Agent 子代理 executor(sonnet-1)] | [一句话理由] |

**workflow 编排判定（Rule 40.4）**: [未命中编排条件 → 维持 Rule 21.4 串行;命中（独立并行子任务可 fan-out / 长链多 skill 接力可复用 / 用户点名）→ 登记"建议 CreateWorkflow"并按 Rule 39.4 做并行豁免登记（Decisions Made + progress）]
**/goal 对齐（Rule 40.3）**: [本计划 Goal+VC 即 session goal 的证据源;如用户已用 /goal 锚定本任务,在执行范围或 Goal 段注明映射;/goal 为用户侧 harness 命令,技能层不可代调]
```

## acceptance: 验收标准
1) `grep -c '🧰 工具选择与编排' <目标文件>` ≥1
2) 区块含「不替代」与「上游分析记录」定位声明
3) 区块内 grep -c '^\*\*Status:\*\*' = 0 且 '^\*\*Executor:\*\*' = 0 且 '^### Phase' 零新增（对比插入前后行数差=区块自身行数）
4) 下游冒烟: 在 /tmp 下建临时目录,运行 `cd /tmp/t-v097-smoke && bash /mnt/data/dev/task-planner-skill-worktrees/task-v097-tool-selection/skills/task-planner/scripts/init-session.sh`（若脚本要求先 mkdir plans 子目录则照做）→ 生成 task_plan.md 含「🧰 工具选择与编排」区块且 6 文件生成无报错;冒烟产物留在 /tmp,禁写入仓库
5) `git -C <wt> diff --stat` 仅 templates/task_plan.md 1 文件

## checkpoint
完成前把结论与命令实际输出写入 /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/subagent-state/05-executor.md。禁 git commit/add。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P3-S1
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
