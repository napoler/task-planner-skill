# 5 — alignment-review 对齐审查检查点

**审查对象**: `git diff 16951ff..73ce9ec`（task-v185 Rule 92 全文 + 编号级联，5 文件 24+/11-）
**审查时间**: 2026-10-17
**审查技能**: alignment-review（Rule 42.2 第④层消费）

---

## ALIGN VERDICT: CHANGES_REQUESTED

**P1 × 1** — Rule 92.6 交叉引用 87.4③ 语义错位（详见逐项 3）。

---

## 审查对象总清单（Rule 70①）

| # | 文件（绝对路径） | 本次变更 |
|---|-----------------|---------|
| 1 | `/mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md` | +12 行：Rule 92 全文（标题+建制+92.1-92.7）追加至文件末尾 |
| 2 | `/mnt/data/dev/task-planner-skill/skills/task-discipline/SKILL.md` | 规则清单 +92；调用条件 +「产出文件尺寸与拆分」；索引表 +行 92 |
| 3 | `/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md` | 1-91→1-92（3 处）；两处 discipline 清单 +92 |
| 4 | `/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md` | discipline 路由行清单 +92 |
| 5 | `/mnt/data/dev/task-planner-skill/skills/task-planner/README.md` | 1-91→1-92（3 处字面） |

---

## 逐项结论

### 1. 需求对齐 — PASS

用户原话（user-session-log.md #1）逐点对照 Rule 92 条款：

| 用户原话要点 | Rule 92 承载 | 判定 |
|-------------|-------------|------|
| 尽量避免单个文件过大 | 92.1「尽量避免单个文件过大」+ 建制段 | ✓ 无漂移 |
| 优先将文件拆分为多个 | 92.1「优先拆分为多个文件」 | ✓ 无漂移 |
| 代码按引用之类都可以拆分 | 92.3「按模块/职责/引用关系切分」 | ✓ 无漂移 |
| 其他文件也是类似的情况 | 92.4「非代码文件垂直拆分」 | ✓ 无漂移 |
| 建议垂直化的拆分 | 92.5「垂直切分边界」+ 标题「垂直化拆分」 | ✓ 无漂移 |
| 减少单个文件过大导致的负担 | 建制段「降低大单文件的读写/上下文/冲突/维护负担」 | ✓ 无漂移 |
| 规范要求在产出写入时避免 | 92.1「任何任务的产出/写入动作前」 | ✓ 无漂移 |

**证据**: `grep -cE "\*\*92\.[1-7]" critical-rules-discipline.md` = 7；关键词计数「垂直」=6、「引用」=4、「优先拆分」=3，均 ≥ VC-2 判据。

### 2. 版本/口径一致性 — PASS

| 检查项 | 命令 | 结果 | 判定 |
|--------|------|------|------|
| SKILL.md 含 1-92 | `grep -cE "(Rules )?1-92" skills/task-planner/SKILL.md` | 3 | ✓ ≥3 |
| SKILL.md 无 1-91 残留 | `grep -c "1-91" skills/task-planner/SKILL.md` | 0 | ✓ |
| README.md 无 1-91 残留 | `grep -c "1-91" skills/task-planner/README.md` | 0 | ✓ |
| discipline SKILL.md 含 92 | `grep -c ",92" skills/task-discipline/SKILL.md` | 1 | ✓ |
| 核心 critical-rules.md 含 92 | `grep -c ",92" skills/task-planner/references/critical-rules.md` | 1 | ✓ |

**既有漂移登记在案（不算本次新增）**:
- D-A: discipline 索引表缺 85-90 行 + 计数 41/42/43 三口径不一致
- D-B: README「其余 71 条」vs SKILL「其余 73 条」
- D-C: 路由清单合计 89 vs 实存编号 88

以上均为 pre-existing，计划 CA-3 明确「其余 73 条」措辞不改（漂移只登记），本次 diff 未触碰这些行。

### 3. 引用面一致性 — FAIL（P1 × 1）

Rule 92 衔接条款引用：19.6 / 29 / 45 / 87 / 88 / 38.7

| 引用 | 存在性 | 语义匹配 | 判定 |
|------|--------|---------|------|
| Rule 19.6 | ✓ `critical-rules.md:29` | ✓ task_plan.md 瘦身同源口径 | ✓ |
| Rule 29 | ✓ `critical-rules-discipline.md:59` | ✓ 工作文件维护 | ✓ |
| Rule 45 | ✓ `critical-rules-discipline.md:181` | ✓ 注释随逻辑迁移 | ✓ |
| Rule 87 | ✓ `critical-rules-discipline.md:527` | ✓ 精准改动纪律 | ✓ |
| **Rule 87.4③** | ✓ 存在 | **✗ 语义错位** | **P1** |
| Rule 88 | ✓ `critical-rules-discipline.md:541` | ✓ 任务射程契约 | ✓ |
| Rule 38.7 | ✓ `critical-rules-discipline.md:195` | ✓ L0-T 执行通道分级 | ✓ |

**P1 问题详情**:

