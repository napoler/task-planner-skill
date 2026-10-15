# Task Plan: [Brief Description]
<!-- 
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->

- **R1**: 「还是当前拆分子代理存在严重的缺陷 没有将子代理任务拆分细致 导致单个子代理解决巨量任务」
- **R2**: 「尤其单个子代理不具备skill」
- **R3**: 「另外 子代理过大也会导致上下文反复叠加」
- **R4**: 「还有 子代理执行复杂任务 导致模型能力不够时候导致无法正确运行」
- **R5**: 「还有当前我发现基本没有调研 /comet 技能来进行任务执行的强化执行 我从来没有见过激活 属于混乱无比  比如 supowerpowers 的相关技能也从未激活过  比如 头脑风暴 类似」
- **R6**: 「总之就是存在严重的缺陷   子代理拆分细致拆分 以及 任务分段执行」

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 | critical-rules.md Rule 59.1 条款存在（grep 锚 `### 59` + `粒度` 命中）+ check-dispatch.sh 粒度三值超限从 SKIPPED 升 enforce（脚本断言命中 `enforce` 级提示串） |
| R2 | VC-2 | Rule 59.2 技能伴飞条款存在 + subagent_dispatch.md 出现伴飞技能子节（grep `伴飞` 命中）+ check-dispatch.sh 伴飞路径存在性校验（`-f` 判存在） |
| R3 | VC-1, VC-6 | 59.1 三值硬门（任务量超限回炉重拆=控上下文源头）+ 59.5 分段执行锚条款存在（grep 锚命中） |
| R4 | VC-3 | Rule 59.4 能力预防判据条款存在（计划期复杂度预估超档→先拆细再派,禁派出去等失败）+ task_plan.md 模板 S-unit 表含粒度三值列（模板 grep 命中） |
| R5 | VC-4 | Rule 59.3 执行前技能扫描条款存在 + knowledge-brief.md 模板出现可用强化技能区块（grep 命中）+ 用户触发型技能（comet 族）仅提示不自动激活的判别条款存在 |
| R6 | VC-5, VC-6, VC-7, VC-8 | analyze-splits.sh 在位且可跑（exit 0/1 判据）+ selftest 新守护 N 断言全 PASS + 全量 selftest 回归 FAIL=0 + 部署位 diff IDENTICAL |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 计划期拆分 | Rule 21.1b 粒度三值（文件/行/时长）无机器硬校验——check-dispatch 仅 SKIPPED 提示不阻断，超限 S-unit 合法流入派发（critical-rules.md:144 自认「提示不阻断,拆分判断归模型」） | 59.1 三值强制填报+enforce 硬门；task_plan 模板 S-unit 表加粒度列；analyze-splits.sh 拆分体检 | VC-1, VC-5 |
| 计划期技能选型 | 无「执行前技能调研」条款——200+ 技能库（comet/superpowers/brainstorming 等）从不被扫描匹配，派发不携带技能 | 59.3 任务画像期技能扫描→knowledge-brief 技能清单区块；用户触发型仅提示 | VC-4 |
| 派发组装 | Rule 22.4 九字段无技能字段——子代理收不到技能强化（且工具面事实：仅 3 agent 有 Skill 工具，Read 全量具备） | 59.2 伴飞技能：S-unit 表伴飞列+任务书 §2 注入技能路径（子代理首动作 Read）+重型技能主进程提炼要点内联 | VC-2 |
| 计划期能力评估 | Rule 22.3 拆细先于升档仅是失败后兜底；43.2 档位标注无「能力不足→预防性拆细」判据 | 59.4 计划期复杂度预估超档先拆细条款 | VC-3 |
| 执行期分段 | Rule 46.1 禁批次追加在，但分段执行与粒度门未成链——大任务书仍可经任务书豁免 fail-open 溜入 | 59.5 分段执行锚（多段=多 S-unit 多派发+检查点链）；豁免收窄说明 | VC-6 |
| 机制守护 | v135 智能拆分分析（analyze-splits.sh）产出丢失未合 master；新增条款无静态守护 | 59.6 selftest-subagent-granularity-skill-escort.sh + registry 登记 | VC-7 |
| 回归防线 | 新条款/新列可能破坏既有 53+ 脚本断言（SKILL 行数定数/规则索引锚级联） | 全量 selftest 回归 + 级联清单核对 | VC-8 |
| 部署一致性 | 仓改动未同步部署位 | 部署位 diff IDENTICAL | VC-9 |

