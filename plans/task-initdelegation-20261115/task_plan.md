# Task Plan: 初始化阶段子代理化（task-initdelegation-20261115）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} token 由 init-session.sh render_template() 脚本渲染；尖括号中文占位=模型填写面，脚本禁碰 -->
template_type: general
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「当前技能的，就是我发现即便在用户初期，他也会消耗大量的时间。就是，那上下文，或者说窗口来分析用户的需求以及等等，呃，我希望可以，嗯，第一步直接将用户所需求直接放分歧以及创建。嗯，技能就是创建当前的技能相关文件，这部直接放在子代理里中执行。   因为这些东西其实没有必要占用上下文。就是比如说用户需求分析，然后创建子代，创建这些相关的这些文档信息。这些直接放在子代理中可以更好地隔离，而且主代理中其实只需要拿到创建了哪些文件，或者说以及任务ID。就可以，别的东西其实就是都没有必要去具体的在主代理中执行这些的工具。 核心就是将用户的，嗯，就是将，嗯初始阶段的分析这些东西全部放到子代理里中执行」 <sub>（[目标]）</sub>
- **R2**: 「来提高子代理里的激活率，嗯嗯嗯，这样的话也可以降低，嗯，主进程中，嗯，主，主代理中的上下文的占用。」 <sub>（[手段]；承 #1 同句中段）</sub>
- **R3**: 「为了，我希望可以继续优化当前技能。」 <sub>（[目标]）</sub>

> 逐字锚权威源：`plans/task-initdelegation-20261115/user-session-log.md#1`（append-only）。R1 中口语“放分歧”按上下文理解为“放分析”（见同号理解镜像，镜像非权威，冲突以逐字原文为准）。

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-4 | SKILL.md/规则条文出现 L1+ 初始化首动作委派、收据契约字段与主代理最小回收/会话绑定边界声明；grep 命令输出含目标锚词与文件路径行号。 |
| R2 | VC-3 | 条文显式包含隔离/激活率/降低上下文占用动机，且声明 L0/mini/trivial 豁免保持不变（比例原则对齐）；grep 命中。 |
| R3 | VC-1, VC-2, VC-3, VC-5, VC-6, VC-7 | task-planner 源仓条款落位并可审计（含编号/索引策略结果）、自测零增量 FAIL 证据、部署位 diff 对账证据齐备。 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-initdelegation-20261115/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

不适用（非结果级需求）。本任务为流程/条款固化改造（在 task-planner 技能中新增初始化首动作委派与收据契约），交付判据以条款落位、边界清晰、回归与部署对账为主，不涉及持续生产管线的质量/性能/可靠性逐工序指标提升。

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | R1-R3 用户原话与 [目标]/[手段] 标注；R→VC 映射覆盖关系；L0/mini/trivial 轻量豁免不被破坏；会话绑定脚本（init-session/attest/set-active/plan-created/哨兵清理）与 D1 确认归主进程；计划子代理不跑会话绑定脚本；收据最小集 `{task_id, files_created[], open_questions[], 摘要}` 语义不缩水；worktree 隔离开发后合并/部署对账要求 | user-session-log.md#1；本文件 R/VC/隔离/Phase 章节 |
| 🔀 可变量 | 条款具体落点（SKILL.md 段落措辞、是否新增 core Rule 109 或采用等价条款块）、S-unit 拆分细节、受影响 selftest 选择策略、部署位同步方式（在不破坏行为前提下） | Phase 1 定稿 + Decisions Made |
| 📈 学得量 | 执行期发现的锚点漂移、selftest 依赖、部署差异、降级路径实证等 → findings.md/progress.md；禁反向改写 R 原文与已锁定 VC 语义 | findings.md, progress.md |