- **位置**: `skills/task-discipline/references/critical-rules-discipline.md:587`（92.6）
- **原文**: 「禁止顺手拆（Rule 87.4③ 同面语义）」
- **87.4③ 实际文本**: 「匹配项目既有风格，即使个人偏好另一种写法」
- **语义比对**: 92.6 的「禁止顺手拆」= 禁止 opportunistic 拆分存量文件；87.4③ = 匹配代码风格。两者语义面不同——87.4③ 管代码风格匹配，不管文件结构拆分 restraint。
- **正确引用**: 87.4①「只改必须改的地方，不顺手『改进』相邻代码/注释/格式」或 87.4②「不重构没有坏掉的模块」——两者均与「禁止顺手拆」同面。
- **建议修法**: 将 92.6 中「Rule 87.4③」改为「Rule 87.4①」或「Rule 87.4②」。

**证据**:
```
$ sed -n '534p' critical-rules-discipline.md | grep -oP "③[^；]*"
③ 匹配项目既有风格，即使个人偏好另一种写法
$ sed -n '587p' critical-rules-discipline.md | grep -oP "禁止顺手拆[^）]*）"
禁止顺手拆（Rule 87.4③ 同面语义）
```

### 4. 术语一致性 — PASS

| 术语 | Rule 92 内使用 | 仓内既有使用 | 冲突 |
|------|---------------|-------------|------|
| 垂直化拆分 / 垂直切分 | 标题+92.3+92.4+92.5（6 处「垂直」） | 无其他使用（grep 排除 Rule 92 后 0 命中） | 无 |
| 内聚边界 / 内聚文件 / 内聚单元 | 标题+92.3+92.5 | ARCHITECTURE.md:302「域内聚」（不同语境，指域内聚非文件内聚） | 无 |
| 拆分 | 全文通用 | Rule 21.6（S-unit 拆分=任务分解）、Rule 59（任务粒度） | 无冲突——Rule 21.6/59 管任务/子代理拆分，Rule 92 管文件拆分，域不同 |

**证据**: `grep -rn "垂直化" skills/ --include="*.md" | grep -v "critical-rules-discipline.md"` = 0 命中。

### 5. 载体一致性 — PASS

| 检查项 | 结果 | 判定 |
|--------|------|------|
| Rule 92 落位 task-discipline 卫星 | `grep -c "^### 92 产出文件尺寸纪律" critical-rules-discipline.md` = 1 | ✓ |
| task-discipline/SKILL.md 规则清单含 92 | diff 确认 +92 | ✓ |
| task-discipline/SKILL.md 索引表含 92 | diff 确认 +行 92 | ✓ |
| task-planner/SKILL.md 卫星清单含 92 | diff 确认 +92 | ✓ |
| task-planner/SKILL.md 路由表含 92 | diff 确认 +92 | ✓ |
| 核心 critical-rules.md 路由索引含 92 | diff 确认 +92 | ✓ |
| task-discipline/SKILL.md 调用条件含「产出文件尺寸与拆分」 | diff 确认 | ✓ |

**注**: task-planner/SKILL.md 路由表与核心 critical-rules.md 路由索引的「调用条件」列未加「产出文件尺寸与拆分」关键词——但这两处为 condensed 摘要（既有调用条件列已省略 task-discipline/SKILL.md 中的多个关键词如 卫生/交互/超时/来源锚），且计划 CA-3/CA-4 仅要求「清单+92」未要求调用条件同步，与既有 condensed 模式一致，不构成新不一致。

---

## 问题清单

| 级别 | 位置 | 问题 | 建议修法 |
|------|------|------|---------|
| P1 | `skills/task-discipline/references/critical-rules-discipline.md:587` | 92.6 引用「Rule 87.4③ 同面语义」语义错位——87.4③=匹配代码风格，非禁止顺手拆 | 改为「Rule 87.4①」或「Rule 87.4②」 |

---

## 变更记录

| 字段 | 内容 |
|------|------|
| 变更范围 | 本检查点文件（唯一写入） |
| 冲突处理结果 | 无冲突——只读审查 + 检查点落盘 |
| 文档当前状态 | 审查完成；1 P1 待修（92.6 交叉引用 87.4③→87.4①/②）；其余 4 项全 PASS |

---

## 复验（Re-verification）— 2026-10-17

**复验对象**: fix commit `39bf476`（master）— 仅 `skills/task-discipline/references/critical-rules-discipline.md:587`（92.6）单行修正。

### ALIGN RE-VERDICT: APPROVED

**复验结论（就 92.6 单行）**:

① **引用面语义匹配** — PASS。
- 修正后原文：「禁止顺手拆（Rule 87.4② 同面语义：不重构没有坏掉的模块）」
- `sed -n '534p' critical-rules-discipline.md | grep -oP "②[^；]*"` = 「② 不重构没有坏掉的模块」
- 语义比对：「禁止顺手拆存量大文件」= 对未坏模块做重构性拆分；87.4②「不重构没有坏掉的模块」同面——大文件能用只是尺寸偏大非坏，无授权不顺手重构/拆分。语义一致，P1 消除。

② **无新引入问题** — PASS。
- `git show 39bf476 --stat`：1 file changed, 1 insertion(+), 1 deletion(-)，仅 92.6 单行。
- 修正为纯引用号改判（③→②）+ 补解释从句「：不重构没有坏掉的模块」，无新增规则号/路由/计数/结构改动。
- 87.4② 已存在（`critical-rules-discipline.md:534`），引用目标真实有效。
- 92.7 衔接列表仍写「87/88（存量拆分须在射程内或获授权）」，与修正后 92.6 一致，无二次漂移。
- 未触碰其他 4 项（需求对齐/口径/术语/载体）涉及行，原 PASS 结论维持。

**残留冲突 = 0**。P1 已修，全 5 项 PASS，无新增 P0/P1。
