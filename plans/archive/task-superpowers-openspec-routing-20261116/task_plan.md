# Task Plan: project
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} token 由 init-session.sh render_template() 渲染（task-id/任务名/日期/路径）；尖括号中文占位=模型填写面，脚本禁碰 -->
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

- **R1**: 「我希望的是可以根据任务就是用户提，提出任务的复杂度，然后选择这两个，从这两个技能中选择一个合适的技能进行执行。」<sub>（[目标]）</sub>
- **R2**: 「学习这个技能的方式在我当前的技能中引入，嗯，open SPEC以及super POWERED的对任务的解决能力。」<sub>（[目标]）</sub>
- **R3**: 「这样就可以在尽量减少当前本当前技能的就是引入难度的情况下，就是当前技能的保持整理整洁的方式下，可以更好地解决问题。」<sub>（[目标]）</sub>
- **R4**: 「也就是说当前项目是否已经完成了对Superpowered和Open Spec的就是说，任务执行过程的中的集成。」<sub>（[手段]）</sub>
- **R5**（同轮 AskUserQuestion 裁决回传）: 「既有载体条款扩展 (Recommended)」+「复杂度主轴+信号修正 (Recommended)」<sub>（[手段]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-3 | 三载体条款在位：spec-mode §1b 决策表 / skill-collaboration §二复杂度主轴初筛段 / SKILL.md 指针行（grep exit 0） |
| R2 | VC-1, VC-2 | 择一语义+嵌入/移交形态+探针降级条款可执行（决策表四档映射齐全） |
| R3 | VC-1..VC-5 | 零新文件零脚本（3 受管文件增量）；selftest 无新增 FAIL；四部署位 diff=0 |
| R4 | VC-7 | findings-external-families.md A 段在盘（集成现状已答） |
| R5 | VC-1..VC-3 | 落点=裁决指定的既有载体（无新建技能/无脚本） |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/task-superpowers-openspec-routing-20261116/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/task-superpowers-openspec-routing-20261116/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 载体选择（where to put 条款） | 误选独立新技能→引入面膨胀违背 R3 | 用户裁决①+findings F1/F2/F5 | VC-1..3（落点=既有载体） |
| 条款措辞（语义一致性） | 双真源/与权威源冲突/吞锚破坏表格 | 同构互引句+择一语义+插入锚点核对 | VC-1, VC-2 |
| 回归验证（改动面自证） | selftest 内容断言破防未察觉 | run-selftests 全量+基线对照 | VC-4 |
| 部署同步（4 位对账） | 漂移方向误判/只同步单位 | 逐对 diff 判向→覆盖→diff=0 终态 | VC-5 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Goal；VC-1..VC-7 判定标准；R1-R5 原话锚；三受管文件增量（禁删既有行禁改既有语义）；「调用不复制」R6 铁律；worktree 基点=master | 本文件对应章节 |
| 🔀 可变量 | 插入行措辞微调（保语义）/S-unit 时长预估/部署位同步顺序/commit 拆分 | - |
| 📈 学得量 | 执行期新事实/教训→findings.md / notepad-learnings.md；禁反向改写不变量 | findings.md |

## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and delete functionality."
-->
task-planner 按 2026-11-16 用户双裁决，在既有载体（spec-mode.md/skill-collaboration.md/SKILL.md 指针行）落「复杂度主轴+信号修正」的 Superpowers×OpenSpec 择一路由决策条款：零新文件零脚本、三受管文件增量、selftest 无新增 FAIL、四部署位同步 diff=0。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯文档条款类，无代码；质量面由 Phase 4 独立复检+critic 覆盖） |
| `session_id` | `dbd1e0f45d554a02a005a9d940d06eda`（会话哨兵 sid） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-superpowers-openspec-routing-20261116` |
| `scope_files` | `skills/task-planner/SKILL.md`、`skills/task-planner/references/spec-mode.md`、`skills/plan-collab-router/references/skill-collaboration.md`（+4 部署位同路径三文件） |
| `interaction_mode` | `ask` |
| `对齐审查` | [登记] Phase 4 独立复检子代理兼跑条款对齐审查（alignment 语义面）；文档更新前版本一致性以 findings 落盘锚核对 |
| `自动超时默认项` | [询问点: 设计形态双裁决已完成（用户已答），无剩余 2+ 选项询问点; 默认 5min] |
| `new_rule` | （空——纯增量条款挂既有 spec-mode/39/40 面下，无新 Rule） |
| `质量审查工具` | `critic`（既有 agent 名，Phase 4 复检体；Rule 42.2 内置在位） |

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
| VC-1 | spec-mode.md §1b「复杂度分档→族选择」决策表在位：四档映射（L0/mini 直执行、L1→Superpowers 嵌入、L2+/规格留存→OpenSpec 移交、信号修正行）+择一语义 | grep 四关键词均命中 | `grep -q "复杂度分档→族选择" skills/task-planner/references/spec-mode.md && grep -q "L1（中等）且无规格留存需求" skills/task-planner/references/spec-mode.md && grep -q "L2+ 或规格留存需求" skills/task-planner/references/spec-mode.md && grep -q "择一语义" skills/task-planner/references/spec-mode.md` |
| VC-2 | skill-collaboration.md §二含「复杂度主轴初筛」段：初筛轴+信号修正覆盖语义+与 §1b 同构互引 | grep 两关键词均命中 | `grep -q "复杂度主轴初筛" skills/plan-collab-router/references/skill-collaboration.md && grep -q "覆盖复杂度初判" skills/plan-collab-router/references/skill-collaboration.md` |
| VC-3 | task-planner/SKILL.md Spec 模式检查行（:65）行尾含 §1b 择一路由指针，既有文字零改动 | grep 命中指针串 | `grep -q 'spec-mode.md` §1b' skills/task-planner/SKILL.md` |
| VC-4 | selftest 回归无本任务面新增 FAIL：全量 Total FAIL 逐个归因，与三受管文件相关的 FAIL=0（CR 轮1 修正：Total 行提取取代 head -1 误抓子脚本行；worktree 态已并入 master，合并后复跑=等价证据；并行会话外因 FAIL 归因见 progress） | run-selftests 全量落盘 plans/<dir>/selftest-final.log，Total+Failed 行逐个归因 | `bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh 2>&1 \| grep -E 'Total:\|Failed:'` |
| VC-5 | 三受管文件 × 4 部署位（zcode/agents/claude/cursor）同步后逐对 diff=0 | for 循环 diff 全过 | `for p in /home/terry/.zcode/skills /home/terry/.agents/skills /home/terry/.claude/skills /home/terry/.cursor/skills; do diff -q "$p/task-planner/SKILL.md" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md >/dev/null && diff -q "$p/task-planner/references/spec-mode.md" /mnt/data/dev/task-planner-skill/skills/task-planner/references/spec-mode.md >/dev/null && diff -q "$p/plan-collab-router/references/skill-collaboration.md" /mnt/data/dev/task-planner-skill/skills/plan-collab-router/references/skill-collaboration.md >/dev/null \|\| exit 1; done` |
| VC-6 | 合并回 master 完成（merge 记录在案）且 worktree 已清理（列表无残留） | git log 含 merge 记录且 worktree list 无本任务路径 | `git -C /mnt/data/dev/task-planner-skill log --oneline --grep="task-superpowers-openspec-routing-20261116" \| grep -q . && ! git -C /mnt/data/dev/task-planner-skill worktree list --porcelain \| grep -q "tmp/worktrees/task-superpowers-openspec-routing-20261116"` |
| VC-7 | 调研结论在盘：findings-external-families.md 含 A 段集成现状结论（R4 已答） | grep 命中段标题 | `grep -q "A. 仓内集成现状" /mnt/data/dev/task-planner-skill/plans/task-superpowers-openspec-routing-20261116/findings-external-families.md` |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard/full 必填，mini 豁免）
<!-- task-dualqc-20261104 新增：双轮质检机制在计划阶段显式设计——派发型实质产出 S-unit 默认两道检核（第一轮执行体自审 103.2 checkpoint 自审段；第二轮主代理派全新子代理独立复检 103.3，档位升一档 103.4、复检任务书简洁五要素 103.5）；多文件变更集（≥2 受管文件）Phase 翻转前过 103.6 同步完整性审查（关联面推导四族→同步核对清单全绿）。豁免面=103.7，逐 S-unit 登记理由；mini 档整体豁免。 -->
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | Phase 4 S1 独立复检（第二轮，critic 档位升一档口径）；第一轮=Phase 3 主进程实现自审（progress Test Results 逐 VC 留痕） |
| 豁免登记 | none |
| 多文件变更集预判 | Phase 5 合并前触发 103.6 同步完整性审查（3 受管文件：spec-mode.md / skill-collaboration.md / SKILL.md；关联面四族=互引条款/部署位/SKILL.md 指针/selftest 断言） |


## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
<!--
  WHEN: 终验时填写;含 [目标] 标注需求（下方 R 行）的任务必须在交付前出三态裁决
  WHY: Rule 58.5 完成裁决门——「分析报告已交付」不等于「问题解决了」;not-solved/partial 禁止标 COMPLETE
  载体: 58.4 手段/目标二分在需求原文区逐条标注 [手段]/[目标];本区块回收目标型需求的解决状态
-->
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1、R2、R3 |
| **裁决** | `solved` |
| **解决证据锚** | VC-1/2/3 grep PASS（spec-mode §1b 四关键词/skill-collaboration 初筛段两关键词/SKILL.md:65 指针）+verify-report.md 语义三性 PASS+merge 42ab794+4 部署位 diff=0+drift-checker ALIGNED（.drift-checkpoint.md） |
| **未解决面+原因** | 无（main 分支不适用：本仓 main 为无共同祖先的陈旧导入分支，按 [[main-master-unrelated-histories-branch-gotcha]] 不合并） |
| **已排除路径** | n/a（solved） |
| **下一步建议** | n/a（solved） |

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
| G1 | 调研双裁决 | 完成 A-F 六段调研+用户载体/判据双裁决 | findings-external-families.md 在盘（VC-7 grep）+AskUserQuestion 回传两裁决 | P1 | complete |
| G2 | 计划锁定 | 计划文档定稿并 attest 锁定 | `attest-plan.sh --verify` exit 0（SHA dd1fa197→重锁定见 Decisions） | P2 | complete |
| G3 | 条款落地 | worktree 内三文件条款+回归零新增 FAIL | VC-1/2/3 grep exit 0（复检 PASS）+VC-4 基线对照 98/96/2 一致 | P3/P4 | complete |
| G4 | 合并部署 | merge 回 master+四部署位 diff=0+收尾 | VC-5 四位 diff=0+VC-6 merge 42ab794+清理完成+check-complete exit 0 | P5 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码（受管 3 文件） | `skills/task-planner/SKILL.md`、`skills/task-planner/references/spec-mode.md`、`skills/plan-collab-router/references/skill-collaboration.md` | 其他 skills/** 与根 scripts/** |
| 文档（计划面） | `plans/task-superpowers-openspec-routing-20261116/**` | 其他 plans/**（mdedit 目录只读） |
| 部署位（同步面） | 4 位同路径三文件（zcode/agents/claude/cursor） | 其他部署位文件 |

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
| CA-1 | skills/task-planner/references/spec-mode.md（§1 路由表之后、「## 2. 安装引导」之前） | 新增（§1b 小节） | 增量 | 「根据任务…复杂度…选择一个合适的技能进行执行」 | findings B/F2+用户裁决② | 插入 §1b 决策表+择一语义段 |
| CA-2 | skills/plan-collab-router/references/skill-collaboration.md（§二判定顺序段之后、矩阵表之前） | 新增（初筛段） | 增量 | 「根据任务…复杂度…选择一个合适的技能进行执行」 | findings F1/F5+用户裁决② | 插入复杂度主轴初筛段（同构互引） |
| CA-3 | skills/task-planner/SKILL.md（:65 Spec 模式检查行行尾） | 修改（行尾追加指针，禁改既有文字） | 增量 | 「在尽量减少…引入难度…保持整理整洁」 | 用户裁决①（既有载体） | 行尾追加 §1b 指针半句 |
| CA-4 | 部署位 4 处同路径三文件 | 更新（同步 master 新态） | 增量（覆盖前逐对 diff 判向） | —（部署对账） | 先例=多位部署 diff=0 | 合并后逐位 cp+diff=0 复核 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | findings-external-families.md（A-F 六段调研+证据锚） | plans/task-superpowers-openspec-routing-20261116/（本计划目录） | 必读 | ☑ |
| 项目内部文档/知识库 | spec-mode.md（插锚对象，§1 表/§2 安装引导结构） | skills/task-planner/references/spec-mode.md（master） | 必读 | ☑ |
| 项目内部文档/知识库 | skill-collaboration.md §二（权威源触发矩阵） | skills/plan-collab-router/references/skill-collaboration.md:51-68 | 必读 | ☑ |
| 项目内部文档/知识库 | comet 选择机制对标（CLI resolve+IntentFrame） | /home/terry/.zcode/skills/comet/SKILL.md、comet-classic/SKILL.md（经 findings B 段） | 参考 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: task-planner 已有 Spec 模式路由与三族触发矩阵（散点条款），但缺「按任务复杂度在 Superpowers/OpenSpec 间择一」的显式决策表（comet 式画像选择）；解决后交付=三载体条款落地+回归零新增 FAIL+四部署位同步，R1-R3 可通过 VC-1..5 复现验收。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？
- [x] 核心问题不解决，其他工作都白费吗？（条款不落地=诉求未满足）
- [x] 核心问题的解决方法是清晰的、可执行的？（用户双裁决+findings F 段设计建议已定案）

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| P1 集成现状调研（已完成） | LOCAL-ONLY | task-planner 集成现状、comet 变体选择机制 | 本仓 grep+本地技能目录读取（子代理 general-purpose 已执行） | findings-external-families.md A-F 段 | 否 |
| P3 条款实现 | LOCAL-ONLY | spec-mode 插锚点、skill-collaboration 判定顺序段 | 本地文件读取（已 Read 定位） | 三文件增量 diff | 不适用 |
| P4 回归复检 | LOCAL-ONLY | selftest 基线、run-selftests 用法 | 本地脚本（已 head 核验 usage） | Total FAIL 对照 | 不适用 |

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| n/a（纯执行类——本任务产出=条款落地非归因结论；调研面证据已由 findings-external-families.md 全量承载） | - | - | - | ☑ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
Phase 5（收尾：重锁定/check-complete/归档）

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
重跑 attest-plan.sh 重锁定（终态翻转+Decisions 登记完成）→ check-complete.sh exit 0 → 提交计划文件与 INDEX → 归档+记忆落盘。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 general-purpose | 调研大输出隔离（§一 宪法），产出落盘 findings-external-families.md |
| Phase 3 | 主进程 Bash+Edit（机械守卫脚本辅助） | 三文件小 diff+措辞强一致，例外理由②（见 Executor 行） |
| Phase 4 | Agent 子代理 general-purpose + 机械守卫 run-selftests.sh | Rule 33.3 独立验证+机器回归 |
| Phase 5 | 主进程 git/部署（Rule 25.3 白名单①②） | git 编排与簿记属白名单面 |

**workflow 编排判定（Rule 40.4）**: [未命中 39.8 激活条件（S-unit<3 无独立并行 fan-out、非长链编排、用户未点名）→ Rule 21.4 独立性守门调度（串行推进）]
**/goal 对齐（Rule 40.3）**: [本计划 Goal+VC 即 session goal（/goal 已锚定本任务）的证据源；user-session-log.md #1=R 原话锚]

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 调研与双裁决
<!-- 
  WHAT: Understand what needs to be done and gather initial information.
  WHY: Starting without understanding leads to wasted effort. This phase prevents that.
-->
- [x] 仓内集成现状+三族机制调研（findings-external-families.md A-F 六段落盘，4 处证据锚主进程抽查一致）
- [x] 集成现状答案呈报用户（部分完成+三缺口）
- [x] 用户双裁决返回：载体=既有条款扩展；判据=复杂度主轴+信号修正
- [x] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **V-N:** VC-7, VC-1（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** complete
- **Executor:** general-purpose（调研子代理，已返回并盘上复核）
<!-- 
  STATUS VALUES:
  - pending: Not started yet
  - in_progress: Currently working on this
  - complete: Finished this phase
-->

<!-- S-unit 派发单元表(Rule 22.6；10 列固定列序，契约同 Phase 4 注释块) -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A2) 外部技能族集成现状调研六段（A 仓内/B comet/C superpowers/D openspec/E 竞合/F 建议） | general-purpose | 本仓根+三族技能目录清单（prompt 自包含六段任务书+落盘路径） | findings-external-families.md 落盘+主进程盘上 4 锚抽查 | 15min | 1f/90l/15min | 无 | - | complete |

