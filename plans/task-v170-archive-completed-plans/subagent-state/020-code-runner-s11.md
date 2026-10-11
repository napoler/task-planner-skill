# checkpoint 020-code-runner-s11（task-v170 Phase 5 / S11 全量 selftest 回归门：只跑不修）

任务锚: R3「确保所有的被使用完成的计划任务全部归档处理。」；S-unit=S11（Phase 5 回归门，Rule 46.1 单任务）。
worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans（分支 wt/task-v170-archive-completed-plans，HEAD d35553f；提示词给的 task-v070 worktree 路径不存在，实存即此仓，与 019 checkpoint 的路径裁决一致）。
入口: skills/task-planner/scripts/run-selftests.sh（统一入口，非 tests/smoke.sh）；执行命令 `bash .../run-selftests.sh --fresh`（强制全量重跑，reused=0）。
辅助入口 tests/smoke.sh 另行单跑 = 17 pass / 0 fail rc=0（安装面 smoke，非 selftest-*.sh 断言面）。

## T1 里程碑（时间戳）
- S11 派发后：ls 入口发现 → run-selftests.sh --fresh 后台全量执行（78 脚本）→ 汇总 Total: 78 PASS=63 FAIL=15 (run=78 reused=0)，EXIT=1
- 15 个 FAIL 脚本逐个单跑复现（全部 rc=1，逐脚本 Total 行见下表/明细）；source-anchor-discipline / user-instruction-priority 两脚本因输出非 PASS= 形态被运行器计 0/0，已按单跑实值修正（12/0、7/0）
- 基线对照（003-019 checkpoint 记录态）逐项核对：全部确认 PASS，无偏差
- base 快照（merge-base 618df79=分支基点）grep 复算 8 组模式 → 确认 15 脚本 FAIL 为 epoch 级联族、base 态本应通过
- 零修复动作：仅执行 selftest 与只读 git 命令；worktree `git status --short` 空（零写入，证据见下）

