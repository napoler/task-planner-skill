# Task Plan: task-model-tier-dispatch-20261119 — Rule 110 任务分级×模型档位强制匹配
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

- **R1**: 「当前 技能在执行任务过程没有践行模型分级理论 也就是 选择最偷懒的方式直接使用大模型运行 导致资源浪费」<sub>（[目标]）</sub>
- **R2**: 「执行 deepseekv4 pro 被滥用 比如 sess_a7eb0603-cbcc-4be1-9072-03d1692b7073 中 的执行 选择最偷懒的方式将所有内容直接丢到大模型的子代理执行 完全背离之前的规范 也就是 只有撰写文章或者修正文章文字部分使用」<sub>（[目标]）</sub>
- **R3**: 「有哪一步是真正的内容创作 完全是被滥用 必须纠正 这种方案导致模型被大量浪费」——判例 8 步 todo 全机械无一内容创作<sub>（[目标]）</sub>
- **R4**: 「必须对当前skill 进行 任务分级处理 来平衡资源消耗」<sub>（[手段]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 | Rule 110 全文在位：critical-rules-dispatch.md 含 `### 110` 段+三分类词面判据+档位强制匹配表 |
| R2 | VC-2 | 契约模型边界条款在位：110.x 明文"创作契约模型仅限产出物=自然语言文字语义的 S-unit；机械步骤禁用"（判例锚 sess_a7eb0603 agent_4224ef20/4f8cfac1） |
| R3 | VC-3 | 混合任务拆分+继承传染禁止+临场派发分类三子条在位（堵失效链 1-3 环） |
| R4 | VC-4 | SKILL.md 计数级联 1-109→1-110+Rule 110 归属行；VC-5 回归 selftest 基线一致（零新增 FAIL） |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/task-model-tier-dispatch-20261119/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/task-model-tier-dispatch-20261119/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 任务分类（派发前） | 无可操作三分类判据，表面动作名误判（"删1句"判作编辑类→重档合理化） | 110.1 产出物判定基准 | VC-1 |
| 档位选择（派发时） | 契约模型边界仅存记忆文件，机械步骤合法使用重档 | 110.2 档位强制匹配+契约模型边界 | VC-2 |
| 拆分决策（计划期） | 59.1 三值门量体量不量类别，混合单元整体派出 | 110.3 混合任务强制拆分 | VC-3 |
| 档位继承（S-unit 表） | 22.6"继承"语义使重档 Phase Executor 传染全部子步骤 | 110.4 继承档位传染禁止 | VC-3 |
| 临场派发（执行期） | 96.2 仅计划期触发，判例 886 修复为临场派发绕过 | 110.5 临场派发同约束 | VC-3 |
| 规则索引（SKILL.md） | 全集计数/卫星归属缺新规则行 | Phase 3 S2 级联 | VC-4 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | 既有 Rule 21.3/22.6/59.1/59.4/68.3/96.2/104 条款原文零改动（纯增量） | critical-rules-dispatch.md 对应段 |
| 🔒 不变量 | 文本优先铁律：零新脚本/零新 config 键/零新 selftest 断言（机器面=待授权候选不实施） | 宪法 §二 P0 2026-10-15 |
| 🔒 不变量 | 判例取证只读：不改 article-generation 项目与 ~/.zcode/cli/agents/** 任何文件 | §五 跨项目隔离 |
| 🔀 可变量 | 110 子条编号切分/措辞/词面判据枚举细节（以用户批准的条款设计为准） | - |
| 📈 学得量 | AD-10 类计数锚实际形态（执行期回归时确认是否锁步） | findings.md §1.3 |

## 🔒 规范基线（Spec-Baseline，Rule 51.15 — 含已确立硬约束时必填）
<!-- 2026-11-19 task-spec-baseline-freeze-20261119：把「已确立且影响验收的业务硬约束」登记为受管基线。本区块随 task_plan.md 纳入 attest SHA-256 锁（Rule 20.1），修改/放宽/删除=[SPEC-BASELINE TAMPERED] P0。区间型必须同时登记上下界（如 4s≤单镜≤12s），禁只写单边——单边口径=无下限，是 3s 过审的机制根因。无硬约束的任务填一行「none（经确认本任务无已确立硬约束）」。四环消费：派发携带 22.4e / 复检回归 103.3b / 返工续写回归 106.7 / 终验门 84.15。 -->
| spec_id | 约束原文(verbatim) | 来源锚(path:line) | 双向判定式 | 来源 sha256 |
|---------|-------------------|------------------|-----------|------------|
| SPEC-TIER-01 | 既有条款零改动：Rule 110 为纯增量，被引条款（21.3/22.6/59.1/59.4/68.3/96.2/104）原文一字不动 | critical-rules-dispatch.md | git diff 旧段=0 处改动；新增段=1 | n/a(文本片段) |
| SPEC-TIER-02 | 新 Rule 编号=110（全集当前最大 109，`.rule-reservations.jsonl` 无冲突预留需执行期核验） | SKILL.md:260 | grep `### 110 ` 计数=1；`### 111 ` 计数=0 | n/a(文本片段) |
| SPEC-TIER-03 | 纪元计数级联=1-109→1-110（SKILL.md:9/:260/:304 三处+"其余 90 条"→91） | SKILL.md:9 | grep -c '1-110' ≥3；grep -c '1-109' 在 SKILL.md=0（纪元计数行；非计数的历史引用除外，逐处判向） | n/a(文本片段) |

## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and delete functionality."
-->
在 task-planner 规则体系落地 Rule 110「任务分级×模型档位强制匹配」：任务三分类（机械/判断/创作）+档位强制匹配+契约模型边界+混合任务拆分+继承传染禁止+临场派发同约束，堵住 sess_a7eb0603 判例暴露的"纯机械操作整体丢大模型子代理"资源滥用路径。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（保护区文本变更，CR 按标准收尾） |
| `session_id` | `sess_aa69669bf9e74e87a29da9de245a45a5` | 启动时生成,注册表追踪 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-model-tier-dispatch-20261119` | §十一 隔离决策已有字段 |
| `scope_files` | `[skills/task-dispatch/references/critical-rules-dispatch.md, skills/task-planner/SKILL.md, skills/task-dispatch/SKILL.md, plans/task-model-tier-dispatch-20261119/**]` | 从「执行范围限制」解析,并发检测基础 |
| `interaction_mode` | `ask` | Rule 28 交互模式 |
| `对齐审查` | `[登记] alignment-review 收尾跑 | Rule 42.6 |
| `自动超时默认项` | `[条款措辞细节差异: 按批准稿直接执行不询问]` | Rule 44 |
| `new_rule` | `110` | Rule 20.6：本任务新增 Rule 编号（attest 自动预留+查重） |
| `质量审查工具` | `critic（条款设计审查）+ grep 锚复核（VC 机械判据）` | Rule 42.4 |

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
| VC-1 | Rule 110 全段在位且六子条齐备（110.1 三分类判据/110.2 档位匹配+契约边界/110.3 混合拆分/110.4 继承禁止/110.5 临场派发/110.6 例外判定+110.7 管辖声明） | grep -c '^### 110 ' ==1 且 grep '110\.[1-7]' 命中各子条锚 | `grep -n '### 110\|110\.[1-7]' skills/task-dispatch/references/critical-rules-dispatch.md` |
| VC-2 | 契约模型边界明文：判例锚+deepseek-v4-pro 类创作契约模型仅限文字语义产出 S-unit | grep 判例锚 sess_a7eb0603 与边界措辞在 110 段内 | `grep -n 'a7eb0603\|契约模型' skills/task-dispatch/references/critical-rules-dispatch.md` |
| VC-3 | 失效链 1-3 环堵点在位（临场派发分类留痕 token/继承传染禁止/混合拆分义务） | grep 三锚 | `grep -n '110\.3\|110\.4\|110\.5\|tier-class' skills/task-dispatch/references/critical-rules-dispatch.md` |
| VC-4 | SKILL.md 级联完成：1-110 计数 ≥3 处+Rule 110 归属 dispatch 卫星行在位+task-dispatch SKILL.md 规则清单行在位 | grep 计数与归属 | `grep -c '1-110' skills/task-planner/SKILL.md` ≥3；`grep -n 'Rule 110' skills/task-planner/SKILL.md skills/task-dispatch/SKILL.md` |
| VC-5 | 零回归：既有条款原文零改动+全量 selftest 与基线一致（预放宽 11x 窗=预期零级联；若 AD-10 类计数锚挂=按锁步先例同步并登记） | git diff 判向+run-selftests.sh --fresh 对照基线 | `bash skills/task-planner/scripts/run-selftests.sh --fresh 2>&1 \| tail -5` |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard/full 必填，mini 豁免）
<!-- task-dualqc-20261104 新增：双轮质检机制在计划阶段显式设计——派发型实质产出 S-unit 默认两道检核（第一轮执行体自审 103.2 checkpoint 自审段；第二轮主代理派全新子代理独立复检 103.3，档位升一档 103.4、复检任务书简洁五要素 103.5）；多文件变更集（≥2 受管文件）Phase 翻转前过 103.6 同步完整性审查（关联面推导四族→同步核对清单全绿）。豁免面=103.7，逐 S-unit 登记理由；mini 档整体豁免。 -->
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | S1（Rule 110 条款落盘：执行体自审+独立复检 critic 档） |
| 豁免登记 | S2 计数级联（机械 grep+Edit，主进程盘上复核替代）；S3 验证（命令判据自证，run-selftests 输出即复检） |
| 多文件变更集预判 | Phase 3 完成（dispatch 规则+SKILL.md×2 共 3 受管文件）→ 103.6 同步完整性审查：关联面四族核对（SKILL 计数/卫星清单/selftest 锚/README 类索引若有） |


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
| G1 | 条款落盘 | Rule 110 七子条全文写入 dispatch 卫星 | grep -n '### 110\|110\.[1-7]' critical-rules-dispatch.md 全锚命中 | S1/Phase 3 | complete |
| G2 | 计数级联 | SKILL.md 1-110 计数+归属行+卫星清单行 | grep -c '1-110' SKILL.md ≥3 + grep 双锚命中（68,110 与 \| 110 \|） | S2/Phase 3 | complete |
| G3 | 零回归 | 既有条款零改动+selftest 基线一致 | git diff 21+0 纯追加 + selftest 93/100 基线同集零增量 | S3/Phase 4 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则正文 | skills/task-dispatch/references/critical-rules-dispatch.md（仅追加 ### 110 段） | 该文件既有 Rule 段任何改动 |
| 技能索引 | skills/task-planner/SKILL.md（仅计数级联行 :9/:260/:304 + Rule 110 归属行） | SKILL.md 其他段落 |
| 卫星索引 | skills/task-dispatch/SKILL.md（仅规则清单行追加 Rule 110） | 该文件其他内容 |
| 计划簿记 | plans/task-model-tier-dispatch-20261119/**、plans/INDEX.md（登记行）、plans/.rule-reservations.jsonl（reserve/land 110） | 其他 plans/** 目录 |
| 部署位 | 不动（~/.zcode/**、~/.agents/** 部署同步=合并后单独授权确认） | 一切部署位写入 |

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
| CA-1 | critical-rules-dispatch.md 末段（Rule 104 段后） | 新增 | 增量 | 「必须对当前skill 进行 任务分级处理 来平衡资源消耗」 | findings §1.2 失效链四环 | 追加 ### 110 全段（批准稿文本） |
| CA-2 | task-planner/SKILL.md:9/:260/:304 | 修改 | 增量（计数随动） | 同上 | 纪元级联惯例 | 1-109→1-110、其余 90→91、加 Rule 110 归属短语 |
| CA-3 | task-dispatch/SKILL.md 规则清单 | 新增 | 增量 | 同上 | 卫星索引惯例 | 清单行加 Rule 110 |
| CA-4 | plans/.rule-reservations.jsonl | 新增 | 增量 | - | Rule 20.6 | reserve/land 110 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | critical-rules-dispatch.md Rule 21.3/22.6/59.1/96.2/104 既有条款 | skills/task-dispatch/references/critical-rules-dispatch.md（本仓 master） | 必读 | ☑ |
| 规范/标准 | agent-model-tiering 分档约定（契约模型边界出处） | ~/.zcode/cli/memories/projects/.zcode-c4bb56bd9710299a/memory/agent-model-tiering.md | 必读 | ☑ |
| 项目内部文档/知识库 | 判例取证（agent_4224ef20/4f8cfac1 metadata+output） | ~/.zcode/cli/agents/sess_a7eb0603-*/（只读） | 参考 | ☑ |
| 规范/标准 | 宪法 §二 文本优先铁律（机器面禁自行实施） | ~/.zcode/AGENTS.md §二 P0 2026-10-15 | 必读 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: task-planner 规则体系缺少"任务类别×模型档位"的强制匹配条款——既有分档规则（96.2 等）只覆盖计划期 S-unit 表且无可操作分类判据，导致纯机械操作任务（判例 886 修复 8 步）被整体丢给创作契约级大模型执行，资源大量浪费。