## Goal
将 L1+ 任务初始化阶段的需求分析与计划文档创建固化为 task-planner 技能的首动作子代理委派流程，使主代理仅回收结构化收据并保留会话绑定/确认职责，且不增加 L0/mini/trivial 仪式。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a` |
| `session_id` | `<待执行期开启>` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-initdelegation-20261115` |
| `scope_files` | `[skills/task-planner/SKILL.md, skills/task-planner/references/critical-rules.md, skills/task-planner/scripts/selftest-init-delegation.sh(若新增), plans/task-initdelegation-20261115/*]` |
| `interaction_mode` | `ask` |
| `对齐审查` | `[登记]` 交付前对改动条款与 R/VC/现有 D1-attest-sentinel 语义做 alignment-review/checklist 式对照；mini 豁免不适用 |
| `自动超时默认项` | `[询问点: 计划确认/D1] 默认选项=按本计划执行；超时5min；真分叉（Rule编号形态/自测范围扩大）需用户裁决` |
| `new_rule` | 无（SKILL-only 条款块，2026-11-15 定稿见 Decisions Made Q1；不占 Rule 编号，禁触发 1-109 纪元级联；rule-reserve 仅只读查询留痕） |
| `质量审查工具` | `[检测结论]` 质量审查面=技能文档/规则一致性+脚本自测回归；工具=grep/diff/bash selftest + verification-gate VC 命令；缺口若出现新增守护则在 Phase 3 补 S-unit |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：终验核查动作由全新独立子代理或主进程外化证据复核执行，主进程既有上下文自测不作为唯一验收（Rule 33.3 延伸）。

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | L1+ 初始化首动作委派条款在 SKILL.md 计划制作循环锚面可检索，明确“需求分析+计划文档创建委派子代理”（CR P2-5 修正：改用改前 0 命中的独特锚保证判别力） | grep 独特锚词 | `cd /mnt/data/dev/task-planner-skill && grep -nE "初始化首动作委派" skills/task-planner/SKILL.md` |
| VC-2 | 收据契约 `{task_id, files_created[], open_questions[], 摘要}` 与主代理最小回收语义落位 | grep 契约字段与收据表述 | `cd /mnt/data/dev/task-planner-skill && grep -nE "task_id|files_created|open_questions|收据|摘要" skills/task-planner/SKILL.md skills/task-planner/references/critical-rules.md` |
| VC-3 | R2 动机（隔离/激活率/降上下文）与 L0/mini/trivial 豁免不变明确 | grep 动机与豁免词 | `cd /mnt/data/dev/task-planner-skill && grep -nE "隔离|激活率|上下文占用|L0/mini/trivial|轻量|豁免" skills/task-planner/SKILL.md skills/task-planner/references/critical-rules.md` |
| VC-4 | 会话绑定脚本与 D1/attest/收据回收归主进程边界明确，计划子代理不执行会话绑定脚本 | grep 边界关键词 | `cd /mnt/data/dev/task-planner-skill && grep -nE "init-session\.sh|attest-plan\.sh|set-active-plan\.sh|plan-created\.cjs|哨兵|主进程|会话绑定|D1" skills/task-planner/SKILL.md` |
| VC-5 | R3 条款固化结果可审计（新增 Rule 已 reserve/land 且索引一致，或 SKILL-only 条款块完整且 Decisions 说明） | 条文/账本/索引检查 | `cd /mnt/data/dev/task-planner-skill && (grep -nE "^### 109 |Rule 109" skills/task-planner/references/critical-rules.md || grep -n "首动作委派" skills/task-planner/SKILL.md)` |
| VC-6 | 自测基线与回归证据显示零增量 FAIL（相对改前基线） | progress.md 记录 + selftest 命令/日志 | `cd /mnt/data/dev/task-planner-skill && grep -nE "基线|回归|零增量 FAIL|FAIL" plans/task-initdelegation-20261115/progress.md` |
| VC-7 | 源仓与部署位（~/.zcode、~/.agents）task-planner scope 文件一致（CR P2-3 修正：scope 级 diff 判别，全目录既有差异登记于 progress） | scope 文件 diff 链（全绿=exit 0） | `cd /mnt/data/dev/task-planner-skill && diff -q skills/task-planner/SKILL.md ~/.zcode/skills/task-planner/SKILL.md && diff -q skills/task-planner/scripts/selftest-batch-pilot.sh ~/.zcode/skills/task-planner/scripts/selftest-batch-pilot.sh && diff -q skills/task-planner/SKILL.md ~/.agents/skills/task-planner/SKILL.md && diff -q skills/task-planner/scripts/selftest-batch-pilot.sh ~/.agents/skills/task-planner/scripts/selftest-batch-pilot.sh` |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard 必填）
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | Phase 2/3/4 所有派发型实质产出 S-unit（条款修改、自测脚本修改/新增、部署对账变更）默认适用 103.2-103.5；Phase 1 分析产物以证据复核为主，若产出文档性补丁同样适用 |
| 豁免登记 | P5-S1 若由主进程白名单直做簿记/汇总则豁免子代理双轮质检，理由=主进程编排与证据汇总（Rule 103.7）；其余无豁免 |
| 多文件变更集预判 | Phase 2（SKILL.md + critical-rules.md 及可能的索引/关联文档）、Phase 3（selftest/脚本）、Phase 4（部署位多文件同步）触发 103.6 同步完整性审查 |

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1, R3 |
| **裁决** | `solved`（2026-11-15 终验） |
| **解决证据锚** | R1→VC-1/2/4 PASS（SKILL.md L49-57 条款：委派+收据契约+主进程边界，主仓 grep 实锚）；R3→VC-1..VC-7 全 PASS（master a745157+4 部署位 diff=0+回归零增量）；本任务自身 init 即新范式 dogfood（计划由子代理产出，主进程仅收据+复核） |
| **未解决面+原因** | 无 |
| **已排除路径** | （solved 不适用） |
| **下一步建议** | （solved 不适用；后续可选=部署位既有漂移（agents 位 175 项为部分拷贝）另行授权收口任务） |

