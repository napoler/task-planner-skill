# S7 任务书：worktree 冲突补救 SOP（用户缺陷①②）

## 1. 背景
用户投诉：明明要求默认 worktree，并行开发中仍多会话争夺写同一文件；发现同写冲突后，明明可用 worktree 隔离先改后合并，实际却没走这条补救路径。本单元在 worktree 隔离指南里补一条**事后补救 SOP**。

## 2. 目标文件（1 个，绝对路径）
/mnt/data/dev/task-planner-skill/skills/task-planner/references/worktree-isolation.md
现有结构：§1 冲突分析 / §2 决策矩阵 / §3 路径规范 / §4 生命周期 / §4 合并回合约 / §4.5 返工找回 / §4.6 方向止损 / §5 反模式 / §6 并行同落点冲突与排队续跑（6.1 盘点 / 6.2 STOP 排队 / 6.3 协调态提交）。

## 3. 精确改动
在 §6 末尾（6.3 协调态提交纪律之后）新增一小节：
```
### 6.4 同写冲突检出后的补救性隔离（用户缺陷①②，2026-11-23）
**触发**：check-conflicts.sh 或 PreToolUse 检出另一会话正在写同一受管文件；或发现两会话已在主树同写。
**禁止**：仅"记录冲突、延后到合并期"后继续在主树直接写（这是用户投诉的错误路径）。
**补救四步**：① 立即补建 worktree 隔离后续改动（路径/命名按 §3）；② 将主树该文件的未提交改动迁移到隔离分支（git stash 或手工复制后 git restore 主树，按 §4.5 找回纪律）；③ 后续所有改动在 worktree 内进行；④ 完成后用 smart-merge-back.sh 合并回主树（按 §4 合并回合约）。
**锚点**：`同写冲突补救`（供 grep / 执行体定位）。
```
（措辞可按文件既有风格微调，但四步骤与锚点 `同写冲突补救` 必须保留。）

## 4. 硬约束
- 只改这 1 个文件；不新增脚本、不改 check-conflicts.sh / smart-merge-back.sh（它们只在 SOP 文本中被引用）。
- 用 Edit 精确插入；写后 Read 回读 §6.4 确认无吞锚（Rule 106.1a）。
- 新增 ≤12 行。

## 5. 验收
- `grep -n '同写冲突补救\|补建 worktree\|smart-merge-back' <file>` 命中新小节。
- Read 回读 §6 结构完整，§6.1-6.3 未被覆盖。

## 6. 返回契约（8 字段）
status / acceptance / files / evidence（命令+原始输出行）/ checkpoint（写完整记录到 /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S7-conflict-recovery.md，目录已存在）/ findings_written / blockers / confidence
