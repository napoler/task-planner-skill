# Task Plan: task-modification-compliance-gate-20261119
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

- **R1**: 「核心问题就是 为什么会将一个原本有理有据的 模型能力限制 被恶意的修改了这才是关键 必须解决这个问题 也就是修改是否合规 连合规性都没有就做恶意修改 只会导致投毒 破坏原本可以正确任务被恶意篡改 我的目的以后不会出现这种 合规性都没有就做恶意修改」<sub>（[目标]）</sub>
- **R2**: 「继续」（承上 R1——继续推进「修改合规门」D 类任务，不改诉求）<sub>（[手段]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-4 | 74.7 通用修改合规门条款在位（合规四元组 + 无依据放宽 P0 禁止），覆盖未登记/执行期就地放宽/单边三类缺口；grep 锚全=1 |
| R2 | VC-3, VC-5 | 5 处纯增量条款零回归（selftest 4 脚本 PASS）+ 3 部署位 diff=0 + drift-checker ALIGNED |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/task-modification-compliance-gate-20261119/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/task-modification-compliance-gate-20261119/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 规范修改落地 | 无通用「修改前合规论证+授权」硬门（B1/B4：未登记规范不受管、登记遗漏无检查） | Rule 74.7 合规四元组 + none-justified 登记前置（Phase 3 S1） | VC-1 |
| 执行期改动 | 74.3 仅方案期、执行期就地放宽无回填与运行绑定（B2/B3） | SKILL 2.5d 执行期回填 + dispatch 22.4e 回传 + 106.7 通用放宽判据（Phase 3 S1） | VC-2, VC-4 |
| 消费链验证 | 条款零回归 + 部署生效 + 目标对齐 | selftest 4 脚本 + 3 位 diff + drift-checker（Phase 4/5） | VC-3, VC-5 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | R1 逐字原文（用户需求原文区）；VC-1~VC-5 判据；零新脚本/零 config 键；既有条款纯增量不改判据；他会话 17 staged+unstaged 不覆盖/不 reset；仅改 skill 规则文本（修 A 不修 B：不动 StoryLab/历史产物） | 本文件 R/VC/范围区 |
| 🔀 可变量 | 条款措辞精炼、模板可选同步与否、执行顺序/调度 | - |
| 📈 学得量 | 74.7 落位与四环联动、C2 最小修复面实证 → findings.md | findings.md |

## 🔒 规范基线（Spec-Baseline，Rule 51.15 — 含已确立硬约束时必填）
| spec_id | 约束原文(verbatim) | 来源锚(path:line) | 双向判定式 | 来源 sha256 |
|---------|-------------------|------------------|-----------|------------|
| none-justified | n/a（经扫描本任务计划期：任务为 skill 规则文本修订，无用户/项目/SOP侧已确立的业务硬约束数值需登记；保护区修改约束由 §六/§十一/Rule 74.7 覆盖） | n/a | n/a | n/a |

