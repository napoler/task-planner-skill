---
name: task-planner
agent: executor
description: Use when planning, decomposing, or organizing multi-step projects or research tasks expected to require more than 5 tool calls. Also use when resuming work after /clear.
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TodoWrite, TaskCreate, TaskUpdate, TaskList, TaskGet"
user-invocable: true
references:
- reference.md: Manus context engineering 原则 + 3-Strike + 5Q + Chain Handoff Contract 合约 + Chain Handoff Contract 重规划触发条件
- references/critical-rules.md: Critical Rules 全集 1-27（1-12 核心执行约束 + 13-27 高级门控，含 Rule 27 git 提交强制）
- examples.md: 完整执行示例（调研/bugfix/功能开发/错误恢复/并行任务）
- references/completion-gate.md: 子代理验证 + 并行同步
- references/goal-gate.md: Goal Gate + VC 规则 + 退出标准
- references/todo-sync.md: 原生 Todo 同步契约（S1-S5 强制同步时机 + 映射规则 + hook 提醒响应协议）
- references/worktree-isolation.md: 冲突分析与工作树隔离契约（实现类默认首选 + 合并回合约）
- references/cost-control.md: 成本控制策略详解（Rule 17 详解）
- references/batch-quality-gate.md: 批量处理质量门控详解（Rule 18 详解：前置 3 问 + 双采样 + Batch Report）
- references/billing.md: 计费模式（单次触发）
- references/template-guide.md: 模板定制指南（模板优先级/项目级 .claude/plan-templates 覆盖/路径规范）
- references/template-mapping.md: 模板分流单一权威源（Rule 16 配套：决策树/模板清单/互斥关系）
- task-drift-guard: 周期性漂移检测（Phase 完成后/连续3次工具调用后/切模块前调用）
- plan-resume: 被动扫描与自主续推（执行中扫描只报告；恢复触发点自主选 1 个中断任务续推，config `autonomous_resume` 控制。详见 Rule 24）
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

### 🚀 复杂功能开发 → 移交 `/comet` 工作流

**何时移交**（满足以下**任意 3 项**即停止在 task-planner 内执行，建议用户改用 `/comet`）：Phase 数 ≥ 5 / 跨多个文件/模块 / 需架构设计或技术选型 / 涉及新功能（feature）而非 bug 修复/小改动 / 需 proposal/design/tasks 三件套归档 / 期望跨会话断点续做。

**移交流程**：总结当前 plan 已有内容（Goal + VC + Phase 列表）→ 提示用户"此任务复杂度匹配 `/comet`，建议移交" → 用户确认 → 引导 `Skill("comet")` 启动 open 阶段 → comet 接管后续阶段（design→build→verify→archive）。

**与 task-planner 区别**：task-planner = 单会话内多 phase 规划 + 执行（轻量、即时）；comet = 跨会话 5 阶段托管（proposal→design→build→verify→archive）+ guard 门控（重量、可恢复）。

> 路径约定：本文件中 scripts/…、references/…、templates/… 等相对路径均相对技能根目录（本 SKILL.md 所在目录）。

## 执行流程图

- [ ] **初始化（哨兵机制）**
  > `[2026-09-10 task-planrequired-race] 哨兵会话私有化`：SessionStart 写会话私有哨兵 `plans/.plan_required_side/<sidkey>.plan_required`（sidkey=uuid core，剥 sess 前缀；写入位置=向上解析的 plans/ 祖先项目根，无 plans/ 祖先不写；sid 缺失不写任何哨兵，fail-open）；legacy `<root>/.plan-required` 不再写入、仅作兼容读取
  - SessionStart hook 自动写入本会话私有哨兵（标记"本会话尚未创建计划"；resume 判定：本会话 side 指针已指向有效计划则哨兵不启用）
  - 运行 `bun scripts/session-catchup.ts` 检测中断恢复点
  - 创建 `plans/{task-id}/` 目录，运行 `bash scripts/init-session.sh`
  - **会话隔离指针（active-plan-race）**：活跃计划经 `resolve-plan-dir.sh [root] [sid]` 双参解析——会话层 `plans/.active_plan_side/<sid>.active_plan`（UserPromptSubmit hook 按 sid 自动认领，TTL 24h）优先于全局 legacy `plans/.active_plan`（兜底），并行会话不再互顶；残留由 `set-active-plan.sh gc` 清扫（详见 `references/critical-rules.md` Rule 22.9）
  - **模板优先级**（由 init-session.sh 自动处理，无需手动干预）：
    - 优先：`{project}/.claude/plan-templates/{filename}`（项目级覆盖）
    - 兜底：`~/.zcode/skills/task-planner/templates/{filename}`（内置 5 模板）
    - 定制入口：在项目中创建 `.claude/plan-templates/` 目录，替换任意子文件即可覆盖内置模板
  - **验证**：确认创建了 5 个文件（task_plan.md / findings.md / progress.md / notepad-learnings.md / verification.md）
  - **冲突分析（隔离决策）**：运行 `bash scripts/check-conflicts.sh` → 结果 + 隔离决策写入 task_plan.md「🔀 隔离决策」区块（实现类任务默认首选 worktree，用户可否决）
  - **S1 同步（原生 Todo 建立映射）**：运行 `bash scripts/sync-todos.sh --json` → 用 `TodoWrite`（跨会话/多任务用 `TaskCreate`）为每个 Phase 建一条 todo（subject=`{task-id}/Phase N: title`，当前 Phase=in_progress，其余 pending）；**禁止只建计划不建 Todo**
  - **清除哨兵**：计划创建完成后立即运行 `node ~/.zcode/skills/task-planner/scripts/plan-created.cjs`（带计划存在性验证，无计划仍 exit 1；双清除：本会话 side 哨兵 + legacy 残留）
  - **门控**：本会话哨兵存在期间，PreToolUse hook 自动拦截所有非 plans/ 路径的 Write/Edit 操作（exit 2 阻断；ZCode 约定 PreToolUse exit 2 = block）；check-time 自动仲裁（D10）：项目内存在 created 时间戳晚于本会话哨兵的有效 task_plan.md 即放行
  - `[2026-09-10 task-path-identity]` 派发契约路径已身份判定化（stat inode / realpath -m），单拼写即可，混拼写兼容

