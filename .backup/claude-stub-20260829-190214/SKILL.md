---
name: task-planner
model: opus
agent: executor
description: Use when planning, decomposing, or organizing multi-step projects or research tasks expected to require more than 5 tool calls. Also use when resuming work after /clear.
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TaskCreate, TaskUpdate, TaskList, TaskGet"
user-invocable: true
references:
- reference.md: Manus context engineering 原则 + 决策矩阵 + 3-Strike + 5Q + Scope Guard + Handoff + 重规划触发
- references/critical-rules.md: Critical Rules 1-11 核心执行约束（含 Rule 11 漂移检测）
- examples.md: 完整执行示例（调研/bugfix/功能开发/错误恢复/并行任务）
- references/completion-gate.md: 子代理验证 + 并行同步
- references/goal-gate.md: Goal Gate + VC 规则 + 退出标准
- references/billing.md: 计费模式（单次触发）
- task-drift-guard: 周期性漂移检测（Phase 完成后/连续3次工具调用后/切模块前调用）
hooks:
- type: command
  name: SessionStart
  command: "node /home/terry/.claude/skills/task-planner/scripts/task-plan-init.cjs"
  statusMessage: "Checking task plan status..."
- type: command
  name: PreToolUse
  matcher: "Write|Edit"
  command: "bash /home/terry/.claude/skills/task-planner/scripts/check-scope.sh \"${CLAUDE_TOOL_NAME:-Write}\" \"${FILE_PATH:-}\""
  block_on_nonzero: true
- type: command
  name: PostToolUse
  matcher: "Write|Edit"
  command: "echo '[plan] File updated. If this completes a phase, update task_plan.md status.'"
- type: command
  name: Stop
  command: "SD=\"${OPENCODE_SKILL_ROOT:-$HOME/.claude/skills/task-planner}/scripts\"; powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"$SD/check-complete.ps1\" 2>/dev/null || sh \"$SD/check-complete.sh\""
---

**[P0]** 禁止跨项目污染 · 禁止虚构 · 修改前必须 Read 并展示 diff · 技能文件修改需逐项授权。发现缺失=STOP 报告，禁止补全。

**Goal**：产出结构化 `task_plan.md`（含 Phases/VC/V-N），按 phase 推进，全 phase complete 后逐条复验 VC，交付 COMPLETE/PARTIAL/BLOCKED。

**[CONTEXT]** 上游：用户任务描述 / CWD / 已有 plan 目录。下游：`plans/{task-id}/task_plan.md` + findings.md/progress.md/verification.md。

**工具**：`Read`/`Write`/`Edit`（计划文件）、`Bash`（脚本）、`Glob`/`Grep`（搜索）、`Agent()`（子代理）、`Skill()`（外部 skill）、`TaskCreate/Update/List`（进度追踪）。

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
    - 兜底：`~/.claude/skills/task-planner/templates/{filename}`（内置 5 模板）
    - 定制入口：在项目中创建 `.claude/plan-templates/` 目录，替换任意子文件即可覆盖内置模板
  - **验证**：确认创建了 5 个文件（task_plan.md / findings.md / progress.md / notepad-learnings.md / verification.md）
  - **清除哨兵**：计划创建完成后立即运行 `node ~/.claude/skills/task-planner/scripts/plan-created.cjs`
  - **门控**：哨兵存在期间，PreToolUse hook 自动拦截所有非 plans/ 路径的 Write/Edit 操作（exit 1 阻断）

- [ ] **计划确认**
  - 展示 `task_plan.md`（含 Phase 列表 + Verification Contract 表）给用户
  - **门控**：等待用户显式 `"yes"` — 无授权禁止执行

- [ ] **Phase 执行循环**（每个 Phase 独立闭环）
  - 编辑 `task_plan.md`：Phase 状态 `in_progress` → 执行 → `complete`
  - 每步完成后运行 `bash scripts/sync-todos.sh --index`
  - 每 Phase 完成后 → **[DRIFT CHECK]** 调用 `Skill("task-drift-guard")`
    - ✅ ALIGNED → 继续下一 Phase
    - ⚠️ DRIFT → 记录 progress.md，警觉继续
    - 🔴 BLOCKED → **STOP**，报告用户，等决策
  - **DRIFT CHECK 触发时机（强制）**：Phase 标记 complete 后立即 / 连续 ≥3 次工具调用后 / 切换文件/模块前 / 用户发出新指令时
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

详见 `references/critical-rules.md`（Rules 1-10：先规划再执行/PreToolUse 阻断/双操作后保存/决策前重读/Phase 更新/记全部错误/永不重复失败/新请求重规划/错误暴露/Scope 变更重规划）。

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
| `code-review` skill | 代码质量审查（Code Review Gate 调用入口） |
