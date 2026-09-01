---
name: task-planner
agent: executor
description: Use when planning, decomposing, or organizing multi-step projects or research tasks expected to require more than 5 tool calls. Also use when resuming work after /clear.
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TodoWrite, TaskCreate, TaskUpdate, TaskList, TaskGet"
user-invocable: true
references:
- reference.md: Manus context engineering 原则 + 决策矩阵 + 3-Strike + 5Q + Scope Guard + Handoff + 重规划触发
- references/critical-rules.md: Critical Rules 1-12 核心执行约束（含 Rule 11 漂移检测、Rule 12 冲突隔离）
- examples.md: 完整执行示例（调研/bugfix/功能开发/错误恢复/并行任务）
- references/completion-gate.md: 子代理验证 + 并行同步
- references/goal-gate.md: Goal Gate + VC 规则 + 退出标准
- references/todo-sync.md: 原生 Todo 同步契约（S1-S5 强制同步时机 + 映射规则 + hook 提醒响应协议）
- references/worktree-isolation.md: 冲突分析与工作树隔离契约（实现类默认首选 + 合并回合约）
- references/billing.md: 计费模式（单次触发）
- task-drift-guard: 周期性漂移检测（Phase 完成后/连续3次工具调用后/切模块前调用）
# hooks: <TOOL-ADAPTED — stub files per tool register hooks via platform-specific config>
# See: ~/.claude/skills/task-planner/SKILL.md (Claude Code) / ~/.zcode/skills/task-planner/SKILL.md (ZCode)
model: opus
---

**[P0]** 禁止跨项目污染 · 禁止虚构 · 修改前必须 Read 并展示 diff · 技能文件修改需逐项授权。发现缺失=STOP 报告，禁止补全。

**Goal**：产出结构化 `task_plan.md`（含 Phases/VC/V-N），按 phase 推进，全 phase complete 后逐条复验 VC，交付 COMPLETE/PARTIAL/BLOCKED。

**[CONTEXT]** 上游：用户任务描述 / CWD / 已有 plan 目录。下游：`plans/{task-id}/task_plan.md` + findings.md/progress.md/verification.md。

**工具**：`Read`/`Write`/`Edit`（计划文件）、`Bash`（脚本）、`Glob`/`Grep`（搜索）、`Agent()`（子代理）、`Skill()`（外部 skill）、`TodoWrite`/`TaskCreate/Update/List`（原生 Todo 同步，契约见 references/todo-sync.md）。

