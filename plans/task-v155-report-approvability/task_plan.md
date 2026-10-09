# Task Plan: task-v155 汇报阶段呈报可审批性纪律（Rule 70）
<!--
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标] -->

- **R1**: 「让我审批，让用户审批内容的时候，竟然完全不列出需要审批哪些内容，连简介都不给，连文件地址都不给，你他妈让人家怎么审批？」<sub>（[目标]）</sub>
- **R2**: 「还有其他类似的情况，这种非常弱智的情况必须要得以修正。」<sub>（[目标]）</sub>
- **R3**: 「我希望的就是整个汇报阶段，可以让用户真正知道你做了什么。然后有哪些风险以及类似于产出有哪些？需要审核的有哪些？需要审核的那种地址有哪些？网址什么的都必须要给出。」<sub>（[目标]）</sub>
- **R4**: 「以及类似其他的东西全部需要补全，不要让用户审查一个莫名其妙的东西。」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | Rule 70 条文四要素锚 grep 命中；呈报触点文件逐一含 Rule 70 引用（缺口=0） |
| R2 | VC-2 | 审计清单 13 文件全部修补，`grep -l "Rule 70"` 全命中 |
| R3 | VC-1, VC-3, VC-5 | 四要素（做了什么=①清单/风险与产出=交付总结既有要素/待审项+地址=①②）条文+守护+lint 实测三链齐 |
| R4 | VC-3, VC-4, VC-6, VC-7 | 机器守护在位+全量回归 ΣFAIL=0+合并部署 IDENTICAL+双审查 APPROVED（防复发闭环） |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 结果级需求（用户可审批）分解呈报生产管线逐工序审计缺陷面 -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 条文层（规则定义） | 除 Rule 48 外无统一呈报契约（5 Whys 根因③④） | Rule 70 新条文（S1） | VC-1 |
| 触点层（各呈报点指令） | ~30 触点无四要素要求，只写「展示/确认/报告」（直接原因） | 触点修补 S3-S11（13 文件） | VC-2 |
| 模板层（呈报载体） | task_plan/batch_report/送审清单无看点/动作/清单规格 | 模板修补 S5-S7 | VC-2 |
| 审查工具层 | review-library 输出合约缺审查对象总清单 | S10-S11 输出合约补行 | VC-2 |
| 机器层（守护） | 呈报完整性零守护（根因⑤） | selftest-report-reviewability.sh + check-complete lint（S12-S15） | VC-3, VC-5 |
| 回归层 | 新增行撞既有锚级联（历史 5 次判例） | 全量回归+级联清账（S16-S17） | VC-4 |
| 分发层 | 部署位漂移（历史判例） | 合并回+--deploy 对账 IDENTICAL（P9） | VC-6 |

<!-- plan_tier: standard -->
## Goal
task-planner 技能全工作流所有「向用户请求审批/审查/确认/呈报」的触点强制执行 Rule 70 最小呈报信息集（①待审项清单+逐项简介 ②可定位地址 ③看点 ④动作+默认项），并以机器守护（selftest+check-complete lint）固化，杜绝「让用户审批一个莫名其妙的东西」。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 代码文件且 >50 行，重 diff 全量 CR） |
| `session_id` | `task-v155-20261010-bc12ebe6` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability` |
| `scope_files` | 见「⚠️ 执行范围限制」表 |
| `interaction_mode` | `ask`（默认；D1 按 Rule 44.3 自治自动裁决并登记五要素，见 Decisions Made） |
| `对齐审查` | P8/S19 alignment-review（review-library 池），CHANGES 闭环复验；变更记录三要素落 verification.md |
| `自动超时默认项` | D1 计划批准：默认项=按本计划执行（推荐）/超时 5min；其余询问点：默认=推荐项/5min；自治会话一律按 44.3 自动裁决+登记五要素，D6 硬停点除外 |
| `new_rule` | `70`（账本核实：66 landed，67=v152/68=v153/69=v154 已预留，70 可用） |
| `质量审查工具` | 四级检测：项目级无专用→用户级 review-library 池命中 `code-quality-review`（代码面）+`alignment-review`（对齐面）；执行期 P8 必须用登记工具；无待补建缺口 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 70 条文在位：`^## Rule 70` 段落含 70.1-70.6 子条锚，四要素关键词（待审项清单/可定位地址/看点/动作）各 ≥1 命中，条文内无硬编码行号锚 | grep 命令 | `cd <worktree>/skills/task-planner && grep -cE "70\.[1-6]" references/critical-rules.md` ≥6 且 `grep -c "待审项清单\|可定位地址" references/critical-rules.md` ≥2 |
| VC-2 | 触点修补零缺口：审计清单 13 文件（findings.md 触点审计表）逐一含 Rule 70 引用或四要素结构补齐 | 逐一 grep | `grep -l "Rule 70" <13 文件逐一>` 全命中，缺口计数=0 |
| VC-3 | 机器守护在位：selftest-report-reviewability.sh 存在可执行且自跑 exit 0；registry.tsv 有登记行；check-complete.sh 含 report-lint 段 | 运行命令+grep | `bash skills/task-planner/scripts/selftest-report-reviewability.sh; echo $?` → 0 |
| VC-4 | 全量回归零破坏：worktree 内全部 selftest 脚本 ΣFAIL=0 | 批量运行 | `for f in skills/task-planner/scripts/selftest-*.sh; do bash $f; done` 汇总，Round 记录落 progress.md |
| VC-5 | lint 行为实测：对含 delivery-summary.md 的计划目录跑 check-complete.sh 输出 report-lint 行，且 exit code 与 master 基线一致（fail-open 不改 exit 语义） | 运行命令对照 | worktree 与 master 各跑一次对照输出 |
| VC-6 | 合并回+部署：master 存在 --no-ff merge commit；部署位逐位 diff=0（IDENTICAL） | git log+diff | `git log --oneline -3` + 逐位 `diff -r` 对账 |
| VC-7 | 双审查 APPROVED：code-quality-review 与 alignment-review 双 verdict=APPROVED（CHANGES_REQUESTED 已修复并复验闭环） | 审查 verdict | checkpoint 文件 + findings.md 审查段 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🎯 核心目标达成裁决（Rule 58.5 — 终验必填）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1/R2/R3/R4（全部 [目标]） |
| **裁决** | （终验填写：solved / partial / not-solved） |
| **解决证据锚** | （终验填写：VC-1..VC-7 证据行；solved 必填） |
| **未解决面+原因** | （partial/not-solved 必填） |
| **已排除路径** | （not-solved 必填） |
| **下一步建议** | （not-solved 必填） |

