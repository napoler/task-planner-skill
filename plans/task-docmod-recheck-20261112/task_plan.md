# Task Plan: 文档修改复检纪律 Rule 106（写后回读+跨字段一致性+二次修改回归+两组 todo 驱动）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} token 由 init-session.sh render_template() 脚本渲染（task-id/任务名/日期/路径）；尖括号中文占位=模型填写面，脚本禁碰 -->
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  选定 variant 后 template_type 填所选类型名（白名单=/mnt/data/dev/task-planner-skill/skills/task-planner/templates/variant/*-type.md 动态派生，见 check-template-type.sh）；general=通用回退（恒合法，Rule 34.1）
  plan_tier ∈ {standard, mini}（Rule 38.1，mini 四条件机器判定）；execution_lane ∈ {L0, L1, L2}（Rule 38.7，缺省 L1；L0 禁滥用见 38.7 末段）
  check-template-type.sh 三形态之一：行首 `^template_type:`（本块）/ 表格行 / HTML 注释；本块用行首形态 -->
template_type: rule-enhancement
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

- **R1**: 「sess_1378b365-f324-4ec0-b6ea-842163462b4e 会话存在严重的错误缺陷 就是在修改文档时候 竟然没有做修改验证导致低级错误」<sub>（[目标]）</sub>
- **R2**: 「也就是严重的时间没有对齐 就是修改的可靠性严重buzu 说明即便是所谓的更新完成后 但是连最基础的文件对齐以及基础的文档修正都没有修改这是严重的缺陷必须纠正相关skill 对于当前项目的各种内容纠正」<sub>（[目标]）</sub>
- **R3**: 「也就是 验证机制严重失效 不要告诉我连修改的核心文件都不复检就放行这是设计缺陷」<sub>（[目标]）</sub>
- **R4**: 「还有就是该文件的逻辑是否存在缺陷 比如 a文件改过一次后再次修改a文件是否需要优化流程」<sub>（[目标]）</sub>
- **R5**: 「为了避免流程缺失或者丢弃我希望可以 使用todo来强制对齐   分为两部分   通用todo +针对性的任务步骤   比如上面的任务就可以将验证加入到通用步骤 因为所有步骤都涉及验证    优化相关的skill 来执行 核心就是 todo 来驱动 就是对齐  当然todo一定要对齐同步到 系统的原始支持的todo来确保执行」<sub>（[目标]，2026-11-13 B 扩展）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 | findings.md 含会话缺陷链取证（会话声称修复 vs 用户所见矛盾）+ G22-05a 文档本体现状取证行（含两轮未命中兜底登记） |
| R2 | VC-2, VC-3 | Rule 106 规则体四子条落盘（含时间轴对齐判例）+ 索引/卫星/路由级联命中 |
| R3 | VC-2, VC-4 | 106.1 写后回读门 + 106.4 验证对象=交付物本体 落盘；既有 selftest 套件 FAIL=0 |
| R4 | VC-2, VC-5 | 106.3 同文件二次修改全量回归子条落盘；三部署位同步 diff=0（新会话生效） |
| R5 | VC-6, VC-4 | 106.5 两组 todo 驱动对齐 + todo-sync 契约扩展（基线组 B1-B5+门禁挂钩）落盘；selftest 回归绿 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
<!-- 2026-10-11 task-v169（Rule 80 落地）：用户会话逐字记录专档指针区块——用户需求与对话内容逐字落档 plans/task-docmod-recheck-20261112/user-session-log.md（只写不改，append-only）；本区块纯静态（专档路径+铁律+恢复协议，禁条目计数/首末条目标记类需随记录更新的可变内容——改 task_plan.md 即 [PLAN TAMPERED] 与 attest 哈希锁冲突） -->
- **专档路径**：`plans/task-docmod-recheck-20261112/user-session-log.md`（模板 = /mnt/data/dev/task-planner-skill/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体。结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；
     与 init-session.sh 注入版脚手架注释同口径） -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 缺陷取证 | 会话声称「已修复/终验 PASS」与用户所见文档矛盾，从未对文档本体定性 | Phase 1 会话上下文取证 + 子代理对 videop1 文档本体取证（两轮未命中→兜底登记） | VC-1 |
| 规则设计 | 本仓无过程期写后复检门/无跨字段一致性条款/无同文件二次修改回归条款；Rule 20.5「刚写完不要再 Read」与复检需求冲突无豁免口径 | Phase 2/3 Rule 106 四子条（106.1-106.4） | VC-2 |
| 执行视图（todo） | 流程步骤可被静默丢弃——todo 仅按 Phase 单组建，验证类通用步骤无固定槽位，丢弃不可见 | Phase 2/3 Rule 106.5 + todo-sync 契约两组结构（基线 B1-B5 门禁挂钩） | VC-6 |
| 级联与生效 | 条款落盘但索引上界/卫星路由/selftest 锚不同步 = 新会话不生效或 selftest 红 | Phase 3 S2/S3/S5 级联 | VC-3, VC-4 |
| 部署同步 | 部署位（zcode/claude/cursor）不同步 = 运行会话继续用旧规则 | Phase 5 文件级 cp + diff=0 | VC-5 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Goal 行原文；R1-R5 逐字原文；VC 表六条；Rule 106 五子条语义（写后回读门/派生值先定基准/同文件二次修改全量回归/验证对象=交付物本体/两组 todo 驱动对齐含基线组 B1-B5） | 本文件 Goal/需求原文/VC 段；findings §Rule106 草案 |
| 🔒 不变量 | 不触碰在途任务文件（plans/task-skillfix-audit-20261109、task-workflow-multimodel-delegation-20261111 目录及 skills/plan-resume、todo-skill、workflow-model-tiers 三 SKILL 的未提交变更）；不动 wt/task-v168-machine-parked 封存分支 | 冲突扫描 2026-11-13 输出 |
| 🔒 不变量 | §四.6 文本优先：仅文本条款+既有 selftest 锚维护，零新脚本/零新 hook/零新守护门（todo 两组结构以契约文本承载，不改 sync-todos.sh） | 用户宪法 §四（2026-10-15 裁决）+ R5 落点决策 |
| 🔀 可变量 | Rule 106 具体措辞/判例锚写法/级联锚的精确位置与数量；S-unit 拆分与并行编组 | - |
| 📈 学得量 | G22-05a 本体取证结论（两态定性）；selftest 基线漂移情况；本会话两组 todo dogfood 有效性 | findings.md |

## Goal
在 task-planner-skill 技能体系落地 **Rule 106 文档修改复检与 todo 驱动对齐纪律**（106.1 写后回读门 / 106.2 派生值先定基准全链重算 / 106.3 同文件二次修改全量回归 / 106.4 验证对象=交付物本体 / 106.5 两组原生 todo 驱动对齐：通用基线组 B1-B5+任务步骤组，门禁挂钩），完成 todo-sync 契约扩展、索引级联、selftest 回归与三部署位同步，封堵 sess_1378b365 类「文档改后不复检即放行/流程步骤被丢弃」设计缺口。

## 🔍 Code Review 配置

<!--
  设计代码修改类任务：将下方值改为 required
  纯调研/文档/规划类任务：留空或写 n/a
  默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值
-->
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯规则文本变更，无代码逻辑；复检面由 Rule 103 双轮质检承载，Phase 4 派独立复检体） |
| `session_id` | `sess_30f4af3e-d8b0-4caf-b7bb-f5f443aeb163` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-docmod-recheck-20261112`（宪法 §11.2 集中目录） |
| `scope_files` | `skills/task-discipline/references/critical-rules-discipline.md`, `skills/task-planner/SKILL.md`, `skills/task-planner/references/critical-rules.md`, `skills/task-planner/references/todo-sync.md`, `skills/verification-gate/references/critical-rules-verification.md`, `skills/task-planner/scripts/selftest-enumerate-first.sh`（+fresh 跑发现的 epoch 锚文件，逐个登记） |
| `interaction_mode` | `ask` |
| `对齐审查` | [登记] 终验前跑 alignment-review 对齐审查（规则文本↔既有规则族互洽：20.5/67.1/84.3/84.5/84.7/84.14/103.6 分工边界） |
| `自动超时默认项` | [D1 计划审批: 推荐项=按已展示计划执行/5min]；[部署范围: 推荐项=zcode+claude+cursor 三位全同步/5min]；[G22-05a 文档本体修正: 推荐项=不纳入本计划（跨项目需单独授权）/5min] |
| `new_rule` | `106` |
| `质量审查工具` | 103.3 独立复检=general-reviewer（规则文本审查）；终验对齐=alignment-review skill（review-library 兜底池在位） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

<!--
  WHAT: 任务执行完毕 ≠ 目标完成。此表确保每一步有可验证证据。
  RULE: 每个 phase 完成后对照 VC 编号复验；phase 全部 complete ≠ 通过终验。
  FORMAT: VC-N 是客观判定标准（可测试/可追溯/不依赖主观判断）。
  V-N: goal-gate.md 规定「≥5 条 VC + 每 phase ≥2 条 V-N（映射到 VC 编号）」；
       在每个 Phase 段（`### Phase N` 的 - **Status:** 行前）补 `- **V-N:**` 占位行，
       填写本 Phase 验收映射的 VC 编号（≥2 条，如 `VC-1, VC-2`；对应逐条验收记录在
       /mnt/data/dev/task-planner-skill/skills/task-planner/templates/verification.md 的 `V-N.N` 项，映射目标须为已定义 VC 编号）。
       check-complete.sh 终验 VC-GATE 段机械校验（config.json vc_gate_enforce，默认 warn）。
-->

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 缺陷取证落盘：findings.md 含 ① 会话 sess_1378b365 缺陷链（声称修复 vs 用户所见矛盾的两态定性）② G22-05a 文档本体现状取证（两轮未命中兜底登记：已检索位置清单+「未验证」标注） | grep 关键行 | `grep -n 'G22-05a\|sess_1378b365\|未验证' plans/task-docmod-recheck-20261112/findings.md \| head -6` 命中≥4 行 |
| VC-2 | Rule 106 规则体落盘：critical-rules-discipline.md 含 106.1-106.5 五子条全文+G22-05a 判例锚+与 20.5/67.1 分工口径，位置在 Rule 105 之后 | grep 计数 | `grep -cE '106\.[1-5]' skills/task-discipline/references/critical-rules-discipline.md` ≥5 类齐全 |
| VC-3 | 级联面完成：SKILL.md 索引上界 1-105→1-106、卫星路由表 task-discipline 行含 106、执行循环含复检步指针、Rule 20.5 矩阵行含豁免口径；verification-gate 含 84↔106 互指；全仓无残留 `Rules 1-105` 字面 | grep 多点 | `grep -c '1-106' skills/task-planner/SKILL.md` ≥2；`grep -n 'Rule 106' skills/task-planner/SKILL.md skills/verification-gate/references/critical-rules-verification.md` 各≥1；`grep -rn 'Rules 1-105' skills/` =0 |
| VC-4 | 既有 selftest 套件全绿：受影响 epoch 锚（selftest-enumerate-first.sh 等）更新后全量 fresh 跑 FAIL=0，且与 master 基线对照仅本任务锚位差异 | 跑套件 | worktree 内全量 selftest 执行（入口以 Phase 3 S5 实测定名后回填 verification.md），汇总 FAIL=0；基线对照记录落 progress.md |
| VC-5 | 部署同步完成：scope 变更文件 × 部署位（zcode=~/.zcode/skills、claude、cursor）逐一 diff=空；源仓+配置仓 push ahead=0（若远端在位） | diff 逐对 | 例：`diff skills/task-discipline/references/critical-rules-discipline.md ~/.zcode/skills/task-discipline/references/critical-rules-discipline.md` 输出空；全部对清单落 progress.md |
| VC-6 | 两组 todo 驱动对齐落盘：todo-sync.md 含两组结构条款（基线组 B1-B5 固定清单+生命周期+门禁挂钩+S3 丢失重建+mini 豁免口径）；SKILL.md 原生 Todo 同步段含两组结构指针；Rule 106.5 在位 | grep 多点 | `grep -c '基线' skills/task-planner/references/todo-sync.md` ≥4；`grep -n '106.5\|两组' skills/task-planner/references/todo-sync.md` ≥3；`grep -n '两组\|106.5' skills/task-planner/SKILL.md` ≥1 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：若 `code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard/full 必填，mini 豁免）
<!-- task-dualqc-20261104 新增：双轮质检机制在计划阶段显式设计——派发型实质产出 S-unit 默认两道检核（第一轮执行体自审 103.2 checkpoint 自审段；第二轮主代理派全新子代理独立复检 103.3，档位升一档 103.4、复检任务书简洁四要素 103.5）；多文件变更集（≥2 受管文件）Phase 翻转前过 103.6 同步完整性审查（关联面推导四族→同步核对清单全绿）。豁免面=103.7，逐 S-unit 登记理由；mini 档整体豁免。 -->
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | Phase 3 S1-S5 全部（实质产出 S-unit）+ Phase 4 复检 |
| 豁免登记 | none |
| 多文件变更集预判 | Phase 3（S1+S2+S3+S4+S5 共 6 受管文件）→ 翻转前过 103.6 同步核对清单（关联面四族：同族字面/引用/部署镜像/selftest 断言） |

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
<!--
  WHEN: 终验时填写;含 [目标] 标注需求（下方 R 行）的任务必须在交付前出三态裁决
  WHY: Rule 58.5 完成裁决门——「分析报告已交付」不等于「问题解决了」;not-solved/partial 禁止标 COMPLETE
  载体: 58.4 手段/目标二分在需求原文区逐条标注 [手段]/[目标];本区块回收目标型需求的解决状态
-->
| 字段 | 值 |
|--------|-----|
| **目标型需求** | R1, R2, R3, R4, R5（全部 [目标]） |
| **裁决** | `solved` |
| **解决证据锚** | R1→findings §1/§5+VC-1；R2/R3→discipline:721-734（106.1/106.2/106.4）+SKILL 级联+VC-2/VC-3；R4→106.3（同文件二次修改全量回归，判例 v4→v6）+VC-2；R5→106.5+todo-sync:29-46 两组契约+本会话 dogfood（基线组 B1-B5 全程挂门禁）+VC-6；全部部署三位于 zcode c8b874d/claude cf28dd5/cursor 落盘（新会话生效） |
| **未解决面+原因** | 无阻塞未解决。已登记遗留（非 R 范围）：① master 2 个预存 selftest FAIL（另立任务）；② G22-05a 文档本体未在盘上找到（两轮检索，用户如需修内容另行授权）；③ findings 折叠建议（hygiene 非严重） |
| **已排除路径** | n/a（solved） |
| **下一步建议** | ① 另立任务修 active-plan T11/execution-stability T11b 两预存 FAIL（锚=S5 检查点 06）；② 如需修 G22 分镜文档本体：请提供文档实际路径（跨项目授权） |

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
| G1 | 缺陷取证 | 会话缺陷链与 G22-05a 本体现状（含未验证兜底）均落 findings | 命令：grep findings.md 命中≥4 行（VC-1 判据） | Phase 1 | pending |
| G2 | 规则落地 | Rule 106 五子条全文落 discipline 规则文件 | 命令：grep -c '106\.[1-5]' ≥5 且位置在 105 后 | S1/Phase 3 | pending |
| G3 | 级联同步 | 索引/路由/复检步/20.5 豁免/84 互指全落，无残留旧锚 | 命令：VC-3 三条 grep 全命中 | S2+S3/Phase 3 | pending |
| G4 | todo对齐 | 两组 todo 契约落 todo-sync.md+SKILL 指针 | 命令：VC-6 三条 grep 全命中 | S4/Phase 3 | pending |
| G5 | 回归全绿 | 既有 selftest 全量 FAIL=0 | 命令：S5 实测入口跑套件 FAIL=0 | S5/Phase 4 | pending |
| G6 | 部署生效 | 三部署位 diff=0 + 推送收口 | diff 形态：ALL-SYNCED 输出+三仓 push 区间 | Phase 5 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!-- 
  🚫 禁止发散规则:
  - 只操作本列表中明确列出的文件
  - 未在列表中的文件一律不碰
  - 如需扩展范围，必须获得用户授权
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则文本 | skills/task-discipline/references/critical-rules-discipline.md（+task-discipline/SKILL.md 若其规则清单含 105 上界锚） | 其他卫星规则文件 |
| 索引级联 | skills/task-planner/SKILL.md、skills/task-planner/references/critical-rules.md | task-planner 其他 references |
| todo 契约 | skills/task-planner/references/todo-sync.md（S1-S5 契约增量扩展；**禁改 scripts/sync-todos.sh**——文本优先铁律） | sync-todos.sh 及其他脚本 |
| 互指指针 | skills/verification-gate/references/critical-rules-verification.md | verification-gate 其他文件 |
| selftest 锚 | skills/task-planner/scripts/selftest-enumerate-first.sh + fresh 跑发现 epoch FAIL 的脚本（逐个登记后入列） | 新建任何脚本/hook |
| 计划文档 | plans/task-docmod-recheck-20261112/** | 其他任务目录（含在途 task-skillfix-audit-20261109 / task-workflow-multimodel-delegation-20261111） |
| git 操作 | worktree 分支 wt/task-docmod-recheck-20261112 + 主仓 merge/pathspec 提交 | 禁碰 wt/task-v168-machine-parked；禁 checkout/switch 主仓分支 |

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
| CA-1 | critical-rules-discipline.md Rule 105 段之后 | 新增 | 增量 | 「必须纠正相关skill」（R2） | Explore 审计缺口 A/B/C（findings §2） | 追加 Rule 106 段（106.1-106.5+判例） |
| CA-2 | SKILL.md「Rules 1-105 全集索引」等 1-105 锚（2 处） | 更新 | 替代（旧上界被新事实证伪：105 已非最大编号） | 同上 | 级联惯例（纪元锚=实测最大编号+1） | 1-105→1-106 |
| CA-3 | SKILL.md 卫星路由表 task-discipline 行规则清单 | 更新 | 增量（追加 106 至清单尾） | 同上 | 同上 | 清单尾追加 106 |
| CA-4 | SKILL.md Phase 执行循环 3h 之后 | 新增 | 增量 | 「验证机制严重失效」（R3） | 缺口 A：无过程期门 | 新增 3i 修改后复检步（一行指针式） |
| CA-5 | SKILL.md Rule 20.5 Read/Write 决策矩阵行 | 更新 | 增量（行尾追加豁免口径半句） | 同上 | 20.5 与复检冲突（findings §2） | 追加「20.5 豁免写入确认型重读，不豁免跨字段一致性复检（Rule 106.1）」 |
| CA-6 | critical-rules-verification.md Rule 84.7/84.14 邻近 | 新增 | 增量 | 同上 | 域分工（Rule 82 禁回潮） | 一行互指：过程期复检=Rule 106（discipline 域） |
| CA-7 | selftest-enumerate-first.sh '1-105' 锚 | 更新 | 替代（同 CA-2 判定） | 同上 | epoch 锚随编号演进（v121 先例） | 1-105→1-106（以 fresh 跑实测 FAIL 清单为准，逐个登记） |
| CA-8 | critical-rules.md 核心域索引（若含上界/卫星清单） | 更新 | 增量 | 同上 | 同 CA-2 | 按实测锚位更新 |
| CA-9 | todo-sync.md「S1 计划创建后建映射」小节 | 新增（小节内追加两组结构条款） | 增量（S1-S5 既有语义零改动） | 「使用todo来强制对齐 分为两部分 通用todo +针对性的任务步骤」（R5） | R5 指令+todo 丢弃面（根源覆盖表第 3 行） | 追加两组结构：基线组 B1-B5 固定清单+生命周期+门禁挂钩+S3 丢失重建+mini 豁免（findings §todo 契约草案逐字） |
| CA-10 | SKILL.md「原生 Todo 同步（强制）」段尾 | 新增 | 增量 | 「todo一定要对齐同步到 系统的原始支持的todo来确保执行」（R5） | 同上 | 追加一句两组结构指针（详见 references/todo-sync.md + Rule 106.5） |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

<!--
  WHAT: 本任务依赖的知识源清单(规范/官方文档/内部知识库/文献/图书)。
  WHY: 对齐任务知识库 — 凭记忆硬写是返工与造谣的首要来源;开工前确认知识源可获取。
  WHEN: 计划创建时填写;Phase 1 开工前逐项确认「已确认」列;必读项缺失 → STOP 记入 Errors Encountered。
-->
> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | 用户宪法 §四/§六/§十一（文本优先/技能保护/worktree 铁律） | /home/terry/.zcode/AGENTS.md | 必读 | ☑ |
| 项目内部文档 | task-planner SKILL.md（本会话已全文加载） | skills/task-planner/SKILL.md @ master(9126c3c) | 必读 | ☑ |
| 项目内部文档 | todo-sync.md 现行 S1-S5 契约（S4 执行体首动作 Read） | skills/task-planner/references/todo-sync.md | 必读 | ☐（S4 执行体读） |
| 项目内部文档 | discipline 规则全集（Rule 105 现状+67.1 原文+编号锚形态） | skills/task-discipline/references/critical-rules-discipline.md | 必读 | ☐（S1 执行体首动作 Read） |
| 项目内部文档 | 判例会话上下文（sess_1378b365 缺陷链） | 本会话 ReadSessionContext 取证（findings §1 转录） | 必读 | ☑ |
| 项目内部文档 | worktree 合并合约 | skills/task-planner/references/worktree-isolation.md | 参考 | ☐ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

<!-- 
  在开始任何任务前，必须明确回答以下问题：
  1. 核心问题是什么？
  2. 解决这个问题后，结果能交付吗？
  3. 解决这个问题的方法是什么？
-->
**核心问题**: 本仓技能体系缺少「文档修改后的过程期复检门」与「todo 驱动的流程步骤防丢弃机制」——无写后回读条款、无跨字段一致性校验、无同文件二次修改回归，Rule 20.5 反向鼓励不回读，todo 仅按 Phase 单组建使验证类通用步骤无固定槽位可被静默丢弃——导致 sess_1378b365 类多轮修补后三方时间口径不一致仍被放行。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？——能：Rule 106 五子条+todo-sync 两组契约落盘级联部署后，新会话的文档修改行为被条款约束、执行视图由两组原生 todo 强制对齐
- [x] 核心问题不解决，其他工作都白费吗？——是：不修条款，同类缺陷与流程丢弃在下次任务中复发
- [x] 核心问题的解决方法是清晰的、可执行的？——是：缺口定位（Explore 审计 file:line）→条款文本→级联→selftest→部署，全部既有通道

**如果无法回答核心问题，禁止开始任务！**

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）
<!-- Rule 75.1 载体：计划期为每个子目标/S-unit 强制标注调研三态之一。NET-* 条目必登记关键词+渠道+产出形态。
     豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）；纯机械 S-unit 默认 LOCAL-ONLY 无需逐行标注 -->

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| 全部 S-unit（S1-S5） | LOCAL-ONLY | 不适用（本地条款库+会话记录即全部输入） | 不适用 | findings 草案→规则文本 | 否（内部技能工程，无外部事实依赖） |

> 三态判定：LOCAL-ONLY=本地数据可完全解决（纯机械/簿记/既定步骤）；NET-RESEARCH=需网络调研补充知识/方案/报错解法；NET-DATA-DEPENDENT=必须接入网络数据（实时信息/外部 API/媒体参考/现成实现）。无 NET-* 条目且无豁免声明=计划不完整（check-plan-dispatch 机器校验）。本表含全 LOCAL-ONLY 声明+理由，满足 75.1。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!--
  WHEN: 计划创建时填写（适用判定:产出=结论/判断/建议/原因解释的任务）
  WHY: Rule 58.1 证据面清单——下结论前三类基线证据面缺一不可,防「无对标就下结论」(用户 2026-10-07 判例:竞品分析没做就归因流量问题)
  豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免
-->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | sess_1378b365 会话记录（缺陷链）+ G22-05a 文档本体（两轮检索未命中→兜底登记） | ReadSessionContext + Explore 只读取证 | findings §1 | ☑（本体取证=未验证已登记） |
| ② 对标样本（58.2 强制） | 本仓既有验证体系现状（84.3/84.5/84.7/84.14/67.1/20.5/103.6/S1-S5 条款原文） | Explore 子代理审计（已完成，带 file:line） | findings §2 | ☑ |
| ③ 外部约束 | 无外部约束面（纯内部技能工程）——豁免理由：不依赖平台规则/市场/外部 API | n/a | findings §2 豁免登记 | ☑ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。本任务归因（缺陷根因=条款缺口）已有 ①② 双面支撑。

## Current Phase
<!-- 
  WHAT: Which phase are you currently working on (e.g., "Phase 1", "Phase 3").
  WHY: Quick reference for where you are at the task. Update this as you progress.
-->
Phase 4

## Next Step
<!-- 
  WHAT: 单一下一步动作(一句话,可执行)。
  WHY: 恢复会话/上下文压缩后无需推断"接下来干嘛";5Q 第 6 问的答案源;smart 注入块每轮携带本字段。
  WHEN: Phase 状态每次变更时同步刷新(Rule 20.4);完成一个动作后立即更新为再下一步。
  EXAMPLE: "派 code-assistant 修复 src/auth.ts 的 token 空值判断,然后跑 bun test"
-->
S6 VC 复验落证据 ∥ drift-checker(Phase3) → S7 general-reviewer 独立复检 + alignment-review → Phase 5 smart-merge-back + 三位部署 + rule106 land + 归档

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
<!--
  WHAT: 逐 Phase 登记命中的 harness 执行工具面与选择理由（Rule 40.1 六类: /workflow 动态工作流、/goal 会话目标、Agent 子代理、卫星技能、MCP/平台工具、机械守卫脚本）。
  WHY: 计划期显式选择最合适的执行工具,替代"默认只有串行 Agent 派发一条路"的隐式决策;记录工具选择的可追溯依据。
  WHEN: 计划创建时（plan-writer）填写;执行期工具变更时回填。
  定位声明: 本区块是 Executor 字段的**上游分析记录,不替代**其委派门控机器事实源地位（check-delegation/check-plan-dispatch 消费面不变）;本区块内禁止出现 Phase/Status/Executor 三形态伪行。mini 档豁免本区块（Rule 38.3 区块白名单）。机器校验边界见 Rule 40.5（LLM 行为面,selftest-tool-selection.sh 静态守护）。
-->
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理（Explore ×2：条款审计已完成 + 本体取证已收）+ ReadSessionContext | 大仓检索/会话取证委派隔离上下文（宪法 §一） |
| Phase 2 | 卫星技能（task-planner 本体）+ 机械守卫（attest-plan.sh）+ 原生 Todo（两组结构 dogfood） | 规则文本设计属计划系统文件维护白名单② |
| Phase 3 | Agent 子代理（general-coder ×4 + code-runner-agent）+ git worktree | 技能文件写入被 check-delegation 拦主进程直写，必须派发；隔离开发走 §十一 |
| Phase 4 | Agent 子代理（code-runner-agent + general-reviewer 103.3 复检） | 验证独立性（Rule 33.3） |
| Phase 5 | 机械守卫（smart-merge-back.sh/check-complete.sh/archive-plan.sh）+ 主进程 git 编排 | 合并/部署/归档属白名单①② |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 激活条件（S-unit 数 5 但真依赖链 S1→(S2∥S3∥S4)→S5 非独立 fan-out）→ Rule 21.4 独立性守门调度（S2/S3/S4 执行期同消息并行派发，登记于 Decisions）
**/goal 对齐（Rule 40.3）**: 用户未用 /goal 锚定；本计划 Goal+VC 即证据源，无需映射

