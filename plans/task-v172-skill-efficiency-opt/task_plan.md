# Task Plan: task-planner 技能执行效率与质量优化（低复杂度任务数小时不完成根因诊断 + 落地）
execution_lane: L1
plan_tier: standard
<!-- 
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC（核心问题的可观察解决证据，非手段产物完成）；目标型任务终验必填「🎯 核心目标达成裁决」区块（58.5） -->

- **R1**: 「我让去改造一个技能，让在创作视频的时候，按照一定的模板方式去执行（生成视频用提示词，按一定规范、按特定模板去生成），这种任务复杂度应该不是很高，为什么执行了好几个小时都不执行完？」<sub>（[目标]）</sub>
- **R2**: 「当前这个技能解决问题效率太低了，质量也不可（很）好。我希望优化质量以及效率。」<sub>（[目标]）</sub>
- **R3**: 「（sess_af21a26a 视频提示词修正任务至今没执行完，严重不合理）就这么一点东西，就这么点工作，来回折腾了多次读取 Task 文件。这么频繁的读取有必要吗？是不是可以每隔多少步才限制更新一次？当前这种更新频率是否会导致效率急剧降低？」<sub>（[目标]）</sub>
- **R4**: 「当前的就是验证机制还是存在问题，因为我发现执行很久之后，执行错了之后还是没有办法纠正，纠偏机制还是存在设计缺陷。我希望在复合的时候，将用户原始的需求进行审查，与当前执行的步骤进行复合，检查偏移性。因为用户原始的诉求才最能表达真正的目的，最能体现是否偏移。将原始数据、用户原始对话（用户多轮提交的相关需求）都进行复合，与文档进行对应，确保不会偏离用户核心需求；遇到偏移应及时打回重做/修正/调整等补救。」<sub>（[目标]）</sub>
- **R5**: 「我之前一直强调的是将纠偏机制放到单独的子代理去执行，但是当前不知道有没有正确的执行过。在子代理去审核任务的执行，避免上下文中盲目自信带来的错误的污染（幻觉）。」（实证：drift-checker 检查点仅 task-v146/v160/v169 有，v160 后约 10 个任务零执行痕迹）<sub>（[目标]）</sub>
- **R6**: 「任务执行的时候，遇到问题应该进行优化，在不降低性能的情况下进行优化。」<sub>（[手段]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-3 | findings.md 有 sess_af21a26a 时间线（锚点行）+ ≥3 项优化落地 |
| R2 | VC-3, VC-4, VC-5 | selftest FAIL=0 + 质量门断言在 + 审查结论登记 |
| R3 | VC-2, VC-3 | 开销清单含计划文件读写频次条目 + 限频机制机器断言（grep 命中） |
| R4 | VC-7 | drift-checker 载体含 user-session-log 原话锚 + selftest 断言命中 |
| R5 | VC-7, VC-8 | 纠偏执行率机器可观测（DRIFT-GATE 或执行留痕断言） |
| R6 | VC-4 | 回归 FAIL=0（优化不降质量） |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/<task-id>/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/<task-id>/user-session-log.md`（模板 = templates/user-session-log.md）
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
[查明 task-planner 技能在低复杂度任务上耗时数小时的根因（以 sess_af21a26a 视频提示词修正任务为样本），落地针对性效率/质量优化（含 R3 点名的计划文件读写限频机制），并以机器守护+回归零 FAIL 验证。]

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
       templates/verification.md 的 `V-N.N` 项，映射目标须为已定义 VC 编号）。
       check-complete.sh 终验 VC-GATE 段机械校验（config.json vc_gate_enforce，默认 warn）。
-->

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 耗时根因取证落盘：sess_af21a26a 视频提示词修正任务的时间线/回路/耗时点逐条有锚（文件+行号/会话日志行） | 读 findings.md+evidence 子代理检查点+主进程抽查 | plans/task-v172-skill-efficiency-opt/findings.md、subagent-state/*.md |
| VC-2 | 开销结构分析落盘：harness 每轮固定开销（hook 注入/计划背书/同步/提醒）逐项列出，量化低复杂度任务端到端成本 | Explore 子代理报告+主进程复核 | findings.md 开销清单节 |
| VC-3 | 优化落地：至少 3 项可机器验证的效率优化进入 skill 文件（含 R3 点名的计划文件读写限频机制），每项有机器守护断言 | grep/selftest 断言通过 | skills/task-planner/** 对应文件+selftest |
| VC-4 | 回归零破坏：全仓 selftest 套件 FAIL=0（对比基线不得新增 FAIL） | 跑 scripts/ 下全部 selftest-*.sh | 主进程汇总逐行 rc=0 |
| VC-5 | 质量不回退：新规则/改动不改弱质量门（VC/反造谣/验证独立性），alignment 与 CR 结论登记 | alignment-review/verifier 子代理结论落 findings | findings.md 审查节 |
| VC-6 | 部署位同步：优化后四部署位与主仓 diff=0（或登记豁免理由） | install 对比/diff | findings.md 部署行 |
| VC-7 | 复合审查输入在位：drift-checker.md 判定锚含 user-session-log 用户原话（E1/E2）+ selftest 断言命中 | grep + selftest-drift-check-subagent DCS-新断言 | drift-checker.md:22/36 + selftest |
| VC-8 | 纠偏执行率机器可观测：check-complete 或 hook 有 DRIFT-GATE（env 开关，默认 warn）对已完成多 Phase 任务零 drift-checker 检查点出信号 | grep DRIFT-GATE + 冒烟 | check-complete.sh |

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
| G1 | <示例> | | <命令+判据 或 路径+关键行> | S1/Phase 1 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | worktree skills/task-planner/scripts/{zcode-userpromptsubmit,zcode-posttooluse}.sh、config.json | 其他 .sh/.cjs/.ts |
| 测试 | worktree skills/task-planner/scripts/selftest-{reliability-institution,agent-coverage,requirement-grading,decision-drift,four-file-dataflow,media-dispatch,ask-default-timeout,capability-persistence,context-pressure,self-resolution,media-agents,requirement-coverage,session-log,iteration-persistence,workflow-orchestration,lane-advancement,tool-selection,summary-readability}.sh（仅 44→46 键数锚级联） | 其他测试文件 |
| 配置 | worktree skills/task-planner/config.json（仅 smart_inject_type_gate/smart_inject_interval/light_tier_interval_multiplier 三键） | 其他配置 |
| 文档 | [明确列出，如 README.md] | 其他文档 |

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
| CA-1 | worktree skills/task-planner/scripts/zcode-userpromptsubmit.sh smart 注入段（:124-188）+ config.json smart_inject_type_gate（:443） | 修改 | 增量 | R3「每隔多少步才限制更新一次」；S2 证据 D-1（每轮无条件注入 1-1.5KB/0.22-0.26s 复利） | 注入前比 Goal/Next Step/Current Phase 三行文本（哈希快照），无变化则跳过注入；type gate 默认 off→on |
| CA-2 | worktree config.json 提醒周期键（:196-242）+ zcode-posttooluse.sh P1-P4 读取段 | 修改 | 增量 | R3；S2 证据 D-2（15/20/25min+10calls 全 tier 统一，低复杂度被反复打回写） | 周期按 plan_tier 分档：mini/L0 时长按 2×（30/40/50min、calls 30），standard/L1/L2 保持现行；新增键 tier_aware_intervals 默认 on |
| CA-3 | worktree zcode-posttooluse.sh drift-rhythm 段（:81-84/:230-246） | 修改 | 增量 | S2 证据 D-4（每调用 3×sed+9×cut 进程孵化，降频回退史） | 3×sed 合 1 次 awk 读、9 字段 cut 合 1 次 awk；count 每调用 +1 的 N1 节奏不变 |
| CA-4 | worktree check-dispatch.sh checkpoint 契约校验段 | 修改 | 增量 | RC5：Explore 等只读 agent 无 Write 工具，契约强制 checkpoint 落盘→主进程代写往返（本次 S1/S2 双实证 + videop1 空返回） | 只读类 Executor 的 checkpoint 自动降级为「返回消息代写」模式（校验从文件存在改为代写登记），消除误拦 |
| CA-5 | worktree zcode-sessionstart.sh [task-resume] 段（:18-28） | 修改 | 增量 | S2 证据 D-3/C-01（每会话无条件注入 top-3 陈旧未完成任务，7 个 stale in_progress 制造噪音） | in_progress 任务 >0 时注入维持；为 0 时跳过注入（已具备）；有值但全 >7 天未更新时折叠为单行「N 项历史任务（未更新>7 天），按需 plan-resume」 |
| CA-6 | worktree SKILL.md 投诉响应协议段（:147-152）+ references/critical-rules.md 新增 Rule 83 | 新增 | 增量 | videop1 D6 判例（CreateWorkflow 无 Skill 工具 3 次重试全拦）+ R2 质量诉求 | Rule 83 通道不可达快速失败：/workflow 请求先探测 Skill 工具面，缺失即登记环境缺口+给三选项（换环境/Agent 替代授权/主进程直执行授权），禁 ≥2 次同法重试；配 selftest 断言 |
| CA-7 | worktree drift-checker.md（SOP 步骤1 + 三锚①）+ zcode-posttooluse.sh [drift-rhythm] 提醒 + selftest-drift-check-subagent.sh 断言 | 修改 | 增量 | R4/R5：纠偏复合审查须拿用户多轮原话（user-session-log.md）对照执行查偏移，非仅转译 R 条目 | ① Goal 原文锚 升级为「user-session-log 全部原话 + task_plan R 条目双源（原话优先，Rule 80.4）」；[drift-rhythm] 提醒加复合审查指引；selftest 守护 |
| CA-8 | worktree check-complete.sh（镜像 DELEGATION GATE 范式，env 开关 TASK_PLANNER_DRIFT_GATE_ENFORCE 默认 warn） | 新增 | 增量 | R5：纠偏子代理 v160 后零执行（0% 执行率），需机器门控强制 | 终验 DRIFT-GATE：已完成多 Phase 任务若 subagent-state 无任何 *drift* 检查点→出 [DRIFT-GATE] 行（默认 warn 不拦，enforce 可配置为硬拦）；让纠偏执行率机器可观测 |

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
**核心问题**: 低复杂度任务（如"改造技能使视频创作按模板执行"）为何耗时数小时不完成？根因是 harness 每轮固定开销过高（计划文件读写/hook 注入/同步/提醒频次失控）+ 路由未按复杂度降载。解决后低复杂度任务应分钟级完成且质量不回退。

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
[下一轮（本任务续）：CA-1/2/3/4/5/6/7/8 全部完成；Phase 4 收口=全仓回归+部署同步+报告；master 0817eef+13a23ab 已 push origin+四部署位同步；如需进一步优化找新 issue 挖掘]

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore(mini)×2 | 取证类只读分析，隔离上下文防主进程上下文膨胀（§一） |
| Phase 2 | 主进程 | 设计+裁决，计划系统文件维护白名单 |
| Phase 3 | Agent 子代理 code-assistant（haiku-1） | 落地改动，隔离执行 |
| Phase 4 | 主进程+verifier | 回归+部署+报告 |

**workflow 编排判定（Rule 40.4）**: [未命中编排条件 → 按 Rule 21.4 独立性守门调度（并行默认+声明组，未声明=串行，10-02）;命中（独立并行子任务可 fan-out / 长链多 skill 接力可复用 / 用户点名）→ 登记"建议 CreateWorkflow"并按 Rule 39.4 做并行豁免登记（Decisions Made + progress）]
**/goal 对齐（Rule 40.3）**: [本计划 Goal+VC 即 session goal 的证据源;如用户已用 /goal 锚定本任务,在执行范围或 Goal 段注明映射;/goal 为用户侧 harness 命令,技能层不可代调]

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 取证与根因（sess_af21a26a 视频任务时间线 + harness 开销结构）
- [x] S1 会话日志取证：sess_af21a26a 视频提示词修正任务时间线/回路/耗时点
- [x] S2 开销结构分析：harness 每轮固定开销清单 + 低复杂度任务端到端成本
- [x] 主进程综合根因（≥3 条，含 R3 计划文件读写频次）
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** explore（mini）×2 并行
- **落地证据:** findings.md `[sub:s1-explore]`+`[sub:s2-explore]` 节 + subagent-state/s1/s2 检查点
<!-- 
  STATUS VALUES:
  - pending: Not started yet
  - in_progress: Currently working on this
  - complete: Finished this phase
-->

### Phase 2: 优化设计与裁决
- [ ] 主进程设计优化方案（含 R3 限频机制），填变更标注表
- [ ] 用户裁决点（如有）
- **V-N:** VC-3
- **Status:** pending
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: 落地（改 SKILL/rules/scripts/templates + selftest 守护）
- [x] CA-1 UPS smart 注入限频（变更触发+周期兜底）+ type gate 默认 on（S3 落盘）
- [x] CA-2 提醒周期按 plan_tier/execution_lane 分档（mini/L0 ×mult）
- [x] CA-3 drift-rhythm 进程孵化合并（2sed→1awk / 8cut→1awk）
- [x] config 键数守护锚级联 44→46（17 selftest，S4 落盘）
- [x] CA-4（**完成 2026-10-13**：22.8.6 只读 Executor checkpoint 主进程代建豁免，worktree commit 1bee3b4 → merge 87bb3b6，四部署位同步，回归 77/77 + task-dispatch 42/42）
- [x] CA-5/CA-6（**完成 2026-10-14**：CA-5 SessionStart 陈旧任务折叠 + CA-6 Rule 83 通道不可用快速失败；worktree 50e08e9 → merge 0817eef + CA-5 bug 修正 13a23ab；四部署位同步；回归 78/78）
- [x] CA-7 复合审查=drift-checker 判定锚升级为 user-session-log 用户多轮原话 + task_plan R 双源（原话优先，Rule 80.4）+ [drift-rhythm] 提醒指引 + DCS-21 守护（S5 落盘）
- [x] CA-8 纠偏执行率 DRIFT-GATE：check-complete 终验多 Phase 零 drift-checker 检查点→告警（env TASK_PLANNER_DRIFT_GATE_ENFORCE，默认 warn 不拦，机器可观测 R5 的 0% 执行率问题）+ CD-07 守护（S5 落盘）
- [x] 收口：merge --no-ff 419573b 入 master + 四部署位同步 + push origin（用户已授权；~/.zcode IDENTICAL；主仓 75/2 FAIL 归因并行扫荡与本任务零相关）
- [x] CA-4 收口：worktree task-v172-ca4 commit 1bee3b4 → merge --no-ff 87bb3b6 入 master + worktree/branch 清理 + 四部署位 git-archive 同步（逐位 grep 22.8.6/待主进程代建 命中）+ push origin 419573b..87bb3b6（回归 77/77 + task-dispatch 42/42）
- **V-N:** VC-3, VC-7, VC-8
- **Status:** complete（CA-1/2/3/4/5/6/7/8 全部完成；CA-5/6 merge 0817eef + fix 13a23ab；回归 78/78）
- **Executor:** code-assistant（haiku-1）via S3/S4/S5 子代理 + 主进程 CA-5/6
- **提交:** master 0817eef + 13a23ab（已 push origin；worktree 已清理）

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
| S1 | 会话日志取证：sess_af21a26a 视频提示词修正任务时间线/回路/耗时点 | explore(mini) | 会话日志路径（子代理自定位 ~/.zcode 下）+ ≤10 行摘要 | findings.md 时间线节+检查点 | ≤15min | 1f/30l/15min | 无 | - | pending |
| S2 | 开销结构分析：harness 每轮固定开销（hook/计划背书/同步/提醒）清单+低复杂度任务端到端成本 | explore(mini) | skills/task-planner/scripts/ 清单+SKILL.md 路由段 | findings.md 开销清单节+检查点 | ≤15min | 1f/30l/15min | 无 | - | pending |

### Phase 4: 回归验证 + 部署 + 报告
- [x] 全仓 selftest FAIL=0（78 中唯 1 FAIL=RG-04 归因并行会话模板扫荡，与本任务零相关）
- [x] 部署位同步 diff=0（4 位 CA-5/6 5 文件逐位核验）
- [x] 交付报告（根因+优化+效果）
- **V-N:** VC-4, VC-5, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

### Phase 5: Delivery
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [x] Review all output files
- [x] Ensure deliverables are complete
- [x] Deliver to user
- **V-N:** VC-3, VC-4, VC-6, VC-7, VC-8
- **Status:** complete
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
| `conflict_scan` | `risk`（工作区有 23 文件未提交模板扫荡+多并行会话，见 git status） |
| `isolation` | `worktree`（实现类默认首选；本任务改 skills/task-planner/** 运行中基础设施） |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v172-skill-efficiency-opt` |
| `branch` | `wt/task-v172-skill-efficiency-opt` |
| `merge_back` | `merged(419573b)`（master 已 push origin；部署位 4 个已同步） |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

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

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

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
| 2026-10-14 完成收口：Phase 3/4/5 标 complete + CA-5/6 勾选 + Next Step 更新（master 5cd68ae） | CA-5 SessionStart 折叠 + CA-6 Rule 83 全部落地并 merge+push+四部署位；Phase 4 回归 78 中唯 1 FAIL=RG-04 归因并行会话模板扫荡与本任务零相关；属任务推进非计划内容篡改，故登记后重 attest 重锁 |

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
  完整模板: templates/batch_report.md | 规则详解: references/batch-quality-gate.md
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
  派发 prompt 八字段模板: templates/subagent_dispatch.md
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
