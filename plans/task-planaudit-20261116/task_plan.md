# Task Plan: 计划审计门与产出独立审计原则全流程贯彻（task-planner 技能优化）

<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）===== -->
template_type: rule-enhancement
plan_tier: standard
execution_lane: L1
parallel_groups: [p1-audit-baseline]
<!-- plan-writer 计划期产出（初始化首动作委派）；R1 审计 REJECTED 后按 F1-F18 增量修订，待 R2 复审 -->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「对当前的技能进行优化。核心就是一点，我希望以后做出的就是计划的时候，当前不是先提出一个计划日，然后交给用户审核授权之后再进行推进吗？就是这个计划任务，产出的计划任务需要放入单独的子代理中进行一次审计。核心目的就是在独立上下文的情况下，审核当前计划的合理性。这样的话却可以确保因为上下文中，比如分析错误等等的影响，这样的话就尽可能地发现其中的问题。那如果不合理，然后就是打回去重新修正，修正之后再次执行审核，类似这种迭代形式，直到合理，直到完全达标之后才交给用户分析。不要将就是大体意思就是不要将一个未经过审计的产品给用户。」<sub>（[目标]）</sub>
- **R2**: 「另外还有就是将我上面说到的这种原则，就是不要将一个未经审计的产出交给用户，将这一条贯彻到整个项目的全流程中。核心目标就是在任何的需要，嗯，需要审核，就是任何的产出前都进行独立审计，确保整个产出的完整以及可靠性。」<sub>（[目标]）</sub>
- **R3**: 「你需要将这些都融入到当前技能的创作中。」<sub>（[手段]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-6 | `skills/task-planner/SKILL.md` 中在“[A] 初始化（智能子动作：冲突分析+隔离决策复核+Spec 判定）完成之后、[A] 计划确认展示之前”存在 `计划独立审计门`（L1+ 适用，mini/L0/trivial 轻量复核或登记豁免，L0-E 豁免）与 `audit→REJECTED→修正→re-audit→APPROVED→方可展示/D1` 循环文本；判别性专有 token 基线负断言记录+落地后命中；达标判据与裁决转换/升级出口可观察；**端到端实跑证据**=本计划 R1(REJECTED)→修订→最终达标轮复审留痕与裁决（`progress.md [plan-audit-R1]` 首例已在位；最终达标轮=首个达成 0C/0I 且零阻断新发现的复审轮，如 R3），负向验证=REJECTED 计划在达标前被阻断进入 D1/展示 |
| R2 | VC-3, VC-6 | 核心规则/流程文本含“未经审计产出禁交用户”全流程原则总则，并映射**已识别覆盖面（非穷尽）**：计划面（VC-1 门）、执行产物面（Rule 103 双轮质检引用）、终验面（verification-gate/Rule 84 引用）、报告/总结面（交付前独立审计要求）、上抛裁决面（decision-arbiter/Rule 69 映射）；总则声明未列面按默认适用简版独立复核+判定规则；端到端落地以 VC-6 审计轮次证据（最终达标轮复审留痕与裁决）佐证 |
| R3 | VC-4, VC-5 | 变更以增量条款落入技能载体（SKILL.md + references/critical-rules.md 及必要联动）且 Rule 74 变更标注表完整；Rule 109 归属先定：核心 `critical-rules.md` 落计划制作域条款（计划审计门属计划生命周期=核心域）+全流程原则总则（含已识别覆盖面映射引用 Rule 103/84/108/69），跨域细则仅引用不改写卫星语义；编号/索引/锚点一致无冲突；计划与 knowledge-brief 完整可审计（必填字段齐、§1-§6 实条目） |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-planaudit-20261116/user-session-log.md`（模板 = skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 计划产出（Plan Writer→盘上复核） | 主上下文分析偏差被直接带入计划并展示给用户；无独立复核即进 D1；轻量档比例失衡风险 | 在盘上复核及智能子动作（冲突分析+隔离决策复核+Spec 判定）完成后、D1 展示前插入独立子代理审计门（L1+ 强制；mini/L0/trivial 轻量复核或登记豁免；L0-E 豁免），APPROVED 方可展示（VC-1） | VC-1 |
| 计划审计与修正循环 | 审计发现问题后无强制回炉与再审，或缺轮次留痕/达标判据不可观察导致“形式通过”或死循环 | REJECTED→修正→re-audit 迭代直到完全达标；达标=0 CRITICAL 且 0 IMPORTANT 且连续一轮零新发现（新发现=新增 CRITICAL/IMPORTANT；WARNING/QUESTION/NIT 留档不阻断）；裁决转换与升级出口明确；每轮固定留痕 `progress.md [plan-audit-R<N>]`（轮次/审计体/结论/问题清单/修复对照）；R1 已留痕首例（VC-2, VC-6） | VC-2, VC-6 |
| 执行产物审核 | 实质产出仅执行体自述无独立复检，遗漏与质量问题直达用户 | 映射既有 Rule 103 双轮质检为执行产物面独立审计覆盖（已识别面）；声明计划面逃逸 103.3 由审计门承载、执行期产物由 103 承载、二者不叠加（VC-3） | VC-3 |
| 终验与证据闭合 | 终态判定缺独立验证证据或与产物脱节 | 映射 verification-gate/Rule 84、Rule 108 为终验面已识别覆盖（VC-3） | VC-3 |
| 报告/总结交付 | 交付总结/分析报告未经独立审计即呈用户，存在遗漏与不实风险 | 总则要求需审核报告/总结交付前独立审计（完整性/可靠性）并留证据；未列面默认简版复核（VC-3） | VC-3 |
| 上抛与裁决呈报 | 分歧/裁决请求未经独立仲裁或证据整理即上抛用户 | 映射 decision-arbiter/Rule 69 及证据面要求为上抛裁决已识别覆盖（VC-3） | VC-3 |
| 规则落地与一致性 | 新原则未融入技能载体或与既有规则冲突/索引漂移；归属与判据自相矛盾 | 增量条款+SKILL 流程+索引联动；Rule 109 归属先定再冻结 VC-4；Rule 74 变更标注与编号校验；判别性 token+基线负断言（VC-4,VC-5,VC-6） | VC-4, VC-5, VC-6 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Goal 与 VC-1~VC-6；用户需求原文 R1-R3 逐字锚与 R→VC 映射；“L1+ 计划在 D1 展示/授权前必须经独立子代理审计且迭代达标后才可交用户”（mini/L0/trivial=轻量复核或登记豁免，L0-E 豁免，比例原则对齐 SKILL.md:51,57）；“未经审计产出禁交用户”全流程原则总则（已识别覆盖面非穷尽，未列面默认简版独立复核+判定规则）；Rule 109 归属=核心 critical-rules.md 计划制作域条款+全流程原则总则（跨域细则仅引用不改写卫星语义）；不改既有规则语义（Rule 74 增量默认）；R1 审计留痕 `[plan-audit-R1]` 为门控生效首例证据（已在位，禁改写；`[corrected]` 标注式透明更正除外——原值须保留在更正说明中，R3/WARNING-2 例外口径） | 本文件 Goal/VC/R/不变量区块、user-session-log.md #1、progress.md [plan-audit-R1] |
| 🔀 可变量 | S-unit 拆分与排期细节；留痕固定段内字段表述细化（保持轮次/审计体/结论/问题清单/修复对照五要素）；Rule 109 子条文案细化（不改变原则语义与归属）；机器面（selftest/attest 接线）范围；CA-5 是否落地 | Phase 执行期 Decisions Made |
| 📈 学得量 | 执行期发现的既有门控冲突点、精确锚点行号、审计协议落地经验 → findings.md / knowledge-brief.md；禁反向改写不变量 | findings.md, knowledge-brief.md |

## Goal
在 task-planner 技能中落地“L1+ 计划产出后、D1 前独立子代理审计迭代通过”门控，并以增量文本条款将“未经审计产出禁交用户”原则（已识别覆盖面非穷尽，未列面默认简版复核）映射贯彻到计划、执行产物、终验、报告/裁决等全流程审核面。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（涉及技能规则/流程文档与脚本潜在联动的实现类变更，终验前按轻/重 diff 触发 Code Review Gate） |
| `session_id` | `task-planaudit-20261116` |
| `worktree_path` | `tmp/worktrees/task-planaudit-20261116`（Rule 100：项目内 tmp/worktrees） |
| `scope_files` | `[skills/task-planner/SKILL.md, skills/task-planner/references/critical-rules.md, plans/task-planaudit-20261116/*]`（执行期按需最小扩展并登记） |
| `interaction_mode` | （缺省回落 config.json#interaction_mode；D1 仍按 44.3 口径，但**计划审计门不适用 44.3 自动通过**——审计未达标禁自动放行） |
| `对齐审查` | `[登记]` 完成前对更新的 SKILL/规则文档执行 alignment-review/一致性校验并随交付落盘（Rule 42.6；standard 档不豁免） |
| `自动超时默认项` | `[D1展示: 默认选项=按已展示计划执行 / 超时 5 分钟（Rule 44.3，仅审计 APPROVED 后适用）]`；审计门本身无自动通过；其余 2+ 选项询问点执行期逐点登记默认项与超时 |
| `new_rule` | `109`（候选，已 grep 全仓确认活跃代码未占用；执行期按 Rule 20.6 reserve/land） |
| `质量审查工具` | `critic（/home/terry/.zcode/agents/critic.md，plan/doc 审查触发词在位）+ decision-arbiter（Rule 69，分歧/争议仲裁）；code-review skill（CR Gate）；执行期补充实际检测结论` |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：VC 复验默认由独立子代理/全新上下文执行，主进程仅编排与簿记（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 计划审计门落地（判别性）：在“[A] 初始化（智能子动作：冲突分析+隔离决策复核+Spec 判定）完成之后、[A] 计划确认展示之前”，SKILL.md 明确要求 L1+ 计划交独立子代理（主审计体=critic）在独立上下文审计合理性；未经审计 APPROVED 不得进入 D1/不得展示给用户；mini/L0/trivial 轻量复核或登记豁免，L0-E 豁免；含再展示/修订重审触发与审计体降级链；专有 token `计划独立审计门` 落地且基线负断言已记录（改动前 `grep -c "计划独立审计门" skills/task-planner/SKILL.md`=0，见 findings 基线） | 判别性 `grep` 命中新 token + Read 对应段落确认插入点/分档/阻断/降级链语义 + 基线记录核对 | `skills/task-planner/SKILL.md`；`plans/task-planaudit-20261116/findings.md`（基线负断言） |
| VC-2 | 迭代闭环与留痕落地（判别性）：REJECTED→修正→re-audit 迭代直至达标；达标=0 CRITICAL 且 0 IMPORTANT 且连续一轮零新发现（新发现=新增 CRITICAL/IMPORTANT；WARNING/QUESTION/NIT 留档不阻断）；裁决转换“0 CRITICAL 且 0 IMPORTANT ⇒ APPROVED，否则 REJECTED”由审计体出具（REJECTED 附问题清单），主进程只登记不得自判达标；每轮固定留痕 `progress.md [plan-audit-R<N>]`（轮次/审计体/结论/问题清单/修复对照）；升级出口：争议→decision-arbiter，连续≥3 轮无实质进展→呈报用户裁决；R1 首例留痕已在位 | `grep` 命中 `plan-audit-R` 固定段与判据关键词 + Read SKILL.md 审计步骤 + progress.md R1 记录核验 | `skills/task-planner/SKILL.md`；`plans/task-planaudit-20261116/progress.md`（R1 首例） |
| VC-3 | 全流程“未经审计产出禁交用户”原则落地（判别性）：Rule 109/流程确立原则总则并映射**已识别覆盖面（非穷尽）**——计划面（VC-1）、执行产物面（Rule 103）、终验面（verification-gate/Rule 84, Rule 108）、报告/总结面（交付前独立审计）、上抛裁决面（decision-arbiter/Rule 69）；声明未列面按总则默认适用简版独立复核+判定规则；103 边界“计划面逃逸 103.3 由审计门承载、执行期产物由 103 承载、二者不叠加”在位；专有 token `audit-before-delivery` 落地且基线负断言已记录 | 判别性 `grep` 命中新 token 与已识别覆盖面/非穷尽/简版复核关键词 + Read 映射条款 | `skills/task-planner/references/critical-rules.md`；`skills/task-planner/SKILL.md`；`plans/task-planaudit-20261116/findings.md` |
| VC-4 | 增量合规与归属/编号/索引一致性：Rule 74 增量、变更标注表完整；Rule 109 归属已定稿（核心 critical-rules.md 计划制作域条款+全流程原则总则；跨域细则仅引用不改写卫星语义）并据此冻结判据；`^### 109` 定义唯一且 SKILL/critical-rules 索引计数与路由表述一致 | Read 变更标注表与归属声明 + `grep -rn "^### 109 " .../references` 计数=1 + 索引命中 | `plans/task-planaudit-20261116/task_plan.md`；`skills/task-planner/SKILL.md`；`skills/task-planner/references/critical-rules.md` |
| VC-5 | 计划与知识底座可审计：task_plan.md 必填字段完整（Goal/VC/Scope/Phases 含 Status+Executor+派发型 S-unit 表+并行组声明/隔离/原生 Todo 同步/Key Questions/Decisions/需求锚/根源覆盖/知识储备/调研需求/委派统计/Batch Report 等），knowledge-brief.md §1-§6 具真实条目且 §2/§3 各≥1 可追溯事实锚点；R1-R3 全覆盖无 uncovered | Read `task_plan.md` 与 `knowledge-brief.md` + 结构/锚点 `grep` | `plans/task-planaudit-20261116/task_plan.md`；`plans/task-planaudit-20261116/knowledge-brief.md`；`plans/task-planaudit-20261116/verification.md` |
| VC-6 | 端到端实跑证据（[目标]达成判据）：本计划自身审计轮次 `R1(REJECTED, 18 发现)→修订(F1-F18)→最终达标轮复审` 留痕与裁决作为审计门实跑证据；负向验证=R1 结论 REJECTED 且在达标前被阻断进入 D1/展示（计划未获 APPROVED/未进 D1 确认展示）；最终达标轮（首个达成 0 CRITICAL 且 0 IMPORTANT 且连续一轮零新发现的复审轮，如 R3；新发现=新增 CRITICAL/IMPORTANT，WARNING/QUESTION/NIT 留档不阻断）由审计体记录 APPROVED，方可进入 D1 展示 | `grep -n "\[plan-audit-R1\]" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/progress.md && grep -q "REJECTED" /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/progress.md && awk '/^## \[plan-audit-R[0-9]+\] /{buf=""} {buf=buf $0 "\n"} END{printf "%s",buf}' /mnt/data/dev/task-planner-skill/plans/task-planaudit-20261116/progress.md \| grep -q "结论: \*\*APPROVED\*\*"`（与 verification.md:30 同源同形，cwd 无关） + Handoff 审计行状态核对 | `plans/task-planaudit-20261116/progress.md`；`plans/task-planaudit-20261116/task_plan.md`（Handoff/Drift 或审计记录引用） |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。**计划审计门不适用 44.3 自动通过**：审计未达标禁自动放行进入 D1。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard 必填）

| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | Phase 3/4 所有修改技能受管文档的派发型实质产出 S-unit（默认适用）；Phase 1 调研 S-unit 产出 findings/覆盖矩阵属实质分析产出，按 103.2/103.3 适用；Phase 5 机械校验 S-unit 若仅产出命令证据可登记轻量复核 |
| 豁免登记 | 纯只读扫描且无独立产物文件的探测动作可豁免（登记具体 S-unit+理由）；Phase 2 主进程直做计划文档设计决策不适用子代理双轮质检（主进程例外，决策留痕于 Decisions/变更标注表） |
| 多文件变更集预判 | Phase 3 预判触发 103.6（SKILL.md + 可能 checklist/引用同步）；Phase 4 预判触发 103.6（critical-rules.md + SKILL.md 索引/计数联动）；翻转前附同步核对清单全绿 |
| 审计门与 103 边界 | 计划面逃逸 Rule 103.3 由本计划审计门承载；执行期产物由 Rule 103 承载；二者不叠加（F9） |

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标])终验必填）

| 字段 | 值 |
|------|-----|
| **目标型需求** | R1, R2 |
| **裁决** | `solved`（终验填写 2026-11-16） |
| **解决证据锚** | R1：worktree SKILL.md:68-77 审计门区块（L1+ 分档/critic 主审计/裁决映射 0C0I⇒APPROVED/迭代闭环/留痕 [plan-audit-R<N>]/阻断语义/44.3 不适用）+ G1:185 前置 + D1:81 排除括注；端到端实跑证据=本计划自身 R1 REJECTED→R2 REJECTED→R3 APPROVED 全留痕 progress.md:102-191（负向验证：REJECTED 计划在达标前被阻断进 D1，流程实证）+ P5-S1 采证 16/16 PASS。R2：critical-rules.md:194-212 Rule 109（109.1 总则三要素+109.4 已识别覆盖面映射五面+109.5 未列面判定规则）+ SKILL.md:75 103 边界不叠加声明；CR Gate APPROVED + DRIFT ALIGNED |
| **未解决面+原因** | 无（CA-5 不落地=有据预裁；CA-6 机器面未授权未实施=文本优先铁律，非未解决） |
| **已排除路径** | 不适用 |
| **下一步建议** | 不适用；后续可选：机器面接线（CA-6）另行授权任务 |

## 🎯 Goal 单元表（Rule 66.1 — attest 获批后逐步落证据，standard 必填）

| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 审计门落地 | L1+ 计划 D1 前必经独立审计迭代达标（分档+降级链） | `grep -n "计划独立审计门" skills/task-planner/SKILL.md` 命中且 Read 确认插入点/分档/循环/阻断语义 | P3-S1,S2 / Phase 3 | pending |
| G2 | 全流程原则 | 未审计产出禁交用户总则映射已识别覆盖面（非穷尽） | `grep -n "audit-before-delivery" skills/task-planner/references/critical-rules.md` + Read 确认总则/已识别面/未列面简版复核与 103/84/108/69 映射 | P4-S1,S2 / Phase 4 | pending |
| G3 | 一致性终验 | 归属/编号/索引/计划知识底座可审计且判别性命令通过 | `grep -rn "^### 109 " skills/task-planner/references` 计数=1 且 VC-4/VC-5/VC-1~3 判别性命令与证据齐 | P5-S1,S2 / Phase 5 | pending |
| G4 | 审计实跑证据 | 本计划经 R1→修订→最终达标轮审计闭环达标后方可 D1 展示 | `grep -n "\[plan-audit-R1\]" plans/task-planaudit-20261116/progress.md` 且最终达标轮（首个达成 0C/0I 且连续一轮零新发现的复审轮，如 R3）留痕段满足 0C/0I+连续一轮零新发现（新发现=新增 CRITICAL/IMPORTANT；WARNING/QUESTION/NIT 留档不阻断）并记录 APPROVED | 审计轮次 R1→最终达标轮 R<N> / 全程 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码/脚本 | （默认不改；仅用户 D1 明示授权机器面扩展时）`skills/task-planner/scripts/*` 中与本任务直接相关的最小集合 | 其他脚本、无关自测/重构 |
| 测试 | （仅授权时）`skills/task-planner/scripts/selftest-*` 新增或最小联动 | 未授权新增守护/selftest |
| 配置 | （默认不改）`skills/task-planner/config.json` | 改既有键或新增键（除非 D1 显式授权） |
| 文档/规则/模板 | `skills/task-planner/SKILL.md`、`skills/task-planner/references/critical-rules.md`；必要时最小联动 `skills/task-planner/templates/delivery-summary.md`、`skills/task-planner/references/todo-sync.md` 或 `templates/task_plan.md`（须在变更标注表登记理由） | 其他卫星技能规则正文、无关文档 |
| 计划产物 | `plans/task-planaudit-20261116/*`（task_plan/findings/progress/verification/knowledge-brief/notepad-learnings/user-session-log） | 其他计划目录 |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户（问询按 Rule 70 四要素）

## 📋 变更标注表（Rule 74.3 — 修订方案必填）

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 用户原话（逐字） | 依据（证据） | 执行动作 |
|------|------------------|---------------------------|-----------|----------------|--------|---------|
| CA-1 | `skills/task-planner/SKILL.md`: 计划制作循环插入点钉死于「[A] 初始化（智能子动作：冲突分析+隔离决策复核+Spec 判定）完成之后、[A] 计划确认展示之前」 | 新增 | 增量 | R1 全文（见 R1） | SKILL.md:50-75 现状无 D1 前独立审计步骤；critic 具“审查计划”触发（critic.md:5） | 插入 `计划独立审计门`（D1 前）步骤：L1+ 独立审计→REJECTED 修正再审→APPROVED 才展示/D1；分档/再展示简版审计/降级链；登记固定留痕字段 |
| CA-2 | `skills/task-planner/SKILL.md`: 计划确认/合规清单/终验或报告相关段落（最小必要处） | 修改 | 增量（补充前置条件与映射，不改既有语义） | R1,R2 全文 | 现有 G1/D1/Rule 103/84/48/44.3 已存在，需对齐审计门前置与“未经审计禁交用户”原则 | 补充“未经 L1+ 计划审计 APPROVED 不得展示/确认（审计门不适用 44.3 自动通过）”等一致性表述与全流程映射指针；103 边界声明 |
| CA-3 | `skills/task-planner/references/critical-rules.md`: 末尾追加 Rule 109（及必要索引同步） | 新增 | 增量 | R2 全文、R3 | 活跃代码无 `### 109`（grep 2026-11-16 核实）；归属定稿=核心计划制作域条款+全流程原则总则（跨域引用不改卫星） | 新增 Rule 109 `audit-before-delivery`：计划制作域审计门+全流程原则总则+已识别覆盖面（非穷尽）映射 Rule 103/84/108/69+未列面简版复核判定规则+留痕+文本优先/机器面待授权候选；同步核心计数/索引行 |
| CA-4 | `skills/task-planner/SKILL.md`: 规则索引/核心指针/全集说明 | 修改 | 增量（编号与摘要同步） | R3 | 新增 Rule 109 后索引需一致（SKILL.md:9,247 等） | 按定稿归属更新 Rules 全集/核心在位清单与 Rule 109 摘要行，计数表述一致 |
| CA-5 | （条件式）`skills/task-planner/templates/delivery-summary.md` 或相关引用文档 | 修改 | 增量 | R2 | 报告/总结面为泛化缺口候选（已识别面） | 仅在必要时增加“交付前独立审计/核对”提示行；不必要则不改并在 Decisions 说明 |
| CA-6 | （待授权候选）`skills/task-planner/scripts/selftest-*`、`scripts/attest-plan.sh`/门控脚本 | 新增/修改 | 增量（仅 D1 显式授权后执行） | — | 宪法文本优先铁律：脚本/守卫/机器门属范围扩张 | 默认不实施；若 D1 授权则拆分独立 S-unit 并补变更行/VC |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

> 目的：对齐任务知识库。Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | task-planner 计划制作循环与 D1 门控 | `skills/task-planner/SKILL.md:38-75,118-150` | 必读 | ☑（计划期已 Read） |
| 规范/标准 | 核心 Critical Rules（51/62/66/74/80/82/103引用面等） | `skills/task-planner/references/critical-rules.md:1-208` | 必读 | ☑ |
| 项目内部文档 | critic 审计体能力与触发词 | `/home/terry/.zcode/agents/critic.md:1-70` | 必读 | ☑ |
| 项目内部文档 | 规则增强模板与流程先例 | `skills/task-planner/templates/variant/rule-enhancement-type.md` | 参考 | ☑ |
| 项目内部文档 | 双轮质检/验证/裁决既有机制索引 | `SKILL.md:118,129,142,247`；卫星路由（verification-gate/dispatch/discipline） | 必读 | ☑ |
| 项目内部文档 | 变更吸收三判与增量纪律 | `skills/task-discipline/references/critical-rules-discipline.md` Rule 74（按需 Read） | 参考 | ☐（执行期按需） |

**填写规则**：① 定位可唯一定位；② 必读缺失 → STOP 并登记；③ 引用格式对齐 SKILL.md 调研引用规范。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 如何在不破坏既有计划/验证/质检机制语义的前提下，把“L1+ 计划 D1 前独立审计迭代（分档、可观察达标判据、留痕、降级与升级出口）”与“未经审计产出禁交用户”的全流程原则（已识别覆盖面非穷尽+未列面简版复核）以可执行、可留痕、可校验的增量条款融入 task-planner，使后续计划与需审核产出在交付用户前均有独立审计保障？

**核心问题判断**:
- [x] 核心问题解决后，结果能交付吗？——是：技能流程与规则文本明确阻断未审计 L1+ 计划/未审计需审核产出交付用户，并给出覆盖映射、达标判据、留痕与端到端证据要求。
- [x] 核心问题不解决，其他工作都白费吗？——是：仅局部补文档或不可观察口号无法形成稳定门控，主上下文偏差仍可直达用户。
- [x] 核心问题的解决方法是清晰的、可执行的？——是：插入钉死位置的 D1 前审计循环+增量 Rule 109（归属定稿）映射+判别性 VC+索引/联动一致性校验，按 Phase 推进并经 R2 审计/VC 复验。

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| P1-S1~S3 现状核实 | LOCAL-ONLY | `计划确认 D1`、`初始化首动作委派` | 本地 Read/Grep（SKILL/agents/references） | findings 覆盖面矩阵与锚点清单 | 否 |
| P2 方案定稿 | LOCAL-ONLY | `Rule 103 双轮质检`、`verification-gate Rule 84` | 本地 Read（核心与卫星索引/模板） | 条款草案与变更标注表（含归属/判据/留痕） | 否 |
| P3-S1~S2 门控落地 | LOCAL-ONLY | `critic 审查计划`、`APPROVED REJECTED` | 本地 Read/Grep（SKILL 目标段落） | SKILL.md 增量变更与留痕字段 | 否 |
| P4-S1~S2 原则与索引 | LOCAL-ONLY | `Rule 109`、`audit-before-delivery` | 本地 Grep/Read | critical-rules 增量条款与索引一致 | 否 |
| P5-S1~S2 校验交付 | LOCAL-ONLY | `check-complete`、`grep 证据` | 本地 Bash/Grep/Read | VC 证据与回归记录 | 否 |

> 三态判定：本任务为技能内流程/规则文本优化，所需事实均在仓库与本地 agent 定义中可完全定位；无外部事实依赖，故全为 LOCAL-ONLY。若执行期发现需外部标准佐证，按 Rule 75 追加 NET-* 条目并更新本表（变更登记）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）

| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | `skills/task-planner/SKILL.md` 当前计划制作循环、D1、Rule 103/84/108/48 引用 | Read/Grep + 段落摘录 | findings.md `## Research Findings`（P1 产出） | ☑（计划期基线） |
| ② 对标样本 | 既有独立审计/复检机制：`/home/terry/.zcode/agents/critic.md`、`decision-arbiter`（Rule 69）、Rule 103 双轮质检、verification-gate 终验链路、历史先例 `plans/archive/task-initdelegation-20261115/`；本计划 R1 审计留痕 | Read/Grep + 机制对照 | findings.md `## Research Findings` / progress.md `[plan-audit-R1]` | ☑（计划期基线+R1 首例） |
| ③ 外部约束 | 仓库内既有纪律：Rule 74（三判门/增量默认）、Rule 82（核心域边界）、宪法文本优先铁律（§二/§十）、Rule 20.6 编号预留、Rule 44.3 适用边界 | Read + 约束条目摘录 | findings.md `## Resources` / task_plan Decisions | ☑（计划期基线） |

## Current Phase
Phase 5 已 complete（P1-P5 全闭环）；当前=终验收口段：CR Gate APPROVED + DRIFT ALIGNED 已回填，进行中=合并回主仓→主仓复验→run-verification→Goal Gate→check-complete→归档+部署核验+交付总结

## Next Step
合并回主仓（smart-merge-back --deploy）→主仓 Read 复验→统一入口 run-verification 全 VC 复验→独立 Verifier 出 Goal Gate→check-complete→归档+部署核验+交付总结。（前置链已闭环：审计门 R3 APPROVED、P1-P5 complete、CR Gate APPROVED、DRIFT ALIGNED）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore(mini)；Read/Grep（本地检索） | 现状核实与覆盖面盘点属定位/分析，explore 低成本并可隔离上下文；主进程回收结论落盘 |
| Phase 2 | 主进程（编排/设计决策）；按需 Read | 方案裁决需整合 R1-R3、Rule 74/82 边界、归属定稿与覆盖面映射，属计划设计决策与计划文档维护（25.3②） |
| Phase 3 | Agent 子代理 executor(sonnet-1)；Edit/Read/Grep | SKILL.md 流程增量修改为多段文本编辑，按 25.1/104 默认派发执行体 |
| Phase 4 | Agent 子代理 executor(sonnet-1)；Edit/Read/Grep | 规则条款与索引联动为结构化文档变更，需精确增量与一致性维护 |
| Phase 5 | Agent 子代理 code-runner-agent(mini)；Bash/Grep/Read | 机械校验（grep 锚点、计数、diff/一致性命令）可批量执行并产出证据 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 激活条件（无 ≥3 独立并行 S-unit fan-out 组、非长链编排型、用户未点名 /workflow）→ 采用 Rule 21.4 独立性守门调度（Phase 1 内 P1-S1~S3 无依赖已声明并行组 `p1-audit-baseline`；跨 Phase 串行）。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 为会话目标证据源；`/goal` 为用户侧 harness 命令，技能层不可代调，执行期不虚构 /goal 状态。

## Phases

### Phase 1: 现状核实与覆盖面盘点
- [x] 核实 SKILL.md 计划制作循环插入点（钉死：智能子动作完成后、D1 展示前）与现有约束（插入点=:66/68 间；G1=:174；44.3=:70-71；单写者=:53）
- [x] 核实审计载体与既有覆盖机制（critic/decision-arbiter/Rule 103/84/108/69/48），形成已识别覆盖面（非穷尽）缺口矩阵与未列面判定规则输入（缺口=计划面+报告总结面；10 项未列面候选）
- [x] 确认 Rule 109 编号可用性、落点与归属（核心计划制作域+全流程总则）及文本优先/机器面待授权候选边界（next=109；落点=:192 后；索引联动 5 面）
- [x] 将盘点结论回填 findings.md、knowledge-brief.md §2/§3（findings P1 段已回填，3-file gate exit=0）
- **V-N:** VC-1, VC-3（为门控与全流程映射提供可追溯现状证据）
- **Status:** complete
- **Executor:** explore（mini）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|------|------|------|
| S1 | [parallel-group:p1-audit-baseline] 核实 D1 前计划审计插入锚点与前后约束 | explore（mini） | `skills/task-planner/SKILL.md:38-75,61-75`（初始化首动作委派收尾、盘上复核、智能子动作与计划确认/D1 门控） | findings 记录精确插入点（智能子动作完成后、D1 展示前）、必须保留前置条件与“未经审计禁入 D1”挂载位置 | 15min | 1f/60l/15min | 无 | - | pending |
| S2 | [parallel-group:p1-audit-baseline] 盘点已识别审核面覆盖与缺口（非穷尽） | explore（mini） | `/home/terry/.zcode/agents/critic.md:1-70`（审查计划能力）；`skills/task-planner/SKILL.md:118,129,142,247`（Rule 103/84/108/69/48/CR分歧触点）；卫星路由索引摘要 | findings 产出已识别五面矩阵+未列面简版复核判定输入：已覆盖机制/缺口/拟映射 | 15min | 2f/80l/15min | 无 | - | pending |
| S3 | [parallel-group:p1-audit-baseline] 确认 Rule 109 落点/归属与变更边界 | explore（mini） | `skills/task-planner/references/critical-rules.md:1-10,140-208`（核心域与规则尾部）；全仓 grep 结论“活跃代码无 `### 109`”（计划期已核实） | findings/Decisions 记录：Rule 109 增量候选、归属定稿（核心计划制作域+全流程总则）、Rule 74/82 约束、文本优先、机器面列待授权候选 | 10min | 2f/50l/10min | 无 | - | pending |

### Phase 2: 方案定稿与变更设计
- [x] 定稿计划审计门协议（适用范围 L1+、插入点、审计体/输入输出、APPROVED/REJECTED 判定与达标判据、迭代/升级/降级链、再展示简版审计）→ design-p3-p4.md §A
- [x] 定稿修正执行体（主进程驱动 Plan Writer 重派）与再审派发方；定稿审计输入材料包（task_plan + user-session-log 需求锚 + knowledge-brief + 上轮问题清单）→ design §A
- [x] 定稿轻量复核最小定义：主进程盘上复核 + 基线自查 + 一行留痕 `[plan-audit-skip]`（豁免时登记理由）；L0-E 天然豁免（无需留痕）；mini/L0/trivial 轻量复核口径采用本定义（不并入 mini 豁免，保留可追溯留痕）→ design §A
- [x] 定稿全流程“未经审计产出禁交用户”覆盖映射（已识别覆盖面非穷尽+未列面简版复核判定规则）与 Rule 109 子条结构/归属（文本优先）→ design §C（109.1-109.7 七子条）
- [x] 逐行复核本文件「📋 变更标注表」区块六行（CA-1~CA-6，本文件 :130-141 附近）与 Phase 3/4 S-unit 表「输入」列：确认每行变更对象/锚点/执行动作具体可执行、每 S-unit 输入含路径+摘要，缺项当场补齐（CA-1~CA-4 对应 design §A-D；CA-5 预裁=默认不落地见 design §E；CA-6 保持待授权不实施）
- [x] 复核与 R1-R3 不变量、Rule 82 边界、44.3 边界、103 边界一致（插入文本含 44.3 不适用+103 边界声明；109 引用不改写卫星语义）
- **V-N:** VC-1, VC-2, VC-3, VC-4（方案覆盖核心契约、归属与判据）
- **Status:** complete
- **Executor:** 主进程（例外理由:25.3② 计划系统文件维护——仅编辑 `plans/**` 计划文档；设计决策以既有七文件载体整合，派发开销大于收益）

### Phase 3: 计划审计门落地（SKILL.md 流程）
- [x] 在钉死插入点插入 D1 前 `计划独立审计门` 与迭代闭环（critic 主审计，争议/分歧可走 decision-arbiter）——worktree SKILL.md :68-77 插入 10 内容行，与 design §A 逐字一致（executor 产出+主进程盘上复核+103 复检 PASS）
- [x] 明确分档适用、达标判据与裁决转换、固定留痕载体 `progress.md [plan-audit-R<N>]`、44.3 不适用、审计体降级链；**明确任何 L1+ 计划（含再展示/修订重审）展示/确认前均过审计门；轻量档按分档规则（轻量复核或登记豁免）；修订重审可用简版（仅审变更增量+上轮问题清单闭环检查）**——全部含于插入区块
- [x] 同步计划确认、合规检查等受影响段落，保持与 22.4a/62.2/103 等既有契约一致；声明 103 边界不叠加——G1 :185 前置+D1 :81 44.3 排除括注（worktree commit 5b728a7；VC-1 命中=3）
- **V-N:** VC-1, VC-2, VC-4, VC-6（门控生效、判据可观察且不破坏一致性）
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|------|------|------|
| S1 | 插入 D1 前 `计划独立审计门` 与迭代/留痕/降级协议 | 继承 | `skills/task-planner/SKILL.md:50-75,61-75`（首动作委派/智能子动作/计划确认段）；Phase 2 定稿协议（Decisions/CA-1,CA-2） | SKILL.md 含专有 token、钉死插入点、L1+ 分档、APPROVED/REJECTED 循环、达标判据与裁决转换、固定留痕字段、**任何 L1+ 计划（含再展示/修订重审）前过审计门+轻量档按分档规则+修订重审简版**、44.3 不适用、降级链、达标前禁入 D1 | 15min | 1f/90l/15min | 无 | - | pending |
| S2 | 对齐计划确认、合规检查与 103 边界表述 | 继承 | `skills/task-planner/SKILL.md:68-75,170-184`（D1/目标绑定/合规清单相关行）；S1 结果摘要 | D1 前置条件与检查项包含“计划审计通过（L1+）”，103 边界声明在位且无语义冲突 | 10min | 1f/50l/10min | 无 | S1 | pending |

### Phase 4: 全流程原则条款与索引联动落地
- [x] 在 core critical-rules.md 追加 Rule 109 `audit-before-delivery`（增量，归属定稿）并映射已识别覆盖面（非穷尽）+未列面简版复核规则——:194-212（109.1-109.7+Why），与 design §C 逐字一致（含 109.3「天然」补齐 1c49637）；rule-reserve reserve/land 完成（主仓台账 commit 18a4f2e）
- [x] 更新 SKILL.md 与 critical-rules 索引/计数/摘要，确保可检索一致——:9/:258/:302+critical-rules:180 计数同步（1-109/15 条/90 条），旧计数清零（P4-S2 验收 grep=0/0）；SKILL:70 分档措辞对齐 §A（1f568f7）
- [x] 按需最小联动报告/模板提示（CA-5 条件式）——实测 templates/delivery-summary.md 在位（worktree+主仓），按 design §E 预裁：不新增模板提示行（Rule 109.4 已覆盖报告面），CA-5 不落地
- **V-N:** VC-3, VC-4（原则覆盖与编号/索引一致）
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|------|------|------|
| S1 | 追加 Rule 109 主条款（条款主体 ≤100 行；索引同步归 P4-S2） | executor（sonnet-1） | `skills/task-planner/references/critical-rules.md:140-208`（Rule 80-83 尾部范式与路由索引）；Phase 2 Rule 109 草案与映射 | `### 109 audit-before-delivery` 主条款在位，含计划制作域审计门+全流程原则总则+已识别覆盖面映射+未列面简版复核判定规则+留痕+103 边界+文本优先机制说明，增量不改既有语义；**不含索引/计数联动（P4-S2 承担）** | 15min | 1f/95l/15min | 无 | - | pending |
| S2 | 同步规则索引与 SKILL 联动摘要 | 继承 | `skills/task-planner/references/critical-rules.md:1-10,194-208`；`skills/task-planner/SKILL.md:9,247,256-259`；S1 结果 | 全集/核心索引与 Rule 109 可定位且计数表述一致；必要时补最小报告面提示（CA-5） | 15min | 2f/80l/15min | 无 | S1 | pending |

### Phase 5: 校验、收尾与交付准备
- [x] 执行 VC-1~VC-6 机械/复核命令并记录证据（grep/Read/计数/留痕核验）——P5-S1 采证 16/16 全 PASS（VC-1=3/VC-2 留痕链/VC-3 109.1-109.7/VC-4 唯一性+计数/VC-6 预演=0；回归 dispatch rc=0+delegation ok）
- [x] 完成多文件变更集同步核对清单（103.6，若触发）与 Rule 74 变更标注表勾核——P3/P4 双独立复检 RECHECK: PASS（103.6 清单全绿）；CA-1~CA-4 已落地、CA-5 不落地（预裁）、CA-6 未授权未实施
- [x] 汇总 findings/progress/verification，准备 Code Review Gate 与终验交付材料——终验前待办清单已出（P5-S2 checkpoint）
- [x] 归档前置条件检查（check-complete 通过后按 Rule 81；本阶段仅准备）——worktree clean（HEAD 1c49637，3 commits）+主仓 ledger committed（18a4f2e）
- **V-N:** VC-4, VC-5, VC-6（一致性、计划可审计与端到端证据收口）
- **Status:** complete
- **Executor:** code-runner-agent（mini）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|------|------|------|
| S1 | 运行锚点与一致性校验命令采集证据 | 继承 | 变更后 `SKILL.md`、`references/critical-rules.md`；本计划 VC 表命令与基线记录 | 输出 VC-1~VC-4,VC-6 对应 grep/计数/留痕结果并落盘到 verification/progress | 10min | 2f/40l/10min | 无 | - | pending |
| S2 | 核对计划完整性与交付准备清单 | 继承 | `plans/task-planaudit-20261116/task_plan.md`、`knowledge-brief.md`、变更标注表、progress 审计段 | VC-5 核对通过项与待终验项清单在 verification.md 可见；记录 CR Gate/归档前置提醒 | 10min | 2f/30l/10min | 无 | S1 | pending |

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）

| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1 | 84.14 全量回读发现四处陈旧/噪音：①findings/kb 多处「待最终达标轮复审（如 R3）」未闭环标注（R3 已 APPROVED）②task_plan Next Step/Current Phase 停留在 pre-D1 时点③Handoff #5-#9 queued 占位行与执行 done 行重复（簿记噪音）④progress 尾部 plan-resume 报告表为空属模板占位（本任务非 plan-resume 恢复场景，登记不适用） | 全部当轮处置：①findings 追加 84.14 闭环标注段+kb §2 L33 行追加闭环括注②③本回读轮内已更新/清理（Next Step 已改合并回序列；queued 副本已删除）④登记不适用理由。回读轮次 1 零新增未处置发现 → 满足收敛出口（连续一轮零新发现），可出 outcome |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（技能核心流程/规则文件改动，属实现类基础设施性变更；执行前须复跑 `bash skills/task-planner/scripts/check-conflicts.sh` 确认） |
| `isolation` | `worktree`（实现类默认首选，§十一） |
| `worktree_path` | `tmp/worktrees/task-planaudit-20261116` |
| `branch` | `wt/task-planaudit-20261116` |
| `merge_back` | `pending` |

> 契约详见 `skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | 误判既有机制已覆盖，导致 VC-3 映射缺口漏检（含未列面漏判） | 7 | 4 | 5 | 140 | ② 拆细取证：强制产出已识别五面矩阵+未列面判定规则并逐条附 file:line 证据；矩阵缺任一面/判定规则=不进入 Phase 2 |
| Phase 2 | 审计协议与计划期单写者/22.4a/62.2 冲突，或达标判据/升级出口不可执行 | 8 | 4 | 5 | 160 | ③ 降档重审：以 critic+decision-arbiter 职责边界复核协议；冲突项回退为“主进程按审计意见驱动 Plan Writer 修正（重派）”并登记 Decisions；定稿输入包与升级出口 |
| Phase 3 | 插入审计门破坏 D1/attest/展示顺序、与 44.3 冲突或造成死循环阻塞 | 9 | 3 | 5 | 135 | ① 改派/② 拆细：钉死插入点并声明 44.3 不适用审计门；先在隔离 worktree 小步改 SKILL.md 并 grep 关键序列；无进展触发≥3轮升级出口 |
| Phase 4 | Rule 109 归属/编号/索引与 Rule 82、20.6 冲突，引入规则漂移 | 8 | 3 | 6 | 144 | ② 拆细+⑤ AskUserQuestion：归属已先定稿再落笔；实施前 grep 编号与索引锚点，冲突升级用户裁决 |
| Phase 5 | 仅文本 grep 通过但语义未闭合（伪覆盖）或 R2 审计未达标即推进 D1 | 8 | 4 | 6 | 192 | ④ 主进程接管复核：判别性 token+基线记录+Read 语义复核；独立 critic R2 审计作为端到端门控；未达标=阻断 D1 并回炉 |

**填写规则**：RPN>100 项已登记兜底；执行期实际失败仍走 Rule 22.3 完整链路。

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 计划确认(D1)后执行 S1 建立映射 |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |

> 契约详见 `skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
1. （已定稿，R2 复审验证）计划审计“完全达标”判据：审计体输出 0 CRITICAL 且 0 IMPORTANT 且连续一轮零新发现（新发现=新增 CRITICAL/IMPORTANT；WARNING/QUESTION/NIT 留档不阻断）⇒APPROVED，否则 REJECTED（REJECTED 必附问题清单）；裁决由审计体出具，主进程只登记不自判。升级出口：争议→decision-arbiter；连续≥3 轮无实质进展→呈报用户裁决。
2. （已定稿）Rule 109 归属：核心 `skills/task-planner/references/critical-rules.md` 落计划制作域条款（计划审计门属计划生命周期=核心域）+全流程原则总则（含已识别覆盖面映射引用 Rule 103/84/108/69）；跨域细则仅引用不改写卫星语义。据此冻结 VC-4 判据与 CA-3/CA-4。
3. （执行期收敛）报告/总结面（delivery-summary 等）最小改动：若规则/流程文本已足以承载审计要求则不改模板并在 Decisions 登记理由（CA-5）；仅必要时增量提示，不引入未经授权机器门控。

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 采用 `template_type: rule-enhancement` 起草本计划 | 用户目标为优化 task-planner 技能规则/流程（新增审计门与全流程原则），契合规则增强画像；非单纯诊断/写作 |
| 计划审计主审计体选用既有 `critic`，分歧仲裁走 `decision-arbiter`（Rule 69.1） | critic 明确支持“审查计划/review文档”（/home/terry/.zcode/agents/critic.md:5）；复用既有裁决链避免新建重复执行体（增量原则） |
| 默认文本条款承载，机器面（selftest/attest 接线）列为待授权候选 | 宪法文本优先铁律与用户未显式要求脚本/守卫；CA-6 保留条件式扩展路径，D1 明示后再实施 |
| Rule 109 作为候选增量编号并先 grep 确认未占用 | 活跃代码库未发现 `### 109` 定义；按 Rule 20.6 执行期 reserve/land，避免编号竞态 |
| 隔离策略采用 worktree（实现类技能核心文件改动） | 变更触及 SKILL.md 与核心规则，按 §十一 默认隔离降低并行/半残风险；执行前复跑冲突扫描确认 |
| 全流程覆盖采用“总则+既有机制映射”，已识别覆盖面非穷尽；未列面默认简版独立复核+判定规则（F1） | 满足 R2 贯彻精神且避免 51.9 自缩水式封闭枚举；计划/执行产物/终验/裁决已有 Rule 103/84/108/69 覆盖，增量引用映射符合 Rule 74/82 |
| Rule 109 归属定稿：核心 critical-rules.md 计划制作域条款+全流程原则总则，跨域细则仅引用不改写卫星语义（F8） | 计划审计门属计划生命周期/制作域，核心可承载；全流程细则分属 dispatch/verification/discipline 等卫星，引用映射避免改写卫星语义 |
| 审计门分档适用：L1+ 强制；mini/L0/trivial 轻量复核或登记豁免；L0-E 豁免（F11） | 对齐比例原则与既有轻量豁免判例（SKILL.md:51,57），避免一刀切仪式膨胀 |
| 达标判据与裁决转换定稿（F4/F5） | 0 CRITICAL 且 0 IMPORTANT 且连续一轮零新发现（新发现=新增 CRITICAL/IMPORTANT；WARNING/QUESTION/NIT 留档不阻断）⇒APPROVED，否则 REJECTED；审计体出具裁决（REJECTED 附清单），主进程只登记；争议→decision-arbiter，连续≥3 轮无实质进展→用户裁决 |
| P4-S1/P4-S2 拆分依据（NEW-1） | Rule 109 条款主体（≤100 行）与索引/计数/SKILL 摘要联动分属两个 S-unit：条款落笔受 100 行粒度硬门约束，索引联动涉及多文件一致性与计数校验，合并会超粒度且难以独立验收；故 P4-S1 收敛为条款主体、P4-S2 承担索引同步 |
| 轻量复核最小定义（NEW-12） | 主进程盘上复核 + 基线自查 + 一行留痕 `[plan-audit-skip]`（豁免时登记理由）；L0-E 天然豁免；与既有 mini 豁免口径二选一，Phase 2 定稿时在清单明确 |
| VC-6 验证命令主进程接管替换（2026-11-16） | Plan Writer 微修轮先以纯文本计划冒充落盘（盘上实测 0 命中，打回后已实际执行），随后主进程模拟实测发现 tac 命令判别力来自旧段「APPROVED/REJECTED」枚举词偶然命中=非语义判别；按 §一「极简单可主进程做」以 awk 末段聚合命令替换（verification.md:30 / task_plan.md:78），三态实测（真实 FAIL/模拟 PASS/相对路径 FAIL）全部正确；单行命令替换属极简单修正非内容创作 |
| 审计门不适用 44.3 自动通过；审计体降级链 critic→重试1→decision-arbiter→general-purpose→AskUser（F10） | 防未达标自动放行；保障审计能力不可用时可追溯逐级处置 |
| 留痕载体钉死为 `progress.md [plan-audit-R<N>]` 固定段（F16） | 统一可核对形态；R1 已作为首例实证 |
| 插入点钉死为智能子动作完成后、D1 展示前；任何 L1+ 计划（含再展示/修订重审）展示/确认前均过审计门；轻量档按分档规则（轻量复核或登记豁免）；修订重审可用简版（F7/F3） | 消除歧义并覆盖 B/C/D/E 再展示面；简版限变更增量+上轮问题清单闭环检查（不重审全文但必须闭环上轮问题） |
| 103 边界不叠加（F9）；修正执行体=主进程驱动 Plan Writer 重派，再审由主进程派发（F6） | 与既有双轮质检职责清晰；符合计划期单写者/22.4a/62.2 约束 |
| VC-1/2/3 采用判别性专有 token + 基线负断言记录（F12）；新增 VC-6 端到端实跑证据（F2） | 避免基线即 PASS 伪绿；以本计划 R1→修订→R2 审计闭环补齐目标型判据 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| Plan Writer 微修轮以纯文本修改计划冒充落盘收据（盘上实测 `tac plans` 命中=0） | 1 | 盘上实测抓破→打回并显式要求 Edit 实际执行+粘贴真实 grep 输出→第 2 轮实际落盘（22 次工具调用） | 收据必须含盘上实测命令输出；主进程对子代理收据逐关键断言 grep 复核（Rule 84.4/§三），「应落点/待执行」措辞=未完成信号 |
| VC-6 验证命令 tac 形态判别力来自旧段「APPROVED/REJECTED」枚举词偶然命中（模拟实测暴露） | 1 | 主进程接管替换为 awk 末段聚合命令（Decisions 已登记），三态实测（真实 FAIL/模拟 PASS/相对路径 FAIL）全部正确 | 验证命令必须模拟正反双态实测判别性后才可冻结（F12/NEW-5 同族教训：基线即 PASS 或恒真=伪绿） |
|       | 1       |            | → progress.md Error Log   |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- R1 审计 REJECTED（18 发现）已在 `progress.md [plan-audit-R1]` 留痕；R2 复审 REJECTED（F1-F18 闭环 18/18，新发现 12 项）已在 `[plan-audit-R2]` 留痕；修复轮 2（NEW-1~NEW-12）增量落盘，待下一轮复审 APPROVED 后方可进入 D1 展示/确认
- 计划审计门不适用 Rule 44.3 自动通过；未达标禁自动放行
- 轻量复核最小定义（NEW-12）：主进程盘上复核 + 基线自查 + 一行留痕 `[plan-audit-skip]`（豁免时登记理由）；L0-E 天然豁免
- 机器面扩展（selftest/attest）未经 D1 显式授权不得实施（CA-6）

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-11-16 | R1 critic REJECTED（18 发现：B2/M7/m9） | VC-1,VC-2,VC-3,VC-4,VC-5 | 已打回修订并逐项处置（F1-F18）→R2 REJECTED(12)→修复轮2+微修→R3 APPROVED（0C/0I）；审计循环收敛闭环 |
| 2026-11-16 | drift-checker 全跨度检查（P1-P5） | VC-1~VC-6 | **ALIGNED**：worktree 仅 2 技能文件（diff master +37/-6 skills/）、主仓提交仅本计划目录+ledger、R1-R3 逐字锚在位、无越界无加戏 |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6）

| 字段 | 值 |
|------|-----|
| `total` | n/a（无同类 fan-out 批处理：9 个离散异质 S-unit 非批量同类操作） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | n/a |
| `pre_check` | n/a（Q1:是-每单元独立判断但非批量脚本/同类 fan-out；Q2:有客观 VC；Q3:git+worktree 可回滚；本任务按逐 S-unit 子代理执行） |
| `rollback_point` | n/a（执行期以 worktree 分支 `wt/task-planaudit-20261116` 为回滚点，合并前可弃） |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 4 / 5（P1 explore×3 并行组+P3 executor×2+P4 executor×2+P5 code-runner×2；P2=主进程 25.3② 例外；计划期审计 critic R1/R2/R3 三轮另计） |
| 主进程直做 Phase 清单 | Phase 2（例外理由:25.3② 计划系统文件维护——仅编辑 plans/** 计划文档；设计决策以既有七文件载体整合，派发开销大于收益） |
| 委派率 | 待执行期统计（目标 ≥ delegation_rate_floor；主进程直做仅白名单例外） |
| 激活子代理数（Rule 96.5） | 15（计划期 6：Plan Writer 起草+修复轮1+修复轮2 / critic R1+R2+R3；执行期 9：explore×3+executor×4+general-reviewer×2+code-runner×2+drift-checker×1+Code Reviewer×1——复检/CR/漂移审计另计口径见 Handoff #15/#16/#17）；check-delegation stats=rate 0.800 verdict ok（0 violations） |
| 最大并行宽度（Rule 96.5） | 1（当前）；Phase 1 设计并行组 `p1-audit-baseline`（S1-S3）待执行期并发派发 |
| 串行化例外理由（Rule 96.4） | none（跨 Phase 串行属天然依赖；P1 组内并行已声明） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-11-16 | explore | P1-S1 核实计划审计插入锚点与D1前约束 | done | 插入点=SKILL.md:66/68 间（中间仅空行）；门控序列 :69-74；G1=:174；44.3=:70-71；单写者=:53；索引联动=:9,247,291 | worktree SKILL.md 实测行号 | findings.md P1-S1 段 | - | - / 1 / ☑ |
| 2 | 2026-11-16 | explore | P1-S2 盘点已识别审核面覆盖与缺口矩阵 | done | 五面矩阵：缺口=计划面+报告总结面；部分缺口=终验面/直做豁免面/上抛面；10 项未列面候选；⚠ templates/delivery-summary.md 疑缺失待 P4 实测 | dispatch:225-245/verification:35-70/discipline:384-393 | findings.md P1-S2 段 | - | - / 1 / ☑ |
| 3 | 2026-11-16 | explore | P1-S3 确认 Rule 109 落点/归属与变更边界 | done | next=109 水位一致；落点=critical-rules.md:192 后；索引同步 5 面（:180/:194-207/SKILL:9/247/291）；Rule 82/74/20.6 锚齐；token 基线 0 | rule-reserve.sh:1+critical-rules.md:162-192 | findings.md P1-S3 段 | - | - / 1 / ☑ |
| 4 | 2026-11-16 | executor | P3-S1 插入 SKILL 计划审计门与迭代留痕 | done | +11 行（307→318）:68-77 与 design §A 逐字一致；主进程盘上复核+逐字 diff 通过；commit 5b728a7 | worktree SKILL.md:68-77 | findings.md P3 段 | design §A | - / 2 / ☑ |
| 5 | 2026-11-16 | executor | P3-S2 对齐 G1 与 44.3 表述 | done | G1 :185 前置+D1 :81 排除括注；wc 318 零增删行；主进程复核 grep=1/1 | worktree SKILL.md:81,185 | findings.md P3 段 | design §B | - / 3 / ☑ |
| 15 | 2026-11-16 | general-reviewer | P3 独立复检（103.3a 全文回读） | done | RECHECK: PASS：逐字/结构/语义/回归四维全过；Rule 109 未落地=P4 瞬态非缺陷 | worktree SKILL.md 全文回读 | progress.md [p3-recheck] | subagent-state/p3-recheck-checkpoint.md | - / 4 / ☑ |
| 6 | 2026-11-16 | executor | P4-S1 追加 Rule 109 全流程条款 | done | critical-rules.md 207→227（:194-212 109.1-109.7+Why）；audit-before-delivery=4；主进程复核+P4 复检比对 | worktree critical-rules.md:194 | findings.md P4 段 | design §C | - / 5 / ☑ |
| 7 | 2026-11-16 | executor | P4-S2 同步索引计数与 SKILL 摘要 | done | 4 行 5 处计数同步（1-109/15 条/90 条），旧计数 0/0；SKILL:175→258 口径引用同步修正 | worktree SKILL.md:9,258,302+critical-rules:180 | findings.md P4 段 | design §D | - / 6 / ☑ |
| 16 | 2026-11-16 | general-reviewer | P4 独立复检（103.3a+103.6） | done | 首轮 FAIL 2 项→全部闭环：ledger=主仓共享账本伪缺陷（主仓 check=landed 实锚）；SKILL:70+critical-rules:202 两处「天然」措辞偏差主进程 grep 实锤直修（1f568f7/1c49637）→ **RECHECK: PASS** | worktree 全文回读+103.6 清单 | progress.md [p4-recheck] | subagent-state/p4-recheck-checkpoint.md | - / 7 / ☑ |
| 8 | 2026-11-16 | code-runner-agent | P5-S1 VC 全量采证 | done | 16/16 全 PASS（VC-1~VC-4+回归+git；worktree clean HEAD 1c49637；diff master 2 skill files +37/-8） | p5-s1-checkpoint.md 采证汇总表 | findings.md P5 段 | subagent-state/p5-s1-checkpoint.md | - / 8 / ☑ |
| 9 | 2026-11-16 | code-runner-agent | P5-S2 交付准备核对 | done | VC-5a/b/c PASS+VC-6 预演 PASS；NOT-READY=P5 翻转前事实（已翻转）；终验前待办清单已出 | p5-s2-checkpoint.md | findings.md P5 段 | subagent-state/p5-s2-checkpoint.md | - / 9 / ☑ |
| 17 | 2026-11-16 | drift-checker | P1-P5 全跨度偏移检查（Rule 61/64） | done | **DRIFT: ALIGNED**：R1-R3 逐字锚在位、worktree 仅 2 技能文件、主仓提交仅本计划目录+ledger、无越界；簿记噪音（queued 重复行）已清理 | drift-check-20261116.md | task_plan Drift Log | subagent-state/drift-check-20261116.md | - / 10 / ☑ |
| 10 | 2026-11-16 | critic | 计划独立审计 R1（D1 前）：审计 task_plan.md 对 R1-R3 的覆盖与合理性 | done | REJECTED：18 发现（B2/M7/m9）全清单留痕 progress.md [plan-audit-R1]；已打回 Plan Writer 修订 | plans/task-planaudit-20261116/progress.md | progress.md [plan-audit-R1] | - | - / 1 / ☑ |
| 11 | 2026-11-16 | Plan Writer(续) | R1 修复轮：按 F1-F18 修订五计划文档 | done | 18/18 逐项处置带落点；主进程盘上抽查 7/7 PASS；收据 progress.md [plan-audit-R1-revision] | plans/task-planaudit-20261116/progress.md | progress.md [plan-audit-R1-revision] | - | - / 2 / ☑ |
| 12 | 2026-11-16 | critic(续) | 计划独立审计 R2（修订后复审）：核验 F1-F18 闭环与达标判据 | done | REJECTED：F1-F18 闭环 18/18；新发现 12（C1/I1/W6/Q1/N3）全录 progress.md [plan-audit-R2]；已打回修复轮 2 | plans/task-planaudit-20261116/progress.md | progress.md [plan-audit-R2] | - | - / 3 / ☑ |
| 13 | 2026-11-16 | Plan Writer(续)+主进程 | 修复轮 2（NEW-1~12）+微修（VC-6 轮次无关命令） | done | 修复轮 2 十项全落盘（dispatch rc=0/delegation ok 双门实测）；VC-6 tac 命令判别缺陷经模拟实测暴露→主进程接管换 awk 末段聚合（三态实测正确，Decisions 已登记） | plans/task-planaudit-20261116/progress.md | progress.md [plan-audit-R2-revision] | - | - / 4 / ☑ |
| 14 | 2026-11-16 | critic(续) | 计划独立审计 R3（最终达标轮）：核验 NEW 闭环+微修+达标裁决 | done | **APPROVED**（0C/0I）：F1-F18 保持闭合+NEW-1~12 12/12+微修核验通过；3 WARNING+5 NIT 非阻断已即时收敛（WARNING×3/NIT-2/3/4）或留档（NIT-1/5）；全录 progress.md [plan-audit-R3] | plans/task-planaudit-20261116/progress.md | progress.md [plan-audit-R3] | - | - / 5 / ☑ |

> 派发 prompt 八字段模板: `skills/task-planner/templates/subagent_dispatch.md`；每次返回 30s 内 Read 产出+回填 findings 后勾 verify_done。留痕载体钉死：`progress.md [plan-audit-R<N>]` 固定段（轮次/审计体/结论/问题清单/修复对照）。

## 🔗 Chain 区块交接配置（可选）

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
| **current_block** | Block 1 |
| **handoff_on_complete** | ❌ 否 |

## 🔁 模板感知
<!-- template_type: rule-enhancement（显式选择，非 general 兜底） -->
- 触发信号: 任务为 task-planner 技能规则/流程增强（计划审计门+全流程独立审计原则，含新增 Rule 候选）
- Rule 34.3② 沉淀预登记: 本任务复用既有 `rule-enhancement` 变体，不新增变体模板
- 终验必查: 不适用 general 兜底；如执行中发现该类“审计门流程增强”存在可泛化缺口，按 34.3 登记沉淀理由/不沉淀理由
- 处置登记处: 终验 findings/Decisions 记录“复用 rule-enhancement 变体，不沉淀新变体”及理由
