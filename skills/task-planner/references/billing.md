# Plan 技能计费使用指南

## 概述

本指南说明 Plan 技能在使用 opus 模型时的计费行为，以及如何避免不必要的重复计费。

## 📊 核心结论

**Plan 技能采用单次触发模式**：
- ✅ 一次任务规划 = 一次 opus 调用 = 一次计费
- ✅ 执行过程中的所有文件操作（Read/Write/Edit/Bash）**不会**重新触发 skill
- ✅ 子代理调用按各自模型独立计费，不叠加到 Plan 技能
- ⚠️ 唯一导致重复计费的情况：**用户中途重复调用 `/plan`**

## 💰 详细计费场景

### 正常场景（推荐）

```bash
# 第1次：用户在任务开始时调用
/plan 创建一个任务规划
→ 计费: 1次 opus 推理
→ 执行: 生成 task_plan.md, 持续执行直到完成
→ 执行中的 50+ 次 Read/Write/Bash → **不计费**
→ 结果: 任务完成，总计费: 1次 ✅
```

### 重复计费场景（应避免）

```bash
# 第1次：用户调用
/plan 开始任务A
→ 计费: 1次 ✅

# ...执行中途...

# 第2次：用户又说 "/plan"
/plan （Task A 未完成，又调用一次）
→ 计费: +1次 ❌ 重复
→ 原因: 两个独立会话，互不影响

# 总计费: 2次（其中1次是多余的）
```

## 🔍 为什么执行中不会重复计费？

### 技术原理

1. **技能加载机制**：
   ```
   用户调用 /plan → Claude 加载 SKILL.md → 执行指令
                                   ↓
                           在同一个会话中持续运行
                                   ↓
                           PreToolUse hook 仅检查范围
                                   ↓
                           不重新加载 SKILL.md
   ```

2. **Hook 的作用**：
   - `PreToolUse` 中的 `check-scope.sh` 是**bash 范围检查**
   - 不涉及 skill 重新加载或模型重新初始化
   - 纯粹的文件访问控制，无计费影响

3. **工具调用隔离**：
   - `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` 都是**基础工具**
   - 这些工具的调用记录在 tool_use 中，但**不触发 skill 重新加载**
   - 相当于同一会话内的连续操作

4. **会话持续性**：
   - 从 skill 激活到任务完成，是一个**连续的 LLM 会话**
   - 模型实例保持在同一上下文中
   - 只有 session 边界（如 `/clear`）才会"重置"计费状态

## ⚠️ 导致多计费的5种情况

| # | 场景 | 原因 | 预防措施 |
|---|------|------|----------|
| 1 | **中途重复调用** | 用户不知情，又说一次 `/plan` | 在 plan 开始时确认："已激活 Plan 技能，无需重复调用" |
| 2 | **Session 中断后重新调用** | 网络超时或 `/clear` 后重启 | 使用 `session-catchup.py` 恢复，而非新计划 |
| 3 | **并行任务分别调用** | 同时规划多个任务 | 使用独立 `plans/{task-id}/` 目录隔离 |
| 4 | **自动化脚本调用** | 脚本中多次调用 `/plan` | 脚本应检查是否已有 `task_plan.md` |
| 5 | **范围变更导致重规划** | 频繁变更需求触发新计划 | 遵循 "Re-Plan on Scope Change" 规则，只在必要时重规划 |

## 🛡️ 防护措施

### 1. 会话内防护 (SKILL.md v2.3.0+)

Plan 技能已内置防护：
- **明确标注**单次触发模式
- **提示用户**勿重复调用
- **指导**使用 session-catchup 恢复

### 2. 用户自查清单

每次调用 `/plan` 前，问自己：

- [ ] 当前会话中是否已有 `task_plan.md`？
- [ ] 任务是否真的从头开始？
- [ ] 是否只是需要恢复上下文？（用 `session-catchup.py`）
- [ ] 新需求是否应在现有计划上调整？（Edit task_plan.md）

如果以上任一为 **Yes**，**不要**调用 `/plan`。

### 3. 使用 session-kv 跟踪

```bash
# 查看上次调用时间
session-kv get plan_last_invocation

# 如果 < 5 分钟，说明可能有重复
```

我们可配置 `PreToolUse` hook 来阻止5分钟内的重复调用（可选，需用户显式启用）。

## 📚 相关资源

- **Plan 技能 SKILL.md**: `~/.claude/skills/task-planner/SKILL.md`
- **计费章节**: 本文件（references/billing.md）— SKILL.md 主流程不重复计费说明，详见此处
- **模板目录**: `~/.claude/skills/task-planner/templates/`
- **脚本工具**: `~/.claude/skills/task-planner/scripts/`
  - `session-catchup.py` - 恢复上下文
  - `init-session.sh` - 初始化任务目录
  - `check-scope.sh` - 范围检查（不触发额外计费）

## ❓ 常见问题

**Q: 执行中 Write 100次，会额外计费100次吗？**
A: 不会。Write 是标准工具调用，不重新加载 skill。计费仅发生在 skill 触发时（即 `/plan` 命令）。

**Q: 我的任务执行了2小时，中途没再调用 `/plan`，计费几次？**
A: 1次。整个会话期间的skill使用只计首次触发。

**Q: 如果我调用了 `/research-assistant` 子代理，如何计费？**
A: 子代理有自己的 `model` 配置，按子代理的模型独立计费。Plan skill 本身不叠加计费。

**Q: `/clear` 后重新调用 `/plan`，算几次？**
A: 2次（独立会话）。这是预期行为，因为 context 已完全重置。

**Q: 如何查看我的技能调用统计？**
A: 使用 `session-kv` 或查看 Claude Code 的 usage 报告（如有）。

## 📞 支持

如对计费有疑问，请：
1. 检查 `task_plan.md` 的创建时间
2. 确认是否有多次 `/plan` 命令历史
3. 查看 `session-kv get plan_last_invocation` 的时间戳

---
**文档版本**: 1.0
**更新日期**: 2026-06-13
**适用模型**: sonnet