> 判据（58.4 问题解决判据）：用户再收到任何审批/审查请求时，请求自带待审项清单+可定位地址+看点+动作（契约链=条文→触点→守护三层全部在位且机器可验证）。

## 🎯 Goal 单元表（Rule 66.1 — standard 必填）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 调研与归因 | 全触点审计+Rule 31 四维归因落盘 | findings.md 触点审计表 13 文件锚+归因段在位 | S0/Phase 1 | complete |
| G2 | 条文与索引 | Rule 70 条文+SKILL 接线落位 | grep 70.1-70.6 锚 ≥6；SKILL 索引含 Rule 70 | S1-S2/Phase 2 | complete |
| G3 | 主链触点 | SKILL/reference/worktree 触点四要素指针 | 3 文件 grep Rule 70 命中 | S3-S4/Phase 3 | complete |
| G4 | 模板触点 | 4 模板呈报规格补全 | 4 文件 grep Rule 70 或四要素词命中 | S5-S7/Phase 4 | complete |
| G5 | 管线触点 | 引用面+管线 6 文件补齐 | 6 文件 grep 命中 | S8-S11/Phase 5 | complete |
| G6 | 机器守护 | selftest+lint+registry 落位 | selftest 自跑 exit 0+registry 行在位 | S12-S15/Phase 6 | complete |
| G7 | 回归清账 | 全量 selftest ΣFAIL=0 | 跑批记录（progress.md Round 行四要素） | S16-S17/Phase 7 | complete |
| G8 | 双审查 | 代码面+对齐面双 APPROVED | 两 checkpoint verdict=APPROVED | S18-S20/Phase 8 | complete |
| G9 | 合并交付 | 合并+部署 IDENTICAL+终验交付 | merge commit+逐位 diff=0+delivery-summary | P9 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 条文/索引（worktree 内） | skills/task-planner/SKILL.md、skills/task-planner/references/critical-rules.md | 其他技能文件 |
| 引用面（worktree 内） | skills/task-planner/reference.md、skills/task-planner/references/worktree-isolation.md、skills/task-planner/references/batch-quality-gate.md | 其他 references |
| 模板面（worktree 内） | skills/task-planner/templates/task_plan.md、templates/batch_report.md、templates/variant/image-type.md、templates/variant/multiview-ref-type.md | 其他模板（含 delivery-summary.md——已是金标准不动） |
| 管线面（worktree 内） | skills/task-planner/review-library/{general-review,alignment-review,code-quality-review}/SKILL.md、companion/agents/{article-batch-publisher,article-field-fixer,plan-writer}.md | 其他 companion/review 文件 |
| 守护面（worktree 内） | skills/task-planner/scripts/selftest-report-reviewability.sh（新建）、scripts/selftest-registry.tsv、scripts/check-complete.sh | 其他脚本；config.json（零新键，禁改） |
| 簿记（主仓） | plans/task-v155-report-approvability/*（计划系统文件，Rule 25.3 白名单②） | 其他 plans/ 目录（v152/153/154 并行在途，禁碰） |
| 部署位 | 仅 P9 合并后由 smart-merge-back.sh --deploy 流程写入 | 手工直改部署位 |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做这个修改吗？（用户 2026-10-10 显式指令「必须要得以修正…全部需要补全」）
- 全部 Yes → 可以执行 | 任一 No → 先问用户

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档 | delivery-summary 模板（呈报金标准+Rule 48.2 五条硬规则） | /mnt/data/dev/task-planner-skill/skills/task-planner/templates/delivery-summary.md | 必读 | ☑ |
| 项目内部文档 | critical-rules.md Rule 48/28/44/41/36（呈报相关既有条文） | <技能根>/references/critical-rules.md | 必读 | ☑ |
| 项目内部文档 | selftest 范式与 registry 登记纪律（4 列：script/domain/trigger_scenarios/dep_anchors） | <技能根>/scripts/selftest-research-first.sh + selftest-registry.tsv | 必读 | ☑ |
| 项目内部文档 | worktree 隔离 SOP | <技能根>/references/worktree-isolation.md | 参考 | ☑ |
| 项目内部文档 | 规则编号预留账本 | /mnt/data/dev/task-planner-skill/plans/.rule-reservations.jsonl | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）
**核心问题**: 呈报生产链（条文→触点→模板→守护）缺失统一「最小呈报信息集」契约，导致用户收到审批/审查请求时无从知道审什么、去哪看、看什么、回什么。解决后能交付：能——契约链三层落地且机器可验证（VC-1/2/3）。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？
- [x] 核心问题不解决，其他工作都白费吗？（只修单点=第三次复发）
- [x] 核心问题的解决方法是清晰的、可执行的？

## 🔍 证据面清单（Rule 58.1）
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 本技能 ~30 呈报触点全量 | Explore 子代理 very thorough 审计（2026-10-10） | findings.md#触点审计 | ☑ |
| ② 对标样本（58.2 强制） | 同仓金标准=templates/delivery-summary.md+Rule 48（task-v123 用户裁决落地的成功先例） | 主进程直读全文 | findings.md#金标准现状 | ☑ |
| ③ 外部约束 | selftest 锚级联纪律（历史 5 次判例）+registry 登记纪律+并行任务编号预留 | 记忆+账本核实 | findings.md#Resources | ☑ |

## Current Phase
Phase 9（全部 complete）

## Next Step
交付完成（见 delivery-summary.md；下一步=task-v156 立项待用户授权）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore(mini) | 跨 20+ 文件触点审计（Rule 13 隔离）——已完成 |
| Phase 2 | Agent 子代理 executor(sonnet-1) | 条文落位为判断型文本写入（新材料包内联于本计划） |
| Phase 3-5 | Agent 子代理 code-assistant(haiku-1) | ≤2 文件/≤15 行机械指针补丁（最小可承载档，43.2） |
| Phase 6 | Agent 子代理 executor(sonnet-1) | 新 selftest+lint 为判断型脚本编写 |
| Phase 7 | Agent 子代理 code-runner-agent(mini)+executor | 跑批与级联修复分离；跑批=机械 IO |
| Phase 8 | Agent 子代理 code-reviewer(sonnet-1)+general-purpose(对齐审查) | 独立审查视角（§一路由表） |
| Phase 9 | 主进程（白名单①git 编排+②簿记） | smart-merge-back/deploy/簿记为编排动作 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（用户未点名 /workflow；子任务同文件强串行为主）→ 按 Rule 21.4 独立性守门调度；写集均不相交的 S-unit 按声明组并行（S5‖S6‖S7、S10‖S11、S18‖S19），其余串行
**/goal 对齐（Rule 40.3）**: 本计划 Goal+Goal 单元表即 session goal 证据源；用户未用 /goal 锚定；技能层不可代调

