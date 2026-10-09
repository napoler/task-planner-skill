# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->

- R1[手段] 按用户给定方向修正 skill：把「无来源虚构内容专项审计」SOP 制度化进 task-planner 技能层（用户指令原文见 task_plan.md 🎯 用户需求原文区）。
- R2[目标] 三态判定机制落地：有源=附 file:line/URL/命令输出原文/工具调用记录四者之一；无源含事实=违规；显式占位=合法——处置=删除或降级占位，禁「补一个源」蒙混，不确定从严判无源。
- R3[目标] 写入前 5 问自检 + 最小版口诀「无源不写，空段占位，写必带锚」成为可执行纪律（规则条+模板注释+派发契约三位一体）。
- R4[目标] 【防幻觉契约】产出=全部事实性输出带来源锚；禁无来源具体化；缺失显式「未验证/暂无」；结论区「事实+锚点」成对。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| v153 fix-prompts A/B/C（事故素材+提示词组） | plans/task-v153-parallel-scheduling/fix-prompts.md:1-55 | ✅ 全文 Read | Research Findings §1 |
| task-planner SKILL.md | skills/task-planner/SKILL.md:281-345（Critical Rules 区） | ✅ Read 区间 | Research Findings §3 |
| critical-rules.md | skills/task-planner/references/critical-rules.md:853-876（Rule 68 段） | ✅ Read 区间 | Research Findings §3 |
| subagent_dispatch.md 模板 | skills/task-planner/templates/subagent_dispatch.md:1-60 | ✅ Read 区间 | Research Findings §4 |
| findings/progress 模板 | skills/task-planner/templates/findings.md、progress.md（全文 43/63 行） | ✅ 全文 Read | Research Findings §5 |
| 宪法反造谣铁律 | /home/terry/.zcode/AGENTS.md §三 | ✅ 会话注入 | Technical Decisions §1 |
| 跨会话记忆（幻觉纪律） | /home/terry/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/hallucination-placeholder-discipline-20261009.md | ✅ 会话注入 | Research Findings §1 |
| Rule 编号预留台账 | plans/.rule-reservations.jsonl（rule-reserve.sh list 输出） | ✅ 命令输出 | Research Findings §2 |

## Research Findings

### §1 素材定位：用户给定内容 = v153 fix-prompts A/B/C 的制度化合稿

- 用户本条指令的【目标】【审计口径】【铁律】= fix-prompts.md 提示词 A（溯源审计，fix-prompts.md:9-27）；5 问+最小版=提示词 B（写入前自检，fix-prompts.md:31-42）；【防幻觉契约】=提示词 C（派发契约行，fix-prompts.md:44-48）。语义逐条对照一致（本回合 Read 原文核对）。
- v153 事故源：2026-10-09 编写 findings.md 时 Visual/Browser Findings 模板空段被填入本会话无任何来源的内容，当次自查发现并删除（fix-prompts.md:3-5）。
- v153 结论中明确留了制度化通道：「若未来要进技能层（templates/subagent_dispatch.md），属保护区文件改动，须用户授权+worktree，本任务不越权」（fix-prompts.md:54）——**用户本条指令即该授权**。
- 记忆层已有跨会话沉淀：hallucination-placeholder-discipline-20261009.md（A/B/C 提示词指针+教训）。本任务把记忆指向的素材升级为规则/模板/守护三层机制。

### §2 编号与键位现状（命令输出锚）

- 04:28 旧快照（master@78b9659，worktree 初建前）：65/66/68 landed；67 reserved(v152)；69 reserved(v154)；70 reserved(v155)；71 free。
- 04:45 新基线（master@5280cb3，v154 已合并回）：Rule 69 landed；71 仍 free——本任务已 reserve：`[rule-reserve] rule 71 reserved by task-v158-source-anchor-discipline`（2026-10-10）。
- SKILL.md 合规清单 C47 已被 v154 Rule 69 占用（SKILL.md:224 实测）→ 本任务合规编号=**C48**。
- config.json 反查 `source_anchor|anti_halluc|no_source` 零命中 → 新机制可零新 config 键（对齐 25.4/43.4/66.6 零新键纪律）。

### §3 级联面一手清点（两次 grep 实测）

**04:28 旧快照（master@78b9659）**：skills/ 内 30 处 / 12 文件（workflow-orchestration×5、SKILL×4、requirement-coverage×4、tool-selection×3、self-resolution×3、lane-advancement×3、research-first×2、parallel-scheduling×2、registry.tsv×1、split-pattern-library×1、critical-rules×1、skill README×1）；仓根 README_zh/CLAUDE 三处。