**核心问题判断**:
- [x] 核心问题解决后，结果能交付吗？——Rule 110 落地即完成"任务分级处理"诉求，交付=规则条款
- [x] 核心问题不解决，其他工作都白费吗？——不落条款则同类滥用复发（判例已复发 11-14/11-18 两次）
- [x] 核心问题的解决方法是清晰的、可执行的？——失效链四环已定位，六子条逐环堵截

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| S1 Rule 110 条款落盘 | LOCAL-ONLY | - | - | 既有判例/条款衔接全在本地（findings §1） | 不适用 |
| S2 SKILL 计数级联 | LOCAL-ONLY | - | - | grep 计数行+宽容锚形态 | 不适用 |
| S3 验证回归 | LOCAL-ONLY | - | - | run-selftests 输出对照 | 不适用 |

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | sess_a7eb0603 判例两 agent（4224ef20/4f8cfac1）metadata+output | 盘上 Read（只读） | findings.md §1.1 | ☑ |
| ② 对标样本（58.2 强制） | 既有分档条款基线：Rule 21.3（10-01 落地）/96.2（10-24 落地）及其未防住的缺口 | grep 条款原文+触发面分析 | findings.md §1.2 | ☑ |
| ③ 外部约束 | agent-model-tiering 用户裁决（2026-08-27 机械 haiku/判断 sonnet/创作契约专用） | 记忆文件 Read | findings.md §1.1 第三锚 | ☑ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
Phase 5（归档收尾）

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
展示 Rule 110 条款设计给用户批准；批准后建 worktree（§十一：skills/**=保护区实现类必隔离）并派 S1 条款落盘

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理（本 Phase 已由主进程+盘上 grep 完成） | 判例取证=只读小体量定位，主进程直查后落 findings |
| Phase 2 | 卫星技能 task-planner（本技能载体） | 计划系统文件维护白名单 |
| Phase 3 | Agent 子代理 executor(sonnet-1)×1 + 主进程机械级联 | S1=保护区文本精确插入（判断型，106.1a 吞锚风险）；S2 计数级联=机械（主进程白名单③量内） |
| Phase 4 | 机械守卫脚本（run-selftests）+grep | 验证判据自证 |
| Phase 5 | 主进程 git 编排 | 白名单① |

**workflow 编排判定（Rule 40.4）**: [命中 39.8 激活条件（独立并行 ≥3 S-unit 可 fan-out / 长链编排型 / 用户点名）→ 登记『CreateWorkflow 路由（39.8 条件命中）』并执行期按 39.8 三件套主动创建；未命中 → Rule 21.4 独立性守门调度（并行默认+声明制）]
**/goal 对齐（Rule 40.3）**: [本计划 Goal+VC 即 session goal 的证据源;如用户已用 /goal 锚定本任务,在执行范围或 Goal 段注明映射;/goal 为用户侧 harness 命令,技能层不可代调]

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 判例取证与失效链定位
- [x] 判例会话铁证提取（agent_4224ef20/4f8cfac1：模型/任务/产出比对）
- [x] 失效链四环定位（96.2 触发面/混合拆分/继承传染/契约边界）
- [x] 级联面基线（最大编号 109/11x 预放宽窗/计数行清单）
- [x] findings.md §1 落盘
- **V-N:** VC-2, VC-3（取证锚=条款判例锚来源）
- **Status:** complete
- **Executor:** 主进程（例外理由: 调研取证小体量只读定位+findings 簿记，Rule 25.3 白名单②；判例文件 grep 精确定位非大输出）
<!-- 
  STATUS VALUES:
  - pending: Not started yet
  - in_progress: Currently working on this
  - complete: Finished this phase
