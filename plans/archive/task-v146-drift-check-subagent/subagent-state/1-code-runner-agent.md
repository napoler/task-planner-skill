# 1-code-runner-agent 检查点 — task-v146 全量 selftest 基线回归

- status: **FINAL**（全部 57 脚本已执行完；提取完成；独立复算、rc 抽查、worktree 清洁度检查通过）
- 工作副本: /mnt/data/dev/task-planner-skill-worktrees/task-v146 (branch wt/task-v146, HEAD da1f308)
- 脚本目录: /mnt/data/dev/task-planner-skill-worktrees/task-v146/skills/task-planner/scripts
- 执行方式: 4 批 x 每组<=15，`timeout 90 bash <script>`，原始输出完整捕获于: /tmp/tp146_out_00.txt, /tmp/tp146_out_01.txt, /tmp/tp146_out_02.txt, /tmp/tp146_out_03.txt
- 当前正执行脚本: 无（执行阶段已完成）
- 首次(PARTIAL)落盘时间: 2026-10-07T18:45:22Z（FINAL 落盘时间见 ④）

## ① 逐脚本 Total 行清单（脚本名 → PASS/FAIL，原文行）

| # | 脚本 | PASS | FAIL | Total/结果行原文 |
|---|------|------|------|------------------|
| 1 | selftest-active-plan.sh | 29 | 0 | `Total: 29 PASS=29 FAIL=0` |
| 2 | selftest-agent-coverage.sh | 8 | 1 | `Total: 9 PASS=8 FAIL=1 SKIPPED=0` |
| 3 | selftest-ask-default-timeout.sh | 10 | 1 | `Total: 11 PASS=10 FAIL=1` |
| 4 | selftest-batch-pilot.sh | 10 | 0 | `Total: 10 PASS=10 FAIL=0` |
| 5 | selftest-capability-persistence.sh | 19 | 1 | `Total: 20 PASS=19 FAIL=1` |
| 6 | selftest-check-conflicts.sh | 7 | 0 | `Total: 7 PASS=7 FAIL=0` |
| 7 | selftest-check-drift.sh | 6 | 0 | `Total: 6 PASS=6 FAIL=0` |
| 8 | selftest-conclusion-discipline.sh | 24 | 0 | `Total: 24 PASS=24 FAIL=0` |
| 9 | selftest-context-hygiene.sh | 12 | 0 | `Total: 12 PASS=12 FAIL=0` |
| 10 | selftest-delegation.sh | 38 | 0 | `Total: 38    PASS=38  FAIL=0` |
| 11 | selftest-dispatch-grain.sh | 10 | 0 | `Total: 10 PASS=10 FAIL=0` |
| 12 | selftest-dispatch.sh | 31 | 0 | `Total: 31 PASS=31 FAIL=0` |
| 13 | selftest-error-loop.sh | 16 | 0 | `Total: 16 PASS=16 FAIL=0` |
| 14 | selftest-evidence-goal-gate.sh | 21 | 0 | `Total: 21 PASS=21 FAIL=0` |
| 15 | selftest-execution-honesty.sh | 14 | 0 | `Total: 14 PASS=14 FAIL=0` |
| 16 | selftest-execution-stability.sh | 19 | 0 | `Total: 19  PASS=19  FAIL=0` |
| 17 | selftest-fallback.sh | 31 | 0 | `Total: 31  PASS=31  FAIL=0` |
| 18 | selftest-final-gate-hash.sh | 22 | 0 | `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====` |
| 19 | selftest-fine-grain-steps.sh | 11 | 0 | `Total: 11 PASS=11 FAIL=0` |
| 20 | selftest-interaction.sh | 11 | 0 | `Total: 11 PASS=11 FAIL=0` |
| 21 | selftest-iteration-persistence.sh | 17 | 1 | `Total: 18 PASS=17 FAIL=1` |
| 22 | selftest-iterative-optimizer.sh | 8 | 0 | `Total: 8 PASS=8 FAIL=0` |
| 23 | selftest-knowledge-brief.sh | 16 | 0 | `Total: 16  PASS=16  FAIL=0` |
| 24 | selftest-lane-advancement.sh | 13 | 1 | `Total: 14 PASS=13 FAIL=1` |
| 25 | selftest-mechanism-profile.sh | 19 | 0 | `Total: 19 PASS=19 FAIL=0` |
| 26 | selftest-media-agents.sh | 9 | 1 | `Total: 10 PASS=9 FAIL=1` |
| 27 | selftest-media-dispatch.sh | 8 | 1 | `Total: 9 PASS=8 FAIL=1` |
| 28 | selftest-methodology.sh | 16 | 0 | `Total: 16 PASS=16 FAIL=0` |
| 29 | selftest-periodic-review.sh | 5 | 5 | `Total: 10 PASS=5 FAIL=5` |
| 30 | selftest-plan-dispatch.sh | 12 | 0 | `Total: 12 PASS=12 FAIL=0` |
| 31 | selftest-plan-tier.sh | 32 | 0 | `Total: 32 PASS=32 FAIL=0` |
| 32 | selftest-reflect-verify.sh | 12 | 0 | `Total: 12 PASS=12 FAIL=0` |
| 33 | selftest-registry.sh | 4 | 1 | `Total: 5 PASS=4 FAIL=1 (registry rows=56, actual selftest=57)` |
| 34 | selftest-reliability-institution.sh | 15 | 1 | `Total: 16 PASS=15 FAIL=1` |
| 35 | selftest-requirement-coverage.sh | 21 | 2 | `Total: 23 PASS=21 FAIL=2` |
| 36 | selftest-requirement-grading.sh | 6 | 1 | `Total: 7 PASS=6 FAIL=1` |
| 37 | selftest-rescue-chain.sh | 11 | 0 | `Total: 11 PASS=11 FAIL=0` |
| 38 | selftest-review-library.sh | 15 | 0 | `Total: 15 PASS=15 FAIL=0` |
| 39 | selftest-root-resolution.sh | 17 | 0 | `Total: 17 PASS=17 FAIL=0` |
| 40 | selftest-rule23-conflict-scan.sh | 3 | 0 | `Total: 3 PASS=3 FAIL=0` |
| 41 | selftest-rule-reserve.sh | 10 | 0 | `Total: 10 PASS=10 FAIL=0` |
| 42 | selftest-self-resolution.sh | 11 | 2 | `Total: 13 PASS=11 FAIL=2` |
| 43 | selftest-shared-tracker.sh | 11 | 0 | `Total: 11 PASS=11 FAIL=0` |
| 44 | selftest-skill-collab.sh | 25 | 0 | `Total: 25  PASS=25  FAIL=0` |
| 45 | selftest-skill-modify.sh | 9 | 0 | `Total: 9 PASS=9 FAIL=0 (SKIP=0)` |
| 46 | selftest-skill-split.sh | 41 | 0 | `Total: 41  PASS=41  FAIL=0` |
| 47 | selftest-smart-merge.sh | 17 | 0 | `Total: 17 PASS=17 FAIL=0` |
| 48 | selftest-sync-index.sh | 13 | 0 | `Total: 13 PASS=13 FAIL=0` |
| 49 | selftest-task-boundary.sh | 11 | 0 | `Total: 11 PASS=11 FAIL=0` |
| 50 | selftest-template-lifecycle.sh | 24 | 0 | `Total: 24 PASS=24 FAIL=0` |
| 51 | selftest-template-sense.sh | 8 | 0 | `Total: 8 PASS=8 FAIL=0` |
| 52 | selftest-tier-b.sh | 18 | 0 | `Total: 18 PASS=18 FAIL=0` |
| 53 | selftest-tool-selection.sh | 11 | 1 | `Total: 12 PASS=11 FAIL=1` |
| 54 | selftest-user-instruction-priority.sh | 7 | 0 | `(no Total line; computed PASS=7 from check marks, concluded ALL PASS)` |
| 55 | selftest-vc-gate.sh | 11 | 0 | `Total: 11 PASS=11 FAIL=0` |
| 56 | selftest-veto.sh | 13 | 0 | `Total: 13 PASS=13 FAIL=0` |
| 57 | selftest-workflow-orchestration.sh | 15 | 1 | `Total: 16 PASS=15 FAIL=1` |

