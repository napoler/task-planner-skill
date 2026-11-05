# Task Plan: 修复 user-session-log 只写不读缺陷
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} token 由 init-session.sh render_template() 脚本渲染（task-id/任务名/日期/路径）；尖括号中文占位=模型填写面，脚本禁碰 -->
template_type: general
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「执行错误某个任务执行错误之后。用户有，我添加或者说补充了其他的要求，然后模型是，就是agent竟然又反过来问这些东西如何去决策，就是上面我提到的没有解决的问题如何去选择。也就是说用户上面的指令被抛弃了」<sub>（[目标]）</sub>
- **R2**: 「我之前已经明确的设计过一个，就是叫，要求用户每次请求的问题，我已经理解，全部都存入到一个用户Session，就是用户的，就是用户询问文档中。但是实际上，明显的在解，用户没有去解决这个事情」<sub>（[目标]）</sub>
- **R3**: 「我希望对用户之前的询问交互记录进行挖掘，就是说定时的回顾，或者说在结尾，或者说类似于决策的时候去读取这个用户之前记录的用户交互内容，来确保后期整个执行不会偏移用户的」<sub>（[目标]）</sub>
- **R4**: 「你必须要对，技能中，必须要对这个文件进行的有效利用」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 | 上抛裁决前读取条款锚 grep 命中（95.4 第④问 + 86.1 前置读档门 + 80.8 决策点①） |
| R2 | VC-1 | 80.8 统一锚条款在位 + 五决策点读取面全落位（grep 锚 ≥5 处） |
| R3 | VC-1, VC-6 | 周期对照（3f 联动专档尾部）+ 派发需求锚双锚 + 交付双锚条款在位 |
| R4 | VC-2, VC-3, VC-4 | selftest 扩断言全绿 + 全量零回归 + 部署 3 位 diff=0 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-userlog-recall-20261105/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 决策面-上抛裁决（AskUserQuestion/暂停请示前） | 上抛前无读档对照条款——用户已答过的问题被重新上抛（R1 抱怨直接成因） | Rule 95.4 增第④问 + Rule 86.1 前置读档门 + 80.8 决策点① | VC-1 |
| 决策面-反思门（新指令到达） | Rule 102.0 反思问不读专档既有原话 | Rule 102.0 增第⑤问 + 80.8 决策点② | VC-1 |
| 决策面-完成声称与交付 | Rule 51.3 需求覆盖只对 task_plan R 条目（转译面），不对专档原话面 | Rule 51.3 双锚升级 + delivery-summary 模板增专档条目列 + 80.8 决策点③ | VC-1, VC-6 |
| 决策面-子代理派发 | 需求锚只带 task_plan R 条目转译，子代理感知不到专档原话 | subagent_dispatch 模板需求锚双锚 + 80.8 决策点④ | VC-1, VC-6 |
| 决策面-周期对照 | 无周期回顾用户原话的节奏承载 | 3f 周期性对照扩展（纳入专档尾部原话）+ 80.8 决策点⑤ | VC-1 |
| 会话恢复 | 80.4 已覆盖（唯一既有读取面），本次保持不动 | 80.8 重申不新增 | - |

## Goal
修复 user-session-log.md 只写不读缺陷：在全部决策面（上抛裁决前 / 新指令反思门 / 完成声称与交付 / 子代理派发 / 周期对照五点）落强制「读取专档对照用户原话」条款，统一锚=新增 Rule 80.8 决策前读取纪律；确保用户已明确的指令永远进入决策上下文，杜绝「用户已要求过、agent 反过来问」。

## 🔒 不变量声明区（Rule 73.3）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Rule 80.1-80.7 既有子条文本零改动；80.2 append-only 铁律不动；drift-checker CA-7 读档机制零改动；既有 selftest 断言只增不减 | critical-rules.md Rule 80 / companion agents |
| 🔀 可变量 | 80.8 新子条措辞；95.4/102.0/51.3 扩展问法与插入位置；模板字段增列方式；selftest 新增断言形态 | - |
| 📈 学得量 | 各决策点读取条款的实施教训→findings.md，禁反向改写不变量 | findings.md |

