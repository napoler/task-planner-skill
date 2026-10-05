---
name: task-planner
agent: executor
description: Use when planning, decomposing, or organizing multi-step projects or research tasks expected to require more than 5 tool calls. Also use when resuming work after /clear.
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TodoWrite, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, WebSearch, WebFetch"
user-invocable: true
references:
- reference.md: Manus context engineering 原则 + 3-Strike + 5Q + Chain Handoff Contract 合约 + Chain Handoff Contract 重规划触发条件
- references/critical-rules.md: Critical Rules 全集 1-53（1-12 核心执行约束 + 13-28 高级门控 + 29-35 维护/追踪/学习/防倒退/反思/模板生命周期门控/执行结论纪律 + 36 技能修改保守化、37 任务类型机制画像、38 任务难度分级与轻量档、39 动态工作流编排、40 harness 工具面主动选择、41 问题自主消解与升级纪律、42 质量审查技能主动检测与补充、43 执行可靠性制度化、44 用户选择点默认项与自动超时裁决、45 注释完整性规范、46 子代理单任务专注度、47 媒体制作任务派发纪律、48 交付总结可定位性与实用性、49 单元线多路并行推进、50 内容要求权重分级与评级、51 需求覆盖与完成声称门控，含 Rule 27 git 提交强制、Rule 28 交互模式与询问门控、Rule 31 错误学习闭环、Rule 32 用户否决与禁令追踪、Rule 33 解决→反思→验证迭代循环、Rule 34 模板生命周期门控、Rule 35 执行结论纪律、Rule 36 技能修改保守化与功能删除防护）
- examples.md: 完整执行示例（调研/bugfix/功能开发/错误恢复）
- references/completion-gate.md: 子代理验证 + 串行同步
- references/goal-gate.md: Goal Gate + VC 规则 + 退出标准
- references/todo-sync.md: 原生 Todo 同步契约（S1-S5 强制同步时机 + 映射规则 + hook 提醒响应协议）
- references/worktree-isolation.md: 冲突分析与工作树隔离契约（实现类默认首选 + 合并回合约）
- 卫星技能 plan-cost-guard: 成本控制与计费知识库（cost-control/billing/cost_log 已迁至其 references/，Rule 17 场景经 Skill() 调用）
- references/batch-quality-gate.md: 批量处理质量门控详解（Rule 18 详解：前置 3 问 + 双采样 + Batch Report）
- 卫星技能 plan-template-kit: 模板选型/定制/沉淀知识库（template-mapping/template-guide 已迁至其 references/，Rule 16/34 经 Skill() 调用）
# hooks: <TOOL-ADAPTED — stub files per tool register hooks via platform-specific config>
# See: ~/.claude/skills/task-planner/SKILL.md (Claude Code) / ~/.zcode/skills/task-planner/SKILL.md (ZCode)
model: opus
---

**[P0]** 禁止跨项目污染 · 禁止虚构 · 修改前必须 Read 并展示 diff · 技能文件修改需逐项授权。发现缺失=STOP 报告，禁止补全。

**Goal**：产出结构化 `task_plan.md`（含 Phases/VC/V-N），按 phase 推进，全 phase complete 后逐条复验 VC，交付 COMPLETE/PARTIAL/BLOCKED。

## 主进程=调度管理器（最关键定位，三条铁律）

> **核心定位**：主进程 = **调度管理器（scheduler/orchestrator）**——只做规划、拆分、派发、验收、簿记；任务执行一律下沉子代理。**降低主进程亲自执行是本技能的第一设计目标，新场景默认派子代理。**

**三条铁律（执行期硬约束 — task-v055 已机制化）**：
1. **白名单外 Write/Edit 被 PreToolUse hook `check-delegation.sh` 拦截**（enforce 档 = `exit 2`；warn 档 = 注入警告并计数）
2. **任务执行一律 `Agent()` 派发**（Executor≠主进程时立即按 Rule 22.4 九字段模板逐 S-unit 派发 + Handoff 登记；prompt 必含计划三文件绝对路径(22.4a)与 8 字段严格返回模板(22.4b)，Agent 调用受 check-dispatch.sh 守卫(22.4c)）
3. **bypass 仅来自显式 `allow-direct.sh on --confirm-user-requested`**（30 分钟窗口 + ledger 记录 + 终验展示；同 sid 仅一次 `/tmp/task-planner-bypass-<sid>`；同 plan-dir 二次 bypass 需 `--force`）

**六项白名单（精简版，权威源 `references/critical-rules.md` Rule 25.3）**：① 纯 git/worktree 编排 ② 计划系统文件维护（三件套/INDEX/ledger/attest/plan 模板） ③ 机械验证命令（只读，输出可控） ④ 用户显式要求主进程亲为 ⑤ Rule 22.3 兜底接管（单文件 ≤300 行） ⑥ 单文件 ≤3 行 trivial 修改（非保护区）。

**[CONTEXT]** 上游：用户任务描述 / CWD / 已有 plan 目录。下游：`plans/{task-id}/task_plan.md` + findings.md/progress.md/verification.md。

**工具**：`Read`/`Write`/`Edit`（计划文件）、`Bash`（脚本）、`Glob`/`Grep`（搜索）、`Agent()`（子代理）、`Skill()`（外部 skill）、`TodoWrite`/`TaskCreate/Update/List`（原生 Todo 同步，契约见 references/todo-sync.md）。

