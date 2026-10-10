# S6 README+INSTALL 改述材料（executor，2026-10-10）

## 任务（≤2 文件）
按 findings.md [sub:4-executor] 级联清单，改述两个安装/说明文档中的指针旧语义。**只改措辞+[task-v164] 注记，禁改其他内容**。

## 文件与目标区段（行号以实施日实测为准）
1. `/mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/skills/task-planner/README.md`
   - 清单目标：`:100`、`:101`（文档"全局 legacy .active_plan"旧语义）
2. `/mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/skills/task-planner/INSTALL.md`
   - 清单目标：`:189`（正文"全局 legacy `plans/.active_plan` 仅兜底"旧语义）
- 定位命令：`grep -n 'active_plan' README.md INSTALL.md`

## 改述语义（三点，与 S3/S5 一致）
① 全局指针 `plans/.active_plan` = **工作树内瞬态 fallback**（路径随 `$PWD` 本地化；2026-10-10 task-v164：git rm --cached+.gitignore，与 .active_plan_side/ 同族瞬态运行态）；② 正常路径=side 会话私有指针（权威层）；③ 退役"legacy/移交"旧表述。

## 保留纪律（Rule 45 — 必守）
- 每处改述行内或邻行加 `[2026-10-10 task-v164]` 注记（原措辞一句说明）；禁删文档其他段落/表格/安装命令
- README/INSTALL 只动清单内行；行数变化 ≤±2/文件

## 验收（主进程将复跑）
- `grep -c 'task-v164' README.md INSTALL.md` 各 ≥1
- `grep -nE '全局 legacy' README.md INSTALL.md` = 0
- `git diff --stat` 仅两文件；安装命令/表格零改动

## 边界
- 只改两文件清单内行；禁动 skills/ 下其他文件与任何脚本；禁 git add/commit
