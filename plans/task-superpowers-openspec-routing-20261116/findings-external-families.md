# task-planner × superpowers/OpenSpec/comet 外部技能族集成现状与路由调研

> 只读调研结论；每条结论带 `文件:行号` 证据锚。读不到/不存在处均标「未找到」。

## A. 仓内集成现状（task-planner 主仓）

**调研范围与命令**：在 `/mnt/data/dev/task-planner-skill` 执行  
`grep -rniE 'superpowers|openspec|comet|brainstorming|writing-plans|executing-plans|subagent-driven|spec-driven' --include='*.md' skills/ docs/ *.md 2>/dev/null`

### A1. grep 命中逐条判定（文件:行号 + 语境）

| 命中 | 语境判定 |
|---|---|
| `CHANGELOG.md:16` `- **Spec 模式路由（Superpowers × OpenSpec 显性集成）** — 2026-11-15...` | **真路由/集成记录**：记录已新增 spec-mode 路由与 SKILL/spec-mode 变更。 |
| `CHANGELOG.md:117-120` 提及 openspec/spec-kit 扫描与 extract-meta（`openspec/changes/*/tasks.md`、`spec-kit` 后端等） | **真功能条款（plan-resume 扩展）**：面向计划续推对 openspec/spec-kit 格式的识别，非 task-planner 执行路由。 |
| `CHANGELOG.md:123` smoke 测试断言提及 `openspec/spec-kit` | **仅测试/历史语境提及**。 |
| `skills/plan-collab-router/SKILL.md:3,8,15,19-21,25,36,40,44` | **真路由条款/知识库入口**：定义 comet/OpenSpec/superpowers 三族画像、判定顺序、22.3.3 接管档位、显式 `Skill("plan-collab-router")` 调用入口与权威源指针。 |
| `skills/plan-collab-router/references/skill-collaboration.md:1,3,15-49,53-82,108,113` | **真路由条款（权威源正文）**：三族能力画像、触发矩阵 D1、移交/嵌入语义、22.3.3 全序/接管快照、CLI 探针前置、反模式等。 |
| `skills/plan-cost-guard/SKILL.md:20`；`skills/plan-cost-guard/references/cost_log.md:24`；`skills/plan-cost-guard/references/cost-control.md:16-18,29,132-134`；`skills/plan-cost-guard/references/billing.md:13`；`skills/plan-cost-guard/references/critical-rules-cost.md:9` | **真约束条款（成本侧）**：将 brainstorming/writing-plans/comet-* 等列为 opus 档 Skill 并施加同 phase 节流/计费规则；非执行路由但与协同调用成本强相关。 |
| `skills/plan-resume/references/critical-rules-resume.md:12` 扫描 `openspec/changes/*/tasks.md` + `specs/*/tasks.md` | **真功能条款（续推扫描源）**：识别 openspec/spec-kit 格式计划，不等于 task-planner 执行期路由到 openspec 技能。 |
| `skills/task-discipline/references/critical-rules-discipline.md:156` “CR 触发制（... comet review_mode 移植）” | **仅提及/借鉴来源**：质量门控机制来源提及，非 comet 路由。 |
| `skills/task-dispatch/references/critical-rules-dispatch.md:57,153,159` | **真路由/执行条款引用**：22.3.3 技能族接管评估指向 comet/openspec-propose/superpowers；并要求计划期技能扫描与“comet/superpowers/brainstorming 闲置”可见性治理。 |
| `skills/task-dispatch/references/split-pattern-library.md:13,14,16,27,35,43,51,91,99,124,126,127,136` | **引用/消费关系**：将 writing-plans/brainstorming/subagent-driven-development 作为拆分/计划/管线设计参考与消费来源（含路径指针）；非 task-planner 内置路由表，但承认 superpowers 成员能力。 |
| `skills/task-drift-guard/SKILL.md:34` “comet change 活跃 \| 读 `.comet.yaml`…” | **真条件检测条款**：漂移检查可感知 comet 活跃 change，属于与 comet 状态的协同感知。 |
| `skills/task-planner/README.md:75`；`skills/task-planner/docs/ARCHITECTURE.md:108` | **真路由索引/文档指针**：卫星 plan-collab-router 覆盖 comet/OpenSpec/superpowers/dynamic-workflows。 |
| `skills/task-planner/SKILL.md:16,65,228,265,266,296` | **真路由条款与指针（核心）**：引用 spec-mode；初始化独立检查项做 Spec 模式触发并路由 brainstorming/openspec-propose；卫星路由表纳入 plan-collab-router；Chain/协同路由权威源指向 `skill-collaboration.md`；显式 Spec 模式路由行。 |
| `skills/task-planner/references/spec-mode.md:1,4,12-16,21-23,28,37` | **真路由条款（Spec 模式）**：Superpowers×OpenSpec 触发/调用形态/记录者职责/安装引导/反模式/产物路径约束。 |
| `skills/task-planner/templates/knowledge-brief.md:70,71,76,77` | **真执行前提示条款**：要求扫描匹配 comet/superpowers/brainstorming 等强化技能入 brief，并区分用户触发型（comet 族）仅提示不代激活。 |
| `skills/todo-skill/WORKFLOW.md:55,61` | **仅提及/外部能力清单**：列出 brainstorming/comet-any 可用性提示，非 task-planner 路由实现。 |