**04:45 新基线（master@5280cb3，v154 合入后）**：skills/ 内 **16 处 / 6 文件**——selftest-requirement-coverage.sh×4、selftest-tool-selection.sh×3、selftest-self-resolution.sh×3、selftest-lane-advancement.sh×3、selftest-research-first.sh×2、SKILL.md×1（:287 详见行）；仓根 3 处不变（CLAUDE.md:33、README_zh.md:136,229，v154 已将其演进为 "Rules 1-69" 形态）。CHANGELOG.md 需追加 Rule 71 条目（对齐 Rule 68/69 条目形态，CHANGELOG.md:12）。

> 级联基准以执行时 `grep -rn "1-69"` 实锚为准逐文件改，禁凭快照数硬套（v154 合流已改变分布面）。

### §4 落点格式现状

- critical-rules.md 规则段格式=「### NN 标题（日期 task-id，目标：…）」+ NN.1..NN.7 子条 + NN.x 机制（Rule 68 段实证 :853-876）。
- SKILL.md Critical Rules 区（:283-）：详见行含「Critical Rules 1-68」计数 + 每 Rule 一行 bullet + 合规清单编号现到 C46（v153 Rule 68 的 C46）→ 本任务新增 bullet + 计数 1-68→1-71×4 + C47。
- subagent_dispatch.md（88 行）= 九字段派发模板（§1 目标/§2 输入/§3 验收/…）；防幻觉契约段拟插入位=§3 验收标准之后、§7 返回格式之前（字段结构位置，最终以 Edit 实况为准）。
- findings.md/progress.md 模板**当前无任何防幻觉注释**（Visual/Browser Findings 段仅有多模态落盘提示 findings.md:38-40；progress Test Results 表 progress.md:32-39）——即 v153 记忆所称「模板注释已强化口径」在仓内模板**未兑现**（一字无防幻觉字样，本回合全文 Read 实证）。此即本任务 Phase 3 的 gap。

### §5 环境与边界事实

- worktree：/mnt/data/dev/task-planner-skill-worktrees/task-v158-source-anchor-discipline（§11.2 路径规范）。**初建时 master 正被并行会话推进**（worktree add 落 f6d6158，主仓随后合入 v154 至 5280cb3）→ 已 `git merge master` 同步（worktree-branch-desync 教训复发：初建后必须与主仓 HEAD 对账）。
- 全量 selftest 基线（同步后 5280cb3 跑批）：**66 脚本 66 PASS / 0 FAIL**，证据=plans/task-v158-source-anchor-discipline/baseline-selftest.log（VC-4 对照基线）。
- 本会话身份：CLAUDE_CODE_SESSION_ID=de2c5bba-7058-47e2-8d6a-f0566b838159（env 实测）；ZCode hook 侧 sid=sess1cefd1cf（delegation-observe 输出）。
- plans/task-v157-error-fix-prompt-forge/ 的 .session-owner=sess cbab959f（sidmap de2c5bba→cbab959f，同本会话流），但其 task_plan.md 已被填成**另一方向任务**（「创建一个 skill：错误排查结果→专业修正提示词锻造器」，R1/R2 原文 diff 实证）——与本请求（制度化防幻觉 SOP）不同目标，**不并入不触碰**；v156-drift-shield 同理属同会话流其他任务。
- 主仓并行会话：wt/v152、wt/v154、wt/v155 三 worktree 在途（git branch 实测），均可能改 critical-rules.md/SKILL.md/selftest 钉值——合并策略=并集解（v149「v150 并行合并 5 冲突并集解」先例）。
- v150 PLAN TAMPERED 告警根因（非本任务引入）：attest（2026-10-09T05:36:28）之后 v150 task_plan.md 又被两个簿记性提交修改（02c61d7 COMPLETE 收尾、1a87387 Handoff 表裸名化 32→32 行）未重锁，`.plan-attestation` 哈希失配；本任务 Phase 1 顺带按 Rule 51.7 登记+重锁。


#### [sub:01-explore] 基线独立复验（S1）

1. 级联面：skills/ 内 6 文件 16 处（selftest-requirement-coverage×4/tool-selection×3/self-resolution×3/lane-advancement×3/research-first×2/SKILL.md×1）与 §3 快照一致；仓根 grep "1-69"（排除 CHANGELOG）= 0 命中——快照称 3 处（CLAUDE.md:33、README_zh.md:136,229），实测该 3 处仍为 "Rules 1-68" 形态，差异=仓根 3 处未演进为 1-69。
2. Rule 71：worktree 内 `rule-reserve.sh check 71` 输出 "free"（worktree 台账无 71 行）；主仓 plans/.rule-reservations.jsonl 含 `{"rule":71,"status":"reserved","task_id":"task-v158-source-anchor-discipline"}`——主仓已持有，worktree 台账未同步（§84 已记录）。
3. C48：SKILL.md:224 C47 行含 Rule 69，C48 零命中——C47 已占用、C48 空闲，PASS。
4. dispatch 插入位：subagent_dispatch.md §9 在 :85，§10 不存在——现有段落止于 §9，可插入，PASS。

