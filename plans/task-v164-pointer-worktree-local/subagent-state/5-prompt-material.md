# S5 critical-rules+SKILL 改述材料（executor，2026-10-10）

## 任务（≤2 文件）
按 findings.md [sub:4-executor] 级联清单，改述两个文档中的指针旧语义 + 在 critical-rules.md 登记瞬态文件合并规则。**规则语义零改动**（只改措辞+新增登记段）。

## 文件与目标区段
1. `/mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/skills/task-planner/references/critical-rules.md`
   - 清单目标：`:196`（Rule 22.9 附近"全局 legacy…互顶全局指针"旧语义）
   - `:298` 附近 side 指针描述为中性（S4 判只读），**核对即可，中性不改**
   - 行号以实施日实测为准（grep 定位：`grep -n 'active_plan' references/critical-rules.md`）
2. `/mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/skills/task-planner/SKILL.md`
   - 清单目标：`:59`（"全局 legacy"）、`:111`（"指针移交…全局指针"）

## 改述语义（三点，与 S3 一致）
① 全局指针 `plans/.active_plan` = **工作树内瞬态 fallback**（路径随 `$PWD` 本地化；2026-10-10 task-v164：git rm --cached+.gitignore 与兄弟瞬态族同族）；② 正常路径=side 会话私有指针（权威层）；③ **退役"移交/互顶全局指针"叙事**（该叙事=并行可见漂移来源）。

## 必填：瞬态文件合并规则登记段（critical-rules.md，紧贴指针相关段之后追加）
```
### [2026-10-10 task-v164] 瞬态状态文件合并规则
- 范围：`plans/.active_plan` 及同族瞬态运行态（`.active_plan_side/`、`.plan_required_side/`、`.drift-rhythm/`、`plans/**/.session-owner`）一律不入库（.gitignore 在册）
- 合并纪律：worktree 合并回 master 时如遇瞬态文件冲突（含 untracking 导致的删除态冲突），一律按瞬态处置——取删除/忽略态，**禁抢救指针值**；各会话指针由 `set-active-plan.sh set` 再生
- 依据：git log 实证 8 次 chore 移交/收尾噪音（f6d6158…26878fe）；2026-10-10 用户指令 R4「合并时忽略掉这个状态临时文件」
```

## 保留纪律（Rule 45 — 必守）
- 改述处行内/邻行加注 `[2026-10-10 task-v164]` + 原措辞一句说明（修改原因/时间/原行为）；历史勘误段落禁删
- critical-rules.md 只动清单内两处+新增登记段；SKILL.md 只动清单内两处；**其余零改动**（行数净增以登记段为主）

## 验收（主进程将复跑）
- `grep -n 'task-v164' critical-rules.md SKILL.md` 各 ≥1
- `grep -nE '全局 legacy|指针移交' critical-rules.md SKILL.md` = 0（旧语义清零；历史 commit 引用除外）
- 合并规则登记段四要素在位（范围/合并纪律/依据/R4 锚）
- `git diff --stat` 只见两文件；diff 内无规则条文语义变化（只措辞+新增段）

## 边界
- 只改两文件清单内区段；禁改其他规则/SKILL 其他节；禁 git add/commit；禁动任何 .sh/.cjs