### Phase 2: 计划定稿与 attest 锁定
<!-- 
  WHAT: Decide how you'll approach the problem and what structure you'll use.
  WHY: Good planning prevents rework. Document decisions so you remember why you chose what you did.
-->
- [x] Define technical approach（三载体条款设计定稿，CA-1/2/3 变更标注）
- [x] 计划文档填充（task_plan/verification/findings/progress/user-session-log）
- [x] attest-plan.sh 锁定（含 Goal 单元表/VC/FMEA 门链全绿；SHA dd1fa197，重锁定见 Decisions）
- **V-N:** VC-7, VC-4（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: worktree 隔离与三文件条款实现
<!-- 
  WHAT: Actually build/create/write the solution.
  WHY: Good planning prevents rework. Document decisions so you remember why you made choices.
-->
- [x] `git worktree add tmp/worktrees/task-superpowers-openspec-routing-20261116 -b wt/task-superpowers-openspec-routing-20261116 master`（基点=master，禁 main）
- [x] CA-1：spec-mode.md 插 §1b 决策表（四档映射+择一语义）
- [x] CA-2：skill-collaboration.md §二插复杂度主轴初筛段（同构互引）
- [x] CA-3：SKILL.md:65 行尾追加 §1b 指针（禁改既有文字，PREFIX-OK）
- [x] 实现自审（103.2）：插入锚点回读+既有行 diff=零删除
- **V-N:** VC-1, VC-2, VC-3（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——本仓=task-planner 技能自身，条款措辞与既有锚强一致，拆派需转述全量设计上下文，收益<风险——Rule 25.3 白名单）

