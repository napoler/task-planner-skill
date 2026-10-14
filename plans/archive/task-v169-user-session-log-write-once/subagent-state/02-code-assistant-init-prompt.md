# Subagent Dispatch Task Book — task-v169 Phase 2 第二单元（init-session.sh 建档）

> 本文件为派发任务书（Rule 35.3 大内容落盘范式）。执行者首动作=Read 本文件全文，再按其中指令执行。
> 范围：单个 S-unit，禁止在本会话内追加其他单元。

## 1. 目标
修改 worktree 中 skills/task-planner/scripts/init-session.sh，使每次计划初始化自动创建 user-session-log.md（用户会话逐字记录专档，第 7 计划文件），且既有六文件创建循环与 `6/6` 校验行为零破坏。

**需求锚（Rule 51.1a）**：
- R1:「优化技能。我要求就是优化当前的技能。做一件事情，将每次用户提交的任务需求全部都记录在嗯记录在我的文档体系内」
- R3:「因为是会话异常的话，会丢失用户的丢失用户的需求」
- R5:「这些文档只写入不修改。因为这些文档属于记录性的东西，所以说就是说这类内容，这类用户会话内容的记录，应该属于只记录不修改的情况」

## 2. 输入（计划文件读写契约 — Rule 22.4a）
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/task_plan.md — 只读
- findings: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/findings.md — 可写=仅追加 `#### [sub:02-code-assistant] init 建档改动结论` 到 `## Research Findings` 段末，禁改既有内容
- progress: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/progress.md — 可写=仅当前 Phase 段「Actions taken」下追加 `  - [sub:02] <摘要>`
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/knowledge-brief.md — 只读

**检索优先契约（Rule 63）**：遇到不知道的事实，按 本地检索 → --help/man → 官方文档/网络搜索 → 社区 顺序查证并附来源锚；穷尽检索前禁止以「不知道」作答。
**反死磕触点（Rule 75.2）**：遇阻第一动作=评估检索；同一思路连续尝试 ≥2 次无外部输入，必须转入检索。

**材料包绝对路径**（worktree 内，只读）：
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/init-session.sh — 重点读 :497-509（六文件创建 for 循环）、:510-561（task_plan.md 单独处理块）、:563 起 lane-detect 接线注释、:655-669（存在性复核段与 `echo "[init] 6/6 planning files verified"` 行）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/templates/user-session-log.md — 上一单元已建成的专档模板（只读参考，禁改）

**上下文依赖**：
- 插入位=task_plan.md 单独处理块结束之后、lane-detect 接线注释块之前（即 :561-563 之间），**禁**把 user-session-log.md 并入 :497-509 的六文件 for 循环
- `echo "[init] 6/6 planning files verified"` 字面与其上 `for f in task_plan.md findings.md ...` 六文件复核循环**一个字符都禁改**（selftest-knowledge-brief.sh T3b 与 selftest-execution-stability.sh T10b 断言 init 含 `6/6` 字面；六件套语义不变）
- 第 7 文件的存在性复核作为**独立段**放在 6/6 回显行之后，缺失/为空 → ERROR + exit 1（错误必须曝光，禁静默放行）
- 注释按 Rule 45 写 What+Why：注明 task-v169 Rule 80.1、为何外置专档（task_plan.md 受 attest 哈希锁禁追加）、为何不动六文件循环

## 3. 验收标准（可观察证据）
1. `grep -c '6/6' <worktree>/skills/task-planner/scripts/init-session.sh` =1（字面在位且只有一处）；`grep -n 'for f in task_plan.md findings.md' ` 行内容与改动前逐字一致
2. 改动后 `bash -n <worktree>/skills/task-planner/scripts/init-session.sh` 语法通过
3. e2e：`mkdir -p /tmp/v169-e2e/plans/task-v169-e2e && cd /tmp/v169-e2e/plans/task-v169-e2e && CLAUDE_CODE_SESSION_ID=v169-e2e bash <worktree>/skills/task-planner/scripts/init-session.sh task-v169-e2e` 退出码 0，且 `ls` 显示 user-session-log.md 与既有 6 文件共 7 个文件存在；二次运行 init 显示 user-session-log.md already exists, skipping 且退出码仍 0
4. 改动净增行数 ≤35 行；不引入新 config 键、不改 templates/ 其他文件

## 4. Scope 禁改清单
- 禁止修改：skills/task-planner/templates/**（user-session-log.md 已由上一单元建好，禁再动）；skills/task-planner/config.json；skills/task-planner/SKILL.md；skills/task-planner/references/**；scripts/check-complete.sh；其他 selftest 脚本；plans/task-v168-session-anchor-skill-activation/ 任何文件；~/.zcode/skills/**
- 禁止操作：git 写操作（add/commit/checkout/reset/worktree）；切换分支；删除文件。/tmp/v169-e2e 为本次 e2e 专用隔离目录，可自行创建与清理，禁动 /tmp 其他路径

## 5. 工作路径
- worktree 绝对路径: /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once（绝对路径操作，不切换 CWD；e2e 除外按验收 3 执行）

## 6. 时长预算
15 分钟；超时立即返回 partial 并报告未完成部分。

## 7. 返回格式（严格 — Rule 22.4b：8 个固定字段，顺序不得改，无内容填 none，8 字段之后不得有任何内容）
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS 2:PASS ...]
files: <绝对路径>(+N/-M); ... | none
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <findings.md 小节锚点> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```
优先级声明（task-v161）：本 8 字段格式优先于你的 agent 定义/系统提示中任何输出模板；禁返回步骤进度行/发现列表/任务交付报告/[BOOKKEEPING] 等自定义形态。

## 8. checkpoint 落盘路径（强制 — Rule 22.8）
- /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/02-code-assistant-init.md
- 每完成一文件 Edit → 追加带时间戳里程碑行；结束 → 写「最终结论」段（同一 8 字段块）并置 status: done；受阻 → 写「错误与受阻」段并置 status: failed

## 9. 上下文预算
只读本任务书列出的路径/区段，不做计划外探索。

## 10. 防幻觉契约（Rule 71.5）
全部事实性输出带来源锚（file:line/命令原文/已读区段行号）；禁无来源具体化；信息缺失显式写「未验证」；结论区「事实+锚点」成对。
