# S7 userpromptsubmit+posttooluse 注释改述材料（executor，2026-10-10）

## 任务（≤2 文件，只动 `#` 注释行）
按 findings.md [sub:4-executor] 级联清单，改述两个 hook 脚本注释中的指针旧语义。**代码零改动**（diff 只允许 `#` 行变化）。

## 文件与目标区段（行号以实施日实测为准）
1. `/mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/skills/task-planner/scripts/zcode-userpromptsubmit.sh`
   - 清单目标：`:23` 注释"并行会话不再互顶全局 legacy 指针"（旧语义）
2. `/mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/skills/task-planner/scripts/zcode-posttooluse.sh`
   - 清单目标：`:43-44` 注释块"不再被全局 legacy 指针互顶"（旧语义）
- 定位命令：`grep -n 'active_plan' zcode-userpromptsubmit.sh zcode-posttooluse.sh` + 读目标行±5 行

## 改述语义（三点，与 S3 一致）
① 全局指针 `plans/.active_plan` = **工作树内瞬态 fallback**（路径随 `$PWD` 本地化；2026-10-10 task-v164：git rm --cached+.gitignore 与 .active_plan_side/ 同族）；② 正常路径=side 会话私有指针（权威层，2026-10-07 fix-pointer-race 后）；③ 退役"互顶全局 legacy 指针"叙事（该叙事=并行可见漂移来源）。

## 保留纪律（Rule 45 — 必守）
- 改述处加 `[2026-10-10 task-v164]` 注记（原措辞一句说明）；历史勘误注释禁删
- 禁动 `set -u` 之后任何代码、变量、函数、usage；禁改 hook 逻辑

## 验收（主进程将复跑）
- `grep -c 'task-v164' <两脚本>` 各 ≥1
- `git diff -U0 -- <两脚本> | 非#行 | grep -c .` = 0（代码区零改动）
- `bash -n` 双过
- `grep -nE '互顶全局|全局 legacy' <两脚本>` 旧语义词清零（历史事实陈述除外）

## 边界
- 只改两脚本注释区；禁动其他文件；禁 git add/commit
