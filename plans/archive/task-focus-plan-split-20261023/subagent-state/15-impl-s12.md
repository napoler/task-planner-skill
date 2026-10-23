# 15-impl-s12 | S-unit S12（CR fix-phase，CA-13）| status=done | 2026-10-23

## 任务
task-focus-plan-split-20261023 / Phase 3 / S12：ARCHITECTURE.md 注记/措辞修复（CR P2-1/2/3）+ CLAUDE.md 纪元注释链补登（CR P2-10）。

## worktree
/mnt/data/dev/task-planner-skill-worktrees/task-focus-plan-split-20261023

## 逐处改前→改后（4 处，全部完成）

### A1. ARCHITECTURE.md L4（CR P2-1，dedup=76 旧实测值与活跃行 77 矛盾）
- 改前：`...卫星侧实体规则编号 dedup=76，全集 14+76=90（77/78/79 已废弃不计）] -->`
- 改后：`...卫星侧实体规则编号 dedup=76（+Rule 94 → 77），全集 14+76=90（77/78/79 已废弃不计）] -->`
- 方式：纯行内插入「（+Rule 94 → 77）」，原注记文字零删改

### A2. ARCHITECTURE.md L115（CR P2-2，58+17+1=76 与实测 dedup 一致）
- 改前：`...58+17+1=76 与实测 dedup 一致] -->`
- 改后：`...58+17+1=76 与实测 dedup 一致（+Rule 94: 58→59、44→45 → 77）] -->`
- 方式：纯行内插入增量语义补注，原注记文字零删改

### A3. ARCHITECTURE.md L123（CR P2-3，「94 行」措辞误导——卡实为 52 行）
- 改前：`...execution-recall-card.md 94 行同批落地`
- 改后：`...execution-recall-card.md 之 Rule 94 蒸馏行（L39）同批落地`
- 事实核验（编辑前第一手证据）：`wc -l skills/task-discipline/references/execution-recall-card.md` = 52 行；L39 = 「- 专注隔离：目标重大偏差（A→B）不就地吸收——主动询问拆分新 Task Plan，单计划单垂直域防污染（Rule 94）」，蒸馏行定位 L39 属实

### B1. CLAUDE.md L33（CR P2-10，纪元注释链补登）
- 改前：行尾止于 `<!-- 2026-10-21 task-v195 演进 1-92→1-93（Rule 93 规范再召回落地，核心 14 条不变） -->`
- 改后：行尾追加 `<!-- 2026-10-23 task-focus-plan-split-20261023: Rules 1-93→1-94 -->`（逐字，沿用该文件既有行尾 HTML 纪元注释风格）

## 验收结果（全部 PASS）
1. `grep -n "之 Rule 94 蒸馏行（L39）" ARCHITECTURE.md` → L123 命中（≥1 PASS）
2. `grep -n "（+Rule 94" ARCHITECTURE.md` → L4、L115 两处命中（≥2 PASS）
3. `git diff -U0` 核对：ARCHITECTURE.md +3/-3（L4/L115/L123 各 1 行）、CLAUDE.md +1/-1（L33），合计 4 行 ≤6 行 PASS；A1/A2 为纯行内插入、原历史注记文字零删改 PASS
4. `grep -c "2026-10-23 task-focus-plan-split-20261023: Rules 1-93→1-94" CLAUDE.md` = 1 PASS

## 目标文件触碰清单
- skills/task-planner/docs/ARCHITECTURE.md（L4/L115/L123）
- CLAUDE.md（L33）
- 本检查点（新建）
- 未触碰其他任何文件

## 风险
- 无。L123 的「94 行→之 Rule 94 蒸馏行（L39）」为任务显式要求的措辞修正（非历史注记删除禁令范围，L122 的「同批落地」行未动）。
