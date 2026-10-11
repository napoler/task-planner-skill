# Task Plan: Rule 76 总结阶段格式可读性与审查清单实体化纪律（task-v166）
<!-- 
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC（核心问题的可观察解决证据，非手段产物完成）；目标型任务终验必填「🎯 核心目标达成裁决」区块（58.5） -->

- **R1**: 「让我审查内容，为什么不把那需要审查的内容列给我？现在是连有很多很多文件列表都不列给我。这种不符合逻辑的方式根本就是恶意的，因为完全没有把让，没有给用户审核的机会。还有就是其他，如果说需要的话，都需要列出来。」<sub>（[目标]）</sub>
- **R2**: 「我需要的总结以及是执行的任务的总结，以及需要审查的数据的总结以及建议的，还有类似风险之类的全部的内容。」<sub>（[目标]）</sub>
- **R3**: 「格式比较混乱，就是比如说列表1、2、3，现在非常非常让人愤怒的是，是正常的列表或者候选列表之类的，应该是列表的格式展示。但是现在非常非常奇葩的是，用了一个圈1、圈2、圈3，圆圈1、圆圈2、圆圈3这种方式混在一起，让人看着非常头疼。正确的做法就是应该是列表1、2、3这种非常好容易读，又容易区分，为什么不这么做呢？需要优化一下展示格式，确保展示出来的内容是可读的。」<sub>（[目标]）</sub>
- **R4**: 「对于需要审查的图片啊、审查的文件，最好有个专门的列表。专门的列表用于比如说列表文件，文件就是文件的表格、文件名、路径以及简单描述这种。」<sub>（[手段]）</sub>
- **R5**: 「总之我希望最后总结的是，可以更方便用户审查以及了解整个运作详情，以及下一步该做什么的。」<sub>（[目标]）</sub>
- **R6**: 「你看，这就是我发现当前在提交给子代理的提示词中包含的格式，这就说明是这就是问题的关键。以下为示例：## 返回格式## 返回格式 ① v3.1 23 段新配置摘要表（段×mode×refs 槽位）② style_exempt 统一口径 ③ 合图锚占位清单 ④ 段间链锚链图 ⑤ 机械自检输出 ⑥ 待裁项。」<sub>（[手段]）</sub>

> **R6 边界声明（Rule 8.1 划界，8.1 用户裁决 2026-10-10「另立」）**：R6 的「派发/子代理返回格式源」半边（subagent_dispatch.md §7 返回格式段 ①②③ 圆圈枚举）归 **task-v161-subagent-return-format**（已 COMPLETE）治；本任务 v166 只管**用户面总结/呈报**半边。两任务共用用户原话引用，范围不重叠。

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-3 | delivery-summary.md 新增审查清单表格段在位（grep 表头含「文件名」「路径」「描述」）；grep -cE '^76\.[1-6]' critical-rules.md ≥6 |
| R2 | VC-1, VC-2 | Rule 76.4 五要素联动条文落盘；SKILL.md 终验交付段 Rule 76 联动句 grep 命中 |
| R3 | VC-1, VC-3 | 76.2 编号列表规范落盘；image-type.md/multiview-ref-type.md 「Phase N: ①」装饰圈号 grep=0；selftest-summary-readability.sh SRV 断言 PASS |
| R4 | VC-3 | delivery-summary.md 审查清单表格含「文件名/路径/简单描述」三列（grep）+ 报告类条目均可按该三列形态落地 |
| R5 | VC-3, VC-6 | 双审 APPROVED（alignment + code-quality）；模板改造后全部载体可审查性达标 |
| R6 | VC-2 | 边界登记行在位（task_plan 本行 + findings.md 边界段）；v161 覆盖范围 grep 确认无越界改动 subagent_dispatch.md §7 |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 规则层（critical-rules.md） | 规则全集无「展示格式」规范域：Rule 45 只管代码注释完整性；Rule 70 只管呈报内容四要素；用户面列表格式（圆圈枚举 vs 编号列表）无规则约束 | S3 落盘 Rule 76 六子条 | VC-1 |
| 导览层（SKILL.md） | 索引/终验交付段/合规清单无 Rule 76 导览；执行期无格式对照物 | S4/S5 接线四处 + bullet + C54 行 | VC-2 |
| 模板层（delivery-summary.md） | 交付总结无「待审文件/图片专门表格」实体段（文件名/路径/简单描述）；注释指引区 ①-⑤ 编号列表仅注释内（用户面 §5 已用 1. 2. 3. 但无表格段） | S6 审查清单表格段新增 | VC-3 |
| 模板层（variant 媒体审查模板） | image-type.md/multiview-ref-type.md 的 Phase 标题带装饰圈号（「Phase 1: ① 剧本规划」）；用户面审查清单段引用 Rule 70 四要素用圆圈编号 | S7 装饰圈号清除 + Rule 76 引用 | VC-3 |
| 机器守护层（report-lint/selftest） | check-complete report-lint 仅查定位性/三要素/待裁决；无「审查清单表格在位」与「用户面圈号」断言 | S8/S9/S10 扩展 report-lint + 新建 selftest-summary-readability.sh | VC-4 |
| 级联层（selftest 锚纪元） | 9 个脚本硬锚 '1-74'（v162 纪元）待演进 1-76 | S11-S15 逐脚本宽容锚扩展 | VC-5 |

<!-- plan_tier: standard -->
<!-- parallel_groups: [G-review]（S19/S20 双审只读独立组：文件集/资源/输入/验收四问无互依，Rule 21.4 并行默认+声明组；未声明组=串行槽） -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反变不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | 用户需求原文 R1-R6（逐字）；VC-1..VC-7 判定标准；Rule 76 编号（rule-reserve 已登记）；范围边界（v161 管派发/返回格式，v166 管用户面总结）；Rule 70 ①-④ 子条编号引用为合法例外（76.2 但书） | task_plan.md 对应章节锚 |
| 🔀 可变量 | S-unit 拆分细节；级联修顺序；脚本内部断言写法；执行工具选型（在 Executor 声明范围内） | - |
| 📈 学得量 | 格式现状审计结论；级联影响面清单；双审发现；部署位对账数据 → findings.md/notepad-learnings.md；禁反向改写不变量 | findings.md |

