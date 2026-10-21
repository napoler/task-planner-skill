# S4 Runner — task-planner 守卫脚本健康扫描 + 全量回归基线

- 生成时间: 2026-10-22 01:2x CST
- 仓库: /mnt/data/dev/task-planner-skill（分支 master，HEAD 未变）
- 执行模式: 只读（仅执行脚本；唯一写入 = 本文件 + /tmp 临时日志）
- 执行者: code-runner（子代理 S4）

---

## 0. 口径与不变量

| 项 | 值 | 证据 |
|---|---|---|
| 活树 .sh 总数（`-path '*/.backup' -prune`） | **159** | `find skills -path '*/.backup' -prune -o -name '*.sh' -print | wc -l` → 159 |
| 其中 `skills/task-planner/scripts/` | 136（92 selftest + 22 check + 22 其他） | `ls -1 *.sh | wc -l` → 136；`ls -1 selftest-*.sh | wc -l` → 92；`ls -1 check-*.sh | wc -l` → 22 |
| 其他活树目录 | task-planner/lib 6, task-planner 根 2, task-planner/tests 1, task-planner/scripts/lib 1, task-dispatch/scripts 6, plan-resume/scripts 3, plan-resume/tests 1, verification-gate/scripts 1, task-discipline/scripts 1, task-discipline/scripts/capabilities 1 | `sed 's|/[^/]*$||' /tmp/all_sh.txt | sort | uniq -c` |
| **已排除** `.backup/` | 2 个 .backup 目录，内含 1556 文件，其中 **895 个 .sh（557 个 selftest-*.sh）** | `find skills -path '*/.backup*' -name 'selftest-*.sh' | wc -l` → 557（与任务说明「557 个历史 selftest 副本」一致） |
| 工作树未被本次执行改动 | 是 | 运行前后 `git status --short` 完全一致；4 个已改文件 mtime 仍为 `2026-10-21 11:30:02 / 11:32:33`，早于运行时刻 `2026-10-22 01:21` |

**在途变更实况（4 个，非 3 个）**：`git status --short` 显示
- `M skills/task-planner/SKILL.md`（+1/-1 行：Rule 51 bullet 增补 51.9-51.12 摘要）
- `M skills/task-planner/references/critical-rules.md`（+10 行：51.9-51.13 五子条）
- `M skills/task-planner/scripts/selftest-requirement-coverage.sh`（+60/-5 行：新增 RC-24..RC-27 断言）
- `M plans/.rule-reservations.jsonl`（+2 行，**任务说明未列出**，属计划侧数据非守卫脚本）
`git diff --stat` 合计 4 files changed, 69 insertions(+), 5 deletions(-)。

---

## ① 语法健康

| 项 | 值 |
|---|---|
| `bash -n` 检查文件数（活树 159 全量） | 159 |
| **语法错误数** | **0** |
| 错误文件清单 | 无 |

命令（可复现）：
```bash
cd /mnt/data/dev/task-planner-skill
find skills -path '*/.backup' -prune -o -name '*.sh' -print > /tmp/all_sh.txt
while read -r f; do bash -n "$f" || echo "SYNTAX_ERR $f"; done < /tmp/all_sh.txt
# 输出: 无任何 SYNTAX_ERR 行 → 0 语法错误
```

---

## ② 全量回归总表（92 个 selftest，逐个 `timeout 60 bash <script>`）

调度：`xargs -P 6`，单脚本 `timeout 60`，**总墙钟 61 秒**，各脚本耗时之和 281,880 ms。
汇总：**92 executed / 92 exit 0 / PASS 合计 1315 / FAIL 合计 0 / timeout 0**。

| 脚本名 | exit | PASS | FAIL | 耗时 | 备注 |
|---|---|---|---|---|---|
| selftest-absorption-discipline.sh | 0 | 16 | 0 | 446 ms | 1 skip (AD-13 中性态) |
| selftest-active-plan.sh | 0 | 29 | 0 | 7883 ms | |
| selftest-agent-coverage.sh | 0 | 9 | 0 | 301 ms | |
| selftest-archive-plan.sh | 0 | 20 | 0 | 1189 ms | |
| selftest-ask-default-timeout.sh | 0 | 11 | 0 | 167 ms | |
| selftest-batch-pilot.sh | 0 | 10 | 0 | 214 ms | |
| selftest-capability-persistence.sh | 0 | 20 | 0 | 1329 ms | |
| selftest-channel-fast-fail.sh | 0 | 6 | 0 | 152 ms | |
| selftest-check-conflicts.sh | 0 | 7 | 0 | 1592 ms | |
| selftest-check-drift.sh | 0 | 7 | 0 | 2393 ms | |
| selftest-conclusion-discipline.sh | 0 | 24 | 0 | 207 ms | |
| selftest-context-hygiene.sh | 0 | 12 | 0 | 1093 ms | |
| selftest-context-pressure.sh | 0 | 9 | 0 | 215 ms | |
| selftest-decision-arbiter.sh | 0 | 16 | 0 | 184 ms | |
| selftest-decision-drift.sh | 0 | 23 | 0 | 397 ms | |
| selftest-decision-grading.sh | 0 | 11 | 0 | 336 ms | WARN=1（DG-12 占位跳过，非 FAIL） |
| selftest-delegation.sh | 0 | 38 | 0 | 4642 ms | |
| selftest-dispatch-grain.sh | 0 | 10 | 0 | 1970 ms | |
| selftest-dispatch.sh | 0 | 31 | 0 | 8829 ms | |
| selftest-doc-script-paths.sh | 0 | 3 | 0 | 1772 ms | docs=46 tokens=162 |
| selftest-drift-check-subagent.sh | 0 | 21 | 0 | 833 ms | |
| selftest-drift-enforcement.sh | 0 | 23 | 0 | 15934 ms | |
| selftest-error-fix-prompt-forge.sh | 0 | 8 | 0 | 231 ms | |
| selftest-error-loop.sh | 0 | 16 | 0 | 328 ms | |
| selftest-evidence-anchor.sh | 0 | 26 | 0 | 19796 ms | |
| selftest-evidence-goal-gate.sh | 0 | 23 | 0 | 4807 ms | |
| selftest-execution-honesty.sh | 0 | 14 | 0 | 226 ms | |
| selftest-execution-stability.sh | 0 | 19 | 0 | 3350 ms | |
| selftest-final-gate-hash.sh | 0 | 22 | 0 | 27334 ms | 最慢脚本 |
| selftest-fine-grain-steps.sh | 0 | 11 | 0 | 3355 ms | |
| selftest-four-file-dataflow.sh | 0 | 18 | 0 | 301 ms | |
| selftest-gate-degraded.sh | 0 | 16 | 0 | 2066 ms | |
| selftest-gate-injection.sh | 0 | 11 | 0 | 10425 ms | |
| selftest-goal-cjk.sh | 0 | 11 | 0 | 445 ms | |
| selftest-goal-unit-goal-mode.sh | 0 | 9 | 0 | 314 ms | |
| selftest-input-consistency.sh | 0 | 5 | 0 | 95 ms | WARN=0 |
| selftest-interaction.sh | 0 | 11 | 0 | 575 ms | |
| selftest-iteration-persistence.sh | 0 | 18 | 0 | 264 ms | |
| selftest-iterative-optimizer.sh | 0 | 8 | 0 | 183 ms | |
| selftest-knowledge-brief.sh | 0 | 16 | 0 | 413 ms | |
| selftest-lane-advancement.sh | 0 | 14 | 0 | 148 ms | |
| selftest-mechanism-profile.sh | 0 | 19 | 0 | 15823 ms | |
| selftest-media-agents.sh | 0 | 10 | 0 | 226 ms | |
| selftest-media-dispatch.sh | 0 | 9 | 0 | 134 ms | |
| selftest-methodology.sh | 0 | 16 | 0 | 1943 ms | |
| selftest-parallel-scheduling.sh | 0 | 9 | 0 | 210 ms | |
| selftest-periodic-review.sh | 0 | 10 | 0 | 131 ms | |
| selftest-plan-dispatch.sh | 0 | 12 | 0 | 3634 ms | |
| selftest-plan-tier.sh | 0 | 32 | 0 | 17984 ms | |
| selftest-pointer-lifecycle.sh | 0 | 10 | 0 | 532 ms | |
| selftest-proactive-research.sh | 0 | 15 | 0 | 162 ms | |
| selftest-reflect-verify.sh | 0 | 12 | 0 | 167 ms | |
| selftest-registry.sh | 0 | 5 | 0 | 116 ms | registry rows=92, actual selftest=92（一致） |
| selftest-reliability-institution.sh | 0 | 16 | 0 | 195 ms | |
| selftest-report-reviewability.sh | 0 | 12 | 0 | 424 ms | WARN=1（RRV-13 占位跳过） |
| selftest-requirement-coverage.sh | 0 | 27 | 0 | 20054 ms | **在途变更脚本** |
| selftest-requirement-grading.sh | 0 | 7 | 0 | 143 ms | |
| selftest-research-first.sh | 0 | 12 | 0 | 279 ms | |
| selftest-review-library.sh | 0 | 15 | 0 | 1078 ms | |
| selftest-root-resolution.sh | 0 | 17 | 0 | 290 ms | |
| selftest-rule23-conflict-scan.sh | 0 | 3 | 0 | 1291 ms | |
| selftest-rule-reserve-pairing.sh | 0 | 3 | 0 | 135 ms | |
| selftest-rule-reserve.sh | 0 | 10 | 0 | 914 ms | |
| selftest-rvc-coverage.sh | 0 | 9 | 0 | 1274 ms | RVC-08 语义 SKIP（非跳过断言） |
| selftest-self-resolution.sh | 0 | 13 | 0 | 270 ms | |
| selftest-session-log.sh | 0 | 12 | 0 | 6172 ms | |
| selftest-shared-tracker.sh | 0 | 11 | 0 | 324 ms | |
| selftest-skill-collab.sh | 0 | 25 | 0 | 443 ms | |
| selftest-skill-modify.sh | 0 | 7 | 0 | 209 ms | SKIP=2（SM-08 ×2，Rule 36/C24 缺失自动跳过） |
| selftest-skill-split.sh | 0 | 40 | 0 | 361 ms | PAS 数最多 |
| selftest-smart-merge.sh | 0 | 18 | 0 | 11651 ms | |
| selftest-source-anchor-discipline.sh | 0 | 12 | 0 | 239 ms | |
| selftest-split-pattern-library.sh | 0 | 13 | 0 | 142 ms | |
| selftest-state-consistency.sh | 0 | 5 | 0 | 549 ms | |
| selftest-step-placeholders.sh | 0 | 10 | 0 | 376 ms | |
| selftest-subagent-granularity-skill-escort.sh | 0 | 23 | 0 | 270 ms | |
| selftest-subagent-return.sh | 0 | 12 | 0 | 1707 ms | |
| selftest-summary-readability.sh | 0 | 13 | 0 | 20921 ms | WARN=0 |
| selftest-sync-index.sh | 0 | 15 | 0 | 1027 ms | |
| selftest-task-boundary.sh | 0 | 11 | 0 | 164 ms | |
| selftest-template-lifecycle.sh | 0 | 24 | 0 | 438 ms | |
| selftest-template-sense.sh | 0 | 8 | 0 | 14258 ms | |
| selftest-tier-b.sh | 0 | 18 | 0 | 2389 ms | |
| selftest-tier-consistency.sh | 0 | 8 | 0 | 509 ms | |
| selftest-tool-selection.sh | 0 | 12 | 0 | 212 ms | |
| selftest-user-instruction-priority.sh | 0 | 7 | 0 | 107 ms | 输出形态 `=== ALL PASS ===`（✓×7） |
| selftest-vc-gate.sh | 0 | 11 | 0 | 22779 ms | |
| selftest-vc-nonvacuous.sh | 0 | 13 | 0 | 864 ms | |
| selftest-verification-gate.sh | 0 | 13 | 0 | 217 ms | |
| selftest-verify-io.sh | 0 | 4 | 0 | 784 ms | 输出形态 `总计: 4 PASS, 0 FAIL` |
| selftest-veto.sh | 0 | 13 | 0 | 267 ms | |
| selftest-workflow-orchestration.sh | 0 | 22 | 0 | 358 ms | |

