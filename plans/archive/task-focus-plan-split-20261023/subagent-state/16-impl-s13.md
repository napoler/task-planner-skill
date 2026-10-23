# 16-impl-s13 | S-unit S13（CR fix-phase，CA-13）| status=done | 2026-10-23

## 任务
task-focus-plan-split-20261023 / Phase 3 / S13：README_zh.md 纪元注释链补登（CR P2-10）+ discipline SKILL.md 93 表行补登（CR P2-4）与落盘状态句补全（CR NIT-2）。

## worktree
/mnt/data/dev/task-planner-skill-worktrees/task-focus-plan-split-20261023

## 逐处改前→改后（4 处，全部完成）

### A1. README_zh.md L136（CR P2-10，纪元注释链补登）
- 改前：行尾止于 `<!-- 2026-10-21 task-v195 演进 1-92→1-93（Rule 93 规范再召回落地，核心 14 条不变） -->`
- 改后：行尾追加 `<!-- 2026-10-23 task-focus-plan-split-20261023: Rules 1-93→1-94 -->`（逐字，沿用既有行尾 HTML 纪元注释链风格；含「2026-10-23」与「1-93→1-94」两要素；与 CLAUDE.md L33 判例（检查点 15 B1）同款）

### A2. README_zh.md L229（CR P2-10，纪元注释链补登）
- 改前：表格行末注释链止于 `<!-- 2026-10-21 task-v195 演进 1-92→1-93（Rule 93 规范再召回落地，核心 14 条不变） --> |`
- 改后：注释链尾（表格行末闭合竖线 ` |` 之前）插入 ` <!-- 2026-10-23 task-focus-plan-split-20261023: Rules 1-93→1-94 -->`——插入位置取注释链尾而非竖线后，保持表格单元格结构不破；与 A1 注释文案逐字一致
- 适配裁决：L229 为表格行（唯一 `--> |$` 形态），行尾即闭合竖线；「行尾同款追加」按 L136 语义=追加到注释链末端（可见行内容末尾），故置于 ` |` 之前

### B1. SKILL.md L74 与 L75 之间插入 93 表行（CR P2-4，索引表 45 条对齐）
- 改前：`| 92 | 产出文件尺寸纪律与优先拆分 | 同上 |` 行下直接接 `| 94 | 任务专注性与计划隔离纪律 | 同上 |`（93 表行缺口=task-v195 遗留）
- 改后：两行之间插入 `| 93 | 规范再召回纪律 | 同上 |`（新行=L75）
- 标题核验：取自 critical-rules-discipline.md L591 `### 93 规范再召回纪律（P0 — task-v195，...）` 段头主干部份（与 L73/L74 既有 90/92 行取名口径一致）
- 旁证：Rule 91 不属 discipline 卫星（`grep "^### 91" critical-rules-discipline.md` exit=1），索引表 90→92→93→94 连续与卫星归属面一致，本任务只补缺 93

### B2. SKILL.md L77→L78 落盘状态句（CR P2-4+NIT-2，数值跳跃补齐）
- 改前：`...Rule 89（task-v181 前后逻辑一致性禁反言）已后补落盘、Rule 94（task-focus-plan-split-20261023 任务专注性与计划隔离）已后补落盘——本索引现共 45 条全文可消费。`
- 改后：`...Rule 89（...）已后补落盘、Rule 90/92/93（task-v182/v185/v195）与 Rule 94（task-focus-plan-split-20261023 任务专注性与计划隔离）已后补落盘——本索引现共 45 条全文可消费。`
- 任务代号核对：90=task-v182、92=task-v185、93=task-v195（取自 L566/L578/L591 各段头「task-vXXX」字面）；「90/92/93」跳号与 B1 说明同源（91 不在本卫星）

## 验收结果（全部 PASS）
1. `grep -c "2026-10-23 task-focus-plan-split-20261023: Rules 1-93→1-94" README_zh.md` = 2 PASS（L136+L229）
2. `grep -c "^| 93 |" skills/task-discipline/SKILL.md` = 1 PASS；`grep -n "^| 9[234] |"` → L74(92)/L75(93)/L76(94) 三行连续升序 PASS
3. `grep -n "Rule 90/92/93（task-v182/v185/v195）" skills/task-discipline/SKILL.md` → L78 命中 1 处 PASS
4. `git diff -- README_zh.md skills/task-discipline/SKILL.md`：A=2 行（L136/L229 各 1 行替换）、B=2 行（L75 插入 + L78 句内更新），合计 4 行；既有历史注记文字零删改 PASS
5. 注释链两要素自检：新增注释同时含「2026-10-23」与「1-93→1-94」PASS

## 目标文件触碰清单
- README_zh.md（L136/L229）
- skills/task-discipline/SKILL.md（L75 插入 / L78 更新）
- 本检查点（新建）
- 未触碰其他任何文件（计划三文件只读参照；critical-rules-discipline.md 只读核验）

## 风险
- 无。4 处全部为纯增量/句内增量，无历史注记与既有条目原文改动；表行插入不改变行号敏感锚（SKILL.md 行数 +1，L78 起下移 1 行——若后续 S-unit 以绝对行号定位 L77 原落盘状态句，需按 L78 重定位）。
