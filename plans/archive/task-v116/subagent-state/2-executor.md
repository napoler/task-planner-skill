# subagent-state/2-executor — task-v116 Phase 2 终验（回归+对齐审查）

- agent_type: executor
- session: 2026-10-02 全新独立会话
- merge 对象: eb6aea8（Merge branch 'wt/task-v116'，内容=85ab33b Phase 1b 根目录文档刷新 + fe7c12e Phase 1a skills 面 R 项修复）

## 1. 全量回归（42 selftest）

42 脚本全运行，单脚本 timeout 90s 包裹，实测总耗时 <3 分钟。

### 结果原文（脚本名 :: rc :: Total 原文）

```
=== selftest-active-plan.sh rc=0 :: Total: 19 PASS=19 FAIL=0
=== selftest-ask-default-timeout.sh rc=0 :: Total: 9 PASS=9 FAIL=0
=== selftest-batch-pilot.sh rc=0 :: Total: 10 PASS=10 FAIL=0
=== selftest-check-conflicts.sh rc=0 :: Total: 7 PASS=7 FAIL=0
=== selftest-check-drift.sh rc=0 :: Total: 6 PASS=6 FAIL=0
=== selftest-conclusion-discipline.sh rc=0 :: Total: 24 PASS=24 FAIL=0
=== selftest-context-hygiene.sh rc=0 :: Total: 12 PASS=12 FAIL=0
=== selftest-delegation.sh rc=0 :: Total: 38    PASS=38  FAIL=0
=== selftest-dispatch.sh rc=0 :: Total: 31 PASS=31 FAIL=0
=== selftest-error-loop.sh rc=0 :: Total: 16 PASS=16 FAIL=0
=== selftest-execution-stability.sh rc=0 :: Total: 19  PASS=19  FAIL=0
=== selftest-fallback.sh rc=0 :: Total: 31  PASS=31  FAIL=0
=== selftest-final-gate-hash.sh rc=0 :: (输出无 Total 行, rc=0, elapsed=15s)
=== selftest-fine-grain-steps.sh rc=0 :: Total: 11 PASS=11 FAIL=0
=== selftest-interaction.sh rc=0 :: Total: 11 PASS=11 FAIL=0
=== selftest-iterative-optimizer.sh rc=0 :: Total: 8 PASS=8 FAIL=0
=== selftest-knowledge-brief.sh rc=0 :: Total: 16  PASS=16  FAIL=0
=== selftest-mechanism-profile.sh rc=0 :: Total: 19 PASS=19 FAIL=0
=== selftest-methodology.sh rc=0 :: Total: 16 PASS=16 FAIL=0
=== selftest-plan-dispatch.sh rc=0 :: Total: 12 PASS=12 FAIL=0
=== selftest-plan-tier.sh rc=0 :: Total: 32 PASS=32 FAIL=0
=== selftest-reflect-verify.sh rc=0 :: Total: 12 PASS=12 FAIL=0
=== selftest-registry.sh rc=0 :: Total: 5 PASS=5 FAIL=0 (registry rows=42, actual selftest=42)
=== selftest-reliability-institution.sh rc=0 :: Total: 12 PASS=12 FAIL=0
=== selftest-rescue-chain.sh rc=0 :: Total: 11 PASS=11 FAIL=0
=== selftest-review-library.sh rc=0 :: Total: 15 PASS=15 FAIL=0
=== selftest-rule23-conflict-scan.sh rc=0 :: Total: 3 PASS=3 FAIL=0
=== selftest-self-resolution.sh rc=0 :: Total: 13 PASS=13 FAIL=0
=== selftest-shared-tracker.sh rc=0 :: Total: 11 PASS=11 FAIL=0
=== selftest-skill-collab.sh rc=0 :: Total: 25  PASS=25  FAIL=0
=== selftest-skill-modify.sh rc=0 :: Total: 9 PASS=9 FAIL=0 (SKIP=0)
=== selftest-skill-split.sh rc=0 :: Total: 41  PASS=41  FAIL=0
=== selftest-smart-merge.sh rc=0 :: Total: 17 PASS=17 FAIL=0
=== selftest-sync-index.sh rc=0 :: Total: 13 PASS=13 FAIL=0
=== selftest-task-boundary.sh rc=0 :: Total: 11 PASS=11 FAIL=0
=== selftest-template-lifecycle.sh rc=0 :: Total: 21 PASS=21 FAIL=0
=== selftest-template-sense.sh rc=0 :: Total: 8 PASS=8 FAIL=0
=== selftest-tier-b.sh rc=0 :: Total: 18 PASS=18 FAIL=0
=== selftest-tool-selection.sh rc=0 :: Total: 12 PASS=12 FAIL=0
=== selftest-vc-gate.sh rc=0 :: Total: 11 PASS=11 FAIL=0
=== selftest-veto.sh rc=0 :: Total: 13 PASS=13 FAIL=0
=== selftest-workflow-orchestration.sh rc=1 :: Total: 16 PASS=15 FAIL=1
```

