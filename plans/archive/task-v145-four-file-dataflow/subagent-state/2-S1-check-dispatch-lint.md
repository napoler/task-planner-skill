# Checkpoint: 2-S1 check-dispatch 契约收窄 lint
status: done

- [2026-10-08 01:51] 读规格: check-dispatch.sh 头部 :35-68 v075 P3-S1 范式 + get_mode()/scan_missing/fine_grain_checks/cmd_check/cmd_pretool 已通读; critical-rules.md:700 Rule 60.2 判定语义已读
- [2026-10-08 01:52] 基线留底: check 对合规 prompt 输出空/exit 0; check 对收窄 prompt(负样例)输出空/exit 0 = 盲区实证
- [2026-10-08 01:52] 实现: 新增 scan_contract_narrowing()（双条件 ∧）+ cmd_check 接入（stdout+exit 1）+ fine_grain_checks ⑥（enforce=exit 2/warn=计数落盘）+ 头部注释段; bash -n SYNTAX_OK; git diff +63/-0（单文件）
- [2026-10-08 01:53] 验收: 负样例 check 输出 [dispatch-contract] 违规 exit 1 / enforce pretool exit 2; 正样例 check exit 0 放行; 回归 check 改动前后输出一致(空/exit 0); 误报守卫 edge1/2/3 全放行; warn 计数文件范式命中
- [2026-10-08 01:53] 回归: check-dispatch 相关 5 个 selftest 全 FAIL=0 rc=0（selftest-dispatch/grain/fine-grain-steps/conclusion-discipline/tier-b）

## 最终结论

status: done
acceptance: 4/4 pass
files: /mnt/data/dev/task-planner-skill-worktrees/task-v145/skills/task-planner/scripts/check-dispatch.sh +63/-0
evidence: check-dispatch.sh:152-175 scan_contract_narrowing; :309-317 cmd_check 接入; :471-482 fine_grain_checks ⑥; 命令→ `bash check-dispatch.sh check /tmp/v145-neg-prompt.md <plan-dir>` 输出 `[dispatch-contract] 🚫 ...` exit=1; `TASK_PLANNER_DISPATCH_ENFORCE=enforce ... pretool` exit=2
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v145-four-file-dataflow/subagent-state/2-S1-check-dispatch-lint.md | status=done
findings_written: #### [sub:2-S1-executor] check-dispatch 契约收窄 lint（Rule 60.2）实测
blockers: none
confidence: HIGH
