# 检查点 — 3c skill/claude 纪元级联（1-94→1-95，新增 Rule 95）

任务：worktree `/mnt/data/dev/task-planner-skill-worktrees/task-nopause-execfirst-20261023`
范围：仅 2 文件 `skills/task-planner/SKILL.md` + `CLAUDE.md`，逐字最小替换，历史注释链零改动。

## 完成清单（逐处记录）

| # | 文件 | 行 | 改动（旧 → 新） | 状态 |
|---|------|----|----------------|------|
| 1 | SKILL.md | 9 | `Rules 1-94 全集索引（核心在位` → `Rules 1-95 全集索引（核心在位` | done |
| 2 | SKILL.md | 9 | `其余 77 条按域归 11 卫星` → `其余 78 条按域归 11 卫星` | done |
| 3 | SKILL.md | 17 | task-discipline 枚举行 `…,92,93,94）` → `…,92,93,94,95）` | done |
| 4 | SKILL.md | 196 | 路由表 task-discipline 行 `…,92,93,94） |` → `…,92,93,94,95） |` | done |
| 5 | SKILL.md | 209 | `Rules 1-94 全集索引：**核心在位` → `Rules 1-95 全集索引：**核心在位` | done |
| 6 | SKILL.md | 209 | `其余 77 条已按域迁至上表 11 卫星` → `其余 78 条…` | done |
| 7 | SKILL.md | 209 | `Rule 85/86/87/88/89/90/92/93/94 纪律域` → `…/92/93/94/95 纪律域` | done |
| 8 | SKILL.md | 251 | `核心域 1-94 全集索引` → `核心域 1-95 全集索引` | done |
| 9 | CLAUDE.md | 33 | `Rules 1-94 核心执行约束` → `Rules 1-95 核心执行约束`（同行的 `1-9x→1-9y` 历史演进注释链未动一字） | done |

注：L9 确实同时含 "77 条"，与派发假设一致，无需特殊处理。

## 自验证据

- `grep -n "1-94" SKILL.md CLAUDE.md` → 唯一命中 `CLAUDE.md:33` 历史演进注释链 `… Rules 1-93→1-94`（HISTORICAL，守卫负样本，按令不动）；两文件 live 计数行残留 = 0。
- `grep -c "1-95" SKILL.md` → 3（行 9 / 209 / 251）。派发期望 ≥4 与实际不符的原因：另 4 处改动（行 9 的 77→78、行 17/196 的 `93,94`→`93,94,95`、行 209 的纪律域列表）只引入裸 `95`，不产生字面 `1-95`；字面 `1-95` 只在"Rules 1-94 全集索引 / 核心域 1-94 全集索引"这 3 行出现，故 3 为正确值。
- `git diff --stat` → `CLAUDE.md 2 +-`、`skills/task-planner/SKILL.md 10 ++++----`，另有 2 个 companion agent 文件（image/video-generation-executor.md）在我动工前已处于 modified 状态（初始 `git status` 即如此），非本次改动，未触碰。
- 未执行 `git add` / `git commit`。

## 遗留风险

1. `grep -c "1-95"` = 3 与派发期望 ≥4 的数字差异（原因已如上述，非漏改）。
2. worktree 内存在他人未提交改动（2 个 companion agent 文件），收口审计时需排除 attributable 混淆。
3. 本次仅改索引计数行，Rule 95 正文落盘属其他子任务范围（本任务未涉及）。
