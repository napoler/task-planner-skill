# S6 executor checkpoint — README+INSTALL 指针旧语义改述

任务: 按 findings.md [sub:4] 级联清单改述 README.md(:100-101) 与 INSTALL.md(:189) 指针旧语义（全局 legacy→工作树内瞬态 fallback，退役 legacy/移交叙事）。

## 里程碑
- [2026-10-10] 读 6-prompt-material.md + findings.md[sub:4] 清单 + README.md/INSTALL.md 全文；基线 grep 定位 `全局 legacy` = README:100,101 / INSTALL:189（rc=0，3 hits）
- [2026-10-10] README.md 改述完成：:100/:101 `全局 legacy .active_plan`→`全局 fallback .active_plan`（:100 补「（工作树内瞬态兜底）」），邻行新增 `│   # [2026-10-10 task-v164]` 注记（原措辞说明+三点语义+退役叙事）；净 +1 行
- [2026-10-10] INSTALL.md 改述完成：:189 `全局 legacy plans/.active_plan`→`全局 fallback plans/.active_plan`（补「（工作树内瞬态兜底，路径随 $PWD 本地化）」）+ 行内 `[2026-10-10 task-v164 补注：...]`；行数不变
- [2026-10-10] 验收三项复跑全过（见下）

## 最终结论
```
status: done
acceptance: 3/3 pass — A1 `grep -c 'task-v164' README.md INSTALL.md` → README.md:1 / INSTALL.md:1（各≥1）; A2 `grep -nE '全局 legacy' README.md INSTALL.md` → 空 rc=1（=0）; A3 `git diff --stat` → skills/task-planner/INSTALL.md(2 +-) + skills/task-planner/README.md(5 +++--) 仅两文件（第三行 .dispatch-inflight 为派发期既有 M，非本次产生），安装命令/表格零改动（diff 仅两 hunk）
files: /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/skills/task-planner/README.md (+3/-2); /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/skills/task-planner/INSTALL.md (+1/-1)
evidence: README.md:100 `全局 fallback .active_plan（工作树内瞬态兜底）`; README.md:102 新增 `│   # [2026-10-10 task-v164] 上两行原措辞以 legacy 描述该层...`; INSTALL.md:189 `全局 fallback plans/.active_plan 仅兜底（工作树内瞬态兜底，路径随 $PWD 本地化）[2026-10-10 task-v164 补注：...]`; 命令→`grep -c 'task-v164'`=README:1/INSTALL:1、`grep -nE '全局 legacy'` 空 rc=1
checkpoint: /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/plans/task-v164-pointer-worktree-local/subagent-state/6-executor.md (status: done)
findings_written: #### [sub:6-executor] S6 README+INSTALL 改述
blockers: none
confidence: HIGH
```
