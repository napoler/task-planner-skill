# Subagent Dispatch Task Book — task-v169 Phase 2 第四单元（SKILL.md 级联）

> 本文件为派发任务书（Rule 35.3 大内容落盘范式）。执行者首动作=Read 本文件全文，再按其中指令执行。
> 范围：单个 S-unit，禁止在本会话内追加其他单元。

## 1. 目标
在 worktree 的 skills/task-planner/SKILL.md 完成 Rule 80 索引级联：三处 1-76 改 1-80、第 6 文件确认行改第 7 文件、新增 C56 合规行、References 表新增 user-session-log.md 行（改法见第 2 节替换串表 E1-E9）。

**需求锚（Rule 51.1a）**：
- R4:「所以我希望你明确要求，每次用户提交的任务需求以及对话内容，都记录在我的Task这个Task Plan这个文档中，确保我后期无论如何嗯如何」

## 2. 输入（计划文件读写契约 — Rule 22.4a）
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/task_plan.md — 只读
- findings: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/findings.md — 可写=仅追加 `#### [sub:04-code-assistant] SKILL 级联结论` 到 `## Research Findings` 段末，禁改既有内容
- progress: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/progress.md — 可写=仅当前 Phase 段「Actions taken」下追加 `  - [sub:04] <摘要>`
- knowledge-brief: /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/knowledge-brief.md — 只读

**检索优先契约（Rule 63）**：遇到不确定的原文串，先 Read 目标行核对再改；禁凭记忆猜行内容。
**反死磕触点（Rule 75.2）**：Edit 匹配失败先 Read 当前行实际内容，禁反复重试同一替换串。

**材料包绝对路径**（worktree 内，唯一改动对象）：
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/SKILL.md — 当前 556 行；目标行：:9（全集索引 bullet）、:64（创建确认验证行）、:312（Critical Rules 详解段）、:403（References 表 critical-rules 行）、:245（C55 合规行）、:413（References 表 knowledge-brief 模板行）

**上下文依赖（精确替换串表；每处先用 Read 核对原行再 Edit；E1-E8 为编辑编号非步骤序）**：

| 编号 | 位置 | 原串（精确，含行首上下文） | 新串 |
|------|------|--------------------------|------|
| E1 | :9 | `Critical Rules 全集 1-76（` | `Critical Rules 全集 1-80（` |
| E2 | :9 | `Rule 76 总结阶段格式可读性与审查清单实体化纪律、Rule 36 技能修改保守化与功能删除防护）` | `Rule 76 总结阶段格式可读性与审查清单实体化纪律、Rule 80 用户会话逐字记录与只写不改纪律、Rule 36 技能修改保守化与功能删除防护）` |
| E3 | :64 | `确认创建了 6 个文件（task_plan.md / findings.md / progress.md / notepad-learnings.md / verification.md / knowledge-brief.md）（task-v116：v067 起第 6 文件，v107 R-01 清账）` | `确认创建了 7 个文件（task_plan.md / findings.md / progress.md / notepad-learnings.md / verification.md / knowledge-brief.md / user-session-log.md）（task-v116：v067 起第 6 文件，v107 R-01 清账；user-session-log.md=第 7 文件，task-v169 Rule 80）` |
| E4 | :312 | `Critical Rules 1-76（含 Rule 40-76 全集` | `Critical Rules 1-80（含 Rule 40-80 全集` |
| E5 | :312 | `Rule 76 总结阶段格式可读性与审查清单实体化纪律））` | `Rule 76 总结阶段格式可读性与审查清单实体化纪律 / Rule 80 用户会话逐字记录与只写不改纪律））` |
| E6 | :403 | `Critical Rules 1-76（含 Rule 13-18` | `Critical Rules 1-80（含 Rule 13-18` |
| E7 | :403 | `Rule 76 总结阶段格式可读性与审查清单实体化纪律（task-v166）） \|` | `Rule 76 总结阶段格式可读性与审查清单实体化纪律（task-v166） / Rule 80 用户会话逐字记录与只写不改纪律（task-v169）） \|` |
| E8 | :245 后插入 | （C55 行下一行插入） | `\| C56 \| 用户会话逐字记录与只写不改自查（Rule 80）：本任务每次用户发言已逐字落盘 user-session-log.md（80.1）；写入=append-only，历史条目零改写零删除零重排（80.2）；会话恢复先读专档再读 task_plan.md（80.4）（机器面=selftest-session-log.sh 静态断言+check-complete SESSION-LOG GATE，记录内容人工核查；mini 档豁免） \| ☐ \|` |
| E9 | :413 后插入 | （knowledge-brief 模板行下一行插入） | `\| \`templates/user-session-log.md\` \| 用户会话逐字记录专档模板（init-session 第 7 文件；append-only 只写不改，条目格式+恢复协议，Rule 80） \|` |

- 硬约束：SKILL.md 总行数改动后 ≤581（现 556，预计 +2=558）；既有 Rule 76 文本与其余一切内容零删改；禁触碰 config.json；E3 新串中竖线为表格内容字符，按上表转义形态书写最终行时保持行原管道结构

## 3. 验收标准（可观察证据）
1. `grep -c '1-80' <worktree>/skills/task-planner/SKILL.md` =3 且 `grep -c '1-76' ` =0
2. `grep -c '7 个文件' ` ≥1 且 `grep -c 'user-session-log.md' ` ≥2（:64 行与新增 References 行）；`grep -c '| C56 |' ` =1
3. `wc -l < SKILL.md` ≤581；`git diff --numstat skills/task-planner/SKILL.md` 删除行=0（纯原地替换+两行插入）
4. `grep -c 'Rule 76' ` ≥5（SRV-04 依赖 Rule 76 提及数不降）；`grep -c '40-80 全集' ` =1

## 4. Scope 禁改清单
- 禁止修改：SKILL.md 除上述六处以外的任何内容；scripts/**；references/**；templates/**；config.json；plans/task-v168-session-anchor-skill-activation/ 任何文件；~/.zcode/skills/**
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
- /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/04-code-assistant-skill.md
- 每完成一处 Edit → 追加带时间戳里程碑行；结束 → 写「最终结论」段（同一 8 字段块）并置 status: done；受阻 → 写「错误与受阻」段并置 status: failed

## 9. 上下文预算
只读本任务书列出的路径/区段，不做计划外探索。

## 10. 防幻觉契约（Rule 71.5）
全部事实性输出带来源锚（file:line/命令原文/已读区段行号）；禁无来源具体化；信息缺失显式写「未验证」；结论区「事实+锚点」成对。