## Phases

### Phase 1: 调研审计与归因
- [x] 全触点审计（Explore 子代理，very thorough，~30 触点缺口表）
- [x] 金标准对照（delivery-summary 模板 + Rule 48 直读）
- [x] Rule 31 四维归因（5 Whys 根因=单点补丁未泛化+零机器守护）
- [x] 结论落盘 findings.md
- **V-N:** VC-2, VC-1
- **Status:** complete
- **Executor:** explore（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 前置依赖 | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|----|
| S0 | 全触点呈报缺口审计+Rule 31 归因 | explore(mini) | skills/task-planner/（20+ 文件扫描，审计式派发） | - | 缺口触点表+归因段落落盘 findings.md | 15min | 0f/0l/15min | 无 | complete |

### Phase 2: Rule 70 条文与 SKILL 主索引
- [x] critical-rules.md 追加 Rule 70 条文（§70.1-70.6，材料=本计划「📜 Rule 70 条文草案」节）
- [x] SKILL.md 主索引接线（Rules 全集行/References 表/终验交付段联动/合规清单 C46）
- **V-N:** VC-1, VC-3
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 前置依赖 | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|----|
| S1 | Rule 70 条文写入 critical-rules.md（Rule 66 之后追加，不硬编码行号锚） | executor(sonnet-1) | skills/task-planner/references/critical-rules.md + plans/task-v155-report-approvability/task_plan.md（§条文草案逐字采用） | - | `grep -cE "70\.[1-6]" references/critical-rules.md` ≥6 | 15min | 1f/60l/15min | 无 | pending |
| S2 | SKILL.md 接线：Rules 全集行加「Rule 70 用户呈报可审批性纪律（task-v155）」条目+范围改「1-66+70（67-69 并行预留）」、References 表 critical-rules 行同步、终验交付段补 Rule 70 联动半句、合规清单新增 C46 行（材料=本计划 §接线材料包） | executor(sonnet-1) | skills/task-planner/SKILL.md + plans/task-v155-report-approvability/task_plan.md（§接线材料包） | - | grep "Rule 70" SKILL.md ≥4 命中且 C46 行在位 | 15min | 1f/12l/10min | 无 | pending |

### Phase 3: 触点修补 A（主链呈报点）
- [x] SKILL.md 触点指针行（计划确认/drift BLOCKED/CR Gate/B-C 变更四段）
- [x] reference.md + worktree-isolation.md 呈报点指针行
- **V-N:** VC-2, VC-4
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 前置依赖 | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|----|
| S3 | SKILL.md 四触点段各补「呈报按 Rule 70 四要素」指针半句（材料=§触点指针材料包 T1-T4） | code-assistant(haiku-1) | skills/task-planner/SKILL.md + plans/task-v155-report-approvability/task_plan.md | - | 4 处 grep "Rule 70" 新增命中 | 10min | 1f/10l/10min | 无 | pending |
| S4 | reference.md 升级呈报点+worktree-isolation.md 四个 STOP/报告点补 Rule 70 指针行（T5-T6） | code-assistant(haiku-1) | skills/task-planner/reference.md + skills/task-planner/references/worktree-isolation.md | - | 两文件 grep "Rule 70" ≥5 命中 | 10min | 2f/10l/10min | 无 | pending |

