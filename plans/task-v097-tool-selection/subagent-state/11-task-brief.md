# P7-S1 任务书: Code Review 审查 task-v097 全量 diff（task-v097）

任务: 上下文隔离审查主仓 merge commit 52b434f 引入的全部变更（`git diff 26f938c..52b434f`,主仓 /mnt/data/dev/task-planner-skill）。禁任何写入/禁 git 状态变更操作（只读审查）。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/task_plan.md（只读: Goal/VC-7/强制约束段=审查基准）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/findings.md（只读背景）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/progress.md（子代理禁写）

## 审查对象
`git -C /mnt/data/dev/task-planner-skill diff 26f938c..52b434f`（8 文件: critical-rules.md+11 / SKILL.md+5-2 / selftest-skill-split.sh / templates/task_plan.md+14 / mini-lite-type.md+1 / subagent_dispatch.md+1 / template-mapping.md+15 / template-guide.md+11 / plan-writer.md+1 / selftest-tool-selection.sh 新建 107 行± / selftest-registry.tsv+1——以实际 diff 为准）

## 专项核对点（逐项给结论）
1. **锚保全**: 39.1/39.7/C27 既有子串零改动（diff 中不得出现这三处行的删改;「Rules 1-39」在 SKILL.md 保持 2 处字面,无「1-40」字面引入）
2. **40.3 披露纪律**: Rule 40.3 是否如实披露 /goal 为用户侧命令不可代调,无"技能可代调/读取运行态"的虚构表述
3. **40.4 与 39.1 调和**: 40.4 是否只增"建议登记面"而无自动路由语义;39.1 原文是否逐字未动
4. **模板契约标记**: general 模板新区块是否含定位声明（不替代 Executor 机器事实源）;区块内是否有 `### Phase`/`**Status:**`/`**Executor:**` 伪行;mini-lite 豁免声明在位
5. **纯增量纪律**: 全 diff 是否零功能性删除（deletions 应仅为行内括注/断言上限替换）
6. **selftest 质量**: selftest-tool-selection.sh 断言是否锚定真实内容（抽 3 条对照实际文件）、Total 行格式同构 WF 范式
7. **一般缺陷**: 上述之外的任何正确性/一致性问题

## 输出合约
- 结论二选一: `APPROVED` 或 `CHANGES_REQUESTED`
- CHANGES_REQUESTED 时逐条列: [P0/P1/P2] 文件:行 — 问题 — 建议修法
- 先落盘再返回: /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/subagent-state/11-code-reviewer.md

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P7-S1
completed_steps: 逐条
files_written: 检查点路径
evidence: 结论+问题清单摘要
issues: 无或明细
next_step: 一句话
self_check: 7 专项逐项结论
