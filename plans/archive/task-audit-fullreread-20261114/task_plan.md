# Task Plan: 审核阶段修改后全文回读审查
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} token 由 init-session.sh render_template() 脚本渲染（task-id/任务名/日期/路径）；尖括号中文占位=模型填写面，脚本禁碰 -->
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  选定 variant 后 template_type 填所选类型名（白名单=/home/terry/.zcode/skills/task-planner/templates/variant/*-type.md 动态派生，见 check-template-type.sh）；general=通用回退（恒合法，Rule 34.1）
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

- **R1**: 「当前的Skill就是当前的Skill是否做到了比如说在修改完文件中重新读取完整文件，然后进行整体分析，做，有没有这一个步骤？因为只有在读取整个文件之后，才可以获取更加完整的就是上下文。来确保，嗯，修改，不会部分修改或者是修改位置错误导致」<sub>（[手段]——审计动作，已由 agent-quality-auditor 子代理完成并经主进程盘上复核）</sub>
- **R2**: 「如果没有的话，我希望可以修正。如果没有，如果有的话，分析是否合理。当然说最重要的是在审核阶段，我希望可以在审核阶段去做这部分内容，在单独的子代理中进行。」<sub>（[目标]——核心诉求：审核阶段+单独子代理+全文回读+整体分析绑定落地为技能条款；修正授权已获）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 | 审计报告在位且含 verdict+五要素判定表+≥6 条证据（checkpoints/audit-report.md 可 Read） |
| R2 | VC-2, VC-3, VC-4, VC-5, VC-6 | 语料中「审核阶段复检体全文回读+整体分析」绑定条款可 grep 命中于 103.3/103.5/3h/106.1b 四锚位；全量回归零新增 FAIL | |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/task-audit-fullreread-20261114/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/task-audit-fullreread-20261114/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| <工序 1> | <此工序削弱该结果的缺陷/缺口，无则"无"> | <修复 S-unit/Phase> | <VC-n> |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | <Goal/VC 表/用户需求原文 R 条目/风格与质量约束，逐条列> | <task_plan.md 对应章节锚> |
| 🔀 可变量 | <执行细节/工序排期/工具选型/S-unit 拆分> | - |
| 📈 学得量 | <执行期新事实/教训/锚点→findings.md/notepad-learnings.md；禁反向改写不变量> | findings.md |

## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and delete functionality."
-->
在 task-planner 技能体系将「审核阶段（独立复检）由全新子代理**重读被修改文件全文并做整体分析**」绑定落地为条款——修订 103.3/103.5（task-dispatch 卫星）+SKILL.md 3h 指针+106 家族 106.1b 分工指针，全量回归零新增 FAIL。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（规则文本修订非代码；语义审查由 103.3 独立复检 dogfood 承担） |
| `session_id` | `sess5f9294bcf1ee492583763fe2587964a4` | 启动时生成,注册表追踪 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-audit-fullreread-20261114` | §十一 隔离决策已有字段 |
| `scope_files` | `[skills/task-dispatch/references/critical-rules-dispatch.md, skills/task-discipline/references/critical-rules-discipline.md, skills/task-planner/SKILL.md, skills/task-planner/templates/subagent_dispatch.md, skills/task-planner/templates/task_plan.md, skills/verification-gate/references/critical-rules-verification.md, skills/task-planner/scripts/selftest-*.sh（仅断言适配时）]` | 从「执行范围限制」解析,并发检测基础（CA-5~7 级联面扩充已登记变更标注表） |
| `interaction_mode` | `ask` | Rule 28 交互模式：ask=关键决策点给选项；silent=静默+静默决策清单登记 |
| `对齐审查` | `[登记]` | Rule 42.6 消费：任务产出或更新的文档在完成前跑 alignment-review 对齐审查（标准收尾流程）;文档更新前跑版本一致性校验（未经校验不追加）;变更记录随交付物落盘;mini 档豁免（42.6.4） |
| `自动超时默认项` | `[询问点: 计划确认 → 默认=按已展示计划执行 / 5min]` | Rule 44 消费：本任务所有 2+ 选项询问点逐个登记默认选项（推荐项）与自动超时时长（默认 5 分钟,可覆盖）;低区分度选项（产出一致仅步骤/耗时差异）不询问、直接裁决并登记理由（44.2）;用户超时未答复按默认选项自动执行+登记自动裁决记录五要素（44.3）;mini 档豁免（44.4） |
| `new_rule` | 留空（修订既有 103/106，无新编号，不触发纪元级联） | Rule 20.6：本任务新增 Rule 编号时填写（attest 自动预留+查重；无则留空） |
| `质量审查工具` | `agent-quality-auditor（已用于审计）+ general-reviewer（P3 独立复检）` | Rule 42 消费登记（42.4）：任务涉及质量审查面时按 42.2 四级检测（含内置 review-library 兜底池）,填 技能名/既有 agent 名/待补充 S-unit 指针;缺口按 42.3 补建并登记 S-unit;执行期必须用登记工具;mini 档豁免（42.5） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

<!--
  WHAT: 任务执行完毕 ≠ 目标完成。此表确保每一步有可验证证据。
  RULE: 每个 phase 完成后对照 VC 编号复验；phase 全部 complete ≠ 通过终验。
  FORMAT: VC-N 是客观判定标准（可测试/可追溯/不依赖主观判断）。
  V-N: goal-gate.md 规定「≥5 条 VC + 每 phase ≥2 条 V-N（映射到 VC 编号）」；
       在每个 Phase 段（`### Phase N` 的 - **Status:** 行前）补 `- **V-N:**` 占位行，
       填写本 Phase 验收映射的 VC 编号（≥2 条，如 `VC-1, VC-2`；对应逐条验收记录在
       /home/terry/.zcode/skills/task-planner/templates/verification.md 的 `V-N.N` 项，映射目标须为已定义 VC 编号）。
       check-complete.sh 终验 VC-GATE 段机械校验（config.json vc_gate_enforce，默认 warn）。
-->

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 审计报告在位：verdict+五要素判定表+≥6 条证据+合理性分析 | 检查文件 | plans/task-audit-fullreread-20261114/checkpoints/audit-report.md（grep 'verdict'/'五要素' 均命中） |
| VC-2 | 103.3 含「复检体全文回读被改文件+整体分析」义务句 | 运行命令 | `grep -nE '全文回读' skills/task-dispatch/references/critical-rules-dispatch.md` → 103.3 段命中 |
| VC-3 | 103.5 复检任务书含第五要素（全文回读+读取证据） | 运行命令 | 同上 grep → 103.5 段命中 |
| VC-4 | SKILL.md 3h 指针含全文回读表述 | 运行命令 | `grep -nE '全文回读' skills/task-planner/SKILL.md` → 3h 行命中 |
| VC-5 | Rule 106 家族含 106.1b 审核阶段分工交叉引用 | 运行命令 | `grep -nE '106.1b' skills/task-discipline/references/critical-rules-discipline.md` → 命中 |
| VC-6 | 全量 selftest 零新增 FAIL（≤基线，基线=P1 记录值） | 运行命令 | 逐脚本跑 skills/task-planner/scripts/selftest-*.sh（worktree 内），FAIL 数 ≤ P1 基线并落 progress.md |
| VC-7 | 合并回后越界自检：主仓合并 commit 仅含 scope 文件 | 运行命令 | `git show --stat <merge-commit>` → 仅 scope 三文件+plans/ |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard/full 必填，mini 豁免）
<!-- task-dualqc-20261104 新增：双轮质检机制在计划阶段显式设计——派发型实质产出 S-unit 默认两道检核（第一轮执行体自审 103.2 checkpoint 自审段；第二轮主代理派全新子代理独立复检 103.3，档位升一档 103.4、复检任务书简洁四要素 103.5）；多文件变更集（≥2 受管文件）Phase 翻转前过 103.6 同步完整性审查（关联面推导四族→同步核对清单全绿）。豁免面=103.7，逐 S-unit 登记理由；mini 档整体豁免。 -->
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | Phase 3 全部 S-unit（语料条款修订=仓库受管实质产出） |
| 豁免登记 | P1 审计报告=调研产出非本仓受管文件（103.7 调研豁免）；P4 复检=第二轮本体；P2/P5=git 编排+簿记主进程白名单 |
| 多文件变更集预判 | P3 变更集=6 受管文件 ≥2 → Phase 翻转前过 103.6 同步核对清单（四族：同族字面面=「五要素」字面族全仓 grep；引用面=103.3a/103.5 互引+SKILL.md 3h；部署镜像位=~/.zcode/skills+~/.claude/skills 同路径族；断言面=selftest 文本锚 grep） |


## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
<!--
  WHEN: 终验时填写;含 [目标] 标注需求（下方 R 行）的任务必须在交付前出三态裁决
  WHY: Rule 58.5 完成裁决门——「分析报告已交付」不等于「问题解决了」;not-solved/partial 禁止标 COMPLETE
  载体: 58.4 手段/目标二分在需求原文区逐条标注 [手段]/[目标];本区块回收目标型需求的解决状态
-->
| 字段 | 值 |
|------|-----|
| **目标型需求** | （R 行编号，如 R1/R3） |
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
  列契约（66.1 六列）: goal-id(G1..) | 任务名(≤8字) | 目标(≤1句) | 完整验证方式(命令+判据/路径+关键行/diff形态,三选一必具其一) | 对应 S-unit/Phase | 状态(pending/complete)
  状态机: pending → complete(仅 66.3 三证据齐备后翻格,同步 progress.md [goal:Gn] 证据行)
-->
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 审计结论固化 | 判定五要素现状并落盘 findings | `grep -c '五要素' plans/task-audit-fullreread-20261114/checkpoints/audit-report.md` ≥1 且 findings.md §Research Findings 有审计段 | S1/Phase 1 | complete |
| G2 | 条款修订落地 | CA-1~CA-7 增量落地且段结构无损 | 四锚位 grep '全文回读'/'106.1b' 全命中+段清单守恒（V-3.1~V-3.4 PASS，commit 83b3388） | S1-S4/Phase 3 | complete |
| G3 | 回归零新增 FAIL | 全量 selftest 对照基线 | 回归 FAIL=105=基线（VC-6 PASS）+复检 APPROVED | S1-S2/Phase 4 | complete |
| G4 | 合并回+部署+归档 | 主仓 scope diff 仅预期+部署位同步 | merge 5d52eb4 越=6 scope 文件（VC-7 PASS）；部署 12/12 SAME+三仓 push ahead=0 | S1/Phase 5 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 语料（规则全文） | skills/task-dispatch/references/critical-rules-dispatch.md（仅 103.3/103.5 段内追加）、skills/task-discipline/references/critical-rules-discipline.md（仅新插 106.1b 行） | 其他规则文、既有段落文本改写/删除 |
| 技能定义 | skills/task-planner/SKILL.md（仅 3h 行追加）、skills/task-planner/templates/subagent_dispatch.md（仅 58 行⑤要素追加）、skills/task-planner/templates/task_plan.md（仅 113 行措辞）、skills/verification-gate/references/critical-rules-verification.md（仅 55 行措辞） | 其他行/frontmatter/其他卫星文件 |
| 守卫断言 | skills/task-planner/scripts/selftest-*.sh（仅断言面适配，锚断时才动） | 新增脚本/registry 改动 |
| 计划文档 | plans/task-audit-fullreread-20261114/** | 其他任务计划目录/其他项目 |

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

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 用户原话（逐字） | 依据（证据） | 执行动作 |
|------|------------------|---------------------------|-----------|----------------|------------------------|---------|
| CA-1 | skills/task-dispatch/references/critical-rules-dispatch.md:230（103.3 段尾） | 修改（段内追加义务句） | 增量 | 「如果没有的话，我希望可以修正。如果没有，如果有的话，分析是否合理。当然说最重要的是在审核阶段，我希望可以在审核阶段去做这部分内容，在单独的子代理中进行。」 | 审计 verdict B 五要素表（checkpoints/audit-report.md；引用已盘上复核） | 103.3 追加：复检体必须**分页读完被改文件全文**（非 diff/非片段）+整体分析四维（结构完整性/落点正确性/交叉引用一致性/语义连贯）+回执附读取证据，缺证据=复检无效 |
| CA-2 | skills/task-dispatch/references/critical-rules-dispatch.md:234（103.5 四要素） | 修改（四要素扩五要素） | 增量 | 同 CA-1 | 同 CA-1 | 追加⑤=全文回读要求：被改文件清单+分页读完义务+整体分析四维+回执附读取证据 |
| CA-3 | skills/task-planner/SKILL.md:104（3h 行） | 修改（行尾追加） | 增量 | 同 CA-1 | 同 CA-1 | 3h 句尾追加「复检体全文回读被改文件并整体分析（103.3 扩展条款，2026-11-14）」 |
| CA-4 | skills/task-discipline/references/critical-rules-discipline.md:725 之后（106.1a 与 106.2 之间） | 新增 | 增量 | 同 CA-1 | 同 CA-1 | 新插 106.1b 审核阶段全文回读分工指针：审核阶段语义整体面归 103.3 复检子代理；106.1/106.1a/106.3 管过程期即时拦截；互补不互代（对齐 84.x/106 分工声明范式） |
| CA-5 | skills/task-planner/templates/subagent_dispatch.md:58（复检任务书操作模板） | 修改（四要素扩五要素） | 增量 | 同 CA-1 | 级联面枚举 cascade-surface.md——复检任务书操作模板=CA-2 同族字面面+引用面双命中（103.6 关联面义务） | 追加⑤=全文回读要素（与 103.5 同步措辞）；不新增编号不改①-④原文 |
| CA-6 | skills/task-planner/templates/task_plan.md:113（双轮质检声明注释） | 修改（措辞同步） | 增量 | 同 CA-1 | 同上——「复检任务书简洁四要素 103.5」字面面 | 「四要素」→「五要素」字面同步 |
| CA-7 | skills/verification-gate/references/critical-rules-verification.md:55（衔接行） | 修改（措辞同步） | 增量 | 同 CA-1 | 同上 | 「103.5 复检任务书简洁四要素」→「103.5 复检任务书简洁五要素」字面同步 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | Rule 103 双轮质检全文（103.3/103.5 修订锚） | skills/task-dispatch/references/critical-rules-dispatch.md:224-236 | 必读 | ☑ |
| 项目内部文档/知识库 | Rule 106 家族全文（106.1b 插入锚） | skills/task-discipline/references/critical-rules-discipline.md:721-733 | 必读 | ☑ |
| 项目内部文档/知识库 | 3h/3i 接线（指针刷新锚） | skills/task-planner/SKILL.md:104-105 | 必读 | ☑ |
| 项目内部文档/知识库 | 审计报告（五要素表+合理性 5 条） | plans/task-audit-fullreread-20261114/checkpoints/audit-report.md | 必读 | ☑ |
| 项目内部文档/知识库 | worktree 合并回合约 | /home/terry/.zcode/skills/task-planner/references/worktree-isolation.md | 参考 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 审核阶段（独立复检）缺「重读被修改文件全文+整体分析」义务绑定——部分修改/改错位置/交叉引用破坏不被审核门拦截（审计 verdict B 证实）。
**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？→ 能：条款落地+回归绿即交付
- [x] 核心问题不解决，其他工作都白费吗？→ 是：无绑定条款则审核阶段仅局部对照，用户诉求落空
- [x] 核心问题的解决方法是清晰的、可执行的？→ 是：103.3/103.5 增量修订+106.1b 指针+3h 刷新（findings §Technical Decisions 已定案）

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| 全部 S-unit | LOCAL-ONLY（纯本地语料修订；审计已由子代理本地完成并复核，零外部事实依赖） | 全文回读、复检任务书、103.3、106.1a | 本地 grep/Read（网络链不适用） | findings 小节+语料条款 | 不适用 |

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | （自身内容/产品/数据） | | | ☐ |
| ② 对标样本（58.2 强制） | （竞品/同类成功案例/历史基线，≥1 个可指名） | | | ☐ |
| ③ 外部约束 | （平台规则/市场环境/算法机制） | | | ☐ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
终验完成（全 Phase complete，VC PASS=8 FAIL=0，outcome=COMPLETE 待归档）

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
无——已交付（COMPLETE）；残留仅归档动作（check-complete 后执行）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 agent-quality-auditor(sonnet-1)+机械守卫脚本（40.1③⑥） | 语料审计隔离主上下文（§一）；基线跑=机械脚本 |
| Phase 2 | 机械 git 命令（40.1⑥） | worktree 编排主进程白名单 |
| Phase 3 | Agent 子代理 general-coder(sonnet-1)（40.1③） | 语料条款修订实施（worktree 内），主进程不直写语料 |
| Phase 4 | Agent 子代理 general-reviewer(sonnet-1)+code-runner-agent(haiku-1)（40.1③） | 独立复检（103.3 dogfood）+回归机械执行 |
| Phase 5 | 机械守卫脚本 smart-merge-back/archive（40.1⑥） | git 编排+簿记主进程白名单（Rule 25.3 ⑥） |

**workflow 编排判定（Rule 40.4）**: [命中 39.8 激活条件（独立并行 ≥3 S-unit 可 fan-out / 长链编排型 / 用户点名）→ 登记『CreateWorkflow 路由（39.8 条件命中）』并执行期按 39.8 三件套主动创建；未命中 → Rule 21.4 独立性守门调度（并行默认+声明制）]
**/goal 对齐（Rule 40.3）**: [本计划 Goal+VC 即 session goal 的证据源;如用户已用 /goal 锚定本任务,在执行范围或 Goal 段注明映射;/goal 为用户侧 harness 命令,技能层不可代调]

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 审计与基线固结
<!-- 
  WHAT: Understand what needs to be done and gather initial information.
  WHY: Starting without understanding leads to wasted effort. This phase prevents that.
