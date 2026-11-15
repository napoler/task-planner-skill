---
id: task-intentswitch-20261116
title: "会话意图切换主动换计划——单入口判定卡+显性通告+切换登记（task-intentswitch-20261116）"
tags: [intent-switch, 计划隔离, Rule94, Rule102, UPS-hook, 显性化]
sources: [plans/task-intentswitch-20261116/task_plan.md, plans/task-intentswitch-20261116/findings.md]
updated: 2026-11-16
---

# 会话意图切换主动换计划（A→B 任务隔离显性化）

## 结论（一句话）
task-planner 的意图切换能力根因=触发面弱（LLM 行为门+hook 提示无锚句）+流程散（步骤跨 4 载体）+感知弱（无会话面通告）+边界混淆（drift-checker 被误当切换发起器）+证据弱（无登记字段）；增强采用 S-A 最小增强：SKILL.md 单入口快速判定卡+切换执行清单+显性通告模板+[intent-switch] 登记字段+hook 快速锚句前置+Rule 94/102 交叉锚收敛（merge 281e556，终验 7/7）。

## 可复用事实（带锚）
- 快速判定卡判据：新指令 Goal/范围/交付物 三要素 ↔ 活跃计划 Goal+user-session-log 最新原话比对，均无交集=D 类立即切换；可判定换目标信号=E 类先确认（skills/task-planner/SKILL.md:193）
- 切换执行清单四步：①旧计划挂起登记（[intent-switch] 行+断点检查点）→②新计划 init（指针自动切换）→③显性通告（会话面模板）→④切换登记（progress+Decisions）（SKILL.md:202-204）
- 通告模板与登记最小字段：旧=<id> 新=<id> 触发=原话#N 判定=D/E 确认=yes|44.3自动 时间=ISO8601（SKILL.md:203-204）
- UPS hook [plan-note] 锚句在反思门文案之前前置（zcode-userpromptsubmit.sh:287，PREFIX 保留 102.0/80.8②/8.1）
- drift-checker=执行偏移/目标漂移安全网（Rule 61/64），非意图切换发起器；意图变更走判定卡，归属当前计划后才派 drift-checker（SKILL.md:122-123）
- 交叉锚收敛范式：卫星权威细则保留+段末 `> 交叉锚` 引用块指向单入口，不复制步骤（discipline:619/:708）

## 易错点
- 判据串写 grep 'Rule 94' 前先实测目标文件标题形态——discipline 用裸编号（### 94），SKILL.md 从不写 Rule 102 字面；判据形态错配=判据缺陷非产物缺陷（本任务 V-3.2/VC-3/VC-4 三犯，antitamper 四步修正两批）
- Handoff 表 subagent_type 必须纯 token（plan-writer(本轮) 括号后缀阻断 gate 解析——task-v150 判例第 4 次）；Executor 字段同理纯类型名，编排说明注释化（self_declared_reason 检测）
- 修改验证载体判据（attest 冻结行）必须走 STOP→授权→Decisions→重锁四步（25c4b33 antitamper 条款）；AskUserQuestion 未答时 44.3 超时自动通过口径+留痕可用
- 主进程机械验证（跑 selftest+grep 零仓库变更）Executor 标 L0-E 纯执行档可解委派率分母（权重 0）

## 后续演进
- S-B 结构化重构（独立 intent-switch SOP+plan-resume 挂起态字段）备选；行为面冒烟待新会话真实 A→B 场景验证判定卡/hook 锚句/通告触发显性度