- [ ] **计划确认**
  - 展示 `task_plan.md`（含 Phase 列表 + Verification Contract 表）给用户
  - **门控**：等待用户显式 `"yes"` — 无授权禁止执行；确认后立即 `bash scripts/attest-plan.sh` 锁定，其内置 `check-plan-dispatch.sh` 校验派发型 Phase 是否已规划子代理（S-unit 执行体列，Rule 22.6/25.1；缺失拒绝锁定，`--skip-dispatch-check` 逃生）

- [ ] **Phase 执行循环**（每个 Phase 独立闭环，6 步顺序执行）
  1. **开启 Phase**：`Edit task_plan.md` 当前 Phase 状态 → `in_progress`（Current Phase 同步更新）
  2. **同步 Todo（S2）**：`TodoWrite`/`TaskUpdate` 该 Phase 对应 todo → `in_progress`；步骤 1/2 必须紧邻执行，禁止只做其一
  2.5 **委派检查点（强制 — Rule 25）**：开始实际工作前必查本 Phase `**Executor:**` 字段 → 非"主进程"则**立即按九字段模板（Rule 22.4）逐 S-unit（22.6 表每行一次，严格串行：一次一个、验收通过再派下一个 — Rule 21.4）`Agent()` 派发**并在 Subagent Handoff 登记表登记，主进程只保留派发/回填三文件/验收 Read；Executor=主进程的 Phase 须已带例外理由，无理由 = 先回炉补记再动；**无 Executor 字段 = 计划无效**，先补字段并重跑 attest（Rule 20.1）。禁止"先自己干，干不动再派"。**hook 已机制化**：主进程白名单外 Write/Edit 被 check-delegation.sh 拦截（enforce=exit 2；warn 档注入警告并计数）
  3. **执行 Phase 工作**（内嵌 3-File 落盘强制点，Rule 19）：
     - **3a. 子代理产出回填（19.1）**：每次子代理（Explore / research / debugger / codebase-analyzer 等）或调研类 Skill 返回后，**紧邻一次 `Edit findings.md`** 写入结论摘要 + 证据路径（映射见下方「产出落盘映射」）——禁止让结论只留在会话记忆（context reset 即丢失）；回填完成才可勾 Handoff 登记表 `verify_done`（Read 产出 + findings 回填双条件，见 22.5）
     - **3b. 2-Action Rule（Rule 3）**：每 2 次 view/browser/search 操作后写 findings.md；多模态内容（截图/网页）必须立即转文字落盘
     - **3c. 动作留痕**：关键动作（文件创建/修改、命令执行、测试）随做随记 progress.md 对应 Phase 段；错误发生 → **立即**写 progress.md Error Log（不等 Phase 结束，19.4）。关键动作同步追加工作账本：`bash <skill>/scripts/ledger-append.sh <plan-dir> <event> <summary> [--phase N]`（event 枚举：Phase 翻转=`phase_complete`/子代理回填=`progress`/错误=`error`/门控拦截=`gate_block`/锁定=`attest`/其他=`note`）——ledger 行是 check-3file-gate.sh 的语义工作信号（19.2），无 ledger 时门控退回 mtime 判定
     - **3d. hook 响应**：期间收到 `[plan-sync]` hook 提醒 → 立即执行 references/todo-sync.md §4 响应协议（回写计划 + 同步 Todo）；每 `todo_sync_interval_calls`（默认 10）次工具调用内保持计划文档未腐化；收到 `[plan-compass]` 提醒（findings/progress 陈旧，Rule 19.7）→ 立即回填对应文件再继续；回写内容按三文件分流——状态与指针进 task_plan.md，调研与结论进 findings.md，动作与测试进 progress.md，禁止把 findings 类细节塞进 task_plan.md（Rule 19.6）
  4. **回写计划**：`Edit task_plan.md` Phase 状态 → `complete` + 勾选 checkbox + 记录证据路径；错误记 Errors 表
     - **⚠️ 3-File 回填门控（19.2 — 执行中硬门控）**：标记 complete 前必须满足双条件——① progress.md 对应 Phase 段已回填（Actions taken / Files created-modified / Test Results）；② findings.md 在本 Phase 期间有实质增量。运行 `bash <skill>/scripts/check-3file-gate.sh <plan-dir>` 校验：信号优先级 = ledger 工作账本（`ledger-*.jsonl` 含锚点后的行 = 语义工作证据）> mtime 判定（无 ledger 时兜底）；exit 1 → 禁止翻转 complete，先回填再重跑直至 exit 0
  4.5 **提交工作产物（Rule 27 — git 管理强制）**：实现类 Phase 在标记 complete 前，必须把本 Phase 产物 commit 到当前工作分支（worktree 隔离场景提交在 worktree 内分支；direct 场景提交在主仓当前分支）——**禁止跨 Phase 攒批、禁止留到终验才提交**，丢弃上限收敛为单 Phase 增量。范围 = 本 Phase 实际产出文件（以 scope_files / progress.md「Files created-modified」清单为准），**禁止 `git add -A` / `git add .` 盲扫**（防卷入 plans/、.env、临时文件与并行任务产物；plans/ 按仓约定不入库）。message：`<type>(<scope>): task-<id>/Phase N — <一句话产物摘要>`。提交后 `git status --porcelain -- <scope 文件>` 必须为空；非 git 目录 → progress.md 记一行 `[git-commit] 跳过:非 git 仓库` 不阻塞；豁免（计划声明 `git_commit: deferred` 或用户显式"先不提交"）须已写入计划并登记 verification.md。详见 `references/critical-rules.md` Rule 27
  5. **同步 Todo + 索引（S2/S4）**：该 Phase todo → `completed`；运行 `bash scripts/sync-todos.sh --index` 刷新 INDEX.md
  6. **[DRIFT CHECK]** 调用 `Skill("task-drift-guard")`
    - ✅ ALIGNED → 继续下一 Phase
    - ⚠️ DRIFT → 记录 progress.md，警觉继续
    - 🔴 BLOCKED → **STOP**，报告用户，等决策
  - **DRIFT CHECK 触发时机（强制）**：Phase 标记 complete 后立即 / 连续 ≥3 次工具调用后 / 切换文件/模块前 / 用户发出新指令时（先按下方「🆕 用户新指令处理」判定）
  - **PLAN-RESUME 被动扫描（Rule 24）**：Phase complete 后，**在 DRIFT CHECK 之前**被动调 `Skill("plan-resume")` 扫工作区其他中断任务。产出报告写到 `<cwd>/.zcode/plans/plan-resume-report.md`，主上下文打印摘要（≤5 行）。**当前计划执行中 → 仅报告不续推**（防打断）；恢复触发点（会话启动无活跃计划 / 用户恢复类指令 / 本计划交付终态后）→ 按计划自动打分选 Top 1 **自主续推**（config `autonomous_resume`，守卫：单次 1 个 / skip_states 排除 / 跨仓只报告 / 用户说"不要自动续推"即降级，详见 plan-resume §7）。若用户已在 prompt 说"不要 plan-resume"或任务 ≤3 个 phase → 跳过
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

