# Task Plan: 收尾回读梳理迭代机制——全文档体系只写不读根治
template_type: general
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「很多任务执行过程中出现的偏移应该就是偏移，没有对当前的就是计划文档体系进行有效的就是利用，也就是说各种文档的各种文档存在了只写不读的情况」<sub>（[目标]）</sub>
- **R2**: 「查询到的知识，可能说在几轮对话之后被淹没到了，但是其实这个知识点已经记录到了特定的文档中……只写入、不读取，那就是没有任何价值的」<sub>（[目标]）</sub>
- **R3**: 「在完成任务之后，就是说所有任务完成之后，增加一个就是增加一个步骤，就是回读这些文档，回顾这些文档……就是每次完成任务，就是提交之前，将这些文档进行梳理，尤其是当前的技能涉及的几个文档体系，比如说用户的需求、用户的知识体系以及执行过程……追踪」<sub>（[目标]）</sub>
- **R4**: 「进行的回顾梳理，发现本轮执行是否有偏移，就进行主动性的纠正。如果说发现问题，那么就回去进行迭代……然后再梳理，再改再改再梳理，我希望引入这个迭代体系，不要怕浪费资源。没有解决问题才是对资源最大的浪费」<sub>（[目标]）</sub>
- **R5**: 「我希望同步在模板以及相关的Todo执行过程中……增加一个这种回顾梳理文档的步骤」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 | 84.14 收尾回读梳理迭代条款在位（verification-gate 卫星 grep 锚）+SKILL 终验链新步骤在位 |
| R2 | VC-1 | 条款读取范围显式含 findings/knowledge-brief（知识体系回读面） |
| R3 | VC-1, VC-2 | 触发点=全部 Phase complete 后/outcome 判定前；读取面=五文档体系全量 |
| R4 | VC-1 | 迭代环条款在位（发现→修复→再梳理→收敛出口=连续一轮零新发现）+task_plan 梳理记录区块（轮次留痕） |
| R5 | VC-2, VC-3 | 模板三处承载（task_plan 区块/delivery-summary 结论行/专档消费点⑥）+todo-sync S4 前置引用 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-finalrecall-20261105/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1）
| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 终验交付链（SKILL L115-129） | 无内容级全文档回读步骤；VC 复验只读 verification.md | 智能子动作新增「全文档收尾回读梳理」步骤 | VC-1 |
| 终验 SOP（84.5 数据源） | 只读 verification.md+交付物，不回读 findings/progress/kb/专档 | 84.5 前置引用句+新子条 84.14（verification-gate 卫星） | VC-1 |
| 知识体系消费（kb） | 终验期零消费（62.4 派发前/62.5 翻转门之外无读取点） | 84.14 读取面显式含 knowledge-brief | VC-1, VC-2 |
| 模板承载 | task_plan/delivery-summary/专档消费点表无梳理记录载体 | 三模板增区块/行/⑥ 行 | VC-2 |
| Todo 承载 | S4 终态同步不含回读梳理前置 | todo-sync S4 前置引用 | VC-3 |
| 机器守护 | 内容偏移不可机器判（84.7 先例） | selftest 静态锚，零新 GATE 零新 config 键 | VC-4 |

## Goal
在 task-planner 终验交付链落「收尾回读梳理迭代」强制步骤（新子条 84.14+SKILL 终验链新步）：全部 Phase complete 后、outcome 判定前，全量回读五文档体系（用户需求专档/计划目标/findings 知识/progress 执行/verification 追踪）做五维互洽检查，发现偏移→迭代修复→再梳理，收敛出口=连续一轮零新发现；模板与 Todo 同步承载。

## 🔒 不变量声明区（Rule 73.3）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | 80.1-80.8 既有文本零改动；84.7/103.6 既有分工面零改动；check-complete 既有 GATE 零改动；既有 selftest 断言只增不减 | 各规则文件 |
| 🔀 可变量 | 84.14 新子条措辞与插入位置；SKILL 终验链步骤插入点；模板区块形态；selftest 新断言 | - |
| 📈 学得量 | 梳理机制实测教训→findings.md | findings.md |