## 逐脚本汇总表（78/78，脚本名 | Total | PASS | FAIL | 退出码 rc）
| 脚本 | Total | PASS | FAIL | rc |
|---|---|---|---|---|
| selftest-absorption-discipline | 14 | 13 | 1 | 1 |
| selftest-active-plan | 29 | 29 | 0 | 0 |
| selftest-agent-coverage | 9 | 9 | 0 | 0 |
| selftest-archive-plan | 16 | 16 | 0 | 0 |
| selftest-ask-default-timeout | 11 | 11 | 0 | 0 |
| selftest-batch-pilot | 10 | 10 | 0 | 0 |
| selftest-capability-persistence | 20 | 19 | 1 | 1 |
| selftest-check-conflicts | 7 | 7 | 0 | 0 |
| selftest-check-drift | 6 | 6 | 0 | 0 |
| selftest-conclusion-discipline | 24 | 24 | 0 | 0 |
| selftest-context-hygiene | 12 | 12 | 0 | 0 |
| selftest-context-pressure | 9 | 8 | 1 | 1 |
| selftest-decision-arbiter | 16 | 16 | 0 | 0 |
| selftest-decision-drift | 23 | 23 | 0 | 0 |
| selftest-decision-grading | 12 | 12 | 0 | 0 |
| selftest-delegation | 38 | 38 | 0 | 0 |
| selftest-dispatch-grain | 10 | 10 | 0 | 0 |
| selftest-dispatch | 31 | 31 | 0 | 0 |
| selftest-drift-check-subagent | 20 | 19 | 1 | 1 |
| selftest-drift-enforcement | 23 | 23 | 0 | 0 |
| selftest-error-fix-prompt-forge | 8 | 8 | 0 | 0 |
| selftest-error-loop | 16 | 15 | 1 | 1 |
| selftest-evidence-goal-gate | 21 | 21 | 0 | 0 |
| selftest-execution-honesty | 14 | 13 | 1 | 1 |
| selftest-execution-stability | 19 | 19 | 0 | 0 |
| selftest-fallback | 31 | 31 | 0 | 0 |
| selftest-final-gate-hash | 22 | 22 | 0 | 0 |
| selftest-fine-grain-steps | 11 | 11 | 0 | 0 |
| selftest-four-file-dataflow | 18 | 18 | 0 | 0 |
| selftest-goal-unit-goal-mode | 9 | 9 | 0 | 0 |
| selftest-interaction | 11 | 11 | 0 | 0 |
| selftest-iteration-persistence | 18 | 17 | 1 | 1 |
| selftest-iterative-optimizer | 8 | 8 | 0 | 0 |
| selftest-knowledge-brief | 16 | 16 | 0 | 0 |
| selftest-lane-advancement | 14 | 13 | 1 | 1 |
| selftest-mechanism-profile | 19 | 19 | 0 | 0 |
| selftest-media-agents | 10 | 10 | 0 | 0 |
| selftest-media-dispatch | 9 | 9 | 0 | 0 |
| selftest-methodology | 16 | 16 | 0 | 0 |
| selftest-parallel-scheduling | 9 | 9 | 0 | 0 |
| selftest-periodic-review | 10 | 10 | 0 | 0 |
| selftest-plan-dispatch | 12 | 12 | 0 | 0 |
| selftest-plan-tier | 32 | 32 | 0 | 0 |
| selftest-pointer-lifecycle | 10 | 10 | 0 | 0 |
| selftest-proactive-research | 15 | 15 | 0 | 0 |
| selftest-reflect-verify | 12 | 11 | 1 | 1 |
| selftest-registry | 5 | 5 | 0 | 0 |
| selftest-reliability-institution | 16 | 16 | 0 | 0 |
| selftest-report-reviewability | 13 | 13 | 0 | 0 |
| selftest-requirement-coverage | 23 | 22 | 1 | 1 |
| selftest-requirement-grading | 7 | 7 | 0 | 0 |
| selftest-rescue-chain | 11 | 11 | 0 | 0 |
| selftest-research-first | 12 | 12 | 0 | 0 |
| selftest-review-library | 15 | 15 | 0 | 0 |
| selftest-root-resolution | 17 | 16 | 1 | 1 |
| selftest-rule23-conflict-scan | 3 | 3 | 0 | 0 |
| selftest-rule-reserve | 10 | 10 | 0 | 0 |
| selftest-self-resolution | 13 | 13 | 0 | 0 |
| selftest-shared-tracker | 11 | 11 | 0 | 0 |
| selftest-skill-collab | 25 | 25 | 0 | 0 |
| selftest-skill-modify | 9 | 9 | 0 | 0 |
| selftest-skill-split | 41 | 40 | 1 | 1 |
| selftest-smart-merge | 18 | 18 | 0 | 0 |
| selftest-source-anchor-discipline | 12 | 12 | 0 | 0 |
| selftest-split-pattern-library | 13 | 13 | 0 | 0 |
| selftest-subagent-granularity-skill-escort | 23 | 23 | 0 | 0 |
| selftest-subagent-return | 11 | 11 | 0 | 0 |
| selftest-summary-readability | 13 | 11 | 2 | 1 |
| selftest-sync-index | 13 | 13 | 0 | 0 |
| selftest-task-boundary | 11 | 11 | 0 | 0 |
| selftest-template-lifecycle | 24 | 24 | 0 | 0 |
| selftest-template-sense | 8 | 8 | 0 | 0 |
| selftest-tier-b | 18 | 18 | 0 | 0 |
| selftest-tool-selection | 12 | 11 | 1 | 1 |
| selftest-user-instruction-priority | 7 | 7 | 0 | 0 |
| selftest-vc-gate | 11 | 11 | 0 | 0 |
| selftest-veto | 13 | 12 | 1 | 1 |
| selftest-workflow-orchestration | 16 | 16 | 0 | 0 |

汇总行（断言口径）: 共 78 脚本、总断言 1184、FAIL 合计 16（15 脚本 FAIL；summary-readability 单脚本含 2 条 FAIL）。
运行器脚本口径汇总行原文: `Total: 78 PASS=63 FAIL=15 (run=78 reused=0)` + `Failed: selftest-absorption-discipline selftest-capability-persistence selftest-context-pressure selftest-drift-check-subagent selftest-error-loop selftest-execution-honesty selftest-iteration-persistence selftest-lane-advancement selftest-reflect-verify selftest-requirement-coverage selftest-root-resolution selftest-skill-split selftest-summary-readability selftest-tool-selection selftest-veto` + `EXIT=1`。
口径注: source-anchor-discipline（`Total: 12 pass, 0 fail`）与 user-instruction-priority（7 个 ✓ + `=== ALL PASS ===`，无 Total 行）输出非 `PASS=` 形态，运行器计 0/0 但 rc=0；上表已按单跑实值修正。

