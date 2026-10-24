# Task Plan: init 模板脚本侧变量渲染层（tplrender）
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  选定 variant 后 template_type 填所选类型名（白名单=${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/templates/variant/*-type.md 动态派生，见 check-template-type.sh）；general=通用回退（恒合法，Rule 34.1）
  plan_tier ∈ {standard, mini}（Rule 38.1，mini 四条件机器判定）；execution_lane ∈ {L0, L1, L2}（Rule 38.7，缺省 L1；L0 禁滥用见 38.7 末段）
  check-template-type.sh 三形态之一：行首 `^template_type:`（本块）/ 表格行 / HTML 注释；本块用行首形态 -->
template_type: general
plan_tier: standard
execution_lane: L1
parallel_groups: tpl
<!-- 
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC（核心问题的可观察解决证据，非手段产物完成）；目标型任务终验必填「🎯 核心目标达成裁决」区块（58.5） -->

- **R1**: 「模板ID这些东西还竟然是依赖于模型自主的识别能力进行去修正」<sub>（[目标]）</sub>
- **R2**: 「使用类似于模板引擎或者变量替换这种，在脚本阶段直接生成替换掉」<sub>（[手段]）</sub>
- **R3**: 「直接通过脚本通过变量传参，然后直接适配产出一个直接适配任务的任务」<sub>（[手段]）</sub>
- **R4**: 「确保后期减少无必要的无关紧要的各种，比如说路径检索」<sub>（[目标]）</sub>
- **R5**: 「用脚本传参数是最稳定而且最准确的，比模型再去检索各种特别浪费时间……高效的多，而且准确」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-3 | 产物中机械占位符计数=0（grep 实测）；语义占位符原样保留（模型只填语义内容） |
| R2 | VC-1, VC-4 | init 渲染层产物零机械占位残留；漏定义变量 fail-closed（exit≠0+报错列 token） |
| R3 | VC-1, VC-2 | 脚本吃 task-id/任务名/日期/路径参数直接产出适配产物（值正确性 grep 实测） |
| R4 | VC-2, VC-6 | 产物内路径已展开为真实绝对路径（无需模型检索）；SKILL.md 指示面同步更新 |
| R5 | VC-5, VC-7 | 渲染确定性=既有 selftest 全量零回归；部署位 diff=0 同步 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/<task-id>/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/<task-id>/user-session-log.md`（模板 = ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 模板制作（templates/*.md） | 机械占位与语义占位形态混杂无契约，模型无法机械区分 | token 契约：{{VAR}}=脚本渲染，尖括号中文=模型填写，边界清单落 findings | VC-3 |
| 初始化（init-session.sh copy_template） | 纯 cp 零替换；$1/DATE 已知却不写入文件；27 处 ${TASK_PLANNER_ROOT:-…} markdown 内永不展开 bug | 新增 render_template() 渲染层：{{VAR}}+兼容形态双映射+残留校验 fail-closed | VC-1, VC-2, VC-4 |
| 计划消费（模型后续填写） | SKILL.md/模板内指示模型手工修正机械占位 | SKILL.md 初始化段改写：机械占位由脚本渲染，模型禁手工修正 | VC-6 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Goal；VC 表全 7 条；R1-R5 用户原话；四文件罗盘协议与 7 计划文件清单不变；variant 29 文件零文本迁移（由渲染层兼容映射覆盖）；既有 selftest 断言语义不放松（只适配不改口径） | 本计划对应章节锚 |
| 🔀 可变量 | 渲染函数内部实现形态（sed/awk/bash 串替换选型）；S-unit 执行顺序；模板 token 注释措辞 | - |
| 📈 学得量 | 渲染实测产物差异；selftest 级联新发现；模板占位符边界新事实 | findings.md |

## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and delete functionality."
-->
init-session.sh 内建变量渲染层（{{VAR}} 传参 + 兼容形态映射 + 残留 fail-closed），使 init 产出的计划文件机械占位符（task-id/任务名/日期/路径）全部由脚本直接替换为真实值，模型只填语义内容。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（shell 脚本+模板代码修改类，模板画像代码组默认） |
| `session_id` | `sessiond427dc55b7e372b7367ad55488895e13` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-tplrender-20261024` |
| `scope_files` | `skills/task-planner/scripts/init-session.sh`; `skills/task-planner/templates/task_plan.md`、`skills/task-planner/templates/user-session-log.md`、`skills/task-planner/templates/notepad-learnings.md`、`skills/task-planner/templates/progress.md`、`skills/task-planner/templates/findings.md`、`skills/task-planner/templates/verification.md`、`skills/task-planner/templates/knowledge-brief.md`; `.zcode/plan-templates/knowledge-brief.md`; `skills/task-planner/SKILL.md`; `skills/task-planner/scripts/selftest-plan-tier.sh`、`skills/task-planner/scripts/selftest-session-log.sh`（Phase 5 实测级联） |
| `interaction_mode` | `silent`（autonomous 会话 + Rule 95 执行优先；静默决策清单随交付呈报） |
| `对齐审查` | 终验前跑 alignment-review（标准收尾流程） |
| `自动超时默认项` | 本计划唯一询问点=D1 计划确认：默认项=按本计划执行；超时 5min（Rule 44.1）；autonomous 会话按 44.3+Rule 95 登记「自动裁决记录」后推进 |
| `new_rule` | （留空——本次为机械层改造，不新增 Rule 编号；模板域既有 Rule 34/37 管辖，渲染契约文字落 SKILL.md 初始化段+init 脚本头注释） |
| `质量审查工具` | 既有 agent：`Code Reviewer`（CR Gate）+ `Verifier`（终验独立复验）；无缺口待补建 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

<!--
  WHAT: 任务执行完毕 ≠ 目标完成。此表确保每一步有可验证证据。
  RULE: 每个 phase 完成后对照 VC 编号复验；phase 全部 complete ≠ 通过终验。
  FORMAT: VC-N 是客观判定标准（可测试/可追溯/不依赖主观判断）。
  V-N: goal-gate.md 规定「≥5 条 VC + 每 phase ≥2 条 V-N（映射到 VC 编号）」；
       在每个 Phase 段（`### Phase N` 的 - **Status:** 行前）补 `- **V-N:**` 占位行，
       填写本 Phase 验收映射的 VC 编号（≥2 条，如 `VC-1, VC-2`；对应逐条验收记录在
       ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/templates/verification.md 的 `V-N.N` 项，映射目标须为已定义 VC 编号）。
       check-complete.sh 终验 VC-GATE 段机械校验（config.json vc_gate_enforce，默认 warn）。
-->

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | init 实弹产物中机械占位符零残留（`{{[A-Z_]+\}\}`、`[Brief Description]`、`{task-id}`、`<task-id>`、`{task-name}`、`[DATE]`、`[YYYY-MM-DD`、`${TASK_PLANNER_ROOT:-` 八形态合计 grep 计数=0） | 临时目录实弹跑 init 后 grep -rE 计数 | `mkdir -p /tmp/tplrender-vctest/task-vctest-$$ && cd $_ && bash <root>/skills/task-planner/scripts/init-session.sh "VC测试任务" ; grep -rE '\{\{[A-Z_]+\}\}|\[Brief Description\]|\{task-id\}|<task-id>|\{task-name\}|\[DATE\]|\[YYYY-MM-DD|\$\{TASK_PLANNER_ROOT:-' . \| wc -l` 输出 0 |
| VC-2 | 渲染值正确：产物含真实 task-id（目录名）、init 当日日期、$1 任务名、TASK_PLANNER_ROOT 真实绝对路径 | grep 命中断言（≥4 类各 ≥1 处） | 实弹目录内 `grep -rl "task-vctest" ; grep -rl "$(date +%Y-%m-%d)" ; grep -rl "VC测试任务" ; grep -rl "$HOME/.zcode/skills/task-planner"` 全命中 |
| VC-3 | 语义占位符零误替换：产物中 `<用户原话`、`<按需增行>` 等语义占位仍在位 | grep 命中断言 | 实弹目录 `grep -rc '<用户原话' ; grep -rc '<按需增行>'` 合计 ≥2 |
| VC-4 | 残留校验 fail-closed：注入未定义 `{{UNDEFINED_VAR_XYZ}}` 后 init exit≠0 且报错含该 token | 临时模板注入实测 | 临时副本模板加 token → 跑 init → `echo $?` 非 0 且 stderr 含 `UNDEFINED_VAR_XYZ` |
| VC-5 | 零回归：worktree 内 run-selftests.sh 全量 ΣFAIL=0（对照改动前基线快照） | 全量 selftest 对比基线 | `bash skills/task-planner/scripts/run-selftests.sh 2>&1 \| tail -5`（基线快照见 progress.md Phase 1） |
| VC-6 | SKILL.md 指示面更新在位：初始化段含脚本渲染契约文字 | grep 断言 | `grep -n "渲染" skills/task-planner/SKILL.md` 命中初始化段新契约行 |
| VC-7 | 部署位同步：~/.zcode/skills/task-planner 改动文件与主仓 diff=0 | diff 断言 | `diff ~/.zcode/skills/task-planner/scripts/init-session.sh <主仓同路径> && diff ~/.zcode/skills/task-planner/templates/task_plan.md <主仓同路径>` 等逐文件空输出 |

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
| G1 | 契约定稿 | 变量集+兼容映射+语义边界清单落 findings | findings.md 三清单齐全+调查检查点可追溯 | S1/Phase 1 | complete |
| G2 | 渲染层落地 | init-session.sh 渲染函数+校验+接线完成 | tmp 实弹 VC-1 计数=0+VC-4 exit≠0 | S3、S4、S5/Phase 2 | complete |
| G3 | 模板 token 化 | 核心 7+项目级模板机械占位改 {{VAR}} | worktree 8 文件旧机械形态 grep=0 | S6-S10/Phase 3 | complete |
| G4 | 指示面更新 | SKILL.md 初始化段渲染契约在位 | grep -n "渲染" SKILL.md 命中初始化段 | S11/Phase 4 | complete |
| G5 | 回归合并 | selftest 零回归+VC 全 PASS+部署 diff=0 | run-selftests ΣFAIL=0+merge commit+diff 空 | S12-S15/Phase 5 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 脚本 | `skills/task-planner/scripts/init-session.sh` | 其他 scripts/*.sh（selftest 级联修复除外，Phase 5 实测定） |
| 模板 | `skills/task-planner/templates/task_plan.md`、`skills/task-planner/templates/user-session-log.md`、`skills/task-planner/templates/notepad-learnings.md`、`skills/task-planner/templates/progress.md`、`skills/task-planner/templates/findings.md`、`skills/task-planner/templates/verification.md`、`skills/task-planner/templates/knowledge-brief.md` | `templates/variant/*.md` 29 文件零文本迁移（渲染层兼容映射覆盖）；`templates/{delivery-summary,session-handoff,subagent_dispatch,shared-tracker,batch_report,deprecated}.md` 不动 |
| 配置 | `.zcode/plan-templates/knowledge-brief.md`（项目级双轨对齐） | 其他 .zcode/ 配置 |
| 文档 | `skills/task-planner/SKILL.md`（初始化段+I/O 契约段） | 其他文档 |
| plans/ | 本计划目录 `plans/task-tplrender-20261024/**` | 其他计划目录 |

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
|------|------------------|---------------------------|-----------|----------------|----------------|---------|
| CA-1 | init-session.sh:copy_template(L83-97) | 修改 | 增量（新增渲染层函数+调用点，既有逻辑不动） | 「在脚本阶段直接生成替换掉」 | 调查② 纯 cp 零替换 | 新增 render_template() 于 cp 后调用 |
| CA-2 | templates/ 核心 7 模板机械占位符 | 更新 | 替代（①用户明示要求改造模板 ②{{VAR}} 完整覆盖旧机械形态场景 ③改前 Read 全文 ④替代后 selftest 全绿） | 「改进模板生成……可以用传参数参数定义的方式来改进」 | 调查③ 占位符表 | 机械占位→{{VAR}}；语义占位逐字保留 |
| CA-3 | 27 处 `${TASK_PLANNER_ROOT:-…}` markdown 死串（核心 7 模板内命中部分） | 更新 | 替代（bug 修复：永不展开→渲染为真实路径，用户诉求含减少路径检索） | 「减少无必要的……路径检索」 | 调查③ 既存 bug | 核心模板内→{{TASK_PLANNER_ROOT}} 渲染展开 |
| CA-4 | SKILL.md:40 初始化段+I/O 契约示例 | 修改 | 增量（新增渲染契约说明与命令形态） | 「直接通过脚本通过变量传参」 | 调查④ 模型侧修正面 | 初始化段加渲染契约行 |
| CA-5 | selftest 级联受影响断言（Phase 5 实测确定清单） | 修改 | 增量（适配新渲染行为，断言语义不放松） | 「最稳定而且最准确」 | 调查⑤ 级联面 | 逐脚本适配+全量绿 |
| CA-6 | `.zcode/plan-templates/knowledge-brief.md` | 更新 | 替代（已手工展开的静态路径→token 化对齐新契约） | 「直接基于模板进行生成」 | 调查③ 项目级双轨 | token 化 |
| CA-7 | variant/*.md 29 文件 | - | 不变更（渲染层兼容映射覆盖，零文本迁移） | - | 范围控制决策 | 不碰，登记于 findings 边界清单 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | 调查检查点（init 机制现状全貌） | `/mnt/data/dev/task-planner-skill/plans/task-tplrender-20261024/subagent-state/01-explore-init-mechanism.md` | 必读 | ☑ |
| 项目内部文档/知识库 | init-session.sh 源码（1023 行） | `skills/task-planner/scripts/init-session.sh` @ master | 必读 | ☑ |
| 项目内部文档/知识库 | 模板占位符分布 | `skills/task-planner/templates/*.md`（42 文件） | 必读 | ☑ |
| 项目内部文档/知识库 | selftest 级联面清单 | 调查结论⑤（9 selftest+check-template-type+check-complete） | 参考 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 模板机械占位符的替换责任错放在模型（不稳定+慢+需路径检索），应移到脚本侧在 init 阶段一次性确定性完成——解决后 init 产物即开即用，结果能交付。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（init 产物零机械占位残留=交付）
- [x] 核心问题不解决，其他工作都白费吗？（每次 init 都重复付出模型修正成本）
- [x] 核心问题的解决方法是清晰的、可执行的？（渲染层+变量表+残留校验，先例=register-hooks-cj.ts 构建期替换）

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| S1/S3-S9 | LOCAL-ONLY | -（本地源码+模板可完全解决；bash sed 替换为既有能力） | - | - | 不适用 |
| S10-S13 | LOCAL-ONLY | -（既有 selftest 体系回归） | - | - | 不适用 |

> 豁免声明：全任务纯本地机械改造（bash 脚本+markdown 模板），无 NET-* 条目；bash 文本替换若有语法疑问按 Rule 22.3.0 现场检索（不预排）。

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | init-session.sh 现有渲染能力/模板占位符分布 | Explore 子代理全量 grep+源码精读（已完成） | findings.md §Research Findings / subagent-state/01 | ☑ |
| ② 对标样本（58.2 强制） | 仓内既有替换先例 register-hooks-cj.ts:109-165 构建期字符串替换 | 子代理定位+形态比对 | findings.md §Research Findings | ☑ |
| ③ 外部约束 | selftest 守护面（9 脚本断言+check-complete） | 子代理级联清单 | findings.md §Research Findings | ☑ |

> 本任务为功能实现类（非归因分析），证据面=改造前现状取证，已完成（三面全有第一手证据）。

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
派 Verifier 独立终验 S14（VC-1..6+合并前置+范围自检）→ PASS 后 CR Gate → S15 合并部署

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | 主进程（编排决策）+ 机械守卫脚本 | 变量契约定稿=跨文件设计决策；worktree 编排=白名单② |
| Phase 2 | Agent 子代理 general-coder + 机械守卫脚本 | 渲染层实现=中等规模单文件代码任务 |
| Phase 3 | Agent 子代理 general-coder（4 单元，S5-S8 可并行） | 模板 token 化=既定模式批量机械改（每单元 ≤2f） |
| Phase 4 | Agent 子代理 Code Assistant | SKILL.md 单文件小改 |
| Phase 5 | code-runner-agent（回归）+ Verifier（终验）+ 主进程（git 编排） | 测试执行隔离+独立验证视角+白名单② git 编排 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 激活条件（S-unit 间强依赖链 S1→{S3,S5-S9}→S10→S13，无 ≥3 独立 fan-out 面）→ Rule 21.4 独立性守门调度；S5-S8 四单元文件集互不相交且同依赖 S1，S1 完成后同消息并行派发
**/goal 对齐（Rule 40.3）**: 用户 /goal 指令即本计划 Goal 证据源（user-session-log.md #1）；Goal+VC 表即 session goal 载体

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 契约定稿与隔离建起
- [x] 变量契约定稿（{{VAR}} 变量集+兼容映射形态+语义占位边界清单）→ findings.md
- [x] worktree 创建 + 改动前 selftest 基线快照 → progress.md（93/93 FAIL=0）
- [x] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **V-N:** VC-3, VC-4（边界清单是 VC-3 判定的依据；契约含 fail-closed 行为定义）
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护与 git 编排——Rule 25.3 白名单）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 变量契约与语义边界清单定稿落 findings | 继承(主进程) | plans/task-tplrender-20261024/subagent-state/01-explore-init-mechanism.md（占位符分布表+27 处死串 bug+语义占位形态清单） | findings.md 含：{{VAR}} 变量表(≥6 变量)+兼容映射表(8 形态)+语义保留清单 | 15min | 1f/60l/15min | 无 | - | pending |
| S2 | worktree 建立+selftest 基线快照 | 继承(主进程) | /mnt/data/dev/task-planner-skill-worktrees/task-tplrender-20261024（git worktree add 自 master） | worktree 在位；基线 ΣFAIL 数记 progress.md | 15min | 1f/20l/15min | 无 | S1 | pending |

### Phase 2: 渲染层实现（init-session.sh）
- [x] render_template() 渲染函数：{{VAR}} 替换+兼容形态映射+残留校验 fail-closed+头注释变量表
- [x] tmp 实弹验证（VC-1/2/4 现场证据，S4 六项实弹覆盖 S5）
- **V-N:** VC-1, VC-2, VC-4
- **Status:** complete
- **Executor:** general-coder

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S3 | 渲染函数主体：{{VAR}} 变量集替换+头注释变量表 | general-coder | worktree skills/task-planner/scripts/init-session.sh（1023l；copy_template L83-97 纯 cp；DATE L479 已定义未用） | render 函数含 6 变量替换+变量表注释；bash -n 语法过 | 15min | 1f/50l/15min | 无 | S1 | pending |
| S4 | 兼容形态映射+残留校验 fail-closed+cp 后接线 | general-coder | worktree 同文件（S3 产出渲染函数后追加兼容层+调用点） | 8 兼容形态替换；残留 {{[A-Z_]+}} → exit 1 列 token；copy_template 后已接线 | 15min | 1f/40l/15min | 无 | S3 | pending |
| S5 | tmp 实弹验证渲染+fail-closed | code-runner-agent | /tmp/tplrender-vctest/ 实弹目录 + verification.md VC-1/2/4 命令 | VC-1 计数=0；VC-2 四类值命中；VC-4 exit≠0 含 token 名 | 15min | 0f/0l/15min | 无 | S4 | pending |

### Phase 3: 模板 token 化（核心 7+项目级，S5-S8 并行组 tpl）
- [x] 核心 7 模板机械占位符 → {{VAR}}；语义占位符逐字保留
- [x] 项目级 .zcode/plan-templates/knowledge-brief.md 双轨对齐
- [x] 规范召回（Rule 93）：10 S-unit 节点主进程亲读召回卡+progress [recall] 行+V-N 补跑全 PASS（2026-10-24）
- **V-N:** VC-1, VC-3
- **Status:** complete
- **Executor:** general-coder

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S6 | token 化 task_plan.md 模板 | general-coder | worktree skills/task-planner/templates/task_plan.md（机械占位分布见 findings 契约表） | 机械占位→{{VAR}}；`<用户原话`/`<按需增行>` 等语义占位逐字保留 | 15min | 1f/35l/15min | 无 | S1 | pending | [parallel-group:tpl]
| S7 | token 化 user-session-log+notepad-learnings | general-coder | worktree skills/task-planner/templates/user-session-log.md+notepad-learnings.md | 同 S6 验收口径 | 10min | 2f/20l/10min | 无 | S1 | pending | [parallel-group:tpl]
| S8 | token 化 progress+findings | general-coder | worktree skills/task-planner/templates/progress.md+findings.md | 同 S6 验收口径 | 15min | 2f/30l/15min | 无 | S1 | pending | [parallel-group:tpl]
| S9 | token 化 verification+knowledge-brief | general-coder | worktree skills/task-planner/templates/verification.md+knowledge-brief.md | 同 S6 验收口径 | 15min | 2f/30l/15min | 无 | S1 | pending | [parallel-group:tpl]
| S10 | 项目级 plan-templates 双轨对齐 | general-coder | worktree .zcode/plan-templates/knowledge-brief.md（已手工展开的静态路径→{{VAR}} 化） | 项目级文件 {{VAR}} 化与内建模板口径一致 | 5min | 1f/10l/5min | 无 | S1 | pending | [parallel-group:tpl]

### Phase 4: SKILL.md 指示面更新
- [x] 初始化段命令形态+渲染契约文字+「机械占位禁模型手工修正」指示
- **V-N:** VC-6
- **Status:** complete
- **Executor:** code-assistant

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S11 | SKILL.md 初始化段渲染契约更新 | code-assistant | worktree skills/task-planner/SKILL.md（:40 初始化机械子动作段；:233 附近 I/O 契约示例） | 初始化段含「机械占位符由 init 渲染层替换，模型禁手工修正，仅语义占位由模型填写」+命令形态带任务名参数；grep 渲染契约命中 | 15min | 1f/15l/15min | 无 | S1 | pending |

### Phase 5: 回归终验与合并部署
- [x] worktree 全量 selftest 回归（对照 Phase 1 基线）+ 级联修复（93/93，da7a3a4）
- [x] 独立终验（VC-1..7 全量复验，Verifier 派发；全 PASS）
- [x] 合并回+部署位文件级同步+worktree/分支清理+主仓 Read 复验（merge commit+VC-7 diff=0）
- [x] 归档计划：check-complete exit 0 后先 `bash <skill>/scripts/set-active-plan.sh --clear` 再 `bash <skill>/scripts/archive-plan.sh <task-id> --root <plans根>`（Rule 81；守卫拒绝时登记理由不强移）
      <!-- task-kb-auto-capture-20261022 增：收尾主动触发——归档与知识提取为收尾默认动作，勿依赖人想起手动跑 -->
- [x] 知识提取入库：本仓无 scripts/kb-sync-from-plan.sh 机制 → 登记「跳过：无知识库机制」；知识蒸馏已完成于 plans/task-tplrender-20261024/knowledge-brief.md §1-§4
- **V-N:** VC-5, VC-7, VC-1, VC-2, VC-3
- **Status:** complete
- **Executor:** 主进程（例外理由: ② git 编排+簿记——Rule 25.3 白名单；回归/修复/终验由 S-unit 各自执行体承担）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S12 | worktree 全量 selftest 回归 | code-runner-agent | worktree skills/task-planner/scripts/run-selftests.sh（对照 progress.md Phase 1 基线快照） | ΣFAIL=0 或 FAIL 清单落 progress.md | 15min | 0f/0l/15min | 无 | S4、S5、S6、S7、S8、S9、S10、S11 | pending |
| S13 | 级联断言适配修复 | general-coder | S12 FAIL 清单（每批 ≤2f，超批续派 S13b/S13c） | 修复后复跑对应 selftest 绿；断言语义不放松 | 15min | 2f/40l/15min | 无 | S12 | done |
| S14 | 独立终验 VC-1..7 全量复验 | verifier | worktree 改动文件清单 + plans/task-tplrender-20261024/verification.md | 全 VC PASS 证据落 verification.md；FAIL → 回炉 | 15min | 0f/0l/15min | 无 | S13 | done |
| S15 | 合并回+部署+清理+主仓复验 | 继承(主进程白名单②) | worktree 路径 + 文件级 cp 部署（memory 教训：不依赖 --deploy） | merge commit+部署位 diff=0（VC-7）+wt/分支清理+主仓 Read 复验 | 15min | 0f/0l/15min | 无 | S14 | done |

<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号③ 遗留 wt/task-v168-machine-parked 分支 1 个=历史遗留不碰；信号④ 7 个未完成任务在册=并行会话风险，隔离必需；信号① 为本计划自身目录） |
| `isolation` | `worktree`（实现类默认首选——改 init-session.sh/templates/SKILL.md 均为运行中基础设施） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-tplrender-20261024` |
| `branch` | `wt/task-tplrender-20261024` |
| `merge_back` | `merged(merge commit 见 git log --grep tplrender 首条)` |

> 契约详见 `${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/references/methodology.md §R2）

<!--
  WHAT: 对每个 Phase 枚举失败模式，打 S(严重度)/O(频度)/D(探测难度) 各 1-10 分，RPN=S×O×D。
  WHY: RPN>100 的高风险 Phase 必须预先登记兜底动作（对齐 Rule 22.3 五档兜底链，task-v113 后含 22.3.0 资料先行档），避免执行期临时决策。
  WHEN: 计划创建时填写（高 RPN 项）；纯文档/调研类小任务可写 n/a。
  开关键: config.json#fmea_enforce（默认 warn；enforce 档下 RPN>100 无兜底登记 = 计划无效）。
-->

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2 | sed 特殊字符（`${TASK_PLANNER_ROOT:-…}` 含 `$/{/}/:-`）转义翻车 | 5 | 5 | 2 | 50 | 换 bash 内建串替换或 awk index 定位（22.3② 换法）；S5 实弹兜底验证 |
| Phase 3 | 语义占位被误替换（尖括号形态甄别错） | 7 | 4 | 3 | 84 | 边界清单先行（S1）；S12 回归+S14 独立终验双拦截 |
| Phase 3 | variant/模板盘点遗漏致产物残留 | 6 | 6 | 4 | 144 | 渲染残留校验 exit 1 fail-closed 机器兜底（22.3⑤ 前置拦截）；S1 边界清单基于调查③ 全量占位符表；S5 实弹 |
| Phase 5 | selftest 级联面爆炸修复量超预估 | 6 | 5 | 2 | 60 | S13 按批 ≤2f 续派；基线快照区分预存 FAIL 与新增 FAIL |

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

> 契约详见 `${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for storing tasks? (JSON file)
-->
1. 渲染变量集最小完备集是什么？（→S1 定稿：task-id/任务名/日期/日期时间/根路径/计划目录路径 ≥6 个）
2. 语义占位与机械占位的机械可判边界是什么？（→S1 定稿：尖括号中文形态+`#N`+`<按需增行>` 类=模型填写；ASCII token+日期形态=脚本渲染）
3. 27 处 `${TASK_PLANNER_ROOT:-…}` markdown 死串如何安全展开？（→兼容映射表单列，S5 实弹验证）

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
| silent: 选 {{VAR}} 双花括号显式 token 为新契约形态（方案 Y：核心 7+项目级模板 token 化，variant 29 文件零迁移由渲染层兼容映射兜底） | `{{` 形态仓内零占用无歧义；残留可机械校验（fail-closed）；diff 收敛 90%（42→8 文件）；用户原话「引入变量…脚本通过变量传参」正中此形态 |
| silent: 渲染时机=init 内 copy_template 之后 attest 之前 | attest 锁定计划 SHA 前完成替换无冲突（调查⑥）；产物即开即用 |
| silent: 不新增 Rule 编号、不新增守护脚本 | 机械层改造由既有 Rule 34/37 模板域管辖；渲染残留校验为脚本内建行为非守护；守卫机器化 opt-in（宪法 §四.6） |
| silent: 27 处 ${TASK_PLANNER_ROOT:-…} markdown 死串顺带修复（展开为真实路径） | 属"减少路径检索"诉求直接命中面；永不展开=既存 bug（调查②③） |
| 自动裁决: D1 计划确认按 Rule 44.3+Rule 95 执行优先推进（超时 5min，默认项=按本计划执行） | autonomous 会话用户不在场；Rule 95（2026-10-23 用户裁决）禁零报错停等；被覆盖选项=无限等待 yes |

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
  完整模板: ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/templates/batch_report.md | 规则详解: ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/references/batch-quality-gate.md
-->
| 字段 | 值 |
|------|-----|
| `total` | 5（S6-S10 模板 token 化并行批，parallel-group:tpl） |
| `success` | 5（各单元自检+主进程 git diff 复核全过；commit b983b3b） |
| `failed` | 0 |
| `failure_rate` | 0%（≤5% 放行） |
| `sampled_pass` | 3/3（S6 task_plan 模板/S9 verification+S10 项目级——主进程 diff 抽查+worktree grep 断言复核） |
| `sampled_fail` | 0（批前探针=S1 契约清单先行+task_plan 模板 S6 首发验收通过后才放行 S7-S10 并行） |
| `pre_check` | Q1:否（单元间零重叠文件）/Q2:有（检查点 06-10 逐单元落盘）/Q3:能（worktree+commit b983b3b 可整体回退） |
| `rollback_point` | commit c722261（批前 master tip；实测未触发回退） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 子代理占比需要可见反馈闭环;委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
  WHEN: 每个 Phase complete 后更新;终验交付前必须完整。
-->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（Phase 2/3/4 执行体=子代理；Phase 5 内 S12/S13/S13b/S14/CR 亦全子代理） |
| 主进程直做 Phase 清单 | Phase 1（② 计划系统文件维护与 git 编排）、Phase 5（② git 编排+簿记；S-unit 级工作全委派） |
| 委派率 | S-unit 级 12/14 委派=0.86（主进程直做=S1 契约/S2 worktree/S15 合并部署，均白名单②登记）≥0.7 达标 |
| 激活子代理数（Rule 96.5） | 9（Explore×3 含 2 失败改派、general-purpose×1、general-coder×5、Code Assistant×1、code-runner×1、Verifier×1、Code Reviewer×2 轮） |
| 最大并行宽度（Rule 96.5） | 1 组（tpl）/ 最宽 4（S6-S9 同消息并行） |
| 串行化例外理由（Rule 96.4） | S3→S4→S13→S13b 同文件依赖链；S12→S13 依赖 FAIL 清单；S14→S15 终验后置 none |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
<!--
  WHEN: 每次 Agent() 派发前填一行;子代理返回 30s 内主进程必须 Read 实际产出 + 紧邻 Edit findings.md 回填结论(「findings 落点」列记段落锚点),两动作完成才在「备注」列勾 verify_done;failed/timeout 行必须回填 checkpoint 路径列(Rule 22.8.4)
  WHY: 子代理规模限制 + 交接文件保障(Rule 22);findings 回填绑定(Rule 19.1/22.5)防止结论只留会话记忆
  状态枚举: queued/pending/running/done/partial/timeout/failed/blocked/scaling-redispatch(22.3.1 provider 失败改派)
  列说明: 备注列 = 低频列折叠单列(rescue 换档挽救记录 档位/结果/时间,failed|timeout 行必填,Rule 22.7;retry_count = 22.3 retry_limit 计数,初值 0,每次重试 +1;verify_done☐ = Read 产出 + findings 复核/回填双条件,Rule 22.5)——字段内容不删,仅列位折叠;verify_done 无机器消费(grep 实证 scripts/*.sh 除 selftest 零命中),为人工义务,不声称机器门
  派发 prompt 八字段模板: ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/templates/subagent_dispatch.md
  # [2026-09-27 task-v091 B-2] 单写者澄清+Handoff 低频列折叠（verify_done 无机器消费如实披露）
-->

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-24 04:2x | Explore | 调查 init/模板机制现状 | failed | provider rate-limited，零产出 | - | - | （未落盘） | retry→#2 / 1 / ☐ |
| 2 | 2026-10-24 04:3x | Explore | 同上（重试） | failed | provider Headers Timeout，零产出 | - | - | （未落盘） | 22.3.1 改派 general-purpose→#3 / 2 / ☐ |
| 3 | 2026-10-24 04:4x | general-purpose | 同上 | done | init 参数面/零替换逻辑/占位符 27+8+35+10 分布/selftest 级联 9 脚本/渲染先例 register-hooks-cj.ts | init-session.sh:83-97,395,479 | findings §Research ①-⑧ | plans/task-tplrender-20261024/subagent-state/01-explore-init-mechanism.md | - / 0 / ☑ |
| 4 | 2026-10-24 05:0x | general-coder | S3 渲染函数主体 | done | +103/-0 零既有行改动；6 变量 sed 序列+转义助手+变量表头注释；PROJECT_NAME 实为 L395 变量名 | init-session.sh:99-200 | findings 待终验后终稿 | subagent-state/03-render-fn.md | - / 0 / ☑ |
| 5 | 2026-10-24 05:1x | general-coder | S4 兼容映射+校验+接线 | running | +182/-0 已写完；发现跨单元 {{VAR}} 注释冲突上报，裁决 B 后完成验收中 | init-session.sh:243,982 | findings 跨单元冲突判例 | subagent-state/04-compat-wiring.md | 裁决 B 已下达 / 0 / ☐ |
| 6 | 2026-10-24 05:1x | general-coder | S6 task_plan 模板 token 化 | done | 14 处替换+1 注释；语义占位保留；自检全过 | templates/task_plan.md | findings Phase 3 结果 | subagent-state/06-task-plan-token.md | - / 0 / ☑ |
| 7 | 2026-10-24 05:1x | general-coder | S7 会话日志+便签 token 化 | done | 4 处替换+2 注释；#N 示例保留；上报 {{VAR}} 冲突 | templates/user-session-log.md | findings Phase 3 结果 | subagent-state/07-sessionlog-token.md | - / 0 / ☑ |
| 8 | 2026-10-24 05:1x | general-coder | S8 进度+发现模板 token 化 | done | 2 处替换+2 注释；[Title] 保留 | templates/progress.md | findings Phase 3 结果 | subagent-state/08-progress-findings-token.md | - / 0 / ☑ |
| 9 | 2026-10-24 05:1x | general-coder | S9 验证+知识模板 token 化 | done | 3 处替换+2 注释；上报 {{VAR}} 冲突+沙箱复现 | templates/verification.md | findings Phase 3 结果 | subagent-state/09-verify-kb-token.md | - / 0 / ☑ |
| 10 | 2026-10-24 05:2x | general-coder | S10 项目级模板双轨对齐 | done | 2 处替换+1 注释；与内建 §1-6 一致 | .zcode/plan-templates/knowledge-brief.md | findings Phase 3 结果 | subagent-state/10-project-kb-token.md | - / 0 / ☑ |
| 11 | 2026-10-24 05:4x | Code Assistant | S11 SKILL.md 指示面 | done | +3/-2；:41 渲染契约+:40 命令形态+:234 示例同步 | SKILL.md:41 | progress Phase 4 | subagent-state/11-skill-md.md | - / 0 / ☑ |
| 12 | 2026-10-24 05:5x | code-runner-agent | S12 全量回归 | partial | 93 脚本 91 PASS 2 FAIL（PT-26/SL-07 断言语义过期，根因=新渲染行为）；基线复现确认非既有 | selftest-plan-tier.sh:368 | progress Phase 5 | subagent-state/12-regression.md | 交 S13 / 0 / ☑ |
| 13 | 2026-10-24 05:5x | general-coder | S13 两处断言适配 | done | PT-26 断言收紧为传参任务名+SL-07 改锚定 echo 语句；全量 93/93 | selftest-{plan-tier,session-log}.sh | progress Phase 5 | subagent-state/13-cascade-fix.md | - / 0 / ☑ |
| 14 | 2026-10-24 06:0x | verifier | S14 独立终验 | done | VC-1..6 全 PASS（VC-2.4 规格措辞修正：渲染值=安装位置派生）；合并前置 PASS；范围自检 12 文件零越界 | subagent-state/14-final-verify.md | progress Phase 5 | subagent-state/14-final-verify.md | - / 0 / ☑ |

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
- 处置登记处: **不沉淀**——本任务属 skill 基建维护类（改 init 脚本+核心模板），历史上同此类任务均用 general 档（task-v17x 系判例），无独立工序轴可复用，沉淀 variant 反增模板面维护负担；若后续"模板渲染类"任务复现 ≥3 次再按 34.3 评估
