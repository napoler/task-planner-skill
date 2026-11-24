# 计划独立审计门任务书（Rule 109，只读）

## 1. 目标
审计 task-planner 计划是否满足交付前质量标准。只读，禁改任何文件。

## 2. 输入（绝对路径，必读）
- /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/task_plan.md
- /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/user-session-log.md（用户原话 #1 #2，需求锚唯一事实源）
- /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/knowledge-brief.md
- /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/verification.md（VC 表）
- findings: 同目录/findings.md（可读，可追加 #### [sub:S0-audit] 到 Research Findings 段）
- progress: 同目录/progress.md（可读，可追加 Actions 行）

背景：用户 /goal 要求方法论层修正三缺陷（①默认worktree却多会话争写同文件②发现冲突未走worktree补救③Superpowers/OpenSpec从未激活）。用户新思路："依赖todo引擎推进=最简单方案，把检测是否用OpenSpec/Superpowers列为todo默认项(B选项)，像对齐一样；之前加的东西不丢弃"。设计定案=方案A：todo基线组B1-B5→B1-B8（B6引擎检测/B7对齐落地/B8 worktree核验），修sync-todos脚本产出+模板露出+selftest守护三层载体。

## 3. 验收（六维审计，逐维结论+file:line证据）
1. 需求覆盖完整性：#1/#2 每条诉求（worktree/冲突补救/引擎激活/定位守正/不推翻既有/todo默认项/对齐不丢）是否都有 R 与 VC？有无 51.9 自缩水（系统级缩成单点）？
2. 机制设计合理性：方案A是否真解决"纯文本契约无机器载体"根因？B6/B7/B8 可操作？
3. 既有机制冲突面：B1-B5→B1-B8 与 Rule 106.5 冲突面是否识别？改动面清单是否完整（todo-sync.md/critical-rules-discipline.md/SKILL.md/templates/sync-todos.sh/selftest）？
4. 比例原则：用户要"最简单方案"，方案A是否过度工程？机器硬门"仅登记不实施"是否符合文本优先？
5. VC 判别性：逐条查 VC-1..6 command 真可执行、有判定力（能区分PASS/FAIL），无反引号/127伪FAIL/恒真命令？VC-4 的 sync-todos --json 断言是否真实有效？
6. 篡改面：需求锚逐字引用原话（非转译）？有无计划外承诺"加戏"？

裁决映射：0 CRITICAL 且 0 IMPORTANT ⇒ APPROVED；否则 REJECTED。W/Q/N 留档不阻断。每个问题给显式 key（I-1/C-1）与 state=open。

## 4. Scope 禁改
只读审计，禁改审核对象文件；禁 git 写；伴飞技能=无。

## 7. 返回格式（8 字段固定，之后无任何内容）
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS 2:PASS ...]
files: <绝对路径>(+N/-M); ... | none
evidence: verdict=<APPROVED|REJECTED>; counts=C<n>I<n>W<n>; <file:line 关键证据>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <findings.md 小节锚点 #### [sub:S0-audit]> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```
裁决结论（verdict/counts/六维结论/issues 清单）写入 evidence 字段（可换行），不要放在 8 字段之外的自由文本里。

## 8. checkpoint 落盘
文件：/mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S0-auditor.md
格式：头部status行+六维结论+issues清单+最终结论（=第7节同一8字段块）；纯markdown无frontmatter。

## 9. 上下文预算
只读四文件+VC表；禁整库通读；总长≤1200字。