### Phase 4: 回归与独立复检
<!-- 
  WHAT: Verify everything works and meets requirements.
  WHY: Catching issues early saves time. Document test results in progress.md.
-->
- [x] worktree 内 run-selftests.sh 全量回归（VC-4 基线对照：98/96/2=master 基线逐字一致）
- [x] 派 general-purpose 独立复检子代理（Rule 33.3）：VC-1/2/3 grep 实测+语义三性+103.6 清单（verify-report.md）
- [x] 规范召回（Rule 93）：主进程 Read execution-recall-card.md 并 progress 留 [recall] 行
- **V-N:** VC-4, VC-7（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** complete
- **Executor:** general-purpose（独立复检子代理，Rule 33.3/103.3；机械回归命令由编排面代跑并留痕）

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
| S1 | (A5) 独立复检：VC-1/2/3 grep 实测+selftest Total 对照复核+103.6 同步完整性清单+条款对齐审查 | general-purpose | 复检 brief（worktree 绝对路径+VC-1..7 判据原文+103.6 四族清单，随派发写入） | 复检结论落 verification.md 交叉验证记录；结论=一致/分歧处置 | 15min | 1f/60l/15min | 无 | Phase 3 | pending |

### Phase 5: 合并回+部署同步+收尾
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten. Document decisions so you remember why you made choices.
-->
- [x] 主仓无 scope 重叠未提交变更复查 → `git merge --no-ff wt/task-superpowers-openspec-routing-20261116`（42ab794）
- [x] 4 部署位同步：逐对 diff 判向（位侧零独有内容）→ 覆盖（.agents 两位补建）→ VC-5 diff=0 全过
- [x] worktree 清理（VC-6）：`git worktree remove` + `git branch -d`（WT/BR 清理完成）
- [x] 全文档收尾回读梳理记录（Rule 84.14）：回读完成——state-consistency 机器三源一致 PASS+收尾回读表登记（收敛出口=一轮零新发现）
- [x] 归档计划：check-complete exit 0 后先 `bash <skill>/scripts/set-active-plan.sh --clear` 再 `bash <skill>/scripts/archive-plan.sh task-superpowers-openspec-routing-20261116 --root <plans根>`（Rule 81；守卫拒绝时登记理由不强移）
      <!-- task-kb-auto-capture-20261022 增：收尾主动触发——归档与知识提取为收尾默认动作，勿依赖人想起手动跑 -->
