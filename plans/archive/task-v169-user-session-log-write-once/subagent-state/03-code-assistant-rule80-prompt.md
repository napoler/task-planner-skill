# Subagent Dispatch Task Book — task-v169 Phase 2 第三单元（Rule 80 正文）

> 本文件为派发任务书（Rule 35.3 大内容落盘范式）。执行者首动作=Read 本文件全文，再按其中指令执行。
> 范围：单个 S-unit，禁止在本会话内追加其他单元。

## 1. 目标
在 worktree 的 skills/task-planner/references/critical-rules.md 末尾（Rule 76 段之后）新增 Rule 80「用户会话逐字记录与只写不改纪律」，六子条 80.1-80.6 齐全。

**需求锚（Rule 51.1a）**：
- R4:「所以我希望你明确要求，每次用户提交的任务需求以及对话内容，都记录在我的Task这个Task Plan这个文档中，确保我后期无论如何嗯如何」
- R5:「这些文档只写入不修改。因为这些文档属于记录性的东西，所以说就是说这类内容，这类用户会话内容的记录，应该属于只记录不修改的情况」
- R1:「优化技能。我要求就是优化当前的技能。做一件事情，将每次用户提交的任务需求全部都记录在嗯记录在我的文档体系内」

## 2. 输入（计划文件读写契约 — Rule 22.4a）
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/task_plan.md — 只读
- findings: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/findings.md — 可写=仅追加 `#### [sub:03-code-assistant] Rule 80 正文结论` 到 `## Research Findings` 段末，禁改既有内容
- progress: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/progress.md — 可写=仅当前 Phase 段「Actions taken」下追加 `  - [sub:03] <摘要>`
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/knowledge-brief.md — 只读

**检索优先契约（Rule 63）**：遇到不知道的事实，按 本地检索 → --help/man → 官方文档/网络搜索 → 社区 顺序查证并附来源锚；穷尽检索前禁止以「不知道」作答。
**反死磕触点（Rule 75.2）**：遇阻第一动作=评估检索；同一思路连续尝试 ≥2 次无外部输入，必须转入检索。

**材料包绝对路径**（worktree 内，只读）：
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/references/critical-rules.md — 重点读 :1032-1046（Rule 76 段全文，作为新 Rule 的格式范式：`## Rule 76（标题 — task-v166）` 标题行 + `>` 引言行 + `76.N **子条名**：内容` 子条格式）与 :360（Rule 34.6 env 开关先例写法）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/templates/user-session-log.md — 上一单元已建专档模板（口径与术语对齐源）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/init-session.sh:562-575 与 :686-693 — 上一单元已建建档块（80.1/80.6 描述的机制本体）

**上下文依赖**：
- 六子条内容骨架（每条 = 「**子条名**：What/Why/口径」句式，禁空泛）：
  - 80.1 建档与记录范围：每个计划目录必须有 user-session-log.md（init-session.sh 自动建档，第 7 计划文件）；记录范围=用户提交的任务需求与对话内容（含纠正/否决/追加/「继续」类短消息），逐字口径同 Rule 51.1
  - 80.2 只写不改：append-only；历史条目禁修改/禁删除/禁重排；唯一合法写操作=文件尾追加；发现历史条目有误→末尾追加「更正说明」新条目，禁回头改旧条目
  - 80.3 写入时机与写入者：用户发言到达后立即追加（宪法 §八 即时落盘纪律），禁止攒批/deferred；写入者=主进程单写（同三文件罗盘单写者纪律），子代理只读不改（派发契约中该文件只读）
  - 80.4 恢复协议：会话中断/压缩/重启恢复时 user-session-log.md=用户意图权威源，先读本文件再读 task_plan.md；两者冲突时以本文件为「用户原话」事实源，task_plan.md 侧按 Rule 74.3 变更标注表对齐，禁反向改写本文件
  - 80.5 与 attest 哈希锁的边界：task_plan.md 受 Rule 20/51.7 哈希锁（改即 [PLAN TAMPERED]），用户会话记录禁入 task_plan.md 正文；task_plan.md 的「🗣️ 用户会话逐字记录」指针区块为纯静态（专档路径+铁律+恢复协议），禁条目计数/首末条目标记类可变内容
  - 80.6 守护机制：init 建档+存在性复核；check-complete.sh SESSION-LOG GATE（指针区块门控：有指针且专档缺失/空=FAIL；无指针=存量计划 SKIP；env `TASK_PLANNER_SESSION_LOG_ENFORCE`（enforce/warn/off，默认 warn）降级）；selftest-session-log.sh 静态断言；**零新 config 键**（71.7/64.6 同范式，config.json properties 键数恒 42）
- 禁在 Rule 80 内写任何 config.json 键名（env-only）；引用 env 开关的写法对齐 :360 Rule 34.6 先例

## 3. 验收标准（可观察证据）
1. `grep -cE '^80\.[1-6] ' <worktree>/skills/task-planner/references/critical-rules.md` =6，且 80.1-80.6 各自含 What/Why/口径实质内容（禁占位空话）
2. 标题行格式=`## Rule 80（用户会话逐字记录与只写不改纪律 — task-v169）`，其后有空行+`>` 引言行（对齐 Rule 76 范式）
3. `grep -c 'config.json#' <Rule 80 新增区段>` =0（零新 config 键）；env 开关名 `TASK_PLANNER_SESSION_LOG_ENFORCE` 在 80.6 出现 ≥1 次
4. `git diff --numstat references/critical-rules.md` 显示纯追加（删除行=0）；净增行数 ≤45；Rule 76 及之前所有既有文字零改动

## 4. Scope 禁改清单
- 禁止修改：critical-rules.md 中 Rule 76 及之前的任何既有文字；SKILL.md；scripts/**；templates/**；config.json；plans/task-v168-session-anchor-skill-activation/ 任何文件；~/.zcode/skills/**
- 禁止操作：git 写操作；切换分支；删除文件

## 5. 工作路径
/mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once （绝对路径操作，不切换 CWD）

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
- /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/03-code-assistant-rule80.md
- 每完成一文件 Edit → 追加带时间戳里程碑行；结束 → 写「最终结论」段（同一 8 字段块）并置 status: done；受阻 → 写「错误与受阻」段并置 status: failed

## 9. 上下文预算
只读本任务书列出的路径/区段，不做计划外探索。

## 10. 防幻觉契约（Rule 71.5）
全部事实性输出带来源锚（file:line/命令原文/已读区段行号）；禁无来源具体化；信息缺失显式写「未验证」；结论区「事实+锚点」成对。
