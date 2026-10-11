# P5 任务书: CR Gate 隔离审查（task-v106,e620a03..b5acff6）

任务: 上下文隔离 Code Review——审查主仓 commit 区间 e620a03..b5acff6（task-v106 新建 iterative-optimizer skill）。只读,禁改文件禁 git 写操作。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v106-iterative-optimizer/（只读）
- progress.md: 同目录（子代理禁写）

## 审查对象
`git -C /mnt/data/dev/task-planner-skill diff e620a03..b5acff6`
- 主审: skills/iterative-optimizer/SKILL.md（新建,96 行——内容质量与设计完备性）
- 轻审: task-planner/scripts/selftest-iterative-optimizer.sh（IL-01..08,断言相对路径解析）;scripts/selftest-registry.tsv(+1 行)

## 专项核对点（逐项给结论与证据）
1. **skill 设计完备性（主审）**: 五步闭环（评估→诊断弱点→定向改进→门控三态）是否完整可执行;输入契约（QC≥3 且≥1 机器可检查/max_iterations 默认 5/改进约束）是否防住「无标准开跑」;门控铁律是否防住 AI 自报收敛（S74 口径）;单 focus 原则+回归重跑是否闭合归因;连续 2 轮无改善停止（防 token 失控）;状态文件断点续跑语义;迭代摘要三要素+结论三枚举
2. **Goal 质量（S47/48）**: Goal 语句含交付物名词+形式+标准;QC/门控上下文主观判定词（更好/大致/应该/足够/合理）零命中
3. **触发边界**: 适用/不触发边界是否清晰（防循环套一次性任务过度工程化;防无标准探索任务误触发）
4. **selftest 有效性**: IL-01..08 断言对照 SKILL.md 实文;断言路径相对解析（无 /home/terry 写死）;registry 行与 SR-12 咬合
5. **一致性**: 与仓内 skill 家族形态一致（frontmatter 两字段/中文主体英文术语/反模式 ❌✅ 形态）;「Rules 1-39」2 处保全;config 零改动
6. **一般缺陷**: 其他正确性问题（含表述歧义——如「跳 Step 4 ①」类编号指代是否清晰）

## 输出合约
- `APPROVED` 或 `CHANGES_REQUESTED`（逐条 [P0/P1/P2] 文件:行 — 问题 — 修法）
- 先落盘: /mnt/data/dev/task-planner-skill/plans/task-v106-iterative-optimizer/subagent-state/03-cr-p5.md

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P5
completed_steps: 逐条
files_written: 检查点路径
evidence: 结论+专项摘要
issues: 无或明细
next_step: 一句话
self_check: 6 专项逐项结论