## 🎯 Goal 单元表（Rule 66.1 — 规划获批后任务单元固化；standard 必填）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 锚点与基线 | 锁定改动锚面、条款形态与自测基线并可复核 | progress.md 含锚点/基线记录 + `bash skills/task-planner/scripts/rule-reserve.sh next` 输出记录 | P1/Phase 1 | complete |
| G2 | 条款落地 | L1+ 首动作委派与收据/边界条款在源仓落位 | VC-1..VC-5 grep/条文检查通过 | P2/Phase 2 | complete |
| G3 | 回归守护 | 自测与守护证明零增量 FAIL | VC-6：基线对比记录 + 指定 selftest 命令 exit 0 | P3/Phase 3 | complete |
| G4 | 部署对账 | 部署位同步且差异可解释 | VC-7：diff 命令结果 + progress 记录 | P4/Phase 4 | complete |
| G5 | 终验交付 | VC 全绿并形成可追溯交付证据 | VC-1..VC-7 全 PASS + verification/progress 证据齐备 | P5/Phase 5 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码/脚本 | `skills/task-planner/SKILL.md`、`skills/task-planner/references/critical-rules.md`、`skills/task-planner/scripts/selftest-*.sh`（仅与本任务相关的新增/修改，需在变更标注表登记）、`skills/task-planner/scripts/rule-reserve.sh`（只读查询或按 20.6 必要 reserve/land 操作） | 其他 `skills/`、`agents/`、hooks、与任务无关脚本 |
| 测试 | 本任务涉及的 task-planner selftest 基线/回归产物（日志/记录文件按需落计划目录或 tmp） | 修改无关 selftest 逻辑 |
| 配置 | 无（除非 Phase 1 证据证明必须且获授权） | `config.json`、插件/MCP/基础设施配置 |
| 文档 | `plans/task-initdelegation-20261115/*`；必要时 `skills/task-planner/README.md` 或 references 索引文件（仅为一致性同步且登记） | 其他计划目录、无关 README/CHANGELOG |
| 部署对账 | `~/.zcode/skills/task-planner/**`、`~/.agents/skills/task-planner/**`（同步/对账目标） | 其他全局技能/agent 目录 |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户（问询按 Rule 70 四要素）

## 📋 变更标注表（Rule 74.3 — 修订方案必填，无表=无效方案）

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 用户原话（逐字） | 依据（证据） | 执行动作 |
|------|------------------|---------------------------|-----------|----------------|------------------------|---------|
| CA-1 | `skills/task-planner/SKILL.md`「计划制作循环」初始化/计划确认段 | 修改/新增 | 增量 | user-session-log.md#1 R1/R3 | 现状锚点 SKILL.md:36-63,194-202；R1-R3 拆解 | 新增 L1+ 首动作委派条款、收据契约、主进程边界、轻量豁免；保留 D1/attest/sentinel 既有语义 |
| CA-2 | `skills/task-planner/references/critical-rules.md`（核心域） | 修改/新增 | 增量 | user-session-log.md#1 R1/R3 | rule-reserve next=109(候选)；需可审计契约 | 按 Phase 1 定稿新增 Rule 109（或等价子条款）并更新核心索引/路由计数；实施前 reserve、落地后 land |
| CA-3 | `skills/task-planner/scripts/selftest-init-delegation.sh`（候选） | 新增/修改 | 增量 | user-session-log.md#1 R3（固化可验证） | VC-6 需零增量 FAIL 证据；具体由 Phase 1 定稿 | 仅在必要时新增针对首动作委派/豁免/边界的静态或行为守护；否则记录“不新增”理由 |
| CA-4 | `~/.zcode/skills/task-planner/**`、`~/.agents/skills/task-planner/**` | 更新 | 增量/替代（同步） | user-session-log.md#1 R3 | 运行位需与源仓一致 | Phase 4 同步源仓改动并 diff 对账，差异登记 |
| CA-5 | `plans/task-initdelegation-20261115/*` | 修改 | 增量 | （计划执行回填） | Rule 19/62 落盘 | 执行期回填 findings/progress/verification 证据与状态 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

