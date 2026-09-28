---
name: plan-collab-router
description: 专业技能协同路由知识库——comet（跨会话 5 阶段托管）/OpenSpec（规格化提案流）/superpowers（TDD/调试/审查成员技能）三族触发矩阵、移交 vs 嵌入合约、22.3.3 卡壳接管评估、progress-tracker 协同契约。主路由是 task-planner 协同触发点与 22.3.3 评估的显式 Skill("plan-collab-router") 调用；用户直呼「该用 comet 吗」「技能协同路由」时可触发。不用于 /workflow 动态编排（走 Rule 39 dynamic-workflows）。
---

# Plan Collab Router

卫星技能：为 task-planner 承接「专业技能协同路由」——把复杂任务按信号移交/嵌入到 comet、OpenSpec、superpowers 三族专业技能的判定矩阵、合约与反模式全文。完整正文在 references/skill-collaboration.md（task-v095 P5-S1 迁移已完成，本卫星为该知识库唯一正文），主技能 SKILL.md 仅保留协同触发条件与指针行。

## 何时读 references/skill-collaboration.md

- task-planner 计划期进入协同评估（触发条件命中）需查三族判定矩阵 / CLI 探针前置 / 移交 vs 嵌入语义时
- 执行期进入 22.3.3 卡壳接管评估（位于 ④主进程接管 与 ⑤AskUserQuestion 之间的兜底档）需查评估 SOP 与接管/回退合约时
- progress-tracker / research-assistant / browser-use 嵌入触发（Rule 30 / task-v080）需查合约列时
- 用户问「该用 comet 吗」「这个任务要不要移交 OpenSpec」「技能协同路由怎么走」时

## 三族一句话画像与判定顺序（顺序敏感，先命中先用，重→轻）

1. **comet**（跨会话 5 阶段托管：open→design→build→verify→archive，重，comet CLI + .comet.yaml）：Phase≥5 / 跨模块 / 需架构选型 / 需归档 / 跨会话续做 任意 3 项命中 → 首选移交
2. **OpenSpec**（spec 驱动 change 生命周期，中，openspec CLI + openspec/ 目录）：需求需 spec 化 / 变更触及已有 spec → 移交；多族命中 = 叠加协同（comet classic 本身即 OpenSpec+superpowers 双星）
3. **superpowers**（单会话过程纪律，轻，无 CLI）：bug→systematic-debugging / TDD→test-driven-development / 审查→requesting-code-review，以嵌入为主（主进程保持统筹）

## 22.3.3 档位说明

22.3.3「协同技能接管评估」位于 22.3 兜底全序 ④主进程接管 与 ⑤AskUserQuestion/STOP 之间：④ 不可行或接管后仍失败时，先评估「是否存在更适配的专业技能族可接管」（comet / openspec-propose / superpowers，CLI 探针前置，缺失标「不可接管」），接管失败才落 ⑤。条款正文本体留守 task-planner references/critical-rules.md（Rule 22.3.3），本技能承载评估 SOP、判定矩阵与合约全文。

## 与 task-planner 的关系

- 纯知识层卫星：无 config / 无 hook / 无 scripts，仅 SKILL.md + references 文档（config.json#skill_collab_enforce 三档由主技能侧流程层执行）
- 不改变 task-planner 触发范围；被 task-planner 协同触发点与 22.3.3 评估显式调用，或用户直呼时独立触发
- 22.3.3 条款正文（含全序图与既有条款关系）权威源 = task-planner critical-rules.md；本文件 = 触发矩阵/合约/反模式唯一正文，两处不可双份改写

## 使用入口（两种）

1. 主路由：task-planner 计划期协同触发点 / 22.3.3 评估处显式 `Skill(skill="plan-collab-router")`
2. 直接触发：用户说「该用 comet 吗」「技能协同路由」「要不要移交 OpenSpec」时加载本技能

## 铁律

CLI 探针前置（禁假设已装）；移交与嵌入互斥（嵌入不得升级为移交）；接管调用计入 Rule 17 opus 节流；silent 模式处置必须登记决策行。全文 6 条反模式见 references/skill-collaboration.md §五。
