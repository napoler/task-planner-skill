---
name: todo-skill
description: 将用户大目标拆解为结构化步骤，通过混合模式（Agent 拆解 + 原生 Task 执行 + 持久化同步）逐项推进完成。
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Agent
  - Skill
  - TaskCreate
  - TaskUpdate
  - TaskList
  - TaskGet
model: haiku
---

# Todo Skill

## 目标

将复杂任务拆解为可执行步骤，逐条创建 Todo 推进执行，完成后清理自身 Todo。

## 触发条件

"todo-skill"、"规划执行"、"任务拆解"、"plan and execute"、"break down and execute"

## 用法

- `用 todo-skill 规划并执行 [大任务]`
- `帮我拆解这个任务`
- `检查 todo-skill 进度`

## 工具

| 工具 | 用途 |
|------|------|
| `tools/cli_todo-manager.ts <cmd> [args]` | 持久化任务管理（node 原生 TS，无需编译） |

> 路径说明：工具表中 `tools/...` 为技能目录相对路径；已安装时解析基准 = `~/.zcode/skills/todo-skill/tools/`（cwd≠技能目录时需带全路径调用）。
| `session-kv set/get/del` | 存储/读取/删除计划 |
| `Agent(description=..., prompt=..., subagent_type="general-purpose")` | 任务拆解 |
| `TaskCreate(subject=..., description=...)` | 创建原生 Todo |
| `TaskUpdate(taskId=..., status=...)` | 推进 Todo 状态 |

## 工作流

### Step 1: 创建计划骨架 [M]

```bash
tools/cli_todo-manager.ts plan --goal "<用户目标>" --max_steps 10
```

记录返回的 JSON，确认 `steps` 数组为空（后续由 Agent 填充）。

### Step 2: 任务拆解（Agent） [A]

启动 Agent 子代理，传入用户目标和计划骨架，要求输出结构化 JSON：

```json
{
  "steps": [
    {"id": 1, "title": "步骤标题", "description": "详细描述", "priority": "High|Medium|Low", "depends_on": []},
    ...
  ]
}
```

约束：
- `steps` 数组按执行顺序排列
- `depends_on` 为前置步骤 id 数组，无前驱则为 `[]`
- 每个步骤的 `description` 必须包含可操作的指令，禁止模糊描述
- 步骤总数不超过 `max_steps`

**可选思路**：
1. 思路 A：单 Agent 一次性拆解全量步骤，直接输出完整 `steps` 数组（适用场景：步骤数少（≤10）、依赖关系简单、无需分层细化时）
2. 思路 B：分阶段拆解——先由 Agent 输出高层里程碑，再逐个里程碑展开为可执行步骤（适用场景：任务庞大或边界模糊、单次拆解易遗漏或粒度失当时）

### Step 3: 存储计划 [M]

将 Agent 返回的完整 JSON 通过 session-kv 存储：

```
session-kv set todo-plan '{"steps": [...], "goal": "..."}'
```

### Step 4: 创建 Todo 列表 [M]

对每个步骤，用 TaskCreate 创建带 `[todo-skill]` 前缀的 Todo：

```
TaskCreate(subject="[todo-skill] 步骤N: <title>", description="<description>")
```

### Step 5a: 逐个执行（状态翻转与持久化） [M]

对每个 pending 的 Todo 依次执行状态翻转与持久化：

1. `TaskUpdate(taskId=<id>, status="in_progress")`
2. `TaskUpdate(taskId=<id>, status="completed")`
3. 同步到持久化管理器：`tools/cli_todo-manager.ts update --index N --status completed`

如果某步骤执行失败：
- 保持 Todo 状态为 `in_progress`
- 记录错误到 session-kv：`session-kv set todo-error-<N> "<错误信息>"`
- 尝试重试一次，仍失败则跳过并标记 completed

### Step 5b: 逐个执行（执行步骤操作） [A]

按每个步骤的 `description` 执行对应操作（执行策略需按步骤性质判断）。

**可选思路**：
1. 思路 A：直接顺序执行——按 description 逐条完成操作，不调整顺序（适用场景：步骤独立、顺序确定、无需协调时）
2. 思路 B：先评估依赖再执行——识别步骤间依赖/可并行项，调整执行顺序或合并执行（适用场景：步骤存在前后依赖或可合并执行时）

### Step 6: 清理 [M]

将所有 `[todo-skill]` 前缀的 Todo 标记 completed。

## 约束

- 全程中文沟通
- Todo subject 必须以 `[todo-skill]` 开头
- 执行完毕后清理自身创建的 Todo
- 禁止修改或删除非本技能创建的 Todo
- 步骤间严格按顺序执行，不并行