<!-- plan_tier: standard -->
## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and delete functionality."
-->
新增 Rule 59「子代理拆分粒度硬门与技能伴飞纪律」（7 子条：59.1 粒度三值硬门 / 59.2 技能伴飞 / 59.3 执行前技能扫描 / 59.4 能力预防判据 / 59.5 分段执行锚 / 59.6 机制守护 / 59.7 零新 config 键），配套 task_plan 模板 S-unit 表粒度三值+伴飞技能双列、knowledge-brief 模板技能清单区块、subagent_dispatch 模板伴飞注入子节、check-dispatch.sh 粒度 SKIPPED→enforce 升级+伴飞路径校验、analyze-splits.sh 重建（吸收 v135 丢失目标）、selftest 静态守护——根治「单子代理巨量任务/子代理无技能强化/上下文叠加/能力不匹配/技能库闲置」五缺陷。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `v144-20261008` | 启动时生成,注册表追踪 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v144` | §十一 隔离决策已有字段 |
| `scope_files` | `skills/task-planner/references/critical-rules.md`, `skills/task-planner/SKILL.md`, `skills/task-planner/templates/task_plan.md`, `skills/task-planner/templates/knowledge-brief.md`, `skills/task-planner/templates/subagent_dispatch.md`, `skills/task-planner/scripts/check-dispatch.sh`, `skills/task-planner/scripts/analyze-splits.sh`(新建), `skills/task-planner/scripts/selftest-subagent-granularity-skill-escort.sh`(新建), `skills/task-planner/scripts/selftest-registry.tsv`, `plans/task-v144/**`, `plans/.rule-reservations.jsonl`, `plans/INDEX.md` | 从「执行范围限制」解析,并发检测基础 |
| `interaction_mode` | `silent`（用户已给完整缺陷清单与总诉求，执行链无歧义分叉） | Rule 28 交互模式：ask=关键决策点给选项；silent=静默+静默决策清单登记 |
| `对齐审查` | `[登记]` critical-rules/SKILL/模板/脚本四端对齐（59 条款↔模板列↔脚本校验↔selftest 断言闭环） | Rule 42.6 消费：任务产出或更新的文档在完成前跑 alignment-review 对齐审查（标准收尾流程）;文档更新前跑版本一致性校验（未经校验不追加）;变更记录随交付物落盘;mini 档豁免（42.6.4） |
| `自动超时默认项` | `[无 2+ 选项询问点——修复方案由调研结论唯一确定（工具面事实：仅 3 agent 有 Skill 工具→Read 伴飞路径为唯一可行泛化路径），登记理由：低区分度直接裁决]` | Rule 44 消费：本任务所有 2+ 选项询问点逐个登记默认选项（推荐项）与自动超时时长（默认 5 分钟,可覆盖）;低区分度选项（产出一致仅步骤/耗时差异）不询问、直接裁决并登记理由（44.2）;用户超时未答复按默认选项自动执行+登记自动裁决记录五要素（44.3）;mini 档豁免（44.4） |
| `new_rule` | `59` | Rule 20.6：本任务新增 Rule 编号时填写（attest 自动预留+查重；无则留空）——已 rule-reserve.sh reserve 59 task-v144（2026-10-08） |
| `质量审查工具` | `[code-quality-review 技能 + Code Reviewer agent（CR 检查点）; 回归=全量 selftest（code-runner-agent 执行）]` | Rule 42 消费登记（42.4）：任务涉及质量审查面时按 42.2 四级检测（含内置 review-library 兜底池）,填 技能名/既有 agent 名/待补充 S-unit 指针;缺口按 42.3 补建并登记 S-unit;执行期必须用登记工具;mini 档豁免（42.5） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

<!--
  WHAT: 任务执行完毕 ≠ 目标完成。此表确保每一步有可验证证据。
  RULE: 每个 phase 完成后对照 VC 编号复验；phase 全部 complete ≠ 通过终验。
  FORMAT: VC-N 是客观判定标准（可测试/可追溯/不依赖主观判断）。
  V-N: goal-gate.md 规定「≥5 条 VC + 每 phase ≥2 条 V-N（映射到 VC 编号）」；
       在每个 Phase 段（`### Phase N` 的 - **Status:** 行前）补 `- **V-N:**` 占位行，
       填写本 Phase 验收映射的 VC 编号（≥2 条，如 `VC-1, VC-2`；对应逐条验收记录在
       templates/verification.md 的 `V-N.N` 项，映射目标须为已定义 VC 编号）。
       check-complete.sh 终验 VC-GATE 段机械校验（config.json vc_gate_enforce，默认 warn）。
-->

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 59.1 粒度三值硬门落地：critical-rules.md 含 `### 59` 条款且 59.1 覆盖三值 enforce；check-dispatch.sh 粒度超限走 enforce 档（不再是 SKIPPED） | grep 锚点 + 脚本断言 | `grep -c "### 59" skills/task-planner/references/critical-rules.md` ≥1；selftest-subagent-granularity-skill-escort.sh 断言项 |
| VC-2 | 技能伴飞落地：subagent_dispatch.md 出现伴飞技能子节（含 SKILL.md 路径注入+首动作 Read 指令）；check-dispatch.sh 校验伴飞路径存在性 | grep + 脚本断言 | `grep -c "伴飞" skills/task-planner/templates/subagent_dispatch.md` ≥2 |
| VC-3 | 能力预防判据落地：59.4 条款存在（计划期复杂度预估超档→先拆细再派）；task_plan 模板 S-unit 表含粒度三值列（`Nf/Nl/Nmin` 形态） | grep 模板+条款 | `grep -E "Nf.*Nl|粒度" skills/task-planner/templates/task_plan.md` 命中 |
| VC-4 | 执行前技能扫描落地：59.3 条款存在；knowledge-brief 模板含可用强化技能区块；comet 族用户触发型仅提示判别条款存在 | grep 模板+条款 | `grep -c "可用强化技能" skills/task-planner/templates/knowledge-brief.md` ≥1 |
| VC-5 | analyze-splits.sh 在位可跑：对含超限行的样例 plan 输出拆分建议（exit 1），干净样例 exit 0 | 跑脚本构造样例 | `bash skills/task-planner/scripts/analyze-splits.sh <fixture>` rc 判据 |
| VC-6 | 59.5 分段执行锚条款存在（多段=多 S-unit 多派发+检查点链，与 46.1 联动表述） | grep 锚点 | `grep "分段" skills/task-planner/references/critical-rules.md` Rule 59 区命中 |
| VC-7 | selftest 新守护全 PASS 且登记 registry | 跑 selftest | `bash scripts/selftest-subagent-granularity-skill-escort.sh` 全 PASS；selftest-registry.tsv 新增行 |
| VC-8 | 全量 selftest 回归 FAIL=0 | 跑全量 | `cd skills/task-planner/scripts && for s in selftest-*.sh; do bash $s; done` 汇总 |
| VC-9 | 部署位同步 IDENTICAL | diff | master vs ~/.zcode/skills/task-planner 等部署位 diff=0 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码(规则) | `skills/task-planner/references/critical-rules.md`(文件尾纯增量 Rule 59 块) | 既有 Rule 1-58 原文任何改动 |
| 源码(主技能) | `skills/task-planner/SKILL.md`(Rules 索引行 1-57→1-59 级联补 58+59；References 表行内改写；派发/计划段指针——均行内追加/改写，禁净删) | SKILL.md 其他段落重写 |
| 模板 | `skills/task-planner/templates/task_plan.md`(S-unit 表加粒度+伴飞列、机器契约注释更新), `templates/knowledge-brief.md`(技能清单区块), `templates/subagent_dispatch.md`(§2 伴飞子节) | 其他模板文件 |
| 脚本 | `skills/task-planner/scripts/check-dispatch.sh`(粒度 enforce+伴飞校验), `scripts/analyze-splits.sh`(新建), `scripts/selftest-subagent-granularity-skill-escort.sh`(新建) | 其他既有脚本（含 selftest-registry.tsv 仅追加 1 行） |
| 计划簿记 | `plans/task-v144/**`, `plans/.rule-reservations.jsonl`(land 一行), `plans/INDEX.md` | 其他 plans/task-* 目录（v133/v135/v138/v143 并行任务禁触） |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | Rule 21.1b/22.4/46.1/47.2 现行条文（拆分/派发/专注度/具名路由基线） | `skills/task-planner/references/critical-rules.md` :144/:168/:494/:506 | 必读 | ☑ |
| 项目内部文档/知识库 | v142 Rule 58 块格式样例（纯增量+锚注释+判例惯例） | `critical-rules.md` 文件尾 Rule 58 块（commit a7c01a8） | 必读 | ☑ |
| 项目内部文档/知识库 | check-dispatch.sh fine_grain_checks 四项现状 | `scripts/check-dispatch.sh` :316-431 | 必读 | ☑ |
| 项目内部文档/知识库 | 工具面事实：仅 3 agent 含 Skill 工具（task-orchestrator/auto-agent/article-research-heavy-agent），Read 全量具备 | `~/.zcode/agents/` frontmatter 扫描结论（2026-10-08 本任务 Phase 1 双 Explore 调研，findings.md §B） | 必读 | ☑ |
| 项目内部文档/知识库 | comet 族=用户显式触发设计（disable-model-invocation） | `~/.zcode/skills/comet-any/SKILL.md` frontmatter | 参考 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: [解决这个问题后，结果能交付吗？]

**核心问题判断**:
- [ ] 核心问题解决后，产品/结果能交付吗？
- [ ] 核心问题不解决，其他工作都白费吗？
- [ ] 核心问题的解决方法是清晰的、可执行的？

**如果无法回答核心问题，禁止开始任务！**

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
Phase 1

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
[一句话下一步动作]

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | [如: Agent 子代理 executor(sonnet-1)] | [一句话理由] |

**workflow 编排判定（Rule 40.4）**: [未命中编排条件 → 按 Rule 21.4 独立性守门调度（并行默认+声明组，未声明=串行，10-02）;命中（独立并行子任务可 fan-out / 长链多 skill 接力可复用 / 用户点名）→ 登记"建议 CreateWorkflow"并按 Rule 39.4 做并行豁免登记（Decisions Made + progress）]
**/goal 对齐（Rule 40.3）**: [本计划 Goal+VC 即 session goal 的证据源;如用户已用 /goal 锚定本任务,在执行范围或 Goal 段注明映射;/goal 为用户侧 harness 命令,技能层不可代调]

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: Requirements & Discovery
<!-- 
  WHAT: Understand what needs to be done and gather initial information.
  WHY: Starting without understanding leads to wasted effort. This phase prevents that.
