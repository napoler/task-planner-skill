# Plan 技能计费使用指南（v2.1 更新）

## 核心结论

**单次触发**：一次 `/plan` = 一次 opus 主会话 + N 次子代理调用（独立计费）+ M 次 Skill 嵌套调用。Skill 嵌套 opus 是隐藏成本源。

## 计费规则（v2.1）

| 场景 | 计费 |
|------|------|
| `/plan` 启动任务（主进程） | 1次 opus（必烧） |
| 执行中工具调用（Read/Write/Bash等） | 不计费 |
| **opus Skill 嵌套调用**（systematic-debugging / code-review / brainstorming / writing-plans / comet-*）| **1次 opus / 次（Rule 17.1 节流：同 phase ≤1 次）** |
| 子代理调用（plan-writer / code-assistant / debugger 等）| 按子代理模型独立计费（sonnet-1 / haiku-1 / mini） |
| 高频 task-drift-guard | haiku 档，极便宜（Rule 15 节流：每 phase ≤3 次） |
| 中断后用 session-catchup 恢复 | 不计费 |
| 重复调用 `/plan`（同一会话） | 额外 opus 计费 ❌ |

## 子代理成本估算表（v2.1 新增）

| 子代理 / Skill | model 档位 | 单次 opus 等效 | 频次（典型 phase）| 累计 |
|----------------|-----------|----------------|------------------|------|
| **主会话 opus** | opus | 1.0× | 1 | 1.0 |
| plan-writer | sonnet-1 | ≈ 0.3× | 1 | 0.3 |
| code-assistant | haiku-1 | ≈ 0.05× | 1-3 | 0.05-0.15 |
| code-runner-agent | mini | ≈ 0.02× | 2-5 | 0.04-0.10 |
| task-drift-guard | haiku | ≈ 0.05× | 1-3 | 0.05-0.15 |
| **嵌套 opus Skill** | opus | 1.0× | 0-1（Rule 17.1 节流） | 0-1.0 |
| debugger | sonnet-1 | ≈ 0.3× | 0-1（仅 bugfix） | 0-0.3 |
| **phase 总计** | — | — | — | **≈ 1.5-3.0 opus 等效** |

**对比 naive（全 opus 主进程）**：5-7× opus 等效。
**节流后节省**：约 **50-70%** opus 调用（前提：充分用 subagent 路由 + 节流嵌套 skill）。

详见 `references/cost-control.md` 完整成本控制策略。

## 避免重复计费

- 任务已开始 → 不用再次调用 `/plan`
- 中断恢复 → 用 `session-catchup.ts`
- 变更需求 → Edit task_plan.md 调整，不重新规划
- 新会话重启 → 算新计费（context 已重置）
- **嵌套 opus Skill 复用**:同一 phase 已触发 `Skill("code-review")`,复用其输出而非再次调用（Rule 17.1）
- **plan-writer 复用旧 Decisions Made**:不重新生成同 task_plan（Rule 17.3）

## 单会话 opus 累计门控（Rule 17.5）

opus 累计调用 ≥10 次 → 触发 AskUserQuestion「继续 / 拆型 / 降级」。

| 累计区间 | 建议动作 |
|---------|---------|
| 0-9 次 | 正常执行 |
| 10-15 次 | 询问用户「继续 / 拆 phase / 主进程降 sonnet-1」 |
| >15 次 | 强制 STOP,等用户决策 |

## 相关脚本

- `session-catchup.ts` — 恢复上下文
- `init-session.sh` — 初始化任务目录
- `check-scope.sh` — 范围检查（不计费）
- `templates/cost_log.md` — opus 调用日志（Rule 17.8 配套）