- 刚写完一个文件 → **不要再 Read**（内容还在上下文里）
- 看过图片/PDF/网页/浏览器/搜索返回 → 立即写 findings.md（多模态内容不持久,转文字落盘）
- 开始新 Phase → 读 plan + findings（上下文可能已陈旧,重新定位）
- 发生错误 → 读相关文件（需要当前真实状态才能修）
- 中断/压缩后恢复 → 读全部三文件（Rule 19.3 顺序重建状态）

- [ ] **Chain 区块交接（仅 linked/fan-out 模式）**
  - 当前 Block 所有 Phase complete 后：
    1. 更新 Handoff 追踪表对应行（状态=complete + 完成时间）
    2. 验证交接产物存在：`Read` 检查目标文件
    3. 更新下游 Block `depends_on` 状态为 `in_progress`
    4. 调用 `Skill("task-drift-guard")`
    5. 调用 `Skill("plan-resume")` 被动扫描（Rule 24）
  - **handoff 合约**（每次交接前必须满足）：
    ```
    [BLOCK-N COMPLETE] 产物: {path} 大小:{size} 内容确认:{Read 结果摘要}
    → BLOCK-N+1 开始  依赖: {path}
    ```
  - fan-out 模式：多个下游 Block 同时 pending → 串行逐个派发（Rule 21.4 铁律），全部完成才汇合

- [ ] **Code Review Gate**（仅 `code_review: required` 的任务）
  - 触发条件：`task_plan.md` frontmatter 含 `code_review: required`
  - 触发时机：全部 Phase `complete` 之后、终验交付之前
  - 审查范围：本次任务 Write/Edit 修改过的文件，过滤为代码文件（`.py/.sh/.ts/.tsx/.js/.jsx/.go/.rs/.java/.c/.cpp/.h/.hpp`），排除 `.md/.json/.yaml/.yml/.txt/.toml/.cfg`
  - 执行步骤：
    1. 收集改动文件清单（从 progress.md / git diff 提取）
    2. 过滤非代码文件 → 待审查列表
    3. 调用 `Skill("code-review")` 上下文隔离审查
    4. 输出 `APPROVED` → 进入终验交付
    5. 输出 `CHANGES_REQUESTED` → 自动追加 fix-phase → 回到执行循环
  - **门控**：`code-review` 输出 `APPROVED` 才允许进入终验交付；否则阻断
  - **失败处理**：`fix-phase` 失败 3 次 → `AskUserQuestion` 决策（继续/停止/降级）

- [ ] **终验交付**
  - Read `verification.md`
  - 逐条复验 VC（每条带证据路径）
  - **委派率统计（Rule 25）**：从各 Phase Executor 字段 + Subagent Handoff 登记表统计「子代理执行 Phase 数 / 总 Phase 数」及主进程直做清单（含理由），写入 verification.md「委派统计」段；委派率 < `config.json#delegation_rate_floor`（默认 0.7）或主进程直做清单含白名单外理由（白名单见 Rule 25.3）或 stats verdict=violation → check-complete.sh `exit 1` 阻断交付,模型需按 violation 清单回炉补 plan 或转 PARTIAL 重跑；**白名单豁免**：rate<floor 但全部直做理由均命中 Rule 25.3 六项白名单 → 不降级（WHITELIST-EXEMPT 放行；jq 缺失 fail-closed，见 Rule 25.4）
  - **3-File Gate（Rule 19.5）**：确认 findings.md/progress.md 存在且非模板 stub——check-complete.sh 已内置校验，缺失/stub → exit 1 → STOP 回填，禁止交付
  - **质量门控统计（Rule 26）**：按 verification.md「质量门控统计」段核查 Q1-Q6 触发与豁免登记；抽查 ≥3 条 Evidence（路径可 Read、结论可复现）；存在未处置违规 → 按 Rule 26.3 降级 outcome；Q3 → outcome 判 BLOCKED 并 STOP
  - subagent 返回 "done" → **必须 Read 实际产出文件**，禁止信任自报
  - **隔离任务合并回**（isolation=worktree 时，按 references/worktree-isolation.md 合约）：worktree 内全 VC 复验且无未提交变更 → 主仓 `git merge wt/<task-id>` → `git worktree remove` + `git branch -d` → 主仓 Read 关键文件复验
  - **git 提交核验（Rule 27 终验联动）**：确认任务 scope 文件无未提交变更（`git status --porcelain -- <scope>` 为空，或各 Phase 已按 27.1 逐 Phase 提交）；遗留未提交 → 先补提交（注明"终验补提交"）再交付，防修改被丢弃
  - 交付结论：`COMPLETE` / `PARTIAL` / `BLOCKED`
  - **退出前**：运行 `bash scripts/check-complete.sh` 验证所有 Phase 已 complete
    - exit 0 → 正常结束
    - exit 1 → STOP，报告未完成任务，不结束会话