**结论（A 总）**：仓内已存在对 comet/OpenSpec/superpowers 的**显性路由与协同知识层集成**（核心在 `skills/task-planner/SKILL.md:65,228,265,266`、`skills/task-planner/references/spec-mode.md:*`、`skills/plan-collab-router/*`）；同时有续推格式识别（openspec/spec-kit）与成本/漂移等周边协同，但**task-planner 自身未内嵌 comet/openSpec/superpowers 的执行引擎实现**，主要通过条款、卫星文档与 `Skill(...)`/外部技能调用约定接线（`skills/task-planner/SKILL.md:266`，`skills/plan-collab-router/SKILL.md:3,35`）。

### A2. 现有「任务→技能/agent→模型档」路由架构概述（≤15 行）

1. **任务入口/规划骨架**：`task-planner` 负责四文件罗盘与计划循环，初始化含体量分级、Spec 模式触发判定、计划确认/D1、Phase 执行循环与终验（`skills/task-planner/SKILL.md:30-33,37-39,60-71,91-144`）。
2. **专业协同路由（技能族层）**：通过卫星 `plan-collab-router` + 权威源 `skill-collaboration.md` 做 comet/OpenSpec/superpowers 触发矩阵、移交/嵌入与 22.3.3 接管评估（`skills/task-planner/SKILL.md:228,265`；`skills/plan-collab-router/SKILL.md:17-25`；`skills/plan-collab-router/references/skill-collaboration.md:51-82`）。
3. **Spec 模式细化路由**：L1+ 且需求模糊/多方向/规格类时，整理阶段路由 brainstorming / openspec-propose(/explore/apply/verify/writing-plans 协同)，planner 只记录产物收据与调度（`skills/task-planner/SKILL.md:65,71,266`；`skills/task-planner/references/spec-mode.md:6-16,31-32`）。
4. **子代理/执行体选型层（独立于技能族）**：派发、执行体覆盖、使用点标注、兜底链等归 `task-dispatch` 卫星与其 references（`skills/task-planner/SKILL.md:222,268-274`）；全局 Agent 选择有独立 `skill-agent-router`（仓内路径 `skills/skill-agent-router/SKILL.md` **未找到**；全局存在 `/home/terry/.zcode/skills/skill-agent-router/SKILL.md:1-25,39-120`，定义 Agent() 前查表、二次降级链与路由决策流程）。
5. **模型/成本档位**：模型分档由 skill frontmatter/卫星纪律体现；成本卫星对 opus 档 Skill（含 brainstorming/writing-plans/comet-*）做节流计费约束（`skills/task-planner/SKILL.md:23`；`skills/plan-cost-guard/references/cost-control.md:16-18,29,132-134`）。
6. **决策载体形态**：主技能 SKILL.md 保留触发点与指针；详细矩阵/合约在 `references/spec-mode.md`、`../plan-collab-router/references/skill-collaboration.md` 等卫星/引用文档（`skills/task-planner/SKILL.md:16,265-266,296`）。

## B. comet 机制（`/home/terry/.zcode/skills/comet*`）

### B1. 入口与变体清单（证据摘录）