## Phases
<!-- 
  WHAT: Break your task into 3-7 logical phases. Each phase should be completable.
  WHY: Breaking work into phases prevents overwhelm and makes progress visible.
  WHEN: Update status after completing each phase: pending → in_progress → complete
  Executor 字段(Rule 25.1):每个 Phase 必须声明执行体;主进程直做必须写例外理由;选型按 SKILL.md §子代理路由与模型分级路由表;Executor≠主进程的 Phase 必附 S-unit 派发单元表(Rule 22.6,示范见 Phase 3);S-unit 表「执行体」列:默认写"继承"(= Phase Executor),混用模型时逐行写具体 subagent_type(model);check-plan-dispatch.sh 在计划批准时校验(22.6/25.1)
-->

### Phase 1: 缺陷取证与证据落盘
<!-- 
  WHAT: Understand what needs to be done and gather initial information.
  WHY: Starting without understanding leads to wasted effort. This phase prevents that.
-->
- [x] 会话缺陷链取证（ReadSessionContext：声称修复 vs 用户所见矛盾、修复器 v4-v6 翻车史、ULTIMATE 终验声称 PASS）
- [x] 本仓条款缺口审计（Explore 子代理：缺口 A/B/C + Rule 20.5 冲突，带 file:line）
- [x] G22-05a 文档本体现状取证回收（Explore #2 + 主进程兜底：两轮未命中 →「未验证」兜底登记，findings §1）
- [x] findings.md 回填全部证据（§1-§4 + §Rule106 草案五子条 + §todo 两组契约草案 + §级联锚位清单 9 项）
- **V-N:** VC-1, VC-2（Rule 106 五子条草案成文入 findings，为 VC-2 前置证据）
- **Status:** complete
- **Executor:** 主进程（例外理由: ② 计划系统文件维护/簿记——调研主体已委派 Explore ×2（Handoff #1/#2），剩余为 findings 回填）
<!-- 
  STATUS VALUES:
  - pending: Not started yet
  - in_progress: Currently working on this
  - complete: Finished this phase
