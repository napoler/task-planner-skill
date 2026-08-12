# task-planner — 任务规划与漂移检测技能

## 概述

结构化任务规划技能，支持多进程/多目录 plan 管理，内置周期性漂移检测。

## 文件结构

```
task-planner/
├── SKILL.md                      # 技能定义（frontmatter + workflow）
├── README.md                     # 本文档
├── reference.md                  # Manus context engineering 原则
├── examples.md                   # 完整执行示例
├── config.json                   # 阈值配置
├── templates/
│   └── task_plan.md              # 计划模板（含 Drift Log 区）
├── references/
│   ├── critical-rules.md         # Rules 1-11（含 Rule 11 漂移检测）
│   ├── completion-gate.md        # 子代理验证协议
│   ├── goal-gate.md              # VC 规则 + 退出标准
│   └── billing.md                # 计费模式
└── scripts/
    ├── init-session.sh           # 初始化 plan 目录
    ├── session-catchup.py        # 中断恢复检测
    ├── sync-todos.sh             # Phase→Todo 同步
    ├── check-scope.sh            # PreToolUse 范围阻断
    ├── check-complete.sh         # Stop hook 完成报告
    ├── check-drift.sh            # 备用漂移检测脚本
    ├── task-plan-init.cjs        # SessionStart hook（计划检测）
    └── sync-ide-folders.ts       # IDE 文件夹同步
```

## 新增组件（2026-08-13）

### 1. task-plan-init.cjs — SessionStart Hook

**位置**: `scripts/task-plan-init.cjs`

**功能**: 会话启动时自动检测计划文档状态。

**检测逻辑**:
1. 向上查找 `plans/task_plan.md` 或 `plans/task-{id}/task_plan.md`
2. 检测 `plans/batch-xxx/` 活跃批量任务
3. 检查 session-kv 上下文

**输出**:
- 有 plan → `[task-plan] 检测到已有计划: <path>`
- 有 batch → `[task-plan] 检测到活跃批量任务`
- 无 plan → 输出触发条件 + §十八点七 提醒

**注册**: `~/.claude/settings.json` SessionStart hooks

```json
{
  "type": "command",
  "command": "node /home/terry/.claude/skills/task-planner/scripts/task-plan-init.cjs",
  "timeout": 5,
  "statusMessage": "Checking task plan status..."
}
```

### 2. task-drift-guard 集成

**位置**: SKILL.md STEP3.5 + references/critical-rules.md Rule 11

**功能**: 周期性漂移检测，调用项目级 `task-drift-guard` 技能。

**触发时机**:
- 每个 phase 标记 `complete` 后立即
- 连续 ≥3 次工具调用后
- 切换到文件/模块前
- 用户发出新指令时

**判定标准**:
| 结果 | 动作 |
|------|------|
| ✅ ALIGNED | 继续执行 |
| ⚠️ DRIFT | 记录 progress.md，警觉继续 |
| 🔴 BLOCKED | STOP，报告用户，等决策 |

### 3. §十八点七 — 每会话必有计划（T0 铁律）

**位置**: `~/.claude/CLAUDE.md`

**核心规则**:
1. 每个活跃会话必须拥有计划文档
2. 无计划 = 禁止执行多步任务
3. SessionStart hook 自动检测
4. 不同任务使用独立 plan 目录

**禁止行为**:
- T7-1: 无 plan 即开始执行
- T7-2: 用临时 Todo 替代正式计划
- T7-3: 执行中途丢弃已有计划
- T7-4: 有计划但不 Read 直接执行

### 4. task_plan.md 模板更新

**新增**: `## 🚨 Drift Log（漂移检测记录）` 区

**格式**:
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-08-13T01:00:00Z | ⚠️ DRIFT | VC-2 | 范围轻微偏移 |

## 依赖关系

| 组件 | 位置 | 用途 |
|------|------|------|
| task-drift-guard | `~/.claude/skills/task-drift-guard/SKILL.md` | 只读漂移检测 |
| todo-skill | `~/.claude/skills/todo-skill/` | 子代理 Todo 持久化 |
| session-kv | `~/.claude/session-kv/` | 会话临时存储 |

## 迁移指南

### 复制到新项目

```bash
# 1. 复制 skill 目录
cp -r ~/.claude/skills/task-planner /path/to/new-project/.claude/skills/

# 2. 注册 SessionStart hook（编辑 ~/.claude/settings.json）
# 在 SessionStart hooks 数组中添加:
{
  "type": "command",
  "command": "node /path/to/new-project/.claude/skills/task-planner/scripts/task-plan-init.cjs",
  "timeout": 5,
  "statusMessage": "Checking task plan status..."
}

# 3. 确保目标项目 CLAUDE.md 包含 §十八点七
```

### 清理旧引用

如果从旧版本升级，检查并删除以下残留:
- `OMC_HOOK_TASK_PLAN` 输出格式（已改为纯文本）
- 硬编码的 `plans/` 目录路径（已改为向上查找）

## 配置项（config.json）

```json
{
  "max_vc": 5,                    // 最少 VC 条目数
  "min_verification_per_phase": 2, // 每 phase 最少验证数
  "retry_count": 3,               // 重试次数
  "max_tool_calls_before_refresh": 5, // 重读计划阈值
  "escalation_threshold": 3       // 升级用户阈值
}
```

## 故障排查

| 问题 | 原因 | 解决 |
|------|------|------|
| hook 无输出 | settings.json 未注册 | 手动添加 hook 配置 |
| 检测不到 plan | 目录结构不对 | 检查 plans/task-{id}/ 格式 |
| 漂移检测误报 | progress.md 未更新 | 每 phase 完成后写 progress.md |
| OMC 格式错误 | 旧版 hook | 更新到最新 task-plan-init.cjs |

## 版本历史

- **2026-08-13**: 新增 §十八点七、task-plan-init.cjs hook、task-drift-guard 集成
- **2026-08-12**: 新增 check-drift.sh 备用脚本、Drift Log 模板区
- **2026-07-23**: 初始版本，Manus context engineering 原则实现
