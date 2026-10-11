# Task Learnings: task-v129（Rule 51 需求覆盖与完成声称门控）

## New Requests
- 2026-10-04 用户上报 videop1 虚假执行事故并定性「流程失控/缺失，不是能力问题；先设定目标+设计验证就不会虚假实现」→ 隐含 scope=治理层根治（本计划全部），非个案修补。

## What Worked
- 守卫链实测有效：check-dispatch 对 Explore 派发拦截×2（22.4a 契约字段/KQ3 brief 引用）→ 补字段即放行，机器面零漏拦。
- 双 Explore 并行取证范式：两路独立只读（跨仓现场 + 本仓锚点）一次消息并行派发，约 8 分钟闭环，主上下文只收结论。
- 编号竞态止血靠先例注记：v128 计划里的「编号占用全景」一行直接裁决了 50/51 归属，免二次仲裁。

## What Didn't Work
<!-- [task-v072 Rule 31.4] 结构化条目 = 错误描述 + 类别标签；来源：31.2 根因分析闭环 -->
- 【规则缺位】videop1 执行方把用户绝对指令（全量归档）在计划层改写为条件式（"无替代件不归档，挂起"）且未问用户，全部门控校验"计划交付物"不校验"用户需求原文"→ 缩水版全链绿灯、自报完成。→ 防线=Rule 51.1/51.3（本任务落地）。
- 【假设未验】生成/补制前未盘点库存（multiview-v3 已在库、小满 outfit-autumn 产线多次在用）→ 17 次生成调用零产出浪费。→ 防线=Rule 51.5 生成前置盘点（本任务落地）。
- 【执行偏差】本计划 attest 首跑被拦：Phase 4（派发型）漏建 S-unit 表——22.6 覆盖所有 Executor≠主进程 Phase，非只"最重的 Phase"。→ 防线=attest 前逐 Phase 自检 Executor 字段。

## 🚫 被否决方案（User Rejected — Rule 32）
- （本任务无用户 veto 登记；历史禁令已查：notepad 无否决项，memory 中 v125/v126 同瞄教训以「编号登记」吸收而非方案重提）

## Files Modified
- plans/task-v129/ 六件套 + subagent-state/02-explore-anchors.md + ledger-main.jsonl（Phase 1 簿记）
- 技能本体文件待 Phase 3（worktree 内）落地后回填本段

## Verification Results
- Verified: attest 二跑锁定（SHA-256 b224d4e9…）；撞号终核（v128 注记「下一可用=51」）；本会话指针→task-v129
- Failed: attest 首跑（Phase 4 缺表，已修复复测通过）；Explore 派发×2（契约字段缺失，已补齐复测通过）

## 📚 必要知识储备备注
- 本次新发现的知识源: v128 计划内「编号占用全景」注记=编号仲裁的一手事实源（建议后续任务沿用此注记惯例）
- 值得入库的书目/文献: 无
- 待补齐的知识缺口: plan-created.cjs env-sid 兜底解析序（观察项，复现≥2 次再立案）

## Notes for Next Time
<!-- [task-v072 Rule 31.4/31.5] 消费侧契约：触发条件 + 防线一句话 -->
- 触发=任何计划涉及用户明确需求 → 防线：先建「用户需求原文」区块（R1..Rn 原话+R→VC 映射）再写 Phase（Rule 51.1，本任务 Phase 3 落地后为硬门）
- 触发=生成/补制/重建类消耗动作 → 防线：先盘点在库/在用同类资产落 findings，零需求禁生成（Rule 51.5）
- 触发=attest 锁定前 → 防线：逐 Phase 查 Executor≠主进程必有 S-unit 数据行（22.6）
- 触发=交付终态 → 防线：逐需求条目出 covered/uncovered 核对表，核心需求未覆盖禁 COMPLETE（Rule 51.3）