-->

### Phase 2: 规则文本设计与计划锁定
<!-- 
  WHAT: Decide how you're going to approach the problem and what structure it will use.
  WHY: Good planning prevents rework. Document decisions so you remember why.
-->
- [x] Rule 106 五子条全文草案定稿（findings.md §Rule106 草案：106.1-106.5+判例锚+20.5/67.1 分工口径）
- [x] todo 两组结构契约草案定稿（findings.md §todo 契约草案，S4 逐字消费面）
- [x] 级联锚位清单定稿（CA-2~CA-10 精确锚点位，9 项）
- [x] 展示更新版计划 → 等用户 yes（D1+目标绑定确认）→ attest-plan.sh 锁定（new_rule=106 自动预留）✅ 2026-11-13 SHA 7821a72d
- [ ] 本会话两组原生 todo dogfood（基线组 B1-B5 已随 B 扩展即时建立；持续至终验）
- **V-N:** VC-2, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由: ② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: worktree 内条款落地与级联
<!-- 
  WHAT: Actually build/create/write the solution.
  WHY: This is where the work happens. Break into smaller sub-tasks if needed.
-->
- [x] 建 worktree（/mnt/data/dev/task-planner-skill-worktrees/task-docmod-recheck-20261112，自 master）✅ 2026-11-13 HEAD=9126c3c WT-FILES-OK
- [x] S1-S5 逐单元派发执行（S1→S2∥S3∥S4→S5 全 done；S5 基线对照达标 B1⊆B0 差集=epoch；2 预存 FAIL 定性 master 既有）
- [x] 规范召回（Rule 93）：[recall] 行已落 progress（S-unit 4/5 时点）
- [x] 103.6 同步核对清单（①同族字面=0 残留 ②引用互指 ③部署镜像=Phase 5 承接 ④selftest 断言=EN-06 纪元翻转+预存定性登记）
- **V-N:** VC-2, VC-3, VC-6（V-3.1/3.2/3.3 主进程亲验 PASS 2026-11-13）
- **Status:** complete
- **Executor:** general-coder
（rule-enhancement 画像：规则文本编辑类，执行体=general-coder，验证=code-runner-agent）

