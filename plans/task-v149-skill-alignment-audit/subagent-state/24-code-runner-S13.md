# task-v149 Phase 4 S13 — 全量 selftest 回归与基线 diff — 检查点 (24-code-runner-S13)

> 状态: RUNNING | 最后更新: 2026-10-09（批次 0 初始化）| 目标: 62/62 全量复跑

## ① 执行环境

- 日期: 2026-10-09
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v149-skill-alignment-audit
- 基点: aa06dde（`git log --oneline -1` 实测；Phase 3 三 commit a234369/fca4f40/aa06dde）
- 对照基线: 01-code-runner-agent.md（master 21f7e6b：62 脚本，exit=0×61，ΣPASS=969，ΣFAIL=4 全部来自 selftest-periodic-review）
- 命令模式: `for f in skills/task-planner/scripts/selftest-*.sh; do timeout 120 bash "$f" > /tmp/v149-regress-$(basename $f .sh).log 2>&1; echo "$(basename $f .sh) exit=$?"; done`
- 只读约束: 除本检查点与 /tmp 日志外不写任何文件

## ② 逐脚本结果（分批回填）

<!-- BATCH-RESULTS -->

## ③ FAIL 明细与基线 diff

（跑完后回填）

## ④ 汇总

（跑完后回填）

## 进度日志

- 2026-10-09: 批次 0 = 环境初始化（worktree 基点 aa06dde 确认；62 脚本清单与基线同序；初始检查点落盘）

### 批次 1（脚本 1-10，2026-10-09）

> 跑法修正注: 父令指定 `echo "$(basename $f .sh) exit=$?"` 存在 bash 陷阱——命令替换先执行并重置 `$?`，导致恒显 exit=0（已实证: `false; echo "$(basename foo .sh) exit=$?"` → `foo exit=0`）。本执行体改为 `rc=$?; echo ... true_exit=$rc` 并复跑批次 1 取得真实退出码。

| # | 脚本 | true exit | PASS | FAIL | 基线对照 |
|---|------|-----------|------|------|----------|
| 1 | selftest-active-plan | 0 | 29 | 0 | 一致（基线 29/0） |
| 2 | selftest-agent-coverage | 0 | 9 | 0 | 一致（9/0, SKIPPED=0） |
| 3 | selftest-ask-default-timeout | 0 | 11 | 0 | 一致 |
| 4 | selftest-batch-pilot | 0 | 10 | 0 | 一致 |
| 5 | selftest-capability-persistence | 0 | 20 | 0 | 一致 |
| 6 | selftest-check-conflicts | 0 | 7 | 0 | 一致 |
| 7 | selftest-check-drift | 0 | 6 | 0 | 一致 |
| 8 | selftest-conclusion-discipline | **1** | 23 | **1** | **新增 FAIL（基线 24/0）** |
| 9 | selftest-context-hygiene | 0 | 12 | 0 | 一致 |
| 10 | selftest-delegation | 0 | 38 | 0 | 一致 |

**新增 FAIL #1（待全量跑完定论）: selftest-conclusion-discipline — 打印行 CD-19「README.md 含 1-3[5-8] 宽容锚」**
- 断言实位: selftest-conclusion-discipline.sh:88 `grep -qE 'Rules 1-3[5-9]' "$README_SKILL"`（脚本打印序号因 CD-25 前置插入而错位，以断言消息文本为准）
- 根因取证（一手）: master:README.md:72=「Rules 1-39」（命中宽容窗口 [5-9]）→ worktree README.md:72=「Rules 1-65」（不命中）；`git diff master...HEAD -- skills/task-planner/README.md` 实证为 S9 文档批改动
- 守卫文件本分支未改（`git diff master...HEAD --stat` 该文件为空）→ 级联批次 S17-S22 覆盖 14 个脚本未含此脚本 = 级联遗漏
- 日志: /tmp/v149-regress-selftest-conclusion-discipline.log + retest 复现（Total: 24 PASS=23 FAIL=1, true_exit=1）

## ② 逐脚本结果（分批回填）

<!-- BATCH-RESULTS -->

### 批次 2（脚本 11-20，2026-10-09）

| # | 脚本 | true exit | PASS | FAIL | 基线对照 |
|---|------|-----------|------|------|----------|
| 11 | selftest-dispatch-grain | 0 | 10 | 0 | 一致 |
| 12 | selftest-dispatch | 0 | 31 | 0 | 一致 |
| 13 | selftest-drift-check-subagent | 0 | 20 | 0 | 一致（特别核对项①：DCS-11 级联后 PASS） |
| 14 | selftest-drift-enforcement | 0 | 23 | 0 | 一致 |
| 15 | selftest-error-loop | 0 | 16 | 0 | 一致 |
| 16 | selftest-evidence-goal-gate | 0 | 21 | 0 | 一致（S21 负断言演进后） |
| 17 | selftest-execution-honesty | 0 | 14 | 0 | 一致 |
| 18 | selftest-execution-stability | 0 | 19 | 0 | 一致 |
| 19 | selftest-fallback | 0 | 31 | 0 | 一致（stderr jq 空洞通过面待终审复核） |
| 20 | selftest-final-gate-hash | 0 | 22 | 0 | 一致 |