- **入口路由器 `comet`**：`/comet` 仅选择入口；必须执行 `comet workflow resolve . --activate --json`，按返回 `skill` 仅加载 `comet-native` 或 `comet-classic`，并将用户原始请求完整交给已选入口；禁止按任务大小/文件数/活跃 change 改选（`/home/terry/.zcode/skills/comet/SKILL.md:2-4,7-31`）。
- **变体/成员（目录与技能）**：存在 `comet`, `comet-any`, `comet-archive`, `comet-build`, `comet-classic`, `comet-design`, `comet-hotfix`, `comet-memory`, `comet-native`, `comet-open`, `comet-review`, `comet-tweak`, `comet-verify`（`ls -d /home/terry/.zcode/skills/comet*` 实测结果；并被 `skills/plan-collab-router/references/skill-collaboration.md:15,23` 总结为 13 成员）。
- **`comet-any`**：Skill 创建向导，创建/升级 Comet Classic workflow Skill；`disable-model-invocation: true`（`/home/terry/.zcode/skills/comet-any/SKILL.md:1-18,44-55`）。

### B2. 任务画像判定维度与选择/关键词规则（原文要点）

`comet-classic` 在 Step 0 通过 `CometIntentFrame` + `comet classic intent route --stdin` 做 runtime 路由，槽位/信号维度与规则要点（`/home/terry/.zcode/skills/comet-classic/SKILL.md:32-44,78-101,109-127,166-168`）：

| 画像/槽位维度 | 规则要点（摘录/归纳） |
|---|---|
| 意图与槽位 | `intent.name/confidence`、`slots.requested_action/workflow_candidate/user_explicit_workflow/change_id/existing_behavior/new_capability/public_api_change/schema_change/cross_module_change`、`context.active_changes_count/names`、`evidence`、`proposed_route`（最小骨架示例）。 |
| 热修复倾向 | `fix_bug` + `existing_behavior: true` 且无新增 capability/public API/schema/cross-module 信号 → 倾向 `hotfix`。 |
| 轻改倾向 | 可收敛为单一 OpenSpec change 的轻量/中等变更（含文案/配置/文档/prompt/单一 change 轻中量修改），需 OpenSpec apply 且不需完整 `/comet-classic` 深度设计/plan → 倾向 `tweak`。 |
| 完整流程倾向 | 新增 capability、public API、schema 变更、跨模块协调或架构调整 → 倾向 `full`。 |
| 交互/歧义 | 多个 active change 且未明确 change → `ask_user`；置信度不足、关键 evidence 缺失或用户显式 workflow 与风险信号冲突 → `ask_user`。 |
| 非范围 | `out_of_scope` → 非 Comet workflow 启动/恢复请求，不初始化 change。 |
| 运行时分流输出 | `hotfix→/comet-hotfix`，`tweak→/comet-tweak`，`full→/comet-open 或用户确认`，`resume→读 .comet.yaml`，`ask_user→暂停等待选择`。 |

补充画像/约束：`hotfix` 适用“修已有 bug、不新增 capability、不涉接口/架构变更、范围可预估”；质变信号/文件数 tripwire 触发用户二选一升级（`/home/terry/.zcode/skills/comet-hotfix/SKILL.md:13-18,149-177`）。`tweak` 适用“单一 OpenSpec change、不需 Superpowers Design Doc/完整 plan、不涉跨模块架构协调、规模可预估”，delta spec 正常产物（`/home/terry/.zcode/skills/comet-tweak/SKILL.md:15-21,123-129`）。

### B3. 路由输出形态

- `comet`：**间接委派**——CLI resolve 输出 JSON 后加载唯一入口 skill（`comet-native`/`comet-classic`），再转交原始请求（`/home/terry/.zcode/skills/comet/SKILL.md:13-25`）。
- `comet-classic`：**运行时 route 驱动的阶段/预设分流**——调用 `/comet-hotfix`/`/comet-tweak` 或进入 `/comet-open`/resume/ask_user 决策点；阶段流转 open→design→build→verify→archive，含多处用户阻塞决策节点（`/home/terry/.zcode/skills/comet-classic/SKILL.md:38-44,111-127,178-211`）。
- 非“关键词静态表直接 `Skill()` 调用变体”的单层形态；而是 **CLI + IntentFrame/runtime scorer + 状态文件/决策点** 的工作流引擎式路由（`/home/terry/.zcode/skills/comet-classic/SKILL.md:34-38,58-76`）。

## C. superpowers 族

### C1. 成员可见性与 frontmatter description（一句话能力）

同族技能检索（按要求清单）：

