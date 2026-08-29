# Plan 技能计费使用指南

## 核心结论

**单次触发**：一次 `/plan` = 一次 opus 调用 = 一次计费。执行中 Read/Write/Bash 不计费。

## 计费规则

| 场景 | 计费 |
|------|------|
| `/plan` 启动任务 | 1次 opus |
| 执行中工具调用（Read/Write/Bash等） | 不计费 |
| 子代理调用 | 按子代理模型独立计费 |
| 中断后用 session-catchup 恢复 | 不计费 |
| 重复调用 `/plan`（同一会话） | 额外计费 ❌ |

## 避免重复计费

- 任务已开始 → 不用再次调用 `/plan`
- 中断恢复 → 用 `session-catchup.ts`
- 变更需求 → Edit task_plan.md 调整，不重新规划
- 新会话重启 → 算新计费（context 已重置）

## 相关脚本

- `session-catchup.ts` — 恢复上下文
- `init-session.sh` — 初始化任务目录
- `check-scope.sh` — 范围检查（不计费）
