# 008-code-assistant-s5 — sync-todos.sh / resolve-plan-dir.sh archive 跳过适配（Phase 4 S5）

agent: Code Assistant | 任务: task-v170 Phase 4 S5 (parallel-group g-wire) | worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans

## 时间戳里程碑

- [2026-10-12 00:4x] T1a Edit sync-todos.sh: forward_sync find（原 L152）追加 `-not -path "*/archive/*"` + Rule 45 注释块（现 L136-142 注释、L158 find 行）；write_index L201(-maxdepth 2 现 L207) 零改动
- [2026-10-12 00:4x] T1b Edit resolve-plan-dir.sh: mtime glob 循环（L121 `for d in "${PLAN_ROOT}"/*/`）内 `slug_is_valid` 前插入 `[ "$name" = "archive" ] && continue` 防御跳过 + Rule 45 注释（现约 L125-131）
- [2026-10-12 00:4x] T2 bash -n 两脚本均通过；worktree git status 仅目标二文件 M（另有 SKILL.md/set-active-plan.sh 属其他 S-unit 已改文件，未触碰）
- [2026-10-12 00:4x] T3 fixture 实跑（/tmp mktemp 根，已清理）全部通过
- [2026-10-12 00:50] T5 commit 29c968a（2 files, +13/-1），index.lock 一次通过；工作树余 SKILL.md/set-active-plan.sh 为其他 S-unit 产物未并入（授权范围仅二脚本）

## 验收逐条

- [x] AC1 forward_sync: `find ... -not -path "*/archive/*"`（findings §6 L152 形态修复）；fixture 根（task-a 活跃 + archive/task-b）实跑 forward_sync human/json 均只出 task-a 两 phase、零 task-b；write_index 原样 -maxdepth 2 未动，fixture INDEX.md `grep -c task-b` = 0，task-a 行在 L10/L13
- [x] AC2 resolve-plan-dir: 直测防御分支——构造 `plans/archive/task_plan.md`（直接子目录形态，"archive" 通过 slug_is_valid，旧行为会被 mtime 兜底选中）实跑 stdout 空 = archive 未被解析；真实形态（archive/<id>/task_plan.md 深度 3）glob `*/` 天然不命中，双保险
- [x] AC3 bash -n 双脚本通过；`--help` 输出与原版逐行一致；Rule 45 注释（Why=归档后 archive 子目录不得被扫入索引/活跃解析）已附

## 负结果核查（无冲突）

- 检查依赖: lib/plan-parse.sh（sync-todos.sh L18-20 source）本 S-unit 未改；resolve-plan-dir.sh 零 source 依赖
- 未触碰: 二文件外全部文件（set-active-plan.sh/SKILL.md 的 M 状态为 g-wire 其他 S-unit 产物）；fixture 全部 /tmp 临时根，worktree plans/ 与主仓 plans/ 零实跑；config.json 未改
- 排除风险: `-not -path "*/archive/*"` 不匹配 find 起始路径本身（起始目录非 archive 子项）→ 根目录在途任务不受影响（fixture task-a 实跑实证）；INDEX.md 写在 plans_dir 根、不受 archive 过滤影响

## 最终结论（= 返回 §7 同块）

status: done
acceptance: 3/3 pass
files: /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans/skills/task-planner/scripts/sync-todos.sh(+8/-1), /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans/skills/task-planner/scripts/resolve-plan-dir.sh(+6/-0)
evidence: sync-todos.sh:158 find `-not -path "*/archive/*"`→fixture forward_sync 零 archive 输出、INDEX grep -c task-b=0；resolve-plan-dir.sh:129 `[ "$name" = "archive" ] && continue`→plans/archive/task_plan.md 直测 stdout 空；bash -n 双 OK；commit 29c968a（2 files +13/-1）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/subagent-state/008-code-assistant-s5.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
