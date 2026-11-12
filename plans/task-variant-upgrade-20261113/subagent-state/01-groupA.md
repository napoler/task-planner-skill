# 01-groupA — variant 模板三结构统一升级（A组）

- 目标：在隔离 worktree 对组 A 9 个 variant 模板统一追加/对齐三结构（Goal 单元表、10 列 S-unit 派发表骨架、Batch Report）。
- 计划参考：`plans/task-variant-upgrade-20261113/findings.md`（§1 统一增量块、§2 处置规则、§4 分组）
- worktree：`/mnt/data/dev/task-planner-skill-worktrees/task-variant-upgrade-20261113`
- 范围：仅 `skills/task-planner/templates/variant/` 下 9 个目标文件；未改 mini-lite/l0-lite；未 commit。

## 逐文件处置记录

| 文件 | 改前三件套(grep goal-id/\|ID\|/Batch) | 改前标题数 | 处置 | 改后(goal/id10/batch) | 改后标题数 | 备注 |
|------|--------------------------------------|-----------:|------|-----------------------|-----------:|------|
| audio-voice-type.md | NONE | 9 | 追加 §1 统一增量块到文件末尾（先 Read 尾 5 行） | 1/1/1 | 12 | 原无三件套；无 7 列表需替换 |
| bugfix-type.md | NONE | 17 | 追加 §1 统一增量块到文件末尾 | 1/1/1 | 20 | 原无三件套 |
| character-design-type.md | NONE | 11 | 追加 §1 统一增量块到文件末尾 | 1/1/1 | 14 | 原无三件套 |
| code-edit-type.md | NONE | 17 | 追加 §1 统一增量块到文件末尾 | 1/1/1 | 20 | 原无三件套 |
| deployment-type.md | NONE | 6 | 追加 §1 统一增量块到文件末尾 | 1/1/1 | 9 | 原无三件套 |
| diagnostic-type.md | NONE | 10 | 追加 §1 统一增量块到文件末尾 | 1/1/1 | 13 | 原无三件套 |
| final-assembly-type.md | NONE | 8 | 追加 §1 统一增量块到文件末尾 | 1/1/1 | 11 | 原无三件套 |
| image-type.md | NONE | 10 | 追加 §1 统一增量块到文件末尾 | 1/1/1 | 13 | 原无三件套 |
| memory-hygiene-type.md | NONE | 8 | 追加 §1 统一增量块到文件末尾 | 1/1/1 | 11 | 原无三件套 |

## 自检输出（原文）

### 1) 三件套计数（goal/id10/batch + headings）
```
audio-voice-type.md: goal=1 id10=1 batch=1 headings=12
bugfix-type.md: goal=1 id10=1 batch=1 headings=20
character-design-type.md: goal=1 id10=1 batch=1 headings=14
code-edit-type.md: goal=1 id10=1 batch=1 headings=20
deployment-type.md: goal=1 id10=1 batch=1 headings=9
diagnostic-type.md: goal=1 id10=1 batch=1 headings=13
final-assembly-type.md: goal=1 id10=1 batch=1 headings=11
image-type.md: goal=1 id10=1 batch=1 headings=13
memory-hygiene-type.md: goal=1 id10=1 batch=1 headings=11
```

### 2) 错字防扩散（窗格态/辋入）
```
NO_MATCH
```
（命令 `grep -n '窗格态\|辋入' <九文件>` 无命中）

### 3) git diff --stat（worktree 内，variant 目录）
```
 .../templates/variant/audio-voice-type.md          | 22 ++++++++++++++++++++++
 .../task-planner/templates/variant/bugfix-type.md  | 22 ++++++++++++++++++++++
 .../templates/variant/character-design-type.md     | 22 ++++++++++++++++++++++
 .../templates/variant/code-edit-type.md            | 22 ++++++++++++++++++++++
 .../templates/variant/deployment-type.md           | 22 ++++++++++++++++++++++
 .../templates/variant/diagnostic-type.md           | 22 ++++++++++++++++++++++
 .../templates/variant/final-assembly-type.md       | 22 ++++++++++++++++++++++
 .../task-planner/templates/variant/image-type.md   | 22 ++++++++++++++++++++++
 .../templates/variant/memory-hygiene-type.md       | 22 ++++++++++++++++++++++
 9 files changed, 198 insertions(+)
```

### 4) mini-lite/l0-lite 对 master diff（必须空）
```
EXIT:0
```
（`git diff master -- skills/task-planner/templates/variant/mini-lite-type.md skills/task-planner/templates/variant/l0-lite-type.md` 无输出）

## 结论
- 9/9 文件已追加 §1 三结构块；三件套各 ≥1；标题数均只增不减；无错字扩散；仅 9 文件变更；mini-lite/l0-lite 未改。
- 风险：低。均为文件末尾追加统一块，未触碰既有段落与 VC 语义；未运行仓库脚本校验（非本任务要求）。