-->
- [x] Understand user intent（用户 6 条缺陷原话已抄录 R1-R6）
- [x] Identify constraints and requirements（R→VC 映射+根源覆盖表完成）
- [x] Document findings in findings.md（双 Explore 调研结论落盘）
- [x] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **V-N:** VC-1, VC-4（条款落点/模板落点锚均已一手核实存在可行）
- **Status:** complete
- **Executor:** explore（mini）×2 并行（拆分纪律现状调研 + 技能面/工具面事实调研——已执行回收）

<!-- Phase 1 S-unit 表(Rule 22.6 — 已执行完毕的历史事实记录,双并行组) -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|-----------|---------|------|
| S1 | 调研拆分纪律与技能路由现状(条款/脚本/缺口) | explore(mini) [readonly-parallel] | SKILL.md+critical-rules.md+check-dispatch.sh | 每问题含结论+锚+缺口 | 15min | 0f/0l/15min | 无(只读调研) | complete |
| S2 | 调研技能族用途与子代理工具面事实 | explore(mini) [readonly-parallel] | ~/.zcode/skills comet 族+~/.zcode/agents frontmatter | 技能表+工具面表+可行路径清单 | 10min | 0f/0l/10min | 无(只读调研) | complete |
<!-- 
  STATUS VALUES:
  - pending: Not started yet
  - in_progress: Currently working on this
  - complete: Finished this phase
