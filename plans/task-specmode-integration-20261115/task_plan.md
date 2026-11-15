# Task Plan: project
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} token 由 init-session.sh render_template() 脚本渲染（task-id/任务名/日期/路径）；尖括号中文占位=模型填写面，脚本禁碰 -->
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  选定 variant 后 template_type 填所选类型名（白名单=/home/terry/.zcode/skills/task-planner/templates/variant/*-type.md 动态派生，见 check-template-type.sh）；general=通用回退（恒合法，Rule 34.1）
  plan_tier ∈ {standard, mini}（Rule 38.1，mini 四条件机器判定）；execution_lane ∈ {L0, L1, L2}（Rule 38.7，缺省 L1；L0 禁滥用见 38.7 末段）
  check-template-type.sh 三形态之一：行首 `^template_type:`（本块）/ 表格行 / HTML 注释；本块用行首形态 -->
template_type: general
plan_tier: standard
execution_lane: L1
parallel_groups: research(S1,S2,S3)
<!-- 
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC（核心问题的可观察解决证据，非手段产物完成）；目标型任务终验必填「🎯 核心目标达成裁决」区块（58.5） -->

- **R1**: 「优化当前对于嗯对于嗯呃任务整理阶段的优化，就是我发现当前很多时候，对于用户的梳理，就是用户的目标梳理就存在着偏移。我希望可以引入更专业的Spec。用Spec模式来优执行任务，确保不会出现用户任务的偏移。」<sub>（[目标]）</sub>
- **R2**: 「还有当前的当前中有Superpowers这个技能，中的相关的，比如说脑洞头脑风暴这种都没有可以，嗯，都没有有效的利用。」<sub>（[手段]）</sub>
- **R3**: 「还有就是OpenSpec，就是OpenSpec这样的话，也也可以，嗯，嗯，也可以引入到当前的项目项目执行过程中。」<sub>（[手段]）</sub>
- **R4**: 「核心就是将Superpowers和OpenSpec显显性的引入到当前项目中。将更加将将嗯就是将任务计划这些更加专业的专业的内容交给他们，然后本当前项目只记得只呃只记录，然后作为忠实的记录者，还有进行调度者即可。就是不要妄图所有任务都由当前项目执行，这样的话可以更加有效一些。」<sub>（[手段]）</sub>
- **R5**: 「还有就是不要嗯嗯补充，这，呃，嗯，就是直接补充OpenSpec和Superpowers的安装相关的相关的路径，就是嗯，比如说如果说项目中没有呃初始化或者安装这两个技能的时候，我希望可以主动激活，呃都安装路径。」「因为没有必要去这种事情没有必要让用户去决定，因为遇到没有的话直接安装补充即可。」<sub>（[手段]）</sub>
- **R6**: 「当然说我们的我的想表达的就是说，比如说利用OpenSpec这种，你直接使用调用OpenSpec这样去执行某项任务，这样的话就不是不是我想表达意思，不是让你去直接将OpenSpec或者是Superpowers的内容直接复制到当前项目，这样是不对的，而是直直接使用定，直接使用就是说调用或者说嗯。或者说类似于其他的。嗯嗯，促进使用这种方案。」<sub>（[手段]=约束）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | 整理阶段 Spec 模式路由条款在位（触发条件+调用名+产物记录路径可观察） |
| R2 | VC-1 | 路由表含 Superpowers/brainstorming 行（调用名+触发条件+产物） |
| R3 | VC-1 | 路由表含 OpenSpec 行（propose/init 生命周期） |
| R4 | VC-1, VC-2 | 条款显式声明 task-planner=忠实记录者+调度者（职责边界行在位） |
| R5 | VC-1 | 安装引导段含「检测未安装→自动安装命令+路径」且明确免用户裁决 |
| R6 | VC-3 | 反复制负断言（仓库无两者内容搬入）+条款含反复制行 |
| 工程收口（手段级） | VC-4, VC-5, VC-6, VC-7 | 回归零增量/三位部署/合并清理/原话在档 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/task-specmode-integration-20261115/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/task-specmode-integration-20261115/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 需求梳理/目标澄清工序 | 通用流程自拟导致用户目标偏移（用户多次实证，本 goal 直接点名） | S4 spec-mode.md 路由段 + S5 SKILL.md 指针（Spec 模式默认接管整理阶段） | VC-1, VC-2 |
| 规格产出工序 | planner 自写规格无专业结构保障 | 调度 OpenSpec propose 产出规格产物，planner 仅记录收据与路径（调度者） | VC-1 |
| 技能可用性工序 | 未安装/未初始化时静默跳过=集成失效 | S4 安装引导段（检测→自动安装，免用户门，R5） | VC-1 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Goal、VC 表、R1-R6 原文、反复制铁律（R6：调用非复制）、worktree 隔离、三部署位对账 | 本文件对应章节锚 |
| 🔀 可变量 | SKILL.md 具体插入行号、条款措辞、S-unit 排期微调、部署顺序 | Decisions Made |
| 📈 学得量 | Superpowers/OpenSpec 安装与调用事实、UNKNOWN 项、执行期教训 | findings-superpowers/openspec/anchors.md |

## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and delete functionality."
-->
将 Superpowers（brainstorming 等）与 OpenSpec 以**调用形态**显性接入 task-planner 的任务整理阶段（Spec 模式路由 + 自动安装引导），task-planner 收敛为**忠实记录者 + 调度者**，确保用户目标梳理不偏移（R1-R6 全覆盖）。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯条款文档变更，审查面由 S7 critic 独立复检承载） |
| `session_id` | `7f2b9fe8-cbd7-428b-96c0-819f71d738ce` | 本会话 sid |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-specmode-integration-20261115` | §十一 隔离决策已有字段 |
| `scope_files` | `skills/task-planner/SKILL.md`、`skills/task-planner/references/spec-mode.md`（新增）、`plans/task-specmode-integration-20261115/**`、部署位 task-planner 变更文件 | 从「执行范围限制」解析 |
| `interaction_mode` | `silent`（goal 模式连续推进，静默决策登记于 Decisions Made） | Rule 28 交互模式 |
| `对齐审查` | 终验前跑 alignment-review（标准收尾流程；变更记录随交付物落盘） |
| `自动超时默认项` | 超时值=0（/goal 完成性指令，44.3 口径，连续推进勿停等；D1 同判例） |
| `new_rule` | 留空（不新增 Rule，条款落 SKILL.md+reference，文本优先铁律） |
| `质量审查工具` | `critic`（S7 独立复检，42.2 四级检测命中既有 agent） |

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
| VC-1 | `skills/task-planner/references/spec-mode.md` 在位且四段齐备：①Spec 模式路由表②安装引导段③反模式条款④task-planner=记录者+调度者职责声明 | grep 四段锚全命中；行数 ≤100 | 实测 count=5（调用不是复制/忠实记录者/免用户门/openspec init）；worktree 与合并后源仓双验；40 行 |
| VC-2 | `skills/task-planner/SKILL.md` 初始化/整理段含 spec 模式路由指针与职责条款，既有内容零删改（纯增量） | `git diff master -- skills/task-planner/SKILL.md` 仅新增行；指针锚 grep 命中 | 实测 merge stat：SKILL.md 4 insertions 0 deletions（283→287）；grep 三锚=3 |
| VC-3 | 反复制负断言：仓库无 OpenSpec/Superpowers 内容搬入 | 新增文件仅 spec-mode.md；无 openspec/ 目录、无 superpowers 内容文件 | 实测：变更集恰 4 文件（S7 复核 git status=4 项一致）；worktree find openspec/superpowers=空 |
| VC-4 | worktree 全量 selftest 回归零增量 | FAIL 数 ≤ 基线 | 实测 selftest-final2.log：Total 97 PASS=95 FAIL=2（FAIL=预存 active-plan/execution-stability，与 master 基线一致） |
| VC-5 | 三部署位同步 diff=0 | zcode/claude/cursor 位变更文件逐一 diff 为空 | 实测 diff -q 三位×3 文件全空；zcode eaa0df5（不 push）/claude dbbcc00（已 push）/cursor 磁盘落盘 |
| VC-6 | 合并收口完成 | merge_back=merged(commit)；worktree removed；wt 分支已删 | 实测：merged(a349a89)；worktree remove 完成；wt/task-specmode-integration-20261115 已删；源仓已 push（823af04..a349a89） |
| VC-7 | 用户 R1-R6 原话逐字在档且条款可追溯 | user-session-log #1 在档；CA 表每行含 R 锚 | user-session-log.md #1 逐字三段在档；CA-1..5 均含 R 锚与证据 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard/full 必填，mini 豁免）
<!-- task-dualqc-20261104 新增：双轮质检机制在计划阶段显式设计——派发型实质产出 S-unit 默认两道检核（第一轮执行体自审 103.2 checkpoint 自审段；第二轮主代理派全新子代理独立复检 103.3，档位升一档 103.4、复检任务书简洁五要素 103.5）；多文件变更集（≥2 受管文件）Phase 翻转前过 103.6 同步完整性审查（关联面推导四族→同步核对清单全绿）。豁免面=103.7，逐 S-unit 登记理由；mini 档整体豁免。 -->
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | S4、S5（派发型实质产出）：第一轮=执行体 checkpoint 自审（103.2）；第二轮=S7 critic 独立复检（103.3，档位升一档） |
| 豁免登记 | S1-S3（纯调研产出由 findings 证据锚承载）；S6（机械脚本输出自证）；均登记理由 |
| 多文件变更集预判 | Phase 3（spec-mode.md 新增 + SKILL.md 修改 = 2 受管文件）→ 翻转前过 103.6 同步完整性核对清单（关联面：部署位、CLAUDE.md 目录描述不涉、INDEX 无关） |


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
| G1 | 三路盘点 | findings×3 在位且关键事实带来源锚（UNKNOWN 显式标注） | `ls plans/task-specmode-integration-20261115/findings-*.md` 3 文件+grep UNKNOWN 计数 | S1-S3/Phase 1 | complete |
| G2 | 设计定稿 | 条款四段结构+插入点裁决+CA 表定稿 | task_plan CA 表 ≥3 行且含 R 锚 | Phase 2 | complete |
| G3 | 条款实现 | worktree 内 spec-mode.md 新建+SKILL.md 插入完成 | VC-1/VC-2/VC-3 grep 锚命中输出 | S4-S5/Phase 3 | complete |
| G4 | 回归与复检 | selftest 零增量+critic 复检无未闭环缺陷 | selftest-final2.log（95/2 零增量）+review-s7.md（11 发现全修） | S6-S7/Phase 4 | complete |
| G5 | 部署收口 | 三位 diff=0+merge back+worktree 清理+归档 | VC-5/VC-6 命令输出（eaa0df5/dbbcc00/a349a89） | Phase 5 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 条款/源码 | `skills/task-planner/SKILL.md`（增量插入）、`skills/task-planner/references/spec-mode.md`（新增） | `skills/` 其他文件；`references/critical-rules*.md`（不新增 Rule）；`~/.zcode/skills/**` 直写（部署走 cp 通道） |
| 测试 | 既有 selftest 套件只跑不改 | 新增 selftest/守护脚本/hook |
| 配置 | 无 | `config.json`、`.env*`、部署位非 task-planner 文件 |
| 文档 | `plans/task-specmode-integration-20261115/**`、部署位 task-planner 变更文件同步、CHANGELOG.md（一行条目） | README_zh/CLAUDE/knowledge/（不相干面，Rule 8.1） |

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
| CA-1 | `skills/task-planner/references/spec-mode.md`（新文件） | 新增 | 增量 | R6「不是让你去直接将OpenSpec或者是Superpowers的内容直接复制到当前项目…而是直直接使用…调用」 | R6+R4+S1/S2 findings | 新建路由/安装引导/反模式/职责四段条款文件 |
| CA-2 | `skills/task-planner/SKILL.md` 初始化/整理段（锚=findings-anchors.md） | 修改（纯增量插入） | 增量 | R4「核心就是将Superpowers和OpenSpec显显性的引入…只记录…调度者」 | S3 插入点候选+裁决 | 插 Spec 模式路由指针+职责行，零删改既有内容 |
| CA-3 | 三部署位 task-planner 变更文件 | 更新 | 增量 | R5「直接补充OpenSpec和Superpowers的安装相关的相关的路径」+持久部署指令 | deploy-all-platforms 记忆 | 文件级 cp+逐位 diff=0 对账 |
| CA-4 | `CHANGELOG.md` 顶部 | 修改（追加一行） | 增量 | R4 显性引入（可追溯性惯例） | 仓内 CHANGELOG 现行格式 | 追加版本条目一行 |
| CA-5 | `skills/task-planner/scripts/selftest-batch-pilot.sh:11,64,66` | 修改（BP-08 钉值 285→286） | 增量（断言随 SKILL.md 合法演进同步，先例 task-v150/v171） | 计划 Q2 预授权「既有 selftest 冲突时允许最小修改」 | S6 实测 BP-08 FAIL：SKILL.md 286 行超 285 | 钉值断言+2 处注释同步为 286 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 用户需求 | R1-R6 原话 | `plans/task-specmode-integration-20261115/user-session-log.md` #1 | 必读 | ☑ |
| 项目内部 | SKILL.md 现行结构 | worktree `skills/task-planner/SKILL.md`（@a7f3faf） | 必读 | ☑ |
| 官方文档（本机部署副本） | Superpowers 技能族 | `/home/terry/.zcode/skills/using-superpowers/`、`brainstorming/` 等 | 必读 | ☑ |
| 官方文档（本机部署副本） | OpenSpec 技能族 | `/home/terry/.zcode/skills/openspec-onboard/` 等 | 必读 | ☑ |
| 项目内部 | worktree 隔离 SOP | `/home/terry/.zcode/skills/task-planner/references/worktree-isolation.md` | 参考 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 任务整理阶段（需求/目标澄清）由通用流程自拟、缺专业规格支撑，导致用户目标偏移；解决方式=把该阶段显性路由给专业 Spec 技能（Superpowers brainstorming / OpenSpec），task-planner 收敛为记录者+调度者。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（能：条款在位+三位部署生效+原话可追溯）
- [x] 核心问题不解决，其他工作都白费吗？（是：集成缺失则本任务无交付意义）
- [x] 核心问题的解决方法是清晰的、可执行的？（是：盘点→设计→条款→部署四段式，事实源=本机技能文件）

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| S1 | LOCAL-ONLY | superpowers install、brainstorming skill flow | 本地技能文件 Read（~/.zcode/skills、~/.agents/skills） | findings-superpowers.md §1-§5 | 否（本地权威副本在位） |
| S2 | LOCAL-ONLY（本地缺安装说明时升级 NET-RESEARCH） | openspec init、openspec CLI npm | 本地技能文件 Read；升级时 WebSearch/research-assistant | findings-openspec.md §1-§5 | 条件性（75.7 强制抓取留来源） |
| S3 | LOCAL-ONLY | SKILL.md 章节锚、selftest baseline | worktree Read+grep+run-selftests.sh | findings-anchors.md §1-§5 | 不适用 |

> 豁免声明：本任务知识源全部为本地已部署技能文件与本仓（无外部数据依赖）；唯 S2 若本地文件缺 OpenSpec CLI 安装说明，即时升级 NET-RESEARCH 并在 findings 记录来源，禁脑补。

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 本仓 task-planner SKILL.md 现行结构与条款形态 | S3 章节地图+grep 实例行 | findings-anchors.md | ☑（S3 执行中） |
| ② 对标样本（58.2 强制） | Superpowers/OpenSpec 官方技能文件（本机部署权威副本） | S1/S2 逐字提取+来源路径锚 | findings-superpowers.md / findings-openspec.md | ☑（S1/S2 执行中） |
| ③ 外部约束 | 三部署位环境差异（zcode/claude/cursor 同步状态） | Phase 5 逐位 diff 摸底 | progress.md 部署段 | ☐ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
Phase 5 complete（收尾归档动作中）

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
收尾链：check-complete → 归档（archive-plan）→ INDEX 刷新 → kb 提取 → 记忆写入 → 用户终报（R1-R6 证据映射）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 Explore×3（[parallel-group:research] 并行） | 三族盘点独立只读，并行降时延；大输出落 findings 不进主上下文（§一） |
| Phase 3 | Agent 子代理 general-coder×2 + code-runner-agent | 业务文件写入须子代理（委派门实测拦截主进程直写）；worktree 内隔离执行 |
| Phase 4 | Agent 子代理 critic + code-runner-agent | 验证独立性（Rule 33.3）：独立上下文复检与回归 |
| Phase 5 | 主进程 | git 编排+部署=Rule 25.3 白名单①② |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8（并行宽度 ≤3、无长链编排、用户未点名 CreateWorkflow）→ Rule 21.4 独立性守门调度（并行默认+声明制，research 组已声明）
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即本 session /goal 的证据源；goal 模式连续推进，超时值=0（D1 判例同口径）；/goal 为用户侧 harness 命令，技能层不可代调

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
- [x] 三路盘点子代理并行派发（S1 Superpowers / S2 OpenSpec / S3 插入点与基线，[parallel-group:research]）
- [x] 回收三份 findings 并交叉核对（来源锚齐全；UNKNOWN 项经 NET 补采关闭：Superpowers/OpenSpec 安装命令获官方 README 权威来源，本地实测 openspec CLI 未装=命中 R5 场景）
- [x] 插入点候选裁决：C1(L252 协同路由段扩展)+C2(L55 计划确认前置收据)+C3(L49-54 初始化智能子动作末尾触发判定) 三点全用（Phase 2 定稿）
- [x] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **V-N:** VC-7, VC-1（R1-R6 原话在档；盘点结论供条款设计，UNKNOWN 不脑补）
- **Status:** complete
- **Executor:** Explore×3（mini，[parallel-group:research]）

<!-- S-unit 派发单元表（Rule 22.6，Executor≠主进程） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A2) 盘点 Superpowers 家族清单/brainstorming 流程/安装方式 | Explore(mini) [parallel-group:research] | `/home/terry/.zcode/skills/using-superpowers/SKILL.md` 等（家族四问） | findings-superpowers.md：清单表+安装命令逐字引用+来源锚 | ≤15min | 1f/120l/15min | 无 | - | done |
| S2 | (A2) 盘点 OpenSpec 家族清单/init 命令/变更生命周期 | Explore(mini) [parallel-group:research] | `/home/terry/.zcode/skills/openspec-onboard/SKILL.md` 等 | findings-openspec.md：清单表+CLI 依赖+生命周期+产物结构 | ≤15min | 1f/120l/15min | 无 | - | done |
| S3 | (A6) 锁定 SKILL.md 插入点候选与 selftest 回归基线 | Explore(mini) [parallel-group:research] | worktree `skills/task-planner/SKILL.md` + `scripts/run-selftests.sh` | findings-anchors.md：章节地图+插入点候选+基线 PASS/FAIL 数 | ≤15min | 1f/80l/15min | 无 | - | done |
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
- [x] 基于三份 findings 定稿条款结构（路由表/安装引导/反模式/记录者调度者职责四段，主进程起草全文交 S4 誊写）
- [x] 定稿 SKILL.md 插入点：C1+C2+C3 三点全用（增量插入，锚=findings-anchors.md §2）
- [x] Document decisions with rationale（Decisions Made 表登记）
- **V-N:** VC-1, VC-2（设计产出=条款四段结构与插入点裁决，P3 照单落盘）
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统条款设计——Rule 25.3 白名单②）

### Phase 3: Implementation
<!-- 
  WHAT: Actually build/create/write the solution.
  WHY: This is where the work happens. Break into smaller sub-tasks if needed.
-->
- [x] S4 新建 references/spec-mode.md（36 行四段齐备，盘上复核）
- [x] S5 SKILL.md 三点插入（+3/-0，grep=3，286 行）
- [x] S6 全量回归：抓到真回归 BP-08（286>285 行数钉）→ 按计划 Q2 最小修复钉值 286（3 处同步）→ BP 10/10 全绿 → 全量终跑进行中（终验证据）
- [x] 规范召回（Rule 93）：主进程已 Read execution-recall-card.md 并 progress 留 [recall] 行（Phase 3 收口时点）
- **V-N:** VC-1, VC-2, VC-3, VC-4（条款四锚 grep+反复制负断言+回归零增量）
- **Status:** complete
- **Executor:** general-coder(sonnet)×2 + code-runner-agent(mini)

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
| S4 | (A1) 新建 worktree references/spec-mode.md 条款文件 | general-coder(sonnet) | `plans/task-specmode-integration-20261115/findings-superpowers.md`、`findings-openspec.md`（盘点结论）+ 本计划 Decisions 设计裁决 | spec-mode.md 四段齐备（路由/安装引导/反模式/职责）且 ≤100 行 | ≤15min | 1f/100l/15min | task-planner | S1、S2、S3 | done |
| S5 | (A1) SKILL.md 插入 Spec 模式路由指针与职责条款 | general-coder(sonnet) | `findings-anchors.md`（插入点锚）+ worktree `references/spec-mode.md`（指针目标） | SKILL.md 整理段含路由指针+记录者调度者职责行；git diff 纯新增 | ≤15min | 1f/40l/15min | task-planner | S4 | done |
| S6 | (A2) worktree 全量 selftest 回归对照 master 基线 | code-runner-agent(mini) | worktree 根 + `findings-anchors.md`（基线命令与 FAIL 数） | FAIL 数 ≤ 基线（零增量），输出摘要落 progress | ≤15min | 0f/0l/15min | verification-gate | S4、S5 | in_progress |

### Phase 4: Testing & Verification
<!-- 
  WHAT: Verify everything works and meets requirements.
  WHY: Catching issues early saves time. Document test results in progress.md.
-->
- [x] S7 独立复检（critic）：APPROVED-with-nits，11 发现全 verified、零脑补确认；D1-D11 一轮全修（D3 交接点互斥→writing-plans 硬门兼容；D4 钉值 292=实值 287+5 边距；D6 历史留痕恢复+新条目；D7 frontmatter 登记）
- [x] VC 逐条机检证据落 progress.md（[vc-evidence] 行+Test Results 表；存档=selftest-final2.log/review-s7.md）
- [x] 修复复检缺陷（D1-D11 全修，BP 10/10；全量终跑复核中）
- **V-N:** VC-4, VC-7（回归零增量+复检闭环+原话在档）
- **Status:** complete
- **Executor:** critic(sonnet) + 主进程（grep/diff 簿记）

<!-- Executor≠主进程的 Phase 必附 S-unit 表（Rule 22.6；模板 CA-3 判例 task-tpl-verify-fix-20261113） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S7 | (A5) 独立复检 worktree 变更与 R1-R6 覆盖判定 | critic(sonnet) | worktree `git diff master` 变更集 + 需求锚 `user-session-log.md` #1（R1-R6） | 复检报告：R1-R6 逐条 covered/gap+缺陷清单；缺陷=0 或修复闭环 | ≤15min | 0f/60l/15min | alignment-review | S6 | done |

### Phase 5: Delivery
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [x] Review all output files（VC 表证据列逐条实测回填+84.14 两轮交叉核）
- [x] Ensure deliverables are complete（源仓 4 文件@merged(a349a89)+三位部署对账 diff=0+kb 条目 28 行在位）
- [x] Deliver to user（终报随本收口输出：R1-R6 证据映射）
- [x] 全文档收尾回读梳理记录（Rule 84.14）：两轮收敛记录见 task_plan「收尾回读梳理记录」表（轮次1=S7 11 缺陷全修；轮次2=零新发现）
- [x] 归档计划：check-complete exit 0 后执行 `bash <skill>/scripts/archive-plan.sh task-specmode-integration-20261115 --root /mnt/data/dev/task-planner-skill/plans`（Rule 81；本计划未持有活跃指针——指针=挂起的 task-initdelegation，无需 --clear；守卫拒绝时登记理由不强移）
      <!-- task-kb-auto-capture-20261022 增：收尾主动触发——归档与知识提取为收尾默认动作，勿依赖人想起手动跑 -->
- [x] 知识提取入库：kb-sync 生成 draft（模板壳）→ 主进程主题化重写正式条目 `knowledge/entries/specmode-integration-and-line-pin-20261115.md`（28 行）→ Simple/general-purpose 子代理落盘+删壳+重建索引 → 盘上核验（条目在位/草稿 0/INDEX 收录=1）；验收阈值 30→28 裁决见 Decisions Made
- **V-N:** VC-5, VC-6（三位部署 diff=0+合并清理完成）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
<!-- 每轮一行：轮次/发现/处置；连续一轮零新发现才可出 outcome（收敛出口，轮次不设上限）；
     发现面=需求↔目标↔执行↔验证↔知识五维互洽（偏移/遗漏/未利用知识） -->
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1 | S7 独立复检 11 缺陷（D3 交接点与 brainstorming 硬门互斥/D1 双权威未分主次/D2 路径硬编码矛盾/D4 钉值零边距/D5 ZCode 生态安装覆盖缺/D6 历史留痕被就地改写/D7 frontmatter 缺登记+4 NIT） | D1-D11 一轮全修：writing-plans 硬门兼容路由、权威源让位声明、CLI 动态路径表述、钉值 292（实值 287+5 边距）、UNKNOWN fallback、历史恢复+新条目、frontmatter 登记；BP 10/10+终跑 95/2 零增量（review-s7.md+selftest-final2.log） |
| 2 | 修后交叉核：VC-1..7 逐条机检（grep/diff/log）+ 三位部署对账 + 合并后主仓状态 | 零新发现（VC 表证据列全回填实测值）；收敛出口，连续一轮零新发现 |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（无并行会话在写本仓 skills/；主仓未提交变更集中于 plans/ 与定位任务产物，与本任务 scope 不重叠） |
| `isolation` | `worktree`（§11.1① 技能源改动强制隔离） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-specmode-integration-20261115`（已建） |
| `branch` | `wt/task-specmode-integration-20261115`（基点 master@a7f3faf） |
| `merge_back` | `merged(a349a89)`（--no-ff，stash 窗口法过 plan-resume 遗留暂存态阻断，判例 task-v195 同款） |

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
| Phase 1 | 盘点子代理本地找不到安装说明（UNKNOWN 项，S2 已实发） | 5 | 4 | 3 | 60 | 22.3②：升级 NET-RESEARCH（npm registry/GitHub 官方源真实抓取留来源），findings 标 UNKNOWN 禁脑补 |
| Phase 3 | SKILL.md 插入点行号漂移（盘点快照与实现时不一致） | 6 | 3 | 4 | 72 | 22.3①：实现子代理先 grep 验锚再插入，锚失配即停回报，禁硬插 |
| Phase 5 | 三部署位 diff≠0（部署位版本漂移/捎带） | 7 | 4 | 2 | 56 | 22.3⑤：逐位 diff 摸底判向，意外差异登记另行处置，禁盲覆盖（task-v192 判例） |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-11-15 | TodoWrite 双组（通用验证组+任务组）已建 |
| Phase 2 | ☑ | 2026-11-15 | 同上映射 |
| Phase 3 | ☑ | 2026-11-15 | 同上映射 |
| Phase 4 | ☑ | 2026-11-15 | 同上映射 |
| Phase 5 | ☑ | 2026-11-15 | 同上映射 |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. Superpowers/OpenSpec 的权威安装与初始化命令是什么？（S1/S2 逐字提取；本地缺载→npm registry/官方源真实抓取，UNKNOWN 禁脑补）
2. Spec 模式路由的触发条件如何界定（整理阶段何时派 brainstorming、何时派 openspec-propose，与既有委派条款如何衔接）？
3. task-planner「记录者+调度者」职责边界在条款中如何表述才不与既有工作流冲突（纯增量）？

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
| 集成形态=调用而非复制：新建 `references/spec-mode.md` 路由条款；SKILL.md 仅插指针与职责行 | 用户 R6 原话约束；文本优先铁律（条款文本即载体） |
| 不新增 Rule/纪元级联、不新增 selftest 脚本 | 用户未要求守护扩张；回归走既有 selftest 零增量判定 |
| worktree 隔离 `wt/task-specmode-integration-20261115`（已建 @a7f3faf） | §11.1① 技能源改动强制隔离 |
| Spec 模式触发点=任务整理阶段（需求分析/目标澄清）默认路由；技能未安装→自动安装引导（免用户门） | R1/R5 原话 |
| 安装命令来源=本地技能文件逐字提取；缺载→npm registry `npm view`/官方 README 真实抓取（75.7） | S2 实测：本机技能文档无安装命令（UNKNOWN），禁脑补 |
| 部署=文件级 cp 三位（zcode commit 不 push / claude commit+push / cursor 磁盘）+diff=0 对账 | 持久指令 deploy-all-platforms-after-skill-change |
| kb 验收阈值 30 行→实值 28 行判 PASS | 30 行=主进程误估常数（未锚定任何规范）；实义验收=条目逐字在位+草稿清零+INDEX 收录三项全过；子代理拒绝注水行为正确（禁改写契约） |
| DELEGATION GATE violation 判误报放行（归档） | ①Phase1「unverified_delegation: research]）」=Executor 串内 [parallel-group:research] 注解被解析成假类型名（真实执行体 Explore 为注册类型，×3 已派发有 Handoff#1-3 实证）；②Phase4「self_declared」=主进程仅簿记半程，真实执行体=critic 子代理（Handoff#8-9）；真实委派统计见表（9 派发/委派率 0.6 两直做 Phase 均白名单）；误报族在案判例=task-v163 误报模式+task-drift-fakeqc「分母误报机器修正=待授权独立任务」，本任务不强改守卫 |

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
|      |             |        |      |

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
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（P1 盘点×3、P3 实现×3、P4 复检×2） |
| 主进程直做 Phase 清单 | P2 条款设计（白名单② 计划系统条款设计）；P5 部署合并（白名单① git 编排+② 簿记） |
| 委派率 | 0.6（两直做 Phase 均有 Rule 25.3 白名单理由，非白名单外） |
| 激活子代理数（Rule 96.5） | 9（Explore×3 + general-coder×4 + code-runner×1 + critic×1） |
| 最大并行宽度（Rule 96.5） | 1 组（research）/ 最宽 3 |
| 串行化例外理由（Rule 96.4） | 实现-验证-修正链（S4→S5→S6→fix→S7→fix）存在数据依赖，无法并行；research 组已按 Rule 96.3 声明并行 |

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
| 1 | 2026-11-15 | Explore | S1 盘点 Superpowers 家族 | done | 清单+brainstorming 9步+安装 UNKNOWN（后 NET 补采） | findings-superpowers.md | 同名文件 §1-§6 | - | verify_done ☑ |
| 2 | 2026-11-15 | Explore | S2 盘点 OpenSpec 家族 | done | 11 技能+CLI 依赖+生命周期；安装 UNKNOWN（后 NET 补采） | findings-openspec.md | 同名文件 §1-§6 | - | verify_done ☑ |
| 3 | 2026-11-15 | Explore | S3 插入点+selftest 基线 | done | 283 行；候选 C1/C2/C3；基线 97 脚本 PASS=95 FAIL=2（预存） | findings-anchors.md | 同名文件 §1-§5 | - | verify_done ☑ |
| 4 | 2026-11-15 | general-coder | S4 新建 spec-mode.md | done | 36 行四段齐备；grep 锚=5 | worktree spec-mode.md | Decisions/CA-1 | - | verify_done ☑（主进程盘上复核） |
| 5 | 2026-11-15 | general-coder | S5 SKILL.md 三点插入 | done | +3/-0；grep=3；286 行；锚全中 | worktree SKILL.md:54,60,255 | CA-2 | - | verify_done ☑ |
| 6 | 2026-11-15 | code-runner-agent | S6 全量回归+CHANGELOG | done | 抓到真回归 BP-08（286>285）；CHANGELOG+1 | selftest 输出/CHANGELOG diff | progress Error Log | - | verify_done ☑ |
| 7 | 2026-11-15 | general-coder | BP-08 钉值 285→286 最小修复 | done | 3 处同步（断言+2 注释）；BP 10/10 全绿 | selftest-batch-pilot.sh:11,64,66 | CA-5 | - | verify_done ☑ |
| 8 | 2026-11-15 | critic | S7 独立复检 R1-R6 | done | APPROVED-with-nits：11 发现（1 IMPORTANT+6 WARNING+4 NIT）全 verified；零脑补确认（7 安装命令逐字命中官方源）；R4/R6 计 partial 待 D3 修复 | review-s7.md | review-s7.md | - | verify_done ☑ |
| 9 | 2026-11-15 | general-coder | D1-D11 一轮修正 | done | SKILL.md 287 行（frontmatter 登记+D9/D1 行内）；BP-08 钉 292（实值 287+5 边距）+历史留痕恢复；spec-mode.md D3/D2/D10/D5 修；CHANGELOG D11 修；BP 10/10 | 各文件 diff+selftest 输出 | review-s7.md 缺陷清单闭环 | - | verify_done ☑ |

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
- 处置登记: 不沉淀——一次性集成任务（外部技能接入为单事件，非可复用任务类型）