## Goal
在 task-planner 技能体系中落地**通用修改合规门**（Rule 74.7 及联动条款），使任何对已确立规范/规则/阈值/区间的修改在落地前必须完成「合规四元组」论证与授权，杜绝无依据放宽与投毒式篡改。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯文本条款修订，非代码任务） |
| `session_id` | sess_a6eb132d-08dc-48ed-a4b5-f8e3de5d35a7（本会话；side 指针 a6eb…） |
| `worktree_path` | n/a（已清理，见隔离决策） |
| `scope_files` | [skills/task-discipline/references/critical-rules-discipline.md, skills/task-planner/references/critical-rules.md, skills/task-planner/SKILL.md, skills/task-dispatch/references/critical-rules-dispatch.md] |
| `interaction_mode` | silent（用户指令明确，无需关键决策点询问；所有裁决已登记 Decisions Made） |
| `对齐审查` | drift-checker 三态判定 ALIGNED（P0=无）+ 收尾五维互洽回读；已登记 |
| `自动超时默认项` | 无 2+ 选项询问点（用户诉求明确、可测问题自主决策，Rule 44.2 低区分度）；无超时裁决 |
| `new_rule` | 留空（74.7 是 Rule 74 族内子条，74 已由 task-v162 预留/listed，不新增顶层编号，无需新预留） |
| `质量审查工具` | drift-checker（Rule 61/103 第二道独立复检）+ selftest 4 脚本（机械守卫）；缺口无 |

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
| VC-1 | Rule 74.7 通用修改合规门条款在位（合规四元组+无依据放宽 P0 禁止+三类缺口覆盖） | grep 锚计数 | `grep -c '^74.7 ' skills/task-discipline/references/critical-rules-discipline.md` =1；`grep -c 'MODIFICATION NON-COMPLIANT' 同文件` =1 |
| VC-2 | 4 处联动条款在位（51.15 跨域指针+none-justified / SKILL 2.5d 回填 / dispatch 22.4e 回传 / 106.7 通用放宽判据） | grep 锚计数 | 4 锚各 =1（详见 verification.md VC-2） |
| VC-3 | 5 处纯增量零回归；selftest 4 脚本全 PASS | 运行脚本 | `bash skills/task-planner/scripts/{selftest-absorption-discipline,selftest-requirement-coverage,selftest-dual-qc,selftest-final-gate-hash}.sh` → 0 FAIL（AD 16P/0F/1S、RC 28P、DQ 14P、hash 22P） |
| VC-4 | 覆盖 B1-B4 四类缺口；无范围漂移、无内部矛盾、74.7 不撞号、既有原文未删改、零新脚本/config | 独立 drift-checker + git diff | 检查点 `plans/.../subagent-state/drift-check-modcomp-20261119.md` = ALIGNED(P0=0)；`git diff --numstat` 4 文件纯增量 |
| VC-5 | 3 部署位条款 diff=0；check-complete exit=0；计划归档 | cmp 锚 + 门命令 | 逐锚 `cmp` 三部署位；`bash scripts/check-complete.sh` exit=0 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard/full 必填，mini 豁免）
<!-- task-dualqc-20261104 新增：双轮质检机制在计划阶段显式设计——派发型实质产出 S-unit 默认两道检核（第一轮执行体自审 103.2 checkpoint 自审段；第二轮主代理派全新子代理独立复检 103.3，档位升一档 103.4、复检任务书简洁五要素 103.5）；多文件变更集（≥2 受管文件）Phase 翻转前过 103.6 同步完整性审查（关联面推导四族→同步核对清单全绿）。豁免面=103.7，逐 S-unit 登记理由；mini 档整体豁免。 -->
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | （派发型实质产出 S-unit 清单或「默认全适用」） |
| 豁免登记 | （逐 S-unit+豁免理由；无则写 none） |
| 多文件变更集预判 | （预判触发 103.6 核对清单的 Phase/S-unit；无则写 none） |


## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
<!--
  WHEN: 终验时填写;含 [目标] 标注需求（下方 R 行）的任务必须在交付前出三态裁决
  WHY: Rule 58.5 完成裁决门——「分析报告已交付」不等于「问题解决了」;not-solved/partial 禁止标 COMPLETE
  载体: 58.4 手段/目标二分在需求原文区逐条标注 [手段]/[目标];本区块回收目标型需求的解决状态
