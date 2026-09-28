---
name: plan-research-router
description: 面向计划/执行期的网络调研与 github 调研路由 SOP。主路由是 task-planner 调研环节显式 Skill("plan-research-router") 调用；用户直呼「调研路由」「怎么查资料」「找修复方案/找 issue」时也可触发。不用于纯本地单文件问答或已知 URL 的简单读取。
---

# Plan Research Router

卫星技能：为 task-planner 承接「调研类操作」路由——决定某类调研走 WebSearch（英文/技术关键词）还是 github-cli（issue/PR/代码搜索），给出调用顺序与降级链。完整 SOP 正文在 references/research-routing.md（task-v095 P2-S2 迁移已完成，本卫星为唯一正文）；下方路由速记仅供速查。

## 何时读 references/research-routing.md

- task-planner 流程进入调研环节（Rule 调研驱动）且需要选择调研路径时
- 用户问「这个报错怎么查」「有没有现成 issue/修复方案」「调研路由怎么走」时
- 调研工具失败需降级换路（≥2 次失败换策略）时
- 用户明确要求「上网查」但没说查什么渠道（WebSearch / github / 官方文档）时

## 路由速记（速查表；完整 SOP 在 references/research-routing.md）

| 调研需求 | 首选路径 | 备注 |
|----------|---------|------|
| 英文/技术关键词搜索 | WebSearch | 实测可用，直接调 |
| 代码仓库/issue/PR 查找 | github-cli | 优先官方 CLI |
| 中文资料/多源交叉验证 | research-assistant 链 | 见 task-planner 现行 SOP |
| 失败 ≥2 次 | 换路径重试，不原地死磕 | 记录失败原因 |

## 与 task-planner 的关系

- 卫星技能：无 config 依赖、无 hook、无 scripts，纯 SKILL.md + references 文档
- 不改变 task-planner 触发范围；被 task-planner 调研环节显式调用，或用户直呼时独立触发
- 调研结论必须记录来源（继承 task-planner 调研铁律）

## 使用入口（两种）

1. 主路由：task-planner 计划/执行期调研环节显式 `Skill(skill="plan-research-router")`
2. 直接触发：用户说「调研路由」「怎么查资料」「找 issue/修复方案」时加载本技能

## 状态说明

本卫星已完成 task-v095 P2-S2 迁移：完整路由 SOP（细粒度判定表、降级链、双路并行策略）在 references/research-routing.md，为该 SOP 唯一正文；「路由速记」表仅作速查。被调用时以 references/research-routing.md 为准。

铁律：只读路由决策，不代替调研工具执行；调研结论必须附来源；不再复制 task-planner 正文，防止双份漂移。
