# Findings — task-v082

## Requirements
- 用户原话（2026-09-18）：「优化当前skill 补充一个最小测试原则 就是 比如测试 是否可以 使用 bash 那么只需要 执行一个最简单 输出测试 类似的也是 完全没有必要 搞复杂化」
- 拆解：给 task-planner 补「验证动作最小化」条款——能力/可用性验证默认最小探针（`echo ok` 类单条输出测试），禁止无谓复杂化；有具体怀疑点才升级。

## Research Findings

### ① [PLAN TAMPERED] 考古（2026-09-18 01:00）
- 钩子报 v081 计划哈希不符。实查：v081 目录被双指针认领（09ab7f05/7c4015d4，23:15/23:17）+ worktree wt/task-v081 在册 + subagent-state 23:53 + progress/task_plan 双文件 00:08 成对更新 → **并行会话活跃簿记，非篡改**；本会话 sid 13e6f5e3 无关，未重锁其 attestation。Decisions ② 已登记。

### ② Rule 35 族与锚点面（critical-rules.md:294-299，c10e8f2）
- 35.1 触发 / 35.2 三关 / 35.3 落盘引用 / 35.4 措辞 / 35.5 消费侧 / 35.6 机制。35.6 全仓引用仅 3 处：本体 :299 + selftest-conclusion-discipline.sh:5（头注记）/ :52（CD-07 `^35\.6 ` 单锚）。级联面=CD 头注记+CD-07 双锚化，无其他文件。

### ③ 基点漂移（P1 实测）
- 计划撰写时 master=34c3959；P1 建 worktree 时 master 已被 v081 并行会话推进至 c10e8f2（其交付 merge 38ed103+簿记）。worktree 基点=c10e8f2=最新 master，本任务与 v081 改动面（Rule 21/22 族）不重叠（本任务 Rule 35 族），无冲突。全量基线 366/0 与 v081 交付口径一致。

### ④ SKILL/断言预算
- SKILL.md 543 行（worktree wc 实查）；断言 ≤548 两处（selftest-skill-collab.sh:81 / selftest-execution-stability.sh:72）。SKILL 两处行内原位改净增 0 行，断言不扩围。C23 行=L197，Rule 35 摘要行=L305。

## Technical Decisions
- 「最小测试原则」定名**最小探针原则**，落 Rule 35 族新 35.6（原 35.6 机制→35.7）：与 35.2 同族（三关管否定前查证充分，本条管单步代价最小），不新增 Rule 编号零锚定级联。见 task_plan Decisions ③。

## Resources
- references/critical-rules.md:294-299（Rule 35 段）；scripts/selftest-conclusion-discipline.sh:5/:52；SKILL.md:197/:305；CHANGELOG.md（仓库根）

## Issues Encountered
- **CD 头注记-标签 off-by-one（v077 遗留，本轮登记不修）**：v077 注记称「CD-01..23」但实际标签已到 CD-24（smart-merge-back）。本轮新增断言避让为 CD-25。修历史注记属越界（Rule 36.5），登记供后续清理轮。
