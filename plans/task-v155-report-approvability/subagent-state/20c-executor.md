# S20c RF-07 守卫钉值级联检查点（sub:20c-executor）

- 单元类型：纯机械守卫修正（v151 级联判例复现）
- 修复文件：SKILL.md:287（头注恢复子串结构）、selftest-research-first.sh:73（RF-07 断言字面级联）
- 只读输入：task_plan.md（未修改）；findings/progress 仅追加

## 背景（根因）

S20b 把 SKILL.md:287 头注改为「Critical Rules 1-66+70（67-69 并行任务预留）（含 Rule 40-65 全集…」，
使 RF-07 断言字面 `Critical Rules 1-66（含 Rule 40-65 全集` 子串消失（`1-66（含` 被改写为 `1-66+70（67-69…）（含`），
守卫 RF-07 双锚之一落空 → 级联断裂。修法=两侧同步恢复（头注结构 + 守卫钉值）。

## 修复明细

### 修复 1：SKILL.md:287 头注
- 原文段：`Critical Rules 1-66+70（67-69 并行任务预留）（含 Rule 40-65 全集，Rule 55 …`
- 改为：`Critical Rules 1-66+70（含 Rule 40-65 全集 + Rule 70 用户呈报可审批性纪律，67-69 并行任务预留）（含 Rule 40-65 全集，Rule 55 …`
- 依据：保留 1-66+70 同步成果 + 下文规则名列表原文，恢复「含 Rule 40-65 全集」子串结构（消除 S20b 改写打翻的 RF-07 锚）

### 修复 2：selftest-research-first.sh:73 RF-07 断言
- 原文：`"$(cnt 'Critical Rules 1-66（含 Rule 40-65 全集' "$SKILL")"  # 2026-10-09 task-v151 S4 钉值级联`
- 改为：`"$(cnt 'Critical Rules 1-66+70（含 Rule 40-65 全集' "$SKILL")"  # 2026-10-09 task-v151 S4 钉值级联；2026-10-10 task-v155 S20b 头注改写级联`
- 依据：钉值级联更新（字面随头注同步），注释追加级联来源

## 验证结果

1. `bash scripts/selftest-research-first.sh` → exit 0，Total: 12 PASS=12 FAIL=0
2. `grep -c "Critical Rules 1-66+70（含 Rule 40-65 全集" SKILL.md` = 1
3. `grep -c "1-66+70" SKILL.md` = 3（不降）
4. `git diff --stat` = 2 文件各 +1/-1；`git diff | grep '^-'` 仅 1 删除行（SKILL.md:287 原行）

## 最终结论

```
status: done
acceptance: 3/3 pass — [1:PASS `bash scripts/selftest-research-first.sh` exit 0 Total: 12 PASS=12 FAIL=0; 2:PASS `grep -c "Critical Rules 1-66+70（含 Rule 40-65 全集" SKILL.md`=1; 3:PASS `grep -c "1-66+70" SKILL.md`=3 不降 且 diff 删除行仅限被修行]
files: /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/SKILL.md(+1/-1); /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/selftest-research-first.sh(+1/-1); /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/findings.md(+1 段); /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/progress.md(+1 行)
evidence: SKILL.md:287（头注恢复「1-66+70（含 Rule 40-65 全集…」）; selftest-research-first.sh:73（断言 1-66→1-66+70）; selftest exit 0 PASS=12 FAIL=0; grep 双锚 1/1; 1-66+70 计数=3; diff 2 文件 +1/-1
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/subagent-state/20c-executor.md (status: done)
findings_written: #### [sub:20c-executor] RF-07 守卫钉值级联（S20b 头注改写两侧同步恢复）
blockers: none
confidence: HIGH
```
