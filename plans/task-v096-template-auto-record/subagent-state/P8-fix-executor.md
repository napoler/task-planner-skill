# P8-fix-executor checkpoint — task-v096 CR fix-phase

date: 2026-09-29 | workspace: /mnt/data/dev/task-planner-skill-worktrees/task-v096-sense-fix (base master ed8712d)
status: COMPLETE（3 修复步骤 + 5 项验证全过；未做任何 git 写操作，提交留主进程）

## 裁决执行记录
- P1-1/P1-2（同根）: 采用主进程裁决的「产物无 template_type 标记」守卫，未采用 CR 原文建议的来源守卫。
  init-session.sh 两处追加条件各补 `! grep -q 'template_type:' "task_plan.md" 2>/dev/null`，
  unknown 分支既有 `TASK_PLAN_SRC = task_plan.md` 来源守卫保留（双条件同时成立才追加）；
  两分支前各加注释 `# [task-v096 CR-fix] 仅无 template_type 标记的产物才追加（防 mini/known-type 产物被二次标记）`。
- P2: check-complete.sh T3 warn 排除式去掉 `|已沉淀` 无锚定字面量，保留「不沉淀理由+冒号+非空白 /
  沉淀理由+冒号+非空白」双式；行尾注释披露剩余 fail-open 裁量（关键词与冒号间仅空白方排除；带实质内容必命中=登记有效）。

## 改动定位（file:line 以改后行号计）
1. init-session.sh: P2-S1 general 分支条件 ~L284-286（`if [ -z "$TEMPLATE_TYPE" ] && [ -f "task_plan.md" ] && ! grep -q 'template_type:' "task_plan.md"`）
2. init-session.sh: P2-S2 unknown 分支条件 ~L317-320（原条件末尾追加同款 grep 守卫）
3. check-complete.sh: T3 warn 段 ~L568-578（grep -qE 排除式去 `|已沉淀`，新增 CR-fix 注释）
4. selftest-template-sense.sh: 头注 6→8 断言；新增 run_init_tier helper（显式空串占位防 tier 前移落 template_type 位）；
   case-7 mini 负例 / case-8 重跑负例；Total 打印由 6 例升级为 8 例（`$((PASS+FAIL))` 动态计）

## 验证证据（全部实际运行）
a. `bash -n` 三文件 → 3x OK
b. `bash scripts/selftest-template-sense.sh` → Total: 8 PASS=8 FAIL=0 RC=0
   （含新 case-7 "mini 档空类型 → mini-lite 产物带标记, 无感知区块、无 general 注释" PASS、case-8 "bugfix 后空类型重跑 → 产物标记仍 bugfix 且无感知区块" PASS）
c. CR 三例定向复验（mktemp 目录，已清理）:
   - c1 mini: 产物仅 L1 `<!-- template_type: mini-lite -->`，感知区块计 0，general 注释计 0 → P1-1 消除
   - c2 bugfix+空类型重跑: 二次输出 [template-sense] 计 0，标记仍 L1 bugfix，区块计 0 → P1-2 消除
   - c3 假计划含「本项目已沉淀 3 个 variant」+ 感知区块 → check-complete 仍输出 1 条
     `[template-sense] ⚠ 计划含模板感知区块但终验未登记沉淀/不沉淀理由` → 字面量移除后不再被吞（反向验证通过）
d. 回归 4 套件: template-lifecycle Total 18/0 + plan-tier 32/0 + knowledge-brief 16/0 + final-gate-hash PASS=22 FAIL=0
e. `git diff --stat` 仅 3 文件（+57/-6）: check-complete.sh 8± / init-session.sh 14± / selftest-template-sense.sh 41±；`git status --short` 仅 3 M

## 未采用项与理由（负结果登记）
- 未采用 CR 原文建议 `[ "$TASK_PLAN_SRC" = "task_plan.md" ]` 作 P1-1 修复: 主进程裁决标记守卫更彻底（同时覆盖
  unknown+tier=mini 等未知路径）；P2-S2 的既有来源守卫保留作双保险。
- 已知 4 个 variant 模板（diagnostic/publish/research/writing）本体无 `<!-- template_type: X -->` 注释标记：
  其产物仍会被无标记守卫放行=行为与修复前一致（known-type 分支 TEMPLATE_TYPE 非空，P2-S1/P2-S2 均不触发），
  不影响本次两例修复，无需额外处理。
- 「已沉淀」登记路径彻底移除: 裁决定为最小收紧，未提供替代登记词；如后续 34.7 处置登记需要该词面，
  走独立任务（fail-open 裁量已在 check-complete.sh 注释披露）。

## 硬约束遵守
- 仅写 3 文件 + 本检查点；无 git 写操作（无 commit/stash/restore/checkout，仅只读 log/status/diff）；无网络；临时产物 mktemp+rm -rf 清理。

## 恢复点（如需重做）
- 若主进程 merge 后发现回归: 从 `git diff ed8712d` 取 3 文件 patch 重放即可；验证入口=验证 b/c 两条命令。
