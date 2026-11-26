# stage-advance 审查实物（Rule 119 / Rule 113.10）

## 目标

验证两段式推进机器门在合并证据写入、pending 登记、STAGE-ADVANCE GATE 阻断/放行、SessionStart 只读探针注入四个面可审查、可复现。

## 实物

### smart-merge-back.sh 成功输出（两段式声明计划）

```text
[CLEANUP-DONE] worktree_removed=/repo/tmp/worktrees/task-x branch_deleted=wt/task-x merge_commit=3f9c2ab1234567890abcdef1234567890abcdef
[merge-back] merged(3f9c2ab)
[stage2-pending] task=task-x rc_plan=task-x-rc
[stage2-pending] action: git -C "/repo" worktree add "/repo/tmp/worktrees/task-x-rc" -b "wt/task-x-rc" master && bash "/repo/skills/task-planner/scripts/init-session.sh" "/repo/plans/task-x-rc"
```

### plan-state.json 片段（merge_back 落盘）

```json
{
  "task_id": "task-x",
  "tags": ["rootcause-followup:task-x", "followup-of:task-x"],
  "isolation": {
    "conflict": "none",
    "path": "/repo/tmp/worktrees/task-x",
    "branch": "wt/task-x",
    "merge_back": "merged(3f9c2ab)"
  }
}
```

### STAGE-ADVANCE GATE 阻断输出

```text
[stage-advance] FAIL 两段式已合并但阶段2未创建（无 task-x-rc 计划 / 无 N/A 豁免）
[stage-advance] 修复: 创建 plans/task-x-rc 计划并完成阶段2深挖，或在 findings/tags 登记 [rootcause-followup:N/A] 豁免后重跑
```

### SessionStart 只读探针输出（未消费 followup-of）

```text
[stage2-pending] 检测到未消费的两段式 followup（只读探针，不自动建计划/不切分支）:
- task=task-x rc_plan=task-x-rc
  action: git -C "/repo" worktree add "/repo/tmp/worktrees/task-x-rc" -b "wt/task-x-rc" master && bash "/repo/skills/task-planner/scripts/init-session.sh" "/repo/plans/task-x-rc"
```

## 审查命令（C-A1..C-A4）

| ID | 命令 | 预期 |
|---|---|---|
| C-A1 | 构造计划 task-x（tags 含 `rootcause-followup:task-x`，`isolation.merge_back="merged(abc1234)"`，plans 根无 `task-x-rc/`），运行 `bash skills/task-planner/scripts/check-complete.sh <plan-dir>` | exit 1，输出含 `[stage-advance] FAIL` 与 `task-x` |
| C-A2 | 在同 plans 根创建 `task-x-rc/`（含最小 plan-state.json），重跑 C-A1 命令 | `[stage-advance] FAIL` 消失，出现 `[stage-advance] OK` 或门放行 |
| C-A3 | 去掉 `task-x-rc/`，在 `findings.md` 追加 `[rootcause-followup:N/A] 无需阶段2`，重跑 C-A1 命令 | `[stage-advance] FAIL` 消失，出现 `[stage-advance] SKIPPED` 或门放行 |
| C-A4 | 备份 `check-complete.sh`，删除含 `[stage-advance] marker` 的标记行并把 `[stage-advance] FAIL` 改为失效字样，重跑 C-A1 夹具 | exit 不为 1 或输出不含 `[stage-advance] FAIL`（证明门可被 mutation 证伪）；恢复备份后 C-A1 再次 FAIL |

## 已知边界

- `smart-merge-back.sh` 仅在 merge+cleanup 成功路径写 `merge_back`；merge 冲突/失败路径不写，避免伪证据。
- pending 登记以 `followup-of:<task-id>` tag + `.tags-index.json` 为准；SessionStart 探针只读，不自动创建 `-rc` 计划、不切分支、不改状态。
- N/A 豁免为显式信号（`[rootcause-followup:N/A]`）；有 N/A 且无 PASS/tag 时跳过 pending 登记；普通计划无两段式声明不受影响。
- 真实 `smart-merge-back.sh` 入参契约较重（需要真实 git worktree + 合并场景）；自测 TC-01 在沙箱真仓中按契约运行，若环境不满足应诚实报告降级原因。
