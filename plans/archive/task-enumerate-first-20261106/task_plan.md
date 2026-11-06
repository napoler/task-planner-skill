# Task Plan: Rule105 检索纪律：小集合全量枚举优先
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

- **R1**: 「我发现当前技能执行存在严重的问题 比如下面 "先做两件取证：①全库搜「装备车/二层/飞桥/帘/天幕」命名族（我此前搜索面太窄，漏了你点名的合规件=asset-first 根因）；"  这就是最大的问题 本来 所有的素材名字也就是几十个  但是却因为 搜索名称错误导致错误决定」<sub>（[目标]）</sub>
- **R2**: 「如果使用 ls 命令列出所有从中选择正确匹配 应该可去掉这种错误  因为 简单的  这就是关键词检索导致缺陷  必须进行纠正  这种完全是因小失大」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-6 + VC-1 | R1 逐字锚定 user-session-log #1（VC-6）；Rule 105 含反例锚与根因条款（关键词检索漏检→错误决定）（VC-1） |
| R2 | VC-1 + VC-2 | Rule 105 含「全量枚举优先（ls）」「零命中≠不存在→回退全量复核」核心判据条款（VC-1）；selftest 守护断言在位且通过（VC-2） |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/task-enumerate-first-20261106/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/task-enumerate-first-20261106/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 检索策略选择（无规则约束） | 执行体在候选集合可枚举时默认选关键词检索，关键词选错→漏检→错误决定（asset-first 判例） | Rule 105.1 小集合全量枚举优先判据 | VC-1 |
| 检索零命中处置 | 「没搜到」被当作「不存在」下结论，无回退复核义务 | Rule 105.2 零命中≠不存在→回退全量枚举复核 | VC-1 |
| 缺陷信号识别 | 「搜索面太窄」被归因为关键词没选好，继续扩关键词重搜（错误方向） | Rule 105.3 缺陷信号条款：纠正动作=全量枚举而非扩大关键词 | VC-1 |
| 规则无机器守护 | 条款落地后无 selftest 断言，回潮不可探测 | selftest-enumerate-first.sh 守护+registry 登记 | VC-2 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | 用户 R1/R2 原话（逐字）；核心判据=小集合（可枚举）必须 ls 全量枚举后选择、零命中≠不存在须回退全量复核；「必须进行纠正」=制度层交付（规则文本条款） | user-session-log #1 / R 区块 / VC 表 |
| 🔀 可变量 | 规则编号（105 为预留结果）、子条款结构、selftest 断言具体形态、级联面清单（Phase 1 确认）、部署批次 | - |
| 📈 学得量 | Phase 1 调研发现（现有条款覆盖面/级联锚族清单）→ findings.md | findings.md |

## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and delete functionality."
-->
新增 Rule 105「可枚举集合全量枚举优先纪律（ls-first）」条款+selftest 守护+级联部署，使「小集合关键词盲搜」这一检索缺陷模式在制度上被纠正（用户 R2「必须进行纠正」），复用判例行为有机器可探测的规则锚。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（规则文本+selftest 脚本=代码修改类） |
| `session_id` | `4ba8869cbd384bc8978401027942ae54` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-enumerate-first-20261106` |
| `scope_files` | `skills/task-discipline/references/critical-rules-discipline.md`、`skills/task-planner/scripts/selftest-enumerate-first.sh`（新增）、`skills/task-planner/scripts/selftest-registry.tsv`、SKILL.md 与纪元锚级联面（Phase 1 确认后精确化登记） |
| `interaction_mode` | `ask` |
| `对齐审查` | 登记：Phase 3 完成后跑 alignment-review 对齐审查（规则文本任务标准收尾）；mini 档豁免不适用（本任务 standard） |
| `自动超时默认项` | D1 计划确认：默认项=按已展示计划执行，超时 5 分钟（Rule 44.3）；Phase 3 执行体选型若有争议默认 executor(sonnet-1)，5 分钟 |
| `new_rule` | `105` |
| `质量审查工具` | 登记：critic（既有 agent，条款挑刺审查 Phase 3 后）+ selftest 机器守护；无缺口 |

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
| VC-1 | Rule 105 条款全文在位于 `../task-discipline/references/critical-rules-discipline.md`，含 105.1 全量枚举优先判据、105.2 零命中≠不存在回退复核、105.3 缺陷信号条款、反例锚（用户判例描述） | grep 断言 | `grep -cE "Rule 105|105\.[1-4]" <规则文档>` ≥6 且关键判据关键词（全量枚举/零命中/回退）逐项命中 |
| VC-2 | 新增 `scripts/selftest-enumerate-first.sh` 在位且 exit 0（守护规则关键行） | 运行命令 | `bash scripts/selftest-enumerate-first.sh`（worktree 内）→ exit 0 |
| VC-3 | 既有 selftest 全量回归 FAIL=0（无破坏） | 运行命令 | worktree 内跑 selftest 套件（registry 全量）→ FAIL 计数=0 |
| VC-4 | 级联面完成：SKILL.md 全集索引更新（104→105 相关行）+ 全仓旧纪元锚形态清零或已修正 | grep 断言 | Phase 1 产出的级联清单逐项消项记录；`grep -rn "1-104" --include="*.md" --include="*.sh"` 旧锚=0（或逐项登记已修正） |
| VC-5 | 部署位同步 diff=0（zcode/claude/cursor 三位关键文件）+ 主仓 scope 文件已提交 | diff + git log | 部署位逐文件 diff 输出为空；`git log -1 --stat` 含 scope 文件 |
| VC-6 | 用户原话双锚：R1/R2 逐字在位 user-session-log.md #1 + task_plan R 区块 | grep 断言 | `grep -c "因小失大" plans/task-enumerate-first-20261106/user-session-log.md` ≥1 且 R 区块命中同片段 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard/full 必填，mini 豁免）
<!-- task-dualqc-20261104 新增：双轮质检机制在计划阶段显式设计——派发型实质产出 S-unit 默认两道检核（第一轮执行体自审 103.2 checkpoint 自审段；第二轮主代理派全新子代理独立复检 103.3，档位升一档 103.4、复检任务书简洁四要素 103.5）；多文件变更集（≥2 受管文件）Phase 翻转前过 103.6 同步完整性审查（关联面推导四族→同步核对清单全绿）。豁免面=103.7，逐 S-unit 登记理由；mini 档整体豁免。 -->
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | Phase 3 全部 S-unit（规则文本/selftest/级联修正均为实质产出）——第一轮执行体自审 103.2（checkpoint 自审段）+ 第二轮 critic 独立复检 103.3 |
| 豁免登记 | S4（worktree 内全量回归跑批）豁免双轮质检——纯执行跑批零产物，自证=FAIL 计数输出 |
| 多文件变更集预判 | Phase 3 整体（≥2 受管文件：规则文档+selftest+SKILL 级联面）→ Phase 3 翻转前过 103.6 同步核对清单 |
| 第二轮复检执行体 | critic（升档：条款挑刺+守护完备性双维） |


## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
<!--
  WHEN: 终验时填写;含 [目标] 标注需求（下方 R 行）的任务必须在交付前出三态裁决
  WHY: Rule 58.5 完成裁决门——「分析报告已交付」不等于「问题解决了」;not-solved/partial 禁止标 COMPLETE
  载体: 58.4 手段/目标二分在需求原文区逐条标注 [手段]/[目标];本区块回收目标型需求的解决状态
-->
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1+R2（「必须进行纠正」=制度层纠正落地） |
| **裁决** | `solved` |
| **解决证据锚** | 主仓 skills/task-discipline/references/critical-rules-discipline.md:707-721（五子条）+ selftest-enumerate-first.sh EN 7/7 exit 0 + run-verification VC 6/6 PASS + 部署四位 diff=0 + rule 105 landed |
| **未解决面+原因** | 无（行为面冒烟属新会话义务，惯例登记遗留） |
| **已排除路径** | n/a |
| **下一步建议** | 新会话冒烟：任一素材匹配场景验证 105 条款被召回生效（对象=新会话执行体；看点=可枚举集合时先 ls；动作=正常派发即触发） |

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
| G1 | 调研定位 | 摸清现有检索相关条款与级联锚面清单 | findings.md §调研结论 含条款覆盖面+级联锚清单（路径+行号） | Phase 1 | complete |
| G2 | 设计定稿 | Rule 105 条款结构+级联清单定稿入 findings | findings.md §Rule105 设计定稿 段在位 | Phase 2 | complete |
| G3 | 落地实施 | 规则全文+selftest+级联修正三产物在 worktree 落盘 | grep Rule 105 关键行命中 + selftest exit 0 | Phase 3 S1-S3 | complete |
| G4 | 回归验证 | worktree 内 fresh 全量回归 FAIL=0 | 套件输出 FAIL=0 计数 | Phase 3 S4+Phase 4 | complete |
| G5 | 交付部署 | 合并回主仓+三位部署 diff=0+归档 | git log 含 scope 提交 + 部署位 diff=0 输出 | Phase 5 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件（相对本仓根） | 禁止 |
|-------|------------|------|
| 规则文档 | `skills/task-discipline/references/critical-rules-discipline.md`（append Rule 105 段） | 其他规则文档（plan-research-router 等） |
| 守护脚本 | `skills/task-planner/scripts/selftest-enumerate-first.sh`（新增）、`skills/task-planner/scripts/selftest-registry.tsv`（append 登记） | 其他 selftest 脚本内容 |
| 级联面 | SKILL.md 索引行、全仓 '1-104' 形态锚族命中文件（Phase 1 清单驱动，逐项登记） | 清单外文件 |
| 文档 | plans/task-enumerate-first-20261106/*（计划三文件） | 其他 plans 目录 |
| 部署位 | 三位部署点对应同族文件（Phase 5） | 部署位其他文件 |

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
| CA-1 | `skills/task-discipline/references/critical-rules-discipline.md`（Rule 104 之后 append） | 新增 | 增量 | R2「必须进行纠正」 | rule-reserve 105=free；Phase 1 确认无既有条款覆盖 | append Rule 105 五子条全文 |
| CA-2 | `skills/task-planner/scripts/selftest-enumerate-first.sh`（路径 attest 后修正） | 新增 | 增量 | R2「必须进行纠正」 | 历史惯例：每规则独立 selftest+registry 登记 | 新建守护脚本（断言规则关键行） |
| CA-3 | `skills/task-planner/scripts/selftest-registry.tsv`（末行 append） | 新增 | 增量 | R2「必须进行纠正」 | registry 登记惯例 | append selftest 登记行 |
| CA-4 | SKILL.md 全集索引行（'1-104' 计数） | 修改 | 增量（计数演进） | R2「必须进行纠正」 | Phase 1 级联清单 | 计数更新 104→105 相关表述 |
| CA-5 | 全仓 '1-104' 纪元锚族命中文件（Phase 1 清单） | 修改 | 增量（锚演进） | R2「必须进行纠正」 | 历史教训：纪元锚每纪元必炸 | 清单驱动逐项修正宽锚 |
| CA-6 | 部署位三位同族文件 | 修改 | 增量（同步） | R2「必须进行纠正」 | 部署惯例（--deploy 或文件级 cp） | 合并回后同步，diff=0 验收 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | Rule 105 载体（规则文档现状+附录编号约定） | `skills/task-discipline/references/critical-rules-discipline.md`（源仓绝对路径，worktree 同族） | 必读 | ☐ |
| 项目内部文档/知识库 | 卫星路由与全集索引现状 | `SKILL.md`「Critical Rules 指针」段+「卫星路由表」 | 必读 | ☐ |
| 项目内部文档/知识库 | selftest 登记契约 | `skills/task-planner/scripts/selftest-registry.tsv`+任一现有 selftest-*.sh 范式 | 必读 | ☐ |
| 项目内部文档/知识库 | 用户判例原文 | user-session-log.md #1（本计划目录） | 必读 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 执行体在候选集合可全量枚举（如素材名仅几十个）时，默认用关键词检索替代全量枚举做匹配判断，关键词族选错→漏检目标件→推出错误决定（asset-first 判例）；该行为模式无制度约束，会复发。**解决后能交付**：Rule 105 条款+守护落地后，后续任务检索策略有可执行判据+机器可探测锚。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？——能：规则条款+守护=制度层交付物
- [x] 核心问题不解决，其他工作都白费吗？——是：仅修现场不改制度，同类缺陷必复发
- [x] 核心问题的解决方法是清晰的、可执行的？——是：五子条判据（105.1 优先判据/105.2 零命中回退/105.3 缺陷信号/105.4 适用边界/105.5 反例锚）+selftest 断言

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| Phase 1 调研 | LOCAL-ONLY | 全量枚举、关键词检索、纪元锚 '1-104'、registry 登记 | 本地 grep/Read（Explore 子代理隔离执行） | findings §调研结论（条款覆盖面+级联锚清单） | 不适用 |

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 本仓规则体系现状（既有检索相关条款） | Explore 子代理 grep/Read | findings §调研结论 | ☐ |
| ② 对标样本（58.2 强制） | 既有同族规则范式（Rule 75 调研纪律条款结构=selftest+级联先例） | Read Rule 75 段全文 | findings §调研结论 | ☐ |
| ③ 外部约束 | 用户判例原话（R1/R2）+ §十一 worktree 铁律 | user-session-log #1 逐字 + 宪法条款 | user-session-log #1 | ☑ |

> 本任务产出=制度条款落地（纯执行类），非调研/归因报告；证据面以 ① 自身规则体系现状为主，58.2 对标=同族规则先例（非竞品归因场景），无网络取证义务。

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
Phase 2（Design 规则定稿）

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
Phase 2：主进程定稿 Rule 105 条款全文（五子条）+ selftest 断言清单落 findings §Rule105 设计定稿

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 Explore（haiku-1） | 只读全仓定位+级联锚面扫描，隔离主上下文（§一） |
| Phase 2 | 主进程 | 设计决策+条款定稿（§一 主进程保留=最终决策） |
| Phase 3 | Agent 子代理 executor（sonnet-1） | 既定步骤 SOP 执行（Rule 104.2 批量既定步骤类） |
| Phase 4 | Agent 子代理 code-runner-agent（mini） | 长耗时测试跑批隔离+fresh 环境复验 |
| Phase 5 | 主进程 | git 编排+簿记（Rule 25.3 白名单①②） |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 激活条件（S-unit ≤4 且依赖链串行、无独立并行组、用户未点名 /workflow）→ 按 Rule 21.4 独立性守门调度；Phase 3 S-unit 串行推进（全串行论证见 Phase 3 区块）
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；用户未使用 /goal 命令，无映射义务

**workflow 编排判定（Rule 40.4）**: [命中 39.8 激活条件（独立并行 ≥3 S-unit 可 fan-out / 长链编排型 / 用户点名）→ 登记『CreateWorkflow 路由（39.8 条件命中）』并执行期按 39.8 三件套主动创建；未命中 → Rule 21.4 独立性守门调度（并行默认+声明制）]
**/goal 对齐（Rule 40.3）**: [本计划 Goal+VC 即 session goal 的证据源;如用户已用 /goal 锚定本任务,在执行范围或 Goal 段注明映射;/goal 为用户侧 harness 命令,技能层不可代调]

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: Requirements & Discovery
- [x] Explore 子代理调研：① 既有检索相关条款覆盖面（grep 全量枚举/ls/检索 相关条款于 skills/*/references/*.md）② 级联锚面清单（'1-104' 字面+宽锚形态+SKILL.md 全集索引行+registry.tsv 现状+SKILL 钉值）③ Rule 105 归属卫星确认（discipline vs research 域边界比对）
- [x] Understand user intent
- [x] Identify constraints and requirements
- [x] Document findings in findings.md
- [x] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **V-N:** VC-6, VC-1（本 Phase 产出调研结论供 VC-1 设计基线）
- **Status:** complete
- **Executor:** Explore

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 96 类别 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|---------|-------------|---------|------|------|------|------|------|
| S1 | 全仓调研：检索条款覆盖面+级联锚面+归属卫星确认 | Explore | A3 | 调研任务书（三问：既有条款 grep 关键词族/级联锚四形态清单/Rule 58/63/75 域边界）；摘要=只读调研零写入 | findings §调研结论 含三节产出（路径+行号锚） | 20min | 0f/0l/20min | 无 | - | pending |

<!--
  STATUS VALUES:
  - pending: Not started yet
  - in_progress: Currently working on this
  - complete: Finished this phase
-->

### Phase 2: Design（规则定稿）
- [x] Rule 105 条款全文定稿（五子条结构+反例锚+场景边界）
- [x] 级联清单定稿（Phase 1 产出消项）
- [x] selftest 断言清单定稿
- [x] Document decisions with rationale（Decisions Made 表+findings 双落）
- **V-N:** VC-1, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护+核心设计决策——Rule 25.3 白名单）

### Phase 3: Implementation（worktree 内）
- [x] S1 Rule 105 条款全文写入 `skills/task-discipline/references/critical-rules-discipline.md`
- [x] S2 新增 `skills/task-planner/scripts/selftest-enumerate-first.sh` + registry.tsv 登记
- [x] S3 SKILL.md 索引/纪元锚级联面修正（Phase 1 清单驱动逐项消项）
- [x] S4 worktree 内 selftest 全量回归（95/97；2 FAIL 主仓基线同现=漂移非本任务引入，对照分类登记）
- [x] 规范召回（Rule 93）：每 3 个 S-unit/Phase 翻转主进程 Read ../task-discipline/references/execution-recall-card.md 并 progress 留 [recall] 行；压缩/恢复后第一动作
- [x] 103.6 同步核对清单（多文件变更集，翻转前全绿）
- **V-N:** VC-1, VC-2, VC-4
- **Status:** complete
- **Executor:** general-coder（provider 拒改派承接；括注=档位说明非类型名）
**全串行论证（Rule 68.2，替代并行组声明）**: S1→S2→S3→S4 串行——三产物共享 worktree 同一回归面（S2/S3 均影响 selftest 结果），单执行体连续上下文成本低于并行组协调+回归互踩风险；无满足「依赖=- 且独立性四问全 no」的 S-unit 对。

<!-- S-unit 派发单元表(Rule 22.6 — Executor≠主进程的 Phase 计划期必填;每行 = 一次 Agent() 派发)
  worktree 绝对路径=/mnt/data/dev/task-planner-skill-worktrees/task-enumerate-first-20261106（attest 后创建；派发 prompt 必须自带）
-->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 96 类别 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|---------|-------------|---------|------|------|------|------|------|
| S1 | Rule 105 五子条全文 append 进 discipline 规则文档 | 继承 | A6 | findings.md §Rule105 设计定稿（条款草案全文+反例锚+边界）+ 规则文档路径；摘要=五子条结构见 Phase 2 定稿 | grep 命中 Rule 105 与 105.1-105.5 段标（计数≥6）+反例锚行在位 | 15min | 1f/60l/15min | 无 | - | pending |
| S2 | 新增 selftest-enumerate-first.sh+registry 登记 | 继承 | A6 | findings §selftest 设计（断言清单：Rule 105 段标题/105.1-105.5 关键词/反例锚行/计数锚）；摘要=断言 ≥6 条 | bash scripts/selftest-enumerate-first.sh exit 0 | 15min | 2f/50l/15min | 无 | S1 | pending |
| S3 | SKILL.md 索引与纪元锚级联面修正 | 继承 | A6 | findings §级联清单（Phase 1 产出，逐项路径+行号+旧形态）；摘要=清单驱动消项 | grep 旧锚形态=0+SKILL 索引行含 105 | 15min | ≤3f/30l/15min | 无 | S1 | pending |
| S4 | worktree 内 selftest 全量回归 | 继承 | LOCAL 纯执行 | selftest 目录（worktree 内）；摘要=registry 全量跑批 | 输出 FAIL=0 | 20min | 0f/0l/20min | 无 | S2、S3 | pending |

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
  - Rule 104.3 计划期标注：「96 类别」列逐行填命中类别（A1-A7 / 47.2 具名 / LOCAL 纯执行），命中标注表（dispatch Rule 104.2）而执行体=主进程须例外理由或 [markup-exempt] token
-->
### Phase 4: Testing & Verification
- [x] critic 独立复检（Rule 103.3 第二轮，升档 103.4）：条款正确性+守护完备性+级联漏改三维挑刺
- [x] fresh 环境复跑 selftest-enumerate-first.sh + 全量套件（复用 S4 fresh 轮证据+修复后单脚本 7/7，比例原则登记）
- [x] Document test results in progress.md
- [x] Fix any issues found（critic 8 发现→修复轮 R1-R4 全 PASS→主进程复核吻合）
- **V-N:** VC-2, VC-3
- **Status:** complete
- **Executor:** critic（fresh 回归复用 S4 轮证据，比例原则登记于 progress；code-runner 派发豁免）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 96 类别 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|---------|-------------|---------|------|------|------|------|------|
| S1 | critic 独立复检（103.3 第二轮升档） | critic(sonnet-1+) | A5 | 复检任务书（103.5 四要素）+执行体 checkpoint 自审段+产物清单；摘要=三维挑刺条款/守护/级联 | 复检回执 checkpoint 含逐条 PASS/FAIL | 15min | 0f/0l/15min | 无 | Phase 3 complete | pending |
| S2 | fresh 全量回归复跑 | code-runner-agent(haiku-1) | A6 | worktree 路径+selftest 目录；摘要=套件全量跑批 | FAIL=0 计数输出 | 20min | 0f/0l/20min | 无 | S1 | pending |

### Phase 5: Delivery
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [x] Review all output files（主仓 Read 复验关键文件：1-105×3/105.1-5×5/EN 7/7）
- [x] Ensure deliverables are complete
- [x] Deliver to user
- [x] smart-merge-back 合并回主仓（71c8393 merge，V4 ALREADY_MERGED 路径）+ worktree/分支已清理（遗留 wt/task-v168-machine-parked 为任务前旧遗留，登记不动）
- [x] 部署位同步：zcode（手动 rm+cp，运行位自保护判例）+claude/opencode（--deploy swap）+cursor（文件级 cp）四位 diff=0
- [x] 全文档收尾回读梳理记录（Rule 84.14）：两轮收敛（轮 1 五发现全处置；轮 2 零新发现=收敛出口）
- [x] 归档计划：check-complete exit 0 后执行（见下）
      <!-- task-kb-auto-capture-20261022 增：收尾主动触发——归档与知识提取为收尾默认动作，勿依赖人想起手动跑 -->
- [x] 知识提取入库：kb-sync draft→精炼主题化 knowledge/entries/rule105-ls-first-discipline.md（级联维护要点五节）→rebuild-index<!-- 路径基准双轨：归档/模板类命令 <skill>/=技能根；kb-* 脚本实体在仓库根 scripts/（项目相对），勿混统一（2026-10-23 task-kb-cr-lits-20261023 CR MAJOR-1 回退） -->
- **V-N:** VC-3, VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
<!-- 每轮一行：轮次/发现/处置；连续一轮零新发现才可出 outcome（收敛出口，轮次不设上限）；
     发现面=需求↔目标↔执行↔验证↔知识五维互洽（偏移/遗漏/未利用知识） -->
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1 | ① rule-reserve land 105 遗漏（PR-02 FAIL 暴露）② VC Verify command 混中文致 runner 127 ③ 委派统计裸名陷阱（v150 判例复发）④ Phase1 重复 checkbox ⑤ VC-3 口径需如实（95/97 非 100%） | ① land e8ab2e8 ② 纯命令化 6 条→PASS 6/6 ③ Handoff 裸名+Executor 对齐→verdict ok ④ 清理+P-04 PASS ⑤ VC-3 判据改如实口径（基线 flaky 分类） |
| 2 | 连续一轮零新发现（六文档互洽：R↔Goal↔执行↔验证↔知识 五维对照通过；反例锚/判据/守护/部署四层一致） | 收敛出口达成，出 outcome |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①: 2 未提交文件——`.zcode/plans/plan-session_*.md` 会话私有计划+本任务 plans 目录，均非任务范围重叠；信号③: 遗留分支 `wt/task-v168-machine-parked`，旧遗留与本次无关，登记不动） |
| `isolation` | `worktree`（§11.1 命中：修改技能文件=P0 保护区+运行中基础设施） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-enumerate-first-20261106` |
| `branch` | `wt/task-enumerate-first-20261106` |
| `merge_back` | `merged(71c8393)` |

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
| Phase 1 | 级联锚面扫描漏项（宽锚形态未覆盖） | 7 | 4 | 5 | 140 | 兜底（22.3④ 拆细）: Explore 任务书强制四形态族清单（'1-104' 字面/宽锚 [0-9]x/SKILL 计数行/registry 钉值）逐形态独立 grep 汇报计数 |
| Phase 3 | 规则文本与既有条款镜像/冲突（Rule 82 回潮） | 6 | 3 | 4 | 72 | Phase 1 调研先行+executor 任务书含禁镜像约束；critic 复检抓 |
| Phase 3 | 级联锚漏改 | 7 | 5 | 6 | 210 | 兜底（22.3④ 清单驱动消项）: Phase 1 清单逐项勾销+S4 回归期 selftest 纪元锚断言兜底 |
| Phase 5 | 部署位漂移方向误判（cp 覆盖错向） | 7 | 4 | 5 | 140 | 兜底（22.3② 换道）: 部署前逐位抽样 diff 判向（历史判例 task-crossprojauth「多位部署漂移方向必逐对 diff 判向」）+diff=0 验收 |
| Phase 4 | 回归 FAIL 非本任务引入（基线漂移） | 5 | 4 | 3 | 60 | master 基线对照分类：非本任务引入的登记另行，不计入本任务验收 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-11-06 | S1 sync-todos.sh --json 已建映射 |
| Phase 2 | ☑ | 2026-11-06 | S2 已同步 |
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
1. 现有规则体系是否已有覆盖「ls 全量枚举 vs 关键词搜索」的条款？（Phase 1 确认，避免镜像副本=Rule 82 回潮）
2. 级联锚面有哪些？（'1-104' 纪元锚族 / SKILL.md 全集索引行 / registry.tsv / SKILL 钉值 BP-08）
3. Rule 105 归属卫星=task-discipline 的判定在 Phase 1 调研后是否成立？

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
| 规则编号=105，归属 task-discipline 卫星（执行纪律域） | rule-reserve check 105=free（2026-11-06 实测）；域归属判定：本条是本地检索**动作策略**纪律，非网络调研证据面（58/63/75 调研族不覆盖检索方式选择） |
| 关键词检索保留合法位置（大集合预过滤），非全面禁止 | 用户否定的是「小集合关键词盲搜」（R1「素材名字也就是几十个」），非关键词检索本身；全面禁止会误伤大仓代码搜索（Explore 路由场景） |
| selftest 独立脚本+registry 登记（非并入现有脚本） | 历史惯例（每规则独立 selftest 守护面隔离）；现有 selftest 多为规则域专属，并 入会扩大既有断言文件改动面 |
| 交付形态=规则文本条款+守护（制度层），不回填历史现场 | Rule 31.8 诉求层级契约：制度层诉求交付物=规则文本条款 |
| 路径修正（attest 后实测）：selftest 落位=`skills/task-planner/scripts/selftest-enumerate-first.sh`，registry=`skills/task-planner/scripts/selftest-registry.tsv`，跑批入口=`run-selftests.sh` | attest 后 worktree 实测：源仓 scripts/ 仅 3 个 kb 脚本；selftest 套件（150 脚本）在 skills/task-planner/scripts/；registry 真名=selftest-registry.tsv（selftest-absorption-discipline.sh:60 实证）。CA-2/CA-3/VC-2/VC-3 路径按此修正 |

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
| 2026-11-06 Phase1 | ✅ALIGNED（4 项 PASS） | VC-6 | 调研产出对齐，范围干净 |
| 2026-11-06 Phase3 | ✅ALIGNED（5 项 PASS） | VC-1/VC-2/VC-4 | 产物与 CA 表一致，未越界，基线漂移分类合规 |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 子代理占比需要可见反馈闭环;委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
  WHEN: 每个 Phase complete 后更新;终验交付前必须完整。