**Code Review 工具**：当 `task_plan.md` 声明 `code_review: required` 时，启用 `Skill("code-review")` 上下文隔离审查（在终验交付前触发）。详见 [Code Review Gate](#code-review-gate代码审查门控)。

### 🤝 专业技能协同路由（comet / OpenSpec / superpowers / dynamic-workflows — 权威源 ../plan-collab-router/references/skill-collaboration.md）

主路由 = `Skill("plan-collab-router")`（知识库→`../plan-collab-router/references/skill-collaboration.md`）。**判定顺序敏感先命中先用**：comet → OpenSpec → superpowers（多族命中=叠加协同；comet 移交=任意 3 项命中（Phase ≥5 / 跨模块 / 需架构选型 / 需三件套归档 / 跨会话续做）即建议移交 `/comet`）；**CLI 探针前置** `command -v comet` / `command -v openspec` 缺失则该族不可接管，开关键 `config.json#skill_collab_enforce`（默认 warn）；**22.3.3 卡壳接管**：④ 主进程接管不可行/仍失败 → 先评估更适配专业族接管（comet / openspec-propose / superpowers），失败才落 ⑤ AskUser/STOP。
- **dynamic-workflows（用户显式点名 /workflow 才路由，Rule 39）**：用户显式调用 `/workflow` 或明确措辞要求 workflow 编排 → 先 `Skill("dynamic-workflows")` 加载再 `CreateWorkflow` 编排；未点名一律按既有 Rule 21.4 调度铁律 Agent 派发（独立性守门：声明并行组内可并行、未声明组=串行，10-02；Rule 39.1 触发纪律；四机制映射见 `references/critical-rules.md` Rule 39）。
- **Rule 40 计划期工具面主动选择（harness 工具面清单+🧰 区块+/goal 对齐，Rule 40）**：计划期在「🧰 工具选择与编排」区块逐 Phase 登记执行工具面与选择理由（六类工具面清单见 critical-rules.md Rule 40.1）；分析命中编排条件（独立并行子任务/fan-out/长链复用）时按 Rule 39.4 登记建议 CreateWorkflow（Rule 39.1 显式点名红线不变）；/goal 对齐仅做映射指引（用户侧 harness 命令技能不可代调，40.3 如实披露）；mini 档豁免（Rule 38.3）。

> 路径约定：本文件中 scripts/…、references/…、templates/… 等相对路径均相对技能根目录（本 SKILL.md 所在目录）。

## 执行流程图

- [ ] **初始化（哨兵机制）**
  > `[2026-09-10 task-planrequired-race] 哨兵会话私有化`：SessionStart 写会话私有哨兵 `plans/.plan_required_side/<sidkey>.plan_required`（sidkey=uuid core，剥 sess 前缀；写入位置=向上解析的 plans/ 祖先项目根，无 plans/ 祖先不写；sid 缺失不写任何哨兵，fail-open）；legacy `<root>/.plan-required` 不再写入、仅作兼容读取
  - SessionStart hook 自动写入本会话私有哨兵（标记"本会话尚未创建计划"；resume 判定：本会话 side 指针已指向有效计划则哨兵不启用）
  - 运行 `bun scripts/session-catchup.ts` 检测中断恢复点
  - 创建 `plans/{task-id}/` 目录，运行 `bash scripts/init-session.sh`（trivial 判定：预估 ≤15min ∧ scope ≤2 文件 ∧ 单模块 ∧ 非④排除（保护区/Rule 36/D6 高危）→ 前置 env `TASK_AUTO_TIER=1 TASK_EST_MINUTES/TASK_SCOPE_FILES/TASK_SCOPE_MODULES` 提交体量事实，脚本四条件闸门自动降 mini 并打 `auto_tier: mini` 标记供终验复核，Rule 38.6；显式 tier 恒优先）
  - **会话隔离指针（active-plan-race）**：活跃计划经 `resolve-plan-dir.sh [root] [sid]` 双参解析——会话层 `plans/.active_plan_side/<sid>.active_plan`（UserPromptSubmit hook 按 sid 自动认领，TTL 24h）优先于全局 legacy `plans/.active_plan`（兜底），并行会话不再互顶；残留由 `set-active-plan.sh gc` 清扫（详见 `references/critical-rules.md` Rule 22.9）
  - **模板优先级**（由 init-session.sh 自动处理，无需手动干预）：
    - 优先：`{project}/.claude/plan-templates/{filename}`（项目级覆盖）
    - 兜底：`{platform-home}/skills/task-planner/templates/{filename}`（`~/.zcode` 或 `~/.claude`，内置 5 模板）
    - 定制入口：在项目中创建 `.claude/plan-templates/`（Claude Code）或 `.zcode/plan-templates/`（ZCode）目录，替换任意子文件即可覆盖内置模板
  - **验证**：确认创建了 6 个文件（task_plan.md / findings.md / progress.md / notepad-learnings.md / verification.md / knowledge-brief.md）（task-v116：v067 起第 6 文件，v107 R-01 清账）
  - **冲突分析（隔离决策）**：运行 `bash scripts/check-conflicts.sh` → 结果 + 隔离决策写入 task_plan.md「🔀 隔离决策」区块（实现类任务默认首选 worktree，用户可否决）
  - **S1 同步（原生 Todo 建立映射）**：运行 `bash scripts/sync-todos.sh --json` → 用 `TodoWrite`（跨会话/多任务用 `TaskCreate`）为每个 Phase 建一条 todo（subject=`{task-id}/Phase N: title`，当前 Phase=in_progress，其余 pending）；**禁止只建计划不建 Todo**
  - **清除哨兵**：计划创建完成后立即运行 `node ~/.zcode/skills/task-planner/scripts/plan-created.cjs`（带计划存在性验证，无计划仍 exit 1；双清除：本会话 side 哨兵 + legacy 残留）
  - **门控**：本会话哨兵存在期间，PreToolUse hook 自动拦截所有非 plans/ 路径的 Write/Edit 操作（exit 2 阻断；ZCode 约定 PreToolUse exit 2 = block）；check-time 自动仲裁（D10）：项目内存在 created 时间戳晚于本会话哨兵的有效 task_plan.md 即放行
  - `[2026-09-10 task-path-identity]` 派发契约路径已身份判定化（stat inode / realpath -m），单拼写即可，混拼写兼容

- [ ] **计划确认**
  - 展示 `task_plan.md`（含 Phase 列表 + Verification Contract 表）给用户
  - **门控**：等待用户显式 `"yes"` — 无授权禁止执行；确认后立即 `bash scripts/attest-plan.sh` 锁定，其内置 `check-plan-dispatch.sh` 校验派发型 Phase 是否已规划子代理（S-unit 执行体列，Rule 22.6/25.1；缺失拒绝锁定，`--skip-dispatch-check` 逃生）
  - **交互模式（Rule 28）**：ask 模式保持本门控，且按 **28.2.1** 在计划全文之后口头复述「大体执行思路」（≤5 行：Phase 序列与一句话目标 / 执行体与模型档位 / 关键门控 D2-D6 与失败兜底路径 / 隔离与合并策略 / 交付节奏与终验方式），使不查计划文档也知大体工作流程——复述是补充，不替代等待显式 yes，复述完成登记 Decisions Made（`思路复述已呈示,<时间>`）；silent 模式本门控自动通过——计划照常 `bash scripts/attest-plan.sh` 锁定后直接执行，无需等待确认；计划全文落盘可查，交付报告须附「静默决策清单」（Decisions Made 表 `silent:` 前缀行）供用户复核；模式解析优先级 env TASK_PLANNER_INTERACTION_MODE > 计划配置表 interaction_mode > config.json > 默认 ask，用户会话中口头切换优先于一切
  - **规则编号预留（Rule 20.6）**：新增 Rule 编号时在计划声明 `new_rule: <NN>`；attest 自动查重登记（账本 `plans/.rule-reservations.jsonl`），冲突时按 `next` 建议改号。

- [ ] **Poka-Yoke 前置条件检查（v063 方法论引入，指针 references/methodology.md §R1/R2/§思维方法论）**：Phase 执行前核对本 Phase 前置条件（依赖文件存在/上 Phase 产物非空/必要配置在位）+ 高风险 Phase（FMEA RPN>100，见 task_plan.md「📊 FMEA 预演」段）是否已登记预设兜底动作；不满足 → 先修前置再继续；开关键 config.json#fmea_enforce（默认 warn）

- [ ] **思维方法论问题解构（task-v084，指针 references/methodology.md §思维方法论 T1-T5）**：计划创建/展示时已按 T1 问题先行三问与 T2 四问完成解构（问题是什么/本质是什么——5 Whys ≥5 层/解决方案是什么/执行方案是什么），答案落 task_plan.md「核心问题定义」+ findings.md；方案候选与 D2 选项按 T3 结论先行并附 T4 推导链；失败侧归因仍走 Rule 31.2（同法不同时）。行为纪律零新开关键，selftest-methodology 守护文本在位

- [ ] **共享内容追踪检查点（Rule 30 — task-v071，设计期 D1 批准后、Phase 执行前）**：核对本任务是否命中 30.1 识别条件（目标资源可枚举且只认领一部分 / 同类任务 ≥3 次）→ 命中则按 30.2 创建/复用项目级共享追踪账本（`Skill("progress-tracker")`，账本位置=项目根平台配置目录 `.zcode/ledger/` 或 `.claude/ledger/` 跟随既有），按 30.3 逐 target 登记认领（in_progress + 认领 task-id + 收尾 Todo），完成时翻 done + effect；30.4 防冲突（他 task 已认领 in_progress → D4 询问）；未命中 → Decisions Made 记 `共享追踪不适用,<理由>`。开关键 `config.json#shared_tracker_enforce`（默认 warn）

- [ ] **Phase 执行循环**（每个 Phase 独立闭环，6 步顺序执行）
  1. **开启 Phase**：`Edit task_plan.md` 当前 Phase 状态 → `in_progress`（Current Phase 同步更新）
  2. **同步 Todo（S2）**：`TodoWrite`/`TaskUpdate` 该 Phase 对应 todo → `in_progress`；步骤 1/2 必须紧邻执行，禁止只做其一
  2.5 **委派检查点（强制 — Rule 25）**：开始实际工作前必查本 Phase `**Executor:**` 字段 → 非"主进程"则**立即按九字段模板（Rule 22.4）逐 S-unit（22.6 表每行一次；单会话单 S-unit（Rule 46.1：一次执行会话只领一行，禁批次追加）；按 Rule 21.4 调度铁律：声明并行组内成员可并行（独立性四问通过）、未声明组=一次验收一组成员再派下一组成员（10-02）；执行体选型先查覆盖矩阵与三登记面（Rule 52.1））`Agent()` 派发**并在 Subagent Handoff 登记表登记，主进程只保留派发/回填三文件/验收 Read；Executor=主进程的 Phase 须已带例外理由，无理由 = 先回炉补记再动；**无 Executor 字段 = 计划无效**，先补字段并重跑 attest（Rule 20.1）。禁止"先自己干，干不动再派"。**hook 已机制化**：主进程白名单外 Write/Edit 被 check-delegation.sh 拦截（enforce=exit 2；warn 档注入警告并计数）；**验收后推进检查（Rule 49）**：每完成一个 S-unit 验收（22.5 三证据），立即核对该单元线下一工序是否满足推进三条件（49.2 已验收+前置在位+独立性四问），满足即派发不等批（跨 Phase 前移按 49.3 双登记，汇合点按 49.4① 等齐）
  2.6 **上下文卫生检查点（Rule 29.1①，每 2 个 Phase complete 触发一次）**：运行 `bash scripts/check-context-hygiene.sh <plan-dir>`（findings/progress 退场扫描，exit 1=有建议）→ 有建议按 29.2 处置（superseded 标记/压缩/progress 折叠，拿不准保留标"待复核"）；工作文件侧（`bash scripts/plan-hygiene.sh <plans-dir>`）在会话恢复时（29.1②）或用户显式指令（29.1③）时运行，--execute 前须先登记 dry-run 清单。开关键 `config.json#context_hygiene_enforce` / `plan_hygiene_enforce`（默认 warn，详见 `references/critical-rules.md` Rule 29）
  3. **执行 Phase 工作**（内嵌 3-File 落盘强制点，Rule 19）：
     - **3a. 子代理产出回填（19.1）**：每次子代理（Explore / research / debugger / codebase-analyzer 等）或调研类 Skill 返回后，**紧邻一次 `Edit findings.md`** 写入结论摘要 + 证据路径（映射见下方「产出落盘映射」）——禁止让结论只留在会话记忆（context reset 即丢失）；回填完成才可勾 Handoff 登记表 `verify_done`（Read 产出 + findings 回填双条件，见 22.5）
     - **3b. 2-Action Rule（Rule 3）**：每 2 次 view/browser/search 操作后写 findings.md；多模态内容（截图/网页）必须立即转文字落盘
     - **3c. 动作留痕**：关键动作（文件创建/修改、命令执行、测试）随做随记 progress.md 对应 Phase 段；错误发生 → **立即**写 progress.md Error Log（不等 Phase 结束，19.4）。关键动作同步追加工作账本：`bash <skill>/scripts/ledger-append.sh <plan-dir> <event> <summary> [--phase N]`（event 枚举：Phase 翻转=`phase_complete`/子代理回填=`progress`/错误=`error`/门控拦截=`gate_block`/锁定=`attest`/其他=`note`）——ledger 行是 check-3file-gate.sh 的语义工作信号（19.2），无 ledger 时门控退回 mtime 判定
     - **3d. hook 响应**：期间收到 `[plan-sync]` hook 提醒 → 立即执行 references/todo-sync.md §4 响应协议（回写计划 + 同步 Todo）；每 `todo_sync_interval_calls`（默认 10）次工具调用内保持计划文档未腐化；收到 `[plan-compass]` 提醒（findings/progress 陈旧，Rule 19.7）→ 立即回填对应文件再继续；回写内容按三文件分流——状态与指针进 task_plan.md，调研与结论进 findings.md，动作与测试进 progress.md，禁止把 findings 类细节塞进 task_plan.md（Rule 19.6）
  4. **回写计划**：`Edit task_plan.md` Phase 状态 → `complete` + 勾选 checkbox + 记录证据路径；错误记 Errors 表
     - **⚠️ 3-File 回填门控（19.2 — 执行中硬门控）**：标记 complete 前必须满足双条件——① progress.md 对应 Phase 段已回填（Actions taken / Files created-modified / Test Results）；② findings.md 在本 Phase 期间有实质增量。运行 `bash <skill>/scripts/check-3file-gate.sh <plan-dir>` 校验：信号优先级 = ledger 工作账本（`ledger-*.jsonl` 含锚点后的行 = 语义工作证据）> mtime 判定（无 ledger 时兜底）；exit 1 → 禁止翻转 complete，先回填再重跑直至 exit 0
  4.5 **提交工作产物（Rule 27 — git 管理强制）**：实现类 Phase 在标记 complete 前，必须把本 Phase 产物 commit 到当前工作分支（worktree 隔离场景提交在 worktree 内分支；direct 场景提交在主仓当前分支）——**禁止跨 Phase 攒批、禁止留到终验才提交**，丢弃上限收敛为单 Phase 增量。范围 = 本 Phase 实际产出文件（以 scope_files / progress.md「Files created-modified」清单为准），**禁止 `git add -A` / `git add .` 盲扫**（防卷入 plans/、.env、临时文件与并行任务产物；plans/ 按仓约定不入库）。message：`<type>(<scope>): task-<id>/Phase N — <一句话产物摘要>`。提交后 `git status --porcelain -- <scope 文件>` 必须为空；非 git 目录 → progress.md 记一行 `[git-commit] 跳过:非 git 仓库` 不阻塞；豁免（计划声明 `git_commit: deferred` 或用户显式"先不提交"）须已写入计划并登记 verification.md。详见 `references/critical-rules.md` Rule 27
  5. **同步 Todo + 索引（S2/S4）**：该 Phase todo → `completed`；运行 `bash scripts/sync-todos.sh --index` 刷新 INDEX.md
  6. **[DRIFT CHECK]** 调用 `Skill("task-drift-guard")`（本触发点唯一检测载体——`check-drift.sh` 仅作可选佐证，不双跑；C4）
    - ✅ ALIGNED → 继续下一 Phase
    - ⚠️ DRIFT → 记录 progress.md，警觉继续
    - 🔴 BLOCKED → **STOP**，报告用户，等决策
  - **DRIFT CHECK 触发时机（强制）**：Phase 标记 complete 后立即 / 连续 ≥3 次工具调用后 / 切换文件/模块前 / 用户发出新指令时（先按下方「🆕 用户新指令处理」判定）
  - `task-drift-guard` 为只读检测层，发现 BLOCKED 时必须等用户明确决策后再继续

### 📄 产出落盘映射（3-File Pattern — 子代理/调研结论 → findings.md）

> 原则：**Context Window = RAM（易失），Filesystem = Disk（持久）**——任何重要产出必须落盘，会话恢复时靠三文件重建上下文（恢复顺序：task_plan.md 在哪/去哪 → progress.md 做过什么 → findings.md 已知什么）。

| 产出类型 | 写入 findings.md 段落 | 写入时机 |
|---------|---------------------|---------|
| 调研结论 / 搜索结果摘要（web-search / explore / doc-search / research-assistant 返回） | `## Research Findings` | 子代理返回后**紧邻** |
| 根因分析 / 排查结论（debugger / systematic-debugging） | `## Issues Encountered`（Issue + Resolution） | 根因定位后 |
| 技术选型 / 方案决策 | `## Technical Decisions`（+ task_plan.md Decisions Made 双写） | 决策时 |
| 有用的 URL / 文件路径 / API 引用 | `## Resources` | 发现时 |
| 截图 / 网页等多模态信息 | `## Visual/Browser Findings`（转文字） | **立即**（多模态不持久） |
| 用户需求拆解 | `## Requirements` | Phase 1 期间 |

### 📖 Read vs Write 决策矩阵（Rule 20.5 — 省 token 判定）

> 权威源 = `references/critical-rules.md` Rule 20.5（判定矩阵表 + 五场景）。场景速查：刚写完一个文件 → **不要再 Read**（内容还在上下文里）；看过的图/PDF/网页/浏览器/搜索返回 → 立即写 findings.md；开新 Phase → 读 plan+findings；出错 → 读相关文件；中断/压缩恢复 → 读全部三文件（Rule 19.3）。

- [ ] **Chain 区块交接（仅 linked/fan-out 模式）**
  - 当前 Block 所有 Phase complete 后：
    1. 更新 Handoff 追踪表对应行（状态=complete + 完成时间）
    2. 验证交接产物存在：`Read` 检查目标文件
    3. 更新下游 Block `depends_on` 状态为 `in_progress`
    4. 调用 `Skill("task-drift-guard")`
    5. 恢复触发点（交付终态/会话恢复）按 Rule 24.5 自主续推（per-block 扫描已收敛）
  - **handoff 合约**（每次交接前必须满足）：
    ```
    [BLOCK-N COMPLETE] 产物: {path} 大小:{size} 内容确认:{Read 结果摘要}
    → BLOCK-N+1 开始  依赖: {path}
    ```
  - fan-out 模式：多个下游 Block 同时 pending → 按 Rule 21.4 声明组并行（成员通过独立性四问即组内并行；10-02），全部完成才汇合

- [ ] **Code Review Gate**（仅 `code_review: required` 的任务）
  - 触发条件：`task_plan.md` frontmatter 含 `code_review: required`；**diff 分级（[task-v094 T-B6]）**：轻 diff（代码文件 ≤3 个且合计 ≤50 行）→ 单轮轻量审查（code-review 单轮或主进程逐 hunk 自查+抽验登记），重 diff → 全量多轮 CR 原流程不变
  - 触发时机：全部 Phase `complete` 之后、终验交付之前
  - 审查范围：本次任务 Write/Edit 修改过的文件，过滤为代码文件（`.py/.sh/.ts/.tsx/.js/.jsx/.go/.rs/.java/.c/.cpp/.h/.hpp`），排除 `.md/.json/.yaml/.yml/.txt/.toml/.cfg`
  - 执行步骤：
    1. 收集改动文件清单（从 progress.md / git diff 提取）
    2. 过滤非代码文件 → 待审查列表
    3. 调用 `Skill("code-review")` 上下文隔离审查
    4. 输出 `APPROVED` → 进入终验交付
    5. 输出 `CHANGES_REQUESTED` → 自动追加 fix-phase → 回到执行循环
  - **门控**：`code-review` 输出 `APPROVED` 才允许进入终验交付；否则阻断
  - **失败处理**：`fix-phase` 失败 3 次 → `AskUserQuestion` 决策（继续/停止/降级）；交互模式语义见 Rule 28（ask=选项化询问并回填 Decisions；silent=按推荐项自主处置并登记 `silent:` 决策行，D6 硬停点除外）

- [ ] **终验交付**
  - Read `verification.md`
  - 逐条复验 VC（每条带证据路径）
  - **委派率统计（Rule 25）**：从各 Phase Executor 字段 + Subagent Handoff 登记表统计「子代理执行 Phase 数 / 总 Phase 数」及主进程直做清单（含理由），写入 verification.md「委派统计」段；委派率 < `config.json#delegation_rate_floor`（默认 0.7）或主进程直做清单含白名单外理由（白名单见 Rule 25.3）或 stats verdict=violation → check-complete.sh `exit 1` 阻断交付,模型需按 violation 清单回炉补 plan 或转 PARTIAL 重跑；**白名单豁免**：rate<floor 但全部直做理由均命中 Rule 25.3 六项白名单 → 不降级（WHITELIST-EXEMPT 放行；jq 缺失 fail-closed，见 Rule 25.4）
  - **3-File Gate（Rule 19.5）**：确认 findings.md/progress.md 存在且非模板 stub——check-complete.sh 已内置校验，缺失/stub → exit 1 → STOP 回填，禁止交付
  - **质量门控统计（Rule 26）**：按 verification.md「质量门控统计」段核查 Q1-Q6 触发与豁免登记；抽查 ≥3 条 Evidence（路径可 Read、结论可复现）；存在未处置违规 → 按 Rule 26.3 降级 outcome；Q3 → outcome 判 BLOCKED 并 STOP
  - **内容质量门控（v063，template_type=writing/research/publish 任务）**：终验前按 references/methodology.md §内容质量 Q3（去 AI 化 10 条清单）+ Q4（五维评分卡：准确性 25/相关 20/可读 20/原创 20/SEO 15，加权 ≥4.0 放行）核查；不达标 → 回炉精修（Rule 26 惩罚映射）；开关键 config.json#content_quality_enforce（默认 warn）
  - subagent 返回 "done" → **必须 Read 实际产出文件**，禁止信任自报
  - **隔离任务合并回**（isolation=worktree 时，按 references/worktree-isolation.md 合约）：worktree 内全 VC 复验且无未提交变更 → **`bash <skill>/scripts/smart-merge-back.sh <worktree-path> [--deploy]`**（智能门：预检+已合并检测+--no-ff 合并+可选部署对账；ALREADY_MERGED=另一会话已合并→跳过合并补簿记）→ 按 [CLEANUP] 提示行 `git worktree remove` + `git branch -d` → 主仓 Read 关键文件复验
  - **git 提交核验（Rule 27 终验联动）**：确认任务 scope 文件无未提交变更（`git status --porcelain -- <scope>` 为空，或各 Phase 已按 27.1 逐 Phase 提交）；遗留未提交 → 先补提交（注明"终验补提交"）再交付，防修改被丢弃
  - **编号账本**：任务合并后运行 `bash scripts/rule-reserve.sh land <NN> <task-id>`（无新增编号则跳过）。
  - 交付结论：`COMPLETE` / `PARTIAL` / `BLOCKED`
  - **交付总结（五要素）**：按 `templates/delivery-summary.md` 向用户输出任务交付总结（任务说明/产出清单/审查信息/风险点/下一步建议；数据引 verification.md/progress.md/subagent-state/ 指针不重写；风险点区块必须列举，无则逐项写「无」；需存证时落 plans/<task-id>/delivery-summary.md；**可定位性（Rule 48）**：全体指针必须为绝对路径/URL/可执行命令（禁裸文件名、模糊指代、未解析占位符）；下一步建议与待裁决项逐条带「对象路径/URL+看点+动作」，审查类条目必须含审查对象路径或网址）
  - **退出前**：运行 `bash scripts/check-complete.sh` 验证所有 Phase 已 complete
    - exit 0 → 正常结束
    - exit 1 → STOP，报告未完成任务，不结束会话

### 合规检查清单（每 Phase 开始前逐项确认）

| # | 检查项 | 状态 |
|---|--------|------|
| C1 | 用户任务已复述，目标无歧义 | ☐ |
| C2 | `task_plan.md` 存在且含 Phase + VC 表 | ☐ |
| C3 | 计划已展示并获得用户显式授权 | ☐ |
| C4 | 每个 Phase 完成后已调用 `Skill("task-drift-guard")`（同点唯一检测载体，ALIGNED/DRIFT/BLOCKED 三态，BLOCKED→STOP；`check-drift.sh` 仅作可选佐证，不再与 skill 双跑） | ☐ |
| C5 | subagent 返回后已 Read 实际产出文件（check-complete 终验抽查承载） | ☐ |
| C6 | 全部 VC 逐条复验，有可查证据（check-complete 逐条校验承载） | ☐ |
| C7 | 交付结论为 COMPLETE/PARTIAL/BLOCKED 之一（check-complete 终态判定承载） | ☐ |
| C8 | `code_review: required` 任务已完成 Code Review Gate 且输出 APPROVED（APPROVED 为门控前置条件，终验人工确认） | ☐ |
| C9 | Code Review Gate 的 fix-phase（如有）已 complete（check-complete 全 Phase complete 判定承载） | ☐ |
| C10 | 计划创建后已按 S1 建立原生 Todo 映射（TodoWrite 或 Task；原生 Todo 无机器门，人工） | ☐ |
| C11 | 每个 Phase 状态变更后已同步 Todo（S2）；`[plan-sync]` 提醒均已响应（S3，hook 提醒响应为人工动作） | ☐ |
| C12 | 用户新指令已做 D/A/B/C 影响判定（D 新任务边界先判，8.1）；D 类已开新计划目录且旧计划原样保留；B/C 类已完成计划 + Todo 同步更新（S5，判定为人工动作） | ☐ |
| C13 | 计划交付终态/会话恢复触发点已按 Rule 24.5 调 `Skill("plan-resume")` 自主续推 Top 1（不再每 Phase 被动扫描；24.7 豁免场景登记跳过） | ☐ |
| C14 | 本 Phase 执行体与计划 Executor 字段一致；主进程直做已在计划登记例外理由（check-delegation stats 终验承载） | ☐ |
| C15 | 本 Phase 无未处置质量违规：V-N 全勾且 Evidence 非空、Handoff verify_done 已勾、无 Rule 26 触发项（或已豁免登记）（Rule 26 人工核查；无机器门承载，人工保留不收敛） | ☐ |
| C16 | 三文件罗盘可验证：Phase complete 前 `check-3file-gate.sh` exit 0（findings 本 Phase 有增量 + progress Phase 段已回填，Rule 19.2 机器门承载）；Handoff 表各行「findings 落点」已填且 verify_done 已勾（Rule 22.5 人工）；终验前两文件非 stub（check-complete 3-File Gate 机器门承载） | ☐ |
| C17 | 本 Phase 产物已按 Rule 27 提交：scope 文件 `git status --porcelain` 为空（或已登记非 git 跳过 / `git_commit: deferred` 豁免 / 无仓内产物）（check-complete porcelain 终验预检承载） | ☐ |
| C18 | ask 模式计划批准前已按 28.2.1 口头复述大体执行思路（≤5 行，内容可对照计划）且已登记 Decisions Made（silent 模式不适用；复述为人工动作） | ☐ |
| C19 | 用户指出错误场景（31.1 触发①②③任一）已按 Rule 31 走 31.2 根因分析：progress.md Error Log 对应行 Root Cause/Prevention 列非空（`<待沉淀>` 占位不算）且 notepad 沉淀两段已写（check-complete Learning Gate 机器门承载；未命中错误指出则不触发，无需记行） | ☐ |
| C20 | 本任务全部方案候选/建议/D2 选项已过 32.2 禁令检查（禁令源=当前+历史 notepad「被否决方案」段+memory）；命中项已剔除或按 32.4 标注否决出处+新证据交用户裁决（veto 核查无机器门，人工保留不收敛；无禁令命中则无需记行） | ☐ |
| C21 | 每个问题解决动作后已按 Rule 33 落 [reflect] 反思+验证两行（progress.md 可查；check-complete REFLECT-GATE 机器门承载，声明 reflect_verify: required 时） | ☐ |
| C22 | attest 前 template_type 已过 check-template-type.sh 门控（逃生须披露，机器门承载）；命中 34.3 沉淀触发时已按 34.7 全自动生成（34.5 双闸门内置生成侧）沉淀或登记不沉淀理由（check-complete warn 兜底） | ☐ |
| C23 | 准备以否定结论（无法查看/不存在/不支持）结束任务或上报 prompt 过大失败前：能力否定已过 Rule 35.2 三关（完整接口面/CRUD 推断/替代路径，查证动作按 35.6 最小探针原则）并附证据，或已按 35.3 落盘引用补救（内容写文件+prompt 只放路径与 Read 指令）；违规按 Rule 26 回炉（三关查证人工，结论证据随交付报告留痕） | ☐ |
| C24 | 本任务涉及技能文件修改时（Rule 36.1 范围）：已按 36.2 完成归因（指向技能本体才可提案）+ 36.3 删除基线与删除性行为清单已落 findings/progress；功能性删除/语义改写已逐项获用户确认（36.4，D6 级；check-skill-modify 机器门承载写操作，确认动作人工） | ☐ |
| C25 | 本任务已按 Rule 37 套用机制画像：template_type 对应的代码组/内容组机制适用性已核对（Code Review Gate、code-assistant 路由等按画像取捨）；画像不适用或未命中登记一行理由（机制画像核对人工） | ☐ |
| C26 | 本任务已按 Rule 38 判定计划档位：轻量任务声明 plan_tier: mini 时已套用 mini-lite 模板+豁免清单（5 锚点），非轻量任务未误用 mini 档；MISMATCH 提示已处置（check-template-type/plan-tier 机器门承载 MISMATCH 检测，套用人工） | ☐ |
| C27 | 用户显式点名 /workflow 编排时已按 Rule 39 路由：Skill("dynamic-workflows") 已加载、CreateWorkflow 三来源其一提交、21.4 并行豁免已登记 Decisions Made+progress（39.4，未点名则按 21.4 独立性守门调度执行，无需记行） | ☐ |
| C28 | standard/full 档计划含「🧰 工具选择与编排」区块且逐 Phase 登记工具面与理由、workflow 编排判定与 /goal 对齐两判定行已填（Rule 40.2/40.3/40.4；Executor 字段仍是委派门控机器事实源,区块不替代；mini 档豁免无需记行）；命中建议 CreateWorkflow 时已按 39.4 登记并行豁免（机器面=selftest-tool-selection 静态断言,区块完整性人工核查） | ☐ |
| C29 | 本任务执行中出现失败/阻塞/升级冲动时已按 Rule 41 过消解链与升级四门槛：升级用户仅限 G1 破坏性不可逆/G2 范围越界/G3 对外不可撤回发布/G4 语义级目标分叉,门槛外自动消解+登记禁呈报（41.2/41.3）；任何 AskUserQuestion/STOP 前已过 41.4 消解清单并在上报附「已尝试清单」；多待决项打包呈报附推荐（41.5）（机器面=selftest-self-resolution 静态断言,消解过程人工核查） | ☐ |
| C30 | 质量审查工具检测与登记（Rule 42）：本任务涉及质量审查面（内容组=发布前质量审计/代码组=Code Review）时已按 42.2 四级顺序检测（项目级→用户级→环境既有 agents→内置 review-library 兜底池），检测结论（技能名/既有 agent 名/待补充 S-unit 指针）已登记计划「质量审查工具」行；缺口已按 42.3 补充合约处置（补建动作作为 S-unit 登记进计划，禁无登记私建技能）；执行期质量审查动作已用登记工具（未检测=违规，Rule 26 降质面）（机器面=selftest-reliability-institution 静态断言，检测过程人工核查；mini 档 42.5 豁免） | ☐ |
| C31 | 执行可靠性制度化（Rule 43）：交付物重要声称（已完成/正确/通过）已附机器可复现验证证据（命令+关键输出/Read 路径+关键行/diff 行号），未验证内容已以「未验证」显式登记（43.1）；S-unit 表逐行标注建议档位且取最小可承载档（43.2，失败先 22.3 升档非默认大模型）；推荐/选项化呈报前已枚举 ≥2 候选并过最轻验证后按候选对比表选已验证最优（43.3），验证成本过高时降级假设清单+验证顺序（机器面=selftest-reliability-institution 静态断言，证据核查人工） | ☐ |
| C32 | 对齐审查标准流程（Rule 42.6）：文档/文件更新前已按 42.6.1 跑版本一致性校验（未经校验未直接追加）；任务完成前已按 42.6.2 对全部产出与更新文档跑 alignment-review 对齐审查（标准收尾流程）；对齐整理已输出变更记录（42.6.3 三要素）；本任务无文档更新或纯新增无联动时登记豁免理由（机器面=selftest-review-library RL-11..13 静态断言，校验过程人工核查；mini 档豁免） | ☐ |
| C33 | 用户选择点默认项与自动超时（Rule 44）：向用户提供 2+ 选项的每个询问点已指定默认选项（推荐项排第 1 位标注默认/推荐）+自动超时时长（默认 5 分钟,询问点可声明覆盖值,登记于「自动超时默认项」行）;低区分度选项（产出一致仅步骤/耗时差异）已按 41.3 直接裁决并登记理由而非打扰用户;用户超时未答复已按默认选项自动执行且登记自动裁决记录五要素（超时值/推荐项/触发时间/理由/被覆盖选项）;本任务无 2+ 选项询问点时登记豁免理由（机器面=selftest-ask-default-timeout RT 静态断言,消费过程人工核查;mini 档豁免） | ☐ |
| C34 | 单元线推进检查（Rule 49）：多单元线任务每个跨 Phase 前移已过推进三条件（已验收/前置在位/独立性四问）并双登记（Lane 表或 progress [advance] 行）；汇合点工序已等齐上游验收；单单元线任务登记豁免理由（机器面=selftest-lane-advancement 静态断言，推进核查人工；mini 档豁免） | ☐ |
| C35 | 需求覆盖门控（Rule 51）：计划含「🎯 用户需求原文」区块且 R→VC 映射完整（51.1/51.2）；交付终态出「需求覆盖核对表」且核心需求全 covered 或有用户让步登记（51.3/51.4）；生成类动作前有盘点记录（51.5）（机器面=selftest-requirement-coverage.sh 静态断言，核对过程人工核查；mini 档豁免） | ☐ |
| C36 | 根源解决纪律（Rule 53）：计划含「根源覆盖表」区块（结果级需求全链审计，53.1）；解决类条目附根治判据（53.2）；决策点过管辖二分（53.3）；浅快路径过返工核算（53.4）（机器面=selftest-root-resolution.sh 静态断言，核查过程人工；mini 档豁免） | ☐ |

### 🔁 原生 Todo 同步（强制）

计划文档 = 唯一事实源，原生 Todo（ZCode/Claude 内置 `TodoWrite` / Task 系统）= 执行视图。五个强制同步时机：**S1** 计划创建后建映射 → **S2** Phase 状态变更后紧邻同步 → **S3** 收到 `[plan-sync]` hook 提醒立即回写 → **S4** 会话结束前终态同步 + `sync-todos.sh --index` → **S5** 用户新指令影响计划后先改计划再重映射 Todo。映射规则、工具选择与响应协议详见 `references/todo-sync.md`；阈值在 `config.json#todo_sync_interval_calls` / `config.json#plan_update_interval_minutes`。

### 🆕 用户新指令处理（计划影响判定 — 强制）

会话中用户发出任何新指令/修正/补充时，**执行该指令前**先完成三分类判定：

| 类 | 判定 | 强制动作 |
|----|------|----------|
| D 新任务边界 | 与当前计划 Goal/范围/交付物均无关联（用户要的是独立新任务，详见 8.1） | **开新计划**：为该指令建 `plans/{new-task-id}/`（init-session 全流程）；旧计划原样保留（不标 superseded）；判定落 notepad 一行 + Decisions Made；**禁止**在当前计划上下文里照做（A）或扩进当前计划范围（B）= 不相干内容混入 |
| A 无影响 | 闲聊/追问/与当前计划无关 | 正常执行，不改计划 |
| B 扩展 | 新需求/加范围/改交付物 | **先重规划再执行**：`Edit task_plan.md`（新增/修改 Phase、VC、执行范围表，注明来源指令与时间）→ 紧邻同步原生 Todo（S5：新增/调整对应条目）→ 向用户复述计划变更 → 再执行 |
| C 矛盾 | 与已确认计划/VC/用户先前决策冲突 | 停止当前写入：更新计划中被推翻部分（标注 superseded + 新内容）→ 同步 Todo（改/删对应条目）→ 展示新旧对比获确认后执行；与用户此前关键决策冲突时必须 STOP 等决策 |

**判定顺序**：先 D（任务边界）再 A/B/C——指令与当前目标有关联时回退 A/B/C 正常判定；仅当存在进行中的活跃计划时 D 类适用。

**稳定性铁律**：禁止"口头接受新指令、计划文档与 Todo 不动"——计划外执行是后期执行不稳定与漂移的首要来源。
**错误指出特判（Rule 31 — task-v072）**：用户指出的若是「已产出/结论/执行有误」、或对同一问题重复反馈 ≥2 次、或执行中打断补充新数据推翻既有结论 → 先 STOP 当前写入，按 31.2 完成 4 维归因表（现象/直接原因/根因 5 Whys/类别）并落 progress.md Error Log（Root Cause 列）+ findings.md Issues 段，再按 31.3 修正路由定向修、31.4 同步沉淀 notepad 两段；**禁止跳过归因直接改症状处**。完整条款见 `references/critical-rules.md` Rule 31。
**用户否决登记（Rule 32 — task-v073）**：用户说「不允许 X / 禁止 X / X 是错的 / 不要再做 X」或否决某方案 → 当次动作内按 32.1 双写登记（Decisions Made `veto:` 行 + notepad「🚫 被否决方案」段）；此后任何方案候选/D2 选项/重规划建议提出前按 32.2 先查禁令源，命中的方案禁止进入候选与推荐；解禁仅按 32.4 两条路（用户显式 veto-lift / 可引用新证据+标注否决出处交裁决），**禁止静默改回**。完整条款见 `references/critical-rules.md` Rule 32。
**解决后反思-验证循环（Rule 33 — task-v074）**：每个问题解决动作（bug 修复/失败重试成功/错误修正/关键实现完成）后、标记完成前，走「反思四问（33.2）→独立验证（33.3）」微循环，progress.md 落 `- [reflect] 反思:` 与 `- [reflect] 验证:` 两行；≤3 轮（33.4），超限按 Rule 22.3 升级。完整条款见 `references/critical-rules.md` Rule 33。
**模板选取门控与沉淀（Rule 34 — task-v074）**：attest 锁定前 check-template-type.sh 校验 template_type ∈ 白名单（variant/ 动态派生+general）；终验时命中 34.3 沉淀触发（同类第 2 次/类型空缺可泛化/用户点名）→ 按 34.4 提炼新 variant 模板入库+四点同步，防滥用见 34.5。完整条款见 `references/critical-rules.md` Rule 34。
**模板感知（task-v096）**：遇新类型任务时三时点主动激活（init-session [template-sense] 提示+计划区块预登记 → 终验全自动生成，34.7 全自动合约+34.5 闸门内置生成侧）；卫星 SOP 见 plan-template-kit。
**技能文件修改保守化（Rule 36 — task-v079）**：任何技能文件写操作（36.1 范围）先过 36.2 归因前置门——执行期失败/异常禁止拿「改技能」当第一补救，归因指向技能本体且用户显式要求才可提案；修改前按 36.3 建删除基线产出删除性行为清单，功能性删除/语义改写按 36.4 交用户逐项确认（D6 级，silent 亦不可跳过），默认 36.5 纯增量；新守卫 check-skill-modify.sh 挂 pretooluse 对主进程与子代理一致生效（skill_modify_enforce 默认 warn）。完整条款见 `references/critical-rules.md` Rule 36。
**新增任务边界判定（Rule 8.1 — task-v087）**：用户新指令与当前计划 Goal/范围/交付物均无关联 = **D 类新任务**——先判 D 再判 A/B/C：开新计划目录（init-session 全流程），旧计划原样保留（不标 superseded，区别于 C 类）；禁止把不相干指令在当前计划上下文照做（A）或扩进当前计划范围（B）——不相干内容混入既有 task_plan.md 是三文件污染与终验失焦的首要来源。判定依据 = 当前 task_plan.md 三要素（Goal + scope_files/执行范围 + 交付物）；指令与当前目标有关联（哪怕影响小）回退 A 类；无活跃计划时 D 类 N/A（天然开新计划）。判定落 notepad-learnings.md 一行 + Decisions Made。完整条款见 `references/critical-rules.md` 8.1。
- 每次 B/C 类变更 → `Decisions Made` 表记一行（指令→变更）+ progress.md 记录
- B/C 类处理完必须再跑 `Skill("task-drift-guard")`
- 配套提醒：UserPromptSubmit hook 在指令到达时注入 `[plan-note]` 判定提示（有活跃计划时）

### 🔀 冲突分析与工作树隔离（默认首选）

**默认策略：实现类任务一律首选 git worktree 隔离开发**——本仓多为运行中的基础设施（skills/hooks/config 被所有会话实时使用），直接改动可能使功能在工作期间半残；隔离后改动发生在副本，验证后原子合并回原分支。仅**纯文档/调研类任务**（只写 plans/ 与 .md）允许直接开发；用户显式否决时才直接开发。

**初始化时强制执行**：
1. 运行 `bash scripts/check-conflicts.sh` → 输出五类冲突信号（①未提交变更 ②额外 worktree ③遗留 wt 分支 ④待处理任务在册 ⑤运行中基础设施改动）
2. 结果 + 隔离决策写入 task_plan.md「🔀 隔离决策」区块，随计划一并展示给用户（默认建议 worktree，用户可否决）
3. 隔离开发期间 **CWD 不迁移**，所有文件操作用 worktree 绝对路径；计划文档留在主仓 plans/（会话级状态不进 worktree）

**完成后主动合并回**（合约见 `references/worktree-isolation.md`）：worktree 内全 VC 复验 → **`bash <skill>/scripts/smart-merge-back.sh <worktree-path> [--deploy]`**（智能门：预检+已合并检测+合并+可选部署对账）→ 按 [CLEANUP] 提示行清理 worktree/分支 → 主仓 Read 关键文件复验合并结果。复杂场景可配合 `Skill("using-git-worktrees")`。

## Chain 模式详解（已内敛 → reference.md）

`chain_mode` 默认 `single`（单 block，无 chain 区块）；`linked`（多 skill 串行接力）/`fan-out`（一对多派发，fan-out 成员按 Rule 21.4 声明组并行——组内独立性四问通过即可并行，未声明组=串行，10-02）的值语义、示意图与执行规则权威源 = `reference.md § Chain 模式详解`；block 交接字段表/6 条件/重规划触发见 `reference.md § Chain Handoff Contract`。

## 🧵 并行创作组（Unit × Lane — Rule 21.4 / 23.9-23.13 / 47 / 49）

> **核心模型**：把「场景段落 / 关键帧批 / 资产批」抽象为 **创作单元 Unit**；每个 Unit 一条 **工序链 lane**（写词→生成→质检→放行→组装）。**并行单位 = Unit（lane）；Unit 内工序强串行**（Rule 47.1 阶段×生产单元轴 + Rule 49.1 单元线模型，不造新机制）。冲突检测/引用管理规则本体见 `references/critical-rules.md` Rule 23.9-23.13。

**① 声明格式（task_plan.md 三层声明）**：**(a) frontmatter** `parallel_groups: [u-seg01, u-seg02, ...]`（组名=创作单元 id）∧ `lanes: [u-seg01, ...]`（单元线名册，Rule 49）——必须**一次性声明全部 lane**（frontmatter 受 SHA-256 attest 锁定 Rule 20，执行期追加触发重锁）；只读并行组沿用 `parallel_readonly: true` + `[readonly-parallel]`。**(b) S-unit 表（22.6）增「单元/并行组」列**，每行填 `[parallel-group:<unit-id>]`（Rule 21.4 机器可消费组标记，check-dispatch.sh 消费；check-plan-dispatch.sh 只硬校验「执行体」列，加列安全）。**(c) 「📐 创作单元并行表（Lane 状态表）」区块**（Rule 49.1，主进程单写者）：列 = 单元 id | 工序链 | 当前工序 | 前置 S-unit | 前置验收证据 | 组标记 | 共享引用集 | 预估烧秒 | 状态 | 最后推进时间；推进双登记（49.3）= Lane 表翻格 + progress.md `[advance]` 行。

**② fan-out / Aggregator（与既有 chain_mode 一致）**：`fan-out` = 上游 complete → 下游 Block 按 Rule 21.4 声明组**并行**派发（未声明组仍串行）→ 等齐；`chain_mode: fan-out` 计划**必须**预置 Aggregator Phase（Rule 23.6 / 18.7，check-complete.sh 硬校验正则 `Phase \d+:.*Aggregator|聚合`），模板预置 `### Phase N: Aggregator（汇合：整片组装 / 成片 QC / 台账收口）`；`linked` 语义不变（同上游产物多下游依次消费 = 四问③串行）。

**③ 冲突检测清单（哪些情况不能并行）**：两 Unit 可并行 ⇔ 独立性四问全 **no**：① 写集相交？② 资源相争（同 worktree/分支、同交付物、同计划文件锚点、同预算 piece_id、同 NAS/VERSIONS.md、同额度窗口）？③ 输入依赖他者产物？④ 验收依赖他者结果？**项目专属冲突类（强串行）**：锚件换代（换装/装备变体/母图重抽）；同场景组连续成片（同场景组镜头=同一 lane 内串行）；同单元内生成→质检→放行→视频工序链；人工门（草稿门/试水门/G1）=lane 内屏障不可并行越过（跨 lane 可同批呈示）；生成额度=全局共享资源（Σ 在飞 lane 预算 ≤ 当日剩余额度）。三检测时机（计划期静态 / 派发期对全部在飞过四问 / 验收后三证据）与 RefSet 见 Rule 23.10-23.12。

**④ 引用管理（共享资源处理）**：① 只读共享+版本冻结（共享锚件 `id+版本+sha256` 冻结，子代理只读，派发 prompt §4 Scope 禁改）；② 单写者（masters-registry/upload-map/master-prompt-store/VERSIONS.md/Lane 表/计划三文件由主进程单写，子代理只追加自己锚点，22.4a/49.4②）；③ 共享引用登记表（task_plan.md 区块：资源 id|类型|路径|sha256|引用单元清单|状态(现役/frozen/stale)）；④ 产出命名空间隔离（每单元 `output/<ep>/<unit>/` 与 `tmp/<task>/<unit>/`，汇合件由 Aggregator 单写）；⑤ 锚件换代协议（G1 人工门+单写者登记+stale 广播+冻结锁，换代后按 sha 差集重跑，grep 旧 sha 0 命中方可 complete）；⑥ 预算账本隔离（每单元独立 piece_id 命名空间）。

**⑤ 子代理拆分模板（Unit × 工序 = S-unit）**：单 S-unit = 单创作单元 × 单工序（禁「整集生成/整批关键帧」粗粒度，Rule 47.1）；派发纪律 = 单会话单 S-unit（46.1）+ 每 lane 至多 1 个在飞 + 跨 lane 在飞 ≤ 并发上限（建议 2-4）+ 推进三条件（49.2）满足即派不等批（跨 Phase 前移 49.3）+ 失败 lane 冻结不阻塞其它 lane（Rule 49 核心收益）。**派发 prompt 增补字段**（在 `templates/subagent_dispatch.md` 并行组声明行基础上）：单元 id + `[parallel-group:<unit>]` + 引用集 sha 清单 + Scope 禁改（共享锚/registry/VERSIONS.md/Lane 表/三文件既有内容）+ 前置验收证据指针 + checkpoint `subagent-state/{seq}-{agent}-<unit>.md`。**执行体路由**：视频生成=`video-generation-executor`（缺位回退 executor(sonnet-1)+videop1-tools skill）；图片/关键帧=`image-generation-executor`；质检=对应 review-*；放行=用户（主进程 STOP，子代理无权代放行，约束 14/15）；禁因路由表无匹配行默认落 general-purpose（Rule 47.2/52.1）。**机器守卫边界（如实披露）**：check-dispatch.sh `serial_slot_check` 只有全局锁 `subagent-state/.dispatch-inflight`（120s age），组标记命中即放行、不区分组名、不做四问机器校验——责任在计划期声明+执行期四问（Rule 23.13）。

## Critical Rules

详见 `references/critical-rules.md`（Rules 1-39（含 Rule 40-53 全集））：
- Rules 1-12：先规划再执行/PreToolUse 阻断/双操作后保存/决策前重读/Phase 更新/记全部错误/永不重复失败/新请求重规划/错误暴露/Scope 变更重规划/漂移检测/冲突隔离
- **Rule 13（P0）子代理隔离强制**：调研/搜索/大文件读取/Read 大文件 必须派子代理（详见下方 §子代理路由与模型分级）
- **Rule 14（P0）代码编辑必须派子代理**：主进程禁止 Edit/Write 业务代码（详见下方 §代码编辑强制隔离）
- **Rule 15 高频漂移纠正强制**：每 2-3 个原生 todo 后必须跑 `Skill("task-drift-guard")`（详见下方 §高频漂移纠正）
- **Rule 16 任务开启期选模板**：禁止用通用 task_plan.md 套所有任务，必须按类型选模板（详见 `../plan-template-kit/references/template-mapping.md`，模板分流单一权威源）
- **Rule 17 成本控制 — 降低 Opus 使用频率**：嵌套 opus Skill 节流 + 单会话 opus 累计门控 + cost_log 记录（详见 `../plan-cost-guard/references/cost-control.md`）
- **Rule 18 批量处理质量门控**：批量操作禁止以牺牲质量/准确性为代价；试点先行硬门（18.9-18.11：单件未验证禁批量、单件失败即投毒红线、宁慢勿错，task-v083）+ 前置 3 问评估 + 双采样抽检 + 失败率熔断 + Batch Report 八字段（详见 `references/batch-quality-gate.md`）
- **Rule 19（P0）3-File 落盘强制**：三文件（task_plan/findings/progress）= Context Window 是 RAM、Filesystem 是 Disk 的落地——子代理结论必落盘 findings.md（与 Handoff `verify_done` 双条件绑定，22.5）、**3-File 回填门控（19.2）= Phase complete 前置硬门控**（progress 回填 + findings 本 Phase 增量，`check-3file-gate.sh` 校验 exit 1 禁止翻转）、恢复会话先读三文件、终验 3-File Gate 硬校验（19.5）、task_plan.md 瘦身指针制（19.6）、[plan-compass] 及时性提醒链路含二次未响应升级警告（19.7）（详见上方 §产出落盘映射）
- **Rule 20 计划注入与防篡改**：turn-start smart 注入（Goal/Next Step/in_progress Phase 复诵）+ SHA-256 attestation 锁定（篡改即 [PLAN TAMPERED] 拒绝注入）+ 外部内容只进 findings.md（详见 `references/critical-rules.md` Rule 20）
- **Rule 21 子任务拆分与模型分工**：大模型拆分、低档模型执行，单 Phase ≤3 文件 ≤300 行，步级 S-unit ≤2 文件/≤100 行/≤15min 且派发型 Phase 计划期必填 S-unit 表（21.1b/22.6），派发按 21.4 调度铁律——声明并行组内成员可并行（独立性四问通过）、未声明组一次验收一组成员再派下一组成员（21.4 子代理调度铁律，10-02）（21.1b 数值门控机器校验已生效：check-plan-dispatch.sh；步骤枚举维度=check-dispatch.sh ④+step_max_steps，task-v081）（详见 `references/critical-rules.md` Rule 21）
- **Rule 22（P0）子代理规模限制与交接文件**：派发上限/超时档位/九字段 prompt(含上下文预算、三文件读写契约 22.4a、8 字段严格返回 22.4b、派发守卫 22.4c)/兜底拆细先于升档/Handoff 登记表（详见 `references/critical-rules.md` Rule 22）
- **Rule 23 并行任务检测与冲突规避**：--runtime 四级冲突 + fan-out Aggregator 硬校验 + 并行创作组单元级冲突检测/引用管理（Rule 23.9-23.13，衔接 Rule 21.4/47/49）（详见 `references/critical-rules.md` Rule 23）
- **Rule 24（P1）plan-resume 被动扫描与自主续推**：交付终态/会话恢复触发点扫中断任务（task-v091 A-3 收敛，不再每 Phase 扫）；执行中只报告，恢复触发点自主续推 Top 1（v0.5，config `autonomous_resume`；详见 `references/critical-rules.md` Rule 24）
- **Rule 25（P0）子代理委派门控**：Phase 必须声明 Executor 执行体，开启先过委派检查点，主进程直做须登记白名单内例外理由（25.3 六项白名单），终验统计委派率（阈值 `config.json#delegation_rate_floor` 默认 0.7；详见 `references/critical-rules.md` Rule 25）；**计划批准时 attest 内置 `check-plan-dispatch.sh` 校验派发型 Phase 的 S-unit 执行体列（22.6 机制化，缺失拒绝锁定）**（fmea_enforce 消费机器校验已生效：attest+check-complete）
- **Rule 26（P0）质量优先于速度门控**：6 类降质行为可观察触发式 + 确定性惩罚映射（回炉→PARTIAL→BLOCKED），伪造证据无豁免（详见 references/critical-rules.md Rule 26）
- **Rule 27（P0）工作产物及时提交**：实现类 Phase 翻转 complete 前产物必须 commit 到当前工作分支（worktree 逐 Phase 提交 / direct 主仓分支），禁攒批到终验；只 add scope 产物禁盲扫；非 git 目录记行跳过；deferred/用户显式豁免须写入计划（详见 `references/critical-rules.md` Rule 27）
- **Methodology 指针（v063）可靠性 4 条/内容质量 5 条/思维方法论 5 条（T1-T5：问题先行/解构四问/金字塔原理/逐步推导/消费点，零新键，task-v084）方法论，门控+指针范式，不改 Rule 1-28 既有语义（详见 references/methodology.md，开关键 fmea_enforce/content_quality_enforce 默认 warn）**（机器校验已生效：attest-plan.sh FMEA 门控段 + check-complete.sh 终验双点，三档 warn/enforce/off）
- **Rule 28（P0）交互模式与询问门控**：ask（默认：D1-D6 关键决策点给选项供用户选，D1 批准前按 28.2.1 口头复述大体执行思路供用户不读计划文档预知流程）| silent（静默：自主决策+登记静默决策清单）；解析优先级 env > 计划配置表 > config.json > 默认 ask；D6 硬停点（连续失败 STOP/drift BLOCKED/Q3/破坏性操作确认）两模式一致不可豁免（详见 references/critical-rules.md Rule 28）
- **Rule 29（P0）上下文与工作文件主动维护**：触发时机(29.1)/退场 SOP(29.2)/压缩 SOP(29.3)/工作文件整理 SOP(29.4)/配置键语义(29.5)/反模式(29.6)——主动维护"多→删"链路，与 Rule 19"缺→补"链路对称（详见 references/critical-rules.md Rule 29）
- **Rule 30（P0）共享内容认领追踪**：识别条件(30.1)/创建复用(30.2)/认领登记(30.3)/防冲突(30.4)/机制(30.5)——"共→认领"链路，可枚举共享资源（页面/内容/功能/部署位）的部分认领任务须登记项目级共享追踪账本（progress-tracker `.zcode/ledger/` 多平台跟随），后续任务先查后做，杜绝重复混乱；开关键 `config.json#shared_tracker_enforce`（默认 warn，详见 references/critical-rules.md Rule 30 与 ../plan-collab-router/references/skill-collaboration.md progress-tracker 协同行）
- **Rule 31（P0）错误学习闭环**：触发(31.1)/根因分析(31.2)/修正路由(31.3)/沉淀(31.4)/消费侧(31.5)/机制(31.6)——“错→析→修→防”链路，用户指出错误/重复反馈/打断补充数据时先 4 维归因（现象/直接原因/根因 5 Whys ≤5 层/类别）并落 progress.md Error Log（Root Cause 列）+ findings.md Issues 段，禁止盲目改症状处；防复现措施沉淀 notepad-learnings 并被下一 Phase/新任务消费（31.5 消费侧）；终验 Learning Gate（check-complete.sh 校验 Error Log Root Cause 非空）；开关键 `config.json#error_loop_enforce`（默认 warn，详见 references/critical-rules.md Rule 31）
- **Rule 32（P0）用户否决与禁令追踪**：登记(32.1)/计划期必查(32.2)/执行期消费(32.3)/解禁条件(32.4)/机制(32.5)——"否决→登记→提方案前必查→无证据禁重提"链路：用户裁决「不允许/禁止/X 是错的」即时落盘 notepad「🚫 被否决方案」段+Decisions Made（veto: 行）；提出任何方案候选/D2 选项/B 类重规划建议前必查禁令源（当前+历史 notepad+memory），命中的方案禁止进入候选、禁止推荐、禁止作为默认项；解禁仅限用户显式撤销（veto-lift）或可引用新证据且标注否决出处交用户裁决——**禁止静默改回（倒退式改法=循环开发）**；开关键 `config.json#veto_enforce`（默认 warn，详见 references/critical-rules.md Rule 32）
- **Rule 33（P0）解决→反思→验证迭代循环**：触发(33.1)/反思四问(33.2)/独立验证(33.3)/迭代边界≤3 轮(33.4)/沉淀联动(33.5)/机制(33.6)——问题解决动作（bug 修复/失败重试成功/错误修正/关键实现完成）后标记完成前，progress.md 落 `- [reflect] 反思:` 与 `- [reflect] 验证:` 两行；REFLECT-GATE（check-complete.sh，声明 reflect_verify: required 时校验，默认 warn）；开关键 `config.json#reflect_verify_enforce`（详见 references/critical-rules.md Rule 33）
- **Rule 34（P0）模板生命周期门控与沉淀**：选取门控(34.1)/四点同步(34.2)/沉淀触发(34.3)/沉淀流程(34.4)/防滥用(34.5)/机制(34.6)/模板感知(34.7 三时点激活+全自动生成)——attest 前 check-template-type.sh 校验 template_type ∈ 白名单（variant/ 动态派生+general）；命中沉淀触发→提炼新 variant 模板+四点同步；开关键 `config.json#template_gate_enforce`（默认 warn，详见 references/critical-rules.md Rule 34）
- **Rule 35（P0）执行结论纪律**：能力否定三关查证（35.2 通读完整接口面/CRUD 一致性推断/替代路径）+ 大输入落盘引用补救（35.3 prompt 超限→内容写文件+Read 指令）——「没找到」禁写成「不存在」收场、prompt 过大禁失败收场；+ 最小探针原则（35.6 验证动作最小化：echo ok 类单条最小输出测试，禁一上来复杂化）；check-dispatch 超限提示+selftest-conclusion-discipline 守护，无新 config 键（详见 references/critical-rules.md Rule 35）
- **Rule 36（P0）技能修改保守化与功能删除防护**：适用范围(36.1)/归因前置门(36.2)/修改前基线(36.3)/删除=高危确认门(36.4)/纯增量纪律(36.5)/回归验证(36.6)/机制(36.7)——"归因→基线→确认→增量→回归"链路：技能文件写操作先按 31.2 归因且归因指向本体才可提案，功能性删除/语义改写须用户逐项确认（D6 级硬停点），默认纯增量，杜绝偷渡式修改与功能静默丢失；开键 `config.json#skill_modify_enforce`（默认 warn，详见 references/critical-rules.md Rule 36）
- **Rule 37（P0）任务类型机制画像**：画像表(37.1 权威源=template-mapping.md §九)/判定时点(37.2 计划创建期)/三类机制组(37.3)/消费侧(37.4 委派检查点+Code Review Gate 触发条件)/机制(37.5 mechanism_profile_enforce+selftest)——「按类型裁剪机制适用性」链路：仅裁剪类型组机制，3-File/委派率/漂移检测等通用守卫全类型不变（详见 references/critical-rules.md Rule 37）
- **Rule 38（P0）任务难度分级与轻量档**：判定(38.1 plan_tier: mini ∧ ≤2 文件 ∧ ≤15min ∧ 单模块, 三条件机器可测+MISMATCH 提示)/档位矩阵(38.2 mini-lite 模板+standard 29 variant+full general)/轻量模板契约(38.3 区块白名单)/门控豁免清单(38.4 5 锚点 if 前置, 非 mini 路径零改动)/机制(38.5 plan_tier_enforce 三档默认 warn+init-session tier 分流+selftest-plan-tier.sh)/执行通道分级(38.7 L0 微变更轻量通道·比例原则——流程开销与变更体量成比例)——轻任务走精简仪式消除慢源，未声明档位计划零影响（详见 references/critical-rules.md Rule 38）
- **Rule 39（动态工作流编排 — task-v088）**：用户显式点名 `/workflow` 才路由 dynamic-workflows 编排（未点名=按 21.4 独立性守门调度，声明组并行/未声明串行，10-02）；skill 加载前置门槛（39.2）；四机制映射 失败/断点/升级/沉淀→AmendWorkflow/ResumeWorkflowRun/ResolveWorkflowQuestion/SaveWorkflow（39.3 表）；21.4 并行豁免登记（39.4）；机器校验边界=官方文档未提及 check-dispatch 覆盖 workflow 内部（39.5）；零新 config 键，selftest-workflow-orchestration.sh 守护（39.6）
- **Rule 40（harness 工具面主动选择 — task-v097）**：工具面六类清单（/workflow、/goal、Agent 子代理、卫星技能、MCP、机械守卫脚本）（40.1）；计划期「🧰 工具选择与编排」区块=Executor 上游分析记录,不替代委派门控机器事实源（40.2）；/goal 对齐映射指引+用户侧命令如实披露（40.3）；workflow 编排建议登记制、39.1 显式点名红线不变（40.4）；机器校验边界如实披露（40.5）；零新 config 键+selftest-tool-selection.sh 守护（40.6）
- **Rule 41（问题自主消解与升级纪律 — task-v098）**：消解优先链=重读计划→22.3 ①-④ 兜底→最小探针→拆细→替代路径(含 22.3.0 官方文档/网络现成方案),升级用户是最后手段非默认出口（41.1）；升级四门槛 G1 破坏性不可逆/G2 范围越界/G3 对外不可撤回发布/G4 语义级目标分叉,门槛外自动消解+登记（41.2）；trivial 小修直接做+登记,禁「留用户裁决」推诿（41.3）；升级前必过消解清单并附「已尝试清单」,D6 硬停点语义保留不弱化（41.4）；多待决项打包呈报附推荐（41.5）；零新 config 键+selftest-self-resolution.sh 守护（41.6）
- **Rule 42（质量审查技能主动检测与补充 — task-v099）**：任务涉及质量审查面时按四级顺序检测（42.1/42.2 项目级→用户级→环境 agents→内置 review-library 兜底池，均未命中=缺口）；缺口按补充合约处置——该任务项目级补建专用质量审查技能且补建动作作为 S-unit 登记进计划，禁无登记私建技能（42.3）；计划「质量审查工具」行登记检测结论，执行期必须用登记工具（42.4）；零新 config 键+mini 档豁免（42.5）；对齐审查前置与收尾消费——写入前版本一致性校验闸门（42.6.1 未经校验不追加）+任务完成前对齐标准流程（42.6.2 全文档过 alignment-review）+变更记录输出（42.6.3）+零新键机制（42.6.4,task-v102）
- **Rule 43（执行可靠性制度化 — task-v099）**：证据先行反幻觉——重要声称必附机器可复现验证证据，未验证内容只能以「未验证」显式登记，子代理 8 字段 evidence 无证据=该项未完成（43.1）；模型档位经济性路由——S-unit 逐行标注建议档位，取最小可承载档，失败先 22.3 升档（43.2）；方案预验证与最优选择——呈报前枚举 ≥2 候选各过最轻验证，候选对比表裁决，验证成本过高降级假设清单（43.3）；C30/C31 消费+零新 config 键+selftest-reliability-institution.sh 守护（43.4）
- **Rule 44（用户选择点默认项与自动超时裁决 — task-v103）**：给用户的所有选择点必设默认选项+自动超时（44.1 默认 5 分钟,询问点可声明覆盖值）;产出一致仅步骤/耗时差异的低区分度选项优先按 41.3 直接裁决登记而非打扰用户（44.2）;用户超时未答复→按推荐默认项自动执行+登记自动裁决记录五要素（44.3,不打断≠不留痕）;零新 config 键+C33 消费+RT 静态守护（44.4）
- **Rule 47（媒体制作任务派发纪律 — task-v122）**：媒体拆分轴=制作阶段×生产单元，单 S-unit=单单元×单阶段（47.1）；具名执行体路由=executor+工序模板 SOP+生成技能，general-purpose 默认兜底禁止、例外登记理由（47.2）；批量生成试点先行联动 Rule 18.9 硬门（47.3）；零新 config 键+selftest-media-dispatch.sh 守护（47.4）
- **Rule 49（单元线多路并行推进 — task-v126）**：可枚举生产单元×序贯工序任务族启用 lane 模型（49.1）；推进三条件=已验收+前置在位+独立性四问（49.2）；满足即派发不等批、跨 Phase 前移双登记、Phase 翻转语义不变（49.3）；汇合点强串行+单写者/单 S-unit 不变（49.4）；零新 config 键+selftest-lane-advancement.sh 守护（49.5）
- **Rule 50（内容要求权重分级与评级 — task-v127）**：复合需求拆原子验收条目表（存在性 P/程度 E × 硬约束 H/评分项 S，50.1）；程度约束词显式成条且未标注默认 H（50.2）；逐条评级 PASS/PARTIAL/FAIL、程度条目双向判（过显眼 FAIL/不可见亦 FAIL，50.3）；加权判定=全 H 过+S 加权≥阈值（50.4）；条目表随任务书派发供 QC 链消费（50.5）；零新 config 键+selftest-requirement-grading.sh 守护（50.6）
- **Rule 51（需求覆盖与完成声称门控 — task-v129）**：需求原文锚定+验证机制先行+完成声称对照门+自缩水禁令+生成前置盘点六子条；零新 config 键+selftest-requirement-coverage.sh 守护（51.6）
- **Rule 52（执行体专业化优先与覆盖矩阵维护 — task-v125）**：派发选型专用体优先——先查覆盖矩阵 `references/agent-coverage.md` 与三登记面（52.1）；三类缺口（A 无具名映射/B 登记指向不存在或名不符实体/C 实体未登记）禁新增，B 类零容忍实体存在性（52.2）；agent 增删改名或登记面改动→矩阵与登记面同任务同步（52.3）；零新 config 键+selftest-agent-coverage.sh 静态守护（52.4）
- **Rule 53（根源解决与决策管辖 — task-v131）**：结果级需求全链工序审计+根源覆盖表（53.1）/根治判据=机制·守卫·载体三选一防复发（53.2）/决策管辖二分反推诿（53.3）/返工成本核算质量优先（53.4）；零新 config 键+selftest-root-resolution.sh 守护（53.5）

## Completion Gate

详见 `references/completion-gate.md`。subagent 返回 "done" 后必须 Read 实际文件验证变更，才能标记 complete。

## Scope Guard / Goal Gate

- **Scope Guard**：`check-scope.sh Write "<file>" task_plan.md` → exit 0=in scope / 1=out / 2=no plan。不在 scope → 停，获授权扩 scope。
- **Goal Gate**：每个 `task_plan.md` 必须含 **Verification Contract**（VC 表）。详见 `references/goal-gate.md`。

## I/O 契约

输入 = 任务描述 / CWD / 已有 plan（恢复时用）；输出 = 规划→plan+思路复述（28.2.1，ask 模式）+确认（silent 模式按 Rule 28 自动通过）/ 执行→checkbox+错误 / 完成→全部 [x]+验证。`config.json#escalation_threshold` 次失败 → AskUserQuestion（交互模式语义见 Rule 28）。示例：`mkdir -p plans/task-001/ && cd $_ && bash <skill>/scripts/init-session.sh`。

## Chain Handoff Contract（链式交接合约）

`chain_mode: linked` / `fan-out` 的 block 交接合约（字段表 + 交接前 6 条件 + 重规划触发条件）**唯一权威源**：`reference.md § Chain Handoff Contract`。执行循环内的交接操作步骤见上方「Chain 区块交接」；`next_skill: general-purpose`。

## References

| 文档 | 用途 |
|------|------|
| `reference.md` | Manus 原则 + 3-Strike + 5Q + Chain Handoff Contract 合约 + Chain Handoff Contract 重规划触发条件 |
| `references/critical-rules.md` | Critical Rules 1-39（含 Rule 13-18/21-23/25-28 关键条款 + 29-32 维护/追踪/学习/防倒退门控 + Rule 33 反思-验证循环 / Rule 34 模板生命周期门控 / Rule 35 执行结论纪律 / Rule 36 技能修改保守化 / Rule 37 任务类型机制画像 / Rule 38 任务难度分级与轻量档 / Rule 39 动态工作流编排 / Rule 40 harness 工具面主动选择 / Rule 41 问题自主消解与升级纪律 / Rule 42 质量审查技能主动检测与补充 / Rule 43 执行可靠性制度化 / Rule 44 用户选择点默认项与自动超时裁决 / Rule 45 注释完整性规范 / Rule 46 子代理单任务专注度 / Rule 47 媒体制作任务派发纪律 / Rule 48 交付总结可定位性与实用性 / Rule 49 单元线多路并行推进 / Rule 50 内容要求权重分级与评级 / Rule 51 需求覆盖与完成声称门控 / Rule 52 执行体专业化优先与覆盖矩阵维护 / Rule 53 根源解决与决策管辖） |
| `references/completion-gate.md` | 子代理验证 + 串行同步 |
| `references/goal-gate.md` | Goal Gate + VC 规则 + 退出标准 |
| `../plan-cost-guard/references/billing.md` | 计费模式 + 子代理成本估算表（Rule 17） |
| `../plan-cost-guard/references/cost-control.md` | 成本控制策略详解（Rule 17 详解） |
| `references/batch-quality-gate.md` | 批量处理质量门控详解（Rule 18 详解：前置 3 问 + 双采样 + Batch Report） |
| `examples.md` | 实际示例 |
| `../plan-collab-router/references/skill-collaboration.md` | 专业技能协同路由权威源（三族画像/触发矩阵/22.3.3 卡壳接管/移交合约） |
| `references/todo-sync.md` | 原生 Todo 同步契约（S1-S5/映射/hook 响应） |
| `templates/knowledge-brief.md` | 任务知识简略要点模板（init-session 第 6 文件；五段:速览/已验证事实/文件锚点/易错点/S-unit 材料包索引） |
| `templates/shared-tracker.md` | 共享内容认领追踪区块模板（Rule 30；task_plan 引用，账本权威源=progress-tracker 技能） |
| `templates/delivery-summary.md` | 终验交付总结五要素模板（终验交付段消费；数据源=verification/progress/report 引用不重写；非计划模板不入 25 口径） |
| `code-review` skill | 代码质量审查（Code Review Gate 调用入口） |
| 外部 skill | `Skill("task-drift-guard")` 漂移检测 / `Skill("plan-resume")` 中断扫描（Rule 15/24 调用入口） / `Skill("progress-tracker")` 共享内容认领追踪（Rule 30 调用入口，协同契约见 ../plan-collab-router/references/skill-collaboration.md） |

---

## 🎯 子代理路由与模型分级（强制 — P0）

**目的**：主进程 = 调度器,所有实际工作派子代理。避免上下文过长质量降低,避免主进程被代码细节/搜索结果/调试日志污染丢失全局视野。

**强制约束**（P0）：执行任何任务时,**先按本表选择 subagent,再开始工作**。违反 = 反模式。

### 路由表（按任务类型）

> **类型适配（Rule 37）**：下表为代码组画像的默认路由；内容类任务（writing/research/publish）按 ../plan-template-kit/references/template-mapping.md §九 机制画像路由到内容类执行体（article-writer 等），不适用 code-assistant/debugger/code-reviewer 行。仅裁剪代码组机制，通用守卫不变。

| 任务类型 | 推荐 subagent | model 档位 | 主进程直接做? | 规模上限 | 超限动作 |
| --- | --- | --- | --- | --- | --- |
| **计划撰写** | `plan-writer` | **sonnet-1** | ❌ | ≤1 plan, ≤500行 | askUser 重拆 |
| **代码编辑（单文件 ≤300 行,≤3 文件）** | `code-assistant` | **haiku-1** | ❌ | ≤3 文件, ≤300行 | 升级 executor |
| **代码编辑（>3 文件 或 >300 行）** | `executor` | **sonnet-1** | ❌ | ≤3 文件, ≤300行 | 升级 executor |
| **代码编辑（重构/瘦身）** | `code-simplifier` | 继承主会话 | ❌ | ≤1 模块, ≤500行 | 升级 executor |
| **构建/编译错** | `build-error-resolver` | **sonnet-1** | ❌ | ≤1 构建错误 | 升级 debugger |
| **修 bug / 根因分析** | `debugger` + `Skill("systematic-debugging")` | **sonnet-1** | ❌ | ≤1 bug, ≤3 文件 | 升级 complex-problem-solver |
| **跑测试/构建** | `code-runner-agent` | mini | ❌ | ≤1 测试套件 | 拆多个命令 |
| **代码库深度分析/体检** | `codebase-analyzer` | **sonnet-1** | ❌ | ≤1 子系统, ≤5 文件 | 拆 Phase |
| **关键词搜索/抓静态页** | `web-search-agent` | mini | ❌ | ≤1 主题, ≤3 query | 改用 research-assistant |
| **github 调研（issue/PR/release/源码）** | `web-search-agent` + `gh CLI` | mini | ❌ | ≤1 主题, ≤3 query | 改用 research-assistant |
| **网页访问（JS 渲染/登录态/交互页）** | Browser Automation（browser-use:control-browser / mcp__node_repl__js） | mini | ❌ | ≤1 批 URL, 单次 ≤120s | 超时降级 web_reader/splash 链 |
| **跨文件搜索定位** | `explore` | mini | ❌ | ≤1 子系统 | 拆多 explore |
| **文档/规范搜索** | `doc-search-agent` | mini | ❌ | ≤1 规范文件 | 拆 doc-search-agent |
| **综合调研（API + 选型 + 风险）** | `Skill("research-assistant")` / `web-search-agent（agent）` | **sonnet-1** | ❌ | ≤1 选型, ≤3 API | 升级 codebase-analyzer |
| **多文件重构 / 跨模块实现** | `executor` | **sonnet-1** | ❌ | ≤1 模块, ≤3 文件 | 拆多 executor |
| **规划 / 架构 / 编排** | `architect` / `planner` / `task-orchestrator` | 继承主会话 | ❌ | ≤1 模块 | 升级 complex-problem-solver 或升级 complex-planner（高复杂度规划备用，GLM5.3/Opus 级） |
| **Code Review / 批判** | `code-reviewer` / `critic` | **sonnet-1** | ❌ | ≤1 PR, ≤3 文件 | 拆评论任务 |
| **漂移检测（高频）** | `Skill("task-drift-guard")` | haiku（内置） | ❌ | 高频(≤3次/phase) | 无需(已节流) |
| **计划系统文件（plans/** 三件套、plan 模板、INDEX/ledger）** | （主进程） | 主会话 | ✅ 允许 | n/a(主进程) | n/a |
| **原生 Todo 同步（TodoWrite/Task 状态更新）** | （主进程） | 主会话 | ✅ 允许 | n/a(主进程) | n/a |
| **业务文档/配置/技能文件（.md/.json/.yaml）** | `code-assistant` / `executor` | haiku-1 / sonnet-1 | ❌ | ≤3 文件, ≤300 行 | 升级 executor |
| **质量审查族（质量校验/审查/QC 实体）** | `quality-auditor` / `quality-check-agent` / `quality-control-agent` / `content-origin-verify-agent` / `doc-sync-verify-agent` | haiku-1 / sonnet-1 | ❌ | ≤1 审查对象 | 拆审查项 |
| **Git 运维族（Git/worktree/记忆运维）** | `git-master` / `git-security-expert` / `worktree-janitor` / `cron-patrol` / `memory-librarian` | mini / haiku-1 / sonnet-1 | ❌ | ≤1 运维项 | 拆多项运维 |
| **营销 SEO 族（营销内容/SEO/有机增长）** | `marketing-content-creator` / `marketing-seo-specialist` / `organic-content-strategist` / `seo-specialist` | haiku-1 / mini | ❌ | ≤1 主题 | 拆 S-unit |
| **数据研究族（数据/API/研究分析）** | `api-tester` / `scientist` / `data-consolidation-agent` / `search-query-analyst` / `log-distiller` | sonnet-1 / haiku-1 | ❌ | ≤1 数据集/主题 | 拆多研究 |
| **文档 UI 族（技术文档/UI/前端）** | `technical-writer` / `ui-designer` / `frontend-developer` | sonnet-1 | ❌ | ≤1 模块 | 拆 S-unit |
| **文章管线补充族（article-* 未登记 10 实体）** | `article-content-editor` / `article-data-fetcher` / `article-field-fixer` / `article-publish-phase-agent` / `article-research-heavy-agent` / `article-research-phase-agent` / `article-reviewer` / `article-site-router` / `article-synthesis-phase-agent` / `article-batch-publisher`（逐行登记与豁免理由见 `references/agent-coverage.md`，Rule 52.1） | 按 agent frontmatter 声明档 | ❌ | ≤1 篇 × 1 相位 | 拆 S-unit |
| **媒体生成工序（视频/图片单体：写词/生成/QC/修正）** | `image-generation-executor` / `video-generation-executor`（在位优先）；缺位回退 `executor` + 工序 variant 模板 SOP + 生成技能（Rule 47.2）+评级契约（Rule 50） | **sonnet-1** | ❌ | ≤1 生产单元 × 1 工序 | 拆 S-unit（Rule 47.1 媒体轴） |
| **剧集创作管线（多集/多镜整链）** | `video-generation-executor` 按集→场→镜逐级拆 Phase/S-unit（Rule 47.1）；组合工序缺位回退 executor | **sonnet-1** | ❌ | ≤1 集 × 1 工序 per S-unit | 拆 Phase |

### 模型档位依据

复用 `~/.zcode/cli/memories/projects/.zcode-c4bb56bd9710299a/memory/agent-model-tiering.md` 既有约定：
- **mini**：机械 IO（CLI 执行、搜索、抓取、簿记）
- **haiku-1**：机械/轻量（验证、格式化、批量 I/O、单文件 ≤3 文件小改）
- **sonnet-1**：判断型（编辑、调试、重构、综合调研、复杂分析）
- **opus**：复杂判断（架构、跨会话编排、spec/plan 起草）
- **继承主会话**：无 model 字段的规划/编排型 agent

### 反模式（主进程禁止）

- ❌ 主进程 `Edit`/`Write` 业务代码（`.ts/.tsx/.js/.jsx/.py/.go/.rs/.java/.c/.cpp/.h/.hpp`）
- ❌ 主进程 `Edit`/`Write` 白名单外文档/配置/技能文件（`.md`/`.json`/`.yaml`——例外仅计划系统文件/原生 Todo/≤3 行 trivial，见 Rule 14）
- ❌ 主进程 `Read` >500 行业务文件后直接改
- ❌ 主进程跑 `npm test` / `cargo build` / `pytest` / `bun test`
- ❌ 全仓 `grep` + `sed` 批量替换
- ❌ 主进程直接接收 `Skill("research-assistant")` 长文（必须 spawn 子代理消化）
- ❌ 主进程直接接收 `Skill("code-review")` / `Skill("systematic-debugging")` 长输出
- ❌ 主进程直接接收 `Agent(subagent_type=codebase-analyzer)` 的体检报告全文
- ❌ Phase 无 `**Executor:**` 字段即开始执行（违反 Rule 25，计划视为无效，须补字段并重跑 attest）

---

## ⏱️ 超时与失败兜底 — Rule 22 落地

派发子代理时必须先看这一节:**执行可能超时/失败,主进程必须有兜底动作**,不是被动等（22.4 上下文预算=prompt 长度/打包检测/步骤枚举计数已机器化：check-dispatch.sh 校验 prompt 字符数 vs prompt_max_chars、多 S-unit 打包与步骤枚举数 vs step_max_steps(task-v081)，挂 dispatch_contract_enforce 档位）。

**步骤 0 — 先查检查点(Rule 22.8.4)**:任何兜底动作执行前,主进程必须先 Read 该子代理的检查点文件(`<plan-dir>/subagent-state/{seq}-{agent_type}.md`,路径见 Handoff 登记表「checkpoint 路径」列)——有实质进度 → 重试 prompt 注入 resume_from 段从断点续做(模板见 `templates/subagent_dispatch.md` 附录);无进度 → 按下表兜底。

**五档兜底(优先级顺序,Rule 22.3 — 拆细先于升档;任一档连续失败 ≥2 次先走 22.3.0 资料先行前置评估——help/man/官方文档→research-assistant/Doc Search Agent/web-search 现成方案,换道义务 22.3.0b,task-v113 演进,五机械档 ①-⑤ 序号不变)**:

| 序 | 兜底动作 | 何时用 | 执行者 |
|---|---------|-------|-------|
| 1 | **改派** | 失败原因是 subagent 类型不匹配(如 explore 接到写代码任务) | 主进程 |
| 2 | **拆细** | 子任务触及 21.1b 步级上限(>2 文件/>100 行/预估 >15min)或超时——第一假设是任务太大而非模型弱;回计划层拆成更小 S-unit 重派,不改模型档位;每子任务限 1 次 | 主进程 |
| 3 | **降档** | 类型对、已拆细仍失败(能力不足)→ 升一档 model(haiku→sonnet→opus) | 主进程 |
| 4 | **主进程接管** | 单文件 ≤300 行、目标明确、可独立验收；接管后须按 Rule 25.3 登记例外理由（白名单⑤） | 主进程 Edit/Read |
| 5 | **AskUserQuestion** | 改派/拆细/降档/接管都失败,或问题需用户决策；交互模式见 Rule 28（ask=选项化询问并回填 Decisions；silent=按推荐项自主处置并登记 silent 决策行；D6 触发时按 28.4.1 降级交付(推荐项=拆细后主进程接管 ≤300 行子集,剩余登记未完成清单)，禁静默空等） | AskUserQuestion 工具 |
> 「prompt 过大/context_exceeded」类失败 → 先走 Rule 35.3 大输入落盘引用（内容写文件+prompt 只放绝对路径与 Read 指令）再考虑 ②拆细，禁止直接失败收场（Rule 35.5 消费侧）。

**触发条件**(任一):
- 子代理返回 `status: failed` 或 `partial` 但关键产出缺失
- 派发超 `config.json#subagent.timeout_by_type[type]`(explore 30min / editor 60min / debugger 60min / executor 120min)
- 子代理返回 `permission_denied` / `context_exceeded` 等不可重试错误
- 同一子任务**连续失败 ≥2 次**(Rule 22.7)→ **强制换档**重试(穷尽 ①-④ 前禁止 STOP);穷尽后仍失败 → **强制 STOP** 报告用户,不进入 Chain block 交接

**登记**(Rule 22.5):
派发前在 task_plan.md `## 🔗 Subagent Handoff 登记表` 填一行(时间/subagent_type/目标/状态);子代理返回 30s 内主进程必须 Read 实际产出 **并紧邻 `Edit findings.md` 回填结论**（「findings 落点」列记段落锚点），两动作完成才勾 `verify_done`;未 Read → findings.md 记"未验证"。Handoff 登记表含 checkpoint 路径列,failed/timeout 行必填。

**反模式(禁止)**:
- ❌ 失败后静默重试同法(违反 Rule 7 三击协议 + Rule 22.3)；同法失败 ≥2 次第 3 次仍同法且不登记换道理由(违反 22.3.0b 换道义务,task-v113)
- ❌ 改派/拆细/降档时无登记(违反 Rule 22.5 流程追溯)
- ❌ 主进程亲自重写 >300 行内容(违反 Rule 14 + Rule 22.1)
- ❌ 失败时直接 `outcome: BLOCKED` 不留证据(违反 Rule 6 错误留痕)

**Provider 失败主动 Scaling(task-v055-fallback)**:网络/400/超时类失败(`model.network.failed`)→ `scripts/subagent-fallback.sh`(probe 预检 / next 决策 / bind 生成 `<type>-fb` 变体 agent 指定 fallback 模型),零消耗改派不计 retry_limit;细则 critical-rules Rule 22.3.1。边界(如实):变体 agent 新会话才对 Agent 工具可见(类型列表会话启动固化);当前会话内兑现 = 新开会话派发或主进程接管。provider 全灭且任务超 ④ 接管上限(单文件 ≤300 行)时禁直接 STOP:先回计划层拆细到每片 ≤300 行单文件再逐片 ④ 接管(22.3.2)。

### 🛡️ 环境级中断自愈(task-v068)
hook 链路对以下中断自动自愈或降噪,sid 护栏下无需人工兜底:①memory 写入哨兵误拦(check-scope 白名单豁免)②无 sid 时 plan-created 兜底清除无认领/过期哨兵 ③本会话(.session-owner 认领者)编辑 task_plan.md 后 PostToolUse 自动重锁 attestation(他会话编辑仍 TAMPERED)④delegation-observe 注入会话级节流 ⑤env sid 兜底链(stdin 缺失时 CLAUDE_CODE_SESSION_ID 承接)。开关键 `config.json#hook_self_heal_enforce`(默认 warn,off 档后续轮接读取,enforce 预留);护栏=sid 匹配,外部篡改仍拒绝。E4 慢注入(Rule 23 O(N))未修,登记 deferred。

## 💻 代码编辑强制隔离

代码编辑派发规则与白名单的**权威源** = 上方 §子代理路由表「代码编辑」三行（322-324）+ ✅ 行白名单；本节只补路由表未覆盖的「修改后验证流程」与 Rule 14 的执行要点指针。

### 修改后验证流程（每个代码修改完成）

1. `Agent(subagent_type: code-runner-agent)` 跑编译/lint/测试；**轻 diff 合并（[task-v094 T-B6]）**：改动 ≤3 文件且 ≤50 行时编译/lint/测试合并单代理一次跑完（不再拆 code-runner/build-error 两轮派发）
2. 测试失败 → `Agent(subagent_type: build-error-resolver)` 修复（轻 diff 场景由同一合并代理内联修复）
3. 通过 → `Skill("code-review")` 上下文隔离审查（Code Review Gate）
4. APPROVED → commit；CHANGES_REQUESTED → 回到子代理修复

**禁止重复**：路由表已说"单文件 ≤300 行派 `code-assistant`"，本节不再列同表，避免双权威源漂移。

---

## 🔍 调研类操作（已外迁 → plan-research-router）

调研路由 SOP 已拆分至卫星技能 `plan-research-router`（正文 = 其 `references/research-routing.md`：路径 1 WebSearch 降级链 / 路径 2 github 调研 / 强制引用格式 / 禁止清单）。主路由 = 调研环节显式 `Skill("plan-research-router")`；github 调研仍可用 gh CLI（上方子代理路由表「github 调研」行不变）。

---

## 🔁 高频漂移纠正（每 2-3 轮 todo，已内敛 → critical-rules.md §15）

> 权威源 = `references/critical-rules.md` Rule 15（触发时机表 15.1 / 纠正条目自动入 Todo 15.2 / 与 Rule 11 的关系 15.3）。摘要：任一触发条件命中立即调 `Skill("task-drift-guard")`（含「用户发出新指令时：A/B/C 判定后做漂移检查」）；⚠️ DRIFT 自动入 todo、🔴 BLOCKED 立即 STOP。

---

## 📚 任务模板库（任务开启期必选）
权威源 = 卫星技能 `plan-template-kit`（`../plan-template-kit/references/` template-mapping.md 决策树/模板清单/互斥 + template-guide.md 定制指南，经 `Skill("plan-template-kit")` 调用或按需 Read）。要点：① 任务开启期按 Rule 16 选模板 → frontmatter `template_type`（`init-session.sh` 自动从 `templates/variant/` 复制；禁止通用 task_plan 套用所有任务）；② 命中 Rule 34.3 沉淀触发 → 按 34.4 提炼新 variant 模板+四点同步（防滥用 34.5）；③ `knowledge-brief`（五段）= `init-session` 第 6 文件，由 `plan-writer` 写入 `<plan-dir>/knowledge-brief.md`，执行期材料包引用其 §1-§5（开关键 `config.json#knowledge_brief_enforce`，默认 warn）；模板选型/定制/沉淀主路由一律 `Skill("plan-template-kit")`，本技能 `templates/variant/` 机械层留守，映射源=卫星 template-mapping §六
