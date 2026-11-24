# S7 Checkpoint: worktree 同写冲突补救 SOP

## status
done

## acceptance
- [x] 在 `worktree-isolation.md` §6 末尾新增 §6.4「同写冲突检出后的补救性隔离」。
- [x] 保留锚点 `同写冲突补救`，含触发/禁止/补救四步。
- [x] 明确禁止“仅记录冲突、延后到合并期后继续在主树直接写”。
- [x] 四步引用 §3、§4.5、smart-merge-back.sh、§4 合并回合约。
- [x] 仅改 1 个文件，新增 7 行（<=12），未改脚本。
- [x] 写后 Read 回读 §6.1-6.4 结构完整，无吞锚。

## files
- `/mnt/data/dev/task-planner-skill/skills/task-planner/references/worktree-isolation.md` (edited: appended §6.4 at lines 189-194)

## evidence
Command:
```bash
cd /mnt/data/dev/task-planner-skill && grep -n '同写冲突补救\|补建 worktree\|smart-merge-back' skills/task-planner/references/worktree-isolation.md
```
Output:
```text
45:- 子目录名 = task-id,不带 `wt-` 前缀(basename 语义不变,smart-merge-back.sh/check-conflicts.sh 的 basename=task-id 兼容逻辑不受影响)
86:**执行期不打断原则（P0，对齐用户裁决）**：worktree 内执行**不因并行开发/其他在途 plan 的 Rule 23 同域冲突（`[conflict]` 注入、信号①-⑤、scope 重叠提示）而暂停或向用户发起 scope/是否继续确认**——冲突仅作记录，**统一延后至 ④ 合并回阶段**由 `smart-merge-back.sh` V3/V5/V6 与 Rule 101.2 解决。worktree 文件隔离 + ①-备份 保证执行稳定；冲突收口属于合并义务，不属于执行期阻塞。
92:> **机制化入口（task-v064）**：`bash <skill>/scripts/smart-merge-back.sh <worktree-path> [--deploy]` 自动执行本合约第 2/3 条预检 + 已合并检测（ALREADY_MERGED——另一会话已合并时跳过转簿记补全）+ --no-ff 合并；V1-V6 判定与退出码 2-8 见脚本头注释（6 = DEPLOY_DRIFT，部署位不齐时可能在合并已成功后出现）。下方人工流程保留为逃生路径（脚本退出码非 0 时按失败处理人工介入）。
193:**补救四步**：① 立即补建 worktree 隔离后续改动（路径/命名按 §3）；② 将主树该文件的未提交改动迁移到隔离分支（git stash 或手工复制后 git restore 主树，按 §4.5 找回纪律）；③ 后续所有改动在 worktree 内进行；④ 完成后用 smart-merge-back.sh 合并回主树（按 §4 合并回合约）。
194:**锚点**：`同写冲突补救`（供 grep / 执行体定位）。
```

Read-back (offset 180, limit 30) confirmed §6.3 intact and §6.4 present with all required steps and anchor.

## checkpoint
- `/mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S7-conflict-recovery.md`

## findings_written
- `/mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S7-conflict-recovery.md`

## blockers
- none

## confidence
- high
