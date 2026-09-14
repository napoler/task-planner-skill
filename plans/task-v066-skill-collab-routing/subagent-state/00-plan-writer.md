# Checkpoint: 00-plan-writer (task-v066-skill-collab-routing)

- **time**: 2026-09-13
- **agent**: plan-writer
- **status**: done
- **产出**: 覆盖写入 `/mnt/data/dev/task-planner-skill/plans/task-v066-skill-collab-routing/task_plan.md`（formal plan, 替换 stub）

## Phase 列表（5 Phase）
| Phase | 标题 | Executor | Status |
|-------|------|----------|--------|
| 1 | 调研 — 三族技能画像 + 现有协同条款盘点 | explore（mini）, S-unit S1 | in_progress |
| 2 | 机制设计 — 协同路由矩阵 + 22.3.3 升级阶梯 + 移交/回填合约 | 主进程（例外② 计划系统文件维护 + 调度规划设计本职, Rule 25.3 白名单） | pending |
| 3 | 实现 — worktree 内串行派发 S1-S4（Rule 21.4） | executor（sonnet-1）, 4 S-units | pending |
| 4 | 验证 — 全量 selftest + verify + 跨文件一致性 + Code Review Gate | code-runner-agent（mini + 主进程机械验证白名单③）, 2 S-units | pending |
| 5 | 合并部署交付 — smart-merge-back --deploy + 清理 + 交付报告 | 主进程（例外①② Rule 25.3 白名单） | pending |

## 关键数字
- **VC 条目**: 7（VC-1 四要素 reference / VC-2 SKILL.md 协同段 / VC-3 22.3.3 无冲突 / VC-4 键+selftest 0 fail / VC-5 跨文件一致 / VC-6 合并+9 位 diff=0 / VC-7 Code Review APPROVED）
- **S-unit**: 8（Phase 1:1 + Phase 3:4 + Phase 4:3? 实际 Phase1 S1 / Phase3 S1-S4 / Phase4 S1-S2 = 7 个派发单元）
- **task_plan.md 行数**: 393
- **FMEA 高风险行（RPN>100）**: 3（Phase 3 超 500 行 RPN150 / S4 selftest 冲突 RPN144 / Phase 5 diff≠0 RPN105）
- **隔离决策**: worktree=/home/terry/task-planner-skill-worktrees/task-v066-skill-collab-routing, branch=wt/task-v066-skill-collab-routing, merge_back=pending, conflict_scan=safe

## 校验
- `bash skills/task-planner/scripts/check-complete.sh <task_plan.md>`: 机械门全过（Rule 27.3 porcelain clean / 3-File Gate 过 / Batch Report 不适用 chain_mode=single）, exit 1 仅为「0/5 phases complete, session should not end yet」预期提示
- 已同步回填 findings.md（Requirements + 基线勘察 4 条证据）与 progress.md（Session 段 + Phase 1 段）使 3-File Gate 通过

## 注意事项（交执行期）
1. Phase 1 开工前确认 worktree 已建（`git -C /mnt/data/dev/task-planner-skill worktree list` 未见本任务条目 → 需 `git worktree add /home/terry/task-planner-skill-worktrees/task-v066-skill-collab-routing -b wt/task-v066-skill-collab-routing master`；HOME 下目录目前为空）
2. S4 前必须 grep 既有 selftest/smoke 对「五档全序 / STOP 前穷尽」的断言（Key Question 3）
3. 部署一律定向 cp -rL + diff -r, 禁 sync-companion 拉回（反向陷阱）
