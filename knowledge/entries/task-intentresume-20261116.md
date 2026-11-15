---
id: task-intentresume-20261116
title: "意图切换回切闭环——B 收口后主动回切挂起计划 A（task-intentresume-20261116）"
tags: [intent-switch, 回切, 计划隔离, Rule94, plan-resume, 显性通告]
sources: [plans/archive/task-intentswitch-20261116/task_plan.md, plans/task-intentresume-20261116/findings.md]
updated: 2026-11-16
---

# 意图切换回切闭环（挂起计划不被彻底搁置）

## 结论（一句话）
上承 intentswitch 切换机制（挂起+通告+登记），本任务补齐回切环：终验交付序列新增「挂起计划回切检查（intent-switch 回切）」——outcome 判定后（显式先于归档动作）查 [intent-switch] 登记链+INDEX 待处理区，命中即输出【计划回切通告】（B 已收口→检测到挂起链 A→是否切回），用户 yes=释放指针→完成 B 归档/收尾→路由 Skill("plan-resume") 定向恢复 A 续推，no=登记回切状态=no|保持挂起；不自动切且回切门优先于 plan-resume 触发点③自主续推（merge 1b214f9，终验 7/7，CR 两轮 APPROVED）。

## 可复用事实（带锚）
- 回切检查三要素：时机（outcome 判定后+显式先于归档）、数据源（[intent-switch] 旧=<id> 登记链+plans/INDEX.md 待处理区双源）、动作（通告→确认→定向恢复/保持挂起）（skills/task-planner/SKILL.md:145）
- 回切通告模板：B 已收口→检测到挂起链 A（挂起于原话#N）→是否切回（SKILL.md:206）
- 登记字段扩展：回切分支追加 回切状态=<yes已回切|no|保持挂起>（SKILL.md:205）
- 优先级防第二套路由：回切门优先于 plan-resume 触发点③自主续推——定向恢复须用户显式 yes（SKILL.md:145）
- 交叉锚范式：94.4 封存待 resume 的挂起计划由收口回切检查主动触发（discipline:620）

## 易错点
- **条款内定序必须自洽**：「归档前检查」若归档动作在清单更早位置物理先执行=门不可达（CR 抓获）；收口序列插入条款须显式声明相对定序
- **改控制流要补归属**：yes 路径切走后，原计划（B）的归档/收尾提交必须显式留在切走前完成，否则永不归档（Rule 81.1 失守）
- **声明路由排他**：新增确认门与既有自主机制（plan-resume 自主续推）触发时点重合时，必须显式声明优先级防绕过
- **判据命令禁 Markdown 反引号包裹**：**Verify command**: 后的命令若用 \`...\` 包裹，run-verification 执行时反引号触发 shell 命令替换→grep 输出被当作命令→全 VC 127 伪 FAIL（本任务教训：格式即语义）
- **验证载体格式修复也走重锁**：attest 冻结的是文件哈希——格式修复（去反引号）与状态回填同属哈希漂移，Decisions 登记+重跑 attest 后 PLAN TAMPERED 解除

## 后续演进
- 行为面冒烟待首次真实 B 收口场景（回切通告触发显性度）；多条挂起链批量展示交互可按需扩展（open_question #1）
