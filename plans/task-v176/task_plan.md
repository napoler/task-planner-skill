# Task Plan: [Brief Description]
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

- **R1[目标]**: 「挖掘出当前的就是在运行过程中的存在的问题」
- **R2[目标]**: 「当前技能核心工作就是回归，最重要的就是记录，如实记录，记录整个过程中产出的数据以及锚定数据」
- **R3[目标]**: 「确保整个过程中，上下文中不会出现偏移以及幻觉。还有就是前后对照，然后解决解决幻觉以及遗忘问题」
- **R4[手段]**: 「主动依主动依赖于基于上下审查来发现问题。就是主动发现不合理，然后进行改正」
- **R5[目标]**: 「核心就是提高整个嗯整个整整个运行的准确性。记住当前技能回归最核心的功能就是整个任务过程中的记录以及追踪，还有就是纠正纠正纠正错误。纠正偏移，核心就这些功能，其他的都属于辅助功能，不是属于主要功能」

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | findings.md「问题清单」≥8 条实证缺陷，每条含证据路径/命令输出/行号 |
| R2 | VC-1, VC-3 | 记录/追踪/纠错/纠偏四域机制缺口逐条有根因+修法（findings+变更标注表） |
| R3 | VC-2, VC-4 | 簿记失真量化（INDEX vs git 真实状态对照表）+ 修正后 selftest 无回归 FAIL=0 |
| R4 | VC-3, VC-4 | 修正 landed 到 worktree 并通过 selftest（不只是提案） |
| R5 | VC-1, VC-4, VC-5 | 核心域缺陷修复在仓+部署位一致（diff=0 或登记），准确性提升可由机器复验 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/<task-id>/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/<task-id>/user-session-log.md`（模板 = ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）

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
[一条：挖掘并修正 task-planner 技能运行期核心功能（记录/追踪/纠错/纠偏）的实证缺陷，消除状态失真/归档失效/偏移失守等幻觉与遗忘风险，使技能准确性提升可被机器复验]

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a` / `required` |
| `session_id` | `<uuid>` | 启动时生成,注册表追踪 |
| `worktree_path` | `<path>` | §十一 隔离决策已有字段 |
| `scope_files` | `[paths]` | 从「执行范围限制」解析,并发检测基础 |
| `interaction_mode` | `ask` / `silent`（可省略，缺省回落 config.json#interaction_mode） | Rule 28 交互模式：ask=关键决策点给选项；silent=静默+静默决策清单登记 |
| `对齐审查` | `[登记]` | Rule 42.6 消费：任务产出或更新的文档在完成前跑 alignment-review 对齐审查（标准收尾流程）;文档更新前跑版本一致性校验（未经校验不追加）;变更记录随交付物落盘;mini 档豁免（42.6.4） |
| `自动超时默认项` | `[询问点: 默认选项/超时值]` | Rule 44 消费：本任务所有 2+ 选项询问点逐个登记默认选项（推荐项）与自动超时时长（默认 5 分钟,可覆盖）;低区分度选项（产出一致仅步骤/耗时差异）不询问、直接裁决并登记理由（44.2）;用户超时未答复按默认选项自动执行+登记自动裁决记录五要素（44.3）;mini 档豁免（44.4） |
| `new_rule` | `<NN>` / 留空 | Rule 20.6：本任务新增 Rule 编号时填写（attest 自动预留+查重；无则留空） |
| `质量审查工具` | `[检测结论]` | Rule 42 消费登记（42.4）：任务涉及质量审查面时按 42.2 四级检测（含内置 review-library 兜底池）,填 技能名/既有 agent 名/待补充 S-unit 指针;缺口按 42.3 补建并登记 S-unit;执行期必须用登记工具;mini 档豁免（42.5） |

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
| VC-1 | 问题清单 ≥8 条实证缺陷（每条含证据：绝对路径+行号/命令输出），覆盖记录/追踪/纠错/纠偏四域 | `grep -c "^\- D[0-9]" plans/task-v176/findings.md` ≥8 + Read 逐条复核证据列 | plans/task-v176/findings.md |
| VC-2 | 簿记失真量化：INDEX.md 在册 8 个未完成任务逐个有 git 真实状态对照（complete-but-listed/in_progress 计数） | Read findings.md「## 簿记失真对照」表 + `git log --oneline` 抽查 ≥3 条 | plans/task-v176/findings.md |
| VC-3 | 每条缺陷有根因+修法；修正已 landed（worktree 内）且机器验证在位 | `cd <worktree> && grep -c "<修复签名>" <文件>` + selftest 断言 | worktree 绝对路径 |
| VC-4 | 修正后仓内 selftest 全集 FAIL=0（基线由 Phase 1 记录，对比零回归） | bash skills/task-planner/scripts/run-all-selftest.sh（入口名以 Phase 1 实测为准） | 终端输出 + progress.md |
| VC-5 | 部署位（~/.zcode/skills/task-planner）与主仓技能文件一致 | `diff -r skills/task-planner ~/.zcode/skills/task-planner` 无差异或登记差异清单 | 终端输出 |

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
| G1 | 记录域审计 | 挖掘记录/锚定机制缺口 ≥5 条 | `grep -c "^- " plans/task-v176/subagent-state/1-explore.md` ≥5 + 抽查行号真实存在 | S1/Phase 1 | pending |
| G2 | 脚本基线 | selftest 全集基线数值+脚本缺陷 ≥3 条 | Read plans/task-v176/subagent-state/2-code-runner-agent.md 基线段 | S2/Phase 1 | pending |
| G3 | 簿记对照 | INDEX 8 任务 git 真实状态失真表 | Read plans/task-v176/subagent-state/3-general-purpose.md | S3/Phase 1 | pending |
| G4 | 修正落地 | P0/P1 修正 in worktree + selftest FAIL=0 | worktree 内 selftest 输出 | S4/Phase 3 | pending |
| G5 | 终验一致 | 合并回+部署 diff=0+VC 全 PASS | diff -r 输出 + check-complete exit 0 | Phase 4 | pending |## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 计划文件 | `plans/task-v176/**` | 其他 plans/ 目录（他人 34 个未提交变更所在，禁碰） |
| 修正源码 | `skills/task-planner/**`（仅按 findings 修正清单逐条登记的文件） | 其他 skills/ 卫星、~/.zcode/ 记忆文件 |
| 临时产物 | `/mnt/data/dev/task-planner-skill-worktrees/task-v176/**` | 主仓直接改技能文件（必须 worktree） |
| git | wt/task-v176 分支创建/合并/删除 | 动 wt/task-v168-machine-parked（遗留分支属他人范围，只报告不清理） |

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
| CA-1 | <示例: 文件:锚点> | 新增 | 增量 | <用户原话/证据> | <执行动作> |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 |  |  | 必读/参考 | ☐ |
| 官方文档 |  |  | 必读/参考 | ☐ |
| 项目内部文档/知识库 |  |  | 参考 | ☐ |
| 文献/论文 |  |  | 参考 | ☐ |
| 图书/教程 |  |  | 参考 | ☐ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: [解决这个问题后，结果能交付吗？]

