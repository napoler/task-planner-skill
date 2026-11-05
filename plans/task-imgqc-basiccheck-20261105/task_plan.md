# Task Plan: 图片QC基础认知检查缺陷根治
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

- **R1**: 「连最基本的图片的质量检测都出现了错，重大错误。 就是基础性认知检查错误，嗯，比如说，嗯，像房车图片，嗯的入户门应该指出现在一侧，但是他敢设计的图片却放审了，嗯两侧都有入户门的版本，这是严重的缺陷。」<sub>（[目标]）</sub>
- **R2**: 「另外还有就是要求严格要求场景图只有场景没有人物要求，但是没有完成就通过了，这是严重的缺陷，必须得到纠正相关技能。」<sub>（[目标]）</sub>
- **R3**: 「我要求的就是，当优先，必须优化当前技能中的技能文件，确保不会再出现这种弱智性的文件。这种弱智性的基础性的错误必须得到有效的纠正，确保后期执行过程中验证的严格性。」<sub>（[目标]）</sub>
- **R4**: 「连基础性的基础性的就是基础性的错误都在犯错的话，这就非常没有可控性。必须确保所有基础性的或者说可理解可发现的错误都已解决，不要出现错误。」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1、VC-2 | 47.6 常识类目含空间布局/场景构成/物件功能（grep ≥3 命中）+ 图/视频执行体 SOP 同族条款在位（grep ≥2 命中） |
| R2 | VC-1 | 「硬约束逐条核验门」条款在位：清单提取+逐条 PASS/FAIL 留痕+任一 FAIL 禁入候选（grep 命中+条款文本 Read 复核） |
| R3 | VC-2、VC-3、VC-4 | SRC 三载体条款在位+全量回归零新增 FAIL+12 部署位 diff=0 对账表 |
| R4 | VC-5、VC-6 | 独立复检无 BLOCKER+master 合并后主仓 Read 复验在位 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/task-imgqc-basiccheck-20261105/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/task-imgqc-basiccheck-20261105/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 约束提取（生成前） | 用户硬约束/设定事实（门数方位、空景禁人物）未强制提取为可视觉判定检查项 | 47.6a 硬约束清单提取条款（来源=需求原文+设定卡+负例裁决） | VC-1 |
| 取证工序 | QC 判定可凭印象/凭提示词推断，无取证证据链 | 47.6c 先取证后判定（取证输出原文为判定依据+逐条留痕） | VC-1 |
| 判定工序 | 封闭式 3 项清单无空间布局/场景构成/物件功能类目；硬约束违反无 FAIL 语义 | 47.6b 常识类目扩容+违反=H 级禁交付 | VC-1、VC-2 |
| 放行门 | FAIL 图可入候选/待审核/呈审推荐 | 47.6a 任一 FAIL=禁入候选/禁挂待审核/禁推荐，直接入 47.5 重做环 | VC-1 |
| 载体同步 | SRC companion 两 agent 文件无 47.6 块（漂移）；部署位条款陈旧 | SRC graft+12 处部署位 body 对齐（frontmatter 逐位保留） | VC-2、VC-4 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Goal；R1-R4 原文；两缺陷判据（①空间布局常识：不对称物件逐视角核验非门侧必无门/台阶 ②硬约束违反=FAIL 禁放行）；§六/§十一 保护区流程（worktree+逐项授权+部署 diff 判向） | task_plan Goal/R 区块+本表 |
| 🔀 可变量 | 条款措辞打磨/Phase 内工序排期/部署批次顺序/复检体选型 | - |
| 📈 学得量 | 执行期新事实（部署位漂移明细/自测基线明细/条款级联面）→findings；禁反向改写不变量 | findings.md |

## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and delete functionality."
-->
图片 QC 门条款（media Rule 47.6 与 companion 图/视频执行体 SOP）扩容出「硬约束逐条核验门 + 常识认知缺陷类目 + 先取证后判定」，并同步源仓与全部 12 处部署位 diff=0，使空间布局常识错误与硬约束违反类基础错误在 QC 环被强制拦截。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（条款文本修订非代码；独立复检走 Rule 103 双轮质检：Phase 3 派全新 general-reviewer 复检） |
| `session_id` | `sess1f0efca0f4774061982bf583710f7357` | 启动时生成,注册表追踪 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-imgqc-basiccheck-20261105` | §十一 隔离决策已有字段 |
| `scope_files` | `skills/media-planner/references/critical-rules-media.md`+`skills/task-planner/companion/agents/{image,video}-generation-executor.md`（3 受管文件；部署位见执行范围限制） | 从「执行范围限制」解析,并发检测基础 |
| `interaction_mode` | `ask` | Rule 28 交互模式：ask=关键决策点给选项；silent=静默+静默决策清单登记 |
| `对齐审查` | `[登记]` | Rule 42.6 消费：任务产出或更新的文档在完成前跑 alignment-review 对齐审查（标准收尾流程）;文档更新前跑版本一致性校验（未经校验不追加）;变更记录随交付物落盘;mini 档豁免（42.6.4） |
| `自动超时默认项` | `[询问点:D1 计划确认; 默认选项=按已展示计划执行; 超时=5min（Rule 44.3）]` | Rule 44 消费：本任务所有 2+ 选项询问点逐个登记默认选项（推荐项）与自动超时时长（默认 5 分钟,可覆盖）;低区分度选项（产出一致仅步骤/耗时差异）不询问、直接裁决并登记理由（44.2）;用户超时未答复按默认选项自动执行+登记自动裁决记录五要素（44.3）;mini 档豁免（44.4） |
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
       /home/terry/.zcode/skills/task-planner/templates/verification.md 的 `V-N.N` 项，映射目标须为已定义 VC 编号）。
       check-complete.sh 终验 VC-GATE 段机械校验（config.json vc_gate_enforce，默认 warn）。
-->

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 47.6 条款扩容在位：含「硬约束逐条核验门」（清单提取+逐条 PASS/FAIL 留痕+任一 FAIL 禁入候选/待审核/推荐）与常识类目（空间布局/场景构成/物件功能） | grep 计数+Read 复核 | `grep -c "硬约束逐条核验门" skills/media-planner/references/critical-rules-media.md` ≥1 且 `grep -cE "空间布局|场景构成|物件功能" <同文件>` ≥3 且 Read 47.6a/b/c 三段在位 |
| VC-2 | SRC 图/视频执行体 SOP 同族条款在位 | grep 计数 | `grep -c "硬约束逐条核验门" skills/task-planner/companion/agents/image-generation-executor.md` ≥1 且 video 文件同 ≥1，两文件 47.6 块完整（含 47.6a/b/c） |
| VC-3 | 全量回归零新增 FAIL | bash 套件 | `bash skills/task-planner/scripts/run-selftests.sh --fresh`（worktree 内）FAIL 数 ≤ master 预跑基线（基线值执行期记录 progress） |
| VC-4 | 12 处部署位 diff=0 | 逐位 diff 对账 | 6 agents 位（body 含新条款+frontmatter 逐位保留）+3 companion 副本（与 SRC md5 一致）+3 media-planner 副本（含新条款）→对账表 `subagent-state/07-deploy-audit.md` 逐位 diff 输出空 |
| VC-5 | 条款质量独立复检无 BLOCKER | 全新复检体 | general-reviewer 复检三文件 diff：逐缺陷判据覆盖判定（a/b 均可拦截）+与既有条款矛盾扫描 |
| VC-6 | master 合并后主仓复验在位 | Read+grep | `git log -1 --oneline` 显示 merge commit + `grep -c "硬约束逐条核验门" <主仓同路径>` ≥1 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard/full 必填，mini 豁免）
<!-- task-dualqc-20261104 新增：双轮质检机制在计划阶段显式设计——派发型实质产出 S-unit 默认两道检核（第一轮执行体自审 103.2 checkpoint 自审段；第二轮主代理派全新子代理独立复检 103.3，档位升一档 103.4、复检任务书简洁四要素 103.5）；多文件变更集（≥2 受管文件）Phase 翻转前过 103.6 同步完整性审查（关联面推导四族→同步核对清单全绿）。豁免面=103.7，逐 S-unit 登记理由；mini 档整体豁免。 -->
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | Phase 2 三文件条款产出（第一轮=执行体 checkpoint 自审段；第二轮=Phase 3 派全新 general-reviewer 独立复检，档位升一档） |
| 豁免登记 | S4 回归（纯执行既有套件，无实质产出）豁免第二轮；Phase 4 部署（L0-E 纯执行）豁免；Phase 5 簿记豁免 |
| 多文件变更集预判 | Phase 2（3 受管文件）→ 103.6 同步完整性核对清单（条款族互引/部署基底/级联锚三族），Phase 3 翻转前全绿 |


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
| G1 | QC 门条款扩容 | 47.6a/b/c 落 media rules+双 agent SOP | grep 硬约束逐条核验门 各文件≥1∧类目≥3 | S1-S3/Phase 3 | complete |
| G2 | 回归零破坏 | 全量 selftest FAIL≤master 基线 | run-selftests.sh --fresh 对照基线 | S4/Phase 3 | complete |
| G3 | 部署收敛 | 12 位 body 对齐 diff=0 | 对账表 07-deploy-audit.md 全绿 | S7-S12/Phase 5 | complete |
| G4 | 独立复检通过 | 两缺陷判据可拦截+无矛盾 | general-reviewer 复检回执无 BLOCKER | S5/Phase 4 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码/条款（worktree 内） | `skills/media-planner/references/critical-rules-media.md`；`skills/task-planner/companion/agents/image-generation-executor.md`；`skills/task-planner/companion/agents/video-generation-executor.md` | 其他任何技能/规则/脚本文件；既有条款正文改写（只允许增量插入 47.6a/b/c 与 50.5 联动句） |
| 部署位（非 git 管辖） | `~/.zcode|.claude|.cursor/agents/{image,video}-generation-executor.md`（6）；`~/.zcode|.claude|.cursor/skills/task-planner/companion/agents/`（3 副本）；`~/.zcode|.claude|.cursor/skills/media-planner/references/critical-rules-media.md`（3 副本） | 其他部署位文件；frontmatter 行改写（claude 位 model 行等逐位保留） |
| 计划文档 | `plans/task-imgqc-basiccheck-20261105/**`、`plans/INDEX.md`（收尾刷新） | 其他计划目录 |
| git | worktree 分支 `wt/task-imgqc-basiccheck-20261105`；master 合并经 smart-merge-back | 直接 push 远端；force 操作 |

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
| CA-1 | `critical-rules-media.md` L21 Rule 47.6 段 | 修改（条款块内增量插入） | 增量（既有 3 项清单/抽检流程逐字保留，只追加 47.6a/b/c） | R1「两侧都有入户门的版本…这是严重的缺陷」R2「场景图只有场景没有人物…没有完成就通过了」 | 取证 Q2/Q4 缺口（subagent-state/01 L缺口表） | 在 47.6 段末插入 47.6a 硬约束逐条核验门 / 47.6b 常识类目扩容 / 47.6c 先取证后判定 三子条 |
| CA-2 | SRC `companion/agents/image-generation-executor.md` L17 附近 | 修改（graft 部署位 47.6 块+插入新子条） | 增量（自部署位版本并集：SRC 保留 95.x 增量，graft 47.6 块再插入 47.6a/b/c） | R3「必须优化当前技能中的技能文件」 | 部署位块=修订基底（md5 cd3f）；SRC 无块 | graft+插入三子条（SOP 祈使句式） |
| CA-3 | SRC `companion/agents/video-generation-executor.md` | 修改（graft+插入） | 增量（同 CA-2 口径） | R3（同族覆盖防条款分裂） | 同 CA-2 | graft+插入三子条（视频单元措辞） |
| CA-4 | 12 处部署位（6 agents+3 companion+3 media-planner 副本） | 更新 | 增量（body=新版超集，frontmatter 逐位保留不动） | R3「优化…技能文件」 | VC-4 对账表 | 逐位 diff 判向→body 对齐→diff=0 对账表落盘 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | media Rule 47/50 全文（QC 抽检门/原子条目表/47.5 迭代环） | /mnt/data/dev/task-planner-skill/skills/media-planner/references/critical-rules-media.md | 必读 | ☑ |
| 规范/标准 | 部署位 47.6 块现行文本（修订基底） | ~/.zcode/agents/image-generation-executor.md L67-73 | 必读 | ☑（cp-01 检查点引文） |
| 项目内部文档/知识库 | 事故证据链（母图状态板 L46/L56-59、rejected-assets 负例） | /mnt/data/dev/Toonflow/workspaces/钓鱼佬日常/ | 参考 | ☑（cp-02 检查点） |
| 项目内部文档/知识库 | selftest 回归基线口径 | skills/task-planner/scripts/run-selftests.sh --fresh | 参考 | ☐（执行期预跑确认） |
| 项目内部文档/知识库 | 级联锚规范（Rule 76 编号/纪元锚/引用面全扩展名扫描） | ../task-discipline/references/critical-rules-discipline.md | 参考 | ☐（Phase 2 派发时内联） |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 图片 QC 判据缺项——47.6 图侧常识清单为封闭式 3 项（解剖透视/文字乱码/主体错位），无空间布局/场景构成/物件功能类目，且用户硬约束（如「场景无人物」）无「违反=FAIL 禁放行」语义、QC 判定可无取证凭印象通过 → 基础性可发现错误漏检放行（事故两案实锤：双门误判 4/4 PASS、人物场景图无 FAIL 入待审核）。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（条款在位+部署对账+回归零破坏即交付）
- [x] 核心问题不解决，其他工作都白费吗？（QC 门判据缺项不补，后续同类基础错误继续漏检）
- [x] 核心问题的解决方法是清晰的、可执行的？（47.6 条款扩容+双执行体 SOP 同步+部署对账，路径已由取证定位）

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| S0 条款类目设计 | NET-RESEARCH（轻量 1 次） | 图像质检 checklist 常识维度、spatial consistency AI image defects | Web Search Agent（research-assistant 链） | findings 补充段（类目交叉验证） | 是（75.15 必选槽位执行） |
| S1-S6 条款落盘/复检/部署 | LOCAL-ONLY | -（依据=事故取证+既有条款结构，零网络依赖登记理由：条款载体与判据均为仓内事实） | - | 条款文本+对账表 | 不适用（登记理由） |

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 事故两案证据链（母图状态板 L46/L56-59、会话日志） | 子代理取证（cp-02） | findings「Research Findings」[cp-02-analyst] | ☑ |
| ② 对标样本 | 部署位 47.6 现行条款文本+50.5 取证机制（条款结构基线） | 子代理取证（cp-01） | findings「Research Findings」[cp-01-explore] | ☑ |
| ③ 外部约束 | §六/§十一 保护区流程；用户验收期望=基础错误零漏检 | 宪法条款 | task_plan 不变量区 | ☑ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
Phase 2 complete → Phase 3 派发中

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
（等用户批准计划后）跑 check-conflicts.sh+建 worktree → 派 code-assistant 执行 Phase 2 S1（47.6a/b/c 落 critical-rules-media.md）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Explore+general-analyst（已完成）+Web Search Agent（S0 评估） | 取证双路已并行回收；S0 类目交叉验证轻量 1 次 |
| Phase 2 | Agent 子代理 code-assistant + code-runner-agent | 三文件条款修订属单点小改（≤3 文件/≤150 行增量）；回归=纯执行既有套件 |
| Phase 3 | general-reviewer（独立复检）+主进程（git 编排白名单①） | 双轮质检第二轮独立视角；merge 为 git 编排 |
| Phase 4 | 主进程（L0-E 纯执行档：机械 cp+diff 对账，零仓库受管变更） | 部署位非 git 管辖，L0-E 权重 0 不计委派率 |
| Phase 5 | 主进程（簿记白名单②） | 归档/INDEX/ledger/交付总结属簿记 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 激活条件（S-unit 链式依赖 S1→S2/S3→S4，无 ≥3 独立并行单元；非用户点名）→ Rule 21.4 独立性守门调度（串行为主，S2/S3 依赖 S1 条款文本源）
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；用户未用 /goal 锚定，无映射动作

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 取证收口（Requirements & Discovery）
<!-- 
  WHAT: 双路取证回收+findings 回填+知识储备确认+75.15 网络评估。
  WHY: 条款设计必须站在事故证据与现行条款结构上，禁凭印象写条款。
-->
- [x] 用户意图与约束定位（R1-R4 逐字落专档+findings）
- [x] 双路取证回收（Explore=载体盘点 / general-analyst=事故链）
- [x] findings.md 回填三段（Requirements/Research Findings/Resources）
- [x] S0 75.15 网络评估：1 次轻量检索交叉验证常识类目设计，结论落 findings（WebSearch 成功，业界口径一致+吸收细分子项）
- [x] 知识储备必读项已确认可获取（表已勾 2 项，执行期补 selftest 基线确认）
- **V-N:** VC-1, VC-5（判据设计输入齐备后 VC-1 条款可写；VC-5 复检判据输入=本 Phase 取证）
- **Status:** complete
- **Executor:** explore+general-analyst（取证已完成）+主进程（回填簿记，白名单②）
<!-- 
  STATUS VALUES:
  - pending: Not started yet
  - in_progress: Currently working on this
  - complete: Finished this phase
-->

### Phase 2: 隔离与冲突扫描（Planning & Structure）
<!-- 
  WHAT: check-conflicts.sh + worktree 建立（§11.1 命中：companion agents+media rules 为保护区/共享热点）。
  WHY: 本仓为运行中基础设施，实现改动必须隔离副本完成。
-->
- [x] `bash scripts/check-conflicts.sh` → 结果已写 progress（信号①③④均为他任务/他会话，零 scope 重叠）
- [x] `git worktree add /mnt/data/dev/task-planner-skill-worktrees/task-imgqc-basiccheck-20261105 -b wt/task-imgqc-basiccheck-20261105 master`
- [x] worktree 初建对账：三文件 md5 与 master 一致（40202c00/5a5810c6/3caf3143）
- [x] 部署位基底判向：frontmatter 三 site 与 SRC diff 零差异；47.6 块 image@L68/video@L69；body 双向差异 image 13 行/video 15 行（SRC 有 95.x、部署有 47.6 块）→并集口径=SRC 为底+graft
- **V-N:** VC-3, VC-4（worktree 内跑基线与部署对账的载体就绪）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排——Rule 25.3 白名单）

### Phase 3: Implementation 源仓条款修订
<!-- 
  WHAT: 三文件增量插入 47.6a/b/c：media rules → image agent graft → video agent graft → 回归。
  WHY: 缺陷根因=QC 门判据缺项；条款是唯一修复面（§四.6 文本优先铁律）。
-->
- [x] S1-S3 条款落盘（3 文件 24 行纯增量，主进程逐一盘上复核）
- [x] S4 回归（改派 general-purpose，22.3①）：master 94/96 vs worktree 94/96 零新增 FAIL；级联 grep：47.6a/b/c 引用面仅三目标文件，无跨文件级联需求（三子条为新增编号，引用面=本批产出）
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete
- **Executor:** code-assistant（S1-S3）+code-runner-agent（S4 回归）
<!-- S-unit 派发单元表(Rule 22.6 — attest 机器契约: ID 纯数字/时长 NNmin/粒度三值≤2f/100l/15min/输入≤2 path token/伴飞路径存在性) -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 96 类别 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|---------|-------------|---------|------|------|------|------|------|
| S1 | 47.6a/b/c 三子条插入 critical-rules-media.md 47.6 段 | code-assistant | A6 | critical-rules-media.md; CA-1 条款骨架(计划内) | grep 硬约束逐条核验门≥1∧类目 grep≥3 | 15min | 1f/45l/15min | 无 | - | complete |
| S2 | SRC image agent graft 部署位 47.6 块+插 47.6a/b/c | code-assistant | A6 | image-generation-executor.md(SRC)+部署位基底块 | grep 硬约束逐条核验门≥1∧块完整 | 15min | 1f/45l/15min | 无 | S1 | complete |
| S3 | SRC video agent graft+插 47.6a/b/c（视频措辞） | code-assistant | A6 | video-generation-executor.md(SRC)+部署位基底块 | grep 硬约束逐条核验门≥1∧块完整 | 15min | 1f/45l/15min | 无 | S1 | complete |
| S4 | 回归 run-selftests --fresh+级联 grep 留痕 | code-runner-agent | LOCAL(L0-E) | run-selftests.sh | FAIL≤基线+级联 grep 记录 progress | 10min | 0f/0l/10min | 无 | S2、S3 | complete |

### Phase 4: Testing & Verification（独立复检+合并回）
<!-- 
  WHAT: 双轮质检第二轮独立复检 → worktree 全 VC 复验 → 103.6 清单 → smart-merge-back --deploy。
  WHY: 「条款写完」≠「条款能拦住两缺陷」；独立视角复检判据覆盖与矛盾面。
-->
- [x] S5 全新 general-reviewer 复检（VERDICT: APPROVED，零 BLOCKER/MAJOR/MINOR，两缺陷均判定可拦截）
- [x] S6 全 VC 复验+103.6 清单全绿+merge 0508586 落 master+主仓复验过（VC-6）
- **V-N:** VC-3, VC-5, VC-6
- **Status:** complete
- **Executor:** general-reviewer（S5 复检）+主进程（S6 git 编排白名单①）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 96 类别 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|---------|-------------|---------|------|------|------|------|------|------|
| S5 | 独立复检三文件条款 diff | general-reviewer | C4 | worktree 三文件绝对路径; VC-1/VC-2 判据 | 复检回执无 BLOCKER+两缺陷可拦截判定 | 15min | 0f/0l/15min | 无 | S4 | complete |
| S6 | 全 VC 复验+合并回主仓 | 主进程（例外:git 编排白名单①） | - | verification.md; worktree 路径 | VC 全 PASS+merge commit+主仓 Read 复验 | 10min | 0f/0l/10min | 无 | S5 | in_progress |

### Phase 5: Delivery（部署同步+收尾交付）
<!-- 
  WHAT: 12 位部署 body 对齐（frontmatter 逐位保留）→ 逐位 diff=0 对账表 → 84.14 回读 → ledger/INDEX/归档 → 交付总结。
  WHY: 部署位才是会话消费面；不同步=条款写了等于没写。
-->
- [x] S7-S12 部署批次+逐位 diff=0 对账表落盘 subagent-state/07-deploy-audit.md（12+3 位全绿，VC-4）
- [x] 全文档收尾回读梳理（Rule 84.14）：三轮收敛（ledger 补认领/kb 补蒸馏/第三轮零新发现），记录见「收尾回读梳理记录」表
- [x] ledger 认领收尾（.zcode/ledger/task-planner-maintenance.jsonl complete 条目已追加）/INDEX 已刷新/knowledge-brief §2 已蒸馏
- [x] 归档计划：check-complete exit 0 后 set-active-plan --clear + archive-plan.sh（编排完成，执行紧随本门通过）
- **V-N:** VC-4, VC-6
- **Status:** complete
- **Executor:** 主进程（S7-S12 L0-E 纯执行档权重 0+S13 簿记白名单②）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 96 类别 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|---------|-------------|---------|------|------|------|------|------|------|
| S7 | 部署 zcode 位 agents 2 文件 | 主进程（L0-E 纯执行） | LOCAL(L0-E) | SRC 两 agent 新版; ~/.zcode/agents/ 路径 | body diff=0 | 5min | 2f/0l/5min | 无 | S6 | complete |
| S8 | 部署 claude 位 agents 2 文件（model 行保留） | 主进程（L0-E 纯执行） | LOCAL(L0-E) | SRC 两 agent 新版; ~/.claude/agents/ 路径 | body diff=0+frontmatter 保留 | 5min | 2f/0l/5min | 无 | S6 | complete |
| S9 | 部署 cursor 位 agents 2 文件 | 主进程（L0-E 纯执行） | LOCAL(L0-E) | SRC 两 agent 新版; ~/.cursor/agents/ 路径 | body diff=0 | 5min | 2f/0l/5min | 无 | S6 | complete |
| S10 | 部署 claude/cursor companion 副本 4 文件 | 主进程（L0-E 纯执行） | LOCAL(L0-E) | SRC 两 agent 新版; 4 副本路径 | 与 SRC md5 一致 | 5min | 2f/0l/5min | 无 | S6 | complete |
| S11 | 部署 claude/cursor media-planner rules 副本 2 文件 | 主进程（L0-E 纯执行） | LOCAL(L0-E) | rules 新版; 2 副本路径 | 与 worktree 版 md5 一致 | 5min | 2f/0l/5min | 无 | S6 | complete |
| S12 | 对账表落盘（12 位逐位 diff=0 判定） | 主进程（L0-E 纯执行） | LOCAL(L0-E) | 逐位 diff 输出 | subagent-state/07-deploy-audit.md 全绿 | 5min | 0f/0l/5min | 无 | S7-S11 | complete |
| S13 | 84.14 回读+ledger+INDEX+归档+交付总结 | 主进程（簿记白名单②） | LOCAL | 六文档; 门脚本 | check-complete exit 0 | 15min | 0f/0l/15min | 无 | S12 | complete |

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
| `conflict_scan` | 待扫描（Phase 2 首动作 `bash scripts/check-conflicts.sh`，结果回填） |
| `isolation` | `worktree`（§11.1 命中：companion agents+media rules=保护区+运行中基础设施+共享热点文件） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-imgqc-basiccheck-20261105`（§11.2 集中目录规范） |
| `branch` | `wt/task-imgqc-basiccheck-20261105` |
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
| Phase 3 | SRC↔部署双向漂移并集解遗漏（graft 丢 SRC 95.x 增量或丢部署位 47.6 细节） | 8 | 4 | 4 | 128 | 派发前主进程 Read 部署位基底块+SRC 全文逐对 diff 判向，graft 口径=「SRC 为底+graft 部署位 47.6 块」并集写进任务书（22.3① 预防）；失败则 22.3② 改派 general-coder 重做并集 |
| Phase 3 | selftest 基线漂移误报 | 4 | 4 | 3 | 48 | S4 前主进程 worktree 内预跑基线记录（预存 FAIL 分类对照，勿把环境态失败归罪改动） |
| Phase 4 | 复检体误报/漏报 | 6 | 3 | 4 | 72 | 复检任务书附两缺陷判据+证据锚；争议 → decision-arbiter（Rule 69.1 T4） |
| Phase 5 | 部署覆盖丢 frontmatter 适配（claude 位 model 行） | 7 | 3 | 3 | 63 | 逐位 diff 判向+frontmatter 保留清单先行登记；护栏=逐位 diff=0 对账表（判例=v119 frontmatter 适配/crossprojauth 逐位禁 cp） |

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
1. SRC↔部署双向漂移如何并集？→（已答）以 SRC 为底 graft 部署位 47.6 增量块，产出=双向超集，随后全量部署收敛漂移（Phase 5 S7-S12）
2. 独立视角门强度？→（已答）47.6c 先取证后判定=硬门；母图级独立复核=推荐档；不强制独立子代理 QC（避免流程成本失控与范围扩张，YAGNI）
3. 部署位 frontmatter 差异面？→ Phase 2 完成逐位 diff 判向并登记保留清单（claude 位 model 行等），S7-S12 照单保留

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
| 改既有 Rule 47.6（插入 47.6a/b/c 子条），不新增 Rule 编号 | 缺陷根因=既有 QC 门判据缺项；新增 Rule 引入编号竞态与跨域引用负担（20.6 避让成本） |
| 不新增 selftest 断言/机器门（§四.6 文本优先铁律，守护 opt-in） | 用户未显式要求机器门；回归跑既有套件保零破坏即可 |
| video-generation-executor 同步同族条款 | 47.6 为图/视频共用抽检门，单改图侧=同一规则两版本（条款分裂+部署对账复杂化） |
| 先取证后判定=硬门（47.6c），母图级独立复核=推荐档 | 拦截「凭印象判 PASS」的最小结构改动；全强制独立子代理 QC 会显著放大流程成本 |
| Rule 30 认领：命中（media rules+companion agents=共享热点文件），Phase 1 收口时经 Skill(progress-tracker) 登记 ledger 认领 | 同类技能文件修订任务 ≥3 次（v161/v166/crossprojauth 判例） |
| S7-S13 部署批次主进程直做=L0-E 纯执行档（零仓库受管变更，权重 0） | Rule 25.4 P4 用户授权：机械 cp+diff 对账不派子代理不计委派率；粒度门按 ≤2f 拆行 |
| 执行期簿记回填（Goal 表翻转/84.14 回读记录/Phase 5 checkbox 勾选/P-04 修复）→ attest 重锁 | Rule 51.7：状态类回填非 Goal/范围变更，重锁前在此登记（2026-11-06 终验收尾段） |

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
| 激活子代理数（Rule 96.5） | （Agent() 派发总次数） |
| 最大并行宽度（Rule 96.5） | （并行组数 / 最宽组宽,如 2 组 / 最宽 3） |
| 串行化例外理由（Rule 96.4） | （逐组一句话;无则写 none） |

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
| 1 | 2026-11-05 | Explore | 盘点图片 QC 门条款载体+缺口分析 | done | 载体=media rules L21 47.6；SRC 无 47.6 块/部署 6 份有（双向漂移）；Q2/Q4 缺口实锤 | critical-rules-media.md:21 | Research Findings[cp-01] | subagent-state/01-explore-qc-carriers.md | - / 0 / ☑ |
| 2 | 2026-11-05 | general-analyst | 事故会话取证两缺陷证据链+根因 | done | 双门误判 4/4 PASS 入候选；人物场景无 FAIL 挂待审核；根因三假设带锚 | Toonflow 母图状态板.md:46,56-59 | Research Findings[cp-02] | subagent-state/02-analyst-incident.md | - / 0 / ☑ |
| 3 | | | | queued | | | | | - / 0 / ☐ |

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP
- **处置登记（不沉淀理由）**：本任务=特定事故驱动的条款缺陷修复（非可复用任务画像），无沉淀 variant 价值；条款本身沉淀于 media-planner 规则层，任务过程无新模板形态产出。

## 🔁 收尾回读梳理记录（84.14 实际执行）
| 轮次 | 发现 | 处置 |
|------|------|------|
| 1 | Rule 30 ledger 认领未执行（Decisions 登记了要做） | 已补：ledger task-planner-maintenance.jsonl 追加 complete 条目（含 effect+claim） |
| 2 | knowledge-brief 未蒸馏 | 已补：§2 四条可复用事实（QC 门判据/并集判向 SOP/部署通道判例/attest 判据形态） |
| 3 | 无新发现（五维互洽：需求 R1-R4↔VC 全过↔执行 S1-S13 全闭环↔验证 6/6 PASS↔知识已沉淀） | 收敛出口达成，出 outcome |
