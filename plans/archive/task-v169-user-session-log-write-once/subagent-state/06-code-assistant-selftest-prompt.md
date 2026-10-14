# Subagent Dispatch Task Book — task-v169 Phase 3 第二单元（selftest-session-log.sh + registry 登记）

> 本文件为派发任务书（Rule 35.3 大内容落盘范式）。执行者首动作=Read 本文件全文，再按其中指令执行。
> 范围：单个 S-unit，禁止在本会话内追加其他单元。

## 1. 目标
新建 worktree 的 skills/task-planner/scripts/selftest-session-log.sh（SL-01..SL-10 静态断言，守护 Rule 80 全链落点），并在 scripts/selftest-registry.tsv 末尾追加本脚本登记行（四列非空）。

**需求锚（Rule 51.1a）**：
- R4:「所以我希望你明确要求，每次用户提交的任务需求以及对话内容，都记录在我的Task这个Task Plan这个文档中，确保我后期无论如何嗯如何」
- R5:「这些文档只写入不修改。因为这些文档属于记录性的东西，所以说就是说这类内容，这类用户会话内容的记录，应该属于只记录不修改的情况」

## 2. 输入（计划文件读写契约 — Rule 22.4a）
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/task_plan.md — 只读
- findings: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/findings.md — 可写=仅追加 `#### [sub:06-code-assistant] selftest 与 registry 结论` 到 `## Research Findings` 段末，禁改既有内容
- progress: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/progress.md — 可写=仅当前 Phase 段「Actions taken」下追加 `  - [sub:06] <摘要>`
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/knowledge-brief.md — 只读

**检索优先契约（Rule 63）**：不确定既有脚本写法先 Read 核对；禁凭记忆造脚本结构。
**反死磕触点（Rule 75.2）**：断言跑挂先读真实输出定位，同一思路连续尝试 ≥2 次无进展必须转入检索。

**材料包绝对路径**（worktree 内）：
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-knowledge-brief.sh — 脚本结构范式参考（shebang/头注 What-Why/断言函数/Total 行/exit 语义），只读不改
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-registry.tsv — 登记对象（只追加一行，禁改既有行）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/templates/user-session-log.md — SL-01/SL-02 守护对象
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/templates/task_plan.md — SL-03/SL-08 守护对象（指针区块）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/references/critical-rules.md — SL-04 守护对象（Rule 80 六子条）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/SKILL.md — SL-05 守护对象（1-80 ×3）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/init-session.sh — SL-07 守护对象（建档块+6/6 字面）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/check-complete.sh — SL-06 守护对象（SESSION-LOG GATE）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/config.json — SL-09 守护对象（properties 键数=42）

**上下文依赖（十条断言的判定口径表）**：

| 断言 | 守护落点 | 判定（机检） |
|------|----------|--------------|
| SL-01 | templates/user-session-log.md 存在 | `-f` 且含「只写不改」「append-only」「逐字抄录」三关键词各 ≥1 |
| SL-02 | 同文件条目格式+恢复协议 | 含 `## #N` 形态示例行且含「## 恢复协议」标题段 |
| SL-03 | templates/task_plan.md 指针区块 | `grep -c '🗣️ 用户会话逐字记录'` ≥1 且 `grep -c 'user-session-log'` ≥2 |
| SL-04 | references/critical-rules.md Rule 80 | `grep -cE '^80\.[1-6] '` = 6 |
| SL-05 | SKILL.md Rule 80 索引接线 | `grep -c '1-80'` = 3 |
| SL-06 | check-complete.sh SESSION-LOG GATE | 含 `[session-log-gate]` 前缀 + `TASK_PLANNER_SESSION_LOG_ENFORCE` + 注释含「零新 config 键」或「env-only」 |
| SL-07 | init-session.sh 建档 | `grep -c 'copy_template "user-session-log.md"'` ≥1 且 `grep -c '6/6'` = 1 |
| SL-08 | 指针区块纯静态（无可变计数） | templates/task_plan.md 中 `grep -cE '当前条目数\|最近一条'` = 0 |
| SL-09 | 零新 config 键 | jq 可得时 `jq '.properties\|keys\|length' config.json` = 42；jq 缺失=SKIP 计 PASS（对齐 DD-20 先例） |
| SL-10 | registry 自登记 | `grep -c 'selftest-session-log.sh' selftest-registry.tsv` = 1 且该行四列非空 |

- 脚本纪律：头部注释 What+Why（Rule 45）注明 task-v169 Rule 80 与 SL-01..10 口径；断言函数与 Total 行/exit 语义对齐 selftest-knowledge-brief.sh 范式；**本脚本自身禁写 config.json、禁 git 写操作**；stderr/stdout 只用既有约定；单文件行数 ≤120 行
- registry 新行四列（script/domain/trigger_scenarios/dep_anchors，tab 分隔）内容=本脚本名 + Rule 80 守护域描述 + SL-01..10 触发场景 + 上表守护对象路径清单（分号分隔）

## 3. 验收标准（可观察证据）
1. `bash <worktree>/skills/task-planner/scripts/selftest-session-log.sh` exit=0 且输出 `Total: 10 PASS=10 FAIL=0`
2. `grep -c 'selftest-session-log.sh' <worktree>/skills/task-planner/scripts/selftest-registry.tsv` =1，且该行 tab 分列数=4、每列非空（`awk -F'\t' 'NF==4'` 命中该行）
3. `wc -l` 新脚本 ≤120 行；`git diff --numstat selftest-registry.tsv` = 纯追加 1 行、既有行零改动
4. 负向自检：任意一条断言对象被临时破坏（如在 /tmp 副本上试跑）时应 FAIL——用命令证明断言非空转（例如临时移动一份副本到 /tmp 改坏 SL-03 对象后跑出 FAIL 再还原，禁改动 worktree 真文件）

## 4. Scope 禁改清单
- 禁止修改：除 scripts/selftest-session-log.sh（新建）与 scripts/selftest-registry.tsv（追加一行）以外的任何文件；尤其禁改 SL-01..10 的守护对象本体（模板/规则/SKILL/init/check-complete/config.json）；plans/task-v168-session-anchor-skill-activation/ 任何文件；~/.zcode/skills/**
- 禁止操作：git 写操作；切换分支；删除文件；改动 config.json

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
- /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/06-code-assistant-selftest.md
- 每完成一文件 Write/Edit → 追加带时间戳里程碑行；结束 → 写「最终结论」段（同一 8 字段块）并置 status: done；受阻 → 写「错误与受阻」段并置 status: failed

## 9. 上下文预算
只读本任务书列出的路径/区段，不做计划外探索。

## 10. 防幻觉契约（Rule 71.5）
全部事实性输出带来源锚（file:line/命令原文/已读区段行号）；禁无来源具体化；信息缺失显式写「未验证」；结论区「事实+锚点」成对。
