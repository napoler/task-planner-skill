# Subagent Dispatch Task Book — task-v169 Phase 3 第一单元（check-complete.sh SESSION-LOG GATE）

> 本文件为派发任务书（Rule 35.3 大内容落盘范式）。执行者首动作=Read 本文件全文，再按其中指令执行。
> 范围：单个 S-unit，禁止在本会话内追加其他单元。

## 1. 目标
在 worktree 的 skills/task-planner/scripts/check-complete.sh 中新增 SESSION-LOG GATE（Rule 80.6 门控面）：task_plan.md 含「🗣️ 用户会话逐字记录」指针区块时，强制 user-session-log.md 存在且至少 1 条记录条目；指针区块缺失（存量计划）自动 SKIP；env-only 档位降级。

**需求锚（Rule 51.1a）**：
- R4:「所以我希望你明确要求，每次用户提交的任务需求以及对话内容，都记录在我的Task这个Task Plan这个文档中，确保我后期无论如何嗯如何」
- R5:「这些文档只写入不修改。因为这些文档属于记录性的东西，所以说就是说这类内容，这类用户会话内容的记录，应该属于只记录不修改的情况」

## 2. 输入（计划文件读写契约 — Rule 22.4a）
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/task_plan.md — 只读
- findings: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/findings.md — 可写=仅追加 `#### [sub:05-code-assistant] SESSION-LOG GATE 结论` 到 `## Research Findings` 段末，禁改既有内容
- progress: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/progress.md — 可写=仅当前 Phase 段「Actions taken」下追加 `  - [sub:05] <摘要>`
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/knowledge-brief.md — 只读

**检索优先契约（Rule 63）**：不确定的既有代码行为先 Read 原文核对；禁凭记忆猜既有逻辑。
**反死磕触点（Rule 75.2）**：fixture 跑不通先 Read 真实报错，同一思路连续尝试 ≥2 次无进展必须转入检索。

**材料包绝对路径**（worktree 内，唯一改动对象）：
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/check-complete.sh — 改动对象；参照阅读：:645-700 VC-GATE 档位解析段（env>config>warn 解析范式）、:826-900 R-COVERAGE GATE 段（门控注释结构与 stderr 消息前缀形态）、:1122-1130 CR-GATE 段首（插入位锚点）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/templates/task_plan.md:20-24 — 指针区块现实形态（标题含「🗣️ 用户会话逐字记录」，区块内含 user-session-log.md 路径）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/references/critical-rules.md 的 Rule 80.6 — 门控口径权威源

**上下文依赖（插入位与行为契约）**：
- 插入位：`    run_report_lint` 行之后、CR-GATE 注释块（`# [2026-10-11 task-v167 波次4 Rule 42.7] CR-GATE`）之前，保持 4 空格缩进层级
- 计划目录解析：复用 `$PLAN_DIR_GUESS`（R-COVERAGE GATE 同款用法）
- 指针区块判定标记：`grep -q '🗣️ 用户会话逐字记录'`（命中=新模板计划，进入门控；未命中=存量计划，输出 SKIPPED INFO 后放行）
- 专档判定：`$PLAN_DIR_GUESS/user-session-log.md` 存在、非空（`-s`）、且 `grep -cE '^## #'` ≥1（有记录条目）
- 档位解析（零新 config 键）：`session_log_tier="${TASK_PLANNER_SESSION_LOG_ENFORCE:-}"`，取值 enforce/warn/off，其他/空值回落 warn；本门不读 config.json、不新增任何键
- 行为矩阵：enforce+违规=stderr `[session-log-gate] ✗` 后 exit 1；warn+违规=stderr `[session-log-gate] ⚠` 不阻断（默认档）；off=整门 SKIP；`LANE_L0=1`=打印 `[lane-L0] skip SESSION-LOG GATE` 后跳过（38.7 同款）；合规=stderr `[session-log-gate] OK` 带条目数
- 注释按 Rule 45 写 What/Why 双层，注明 task-v169 Rule 80.6、R4/R5 锚、存量跳过理由、env-only 零新键；stderr 消息前缀统一 `[session-log-gate]`（对齐既有 [fmea-gate]/[rcov-gate] 风格）
- 禁令：不得改动任何既有门控逻辑与既有行；不得引入 config.json 键；不得在 stdout 输出（stdout 是 [plan] 行通道）；新增注释的行内枚举一律用短横或分号列表，禁圆圈序号字符

## 3. 验收标准（可观察证据）
1. `bash -n <worktree>/skills/task-planner/scripts/check-complete.sh` 语法通过；`git diff --numstat scripts/check-complete.sh` 净增 ≤45 行且删除行=0
2. fixture A（enforce+违规）：/tmp 下造 `plans/task-v169-gate-a/`，task_plan.md 含指针区块标记但 user-session-log.md 缺失 → `TASK_PLANNER_SESSION_LOG_ENFORCE=enforce bash scripts/check-complete.sh /tmp/.../task_plan.md` exit 1 且 stderr 含 `[session-log-gate] ✗`
3. fixture B（合规）+ fixture C（无指针区块 SKIP）+ fixture D（off 档 SKIP）+ fixture E（默认 warn 档违规不阻断 exit 0）：四种场景逐一实跑并在返回 evidence 贴 stderr 关键行
4. 零新键实证：`git diff scripts/check-complete.sh` 中无 config.json 写入/键名新增；`jq '.properties|keys|length' config.json` = 42（DD-20 不回归）

## 4. Scope 禁改清单
- 禁止修改：check-complete.sh 中既有任何行（只允许在指定插入位纯追加）；SKILL.md；references/**；templates/**；config.json；其他 scripts/**；plans/task-v168-session-anchor-skill-activation/ 任何文件；~/.zcode/skills/**
- 禁止操作：git 写操作；切换分支；删除文件。/tmp 下 fixture 目录可自建自清（仅限 task-v169-gate-* 前缀路径）

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
- /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/05-code-assistant-gate.md
- 每完成一文件 Edit → 追加带时间戳里程碑行；结束 → 写「最终结论」段（同一 8 字段块）并置 status: done；受阻 → 写「错误与受阻」段并置 status: failed

## 9. 上下文预算
只读本任务书列出的路径/区段，不做计划外探索。

## 10. 防幻觉契约（Rule 71.5）
全部事实性输出带来源锚（file:line/命令原文/已读区段行号）；禁无来源具体化；信息缺失显式写「未验证」；结论区「事实+锚点」成对。
