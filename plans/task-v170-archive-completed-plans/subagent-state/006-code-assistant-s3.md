# 006-code-assistant S3 检查点（SKILL.md 终验段接入归档步骤+Rule 81 摘要行）

- status: done
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans（分支 wt/task-v170-archive-completed-plans）

## T1 里程碑（时间戳）
- 00:35 读 progress.md Phase 2（接入点定稿=check-complete 行后 ≤6 行）+ SKILL.md 终验段 L158-212 与 Critical Rules 区 L310-379 + task_plan.md（Rule 81 契约/CA-2 位置/check-complete 行 L182-184 定位）
- 00:40 Edit #1：SKILL.md L184（`exit 1 → STOP…`）后插入归档步骤 1 行（新 L185，含 `bash scripts/archive-plan.sh <task-id>`、幂等/守卫拒绝处置、Rule 81.1 引用、Rule 45 Why 一句话）
- 00:41 Edit #2：Critical Rules 区 L379（Rule 76 行）后插入 Rule 81 摘要 1 行（新 L381，81.1-81.4 子条引用+Why）
- 00:45 验证：wc -l 556→558；git diff 仅 SKILL.md +2 行（另 S6 单元已并行落 set-active-plan.sh +8，本单元未触碰，commit 时 `git add` 仅 SKILL.md 单文件）
- 00:48 commit 622508a `feat(task-planner): task-v170/Phase 4 S3 — SKILL.md 终验段接入归档步骤+Rule 81 摘要行`（1 file changed, 2 insertions(+)，index.lock 无冲突一次成功）

## 最终结论（=§7 返回块）
status: done
acceptance: 3/3 pass
files: /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans/skills/task-planner/SKILL.md(+2/-0)
evidence: SKILL.md:185 归档步骤行（archive-plan.sh 命令+幂等/守卫拒绝+Rule 81.1）；SKILL.md:381 Rule 81 摘要行（81.1-81.4）；grep -c "archive-plan.sh"=2、grep -n "Rule 81"=2 命中；wc -l=558；commit 622508a `1 file changed, 2 insertions(+)`
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/subagent-state/006-code-assistant-s3.md (status: done)
findings_written: none
blockers: none
confidence: HIGH

## 级联清单（只输出不执行，交后续单元）
插入点：旧 L185-184 之间（+1 行）与旧 L380 前（+1 行）。位移规则：旧 L185-379 → +1；旧 L380+ → +2。
形态：全仓（worktree）grep `SKILL.md:NNN` 命中两类——① selftest 注释内行号锚 ② SKILL.md 总行数钉断言。硬 grep 行号锚断言=0 命中（行号只出现在注释）。

### A. 行号锚（注释级，建议同步演进）
| 文件:行 | 断言/锚原文（摘） | 建议新值 |
|---|---|---|
| skills/task-planner/scripts/selftest-self-resolution.sh:18 | 注释「SKILL.md:266 括注演进」 | 267 |
| skills/task-planner/scripts/selftest-self-resolution.sh:91 | 注释「SKILL.md:266 括注演进」 | 267 |
| skills/task-planner/scripts/selftest-reliability-institution.sh:14 | 注释「SKILL.md:278 括注演进」 | 279 |
| skills/task-planner/scripts/selftest-reliability-institution.sh:80 | 注释「SKILL.md:278」 | 279 |
| skills/task-planner/scripts/selftest-research-first.sh:77 | 注释「SKILL.md:288/299/307 实态」 | 289/300/308 |
| skills/task-planner/scripts/selftest-reliability-institution.sh:84 | 注释「SKILL.md:288 实态」 | 289 |
| skills/task-planner/scripts/selftest-self-resolution.sh:95 | 注释「SKILL.md:288 实态」 | 289 |
| skills/task-planner/scripts/init-session.sh:380 | 注释「消 SKILL.md:505 "自动路由"语义漂移」 | 507（注意：既有失真——「自动路由」已不在新 SKILL.md 任何行，旧 L505=AskUserQuestion 表行；本单元不改注释） |
| skills/task-planner/scripts/selftest-registry.tsv:50 | 「SKILL.md:206(C35),319(bullet)」 | 207/320（注意：既有失真——当前实态 C35=L225、Rule 51 bullet=L355，pin 早已落后 ≥18 行，建议 S10 一并校准到 225/355） |

### B. 总行数钉断言（本单元净 +2：556→558）
| 文件:行 | 断言原文（摘） | 现状/建议 |
|---|---|---|
| skills/task-planner/scripts/selftest-batch-pilot.sh:55（BP-08） | `[ "$lines" -le 558 ]`「SKILL.md 行数 ≤558」 | 558 贴线 PASS（零余量）；后续任何新增即破钉 → S10 需上调 |
| skills/task-planner/scripts/selftest-drift-check-subagent.sh:87-89（DCS-19） | `[ "$SKILL_LINES" -le 558 ]` | 同上 |
| skills/task-planner/scripts/selftest-knowledge-brief.sh:39（T2b） | `-le 558` | 同上 |
| skills/task-planner/scripts/selftest-execution-stability.sh:70-72（T8/T8b） | `-le 558` | 同上 |
| skills/task-planner/scripts/selftest-skill-collab.sh:81-82（T10） | `-le 558` | 同上 |
| skills/task-planner/scripts/selftest-goal-unit-goal-mode.sh:127-128 | `不超过 581`（含上限 584） | 558 PASS，无需本单元改 |
| skills/task-planner/scripts/selftest-skill-split.sh:50（T-主） | `≤581 且 ≤584` | 558 PASS，无需本单元改 |

### C. 非本单元范围（登记不执行）
- epoch 断言「Critical Rules 1-76/40-74 全集」字面（selftest-research-first.sh:77 RF-07 宽容锚、selftest-source-anchor-discipline 等）：属 S10 epoch '1-76'→'1-81' 级联范围
- 历史 plans/ 数据目录内 SKILL.md:NNN 引用（plans/task-v122 等）：历史事实记录，非活断言，不动
- critical-rules.md Rule 81 正文：属 S4 范围（本单元仅在 SKILL.md 两处以「详见 references/critical-rules.md Rule 81」指针引用）

## 负结果报告
- 检查依赖面：SKILL.md 全 558 行、task_plan.md CA-2/Rule 81 契约段、progress.md Phase 2 契约定稿、findings.md R2 行——无冲突
- 排除了在终验段 L165-181 中部插入（定稿接入点=check-complete 块后，即 L184 后）；排除了改 L313 头注/ L405 References 表「1-76」措辞（=epoch S10 范围，本单元不越界）
- 未发现对 SKILL.md:NNN 的硬 grep 行号断言（全部行号引用在注释/registry 文本内，改不改不触发 FAIL；registry tsv 有既有失真已标注）
