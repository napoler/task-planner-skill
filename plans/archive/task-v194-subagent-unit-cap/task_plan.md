# Task Plan: 修复子代理拆分粒度缺陷——单子代理生产单元数量上限（task-v194）
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  选定 variant 后 template_type 填所选类型名（白名单=${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/templates/variant/*-type.md 动态派生，见 check-template-type.sh）；general=通用回退（恒合法，Rule 34.1）
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

- **R1**: 「sess_f74fc164-419a-4ada-b45d-565685da83c7 在这个会话中，单个子代理竟然一次性出，要求子代理一次性处理4篇文章的修正优化工作。这种复杂的任务竟然放在一个子代理中执行，那么已经可以说已经完全背离了单个子代理执行一些就是小任务的。那是一个子代理，我按现在的方案，是一个子代理尽可能执行多的任务，这已经严重违背了原则。」<sub>（[手段]·缺陷实证①：多篇文章打包派发单个子代理）</sub>
- **R2**: 「还有最可怕的是，之前我看到有一个会话在执行视频创作的时候，将整个视频的创作19段，19个片段全部放到一个子代理去生成。这种方案简直就是烂透了。和一一一一完全背离了之前要求子代理中单个任务禁止过长的条约规范。」<sub>（[手段]·缺陷实证②：媒体多单元打包派发单个子代理）</sub>
- **R3**: 「就是，现在目标非常明确，就是在技能中确保所拆分的单个任务不会在单个子代理中执行过多的任务。」<sub>（[目标]）</sub>
- **R4**: 「因为我希望就是比如说调研阶段，调研阶段我也希望可以就是拆分阶段，拆分为多个子代理进行并行调研。不是而不是一次性，比如说一次性调研过多的方向，导致后期混乱。还，就是这样的。一个任务拆分成多个单个任务来解决，来提高准确性。」<sub>（[目标]·B 类扩展 2026-10-21：调研阶段方向粒度与并行拆分）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 | critical-rules-dispatch.md 落地 46.6 数值上限条款，含「内容类 1 单元/派发」上限与判例锚；grep 命中 ≥3 处 |
| R2 | VC-2 | critical-rules-media.md 47.1 增量「1 个生产单元/派发」数值上限句；grep 命中 |
| R3 | VC-1 + VC-2 + VC-4 + VC-5 | 条款落地 + 全量 selftest 零回归 + worktree 合并回 master（命令级证据见 VC 表） |
| R4 | VC-7 | critical-rules-research.md 落地 75.8 调研方向粒度条款（单子代理 1 方向 + 多方向并行多子代理 + 结论分方向落盘）；grep 命中 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/<task-id>/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/task-v194-subagent-unit-cap/user-session-log.md`（模板 = ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 拆分规划（计划期 S-unit 表填写） | 无按任务类型的数量上限表——「4 篇文章」即使三值超标也仅 SKIPPED 提示，无数值判据拦「多单元打包」 | Rule 46.6 单子代理生产单元上限表 | VC-1 |
| 派发执行（主进程写任务书/prompt） | 定性条款（46.1 单会话单 S-unit）无量化口径，且与 S-ID 无关的自然语言罗列（「55, 638, 1009…」）完全绕过 | 46.6 判定口径：可数交付单元计数与是否写 S-ID 无关 | VC-1 |
| 媒体生产派发 | media Rule 47.1 仅定性「单元数 >1 批 → 拆分」，无数值上限；49.5 明示机器不校验 | 47.1 增量数值上限句（1 生产单元/派发，与 46.6 同源） | VC-2 |
| 机器守卫（check-dispatch） | 只数 `S[0-9]+` ID 与步骤序号，不识别自然语言单元量；无活跃计划 fail-open | 本任务不扩张（宪法 §四.6 守护机器化=opt-in）——登记为待审项交用户裁决 | VC-6 |
| 调研阶段派发（方向粒度） | 调研域无任何方向数约束（critical-rules-research.md 全文 grep「并行/单方向/一次调研」零命中）——单子代理可一次性调研过多方向导致后期混乱 | Rule 75.8 调研方向粒度（1 方向/子代理 + 多方向并行多子代理，复用 21.4 并行组） | VC-7 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | 用户需求原文 R1-R4；Goal；VC 表；文本优先边界（不新增脚本/hook/config 键/selftest 断言，宪法 §四.6）；部署位 `~/.zcode/skills/**` 禁改（同步待用户授权）；增量式落地（既有条款 46.1-46.5/47.1/58/63/75 原文逐字保留） | 本计划 R 区/Goal/VC 表/执行范围限制/CA 表 |
| 🔀 可变量 | 46.6 条款具体措辞与数值豁免细节；S-unit 拆分行；Phase 排期；CA-3 指针级联是否触发 | - |
| 📈 学得量 | 执行期新事实/锚点断裂清单 → findings.md；禁反向改写不变量 | findings.md |

## Goal
<!-- 
  WHAT: One clear sentence describing what you're trying to achieve.
  WHY: This is your north star. Re-reading this keeps you focused on the end state.
  EXAMPLE: "Create a Python CLI todo app with add, list, and format functionality."
-->
在 task-planner 技能内为「单个子代理执行过多任务」建立数值化硬上限（task-dispatch 新增 Rule 46.6 单子代理生产单元上限表 + media-planner Rule 47.1 数值化 + plan-research-router 新增 75.8 调研方向粒度条款），使「N 篇文章/N 个视频片段打包派给一个子代理」「单子代理一次性调研过多方向」均有明确可判的违规判据——一个任务拆分为多个单个任务、由多个子代理并行解决以提高准确性，且全量 selftest 零回归、既有条款零删改。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（规则文本条款类任务；独立复审由 Phase 4 critic 承载，对齐审查按 Rule 42.6 收尾） |
| `session_id` | `15b9b671-2b49-4d1d-97e9-6e7e64204dd5` | 启动时生成,注册表追踪 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v194-subagent-unit-cap` | §十一 隔离决策已有字段 |
| `scope_files` | `skills/task-dispatch/references/critical-rules-dispatch.md, skills/media-planner/references/critical-rules-media.md, skills/plan-research-router/references/critical-rules-research.md, skills/task-dispatch/SKILL.md(仅指针级联,如需), skills/plan-research-router/SKILL.md(仅指针级联,如需), skills/task-planner/scripts/selftest-dispatch-grain.sh(仅锚措辞级联)` | 从「执行范围限制」解析,并发检测基础 |
| `interaction_mode` | `ask`（关键决策点给选项；机器化扩张项交用户裁决） | Rule 28 交互模式：ask=关键决策点给选项；silent=静默+静默决策清单登记 |
| `对齐审查` | `[登记]` 终验收尾跑 alignment-review（标准收尾流程） | Rule 42.6 消费：任务产出或更新的文档在完成前跑 alignment-review 对齐审查（标准收尾流程）;文档更新前跑版本一致性校验（未经校验不追加）;变更记录随交付物落盘;mini 档豁免（42.6.4） |
| `自动超时默认项` | `[询问点: 无预置询问点；机器化扩张待审项随计划确认一并裁决，超时默认=不做（§四.6 缺省）]` | Rule 44 消费：本任务所有 2+ 选项询问点逐个登记默认选项（推荐项）与自动超时时长（默认 5 分钟,可覆盖）;低区分度选项（产出一致仅步骤/耗时差异）不询问、直接裁决并登记理由（44.2）;用户超时未答复按默认选项自动执行+登记自动裁决记录五要素（44.3）;mini 档豁免（44.4） |
| `new_rule` | （留空——46.6 为既有 Rule 46 的新子条，无新编号，无 1-92 纪元级联） | Rule 20.6：本任务新增 Rule 编号时填写（attest 自动预留+查重；无则留空） |
| `质量审查工具` | `[登记] Phase 4 critic（sonnet-1）独立复审条款可执行性——既有 agent 名，42.2 四级检测无缺口` | Rule 42 消费登记（42.4）：任务涉及质量审查面时按 42.2 四级检测（含内置 review-library 兜底池）,填 技能名/既有 agent 名/待补充 S-unit 指针;缺口按 42.3 补建并登记 S-unit;执行期必须用登记工具;mini 档豁免（42.5） |

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
| VC-1 | Rule 46.6「单子代理生产单元上限表」落地 critical-rules-dispatch.md（含：内容类 1 单元/派发、媒体类 1 生产单元/派发、批量小操作 ≤5+逐单元检查点、只读豁免+用户显式豁免两类、判定口径与是否写 S-ID 无关） | grep 锚点 + Read 条款全文复核 | 合并回主仓后：`grep -c "46\.6" skills/task-dispatch/references/critical-rules-dispatch.md` ≥3 且 Read 确认五要素齐 |
| VC-2 | media Rule 47.1 数值化增量句落地（单派发 = 1 个生产单元，注明与 46.6 同源），既有「禁整集生成」句逐字保留 | grep + Read | `grep -n "47\.1" skills/media-planner/references/critical-rules-media.md` 输出含数值上限表述；`grep -c "整集生成" 同文件` ≥1（原文保留） |
| VC-3 | 既有粒度锚零回退：46.1「单会话单 S-unit」、59.1 三值门原文未被删改 | grep 既有锚仍命中 | `grep -c "单会话单 S-unit" skills/task-dispatch/references/critical-rules-dispatch.md` ≥1；`grep -c "59\.1" 同文件` ≥1 |
| VC-4 | 全量 selftest 零 FAIL（含必要的既有锚措辞级联修复后） | run-selftests.sh | `bash skills/task-planner/scripts/run-selftests.sh --fresh` exit=0 |
| VC-5 | worktree 合并回 master，主仓 scope 文件零未提交变更，worktree/分支已清理 | git 核验 | `git -C /mnt/data/dev/task-planner-skill log --oneline -3` 含本任务 merge 提交；`git status --short` 无 scope 文件残留；`git worktree list` 无本任务残留 |
| VC-6 | 机器面零扩张：变更文件仅限执行范围限制表白名单（未新增脚本/hook/config 键/selftest 断言文件） | git diff 文件清单核验 | `git diff --name-only master...wt/task-v194-subagent-unit-cap`（合并前）输出 ⊆ 白名单集合 |
| VC-7 | Rule 75.8「调研方向粒度」落地 critical-rules-research.md（三要素：单子代理 1 个方向；多方向=方向枚举多 S-unit + 并行多子代理（Rule 21.4 组）；每方向结论分档落 findings 独立小节防混乱），既有 58/63/75 原文零删改 | grep + Read | `grep -c "75\.8" skills/plan-research-router/references/critical-rules-research.md` ≥2 且 Read 确认三要素齐 |

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
| **目标型需求** | R3、R4 |
| **裁决** | `solved` |
| **解决证据锚** | 主仓 b21b44ac：critical-rules-dispatch.md#46.6（grep=3，含合并单文件反绕过+兜底类≤3+约1篇括注）+ critical-rules-media.md 47.1 数值句（grep「1 个生产单元」=1）+ critical-rules-research.md#75.8（grep=2，含方向计数反绕过+58.1 换算边界）；复审 5 MAJOR 回炉 42a09f3 后判据闭环；selftest 92/92 |
| **未解决面+原因** | 无未解决面（机器守卫识别自然语言单元量=用户未授权的 opt-in 项，非条款缺陷；部署位同步待用户单独授权） |
| **已排除路径** | n/a（solved） |
| **下一步建议** | 待用户裁决两项：① 是否授权 check-dispatch 机器化扩张（识别「N 篇/N 段」自然语言单元量，宪法 §四.6 opt-in）；② 部署位（~/.zcode/skills/**）同步授权（对象=4 变更文件，动作=cp 对账） |

> 纯手段型任务（用户只要动作/产物，无问题待解）可填 `n/a（纯手段型任务）`——须与需求区标注一致，禁裸豁免。本任务 R3 为目标型，终验必裁。

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
| G1 | 证据缺口固化 | 两起实证第一手证据+四结构性缺口落盘 findings | findings.md §Research Findings 含 sess_f74fc164 锚与 4 缺口（file:line） | Phase 1 | complete |
| G2 | 条款设计 | 46.6+47.1+75.8 三草案+级联清单定稿 | `<plan-dir>/design/` 下草案文件存在且含三条款定稿文本 | Phase 2 | complete |
| G3 | worktree 落地 | 三条款落盘+selftest 全绿 | worktree 内 `grep -c "46\.6"` ≥3、`grep -c "75\.8"` ≥2 且 run-selftests.sh exit=0 | S1-S4 | complete |
| G4 | 独立复审 | critic 复审通过（复审闭环） | Handoff 表 S5 行 verdict 处置闭环（CHANGES 回炉 42a09f3+复跑绿） | S5/S6 | complete |
| G5 | 合并回交付 | master 合并+VC 全过+归档 | git log 含 merge 提交 + run-verification.sh 全 PASS | Phase 5 | complete（归档执行中） |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则文本 | `skills/task-dispatch/references/critical-rules-dispatch.md`（Rule 46 段追加 46.6）、`skills/media-planner/references/critical-rules-media.md`（47.1 追加数值句）、`skills/plan-research-router/references/critical-rules-research.md`（75 段追加 75.8） | 其他任何规则文件；既有条款删改；其他卫星 |
| 技能索引 | `skills/task-dispatch/SKILL.md`、`skills/plan-research-router/SKILL.md`（仅规则索引行指针级联，如需） | SKILL.md 其他段落；task-planner/SKILL.md 主索引（子条不改全集计数，原则上无需动） |
| 测试脚本 | `skills/task-planner/scripts/selftest-dispatch-grain.sh`（实际唯一触碰：GR-01 计数锚 5→6 措辞级联；禁新增断言/禁新增脚本文件） | config.json（零新键）；check-dispatch.sh 行为改动；任何新 hook/机器门；其他 selftest-*.sh（含并行会话在途文件） |
| 计划文档 | `plans/task-v194-subagent-unit-cap/**`、`plans/INDEX.md`（sync-todos 刷新） | 旧计划 task-v193（D 类边界：原样保留）；`~/.zcode/skills/**` 部署位（同步待用户单独授权） |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做这个修改吗？
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
| CA-1 | skills/task-dispatch/references/critical-rules-dispatch.md Rule 46 段（46.5 之后追加） | 新增（46.6 子条） | 增量（46.1-46.5 既有文本逐字保留） | 「就是在技能中确保所拆分的单个任务不会在单个子代理中执行过多的任务」 | Explore 缺口①④：无数量上限表+判定口径缺；sess_f74fc164 实证 | Phase 3 S1 落地 |
| CA-2 | skills/media-planner/references/critical-rules-media.md:11 Rule 47.1 | 修改（条款末追加数值上限句） | 增量（既有「单 S-unit = 单生产单元 × 单阶段」「禁止整集生成」句逐字保留） | 「19段，19个片段全部放到一个子代理去生成」 | Explore 缺口①：仅定性「单元数 >1 批」 | Phase 3 S2 落地 |
| CA-3 | skills/task-dispatch/SKILL.md Rule 46 索引行（:35 附近，仅当该行枚举子条编号时补 46.6） | 修改（指针级联） | 增量 | 「在技能中确保……」 | 级联需要（执行期核对该行形态再定） | Phase 3 S2 一并核对，不触发则登记不适用 |
| CA-4 | skills/task-planner/scripts/selftest-*.sh 既有断言锚 | 修改（仅锚措辞级联修复） | 增量（维护性；禁新增断言） | 「在技能中确保……」（零回归为前提） | Phase 3 S4 实跑结果（锚断裂才动） | Phase 3 S4 |
| CA-5 | skills/plan-research-router/references/critical-rules-research.md 75 段（75.7 之后追加） | 新增（75.8 子条） | 增量（58/63/75 既有文本逐字保留） | 「拆分为多个子代理进行并行调研。不是而不是一次性，比如说一次性调研过多的方向，导致后期混乱」 | Bash grep 实证：调研域全文无方向数/并行约束（零命中） | Phase 3 S3 落地 |
| CA-6 | skills/plan-research-router/SKILL.md 规则索引行（仅当枚举 75 子条编号时补 75.8） | 修改（指针级联） | 增量 | 「一个任务拆分成多个单个任务来解决，来提高准确性」 | 级联需要（执行期核对再定） | Phase 3 S3 一并核对，不触发则登记不适用 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | task-dispatch 粒度规则全文（Rule 21/22/46/59） | /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md | 必读 | ☑（Explore 一手摘录，Phase 3 落地前 S1 子代理再 Read 原文） |
| 项目内部文档/知识库 | media-planner 媒体拆分规则（Rule 47/49） | /mnt/data/dev/task-planner-skill/skills/media-planner/references/critical-rules-media.md | 必读 | ☑（同上） |
| 项目内部文档/知识库 | 粒度守护 selftest 面（selftest-dispatch-grain.sh / selftest-subagent-granularity-skill-escort.sh） | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/ | 参考 | ☑ |
| 用户级规范 | 宪法 §四.6 文本优先 / §十一 worktree 隔离 | /home/terry/.zcode/AGENTS.md | 必读 | ☑ |
| 事故证据 | sess_f74fc164 派发形态与用户裁决（msg62） | ReadSessionContext(sess_f74fc164-419a-4ada-b45d-565685da83c7) 摘录 → findings.md §1 | 必读 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 技能对「单个子代理执行过多任务」只有定性禁令（46.1 单会话单 S-unit、47.1 禁整集生成），没有按任务类型的数量上限——「4 篇文章」「19 个片段」在现有条款下找不到可判违规的硬判据；机器守卫又只数 S 编号不识自然语言单元量且 fail-open。因此主进程打包派发时条款形同虚设（两起实证复发）。B 类扩展面（R4）：调研域（critical-rules-research.md）对「单子代理一次性调研过多方向」零约束（grep 并行/方向数零命中），同属「单子代理任务过多」缺陷族——需方向粒度条款 + 并行多子代理拆分。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（数值上限条款落地 + 零回归 = 交付）
- [x] 核心问题不解决，其他工作都白费吗？（同类打包派发会继续复发，已 ≥2 次实证且用户多次投诉）
- [x] 核心问题的解决方法是清晰的、可执行的？（增量条款文本：46.6 上限表 + 47.1 数值化，仓内已有 Rule 59.1 三值数值门先例可循）

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| S1（46.6 条款） | LOCAL-ONLY | 粒度上限、生产单元 | 本仓 skills/ 一手文本（Explore 已完成） | findings §2 缺口清单 | 不适用（仓内规则文本工程，无外部数据依赖） |
| S2（47.1 数值化） | LOCAL-ONLY | 媒体拆分轴、生产单元上限 | 本仓 skills/ 一手文本（Explore 已完成） | findings §2 | 不适用 |
| S3（75.8 调研粒度） | LOCAL-ONLY | 调研方向粒度、并行调研 | 本仓 skills/ 一手文本（grep 复核已完成：调研域零方向约束） | findings §2 缺口清单 | 不适用 |
| S4（selftest 回归） | LOCAL-ONLY | 锚级联、断言措辞 | 本仓 scripts/ 实跑 | progress 测试记录 | 不适用 |

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。本任务全 LOCAL-ONLY：修复对象是本仓规则文本，全部一手证据已计划期取回。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | sess_f74fc164 派发形态（8 篇/批→2×4 篇）+ 用户 msg62 裁决原话；本仓粒度条款现状（46.1/46.5/47.1/49.5 原文） | ReadSessionContext + Explore 一手摘录 | findings.md §1/§2 | ☑ |
| ② 对标样本（58.2 强制） | 仓内数值硬门成功先例：Rule 59.1 粒度三值 enforce（critical-rules-dispatch.md:142）——数值上限在本仓已验证可落地可守护 | Explore 一手文本 | findings.md §2 | ☑ |
| ③ 外部约束 | 宪法 §四.6 文本优先（守护机器化 opt-in）、§十一 worktree 隔离；部署位同步需用户授权先例 | 用户级 AGENTS.md + plans/task-v193 范围先例 | 本计划执行范围限制/隔离决策 | ☑ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。本任务非流量归因类；②已取仓内先例对标。

## Current Phase
<!-- 
  WHAT: Which phase you're currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are in the task. Update this as you progress.
-->
全部 Phase complete——终验交付中（VC 全 PASS；余=check-complete→归档→交付总结）

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
跑 check-complete → archive-plan 归档 → 交付总结（剩余唯二待用户裁决：机器守卫 opt-in 扩张、部署位同步）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 Explore（只读调研）+ ReadSessionContext | 跨文件调研与跨会话取证隔离主上下文（§一），已完成 |
| Phase 2 | 主进程 | 条款设计依赖整体证据判断（白名单②，见 Executor 例外理由） |
| Phase 3 | Agent 子代理 executor(sonnet-1) ×4 串行 + 机械守卫脚本 run-selftests.sh | S1→S2→S3→S4 文件/产物有依赖（S3 引 S1 的 46.6 编号、S4 验 S1-S3），Rule 21.4 独立性四问判串行 |
| Phase 4 | Agent 子代理 critic(sonnet-1) | 独立视角挑刺条款可执行性（Rule 42.2 登记工具） |
| Phase 5 | 机械守卫脚本 run-verification.sh + 主进程 git 编排 | 终验门脚本统一入口；git 编排属白名单① |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 激活条件（S-unit 依赖链串行，无可 fan-out 独立组；非长链编排；用户未点名）→ Rule 21.4 独立性守门调度（本计划显式声明：全部 S-unit 串行）
**/goal 对齐（Rule 40.3）**: 用户未使用 /goal 命令；本计划 Goal+VC 表即 session goal 证据源

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 证据固定与需求锚定（计划期已完成——只读取证）
<!-- 
  WHAT: Understand what needs to be done and gather initial information.
  WHY: Starting without understanding leads to wasted effort. This phase prevents that. This phase prevents that.
-->
- [x] 事故第一手证据固定：sess_f74fc164 派发形态（8 篇/批→2×4 篇、44min 网关挂死）+ 用户 msg62「每子代理约 1 篇」裁决 → findings.md §1
- [x] 技能现状与结构性缺口盘点：Rule 46/59/47.1 一手文本 + check-dispatch 口径四缺口 → findings.md §2
- [x] 用户原话逐字落盘 user-session-log.md #1（Rule 80.1）
- [x] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **V-N:** VC-1, VC-2（证据面支撑条款设计；取证记录即 verification.md V-1.1/V-1.2 证据）
- **Status:** complete
- **Executor:** Explore（只读调研，已完成）+ 主进程回填（例外理由:② 计划系统文件簿记（findings 回填）——Rule 25.3 白名单）
  <!-- STATUS VALUES: pending: Not started yet / in_progress: Currently working on this / complete: Finished this phase -->

### Phase 2: 条款设计（46.6 草案 + 47.1 数值化草案 + 级联清单）
<!-- 
  WHAT: Decide how you'll approach the problem and what structure you'll use.
  WHY: Good planning prevents rework. Document decisions so you remember why you chose to.
-->
- [x] Rule 46.6「单子代理生产单元上限表」定稿草案（五要素：内容类上限/媒体类上限/批量小操作上限/豁免两条件/判定口径与 S-ID 无关；判例锚引 sess_f74fc164）
- [x] Rule 47.1 数值化增量句草案（1 生产单元/派发，注明与 46.6 同源，既有句逐字保留）
- [x] Rule 75.8 调研方向粒度草案（单子代理 1 个方向；多方向=方向枚举多 S-unit + 并行多子代理（Rule 21.4 并行组+独立性四问）；每方向结论分档落 findings 独立小节防后期混乱；46.6 只读豁免措辞交叉引用 75.8 防定义漂移）
- [x] 级联影响清单核对（task-dispatch/SKILL.md Rule 46 索引行形态；selftest 锚排查清单；config 零新键确认）
- [x] 草案落盘 plans/task-v194-subagent-unit-cap/design/（clauses.md，供 S1/S2 材料包引用）
- **V-N:** VC-1, VC-2, VC-7（草案含 VC-1 五要素、VC-2 数值句、VC-7 调研三要素的定稿文本）
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件条款设计——依赖 Phase 1 已回收证据的整体判断，拆派需整体材料包传递成本大于收益，Rule 25.3 白名单）

### Phase 3: worktree 落地 + selftest 回归
<!-- 
  WHAT: Actually build/create/write the solution.
  WHY: This is where the work happens. Break into smaller sub-tasks if needed.
-->
- [x] 创建 worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v194-subagent-unit-cap`（分支 `wt/task-v194-subagent-unit-cap`，基于 master；初建即对账主仓 HEAD，防 worktree 分支不同步——memory worktree-branch-desync 判例）
- [x] S1-S4 逐单元派发执行（下表；串行——S3 引用 S1 编号、S4 验证 S1-S3 产物）
- [x] 全量 selftest 绿（run-selftests.sh --fresh exit=0）
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-6, VC-7（worktree 内先验 VC-1/2/3/6/7，合并回后终验 VC-4/5）
- **Status:** complete
- **Executor:** executor（sonnet-1）

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
| S1 | worktree 创建 + Rule 46.6 上限表落地 critical-rules-dispatch.md（46.5 后追加；只读豁免措辞含对 75.8 调研粒度的交叉引用；既有文本零删改） | 继承 | plans/task-v194-subagent-unit-cap/design/clauses.md（46.6 定稿文本+插入锚点+worktree 绝对路径） | grep "46\.6" worktree 内目标文件命中 ≥3 且 46.1-46.5 原文 diff 为零删改 | 15min | 1f/50l/15min | 无 | Phase 2 | pending |
| S2 | media Rule 47.1 追加数值上限句 + task-dispatch/SKILL.md 索引行核对（不触发则登记不适用） | 继承 | plans/task-v194-subagent-unit-cap/design/clauses.md（47.1 增量句+插入锚点） | grep 47.1 段含数值上限表述且「整集生成」原句保留 | 10min | 2f/20l/10min | 无 | S1 | pending |
| S3 | Rule 75.8 调研方向粒度落地 critical-rules-research.md + plan-research-router/SKILL.md 索引核对（不触发则登记不适用） | 继承 | plans/task-v194-subagent-unit-cap/design/clauses.md（75.8 定稿文本+插入锚点） | grep "75\.8" 命中 ≥2 且 58/63/75 原文零删改 | 10min | 2f/25l/10min | 无 | S1 | pending |
| S4 | selftest 全量回归；仅当锚断裂修既有断言锚措辞（禁新增断言），复跑至绿 | 继承 | worktree 路径 + run-selftests.sh 用法一行 | run-selftests.sh --fresh exit=0（若首轮红：断裂锚清单落 progress 后再修） | 15min | 2f/30l/15min | 无 | S1、S2、S3 | pending |

### Phase 4: 独立复审（换人挑刺）
<!-- 
  WHAT: Verify everything works and meets requirements.
  WHY: Catching issues early saves time. Document test results in progress.md.
-->
- [x] critic 对照用户 R1-R3 原话复审条款：可执行性/漏洞/数值豁免合理性/与既有条款冲突面
- [x] 复审发现分级处置：BLOCKER/MAJOR 回炉 Phase 3 增量改（改后 S3 复跑）；NIT 登记 findings 待用户裁决
- **V-N:** VC-1, VC-2（复审通过=条款文本满足 R1/R2 判据的独立确认）
- **Status:** complete
- **Executor:** critic（sonnet-1）

<!-- S-unit 派发单元表(Rule 22.6 — Executor≠主进程的 Phase 计划期必填) -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S5 | 条款复审挑刺（只读） | critic(sonnet-1) | worktree 内三条款 diff + 用户 R1-R4 原文（任务书内联） | 复审结论 APPROVED / CHANGES(条目清单) | 15min | 0f/0l/15min | 无 | S4 | pending |

### Phase 5: 合并回 + 终验交付
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [x] worktree 内全 VC 复验通过且 git status 干净 → `smart-merge-back.sh <worktree-path>`（不带 --deploy；部署位同步待用户授权）
- [x] 清理 worktree/分支 → 主仓 Read 复验关键条款
- [x] 终验：run-verification.sh 逐条 VC 复验 + 委派率统计 + 核心目标达成裁决（R3）+ alignment-review 收尾
- [x] 交付总结五要素 + archive-plan.sh 归档
- **V-N:** VC-4, VC-5, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+终验簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号③ 遗留 wt/task-v168-machine-parked 分支 1 个——非本任务范围不处理；信号④ 2 个未完成任务在册（task-defect-rrv13 / task-P01）——并行会话可能推进，本任务全程 worktree 隔离不踩主工作树；其余为 plans/ 未跟踪目录属正常形态） |
| `isolation` | `worktree`（命中宪法 §11.1.1：技能文件修改为保护区实现类任务） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v194-subagent-unit-cap` |
| `branch` | `wt/task-v194-subagent-unit-cap` |
| `merge_back` | `merged(b21b44ac)`（master 合并完成，worktree/分支已清理；期间并入并行会话 task-v195 推进的 master 9 提交零冲突；不带 --deploy） |

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
| Phase 3 | selftest 锚级联断裂回归红（历史判例：纪元锚/行号锚家族，锚演进必跨脚本 grep 旧 label） | 6 | 5 | 3 | 90 | RPN≤100；仍登记兜底：S3 首轮红→断裂锚清单落 progress→仅修锚措辞不新增断言→复跑（22.3 ②拆细）；两轮仍红→降级 STOP 报告用户 |
| Phase 5 | 合并冲突（并行会话同日推进 master——v180 三会话同日竞写判例） | 7 | 4 | 2 | 56 | RPN≤100；兜底：并集解（取覆盖侧+保留双方注释），冲突面报告用户 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-21 | 计划创建时 S1 建映射 |
| Phase 2 | ☑ | 2026-10-21 | 同上 |
| Phase 3 | ☑ | 2026-10-21 | 同上 |
| Phase 4 | ☑ | 2026-10-21 | 同上 |
| Phase 5 | ☑ | 2026-10-21 | 同上 |

> 契约详见 `${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
-->
1. 数量上限定多少？→ 内容生产/修正类 **1 单元/派发**（用户 sess_f74fc164 msg62 已裁决「后续派发粒度应缩至每子代理约 1 篇」）；媒体生成类 **1 生产单元/派发**（对齐 47.1 单 S-unit=单生产单元既有定义）；≤2 分钟/单元的机械小操作 **≤5 个/派发**且逐单元检查点落盘
2. 只读分析批（如普查 20 篇无写入）是否受限？→ 豁免（无逐单元写入产物，无上下文累积写坏风险），但仍受 21.1b 三值门约束
3. 机器守卫（check-dispatch 识别自然语言单元量）要不要同步扩张？→ 默认**不**（宪法 §四.6：守护机器化=opt-in，用户显式同意才建）；已登记为本计划待审项，随计划确认一并裁决
4. 调研阶段方向上限（R4 扩展新增）？→ **1 个方向/子代理**（默认）；多方向 = 方向枚举为多 S-unit + 并行多子代理（复用 Rule 21.4 并行组+独立性四问，方向间默认独立）；每方向结论分档落 findings 独立小节防后期混乱

## Decisions Made
<!-- 
  WHAT: Technical and design decisions you've made, with the reasoning behind them.
  WHY: You'll forget why you made choices. This table helps you remember and justify decisions.
-->
| Decision | Rationale |
|----------|-----------|
| 上限落 Rule 46.6 子条而非新增 Rule 93 | 域归属正确（单子代理任务量=Rule 46 专注度管辖）；避免 1-92 全集索引纪元级联（历史判例：编号级联跨十文件）；编号零扩张=零 attest 查重负担 |
| 媒体上限写 media 47.1 增量句并注明与 46.6 同源 | 域归属（媒体拆分轴=Rule 47 管辖）；两处引用同源避免数值漂移分叉 |
| 不新增脚本/hook/selftest 断言（§四.6 文本优先） | 守护机器化=opt-in；check-dispatch 扩张识别自然语言单元量登记为待审项交用户裁决；本任务交付=条款文本+既有锚维护 |
| 合并回不带 --deploy | 部署位同步历来需用户单独授权（task-v193 同口径先例） |
| 调研方向粒度落 research 域 75.8 子条（而非塞进 46.6） | 域归属：调研纪律=Rule 75 管辖（75.0-75.7 后顺延 75.8 零撞号）；并行机制复用既有 Rule 21.4 不另造；46.6 只读豁免措辞交叉引用 75.8 防两处定义漂移 |
| 全 S-unit 串行（Rule 21.4 声明制） | S3 引用 S1 落地的 46.6 编号、S4 验证 S1-S3 产物——输入/验收依赖判串行（注意两层：本计划落地工序串行 ≠ 未来调研类任务派发方式，后者由 75.8 约束为并行） |

## Errors Encountered
<!-- 
  WHAT: Every error you encounter, what attempt number it was, and how you resolved it.
  WHY: Logging errors prevents repeating the same mistakes. This is critical for learning.
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
- 本任务为 D 类新任务边界：旧计划 task-v193-skill-goal-drift-fix 原样保留，不混入本计划（Rule 8.1）
- 哨兵 plans/.plan_required_side/ 尚未清除——用户显式 yes 前禁跑 plan-created.cjs（D1 门控）

## 🚨 Drift Log（漂移检测记录）
<!-- 
  WHEN: 每次派发 drift-checker 偏移检查（Rule 61 载体）后追加一行记录
  FORMAT: | timestamp | 结果 | VC条目 | 结论 |
-->
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-21（终验前） | ✅ALIGNED（drift-checker 子代理复合审查：Goal 达成/scope 零越界/VC 抽验全过/原话留痕四项全过；检查点 subagent-state/drift-check-final.md） | 全部 | 继续收尾交付 |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 子代理占比需要可见反馈闭环;委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
  WHEN: 每个 Phase complete 后更新;终验交付前必须完整。
-->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 5（Phase 3 executor、Phase 4 critic+executor；S-unit 口径 6/6=1.0——S1-S6 全部子代理派发） |
| 主进程直做 Phase 清单 | Phase 1（② 计划系统文件簿记）、Phase 2（② 计划系统文件条款设计）、Phase 5（① git 编排）——全部 Rule 25.3 白名单内 |
| 委派率 | 0.400（=2/5，check-delegation stats 机器输出；低于 floor 0.7 但主进程直做 3 条理由全白名单内 → check-complete WHITELIST-EXEMPT 放行——Rule 25.4「编排/簿记型任务属正常形态」） |

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
| 1 | 2026-10-21 | Explore | 摸排粒度规则与守护现状 | done | 46.1/59.1/47.1 原文锚齐；四结构性缺口（无上限表/fail-open/编号排除/无会话累积） | critical-rules-dispatch.md:116,142; critical-rules-media.md:11; check-dispatch.sh:375-381,443-479 | §2 | -（返回消息完整入 findings） | - / 0 / ☑ |
| 2 | 2026-10-21 | ReadSessionContext | sess_f74fc164 派发取证 | done | 8 篇/批挂死→2×4 篇重派；用户 msg62 裁决 1 篇/子代理 | 会话 msg51/57/59/62 | §1 | - | - / 0 / ☑ |
| 3 | | executor | S1 worktree+46.6 落地 | done | +9/-0 纯增量，grep=3；主进程 diff 复核一致 | critical-rules-dispatch.md:122-129（wt） | progress Phase 3 | plans/task-v194-subagent-unit-cap/subagent-state/S1-executor.md | sonnet-1 / 0 / ☑ |
| 4 | | executor | S2 47.1 数值化 | done | +1/-0；CA-3 不适用（SKILL.md:39 整号不枚举） | critical-rules-media.md:12（wt） | progress Phase 3 | plans/task-v194-subagent-unit-cap/subagent-state/S2-executor.md | sonnet-1 / 0 / ☑ |
| 5 | | executor | S3 75.8 调研方向粒度落地 | done | +8/-0；CA-6 不适用；残留发现登记 | critical-rules-research.md:62-68（wt） | progress Phase 3 | plans/task-v194-subagent-unit-cap/subagent-state/S3-executor.md | sonnet-1 / 0 / ☑ |
| 6 | | executor | S4 selftest 回归 | done | 3 轮→92/92 exit=0；GR-01 锚修复 +4/-4 | selftest-dispatch-grain.sh:88（wt） | progress Phase 3 | plans/task-v194-subagent-unit-cap/subagent-state/S4-executor.md | sonnet-1 / 0 / ☑ |
| 7 | 2026-10-21 | critic | S5 条款复审挑刺 | done | verdict=CHANGES（0B/5M/4N）；主进程逐条裁决 | 复审报告（返回消息全文） | progress Phase 4 | plans/task-v194-subagent-unit-cap/subagent-state/S5-critic.md | sonnet-1 / 0 / ☑ |
| 8 | 2026-10-21 | executor | S6 复审回炉修复 | done | 7 处修订 +7/-6；selftest 92/92 | dispatch:124,127,128,129;research:64,67;media:12 | progress Phase 4 | plans/archive/task-v194-subagent-unit-cap/subagent-state/S6-executor.md | sonnet-1 / 0 / ☑ |
| 9 | 2026-10-21 | critic | S5b 复审复核回炉修订 | done | verdict=APPROVED（5M+2N 全 RESOLVED；残留观察 1 登记） | 复核报告（返回消息全文） | progress Phase 5 | - | sonnet-1 / 0 / ☑ |

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（技能规则文本维护任务，非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 不沉淀理由——本任务为既有技能规则文本的单点缺陷修复（复用 general 流程完成），无跨任务复用的模板形态差异，不满足 34.3 沉淀三条件；终验时复核