## ② 汇总行

- 脚本数: **57**
- ΣPASS: **863**
- ΣFAIL: **21**
- FAIL≠0 脚本数: **15**
- 无 Total 行脚本 2 个（等效提取，见清单）：selftest-final-gate-hash.sh（结果行 PASS=22 FAIL=0）、selftest-user-instruction-priority.sh（无计数行，7 个 check 标记 + ALL PASS，计算 PASS=7）

## ③ FAIL≠0 脚本与其 FAIL 断言原文（逐条；脚本标题后附其 Total/结果行）

### selftest-agent-coverage.sh — `Total: 9 PASS=8 FAIL=1 SKIPPED=0`
- `AC-07 FAIL config.json properties 键数=42（应 40，零新键承诺被破坏）`

### selftest-ask-default-timeout.sh — `Total: 11 PASS=10 FAIL=1`
- `RT-09 FAIL config.json properties 键数=42（应 40）`

### selftest-capability-persistence.sh — `Total: 20 PASS=19 FAIL=1`
- `CP-16 FAIL config.json properties 键数=42（应 40，零新键被破坏）`

### selftest-iteration-persistence.sh — `Total: 18 PASS=17 FAIL=1`
- `IP-15 FAIL config.json properties 键数=42（应 40，零新键被破坏）`

### selftest-lane-advancement.sh — `Total: 14 PASS=13 FAIL=1`
- `LA-14 FAIL config.json properties 键数=42（应 40，Rule 49 零新键被破坏）`

