# S2 检查点：media 指针 + variant 两模板「移入 trash/」替代（Rule 100.6）

- S-unit: S2（task-trashcan-20261105）
- 时间: 2026-11-05
- worktree: `/mnt/data/dev/task-planner-skill-worktrees/task-trashcan-20261105`
- 依据: 用户 2026-11-05 裁决 + Rule 100.6（S1 并行落地中，CA-2/CA-3/CA-4 替代修改）

## 修改内容

1. `skills/media-planner/references/critical-rules-media.md`
   - 在 47.5 段落结束后追加淘汰件处置指针（逐字按任务要求），新增引用 Rule 100.6 / task-trashcan-20261105，指向 `<project-root>/trash/` 判废即移，禁 -failed 式原地重命名；正常检索排除 trash/。
2. `skills/task-planner/templates/variant/image-type.md`
   - VC-6（L26）替代处置动作：由「当日归档（-failed/-superseded 重命名+归档登记簿一行）」改为「当日判废移入 trash/（Rule 100.6 判废即移，`mv <file> trash/`，禁原地 -failed/-superseded 重命名堆放）+归档登记簿一行（docs/archive/README.md）」；VC 编号/其余验收语义保留。
3. `skills/task-planner/templates/variant/video-type.md`
   - L61（Phase 3 G1 门控，否决镜草稿）与 L72（Phase 5 成片 QC，否决/废弃件）两处「当日归档（-failed/-superseded）」替代为「当日判废移入 trash/（Rule 100.6 判废即移，禁原地 -failed/-superseded 重命名堆放）」；句内其余语义保留。

## 验收自证

### 1) Rule 100.6 引用计数
```bash
$ grep -c "100.6" skills/media-planner/references/critical-rules-media.md
1
```

### 2) trash 引用计数
```bash
$ grep -c "trash" skills/task-planner/templates/variant/image-type.md
1
$ grep -c "trash" skills/task-planner/templates/variant/video-type.md
2
```

### 3) `-failed` 处置动作表述核查（预期：仅“禁…”否定引用保留）
命令：`grep -n '\-failed' <三文件>`

结果（4 处，均为**禁止性否定引用**，非原地重命名处置动作）：
- `skills/media-planner/references/critical-rules-media.md:20` — `禁原地堆放或 -failed 式原地重命名…`（否定引用，预期保留）
- `skills/task-planner/templates/variant/video-type.md:61` — `…禁原地 -failed/-superseded 重命名堆放`（否定引用，预期保留）
- `skills/task-planner/templates/variant/video-type.md:72` — `…禁原地 -failed/-superseded 重命名堆放`（否定引用，预期保留）
- `skills/task-planner/templates/variant/image-type.md:26` — `…禁原地 -failed/-superseded 重命名堆放`（否定引用，预期保留）

结论：三文件中 `-failed` 作为**处置动作**的表述已消失；保留的 `-failed` 均位于“禁…”语境，符合任务说明。

### 4) git diff --stat（worktree）
```bash
$ git -C /mnt/data/dev/task-planner-skill-worktrees/task-trashcan-20261105 diff --stat
 .gitignore                                                     | 3 +++
 skills/media-planner/references/critical-rules-media.md        | 1 +
 skills/task-discipline/references/critical-rules-discipline.md | 1 +
 skills/task-planner/templates/deprecated.md                    | 1 +
 skills/task-planner/templates/variant/image-type.md            | 2 +-
 skills/task-planner/templates/variant/video-type.md            | 4 ++--
 6 files changed, 9 insertions(+), 3 deletions(-)
```

**S2 本单元修改仅限**上述 3 个目标文件（`critical-rules-media.md`、`image-type.md`、`video-type.md`）。diff stat 中另外 3 个文件（`.gitignore`、`critical-rules-discipline.md`、`deprecated.md`）为 worktree 内并行 S1/其他单元既存改动，非本次 S2 产生；本单元未触碰。

## 状态
- 结论: **done**（三处替代完成，自证通过）
- 风险: worktree 含并行单元未提交改动，提交/合并时需按单元范围分拣（避免误带入）。
