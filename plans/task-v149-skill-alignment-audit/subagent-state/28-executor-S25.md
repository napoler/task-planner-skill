# S25 CR 修复批B 检查点（executor，worktree 内写）

- 执行体：executor（sonnet-1）
- 工作区：/mnt/data/dev/task-planner-skill-worktrees/task-v149-skill-alignment-audit
- 需求锚：R3「修复其中的问题、错误以及不合理的地方」
- 修改文件：2 个（selftest-requirement-coverage.sh + lib/install-companion.sh）
- 修改项：M-5（RC-15 块三值统一到 ^66）+ L-1（注释箭头左值拼写）

## 修改摘要

### M-5: selftest-requirement-coverage.sh RC-15 块（:165-169）
- 行 165：`grep -c '^65\.'` → `grep -c '^66\.'`
- 行 166：`负断言对象演进为下一个未用编号 '63.'` → `'66.'`
- 行 167：`行首 '63.' 子条命中数为 0（63 号未被误占）` → `'66.'`（66 号未被误占）
- 行 169：`若 '63.' 出现说明他任务并行插入了 Rule 63` → `'66.'`（Rule 66）
- 代码（行 178-179）已是 `^66\.`，未动
- 历史演进记录（行 170-176）保持不动（历史事实，非本轮演进语境）

### L-1: lib/install-companion.sh:20
- `COMPANION_DIR→COMPANION_DIR` → `COMPAANION_DIR→COMPANION_DIR`

## 自验结果

### 1. bash -n 语法检查
- selftest-requirement-coverage.sh：syntax OK
- install-companion.sh：syntax OK

### 2. selftest 运行
- 命令：`bash skills/task-planner/scripts/selftest-requirement-coverage.sh`
- 结果：Total: 23 PASS=23 FAIL=0

### 3. grep ^65\. 全文件残留检查
- 行 176：`# [2026-10-08 task-v147 第二代级联] '^64.'→'^65.'：Rule 64 已由 task-v148 落地（64.1-64.6），防线前移至 65`
  - 判定：历史演进记录（task-v147 第二代级联），非本轮（task-v149）演进语境，保留
- 行 505：`#      RC-01（≥7）与 RC-15（'^66.'=0，[2026-10-08 task-v149 Rule 65 落地演进] 前移，原 '^65.'=0 task-v147 第二代级联）不受 51.8 影响...`
  - 判定：RC-15 块外描述（行 505 在 RC-15 块外），保留

### 4. RC-15 块内本轮演进语境检查
- 行 165-169 当前描述：已全部改为 ^66 语义，无 ^65. 或 63. 残留
- 行 177（v149 演进行）：已是 ^66 语义，未动
- 行 178-179（代码）：已是 ^66\.，未动

## 结论
- M-5：RC-15 块内本轮演进语境（行 165-169）三值统一到 ^66，无残留
- L-1：注释箭头左值已改为 COMPAANION_DIR（如实记录拼写修正前状态）
- 自验全通过：bash -n OK / selftest FAIL=0 / RC-15 块内本轮演进语境无 ^65. 或 63. 残留
