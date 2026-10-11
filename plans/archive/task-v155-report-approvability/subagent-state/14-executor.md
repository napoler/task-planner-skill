# S14 checkpoint — check-complete.sh report-lint 段（executor）

- 任务: 在 worktree 内 `skills/task-planner/scripts/check-complete.sh` 的 rcov-gate 段之后追加 report-lint 段（fail-open warn，不改任何既有 exit 语义）
- worktree: /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability
- 时间: 2026-10-10

## 动作
- 插入位置: rcov-gate 段结束处（rcov-gate 外层 `fi` 之后、Learning Gate 之前，4 空格同层级）插入独立函数 `run_report_lint()` + 一处调用。
- 三项 fail-open warn 检查: ①「## 2. 产出清单」区表格数据行（排除表头/分隔行）不含 `/` ≥2 行 → warn（Rule 48.2/70②）；②「## 5. 下一步建议」区缺「看点」或「动作」→ warn（Rule 48.4/70④）；③「待裁决」行同行无 `/`/`http` → warn（Rule 70②）。
- delivery-summary.md 不存在 → SKIPPED 后 `return 0`。区块锚容忍 `## 2.`/`## 5.`（金标准模板）与 `## 二、`/`## 五、`（历史形态）。
- 只 `printf '[report-lint] ⚠ ...' >&2`；不改 exit code / 不写 FAIL 计数 / return 恒 0。

## 验证证据
- `bash -n` rc=0；`grep -c "report-lint"`=6（≥4）
- `git diff --numstat`=53/0（零删除）；新增行 `grep -c 'exit 1'`=0
- 冒烟（/tmp 最小样例）: worktree 输出 3 行 `[report-lint] ⚠`；WT_EXIT=0 == MASTER_EXIT=0
- 缺 delivery-summary → `[report-lint] SKIPPED` exit 0；干净样例与真实 v149 summary 零 warn（无假阳性）
- `selftest-report-reviewability.sh` RRV-07 由 WARN 翻 PASS（Total PASS=12 FAIL=0 WARN=1）
- 注: `selftest-goal-unit-goal-mode.sh` G-09 FAIL（SKILL.md=518>515）系 S2/S3 早前单元所致（master=511），不在 S14 scope

## 最终结论
```
status: done
acceptance: 4/4 pass — [1:PASS bash -n rc=0 | 2:PASS grep -c report-lint=6(≥4) | 3:PASS git diff +53/-0 且新增行 exit 1=0 | 4:PASS 冒烟 worktree 输出 3 行 [report-lint] ⚠ 且 WT_EXIT=0==MASTER_EXIT=0]
files: /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/check-complete.sh (+53/-0)
evidence: check-complete.sh:938 run_report_lint() 定义 → `[report-lint] ⚠ 产出清单存在无路径行 (Rule 48.2/70② 可定位性)` / `[report-lint] ⚠ 下一步建议缺看点/动作定位三要素 (Rule 48.4/70④)` / `[report-lint] ⚠ 待裁决项缺对象定位 (Rule 70②)`；WT_EXIT=0 MASTER_EXIT=0
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/subagent-state/14-executor.md (status: done)
findings_written: #### [sub:14-executor] check-complete.sh rcov-gate 段后追加 report-lint 守护段（S14 机械单元）
blockers: none
confidence: HIGH
```