## FAIL 断言明细（16 条，逐条原文）
1. selftest-absorption-discipline: AD-04 — `AD-04 FAIL SKILL.md 接线锚 ≥5：'1-7[4-9]' 三处（全集/索引段/References 表）+ 新指令处理段 'Rule 74' + C51 行`
2. selftest-capability-persistence: CP-05 — `CP-05 FAIL SKILL.md '40-[567][0-9]' 计数=0（应 =1）`
3. selftest-context-pressure: CP-07 — `CP-07 FAIL 1-(69|71|7[4-9])=3 CR=0 C48=2 C49=1 C50=1`
4. selftest-drift-check-subagent: DCS-11 — `DCS-11 FAIL DCS-11 条件缺失（需 40-(69|71|73|7[4-9]) 全集（±+NN 形态） + Rule 61 偏移检查子代理化 + Rule 61 摘要 bullet）`
5. selftest-error-loop: EL-11 — `EL-11 FAIL SKILL.md 缺 Rules 1-3x..7x 宽容锚`
6. selftest-execution-honesty: EH-09 — `EH-09 FAIL SKILL.md Rule 54=3（应 ≥1）或 C38=1（应 =1）或「Rule 40-(5[3-9]|6[0-9]|7[0-6])」=0（应 ≥1，级联漏改）`
7. selftest-iteration-persistence: IP-12 — `IP-12 FAIL SKILL.md 全集声明「Rule 40-[567][0-9]」=0（应 ≥1，级联漏改）`
8. selftest-lane-advancement: LA-12 — `LA-12 FAIL SKILL.md 主锚漂移（Critical Rules 1-7[4-9]=0 应 ≥1 / 1-39=0 应 0）`
9. selftest-reflect-verify: RV-10 — `RV-10 FAIL SKILL.md 缺 'Rules 1-(3[5-9]|[4-7][0-9])' 宽容锚`
10. selftest-requirement-coverage: RC-11 — `RC-11 FAIL SKILL.md 主锚漂移（Critical Rules 1-7[4-9]=0 应 ≥1 / 1-39 变体非 0，SR-07 主锚被改动）`
11. selftest-root-resolution: RR-16 — `RR-16 FAIL SKILL.md 索引行命中=1（应 =1）或索引行未含「Rule 40-(5[3-9]|6[0-9]|7[0-6])」（亦未同时含 50 与 53——级联漏改，CR P1-2 复发）`
12. selftest-skill-split: T-锚 — `[FAIL] T-锚 Rules 1-3..7 宽容计数锚 ≥1`（脚本自跑 Total: 41  PASS=40  FAIL=1）
13. selftest-summary-readability: SRV-03 — `SRV-03 FAIL: SKILL 接线锚(got 1-7[4-9]=2 expect>=3)`
14. selftest-summary-readability: SRV-12 — `SRV-12 FAIL: 9 级联脚本(pass=3 fail=6 expect 9/9)`
15. selftest-tool-selection: TS-05 — `TS-05 FAIL SKILL.md 字面锚漂移（Critical Rules 1-7[4-9]=0 应 ≥1 / 1-39=0 应 0）`
16. selftest-veto: VT-10 — `VT-10 FAIL SKILL.md 缺 Rules 1-3x..7x 宽容锚`

## 已知基线对照（003-019 checkpoint 记录态 vs 本次输出）
| 基线（checkpoint 记录） | 本次实测 | 判定 |
|---|---|---|
| archive-plan 16/16（011/S8） | selftest-archive-plan Total 16 / PASS=16 / FAIL=0（rc=0） | 确认 ✓ |
| kb 16/16（014/S10b） | selftest-knowledge-brief PASS=16 FAIL=0（rc=0） | 确认 ✓ |
| es 19/19（014/S10b） | selftest-execution-stability PASS=19 FAIL=0（rc=0） | 确认 ✓ |
| skill-collab 25/25（015/S10c） | selftest-skill-collab PASS=25 FAIL=0（rc=0） | 确认 ✓ |
| research-first 12/12（015/S10c） | selftest-research-first PASS=12 FAIL=0（rc=0） | 确认 ✓ |
| SR 13/13（019/S10g） | selftest-self-resolution PASS=13 FAIL=0（rc=0） | 确认 ✓ |
| RI 16/16（019/S10g） | selftest-reliability-institution PASS=16 FAIL=0（rc=0） | 确认 ✓ |
| BP-08 PASS（013/S10a） | selftest-batch-pilot PASS=10 FAIL=0（rc=0，含 BP-08 ≤584） | 确认 ✓ |
| DCS-19 PASS（013/S10a） | 单跑输出行 `DCS-19 PASS SKILL.md 行数<=584+61.4 清零+61.5 check-drift.sh` | 确认 ✓ |
| DCS-11 既有 FAIL（013 登记，归 epoch 级联，未修） | 本次仍 FAIL（明细 #4），同脚本其余 19 条全 PASS | 偏差=与 013 登记一致（遗留欠账未清） |

