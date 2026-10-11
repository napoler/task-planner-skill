# 01 P2-S1 checkpoint — general-review 范式技能（executor）

## 结论
- status: done
- 新建 `skills/task-planner/review-library/general-review/SKILL.md`（兜底池成员 1/10,范式锚定标杆）
- 四要素齐备（frontmatter / 触发条件 / 审查清单 / 输出合约）+「## 证据要求」段
- 审查清单 15 条 `- [ ]`（≥10）；无 tab；无「1-4x」越界字面；未触碰本文件外任何文件

## 验收命令输出（原样）
| 验收项 | 命令 | 结果 |
|--------|------|------|
| 1 行数 | `wc -l < SKILL.md` | 50（50-70 内） |
| 2 frontmatter | `head -5`；`grep -cP '\t'` | name+description 可见；tab=0 |
| 3 四要素 | `grep -c` 各标题 | 触发条件/审查清单/证据要求/输出合约 各=1 |
| 4 清单条目 | `grep -c '^- \[ \]'` | 15 |
| 5 关键词 | `grep -c` | APPROVED=4 / CHANGES_REQUESTED=5 / Rule 43.1=1 |
| 6 目录 | `ls review-library/` | 恰 1 目录 general-review |
| 7 git | `git -C <wt> status --short` | `?? skills/task-planner/review-library/`（仅该文件 untracked） |

## 证据
- 文件位置: `/mnt/data/dev/task-planner-skill-worktrees/task-v100-review-library/skills/task-planner/review-library/general-review/SKILL.md:1-50`
- 来源注释行（tail）: `<!-- task-v100-review-library 兜底池成员 1/10;Rule 42.2 第④层消费;范式锚定文件 -->`
- Rule 43.1 引文核对: critical-rules.md:429 原文「证据先行反幻觉」,SKILL.md 在「## 证据要求」段以「呼应 Rule 43.1 证据先行」字样引用,引用准确

## 遗留 / 未验证
- 无。文件已存在且逐条验收通过；未做 git add/commit（任务书禁止）。
- 后续 S2-S4 将按本文件范式对标产出，本文件作为质量与结构一致性的锚。

## 返回 8 字段
status: done
phase: P2-S1
completed_steps:
  1. 解析 01-task-brief.md，确认 worktree 目标路径与四要素合约
  2. 建 review-library/general-review/ 目录并新建 SKILL.md（50 行）
  3. 执行 acceptance 7 条机械验证，全部通过
  4. 落盘本 checkpoint
files_written:
  - /mnt/data/dev/task-planner-skill-worktrees/task-v100-review-library/skills/task-planner/review-library/general-review/SKILL.md
  - /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/subagent-state/01-exec-p2s1.md
evidence: "wc -l=50; head -5 见 name/description; tab=0; 四标题各=1; 清单 15; APPROVED=4/CHANGES_REQUESTED=5/Rule 43.1=1; '1-4x'=0; ls review-library/=general-review(恰1); git status --short=?? skills/task-planner/review-library/"
issues: 无
next_step: 主进程回填 task_plan S1→done + 派发 P2-S2（code/test/security 三技能按 S1 范式对标）
self_check: "acceptance 7 条逐一: [1 行数50内 50-70]OK [2 frontmatter head -5 + tab=0]OK [3 四要素各≥1]OK [4 清单15≥10]OK [5 APPROVED/CHANGES_REQUESTED/Rule 43.1 各≥1]OK [6 ls 恰1目录]OK [7 git 仅该文件 untracked]OK —— 7/7 通过"
