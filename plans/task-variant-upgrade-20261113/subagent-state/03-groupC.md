# 03-groupC checkpoint — variant 三结构升级（2026-11-13）

## 范围与锚点
- worktree: `/mnt/data/dev/task-planner-skill-worktrees/task-variant-upgrade-20261113`
- 计划/依据: `plans/task-variant-upgrade-20261113/findings.md`（§1 统一增量块、§2 处置规则、§3 特例、§4 分组）
- 组 C（10）：`research-type.md` `rule-enhancement-type.md` `schema-migration-type.md` `script-dev-type.md` `storyboard-type.md` `test-writing-type.md` `video-fix-type.md` `video-prompt-type.md` `video-type.md` `writing-type.md`

## 每文件处置记录（含 106.1a 结构回读）
| 文件 | grep 三件套（改前） | 处置 | h2 改前->改后 |
|------|----------------------|------|---------------|
| research-type.md | goal-id/`\| ID \|`/Batch 均无 | EOF 追加 §1 完整统一块（Goal+Phases骨架+Batch） | 10->13 (+3) |
| rule-enhancement-type.md | 有 `\| ID \|`(L58, 7列)；无 goal-id/Batch | 将 Phase2 下 7 列 S-unit 表(L58-60, 表头+分隔+数据行)替换为 §1 10 列新口径表（保留段落/标题语境）；EOF 追加 Goal+Batch 块（不重复 Phases 骨架） | 11->13 (+2) |
| schema-migration-type.md | 三件套均无 | EOF 追加 §1 完整统一块 | 17->20 (+3) |
| script-dev-type.md | 三件套均无 | EOF 追加 §1 完整统一块 | 10->13 (+3) |
| storyboard-type.md | 三件套均无 | EOF 追加 §1 完整统一块 | 9->12 (+3) |
| test-writing-type.md | 三件套均无 | EOF 追加 §1 完整统一块 | 17->20 (+3) |
| video-fix-type.md | 三件套均无 | EOF 追加 §1 完整统一块 | 11->14 (+3) |
| video-prompt-type.md | 三件套均无 | EOF 追加 §1 完整统一块 | 9->12 (+3) |
| video-type.md | 三件套均无 | EOF 追加 §1 完整统一块 | 12->15 (+3) |
| writing-type.md | 三件套均无 | EOF 追加 §1 完整统一块 | 10->13 (+3) |

- goal-id 表列名空格问题：10 文件均无既有 goal-id 表，未触发修列名。
- 特例执行：`rule-enhancement-type.md` 旧 7 列表头 `| ID | 目标(≤1 句) | 执行体 | 输入 | 验收(可观察) | 预估时长 | 状态 |` 已替换为 10 列（含 `粒度(三值)|伴飞技能|前置依赖` 与占位行 `S1 | （A6） | 继承 | ... | 1f/10l/10min | 无 | - | pending |`）。
- mini-lite-type.md / l0-lite-type.md 未触碰。

## 组自检（原文）

### 1) goal/id10/batch
```text
research-type.md: goal=1 id10=1 batch=1
rule-enhancement-type.md: goal=1 id10=1 batch=1
schema-migration-type.md: goal=1 id10=1 batch=1
script-dev-type.md: goal=1 id10=1 batch=1
storyboard-type.md: goal=1 id10=1 batch=1
test-writing-type.md: goal=1 id10=1 batch=1
video-fix-type.md: goal=1 id10=1 batch=1
video-prompt-type.md: goal=1 id10=1 batch=1
video-type.md: goal=1 id10=1 batch=1
writing-type.md: goal=1 id10=1 batch=1
```

### 2) rule-enhancement 旧 7 列表头计数
```text
---old7-header---
0
```

### 3) 乱码/禁词扫描（窗格态|辋入）
```text
---garble---
(none)
```

### 4) git diff --stat（10 文件）
```text
---diff-stat---
 .../templates/variant/research-type.md             | 22 +++++++++++++++++++++
 .../templates/variant/rule-enhancement-type.md     | 23 +++++++++++++++++++---
 .../templates/variant/schema-migration-type.md     | 22 +++++++++++++++++++++
 .../templates/variant/script-dev-type.md           | 22 +++++++++++++++++++++
 .../templates/variant/storyboard-type.md           | 22 +++++++++++++++++++++
 .../templates/variant/test-writing-type.md         | 22 +++++++++++++++++++++
 .../templates/variant/video-fix-type.md            | 22 +++++++++++++++++++++
 .../templates/variant/video-prompt-type.md         | 22 +++++++++++++++++++++
 .../task-planner/templates/variant/video-type.md   | 22 +++++++++++++++++++++
 .../task-planner/templates/variant/writing-type.md | 22 +++++++++++++++++++++
 10 files changed, 218 insertions(+), 3 deletions(-)
```

### 5) mini-lite/l0-lite 与 master diff
```text
---lite-diff---
EXIT:0
```
（输出为空，表示无差异）