### 批次 3（脚本 21-30，2026-10-09）

| # | 脚本 | true exit | PASS | FAIL | 基线对照 |
|---|------|-----------|------|------|----------|
| 21 | selftest-fine-grain-steps | 0 | 11 | 0 | 一致 |
| 22 | selftest-four-file-dataflow | 0 | 18 | 0 | 一致（S21 负断言演进后） |
| 23 | selftest-interaction | 0 | 11 | 0 | 一致 |
| 24 | selftest-iteration-persistence | 0 | 18 | 0 | 一致（S22 演进后） |
| 25 | selftest-iterative-optimizer | 0 | 8 | 0 | 一致 |
| 26 | selftest-knowledge-brief | 0 | 16 | 0 | 一致 |
| 27 | selftest-lane-advancement | 0 | 14 | 0 | 一致（S17 演进后） |
| 28 | selftest-mechanism-profile | 0 | 19 | 0 | 一致 |
| 29 | selftest-media-agents | **1** | 9 | **1** | **新增 FAIL（基线 10/0）** |
| 30 | selftest-media-dispatch | 0 | 9 | 0 | 一致 |

**新增 FAIL #2: selftest-media-agents — MA-08「文档计数/表行漂移」**
- 断言实位: selftest-media-agents.sh:117-124——`a=grep -c '6 个伴生' README_zh.md` 且 `b=grep -c '6 个配套' INSTALL_zh.md` 各 ≥1（+INSTALL.md 双 agent 行 c/d≥1 仍过）
- 一手取证: 当前 README_zh.md:114=「7 个伴生 agent...」、INSTALL_zh.md:306=「7 个配套 agent: ...」→ a=0/b=0；master:README_zh.md:114=「6 个伴生」/INSTALL_zh.md:305=「6 个配套」→ 命中
- `git diff master...HEAD --stat -- README_zh.md INSTALL_zh.md` 实证两文档本分支已改（计数 6→7 对齐实态）；守卫文件未改 → 级联遗漏
- 影响面清点: 全 selftest 面 grep「个伴生|个配套」仅 media-agents 一处消费（无其他脚本受害，forecast 已验）
- 日志: /tmp/v149-regress-selftest-media-agents.log（Total: 10 PASS=9 FAIL=1）

### 批次 4（脚本 31-40，2026-10-09）

| # | 脚本 | true exit | PASS | FAIL | 基线对照 |
|---|------|-----------|------|------|----------|
| 31 | selftest-methodology | 0 | 16 | 0 | 一致 |
| 32 | selftest-periodic-review | **0** | **10** | **0** | **修复验证通过**（基线 6/4，PR-03/04/05/10 FAIL → 现全 PASS） |
| 33 | selftest-plan-dispatch | 0 | 12 | 0 | 一致（S8 行锚修正后） |
| 34 | selftest-plan-tier | 0 | 32 | 0 | 一致（特别核对项②：PASS） |
| 35 | selftest-reflect-verify | 0 | 12 | 0 | 一致 |
| 36 | selftest-registry | 0 | 5 | 0 | 一致（S20 行更新后） |
| 37 | selftest-reliability-institution | 0 | 16 | 0 | 一致（S8 行锚修正后） |
| 38 | selftest-requirement-coverage | 0 | 23 | 0 | 一致（S17 演进后） |
| 39 | selftest-requirement-grading | 0 | 7 | 0 | 一致 |
| 40 | selftest-rescue-chain | 0 | 11 | 0 | 一致 |

**修复验证证据（periodic-review 日志尾段）**:
```
PR-01 PASS Rule 65 条款存在 / PR-02 PASS 含触发时机 / PR-03 PASS 含前后对照检查维度
PR-04 PASS 含自动纠正机制 / PR-05 PASS 含开关键 / ... PR-10 PASS SKILL.md 有 C39 引用
Total: 10 PASS=10 FAIL=0
```

### 批次 5（脚本 41-50，2026-10-09）

| # | 脚本 | true exit | PASS | FAIL | 基线对照 |
|---|------|-----------|------|------|----------|
| 41 | selftest-research-first | 0 | 12 | 0 | 一致（S20 演进后） |
| 42 | selftest-review-library | 0 | 15 | 0 | 一致 |
| 43 | selftest-root-resolution | 0 | 17 | 0 | 一致 |
| 44 | selftest-rule23-conflict-scan | 0 | 3 | 0 | 一致 |
| 45 | selftest-rule-reserve | 0 | 10 | 0 | 一致 |
| 46 | selftest-self-resolution | 0 | 13 | 0 | 一致（S18 演进后） |
| 47 | selftest-shared-tracker | 0 | 11 | 0 | 一致 |
| 48 | selftest-skill-collab | 0 | 25 | 0 | 一致 |
| 49 | selftest-skill-modify | 0 | 9 | 0 | 一致 |
| 50 | selftest-skill-split | 0 | 41 | 0 | 一致（S23 行数上限 500→510 后） |
