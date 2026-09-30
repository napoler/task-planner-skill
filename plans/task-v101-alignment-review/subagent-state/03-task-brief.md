# P5 任务书: CR Gate 隔离审查（task-v101,4194f34..54bd512）

任务: 上下文隔离 Code Review——审查主仓 commit 区间 4194f34..54bd512（task-v101 实现面）。只读,禁改文件禁 git 写操作。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v101-alignment-review/（只读）
- progress.md: 同目录（子代理禁写）

## 审查对象
`git -C /mnt/data/dev/task-planner-skill diff 4194f34..54bd512`
- 主审: review-library/alignment-review/SKILL.md（新建,内容质量+清单案例化程度）
- 主审: scripts/selftest-review-library.sh（RL-01/DIRS/文案 10→11 级联面——含自检:「10」残留清零但 ≥10 下限保留）
- 轻审: critical-rules.md（42.2 枚举 10→11 类+尾注）/ general-review/SKILL.md（枚举 +alignment）

## 专项核对点（逐项给结论与证据）
1. **alignment-review 内容质量**: 逐个 Read;清单是否领域具体化（每条有检查动作+判定标准,非空话）;与 general-review 的分工边界是否清晰（general=混合兜底,alignment=对齐专用面）
2. **输出合约自洽**: APPROVED/CHANGES_REQUESTED+P0-P2 与池内家族一致;Rule 43.1 实引;「机器可复现命令优先」的对齐领域特性是否体现
3. **级联完整性**: 池 10→11 后所有应联动处是否联动——selftest RL-01/DIRS/文案、CRIT 42.2 枚举+类数、general-review 枚举;`grep -rn '10 类通用'` 与池内「10 个目录」类字样是否清零（≥10 下限除外）
4. **42.2 行语义保全**: ①②③④层+「均未命中=缺口」+尾注追加格式;枚举追加 alignment 位置合理
5. **越界字面与字面锚**: 新增文本 1-4x 零命中;「Rules 1-39」字面 2 处保全
6. **一般缺陷**: 上述之外任何正确性/一致性问题

## 输出合约
- `APPROVED` 或 `CHANGES_REQUESTED`（逐条 [P0/P1/P2] 文件:行 — 问题 — 修法）
- 先落盘: /mnt/data/dev/task-planner-skill/plans/task-v101-alignment-review/subagent-state/03-cr-p5.md

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P5
completed_steps: 逐条
files_written: 检查点路径
evidence: 结论+专项摘要
issues: 无或明细
next_step: 一句话
self_check: 6 专项逐项结论
