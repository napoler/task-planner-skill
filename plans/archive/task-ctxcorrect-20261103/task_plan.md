# Task Plan: 上下文否定纠正机制固化
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

- **R1**: 「当用户明确提出来有错误或者需要纠正的时候，主动触发对上下文以及历史文档的整理，因为在用户提提提提到明确提到否定的时候，那么就意味着上下文或者说记录的相关文档中存在着明显的缺陷。如果后期继续使用这些明显存在缺陷的上下文以及相应的文档的话，那么肯定只会导致还会犯错，也就是说错误继续污染真正的工作。」<sub>（[手段]—触发面一的需求描述）</sub>
- **R2**: 「我希望可以将这个整理机制固化为专业的技能，在需要的地方触发整理。」<sub>（[目标]—制度层交付物=专业技能+触发点接线，非修某具体实例）</sub>
- **R3**: 「Agent在自主执行的时候，发现是前后文矛盾的时候，也需要触发这种整理机制。」<sub>（[手段]—触发面二的需求描述）</sub>
- **R4**: 「改造相关的技能步骤，在受到否定以及明确指出错误的时候，进行纠正相关上下文。」<sub>（[手段]—触发点接线需求描述）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-3 | 技能 SOP 触发判定段含「用户否定/错误指出」判据（grep 命中）+ task-planner 触发点接线（grep `context-corrector` ≥1 处，位于用户指令处理面） |
| R2 | VC-1, VC-4, VC-5 | 技能文件在位+frontmatter 完整（命令输出）+ 全量 selftest FAIL=0 + 合并回 master 且账本 98 行在位 |
| R3 | VC-2, VC-3 | Rule 98 条款含「自主发现前后文矛盾」触发子条（grep `前后文矛盾` 命中）+ 技能 SOP 含自主触发判据 |
| R4 | VC-3 | 触发点接线 grep：`C 矛盾` 行处置句含 context-corrector + Rule 31/65 交叉引用指针在位 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/task-ctxcorrect-20261103/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/task-ctxcorrect-20261103/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| ① 触发判定（否定信号/矛盾信号识别） | 既有 Rule 31.1 只管「错误指出→根因归因」，无「否定=记录缺陷信号→整理」分支；Rule 65 周期性回顾是定时驱动非事件驱动 | 新技能 SOP §触发判定（双触发源判据）+ Rule 98.1/98.2 | VC-1, VC-2 |
| ② 污染面定位（枚举被否结论的记录落点） | 四文件罗盘/notepad/记忆/台账/子代理检查点无统一「污染面枚举清单」，整理靠临场 grep | 新技能 SOP §整理六步之污染面枚举（载体清单+grep 定位法） | VC-1 |
| ③ 逐条处置（修正当地/标失效/删） | 无处置模式分级：append-only 载体（user-session-log Rule 80）禁改写但无显式豁免清单，易误改写 | 新技能 SOP §处置三分+载体豁免清单 | VC-1 |
| ④ 纠正留痕（修正条目可追溯） | 修正后旧结论去向无登记，下游消费侧（31.5/32.2）读不到修正 | 新技能 SOP §修正条目（原结论→否定原因→修正结论→影响面）+ 下游阻断 | VC-1, VC-2 |
| ⑤ 触发点接线（需要的地方） | task-planner SKILL C 矛盾类/Rule 31 衔接句/Rule 65 步骤5 均无整理触发指针 | 文本增量接线（C 类处置句+31/65 交叉指针+路由表） | VC-3 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Goal 行（上文）；R1-R4 原文；VC-1~VC-5；纯文本条款档零新增机器守卫（§四.6 opt-in）；append-only 载体（user-session-log/ledger）禁改写；写入最小化（只增量接线，既有条款原文零改动） | task_plan.md 对应章节 |
| 🔀 可变量 | 技能内部段落排版/SOP 步骤数（六步可并为五步，双触发面+下游阻断不可省）；Phase 排期；子代理档位（provider 拒则主进程接管） | - |
| 📈 学得量 | 纪元级联面实测清单/级联踩坑→findings.md；provider 拒派记录→Errors | findings.md |

## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and delete functionality."
-->
在 task-planner 技能族内新建独立技能 `context-corrector`（否定/矛盾触发→上下文与历史文档整理纠正的专职 SOP）+ 新增 Rule 98（纪律域触发纪律条款），并在既有触发点（task-planner 用户指令处理 C 矛盾类、Rule 31/65/95 衔接处、task-discipline 路由）完成文本接线；纯文本条款档（零新增脚本/守卫/自测断言，机器化 opt-in 未获授权不做），落地 master 后自测零回归。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯文本条款/技能文档变更，无代码逻辑；文档面走 alignment-review 对齐审查） |
| `session_id` | `62182ee1944741eb91f207adc18b7266` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-ctxcorrect-20261103` |
| `scope_files` | `skills/context-corrector/SKILL.md（新建）, skills/task-discipline/references/critical-rules-discipline.md, skills/task-discipline/SKILL.md, skills/task-planner/SKILL.md, skills/task-planner/references/critical-rules.md, plans/.rule-reservations.jsonl（rule-reserve 脚本写）` |
| `interaction_mode` | `ask` |
| `对齐审查` | `[登记]` 终验前对改动 5 个技能文档跑 alignment-review（口径：新增条款与既有 31/32/65/95 无语义冲突+接线指针可解析） |
| `自动超时默认项` | `[询问点: 无 2+ 选项真分叉——技能名/编号已按推荐自主裁决并登记 Decisions；D1 计划确认走 44.3 超时自动通过口径（本指令为完成性指令）]` |
| `new_rule` | `98` |
| `质量审查工具` | `[alignment-review（文档口径面）+ Verifier（VC 独立复验面）]` |

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
| VC-1 | 新技能 `context-corrector` 在位且 frontmatter 完整（name/description/tools）；SOP 含双触发面判据（用户否定/错误指出 + 前后文矛盾）+ 整理六步 + 边界互引段 | **Verify command**: `test -f <wt>/skills/context-corrector/SKILL.md && grep -c '^name: context-corrector' <wt>/skills/context-corrector/SKILL.md && grep -c '前后文矛盾' <wt>/skills/context-corrector/SKILL.md` → 1 / ≥1 | <wt>=/mnt/data/dev/task-planner-skill-worktrees/task-ctxcorrect-20261103 |
| VC-2 | Rule 98（纪律域）在位且含双触发源子条（98.1 用户显式/98.2 自主矛盾/98.3 整理优先于继续/98.4 下游阻断/98.5 与 31/32/65/95 边界互引）；Rule 31/65 处交叉指针在位 | **Verify command**: `grep -n '^### 98' <wt>/skills/task-discipline/references/critical-rules-discipline.md && grep -c '前后文矛盾' <wt>/skills/task-discipline/references/critical-rules-discipline.md && grep -c 'context-corrector' <wt>/skills/task-discipline/references/critical-rules-discipline.md` → 全 ≥1 | 同 VC-1 |
| VC-3 | 触发点接线完成：task-planner SKILL「用户新指令处理」C 矛盾类处置句 + Rule 31 衔接句含 `Skill("context-corrector")` 指针；Rule 全集索引 1-97→1-98（含「其余 80 条」→81 条、纪律域列表补 98）；旧纪元 `1-97` 在 task-planner SKILL.md 与 critical-rules.md 计数面清零 | **Verify command**: `grep -n 'context-corrector' <wt>/skills/task-planner/SKILL.md && grep -c '1-97' <wt>/skills/task-planner/SKILL.md <wt>/skills/task-planner/references/critical-rules.md` → 前者≥2，后者各=0 | 同 VC-1 |
| VC-4 | 既有 selftest 全量回归 FAIL=0（纪元锚级联锁步后无回归） | **Verify command**: `cd <wt> && bash skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -3` → 汇总 FAIL=0 | 同 VC-1 |
| VC-5 | 收口：merge commit 在位 + worktree/分支清理无残留 + 规则账本 98 reserve/land 双行 + 主仓 Read 复验 | **Verify command**: `git -C /mnt/data/dev/task-planner-skill log --oneline -3 && git -C /mnt/data/dev/task-planner-skill worktree list && grep -c '"rule":98' /mnt/data/dev/task-planner-skill/plans/.rule-reservations.jsonl` → merge 提交可见 / 无 `task-ctxcorrect-20261103` worktree 行 / ≥2 | 主仓 |

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
| G1 | 缺口调研落盘 | 机制缺口矩阵+级联面清单落 findings.md | `grep -c '^## 机制缺口矩阵' <plan-dir>/findings.md`=1 且 `grep -c '级联面' <plan-dir>/findings.md`≥1 | S1,S2/Phase 1 | complete |
| G2 | 技能体例定案 | context-corrector SKILL.md 定案（双触发源+SOP+边界互引） | Read 草案+frontmatter grep `name: context-corrector` 命中 | S3,S4/Phase 2 | complete |
| G3 | 条款落地 | Rule 98 五子条+触发点接线+1-98 级联在 worktree 完成 | VC-2/VC-3 两条 grep 命令全命中（见 VC 表） | S5,S6/Phase 3 | pending |
| G4 | 零回归收口 | selftest 全量 FAIL=0 且合并回 master+账本+归档 | VC-4/VC-5 命令输出（FAIL=0；无 worktree 残留；账本 ≥2 行） | S7,S8/Phase 4,5 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | skills/context-corrector/SKILL.md（新建） | 其他任何文件 |
| 测试 | 无（§四.6 opt-in：不加新 selftest/守卫） | 新增断言脚本 |
| 配置 | 无（零新 config 键） | config.json 改动 |
| 文档 | skills/task-discipline/references/critical-rules-discipline.md（+Rule 98 段+31/65 交叉指针）、skills/task-discipline/SKILL.md（规则列表+触发词增量）、skills/task-planner/SKILL.md（C 类处置句/Rule 31 衔接句/Rule 全集索引 1-98/路由表纪律域列表）、skills/task-planner/references/critical-rules.md（卫星路由索引 1-98+纪律域列表） | 其他技能/文档 |
| 簿记 | plans/.rule-reservations.jsonl（rule-reserve.sh 机器写 98 reserve/land 行） | 手工改账本 |

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
| CA-1 | skills/context-corrector/SKILL.md | 新增 | 增量 | 「我希望可以将这个整理机制固化为专业的技能」 | R2 目标型交付物 | 新建技能（frontmatter+SOP：触发判定/整理六步/边界互引/非目标声明） |
| CA-2 | skills/task-discipline/references/critical-rules-discipline.md:文件尾 | 新增 | 增量 | 「补充一个核心要求，就是当用户明确提出来有错误或者需要纠正的时候，主动触发…」 | R1 触发面一 | 追加 `### 98` 段（98.1-98.5 五子条），既有 Rules 原文零改动 |
| CA-3 | 同上：Rule 31 段尾+Rule 65.2 步骤5 后 | 新增（指针句） | 增量 | 「在需要的地方触发整理」 | R4 | Rule 31.6/31.3 衔接处与 65.2-5 各加一行交叉指针（指 98/新技能），不改原句 |
| CA-4 | skills/task-discipline/SKILL.md：规则索引+frontmatter description | 更新（行内增量） | 增量 | 「固化为专业的技能，在需要的地方触发整理」 | R2/R4 | 规则列表补 98；description 追加触发词「否定/纠错/前后文矛盾/上下文整理」 |
| CA-5 | skills/task-planner/SKILL.md：「用户新指令处理」表 C 矛盾类行+Rule 31 衔接句 | 更新（行内增量） | 增量 | 「在受到否定以及明确指出错误的时候，进行纠正相关上下文」 | R1/R4 | C 类处置句尾追加「→触发 Skill("context-corrector") 整理被污染记录」；「用户指出错误（Rule 31）…（Rule 31/32/33/74）」句补 /98+技能指针 |
| CA-6 | skills/task-planner/SKILL.md：L9+L210「Rules 1-97」全集索引+纪律域列表 | 更新（数值） | 增量 | 级联（R2 的既有代价） | 纪元锁步判例（1-94/1-97 历次级联） | 1-97→1-98、「其余 80 条」→「其余 81 条」、纪律域列表补 98 |
| CA-7 | skills/task-planner/references/critical-rules.md:191 卫星路由索引表纪律域行 | 更新（数值+列表） | 增量 | 同 CA-6 | 同上 | 同上口径 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | 纪律域规则文风与子条编号体例（98 段格式对齐 31/65/95） | /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md（既有段体例） | 必读 | ☑ P1 已读 |
| 项目内部文档/知识库 | 纪元级联判例（1-94→1-97 历次锁步面） | 记忆 task-v195-spec-recall-rule93 / task-l0lite-exempt-20261103 级联记录；实测=执行期 grep | 必读 | ☑ 判例在案 |
| 项目内部文档/知识库 | 卫星技能 SKILL.md 模板体例（frontmatter 契约） | skills/task-drift-guard/SKILL.md（同族参照） | 必读 | ☐ P2 开工前 |
| 官方文档 | n/a（无外部依赖） | - | 参考 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 「用户否定/Agent 前后文矛盾发生时，被污染的历史记录（四文件罗盘/notepad/记忆/台账/检查点）无专职整理机制与触发点，后续消费侧继续读到缺陷记录→错误持续污染工作」——解决方法=新建 context-corrector 技能（专职 SOP）+ Rule 98（触发纪律）+ 既有触发点文本接线，全部为文本条款级，可交付、可验证（grep 锚+selftest 零回归）、可追溯。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（能：技能+Rule 98+接线三件产物落地 master）
- [x] 核心问题不解决，其他工作都白费吗？（是：不固化则每次否定仍靠临场 grep，缺陷记录继续污染）
- [x] 核心问题的解决方法是清晰的、可执行的？（是：CA-1~CA-7 七处变更全部锚定既有文件/新增文件）

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| （全部 S-unit） | LOCAL-ONLY | n/a | n/a（本任务零外部依赖：技能体例/纪元判例/级联面全部在仓内与用户记忆中） | n/a | 否 |