### WF-10 FAIL 根因（唯一 rc≠0）

- 失败断言: `WF-10 FAIL Rules 1-39 命中总和 4 <6`（scripts/selftest-workflow-orchestration.sh:52-57）
- 断言逻辑: 4 索引文档（SKILL.md/CLAUDE.md/README_zh.md/skills/task-planner/README.md）中 "Rules 1-39" 命中总和须 ≥6
- 逐文件实测: SKILL.md=2, CLAUDE.md=1, README_zh.md=0, skills/task-planner/README.md=1 → 总和 4
- 根因: Phase 1b（85ab33b）把 README_zh.md 两处 `Rules 1-39` 刷新为 `Rules 1-45`（实测数字，git diff README_zh.md:136,229 `-Rules 1-39 核心执行约束 / +Rules 1-45 核心执行约束`），但 selftest WF-10 的锚点期望未随动——文档刷新正确、测试断言漂移（守卫锚级联漏网，FMEA「级联漏网 RPN 48」命中）
- 建议修法: WF-10 改数 `Rules 1-4[0-9]` 合并锚或阈值对齐现值；或 README_zh.md 回退为 "Rules 1-39（含 40-45）" 表述——推荐前者（数字面保持实测真相）

## 2. 对齐审查四要素（alignment-review 方法）

### 2.1 diff↔意图对应（抽 5 处, 全过）

| # | 位置 | diff 原文 | 意图 | 判定 |
|---|------|-----------|------|------|
| 1 | skills/task-planner/SKILL.md:64 | `-确认创建了 5 个文件（…verification.md）` → `+确认创建了 6 个文件（…/ knowledge-brief.md）（task-v116：v067 起第 6 文件，v107 R-01 清账）` | R-01 五文件锚→6 文件 | ✓ |
| 2 | skills/plan-cost-guard/SKILL.md:21 | `-≥10 次 → 触发 AskUserQuestion；>15 次强制 STOP` → `+…（与主侧 critical-rules.md 17.5 同源同改 task-v116：删除无源「>15 强制 STOP」档，v107 C-P1 清账）` | R-06 幽灵 STOP 档删除 | ✓ |
| 3 | skills/plan-cost-guard/references/cost-control.md:33 | 17.5 行末 `+（与主侧 17.5 同源，无更高 STOP 档，task-v116 对齐）` | R-06 对齐核查 | ✓ |
| 4 | skills/progress-tracker/SKILL.md:192 | `plan-bookkeeper` 幽灵行 → `~~plan-bookkeeper~~（已移除，task-v116 v107 C-P5 清账：仓内无此技能）→ task-planner 主进程簿记职能` | R-08 清账 | ✓ |
| 5 | README_zh.md×9 + INSTALL_zh.md×14 | 数字簇 29 变体/40 键/81 项/6 文件/Rules 1-45/2.0MB/实位安装命令（见 sub:1 对照表） | R-11 数字簇实测刷新 | ✓ |

主侧权威源核验: critical-rules.md:84 `17.5 **opus 调用门控**…≥10 次 → AskUserQuestion`（无更高 STOP 档）——与 R-06 修复一致。

### 2.2 旧表述零残留复验（grep 全仓 skills/+根文档）

