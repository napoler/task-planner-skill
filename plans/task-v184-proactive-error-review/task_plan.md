# Task Plan: 主动错误发现与内容审查能力升级（v183 收口后接线批次+语义层）
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  选定 variant 后 template_type 填所选类型名（白名单=${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/variant/*-type.md 动态派生，见 check-template-type.sh）；general=通用回退（恒合法，Rule 34.1）
  plan_tier ∈ {standard, mini}（Rule 38.1，mini 四条件机器判定）；execution_lane ∈ {L0, L1, L2}（Rule 38.7，缺省 L1；L0 禁滥用见 38.7 末段）
  check-template-type.sh 三形态之一：行首 `^template_type:`（本块）/ 表格行 / HTML 注释；本块用行首形态 -->
template_type: general
plan_tier: standard
execution_lane: L1
<!-- 
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC（核心问题的可观察解决证据，非手段产物完成）；目标型任务终验必填「🎯 核心目标达成裁决」区块（58.5） -->

- **R0**: 「审查当前技能的就是对错误的发现能力，也就是说质量检测能力。」<sub>（[手段]）</sub>
- **R1**: 「我希望可以提高该技能的主动发现问题能力，就是因为当前技能核心点、核心地点，专注于记录以及收集信息，就是记录各种信息，记录运行过程中收集的数据以及运行日志类似的运行的记录。」<sub>（[目标]）</sub>
- **R2**: 「还有就是可以主动发现偏差、偏移以及错误，进行及时纠正。」<sub>（[目标]）</sub>
- **R3**: 「还有就是对内容的错误及时审查出来，确保可以及时纠偏。所有出现的错误都可以审查出来。提高内容错误的审查能力才是最核心的，我希望可以提高内容审查能力的。」<sub>（[目标]——用户明示最核心）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R0 | VC-2 | 审查判据=三类漏检→接线面映射（report §5 落地方式列逐条对齐）；「主动拦截生效」即审查结论的可观察落地（R0 为手段行，映射 VC-2 收口） |
| R1 | VC-2 | 5 判定器接线后：注入缺陷计划走真实门链（attest/check-3file-gate/check-complete）exit≠0 且留痕；此前=手动调用不主动（v183 风险①） |
| R2 | VC-2, VC-5 | 偏差/偏移类（P-06 CJK 漂移/P-08 R→VC 缺映射）在翻转期+终验期自动拦截；纠正走既有 Rule 31/64 SOP 不新建 |
| R3 | VC-3, VC-4 | 内容级核对层（声明串↔证据文件内容不符→FAIL）+ 内容审查门规则条款（84.7）落地；语义级零机器检查缺口（report §7.3 high）收窄 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/<task-id>/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/task-v184-proactive-error-review/user-session-log.md`（模板 = ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

R1-R3 为结果级需求（提高发现/审查能力），按错误检查发生的生产管线逐工序审计缺陷面：

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 规划期（attest 锁定门） | 真空 VC 命令/模糊占位步骤/R→VC 缺映射/档位自声明——四类全无自动拦截（report §7.1 P-02/03/08/09） | Phase 2 S1-S4 接线 attest-plan.sh | VC-2 |
| 翻转期（Phase complete 门） | 纯中文 Goal CJK 分词空转→漂移静默跳过（P-06；check-3file-gate 无第 6 条件消费面） | Phase 2 S5 接线 check-3file-gate.sh+语料校准 | VC-2 |
| 终验期（check-complete 门） | 6 新判定器未被任何门链调用=「检测器发货即死」（v183 风险①；report §5.1 修订 3 诊断的失效模式） | Phase 2 S1/S2 接线 VC-GATE 段 | VC-2 |
| 内容层（证据↔内容一致性） | 全部机器检查止于格式/计数/存在性/词法/路径归属——文件真存在但内容与声明无关=零检查（report §7.3 high，v183 风险③） | Phase 3 S6/S7 内容核对层 + S8 84.7 条款 | VC-3, VC-4 |
| 检查器自身可靠性 | selftest 主体是静态文本锚，门控判定逻辑无行为级回归（report §7.3） | Phase 2 各 S-unit 注入式验收（§5.1 修订 3 标准） | VC-2, VC-5 |
| 纠正闭环（及时纠偏） | 门 fired 后纠正 SOP 已在位（Rule 31 错误四步/Rule 61 drift 三态/Rule 64 留痕）——缺陷在「门不自动 fired」而非「纠正缺位」 | 不新建，由接线激活 | VC-2 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Goal 一句话/R1-R3 原文/VC-1..5 判定标准/全量回归 0 新增失败/§5.1 修订 3 注入式验收标准/84.7 子条承载不新增 Rule 编号 | 本文件 Goal/VC 表/Decisions Made |
| 🔒 不变量 | 既有门行为不回退：check-complete 既有门链（R-COVERAGE/VC-GATE/STATE-CONSISTENCY/EVIDENCE-ANCHOR 等）当前语义保持 | skills/task-planner/scripts/check-complete.sh 现状 |
| 🔀 可变量 | 接线实现细节（shell-out 位置/输出前缀格式）/注入夹具设计/内容核对层声明串提取范围/各门档位键默认值（warn 起步） | Phase 内自主调+登记 Decisions |
| 📈 学得量 | 各判定器对存量 146 计划的误报率数据/语料校准阈值/内容核对层误报样本 | findings.md |

## Goal
将 task-planner 的错误发现能力从「被动记录/手动调用」升级为「主动拦截」：v183 落地的 5 个未接线判定器（P-02/03/06/08/09）接进 attest/check-3file-gate/check-complete 自动门链使规划期/翻转期/终验期三时点自动跑，并补齐内容错误审查层（证据声明↔文件内容机器核对 + Rule 84.7 内容审查门 + 注入式行为回归），全量回归 0 新增失败。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（门链 shell 脚本接线属保护区代码改动，§5.1 修订 3） |
| `session_id` | `e9716e6eab4842a99521379e6db9ef08` | 启动时生成,注册表追踪 |
| `worktree_path` | `n/a（isolation=direct，见隔离决策）` | §十一 隔离决策已有字段 |
| `scope_files` | `[skills/task-planner/scripts/attest-plan.sh, skills/task-planner/scripts/check-complete.sh, skills/task-planner/scripts/check-3file-gate.sh, skills/task-planner/scripts/check-evidence-anchor.sh, skills/task-planner/scripts/selftest-evidence-anchor.sh, skills/task-planner/scripts/selftest-registry.tsv, skills/task-planner/scripts/selftest-gate-injection.sh(新), skills/task-planner/config.json, skills/verification-gate/SKILL.md, skills/verification-gate/references/critical-rules-verification.md, plans/task-v184-proactive-error-review/**, plans/task-v183-verif-closeout/**]` | 从「执行范围限制」解析,并发检测基础 |
| `interaction_mode` | `ask` | Rule 28 交互模式：ask=关键决策点给选项；silent=静默+静默决策清单登记 |
| `对齐审查` | `[登记] 84.7 条款与 SKILL.md/verification-gate 消费面引用在完成前跑 alignment-review 对齐审查` | Rule 42.6 消费：任务产出或更新的文档在完成前跑 alignment-review 对齐审查（标准收尾流程）;文档更新前跑版本一致性校验（未经校验不追加）;变更记录随交付物落盘;mini 档豁免（42.6.4） |
| `自动超时默认项` | `[① v183 git 收口提交=执行(计划内授权,超时 5min 默认执行)；② 部署位同步=否(默认不部署,登记遗留)；③ 内容核对层档位=warn(默认,存量零误报基线后再议 enforce)；④ P-06 校准语料=取 plans/archive 存量(默认)]` | Rule 44 消费：本任务所有 2+ 选项询问点逐个登记默认选项（推荐项）与自动超时时长（默认 5 分钟,可覆盖）;低区分度选项（产出一致仅步骤/耗时差异）不询问、直接裁决并登记理由（44.2）;用户超时未答复按默认选项自动执行+登记自动裁决记录五要素（44.3）;mini 档豁免（44.4） |
| `new_rule` | 留空（内容审查门以 Rule 84.7 子条承载于 verification-gate 域，不新增编号——避免 1-91→1-92 纪元锚级联，判例见 task-v178/v183） | Rule 20.6：本任务新增 Rule 编号时填写（attest 自动预留+查重；无则留空） |
| `质量审查工具` | `[Verifier（Phase 4 独立验证+注入夹具复核）+ alignment-review（S8 文档对齐收尾）+ Code Reviewer（CR Gate）]` | Rule 42 消费登记（42.4）：任务涉及质量审查面时按 42.2 四级检测（含内置 review-library 兜底池）,填 技能名/既有 agent 名/待补充 S-unit 指针;缺口按 42.3 补建并登记 S-unit;执行期必须用登记工具;mini 档豁免（42.5） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

<!--
  WHAT: 任务执行完毕 ≠ 目标完成。此表确保每一步有可验证证据。
  RULE: 每个 phase 完成后对照 VC 编号复验；phase 全部 complete ≠ 通过终验。
  FORMAT: VC-N 是客观判定标准（可测试/可追溯/不依赖主观判断）。
  V-N: goal-gate.md 规定「≥5 条 VC + 每 phase ≥2 条 V-N（映射到 VC 编号）」；
       在每个 Phase 段（`### Phase N` 的 - **Status:** 行前）补 `- **V-N:**` 占位行，
       填写本 Phase 验收映射的 VC 编号（≥2 条，如 `VC-1, VC-2`；对应逐条验收记录在
       ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/verification.md 的 `V-N.N` 项，映射目标须为已定义 VC 编号）。
       check-complete.sh 终验 VC-GATE 段机械校验（config.json vc_gate_enforce，默认 warn）。
-->

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | v183 收口完成：check-complete exit 0、计划归档、Rule 90 首尾双锚 git 提交落库、基线取证 | 运行 check-complete.sh + archive-plan.sh + git log 对照 + 全量回归 | `bash skills/task-planner/scripts/check-complete.sh plans/task-v183-verif-closeout/task_plan.md`（exit 0）；`ls plans/archive/ | grep v183`；`git log --oneline -3`；`bash skills/task-planner/scripts/run-selftests.sh --fresh`（Total=90 FAIL=0） |
| VC-2 | 主动拦截生效：5 判定器接线后，逐门注入缺陷计划走**真实门链**被拦（exit≠0+留痕）；干净夹具+活计划全量零误报 | 每判定器一组注入夹具跑 attest-plan.sh / check-3file-gate.sh / check-complete.sh | `bash skills/task-planner/scripts/selftest-gate-injection.sh`（新，断言 ≥5 门注入全 exit≠0 且留痕行在位 + 干净夹具 exit=0）；`for p in plans/task-v18*/; do bash <各 check> $p; done` 零误报 |
| VC-3 | 内容核对层落地：证据格声明串（Total/exit=/ PASS=/FAIL= 形态）与证据文件实际内容不符→FAIL；相符→PASS；存量计划误报率量化登记 | 注入内容不符夹具 + 存量基线扫描 | `bash skills/task-planner/scripts/check-evidence-anchor.sh <内容不符夹具目录>`（exit≠0）；`bash skills/task-planner/scripts/selftest-evidence-anchor.sh`（新断言 PASS）；146 存量误报清单入 findings.md |
| VC-4 | 内容审查门规则条款落地：verification-gate 域 Rule 84.7 子条（内容型交付物终验前独立内容审查+结论落盘）+ SKILL.md 消费面引用 + 静态锚 | grep 锚核对 + alignment-review | `grep -c '84\.6' skills/verification-gate/references/critical-rules-verification.md`（≥1）；`grep -c '84\.6' skills/verification-gate/SKILL.md`（≥1）；selftest 静态锚 PASS |
| VC-5 | 无回归破坏：全量 selftest 0 新增失败，registry 双向一致 | 全量回归 + registry 校验 | `bash skills/task-planner/scripts/run-selftests.sh --fresh`（FAIL=0 且 Total ≥ 90）；`bash skills/task-planner/scripts/selftest-registry.sh`（rows=actual） |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
<!--
  WHEN: 终验时填写;含 [目标] 标注需求（下方 R 行）的任务必须在交付前出三态裁决
  WHY: Rule 58.5 完成裁决门——「分析报告已交付」不等于「问题解决了」;not-solved/partial 禁止标 COMPLETE
  载体: 58.4 手段/目标二分在需求原文区逐条标注 [手段]/[目标];本区块回收目标型需求的解决状态
-->
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1/R2/R3（R3 为用户明示最核心） |
| **裁决** | `solved` / `partial` / `not-solved`（三选一必填） |
| **解决证据锚** | （file#锚点/取证记录行；solved 必填） |
| **未解决面+原因** | （partial/not-solved 必填） |
| **已排除路径** | （not-solved 必填：试过什么+为何不行） |
| **下一步建议** | （not-solved 必填：可执行的下一步）（按 Rule 70：对象路径+看点+动作） |

> 纯手段型任务（用户只要动作/产物，无问题待解）可填 `n/a（纯手段型任务）`——须与需求区标注一致，禁裸豁免。

## 🎯 Goal 单元表（Rule 66.1 — 规划获批后任务单元固化；standard/full 必填，mini 档豁免）
<!--
  WHEN: attest 获批后立即填写（自动分解：S-unit/Phase → goal 单元映射）
  WHY: 用户 2026-10-09 裁决——任务分解后逐格固定为「任务名+目标+完整验证方式」，
       执行按 goal 逐个推进（66.3），/goal 目标模式完成审计的证据源（66.2 映射供料）
  列契约（66.1 六列）: goal-id(G1..) | 任务名(≤8字) | 目标(≤1句) | 完整验证方式(命令+判据/路径+关键行/diff形态,三选一必具其一) | 对应S-unit/Phase | 状态(pending/complete)
  状态机: pending → complete(仅 66.3 三证据齐备后翻格,同步 progress.md [goal:Gn] 证据行)
-->
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | v183 收口 | 未提交基座落库+基线取证 | check-complete exit 0 + git log 首锚 + 90/90 全绿 | Phase 1 | complete |
| G2 | 五门接线 | 规划/翻转/终验三时点自动拦截 | selftest-gate-injection.sh 全 PASS（≥5 门注入 exit≠0+干净 exit=0） | S1-S5 | complete |
| G3 | 内容核对层 | 声明串↔证据内容不符可检出 | 内容不符夹具 exit≠0 + 存量误报率入 findings | S6-S7 | complete |
| G4 | 审查门条款 | 84.7 内容审查门制度化 | grep 锚 ≥1×2 载体 + selftest 静态锚 PASS | S8 | complete |
| G5 | 零回归收尾 | 全量回归+终验+交付 | run-selftests --fresh FAIL=0 + registry rows=actual | S9-S10 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 门链脚本 | skills/task-planner/scripts/{attest-plan.sh, check-complete.sh, check-3file-gate.sh} | 其他 check-*/门链脚本 |
| 判定器（只读消费+档位键） | skills/task-planner/scripts/{check-vc-nonvacuous.sh, check-step-placeholders.sh, check-goal-cjk.sh, check-rvc-coverage.sh, check-tier-consistency.sh, check-evidence-anchor.sh}（后 6 者仅当接线需要输出/接口微调时改，逐项登记 CA 表） | 判定器判定逻辑重构 |
| selftest | skills/task-planner/scripts/{selftest-gate-injection.sh(新), selftest-evidence-anchor.sh, selftest-registry.tsv} | 其他既有 selftest（键数断言级联所需的最小同步除外，逐处登记） |
| 配置 | skills/task-planner/config.json（仅档位键新增/调整） | 其他配置 |
| 规则文档 | skills/verification-gate/{SKILL.md, references/critical-rules-verification.md}（84.7 子条+消费面引用） | 其他卫星/核心 critical-rules（纪元锚级联所需最小同步除外，逐处登记） |
| 计划簿记 | plans/task-v184-proactive-error-review/**, plans/task-v183-verif-closeout/**（收口簿记+归档）, plans/INDEX.md（归档刷新） | 其他 plans/* |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户（问询按 Rule 70 四要素）

## 📋 变更标注表（Rule 74.3 — 修订方案必填，无表=无效方案）

<!--
  WHAT: Rule 74.3 变更标注表 — 任何对既有文件/条目的变更，制定方案时逐条登记（编号/对象+锚点/类型/吸收判定/依据/执行动作）。
  WHY: 落实 74.2 三判门（增量默认·替代四条件·删除授权）留痕；无表=无效方案禁入执行（74.3b），表兼验收清单（74.3c）。
  WHEN: 制定修订方案时填写；用户新指令到达时先逐条转标注行再动任何文件（先标注后执行，74.3d）。
-->

任何对既有文件/条目的变更，制定方案时在此逐条登记；本表兼任验收清单（执行后逐行勾核，新增而产物缺失/增量而旧内容被改=FAIL）。用户新指令到达时先转标注行再动任何文件——先标注后执行。

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 依据（用户原话或证据） | 执行动作 |
|------|------------------|---------------------------|-----------|------------------------|---------|
| CA-1 | skills/task-planner/scripts/attest-plan.sh（VC 门/锁定门段） | 修改 | 增量 | report §5 P-02/03/08/09 落地方式列 | S1/S3/S2/S4 接线四判定器 shell-out（warn 起步档位键） |
| CA-2 | skills/task-planner/scripts/check-complete.sh（VC-GATE 段） | 修改 | 增量 | report §5 P-02/P-08 落地方式列 | S1/S2 接线 vc-nonvacuous + rvc-coverage |
| CA-3 | skills/task-planner/scripts/check-3file-gate.sh（条件链） | 修改 | 增量 | report §5 P-06「接线第 6 条件消费面」 | S5 接线 goal-cjk（阈值经语料校准） |
| CA-4 | skills/task-planner/scripts/check-evidence-anchor.sh（内容核对层） | 修改 | 增量 | R3 核心+report §7.3 语义级缺口收窄第一层 | S6 新增声明串↔证据文件内容核对（Total/exit=/PASS=/FAIL= 形态，warn 起步） |
| CA-5 | skills/verification-gate/references/critical-rules-verification.md（Rule 84 段尾） | 修改 | 增量 | R3 核心；§四.6 文本条款优先 | S8 新增 84.7 内容审查门子条 |
| CA-6 | skills/verification-gate/SKILL.md（终验 SOP 段） | 修改 | 增量 | 84.7 消费面引用 | S8 增引用行 |
| CA-7 | skills/task-planner/scripts/selftest-gate-injection.sh | 新增 | 增量 | report §5.1 修订 3 注入式验收标准 | S1-S5 验收载体：每门注入夹具→真实链 exit≠0 断言 |
| CA-8 | skills/task-planner/scripts/selftest-evidence-anchor.sh | 修改 | 增量 | CA-4 行为断言 | S7 扩内容核对断言 |
| CA-9 | skills/task-planner/config.json | 修改 | 增量 | 档位键 | 结构类（vc_nonvacuous/step_placeholder/rvc_coverage/tier_consistency）=enforce；阈值类（goal_cjk/claim_match）=warn；键数断言级联逐处同步 |
| CA-10 | skills/task-planner/scripts/selftest-registry.tsv | 修改 | 增量 | registry 双向一致 | +1 行（selftest-gate-injection） |
| CA-11 | plans/task-v183-verif-closeout/{task_plan.md(Next Step/Current Phase 簿记), 全套}（归档移动） | 更新 | 增量 | Rule 81/90 | Phase 1 check-complete→簿记修正→archive→git 提交 |
| CA-12 | plans/INDEX.md | 修改 | 增量 | Rule 81.4 | 归档后索引刷新 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | 验证机制升级审计报告（提案 P-01..P-10+终审修订 10 条+§7.3 缺口） | plans/verification-upgrade-2026-10-16/report.md（§5/§5.1/§7） | 必读 | ☑ |
| 项目内部文档/知识库 | v183 交付总结（7 判定器落地态+5 风险） | plans/task-v183-verif-closeout/delivery-summary.md | 必读 | ☑ |
| 项目内部文档/知识库 | 接线范式先例（shell-out 前置块+fail-open+档位键） | skills/task-planner/scripts/check-complete.sh:431（DELEGATION shell-out）+ check-evidence-anchor 接线段 | 必读 | ☑ |
| 项目内部文档/知识库 | Rule 84 现行全文（84.7 子条落点） | skills/verification-gate/references/critical-rules-verification.md | 必读 | ☐ |
| 官方文档 | bash/awk/grep 行为（tr 尾连字符/locale 判例已内化） | 本仓实证（findings P-05/P-06 判例） | 参考 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 判定器已存在但不被自动调用（主动发现缺失），且内容级错误零机器检查（内容审查缺失）——两个缺口使技能止于「记录/收集」而达不到用户要的「主动发现+内容审查」。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（三时点自动拦截+内容核对层+84.7 条款=可观察的发现能力提升）
- [x] 核心问题不解决，其他工作都白费吗？（不接线=复刻 P-05 诊断的「检测器发货即死」失效模式）
- [x] 核心问题的解决方法是清晰的、可执行的？（接线点=report §5 各提案「落地方式」列原文；内容层=CA-4/S8）

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| S1-S5 五门接线 | LOCAL-ONLY | - | -（仓内范式：check-complete.sh:431 shell-out 先例） | 代码接线+注入夹具 | 不适用 |
| S6 内容核对层 | LOCAL-ONLY | - | -（仓内范式：check-evidence-anchor.sh PATH_TOKEN_RULES 词表调优判例） | 核对层+误报基线 | 不适用 |
| S7 selftest 扩展 | LOCAL-ONLY | - | - | 断言+registry | 不适用 |
| S8 84.7 条款 | LOCAL-ONLY | - | -（Rule 84 现行文+卫星条款范式） | 规则文本+静态锚 | 不适用 |

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
n/a（纯执行类——「审查」产出的结论已由 plans/verification-upgrade-2026-10-16/report.md 承载（三类漏检经独立复核 confirmed=true），本任务为该结论的实施批次，不新增归因结论）

| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 本仓 146 存量计划（误报基线） | 各判定器全量扫描 | findings.md Research Findings | ☐ |
| ② 对标样本（58.2 强制） | n/a（纯执行类豁免——实施任务无对标归因面） | - | - | ☐ |
| ③ 外部约束 | n/a（纯执行类豁免） | - | - | ☐ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
Phase 4

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
并行派 Code Reviewer（全任务 diff 审查→APPROVED 留痕）+ Verifier（全量 --fresh 回归+VC-1..5 独立复验+84.7 对齐审查+注入夹具复跑=S9/S10 合并承载）→ Phase 5 交付（delivery-summary+尾锚提交+核心目标裁决）。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理（Verifier 复核 v183 收口）+ 机械守卫脚本（check-complete/archive/attest）+ git 编排（主进程白名单②） | 收口动作=既定 SOP 机械步骤+git 编排 |
| Phase 2 | Agent 子代理 code-assistant(haiku-1)×5 并行组（S1-S5 文件集互斥：attest×4 注意——S1/S3/S2/S4 同改 attest-plan.sh **非互斥→串行**；S5 独立可并行）+ 机械守卫脚本 | 单文件小改走 code-assistant；同文件依赖强制串行（Rule 21.4 独立性四问） |
| Phase 3 | Agent 子代理 code-assistant(haiku-1)（S6-S8 串行：S7 依赖 S6 接口、S8 独立可并行）+ 卫星技能 alignment-review（S8 收尾） | 同上+S8 文档对齐收尾 |
| Phase 4 | Agent 子代理 code-runner-agent（全量回归）+ Verifier（独立复验）+ code-review skill（CR Gate） | Rule 33.3 验证独立性 |
| Phase 5 | 主进程（git 编排+簿记——Rule 25.3 白名单） | 交付收尾 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（S-unit 总量 8、同文件依赖多、串行为主）→ 按 Rule 21.4 独立性守门调度（S5 可与 S1 串行链并行；未声明组默认串行）
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；用户未用 /goal 锚定，无映射登记

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: v183 收口与基线
<!-- 
  WHAT: 先把未提交基座落库（Rule 90 首锚），取得干净回归基线，再在其上开工。
  WHY: 52 个未提交文件含本任务全部接线对象；不先收口=新改动与 v183 在途改动混叠不可回退。
-->
- [x] check-complete 收口 v183（簿记修正 Next Step/Current Phase 陈旧指针）
- [x] archive-plan.sh 归档 v183 + INDEX 刷新（**Rule 81.3 合规拒绝路径**：live-owner 守卫拒绝→保持原位+理由登记，重试窗口 2026-10-18 01:46 后；INDEX 无 v183 活跃行无需刷新）
- [x] Rule 90 首锚 git 提交（b83ad92，67 文件逐目录 add 禁 -A 含 plans/task-v183-verif-closeout/ 全套；簿记补录四笔：88284d7 等）
- [x] 全量回归基线取证（Total: 90 PASS=90 FAIL=0）
- **V-N:** VC-1, VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 计划系统文件维护——Rule 25.3 白名单；收口后 Verifier 子代理复核于 Phase 4 S10 统一执行）
<!-- 
  STATUS VALUES:
  - pending: Not started yet
  - in_progress: Currently working on this
  - complete: Finished this phase
-->

### Phase 2: 接线批次（主动发现——R1/R2）
<!-- 
  WHAT: 5 判定器接进三时点自动门链，每门带注入式行为验收。
  WHY: report §5.1 修订 3：只交付脚本+registry+selftest=「检测器发货即死」；验收必须是注入缺陷计划→真实链 exit 1。
-->
- [x] S1-S5 按 S-unit 表派发落地（实际执行链：S1 三投 general-purpose 成/S2/S2b 清理/S3+S4 合并/S5——见 Handoff rescue 记录）
- [x] selftest-gate-injection.sh 汇聚各门注入断言（CA-7，11 断言全 PASS + registry 91 行）
- [x] 档位分档落地（[align] 修订：结构类 enforce/阈值类 warn；P-06 经 148 语料 0 误报数据翻 enforce）+ 键批前置 48→53 一轮级联
- **V-N:** VC-2, VC-5
- **Status:** complete
- **Executor:** code-assistant（haiku-1）→实际主体 general-purpose（rescue 记录：code-assistant 两投停摆，Rule 22.3.1 改派；Handoff 表 #2/#5/#6）

<!-- S-unit 派发单元表(Rule 22.6 — Executor≠主进程的 Phase 计划期必填;每行 = 一次 Agent() 派发;单步 ≤step_max_files(2) 文件 / ≤step_max_lines(100) 行 / ≤step_max_minutes(15) 分钟,超限再拆而非升档;「执行体」列可写"继承"或具体 subagent_type(model);「输入」列在计划期预写材料包 = 路径 + ≤10 行摘要,执行期照单派发)
  机器契约(check-plan-dispatch.sh attest 校验):
  ① 预估时长列一律写 NNmin 格式(先估出可测的时长),逐行数值校验——超限= enforce 档硬阻断拒锁回炉重拆（Rule 59.1，2026-10-08 由 SKIPPED 提示升级）
  ② 输入列文件路径 token 计数 ≤2,超限= enforce 档硬阻断拒锁回炉重拆（Rule 59.1，2026-10-08 由 SKIPPED 提示升级）
  ③ 拆分决策基准 = 预估时间(用户裁决 09-17):写表时先给每行可测的 NNmin 预估,模型据此决定拆不拆,机侧校验行供 review 对照
  ④ ID 列一律纯数字（S1/S2…），禁字母后缀——check-plan-dispatch.sh 数据行正则不认 S2a 式命名，attest 拒锁（task-v076 教训）
  - 粒度三值列 Nf/Nl/Nmin 格式逐行校验,任一超 step_max_files/step_max_lines/step_max_minutes → enforce 拒锁
  - 伴飞技能列非「无」→ 校验对应 SKILL.md 路径存在(Rule 59.2)
  - Rule 68.1 前置依赖列必填,无依赖填 -（多依赖顿号分隔）
-->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | P-02 接线：check-vc-nonvacuous 入 attest VC 门+check-complete VC-GATE | 继承 | skills/task-planner/scripts/attest-plan.sh（VC 门段；消费 check-vc-nonvacuous.sh shell-out+warn 档位键；DELEGATION shell-out 范式派发 prompt 内联） | 真空 VC 夹具 attest exit≠0+留痕；干净夹具 exit=0 | 14min | 2f/80l/14min | 无 | - | pending |
| S2 | P-08 接线：check-rvc-coverage 入 attest VC 链+check-complete VC-GATE | 继承 | skills/task-planner/scripts/attest-plan.sh（同 S1 段追加 rvc-coverage shell-out；缺 R→VC 映射拒锁） | 缺映射夹具 exit≠0；v183 真阳性判例复核 | 10min | 1f/40l/10min | 无 | S1 | pending |
| S3 | P-03 接线：check-step-placeholders 入 attest 锁定门（硬占位 enforce/软模糊 warn 分档） | 继承 | skills/task-planner/scripts/attest-plan.sh（锁定门段消费 check-step-placeholders.sh） | 占位步骤夹具拒锁 exit≠0；模糊词 warn 留痕 | 10min | 1f/40l/10min | 无 | S2 | pending |
| S4 | P-09 接线：check-tier-consistency 入 attest 档位复核 | 继承 | skills/task-planner/scripts/attest-plan.sh（档位段消费 check-tier-consistency.sh；plan_tier 声明行格式规范化） | 档位漂移夹具 exit≠0；自声明 mini 复核 | 10min | 1f/40l/10min | 无 | S3 | pending |
| S5 | P-06 接线：check-goal-cjk 入 check-3file-gate 第 6 条件+语料校准 | 继承 | skills/task-planner/scripts/check-3file-gate.sh（条件链尾追加 goal-cjk 消费；阈值经 plans/archive ≥30 中文 Goal 语料校准后固化） | 纯中文 Goal 跑题夹具翻转被拦；活计划零误报 | 14min | 2f/90l/14min | 无 | - | pending |

### Phase 3: 内容错误审查层（核心——R3）
<!-- 
  WHAT: 内容级核对机器层（S6/S7）+ 内容审查门规则条款（S8）。
  WHY: report §7.3 high——语义级零机器检查是用户明示的最核心缺口；机器层收窄可判面，规则层兜语义面。
-->
- [x] S6-S8 按 S-unit 表派发（S6→S7 串行；S8 提前并行完成；执行体=general-purpose，rescue 判例同 S1）
- [x] 存量误报基线扫描（60 计划抽样：2 计划 5 旗标=1 真阳性+4 边界阳性，量化入 findings）→ CLAIM_MATCH 保持 warn（升 enforce 待用户裁决边界模式）
- [x] alignment-review 对 84.7 条款跑对齐审查（**并入 Phase 4 S10 Verifier 复验面**——[align] 排程合并，独立性不受损）
- **V-N:** VC-3, VC-4, VC-5
- **Status:** complete
- **Executor:** code-assistant（haiku-1）→实际 general-purpose（Handoff rescue 记录）

<!-- S-unit 派发单元表（Rule 22.6 — 机器契约同 Phase 2 注释：NNmin/路径 token ≤2/纯数字 ID/粒度三值/伴飞存在性/前置依赖必填） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S6 | 内容核对层：check-evidence-anchor 增声明串↔证据文件内容核对 | 继承 | skills/task-planner/scripts/check-evidence-anchor.sh（PATH_TOKEN_RULES 词表后追加 CLAIM_MATCH 层：Total/exit=/PASS=/FAIL= 形态声明串 grep 证据文件） | 内容不符夹具 exit≠0；相符夹具 exit=0；146 存量误报率量化 | 15min | 1f/100l/15min | 无 | - | pending |
| S7 | 内容核对层 selftest：selftest-evidence-anchor 扩内容断言+registry 登记 | 继承 | skills/task-planner/scripts/selftest-evidence-anchor.sh（EA 断言族后追加 CLAIM-01..N：内容不符/相符/无声明串三态夹具） | selftest 新断言全 PASS；registry rows=actual | 12min | 2f/60l/12min | 无 | S6 | pending |
| S8 | Rule 84.7 内容审查门条款落 verification-gate+SKILL 消费面+静态锚 | 继承 | skills/verification-gate/references/critical-rules-verification.md（Rule 84 段尾增 84.7 子条：内容型交付物终验前独立内容审查子代理+结论落盘；SKILL.md 终验 SOP 段增引用行） | grep 84.7 两载体 ≥1；静态锚 selftest PASS；alignment-review APPROVED | 14min | 2f/80l/14min | 无 | - | pending |

### Phase 4: Testing & Verification
<!-- 
  WHAT: Verify everything works and meets requirements.
  WHY: Catching issues early saves time. Document test results in progress.md.
-->
- [ ] 全量回归 run-selftests.sh --fresh（FAIL=0）
- [ ] Code Review Gate（code_review: required → APPROVED）
- [ ] Verifier 独立复验 VC-1..5（含注入夹具复核）
- [ ] Fix any issues found
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5
- **Status:** pending
- **Executor:** 混合（S9 code-runner-agent / S10 Verifier；CR Gate=主进程 Skill 调用）

<!-- S-unit 派发单元表（Rule 22.6 — 机器契约同 Phase 2 注释） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S9 | 全量回归+registry 双向一致校验 | code-runner-agent(mini) | skills/task-planner/scripts/run-selftests.sh（--fresh 全量跑批；registry rows=actual 对照） | FAIL=0 且 Total ≥ 90；registry 校验 PASS | 12min | 1f/5l/12min | 无 | S1-S8 | pending |
| S10 | VC-1..5 独立复验（含注入夹具复核） | Verifier(mini) | plans/task-v184-proactive-error-review/verification.md（逐 VC 复验：重跑 Verify command+证据核对） | 复验结论全 PASS 入 findings；不符项开 fix 回路 | 14min | 1f/20l/14min | 无 | S9 | pending |

### Phase 5: Delivery
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [ ] Review all output files
- [ ] Rule 90 尾锚 git 提交（本任务产物）
- [ ] delivery-summary 五要素输出；部署位同步呈报用户裁决（默认不部署）
- **V-N:** VC-1, VC-5
- **Status:** pending
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
| `conflict_scan` | `risk`（信号①52 未提交文件与任务范围重叠；信号⑤47 个运行中基础设施；信号③遗留 wt/task-v168-machine-parked（登记不动）） |
| `isolation` | `direct`（例外登记：接线对象=19 个未跟踪新脚本+5 个未提交修改门链——worktree from HEAD 缺这些文件，接线对象不存在；Phase 1 首动作即 Rule 90 提交收口化解未提交态。同判例：v183 isolation=direct 已呈报用户未否决） |
| `worktree_path` | n/a |
| `branch` | n/a |
| `merge_back` | n/a |

> 契约详见 `${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/methodology.md §R2）

<!--
  WHAT: 对每个 Phase 枚举失败模式，打 S(严重度)/O(频度)/D(探测难度) 各 1-10 分，RPN=S×O×D。
  WHY: RPN>100 的高风险 Phase 必须预先登记兜底动作（对齐 Rule 22.3 五档兜底链，task-v113 后含 22.3.0 资料先行档），避免执行期临时决策。
  WHEN: 计划创建时填写（高 RPN 项）；纯文档/调研类小任务可写 n/a。
  开关键: config.json#fmea_enforce（默认 warn；enforce 档下 RPN>100 无兜底登记 = 计划无效）。
-->

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | git 提交范围误扫（git add -A 判例）或收口门 FAIL 阻断 | 6 | 4 | 3 | 72 | — |
| Phase 2 | 接线破坏既有门链/键数断言级联（先例：46→47 时 18 处断言炸，3 处非标准形态靠全量回归才暴露） | 7 | 6 | 4 | 168 | ②拆细：每个 S-unit 独立提交+--only 单项回归+全量 --fresh 三段验收，失败即回退该接线（git checkout 单文件级） |
| Phase 2 | 5 门同时 enforce 撞存量误报（先例：P-04 enforce 撞 73/145） | 7 | 5 | 4 | 140 | 分档（[align] 修订）：结构类 enforce 仅作用于 attest 锁定期/终验期新计划与活跃计划（archive 不受门控+v184 自身达标）；阈值类（P-06）warn 起步+语料校准先行；注入夹具若在存量撞误报→该门降 warn 并登记 |
| Phase 3 | 内容核对层误报失控（先例：P-01 词表初版 63/90 命中，8 轮调优至 1/56） | 6 | 7 | 5 | 210 | ②拆细+降档：CLAIM_MATCH 层独立开关 warn 起步，先跑 146 基线量化误报，>5% 即收窄声明串形态集 |
| Phase 4 | CR/Verifier 发现接线缺陷返工 | 5 | 4 | 3 | 60 | — |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 ①-⑤哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | S1 待跑 sync-todos.sh --json |
| Phase 2 | ☐ |  | |
| Phase 3 | ☐ |  | |
| Phase 4 | ☐ |  | |
| Phase 5 | ☐ |  | |

> 契约详见 `${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing files? (JSON)
-->
1. 内容核对层声明串提取范围：Total/exit=/PASS=/FAIL= 四形态起步是否覆盖绝大多数终验证据？（Phase 3 由 146 存量语料实测决定，误报>5% 收窄）
2. Rule 84.7「内容型交付物」触发面怎么划？（默认=VC 证据含非脚本产出物[文档/报告/数据]的计划；执行期由 S8 起草+alignment-review 校订）
3. P-06 校准阈值在 ≥30 中文 Goal 语料上的误报率？（S5 实测固化，数据入 findings）

## Decisions Made
<!-- 
  WHAT: Technical and design decisions you've made, with the reasoning.
  WHY: You'll forget why you made choices. This table helps you remember and justify them.
  WHEN: Update whenever you make a significant choice (technology, approach, structure).
  EXAMPLE:
    | Use JSON for storage | Simple, human-readable, built-in Python |
-->
| Decision | Rationale |
|----------|-----------|
| 判定 D 类新任务（非 B 扩展） | v183 四 Phase 全 complete+delivery-summary 已交付其 Goal；接线/语义层被其显式登记为「后续批次」——新计划消费前序产物，旧计划原样收口归档（Rule 8.1） |
| isolation=direct（不 worktree） | 接线对象=19 个未跟踪新脚本+5 个未提交门链改动——worktree from HEAD 缺这些文件；Phase 1 首动作提交收口化解。同 v183 判例（已呈报未否决） |
| 不新增 Rule 编号，84.7 子条承载 | 1-91→1-92 纪元锚级联会炸 ~23 个脚本断言（execution-lane 记忆判例：每纪元必炸）；84.7 落管辖域 verification-gate，语义上本就是 Rule 84 验证域延伸 |
| 档位分两档起步（[align] 2026-10-17 Phase 1 实证修订） | **结构类门 enforce 起步**（P-02/03/08/09 的 attest+check-complete 接线：判定面客观+v183 活计划 smoke 全绿+archive 不受门控+--skip 逃生阀在）；**阈值/内容类门 warn 起步**（P-06/CLAIM_MATCH：语料校准与 146 误报基线先行再翻）。原「全部门 warn」被 Phase 1 六轮拦截链证伪——warn 档门（Batch/judge/rcov）从未拦住 v183 的交付声称，R1 要的是拦截 |
| 机器层+规则层双轨收窄语义缺口 | 机器可判面（声明串↔内容核对）用脚本；纯语义面（内容相关性）机器不可靠——按 §四.6 文本优先落 84.7 规则条款（独立内容审查子代理门），不擅自扩机器基建 |
| 注入式验收为统一标准 | report §5.1 修订 3：验收=注入缺陷计划→真实 hook/终验链 exit 1，非仅脚本自带夹具——selftest-gate-injection.sh 汇聚承载 |
| 部署位同步不在本任务范围 | 需独立授权（v183 风险④同款）；Phase 5 呈报默认不部署 |
| P-05/P-07/P-04 不入本任务 | P-05 已修（v183）；P-07 可见化已落（check-gate-degraded.sh 在位），翻档凭降级率数据后置；P-04=warn 已裁决（v183 findings） |

## Errors Encountered
<!-- 
  WHAT: Every error you encounter, what attempt number it was, and how you resolved it.
  WHY: Logging errors prevents repeating the same mistakes. This is critical for learning.
  WHEN: Add immediately when an error occurs, even if you fix it quickly.
  EXAMPLE:
    | FileNotFoundError | 1 | Check if file exists, create empty list if not |
    | JSONDecodeError | 2 | Handle if file exists check for empty values |
-->
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| bun 不在 PATH（session-catchup.ts 跳过） | 1 | 以 git/文件现状替代中断恢复点检测（工作树即最新态） | → progress.md Error Log |

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
  WHEN: 每次派发 drift-checker 偏移检查（Rule 61 载体）后追加一行记录
  FORMAT: | timestamp | 结果 | VC条目 | 结论 |
-->
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-17 | ✅ALIGNED（subagent-state/drift-phase1.md） | VC-1 | v183 收口=服务 R1 基座前置；67 文件全属弧线；[align] 档位修订强化 VC-2 |
| 2026-10-17 | ✅ALIGNED（subagent-state/drift-phase2.md） | VC-2, VC-5 | 五门真接线实证；执行体改派/[align]×2 均登记；43 文件全 ∈ scope |
|------|---------|--------|------|
|      |             |        |      |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）
<!-- 
  WHEN: chain_mode: fan-out 或 批量操作 ≥5 单元时必填;纯单次任务可删除整个区块
  WHY: 批量操作禁止以牺牲质量/准确性为代价(Rule 18);前置 3 问 + 双采样抽检 + 失败率熔断的落盘证据
  校验: failure_rate >5% → Phase 禁止 complete;sampled_fail >0 → 整批未验证;pre_check 缺项 → plan-writer 校验失败
  完整模板: ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/batch_report.md | 规则详解: ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/batch-quality-gate.md
-->
| 字段 | 值 |
|------|-----|
| `total` | 8（S1-S8 派发单元） |
| `success` | （执行后填） |
| `failed` | （执行后填） |
| `failure_rate` | （>5% → STOP;>20% → 熔断回滚） |
| `sampled_pass` | （运行后抽 10%） |
| `sampled_fail` | （运行前抽 2,>0 → 整批熔断） |
| `pre_check` | Q1:否（非同质批量,8 单元分 3 类面）/Q2:有（每 S-unit 独立注入验收）/Q3:能（逐单元 --only 回归） |
| `rollback_point` | Phase 1 收口提交（git commit 首锚）——每 S-unit 独立提交可单文件级回退 |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 子代理占比需要可见反馈闭环;委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
  WHEN: 每个 Phase complete 后更新;终验交付前必须完整。
-->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  / 5（Phase 2/3=code-assistant，Phase 4=code-runner-agent+Verifier；终验时填实） |
| 主进程直做 Phase 清单 | Phase 1（例外理由:① git 编排+② 计划系统文件维护）、Phase 5（① git 编排+② 簿记）——Rule 25.3 白名单 |
| 委派率 | （终验时填实；预期 ≥0.6 含两白名单 Phase） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
<!--
  WHEN: 每次 Agent() 派发前填一行;子代理返回 30s 内主进程必须 Read 实际产出 + 紧邻 Edit findings.md 回填结论(「findings 落点」列记段落锚点),两动作完成才在「备注」列勾 verify_done;failed/timeout 行必须回填 checkpoint 路径列(Rule 22.8.4)
  WHY: 子代理规模限制 + 交接文件保障(Rule 22);findings 回填绑定(Rule 19.1/22.5)防止结论只留会话记忆
  状态枚举: queued/pending/running/done/partial/timeout/failed/blocked/scaling-redispatch(22.3.1 provider 失败改派)
  列说明: 备注列 = 低频列折叠单列(rescue 换档挽救记录 档位/结果/时间,failed|timeout 行必填,Rule 22.7;retry_count = 22.3 retry_limit 计数,初值 0,每次重试 +1;verify_done☐ = Read 产出 + findings 复核/回填双条件,Rule 22.5)——字段内容不删,仅列位折叠;verify_done 无机器消费(grep 实证 scripts/*.sh 除 selftest 零命中),为人工义务,不声称机器门
  派发 prompt 八字段模板: ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/subagent_dispatch.md
  # [2026-09-27 task-v091 B-2] 单写者澄清+Handoff 低频列折叠（verify_done 无机器消费如实披露）
-->

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-17 | drift-checker | Phase 1 完成后偏移检查（Rule 61/64 三态判定） | done | ✅ALIGNED；警觉 c1 计划旧措辞已修/c2 Todo 表已同步/c3 归档 10-18 重试窗 | subagent-state/drift-phase1.md | findings Research Findings | subagent-state/drift-phase1.md | - / 0 / ☑ |
| 2 | 2026-10-17 | general-purpose | S1 P-02 接线 attest VC 门+check-complete VC-GATE | done | 真实链拦截实证（夹具 A rc=1 含 ✗×5/B rc=0）；级联 16 处 48 | findings Research Findings（续） | subagent-state/S1-code-assistant.md | subagent-state/S1-code-assistant.md | rescue: code-assistant ×2 停摆→general-purpose 三投成 / 0 / ☑ |
| 3 | 2026-10-17 | code-assistant | S5 P-06 接线 3file-gate 第 6 条件+语料校准（排队：config.json 串行链 S1→S2→S3→S4→S5） | pending | | | | subagent-state/S5-code-assistant.md | - / 0 / ☐ |
| 4 | 2026-10-17 | code-assistant | S8 84.7 内容审查门条款两载体+VG-13 锚（编号撞车 84.7→84.7 裁决） | done | grep 84.7=7/1 两载体；VG-13 13/13 PASS | findings Research Findings（续） | subagent-state/S8-code-assistant.md | subagent-state/S8-code-assistant.md | 编号裁决 84.7→84.7 / 0 / ☑ |

## 🔗 Chain 区块交接配置（可选）

<!-- 仅多 skill 接力任务填写（如：调研→创作→发布）。单 skill 任务可删除此整个区块。 -->

### Chain 模式

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
| **current_block** | Block 1 |
| **handoff_on_complete** | ❌ 否 |

### Block 1: 本任务（单 block）

| 字段 | 值 |
|------|-----|
| **goal** | 见 Goal 段 |
| **depends_on** | none |
| **passes_to** | none（chain_mode: single） |
| **status** | in_progress |

<!-- 
### Block 2: [下游块名称]
## Goal
...
（single 模式无下游 block，本区块整体不适用）
-->

---

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP
- 处置预填: 不沉淀（技能自升级任务，无跨域复用画像；verify-closeout 型 variant 已有先例可对齐，若终验判定重复度高则维持 general）
