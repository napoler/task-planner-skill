# S3 头注释改述材料（executor，2026-10-10）

## 任务（≤2 文件）
把两个指针脚本的头注释从"legacy 全局指针"叙事改述为"工作树内瞬态 fallback"叙事，退役"移交"表述；**解析链逻辑/参数/函数体零改动**（只看注释区）。

## 文件与区段（绝对路径）
- /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/skills/task-planner/scripts/set-active-plan.sh — 头注释区 :1-21
- /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/skills/task-planner/scripts/resolve-plan-dir.sh — 头注释区 :1-27

## 改述语义（必须体现的三点）
1. **路径本地化既成事实**：全局指针 `plans/.active_plan` 路径随 `$PWD` 工作树本地化（每棵树各一份）
2. **瞬态化（2026-10-10 task-v164）**：`git rm --cached` + `.gitignore`（与 `.active_plan_side/`/`.plan_required_side/`/`.drift-rhythm/` 同族）→ 合并零冲突、git churn 止息（历史 8 次 chore 移交/收尾噪音）
3. **角色降级为 fallback**：正常路径=side 会话私有指针（2026-10-07 fix-pointer-race 后权威层）；全局层仅服务 sid-less/cron legacy 调用方；**退役"移交全局指针"叙事**（该叙事=并行可见漂移来源）

## 保留纪律（Rule 45 — 必守）
- 历史勘误段落（2026-09-10 active-plan-race / task-planrequired-race / fix-pointer-race 等既有注释）**全部保留**，只在相关行追加/行内补注 `[2026-10-10 task-v164]` 说明
- 修改处须注明修改原因/时间/原行为（例：`[2026-10-10 task-v164] 原措辞"全局 legacy"误导为跨树共享，实为工作树内瞬态 fallback，改述之`）
- 禁删既有注释、禁改 usage 行的命令形态、禁动 `set -u` 之后任何代码

## 验收（主进程将复跑）
- `grep -n 'task-v164' 两脚本` 各有 ≥1 处改述锚
- `bash -n` 两脚本均通过
- `git diff --stat` 只见两文件；`git diff` 中代码区（非 # 注释行）零改动
- 头注释无"移交"作为推荐操作的表述（历史事实陈述中的"移交修复→"类 commit 引用除外）

## 边界
- 只改两脚本头注释区；禁改函数体/变量/usage/解析链；禁 commit
