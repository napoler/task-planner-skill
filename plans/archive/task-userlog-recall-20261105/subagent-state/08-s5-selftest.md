# 08-s5-selftest — Rule 80.8 五决策点读取面 SL 断言扩展检查点

- 时间: 2026-11-05
- S-unit: S5
- worktree: `/mnt/data/dev/task-planner-skill-worktrees/task-userlog-recall-20261105`
- 目标文件: `skills/task-planner/scripts/selftest-session-log.sh`（仅此文件）

## 变更摘要
- 既有断言（SL-01..SL-12，`t()` 调用 16 处）**一行未改**（append-only）；仅将原末尾汇总/exit 块移至文件真正末尾（保持原语义，确保新增断言计入 Total）。
- 追加 `td()` 诊断断言包装器（失败时输出缺失文件/锚，便于定位）+ SL-13..SL-18 共 **12 个新断言点**（11 个 `td()` + 1 个 SL-18 内联计数断言），守护 Rule 80.8 五决策点读取面 8 文件锚 + 1 完整性负断言。

## 新增断言清单
| 断言 | 覆盖项 | 锚/文件 | 判定 |
|---|---|---|---|
| SL-13a | item 1 | `critical-rules.md` 含 `80.8 **决策前读取纪律` | PASS |
| SL-13b | item 2 | `critical-rules.md` 含 `双锚升级（task-userlog-recall-20261105，Rule 80.8③）`（51.3 双锚） | PASS |
| SL-14a | item 3 | `task-discipline/references/critical-rules-discipline.md` 含 `暂停前四问` | PASS |
| SL-14b | item 4 | 同文件含 `反思门**五问` | PASS |
| SL-14c | item 5 | 同文件含 `前置读档门` | PASS |
| SL-15a | item 6 | `task-planner/SKILL.md` 含 `决策前读取已过` | PASS |
| SL-15b | item 6 | `task-planner/SKILL.md` 含 `决策前读取纪律（80.8` | PASS |
| SL-16a | item 7 | `templates/user-session-log.md` 含 `## 消费点（读取触发点 — Rule 80.8 五决策点）` | PASS |
| SL-16b | item 8 | `templates/delivery-summary.md` 含 `专档条目#` | PASS |
| SL-16c | item 9 | `templates/subagent_dispatch.md` 含 `双锚升级（Rule 80.8④）` | PASS |
| SL-17  | item 10 | `scripts/zcode-userpromptsubmit.sh` 含 `80.8` | PASS |
| SL-18  | item 11 | 完整性负断言：`critical-rules.md` 中 `^80.[1-8] ` 行首子条计数 = 8（80.1-80.8 全在，写入面未破坏）；与 SL-04(80.1-80.6=6) 并存 | PASS |

路径解析：沿用既有 `$SCRIPT_DIR`/`$ROOT` 推导；`task-discipline` 以 `$ROOT/../task-discipline/...`（同级兄弟）解析；无硬编码绝对路径。

## selftest 输出原文
```text
[PASS] SL-01 user-session-log.md 存在且三关键词(只写不改∧append-only∧逐字抄录)各≥1
[PASS] SL-02 user-session-log.md '## #' 条目示例行 ∧ '^## 恢复协议' 标题段
[PASS] SL-03 task_plan.md 指针区块('🗣️ 用户会话逐字记录'≥1 ∧ 'user-session-log'≥2)
[PASS] SL-04 critical-rules.md '^80.[1-6] ' = 6
[PASS] SL-05 SKILL.md 纪元锚 '1-(8x|9x|10x)' ≥3（覆盖 1-80..101 宽窗, 尾边界 79/110 负样本不命中）
[PASS] SL-06 check-complete.sh SESSION-LOG GATE('[session-log-gate]'∧TASK_PLANNER_SESSION_LOG_ENFORCE∧零新 config 键|env-only)
[PASS] SL-07 init-session.sh 'copy_template "user-session-log.md"'≥1 ∧ verify 回显语句=1
[PASS] SL-08 task_plan.md 指针区块无可变计数('当前条目数|最近一条'=0, 纯静态)
[PASS] SL-09 config.json properties 键数 = 53（零新 config 键, jq; task-perf-opt 42→44, task-v172 合法新增 2 键 44→46, P-01 1 键 46→47, [task-v184-S2b] 47→53）
[PASS] SL-10 registry 自登记('selftest-session-log.sh'=1 行 ∧ 该行 NF=4 且四列非空)
[PASS] SL-11a 基线空锚（- 0）+ append 首条 enforce 档 PASS（无 baseline-drift, task-v176 CR MAJOR-2 豁免）
[PASS] SL-11b 回退校验保留（基线条目数 2→现存 1 = FAIL；基线=现存 1 = PASS, 篡改面不放开）
[PASS] SL-12 二次 init 不改写既有条目（user-session-log sha 不变 ∧ 假条目/Goal 手改保留 ∧ rc=0, Rule 80.2）
[PASS] SL-13a critical-rules.md 含 '80.8 **决策前读取纪律' (80.8 header)
[PASS] SL-13b critical-rules.md 含 51.3 双锚升级字面 (task-userlog-recall-20261105, Rule 80.8③)
[PASS] SL-14a task-discipline 含 '暂停前四问' (Rule 80.8① 上抛裁决前读档)
[PASS] SL-14b task-discipline 含 '反思门**五问' (Rule 80.8② 新指令反思)
[PASS] SL-14c task-discipline 含 '前置读档门' (Rule 80.8① 86.1 前置)
[PASS] SL-15a SKILL.md 含 '决策前读取已过' (G9 自查项)
[PASS] SL-15b SKILL.md 含 '决策前读取纪律（80.8' (Rule 80 索引接线)
[PASS] SL-16a user-session-log.md 模板含消费点区块 (Rule 80.8 五决策点)
[PASS] SL-16b delivery-summary.md 含 '专档条目#' 列 (51.3 双锚交付面)
[PASS] SL-16c subagent_dispatch.md 含 '双锚升级（Rule 80.8④）' (派发需求锚双锚)
[PASS] SL-17 zcode-userpromptsubmit.sh 含 '80.8' (反思提示/专档对照接线)
[PASS] SL-18 critical-rules.md '^80.[1-8] ' = 8 (80.1-80.8 完整性, 写入面未被破坏)
Total: 25  PASS=25  FAIL=0
---exit:0---
```

## diff --stat（仅目标文件）
```text
 skills/task-planner/scripts/selftest-session-log.sh | 81 ++++++++++++++++++++++
 1 file changed, 81 insertions(+)
```

## 既有断言计数对照
- 改前 `t()` 调用：16（SL-01..SL-12 覆盖，含 SL-11a/b/SL-12）
- 改后 `t()` 调用：16（不变，既有一行未改）+ `td()` 调用：11 + SL-18 内联：1
- 改后 Total：25 PASS / 0 FAIL（≥ 改前覆盖面，且既有断言全部仍通过）
