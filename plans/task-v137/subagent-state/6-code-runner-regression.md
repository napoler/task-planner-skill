# 6-code-runner-regression — task-v137 Phase 3 回归验证（S5 行）

- 单元类型：纯机械验证单元（Rule 51.1a 不适用）
- worktree（只读）：/home/terry/task-planner-skill-worktrees/task-v137
- 执行方式：仅只读命令（bash selftest / wc -l / check-dispatch），零文件修改
- 日期：2026-10-05

## 1. 全量 selftest 求和明细（逐脚本 Total 行）

求和口径：对每个 `selftest-*.sh` 取输出中的 `Total:` 行（final-gate-hash 取其 `结果:` 行），主进程 awk 求和。

| # | 脚本 | PASS | FAIL |
|---|------|------|------|
| 1 | selftest-active-plan.sh | 19 | 0 |
| 2 | selftest-agent-coverage.sh | 9 | 0 |
| 3 | selftest-ask-default-timeout.sh | 9 | 0 |
| 4 | selftest-batch-pilot.sh | 10 | 0 |
| 5 | selftest-check-conflicts.sh | 7 | 0 |
| 6 | selftest-check-drift.sh | 6 | 0 |
| 7 | selftest-conclusion-discipline.sh | 24 | 0 |
| 8 | selftest-context-hygiene.sh | 12 | 0 |
| 9 | selftest-delegation.sh | 38 | 0 |
| 10 | selftest-dispatch-grain.sh | 10 | 0 |
| 11 | selftest-dispatch.sh | 31 | 0 |
| 12 | selftest-error-loop.sh | 16 | 0 |
| 13 | selftest-execution-stability.sh | 19 | 0 |
| 14 | selftest-fallback.sh | 31 | 0 |
| 15 | selftest-final-gate-hash.sh | 22 | 0 |
| 16 | selftest-fine-grain-steps.sh | 11 | 0 |
| 17 | selftest-interaction.sh | 11 | 0 |
| 18 | selftest-iterative-optimizer.sh | 8 | 0 |
| 19 | selftest-knowledge-brief.sh | 16 | 0 |
| 20 | selftest-lane-advancement.sh | 14 | 0 |
| 21 | selftest-mechanism-profile.sh | 19 | 0 |
| 22 | selftest-media-agents.sh | 10 | 0 |
| 23 | selftest-media-dispatch.sh | 9 | 0 |
| 24 | selftest-methodology.sh | 16 | 0 |
| 25 | selftest-plan-dispatch.sh | 12 | 0 |
| 26 | selftest-plan-tier.sh | 32 | 0 |
| 27 | selftest-reflect-verify.sh | 12 | 0 |
| 28 | selftest-registry.sh | 5 | 0 |
| 29 | selftest-reliability-institution.sh | 16 | 0 |
| 30 | selftest-requirement-coverage.sh | 23 | 0 |
| 31 | selftest-requirement-grading.sh | 7 | 0 |
| 32 | selftest-rescue-chain.sh | 11 | 0 |
| 33 | selftest-review-library.sh | 15 | 0 |
| 34 | selftest-root-resolution.sh | 17 | 0 |
| 35 | selftest-rule23-conflict-scan.sh | 3 | 0 |
| 36 | selftest-rule-reserve.sh | 10 | 0 |
| 37 | selftest-self-resolution.sh | 13 | 0 |
| 38 | selftest-shared-tracker.sh | 11 | 0 |
| 39 | selftest-skill-collab.sh | 25 | 0 |
| 40 | selftest-skill-modify.sh | 9 | 0 |
| 41 | selftest-skill-split.sh | 41 | 0 |
| 42 | selftest-smart-merge.sh | 17 | 0 |
| 43 | selftest-sync-index.sh | 13 | 0 |
| 44 | selftest-task-boundary.sh | 11 | 0 |
| 45 | selftest-template-lifecycle.sh | 24 | 0 |
| 46 | selftest-template-sense.sh | 8 | 0 |
| 47 | selftest-tier-b.sh | 18 | 0 |
| 48 | selftest-tool-selection.sh | 12 | 0 |
| 49 | selftest-vc-gate.sh | 11 | 0 |
| 50 | selftest-veto.sh | 13 | 0 |
| 51 | selftest-workflow-orchestration.sh | 16 | 0 |

**求和结果：SCRIPTS=51  SUM_PASS=782  SUM_FAIL=0**
（全部 51 脚本 rc=0，无超时）

## 2. ΣPASS 与基线 760 的差异解释（逐条）

- 基线 760 = **50 个标准 `Total:` 格式**脚本之和（排除 final-gate-hash 后实测 `EXCL_FINALGATE: SCRIPTS=50 SUM_PASS=760 SUM_FAIL=0`，与基线**完全持平**）。
- 差值 +22 全部来自 `selftest-final-gate-hash.sh`（`==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`），该脚本输出格式为 `结果:` 而非 `Total:`，基线口径未纳入。
- 结论：**0 断言增删，ΣFAIL=0，与基线实质持平**；差异为求和口径差异而非行为回归。

## 3. 重点组逐行结果

### selftest-knowledge-brief.sh（T1b/T1c/T2a/T2b/T6/T7 全 PASS）
```
[PASS] T1b 五段标题 grep -c '^## §' = 5
[PASS] T1c 行数 ≤150
[PASS] T2a SKILL.md grep 'knowledge-brief' ≥2
[PASS] T2b SKILL.md 行数 ≤558
[PASS] T6 critical-rules 21.2(145)+22.4(168) 命中且 100<行号<200
[PASS] T7 subagent_dispatch.md 'knowledge-brief' ≥1
```
→ T1b 五段锚=5 未碎（知识简报新增供料行未新增 `## §` 段）；T6 窗口安全。

### selftest-skill-split.sh T-主 行数钉
```
[PASS] T-主 行数 ≤478（演进 440→442→444→447→449→452→454→461→475→477→478）
```
→ 零改动承诺成立（实测 wc -l = 478，恰压 ≤478 钉）。

## 4. 行数定数复核（wc -l）

| 文件 | wc -l | 说明 |
|------|-------|------|
| SKILL.md | **478** | 预期 478 不变 ✅ |
| templates/knowledge-brief.md | 68 | 基线 61（+7，S1 供料行型） |
| templates/subagent_dispatch.md | 78 | 基线 76（+2，S2 注入纪律行） |
| references/critical-rules.md | 591 | 基线 590（+1，S3 21.2.1 插入 :145 后） |
| templates/variant/rule-enhancement-type.md | 123 | 基线 122（+1，S4 必读表行） |

## 5. check-dispatch 冒烟

```
[dispatch-guard] usage: pretool <prompt-file> [sid] | check <prompt-file> <plan-dir>
```
rc=0，可运行性正常（不在本任务改动面，仅探测）。

## 6. 最终 8 字段结论

- status: done
- acceptance: 2/2 — ①PASS（51 脚本 ΣFAIL=0，ΣPASS 760 基线持平+final-gate-hash 22 口径差）②PASS（SKILL.md wc -l=478）
- files: none（只读验证，零文件修改）
- blockers: none
- confidence: HIGH