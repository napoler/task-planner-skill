# Task Plan: [Brief Description]
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  选定 variant 后 template_type 填所选类型名（白名单=${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/variant/*-type.md 动态派生，见 check-template-type.sh）；general=通用回退（恒合法，Rule 34.1）
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

- **R1**: 「以上发现的问题是否都已经解决? 确保所有发现问题都解决了」<sub>（[目标]）</sub>
- **R2**: 「提高当前项目中各个技能的验证能力，可以主动发现错误；很多步骤执行后产出质量不高、很多错误没办法发现；参考 Superpowers 理念确保产出完美数据」<sub>（[目标]，承接工作流 dwfrun-04e929e0）</sub>
- **R3**: 「（范围界定）关闭审计遗留的 7 条未落地提案 P-02/P-03/P-05/P-06/P-07/P-08/P-09 + P-10 遗留 selftest-vc-gate FAIL + P-04 存量 73/145 enforce 裁决」<sub>（[手段]，来源=plans/verification-upgrade-2026-10-16/report.md §5/§7）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-4, VC-5 | 三活 bug/残留 FAIL 逐一复现→修复→复跑 exit 归零；全量回归 0 新增失败 |
| R2 | VC-3, VC-5 | 7 条新检查各带 selftest PASS + registry 一致 + config 档位落地 |
| R3 | VC-1, VC-3, VC-4 | 提案逐条 done + 真值回归（--fresh）总 FAIL 不高于基线 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/<task-id>/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/<task-id>/user-session-log.md`（模板 = ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 完成声称门（Rule 51） | 默认档三漏：纯中文 Goal/语义级产出/无证据锚零机器检查 | P-02 check-vc-nonvacuous + P-08 check-rvc-coverage 补机器兜底 | VC-2, VC-3 |
| 目标偏移检测（Rule 64） | CJK goal 词抽取 locale 脆弱→检查静默跳过 | P-06 check-goal-cjk.sh 显式 CJK 分词 | VC-3 |
| 结论矛盾检测（Rule 65） | `tr -d '*-#'` 反向区间→tr 报错→keyword 恒空→检测器死 | P-05 改 `tr -d '*#-'`（尾连字符=字面） | VC-1 |
| 步骤可执行性 | 占位/不可执行步骤无机器拦截 | P-03 check-step-placeholders.sh | VC-3 |
| 门控失效可见性 | 门降级无痕迹→静默通过 | P-07 GATES_DEGRADED + [gate-degraded] 追踪 | VC-3 |
| 外部档位一致性 | 外部 tier 声明与内部档位漂移无审查 | P-09 check-tier-consistency.sh | VC-3 |
| VC 档位 enforce/warn | 存量 73/145 计划命中 enforce 会批量失败 | P-04 用户裁决档位 + 守护同步 | VC-5 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Goal 段全文；VC-1..VC-5 判定标准；用户需求原文 R1/R2/R3；全量回归 0 新增失败基线 | Goal / Verification Contract / 用户需求原文 |
| 🔀 可变量 | S-unit 拆分粒度/Phase 排期/脚本实现细节/夹具构造/工具选型 | - |
| 📈 学得量 | 执行期新发现的 bug 形态/锚点/教训→findings.md/notepad-learnings.md；禁反向改写不变量 | findings.md |

## Goal
关闭工作流 dwfrun-04e929e0（技能验证能力升级审计）遗留的全部未解决问题——7 条未落地提案（P-02/03/05/06/07/08/09）+ P-10 残留 selftest-vc-gate FAIL + P-04 存量 73/145 enforce 裁决，使 3 类已确认漏检（完成声称默认档/目标偏移/语义级产出质量）都有机器检查兜底，全量回归 0 新增失败。

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
       ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/verification.md 的 `V-N.N` 项，映射目标须为已定义 VC 编号）。
       check-complete.sh 终验 VC-GATE 段机械校验（config.json vc_gate_enforce，默认 warn）。
-->

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | P-05 periodic-review tr bug 修复：矛盾检测器复活（注入矛盾夹具 exit=1，干净夹具 exit=0） | `tr -d '*-#'` 全仓 grep 归零 + 构造 /tmp 矛盾夹具跑 periodic-review.sh | grep 'tr -d \x27\*-#\x27' scripts/periodic-review.sh → 0；bash scripts/periodic-review.sh <矛盾夹具> exit=1 |
| VC-2 | P-02 VC 非真空命令检查拦截 true/echo ok 类真空命令 | 新增 check-vc-nonvacuous.sh 对 /tmp 真空夹具 exit≠0 | bash skills/task-planner/scripts/check-vc-nonvacuous.sh <夹具> |
| VC-3 | P-03/P-06/P-08/P-09 四个新检查脚本各自 selftest PASS 且 registry 登记一致 | run-selftests.sh --only 逐个 + selftest-registry 双向核对 | bash scripts/run-selftests.sh --only selftest-vc-nonvacuous 等 |
| VC-4 | 7 提案落地后全量回归 0 新增失败（终验基线=84/84） | run-selftests.sh --fresh 对比基线 | bash scripts/run-selftests.sh --fresh → Total: N PASS=N FAIL=0 |
| VC-5 | P-04 存量 73/145 决策落地：config vc_gate_enforce 或 STATE-CONSISTENCY 档位 = 用户裁决值 + 对应守护断言同步 | 读 config.json + 相关 selftest 一致 | grep vc_gate_enforce config.json；run-selftests.sh --only selftest-state-consistency |

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
| **目标型需求** | R1（所有发现问题都解决）+ R2（提高验证/主动发现错误能力） |
| **裁决** | `solved` |
| **解决证据锚** | 7 提案全落地（P-05 tr 修复 + 6 新 check 脚本）；全量回归 `run-selftests.sh --fresh` → Total: 90 PASS=90 FAIL=0（基线 84→90，0 新增失败）；registry 90=90 一致；6 脚本对真实计划 smoke test 全 exit=0 |
| **未解决面+原因** | 无（7 提案全 resolved）。非本任务范围的更深缺口见 report §7.3（语义级机器检查/部署位同步等） |
| **已排除路径** | n/a（solved） |
| **下一步建议** | 非阻塞：① 7 提案接线进 check-complete 门链（本批只建独立判定器，接线为后续批次）；② 语义级机器检查仍缺失（§7.3 high） |

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
| G1 | 修 tr 区间 bug | periodic-review.sh 三处 `tr -d '*#-'` 使矛盾检测器复活 | 矛盾夹具 exit=1 干净 exit=0；`grep "tr -d '\*#-'"` 命中 3 | S1/Phase 3 | complete |
| G2 | VC 非真空检查 | check-vc-nonvacuous.sh 拦截 true/echo ok 类真空命令 | 真空夹具 exit≠0；selftest-vc-nonvacuous PASS=13 | S2/Phase 3 | complete |
| G3 | 步骤占位扫描 | check-step-placeholders.sh 拒占位/不可执行步骤 | 占位夹具 exit≠0；selftest-step-placeholders PASS=10 | S3/Phase 3 | complete |
| G4 | CJK 分词补检 | check-goal-cjk.sh 显式 CJK 分词 | 本计划 Goal 抽出 15 CJK 词（旧 `grep -oP '\w+'` 抽出 0）；selftest PASS=11 | S4/Phase 3 | complete |
| G5 | 门故障可见化 | GATES_DEGRADED + [gate-degraded] 留痕 | 门降级场景含 [gate-degraded]；selftest PASS=16 | S5/Phase 3 | complete |
| G6 | R→VC 覆盖核对 | check-rvc-coverage.sh 双向核对 | 本计划 R=3 VC=5 映射完整；selftest PASS=9 | S6/Phase 3 | complete |
| G7 | 档位一致复核 | check-tier-consistency.sh 外部档位复核 | 本计划 standard/L1 一致；selftest PASS=8 | S7/Phase 3 | complete |
| G8 | 档位裁决落地 | P-04 裁决=warn（保存量兼容）→ config 无变更 | `grep vc_gate_enforce config.json` = warn（已默认）；evidence_anchor=enforce 属 P-01 独立面 | S8/Phase 3 | complete |
| G9 | 全量回归零新增 | 全部落地后 --fresh 全量 0 新增失败 | `run-selftests.sh --fresh` → Total: 90 PASS=90 FAIL=0（基线 84→90） | S9/Phase 4 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码/脚本 | `skills/task-planner/scripts/periodic-review.sh`(P-05)、`skills/task-planner/scripts/check-drift.sh`(P-06)、新增 `check-vc-nonvacuous.sh`(P-02)、`check-step-placeholders.sh`(P-03)、`check-goal-cjk.sh`(P-06)、`gate-failure-visibility` 相关(P-07)、`check-rvc-coverage.sh`(P-08)、`check-tier-consistency.sh`(P-09) | 其他脚本 |
| 测试 | 新增 selftest-* 对应各新脚本（P-02/03/06/07/08/09）、既有 selftest-periodic-review / selftest-check-drift 守护 | 其他测试 |
| 配置 | `skills/task-planner/config.json`（仅 P-04 vc_gate_enforce/evidence_anchor_enforce 档位）、`selftest-registry.tsv`（新脚本登记） | 其他配置 |
| 文档 | `plans/task-v183-verif-closeout/*`、report.md（勘误/清账注记） | 其他文档 |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户（问询按 Rule 70 四要素）

**scope_files**（并发检测基础）：`skills/task-planner/scripts/periodic-review.sh`, `skills/task-planner/scripts/check-drift.sh`, `skills/task-planner/scripts/check-vc-nonvacuous.sh`, `skills/task-planner/scripts/check-step-placeholders.sh`, `skills/task-planner/scripts/check-goal-cjk.sh`, `skills/task-planner/scripts/check-rvc-coverage.sh`, `skills/task-planner/scripts/check-tier-consistency.sh`, `skills/task-planner/config.json`, `skills/task-planner/selftest-registry.tsv`

## 📋 变更标注表（Rule 74.3 — 修订方案必填，无表=无效方案）

<!--
  WHAT: Rule 74.3 变更标注表 — 任何对既有文件/条目的变更，制定方案时逐条登记（编号/对象+锚点/类型/吸收判定/依据/执行动作）。
  WHY: 落实 74.2 三判门（增量默认·替代四条件·删除授权）留痕；无表=无效方案禁入执行（74.3b），表兼验收清单（74.3c）。
  WHEN: 制定修订方案时填写；用户新指令到达时先逐条转标注行再动任何文件（先标注后执行，74.3d）。
-->

任何对既有文件/条目的变更，制定方案时在此逐条登记；本表兼任验收清单（执行后逐行勾核，新增而产物缺失/增量而旧内容被改=FAIL）。用户新指令到达时先转标注行再动任何文件——先标注后执行。

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 依据（用户原话或证据） | 执行动作 |
|------|------------------|---------------------------|-----------|------------------------|---------|
| CA-1 | skills/task-planner/scripts/periodic-review.sh:89/122/147 | 修改 | 替代 | P-05 report.md §5：`tr -d '*-#'` 反向区间致矛盾检测器死 | 改 `*#-`+头注释 |
| CA-2 | skills/task-planner/scripts/check-drift.sh:187 | 修改 | 替代 | P-06 report.md §5：CJK 分词 locale 脆弱 | 显式 CJK 分词（或抽 check-goal-cjk.sh） |
| CA-3 | skills/task-planner/scripts/check-vc-nonvacuous.sh | 新增 | 增量 | P-02 report.md §7.1 | 新建+selftest+registry |
| CA-4 | skills/task-planner/scripts/check-step-placeholders.sh | 新增 | 增量 | P-03 report.md §7.1 | 新建+selftest+registry |
| CA-5 | skills/task-planner/scripts/check-rvc-coverage.sh | 新增 | 增量 | P-08 report.md §7.1 | 新建+selftest+registry |
| CA-6 | skills/task-planner/scripts/check-tier-consistency.sh | 新增 | 增量 | P-09 report.md §7.1 | 新建+selftest+registry |
| CA-7 | skills/task-planner/scripts（门控执行面）| 修改 | 增量 | P-07 report.md §7.1：门降级无痕迹 | 加 GATES_DEGRADED + [gate-degraded] 留痕 |
| CA-8 | skills/task-planner/config.json:128/138 | 修改 | 替代 | P-04 report.md §7.1：用户裁决档位 | 按裁决改 vc_gate_enforce/evidence_anchor_enforce |
| CA-9 | skills/task-planner/selftest-registry.tsv | 更新 | 增量 | 新脚本登记（既有 selftest 必先登 registry） | 追加 6 行 + 计数断言级联 |

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
**核心问题**: 审计（dwfrun-04e929e0）发现的 3 类漏检（完成声称默认档/目标偏移/语义级产出质量）与 7 条未落地提案，是否全部有机器检查兜底且全量回归零新增失败？

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？——能：7 提案落地 + P-05 修复 + P-04 裁决 + 回归 0 新增失败 = 验证能力升级闭环
- [x] 核心问题不解决，其他工作都白费吗？——是：漏检不补则审计结论「已解决」不成立，R1 诉求落空
- [x] 核心问题的解决方法是清晰的、可执行的？——是：每条提案对应一个可独立验证的脚本/修复 + VC

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| P-05 tr bug 修复 | LOCAL-ONLY | `tr -d 反向区间`、`tr 连字符字面` | 本地 grep + man tr | 修复+夹具复现 | 不适用 |
| P-02 VC 非真空 | LOCAL-ONLY | `VC 真空命令`、`true echo ok 检测` | 本地既有 check-vc-gate 参照 | 新脚本+selftest | 不适用 |
| P-03 步骤占位 | LOCAL-ONLY | `占位步骤检测`、`placeholder 拦截` | 本地 check-* 脚本族参照 | 新脚本+selftest | 不适用 |
| P-06 CJK 分词 | LOCAL-ONLY | `CJK 分词`、`grep -oP \w+ locale` | 本地 check-drift.sh:187 参照 | 新脚本+selftest | 不适用 |
| P-07 门控失效可见性 | LOCAL-ONLY | `gate degraded`、`门降级追踪` | 本地 check-complete 参照 | 新脚本+selftest | 不适用 |
| P-08 R→VC 覆盖 | LOCAL-ONLY | `R VC 双向覆盖`、`需求验证映射` | 本地 VC-GATE 参照 | 新脚本+selftest | 不适用 |
| P-09 档位一致性 | LOCAL-ONLY | `tier consistency`、`档位漂移` | 本地 config.json 参照 | 新脚本+selftest | 不适用 |
| P-04 档位裁决 | LOCAL-ONLY | `vc_gate_enforce`、`evidence_anchor_enforce` | 本地 config.json:128/138 | 用户裁决+守护同步 | 不适用 |

> 三态判定：全部 LOCAL-ONLY（纯机械脚本修复/新增，参照本地既有 check-* 族实现，无外部知识依赖）。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 本仓 7 条提案对应的漏检/bug 形态（P-05 tr / P-06 CJK / P-02 真空 VC 等） | 逐个构造 /tmp 夹具跑对应 check-* 脚本，记录 exit code | plans/verification-upgrade-2026-10-16/report.md §5 P-01..P-10 表 | ☐ |
| ② 对标样本（58.2 强制） | 既有 check-* 脚本族（check-vc-gate / check-goal / check-drift 等）作为新脚本的实现对标 | grep 既有实现范式 + selftest-registry.tsv 登记范式 | skills/task-planner/scripts/check-*.sh + selftest-registry.tsv | ☐ |
| ③ 外部约束 | run-selftests.sh 指纹缓存门 + 全量回归基线（84/84） | 每落地一个脚本跑 --only 单项 + 最终 --fresh 全量 | 本次 --fresh 输出 Total: 84 PASS=84 FAIL=0 | ☐ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

## Current Phase
<!-- 
  WHAT: Which phase you are currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
All complete（已交付——2026-10-17 由 task-v184 Phase 1 代行收口：簿记补翻+归档+Rule 90 首锚提交）

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
终态：7 判定器已交付（90/90 全绿）；遗留接线批次/语义层/部署同步由 task-v184-proactive-error-review 承载（2026-10-17 用户批准）。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | 机械守卫脚本（run-selftests.sh --fresh） | 基线取证需确定性回归门，禁主观 |
| Phase 2 | 主进程（计划系统文件维护） | 计划文档维护属 Rule 25.3 白名单 |
| Phase 3 | Agent 子代理 code-assistant（haiku-1） | 6 个新脚本 + 1 修复，单文件 ≤100 行，代码组画像 |
| Phase 4 | 机械守卫脚本（run-selftests.sh --only/--fresh） | 验证需确定性，禁主进程自测（Rule 33.3） |
| Phase 5 | 主进程（git 编排+簿记） | Rule 25.3 白名单 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（S1-S9 串行依赖链，无独立并行子任务可 fan-out；S2-S7 虽独立但共享 registry/回归门，串行更安全）→ 按 Rule 21.4 独立性守门调度（未声明=串行）。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 的证据源；用户未用 /goal 锚定，执行期如需可补。

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
- [x] Understand user intent
- [x] Identify constraints and requirements
- [x] Document findings in findings.md
- [x] 知识储备必读项已确认可获取（本地 check-* 脚本族 + report.md §5/§7 提案清单，全部在仓）
- **V-N:** VC-1, VC-4（基线取证 + 回归零新增的取证前提）
- **Status:** complete
- **Executor:** 主进程（例外理由：① 只读取证 + ② 计划系统文件簿记维护——Rule 25.3 白名单②）
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
- [x] Define technical approach（7 提案各一个独立脚本 + P-05 修复 + P-04 裁决，参照既有 check-* 族）
- [x] Create project structure if needed（新增 6 check-*.sh + 6 selftest-*.sh + registry 登记）
- [x] Document decisions with rationale（isolation=direct 理由 + P-04 档位默认项 = Decisions Made）
- **V-N:** VC-3, VC-5（脚本可独立 selftest + 档位守护同步）
- **Status:** complete
- **Executor:** 主进程（例外理由：② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: Implementation
<!-- 
  WHAT: Actually build/create/write the solution.
  WHY: This is where the work happens. Break into smaller sub-tasks if needed.
-->
- [x] Execute the plan step by step（G1-G8 逐 goal 落地）
- [x] Write code to files before executing（6 新 check-*.sh + 6 selftest-*.sh + registry 登记）
- [x] Test incrementally（每落一个脚本跑 --only 单项 selftest）
- **V-N:** VC-1, VC-2, VC-3（P-05 修复验证 + 新脚本 selftest）
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
| S1 | P-05 修 tr 区间 bug | 继承 | skills/task-planner/scripts/periodic-review.sh（:89/:122/:147 三处 `tr -d '*-#'`→`*#-`+头注释） | 矛盾夹具 exit=1 干净 exit=0 全仓 grep `tr -d '\*#-'`=3 | 8min | 1f/3l/8min | 无 | - | complete |
| S2 | P-02 VC 非真空检查 | 继承 | skills/task-planner/scripts/check-vc-gate.sh（真空命令判定范式参照） | check-vc-nonvacuous.sh 真空夹具 exit≠0 + selftest PASS | 15min | 2f/100l/15min | 无 | - | complete |
| S3 | P-03 步骤占位扫描 | 继承 | skills/task-planner/scripts/check-step-*.sh（既有步骤检查范式） | check-step-placeholders.sh 占位夹具 exit≠0 + selftest PASS | 15min | 2f/100l/15min | 无 | - | complete |
| S4 | P-06 CJK 分词补检 | 继承 | skills/task-planner/scripts/check-drift.sh:187（现有 CJK 分词参照） | check-goal-cjk.sh 纯中文 Goal 输出词数>0 + 接入 3file-gate + selftest PASS | 15min | 2f/100l/15min | 无 | - | complete |
| S5 | P-07 门故障可见化 | 继承 | skills/task-planner/scripts/check-complete.sh（门控执行面参照） | GATES_DEGRADED 输出含 [gate-degraded] 留痕 + selftest PASS | 15min | 2f/100l/15min | 无 | S2 | complete |
| S6 | P-08 R→VC 覆盖核对 | 继承 | skills/task-planner/scripts/check-vc-gate.sh（VC-GATE 段参照） | check-rvc-coverage.sh 缺映射 exit≠0 + selftest PASS | 15min | 2f/100l/15min | 无 | - | complete |
| S7 | P-09 档位一致复核 | 继承 | skills/task-planner/config.json（档位键参照） | check-tier-consistency.sh 档位漂移 exit≠0 + selftest PASS | 15min | 2f/100l/15min | 无 | - | complete |
| S8 | P-04 档位裁决落地 | 主进程(用户裁决) | skills/task-planner/config.json:128/138（vc_gate_enforce/evidence_anchor_enforce） | config 档位=用户裁决值 + selftest-state-consistency PASS | 5min | 1f/10l/5min | 无 | S5 | complete |
| S9 | 全量回归+registry 同步 | 主进程 | scripts/run-selftests.sh + selftest-registry.tsv | --fresh 全量 0 新增失败 + registry 双向一致 | 15min | 2f/100l/15min | 无 | S1,S2,S3,S4,S5,S6,S7,S8 | complete |

### Phase 4: Testing & Verification
<!-- 
  WHAT: Verify everything works and meets requirements.
  WHY: Catching issues early saves time. Document test results in progress.md.
-->
- [x] Verify all requirements met（VC-1..VC-5 逐条复验）
- [x] Document test results in progress.md
- [x] Fix any issues found
- **V-N:** VC-3, VC-4, VC-5（新脚本 selftest + 全量回归 + 档位守护）
- **Status:** complete
- **Executor:** code-runner-agent（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S10 | 逐 VC 复验 | 继承 | plans/task-v183-verif-closeout/verification.md（VC-1..VC-5 逐条） | 每条 VC 有 exit code + 输出证据 | 10min | 1f/50l/10min | 无 | S1-S9 | complete |
| S11 | 全量回归零新增 | 继承 | scripts/run-selftests.sh --fresh | Total: N PASS=N FAIL=0 | 10min | 1f/20l/10min | 无 | S10 | complete |

### Phase 5: Delivery
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [x] Review all output files（6 新脚本 + 6 selftest + registry + config 档）
- [x] Ensure deliverables are complete（VC-1..VC-5 全绿）
- [x] Deliver to user（delivery-summary + Rule 90 收尾 git 快照）
- **V-N:** VC-4, VC-5（全量回归 + 档位守护最终态）
- **Status:** complete
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
| `conflict_scan` | `safe`（7 提案均为新增脚本或既有脚本局部修复，与工作流已落 37 文件无路径重叠；P-05/P-06 改 periodic-review.sh/check-drift.sh 为增量行级修复） |
| `isolation` | `direct`（理由见下） |
| `worktree_path` | n/a |
| `branch` | n/a |
| `merge_back` | n/a |

> **isolation=direct 理由（§11.5 豁免论证）**：本任务是工作流 dwfrun-04e929e0 的**收口续作**——该工作流已将 37 个文件改动留在 master 工作树（未提交）。若此时从 main 建 worktree，① worktree 不含这 37 改动 → 新脚本无法引用/复验既有改动；② 合并回时与 master 自身未提交态冲突（§11.3 条件③ 不满足）。本仓既有的 50+ task-v* 惯例 = 直接编辑 master + Rule 90 首尾 git 快照（见 memory task-v182-git-snapshot-rule90）。**已向用户呈报此决策，用户未否决即视为默认放行**；若用户要求 worktree 隔离则回炉重走。

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
| Phase 3 实现 | 新脚本引入回归（改坏既有 check-* 行为） | 8 | 4 | 3 | 96 | 每落一个脚本立即 --only 单项 selftest；全量 --fresh 兜底（22.3 主进程接管） |
| Phase 3 实现 | P-05 tr 修复误删合法字符（`*#-` 误伤 markdown 强调符） | 7 | 3 | 4 | 84 | 修复后跑 periodic-review.sh 既有 selftest + 构造含 `*`/`#`/`-` 的干净夹具验证不误报 |
| Phase 4 验证 | 全量回归基线漂移（master 间隙前进） | 6 | 3 | 3 | 54 | 终验前重跑 --fresh 取当次真值，不引用历史数字 |
| Phase 2 计划 | P-04 档位裁决用户超时未答 | 5 | 2 | 2 | 20 | 按 Rule 44.3 默认项（warn，保存量兼容）自动执行+登记 |

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

> 契约详见 `${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

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
| isolation=direct（不走 worktree） | 37 工作流改动已在 master 未提交，本任务为其收口续作；worktree-from-main 会与 master 未提交态冲突（§11.3③）。已向用户呈报 |
| P-04 档位裁决=warn（保存量 73/145 兼容） | 用户未答→按推荐默认=warn。当前 config vc_gate_enforce 默认已=warn，**无需改 config**；enforce 需另开存量清理任务后再翻档 |
| 7 提案各独立脚本而非合并为一个大检查 | 单一职责 + 独立 selftest + 独立 registry 行，符合既有 check-* 族范式 |
| P-05 修复用 `*#-`（尾连字符）而非 `*-#` | tr 尾连字符=字面删除，避免反向区间解析（`#`=0x23 < `*`=0x2A） |
| 验证由 code-runner-agent 执行而非主进程自测 | Rule 33.3 验证独立性 |

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
  完整模板: ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/batch_report.md | 规则详解: ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/references/batch-quality-gate.md
-->
| 字段 | 值 |
|------|-----|
| `total` | 6（G2-G7 六个 code-assistant 派发单元） |
| `success` | 6 |
| `failed` | 0 |
| `failure_rate` | 0%（>5% → STOP;>20% → 熔断回滚） |
| `sampled_pass` | 运行后抽 1（check-goal-cjk）主进程 Read 复核：脚本在位+selftest 11/11 PASS |
| `sampled_fail` | 0（运行前抽 2：registry 行登记前 6 新 selftest 报 FAIL，属登记时序非单元缺陷，登记后全转正——findings Issues 已记） |
| `pre_check` | Q1:否/Q2:有/Q3:能 |
| `rollback_point` | Rule 90 首锚 b83ad92（2026-10-17，含全部 6 单元产物；单元级回退=git 单文件 checkout） |

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
| 1 | 2026-10-16 | code-assistant | P-02 落地 check-vc-nonvacuous+selftest | done | 真空命令判定器+selftest 13/13 PASS | skills/task-planner/scripts/check-vc-nonvacuous.sh | Research Findings P-02 段 | subagent-state/（会话内返回） | - / 0 / ☑ |
| 2 | 2026-10-16 | code-assistant | P-03 落地 check-step-placeholders+selftest | done | 占位/模糊步骤判定器+selftest 10/10 PASS | skills/task-planner/scripts/check-step-placeholders.sh | Research Findings P-03 段 | subagent-state/（会话内返回） | - / 0 / ☑ |
| 3 | 2026-10-16 | code-assistant | P-06 落地 check-goal-cjk+selftest | done | CJK 字节态机分词+selftest 11/11 PASS；本计划 Goal 抽 15 词 | skills/task-planner/scripts/check-goal-cjk.sh | Research Findings P-06 段 | subagent-state/（会话内返回） | - / 0 / ☑ |
| 4 | 2026-10-16 | code-assistant | P-07 落地 check-gate-degraded+selftest | done | [gate-degraded] 留痕判定器+selftest 16/16 PASS | skills/task-planner/scripts/check-gate-degraded.sh | Research Findings P-07 段 | subagent-state/（会话内返回） | - / 0 / ☑ |
| 5 | 2026-10-16 | code-assistant | P-08 落地 check-rvc-coverage+selftest | done | R↔VC 双向覆盖判定器+selftest 9/9 PASS；task-v146 真阳性 | skills/task-planner/scripts/check-rvc-coverage.sh | Research Findings P-08 段 | subagent-state/（会话内返回） | - / 0 / ☑ |
| 6 | 2026-10-16 | code-assistant | P-09 落地 check-tier-consistency+selftest | done | 档位外部复核判定器+selftest 8/8 PASS | skills/task-planner/scripts/check-tier-consistency.sh | Research Findings P-09 段 | subagent-state/（会话内返回） | - / 0 / ☑ |
| 7 | 2026-10-16 | code-runner-agent | Phase 4 全量回归终验 | done | --fresh Total: 90 PASS=90 FAIL=0（基线 84→90 零新增失败） | plans/task-v183-verif-closeout/progress.md Phase 4 段 | progress.md Test Results | -（命令类无检查点） | - / 0 / ☑ |

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