## 🔒 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-finalrecall-20261105` |
| `scope_files` | skills/verification-gate/references/critical-rules-verification.md；skills/task-planner/SKILL.md；skills/task-planner/templates/task_plan.md；skills/task-planner/templates/delivery-summary.md；skills/task-planner/templates/user-session-log.md；skills/task-planner/references/todo-sync.md；skills/task-planner/scripts/selftest-session-log.sh；skills/verification-gate/scripts/selftest-verification-gate.sh（若存在，实施时核实） |
| `interaction_mode` | `ask` |
| `自动超时默认项` | 计划确认超时 5 分钟→按已展示计划执行（Rule 44.3） |
| `new_rule` | 留空（84.14 为 verification-gate 卫星既有 Rule 84 域新子条） |
| `质量审查工具` | 既有 general-reviewer / critic |

## ✅ Verification Contract

> **验证独立性**：验证动作默认由独立子代理执行，主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 84.14 条款在位且含迭代环+收敛出口+五文档读取面+五维互查；SKILL 终验链步骤在位 | grep+Read 条款 | grep "84.14" 两文件 + 关键词锚 |
| VC-2 | 模板三处承载在位 | grep 锚 | grep 三模板 |
| VC-3 | todo-sync S4 前置引用在位 | grep | grep todo-sync.md |
| VC-4 | selftest 扩断言后全绿 | 运行 selftest | bash 两 selftest |
| VC-5 | 全量 selftest 与 master 基线一致（零新增 FAIL） | 全量对照 | worktree vs master 差集空 |
| VC-6 | 部署 3 位 diff=0 | diff | 3 位改动文件 0 diff |
| VC-7 | worktree 合并回+清理 | git 证据 | git log+worktree list |

**终验规则**：全部 VC 通过 → COMPLETE；有遗留 → PARTIAL；3 次重试无效 → BLOCKED

## 🛡 双轮质检与同步完整性声明（Rule 103）
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | 默认全适用 |
| 豁免登记 | none |
| 多文件变更集预判 | Phase 3 全部 S-unit（7-8 文件）→ Phase 4 翻转前过 103.6 |

## 🎯 核心问题定义
**核心问题**: 计划文档体系（专档/task_plan/findings/kb/progress/verification）全部只写不读——写入面纪律完备，但收尾交付期无任何「全量回读+互洽检查+偏移迭代」步骤，知识在上下文压缩后永久沉没，偏移无人主动发现。
**核心问题判断**:
- [x] 解决后能交付吗？能——交付前强制回读梳理，偏移在 outcome 判定前被拦截迭代
- [x] 不解决其他工作白费吗？是——知识只写不读=落盘劳动全部白费
- [x] 方法清晰可执行？是——Explore 已产出落点清单（五面分工互斥设计）

## 🔍 调研需求与检索计划（Rule 75.1）
| S-unit/子目标 | 三态 | 检索关键词 | 检索渠道 | 预期产出形态 | 网络解难评估 |
|---------------|------|-----------|----------|--------------|--------------|
| P1 调研 | LOCAL-ONLY | 终验链/回读机制/84.5 SOP | 本仓 grep+Read | findings+检查点 | 否（Phase 1 已完成） |
| P3 实施 | LOCAL-ONLY | 84.7/103.6/80.8 分工锚 | 本仓 Read 原文核对 | 条款文本 | 否 |

## Current Phase
DONE（全 Phase complete 2026-11-05）

## Next Step
全量基线对照→CR→部署 3 位→合并回

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面 | 选择理由 |
|-------|-----------|---------|
| Phase 1 | Agent Explore | 终验链盘点隔离主上下文（已完成） |
| Phase 2 | 主进程（白名单②⑥） | 设计裁决 |
| Phase 3 | Agent general-coder×并行 | 多文件规则文本修改 |
| Phase 4 | Agent general-reviewer+主进程编排 | CR 隔离视角 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 → Rule 21.4 守门调度（S1/S2/S4 文件互斥并行组）

## Phases