### selftest-media-agents.sh — `Total: 10 PASS=9 FAIL=1`
- `MA-10 FAIL config.json properties 键数=42（应 40，零新键承诺被破坏）`

### selftest-media-dispatch.sh — `Total: 9 PASS=8 FAIL=1`
- `MD-08 FAIL config.json properties 键数=42（应 40，Rule 47 零新键被破坏）`

### selftest-periodic-review.sh — `Total: 10 PASS=5 FAIL=5`
- `PR-03 FAIL Rule 57 前后对照检查维度缺失`
- `PR-04 FAIL Rule 57 自动纠正机制缺失`
- `PR-05 FAIL Rule 57 开关键缺失`
- `PR-09 FAIL selftest-registry.tsv 注册缺失`
- `PR-10 FAIL SKILL.md C39 引用缺失`

### selftest-registry.sh — `Total: 5 PASS=4 FAIL=1 (registry rows=56, actual selftest=57)`
- `T02 FAIL 未登记: selftest-periodic-review.sh`

### selftest-reliability-institution.sh — `Total: 16 PASS=15 FAIL=1`
- `R-12 FAIL config.json properties 键数=42（应 40）`

### selftest-requirement-coverage.sh — `Total: 23 PASS=21 FAIL=2`
- `RC-13 FAIL config.json properties 键数=42（应 40，Rule 51 零新键被破坏）`
- `RC-15 FAIL critical-rules.md '56.' 子条命中=5（应 =0，编号假设被破坏）`

### selftest-requirement-grading.sh — `Total: 7 PASS=6 FAIL=1`
- `RG-07 FAIL config.json properties 键数=42（应 40，Rule 50 零新键被破坏）`

### selftest-self-resolution.sh — `Total: 13 PASS=11 FAIL=2`
- `SR-09 FAIL config.json properties 键数=42（应 40）`
- `SR-12 FAIL registry 漂移（selftest-self-resolution 命中 1 应 ≥1 / 总行数 57 应 58=脚本数+表头）`

### selftest-tool-selection.sh — `Total: 12 PASS=11 FAIL=1`
- `TS-12 FAIL config.json properties 键数=42（应 40）`

### selftest-workflow-orchestration.sh — `Total: 16 PASS=15 FAIL=1`
- `WF-12 FAIL config.json properties 键数=42（应 40）`

## ④ 时间戳

- 执行起始(UTC): 2026-10-07T18:06:58Z（pre-check 前），4 批连续执行
- PARTIAL 落盘: 2026-10-07T18:45:22Z
- FINAL 落盘: 2026-10-07T18:58:30Z

## ⑤ Post-verify（独立复算与抽查）

- 独立复算（awk 法，与 python 解析互为独立）: Total 行 ΣPASS=834、ΣFAIL=21；加 2 个特殊格式脚本（final-gate-hash 结果行 PASS=22、user-instruction-priority 计算 PASS=7）→ ΣPASS=834+22+7=863、ΣFAIL=21，与 ② 完全一致；脚本数=57 一致。
- rc 抽查（重跑 4 个并捕获退出码）: selftest-registry.sh rc=1、selftest-periodic-review.sh rc=1、selftest-self-resolution.sh rc=1，三者 Total 行与主运行完全复现；对照组 selftest-active-plan.sh rc=0（PASS=29 FAIL=0）。
- 特殊格式核实: selftest-user-instruction-priority.sh 无 Total 计数行，内部恰 7 处 check() 调用（56.1-56.5 + SKILL 联动锚 + 零新键声明），FAIL=0 → 输出 ALL PASS 并 exit 0，计算 PASS=7 成立；selftest-final-gate-hash.sh 用 "结果: PASS=22 FAIL=0" 格式。
- 超时: 4 批原始输出中 [TIMEOUT] 标记计数=0（57/57 均在 90s 限内完成，实际秒级）。
- 捕获完整性: 逐脚本捕获 4~45 行（中位数 14），无 truncated/omitted 截断标记。
- worktree 清洁度: 测试后 `git status --porcelain` = 0 行 — 未在工作副本留下任何变更或未跟踪文件（测试全程只读效应）。
- caveat: 主运行（4 批）未逐脚本捕获 rc（按任务指定命令形态执行，以脚本自身 Total 行为准）；rc 仅抽查 4 个。

## ⑥ 负结果注记（含 FAIL 字样但非失败）

- 全 57 份原始输出中，除 Total/结果行外含字面 "FAIL" 的仅 2 行，且均为 PASS 行: selftest-iteration-persistence.sh 的 IP-08（描述文本含 "PASS-FAIL=2"）、selftest-rule-reserve.sh 的 RR-10（负向自检说明提及 "RR-03 同款判定 FAIL"）。两行均未计入任何 FAIL。
- 未发现: TIMEOUT、输出截断、脚本崩溃（无异常 stderr 噪声）；awk 独立复算排除了主解析误差。
- 已知与本任务无关: worktree 存在 1 条既有 stash（WIP on master: d806d05），非本次测试产物，未触碰。
