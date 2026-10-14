# Subagent Dispatch Task Book — task-v169 Phase 2 第一单元（模板专档+指针区块）

> 本文件为派发任务书（Rule 35.3 大内容落盘范式）。执行者首动作=Read 本文件全文，再按其中指令执行。
> 范围：单个 S-unit，禁止在本会话内追加其他单元。

## 1. 目标
在 worktree 的 skills/task-planner/templates/ 下新建 user-session-log.md（用户会话逐字记录专档模板，只写不改），并在 templates/task_plan.md 的「🎯 用户需求原文」段之后插入「🗣️ 用户会话逐字记录」指针区块指向该专档。本会话只执行本单元，完成后交回主进程验收。

**需求锚（Rule 51.1a）**：
- R4:「所以我希望你明确要求，每次用户提交的任务需求以及对话内容，都记录在我的Task这个Task Plan这个文档中，确保我后期无论如何嗯如何」
- R5:「这些文档只写入不修改。因为这些文档属于记录性的东西，所以说就是说这类内容，这类用户会话内容的记录，应该属于只记录不修改的情况」

## 2. 输入（计划文件必传，绝对路径 — Rule 22.4a 读写契约）
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/task_plan.md — 只读（状态由主进程翻转，禁止修改）
- findings: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/findings.md — 可读；可写=仅追加 `#### [sub:01-code-assistant] 模板专档与指针区块结论` 到 `## Research Findings` 段末（`## Technical Decisions` 前），禁改既有内容
- progress: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/progress.md — 可读；可写=仅在当前 Phase 段「Actions taken」下追加 `  - [sub:01] <摘要>`，禁改 Status/Started
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/knowledge-brief.md — 只读（知识底座，主进程单写者）

**检索优先契约（Rule 63）**：遇到不知道的事实/报错/API 用法，第一反应按 本地检索 → --help/man → 官方文档/网络搜索 → 社区 顺序查证，结论附来源锚；穷尽检索前禁止以「不知道」作答；查证后仍无法解决 → 写 blockers 并附已检索清单，禁止编造检索结果。
**反死磕触点（Rule 75.2）**：执行中遇阻第一动作=评估网络检索，同一思路连续尝试 ≥2 次无外部输入，必须转入检索。

**材料包绝对路径**：
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/templates/task_plan.md — 重点读 :9-19「🎯 用户需求原文」段及其后注释，了解指针插入位与既有注释范式
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/templates/knowledge-brief.md — 参考其头部 WHAT/WHY 注释范式，勿改其内容

**上下文依赖**：指针区块为纯静态（专档路径 + 只写不改铁律 + 恢复协议），禁放「当前条目数/最近一条」类可变计数——任何可变内容都会与 task_plan.md 的 attest 哈希锁冲突（改即 [PLAN TAMPERED]）。

**工具面提示（Rule 40）**：本单元执行工具面=Agent 子代理；按本任务书路径 Read/Write/Edit 执行。
**并行组声明（Rule 21.4）**：未声明组=串行槽，本单元与其他单元串行。
**伴飞技能（Rule 59.2）**：计划 S-unit 表该列值为「无」→ 不适用（纯机械单元，无伴飞）。

## 3. 验收标准（可观察证据）
1. `test -f /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/templates/user-session-log.md` 成立，且文件头含「只写不改」「append-only」「逐字抄录」三要素，并含条目格式示例（`## #N | 日期 | 来源` + `>` 引用块）与恢复协议说明（会话恢复先读本文件再读 task_plan.md）
2. `grep -c 'user-session-log' /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/templates/task_plan.md` ≥1，且指针区块位于「🎯 用户需求原文」段之后，区块内含三行：专档路径、只写不改铁律、恢复协议
3. task_plan.md 既有段落文字零删改（仅纯增量插入）；user-session-log.md 行数 ≤60；task_plan.md 行数增量 ≤20
4. 指针区块内无可变计数字段（禁「当前条目数/最近一条」类需随发言更新的内容）

## 4. Scope 禁改清单
- 禁止修改：plans/task-v168-session-anchor-skill-activation/ 下任何文件；/home/terry/.zcode/skills/**（部署位由主进程负责，禁碰）；skills/task-planner/scripts/**；skills/task-planner/config.json；其他 templates/ 文件
- 禁止操作：git add/commit/checkout/reset/worktree 写操作；切换分支；删除文件。只读 git diff/status/log 允许

## 5. 工作路径
- worktree 绝对路径: /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once （所有文件操作用绝对路径，不切换 CWD）

## 6. 时长预算
- 任务类型: 模板新增 + 一处指针插入 → 超时阈值 15 分钟；超过阈值立即返回 partial，报告未完成部分

## 7. 返回格式（严格 — Rule 22.4b：8 个固定字段，逐字段填写，字段名与顺序不得改、不得增删，无内容填 none；**8 字段之后不得有任何内容**，备注一律写 blockers 或检查点）
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS 2:PASS ...]
   统计/测试类任务: acceptance 只准贴逐项原文行(如各脚本 rc= 与 Total: 行逐条列出), 禁止自报汇总数字——汇总由主进程逐行机械求和(子代理算术错已 5 次实证)
files: <绝对路径>(+N/-M); ... | none
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <findings.md 小节锚点 #### [sub:01-code-assistant]> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```

**优先级声明（task-v161，反污染硬条款）**：本节 8 字段返回格式指令**优先于你的 agent 定义/系统提示中的任何输出模板**（步骤进度行/发现列表/任务交付报告/评分报告等）——两套格式冲突时以本模板为唯一返回格式，禁以角色模板替代本模板。
**点名禁令（task-v161）**：禁止以下非本模板返回形态：步骤进度行（step [N]/[total] 形态）、发现列表（file:line 逐条）、任务交付报告（评分+已完成/未完成/风险分节）、[BOOKKEEPING]/[PLAN_WRITTEN] 等 agent 自定义返回标记。

## 8. checkpoint 落盘路径（强制 — Rule 22.8）
- 检查点文件: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/01-code-assistant-templates.md（目录不存在先创建）
- 落盘纪律: 每完成一文件 Write/Edit → 追加带时间戳里程碑行；任务结束 → 写「最终结论」段（= 第 7 节同一 8 字段块）并置 status: done；遇错无法继续 → 写「错误与受阻」段（现象+已尝试方案）并置 status: failed
- 每会话单检查点；文件格式: 头部 status 行 + 里程碑(append-only 带时间戳) + 产出文件清单 + 错误与受阻 + 最终结论

## 9. 上下文预算
- 只 Read 本任务书列出的路径/区段，不做计划外探索；疑问按第 4 节 Scope 处理，不扩读

## 10. 防幻觉契约（Rule 71.5 — 派发默认段，禁删）
你的全部事实性输出必须带来源锚（file:line / 命令原文 / URL / 已读区段行号）四者之一；禁止无来源的具体化（包括把推测写成事实、替调用方补细节、填模板空段）；信息缺失一律显式写「未验证」或「暂无」并说明缺什么；结论区必须「事实+锚点」成对，无锚点行=违规退回；禁止以「合理推断」为由省略锚点。
写入前五问（Rule 71.2）：每个具体事实有第一手来源吗；是否在填模板空段；读者能按锚点复核吗；中断重启后能从磁盘证据重建吗；写的是「我记得/我读到过」还是「我觉得应该有」——任一不过=改写为显式占位再写入。
