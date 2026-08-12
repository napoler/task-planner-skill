---
name: task-planner
model: sonnet
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
  name: PreToolUse
  matcher: "Write|Edit|Bash"
  command: "SD=\"${OPENCODE_SKILL_ROOT:-$HOME/.claude/skills/task-planner}/scripts\"; PLAN_DIR=\"$(dirname \"$FILE_PATH\" 2>/dev/null)\"; bash \"$SD/check-scope.sh\" Write \"$FILE_PATH\" \"$PLAN_DIR/task_plan.md\""
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

## 执行流程图

- [ ] **初始化**
  - 运行 `python3 scripts/session-catchup.py` 检测中断恢复点
  - 创建 `plans/{task-id}/` 目录并初始化 `task_plan.md`
  - **门控**：plan 文件不存在 → 禁止后续写入（check-scope.sh 拦截）

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

- [ ] **终验交付**
  - Read `verification.md`
  - 逐条复验 VC（每条带证据路径）
  - subagent 返回 "done" → **必须 Read 实际产出文件**，禁止信任自报
  - 交付结论：`COMPLETE` / `PARTIAL` / `BLOCKED`

### 合规检查清单（每 Phase 开始前逐项确认）

| # | 检查项 | 状态 |
|---|--------|------|
| C1 | 用户任务已复述，目标无歧义 | ☐ |
| C2 | `task_plan.md` 存在且含 Phase + VC 表 | ☐ |
| C3 | 计划已展示并获得用户显式授权 | ☐ |
| C4 | 每个 Phase 完成后已调用 `task-drift-guard` | ☐ |
| C5 | subagent 返回后已 Read 实际产出文件 | ☐ |
| C6 | 全部 VC 逐条复验，有可查证据 | ☐ |
| C7 | 交付结论为 COMPLETE/PARTIAL/BLOCKED 之一 | ☐ |

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

## Handoff Contract

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