**核心问题判断**:
- [ ] 核心问题解决后，产品/结果能交付吗？
- [ ] 核心问题不解决，其他工作都白费吗？
- [ ] 核心问题的解决方法是清晰的、可执行的？

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| <S-unit id> | LOCAL-ONLY / NET-RESEARCH / NET-DATA-DEPENDENT | <关键词1>、<关键词2> | WebSearch / Doc Search Agent / research-assistant / GitHub CLI / Forum Search Agent | <findings 小节 / 现成实现 / 媒体参考> | <是/否/不适用> |

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
Phase 1

## Next Step
派 3 个子代理并行审计（S1 记录域机制 / S2 脚本验证基线 / S3 簿记失真对照），检查点落盘 plans/task-v176/subagent-state/

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 ×3（Explore / code-runner-agent / general-purpose） | 大文件多路径审计必须隔离上下文（§一 P0）；三路文件集不重叠可并行 |
| Phase 2 | 主进程直做 | 汇总+分级=簿记动作（白名单②），无新信息获取 |
| Phase 3 | Agent 子代理 + git worktree | 技能文件=保护区（§六/§十一），必须隔离开发；code-assistant ≤3 文件硬限制匹配修正集 |
| Phase 4 | 机械守卫脚本（selftest/diff/check-complete）+ git | 终验必须机器证据；合并回走 smart-merge-back.sh |