### Phase 4: 触点修补 B（模板面）
- [x] templates/task_plan.md 呈报字段规格补全
- [x] templates/batch_report.md 面向用户呈报区块规格
- [x] 送审清单模板补 看点/动作 列
- **V-N:** VC-2, VC-4
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 前置依赖 | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|----|
| S5 | task_plan.md 三处呈报字段（not-solved 下一步建议/范围自检问用户/FMEA AskUser）补 Rule 70 四要素引用（T7） | code-assistant(haiku-1) | skills/task-planner/templates/task_plan.md | - | 3 处 grep "Rule 70" 命中 | 5min | 1f/10l/5min | 无 | pending |
| S6 | batch_report.md 头部注释+呈报区块补「面向用户呈报按 Rule 70 四要素」（T8） | code-assistant(haiku-1) | skills/task-planner/templates/batch_report.md | - | grep "Rule 70" ≥1 | 8min | 1f/15l/8min | 无 | pending |
| S7 | image-type.md:87 与 multiview-ref-type.md:25 送审清单补「逐件清单+看点+动作」列规格（T9） | code-assistant(haiku-1) | skills/task-planner/templates/variant/image-type.md + skills/task-planner/templates/variant/multiview-ref-type.md | - | 两文件 grep "Rule 70" 命中 | 8min | 2f/12l/8min | 无 | pending |

### Phase 5: 触点修补 C（引用面与管线）
- [x] batch-quality-gate.md + companion + review-library 呈报合约补齐
- **V-N:** VC-2, VC-4
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 前置依赖 | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|----|
| S8 | batch-quality-gate.md 熔断/跳过率呈报点+companion/plan-writer.md 质量风险呈报点补 Rule 70 指针（T10-T11） | code-assistant(haiku-1) | skills/task-planner/references/batch-quality-gate.md + skills/task-planner/companion/agents/plan-writer.md | - | 两文件 grep "Rule 70" ≥3 | 5min | 2f/8l/5min | 无 | pending |
| S9 | article-batch-publisher.md 与 article-field-fixer.md 熔断/跳过呈报点补 Rule 70 指针（T12） | code-assistant(haiku-1) | skills/task-planner/companion/agents/article-batch-publisher.md + skills/task-planner/companion/agents/article-field-fixer.md | - | 两文件 grep "Rule 70" ≥2 | 5min | 2f/8l/5min | 无 | pending |
| S10 | review-library general-review 与 alignment-review 输出合约补「审查对象总清单（编号+路径）」要素行（T13） | code-assistant(haiku-1) | skills/task-planner/review-library/general-review/SKILL.md + skills/task-planner/review-library/alignment-review/SKILL.md | - | 两文件输出合约段 grep "Rule 70" 命中 | 8min | 2f/8l/8min | 无 | pending |
| S11 | review-library code-quality-review 输出合约同款补行（T13 同措辞） | code-assistant(haiku-1) | skills/task-planner/review-library/code-quality-review/SKILL.md | - | grep "Rule 70" 命中 | 5min | 1f/4l/5min | 无 | pending |

### Phase 6: 机器守护
- [x] 新建 selftest-report-reviewability.sh（RR 断言：条文锚/接线锚/触点锚/registry/零新键）
- [x] check-complete.sh 增 report-lint（fail-open warn，不改 exit 语义）
- [x] registry.tsv 登记新脚本行
- **V-N:** VC-3, VC-4
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 前置依赖 | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|----|
| S12 | 新建 scripts/selftest-report-reviewability.sh 上半（RRV-01..07：Rule 70 条款锚+SKILL 接线锚+registry 自登记断言；范式=selftest-research-first.sh） | executor(sonnet-1) | skills/task-planner/scripts/selftest-research-first.sh + plans/task-v155-report-approvability/task_plan.md（§守护断言清单） | - | 脚本存在且 bash 语法检查通过 | 15min | 1f/90l/15min | 无 | pending |
| S13 | 追加上半（RRV-08..13：13 触点文件锚断言+check-complete lint 段锚）+chmod+x+自跑 | executor(sonnet-1) | skills/task-planner/scripts/selftest-report-reviewability.sh + plans/task-v155-report-approvability/task_plan.md | - | 自跑 exit 0 | 10min | 1f/70l/10min | 无 | pending |
| S14 | check-complete.sh rcov-gate 段后增 report-lint（fail-open printf warn：产出清单绝对路径/下一步建议看点动作/待裁决对象定位；不动任何 exit） | executor(sonnet-1) | skills/task-planner/scripts/check-complete.sh | - | bash -n 通过；grep "report-lint" ≥3；既有 selftest 无 FAIL | 12min | 1f/45l/12min | 无 | pending |
| S15 | registry.tsv 追加 selftest-report-reviewability.sh 登记行（4 列格式）+全仓计数钉核查（grep 脚本总数断言并按需上调） | executor(sonnet-1) | skills/task-planner/scripts/selftest-registry.tsv + skills/task-planner/SKILL.md | - | registry 新行在位；S16 回归无计数 FAIL | 5min | 2f/8l/5min | 无 | pending |

### Phase 7: 全量回归与锚级联清账
- [x] worktree 内全量 selftest 跑批（Round 1，结果四要素落 progress.md）
- [x] FAIL 清单级联修复→重跑至 ΣFAIL=0（条件执行）
- **V-N:** VC-4, VC-3
- **Status:** complete
- **Executor:** code-runner-agent（mini）+executor（sonnet-1，条件修复）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 前置依赖 | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|----|
| S16 | worktree 内全量 selftest 跑批（for f in selftest-*.sh）+FAIL 清单落盘 subagent-state 检查点 | code-runner-agent(mini) | skills/task-planner/scripts/selftest-*.sh（跑批，禁逐文件罗列） | - | 输出含每脚本 PASS/FAIL 与 ΣFAIL 计数 | 15min | 0f/0l/15min | 无 | pending |
| S17 | （条件：ΣFAIL>0）按 FAIL 清单修锚级联（单次派发 ≤2 文件，超限再拆多轮派发）→ 重跑至 ΣFAIL=0 | executor(sonnet-1) | 检查点 FAIL 清单（S16 产出路径执行期回填）+涉及断言脚本 | - | 重跑 ΣFAIL=0 | 15min | 2f/30l/15min | 无 | pending |

