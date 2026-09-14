# Task Learnings: {task-name}

## New Requests
<!-- Log user-injected requests here. Each entry: timestamp + request + implied scope + plan impact. -->
-

## What Worked
-

## What Didn't Work
<!-- [task-v072 Rule 31.4] 结构化条目 = 错误描述 + 类别标签（信息缺失/假设未验/规则缺位/数据源过时/执行偏差）；来源：31.2 根因分析闭环（用户指出错误/重复反馈/打断补充数据）与三击协议 -->
-

## 🚫 被否决方案（User Rejected — Rule 32）
<!-- [task-v073 Rule 32.1] 用户裁决「不允许/禁止/X 是错的/不要再做」的方案登记于此：方案描述 + 否决原文 + 日期 + 适用范围。
     32.2 计划期/32.3 执行期提出任何方案候选前必查本段（plans/ 历史 notepad 同查）；32.4 无新验证证据禁止重提——
     重提须标注「此前被否决于 <日期/出处>，现因 <新证据> 申请重议」交用户裁决；解禁仅限用户显式撤销（veto-lift 行）。
     31.5 消费侧联动：下一 Phase 开工前/新任务 init-session 后必读本段。 -->
-

## Files Modified
-

## Verification Results
- Verified: [specific change confirmed]
- Failed: [specific issue and resolution]

## 📚 必要知识储备备注
<!-- WHAT: 本次任务新发现的知识源/值得入库的书目文献/待补齐的知识缺口 -->
- 本次新发现的知识源:
- 值得入库的书目/文献:
- 待补齐的知识缺口:

## Notes for Next Time
<!-- [task-v072 Rule 31.4/31.5] 消费侧契约：条目格式 = 触发条件 + 防线一句话；31.5 ① 下一 Phase 开工前 Read 未消费项命中即执行并记 [learn-apply]；31.5 ② 新任务 init-session 后 Read 上一 completed 任务同段作风险预演输入 -->
-

## What Worked（task-v074）
- 消费侧门控三档键+静态 selftest 守护的「规则落地五件套」套路已验证：条款（NN.M 动词短语+末条机制）+config 键+消费侧脚本+SKILL 联动+selftest——已被沉淀为 templates/variant/rule-enhancement-type.md
- 白名单/类型清单**动态派生**（ls 目录）是消双权威源的最有效手段：init VALID_TYPES 与 check-template-type 同源 variant/ 目录后，沉淀新类型零脚本改动
- 宽容正则锚（Rules 1-3[1-4]）让规则编号级联改动在两阶段间都不破 selftest
- worktree 隔离+smart-merge-back --deploy 一次通过（V1 拦截目录短名属正确防呆，git worktree move 即修）

## What Didn't Work（task-v074）
- 子代理自报"总数"两次算术错误（234≠实 266、304≠实 294）：任何计数类汇总必须主进程逐行求和定数
- Handoff 表 subagent_type 列写 `executor(sonnet-1)` 触发 unverified_delegation——该列只认裸类型 token（老教训 recurrence，已再次验证）
- 正文含 "Batch Report" 字样即触发 Rule 18.6 八字段门控（即便声明不适用）——如实填零单元字段是唯一通路
- init-session.sh 注册 active_plan 指针用的 sid 与会话真实 sid 错位（133bb… vs sess038d…），Write 工具被哨兵拦截；按机制手工补 sess 前缀指针文件即修复

## 🚫 被否决方案（Rule 32 — task-v074）
- （本任务无用户否决记录；v073 期禁令源经查均为空）
