# 02-groupB — variant 模板三结构升级（9 文件）

- 时间戳：2026-11-13（会话内）
- worktree：`/mnt/data/dev/task-planner-skill-worktrees/task-variant-upgrade-20261113`
- 只读基线：`/mnt/data/dev/task-planner-skill/plans/task-variant-upgrade-20261113/findings.md`（§1 统一增量块、§2 处置规则、§4 分组）
- 范围：组 B 9 个 variant 模板（仅改这些文件；未触碰主仓/其他 worktree；未 commit；未改 mini-lite/l0-lite）

## 每文件处置记录

| 文件 | 改前 grep 三件套（goal-id / `| ID |` / Batch Report） | 改前 `^## ` 数 | 处置 | 改后 grep 三件套 | 改后 `^## ` 数 | 结构回读结论 |
|------|---|---:|------|---|---:|------|
| `skills/task-planner/templates/variant/migration-type.md` | NONE | 6 | 末尾追加 findings §1 全块（Goal + S-unit 10列骨架 + Batch Report）；尾部形态已确认（文件末行 `- **Executor:** executor（sonnet-1）`） | goal=1, id10=1, batch=1 | 9 | 仅增 3 标题，无重复 |
| `skills/task-planner/templates/variant/motion-camera-type.md` | NONE | 9 | 末尾追加 §1 全块；尾部为 handoff 表末空行，已按规则追加 | goal=1, id10=1, batch=1 | 12 | 仅增 3 标题，无重复 |
| `skills/task-planner/templates/variant/multiview-ref-type.md` | NONE | 10 | 末尾追加 §1 全块 | goal=1, id10=1, batch=1 | 13 | 仅增 3 标题，无重复 |
| `skills/task-planner/templates/variant/performance-tuning-type.md` | NONE | 17 | 末尾追加 §1 全块 | goal=1, id10=1, batch=1 | 20 | 仅增 3 标题，无重复 |
| `skills/task-planner/templates/variant/physics-compliance-type.md` | NONE | 10 | 末尾追加 §1 全块 | goal=1, id10=1, batch=1 | 13 | 仅增 3 标题，无重复 |
| `skills/task-planner/templates/variant/prompt-struct-type.md` | NONE | 9 | 末尾追加 §1 全块 | goal=1, id10=1, batch=1 | 12 | 仅增 3 标题，无重复 |
| `skills/task-planner/templates/variant/publish-type.md` | 命中 Batch Report（多处，含既有 `## 📦 Batch Report（批量发布必填 — Rule 18.6）` 与 VC 引用）；无 goal-id；无 10 列 `| ID |` | 12 | 末尾追加 Goal + S-unit 10列骨架；**Batch 已存在故不重复追加**（按 §2 规则 4）；列名/非10列表替换不适用（无 goal-id 表、无 `| ID |` 表） | goal=1, id10=1, batch=8 | 14 | 仅增 2 标题（Goal/S-unit），无重复；保留既有 Batch 段语义与引用 |
| `skills/task-planner/templates/variant/qc-defect-type.md` | NONE | 10 | 末尾追加 §1 全块 | goal=1, id10=1, batch=1 | 13 | 仅增 3 标题，无重复 |
| `skills/task-planner/templates/variant/refactor-type.md` | NONE | 17 | 末尾追加 §1 全块 | goal=1, id10=1, batch=1 | 20 | 仅增 3 标题，无重复 |

> 注：`publish-type.md` 的 `batch` 计数为 8（含既有模板中的 Batch Report 标题/引用/VC 文本），且未新增重复 Batch 标题；满足“三件套各 ≥1”。

## 组自检输出（原文）

### 1) goal/id10/batch 计数
```text
skills/task-planner/templates/variant/migration-type.md: goal=1 id10=1 batch=1
skills/task-planner/templates/variant/motion-camera-type.md: goal=1 id10=1 batch=1
skills/task-planner/templates/variant/multiview-ref-type.md: goal=1 id10=1 batch=1
skills/task-planner/templates/variant/performance-tuning-type.md: goal=1 id10=1 batch=1
skills/task-planner/templates/variant/physics-compliance-type.md: goal=1 id10=1 batch=1
skills/task-planner/templates/variant/prompt-struct-type.md: goal=1 id10=1 batch=1
skills/task-planner/templates/variant/publish-type.md: goal=1 id10=1 batch=8
skills/task-planner/templates/variant/qc-defect-type.md: goal=1 id10=1 batch=1
skills/task-planner/templates/variant/refactor-type.md: goal=1 id10=1 batch=1
```
结论：九文件三项各 ≥1。

### 2) 错字防扩散
```bash
grep -n '窗格态\|辋入' skills/task-planner/templates/variant/{migration-type.md,motion-camera-type.md,multiview-ref-type.md,performance-tuning-type.md,physics-compliance-type.md,prompt-struct-type.md,publish-type.md,qc-defect-type.md,refactor-type.md} || echo "ZERO_HITS"
```
```text
ZERO_HITS
```

### 3) git diff --stat（仅 9 文件）
```text
 .../templates/variant/migration-type.md            | 22 ++++++++++++++++++++++
 .../templates/variant/motion-camera-type.md        | 21 +++++++++++++++++++++
 .../templates/variant/multiview-ref-type.md        | 21 +++++++++++++++++++++
 .../templates/variant/performance-tuning-type.md   | 22 ++++++++++++++++++++++
 .../templates/variant/physics-compliance-type.md   | 21 +++++++++++++++++++++
 .../templates/variant/prompt-struct-type.md        | 21 +++++++++++++++++++++
 .../task-planner/templates/variant/publish-type.md | 10 ++++++++++
 .../templates/variant/qc-defect-type.md            | 21 +++++++++++++++++++++
 .../templates/variant/refactor-type.md             | 22 ++++++++++++++++++++++
 9 files changed, 181 insertions(+)
```

### 4) git diff master -- mini-lite l0-lite = 空
```bash
git diff master -- skills/task-planner/templates/variant/mini-lite-type.md skills/task-planner/templates/variant/l0-lite-type.md
# (no output)
---RC=0---
```

## 风险与备注
- `publish-type.md` 原有批量发布语境中已含 Batch Report 区块/多处引用；按规则未追加统一 Batch 块，避免语义重复；新增 Goal/S-unit 骨架已在文件末尾。
- 本组未发现既有 `| ID |` 非 10 列表需替换、未发现 goal-id 列名缺空格情形；因此无表头替换操作。
- 追加前均已确认文件尾 5 行；结构回读显示 `##` 标题仅增不减且无重复。
- 未执行 commit，变更仅存在于指定 worktree。
