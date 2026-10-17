# Task Plan: 工作流主动激活+模型分级+并行度三缺陷修复（Rule 39/40/91/21.4/68 演进）
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  选定 variant 后 template_type 填所选类型名（白名单=${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/variant/*-type.md 动态派生，见 check-template-type.sh）；general=通用回退（恒合法，Rule 34.1）
  plan_tier ∈ {standard, mini}（Rule 38.1，mini 四条件机器判定）；execution_lane ∈ {L0, L1, L2}（Rule 38.7，缺省 L1；L0 禁滥用见 38.7 末段）
  check-template-type.sh 三形态之一：行首 `^template_type:`（本块）/ 表格行 / HTML 注释；本块用行首形态 -->
template_type: general
plan_tier: standard
execution_lane: L1
parallel_groups:
  - pg-w1
  - pg-w2
  - pg-w3
<!-- 
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC（核心问题的可观察解决证据，非手段产物完成）；目标型任务终验必填「🎯 核心目标达成裁决」区块（58.5） -->

- **R1**: 「第一点就是工作流的工作流的被调用。就比如说就比如说我希望工作流，我工作流产出的时候，就是复杂任务应该启用工作流，主动创建工作流来调用，来推进任务。但是当前我发现，执行多次从来就没有主动创建过工作流推进。」<sub>（[目标]）</sub>
- **R2**: 「我希望是工作流创建时可以在创建的时候选择不同的模型执行，根据嗯根据不同的任务难度执行，就是子代理进行选择，确保不会使用，都使用复杂大模型解决。」<sub>（[目标]）</sub>
- **R3**: 「同时就是在其他任务的时候，如果就是解决解决任务的时候，解决任务的时候，尽量提高非互相影响的子代理的并行效率。也就是说也就是说，遇到的所有问题，就是说如果只要任务不冲突，就是不互相依赖的前提下，可以提高兵法，就是同时推进多个子代理的调用，这样提高任务的速度。」<sub>（[目标]，「兵法」=语音转写误差，语义=并行）</sub>
- 前置定性（R1 引子）：「我发现当前的技能存在一个缺陷，就是需要解决之前设定的目标没有完成。」——三诉求均为既定目标的缺陷修复，非新增功能。

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | collab.md Rule 39.1/39.8 含「常设授权+命中条件主动路由」新语义锚（grep 命中 ≥1）；SKILL.md 摘要行不再含「仅用户显式点名」（grep 计数=0）+含主动激活语义行 |
| R2 | VC-3 | collab.md Rule 91 含与 39.8 激活联动的分档义务锚 + run 级 `subagent_model` 选档条款在位（grep 命中） |
| R3 | VC-4 | dispatch.md Rule 21.4 新增执行期扩组协议子条锚 + 68.2 惰性全串行论证义务锚（grep 命中 ≥2） |
| R1-R3 通用 | VC-5 | 全量 selftest 回归 FAIL=0（含锚级联同步后） |
| R1-R3 通用 | VC-6 | 合并 master + 部署位同步 diff=0（部署需用户授权，完成前为 PARTIAL 保留项） |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/<task-id>/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/<task-id>/user-session-log.md`（模板 = ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 工作流路由决策（计划期「🧰」区块+执行期路由） | Rule 39.1「仅用户显式点名才路由」把主动激活结构性锁死（激活率 0 根因） | S1/S2（39.1 演进+39.8 常设授权） | VC-1 |
| 工作流路由消费面（SKILL.md 摘要行/协同段） | 「仅用户显式点名 /workflow 时路由」字面与 39.1 互锁，双处须同步演进 | S4 | VC-2 |
| 工作流内子代理模型选择（CreateWorkflow 脚本编写期） | Rule 91 分档纪律存在但无激活时机联动（工作流从不被创建→条款空转）；run 级 subagent_model 无按难度选档条款 | S3 | VC-3 |
| 计划期并行分组（68.2 依赖分析→组推导） | 「杜绝惰性分组」仅目标语无义务锚——零并行组全串行计划无论证即通过 | S5 | VC-4 |
| 执行期并行调度（21.4 声明制） | 未声明=串行槽且无执行期扩组通道——执行中新识别的独立单元被迫串行 | S5 | VC-4 |
| selftest 锚守护 | 39.x/21.4/68 既有断言锚定旧措辞，规则演进必级联 | S6/S7 | VC-5 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | ① R1-R3 用户需求原文三条逐字（含"复杂任务/按难度选模型/不依赖即并行"语义） | task_plan.md §用户需求原文 |
| 🔒 不变量 | ② VC 表 VC-1..VC-6 判定标准 | task_plan.md §Verification Contract |
| 🔒 不变量 | ③ Rule 39.2-39.7 机制条款不动（skill 加载门槛/四机制映射/机器校验边界/防遮蔽 P0） | collab.md §39 既有子条 |
| 🔒 不变量 | ④ Rule 91.2 官方矛盾披露不回退（per-subagent 非官方机制+91.5 验证门维持） | collab.md §91.2 |
| 🔒 不变量 | ⑤ Rule 21.4 独立性四问+组间串行语义不回退（10-02 用户裁决保留） | dispatch.md §21.4 |
| 🔒 不变量 | ⑥ 宪法 §四.6 文本优先铁律：不新建机器门/脚本/hook（selftest 既有锚同步除外=级联必须） | AGENTS.md §四.6 |
| 🔒 不变量 | ⑦ L0/mini/trivial 轻量通道边界不动（perf-diagnosis 成果，防全任务 workflow 化滥用） | critical-rules-template.md:45 + discipline.md:191 |
| 🔀 可变量 | 39.1 触发纪律措辞/39.8 新子条编号与内容/40.4 升级措辞/91 联动锚/SKILL.md 摘要行措辞/21.4.2 扩组协议/68.2 论证义务措辞/selftest 锚同步方式 | - |
| 🔀 可变量 | 激活条件门槛参数（≥N 独立 S-unit / ≥N 阶段，方案默认 ≥3/≥3，用户可调） | Decisions #2 |
| 📈 学得量 | 官方工具描述 vs 常设授权的优先级论证措辞/锚级联四形态族清单/部署位差异 | findings.md |

## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and delete functionality."
-->
把 task-planner 工作流路由从「仅用户显式点名」演进为「用户常设授权+命中编排条件主动创建（含按难度模型分档）」，并消除并行调度的声明制惰性串行——使复杂任务实际走 CreateWorkflow 推进、工作流子代理按难度分档、无依赖 S-unit 默认并行。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（规则文本为运行中基础设施条款，重 diff 面虽小但语义敏感） |
| `session_id` | `sess7eb91e2c12b34d1f9f69440471b4cb36` | 启动时生成,注册表追踪 |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v187-workflow-activation-parallel` | §十一 隔离决策已有字段 |
| `scope_files` | `[collab.md, SKILL.md(task-planner), critical-rules-dispatch.md, selftest-workflow-orchestration.sh, selftest-parallel-scheduling.sh(+受级联面)]` | 从「执行范围限制」解析,并发检测基础 |
| `interaction_mode` | `ask` | Rule 28 交互模式：ask=关键决策点给选项 |
| `对齐审查` | `[登记]` 本任务产物=规则条款文本，完成前跑 alignment-review 对齐审查（标准收尾流程） | Rule 42.6 消费 |
| `自动超时默认项` | `[询问点: 激活门槛参数 → 默认 ≥3 独立 S-unit / ≥3 阶段，5min]`；`[部署同步 → 默认 批准后同步四部署位，5min]` | Rule 44 消费 |
| `new_rule` | 留空（演进既有 Rule 39/40/91/21.4/68，不新增编号——39.8/21.4.2 为既有 Rule 的新子条，不占新号） | Rule 20.6 |
| `质量审查工具` | `alignment-review`（既有技能）+ `critic`（既有 agent，方案挑刺） | Rule 42 消费登记 |

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
| VC-1 | collab.md Rule 39.1 演进+39.8 常设授权在位：39.1 含「常设授权」语义且「仅当用户显式调用」不再为唯一触发；39.8 含激活三条件+留痕义务 | grep 断言（在 worktree 与主仓合并后各跑一次） | `grep -n "常设授权" skills/plan-collab-router/references/critical-rules-collab.md`（≥2 命中：39.1+39.8）；`grep -c "仅当用户显式调用" 同文件`（=0 或仅存在于官方红线披露引用上下文=1 且伴「常设授权覆盖」说明） |
| VC-2 | SKILL.md 摘要行演进：不再含「仅用户显式点名」锁死措辞，含主动激活+门槛语义 | grep 断言 | `grep -c "仅用户显式点名" skills/task-planner/SKILL.md`（=0）；`grep -n "主动创建\|主动激活\|命中编排条件" 同文件`（≥1 命中） |
| VC-3 | Rule 91 分档联动在位：91 段含 39.8 激活时机联动锚+run 级 subagent_model 按难度选档条款 | grep 断言 | `grep -n "39.8" skills/plan-collab-router/references/critical-rules-collab.md`（≥2 命中：39.8 定义+91 联动）；`grep -n "subagent_model" 同文件`（≥1 命中于 91 联动子条） |
| VC-4 | 并行强化在位：21.4 新增执行期扩组协议子条（21.4.2）+68.2 惰性全串行论证义务 | grep 断言 | `grep -n "21.4.2\|执行期扩组\|并行升级" skills/task-dispatch/references/critical-rules-dispatch.md`（≥1）；`grep -n "惰性\|全串行.*论证\|论证.*全串行" 同文件`（≥1 于 68.2 段） |
| VC-5 | 锚级联同步+全量回归：受影响 selftest 全部 FAIL=0（worktree 内验证+合并后主仓复验） | 全量 selftest 回归 | `cd <worktree>/skills/task-planner/scripts && for f in selftest-*.sh; do bash $f; done` 汇总 ΣFAIL=0（至少覆盖 workflow-orchestration/parallel-scheduling/tool-selection 三脚本） |
| VC-6 | 合并回主仓 master+部署位同步：scope 文件无未提交变更；四个部署位（~/.zcode/skills 等）与主仓 diff=0 | git 状态+diff 对账 | `git -C /mnt/data/dev/task-planner-skill status --short`（scope 文件干净）；部署位 diff 命令（部署获用户授权后执行，参照 v184 rsync 范式） |

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
| **目标型需求** | R1（工作流主动激活）/R2（模型分级）/R3（并行度）——三条全 [目标] |
| **裁决** | `solved` |
| **解决证据锚** | R1：skills/plan-collab-router/references/critical-rules-collab.md:5（39.1 常设授权∨点名）+:24（39.8 三条件+三件套）+:33（40.4 主动路由义务）+SKILL.md:207（消费侧）；R2：collab.md:79（91.12 分档联动+subagent_model 选档+91.8 衔接）；R3：critical-rules-dispatch.md:34（21.4.2 四步扩组）+:165（68.2 论证义务）；回归面：主仓 91/91 红=0（progress Phase 4 段）+CR APPROVED（16-critic.md）+部署 0/9×3 位（progress Phase 4 段） |
| **未解决面+原因** | 行为面冒烟未做（规则文本已生效于 3 部署位，但「下一会话实际主动创建工作流」的端到端验证需新会话——技能文件新会话加载，本会话不可自证） |
| **已排除路径** | 不适用（solved） |
| **下一步建议** | 新会话冒烟：任给一个 ≥3 独立子任务编排型指令，观察是否按 39.8 主动路由 CreateWorkflow+留痕+分档（对象=~/.zcode/skills/plan-collab-router/references/critical-rules-collab.md §39.8；动作=发指令观察执行链） |

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
| G1 | 工作流激活修订 | Rule 39.1 演进+39.8 常设授权子条落地，复杂任务主动创建工作流可达 | 命令+判据：VC-1/VC-2 的 grep 断言全过 | S1,S2,S4/Phase 2 | complete |
| G2 | 模型分级联动 | Rule 91 与 39.8 激活联动+run 级 subagent_model 按难度选档条款 | 命令+判据：VC-3 grep 断言过 | S3/Phase 2 | complete |
| G3 | 并行强化 | 21.4.2 执行期扩组协议+68.2 惰性串行论证义务落地 | 命令+判据：VC-4 grep 断言 ≥2 命中 | S5/Phase 2 | complete |
| G4 | 回归绿 | 锚级联同步+全量 selftest FAIL=0 | 命令+判据：VC-5 ΣFAIL=0（worktree+主仓双跑） | S6,S8,S7,S11/Phase 3 | complete |
| G5 | 合并部署 | worktree 合并回 master+部署位同步 | diff 形态：VC-6 scope 干净+部署位 diff=0 | Phase 4/Phase 4 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `skills/plan-collab-router/references/critical-rules-collab.md`（Rule 39/40/91 段） | 同文件其他 Rule 段措辞 |
| 规则条款 | `skills/task-dispatch/references/critical-rules-dispatch.md`（Rule 21.4/68 段） | 同文件其他 Rule 段措辞 |
| 技能主文件 | `skills/task-planner/SKILL.md`（第 156/207 行协同路由与 Chain 段的 workflow 语义行） | SKILL.md 其他区块 |
| selftest | `skills/task-planner/scripts/selftest-workflow-orchestration.sh`、`selftest-parallel-scheduling.sh`、`selftest-tool-selection.sh`（仅当断言锚级联需要；新增断言属范围扩张须单独授权，默认只改锚措辞） | 新建 selftest 脚本/registry 行 |
| 模板镜像（[D9 扩展] S0 侦察发现 B 类引用面） | `skills/task-planner/templates/task_plan.md`（:262 判定行）、`skills/plan-template-kit/references/template-guide.md`、`skills/plan-template-kit/references/template-mapping.md`（40.4 语义镜像同步） | 模板其他区块 |
| 卫星 SKILL | `skills/plan-collab-router/SKILL.md`（仅当其路由行含「仅显式点名」旧措辞需同步时） | 其他内容 |
| 计划文档 | `plans/task-v187-workflow-activation-parallel/**`、`plans/INDEX.md` | 其他计划目录 |

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
| CA-1 | collab.md §39.1（触发纪律） | 修改 | 替代（触发语义：显式点名唯一 → 显式点名∨常设授权命中条件） | R1「复杂任务应该启用工作流，主动创建工作流来调用，来推进任务」 | 重写 39.1：保留官方红线原文披露+新增用户常设授权覆盖声明（授权锚=user-session-log #1，2026-10-18） |
| CA-2 | collab.md §39.8（新增子条：常设授权主动激活） | 新增 | 增量 | R1 同上 | 激活三条件（≥3 独立可并行 S-unit / ≥3 阶段编排型有类型化中间结果 / 用户点名）+激活留痕（Decisions+progress 一行）+不命中回落 Agent 调度+轻量通道豁免声明 |
| CA-3 | collab.md §40.4（计划期路径） | 修改 | 替代（「建议登记≠自动触发」→「命中 39.8 条件=主动路由义务」） | R1 | 升级 40.4 为 39.8 联动执行面：命中即在「🧰」区块登记 CreateWorkflow 路由并执行 |
| CA-4 | collab.md §91（模型分档） | 修改 | 增量（联动锚+选档条款） | R2「根据不同的任务难度执行，就是子代理进行选择，确保不会都使用复杂大模型」 | 91 段新增：39.8 主动创建时强制过 91 分档；CreateWorkflow `subagent_model`（run 级唯一官方字段）按任务整体难度声明；91.2 官方矛盾披露与 91.5 验证门不变量不动 |
| CA-5 | task-planner/SKILL.md:207 摘要行（+:156 Rule 83 行如涉） | 修改 | 替代 | R1 | 「仅用户显式点名 /workflow 时路由」→「命中 Rule 39.8 编排条件（常设授权）或用户点名时路由」 |
| CA-6 | dispatch.md §21.4（新增子条 21.4.2 执行期扩组协议） | 新增 | 增量 | R3「只要任务不冲突，就是不互相依赖的前提下，可以提高并行」 | 执行期新识别独立单元（四问全 no）→ Decisions 登记 [parallel-uplift]+S-unit 表补组标记+attest 重锁 → 并行派发；只读并行豁免通道保持 |
| CA-7 | dispatch.md §68.2（惰性串行论证义务） | 修改 | 增量 | R3 | S-unit ≥3 且零并行组的计划：须在 Decisions 论证全串行理由（资源/依赖/风险三轴至少一轴逐条说明），否则视为惰性分组回炉 |
| CA-8 | selftest-workflow-orchestration.sh 等（锚级联） | 修改 | 增量（仅锚措辞同步，不加新断言） | VC-5 回归前提 | 39.x 断言锚同步新措辞；21.4/68 锚同步（parallel-scheduling） |
| CA-9 | plans/INDEX.md | 更新 | 增量 | 流程惯例 | 任务登记行+归档刷新 |
| CA-10 | task-planner/templates/task_plan.md:262 判定行 + plan-template-kit/references/template-guide.md:254 + template-mapping.md:312/321（[D9] S0 侦察 B 类镜像面） | 修改 | 替代（40.4 语义镜像随 CA-3 演进：建议登记→39.8 主动路由） | R1；S0 交付 2 B 类清单（findings §S0 断言面侦察结论） | 三处判定行按 findings §S4 段模板镜像措辞同步 |
| CA-11 | collab.md:24 91.6→91.12 联动字面（[D11]） | 修改 | 增量 | S2 撞号前蓝本残留 | S6 顺带修（done：91.6 联动=0/91.12 联动=1） |
| CA-12 | collab.md:28×2+:71 段引言短语 + plan-writer.md:45 第四镜像面（[D12] V-3.2 抓出） | 修改 | 替代（引言语义随 39.1 演进） | R1；V-3.2 主进程复核 | S11 done（4 处 Edit 申报） |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | 宪法 §四.6 文本优先铁律+§十一 worktree 铁律 | ~/.zcode/AGENTS.md §四/§十一 | 必读 | ☑ |
| 官方文档 | dynamic-workflows 官方 SKILL.md（CreateWorkflow 族语义+subagent_model schema） | /opt/ZCode/resources/glm/packages/bundled-skills/skills/dynamic-workflows/SKILL.md（本会话工具描述=同源最新版） | 必读 | ☑（工具描述已核：subagent_model=run 级、max_concurrency、"Only when the user asks"） |
| 项目内部文档/知识库 | collab.md 全文（Rule 39/40/91 现行原文） | skills/plan-collab-router/references/critical-rules-collab.md（77 行） | 必读 | ☑（诊断轮已 grep 精读核心段，Phase 1 全文复读） |
| 项目内部文档/知识库 | dispatch.md §21.4/§68 现行原文 | skills/task-dispatch/references/critical-rules-dispatch.md（174 行） | 必读 | ☑（同上） |
| 项目内部文档/知识库 | workflow-model-tiers 用户级技能（CCR 四档映射） | ~/.zcode/skills/workflow-model-tiers/SKILL.md（120 行） | 参考 | ☐（Phase 1 S-unit 内精读） |
| 项目内部文档/知识库 | selftest 断言面（39.x/21.4/68 锚清单） | scripts/selftest-workflow-orchestration.sh + selftest-parallel-scheduling.sh + selftest-tool-selection.sh | 必读 | ☐（Phase 1 S-unit 内枚举） |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 现行 Rule 39.1「仅当用户显式调用 /workflow……agent 不得自主判断启动 workflow」把「复杂任务主动创建工作流」结构性锁死（SKILL.md:207 摘要行同构互锁）——R1 目标在现行规则下不可达，激活率 0 是规则设计使然而非执行滑坡；并行面 21.4 声明制「未声明=串行」+68.2 无惰性串行防线导致实际并行率低于用户预期。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？——能：规则文本修订（39.1/39.8/40.4/91/21.4.2/68.2）+锚级联+回归绿+合并部署后，下一会话起复杂任务可主动走 CreateWorkflow（行为面生效需新会话冒烟，如实披露）
- [x] 核心问题不解决，其他工作都白费吗？——是：不修 39.1，任何"建议登记"（40.4 现文）都无触发效力，R1/R2 持续空转
- [x] 核心问题的解决方法是清晰的、可执行的？——是：诊断已完成一手取证（grep 输出在 findings），修订面/级联面已定位，CA-1..CA-9 逐条登记

**官方红线张力披露（关键设计点）**: 官方 CreateWorkflow 工具描述含「Without such an explicit request, do not start a workflow」（与 39.1 现文同源）。本任务依据=宪法 §四 P0-1 用户当前指令优先：用户 2026-10-18 原话（user-session-log #1）构成**常设授权**，等价于「显式请求的常驻形态」。39.8 条款须写明：授权来源锚+可撤销性（用户一句"收回工作流授权"即回退）+每次激活留痕（可审计）——用三元组把用户主权授权合规化，而非删掉官方红线披露。

**如果无法回答核心问题，禁止开始任务！**（三问已全部 [x] 回答，满足开工条件）

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| S1-S5（规则文本修订） | LOCAL-ONLY | 不适用（根因已一手取证） | 不适用 | findings.md 修订方案定稿段 | 不适用 |
| S6（selftest 锚级联） | LOCAL-ONLY | grep 旧措辞四形态族（仅用户显式点名/不得自主判断/建议登记≠自动触发/串行槽措辞） | 本仓 Grep | 级联面清单+锚 diff | 不适用 |
| S7（全量回归） | LOCAL-ONLY | 不适用 | 本仓 Bash | progress.md 回归记录 | 不适用 |

> 三态判定说明：本任务全部 LOCAL-ONLY——诊断已完成（激活率 0 根因=本地规则文本 grep 实证；官方 schema=本会话工具描述一手核验），无网络数据依赖。Rule 75 网络调研义务由诊断轮的官方文档核验（dynamic-workflows 工具描述/bundled SKILL.md）承接，无需 NET-* 检索。

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | SKILL.md:207 摘要行原文「仅用户显式点名 /workflow 时路由」+collab.md:5 39.1 原文「agent 不得自主判断启动 workflow」 | grep -n 精读（诊断轮已执行） | findings.md §诊断证据（含行号+原文引用） | ☑ |
| ② 对标样本（58.2 强制） | 官方 dynamic-workflows 工具描述（CreateWorkflow subagent_model/max_concurrency/触发条款）+官方 bundled SKILL.md:112「no per-subagent model choice」 | 本会话工具 schema 一手核验+collab.md 91.2 既有实证引用 | findings.md §官方事实 | ☑ |
| ③ 外部约束 | 官方「explicit request is binding」红线 vs 宪法 §四 P0-1 用户指令优先级的裁决序 | AGENTS.md §四+用户 2026-10-18 原话 | task_plan §核心问题定义·官方红线张力披露 | ☑ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
Phase 3

## Next Step
pg-w3 收 S6∥S8 → S7 全量回归（code-runner-agent）→ 四形态族清零复核 → Phase 3 收口（V-3.1/3.2）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore（取证+修订面全文精读） | 跨 5 文件的断言面枚举=「读得多要得少」，主上下文只回收清单 |
| Phase 2 | Agent 子代理 executor（并行组派发，sonnet 档） | 既定步骤批量文本修订；W1 波 S1∥S5 文件集不相交（诉求 3 的本计划内实践） |
| Phase 3 | Agent 子代理 code-runner-agent（回归跑） | 全量 selftest 长输出隔离执行，主进程收 ΣFAIL 结论 |
| Phase 4 | 机械守卫脚本+git 编排（主进程白名单②） | smart-merge-back+部署同步=git 操作主进程直做 |
| 全程 | 卫星技能 plan-collab-router/task-dispatch（伴飞 Read） | 修订对象即其权威源文件，执行体须 Read 现状 |

**workflow 编排判定（Rule 40.4）**: 未命中主动激活门槛——本计划 S-unit 7 个但 collab.md 三连（S1→S2→S3）同文件强串行，最大独立波=2 个单元（W1: S1∥S5；W2: S2∥S4），低于「≥3 独立可并行」门槛；且任务本质=高风险文件语义修订（验收依赖逐段人工复核），非类型化中间结果编排型。判定=按 Rule 21.4 独立性守门调度（本计划 frontmatter 声明 pg-w1/pg-w2 两并行组，即为诉求 3 新语义的实践示范）。用户未点名 /workflow。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；用户未使用 /goal 锚定；R1-R3 全部映射 VC（R→VC 表）。

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 诊断固化与修订方案定稿
- [x] findings.md 落三大诉求根因诊断证据（主进程诊断轮完成：激活率 0=39.1 规则锁死；91 空转；21.4 惰性串行——含行号+原文引用）
- [x] S0：派 explore 枚举 selftest 断言面+旧措辞四形态族全仓扫描+workflow-model-tiers 四档精读（done；检查点 0-explore.md；锚清单 WF-09/TS-03/TS-06/P-08+B 类镜像三处）
- [x] 修订方案逐段措辞定稿（六段全文落 findings §方案定稿：39.1/39.8/40.4/91.6/21.4.2/68.2+S4 消费侧段）
- [x] 知识储备必读项已确认（workflow-model-tiers 四档=opus-1/sonnet-1/fast/haiku-1，随 S0 消费）
- **V-N:** VC-1, VC-3（V-1.1=7 ✓ / V-1.2=2 ✓，2026-10-18 01:12）
- **Status:** complete
- **Executor:** explore（sonnet-1）（方案定稿子步=主进程直做，例外理由:② 计划系统文件维护——Rule 25.3 白名单，登记于 checklist 第 3 条）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S0 | 枚举三 selftest 脚本中 39.x/21.4/68 断言锚行号清单+旧措辞四形态族全仓扫描+workflow-model-tiers 四档映射摘要 | explore（sonnet-1） | skills/task-planner/scripts/selftest-workflow-orchestration.sh（39.x 锚+SKILL 摘要行锚）；扫描范围=主仓 skills/**/*.md 四形态族（仅用户显式点名/不得自主判断/建议登记≠自动触发/未声明默认串行） | findings.md §断言面清单：锚行号表+四形态族命中清单+四档映射 ≤10 行摘要 | 15min | 1f/60l/15min | 无 | - | pending |
<!-- 
  STATUS VALUES:
  - pending: Not started yet
  - in_progress: Currently working on this
  - complete: Finished this phase
-->

### Phase 2: 规则文本修订（三波派发，W1/W2 并行组实践诉求 3）
- [x] W1 并行组 pg-w1：S1（collab.md 39.1 重写）∥ S5（dispatch.md 21.4.2+68.2）——同消息双发 done
- [x] W2 并行组 pg-w2：S2（collab.md 39.8 新增）∥ S4（两 SKILL.md 行）∥ S9（模板判定行）∥ S10（plan-template-kit 镜像）——四发；S10 首派失败（Simple Agent 0 工具调用）→22.3① 改派 general-purpose done（[D9] 扩展）
- [x] W3 串行：S3（collab.md 40.4 升级+91.12 联动+SKILL:207 编号回改；S2 报出 91.6 撞号→蓝本修正 91.12）
- [x] 逐段 Read 复核修订后文本（主进程抽查 V-2.1..2.4 断言+diff 总览 6 文件 11+/8-；complex-planner.md:16 未误改——S0 排除项在各任务书已注明）
- **V-N:** VC-1, VC-2, VC-3, VC-4（全 PASS：常设授权=4/仅当用户显式调用=0/两 SKILL 旧措辞=0/新语义=1/39.8=4/subagent_model=4/21.4.2=1/惰性=1；2026-10-18 01:55）
- **Status:** complete
- **Executor:** executor（sonnet-1）；产物 worktree commit 3004687

<!-- S-unit 派发单元表(Rule 22.6) -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 重写 collab.md §39.1：常设授权触发语义替代显式点名唯一触发 | executor（sonnet-1） | skills/plan-collab-router/references/critical-rules-collab.md + findings §方案定稿 39.1 段全文 | grep 常设授权 ≥1 命中；官方红线披露行保留 | 15min | 1f/45l/15min | 无 | - | [parallel-group:pg-w1] done |
| S5 | dispatch.md 新增 §21.4.2 执行期扩组协议+§68.2 惰性串行论证义务 | executor（sonnet-1） | skills/task-dispatch/references/critical-rules-dispatch.md + findings §方案定稿 21.4.2/68.2 段全文 | grep 21.4.2 ≥1；grep 惰性串行论证 ≥1（68.2 段） | 15min | 1f/45l/15min | 无 | - | [parallel-group:pg-w1] done |
| S2 | collab.md 新增 §39.8 常设授权主动激活子条（三条件+留痕+回落+豁免） | executor（sonnet-1） | skills/plan-collab-router/references/critical-rules-collab.md + findings §方案定稿 39.8 段全文 | grep 39.8 ≥1；含三条件+可撤销+留痕三要素 | 15min | 1f/40l/15min | 无 | S1 | [parallel-group:pg-w2] done |
| S4 | SKILL.md:207 摘要行改写+plan-collab-router/SKILL.md 路由行同步 | Code Assistant（haiku-1） | findings §方案定稿 S4 段（含两 SKILL.md 目标行号与新措辞全文） | grep "仅用户显式点名" 两 SKILL 计数=0；新语义行 ≥1 | 10min | 2f/15l/10min | 无 | S1 | [parallel-group:pg-w2] done |
| S3 | collab.md §40.4 升级（主动路由义务）+§91 联动（39.8 激活→91 分档强制+subagent_model 选档） | executor（sonnet-1） | skills/plan-collab-router/references/critical-rules-collab.md + findings §方案定稿 40.4/91 段全文 | grep 39.8 于 91 段命中 ≥1；subagent_model ≥1 | 15min | 1f/35l/15min | 无 | S2 | done |
| S9 | templates/task_plan.md:262 workflow 编排判定行按 39.8 语义同步 | Code Assistant（haiku-1） | findings §S4 段（含模板镜像新措辞全文） | grep -c "39.8" 该模板 ≥1；旧「建议 CreateWorkflow」登记语义行替换 | 5min | 1f/5l/5min | 无 | - | [parallel-group:pg-w2] done |
| S10 | plan-template-kit 两 references 模板镜像行同步（template-guide.md:254+template-mapping.md:312/321） | Simple Agent | findings §S4 段（含模板镜像新措辞全文） | grep -c "39\.8" 两文件合计 ≥2（旧「建议 CreateWorkflow」语义行已替换） | 8min | 2f/10l/8min | 无 | - | [parallel-group:pg-w2] done（重派 general-purpose：Simple Agent 首派 0 工具调用失败，22.3 换道） |

### Phase 3: selftest 锚级联与全量回归
- [x] S6：workflow-orchestration.sh 断言锚同步（WF-09 期望措辞；22/22 PASS）+CA-11 字面修正（collab.md:24 91.6→91.12 联动）
- [x] S8：tool-selection.sh 断言锚同步（TS-03/TS-06 期望措辞 12/12 PASS）+parallel-scheduling.sh 核对无需改（P-08 语义未变 9/9 PASS 保持）
- [x] S7：全量 selftest 回归（91/91 脚本 ΣPASS=1304 ΣFAIL=0，检查点 13-code-runner-agent.md）
- [x] S11（D12 扩展）：40/91 段引言∨常设授权短语+plan-writer 第四镜像面（4 处 Edit 申报）；主进程全量复跑红脚本=0
- [x] 四形态族清零复核（V-3.2）：硬措辞 0 残留；唯一合法保留=collab:5 披露引语（不得自主判断废止引语，Rule 35.2）
- **V-N:** VC-5（全量回归双跑 FAIL=0+清零终态；2026-10-18 02:20）
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S6 | selftest-workflow-orchestration.sh 断言锚同步至 39.1/39.8 新措辞+CA-11 字面修正（collab.md:24 91.6→91.12 联动） | executor（sonnet-1） | skills/task-planner/scripts/selftest-workflow-orchestration.sh + findings §断言面清单（锚行号表） | 该脚本单独跑全 PASS；collab.md:24 91.6 联动=0 | 12min | 2f/15l/12min | 无 | S1,S2,S3,S4,S5 | [parallel-group:pg-w3] done |
| S8 | parallel-scheduling.sh+tool-selection.sh 断言锚同步（21.4.2/68.2/40.4 锚） | executor（sonnet-1） | findings §断言面清单（含两脚本目标锚行号与新锚措辞） | 两脚本单独跑全 PASS | 12min | 2f/15l/12min | 无 | S5,S3 | [parallel-group:pg-w3] done |
| S7 | 全量 selftest 回归 ΣFAIL=0 | code-runner-agent（mini） | skills/task-planner/scripts/selftest-*.sh 全量 | 回归输出 ΣFAIL=0 全程留 progress | 15min | 1f/5l/15min | 无 | S6,S8 | done |
| S11 | D12 引用面清零：collab :28×2/+:71 段引言+plan-writer:45 镜像 | Code Assistant（haiku-1） | findings §S0（漏扫面）+V-3.2 复核输出 | 显式点名才路由=0/新短语=2/plan-writer 旧字样=0/披露引语保留=1 | 10min | 2f/15l/10min | 无 | S6,S8 | done（[D12] 扩展增行） |

### Phase 4: 合并回主仓+部署同步+交付
- [x] CR Gate（code_review: required）——critic 首轮 CHANGES_REQUESTED（M-1：:28 引言与 :33 本体矛盾）→ cr-fix 修复（059b65c）→ 复评 **APPROVED**（七项全 PASS+NIT×3 降级可选后续；检查点 16-critic.md）
- [x] worktree 内全部 VC 复验 → smart-merge-back 合并 master（**55fa43ca**，V1-V5 全过）→ worktree/分支已清理
- [x] 主仓 Read 复验（常设授权=6/显式点名才路由=0/39.8=5/21.4.2=1/SKILL 旧措辞=0）+全量 selftest 复跑（91/91 红=0，VC-5 双跑达成）
- [x] 部署同步（计划 Rule 44 默认项授权）：9 文件×3 部署位（~/.zcode / ~/.claude / ~/.cursor）精准 cp，对账 0/9 差异全 IDENTICAL；.drift-rhythm 等运行态保留未动；cursor 位历史漂移（非本次范围）报告不动
- [x] alignment-review 对齐审查+delivery-summary 五要素+归档
- **V-N:** VC-5, VC-6（全 PASS）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单；CR 子步骤派 critic）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号③：scope 含 skills/**=运行中基础设施；信号①本计划目录） |
| `isolation` | `worktree`（§十一 11.1 条款 1 命中：修改 skills/** → 部署到 ~/.zcode/skills/**） |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v187-workflow-activation-parallel`（已清理） |
| `branch` | `wt/task-v187-workflow-activation-parallel`（已删除，was 059b65c） |
| `merge_back` | `merged(55fa43ca)` |

> 契约详见 `${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/methodology.md §R2）

<!--
  WHAT: 对每个 Phase 枚举失败模式，打 S(严重度)/O(频度)/D(探测难度) 各 1-10 分，RPN=S×O×D。
  WHY: RPN>100 的高风险 Phase 必须预先登记兜底动作（对齐 Rule 22.3 五档兜底链，task-v113 后含 22.3.0 资料先行档），避免执行期临时决策。
  WHEN: 计划创建时填写（高 RPN 项）；纯文档/调研类小任务可写 n/a。
  开关键: config.json#fmea_enforce（默认 warn；enforce 档下 RPN>100 无兜底登记 = 计划无效）。
-->

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2 | 措辞锚级联漏改（消费面残留旧语义：仅用户显式点名/不得自主判断/建议登记≠自动触发四形态族） | 6 | 7 | 3 | 126 | ④ 主进程接管：grep 四形态族全仓扫描（含 .md 全扩展名）逐面清零后才可进 Phase 3 |
| Phase 3 | selftest 既有断言依赖旧措辞 FAIL | 6 | 6 | 2 | 72 | （≤100）按 FAIL 输出逐条同步锚；≥2 次同法失败→① 改派全新 executor |
| Phase 2 | 39.8 激活条件过宽→简单任务 workflow 化滥用（破坏不变量⑦轻量通道） | 7 | 4 | 3 | 84 | （≤100）CR Gate critic 专项审查门槛参数+L0/mini 豁免声明在位 |
| Phase 4 | 并行会话同日竞写同文件（master 合并冲突） | 6 | 5 | 3 | 90 | （≤100）合并前 git log 对账+冲突走并集解（v166/v179 判例范式） |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | S1 计划创建后建映射 |
| Phase 2 | ☐ |  | 5 S-unit 三波（pg-w1/pg-w2 并行组） |
| Phase 3 | ☐ |  | S6/S7 串行链 |
| Phase 4 | ☐ |  | 主进程 git 编排+CR Gate |

> 契约详见 `${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. 激活门槛参数：方案默认「≥3 独立可并行 S-unit ∨ ≥3 阶段编排型（类型化中间结果/停止条件循环）∨ 用户点名」三选一——是否符合你说的"复杂任务"预期？（偏窄=多数任务仍走 Agent 派发；偏宽=workflow 确认窗/类型检查开销侵入轻量任务）
2. 执行期扩组协议的重锁成本：S-unit 表补组标记后须 attest 重锁（frontmatter SHA-256 锁定机制）——方案保留重锁（安全优先），是否接受？
3. 部署同步时机：合并 master 后是否立即同步四部署位（~/.zcode/skills 等即刻生效）？（历史惯例=用户逐次授权；本计划默认项=批准后同步）
4. 行为面验证：规则生效需新会话冒烟（技能文件新会话加载）——本任务交付=规则+回归绿，冒烟是否另行安排？

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
| D1: 常设授权三元组合规化（授权来源锚+可撤销+激活留痕），不删官方红线披露 | 宪法 §四 P0-1 用户指令优先于官方默认政策；但官方红线披露保留可防未来会话误判——用"用户主权授权覆盖"论证而非掩埋冲突（Rule 35.2 防虚构） |
| D2: 激活门槛=三条件（≥3 独立 S-unit/≥3 阶段编排型/用户点名） | 防全任务 workflow 化滥用（不变量⑦）；与 40.4 既有编排条件同源+量化门槛使其可判 |
| D3: 诉求 2 落点=91 联动+run 级 subagent_model 按整体难度声明；per-subagent 官方无支持维持 91.2 披露 | 官方 schema 实证（工具描述+SKILL.md:112）：subagent_model=run 级唯一模型字段；91 既有四档映射表复用，不另造分档体系 |
| D4: 诉求 3 落点=纯文本条款（21.4.2+68.2），不新建机器门 | 宪法 §四.6 文本优先铁律：守护机器化=opt-in；既有 check-dispatch 串行槽/组标记机制语义不变 |
| D5: 39.8 编号而不新开 Rule 号 | 39 族内演进（激活纪律属 39 域）；21.4.2 同理——避免编号膨胀 |
| D6: worktree 隔离（§十一 11.1 条款 1） | skills/**=保护区+运行中基础设施 |
| D7: S1∥S5（pg-w1）、S2∥S4（pg-w2）两并行组 | 文件集不相交+四问全 no（68.1 分析：S1/S5 无输入依赖；S2/S4 各依赖 S1 定稿但互不依赖）——诉求 3 在本计划内的实践示范 |
| D8: 组内异构（68.3 WARN 处置）：pg-w2 S4 改 Code Assistant（haiku-1）；pg-w1 维持同体 executor（sonnet-1）+登记理由 | S4=照单替换两行（输入=findings 定稿全文，机械轻量）→ 43.2 最小可承载档位 haiku 可承载且实现类型异构；S1/S5 均为语义敏感条款重写，降档违 43.2「禁止为异构降档」——同档异构无合适类型对（规则语义修订=executor 域），接受 advisory WARN |
| D9: [Phase 1 扩展] scope 增模板镜像三处（CA-10）+S9/S10 拆分入 pg-w2 | S0 侦察发现 B 类引用面（templates/task_plan.md:262+template-guide.md:254+template-mapping.md:312/321）为 40.4 语义镜像，不同步=措辞漂移（v161 判例同构）；3 文件超单 S-unit 粒度上限故拆 S9（1f，Code Assistant）/S10（2f，Simple Agent）；S9/S10 输入=findings §S4 段已定稿全文，与 S2/S4 四问全 no 同组并行——本条重锁理由=scope 扩展+S-unit 表增行（Rule 51.7 合法重锁） |
| D10: [parallel-uplift 21.4.2 首用] S6/S8 升级并行组 pg-w3：①文件集不相交（S6=selftest-workflow-orchestration.sh 1f；S8=parallel-scheduling+tool-selection 2f）②资源不相争（同 worktree 不同文件，无部署位/分支/交付物冲突）③输入=findings §断言面清单共享只读，互不依赖产出 ④验收=各自脚本独立跑 PASS 互不依赖——四问全 no；补组标记+frontmatter 追加+重锁=21.4.2 四步合规（本任务修订协议的实战首用） | R3 精神+效率（S6∥S8 省 ~12min）；协议狗food 验证 |
| D11: [CA-11] collab.md:24（39.8 段内）「Rule 91.6 联动」→「Rule 91.12 联动」字面修正（S2 按撞号前蓝本写入的残留，S3 白名单禁改已如实上报；S6 顺带修——同文件域锚同步单元） | S3 检查点+drift-checker-p2 双确认的遗留项 |
| D12: [Phase 3 扩展] S11 收尾修正单元（3+1 处）：collab.md:28×2（40 段引言「显式点名才路由」→「显式点名∨常设授权命中才路由」——含行内第 2 处 36.5 承诺句引用）+:71（91 段引言同短语）+plan-writer.md:45（第四镜像面「建议 CreateWorkflow」→39.8 语义）——S0 漏扫引用面，V-3.2 主进程复核抓出；本条重锁理由=引用面级联修正+S11 增行（Rule 51.7 合法重锁） | V-3.2 清零判据驱动；S11 申报 4 处 Edit（任务书 3 处+同行第 2 处引用，语义无损） |

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
| 2026-10-18 01:15 | ✅ALIGNED（drift-checker 检查点 1-drift-checker.md+ledger tick1） | VC-1,VC-3（预检） | Phase 1 方案六段定稿+D9 扩展均落 R1-R3 与 scope 内，git 零越范围写入 |
| 2026-10-18 02:00 | ✅ALIGNED（drift-checker 检查点 10-drift-checker.md+ledger tick2） | VC-1..VC-4 | Phase 2 commit 3004687 六文件全落 scope，R1-R3 逐条闭合，不变量⑦在位，complex-planner 排除项未动 |
| 2026-10-18 02:28 | ✅ALIGNED（drift-checker 检查点 15-drift-checker.md+ledger tick3；.sh 级联注引旧形=历史记载惯例非违例） | VC-5 | Phase 3 锚级联+回归双跑 FAIL=0+四形态族清零；S11 4 处 Edit 申报合规；D12 扩展面全落 scope |

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
| 1 | 10-18 00:50 | Explore | S0 断言面枚举+四形态族扫描+四档摘要 | done | WF-09(:64)/TS-03(:51)/TS-06(:89)/P-08(:147) 四硬锚+B 类镜像三处+排除项 | subagent-state/0-explore.md | §S0 断言面侦察结论 | subagent-state/0-explore.md | - / 0 / ☑ |
| 2 | 10-18 01:15 | drift-checker | Phase 1 偏移检查 | done | ✅ALIGNED 四问全过（R1-R3 服务/scope 内/Goal 对齐/D9 合理级联） | subagent-state/1-drift-checker.md | Drift Log 行 | subagent-state/1-drift-checker.md | - / 0 / ☑ |
| 3 | 10-18 01:20 | executor | S1 重写 39.1 触发纪律 | done | 蓝本逐字（diff 空）；39.2-39.7/40.4 未动；常设授权行内 4 次 | collab.md:5（worktree） | [sub:S1-executor] | subagent-state/2-executor.md | - / 0 / ☑ |
| 4 | 10-18 01:20 | executor | S5 新增 21.4.2+68.2 义务 | done | 两段逐字（diff 空）；21.4 原文/68.1 未动 | dispatch.md:34,:165（worktree） | [sub:S5-executor] | subagent-state/3-executor.md | - / 0 / ☑ |
| 5 | 10-18 01:30 | executor | S2 新增 39.8 主动激活子条 | done | 蓝本逐字插入 :24；发现 91.6 撞号（蓝本改 91.12 由 S3 落地） | collab.md:24（worktree） | [sub:S2-executor] | subagent-state/4-executor.md | - / 0 / ☑ |
| 6 | 10-18 01:30 | Code Assistant | S4 两 SKILL 路由行同步 | done | SKILL.md:207 逐字替换；router SKILL 零锁死措辞零写入 | SKILL.md:207（worktree） | [sub:S4-code-assistant] | subagent-state/5-code-assistant.md | - / 0 / ☑ |
| 7 | 10-18 01:30 | Code Assistant | S9 模板判定行同步 | done | :262 替换（+1/-1）；行号未漂移 | templates/task_plan.md:262（worktree） | [sub:S9-code-assistant] | subagent-state/6-code-assistant.md | - / 0 / ☑ |
| 8 | 10-18 01:30 | Simple Agent | S10 镜像两文件同步 | failed | 0 工具调用返回截断（provider 失败） | 无产出 | 无 | 无 | scaling-redispatch / 1 / ☑（失败登记） |
| 9 | 10-18 01:50 | executor | S3 升级 40.4+新增 91.12+编号回改 | done | 两蓝本逐字+SKILL:207 编号 91.12；91 族 12 行 | collab.md:33,:79（worktree） | [sub:S3-executor] | subagent-state/8-executor.md | - / 0 / ☑ |
| 10 | 10-18 01:50 | general-purpose | S10 重派镜像同步 | done | 三处替换（guide:254/mapping:312/:321）40.4 语境清零 | 两 references（worktree） | [sub:S10-general] | subagent-state/9-general-purpose.md | 22.3① 改派 Simple Agent→general-purpose / 1 / ☑ |
| 11 | 10-18 02:05 | executor | S6 锚同步+CA-11 修正 | done | WF-09 期望措辞 22/22 PASS；91.6 联动=0/91.12=1 | 脚本:63-64+collab:24（worktree） | [sub:S6-executor] | subagent-state/11-executor.md | - / 0 / ☑ |
| 12 | 10-18 02:05 | executor | S8 两脚本锚同步 | done | TS-03/TS-06 12/12 PASS；parallel-scheduling 9/9 保持 | tool-selection.sh（worktree） | [sub:S8-executor] | subagent-state/12-executor.md | - / 0 / ☑ |
| 13 | 10-18 02:12 | code-runner-agent | S7 全量回归 | done | 91/91 脚本 ΣPASS=1304 ΣFAIL=0；4 伪阳性解析修正 | subagent-state/13-code-runner-agent.md | progress Phase 3 段 | subagent-state/13-code-runner-agent.md | - / 0 / ☑ |
| 14 | 10-18 02:18 | Code Assistant | S11 D12 引用面清零 | done | 4 处 Edit（3 任务+1 同行申报）；4 受影响脚本全绿 | collab:28,:71+plan-writer:45（worktree） | [sub:S11-code-assistant] | subagent-state/14-code-assistant.md | - / 0 / ☑ |
| 15 | 10-18 02:40 | drift-checker | Phase 3 偏移检查 | done | ✅ALIGNED（抽验 2 脚本+四断言复核） | subagent-state/15-drift-checker.md | Drift Log 行 | subagent-state/15-drift-checker.md | - / 0 / ☑ |
| 16 | 10-18 02:50 | critic | CR Gate 七项审查 | done（首轮 CHANGES_REQUESTED→复评 APPROVED） | 七项全 PASS+M-1 抓出（:28 矛盾）→修复闭环 | subagent-state/16-critic.md | progress Phase 4 段 | subagent-state/16-critic.md | M-1 → cr-fix / 1 / ☑ |
| 17 | 10-18 02:55 | Code Assistant | CR M-1 修复 | done | :28 整句对齐 :33 本体；22/22 PASS | collab.md:28（worktree，commit 059b65c） | [sub:cr-fix-m1] | subagent-state/17-code-assistant.md | - / 1 / ☑ |
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
