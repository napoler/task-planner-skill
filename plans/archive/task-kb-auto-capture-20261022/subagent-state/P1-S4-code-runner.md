# P1-S4 code-runner — task-planner 全量 selftest 批跑与失败归因

- 时间: 2026-10-22
- worktree: /home/terry/task-planner-skill-worktrees/task-kb-auto-capture-20261022 (HEAD 06ae3f5)
- 运行方式: 循环 `timeout 60 bash <script>`，worktree 根为 cwd，逐脚本记录 rc 与耗时
- 原始产物: /tmp/selftest-results/{all.txt,summary.txt,<script>.log}, runner=/tmp/run-selftests.sh

## 结果总览

| 指标 | 值 |
|------|----|
| 脚本总数 | 92 |
| PASS | 92 |
| FAIL | 0 |
| 超时 | 0 |
| 最长耗时 | 25s (selftest-vc-gate / selftest-final-gate-hash) |

`summary.txt` 原文: `TOTAL=92 PASS=92 FAIL=0`

## 6 个引用 templates/task_plan.md 的重点守卫（单独复跑）

| 守卫 | rc | 结果行 | 判定 | 模板锚点（脚本内） |
|------|----|--------|------|--------------------|
| selftest-ask-default-timeout | 0 | `Total: 11 PASS=11 FAIL=0` | PASS | RT-05 `grep -c '自动超时默认项'` ≥1（L29/L62-64） |
| selftest-conclusion-discipline | 0 | `Total: 24 PASS=24 FAIL=0` | PASS | CD-21 `grep -qF 'ID 列一律纯数字'`（L52/L116） |
| selftest-absorption-discipline | 0 | `Total: 16 pass, 0 fail, 1 skip` | PASS(含中性 skip) | AD-06 变更标注表六列+四类型串+三态串（L48） |
| selftest-decision-drift | 0 | `Total: 23 PASS=23 FAIL=0` | PASS | DD-12~13 🔒 三态区块（L22/L63） |
| selftest-goal-unit-goal-mode | 0 | `Total: 9 PASS=9 FAIL=0` | PASS | G-03 Goal 单元表区块=1 + 六列表头=1 + 行序 L裁决<Lgoal<L限制（L47/L67-80） |
| selftest-error-loop | 0 | `Total: 16 PASS=16 FAIL=0` | PASS | EL-14 Errors 表 `Prevention（Rule 31 指针）`（L94） |

## 失败归因

无 FAIL，A/B/C 三类归因均未触发（A=模板改动引入 0 例 / B=环境性 0 例 / C=HEAD 既有 0 例）。

## 中性 skip（不计 fail，需登记）

- AD-13 自举消费 SKIP，脚本原文: `AD-13 SKIP 自举消费 SKIPPED（候选均缺：env TASK_PLANNER_ABSORB_PLAN 未设 + 主仓根未解析 + repo 相对缺失；中性态不计 pass/fail）`
- 归因 B（环境性，且为 HEAD 既有设计的中性态）：worktree 内不存在 `plans/task-v162-change-absorption-safety/`（实测 `ls: cannot access ... No such file or directory`），该 plan 仅存在于主仓 plans 根。与本次 task_plan.md 插入无关。

## 零回归判定

PASS=92 / FAIL=0，与 HEAD 基线（前次计划记录「92 selftest 零回归」，commit 7eddc7c）一致 → **零回归成立**。

## 破坏性副作用核查

- `git status --short` 运行后仍仅两行预期变更:
  ` M skills/task-planner/templates/task_plan.md` / `?? .zcode/plan-templates/task_plan.md`
- 未修改任何仓库文件；所有临时产物写到 /tmp/selftest-results/。

## 负结果报告（检查了但未发现）

- 未发现任何 FAIL / 超时 / 非零退出码实例（92/92 rc=0）。
- 虽 `df -h /mnt/data` 显示 99% (avail 1.3G)，未出现 I/O 类失败；selftest 全部写 /tmp（根分区 20G avail）。
- 插入位置（Phase 5 收尾 "Deliver to user" 之后）不在 6 个守卫断言的模板锚点区间内，故未触发模板类断言；goal-unit-goal-mode 的行序断言只比较行号顺序（相对关系），插入点位于其后，不影响。