### Phase 1: 调研缺口定位
- [x] 终验链盘点（L115-129 无内容级回读）
- [x] 回读机制盘点（80.4/3f/93.3/80.8/103.6/kb/check-complete 分工图）
- [x] 缺口清单+落点建议落盘 findings+检查点
- **V-N:** VC-1
- **Status:** complete
- **Executor:** Explore（haiku）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 96 类别 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|---------|-------------|---------|------|------|------|------|------|
| S0 | 终验链与回读缺口盘点 | Explore（haiku） | A1 | 本仓 skills/ | 检查点 01-explore-finalchain.md+落点建议 | 8min | 1f/70l/15min | 无 | - | complete |

### Phase 2: 设计定稿
- [x] 84.14 条款全文设计（迭代环+收敛出口+五面分工声明）
- [x] 变更标注表登记
- [x] 计划展示+用户审批（D1 超时 5min 自动通过，Rule 44.3 登记：推荐项=批准执行/理由=计划与原话逐点对齐+上次同模式任务 userlog-recall 已获用户批准/被覆盖选项=缩范围版/调设计版）
- **V-N:** VC-1
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护+⑥设计裁决——Rule 25.3 白名单）

### Phase 3: 实施（worktree 隔离）
- [x] S1-S5 落地（commit 0f6c1c8，7 文件 +62/-1）
- [x] 规范召回（Rule 93）+ [recall] 行
- **V-N:** VC-1, VC-2, VC-3, VC-4（实跑 PASS：六载体锚全命中+selftest 31/31 主进程亲跑）
- **Status:** complete
- **Executor:** general-coder（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 96 类别 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|---------|-------------|---------|------|------|------|------|------|
| S1 | verification-gate 新增 84.14 收尾回读梳理迭代子条+84.5 前置引用句 | general-coder（sonnet-1） | A4/A5 | findings.md §设计稿 | grep 锚 84.14+迭代/收敛/五文档词 | 15min | 1f/40l/15min | 无 | P2 | pending |
| S2 | SKILL.md 终验链智能子动作插「全文档收尾回读梳理」步骤（VC 复验后 outcome 前） | general-coder（sonnet-1） | A4 | findings.md §设计稿 | grep 锚 收尾回读/84.14 | 15min | 1f/12l/15min | 无 | P2 | pending |
| S3 | 模板三处：task_plan 梳理记录区块/delivery-summary 结论行/专档消费点⑥行 | general-coder（sonnet-1） | A4 | findings.md §设计稿 | grep 锚 三处 | 15min | 3f/30l/15min | 无 | S1 | pending |
| S4 | todo-sync.md S4 前置引用 | general-coder（sonnet-1） | A4 | findings.md §设计稿 | grep 锚 | 15min | 1f/4l/15min | 无 | S1 | pending |
| S5 | selftest 扩断言（SL-19 消费点⑥+84.14 锚；V 系 84.14 锚） | general-coder（sonnet-1） | A7 | S1-S4 产物 | selftest 全绿 | 15min | 2f/30l/15min | 无 | S1,S2,S3,S4 | pending |

**并行组声明（Rule 96.3）**: parallel_groups: PG1={S1,S2,S4}（文件互斥）；S3 依赖 S1（锚引用）；S5 依赖全部。

### Phase 4: 回归验证+CR+部署+合并回
- [x] selftest 全绿+全量基线对照零新增 FAIL（31/31+差集 0：worktree 2 FAIL ⊆ master 14）
- [x] Code Review APPROVED（0 BLOCKER/1 MINOR=SL-19f 已收紧 commit）
- [x] 84.14 首次 dogfood：收尾回读梳理第 1 轮零新发现收敛（见梳理记录区块）
- [x] 部署 3 位 diff=0（21 对 0 diff；zcode 位实弹 selftest 31/31）
- [x] smart-merge-back 合并回 master（472b9ac）+worktree/分支已清
- **V-N:** VC-4, VC-5, VC-6, VC-7（全 PASS）
- **Status:** complete
- **Executor:** 主进程（例外理由:① 回归/部署/git 编排——Rule 25.3 白名单;CR 子代理以 Handoff 登记承载）

