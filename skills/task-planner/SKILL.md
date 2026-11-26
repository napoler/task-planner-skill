---
name: task-planner
agent: executor
description: Use when planning, decomposing, or organizing multi-step projects or research tasks expected to require more than 5 tool calls. Also use when resuming work after /clear.
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TodoWrite, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, WebSearch, WebFetch"
user-invocable: true
references:
- reference.md: Manus context engineering 原则 + 3-Strike + 5Q + Chain Handoff Contract 合约 + Chain Handoff Contract 重规划触发条件
- references/critical-rules.md: Critical Rules 核心域——Rules 1-117 全集索引（核心在位 1,2,3,5,19,20,26,51,62,66,80,81,82,83,109,111,112,113,116,117，含 Rule 82 分层纪律 + Rule 83 通道快速失败 + Rule 109 独立审计门 + Rule 111 进度产出基线防倒退 + Rule 112 检索排除清单纪律 + Rule 116 惰性文件引入规范 + Rule 117 跨任务共用未解决问题登记；其余 96 条按域归 12 卫星，见文末「卫星路由表」）
- examples.md: 完整执行示例（调研/bugfix/功能开发/错误恢复）
- references/completion-gate.md: 子代理验证（指针；全文→卫星 `../verification-gate/` Rule 84.4，2026-10-14 task-v173 迁移）
- references/goal-gate.md: Goal Gate + VC 规则（指针；全文→卫星 `../verification-gate/` Rule 84.3，2026-10-14 task/v173 迁移）
- references/todo-sync.md: 原生 Todo 同步契约（S1-S5 强制同步时机 + 映射规则 + hook 提醒响应协议）
- references/worktree-isolation.md: 冲突分析与工作树隔离契约（实现类默认首选 + 合并回合约）
- references/methodology.md: 思维方法论 T1-T5 指针 + 内容质量 Q3/Q4 + FMEA/Poka-Yoke
- references/longform-continuity-methodology.md: 长篇连续性方法论（T1-T5 应用于长文/连载创作，按需加载）；触发：长篇/连载/多章节内容创作任务需要创作连续性方法论支撑时；关键词：长篇 连载 章节 连续性 方法论
- references/spec-mode.md: Spec 模式路由（Superpowers×OpenSpec 显性集成：触发判定/路由表/安装引导/反模式/记录者调度者职责）
- 卫星技能 task-dispatch: 子代理派发/拆分/调度/超时兜底/返回校验/代码编辑隔离/使用点标注（`../task-dispatch/`，Rule 12,13,14,21,22,23,25,46,52,59,68,96,103,104）
- 卫星技能 task-discipline: 执行纪律/错误闭环/批量质量/反思/注释/可靠性/能力沉淀/变更吸收（`../task-discipline/`，Rule 4,6,7,8,9,10,18,27,28,29,31,32,33,35,36,41-45,48,53-57,60,65,67,69-74,76,85,86,87,88,89,90,92,93,94,95,97,98,99,100,101,102,105,106,107,114）
- 卫星技能 media-planner: 媒体制作派发/单元线并行/内容分级（`../media-planner/`，Rule 47,49,50）
- 卫星技能 verification-gate: 任务验证全链路——VC 可执行化设计/执行期 V-N 校验/终验 VC 复验/子代理验证/统一验证入口（`../verification-gate/`，Rule 84）
- references/plan-workflow-details.md: 计划制作循环细节（模板/审计/终验/JSON SOP/planctl 四件套等，按需加载）；触发：执行计划制作循环任一步骤需要细化操作、模板选型、审计门或 planctl SOP 时；关键词：计划制作 模板 审计 planctl 终验
# hooks: <TOOL-ADAPTED — stub files per tool register hooks via platform-specific config>
# See: ~/.claude/skills/task-planner/SKILL.md (Claude Code) / ~/.zcode/skills/task-planner/SKILL.md (ZCode)
model: opus
---

**[P0]** 禁止跨项目污染 · 禁止虚构 · 修改前必须 Read 并展示 diff · 技能文件修改需逐项授权。发现缺失=STOP 报告，禁止补全。
**完成总结（S58）**：交付前输出四字段中文总结——已完成事项 / 产出文件清单 / 遗留问题 / 下一步建议（≥2 条）；字段名逐字使用，禁用「应该没问题/已成功」等模糊语。

**Goal**：产出结构化 `task_plan.md`（含 Phases/VC/V-N），按 phase 推进，全 phase complete 后逐条复验 VC，交付 COMPLETE/PARTIAL/BLOCKED。**每轮锚定（抗上下文稀释）**：每次回答前（含工具调用后的续答）先复述当前任务 Goal 与 Requirements 首条用户原话（≤2 行）再推进；上下文定位不到锚时先读 plan-state.json/恢复包再答，禁凭压缩摘要继续。

## 定位：核心 = planctl.py 驱动的四文件罗盘管理（task-v171 分层后）

<!-- [2026-11-25 task-planctl-trigger-20261125] What: 定位段权重修复——原标题「核心 = 四文件罗盘管理」与下方分流铁律通篇未提 planctl.py，入口权重区把四文件呈现为可直接操作对象；实证 ~/.claude/opencode/cursor 三薄壳 planctl 提及=0、~/.zcode 段为场外手加（生成器源缺段，install 会回退丢失），端点执行期核心触发（planctl 唯一写通道）结构性不激活→直接手写派生视图（用户 2026-11-25 判例）。Why: 入口权重=激活链第一环，定位段不携带引擎表述则文末「结构化状态操作 SOP」硬规则埋底、下游门全部失效（本末倒置根治）。原行为: 定位段仅述四文件管理域与分流铁律，引擎表述仅存于文末 SOP 段。 -->
> **核心定位**：本技能 = **四文件罗盘的唯一管理域**，而罗盘的**唯一执行引擎与唯一写入口 = `scripts/planctl.py`**（P0：一切计划状态/语义变更必须经 `python3 <skill>/scripts/planctl.py <subcommand>` + `render`，`<plan-dir>/plan-state.json` = 唯一权威源；task_plan/findings/progress/verification 四个 MD 派生视图禁手工 Edit/Write（render 全量覆盖），罗盘四文件中的 knowledge-brief.md 为 render 链外专档（Rule 62 增量维护）——详见文末「结构化状态操作 SOP」；触发：需要确认 planctl 唯一写入口或四文件派生视图纪律时；关键词：planctl 权威源 派生视图 写入口）——`task_plan.md`（目标维：状态与指针）/ `findings.md`（决策维：调研结论与证据）/ `progress.md`（进度维：动作与测试）/ `knowledge-brief.md`（知识维：可复用知识底座）四文件 = 主代理↔子代理数据流转**唯一协议介质**（Rule 62.1）；`verification.md`（终验维）与 `user-session-log.md`（用户原话维，append-only 只写不改，Rule 80）同属记录文档域。子代理上下文=RAM，四文件=Disk。
> **非核心域已分层至卫星**：派发/拆分/调度→`task-dispatch`；执行纪律/错误闭环→`task-discipline`；媒体制作→`media-planner`；其余见文末「卫星路由表」。分层纪律=Rule 82（建制/边界/回归防线：禁回潮、禁镜像副本）。

**四文件写入分流铁律（写入动作本体 = planctl 子命令）**：状态与指针→`planctl set/add --section …`（→task_plan.md 派生视图；控制面板：只放目标/Phase 状态/VC/范围/一行摘要，Rule 19.6）；调研与结论→`planctl add --section findings`（→findings.md 派生视图）；动作与测试→`planctl add --section actions/errors`（→progress.md 派生视图）；可复用知识→knowledge-brief.md（render 链外专档，Rule 62 增量门控维护）。**「写到哪个文件」只决定选哪类子命令；写入动作本体永远是 planctl 子命令——task_plan/findings/progress/verification 四视图手工 Edit/Write=流程无效（render 全量覆盖）**。外部内容只进 findings.md（Rule 20.2）；结论禁只留会话记忆（Rule 19.1）。

## 计划制作循环

> **[P0] 两段式修复拆分判定（D1' 分级全覆盖 + D5 阶段二启动，强制）**：收到实现/修复/优化类请求时先做拆分判定，**禁止跳过**。
> - **分级全覆盖（D1'）**：修复类请求（报错/改错/bug/回归/异常）= 阶段一快修表层 + 产出完整根因线索包 + 阶段二从底层根治；非修复类请求 = 阶段一产出可用结果并尽早**合并回 master**、**不阻塞**下游 + 阶段二独立同族风险/隐患排雷（无风险以 `N/A`+证据收口）。
> - **升档铁律**：修复类请求命中 L0/mini/trivial/L0-E，**一律先升 L1 standard 复核，再走两段式**；不得以轻量档豁免跳过拆分判定（本判定优先于 :98-107 豁免块）。
> - **阶段一**：快刀修表层、快速产出；VC 复验通过后**立即合并回 master**，让依赖该成果的下游任务不被阻塞。
> - **阶段二**：独立 task-id（建议 `<A-id>-rc`），新 worktree 从底层排查根因、全面排雷，确保不再犯同类错误；与阶段一解耦，阶段二失败不影响阶段一结果。
> - **双向 tag 登记**：阶段一计划登记 `rootcause-followup:<B-id>`；阶段二计划登记 `followup-of:<A-id>`（INDEX 与计划元数据同步）。**根因线索包机器标记契约**：阶段一须用 `planctl add --section findings` 把线索包登记为 `[rootcause-followup:PASS] 线索包已落盘` 字面标记（非修复类无风险用 `[rootcause-followup:N/A]` + 理由），`planctl render` 后自动写入 findings.md 供 rootcause 消费门校验；禁只登记 tag 不写标记（门读 findings 正文，不读索引 key）。
> - **阶段二启动四要素（D5）**：执行者=阶段一主进程；触发时点=阶段一合并回 master 完成且 VC 复验通过后同轮；命令=`git worktree add <项目根>/tmp/worktrees/<A-id>-rc -b wt/<A-id>-rc master`（`--base master`）；失败口径=派发失败/会话结束仅在 INDEX 与 tag 登记 `pending`（`followup-of:<A-id>`），**不改阶段一 outcome、不回滚**。

