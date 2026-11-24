# Drift Checkpoint 01-drift-checker

- time: 2026-11-25
- trigger: post-merge drift check (task-planctl-trigger-20261125)
- verdict: **ALIGNED**（含簿记滞后说明，非执行偏移）

## 证据

1. **目标对齐（原话）**：user-session-log.md#2026-11-25 原话要求“定位段…完全没有提及 planctl.py…核心触发完全没有被激活…要求恢复 planctl.py 的核心触发权重”。`git show ebbb42b5 -- skills/task-planner/SKILL.md` 将标题改为 `核心 = planctl.py 驱动的四文件罗盘管理`；定位段新增 `唯一执行引擎与唯一写入口 = scripts/planctl.py`（P0）+ `plan-state.json=唯一权威源` + `四个 MD 派生视图禁手工 Edit/Write`；分流铁律改写为 planctl 子命令映射。保留 selftest 锚 `四文件罗盘的唯一管理域`。→ 正面回应原话，非答非所问。
2. **范围对齐**：`git show --stat ebbb42b5` = `skills/task-planner/SKILL.md | 9 +++++----`、`skills/task-planner/lib/install-stub.sh | 13 +++++++++++++`，2 files, +18/-4。`git show --stat 403bfb78` 为 merge commit，无额外文件改动。未触及 critical-rules/references/scripts/hook/config。符合 R2。
3. **原话对照/语义偏移**：非“加一行注释”缩水——实改定位标题+核心定位段+分流铁律语义，并在 install-stub.sh 注入 `ENGINE_BLOCK`（`核心执行引擎（P0 — 四文件罗盘唯一写入口）`）并写入 4 模板 `${ENGINE_BLOCK}`。亦非“重写整个 SKILL.md”越界扩张（diff 限定定位区+分流铁律段）。语义与原话一致。
4. **计划簿记一致性**：task_plan.md 显示 P1 complete / P2 in_progress / P3 pending；git 证据显示 ebbb42b5 已合并入 master(403bfb78)，worktree 已清理（派发说明）。**簿记滞后待收口**（VC/render/attest/INDEX/outcome 未在计划面翻转），非执行偏移；需主进程按 P3 收口。

## 建议
- 主进程执行 P3：verify/selftest 对账、VC 翻转、render+attest、INDEX/outcome 收口，消除簿记滞后。