# Task Plan: [Brief Description]
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  选定 variant 后 template_type 填所选类型名（白名单=${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/templates/variant/*-type.md 动态派生，见 check-template-type.sh）；general=通用回退（恒合法，Rule 34.1）
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

- **R1**: 「但是当前模型却恶意的在不知情的情况下，直接停止，直接暂停了任务，然后报备说需要消耗消耗多少额度」<sub>（[目标]）</sub>
- **R2**: 「就是因为在恶意的暂停，导致了当天的额度被在没有任何消耗的情况下被重置掉了，也就是说白白浪费掉了一天的视频额度」<sub>（[目标]）</sub>
- **R3**: 「视频额度是否有额度这种，直接发起任务。如果说任务失败的话，就是比如说视频生成失败的话，那么肯定就说明额度过去过期了。就是这种方案明明是可以从侧面测试检测出是否有额度的，但是却不做任何的测试，直接去停止」<sub>（[目标]）</sub>
- **R4**: 「不能说我每次提示一个任务，你就提示一种缺陷，然后你就弥补一个缺陷。我需要的是泛化行为，就是这种恶意的暂停的行为」<sub>（[目标]）</sub>
- **R5**: 「比如说在图片检测的时候，也完全就是明明可以通过质检提高或者说多做几次质检来分析出其中问题，然后非得将这种决策推给用户」<sub>（[目标]）</sub>
- **R6**: 「明明可以直接推进，不阻塞的情况下，不会给用户带来任何的损失的情况，却被恶意的停止了」<sub>（[目标]）</sub>
- **R7**: 「必须从根源上彻底解决这种问题。我需要的是可以让用户的利益最大化，而不是恶意的停止」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | Rule 95 定性条+视频执行体旧预询问措辞 grep=0 |
| R2 | VC-1 | 95.2 时间衰减资源保护条款在位（grep 锚） |
| R3 | VC-1, VC-2 | 95.1 执行即探测条款+视频执行体新措辞 grep≥1 |
| R4 | VC-1, VC-4 | 泛化规则全文落 discipline 卫星+纪元级联回归 ΣFAIL=0 |
| R5 | VC-3 | 图片执行体质检处置自主化条款 grep≥1 |
| R6 | VC-1 | 95.4 暂停前三问判定器条款在位 |
| R7 | VC-4, VC-5, VC-6 | 回归绿+部署位 diff=0+编号 land 登记 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/<task-id>/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/<task-id>/user-session-log.md`（模板 = ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 规则层 | 无"非必要暂停"泛化禁令；G 门语义被执行体放大为零证据预询问 | Rule 95 七子条落 task-discipline 卫星（Rule 82 分层先例=87-94） | VC-1 |
| 视频生成执行体 | 放行核验链含额度预报备/预询问停等语义（无 API 查询通道仍停等） | video-generation-executor.md 改"执行即探测" | VC-2 |
| 图片生成执行体 | 质检问题处置决策可被推给用户 | image-generation-executor.md 处置自主化条款 | VC-3 |
| 纪元锚/回归面 | 新增编号 95 未级联致 selftest 红面 | "1-94"纪元锚行级联 1-95（既有断言维护，非新增机器面） | VC-4 |
| 部署面 | 仅改源仓不生效（运行位仍旧措辞） | smart-merge-back --deploy 同步+diff=0 复核 | VC-5 |
| 编号治理 | 撞号/未登记竞态（v128 判例） | rule-reserve reserve→land 95 | VC-6 |

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
在 task-planner 技能族制度化泛化"执行优先/非必要暂停禁令"纪律（新增 Rule 95：执行即探测/时间衰减额度保护/质检自主化/暂停前三问），修正视频与图片生成执行体中的额度预询问与决策推诿条款，纪元级联回归绿并同步部署位，使该行为类禁令在新会话生效。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（宪法级行为规则文本，CR 用 general-reviewer 独立审查） |
| `session_id` | `session15576471f77c9ca8d81d0d10f9894fe4` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-nopause-execfirst-20261023` |
| `scope_files` | `skills/task-discipline/references/critical-rules-discipline.md; skills/task-discipline/SKILL.md（CA-10）; skills/task-discipline/references/execution-recall-card.md（CA-11）; skills/task-planner/SKILL.md; skills/task-planner/companion/agents/video-generation-executor.md; skills/task-planner/companion/agents/image-generation-executor.md; 文档纪元级联 22 行=README.md+docs/ARCHITECTURE.md+CLAUDE.md+README_zh.md+SKILL.md（CA-7/CA-8 冻结清单）; plans/task-nopause-execfirst-20261023/**; plans/INDEX.md` |
| `interaction_mode` | `ask`（自主会话下按 44.3 超时自动通过执行，见下方登记） |
| `对齐审查` | `[登记]` 收尾跑 alignment-review 对齐审查（标准收尾流程） |
| `自动超时默认项` | `[D1 计划确认: 默认=按本计划执行/超时立即]` **自动裁决记录五要素（Rule 44.3）**：①超时值=立即（自主 /goal 会话无实时等待对象，44.3 完成性指令前提命中）②推荐项=按本计划执行（规则文本+执行体修正+级联+部署）③触发时间=2026-10-23 计划展示时④裁决理由=用户指令为完成性指令（"必须得到修正/从根源彻底解决"）；且本任务目标即禁止不必要暂停，停下来等确认恰是投诉行为重演⑤被覆盖的未决选项=无真分叉（Rule 95 落 discipline 卫星+执行体修正为唯一合理路径；部署通道走 smart-merge-back --deploy 既有机制） |
| `new_rule` | `95` |
| `质量审查工具` | `general-reviewer`（既有 agent，CR Gate 用）+ `alignment-review`（既有 skill，收尾对齐） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

<!--
  WHAT: 任务执行完毕 ≠ 目标完成。此表确保每一步有可验证证据。
  RULE: 每个 phase 完成后对照 VC 编号复验；phase 全部 complete ≠ 通过终验。
  FORMAT: VC-N 是客观判定标准（可测试/可追溯/不依赖主观判断）。
  V-N: goal-gate.md 规定「≥5 条 VC + 每 phase ≥2 条 V-N（映射到 VC 编号）」；
       在每个 Phase 段（`### Phase N` 的 - **Status:** 行前）补 `- **V-N:**` 占位行，
       填写本 Phase 验收映射的 VC 编号（≥2 条，如 `VC-1, VC-2`；对应逐条验收记录在
       ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/templates/verification.md 的 `V-N.N` 项，映射目标须为已定义 VC 编号）。
       check-complete.sh 终验 VC-GATE 段机械校验（config.json vc_gate_enforce，默认 warn）。
-->

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 95「非必要暂停禁令与执行优先纪律」全文落入 skills/task-discipline/references/critical-rules-discipline.md，含 95.0 定性/95.1 执行即探测/95.2 时间衰减资源保护/95.3 质检自主化/95.4 暂停前三问/95.5 门关系/95.6 处置复盘 子条 | grep 锚断言（格式随 Phase 1 确认，锚 token 与文件无关） | `grep -c "Rule 95" <discipline 文件> ≥1 && grep -c "95\.1" ≥1 && grep -c "95\.2" ≥1 && grep -c "95\.4" ≥1`（命令落 verification.md V-N） |
| VC-2 | video-generation-executor.md 无"额度预询问/报备消耗后停等"类条款，含执行即探测语义 | grep 旧措辞=0+新措辞≥1 | `grep -cE "是否有额度|额度.*询问|询问.*额度" =0` 且新锚≥1（video-generation-executor.md） |
| VC-3 | image-generation-executor.md 含质检处置自主化条款（问题处置自主决策，禁推给用户） | grep 断言 | 新锚 grep≥1（image-generation-executor.md） |
| VC-4 | 纪元级联完成（1-94→1-95 口径），全量 selftest 回归 ΣFAIL=0 | 跑既有 selftest 套件 | 套件运行输出 ΣFAIL=0（progress.md 留轮次记录，Rule 57） |
| VC-5 | 部署位（zcode/cursor 等 --deploy 登记位）与源仓 diff=0 | smart-merge-back --deploy 后 diff 复核 | diff 输出为空（progress 留痕） |
| VC-6 | rule-reserve 编号账本 land 95 登记 | 读账本 | `grep '"rule":95' plans/.rule-reservations.jsonl` 含 landed |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

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
  列契约（66.1 六列）: goal-id(G1..) | 任务名(≤8字) | 目标(≤1句) | 完整验证方式(命令+判据/路径+关键行/diff形态,三选一必具其一) | 对应S-unit/Phase | 状态(pending/complete)
  状态机: pending → complete(仅 66.3 三证据齐备后翻格,同步 progress.md [goal:Gn] 证据行)
-->
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 发现与映射 | 承载体/锚面/部署位全部映射成冻结清单 | findings.md 载体表≥5 行且每行含路径+行号锚 | S1/Phase 1 | pending |
| G2 | Rule 95 定稿 | 七子条文本定稿并落 discipline 卫星 | discipline 文件 grep "Rule 95"≥1 且 95.1/95.2/95.4 锚在位 | Phase 2 | pending |
| G3 | 执行体修正 | 视频/图片执行体条款按精确 diff 改写 | 两文件旧措辞 grep=0 且新锚≥1 | S1-S2/Phase 3 | pending |
| G4 | 纪元级联 | selftest 纪元锚 1-95 口径一致 | 冻结清单行改后旧锚残留=0 | S3/Phase 3 | pending |
| G5 | 回归与 CR | 全量 selftest ΣFAIL=0+CR APPROVED | 套件输出+CR 记录落 progress | Phase 4 | pending |
| G6 | 合并部署 | master 合并+部署位 diff=0+账本 land | merge commit+diff 空+jsonl landed 行 | Phase 5 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则文本 | skills/task-discipline/references/critical-rules-discipline.md（追加 Rule 95） | 其他规则文件；既有规则条目任何改写 |
| 索引锚 | skills/task-planner/SKILL.md 与 skills/task-planner/references/critical-rules.md 中的纪元计数行（仅 1-94→1-95 口径） | 这两文件的其他内容 |
| 执行体 | skills/task-planner/companion/agents/video-generation-executor.md、image-generation-executor.md（仅额度/停等/质检处置相关段） | 其他 agent 定义 |
| 回归面 | 只跑既有套件（bash skills/task-planner/scripts/run-selftests.sh --fresh），零脚本改动 | 新增任何脚本/断言/hook（§四.6 文本优先，新增机器面=范围扩张禁止）；selftest 零改动（Phase 1 实证宽容锚已覆盖） |
| 文档级联 | SKILL.md、README.md、docs/ARCHITECTURE.md、CLAUDE.md、README_zh.md 中 Phase 1 冻结的 22 行纪元计数（CA-7/CA-8） | 上述文件的其余内容；batch-quality-gate.md:138（BP-09 锚，勿动） |
| 簿记 | plans/task-nopause-execfirst-20261023/**、plans/INDEX.md 待处理区 | plans/ 其他目录 |
| 部署位 | 经 smart-merge-back --deploy 通道写入 ~/.zcode/skills/task-planner**、cursor 登记位（用户"从根源彻底解决"授权） | 手工散拷贝；~/.zcode/AGENTS.md 等其他保护区 |

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
| CA-1 | skills/task-discipline/references/critical-rules-discipline.md:616+（现 EOF 后） | 新增 | 增量（纯追加，L605-615 Rule 94 逐字不动） | R4「我需要的是泛化行为」 | 检查点②格式锚（Rule 94 尾部形态） | Rule 95 七子条全文追加 |
| CA-2 | companion/agents/video-generation-executor.md:19「成本纪律…配额警示后再批量」 | 修改 | 替代（①该措辞被用户裁决证伪=恶意暂停根因；②替代范围完整覆盖成本警示语义为执行即探测；③Phase 2 Read 全文后执行；④替代后 selftest 全绿） | R3「直接发起任务…如果不做任何的测试，直接去停止」 | 检查点①L19 逐字 | 改写为「试水 PASS 即自动扩批+执行即探测」措辞 |
| CA-3 | companion/agents/video-generation-executor.md:58「❌ 超配额无警示批量扩散」 | 修改 | 替代（同 CA-2 四条件） | R1/R3 | 检查点①L58 | 改「❌ 试水未 PASS 即批量扩散」，去额度警示停等语义 |
| CA-4 | companion/agents/video-generation-executor.md:43 额度查询复用段 | 修改 | 增量（原句保留，句尾补"不可查询时执行即探测"分支） | R3「是否有额度你可以直接通过直接执行的方式测试出来」 | 检查点①L43 | 句尾追加执行即探测分支+Rule 95 引用 |
| CA-5 | companion/agents/image-generation-executor.md:42 同款额度段 | 修改 | 增量（同 CA-4） | R3 | 检查点①L42 | 同 CA-4 |
| CA-6 | companion/agents/image-generation-executor.md 三检处置段（L48/L69 附近） | 新增 | 增量 | R5「多做几次质检来分析出其中问题，然后非得将这种决策推给用户」 | 检查点①L48/L69 | 追加三检处置自主化条款（预算内自主复检/重抽，禁推给用户） |
| CA-7 | 文档纪元级联：SKILL.md:9/17/196/209/251、README.md:4/36/81/123/127、docs/ARCHITECTURE.md:4/13/42/113/114/115/135/137、CLAUDE.md:33、README_zh.md:136/229（22 行） | 修改 | 替代（纪元计数事实更新；各处只改计数/列表 token，语义不动） | R7「必须从根源上彻底解决」（生效面含部署链一致性） | 检查点②级联表（逐行原文+改法） | 1-94→1-95、77 条→78 条、纪律域列表补 95、:114 行数注与 :115 算式随动 |
| CA-8 | docs/ARCHITECTURE.md:121-123 纪元注释链 | 新增 | 增量（链尾追加一行，旧行不动） | 同 CA-7 | 检查点②注 | 追加 2026-10-23 Rule 95 演进行 |
| CA-9 | 部署位 zcode+cursor（~/.zcode/skills、~/.cursor/skills 的 task-planner+task-discipline） | 更新 | 增量（文件级 cp 覆盖 7 文件×2 位） | R7（运行位生效） | 检查点④映射+rule94 先例 | smart-merge-back --deploy + TASK_PLANNER_DEPLOY_SLOTS=zcode:cursor |
| CA-10 | skills/task-discipline/SKILL.md（:15/:76/:78/:89 四处） | 修改 | 增量（索引行追加+计数 45→46） | R4（泛化规则须可索引消费） | CR MAJOR-1（subagent-state/4c-cr.md：78 条分母实体缺位） | 索引表追加 \| 95 \| 行+四处计数/枚举改 46 |
| CA-11 | skills/task-discipline/references/execution-recall-card.md（E 节 Rule 94 行后追加 1 行） | 新增 | 增量 | R4 | CR MINOR-8+卡片头 §维护同步义务（Rule 93.1） | 追加执行优先蒸馏行 |
| CA-12 | CR 意见处置（MAJOR-2/MINOR-1/2/3 改 Rule 95 条款文本；MINOR-4/5/6/7 改 ARCH/README 注释算术） | 修改 | 增量/措辞精化 | R7 | CR 检查点 4c-cr.md 逐字修法 | 按检查点修法逐条落地；NIT-1/2/3 不采纳（NIT-1 措辞取舍、NIT-2 替换行=保留真守卫、NIT-3 就地改写为对称性刻意选择）——理由登记于此 |

> Scope 修正记录（2026-10-23，Phase 1 冻结）：原 scope 写「selftest 纪元锚行」——Explore 实证 selftest i 类=0（宽容锚 9[0-9] 已覆盖），真级联=上述 5 文档 22 行。本表即冻结清单；BP-09 锚 batch-quality-gate.md:138「隶属 Rules 1-36」明确勿动（7[0-7] 不含 78，误写即 FAIL）。

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | Rule 82 分层架构与卫星路由（Rule 95 归属判定） | skills/task-planner/SKILL.md 卫星路由表 | 必读 | ☑ |
| 项目内部文档/知识库 | task-discipline 卫星规则文件尾部形态（94 落地先例=Rule 95 追加格式锚） | skills/task-discipline/references/critical-rules-discipline.md | 必读 | Phase 2 Read |
| 项目内部文档/知识库 | 视频/图片执行体现状（额度/停等/质检段原文） | skills/task-planner/companion/agents/video-generation-executor.md、image-generation-executor.md | 必读 | Phase 2 Read |
| 项目内部文档/知识库 | 编号预留账本（95 空闲已核） | plans/.rule-reservations.jsonl（最新=94 landed） | 必读 | ☑ |
| 项目内部文档/知识库 | worktree 隔离合约与部署通道 | skills/task-planner/references/worktree-isolation.md；smart-merge-back.sh --deploy | 参考 | Phase 5 Read |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 执行体在「零报错证据 + 存在直接推进路径 + 暂停对用户零收益且资源流失」的场景下制度性停等（额度预询问/预报备、质检决策推给用户），且技能族无泛化禁令约束该行为类——本次按日重置的视频额度因停等零消耗被重置，用户权益实质受损。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？——能：Rule 95 泛化禁令+执行体条款修正即可机器验证落地
- [x] 核心问题不解决，其他工作都白费吗？——是：只修视频一个点不解决行为类（用户 R4 明令泛化），同类暂停会继续复发损耗额度类资源
- [x] 核心问题的解决方法是清晰的、可执行的？——清晰：文本规则（Rule 95 七子条）+两执行体精确改写+纪元级联+部署通道，全部既有机制

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| S1/Phase 1（发现映射） | LOCAL-ONLY | 额度、询问、停等、放行、1-94 | 本地 grep/Read（Explore 子代理） | findings 载体清单+冻结锚清单 | 不适用 |
| Phase 2-5 全部 | LOCAL-ONLY | 规则文本、执行体、纪元锚 | 本地 Read/Edit+既有脚本 | 规则条目/diff/回归输出 | 不适用 |

> 豁免声明：本任务全 S-unit LOCAL-ONLY（仓内规则文本修订与既有机制编排，无外部数据/知识依赖）。

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| n/a（纯执行类） | 规则文本修订任务，非调研/归因/评估类产出 | - | - | - |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
Phase 4（回归+CR；S4 drift=ALIGNED 留痕 d4-drift-phase3-4.md）

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
S3 CR 审查（general-reviewer）→APPROVED 后 Phase 5：smart-merge-back --deploy（TASK_PLANNER_DEPLOY_SLOTS=zcode+cursor）→VC-5/6 终验→归档交付

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

**workflow 编排判定（Rule 40.4）**: [命中 39.8 激活条件（独立并行 ≥3 S-unit 可 fan-out / 长链编排型 / 用户点名）→ 登记『CreateWorkflow 路由（39.8 条件命中）』并执行期按 39.8 三件套主动创建；未命中 → Rule 21.4 独立性守门调度（并行默认+声明制）]
**/goal 对齐（Rule 40.3）**: [本计划 Goal+VC 即 session goal 的证据源;如用户已用 /goal 锚定本任务,在执行范围或 Goal 段注明映射;/goal 为用户侧 harness 命令,技能层不可代调]

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: Requirements & Discovery（发现与映射）
- [x] 映射措辞承载体：skills/task-planner/companion/agents/video-generation-executor.md 与 image-generation-executor.md 的额度/停等/放行段 + skills/*/references/critical-rules-*.md 相关条款行，结论落检查点第一节
- [x] selftest 纪元锚清单（结论：i 类=0，宽容锚已覆盖；级联改走文档 22 行，CA-7/CA-8 冻结）
- [x] 部署位映射（zcode+cursor 2 位，TASK_PLANNER_DEPLOY_SLOTS 对齐 rule94 先例）
- [x] Rule 95 编号空闲复核（attest 自动 reserve 成功）
- [x] findings.md 载体表回填
- **V-N:** VC-4（锚清单为级联输入）, VC-6（编号空闲）
- **Status:** complete
- **Executor:** Explore（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 只读映射：额度/停等措辞承载面+selftest 纪元锚行+部署位，结论落检查点 | Explore（haiku-1） | 检查点 plans/task-nopause-execfirst-20261023/subagent-state/1-explore.md；扫 skills/ 与 scripts/ | 检查点四节齐（执行体措辞面/规则锚面/纪元锚行清单/部署位映射），每节含路径+行号 | 15min | 0f/0l/15min | 无 | - | pending |

### Phase 2: Design（Rule 95 文本定稿+变更标注）
- [x] Read 两执行体全文+discipline 尾部（94 落地形态）
- [x] Rule 95 七子条全文定稿（写入 worktree 的 discipline 文件，commit c359c55）
- [x] 两执行体改写精确 diff 定稿（登记变更标注表 CA-2..CA-6，材料包供 Phase 3 派发）
- [x] 创建 worktree（§十一：实现类默认首选）
- **V-N:** VC-1（文本锚在位）, VC-2（改写方案冻结）
- **Status:** complete
- **Executor:** 主进程（例外理由：用户投诉原文仅存于本会话上下文，规则文本为宪法级敏感措辞，转译派发必然失真——语义保真；白名单外理由登记，终验委派率表复核）

### Phase 3: Implementation（执行体修正+纪元级联）
- [x] 按冻结 diff 改写两执行体（S1/S2 完成，主进程亲验 diff+grep）
- [x] 文档纪元级联（S3/S4/S5：SKILL5+CLAUDE1+README5+README_zh2+ARCH9+链尾补登；commit 0ba3aa6）
- [x] 规范召回（Rule 93）：Phase 翻转主进程 Read ../task-discipline/references/execution-recall-card.md 并 progress 留 [recall] 行
- **V-N:** VC-2, VC-3（执行体锚）；VC-4（级联后套件可跑）
- **Status:** complete
- **Executor:** general-coder（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | video-generation-executor.md 按冻结 diff 改额度预询问段为执行即探测 | general-coder（sonnet-1） | worktree 内 companion/agents/video-generation-executor.md；diff=计划变更标注表 CA-2 精确前后文 | grep 旧措辞=0 且新锚≥1 | 10min | 1f/20l/10min | 无 | Phase 2 | pending |
| S2 | image-generation-executor.md 增质检处置自主化条款 | general-coder（sonnet-1） | worktree 内 companion/agents/image-generation-executor.md；diff=CA-3 | 新锚 grep≥1 | 10min | 1f/10l/10min | 无 | Phase 2 | pending |
| S3 | 文档纪元级联 1-95：SKILL.md（5 行）+CLAUDE.md（1 行） | general-coder（sonnet-1） | 冻结清单=检查点 1-explore.md 第二节级联表 + task_plan CA-7 | 6 行改毕且 grep "1-94" 该两文件=0 | 10min | 2f/10l/10min | 无 | S2 | pending |
| S4 | 文档纪元级联 1-95：README.md（5 行）+README_zh.md（2 行） | general-coder（sonnet-1） | 同上冻结清单 + CA-7 | 7 行改毕且旧锚=0 | 10min | 2f/10l/10min | 无 | S3 | pending |
| S5 | 文档纪元级联 1-95：docs/ARCHITECTURE.md（9 行改+注释链尾追加 1 行） | general-coder（sonnet-1） | 同上冻结清单 + CA-7/CA-8 | 9 行改毕+演进行追加+旧锚=0 | 10min | 1f/12l/10min | 无 | S4 | pending |

### Phase 4: Testing & Verification（回归+CR）
- [x] 全量 selftest 套件回归（两轮 92/92 FAIL=0，4a/4d 检查点）
- [x] VC 逐条复验（worktree cwd 实跑，VC-1..4 PASS，4b 检查点）
- [x] CR Gate：第 1 轮 CHANGES_REQUESTED→修复 a95de42→复审 APPROVED（4c/4e 检查点）
- [x] drift-checker 偏移检查派发（ALIGNED，d4 检查点+ledger+Drift Log 三件套）
- **V-N:** VC-4, VC-6
- **Status:** complete
- **Executor:** code-runner-agent（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 全量 selftest 套件回归，轮次落盘 progress（Rule 57） | code-runner-agent（mini） | worktree 根回归入口（Phase 1 确认入口名，检查点第一节登记） | ΣFAIL=0 输出原文落 progress | 15min | 0f/0l/15min | 无 | Phase 3 | pending |
| S2 | VC 逐条复验（run-verification.sh） | code-runner-agent（mini） | plans/task-nopause-execfirst-20261023/verification.md | V-N 全 PASS 输出 | 10min | 0f/0l/10min | 无 | S1 | pending |
| S3 | CR 独立审查（宪法级规则文本+执行体 diff） | general-reviewer（sonnet-1） | worktree 内 git diff master..HEAD+变更标注表 | APPROVED/CHANGES_REQUESTED 结论落 findings | 15min | 0f/0l/15min | 无 | S2 | pending |
| S4 | 偏移检查派发（Rule 61 载体） | drift-checker（haiku-1） | 计划三文件+git 证据 | ALIGNED/DRIFT 判定落 Drift Log+ledger | 5min | 0f/0l/5min | 无 | S1 | pending |

### Phase 5: Delivery（合并部署与簿记）
- [ ] smart-merge-back.sh <worktree> --deploy（合并+部署+清理）
- [ ] rule-reserve land 95 + INDEX 刷新 + 部署 diff=0 复核
- [ ] 归档计划：check-complete exit 0 后先 `bash <skill>/scripts/set-active-plan.sh --clear` 再 `bash <skill>/scripts/archive-plan.sh <task-id> --root <plans根>`（Rule 81；守卫拒绝时登记理由不强移）
- [ ] 知识提取入库：`bash scripts/kb-sync-from-plan.sh <plan-dir>` 生成 draft → 精炼改名 → `bash scripts/kb-rebuild-index.sh`（项目存在 knowledge/ 机制，必做）
- [ ] 交付总结五要素输出（templates/delivery-summary.md）
- **V-N:** VC-5, VC-6
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
| `conflict_scan` | `safe`（信号①=本任务 plans/ 目录自身，非冲突；信号③=遗留 wt/task-v168-machine-parked 非本任务射程，仅登记不处置；信号④=7 个在册未完成任务可能并行——合并前按 §11.3 复核主仓 scope 文件无未提交变更；技能文件=运行中基础设施命中 §11.1.1） |
| `isolation` | `worktree`（实现类默认首选；§11.1.1 技能保护区命中） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-nopause-execfirst-20261023` |
| `branch` | `wt/task-nopause-execfirst-20261023`（自 master 886f060 创建；建后核对关键文件与主仓 HEAD 一致，防 worktree 分支不同步判例复发） |
| `merge_back` | `pending` |

> 契约详见 `${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/references/methodology.md §R2）

<!--
  WHAT: 对每个 Phase 枚举失败模式，打 S(严重度)/O(频度)/D(探测难度) 各 1-10 分，RPN=S×O×D。
  WHY: RPN>100 的高风险 Phase 必须预先登记兜底动作（对齐 Rule 22.3 五档兜底链，task-v113 后含 22.3.0 资料先行档），避免执行期临时决策。
  WHEN: 计划创建时填写（高 RPN 项）；纯文档/调研类小任务可写 n/a。
  开关键: config.json#fmea_enforce（默认 warn；enforce 档下 RPN>100 无兜底登记 = 计划无效）。
-->

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | 纪元锚形态遗漏（字面/正则/计数多形态，历史级联 5 次翻车） | 7 | 6 | 6 | 252 | 多形态族 grep（`1-94`/`1-9[0-9]`/计数行）交叉复核后冻结清单；执行期套件回归兜底（22.3④ 主进程复核） |
| Phase 3 | attest/check-plan-dispatch 三拦点误拦（NNmin 格式/粒度/输入 token） | 5 | 5 | 3 | 75 | 读脚本源码对齐格式后重锁（22.3.0 资料先行档） |
| Phase 4 | selftest 套件存量红面与本任务无关（基线漂移） | 6 | 4 | 4 | 96 | 对照 master 基线分类：预存红登记豁免、新增红必修（22.3② 拆细） |
| Phase 5 | 部署位漂移/指针竞态（并行会话） | 6 | 3 | 5 | 90 | 部署后 diff=0 复核；指针异常走 set-active-plan --sid（22.3③ 降档） |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

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

> 契约详见 `${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. Rule 95 编号是否空闲？（已核账本：最新=94 landed，95 空闲；attest 时自动预留）
2. 纪元锚影响面多大？（Phase 1 冻结清单回答；预期为 selftest 计数行族）
3. 两执行体中"额度停等"措辞的确切形态？（Phase 2 Read 全文后定精确 diff）
4. 部署位有哪些？（以 rule94 部署任务先例+smart-merge-back --deploy 登记为准）

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
| L1 standard 档（非 L0-T 纯文本档） | 命中任务规划矩阵：≥3 文件+技能保护区；但不新增任何脚本/hook/守护断言（§四.6 文本优先——selftest 纪元锚行级联=既有断言维护，非新增机器面） |
| Rule 95 全文落 task-discipline 卫星（核心仅索引级联） | Rule 82 分层纪律：执行纪律域归卫星（87-94 先例），禁回填核心 |
| Rule 95 文本由主进程撰写 | 用户投诉原文仅存在于本会话上下文；宪法级措辞转译派发必失真（语义保真例外，终验委派率表登记） |
| 执行体修正用"精确 diff 材料包"派发 general-coder | 主进程定稿前后文，子代理机械落地——语义保真与委派纪律兼得（Rule 35.3 范式） |
| D1 计划确认自动通过 | Rule 44.3：完成性指令+自主 /goal 会话无等待对象；停下来等确认=投诉行为重演（五要素登记见 CR 配置区） |
| 部署位经 smart-merge-back --deploy 通道 | 用户"从根源彻底解决"含运行位生效；既有机制通道，禁手工散拷贝 |

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
| 2026-10-23（Phase 1 窗口） | **EXEMPT**（`drift_exempt` 登记：drift-checker 派发连续 3 败=ECONNREFUSED×1+限流×2，Rule 22.3 兜底④主进程接管自检；Phase 4 S4 保留正式派发） | VC-4/VC-5 | ALIGNED（自检：git status 仅 plans/ 本任务簿记新增，零源码写入；Phase 1 产出=映射检查点直接服务 R1-R7；无越界/无手段当目标） |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）
<!-- 
  WHEN: chain_mode: fan-out 或 批量操作 ≥5 单元时必填;纯单次任务可删除整个区块
  WHY: 批量操作禁止以牺牲质量/准确性为代价(Rule 18);前置 3 问 + 双采样抽检 + 失败率熔断的落盘证据
  校验: failure_rate >5% → Phase 禁止 complete;sampled_fail >0 → 整批未验证;pre_check 缺项 → plan-writer 校验失败
  完整模板: ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/templates/batch_report.md | 规则详解: ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/references/batch-quality-gate.md
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
  派发 prompt 八字段模板: ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/templates/subagent_dispatch.md
  # [2026-09-27 task-v091 B-2] 单写者澄清+Handoff 低频列折叠（verify_done 无机器消费如实披露）
-->

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-23 | Explore(haiku-1) | Phase 1 只读映射四节（措辞面/锚面/selftest/部署位） | done | 两执行体无显式询问门，根因=video L19/L58 成本警示措辞；selftest i 类=0；级联=5 文件 22 行文档；部署=zcode+cursor 2 位 | subagent-state/1-explore.md 全文 | Research Findings 1-6 | plans/task-nopause-execfirst-20261023/subagent-state/1-explore.md | retry 2（provider 限流）/ 0 / ☑ |
| 2 | | | | queued | | | | | - / 0 / ☐ |

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
- **不沉淀理由**：规则修订类任务已有 90+ 判例（v143/v161/v187 等均走 general），非新任务类型；general 兜底合法（Rule 34.1）