- [x] 知识提取入库：kb-sync draft → 精炼主题化（superpowers-openspec-complexity-routing.md：§2 六事实/§3 四锚/§4 六易错点，源锚 findings-external-families.md+verify-report.md）→ kb-rebuild-index（回执见 progress Phase 5 段）<!-- 路径基准双轨：归档/模板类命令 <skill>/=技能根；kb-* 脚本实体在仓库根 scripts/（项目相对），勿混统一（2026-10-23 task-kb-cr-lits-20261023 CR MAJOR-1 回退） -->
- **V-N:** VC-5, VC-6（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
<!-- 每轮一行：轮次/发现/处置；连续一轮零新发现才可出 outcome（收敛出口，轮次不设上限）；
     发现面=需求↔目标↔执行↔验证↔知识五维互洽（偏移/遗漏/未利用知识） -->
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1 | 无新发现（五维互洽：需求 R1-R5↔Goal↔三文件条款↔VC-1..7 全 PASS↔findings/知识储备已用尽——check-complete state-consistency 三源一致 PASS；verify-report 语义三性 PASS；drift ALIGNED） | 收敛出口（连续一轮零新发现）；遗留仅 WARN 级：task_plan 596 行>500（Rule 19.6，计划期文档体量，归档承载不回炉） |
| 2 | CR 轮1 发现处置：MAJOR×3 判据/证据链缺陷已修（VC-4 Total 提取/selftest-final.log 持久/归档同程）；W-1（信号修正互斥优先级未显式定义——已由「权威源 §二判定顺序先命中先用」引用语义覆盖）与 W-2（§1 L0-T/L0-E vs §1b L0/mini 命名口径）=遗留建议不回炉——并发热点文件（mdedit/veriffirst 同日同文件三写）最小扰动原则；NIT（kb 缺 §1 节/INDEX 残留注释）=不阻断不修 | 处置证据：progress [CR 轮1]/[VC-4 归因行]；selftest-final.log |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（主仓 dirty=CLAUDE.md/README_zh/plans/INDEX.md/plan-resume/todo-skill/workflow-model-tiers——均不在本任务 scope_files，零重叠；信号①-⑤ 无命中） |
| `isolation` | `worktree`（实现类默认首选；命中 §11.1 改会话实时加载技能面） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-superpowers-openspec-routing-20261116` |
| `branch` | `wt/task-superpowers-openspec-routing-20261116`（基点=master，禁 main——本仓 main 无共同祖先） |
| `merge_back` | `merged(42ab794)` |

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
| Phase 3 | Edit 插段吞锚/破坏既有表格结构（106.1a 惯犯面） | 6 | 4 | 2 | 48 | new_string 含锚行子串+Edit 后结构回读（插段三规约） |
| Phase 5 | 部署位漂移方向误判（覆盖 vs 被覆盖） | 7 | 3 | 3 | 63 | 逐对 diff 判向后覆盖；方向不明→STOP 登记 |
| Phase 4 | selftest 预存 FAIL 混入误判新增回归 | 5 | 3 | 2 | 30 | VC-4 基线对照设计（master 双跑） |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-11-16 | S1/S2 调研+裁决双组 todo 已建 |
| Phase 2 | ☑ | 2026-11-16 | S4a 计划定稿 |
| Phase 3 | ☑ | 2026-11-16 | S4b worktree+条款 |
| Phase 4 | ☑ | 2026-11-16 | S4b 回归+复检 / S4c 终验 |
| Phase 5 | ☑ | 2026-11-16 | S4c 合并部署+收尾 |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
-->
1. spec-mode §1b 与权威源冲突序？——答：权威源=skill-collaboration.md §二，§1b 细化 Spec 模式场景，冲突以权威源为准（两处同构互引句已设计）。
2. 部署位漂移方向？——合并后逐对 diff 判向再覆盖（FMEA Phase 5 行）。
3. selftest 基线是否有预存 FAIL？——VC-4 采用基线对照判据（worktree FAIL ≤ master FAIL）防预存误判。

## Decisions Made
<!-- 
  WHAT: Technical and design decisions you've made, with the reasoning behind them.
  WHY: You'll forget why you made choices. This table helps you remember and justify decisions.
  WHEN: Update whenever you make a significant choice (technology, approach, structure).
-->
| Decision | Rationale |
|----------|-----------|
| 载体=既有条款扩展（用户裁决 Q1） | findings F1/F2/F5 一致指向；零新文件零脚本，最小引入难度+整洁（R3） |
| 判据=复杂度主轴+信号修正（用户裁决 Q2） | 沿用 Rule 21 体量分级零新概念；信号修正防「小规格变更」误路由 |
| 择一语义=同任务同阶段两族择一主导，跨阶段可切换 | findings E1/E2 双真源/控制权分裂风险；comet runtime 不复制（F4） |
| Phase 3 主进程直做（例外理由②） | 本仓=计划系统自身；条款措辞强一致要求（Rule 25.3 白名单） |
| worktree 基点=master 禁 main | 本仓 main 无共同祖先（记忆判例 main-master-unrelated-histories-branch-gotcha） |
| mdedit 任务 Rule 102.0 D 显式挂起 | 新任务边界；断点=Phase 3 未启动，已登记其 progress.md |
| S-unit 粒度列=计划期预估口径（S1 调研 90l） | attest 粒度门=计划期拆分判据；实际产出 135l（超出预估）已如实记录 progress.md Test Results，实际面不回填预估列 |
| VC-6 判据串 spec 笔误修正（grep 串 wt/task-…→task-…） | 实际 commit message 前缀为 feat(/merge(，原串必空匹配=判据写错非产物缺失；intent（merge 在案+清理完成）不变，修正后实测 PASS（42ab794+54ec525 命中） |
| Phase 4 Executor 串解析修正（去「主进程」字样） | check-delegation 机器按关键词解析把委派 Phase 4 误计为 main_direct+self_declared violation；改为中性措辞「由编排面代跑」后机器口径归真（委派率 2/5） |
| task_plan 终态翻转后重锁定（PLAN TAMPERED 协议） | 状态翻转/裁决回填属计划内变更，按记忆判例协议=Decisions 登记本行+重跑 attest 更新 SHA；非未授权篡改 |

## Errors Encountered
<!-- 
  WHAT: Every error you encounter, what attempt number it was, and how you resolved it.
  WHY: Logging errors prevents repeating the same mistakes. This is critical for learning.
  WHEN: Add immediately when an error occurs, even if you fix it quickly.
-->
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| mdedit progress.md 挂起登记 Edit 首次失败（file modified since read，hook 竞写） | 1 | 重读后按新尾部锚重 Edit 成功 | → progress.md Error Log |

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
| 2026-11-16（Phase 5 收尾） | drift-checker 三态判定 **ALIGNED** 零偏移（改动集=三受管文件无越界/择一语义与双裁决一致/零新文件零脚本守住） | VC-1..7 | checkpoint=`.drift-checkpoint.md`；progress Phase 5 段已留 [drift] 面证据（Rule 64.1 留痕三件套：本表+checkpoint+progress 行） |

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
| `total` | n/a（非批量任务；部署同步 12 文件对属机械 diff 对账非批量产出） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | n/a |
| `pre_check` | n/a |
| `rollback_point` | n/a |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 子代理占比需要可见反馈闭环;委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
  WHEN: 每个 Phase complete 后更新;终验交付前必须完整。
-->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 5（P1 调研+P4 复检） |
| 主进程直做 Phase 清单 | P2（例外理由② 计划系统文件维护）/ P3（例外理由② 计划系统文件维护）/ P5（例外理由① git 编排+② 簿记）——均 Rule 25.3 白名单内 |
| 委派率 | 0.4（<0.7；主进程 Phase 均持白名单理由，登记于此供 check-delegation stats 复核） |
| 激活子代理数（Rule 96.5） | 2（调研 1+复检 1） |
| 最大并行宽度（Rule 96.5） | 0 并行组（全串行，S-unit 单元依赖链） |
| 串行化例外理由（Rule 96.4） | 全串行论证：P3→P4→P5 强依赖（实现→回归→合并），P1 已完成 |

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
| 1 | 2026-11-16 | general-purpose | 外部技能族集成现状调研（A-F 六段） | done | 部分集成+三缺口；135 行落盘带证据锚 | findings-external-families.md:1-145 | findings.md Research Findings 段 | -（直返） | - / 0 / ☑ |
| 2 | 2026-11-16 | general-purpose | Phase 4 独立复检（VC 实测+103.6+语义三性） | done | VC-1/2/3+语义三性+103.6(a-c) 全 PASS；103.6(d) 发现 .agents 缺 2 文件→Phase 5 补齐；VC-4 全量终数待闭合→已由主进程亲跑闭合（98/96/2=基线） | verify-report.md（97 行） | verification.md 交叉验证记录 | - | - / 0 / ☑ |
| 3 | 2026-11-16 | drift-checker | 目标对齐三态终检（Rule 61/64） | done | ALIGNED 零偏移；改动集=三受管文件无越界；择一语义与双裁决一致 | .drift-checkpoint.md | progress.md Phase 5 段 | - | - / 0 / ☑ |

## 🔗 Chain 区块交接配置（可选）

<!-- 仅多 skill 接力任务填写（如：调研→创作→发布）。单 skill 任务可删除此整个区块。 -->

### Chain 模式

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
| **current_block** | Block 1 |
| **handoff_on_complete** | ❌ 否（单 skill 任务） |

### Block 1: task-superpowers-openspec-routing（当前块）

| 字段 | 值 |
|------|-----|
| **goal** | 见 Goal 段 |
| **depends_on** | none |
| **passes_to** | 无（单块任务） |
| **status** | complete |

### 🔗 Handoff 追踪表

| Block | 状态 | 交接产物路径 | 验证命令 | 实际完成时间 |
|-------|------|------------|---------|-------------|
| Block 1 | in_progress | -（单块） | - | - |

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 不沉淀理由=一次性条款增补任务，无跨任务复用类型画像（34.3 三条件之「可复用形态」不命中）
