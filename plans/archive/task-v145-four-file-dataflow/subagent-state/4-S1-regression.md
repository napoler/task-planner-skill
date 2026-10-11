# 4-S1 全量 selftest 回归 checkpoint（master 基线 vs wt/task-v145）
status: done

## 里程碑
- [M1] Pre-check：两处各 57 个 selftest-*.sh；master 独有 selftest-evidence-goal-gate.sh，worktree 独有 selftest-four-file-dataflow.sh；共有 56 个中仅 selftest-iteration-persistence.sh 内容不同（md5）；依赖 jq/git/python3/timeout 齐备；脚本均 SCRIPT_DIR 自定位（测各自树文件，非安装位）
- [M2] master 套件完成：57 脚本、15 nonzero、FAIL 总 21 → /tmp/v145-regression-master.out（+logs /tmp/v145-regression-master-logs/）
- [M3] worktree 套件完成：57 脚本、15 nonzero、FAIL 总 22 → /tmp/v145-regression-wt.out（+logs /tmp/v145-regression-wt-logs/）
- [M4] 比对：15 个 nonzero 脚本清单两侧一致；14 个脚本 FAIL 行逐字一致（含计数）；唯一计数差异 = selftest-iteration-persistence.sh（master PASS=17 FAIL=1 → worktree PASS=16 FAIL=2，增量 IP-14）
- [M5] IP-14 归因复现：worktree 版该脚本与 merge-base a7c01a8 版 md5 相同（bdae7356e300df8022316e7423a2384b，本任务净改动不含它）；git archive a7c01a8 全树到 /tmp/v145-baseline-check 复跑 = `Total: 18 PASS=16 FAIL=2`（IP-14/IP-15 逐字一致）→ FAIL 任务开始前已存在（基线脚本旧口径 `^58\.`；master 主线已做「58→59 级联演进」）→ 非本任务引入
- [M6] 零修改验证：两处 git status 跑前/跑后一致；plans/.active_plan 等 M 文件 mtime ≤ 02:09（早于 03:0x 套件运行）；config.json 两树 md5 相同（bf2b5e7c…）
- [M7] four-file-dataflow 18/18 PASS（FF-01..FF-18 全 PASS，exit 0）确认

## 最终结论（8 字段块）
status: done
acceptance: 4/4 pass
1. PASS——两份输出在位含每脚本 exit 码：`selftest-active-plan.sh exit=0 dur=11771ms | Total: 29 PASS=29 FAIL=0`（master）/ 同格式 57 行（wt）
2. PASS——worktree FAIL 总 22；本任务引入 0（唯一增量 IP-14 经 merge-base 复现 `Total: 18 PASS=16 FAIL=2` 预存在）；master 既有 FAIL = 15 脚本 21 条
3. PASS——`selftest-four-file-dataflow.sh exit=0 dur=224ms | Total: 18 PASS=18 FAIL=0`
4. PASS——逐脚本 exit 码清单：`SUITE_DONE total_scripts=57 nonzero_exit=15`（两 .out 各 57 行；15 nonzero 清单两侧逐字一致）
files: /tmp/v145-regression-master.out /tmp/v145-regression-wt.out（+logs /tmp/v145-regression-{master,wt}-logs/；复现树 /tmp/v145-baseline-check/；runner /tmp/v145-run-suite.sh）+3/-0（checkpoint 新 1；findings/progress 各追加 1）
evidence: `bash /tmp/v145-run-suite.sh <master scripts> …` → `SUITE_DONE total_scripts=57 nonzero_exit=15`（FAIL 总 21）；`bash /tmp/v145-run-suite.sh <wt scripts> …` → `SUITE_DONE total_scripts=57 nonzero_exit=15`（FAIL 总 22）；`git archive a7c01a8 … && bash selftest-iteration-persistence.sh` → `IP-14 FAIL critical-rules.md 57 块尾「58.x」=8（应 =0，58 号被顺手创建）` + `Total: 18 PASS=16 FAIL=2` → 本任务引入 FAIL=0
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v145-four-file-dataflow/subagent-state/4-S1-regression.md + status: done
findings_written: #### [sub:4-S1-code-runner] 全量 selftest 回归：master 基线 vs wt/task-v145（57+57 脚本） | none
blockers: none
confidence: HIGH
