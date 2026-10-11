# task-v136 — selftest 全量基线跑批检查点（单元 02）

- 执行时间：2026-10-05 20:28:30 CST
- 跑批对象：`/home/terry/task-planner-skill-worktrees/task-v136/skills/task-planner/scripts/` 下全部 `selftest-*.sh`
- 执行方式：主进程逐脚本 `bash <script>` 实跑，单脚本 `timeout 90`，无跳过
- 数据来源：每脚本输出内的汇总行原文逐行解析累加（非估算、非引用历史数字）

## 一、汇总（头部结论）

| 指标 | 数值 |
|---|---|
| 脚本总数 | **51** |
| 脚本 PASS（退出码 0 且自身 FAIL=0） | **51** |
| 脚本 FAIL / TIMEOUT | **0** |
| 断言总数（passed + failed） | **762** |
| 断言 passed 合计 | **762** |
| 断言 failed 合计 | **0** |
| 断言 SKIPPED 合计 | **0**（仅 agent-coverage / skill-modify 两脚本输出含 SKIP 字段，均为 SKIP=0） |

> **基线数：762 断言全通过 / 0 失败，51 个脚本零 FAIL、零 TIMEOUT。**

## 二、FAIL / TIMEOUT 清单

无。全部 51 个脚本退出码均为 0，各自汇总行 FAIL 均为 0。

## 三、逐脚本结果（脚本 | 退出码 | 状态 | Total 行原文）

| # | 脚本 | 退出码 | 状态 | 汇总行原文 |
|---|---|---|---|---|
| 1 | selftest-active-plan.sh | 0 | PASS | `Total: 19 PASS=19 FAIL=0` |
| 2 | selftest-agent-coverage.sh | 0 | PASS | `Total: 9 PASS=9 FAIL=0 SKIPPED=0` |
| 3 | selftest-ask-default-timeout.sh | 0 | PASS | `Total: 11 PASS=11 FAIL=0` |
| 4 | selftest-batch-pilot.sh | 0 | PASS | `Total: 10 PASS=10 FAIL=0` |
| 5 | selftest-check-conflicts.sh | 0 | PASS | `Total: 7 PASS=7 FAIL=0` |
| 6 | selftest-check-drift.sh | 0 | PASS | `Total: 6 PASS=6 FAIL=0` |
| 7 | selftest-conclusion-discipline.sh | 0 | PASS | `Total: 24 PASS=24 FAIL=0` |
| 8 | selftest-context-hygiene.sh | 0 | PASS | `Total: 12 PASS=12 FAIL=0` |
| 9 | selftest-delegation.sh | 0 | PASS | `Total: 38    PASS=38  FAIL=0` |
| 10 | selftest-dispatch-grain.sh | 0 | PASS | `Total: 10 PASS=10 FAIL=0` |
| 11 | selftest-dispatch.sh | 0 | PASS | `Total: 31 PASS=31 FAIL=0` |
| 12 | selftest-error-loop.sh | 0 | PASS | `Total: 16 PASS=16 FAIL=0` |
| 13 | selftest-execution-stability.sh | 0 | PASS | `Total: 19  PASS=19  FAIL=0` |
| 14 | selftest-fallback.sh | 0 | PASS | `Total: 31  PASS=31  FAIL=0` |
| 15 | selftest-final-gate-hash.sh | 0 | PASS(非标准汇总行) | `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====` |
| 16 | selftest-fine-grain-steps.sh | 0 | PASS | `Total: 11 PASS=11 FAIL=0` |
| 17 | selftest-interaction.sh | 0 | PASS | `Total: 11 PASS=11 FAIL=0` |
| 18 | selftest-iterative-optimizer.sh | 0 | PASS | `Total: 8 PASS=8 FAIL=0` |
| 19 | selftest-knowledge-brief.sh | 0 | PASS | `Total: 16  PASS=16  FAIL=0` |
| 20 | selftest-lane-advancement.sh | 0 | PASS | `Total: 14 PASS=14 FAIL=0` |
| 21 | selftest-mechanism-profile.sh | 0 | PASS | `Total: 19 PASS=19 FAIL=0` |
| 22 | selftest-media-agents.sh | 0 | PASS | `Total: 10 PASS=10 FAIL=0` |
| 23 | selftest-media-dispatch.sh | 0 | PASS | `Total: 9 PASS=9 FAIL=0` |
| 24 | selftest-methodology.sh | 0 | PASS | `Total: 16 PASS=16 FAIL=0` |
| 25 | selftest-plan-dispatch.sh | 0 | PASS | `Total: 12 PASS=12 FAIL=0` |
| 26 | selftest-plan-tier.sh | 0 | PASS | `Total: 32 PASS=32 FAIL=0` |
| 27 | selftest-reflect-verify.sh | 0 | PASS | `Total: 12 PASS=12 FAIL=0` |
| 28 | selftest-registry.sh | 0 | PASS | `Total: 5 PASS=5 FAIL=0 (registry rows=51, actual selftest=51)` |
| 29 | selftest-reliability-institution.sh | 0 | PASS | `Total: 16 PASS=16 FAIL=0` |
| 30 | selftest-requirement-coverage.sh | 0 | PASS | `Total: 23 PASS=23 FAIL=0` |
| 31 | selftest-requirement-grading.sh | 0 | PASS | `Total: 7 PASS=7 FAIL=0` |
| 32 | selftest-rescue-chain.sh | 0 | PASS | `Total: 11 PASS=11 FAIL=0` |
| 33 | selftest-review-library.sh | 0 | PASS | `Total: 15 PASS=15 FAIL=0` |
| 34 | selftest-root-resolution.sh | 0 | PASS | `Total: 17 PASS=17 FAIL=0` |
| 35 | selftest-rule23-conflict-scan.sh | 0 | PASS | `Total: 3 PASS=3 FAIL=0` |
| 36 | selftest-rule-reserve.sh | 0 | PASS | `Total: 10 PASS=10 FAIL=0` |
| 37 | selftest-self-resolution.sh | 0 | PASS | `Total: 13 PASS=13 FAIL=0` |
| 38 | selftest-shared-tracker.sh | 0 | PASS | `Total: 11 PASS=11 FAIL=0` |
| 39 | selftest-skill-collab.sh | 0 | PASS | `Total: 25  PASS=25  FAIL=0` |
| 40 | selftest-skill-modify.sh | 0 | PASS | `Total: 9 PASS=9 FAIL=0 (SKIP=0)` |
| 41 | selftest-skill-split.sh | 0 | PASS | `Total: 41  PASS=41  FAIL=0` |
| 42 | selftest-smart-merge.sh | 0 | PASS | `Total: 17 PASS=17 FAIL=0` |
| 43 | selftest-sync-index.sh | 0 | PASS | `Total: 13 PASS=13 FAIL=0` |
| 44 | selftest-task-boundary.sh | 0 | PASS | `Total: 11 PASS=11 FAIL=0` |
| 45 | selftest-template-lifecycle.sh | 0 | PASS | `Total: 24 PASS=24 FAIL=0` |
| 46 | selftest-template-sense.sh | 0 | PASS | `Total: 8 PASS=8 FAIL=0` |
| 47 | selftest-tier-b.sh | 0 | PASS | `Total: 18 PASS=18 FAIL=0` |
| 48 | selftest-tool-selection.sh | 0 | PASS | `Total: 12 PASS=12 FAIL=0` |
| 49 | selftest-vc-gate.sh | 0 | PASS | `Total: 11 PASS=11 FAIL=0` |
| 50 | selftest-veto.sh | 0 | PASS | `Total: 13 PASS=13 FAIL=0` |
| 51 | selftest-workflow-orchestration.sh | 0 | PASS | `Total: 16 PASS=16 FAIL=0` |