> 目的：对齐任务知识库。Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | task-planner 计划制作循环与 D1/attest/sentinel 现状 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md:36-80 | 必读 | ☑（计划期已读） |
| 规范/标准 | 核心规则域与编号预留机制 | /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md; skills/task-planner/scripts/rule-reserve.sh | 必读 | ☑（计划期已读） |
| 项目内部文档/知识库 | Plan Writer agent 契约 | /home/terry/.zcode/agents/plan-writer.md | 参考 | ☑ |
| 项目内部文档/知识库 | 执行通道分级/轻量豁免口径 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md:194-202; plan-template-kit/task-discipline 相关卫星（按需） | 必读 | ☐（执行期复核） |
| 项目内部文档/知识库 | 自测体系与基线 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest*.sh, run-selftests.sh | 必读 | ☐（Phase 1 建基线） |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 如何在不破坏现有 D1/attest/sentinel/轻量豁免语义的前提下，把 L1+ 初始化阶段的需求分析与计划文档创建可靠委派给子代理，并让主代理仅以结构化收据完成后续确认流程？解决后可交付“条款固化 + 可验证 + 已部署对账”的技能优化。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（R1-R3 均有可检验条款与证据链）
- [x] 核心问题不解决，其他工作都白费吗？（不改流程条款/边界则无法稳定降低主上下文占用）
- [x] 核心问题的解决方法是清晰的、可执行的？（锚点已定位，分 Phase 实施与 VC 明确）

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| P1-S1 锚点与条款形态定稿 | LOCAL-ONLY | `首动作委派`, `计划确认 attest`, `L0 mini 豁免` | 本地代码/文档检索（grep/read） | findings 锚点清单 + 设计决策 | 不适用 |
| P1-S2 编号/自测基线盘点 | LOCAL-ONLY | `rule-reserve next`, `selftest init`, `baseline FAIL` | 本地脚本与文件系统 | 基线记录与受影响测试清单 | 不适用 |
| P2-S1 条款实现 | LOCAL-ONLY | `task_plan.md receipt`, `subagent dispatch`, `plan-created sentinel` | 本地源码/规则文档 | 代码/文档 diff | 否（仅内部知识） |
| P3-S1 守护回归 | LOCAL-ONLY | `selftest delegation`, `zero incremental FAIL` | 本地测试执行 | 回归日志与对比结论 | 否 |
| P4-S1 部署对账 | LOCAL-ONLY | `diff -rq task-planner`, `~/.zcode ~/.agents` | 本地文件对比 | 对账记录 | 不适用 |
| P5-S1 终验交付 | LOCAL-ONLY | `VC verify`, `收尾回读` | 本地证据核验 | 终验结论 | 不适用 |

> 无 NET-* 条目：本任务完全基于仓内技能源码、规则与本地自测/部署位事实可完成。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）

n/a（纯执行类/条款实现类：产出为技能条款与验证证据，非对标归因型结论；相关事实证据通过 VC 命令与文件锚点覆盖）

## Current Phase
Phase 5

## Next Step
终验交付：Handoff/委派统计回填 → run-verification VC 全量复验 → check-complete → 84.14 收尾回读 → 归档 → 交付总结。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 general-purpose(sonnet/默认)、机械守卫脚本(bash/grep/rule-reserve next) | 需要跨 SKILL/rules/scripts 定位锚点并产出基线证据；只读分析适合子代理隔离上下文。 |
| Phase 2 | Agent 子代理 code-assistant/general-purpose、Worktree 隔离(git)、文件编辑工具 | 修改 skills/ 保护区源码需隔离开发与细粒度编辑，子代理承载实现细节。 |
| Phase 3 | Agent 子代理 code-assistant/general-purpose、Bash(自测脚本) | 运行/补充 selftest 并对比基线，证据化输出便于 VC-6。 |
| Phase 4 | Agent 子代理 general-purpose、Bash(diff/cp/rsync按需) | 部署对账为机械对比+同步操作，子代理执行并回传 diff 证据。 |
| Phase 5 | 主进程编排 + Agent 子代理(verification-gate/核验，可选)、机械守卫脚本 | 终验需汇总 VC 证据与收尾簿记；主进程负责 D1 后流程与最终呈报。 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 激活条件（无 ≥3 独立 fan-out S-unit 并行组需求、非长链编排型、用户未点名 /workflow）→ 采用 Rule 21.4 独立性守门调度（本计划以串行 Phase 为主，Phase 内 S-unit 可按依赖并行但当前无强制并行组）。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 作为任务目标证据源；用户未显式使用 /goal 命令锚定，/goal 为用户侧 harness 命令技能层不可代调。

## Phases