## Goal
在用户面总结/呈报载体落地 Rule 76 格式可读性与审查清单实体化纪律——用户拿到任务总结即可直接审查（编号列表 1. 2. 3. 可读 + 待审项表格文件名/路径/简单描述可定位 + 五要素完整 + 无装饰圈号混用），并由 selftest + report-lint 机器守护。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（本任务含 .sh 脚本改动：check-complete.sh + 9 个 selftest 脚本 + 新建 selftest-summary-readability.sh） |
| `session_id` | `<uuid>` | 启动时生成,注册表追踪 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v166-summary-readability` | §十一 隔离决策 |
| `scope_files` | `skills/task-planner/references/critical-rules.md, skills/task-planner/SKILL.md, skills/task-planner/templates/delivery-summary.md, skills/task-planner/templates/variant/image-type.md, skills/task-planner/templates/variant/multiview-ref-type.md, skills/task-planner/scripts/check-complete.sh, skills/task-planner/scripts/selftest-summary-readability.sh, skills/task-planner/scripts/selftest-registry.tsv, skills/task-planner/scripts/selftest-absorption-discipline.sh, skills/task-planner/scripts/selftest-context-pressure.sh, skills/task-planner/scripts/selftest-lane-advancement.sh, skills/task-planner/scripts/selftest-tool-selection.sh, skills/task-planner/scripts/selftest-requirement-coverage.sh, skills/task-planner/scripts/selftest-research-first.sh, skills/task-planner/scripts/selftest-self-resolution.sh, skills/task-planner/scripts/selftest-source-anchor-discipline.sh, skills/task-planner/scripts/selftest-root-resolution.sh, plans/task-v166-summary-readability/*` | 从「执行范围限制」解析 |
| `interaction_mode` | `silent`（自治会话无在线用户；决策点按 Rule 72 分级自动裁决并登记） | Rule 28 交互模式 |
| `对齐审查` | `required`（Rule 42.6：.md 改动完成前跑 alignment-review） | Rule 42.6 |
| `自动超时默认项` | `Rule 44.3 自动裁决：超时值=即时（自治会话）；推荐项=按本计划执行；触发时间=2026-10-11` | Rule 44 |
| `new_rule` | `76` | Rule 20.6（已 reserve） |
| `质量审查工具` | `alignment-review（review-library，review-library/alignment-review/SKILL.md）；code-quality-review（review-library，review-library/code-quality-review/SKILL.md）；selftest-summary-readability.sh（新建机器面）` | Rule 42 消费 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 76 六子条完整落盘 critical-rules.md（76.1-76.6 各锚可 grep；条文含编号列表规范/审查清单表格/五要素联动/边界/守护机制六域） | `grep -cE '^76\.[1-6] ' references/critical-rules.md` ≥6；`grep -qF 'Rule 76（总结阶段格式可读性与审查清单实体化纪律 — task-v166）'` | critical-rules.md Rule 76 段 |
| VC-2 | SKILL.md 接线四处：:9/:305/:394 三处索引 1-74→1-76；Rule 76 摘要 bullet 在位；C54 合规行在位；终验交付段 Rule 76 联动句在位 | `grep -c '1-76' SKILL.md` ≥3；`grep -c 'Rule 76' SKILL.md` ≥5；`grep -qF '| C54 |'` | SKILL.md |
| VC-3 | delivery-summary.md 审查清单表格段在位（表头含「文件名」「路径」「描述」三列）；image-type.md/multiview-ref-type.md「Phase N: ①」装饰圈号 grep=0；全用户面载体无「Phase 1: ①」形态残留 | grep 表头 + `grep -cE 'Phase [0-9]+: [①-⑨]' templates/variant/image-type.md templates/variant/multiview-ref-type.md` =0 | 两 variant 文件 |
| VC-4 | selftest-summary-readability.sh ≥13 断言 PASS rc=0；registry.tsv 登记新行；selftest-registry.sh 自检 PASS | `bash scripts/selftest-summary-readability.sh` → Total PASS=13 FAIL=0 rc=0；registry rows=74 | 脚本输出 |
| VC-5 | 全量回归两轮独立子代理 ΣFAIL=0（主进程逐行独立求和，禁子代理自报汇总）；级联 9 脚本各自 PASS；零新增冲突标记 | `for f in scripts/selftest-*.sh; do bash $f; done` 两轮；`grep -c '^<<<<<<<$' 涉及脚本` =0 | 回归输出 |
| VC-6 | 双审 APPROVED（alignment-review 对 .md 改动 + code-quality-review 对 .sh 改动）；问题清单逐条处置 | 两 checkpoint verdict 行=APPROVED | subagent-state/*.md |
| VC-7 | merge-back merged(commit)；部署位对账 diff=0；rule 76 landed；INDEX 登记；delivery-summary 落盘 | `git log -1 --oneline master`；部署位 diff；`rule-reserve.sh land 76 task-v166-summary-readability` | plans/task-v166-summary-readability/ |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1, R2, R3, R5 |
| **裁决** | （终验时填写） |
| **解决证据锚** | （终验时填写） |
| **未解决面+原因** | （终验时填写） |
| **已排除路径** | （终验时填写） |
| **下一步建议** | （终验时填写） |

> 纯手段型任务（用户只要动作/产物，无问题待解）可填 `n/a（纯手段型任务）`——须与需求区标注一致，禁裸豁免。

## 🎯 Goal 单元表（Rule 66.1 — 规划获批后任务单元固化；standard/full 必填，mini 档豁免）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 格式现状审计 | 摸清用户面载体圈号分布与审查清单缺失面 | findings.md §格式现状审计段落 + 载体清单表 | S1/S2/Phase 1 | pending |
| G2 | 条文落盘 | Rule 76 六子条入 critical-rules.md | `grep -cE '^76\.[1-6] ' references/critical-rules.md` ≥6 | S3/Phase 2 | pending |
| G3 | SKILL 接线 | 索引 1-76 三处 + bullet + C54 + 终验段联动句 | `grep -c 'Rule 76' SKILL.md` ≥5 | S4/S5/Phase 2 | pending |
| G4 | 模板表格化 | delivery-summary 审查清单表格段 | grep 表头三列 | S6/Phase 3 | pending |
| G5 | variant 编号列表化 | 媒体审查模板装饰圈号清零 | grep -cE 'Phase [0-9]+: [①-⑨]' =0（两文件） | S7/Phase 3 | pending |
| G6 | 机器守护 | selftest 新脚本 + report-lint 扩展 + 级联锚扩 | 两轮回归 ΣFAIL=0 | S8-S15/Phase 4 | pending |
| G7 | 双审通过 | alignment + code-quality APPROVED | 两 checkpoint verdict | S19/S20/Phase 5 | pending |
| G8 | 交付合并 | merge-back + land + INDEX + 部署对账 | git log + rule-reserve land | S21/Phase 5 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码（脚本） | skills/task-planner/scripts/check-complete.sh, selftest-summary-readability.sh(新建), selftest-registry.tsv, selftest-absorption-discipline.sh, selftest-context-pressure.sh, selftest-lane-advancement.sh, selftest-tool-selection.sh, selftest-requirement-coverage.sh, selftest-research-first.sh, selftest-self-resolution.sh, selftest-source-anchor-discipline.sh, selftest-root-resolution.sh | 其他 .sh 文件 |
| 文档 | skills/task-planner/SKILL.md, references/critical-rules.md, templates/delivery-summary.md, templates/variant/image-type.md, templates/variant/multiview-ref-type.md, plans/task-v166-summary-readability/* | 其他 .md（含 subagent_dispatch.md §7——v161 边界） |
| 配置 | 无 | 其他配置 |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户（问询按 Rule 70 四要素）

## 📋 变更标注表（Rule 74.3 — 修订方案必填，无表=无效方案）

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 依据（用户原话或证据） | 执行动作 |
|------|------------------|---------------------------|-----------|------------------------|---------|
| CA-1 | references/critical-rules.md：Rule 74 段之后文尾追加区 | 新增 | 增量 | R1/R3/R4 用户原话 | S3 落盘 Rule 76 六子条 |
| CA-2 | SKILL.md:9 索引行 | 更新 | 增量 | 1-74→1-76 纪元演进 | S4 |
| CA-3 | SKILL.md:305 Critical Rules 行 | 更新 | 增量 | 同上 | S4 |
| CA-4 | SKILL.md:394 References 表 critical-rules 行 | 更新 | 增量 | 同上 | S4 |
| CA-5 | SKILL.md Rule 摘要 bullet 区（Rule 72 bullet 后） | 新增 | 增量 | Rule 76 条文 | S5 新增 Rule 76 bullet |
| CA-6 | SKILL.md 终验交付段（Rule 70 四要素行后） | 新增 | 增量 | R3 用户原话 | S5 新增 Rule 76 格式联动句 |
| CA-7 | SKILL.md 合规清单 C 行区（C53 后） | 新增 | 增量 | Rule 76 条文 | S5 新增 C54 行 |
| CA-8 | templates/delivery-summary.md：§2 后新增审查清单表格段；注释指引区编号列表化 | 新增+更新 | 增量 | R1/R4 用户原话 | S6 |
| CA-9 | templates/variant/image-type.md + multiview-ref-type.md：Phase 标题装饰圈号清除 + 审查清单段 Rule 76 引用 | 更新 | 增量 | R3 用户原话 | S7 |
| CA-10 | scripts/check-complete.sh：run_report_lint 扩展 Rule 76 三查 | 更新 | 增量 | R1/R4 用户原话 | S8 |
| CA-11 | scripts/selftest-summary-readability.sh（新建）+ selftest-registry.tsv 登记行 | 新增 | 增量 | Rule 76.6 守护机制 | S9/S10/S11 |
| CA-12 | 9 个 selftest 脚本 '1-74'→'1-76' 宽容锚扩展 | 更新 | 增量 | 索引演进级联 | S12-S16 |
| CA-13 | plans/task-v166-summary-readability/delivery-summary.md 落盘 | 新增 | 增量 | Rule 76.4 五要素 | S21 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | Rule 70 条文（呈报四要素 ①-④ 编号引用为合法例外） | skills/task-planner/references/critical-rules.md Rule 70 段（:913 起） | 必读 | ☑ |
| 规范/标准 | Rule 72 条文（决策分级） | 同上 Rule 72 段（:954 起） | 必读 | ☑ |
| 项目内部文档/知识库 | delivery-summary.md 模板全文 | skills/task-planner/templates/delivery-summary.md | 必读 | ☑ |
| 项目内部文档/知识库 | v160 findings.md 第三条反馈立案材料（5 Whys 根因+用户原话） | plans/task-v160-decision-grading/findings.md §第三条反馈立案材料 | 必读 | ☑ |
| 项目内部文档/知识库 | selftest-report-reviewability.sh 范式（新脚本照此范式） | skills/task-planner/scripts/selftest-report-reviewability.sh | 参考 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 用户面总结/呈报的列表格式混乱（圆圈枚举与数字列表混用）+ 待审文件/图片无专门表格 → 用户拿到总结无法直接审查。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？—— 能：模板+规则+守护三层落地后，终报/总结输出即符合可读可审标准
- [x] 核心问题不解决，其他工作都白费吗？—— 是：v155 修了内容四要素但格式面仍缺，用户第三次同类反馈会复发
- [x] 核心问题的解决方法是清晰的、可执行的？—— 是：Rule 76 六子条 + 模板表格化 + 机器守护，路径明确

## 🔍 证据面清单（Rule 58.1 — 调研/分析/归因类任务计划期必填）

| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | delivery-summary.md / image-type.md / multiview-ref-type.md 用户面段落 | S1/S2 子代理 grep+Read 取证 | findings.md §格式现状审计 | ☐ |
| ② 对标样本（58.2 强制） | v155（Rule 70 内容面）+ v160（Rule 72 决策面）两次同类反馈修法先例 | findings.md 先例段引用 | findings.md §先例 | ☑ |
| ③ 外部约束 | 用户 2026-10-10 第三条反馈原话（v160 findings 立案材料） | 逐字引用 | plans/task-v160-decision-grading/findings.md §第三条反馈 | ☑ |

> 归因类结论在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
Phase 5（complete — 全部 VC PASS，outcome: COMPLETE）

## Next Step
任务已完成（COMPLETE，merge 0d57483）：Check-complete 全门复验+主仓提交 plans 簿记（check-complete.sh exit 0 后）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore(mini) + general-purpose(sonnet-1) | 跨多文件 grep+Read 取证，隔离上下文防污染主进程 |
| Phase 2 | Agent 子代理 executor(sonnet-1) | 条文落盘+S-unit 批量接线，机械执行 |
| Phase 3 | Agent 子代理 code-assistant(haiku-1) ×3 | 模板面小改（≤2 文件/次），轻量档够用 |
| Phase 4 | Agent 子代理 executor(sonnet-1) + code-runner-agent(mini) | 脚本级联修+跑批，机械重复 |
| Phase 5 | Agent 子代理 code-reviewer(sonnet-1) + general-purpose(sonnet-1) + 主进程 | 双审独立视角；合并回+簿记主进程直做 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件 → 按 Rule 21.4 独立性守门调度（并行默认+声明组，未声明=串行）。本计划声明 1 个并行组 `[parallel-group:G-review]`（S19/S20 双审，只读独立）。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 的证据源。

## Phases

### Phase 1: Requirements & Discovery（格式现状审计）
- [ ] 审计用户面载体圈号分布与审查清单缺失面
- [ ] 确认 v161 边界（subagent_dispatch.md §7 归属 v161）
- [ ] 落盘 findings.md §格式现状审计
- [ ] 知识储备必读项已确认可获取（勾选「必要知识储备」表"已确认"列）
- **V-N:** VC-1, VC-3
- **Status:** complete
- **Executor:** Explore

<!-- S-unit 派发单元表(Rule 22.6) -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 审计用户面总结载体格式现状：delivery-summary.md 全文+注释指引区圈号分布+审查清单缺失面+SKILL.md 终验交付段引用形态 → findings.md §格式现状审计 | explore(mini) | skills/task-planner/templates/delivery-summary.md + skills/task-planner/SKILL.md（终验交付段 grep "Rule 70"/"Rule 76"） | findings.md 新增 §格式现状审计 段落（≥15 行：载体清单表+圈号分布+缺失面） | 15min | 0f/0l/15min | 无 | - | pending |
| S2 | 审计 variant 媒体审查模板圈号分布（image-type/multiview-ref）+ v161 边界确认（subagent_dispatch.md §7 圈号归属） → findings.md §variant 审计 | explore(mini) | skills/task-planner/templates/variant/image-type.md + skills/task-planner/templates/subagent_dispatch.md（§7 返回格式段 grep ①） | findings.md 追加 §variant 审计 段落（含两文件圈号行号清单+v161 边界确认行） | 15min | 0f/0l/15min | 无 | - | pending |

### Phase 2: Planning & Structure（Rule 76 条文落盘 + SKILL 接线）
- [ ] Rule 76 六子条写入 critical-rules.md（Rule 74 段之后，禁硬编码行号锚）
- [ ] SKILL.md 接线四处：索引 1-74→1-76（三处）+ Rule 76 bullet + C54 行 + 终验段联动句
- [ ] 互引补链：Rule 70/72 条文段补 Rule 76 指针
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S3 | Rule 76 六子条写入 critical-rules.md 文尾（Rule 74 段之后追加，不硬编码行号锚；条文=本计划 §Rule 76 条文草案 逐字采用） | executor(sonnet-1) | skills/task-planner/references/critical-rules.md + plans/task-v166-summary-readability/task_plan.md（§Rule 76 条文草案） | `grep -cE '^76\.[1-6] ' references/critical-rules.md` ≥6 且 `grep -qF 'Rule 76（总结阶段格式可读性与审查清单实体化纪律 — task-v166）'` | 15min | 1f/60l/15min | 无 | - | pending |
| S4 | SKILL.md 接线一：:9/:305/:394 三处 1-74→1-76 + 规则名清单加 76 条目 + References 表 critical-rules 行同步 | executor(sonnet-1) | skills/task-planner/SKILL.md + plans/task-v166-summary-readability/task_plan.md（§接线材料包） | `grep -c '1-76' SKILL.md` ≥3 且 `grep -qF '76 总结阶段格式可读性与审查清单实体化纪律'` | 15min | 1f/12l/10min | 无 | S3 | pending |
| S5 | SKILL.md 接线二：Rule 76 摘要 bullet（Rule 72 bullet 后）+ 终验交付段 Rule 76 联动句 + C54 合规行 + Rule 70/72 条文段互引指针 | executor(sonnet-1) | skills/task-planner/SKILL.md + plans/task-v166-summary-readability/task_plan.md（§接线材料包） | `grep -c 'Rule 76' SKILL.md` ≥5 且 `grep -qF 'C54' SKILL.md` 且 `grep -qF '总结阶段格式可读性与审查清单实体化纪律 — task-v166' SKILL.md` | 15min | 1f/15l/10min | 无 | S3 | pending |

### Phase 3: Implementation（模板面改造）
- [ ] delivery-summary.md：审查清单表格段新增 + 注释指引区编号列表化
- [ ] image-type.md/multiview-ref-type.md：Phase 标题装饰圈号清除 + 审查清单段 Rule 76 引用
- [ ] check-complete.sh report-lint 扩展 Rule 76 三查
- **V-N:** VC-3, VC-4
- **Status:** complete
- **Executor:** code-assistant

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S6 | delivery-summary.md 改造：§2 后新增「## 3. 审查清单（待审文件/图片/数据）」表格段（文件名｜路径｜简单描述三列+审查看点列）；注释指引区 ①-⑤ 枚举改编号列表（Rule 70 ①-④ 子条引用保留不动） | code-assistant(haiku-1) | skills/task-planner/templates/delivery-summary.md + plans/task-v166-summary-readability/task_plan.md（§审查清单表格段草案） | grep 表头含「文件名」「路径」「描述」三列；§3 段落标题存在 | 10min | 1f/25l/10min | 无 | S3 | pending |
| S7 | image-type.md 与 multiview-ref-type.md：Phase 标题「Phase N: ①」装饰圈号清除（改「Phase N.」）；审查地址清单段补 Rule 76 引用（编号列表+表格指引） | code-assistant(haiku-1) | skills/task-planner/templates/variant/image-type.md + skills/task-planner/templates/variant/multiview-ref-type.md | 两文件 `grep -cE 'Phase [0-9]+: [①-⑨]'` =0；`grep -c 'Rule 76'` 各 ≥1 | 8min | 2f/15l/8min | 无 | S3 | pending |
| S8 | check-complete.sh run_report_lint 扩展 Rule 76 三查：①审查清单表格段在位（delivery-summary §3 表头三列）②用户面圈号负断言（variant 两文件 Phase 装饰圈号=0）③占位符残留检查（<待补>/<TODO> 形态） | code-assistant(haiku-1) | skills/task-planner/scripts/check-complete.sh + plans/task-v166-summary-readability/task_plan.md（§report-lint 扩展草案） | 脚本内 `grep -q 'Rule 76'` ≥1；bash -n 通过；自跑 exit 0（fail-open 恒 0） | 15min | 1f/40l/15min | 无 | S6,S7 | pending |

### Phase 4: Testing & Verification（机器守护 + 两轮回归）
- [ ] selftest-summary-readability.sh 新建（SRV-01..13）+ registry 登记
- [ ] 9 个 selftest 脚本 1-74→1-76 宽容锚扩展
- [ ] 全量回归 round 1 + 条件修 FAIL
- [ ] 独立子代理回归 round 2
- **V-N:** VC-4, VC-5
- **Status:** complete
- **Executor:** executor

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S9 | 新建 scripts/selftest-summary-readability.sh 上半（SRV-01..07：Rule 76 条文锚+SKILL 接线锚+delivery-summary 表格段锚+variant 圈号负断言；范式=selftest-report-reviewability.sh） | executor(sonnet-1) | skills/task-planner/scripts/selftest-report-reviewability.sh + plans/task-v166-summary-readability/task_plan.md（§守护断言清单） | 脚本存在且 `bash -n` 通过；头部含 SRV-01..07 断言定义 | 15min | 1f/90l/15min | 无 | S3,S4,S5 | pending |
| S10 | 追加上半（SRV-08..13：report-lint 扩展锚+registry 登记断言+config 零新键+负断言守护）+chmod+x+自跑 | executor(sonnet-1) | skills/task-planner/scripts/selftest-summary-readability.sh + plans/task-v166-summary-readability/task_plan.md | 自跑 `Total: 13 PASS=13 FAIL=0` rc=0 | 10min | 1f/70l/10min | 无 | S9 | pending |
| S11 | selftest-registry.tsv 登记新行（selftest-summary-readability.sh 行）+ selftest-root-resolution.sh 的 1-74 锚宽容扩展 | executor(sonnet-1) | skills/task-planner/scripts/selftest-registry.tsv + skills/task-planner/scripts/selftest-root-resolution.sh | registry rows=74（73+1）；selftest-registry.sh PASS；root-resolution 自跑 PASS | 10min | 2f/12l/10min | 无 | S10 | pending |
| S12 | selftest-absorption-discipline.sh（AD-04 三处 1-74→1-76 + AD-12 pin）+ selftest-context-pressure.sh（CP-07）宽容锚扩展 | executor(sonnet-1) | skills/task-planner/scripts/selftest-absorption-discipline.sh + skills/task-planner/scripts/selftest-context-pressure.sh | 两脚本自跑 PASS rc=0；两脚本 `grep -cE '1-7[4-9]'` 各 ≥1 | 10min | 2f/10l/10min | 无 | S4 | pending |
| S13 | selftest-lane-advancement.sh（LA-12）+ selftest-tool-selection.sh（TS-05）宽容锚扩展 | executor(sonnet-1) | skills/task-planner/scripts/selftest-lane-advancement.sh + skills/task-planner/scripts/selftest-tool-selection.sh | 两脚本自跑 PASS rc=0 | 10min | 2f/10l/10min | 无 | S4 | pending |
| S14 | selftest-requirement-coverage.sh + selftest-research-first.sh（RF-06/RF-07）宽容锚扩展 | executor(sonnet-1) | skills/task-planner/scripts/selftest-requirement-coverage.sh + skills/task-planner/scripts/selftest-research-first.sh | 两脚本自跑 PASS rc=0 | 10min | 2f/10l/10min | 无 | S4 | pending |
| S15 | selftest-self-resolution.sh（SR-07）+ selftest-source-anchor-discipline.sh（SA-07）宽容锚扩展 | executor(sonnet-1) | skills/task-planner/scripts/selftest-self-resolution.sh + skills/task-planner/scripts/selftest-source-anchor-discipline.sh | 两脚本自跑 PASS rc=0 | 10min | 2f/10l/10min | 无 | S4 | pending |
| S16 | worktree 内全量 selftest 跑批（for f in selftest-*.sh）+FAIL 清单落盘 subagent-state 检查点 | general-purpose(sonnet-1) | skills/task-planner/scripts/selftest-*.sh（跑批，禁逐文件罗列） | 输出含每脚本 PASS/FAIL 与 ΣFAIL 计数（逐行列出，禁自报汇总） | 15min | 0f/0l/15min | 无 | S11-S15 | complete |
| S17 | （条件：ΣFAIL>0）按 FAIL 清单修锚级联 | executor(sonnet-1) | 条件不触发：S16 实测 ΣFAIL=0（76/76 exit=0）→ 跳过 | 跳过（条件未触发） | 0min | 0f/0l/0min | 无 | S16 | skipped |
| S18 | 独立子代理回归 round 2（验证独立性：全新上下文重跑全量+核对两轮 FAIL=0） | code-runner-agent(mini) | skills/task-planner/scripts/selftest-*.sh（跑批）+ plans/task-v166-summary-readability/subagent-state/（S16/S17 检查点路径） | 输出含每脚本 PASS/FAIL 与 ΣFAIL 计数；round1 vs round2 一致性结论行 | 15min | 0f/0l/15min | 无 | S17 | complete |

### Phase 5: Delivery（双审 + 合并回 + 簿记）
- [x] 双审（alignment + code-quality）：CHANGES_REQUESTED×2 → fix-wave1/2 逐条闭合 → round5/终跑 77/77 复验
- [x] merge-back merged(0d57483) --deploy（部署位 IDENTICAL）+ rule 76 land + INDEX 登记
- [x] delivery-summary 落盘
- **V-N:** VC-6, VC-7
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S19 | 代码面审查：worktree 内 git diff 的 .sh 改动（check-complete + 新脚本 + 9 级联），输出 APPROVED/CHANGES_REQUESTED+逐条 file:line [parallel-group:G-review] | code-reviewer(sonnet-1) | worktree 内 skills/task-planner/scripts/*.sh（本次改动 12 文件，执行期给 git diff 基线） | checkpoint 落 verdict 行 | 15min | 0f/0l/15min | 无 | S18 | complete |
| S20 | 对齐面审查：按 review-library/alignment-review/SKILL.md 对全部 .md 改动跑对齐审查，输出 verdict+问题清单 [parallel-group:G-review] | general-purpose(sonnet-1) | skills/task-planner/review-library/alignment-review/SKILL.md + worktree git diff（.md 集合） | checkpoint 落 verdict 行 | 15min | 0f/0l/15min | 无 | S18 | complete |
| S21 | （条件：CHANGES_REQUESTED）逐条修复→复验 + master 并集解（S25-S28：Rule 75+76 共存/索引 1-76/C54C55/SRV 钉值/P-05 上界对齐）→ merge-back 0d57483 --deploy + rule 76 land + INDEX 登记 + delivery-summary 落盘 | code-assistant(haiku-1)+code-runner-agent(mini)+主进程 | 双 checkpoint CHANGES 清单 + master 冲突态 10 文件 | 12 条问题闭合+77/77 回归 0 FAIL+merge 0d57483+deploy IDENTICAL+land 输出 | 15min | 2f/80l/15min | 无 | S19,S20 | complete |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | （check-conflicts.sh 扫描后回填） |
| `isolation` | `worktree`（实现类默认首选） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v166-summary-readability` |
| `branch` | `wt/task-v166-summary-readability` |
| `merge_back` | `merged(0d57483)` |

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2 | 并行任务占编号致 Rule 76 撞号 | 6 | 4 | 2 | 48 | rule-reserve.sh 查重；撞号→改号+findings 登记 |
| Phase 3 | 级联面低估（新 selftest 脚本引用 1-74） | 7 | 5 | 3 | 105 | 兜底：S16 跑批 FAIL 清单驱动 S17 修；grep 全脚本 '1-74\|1-7[0-9]' 预扫描补漏 |
| Phase 4 | 回归 FAIL 反复修不收敛 | 7 | 4 | 3 | 84 | 兜底：≥3 轮不收敛→主进程接管+findings 根因登记 |
| Phase 5 | 双审 CHANGES_REQUESTED 循环 | 6 | 4 | 2 | 48 | 兜底：逐条修复≤2 文件/轮；3 轮不收敛→用户决策 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填。

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-11 | TodoWrite 6 项 |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |

## Key Questions
1. 用户面载体白名单边界在哪？（答：delivery-summary + image-type + multiview-ref + SKILL.md 终验交付段；其余 variant 模板列入后续轮次）
2. Rule 70 ①-④ 子条编号引用与 76.2 禁圈号的关系？（答：76.2 但书——引用既有规则子条编号合法；仅禁止用圈号承载新枚举）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| R6 边界：派发/返回格式源归 v161，v166 只管用户面总结 | 用户 2026-10-10「另立」裁决；v161 已 COMPLETE |
| Rule 76 但书：Rule 70 ①-④ 子条引用不受 76.2 禁圈号约束 | 规则子条编号是合法引用，非枚举承载 |
| 用户面载体白名单：delivery-summary + image-type + multiview-ref 三个先行 | 匹配用户「审查的图片/文件」原话；其余 variant 列后续轮次 |
| 双审并行组 [G-review] | S19/S20 只读独立，Rule 21.4 并行默认+声明组 |
| 级联修按 2 文件/批分 5 个 S-unit | Rule 59 粒度硬门（≤2 文件/100 行/15min） |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- Never repeat a failed action - mutate your approach instead

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）
| 字段 | 值 |
|------|-----|
| `total` | n/a（chain_mode=single 非批量 fan-out；双审 2 单元为 Rule 21.4 并行组非 Rule 18.6 批量门控对象） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a（非批量任务无批量失败率口径） |
| `sampled_pass` | n/a（无 10% 抽样面；等价覆盖=全量 77/77 脚本两轮独立回归） |
| `sampled_fail` | n/a（无 ground-truth 抽检面；等价替代=726 断言 0 FAIL） |
| `pre_check` | Q1:否（无逐单元独立判断批量面）Q2:有（grep/夹具/rc 客观验收）Q3:能（git revert 0d57483+部署位重对账） |
| `rollback_point` | merge 前基线 master 39c41fa；部署位快照=smart-merge-back --deploy staging 机制 |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（Phase 1 Explore / Phase 3 code-assistant / Phase 4 executor；S-unit 全部经 28 次子代理派发执行） |
| 主进程直做 Phase 清单 | Phase 2, Phase 5（例外理由② 计划系统文件维护+① git 编排② 簿记——Rule 25.3 白名单） |
| 委派率 | 0.600——check-delegation.sh stats verdict=ok violations=0；低于 floor 0.7 但两个主进程直做 Phase 均命中 Rule 25.3 六项白名单 → WHITELIST-EXEMPT 放行（Rule 25.4） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 01:45 | Explore | 审计 delivery-summary+SKILL 终验段格式现状 | done | 3/3：审查清单表格段缺失实锤/§5 已编号/C 行止 C53 | delivery-summary.md:10-15,73-75 | findings §sub:1-explore | subagent-state/1-explore.md | - / 0 / ☑ |
| 2 | 01:50 | Explore | 审计 variant 圈号分布+v161 边界确认 | done | 3/3：image=7/multiview=5/v161 归属确认；代理无写权限由主进程代落盘 | image-type.md:43-88 | findings §sub:2-explore | subagent-state/2-explore.md | - / 0 / ☑ |
| 3 | 02:10 | executor | Rule 76 六子条写入 critical-rules.md | done | 3/3：六子条 6+标题 em-dash+六域齐 | critical-rules.md:1003-1018 | 不适用 | subagent-state/3-executor.md | - / 0 / ☑ |
| 4 | 02:25 | executor | SKILL.md 索引三处 1-74→1-76+规则名清单 | done | 4/4：1-76×3/76 条目×3/Rule76×3/1-74 残留 0 | SKILL.md:9/305/394 | 不适用 | subagent-state/4-executor.md | - / 0 / ☑ |
| 5 | 02:40 | executor | SKILL.md bullet+联动句+C54+互引指针 | done | 6/6：Rule76×6/C54/联动句/互引×2 | SKILL.md:373/177/240 | 不适用 | subagent-state/5-executor.md | - / 0 / ☑ |
| 6 | 03:25 | code-assistant | delivery-summary 审查清单表格段+编号顺延 | done | 4/4：§3 三列表/§1-6 连续/注释圈号 0/Rule54.1③ 保留 | delivery-summary.md:51-55 | 不适用 | subagent-state/6-code-assistant.md | - / 0 / ☑ |
| 7 | 04:05 | code-assistant | variant Phase 装饰圈号清除+Rule 76 引用 | done | 4/4*：装饰圈号 0/0、Rule76 各 1（multiview 无「约束19」系原态） | image:43-86/mv:32-56 | 不适用 | subagent-state/7-code-assistant.md | - / 0 / ☑ |
| 8 | 04:20 | code-assistant | check-complete report-lint 扩展 Rule 76 三查 | done | 4/4：Rule76×8/bash-n/ harness 四态 RC=0/既有三查保留 | check-complete.sh:992-1033 | 不适用 | subagent-state/8-code-assistant.md | - / 0 / ☑ |
| 9 | 05:50 | executor | 新建 selftest-summary-readability.sh 上半 | done | 4/4：SRV-01..08/chmod/bash-n/Total 计数 | selftest-summary-readability.sh | 不适用 | subagent-state/9-executor.md | - / 0 / ☑ |
| 10 | 06:10 | executor | selftest 追加上半+自跑 | partial | 11P/2F：SRV-11 registry 未登记+SRV-12 级联未完成（预期，归 S11-S15） | 自跑 Total: PASS=11 | 不适用 | subagent-state/10-executor.md | - / 0 / ☑ |
| 11 | 06:25 | executor | registry 登记+root-resolution 锚扩 | done | 4/4：rows=76/RR 17/17/1-74=0/NF=4 | registry.tsv; root-resolution:181 | 不适用 | subagent-state/11-executor.md | - / 0 / ☑ |
| 12 | 07:00 | executor | absorption+context-pressure 级联（首跑） | failed | 输出失控 202KB 推理循环+4 处半成品破坏在盘+未落检查点 | 主进程读盘接管 | 不适用 | subagent-state/12-executor.md（主进程补） | rescue=主进程接管 → 补派 code-assistant 完成 / 1 / ☑ |
| 12b | 07:20 | code-assistant | absorption+context-pressure 级联（续修） | done | 5/5：-cF=0/-cE=3/新族=5/bash-n 双 OK/CP 9-9 | absorption:60,70,72; CP:101-110 | 不适用 | subagent-state/12-executor.md | rescue 续跑 / 0 / ☑ |
| 13 | 08:10 | executor | lane-advancement+tool-selection 级联 | done | 4/4：LA 14/14+TS 12/12+1-74=0 | lane:139; tool:66 | 不适用 | subagent-state/13-executor.md | - / 0 / ☑ |
| 14 | 08:25 | executor | requirement-coverage+research-first 级联 | done | 4/4：RC 23/23+RF 12/12+AD-12 pin 兼容 | RC:135; RF:75,77 | 不适用 | subagent-state/14-executor.md | - / 0 / ☑ |
| 15 | 08:40 | executor | self-resolution+source-anchor 级联 | done | 4/4：SR 13/13+SA 12/12+SA-07 -cE 形态 | SR:83; SA:39 | 不适用 | subagent-state/15-executor.md | - / 0 / ☑ |
| 16 | 09:00 | general-purpose | worktree 全量回归 round1（code-runner provider 两连败改派） | done | 76/76 exit=0 ΣFAIL=0 | 跑批输出 | 不适用 | subagent-state/16-code-runner-agent.md | provider 失败改派（22.3①）/ 0 / ☑ |
| 17 | 09:05 | 跳过 | （条件：ΣFAIL>0）级联修 | skipped | 条件不触发：round1 ΣFAIL=0 | progress Phase 4 | 不适用 | 不适用 | 条件未触发 / 0 / n/a |
| 18 | 09:20 | code-runner-agent | 独立回归 round2 | done | 76/76，与 round1 Total 行 BYTE-IDENTICAL | round2 输出 | 不适用 | subagent-state/18-code-runner-agent.md | - / 0 / ☑ |
| 19 | 10:30 | code-reviewer | 代码面审查（.sh 改动 12 文件） | done | CHANGES_REQUESTED：5 条（F1 弱守卫/F2 BRE 死守卫/F3 头注/F4 变量/F5 簿记） | verdict+file:line 清单 | 不适用 | subagent-state/19-code-reviewer.md | - / 0 / ☑ |
| 20 | 10:35 | general-purpose | 对齐面审查（.md 5 文件） | done | CHANGES_REQUESTED：7 条（P0 段号锚漂移+P1×3+P2×3） | verdict+file:line 清单 | 不适用 | subagent-state/20-general-purpose.md | - / 0 / ☑ |
| 21a | 11:00 | code-assistant | fix-wave1: check-complete P0 段号锚+变量清理 | done | 4/4：双形态锚/§6 夹具 warn/旧 §5 不误报 | check-complete.sh:976/979/1033 | 不适用 | subagent-state/21a-code-assistant.md | - / 0 / ☑ |
| 21b | 11:10 | executor | fix-wave1: SRV-07 锚定+BRE 死守卫+头注 | done | 4/4：夹具 FAIL×2/自跑 13/13/bash-n | selftest-summary-readability.sh:99-108,117,125,174 | 不适用 | subagent-state/21b-executor.md | - / 0 / ☑ |
| 21c | 11:20 | executor | fix-wave1: critical-rules 三处演进注 | done | 4/4：:885/:954 1-76+1005 C51/C54 | critical-rules.md:885/954/1005 | 不适用 | subagent-state/21c-executor.md | - / 0 / ☑ |
| 21d | 11:25 | code-assistant | fix-wave1: image-type:21 顿号化+SKILL 40-76 | done | 4/4（改动经主进程独立复核为真；子代理 checkpoint 路径 typo 误报，主进程补落） | image:21; SKILL:307 | 不适用 | subagent-state/21d-code-assistant.md（主进程补落） | checkpoint 补落留痕 / 0 / ☑ |
| 22 | 13:30 | code-runner-agent | round3 回归+12 条问题闭合验收 | partial | 70/76：21d 触发 5 旧容差锚 FAIL（第二轮级联）+P2-b 登记缺位 | 跑批+闭合表 | findings §闭合台账 | subagent-state/22-code-runner-agent.md | 级联暴露→fix-wave2 / 0 / ☑ |
| 23a | 14:00 | executor | fix-wave2: DCS-11+EH-09 锚 | done | 4/4：DCS 20/20+EH 14/14 | DCS:63; EH:98 | 不适用 | subagent-state/23a-executor.md | - / 0 / ☑ |
| 23b | 14:10 | executor | fix-wave2: RF-07+RR-16 锚 | done | 4/4：RF 12/12+RR 17/17 | RF:77; RR:181 | 不适用 | subagent-state/23b-executor.md | - / 0 / ☑ |
| 23c | 14:20 | executor | fix-wave2: SR-08 锚 | done | 4/4：SR 13/13+SRV-12 复验 9/9 | SR:94 | 不适用 | subagent-state/23c-executor.md | - / 0 / ☑ |
| 24 | 15:30 | general-purpose | 最终回归 round4（code-runner provider 失败改派） | done | 76/76 rc=0 ΣFAIL=0+点名三脚本复核 | 跑批输出 | 不适用 | subagent-state/24-code-runner-agent.md | provider 失败改派（22.3①）/ 0 / ☑ |
| 25 | 16:00 | code-assistant | master 合并 10 文件冲突并集解（Rule 75+76 共存/索引/C54C55/7 脚本锚） | done | 4/4：冲突标记 0/SKILL 1-77×3（后修正 1-76）/六子条 6+75 七子条/九脚本自跑 | 冲突块逐处 file:line | 不适用 | subagent-state/25-code-assistant.md | 任务书外置 25-prompt.md（Rule 35.3）/ 0 / ☑ |
| 26 | 16:10 | executor | SRV-03/SRV-05 钉值随并集 epoch 修正 | done | 4/4：自跑 13/13；SRV-03 宽容 1-7[4-9]；SRV-05 C55+关键词 | selftest-summary-readability.sh | 不适用 | subagent-state/26-executor.md | - / 0 / ☑ |
| 27 | 16:20 | general-purpose | 并集后 round5 回归（77 脚本；code-runner provider 失败改派） | partial | 70/76+PR15：暴露 P-05 索引上界误配（skill=77 vs crit=76）→sub:28 修复 | 跑批+FAIL 明细 | 不适用 | subagent-state/27-code-runner-agent.md | 暴露第二轮并集问题 / 0 / ☑ |
| 28 | 16:25 | code-assistant | 并集索引上界修正 1-77→1-76 | done | 4/4：1-77=0/1-76=3；P-05 PASS 9/9；75/76 名目+C54C55 未动 | SKILL.md:9/308/399 | 不适用 | subagent-state/28-code-assistant.md | - / 0 / ☑ |
| 29 | 16:40 | general-purpose | 合并前最终回归（code-runner provider 失败改派） | done | 77/77 rc=0，断言合计 726 PASS/0 FAIL | 跑批+点名三脚本 | 不适用 | subagent-state/29-code-runner-agent.md | provider 失败改派（22.3①）/ 0 / ☑ |

## 🔗 Chain 区块交接配置（可选）

### Chain 模式
| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
| **current_block** | Block 1 |
| **handoff_on_complete** | ❌ 否 |

### Block 1: 本任务（当前块）
| 字段 | 值 |
|------|-----|
| **goal** | Rule 76 用户面总结格式可读性与审查清单实体化落地 |
| **depends_on** | none |
| **passes_to** | 无 |
| **status** | in_progress |

### 🔗 Handoff 追踪表
| Block | 状态 | 交接产物路径 | 验证命令 | 实际完成时间 |
|-------|------|------------|---------|-------------|
| Block 1 | - | - | - | - |

<!-- ★ Block 分隔符：每个独立交接区块下方用 --- 分隔 -->
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP

---

## §Rule 76 条文草案（S3 逐字采用）

> 位置：critical-rules.md 文尾，Rule 74 段之后。六子条编号 76.1-76.6。

```markdown
## Rule 76（总结阶段格式可读性与审查清单实体化纪律 — task-v166）

> 用户面总结/呈报要「可直接审查」——内容易读（编号列表）之外，待审实体必须表格化可定位；与 Rule 70（列什么）互补，本规则管「怎么列」。

**76.1 适用范围**：所有用户面总结/呈报载体 = delivery-summary.md 模板及其产出、会话终报/Phase 汇报、AskUserQuestion 选项与候选列表、报告类任务面向用户的输出段。范围外（不适用）：机器面字段（checkpoint 8 字段块）、脚本内部步骤枚举注释、派发/子代理返回格式（Rule 22.4b/task-v161 治）。

**76.2 列表格式规范**：① 列表一律用编号列表（1. 2. 3.）或无序列表（-）；② 禁止 ①②③④ 圆圈数字与「1）2）」全角数字编号在用户面承载枚举；③ 同一份总结内列表格式统一，禁混用；④ 批准候选/选项也用编号列表承载。**但书**：引用既有规则子条编号（Rule 70 的 ①-④、72.4 等）不受本条约束——那是引用不是枚举承载。

**76.3 审查清单实体化**：凡需用户审查的文件/图片/网页/数据，必须给专门表格（文件名｜路径｜简单描述三列起步，可加审查看点列）；文件名字禁裸名（须带路径形态，Rule 48.2 联动）；图片可加缩略图/MIME 说明。

**76.4 总结内容五要素（Rule 48/70 联动，缺一即 report-lint warn）**：任务执行总结、产出清单、待审数据清单（76.3 表格）、建议（含默认项）、风险（含失效条件）——用户面总结不得以「见某文件」替代待审清单本身。

**76.5 边界（parallel 分治）**：派发/子代理返回格式污染（subagent_dispatch.md §7 ①②③）归 Rule 22.4b + task-v161-subagent-return-format；本规则不越界改派发模板字段结构，只在 v161 修正后对用户面引用。

**76.6 守护机制**：selftest-summary-readability.sh（SRV 断言）+ check-complete.sh report-lint 扩展（审查清单表头在位数/占位符残留/圈号混用负断言三查）；selftest-registry.tsv 登记；fail-open warn 档，enforce 由 config 收编。
```

## §接线材料包（S4/S5 逐字采用）

**Rule 76 摘要 bullet**（置于 Rule 72 bullet 之后）：
```
- **Rule 76（总结阶段格式可读性与审查清单实体化纪律 — task-v166）**：用户面总结/呈报列表一律编号列表 1. 2. 3.（禁①②③圆圈枚举与数字列表混用，76.2）；待审文件/图片/数据须表格化（文件名/路径/简单描述，76.3）；总结五要素=执行总结+产出清单+待审数据清单+建议+风险（76.4）；机器面=selftest-summary-readability.sh，零新 config 键（76.6）（详见 references/critical-rules.md Rule 76）
```

**终验交付段联动句**（置于「会话内一切其他呈报（审批/审查/确认/升级/熔断报告）按 Rule 70 四要素输出」行后）：
```
  - 用户面总结/呈报的列表一律编号列表 1. 2. 3.（禁①②③圆圈枚举与数字列表混用，Rule 70/72 规则子条编号引用除外）；待审文件/图片/数据须表格化（文件名/路径/简单描述，Rule 76）
```

**C54 合规行**（置于 C53 行后）：
```
| C54 | 总结格式可读性与审查清单自查（Rule 76）：用户面总结/呈报列表一律编号列表 1. 2. 3.（禁①②③圆圈枚举混用，规则子条引用除外）；待审文件/图片/数据已表格化（文件名/路径/简单描述）；总结含五要素（执行总结+产出清单+待审数据清单+建议+风险）（机器面=selftest-summary-readability.sh 静态断言+check-complete report-lint，格式内容人工核查；mini 档豁免） | ☐ |
```

**Rule 70/72 互引指针**（各自条文末尾追加半句）：
- Rule 70 段末：「——用户面列表格式与审查清单表格化见 Rule 76」
- Rule 72 段末：「——用户面呈报格式（编号列表+审查清单表格）见 Rule 76」

## §审查清单表格段草案（S6 逐字采用）

位置：delivery-summary.md §2 产出清单之后，新增独立段：

```markdown
## 3. 审查清单（待审文件/图片/数据 — Rule 76.3）
> 凡需用户审查的文件/图片/网页/数据，逐项列此表；文件名字禁裸名（Rule 48.2）。

| 文件名 | 路径（绝对路径或仓内路径+定位栏仓库根） | 简单描述（一句话：这是什么+审查看点） |
|--------|---------------------------------------|--------------------------------------|
| （示例）image-001.png | /abs/path/to/image-001.png | 第 1 批次首图，审查看点：主体一致性+构图缺陷 |
```

（注：原 §3 审查信息及后续段落顺延编号；模板内段落编号为占位，S6 执行时按实际结构调整。）

## §守护断言清单（S9/S10 执行依据）

SRV-01: critical-rules.md 含 'Rule 76（总结阶段格式可读性与审查清单实体化纪律 — task-v166）' 标题
SRV-02: critical-rules.md 76.1-76.6 六子条锚各 ≥1（grep -cE '^76\.[1-6] ' ≥6）
SRV-03: SKILL.md '1-76' ≥3 处
SRV-04: SKILL.md 'Rule 76' ≥5 处
SRV-05: SKILL.md C54 行在位
SRV-06: SKILL.md 终验段 Rule 76 联动句在位
SRV-07: delivery-summary.md 审查清单表格段表头含「文件名」「路径」「描述」
SRV-08: image-type.md 'Phase N: ①' 装饰圈号 =0
SRV-09: multiview-ref-type.md 'Phase N: ①' 装饰圈号 =0
SRV-10: check-complete.sh run_report_lint 含 'Rule 76' 检查 ≥1
SRV-11: selftest-registry.tsv 含 selftest-summary-readability.sh 行且 selftest-registry.sh PASS
SRV-12: 9 级联脚本各自自跑 PASS（for f in 9 脚本; do bash $f; done）
SRV-13: 负断言守护——全 skill 树 grep 'Phase [0-9]+: [①-⑨]' 在用户面白名单载体 =0