## 四、格式异常说明

`selftest-final-gate-hash.sh` 的汇总行不是 `Total: N PASS=N FAIL=N` 格式，而是自定义格式，
本次已按其原文纳入累加（该脚本 PASS=22、FAIL=0、退出码 0，判定为 PASS）：

```
==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====
```

## 五、校验

- 逐脚本一致性校验：每个含 `Total:` 的脚本均满足 `Total == PASS + FAIL`，无一处不一致。
- 汇总行形态归一：50 个脚本用 `Total:` 前缀（含 5 个多空格变体、4 个带尾注变体），1 个用 `结果:` 前缀，已全部识别无遗漏。

## 六、只读性核验（run window 20:24:32 - 20:26:16）

以原始输出 mtime 反推跑批窗口，在该窗口内对两个仓做 `find -newermt` 扫描 + `git status`/`git diff` 内容级比对：

| 路径 | 窗口内是否被触碰 | 内容是否改变 | 归因 |
|---|---|---|---|
| worktree `skills/task-planner/config.json` | 是（mtime 20:24:38） | **否**，`git diff` 空、`git status` 干净，内容与 HEAD 逐字节一致 | `selftest-final-gate-hash.sh` 按设计先 `cp` 备份、末尾 `cp` 回原位（第 68/243/251 行），仅残留 mtime 变动 |
| `plans/task-v137/subagent-state/8-executor-fix.md` | 是 | 属 task-v137 | 并行会话产物，非本单元写入 |

- worktree 全程 `git status --short` 为空、`git diff` 为空 → 未修改任何仓库文件内容。
- 本单元唯一写入文件即本检查点；其余中间产物（runner、results.tsv、51 份原始输出）均在 `/tmp`。
- 说明：`config.json` 的 mtime 变动是 selftest 自身既有的备份/还原机制所致，非本单元引入的变更；
  若后续单元对 mtime 敏感探针有顾虑，可知该文件内容状态未受跑批影响。

## 五、主进程复核修正（2026-10-05 20:3x，Rule 22.5/43.1）
- 复核方式：主进程对 /tmp/selftest_v136_raw/ 全部 51 份原始输出独立 grep -oE "(PASS|passed)=[0-9]+" 逐文件求和；每文件恰 1 行汇总（final-gate-hash 为非标准 `PASS=22 FAIL=0`），匹配总数=51
- **修正后基线定数：passed 合计 = 784（原头部 762 漏加 final-gate-hash 的 22，该行声称纳入但未计入）**；failed 合计 = 0（两法一致）
- 后续 Phase 5 回归对比以 784/0 为基线（S-unit S5 验收锚同步以此为准）