> 豁免声明：本任务全部 S-unit 纯机械/文本条款型（LOCAL-ONLY），无 NET-* 条目；不涉外部事实/报错/现成方案检索。

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 本仓既有纠正/整理机制（Rule 31/32/65/95.6+drift-guard+meta-corrector agent） | 只读 grep/Read（P1 已取证，锚=progress.md [research] 行） | progress.md [research] 2026-11-03 | ☑ |
| ② 对标样本 | 用户宪法 §四.6 文本优先铁律+§八 记忆系统「过时记忆更新或删除」条款（机制体例对标） | 只读 Read ~/.zcode/AGENTS.md §四.6/§八 | 本表+Decisions | ☑ |
| ③ 外部约束 | 无外部平台约束（纯仓内文本条款；机器守卫 opt-in 未授权=约束自用户指令边界） | 用户原话（user-session-log #1） | user-session-log.md #1 | ☑ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）——本任务非归因类，②③ 为体例与边界对标，已取证。

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
Phase 1

## Next Step
P1 收口：findings.md 回填机制缺口矩阵+级联面清单 → 清哨兵+attest 锁计划 → 建 worktree 进 P2

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore（调研兜底）＋机械 grep（级联面扫描） | 机制缺口矩阵需跨多文件通读（discipline 规则 31/32/65/95+drift-guard+SKILL 接线点），子代理隔离；级联面=机械 grep 主进程直做 |
| Phase 2 | Agent 子代理 general-coder（新建技能文件） | 单文件新建 ≤2f，编码类兜底执行体；provider 拒则主进程接管（22.3 第⑤档） |
| Phase 3 | Agent 子代理 general-coder（Rule 98+接线）＋机械 grep（级联锁步） | 多文件文本条款修改走编码兜底；纪元级联=机械面主进程 grep+Edit |
| Phase 4 | 机械守卫脚本 run-selftests.sh＋Agent 子代理 verifier（独立复验） | 零回归门=脚本；VC 独立面=verifier 子代理 |
| Phase 5 | 机械（git 命令+rule-reserve+archive 脚本） | git 编排/簿记=主进程白名单① |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8（S-unit 7 个但强串行依赖为主：P2 依赖 P1 结论、P3 依赖 P2 文件在位、P4 依赖 P3 全量写入；唯一并行组 P1 内部两路）→ Rule 21.4 独立性守门调度
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；用户未用 /goal 锚定，不代调

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 机制缺口调研与级联面扫描
- [x] 缺口矩阵：Rule 31/32/65/95.6/drift-guard/meta-corrector 对「否定→记录整理」的覆盖缺口（落 findings.md）
- [x] 级联面清单：全仓 grep `1-97` / `80 条` / `97 纪律域` 命中行逐一登记（锁步更新面）
- [x] 规则号 98 可用性确认（账本无预留冲突）
- [x] 知识储备必读项勾选
- [x] 计划展示 + D1 确认（Rule 44.3 超时自动通过口径，登记自动裁决记录）+ 清哨兵 + attest 锁
- **V-N:** VC-1, VC-5（S1/S2 结论落 findings 后可直接服务终验对照）
- **Status:** complete（2026-11-03；attest 锁定 70372cf3+98 reserve 登记）
- **Executor:** explore（S1）/ 主进程机械 grep（S2）——provider 拒时两路均主进程接管（22.3 第⑤档，Errors 已登记前例）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 缺口矩阵落盘 | explore | /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md（31/32/65/95.6 段） | findings.md「机制缺口矩阵」段在位 | 8min | 1f/60l/8min | 无 | - [parallel-group:pg-p1] | complete |
| S2 | 级联面清单落盘 | 继承 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md（L9/L210 全集索引行） | findings.md「级联面清单」段含逐行锚 | 8min | 1f/40l/8min | 无 | - [parallel-group:pg-p1] | complete |

