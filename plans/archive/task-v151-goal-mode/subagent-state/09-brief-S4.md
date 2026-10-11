# 任务书 S4：新 selftest-goal-unit-goal-mode.sh + registry 登记 + 钉值级联

## 1. 目标
task-v151 的 S4 单任务：worktree 内新建 scripts/selftest-goal-unit-goal-mode.sh（G-01..G-09 静态断言）+ selftest-registry.tsv 追加 1 行 + 钉值级联 D1/D2 两处修正。
- 需求锚（Rule 51.1a）：R4「自动分解任务，然后按照调度之后逐个进行解决」

## 2. 输入
- 计划三文件（只读）：/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/{task_plan.md,findings.md,progress.md}
- 材料包：
  - ① 设计蓝本 /mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/design-draft.md —— §4.4 断言清单 G-01..G-09 全文 + §5 钉值级联清单 D1/D2（D3 即本任务 registry 行）
  - ② 既有 selftest 范式参考：worktree skills/task-planner/scripts/selftest-evidence-goal-gate.sh（同域守护脚本，照其文件骨架/断言计数输出/exit 语义写新脚本；先 Read 前 40 行看骨架）
  - ③ S1-S3 已落地面：critical-rules.md 行 848-860（Rule 66）、templates/task_plan.md 行 104 起（Goal 单元表）、SKILL.md（Rule 66 摘要行+C45 行+1-66 三处）、check-plan-dispatch.sh 行 314 起（66.5 段）、check-complete.sh 行 1212-1255（goal-gate 段）
- 伴飞技能：无（纯机械单元）；并行组：无（串行槽）
- 检索优先契约（Rule 63）：写断言前逐个 grep 实态确认锚点存在（禁凭 design 文本假设行号；行号可能因前序 S-unit 漂移，用内容锚不用行号锚）

## 3. 验收标准
- A1：新脚本 worktree skills/task-planner/scripts/selftest-goal-unit-goal-mode.sh 存在，断言面=G-01..G-09（design §4.4 表逐条实现；G-09=SKILL 行数≤515 钉值断言）；输出范式对齐既有 selftest（PASS=9 FAIL=0 行）；`bash 该脚本` exit 0
- A2：selftest-registry.tsv 末行追加 `selftest-goal-unit-goal-mode.sh`（4 列对齐既有行：script/domain/trigger_scenarios/dep_anchors；domain=Rule 66 goal 单元固化守护）；`wc -l` = 65（64 脚本+表头）
- A3：钉值级联 D1：worktree selftest-skill-split.sh 行 46 附近 SKILL 行数上限 510→515（先 grep -n '510' 该文件确认断言行原文再改，只改该数值）
- A4：钉值级联 D2：worktree selftest-evidence-goal-gate.sh 的 EG-16 断言（`^66\.[0-9] =0` 前向防线）语义演进——58 块范围内保留「58 块尾无 66 入侵」负断言，全文件面 `^66\.[0-9]` 断言删除或改为 =6（先 Read 该断言实现，取最小改动且 PASS 的口径；改动说明入检查点）
- A5：全量回归（worktree 内 `for s in scripts/selftest-*.sh; do bash $s; done` 汇总）：ΣFAIL=0（基线 0，零新增）；输出摘要行入检查点
- A6：注释 What+Why（新脚本头注释说明守护面与 66.6 出处）

## 4. Scope 禁改
- 只动：新 selftest 脚本 + selftest-registry.tsv + selftest-skill-split.sh（D1 行）+ selftest-evidence-goal-gate.sh（D2 断言）四文件；禁 git 写操作；禁改 check-complete/SKILL/模板/critical-rules（S1-S3 交付面）
- D5 兜底：落地前 grep 一次全仓 selftest 中是否有钉 templates/task_plan.md 行数的断言（`grep -rn 'task_plan.*行数\|wc.*task_plan\|504\|516' skills/task-planner/scripts/selftest-*.sh` 口径自定），有则登记进检查点处理

## 5. 工作路径
worktree=/mnt/data/dev/task-planner-skill-worktrees/v151-goal-mode（不切 CWD）

## 6. 时长预算
脚本+回归 → 40 分钟（含全量回归跑时）；超时返回 partial

## 7. 返回格式（严格 8 字段，字段后无内容）
```
status: done | partial | failed
acceptance: <n>/6 pass — [A1:PASS ... A6:PASS]
files: <绝对路径>(+N/-M); ...
evidence: <file:line 或 命令→关键输出行>; 新selftest输出行+回归ΣFAIL行+registry行数
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/subagent-state/08-executor-S4.md
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```

## 8. checkpoint
/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/subagent-state/08-executor-S4.md：里程碑带时间戳；遇错写「错误与受阻」；结束写「最终结论」=同一 8 字段块

## 9. 上下文预算
只 Read 本节列出路径区段；selftest 全量回归输出只留 FAIL>0 行与 Σ 求和行进检查点，全 PASS 明细不贴；完成前 Read 新脚本确认落盘