### Phase 5: 交付总结+归档
- [x] delivery-summary 五要素（会话交付）
- [x] check-complete → 归档（簿记 commit 后执行）
- **V-N:** VC-6, VC-7（全 PASS）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记）

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | safe |
| `isolation` | `worktree`（§11.1 保护区命中） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-finalrecall-20261105` |
| `branch` | `wt/task-finalrecall-20261105` |
| `merge_back` | `pending` |

## 📋 变更标注表（Rule 74.3）
| 编号 | 对象（文件+锚点） | 类型 | 吸收判定 | 用户原话（逐字） | 依据 | 执行动作 |
|------|------------------|------|---------|----------------|------|---------|
| CA-1 | verification-gate 84 域尾部 | 新增 84.14 | 增量 | R3/R4 | Explore 落点#2 | 追加子条 |
| CA-2 | 84.5 SOP 步骤表 | 修改（前置引用句） | 增量 | R3 | 落点#2 | 句尾追加 |
| CA-3 | SKILL.md 终验链智能段 | 修改（插步骤行） | 增量 | R3/R4 | 落点#1 | 插入步骤 |
| CA-4 | 三模板 | 修改（增区块/行） | 增量 | R5 | 落点#3 | 增量插入 |
| CA-5 | todo-sync.md S4 | 修改（前置引用） | 增量 | R5 | 落点#4 | 追加 |
| CA-6 | selftest 两脚本 | 修改（新增断言） | 增量 | R4 | 落点#5 | 只增断言 |

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | scope_files 列表 8 文件 | 其他一切 skills/scripts 文件 |
| 文档 | plans/task-finalrecall-20261105/ | 其他 plans 目录 |

## 🔗 Subagent Handoff 登记表（Rule 22.5）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-11-05 | Explore | 终验链与回读缺口盘点 | done | 终验链无内容级回读；84.5 数据源仅 verification.md；五面分工互斥设计 | 01-explore-finalchain.md | §Research Findings | plans/task-finalrecall-20261105/subagent-state/01-explore-finalchain.md | - / 0 / ☑ |
| 2 | 2026-11-05 | general-coder | PG1 并行组 S1/S2/S4（84.14 条款/SKILL 步骤/todo-sync 前置） | done | 84.14 定义+84.5 前置句/SKILL P0 迭代门行/S4 前置引用全落盘 | grep 84.14 锚 2/1/1 | §设计稿落地 | 02/03/04-s*.md | - / 0 / ☑ |
| 3 | 2026-11-05 | general-coder | S3 三模板承载 | done | task_plan 区块+delivery 结论行+专档⑥行 | grep 锚 2/1/1 | 同上 | 05-s3-templates.md | - / 0 / ☑ |
| 4 | 2026-11-05 | general-coder | S5 SL-19a..f 断言扩展 | done | 31/31 全绿（+6 断言） | selftest Total 31 | 同上 | 06-s5-sl19.md | - / 0 / ☑ |

## 🎯 Goal 单元表（Rule 66.1）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式 | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|--------------|------------------|------|
| G1 | 条款与步骤落地 | 84.14+SKILL 步骤在位 | grep 锚+Read 复核 | S1,S2 | complete |
| G2 | 模板与 Todo 载体落地 | 三模板+S4 前置引用在位 | grep 锚 | S3,S4 | complete |
| G3 | 机器守护落地 | selftest 扩断言全绿 | bash selftest | S5 | complete |
| G4 | 回归部署收口 | 零回归+diff=0+合并回 | 基线对照+diff+git log | P4 | complete |

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
<!-- 84.14 首次 dogfood：本区块由执行期追加（计划创建时模板尚未含此区块，init 渲染于改前模板） -->
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1 | 零新发现（五维对照：R1→84.14+SKILL 在位/R2→kb 纳入读取面/R3→触发点六文档/R4→迭代环+收敛出口/R5→三模板+todo-sync 全命中；VC-1..5 实跑全 PASS） | 收敛（第 1 轮零新发现=出口达成），进入 outcome 判定 |

## 🔁 模板感知
<!-- template_type: general -->
- 触发信号: 任务类型空缺 → general 兜底；Rule 34.3②: 不沉淀（一次性规则体系维护）