## 🔒 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（规则体系大面积修改=受管文件变更集） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-userlog-recall-20261105` |
| `scope_files` | skills/task-planner/references/critical-rules.md；skills/task-discipline/references/critical-rules-discipline.md；skills/task-planner/SKILL.md；skills/task-planner/templates/user-session-log.md；skills/task-planner/templates/delivery-summary.md；skills/task-planner/templates/subagent_dispatch.md；skills/task-planner/scripts/selftest-session-log.sh；（可选待裁决）skills/task-planner/scripts/hooks 脚本文案 |
| `interaction_mode` | `ask` |
| `自动超时默认项` | 计划确认超时 5 分钟→按已展示计划执行（Rule 44.3） |
| `new_rule` | 留空（80.8 为既有 Rule 80 子条，非新 Rule 编号） |
| `质量审查工具` | 既有 general-reviewer / critic（Rule 42.2 已有工具，无缺口） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 五决策点读取条款全部在位（上抛裁决前/反思门/完成声称与交付/派发需求锚/周期对照），统一锚=Rule 80.8 | grep 断言各文件条款锚 | `bash skills/task-planner/scripts/selftest-session-log.sh`（含新增 SL 断言）+ grep 人工复核 |
| VC-2 | selftest-session-log.sh 扩展 SL 断言后全绿 | 运行 selftest | `bash skills/task-planner/scripts/selftest-session-log.sh` |
| VC-3 | 全量 selftest 与 master 基线一致（零新增 FAIL） | 全量跑+基线对照 | `bash skills/task-planner/scripts/run-verification.sh` + master 对照 |
| VC-4 | 部署 3 位（zcode/claude/cursor）改动文件 diff=0 | diff 命令 | 部署脚本输出+diff 复核 |
| VC-5 | worktree 合并回 master + worktree/分支已清 | git 证据 | `git log --oneline -5` + `git worktree list` |
| VC-6 | delivery-summary/subagent_dispatch 模板专档双锚字段在位 | grep 锚 | grep 模板文件 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

## 🛡 双轮质检与同步完整性声明（Rule 103）
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | 默认全适用（全部 S-unit 为多文件规则文本变更集） |
| 豁免登记 | none |
| 多文件变更集预判 | Phase 3 全部 S-unit（8 文件受管变更）→ Phase 4 翻转前过 103.6 同步核对清单 |

## 🎯 核心问题定义（强制 - 任务开始前必须回答）
**核心问题**: user-session-log.md 专档写入面完整（80.1-80.7）但读取面断链——全体系唯一读触发=80.4（仅会话恢复），上抛裁决/反思门/交付/派发/周期对照五类决策点全部不读档，导致用户已明确给出的指令脱离决策上下文，agent 反复上抛已答过的问题。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？能——五决策点补读取条款后，「已答过的问题再上抛」的根因被条款化封堵
- [x] 核心问题不解决，其他工作都白费吗？是——写入面已完备，缺的全是读取面
- [x] 核心问题的解决方法是清晰的、可执行的？是——Explore 已产出缺口清单（01-explore-userlog.md），每缺口有明确落点

## 🔍 调研需求与检索计划（Rule 75.1）
| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道 | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|----------|--------------|-------------------|
| P1 调研 | LOCAL-ONLY | Rule 80 子条、user-session-log 读写面 | 本仓 grep+Read | findings 小节+缺口清单 | 否（纯本仓盘点，Phase 1 已完成） |
| P3 实施 | LOCAL-ONLY | Rule 95.4/86.1/102.0/51.3 原文 | 本仓 Read 原文核对 | 条款文本 | 否 |

## Current Phase
DONE（全 Phase complete 2026-11-05）

## Next Step
check-complete→交付总结→归档

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 Explore | 多文件读写面盘点，隔离主上下文（已完成） |
| Phase 2 | 主进程（白名单②计划系统文件维护+⑥决策） | 设计裁决属主进程保留域 |
| Phase 3 | Agent 子代理 general-coder | 多文件规则文本修改 |
| Phase 4 | Agent 子代理 general-reviewer + 主进程编排 | CR 隔离视角+回归部署编排 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 激活条件（S-unit 串行依赖为主，无需 fan-out）→ Rule 21.4 独立性守门调度（S1/S2/S4a/S4b 文件互斥可并行，声明并行组）

## Phases

### Phase 1: 调研缺口定位
- [x] Rule 80 全貌盘点（写入面 6 条 / 读取面仅 80.4 恢复场景）
- [x] 五决策点核查（上抛/反思门/交付/派发/周期全不读档）
- [x] 实盘核查（20+ 份专档零主进程读取记录）
- [x] 缺口清单落盘 findings.md
- **V-N:** VC-1（缺口清单即 VC-1 的设计依据）
- **Status:** complete
- **Executor:** Explore（haiku）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 96 类别 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|---------|-------------|---------|------|------|------|------|------|
| S0 | user-session-log 读写面盘点+缺口清单 | Explore（haiku） | A1 | 本仓 skills/ 目录 | 检查点 01-explore-userlog.md 落盘+缺口清单 5 项 | 10min | 1f/60l/15min | 无 | - | complete |

### Phase 2: 设计定稿
- [x] 核对 Rule 95.4/86.1/102.0/51.3/3f 原文锚点位置与措辞
- [x] 设计 80.8 条款文本+各决策点扩展问法
- [x] 变更标注表登记（Rule 74.3）
- [x] 设计稿落盘 findings.md
- **V-N:** VC-1
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护+⑥设计裁决——Rule 25.3 白名单）

### Phase 3: 实施（worktree 隔离）
- [x] S0-S6 全部落地（commit 4e2198c，8 files +108/-14）
- [x] 规范召回（Rule 93）：progress 留 [recall] 行
- **V-N:** VC-1, VC-2（实跑 PASS：selftest 25/25+六锚 grep 全命中）
- **Status:** complete
- **Executor:** general-coder（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 96 类别 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|---------|-------------|---------|------|------|------|------|------|
| S1 | critical-rules.md 新增 80.8 决策前读取纪律（五决策点统一锚）+51.3 双锚升级 | general-coder（sonnet-1） | A4/A5 | plans/task-userlog-recall-20261105/findings.md §设计稿（80.8 全文+51.3 改法） | grep 锚：80.8 标题+五决策点各 1 锚+51.3「专档」锚 | 15min | 1f/50l/15min | 无 | P2 | pending |
| S2 | critical-rules-discipline.md：95.4 增第④问+102.0 增第⑤问+86.1 前置读档门 | general-coder（sonnet-1） | A4/A5 | findings.md §设计稿（三处扩展问法原文） | grep 锚：第④问/第⑤问/读档门 | 15min | 1f/30l/15min | 无 | P2 | pending |
| S3 | SKILL.md：G9 扩展读取面自查项+Rule 80 bullet 更新 | general-coder（sonnet-1） | A4 | findings.md §设计稿 | grep 锚：G9 读取面句+80.8 bullet | 15min | 1f/12l/15min | 无 | S1,S2 | pending |
| S4a | templates/user-session-log.md 增「消费点」区块（五决策点读取触发点表） | general-coder（sonnet-1） | A4 | findings.md §设计稿 | grep 锚：消费点区块标题+五行触发点 | 15min | 1f/25l/15min | 无 | S1 | pending |
| S4b | templates/delivery-summary.md 增专档条目列+templates/subagent_dispatch.md 需求锚双锚 | general-coder（sonnet-1） | A4 | findings.md §设计稿 | grep 锚：专档条目列+双锚字段 | ≤15min | 2f/25l/15min | 无 | S1 | pending |
| S5 | selftest-session-log.sh 扩 SL 断言（80.8 五决策点锚+模板双锚锚） | general-coder（sonnet-1） | A7 | S1-S4b 产物文件路径 | selftest 全绿含新断言 | 15min | 1f/40l/15min | 无 | S1,S2,S3,S4a,S4b | pending |
| S6 | hook 脚本文案三处追加「对照专档既有条目」提示句（用户 2026-11-05 已裁决纳入） | general-coder（sonnet-1） | A4 | findings.md §设计稿 | grep 锚：三处提示句 | 15min | 1f/6l/15min | 无 | S2 | pending |

**并行组声明（Rule 96.3）**: parallel_groups: PG1={S1,S2,S4a,S4b}（文件互斥：critical-rules.md / critical-rules-discipline.md / user-session-log.md 模板 / 两模板，四问全 no）；S3/S5/S6 串行依赖。

### Phase 4: 回归验证+CR+部署+合并回
- [x] selftest-session-log.sh 全绿（VC-2：worktree 25/25）
- [ ] 全量 selftest 与 master 基线对照零新增 FAIL（VC-3）
- [x] Code Review（general-reviewer 独立视角）APPROVED（0 BLOCKER/1 MINOR 已采纳收紧）
- [x] 部署 3 位 diff=0（VC-4：zcode/claude/cursor 24 对文件 0 diff；zcode 位 selftest 复跑 25/25 实弹）
- [x] smart-merge-back 合并回 master+清 worktree（VC-5：0774bba）
- [x] 103.6 同步核对清单全绿（8 文件变更集：规则族/模板族/hook 族 selftest 25 断言机器核对）
- **V-N:** VC-2, VC-3, VC-4, VC-5（全 PASS：selftest 基线对照差集空/CR APPROVED/部署 24 对 0 diff/0774bba）
- **Status:** complete
- **Executor:** 主进程（例外理由:① 回归/部署/git 编排——Rule 25.3 白名单;CR 子代理派发以 Handoff 表登记承载）

### Phase 5: 交付总结+归档
- [x] delivery-summary 五要素输出（会话交付，含三仓 ahead 呈报）
- [x] check-complete → 归档 archive-plan.sh（Rule 27.3 簿记 commit 后归档）
- **V-N:** VC-5, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | safe（改 skills/ 源仓受管文件，无运行中基础设施直接写；hook 文案 S6 若纳入涉及 hooks 目录脚本） |
| `isolation` | `worktree`（§11.1 命中：修改技能文件=保护区） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-userlog-recall-20261105` |
| `branch` | `wt/task-userlog-recall-20261105` |
| `merge_back` | `merged(0774bba)` |

## 📋 变更标注表（Rule 74.3）
| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 用户原话（逐字） | 依据（证据） | 执行动作 |
|------|------------------|---------------------------|-----------|----------------|------------------------|---------|
| CA-1 | critical-rules.md Rule 80 尾部 | 新增 80.8 子条 | 增量 | R4「必须要对这个文件进行的有效利用」 | Explore 缺口#5 | 追加子条不碰 80.1-80.7 |
| CA-2 | critical-rules.md Rule 51.3 | 修改（双锚扩展） | 增量（既有口径保留+扩展） | R3「决策的时候去读取……用户交互内容」 | Explore 缺口#3 | 双锚升级 |
| CA-3 | critical-rules-discipline.md 95.4/102.0/86.1 | 修改（扩展问法） | 增量 | R1「agent竟然又反过来问这些东西如何去决策」 | Explore 缺口#1/#2 | 扩问不改既有问 |
| CA-4 | SKILL.md G9+Rule 80 bullet | 修改 | 增量 | R4 | Explore 缺口#5 | 扩展自查项 |
| CA-5 | templates 三文件 | 修改（增列/增区块） | 增量 | R3「定时回顾/结尾/决策时读取」 | Explore 缺口#3/#4 | 增列不删既有字段 |
| CA-6 | selftest-session-log.sh | 修改（新增断言） | 增量 | R4 | 缺口#5 | 只增断言 |
| CA-7 | hook 脚本文案（S6） | 修改（追加句） | 增量 | R3「定时回顾」 | 缺口#2 | 追加提示句（用户已裁决纳入 2026-11-05） |

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | scope_files 列表 8 文件（S6 经用户裁决后纳入 hooks 脚本） | 其他一切 skills/scripts 文件 |
| 文档 | plans/task-userlog-recall-20261105/ 计划目录 | 其他 plans 目录 |

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-11-05 | complete |
| Phase 2 | ☑ | 2026-11-05 | complete |
| Phase 3 | ☑ | 2026-11-05 | in_progress |
| Phase 4 | ☐ |  | pending |
| Phase 5 | ☐ |  | pending |

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 2 | 2026-11-05 | general-coder×4 | PG1 并行组 S1/S2/S4a/S4b | done | 80.8+三处扩展+消费点+双锚全落盘 | 六锚 grep | §设计稿落地 | 02~05-s*-*.md | - / 0 / ☑ |
| 3 | 2026-11-05 | general-coder×2 | S3/S6 | done | G9/bullet 扩展+hook 三处文案 | grep+bash -n | 同上 | 06/07-s*.md | - / 0 / ☑ |
| 4 | 2026-11-05 | general-coder | S5 selftest 扩断言 | done | SL-13..18 共 25 断言全绿 | selftest 输出 | 同上 | 08-s5-selftest.md | - / 0 / ☑ |
| 5 | 2026-11-05 | general-reviewer | CR 独立审查 | done | APPROVED 0 BLOCKER/1 MINOR 已采纳 | 09-cr-review.md | 同上 | 09-cr-review.md | - / 0 / ☑ |
| 1 | 2026-11-05 | Explore | user-session-log 读写面盘点 | done | Rule 80 六条写入纪律零读触发；五决策点全不读档；缺口清单 5 项 | 01-explore-userlog.md | §Research Findings | plans/task-userlog-recall-20261105/subagent-state/01-explore-userlog.md | - / 0 / ☑ |

## 🎯 Goal 单元表（Rule 66.1）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 规则条款落地 | 80.8+四扩展点条款在位 | grep 锚命中+条款文本 Read 复核 | S1,S2 | complete |
| G2 | 模板与 SKILL 载体落地 | G9/模板双锚/消费点区块在位 | grep 锚命中 | S3,S4a,S4b | complete |
| G3 | 机器守护落地 | selftest 扩断言全绿 | bash selftest-session-log.sh | S5,S6 | complete |
| G4 | 回归部署收口 | 全量零回归+部署 diff=0+合并回 | run-verification+diff+git log | P4 | complete |

## 📊 FMEA 预演
| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作 |
|-------|---------|---|---|---|-----|-------------|
| Phase 3 | 95.4/102.0/86.1 原文锚定位偏差致改错段 | 6 | 4 | 3 | 72 | 实施前先 Read 原文核对锚点（S-unit 输入已含设计稿原文） |
| Phase 4 | selftest 新断言与既有断言冲突致误红 | 5 | 3 | 4 | 60 | master 基线对照判定预存 vs 新增；conflict→改断言措辞 |

## 🔁 模板感知
<!-- template_type: general -->
- 触发信号: 任务类型空缺 → 落 general 兜底
- Rule 34.3②: 沉淀预登记 —— 不沉淀（规则体系维护属一次性任务，非可复用模板画像）
- 处置登记处: 不沉淀理由如上
