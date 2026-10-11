# [sub:05d-executor] DG-03/PT-15 回归修复 — 检查点

status: done
session: task-v163-proactive-research S-unit 05d
scope: 仅 2 文件各 1 处措辞修正（无 git 操作、无网络）

## 动作
1. DG-03 修复：worktree `skills/task-planner/references/critical-rules.md:974`
   `归因（findings.md [sub:01a-explore] 三空白面实证）` → `归因（findings 盘点段三空白面实证）`
   根因：Rule 72 段界 `sed -n '/^## Rule 72/,$p'` 捕获到 Rule 75 来源段，`[sub:01a-explore]` 的 `:0` 被 DG-03 `:\s?[0-9]+` 命中。
2. PT-15 修复：worktree `skills/task-planner/templates/task_plan.md:175`
   `豁免：plan_tier: mini 任务整体豁免（Rule 38.3 区块白名单同口径）` → `豁免：mini 档任务整体豁免（Rule 38.3 区块白名单同口径）`
   根因：init 缺省复制 general 源（task_plan.md），注释含字面 `plan_tier: mini` 被 PT-15 `grep -q 'plan_tier: mini'` 误判为 mini 档。

## 证据（第一手命令输出）
- 基线：DG `DG-03 FAIL ... 命中=1`（PASS=11 FAIL=1）；PT `PT-15 FAIL init 缺省场景复制源异常`（PASS=31 FAIL=1）
- 修复后：DG `DG-03 PASS: Rule 72 段无行号引用形态` + `Total: PASS=12 FAIL=0 WARN=0` rc=0
- 修复后：PT `PT-15 PASS init 缺省场景=general 源（无 mini 标记）` + `Total: 32 PASS=32 FAIL=0` rc=0
- 残留复核：`grep -c "01a-explore"`=0 / `grep -c "plan_tier: mini"`=0 / `sed -n '/^## Rule 72/,$p' | grep -cE ':\s?[0-9]+'`=0
- 未误伤：PT-16 PASS（mini-lite 模板自身 `plan_tier: mini` 标记仍在）

## 状态
- acceptance: 2/2 pass
- blockers: none
- confidence: HIGH