**workflow 编排判定**: 未命中编排条件（无用户点名 /workflow，任务规模不适用）→ 按 Rule 21.4 独立性守门：Phase 1 三路已过独立性四问，声明 `parallel_groups: [S1,S2,S3]` 并行；Phase 3-4 串行依赖
**/goal 对齐**: 本计划 Goal+VC 即 /goal session goal 的证据源；R1-R5 已逐字落 user-session-log.md #1 + 本文件需求原文区

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 三路并行审计（数据收集）
<!-- WHAT: 3 个子代理并行审计技能核心域：记录机制缺口 / 脚本验证基线 / 簿记失真对照。独立四问核验：文件集（skills/ vs scripts/ vs plans/）不重叠、资源（只读）、输入（各自路径）、验收（各自检查点）互不依赖 → 声明 parallelism: parallel（Rule 21.4） -->
- [ ] S1 记录域机制审计落盘 subagent-state/1-explore.md
- [ ] S2 脚本 selftest 基线+脚本缺陷落盘 subagent-state/2-code-runner-agent.md
- [ ] S3 簿记失真对照表落盘 subagent-state/3-general-purpose.md
- [ ] findings.md 三段增量回填（19.1：子代理返回后紧邻 Edit）
- **V-N:** VC-1, VC-2, VC-3
- **Status:** in_progress
- **Executor:** general-purpose（sonnet-1）

<!-- S-unit 派发单元表（Rule 22.6；三路并行 = parallel_groups [S1,S2,S3]，独立性四问注释见 Phase 描述） -->
| ID | 目标（≤1 句） | 执行体 | 输入（≤2 token） | 验收（可观察） | 预估时长 | 粒度（三值） | 伴飞技能 | 前置依赖 | 状态 |
|----|------|--------|------|---------|------|------|------|------|------|
| S1 | 审计记录/锚定机制缺口（SKILL.md+critical-rules.md 记录条款机器化程度与失效面） | Explore | skills/task-planner/SKILL.md、references/critical-rules.md | 检查点含 ≥5 条机制缺口，每条带 file:line 证据 | 15min | 1f/10l/15min | 无 | - | pending |
| S2 | 跑仓内 selftest 全集记录基线 FAIL 数 + 审 check/archive/index 类脚本缺陷 | code-runner-agent | skills/task-planner/scripts/ | 基线数值+脚本缺陷 ≥3 条带行号 | 15min | 1f/10l/15min | 无 | - | pending |
| S3 | INDEX.md 8 个未完成任务逐个对照 git log 真实状态，量化簿记失真 | general-purpose | plans/INDEX.md | 失真对照表 ≥8 行（任务/git结论/INDEX状态/差异） | 15min | 1f/10l/15min | 无 | - | pending |

### Phase 2: 问题分级与修正方案（主进程）
- [ ] 汇总三路审计 → findings.md「## 问题清单」（编号 D1..，分级 P0/P1/P2）
- [ ] 每条填根因+修法+对应修正文件
- [ ] 变更标注表（Rule 74.3）逐条登记修正动作
- **V-N:** VC-1, VC-3
- **Status:** pending
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: worktree 隔离实施修正
- [ ] `git worktree add /mnt/data/dev/task-planner-skill-worktrees/task-v176 -b wt/task-v176 master`
- [ ] 在 worktree 内按修正清单修技能文件（记录/追踪/纠偏类缺陷）
- [ ] worktree 内 selftest 全集复跑 FAIL=0
- **V-N:** VC-3, VC-4
- **Status:** pending
- **Executor:** code-assistant（haiku-1）
| ID | 目标（≤1 句） | 执行体 | 输入（≤2 token） | 验收（可观察） | 预估时长 | 粒度（三值） | 伴飞技能 | 前置依赖 | 状态 |
|----|------|--------|------|---------|------|------|------|------|------|
| S4 | worktree 内实施 P0/P1 修正（按 findings 修正清单逐条 Edit） | 继承 | 修正清单、worktree 路径 | 修正文件 diff 在位 + selftest FAIL=0 | 15min | 2f/40l/15min | 无 | Phase 2 | pending |

