# fix-f2a (C-3/C-6) 修复回执

- status: done
- goal: 修复 C-3（规则归属枚举回退为 7 卫星，去除 plan-template-advisor）与 C-6（install-stub.sh 注释计数 7→8 与数组实况一致），仅限指定 2 文件，worktree 内最小改动。
- conclusions:
  - C-3: `skills/task-planner/references/critical-rules.md:178` 建制段「其余规则归 8 个既有卫星」回退为「7 个既有卫星」，名单移除 `plan-template-advisor`；:201 路由索引 advisor 行保留。
  - C-6: `skills/task-planner/lib/install-stub.sh:40` 注释「rsync 的 7 个」改为「rsync 的 8 个」；`SATELLITE_SKILLS` 数组未改动。
- evidence:
  - `grep -c 'plan-template-advisor' skills/task-planner/references/critical-rules.md` → `1`（仅 :201 路由索引行）。
  - `nl -ba .../critical-rules.md | sed -n '176,182p'`：:178 含「7 个既有卫星」且名单无 advisor。
  - `grep -n '8 个' skills/task-planner/lib/install-stub.sh` → `40:... 只登记 install-stub 显式 rsync 的 8 个`。
  - `git diff --unified=1 -- skills/task-planner/references/critical-rules.md skills/task-planner/lib/install-stub.sh`：仅 :178 枚举行文字与 :40 注释数字两处删除/新增，数组行未变。
- acceptance:
  - C-3: PASS（`grep -c 'plan-template-advisor' critical-rules.md = 1` 仅路由索引行；:178 恢复为「7 个既有卫星」且名单不含 advisor；git diff 删除行仅该枚举行）。
  - C-6: PASS（`grep -n '8 个'` 命中注释 :40；SATELLITE_SKILLS 数组行不变）。
  - 约束遵守: PASS（仅改上述 2 文件；未碰 `tmp/worktrees/task-clause-generalize-20261115`；未改其他文件）。
- confidence: high（改动为定点文本替换，所有验收命令与 diff 证据已逐项核对）。
- issues: 无。未执行 selftest/回归（本批次为定点文本修复，回归由 P3 后续单元按计划执行）。
- checkpoint: /mnt/data/dev/task-planner-skill/plans/task-tpl-sediment-20261115/subagent-state/fix-f2a.md
- handoff: worktree=`/mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115`（分支 `wt/task-tpl-sediment-20261115`）内两处修复已落盘、未提交；可由主进程继续纳入后续 commit/复检流程。
