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

## 沉淀（task-v087，2026-09-22）

**教训 1**：行数回归钉同步模式——SKILL.md 净增 N 行必同步 4 个既有 selftest 的行数断言（本轮 552→555）；漏改=批量假 FAIL（v075 先例重演兜住，改完即跑全量）。
**教训 2**：部署位 selftest 自报总数 440 vs 主仓 441 口径差=自跳用例（BP-08 自测位跳过自断言）非回归——验收取「逐脚本行无 FAIL + 主仓循环求和」双口径，勿信单一自报总数（v076 三次算术错教训第三类实证）。
**教训 3**：纯追加子条（8.1 行首锚 `^8\.1 `）+ 原文零改动 = 零级联（对比 v082 插入式多锚级联）；static-guard 用「原文语义锚仍须命中」（TB-04）钉住防误改。
