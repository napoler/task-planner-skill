status: in_progress
## 里程碑
- 09:00 M1: 修改1 完成 — §7 整节替换为 8 字段严格模板 + 已填示例 + 禁令 + 返回前必做4条
- 09:01 M2: 修改2 完成 — §8 T5 行对齐「= 第 7 节同一 8 字段块,逐字段」
- 09:01 M3: 验收 grep 全 PASS(见最终结论 evidence)
- 09:02 M4: findings/progress 追加完成;git status 确认 worktree 仅模板文件变更

## 最终结论
status: done
acceptance: 5/5 pass — [1:PASS 2:PASS 3:PASS 4:PASS 5:PASS]
files: /mnt/data/dev/task-planner-skill-worktrees/task-v057-subagent-io-contract/skills/task-planner/templates/subagent_dispatch.md(+31/-12); /mnt/data/dev/task-planner-skill/plans/task-v057-subagent-io-contract/findings.md(+4/-0); /mnt/data/dev/task-planner-skill/plans/task-v057-subagent-io-contract/progress.md(+1/-0)
evidence: grep -c '^status: '=2; grep -c '8 字段之后不得有任何内容'=1; grep -c '结论摘要(≤3 行)'=0; grep -c '[done|partial|failed|timeout]'=0; grep -c '= 第 7 节同一 8 字段块'=1; grep -c '^## 8. checkpoint'与'^## 9. 上下文预算'各=1; wc -l → 104(100-108 内)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v057-subagent-io-contract/subagent-state/06-executor-p3s2.md (status: done)
findings_written: findings.md #### [sub:06-executor] 模板 §7 严格返回落地
blockers: none
confidence: HIGH