-->
- [x] 语料审计子代理（agent-quality-auditor）：五要素三态判定+证据表 → checkpoints/audit-report.md
- [x] 主进程盘上复核子代理 8 条引用行（§三禁信自报，全部一致）
- [x] findings.md 回填审计结论+技术决策（Rule 19.1 紧邻回填）
- [x] 主仓全量 selftest 基线跑通并记录（97 脚本，FAIL=105 → checkpoints/baseline-selftest.txt，作 VC-6 对照基线；基线跑=机械脚本执行，Rule 25.3 白名单）
- [x] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **V-N:** VC-1, VC-6（基线记录行）
- **Status:** complete
- **Executor:** agent-quality-auditor（sonnet-1）
<!-- 
  STATUS VALUES:
  - pending: Not started yet
  - in_progress: Currently working on this
  - complete: Finished this phase
-->

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A7) 语料审计：五要素三态判定+证据表落盘 | agent-quality-auditor(sonnet-1) | skills/**（全语料 grep 面） | 审计报告 verdict+五要素表+≥6 证据落 checkpoints | 15min | 0f/0l/15min | 无 | - | complete |

### Phase 2: worktree 创建与隔离基线
<!-- 
  WHAT: Decide how you'll approach the problem and what structure you'll use.
  WHY: Good planning prevents rework. Document decisions so you remember why you chose them.
-->
- [x] 主进程建 worktree：`git worktree add tmp/worktrees/task-audit-fullreread-20261114 -b wt/task-audit-fullreread-20261114 master`（§11.2 集中目录规约，631af7a）
- [x] worktree 内全量 selftest 基线跑通（与 P1 主仓基线对照一致=105/97）
- [x] 级联面全量枚举（Rule 105）：13 行/6 文件 → 传播面清单落 checkpoints/cascade-surface.md+CA-5~7 登记扩充
- [x] 变更标注表 CA-1~CA-7 材料包核对（锚行原文已验证在位；CA-5~7 随级联扩充补登）
- **V-N:** VC-6（基线双确认）, VC-2
- **Status:** complete
- **Executor:** 主进程（例外理由:⑥ git 编排+机械脚本——Rule 25.3 白名单）

### Phase 3: 条款修订实施（CA-1~CA-4，worktree 内）
<!-- 
  WHAT: Actually build/create/write the solution.
  WHY: This is where the work happens. Break into smaller sub-tasks if needed.
-->
- [x] 派 general-coder 按 S-unit 表逐单元实施（每 S-unit 返回→核 checkpoint 自审段 103.2→Read 产出 84.4→findings 回填 19.1；后两单元主进程接管=22.3 兜底链④档，例外登记 progress）
- [x] 每 S-unit Edit 后 106.1a 结构回读：段清单守恒（dispatch 15/SKILL 17/discipline 66 标题）+锚行原文保留 ✓（S1 `**` 吞字缺陷被 84.4 复核当轮修复）
- [x] 规范召回（Rule 93）：召回卡已 Read+progress 留 [recall] 行（执行后补做，欠账如实登记）
- **V-N:** VC-2, VC-3, VC-4, VC-5
- **Status:** complete
- **Executor:** general-coder（sonnet-1）

> 执行注记：后两单元由主进程接管（22.3 兜底链④档，dispatch-guard 同码拦 ×2，例外登记 progress——非白名单外理由，属兜底链合规范畴）。

<!-- S-unit 派发单元表(Rule 22.6 — Executor≠主进程的 Phase 计划期必填;每行 = 一次 Agent() 派发;单步 ≤step_max_files(2) 文件 / ≤step_max_lines(100) 行 / ≤step_max_minutes(15) 分钟,超限再拆而非升档;「执行体」列可写"继承"或具体 subagent_type(model);「输入」列在计划期预写材料包 = 路径 + ≤10 行摘要,执行期照单派发)
  机器契约(check-plan-dispatch.sh attest 校验):
  ① 预估时长列一律写 NNmin 格式(先估出可测的时长),逐行数值校验——超限= enforce 档硬阻断拒锁回炉重拆（Rule 59.1，2026-10-08 由 SKIPPED 提示升级）
  ② 输入列文件路径 token 计数 ≤2,超限= enforce 档硬阻断拒锁回炉重拆（Rule 59.1，2026-10-08 由 SKIPPED 提示升级）
  ③ 拆分决策基准 = 预估时间(用户裁决 09-17):写表时先给每行可测的 NNmin 预估,模型据此决定拆不拆,机侧校验行供 review 对照
  ④ ID 列一律纯数字（S1/S2…），禁字母后缀——check-plan-dispatch.sh 数据行正则不认 S2a 式命名，attest 拒锁（task-v076 教训）
  - 粒度三值列 Nf/Nl/Nmin 格式逐行校验,任一超 step_max_files/step_max_lines/step_max_minutes → enforce 拒锁
  - 伴飞技能列非「无」→ 校验对应 SKILL.md 路径存在(Rule 59.2)
  - Rule 68.1 前置依赖列必填,无依赖填 -（多依赖顿号分隔）
  - Rule 96.3 并行硬标注:前置依赖为 - 且独立性四问全 no 的 S-unit ≥2 个 → 必须声明并行组（frontmatter parallel_groups: 组名 + 行内注解 [parallel-group:<组名>];未声明且未按 Rule 68.2 登记全串行论证=计划缺陷,回炉补分析再 attest）
  - Rule 104.3 计划期标注：类别以目标列内（An）前缀标注（A1-A7 / 47.2 具名 / LOCAL 纯执行）——S-unit 表为 10 列固定列序（ID/目标/执行体/输入/验收/预估时长/粒度/伴飞/前置/状态，check-plan-dispatch.sh $4/$5/$7/$8 定位），禁增列、禁单元格管道转义
-->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6) CA-1/CA-2 落地（103.3 全文回读义务+103.5 第五要素追加） | 继承 | skills/task-dispatch/references/critical-rules-dispatch.md（103.3@230/103.5@234 段锚） | 两段追加后段清单守恒+锚行原文保留+grep '全文回读' 命中 | 10min | 1f/18l/10min | 无 | - | pending |
| S2 | (A6) CA-3/CA-4 落地（SKILL.md 3h 指针+106.1b 分工指针新插） | 继承 | skills/task-planner/SKILL.md（3h@104）、skills/task-discipline/references/critical-rules-discipline.md（106.1a@725 后） | 两处追加后段清单守恒+grep 命中 | 10min | 2f/6l/10min | 无 | S1 | pending |
| S3 | (A6) CA-5/CA-6 落地（subagent_dispatch 模板⑤要素+task_plan 模板措辞同步） | 继承 | skills/task-planner/templates/subagent_dispatch.md（58 行）、skills/task-planner/templates/task_plan.md（113 行） | 模板⑤要素与 103.5 措辞一致+措辞同步 | 10min | 2f/4l/10min | 无 | S2 | pending |
| S4 | (A6) CA-7 落地（verification-gate 衔接行措辞同步） | 继承 | skills/verification-gate/references/critical-rules-verification.md（55 行） | 「四要素」→「五要素」同步 | 5min | 1f/1l/5min | 无 | S3 | pending |

> Rule 96.3 全串行论证（Rule 68.2）：S2 前置依赖 S1（同变更集分步落地、共享锚面上下文），无独立并行单元，全计划 S-unit 串行推进。

### Phase 4: 独立复检与全量回归
<!-- 
  WHAT: Verify everything works and meets requirements.
  WHY: Catching issues early saves time. Document test results in progress.md.
-->
- [x] 派全新 general-reviewer 独立复检（103.3 dogfood+103.5 五要素任务书）：分页读完六个被改文件全文（变更集扩至 6 文件）+整体分析四维+对照变更标注表逐行勾核；任务书附执行体 checkpoint 自审段（103.2）→ APPROVED 7/7
- [x] selftest 断言面 grep（103.3/103.5/106 文本锚）→ 零锚断（P2 已核）零适配
- [x] 全量回归对照基线（VC-6）=105 PASS + 103.6 同步核对清单四族全绿（checkpoints/sync-checklist.md；回归跑=机械脚本执行，Rule 25.3 白名单，登记 progress）
- [x] Fix any issues found（无）
- **V-N:** VC-6, VC-2
- **Status:** complete
- **Executor:** general-reviewer（sonnet-1）

<!-- Executor≠主进程的 Phase 必附 S-unit 表（Rule 22.6；模板 CA-3 判例 task-tpl-verify-fix-20261113） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A7) 独立复检：全文回读三被改文件+整体分析四维+变更标注表勾核 | 继承 | 被改三文件绝对路径（任务书内联，主仓 plans/ 变更标注表） | 复检回执 APPROVED+读取范围证据落 checkpoint | 15min | 0f/0l/15min | 无 | P3-S2 | pending |
| S2 | (A7) selftest 断言适配+全量回归对照基线 | code-runner-agent（haiku-1） | worktree 根（skills/task-planner/scripts/selftest-*）+P1 基线记录行 | FAIL≤基线+适配 diff 仅断言面 | 15min | 2f/20l/15min | 无 | P3-S2 | pending |

### Phase 5: 合并回+部署+push+归档交付
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [x] 合并回五条件核（§11.3）→ stash 窗口法（他任务在途变更暂存回填）merge --no-ff → **merge_back=merged(5d52eb4)** → worktree remove+branch -d 完成（遗留 wt/task-v168-machine-parked=前存非本任务）
- [x] 部署位同步：zcode(~/.zcode)+claude(~/.claude) 双位×6 文件 cp+反向漂移核验（`<` 行零命中新关键词）+逐对 diff=12/12 SAME（checkpoints/deploy-diff.txt）
- [x] 三仓 push：源仓 11a4071→276fa50 / zcode ea70c3a→76ce690 / claude f5fbbda→75a0a05，ahead=0×3
- [x] Deliver to user（终验交付报告随本轮会话输出）
- [x] 全文档收尾回读梳理记录（Rule 84.14）：两轮迭代收敛（轮次 1 两发现已修复，轮次 2 零新发现→收敛出口达成，记录见「收尾回读梳理记录」区块）
- [x] 归档计划：check-complete exit 0 后 `set-active-plan.sh --clear` + `archive-plan.sh`（本行随归档执行勾核）
      <!-- task-kb-auto-capture-20261022 增：收尾主动触发——归档与知识提取为收尾默认动作，勿依赖人想起手动跑 -->
- [x] 知识提取入库（跳过：项目根无 scripts/kb-sync-from-plan.sh 知识库机制；知识沉淀已入 knowledge-brief.md §6+用户级记忆）
- **V-N:** VC-7, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
<!-- 每轮一行：轮次/发现/处置；连续一轮零新发现才可出 outcome（收敛出口，轮次不设上限）；
     发现面=需求↔目标↔执行↔验证↔知识五维互洽（偏移/遗漏/未利用知识） -->
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1 | ① VC-1 Verify command 大小写缺陷（报告用「Verdict」，`grep -q 'verdict'` 命中 0）② worktree cwd 漂移致 progress/sync-checklist 误写 worktree plans/ 副本 | ① verification.md 命令改 `grep -qi`（VC-1/V-1.1 双处）重验 PASS ② `git restore`+`clean -f` 恢复正本优先（progress P4 段） |
| 2 | 零新发现（五维互洽：需求 #1/#2↔Goal/R1R2↔CA-1~7 执行↔VC 全 PASS+复检 APPROVED↔知识 findings/kb 沉淀——五维逐维核对无偏移/遗漏/未利用） | 收敛出口达成（连续一轮零新发现）→ 出 outcome |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk(low)`——主仓存在他任务未提交变更（skills/plan-resume|todo-skill|workflow-model-tiers+plans/*），与本任务 scope 三文件**零重叠**（§11.3 条件③满足可继续）；worktree 内基线不受影响 |
| `isolation` | `worktree`（命中 §11.1 ①保护区+⑥运行中基础设施：skills/** 被所有会话实时加载） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-audit-fullreread-20261114` |
| `branch` | `wt/task-audit-fullreread-20261114` |
| `merge_back` | `merged(5d52eb4)`（stash 窗口法，他任务在途变更回填无损） |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 /home/terry/.zcode/skills/task-planner/references/methodology.md §R2）

<!--
  WHAT: 对每个 Phase 枚举失败模式，打 S(严重度)/O(频度)/D(探测难度) 各 1-10 分，RPN=S×O×D。
  WHY: RPN>100 的高风险 Phase 必须预先登记兜底动作（对齐 Rule 22.3 五档兜底链，task-v113 后含 22.3.0 资料先行档），避免执行期临时决策。
  WHEN: 计划创建时填写（高 RPN 项）；纯文档/调研类小任务可写 n/a。
  开关键: config.json#fmea_enforce（默认 warn；enforce 档下 RPN>100 无兜底登记 = 计划无效）。
-->

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 3 | Edit 吞锚/段结构受损（106.1a 判例族惯犯面） | 6 | 4 | 3 | 72 | 实施后强制 grep 段清单结构回读（106.1a）+P4 复检全文回读兜底 |
| Phase 5 | 合并冲突/部署位漂移（10 列判例族） | 7 | 3 | 4 | 84 | §11.3 五条件逐项核+部署位逐对 diff 判向；冲突 STOP 报告用户 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-11-14 | 原生 todo#1 已 complete；todo#2 审计子代理 complete |
| Phase 2 | ☑ | 2026-11-14 | 对应 todo#4/#5 |
| Phase 3 | ☑ | 2026-11-14 | 对应 todo#5 |
| Phase 4 | ☑ | 2026-11-14 | 对应 todo#6 |
| Phase 5 | ☑ | 2026-11-14 | 对应 todo#7 |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. 五要素现状如何？→ 已答：verdict B（部分满足），缺口=②③未绑定到④⑤载体（findings §Research Findings）
2. 绑定载体选哪条规则？→ 已答：修订 103.3/103.5+新增 106.1b+SKILL.md 3h 刷新，不新建 Rule 107（findings §Technical Decisions）

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
| 绑定载体=修订 103.3/103.5+新增 106.1b+3h 指针刷新；不新建 Rule 107 | 103.3 已具④⑤（审核阶段+全新子代理+只读），仅缺②③绑定；新编号触发纪元级联成本不成比例（YAGNI+Rule 38.7） |
| 全文回读形态=分页读完被改文件全文+整体分析四维+回执附读取证据 | 对齐用户②③诉求；读取证据使义务可核 |
| worktree 隔离+实施派 general-coder | §11.1 保护区强制；委派率门 0.7 |
| CA-5~CA-7 级联面扩充（P2 级联枚举发现，103.6 关联面义务） | subagent_dispatch.md:58=复检任务书操作模板（CA-2 同族面，漏改=模板与规则漂移）；task_plan.md:113+verification-gate:55=「四要素」措辞字面面——均增量字面同步，已登记变更标注表（Rule 74.3d 先标注后执行） |

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
  WHEN: 每次派发 drift-checker 偏移检查（Rule 61 载体）后追加一行记录
  FORMAT: | timestamp | 结果 | VC条目 | 结论 |
-->
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-11-14 | drift-checker P1（subagent-state/1-drift-checker.md） | VC-1, VC-6 | ALIGNED（3/3 PASS，confidence HIGH；零越界） |
| 2026-11-14 | drift-checker P2（subagent-state/2-drift-checker.md） | VC-6, VC-2 | ALIGNED（4/4 PASS，HIGH；worktree+基线双确认+零语料修改） |
| 2026-11-14 | drift-checker P3（subagent-state/4-drift-checker.md） | VC-2~5 | ALIGNED（3/3 PASS，HIGH；CA-1~7 全落地零越界+R2 语义承载对照） |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）
<!-- 
  WHEN: chain_mode: fan-out 或 批量操作 ≥5 单元时必填;纯单次任务可删除整个区块
  WHY: 批量操作禁止以牺牲质量/准确性为代价(Rule 18);前置 3 问 + 双采样抽检 + 失败率熔断的落盘证据
  校验: failure_rate >5% → Phase 禁止 complete;sampled_fail >0 → 整批未验证;pre_check 缺项 → plan-writer 校验失败
  完整模板: /home/terry/.zcode/skills/task-planner/templates/batch_report.md | 规则详解: /home/terry/.zcode/skills/task-planner/references/batch-quality-gate.md
  留空会被 check-complete 18.6 门拦（判例同上）
-->
| 字段 | 值 |
|------|-----|
| `total` | n/a（非批量任务或填写实际数量） |
| `success` | n/a（非批量任务或填写实际数量） |
| `failed` | n/a（非批量任务或填写实际数量） |
| `failure_rate` | n/a（非批量任务；批量时填实际比率，>5% → STOP;>20% → 熔断回滚） |
| `sampled_pass` | n/a（非批量任务；批量时填运行后抽 10% 结果） |
| `sampled_fail` | n/a（非批量任务；批量时填运行前抽 2 结果，>0 → 整批熔断） |
| `pre_check` | n/a（非批量任务；批量时填 Q1:否/Q2:有/Q3:能） |
| `rollback_point` | n/a（非批量任务；批量时填回滚点，为空 → 禁止批量） |

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
| 激活子代理数（Rule 96.5） | （Agent() 派发总次数） |
| 最大并行宽度（Rule 96.5） | （并行组数 / 最宽组宽,如 2 组 / 最宽 3） |
| 串行化例外理由（Rule 96.4） | （逐组一句话;无则写 none） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
<!--
  WHEN: 每次 Agent() 派发前填一行;子代理返回 30s 内主进程必须 Read 实际产出 + 紧邻 Edit findings.md 回填结论(「findings 落点」列记段落锚点),两动作完成才在「备注」列勾 verify_done;failed/timeout 行必须回填 checkpoint 路径列(Rule 22.8.4)
  WHY: 子代理规模限制 + 交接文件保障(Rule 22);findings 回填绑定(Rule 19.1/22.5)防止结论只留会话记忆
  状态枚举: queued/pending/running/done/partial/timeout/failed/blocked/scaling-redispatch(22.3.1 provider 失败改派)
  列说明: 备注列 = 低频列折叠单列(rescue 换档挽救记录 档位/结果/时间,failed|timeout 行必填,Rule 22.7;retry_count = 22.3 retry_limit 计数,初值 0,每次重试 +1;verify_done☐ = Read 产出 + findings 复核/回填双条件,Rule 22.5)——字段内容不删,仅列位折叠;verify_done 无机器消费(grep 实证 scripts/*.sh 除 selftest 零命中),为人工义务,不声称机器门
  派发 prompt 八字段模板: /home/terry/.zcode/skills/task-planner/templates/subagent_dispatch.md
  # [2026-09-27 task-v091 B-2] 单写者澄清+Handoff 低频列折叠（verify_done 无机器消费如实披露）
-->

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-11-14 | agent-quality-auditor | 语料审计：五要素三态判定+证据表 | done | verdict B（部分满足），缺口=②③未绑定④⑤ | checkpoints/audit-report.md:10-56 | §Research Findings 审计段 | checkpoints/audit-report.md | - / 0 / ☑ |
| 2 | 2026-11-14 | drift-checker | P1 偏移检查 | done | ALIGNED 3/3 PASS | subagent-state/1-drift-checker.md | §Research Findings（drift 不回填，三件套留痕） | subagent-state/1-drift-checker.md | - / 0 / ☑ |
| 3 | 2026-11-14 | drift-checker | P2 偏移检查 | done | ALIGNED 4/4 PASS | subagent-state/2-drift-checker.md | 同上 | subagent-state/2-drift-checker.md | - / 0 / ☑ |
| 4 | 2026-11-14 | general-coder | CA-1/CA-2 落地（103.3a+103.5⑤） | done | 5/5 PASS；`**` 缺陷经主进程 84.4 复核当轮修复 | dispatch.md:232/236 | §Research Findings S1/S2 回填段 | subagent-state/3-general-coder-s1.md | - / 0 / ☑ |
| 5 | 2026-11-14 | general-coder | CA-3/CA-4 落地（3h+106.1b） | done | 5/5 PASS，锚行保留+正字核验 | SKILL.md:104、discipline.md:727 | §Research Findings S1/S2 回填段 | subagent-state/3-general-coder-s2.md | - / 0 / ☑ |
| 6 | 2026-11-14 | drift-checker | P3 偏移检查 | done | ALIGNED 3/3 PASS（CA-1~7 零越界+R2 语义承载） | subagent-state/4-drift-checker.md | 同上 | subagent-state/4-drift-checker.md | - / 0 / ☑ |
| 7 | 2026-11-14 | general-reviewer | P4 独立复检（103.3a dogfood，六文件全文回读） | done | APPROVED 7/7+四维 PASS | subagent-state/5-general-reviewer-recheck.md:1-30 | progress P4 段 | subagent-state/5-general-reviewer-recheck.md | - / 0 / ☑ |

> S3/S4（模板级联 CA-5~7）=主进程接管（22.3 兜底链④档，dispatch-guard 同码拦 ×2），无派发行，例外登记 progress。

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
- **处置登记（2026-11-14）**: 不沉淀——单点条款修订（Rule 103/106 增量），无新任务类型模式可沉淀（Rule 34.3② 三条件不命中）