-->
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1（[目标]：无依据放宽/投毒根治，以后不出现合规性都没有就修改） |
| **裁决** | `solved`（skill 制度层诉求范围） |
| **解决证据锚** | Rule 74.7 通用修改合规门落地：discipline:494（合规四元组+无依据放宽 P0+三类缺口）、critical-rules.md:109（51.15 none-justified+74.7 跨域指针）、SKILL.md:122（2.5d 执行期回填）、dispatch:66（22.4e 回传）、discipline:757（106.7 通用放宽判据）；merge 79debfa；4 selftest PASS；drift ALIGNED；2 部署位 9 锚到位 |
| **未解决面+原因** | 无（本任务范围=修正 skill 制度层）。范围外：StoryLab 已产出的 3s/15s 违规分镜修复 + 项目层 4-12s 规范下沉属另一仓 `task-storyboard-duration-fix-001`，跨项目需显式授权（§五），本任务未触碰；本机制对新会话生效，历史产物不自动回溯 |
| **已排除路径** | 不适用（solved） |
| **下一步建议** | 如需修复历史违规分镜/下沉 StoryLab 项目层规范，授权后另开跨仓任务；本 skill 层机制已在两部署位生效 |

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
| G1 | 修改合规门 | 已确立规范的修改必须先过合规四元组+授权，杜绝无依据放宽 | grep `^74.7 ` critical-rules-discipline.md =1 + 4 联动锚各=1 + selftest 4 脚本 0 FAIL + drift ALIGNED + 部署位 diff=0 + check-complete exit=0 | S1/Phase 1~5 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | none（纯文本条款任务） | 所有脚本/代码文件 |
| 测试 | none（复用现有 selftest，不新增） | 新增 selftest 脚本 |
| 配置 | none（零新 config 键） | 配置与注册表文件 |
| 文档源仓 | 见下方「范围路径清单」（4 文件，本任务改动已 commit 79debfa） | 其他 skill 文件、模板、StoryLab/其他项目文件 |
| 文档部署位 | 见下方「范围路径清单」（2 运行时位，就地插入） | 部署位其他文件、他会话草稿块 |
| 计划簿记 | 见下方「范围路径清单」（本计划目录，非保护区） | 他会话计划目录 |