（S1/S2 并行组=pg-p1：文件集 disjoint 只读、资源无竞争、输入独立、验收各自落 findings 不同段，独立性四问全 no）

### Phase 2: worktree 建成 + 新建 context-corrector 技能
- [x] worktree 按 §十一 路径规范创建（分支 wt/task-ctxcorrect-20261103）
- [x] 新建 skills/context-corrector/SKILL.md（frontmatter 契约+触发判定双源+SOP 六步+边界互引 31/32/65/80/95+非目标声明「零机器守卫」；文件 >100 行故 S3/S4 两步写入）
- [x] 体例对照 task-drift-guard SKILL.md（同族格式）
- **V-N:** VC-1
- **Status:** complete（2026-11-03；V-2.1/V-2.2 PASS，git status `?? skills/context-corrector/`）
- **Executor:** general-coder（haiku 档；provider 拒→主进程接管）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S3 | 技能文件上半（frontmatter+触发判定+整理六步 1-3 步） | general-coder | 计划 P2 段+skills/task-drift-guard/SKILL.md（体例参照） | SKILL.md 上半在位，grep '^name: context-corrector'=1 | 10min | 1f/90l/10min | 无 | S1 | complete |
| S4 | 技能文件下半（六步 4-6 步+边界互引+非目标声明） | 继承 | S3 产出（同文件续写） | 完整 SKILL.md 在位，grep '前后文矛盾'≥1 且 '非目标' 段在位 | 10min | 1f/90l/10min | 无 | S3 | complete |