- [ ] [M] **初始化（哨兵机制）— 机械子动作**：跑脚本建目录/设 env/校验在位/清哨兵
  > `[2026-09-10 task-planrequired-race]` 哨兵会话私有化：SessionStart 写会话私有哨兵 `plans/.plan_required_side/<sidkey>.plan_required`（sidkey=uuid core）；legacy `<root>/.plan-required` 仅兼容读取
  <!-- [task-perf-default-mini 2026-11-24] What: 分级缺省=mini，去掉 trivial/纯文档主观闸门；Why: 用户裁决默认简单 SOP、升级依据=客观运行时间而非主观判断 -->
  - 运行 `node --experimental-strip-types scripts/session-catchup.ts` 检测中断恢复点；创建 `plans/{task-id}/`，运行 `bash scripts/init-session.sh "<任务名>"`（任务名=$1，渲染进产物；**分级缺省=mini**（task-perf-default-mini 2026-11-24：默认简单 SOP、不做主观判断；④排除 `TASK_TIER_EXCLUDE=1` 或显式 `TASK_PLAN_TIER=standard` / `TASK_AUTO_TIER=0` 才落 standard）；升档双判据（软阈值默认 15min，`TASK_PLANNER_TIER_UPGRADE_MINUTES` 可调，须联合步骤门：phase complete / findings/research 落盘 / delegations 非空；无信号时硬兜底默认 45min，`TASK_PLANNER_TIER_UPGRADE_HARD_MINUTES` 可调；至少完成调研后升档才有参考价值，2026-11-24/25 用户裁决）由 posttooluse hook 自动升级 standard 检查面）
  - **无 hook 工具位升档自查（task-tier-deadzone-fix-20261125）**：claude/cursor/opencode 位无 zcode 的 posttooluse tier hook（其 PostToolUse 挂 check-doc-sync.sh 零 tier 逻辑）——主进程在三时机自查升档：①Phase 翻转后 ②每 10 次工具调用（S3 节奏）③收尾回读前；判据同 hook 双判据（时长>15min ∧ 步骤门[phase complete ∨ findings/research 落盘 ∨ delegations 非空] ∨ >45min 硬兜底），命中即 `planctl set --field plan_tier --value standard` + render + Decisions 登记 +（mini 骨架先补 R/VC 区块）重 attest；`tier-upgrade-check.sh` 已随技能部署可手动跑（plain text 输出，幂等 per-plan）。本条款=hook 不可用时的文本兜底，非 hook 位升级责任在主进程，禁以「无 hook」为由永不升档
  - **模板检索前置（task-template-catalog-20261122）**：init 前先跑 `bash scripts/template-catalog.sh list --json --scope all` 拿模板清单（模板名/简介/适配场景/功能），据此匹配 `template_type` 再作为 init 第 2 参；禁靠读散文盲选（用法详见下方「模板检索与管理」；触发：需要模板检索命令用法或选型入口时；关键词：模板检索 template-catalog 选型）
  - **脚本侧渲染（tplrender 2026-10-24）**：init 渲染层自动替换模板机械占位符（{{TASK_ID}}/任务名/日期/路径 6 变量+8 旧形态兼容映射，含 ${TASK_PLANNER_ROOT:-…} 死串修复）；**模型禁手工修正机械占位**，仅填写语义占位（尖括号中文/<用户原话>/#N 序号/[Title] 等）；残留 {{大写}} token 非注释行触发 fail-closed exit 1
  - **auto-tier env 变量（主进程调用 init 前以 env 提交任务体量事实）**：`TASK_AUTO_TIER=1`（opt-in 开关）+ `TASK_EST_MINUTES`（预估分钟）+ `TASK_SCOPE_FILES`（scope 文件数）+ `TASK_SCOPE_MODULES`（模块数）+ `TASK_TIER_EXCLUDE=1`（④排除）。[task-perf-opt Change #1] 新增 `TASK_SCOPE_FILE_LIST`（逗号分隔的文件名列表，如 `fix-bug.sh`）与 `TASK_EST_LINES`（预估变更行数）两个 env：主进程从用户指令解析 scope 文件列表与预估行数以 env 传入，init 在 auto-tier 块读取；四条件 ∧ 单文件代码（.sh/.ts/.cjs/.js/.py/.json）∧ ≤3 行 → 第四条件命中 mini+L0+trivial 三文件缩减档（Rule 38.6）
  - **会话隔离指针**：活跃计划经 `resolve-plan-dir.sh [root] [sid]` 双参解析（side 指针优先于全局 fallback；残留由 `set-active-plan.sh gc` 清扫）；**上下文压缩恢复（2026-11-24 task-session-regression-20261124 / task-compact-skill-always）**：压缩后 SessionStart hook 注入 `[compact-recovery]`——技能正文 SKILL.md 全文**无条件注入**（`planctl.py recover-skill`，无在途计划也注入，因压缩会冲掉整个技能体系）；有在途计划时再附加任务核心状态（权威源 `plan-state.json` 经 `planctl.py recover`），以包内字段为准续做，禁仅凭摘要续做
  - **模板优先级**（init-session.sh 自动处理）：项目级 `.claude/plan-templates/` 或 `.zcode/plan-templates/` 覆盖 → 兜底 `<platform-home>/skills/task-planner/templates/`（选型权威源=卫星 `plan-template-kit`，Rule 16/34）
  → 模板检索与选型细则（按需加载）→ 详见 references/plan-workflow-details.md §template-catalog；触发：制作/审计计划需要模板选型细则、template-catalog 操作或 JSON 模板 SOP 时；关键词：模板选型 template-catalog 变体 render JSON
  - **验证**：7 文件在位（task_plan/findings/progress/notepad-learnings/verification/knowledge-brief/user-session-log，Rule 80）
  - **S1 同步**：`bash scripts/sync-todos.sh --json` → 每 Phase 一条原生 Todo；**禁止只建计划不建 Todo**
  - **进度产出基线登记（Rule 111）**：计划期登记 `📦 进度产出基线`，禁倒退清单随计划 attest 锁定（交付/合并/返工均不得就地删降替）
  - **检索排除清单纪律（Rule 112）**：任何检索前先读项目根 `RETRIEVAL_EXCLUDE.md` 并按「可排除/必须纳入」条件排除（跨调研/执行/回找多域，L0-T 文本锚；详见 references/critical-rules.md Rule 112）；触发：执行检索前需确认排除清单或判定可排除/必须纳入边界时；关键词：检索排除 RETRIEVAL_EXCLUDE Rule112
  - **清除哨兵**：`node scripts/plan-created.cjs`（双清除 side+legacy）；哨兵存在期间 PreToolUse hook 拦截非 plans/ 路径 Write/Edit（exit 2）

  → 初始化委派细则（按需加载）→ 详见 references/plan-workflow-details.md §init-delegation；触发：计划初始化需委派 plan-writer、收窄主代理职责或处理计划期单写者边界时；关键词：初始化 委派 plan-writer 收据 单写者
  - **可选前置（历史经验）**：L1+ 新任务主题涉同类改造/既有机制扩展/曾犯错领域时，建议先 Skill("plan-history-recall") 产出 history-brief 再定方案；不强制，L0-T/mini 跳过

- [ ] [A] **初始化（哨兵机制）— 智能子动作**：体量分级判定与隔离决策
  - **冲突分析**：`bash scripts/check-conflicts.sh` → 结果+隔离决策写入 task_plan.md「🔀 隔离决策」（实现类默认首选 worktree；首动作委派子代理已起草时=复核/校正，不重写）
  → 冲突分析与隔离决策细则（按需加载）→ 详见 references/plan-workflow-details.md §conflict-isolation-options；触发：初始化判定 worktree 隔离或 Spec 模式路由、需要隔离选项思路时；关键词：隔离 worktree 冲突 Spec 路由

- [ ] [A] **计划独立审计门（D1 前强制 — audit-before-delivery，Rule 109）**：L1+ 计划在展示/授权前必须经独立子代理审计迭代达标，未经审计的产出禁交用户
  - **触发**：计划产出（主进程盘上复核 Rule 84.4 完成后）且智能子动作（冲突分析+隔离决策复核+Spec 判定）完成之后、本区块「[A] 计划确认」展示之前；B/C/D/E 类任何计划（再）展示/确认前同样过门，修订重审可用简版（仅审变更增量+上轮问题清单闭环）
  - **分档豁免（Rule 38.7 比例原则）**：L1+ 强制；mini/L0/trivial=轻量复核（主进程盘上复核+基线自查）或登记豁免（一行留痕 `[plan-audit-skip]`+理由）；L0-E 豁免
  <!-- [task-perf-default-mini 2026-11-24] What: 审计收敛依据改挂脚本锚；Why: 与 critical-rules/plan-workflow-details 口径对齐，避免「不设上限」被误读为无刹车 -->
  - **审计体（独立上下文，只读）**：首选 critic（「审查计划/review 文档」触发在位）；不可用降级链=critic 失败→重试 1 次→decision-arbiter→general-purpose→AskUser（逐级留痕）；审计分歧→decision-arbiter（Rule 69.1）；修正执行=主进程驱动 Plan Writer 重派（22.4a/62.2 计划期单写者不变）；**审计轮次脚本刹车（2026-11-24 task-perf-default-mini）**：累计 2 轮 REJECTED 且无 APPROVED → planctl 写入打印 [audit-cap]，Agent 派发被 PreToolUse 拦截（decision-arbiter 例外），直到登记 [audit-converge]；「轮次不设上限」仅指有实质进展的迭代。96.7/109 门不变。
  → 计划独立审计门细则（按需加载）→ 详见 references/plan-workflow-details.md §audit-gate-details；触发：L1+ 计划进入 D1 前审计、判定 APPROVED/REJECTED 或处理审计无进展刹车时；关键词：审计 audit APPROVED REJECTED 刹车

- [ ] [A] **计划确认**
  - 展示 `task_plan.md`（Phase 列表+VC 表）给用户，附计划文件绝对路径+待审项清单+看点+动作（Rule 70 四要素）；**VC 每项须含可执行验证命令（Rule 84.1）**——验证域规则与 SOP 详见卫星 `verification-gate`（`Skill("verification-gate")`）；触发：计划确认前需核对 VC 可执行命令或查验验证域 SOP 时；关键词：计划确认 VC 验证门 verification-gate
  - **指令理解对齐（Rule 28.2.2）**：计划确认前须已完成/呈示 3-4 轮理解迭代草稿（原始指令→理解→思路与候选+歧义门控→大体方向，粗稿非定稿）以暴露方向供纠偏。**goal/目标迭代（28.8）优先覆盖**：明确或歧义/多候选均**禁止**向用户提问/列选项请求确认/等待回复，按推荐项或可逆安全默认静默自决并留痕后直接继续推进（歧义仅内收敛+登记假设）；同问禁复发；预算外硬门（28.9②）不停表——登记待授权清单后继续，收到续推指令按 28.9③-⑤ 幂等处理。**非 goal**：明确任务不因本模块新增停等确认（无歧义时提示可纠偏后继续），仅歧义/多候选(典型3-4)或关键范围不明时按选项确认（28.3）；silent/44.3 自动通过/mini 缺省 silent 场景按 28.2.2 降级留痕与推荐项自决，不做多轮阻塞。
  → 计划确认与指令对齐细则（按需加载）→ 详见 references/plan-workflow-details.md §plan-confirm-alignment；触发：计划确认前做指令理解对齐、交互模式判定或 goal 静默自治决策时；关键词：计划确认 对齐 交互模式 goal 自治
  - **交互模式（Rule 28）**：ask 模式在计划全文后口头复述大体执行思路（≤5 行，28.2.1）并登记 Decisions Made；silent 模式自动通过+交付附静默决策清单；解析优先级 env > 计划配置表 > config.json > 默认 ask；**goal/目标迭代语境强制自治（28.8）**：/goal 续推下选择/确认全静默按推荐项自治并留痕，禁止询问阻塞与同问重复，预算外硬门不停表——按 28.9② 登记待授权清单后继续；宿主 goal verifier 续推指令一律按 28.9③-⑤（差异归因一次→固定点应答），用户授权消息到达按 28.9⑦ 立即执行预案（D6 类项须逐项显式确认）（见 critical-rules-discipline 28.8/28.9/44.3/44.5）
  - **规则编号预留（Rule 20.6）**：新增 Rule 编号在计划声明 `new_rule: <NN>`；attest 自动查重登记（账本 `plans/.rule-reservations.jsonl`）
  <!-- [task-output-example-contract-20261125] What: 计划确认前核对 output_examples；Why: 防「声明输出格式却无样例」的表面专业实质不可用（Rule 113） -->
  - **输出示例契约核对（Rule 113/113.10）**：**第一动作=先向用户展示产出示例实物**（真实路径/可读代码块 + 同结构占位模板 + 审查命令与预期输出），再写条款/方案；权威形态见 `examples/json-template-upgrade/review.md`。产出计划前核对 `output_examples`——凡交付物声明输出格式（JSON/Markdown/表格/API 等）必须已有完整示例 + 同结构可复用模板，禁只写格式不给样例、禁仅标题 token；示例经 `planctl add --section output_examples` 写入并由 `planctl render` 派生到 task_plan.md 同名区块（模板见 `templates/variant/` 同名区块；mini/L0 极简档至少 1 条）；新计划锁定经 `attest-plan.sh [example-gate]` 拒缺/空/占位

- [ ] [M] **Poka-Yoke 前置检查**（`references/methodology.md` §R1/R2）：依赖文件存在/上 Phase 产物非空/必要配置在位；高风险 Phase（FMEA RPN>100）须登记预设兜底动作；不满足先修前置

- [ ] [A] **思维方法论解构**（`references/methodology.md` T1-T5，指针）：计划期已按问题先行三问+5 Whys+结论先行附推导链完成解构，答案落 task_plan「核心问题定义」+findings.md；方案终裁（Rule 69.1 T1）≥2 候选难决→委派 decision-arbiter，不硬决不直接 AskUser
  → 思维方法论 T1-T5 细则（按需加载）→ 详见 references/plan-workflow-details.md §methodology-t1-t5；触发：计划期做问题解构、5 Whys、结论先行或方案终裁需要方法论支撑时；关键词：方法论 T1-T5 5Whys 解构 终裁

- [ ] [M] **共享内容追踪检查点（Rule 30）— 机械子动作**：命中则 `Skill("progress-tracker")` 建/用项目级账本（`.zcode/ledger/`），逐 target 认领登记+收尾 Todo；未命中 → Decisions Made 记不适用理由
- [ ] [A] **共享内容追踪检查点（Rule 30）— 智能子动作**：判定是否命中 30.1 识别条件（可枚举共享资源只认领一部分 / 同类任务 ≥3 次）
  → 共享内容追踪检查点细则（按需加载）→ 详见 references/plan-workflow-details.md §shared-tracker-options；触发：判定是否命中共享追踪条件、需要建立项目级账本或认领登记时；关键词：共享追踪 账本 progress-tracker 认领

- [ ] **Phase 执行循环（每 Phase 独立闭环）**
  1. [M] **开启 Phase**：`planctl phase-start --id P<n>` 后 `render`（task_plan.md=派生视图，禁手工 Edit）；**R 锚定复诵**（v168）：Read「🎯 用户需求原文」→ 经 `planctl add --section actions` 落盘 `- **R 锚定**：本 Phase 服务 R<n>「<一句话复述>」`（随 render 入 progress 视图）；与 Goal 或当前动作不符=先修计划再开工
  2. [M] **同步 Todo（S2）**：对应 todo→in_progress；步骤 1/2 必须紧邻执行
  2.5 [A] **委派检查点（Rule 25）**：Phase Executor≠主进程 → 立即按九字段模板逐 S-unit 派发子代理（路由表/粒度门/伴飞/返回校验/兜底详见卫星 `task-dispatch`）；触发：Phase Executor 非主进程需派发子代理或查派发路由/兜底时；关键词：委派 子代理 派发 路由 兜底。主进程只保留派发/回填三文件/验收 Read；无 Executor 字段=计划无效先回炉；禁止"先自己干再派"
     **使用点标注速查（Rule 104.2 就地版 — 默认执行体，偏离须 `[markup-exempt] 理由`）**：
  → 执行体使用点标注速查（按需加载）→ 详见 references/plan-workflow-details.md §execution-agent-quickref；触发：派发 Phase 前确认默认执行体、伴飞标注或 markup-exempt 豁免时；关键词：执行体 派发 标注 executor 豁免
  2.5b [A] **技能激活确认**（v168）：派发前 Read knowledge-brief.md §6 可用强化技能清单 → 择优伴飞激活并登记 Handoff（用户触发型技能仅提示不代激活）；**资料消费锚（task-resource-utilization-20261123）**：本节命中并复用 kb/findings 既有条目时，同轮 `planctl add --section knowledge_use --json '{"id":"KU<n>","phase":"<P>","source":"<kb:§N|findings锚>","purpose":"<消费点>"}'`（复用既有 section，零新字段/新门；未命中无需记）
  2.5c [A] **动作相关性三问**（v168）：新文件/新命令/新 S-unit 动手前过三问——① 服务本 Phase R 锚定？② 在 scope_files 内？③ 用户原话要求过？任一 No→记录不执行
  2.5d [A] **变更类型判定（Rule 74 三判门，P0）**：对既有文件/条目的每处变更，执行前必须判定变更类型（增量/替代/删除），答案登记 task_plan.md「📋 变更标注表」：
     - **增量（默认且优先）**：用户措辞含"补充/再加/还有/另外/同时"或语义为新增条目 → 只追加、既有条目逐字保留不动；"补充一些条目"类指令永远走本档，禁以"整合/去重/顺手重构/格式化"名义回写既有条目
     - **替代（禁默认，四条件全满足才可）**：① 既有内容被新证据或回归测试证伪，或已被用户明示否决/作废；② 替代范围完整覆盖旧场景；③ 替代前已 Read 旧内容全文；④ 替代后既有守护/selftest 全绿。缺任一 → 回落增量
     - **删除（最高门槛）**：必须取得用户逐项授权；未授权只可停用/标记，禁物理删除
  → 变更类型判定与合规门细则（按需加载）→ 详见 references/plan-workflow-details.md §change-type-compliance-gate；触发：对既有文件做增量/替代/删除判定或填写变更标注表合规四元组时；关键词：变更类型 增量 替代 删除 合规门
  2.5e [M] **Agent 失败会话级留痕（task-agent-failure-ledger-20261123，用户裁决）**：主进程每次 `Agent()` 调用**返回失败**（provider 限流/超时/UNKNOWN_ERROR/输出不可信被驳回等任何非成功返回）时，**紧邻一次** `bash <skill>/scripts/agent-failure-ledger.sh append <plan-dir> <sid> <agentType> "<失败原因>"`，把 `{ts, agentType, reason}` 追加到本任务 `.agent-failures/<sid>.jsonl`。
  → Agent 失败会话级留痕细则（按需加载）→ 详见 references/plan-workflow-details.md §agent-failure-ledger-details；触发：Agent 调用返回失败需要 append 留痕或交付时汇总失败台账时；关键词：Agent失败 留痕 ledger 失败台账
  3. [M] **执行 Phase 工作**（内嵌 3-File 落盘，Rule 19）：
     - **3a 子代理产出回填（19.1）**：每次子代理/调研 Skill 返回后**紧邻一次 `planctl add --section research`（结论摘要+证据路径）+ `render`**；回填完成才勾 Handoff `verify_done`（Read 产出+findings 双条件）；验收争议（Rule 69.1 T4）→ decision-arbiter 仲裁。**采集→消费闭环（task-resource-utilization-20261123）**：每条采集结论回填 research 时同轮补一条 `planctl add --section knowledge_use --json '{"id":"KU<n>","phase":"<P>","source":"<research锚>","purpose":"<下游消费点;未消费写「未消费 因__」>"}'`——把「查了却悄悄丢掉」变为「回填时显式声明去向」；purpose 留空或缺失视为该采集未闭环，收尾回读门（84.14）逐条核对。复用既有 section/schema/render（planctl.py knowledge_use），零新增脚本/门/hook。
     - **3b 2-Action Rule（Rule 3）**：每 config.json#max_view_browser_before_save（默认 2）次 view/browser/search 后写 findings.md；多模态内容立即转文字落盘
     - **3c 动作留痕**：关键动作随做随记 progress.md；错误**立即**写 Error Log（19.4）并同轮完成四步（v168：记错误原文→Rule 31.2 四问根因→纠正→复验回填，未完禁下一动作）；关键动作同步 `bash <skill>/scripts/ledger-append.sh <plan-dir> <event> <summary> [--phase N]`
     - **3d hook 响应**：`[plan-sync]`→按 `references/todo-sync.md` §4 协议回写；`[plan-compass]`（findings/progress 陈旧，Rule 19.7）→立即回填再继续
     - **3e 上下文卫生（Rule 29，细则→task-discipline）**：每 2 个 Phase 跑 `bash scripts/check-context-hygiene.sh`；工作文件整理在会话恢复/用户指令时运行
     - **3f 周期性三文件对照**（v168/R3）：每完成一个 S-unit（或每 10 次工具调用），Read task_plan Goal+Phase 状态与 progress 尾部对照；不符按 Rule 65.4 标 `[corrected]` 回错误步并一句话记 progress
  → Phase 上下文回想细则（按需加载）→ 详见 references/plan-workflow-details.md §phase-context-recall；触发：Phase 执行中做周期性三文件对照、回想目标或纠偏漂移时；关键词：上下文回想 三文件 对照 漂移 纠偏
  - **3h 双轮质检（Rule 103）**：子代理返回→核 checkpoint 自审段（103.2）→Read 产出（84.4）→派全新复检体（103.3，升档 103.4/简洁五要素 103.5）→复检回执落 checkpoint；多文件变更集附同步核对清单（103.6）。复检体全文回读被改文件并整体分析（103.3a 义务，2026-11-14 task-audit-fullreread-20261114）。
  - **3i 修改后复检（Rule 106）**：受管文档每次修改后回读校验跨字段不变量（106.1-106.4）；同文件 ≥2 次修改后全量回归（106.3）——细则→task-discipline Rule 106；结构文件插段另守 106.1a
  4. [M] **回写计划**：Phase→`complete`+勾选+证据路径；**⚠️ 3-File 回填门控（19.2）**：翻转前 progress Phase 段已回填（Actions/Files/Test Results）+ findings 本 Phase 有实质增量，`bash <skill>/scripts/check-3file-gate.sh <plan-dir>` exit 0 才可翻转（信号优先级 ledger 语义证据 > mtime；纯实施 Phase 一行 `[implementation-only]` 声明计增量）；**V-N 校验（Rule 84.3/84.4）**：翻转前逐项执行 verification.md 当前 Phase 段的 V-N 验证命令（SOP→卫星 `verification-gate` Step 2），V-N 未全 PASS→禁止翻转；**多文件变更集（≥2 受管文件）翻转前先过 103.6 同步核对清单（清单全绿才可翻转，Rule 103.6）**；**Git 差异门（2026-11-24 task-session-regression-20261124）**：Phase 翻转前由 check-3file-gate 第 8 条件自动跑 Git 差异分析，unresolved>0 拒翻
  - **对齐必选步骤**：修改完成后强制对齐——任何受管文件修改完成后、Phase 翻转 complete 前必须执行对齐核查，逐项核对关联面四族+部署位+引用面（字面/引用/部署镜像/断言面）同步完整性，清单全绿才可翻转，杜绝部分改部分丢弃（机器门=check-complete.sh ALIGN-ANCHOR GATE；mini 档豁免）
  4.5 [M] **提交工作产物（Rule 27 / git-rework-guard）**：实现类 Phase 翻转 complete 前 commit 本 Phase 产物（禁跨 Phase 攒批、禁 `git add -A` 盲扫、只 add scope 文件）；**单个 S-unit/大改动完成即 commit（不等整 Phase），让每个可回退点进版本历史**；非 git 记行跳过；deferred/用户显式豁免须写入计划。**返工第一动作=Git 找回**：QC FAIL/方向错/需回退 → 先 `git log --oneline` 定位正确 commit + `git checkout <commit> -- <file>` 精确找回，禁凭记忆重做；方向彻底错→丢弃 wt/<task-id> 分支（不污染 master）；细则→`references/worktree-isolation.md` §4.5+§4.6；**方向根本错误且阈值命中（96.7/103.8b）→走 §4.6 弃旧开新**：评估归因+用户确认→提取有效数据(salvage-manifest)→从基线牵新 wt/<task-id>-rN→新计划 restarted_from 登记，旧计划 outcome=RESTARTED(非 CANCELLED)（细则→§4.6）；**检查点（2026-11-24 task-session-regression-20261124）**：单个 S-unit/Phase 产物提交后执行 `bash <skill>/scripts/git-baseline.sh checkpoint <plan-dir> --label <S-unit 或 Phase id>`
  5. [M] **同步 Todo+索引（S2/S4）**：todo→completed；`bash scripts/sync-todos.sh --index` 刷新 INDEX.md
  6. [A] **[DRIFT CHECK]** 派发 `drift-checker` 偏移检查（载体 Rule 61/64，详见卫星 `task-drift-guard`）；触发：Phase complete 后或连续调用/切模块前需做偏移检查时；关键词：漂移检查 drift-checker ALIGNED BLOCKED。✅ALIGNED→继续；⚠️DRIFT→记 progress 警觉继续（「警觉 vs 返工」拿不准→decision-arbiter 裁决）；🔴BLOCKED→STOP 报告用户等决策。触发时机=Phase complete 后立即/连续 ≥3 次工具调用/切换文件模块前/用户新指令时（先过「用户新指令处理」判定）；留痕三件套（检查点+`ledger-append.sh drift_check`+Drift Log 行）缺一=未执行
     drift-checker=执行偏移/目标漂移的安全网（Rule 61/64），**非意图切换发起器**——用户新指令的意图变更走上方快速判定卡判定归属，偏移检查只在判定归属当前计划后才派发。
  → Drift Check 执行选项细则（按需加载）→ 详见 references/plan-workflow-details.md §drift-check-options；触发：Phase complete 后派发 drift-checker、处理 ALIGNED/DRIFT/BLOCKED 结论时；关键词：drift-checker 偏移 ALIGNED BLOCKED 留痕
- [ ] [A] **Code Review Gate**（仅 `code_review: required`）：全部 Phase complete 后、终验交付前触发；轻 diff（代码 ≤3 文件且合计 ≤50 行）单轮轻量审查，重 diff 全量多轮；`Skill("code-quality-review")` 输出 APPROVED 才可进入终验交付；CHANGES_REQUESTED→追加 fix-phase 回执行循环；CR 分歧（Rule 69.1 T6）→decision-arbiter

- [ ] [M] **终验交付 — 机械子动作**：跑终验门脚本/合并回/提交核验/Read 产出/归档
  - **3-File Gate（19.5）/GIT-BASELINE GATE（2026-11-24 task-session-regression-20261124）**：check-complete.sh 内置校验 findings/progress 非 stub（缺失/stub→exit 1→STOP 回填禁交付），终验自动跑全量 Git 差异分析并核 sidecar（B9/B10 缺证或 B11 unresolved>0→exit 1→STOP 禁出 outcome）
  - **隔离任务合并回**：worktree 内全 VC 复验且无未提交变更→`bash <skill>/scripts/smart-merge-back.sh <worktree-path> [--deploy]`→清理 worktree/分支→主仓 Read 复验（合约见 `references/worktree-isolation.md`）；触发：worktree 任务终验合并回主仓、清理分支或复验合并结果时；关键词：合并回 worktree merge 清理 复验
  → 终验机械子动作细则（按需加载）→ 详见 references/plan-workflow-details.md §final-verification-mechanical；触发：终验交付跑门脚本、合并回、归档或防倒退终检时；关键词：终验 机械门 合并 归档 防倒退
  - **防倒退终检（Rule 111/106.8）**：交付/合并前执行 `🛡 防倒退终检`，对照 `📦 进度产出基线` 逐项判定净效果≥0，禁拆东墙补西墙
  - **检索排除清单（Rule 112）**：检索前先读 `RETRIEVAL_EXCLUDE.md` 按条件排除，避免临时/资料文件淹没会话
  - **计划归档（Rule 81.1）**：check-complete exit 0 后运行 `bash scripts/archive-plan.sh <task-id>` 将完成任务目录移入 plans/archive/——target 已存在=幂等报 `ALREADY_ARCHIVED` 视为通过；守卫拒绝（active 指针 / .session-owner 活跃 / Status 未全 complete，fail-closed）→ 保持原位并登记拒绝理由，禁止强移。Why：「在途在根、历史在 archive/」是 plans/ 存量唯一健康形态，防无限堆积致索引失真（task-v170；详见 references/critical-rules.md Rule 81）；触发：终验交付后归档完成计划或处理归档守卫拒绝时；关键词：归档 archive Rule81 守卫 plans

- [ ] [A] **终验交付 — 智能子动作**：VC 复验判定、质量门控与委派率核查、outcome 判定
  - **终验强制对齐**：终验交付判定前必须执行对齐核查，核对本任务全部修改的关联面四族+部署位+引用面同步完整性，零丢弃才可判定 COMPLETE；机器门=check-complete.sh ALIGN-ANCHOR GATE enforce 缺锚阻断
  - **按卫星 `verification-gate` 终验 SOP 执行（Rule 84.5 Step 3）**：Read `verification.md`，逐条复验 VC（每条带证据路径+可执行命令）；统一入口 `bash <verification-gate>/scripts/run-verification.sh <plan-dir>` 自动执行 VC 命令并汇总 PASS/FAIL；触发：终验逐条复验 VC 或运行 verification-gate 统一入口时；关键词：终验 VC复验 verification-gate run-verification
  - **全文档收尾回读梳理（Rule 84.14，P0 迭代门）**：全部 Phase complete 后、outcome 判定前，主进程全量回读六文档体系（用户需求专档 #1→最新/task_plan Goal+R+VC/findings 全结论/knowledge-brief 沉淀/progress 动作线/verification 验收记录）做五维互洽检查（需求↔目标↔执行↔验证↔知识，每维问「有无偏移/遗漏/未利用」）；**mini/纯文档轻量档收窄（2026-11-24 task-perf-tiers）**：plan_tier=mini 或 L0 档的收尾回读只做 task_plan.md Goal+R+VC 与 verification.md VC 记录两文档，其余四文档按需 Read（有偏离迹象才读）；触发：收尾回读按需补读其余四文档时；关键词：收尾回读 按需Read 六文档。五维互洽中"知识"维仅在本 Phase 有 research 采集时核对。标准档/涉及代码/多模块任务仍全量六文档，不变。**「知识」维新增逐条核对（task-resource-utilization-20261123）**：Read progress.md「📚 必要知识储备使用记录」表，本 Phase 每条 research/findings 采集结论应有 knowledge_use 行且 purpose 非空；缺失/空 purpose=补录消费点或在 findings 标注「未消费 因__」后重回读，禁采集后无声丢弃；发现偏移→登记（task_plan「收尾回读梳理记录」区块+progress `[recall-final]` 行）→修复→再梳理；**收敛出口=连续一轮零新发现才可出 outcome**，迭代轮次不设上限（用户裁决「不要怕浪费资源」）；触发：outcome 判定前执行全文档收尾回读与五维互洽时；关键词：收尾回读 五维互洽 Rule84.14 outcome
  - **收尾对齐与清理**：交付前按 task_plan 模板「🧹 收尾对齐与清理」板块执行——①对齐口径 ②清理本任务新增无价值注释（保留契约注，判例归档 forensics）；**清理范围仅限会被 Agent 读进上下文的 Skill 说明 Markdown（SKILL.md/references/templates），代码文件（.py/.sh/.ts 等）里的注释属保护对象、禁止清理**（不进 Agent 上下文、便于后期理解）；执行在 outcome 判定与合并回之前；证据落 progress `[align-final]`/`[cleanup-final]` 行；mini/L0-lite 档豁免。
  - **双轮质检与同步完整性终验衔接（Rule 103）**：终验前核对本计划各多文件变更集的同步核对清单全绿记录（103.6）；双轮质检细则→task-dispatch 卫星 Rule 103。
  - **质量门控统计（Rule 26）**：核查 Q1-Q6 触发与豁免登记；抽查 ≥3 条 Evidence（路径可 Read、结论可复现）；未处置违规按 Rule 26.3 降级 outcome，Q3→BLOCKED+STOP
  - **委派率统计（Rule 25，细则→task-dispatch）**：子代理执行 Phase 占比 < `config.json#delegation_rate_floor`（默认 0.7）或直做含白名单外理由→check-complete exit 1 回炉；**纯执行 S-unit 权重 0（P4，2026-10-22 用户授权）**：命中 L0-E 档（零仓库受管变更 ∧ 仅调用既有工具 ∧ 产物落 gitignore 区）的 S-unit **既不计入分子也不计入分母**——若计入分母会拉低委派率，方向与「机械操作免强制派子代理/免终验回炉」的豁免意图相反（审计判例 F9）；机器面=计划 Executor 行标 `L0-E`（或括注含「纯执行」）即识别，`check-delegation.sh stats` 已按此口径实现（分母扣减 + 该单元不判 violation + 整批皆纯执行时 rate=1.000 视为达标）
  - 交付结论 COMPLETE/PARTIAL/BLOCKED；**交付总结五要素**（Rule 48：全体指针绝对路径/可执行命令）按 `templates/delivery-summary.md` 输出
  - **挂起计划回切检查（intent-switch 回切）**：outcome 判定后、归档前，检查本计划 progress.md/Decisions 的 [intent-switch] 登记链（旧=<id>）与 plans/INDEX.md 待处理区——存在挂起计划则会话面输出【计划回切通告】询问是否切回：用户 yes=释放活跃指针→完成本计划归档/收尾提交→路由 Skill("plan-resume") 定向恢复该计划续推；no=登记保持挂起（[intent-switch] 追加 回切状态=no|保持挂起）。不自动切——切回也是目标变更，须用户显式确认，本回切门优先于 plan-resume 触发点③自主续推（本场景定向恢复须用户显式 yes）。多条挂起链按登记最近一条优先、逐条确认。（本检查须先于 [M] 机械子动作块的归档动作执行；归档置后）
  - 决策分级（Rule 72）/呈报四要素（Rule 70）/变更吸收三判（Rule 74）/编号列表规范（Rule 76）按卫星 `task-discipline` 全文执行
  → 终验智能子动作细则（按需加载）→ 详见 references/plan-workflow-details.md §final-verification-options；触发：终验做 VC 复验判定、质量门控、委派率核查或 outcome 判定时；关键词：终验 VC复验 质量门控 委派率 outcome

### 📄 产出落盘映射（3-File Pattern）

> 原则：**Context Window = RAM（易失），Filesystem = Disk（持久）**；恢复读序：task_plan（在哪/去哪）→ progress（做过什么）→ findings（已知什么）→ knowledge-brief（可复用什么）。

  → 产出落盘映射表细则（按需加载）→ 详见 references/plan-workflow-details.md §output-mapping-table；触发：需要确认某类产出应落盘到哪个计划文件或恢复读序时；关键词：落盘映射 产出 task_plan findings progress
| 调研蒸馏知识（可复用事实/锚点/易错点） | `knowledge-brief.md` §2/§3/§4（主进程单写者蒸馏，Rule 62.3 双落盘） | 22.5 复核时，Handoff 记双锚 `findings锚\|kb:§N` |

  → 读写矩阵细则（按需加载）→ 详见 references/plan-workflow-details.md §read-write-matrix；触发：确认主进程/子代理对计划四文件的读写权限边界时；关键词：读写矩阵 权限 主进程 子代理 四文件
### 合规检查清单（核心域，每 Phase 开始前逐项确认）

| # | 检查项 | 状态 |
|---|--------|------|
  → 合规检查清单 A 细则（按需加载）→ 详见 references/plan-workflow-details.md §compliance-table-a；触发：Phase 开始前逐项核对核心合规检查项 G1-G12 时；关键词：合规检查 清单 G1-G12 Phase 开始
<!-- [task-perf-default-mini 2026-11-24] What: G4 补 mini 档豁免口径；Why: 与 G9-G11 同款措辞，缺省 mini 后 drift-checker 派发豁免需可查 -->
| G4 | DRIFT CHECK 已派+留痕三件套齐（检查点/ledger drift_check/Drift Log 行；机器面=selftest-drift-check-subagent.sh + check-drift.sh，人工核查；mini 档豁免） | ☐ |
| G5 | 子代理结论已落 findings（含多模态转文字）；ledger 关键动作已追加 | ☐ |
| G6 | complete 前 `check-3file-gate.sh` exit 0（progress 回填+findings 增量，19.2）；Handoff verify_done 已勾（Read+回填双条件） | ☐ |
| G7 | 本 Phase 无未处置质量违规（Rule 26 Q1-Q6 或已豁免登记）；产物已 commit（Rule 27） | ☐ |
| G8 | 原生 Todo 已同步（S2）；用户新指令已过 D/A/B/C 判定（如有） | ☐ |
| G9 | 用户会话逐字记录自查（Rule 80，原 C56 并集承载）：每次用户发言已逐字落盘 user-session-log.md（80.1）；写入=append-only 历史条目零改写零删除零重排（80.2）；会话恢复先读专档再读 task_plan.md（80.4）；理解镜像已同号配对（80.7）；**决策前读取已过（80.8 五决策点：上抛裁决/反思门/交付双锚/派发双锚/周期对照，各读取动作有留痕或执行证据）**；（机器面=selftest-session-log.sh+check-complete SESSION-LOG GATE，记录内容人工核查；mini 档豁免） | ☐ |
| G10 | 计划完成后归档自查（Rule 81，原 C57 并集承载）：check-complete exit 0 后已执行 `bash scripts/archive-plan.sh <task-id>`（81.1，guard/ALREADY_ARCHIVED 幂等路径走通）；守卫拒绝（active 指针/活会话标记/Status 未全 complete，81.3）时保持原位不归档并登记拒绝理由，禁强移；归档后已重跑 `sync-todos.sh --index`（81.4）（机器面=selftest-archive-plan.sh+check-complete [ARCHIVE-GATE] warn，归档动作与拒绝登记人工核查；mini 档豁免） | ☐ |
| G11 | 修改完成后对齐核查：所有任务修改完成后已执行对齐核查——关联面四族（字面/引用/部署镜像/断言面）+部署位+引用面同步完整性逐项核对零丢弃，机器门=check-complete.sh ALIGN-ANCHOR GATE（enforce=缺锚阻断，mini 档豁免）；人工面=核对清单全绿 | ☐ |
<!-- [task-output-example-contract-20261125] What: 合规表增 G12 Rule 113 检查项；Why: 为 output_examples 契约提供每 Phase 可勾核的人机双验锚 -->
| G12 | 输出示例契约核对（Rule 113/113.10）：**先展示产出示例实物**（真实路径/可读代码块+占位模板+审查命令），再写条款；凡交付物声明输出格式（JSON/Markdown/表格/API 等）必须已有完整示例 + 同结构可复用模板，禁只写格式/仅标题 token；示例经 `planctl add --section output_examples` 写入并由 `planctl render` 派生；新计划锁定经 `[example-gate]` 校验（mini/L0 极简档至少 1 条） | ☐ |
> 非核心域合规项（派发/纪律/媒体/模板/调研/协同族）随规则迁至各卫星 `critical-rules-*.md` 全文（按需加载）→ 详见上方卫星路由表对应 `references/critical-rules-*.md`；触发：需查非核心域规则全文或判定规则归属卫星时；关键词：卫星规则 critical-rules 按需Read 归属

<!-- [task-perf-default-mini 2026-11-24] What: 汇总散落 mini 豁免为单一常置指针表；Why: 缺省 mini 后逐处翻规则成本高，冲突裁决以各门脚本为准 -->
> **mini 缺省档最小流程（2026-11-24 缺省 mini 后的常置口径）**：init 产物即 mini → 免计划独立审计体（Rule 75 轻量复核）、免双轮质检复检体（103.7 豁免面）、免 drift-checker 派发（G4）、免归档（G10）、收尾回读两文档（Rule 84.14，L141）、基线 todo 裁 6 条（B2/B6/B7/B8/B15/B16，sync-todos）；运行 >15min 且命中步骤门（phase complete / findings/research 落盘 / delegations 非空任一），或无信号运行 >45min 硬兜底，由 hook 自动升级 standard（[tier-upgrade] 注入；两阈值 env 可调），升级后以上全部恢复标准档。无 hook 的工具位主进程按三时机自查升档（Phase 翻转/每 10 次工具调用/收尾回读，判据同 hook 双判据，命中即 set standard+render+登记+重 attest；tier-upgrade-check.sh 已随技能部署可手动跑）。散落豁免以此表为索引，冲突以各门脚本为准。

### 🔁 原生 Todo 同步（强制）

计划文档=唯一事实源，原生 Todo（`TodoWrite`/Task）=执行视图。五个强制同步时机：**S1** 计划创建后建映射→**S2** Phase 状态变更后紧邻同步→**S3** `[plan-sync]` hook 提醒立即回写→**S4** 会话结束前终态同步+`--index`→**S5** 用户新指令影响计划后先改计划再重映射。映射规则与响应协议详见 `references/todo-sync.md`；触发：执行 Todo 同步 S1-S5、处理 [plan-sync] 提醒或核对映射规则时；关键词：Todo同步 S1-S5 plan-sync 映射。S1 两组结构（任务组+基线组 B1-B18，Rule 106.5）详见 references/todo-sync.md；触发：创建/核对基线 Todo B1-B18 结构时；关键词：基线Todo B1-B18 结构；B9-B11 的完成以 `git-baseline.sh` 写入的 sidecar 证据为准，非 todo 勾选（2026-11-24 task-session-regression-20261124）；B14 = 根因/风险线索包已落盘 + 后续任务已登记（非修复类标 N/A + 证据）；B12/B13 归方案A/H3（SP/OS 技能到达 + Spec 路由命中），两组语义不重叠。B16 = 合并回主分支+合并后回归核验（merge --no-ff/worktree 清理/selftest 不增 FAIL），合并证据读 plan-state.json 的 isolation.merge_back。B17 = 口径对齐（交付前拉平触及的过期计数与冲突条款，冲突锚 grep 无新增命中，证据 `[align-final]`）；B18 = 垃圾清理（Skill 说明 Markdown 历史旁注清理；代码注释保护不清理，证据 `[cleanup-final]`）[2026-11-25 task-skill-deploy-fix A7]।

### 🆕 用户新指令处理（计划影响判定 — 强制）

> **两段式拆分判定（同「计划制作循环」P0 条款，单一口径）**：新指令进入实现/修复/优化路径时，在 ② 判定前先过两段式拆分判定。修复类（报错/改错/bug/回归/异常）与非修复类均分两阶段（D1' 分级全覆盖）：阶段一快修表层/产出可用结果→VC 复验通过后立即**合并回 master**、**不阻塞**下游；阶段二独立 task-id（`<A-id>-rc`）新 worktree 从底层根治/同族排雷，双向 tag `rootcause-followup:<B-id>` / `followup-of:<A-id>`。**修复类命中 L0/mini/trivial/L0-E 一律先升 L1 standard 复核再走两段式**。阶段二启动四要素（D5）：执行者=阶段一主进程；触发=阶段一合并回 master 完成且 VC 复验通过后同轮；命令=`git worktree add <项目根>/tmp/worktrees/<A-id>-rc -b wt/<A-id>-rc master`（`--base master`）；失败=仅 INDEX/tag 登记 `pending`（`followup-of:<A-id>`），不改阶段一 outcome、不回滚。

**新指令统一收口序列（强制，单入口定序）**：① 逐字落盘 user-session-log.md（80.1，含理解镜像 80.7）→ ①a 入站字面/语义筛查（同音错字/专有名词/语义合理性，逐字对照追加登记，唯一合理修正自主执行不问用户；歧义影响目标/范围才确认）→ 入站指令筛查细则（按需加载）→ 详见 references/plan-workflow-details.md §inbound-instruction-screen；触发：收到用户新指令需做字面/语义筛查或疑似误发预检时；关键词：入站筛查 误发 语义 预检 → ② D/A/B/C/E 判定（判定前先过 8.1.2 入站预检：疑似误发/项目定位明显错位 → 先分析偏移点并询问是否纠正，再判定；下表；A 类无影响=走 ①② 后登记一行即完成，③-⑤ 仅 B/C/D/E 适用；E 类目标切换先过确认门、用户 yes 后按 D 处置再进序列）→ ③ **指令理解迭代（Rule 28.2.2，执行前方向对齐）**：完成 3-4 轮理解迭代草稿（原始指令复述→模型理解[目标/范围/约束/不做什么]→模型思路与候选+歧义门控→大体执行方向，粗稿非定稿）并按模式处理。**goal/目标迭代（28.8）优先覆盖**：无论明确或歧义/多候选，**禁止**向用户提问/列选项请求确认/等待回复，直接按推荐项或可逆安全默认静默自决并留痕后继续（歧义仅内收敛+登记假设），同问禁复发（预算外硬门按 28.9② 登记待授权清单后继续，不停表；续推与授权到达按 28.9③-⑦）。**非 goal**：ask 模式展示供早纠偏，无实质歧义时不因本模块新增阻塞确认（提示可纠偏后继续），有歧义/多候选(典型3-4)时才按选项确认（28.3）；silent/44.3 自动通过/mini 缺省 silent 下不阻塞等待，收敛并留痕且歧义按推荐项与可逆安全默认自决→ ④ 计划文档同步（task_plan/progress/需求锚）→ ⑤ Todo S5 重映射 → ⑥ 触发修改轮时衔接 Rule 103.6 同步完整性审查。两义务一体执行、顺序不可倒置（记录先于转译，防转译覆盖原话）；禁拆散单做（漏序=缺口）。

**意图切换快速判定卡（新指令首动作，先于 A/B/C 细分）**：⓪ 前置预检（8.1.2）：指令任务类型/交付物与项目定位、当前任务域、最近原话三源比对——明显错位或疑似误发 → 先输出≤5 行分析（意图+偏移点）并询问是否纠正（澄清优先，86.4 三件套），确认后回落下方判定；无错位 → 直接进判定（[align-scan] 留痕）。提取新指令的「Goal/范围/交付物」三要素，与当前活跃计划 Goal 行及 user-session-log.md 最新原话比对——三要素均无交集 → 立即判 **D 类新任务边界**，按下方「意图切换执行清单」处置（禁吸收进当前计划）；含可判定换目标信号（新站点/域名/新对象词/宾语变更）→ **E 类**先确认再切换；有交集 → 回落 A/B/C 常规判定。

| 类 | 判定 | 强制动作 |
|----|------|----------|
| D 新任务边界 | 与当前计划 Goal/范围/交付物均无关联（Rule 8.1） | **开新计划** `plans/{new-task-id}/`（init 全流程）；旧计划原样保留（不标 superseded）；判定落 notepad+Decisions；禁混入当前计划 |
| A 无影响 | 闲聊/追问/与当前计划无关 | 正常执行，不改计划 |
| B 扩展 | 新需求/加范围/改交付物 | 先重规划（Rule 74 三判门+变更标注表）→ S5 同步 Todo→复述变更→再执行 |
| C 矛盾 | 与已确认计划/VC/用户先前决策冲突 | 停止写入：更新计划中被推翻部分（标 superseded）→同步 Todo→展示新旧对比获确认后执行；记录面按 Rule 98 触发面整理（`Skill("context-corrector")`，98.3 组织先于继续） |

  → 意图切换模板细则（按需加载）→ 详见 references/plan-workflow-details.md §intent-switch-templates；触发：判定 D/E 类意图切换、需要切换通告模板或回切检查时；关键词：意图切换 D类 E类 模板 回切

**判定顺序**：先 D 再 A/B/C（指令与目标有关联哪怕小→回退 A/B/C）；仅存在活跃计划时 D 类适用。B/C 变更前过 Rule 73.2 对齐三问+[align] 行，处理完再派 drift-checker。**稳定性铁律**：禁止"口头接受新指令、计划与 Todo 不动"。用户指出错误（Rule 31）→先 STOP 走 31.2 四维归因再修（完整闭环见 task-discipline Rule 31/32/33/74）。命中 Rule 98 触发面（用户否定 ∨ 自主前后文矛盾）→ 调用 `Skill("context-corrector")` 整理上下文与历史文档（记录面专职 SOP，98.3 组织先于继续）。

**目标切换判定（E 类，P0 铁律）**：用户指令命中以下任一**可判定**条件 = 目标切换 = **scope 扩张动作** → **禁止自行归类为 D/A/B/C 并执行**，必须先复述解读 + 等用户显式 yes（D1 门控）：① 指令含**新站点/域名/平台名词**，与当前活跃计划 Goal 的站点/域名词**零交集**（实体提取：Goal 行 + 指令中的域名/站点名/产品名）；② 指令含**指示词**（「其他」「另外」「换个」「别的」「新的」）+ **新对象词**，且该新对象词与当前计划 Goal **零交集**；③ 指令的**宾语**从当前计划 Goal 的宾语变为另一宾语（Goal 宾语 = 站点/产品/项目名）。处置：复述「我理解您的指令是 X（切换到 Y），对吗？」→ 等用户 yes → 才可按 D 类开新计划或 B 类扩范围。**禁止**在用户确认前新建计划目录、写 task_plan.md、清哨兵。**确认切换后的处置（Rule 94，2026-10-23）**：确认目标切换后按 Rule 94 任务专注性与计划隔离纪律处置——94.3 询问门可与本类确认合并为一次询问（新开计划隔离执行（推荐）/并入当前计划重规划/暂挂当前计划），同意拆分则按 94.4 隔离（旧计划封存待 plan-resume、新目标独立 init、跨计划禁交叉写入）；封存=挂起登记+删除旧计划 `.session-owner` 释放会话占用（回切 attest 口径同 D 类①），禁把新目标就地吸收进当前计划。Why: RCA 缺失环节 1——D5 歧义条款与 D/A/B/C 判定均为 LLM 行为门，机器不可判，含糊指令被宽泛归类后 agent 直接执行；本条给出**可判定的触发条件**（换站点/换目标域/新目标实体词），把「目标切换」从模糊判定中抽出为独立可判类别，在「新建计划」前强制停下确认。与宪法 §四 P0-1（用户说 A 做 A）和 §二（规划先行）绑定。

### 🔀 冲突分析与工作树隔离（默认首选）

**实现类任务一律首选 git worktree 隔离**——本仓多为运行中基础设施（skills/hooks/config 被所有会话实时使用），直接改动有半残风险；仅纯文档/调研类（只写 plans/ 与 .md）可直接开发。初始化 `bash scripts/check-conflicts.sh`（五类冲突信号）→ 隔离决策写入 task_plan「🔀 隔离决策」并**默认按隔离执行，不就该安全默认向用户发起确认/询问**；仅当用户**显式**要求“直接改不用 worktree”且命中 AGENTS.md §11.5 豁免条件时才直改并登记理由。**创建前先 git 备份主仓未提交改动**（推荐 `git -C <project> stash push -u -m "pre-wt-backup:<task-id>" -- . ':(exclude)plans' ':(exclude)tmp'`，引用登记隔离决策；已干净则跳过）以稳定基线并利于合并回。隔离期间 CWD 不迁移、文件操作用 worktree 绝对路径、计划文档留主仓 plans/；**worktree 执行期不因并行冲突/Rule 23 `[conflict]` 注入而中断或询问，冲突仅记录、统一延后至合并回阶段**（`smart-merge-back.sh` V3/V5/V6 + Rule 101.2）解决。完成合并：全 VC 复验→`bash <skill>/scripts/smart-merge-back.sh <worktree-path> [--deploy]`→清理 worktree/分支→主仓 Read 复验（按需恢复备份前先重跑同落点盘点）。合约详见 `references/worktree-isolation.md`；触发：创建/使用/合并 worktree 隔离区或判定隔离豁免时；关键词：worktree 隔离 合并回 check-conflicts 豁免

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
| plan-template-kit | 模板生命周期与难度分级 | `../plan-template-kit/references/critical-rules-template.md` | 模板选取/沉淀入库/难度分级/轻量档判定（Rule 16,34,37,38） |
| plan-collab-router | 技能协同与工具面选择 | `../plan-collab-router/references/critical-rules-collab.md` | comet/OpenSpec/superpowers/dynamic-workflows 路由（Rule 39,40,91） |
| plan-cost-guard | 成本控制 | `../plan-cost-guard/references/critical-rules-cost.md` | opus 频次/嵌套成本/成本门控（Rule 17） |
| plan-resume | 计划续推 | `../plan-resume/references/critical-rules-resume.md` | 交付终态/会话恢复触发点扫描与自主续推（Rule 24） |
| progress-tracker | 共享内容认领 | `../progress-tracker/references/critical-rules-progress.md` | 跨任务共享内容认领追踪/进度复用（Rule 30） |
| task-drift-guard | 漂移检测与偏移留痕 | `../task-drift-guard/references/critical-rules-drift.md` | 漂移检测/偏移检查子代理化/周期回顾节奏（Rule 11,15,61,64） |
| verification-gate | 任务验证全链路 | `../verification-gate/references/critical-rules-verification.md` | VC 可执行化设计/执行期 V-N 校验/终验 VC 复验/子代理验证/统一验证入口（Rule 84,108） |

## Critical Rules 指针（核心域）

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

详见卫星 `verification-gate` `../verification-gate/references/critical-rules-verification.md` Rule 84.4（2026-10-14 task-v173 从 completion-gate.md 迁移）；触发：子代理返回 done 后需验收产出或查 completion-gate 规则时；关键词：子代理验收 completion-gate Rule84.4 Read验证。subagent 返回 "done" 后必须 Read 实际文件验证变更，才能标记 complete。

## Scope Guard / Goal Gate

- **Scope Guard**：`check-scope.sh Write "<file>" task_plan.md` → exit 0=放行 / 1=拦截 / 2=no plan。**口径更正（P7，2026-10-22 用户授权）**：`scope_files` 约束**不由运行时停摆门承载**——实测 `check-scope.sh`/`check-delegation.sh` 均无 scope_files 运行时拦截逻辑（grep 零命中），原表述「不在 scope→停，获授权扩 scope」是死文，会诱导执行体按不存在的门停摆请示；实际约束由三处承载：① 主进程派发前的范围声明（Executor/scope_files 字段）② 收口审计 ③ `git show --stat` 越界自检。scope 越界的唯一合法出口=收口审计发现越界后按 Rule 74 变更标注表处理，不是执行期停下问用户。
- **Goal Gate**：每个 `task_plan.md` 必须含 **Verification Contract**（VC 表），每项含可执行验证命令（Rule 84.1）。详见卫星 `verification-gate` `../verification-gate/references/critical-rules-verification.md` Rule 84.3（2026-10-14 task-v173 从 goal-gate.md 迁移）；触发：编写/审查 VC 表或查 goal-gate 规则时；关键词：GoalGate VC 验证契约 Rule84.3

## I/O 契约

输入=任务描述/CWD/已有 plan（恢复时用）；输出=规划→理解迭代草稿（28.2.2，3-4轮：明确免无价值确认、歧义/多候选才确认）+plan+思路复述（28.2.1，ask 模式）/执行→checkbox+错误/完成→全部 [x]+验证。`config.json#escalation_threshold` 次失败→AskUserQuestion（交互模式语义见 Rule 28；goal 语境不 AskUser，按 28.9⑧ 终点覆盖）。示例：`mkdir -p plans/task-001/ && cd $_ && bash <skill>/scripts/init-session.sh "<任务名>"`。机器面=`scripts/schemas/check-delegation-stats.schema.json`（check-delegation stats JSON 契约）+ `scripts/verify_io.sh <plan-dir>`（7 文件在位 + delegation stats JSON 断言，`scripts/selftest-verify-io.sh` 守护，task-v189 F11 修复）

## Chain 模式与协同路由（指针）

`chain_mode` 默认 `single`（单 block）；`linked`（多 skill 串行接力）/`fan-out`（一对多派发，成员按 Rule 21.4 声明组并行）的值语义与 block 交接合约权威源=`reference.md § Chain Handoff Contract`。专业技能协同（comet/OpenSpec/superpowers/dynamic-workflows）权威源=`../plan-collab-router/references/skill-collaboration.md`，主路由 `Skill("plan-collab-router")`；dynamic-workflows 于用户点名 /workflow 或命中 Rule 39.8 编排条件（常设授权）时主动路由——激活按 39.8 三件套（留痕/91.12 分档/83 探测）（Rule 39,40,91）。调研 SOP=卫星 `plan-research-router`（`../plan-research-router/references/research-routing.md`）；模板库=卫星 `plan-template-kit`（本技能 `templates/` 机械层留守）。
Spec 模式路由（2026-11-15 增）：任务整理阶段的专业内容（头脑风暴/规格/变更提案）交 Superpowers（brainstorming 等）与 OpenSpec（propose/apply/verify）执行，task-planner=忠实记录者+调度者。路由表/安装引导/反模式见 `references/spec-mode.md`；触发：计划进入任务整理阶段需判定是否启用 Spec 模式、查阅 Superpowers/OpenSpec 路由表或安装引导/反模式时；关键词：Spec模式 Superpowers OpenSpec 路由 规格提案。（跨技能优先级以 plan-collab-router 权威源 skill-collaboration.md 为准，本行只细化 Spec 模式场景）

## 派发与执行纪律指针（卫星 authoritative）

- **子代理派发/路由表/模型档位/超时兜底/返回校验/代码编辑隔离/provider 故障 scaling/hook 自愈** → 卫星 `task-dispatch`（SKILL.md+`../task-dispatch/references/agent-coverage.md` 覆盖矩阵+`../task-dispatch/references/split-pattern-library.md` 模式库；五档兜底=改派→拆细→降档→接管→AskUser）
- **执行纪律/错误闭环/批量质量门控（batch-quality-gate.md）/反思验证/注释规范/可靠性/能力落盘/上下文压力/用户否决/决策分级/变更吸收/上下文记录整理触发（Rule 98）/跨项目跨目录操作授权（Rule 99）/临时目录统一与工作树内放（Rule 100）/git 使用加强（Rule 101）/可枚举集合全量枚举优先（Rule 105）** → 卫星 `task-discipline`
- **媒体制作/单元线并行/内容权重分级** → 卫星 `media-planner`
- 主进程铁律摘要：任务执行一律 `Agent()` 派发（白名单外 Write/Edit 被 `check-delegation.sh` 拦截，enforce=exit 2）；bypass 仅显式 `allow-direct.sh on --confirm-user-requested`；六项白名单全文见 task-dispatch Rule 25.3
- **子代理激活默认档/模型分档/并行硬标注/同消息并发/指标留痕** → 卫星 task-dispatch Rule 96（七类触发类别默认派发；主进程直做=窄白名单登记例外；≥2 个无依赖 S-unit 必须声明并行组；并行组成员同消息并发派发；交付报告激活子代理数与最大并行宽度）
- **声明源通用消费与本地调研通道（Rule 115）** → research-channels 技能（`project-inventory.sh` 索引第 0 步）+ core Rule 115 + discipline 101.5/B20；计划期 spec-scan 源扫描 + check-spec-baseline `[source-gate]`；终验 `--final` + diff 对账 `[diff-disposition]/[source-waiver]`

## 结构化状态操作 SOP（JSON 权威源）

> [2026-11-21 task-json-state-20261121] 结构化状态升级硬条款；与上文「派发与执行纪律指针」并列，适用于所有使用 task-planner 的计划目录。

- **权威源声明**：`<plan-dir>/plan-state.json` 是任务状态**唯一权威源**，承载全部语义数据（Phase/VC/审计/派发 + Actions/Error Log/Test Results/Research/Decisions/Issues/S-units/FMEA 等全部语义段，2026-11-22 task-jsonderive-deploy-20261122 全量扩张）；`task_plan.md` / `progress.md` / `verification.md` / `findings.md` 是由 `planctl.py render` 从 JSON **全量派生**的只读视图。模板维度同理：`template_doc`（结构化模板载荷）+ `template_checks`（勾选唯一权威源）+ `template_ref` 同在 plan-state.json 内，`task_plan.md` 的领域段与 `- [x]` 勾态均为 render 派生（2026-11-25 task-json-template-docs）。
- **硬规则（违反=流程无效）**：所有状态与语义数据变更**必须**通过 `python3 <skill>/scripts/planctl.py <subcommand>` 完成（`<skill>` = 本技能根目录，脚本绝对路径 `scripts/planctl.py`）；**四个 MD 视图一律不得手工 Edit/Write**——手工编辑会在下一次 `render` 被全量覆盖（软堵：render 覆盖使直接编辑无效，用户裁决 2026-11-22）。语义内容（动作/错误/测试/结论/决策/证据）同样走 CLI 入 JSON 再 `render` 同步视图。
- **常用命令速查**（每条均需追加 `--plan-dir <plan-dir>`）：
  - 初始化：`init --task-id <id> --tier standard --lane L1 [--template-json <templates/json/*.template.json>]`（tier 可选 standard/mini；lane 可选 L0/L1/L2；state 已存在则拒绝覆盖；init 只建权威源不 render，首次数据写入后必须 render；JSON 模板为源，`plan-state.json` 的 `template_doc/template_checks` 为权威，`task_plan.md` 为 render 派生视图；`--template-body-from` 仅旧计划兼容（deprecated，禁与新计划同传），mini 档豁免领域勾选）
  - 读取：`get`（整份）/ `get --section <section> --id <id>` / `status` / `validate`
  - 改字段 / 增条目：`set --section <s> --id <id> --field <f> --value <v>` / `add --section <s> --json '<JSON>'`（另有 `update` / `delete`；`set` 不带 `--section` 可写顶层标量/对象字段）
  - 结构化勾选读取：`get --section template_checks`（勾态权威数组，含 id/section/block/text/checked/note/tags）；整份模板载荷 `get --section template_doc`（2026-11-25 task-json-template-docs）
  - 勾选项编辑（唯一入口）：`set --section template_checks --id <id> --field checked --value true`（或 `false`；`checked` 严格 bool，字符串拒收）→ `render`；手改 MD 勾态无效（门控按 JSON 负控制判定）
  - Phase / VC：`phase-start --id P1`（置 in_progress+Started 锚）/ `phase-done --id P1` / `vc-pass --id VC-1` / `vc-fail --id VC-1`
  - 规范候选扫描（计划期）：`python3 <skill>/scripts/planctl.py spec-scan --plan-dir <dir> --write` 扫描规范候选并逐条处置 SRC/NA，收据 `[spec-scan]`（22.4e） spec-scan 会按 config/spec-registry.tsv 维度别名归纳候选源（suggest_dims 落 .spec-scan.tsv）；项目可经 <repo-root>/.spec-registry.tsv 声明自有内容类模板/执行体与新维度（零代码扩展）
  - **调研第 0 步（Rule 115.1）**：任何调研动作前先 `bash research-channels/scripts/project-inventory.sh --root <repo-root> [--check]`（research-channels 技能）建立项目内外源索引；索引外=未探索区显形。五层通道失败纪律=当轮换层+留证据，五层穷尽才可声明受限（core Rule 115.2）。
  - 规范携带块（派发期）：`python3 <skill>/scripts/planctl.py spec-brief --plan-dir <dir> --sunit S<n>` 输出规范携带块，原样入派发 prompt（22.4e）；派发同时携带必保锚词/排除面（core Rule 115.4/114.8，discipline B20）。
  → planctl JSON 命令示例（按需加载）→ 详见 references/plan-workflow-details.md §planctl-json-examples；触发：需要 planctl add/set/spec-scan/spec-brief 的 JSON 示例或参数写法时；关键词：planctl JSON 示例 add set spec-scan
  - 生成视图 / 安全回退：`render`（从 JSON **全量重建** 4 个 MD 视图；**每次状态/语义变更后必须 render**，这是软堵生效条件——不 render 则手工编辑残留不被覆盖）/ `backup` / `restore [--version N]` / `history`
- **安全说明**：每次写操作自动备份权威源到 `<plan-dir>/.history/`（保留最近 20 版），改坏可 `restore`；错误操作不破坏旧版，禁止手工删除/改写 `.history/`。
- **机器门**：`python3 scripts/planctl.py check vc-nonvacuous|rvc|audit|evidence` 输出单行 `PLANCTL CHECK <name>: PASS|FAIL <reason>`，rc 0=PASS / 1=FAIL / 2=输入异常；旧门脚本为双读 shim，前缀与 rc 外契约不变。
  → 跨任务共用待办（项目根 `todo.json` 的唯一写入口；发现未结问题或统计已解决/未解决项时必用）→ 详见 examples/shared-todo/review.md；触发：执行/修 bug/扫描/审查中发现未解决的问题需要登记，需要统计跨任务未结与已结条目时，或用户说「检查一下还有什么任务没有解决/帮我推进/清理已完成计划/更新跟进状态」时；关键词：todo.json 待办 未解决 登记 todoctl 推进 退场 跟进
  - 跨任务待办命令（Rule 117）：`python3 <skill>/scripts/todoctl.py add --title "<问题>" --source-type task --ref findings.md:L12 --root <repo-root>` 登记；`todoctl.py stats` / `list` 统计与查看；`check` 单行 `TODOCTL CHECK schema: PASS|FAIL`。**禁手改 `todo.json`**（唯一写入口=CLI），已解决项保留不删以支撑统计。
  - 消费闭环（Rule 117.8-117.11）：`python3 <skill>/scripts/todoctl.py review --root <repo-root>` 报未结/陈旧/待退场候选；`todoctl.py next` 按优先级+创建时间确定性选一条并报告（只读，不自动建计划），选中后按本技能常规流程建计划推进；完成后 `todoctl.py resolve <id>`；清理已完成计划用 `todoctl.py retire --root <repo-root>`（默认 dry-run，`--execute` 才归档，复用 archive-plan 守卫）。
- **输出示例生成器（Rule 113.9）**：`python3 scripts/render-output-example.py --set id=OE-1 --set deliverable=article.json --set format=JSON --example-file <完整示例文件> --template-file <占位符模板文件> --vc-ref VC-1 --out oe-1.json [--plan-dir <计划目录>] [--dry-run]` —— CLI 传参填充 `templates/output-example.template.json`（`{{KEY}}` 占位符），产出符合 `output_example_item` 契约的 JSON 文件；产物经 `planctl add --section output_examples --json` 落库并 render 派生。
- **迁移期**：存量无 `plan-state.json` 的旧计划一次性兼容（机器门双读 fallback 保证零回归），**新计划一律 JSON 权威源**：`init-session.sh` 创建 plan-state.json（不 render）；**首次 planctl 数据写入后必须 `render`**——此后 4 个 MD 即为派生视图，手工编辑被后续 render 覆盖（软堵）。templates/*.md 为 plan-writer 过渡结构参考与 stub 判定基准（全量回归 PT-16/26 实证：空数据 render 会覆盖模板骨架，故 init 不自动 render）。
  → planctl 四件套与备份恢复细则（按需加载）→ 详见 references/plan-workflow-details.md §planctl-four-piece；触发：需要 planctl init/render/backup/restore 全流程或迁移期说明时；关键词：planctl 四件套 render backup restore

### 📐 JSON 原生模板（结构化源 + 勾选负控制 — task-json-template-20261125）

<!-- [2026-11-25 task-json-template-docs] What: 补写 JSON 模板权威源、勾选编辑入口与门控负控制口径；Why: 此前技能正文仅留 1 行注释，端点执行体仍按「整份 MD 读进 Python」旧路径操作，手改勾选被 render 覆盖却无从判断，故把已落地机制写进入口权重区。 -->

- **模板源路径**：`templates/json/<type>.template.json`（33 个）。选型仍先跑 `scripts/template-catalog.sh list --json --scope all`，`source=json` 为权威首选、`source=legacy` 为旧 MD 兼容；`templates/variant/*.md` 降级为教学/展示视图，不再作为「整份 MD 读入 Python」的数据源。
- **结构要点**：`{schema_version:1, meta:{template_type,name,summary,scenarios,features,lineage{level,parent,base,spec_version,pruned,pruned_reason}}, sections:[{id,anchor,level,kind:ref|blocks,required,ref?:{path,renderer},blocks?:[{id,kind:markdown|checklist|table|raw,...}]}]}`。`kind=ref` 由 planctl 既有核心渲染器填值；`kind=blocks` 按 `anchor` 顺序追加；`checklist.items[].id/text/checked` 是勾选条目来源。
- **派生登记**：`meta.lineage` 记录 `level/parent/base/spec_version/pruned/pruned_reason`；二级派生须 `parent`+`base` 双参照，裁剪区块在 `pruned[]` 显式登记并写 `pruned_reason`（Rule 34.5），核心区块未经豁免禁静默丢失。
- **转换工具**：`scripts/template-catalog.sh to-json [--dry-run|--write]`（33 个 MD 骨架→JSON；默认 dry-run 只列源→目标与字段计数，拒绝部分转换，`--write` 才落盘）；新增/改造类型先用它核对 JSON 源，再交 `init --template-json` 消费。
- **落位与权威**：`planctl init --template-json <path>` 写 `template_ref`（仓内相对路径）/`template_doc`（仅 meta+sections）/`template_checks`（所有 checklist items 扁平化，id 重复即 fail-loud 拒绝）；新计划禁写 `template_body`，`render` 不吐旧模板附录。
- **勾选编辑（唯一入口）**：`get --section template_checks` 读权威勾态 → `set --section template_checks --id <id> --field checked --value true|false` → `render`。**手改 `task_plan.md` 的 `- [x]` 无效**：下一次 render 全量覆盖，判定一律按 JSON；门控负控制见下条。
- **门控负控制**：`check-state-consistency.sh` 等门先读 `plan-state.json` 的 `template_checks`；JSON 存在但 planctl 缺失/解析异常=FAIL 且**禁回退 MD**；勾态与渲染视图不一致报 `[state-mismatch]`（提示改用 set checked + render）。仅当无 JSON 时才回退旧 MD 正则，保证存量计划零回归。
- **旧计划兼容边界**：`--template-body-from` 仅供无 JSON 的旧计划使用（deprecated，禁与 `--template-json` 同传）；旧 `template_body` 仅在无 `template_doc` 时以附录呈现；新计划一律 JSON 权威源，MD 模板不作为状态/勾选写入面。

  → 脚本索引细则（按需加载）→ 详见 references/plan-workflow-details.md §script-index；触发：查找 task-planner scripts/ 下某脚本用途、入口参数或调用时机时；关键词：脚本索引 scripts 用途 参数
## References

| 文档 | 用途 |
|------|------|
  → 参考文档表细则（按需加载）→ 详见 references/plan-workflow-details.md §references-table；触发：查找 references/templates/外部 skill 的用途与读取时机时；关键词：参考文档 references 模板 索引
| `references/critical-rules.md` | Critical Rules 核心域 1-117 全集索引（20 条核心全文+分层架构说明+卫星路由索引）；触发：查规则编号、判定规则归属域、核对核心/卫星边界时；关键词：规则 索引 Rule 归属 核心 卫星 |
| `templates/delivery-summary.md` | 终验交付总结五要素模板；触发：终验交付需要输出五要素总结或填写交付摘要时；关键词：交付总结 模板 五要素 delivery |
| `../plan-collab-router/references/skill-collaboration.md` | 专业技能协同路由权威源；触发：任务涉及 comet/OpenSpec/superpowers/dynamic-workflows 协同路由时；关键词：协同路由 comet OpenSpec superpowers workflow |
| `../research-channels/SKILL.md` | 声明源通用消费与本地调研通道（Rule 115）：project-inventory 索引第 0 步、五层通道失败纪律、源注册表消费 |
| `references/longform-continuity-methodology.md` | 长篇连续性方法论（T1-T5 应用于长文/连载创作，按需加载）；触发：长篇/连载/多章节内容创作任务需要创作连续性方法论支撑时；关键词：长篇 连载 章节 连续性 方法论 |
| 外部 skill/agent | `drift-checker`（Rule 61）/`decision-arbiter`（Rule 69）/`Skill("plan-resume")`（Rule 24）/`Skill("progress-tracker")`（Rule 30）/`code-quality-review` skill |