**Code Review 工具**：当 `task_plan.md` 声明 `code_review: required` 时，启用 `Skill("code-review")` 上下文隔离审查（在终验交付前触发）。详见 [Code Review Gate](#code-review-gate代码审查门控)。

### 💡 专业代码编辑最佳实践（鼓励使用，非强制）

**原则**：主进程**不直接** `Edit`/`Write` 业务代码——优先委托子代理解决，主进程仅维护计划和调度。**目的不是"省事"，而是用最少上下文隔离执行，避免主进程被代码细节污染后丢失全局视野。**

**代码编辑场景 → 推荐工具**：

| 场景 | 推荐 | 类型 | 触发条件 |
|------|------|------|----------|
| 单文件代码创建/编辑/重构 | `Agent(subagent_type: code-assistant)` | agent | ≤3 文件、≤300 行变更 |
| 已写代码的简化优化 | `Agent(subagent_type: code-simplifier)` | agent | 代码块完成后主动调用 |
| 修复 bug / 根因分析 | `Skill("systematic-debugging")` + `Agent(subagent_type: debugger)` | skill + agent | 报错/测试失败 |
| 代码质量审查 | `Skill("code-review")` | skill | Phase 完成 / Code Review Gate 触发 |
| AI 生成文风净化（注释/字符串） | `Skill("humanizer")` | skill | 文档/字符串含 AI 味 |
| 调研/搜索资料 | `Skill("research-assistant")` | skill | 需要查资料、找方案、搜报错 |
| 代码+文档简化清理 | `Agent(subagent_type: code-simplifier)` 或 `Agent(subagent_type: claude md)` | agent | 结构优化/清理 |
| 复杂功能开发（多 phase / 跨文件 / 需架构设计） | `Skill("comet")` | skill | phase ≥5、跨多模块、有设计决策待论证 |

**核心价值**：
- **上下文隔离**：子代理独立 context 执行，主进程保持全局视野——这是**首要原因**，不是副作用
- **模型匹配**：各 agent 按任务类型用最优 model tier（编辑 sonnet，审查 opus，简单任务 haiku）
- **质量提升**：专业流程（systematic-debugging 的 5 步、code-simplifier 的语义保留）显著优于主进程手动修

**例外**：纯配置/计划文件（`.md`/`.json`/`.yaml` plan 模板）仍由主进程 `Edit`——这些不是"业务代码"。

**Skill 与 Agent 区分**：Skill 是预设流程/规则（如 systematic-debugging 的 5 步、code-review 的 10 维审查），Agent 是执行体（如 code-assistant 做实际编辑、code-simplifier 做代码瘦身）。Skill 定义"怎么审/怎么修"，Agent 定义"谁来干"。

**何时坚决用子代理**（避免上下文污染的典型场景）：
- 调研/搜索：避免搜索结果挤占主进程 context → `Skill("research-assistant")` / `Agent(subagent_type: web-search-agent)` / `explore`
- 大段代码改写：避免主进程 context 被代码细节淹没 → `Agent(subagent_type: code-assistant)`
- 多文件重构：避免每个文件 diff 都进入主进程 → `Agent(subagent_type: executor)`
- 重读/验证大文件：避免 Read 大文件占用主进程 token → `Agent(subagent_type: explore)`
- 跑测试/构建：避免 stdout/stderr 噪声 → `Agent(subagent_type: code-runner-agent)`

**反模式**：主进程直接 `Read` 大文件 + `Edit` 多文件 + `Bash` 跑测试 = 上下文三连击，快速耗尽 token 且丢失全局视野。

### 🚀 复杂功能开发 → 移交 `/comet` 工作流

**何时移交**：当任务满足以下**任意 3 项**时，停止在 task-planner 内执行，建议用户改用 `/comet`：

- Phase 数 ≥ 5
- 跨多个文件/模块
- 需架构设计或技术选型
- 涉及新功能（feature）而非 bug 修复/小改动
- 需 proposal/design/tasks 三件套归档
- 期望跨会话断点续做

**移交流程**：
1. 总结当前 plan 已有内容（Goal + VC + Phase 列表）
2. 提示用户："此任务复杂度匹配 `/comet`，建议移交"
3. 用户确认 → 引导 `Skill("comet")` 启动 open 阶段
4. comet 接管后续阶段（design→build→verify→archive）

**与 task-planner 区别**：
- task-planner：单会话内多 phase 规划 + 执行（轻量、即时）
- comet：跨会话 5 阶段托管（proposal→design→build→verify→archive）+ guard 门控（重量、可恢复）

## 执行流程图

- [ ] **初始化（哨兵机制）**
  - SessionStart hook 自动写入 `.plan-required` 哨兵（标记"尚未创建计划"）
  - 运行 `bun scripts/session-catchup.ts` 检测中断恢复点
  - 创建 `plans/{task-id}/` 目录，运行 `bash scripts/init-session.sh`
  - **模板优先级**（由 init-session.sh 自动处理，无需手动干预）：
    - 优先：`{project}/.claude/plan-templates/{filename}`（项目级覆盖）
    - 兜底：`~/.zcode/skills/task-planner/templates/{filename}`（内置 5 模板）
    - 定制入口：在项目中创建 `.claude/plan-templates/` 目录，替换任意子文件即可覆盖内置模板
  - **验证**：确认创建了 5 个文件（task_plan.md / findings.md / progress.md / notepad-learnings.md / verification.md）
  - **冲突分析（隔离决策）**：运行 `bash scripts/check-conflicts.sh` → 结果 + 隔离决策写入 task_plan.md「🔀 隔离决策」区块（实现类任务默认首选 worktree，用户可否决）
  - **S1 同步（原生 Todo 建立映射）**：运行 `bash scripts/sync-todos.sh --json` → 用 `TodoWrite`（跨会话/多任务用 `TaskCreate`）为每个 Phase 建一条 todo（subject=`{task-id}/Phase N: title`，当前 Phase=in_progress，其余 pending）；**禁止只建计划不建 Todo**
  - **清除哨兵**：计划创建完成后立即运行 `node ~/.zcode/skills/task-planner/scripts/plan-created.cjs`
  - **门控**：哨兵存在期间，PreToolUse hook 自动拦截所有非 plans/ 路径的 Write/Edit 操作（exit 1 阻断）

- [ ] **计划确认**
  - 展示 `task_plan.md`（含 Phase 列表 + Verification Contract 表）给用户
  - **门控**：等待用户显式 `"yes"` — 无授权禁止执行

- [ ] **Phase 执行循环**（每个 Phase 独立闭环，6 步顺序执行）
  1. **开启 Phase**：`Edit task_plan.md` 当前 Phase 状态 → `in_progress`（Current Phase 同步更新）
  2. **同步 Todo（S2）**：`TodoWrite`/`TaskUpdate` 该 Phase 对应 todo → `in_progress`；步骤 1/2 必须紧邻执行，禁止只做其一
  3. **执行 Phase 工作**：期间收到 `[plan-sync]` hook 提醒 → 立即执行 references/todo-sync.md §4 响应协议（回写计划 + 同步 Todo）；每 `todo_sync_interval_calls`（默认 10）次工具调用内保持计划文档未腐化
  4. **回写计划**：`Edit task_plan.md` Phase 状态 → `complete` + 勾选 checkbox + 记录证据路径；错误记 Errors 表
  5. **同步 Todo + 索引（S2/S4）**：该 Phase todo → `completed`；运行 `bash scripts/sync-todos.sh --index` 刷新 INDEX.md
  6. **[DRIFT CHECK]** 调用 `Skill("task-drift-guard")`
    - ✅ ALIGNED → 继续下一 Phase
    - ⚠️ DRIFT → 记录 progress.md，警觉继续
    - 🔴 BLOCKED → **STOP**，报告用户，等决策
  - **DRIFT CHECK 触发时机（强制）**：Phase 标记 complete 后立即 / 连续 ≥3 次工具调用后 / 切换文件/模块前 / 用户发出新指令时（先按下方「🆕 用户新指令处理」判定）
  - `task-drift-guard` 为只读检测层，发现 BLOCKED 时必须等用户明确决策后再继续

- [ ] **Chain 区块交接（仅 linked/fan-out 模式）**
  - 当前 Block 所有 Phase complete 后：
    1. 更新 Handoff 追踪表对应行（状态=complete + 完成时间）
    2. 验证交接产物存在：`Read` 检查目标文件
    3. 更新下游 Block `depends_on` 状态为 `in_progress`
    4. 调用 `Skill("task-drift-guard")`
  - **handoff 合约**（每次交接前必须满足）：
    ```
    [BLOCK-N COMPLETE] 产物: {path} 大小:{size} 内容确认:{Read 结果摘要}
    → BLOCK-N+1 开始  依赖: {path}
    ```
  - fan-out 模式：多个下游 Block 同时 pending → 并行派发，全部完成才汇合

- [ ] **Code Review Gate**（仅 `code_review: required` 的任务）
  - 触发条件：`task_plan.md` frontmatter 含 `code_review: required`
  - 触发时机：全部 Phase `complete` 之后、终验交付之前
  - 审查范围：本次任务 Write/Edit 修改过的文件，过滤为代码文件（`.py/.ts/.tsx/.js/.jsx/.go/.rs/.java/.c/.cpp/.h/.hpp`），排除 `.md/.json/.yaml/.yml/.txt/.sh/.toml/.cfg`
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
  - subagent 返回 "done" → **必须 Read 实际产出文件**，禁止信任自报
  - **隔离任务合并回**（isolation=worktree 时，按 references/worktree-isolation.md 合约）：worktree 内全 VC 复验且无未提交变更 → 主仓 `git merge wt/<task-id>` → `git worktree remove` + `git branch -d` → 主仓 Read 关键文件复验
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

### 🔁 原生 Todo 同步（强制）

计划文档 = 唯一事实源，原生 Todo（ZCode/Claude 内置 `TodoWrite` / Task 系统）= 执行视图。五个强制同步时机：**S1** 计划创建后建映射 → **S2** Phase 状态变更后紧邻同步 → **S3** 收到 `[plan-sync]` hook 提醒立即回写 → **S4** 会话结束前终态同步 + `sync-todos.sh --index` → **S5** 用户新指令影响计划后先改计划再重映射 Todo。映射规则、工具选择与响应协议详见 `references/todo-sync.md`；阈值在 `config.json#todo_sync_interval_calls` / `config.json#plan_update_interval_minutes`。

### 🆕 用户新指令处理（计划影响判定 — 强制）

会话中用户发出任何新指令/修正/补充时，**执行该指令前**先完成三分类判定：

| 类 | 判定 | 强制动作 |
|----|------|----------|
| A 无影响 | 闲聊/追问/与当前计划无关 | 正常执行，不改计划 |
| B 扩展 | 新需求/加范围/改交付物 | **先重规划再执行**：`Edit task_plan.md`（新增/修改 Phase、VC、执行范围表，注明来源指令与时间）→ 紧邻同步原生 Todo（S5：新增/调整对应条目）→ 向用户复述计划变更 → 再执行 |
| C 矛盾 | 与已确认计划/VC/用户先前决策冲突 | 停止当前写入：更新计划中被推翻部分（标注 superseded + 新内容）→ 同步 Todo（改/删对应条目）→ 展示新旧对比获确认后执行；与用户此前 P0 决策冲突时必须 STOP 等决策 |

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

适用场景：同一个上游产物，多个下游 skill 并行消费。

```
Block 1 (选题) complete
  → 同时派发 Block 2A, Block 2B, Block 2C
  → 全部 complete → Block 3 (汇总)
```

**chain_mode: fan-out 时**：
- 上游 Block 完成后，所有下游 Block 状态变为 `pending`
- 每个 Block 独立执行，互不阻塞
- 汇合点需等所有下游 Block complete 后才继续

### 执行规则

1. **chain_mode 默认 `single`**：只有一个 block，不需要 chain 区块
2. **初始化时填写 chain 区块**：任务开始前根据复杂度选择模式
3. **block 之间用 `---` 分隔**：`task_plan.md` 可按 `---` 分割为多个独立 plan
4. **下游 block 的 Phase 编号可以复用**（各 block 独立计数）

## Critical Rules

详见 `references/critical-rules.md`（Rules 1-16）：
- Rules 1-12：先规划再执行/PreToolUse 阻断/双操作后保存/决策前重读/Phase 更新/记全部错误/永不重复失败/新请求重规划/错误暴露/Scope 变更重规划/漂移检测/冲突隔离
- **Rule 13（P0）子代理隔离强制**：调研/搜索/大文件读取/Read 大文件 必须派子代理（详见下方 §子代理路由与模型分级）
- **Rule 14（P0）代码编辑必须派子代理**：主进程禁止 Edit/Write 业务代码（详见下方 §代码编辑强制隔离）
- **Rule 15（P0）高频漂移纠正强制**：每 2-3 个原生 todo 后必须跑 `Skill("task-drift-guard")`（详见下方 §高频漂移纠正）
- **Rule 16（P0）任务开启期选模板**：禁止用通用 task_plan.md 套所有任务，必须按类型选模板（详见下方 §任务模板库）

## Completion Gate

详见 `references/completion-gate.md`。subagent 返回 "done" 后必须 Read 实际文件验证变更，才能标记 complete。

## Scope Guard

`check-scope.sh Write "<file>" task_plan.md` → exit 0=in scope / 1=out / 2=no plan。不在 scope → 停，获授权扩 scope。

## Goal Gate

每个 `task_plan.md` 必须含 **Verification Contract**（VC 表）。详见 `references/goal-gate.md`。

## I/O 契约

**输入**：任务描述 / CWD / 已有 plan（恢复时用）
**输出**：规划 → plan+确认；执行 → checkbox+错误；完成 → 全部 [x]+验证。`config.json#escalation_threshold` 次失败 → AskUserQuestion。
**示例**：`mkdir -p plans/task-001/ && cd $_ && bash <skill>/scripts/init-session.sh`

## Chain Handoff Contract（链式交接合约）

当 `chain_mode: linked` 或 `fan-out` 时，block 间的交接必须满足以下合约：

| 字段 | 必填 | 说明 |
|------|------|------|
| `passes_to` | ✅ | 下一个 block 依赖的文件路径 |
| `depends_on` | ✅ | 上一个 block 的产物路径 |
| `handoff_status` | ✅ | `pending` / `in_progress` / `complete` / `blocked` |
| `verification_cmd` | ✅ | 验证交接产物合法性的命令 |

**交接前必须满足**：
```
1. 当前 block 所有 Phase = complete
2. 交接产物文件存在且大小 > 0
3. 交接产物通过 verification_cmd 验证
4. Handoff 追踪表已更新
5. 下游 block 的 status 已设为 in_progress
```

`next_skill: general-purpose`。详见 `reference.md § Handoff`。

## References

| 文档 | 用途 |
|------|------|
| `reference.md` | Manus 原则 + 决策矩阵 + 3-Strike + 5Q + Scope Guard + Handoff + 重规划触发 |
| `references/critical-rules.md` | Critical Rules 1-11（含 Rule 11 漂移检测） |
| `references/completion-gate.md` | 子代理验证 + 并行同步 |
| `references/goal-gate.md` | Goal Gate + VC 规则 + 退出标准 |
| `references/billing.md` | 计费模式（单次触发） |
| `examples.md` | 实际示例 |
| `references/todo-sync.md` | 原生 Todo 同步契约（S1-S4/映射/hook 响应） |
| `code-review` skill | 代码质量审查（Code Review Gate 调用入口） |

---

## 🎯 子代理路由与模型分级（强制 — P0）

**目的**：主进程 = 调度器,所有实际工作派子代理。避免上下文过长质量降低,避免主进程被代码细节/搜索结果/调试日志污染丢失全局视野。

**强制约束**（P0）：执行任何任务时,**先按本表选择 subagent,再开始工作**。违反 = 反模式。

### 路由表（按任务类型）

| 任务类型 | 推荐 subagent | model 档位 | 主进程直接做? |
|---------|--------------|-----------|--------------|
| **计划撰写** | `plan-writer` | **sonnet-1** | ❌ |
| **代码编辑（单文件 ≤300 行,≤3 文件）** | `code-assistant` | **haiku-1** | ❌ |
| **代码编辑（>3 文件 或 >300 行）** | `executor` | **sonnet-1** | ❌ |
| **代码编辑（重构/瘦身）** | `code-simplifier` | 继承主会话 | ❌ |
| **构建/编译错** | `build-error-resolver` | **sonnet-1** | ❌ |
| **修 bug / 根因分析** | `debugger` + `Skill("systematic-debugging")` | **sonnet-1** | ❌ |
| **跑测试/构建** | `code-runner-agent` | mini | ❌ |
| **代码库深度分析/体检** | `codebase-analyzer` | **sonnet-1** | ❌ |
| **关键词搜索/抓静态页** | `web-search-agent` | mini | ❌ |
| **github 调研（issue/PR/release/源码）** | `web-search-agent` + `gh CLI` | mini | ❌ |
| **跨文件搜索定位** | `explore` | mini | ❌ |
| **文档/规范搜索** | `doc-search-agent` | mini | ❌ |
| **综合调研（API + 选型 + 风险）** | `research-assistant` | **sonnet-1** | ❌ |
| **多文件重构 / 跨模块实现** | `executor` | **sonnet-1** | ❌ |
| **规划 / 架构 / 编排** | `architect` / `planner` / `task-orchestrator` | 继承主会话 | ❌ |
| **Code Review / 批判** | `code-reviewer` / `critic` | **sonnet-1** | ❌ |
| **漂移检测（高频）** | `Skill("task-drift-guard")` | haiku（内置） | ❌ |
| **纯配置/计划文件（.md/.json/.yaml plan 模板）** | （主进程） | 主会话 | ✅ 允许 |
| **Todo 同步/AGENTS.md 文档编辑** | （主进程） | 主会话 | ✅ 允许 |

### 模型档位依据

复用 `~/.zcode/cli/memories/projects/.zcode-c4bb56bd9710299a/memory/agent-model-tiering.md` 既有约定：
- **mini**：机械 IO（CLI 执行、搜索、抓取、簿记）
- **haiku-1**：机械/轻量（验证、格式化、批量 I/O、单文件 ≤3 文件小改）
- **sonnet-1**：判断型（编辑、调试、重构、综合调研、复杂分析）
- **opus**：复杂判断（架构、跨会话编排、spec/plan 起草）
- **继承主会话**：无 model 字段的规划/编排型 agent

### 反模式（主进程禁止）

- ❌ 主进程 `Edit`/`Write` 业务代码（`.ts/.tsx/.js/.jsx/.py/.go/.rs/.java/.c/.cpp/.h/.hpp`）
- ❌ 主进程 `Read` >500 行业务文件后直接改
- ❌ 主进程跑 `npm test` / `cargo build` / `pytest` / `bun test`
- ❌ 全仓 `grep` + `sed` 批量替换
- ❌ 主进程直接接收 `Skill("research-assistant")` 长文（必须 spawn 子代理消化）
- ❌ 主进程直接接收 `Skill("code-review")` / `Skill("systematic-debugging")` 长输出
- ❌ 主进程直接接收 `Agent(subagent_type=codebase-analyzer)` 的体检报告全文

---

## 💻 代码编辑强制隔离（P0）

**目的**：业务代码的准确性依赖专业 agent 的"读 → 改 → 验证"流水线,主进程直接 Edit 极易因上下文过长而写错或漏改。

### 强制规则

| 变更规模 | 必须派 | 理由 |
|---------|-------|------|
| 单文件 ≤300 行,≤3 文件 | `code-assistant`（haiku-1） | 机械单文件编辑,已降档验证 |
| >3 文件 或 >300 行 | `executor`（sonnet-1） | 跨文件判断需 sonnet |
| 重构 / 性能 / 瘦身 | `code-simplifier` | 专业语义保留 + 复杂度度量 |
| 构建/编译错 | `build-error-resolver`（sonnet-1） | surgical fix,不扩改 |
| 修 bug（需根因定位） | `debugger` + `Skill("systematic-debugging")` | 系统性根因分析 |
| 跨模块实现 | `executor`（sonnet-1） | 跨模块依赖协调 |

### 主进程可以 Edit 的例外

仅以下两类**非业务代码**可主进程直接 Edit：
- **纯配置/计划文件**：`*.md`（计划/文档）、`*.json`（配置）、`*.yaml`/`*.yml`（模板）
- **Todo 同步**：原生 Todo（TodoWrite / TaskCreate）的 status 更新

### 验证流程

每个代码修改完成,必须：
1. `Agent(subagent_type: code-runner-agent)` 跑编译/lint/测试
2. 测试失败 → `Agent(subagent_type: build-error-resolver)` 修复
3. 通过 → `Skill("code-review")` 上下文隔离审查（Code Review Gate）
4. APPROVED → commit;CHANGES_REQUESTED → 回到子代理修复

---

## 🔍 调研类操作（WebSearch + github 双路 — 强制）

**目的**：调研结果易挤压主上下文,且代码准确性需依赖上游 release/issue/源码,不允许仅靠训练知识。

### 路径 1：WebSearch（首选,英文/技术）

| 阶段 | 工具 | 适用 |
|------|------|------|
| 1 | `WebSearch` | 关键词/英文/技术（ZCode 实测可用） |
| 2 | `WebFetch` | 已知 URL 的纯静态页 |
| 3 | `web_reader` MCP / `defuddle` | 需 JS 渲染的页面 |
| 4 | `splash` / Browser Use | 动态页面/需登录态 |
| 5 | `Skill("research-assistant")` → bing-intl → searxng | 中文/多源交叉 |

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
- ❌ 调研结果直接 dump 进主上下文（必须派子代理消化）

---

## 🔁 高频漂移纠正（每 2-3 轮 todo — P0）

**问题**：任务执行中上下文变长,主进程视野变窄,容易偏离原计划（改错文件/跳过 VC/做计划外的事）。Phase 级漂移检测太粗,问题累积到 Phase 完成才暴露已晚。

### 强制密度（P0）

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

### 为什么高频

- Phase 级漂移检测：粗粒度,问题累积数小时才暴露
- todo 级纠正：细粒度,2-3 步内发现,代价小
- `task-drift-guard` 是 haiku 档,token 便宜,可高频跑

### 与现有 Rule 11 关系

Rule 11 仅在 Phase 完成时跑漂移检测；Rule 15 把密度从 Phase 级降到 todo 级,两者并存（Phase 完成 = 粗粒度兜底,todo 完成 = 细粒度主控）。

---

## 📚 任务模板库（任务开启期必选 — P0）

**原则**：每种任务类型有专属模板,任务开启期（创建 task_plan.md 前）必须先选定,确保 VC/Phase/Scope 表与任务类型匹配,避免通用模板应付所有任务导致 VC 漏项。

### 模板清单

| 模板文件 | 适用场景 | 关键 VC 字段 | 推荐 subagent |
|---------|---------|--------------|---------------|
| `templates/task_plan.md`（默认） | 通用规划（无专属匹配时） | 5 条通用 VC | plan-writer |
| `templates/variant/research-type.md` | 关键词调研 / SERP / 竞品 | _channel_attempts[] / 数据源 ≥2 / 覆盖率 ≥80% | research-assistant |
| `templates/variant/diagnostic-type.md` | skill 审计 / bug 排查 / 路径验证 | S59 Read 门 / S64 路径验证 / 证据 sha256 | debugger / codebase-analyzer |
| `templates/variant/writing-type.md` | 长文 / 文章 / 文档撰写 | SEO/可读性/事实核查 | article-writer / content-creator |
| `templates/variant/publish-type.md` | API 发布 / 跨平台分发 | post_id / schema 验证 / 幂等 | article-batch-publisher |
| `templates/variant/code-edit-type.md` | 单文件/多文件代码编辑 | diff 验证 / lint / 测试 / 风格保持 | code-assistant / executor |
| `templates/variant/refactor-type.md` | 代码重构 / 瘦身（行为不变） | 行为不变证明 / 测试通过 / 复杂度下降 | code-simplifier |
| `templates/variant/bugfix-type.md` | bug 修复 / 根因定位 | 复现 / 根因证据 / 修复后回归 | debugger + systematic-debugging |
| **`templates/variant/migration-type.md`**（v2 新增） | 跨语言/框架迁移 / CLI 重写 | 基线归档 / 双跑对照 / 旧入口下线 / 文档更新 | executor + code-assistant + cli-tool-builder |
| **`templates/variant/test-writing-type.md`**（v2 新增） | 单元/集成/E2E 测试编写 | 用例数 ≥N / 覆盖率 ≥X% / 独立性 / 边界 case | test-engineer |
| **`templates/variant/deployment-type.md`**（v2 新增） | 部署 / CI-CD / Docker / k8s / nginx | staging 验证 / 健康检查 / 回滚预案 / 配置审计 | executor + general-purpose |
| **`templates/variant/performance-tuning-type.md`**（v2 新增） | 性能瓶颈定位 / 优化 | 基线 benchmark / P95 降幅 / 无回归 / 资源未恶化 | performance-optimizer + database-optimizer |
| **`templates/variant/schema-migration-type.md`**（v2 新增） | DB schema 变更 / migration | 可逆 up/down / staging 演练 / 数据零丢失 / 在线切换 | database-optimizer |

### 选择决策树（任务开启期执行）

```
任务描述是什么?
├─ 关键词/SERP/数据调研 → research-type
├─ skill 审计/bug 排查 → diagnostic-type
├─ 文章/长文撰写 → writing-type
├─ API 发布/分发（数据推送）→ publish-type
├─ 代码改/写/删（明确单次编辑）→ code-edit-type
├─ 重构（行为不变）/ 瘦身 → refactor-type
├─ 修 bug（用户描述了具体症状）→ bugfix-type
├─ 跨语言/框架迁移 / CLI 重写 → migration-type
├─ 单元/集成/E2E 测试编写 / 覆盖率提升 → test-writing-type
├─ 部署 / CI-CD / Docker / k8s / nginx / 基础设施 → deployment-type
├─ 性能瓶颈定位 / 优化 / 压测 / benchmark → performance-tuning-type
├─ DB schema 变更 / migration / 索引 / 数据回填 → schema-migration-type
└─ 不匹配上述任何一类 → task_plan.md（通用）
```

### 模板互斥关系(避免误选)

| 易混对 | 边界 |
|--------|------|
| publish vs deployment | publish=**数据**推送到 API;deployment=**代码/服务/基础设施**部署 |
| migration vs code-edit | migration=**多步骤**流程(基线锁定→双跑→切流);code-edit=**单次编辑** |
| refactor vs performance-tuning | refactor=**行为不变**前提;performance-tuning=允许**功能+性能**共同变化 |
| test-writing vs code-edit | test-writing 缺**覆盖率门槛/独立性/边界 case**;code-edit 通用编辑 |
| schema-migration vs bugfix | schema-migration=**可逆 up/down** + **在线切换**;bugfix 假设修复即正确 |
| bugfix vs diagnostic | bugfix=**根因已知**进入修复;diagnostic=**根因排查**阶段 |

### 强制约束（P0）

- 任务开启期必须先选模板 → 写进 task_plan.md frontmatter 的 `template_type` 字段
- `init-session.sh` 自动按 `template_type` 从 `templates/variant/` 复制对应文件
- **禁止**用通用 `task_plan.md` 套用所有任务（常见反模式：VC 字段与任务类型不匹配）
- 模板可被项目级 `.claude/plan-templates/` 覆盖（优先级 1,见 `templates/template-guide.md` §一）
- `plan-writer` agent 接收 `template_type` 参数,自动选模板填充