### Phase 1: 锚定、基线与设计定稿
- [x] 精读 SKILL.md 初始化/计划确认与 L0 边界段，定稿首动作委派插入点与主进程职责切分
- [x] 盘点 critical-rules 编号/索引现状与 selftest 基线，确定 Rule 109（或 SKILL-only）策略及受影响测试集
- [x] 回填 findings.md/knowledge-brief.md/Decisions（锚点、基线、风险）
- **V-N:** VC-5, VC-6
- **Status:** complete
- **Executor:** general-purpose(sonnet)

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6) 锁定 SKILL.md 改动锚点与条款边界 | 继承 | `skills/task-planner/SKILL.md:36-80,194-202`（初始化/计划确认/L0边界） + `plans/task-initdelegation-20261115/findings.md`（需求拆解） | findings 记录精确插入点、会话绑定脚本边界、L1+/豁免判定 | 15min | 1f/80l/15min | task-planner, task-dispatch | - | complete |
| S2 | (A6) 核对 Rule 候选与自测基线 | 继承 | `skills/task-planner/references/critical-rules.md`（编号/索引区）+ `skills/task-planner/scripts/rule-reserve.sh`（next 只读查询；selftest 盘点动作移入验收执行） | progress 记录 next 结果、候选策略（已定 SKILL-only）、selftest 清单与基线命令结果摘要 | 15min | 2f/60l/15min | verification-gate | - | complete |

### Phase 2: 条款实现（worktree）
- [x] 创建 worktree 并在其中实现 SKILL.md 首动作委派/收据契约/主进程边界/轻量豁免条款
- [x] 按定稿策略更新 critical-rules.md（新增 Rule 或等价条款）及必要索引/引用一致性（Q1 SKILL-only 定稿→critical-rules.md 无操作，CA-2 关闭）
- [x] 变更标注表与 progress 证据回填
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5
- **Status:** complete
- **Executor:** general-purpose(sonnet)（2026-11-15 终验校正：计划期写 code-assistant(sonnet) 为未登记类型名且与实际派发不符；实际执行体=general-purpose，实际改 1 文件 +9 行符合粒度门）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A7) 实现 SKILL.md 初始化首动作委派条款 | 继承 | Phase 1 定稿结论（findings/decisions）+ `skills/task-planner/SKILL.md:36-80`；worktree 路径 `tmp/worktrees/task-initdelegation-20261115` | SKILL.md 含首动作委派、执行体优先/降级、收据契约、主进程职责与 L1+ 豁免声明；git diff 可读 | 15min | 1f/60l/15min | task-planner, task-discipline | S1,S2(Phase1) | complete |
| S2 | (A7) 实现 core 规则/索引一致性更新 | 继承 | `skills/task-planner/references/critical-rules.md`（编号/索引区）+ Phase 1 Rule 策略；`skills/task-planner/scripts/rule-reserve.sh` 用法 | 规则条文与索引一致（若新增 Rule 已 reserve 记录）；VC-5 命令可命中 | 15min | 1f/60l/15min | task-planner | S1 | complete |

### Phase 3: 守护与自测回归
- [x] 建立改前基线快照（如未在 P1 完成则补齐）并执行受影响/必要 selftest
- [x] 必要时新增最小守护 selftest，确保对新条款关键语义可检测（Q2 定稿：不新增守护；VC-1..VC-4 grep+全量回归承载；插入引起的 BP-08 断言冲突已最小修复 dcf7190）
- [x] 产出零增量 FAIL 对比证据
- **V-N:** VC-6, VC-3
- **Status:** complete
- **Executor:** general-purpose(sonnet)

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6) 采集/确认基线并运行回归自测 | 继承 | Phase 1 基线计划 + `skills/task-planner/scripts/run-selftests.sh` 及目标 selftest；worktree 改动后代码 | progress 记录基线与回归结果、失败清单对比、零增量 FAIL 结论 | 15min | 2f/80l/15min | verification-before-completion | S2(Phase2) | complete |
| S2 | (A7) 补齐必要守护（按需） | 继承 | VC-1..VC-4 关键语义 + 现有 selftest 风格（`skills/task-planner/scripts/selftest-*.sh`） | 若新增守护：脚本存在且通过；若不新增：progress 明确理由与替代证据 | 15min | 2f/60l/15min | task-discipline | S1 | complete |

