# Critical Rules — 核心执行规则

> 以下为 task-planner 的强制行为约束。详见 § 十-6 安全执行原则。

### 1 先规划，再执行
创建 `task_plan.md` → 展示计划 → 等 "yes" → 执行。

### 2 PreToolUse 强制阻断
`task_plan.md` 不存在时 `check-scope.sh` 返回 exit 2，hook 阻止非初始化写入。

### 3 双操作后立即保存
每 `config.json#max_view_browser_before_save` 次 view/browser/search 后写 findings.md。

### 4 决策前重读计划
重大决策前读 `task_plan.md`。

### 5 Phase 完成后更新
标记 `in_progress` → `complete`，记录错误和文件。

### 6 记全部错误
错误 → `task_plan.md` Errors + `progress.md` Error Log。

### 7 永不重复失败
`action_failed: next_action != same_action`。详见 `reference.md § 三击协议`。

### 8 新请求强制重新规划（三分类判定）
新请求 = 重规划触发器：停 → 记 `notepad-learnings.md` → A/B/C 影响判定（A 无影响照常执行 / B 扩展 / C 矛盾，详见 SKILL.md § 用户新指令处理）→ **凡影响计划（B/C）：先更新 task_plan.md 对应 Phase/VC/范围，并紧邻同步原生 Todo（todo-sync.md S5），再执行** → 确认 → 继续。禁止口头接受新指令而计划与 Todo 不动。

### 9 错误提前暴露
出错 → 记 progress.md + 告诉用户 + `config.json#escalation_threshold` 次失败则 AskUserQuestion。

### 10 Scope 变更必重规划
详见 `reference.md § 重规划触发`。

### 11 漂移检测（周期性）
每个 phase 标记 complete 后、连续 ≥3 次工具调用后、切模块前，调用：
```
Skill("task-drift-guard")
```
- ✅ ALIGNED → 继续执行
- ⚠️ DRIFT → 记录到 progress.md，继续但警觉
- 🔴 BLOCKED → STOP，报告用户，等决策

`task-drift-guard` 是只读检测层，不做任何文件写入；发现偏差后输出结构化报告并等待用户决策。

### 12 冲突即隔离（工作树默认首选）
任务启动前运行 `check-conflicts.sh`；**实现类任务默认建议工作树隔离**（`wt/<task-id>` 分支，`../<repo>-wt-<task-id>` 目录），完成后验证并主动合并回原分支再清理（合约见 `references/worktree-isolation.md`）。纯文档/调研类或用户显式否决时才直接开发。原因：本仓多为运行中基础设施，直接改动可能使功能在工作期间无法使用。

### 13 子代理隔离强制（P0）
调研/搜索/大文件读取/跨文件 Read 必须派子代理。完整路由表见 SKILL.md §「子代理路由与模型分级」。主进程禁止直接 Read >500 行文件后改动、跑测试、接收 `Skill("research-assistant")` 长文。模型档位复用 `~/.zcode/cli/memories/projects/.zcode-c4bb56bd9710299a/memory/agent-model-tiering.md` 既有约定。

### 14 代码编辑必须派子代理（P0）
主进程禁止直接 Edit/Write 业务代码（`.ts/.tsx/.js/.jsx/.py/.go/.rs/.java/.c/.cpp/.h/.hpp`）。详见 SKILL.md §「代码编辑强制隔离」。仅允许主进程 Edit 纯配置/计划文件（`.md/.json/.yaml` plan 模板）+ Todo 同步 + AGENTS.md 文档。变更规模路由：≤3 文件/≤300 行 → code-assistant（haiku-1）；>3 文件或 >300 行 → executor（sonnet-1）。

### 15 高频漂移纠正强制（P0）
每完成 2-3 个原生 todo 后必须调用 `Skill("task-drift-guard")`（model: haiku,token 便宜）。纠正条目入 todo：⚠️ DRIFT → 自动追加 `[drift-fix]` 条目；🔴 BLOCKED → 立即 STOP 不自动入 todo,必须报告用户等决策。Phase 级 Rule 11 仍生效,作为粗粒度兜底。详见 SKILL.md §「高频漂移纠正」。

### 16 任务开启期选模板（P0）
禁止用通用 `task_plan.md` 套用所有任务。任务开启期必须先选模板（research/diagnostic/writing/publish/code-edit/refactor/bugfix/general）,写进 task_plan.md frontmatter `template_type` 字段。`plan-writer` agent 自动按类型选模板填充。决策树见 SKILL.md §「任务模板库」。
