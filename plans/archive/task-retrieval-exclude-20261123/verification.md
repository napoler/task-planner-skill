<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Verification: task-retrieval-exclude-20261123

- task_id: `task-retrieval-exclude-20261123`
- 时间: created_at=2026-11-22T19:45:57Z / updated_at=2026-11-22T19:52:14Z

## Goal (1 sentence)
- （本任务暂无Goal 语句）

---
## Verification Contract（VC 状态与判据）
| id | status | criterion | command | evidence | tags |
|---|---|---|---|---|---|
| VC-1 | pass | 清单文档存在且含条件化表格(可排除/必须纳入两栏)+trash条目+维护日志 | test -f /mnt/data/dev/task-planner-skill/RETRIEVAL_EXCLUDE.md && grep -q 可排除场景 /mnt/data/dev/task-planner-skill/RETRIEVAL_EXCLUDE.md && grep -q 必须纳入场景 /mnt/data/dev/task-planner-skill/RETRIEVAL_EXCLUDE.md && grep -q trash /mnt/data/dev/task-planner-skill/RETRIEVAL_EXCLUDE.md && echo PASS |  |  |
| VC-2 | pass | Rule 112 六子条全文在 critical-rules.md | f=/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md; for n in 112.1 112.2 112.3 112.4 112.5 112.6; do grep -q "^$n " "$f" \|\| exit 1; done; echo PASS |  |  |
| VC-3 | pass | SKILL.md 摘要含 Rule 112 指针且数字索引未改 | grep -q "检索排除清单纪律" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -q "Rules 1-110" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && echo PASS |  |  |
| VC-4 | pass | 5部署位 SKILL.md+critical-rules.md 全部含112锚且diff一致 | for d in /mnt/data/dev/task-planner-skill/skills/task-planner /home/terry/.zcode/skills/task-planner /home/terry/.claude/skills/task-planner /home/terry/.config/opencode/skills/task-planner /home/terry/.cursor/skills/task-planner /home/terry/.agents/skills/task-planner; do grep -q 检索排除清单纪律 "$d/SKILL.md" \|\| exit 1; grep -q "^112.1 " "$d/references/critical-rules.md" \|\| exit 1; done; echo PASS |  |  |

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