### Phase 3: Rule 98 条款 + 触发点接线 + 1-98 纪元级联
- [x] critical-rules-discipline.md 追加 `### 98` 段（98.1-98.5 五子条，文风对齐 31/65/95）
- [x] Rule 31/65 交叉指针句（增量，原文零改）
- [x] task-discipline SKILL.md 规则列表+description 触发词增量
- [x] task-planner SKILL.md：C 矛盾类处置句/Rule 31 衔接句补指针 + L9/L210 全集索引 1-97→1-98 + critical-rules.md:191 路由索引锁步
- [x] worktree 内 commit（Rule 27）
- **V-N:** VC-2, VC-3
- **Status:** complete（2026-11-03；commit 5e6e472，5 文件 +126/-15；主进程逐行 Read 复核 S5/S6 全命中）
- **Executor:** general-coder（S5/S6；provider 拒→主进程接管）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S5 | Rule 98 五子条+31/65 指针落 discipline 两文件 | general-coder | S4 产出+critical-rules-discipline.md 31/65 段体例 | `grep -n '^### 98'` 命中+98.1-98.5 全在+31/65 指针各 1 行 | 10min | 1f/70l/10min | 无 | S4 | complete |
| S6 | task-planner 触发点接线+1-98 纪元级联 | 继承 | findings「级联面清单」逐行锚 | task-planner SKILL grep context-corrector≥2 且 grep -c '1-97'=0（SKILL+critical-rules 两面） | 10min | 2f/60l/10min | 无 | S5 | complete |

