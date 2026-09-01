# 成本控制 — Opus 使用节流指南（v2.1）

> 目标：在不损失核心能力的前提下，降低 Opus 使用频率，提高成本控制。
> 模型分档复用 `~/.zcode/cli/memories/projects/.zcode-c4bb56bd9710299a/memory/agent-model-tiering.md` 既有约定。

---

## 一、Opus 成本结构（当前 task-planner 会话）

| 来源 | 档位 | 频次 | 是否可控 |
|------|------|------|----------|
| task-planner 主会话 | opus（frontmatter） | 1 次/会话 | ❌ 必烧 opus |
| `Skill("task-drift-guard")` | haiku | 高频（每 2-3 todo） | ✅ 已优化 |
| `Skill("systematic-debugging")` | 继承主会话 = opus | bug 类任务触发 | 🔴 嵌套 opus |
| `Skill("code-review")` | 继承主会话 = opus | code_review: required 触发 | 🔴 嵌套 opus |
| `Skill("brainstorming")` | opus 档 | 用户主动触发 | 🟡 用户可控 |
| `Skill("writing-plans")` | opus 档 | 用户主动触发 | 🟡 用户可控 |
| `Skill("comet-*")` | opus 档 | 用户主动触发 | 🟡 用户可控 |
| `Agent(complex-problem-solver)` | sonnet-1（默认 3-strike 升级 opus） | 失败 ≥3 次 | 🟡 prompt 升级机制 |

**真正的隐藏成本源**：opus 主会话中调 `Skill("systematic-debugging")` / `Skill("code-review")`（嵌套 opus = 每次额外 1 次 opus 计费）。

---

## 二、Rule 17 八条款（与 critical-rules.md Rule 17 同步）

| # | 条款 | 节流机制 |
|---|------|----------|
| **17.1** | opus Skill 节流：opus 档 Skill（systematic-debugging/code-review/brainstorming/writing-plans/comet-*）同 phase 内 ≤1 次 | PreToolUse hook 提醒 + 软警告；超出 → AskUserQuestion "继续/拆型/降级" |
| **17.2** | subagent 嵌套禁止：禁止 plan-writer 调 plan-writer / code-assistant 调 code-assistant（递归） | Subagent frontmatter `tools` 不含 Agent/Skill 已防止 |
| **17.3** | 任务模板复用：禁止 plan-writer 重复生成同 task_plan；用 Decisions Made 复用旧决策 | plan-writer 输入契约检查 |
| **17.4** | drift 检测频次上限：每 phase 内 task-drift-guard ≤3 次（2-3 todo + 切模块 + phase complete） | PostToolUse hook 计数 |
| **17.5** | opus 调用门控：单次会话 opus 累计调用（含主进程 + Skill 嵌套 + subagent 升级）≥10 次 → 触发 AskUserQuestion | PostToolUse hook 计数 + 软警告 |
| **17.6** | 复杂任务优先 subagent：opus 上下文长读文件（>500 行）必派 subagent（沿用 Rule 13） | Rule 13 已护住 |
| **17.7** | 代码 review 必含 `required`：`task_plan.md#code_review` = `required` 才触发 `Skill("code-review")` | 既定 design |
| **17.8** | 每次 opus 调用记 cost_log.md：子代理/Skill 调用记录到 `templates/cost_log.md` 便于复盘 | plan-writer 产出模板加 cost_estimate |

---

## 三、模型档位映射（完整版）

| 任务类型 | subagent | model 档位 | 单次成本估算（相对 opus） |
|---------|---------|-----------|---------------------|
| 计划撰写 | plan-writer | sonnet-1 | ≈ 0.3× opus |
| 代码编辑（≤3 文件） | code-assistant | haiku-1 | ≈ 0.05× opus |
| 代码编辑（>3 文件） | executor | sonnet-1 | ≈ 0.3× opus |
| 跑测试/构建 | code-runner-agent | mini | ≈ 0.02× opus |
| 跨文件搜索 | explore | haiku-1 | ≈ 0.05× opus |
| 漂移检测 | task-drift-guard skill | haiku | ≈ 0.05× opus |
| bug 根因 | debugger | sonnet-1 | ≈ 0.3× opus |
| 主进程调度 | task-planner 主会话 | opus | 1× opus（必烧） |
| **嵌套 opus** | `Skill("systematic-debugging")` / `Skill("code-review")` | opus（继承主会话） | **1× opus（Rule 17.1 节流）** |

**成本对比示例**（一次 phase 执行）：
- 旧版（全跑 opus 主进程）：1（主会话）+ 5（嵌套 skill） = 6× opus
- 新版（Rule 17 节流）：1（主会话）+ 1（code-review 1 次）+ 5× 0.3（sonnet subagent）= **2.5× opus 等效**

**节省约 58% opus 调用**（前提：充分用 subagent 路由 + 节流嵌套 skill）。

---