> **范围路径清单**（真实路径留痕；本任务源仓改动已于 worktree commit 274bb9e → merge 79debfa 提交，工作树残留的 M 为他会话 stash pop 恢复的 staged 改动，与本任务无关，禁 reset 覆盖）：
> - 源仓（4）：`skills/task-discipline/references/critical-rules-discipline.md`、`skills/task-planner/references/critical-rules.md`、`skills/task-planner/SKILL.md`、`skills/task-dispatch/references/critical-rules-dispatch.md`
> - 部署位：`/home/terry/.zcode/skills` 与 `/home/terry/.agents/skills` 下上述 4 文件对应副本（zcode SKILL 薄壳按设计跳过）
> - 计划簿记：`plans/task-modification-compliance-gate-20261119/`（7 文件 + subagent-state/）

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
| CA-1 | critical-rules-discipline.md:74.6 后 | 新增 | 增量 | 「连合规性都没有就做恶意修改 只会导致投毒」 | forensics C2-1/B1-B4；74.7 空位 grep=0 | 插 Rule 74.7 合规四元组 + 无依据放宽 P0 禁止 |
| CA-2 | critical-rules-discipline.md:106.7 尾 | 更新 | 增量 | 同上 | forensics C2-3 | 段尾追加通用放宽判据（单边/软豁免=无依据放宽） |
| CA-3 | critical-rules.md:51.15 尾 | 更新 | 增量 | 「为什么会将一个原本有理有据的 模型能力限制 被恶意的修改」 | forensics C2-1/C2-4 | 段尾追加 none-justified 登记前置 + 74.7 跨域指针 |
| CA-4 | SKILL.md:2.5d 后 | 新增 | 增量 | 「以后不会出现这种 合规性都没有就做恶意修改」 | forensics C2-2 | 新增执行期改规范必补合规四元组 + 51.15 联动要点 |
| CA-5 | critical-rules-dispatch.md:22.4e 尾 | 更新 | 增量 | 同上 | forensics C2-2 | 段尾追加执行体禁自行改口径、回传主进程 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | 宪法 §六保护区+§十一 worktree+§二文本优先铁律 | /home/terry/.zcode/AGENTS.md | 必读 | ☑ |
| 项目内部文档/知识库 | 一手取证底稿（B1-B5/C1-C3） | forensics/modification-compliance-gap-20261119.md | 必读 | ☑ |
| 项目内部文档/知识库 | 核心规则 51.15 / 纪律 74.x·106.7 / 派发 22.4e | skills/*/references/critical-rules*.md | 必读 | ☑ |
| 项目内部文档/知识库 | 隔离 SOP | /home/terry/.zcode/skills/task-planner/references/worktree-isolation.md | 参考 | ☑ |
| 官方文档 | 无（纯本地规则文本任务，无需外部文档） | n/a | 参考 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 已确立规范（如 4-12s）为何被无依据放宽/篡改？→ 根因=缺覆盖所有已确立规范的通用「修改前合规论证+授权」硬门（已登记 Spec-Baseline 的 51.15 强门无法覆盖未登记/执行期就地放宽/单边口径）；解决后 skill 可在落地前拦截无依据放宽，交付可成立。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（Rule 74.7 通用门 + 四环联动使修改合规可审，交付成立）
- [x] 核心问题不解决，其他工作都白费吗？（合规门缺失时任何规范都可能被静默放宽，先例判例致工作不可用）
- [x] 核心问题的解决方法是清晰的、可执行的？（forensics C2 最小修复面 = 5 处纯增量文本条款，零新脚本）

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| S1（取证） | LOCAL-ONLY | 修改合规门、Spec-Baseline 缺口 | 本地文件（Explore 子代理） | findings.md F1-F7 + forensics 底稿 | 不适用（本地规则文本体系） |
| S1（实现） | LOCAL-ONLY | 74.7 合规四元组、none-justified 登记 | 本地文件 | 4 文件 5 处文本条款 | 不适用 |
| S1（验证） | LOCAL-ONLY | selftest、drift、部署锚 | 本地脚本/子代理 | 4 脚本 PASS + drift 检查点 + 部署 diff | 不适用 |

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 当前 skill 修改合规机制（74.2/74.3/51.15/36.x/§六） | Read 规则原文 + grep 锚 | findings.md F2-F5 / forensics A 节 | ☑ |
| ② 对标样本（58.2 强制） | 已归档 task-spec-baseline-freeze-20261119（已登记基线冻结范式）+ 判例 sess_ba603cf5（4-12s 被放宽 3s/15s 反例） | Read 归档 task_plan/progress + forensics C1 | findings.md F6-F7 / forensics C1/C3 | ☑ |
| ③ 外部约束 | 宪法 §六保护区 + §十一 worktree + §二文本优先铁律 + Rule 31.8 制度层诉求 | Read /home/terry/.zcode/AGENTS.md | findings.md Technical Decisions D1-D5 | ☑ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
Phase 5 complete（交付+归档收尾；check-complete exit=0）

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
交付最终报告（诚实列明自举 skip=1 中性态、zcode 位 SKILL 薄壳按设计跳过、StoryLab 跨项目范围外未动）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore（取证）+ 主进程 Read 复核 | 广域规则体系扫描交给 explore 隔离上下文；结论主进程盘上抽验（§一产出必验证） |
| Phase 2 | 主进程（规划判断） | 反思门 D 类决策 + 计划初始化，主进程编排 |
| Phase 3 | 主进程（worktree 内 4 文件纯增量文本） | 保护区文本条款在隔离 worktree 内主进程精确 Edit（Rule 25.3 白名单②） |
| Phase 4 | 机械守卫脚本（selftest 4）+ Agent drift-checker | 脚本做零回归判定；独立子代理做目标对齐三态（Rule 61/103） |
| Phase 5 | 主进程（部署+簿记+归档） | 幂等 Python 部署脚本 + 主进程 check-complete 终验 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8（无独立并行 ≥3 可 fan-out 的大 S-unit，取证→实现→验证为串行依赖链）→ Rule 21.4 串行调度；唯一并行点=Phase 1 取证（已在归档前完成）。
**/goal 对齐（Rule 40.3）**: 用户本轮未用 /goal 命令；本计划 G1 + VC-1~VC-5 即 session goal 证据源。

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
- [x] Understand user intent（R1 逐字落 findings.md）
- [x] Identify constraints and requirements（B1-B5 缺口 + C2 最小修复面）
- [x] Document findings in findings.md（F1-F7）
- [x] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **V-N:** VC-1, VC-4（本 Phase 验收映射的 VC 编号,≥2 条）
- **R 锚定**：本 Phase 服务 R1/R2（一手取证「修改合规性」机制覆盖度与缺口，判定 D 类新任务）
- **Status:** complete
- **Executor:** explore（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A1) 取证 skill 体系「修改合规性」现有机制覆盖度与 B1-B5 缺口 | explore | forensics 判例底稿 + critical-rules*.md（≤2 路径） | findings.md F1-F7 + forensics 报告落盘 | 15min | 1f/60l/15min | 无 | - | complete |
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
- [x] Define technical approach（D1-D5 决策：D 类新任务/纯文本/74.7 落纪律域/worktree/编号避碰）
- [x] Create project structure if needed（init-session.sh 7 文件 + side 指针绑定）
- [x] Document decisions with rationale（findings.md Technical Decisions）
- **V-N:** VC-1, VC-4（本 Phase 验收映射的 VC 编号,≥2 条）
- **R 锚定**：本 Phase 服务 R1/R2（反思门 D 类判定 + 计划/worktree 隔离决策）
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: Implementation
<!-- 
  WHAT: Actually build/create/write the solution.
  WHY: This is where the work happens. Break into smaller sub-tasks if needed.