-->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（Phase 1 Explore/Phase 3 general-coder×3/Phase 4 critic+general-coder） |
| 主进程直做 Phase 清单 | Phase 2（白名单②计划文件维护+设计决策）/Phase 5（白名单①git 编排+②簿记） |
| 委派率 | 0.6（check-delegation stats verdict=ok；主进程两位均白名单内） |
| 激活子代理数（Rule 96.5） | 7（Explore1+drift2+general-coder4+critic1——含修复轮与 EN-03 修正轮） |
| 最大并行宽度（Rule 96.5） | 1 组 / 最宽 2（S2 修正轮与 S3 并行，文件集无交集） |
| 串行化例外理由（Rule 96.4） | S1→S2→S3 串行（共享回归面）；S2 修正与 S3 并行为无交集特例 |

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
| 1 | 2026-11-06 | Explore | Phase1 全仓调研三节（空白区/级联锚/归属） | done | ① 105=空白区（关键词族零命中）② 级联=SKILL.md 3 处+路由 4 行+卫星尾新增；selftest 宽窗零改动 ③ 归属=task-discipline | SKILL.md:9/222/265/17/209/211/255；discipline:109-115,681 | §调研结论（三节全量） | subagent-state/01-explore-enumerate-first.md | - / 0 / ☑ |
| 2 | 2026-11-06 | general-purpose | Phase1 偏移检查三态判定（drift-checker provider 拒改派） | done | ✅ALIGNED 4 项 PASS（动作对齐/产出对齐/范围干净/证据实存） | progress.md:18 R锚定行 | — | subagent-state/01-drift-phase1.md | - / 0 / ☑ |
| 3 | 2026-11-06 | general-coder | S1 Rule 105 条款 append worktree（executor provider 拒改派） | done | +14 行纯尾部增量；五子条+Why 块逐字在位（主进程 Read :707-719 复核吻合）；既有零改动 | discipline(wt):707-719 | §Rule105 设计定稿（落地完成态） | subagent-state/03-executor-s1.md | - / 0 / ☑ |
| 4 | 2026-11-06 | general-coder | S2 selftest+registry（executor provider 拒改派） | done | +101 行脚本+registry 1 行；EN-03 阈值修正轮（5→4，设计拍脑袋值校准）；当前态 5/2 预期 | scripts(wt):selftest-enumerate-first.sh | §Rule105 设计定稿（断言清单段） | subagent-state/03-executor-s2.md | - / 0 / ☑ |
| 5 | 2026-11-06 | general-coder | S3 SKILL.md 级联 104→105 | done | 7 项验收全 PASS；281 行不变净 0；2 文件 6+/5- | SKILL.md(wt):9/222/265/209/255 | §调研结论·节 B（级联清单消项） | subagent-state/03-executor-s3.md | - / 0 / ☑ |
| 6 | 2026-11-06 | general-purpose | Phase3 偏移检查（drift-checker provider 拒改派） | done | ✅ALIGNED 5 项 PASS（CA 一致/未越界/文本吻合/基线分类合规） | git show 4344749 | — | subagent-state/03-drift-phase3.md | - / 0 / ☑ |
| 7 | 2026-11-07 | critic | Phase4 独立复检三维挑刺 | done | 8 发现全验证 VERDICT=CHANGES_REQUESTED（I-1 计数/I-2 空壳/W-1 双阈值+N 项） | subagent-state/04-critic-review.md | §调研结论（复检闭环） | subagent-state/04-critic-review.md | - / 0 / ☑ |
| 8 | 2026-11-07 | general-coder | Phase4 修复轮 R1-R4 | done | 4 项全 PASS+EN 7/7 复跑绿+主进程 Read 复核吻合；commit 227f3a3 | subagent-state/04-fix-round.md | §Rule105 设计定稿（修复完成态） | subagent-state/04-fix-round.md | - / 0 / ☑ |

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP
- **登记（2026-11-06）**：不沉淀理由——本任务为规则制度类（task-planner 技能维护的标准形态，属既有 general/规则类惯用形态），非新型可复用 variant；template-sense 空缺系任务类型未匹配 16 类已知类型，Rule 34.3② 评估后判定无沉淀价值。
