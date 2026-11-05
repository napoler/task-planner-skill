# 05 S4 — selftest-file-disposal.sh + registry.tsv 登记（task-trashcan-20261105）

## 状态
complete

## 结论摘要
- 新建 `skills/task-planner/scripts/selftest-file-disposal.sh`（FD-01..06，t/td 包装器+PASS/FAIL/Total+exit，`SCRIPT_DIR` 相对推导，禁硬编码绝对路径；只读静态断言）。
- FD-01 锚按盘上实际文本对齐为 `100.6 垃圾桶机制`（文件实为 `**100.6 垃圾桶机制（...）**`，`grep -qF '100.6 垃圾桶机制'` 命中；任务书表述的 `100.6 **垃圾桶机制` 与实文不一致，按锚可验证性落地并在此记录）。
- FD-06 负断言修复 `grep -c ... || echo 0` 双输出陷阱（0 命中时 grep exit 1 触发 `||` 追加 0 导致变量含换行）；改为 `var="$(grep -c ...)" || var=0`。
- `selftest-registry.tsv` 追加 1 行（4 列，结构对齐既有行）。

## 验收证据
1. `bash <worktree>/skills/task-planner/scripts/selftest-file-disposal.sh` → 全绿  
   - `[PASS] FD-01..FD-06`（FD-04b got=2，FD-06 sum=0 image=0 video=0 media=0）  
   - `Total: 8  PASS=8  FAIL=0`，exit 0
2. `grep -c "selftest-file-disposal" <worktree>/skills/task-planner/scripts/selftest-registry.tsv` → `1`
3. `git -C <worktree> status --short`：  
   - `M`（PG1 既有）：`.gitignore`、`skills/media-planner/references/critical-rules-media.md`、`skills/task-discipline/references/critical-rules-discipline.md`、`skills/task-planner/templates/deprecated.md`、`skills/task-planner/templates/variant/image-type.md`、`skills/task-planner/templates/variant/video-type.md`  
   - **S4 本单元**：`?? skills/task-planner/scripts/selftest-file-disposal.sh`（新建），` M skills/task-planner/scripts/selftest-registry.tsv`（追加登记行，+1）

## 修改文件清单（S4 范围）
- `skills/task-planner/scripts/selftest-file-disposal.sh` — **新建**（+约 95 行，FD-01..06 断言；chmod +x）
- `skills/task-planner/scripts/selftest-registry.tsv` — **修改**（+1 行，selftest-file-disposal 登记）

## 未完成面/风险
- FD-01 锚与任务书字面（`100.6 **垃圾桶机制` 含 `**`）不完全一致；当前以盘上真实锚 `100.6 垃圾桶机制` 断言。若后续 S1 文本调整锚形态需同步 selftest（低风险，锚语义稳定）。
- registry.tsv 追加行的“修改”在 `git diff --stat` 中与 PG1 基线混显；S4 实际增量仅尾行 +1，可用 `git diff -- skills/task-planner/scripts/selftest-registry.tsv` 复核。
- 未运行 worktree 全量 selftests（超出本单元 scope）；FD 断言为只读静态、与既有套件隔离，冲突风险低。

## 检查点路径
- `/mnt/data/dev/task-planner-skill/plans/task-trashcan-20261105/subagent-state/05-s4-selftest.md`

## 下次动作建议
- 由上游/集成者复核 registry 行与 FD-01 锚表述是否需与任务书统一措辞（必要时微调锚或任务书描述，不改判定语义）。
- 合入前可选跑 `bash <worktree>/skills/task-planner/scripts/run-selftests.sh` 或 registry 相关 selftest 做回归确认（若流程要求）。