### Phase 4: 回归与独立复验
- [x] run-selftests.sh 全量 FAIL=0（纪元锚锁步后；红锚=锁步面漏扫→按 FMEA 兜底逐个 grep 修复）
- [x] verifier 子代理独立复验 VC-1/2/3（Read 实际文件，不信任主进程自测）
- [x] 遗留登记：部署位同步（zcode/claude/cursor）待用户授权（判例=历次任务惯例）→ 已登记 P5 交付总结「下一步建议」（§四.6 部署授权惯例，本任务仅落 master 源仓）
- **V-N:** VC-1, VC-4
- **Status:** complete（2026-11-03；全量 94/94 FAIL=0；verifier 首派编造输出按§三 P0 判例作废，主进程磁盘实测接管：VC-1 1/3、VC-2 `### 98`@L644+3+5、VC-3 双文件 1-97=0 且 1-98=L9/L210/L253 三处，3/3 PASS；纪元锚 2 脚本锁步 commit 6ad1686）
- **Executor:** code-runner-agent（S7）/ verifier（S8；首派编造输出→主进程接管登记 Errors）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S7 | selftest 全量回归零 FAIL | code-runner-agent | worktree 根（run-selftests.sh） | 末行汇总 FAIL=0（命令输出） | 12min | 1f/30l/12min | 无 | S6 | complete |
| S8 | VC-1/2/3 独立复验 | verifier | VC 表 Verify command 三条 | 三条命令独立复跑全命中，复验记录落 verification.md | 10min | 1f/30l/10min | 无 | S7 | complete |

