# 13-impl-s10 checkpoint（S10 CR fix-phase，CA-13：Rule 94 正文七处修复）

status: done
date: 2026-10-23

## 目标文件（唯一）
/mnt/data/dev/task-planner-skill-worktrees/task-focus-plan-split-20261023/skills/task-discipline/references/critical-rules-discipline.md

## 修复登记（逐处 old 改前 grep -c=1 已核验 → Edit → new 改后 grep -c=1 已核验）
| # | 锚 | 行（改后） | 状态 |
|---|----|-----------|------|
| 1 | NIT-1：衔接清单补 /74（变更吸收与混写补救） | 605 | hit |
| 2 | P2-5：94.1 补「垂直域判别口径」定义句 | 610 | hit |
| 3 | P2-7：94.2③ 偏移方向判定锚（61.x 契约字段零改动） | 611 | hit |
| 4 | P2-6：94.3「并入当前计划重规划」改为纠正出口表述 | 612 | hit |
| 5 | P2-8+P2-9：`[focus-ask]` 暂记 + Rule 28 silent 档不停摆 | 612 | hit |
| 6 | P1-2：94.4② E 类确认与 94.3 询问门合并授权/未合并补确认 | 613 | hit |

## 验收 grep 原文输出
```
grep -c '垂直域判别口径' => 1
grep -c '\[focus-ask\]'  => 1
grep -c '纠正出口'       => 1
grep -c '74（变更吸收与混写补救）' => 1
grep -c '仅当两目标确属同域强关联'  => 0（旧文已消除）
grep -c '88（射程契约），既有规则条目原文零改动' => 0（旧文已消除）
```

## git 范围核对
- 改前 `git status --short`：干净（HEAD=571ad73 rule-reserve land 94）
- 改后 `git status --short`：仅 `M skills/task-discipline/references/critical-rules-discipline.md`
- `git diff --stat`：1 file changed, 5 insertions(+), 5 deletions(-)（6 处修复落在 5 行，612 行含 #4+#5 两处）
- 未 commit（worktree 内待主进程裁决收口）

## findings
- 无。6 处修复全部按 old→new 精确命中，无越界改动，既有 94.1-94.6 子条结构未变。