-->

### Phase 2: 条款设计与计划定稿
- [x] Rule 110 七子条设计（含判例锚/衔接声明/管辖边界）
- [x] task_plan.md 全区块填写（Goal/VC/范围/CA 表/S-unit）
- [x] 用户批准条款设计（2026-11-19 AskUserQuestion 机器面授权未作答→按宪法铁律裁决仅文本先行，登记于 Decisions Made 表）
- [x] attest 锁定计划（SHA-256=8557f68a…，rule 110 自动预留）
- **V-N:** VC-1, VC-3
- **Status:** complete
- **Executor:** 主进程（例外理由: ② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: worktree 实施（Rule 110 落盘+级联）
- [x] 建 worktree（tmp/worktrees/task-model-tier-dispatch-20261119，§十一 保护区隔离）
- [x] S1 派发：executor(sonnet-1) 落盘 21 行纯追加，主进程盘上复核 PASS（[tier-class:judgment] dogfood）
- [x] S2 主进程机械级联：SKILL.md 3 处计数+归属行+task-dispatch SKILL.md 3 处
- [x] 并行协调：master 前进至 79debfa（74.7 任务）→ worktree 内吸收合并零冲突
- [x] 103.6 同步完整性审查（全仓 1-109 残留=0；11x 宽容窗 24 脚本覆盖 110）
- [x] 规范召回（Rule 93）：本 Phase 两 S-unit 全程按 110 判据选档实践=召回实践本身（条款为本任务产物）
- **V-N:** VC-1, VC-2, VC-3, VC-4
- **Status:** complete
- **Executor:** executor（sonnet-1）+主进程（S2 机械级联白名单③）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A3) 将批准稿 Rule 110 七子条全文追加到 critical-rules-dispatch.md 末段（Rule 104 段后） | executor(sonnet-1) | worktree 绝对路径 + `<plan-dir>/knowledge-brief.md` §1 批准稿全文 + findings.md §1 判例锚 | grep '### 110 '+'110.1'-'110.7' 全锚命中且既有段落 git diff=0 | 12min | 1f/95l/12min | 无 | - | done |
| S2 | (A6) SKILL.md 计数级联+归属行+task-dispatch SKILL.md 清单行 | 主进程（白名单③ ≤3 行×2 文件机械改） | SKILL.md:9/:260/:304 + task-dispatch/SKILL.md 清单段 | grep -c '1-110' SKILL.md ≥3 | 8min | 2f/12l/8min | 无 | S1 | done |