<!-- S-unit 派发单元表(Rule 22.6 — Executor≠主进程的 Phase 计划期必填;每行 = 一次 Agent() 派发;单步 ≤step_max_files(2) 文件 / ≤step_max_lines(100) 行 / ≤step_max_minutes(15) 分钟,超限再拆而非升档;「执行体」列可写"继承"或具体 subagent_type(model);「输入」列在计划期预写材料包 = 路径 + ≤10 行摘要,执行期照单派发)
  机器契约(check-plan-dispatch.sh attest 校验):
  ① 预估时长列一律写 NNmin 格式(先估出可测的时长),逐行数值校验——超限= enforce 档硬阻断拒锁回炉重拆（Rule 59.1，2026-10-08 由 SKIPPED 提示升级）
  ② 输入列文件路径 token 计数 ≤2,超限= enforce 档硬阻断拒锁回炉重拆（Rule 59.1）
  ③ 拆分决策基准 = 预估时间(用户裁决 09-17):写表时先给每行可测的 NNmin 预估,模型据此决定拆不拆,机侧校验行供 review 对照
  ④ ID 列一律纯数字（S1/S2…），禁字母后缀——check-plan-dispatch.sh 数据行正则不认 S2a 式命名，attest 拒锁（task-v076 教训）
  - 粒度三值列 Nf/Nl/Nmin 格式逐行校验,任一超 step_max_files/step_max_lines/step_max_minutes → enforce 拒锁
  - 伴飞技能列非「无」→ 校验对应 SKILL.md 路径存在(Rule 59.2)
  - Rule 68.1 前置依赖列必填,无依赖填 -（多依赖顿号分隔）
  - Rule 96.3 并行硬标注:前置依赖为 - 且独立性四问全 no 的 S-unit ≥2 个 → 必须声明并行组（frontmatter parallel_groups: 组名 + 行内注解 [parallel-group:<组名>];未声明且未按 Rule 68.2 登记全串行论证=计划缺陷,回炉补分析再 attest）
  - Rule 104.3 计划期标注：「96 类别」列逐行填命中类别（A1-A7 / 47.2 具名 / LOCAL 纯执行），命中标注表（dispatch Rule 104.2）而执行体=主进程须例外理由或 [markup-exempt] token