| 模式 | 结果 | 判定 |
|------|------|------|
| `bash scripts/install.sh` | skills/ 与 README_zh/INSTALL_zh/CLAUDE = 0；**CONTRIBUTING.md:44,51,89,136 + CONTRIBUTING_zh.md:44,51,89,136 共 8 处残留**（含幽灵 flag `--force`/`--target`） | ✗ P1（超出 v116 scope_files，未刷新） |
| `session-catchup.py` | **CLAUDE.md:24,43,54,81 共 4 处残留**（实际文件=scripts/session-catchup.ts, ls 实测）；CONTRIBUTING.md:40 / CONTRIBUTING_zh.md:40 各 1；CHANGELOG.md:140 历史条目（可豁免）；check-scope.sh:80（脚本白名单模式,非文档）+ templates/variant/memory-hygiene-type.md:133（模板证据例句） | ✗ P1（CLAUDE.md 根文档）+ P2（脚本/模板/历史） |
| `>15 次强制 STOP` | skills/plan-cost-guard/SKILL.md:21 已修复；cost-control.md:33 已对齐；**但 references/billing.md:54 仍存 `| >15 次 | 强制 STOP,等用户决策 |` 门控表行（billing.md 第 46 行标题「单会话 opus 累计门控（Rule 17.5）」表内）——R-06 漏网**；部署位 ~/.zcode/skills/plan-cost-guard/references/billing.md:54 同残留 | ✗ P0/P1（用户可见计费文档与主侧 critical-rules.md:84 语义互斥） |
| `plan-bookkeeper` | 仅 progress-tracker/SKILL.md:192 删除标记（有意保留的清账注记，可接受） | ✓ 零幽灵引用 |
| `5 个文件`（计划簇） | task-planner SKILL.md:64 已改 6 文件；template-guide.md:143「5 个文件名白名单 init-session.sh:62」——核实 init-session.sh:210 for 循环恰为 5 文件（task_plan 另建），属另一事实，非 R-01 残留（P2 观察: 行号锚 :62 与实 :210 漂移，非 v116 scope） | ✓（R-01 口径零残留） |

### 2.3 引用实存

- `skills/task-planner/install.sh` EXISTS ✓（实 flag --canonical/--tools/--no-verify/--no-backup/--dry-run，无 --force/--target/--uninstall）
- `skills/task-planner/uninstall.sh` EXISTS ✓
- `skills/task-planner/lib/verify.sh` EXISTS ✓
- `scripts/session-catchup.ts` EXISTS ✓（.py 已不存在）

### 2.4 守卫锚重跑

- selftest-template-lifecycle.sh → `Total: 21 PASS=21 FAIL=0` rc=0 ✓
- selftest-skill-split.sh → `Total: 41  PASS=41  FAIL=0` rc=0 ✓

## 3. 8 字段结论块

```
status: partial
acceptance: 2/3 pass — [1:回归 42 行 PASS(41/42 rc=0, WF-10 FAIL 根因已定位) 2:四要素 FAIL(残余项见 2.2) 3:checkpoint PASS]
files: 无修改（只读任务；写入仅限本 checkpoint+findings 追加段+progress 追加行）
evidence: 见上 §1/§2 各表（全部命令可重跑复现：selftest 42 个 bash timeout 90；git diff eb6aea8^1 85ab33b；grep 各模式）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v116/subagent-state/2-executor.md (status: done)
findings_written: #### [sub:2-executor] 回归与对齐
blockers: WF-10 断言漂移 + billing.md:54/CLAUDE.md/CONTRIBUTING×2 旧表述残留（v116 scope 外, 需主进程裁决是否立 v117）
confidence: HIGH
```

## 4. 负结果报告（已排除项）

- 42 脚本中无超时（单脚本最长 15-16s，远 <90s）
- 无 SKIP 异常（selftest-skill-modify SKIP=0）
- 部署位 ~/.zcode/skills 存在对应三技能副本，仅 billing.md 残留与主仓一致（非部署漂移）
- 英文死链（根 INSTALL.md/README.md）grep = 0 ✓；`--uninstall`/`scripts/uninstall.sh` 幽灵命令 grep = 0 ✓