| 技能 | 位置（存在性） | frontmatter description（摘录） |
|---|---|---|
| `using-superpowers` | `~/.zcode/skills/using-superpowers/SKILL.md`、`~/.agents/skills/using-superpowers/SKILL.md` 均存在 | “Use when starting any conversation - establishes how to find and use skills, requiring skill invocation before ANY response including clarifying questions”（`/home/terry/.zcode/skills/using-superpowers/SKILL.md:1-4`） |
| `brainstorming` | `~/.zcode/skills/`、`~/.agents/skills/` 均存在 | “You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation.”（frontmatter 摘录，命令输出） |
| `writing-plans` | `~/.zcode/skills/`、`~/.agents/skills/` 均存在 | “Use when you have a spec or requirements for a multi-step task, before touching code”（frontmatter 摘录） |
| `executing-plans` | `~/.agents/skills/executing-plans/SKILL.md` 存在；`~/.zcode/skills/` **未找到同名** | “Use when you have a written implementation plan to execute in a separate session with review checkpoints”（frontmatter 摘录） |
| `test-driven-development` | `~/.agents/skills/test-driven-development/SKILL.md` 存在；`~/.zcode/skills/` **未找到** | “Use when implementing any feature or bugfix, before writing implementation code”（frontmatter 摘录） |
| `systematic-debugging` | `~/.agents/skills/systematic-debugging/SKILL.md` 存在；`~/.zcode/skills/` **未找到** | “Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes”（frontmatter 摘录） |
| `subagent-driven-development` | `~/.agents/skills/subagent-driven-development/SKILL.md` 存在；`~/.zcode/skills/` **未找到** | “Use when executing implementation plans with independent tasks in the current session”（frontmatter 摘录） |
| `requesting-code-review` | `~/.agents/skills/requesting-code-review/SKILL.md` 存在；`~/.zcode/skills/` **未找到** | “Use when completing tasks, implementing major features, or before merging to verify work meets requirements”（frontmatter 摘录） |
| `receiving-code-review` | `~/.agents/skills/receiving-code-review/SKILL.md` 存在；`~/.zcode/skills/` **未找到** | “Use when receiving code review feedback, before implementing suggestions, especially if feedback seems unclear or technically questionable - requires technical rigor and verification, not performative agreement or blind implementation”（frontmatter 摘录） |
| `using-git-worktrees` | `~/.agents/skills/`、`~/.zcode/skills/` 均存在 | “Use when starting feature work that needs isolation from current workspace or before executing implementation plans - ensures an isolated workspace exists via native tools or git worktree fallback”（frontmatter 摘录） |
| `verification-before-completion` | `~/.agents/skills/`、`~/.zcode/skills/` 均存在 | “Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always”（frontmatter 摘录） |
| `finishing-a-development-branch` | `~/.agents/skills/finishing-a-development-branch/SKILL.md` 存在；`~/.zcode/skills/` **未找到** | “Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup”（frontmatter 摘录） |
| `dispatching-parallel-agents` | `~/.agents/skills/dispatching-parallel-agents/SKILL.md` 存在；`~/.zcode/skills/` **未找到** | “Use when facing 2+ independent tasks that can be worked on without shared state or sequential dependencies”（frontmatter 摘录） |

### C2. `using-superpowers` 入口判定/路由逻辑

- 子代理豁免：若作为子代理执行特定任务则忽略本技能（`/home/terry/.zcode/skills/using-superpowers/SKILL.md:6-8`）。
- 强制前置：认为 1% 可能适用即必须在任何响应/行动前调用相关 skill（含澄清、探索、查文件）；“IF A SKILL APPLIES... YOU MUST USE IT”（`/home/terry/.zcode/skills/using-superpowers/SKILL.md:10-16,18-24`）。
- 计划模式前：未 brainstorm 则先调用 brainstorming（`/home/terry/.zcode/skills/using-superpowers/SKILL.md:22-23`）。
- 技能优先级：process skills 优先于 implementation skills；示例“build X → brainstorming first”“fix bug → systematic-debugging first”（`/home/terry/.zcode/skills/using-superpowers/SKILL.md:26-31`）。
- 反合理化清单与平台适配引用（`/home/terry/.zcode/skills/using-superpowers/SKILL.md:33-58`）；用户指令优先级声明（`/home/terry/.zcode/skills/using-superpowers/SKILL.md:60-62`）。

## D. openspec 族

