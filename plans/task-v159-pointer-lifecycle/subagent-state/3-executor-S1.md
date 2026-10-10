# Checkpoint — 指针单元（set-active-plan.sh 四修点）

> 执行体：executor（sonnet-1）
> 日期：2026-10-09
> 组域：p3-core
> 目标文件：skills/task-planner/scripts/set-active-plan.sh（worktree: v159-pointer-lifecycle）

## 任务摘要

按 design-pointer-fix.md F1/F2/F3/F4 逐条实现 set-active-plan.sh 四修点：
- F4（先做，最小）：set 分支 ROOT 默认 $PWD，修正计划目录内运行误报
- F1：gc 分支新增全局指针生命周期（dead-ref + completed-ttl → 置空）
- F2：gc 分支新增哨兵-side 缺口巡检（advisory 只报告）
- F3：side 写入所有权守卫（claimant in_progress → 拒绝 trample + --force 覆盖）

## F1-F4 落位清单

| 修点 | 位置（worktree 脚本行区间） | 实现摘要 |
|------|--------------------------|---------|
| F4 | ~58-66 | ROOT="${positional[1]:-$PWD}"；补充：$PWD 本身为计划目录时 ROOT 取上上级 |
| F1 | gc 分支（exit 0 前） | 全局指针非空时检查：目标目录缺失=dead-ref；Status=complete 且 mtime>24h=completed-ttl；命中则 : > 置空 + 输出 stale 行 |
| F2 | gc 分支（F1 后） | 遍历 .plan_required_side/*.plan_required（mtime<24h），对应 side 指针缺失→输出巡检行（只报告） |
| F3 | set 分支（mkdir 后 atomic_write 前） | 扫 plans/*/.session-owner 找 sess<SID> 声明；claimant in_progress → 跳过写入+WARN；--force 覆盖；fail-open 仅提示 |

## 验收测试结果

| 项 | 命令/夹具 | 结果 |
|----|---------|------|
| bash -n | `bash -n scripts/set-active-plan.sh` | rc=0 PASS |
| F4 回归 | /tmp/f4test/plans/task-x 内 `set task-x --sid testsid159` | rc=0 PASS（原实现 exit 2） |
| F1 dead-ref | /tmp/f1dead：.active_plan=nonexistent-plan → gc | 输出 `stale(dead-ref)=nonexistent-plan -> 已置空`；.active_plan 置空 PASS |
| F1 completed-ttl | /tmp/f1ttl：task-x Status=complete + .active_plan mtime 25h 前 → gc | 输出 `stale(completed-ttl)=task-x -> 已置空`；.active_plan 置空 PASS |
| F2 巡检 | /tmp/f2test：2 活跃哨兵无 side 指针 → gc | 输出含 abc123def456 和 789xyz000 巡检行 PASS |
| F3 无 --force | /tmp/f3test：task-ownertest owner=sessclaimkey in_progress → set task-y --sid claimkey | 跳过写入+WARN 含 task-ownertest；side 指针不存在 PASS |
| F3 有 --force | 同令加 --force | 写入成功；side 指针=task-y PASS |
| git diff --stat | `git diff --stat master -- skills/task-planner/scripts/set-active-plan.sh` | 仅该文件；87 插入 4 删除 PASS |

## 文件清单

- 改动文件（worktree）：/mnt/data/dev/task-planner-skill-worktrees/v159-pointer-lifecycle/skills/task-planner/scripts/set-active-plan.sh
- checkpoint（主仓）：/mnt/data/dev/task-planner-skill/plans/task-v159-pointer-lifecycle/subagent-state/3-executor-S1.md

## 净改动行数

87 行插入，4 行删除（git diff --stat 实测）

## 自证通过项数

8/8（bash -n + 四修点夹具 + git diff --stat）

## 备注

- F4 原实现（worktree 已有）`ROOT="${positional[1]:-$PWD}"` 在计划目录内运行仍 exit 2（PLAN_ROOT 解析为 $PWD/plans 而非 $PWD/../plans）。补充逻辑：$PWD 本身为计划目录（含 task_plan.md）时 ROOT 取上上级（dirname dirname），使 PLAN_ROOT 正确解析。
- F1/F2/F3 均为纯增量，既有逻辑零删除。
- 所有改点配 Rule 45 What+Why 注释（含日期 2026-10-09 与基线行为说明）。
- knowledge-brief.md 为模板状态（未填充），不影响本单元实现。
