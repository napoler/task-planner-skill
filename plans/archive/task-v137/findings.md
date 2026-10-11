# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1（消耗冗余）：设计/审计代理派发的基线定数内联重建与规范原文重复读取 → 以台账供料收窄（机制详见提案）
- R2（「继续」）：授权实施呈示的落点 1-4 + critical-rules 21.2.1 子条款

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| 设计代理输入收窄方案 | /mnt/data/dev/task-planner-skill/plans/cost-analysis-2026-10-05/design-input-narrowing-proposal.md | ☑ 计划期全文消费 | Research Findings + task_plan 全文 |
| skill critical-rules 锚点 | skills/task-planner/references/critical-rules.md | ☑ 实测 | Research Findings（锚点实测段） |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **[Phase 1] worktree 基线与锚点终验（2026-10-05 实测）**：
  - worktree /home/terry/task-planner-skill-worktrees/task-v137（wt/task-v137 @ 4e734b2）创建成功
  - 锚点终验全对齐：21.2@critical-rules.md:145；knowledge-brief.md 61 行、`^## §` 计数=5；subagent_dispatch.md 76 行；critical-rules.md 590 行；rule-enhancement-type.md 122 行；SKILL.md 478 行
  - **全量 selftest 基线 = 51 脚本 / PASS=760 / FAIL=0**（主进程逐脚本 Total 行求和，Phase 3 对照值）
  - 与提案旧值差异记录：提案时点 21.2@:144/CR 567 行 → 现场因 task-v131/v132/v133 合入漂移至 :145/590 行；提案的「53 可用」已被 task-v131 占用事实取代（均已在计划中修正）
- **[S1] brief 模板供料行型落地（2026-10-05，executor 回执+主进程 Read 复核）**：worktree 内 templates/knowledge-brief.md +7/-0（61→68 行），§2/§3/§5 各加台账供料注释说明+示例行——§2 台账供料源行型（台账锚+原文重验锚并列、缺口维度禁顶替）、§3 设计插入点+范式锚行型（插入点/B8 最大 landed 范式块/时效戳）、§5 台账产物绝对路径行型。五段锚=5、grep 台账供料=4、纯增量 verified（git diff 7 insertions/0 deletions）。证据：worktree git diff + subagent-state/2-executor-s1.md
- **[S2] dispatch 注入纪律行落地（2026-10-05，executor 回执+主进程 Read 复核）**：worktree 内 templates/subagent_dispatch.md +2/-0——📚 表体 :38 新增基线定数纪律行（一律经 brief §2/§3 台账路径锚供料、prompt 禁内联重建、收口 v116 A2 变体）+ :34 Why 注释（含 22.4 §9 禁双份供料引用）。§2 三文件块与 §7 八字段块零变化（hunk 仅 @@ -31,9 +31,11 @@），纯增量 verified。证据：worktree git diff + subagent-state/3-executor-s2.md
- **[S3] critical-rules 21.2.1 子条款落地（2026-10-05，executor 回执+微调+主进程 Read 复核）**：worktree 内 references/critical-rules.md +1/-0——21.2.1「台账供料优先(task-v137)」@:146（21.2@:145 与 21.3@:147 之间），三要素齐备（brief §2/§3/§5 台账供料禁内联/过期维度重测带时效戳/禁双份供料引用化）。**过程中发现并修复**：首轮条款行含「22.4 §9」字面，会被 T6 断言的行号提取链（grep knowledge-brief|grep '22.4'|head -1）误命中致报告行号失真——微调去掉 "22.4" 子串后 T6 报告真实 22.4@:168，PASS 且语义恢复。T6 实跑 PASS。证据：worktree git diff + sed '145,147p' + subagent-state/4-executor-s3.md（含微调段）
- **[S4] variant 必读表行落地（2026-10-05，executor 回执+主进程 Read 复核）**：worktree 内 templates/variant/rule-enhancement-type.md +1/-0——📚 必读表 :100 新增「台账供料简报（Rule 编号账本+审计台账路径等）| brief §2/§3/§5 | ☑」行，4 列结构与表头对齐，:40-46 强制约束区零触碰。**Phase 2 合计**：4 文件 +11/-0 纯增量（brief 7/dispatch 2/CR 1/variant 1），四落点全部一次通过验收（S3 含一次自发现自修复的微调）。证据：worktree git diff --stat + subagent-state/5-executor-s4.md
- **[Phase 4] 对齐审查与修复波（2026-10-05）**：alignment-review 执行体（general-purpose 隔离上下文）逐 8 项机器取证：多副本四位 md5 五方全等/守卫 16/16+41/41/术语三形态同源/无越界——**CHANGES_REQUESTED**：P0-1 = :146「Rule 22 §9」错挂（真实载体=派发模板 §9 上下文预算，Rule 22 §9 误解析到 22.9）；P2-1 = 「B8」任务代号泄漏永久模板；P2-2 = T6 行号提取链脆弱（既存，登记 deferred）。修复波（executor，5234243）：:146 改挂真载体 `templates/subagent_dispatch.md` §9（不再含 "22.4" 子串，T6 报真实 22.4(168)）+ variant:100 去 B8 + brief §3 示例行占位符化（顺带消除「### 52 最新」过时定数）。重合并 b11f3fd → 四位重部署 IDENTICAL → 终验 51 脚本 FAIL=0。证据：subagent-state/7-alignment-review.md + 8-executor-fix.md + master git log
- **[终验] VC 逐条复验（2026-10-05）**：VC-1 PASS（grep 台账供料=4、^## §=5、68≤150）；VC-2 PASS（:34/:38 纪律行在位、§2/§7 零变化）；VC-3 PASS（21.2.1@:146、T6 窗口 100<168<200）；VC-4 PASS（variant:100）；VC-5 PASS（51 脚本 FAIL=0、SKILL.md=478 零改动兑现）；VC-6 PASS（四位 IDENTICAL、INDEX/ledger 簿记、worktree 已清理）→ **6/6 COMPLETE**

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 21.2.1 子条款承载而非新 Rule | Rule 53 已被 task-v131 占用（账本 landed）；子条款零级联（SKILL:9 索引/合规清单/Rules 1- 锚断言三面全免），提案 §三 时效补记同结论 |
| SKILL.md 零改动 | 478 行恰压 selftest-skill-split.sh T2 钉 ≤478，净增 1 行即碎；模板表 :323 行描述已含 knowledge-brief 无需改 |
| 不新增 selftest 断言 | 触发 51→52 脚本数与 760 基线和的定数级联；既有 T1b/T1c/T6/T7 + check-dispatch ③ 已覆盖供料行的回归面 |
| 计划撰写主进程直做 | plan-writer 派发两度被 KQ3 误拦（任务书含计划结构被计为打包/超限），白名单②+22.3④，见 progress.md Error Log |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| attest 首跑拒：S4 行验收列含未转义竖线破坏列解析 + Phase 3 派发型缺 S-unit 表 | 竖线改文字「竖线列结构完整」；Phase 3 补 S5 行后 attest 通过（SHA 45f5c4ce） |
