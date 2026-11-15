# fix-f1a (F1a: C-1/C-4) — checkpoint

- **task**: `task-tpl-sediment-20261115` 修复批次 F1a（critic C-1/C-4）
- **worktree**: `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115`
- **constraints**: 仅修改 2 文件；未改其他文件；未碰 `tmp/worktrees/task-clause-generalize-20261115`

## 修改摘要

### C-1
- **file**: `skills/plan-template-advisor/SKILL.md:60`（卫星路由段）
- **change**: `（见 findings F2/F3/F9）` → `（init-session.sh 项目级模板发现机制/check-template-type.sh 白名单校验/render_template fail-closed 契约）`，其余文本不变。

### C-4
- **file**: `skills/plan-template-kit/references/critical-rules-template.md:22`（34.8 行）
- **change**: 在 `④**未过门处置**：候选留暂存并登记理由，禁静默丢弃。` 与 `判例=task-tpl-sediment-20261115。` 之间插入（逐字照 clause-drafts.md §1）：`与 34.7 分工：34.7 全自动合约触发生成的候选同样须过本条官方门 G1-G4 方可写入 \`templates/variant/\`（34.5 双闸门=G3 的查重/泛化性输入，非独立入库通道）。`
- **audit**: 34.8 其余文字与 34.7/34.9 零改动；diff 删除行审计=0（仅替换/插入形成的行级替换，无纯删除）。

## 验收实测

| check | command | result |
|---|---|---|
| C-1 `findings F` 计数 = 0 | `grep -c 'findings F' skills/plan-template-advisor/SKILL.md \|\| true` (worktree) | `0` PASS |
| C-4 `非独立入库通道` 计数 = 1 | `grep -c '非独立入库通道' skills/plan-template-kit/references/critical-rules-template.md` (worktree) | `1` PASS |
| 34.8 衔接句位置/结构回读 | `sed -n '22p' skills/plan-template-kit/references/critical-rules-template.md` | 衔接句位于 `禁静默丢弃。` 之后、`判例=task-tpl-sediment-20261115。` 之前 PASS |
| diff 审计 | `git diff --unified=1 -- skills/plan-template-advisor/SKILL.md skills/plan-template-kit/references/critical-rules-template.md` | 仅 2 文件各 1 处替换；无纯删除行 PASS |

## 结论

- C-1: PASS
- C-4: PASS
- status: **PASS** (both targeted fixes applied and verified in worktree)