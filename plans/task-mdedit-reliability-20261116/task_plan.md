# Task Plan: markdown编辑可靠性工具化
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} token 由 init-session.sh render_template() 脚本渲染（task-id/任务名/日期/路径）；尖括号中文占位=模型填写面，脚本禁碰 -->
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  选定 variant 后 template_type 填所选类型名（白名单=/home/terry/.zcode/skills/task-planner/templates/variant/*-type.md 动态派生，见 check-template-type.sh）；general=通用回退（恒合法，Rule 34.1）
  plan_tier ∈ {standard, mini}（Rule 38.1，mini 四条件机器判定）；execution_lane ∈ {L0, L1, L2}（Rule 38.7，缺省 L1；L0 禁滥用见 38.7 末段）
  check-template-type.sh 三形态之一：行首 `^template_type:`（本块）/ 表格行 / HTML 注释；本块用行首形态 -->
template_type: general
plan_tier: standard
execution_lane: L1
cost_estimate:
  main_process_opus: 1
  subagent_calls:
    general-purpose: 2
    decision-arbiter: 1
    code-assistant: 3
    code-runner-agent: 2
  estimated_opus_equivalent: 1.21
  estimated_savings_vs_naive: 0.55
<!-- 
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC（核心问题的可观察解决证据，非手段产物完成）；目标型任务终验必填「🎯 核心目标达成裁决」区块（58.5） -->

- **R1**: 「/goal 解决当前项目 不只是当前项目 也就是在执行markdown文件编辑时候总是出错 是否可以使用更加有效的优化 选择更加高级的工具或者 引入 json作为中间件 在编辑过程可以有效管理   还是 编辑脚本等方案优化  也就是 这种 解决编辑文档过程 出现多次编辑后混乱问题 或者编辑一个有效的工具 或者引入已有的工具来规避这种错误风险 这个错误出现频率极高 必须纠正」<sub>（[目标]；逐字锚=user-session-log.md #1）</sub>
- **R2**: 「选择更加高级的工具」<sub>（[手段]；候选方向1，R1 原文子串）</sub>
- **R3**: 「引入 json作为中间件 在编辑过程可以有效管理」<sub>（[手段]；候选方向2，R1 原文子串）</sub>
- **R4**: 「编辑脚本等方案优化」<sub>（[手段]；候选方向3，R1 原文子串）</sub>
- **R5**: 「编辑一个有效的工具 或者引入已有的工具来规避这种错误风险」<sub>（[手段]；候选方向4，R1 原文子串）</sub>
- **R6**: 「这个错误出现频率极高 必须纠正」<sub>（[目标]；R1 原文子串，强调可靠性与纠正优先级）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-3, VC-6 | 计划覆盖跨项目工具级防护目标、四类失败模式对策、跨环境落地路径（task_plan.md+knowledge-brief.md+verification.md 在位且含对应区块/证据锚） |
| R2 | VC-1, VC-4 | P2 裁决入口列出“更高级工具”方向并给评估结论/取舍（含推荐项标注） |
| R3 | VC-1, VC-2, VC-4 | P2/P3 评估并设计“JSON 作为中间件（edit-ops 指令单）”的校验/原子应用/回读/回滚链路 |
| R4 | VC-1, VC-2, VC-4 | P2/P3 评估并设计“编辑脚本方案”及其与 JSON 指令单的关系（脚本执行器） |
| R5 | VC-1, VC-3, VC-4 | P2 评估“编辑有效工具/引入已有工具”并裁决复用或新建，P4 接线技能触发点 |
| R6 | VC-2, VC-5, VC-6 | 根源覆盖表+VC/验证命令覆盖拦截/检测/回滚机制与实弹冒烟/selftest 计划，目标为机制性降错 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/task-mdedit-reliability-20261116/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`/mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面（对应用户痛点） | 修复点（S-unit/Phase/机制） | VC |
|------|--------------------------|------------------------------|----|
| 编辑意图表达 | ①锚点失配反复重试烧时间：old_string 依赖脆弱上下文、唯一性难保证 | P3：edit-ops JSON 指令单显式表达 op（replace/insert/delete/move）+ 目标锚点（heading/行范围/内容hash/前后文约束）+ 预校验（存在性/唯一性/冲突检测）失败即整单拒绝不落盘 | VC-2, VC-4 |
| 变更应用 | ②new_string 误删相邻内容（吞块，历史判例三犯）：插段/替换时锚行被吞或边界错位 | P3：原子应用（全过才写）+ 结构回读断言（段清单/锚行守恒/预期 diff 形态）+ 应用前自动备份；P4：接线 Rule 106/106.1a 触发前置校验 | VC-2, VC-4, VC-5 |
| 多步编辑状态 | ③多次编辑后状态混乱（改了什么/还剩什么说不清） | P3：指令单含 step id/依赖/状态回执；执行产出 apply-report（已应用/跳过/失败+原因+前后hash）；回读验证生成可审计结果 | VC-2, VC-5 |
| 批量替换 | ④python/sed 批量替换静默失配（判例 3 处） | P3：禁静默失配策略——每条 op 返回 matched_count/changed，0 命中或非预期命中=FAIL；P5：失败用例实弹冒烟覆盖静默失配场景 | VC-2, VC-5 |
| 方案与落地 | 跨项目“必须纠正”但方案碎片化、无统一工具与触发接线 | P1/P2：四候选方向真实调研+裁决推荐；P4/P6：技能与 task-planner/task-discipline 接线、多环境部署计划 | VC-1, VC-3, VC-6 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Goal 原文不改；R1-R6 与 user-session-log.md #1 逐字锚定；VC 逐条可验证且带命令；四候选方向在 P2 裁决入口齐备并标注推荐项；计划期单写者仅改本计划目录 5 文件（task_plan/findings/knowledge-brief/progress/verification） | 本文件 Goal/R 区块/VC/Scope；user-session-log.md #1 |
| 🔀 可变量 | 具体技术选型细节（在 P2 裁决后落定）、S-unit 内部实现拆分顺序、调研渠道选择、是否新建 md-edit-ops 技能或扩展 markdown-editor（P2 裁决） | P2 Decisions / findings.md |
| 📈 学得量 | 外部工具/仓库调研结论、markdown-editor 实测能力差距、edit-ops schema 试错与回归结果→findings.md/progress.md/knowledge-brief.md §2§3 回填；禁反写 R/VC/Goal | findings.md, progress.md, knowledge-brief.md |

## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and delete functionality."
-->
为 markdown 多次编辑高频出错建跨项目工具级防护：结构化 edit-ops JSON 编辑指令单 + 校验/原子应用/回读验证/回滚脚本 + 技能接线，使编辑错误被机制性拦截/检测/回滚

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（后续实现涉及 Bun+TS 脚本/技能文件/接线文档，代码与规则改动面需复核） |
| `session_id` | `task-mdedit-reliability-20261116` | 启动时生成,注册表追踪 |
| `worktree_path` | `n/a（计划期文档撰写，未创建实现 worktree；实现期按 Rule §十一在 P3 前决策）` | §十一 隔离决策已有字段 |
| `scope_files` | 计划期：`plans/task-mdedit-reliability-20261116/{task_plan,findings,knowledge-brief,progress,verification}.md`；实现期预估：`skills/md-edit-ops/SKILL.md`（或扩展 `/home/terry/.zcode/skills/markdown-editor/SKILL.md`，P2 裁决）+ `skills/task-planner/scripts/md-edit-ops.ts`（或等价路径）+ `skills/task-planner/scripts/selftest-md-edit-ops.sh` + 接线文件（task-planner/task-discipline/markdown-editor 相关 SKILL 与 references，P2/P4 定稿） | 从「执行范围限制」解析,并发检测基础 |
| `interaction_mode` | `ask`（缺省回落 config.json#interaction_mode） | Rule 28 交互模式：ask=关键决策点给选项；silent=静默+静默决策清单登记 |
| `对齐审查` | `[登记]` P4/P6 文档与技能接线完成后跑 alignment-review/版本一致性校验并随交付落盘；本计划期产出暂 n/a | Rule 42.6 消费：任务产出或更新的文档在完成前跑 alignment-review 对齐审查（标准收尾流程）;文档更新前跑版本一致性校验（未经校验不追加）;变更记录随交付物落盘;mini 档豁免（42.6.4） |
| `自动超时默认项` | `[询问点: 默认选项/超时值]` P2 方案裁决=推荐“JSON edit-ops 指令单 + Bun 脚本执行器 + 技能接线”混合方案 / 5min；是否新建独立技能 vs 扩展 markdown-editor=推荐“新建 skills/md-edit-ops + 复用 markdown-editor 约定” / 5min | Rule 44 消费：本任务所有 2+ 选项询问点逐个登记默认选项（推荐项）与自动超时时长（默认 5 分钟,可覆盖）;低区分度选项（产出一致仅步骤/耗时差异）不询问、直接裁决并登记理由（44.2）;用户超时未答复按默认选项自动执行+登记自动裁决记录五要素（44.3）;mini 档豁免（44.4） |
| `new_rule` | `留空` | Rule 20.6：本任务新增 Rule 编号时填写（attest 自动预留+查重；无则留空） |
| `质量审查工具` | `[检测结论]` 计划期：general-review/alignment-review 作为文档一致性审查候选；实现期 P5：selftest-md-edit-ops.sh + code-quality-review + test-quality-review；缺口在 P4 登记 S-unit 补建 selftest（42.3） | Rule 42 消费登记（42.4）：任务涉及质量审查面时按 42.2 四级检测（含内置 review-library 兜底池）,填 技能名/既有 agent 名/待补充 S-unit 指针;缺口按 42.3 补建并登记 S-unit;执行期必须用登记工具;mini 档豁免（42.5） |

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
| VC-1 | P2 方案裁决入口齐备：四候选方向（高级工具/JSON中间件/编辑脚本/有效工具或引入已有工具）逐项评估且推荐项明确标注（Recommended）含取舍理由 | 检查 task_plan.md Phase 2 与 Decisions/裁决表包含四方向与推荐标记 | `grep -n "候选方向" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "(Recommended)" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md` |
| VC-2 | 设计覆盖四类失败模式（锚点失配/吞块/状态混乱/静默失配）并给出机制性对策：edit-ops JSON 指令单 + 预校验 + 原子应用(全过才写) + 回读验证 + 备份回滚 | 检查根源覆盖表与 P3 设计/S-unit 描述关键词齐备 | `grep -n "原子应用" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "预校验" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "回读验证" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "回滚" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md` |
| VC-3 | 跨项目落地路径明确：技能接线点（md-edit-ops/markdown-editor/task-planner/task-discipline）与多环境部署（zcode/claude/cursor/agents）在 P4/P6 列出 | 检查 Scope/Phase 4/Phase 6 与 knowledge-brief 部署位族记录 | `grep -n "zcode" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "cursor" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "agents" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md` |
| VC-4 | Phase 1-6 全部声明 `**Executor:**`；Executor≠主进程的派发型 Phase 附 S-unit 表且数据行含执行体/输入摘要/验收/≤15min 预估 | 结构检查：Executor 字段与 S-unit 表头/数据行存在 | `grep -n "^- \*\*Executor:\*\*" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md && grep -n "^| S[0-9]" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/task_plan.md` |
| VC-5 | verification.md 包含与 VC-1..VC-6 对应的 V-N 段，每段含行首 `**Verify command**:` 且为可执行命令（非占位） | 检查 verification.md 的 Verify command 行数量与内容 | `grep -nE "^  \*\*Verify command\*\*:" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/verification.md` |
| VC-6 | R 锚与知识底座落盘：R1 逐字等同 user-session-log.md #1；findings.md 含四类失败模式+Rule 106/106.1a+markdown-editor 摘要；knowledge-brief.md §2/§3 含技能架构/部署位族/Rule 106/markdown-editor 事实 | 交叉检查三文件关键锚点 | `grep -n "锚点失配" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/findings.md && grep -n "106.1a" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/knowledge-brief.md && grep -n "markdown-editor" /mnt/data/dev/task-planner-skill/plans/task-mdedit-reliability-20261116/knowledge-brief.md` |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard/full 必填，mini 豁免）
<!-- task-dualqc-20261104 新增：双轮质检机制在计划阶段显式设计——派发型实质产出 S-unit 默认两道检核（第一轮执行体自审 103.2 checkpoint 自审段；第二轮主代理派全新子代理独立复检 103.3，档位升一档 103.4、复检任务书简洁五要素 103.5）；多文件变更集（≥2 受管文件）Phase 翻转前过 103.6 同步完整性审查（关联面推导四族→同步核对清单全绿）。豁免面=103.7，逐 S-unit 登记理由；mini 档整体豁免。 -->
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | 默认全适用：P1 调研产出、P3 工具实现、P4 技能接线、P5 selftest/冒烟产出（派发型实质产出 S-unit） |
| 豁免登记 | P2 方案裁决（主进程决策+文档更新，非派发型实质代码产出）按 103.7 登记；P6 部署编排由主进程执行但涉及≥2 受管文件时触发 103.6 同步完整性审查 |
| 多文件变更集预判 | 预判触发 103.6：P4（技能+规则接线多文件）、P6（多环境部署位同步） |

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
<!--
  WHEN: 终验时填写;含 [目标] 标注需求（下方 R 行）的任务必须在交付前出三态裁决
  WHY: Rule 58.5 完成裁决门——「分析报告已交付」不等于「问题解决了」;not-solved/partial 禁止标 COMPLETE
  载体: 58.4 手段/目标二分在需求原文区逐条标注 [手段]/[目标];本区块回收目标型需求的解决状态
-->
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1, R6 |
| **裁决** | `pending`（终验填写：solved / partial / not-solved） |
| **解决证据锚** | 待终验：edit-ops 工具脚本+schema+apply-report+回滚/回读验证+selftest 通过+冒烟记录+接线/部署证据（file:line/命令输出） |
| **未解决面+原因** | 待终验填写（partial/not-solved 必填） |
| **已排除路径** | 待终验填写（not-solved 必填：试过什么+为何不行） |
| **下一步建议** | 待终验填写（not-solved 必填：可执行的下一步）（按 Rule 70：对象路径+看点+动作） |

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
| G1 | 调研盘点 | 完成四候选方向真实调研与本地资产盘点 | findings.md 含外部/本地证据锚与 markdown-editor 摘要（`grep -n "Research Findings" plans/task-mdedit-reliability-20261116/findings.md`） | P1/S1-S3 | pending |
| G2 | 方案裁决 | 四方向评估并产出推荐方案(Recommended)+设计草案 | task_plan.md P2 含四方向表与推荐标注+取舍理由（`grep -n "(Recommended)" task_plan.md`） | P2/S1-S2 | pending |
| G3 | 工具实现 | 实现 edit-ops JSON 解析/预校验/原子应用/回读/回滚 | 脚本存在且单测/selftest 通过（`test -f skills/task-planner/scripts/md-edit-ops.ts && bash skills/task-planner/scripts/selftest-md-edit-ops.sh`） | P3/S1-S4 | pending |
| G4 | 技能接线 | md-edit-ops 技能与规则/触发点接线完成 | SKILL.md 与接线文件含触发与调用约定（`grep -rn "md-edit-ops" skills/task-planner skills/md-edit-ops 2>/dev/null`） | P4/S1-S3 | pending |
| G5 | 回归冒烟 | selftest+真实 md 成功/失败用例冒烟通过 | 冒烟日志/命令退出码 0 且失败用例被拦截（`bash skills/task-planner/scripts/selftest-md-edit-ops.sh`） | P5/S1-S3 | pending |
| G6 | 多环境部署 | zcode/claude/cursor/agents 同步并终验 | 部署位 diff/存在性检查一致（按 repo deploy 脚本执行后 `diff -rq` 或等价证据） | P6/S1-S2 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件（计划期已知/预估，P2 裁决后可收敛更新） | 禁止 |
|-------|----------------------------------------------------|------|
| 计划文档（本任务计划期单写者） | `plans/task-mdedit-reliability-20261116/task_plan.md`, `plans/task-mdedit-reliability-20261116/findings.md`, `plans/task-mdedit-reliability-20261116/knowledge-brief.md`, `plans/task-mdedit-reliability-20261116/progress.md`, `plans/task-mdedit-reliability-20261116/verification.md` | 计划目录外文件；本目录其他文件（user-session-log.md 等） |
| 源码/脚本（实现期预估） | `skills/task-planner/scripts/md-edit-ops.ts`（或 P2 裁决等价路径）, `skills/task-planner/scripts/selftest-md-edit-ops.sh` | 其他未列脚本/源码 |
| 技能（实现期预估） | `skills/md-edit-ops/SKILL.md`（新建，P2 推荐）或 `/home/terry/.zcode/skills/markdown-editor/SKILL.md`（扩展，P2 备选）；`skills/task-planner/SKILL.md`、`skills/task-discipline/SKILL.md` 等接线必要文件（P4 白名单化） | 无关技能目录 |
| 配置/部署 | 部署目标位镜像（zcode/claude/cursor/agents 对应已安装技能路径，P6 以 deploy 机制为准） | 无关配置、基础设施 |
| 文档 | 本计划 5 文件；P4 可能更新的 `skills/task-planner/references/*` 中与 md-edit 接线直接相关条目（P2 定稿后列名） | 其他文档 |

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
| CA-1 | `plans/task-mdedit-reliability-20261116/task_plan.md` 全文占位→实质计划 | 更新 | 替代（四条件：①用户显式要求“写入/填充计划文档”②同场景=初始化占位替换为定稿计划 ③已 Read 模板现状 ④计划期产出将经回读与 VC 校验） | 「把用户痛点转为结构化计划文档…写入: 1. task_plan.md…」 | user-session-log.md #1 + 本任务输入契约 | 填充 Goal/R/VC/Phase/Executor/S-unit/根源覆盖/证据面/裁决/调研计划等必填区块 |
| CA-2 | `plans/task-mdedit-reliability-20261116/findings.md` 占位→实质发现 | 更新 | 替代（同 CA-1，初始化占位替换） | 「2. findings.md：Research Findings 预留段 + 已知失败模式四条…」 | 同上 | 写入失败模式/Rule 106/markdown-editor 现状与调研预留 |
| CA-3 | `plans/task-mdedit-reliability-20261116/knowledge-brief.md` 占位→实质知识底座 | 更新 | 替代（初始化占位替换） | 「3. knowledge-brief.md：§2/§3 已知事实底座…」 | 同上 | 填充 §1-§5/§6/§7 与事实锚点 |
| CA-4 | `plans/task-mdedit-reliability-20261116/progress.md` 占位→初始化留痕 | 更新 | 替代（初始化占位替换） | 「4. progress.md：R 锚定行 + 初始化留痕…」 | 同上 | 写入 R 锚/初始化动作/sync-todos 延后理由 |
| CA-5 | `plans/task-mdedit-reliability-20261116/verification.md` 占位→VC 对应 V-N | 更新 | 替代（初始化占位替换） | 「5. verification.md：VC 对应 V-N 段…」 | 同上 | 写入 VC 对应验证段与 **Verify command** 行 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | Rule 106/106.1a 文档修改复检与结构插段纪律 | `skills/task-discipline/references/critical-rules-discipline.md:722-760`、`skills/task-planner/SKILL.md:118,165` | 必读 | ☑（计划期已读锚点） |
| 官方文档 | task-planner 技能架构与脚本/模板约定 | `/mnt/data/dev/task-planner-skill/README*`（如存在）、`skills/task-planner/SKILL.md`、`skills/task-planner/scripts/`、`templates/` | 必读 | ☑ |
| 项目内部文档/知识库 | 既有 markdown-editor 全局技能现状 | `/home/terry/.zcode/skills/markdown-editor/SKILL.md` | 必读 | ☑（计划期已读） |
| 项目内部文档/知识库 | 部署位族与同步机制先例 | `INSTALL.md`（如存在）、`knowledge/entries/worktree-lifecycle-mergeback.md`、`knowledge/INDEX.md` | 参考 | ☑（路径已定位，细节 P1/P6 深读） |
| 文献/论文 | Markdown 结构化编辑/patch/AST/事务性写入方案（外部） | P1 调研产出（GitHub/文档/文章 URL+日期） | 必读（P1 产出后） | ☐ |
| 图书/教程 | JSON 中间件/事务性文件更新/回滚模式实践（外部） | P1 调研产出 | 参考 | ☐ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 跨项目场景下，AI 代理基于 `old_string/new_string` 锚点匹配编辑 markdown 时高频出现锚点失配、吞块、状态混乱与静默失配；仅靠人工纪律（Rule 106/106.1a）不足以稳定拦截。引入“结构化 edit-ops JSON 指令单 + 预校验/原子应用/回读验证/备份回滚 + 技能接线”的工具级机制后，能否将错误从过程依赖转为可被机制性拦截/检测/回滚，从而显著降低编辑失败率并可交付可复用方案？

**T2 问题解构四问（methodology.md §T2，Rule 31.2 同法不同时见）**：
1. **问题是什么？** markdown 多次编辑高频出错（失配重试、吞块、状态混乱、sed/python 静默失配），影响交付效率与正确性，且不限当前项目（用户 R1/R6）。
2. **本质是什么？（5 Whys ≥5 层）** Why1: Edit 依赖精确文本锚点易受上下文漂移/重复片段影响。Why2: 代理在多步编辑中缺少统一事务状态与可观测中间表示。Why3: 失败常在“写后”或“批量替换后”才暴露，缺少写前全量预校验与写后结构断言。Why4: 批量脚本替换未强制命中计数与失败退出，允许静默失配。Why5: 纪律条款存在但无强制执行器与标准化指令协议，跨项目复用与自动拦截能力不足（根因=缺少工具级、可机器校验的编辑事务层）。
3. **解决方案是什么？（候选+取舍）** 候选：①高级工具/成熟 diff-patch 库 ②JSON 中间件(edit-ops)+脚本执行器 ③纯编辑脚本优化 ④新建/引入专用 md 编辑工具。初步取舍：单一手段难同时覆盖表达、校验、原子性与接线；**推荐混合方案（见 P2）**：以 JSON edit-ops 为中间表示+原子执行脚本为核心，吸收成熟库/工具能力并通过技能接线落地（P2 裁决定稿）。
4. **执行方案是什么？（步骤化+门控）** P1 真实调研与盘点→P2 四方向裁决与 schema/流程设计→P3 Bun+TS 工具实现（预校验/原子应用/回读/回滚）→P4 技能与规则触发接线→P5 selftest 与真实 md 冒烟→P6 多环境部署；每 Phase 有 VC/V-N 门控与 S-unit 验收。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？— 是：可交付可复用的 edit-ops 工具链与接线方案，直接服务后续 markdown 编辑任务。
- [x] 核心问题不解决，其他工作都白费吗？— 高概率是：高频编辑错误会持续消耗重试成本并引入隐蔽内容损坏。
- [x] 核心问题的解决方法是清晰的、可执行的？— 计划层面清晰：以 P1 调研证据支撑 P2 裁决，P3-P6 工程化落地并验证。

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| P1/S1 本地资产盘点 | LOCAL-ONLY | markdown-editor, Rule 106, edit tool | 本地 Read/Grep/ls（repo + ~/.zcode/skills） | findings.md 本地资产与差距小节 | 否 |
| P1/S2 高级工具/已有工具调研 | NET-RESEARCH | "markdown structured edit CLI", "atomic markdown patch tool" | WebSearch → WebFetch/GitHub/官方文档 | 候选工具对比表+证据 URL/README 摘要 | 是（选型解难） |
| P1/S3 JSON中间件/事务编辑模式调研 | NET-RESEARCH | "JSON edit operations file transaction", "atomic file apply rollback" | WebSearch → 技术文档/文章/实现参考 | edit-ops schema 与事务模式参考+可借鉴点 | 是 |
| P1/S4 脚本与批量替换可靠性调研 | NET-RESEARCH | "sed python replace silent failure", "idempotent markdown batch edit" | WebSearch → 文档/案例 | 静默失配防护模式与命中计数策略 | 是 |
| P2/S1-S2 方案裁决与设计 | LOCAL-ONLY | R2-R5, 四候选方向, VC-2 | 本地综合 P1 产出 | 裁决表+推荐方案+schema 草案 | 否 |
| P3-P6 实现接线验证部署 | LOCAL-ONLY | md-edit-ops.ts, selftest, SKILL.md, deploy | 本地编码/脚本/文档编辑 | 代码/测试/接线/部署证据 | 否（若遇工具报错转 NET-RESEARCH） |

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 现有 Edit 工具约束、Rule 106/106.1a 文本、全局 `~/.zcode/skills/markdown-editor/SKILL.md`、本仓 task-planner 架构与脚本 | 本地 Read/Grep/ls，提取能力与缺口 | `findings.md#Research Findings` / `knowledge-brief.md#§2` | ☐（计划期已初读，P1 完整化） |
| ② 对标样本（58.2 强制） | 现成 markdown/文本结构化编辑工具、patch/事务编辑实现（≥1 个可指名候选，P1 调研产出） | WebSearch/WebFetch/GitHub README 与用法对比 | `findings.md#Research Findings`（候选对比表+URL） | ☐ |
| ③ 外部约束 | 编辑环境约束（Bun+TS 优先、无交互式 CLI 依赖前提、跨项目部署位 zcode/claude/cursor/agents）、失败模式判例（吞块/静默失配） | 本地规则/宪法/知识库阅读 + 用户原话锚 | `knowledge-brief.md#§4` / `task_plan.md#R1-R6` | ☐ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
Phase 1（计划已定稿，待 D1 确认后进入执行）

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
主进程展示本计划与待审项（四候选方向推荐项、scope 预估），获 D1 确认后派 general-purpose 执行 P1/S1-S4 调研盘点并回填 findings.md。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 general-purpose(sonnet/研究档)、卫星技能 research-assistant/task-planner 参考、MCP/平台工具 WebSearch/WebFetch/Read/Grep | 需外部真实调研+本地盘点并产出证据锚，隔离大输出避免主上下文膨胀 |
| Phase 2 | 主进程 + Agent 子代理 decision-arbiter(备用)、卫星技能 verification-gate/plan-template-kit 参考 | 方案裁决与取舍需对照 VC/约束；多候选难决时升级 arbiter |
| Phase 3 | Agent 子代理 code-assistant(haiku-1/编码档)、机械守卫脚本(后续 selftest)、平台工具 Bash/Read/Edit | Bun+TS 工具实现与单元化修改，按 S-unit 派发 |
| Phase 4 | Agent 子代理 code-assistant(haiku-1)、卫星技能 task-discipline/task-planner 接线参考 | 技能与规则触发点接线属于多文件文档/技能修改，需受控派发 |
| Phase 5 | Agent 子代理 code-runner-agent(mini)、机械守卫脚本 selftest/bash | 回归与冒烟执行、失败用例拦截验证，结果导向 |
| Phase 6 | 主进程（例外①②）+ 机械守卫脚本(deploy/diff) | 多环境部署与终验编排涉及 git/部署位对账，按白名单由主进程协调 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 激活条件（独立并行 ≥3 S-unit 可 fan-out 的主线有限，P1 可局部并行但规模不达长链编排）→ 采用 Rule 21.4 独立性守门调度（并行默认+声明制），P1/S2-S4 可按数据独立性并行。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；/goal 为用户侧 harness 命令，技能层不可代调；若用户已用 /goal 锚定任务，执行范围记录映射。

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 调研与方案选型（真实调研+本地资产盘点）
<!-- 
  WHAT: Understand what needs to be done and gather initial information.
  WHY: Starting without understanding leads to wasted effort. This phase prevents that.
-->
- [x] 盘点本地资产：Edit 约束、Rule 106/106.1a、全局 markdown-editor SKILL.md 能力与缺口
- [x] 真实调研四候选方向（高级工具/JSON中间件/编辑脚本/已有工具）并收集证据
- [x] 输出候选对比矩阵与可复用点，回填 findings.md/knowledge-brief.md
- [x] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **V-N:** VC-1, VC-6（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** complete
- **Executor:** general-purpose（sonnet）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6) 本地资产盘点 | 继承 | `skills/task-discipline/references/critical-rules-discipline.md:722-760`(106/106.1a)；`/home/terry/.zcode/skills/markdown-editor/SKILL.md`(编辑原则/无事务机制)；`task_plan.md` R1-R6(痛点与四方向) | findings.md 新增本地现状与缺口小节，含 file:line 锚点 | 12min | 1f/40l/12min | 无 | - | pending |
| S2 | (A6) 高级/已有工具调研 | 继承 | `task_plan.md` R2/R5；`findings.md` 模板段；关键词“markdown structured edit CLI/atomic patch” | findings.md 记录≥2 个候选工具/仓库，含 URL、能力、与四痛点匹配度 | 15min | 1f/60l/15min | research-assistant | - | pending |
| S3 | (A6) JSON中间件与事务模式调研 | 继承 | `task_plan.md` R3；目标链路“预校验/原子应用/回读/回滚”；Bun+TS 约束 | findings.md 记录 edit-ops/schema/原子写与回滚模式参考及取舍 | 15min | 1f/60l/15min | research-assistant | - | pending |
| S4 | (A6) 编辑脚本与静默失配防护调研 | 继承 | `task_plan.md` R4/R6；痛点④“python/sed 静默失配”；Rule 106.1/106.4 | findings.md 记录命中计数/失败退出/幂等与批量安全实践及证据 | 12min | 1f/50l/12min | research-assistant | - | pending |

### Phase 2: 方案裁决与设计（四方向评估+推荐项）
<!-- 
  WHAT: Decide how you'll approach the problem and what structure you'll use.
  WHY: Good planning prevents rework. Document decisions so you remember why you chose them.
-->
- [x] 建立四候选方向评估矩阵（能力/风险/跨项目复用/实现成本）
- [x] 裁决推荐方案并标注 **(Recommended)**，给出取舍理由与备选
- [x] 输出 edit-ops JSON schema 草案、执行流程（预校验→原子应用→回读→回滚）与接线草案
- [x] 更新 task_plan Decisions/范围收敛、knowledge-brief 设计要点
- **V-N:** VC-1, VC-2（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护与方案裁决编排——Rule 25.3 白名单）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A2) 汇总 P1 证据并形成四方向对比 | 主进程（继承 Phase 例外） | `findings.md` P1 产出；`task_plan.md` R2-R5；证据面清单 | task_plan.md P2 表含四方向逐项评估与证据引用 | 12min | 1f/50l/12min | 无 | S1-S4(P1) | pending |
| S2 | (A2) 裁决推荐项与设计草案定稿 | 主进程（继承；难决升级 decision-arbiter） | S1 对比结果；Goal/VC；Rule 106 约束 | 推荐项标注 `(Recommended)`、schema/流程/接线草案落盘 | 15min | 2f/60l/15min | decision-arbiter(备用) | S1(P2) | pending |

### Phase 3: 工具实现（edit-ops 执行器，Bun+TS）
<!-- 
  WHAT: Actually build/create/write the solution.
  WHY: This is where the work happens. Break into smaller sub-tasks if needed.
-->
- [x] 定义 edit-ops JSON 指令单格式（op/id/target/precondition/expected）
- [x] 实现解析与预校验（锚点存在性、唯一性、命中计数、冲突检测）
- [x] 实现原子应用（全过才写）、备份与回滚
- [x] 实现回读验证与结构断言（段清单/守恒检查）及 apply-report 输出
- [x] 规范召回（Rule 93）：每 3 个 S-unit/Phase 翻转主进程 Read ../task-discipline/references/execution-recall-card.md 并 progress 留 [recall] 行；压缩/恢复后第一动作
- **V-N:** VC-2, VC-4（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A1) 落地 schema 与解析器骨架 | 继承 | P2 设计草案（task_plan/findings）；Bun+TS 约定；目标文件 `skills/task-planner/scripts/md-edit-ops.ts` | 脚本可解析最小 edit-ops JSON 并输出结构化错误码 | 15min | 1f/80l/15min | 无 | S2(P2) | pending |
| S2 | (A1) 实现预校验与冲突检测 | 继承 | S1 产物；四类失败模式对策（存在性/唯一性/命中计数） | 失配/非唯一/0命中等场景返回 FAIL 且不改目标文件 | 15min | 1f/90l/15min | 无 | S1(P3) | pending |
| S3 | (A1) 实现原子应用+备份回滚 | 继承 | S2 产物；“全过才写”要求；临时文件/备份路径策略 | 成功全量应用或失败回滚，目标文件与备份状态可验证 | 15min | 1f/90l/15min | 无 | S2(P3) | pending |
| S4 | (A1) 实现回读验证与 apply-report | 继承 | S3 产物；Rule 106.1a 结构回读要点（段清单守恒） | 输出 report（step状态/matched/changed/hash/断言结果） | 15min | 1f/80l/15min | 无 | S3(P3) | pending |

### Phase 4: 技能与文档接线
<!-- 
  WHAT: Verify everything works and meets requirements.
  WHY: Catching issues early saves time. Document test results in progress.md.
-->
- [x] 新建 `skills/md-edit-ops/SKILL.md`（或按 P2 裁决扩展 markdown-editor）并定义触发/用法/I-O 契约
- [x] 接线 task-planner/task-discipline 相关触发点（引用 edit-ops 流程与 Rule 106 协同）
- [x] 更新必要 references/索引说明，保持与 P2 方案一致
- **V-N:** VC-3, VC-4（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A1) 创建/更新 md-edit-ops 技能定义 | 继承 | P2 裁决；`/home/terry/.zcode/skills/markdown-editor/SKILL.md` 现状；P3 CLI 用法 | SKILL.md 含触发词、edit-ops JSON 流程、示例与约束 | 15min | 1f/90l/15min | 无 | S4(P3) | pending |
| S2 | (A1) 接线 task-planner 侧触发/引用 | 继承 | `skills/task-planner/SKILL.md` 与相关 references；P2 接线草案 | 计划/执行指引中可发现 md-edit-ops 使用点与 Rule 106 协同说明 | 15min | 2f/80l/15min | 无 | S1(P4) | pending |
| S3 | (A1) 接线 task-discipline/markdown-editor 协同 | 继承 | `skills/task-discipline/*` 相关引用点；markdown-editor 扩展策略 | 触发点一致、无冲突表述，避免双轨混乱 | 12min | 2f/60l/12min | 无 | S1(P4) | pending |

### Phase 5: selftest 回归与实弹冒烟
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [x] 编写 `selftest-md-edit-ops.sh` 覆盖成功/失败路径（失配、吞块风险、静默失配、回滚）
- [x] 对真实 markdown 样本执行成功与失败用例冒烟
- [x] 记录测试结果与证据，确认拦截/检测/回滚可观测
- **V-N:** VC-2, VC-5（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** complete
- **Executor:** code-runner-agent（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A7) 实现/完善 selftest 脚本 | 继承 | P3 工具与 apply-report 约定；四类失败模式用例 | `selftest-md-edit-ops.sh` 可执行并覆盖关键失败路径 | 15min | 1f/80l/15min | 无 | S4(P3), S3(P4) | pending |
| S2 | (A7) 运行 selftest 并收集证据 | 继承 | S1 脚本；测试样本路径 | 命令输出显示 PASS/FAIL 断言符合预期，失败被拦截 | 12min | 1f/30l/12min | 无 | S1(P5) | pending |
| S3 | (A7) 真实 md 冒烟与回归记录 | 继承 | 真实 markdown 文件样本；P3 工具 | progress/verification 记录成功与失败用例证据 | 12min | 2f/40l/12min | 无 | S2(P5) | pending |

### Phase 6: 多环境部署与交付收尾
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [ ] 按 repo 机制同步到 zcode/claude/cursor/agents 对应部署位
- [ ] 运行对账/终验命令并记录证据
- [ ] 全文档收尾回读梳理记录（Rule 84.14）：全量回读六文档体系→五维互洽→偏移迭代→收敛出口（连续一轮零新发现）后才出 outcome
- [ ] 归档计划：check-complete exit 0 后先 `bash <skill>/scripts/set-active-plan.sh --clear` 再 `bash <skill>/scripts/archive-plan.sh task-mdedit-reliability-20261116 --root <plans根>`（Rule 81；守卫拒绝时登记理由不强移）
      <!-- task-kb-auto-capture-20261022 增：收尾主动触发——归档与知识提取为收尾默认动作，勿依赖人想起手动跑 -->
- [ ] 知识提取入库（条件式：项目存在 scripts/kb-sync-from-plan.sh 知识库机制则必做；不存在则登记「跳过：无知识库机制」）：`bash scripts/kb-sync-from-plan.sh <plan-dir>` 生成 draft → 精炼改名（去 _draft- 前缀、补行号锚、主题化去重）→ `bash scripts/kb-rebuild-index.sh`；条目规范见 knowledge/README.md（项目级 knowledge-brief.md §7 入库回链段，若有）<!-- 路径基准双轨：归档/模板类命令 <skill>/=技能根；kb-* 脚本实体在仓库根 scripts/（项目相对），勿混统一（2026-10-23 task-kb-cr-lits-20261023 CR MAJOR-1 回退） -->
- **V-N:** VC-3, VC-5, VC-6（本 Phase 验收映射的 VC 编号,≥2 条）
- **Status:** in_progress
- **Executor:** 主进程（例外理由:① git/部署编排 + ② 簿记——Rule 25.3 白名单）

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
<!-- 每轮一行：轮次/发现/处置；连续一轮零新发现才可出 outcome（收敛出口，轮次不设上限）；
     发现面=需求↔目标↔执行↔验证↔知识五维互洽（偏移/遗漏/未利用知识） -->
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1    |                              |                      |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk（实现期预判）`：将修改 skills/scripts 等被多会话使用资产；计划期仅写 plan 目录文档=局部安全 |
| `isolation` | `worktree`（实现类默认首选；P3 开工前创建并登记） / `direct` 仅用于本计划期 5 文件填写（已限定 scope） |
| `worktree_path` | `<project-root>/tmp/worktrees/task-mdedit-reliability-impl`（实现期开工时创建；Rule 100:tmp/ 入 .gitignore） |
| `branch` | `wt/task-mdedit-reliability-impl`（实现期） |
| `merge_back` | `pending` |

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
| Phase 1 | 外部调研结果不可得/证据不足导致 P2 无据裁决 | 6 | 5 | 5 | 150 | 22.3①改派研究子代理补证据→22.3②拆细到单方向调研→22.3⑤ AskUserQuestion 裁决是否接受本地对标替代并登记豁免 |
| Phase 2 | 四方向取舍分歧导致推荐项摇摆/与约束冲突 | 7 | 4 | 5 | 140 | 22.3③降档先出可回退最小方案→升级 decision-arbiter→22.3⑤ 呈报选项请用户裁决（Rule 70 四要素） |
| Phase 3 | 原子应用/回滚实现缺陷造成误改或回滚失败 | 9 | 4 | 6 | 216 | 22.3②拆细到单机制 S-unit→强制备份与 dry-run 模式→22.3④主进程接管关键修复→失败则 22.3⑤ STOP 并回滚到备份 |
| Phase 4 | 技能与规则接线不一致引发双轨行为/触发混乱 | 7 | 5 | 5 | 175 | 22.3①改派专注接线子代理→对照 106/markdown-editor 做一致性检查→22.3⑤ 冲突点上抛裁决 |
| Phase 5 | selftest 覆盖不足导致漏检吞块/静默失配 | 8 | 5 | 6 | 240 | 22.3②补充失败用例 S-unit→用真实 md 复现判例→22.3④主进程复核证据→未覆盖关键场景禁声称完成 |
| Phase 6 | 多环境部署不一致/漏同步 | 7 | 4 | 4 | 112 | 22.3①按 deploy 先例重跑同步→diff -rq 逐位对账→不一致 22.3⑤ STOP 报告并回退 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 计划定稿后建映射（sync-todos 延后：Phase 未定稿前无稳定映射） |
| Phase 2 | ☐ |  | 同上 |
| Phase 3 | ☐ |  | 同上 |
| Phase 4 | ☐ |  | 同上 |
| Phase 5 | ☐ |  | 同上 |
| Phase 6 | ☐ |  | 同上 |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. P2 裁决：在“新建 skills/md-edit-ops”与“扩展全局 markdown-editor”之间，哪种更利于跨项目复用且不破坏现有触发？（默认推荐：新建专用技能+复用约定）
2. edit-ops JSON 的目标定位策略采用何种主锚（heading 路径/行区间/内容 hash/上下文指纹）才能同时降低失配与吞块风险？
3. “原子应用”在多文件/多 op 场景的事务边界如何定义（单文件原子优先，还是支持跨文件批次）？
4. 与 Rule 106/106.1a 的关系：工具级校验是否作为前置门、纪律条款是否保留为兜底与审计要求？
5. 多环境部署的权威源与同步命令以本仓现行机制（smart-merge-back/deploy 脚本）哪一条为准，需在 P1/P6 实证确认？

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
| template_type=general，6 Phase 推进 | 任务跨调研/设计/实现/接线/验证/部署，通用模板可承载；按建议拆解并优化 S-unit |
| 推荐混合方向：JSON edit-ops 指令单 + Bun+TS 原子执行器 + 技能接线（P2 定稿） | 同时回应 R2-R5：可吸收高级/已有工具能力、以 JSON 作为可校验中间件、以脚本落实原子与回滚、以技能/规则接线实现跨项目复用 |
| 计划期仅写 5 个计划文件，不改外部实现 | 满足“计划期单写者”约束，避免范围漂移；实现期另走 worktree 与授权 |
| VC/verification 使用可执行命令 | 满足 Rule 84.1 与用户验收，终验可机械/人工复现 |
| Rule 44.3 超时自动裁决（2026-11-16）：D1 计划展示后无异议自动通过，按已展示计划执行并 attest 锁定 | 五要素：①超时值=默认 5min（实际展示后约 49min goal-loop 续推时点触发）②推荐项=混合方案（JSON edit-ops+Bun+TS 执行器+技能接线，计划已展示）③触发时间=2026-11-16 计划展示后续推轮④裁决理由=/goal 完成性指令「必须纠正」+展示后用户无异议⑤被覆盖的未决选项=P2 遗留项（新建 md-edit-ops 技能 vs 扩展 markdown-editor，默认新建）与 P6 部署授权（计划待审项 2 已声明「批准计划即视为授权」，49min 无异议=授权生效；逐次确认要求未被提出） |
| P2 裁决定稿：选方向② JSON edit-ops 指令单+本地执行器 **(Recommended)**；方向①现成工具（Aider/Codex）仅吸收契约经验不作主干（无原子回滚），方向③被②吸收（执行器即受控脚本），方向④外部 fast-apply 服务拒绝入主干（契约未公开+外部依赖）；技能形态=新建 `skills/md-edit-ops/`（markdown-editor 仅加指针行最小增量） | 评估矩阵+schema v1+七步流水线（load→staleness 门→预校验→模拟应用→回读断言→原子写盘→apply-report）+exit code 2/3/4/5/6 契约见 findings.md「edit-ops 设计定稿（P2/S1-S3）」段；四失败模式全覆盖：预校验→失配/静默失配，原子+回滚→部分提交，回读断言（标题守恒+锚行保活）→吞块，apply-report→状态混乱 |

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
| 2026-11-16 02:50 | drift-checker ALIGNED（P1-P3 窗口；检查点 .drift-checkpoint-p3.md + ledger tick4 + 本行=三件套齐） | VC-1/VC-2/VC-5/VC-6 | 目标↔证据链闭合、四方向逐项有据、四失败模式全覆盖、范围无漂移；继续推进 |

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
| 子代理执行 Phase 数 / 总 Phase 数 |  / 6 |
| 主进程直做 Phase 清单 | Phase 2（例外②计划系统文件维护与方案裁决编排）、Phase 6（例外①② git/部署编排+簿记） |
| 委派率 | 待执行统计（目标 ≥ delegation_rate_floor 默认 0.7；4/6 派发型 Phase） |
| 激活子代理数（Rule 96.5） | 0（计划期） |
| 最大并行宽度（Rule 96.5） | 0 组 / 最宽 0（计划期） |
| 串行化例外理由（Rule 96.4） | none（计划期）；执行期按 S-unit 前置依赖与 68.2 登记 |

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
| 1 | 2026-11-16 | plan-writer | 撰写 task-mdedit-reliability-20261116 计划 5 文件 | done | 完成 task_plan/findings/knowledge-brief/progress/verification 实质填充 | `plans/task-mdedit-reliability-20261116/task_plan.md` 等 | n/a（计划期产出） | n/a | - / 0 / ☑ |
| 2 | | | | | | | | | - / 0 / ☐ |
| 3 | | | | | | | | | - / 0 / ☐ |

## 🔗 Chain 区块交接配置（可选）

<!-- 仅多 skill 接力任务填写（如：调研→创作→发布）。单 skill 任务可删除此整个区块。 -->

### Chain 模式

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
| **current_block** | Block 1 |
| **handoff_on_complete** | ❌ 否 |

### Block 1: 计划与实现链（当前块）

| 字段 | 值 |
|------|-----|
| **goal** | 产出并执行 markdown 编辑可靠性工具化计划（调研→裁决→实现→接线→验证→部署） |
| **depends_on** | none |
| **passes_to** | n/a |
| **status** | in_progress |

### 🔗 Handoff 追踪表

| Block | 状态 | 交接产物路径 | 验证命令 | 实际完成时间 |
|-------|------|------------|---------|-------------|
| Block 1 | in_progress | `plans/task-mdedit-reliability-20261116/*.md` | `grep -n "VC-" plans/task-mdedit-reliability-20261116/task_plan.md` | - |

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP
