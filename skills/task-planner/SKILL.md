---
name: task-planner
agent: executor
description: Use when planning, decomposing, or organizing multi-step projects or research tasks expected to require more than 5 tool calls. Also use when resuming work after /clear.
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TodoWrite, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, WebSearch, WebFetch"
user-invocable: true
references:
- reference.md: Manus 原则 + 3-Strike + 5Q + Chain Handoff Contract
- references/critical-rules.md: Critical Rules 核心域——Rules 1-117 全集索引（核心 20 条在位；其余 96 条归 12 卫星，见卫星路由表）
- examples.md: 完整执行示例（调研/bugfix/功能开发/错误恢复）
- references/completion-gate.md: 子代理验证指针（→verification-gate Rule 84.4）
- references/goal-gate.md: Goal Gate+VC 指针（→verification-gate Rule 84.3）
- references/todo-sync.md: 原生 Todo 同步契约（S1-S5）
- references/worktree-isolation.md: 工作树隔离+合并回合约
- references/methodology.md: 思维方法论 T1-T5 + Q3/Q4 + FMEA/Poka-Yoke
- references/longform-continuity-methodology.md: 长篇连续性方法论（按需加载）
- references/spec-mode.md: Spec 模式路由（Superpowers×OpenSpec）
- 卫星技能 task-dispatch: 派发/拆分/调度（`../task-dispatch/`，Rule 12,13,14,21,22,23,25,46,52,59,68,96,103,104）
- 卫星技能 task-discipline: 执行纪律/错误闭环/批量/反思（`../task-discipline/`，Rule 4,6,7,8,9,10,18,27-29,31-33,35,36,41-45,48,53-57,60,65,67,69-74,76,85-90,92-95,97-102,105-107,114）
- 卫星技能 media-planner: 媒体制作派发（`../media-planner/`，Rule 47,49,50）
- 卫星技能 verification-gate: 验证全链路（`../verification-gate/`，Rule 84）
- references/plan-workflow-details.md: 计划制作循环细节/命令速查/脚本索引（按需加载）
# hooks: <TOOL-ADAPTED — stub files per tool register hooks via platform-specific config>
# See: ~/.claude/skills/task-planner/SKILL.md (Claude Code) / ~/.zcode/skills/task-planner/SKILL.md (ZCode)
model: opus
---

**[P0]** 禁止跨项目污染 · 禁止虚构 · 修改前必须 Read 并展示 diff · 技能文件修改需逐项授权。发现缺失=STOP 报告，禁止补全。
**完成总结（S58）**：交付前输出四字段中文总结——已完成事项 / 产出文件清单 / 遗留问题 / 下一步建议（≥2 条）；字段名逐字使用，禁用「应该没问题/已成功」等模糊语。

**Goal**：产出结构化 `task_plan.md`（含 Phases/VC/V-N），按 phase 推进，全 phase complete 后逐条复验 VC，交付 COMPLETE/PARTIAL/BLOCKED。**每轮锚定（抗上下文稀释）**：每次回答前（含工具调用后的续答）先复述当前任务 Goal 与 Requirements 首条用户原话（≤2 行）再推进；上下文定位不到锚时先读 plan-state.json/恢复包再答，禁凭压缩摘要继续。

## 定位：核心 = planctl.py 驱动的四文件罗盘管理（task-v171 分层后）
<!-- 锚面保留：## 核心执行引擎（P0 — 四文件罗盘唯一写入口）（语义同本段 P0 定位，禁删改） -->

<!-- [2026-11-25 task-planctl-trigger-20261125] What: 定位段权重修复——原标题「核心 = 四文件罗盘管理」与下方分流铁律通篇未提 planctl.py，入口权重区把四文件呈现为可直接操作对象；实证 ~/.claude/opencode/cursor 三薄壳 planctl 提及=0、~/.zcode 段为场外手加（生成器源缺段，install 会回退丢失），端点执行期核心触发（planctl 唯一写通道）结构性不激活→直接手写派生视图（用户 2026-11-25 判例）。Why: 入口权重=激活链第一环，定位段不携带引擎表述则文末「结构化状态操作 SOP」硬规则埋底、下游门全部失效（本末倒置根治）。原行为: 定位段仅述四文件管理域与分流铁律，引擎表述仅存于文末 SOP 段。 -->
> **核心定位**：本技能 = **四文件罗盘的唯一管理域**，而罗盘的**唯一执行引擎与唯一写入口 = `scripts/planctl.py`**（P0：一切计划状态/语义变更必须经 `python3 <skill>/scripts/planctl.py <subcommand>` + `render`，`<plan-dir>/plan-state.json` = 唯一权威源；task_plan/findings/progress/verification 四个 MD 派生视图禁手工 Edit/Write（render 全量覆盖），罗盘四文件中的 knowledge-brief.md 为 render 链外专档（Rule 62 增量维护）——详见文末「结构化状态操作 SOP」；触发：需要确认 planctl 唯一写入口或四文件派生视图纪律时；关键词：planctl 权威源 派生视图 写入口）——`task_plan.md`（目标维：状态与指针）/ `findings.md`（决策维：调研结论与证据）/ `progress.md`（进度维：动作与测试）/ `knowledge-brief.md`（知识维：可复用知识底座）四文件 = 主代理↔子代理数据流转**唯一协议介质**（Rule 62.1）；`verification.md`（终验维）与 `user-session-log.md`（用户原话维，append-only 只写不改，Rule 80）同属记录文档域。子代理上下文=RAM，四文件=Disk。
> **非核心域已分层至卫星**：派发/拆分/调度→`task-dispatch`；执行纪律/错误闭环→`task-discipline`；媒体制作→`media-planner`；其余见文末「卫星路由表」。分层纪律=Rule 82（建制/边界/回归防线：禁回潮、禁镜像副本）。

**四文件写入分流铁律（写入动作本体 = planctl 子命令）**：状态与指针→`planctl set/add --section …`（→task_plan.md 派生视图；控制面板：只放目标/Phase 状态/VC/范围/一行摘要，Rule 19.6）；调研与结论→`planctl add --section findings`（→findings.md 派生视图）；动作与测试→`planctl add --section actions/errors`（→progress.md 派生视图）；可复用知识→knowledge-brief.md（render 链外专档，Rule 62 增量门控维护）。**「写到哪个文件」只决定选哪类子命令；写入动作本体永远是 planctl 子命令——task_plan/findings/progress/verification 四视图手工 Edit/Write=流程无效（render 全量覆盖）**。外部内容只进 findings.md（Rule 20.2）；结论禁只留会话记忆（Rule 19.1）。
**范围边界指针（2026-11-27 Rule 118）**：计划锁定时用 `planctl scope-set` 声明 `scope_boundary`（include/exclude/enabled）；执行期越界写由 `check-scope.sh` [scope-boundary] 拦截；扩张用 `planctl scope-extend --path ... --reason ...` 且须用户批准+Decisions 登记。

## 计划制作循环

> **[P0] 两段式修复拆分判定（D1' 分级全覆盖 + D5 阶段二启动，强制）**：实现/修复/优化请求先判定，**禁止跳过**。修复类=阶段一快修+根因线索包+阶段二底层根治；非修复类=阶段一尽早合并回 master 不阻塞下游+阶段二同族排雷（无风险 `N/A`+证据）。修复类命中 L0/mini/trivial/L0-E **一律先升 L1 standard 再走两段式**。双向 tag：`rootcause-followup:<B-id>` / `followup-of:<A-id>`；线索包经 `planctl add --section findings` 登记 `[rootcause-followup:PASS|N/A]`。D5：阶段一合并回 master 且 VC 复验通过后同轮起 `<A-id>-rc` worktree；失败仅登记 pending。→ 细则见 references/plan-workflow-details.md §计划制作循环（完整细节）。

- [ ] [M] **初始化（哨兵机制）— 机械子动作**：建目录/设 env/校验在位/清哨兵
  - `node --experimental-strip-types scripts/session-catchup.ts` 检测恢复点；`bash scripts/init-session.sh "<任务名>"` 建 `plans/{task-id}/`（**分级缺省=mini**；升档双判据 15min+步骤门 / 45min 硬兜底由 hook 自动升 standard；无 hook 位主进程三时机自查升档）。
  - 模板检索前置 / 脚本侧渲染（tplrender）/ auto-tier env 变量 → 见 references/plan-workflow-details.md §命令速查与脚本索引。
  - 会话隔离指针 `resolve-plan-dir.sh [root] [sid]`；压缩恢复 `[compact-recovery]` 注入技能全文+`planctl.py recover`；模板三层优先级（项目→用户→内置）；7 文件在位；S1 同步 `sync-todos.sh --json`；进度产出基线登记（Rule 111）；检索排除清单（Rule 112）；清除哨兵 `node scripts/plan-created.cjs`。
  → 初始化委派细则（按需加载）→ 详见 references/plan-workflow-details.md §init-delegation；触发：计划初始化需委派 plan-writer、收窄主代理职责或处理计划期单写者边界时；关键词：初始化 委派 plan-writer 收据 单写者

- [ ] [A] **初始化（哨兵机制）— 智能子动作**：体量分级判定与隔离决策
  - `bash scripts/check-conflicts.sh` → 隔离决策写入 task_plan「🔀 隔离决策」（实现类默认首选 worktree；默认不就安全默认发确认/询问）。→ 详见 references/plan-workflow-details.md §conflict-isolation-options。

- [ ] [A] **计划独立审计门（D1 前强制 — audit-before-delivery，Rule 109）**：L1+ 计划展示/授权前须经独立子代理审计迭代达标；mini/L0/trivial 按 38.7 比例豁免但交付型 MD/>2行/多文件仍 REQUIRED worktree；累计 2 轮 REJECTED 且无 APPROVED → [audit-cap] 刹车。
  → 详见 references/plan-workflow-details.md §audit-gate-details。

- [ ] [A] **计划确认**：展示 task_plan.md（Phase+VC）+绝对路径+待审项+看点+动作（Rule 70）；VC 每项须含可执行验证命令（Rule 84.1）；指令理解对齐（Rule 28.2.2，goal/28.8 优先覆盖禁止阻塞提问）；交互模式（Rule 28/28.8/28.9）；规则编号预留（Rule 20.6）；输出示例契约核对（Rule 113/113.10，先展示产出示例实物）。
  → 详见 references/plan-workflow-details.md §plan-confirm-alignment。

- [ ] [M] **Poka-Yoke 前置检查**（`references/methodology.md` §R1/R2）：依赖/上 Phase 产物/配置在位；高风险 Phase（RPN>100）登记兜底。

- [ ] [A] **思维方法论解构**（T1-T5）：问题先行三问+5 Whys+结论先行附推导链；方案终裁≥2 候选难决→`decision-arbiter`（Rule 69）。→ 详见 references/plan-workflow-details.md §methodology-t1-t5。
- [ ] [M] **共享内容追踪检查点（Rule 30）— 机械子动作**：命中则 `Skill("progress-tracker")` 建/用项目级账本，逐 target 认领登记+收尾 Todo；未命中→Decisions Made 记不适用。
- [ ] [A] **共享内容追踪检查点（Rule 30）— 智能子动作**：判定命中 30.1 条件。→ 详见 references/plan-workflow-details.md §shared-tracker-options。

- [ ] **Phase 执行循环（每 Phase 独立闭环）**
  1. [M] 开启 Phase：`planctl phase-start --id P<n>` 后 `render`；R 锚定复诵落盘 actions。
  2. [M] 同步 Todo（S2）：对应 todo→in_progress。
  2.5 [A] **委派检查点（Rule 25）**：Executor≠主进程→九字段模板逐 S-unit 派发；主进程只派发/回填/验收 Read。→ 使用点标注速查见 references/plan-workflow-details.md §execution-agent-quickref。
  2.5b [A] 技能激活确认+资料消费锚（knowledge_use）。 2.5c [A] 动作相关性三问。 2.5d [A] **变更类型判定（Rule 74 三判门，P0）**：增量默认/替代四条件/删除须授权，登记变更标注表。→ 详见 references/plan-workflow-details.md §change-type-compliance-gate。
  2.5e [M] **Agent 失败会话级留痕**：Agent() 返回失败即 `agent-failure-ledger.sh append ...`。→ 详见 references/plan-workflow-details.md §agent-failure-ledger-details。
  3. [M] 执行 Phase 工作（3-File 落盘 Rule 19）：3a 子代理产出回填+采集→消费闭环（research+knowledge_use）；3b 2-Action Rule；3c 动作留痕+Error Log 四步；3d hook 响应 `[plan-sync]/[plan-compass]`；3e 上下文卫生 Rule 29；3f 周期性三文件对照。→ 详见 references/plan-workflow-details.md §phase-context-recall。
  - **3h 双轮质检（Rule 103）**：子代理返回→核 checkpoint 自审段（103.2）→Read 产出（84.4）→派全新复检体（103.3，升档 103.4/简洁五要素 103.5）→复检回执落 checkpoint；多文件变更集附同步核对清单（103.6）。复检体全文回读被改文件并整体分析（103.3a）。
  - **3i 修改后复检（Rule 106）**：受管文档每次修改后回读校验跨字段不变量；同文件≥2次修改后全量回归（106.3）。
  4. [M] **回写计划**：Phase→complete；3-File 回填门控（19.2）`check-3file-gate.sh` exit 0；V-N 校验（84.3/84.4）；多文件变更集过 103.6 同步核对清单；Git 差异门。
  - **对齐必选步骤**：修改完成后强制对齐——执行对齐核查，关联面四族+部署位+引用面逐项核对零丢弃，机器门=check-complete.sh ALIGN-ANCHOR GATE（mini 豁免）。
  4.5 [M] **提交工作产物（Rule 27 / git-rework-guard）**：实现类 Phase 翻转前 commit 本 Phase 产物；返工第一动作=Git 找回；方向根本错误且阈值命中（96.7/103.8b）→§4.6 弃旧开新；检查点 `git-baseline.sh checkpoint`。
  5. [M] 同步 Todo+索引（S2/S4）：`sync-todos.sh --index`。
  6. [A] **[DRIFT CHECK]** 派发 `drift-checker` 偏移检查（Rule 61/64）；✅ALIGNED→继续；⚠️DRIFT→警觉继续；🔴BLOCKED→STOP。留痕三件套缺一=未执行。→ 详见 references/plan-workflow-details.md §drift-check-options。

- [ ] [A] **Code Review Gate**（仅 `code_review: required`）：轻 diff 单轮轻量审查，重 diff 全量多轮；APPROVED 才进终验；CHANGES_REQUESTED→追加 fix-phase。

- [ ] [M] **终验交付 — 机械子动作**：3-File Gate/GIT-BASELINE GATE；隔离任务合并回 `smart-merge-back.sh`；**防倒退终检（Rule 111/106.8）**净效果≥0；检索排除清单（Rule 112）；计划归档（Rule 81.1）`archive-plan.sh`。→ 详见 references/plan-workflow-details.md §final-verification-mechanical。
- [ ] [A] **终验交付 — 智能子动作**：**终验强制对齐**（ALIGN-ANCHOR GATE）；按 verification-gate 终验 SOP 复验 VC；**全文档收尾回读梳理（Rule 84.14，P0 迭代门）**（标准档六文档五维互洽，mini 两文档，收敛=连续一轮零新发现）；收尾对齐与清理（仅 Skill 说明 MD，代码注释保护）；双轮质检与同步完整性终验衔接（Rule 103）；质量门控统计（Rule 26）；委派率统计（Rule 25，L0-E 权重 0）；交付总结五要素；挂起计划回切检查。→ 详见 references/plan-workflow-details.md §final-verification-options。

### 📄 产出落盘映射（3-File Pattern）
> Context Window=RAM，Filesystem=Disk；恢复读序 task_plan→progress→findings→knowledge-brief。→ 详见 references/plan-workflow-details.md §output-mapping-table / §read-write-matrix。

### 合规检查清单（核心域，每 Phase 开始前逐项确认）
→ 详见 references/plan-workflow-details.md §compliance-table-a（G1-G12）。

> **mini 缺省档最小流程**：init=mini→免计划独立审计体/免双轮质检复检体/免 drift-checker/免归档；收尾回读两文档；基线 todo 裁 6 条；运行>15min+步骤门或>45min 硬兜底自动升 standard（hook 或主进程三时机自查）。冲突以各门脚本为准。

### 🔁 原生 Todo 同步（强制）
S1-S5 强制时机；计划文档=事实源，原生 Todo=执行视图。→ 详见 references/todo-sync.md。

### 🆕 用户新指令处理 / 🔀 工作树隔离
- 新指令统一收口序列：①逐字落盘 user-session-log.md+理解镜像 ②D/A/B/C/E 判定 ③指令理解迭代（goal/28.8 禁阻塞提问）④计划文档同步 ⑤Todo S5 重映射 ⑥Rule 103.6 衔接。→ 详见 references/plan-workflow-details.md §inbound-instruction-screen / §intent-switch-templates / §计划制作循环（完整细节）。
- 实现类任务首选 git worktree 隔离；交付型 MD/>2行/多文件=REQUIRED worktree。→ 详见 references/worktree-isolation.md。

## 投诉响应协议与 L0 边界审查（[task-perf-opt 2026-10-13 Change #10]）

  → 投诉响应协议 A 细则（按需加载）→ 详见 references/plan-workflow-details.md §complaint-protocol-a；触发：处理用户投诉、质量争议或需要投诉响应分流时；关键词：投诉响应 质量争议 分流 协议A
- **通道不可用快速失败（Rule 83）**：`/workflow` 请求先探测当前环境 Skill 工具面（`Skill(skill="dynamic-workflows")` 是否可用），缺失即登记环境缺口 + 给三选项（换环境 / Agent 替代授权 / 主进程直执行授权），禁 ≥2 次同法重试（videop1 D6 判例：CreateWorkflow 无 Skill 工具 3 次重试全拦）。
  → 投诉响应协议 B 细则（按需加载）→ 详见 references/plan-workflow-details.md §complaint-protocol-b；触发：投诉响应进入升级路径、需要通道不可用快速失败或 §六保护区约束时；关键词：投诉升级 通道失败 快速失败 协议B
- **§六 保护区约束**：本技能 SKILL.md 是技能文件，修改须走 §十一 worktree 铁律（git worktree add → 修改 → selftest → 合并回 master）；不修改 `~/.zcode/` 下的记忆文件（§六 保护区）。

## 卫星路由表（12 卫星 — 非核心域规则全文按需加载；触发：需要定位非核心域规则归属卫星或按需读取 critical-rules-*.md 时；关键词：卫星 路由 规则归属 critical-rules）

| 卫星 | 域 | 规则全文路径 | 调用条件 |
|------|----|------------|---------|
| task-dispatch | 子代理派发与拆分调度 | `../task-dispatch/references/critical-rules-dispatch.md` | 拆分/派发/并行/粒度校验/执行体选型/超时兜底/代码编辑隔离/使用点标注（Rule 12,13,14,21,22,23,25,46,52,59,68,96,103,104） |
| task-discipline | 执行纪律与工作产物维护 | `../task-discipline/references/critical-rules-discipline.md` | 执行纪律/错误闭环/证据/调研/批量/反思/注释/可靠性/能力沉淀/变更吸收/跨项目跨目录操作授权/临时目录统一与工作树内放/git 使用加强（Rule 4,6,7,8,9,10,18,27,28,29,31,32,33,35,36,41-45,48,53-57,60,65,67,69-74,76,85,86,87,88,89,90,92,93,94,95,97,98,99,100,101,102,105,106,107,114） |
| media-planner | 媒体制作任务派发 | `../media-planner/references/critical-rules-media.md` | 视频/图片/剧集创作媒体轴拆分与执行体路由（Rule 47,49,50） |
| plan-template-advisor | 项目模板适配与沉淀生产 | `../plan-template-advisor/SKILL.md` | 项目模板适配分析/沉淀评估/缺口映射（Rule 34.8/34.9 消费面） |
| plan-research-router | 调研分析与证据纪律 | `../plan-research-router/references/critical-rules-research.md` | 调研/分析/评估/归因证据面覆盖与反推诿（Rule 58,63,75） |
| plan-template-kit | 模板生命周期与难度分级 | `../plan-template-kit/references/critical-rules-template.md` | 模板选取/沉淀入库/难度分级/轻量档判定；选型三层（项目级→用户级→内置）+研究前置+用户明确审核授权后落盘，禁 silent 自动落盘（Rule 16,34,37,38） |
| plan-collab-router | 技能协同与工具面选择 | `../plan-collab-router/references/critical-rules-collab.md` | comet/OpenSpec/superpowers/dynamic-workflows 路由（Rule 39,40,91） |
| plan-cost-guard | 成本控制 | `../plan-cost-guard/references/critical-rules-cost.md` | opus 频次/嵌套成本/成本门控（Rule 17） |
| plan-resume | 计划续推 | `../plan-resume/references/critical-rules-resume.md` | 交付终态/会话恢复触发点扫描与自主续推（Rule 24） |
| progress-tracker | 共享内容认领 | `../progress-tracker/references/critical-rules-progress.md` | 跨任务共享内容认领追踪/进度复用（Rule 30） |
| task-drift-guard | 漂移检测与偏移留痕 | `../task-drift-guard/references/critical-rules-drift.md` | 漂移检测/偏移检查子代理化/周期回顾节奏（Rule 11,15,61,64） |
| verification-gate | 任务验证全链路 | `../verification-gate/references/critical-rules-verification.md` | VC 可执行化设计/执行期 V-N 校验/终验 VC 复验/子代理验证/统一验证入口（Rule 84,108） |

## Critical Rules 指针（核心域）
<!-- 纪元锚 1-117 宽容 -->
Rules 1-117 全集索引：**核心在位 20 条**（1,2,3,5,19,20,26,51,62,66,80,81,82,83,109,111,112,113,116,117）全文见 `references/critical-rules.md`（含分层架构说明+卫星路由索引）；其余 96 条已按域迁至上表 12 卫星（含 Rule 84 验证域、Rule 85/86/87/88/89/90/92/93/94/95/97/98/99/100/101/102 纪律域、Rule 103 双轮质检与同步完整性域、Rule 104 子代理使用点显式标注域（dispatch 卫星）、Rule 105 可枚举集合全量枚举优先纪律域、Rule 106 文档修改复检与 todo 驱动对齐纪律域、Rule 107 序列与长文连续性治理纪律域（项目级大纲/设定库/知识库/脑图+全局检索，均 task-discipline 卫星）、Rule 108 交叉验证纪律域（verification-gate 卫星）、Rule 109 独立审计门（audit-before-delivery，核心在位）、Rule 110 任务分级×模型档位强制匹配域（dispatch 卫星）、Rule 111 进度产出基线防倒退域（核心在位）、Rule 112 检索排除清单纪律域（核心在位）、Rule 113 输出示例契约域（核心在位）、Rule 114/115 纪律域）——**非核心域规则勿在本技能展开**（Rule 82 回归防线）。
  → 核心规则摘要 A 细则（按需加载）→ 详见 references/plan-workflow-details.md §critical-rules-summary-a；触发：需要快速回顾核心规则摘要或执行期规则速查时；关键词：核心规则 摘要 速查 Rule
- **Rule 26 质量优先于速度**：6 类降质行为可观察触发+确定性惩罚（回炉→PARTIAL→BLOCKED），伪造证据无豁免
- **Rule 51 需求覆盖与完成声称**：需求原文逐字锚+R→VC 映射；自缩水禁令；未测试禁声称完成；**可计数交付物全 R 化 + 禁「0 产出」为 covered 判据 + 留口须逐字让步锚（51.9-51.12）**；完成声称须按 51.14 操作类型档位 L1-L4 + 覆盖实数 + 实测耗时（并发度 K 写明依据）自证，措辞不得高于实际档位（task-drift-fakeqc-20261115 判例锚）。
- **Rule 62 四文件罗盘数据流转**：派发读写契约不可收窄+调研双落盘+kb 增量门控
- **Rule 66 goal 单元固化**：Goal 单元表六列契约+逐 goal 验证通过门+按 goal 逐个推进
- **Rule 80 用户会话逐字记录**：user-session-log.md append-only 只写不改；恢复先读专档；每条逐字后同号配对理解镜像（80.7，非权威对照面）；决策前读取纪律（80.8 五决策点：上抛裁决前/新指令反思门/完成声称与交付双锚/子代理派发双锚/周期对照——先读专档再决策）
- **Rule 81 计划完成后归档（task-v170）**：check-complete exit 0 后必须运行 `bash scripts/archive-plan.sh <task-id>` 完成任务归档（81.1 触发点，终验交付段承载）；命令形态=`git mv` 移入 `plans/archive/`、目标已存在报 ALREADY_ARCHIVED 放行（81.2 幂等）；守卫三拒绝 fail-closed=active 指针 / .session-owner 活跃(mtime<24h) / task_plan.md Status 未全 complete（81.3）；联动=归档后重跑 `sync-todos.sh --index` 保索引一致性（81.4）；存量批量按 Rule 18 批门四步走 `--batch` 先 dry-run 再实做（81.5）；Why：「在途在根、历史在 archive/」维持 plans/ 健康形态防堆积索引失真（详见 references/critical-rules.md Rule 81）；触发：终验后归档计划、处理 archive-plan 守卫拒绝或批量归档存量计划时；关键词：归档 Rule81 archive-plan 守卫 索引
- **Rule 82 技能专业化分层纪律**：核心只管四文件罗盘域；删留原子配对；禁回潮禁镜像

## Completion Gate
详见卫星 `verification-gate` Rule 84.4：subagent 返回 "done" 后必须 Read 实际文件验证变更才可标记 complete。

## Scope Guard / Goal Gate
- **Scope Guard**：`check-scope.sh Write "<file>" task_plan.md`（exit 0/1/2）。scope_files 约束不由运行时停摆门承载（P7 口径）：实际由派发范围声明/收口审计/git 越界自检承载，越界合法出口=Rule 74 变更标注。
- **Goal Gate**：task_plan.md 必须含 VC 表，每项含可执行验证命令（Rule 84.1）；详见 verification-gate Rule 84.3。

## I/O 契约
输入=任务描述/CWD/已有 plan；输出=规划→理解迭代草稿+plan+思路复述/执行→checkbox+错误/完成→全部[x]+验证。失败阈值见 `config.json#escalation_threshold`。示例：`mkdir -p plans/task-001/ && cd $_ && bash <skill>/scripts/init-session.sh "<任务名>"`。

## Chain 模式与协同路由（指针）
`chain_mode` 默认 `single`；`linked`/`fan-out` 语义见 `reference.md § Chain Handoff Contract`。协同路由权威源=`plan-collab-router/references/skill-collaboration.md`；调研 SOP=plan-research-router；模板库=plan-template-kit。Spec 模式路由见 `references/spec-mode.md`。

## 派发与执行纪律指针（卫星 authoritative）
- 派发/路由/兜底/代码编辑隔离 → `task-dispatch`；执行纪律/错误闭环/批量门控 → `task-discipline`；媒体制作 → `media-planner`。
- 主进程铁律：任务执行一律 `Agent()` 派发（白名单外 Write/Edit 被 `check-delegation.sh` 拦截）；bypass 仅 `allow-direct.sh on --confirm-user-requested`；白名单见 task-dispatch Rule 25.3。
- 子代理激活默认档/并行硬标注/同消息并发 → task-dispatch Rule 96。声明源通用消费（Rule 115）→ research-channels。

## 结构化状态操作 SOP（JSON 权威源）

> [2026-11-21 task-json-state-20261121] 结构化状态升级硬条款；适用于所有使用 task-planner 的计划目录。

- **权威源声明**：`<plan-dir>/plan-state.json` 是任务状态**唯一权威源**（Phase/VC/审计/派发+全部语义段，含 template_doc/template_checks）；`task_plan.md`/`progress.md`/`verification.md`/`findings.md` 由 `planctl.py render` 从 JSON **全量派生**的只读视图。
- **硬规则（违反=流程无效）**：一切状态/语义变更必须经 `python3 <skill>/scripts/planctl.py <subcommand>`；**四个 MD 视图禁手工 Edit/Write**（render 全量覆盖，软堵）。`knowledge-brief.md` 为 render 链外专档（Rule 62）。
- 完整命令速查与脚本索引 → references/plan-workflow-details.md §命令速查与脚本索引。
- **安全说明**：每次写操作自动备份权威源到 `<plan-dir>/.history/`（保留最近 20 版），改坏可 `restore`；禁止手工删除/改写 `.history/`。
- **机器门**：`python3 scripts/planctl.py check vc-nonvacuous|rvc|audit|evidence` 输出单行 `PLANCTL CHECK <name>: PASS|FAIL <reason>`，rc 0=PASS / 1=FAIL / 2=输入异常。
- **输出示例生成器（Rule 113.9）**：`python3 scripts/render-output-example.py --set ... --example-file <f> --template-file <f> --vc-ref VC-1 --out oe-1.json [--plan-dir <d>]`；产物经 `planctl add --section output_examples --json` 落库并 render 派生。
- **迁移期**：存量无 `plan-state.json` 旧计划一次性兼容（机器门双读 fallback）；**新计划一律 JSON 权威源**，init 只建权威源不 render，首次数据写入后必须 `render`。
  → planctl 四件套与备份恢复细则（按需加载）→ 详见 references/plan-workflow-details.md §planctl-four-piece；触发：需要 planctl init/render/backup/restore 全流程或迁移期说明时；关键词：planctl 四件套 render backup restore
  → 脚本索引细则（按需加载）→ 详见 references/plan-workflow-details.md §script-index；触发：查找 task-planner scripts/ 下某脚本用途、入口参数或调用时机时；关键词：脚本索引 scripts 用途 参数

## References

| 文档 | 用途 |
|------|------|
  → 完整参考文档表见 references/plan-workflow-details.md §references-table。