#### [sub:03-code] SKILL.md 登记面 4 处改动实况（S-unit 03）

1. 详见行实锚=SKILL.md:287（非 design 假设的 1-69 全文形态）：原为「Critical Rules 1-69（含 Rule 40-69 全集…」，已行内替换为 1-71/40-71，括注尾部插「/ Rule 71 无源不写·空段占位·写必带锚纪律」（与 design-rule71.md §二.1 一致）。
2. Rule 71 摘要 bullet 插入位=Rule 68 bullet 后、Rule 69 bullet 前（现 :347，与 design-rule71.md:34 逐字一致）。
3. C48 合规清单行插入位=C47 行后（现 :225，与 design-rule71.md:38 逐字一致）。
4. **差异披露**：design §二.4 称 References 行「1-69→1-71」，实测 SKILL.md:370 该行计数标签为 **1-66**（v154 合入时未演进该行），为全文件除 :287 外唯一另一处计数标签——按 design「以 Edit 时 grep 实锚为准」指令改至 1-71。
5. 验收 5/5：grep -c "1-71"=2（:287/:370）；"Rule 71（无源不写"命中 1；"| C48 |"命中 1；git diff --numstat 仅 SKILL.md 4/2（deletions=2 均为行内替换旧行）；C47(:224)/Rule 68(:346)/Rule 69(:348) 原文零改动；grep -c "1-69"=0。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 新 Rule 71 而非扩展现有 Rule | 现有 Rule 26/43.1/51/54/63 覆盖「禁编造」总纲但无「写入前自检+空段占位合法化+溯源审计 SOP」执行细则；v153 fix-prompts 已是独立提示词组，制度化=独立 Rule 最清晰（71.7 说明与既有 Rule 关系，防语义重叠） |
| 三载体联动=critical-rules 规则条 + templates/dispatch 契约段 + findings/progress 模板注释 | 单层落地不够：规则=纪律总纲（人读）；契约段=传播面（子代理任务书必填，Rule 63.6 同款先例）；模板注释=事故温床的直接填埋点（v153 事故即 Visual/Browser Findings 空段） |
| 新 selftest-source-anchor-discipline.sh 静态守护 + registry 登记 | 对齐全仓既有模式（每个 Rule 一个 selftest）；静态边界如实披露在 71.7（三态语义判定不可机检，守护只锚载体存在性） |
| 30 处 1-68→1-71 级联用逐文件 sed + git diff 逐目审 | 30 处逐个 Edit 超单 S-unit 粒度；§五禁「未逐项审查的批量脚本」→ 逐文件 sed 后 git diff 全文目审每个 hunk 再提交（v152/v153 同路径先例） |
| 不建新 agent | YAGNI：溯源审计的派发型已可由 Explore/通用体承载（fix-prompts.md:29 已给 8 字段模板）；机器面=selftest+模板+规则已闭合；agent 化列为 future candidate 不进本任务 |
| template_type 判定=general（非 rule-enhancement） | init template-sense 输出 general 兜底；本任务同时改规则+模板+脚本+仓根文档，非单 variant 画像；沉淀评估按 34.3② 终验登记 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| 主仓 git status 有并行会话未提交变更（INDEX.md + 4 个 task-* 目录） | 只在本任务 worktree 内提交；主仓精确 add 仅 v150 两个簿记文件 |
| init-session.sh 需在 plans/<task-id>/ 内运行（仓根跑报错） | mkdir 后 cd 再跑，6/6 verified |
| worktree 内 plans/.rule-reservations.jsonl 无 71 行（主仓已 reserve） | 在 worktree 内幂等重 reserve（同 task-id+note），land 时持有人匹配；合并时台账并集解 |

## Resources
- /mnt/data/dev/task-planner-skill/plans/task-v153-parallel-scheduling/fix-prompts.md（A/B/C 素材源）
- /mnt/data/dev/task-planner-skill/plans/task-v153-parallel-scheduling/findings.md:§D（事故深潜，design-rule68.md 旁证）
- skills/task-planner/references/critical-rules.md（Rule 追加目标）
- skills/task-planner/templates/subagent_dispatch.md（契约段目标）
- skills/task-planner/scripts/selftest-registry.tsv（登记目标）

## Visual/Browser Findings
<!-- 2026-10-10 task-v158：本任务无截图/PDF/网页多模态信息——本会话未产生该类证据；按 Rule 71.5 空段显式占位为合法交付形态（本次以身作则） -->
（本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应升级警告(Rule 26.3 处置) -->
