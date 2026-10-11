# 1-code-runner 检查点 — master 全量 selftest 基线（task-v154 前置）

> 任务：/mnt/data/dev/task-planner-skill（master 主仓）只读执行全量 selftest-*.sh 回归，记录基线供 task-v154 decision-arbiter 改动后对照。
> 执行方式：逐个 `timeout -k 5 120 bash <脚本绝对路径>`，cwd=仓库根，无参数（全部脚本 BASH_SOURCE 自定位，无 CLI 参数解析）。
> 只读约束：不修改仓库任何文件；仅本检查点 + /tmp 下输出日志。

## 执行时间
- 开始：2026-10-10 约 01:38（+0800）
- 结束：2026-10-10 02:13（+0800）
- 模式：逐个 `timeout -k 5 120 bash <脚本绝对路径>`，cwd=/mnt/data/dev/task-planner-skill，无参数（64 脚本全部 BASH_SOURCE 自定位，无 CLI 参数解析/--help）

## 脚本总数
- 枚举 64 个（`ls skills/task-planner/scripts/selftest-*.sh`，与预期一致）

## 逐脚本结果表
| # | 脚本 | 结果 | PASS | FAIL | exit | 耗时ms |
|---|------|------|------|------|------|--------|
| 1 | selftest-active-plan.sh | PASS | 29 | 0 | 0 | 6727 |
| 2 | selftest-agent-coverage.sh | PASS | 9 | 0 | 0 | 277 |
| 3 | selftest-ask-default-timeout.sh | PASS | 11 | 0 | 0 | 168 |
| 4 | selftest-batch-pilot.sh | PASS | 10 | 0 | 0 | 223 |
| 5 | selftest-capability-persistence.sh | PASS | 20 | 0 | 0 | 1229 |
| 6 | selftest-check-conflicts.sh | PASS | 7 | 0 | 0 | 1470 |
| 7 | selftest-check-drift.sh | PASS | 6 | 0 | 0 | 2376 |
| 8 | selftest-conclusion-discipline.sh | PASS | 24 | 0 | 0 | 175 |
| 9 | selftest-context-hygiene.sh | PASS | 12 | 0 | 0 | 1003 |
| 10 | selftest-delegation.sh | PASS | 38 | 0 | 0 | 4472 |
| 11 | selftest-dispatch-grain.sh | PASS | 10 | 0 | 0 | 1857 |
| 12 | selftest-dispatch.sh | PASS | 31 | 0 | 0 | 7610 |
| 13 | selftest-drift-check-subagent.sh | PASS | 20 | 0 | 0 | 275 |
| 14 | selftest-drift-enforcement.sh | PASS | 23 | 0 | 0 | 15466 |
| 15 | selftest-error-loop.sh | PASS | 16 | 0 | 0 | 245 |
| 16 | selftest-evidence-goal-gate.sh | PASS | 21 | 0 | 0 | 310 |
| 17 | selftest-execution-honesty.sh | PASS | 14 | 0 | 0 | 182 |
| 18 | selftest-execution-stability.sh | PASS | 19 | 0 | 0 | 2567 |
| 19 | selftest-fallback.sh | PASS | 31 | 0 | 0 | 2182 |
| 20 | selftest-final-gate-hash.sh | PASS | 22 | 0 | 0 | 19072 |
| 21 | selftest-fine-grain-steps.sh | PASS | 11 | 0 | 0 | 2819 |
| 22 | selftest-four-file-dataflow.sh | PASS | 18 | 0 | 0 | 282 |
| 23 | selftest-goal-unit-goal-mode.sh | PASS | 9 | 0 | 0 | 262 |
| 24 | selftest-interaction.sh | PASS | 11 | 0 | 0 | 492 |
| 25 | selftest-iteration-persistence.sh | PASS | 18 | 0 | 0 | 208 |
| 26 | selftest-iterative-optimizer.sh | PASS | 8 | 0 | 0 | 152 |
| 27 | selftest-knowledge-brief.sh | PASS | 16 | 0 | 0 | 290 |
| 28 | selftest-lane-advancement.sh | PASS | 14 | 0 | 0 | 107 |
| 29 | selftest-mechanism-profile.sh | PASS | 19 | 0 | 0 | 5129 |
| 30 | selftest-media-agents.sh | PASS | 10 | 0 | 0 | 201 |
| 31 | selftest-media-dispatch.sh | PASS | 9 | 0 | 0 | 119 |
| 32 | selftest-methodology.sh | PASS | 16 | 0 | 0 | 1189 |
| 33 | selftest-periodic-review.sh | PASS | 10 | 0 | 0 | 84 |
| 34 | selftest-plan-dispatch.sh | PASS | 12 | 0 | 0 | 3304 |
| 35 | selftest-plan-tier.sh | PASS | 32 | 0 | 0 | 13725 |
| 36 | selftest-reflect-verify.sh | PASS | 12 | 0 | 0 | 164 |
| 37 | selftest-registry.sh | PASS | 5 | 0 | 0 | 105 |
| 38 | selftest-reliability-institution.sh | PASS | 16 | 0 | 0 | 168 |
| 39 | selftest-requirement-coverage.sh | PASS | 23 | 0 | 0 | 15227 |
| 40 | selftest-requirement-grading.sh | PASS | 7 | 0 | 0 | 130 |
| 41 | selftest-rescue-chain.sh | PASS | 11 | 0 | 0 | 984 |
| 42 | selftest-research-first.sh | PASS | 12 | 0 | 0 | 244 |
| 43 | selftest-review-library.sh | PASS | 15 | 0 | 0 | 875 |
| 44 | selftest-root-resolution.sh | PASS | 17 | 0 | 0 | 258 |
| 45 | selftest-rule23-conflict-scan.sh | PASS | 3 | 0 | 0 | 1213 |
| 46 | selftest-rule-reserve.sh | PASS | 10 | 0 | 0 | 757 |
| 47 | selftest-self-resolution.sh | PASS | 13 | 0 | 0 | 268 |
| 48 | selftest-shared-tracker.sh | PASS | 11 | 0 | 0 | 239 |
| 49 | selftest-skill-collab.sh | PASS | 25 | 0 | 0 | 352 |
| 50 | selftest-skill-modify.sh | PASS | 9 | 0 | 0 | 197 |
| 51 | selftest-skill-split.sh | PASS | 41 | 0 | 0 | 320 |
| 52 | selftest-smart-merge.sh | PASS | 17 | 0 | 0 | 9118 |
| 53 | selftest-split-pattern-library.sh | PASS | 13 | 0 | 0 | 138 |
| 54 | selftest-subagent-granularity-skill-escort.sh | PASS | 23 | 0 | 0 | 243 |
| 55 | selftest-sync-index.sh | PASS | 13 | 0 | 0 | 402 |
| 56 | selftest-task-boundary.sh | PASS | 11 | 0 | 0 | 167 |
| 57 | selftest-template-lifecycle.sh | PASS | 24 | 0 | 0 | 392 |
| 58 | selftest-template-sense.sh | PASS | 8 | 0 | 0 | 4956 |
| 59 | selftest-tier-b.sh | PASS | 18 | 0 | 0 | 2352 |
| 60 | selftest-tool-selection.sh | PASS | 12 | 0 | 0 | 390 |
| 批次1-2小计 | 20 脚本 | 全 PASS | 373 | 0 | - | - |
| 批次3小计 | 10 脚本 | 全 PASS | 134 | 0 | - | - |
| 批次4小计 | 10 脚本 | 全 PASS | 142 | 0 | - | - |
| 批次5小计 | 10 脚本 | 全 PASS | 126 | 0 | - | - |
| 批次6小计 | 10 脚本 | 全 PASS | 180 | 0 | - | - |
| 61 | selftest-user-instruction-priority.sh | PASS | 7（✓格式，无汇总行） | 0 | 0 | 81 |
| 62 | selftest-vc-gate.sh | PASS | 11 | 0 | 0 | 18469 |
| 63 | selftest-veto.sh | PASS | 13 | 0 | 0 | 252 |
| 64 | selftest-workflow-orchestration.sh | PASS | 16 | 0 | 0 | 243 |
| 批次7小计 | 4 脚本 | 全 PASS | 47 | 0 | - | - |
| **合计** | **64 脚本** | **全 PASS（rc 全 0）** | **1002** | **0** | - | **154953** |