### D1. 族成员与入口

- 目录列举：`openspec-apply-change`, `openspec-archive-change`, `openspec-bulk-archive-change`, `openspec-continue-change`, `openspec-explore`, `openspec-ff-change`, `openspec-new-change`, `openspec-onboard`, `openspec-propose`, `openspec-sync-specs`, `openspec-verify-change`（`ls -d /home/terry/.zcode/skills/openspec-*`）。
- 入口/引导技能：`openspec-onboard`（教学式完整周期引导，需 `openspec` CLI；前置检查 `openspec --version`）（`/home/terry/.zcode/skills/openspec-onboard/SKILL.md:1-34`）。
- 快速提案入口：`openspec-propose` 一步生成 proposal/design/tasks，完成后建议 `/opsx:apply`（`/home/terry/.zcode/skills/openspec-propose/SKILL.md:1-22,84-133`）。
- 分步起点：`openspec-new-change` 创建 change scaffold + 展示 artifact 状态与首 artifact 指令后停止等待（`/home/terry/.zcode/skills/openspec-new-change/SKILL.md:1-12,31-71`）。

### D2. 解决的问题、典型工作流链、前置要求

| 维度 | 结论 | 证据 |
|---|---|---|
| 解决问题 | 以 artifact/变更为中心的结构化需求澄清、提案、设计、任务与实现/验证/归档生命周期（spec/change 驱动协作）。 | `/home/terry/.zcode/skills/openspec-propose/SKILL.md:14-21`；`/home/terry/.zcode/skills/openspec-new-change/SKILL.md:14-15,45-65`；`/home/terry/.zcode/skills/openspec-onboard/SKILL.md:38-56`（onboard 展示 idea→change→proposal/specs/design/tasks→implement→archive） |
| 典型工作流链 | 可见链路形态：`new/propose` 建 change 与 artifacts →（按 schema）补齐 proposal/specs/design/tasks → `apply` 实施 → `verify` 验证 → `archive` 归档；另有 `explore/continue/ff/sync-specs/bulk-archive` 辅助。 | `/home/terry/.zcode/skills/openspec-propose/SKILL.md:16-21,45-107`；`/home/terry/.zcode/skills/openspec-new-change/SKILL.md:45-65`；`/home/terry/.zcode/skills/openspec-apply-change/SKILL.md:27-55`（status/instructions apply/blocked|all_done 分支）；`/home/terry/.zcode/skills/openspec-onboard/SKILL.md:47-56` |
| 前置要求 | 需要 `openspec` CLI（frontmatter `compatibility: Requires openspec CLI.`，多技能 `allowed-tools: Bash(openspec:*)`）；onboard 明确安装检查。路径/目录由 CLI 解析（`planningHome/changeRoot/artifactPaths/actionContext/resolvedOutputPath`），可配合 store/root，不应硬编码固定物理路径。 | `/home/terry/.zcode/skills/openspec-onboard/SKILL.md:5-6,20-34`；`/home/terry/.zcode/skills/openspec-propose/SKILL.md:4-6,25,42-56`；`/home/terry/.zcode/skills/openspec-new-change/SKILL.md:4-6,31-44`；`/home/terry/.zcode/skills/openspec-apply-change/SKILL.md:4-6,27-41` |

## E. 竞合/重叠分析（superpowers writing-plans/executing-plans/TDD vs task-planner）

