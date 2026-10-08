# S9 仓级文档 Rule 集合滞后修正检查点

**执行体**: executor（sonnet-1）
**执行时间**: 2026-10-08
**状态**: 完成

---

## 任务目标

D14/D15：仓级文档 Rule 集合滞后修正——「Rules 1-45」「Rules 1-39」→实态 1-65。

## 修改文件清单

### 1. README_zh.md

| 行号 | 修改前 | 修改后 | 类型 |
|------|--------|--------|------|
| :136 | `Rules 1-45 核心执行约束` | `Rules 1-65 核心执行约束` | 全集声明 |
| :229 | `Rules 1-45 —— 自定义前必读` | `Rules 1-65 —— 自定义前必读` | 全集声明 |
| :114 | `6 个伴生 agent（plan-writer / article-batch-publisher / article-field-fixer / complex-planner / image-generation-executor / video-generation-executor）` | `7 个伴生 agent（plan-writer / article-batch-publisher / article-field-fixer / complex-planner / image-generation-executor / video-generation-executor / drift-checker）` | 计数修正 |

### 2. CLAUDE.md

| 行号 | 修改前 | 修改后 | 类型 |
|------|--------|--------|------|
| :33 | `Rules 1-39 核心执行约束` | `Rules 1-65 核心执行约束` | 全集声明 |

### 3. skills/task-planner/README.md

| 行号 | 修改前 | 修改后 | 类型 |
|------|--------|--------|------|
| :72 | `Rules 1-39（1-12 核心执行约束 + 13-35 P0/P1 扩展门控与学习/防倒退/结论纪律闭环 + 36 技能修改保守化 + 37 任务类型机制画像 + 38 任务难度分级与轻量档 + 39 动态工作流编排）` | `Rules 1-65（1-12 核心执行约束 + 13-35 P0/P1 扩展门控与学习/防倒退/结论纪律闭环 + 36-39 技能修改保守化/任务类型画像/难度分级/动态工作流 + 40-43 工具面/问题消解/质量审查/执行可靠性 + 44-45 用户选择点/注释规范 + 46-50 子代理专注/媒体派发/交付总结/并行推进/内容分级 + 51-58 需求覆盖/执行体专业化/根源解决/执行诚实/可复用能力/用户指令/迭代测试/调研证据 + 59-62 拆分粒度/主动解决/偏移检查/四文件罗盘 + 63-65 检索优先/偏移留痕/周期性回顾）` | 分组描述修正 |
| :71 | `8 篇规则文档（实测 8：13 篇基线中 template-mapping/template-guide/billing 等 5 篇已迁出至卫星）` | `10 篇规则文档（实测 10：13 篇基线中 template-mapping/template-guide/billing 等 3 篇已迁出至卫星）` | 计数修正 |
| :79 | `5 核心 + 3 辅助 + 29 个 variant` | `10 核心 + 29 个 variant` | 计数修正 |
| :120 | `伴生 agents（plan-writer / article-batch-publisher / article-field-fixer，跨平台部署用）` | `伴生 agents（plan-writer / article-batch-publisher / article-field-fixer / complex-planner / image-generation-executor / video-generation-executor / drift-checker，跨平台部署用）` | 计数修正 |

## 实态计数验证（ls 实测）

| 项目 | 实态 | 证据命令 |
|------|------|----------|
| selftest-*.sh | 62 | `ls skills/task-planner/scripts/selftest-*.sh \| wc -l` |
| companion/agents/ | 7 | `ls skills/task-planner/companion/agents/ \| wc -l` |
| templates/*.md | 10 | `ls skills/task-planner/templates/*.md \| wc -l` |
| templates/variant/ | 29 | `ls skills/task-planner/templates/variant/ \| wc -l` |
| references/*.md | 10 | `ls skills/task-planner/references/*.md \| wc -l` |

## 自验结果

```
=== README_zh.md ===
0 命中
=== CLAUDE.md ===
0 命中
=== skills/task-planner/README.md ===
0 命中
```

## 异常说明

- **templates 计数差异**：03-explore-s2.md 报告 templates 顶层 12 个，但 worktree 内 `ls skills/task-planner/templates/*.md | wc -l` 实测为 10。按任务要求「ls 实测为准」原则，采用实测值 10。差异原因待查（可能为扫描时 master 与 worktree 间有未同步变更，或扫描命令差异）。

## 改动标注

所有改动处均标注 `<!-- 2026-10-08 task-v149 对齐实态 -->`。

## 检查点写入时间

2026-10-08 S9 执行完成
