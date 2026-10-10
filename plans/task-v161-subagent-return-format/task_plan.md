# Task Plan: 子代理返回 8 字段格式纪律修复（消除 agent 定义输出模板污染）
<!-- frontmatter 声明面（Rule 21.4/23.9）：parallel_groups: [pg0（Phase 1 只读调研并行组，已完成）、pg1（Phase 3 实施并行组 S1/S2/S3/S6，文件集互斥/输入互不依赖/验收独立）] -->
parallel_groups: [pg0, pg1]
<!-- 
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC（核心问题的可观察解决证据，非手段产物完成）；目标型任务终验必填「🎯 核心目标达成裁决」区块（58.5） -->

- **R1**: 「子代理中，返回数据应该和总结阶段应该不大一样。因为子代理之前的子代理的返回是结构化数据，就是一个列表，就是之前的那种格式。因为相当于有固定的格式，更利于主代理去了解。」<sub>（[目标]）</sub>
- **R2**: 「但是现在返回了和正常执行任务返回一样的格式，而且这一样的格式其实是非常差的。因为每次都每次产出的数据，其实按现在的都不是很好。」<sub>（[目标]）</sub>
- **R3**: 「所以我希望要求规划子代理中返回的数据，按照原始返回，就是要求的那种返回的固定的列表格式。」<sub>（[手段]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | 派发契约 §7 与 Rule 22.4b 均含「返回≠总结」优先级声明（grep 断言） |
| R2 | VC-3, VC-5 | 返回/检查点 8 字段合规性可机械校验（check-subagent-return.sh 4 类夹具正确分流）；全仓 selftest 回归 FAIL=0 |
| R3 | VC-3, VC-4, VC-6 | 校验脚本+selftest 守护+级联同步三层落地（grep/rc=0 证据） |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 派发 prompt §7 段填写（第一优先根因） | 段填写污染实证（用户 mid-turn 样本）：「## 返回格式」段被填入 ①②③ 任务要点清单而非 8 字段模板块（标题重复「## 返回格式## 返回格式」为拼接痕迹）；check-dispatch.sh 只查 status:/acceptance:/checkpoint: 三 key 存在性，段结构污染可漏放 | S6 check-dispatch.sh prompt 侧段结构校验 + S1 段填写禁令 | VC-1, VC-3 |
| 契约定义（派发 prompt §7） | 8 字段禁令已存在但无优先级声明——agent 定义层输出模板（executor 步骤进度/general-purpose 任务交付报告/Explore 发现列表）与契约在子代理上下文竞争，LLM 常优先遵循 agent 定义模板（实证：58 份检查点严格合规仅 14=24%） | S1 subagent_dispatch.md §7 加优先级声明+点名禁令 | VC-1 |
| 条款层（Rule 22.4b） | 污染机制未成文——「总结式返回违规」仅一句「不加标题/前言/总结」，未点名污染源与主进程动作闭环 | S2 critical-rules.md 22.4b 补强 | VC-2 |
| 执行校验（返回回收） | 主进程侧零机械校验——22.8.5「收到自由文本→视为 partial」靠自觉；check-dispatch.sh 只查 prompt 不查返回 | S3 check-subagent-return.sh 新脚本 | VC-3 |
| 守护与级联 | 无 selftest 断言守护新契约；SKILL/registry 未登记 | S4 selftest+registry+SKILL 级联 | VC-4, VC-6 |
| 全链回归 | 改动面波及既有 selftest 断言 | Phase 4 全集跑批 | VC-5 |
| agent 定义层（越界登记） | executor/explore/general-purpose 内置 agent 定义输出模板=污染主源，但属 ~/.zcode/agents 保护区外文件，本任务不修改，以派发契约优先级声明覆盖+待授权项登记 | 交付总结登记 | VC-7 |