## ΣPASS / ΣFAIL
- 脚本总数 = **64**（64/64 rc=0，全部 PASS）
- **ΣPASS = 1002**（63 脚本以汇总行计 + user-instruction-priority 按 7 条 ✓ 断言计）
- **ΣFAIL = 0**
- 总耗时 Σduration ≈ 154,953 ms（约 2.6 分钟）；单脚本最长 19,072 ms（final-gate-hash）

## FAIL 清单与摘要
- 无。64/64 脚本 rc=0，无任何失败断言，无失败脚本。

## timeout 清单
- 无。64 个脚本均在 120s 上限内完成（最长 19,072 ms，离上限余量 >100s）。

## 负结果报告 / 备注
- **未发现项（预期问题但未发现）**：全量 64 脚本零 FAIL、零 timeout、零真实 SKIP 断言（8 个日志中的 "SKIP" 字样均为断言语义描述或 SKIP=0/SKIPPED=0 计数器）。
- **解析口径与复核**：
  - 63 个脚本带汇总行（`Total: N PASS=N FAIL=N` 等），行级断言计数与汇总行完全一致（对账 0 mismatch）。
  - selftest-user-instruction-priority.sh 无汇总行，格式为 ✓ 勾选（56.1-56.5 + SKILL 联动锚 + 零新键声明 = 7 断言），以 7 计入 ΣPASS。
  - 复核陷阱：粗扫 `FAIL=[1-9]` 出现 1 例伪匹配（selftest-iteration-persistence.sh 断言描述文本 "PASS-FAIL=3" 子串），非实际失败；修正后 ΣFAIL=0。
  - 可重现性抽样复跑 3 脚本与首轮完全一致：registry=5 / user-instruction-priority=7✓ / delegation=38。
