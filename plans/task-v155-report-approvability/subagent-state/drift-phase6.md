# Drift Check — Phase 6 偏移检查

**时间**: 2026-10-10
**载体**: Rule 61 载体 22.3.1 改派执行（只读+检查点）
**触发**: Phase 6 complete 前检查

## 检查项与证据

### 1. Git status — scope 核对

命令: `git -C /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability status --short`

输出:
```
 M skills/task-planner/scripts/check-complete.sh
 M skills/task-planner/scripts/selftest-registry.tsv
?? skills/task-planner/scripts/selftest-report-reviewability.sh
```

判定: 恰好 3 文件，与 Phase 6 scope 一致。selftest-report-reviewability.sh 为 untracked 新文件属正常（S12 新建）。

### 2. 范围限制表对照（task_plan.md:110 守护面行）

允许文件:
- `skills/task-planner/scripts/selftest-report-reviewability.sh`（新建）
- `skills/task-planner/scripts/selftest-registry.tsv`
- `skills/task-planner/scripts/check-complete.sh`

实际改动恰好匹配，无越界文件。

### 3. Selftest 自跑抽验

命令: `bash skills/task-planner/scripts/selftest-report-reviewability.sh`

输出末行: `Total: PASS=13 FAIL=0 WARN=0`

判定: FAIL=0，exit 0，RRV-01..13 全 PASS。

### 4. check-complete.sh fail-open 验证

命令: `git diff -U0 -- skills/task-planner/scripts/check-complete.sh | grep '^+' | grep -c 'exit 1'`

输出: `0`

判定: 新增行无 exit 1，exit 语义零改动（fail-open 守护成立）。

### 5. Numstat 对照 findings.md 记录

命令: `git diff --numstat -- skills/task-planner/scripts/check-complete.sh skills/task-planner/scripts/selftest-registry.tsv`

输出:
```
53	0	skills/task-planner/scripts/check-complete.sh
1	0	skills/task-planner/scripts/selftest-registry.tsv
```

判定: check-complete.sh +53/-0（与 S14 记录一致）、registry.tsv +1/-0（与 S15 记录一致）。

## 最终结论

```
status: done
acceptance: 5/5 pass — [1:PASS git status 恰 3 文件在 scope, 2:PASS selftest 自跑 Total PASS=13 FAIL=0 WARN=0, 3:PASS check-complete.sh 新增行 exit 1=0, 4:PASS numstat 对照 findings 记录一致, 5:PASS 范围限制表守护面行恰好匹配]
files: /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/selftest-report-reviewability.sh(新建) | /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/check-complete.sh(+53/-0) | /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/selftest-registry.tsv(+1/-0)
evidence: git status --short→3 文件; selftest 自跑→Total: PASS=13 FAIL=0 WARN=0; git diff exit 1 计数→0; numstat→53/0+1/0; task_plan.md:110 守护面行
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/subagent-state/drift-phase6.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
```