### Phase 4: 部署与对账
- [x] 将源仓 `skills/task-planner/**` 同步至 `~/.zcode/skills/task-planner` 与 `~/.agents/skills/task-planner`（实作扩展探测并同步 4 位：zcode/agents/claude/cursor，claude 位原已一致；agents 位原缺 2 文件已补齐 mkdir+cp）
- [x] 执行 diff 对账并登记差异/结论（Q3 口径：先 diff 摸底判向→scope 2 文件 cp→复验 diff=0；位上既有差异（zcode 2/agents 175/cursor 8）登记未动）
- **V-N:** VC-7, VC-5
- **Status:** complete
- **Executor:** general-purpose(sonnet)

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A7) 同步部署位并执行 diff 对账 | 继承 | 源仓 `skills/task-planner/`（Phase 3 通过态）+ 目标 `~/.zcode/skills/task-planner/`、`~/.agents/skills/task-planner/` | 两处 diff 命令结果记录在 progress；无意外差异或差异有理由登记 | 15min | 2f/60l/15min | task-discipline | S2(Phase3) | complete |

### Phase 5: 终验与交付
- [x] 汇总 VC-1..VC-7 证据，完成收尾回读梳理与 outcome 判定（run-verification PASS=8 FAIL=0，口径=7 VC+1 V-2.1 重复项误标注记见 verification.md Phase 5 Status；84.14 两轮收敛；Goal Gate outcome=COMPLETE）
- [x] 整理交付摘要（含 files_created/任务ID/关键设计/open questions）
- **V-N:** VC-1, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由:② 簿记与终验编排/证据汇总——Rule 25.3 白名单）

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1 | ① verification.md 全部 Verify command 行含 markdown 反引号→run-verification 全 VC exit=127（判例「反引号→127」复发，模板写入面缺陷）；② P2 Executor 字段 code-assistant(sonnet)=未登记类型名与实际派发 general-purpose 不符→委派统计 verdict=violation；③ verification.md 终验占位面（Phase 状态/核验/委派 JSON/质量门控/Goal Gate）未填；④ findings.md Technical Decisions 首行保留 SKILL+core 双锚候选措辞（已被 Q1 SKILL-only 取代，属历史决策演进留痕非矛盾） | ① sed 去反引号重跑 run-verification=PASS 8/FAIL 0（evidence/*.out）；② Executor 校正 general-purpose+Decisions 登记+attest 重锁 786268f1+stats 复跑 0.8/ok；③ 全部占位终验回填（Phase 门 5/5 complete+Goal Gate VC-1..7 PASS+outcome COMPLETE）；④ 保留不改（S1 锚点锁定段 L91 已载 Q1 定稿，演进链完整） |
| 2 | 零新发现（verification.md 占位残留 grep=0、委派统计 ok、组合态回归 FAIL⊆基线既有、4 部署位实锚一致、六文档五维互洽） | 连续一轮零新发现→收敛出口达成（轮次不设上限规则满足） |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（修改 `skills/task-planner/**` 属运行中技能基础设施/保护区，§十一 命中） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-initdelegation-20261115` |
| `branch` | `wt/task-initdelegation-20261115` |
| `merge_back` | `merged(a745157, 2026-11-15；并行合流 BP-08 钉并集解=300；worktree+分支已清理)` |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。计划文档保留主仓 `plans/task-initdelegation-20261115/`。

## 📊 FMEA 预演（规划期）
| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | 锚点漂移/编号候选误判导致设计返工 | 6 | 4 | 5 | 120 | ① 以 Read+grep 实锚重验并记录；② 若编号冲突走 `rule-reserve.sh next` 重选并更新 Decisions；证据写 findings。 |
| Phase 2 | 条款改动破坏 D1/attest/sentinel 或轻量豁免语义 | 9 | 4 | 4 | 144 | ① 最小增量改动+diff 自审；② 复用现有关键语句并加回归检查；③ 失败则拆细 S-unit 回滚到上一绿态（22.3②/④）。 |
| Phase 3 | 自测回归出现增量 FAIL 或无法定位基线 | 8 | 4 | 5 | 160 | ① 先固化改前基线记录；② 失败按 31.2 根因分析并最小修复；③ 仍失败升级用户决策/转 PARTIAL（22.3⑤）。 |
| Phase 4 | 部署位 diff 不一致或误覆盖本地差异 | 7 | 3 | 5 | 105 | ① 同步前记录目标现状/diff；② 仅同步 task-planner 目录；③ 异常差异停下报告并请示（22.3⑤）。 |

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 计划获批后按 S1 建立映射 |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |

## Key Questions
1. 条款落点采用“SKILL.md + 新 core Rule 109”双锚还是“SKILL.md-only + 现有 Rule 索引补注”？→ **已定稿（2026-11-15 主进程裁决）：SKILL-only 条款块**（依据=宪法 §二/§四 文本优先铁律 P0：条款落入指令载体即完成；Rule 109 编号登记+纪元级联+land 仪式与用户元目标「降低开销」相悖；VC-5 fallback 分支已允许；rule-reserve 109 释放不占用。VC-5 走 fallback 命令分支）
2. 是否需要新增专用 `selftest-init-delegation.sh`？→ **已定稿：默认不新增**（宪法文本优先铁律：未显式要求禁新增守护脚本；VC-1..VC-4 grep 命令=可执行验证 + 全量回归零增量=VC-6 即足。例外=若回归发现既有 selftest 内容断言与新条款冲突，允许最小修改既有 selftest——修改既有≠新增扩张）
3. 部署位对账口径？→ **已定稿：同步前逐位 diff 摸底漂移方向 → 文件级 cp 仅本任务 scope 文件（禁整仓 add/pathspec 锁定）→ 对账 diff 复验 → 意外差异登记不强覆盖**（判例：task-v192 同步前抽样确认漂移方向）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 本计划将“首动作委派”限定为 L1+，显式豁免 L0/mini/trivial/L0-E 轻量路径 | 对齐 R1/R2 与 Rule 38.6/38.7 比例原则，避免增加简单任务仪式。 |
| 首选执行体 Plan Writer，失败降级 general-purpose 并在收据/进度留痕 | 复用专职 agent 提升计划质量；本次 dogfood 已出现 `reasoning-level-missing` 失败并成功降级，证明 fallback 必要。 |
| 会话绑定脚本与 D1/attest/收据回收归主进程；计划子代理只做分析与文档产出 | 避免会话态副作用竞争与越权，保持现有哨兵/确认链路稳定。 |
| 实施走 worktree（tmp/worktrees）并在源仓改后部署对账 | 满足 §十一 对 skills 保护区/基础设施修改要求，降低半残风险。 |
| new_rule 暂记 109(候选)，实施前 check/reserve 定稿 | `rule-reserve.sh next` 当前返回 109，但计划阶段未执行 reserve；遵守 Rule 20.6 并避免编号抢占。 |
| 本次派发作为 dogfood 首实例记录在 progress/findings | 直接响应 R1“初始化阶段委派子代理”要求并提供可追溯证据。 |
| Q1 条款形态=SKILL-only 条款块（不占新 Rule 编号，禁 1-109 级联） | 宪法 §二/§四 文本优先铁律 P0（条款落载体即完成）+ 用户元目标「降低开销」；编号登记/级联仪式本身即开销；VC-5 fallback 分支允许 |
| Q2 守护=默认不新增专用 selftest；VC-1..VC-4 grep+全量回归零增量承载；既有 selftest 冲突时允许最小修改 | 宪法文本优先铁律（未显式要求禁新增脚本/守护）；修改既有≠新增扩张 |
| Q3 部署对账=先逐位 diff 摸底→文件级 cp scope 文件→diff 复验→意外差异登记 | 判例 task-v192：同步前抽样确认漂移方向；pathspec 锁定防捎带 |
| P2 Executor 字段校正=code-assistant(sonnet)→general-purpose(sonnet) | check-delegation stats verdict=violation（未登记类型名）+实际派发回执=general-purpose；字段须反映真实执行体（TAMPERED 重锁闭环：本行登记+重跑 attest） |
| D1 自动裁决记录（五要素）：① 超时值=0（goal 模式连续推进）② 推荐项=按已展示计划执行 ③ 触发时间=2026-11-15 计划确认 ④ 裁决理由=用户 /goal 为完成性指令场景（Rule 44.3 超时自动通过口径），运行时明示「继续推进勿停等」⑤ 被覆盖选项=无限等待显式 yes；Goal 绑定复述：本计划 Goal=「L1+ 任务初始化阶段需求分析与计划文档创建固化为首动作子代理委派，主代理仅回收结构化收据并保留会话绑定/确认职责，不增加 L0/mini/trivial 仪式」，服务用户指令=user-session-log.md#1 原话（R1-R3） |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| Plan Writer 首派失败（reason=reasoning-level-missing） | 1 | 改派 general-purpose 完成计划文档产出并留痕 | → progress.md Error Log；条款固化优先级与降级记录 |
| attest 首锁拒绝（P2S1/P2S2/P3S2 粒度 120l>100 硬门；时长 `≤` 前缀不可解析；P1S2 输入 3 路径>2）+ 退出码误读（管道 `$?` 取到 tail 非 attest） | 1 | 粒度降至 60l、时长去 ≤ 前缀、输入收敛 2 路径后重锁（TAMPERED 重锁闭环：Decisions 已登记+重跑 attest） | 粒度三值/格式判据先看脚本实测；attest 退出码用 PIPESTATUS 独立取，禁管道尾取 |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-11-15 | ALIGNED（Phase 0-1 偏移检查；检查点 .drift-check-p1.md） | VC-5, VC-6 | 继续 Phase 2（worktree 内条款实现） |
| 2026-11-15 | ALIGNED（Phase 2 偏移检查；检查点 .drift-check-p2.md） | VC-1..VC-5 | 继续 Phase 3（worktree 全量回归） |
| 2026-11-15 | ALIGNED（Phase 3 偏移检查；检查点 .drift-check-p3.md） | VC-6 | 继续 Phase 4（合并回+部署对账） |
| 2026-11-15 | ALIGNED（Phase 4 偏移检查；检查点 .drift-check-p4.md） | VC-7 | 进入 Phase 5（终验交付） |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）
| 字段 | 值 |
|------|-----|
| `total` | n/a |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | n/a |
| `pre_check` | n/a |
| `rollback_point` | n/a |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 4/5（P1-P4 全部子代理执行）+ Phase 0 计划产出派发 |
| 主进程直做 Phase 清单 | Phase 5（白名单②：簿记与终验编排/证据汇总）；git/worktree 编排与 stash 窗口=白名单① |
| 委派率 | 0.80（4/5 ≥ 0.7 达标） |
| 激活子代理数（Rule 96.5） | 10（1 Plan Writer 失败重派 + 1 计划 + 1 P1 + 1 P2 + 1 P3 + 4 drift-checker + 1 部署） |
| 最大并行宽度（Rule 96.5） | 1（串行依赖链） |
| 串行化例外理由（Rule 96.4） | Phase 1→2→3→4→5 存在产物依赖（设计→实现→回归→部署→终验），并行组 none |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-11-15 17:25 | plan-writer | 产出 task-initdelegation-20261115 计划文档（首动作委派 dogfood） | failed | 首派失败，未产出计划文件 | （主进程派发回执：reason=reasoning-level-missing） | findings.md Issues/Resources | n/a | 首选执行体失败 / 0 / ☐ |
| 2 | 2026-11-15 17:30 | general-purpose | 承接首派失败，完成需求分析与计划文档创建 | done | 已写 task_plan/findings/knowledge-brief/progress/verification；Phase 5，VC 7；open questions 3 | plans/task-initdelegation-20261115/{task_plan.md,findings.md,knowledge-brief.md,progress.md,verification.md} | findings.md Requirements/Research | n/a | Plan Writer降级 / 1 / ☑（盘上复核 332 行+frontmatter） |
| 3 | 2026-11-15 17:47 | general-purpose | P1 S1+S2 锚点锁定与基线采集 | done | 插入点 L48/L49 定稿+基线 97 脚本 PASS=94 FAIL=3（改前既有）+69 个 SKILL.md 断言测试 | progress.md:28-49 | findings.md Technical Decisions S1 段 | n/a | 锚点盘上复测 / 1 / ☑ |
| 4 | 2026-11-15 18:52 | general-purpose | P2 S1+S2 worktree 条款实现+引用面核查 | done | SKILL.md +9 行（L49-57 七要素）commit 2bb24f4；无直接锚断言冲突 | progress.md:51-80 | progress Phase2 段 | n/a | V-N 直跑 VC-1..5 全 PASS / 1 / ☑ |
| 5 | 2026-11-15 19:05 | general-purpose | P3 S1+S2 全量回归+守护判定 | done | 插入致 BP-08 钉超限→最小修复 dcf7190；终态 FAIL=2 全基线既有；不新增守护（Q2） | progress.md:112-151 | progress Phase3 段 | n/a | diff 盘上复核+提交实测 / 1 / ☑ |
| 6 | 2026-11-15 18:15 | drift-checker | P1 偏移检查 | done | ALIGNED | .drift-check-p1.md | Drift Log | n/a | 检查点在盘 / 1 / ☑ |
| 7 | 2026-11-15 19:20 | drift-checker | P2 偏移检查 | done | ALIGNED | .drift-check-p2.md | Drift Log | n/a | 检查点在盘 / 1 / ☑ |
| 8 | 2026-11-15 19:35 | drift-checker | P3 偏移检查 | done | ALIGNED | .drift-check-p3.md | Drift Log | n/a | 检查点在盘 / 1 / ☑ |
| 9 | 2026-11-15 19:55 | drift-checker | P4 偏移检查 | done | ALIGNED | .drift-check-p4.md | Drift Log | n/a | 检查点在盘 / 1 / ☑ |
| 10 | 2026-11-15 19:47 | general-purpose | P4 S1 部署位同步与对账 | done | 4 位（zcode/agents/claude/cursor）scope 2 文件同步 diff=0；既有差异登记未动 | progress.md Phase4 部署对账段 | Drift Log/VC-7 证据 | n/a | 主进程 4 位实锚复核 / 1 / ☑ |