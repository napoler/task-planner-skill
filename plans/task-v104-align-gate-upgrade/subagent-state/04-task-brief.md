# P5 任务书: CR Gate 隔离审查（task-v104,e1180a5..77daa52）

任务: 上下文隔离 Code Review——审查主仓 commit 区间 e1180a5..77daa52（task-v104 实现面）。只读,禁改文件禁 git 写操作。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v104-align-gate-upgrade/（只读）
- progress.md: 同目录（子代理禁写）

## 审查对象
`git -C /mnt/data/dev/task-planner-skill diff e1180a5..77daa52`
- 主审: review-library/alignment-review/SKILL.md（闸门段五维全文扫描+标记确认后整理+删除或归档+四项统一/变更记录段三要素表）
- 主审: critical-rules.md（42.6.1/.3 行内升级,42.6.2/.4 零改动）
- 轻审: SKILL.md（C32 行「五要素→三要素」级联）/selftest-review-library（RL-12/13+头注释级联）

## 专项核对点（逐项给结论与证据）
1. **闸门段升级质量**: 五维识别是否完整（版本冲突/重复段/过期结论/编号不一致/失效引用）;「标记冲突+建议处置」与「确认后整理」两阶段语义是否清晰（防误删）;ask/silent 双通道描述（silent=Rule 44 自动超时裁决）与 44.3 实际语义一致（44.3 D6 例外是否被误伤——闸门场景非 D6,但描述须无歧义）;「删除或归档」语义;四项统一（术语/编号/章节结构/引用）
2. **变更记录段**: 三要素表（变更范围/冲突处理结果/文档当前状态）是否可操作;原五字段信息（依据版本/残留冲突）是否并入冲突处理结果列未丢信息
3. **42.6.1/.3 行内升级**: 与 alignment 实文一致;42.6.2/.4/44.x 零改动;44.3「自动裁决记录五要素」（另一概念）未被误改
4. **级联完整性**: C32 行「三要素」;RL-12/13 断言锚对照实文;RL-01..11 零改动;头注释 11→13 级联
5. **v102 原话锚保全**: 「**未经一致性校验，不直接追加新内容。**」字面在 alignment 与 42.6.1 均在位（RL-11 守护面）
6. **越界字面与字面锚**: 新增文本 1-4x 零命中;「Rules 1-39」2 处保全
7. **一般缺陷**: 其他正确性/一致性问题

## 输出合约
- `APPROVED` 或 `CHANGES_REQUESTED`（逐条 [P0/P1/P2] 文件:行 — 问题 — 修法）
- 先落盘: /mnt/data/dev/task-planner-skill/plans/task-v104-align-gate-upgrade/subagent-state/04-cr-p5.md

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P5
completed_steps: 逐条
files_written: 检查点路径
evidence: 结论+专项摘要
issues: 无或明细
next_step: 一句话
self_check: 7 专项逐项结论
