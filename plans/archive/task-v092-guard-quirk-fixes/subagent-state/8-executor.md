# S8 Executor Checkpoint — check_phase_order 初值误报修复

- task: task-v092-guard-quirk-fixes Phase 3 / S8
- worktree: /home/terry/task-planner-skill-worktrees/task-v092-guard-quirk-fixes (wt/task-v092-guard-quirk-fixes)
- date: 2026-09-27
- status: complete（commit f3966eb）

## 步骤状态（全部完成）
- [x] S1 读取 check-drift.sh:111-154 check_phase_order + findings S2 3a 节
- [x] S2 确认 S2 夹具构造（/tmp/s2-fixtures/fixture-{a,b,c,d}/plans/task-x/，同模板仅 Status 行不同）
- [x] S3 复刻夹具到 /tmp/s8-fixtures + 修复前基线实跑：a/c 误报 CRITICAL rc=1、b 真报 CRITICAL rc=1、d INFO rc=0（与 S2 取证逐行一致）
- [x] S4 修复 :122：`local prev_status="pending"` → `"none"` + 4 行修复注记（原因/时间/原行为/出处）
- [x] S5 修复后验收：a=INFO PHASE-ORDER rc=0 / b=CRITICAL rc=1 / c=INFO rc=0 / d=INFO rc=0；probe-e(pending,pending,complete)=CRITICAL rc=1（真越级报警保持）
- [x] S6 `git diff HEAD~1 --stat` 仅 check-drift.sh（+5/-1）；提交 f3966eb；worktree status 干净
- [x] S7 findings.md `### S8 修复记录`（:286，修法+四夹具对照表）+ progress.md Phase 3 段新增（S8 一行）
- [x] S8 返回 8 字段

## 修法
check-drift.sh:122 初值 `"pending"`（虚构「虚拟 Phase 0=pending」前驱）→ 中性 `"none"`；:138 判定对中性值天然不命中，误报场景消失；真实前驱 pending→complete 的越级判定路径不变。单 hunk，仅 check_phase_order 函数内，Check 1-3/5 与 check_scope_breach 零触碰（check_scope_breach 留 S9）。

## 证据路径
- /tmp/s8-evidence/baseline-runs.txt（修复前四夹具）
- /tmp/s8-evidence/postfix-runs.txt（修复后四夹具）
- /tmp/s8-evidence/probe-e.txt（真越级探针）
- worktree commit f3966eb（HEAD~1=7bdd6ff，diff +5/-1 仅 check-drift.sh）
- 簿记：plans/task-v092-guard-quirk-fixes/findings.md `### S8 修复记录`；progress.md `### Phase 3` 段 S8 行
