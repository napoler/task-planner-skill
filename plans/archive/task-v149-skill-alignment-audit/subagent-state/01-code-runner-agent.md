# task-v149 selftest 基线 — 检查点 (01-code-runner-agent)

> 状态: COMPLETED | 最后更新: 2026-10-08 22:42 | 全量 62/62 完成

## ① 执行环境

- 日期: 2026-10-08
- 仓库: /mnt/data/dev/task-planner-skill
- 分支/commit: master @ 21f7e6b
- 命令模式: `timeout 120 bash <script> > /tmp/v149-selftest-$(basename <script> .sh).log 2>&1`
  - 注: 脚本 basename 本身以 `selftest-` 开头, 故实际日志名形如 `/tmp/v149-selftest-selftest-<name>.log` (双 selftest 前缀为任务指定命名)
- 依赖: jq(/usr/bin/jq) bun(/home/terry/.bun/bin/bun) node python3 timeout 均可用, 无缺依赖
- 只读约束: 未修改仓库内任何源文件; 仅写入任务指定的本检查点文件与 /tmp 日志

## ② 逐脚本结果表 (全量 62/62)

| # | 脚本 | exit | PASS | FAIL | 备注 |
|---|------|------|------|------|------|
| 1 | selftest-active-plan | 0 | 29 | 0 | |
| 2 | selftest-agent-coverage | 0 | 9 | 0 | SKIPPED=0 |
| 3 | selftest-ask-default-timeout | 0 | 11 | 0 | |
| 4 | selftest-batch-pilot | 0 | 10 | 0 | |
| 5 | selftest-capability-persistence | 0 | 20 | 0 | |
| 6 | selftest-check-conflicts | 0 | 7 | 0 | |
| 7 | selftest-check-drift | 0 | 6 | 0 | |
| 8 | selftest-conclusion-discipline | 0 | 24 | 0 | |
| 9 | selftest-context-hygiene | 0 | 12 | 0 | |
| 10 | selftest-delegation | 0 | 38 | 0 | |
| 11 | selftest-dispatch-grain | 0 | 10 | 0 | |
| 12 | selftest-dispatch | 0 | 31 | 0 | |
| 13 | selftest-drift-check-subagent | 0 | 20 | 0 | |
| 14 | selftest-drift-enforcement | 0 | 23 | 0 | |
| 15 | selftest-error-loop | 0 | 16 | 0 | |
| 16 | selftest-evidence-goal-gate | 0 | 21 | 0 | |
| 17 | selftest-execution-honesty | 0 | 14 | 0 | |
| 18 | selftest-execution-stability | 0 | 19 | 0 | |
| 19 | selftest-fallback | 0 | 31 | 0 | stderr 含 jq 编译错误(见③-2), T07c 空洞通过 |
| 20 | selftest-final-gate-hash | 0 | 22 | 0 | 18s (本批最慢) |
| 21 | selftest-fine-grain-steps | 0 | 11 | 0 | |
| 22 | selftest-four-file-dataflow | 0 | 18 | 0 | |
| 23 | selftest-interaction | 0 | 11 | 0 | |
| 24 | selftest-iteration-persistence | 0 | 18 | 0 | |
| 25 | selftest-iterative-optimizer | 0 | 8 | 0 | |
| 26 | selftest-knowledge-brief | 0 | 16 | 0 | |
| 27 | selftest-lane-advancement | 0 | 14 | 0 | |
| 28 | selftest-mechanism-profile | 0 | 19 | 0 | |
| 29 | selftest-media-agents | 0 | 10 | 0 | |
| 30 | selftest-media-dispatch | 0 | 9 | 0 | |
| 31 | selftest-methodology | 0 | 16 | 0 | |
| 32 | selftest-periodic-review | **1** | 6 | **4** | 唯一 FAIL, 详见③-1, 已复现 |
| 33 | selftest-plan-dispatch | 0 | 12 | 0 | |
| 34 | selftest-plan-tier | 0 | 32 | 0 | 12s |
| 35 | selftest-reflect-verify | 0 | 12 | 0 | |
| 36 | selftest-registry | 0 | 5 | 0 | |
| 37 | selftest-reliability-institution | 0 | 16 | 0 | |
| 38 | selftest-requirement-coverage | 0 | 23 | 0 | 12s |
| 39 | selftest-requirement-grading | 0 | 7 | 0 | |
| 40 | selftest-rescue-chain | 0 | 11 | 0 | |
| 41 | selftest-research-first | 0 | 12 | 0 | |
| 42 | selftest-review-library | 0 | 15 | 0 | |
| 43 | selftest-root-resolution | 0 | 17 | 0 | |
| 44 | selftest-rule23-conflict-scan | 0 | 3 | 0 | |
| 45 | selftest-rule-reserve | 0 | 10 | 0 | |
| 46 | selftest-self-resolution | 0 | 13 | 0 | |
| 47 | selftest-shared-tracker | 0 | 11 | 0 | |
| 48 | selftest-skill-collab | 0 | 25 | 0 | |
| 49 | selftest-skill-modify | 0 | 9 | 0 | |
| 50 | selftest-skill-split | 0 | 41 | 0 | |
| 51 | selftest-smart-merge | 0 | 17 | 0 | 10s |
| 52 | selftest-subagent-granularity-skill-escort | 0 | 23 | 0 | |
| 53 | selftest-sync-index | 0 | 13 | 0 | |
| 54 | selftest-task-boundary | 0 | 11 | 0 | |
| 55 | selftest-template-lifecycle | 0 | 24 | 0 | |
| 56 | selftest-template-sense | 0 | 8 | 0 | |
| 57 | selftest-tier-b | 0 | 18 | 0 | |
| 58 | selftest-tool-selection | 0 | 12 | 0 | |
| 59 | selftest-user-instruction-priority | 0 | n/a* | 0 | *非标准格式: 7 条 `✓` 检查全过 + `=== ALL PASS ===`, 无 `PASS=n` 汇总行 |
| 60 | selftest-vc-gate | 0 | 11 | 0 | 16s |
| 61 | selftest-veto | 0 | 13 | 0 | |
| 62 | selftest-workflow-orchestration | 0 | 16 | 0 | |

## ③ FAIL 脚本明细

### ③-1 selftest-periodic-review (exit=1, PASS=6 FAIL=4)

日志: `/tmp/v149-selftest-selftest-periodic-review.log` (复现: `/tmp/v149-selftest-periodic-review-rerun.log`, rerun exit=1, 同样 4 条 FAIL — 可复现)

逐步 FAIL 行原文 (日志 3-10 行):
```
PR-03 FAIL Rule 57 前后对照检查维度缺失
PR-04 FAIL Rule 57 自动纠正机制缺失
PR-05 FAIL Rule 57 开关键缺失
PR-10 FAIL SKILL.md C39 引用缺失
```
复现输出末行: `Total: 10 PASS=6 FAIL=4`

### ③-2 附加发现: selftest-fallback T07c 空洞通过 (exit=0 但断言无效)

- 日志 19-24 行原文:
```
jq: error: syntax error, unexpected INVALID_CHARACTER (Unix shell quoting issues?) at <top-level>, line 1:
.files[\"executor-fb.md\"].hash
jq: 1 compile error
```
- 脚本 `skills/task-planner/scripts/selftest-fallback.sh:108,110` 中 `jq -r '.files[\"executor-fb.md\"].hash'` 转义写法在 jq 1.6 编译报错 (jq_exit=3, stdout 为空, 已独立复现)
- 后果: `h1`/`h2` 均为空字符串, `T07c meta hash 不变` = `test "$h1" = "$h2"` 空等空恒真 → **空洞通过**, 实际未验证任何 hash
- 置信度: HIGH (日志证据 + 独立复现)

## ④ 总计

- 脚本总数: **62** (日志 62/62 齐全, 一一对应无缺失)
- exit=0: **61** / exit≠0: **1** (selftest-periodic-review exit=1)
- **ΣPASS = 969** (按标准 `PASS=n` 汇总行统计, 61 个脚本; 另有 selftest-user-instruction-priority 7 条 `✓` 全过未计入 → 含入口径为 976)
- **ΣFAIL = 4** (全部来自 selftest-periodic-review)
- timeout 脚本: 0; 最长单脚本耗时 18s (final-gate-hash), 全部远低于 120s 上限
- 对照历史基线 (v147: ΣFAIL=4): 计数一致 (同为 4); 断言条目是否同一组未逐字比对 (MEDIUM)

## 进度日志

- 2026-10-08 22:35: 批1 (脚本1-16) 完成, 全部 exit=0, 初始检查点落盘 (ΣPASS=287)
- 2026-10-08 22:42: 批2 (脚本17-62) 后台续跑完成; periodic-review 失败已复现; fallback jq 空洞通过已复现; 全量汇总落盘
