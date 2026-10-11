# Task Learnings: task-v106-iterative-optimizer

## New Requests
- 2026-10-01(英文自包含指令): 创建循环迭代优化 skill(评估→诊断→定向改进→门控收敛,质量标准或最大轮次收敛,稳定可重复,迭代摘要)→顶层 skills/iterative-optimizer 已交付(merge b5acff6+4e55894 已 push,三宿主分发)

## What Worked
- 用户指令自包含(八锚原文)→设计规格零歧义,executor 一次成型
- 顶层 skill 首次走 install-companion 分发路径,三宿主 diff IDENTICAL——顶层 skill 交付范式闭环(此前仅 task-planner/池)

## What Didn't Work
- **CR P2-d 误判登记**: code-reviewer 把 task-planner/ 当仓根,报「lib/install-companion.sh 不存在」——审查者路径基准错误,主进程对照实存证伪。防线=审查报告涉及「文件不存在」类断言必须附 find 证据再采信

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
- 触发=优化类任务(提示词精修/参数调优/缺陷修正): 防线=iterative-optimizer 五步闭环(先协商 QC≥3 含机器可检查→单 focus 每轮最弱项→gate 逐条证据→达上限如实 PARTIAL)
- 触发=新建顶层 skill: 防线=deploy 用 install-companion --target ×3(顶层循环自动分发)+diff 亲验;勿忘新会话快照刷新
- 触发=CR 报「文件不存在」: 防线=要求 find 证据,核对审查者 cwd 基准(v106 P2-d 教训)
