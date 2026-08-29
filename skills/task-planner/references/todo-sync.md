# 原生 Todo 同步契约（Native Todo Sync Contract）

> **事实源声明**：`task_plan.md` 是唯一事实源（single source of truth）；原生 Todo（ZCode/Claude 内置 TodoWrite 或 Task 系统）只是**执行视图**。二者不一致时，以 task_plan.md 为准重建 Todo，禁止反向覆盖计划文档。

## 1. 工具选择

| 场景 | 用什么 | 说明 |
|------|--------|------|
| 默认（单会话、Claude/ZCode 通用） | `TodoWrite` | 内置 todo 清单，实时可视，最通用 |
| 跨会话恢复 / 多任务编排 / 子代理可见 | `TaskCreate` + `TaskUpdate` + `TaskList` | 持久化任务系统，`sync-todos.sh --index` 的 INDEX.md 可直接转译为 Task |

**规则**：二选一即可，禁止同一 Phase 双写两套 todo（会漂移）。会话内默认 TodoWrite；需要断点续做或多任务并行时用 Task 系统并保持唯一。

## 2. 映射规则

| task_plan.md | 原生 Todo | 说明 |
|--------------|-----------|------|
| 每个 `### Phase N: <title>` | 一条 todo | subject 格式：`{task-id}/Phase N: title`（与 `sync-todos.sh` 输出一致） |
| `**Status:** pending` | `pending` | 未开始的 Phase 不强制预建，按需 |
| `**Status:** in_progress` | `in_progress` | 同时只允许一条 in_progress |
| `**Status:** complete` | `completed` | 必须带证据（文件/命令输出），见 completion-gate |
| Goal / VC 表 | 不建 todo | VC 复验走终验流程，不是待办项 |

## 3. 强制同步时机（S1–S5，全部强制）

| # | 时机 | 动作 |
|---|------|------|
| S1 | 计划创建后（init-session.sh 完成、哨兵清除前） | 运行 `sync-todos.sh --json` → 按映射规则建立全部 Phase 的 todo（一条 in_progress + 其余 pending） |
| S2 | Phase 状态每次变更后（in_progress / complete） | `Edit task_plan.md` 状态行 + 同步该条 todo 状态，**两步必须紧邻执行，禁止只做其一** |
| S3 | 每 `todo_sync_interval_calls`（默认 10）次工具调用 | 收到 `[plan-sync]` hook 提醒 → 执行第 4 节响应协议 |
| S4 | 会话结束前（交付 COMPLETE/PARTIAL/BLOCKED 之前） | 终态同步：全部 todo 终结 + `sync-todos.sh --index` 刷新 INDEX.md + 计划文档终态一致 |
| S5 | 用户新指令影响计划后（扩展 B / 矛盾 C） | 先 `Edit task_plan.md`（Phase/VC/执行范围，注明来源指令与时间）→ 紧邻完成 Todo 重映射（增/改/删对应条目）→ 复述变更后再执行；**禁止口头接受新指令而不落盘**（判定规则见 SKILL.md § 用户新指令处理） |

## 4. Hook 提醒响应协议

PostToolUse hook（`zcode-posttooluse.sh`）在检测到**计划文档超龄**（> `plan_update_interval_minutes`，默认 15 分钟）或**工具调用达到阈值**（`todo_sync_interval_calls`，默认 10）时，注入 `[plan-sync]` 提醒。**陈旧提醒触发后进入冷却**（`stale_remind_cooldown_calls`，默认 10 次调用内不再重复催）；已完结计划（outcome 为 COMPLETE/BLOCKED）不再提醒。收到提醒后必须立即执行三步：

```
1. Edit task_plan.md        → 回写进度（当前 Phase 的 checkbox / 状态 / Errors 表）
2. TodoWrite / TaskUpdate   → 同步原生 Todo 状态
3. bash scripts/sync-todos.sh --index   → 刷新 INDEX.md（校验解析一致）
```

hook 提醒是**阻断性提示**：不响应则同一提醒会在后续调用中反复出现，且违反 Critical Rules（计划腐化 = 目标丢失）。

另有 UserPromptSubmit hook 在用户每条指令到达时注入 `[plan-note]` 提示（有活跃计划时）：提示先做 A/B/C 影响判定，命中 B/C 按 S5 处理——计划变更三步同上（回写计划 → Todo 重映射 → INDEX 刷新）。

## 5. 命令速查

```bash
# Phase→Todo 同步报告（JSON，机器可读；agent 据此调 TodoWrite/TaskUpdate）
bash <skill>/scripts/sync-todos.sh --json

# 刷新 plans/INDEX.md（跨任务注册表；S4 / 恢复会话时必跑）
bash <skill>/scripts/sync-todos.sh --index

# 手动检测计划文档陈旧度（0=新鲜 1=STALE 需回写 2=无计划）
bash <skill>/scripts/check-doc-sync.sh [task_plan.md 路径] [最大陈旧分钟数]
```

阈值配置：`config.json#todo_sync_interval_calls` / `config.json#plan_update_interval_minutes`。

## 6. 反模式（禁止）

- ❌ 只建不同步：S1 建了 todo，之后 Phase 完成从不更新
- ❌ 单边操作：只改 task_plan.md 不动 todo，或只动 todo 不回写文档
- ❌ 用 todo 替代计划文档：todo 里写细节、plan 文档停在初始状态
- ❌ 双写漂移：同一进度同时维护 TodoWrite 和 Task 两套
- ❌ 忽略 `[plan-sync]` 提醒继续埋头干活
- ❌ 口头接受新指令：只应承、计划与 Todo 均不更新（违反 S5，后期执行漂移之源）