-->

### Phase 2: Planning & Structure
<!-- 
  WHAT: Decide how you'll approach the problem and what structure you'll use.
  WHY: Good planning prevents rework. Document decisions so you remember why you chose them.
-->
- [x] Define technical approach（Rule 59 七子条架构+四端落点定稿，见下方 S-unit 表）
- [x] Create project structure if needed（无新目录）
- [x] Document decisions with rationale（关键决策：伴飞走 Read 路径而非改 agent 定义——工具面事实仅 3 agent 有 Skill 工具而 Read 全量具备；comet 族用户触发型不自动激活仅提示——comet SKILL 设计为用户显式触发）
- **V-N:** VC-1, VC-2, VC-3, VC-4
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单；计划文档填写）

### Phase 3: Implementation
<!-- 
  WHAT: Actually build/create/write the solution.
  WHY: This is where the work happens. Break into smaller sub-tasks if needed.
-->
- [ ] Execute the plan step by step（S1→[S2‖S4‖S5]→S3→S6→S7→S8）
- [ ] Write code to files before executing
- [ ] Test incrementally（每 S-unit 返回后主进程 Read 复核+翻状态）
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5, VC-6, VC-7
- **Status:** complete
- **Executor:** S-unit 逐个派发（见下表；条文撰写=sonnet-1 判断档，模板/脚本编辑=haiku-1~sonnet-1）
（技能系统文件维护组画像；执行体按 SKILL.md 路由表+43.2 档位：判断型=sonnet-1、轻量编辑=haiku-1）