### Phase 4: 合并回+部署同步+终验
- [ ] smart-merge-back 合并 wt/task-v176 → 主仓 Read 复验
- [ ] 部署同步（~/.zcode/skills/task-planner）+ diff 对账（VC-5）
- [ ] 终验 VC 全条复跑 + check-complete + 归档
- **V-N:** VC-4, VC-5
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
| `conflict_scan` | `risk`（信号①34 个未提交变更含 plans/ 归档中目录；信号③遗留 wt/task-v168-machine-parked；信号④5+3 个未完成任务在册——均与本任务 scope 不重叠） |
| `isolation` | `worktree`（实现类：修正对象为技能文件 skills/**，属 §十一.1 保护区） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v176` |
| `branch` | `wt/task-v176` |
| `merge_back` | `pending` |

> 契约详见 `${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/methodology.md §R2）

<!--
  WHAT: 对每个 Phase 枚举失败模式，打 S(严重度)/O(频度)/D(探测难度) 各 1-10 分，RPN=S×O×D。
  WHY: RPN>100 的高风险 Phase 必须预先登记兜底动作（对齐 Rule 22.3 五档兜底链，task-v113 后含 22.3.0 资料先行档），避免执行期临时决策。
  WHEN: 计划创建时填写（高 RPN 项）；纯文档/调研类小任务可写 n/a。
  开关键: config.json#fmea_enforce（默认 warn；enforce 档下 RPN>100 无兜底登记 = 计划无效）。
-->

| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作 |
|-------|---------|---|---|---|-----|-------------|
| Phase 1 | 子代理大输出撑爆主上下文/返回丢失 | 4 | 3 | 3 | 36 | 检查点强制落盘（subagent-state/），主进程只 Read 检查点文件不接收原始大返回（§一.6/Rule 22.8） |
| Phase 1 | 并行三路 scope 重叠互相覆盖 | 3 | 2 | 2 | 12 | 独立性四问已核（skills/ vs scripts/ vs plans/ 文件集不重叠）；冲突即停 |
| Phase 3 | worktree 从 master 创建但 master 有 34 个未提交变更（含他人进行中的归档） | 3 | 3 | 2 | 18 | worktree 用 `git worktree add` 从 HEAD 提交点创建（干净快照），只在 worktree 内写技能文件；不动 plans/ 下未提交变更 |
| Phase 3 | 修正破坏 selftest 存量断言 | 4 | 3 | 3 | 36 | 先跑基线记录 FAIL 数（S2），修正后复跑对比零增量；回滚=git restore 单文件 |

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

> 契约详见 `${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

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
| 用户 /goal 指令即任务授权，按 silent 模式推进（用户不可实时应答=环境事实；关键决策仍登记 Decisions Made） | Rule 28 + autonomous 执行约束；非白名单动作全部走子代理/worktree |
| 编号 task-v176（最新 land=85/v175；v133-v172 存量未清理但不占新号） | plans/.rule-reservations.jsonl + INDEX.md 实测 |
| 隔离=worktree，从 HEAD 创建（非 master 工作区——34 个未提交变更含他人在途归档） | §十一 + 冲突扫描信号① |
| Phase 1 三路并行（文件集 skills/ vs scripts/ vs plans/ 不重叠） | Rule 21.4 独立性四问核验通过 |
| 本轮不新增 Rule 编号，修既有机制缺陷为主；新条款需求装入 findings 建议区待裁决 | 用户 R 指令聚焦"改正不合理"而非扩张规则面；new_rule 留空防编号通胀 |

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
  完整模板: ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/batch_report.md | 规则详解: ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/batch-quality-gate.md
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
  派发 prompt 八字段模板: ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/subagent_dispatch.md
  # [2026-09-27 task-v091 B-2] 单写者澄清+Handoff 低频列折叠（verify_done 无机器消费如实披露）
-->

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | | | | queued | | | | | - / 0 / ☐ |
| 2 | | | | | | | | | - / 0 / ☐ |
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
