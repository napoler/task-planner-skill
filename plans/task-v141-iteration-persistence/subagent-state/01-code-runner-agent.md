# Checkpoint 01 — code-runner-agent（Phase 3 全量 selftest 回归）

- 任务: task-v141 迭代测试轮次落盘纪律（Rule 57）— Phase 3 验证与回归
- 执行体: code-runner-agent（mini）
- 时间: 2026-10-06（约 10:05–10:20）; 会话: afd0b28ec78a4e8ca9f0acde60eeaaf7（plan 登记值）
- worktree: `/home/terry/task-planner-skill-worktrees/task-v141`（分支 `wt/task-v141`，基于旧分支 `main`@15a3ecf，非 `master`@afdc7d8）
- 执行目录: `/home/terry/task-planner-skill-worktrees/task-v141/skills/task-planner`

## 1. 执行的命令与结果

| # | 命令（cwd=worktree skills/task-planner） | 结果 |
|---|------|------|
| 1 | `bash scripts/selftest-registry.sh` | exit 0；T01–T05 全 PASS（rows=55 = actual 55） |
| 2 | `bash scripts/selftest-iteration-persistence.sh`（S1） | exit 0；IP-01..18 全 PASS（18/18） |
| 3 | 全量回归：`for s in scripts/selftest-*.sh; do timeout 60 bash "$s"; done`（55 脚本，107s） | **21 exit 0 / 34 exit 1 → 验收「全量 0 FAIL」未达成** |
| 4 | 对照组：master 仓库同一全量套件（54 脚本，114s，读只执行） | 51 exit 0 / 3 exit 1（3 项为 master 既存债务，见 §4） |

原始输出: `/tmp/task-v141-regression/`（55 个 *.out + summary.tsv）、`/tmp/task-v141-regression-master/`（54 个 *.out + summary-all.tsv）；副本已落盘本目录两个 *-summary.tsv。

## 2. worktree 全量结果（55 脚本）

- PASS(exit 0)=21: check-conflicts, check-drift, context-hygiene, delegation, fallback, final-gate-hash(22/22), interaction, **iteration-persistence(18/18)**, lane-advancement, plan-dispatch, reflect-verify, **registry(5/5)**, rescue-chain, rule23-conflict-scan, rule-reserve, self-resolution, skill-modify, smart-merge, sync-index, user-instruction-priority, vc-gate
- FAIL(exit 1)=34: active-plan(14/19), agent-coverage(6/9), ask-default-timeout(9/11), batch-pilot(7/10), capability-persistence(15/20), conclusion-discipline(17/24), dispatch-grain(9/10), dispatch(28/31), error-loop(13/16), execution-honesty(11/14), execution-stability(18/19), fine-grain-steps(10/11), iterative-optimizer(0/8), knowledge-brief(11/16), mechanism-profile(15/19), media-agents(2/10), media-dispatch(7/9), methodology(8/16), plan-tier(17/32), reliability-institution(14/16), requirement-coverage(21/23), requirement-grading(5/7), review-library(5/15), root-resolution(14/17), shared-tracker(9/11), skill-collab(13/25), skill-split(20/41), task-boundary(10/11), template-lifecycle(17/24), template-sense(5/8), tier-b(17/18), tool-selection(8/12), veto(12/13), workflow-orchestration(15/16)

## 3. 失败归因（cross-table: worktree vs master）

- **33/34 为 worktree 独有失败**（同脚本同用例在 master 全 PASS）→ 全部可归因于 **worktree 拷贝不完整/文件版本陈旧**（FAIL 行均为 `No such file or directory`／「缺失」断言）。
- **1/34 为与 master 共享的既存失败**: selftest-requirement-coverage RC-15（'56.' 子句命中=5 应=0）；worktree 额外多出 RC-12（`templates/delivery-summary.md` 缺失）1 条。
- **2 项 worktree 反而优于 master**（master FAIL / worktree PASS）: selftest-registry（master T02 缺登记 `selftest-user-instruction-priority.sh`）、selftest-self-resolution（SR-12 registry 行数漂移）→ Phase 2 的 registry.tsv 更新顺带修复了 master 两处登记债务。
- **Rule 57 相关链路全绿**: 新守护 18/18 + registry 5/5；未发现任何由 Phase 1/2 改动引入的失败。

### 缺失/陈旧文件清单（worktree vs master 根因）

- 整个 skill 卫星缺失（worktree `skills/` 仅 task-drift-guard/task-planner/todo-skill）: iterative-optimizer, plan-collab-router, plan-cost-guard, plan-research-router, plan-resume, plan-template-kit, progress-tracker —— 影响 iterative-optimizer, skill-collab, skill-split, mechanism-profile, media-dispatch, shared-tracker, template-lifecycle 等。
- task-planner 内缺失: `references/{agent-coverage,batch-quality-gate,capability-registry,dispatch-examples,methodology,todo-sync,worktree-isolation}.md`；`templates/{batch_report,delivery-summary,knowledge-brief,shared-tracker,subagent_dispatch}.md` 及 `templates/variant/` 全目录；`companion/`、`review-library/`、`docs/`、`lib/`、`tests/`、`install.sh` 等。
- 陈旧（版本≠master）: `references/{goal-gate,completion-gate}.md`、`templates/{task_plan,progress,findings,notepad-learnings,verification}.md`、根 `README.md/reference.md/examples.md` 及 repo 根 `CLAUDE.md/README_zh.md`。
- 典型失败根因样本: active-plan T08/T12 → `[init] ERROR: knowledge-brief.md missing or empty`（templates/knowledge-brief.md 缺失）；batch-pilot/conclusion-discipline → batch-quality-gate.md 缺失；review-library → review-library/ 目录缺失；workflow-orchestration WF-10 → 4 索引文档 "Rules 1-39/1-45" 合计 2<6（旧版根文档）；dispatch-grain GR-04 → subagent_dispatch.md 缺失。

## 4. master 基线 3 项既存失败（与本任务无关，但影响「0 FAIL」口径）

| 测试 | 失败断言 | 备注 |
|------|---------|------|
| selftest-registry | T02 未登记 `selftest-user-instruction-priority.sh` | **本任务 registry.tsv 已修复**（worktree PASS） |
| selftest-self-resolution | SR-12 registry 总行数 54 应 55=脚本数+表头 | **本任务 registry.tsv 已修复**（worktree PASS） |
| selftest-requirement-coverage | RC-15 `critical-rules.md '56.' 子句命中=5（应=0）` | v140 遗留（Rule 56 已存在但负断言未更新为 '58.'）；v141 未改，两处同 FAIL |

## 5. 结论与建议（供主进程决策）

1. 验收 S1（VC-4）达成；S2「全量 selftest 0 FAIL」**当前 worktree 无法达成**，非 Phase 1/2 质量问题——是 worktree 基座问题：`wt/task-v141` 基于旧 `main`（2026-08-13）而仓库活动分支是 `master`（2026-10-06），Phase 1/2 仅同步了部分文件（task-planner 的 scripts/SKILL/critical-rules 等），references/templates/companion/review-library/卫星/根文档仍为旧版或缺失。
2. **合并危险警告**: 该 worktree 不能按现状提交合并——陈旧文件（goal-gate.md、completion-gate.md、templates/*、README.md 等）若以 worktree 版本入库，会把 master 新版文件回退。
3. 建议之一（推荐）: 以 `master` 重建工作区（或向现有 worktree 补齐缺失文件集，保留 4 个 Phase 1/2 增量: SKILL.md +3/-1 行、critical-rules.md +14 行、selftest-iteration-persistence.sh、selftest-registry.tsv），重跑全量套件；预期届时仅剩 RC-15 一项 v140 遗留债务（如需「0 FAIL」需另行裁决是否顺带修 RC-15 的负断言口径）。
4. 未执行（超出本子任务授权）: 未修复/未同步任何文件；未运行修复后套件；未改动 worktree 任何内容。

## 6. 负结果与验证记录

- 全量回归前后 worktree `git status --porcelain` 哈希一致（800f652a…），55 个测试零工作区污染；未触碰任何其他 worktree 内容。
- 无网络类用例；无超时（全部 <60s，单项最长 17s 为 final-gate-hash）。
- 未验证项：修复后完整环境下的全量套件结果（未执行）；测试为单轮运行，未做重复性复跑（未观察到不稳定迹象）。
- 已排除: Phase 1/2 改动破坏断言（critical-rules 增量 0 删除；SKILL.md 仅 1 行索引更新+3 行新增；SKILL.md 484 行仍在 skill-split ≤490 断言内）；测试脚本与 master 完全同版（diff 一致），排除脚本/用例版本错配。
