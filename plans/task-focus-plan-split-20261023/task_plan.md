# Task Plan: 新增 Rule 94 任务专注性与计划隔离纪律
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  选定 variant 后 template_type 填所选类型名（白名单=${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/templates/variant/*-type.md 动态派生，见 check-template-type.sh）；general=通用回退（恒合法，Rule 34.1）
  plan_tier ∈ {standard, mini}（Rule 38.1，mini 四条件机器判定）；execution_lane ∈ {L0, L1, L2}（Rule 38.7，缺省 L1；L0 禁滥用见 38.7 末段）
  check-template-type.sh 三形态之一：行首 `^template_type:`（本块）/ 表格行 / HTML 注释；本块用行首形态 -->
template_type: rule-enhancement
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

- **R1**: 「为当前技能添加一个，就是说专注性专注性的规范」<sub>（[目标]）</sub>
- **R2**: 「要求遇到就是说如果说遇到与偏离与之前的任务偏离的时候，我希望可以主动的开启新的就是计划任务来执行……主动的在遇到用户请求出现偏差的时候，要求用户使用新，就是要，嗯，询问用户是否使用在新的就是Task中进行执行」<sub>（[目标]）</sub>
- **R3**: 「核心工作就是确保所有的工作都在一个垂直领域内执行，确保不会减少，就是尽量减少污染……确保后期不会将所有的就是计划以及任务等等混到一起」<sub>（[目标]）</sub>
- **R4**: 「就是两个目标，一个目标是A，另一个目标是B，那就可以拆分成两个Task Plan的就是计划任务，进行隔离处理」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 | `grep -c "### 94 任务专注性与计划隔离"` 于卫星规则文件 = 1，含 94.1-94.6 子条锚 |
| R2 | VC-1, VC-6 | 94.3 主动询问拆分条款在位 + 主 SKILL.md 用户新指令段指针句 grep 命中 |
| R3 | VC-1 | 94.1 单计划单垂直域 + 94.4 隔离处置条款在位 |
| R4 | VC-1 | 94.2 重大偏差判据（目标 A→B）+ 94.4 拆分处置条款在位 |
| R1-R4（级联面） | VC-2 | 全部索引/枚举/计数锚级联同步（活跃字面 1-93→1-94） |
| R1-R4（不回归） | VC-3 | `run-selftests.sh` 全绿 FAIL=0 |
| R1-R4（制度流程） | VC-4, VC-5 | rule-reserve 94 配对 + worktree 合并回 master |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/<task-id>/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/task-focus-plan-split-20261023/user-session-log.md`（模板 = ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 规则文本起草 | 条款与既有规则管辖重叠（与 Rule 8.1/E 类/64/88 边界不清→双头管辖或空转） | 94.2 管辖二分 + 94.5 衔接条 | VC-1 |
| 级联锚同步 | 1-93 纪元/计数/枚举漂移→文档间口径失真 | S2-S5 级联 S-unit + VC-2 grep 验收 | VC-2 |
| 回归防线 | 规则落地打破 selftest 机器锚 | Phase 3 全量 run-selftests.sh | VC-3 |
| 编号竞态 | Rule 编号与他任务撞号 | new_rule: 94 + rule-reserve reserve/land 配对 | VC-4 |
| 合并完整性 | worktree 改动丢失/半残合并 | --no-ff 合并回 + 主仓 Read 复验 + worktree 清理 | VC-5 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Rule 编号=94（reserve 账本唯一）；归属卫星=task-discipline；L0-T 文本优先（零新增守护/selftest/config 键）；既有规则条目原文零改动（纯增量）；worktree 隔离（§十一.1.1） | R1-R4 + Rule 20.6/82/86.7 范式 + 宪法 §十一 |
| 🔀 可变量 | 条款子条划分（94.x 编号内聚）、插入位置微调（Rule 93 段后）、SKILL.md 指针句措辞、级联 S-unit 的文件分组顺序 | - |
| 📈 学得量 | 侦察级联面结论、判例 diff 细节、锚宽容族实证 → findings.md | findings.md |

## Goal
为 task-planner 技能体系新增 Rule 94「任务专注性与计划隔离纪律」：用户请求与活跃计划目标重大偏差（目标 A→B）时主动询问用户拆分到新 Task Plan 隔离执行，单计划单垂直域防污染——规则正文落入 task-discipline 卫星、全仓级联锚同步、selftest 零回归、worktree 合并回 master。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（规则文本为制度级产出，轻 diff 单轮 critic 审查） |
| `session_id` | `fps-20261023-a3f7` | 启动时生成,注册表追踪 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-focus-plan-split-20261023` | §十一 隔离决策已有字段 |
| `scope_files` | `skills/task-discipline/references/critical-rules-discipline.md, skills/task-discipline/references/execution-recall-card.md, skills/task-discipline/SKILL.md, skills/task-planner/references/critical-rules.md, skills/task-planner/SKILL.md, CLAUDE.md, README_zh.md, skills/task-planner/README.md, skills/task-planner/docs/ARCHITECTURE.md` | 从「执行范围限制」解析,并发检测基础 |
| `interaction_mode` | `ask`（自主目标模式下关键裁决登记 Decisions Made，Rule 44.3 自动裁决五要素留痕） | Rule 28 交互模式：ask=关键决策点给选项；silent=静默+静默决策清单登记 |
| `对齐审查` | `[登记]` Phase 3 critic 审查覆盖对齐面（Rule 42.6 消费：任务产出或更新的文档在完成前跑 alignment-review 对齐审查;mini 档豁免） |
| `自动超时默认项` | `[询问点: D1 计划确认=按已展示计划执行/5min；拆分 vs 并入=新开计划隔离(Recommended)/5min]` | Rule 44 消费：登记默认选项与超时；用户超时未答复按默认选项自动执行+登记自动裁决记录五要素（44.3） |
| `new_rule` | `94` | Rule 20.6：本任务新增 Rule 编号（attest 自动预留+查重；账本实测 94 未被预留） |
| `质量审查工具` | `[检测结论] critic 子代理审查 diff（既有 agent，无需补建）` | Rule 42 消费登记（42.4） |

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
| VC-1 | Rule 94 正文在归属卫星在位且完整（`### 94 任务专注性与计划隔离` + 94.1-94.6 子条） | grep 计数+子条锚 | `grep -c "^### 94 任务专注性与计划隔离" skills/task-discipline/references/critical-rules-discipline.md` = 1；`grep -cE "^- \*\*94\.[1-6]" 同文件` ≥ 6 |
| VC-2 | 全仓级联锚同步：活跃字面 1-93→1-94（SKILL.md L9/L17/L196/L209/L251、references/critical-rules.md 卫星枚举、discipline SKILL.md 4 处计数+枚举、CLAUDE.md、README_zh.md、planner README.md、docs/ARCHITECTURE.md）；历史注释行的 1-93 保留（WF-10 锚依赖） | grep 活跃字面 | 逐文件 grep "Rules 1-94"≥1 命中；`grep -n "1-93" 各文件` 仅剩 HTML 注释行；discipline SKILL「共 44 条」→45 |
| VC-3 | selftest 全量零回归 | 运行 run-selftests.sh | `bash skills/task-planner/scripts/run-selftests.sh` 输出 FAIL=0（exit 0） |
| VC-4 | Rule 编号制度面配对 | 查预留账本 | `grep '"rule":94' plans/.rule-reservations.jsonl` 含 reserved+landed 各 ≥1 行 |
| VC-5 | worktree 合并回完成且清理 | git log+worktree list+Read 复验 | master `git log --oneline -1` 为 wt 分支 merge commit；`git worktree list` 无本任务路径；主仓 Read Rule 94 段在位 |
| VC-6 | 行为面指针接线：主 SKILL.md 用户新指令段含 Rule 94 指针句 + 召回卡含 94 行 | grep | `grep -n "Rule 94" skills/task-planner/SKILL.md` ≥1 命中于「用户新指令处理」段；`grep -n "（Rule 94）" skills/task-discipline/references/execution-recall-card.md` ≥1 |

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
| **目标型需求** | R1/R2/R3/R4 |
| **裁决** | `solved` / `partial` / `not-solved`（终验时填） |
| **解决证据锚** | （VC-1/VC-6 证据行；终验时填） |
| **未解决面+原因** | （partial 时填；部署位同步 deferred 属移交项非缺陷） |
| **已排除路径** | （not-solved 必填） |
| **下一步建议** | （部署位同步待授权等；按 Rule 70：对象路径+看点+动作） |

> 纯手段型任务可填 `n/a（纯手段型任务）`——须与需求区标注一致，禁裸豁免。

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
| G1 | 级联面侦察 | 判例 diff+破裂锚+归属判定结论落检查点与 findings | subagent-state/01-explore-cascade.md 在位且含 1-7 项结论 | S1/Phase 1 | complete |
| G2 | 规则正文落地 | Rule 94 六子条正文+召回卡行写入 discipline 卫星 | `grep -c "^### 94 任务专注性与计划隔离" critical-rules-discipline.md`=1 | S2/Phase 2 | pending |
| G3 | 级联锚同步 | 9 文件索引/枚举/计数全部 1-94 化（历史注释保留） | 逐文件 grep "Rules 1-94" 命中清单落 progress | S3-S6/Phase 2 | pending |
| G4 | 指针接线 | SKILL.md 用户新指令段 Rule 94 指针句在位 | `grep -n "Rule 94" skills/task-planner/SKILL.md` 命中 | S7/Phase 2 | pending |
| G5 | 回归+CR | selftest FAIL=0 + critic APPROVED | run-selftests.sh exit 0；critic 结论行落 progress | S8-S9/Phase 3 | pending |
| G6 | 合并归档交付 | merge --no-ff 回 master+land 94+归档+worktree 清理 | git log merge commit+账本 landed 行+archive 目录在位 | Phase 4 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!--
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则正文 | skills/task-discipline/references/critical-rules-discipline.md、skills/task-discipline/references/execution-recall-card.md | 其他卫星规则文件 |
| 卫星索引 | skills/task-discipline/SKILL.md | 其他卫星 SKILL.md |
| 核心技能 | skills/task-planner/SKILL.md、skills/task-planner/references/critical-rules.md | skills/task-planner 其他文件 |
| 仓级文档 | CLAUDE.md、README_zh.md | 根目录其他文件 |
| 技能文档 | skills/task-planner/README.md、skills/task-planner/docs/ARCHITECTURE.md | docs 其他文件 |
| 部署位 | **本任务零触碰**（deferred 待用户授权，宪法 §六） | ~/.zcode/skills/**、~/.agents/skills/** |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户（问询按 Rule 70 四要素）

## 📋 变更标注表（Rule 74.3 — 修订方案必填，无表=无效方案）

<!--
  WHAT: Rule 74.3 变更标注表 — 任何对既有文件/条目的变更，制定方案时逐条登记（编号/对象+锚点/类型/吸收判定/依据/执行动作）。
  WHY: 落实 74.2 三判门（增量默认·替代四条件·删除授权）留痕；无表=无效方案禁入执行（74.3b），表兼验收清单（74.3c）。
  WHEN: 制定修订方案时填写；用户新指令到达时先逐条转标注行再动任何文件（先标注后执行，74.3d）。
-->

任何对既有文件/条目的变更，制定方案时在此逐条登记；本表兼任验收清单（执行后逐行勾核，新增而产物缺失/增量而旧内容被改=FAIL）。用户新指令到达时先转标注行再动任何文件——先标注后执行。

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 用户原话（逐字） | 依据（证据） | 执行动作 |
|------|------------------|---------------------------|-----------|----------------|----------------|---------|
| CA-1 | critical-rules-discipline.md 文件尾（Rule 93 段后） | 新增 | 增量 | 「为当前技能添加一个…专注性的规范」 | Rule 93 判例格式（`### N` 段式） | 追加 `### 94` 段（94.1-94.6），既有条目零改动 |
| CA-2 | execution-recall-card.md（discipline 分节） | 新增 | 增量 | 「尽量减少污染…混到一起」 | 卡内既有行式「- 规范召回：…（Rule 93）」 | 追加 1 行 Rule 94 蒸馏行，≤120 行约束 |
| CA-3 | skills/task-discipline/SKILL.md L15/L24/L76/L87 | 更新 | 替代（计数口径演进：44→45、枚举尾+94） | 「为当前技能添加…规范」 | 判例 65ceed7 同款计数级联 | 4 处计数/枚举 +1/+94，其余原文不动 |
| CA-4 | skills/task-planner/references/critical-rules.md L194 | 更新 | 替代（卫星枚举演进 +94） | 同上 | 侦察第 3 项 | task-discipline 行枚举尾 +94 |
| CA-5 | skills/task-planner/SKILL.md L9/L17/L196/L209/L251 | 更新 | 替代（纪元字面 1-93→1-94+计数） | 同上 | 侦察第 4 项 | 5 处字面更新；L209 计数 74→75 |
| CA-6 | skills/task-planner/SKILL.md「目标切换判定（E 类）」段尾 | 新增 | 增量 | 「询问用户是否使用在新的就是Task中进行执行」 | 侦察第 4 项（L174 处置句后） | 追加 1 行 Rule 94 处置指针句（BP-08 ≤275 行边距内） |
| CA-7 | CLAUDE.md L33 | 更新 | 替代（纪元字面） | 同上 | 判例同款 | 1-93→1-94 |
| CA-8 | README_zh.md L136/L229 | 更新 | 替代（纪元字面） | 同上 | 判例同款 | 2 处 1-93→1-94 |
| CA-9 | skills/task-planner/README.md L4/L36/L81/L123/L127 | 更新 | 替代（纪元+计数口径现值+1） | 同上 | 侦察第 7 项（判例 4 文件面）+CR P2-11 补登 L36 架构图行 | 逐处现值+1/+94 |
| CA-10 | skills/task-planner/docs/ARCHITECTURE.md L4/L13/L42/L113/L122/L134/L136 | 更新 | 替代（纪元+计数+演进史行） | 同上 | 侦察第 7 项 | 逐处现值+1/+94；L122 演进史追加 94 行 |
| CA-11 | skills/task-discipline/SKILL.md 规则索引表尾 + 「落盘状态」句 | 新增 | 增量 | 同 CA-3 | S3 执行期发现（检查点 04-impl-s3b：索引表 43 行止于 `| 92 |`，94 表行=本任务落地补齐） | 索引表追加 `| 94 | 任务专注性与计划隔离纪律 | 同上 |` 行；落盘状态句补「Rule 94（task-focus-plan-split-20261023 任务专注性与计划隔离）已后补落盘」；**93 表行缺口=task-v195 遗留，射程外只报告不修（Rule 88/87.4④）** |
| CA-12 | plans/.rule-reservations.jsonl 追加 landed 行 | 新增 | 增量 | 同 CA-3 | S8 跑批 PR-02 FAIL（reserved 无 landed 配对） | worktree 内 `rule-reserve.sh land 94 task-focus-plan-split-20261023` + 提交——前置 land 使 landed 行与规则正文同一 merge 入 master（Phase 4 惯例「合并后 land」的等价前置，裁决见 Decisions Made） |
| CA-13 | CR fix-phase（S10-S13）：规则文本七处+SKILL 77 口径×2+README/ARCH/CLAUDE/README_zh 注记与注释链+93 表行补登 | 更新/新增 | 增量为主（注记=同行内补增量；93 表行=1 行增量） | 同 CA-3 | S9 CR CHANGES_REQUESTED（检查点 12-cr-s9.md 15 项；P1-1 主进程复核 11 卫星合计=77 实证） | 逐项按 CR 修法闭环；93 表行=CR 修复门内的射程内闭环（计数级联完整性直接面），修订 CA-11 射程外判定 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | Rule 93 落地判例 diff（级联面先例） | master commit `2f1b88f`（`git diff 45eda8c..19e66fe`） | 必读 | ☑ |
| 项目内部文档/知识库 | discipline 规则文件段式与尾部锚 | skills/task-discipline/references/critical-rules-discipline.md L530-603（已 Read） | 必读 | ☑ |
| 项目内部文档/知识库 | 级联面侦察结论 | plans/task-focus-plan-split-20261023/subagent-state/01-explore-cascade.md | 必读 | ☑ |
| 项目内部文档/知识库 | L0-T 文本优先档范式（86.7/89.6/90.6/92.7） | critical-rules-discipline.md 同文件既有条目 | 参考 | ☑ |

**填写规则**：① `定位` 必须可唯一定位；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!--
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 执行体在遇到用户请求与活跃计划目标重大偏差时缺「拆分新计划」的处置纪律，易把 B 目标就地吸收进 A 计划造成跨域污染——本任务以 Rule 94 条款（判定判据+询问门+隔离处置）补齐该制度缺口。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（规则条款落入技能文件即交付，部署位同步为独立移交项）
- [x] 核心问题不解决，其他工作都白费吗？（是——无条款则诉求未落地）
- [x] 核心问题的解决方法是清晰的、可执行的？（判例先例+级联面已侦察+文本范式既有）

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| S1 级联面侦察 | LOCAL-ONLY | git log Rule 93、grep 纪元锚 | 本仓 git/grep（已完成，结论落检查点） | findings 小节 | 不适用 |
| S2-S7 实施 S-unit | LOCAL-ONLY | 1-93 级联、计数口径 | 本仓 grep+Edit | 文件变更 | 不适用 |
| S8-S9 验证 CR | LOCAL-ONLY | run-selftests、diff 审查 | 本仓脚本+critic 子代理 | 测试结果 | 不适用 |

> 三态判定：本任务全部子目标 LOCAL-ONLY（纯仓内制度文本工程，无外部数据依赖）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」
  豁免: 纯执行类任务填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 本仓既有规则段式（Rule 88-93 七条正文结构） | Read critical-rules-discipline.md L530-603 | findings.md §Research Findings | ☑ |
| ② 对标样本（58.2 强制） | Rule 93 落地判例（task-v195 全文件清单 diff） | git show --stat 2f1b88f | subagent-state/01-explore-cascade.md §1 | ☑ |
| ③ 外部约束 | 宪法 §四.6 文本优先/§十一 worktree 铁律/selftest 机器锚族 | 用户级 AGENTS.md+侦察第 5 项 | 本计划不变量声明区 | ☑ |

> 归因类结论在 ② 未完成第一手取证前禁止产出（58.2）。本任务②已完成（判例 diff 实证）。

## Current Phase
<!-- WHICH phase you're currently working on. Update as you progress. -->
Phase 4

## Next Step
<!-- 单一下一步动作(一句话,可执行)。Phase 状态每次变更时同步刷新(Rule 20.4)。 -->
提交计划簿记→smart-merge-back 合并回 master→主仓全 VC 复验→check-complete→归档→交付总结

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类）。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块。机器校验边界见 Rule 40.5。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理（general-purpose 侦察）+ 主进程起草 | 级联面多文件扫描委派隔离上下文；规则文本=核心规划工作主进程亲撰 |
| Phase 2 | Agent 子代理 executor（5 派发）+ 主进程 git 白名单（worktree 创建） | 机械级联 Edit 按材料包派发；git 编排属白名单① |
| Phase 3 | Agent 子代理 code-runner-agent + critic | 测试跑批隔离执行；独立视角 CR |
| Phase 4 | 主进程（git 编排①+簿记②白名单） | 合并回/land/归档为白名单动作 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 激活条件（S-unit 间强串行依赖：正文→级联→验证→合并），按 Rule 21.4 串行推进
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal（/goal 指令）的证据源；用户已用 /goal 锚定本任务，Goal 段即映射载体

## Phases
<!--
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6)
-->

### Phase 1: 需求与调研（级联面侦察+规则定稿）
- [x] 用户意图复述与逐字落盘（user-session-log.md #1）
- [x] 级联面侦察完成（判例 diff+破裂锚+归属判定，检查点 01-explore-cascade.md）
- [x] 规则 94 文本定稿（六子条草案入本计划材料包与 findings.md）
- [x] 知识储备必读项确认（判例 diff/段式/侦察结论）
- **V-N:** VC-4（编号预留已落账：账本末行 94 reserved）, VC-1（正文草案定稿：findings 六子条+派发简报）
- **Status:** complete
- **Executor:** general-purpose（侦察已派发完成；规则文本起草=主进程规划职责）

<!-- S-unit 派发单元表(Rule 22.6 — Executor≠主进程的 Phase 计划期必填)
  机器契约(check-plan-dispatch.sh attest 校验):
  ① 预估时长列一律写 NNmin 格式 ② 输入列文件路径 token 计数 ≤2 ③ 拆分决策基准=预估时间 ④ ID 列一律纯数字
-->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 扫描 Rule 94 级联面（判例 diff+破裂锚+归属判定） | general-purpose | 任务简报内联（7 项侦察清单）；检查点输出至 plans/task-focus-plan-split-20261023/subagent-state/ | 检查点含 1-7 编号结论+file:line 证据 | 15min | 0f/0l/15min | 无 | - | done |

### Phase 2: worktree 内实施（规则正文+级联锚+指针接线）
- [x] 创建 worktree（/mnt/data/dev/task-planner-skill-worktrees/task-focus-plan-split-20261023，分支 wt/task-focus-plan-split-20261023，自 master HEAD；首锚 2d978e0）
- [x] S2-S7 逐单元派发实施（S2/S3/S3b/S4/S5/S6 六次 executor 派发全 PASS；S7 主进程 git 白名单吸收——提交 3ea1dbc）
- [x] 规范召回（Rule 93）：五单元后主进程 Read 召回卡 52 行，[recall] 行已落 progress
- **V-N:** VC-1, VC-2, VC-6（worktree 侧全部实跑 PASS，见 progress Phase 2 Test Results）
- **Status:** complete
- **Executor:** executor

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S2 | Rule 94 正文+召回卡行写入 discipline 卫星 | 继承 | worktree 内 critical-rules-discipline.md 尾部（L603 后插入）；正文草案见派发简报 | VC-1 grep 双锚=1/≥6；recall 卡含 94 行 | 15min | 2f/45l/15min | 无 | S1 | pending |
| S3 | discipline SKILL.md 4 处计数+核心 critical-rules.md L194 枚举级联 | 继承 | worktree 内两文件目标行（侦察 file:line） | 4 处计数现值+1；L194 枚举尾含 94 | 10min | 2f/8l/10min | 无 | S2 | pending |
| S4 | CLAUDE.md+README_zh.md 纪元字面 1-93→1-94 | 继承 | worktree 内两文件目标行 | grep "Rules 1-94" 各 ≥1 命中 | 10min | 2f/4l/10min | 无 | S3 | pending |
| S5 | planner README.md+ARCHITECTURE.md 纪元+计数+演进史级联 | 继承 | worktree 内两文件目标行（含 L122 演进史追加行） | 逐处现值+1/+94；演进史含 94 行 | 10min | 2f/14l/10min | 无 | S3 | pending |
| S6 | 主 SKILL.md 5 处 1-94+计数+E 类段指针句 | 继承 | worktree 内 SKILL.md L9/L17/L196/L209/L251+L174 段尾 | VC-2/VC-6 grep 锚全命中；wc -l ≤275 | 15min | 1f/12l/15min | 无 | S2 | pending |
| S7 | worktree 内 git 逐 Phase 提交（Rule 27） | 继承 | worktree 仓根 | git status 干净；提交信息含任务代号 | 5min | 0f/0l/5min | 无 | S2-S6 | pending |

### Phase 3: 回归验证与 Code Review
- [x] 全量 selftest 跑批（S8/S8b/S14/S16 四轮，终态 9021b43 fresh 92/92 FAIL=0 exit 0）
- [x] critic 独立审查 diff（S9 首轮 CHANGES_REQUESTED 15 项→复审 APPROVED，检查点 12/18）
- [x] 缺陷回修（fix-phase S10-S13+S15 全闭环：7d9a6e4 + 9021b43 两笔 fix 提交）
- **V-N:** VC-3（S16 终证据）, VC-2（CR 复审独立复算 77 口径一致）
- **Status:** complete
- **Executor:** code-runner-agent（S8）；critic（S9）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S8 | 全量 selftest 跑批出报告 | code-runner-agent | worktree 仓根；命令 `bash skills/task-planner/scripts/run-selftests.sh` | FAIL=0（exit 0），输出落 progress | 15min | 0f/0l/15min | 无 | S7 | done（91/92，唯一 FAIL=PR-02 账本时序，land 后闭环） |
| S9 | CR diff 审查出 verdict | critic | worktree 内 `git diff master...HEAD` 全量 | APPROVED/CHANGES_REQUESTED+逐项意见 | 15min | 0f/0l/15min | 无 | S8 | done（CHANGES_REQUESTED：2 P1+11 P2+2 NIT→S10-S13 修复） |
| S10 | CR 修复：Rule 94 正文七处（P1-2+P2-5..9+NIT-1） | executor | worktree critical-rules-discipline.md 94 段 | CR P1-2/P2-5..9/NIT-1 逐项闭环 | 15min | 1f/12l/15min | 无 | S9 | done（6/6，提交 7d9a6e4） |
| S11 | CR 修复：SKILL 77 条口径×2+README 行内注记（P1-1+P2-1） | executor | worktree 主 SKILL.md+planner README.md | 75→77×2；注记 +Rule 94→77 | 10min | 2f/6l/10min | 无 | S9 | done（4/4，提交 7d9a6e4） |
| S12 | CR 修复：ARCH 注记/措辞+CLAUDE 纪元注释（P2-1/2/3/10） | executor | worktree ARCHITECTURE.md+CLAUDE.md | 注记 77 一致；召回卡措辞；注释链 | 10min | 2f/8l/10min | 无 | S9 | done（3/3，提交 7d9a6e4） |
| S13 | CR 修复：README_zh 纪元注释+93 表行补登（P2-4/10+NIT-2） | executor | worktree README_zh.md+discipline SKILL.md | 注释链；索引表 45 行=计数 | 10min | 2f/5l/10min | 无 | S9 | done（3/3，提交 7d9a6e4） |
| S14 | 修复后全量 selftest --fresh 复跑 | code-runner-agent | worktree 仓根 | FAIL=0 exit 0 | 15min | 0f/0l/15min | 无 | S10-S13 | done（92/92，7d9a6e4） |
| S15 | CR 复审 APPROVED→非阻断 5 项顺手收口（P2-A/B+NIT-1/2） | executor | worktree discipline 正文+README+ARCH | 5 处 1 行级修复 grep 锚 | 10min | 3f/5l/10min | 无 | S14 | done（3/3，提交 9021b43） |
| S16 | 终态 HEAD 全量 --fresh 复跑（VC-3 终证据） | code-runner-agent | worktree 仓根 | 92/92 exit 0 | 15min | 0f/0l/15min | 无 | S15 | done（92/92，9021b43） |

### Phase 4: 合并回+收口交付
- [ ] 全 VC 复验（verification-gate run-verification.sh）
- [ ] smart-merge-back 合并回 master（--no-ff）+ worktree/分支清理
- [ ] 主仓 Read 复验 + rule-reserve land 94
- [ ] 归档计划：check-complete exit 0 后先 `bash skills/task-planner/scripts/set-active-plan.sh --clear` 再 `bash skills/task-planner/scripts/archive-plan.sh task-focus-plan-split-20261023 --root /mnt/data/dev/task-planner-skill/plans`（Rule 81；守卫拒绝时登记理由不强移）
      <!-- task-kb-auto-capture-20261022 增：收尾主动触发——归档与知识提取为收尾默认动作，勿依赖人想起手动跑 -->
- [ ] 知识提取入库（项目存在 scripts/kb-sync-from-plan.sh 则必做）：`bash scripts/kb-sync-from-plan.sh <plan-dir>` 生成 draft → 精炼改名 → `bash scripts/kb-rebuild-index.sh`（路径基准双轨：kb-* 脚本实体在仓库根 scripts/）
- [ ] 交付总结（delivery-summary 五要素，Rule 48/76）
- **V-N:** VC-4, VC-5
- **Status:** pending
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!--
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①=本任务计划目录未跟踪[预期内]；信号③=遗留 wt/task-v168-machine-parked 旧分支[非本任务范围，不处置]；信号④=7 未完成任务在册[并行常态，禁触他任务文件]） |
| `isolation` | `worktree`（§十一.1.1 技能文件=保护区硬条款） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-focus-plan-split-20261023` |
| `branch` | `wt/task-focus-plan-split-20261023` |
| `merge_back` | `pending` |

> 契约详见 `${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/references/worktree-isolation.md`。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2 | 级联 Edit 锚失配（行号漂移/字面不匹配） | 6 | 4 | 3 | 72 | executor 内 Read 目标行后按字面 Edit；失配即上报主进程换锚（22.3② 拆细） |
| Phase 3 | selftest 意外破裂（侦察未覆盖锚） | 7 | 3 | 2 | 42 | 读 FAIL 断言行→修字面或放宽锚（判例 19e66fe 补回范式）→重跑 |
| Phase 4 | 合并冲突（master 间隙前进） | 6 | 3 | 3 | 54 | 并集解（取覆盖侧+保留双方语义，90.3）；复验后强推不动历史 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填；本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链。

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-23 | S1 映射 |
| Phase 2 | ☑ | 2026-10-23 | S1 映射 |
| Phase 3 | ☑ | 2026-10-23 | S1 映射 |
| Phase 4 | ☑ | 2026-10-23 | S1 映射 |

> 契约详见 `references/todo-sync.md`。

## Key Questions
1. Rule 94 归属卫星？→ 已裁决：task-discipline（管辖=处置动作面；判例先例+破裂面最小）
2. 重大偏差与计划内微偏的边界？→ 94.2 管辖二分（换目标=跨计划级；方向细节漂移=Rule 64/61）
3. 部署位是否同步？→ deferred 待用户授权（宪法 §六+判例先例），交付时列入下一步建议

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| Rule 94 归 task-discipline 卫星 | 管辖=偏差处置动作面（纪律域）；Rule 90/92/93 九x纪元全在 discipline；drift 方案需改 3 处 DCS-09 守护字面（破裂面大） |
| L0-T 文本优先：零新增 selftest/守护脚本/config 键 | 宪法 §四.6+Rule 38.7：守护机器化=opt-in，用户未显式要求；Rule 93 判例同款零新增 |
| 部署位同步 deferred | §六 保护区写入须显式授权；task-v195 等判例先例（交付时列入下一步建议） |
| D1 计划确认走 Rule 44.3 自动通过 | 完成性指令（/goal）+自主执行模式；登记自动裁决记录五要素于 progress.md |
| SKILL.md 指针句挂 E 类段尾 | 侦察 L174 处置句为最贴插入点；BP-08 边距 267/275 余量 8 行 |
| S7 主进程吸收（git 白名单①） | 单次 git add scope+commit 为纯编排，派发开销>收益；登记例外理由（v141 先例） |
| land 94 前置到 worktree（Phase 3 内） | S8 PR-02 实证 reserved 悬空即 FAIL；前置 land 使账本与正文同一 merge 入 master，消除「landed 无正文」窗口；语义与「合并后 land」等价（R20.6） |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| scripts/session-catchup.ts 仓内不存在（SKILL 示例路径与仓结构差异） | 1 | 跳过（无恢复需求），直接 init-session.sh | 仓结构差异先 ls 探测再跑脚本 |
| Explore 子代理首次派发 provider 失败（Model request failed） | 1 | 按 22.3① 改派 general-purpose 成功 | provider 失败即改派禁重试同型 |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-23 Phase 1 翻转前 | ✅ALIGNED | VC-4/VC-1 | Goal↔用户原话零漂移；scope 零触碰；检查点 02-drift-check-p1.md+ledger 已留痕 |
| 2026-10-23 Phase 2 翻转前 | ✅ALIGNED | VC-1/VC-2/VC-6 | 3ea1dbc 恰为 scope 9 文件零越界；CA-1..CA-11 逐项在位；检查点 09-drift-check-p2.md |
| 2026-10-23 Phase 3 翻转前 | ✅ALIGNED | VC-3 | 提交序列 2d978e0→9021b43 零越界；CR APPROVED+92/92 fresh 互证；检查点 21-drift-check-p3.md |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 4 |
| 主进程直做 Phase 清单 | Phase 4（例外理由:① git 编排+② 簿记——Rule 25.3 白名单） |
| 委派率 | 0.75（≥ floor 0.7 达标） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-23 | Explore | Rule 94 级联面扫描 | failed | provider 首派失败 | - | - | - | 改派 / 0 / ☐ |
| 2 | 2026-10-23 | general-purpose | Rule 94 级联面扫描（改派） | done | 判例 10 文件清单+锚全宽容+归属=discipline | 01-explore-cascade.md | §Research Findings | plans/task-focus-plan-split-20261023/subagent-state/01-explore-cascade.md | - / 1 / ☑ |
| 3 | 2026-10-23 | general-purpose | Phase 1 偏移检查（改派） | done | ALIGNED：Goal↔原话零漂移 scope 零触碰 | 02-drift-check-p1.md | progress P1 | .../subagent-state/02-drift-check-p1.md | - / 0 / ☑ |
| 4 | 2026-10-23 | executor | S2 Rule 94 正文+召回卡行 | done | 正文 L605-615+卡 L39；5/5 | 03-impl-s2.md | progress P2 | .../subagent-state/03-impl-s2.md | - / 0 / ☑ |
| 5 | 2026-10-23 | executor | S3 卫星 SKILL 计数+核心枚举 | done | 5 处级联；发现 93 表行遗留 | 04-impl-s3.md | progress P2 | .../subagent-state/04-impl-s3.md | - / 0 / ☑ |
| 6 | 2026-10-23 | executor | S3b 索引表 94 行（CA-11） | done | 表行 L75+落盘状态句；4/4 | 05-impl-s3b.md | progress P2 | .../subagent-state/05-impl-s3b.md | - / 0 / ☑ |
| 7 | 2026-10-23 | executor | S4 CLAUDE/README_zh 纪元 | done | 3 处活跃字面；注释保留 | 06-impl-s4.md | progress P2 | .../subagent-state/06-impl-s4.md | - / 0 / ☑ |
| 8 | 2026-10-23 | executor | S5 README/ARCHITECTURE 级联 | done | 13 处+演进史 94 行 | 07-impl-s5.md | progress P2 | .../subagent-state/07-impl-s5.md | - / 0 / ☑ |
| 9 | 2026-10-23 | executor | S6 主 SKILL 级联+指针句 | done | 实质 6/6（AC-1a 措辞 artifact 裁决接受） | 08-impl-s6.md | progress P2 | .../subagent-state/08-impl-s6.md | - / 0 / ☑ |
| 10 | 2026-10-23 | general-purpose | Phase 2 偏移检查（改派） | done | ALIGNED：scope 9 文件零越界 | 09-drift-check-p2.md | progress P2 | .../subagent-state/09-drift-check-p2.md | - / 0 / ☑ |

## 🔁 模板感知
<!-- template_type: rule-enhancement -->
- 触发信号: init 期类型空缺落 general 兜底 → 计划定稿改判 rule-enhancement（变体在位 templates/variant/rule-enhancement-type.md）
- Rule 34.3②: 沉淀评估=rule-enhancement 变体已存在，无需沉淀
- 处置登记处: 不沉淀理由=变体既有在位（二选一必填）