### 合规检查清单（每 Phase 开始前逐项确认）

| # | 检查项 | 状态 |
|---|--------|------|
| C1 | 用户任务已复述，目标无歧义 | ☐ |
| C2 | `task_plan.md` 存在且含 Phase + VC 表 | ☐ |
| C3 | 计划已展示并获得用户显式授权 | ☐ |
| C4 | 每个 Phase 完成后已调用 `task-drift-guard` | ☐ |
| C4a | Phase 完成后已运行 `check-drift.sh --json` 输出合法 JSON | ☐ |
| C5 | subagent 返回后已 Read 实际产出文件 | ☐ |
| C6 | 全部 VC 逐条复验，有可查证据 | ☐ |
| C7 | 交付结论为 COMPLETE/PARTIAL/BLOCKED 之一 | ☐ |
| C8 | `code_review: required` 任务已完成 Code Review Gate 且输出 APPROVED | ☐ |
| C9 | Code Review Gate 的 fix-phase（如有）已 complete | ☐ |
| C10 | 计划创建后已按 S1 建立原生 Todo 映射（TodoWrite 或 Task） | ☐ |
| C11 | 每个 Phase 状态变更后已同步 Todo（S2）；`[plan-sync]` 提醒均已响应（S3） | ☐ |
| C12 | 用户新指令已做 A/B/C 影响判定；B/C 类已完成计划 + Todo 同步更新（S5） | ☐ |
| C13 | Phase complete 后已被动调 `Skill("plan-resume")` 扫描中断任务(若用户未说"不要 plan-resume")；执行中扫描只报告,恢复触发点按 Rule 24.5 自主续推(或已按"不要自动续推"降级) | ☐ |
| C14 | 本 Phase 执行体与计划 Executor 字段一致；主进程直做已在计划登记例外理由（Rule 25） | ☐ |
| C15 | 本 Phase 无未处置质量违规：V-N 全勾且 Evidence 非空、Handoff verify_done 已勾、无 Rule 26 触发项（或已豁免登记）（Rule 26） | ☐ |
| C16 | 三文件罗盘可验证：Phase complete 前 `check-3file-gate.sh` exit 0（findings 本 Phase 有增量 + progress Phase 段已回填，Rule 19.2）；Handoff 表各行「findings 落点」已填且 verify_done 已勾（Rule 22.5）；终验前两文件非 stub（Rule 19.5） | ☐ |
| C17 | 本 Phase 产物已按 Rule 27 提交：scope 文件 `git status --porcelain` 为空（或已登记非 git 跳过 / `git_commit: deferred` 豁免 / 无仓内产物） | ☐ |

### 🔁 原生 Todo 同步（强制）

计划文档 = 唯一事实源，原生 Todo（ZCode/Claude 内置 `TodoWrite` / Task 系统）= 执行视图。五个强制同步时机：**S1** 计划创建后建映射 → **S2** Phase 状态变更后紧邻同步 → **S3** 收到 `[plan-sync]` hook 提醒立即回写 → **S4** 会话结束前终态同步 + `sync-todos.sh --index` → **S5** 用户新指令影响计划后先改计划再重映射 Todo。映射规则、工具选择与响应协议详见 `references/todo-sync.md`；阈值在 `config.json#todo_sync_interval_calls` / `config.json#plan_update_interval_minutes`。

### 🆕 用户新指令处理（计划影响判定 — 强制）

会话中用户发出任何新指令/修正/补充时，**执行该指令前**先完成三分类判定：

| 类 | 判定 | 强制动作 |
|----|------|----------|
| A 无影响 | 闲聊/追问/与当前计划无关 | 正常执行，不改计划 |
| B 扩展 | 新需求/加范围/改交付物 | **先重规划再执行**：`Edit task_plan.md`（新增/修改 Phase、VC、执行范围表，注明来源指令与时间）→ 紧邻同步原生 Todo（S5：新增/调整对应条目）→ 向用户复述计划变更 → 再执行 |
| C 矛盾 | 与已确认计划/VC/用户先前决策冲突 | 停止当前写入：更新计划中被推翻部分（标注 superseded + 新内容）→ 同步 Todo（改/删对应条目）→ 展示新旧对比获确认后执行；与用户此前关键决策冲突时必须 STOP 等决策 |

**稳定性铁律**：禁止"口头接受新指令、计划文档与 Todo 不动"——计划外执行是后期执行不稳定与漂移的首要来源。
- 每次 B/C 类变更 → `Decisions Made` 表记一行（指令→变更）+ progress.md 记录
- B/C 类处理完必须再跑 `Skill("task-drift-guard")`
- 配套提醒：UserPromptSubmit hook 在指令到达时注入 `[plan-note]` 判定提示（有活跃计划时）

### 🔀 冲突分析与工作树隔离（默认首选）

