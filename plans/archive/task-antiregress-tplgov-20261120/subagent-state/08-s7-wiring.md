# 08-s7 主动加载强化（general 兜底须登记理由）checkpoint

## 里程碑
- 2026-11-19T22:06:xxZ 定位：init-session.sh:923/956(template-sense general/unknown emit)、check-complete.sh:673-676(template-sense warn)、plan-template-advisor/SKILL.md:51(边界铁律段)；自测存在 selftest-template-sense.sh（case-1~8）。
- 2026-11-19T22:07:56Z 落地：init-session.sh 两处追加 `[init] ⚠ general 兜底须登记理由（R3...）` 提示行；check-complete.sh T3 模板感知段后追加 `[template-sense]` warn（含“登记理由”且要求 plans/ 类型分布数据依据，不做硬门）；plan-template-advisor SKILL.md 边界铁律段首追加条款 `> general 兜底非静默默认：选用 general 须在计划「🔁 模板感知」区块登记理由...`。
- 2026-11-19T22:07:56Z 验证：VC-08 grep 命中 init-session.sh:924,958 / check-complete.sh:677,680,681 / plan-template-advisor/SKILL.md:53；diff 仅 +行（init +2, check-complete +6, advisor +2，共 +10/-0）；selftest-template-sense.sh Total:8 PASS=8 FAIL=0 rc=0。

## 103.2 自审（逐条对照材料包 §2）

| # | 条目 | 结论 | 证据锚 |
|---|------|------|--------|
| 1 | VC-08：`grep -n "登记理由"` 在 init-session.sh / check-complete.sh / plan-template-advisor/SKILL.md 三文件各≥1 命中 | PASS | `grep -n "登记理由" skills/task-planner/scripts/init-session.sh skills/task-planner/scripts/check-complete.sh skills/plan-template-advisor/SKILL.md` → `skills/task-planner/scripts/init-session.sh:924`(及515,958) `skills/task-planner/scripts/check-complete.sh:677,680,681`(及1686 既有) `skills/plan-template-advisor/SKILL.md:53` |
| 2 | 既有行为零破坏：相关既有 selftest rc=0；check-complete.sh 改动仅 +行（git diff 无删除） | PASS | `bash skills/task-planner/scripts/selftest-template-sense.sh` → `Total: 8 PASS=8 FAIL=0` `RC=0`（case-1~8 含 general 空缺/unknown/known/mini/re-run 负例）；`git diff -U0 -- <3files> \| grep '^-' \| grep -v '^---'` → `(no deletion lines)` |
| 3 | 改动面=3 文件、≤20 行新增 | PASS | `git diff --numstat -- ...` → `2 0 skills/task-planner/scripts/init-session.sh`, `6 0 skills/task-planner/scripts/check-complete.sh`, `2 0 skills/plan-template-advisor/SKILL.md`（合计 +10/-0，3 文件） |
| 4 | 103.2 自审逐条对照，证据锚 file:line 入 checkpoint | PASS | 本表；改动锚 `init-session.sh:923-924,957-958`、`check-complete.sh:677-682`、`plan-template-advisor/SKILL.md:53` |

## 最终结论
```text
status: done
acceptance: 4/4 — [1:PASS 2:PASS 3:PASS 4:PASS]
files: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/task-planner/scripts/init-session.sh(+2/-0); /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/task-planner/scripts/check-complete.sh(+6/-0); /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/plan-template-advisor/SKILL.md(+2/-0)
evidence: grep -n "登记理由" 3files→init-session.sh:924,958 / check-complete.sh:677,680,681 / plan-template-advisor/SKILL.md:53; git diff --numstat 3files→2/0,6/0,2/0(total +10/-0); git diff -U0 3files deletions→(none); bash skills/task-planner/scripts/selftest-template-sense.sh→Total:8 PASS=8 FAIL=0 RC=0
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/subagent-state/08-s7-wiring.md (status: done)
findings_written: #### [sub:08-s7]
blockers: none
confidence: HIGH
```