-->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|------|
| S1 | （A6）在 critical-rules-discipline.md Rule 105 段后落 Rule 106 五子条规则体+判例锚 | 继承 | worktree 路径 + findings.md §Rule106 草案：五子条全文逐字可用，仅做格式对齐与锚位核实（首动作 Read 目标文件 Rule 105 段形态） | 106.1-106.5 五子条各≥1 处且位于 Rule 105 之后；diff 仅新增段 | 15min | 1f/85l/15min | 无 | - | pending |
| S2 | （A6）SKILL.md 级联：1-105→1-106 两处+卫星路由表行+3i 复检步+20.5 豁免+Todo 两组指针（CA-2~5/CA-10） | 继承 | worktree 路径 + findings.md §级联锚位清单：9 锚中 6 处归本单元，替换文本逐字 | 1-106 计数≥2；Rule 106 命中≥2；3i 步、20.5 豁免、两组指针在位 | 15min | 1f/28l/15min | 无 | S1 | pending |
| S3 | （A6）verification-gate 84↔106 互指一行 + critical-rules.md 索引更新 + 旧锚残留清零（CA-6/8） | 继承 | worktree 路径 + findings.md §级联锚位清单 CA-6/8 部分 | Rule 106 两目标文件各≥1；全仓 Rules 1-105 字面=0 | 10min | 2f/10l/10min | 无 | S1 | pending |
| S4 | （A6）todo-sync.md S1 小节扩展两组 todo 结构（基线组 B1-B5+门禁挂钩+丢失重建+mini 豁免；既有语义零改动） | 继承 | worktree 路径 + findings.md §todo 契约草案逐字（首动作 Read todo-sync.md 现行 S1 段形态） | 基线 一词≥4 次；106.5 与 两组 各≥1 处；diff 仅新增块 | 15min | 1f/45l/15min | 无 | S1 | pending |
| S5 | （A7）selftest-enumerate-first.sh epoch 锚更新 + 全量 selftest fresh 跑（master 基线对照） | code-runner-agent | worktree 路径 + 基线对照法说明：先记 master 基线 FAIL 集，改锚后 fresh 跑，FAIL 集=基线−epoch 项 | 主套件 FAIL=0 或=基线−epoch 逐项登记；输出落 progress.md | 15min | 2f/10l/15min | 无 | S1,S2,S3,S4 | pending |

### Phase 4: 验证与独立复检
<!-- 
  WHAT: Verify everything works and meets requirements.
  WHY: Catching issues early saves time. Document test results in progress.md.