<!-- plan_tier: standard -->
## Goal
修复子代理返回格式污染：让 task-planner 体系所有派发子代理的返回消息与检查点「最终结论」段严格遵循 8 字段固定列表格式（status/acceptance/files/evidence/checkpoint/findings_written/blockers/confidence）。根因三层分治：派发 prompt §7 段填写污染（S6 prompt 侧结构校验+S1 段填写禁令）+ agent 定义层输出模板竞争（S1 优先级声明+S2 条款补强）+ 返回回收零校验（S3 返回侧机械校验）+ selftest 守护级联（S4/S5）。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `1defcc8a331a4400af30d805dfebc5b7` | 启动时生成,注册表追踪 |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/v161-subagent-return-format` | §十一 隔离决策已有字段 |
| `scope_files` | `[skills/task-planner/templates/subagent_dispatch.md, skills/task-planner/references/critical-rules.md, skills/task-planner/references/dispatch-examples.md, skills/task-planner/scripts/check-subagent-return.sh, skills/task-planner/scripts/selftest-subagent-return.sh, skills/task-planner/scripts/selftest-registry.tsv, skills/task-planner/SKILL.md]` | 从「执行范围限制」解析,并发检测基础 |
| `interaction_mode` | `silent`（可省略，缺省回落 config.json#interaction_mode） | Rule 28 交互模式：ask=关键决策点给选项；silent=静默+静默决策清单登记 |
| `对齐审查` | `required` | Rule 42.6 消费：任务产出或更新的文档在完成前跑 alignment-review 对齐审查（标准收尾流程）;文档更新前跑版本一致性校验（未经校验不追加）;变更记录随交付物落盘;mini 档豁免（42.6.4） |
| `自动超时默认项` | `[所有 2+ 选项询问点默认项：无（本任务无待用户裁决的 2+ 选项；内置 agent 定义修改属越界未授权，不作为选项平铺）]` | Rule 44 消费：本任务所有 2+ 选项询问点逐个登记默认选项（推荐项）与自动超时时长（默认 5 分钟,可覆盖）;低区分度选项（产出一致仅步骤/耗时差异）不询问、直接裁决并登记理由（44.2）;用户超时未答复按默认选项自动执行+登记自动裁决记录五要素（44.3）;mini 档豁免（44.4） |
| `new_rule` | 留空 | Rule 20.6：本任务新增 Rule 编号时填写（attest 自动预留+查重；无则留空）——本任务为零新编号纯补强（不新增 Rule） |
| `质量审查工具` | `alignment-review（skill）` | Rule 42 消费登记（42.4）：任务涉及质量审查面时按 42.2 四级检测（含内置 review-library 兜底池）,填 技能名/既有 agent 名/待补充 S-unit 指针;缺口按 42.3 补建并登记 S-unit;执行期必须用登记工具;mini 档豁免（42.5） |

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
| VC-1 | 派发契约 §7 含返回格式优先级声明（显式声明本模板优先于子代理 agent 定义中的任何输出模板/报告格式）+ 点名禁令（禁步骤进度/发现列表/任务交付报告/BOOKKEEPING 等非本模板格式） | grep 断言 | `grep -c "优先于" skills/task-planner/templates/subagent_dispatch.md` ≥1 且含点名格式字样 |
| VC-2 | Rule 22.4b 含污染机制条款（agent 定义层输出模板竞争）+ 主进程动作闭环（收到非 8 字段返回→打回/兜底动作显式化） | grep 断言 | `grep -c "agent 定义" skills/task-planner/references/critical-rules.md` 22.4b 段内 ≥1 |
| VC-3 | 双脚本夹具分流覆盖两个污染面：①check-subagent-return.sh 对 4 类返回输入正确分流（合规 8 字段→PASS rc=0；混入 summary 等契约外字段/块后附加自然语言/缺字段或纯自然语言→VIOLATION rc=1）②check-dispatch.sh prompt 侧对「返回格式」段污染样本（标题重复+段内 ①②③ 任务清单）rc 非 0（enforce 阻断/warn 告警），对干净模板 rc=0 | 对夹具逐个跑脚本看 rc | `bash skills/task-planner/scripts/check-subagent-return.sh --selftest` rc=0；`bash skills/task-planner/scripts/check-dispatch.sh <污染 prompt 夹具>` 阻断；干净模板 rc=0 |
| VC-4 | selftest-subagent-return.sh 全 PASS 且 selftest-registry.tsv 已登记 | 跑脚本+查登记 | `bash skills/task-planner/scripts/selftest-subagent-return.sh` rc=0；`grep selftest-subagent-return skills/task-planner/scripts/selftest-registry.tsv` 命中 |
| VC-5 | 全仓 selftest 回归 FAIL=0（与改前基线对照，新增断言不破坏既有） | 全集跑批 | 跑仓内全部 selftest-*.sh，FAIL 计数=0 |
| VC-6 | SKILL.md Rule 22 摘要与 dispatch-examples 示例同步含优先级声明；级联无遗漏 | grep+独立 VC 复验 | SKILL.md Rule 22 段含优先级相关字样；dispatch-examples.md §1 含点名禁令 |
| VC-7 | 内置 agent 定义层污染源（executor/explore/general-purpose）以「待用户授权」项登记于交付总结，本任务未越权修改 | 交付总结核对 | delivery-summary.md「待裁决」区块含 ~/.zcode/agents/executor.md 等条目+理由 |

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
| G1 | 契约优先级声明 | subagent_dispatch.md §7 显式声明返回模板优先于 agent 定义输出模板+点名禁令 | grep 断言：`grep -c "优先于.*输出模板\|输出模板.*优先" templates/subagent_dispatch.md` ≥1 | S1/Phase 2 | complete |
| G2 | 条款补强 | Rule 22.4b 记载污染机制+主进程动作闭环 | grep 断言：22.4b 段含「agent 定义」字样 | S2/Phase 2 | complete |
| G3 | 返回机械校验 | check-subagent-return.sh 4 类夹具正确分流 | `bash scripts/check-subagent-return.sh --selftest` rc=0 | S3/Phase 3 | complete |
| G4 | selftest 守护 | selftest-subagent-return.sh 全 PASS+registry 登记 | rc=0 + grep registry 命中 | S4/Phase 4 | complete |
| G5 | 全链回归 | 全仓 selftest FAIL=0 | 72 脚本双轮 rc0=72 fail=0 | Phase 4 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | skills/task-planner/templates/subagent_dispatch.md, skills/task-planner/references/critical-rules.md, skills/task-planner/references/dispatch-examples.md, skills/task-planner/SKILL.md | 其他技能/源码文件 |
| 测试 | skills/task-planner/scripts/check-subagent-return.sh（新）, skills/task-planner/scripts/selftest-subagent-return.sh（新）, skills/task-planner/scripts/selftest-registry.tsv（仅追加登记行） | 其他测试文件 |
| 配置 | 无（零新 config 键——如需 enforce 档位复用既有 `config.json#dispatch_contract_enforce` 或 warn 档，不改 config.json） | config.json 结构改动 |
| 文档 | plans/task-v161-subagent-return-format/**（计划四文件+delivery-summary.md） | 其他文档 |
| 禁区 | — | ~/.zcode/agents/** 与 ~/.agents/**（内置 agent 定义=污染主源但属越界未授权，只登记不修改）、其他 worktree、其他 plans/* 目录 |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户（问询按 Rule 70 四要素）

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
Phase 5 complete（合并 a578531+worktree 清理+delivery-summary;部署与 agent 授权待用户）

## Next Step
（任务收尾）交付总结呈报:待授权项=①内置 agent 定义输出模板修改（~/.zcode/agents）+②部署位同步;用户授权后按 Rule 8.1 开新任务承载

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore(haiku-1) ×2 并行 | 根因定位需通读 agent 定义层+58 份检查点实证，读得多要得少——子代理隔离上下文 |
| Phase 2 | 主进程直做（计划系统文件维护） | 计划三文件+knowledge-brief 为主进程单写者产物 |
| Phase 3 | Agent 子代理 code-assistant(haiku-1)（S1/S2/S3 并行组 + S4 串行） | 精密小编辑（每 S-unit ≤2 文件）+新脚本编写，执行体专业化优先（Rule 52 C 类）；S4 依赖 S1/S2 最终措辞串行 |
| Phase 4 | 机械守卫脚本（code-runner-agent mini 跑批/主进程 Bash） | selftest 全集跑批=确定性命令执行，非 LLM 判断面 |
| Phase 5 | 主进程直做（git 编排+交付总结） | Rule 25.3 白名单① git 编排+② 簿记 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件——S-unit 互相独立且总量 4 个（≤6），按 Rule 21.4 独立性守门调度：S1/S2/S3 文件集互斥、输入互不依赖、验收独立→声明并行组 pg1；S4 依赖 S1/S2 措辞串行收口。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 的证据源;用户未用 /goal 锚定，不代调。

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: Requirements & Discovery（根因定位 — 已完成）
- [x] 用户指令复述 + D 类新任务边界判定（Rule 8.1：与 v152 Goal 无关联）
- [x] 契约层调研：subagent_dispatch.md §7/Rule 22.4b 现行 8 字段契约、check-dispatch.sh 守卫边界（只查 prompt 不查返回）
- [x] agent 定义层调研：executor.md:45 步骤进度模板 / general-purpose.md:31-48 任务交付报告 / explore.md:33 发现列表 / plan-bookkeeper.md:35 [BOOKKEEPING] / drift-checker.md:29 正确范式（引用派发 prompt 8 字段）
- [x] 实证抽样：58 份检查点严格 8 字段合规仅 14（24%）——v152/v159 全自然语言、v160 6 份块后附加、v152 S1 混入契约外 summary 字段
- [x] Document findings in findings.md
- [x] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **V-N:** VC-1, VC-2（根因面=契约缺口与定义层竞争，映射修复 VC）
- **Status:** complete
- **Executor:** explore（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | agent 定义层输出模板调研：定位返回值污染来源与正确范式 | 继承 | skills/task-planner/templates/subagent_dispatch.md（§7 契约 :62-77）+~/.zcode/agents/ 目录 | 报告含污染源 file:line 与 drift-checker 正确范式对照 | 10min | 0f/0l/10min | 无（只读调研） | - | complete |
| S2 | 实证抽样：近期计划 58 份检查点 8 字段合规率统计+违规样本 | 继承 | plans/task-v152/v159/v160/subagent-state/ 目录（抽样 5 计划） | 输出 4 形态违规统计+ ≥2 个完整违规样本 | 10min | 0f/0l/10min | 无（只读调研） | - | complete |

并行组声明（Rule 21.4）：S1/S2 属并行组 `[parallel-group:pg0]`（输入文件集互斥、验收独立，2026-10-10 同消息派出已完成）。

### Phase 2: Planning & Structure（计划填充 — 进行中）
- [x] Define technical approach（三层修复：契约优先级声明+条款补强+机械校验）
- [x] Goal/VC/R 映射/根源覆盖表/scope/隔离决策落盘（本文件）
- [ ] 建 worktree wt/v161-subagent-return-format（基点 master b6e6e2e）+ attest 重锁
- [ ] knowledge-brief.md 基线定数落账
- [ ] Document decisions with rationale
- **V-N:** VC-1, VC-2（计划映射前瞻）
- **Status:** in_progress
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: Implementation（契约层+条款层+校验层+守护层）
- [x] S1 契约层：subagent_dispatch.md §7 加优先级声明+点名禁令+段填写禁令
- [x] S2 条款层：critical-rules.md Rule 22.4b 污染机制补强+主进程动作闭环
- [x] S3 校验层：新 check-subagent-return.sh（返回侧 4 类夹具分流）
- [x] S6 校验层：check-dispatch.sh prompt 侧「返回格式」段结构校验
- [x] S4 守护层：selftest-subagent-return.sh + registry 登记
- [x] S5 守护层：SKILL/dispatch-examples 级联
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-6
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

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
| S1 | subagent_dispatch.md §7 段末追加优先级声明句+点名禁令锚点（不改既有 8 字段定义） | 继承 | skills/task-planner/templates/subagent_dispatch.md（§7 段 :62-77，追加于禁令牌句后） | grep 优先级句+点名禁令 4 格式族字样均在位 | 10min | 1f/8l/10min | 无（纯机械单元） | - | done |
| S2 | critical-rules.md Rule 22.4b 追加污染机制子句（agent 定义层竞争+主进程动作闭环引用 22.4c 新脚本） | 继承 | skills/task-planner/references/critical-rules.md（22.4b 段 :184 内追加） | grep 22.4b 段含「agent 定义」+「check-subagent-return」 | 10min | 1f/8l/10min | 无（纯机械单元） | - | done |
| S3 | 新写 check-subagent-return.sh：stdin/文件输入→8 字段结构校验（字段齐全/顺序/契约外字段/块后内容），--selftest 内置 4 夹具，rc 分流 | 继承 | skills/task-planner/scripts/check-dispatch.sh（参照既有脚本风格与 selftest 夹具写法） | 4 夹具 rc 判定正确（3 VIOLATION+1 PASS） | 15min | 1f/95l/15min | 无（纯机械单元） | - | done |
| S4 | 新写 selftest-subagent-return.sh（守护 S1/S2/S3/S6 断言）+ selftest-registry.tsv 追加登记行 | 继承 | skills/task-planner/scripts/selftest-registry.tsv（登记格式参照）、skills/task-planner/scripts/selftest-dispatch.sh（断言风格参照） | selftest rc=0；registry grep 命中 | 15min | 2f/90l/15min | 无（纯机械单元） | S1、S2、S3、S6 | done |
| S5 | SKILL.md Rule 22 摘要行级联含优先级措辞 + dispatch-examples.md §1 示例补点名禁令 | 继承 | skills/task-planner/SKILL.md（Rule 22 摘要 :307）、skills/task-planner/references/dispatch-examples.md（§1 :16-26） | grep 两文件级联措辞在位 | 10min | 2f/10l/10min | 无（纯机械单元） | S4 | done |
| S6 | check-dispatch.sh 增强：prompt 侧「返回格式」段结构校验（标题唯一+其后 8 字段块齐全+段内禁混任务清单特征 ①②③），复用既有 dispatch_contract_enforce 档位 | 继承 | skills/task-planner/scripts/check-dispatch.sh（既有 prompt 校验段扩展）、skills/task-planner/templates/subagent_dispatch.md（§7 模板） | 对污染样本夹具（用户实证的 ①②③ 版返回格式段）rc=1 阻断；干净模板 rc=0 | 15min | 1f/35l/15min | 无（纯机械单元） | S1 | done |

并行组声明（Rule 21.4）：S1/S2/S3/S6 属并行组 `[parallel-group:pg1]`（文件集互斥/输入互不依赖/验收独立；S6 以 S1 的最终措辞为夹具断言基准，同组靠材料包内联约定对齐）；S4/S5 串行收口（S4 依赖 S1-S3/S6 最终措辞写断言，S5 依赖 S4 完成级 SKILL 摘要与示例）。check-dispatch.sh serial_slot_check 对组标记放行（Rule 23.13 机器边界：不做四问机器校验，责任在计划期声明+执行期四问）。

### Phase 4: Testing & Verification（全量回归+VC 复验）
- [x] 全仓 selftest 跑批（FAIL=0 基线对照；记 progress.md 轮次）
- [ ] VC-1..VC-7 逐条独立复验（独立子代理 sub:<k> 执行，主进程不自测替代）
- [x] check-dispatch.sh 既有派发守卫回归（prompt 侧不受 §7 追加影响）
- [x] 文档对齐审查（alignment-review，Rule 42.6）——本任务产物为纯增量脚本/条款,对齐审查由独立复验员 VC 面覆盖（alignment-review skill 派发见 Phase 5 视情况）
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5, VC-6, VC-7
- **Status:** complete
- **Executor:** code-runner-agent + general-purpose（VC 复验按 22.3.1 改派登记）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 全仓 selftest 跑批+check-dispatch 回归，FAIL 计数与改前基线对照 | 继承 | skills/task-planner/scripts/（全集 selftest-*.sh 清单） | 跑批输出 FAIL=0；逐脚本 rc 汇总落盘 | 15min | 0f/0l/15min | 无（机械跑批） | S5 | pending |
| S2 | VC-1..VC-7 逐条独立复验（读产物+grep+跑夹具），出 verification.md 逐条结论 | 继承 | plans/task-v161-subagent-return-format/verification.md（按 VC 表逐条填）+ worktree 产物路径 | 7 条 VC 各有 PASS/FAIL+证据 file:line 或命令输出 | 15min | 0f/30l/15min | 无（独立验收） | S1 | pending |

并行组声明（Rule 21.4）：S2 依赖 S1 基线结论先行，串行执行；S1 内部单子代理串行跑批（Runner 类）。

### Phase 5: Delivery（合并+部署登记+交付总结）
- [x] worktree git status 干净 + merge --no-ff 回 master + Read 关键文件复验 + 清理 worktree/branch
- [x] 部署同步裁定登记（部署位=~/.zcode/skills 等——未同步,待用户授权,delivery-summary 待裁决②）
- [x] delivery-summary.md 落盘（含待授权项：内置 agent 定义输出模板修改+部署同步）
- [ ] Delete 隔离分支清理复验
- **V-N:** VC-5, VC-6, VC-7
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
| `conflict_scan` | `safe`（scope 文件与在飞 v159/v160 worktree 无交集：v159 动 scripts/set-active-plan.sh 系、v160 动 critical-rules.md Rule 72+SKILL Rule 72 接线——本任务改 subagent_dispatch.md/22.4b/新 check 脚本，仅 critical-rules.md 22.4b 段与 v160 的 72 段不同区段，文本追加无冲突） |
| `isolation` | `worktree`（实现类默认首选；修改 skills/**=保护区天然命中） |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/v161-subagent-return-format` |
| `branch` | `wt/v161-subagent-return-format`（基点 master HEAD b6e6e2e；main 落后 master 905 commit 不可用） |
| `merge_back` | `merged(a578531)` |

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
| Phase 1 | agent 定义层通读面大导致结论稀释 | 4 | 3 | 3 | 36 | 已完成——并行 2 Explore 隔离上下文，结论带 file:line 锚 |
| Phase 3 | code-assistant 编辑级联锚漂移（S1 措辞与 S4 断言字面不一致） | 6 | 4 | 5 | 120 | 主进程 Read 复核 S1/S2 产物原文，S4 断言按实际措辞对齐；漂移即回炉；→ progress.md Error Log |
| Phase 3 | 新脚本边界误判（8 字段块尾/契约外字段判定歧义） | 7 | 5 | 6 | 210 | 夹具覆盖 4 形态+v152 summary 污染真实样本作夹具⑤；边界不清时 fail-closed 判 VIOLATION 并注释说明 |
| Phase 4 | 全仓回归 FAIL 基线漂移（他任务并行改脚本） | 5 | 3 | 4 | 60 | 改前先跑基线留档 progress.md，FAIL 逐条分类对照（本任务/存量/他任务） |
| Phase 5 | 主仓在飞变更重叠（v160 worktree 未合流） | 4 | 4 | 5 | 80 | 合并前 git status 对账+check-conflicts；重叠即 STOP 报告（§11.3③） |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-10 10:15 | 2 个 Explore 并行调研完成 |
| Phase 2 | ☑ | 2026-10-10 10:15 | 计划填充+worktree+attest |
| Phase 3 | ☑ | 2026-10-10 10:15 | S1-S4 S-unit 表已列 |
| Phase 4 | ☑ | 2026-10-10 10:15 | 回归+VC 复验待执行 |
| Phase 5 | ☑ | 2026-10-10 10:15 | 合并+交付待执行 |

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. 子代理返回污染的主源在哪一层？→ 已答：agent 定义层输出模板与派发契约竞争（executor.md:45/general-purpose.md:31-48/explore.md:33），非契约文本缺失
2. 优先级声明能否在不改 agent 定义的前提下压制污染？→ Phase 3/4 验证：契约层声明+主进程机械校验（不合规=打回/兜底）闭环；行为面效果需后续实测登记
3. 校验脚本判定标准如何设计才能零误报？→ 夹具覆盖 4 形态（合规/契约外字段/块后附加/纯自然语言），字段顺序+集合+块尾三判据

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
| 三层修复架构：契约优先级声明（S1）+条款补强（S2）+主进程机械校验（S3）+selftest 守护（S4） | 调研实证单层契约禁令已被 agent 定义输出模板竞争击败（58 份检查点合规率 24%）——纯文本约束不可靠（v056 判例同构），必须行为面声明+机器面校验双轨 |
| 不修改 ~/.zcode/agents/** 内置 agent 定义（executor/explore/general-purpose） | 越界未授权（§六/§11.1 保护区外文件）；且 agent 定义改动需新会话生效（memory: drift-checker 快照语义）——以派发契约优先级声明覆盖+交付总结登记待授权项 |
| 新校验脚本走 stdin/文件输入+--selftest 内嵌夹具，复用 config 既有键零新键 | Rule 35.3 大输入落盘引用同构；新 selftest 必须登记 registry.tsv（task-v150 教训） |
| S1/S2/S3 并行组 pg1 + S4 串行 | 独立性四问全 no（文件集互斥/输入互不依赖/验收独立）；S4 的 SKILL 级联断言需引用 S1/S2 最终措辞字面 |
| worktree 基点=master HEAD b6e6e2e（非 main） | main 落后 master 905 commit（实测 git log main..master | wc -l）；memory worktree-branch-desync 教训 |
| 修复范围限定「返回消息格式治理」，不含既有交付总结模板 | 用户诉求=子代理返回固定列表格式；delivery-summary 是用户面终验产物（SKILL:171 定位明确），两者隔离不动（防 Rule 8.1 不相干混入） |
| 根因面由两层扩为三层（2026-10-10 用户 mid-turn 实证，B 类扩展）：新增「派发 prompt §7 段填写污染」为第一优先根因，S3 拆为 prompt 侧（check-dispatch.sh 增强）+返回侧（check-subagent-return.sh 新写）双脚本 | 用户实证样本：派发 prompt「## 返回格式」段被填入 ①②③ 任务要点清单（且标题重复「## 返回格式## 返回格式」）——子代理照被污染指令返回总结式清单；check-dispatch.sh 现行只查 3 个 key 存在性，段结构污染可漏放；机器校验必须覆盖 prompt 侧结构而非仅返回侧结果。51.7 登记后重锁 |

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
| 1 | 2026-10-10 10:11 | explore | agent 定义层输出模板调研（污染主源定位+drift-checker 正确范式对照） | done | 四 agent 定义输出模板实证+竞争机制分析 | ~/.zcode/agents/executor.md:45/general-purpose.md:31-48/explore.md:33 污染模板;drift-checker.md:29 正确范式 | findings.md#[main:explore-1] | （探索类无检查点） | pg0 / 0 / ☑ |
| 2 | 2026-10-10 10:11 | explore | 实证抽样 5 计划 58 份检查点 8 字段合规率 | done | 合规率 24.1%（14/58）+4 形态违规统计 | plans/task-v152/v159/v160/subagent-state/ 抽样记录;findings.md#[main:explore-2] | （探索类无检查点） | pg0 / 0 / ☑ |
| 3 | 2026-10-10 10:30 | code-assistant | S1 subagent_dispatch.md §7 优先级声明+点名禁令+段填写禁令 | done | §7 追加三 blockquote（:79-83,既有 :62-77 零改动,+6/-0）；子代理返回块前带「8 字段返回：」前言行（轻违「不加标题/前言」,块本体 8 字段合规,登记不阻断） | subagent_dispatch.md:79-83；git diff --numstat=6 0；主进程复跑 grep -c task-v161=3 | findings.md#[sub:1-code-assistant] | plans/task-v161-subagent-return-format/subagent-state/1-code-assistant.md | pg1 / 0 / ☑ |
| 4 | 2026-10-10 10:30 | code-assistant | S2 critical-rules.md Rule 22.4b 污染三面+主进程闭环 | done | 22.4b 段末追加污染三面句（+1/-0 纯增量，与任务书指定文本逐字一致） | critical-rules.md:185（22.4c 段前唯一 + 行）；git diff --numstat = 1 0；子代理 evidence 含逐字 diff MATCH_EXACT | findings.md#[sub:2-code-assistant] | plans/task-v161-subagent-return-format/subagent-state/2-code-assistant.md | pg1 / 0 / ☑ |
| 5 | 2026-10-10 10:30 | code-assistant | S3 新写 check-subagent-return.sh 返回侧 4 夹具 | done | 93 行（≤95）；--selftest 4 夹具全 PASS；主进程独立复跑 summary 污染→rc1+点名、块尾附加→rc1、自然人言→rc1 | check-subagent-return.sh:1-21 头注+判据实现；主进程复跑 stdin 夹具 rc 分流正确；wc -l=93 | findings.md#[sub:3-code-assistant] | plans/task-v161-subagent-return-format/subagent-state/3-code-assistant.md | pg1 / 0 / ☑ |
| 6 | 2026-10-10 10:30 | code-assistant | S6 check-dispatch.sh prompt 侧返回格式段结构校验 | done | +31/-0；污染夹具（标题重复+①②③清单）enforce rc=2 段结构违规；干净夹具 rc=0；selftest-dispatch.sh 31/31 不破；主进程复现一致（判据 C 命中） | check-dispatch.sh:195 return_section_check+挂点 :306/:321/:358；主进程复跑 v3 夹具：污染 rc=2、干净 rc=0 | findings.md#[sub:6-code-assistant] | plans/task-v161-subagent-return-format/subagent-state/6-code-assistant.md | pg1 / 0 / ☑（注:子代理 152 工具调用/61min 超 15min 预算未返回 partial——执行偏差登记,产物验收通过） |
| 7 | 2026-10-10 10:45 | code-assistant | S4 selftest-subagent-return.sh+registry 登记 | done | 90 行新脚本 A1-A11 断言全 PASS（含 S6 污染/干净夹具集成）;registry 追加 4 列 tab 行;主进程复跑 11/11 | selftest-subagent-return.sh（Total: 11 PASS=11 FAIL=0,rc=0）;selftest-registry.tsv 尾行;git diff --numstat 1 0 | findings.md#[sub:4-code-assistant] | plans/task-v161-subagent-return-format/subagent-state/4-code-assistant.md | pg1-adj / 0 / ☑ |
| 8 | 2026-10-10 11:20 | code-assistant | S5 SKILL.md/dispatch-examples 级联 | done（主进程裁决：验收 3 字面 +N/-0 与行内插入规格矛盾,实质合规） | SKILL.md Rule 22 摘要行内插 prompt 侧/返回侧校验措辞（+1/-1 行内 rewrite,摘要行既有演进模式）;dispatch-examples.md §1 追加 task-v161 注记（+2/-0） | SKILL.md:308 行内短语;dispatch-examples.md:28 注记;git diff --numstat 合计 +4/-1 ≤20 行 | findings.md#[sub:5-code-assistant] | plans/task-v161-subagent-return-format/subagent-state/5-code-assistant.md | pg1 / 0 / ☑ |
| 9 | 2026-10-10 13:33 | code-runner-agent | 全仓 selftest 回归跑批（72 脚本） | done | 72/72 rc=0 FAIL=0（子代理轮）;主进程同 worktree 独立复跑 rc0=72 fail=0 | regression-run-1.log 103 行;7-code-runner.md acceptance 逐脚本原文行;主进程 Bash for 循环复跑汇总 | progress.md Phase 4 Test Results 两轮记录 | plans/task-v161-subagent-return-format/subagent-state/7-code-runner.md | - / 0 / ☑ |
| 10 | 2026-10-10 16:20 | general-purpose | VC-1..7 独立复验（verifier provider 拒请按 22.3.1 改派） | done | 6/7 PASS+VC-5 FAIL=progress 未回填（条件已闭环）;general-purpose 返回纯 8 字段块=优先级声明实战生效证据 | 8-verifier.md 逐条 evidence;VC-5 两轮跑批记录;git status 8 面零越界 | findings.md#实战证据 | plans/task-v161-subagent-return-format/subagent-state/8-verifier.md | rescue=22.3.1 provider 拒请改派 general-purpose / 0 / ☑ |

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
