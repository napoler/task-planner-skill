---
name: task-planner
model: sonnet
context: fork
agent: executor
description: Use when planning, decomposing, or organizing multi-step projects or research tasks expected to require more than 5 tool calls. Also use when resuming work after /clear.
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TaskCreate, TaskUpdate, TaskList, TaskGet"
user-invocable: true
references:
- reference.md: Manus context engineering 原则 + 决策矩阵 + 3-Strike + 5Q + Scope Guard + Handoff + 重规划触发
- references/critical-rules.md: Critical Rules 1-10 核心执行约束
- examples.md: 完整执行示例（调研/bugfix/功能开发/错误恢复/并行任务）
- references/completion-gate.md: 子代理验证 + 并行同步
- references/goal-gate.md: Goal Gate + VC 规则 + 退出标准
- references/billing.md: 计费模式（单次触发）
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

## Workflow

```
FIRST: python3 <skill>/scripts/session-catchup.py "$(pwd)"   # 中断恢复
STEP1: mkdir -p plans/task-XXX/ && cd $_ && bash <skill>/scripts/init-session.sh
STEP2: 展示 task_plan.md 计划 → 等 "yes" → 执行
STEP3: 每 phase 完 Edit task_plan.md (in_progress→complete) + bash <skill>/scripts/sync-todos.sh --index
STEP4: 全部 complete → Read verification.md → 逐条复验 VC → 交付 COMPLETE/PARTIAL/BLOCKED
```

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
| `references/critical-rules.md` | Critical Rules 1-10 |
| `references/completion-gate.md` | 子代理验证 + 并行同步 |
| `references/goal-gate.md` | Goal Gate + VC 规则 + 退出标准 |
| `references/billing.md` | 计费模式（单次触发） |
| `examples.md` | 实际示例 |