### Phase 5: 合并收口
- [x] 全 VC 复验 + git status 干净 → smart-merge-back.sh 合回 master → 清理 worktree/分支
- [x] rule-reserve.sh land 98
- [x] 主仓 Read 关键文件复验 + check-complete.sh + archive-plan.sh + sync-todos --index
- [x] 交付总结五要素（Rule 48/76）
- **V-N:** VC-5
- **Status:** complete（2026-11-03；merge 70b2e13，worktree/分支清理 0 残留，ledger 98 landed，check-complete RC=0 全门）
- **Executor:** 主进程（例外理由：① git 编排+② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（check-conflicts.sh 实测：信号①=未提交 2 件「.zcode/plans/plan-session_da2769c3…md（他会话遗留）+ 本计划目录（本任务自有）」＋信号③=遗留分支 wt/task-v168-machine-parked（他会话）；均与任务 scope 零重叠 → 登记观察不处置，§五 最小写入；技能文件本身=运行中基础设施，§十一 11.1 命中 → worktree） |
| `isolation` | `worktree`（实现类默认首选，未命中 §11.5 任一例外） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-ctxcorrect-20261103` |
| `branch` | `wt/task-ctxcorrect-20261103` |
| `merge_back` | `merged(70b2e13)`（2026-11-03；git status 干净+主仓 Read 复核+全量 94/94 FAIL=0 后合回 master；worktree/分支已清理） |

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
| Phase 2 | 技能体例与既有 15 技能 frontmatter 契约漂移（缺字段/工具面错配） | 4 | 3 | 4 | 48 | 对照 task-drift-guard SKILL.md 体例模板逐字段核；selftest-frontmatter 面 grep 复核 |
| Phase 3 | 纪元级联面漏扫（`1-97`/`80 条`/纪律域列表 三族字面+容差锚未全命中）导致 selftest 红 | 7 | 4 | 3 | 84 | 级联 SOP=全仓 grep 四形态族（历次判例：字面+`[0-9]` 容差）；漏扫→S5 内二次 grep `1-9[6-9]` 兜底+run-selftests 定位红锚逐个锁步 |
| Phase 4 | 并行会话对同文件先行合入 master 致 merge 冲突 | 5 | 3 | 4 | 60 | merge 前 `git fetch`+behind 检查；冲突按并集解判例（取双方增量+留双方注释） |
| Phase 1 | 子代理 provider 持续拒绝 | 2 | 6 | 2 | 24 | 主进程接管（22.3 第⑤档，已在 Errors 登记前例），结论照旧落 findings |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-11-03（S1 TodoWrite 已建 5 条映射） | 执行中 |
| Phase 2 | ☑ | 2026-11-03 | 待 P1 收口 |
| Phase 3 | ☑ | 2026-11-03 | 待 P2 |
| Phase 4 | ☑ | 2026-11-03 | 待 P3 |
| Phase 5 | ☑ | 2026-11-03 | 待 P4 |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. 新技能命名与既有 *-corrector 族（meta-corrector/memory-corrector/prompt-corrector，均在用户级 ~/.zcode/ 不在本仓）是否语义撞车？→ 解：本仓无同名；`context-corrector` 管「上下文/历史文档整理」，meta-corrector 管「死循环/打转纠偏」，触发词互斥（Decisions 已登记裁决）。
2. 新技能归「11 卫星」规则域还是独立技能？→ 解：独立技能（规则全文仍落 task-discipline 卫星 Rule 98，技能=执行 SOP 载体；「11 卫星」分层计数不动，Rule 82 边界不越）。
3. 部署位（~/.zcode/skills 等 4 位）何时同步？→ 解：本任务只落 master 源仓；部署同步=待用户授权（历次任务惯例判例，遗留登记于交付总结）。

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
| 技能名=`context-corrector`（Recommended） | 与既有 *-corrector 家族（meta/memory/prompt）命名对齐，语义「上下文+历史文档的整理纠正」精确；用户未指定名，按推荐自主裁决登记（44.2 低分叉不询问） |
| 纯文本条款档（零新脚本/守卫/selftest） | 宪法 §四.6 文本优先铁律+opt-in 守护原则；用户诉求=「固化为专业技能」（技能体=文本 SOP+接线），未要求机器门 |
| 新 Rule=98（纪律域） | 账本 .rule-reservations.jsonl 显示 97=已 landed、无 98 预留；98 为下一个可用号（Rule 20.6 查重通过） |
| 接线点=C 矛盾类处置句+Rule 31 衔接句+Rule 65.2 步骤5 指针 | 三处=用户否定面（31.1 触发①②③）+自主矛盾面（65.2 步骤5）+C 类重规划面，覆盖 R1/R3 全部触发源且不扩面 |
| 不动「11 卫星」分层计数 | 新技能=独立技能（非规则域卫星，同 error-fix-prompt-forge/todo-skill 先例），「11 卫星」是 Rule 82 分层口径计数，级联面=Rule 纪元 1-97→1-98（CA-6/CA-7） |

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
  完整模板: /home/terry/.zcode/skills/task-planner/templates/batch_report.md | 规则详解: /home/terry/.zcode/skills/task-planner/references/batch-quality-gate.md
-->
| 字段 | 值 |
|------|-----|
| `total` | n/a（纯单次任务，无批量操作，区块按模板规则填 n/a 不删） |

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
| 1 | 2026-11-03 01:05 | Explore | 现状摸底六问（机制/接线面/编号/级联/部署） | failed | provider 拒绝模型请求（"Provider rejected the model request"），两次同法均拒 | 工具返回原文 | -（主进程接管 grep/Read 兜底，结论在 progress [research] 行） | 无（未启动） | rescue=22.3 第⑤档主进程接管 / retry=2 / verify_done=☑（结论已落盘） |
| 2 | 2026-11-03 01:06 | Explore | 同上（重试 1） | failed | 同上 provider 拒绝 | 工具返回原文 | - | 无 | 同上 |
| 2 | | | | | | | | | - / 0 / ☐ |
| 3 | | | | | | | | | - / 0 / ☐ |

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP
