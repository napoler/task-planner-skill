# P4-S2 任务书: template-guide 区块定制指南 + plan-writer 契约义务行（task-v097）

任务: worktree 内两个文件小改——template-guide.md 加「🧰 工具选择与编排」区块定制指南 + companion/agents/plan-writer.md 加工具选择撰写义务行。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/task_plan.md（只读: VC-4 判定标准）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/findings.md（只读）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/progress.md（子代理禁写）

## 目标文件（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v097-tool-selection 下）
1. skills/plan-template-kit/references/template-guide.md（插入点=§五 常见场景定制示例最后一个场景之后、§六 Checklist 之前;以内容锚「§六」标题定位,插其前;作为 §五 的追加场景,编号顺延现有最大场景号+1,若场景以「场景 N」命名则顺延）
2. skills/task-planner/companion/agents/plan-writer.md（「掌握的技能」bullet 列表末尾追加一行;以内容锚定位,禁动既有 bullet）

## 插入内容
### 文件 1（template-guide.md）
```
### 场景 N: 「🧰 工具选择与编排」区块定制（Rule 40 — task-v097）

**何时填**: plan-writer 撰写 standard/full 档计划时随计划产出;执行期工具变更时回填。mini 档豁免（Rule 38.3,mini-lite-type.md 头部有豁免声明行）。

**字段说明**:
- 工具面表 3 列: Phase / 命中工具面（Rule 40.1 六类之一或组合: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）/ 选择理由（一句话,选型依据=template-mapping.md §工具选择映射）
- workflow 编排判定行（Rule 40.4）: 未命中编排条件写"维持 Rule 21.4 串行";命中（独立并行子任务可 fan-out / 长链多 skill 接力可复用 / 用户点名）写"建议 CreateWorkflow"并按 Rule 39.4 做并行豁免登记
- /goal 对齐行（Rule 40.3）: 注明 Goal+VC 与 session goal 的映射关系;如实披露 /goal 为用户侧 harness 命令,技能层不可代调

**定制红线**: ① 定位声明（"上游分析记录,不替代 Executor 委派门控机器事实源"）禁删;② 区块内禁出现 `### Phase N:` / `**Status:**` / `**Executor:**` 三形态伪行（防 check-delegation 状态机误读）;③ mini 档禁加本区块;④ 工具面命名须对齐 Rule 40.1 六类措辞;⑤ 路径引用遵守本文档 §七 规范。
```
### 文件 2（plan-writer.md,「掌握的技能」列表内追加）
```
- 工具选择与编排区块（Rule 40.2,task-v097）: standard/full 档计划必填——逐 Phase 登记命中工具面与选择理由（选型依据=../plan-template-kit/references/template-mapping.md §工具选择映射）,并填写 workflow 编排判定（40.4: 命中→建议 CreateWorkflow+39.4 豁免登记）与 /goal 对齐（40.3: 如实披露用户侧命令不可代调）两判定行;mini 档豁免;区块是 Executor 字段上游分析记录,不替代其委派门控机器事实源地位
```

## 硬约束
- 只改这 2 个文件,各只做插入;既有锚子串禁动: plan-writer.md 的「问题解构四问」（selftest-methodology M-16 消费）与「纯数字」（selftest-conclusion-discipline CD-20 消费）所在行零改动。
- 文件 1 的「场景 N」中 N=现有最大场景号+1（先 grep '场景' 确定）。

## acceptance: 验收标准
1) `grep -c '工具选择与编排' template-guide.md` ≥2（场景标题+正文）
2) `grep -c '工具选择与编排区块' companion/agents/plan-writer.md` =1
3) 既有锚零破坏: `grep -c '问题解构四问' plan-writer.md` 与改前相等;`grep -c '纯数字' plan-writer.md` 与改前相等（改前值先 grep 记录）
4) 复跑 worktree scripts/selftest-methodology.sh 与 selftest-conclusion-discipline.sh → 双双 0 FAIL
5) `git -C <wt> diff --stat` 现累计 2 文件（template-mapping.md 为 S1 存量,本步恰 2 文件）

## checkpoint
完成前把结论与命令实际输出写入 /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/subagent-state/08-executor.md。禁 git commit/add。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P4-S2
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
