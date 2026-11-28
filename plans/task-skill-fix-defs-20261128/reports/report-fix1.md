# report-fix1 — FIX-1 统一修复执行体（worktree: task-skill-fix-defs-20261128）

生成：2026-11-28。目录：`/mnt/data/dev/task-planner-skill/tmp/worktrees/task-skill-fix-defs-20261128`。约束：仅 worktree 内；未弱化门控/未伪断言/未删断言（仅 A/B/C 类修正）。

## 1) 基线/证据
- `git diff --name-only master..HEAD`：含多项 `skills/task-planner/*` 改动（见 `git status --short`）；untracked：`selftest-rule-heading.sh`、`selftest-softonly-gate.sh`、`selftest-verify-hooks.sh`。
- `python3 -m py_compile skills/task-planner/scripts/planctl.py`：rc=0。
- `bash -n`：对本轮改动的 `.sh` 抽检未见语法错误。
- 全量：`/tmp/st-fix3.out`（`run-selftests.sh --fresh`）。**最新汇总**：`Total: 124 PASS=96 FAIL=28 (run=124 reused=0)`。`Failed:` 行含 28 项（见下表）。

## 2) FAIL → 处置/归因（28 项）
| 脚本 | 处置 | 归因（一句） | 证据 |
|---|---|---|---|
| selftest-execution-stability | B/未完 | 仍 FAIL=2（T11a/T11b/T13 等 fixture+hook 语义耦合），本轮未做深度修复 | `/tmp/st-fix3.out` 末段；单跑输出 |
| selftest-goal-unit-goal-mode | A（已修） | 标题锚从 `^### 66` 改为 `^### Rule 66`（模式 A）；单跑 PASS，最新全量列表可能为早期片段 | 单跑 PASS 9/0；`selftest-goal-unit-goal-mode.sh` 已改 |
| selftest-interaction | C（未完） | 仍查 SKILL 中 `28.2.1`/思路复述/`歧义/多候选` 旧锚（TI-11/14），需重指向 plan-workflow-details/discipline（模式 C） | 单跑 TI-11,TI-14 FAIL（PASS=12） |
| selftest-iteration-persistence | C（未完） | IP-09/IP-11 仍指向瘦身后已迁移的 SKILL 落点，需重指向 G6/详情文件（模式 C） | 单跑 FAIL=2 |
| selftest-parallel-scheduling | C/待归因 | 多为静态锚守护，`git diff` 含 SKILL/refs 迁移，高概率迁移锚失配（未逐条核对原因） | 全量 Failed 列表 |
| selftest-periodic-review | C/待归因 | 疑迁移锚失配，未展开明细 | 全量 Failed 列表 |
| selftest-plan-history-recall | C/待归因 | 疑迁移锚失配 | 全量 Failed 列表 |
| selftest-plan-tier | C/A/待归因 | 计数/措辞易随迁移变动，未展开明细 | 全量 Failed 列表 |
| selftest-pointer-lifecycle | C/待归因 | 指针守护易随结构迁移失配 | 全量 Failed 列表 |
| selftest-reflect-verify | 待归因 | 未展开明细 | 全量 Failed 列表 |
| selftest-registry | 待归因 | 可能涉及登记行/TSV 与本轮变更对齐（需对照 registry） | 全量 Failed 列表 |
| selftest-reliability-institution | C/待归因 | 规则机构锚迁移常见触发 | 全量 Failed 列表 |
| selftest-report-reviewability | C/待归因 | 文档重组易触发 | 全量 Failed 列表 |
| selftest-requirement-coverage | C/A/待归因 | 纪元/全集口径类守护易受迁移影响（未单独核对） | 全量 Failed 列表 |
| selftest-research-channels | 待归因 | 未展开明细 | 全量 Failed 列表 |
| selftest-root-resolution | 待归因 | 未展开明细 | 全量 Failed 列表 |
| selftest-self-resolution | C/A/待归因 | 路由描述迁移易触发 | 全量 Failed 列表 |
| selftest-session-log | 待归因 | 未展开明细 | 全量 Failed 列表 |
| selftest-skill-collab | C/待归因 | 卫星/协作表述迁移易触发 | 全量 Failed 列表 |
| selftest-split-pattern-library | 待归因 | 未展开明细 | 全量 Failed 列表 |
| selftest-subagent-return | C/待归因 | 子代理返回协议文案迁移可能影响 | 全量 Failed 列表 |
| selftest-summary-readability | C/待归因 | 与 SKILL 结构变更耦合 | 全量 Failed 列表 |
| selftest-task-boundary | C/待归因 | 任务边界/漂移锚可能受本轮迁移影响 | 全量 Failed 列表 |
| selftest-template-lifecycle | 待归因 | 未展开明细 | 全量 Failed 列表 |
| selftest-tier-b | C/A/待归因 | 分档/纪元口径易受迁移影响 | 全量 Failed 列表 |
| selftest-tool-selection | C/待归因 | 工具选择路由迁移可能触发 | 全量 Failed 列表 |
| selftest-veto | 待归因 | 未展开明细 | 全量 Failed 列表 |
| selftest-workflow-orchestration | C/待归因 | 工作流编排描述迁移常见失配 | 全量 Failed 列表 |

## 3) 本轮已完成关键修复（摘录）
- `planctl.py`：`schema` 无 `--plan-dir` 亦可（保留 `sections`/`--section`）；`cmd_add` 重复 id 报错用 `getattr(args,"id",None) or entry.get("id") or entry.get("path")`。`py_compile` OK。
- `selftest-drift-check-subagent.sh`：DCS-04/05/06 重定向至 `references/plan-workflow-details.md`，单跑 21/0。
- `selftest-decision-drift.sh`：DD-16/17 改为卫星路由表锚，单跑 23/0。
- `selftest-decision-grading.sh`：DG-04/11 重定向至 details + CRIT_D，单跑 11 PASS/0 FAIL/1 WARN。
- `selftest-drift-enforcement.sh`：DCE-07 重定向至 details，单跑通过（含 fixture 组）。
- `selftest-error-loop.sh`：EL-08/10 重定向至 details，单跑 16/0。
- `selftest-goal-unit-goal-mode.sh`：G-01 `### Rule 66`，单跑 9/0。

## 4) 最终结果
- `/tmp/st-fix3.out` 最新：`Total: 124 PASS=96 FAIL=28 (run=124 reused=0)`。`python3 -m py_compile .../planctl.py` rc=0。本轮改动 `.sh` 抽检 `bash -n` 无误。

## 5) 归因结论
- 与 `git diff master..HEAD`（大规模 SKILL/refs/plan-workflow-details/规则纪元迁移）强相关、已修或属迁移锚类的：见上表中标注 A/C/“疑迁移锚”的 20+ 项；其中 interaction/iteration-persistence 已定位为 C 且未完，execution-stability 为 B/fixture 类未完。
- **不能**在未逐脚本对照 `master` 复跑证明前，将剩余 25 项全部宣称为 pre-existing baseline；保守为“迁移相关待修/待归因 + 少量需深挖（execution-stability）”。

## 6) 未达成
- 未达 `FAIL ≤ 3 且剩余全归因非任务文件`。仍有 FAIL=28（见表）。report-fix1 已写入本路径。