-->
- [x] VC-2/VC-3/VC-6 grep 复验（worktree 内，S6 全 PASS）
- [x] 103.3 独立复检：S7 general-reviewer **APPROVED**（五维全绿，回执 checkpoint 09）
- [x] alignment-review 对齐审查（以五维对齐维度并入 S7 执行，登记 Decisions）
- [x] 测试结果落 progress.md（V-4.1 达标口径+V-4.2）
- **V-N:** VC-4, VC-2
- **Status:** complete
- **Executor:** code-runner-agent

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|------|
| S6 | （A7）worktree 内 VC-2/VC-3/VC-6 命令复验+证据落 verification.md | 继承 | worktree 路径 + verification.md VC 命令清单 | 三 VC 命令各 PASS，证据行带时间戳 | 10min | 2f/20l/10min | 无 | S5 | pending |
| S7 | （A3）103.3 独立复检：审五子条+todo 契约边界互洽，回执落 checkpoint | general-reviewer | worktree 路径 + 变更 diff 清单+findings §Rule106 草案对照面 | 回执含 APPROVED 或整改项已闭环清单 | 15min | 1f/60l/15min | 无 | S6 | pending |

### Phase 5: 合并、部署与交付
<!-- 
  WHAT: Final review and handoff to user.
  WHY: Ensures nothing is forgotten and deliverables are complete.
-->
- [x] smart-merge-back.sh 合并回 master（stash 保护窗消解在途暂存阻断，merged=02d90e2）
- [x] 部署同步：6 文件 × 三位 cp+逐对 diff=ALL-SYNCED（zcode c8b874d/claude cf28dd5 pathspec 提交；cursor 落盘）
- [x] 源仓+配置仓 push：源 9126c3c..bdbcfc2 / zcode main 9f0164f..c8b874d / claude master 440570d..cf28dd5；rule-reserve.sh land 106 ✅
- [x] 全文档收尾回读梳理记录（Rule 84.14）：五维检查两轮收敛（轮 1 发现=3 项已登记遗留非新偏移；轮 2 零新发现）——见「收尾回读梳理记录」表
- [ ] 归档计划：check-complete exit 0 后先 `bash <skill>/scripts/set-active-plan.sh --clear` 再 `bash <skill>/scripts/archive-plan.sh task-docmod-recheck-20261112 --root <plans根>`（Rule 81；守卫拒绝时登记理由不强移）
      <!-- task-kb-auto-capture-20261022 增：收尾主动触发——归档与知识提取为收尾默认动作，勿依赖人想起手动跑 -->
- [ ] 知识提取入库（kb-sync-from-plan.sh 在位已确认，归档后执行）
- [ ] 交付总结五要素（含 D3 二次修改流程优化结论=106.3 设计依据 + R5 两组 todo 机制说明）；会话记忆落盘（G22-05a 判例）
- **V-N:** VC-5, VC-3（主仓终验 PASS 2026-11-13）
- **Status:** complete
- **Executor:** 主进程（例外理由: ① git 编排+② 簿记——Rule 25.3 白名单）

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
<!-- 每轮一行：轮次/发现/处置；连续一轮零新发现才可出 outcome（收敛出口，轮次不设上限）；
     发现面=需求↔目标↔执行↔验证↔知识五维互洽（偏移/遗漏/未利用知识） -->
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1    | 五维检查：需求↔目标↔执行↔验证↔知识全对齐（R1-R5→VC-1~6 全 PASS）；发现 3 项均为**已登记遗留非新偏移**：①master 2 预存 selftest FAIL（findings §5 定性）②G22-05a 本体未验证（findings §1 兜底）③findings 折叠建议（hygiene 非严重，proportionality 不处置登记） | 三项分别以 findings §5/§1/progress 登记留痕，不阻塞 outcome |
| 2    | 零新发现（复扫 R→VC 映射/CA-1~10 逐行勾核/三仓 push 区间/worktree 零残留/stash 恢复原样——终轮 drift ALIGNED 佐证） | 收敛出口达成，出 outcome=COMPLETE |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
<!-- 
  WHAT: check-conflicts.sh 扫描结果与工作树隔离决策。
  WHY: 本仓多为运行中基础设施(skills/hooks/config 被所有会话实时使用),直接改动可能使功能工作期间半残;
       worktree 隔离 = 改动在副本上完成,验证后原子合并回原分支。
  WHEN: 计划创建时(init 后)运行 check-conflicts.sh 并填写;合并回后更新 merge_back。
-->
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①8 未提交文件均属在途他任务、与 scope 无重叠；信号⑤运行中基础设施；信号③遗留 wt/task-v168-machine-parked=已知封存不碰；信号④6 pending 任务不自动执行） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-docmod-recheck-20261112`（宪法 §11.2 集中目录形态；模板 tmp/worktrees 形态以宪法 §11.6 冲突裁决为准让位） |
| `branch` | `wt/task-docmod-recheck-20261112` |
| `merge_back` | `merged(02d90e2→簿记 bdbcfc2，worktree/分支已清理零遗留)` |

> 契约详见 `/mnt/data/dev/task-planner-skill/skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 /mnt/data/dev/task-planner-skill/skills/task-planner/references/methodology.md §R2）

<!--
  WHAT: 对每个 Phase 枚举失败模式，打 S(严重度)/O(频度)/D(探测难度) 各 1-10 分，RPN=S×O×D。
  WHY: RPN>100 的高风险 Phase 必须预先登记兜底动作（对齐 Rule 22.3 五档兜底链，task-v113 后含 22.3.0 资料先行档），避免执行期临时决策。
  WHEN: 计划创建时填写（高 RPN 项）；纯文档/调研类小任务可写 n/a。
  开关键: config.json#fmea_enforce（默认 warn；enforce 档下 RPN>100 无兜底登记 = 计划无效）。
-->

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | G22-05a 文档本体定位失败（已发生：两轮未命中） | 4 | 5 | 4 | 80→已按兜底处置 | 22.3④：已登记「未验证+已检索位置」（findings §1）；规则五子条不依赖本体取证成立（106.4 两态兼容） |
| Phase 3 | epoch 锚漏改/错改致 selftest 红（历史惯犯：锚级联第 5 变体） | 7 | 6 | 4 | 168 | 22.3②拆细+S5 基线对照法（先跑 master 基线再改锚，FAIL 集合差不盲修） |
| Phase 3 | 执行体改坏规则文件既有内容（增量变替代） | 8 | 3 | 3 | 72 | 22.3③：S1/S4 验收含「diff 仅新增」；103.3 复检兜底 |
| Phase 3 | todo-sync 契约与 sync-todos.sh 行为不一致（脚本只映射 Phase 组，基线组靠模型+契约重建） | 5 | 5 | 4 | 100 | 22.3④：契约明写「S3 丢失=当次重建」+本会话 dogfood 实证；不改脚本（文本优先铁律），脚本增强另立任务待用户授权 |
| Phase 5 | 部署 cp 覆盖他任务在途文件 / smart-merge-back 被对端活跃变更阻断 | 7 | 4 | 3 | 84 | 22.3⑤：pathspec 严格锁定 scope 文件；阻断则 STOP 报告等对端提交（task-v182 先例） |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）
<!-- 
  WHAT: 计划文档 ↔ 原生 Todo（TodoWrite / Task 系统）的同步状态追踪。
  WHY: 计划文档是唯一事实源，Todo 是执行视图；不同步 = 执行视图丢失目标。
  WHEN: S1 计划创建后建映射 / S2 Phase 状态变更后紧邻同步 / S3 收到 [plan-sync] 提醒立即回写 / S4 会话结束前终态同步 / S5 用户新指令影响计划后先改计划再重映射 Todo。