<!-- S-unit 派发单元表(Rule 22.6) — 本表自身践行 59.1 粒度三值与 59.2 伴飞列(先行示范)
  布局契约:新列「粒度/伴飞技能」插在「预估时长」($7)之后——check-plan-dispatch.sh 按固定列位解析 $4执行体/$5输入/$7时长,新列前移会错位(attest 实测);S6 升级为按表头名定位后解除此约束
  粒度列格式 Nf/Nl/Nmin:文件数/新增行数/预估分钟,上限对齐 config subagent.step_max_*（2/100/15）
  伴飞技能列:技能名或「无」(纯机械单元);派发时任务书 §2 按 59.2 注入 SKILL.md 路径
  依赖链:S1(条文)→S3(表列)→S6(解析正则)契约串行;S2/S4/S5 文件独立可并行;S7 依赖 S3 表格式;S8 依赖全部 -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|-----------|---------|------|
| S1 | critical-rules.md 文件尾纯增量追加 Rule 59 块(七子条 59.1-59.7,含锚注释) | code-assistant(sonnet-1) | worktree critical-rules.md + 本计划 R1-R6/根源表摘要 + v142 Rule 58 块格式样例(Rule 58 块 20 行) | grep "### 59" 命中且七子条全在;diff 纯增量 | 13min | 1f/65l/13min | 无(条文撰写) | complete |
| S2 | SKILL.md 级联:Rules 索引行 1-57→1-59(补 58 缺失+加 59)+References 表 critical-rules 行内改写+派发段 Rule 59 指针 | code-assistant(haiku-1) | worktree SKILL.md + S1 产出锚(59 条款名) | grep "59" SKILL.md 索引行命中;行数与锚断言过 selftest | 6min | 1f/8l/6min | 无(机械级联) | complete |
| S3 | task_plan.md 模板:S-unit 表加「粒度(三值)」+「伴飞技能」双列+机器契约注释 SKIPPED→enforce 措辞更新 | code-assistant(sonnet-1) | worktree templates/task_plan.md + 59.1 条文(S1 产出) | 模板表头含两新列;契约注释含 enforce | 8min | 1f/18l/8min | 无(模板编辑) | complete |
| S4 | knowledge-brief.md 模板:新增「可用强化技能清单」区块(技能/路径/匹配点/激活方式,含用户触发型标注) | code-assistant(haiku-1) | worktree templates/knowledge-brief.md + 59.3 条文摘要(5 行) | grep "可用强化技能" 命中 | 8min | 1f/20l/8min | 无(模板编辑) | complete |
| S5 | subagent_dispatch.md:§2 后新增伴飞技能子节(SKILL.md 绝对路径注入+子代理首动作 Read 指令+重型技能主进程提炼内联规则) | code-assistant(sonnet-1) | worktree templates/subagent_dispatch.md + 59.2 条文摘要(6 行) | grep "伴飞" ≥2 处;九字段锚"九字段"字面不动 | 8min | 1f/16l/8min | 无(模板编辑) | complete |
| S6 | check-dispatch.sh:fine_grain_checks 粒度三值 SKIPPED→enforce 升级+S-unit 表三值列解析+伴飞技能路径存在性校验(-f) | code-assistant(sonnet-1) | worktree check-dispatch.sh + S3 表列格式(Nf/Nl/Nmin 正则) | 构造超限 fixture→exit 2;伴飞缺路径→命中;既有 4 项校验不回退 | 15min | 1f/45l/15min | 无(脚本逻辑) | complete |
| S7 | analyze-splits.sh 新建:读 S-unit 表输出超限行拆分建议(exit 1 有超限/0 干净)——吸收 v135 丢失目标 | code-assistant(sonnet-1) | S3 表列格式 + check-dispatch 粒度解析函数样例 | 双 fixture 跑通 rc 判据 | 15min | 1f/85l/15min | 无(新建脚本) | complete |
| S8 | selftest-subagent-granularity-skill-escort.sh 新建(断言:59 锚/模板双列/伴飞子节/脚本 enforce/rc 判据)+registry.tsv 追加登记 | code-assistant(sonnet-1) | S1-S7 全部产出锚 + 既有 selftest 样例结构 | 新 selftest 全 PASS;registry 新行 | 15min | 2f/95l/15min | 无(守护脚本) | complete |
| S10 | 合并级联①:kb 五段 5→6(selftest-knowledge-brief T1b + selftest-execution-stability T10a,断言+docblock+诊断串三同步) | code-assistant(haiku-1) | worktree 两 selftest + §6 产出锚 | 双脚本 FAIL=0 | 6min | 2f/8l/6min | 无(锚级联) | pending |
| S11 | 合并级联②:TS-05 锚演进+TS-12 键数42 + SR-07 锚/SR-09 键数/SR-12 registry 行数 | code-assistant(haiku-1) | worktree 两 selftest + SKILL 新锚 | 双脚本 FAIL=0 | 8min | 2f/12l/8min | 无(锚级联) | pending |
| S12 | 合并级联③:LA-12 锚+LA-14 键数 + RC-13 键数/RC-15 负断言 '56.'→'63.' | code-assistant(haiku-1) | worktree 两 selftest | 双脚本 FAIL=0 | 8min | 2f/10l/8min | 无(锚级联) | pending |
| S13 | 合并级联④:WF-10 锚+WF-12 键数 + EG-16 负断言 59.x→63.x | code-assistant(haiku-1) | worktree 两 selftest | 双脚本 FAIL=0 | 8min | 2f/10l/8min | 无(锚级联) | pending |
| S14 | 合并级联⑤:IP-14 负断言 59.x→63.x+IP-15 键数42 + registry 补登 periodic-review 行 | code-assistant(haiku-1) | worktree selftest + registry.tsv | 脚本 FAIL=0;T02 过 | 8min | 2f/10l/8min | 无(锚级联) | pending |
| S15 | master 存量清账:config=40→42 定数×7 文件(AC-07/RT-09/CP-16/MA-10/MD-08/RG-07/R-12)——同质单行批量,L0 轻量通道精神(Rule 38.7),文件数例外登记 | code-assistant(haiku-1) | worktree 七 selftest | 七脚本键数断言全过 | 10min | 7f/14l/10min | 无(机械清账;例外登记:同质单行定数批量,7f=L0 通道 Rule 38.7) | pending |

