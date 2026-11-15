# 3a-skill-cascade checkpoint (Rule 108 接线到两个 SKILL.md)

## T1 侦察与锚点定位
- Read: `plans/task-crossvalidate-20261115/{task_plan,findings,progress,knowledge-brief,clause-drafts}.md`
- Read worktree targets:
  - `tmp/worktrees/task-crossvalidate-20261115/skills/verification-gate/SKILL.md`
  - `tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/SKILL.md`
- Anchors (grep -n): verification-gate `description:3`, `## 调用时机:24`, `## References:87`, `84.1-84.6:91`; task-planner `1-107/其余90条:9,224,267`, `Rule 84）路由:220`.

## T2 verification-gate/SKILL.md 增量编辑
- :3 description 句中增加 `、交叉验证识别执行错误与虚构（Rule 108）`（适配验收：使 description 含 Rule 108）。
- :24-31 调用时机末尾追加 `7. 终验/子代理产出采信前需隔离双视角交叉验证或识别伪造信号时（Rule 108）`。
- References 行 `84.1-84.6` → `84.1-84.14, Rule 108`（保留原用途描述，其余邻行未动）。

## T3 task-planner/SKILL.md 增量编辑
- :9 `Rules 1-107`→`Rules 1-108`，`其余 90 条`→`其余 94 条`。
- :220 verification-gate 路由行 rule 列 `（Rule 84）`→`（Rule 84,108）`。
- :224 `1-107`→`1-108`，`其余 90 条`→`其余 94 条`，并在 `（均 task-discipline 卫星））` 后、`——**非核心域` 前插入 `、Rule 108 交叉验证纪律域（verification-gate 卫星）`（括号配对保持合法）。
- :267 `1-107`→`1-108`。

## T4 结构回读与验收
- `grep -c 'Rule 108' verification-gate/SKILL.md` → 3 (>=2) @ :3,:32,:92
- `grep -c 'Rule 84,108' task-planner/SKILL.md` → 1 @ :220
- `grep -c '1-108' task-planner/SKILL.md` → 3 @ :9,:224,:267
- `grep -c '1-107' task-planner/SKILL.md` → 0
- `其余 94 条` @ :9,:224；无 `其余 90 条`。锚行子串均保留，未改动既有邻行内容（106.1a 回读通过）。

## T5 最终结论
status: done
acceptance: 3/3 pass — [1:PASS (grep -c 'Rule 108' verification-gate/SKILL.md=3) 2:PASS (Rule 84,108=1, 1-108=3, 1-107=0) 3:PASS (锚行定点替换，grep -n 回读邻接结构未见非目标改动)]
files: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115/skills/verification-gate/SKILL.md(+2/-1); /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/SKILL.md(+4/-4)
evidence: verification-gate/SKILL.md:3,32,92 含 "Rule 108" (grep -c=3)；task-planner/SKILL.md:220 含 "Rule 84,108"；task-planner/SKILL.md:9,224,267 含 "1-108" 且 "其余 94 条"@9,224；`grep -c '1-107' task-planner/SKILL.md`→0；`git diff --numstat -- skills/verification-gate/SKILL.md skills/task-planner/SKILL.md`→`2\t1\t...verification-gate/SKILL.md`、`4\t4\t...task-planner/SKILL.md`
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-crossvalidate-20261115/subagent-state/3a-skill-cascade.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
