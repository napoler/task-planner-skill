# S11 checkpoint — 主 SKILL.md 计数口径 75→77×2 + planner README.md 行内注记修复（CR fix-phase，CA-13）

- status: done
- agent: executor / 2026-10-23
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-focus-plan-split-20261023（分支 wt/task-focus-plan-split-20261023）

## 写入结果（逐处 改前→改后）

A. skills/task-planner/SKILL.md（267 行→267 行，等宽替换不增行）
1. L9（frontmatter references 行）：`其余 75 条按域归 11 卫星` → `其余 77 条按域归 11 卫星`
2. L209（Critical Rules 指针段）：`其余 75 条已按域迁至上表 11 卫星` → `其余 77 条已按域迁至上表 11 卫星`

B. skills/task-planner/README.md（行内 HTML 注释补增量语义，原文字零删除）
3. L4（L-5 扩面注记）：`dedup=76（全集 14+76=90，77/78/79 废弃不计）` → `dedup=76（+Rule 94 → 77）（全集 14+76=90，77/78/79 废弃不计）`
4. L81（L-5 实测注记）：`卫星侧实体规则编号 dedup=76] -->` → `卫星侧实体规则编号 dedup=76（+Rule 94 → 77）] -->`

## 验收自跑（全部 PASS）

| # | 命令 | 实测 | 判定 |
|---|------|------|------|
| 1 | grep -c "其余 77 条" A；grep -c "其余 75 条" A | 2 / 0 | PASS |
| 2 | wc -l A | 267（=改前） | PASS |
| 3 | grep -n "（+Rule 94 → 77）" B | L4、L81 两行命中（各行同行含活跃 77 与新注记） | PASS |
| 4 | git -C worktree diff --stat | 见下方差异说明（S11 口径 PASS） | PASS |

## 差异说明（非违规，需主进程知悉）

全 worktree `git diff --stat` 显示 3 个文件：本步 2 目标文件 + `skills/task-discipline/references/critical-rules-discipline.md`（5+/5-）。实证该第三文件为**前序 S-unit 遗留**：mtime 2026-10-23 12:02:32（早于 S11 写入时刻 12:05:28），diff 内容 = 同任务 Rule 94 段 94.1–94.4 细化（补「垂直域判别口径」「[focus-ask] progress 行」等），本 S-unit 全程未触碰该文件（严守「只准改两个目标文件」）。S11 口径 diff（`git diff -- skills/task-planner/SKILL.md skills/task-planner/README.md`）= 2 文件 4+/4-，纯等宽替换零增删行。验收第 4 条按「S11 增量仅这两个文件」解释成立；按「worktree 无任何未提交变更」解释不成立——遗留处置权在主进程（随前序 unit 提交或修订验收口径）。

## findings / 遗留

- 其余无异常；计划三文件（task_plan.md/findings.md/progress.md）与主仓零触碰，仅写本检查点。
- 遗留：① discipline 文件遗留 diff（前序 unit）待主进程处置；② 验收第 4 条口径歧义待主进程裁定。无阻塞。