### Phase 4: 验证与回归
- [x] VC-1..VC-4 grep 锚逐条复核（主进程盘上：1/1+7/7、1/1、3/3、3+2 锚）
- [x] VC-5 run-selftests --fresh：93/100 PASS，7 FAIL 基线对照同集同数=零新增（全预存，登记 findings §2）
- [x] 103.3 独立复检：critic APPROVED（四判据 PASS）；M2/M3 消歧收紧已采纳（110.3/110.6 修正）
- [x] 测试结果落盘 progress.md（[2026-11-19 P4] 三条）
- **V-N:** VC-1, VC-4, VC-5
- **Status:** complete
- **Executor:** critic（sonnet-1）+主进程（grep/跑测试=机械复核白名单③）

### Phase 5: Delivery
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [x] Review all output files（三件套+knowledge-brief+subagent-state 复读一致）
- [x] Ensure deliverables are complete（Rule 110 条款+级联+复检+回归全 PASS）
- [x] Deliver to user（交付报告含机器面待授权再呈报）
- [x] 全文档收尾回读梳理记录（Rule 84.14）：两轮收敛（轮 2 零新发现）
- [x] 知识提取入库：项目存在 scripts/kb-sync-from-plan.sh → 归档后执行（登记在归档动作内）
- [ ] 归档计划：check-complete exit 0 后 set-active-plan --clear + archive-plan.sh（Rule 81）
- **V-N:** VC-4, VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
<!-- 每轮一行：轮次/发现/处置；连续一轮零新发现才可出 outcome（收敛出口，轮次不设上限）；
     发现面=需求↔目标↔执行↔验证↔知识五维互洽（偏移/遗漏/未利用知识） -->
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1    | ① 执行期发现 master 被并行 74.7 任务推进（初始误判为子代理越界写入，盘上取证 git log 定位真因=并行合并）② VC-4 判据两次形态偏差（Rule 110 字面 vs 实际锚 68,110/\| 110 \|）③ critic M2/M3 条款消歧点 | ① worktree 内吸收 master 零冲突（79debfa）+主仓 stash 窗口法合并（58f727f），误判过程如实留痕 progress | ② 判据命令随实际锚形态修正 2 次（verification.md VC-4），验证意图不变 | ③ 110.3/110.6 两处消歧收紧采纳，批准稿同步 | 
| 2    | 零新发现（五维互洽：R1-R4↔VC1-5↔CA1-4↔goal G1-G3↔findings §1-2 全对齐；预存 7 selftest FAIL 与历史欠账均已登记另行任务） | 收敛出口达成 |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（本次改动 3 受管文件与并行会话无重叠；git status 示 M 文件为本会话外既有状态，执行期 worktree 内基线核对） |
| `isolation` | `worktree`（skills/** 保护区实现类，§十一 P0 强制） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-model-tier-dispatch-20261119` |
| `branch` | `wt/task-model-tier-dispatch-20261119` |
| `merge_back` | `merged(58f727f)` |

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
| Phase 1 | （示例）依赖配置缺失 |  |  |  |  |  |

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

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

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
| 新条款编号=110，落 task-dispatch 卫星 | 全集当前最大 109；dispatch 卫星已辖 96.2/104 分档与标注域，域归属自洽（SKILL.md:293 职责含"模型档位"） |
| 纯文本条款，机器面=待授权候选不实施 | 宪法 §二 文本优先铁律 P0（2026-10-15）：未经用户显式要求禁新增脚本/断言/机器门；风险如实披露（96.2 同款判定面在长序列会话执行力有限，findings §1.4）。2026-11-19 询问机器面授权（推荐=授权硬拦截），用户未作答=未获显式授权→按铁律仅文本先行，交付时再呈报 |
| 110.5 临场派发以 prompt 内 `[tier-class:...]` 留痕 token 承载 | 零机器面下的最小可审计形态：token 进 prompt 文本=可 grep 可审计，未来自动拦截 |
| S1 执行体=executor(sonnet-1) 而非 haiku | dogfood 本规则：S1=保护区文本精确插入（判断型，106.1a 吞锚风险历史判例），非机械类；S2 计数级联=机械→主进程白名单③ |
| 判例两 agent 原始证据只读引用 | §五 跨项目隔离：article-generation 与 ~/.zcode/cli/agents/** 不写入 |

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
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 4（Phase 1/2 主进程取证与计划=白名单②；Phase 5 收尾主进程 git 编排=白名单①） |
| 主进程直做 Phase 清单 | Phase 1（调研取证小体量只读+findings 簿记，②）；Phase 2（计划系统文件，②）；Phase 5（git 编排+簿记，①） |
| 委派率 | 实质产出 Phase 3/4 均委派（S1 executor+103.3 critic）；S2 级联=主进程白名单③ 机械改（≤3 行×2 文件） |
| 激活子代理数（Rule 96.5） | 2（executor×1+critic×1，串行依赖链无并行组） |
| 最大并行宽度（Rule 96.5） | 1（S1→复检→S2 为串行依赖，96.4 串行化理由=同一文件的落盘-复检-级联依赖序） |
| 串行化例外理由（Rule 96.4） | S2 依赖 S1 落盘（同文件级联）；critic 复检依赖 S1 产出——顺序依赖链，无独立可并行单元 |

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
| 1 | 2026-11-19 | executor(sonnet-1) | S1 Rule 110 七子条落盘（[tier-class:judgment]） | done | done 4/4 验收+21 行纯追加；主进程盘上复核 md5/锚全 PASS | critical-rules-dispatch.md:310-329 | findings §1/§2 | subagent-state/1-executor.md | - / 0 / ☑ |
| 2 | 2026-11-19 | critic(sonnet-1) | 103.3 独立复检条款文本 | done | APPROVED 四判据 PASS；M2/M3 采纳 NIT-3 已修 | 2-critic.md+复检报告 | findings §2 | subagent-state/2-critic.md | - / 0 / ☑ |
| 3 | | | | | | | | | - / 0 / ☐ |


## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP
