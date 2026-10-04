# m4-executor checkpoint（S4: README_zh/INSTALL_zh companion agent 计数 3→6）

- S-unit: [parallel-group:G124] S4
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v124
- 执行时间: 2026-10-04（预算 20min，实际远未超）

## 执行轨迹
1. 防呆 grep `个伴生\|个配套` → 命中仅 2 处: README_zh.md:114（单行树状图「3 个伴生 agent（plan-writer 等）」）、INSTALL_zh.md:305-307（多行树状图「3 个配套 agent: plan-writer / article-batch-publisher / article-field-fixer, 部署到…）」
2. 全仓 grep 复核两文件内 agent 名/计数表述: 仅上述 2 处计数行需改；两文件无其他存量列表（如括号内 3-agent 枚举）。install.sh:179 与 INSTALL.md:137-139 属 brief §2 文档 stale 行的 S5 范围，本 S-unit 未触碰
3. Edit README_zh.md:114 → `← 6 个伴生 agent（plan-writer / article-batch-publisher / article-field-fixer / complex-planner / image-generation-executor / video-generation-executor）`（单行，树缩进未动）
4. Edit INSTALL_zh.md:305-307 → 计数 3→6，清单补全为 6 名，续行新增 2 行，前导空白与原续行（`                                     ` 37 空格起）逐字符一致，树末 `│   │` 等其它行未动
5. 验收: `grep '3 个伴生\|3 个配套'` 零命中（exit=1）；`grep '6 个伴生\|6 个配套'` 各 1 命中；`grep complex-planner\|image-generation-executor\|video-generation-executor` 命中；`git diff --stat` = README_zh.md(+1/-1)、INSTALL_zh.md(+4/-2)，diff 全文逐行复核仅命中树块

## 最终结论（8 字段块）
```
status: done
acceptance: 3/3 pass — [1] grep '3 个伴生\|3 个配套' README_zh.md INSTALL_zh.md → exit=1 零残留; [2] git diff --stat → README_zh.md(+1/-1) INSTALL_zh.md(+4/-2), 全文 diff 仅 companion 树块命中行, 树缩进逐字符对齐未破坏; [3] grep -n '6 个伴生\|6 个配套' 各 1 命中 + 'complex-planner\|image-generation-executor\|video-generation-executor' 命中, 两文件无其他存量计数/列表表述
files: /mnt/data/dev/task-planner-skill-worktrees/task-v124/README_zh.md(+1/-1); /mnt/data/dev/task-planner-skill-worktrees/task-v124/INSTALL_zh.md(+4/-2)
evidence: grep -n '3 个伴生\|3 个配套' → 0 行(exit=1); git diff → README 行 114 单行改 + INSTALL 行 305-308 改(续行前导 37 空白一致); git diff --stat → 2 files changed, 5 insertions(+), 3 deletions(-)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v124/subagent-state/m4-executor.md (status: done)
findings_written: findings.md §Research Findings 锚点 `#### [sub:S4] README_zh/INSTALL_zh companion agent 计数 3→6 修正`
blockers: none
confidence: HIGH
```

## 备注（供主进程验收）
- 目录实况核对: worktree `skills/task-planner/companion/agents/` 含 complex-planner.md(已提交 b7e8988)、image-generation-executor.md.tmp.*（S1 落盘中的临时名）、video-generation-executor.md（S2 新建，untracked）。6 计数口径以 S-unit 指令给定清单为准；S1 正式落盘改名后清单不变
- progress.md Phase 2「Actions taken」已追加 `  - [sub:S4] …` 行
