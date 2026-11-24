<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Verification: task-todo-default-engine-20261123

- task_id: `task-todo-default-engine-20261123`
- 时间: created_at=2026-11-22T20:05:05Z / updated_at=2026-11-22T21:09:16Z

## Goal (1 sentence)
- 通过 todo 默认基线项 B6/B7/B8 使引擎检测/对齐/worktree 检查自动带出，修复软契约无载体根因
- 对齐落地 — 旧计划 task-align 交付物吸收不丢弃
- worktree 隔离核验入 todo 默认项
- 三层载体（产出器+模板+守护）落地 B6/B7/B8 且 sync-todos --json 输出 B 组
- 定位守正（不推翻既有 / 核心定位知识·记忆体系 / 硬门仅登记）

---
## Verification Contract（VC 状态与判据）
| id | status | criterion | command | evidence | tags |
|---|---|---|---|---|---|
| VC-1 | pass | 引擎检测进 todo 默认项：todo-sync.md 契约含 B6 且文案含“引擎检测” | grep -Fq 'B6' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && grep -Fq '引擎检测' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && echo PASS |  |  |
| VC-2 | pass | 对齐落地入默认项：todo-sync.md 契约含 B7 且文案含“对齐” | grep -Fq 'B7' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && grep -Fq '对齐' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && echo PASS |  |  |
| VC-3 | pass | worktree 隔离核验入默认项：todo-sync.md 契约含 B8 且文案含“worktree” | grep -Fq 'B8' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && grep -Fq 'worktree' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && echo PASS |  |  |
| VC-4 | pass | 产出器真出 B 组：sync-todos.sh --json 输出须真实包含 B6、B7、B8（acceptance#3 强断言） | bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh --json /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123 \| grep -q 'B6' && bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh --json /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123 \| grep -q 'B7' && bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh --json /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123 \| grep -q 'B8' && echo PASS |  |  |
| VC-5 | pass | 模板露出+守护锚：task_plan.md 模板含 B6，selftest-skill-collab.sh 含“引擎检测”锚断言 | grep -Fq 'B6' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md && grep -Fq '引擎检测' /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-skill-collab.sh && echo PASS |  |  |
| VC-6 | pass | 守正+零回归：B1-B5 在 todo-sync.md 逐字保留，且 3 个相关 selftest（skill-collab/doc-script-paths/session-log）实跑 0 FAIL | for a in B1 B2 B3 B4 B5; do grep -Fq "$a" /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md \|\| exit 1; done; for s in selftest-skill-collab.sh selftest-doc-script-paths.sh selftest-session-log.sh; do bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/$s >/dev/null 2>&1 \|\| exit 1; done; echo PASS |  |  |
| VC-7 | pass | worktree 冲突补救 SOP 落盘：worktree-isolation.md 含"冲突补救"锚且给出检出同写→补建worktree→迁移改动→后期合并的可操作步骤 | grep -Fq '冲突补救' /mnt/data/dev/task-planner-skill/skills/task-planner/references/worktree-isolation.md && echo PASS |  |  |

## Phase Gates
| Goal | Depends on | Done when | Checks | Status |
|---|---|---|---|---|
| （本任务暂无Phase Gates 记录） |  |  |  |  |

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|---|---|---|
| （本任务暂无知识符合性记录） |  |  |

## 委派统计复验（Rule 25.4）
- （本任务暂无委派复验记录）

## 质量门控统计（Rule 26）
- （本任务暂无质量门控记录）

## Goal Gate (终验，所有 phase complete 后执行)
- （本任务暂无Goal Gate 记录）

---
## 交叉验证记录（Rule 108）
| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|---|---|---|---|
| （本任务暂无交叉验证记录） |  |  |  |

## 5-Question Reboot Check
| # | Question | Answer (fill on resume) |
|---|---|---|
| （本任务暂无5Q 记录） |  |  |