## 四、cost_log.md 模板（双仓 templates/）

```markdown
# Opus 调用成本日志

> 每次 opus 档 Skill 调用 / 主进程 opus 计算 / 嵌套 opus 都记一行

| 时间 | 类型 | 触发点 | 累计 opus 调用 | 备注 |
|------|------|--------|--------------|------|
| 09:00 | 主会话 | task-planner 启动 | 1 | 主进程烧 1 次 |
| 09:15 | Skill("code-review") | Phase 3 complete | 2 | 嵌套 opus（Rule 17.1 第 1 次） |
| ... | ... | ... | ... | ... |

## 累计统计
- 本会话 opus 调用：N 次
- 是否触发门控（≥10）：yes / no
- 主要 opus 来源：主会话 / 嵌套 skill / subagent 升级

## 节流建议
- 嵌套 skill >5 次 → 拆分 phase
- 单 phase opus >3 次 → 派 subagent 替代
```

---

## 五、plan-writer 产出契约扩展

plan-writer 输出的 `task_plan.md` frontmatter 加 `cost_estimate` 字段：

```yaml
template_type: code-edit
cost_estimate:
  main_process_opus: 1
  subagent_calls:
    code-assistant: 1      # haiku
    code-runner-agent: 2    # mini
  estimated_opus_equivalent: 1.7   # ≈ 1 + 0.05×1 + 0.02×2 + ...
  estimated_savings_vs_naive: 0.65 # 节省比例（与全 opus 对照）
```

**作用**：
- 主进程 Read `task_plan.md` 时立即看到 opus 预算
- 子代理派发时主进程可决策"是否接受这个 cost"
- progress.md 自动累加 cost_log

---

## 六、Opus 降级候选清单（按 ROI 排序）

### ✅ 已完成（agent 侧）

| 项 | 现状 | 状态 |
|----|------|------|
| agent opus 数量 | 0（2026-08-27 已彻底下移） | ✅ 无需操作 |

### 🟡 MED ROI（待 A/B 验证）

| 项 | 现状 | 降级方案 | 风险 |
|----|------|---------|------|
| task-planner 主进程 model | opus | 可尝试 sonnet-1（与 plan-writer 同档） | A/B/C 判定质量有损失 |

**当前决策**：主进程**保持 opus**。理由：
- 主进程 token 量小（纯编排）
- opus 调度质量比 sonnet 显著高
- 真正该省的是嵌套 opus（Rule 17.1/17.5），不是主进程降级

### 🔴 LOW ROI（不可降）

| 项 | 不可降原因 |
|----|-----------|
| brainstorming / writing-plans | 创意 + 长文档生成，opus 必要 |
| comet-classic / comet-design / comet-native | 5 阶段跨会话编排，opus 必要 |
| openspec-propose / openspec-new-change | spec 起草 + 长文档生成 |
| plan-writer（agent） | 结构化模板填空，sonnet-1 已够；haiku 风险契约禁动 |

---

## 七、Hook 集成点（PostToolUse / PreToolUse）

| Hook | 触发时机 | 检测内容 | 动作 |
|------|---------|---------|------|
| `zcode-posttooluse.sh` | 工具调用后 | 累计 opus 调用 ≥10（Rule 17.5） | 注入 `[cost-warning]` 提醒 |
| `zcode-posttooluse.sh` | 工具调用后 | 单 phase drift-guard ≥3 次（Rule 17.4） | 注入 `[drift-cooldown]` 抑制 |
| `zcode-pretooluse.sh` | Skill() 调用前 | opus skill 同 phase 重复（Rule 17.1） | 注入 `[opus-throttle]` 提醒 |

**当前状态**：hook 已存在但未实现 cost 计数逻辑。下轮 follow-up：补 cost-count 子命令。

---

## 八、复盘 Checklist

每次 task-planner 会话结束前，主进程应：

- [ ] Read `plans/{task-id}/cost_log.md`（如有）→ 统计本会话 opus 累计
- [ ] 若累计 ≥10 → 复盘：哪些嵌套 opus 本可避免？
- [ ] 若单 phase >3 → 复盘：哪些 phase 该拆？
- [ ] 更新 `~/.zcode/cli/memories/projects/.zcode-c4bb56bd9710299a/memory/` 下的 cost 经验

---

## 九、关联文档

| 文档 | 用途 |
|------|------|
| `~/.zcode/AGENTS.md §十` | ZCode 模型档位事实 |
| `~/.zcode/cli/memories/projects/.zcode-c4bb56bd9710299a/memory/agent-model-tiering.md` | agent 模型分档约定 |
| `references/critical-rules.md` | Rule 17 八条款（核心载体） |
| `references/billing.md` | 子代理成本估算表（与本文件 §三同步） |
| `templates/cost_log.md` | opus 调用日志模板 |
| `agents/plan-writer.md` | plan-writer 产出契约含 cost_estimate |
