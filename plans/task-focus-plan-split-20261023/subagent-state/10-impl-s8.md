# S8 — worktree 全量 selftest 跑批结论

- 任务：task-focus-plan-split-20261023 / Phase 3 / S-unit S8
- 执行目录（worktree）：`/mnt/data/dev/task-planner-skill-worktrees/task-focus-plan-split-20261023`
- worktree HEAD：`3ea1dbc`（Rule 94 落地提交）；跑批前后 `git status --porcelain` 均为空（跑批零副作用）
- 命令（原文）：
  ```
  cd /mnt/data/dev/task-planner-skill-worktrees/task-focus-plan-split-20261023 && bash skills/task-planner/scripts/run-selftests.sh
  ```
- 结果：**exit=1，Total: 92 PASS=91 FAIL=1 (run=92 reused=0)**，耗时 `real 3m27.455s`
- 缓存说明：跑批前核对指纹 `aa8a31a3...ccdccf` 对应缓存命中 `cache_hit=0 cache_miss=92`，即本次为**真实全量执行**（无 reused 粉饰）；全程串行（`selftest_heavy_concurrent.default=off`）

## 判定

**FAIL（1 个脚本失败）** —— 唯一失败为账本配对不变量，非级联破裂。

级联/正文面全部 PASS（证明 Rule 94 六子条 + 全仓级联 1-94 未打破既有纪元锚）：
- `selftest-rule-reserve` PASS=10 FAIL=0
- `selftest-sync-index` PASS=15 FAIL=0
- `selftest-registry` PASS=5 FAIL=0
- `selftest-final-gate-hash` PASS=22 FAIL=0
- `selftest-vc-gate` PASS=11 FAIL=0
- `selftest-tier-consistency` PASS=8 FAIL=0、`selftest-state-consistency` PASS=5 FAIL=0、`selftest-input-consistency` PASS=5 FAIL=0、`selftest-evidence-anchor` PASS=26 FAIL=0
- drift 族全绿：`selftest-check-drift` 7、`selftest-decision-drift` 23、`selftest-drift-check-subagent` 21、`selftest-drift-enforcement` 23

## FAIL 明细（未修复，按契约留主进程决策）

- 脚本：`skills/task-planner/scripts/selftest-rule-reserve-pairing.sh`
- 断言：**PR-02**（reserved 有 landed 的反向配对）
- 输出原文（单跑复现，`RC=1`）：
  ```
  PR-01 PASS landed 无 reserved 的缺失项=46 47 48 49 50 75 全在豁免表 46 47 48 49 50 75 内（历史旁路冻结）
  PR-02 FAIL reserved 无对应 landed（非豁免悬空编号:94；豁免表=57 60 80 82，历史悬空须 land 配对或仲裁作废，不得扩表）
  PR-03 PASS 豁免表自检通过（去重 + 无空格污染 + 元素全为纯数字）
  Total: 3 PASS=2 FAIL=1
  ```
- 数据源（`plans/.rule-reservations.jsonl`，worktree 内）：第 82 行仅 reserved、无 landed 行
  ```
  {"rule":94,"status":"reserved","task_id":"task-focus-plan-split-20261023","ts":"2026-10-23","note":""}
  ```
  末 2 行对照：`{"rule":93,...,"status":"reserved"} / {"rule":93,...,"status":"landed"}`（92/93 均为成对）
- 初步归因（HIGH 置信）：**不是 Rule 94 落地缺陷，是账本 land 步骤尚未执行**。正文确实已落地（`skills/task-discipline/references/critical-rules-discipline.md:610` 起 94.1–94.6 六子条；`skills/task-planner/SKILL.md:174` E 类段指针句；`skills/task-planner/docs/ARCHITECTURE.md:123` 级联 1-94）。而 land 在计划中被显式排到 Phase 4：
  - `task_plan.md:151` `| G6 | 合并归档交付 | merge --no-ff 回 master+land 94+归档+worktree 清理 | ... | Phase 4 | pending |`
  - `task_plan.md:339` `- [ ] 主仓 Read 复验 + rule-reserve land 94`
  - `subagent-state/02-drift-check-p1.md:15` “（VC-4 reserved 半侧；landed 留 Phase 4）”
  - 修复动作 = `rule-reserve.sh land 94 task-focus-plan-split-20261023`（Phase 4 G6 执行，本 S-unit 禁改）
- 主仓同态：`/mnt/data/dev/task-planner-skill/plans/.rule-reservations.jsonl:82` 同为 reserved-only（主仓 HEAD=`2d978e0`），即该 FAIL 在合并前后按同一账本状态可复现，与本跑批环境无关。

## 负结果报告（检查了但未发现问题）

- 检查位置：worktree 全部 92 个 `selftest-*.sh`（runner 汇总行 + 失败脚本单跑复现）；`plans/.rule-reservations.jsonl`（worktree 与主仓两份）；`skills/task-planner/SKILL.md:174`、`skills/task-discipline/references/critical-rules-discipline.md:610`、`docs/ARCHITECTURE.md:123`
- 预期可能破裂但**未发现**：Rule 94 引入导致的纪元锚/编号级联破裂（rule-count、sync-index、registry、final-gate-hash、tier/state/input-consistency、evidence-anchor 全 PASS）；drift 族破裂；豁免表污染（PR-03 PASS）；landed 侧新增缺失（PR-01 PASS，raw_missing 仍仅 46/47/48/49/50/75 全在豁免表）
- 排除项：缓存复用导致的假绿（cache_miss=92 全实跑）；并行模式竞态（本次串行）
- 未做（越界）：未执行 `rule-reserve.sh land 94`、未修改任何 worktree 文件、未改豁免表

## 落盘产物

- 跑批原始日志：`/tmp/s8-selftest.log`（含 92 行逐脚本结果 + `Total:` 行 + `real` 计时 + `EXIT_CODE=1`）
- 本检查点：`/mnt/data/dev/task-planner-skill/plans/task-focus-plan-split-20261023/subagent-state/10-impl-s8.md`
