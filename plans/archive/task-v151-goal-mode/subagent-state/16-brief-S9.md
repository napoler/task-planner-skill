# 任务书 S9：带 /goal 官方文档的重 CR（task-v151 Rule 66 条款与实现全量复审）

## 1. 目标
对 task-v151 Rule 66 全链（条款+模板+双守卫+selftest）做第二轮 CR，本轮新增官方 /goal 文档基准，重点裁决 66.2 口径与官方语义的偏差。
- 需求锚（Rule 51.1a）：R2「...使用 goal 来进行任务的推进，确保整个任务执行的可靠性」+R3「我说的核心就是使用 VSCode 自带的 /goal 就是目标模式」

## 2. 输入
- 计划三文件（只读）：/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/{task_plan.md,findings.md,progress.md}
- 官方文档基准（本轮新增，必读）：/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/subagent-state/09-goal-official-docs.md（§1 官方语义 8 条+§2 官方推荐 goal 写法要点，均附 zcode.z.ai 原文引句）
- 前次 CR 检查点（复验面）：/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/subagent-state/11-code-reviewer-S6.md + 13-executor-S6fix.md（F1-F3 修复已落 commit 6cf8cd7）
- 审查对象：主仓 /mnt/data/dev/task-planner-skill（master ebb5fba 已含 101475f+6cf8cd7，worktree 已清）——文件面：
  - skills/task-planner/references/critical-rules.md 行 848-860（Rule 66 六子条）
  - skills/task-planner/templates/task_plan.md 行 104 起（Goal 单元表区块）
  - skills/task-planner/scripts/check-plan-dispatch.sh 行 314 起（66.5 段+档位三分支）
  - skills/task-planner/scripts/check-complete.sh 行 1212 起（[goal-gate] 段）
  - skills/task-planner/scripts/attest-plan.sh（--skip-goal-check 接线）
  - skills/task-planner/scripts/selftest-goal-unit-goal-mode.sh + selftest-registry.tsv
  - skills/task-planner/SKILL.md（Rule 66 摘要行+C45）
- 注意：本地 ~/.zcode/commands/goal.md 是用户自建 6 步工作流命令，与官方内置 /goal 同名不同义（09 检查点 §3 重要区分）——审查时禁混用两者语义
- 伴飞技能：无；并行组：无
- 检索优先契约（Rule 63）：官方引句一律以 09 检查点为准（其 URL 已核），勿凭记忆

## 3. 验收标准（审查维度）
- V1【核心=偏差裁决】66.2 及关联面 vs 官方 09 检查点逐条对照，输出偏差清单（每条=66 原文锚 vs 官方引句+偏差定性：错误/不完整/兼容措辞）：
  - a) 66.2「技能层不可代调/不可读运行态」vs 官方子命令面（show/pause/resume 语义存在但属用户侧命令，禁令是否仍成立——给裁决）
  - b) 「一个会话仅一个目标」vs 66.4「逐 goal 推进」（本机制 goal 单元表多行 vs 官方单目标限制——是否冲突？多 goal 单元如何在单会话 /goal 约束下消费：轮替 replace 还是只作证据源？给建议）
  - c) 官方「todo 未完成不判完成」vs 66.3「[goal:Gn] 证据行门控」（机制互补面确认，无冲突即可）
  - d) 官方「plan 模式与 goal 模式冲突，须先切执行模式」——SKILL/模板是否需补提示行（给建议）
  - e) 官方 goal 写法要点（一句话可陈述+具体可校验+实据判定）vs 66.1 六列契约「完整验证方式列」——是否对齐（应为增强关系，确认无冲突）
- V2：66.5 档位三分支+66.3 终验对照实现正确性复验（F1-F3 修复面未回退：attest 接线/口径统一/死变量清理）
- V3：零回归面复核：bash -n 三守卫脚本 + 新 selftest exit 0 + `grep -c '^66\.' critical-rules.md` =6
- V4：官方语义进条款的增量建议（若 V1 有偏差）——只列建议不改文件（fix-phase 由主进程另派）
- 结论：APPROVED（无 P0/P1 偏差）或 CHANGES_REQUESTED（逐条 F 编号+文件:行+修建议，区分「必须修（语义错误）」与「建议增强」两档）

## 4. Scope 禁改
只读审查（含 09 检查点全读）；禁改任何文件；CHANGES 只列不改

## 5. 工作路径
主仓=/mnt/data/dev/task-planner-skill（不切 CWD，不建 worktree——纯只读）

## 6. 时长预算
重 CR → 35 分钟；超时返回 partial 列已完成维度

## 7. 返回格式（严格 8 字段，字段后无内容）
```
status: done | partial | failed
acceptance: <n>/4 pass — [V1:PASS V2:PASS V3:PASS V4:PASS]
files: none（只读）
evidence: <命令→关键输出行>; V1 偏差清单逐条（66锚 vs 官方引句+定性）+ 结论=APPROVED 或 CHANGES（必须修 N 条/建议增强 M 条）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/subagent-state/15-code-reviewer-S9.md
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```
V1 偏差裁决全文与 V4 建议入检查点「审查明细」段。

## 8. checkpoint
/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/subagent-state/15-code-reviewer-S9.md：逐维过程+V3 运行面输出原文+V1 偏差对照表（66 锚|官方引句|定性|建议）；结束写「最终结论」=同一 8 字段块

## 9. 上下文预算
只 Read §2 列出文件（09 检查点全文、critical-rules 848-860、两守卫段、attest 接线段、SKILL C45/摘要行区）；V3 跑 3 条 bash -n+1 条 selftest+1 条 grep，不重跑全量 64；输出预算 ≤300 行