# P5 任务书: CR Gate 隔离审查（task-v103,7106233..926af49）

任务: 上下文隔离 Code Review——审查主仓 commit 区间 7106233..926af49（task-v103 Rule 44 实现面）。只读,禁改文件禁 git 写操作。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v103-ask-default-timeout/（只读）
- progress.md: 同目录（子代理禁写）

## 审查对象
`git -C /mnt/data/dev/task-planner-skill diff 7106233..926af49`
- 主审: references/critical-rules.md Rule 44（44.1-44.4 语义:呈现契约/低区分度/超时裁决/机制）
- 主审: scripts/selftest-ask-default-timeout.sh（RT-01..09 断言正确性与锚有效性）
- 轻审: SKILL C33 行+Rule 44 摘要行/templates 配置行+mini-lite 豁免行/T-主 级联/registry 行

## 专项核对点（逐项给结论与证据）
1. **44 条款语义**: 44.1 呈现契约（默认选项+超时 5 分钟默认值+覆盖机制）是否完整可执行;44.2 与 41.3 引用是否恰当（不重述/不互斥）;44.3 自动裁决记录五要素齐备与「可撤回承诺」语义;44.4 与 42.5/43.4 范式一致
2. **RT 断言有效性**: 逐条 Read 对照实文（锚是否真实在位/计数口径正确）;RT-08 越界负断言的限定面（CRIT 44 节+SKILL）是否合理——已知 428 行 42.6.4 括注有历史命中,确认 RT-08 不误伤也不漏守
3. **级联完整性**: T-主 440→442 实测对照（wc SKILL）;SR-12 动态口径咬合（41 脚本+表头=42=registry）;config 零键（jq 键数 40）
4. **C33/模板行**: 措辞与 C30-C32 家族一致;模板「自动超时默认项」行登记义务清晰
5. **越界字面与字面锚**: 新增文本 1-4x 零命中;「Rules 1-39」2 处保全
6. **一般缺陷**: 其他正确性/一致性问题

## 输出合约
- `APPROVED` 或 `CHANGES_REQUESTED`（逐条 [P0/P1/P2] 文件:行 — 问题 — 修法）
- 先落盘: /mnt/data/dev/task-planner-skill/plans/task-v103-ask-default-timeout/subagent-state/04-cr-p5.md

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P5
completed_steps: 逐条
files_written: 检查点路径
evidence: 结论+专项摘要
issues: 无或明细
next_step: 一句话
self_check: 6 专项逐项结论
