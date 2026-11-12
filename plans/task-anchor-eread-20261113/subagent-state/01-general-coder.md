# 01-general-coder checkpoint — task-anchor-eread-20261113

## 目标
在隔离 worktree 对 Rule 106 追加 106.1a 子条（纯文本增量），并在 SKILL.md 3i 行尾追加传播面文案。

## 锚行号
- discipline: `skills/task-discipline/references/critical-rules-discipline.md:725` 插入 `**106.1a 结构文件插段纪律...**` 段（位于 106.1 L723 与 106.2 L727 之间）
- SKILL: `skills/task-planner/SKILL.md:105` 3i 行尾追加 `；结构文件插段另守 106.1a`

## 自检原文

### 1) 106.1a presence
```text
$ grep -c '106.1a' skills/task-discipline/references/critical-rules-discipline.md
1
$ grep -n '106.1a' skills/task-planner/SKILL.md
105:  - **3i 修改后复检（Rule 106）**：受管文档每次修改后回读校验跨字段不变量（106.1-106.4）；同文件 ≥2 次修改后全量回归（106.3）——细则→task-discipline Rule 106；结构文件插段另守 106.1a
```
备注：discipline 文件中 106.1a 文本以加粗段落 `**106.1a ...**` 逐字插入一次（findings §1 原文），该 token 在该文件出现 1 次；SKILL.md 出现 1 次。

### 2) 结构回读（106.1a 自证）
```text
$ grep -cE '^106\.[0-9]' skills/task-discipline/references/critical-rules-discipline.md
5
$ grep -nE '^106\.[0-9]' skills/task-discipline/references/critical-rules-discipline.md
723:106.1 **写后回读门（过程期，P0）**：...
727:106.2 **派生值先定基准（P0）**：...
729:106.3 **同文件二次修改全量回归（P1）**：...
731:106.4 **验证对象=交付物本体（P0）**：...
733:106.5 **两组 todo 驱动对齐（P0，2026-11-13 用户 B 扩展指令）**：...
$ grep -c '^### 106' skills/task-discipline/references/critical-rules-discipline.md
1
```
结论：`^106\.[0-9]` 主条 5 条（106.1-106.5）守恒，`### 106` 标题 1 条守恒；106.1a 以子段落插入未破坏主条计数/结构。

### 3) git diff --stat
```text
$ git diff --stat
 skills/task-discipline/references/critical-rules-discipline.md | 2 ++
 skills/task-planner/SKILL.md                                   | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)
```

## 风险
- 任务自检要求 `grep -c '106.1a' discipline 文件 ≥2`，但 findings §1 逐字文本在 discipline 中仅含一次 `106.1a` token；为保持“逐字插入”未重复 token，实际为 1（需协调者确认口径）。
- 未运行全量/相关 selftest（任务未要求）；仅做文本结构与 diff 自检。

## 时间戳
2026-11-13 (session)