**默认策略：实现类任务一律首选 git worktree 隔离开发**——本仓多为运行中的基础设施（skills/hooks/config 被所有会话实时使用），直接改动可能使功能在工作期间半残；隔离后改动发生在副本，验证后原子合并回原分支。仅**纯文档/调研类任务**（只写 plans/ 与 .md）允许直接开发；用户显式否决时才直接开发。

**初始化时强制执行**：
1. 运行 `bash scripts/check-conflicts.sh` → 输出五类冲突信号（①未提交变更 ②额外 worktree ③遗留 wt 分支 ④待处理任务在册 ⑤运行中基础设施改动）
2. 结果 + 隔离决策写入 task_plan.md「🔀 隔离决策」区块，随计划一并展示给用户（默认建议 worktree，用户可否决）
3. 隔离开发期间 **CWD 不迁移**，所有文件操作用 worktree 绝对路径；计划文档留在主仓 plans/（会话级状态不进 worktree）

**完成后主动合并回**（合约见 `references/worktree-isolation.md`）：worktree 内全 VC 复验 → 主仓 `git merge wt/<task-id>` → `git worktree remove` + 删分支 → 主仓 Read 关键文件复验合并结果。复杂场景可配合 `Skill("using-git-worktrees")`。

## Chain 模式详解

### linked（串行接力）

适用场景：同一任务被拆解为多 skill 接力，如 `调研 → 创作 → 发布`。

```
Block 1 (调研) complete
  → handoff: data/{site}/{id}/research/research_data.json
  → Block 2 (创作) depends_on → in_progress
  → Block 2 Phases 执行 → complete
  → handoff: data/{site}/{id}/article/article.json
  → Block 3 (发布) depends_on → in_progress
  → ...
```

**chain_mode: linked 时必须**：
- 每个 block 是独立的 Goal + Phases + VC
- `passes_to` 字段指向下一个 block 的输入文件
- 交接产物必须存在且非空，才能标记下游 block 为 in_progress

### fan-out（一对多派发）

适用场景：同一个上游产物，多个下游 skill 依次消费（派发仍串行 — Rule 21.4）。

```
Block 1 (选题) complete
  → 串行逐个派发 Block 2A → 2B → 2C（Rule 21.4 铁律）
  → 全部 complete → Block 3 (汇总)
```

**chain_mode: fan-out 时**：
- 上游 Block 完成后，所有下游 Block 状态变为 `pending`
- 每个 Block 独立执行，派发仍按 Rule 21.4 串行（互不依赖不构成并行理由）
- 汇合点需等所有下游 Block complete 后才继续

### 执行规则

1. **chain_mode 默认 `single`**：只有一个 block，不需要 chain 区块
2. **初始化时填写 chain 区块**：任务开始前根据复杂度选择模式
3. **block 之间用 `---` 分隔**：`task_plan.md` 可按 `---` 分割为多个独立 plan
4. **下游 block 的 Phase 编号可以复用**（各 block 独立计数）

## Critical Rules

详见 `references/critical-rules.md`（Rules 1-27）：
- Rules 1-12：先规划再执行/PreToolUse 阻断/双操作后保存/决策前重读/Phase 更新/记全部错误/永不重复失败/新请求重规划/错误暴露/Scope 变更重规划/漂移检测/冲突隔离
- **Rule 13（P0）子代理隔离强制**：调研/搜索/大文件读取/Read 大文件 必须派子代理（详见下方 §子代理路由与模型分级）
- **Rule 14（P0）代码编辑必须派子代理**：主进程禁止 Edit/Write 业务代码（详见下方 §代码编辑强制隔离）
- **Rule 15 高频漂移纠正强制**：每 2-3 个原生 todo 后必须跑 `Skill("task-drift-guard")`（详见下方 §高频漂移纠正）
- **Rule 16 任务开启期选模板**：禁止用通用 task_plan.md 套所有任务，必须按类型选模板（详见 `references/template-mapping.md`，模板分流单一权威源）
- **Rule 17 成本控制 — 降低 Opus 使用频率**：嵌套 opus Skill 节流 + 单会话 opus 累计门控 + cost_log 记录（详见 `references/cost-control.md`）
- **Rule 18 批量处理质量门控**：批量操作禁止以牺牲质量/准确性为代价；前置 3 问评估 + 双采样抽检 + 失败率熔断 + Batch Report 八字段（详见 `references/batch-quality-gate.md`）
- **Rule 19（P0）3-File 落盘强制**：三文件（task_plan/findings/progress）= Context Window 是 RAM、Filesystem 是 Disk 的落地——子代理结论必落盘 findings.md（与 Handoff `verify_done` 双条件绑定，22.5）、**3-File 回填门控（19.2）= Phase complete 前置硬门控**（progress 回填 + findings 本 Phase 增量，`check-3file-gate.sh` 校验 exit 1 禁止翻转）、恢复会话先读三文件、终验 3-File Gate 硬校验（19.5）、task_plan.md 瘦身指针制（19.6）、[plan-compass] 及时性提醒链路含二次未响应升级警告（19.7）（详见上方 §产出落盘映射）
- **Rule 20 计划注入与防篡改**：turn-start smart 注入（Goal/Next Step/in_progress Phase 复诵）+ SHA-256 attestation 锁定（篡改即 [PLAN TAMPERED] 拒绝注入）+ 外部内容只进 findings.md（详见 `references/critical-rules.md` Rule 20）
- **Rule 21 子任务拆分与模型分工**：大模型拆分、低档模型执行，单 Phase ≤3 文件 ≤300 行，步级 S-unit ≤2 文件/≤100 行/≤15min 且派发型 Phase 计划期必填 S-unit 表（21.1b/22.6），派发严格串行——一次一个、验收通过再派下一个（21.4 串行派发铁律）（详见 `references/critical-rules.md` Rule 21）
- **Rule 22（P0）子代理规模限制与交接文件**：派发上限/超时档位/九字段 prompt(含上下文预算、三文件读写契约 22.4a、8 字段严格返回 22.4b、派发守卫 22.4c)/兜底拆细先于升档/Handoff 登记表（详见 `references/critical-rules.md` Rule 22）
- **Rule 23 并行任务检测与冲突规避**：--runtime 四级冲突 + fan-out Aggregator 硬校验（详见 `references/critical-rules.md` Rule 23）
- **Rule 24（P1）plan-resume 被动扫描与自主续推**：Phase complete 后扫中断任务；执行中只报告，恢复触发点自主续推 Top 1（v0.5，config `autonomous_resume`；详见 `references/critical-rules.md` Rule 24）
- **Rule 25（P0）子代理委派门控**：Phase 必须声明 Executor 执行体，开启先过委派检查点，主进程直做须登记白名单内例外理由（25.3 六项白名单），终验统计委派率（阈值 `config.json#delegation_rate_floor` 默认 0.7；详见 `references/critical-rules.md` Rule 25）；**计划批准时 attest 内置 `check-plan-dispatch.sh` 校验派发型 Phase 的 S-unit 执行体列（22.6 机制化，缺失拒绝锁定）**
- **Rule 26（P0）质量优先于速度门控**：6 类降质行为可观察触发式 + 确定性惩罚映射（回炉→PARTIAL→BLOCKED），伪造证据无豁免（详见 references/critical-rules.md Rule 26）
- **Rule 27（P0）工作产物及时提交**：实现类 Phase 翻转 complete 前产物必须 commit 到当前工作分支（worktree 逐 Phase 提交 / direct 主仓分支），禁攒批到终验；只 add scope 产物禁盲扫；非 git 目录记行跳过；deferred/用户显式豁免须写入计划（详见 `references/critical-rules.md` Rule 27）

