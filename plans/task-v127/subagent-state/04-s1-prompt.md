# task-v127/S1 任务书 — Rule 50 条款块落盘 [parallel-group:impl-wave1]

## 1. 目标
在 **worktree** 的 critical-rules.md 文末追加 Rule 50「内容要求权重分级与评级」条款块（50.1-50.6），纯增量，既有内容零改动。本会话只执行本 S-unit。

## 2. 输入(计划三文件,绝对路径 — Rule 22.4a)
- 任务书:本文件
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v127/task_plan.md — 只读；**「📐 Rule 50 设计契约」区块（50.1-50.6 全文+泪痣样例表）= 条款文本草案基线，逐条转写为条款体**
- findings: /mnt/data/dev/task-planner-skill/plans/task-v127/findings.md — 只读
- progress: /mnt/data/dev/task-planner-skill/plans/task-v127/progress.md — 只读
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v127/knowledge-brief.md §1/§4（术语与易错点）
- 目标文件: /mnt/data/dev/task-planner-skill-worktrees/task-v127/skills/task-planner/references/critical-rules.md（**只改 worktree 内此文件**）
- 范式参照（worktree 内同文件）: `### 47`(:484)/`### 48`(:496)/`### 49`(:506) 三块——条文体例=`### NN 标题（P0, 日期 task-vNNN，目标：…；判定面=…；衔接 …，既有 Rules 原文零改动）`+ `NN.M **子条名（…）**：…`
- 工具面提示: 纯文本编辑（Edit 工具），机械校验由主进程验收时执行
## 3. 验收标准(4 条)
- [ ] `### 50 内容要求权重分级与评级` 块在 Rule 49 块之后（文件末尾追加，禁止插进 47/48/49 中间）；50.1-50.6 六子条齐全（grep -c '^50\.' ≥6），文本以设计契约为基线可轻度润色但术语锚保留：`原子验收条目`/`存在性 P`/`程度 E`/`硬约束 H`/`评分项 S`/`双向`/`PASS`/`FAIL`/`加权`
- [ ] 泪痣样例表（P/H + E/H 双条目+评级语义+显隐度刻度）作为条款内样式样例完整保留
- [ ] 50.6 机制子条声明：判定面=LLM 行为、机器面=selftest-requirement-grading.sh 静态断言、零新 config 键、既有 Rules 原文零改动
- [ ] `git -C <worktree> diff --stat` 显示仅 critical-rules.md 一个文件变更且纯追加（0 删除）；既有 1-49 行零变化（git diff 不含既有行修改）
## 4. Scope 禁改清单
- 禁止修改 worktree 内除 critical-rules.md 外任何文件；禁止修改主仓 /mnt/data/dev/task-planner-skill/ 下任何 skills/** 文件（计划三文件只读）；禁止 git add/commit（主进程编排）；禁碰其他 worktree
## 5. 工作路径
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v127（所有 Edit 用此绝对路径）；不切换 CWD
## 6. 时长预算
- executor → 20 分钟；超时返回 partial
## 7. 返回格式(严格 8 字段，之后不得有任何内容)
status: done | partial | failed | timeout
acceptance: <n>/4 pass — [1:PASS 2:PASS 3:PASS 4:PASS]
files: <绝对路径>(+N/-M)
evidence: <grep 输出行 + git diff --stat 行>
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/04-s1-executor.md (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
## 8. checkpoint 落盘路径(强制)
- /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/04-s1-executor.md（唯一额外可写文件）；T5 必写「最终结论」段=第 7 节同一 8 字段块
## 9. 上下文预算
- 只 Read 本任务书 §2 列出文件；设计契约区段用 Read offset/limit 定位（task_plan.md :118-141 一带）；critical-rules.md 只读文尾 40 行确认插入点
