# S9 init-session+plan-created.cjs 注释改述材料（executor，2026-10-10）

## 任务（≤2 文件，只动注释行）
按 findings.md [sub:4-executor] 级联清单，改述两个文件中指针旧语义注释。**代码零改动**。

## 文件与目标区段（行号以实施日实测为准）
1. `/mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/skills/task-planner/scripts/init-session.sh`
   - 清单目标：`:719`、`:720`（"不碰/写全局 legacy"）、`:727`（"legacy 全局指针"）
2. `/mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/skills/task-planner/scripts/plan-created.cjs`
   - 清单目标：`:134`（注释"③ legacy plans/.active_plan 指针"）
- 定位命令：`grep -n 'active_plan\|legacy' init-session.sh plan-created.cjs` + 读目标行±5 行

## 改述语义（三点，与 S3 一致）
① 全局指针 `plans/.active_plan` = **工作树内瞬态 fallback**（路径随 `$PWD` 本地化；2026-10-10 task-v164：git rm --cached+.gitignore 同族瞬态）；② 正常路径=side 会话私有指针（权威层）；③ 退役"legacy/移交"旧表述。

## 保留纪律（Rule 45 — 必守）
- 改述处加 `[2026-10-10 task-v164]` 注记（原措辞一句说明）；历史勘误注释禁删
- .sh 禁动 `set -u` 之后任何代码；.cjs 禁动任何 JS 逻辑（require/函数/字符串字面量）；usage 禁改

## 验收（主进程将复跑）
- `grep -c 'task-v164' <两文件>` 各 ≥1
- .sh：`git diff -U0 | 非#行 | grep -c .` = 0 + `bash -n` 过；.cjs：`git diff` 只含注释行 + `node --check` 过
- `grep -nE '全局 legacy|legacy 全局指针' <两文件>` 旧语义清零（历史陈述除外）

## 边界
- 只改两文件注释区；禁动其他文件；禁 git add/commit
