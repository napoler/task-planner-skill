# Task Plan: 任务路径沉淀与项目模板适配子技能
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} token 由 init-session.sh render_template() 脚本渲染（task-id/任务名/日期/路径）；尖括号中文占位=模型填写面，脚本禁碰 -->
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  选定 variant 后 template_type 填所选类型名（白名单=/home/terry/.zcode/skills/task-planner/templates/variant/*-type.md 动态派生，见 check-template-type.sh）；general=通用回退（恒合法，Rule 34.1）
  plan_tier ∈ {standard, mini}（Rule 38.1，mini 四条件机器判定）；execution_lane ∈ {L0, L1, L2}（Rule 38.7，缺省 L1；L0 禁滥用见 38.7 末段）
  check-template-type.sh 三形态之一：行首 `^template_type:`（本块）/ 表格行 / HTML 注释；本块用行首形态 -->
template_type: general
plan_tier: standard
execution_lane: L1
parallel_groups: [draft, gen-fix]
<!-- 
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC（核心问题的可观察解决证据，非手段产物完成）；目标型任务终验必填「🎯 核心目标达成裁决」区块（58.5） -->

- **R1**: 「在该项目补充对执行任务主动沉淀整理运行task-planner路径目标 核心就是在执行任务的时候，主动进行进行任务路径沉淀，也就是说将它沉淀为Task Plan的Plan，那就是说当前技能的一个模板文件，确保后期执行的时候嗯可以嗯可以，就是说按照正确的路径执行。」<sub>（[目标]）</sub>
- **R2**: 「当然说，为了确保嗯，沉淀出来的模板文件的可靠性，我希望嗯撰写的模板文件可以经过嗯严格的审查以及验证。」<sub>（[手段]）</sub>
- **R3**: 「另外我希望添加一个就是说嗯可以简单的子技能，就是核心的工作就是主动让他分析当前项目，然后嗯让他分析项目，然后制定一些模板。是为了提高该项目的运行来执行的模板。就是我比如说我我直接激活该技能之后，它核心，它的主动去分析当前项目，然后预测当前项目可能会遇到哪些问题，然后补充一些适配于当前项目的模板文件，这样的话可以后期执行任务的时候，直接嗯直接就是说优化，直接调用这些成熟的模板。就是一个相当于模板适配当前项目优化的技能，也就是说激活之后可以主动分析有哪些模板可以适配，补充之后可以适配当前项目来提高项目的质量或者执行程度等等。」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1、VC-4、VC-5 | ①34.8/34.9 条款在位（grep 标题串）②dogfood 候选过审查门留痕 ③render 冒烟 PASS |
| R2 | VC-1、VC-4、VC-5 | ①两级审查门条款化（G1-G4 在 34.8 文本可指认）②候选门清单逐项 PASS 留痕 ③冒烟命令可复现 |
| R3 | VC-2、VC-3、VC-4 | ①advisor SKILL.md 在位且 SOP 锚可 grep ②级联面全绿（路由表/索引/install 清单）③本仓产出 1 个项目适配模板 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/task-tpl-sediment-20261115/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/task-tpl-sediment-20261115/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 条款起草工序 | 34.8/34.9 与既有 34.1-34.7/34.7 全自动合约语义冲突或量纲缺失 | clause-drafts 起草+主进程定稿对照 34 全文 | VC-1 |
| 插段工序 | 结构文件插段吞锚/格式自适配（106.1a 三犯惯面） | 106.1a 三规约内联派发+锚行子串+结构回读 | VC-1 |
| 级联工序 | 卫星计数串/路由表/install 清单漏改（级联惯犯面） | grep 驱动全量清单（Rule 105）+旧串零残留断言 | VC-3 |
| 审查工序 | 候选模板未过独立审查即入库（用户 R2 核心） | G1-G4 两级门+critic 派发+门清单逐项留痕 | VC-4、VC-5 |
| 回归部署工序 | 基线时序（部署前基线漏检自产断言缺陷） | 部署后 --fresh+comm 子集判据 | VC-6、VC-7 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | ①授权范围=R1 沉淀机制+R2 审查门+R3 advisor 子技能（扩范围须走 74 三判）②既有 34.1-34.7 条款文本与既有 30 个 variant 文件零改动 ③零新 Rule 编号/零新 selftest 脚本/零新 hook/config 键（文本优先铁律）④advisor 产出禁覆盖核心 7 计划文件模板 ⑤scope 文件清单（执行范围限制表）锁定 ⑥回归判据=FAIL ⊆ 基线 | R1-R3（专档 #1）/findings F3/F4/宪法 §二文本优先 |
| 🔀 可变量 | ①S-unit 拆分与并行顺序 ②34.8/34.9 行文措辞与 advisor SOP 细节 ③dogfood 模板类型选型（由本仓分析结论定） ④部署/push 批次与时机 ⑤review 工具在 critic/agent-quality-auditor 间选型 | FMEA/工具选择表/42.2 |
| 📈 学得量 | 插段期新锚事实/级联新发现文件/冒烟机制细节 → findings.md/knowledge-brief §2；禁反向改写授权范围 | findings.md |

## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and delete functionality."
-->
[为 task-planner 建成「执行路径→模板」主动沉淀机制：Rule 34 增量补 34.8（执行期沉淀触点+候选暂存+两级严格审查门 G1-G4）与 34.9（项目级模板适配沉淀位），并新增 plan-template-advisor 轻量子技能（激活后分析当前项目→预测问题→产出过门的项目适配模板至 .zcode/plan-templates/ 原生发现位），以本仓 dogfood 产出首个过门项目模板验证全链路；零新 Rule 编号、零新脚本、既有 34.1-34.7 与 30 个 variant 零改动。]

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（规则文本+SKILL.md 新增，非代码任务） |
| `session_id` | `22f3c779ec324332bea8c784eac3cb5e` | 启动时生成,注册表追踪 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115` | §十一 隔离决策已有字段 |
| `scope_files` | `skills/plan-template-kit/references/critical-rules-template.md; skills/plan-template-advisor/SKILL.md; skills/task-planner/SKILL.md; skills/task-planner/references/critical-rules.md; skills/plan-template-kit/SKILL.md; skills/task-planner/lib/install-stub.sh; skills/task-planner/README.md; skills/task-planner/docs/ARCHITECTURE.md; skills/task-planner/scripts/selftest-verification-gate.sh; skills/task-planner/scripts/selftest-registry.tsv; skills/verification-gate/SKILL.md; skills/verification-gate/references/critical-rules-verification.md; .zcode/plan-templates/（dogfood 新增 *-type.md）` | 从「执行范围限制」解析,并发检测基础（2026-11-15 CA-10/11/12 修订：+README/ARCH 实际路径更正+计数窗 2 脚本+verification-gate 2 文件序数同步） |
| `interaction_mode` | `ask` | Rule 28 交互模式：ask=关键决策点给选项；silent=静默+静默决策清单登记 |
| `对齐审查` | [登记] 收尾跑 alignment-review | Rule 42.6 消费：任务产出或更新的文档在完成前跑 alignment-review 对齐审查（标准收尾流程）;文档更新前跑版本一致性校验（未经校验不追加）;变更记录随交付物落盘;mini 档豁免（42.6.4） |
| `自动超时默认项` | 询问点①push 三仓=默认「执行（11-05 先例）」/5min；询问点②dogfood 模板类型选型=默认「按分析结论首荐」/5min；其余低区分度点不询问直接裁决登记（44.2） | Rule 44 消费：本任务所有 2+ 选项询问点逐个登记默认选项（推荐项）与自动超时时长（默认 5 分钟,可覆盖）;低区分度选项（产出一致仅步骤/耗时差异）不询问、直接裁决并登记理由（44.2）;用户超时未答复按默认选项自动执行+登记自动裁决记录五要素（44.3）;mini 档豁免（44.4） |
| `new_rule` | 留空（34.8/34.9 增量挂 Rule 34 族，不新增编号） | Rule 20.6：本任务新增 Rule 编号时填写（attest 自动预留+查重；无则留空） |
| `质量审查工具` | critic（G3 独立审查门+103.3 复检）+alignment-review（收尾） | Rule 42 消费登记（42.4）：任务涉及质量审查面时按 42.2 四级检测（含内置 review-library 兜底池）,填 技能名/既有 agent 名/待补充 S-unit 指针;缺口按 42.3 补建并登记 S-unit;执行期必须用登记工具;mini 档豁免（42.5） |

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
| VC-1 | 34.8（执行期沉淀触点+候选暂存+两级审查门 G1-G4）与 34.9（项目级沉淀位）条款在 critical-rules-template.md 在位；既有 34.1-34.7 零改动 | grep 两标题串各=1 + git diff 对照既有行零变更 | worktree: skills/plan-template-kit/references/critical-rules-template.md |
| VC-2 | skills/plan-template-advisor/SKILL.md 在位：frontmatter name/description + SOP 六步锚（分析→预测→缺口映射→产出→审查→登记）grep 各 ≥1 | test -f + grep 锚 ≥5 | skills/plan-template-advisor/SKILL.md |
| VC-3 | 级联面全绿：task-planner/SKILL.md 卫星路由表含 advisor 行且「11 卫星」串更新 12（旧串 grep=0）；critical-rules.md 路由索引含行；install-stub.sh SATELLITE_SKILLS 含名；plan-template-kit/SKILL.md 指针在位 | grep 逐点 ≥1 + 旧计数串=0 | 5 级联文件（README/ARCHITECTURE 含内） |
| VC-4 | dogfood 项目模板候选过审查门：本仓 .zcode/plan-templates/ 新增 1 个 `*-type.md` 且 G1/G2/G3 逐项 PASS 留痕 verification.md | 门清单逐项勾+产物 test -f | plans/task-tpl-sediment-20261115/template-candidate/ 与 .zcode/plan-templates/ |
| VC-5 | render 冒烟 PASS：候选（及若新增官方 variant 则含之）经 render_template 渲染无 {{残留}}；init tmp 隔离实跑选中该类型生成 task_plan.md 成功 | 冒烟日志+产物 grep | tmp/ 冒烟日志（路径记 progress） |
| VC-6 | 全量回归零增量：部署后 run-selftests.sh --fresh FAIL 集合 ⊆ 基线（部署前基线先行落盘） | comm -13 =0 | tmp/regression-tpl-sediment-baseline.txt 与 tmp/regression-tpl-sediment-final.txt |
| VC-7 | 部署对账：改动文件在部署位 diff=0（task-planner 目录 --deploy 3 槽位+advisor 目录 cp 至宿主位+cursor 位落盘核对） | 逐位 diff -q 回执 | 部署回执记 progress |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard/full 必填，mini 豁免）
<!-- task-dualqc-20261104 新增：双轮质检机制在计划阶段显式设计——派发型实质产出 S-unit 默认两道检核（第一轮执行体自审 103.2 checkpoint 自审段；第二轮主代理派全新子代理独立复检 103.3，档位升一档 103.4、复检任务书简洁五要素 103.5）；多文件变更集（≥2 受管文件）Phase 翻转前过 103.6 同步完整性审查（关联面推导四族→同步核对清单全绿）。豁免面=103.7，逐 S-unit 登记理由；mini 档整体豁免。 -->
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | Phase 1 S1-S2（条款/SKILL 草案）+Phase 2 S1-S6（全部插改/新建实质产出）+Phase 3 复检体本身 |
| 豁免登记 | Phase 1 S1-S2 第二轮独立复检由 Phase 3-S1 critic 承接（复检对象=落位后终态文本，强于草稿态复检，避免同内容双审；103.7 登记） |
| 多文件变更集预判 | Phase 2（≥2 受管文件级联）→ 合并回前过 103.6 同步核对清单（grep 清单逐项全绿） |


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
| G1 | 起草定稿 | clause-drafts（34.8/34.9 v1+两级门清单）+advisor 草案落盘并定稿 | clause-drafts.md+advisor-draft 在位且 34.8/34.9 标题串可 grep | P1-S1/S2 | complete（V-1.1/V-1.2 PASS，findings F11/F12） |
| G2 | 级联落地 | worktree 内条款+SKILL+级联五落点全部就位 | grep 新串逐点 ≥1+git diff 既有行零改动 | P2-S1-S5 | complete（V-2.1/2.2 PASS，commit 8bc8e86） |
| G3 | dogfood 过门 | 本仓项目适配模板候选产出且过 G1-G3 门 | 候选 test -f+门清单逐项 PASS 留痕 verification.md | P2-S6+P3 | complete（G2 复跑 PASS smoke-g2-r2+G3 critic APPROVED+CA-8 落位，findings F17） |
| G4 | 审查回归 | critic APPROVED+worktree selftest FAIL ⊆ 基线 | 检查点 verdict+comm 判据 | P3-S1-S3 | complete（review-critic-r3.md APPROVED+comm 空，findings F16/F17） |
| G5 | 部署收尾 | 合并回+部署对账 diff=0+部署后回归+归档 | diff 回执+comm+archive 回执 | P4 | complete（merge 7ea0a98+20 对 diff=0+VC-6 comm=0+三仓 push） |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则文本 | skills/plan-template-kit/references/critical-rules-template.md（34.7 后追加 34.8/34.9，既有行零改动） | 既有 34.1-34.7 任何一行；其他 critical-rules 卫星文件 |
| 新技能 | skills/plan-template-advisor/SKILL.md（新建） | advisor 目录下新增 references/scripts（保持单文件）；其他 skills/** |
| 级联面 | skills/task-planner/SKILL.md（路由表行+计数串）；skills/task-planner/references/critical-rules.md（路由索引行+建制枚举）；skills/plan-template-kit/SKILL.md（沉淀指针）；skills/task-planner/lib/install-stub.sh（SATELLITE_SKILLS）；skills/task-planner/README.md+docs/ARCHITECTURE.md（卫星表/分类计数）；skills/task-planner/scripts/selftest-verification-gate.sh（VG-06 计数窗 11→12）+selftest-registry.tsv（VG-06 描述行同步） | hooks/；config.json；30 个既有 variant；执行期 grep 发现的其他计数串文件须先登记再改 |
| 项目模板 | .zcode/plan-templates/ 下新增 1 个 `*-type.md`（dogfood）+manifest 行 | 覆盖核心 7 计划文件模板（task_plan/verification 等）；删除既有 knowledge-brief.md |
| 计划文档 | plans/task-tpl-sediment-20261115/**（含 template-candidate/） | - |

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
| CA-1 | critical-rules-template.md:22 后（34.7 末行） | 新增（34.8/34.9 两子条） | 增量（既有 34.1-34.7 逐字保留） | R1「主动进行任务路径沉淀…沉淀为…模板文件」+R2「经过严格的审查以及验证」 | findings F3（34 缺口） | worktree 内段尾追加（106.1a：new_string 含 34.7 末行锚子串） |
| CA-2 | skills/plan-template-advisor/SKILL.md（新建） | 新增 | 增量 | R3「添加一个…简单的子技能…主动去分析当前项目…补充一些适配于当前项目的模板文件」 | findings F7（最小形态先例） | worktree 内新建单文件 |
| CA-3 | task-planner/SKILL.md:213 卫星路由表+「11 卫星」计数串 | 修改（加行+计数 11→12） | 增量 | R3（子技能须可被路由发现） | findings F4 级联面 | grep 驱动：路由表加行+全仓「11 卫星」旧串同改 |
| CA-4 | task-planner/references/critical-rules.md:178,200 路由索引 | 修改（加 advisor 行） | 增量 | 同 CA-3 | findings F4 | 行级追加 |
| CA-5 | plan-template-kit/SKILL.md 沉淀指针段 | 修改（补 advisor 路由句） | 增量 | 同 CA-3 | findings F4 | 段内追加句 |
| CA-6 | install-stub.sh:41 SATELLITE_SKILLS | 修改（清单加名） | 增量 | 同 CA-3 | findings F5 | 数组元素追加 |
| CA-7 | skills/task-planner/README.md+skills/task-planner/docs/ARCHITECTURE.md 卫星表（原写根路径系笔误，11-15 实测修正） | 修改（各加行+分类计数） | 增量 | 同 CA-3 | findings F4（:31,72,187/:37,85,104） | 表行追加 |
| CA-8 | .zcode/plan-templates/（dogfood 模板） | 新增 | 增量 | R3「补充一些适配于当前项目的模板文件」 | findings F2（原生发现机制） | 过门后落位+manifest 登记 |
| CA-9 | 本计划「🔁 模板感知」处置登记 | 更新 | 增量 | —（模板感知区块自要求） | Rule 34.3② | 终验期登记沉淀/不沉淀理由 |
| CA-10 | selftest-verification-gate.sh VG-06（:80-86 计数断言）+selftest-registry.tsv VG-06 行描述 | 修改（'11 卫星'→'12 卫星' 计数窗同步） | 替代（四条件：①真值 12 使旧断言必破=回归证伪 ②替代范围仅该计数串 ③改前 Read 原文 ④替代后全量 selftest 回归绿） | R3（子技能须可路由发现）+Rule 34.7「同源锚必同改」判例 | worktree sweep 实测 VG-06 硬断言 '11 卫星'（11-15） | P2-S5b 补漏单元 |
| CA-11 | skills/task-planner/README.md:31,41,63 + docs/ARCHITECTURE.md:37,47,69,§2.1/§2.2 | 修改（advisor 归类收编→新域：新域 ×3→×4/收编 ×8→×7） | 替代（同 CA-10 四条件） | R3 | ARCHITECTURE 新域=task-v171 新建语义；advisor 同为新建域卫星非收编（11-15 实测 S5 误归） | P2-S5b 补漏单元 |
| CA-12 | skills/verification-gate/SKILL.md:3,10 + skills/verification-gate/references/critical-rules-verification.md:3（「第 11 卫星」自述序数） | 修改（→第 12 卫星） | 替代（同 CA-10 四条件） | R3+同源锚必同改判例 | critic C-7 复检发现（103.3 R1 轮 review-critic.md，11-15） | 修复批次 F3 单元；若 VG-01 断言钉旧串则同步断言 |
| CA-13 | worktree advisor/SKILL.md:60（第 5 处 findings 指针）+critical-rules-template.md 34.8 衔接句+候选模板路径修正+critical-rules.md:178 回退+install-stub 注释+行位次+ARCH §2.1 列语义 | 修改（critic C-1..C-9 修复批次） | 增量/替代（逐项按四条件） | R2/R3 | critic review-critic.md 9 项（11-15） | 修复批次 5 单元并行（F1a/F1b-mix/F2a/F2b/F3）；F12 回执更正（「已全清」不实）记 findings F15 |
| CA-14 | critical-rules.md:201 路径深度（../→../../）+「7 卫星/7 个卫星」6 处语义判定（README:113,150/install-stub:246,304/ARCH:160,182） | 修改（critic R2 轮 C-10/C-11） | 增量/替代（逐点判定：指 SATELLITE_SKILLS rsync 清单者 7→8；指收编卫星数者保持 7=CA-11 后正确值；指旧卫星总数者按上下文 12 化） | R3+同源锚必同改判例 | critic review-critic-r2.md（C-10=ls ENOENT 硬证据；C-11 六处 pre-existing） | 修复批次 F4a/F4b 两单元并行；禁盲改 |
| CA-15 | 候选类型标识统一（rule-clause-cascade-type→rule-clause-cascade：机读头+template_type 字段+README 登记）+候选 VC-3 改等价聚合口径（原引用不存在 scripts/run-selftests.sh）+advisor SOP 补命名纪律句（draft+worktree SKILL 同步） | 修改 | 替代（四条件：①G2 首跑选型失败实证=init 派生口径证伪旧标识 ②替代范围仅类型标识串/单条命令/一句 SOP ③改前 Read 原文 ④复跑 G2 过门） | R2/R3 | 冒烟回执 smoke-g2.md（unknown template_type+generic 回退+对照探针 rule-clause-cascade 全过） | 主进程修 plans/ 三文件+G2 复跑单元改 worktree SKILL 并复测 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | Rule 34 模板生命周期全文（34.1-34.7） | skills/plan-template-kit/references/critical-rules-template.md:11-22 | 必读 | ☑ |
| 项目内部文档/知识库 | 模板类型机制与白名单派生 | skills/task-planner/scripts/check-template-type.sh:1-43 | 必读 | ☑ |
| 项目内部文档/知识库 | 项目级模板覆盖原生机制 | skills/task-planner/scripts/init-session.sh:65-97,570-730 | 必读 | ☑ |
| 项目内部文档/知识库 | 计数级联锚（TL-17 等） | skills/task-planner/scripts/selftest-template-lifecycle.sh:186-204 | 必读 | ☑ |
| 项目内部文档/知识库 | 卫星 SKILL 形态先例（plan-template-kit 40 行） | skills/plan-template-kit/SKILL.md | 必读 | ☑ |
| 项目内部文档/知识库 | 部署面与安装清单 | smart-merge-back.sh:377-470；lib/install-stub.sh:41,289 | 参考 | ☑ |
| 项目内部文档/知识库 | 双 Explore 调研回执（F1-F10） | plans/task-tpl-sediment-20261115/findings.md | 必读 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: Rule 34 沉淀机制缺「执行期主动触点」与「独立严格审查门」（34.3 仅终验兜底、34.4 直建无暂存无审查），且项目级适配模板无生产沉淀机制——导致沉淀靠运气触发、模板可靠性无门、各项目的适配模板无处沉淀复用。解决后：执行路径可主动登记候选→过两级审查门→沉淀为官方 variant 或项目级模板，后续任务直接调用。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（34.8/34.9 条款+advisor 技能+dogfood 过门模板=可观察可验证）
- [x] 核心问题不解决，其他工作都白费吗？（无审查门的沉淀=不可靠模板入库；无项目位=R3 落空）
- [x] 核心问题的解决方法是清晰的、可执行的？（复用既有 34 族/原生项目级机制/既有审查 agent，零新脚本）

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
Phase 4（合并回+部署同步+终验交付）

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
smart-merge-back 合并回主仓（worktree 全 VC+清洁）→ --deploy 对账 → 部署后回归 → push 询问点 → 收尾

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 general-purpose×2（并行组 draft，同消息并发） | 起草隔离上下文；主进程定稿复核 |
| Phase 2 | Agent 子代理 general-coder×5+general-purpose×1（并行组 gen-fix，同消息并发） | 插改/新建隔离执行；106.1a 内联；plan-template-kit 伴飞 |
| Phase 3 | critic（独立审查）+code-runner-agent×2（冒烟/回归） | 双轮质检升档+验证隔离（Rule 33.3） |
| Phase 4 | 主进程白名单（git 编排/簿记） | Rule 25.3 白名单动作 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8（各 S-unit 均单点产物+依赖链清晰，无长链编排、用户未点名）→ Rule 21.4 独立性守门调度：P1 双 S-unit 并行组 draft、P2 六 S-unit 并行组 gen-fix，同消息并发
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；用户未用 /goal 命令；技能层不代调

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 设计定稿与起草（draft 并行）
<!-- 
  WHAT: 起草 34.8/34.9 条款 v1+两级审查门清单+advisor SKILL 草案，主进程定稿。
  WHY: 先稿后插改——插改以草案为唯一事实源，禁现场发挥。
-->
- [x] 双 Explore 调研回收（模板体系/沉淀基础设施+级联面）→ findings F1-F10
- [x] clause-drafts.md 落盘：34.8/34.9 条款 v1+两级审查门清单 G1-G4（S1）
- [x] advisor-draft 落盘：plan-template-advisor SKILL.md 全文草案（S2）
- [x] 主进程逐字定稿复核（修正 2 处：§3 init 形态/4 处 findings 指针换机制锚）
- [x] 知识储备必读项已确认可获取（已 ☑）
- **V-N:** VC-1, VC-2（V-1.1/V-1.2 PASS，见 progress Test Results）
- **Status:** complete
- **Executor:** general-purpose（默认档）
<!-- 
  STATUS VALUES:
  - pending: Not started yet
  - in_progress: Currently working on this
  - complete: Finished this phase
-->

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
| S1 | (A6) 起草 clause-drafts.md：34.8（执行期沉淀触点+候选暂存+两级审查门 G1-G4）/34.9（项目级沉淀位与 advisor 路由）条款 v1+门清单+级联 spec | general-purpose（默认档） | plans/task-tpl-sediment-20261115/findings.md（F1-F10）+ skills/plan-template-kit/references/critical-rules-template.md（Rule 34 全文对照） | drafts 在位且两标题串可 grep+门四要素齐+级联 spec 齐 | 15min | 1f/90l/15min | plan-template-kit | - | pending [parallel-group:draft] |
| S2 | (A6) 起草 advisor SKILL.md 全文草案（frontmatter+SOP 六步：分析→预测→缺口映射→产出→审查→登记） | general-purpose（默认档） | plans/task-tpl-sediment-20261115/findings.md（F2/F3/F7）+ skills/plan-template-kit/SKILL.md（40 行形态先例） | 草案在位且六步锚齐+frontmatter name/description 合规 | 15min | 1f/80l/15min | 无 | - | pending [parallel-group:draft] |

### Phase 2: worktree 实现插改（gen-fix 并行）
<!-- 
  WHAT: 条款/技能/级联五落点/dogfood 候选全部在 worktree 落位。
  WHY: 106.1a 三规约内联（grep 锚→new 含锚行子串→结构回读）；禁格式自适配。
-->
- [x] 条款 34.8/34.9 插入 critical-rules-template.md（S1）
- [x] advisor SKILL.md 定稿落位（S2）
- [x] 级联 A：SKILL.md 路由表+计数串、core.md 路由索引（S3）
- [x] 级联 B：install-stub.sh、kit SKILL.md 指针（S4）
- [x] 级联 C：README.md、docs/ARCHITECTURE.md（S5，实际路径+CA-7 修正）
- [x] dogfood：本仓项目分析→候选模板落 template-candidate/（S6）
- [x] worktree 内复核新串命中+既有锚零改动+103.6 同步核对全绿+commit 8bc8e86（S5b 补漏：VG-06 计数窗+分类修正，CA-10/11）
- **V-N:** VC-1, VC-2, VC-3（V-2.1/V-2.2/V-2.3 PASS，见 progress Test Results）
- **Status:** complete
- **Executor:** general-coder（默认档）
（条款/SKILL/级联均为文本插改，模板代码组画像不适用，执行体=general-coder）

<!-- P2 S-unit 派发单元表（Rule 22.6；机器契约同 P1 表注释） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6) 条款插入：34.8/34.9 追加至 worktree critical-rules-template.md 34.7 后（106.1a 三规约：grep 段清单/锚行子串/结构回读） | general-coder（默认档） | worktree skills/plan-template-kit/references/critical-rules-template.md（锚=34.7 末行）+ plans/task-tpl-sediment-20261115/clause-drafts.md §1 | grep 两标题串各=1+34.1-34.7 零改动+回读段序完整 | 15min | 1f/70l/15min | plan-template-kit | S1(P1) | pending [parallel-group:gen-fix] |
| S2 | (A6) advisor SKILL.md 定稿落位 worktree 新目录（依草案，主进程定稿修订为准） | general-coder（默认档） | worktree skills/plan-template-advisor/SKILL.md（新建）+ plans/task-tpl-sediment-20261115/advisor-draft.md | 文件在位+六步锚 grep ≥5+frontmatter 合规 | 10min | 1f/90l/10min | 无 | S2(P1) | pending [parallel-group:gen-fix] |
| S3 | (A6) 级联 A：task-planner/SKILL.md 卫星路由表加行+「11 卫星」串 12 化+core critical-rules.md 路由索引/分层枚举加行 | general-coder（默认档） | worktree skills/task-planner/SKILL.md（:213 表区）+ worktree skills/task-planner/references/critical-rules.md（:178,200 区） | grep advisor 行各 ≥1+旧「11 卫星」串=0+邻行零改动 | 10min | 2f/8l/10min | 无 | S1(P1) | pending [parallel-group:gen-fix] |
| S4 | (A6) 级联 B：install-stub.sh SATELLITE_SKILLS 加名+plan-template-kit/SKILL.md 沉淀指针补 advisor 句 | general-coder（默认档） | worktree skills/task-planner/lib/install-stub.sh（:41）+ worktree skills/plan-template-kit/SKILL.md | grep plan-template-advisor 各 ≥1 | 5min | 2f/4l/5min | 无 | S1(P1) | pending [parallel-group:gen-fix] |
| S5 | (A6) 级联 C：README.md+docs/ARCHITECTURE.md 卫星表加行 | general-coder（默认档） | worktree README.md+ worktree docs/ARCHITECTURE.md | grep advisor 行各 ≥1+旧表行零改动 | 5min | 2f/4l/5min | 无 | S1(P1) | pending [parallel-group:gen-fix] |
| S6 | (A6) dogfood：按 advisor SOP 分析本仓→产出 1 个项目适配模板候选落 plans/task-tpl-sediment-20261115/template-candidate/ + 选型依据落 findings | general-purpose（默认档） | plans/task-tpl-sediment-20261115/advisor-draft.md（SOP 依循）+ plans/task-tpl-sediment-20261115/findings.md（本仓事实） | 候选 `*-type.md` 在位+选型依据落 findings | 15min | 1f/60l/15min | 无 | S2(P1) | pending [parallel-group:gen-fix] |

### Phase 3: 审查门+回归（worktree 内）
<!-- 
  WHAT: 独立审查+render 冒烟+selftest 基线对照（G1-G3 门全项执行）。
  WHY: 用户 R2 严格审查验证=独立子代理审查+可复现冒烟，主进程自测不作验收。
-->
- [x] 独立审查：critic R1 CHANGES_REQUESTED(9 项)→修复批次→R2(2 项)→F4→**R3 APPROVED**（S1，103.3 三轮收敛）
- [x] render 冒烟：G2 首跑 FAIL（类型标识双后缀）→CA-15 修复→复跑 PASS（S2，commit 71c97ad）
- [x] 全量 selftest：基线落盘+worktree 跑+comm 判定新增 FAIL=0（S3）
- [x] CA-8 落位：.zcode/plan-templates/rule-clause-cascade-type.md+manifest（G1-G3 过门后）
- [x] 规范召回（Rule 93）：Phase 翻转主进程 Read execution-recall-card.md+progress [recall] 行
- **V-N:** VC-4, VC-5, VC-6（门记录段+regression-s3.md 实测）
- **Status:** complete
- **Executor:** critic（默认档）

<!-- P3 S-unit 表 -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6) 独立审查：条款/技能/级联/候选模板按门清单+级联完整性逐项核对 | critic（默认档） | clause-drafts.md（§0 scope 清单+门清单）+ worktree 根 /mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115 | 检查点 verdict=APPROVED 逐项带 grep 证据 | 15min | 1f/0l/15min | 无 | S1-S6(P2) | pending |
| S2 | (A6) render 冒烟+门 G2：候选 render_template 无 {{残留}}+init tmp 隔离实跑选中类型（sid 隔离防指针污染） | code-runner-agent（默认档） | 候选模板路径（自 clause-drafts.md §3 冒烟 spec）+ tmp/ 冒烟工作目录 | 冒烟日志无 {{残留}}+类型选中成功 | 15min | 1f/0l/15min | 无 | S1(P3)+S6(P2) | pending |
| S3 | (A6) 全量 selftest：主仓基线落盘+worktree 跑+comm 子集判定 FAIL ⊆ 基线 | code-runner-agent（默认档） | runner 路径（install.log 同族 scripts/run-selftests.sh）+ 基线输出 tmp/regression-tpl-sediment-baseline.txt | comm 判据 FAIL(worktree) ⊆ FAIL(基线) | 15min | 1f/0l/15min | 无 | S1(P3) | pending |

### Phase 4: 合并回+部署同步+终验交付
<!-- 
  WHAT: stash 窗口合并回（在途任务竞写预案）→部署对账→部署后回归→push→归档。
-->
- [ ] 合并回主仓（在途任务竞写预案：区域隔离+并集解/stash 窗口法，判例 task-docmod-recheck）+worktree 清理
- [ ] 部署同步：--deploy（task-planner 目录 3 槽位，variant 随目录覆盖）+advisor 目录 cp 至宿主位（install-stub 清单）+cursor 位落盘核对
- [ ] 部署后 --fresh 全量回归 FAIL ⊆ 基线（VC-6 复验）+部署位逐对 diff=0（VC-7）
- [ ] 三仓 push（pathspec 锁定；询问点①默认「执行（11-05 先例）」/5min）+INDEX 刷新
- [ ] 全文档收尾回读梳理记录（Rule 84.14）：全量回读六文档体系→五维互洽→偏移迭代→收敛出口（连续一轮零新发现）后才出 outcome
- [ ] 归档计划：check-complete exit 0 后先 `bash <skill>/scripts/set-active-plan.sh --clear` 再 `bash <skill>/scripts/archive-plan.sh task-tpl-sediment-20261115 --root <plans根>`（Rule 81；守卫拒绝时登记理由不强移）
- [ ] 知识提取入库：`bash scripts/kb-sync-from-plan.sh <plan-dir>` 生成 draft → 精炼改名 → `bash scripts/kb-rebuild-index.sh`（§7 回链）
- [ ] 模板感知处置登记（Rule 34.3②：本任务类型是否沉淀新 variant→按 34.8 新门自评估登记）
- **V-N:** VC-6, VC-7
- **Status:** pending
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
<!-- 每轮一行：轮次/发现/处置；连续一轮零新发现才可出 outcome（收敛出口，轮次不设上限）；
     发现面=需求↔目标↔执行↔验证↔知识五维互洽（偏移/遗漏/未利用知识） -->
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1 | ①终验簿记未填（Goal 单元表/委派统计/本表）②kb 入库未执行③NIT-1（README 路由表缺 verification-gate 行）pre-existing 未登记 follow-up④询问点②dogfood 选型默认项未显式登记裁决 | ①本轮补齐（本表+Goal complete+委派统计）②kb-sync 执行（见 progress）③登记 follow-up（另案：README 补 verification-gate 行或豁免声明）④登记=S6 按分析结论首荐 rule-clause-cascade（证据 INDEX/archive/git log，符合计划默认项） |
| 2 | 零新发现（六文档回读：需求↔目标↔执行↔验证↔知识五维互洽；R1-R3 全覆盖、VC 7/7 PASS、门记录在位、kb 入库后闭环） | 收敛出口达成 → outcome=COMPLETE |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①8 个未提交变更——与本 scope 零文件重叠；信号②在途 worktree=task-clause-generalize-20261115；信号⑤运行中基础设施；scope 文件级重叠=SKILL.md/critical-rules.md 但编辑区域隔离，我改 :213 路由表/路由索引区，其改 :229 bullet/:107 条款行） |
| `isolation` | `worktree`（实现类默认首选+§六保护区） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115` |
| `branch` | `wt/task-tpl-sediment-20261115` |
| `merge_back` | `merged(7ea0a98)`（stash 窗口法；master 并行前进两轮均并集解；worktree 已 remove+branch 已删） |

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
| Phase 2/4 | 在途任务 clause-generalize 同文件竞写（SKILL.md/core.md）合并冲突或互相覆盖 | 7 | 5 | 3 | 105 | 预设兜底=区域隔离（我改 :213 路由表区/:178,200 索引区，其改 :229/:107 条款行）+合并回前 `git log` 对账对端 HEAD+冲突并集解/stash 窗口法（判例 task-docmod-recheck，已验证可还原）（22.3②） |
| Phase 3 | render 冒烟 init 实跑写会话 side 指针，污染本会话活跃计划 | 6 | 4 | 4 | 96 | 冒烟用隔离 sid（env 伪造/临时 sid）+事毕 set-active-plan 复原+指针路径校验（attest 输出计划路径与本计划不符=第一信号，判例 active-plan-pointer-race） |
| Phase 4 | 部署位清单差异（--deploy 3 槽位 vs install-stub 四宿主）漏部署 advisor 目录 | 5 | 5 | 3 | 75 | 逐位对账 diff=0 门（VC-7）+install-stub.sh SATELLITE_SKILLS 为部署真源 |
| Phase 1 | 起草稿与 34.7 全自动合约/34.5 防滥用语义冲突 | 5 | 4 | 3 | 60 | 主进程定稿对照 34 全文+critic 复检兜底 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-11-15 14:55 | S1 TodoWrite 双组建立 |
| Phase 2 | ☑ | 2026-11-15 14:55 | 同上 |
| Phase 3 | ☑ | 2026-11-15 14:55 | 同上 |
| Phase 4 | ☑ | 2026-11-15 14:55 | 同上 |
| Phase 5 | n/a | - | 本计划 4 Phase 结构 |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. 34.8 两级审查门的判定面如何在不新增脚本前提下可执行？（G1 grep/结构清单+G2 render_template fail-closed+G3 critic 派发——全部既有机制承载）
2. dogfood 沉淀哪个项目模板类型？（由 S6 本仓分析结论定：plans/INDEX 高频任务类型 × 既有 30 类覆盖缺口映射；候选落 template-candidate/ 过门后才落 .zcode/plan-templates/）

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
| template_type=general | 混合型任务（规则增款+新技能+项目模板 dogfood）无单一既有类型覆盖；rule-enhancement 聚焦纯条款修订不含技能目录新增（先例 clause-generalize 同判 general） |
| 34.8/34.9 增量挂 Rule 34 族，不新增 Rule 编号 | 账本已至 107（task-serial-sync 占）；增量默认（Rule 74.2a）；域归属=模板卫星（critical-rules.md:178 判定） |
| 审查门两级：官方 G1-G4 / 项目级 G1+G2+G3 | 用户「严格审查」=G3 独立审查两级都强制；G4 官方级联仅官方库适用（项目级不动官方文件） |
| 特性 B 沉淀位复用 init-session.sh 原生项目级机制 | findings F2 实证（:65-97,667-679），零接线零脚本（文本优先铁律） |
| 不新增 selftest 脚本/机器门/hook | 文本优先铁律（宪法 §二/§四 P0）；验收=既有 selftest+grep 判据承载 |
| advisor 单文件最小形态（SKILL.md only） | 用户「简单的子技能」；plan-template-kit/SKILL.md 40 行先例 |
| 计划撰写主进程直做（未派 plan-writer） | 设计要素已在主上下文（调研双回执+裁决），转述成本高于直写；plans/ 写入属主进程白名单域 |
| 计划路径笔误修正+自测计数钉补漏（CA-10/CA-11，2026-11-15） | README/ARCH 实际在 skills/task-planner/ 下（S5 实测根路径不存在）；VG-06 硬断言 '11 卫星' 与真值 12 冲突→按 34.7「同源锚必同改」判例同步计数窗；advisor 归类=新域卫星（非收编）；scope 扩张已按 74 三判门登记替代四条件 |
| critic R1 轮 CHANGES_REQUESTED→9 项修复批次（CA-12/13，2026-11-15） | 103.3 双轮质检按设计生效：C-1 第 5 处指针漏改（F12「已全清」被证伪）/C-2 references/ 幽灵路径/C-3 建制枚举误列（advisor 规则数 0 不入规则归属枚举）/C-4 34.7-34.8 双入库通道未衔接/C-5 候选路径/C-6-9 计数序数与位次；修复 5 单元并行全 PASS（fix-f1a/f1b/f2a/f2b/f3 检查点） |
| 候选类型标识统一+advisor 命名纪律（CA-15，2026-11-15） | G2 首跑实证 init 从文件名去 `-type.md` 派生类型名（rule-clause-cascade），双后缀标识选型失败回退 generic；对照探针证明修正后全链通过；教训回写 advisor SOP（类型标识=文件名去后缀，禁双后缀）——沉淀机制自身在 dogfood 中产出第一手改进 |

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
| 2026-11-15 15:12 | ALIGNED（drift-1.md：产物/锚点/Goal 对齐一致，未越 scope） | VC-1、VC-2 | Phase 1 通过，进入 Phase 2 |
| 2026-11-15 15:45 | ALIGNED（drift-2.md：commit 8bc8e86 十文件与 CA-1..11 一致、worktree 清洁、五落点命中） | VC-1、VC-2、VC-3 | Phase 2 通过，进入 Phase 3 |

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
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 4 |
| 主进程直做 Phase 清单 | Phase 4（例外理由:① git 编排+② 簿记——Rule 25.3 白名单；含 stash 窗口合并/部署/收尾） |
| 委派率 | 0.75（≥0.7 达标） |
| 激活子代理数（Rule 96.5） | 27（Explore 2+P1 2+drift 3+P2 6+S5b 1+critic 3+修复批次 5+S2/S3 2+G2 复跑 1+F4 2） |
| 最大并行宽度（Rule 96.5） | 2 组 / 最宽 6（gen-fix：P2-S1..S6 同消息并发） |
| 串行化例外理由（Rule 96.4） | none（draft/gen-fix 两并行组均已声明并同消息并发；critic R1→修复→R2→F4→R3 为质检收敛链，串行=103.3 迭代语义） |

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
| 1 | 2026-11-15 14:47 | Explore | 调研模板体系与沉淀基础设施 | done | 30 variant 清单+白名单动态派生+项目级覆盖原生机制+Rule 34 缺口+TL-17 计数锚 | check-template-type.sh:17/init-session.sh:65-97/critical-rules-template.md:11-22 | findings F1-F3/F8/F9 | （回执即检查点，结论已落 findings） | - / 0 / ☑ |
| 2 | 2026-11-15 14:47 | Explore | 调研新技能注册级联面 | done | 卫星最小形态+级联五落点清单+--deploy 3 槽位+编号账本至 107+skill-split 固定清单不破 | SKILL.md:213/install-stub.sh:41/smart-merge-back.sh:389/.rule-reservations.jsonl | findings F4-F7/F10 | （同上） | - / 0 / ☑ |
| 3 | 2026-11-15 15:05 | general-purpose | P1-S1 起草 clause-drafts（34.8/34.9+两级门清单） | done | 36 行五节齐；定稿修正 §3 init 调用形态（TASK_TEMPLATE_TYPE env）；V-1.1 PASS | clause-drafts.md:8,11-18 | findings F11 | （草案本体即检查点） | - / 0 / ☑ |
| 4 | 2026-11-15 15:05 | general-purpose | P1-S2 起草 advisor SKILL 草案 | done | 60 行六步+铁律 5 条；定稿清 4 处任务本地指针换机制锚；V-1.2 PASS | advisor-draft.md:2-3,14-60 | findings F12 | （草案本体即检查点） | - / 0 / ☑ |
| 5 | 2026-11-15 15:15 | general-coder | P2-S1 条款 34.8/34.9 插入 worktree | done | +2 行插入 34.7 后；grep=1/1；34.1-34.7 零删；回读段序完整 | worktree grep+git diff | findings F13 | commit 8bc8e86 | - / 0 / ☑ |
| 6 | 2026-11-15 15:15 | general-coder | P2-S2 advisor SKILL.md 落位 worktree | done | 逐字落位 diff=0；frontmatter 合规 | worktree diff 空 | findings F13 | commit 8bc8e86 | - / 0 / ☑ |
| 7 | 2026-11-15 15:15 | general-coder | P2-S3 级联 A（SKILL.md 路由表+core 索引） | done | 路由行+「12 卫星」×3+core 枚举/索引（+3/-3、+3/-2）；旧串=0 | worktree grep=1/2 | findings F13 | commit 8bc8e86 | - / 0 / ☑ |
| 8 | 2026-11-15 15:15 | general-coder | P2-S4 级联 B（install-stub+kit 指针） | done | 数组加名+kit 指针句；grep=1/1 | worktree grep | findings F13 | commit 8bc8e86 | - / 0 / ☑ |
| 9 | 2026-11-15 15:15 | general-coder | P2-S5 级联 C（实际路径 README/ARCH） | done | 落位+计数 12 化；根路径笔误暴露（CA-7 修正）；advisor 误归收编→S5b 修 | worktree grep=4/6 | findings F13 | commit 8bc8e86 | - / 0 / ☑ |
| 10 | 2026-11-15 15:15 | general-purpose | P2-S6 dogfood 项目模板候选 | done | rule-clause-cascade-type 39 行候选+README 登记；G1 自检 PASS；选型依据带盘上证据 | template-candidate/ | findings F14 | README 登记 | - / 0 / ☑ |
| 11 | 2026-11-15 15:35 | general-coder | P2-S5b 计数窗+分类补漏（CA-10/11） | done | VG-06 '12 卫星' 同步+registry+4新域/7收编；selftest-verification-gate 实跑 PASS=13 FAIL=0 exit 0 | selftest 回执 | findings F13 | commit 8bc8e86 | - / 0 / ☑ |
| 12 | 2026-11-15 15:52 | critic | P3-S1 独立复检 R1 轮 | done | 全文回读 9 对象判 CHANGES_REQUESTED（9 项 C-1..C-9）；5 selftest 只读实跑佐证 | review-critic.md | findings F15 | subagent-state/review-critic.md | - / 0 / ☑ |
| 13 | 2026-11-15 16:00 | general-coder | F1a 指针清零+34.8 衔接句（C-1/C-4） | done | grep 'findings F'=0；衔接句=1；diff 无删除行 | fix-f1a.md | findings F15 | commit ff2d992 | - / 0 / ☑ |
| 14 | 2026-11-15 16:00 | general-coder | F1b-mix 候选路径+行位次（C-5/C-8） | done | 候选 39 行结构保持；advisor 行移新域组 grep=1 | fix-f1b.md | findings F15 | commit ff2d992 | - / 0 / ☑ |
| 15 | 2026-11-15 16:00 | general-coder | F2a 枚举回退+注释计数（C-3/C-6） | done | 枚举 7 卫星恢复+路由索引保留；注释 8 个 | fix-f2a.md | findings F15 | commit ff2d992 | - / 0 / ☑ |
| 16 | 2026-11-15 16:00 | general-coder | F2b 幽灵路径+列语义（C-2/C-9） | done | references/ 引用=0/0；§2.1 行语义充实 | fix-f2b.md | findings F15 | commit ff2d992 | - / 0 / ☑ |
| 17 | 2026-11-15 16:00 | general-coder | F3 序数同步（C-7，CA-12） | done | 3 处「第 12 卫星」；sweep 零残留；selftest 13/0 exit 0 | fix-f3.md | findings F15 | commit ff2d992 | - / 0 / ☑ |
| 18 | 2026-11-15 16:20 | code-runner-agent | P3-S2 G2 冒烟 R1 | done | **FAIL→真缺陷**：init 派生类型名 rule-clause-cascade vs 候选双后缀标识→generic 回退；对照探针全过 | smoke-g2.md | findings F17 | subagent-state/smoke-g2.md | - / 0 / ☑ |
| 19 | 2026-11-15 16:20 | code-runner-agent | P3-S3 基线回归对照 | done | 新增 FAIL=0；基线/worktree 各 2 预存 FAIL（T11/T11b B1）一致；97 脚本聚合口径 | regression-s3.md | findings F16/F17 | tmp/regression-tpl-sediment-*.txt | - / 0 / ☑ |
| 20 | 2026-11-15 16:40 | code-runner-agent | G2 复跑（CA-15 修复后） | done | **PASS**：project-level 选中+零残留+五块+指针无污染；advisor 补句 commit 71c97ad | smoke-g2-r2.md | findings F17 | commit 71c97ad | - / 0 / ☑ |
| 21 | 2026-11-15 16:45 | critic | R3 终审 | done | **APPROVED**（C-10/C-11 闭环+R1 不回退+无新回归；NIT-1 非阻断登记 follow-up） | review-critic-r3.md | findings F17 | subagent-state/review-critic-r3.md | - / 0 / ☑ |

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
- 触发信号: 任务类型空缺 → 落 general 兜底（混合型：规则增款+新技能+项目模板）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: **终验定案=不沉淀官方 variant**——本任务类型=技能增强/规则增款，已被 rule-enhancement-type 覆盖面（34.5 查重闸门）；本任务产物本身即沉淀机制（34.8/34.9+advisor），且 dogfood 已产出**首个项目级适配模板** rule-clause-cascade（34.9 位，G1-G3 过门+manifest 登记=CA-8）——沉淀机制以项目级形态首次实弹运行，官方库零污染（30 variant 零改动）→ 指向 plan-template-kit 卫星 SOP
