# P5 任务书: CR Gate 隔离审查（task-v102,5ddc317..f419419）

任务: 上下文隔离 Code Review——审查主仓 commit 区间 5ddc317..f419419（task-v102 实现面）。只读,禁改文件禁 git 写操作。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v102-alignment-upgrade/（只读）
- progress.md: 同目录（子代理禁写）

## 审查对象
`git -C /mnt/data/dev/task-planner-skill diff 5ddc317..f419419`
- 主审: review-library/alignment-review/SKILL.md（验证优先升级——写入前校验闸门五步/变更记录输出/触发扩展）
- 主审: references/critical-rules.md（42.6 五段追加——42.5/43 邻接区）
- 主审: scripts/ 三脚本（RL-11/R-01 级联/SR-11 宽容正则根治/T-主 行钉）
- 轻审: SKILL.md（C32+摘要行）/templates×2

## 专项核对点（逐项给结论与证据）
1. **alignment 升级语义**: 写入前闸门五步是否完整可执行;「未经一致性校验，不直接追加新内容」闸门级纪律是否明确;变更记录五要素是否可操作;既有触发条件/四要素/清单 14 条是否零改动（diff 对照）
2. **42.6 语义与位置**: 42.6.1 与 43.1 证据先行是否互补不冲突;42.6.2「完成前对齐标准流程」可操作性;42.5/43 邻接零改动;与 42.2 四级检测的衔接
3. **计数级联完整性**: R-01 5→10（实测 grep '^42\.' 对照）;T-主 439→440（实测 wc SKILL）;SR-11 宽容正则语义等价性;RL-11 三锚对照 alignment 实文
4. **C32/模板行**: C32 行措辞与 C30/C31 家族一致;模板「对齐审查」行与「质量审查工具」行分工清晰
5. **越界字面与字面锚**: 新增文本 1-4x 零命中;「Rules 1-39」2 处保全
6. **一般缺陷**: 其他正确性/一致性问题

## 输出合约
- `APPROVED` 或 `CHANGES_REQUESTED`（逐条 [P0/P1/P2] 文件:行 — 问题 — 修法）
- 先落盘: /mnt/data/dev/task-planner-skill/plans/task-v102-alignment-upgrade/subagent-state/05-cr-p5.md

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P5
completed_steps: 逐条
files_written: 检查点路径
evidence: 结论+专项摘要
issues: 无或明细
next_step: 一句话
self_check: 6 专项逐项结论