### Phase 4: Testing & Verification
<!-- 
  WHAT: Verify everything works and meets requirements.
  WHY: Catching issues early saves time. Document test results in progress.md.
-->
- [ ] Verify all requirements met（R1-R6 逐条对照 VC 复验——check-complete）
- [ ] Document test results in progress.md（每轮回归结果落盘，Rule 57）
- [ ] Fix any issues found
- **V-N:** VC-5, VC-7, VC-8
- **Status:** complete
- **Executor:** code-runner-agent（mini）

<!-- Phase 4 S-unit 表(Rule 22.6) -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 |
|----|------------|------------------------|-------------|---------|------|-----------|---------|------|
| S9 | 全量 selftest 回归+新守护跑批+逐脚本 rc 汇总落盘 | code-runner-agent(mini) | worktree scripts/selftest-*.sh 全集 | Total/FAIL 逐行原文回传 | 15min | 0f/0l/15min | 无(跑批) | pending |

### Phase 5: Delivery
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [ ] Review all output files（Code Review Gate——code_review: required，Code Reviewer agent）
- [ ] Ensure deliverables are complete（交付总结含指针可定位，Rule 48）
- [ ] Deliver to user（部署位同步 IDENTICAL + merge --no-ff + worktree 清理 + rule-reserve land + INDEX 归档）
- **V-N:** VC-8, VC-9
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe` / `risk`（信号①-⑤ 摘要） |
| `isolation` | `worktree`（实现类默认首选） / `direct`（纯文档/调研或用户否决） |
| `worktree_path` | `<repo-parent>/<repo>-worktrees/<task-id>` 或 n/a |
| `branch` | `wt/<task-id>` 或 n/a |
| `merge_back` | `pending` / `merged(<commit>)` / n/a |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

<!--
  WHAT: 对每个 Phase 枚举失败模式，打 S(严重度)/O(频度)/D(探测难度) 各 1-10 分，RPN=S×O×D。
  WHY: RPN>100 的高风险 Phase 必须预先登记兜底动作（对齐 Rule 22.3 五档兜底链，task-v113 后含 22.3.0 资料先行档），避免执行期临时决策。
  WHEN: 计划创建时填写（高 RPN 项）；纯文档/调研类小任务可写 n/a。
  开关键: config.json#fmea_enforce（默认 warn；enforce 档下 RPN>100 无兜底登记 = 计划无效）。
-->

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | （示例）依赖配置缺失 |  |  |  |  |  |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  |  |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. [Question to answer]
2. [Question to answer]

## Decisions Made
<!-- 
  WHAT: Technical and design decisions you've made, with the reasoning behind them.
  WHY: You'll forget why you made choices. This table helps you remember and justify decisions.
  WHEN: Update whenever you make a significant choice (technology, approach, structure).
  EXAMPLE:
    | Use JSON for storage | Simple, human-readable, built-in Python support |
-->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Errors Encountered
<!-- 
  WHAT: Every error you encounter, what attempt number it was, and how you resolved it.
  WHY: Logging errors prevents repeating the same mistakes. This is critical for learning.
  WHEN: Add immediately when an error occurs, even if you fix it quickly.
  EXAMPLE:
    | FileNotFoundError | 1 | Check if file exists, create empty list if not |
    | JSONDecodeError | 2 | Handle empty file case explicitly |
-->
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## Notes
<!-- 
  REMINDERS:
  - Update phase status as you progress: pending → in_progress → complete
  - Re-read this plan before major decisions (attention manipulation)
  - Log ALL errors - they help avoid repetition
  - Never repeat a failed action - mutate your approach instead
-->
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition

## 🚨 Drift Log（漂移检测记录）
<!-- 
  WHEN: 每次调用 Skill("task-drift-guard") 后追加一行记录
  FORMAT: | timestamp | 结果 | VC条目 | 结论 |
-->
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）
<!-- 
  WHEN: chain_mode: fan-out 或 批量操作 ≥5 单元时必填;纯单次任务可删除整个区块
  WHY: 批量操作禁止以牺牲质量/准确性为代价(Rule 18);前置 3 问 + 双采样抽检 + 失败率熔断的落盘证据
  校验: failure_rate >5% → Phase 禁止 complete;sampled_fail >0 → 整批未验证;pre_check 缺项 → plan-writer 校验失败
  完整模板: templates/batch_report.md | 规则详解: references/batch-quality-gate.md
-->
| 字段 | 值 |
|------|-----|
| `total` |  |
| `success` |  |
| `failed` |  |
| `failure_rate` | （>5% → STOP;>20% → 熔断回滚） |
| `sampled_pass` | （运行后抽 10%） |
| `sampled_fail` | （运行前抽 2,>0 → 整批熔断） |
| `pre_check` | （Q1:否/Q2:有/Q3:能） |
| `rollback_point` | （为空 → 禁止批量） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 子代理占比需要可见反馈闭环;委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
  WHEN: 每个 Phase complete 后更新;终验交付前必须完整。
-->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  /  |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
<!--
  WHEN: 每次 Agent() 派发前填一行;子代理返回 30s 内主进程必须 Read 实际产出 + 紧邻 Edit findings.md 回填结论(「findings 落点」列记段落锚点),两动作完成才在「备注」列勾 verify_done;failed/timeout 行必须回填 checkpoint 路径列(Rule 22.8.4)
  WHY: 子代理规模限制 + 交接文件保障(Rule 22);findings 回填绑定(Rule 19.1/22.5)防止结论只留会话记忆
  状态枚举: queued/pending/running/done/partial/timeout/failed/blocked/scaling-redispatch(22.3.1 provider 失败改派)
  列说明: 备注列 = 低频列折叠单列(rescue 换档挽救记录 档位/结果/时间,failed|timeout 行必填,Rule 22.7;retry_count = 22.3 retry_limit 计数,初值 0,每次重试 +1;verify_done☐ = Read 产出 + findings 复核/回填双条件,Rule 22.5)——字段内容不删,仅列位折叠;verify_done 无机器消费(grep 实证 scripts/*.sh 除 selftest 零命中),为人工义务,不声称机器门
  派发 prompt 八字段模板: templates/subagent_dispatch.md
  # [2026-09-27 task-v091 B-2] 单写者澄清+Handoff 低频列折叠（verify_done 无机器消费如实披露）
-->

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | | | | queued | | | | | - / 0 / ☐ |
| 2 | | | | | | | | | - / 0 / ☐ |
| 3 | | | | | | | | | - / 0 / ☐ |

## 🔗 Chain 区块交接配置（可选）

<!-- 仅多 skill 接力任务填写（如：调研→创作→发布）。单 skill 任务可删除此整个区块。 -->

### Chain 模式

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` / `linked`（串行接力）/ `fan-out`（一对多派发） |
| **current_block** | Block 1 |
| **handoff_on_complete** | ✅ 是 / ❌ 否 |

### Block 1: [本块名称]（当前块）

| 字段 | 值 |
|------|-----|
| **goal** | [本 block 独立目标] |
| **depends_on** | none |
| **passes_to** | Block 2: `[交接产物路径]` |
| **status** | in_progress / pending / complete |

### Block 2: [下游块名称]

| 字段 | 值 |
|------|-----|
| **goal** | [下游 block 目标] |
| **depends_on** | Block 1 → `[交接产物路径]` |
| **passes_to** | Block 3: `[...]` |
| **status** | pending |

<!-- 追加 Block N 时使用相同结构 -->

### 🔗 Handoff 追踪表

| Block | 状态 | 交接产物路径 | 验证命令 | 实际完成时间 |
|-------|------|------------|---------|-------------|
| Block 1 | - | - | - | - |
| Block 2 | - | - | - | - |

---
<!-- ★ Block 分隔符：每个独立交接区块下方用 --- 分隔，格式如下 -->
<!--
### Block 2: [名称]
## Goal
...
## Phases
...
（复制完整 task_plan 结构，仅包含本 block 的 Phase 和 VC）
-->

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP
