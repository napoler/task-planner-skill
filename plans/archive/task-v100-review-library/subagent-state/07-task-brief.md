# P5 任务书: CR Gate 隔离审查（task-v100,539adcc..9b17c05 全量 diff）

任务: 上下文隔离 Code Review——审查主仓 commit 区间 539adcc..9b17c05（task-v100 实现面）。只读审查,禁改文件禁 git 写操作。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/task_plan.md（只读: VC 表+范围表=审查基准）
- findings.md: 同目录（只读）
- progress.md: 同目录（子代理禁写）

## 审查对象
`git -C /mnt/data/dev/task-planner-skill diff 539adcc..9b17c05`（主仓 /mnt/data/dev/task-planner-skill）
- 主审: skills/task-planner/review-library/ 10 个 SKILL.md（新建,内容质量主审——非空壳/领域针对性/四要素）
- 主审: scripts/selftest-review-library.sh（新建 RL 断言）+ selftest-self-resolution.sh（SR-12 动态口径根治）
- 轻审: critical-rules.md（42.2 四级化+42.5 一词）/ SKILL.md（C30+摘要行）/ selftest-registry.tsv

## 专项核对点（逐项给结论与证据）
1. **10 技能内容质量**: 逐个 Read;每领域清单是否具体可执行（≥8 条有效项,禁空洞套话——每条有明确检查动作与判定标准）;领域针对性（security 清单不会与 content 清单雷同）;四要素齐备
2. **输出合约自洽**: 10 个技能的 APPROVED/CHANGES_REQUESTED+P0-P2 分级是否与仓内 CR 家族一致;Rule 43.1 证据要求是否实引
3. **Rule 42.2 四级化语义**: ①②③层原文保留;④层描述准确（池位置/10 类清单）;「均未命中=缺口」语义保留;与 42.3 补充合约衔接无矛盾（④层命中≠缺口）
4. **越界字面**: 新增文本 `grep -nE '1-4[0-9]'` 零命中;「Rules 1-39」字面 2 处保全
5. **新 selftest 质量**: RL 断言抽 5 条对照实际文件复 grep;纯静态只读零写入;Total 同构
6. **SR-12 动态口径**: 根治改动是否语义等价（动态期望=脚本数+表头 vs 硬编码 40）;行内注释是否说明改动缘由
7. **一般缺陷**: 上述之外的任何正确性/一致性问题

## 输出合约
- 结论二选一: `APPROVED` 或 `CHANGES_REQUESTED`
- CHANGES_REQUESTED 逐条: [P0/P1/P2] 文件:行 — 问题 — 建议修法
- 先落盘再返回: /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/subagent-state/07-cr-p5.md

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P5
completed_steps: 逐条
files_written: 检查点路径
evidence: 结论+专项摘要
issues: 无或明细
next_step: 一句话
self_check: 7 专项逐项结论
