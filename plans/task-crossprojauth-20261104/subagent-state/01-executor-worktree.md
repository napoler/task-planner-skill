# 检查点 01 — executor worktree 面编辑（spec-A-worktree-edits.md）

- §1 worktree-isolation.md 完成,6 处 Edit（E1 §3 整段替换 / E2 §4① 注释行 / E3 §4 创建命令 / E4 §4 提交两行 / E5 §4 清理命令 / E6 §5 反模式追加一行）

## 失配登记（最小同义修正，规格文件允许）
1. 规格 E1 NEW 段中「为什么」行原文含 `<repo-parent>/<repo>-worktrees/<task-id>`，与 V1 验收 `grep -c 'repo-parent\|REPO_PARENT' = 0` 自冲突；实际落盘改为语义等价的 `仓外隐藏集中目录 <repo>-worktrees/<task-id>,置于该仓父目录`，避开 repo-parent 字面，登记 1 处失配。
2. 规格 E2 new 注释行原文 `前置: <project-root>/.gitignore 含 tmp/`，为避免 V6 验收命令字面（`worktree remove ${PROJECT_ROOT}/tmp/worktrees`）之外的歧义并保持 §3 定义「下文命令示例统一以 ${PROJECT_ROOT} 书写」口径一致，实际落盘用 `${PROJECT_ROOT}/.gitignore`（同位置变量替换，语义不变）。
3. smart-merge-back.sh L105/L172 注释行：实际 old 行与规格 old 文本一致，直接替换成功，无失配。
4. 其余 7 模板文件（variant 6 + task_plan.md + deployment-type.md）与 critical-rules-dispatch.md L8：old 与规格完全一致，无失配。

## 逐文件 Edit 计数
| 文件 | Edit 数 |
|------|--------|
| skills/task-planner/references/worktree-isolation.md | 6 |
| skills/task-planner/templates/variant/bugfix-type.md | 1 |
| skills/task-planner/templates/variant/test-writing-type.md | 1 |
| skills/task-planner/templates/variant/performance-tuning-type.md | 1 |
| skills/task-planner/templates/variant/refactor-type.md | 1 |
| skills/task-planner/templates/variant/code-edit-type.md | 1 |
| skills/task-planner/templates/variant/schema-migration-type.md | 1 |
| skills/task-planner/templates/task_plan.md | 1 |
| skills/task-planner/templates/variant/deployment-type.md | 1 |
| skills/task-dispatch/references/critical-rules-dispatch.md | 1 |
| skills/task-planner/scripts/smart-merge-back.sh | 2（仅注释行） |
合计 11 文件 17 处 Edit。

## 验收 grep 原始输出（V1–V7）
```
$ grep -c 'repo-parent\|REPO_PARENT' skills/task-planner/references/worktree-isolation.md
0
$ grep -c 'PROJECT_ROOT' skills/task-planner/references/worktree-isolation.md
6
$ grep -rn 'repo-parent\|repo-worktrees' skills/task-planner/templates/
（无输出，exit=1）
$ grep -c 'tmp/worktrees' skills/task-dispatch/references/critical-rules-dispatch.md
1
$ grep -c 'Rule 100' skills/task-planner/scripts/smart-merge-back.sh
2
$ grep -n 'worktree remove ${PROJECT_ROOT}/tmp/worktrees' skills/task-planner/references/worktree-isolation.md
66:git worktree remove ${PROJECT_ROOT}/tmp/worktrees/<task-id> && git branch -d wt/<task-id>
V7 人工核对：git 区块结构 = §1(L5)/§2(L20)/§3(L29)/§4 生命周期(L48)/§4 合并回合约(L73)/§5(L89)/§6(L99)；§1/§2/§4 合并回合约/§6 区块文字无改动，仅动了 §3、§4 命令块（L51–L66）、§5 追加行（L96 后新增 1 行）。
```

## 最终结论
完成。11 文件 17 处 Edit 全部落地，验收 V1–V7 全部通过；失配 2 处（上表登记 1、2，均为语义等价的最小修正）；未做任何 git 操作；未触碰 spec 之外的文件；AGENTS.md 未动。
