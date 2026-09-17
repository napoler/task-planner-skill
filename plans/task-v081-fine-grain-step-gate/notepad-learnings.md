# Task Learnings: task-v081 步骤枚举门控

## New Requests
- 2026-09-17 用户：优化当前技能——拆分子代理不够细,单子代理 13 步违背小步快跑（附 Step1..Step13 实证）→ 本任务全量范围

## What Worked
- 计划期先取证四层防线源码再设计,根因（无步骤数维度+advisory 不阻断+ID 计数盲区）一次定位,方案一次成型
- 回退双分支测试（剥键/缺 config）在 SG-07 逼出注释与实现不一致——行为级 selftest 值得
- 预登记降级路由（Executor 字段写明"不可启动则 22.3④"）使环境故障下门控与 CR 不空转

## What Didn't Work
<!-- [task-v072 Rule 31.4] 结构化条目 = 错误描述 + 类别标签；来源：31.2 根因分析闭环 -->
- [假设未验] 写断言按注释文案而非代码行为（SG-07 首跑 FAIL）——jq `//` 兜底使"键缺失→SKIPPED"文案失真,实现才是事实源
- [环境/配置] 本 harness sonnet-1/继承/haiku-1 档位子代理全部 Cannot start(reasoning-level-missing),仅 mini 可用;provider 层另有间歇 server error——派发前先 mini 探针,勿对非 mini 档反复重试
- [执行偏差] findings.md Edit 用既有条目整体作 old_string 致误覆盖（立即恢复）——追加内容用「锚定后界+前插」写法
- [数据源过时] 开工时 master 已被并行会话 v080 推进（f0fa427→34c3959,SKILL 541→543）——行号锚点必须以 worktree 实查为准,材料包行号会腐化
- [规则缺位] 委派统计 Executor 字段是机器事实源,执行路由变更（接管/改派）必须同步改字段并重锁 attest,否则终验 violation 自钉

## 🚫 被否决方案（User Rejected — Rule 32）
- 本任务无用户否决项

## Files Modified
- skills/task-planner: config.json(+step_max_steps)、scripts/check-dispatch.sh(④+count_step_markers)、scripts/check-plan-dispatch.sh(第三维)、scripts/selftest-fine-grain-steps.sh(新)、references/critical-rules.md、SKILL.md、templates/subagent_dispatch.md、CHANGELOG.md（均经 worktree 合并 38ed103 部署三位）

## Verification Results
- Verified: 13 步 enforce exit2/任务书绕门拦截/4 步放行/计划侧 advisory/回退双分支——SG-01..11 三连跑 11/0;全量 worktree+master 双侧 366/0;三位 diff -r IDENTICAL 亲验
- Failed: SG-07 首跑（预期错,已修）;委派统计首跑 violation（Executor 未同步,已回炉）

## 📚 必要知识储备备注
- 本次新发现的知识源: 无外部;内部=check-dispatch/check-plan-dispatch 全结构已吃透
- 值得入库的书目/文献: 无
- 待补齐的知识缺口: 行首编号列表型步骤枚举口径（防误伤未覆盖,见 verification 遗留②）

## Notes for Next Time
- 触发=非 mini 档 Agent 派发 → 防线=预期 Cannot start(reasoning-level-missing),直接 mini 探针+22.3④ 接管路由,勿重试 ≥2 次（Error Log #2/#3）
- 触发=改 jq 阈值类断言 → 防线=先跑一遍真实命令看输出再写期望值（`//` 兜底使 SKIPPED 不触发）
- 触发=执行路由偏离计划 Executor → 防线=改字段+重跑 attest+复跑 check-delegation stats,再进终验
- 触发=同仓并行会话活跃 → 防线=开工 git reflog 考古+worktree list,基线 commit 号写进计划,锚点全部 worktree 实查重验
