# S2 git 索引瞬态化材料（executor，2026-10-10）

## 任务（≤2 文件）
把 `plans/.active_plan` 从 git 跟踪文件改为工作树内瞬态文件：`git rm --cached` + `.gitignore` 追加条目。**工作区文件必须保留**（禁删）。

## 执行命令（worktree 内按序）
```
cd /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local
git rm --cached plans/.active_plan
```

`.gitignore`（仓根）追加段（追加到文件末尾，保留既有全部行）：
```
# 活跃计划全局指针瞬态化(task-v164 2026-10-10)：随工作树本地化的运行态，
# 与 .active_plan_side/.plan_required_side/.drift-rhythm 同族，合并零冲突
plans/.active_plan
```

## 修改注释规范（Rule 45 — 必守）
- `.gitignore` 追加块须带 Why 注释（如上）；禁止只加一行无说明
- 本次为唯一允许的"跟踪态移除"：`git rm --cached` 不动工作区文件；禁 `rm`/`git rm`（不带 --cached）

## 验收（主进程将复跑）
```
git ls-files --error-unmatch plans/.active_plan   # 期望 exit 1（不在跟踪列表）
grep -n '^plans/.active_plan$' .gitignore          # 期望命中 1 行
ls -la plans/.active_plan                          # 期望文件仍在
bash skills/task-planner/scripts/set-active-plan.sh task-v164-pointer-worktree-local   # legacy 模式写全局（瞬态化后）
git status --short                                 # 期望无 plans/.active_plan 条目
```
- `git diff --cached --stat` 应只见：`.gitignore`(+2/+3 行)、`plans/.active_plan`（D，删除自索引）

## 边界
- 只改 `.gitignore` 与索引态；禁改任何 skills/task-planner/** 文件；禁 git commit/add（主进程负责提交）；禁动 plans/.active_plan 工作区文件内容之外的目的性删除