-->
- [x] Execute the plan step by step（4 文件 5 处纯增量文本条款）
- [x] Write code to files before executing（无代码；纯文本条款，先 Read 5 锚点原文后 Edit）
- [x] Test incrementally（每处 Edit 后 grep 锚=1）
- [x] 规范召回（Rule 93）：本任务为 skill 文本条款，实施前已 Read 5 处规则原文（Rule 71 无源不写）
- **V-N:** VC-1, VC-2（本 Phase 验收映射的 VC 编号,≥2 条）
- **R 锚定**：本 Phase 服务 R1（74.7 合规门 + 4 联动条款落地，覆盖三类缺口）
- **Status:** complete
- **Executor:** 主进程（白名单②：保护区 skill 文本条款在 worktree 内主进程直做，5 处纯增量；stash→wt→merge→pop 编排亦主进程）

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
| S1 | (A6) worktree 内落 discipline 74.7+106.7 两处条款 | 主进程 | critical-rules-discipline.md（74.6/106.7 锚原文） | 2 锚=1 + 74.7 唯一 | 15min | 2f/6l/15min | 无 | - | complete |
| S2 | (A6) worktree 内落 critical-rules+SKILL+dispatch 三处联动 | 主进程 | critical-rules.md:109 / dispatch:66（≤2 路径/批） | 4 联动锚=1 | 15min | 2f/6l/15min | 无 | S1 | complete |

### Phase 4: Testing & Verification
<!-- 
  WHAT: Verify everything works and meets requirements.
  WHY: Catching issues early saves time. Document test results in progress.md.
-->
- [x] Verify all requirements met（selftest 4 脚本 80 PASS/0 FAIL/1 中性 SKIP + 部署位 9 锚 + 负控制=0）
- [x] Document test results in progress.md（Phase 4 Test Results 表）
- [x] Fix any issues found（部署脚本 2 FAIL=anchor 用 `^` grep 符 → 改纯文本重跑 ok=2）
- **V-N:** VC-2, VC-3, VC-5（本 Phase 验收映射的 VC 编号,≥2 条）
- **R 锚定**：本 Phase 服务 R2（零回归 + 部署生效 + 独立 drift ALIGNED）
- **Status:** complete
- **Executor:** 主进程（白名单②：验证命令 selftest/部署锚主进程实跑；独立偏移检查派 drift-checker 子代理，见 Handoff）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6) 独立目标对齐三态判定（drift-checker） | drift-checker | 计划三文件 + forensics 底稿（≤2 路径） | 检查点 ALIGNED(P0=无) | 15min | 1f/40l/15min | 无 | - | complete |