- **慢脚本 Top5**（后续回归对照用）：final-gate-hash 19,072ms / vc-gate 18,469ms / drift-enforcement 15,466ms / requirement-coverage 15,227ms / plan-tier 13,725ms。
- **环境事实**：node v22.22.0 / bun / python3 / jq 1.7 均在位（部分脚本依赖 node 与 jq）。
- **只读合规与并发说明**：
  - 本代理未修改仓库任何受控文件；唯一写入 = 本检查点文件；全部 64 份脚本输出日志存放于 /tmp/selftest-baseline/（仓库外，可复查）。
  - 执行窗口内仓库存在**并发会话写入**（非本代理所为）：plans/INDEX.md 于 01:44:39 被 sync-todos.sh --index 刷新（mtime + 头部 refreshed 时间戳佐证）、plans/task-v155-report-approvability/ 于 02:05:57 创建、plans/.rule-reservations.jsonl mtime 01:30:05。
  - selftest-sync-index.sh 已确认 hermetic（`TMP="$(mktemp -d)"` + `call() { bash "$SYNC" --index "$1" ... }` 传夹具目录，头部声明"不触真实 plans/"，日志仅 T01-T13 PASS），对真实 plans/INDEX.md 的改动不归因于本次执行。
- **证据位置**：逐脚本输出日志全量 = /tmp/selftest-baseline/<脚本名>.log（64 个）；本检查点摘要引用自这些日志。
