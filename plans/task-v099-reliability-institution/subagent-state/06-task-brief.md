# P5-S1 任务书: CR Gate 隔离审查（task-v099,d066159 全量 diff）

任务: 上下文隔离 Code Review——审查主仓 commit 区间 55c24fc..d066159（task-v099 实现面,9 文件 130+/9-）。禁任何写入（只读审查;修复由主进程按结论调度,你不改文件、不 git 操作）。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/task_plan.md（只读: VC-6 判定标准+「执行范围限制」表=审查范围基准）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/findings.md（只读）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/progress.md（子代理禁写）

## 审查对象
`git -C /mnt/data/dev/task-planner-skill diff 55c24fc..d066159`（主仓 /mnt/data/dev/task-planner-skill,只读）
代码文件（主审）: scripts/selftest-reliability-institution.sh（新建 94 行）/ selftest-self-resolution.sh（SR-11/12 锚级联）/ selftest-skill-split.sh（级联行）
文档面（轻审一致性）: critical-rules.md（+19 纯增）/ SKILL.md（三锚+级联）/ templates×2 / companion/agents/plan-writer.md / selftest-registry.tsv

## 专项核对点（逐项给结论与证据 file:line 或 diff 片段）
1. **纯增量边界**: critical-rules.md +19 是否纯追加（既有 413 行零改动）;SKILL.md 3 处 deletion 是否仅行内括注/枚举扩写;Rule 22-41 任何原文是否被触碰
2. **42/43 措辞质量**: 42.3「补充动作作为 S-unit 登记」是否无歧义;43.1「8 字段 evidence 无证据=该项视为未完成」与既有完成门是否冲突;43.2 档位表与 SKILL 子代理路由表 model 列是否一致;43.3 候选对比表是否可操作
3. **越界数字字面**: 新增文本 `grep -nE '1-4[0-9]'` 是否零命中;「Rules 1-39」字面 2 处是否保全
4. **selftest-reliability-institution.sh 质量**: 12 断言锚是否锚定真实内容（抽 4 条对照实际文件复 grep）;脚本是否纯静态只读零仓库写入;Total 行格式是否与仓内既有脚本同构
5. **SR-11/SR-12 级联修正面**: selftest-self-resolution.sh 改动是否仅锚值（task-v099 label/行数 40）且断言语义零改动
6. **registry 双向一致**: tsv 新行四列与 selftest-registry.sh 消费口径是否对齐

## 输出合约
- 结论二选一: `APPROVED` 或 `CHANGES_REQUESTED`
- CHANGES_REQUESTED 时逐条: [P0/P1/P2] 文件:行 — 问题 — 建议修法
- 先落盘再返回: /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/subagent-state/06-cr-p5.md（含结论+6 专项逐项+证据）

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P5-S1
completed_steps: 逐条
files_written: 检查点路径
evidence: 结论+问题清单摘要
issues: 无或明细
next_step: 一句话
self_check: 6 专项逐项结论