## Completion Gate

详见 `references/completion-gate.md`。subagent 返回 "done" 后必须 Read 实际文件验证变更，才能标记 complete。

## Scope Guard / Goal Gate

- **Scope Guard**：`check-scope.sh Write "<file>" task_plan.md` → exit 0=in scope / 1=out / 2=no plan。不在 scope → 停，获授权扩 scope。
- **Goal Gate**：每个 `task_plan.md` 必须含 **Verification Contract**（VC 表）。详见 `references/goal-gate.md`。

## I/O 契约

输入 = 任务描述 / CWD / 已有 plan（恢复时用）；输出 = 规划→plan+确认 / 执行→checkbox+错误 / 完成→全部 [x]+验证。`config.json#escalation_threshold` 次失败 → AskUserQuestion。示例：`mkdir -p plans/task-001/ && cd $_ && bash <skill>/scripts/init-session.sh`。

## Chain Handoff Contract（链式交接合约）

`chain_mode: linked` / `fan-out` 的 block 交接合约（字段表 + 交接前 6 条件 + 重规划触发条件）**唯一权威源**：`reference.md § Chain Handoff Contract`。执行循环内的交接操作步骤见上方「Chain 区块交接」；`next_skill: general-purpose`。

## References

| 文档 | 用途 |
|------|------|
| `reference.md` | Manus 原则 + 3-Strike + 5Q + Chain Handoff Contract 合约 + Chain Handoff Contract 重规划触发条件 |
| `references/critical-rules.md` | Critical Rules 1-27（含 Rule 13-18/21-23/25-27 关键条款） |
| `references/completion-gate.md` | 子代理验证 + 并行同步 |
| `references/goal-gate.md` | Goal Gate + VC 规则 + 退出标准 |
| `references/billing.md` | 计费模式 + 子代理成本估算表（Rule 17） |
| `references/cost-control.md` | 成本控制策略详解（Rule 17 详解） |
| `references/batch-quality-gate.md` | 批量处理质量门控详解（Rule 18 详解：前置 3 问 + 双采样 + Batch Report） |
| `examples.md` | 实际示例 |
| `references/todo-sync.md` | 原生 Todo 同步契约（S1-S5/映射/hook 响应） |
| `code-review` skill | 代码质量审查（Code Review Gate 调用入口） |

---

## 🎯 子代理路由与模型分级（强制 — P0）

**目的**：主进程 = 调度器,所有实际工作派子代理。避免上下文过长质量降低,避免主进程被代码细节/搜索结果/调试日志污染丢失全局视野。

**强制约束**（P0）：执行任何任务时,**先按本表选择 subagent,再开始工作**。违反 = 反模式。

### 路由表（按任务类型）