> 注：PASS 合计 1315 由各脚本自报 Total 行相加；`selftest-user-instruction-priority.sh`（无 Total 行，输出 `=== ALL PASS ===`）按 ✓ 行计 7、`selftest-verify-io.sh`（`总计:` 行）计 4、`selftest-final-gate-hash.sh`（`==== ... 结果:` 行）计 22，均已人工复核原始日志。

---

## ③ 失败脚本逐条

**失败数 = 0**（exit≠0: 0 / FAIL>0: 0 / timeout: 0）。因此「在途变更导致的失败」与「其他失败」两类**均为空集**，无需归属判定。

### 负结果报告（必须披露：预期中的失败未出现）

- **检查了哪些位置**：活树 92 个 `selftest-*.sh` 全量逐个执行；每份日志的 `Total/结果/总计/ALL PASS` 汇总行、逐条 `PASS/FAIL` 标记行（不是只看 exit code）；`selftest-registry.tsv`（93 行 = 1 表头 + 92 行，自登记 92 = 实际 92）。
- **预期问题但未发现**：
  1. 任务提示「3 个未提交在途变更可能造成个别 FAIL」——**未出现**。直接证据：`selftest-requirement-coverage.sh`（在途改动脚本本身）跑出 `Total: 27 PASS=27 FAIL=0`；另 65 个 selftest 引用 `SKILL.md`、59 个引用 `critical-rules.md`（在途文档），全部 exit 0 且 FAIL=0。
  2. 语法错误：预期活树历史遗留风险，**0 个**。
  3. 挂死/超时：单脚本 `timeout 60`，最慢 27.3s（final-gate-hash），**0 超时**。
  4. registry 漂移（脚本未登记 / 登记但不存在）：**未发现**，registry rows=92 = actual 92。
- **排除了哪些可能性**：
  - 「exit 0 掩盖 FAIL」已被排除：全量 grep 日志，除 `selftest-decision-grading.sh`/`selftest-report-reviewability.sh` 的 `WARN=1` 占位行外，无任何 `FAIL≥1` 汇总行；且抽查尾部含 `exit 0` 的 10 个脚本，均先经 `[ "$FAIL" -eq 0 ] || exit 1`，无「无条件 exit 0 吞失败」结构。
  - 「并行执行互相干扰造成假 PASS / 假 FAIL」：92 个脚本 `xargs -P 6`，PASS 数与 registry 及各自断言编号一一对应（如 requirement-coverage 27 条 = RC-01..RC-27），且最慢 5 个脚本耗时（27.3s/22.8s/20.9s/20.1s/19.8s）远低于 60s 超时，未因并发争用触发降级。
  - 「在途文档改动已破坏旧断言（部分提交会断回归）」：用 `/tmp` 镜像（软链 references/templates/config.json/SKILL.md + 其余 145 个脚本，仅脚本本体取 `git show HEAD:...`）跑 HEAD 版测试，结果 `Total: 23 PASS=23 FAIL=0`（exit 0）→ 在途 `critical-rules.md`/`SKILL.md` 的 +11 行对 HEAD 版断言**向后兼容**，不构成隐性破坏。
    - 首次镜像跑出 `RC-17..RC-22 六个 FAIL`（均 `exit=127`）经查是镜像缺兄弟脚本所致，**已判定为实验假象并作废**，不作为结论。

---

## ④ 门脚本抽样（原样记录，未为使通过而修改任何文件）

| # | 命令（cwd=/mnt/data/dev/task-planner-skill） | exit | 实际输出（逐字） |
|---|---|---|---|
| G1 | `bash skills/task-planner/scripts/check-complete.sh --help` | **0** | `[plan] No task_plan.md found — no active planning session.` |
| G2 | `bash skills/task-planner/scripts/check-complete.sh`（cwd=scripts/，无参默认 task_plan.md） | **0** | `[plan] No task_plan.md found — no active planning session.` |
| G3 | `bash skills/task-planner/scripts/check-complete.sh plans/task-skill-audit-20261021/task_plan.md` | **1** | `[plan] Rule 27.3 violation: scope 内存在未提交变更` / `[plan]   ?? plans/task-skill-audit-20261021/` |
| G4 | `bash skills/task-planner/scripts/check-3file-gate.sh`（无参） | **1** | `[3file-gate] usage: check-3file-gate.sh <plan-dir or task_plan.md> [--require-kb]` |
| G5 | `bash skills/task-planner/scripts/check-3file-gate.sh plans/task-skill-audit-20261021/` | **0** | （无输出；门控通过 = 可翻转 complete） |
| G6 | `bash skills/task-planner/scripts/check-3file-gate.sh plans/task-skill-audit-20261021/ --require-kb` | **0** | （无输出） |
| G7 | `bash skills/task-planner/scripts/check-complete.sh plans/task-v192-deploy-zcode/task_plan.md`（对照：已跟踪的旧计划） | **1** | `[plan] Rule 27.3: 范围限制节缺少表头行,跳过` / `[state-consistency] PASS (fail-open: task_plan.md 无  段)` / `[plan] ✗ Phase 标题格式不匹配（要求 `### Phase N`）；计划无效先回炉，禁放行 ...` / `[plan] No phases found in task_plan.md.` / `[ARCHIVE-GATE] WARN: 5 个已完成计划未归档…` |

解读（事实层，非缺陷断言）：
- `check-complete.sh` **无 `--help` 专用分支**：`--help` 被当作 PLAN_FILE 路径，故落到「无 task_plan.md」分支并 exit 0 —— 用法只能从脚本头注（`输入: $1=plan 文件路径(默认 task_plan.md...)`）或源码获知。
- G3 的 exit 1 原因是审计计划目录本身为 untracked（`?? plans/task-skill-audit-20261021/`），属**计划侧状态**而非脚本缺陷；同一命令对已跟踪旧计划（G7）也因该计划 Phase 标题不合规而 exit 1，说明 check-complete 对「计划格式/Porcelain 清洁度」是 fail-closed 的。
- `check-3file-gate.sh` 对审计计划放行（G5/G6 exit 0），与回归中 `selftest-four-file-dataflow.sh`(18 PASS)、`selftest-reflect-verify.sh`(12 PASS) 结果一致。

---

## ⑤ 一句话结论

**当前主仓回归健康度 = 全绿：活树 159 个 .sh 语法 0 错，92 个 selftest 全数 exit 0、PASS 合计 1315 / FAIL 0 / 超时 0，4 项未提交在途变更（含 selftest-requirement-coverage.sh +60 行、critical-rules.md 51.9-51.13）未造成任何回归失败，且对 HEAD 版断言向后兼容；门脚本 2 个抽样均按其设计语义工作（check-3file-gate 放行审计计划 exit 0，check-complete 因计划目录未跟踪/Rule 27.3 而 exit 1）。**

可复现命令（只读，约 61s 墙钟）：
```bash
cd /mnt/data/dev/task-planner-skill
find skills -path '*/.backup' -prune -o -name '*.sh' -print | while read -r f; do bash -n "$f" || echo "SYNTAX_ERR $f"; done
mkdir -p /tmp/reg && : > /tmp/reg/rc.txt
ls -1 skills/task-planner/scripts/selftest-*.sh | sed 's|.*/||' | xargs -P 6 -I{} bash -c \
  'cd /mnt/data/dev/task-planner-skill; timeout 60 bash skills/task-planner/scripts/{} >/tmp/reg/{}.log 2>&1; echo "{}|$?" >> /tmp/reg/rc.txt'
awk -F'|' '$2!=0' /tmp/reg/rc.txt | wc -l          # 预期 0（非零退出脚本数）
grep -h -E '(Total|结果|总计)' /tmp/reg/*.log | grep -oE 'FAIL[=: ]+[0-9]+' | sort -u   # 预期仅 FAIL=0
```