| # | 重叠/冲突点 | superpowers 侧出处 | task-planner 侧出处 |
|---|---|---|---|
| 1 | **实施计划产物与计划权威**：writing-plans 生成多步实现计划；task-planner 也产出 `task_plan.md`（Phase/VC）并在 Spec 模式下可路由/对接外部计划产物。易出现“双计划、双真源”。 | `writing-plans`：`/home/terry/.agents/skills/writing-plans/SKILL.md:3`（“Use when you have a spec or requirements for a multi-step task, before touching code”） | `skills/task-planner/SKILL.md:28,37,67-71`（Goal/plan 产出与展示确认）；`skills/task-planner/references/spec-mode.md:12,16`（brainstorming→writing-plans 终态；planner 记录产物路径收据、不重写计划内容） |
| 2 | **执行驱动模型**：executing-plans 按书面计划在独立会话带审查检查点执行；task-planner 有自身 Phase 执行循环、S-unit 派发、委派率/门控。并行采用可能造成控制权分裂。 | `executing-plans`：`/home/terry/.agents/skills/executing-plans/SKILL.md:4`（“execute in a separate session with review checkpoints”） | `skills/task-planner/SKILL.md:91-128,142,268-274`（Phase 循环、委派检查点、双轮质检、委派率统计）；`skills/plan-collab-router/references/skill-collaboration.md:59`（superpowers 嵌入为主） |
| 3 | **TDD/验证先后与完成声称**：TDD 要求实现前先测；verification-before-completion 要求证据先于完成声明；task-planner 也有 VC/V-N、终验与 verification-gate。流程可互补但易重复门控。 | `test-driven-development`：`/home/terry/.agents/skills/test-driven-development/SKILL.md:3`；`verification-before-completion`：`/home/terry/.agents/skills/verification-before-completion/SKILL.md:3` | `skills/task-planner/SKILL.md:68,119,129,138-143,233`（VC 可执行化、V-N 校验、终验 SOP/统一入口）；`skills/task-planner/SKILL.md:252-253`（Completion Gate 指针） |
| 4 | **调试/纠错归因**：systematic-debugging 强调根因优先；task-planner 有错误闭环、规则召回、漂移检查与 task-discipline 卫星。重叠在“先定位后修复”但触发面与留痕载体不同。 | `systematic-debugging`：`/home/terry/.agents/skills/systematic-debugging/SKILL.md:3`；`using-superpowers` 建议 bug→systematic-debugging：`/home/terry/.zcode/skills/using-superpowers/SKILL.md:31` | `skills/task-planner/SKILL.md:113,122,223`（错误四步/漂移检查/执行纪律卫星）；`skills/plan-collab-router/references/skill-collaboration.md:59,72`（superpowers 嵌入与 22.3.3 单点能力接管） |
| 5 | **子代理协作与并行执行**：subagent-driven-development/dispatching-parallel-agents 提供会话内并行/子代理执行手法；task-planner 体系通过 task-dispatch 强制派发契约、并行组与模型/成本纪律。易在“谁编排、谁派发”上冲突。 | `subagent-driven-development`：`/home/terry/.agents/skills/subagent-driven-development/SKILL.md:3`；`dispatching-parallel-agents`：`/home/terry/.agents/skills/dispatching-parallel-agents/SKILL.md:3` | `skills/task-planner/SKILL.md:94-101,222,270,274`（委派检查点、使用点标注、task-dispatch 指针与并行约束）；`skills/task-dispatch/references/split-pattern-library.md:99,127`（消费 subagent-driven-development 模式） |
| 6 | **Spec/设计前置与 brainstorming 触发**：using-superpowers 要求可能适用即先调 skill 且计划模式前先 brainstorming；task-planner 已在 Spec 模式将 brainstorming/openspec-propose 显性路由并强调记录者角色。若不明确优先级会重复触发或角色越界。 | `using-superpowers`：`/home/terry/.zcode/skills/using-superpowers/SKILL.md:10-24,30`；`brainstorming` frontmatter：`/home/terry/.zcode/skills/brainstorming/SKILL.md`（“before any creative work...”） | `skills/task-planner/SKILL.md:65,266`；`skills/task-planner/references/spec-mode.md:1,3,12,28-32`（调用不复制、planner 不自拟规格/头脑风暴替代） |

## F. 最小引入难度路由设计建议（仅建议，不写实现）