| 任务类型 | 推荐 subagent | model 档位 | 主进程直接做? | 规模上限 | 超限动作 |
| --- | --- | --- | --- | --- | --- |
| **计划撰写** | `plan-writer` | **sonnet-1** | ❌ | ≤1 plan, ≤500行 | askUser 重拆 |
| **代码编辑（单文件 ≤300 行,≤3 文件）** | `code-assistant` | **haiku-1** | ❌ | ≤3 文件, ≤300行 | 升级 executor |
| **代码编辑（>3 文件 或 >300 行）** | `executor` | **sonnet-1** | ❌ | ≤3 文件, ≤300行 | 升级 executor |
| **代码编辑（重构/瘦身）** | `code-simplifier` | 继承主会话 | ❌ | ≤1 模块, ≤500行 | 升级 executor |
| **构建/编译错** | `build-error-resolver` | **sonnet-1** | ❌ | ≤1 构建错误 | 升级 debugger |
| **修 bug / 根因分析** | `debugger` + `Skill("systematic-debugging")` | **sonnet-1** | ❌ | ≤1 bug, ≤3 文件 | 升级 ComplexProblemSolver |
| **跑测试/构建** | `code-runner-agent` | mini | ❌ | ≤1 测试套件 | 拆多个命令 |
| **代码库深度分析/体检** | `codebase-analyzer` | **sonnet-1** | ❌ | ≤1 子系统, ≤5 文件 | 拆 Phase |
| **关键词搜索/抓静态页** | `web-search-agent` | mini | ❌ | ≤1 主题, ≤3 query | 改用 research-assistant |
| **github 调研（issue/PR/release/源码）** | `web-search-agent` + `gh CLI` | mini | ❌ | ≤1 主题, ≤3 query | 改用 research-assistant |
| **跨文件搜索定位** | `explore` | mini | ❌ | ≤1 子系统 | 拆多 explore |
| **文档/规范搜索** | `doc-search-agent` | mini | ❌ | ≤1 规范文件 | 拆 doc-search-agent |
| **综合调研（API + 选型 + 风险）** | `research-assistant` | **sonnet-1** | ❌ | ≤1 选型, ≤3 API | 升级 codebase-analyzer |
| **多文件重构 / 跨模块实现** | `executor` | **sonnet-1** | ❌ | ≤1 模块, ≤3 文件 | 拆多 executor |
| **规划 / 架构 / 编排** | `architect` / `planner` / `task-orchestrator` | 继承主会话 | ❌ | ≤1 模块 | 升级 ComplexProblemSolver |
| **Code Review / 批判** | `code-reviewer` / `critic` | **sonnet-1** | ❌ | ≤1 PR, ≤3 文件 | 拆评论任务 |
| **漂移检测（高频）** | `Skill("task-drift-guard")` | haiku（内置） | ❌ | 高频(≤3次/phase) | 无需(已节流) |
| **计划系统文件（plans/** 三件套、plan 模板、INDEX/ledger）** | （主进程） | 主会话 | ✅ 允许 | n/a(主进程) | n/a |
| **原生 Todo 同步（TodoWrite/Task 状态更新）** | （主进程） | 主会话 | ✅ 允许 | n/a(主进程) | n/a |
| **业务文档/配置/技能文件（.md/.json/.yaml）** | `code-assistant` / `executor` | haiku-1 / sonnet-1 | ❌ | ≤3 文件, ≤300 行 | 升级 executor |

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

派发子代理时必须先看这一节:**执行可能超时/失败,主进程必须有兜底动作**,不是被动等。

**步骤 0 — 先查检查点(Rule 22.8.4)**:任何兜底动作执行前,主进程必须先 Read 该子代理的检查点文件(`<plan-dir>/subagent-state/{seq}-{agent_type}.md`,路径见 Handoff 登记表「checkpoint 路径」列)——有实质进度 → 重试 prompt 注入 resume_from 段从断点续做(模板见 `templates/subagent_dispatch.md` 附录);无进度 → 按下表兜底。

**五档兜底(优先级顺序,Rule 22.3 — 拆细先于升档)**:

| 序 | 兜底动作 | 何时用 | 执行者 |
|---|---------|-------|-------|
| 1 | **改派** | 失败原因是 subagent 类型不匹配(如 explore 接到写代码任务) | 主进程 |
| 2 | **拆细** | 子任务触及 21.1b 步级上限(>2 文件/>100 行/预估 >15min)或超时——第一假设是任务太大而非模型弱;回计划层拆成更小 S-unit 重派,不改模型档位;每子任务限 1 次 | 主进程 |
| 3 | **降档** | 类型对、已拆细仍失败(能力不足)→ 升一档 model(haiku→sonnet→opus) | 主进程 |
| 4 | **主进程接管** | 单文件 ≤300 行、目标明确、可独立验收；接管后须按 Rule 25.3 登记例外理由（白名单⑤） | 主进程 Edit/Read |
| 5 | **AskUserQuestion** | 改派/拆细/降档/接管都失败,或问题需用户决策 | AskUserQuestion 工具 |

**触发条件**(任一):
- 子代理返回 `status: failed` 或 `partial` 但关键产出缺失
- 派发超 `config.json#subagent.timeout_by_type[type]`(explore 30min / editor 60min / debugger 60min / executor 120min)
- 子代理返回 `permission_denied` / `context_exceeded` 等不可重试错误
- 同一子任务**连续失败 ≥2 次**(Rule 22.7)→ **强制 STOP** 报告用户,不进入 Chain block 交接

**登记**(Rule 22.5):
派发前在 task_plan.md `## 🔗 Subagent Handoff 登记表` 填一行(时间/subagent_type/目标/状态);子代理返回 30s 内主进程必须 Read 实际产出 **并紧邻 `Edit findings.md` 回填结论**（「findings 落点」列记段落锚点），两动作完成才勾 `verify_done`;未 Read → findings.md 记"未验证"。Handoff 登记表含 checkpoint 路径列,failed/timeout 行必填。

**反模式(禁止)**:
- ❌ 失败后静默重试同法(违反 Rule 7 三击协议 + Rule 22.3)
- ❌ 改派/拆细/降档时无登记(违反 Rule 22.5 流程追溯)
- ❌ 主进程亲自重写 >300 行内容(违反 Rule 14 + Rule 22.1)
- ❌ 失败时直接 `outcome: BLOCKED` 不留证据(违反 Rule 6 错误留痕)

**Provider 失败主动 Scaling(task-v055-fallback)**:网络/400/超时类失败(`model.network.failed`)→ `scripts/subagent-fallback.sh`(probe 预检 / next 决策 / bind 生成 `<type>-fb` 变体 agent 指定 fallback 模型),零消耗改派不计 retry_limit;细则 critical-rules Rule 22.3.1。边界(如实):变体 agent 新会话才对 Agent 工具可见(类型列表会话启动固化);当前会话内兑现 = 新开会话派发或主进程接管。

## 💻 代码编辑强制隔离

代码编辑派发规则与白名单的**权威源** = 上方 §子代理路由表「代码编辑」三行（322-324）+ ✅ 行白名单；本节只补路由表未覆盖的「修改后验证流程」与 Rule 14 的执行要点指针。

### 修改后验证流程（每个代码修改完成）

1. `Agent(subagent_type: code-runner-agent)` 跑编译/lint/测试
2. 测试失败 → `Agent(subagent_type: build-error-resolver)` 修复
3. 通过 → `Skill("code-review")` 上下文隔离审查（Code Review Gate）
4. APPROVED → commit；CHANGES_REQUESTED → 回到子代理修复

**禁止重复**：路由表已说"单文件 ≤300 行派 `code-assistant`"，本节不再列同表，避免双权威源漂移。

---

## 🔍 调研类操作（WebSearch + github 双路 — 强制）

**目的**：调研结果易挤压主上下文,且代码准确性需依赖上游 release/issue/源码,不允许仅靠训练知识。

### 路径 1：WebSearch（首选,英文/技术）

阶段与工具：**①WebSearch**（关键词/英文/技术，ZCode 实测可用）→ **②WebFetch**（已知 URL 纯静态页）→ **③web_reader MCP / defuddle**（需 JS 渲染）→ **④splash / Browser Use**（动态页/登录态）→ **⑤Skill("research-assistant") → bing-intl → searxng**（中文/多源交叉）。

### 路径 2：github 调研（代码准确性必备）

```bash
# Issue/PR 调研
gh issue list --repo <owner>/<repo> --search "<kw>" --state all --limit 30
gh pr list --repo <owner>/<repo> --search "<kw>" --state all
gh release list --repo <owner>/<repo> --limit 10

# 源码调研
gh api repos/<owner>/<repo>/contents/<path>          # 文件列表
gh api repos/<owner>/<repo>/contents/<path> --jq '.content' | base64 -d  # 文件内容

# WebSearch 补充
WebSearch "<library> github issues <symptom>"
```

### 强制引用格式

写到 `task_plan.md` 的「Decisions Made」表"参考依据"列：

- 上游库：`https://github.com/<owner>/<repo>/blob/<sha>/<path>#L<line>`（必须含 Commit SHA 或 Release tag）
- Issue/PR：`https://github.com/<owner>/<repo>/issues/<n>` 或 `.../pull/<n>`
- 官方文档：`URL + 文档版本号`

### 禁止

- ❌ 只靠训练知识写代码而不查上游 release notes
- ❌ 引用"npm 包官网首页"作为唯一依据（应到源码/issue/release）
- ❌ github 调研用 WebFetch 抓 HTML（应直接 `gh api` 拿 JSON）

（其他调研类反模式见上方 §反模式 353-361 行）

---

## 🔁 高频漂移纠正（每 2-3 轮 todo）

**问题**：任务执行中上下文变长,主进程视野变窄,容易偏离原计划（改错文件/跳过 VC/做计划外的事）。Phase 级漂移检测太粗,问题累积到 Phase 完成才暴露已晚。

### 强制密度

执行过程中,以下任一条件命中立即调用 `Skill("task-drift-guard")`（model: haiku,token 便宜）：

| 触发时机 | 说明 |
|---------|------|
| **每完成 2-3 个原生 todo 条目后** | 最高频,2-3 步内发现问题 |
| **切换模块/文件前** | 确认未越界 |
| **连续 ≥3 次工具调用后** | 防止连续跑偏 |
| **Phase 标记 complete 后** | Phase 级门控（已存在 Rule 11） |
| **用户发出新指令时** | A/B/C 判定后做漂移检查 |

### 纠正条目入 Todo（自动）

| task-drift-guard 输出 | 动作 |
|---------------------|------|
| ✅ ALIGNED | 不入 todo,继续 |
| ⚠️ DRIFT | **自动追加 todo 条目**：`[drift-fix] {问题描述}`（activeForm: 纠正漂移）,用户决策后执行 |
| 🔴 BLOCKED | **立即 STOP**；**不自动入 todo**（避免静默改向）,必须报告用户等决策 |

### 为什么高频 / 与 Rule 11 关系

- Phase 级漂移检测（Rule 11）：粗粒度,问题累积数小时才暴露
- todo 级纠正（Rule 15）：细粒度,2-3 步内发现,代价小
- `task-drift-guard` 是 haiku 档,token 便宜,可高频跑
- 两者并存：Phase 完成 = 粗粒度兜底,todo 完成 = 细粒度主控

---

## 📚 任务模板库（任务开启期必选）

> **权威源声明**：模板分流决策树、模板清单与互斥关系的**单一权威源** = `references/template-mapping.md` §一（决策树）/ §六（模板清单）/ §七（互斥关系）。执行时按需 Read；本节仅保留流程约束与模板集成侧独有的强制要求。

**原则**：每种任务类型有专属模板,任务开启期（创建 task_plan.md 前）必须先选定,确保 VC/Phase/Scope 表与任务类型匹配,避免通用模板应付所有任务导致 VC 漏项。

### 强制约束（模板集成侧独有 — 模板分流细节以 template-mapping.md 为准）

- 任务开启期必须先选模板 → 写进 task_plan.md frontmatter 的 `template_type` 字段
- `init-session.sh` 自动按 `template_type` 从 `templates/variant/` 复制对应文件
- **禁止**用通用 `task_plan.md` 套用所有任务（常见反模式：VC 字段与任务类型不匹配）
- **所有模板统一含 `## 📚 必要知识储备` 章节**（任务知识库对齐）：计划创建时填写本任务依赖的规范/官方文档/内部知识库/文献/图书，Phase 1 开工前逐项确认「必读」项可获取；缺失 → STOP 记入 Errors，禁止凭记忆硬写
- 模板可被项目级 `.claude/plan-templates/` 覆盖（优先级 1,见 `references/template-guide.md` §一）；`plan-writer` agent 接收 `template_type` 参数,自动选模板填充
