# Task Learnings: task-v170 计划完成后归档机制

## New Requests
- 2026-10-11：用户发现技能完成任务后缺归档步骤，要求添加归档并确保所有已完成计划全部归档（原文见 task_plan.md R1-R3）。

## What Worked
- explore 子代理一次性回收五项现状结论（完成流程无归档/先例/堆积/引用面/INDEX 结构），主进程上下文零膨胀。
- 计划期先查 Rule 编号账本 + 封存分支状态，避免撞号（77/78/79 封存未 land、80 被占）。

## What Didn't Work
- （暂无——001-explore 无写工具致检查点未落盘，已由其返回值等价固化于 findings.md §1-§5，属已知只读 agent 边界非缺陷）

## 🚫 被否决方案（User Rejected — Rule 32）
- （暂无——用户未否决任何方案；不得将"一次性手工清理"当作已满足需求的方案：用户明确要求"添加归档"=机制面）

## Files Modified
- plans/task-v170-archive-completed-plans/{task_plan,findings,progress,verification,knowledge-brief,notepad-learnings}.md（计划系统文件）

## Verification Results
- Verified: plans/ 根 114 目录 vs archive 21 目录一手清点；check-conflicts.sh 4 信号；git ls-files 证实任务目录全跟踪
- Failed: （暂无）

## 📚 必要知识储备备注
- 本次新发现的知识源：plans/.rule-reservations.jsonl 编号账本（land/reserve 状态读法）；plan-created.cjs archive 跳过先例（:10/:122）
- 值得入库的书目/文献：（无）
- 待补齐的知识缺口：存量中"Status=complete 但带 .session-owner"的具体目录清单（Phase 1 S1 产出）

## Notes for Next Time
- 触发条件=任何"完成后治理"类技能改造 → 防线=守卫 fail-closed + dry-run 先行 + 主仓 data 面改动避开并行会话未提交文件（INDEX.md 信号①）。
- 触发条件=向 SKILL.md 插行 → 防线=先 grep -rn 'SKILL\.md:[0-9]' 全仓引用+行数钉+epoch 字面量三级联查再动手。

## 通用规则（General Rules — Rule 31.7）
| 规则名称 | 适用条件 | 具体措施 |
|----------|----------|----------|
| 缺环节类缺陷先查历史一次性工具 | 用户报"缺少某步骤"时 | git log 找一次性脚本先例（本次=plan-hygiene.sh 714c93b），把已存在但未接线的机制接线而非重造 |
| 在途保护先于批量 | 任何目录级批量操作 | .session-owner/active 指针/状态三查 fail-closed，dry-run 锁定候选集 |