### Phase 8: 双审查（Code Review Gate）
- [x] 代码面审查（本次改动 .sh 文件）
- [x] 对齐面审查（全部条款/文档改动 vs 既有规范口径）
- [x] CHANGES 处置（条件）
- **V-N:** VC-7, VC-4
- **Status:** complete
- **Executor:** code-reviewer（sonnet-1）+general-purpose（alignment-review）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 前置依赖 | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|----|
| S18 | 代码面审查：worktree 内 git diff 的 .sh 改动（selftest 新脚本+check-complete lint），输出 APPROVED/CHANGES_REQUESTED+逐条 file:line | code-reviewer(sonnet-1) | worktree 内 skills/task-planner/scripts/*.sh（本次改动 3 文件，执行期给 git diff 基线） | - | checkpoint 落 verdict 行 | 15min | 0f/0l/15min | 无 | pending |
| S19 | 对齐面审查：按 review-library/alignment-review/SKILL.md 对全部 .md 改动跑对齐审查，输出 verdict+问题清单 | general-purpose(sonnet-1) | skills/task-planner/review-library/alignment-review/SKILL.md + worktree git diff（.md 集合） | - | checkpoint 落 verdict 行 | 15min | 0f/0l/15min | 无 | pending |
| S20 | （条件：CHANGES_REQUESTED）逐条修复（单次派发 ≤2 文件，超限多轮）→复验→两 verdict 翻 APPROVED | executor(sonnet-1) | 两 checkpoint 的 CHANGES 清单（执行期回填路径） | - | 复跑两审查 verdict=APPROVED | 15min | 2f/80l/15min | 无 | pending |

### Phase 9: 合并回+部署+终验簿记交付
- [x] smart-merge-back.sh --deploy（预期与 v152/153/154 尾段冲突→并集解，v149 判例）
- [x] 部署位逐位对账 IDENTICAL
- [x] rule-reserve land 70 + verification.md VC 复验 + 需求覆盖核对表
- [ ] delivery-summary（本任务交付总结本身按 Rule 48/70 金标准输出）
- **V-N:** VC-5, VC-6, VC-7
- **Status:** complete
- **Executor:** 主进程（例外理由:① git/worktree 编排+② 计划系统簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①未提交变更 5 项=并行任务 plans/ 目录非本任务范围；信号②额外 worktree×3=v152/153/154 在途；信号③遗留 wt 分支×3=同上在途非遗留；信号④⑤无。本任务 scope 与并行任务在 critical-rules.md/SKILL.md 尾段存在可预期合并冲突，按 v149 并集解判例处置） |
| `isolation` | `worktree`（修改运行中基础设施，§十一 P0） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability` |
| `branch` | `wt/v155-report-approvability` |
| `merge_back` | `pending` |

> 创建后先 diff 关键文件与 master 一致性（worktree-branch-desync 判例）；子代理派发 prompt 必带 worktree 绝对路径+「禁止触碰其他 worktree」约束（§11.4）。

## 📊 FMEA 预演（规划期）
| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2-6 | 新增行撞既有 selftest 定数断言（SKILL 行数/规则范围 1-66/合规清单计数——历史 5 次级联判例） | 7 | 6 | 3 | 126 | 兜底=Phase 7 全量回归必然暴露（D 层探测）+S17 修复档（22.3④ 主进程协调 executor 修，口径扩展非回退范式 v117 判例） |
| Phase 6 | check-complete.sh 改坏既有 exit 语义（交付门控承重墙） | 9 | 3 | 2 | 54 | 设计面已消解：只增 fail-open warn 不动 exit（S14 验收含 bash -n+既有 selftest 无 FAIL）；兜底=git restore 单文件回退 |
| Phase 9 | 与并行 v152/153/154 在 critical-rules.md/SKILL.md 尾段合并冲突 | 6 | 7 | 2 | 84 | v149 并集解判例：逐 hunk 并集保三方条文+重跑全量回归；禁 rebase 强推 |
| Phase 9 | worktree 基础文件与 master 不同步（desync 判例） | 7 | 3 | 2 | 42 | 创建后立即 diff 关键文件（critical-rules/SKILL/registry），不一致从 master 取正确版本 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填；本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链。

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-10 | 计划创建时 S1 建映射 |
| Phase 2 | ☑ | 2026-10-10 | 同上 |
| Phase 3 | ☑ | 2026-10-10 | 同上 |
| Phase 4 | ☑ | 2026-10-10 | 同上 |
| Phase 5 | ☑ | 2026-10-10 | 同上 |
| Phase 6 | ☑ | 2026-10-10 | 同上 |
| Phase 7 | ☑ | 2026-10-10 | 同上 |
| Phase 8 | ☑ | 2026-10-10 | 同上 |
| Phase 9 | ☑ | 2026-10-10 | 同上 |

## Key Questions
1. Rule 70 编号是否可用？→ 已核实账本：66 landed，67/68/69 并行预留，70 可用（2026-10-10）。
2. 触点修补采用全文复制还是指针引用？→ 指针引用（70.4 单一权威源，防口径漂移）。
3. 机器守护会不会破坏既有交付门控？→ 只增 fail-open warn，exit 语义零改动（VC-5 对照实测）。

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| D 类新任务边界判定：用户 2026-10-10 指令与任何在途计划无关联，开 task-v155 新计划 | Rule 8.1；全局指针指向的 v150 已 COMPLETE（陈旧指针，init 已切 side 指针），旧计划原样保留 |
| D 类判定②：用户 2026-10-10 第二条反馈（决策分级颠倒：重大变更不问/琐事上抛/基础质检推用户）→ 立项 task-v156（Rule 71 决策分级与用户打断纪律方向） | Rule 8.1——超出本计划 Goal/VC 范围；归因已落 findings.md §新投诉归因（v156 立项依据）；本计划先行收尾交付（Rule 70 修复呈报信息面） |
| D1 计划批准按 Rule 44.3 自动裁决 | 五要素：超时值=即时（自治会话无在线用户）/推荐项=按本计划执行/触发时间=2026-10-10/理由=harness 自治指令+用户显式授权修复（「必须要得以修正…全部需要补全」）/被覆盖选项=等待显式 yes；D6 硬停点不受影响 |
| 新增 Rule 70 而非扩写 Rule 48 | Rule 48 权威源绑定交付总结单点；呈报契约是全工作流纪律，独立编号便于触点统一引用（70.4） |
| 机器守护只增 warn 不改 check-complete exit | exit 语义是交付门控承重墙；对齐 rcov-gate fail-open 先例 |
| 范围含 review-library×3 与 companion×3 | 用户明示「其他类似的情况必须修正+全部需要补全」；同缺陷类呈报触点 |
| Rule 36.3 删除性行为清单（技能修改基线） | **无删除性行为**：本任务对技能文件零功能性删除/零语义改写；SKILL 索引行 1-66→1-69+70 为口径演进（并集解保各方条文），C46 让位 C48 为编号新增非删除；selftest 改造全部为断言锚精确化（条数不减：13/9/41/12） |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| （暂无） | 1 | | → progress.md Error Log |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- 本任务交付总结本身必须按 Rule 48 金标准输出（以身作则，用户验收本任务的第一入口就是交付总结）

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-10 Phase 2 | ALIGNED（22.3① 改派 general-purpose 执行，drift-checker 档位 provider 拒绝） | VC-1, VC-3 | scope 恰好 2 文件（SKILL+critical-rules），无越界；checkpoint=subagent-state/drift-phase2.md |
| 2026-10-10 Phase 3 | ALIGNED | VC-2 | 3 文件 +9/-0 全在 scope；指针行四要素词齐；checkpoint=drift-phase3.md |
| 2026-10-10 Phase 4 | ALIGNED | VC-2 | 4 模板文件恰在 scope（+6/-3 行内追加）；六处 Rule 70 锚；checkpoint=drift-phase4.md |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6）
| 字段 | 值 |
|------|-----|
| `total` | n/a（非批量任务） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a（不符合 18.1 批量识别条件：触点修补为逐文件独立内容，非同质批量单元） |
| `sampled_pass` | n/a |
| `sampled_fail` | n/a |
| `pre_check` | n/a（Rule 18 前置 3 问不适用：无同质批量单元） |
| `rollback_point` | n/a（本任务回滚方式=`cd /mnt/data/dev/task-planner-skill && git revert 2a12229`，见 verification.md 风险点） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 8 / 9 |
| 主进程直做 Phase 清单 | Phase 9（例外理由：① git/worktree 编排（合并回/清理/deploy）+② 计划系统簿记——Rule 25.3 白名单①②） |
| 委派率 | 0.89（≥config.json#delegation_rate_floor 0.7 达标；全部直做理由均在白名单内，无违规） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-10 | explore | 全触点呈报缺口审计 | done | ~30 触点缺口+零机器守护+金标准单点确认 | findings.md#触点审计 | Research Findings/触点审计 | （探索类无检查点，结论已回填 findings） | - / 0 / ☑ |
| 2 | 2026-10-10 | executor | S1 Rule 70 条文 | done | 条文 26 行逐字落位，70.1-70.6 全在 | critical-rules.md:888 起 | #### [sub:1-executor] | plans/task-v155-report-approvability/subagent-state/1-executor.md | - / 0 / ☑ |
| 3 | 2026-10-10 | executor | S2 SKILL 接线 | done | 五处接线（:9/:165/:220/:341/:365），+5/-2 | SKILL.md:341 | #### [sub:2-executor] | plans/task-v155-report-approvability/subagent-state/2-executor.md | - / 0 / ☑ |
| 4 | 2026-10-10 | code-assistant | S3 SKILL 触点指针 | done | 四触点 Rule 70 指针行（:73/:107/:153/:251），+4/-0 | SKILL.md:73 | #### [sub:3-code-assistant] | plans/task-v155-report-approvability/subagent-state/3-code-assistant.md | - / 0 / ☑ |
| 5 | 2026-10-10 | code-assistant | S4 reference+worktree 触点 | done | reference:234+worktree-isolation 4 处（:12/:27/:81/:87） | reference.md:234 | #### [sub:4-code-assistant] | plans/task-v155-report-approvability/subagent-state/4-code-assistant.md | - / 0 / ☑ |
| 6 | 2026-10-10 | code-assistant | S5-S7 模板触点 | done | task_plan×3/batch_report/variant×2 六处（S5-S7 三个单元） | task_plan.md:100/:135/:337 | #### [sub:5..7-code-assistant] | plans/task-v155-report-approvability/subagent-state/{5,6,7}-code-assistant.md | - / 0 / ☑ |
| 7 | 2026-10-10 | code-assistant | S8-S11 管线触点 | done | batch-gate+3/companion×3+review-library×3 十处 | batch-quality-gate.md:30 | #### [sub:8..11-code-assistant] | plans/task-v155-report-approvability/subagent-state/{8,9,10,11}-code-assistant.md | - / 0 / ☑ |
| 8 | 2026-10-10 | executor | S12-S15 机器守护 | done | RRV selftest 215 行+report-lint+registry 登记+计数钉核查 | check-complete.sh:948 | #### [sub:12..15-executor] | plans/task-v155-report-approvability/subagent-state/{12,13,14,15}-executor.md | - / 0 / ☑ |
| 9 | 2026-10-10 | code-runner-agent | S16 全量回归 | done | Round1 62/65→S17a/b 修 4 级联→Round2/4/6 65→67 全绿 | progress.md#Phase7 | #### [sub:16/16b-code-runner] | plans/task-v155-report-approvability/subagent-state/{16,16b,17a,17b}-*.md | - / 0 / ☑ |
| 10 | 2026-10-10 | code-reviewer | S18 代码面审查 | done | CHANGES_REQUESTED 2 项→S20 修复（空输入守卫+RRV-07 双锚） | check-complete.sh:988 | #### [sub:18-code-reviewer] | plans/task-v155-report-approvability/subagent-state/{18,20}-*.md | - / 0 / ☑ |
| 11 | 2026-10-10 | general-purpose | S19 对齐面审查（22.3① 改派载体同型） | done | CHANGES_REQUESTED 2 项→S20b/c/d 修复闭环 | SKILL.md:287 | #### [sub:19-align-reviewer] | plans/task-v155-report-approvability/subagent-state/19-align-reviewer.md | 22.3①改派 / 0 / ☑ |
| 12 | 2026-10-10 | general-purpose | 每 Phase 偏移检查（drift-checker haiku 拒→22.3① 改派） | done | P2-P9 全程 ALIGNED，8 检查点 | subagent-state/drift-phase*.md | Research Findings/新投诉归因 | plans/task-v155-report-approvability/subagent-state/drift-phase2..8.md | 22.3①改派 / 0 / ☑ |
| 13 | 2026-10-10 | executor | 合并冲突并集解（U1-U4） | done | 6 冲突文件并集解+RRV-04 内容锚化；Round6 67/67 全绿 | git log 619c848 | #### [sub:u1..u4-executor] | plans/task-v155-report-approvability/subagent-state/u{1,2,3,4}-*.md | - / 0 / ☑ |

## 🔗 Chain 区块交接配置
不适用（chain_mode: single，单 skill 任务，区块删除合规）。

## 📜 Rule 70 条文草案（S1 材料包 — 逐字采用，插入位置=critical-rules.md Rule 66 段之后）

```markdown
## Rule 70（用户呈报可审批性纪律 — task-v155）

> **呈报** = 工作流中一切请求用户审批/审查/确认/复核或向用户知情通报的输出点。本条全工作流适用；交付总结（最重呈报形态）契约仍以 Rule 48 + templates/delivery-summary.md 为权威源，本条不重复定义。

### 70.1 适用范围（呈报触点族）
以下场景一律属呈报触点，受 70.2 最小信息集约束：D1 计划批准展示 / D2-D6 选项呈报（28.3）/ B-C 类变更确认 / drift BLOCKED 与子代理失败升级呈报 / worktree 冲突与合并回 STOP / 批量熔断与跳过率呈报（Rule 18）/ 否定结论上报（35.4）/ 代码审查与对齐审查结果面向用户呈报 / 媒体送审清单 / 静默决策清单呈现 / 非选项类阻塞点展示（44.5）/ 周期回顾矛盾报告（65.4）/ 技能修改 diff 逐项确认（36.4）/ 交付总结（Rule 48）。

### 70.2 呈报最小信息集（四要素，缺一即违规）
1. **待审项清单**：编号 + 逐项一句话简介；禁止裸「请审批/请审查」——用户无从知道审什么（R1 缺陷本体）。
2. **可定位地址**：逐项给绝对路径 / 完整 URL / 可执行命令；禁止裸文件名、模糊指代（「相关文件」「见上文」）、未解析占位符（口径同 Rule 48.2）。
3. **看点**：逐项写明看什么/判什么（锚点、段落、判据）——读者未读上下文也能开审。
4. **动作**：逐项写明用户做什么（批准/驳回/修改/无需动作）+ 默认项排首位标「推荐」（联动 44.1；超时自动裁决按 44.3）。

### 70.3 强度分级
- **重呈报**（需用户拍板：D1/D2-D6/合并回确认/送审/熔断处置/危险操作确认）：四要素全量；危险操作（D6 级）另附影响面与回滚方式。
- **轻呈报**（知情类：drift 警告/阻塞点展示/静默清单/进度通报）：≥要素②③（地址+看点）；无动作须写「无需动作，观察判据 X」。

### 70.4 单一权威源
呈报契约唯一权威源=本条；各触点条款只引用不复制全文（禁自造弱化版规格）；交付总结口径以 Rule 48 为准，冲突时交付总结以 Rule 48 裁决。

### 70.5 与既有规则关系
41.5 打包呈报补四要素；44.1 默认项=要素④消费口径；48.2 可定位性=要素②同口径延伸到全部触点；36.4 展示 diff 满足要素①形态（逐项清单+路径）；28.3 选项呈现=重呈报形态。

### 70.6 机制
零新 config 键。机器面 = scripts/selftest-report-reviewability.sh（RRV 断言：条款锚+触点锚静态守护）+ check-complete.sh report-lint（fail-open warn，不改 exit 语义）。呈报违规按 Rule 26 降质处置：回炉补齐四要素后方可呈报。
```

## 🧩 接线材料包（S2 逐字采用）
- **Rules 全集行（SKILL.md 顶部 references 索引行）**：「Critical Rules 全集 1-66」→「Critical Rules 全集 1-66+70（67-69 并行任务预留）」，并在该行 Rule 66 条目后追加「、70 用户呈报可审批性纪律」；References 表 critical-rules 行「Critical Rules 1-66（含…）」同步加「+Rule 70 用户呈报可审批性纪律（task-v155）」。
- **终验交付段**：交付总结 bullet 后补一句「会话内一切其他呈报（审批/审查/确认/升级/熔断报告）按 Rule 70 四要素输出」。
- **Critical Rules 索引段**：Rule 66 行后新增一行：
  `- **Rule 70（用户呈报可审批性纪律 — task-v155）**：呈报触点四要素=待审项清单+可定位地址+看点+动作（70.2）；重/轻呈报分级（70.3）；单一权威源（70.4）；机器面=selftest-report-reviewability.sh+check-complete report-lint，零新 config 键（70.6）（详见 references/critical-rules.md Rule 70）`
- **合规清单新增行（C45 之后）**：
  `| C46 | 用户呈报可审批性（Rule 70）：一切审批/审查/确认/升级/熔断呈报已含四要素（①待审项清单+逐项简介②可定位地址③看点④动作+默认项；轻呈报≥②③）；交付总结按 Rule 48 权威源（机器面=selftest-report-reviewability.sh 静态断言+check-complete report-lint，呈报内容人工核查；mini 档豁免） | ☐ |`

## 🧩 触点指针材料包（S3-S11 逐字采用；措辞按宿主文件语体微调，禁弱化四要素）
- **T1 计划确认段（SKILL.md「展示 task_plan.md」行后）**：`呈报规格（Rule 70）：展示计划时必须附计划文件绝对路径+待审项清单（Phase 序列即清单，逐项一句话目标）+看点（VC 表与隔离决策）+动作（批准/驳回/修改）。`
- **T2 drift BLOCKED（SKILL.md STOP 行后）**：`呈报规格（Rule 70）：阻塞报告必须含①阻塞项清单+一句话简介②对象文件绝对路径③看点（哪条证据/哪个偏差）④动作选项+默认项（轻呈报≥②③）。`
- **T3 Code Review Gate（SKILL.md 失败处理行后）**：`呈报规格（Rule 70）：审查结果面向用户呈报时必须附①审查对象文件清单（绝对路径）③看点（verdict+关键发现行号）④动作（修复/放行+默认项）。`
- **T4 B-C 变更确认（SKILL.md「向用户复述计划变更」处）**：`呈报规格（Rule 70）：变更确认必须逐项列变更文件绝对路径+变更一句话简介+看点（新旧对比锚点）+动作（确认/回退+默认项）。`
- **T5 reference.md 3 次失败升级**：`升级呈报按 Rule 70 四要素：已尝试清单逐项附命令与错误输出绝对路径（检查点文件），看点=失败根因行，动作=继续/换道/停止+默认项。`
- **T6 worktree-isolation.md 四个 STOP/报告点**：各补一句 `呈报按 Rule 70：列变更/冲突文件绝对路径+看点（冲突 hunk/信号项）+动作+默认项。`
- **T7 templates/task_plan.md 三处**：not-solved 下一步建议字段补 `（按 Rule 70：对象路径+看点+动作）`；范围自检「先问用户」补 `（问询按 Rule 70 四要素）`；FMEA AskUser 处补 `（呈报按 Rule 70 四要素）`。
- **T8 templates/batch_report.md**：头部注释补一行 `面向用户呈报时按 Rule 70 四要素：失败/跳过单元逐项清单（编号+简介）+产物绝对路径+看点（失败原因列）+动作（重试/放弃+默认项）。`
- **T9 送审清单（image-type.md/multiview-ref-type.md）**：审查地址清单规格补 `逐件附编号+一句话简介（①）与看点（看什么：主体一致性/构图缺陷）（③）与动作（选定/重抽+默认项）（④）；仅有地址缺①③④=未送审。`
- **T10 batch-quality-gate.md**：18.1/18.3 STOP 呈报补 `报告按 Rule 70 四要素：受影响单元清单+产物路径+看点（failure 明细行）+动作（重审/回滚+默认项）。`
- **T11 companion/plan-writer.md**：质量风险高亮处补 `（呈报按 Rule 70：风险项清单+计划文件路径+看点+动作）`。
- **T12 companion article-batch-publisher.md/article-field-fixer.md**：熔断/跳过呈报处补 `（呈报按 Rule 70 四要素：单元清单+路径+看点+动作）`。
- **T13 review-library 三技能输出合约**：verdict 行后补一行 `- **审查对象总清单（Rule 70①）**：报告须附本次审查对象文件清单（绝对路径+逐项一句话），使收报告者无需追问即知审了什么。`

## 🛡️ 守护断言清单（S12/S13 材料包 — RRV 断言规格）
- RRV-01 critical-rules.md 含 `^## Rule 70` 与 `70.1`-`70.6` 六子条锚（各 ≥1）
- RRV-02 条文含四要素关键词：待审项清单/可定位地址/看点/动作 各 ≥1
- RRV-03 条文内禁硬编码行号锚（`:\d+` 引用形态=FAIL）
- RRV-04 SKILL.md 接线锚 ≥4（Rules 全集行/References 表/终验段/合规清单 C46）
- RRV-05 触点锚：findings 审计清单 13 文件逐一 grep "Rule 70" 命中（数组遍历断言）
- RRV-06 registry.tsv 含 selftest-report-reviewability.sh 行；config.json 零新键（grep 新键名=0）
- RRV-07 check-complete.sh 含 report-lint 段且不新增 exit 1 于新增行（新增行 grep -c "exit 1"=0）
- RRV-08..13 按触点分组锚（模板面/管线面/审查工具面各自断言）

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 技能条文增强类任务（无既有 variant 完全匹配）→ 落 general 兜底
- Rule 34.3②: 沉淀预登记 —— 终验时评估：本任务为规则/守卫类增强，与历史 Rule 落地任务同型（v138-v151 系列均未沉淀 variant，条款型增强不可模板化），预期登记不沉淀理由
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: **不沉淀（已登记 2026-10-10）**——理由=条款型技能增强（Rule 条文+指针补丁+静态守护），无「同类任务重复生产」的模板化面；判例=v138-v151 系列 Rule 落地任务均未沉淀 variant；若未来出现同型任务 ≥3 次再触发 34.3① 沉淀
