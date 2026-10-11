# [sub:20-executor] task-v155 S20 — 守卫修正单元

## 执行摘要
- 时间: 2026-10-10
- 范围: check-complete.sh 空输入误报 + selftest-report-reviewability.sh RRV-07 双锚精确化
- 结果: 全部验收通过

## 修改明细

### 1. check-complete.sh:983 — 空输入误报修复
- 原文: `if grep -n '待裁决' "$ds_file" 2>/dev/null | grep -vqE '/|http'; then`
- 问题: ugrep 对空输入的 `grep -vqE` 退出码=0（误报 warn），GNU grep=1（正确不报）
- 修法: 先取命中行数 n，仅当 n>0 再判路径形态
- 注释: 根因+修法已写入 :983-986

### 2. selftest-report-reviewability.sh:143 — RRV-07 双锚精确化
- 原文: `RRV07_LINT=$(cnt "report-lint" "$CHECKCOMPLETE")`
- 问题: `grep -c 'report-lint'` 命中 6 次（含 5 次注释行），守卫可腐化
- 修法: 双锚——`run_report_lint()` 函数定义 + `printf '[report-lint]` 输出行
- 注释: 精确化原因已写入 :143-146

## 验证结果
1. `bash -n scripts/check-complete.sh` → SYNTAX_OK
2. 空输入: `PLAN_FILE=/tmp/v155-test-empty/task_plan.md` → `[report-lint] SKIPPED` (不误 warn)
3. 真阳性: `PLAN_FILE=/tmp/v155-test-pending/task_plan.md` → `[report-lint] ⚠ 待裁决项缺对象定位` (warn 保留)
4. `bash scripts/selftest-report-reviewability.sh` → Total: PASS=13 FAIL=0 WARN=0, exit 0
5. RRV-07 双锚实测: func=1 printf=5

## 最终结论
status: done
acceptance: 4/4 pass — [1:PASS bash -n SYNTAX_OK; 2:PASS 空输入 SKIPPED 不误 warn; 3:PASS 真阳性 warn 保留; 4:PASS selftest 13/13 FAIL=0]
files: /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/check-complete.sh(+7/-1); /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/selftest-report-reviewability.sh(+8/-2)
evidence: check-complete.sh:987-991（n>0 前置守卫+根因注释）; selftest-report-reviewability.sh:148-156（双锚 func=1 printf=5）; selftest 输出 Total: PASS=13 FAIL=0
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/subagent-state/20-executor.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
