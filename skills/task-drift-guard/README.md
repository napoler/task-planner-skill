# Task Drift Guard

定期检测任务执行是否偏离原始计划，输出结构化漂移报告。

## 安装

本技能位于项目级 `.claude/skills/task-drift-guard/`，Claude Code 启动时自动加载，无需额外安装。

## 快速开始

```
/ta[REDACTED_SK_KEY]       # 直接调用
```

或在对话中说："检查漂移"、"漂移检测"、"对齐检查"。

## 工作原理

1. 找到当前任务的计划源（task_plan.md / plan.json / .execution-plan.json / 用户原话）
2. 对比计划中的 VC 条目 vs 实际已修改的文件和状态
3. 输出报告：✅ ALIGNED / ⚠️ DRIFT / 🔴 BLOCKED
4. 不修改任何文件，发现漂移后 STOP 等决策

## 触发时机

- 连续 3+ 次工具调用后
- 完成一个 Todo 条目后
- 切换模块/文件前
- 用户重复反馈同一问题 ≥2 次
- 执行 10 分钟无阶段性产出

## 配套文档

- [EXAMPLES.md](EXAMPLES.md) — ≥5 个完整使用示例
- [SKILL.md](SKILL.md) — 完整执行流程