## 失败根因分类（只读复算，base=分支基点 618df79）
全部 15 个 FAIL 脚本属同一族：对 SKILL.md 的 epoch/宽容锚 grep 断言（期望 `1-7x`/`40-5x..7x`/`40-6x..7x` 字面），本任务 SKILL.md 演进 1-76→1-81（S3/S4/S10e 合流）后不再命中。base 快照（`git show 618df79:skills/task-planner/SKILL.md`）对照计数：
| 模式 | base(618df79) | 当前(d35553f) | 关联 FAIL |
|---|---|---|---|
| `Critical Rules 1-7[4-9]` | 2 | 0 | LA-12 / RC-11 / TS-05 |
| `1-7[4-9]` | 3 | 2 | AD-04（≥3 破）/ SRV-03（got=2） |
| `40-[567][0-9]` | 1 | 0 | CP-05（=1 破）/ IP-12 |
| `Rule 40-(5[3-9]|6[0-9]|7[0-6])` | 1 | 0 | EH-09 / RR-16 |
| `Rule 40-(69|71|73|7[4-9])` | 1 | 0 | DCS-11 |
| `Critical Rules 1-(69|71|7[4-9])` | 2 | 0 | CP-07（CR=0） |
| `Rules 1-(3[0-9]|[4-7][0-9])` | 2 | 0 | skill-split T-锚 |
| `Rules 1-(3[1-9]|[4-7][0-9])` | 2 | 0 | EL-11 / VT-10 |
| `Rules 1-(3[5-9]|[4-7][0-9])` | 2 | 0 | RV-10 |
判定: base 态这些断言本应通过（模式均命中），当前 FAIL 由本任务 SKILL.md epoch 演进引入、且 14 个涉事脚本未被本次任务任何 commit 触碰（`git diff --stat 618df79..HEAD` 对 14 脚本为空；drift-check-subagent 仅被 6bf89a8 改行数钉，`git diff | grep -c DCS-11`=0）——即 006 checkpoint「级联清单 C 段（epoch 1-76→1-81 级联，只输出不执行，交后续单元）」尚未执行完的部分；SRV-12（9 级联脚本 pass=3 fail=6）为同族连带（被复跑脚本中有 6 个在本 FAIL 名单内）。置信度 HIGH（模式计数+未触碰 diff+失败消息自述「级联漏改」三重一致）。

## 证据原文摘录（防幻觉）
- 运行入口与命令: `bash /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans/skills/task-planner/scripts/run-selftests.sh --fresh`（日志 /tmp/v170-s11-fresh.log；单跑输出目录 /tmp/v170-s11-individual/）
- 运行器汇总: `Total: 78 PASS=63 FAIL=15 (run=78 reused=0)`；`EXIT=1`
- DCS-19: `DCS-19 PASS SKILL.md 行数<=584+61.4 清零+61.5 check-drift.sh`（与 DCS-11 FAIL 同文件共存）
- smoke（辅助）: `[smoke] summary: 17 pass / 0 fail` rc=0
- 零写入: worktree `git status --short` 输出为空；未执行任何 git 写操作；未在 plans/ 真实数据执行命令
- 全部 FAIL 脚本单跑复现 rc=1（/tmp/v170-s11-individual/rc.txt 15 行全 rc=1）

## 负结果与边界
- 未发现: 除 epoch 族外无其他类型 FAIL（SM-断言/SRV-12 连带外零散落）；无脚本崩溃/超时（无 timeout 触发）；无 [TRUNCATED]
- 排除: 非 15 名单脚本 100% rc=0；两个 0/0 显示项经单跑核实为输出格式口径（12 断言全 PASS / 7 断言 ALL PASS），非沉默失败
- 未验证项: tests/smoke.sh 按计划 S11 说法为「套件入口」但实为安装 smoke（与 selftest-*.sh 不同面），已另行单跑留证；不改动、不评判其归属
- 本 checkpoint 是本次唯一写操作（§8 指定产出）；其余全程只读

## 最终结论（T5，=§7 同块）
status: done
acceptance: 4/4 pass
files: none
evidence: `run-selftests.sh --fresh` → `Total: 78 PASS=63 FAIL=15 (run=78 reused=0)` EXIT=1（逐脚本 78 行表+16 条 FAIL 断言原文见上）；基线 9 项全确认 PASS（archive-plan 16/16、kb 16/16、es 19/19、skill-collab 25/25、research-first 12/12、SR 13/13、RI 16/16、BP-08、DCS-19）；base 快照 9 组模式计数 base 命中→当前 0（或 3→2），证 15 脚本 FAIL 为 epoch 1-76→1-81 级联未执行完引入；worktree git status 空（零写入）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v070-archive-completed-plans/subagent-state/020-code-runner-s11.md (status: done)
findings_written: none
blockers: 无 S11 单元阻塞；任务级 VC-5（FAIL=0）未达成——15 脚本 16 断言 FAIL（epoch 级联族，只记录未修）
confidence: HIGH