### Phase 5: Delivery
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [x] Review all output files（findings/progress/verification/task_plan/user-session-log 五维互洽）
- [x] Ensure deliverables are complete（74.7+4 联动条款 merge 79debfa；2 部署位 diff=0；drift ALIGNED）
- [x] Deliver to user（本轮终报）
- [x] 全文档收尾回读梳理记录（Rule 84.14）：见下方收尾回读表（连续一轮零新发现收敛）
- [x] 归档计划：check-complete exit 0 后 clear 本会话 side 指针（--sid a6eb…）+ archive-plan.sh（Rule 81）；守卫拒绝时登记理由不强移
- [x] 知识提取入库（条件式）：kb-sync-from-plan 生成 draft → 精炼入库 → kb-rebuild-index；若判定与已归档 spec-baseline-freeze 条目同主题则并入该条目或登记新增独立条目
- **V-N:** VC-3, VC-5（本 Phase 验收映射的 VC 编号,≥2 条）
- **R 锚定**：本 Phase 服务 R1/R2（交付收尾，确认修改合规门生效且无范围外污染）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
<!-- 每轮一行：轮次/发现/处置；连续一轮零新发现才可出 outcome（收敛出口，轮次不设上限）；
     发现面=需求↔目标↔执行↔验证↔知识五维互洽（偏移/遗漏/未利用知识） -->
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1    | R1/R2 逐字原文未在 task_plan 需求区（drift-checker P2）、user-session-log 无 #1 | task_plan 需求区补 R1/R2 逐字 + user-session-log 补 #1；findings F1-F7 对齐；证据=本文件与专档实写 |
| 2    | 部署脚本 2 FAIL（anchor=`^74.7 `用 grep 行首符）+ zcode 位 SKILL 薄壳 | 改 anchor 为纯文本重跑 ok=2/fail=0；zcode 位 SKILL 薄壳按设计跳过（指向 canonical）；证据=部署位 9 锚计数 |
| 3    | 连续一轮零新发现 → 收敛 | R↔Goal↔VC↔执行↔验证五维互洽，无新偏移 |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号① 保护区 skills/ 修改 + ③ 他会话 17 staged 同批文件） |
| `isolation` | `worktree`（实现类默认首选） |
| `worktree_path` | n/a（已清理；合并回后移除，Rule 100 tmp/ 入 gitignore） |
| `branch` | n/a（wt 分支已删） |
| `merge_back` | `merged(79debfa)`（commit 274bb9e → merge 79debfa；stash pop --index 17 staged 完整恢复，无冲突） |

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
| Phase 3 | 他会话 17 staged 与我方条款在同一批文件，pop 冲突 | 8 | 4 | 3 | 96 | RPN≤100：stash 前查 hunk 位置全错开；pop 冲突走并集解（保留双方） |
| Phase 5 | 部署位幂等插入失败/恒真假门 | 7 | 4 | 4 | 112 | 备份 7 文件 + 幂等脚本新锚 assert + 负控制=0 证非恒真；FAIL 改 anchor 重跑 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-11-19 | Todo #1/#2 completed（取证+盘上抽验） |
| Phase 2 | ☑ | 2026-11-19 | Todo #3/#4 completed（D 类决策+worktree） |
| Phase 3 | ☑ | 2026-11-19 | Todo #5 completed（条款实现） |
| Phase 4 | ☑ | 2026-11-19 | Todo #6 in_progress→（验证已完成） |
| Phase 5 | ☑ | 2026-11-19 | 终态同步 |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. 用户诉求是「制度层」（修 skill 防复发）还是「现场层」（修具体 3s/15s 分镜）？→ 制度层（Rule 31.8），交付物=规则文本条款，StoryLab 现场修复属跨项目范围外，不动。
2. 已归档 spec-baseline-freeze 能否扩展？→ 不能（已归档），反思门判 D 类新任务。
3. 74.7 落哪个域？→ 纪律域（执行期行为铁律），核心域 51.15 加跨域指针，避免规则孤岛。
4. 部署位 zcode SKILL.md 是薄壳怎么办？→ 按设计跳过 SKILL 条款（它指向 canonical source），仅 agents 完整位插 5 处。

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
| D1 D 类新任务（独立计划，不并入已归档 spec-baseline-freeze） | 诉求层级=制度层（Rule 31.8）；旧计划已归档无法扩展；目标不同（通用合规门 vs 已登记基线冻结） |
| D2 纯文本条款零新脚本/config | 宪法 §二文本优先铁律；C2 最小修复面；复用 74.3/20.1/51.15 四环 |
| D3 Rule 74.7 落纪律域，核心域 51.15 加指针 | 分层：纪律管执行期铁律、核心管基线定义；避免规则孤岛 |
| D4 worktree 从 master（非 main） | 宪法 §十一；main 为无关陈旧历史；stash→wt→merge→pop 已验证 SOP |
| D5 74.7 编号避碰（grep=0）；不改既有编号 | 避免撞号/改判据（判据冻结协议） |
| D6 部署位 zcode SKILL 薄壳跳过 | 薄壳指向 canonical source，实际运行加载源仓完整版，插入反破坏薄壳结构 |

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
| 部署脚本 2 FAIL（anchor 含 grep `^`） | 1 | 改 anchor 为纯文本 `74.7 **通用修改合规门` 重跑 ok=2/fail=0 | 脚本 assert 的字符串锚不可用 grep 正则符；→ progress.md Error Log |

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
| 2026-11-19 | drift-checker 独立三态判定 | VC-1, VC-2, VC-4 | ALIGNED（P0=无，P1=无）；检查点 subagent-state/drift-check-modcomp-20261119.md（主进程 Read 复核确认落盘） |

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
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 5（Phase 1 explore 取证、Phase 4 drift-checker 复检） |
| 主进程直做 Phase 清单 | Phase 2（白名单②计划系统）、Phase 3（白名单②保护区文本条款 worktree 内直做）、Phase 5（白名单①git 编排+②簿记） |
| 委派率 | 0.400（< floor 0.7，但 3 个主进程 Phase 全为 Rule 25.3 白名单②/①豁免；同构判例 task-spec-baseline-freeze 0.200 经 check-delegation 放行） |
| 激活子代理数（Rule 96.5） | 2（explore ×1 + drift-checker ×1） |
| 最大并行宽度（Rule 96.5） | 1 组 / 最宽 1（取证→实现→验证串行依赖链） |
| 串行化例外理由（Rule 96.4） | Phase 2/3/5 白名单②/①（计划编排/保护区编辑/git），非可并行 S-unit；Phase 1 取证已在归档前单独完成，无并行 fan-out 需求 |

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
| 1 | 2026-11-19 | explore | 取证 skill 修改合规机制覆盖度与 B1-B5 缺口 | done | forensics 报告落盘，缺口+根因+C2 修复面；主进程盘上抽验锚吻合 | forensics/modification-compliance-gap-20261119.md | findings.md F1-F7 | forensics/ 下报告 | - / 0 / ☑（主进程 Read 复核） |
| 2 | 2026-11-19 | drift-checker | 独立目标对齐三态判定 | done | ALIGNED(P0=无/P1=无)，覆盖 C2 修复面，无漂移/撞号/删改/新脚本 | subagent-state/drift-check-modcomp-20261119.md:9-11 | findings.md Research Findings | subagent-state/drift-check-modcomp-20261119.md | - / 0 / ☑（主进程 Read 检查点复核） |

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
