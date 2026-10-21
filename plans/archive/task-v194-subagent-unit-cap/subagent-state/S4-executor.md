# S4-executor 检查点（task-v194-subagent-unit-cap）

status: done

## 任务
证明前序单元落地的三条纯增量条款（task-dispatch Rule 46.6 / media-planner Rule 47.1 数值上限 / plan-research-router Rule 75.8）在 worktree 内零回归。

## 计划（步骤）
1. 全量回归 `bash skills/task-planner/scripts/run-selftests.sh --fresh`（600s 上限）
2. FAIL=0 → 步骤 5；FAIL>0 → 逐脚本根因分类（本任务引入 / pre-existing / unconfirmed）
3. 最小修复（仅改 selftest-*.sh 既有断言锚措辞，禁删禁增断言，禁改 check-*.sh/config.json）
4. 修复后复跑全量，最多 3 轮（Rule 57：轮次+命令+结果+关键输出摘要落盘）
5. 终态自验：全量 exit=0（或仅剩 pre-existing 失败并逐一登记 master 对照证据）

## 环境事实
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v194-subagent-unit-cap
- branch: wt/task-v194-subagent-unit-cap
- 已改 3 文件（git status）：
  - M skills/media-planner/references/critical-rules-media.md
  - M skills/plan-research-router/references/critical-rules-research.md
  - M skills/task-dispatch/references/critical-rules-dispatch.md
- selftest-*.sh 脚本总数: 92
- selftest_heavy_concurrent default=off（config.json）→ 全串行

## 轮次记录

### Round 1（基线全量）
- 命令: `bash skills/task-planner/scripts/run-selftests.sh --fresh`
- 结果原文: `Total: 92 PASS=91 FAIL=1 (run=92 reused=0)` / `Failed: selftest-dispatch-grain`；exit=1
- 失败清单: selftest-dispatch-grain (rc=1)
- 定位: 单跑输出 `GR-01 FAIL ^46. 行数=6 (期望 5)`，`Total: 10 PASS=9 FAIL=1`
- 分类: **(a) 本任务引入**。GR-01 断言 `grep -c '^46\.'` = 5（46.1..46.5）；本次新增 `46.6 **单子代理生产单元上限表` 行使计数变 6。
- master 对照证据: `git stash push`（3 文件）→ 重跑 `selftest-dispatch-grain.sh` → `GR-01 PASS critical-rules-dispatch.md 46.1..46.5 共 5 条` / `Total: 10 PASS=10 FAIL=0` → `git stash pop` 成功，`git status` 恢复 3 个已改文件。
- 修复动作: `selftest-dispatch-grain.sh` GR-01 计数阈值 5→6（file:86 注释 + file:88 断言 + file:4/16 头注释同步）；仅改锚措辞/阈值，未增删断言。
- 复跑单脚本: `GR-01 PASS critical-rules-dispatch.md 46.1..46.6 共 6 条` / `Total: 10 PASS=10 FAIL=0` / RC=0

### Round 2（修复后全量）
- 命令: `bash skills/task-planner/scripts/run-selftests.sh --fresh`
- 结果原文: `Total: 92 PASS=91 FAIL=1 (run=92 reused=0)` / `Failed: selftest-final-gate-hash`；exit=1
- 失败清单: selftest-final-gate-hash (rc=1)
- 定位: 单跑 3 次 + 计时不间断 5 次，全部 `PASS=22 FAIL=0` rc=0（每次 ~22s）；Round 1 同脚本 `[run] selftest-final-gate-hash (rc=0 PASS=22 FAIL=0)`
- 分类: **(c) unconfirmed / 瞬态抖动**。证据：① 带本任务 3 文件改动单跑 8/8 全绿；② Round 1 全量该脚本 PASS；③ 脚本沙箱用 mktemp 随机目录 + trap 清理，STATE_FILE 按随机 PLAN_DIR 哈希命名（无跨运行碰撞）；④ 无 disk/mem 压力（/mnt/data 91% avail 9.1G，mem avail 33G）。无法复现，未定位到确定性根因，禁止猜 → 登记 unconfirmed，不修。
- 修复动作: 无（非本任务引入，且不可复现）

### Round 3（终态全量）
- 命令: `bash skills/task-planner/scripts/run-selftests.sh --fresh`
- 结果原文: `Total: 92 PASS=92 FAIL=0 (run=92 reused=0)`；exit=0
- 失败清单: 无
- 结论: 零回归达成

## 最终汇总
- 全量回归 3 轮：R1 FAIL=1(dispatch-grain) → 修复 → R2 FAIL=1(final-gate-hash, 瞬态) → R3 FAIL=0
- 终态: `Total: 92 PASS=92 FAIL=0`，exit=0
- 唯一修复: `skills/task-planner/scripts/selftest-dispatch-grain.sh` GR-01 计数阈值 5→6（46.1..46.5 → 46.1..46.6），仅改锚措辞/阈值，未增删断言
- 修改文件（worktree 内）:
  - M skills/media-planner/references/critical-rules-media.md（前序单元 47.1 数值上限，非本 executor 改）
  - M skills/plan-research-router/references/critical-rules-research.md（前序单元 75.8，非本 executor 改）
  - M skills/task-dispatch/references/critical-rules-dispatch.md（前序单元 46.6，非本 executor 改）
  - M skills/task-planner/scripts/selftest-dispatch-grain.sh（本 executor 最小修复）
- 未触碰: check-*.sh 守卫脚本、config.json、主仓、其他 worktree；无 git commit/push/checkout/merge
- stash: 本 executor 的 stash 已 pop（Dropped refs/stash@{0} (857c103f...)）；`git stash list` 仅剩一条 pre-existing `WIP on master: d806d05`（非本任务，未触碰）
- 负结果: 未发现其他失败；排除了「本任务引入的断言锚漂移」以外的风险（final-gate-hash 抖动已用 8 次单跑 + R1/R3 全量对照排除确定性回归）
- status: done

## 最终汇总
（待填）
