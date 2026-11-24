# S8 Checkpoint: task-discipline SKILL Rule 106 索引 B1-B5 → B1-B8

- status: done
- timestamp: 2026-11-23
- target: /mnt/data/dev/task-planner-skill/skills/task-discipline/SKILL.md (line 86, Rule 106 index row)

## Change

Replaced in Rule 106 index row only:
- from: `两组 todo B1-B5`
- to: `两组 todo B1-B8（B6 引擎检测/B7 对齐/B8 worktree 核验）`

No other lines changed. Count sentence on line 89 untouched.

## Verification

Command: `cd /mnt/data/dev/task-planner-skill && grep -n 'B1-B8\|B1-B5' skills/task-discipline/SKILL.md | head -20`
Output:
```
86:| 106 | 文档修改复检与 todo 驱动对齐纪律（写后回读/派生值基准/同文件二次回归/交付物本体验证/两组 todo B1-B8（B6 引擎检测/B7 对齐/B8 worktree 核验））· task-docmod-recheck-20261112 | `references/critical-rules-discipline.md` `### 106` 段 |
```

Read-back (lines 84-88) confirms row intact and surrounding rows unchanged.

## Acceptance

- `grep -n 'B1-B8'` hits line 86: PASS
- `B1-B5` no longer appears on Rule 106 index row: PASS
- Only specified file touched: PASS
