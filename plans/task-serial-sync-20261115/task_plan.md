# Task Plan: 根治序列创作知识同步缺陷
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} token 由 init-session.sh render_template() 脚本渲染（task-id/任务名/日期/路径）；尖括号中文占位=模型填写面，脚本禁碰 -->
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  选定 variant 后 template_type 填所选类型名（白名单=/mnt/data/dev/task-planner-skill/skills/task-planner/templates/variant/*-type.md 动态派生，见 check-template-type.sh）；general=通用回退（恒合法，Rule 34.1）
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

- **R1**: 「当前项目skill 存在问题 就是执行过程没有解决跨文件或者或者比如写小说 跨章节 的理解以及知识设定同步  当前存在  写剧本 上一集知识到下一集丢了 这是严重的缺陷」<sub>（[目标]）</sub>
- **R2**: 「如果在写新的一集之前阅读之前剧集内容也不会反这种低级错误 所有说明当前skill执行严重缺陷」<sub>（[手段]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1、VC-2、VC-3 | 知识设定同步条款在权威载体+派发/执行/验收链 grep 可命中（命令计数≥1）；selftest 零新增 FAIL |
| R2 | VC-1、VC-4 | 「写新单元前强制回读前序产出」条款在位（grep 锚命中）；合并回主仓后 Read 复验一致 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/task-serial-sync-20261115/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/task-serial-sync-20261115/user-session-log.md`（模板 = /mnt/data/dev/task-planner-skill/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 派发面（任务书契约） | 下一单元任务书只含本单元要求，不带前序单元产出路径与知识台账路径（Phase 1 实测确认） | 派发契约条款：序列任务任务书必附前序产出+台账绝对路径 | VC-2 |
| 执行面（写作执行体） | 执行体首动作无强制回读前序产出与台账的纪律 → 上一集知识丢失 | 执行纪律条款：动笔前强制回读（首动作=Read） | VC-1 |
| 沉淀面（单元完成时） | 单元完成后无「新增设定/事实/伏笔/时间线」台账沉淀义务，知识无介质可传 | 台账沉淀条款：单元完成必须更新序列知识台账 | VC-1 |
| 验收面（QC） | 单元产物验收无与台账的一致性核对 → 设定冲突漏出 | 验收条款：QC 对照台账一致性检查 | VC-1 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | ① Goal 行原文；② R1/R2 用户原话逐字；③ VC-1~VC-5 判定标准；④ 修复核心=三环闭环（台账沉淀/动笔回读/验收一致性）；⑤ scope_files 与禁碰清单（plan-resume/todo-skill/workflow-model-tiers 三 SKILL.md 不碰）；⑥ new_rule=107 | Goal 行/需求原文区/VC 表/核心问题定义/执行范围限制/CR 配置表 |
| 🔀 可变量 | 执行细节/S-unit 拆分粒度/条款子条措辞（Phase 2 终稿）/纪元面拆行数/部署位清单 | - |
| 📈 学得量 | Phase 1 实测事实（命中清单/基线 FAIL 数/纪元面清单）→findings.md；禁反向改写不变量 | findings.md |
| 📈 学得量 | <执行期新事实/教训/锚点→findings.md/notepad-learnings.md；禁反向改写不变量> | findings.md |

## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and delete functionality."
-->
在技能规范层根治序列创作（多集剧本/多章小说等跨单元连续创作）的知识设定同步缺陷：单元 N+1 动笔前强制回读前序单元产出与知识台账、单元 N 完成时强制沉淀台账、验收对照台账一致性——使「上一集知识丢失」在机制上不可能发生。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（规范文本条款修改非代码组；质量门=selftest 回归+双轮质检） |
| `session_id` | `26352834520f4ca1800682ec4e114084` | 启动时生成,注册表追踪 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-serial-sync-20261115` | §十一 隔离决策已有字段 |
| `scope_files` | `skills/task-discipline/references/critical-rules-discipline.md; skills/task-dispatch/references/critical-rules-dispatch.md; skills/media-planner/references/critical-rules-media.md; skills/task-planner/references/critical-rules.md; skills/task-planner/SKILL.md; skills/task-planner/templates/subagent_dispatch.md; skills/task-planner/scripts/selftest-enumerate-first.sh; 纪元锚级联面（Phase 1 实测清单）` | 从「执行范围限制」解析,并发检测基础 |
| `interaction_mode` | `ask` | Rule 28 交互模式：ask=关键决策点给选项；本任务 skills 修改授权门=D6 硬停点不自动通过 |
| `对齐审查` | `登记：收尾跑 alignment-review（标准收尾流程）` | Rule 42.6 消费 |
| `自动超时默认项` | `计划确认（skills 修改授权门）=D6 硬停点禁自动通过；其余询问点默认=推荐项/5min` | Rule 44 消费（44.3）；skills 修改属破坏面授权门 |
| `new_rule` | `107` | Rule 20.6：attest 自动预留+查重（账本实测 105/106 已 land，2026-11-15） |
| `质量审查工具` | `既有工具复用：general-reviewer（独立复检 103.3）+run-selftests.sh 机器面；42.2 检测结论=无缺口` | Rule 42 消费登记（42.4） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

<!--
  WHAT: 任务执行完毕 ≠ 目标完成。此表确保每一步有可验证证据。
  RULE: 每个 phase 完成后对照 VC 编号复验；phase 全部 complete ≠ 通过终验。
  FORMAT: VC-N 是客观判定标准（可测试/可追溯/不依赖主观判断）。
  V-N: goal-gate.md 规定「≥5 条 VC + 每 phase ≥2 条 V-N（映射到 VC 编号）」；
       在每个 Phase 段（`### Phase N` 的 - **Status:** 行前）补 `- **V-N:**` 占位行，
       填写本 Phase 验收映射的 VC 编号（≥2 条，如 `VC-1, VC-2`；对应逐条验收记录在
       /mnt/data/dev/task-planner-skill/skills/task-planner/templates/verification.md 的 `V-N.N` 项，映射目标须为已定义 VC 编号）。
       check-complete.sh 终验 VC-GATE 段机械校验（config.json vc_gate_enforce，默认 warn）。
-->

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 107「序列创作知识同步纪律」条款全文（台账沉淀/动笔回读/派发必附/验收一致性 ≥4 子条）在权威载体逐字在位 | grep 锚计数 | `grep -c '序列创作知识同步' skills/task-discipline/references/critical-rules-discipline.md` ≥1 且 107.x 子条锚行 ≥4（worktree 内执行，合并回后主仓复跑） |
| VC-2 | 派发面+媒体面级联条款在位（序列任务书必附前序产出与台账绝对路径；媒体轴指针） | grep 命令 | `grep -c '前序产出' skills/task-dispatch/references/critical-rules-dispatch.md skills/media-planner/references/critical-rules-media.md` 各 ≥1 |
| VC-3 | 全量 selftest 失败脚本数 ≤ worktree 编辑前基线（动态阈值，判据=Total 行 FAIL 值解析） | 运行 selftest runner | `bash -c 'bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh > /tmp/serialsync-selftest.log 2>&1; test "$(sed -n "s/^Total: .* FAIL=\([0-9]*\).*/\1/p" /tmp/serialsync-selftest.log | tail -1)" -le "$(cat /tmp/serialsync-st-baseline.count)"'`（worktree 编辑前基线=2：active-plan+execution-stability 预存；主仓 3 含在途改动；findings §Technical Decisions） |
| VC-4 | 合并回主仓后 scope 文件无未提交变更且 Rule 107 段 Read 复验一致 | git status + Read | `git status --short -- skills/` 仅含预期状态；主仓 Read 关键文件与 worktree 版一致 |
| VC-5 | 部署位同步 diff=0 且 check-complete exit 0+归档完成 | diff+门脚本 | 部署位 `diff -r` 输出为空；`bash skills/task-planner/scripts/check-complete.sh plans/task-serial-sync-20261115` exit 0 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard/full 必填，mini 豁免）
<!-- task-dualqc-20261104 新增：双轮质检机制在计划阶段显式设计——派发型实质产出 S-unit 默认两道检核（第一轮执行体自审 103.2 checkpoint 自审段；第二轮主代理派全新子代理独立复检 103.3，档位升一档 103.4、复检任务书简洁五要素 103.5）；多文件变更集（≥2 受管文件）Phase 翻转前过 103.6 同步完整性审查（关联面推导四族→同步核对清单全绿）。豁免面=103.7，逐 S-unit 登记理由；mini 档整体豁免。 -->
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | Phase 3 全部派发型 S-unit（条款文本写入=实质产出，103.2 自审+103.3 独立复检） |
| 豁免登记 | Phase 4 S1（复检体本身即独立验证，免第三检）；Phase 1 探索类（产出=findings 结论，主进程 Read 复核即第二检） |
| 多文件变更集预判 | Phase 3（级联面 ≥2 受管文件）→ Phase 翻转前过 103.6 同步核对清单全绿 |


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
| G1 | 侦察缺口清单 | 全量枚举扫描+执行链定位产出缺口清单落 findings | findings.md §Research Findings 含命中清单（文件:行）+缺口判定 | Phase 1 | complete |
| G2 | 条款定稿 | Rule 107 条款文本+传播面清单+变更标注表定稿并经用户确认 | findings §Technical Decisions 条款终稿+用户 yes 留痕（user-session-log #3） | Phase 2 | complete |
| G3 | worktree 实施 | 权威载体+级联面条款全部落地 | VC-1/VC-2 grep 命令在 worktree 内通过 | Phase 3 | complete |
| G4 | 回归绿 | selftest 零新增 FAIL | VC-3 命令输出（progress.md 轮次行） | Phase 4 | complete |
| G5 | 合并部署收口 | merge back+部署 diff=0+check-complete+归档 | VC-4/VC-5 命令输出 | Phase 5 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规范文本 | skills/task-discipline/references/critical-rules-discipline.md、skills/task-dispatch/references/critical-rules-dispatch.md、skills/media-planner/references/critical-rules-media.md、skills/task-planner/references/critical-rules.md（实测 no-op：全集索引不逐条列举，Phase 1 grep 零命中）、skills/task-planner/SKILL.md、skills/task-planner/templates/subagent_dispatch.md（CA-6，用户批准五载体）、skills/task-planner/scripts/selftest-enumerate-first.sh（纪元锁步）、纪元锚级联面（Phase 1 实测清单） | 列表外任何 skills/** 文件 |
| 测试 | skills/task-planner/scripts/selftest-enumerate-first.sh（纪元锚锁步）+其他 selftest 仅 FAIL 锁步修复（禁新增守卫脚本，宪法 §二 文本优先铁律） | 新增 selftest/守卫脚本 |
| 文档 | plans/task-serial-sync-20261115/** | 其他 plans/ 目录 |
| 禁碰清单 | 主仓未提交变更文件（skills/plan-resume/**、skills/todo-skill/SKILL.md、skills/workflow-model-tiers/SKILL.md）=他任务在途 | 任何 git 暂存/提交捎带上述文件 |

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
| CA-1 | skills/task-discipline/references/critical-rules-discipline.md（规则段末尾） | 新增 Rule 107 全文 | 增量 | R1/R2 | Phase 1 缺口清单 | worktree 内插段+结构回读（Rule 106.1a） |
| CA-2 | skills/task-dispatch/references/critical-rules-dispatch.md（派发契约段） | 新增序列任务契约条款 | 增量 | R1/R2 | Phase 1 缺口清单 | worktree 内插段+结构回读 |
| CA-2b | skills/media-planner/references/critical-rules-media.md（Rule 47 家族） | 新增序列创作指针条款 | 增量 | R1 | Phase 1 缺口清单 | worktree 内插段 |
| CA-3 | skills/task-planner/references/critical-rules.md + skills/task-planner/SKILL.md | 全集索引/路由表行更新 | 增量 | R1 | 级联 SOP（卫星索引表行先例） | worktree 内更新 |
| CA-4 | 纪元锚级联面（grep 实测 2 文件：selftest-enumerate-first.sh+task-planner/SKILL.md） | 1-106→1-107 更新 | 修改（锁步） | R1 | grep 实测 2026-11-15 | grep 四形态族核对 |
| CA-5 | skills/task-planner/scripts/selftest-*.sh（仅 FAIL 命中时） | 既有断言锁步修复 | 修改 | R1 | selftest 回归 | 禁新增守卫脚本 |
| CA-6 | skills/task-planner/templates/subagent_dispatch.md（§2 输入段材料包行后） | 新增序列回读输入行 | 增量 | R1/R2 | Phase 2 锚点定位（§2:29 后） | worktree 内插一行 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | critical-rules-discipline.md（Rule 57/62/84 既有纪律形态参照，Rule 107 落点） | /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md | 必读 | ☐ |
| 项目内部文档/知识库 | critical-rules-dispatch.md（派发契约/A 类别码表/粒度门） | /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md | 必读 | ☐ |
| 项目内部文档/知识库 | critical-rules-media.md（Rule 47 媒体轴拆分家族，级联面） | /mnt/data/dev/task-planner-skill/skills/media-planner/references/critical-rules-media.md | 必读 | ☐ |
| 项目内部文档/知识库 | worktree-isolation.md（合并回合约） | /mnt/data/dev/task-planner-skill/skills/task-planner/references/worktree-isolation.md | 参考 | ☐ |
| 项目内部文档/知识库 | 规则预留账本（新号=107 依据） | /mnt/data/dev/task-planner-skill/plans/.rule-reservations.jsonl（105/106 已 land） | 参考 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 序列创作（跨集/跨章）执行链缺少「前置回读+台账沉淀+验收一致性」三环闭环——下一单元派发与执行只携带本单元要求，前序单元的知识设定无处可传也无纪律可依，导致上一集知识丢失；在技能规范文本层补齐三环闭环后，修复后的技能规范即可交付。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（能——规范条款落地+回归绿即交付）
- [x] 核心问题不解决，其他工作都白费吗？（是——本任务唯一目标即此闭环）
- [x] 核心问题的解决方法是清晰的、可执行的？（是——三条款设计方向明确，Phase 1 实测落点）

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| Phase 1 全部 S-unit | LOCAL-ONLY | 回读/上一集/前序产出/跨章/跨集/设定台账/continuity/续写 | 本仓 grep 全量枚举+Explore 子代理（Rule 105） | findings.md 命中清单+缺口判定 | 不适用 |

> 豁免声明：本任务为仓库内规范工程，全部 S-unit 均 LOCAL-ONLY（无网络调研需求，Rule 75.1 豁免登记）。

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 现有规则文本/派发契约/媒体轴条款（Phase 1 盘点命中面） | grep 全量枚举+Explore 通读 | findings.md §Research Findings | ☐ |
| ② 对标样本（58.2 强制） | 同仓既有同类闭环纪律先例：Rule 57 迭代轮次落盘、Rule 62 四文件罗盘、Rule 84 验证链（同为闭环纪律设计参照） | Read 既有条款设计形态 | findings.md §Technical Decisions | ☐ |
| ③ 外部约束 | 无外部平台约束（纯内部规范工程） | n/a | n/a | ☐ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
Phase 5

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
Phase 5 合并回与收口：smart-merge-back --deploy 合并回主仓+部署位 → 主仓 Read 复验+部署 diff=0 核对 → 84.14 收尾回读 → check-complete → 归档

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 Explore(haiku)（A3 搜索定位） | 全量枚举+执行链定位属跨多文件搜索，隔离主上下文（§一） |
| Phase 2 | 主进程（决策域白名单） | 条款文本设计定稿属设计裁决，产出仅计划文档与草案 |
| Phase 3/4 | Agent 子代理 general-coder(sonnet-1)（52.1 中等编码）/general-reviewer（A5 验证） | worktree 内文本插入；独立验证视角（Rule 33.3） |
| Phase 5 | 主进程（git 编排+部署簿记白名单） | worktree 合并回/部署位同步 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 激活条件（Phase 间串行依赖强、独立并行 S-unit <3）→ Rule 21.4 独立性守门调度（并行默认+声明制）
**/goal 对齐（Rule 40.3）**: 未使用 /goal 命令；本计划 Goal+VC 即本会话目标锚，执行期对照不复述

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
- [x] 全量枚举扫描（Rule 105）：关键词族（回读/上一集/前序/前情/跨章/跨集/设定台账/continuity/续写/上一章）遍历 skills/**，产出命中文件+条款摘录清单
- [x] 定位序列创作执行链：派发契约（task-dispatch）、媒体轴（media-planner Rule 47 家族）、写作执行体面、模板/变体面
- [x] 缺口判定：现有条款对「回读+台账沉淀+验收一致性」三环的覆盖面 → 缺口清单
- [x] 实测定案：run-selftests.sh 在 master 的基线 FAIL 数；纪元锚四形态族精确清单（回填 VC-3 基线值）
- [x] 结论落 findings.md（Research Findings+Issues）
- [x] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **V-N:** VC-1, VC-2（Phase 1 产出缺口清单与落点事实，为 VC-1/VC-2 提供落点依据）
- **Status:** complete
- **Executor:** Explore（A3 搜索定位；haiku 档）

<!-- S-unit 派发单元表(Rule 22.6 — Executor≠主进程的 Phase 必填) -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A3) 关键词族全量枚举扫描 skills/** 产出命中文件+条款摘录清单 | Explore(haiku) | 关键词族清单+repo 根 /mnt/data/dev/task-planner-skill；只读侦察 | findings.md Research Findings 含命中清单（文件:行+摘录） | 10min | 0f/0l/10min | 无 | - | complete |
| S2 | (A3) 执行链定位+缺口判定+selftest 基线与纪元面实测 | Explore(haiku) | S1 命中清单（findings.md 锚）+dispatch/media/discipline 三文件绝对路径 | findings.md 含缺口清单+runner 基线 FAIL 数+纪元面清单 | 10min | 0f/0l/10min | 无 | S1 | merged（S1 报告覆盖+主进程白名单②机械实测；findings §Research Findings） |
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
- [x] 基于 Phase 1 缺口清单设计 Rule 107「序列创作知识同步纪律」条款文本（≥4 子条：台账沉淀/动笔回读/派发必附/验收一致性）
- [x] 定稿传播面清单（权威载体+级联面+纪元面）与变更标注表终稿（Rule 74.3d 先标注后执行）
- [x] 条款草案展示用户确认（§六 技能文件修改授权门，D6 硬停点）→ 用户 #3 yes 批准
- [x] Document decisions with rationale（findings §Technical Decisions 条款终稿五载体全文）
- **V-N:** VC-1, VC-2（条款文本定稿即 VC-1/VC-2 的内容蓝本，落点经 Phase 1 实测）
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单；条款设计与定稿属计划文档域，产出仅 findings/task_plan 条款草案，不触 skills 文件）

### Phase 3: Implementation
<!-- 
  WHAT: Actually build/create/write the solution.
  WHY: This is where the work happens. Break into smaller sub-tasks if needed.
-->
- [x] git worktree add /mnt/data/dev/task-planner-skill/tmp/worktrees/task-serial-sync-20261115 -b wt/task-serial-sync-20261115 master（§十一；建后对账主仓 HEAD）
- [x] worktree 编辑前基线采集（主进程机械执行）：`bash <worktree>/skills/task-planner/scripts/run-selftests.sh > /tmp/serialsync-st-before.log 2>&1; grep -cE 'FAIL' /tmp/serialsync-st-before.log > /tmp/serialsync-st-baseline.count`（执行时判据升级为 Total 行 FAIL 值解析，基线=2）
- [x] 按 S-unit 派发 general-coder 于 worktree 内落条款；每单元返回后 Read 复核+findings 回填
- [x] 规范召回（Rule 93）：每 3 个 S-unit/Phase 翻转主进程 Read ../task-discipline/references/execution-recall-card.md 并 progress 留 [recall] 行；压缩/恢复后第一动作
- **V-N:** VC-1, VC-2（worktree 内 grep 锚命中）
- **Status:** complete
- **Executor:** general-coder（sonnet-1）（52.1 中等编码；派发 prompt 自带 worktree 绝对路径，禁触碰主仓未提交文件）

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
| S1 | (52.1) Rule 107 条款全文落入 skills/task-discipline/references/critical-rules-discipline.md | general-coder(sonnet-1) | 条款终稿（findings §Technical Decisions）+worktree 绝对路径 | grep '序列创作知识同步' 命中≥1 且 107.x 锚≥4（VC-1 命令） | 15min | 1f/80l/15min | 无 | Phase 2 | complete |
| S2 | (52.1) 派发面+媒体面级联条款（dispatch 契约+media Rule 47 家族） [parallel-group:impl] | general-coder(sonnet-1) | 条款终稿+两文件绝对路径 | grep '前序产出' 两文件各≥1（VC-2 命令） | 15min | 2f/60l/15min | 无 | Phase 3 S1 | complete |
| S3 | (52.1) 索引/纪元面更新（全集索引+SKILL.md 路由行+纪元锚 1-106→1-107，实测 2 文件） [parallel-group:impl] | general-coder(sonnet-1) | 条款终稿+纪元面清单（findings） | grep -rl '1-107' 命中且 '1-106' 残留=0（plans/ 除外） | 15min | 2f/40l/15min | 无 | Phase 3 S1 | complete |

> 纪元面 Phase 1 实测若超 2 文件，按 ≤2 文件/单元扩展拆行（attest 前回炉登记，Rule 59.1）；S2/S3 同依赖 S1 且改不同文件 → [parallel-group:impl]（Rule 96.3/96.4 同消息并发派发）。

### Phase 4: Testing & Verification
<!-- 
  WHAT: Verify everything works and meets requirements.
  WHY: Catching issues early saves time. Document test results in progress.md.
-->
- [x] worktree 内跑全量 selftest（runner=run-selftests.sh）→ 轮次/命令/结果/关键输出落 progress.md（Rule 57 迭代落盘）
- [x] FAIL 属旧断言措辞失配 → 锁步修复既有断言（禁新增守卫脚本，宪法 §二 文本优先铁律）→ 重跑至 master 基线一致
- [x] VC-1/VC-2 独立复验（复检体 general-reviewer，103.3；复检全文回读被改文件 103.3a）
- [x] Document test results in progress.md
- **V-N:** VC-3, VC-1, VC-2
- **Status:** complete
- **Executor:** general-reviewer（sonnet-1）（A5 独立验证；Rule 33.3 验证独立性）

<!-- Executor≠主进程的 Phase 必附 S-unit 表（Rule 22.6；模板 CA-3 判例 task-tpl-verify-fix-20261113） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A5) 独立复验：worktree 全量 selftest+VC 命令逐条执行，PASS/FAIL 清单落 verification.md | general-reviewer(sonnet-1) | worktree 绝对路径+verification.md V-N 命令清单 | verification.md V-N.N 逐条带命令输出与证据路径 | 15min | 0f/0l/15min | 无 | Phase 3 | complete |
| S2 | (A6) FAIL 锁步修复（条件触发：仅旧断言措辞失配） | general-coder(sonnet-1) | S1 FAIL 清单 | 重跑 selftest 至 master 基线一致（progress.md 轮次行） | 15min | 2f/30l/15min | 无 | Phase 4 S1 | complete |

### Phase 5: Delivery
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [ ] worktree 全 VC 复验+git status 干净 → `bash skills/task-planner/scripts/smart-merge-back.sh /mnt/data/dev/task-planner-skill/tmp/worktrees/task-serial-sync-20261115 --deploy` → 清理 worktree/分支 → 主仓 Read 复验（§十一 合约）
- [ ] 部署位同步核对（--deploy 覆盖面外的卫星技能文件级 cp+diff=0，先例=task-trashcan/task-subagent-markup）
- [ ] Review all output files
- [ ] Ensure deliverables are complete
- [ ] Deliver to user
- [ ] 全文档收尾回读梳理记录（Rule 84.14）：全量回读六文档体系→五维互洽→偏移迭代→收敛出口（连续一轮零新发现）后才出 outcome
- [ ] 归档计划：check-complete exit 0 后先 `bash <skill>/scripts/set-active-plan.sh --clear` 再 `bash <skill>/scripts/archive-plan.sh task-serial-sync-20261115 --root <plans根>`（Rule 81；守卫拒绝时登记理由不强移）
      <!-- task-kb-auto-capture-20261022 增：收尾主动触发——归档与知识提取为收尾默认动作，勿依赖人想起手动跑 -->
- [ ] 知识提取入库（条件式：项目存在 scripts/kb-sync-from-plan.sh 知识库机制则必做；不存在则登记「跳过：无知识库机制」）：`bash scripts/kb-sync-from-plan.sh <plan-dir>` 生成 draft → 精炼改名（去 _draft- 前缀、补行号锚、主题化去重）→ `bash scripts/kb-rebuild-index.sh`；条目规范见 knowledge/README.md（项目级 knowledge-brief.md §7 入库回链段，若有）<!-- 路径基准双轨：归档/模板类命令 <skill>/=技能根；kb-* 脚本实体在仓库根 scripts/（项目相对），勿混统一（2026-10-23 task-kb-cr-lits-20261023 CR MAJOR-1 回退） -->
- **V-N:** VC-4, VC-5
- **Status:** pending
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
<!-- 每轮一行：轮次/发现/处置；连续一轮零新发现才可出 outcome（收敛出口，轮次不设上限）；
     发现面=需求↔目标↔执行↔验证↔知识五维互洽（偏移/遗漏/未利用知识） -->
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1 | 五维互洽检查（需求↔目标↔执行↔验证↔知识）：R1/R2 逐字锚↔Goal/VC 映射齐备；五 Phase 执行与计划一致（S2 合并/CA-6 直补/DQ-08 锁步三处偏差均已登记）；V-1.1→V-5.1 全 PASS 有证据锚；knowledge-brief 五段终稿已回填；VC-5 收尾动作（check-complete+归档+kb 入库）为轮内进行时 | 零新发现 → 收敛出口达成（连续一轮零新发现），可出 outcome |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号① 6 文件未提交/信号③ 遗留 wt 分支 1/信号④ 10 未完成任务/信号⑤ 运行中基础设施 4 文件；未提交文件与本任务 scope 零重叠已核对） |
| `isolation` | `worktree`（实现类+运行中基础设施，§十一 强制） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-serial-sync-20261115` |
| `branch` | `wt/task-serial-sync-20261115` |
| `merge_back` | `pending` |

> 契约详见 `/mnt/data/dev/task-planner-skill/skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 /mnt/data/dev/task-planner-skill/skills/task-planner/references/methodology.md §R2）

<!--
  WHAT: 对每个 Phase 枚举失败模式，打 S(严重度)/O(频度)/D(探测难度) 各 1-10 分，RPN=S×O×D。
  WHY: RPN>100 的高风险 Phase 必须预先登记兜底动作（对齐 Rule 22.3 五档兜底链，task-v113 后含 22.3.0 资料先行档），避免执行期临时决策。
  WHEN: 计划创建时填写（高 RPN 项）；纯文档/调研类小任务可写 n/a。
  开关键: config.json#fmea_enforce（默认 warn；enforce 档下 RPN>100 无兜底登记 = 计划无效）。
-->

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | 关键词族漏扫（枚举不全）→ 缺口清单失真 | 7 | 4 | 4 | 112 | ①关键词族先清单化（Rule 105）+Explore 任务书内联词表；②主进程抽检 grep 对照（22.3② 拆细档） |
| Phase 3 | 级联面漏改（纪元/索引隐藏面漏改） | 8 | 5 | 5 | 200 | ①Phase 1 全量枚举清单驱动 ②103.6 同步核对清单四族推导全绿才翻转 ③漏改门=Rule 103.6 关联面四族 |
| Phase 4 | selftest 旧断言与新增文本失配 | 6 | 5 | 3 | 90 | 锁步修复既有断言（先例=task-v164「selftest 是旧措辞的机器契约须锁步」） |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-11-15 S2 翻转 complete+drift ALIGNED+3file PASS | complete |
| Phase 2 | ☑ | 2026-11-15 S2 翻转 complete+条款获批（#3）+drift 闭合 | complete |
| Phase 3 | ☑ | 2026-11-15 翻转 complete（drift ALIGNED+V-3.1/3.2 PASS+commit c5300a0） | complete |
| Phase 4 | ☑ | 2026-11-15 翻转 complete（V-4.1 PASS FAIL=2=基线+复检回执+DQ-08 锁步 2eded71） | complete |
| Phase 5 | ☑ | 2026-11-15 S1 双组建+合并回启动 | in_progress |

> 契约详见 `/mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. 现有条款对跨单元知识连续性覆盖到哪一环（派发/执行/沉淀/验收）？缺哪几环？
2. Rule 107 传播面最小完整集是哪些文件（权威载体+级联+纪元）？纪元面实测几文件？
3. run-selftests.sh 在 master 的基线 FAIL 数是多少？

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
| 规则落点初判=task-discipline 卫星新增 Rule 107，dispatch/media 面级联指针 | 序列创作纪律属执行纪律域（Rule 82 分层）；创作介质中立（剧本/小说通吃）；Phase 2 按 Phase 1 证据终稿可修订 |
| 修复核心=三环闭环（台账沉淀+动笔回读+验收一致性），非只加「回读」单点 | 用户 R2 点名回读手段；但只回读不沉淀台账则长序列仍衰减（多集后回读成本失控），台账=可回读的介质 |

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
| 2026-11-15 | ALIGNED | VC-1/VC-2/VC-3 | Phase 1 四维（R/Goal/VC/用户原话）无漂移；检查点=checkpoints/drift-check-p1-20261115.md；Next Step 簿记滞后已随本轮翻转同步 |
| 2026-11-15 | ⚠️DRIFT→已闭合 | VC-2 | Phase 2 DRIFT-VC2-KEYWORD（22.4d 草案缺连续锚「前序产出」）→实施前草案措辞修正+VC-2 匹配复验；检查点=checkpoints/drift-check-p2-20261115.md；改派 general-purpose（provider 2 败，22.3） |
| 2026-11-15 | ALIGNED | VC-1/VC-2 | Phase 3 实施保真/Scope 纪律/在途零触碰/三环完整四维全过；检查点=checkpoints/drift-check-p3-20261115.md |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）
<!-- 
  WHEN: chain_mode: fan-out 或 批量操作 ≥5 单元时必填;纯单次任务可删除整个区块
  WHY: 批量操作禁止以牺牲质量/准确性为代价(Rule 18);前置 3 问 + 双采样抽检 + 失败率熔断的落盘证据
  校验: failure_rate >5% → Phase 禁止 complete;sampled_fail >0 → 整批未验证;pre_check 缺项 → plan-writer 校验失败
  完整模板: /mnt/data/dev/task-planner-skill/skills/task-planner/templates/batch_report.md | 规则详解: /mnt/data/dev/task-planner-skill/skills/task-planner/references/batch-quality-gate.md
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
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（P1 侦察=Explore、P3 实施=general-coder×4、P4 复验=general-reviewer；机器面=check-delegation stats verdict=ok 2026-11-15） |
| 主进程直做 Phase 清单 | Phase 2（② 计划系统文件维护——条款定稿属计划文档域）；Phase 5（① git 编排+② 簿记）——均 25.3 白名单内 |
| 委派率 | 0.600（<0.7 floor；主进程直做 2 Phase 均白名单命中 → 25.4a WHITELIST-EXEMPT 放行路径） |
| 激活子代理数（Rule 96.5） | 8 次成功派发（Explore×1、drift×2[general-purpose 改派]、general-coder×4、general-reviewer×1）；另有 2 次 drift-checker provider 失败尝试（未产出） |
| 最大并行宽度（Rule 96.5） | 1 组 / 最宽 2（Phase 3 S2/S3 并行组 impl 同消息并发） |
| 串行化例外理由（Rule 96.4） | none |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
<!--
  WHEN: 每次 Agent() 派发前填一行;子代理返回 30s 内主进程必须 Read 实际产出 + 紧邻 Edit findings.md 回填结论(「findings 落点」列记段落锚点),两动作完成才在「备注」列勾 verify_done;failed/timeout 行必须回填 checkpoint 路径列(Rule 22.8.4)
  WHY: 子代理规模限制 + 交接文件保障(Rule 22);findings 回填绑定(Rule 19.1/22.5)防止结论只留会话记忆
  状态枚举: queued/pending/running/done/partial/timeout/failed/blocked/scaling-redispatch(22.3.1 provider 失败改派)
  列说明: 备注列 = 低频列折叠单列(rescue 换档挽救记录 档位/结果/时间,failed|timeout 行必填,Rule 22.7;retry_count = 22.3 retry_limit 计数,初值 0,每次重试 +1;verify_done☐ = Read 产出 + findings 复核/回填双条件,Rule 22.5)——字段内容不删,仅列位折叠;verify_done 无机器消费(grep 实证 scripts/*.sh 除 selftest 零命中),为人工义务,不声称机器门
  派发 prompt 八字段模板: /mnt/data/dev/task-planner-skill/skills/task-planner/templates/subagent_dispatch.md
  # [2026-09-27 task-v091 B-2] 单写者澄清+Handoff 低频列折叠（verify_done 无机器消费如实披露）
-->

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-11-15 | Explore | S1 关键词族全量枚举扫描（haiku 档） | done | 核心 38 文件/121 处全为工序语义；叙事连续性条款零命中；缺口五面 | script-dev-type.md:28/:66；dispatch:33 | findings.md §Research Findings | 返回报告（无独立 checkpoint） | - / 0 / ☑ |
| 2 | 2026-11-15 | Explore | S2 执行链定位+缺口判定+纪元面实测（merged；haiku 档） | done | merged=S1 覆盖+主进程实测（纪元 2 文件/基线 3 FAIL） | findings §Research Findings | 同上 | 无独立派发 | merged / 0 / ☑ |
| 3 | 2026-11-15 | drift-checker→general-purpose | Phase 2 偏移检查 | done | ⚠️DRIFT 一项（VC-2 锚词）→草案修正闭合；其余 ALIGNED | checkpoints/drift-check-p2-20261115.md | progress [corrected] 行 | 同上 | scaling-redispatch / 0 / ☑ |
| 4 | 2026-11-15 | general-coder | S1 Rule 107 权威载体落入 discipline（sonnet-1 档） | done | 4/4 验收 PASS；107.0-107.5 @:740-753；锚行无损 | critical-rules-discipline.md:740-753 | findings [sub:1] 小节 | subagent-state/1-general-coder.md | - / 0 / ☑ |
| 5 | 2026-11-15 | general-coder | S2 派发面+媒体面级联（sonnet-1 档） | done | 22.4d@:64+47.7@:27；锚段无损；'前序产出' 两文件=1/1 | dispatch:64；media:27 | findings [sub:2] 小节 | subagent-state/2-general-coder.md | - / 0 / ☑ |
| 6 | 2026-11-15 | general-coder | S3 索引纪元面更新（sonnet-1 档） | done | 1-107×3+路由行 ,107+EN-06 锁步 bash -n OK；:105 3i 行禁改区未触碰 | SKILL.md:9/:210/:223/:266 | findings [sub:3] 小节 | subagent-state/3-general-coder.md | - / 0 / ☑ |
| 7 | 2026-11-15 | general-reviewer | Phase 4 独立复验（selftest+VC+全文比对 103.3a；sonnet-1 档） | done | 抓到 P1 回归（dual-qc DQ-08 计数窗溢出）+载体 1-5 全文比对一致 | subagent-state/4-general-reviewer.md | 复检回执落盘 | subagent-state/4-general-reviewer.md | - / 0 / ☑ |
| 8 | 2026-11-15 | general-coder | S2 DQ-08 断言锁步修复（sonnet-1 档） | done | 4 处锁步+dual-qc 14/14；重跑全量 FAIL=2=基线 | 2eded71 | findings [sub:4] 小节 | subagent-state/5-general-coder.md | - / 0 / ☑ |
| 9 | 2026-11-15 | general-purpose | Phase 3 偏移检查（drift-checker provider 2 败改派） | done | ALIGNED 四维（实施保真/Scope/在途零触碰/三环完整） | checkpoints/drift-check-p3-20261115.md | Drift Log P3 行 | 同上 | scaling-redispatch / 0 / ☑ |
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