| # | 建议（挂载点/形态） | 理由（最小改动） | 关联证据 |
|---|---|---|---|
| 1 | **保持“调用不复制”，优先在 `references/spec-mode.md` + `plan-collab-router/references/skill-collaboration.md` 做纯条款扩展**（必要时仅补 SKILL.md 指针行） | 现有已形成“主 SKILL 触发点+卫星权威源”分层，扩展画像/信号只增文档条款与证据引用，不引入新执行脚本（最小风险）。 | `skills/task-planner/SKILL.md:16,228,265-266,296`；`skills/task-planner/references/spec-mode.md:4,33-37`；`skills/plan-collab-router/SKILL.md:8,31` |
| 2 | **在 `plan-collab-router/references/skill-collaboration.md` 增补“画像→候选变体”轻量决策表（内联表），不复制 comet CLI/runtime 逻辑** | comet 已有 IntentFrame/runtime scorer 与强状态机；task-planner 侧仅需“何时建议 handoff/embed 到 comet-classic/hotfix/tweak/openspec-propose/brainstorming”的提示表，避免重复引擎。 | `/home/terry/.zcode/skills/comet/SKILL.md:13-31`；`/home/terry/.zcode/skills/comet-classic/SKILL.md:32-44,78-127`；`skills/plan-collab-router/references/skill-collaboration.md:51-68` |
| 3 | **复用 `knowledge-brief.md` 的“可用强化技能扫描”作为画像匹配输出面（纯模板/条款强化）** | 已有扫描入 brief 与用户触发型限制机制，可把 comet/superpowers/openspec 候选、激活方式与前置条件（CLI/目录）显式化，接近 comet 变体选择的“可见化”但无新工具链。 | `skills/task-planner/templates/knowledge-brief.md:70-77`；`skills/task-planner/SKILL.md:102-103`；`skills/plan-collab-router/references/skill-collaboration.md:57-62,108,113` |
| 4 | **将 comet 变体选择定位为“建议性 handoff 画像”而非 task-planner 内自动路由到具体子变体**（除已存在的明确 Skill 调用场景） | comet 入口/经典流依赖 CLI、`.comet.yaml`、大量用户决策点；task-planner 只做复杂度/画像命中后建议 `Skill("comet")` 或 `Skill("plan-collab-router")` 评估，可最小化与其状态机冲突。 | `/home/terry/.zcode/skills/comet/SKILL.md:11-31`；`/home/terry/.zcode/skills/comet-classic/SKILL.md:178-211`；`skills/plan-collab-router/references/skill-collaboration.md:64-68,70-82` |
| 5 | **对 OpenSpec/superpowers 采用“触发信号→embed/handoff 合约”统一在 skill-collaboration/spec-mode 声明，避免在 task-dispatch/plan 模板重复规则副本** | 当前已出现 spec-mode 与 collab-router 双处路由语义并存；最小引入应统一权威源引用与边界（planner 记录者、外部执行体自管产物），减少漂移。 | `skills/task-planner/references/spec-mode.md:12-16,33-37`；`skills/plan-collab-router/references/skill-collaboration.md:3-9,51-68`；`skills/task-planner/SKILL.md:265-266` |

---
**实际读取文件清单（本次调研）**
- 仓内：`/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md`；`/mnt/data/dev/task-planner-skill/skills/plan-collab-router/SKILL.md`；`/mnt/data/dev/task-planner-skill/skills/plan-collab-router/references/skill-collaboration.md`；`/mnt/data/dev/task-planner-skill/skills/task-planner/references/spec-mode.md`；`/mnt/data/dev/task-planner-skill/CHANGELOG.md`（grep 命中行）；`/mnt/data/dev/task-planner-skill/skills/**`、`docs/`、`*.md` 中 grep 命中涉及文件（按 A1 表）。
- 仓内不存在：`/mnt/data/dev/task-planner-skill/skills/skill-agent-router/SKILL.md`（未找到）。
- 全局技能：`/home/terry/.zcode/skills/skill-agent-router/SKILL.md`；`/home/terry/.zcode/skills/comet/SKILL.md`；`/home/terry/.zcode/skills/comet-any/SKILL.md`；`/home/terry/.zcode/skills/comet-classic/SKILL.md`；`/home/terry/.zcode/skills/comet-hotfix/SKILL.md`；`/home/terry/.zcode/skills/comet-tweak/SKILL.md`；`/home/terry/.zcode/skills/comet-native/SKILL.md`（局部）；`/home/terry/.zcode/skills/comet-open/SKILL.md`（局部）；`/home/terry/.zcode/skills/comet-build/SKILL.md`（局部）；`/home/terry/.zcode/skills/using-superpowers/SKILL.md`；`/home/terry/.zcode/skills/openspec-onboard/SKILL.md`；`/home/terry/.zcode/skills/openspec-new-change/SKILL.md`；`/home/terry/.zcode/skills/openspec-propose/SKILL.md`；`/home/terry/.zcode/skills/openspec-apply-change/SKILL.md`（局部）；`/home/terry/.zcode/skills/openspec-explore/SKILL.md`（局部）；`/home/terry/.agents/skills/*` 与 `~/.zcode/skills/*` 的 superpowers 同族 frontmatter（命令提取）。  
- 命令证据：`grep -rniE ...` 输出、`ls` 目录列举、`awk/nl/sed` 片段读取。