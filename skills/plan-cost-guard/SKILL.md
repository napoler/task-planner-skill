---
name: plan-cost-guard
description: 成本控制与计费知识库——Rule 17 嵌套 opus Skill 节流、单会话 opus 累计门控、cost_log 记账契约与成本估算表。主路由为 task-planner Rule 17 场景显式 Skill("plan-cost-guard") 调用；用户直呼「技能成本/计费/opus 成本控制」时也可触发。不用于代码性能优化（性能优化请用 performance 类技能）。
---

# Plan Cost Guard

卫星技能：为 task-planner 承接成本控制与计费知识层——Rule 17 节流条款详解、计费模式说明、cost_log 记账模板契约。完整正文在 references/ 三份文档，本 SKILL.md 只做速记与路由。

## 三份 references 分工

| 文档 | 职责 | 何时读 |
|------|------|--------|
| `references/cost-control.md` | Rule 17 详解：八条款节流机制（17.1 同 phase ≤1 次 / 17.5 累计门控 / 17.8 记账）+ 模型档位映射 + opus 降级路径（ROI 排序清单） | 需要完整节流策略、降级候选、hook 集成点时 |
| `references/billing.md` | 计费模式（单次 `/plan` 必烧 1 opus + 嵌套/子代理独立计费）+ 子代理成本估算表 + 避免重复计费规则 | 估算任务成本、回答「这次会花多少」时 |
| `references/cost_log.md` | opus 调用日志模板：字段契约（时间/类型/触发点/累计/备注）+ 累计统计 + 节流自检 checklist | 写/更新 plans/{task-id}/cost_log.md 时 |

## 关键契约速记

- **Rule 17.1**：opus 档 Skill（systematic-debugging/code-review/brainstorming/writing-plans/comet-*）同 phase 内 ≤1 次，超出 → AskUserQuestion「继续/拆型/降级」
- **Rule 17.5**：单会话 opus 累计调用（主进程+嵌套+subagent 升级）≥10 次 → 触发 AskUserQuestion；>15 次强制 STOP
- **Rule 17.8**：每次 opus 调用记 `references/cost_log.md` 模板对应的一行；plan-writer 产出契约含 `cost_estimate` 字段（main_process_opus / subagent_calls / estimated_opus_equivalent / estimated_savings_vs_naive）
- 典型 phase 成本 ≈ 1.5-3.0 opus 等效（naive 全 opus 为 5-7×，节流后节省约 50-70%）

## 与 task-planner 主技能的关系

- 纯知识层：无 config、无 hook、无 scripts；本技能不读 config.json
- Rule 17 摘要行与流程执行（hook 计数、节流提醒）留守 task-planner 的 SKILL.md 与 critical-rules.md；本技能只承载详解与模板
- 本技能文档中的 `references/critical-rules.md` 指针指向主技能 task-planner/references/critical-rules.md（跨技能指针；主技能 P4-S2 完成指针化后仍以 grep 重定位）
- 记账产物落 `plans/{task-id}/cost_log.md`（模板在本技能 references/cost_log.md）

## 使用入口（两种）

1. 主路由：task-planner Rule 17 场景（嵌套 opus 节流/门控/记账）显式 `Skill(skill="plan-cost-guard")`
2. 直接触发：用户说「技能成本」「计费规则」「opus 成本控制」「这次会烧多少 opus」时加载本技能

铁律：只承载知识/模板，不执行节流判定（判定留守主技能与 hook）；不复制 critical-rules.md 条款正文，防止双份漂移。
