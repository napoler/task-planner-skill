# S10 check-dispatch+check-complete 注释改述材料（executor，2026-10-10）

## 任务（≤2 文件，只动 `#` 注释行）
按 findings.md [sub:4-executor] 级联清单，改述两个守卫脚本注释中的指针旧语义，**退役"请移交"推荐表述**。代码零改动（diff 只允许 `#` 行）。

## 文件与目标区段（行号以实施日实测为准）
1. `/mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/skills/task-planner/scripts/check-dispatch.sh`
   - 清单目标：`:20`（"全局指针 .active_plan 被并发会话/cron 频繁翻转"）、`:216`（"不再被互顶的全局 legacy 指针误拦"）
2. `/mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/skills/task-planner/scripts/check-complete.sh`
   - 清单目标：`:1338`（"全局指针…仍指向本任务"）、`:1346`（"移交提醒…请移交"）

## 改述语义（三点，与 S3 一致）
① 全局指针 `plans/.active_plan` = **工作树内瞬态 fallback**（路径随 `$PWD` 本地化；2026-10-10 task-v164：git rm --cached+.gitignore 同族瞬态）；② 正常路径=side 会话私有指针（权威层）；③ 退役"互顶/移交"叙事（并行可见漂移来源）；④ check-complete 的终验提醒从"请移交"改述为"提醒清理/无需移交"（注意：该提醒的**stderr 通道与 warn 形态必须保留**——selftest-pointer-lifecycle PL-06 断言锚「移交提醒」及其 `>&2` 通道，如改措辞须保底含可锚定字符串并在 findings 报备新锚，供 S14 锁步）。

## 保留纪律（Rule 45 — 必守）
- 每处改述加 `[2026-10-10 task-v164]` 注记（原措辞一句说明，可避开旧语义词连写）；历史勘误注释禁删
- 禁动 `set -u` 之后任何代码；禁改提醒的触发条件/warn 形态/stderr 通道；禁改 usage

## 验收（主进程将复跑）
- `grep -c 'task-v164' <两脚本>` 各 ≥1
- `git diff -U0 -- <两脚本> | 非#行 | grep -c .` = 0（代码区零改动）
- `bash -n` 双过
- `grep -nE '互顶|全局 legacy|请移交' <两脚本>` = 0（历史陈述除外）
- `bash skills/task-planner/scripts/selftest-pointer-lifecycle.sh` PL-06 结果记录在案（PASS 或新锚说明）

## 边界
- 只改两脚本注释区；禁动其他文件；禁 git add/commit
