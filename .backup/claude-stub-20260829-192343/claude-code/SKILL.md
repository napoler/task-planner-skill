---
name: task-planner
description: 任务规划与进度追踪 | 计划文档 ↔ 原生 Todo 双向同步 | 漂移检测 | 冲突分析
model: opus
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TaskCreate, TaskUpdate, TaskList, TaskGet"
user-invocable: true
---

# task-planner — Claude Code 适配薄壳

> **多工具架构说明**：本文件是 task-planner skill 的 **Claude Code 适配薄壳**。canonical source 位于独立 git 项目 `~/dev/task-planner/`。本薄壳不持有任何内容实现，只声明 Claude Code 平台特定的 hook 配置 + 路径解析契约。
>
> **路径解析**：`${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}` — 优先级
> 1. 环境变量 `TASK_PLANNER_ROOT`（hook 注入或 shell export）
> 2. canonical 仓 `$HOME/dev/task-planner`
>
> **升级同步**：canonical 仓的 `git pull` 后，本薄壳自动生效（所有内容通过 `TASK_PLANNER_ROOT` 解析）。

---

## Hooks（Claude Code settings.json 风格）

> **注册方法**：复制以下 JSON 到 `~/.claude/settings.local.json` 或项目级 `.claude/settings.local.json` 的 `hooks` 字段。也可运行 `bun run ~/.claude/skills/task-planner/scripts/register-hooks-cj.ts` 自动 patch。

```json
{
  "hooks": {
    "SessionStart": [
      {
        "tags": ["*"],
        "command": "bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/task-plan-init.cjs"
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/check-scope.sh \"${CLAUDE_TOOL_NAME:-Write}\" \"${FILE_PATH:-}\""
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/check-doc-sync.sh"
      }
    ],
    "UserPromptSubmit": [
      {
        "command": "bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/zcode-userpromptsubmit.sh"
      }
    ],
    "Stop": [
      {
        "command": "SD=\"${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts\"; powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"$SD/check-complete.ps1\" 2>/dev/null || sh \"$SD/check-complete.sh\""
      }
    ]
  }
}
```

> **5 hooks 全部启用**：zcode 端已实现的 5 hook 链路（SessionStart 哨兵 / PreToolUse 范围检查 / PostToolUse 计划陈旧提醒 / UserPromptSubmit 影响判定 / Stop 完成检测）通过上述 JSON 在 Claude Code 端等价实现。

---

## 内容引用（运行时通过 $TASK_PLANNER_ROOT 解析）

| 资源 | 路径 |
|------|------|
| 核心规则 | `${TASK_PLANNER_ROOT}/references/critical-rules.md` |
| Todo 同步契约 | `${TASK_PLANNER_ROOT}/references/todo-sync.md` |
| 工作树隔离契约 | `${TASK_PLANNER_ROOT}/references/worktree-isolation.md` |
| 模板选型 | `${TASK_PLANNER_ROOT}/references/template-mapping.md` |
| 模板定制 | `${TASK_PLANNER_ROOT}/references/template-guide.md` |
| 目标门控 | `${TASK_PLANNER_ROOT}/references/goal-gate.md` |
| 完成门控 | `${TASK_PLANNER_ROOT}/references/completion-gate.md` |
| 计费模式 | `${TASK_PLANNER_ROOT}/references/billing.md` |
| 脚本集 | `${TASK_PLANNER_ROOT}/scripts/` |
| 内置模板 | `${TASK_PLANNER_ROOT}/templates/` |
| 变体模板 | `${TASK_PLANNER_ROOT}/templates/variant/` |

> 完整流程参见 canonical source 的 `README.md` + `WORKFLOW.md` + `examples.md` + `reference.md`。

---

## 关键约束

1. **禁止在 stub 内编辑内容**：stub 唯一可变文件 = `SKILL.md`（含 hook 配置）。内容修改一律在 canonical 仓进行。
2. **更新方式**：`cd ~/dev/task-planner && git pull` — 引用自动传播。
3. **跨平台注意**：`check-complete.ps1` 是 Windows fallback，POSIX 环境自动用 `.sh`。
4. **stub 备份**：stub 重写前已备份到 `~/dev/task-planner/.backup/claude-stub-YYYYMMDD-HHMMSS/`。
