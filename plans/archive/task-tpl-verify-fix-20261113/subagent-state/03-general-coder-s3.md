# S3 Checkpoint — plan-template-kit 契约条款落地 (CA-6)

- **task**: task-tpl-verify-fix-20261113 / S3 / general-coder
- **timestamp**: 2026-11-13 (session)
- **worktree**: /mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113
- **status**: completed (plan-template-kit 范围内)

## 承载文件选择理由

- **主落点 `skills/plan-template-kit/references/template-mapping.md`（§7.1 新增，§七 定制红线与 §八 验证命令之间）**：
  - 该文件已是 Rule 16/34/37 选型与定制契约的权威 reference（SKILL.md 明示“选型/定制/加类型 → template-mapping.md”；§七 已承载“定制红线/禁止改动格式”、§八 承载验证命令），语义上最贴近“模板与门的契约条款”——验证区块契约与 S-unit 列序契约本质是模板定制/契约红线的补充，可直接约束模板作者与门判据对齐。
  - 在此集中落两条条款并附 S1/S2 模板实际形态行号互证（verification.md:14,18,21,24,27,30；task_plan.md:340,358,338），可作为单一权威锚供后续引用。
- **指针落点 `skills/plan-template-kit/references/template-guide.md`（§四 “可自由定制区域”末尾）**：
  - template-guide.md 承载脚本契约标记/定制边界的面向使用者指引；在 §四 自由定制区末尾放一行指针，确保在“怎么定制模板”的阅读路径上也能发现两条契约，而不重复全文（避免双源漂移），满足“另一处放一行指针”。

## 锚行号（worktree 内）

- `skills/plan-template-kit/references/template-mapping.md:232-238` — `### 7.1 模板契约补充（task-tpl-verify-fix-20261113 落地）`，含两条契约逐字对齐 findings.md §3.3 + S1/S2 互证行号。
  - 条款 1（验证区块契约）：:234-235
  - 条款 2（S-unit 10 列序契约）：:236-237
- `skills/plan-template-kit/references/template-guide.md:167` — 指针行（验证区块契约 + S-unit 10 列序契约 → `references/template-mapping.md` §7.1）。

## S1/S2 互证依据（只读核对，未修改）

- S2 `skills/task-planner/templates/verification.md:14,18,21,24,27,30` — VC 条目预置 `**Verify command**:` 行（头注 :14 声明 vc-gate 判据面）。
- S1 `skills/task-planner/templates/task_plan.md:340,358` — 10 列 S-unit 表头；`:338` — Rule 104.3 类别=目标列内（An）前缀、禁「96 类别」独立列/禁单元格管道转义。

## 自检输出（原文）

### `grep -rn 'Verify command' skills/plan-template-kit/` （≥2，实际 3）
```
3
---
skills/plan-template-kit/references/template-guide.md:167:- 模板契约补充指针（task-tpl-verify-fix-20261113 落地）：验证区块契约（VC 必含行首 `**Verify command**:`，判据源 attest-plan.sh:244-285）与 S-unit 10 列序契约（ID/目标/执行体/输入/验收/预估时长/粒度/伴飞/前置/状态，check-plan-dispatch.sh:246-278）详见 `references/template-mapping.md` §7.1。
skills/plan-template-kit/references/template-mapping.md:234:1. **验证区块契约**：每个计划的 verification.md VC 条目必须含行首 `**Verify command**:` 纯命令行（判据源=attest-plan.sh:244-285 vc-gate）；task_plan/verification 模板必须预置该行格式——模板缺失验证区块=模板缺陷（判例 task-tpl-verify-fix-20261113）。
skills/plan-template-kit/references/template-mapping.md:235:   - S2 实际形态互证：`skills/task-planner/templates/verification.md:14,18,21,24,27,30`（VC 条目模板预置 `**Verify command**:` 行；头注 :14 声明判据面）。
```

### `grep -rn '10 列' skills/plan-template-kit/` （≥1，实际 3）
```
3
---
skills/plan-template-kit/references/template-guide.md:167:- 模板契约补充指针（task-tpl-verify-fix-20261113 落地）：验证区块契约（VC 必含行首 `**Verify command**:`，判据源 attest-plan.sh:244-285）与 S-unit 10 列序契约（ID/目标/执行体/输入/验收/预估时长/粒度/伴飞/前置/状态，check-plan-dispatch.sh:246-278）详见 `references/template-mapping.md` §7.1。
skills/plan-template-kit/references/template-mapping.md:236:2. **S-unit 10 列序契约**：模板 S-unit 表固定 10 列（ID/目标/执行体/输入/验收/预估时长/粒度/伴飞/前置/状态），与 check-plan-dispatch.sh:246-278 的 awk 定位一致；类别=目标列内（An）前缀（Rule 104.3 适配），禁「96 类别」独立列、禁单元格管道转义。
skills/plan-template-kit/references/template-mapping.md:237:   - S1 实际形态互证：`skills/task-planner/templates/task_plan.md:340,358`（10 列表头）+ `:338`（Rule 104.3 口径：类别以目标列内（An）前缀标注，禁增列/禁单元格管道转义）。
```

### `git diff --stat`（全 worktree）
```
 .../plan-template-kit/references/template-guide.md |  1 +
 .../references/template-mapping.md                 |  7 +++++
 skills/task-planner/templates/task_plan.md         | 34 +++++++++++++---------
 skills/task-planner/templates/verification.md      | 22 ++++++++++----
 4 files changed, 44 insertions(+), 20 deletions(-)
```

### `git diff --stat -- skills/plan-template-kit`（S3 scope，≤2 文件）
```
 .../plan-template-kit/references/template-guide.md | 1 +
 .../references/template-mapping.md                 | 7 +++++++
 2 files changed, 8 insertions(+)
```

> 注：worktree 另有 `skills/task-planner/templates/{task_plan,verification}.md` 变更为 S1/S2 既有改动，本次未触碰（符合“禁碰 templates/（S1/S2 已改，勿动）”）。

## 风险/备注

- 无新增脚本/门控，仅纯增量文本条款与指针；未改既有条款语义。
- 行号互证引用 S1/S2 当前 worktree 状态；若 S1/S2 后续再调整行号，需同步更新互证锚（属后续维护事项，本次未越权处理）。