-->
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-11-13 | 任务组 5 条（TodoWrite）；基线组 B1-B5 随 B 扩展同建（两组结构 dogfood） |
| Phase 2 | ☑ | 2026-11-13 | 同上 |
| Phase 3 | ☑ | 2026-11-13 | 同上 |
| Phase 4 | ☑ | 2026-11-13 | 同上 |
| Phase 5 | ☑ | 2026-11-13 | 同上 |

> 契约详见 `/mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
<!-- 
  WHAT: Important questions you need to answer during the task.
  WHY: These guide your research and decision-making. Answer them as you go.
  EXAMPLE: 
    1. Should tasks persist between sessions? (Yes - need file storage)
    2. What format for data storage? (JSON file, base64, or sqlite)
-->
1. G22-05a 本体当前状态？（已答：两轮检索未命中，按兜底登记「未验证」——findings §1）
2. Rule 106 与 84.7/84.14 的边界措辞是否零重叠？（84 家族=终验期，106=过程期；Phase 4 复检验证）
3. selftest 基线在 master 当前态是否本来全绿？（S5 基线对照法回答）
4. 两组 todo 契约下，sync-todos.sh 仅映射任务组是否够用？（dogfood 本会话+103.3 复检回答；脚本增强=另立任务）

## Decisions Made
<!-- 
  WHAT: Technical and design decisions you've made, with the reasoning.
  WHY: You'll forget why you made choices. This table helps you remember and justify decisions.
  WHEN: Update whenever you make a significant choice (technology, approach, structure).
  EXAMPLE:
    | Use JSON for storage | Simple, readable, built-in Python |
-->
| Decision | Rationale |
|----------|-----------|
| Rule 106 归 task-discipline 卫星（执行纪律域），verification-gate 仅放一行互指指针 | 缺口是过程期执行纪律非终验门；Rule 82 禁回潮禁镜像 |
| 文本条款优先（§四.6）：零新脚本/零新 hook/零新守护门；selftest 仅维护既有 epoch 锚 | 用户宪法 2026-10-15 裁决；流程开销与变更体量成比例 |
| 106.4（验证对象=交付物本体）按两态兼容措辞设计，不依赖本体取证结论 | 本体取证两轮未命中（findings §1）；「对本体验证」在副本漂移/虚报两态下均成立 |
| R5 两组 todo 落点=todo-sync.md 契约扩展+Rule 106.5，**不改 sync-todos.sh、不改计划模板** | §四.6 文本优先：两组结构由契约文本+模型 S1 行为承载即成立；脚本/模板级联是范围扩张，另立任务待授权 |
| B1（修改后验证）设计为持续项（in_progress 直至终验，判据=[recheck] 留痕齐备） | 避免逐次修改的 todo 刷屏；完成判据可核（progress [recheck] 行） |
| 基线组条目丢失=当次立即重建（S3 回写协议） | 用户核心诉求=防丢弃；重建义务使丢弃在下一次同步时可见 |
| S2/S3/S4 执行期同消息并行派发（不同文件、无共享输入） | Rule 21.4 声明制；独立性四问全 no |
| S-unit 表列序回归 10 列（96 类别改目标列内前缀），单元格零管道/零转义管道 | check-plan-dispatch.sh:246-278 以 awk -F'\|' 定位 $4执行体/$5输入/$7时长/$8粒度——多列即整体错位；task-v150「S-unit 单元格禁管道转义」同源教训（列序漂移变体）；Rule 104.3 类别标注以目标列内（An）前缀承载，语义不丢失 |
| worktree 路径用宪法 §11.2 集中目录（非模板 tmp/worktrees 形态） | §11.6 冲突裁决：宪法 §十一 优先于 skill 参考文件 |
| 部署范围默认 zcode+claude+cursor 三位全同步 | 历史收口惯例（diff=0 核验）；已列入待审项，用户可缩 |

## Errors Encountered
<!-- 
  WHAT: Every error you encounter, what attempt number it was, and how you resolved it.
  WHY: Logging errors prevents repeating the same mistakes. This is critical for learning.
  WHEN: Add immediately when an error occurs, even if you fix it quickly.
  EXAMPLE:
    | FileNotFoundError | 1 | Check if file exists, create empty list if not |
    | JSONDecodeError | 2 | Check if file has empty list case |
-->
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| videop1 全量 grep 超时 ×2（90s/45s） | 2 | 收窄目录仍超时→改派后台 Explore 子代理按文件名先筛 | → progress.md Error Log；主进程不做大仓盲 grep（宪法 §一 大输出探测） |
| user-session-log.md 插入 #1 条目时 Edit 吞掉「## 消费点」标题行（2026-11-13） | 1 | 同轮发现→补插标题→grep 回读验证结构完整 | Rule 106.1 判例首次 dogfood（修复→回读→留痕全流程）；详见 progress.md Error Log |

## Notes
<!-- 
  REMINDERS:
  - Update phase status as you progress: pending → in_progress → complete
  - Re-read this plan before major decisions (attention manipulation)
  - Log ALL errors - they help prevent repetition
  - Never repeat a failed action - mutate your approach instead
-->
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help prevent repetition

## 🚨 Drift Log（漂移检测记录）
<!-- 
  WHEN: 每次派发 drift-checker 偏移检查（Rule 61 载体）后追加一行记录
  FORMAT: | timestamp | 结果 | VC条目 | 结论 |
-->
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-11-13 | drift-checker ✅ALIGNED（Phase 1/2 complete 后） | 全 VC | 执行方向与 R1-R5 对齐；继续 S2/S3/S4 并行 |
| 2026-11-13 | drift-checker ✅ALIGNED（Phase 3 complete 后） | VC-2/3/6 | CA 射程核验无越界漏项（检查点 08） |
| 2026-11-13 | drift-checker ✅ALIGNED（终轮 P4/P5+收尾） | 全 VC | 射程干净+stash 恢复原样+worktree 零残留（检查点 10；三 drift 全 ALIGNED） |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）
<!-- 
  WHEN: chain_mode: fan-out 或 批量操作 ≥5 单元时必填;纯单次任务可删除整个区块
  WHY: 批量操作禁止以牺牲质量/准确性为代价(Rule 18);前置 3 问 + 双采样抽检 + 失败率熔断的落盘证据
  校验: failure_rate >5% → Phase 禁止 complete;sampled_fail >0 → 整批未验证;pre_check 缺项 → plan-writer 校验失败
  完整模板: /mnt/data/dev/task-planner-skill/skills/task-planner/templates/batch_report.md | 规则详解: /mnt/data/dev/task-planner-skill/skills/task-planner/references/batch-quality-gate.md
-->
| 字段 | 值 |
|------|-----|
| `total` | 不适用（5 个 S-unit 为异构编辑/验证单元非同构批量操作，不触发 Rule 18.6 阈值语义） |
| `success` |  |
| `failed` |  |
| `failure_rate` |  |
| `sampled_pass` |  |
| `sampled_fail` |  |
| `pre_check` |  |
| `rollback_point` |  |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 子代理占比需要可见反馈闭环;委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
  WHEN: 每个 Phase complete 后更新;终验交付前必须完整。
-->
| 字段 | 值 |
|-------|------|
| 子代理执行 Phase 数 / 总 Phase 数 | 2/5（Phase 3、4）+ Phase 1 调研主体已委派 Explore ×2 |
| 主进程直做 Phase 清单 | Phase 1（白名单②簿记回填）、Phase 2（白名单②计划系统文件）、Phase 5（白名单①git 编排+②簿记） |
| 委派率 | 0.400（机器 stats verdict=ok，violations=[]，直做全白名单登记——JSON 原文贴 verification.md 委派统计复验段） |
| 激活子代理数（Rule 96.5） | 12 次 Agent 派发（Explore×2+general-coder×4 含 S1 续轮+code-runner×2+drift-checker×3+general-reviewer×1，另 1 次 drift 重发因契约 token 改写非新任务） |
| 最大并行宽度（Rule 96.5） | 3（S2∥S3∥S4 同消息） |
| 串行化例外理由（Rule 96.4） | S1→(S2∥S3∥S4)→S5→(VC 复验)→(独立复检) 为真依赖链非保守串行 |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
<!--
  WHEN: 每次 Agent() 派发前填一行;子代理返回 30s 内主进程必须 Read 实际产出 + 紧邻 Edit findings.md 回填结论(「findings 落点」列记段落锚点),两动作完成才在「备注」列勾 verify_done;failed/timeout 行必须回填 checkpoint 路径列(Rule 22.8.4)
  WHY: 子代理规模限制 + 交接文件保障(Rule 22);findings 回填绑定(Rule 19.1/22.5)防止结论只留会话记忆
  状态枚举: queued/pending/running/done/partial/timeout/failed/blocked/scaling-redispatch(22.3.1 provider 失败改派)
  列说明: 备注列 = 低频列折叠单列(rescue 换档挽救记录 档位/结果/时间,failed|timeout 行必填,Rule 22.7;retry_count = 22.3 retry_limit 计数,初值 0,每次重试 +1;verify_done☐ = Read 产出 + findings 复核/回填双条件,Rule 22.5)——字段内容不删,仅列位折叠;verify_done 无机器消费(grep 实证 scripts/*.sh 除 selftest 零命中),为人工义务,不声称机器门
  派发 prompt 八字段模板: /mnt/data/dev/task-planner-skill/skills/task-planner/templates/subagent_dispatch.md
  # [2026-09-27 task-v091 B-2] 单写者澄清+Handoff 低频列折叠（verify_done 无机器消费如实披露）
-->

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-11-13 | Explore | 本仓条款缺口审计（A/B/C 三类+验证门适用对象） | done | 缺口 A/B/C 全确认+Rule 20.5 反向冲突；验证门均为终验期无过程期门 | 报告 15 处 file:line（含 verification:48-59/discipline:372/template-mapping:262-276） | §2 条款审计 | 会话返回（只读无产出文件） | - / 0 / ☑（报告全文已入会话+findings 转录） |
| 2 | 2026-11-13 | Explore（后台） | videop1 仓 G22-05a 文档本体取证 | done | 四目录+兜底两轮均未命中 `G22-05a`；本体在已检索范围不存在 | 报告含 rg 检索词清单+近邻命中排除记录 | §1 本体取证（未验证登记） | 会话返回（只读无产出文件） | - / 0 / ☑（findings §1 已转录+兜底登记） |
| 3 | 2026-11-13 | general-coder | S1 落 Rule 106 五子条规则体+106.4 补插 | done | 五子条标题行 L723-731 全齐；diff=15 行纯新增；发现并上报上游 findings 106.4 缺段（主进程锚点事故，已修复） | worktree L721-732；checkpoint 01 | §Rule106 草案消费闭环 | subagent-state/01-general-coder.md | - / 0 / ☑（主进程亲验 for-grep+diff） |
| 4 | 2026-11-13 | drift-checker | Phase 1/2 完成后偏移检查 | done | ✅ALIGNED（R1-R5 逐条对齐；主仓脏改=他任务未提交项，与本任务 scope 不重叠） | 检查点 02 含 R1-R5 file:line 依据 | 留痕三件套闭环（ledger+Drift Log+检查点） | subagent-state/02-drift-checker.md | - / 0 / ☑ |
| 5 | 2026-11-13 | general-coder | S2 SKILL.md 六锚级联（实为 3 处 1-105→1-106+路由行+指针段+3i+20.5 豁免+Todo 指针） | done | 1-106 计数=3；Rules 1-105=0；diff=7+/6-（替代锚行） | SKILL.md L9/L105/L152/L173/L210/L223/L266 | 主进程亲验 V-3.3 PASS | subagent-state/03-general-coder-s2.md | - / 0 / ☑ |
| 6 | 2026-11-13 | general-coder | S3 verification-gate 互指+核心索引处置 | done | 互指行落 verification:56；critical-rules.md CA-8=无锚可改（Rule 105 零命中，登记在案） | verification:56 | 级联锚位清单 item6/8 闭环 | subagent-state/04-general-coder-s3.md | - / 0 / ☑ |
| 7 | 2026-11-13 | general-coder | S4 todo-sync 两组结构契约块 | done | 基线=5 处；106.5/两组在位；L30-37 纯新增 11 行 | todo-sync L30-37 | V-3.2 PASS（主进程亲验） | subagent-state/05-general-coder-s4.md | - / 0 / ☑ |
| 8 | 2026-11-13 | code-runner-agent | S5 selftest 基线对照回归 | done | B0=3FAIL→B1=2FAIL（差集=epoch 项 enumerate-first）；2 预存 FAIL 主仓对照定性 master 既有 | 检查点 06 两跑原文 | findings §5 | subagent-state/06-code-runner-s5.md | - / 0 / ☑ |
| 9 | 2026-11-13 | code-runner-agent | S6 VC-2/3/6 复验+证据落 verification.md | done | 三命令 PASS（6/3/5）；4 处证据行+3 勾选 | verification.md L18-31 | VC 证据闭环 | subagent-state/07-code-runner-s6.md | - / 0 / ☑ |
| 10 | 2026-11-13 | drift-checker | Phase 3 完成后偏移检查 | done | ✅ALIGNED（CA 射程核验/无越界漏项） | 检查点 08 | Drift Log 行2+ledger tick2 | subagent-state/08-drift-checker-p3.md | - / 0 / ☑ |
| 11 | 2026-11-13 | general-reviewer | S7 103.3 独立复检+对齐审查 | done | **APPROVED**（五维全绿；1 INFO 非阻塞） | 检查点 09 | 复检回执=V-4.2 | subagent-state/09-general-reviewer-s7.md | - / 0 / ☑ |

## 🔗 Chain 区块交接配置（可选）

<!-- 仅多 skill 接力任务填写（如：调研→创作→发布）。单 skill 任务可删除整个整个区块。 -->

### Chain 模式

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
| **current_block** | Block 1 |
| **handoff_on_complete** | ❌ 否 |

### Block 1: [本块名称]（当前块）

| 字段 | 值 |
|------|-----|
| **goal** | [本 block 独立目标] |
| **depends_on** | none |
| **passes_to** | none |
| **status** | in_progress |

<!-- 追加 Block N 时使用相同结构 -->

---

## 🔁 模板感知
<!-- template_type: rule-enhancement -->
<!-- template_type 已按 16 类白名单选取（rule-enhancement），本区块仅留存 check-template-type 第三形态机读标记 -->
- 触发信号: 命中 rule-enhancement-type.md（规则增强类任务）
- Rule 34.3②: 已知类型不产生沉淀评估区块（general 兜底才产生）
- 终验必查: check-template-type.sh gate exit 0（template_type: rule-enhancement 行首形态在位）
