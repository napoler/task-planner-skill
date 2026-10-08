# 17-executor: task-v146 合并解纷执行体检查点

## 状态: FINAL (完成)

## 任务概述
worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v146` 内 `git merge master` 产生 10 个冲突文件，按逐文件政策解决。解决后不 git commit。

## 逐文件处置结果

### A 组：整体取 master 侧 (git checkout --theirs + git add)
1. **scripts/selftest-capability-persistence.sh** — checkout --theirs + git add。验证: Total: 20 PASS=20 FAIL=0
2. **scripts/selftest-execution-honesty.sh** — checkout --theirs + git add。验证: Total: 14 PASS=14 FAIL=0
3. **scripts/selftest-iteration-persistence.sh** — checkout --theirs + git add。验证: Total: 18 PASS=18 FAIL=0
4. **scripts/selftest-reliability-institution.sh** — checkout --theirs + git add。验证: Total: 16 PASS=16 FAIL=0
5. **scripts/selftest-root-resolution.sh** — checkout --theirs + git add。验证: Total: 17 PASS=17 FAIL=0
6. **scripts/selftest-self-resolution.sh** — checkout --theirs + git add。验证: Total: 13 PASS=12 FAIL=1 (SR-12/T02 基线预存 FAIL，允许)
7. **scripts/selftest-agent-coverage.sh** — checkout --theirs + git add + AC-09 上界 128→129（头注/注释/断言/ok/bad 文案同步，行尾 label 追加 `[2026-10-08 task-v146] drift-checker 行 +1`）。验证: Total: 9 PASS=8 FAIL=1 (AC-04 部署前暂态 FAIL，允许)

### B 组：并集手工解
8. **SKILL.md 冲突块 1（索引行）** — 整块替换为 `详见 \`references/critical-rules.md\`（Critical Rules 1-62（含 Rule 40-62 全集，Rule 55 可复用能力落盘纪律 / Rule 61 偏移检查子代理化））：`
9. **SKILL.md 冲突块 2（Rule 摘要 bullets）** — 两侧全保留，按编号排序 59→61→62，每条 bullet 原文逐字保留
10. **references/critical-rules.md** — 两侧全保留，顺序=Rule 61 整块在前，Rule 62 整块（含注释）与 Rule 59 整块（含注释）随后
11. **scripts/selftest-registry.tsv** — 两侧行都保留（drift-check-subagent.sh 行 + four-file-dataflow.sh 行），去除冲突标记

### C 组：我方守卫向合并现实对齐
12. **scripts/selftest-drift-check-subagent.sh** — DCS-11 断言条件从「含 `Rule 40-61` 且含 `Rules 1-39`」改为「含 `Rule 40-62 全集` 且含 `Rule 61 偏移检查子代理化`」，ok/bad 文案同步。验证: Total: 20 PASS=20 FAIL=0

## 验证结果

### 冲突标记清零
```
$ grep -rn '^<<<<<<<' --include='*' . | wc -l
0
```

### selftest-drift-check-subagent.sh
```
$ bash scripts/selftest-drift-check-subagent.sh 2>&1 | tail -1
Total: 20 PASS=20 FAIL=0
```

### A 组 7 脚本
```
selftest-capability-persistence.sh: Total: 20 PASS=20 FAIL=0
selftest-execution-honesty.sh:     Total: 14 PASS=14 FAIL=0
selftest-iteration-persistence.sh: Total: 18 PASS=18 FAIL=0
selftest-reliability-institution.sh: Total: 16 PASS=16 FAIL=0
selftest-root-resolution.sh:       Total: 17 PASS=17 FAIL=0
selftest-self-resolution.sh:       Total: 13 PASS=12 FAIL=1  (SR-12/T02 基线预存 FAIL，允许)
selftest-agent-coverage.sh:        Total: 9  PASS=8  FAIL=1  (AC-04 部署前暂态 FAIL，允许)
```

### SKILL.md / critical-rules.md 关键锚
```
$ grep -c 'Rule 40-62 全集' skills/task-planner/SKILL.md
1
$ grep -c 'Rule 61 偏移检查子代理化' skills/task-planner/SKILL.md
1
$ grep -c '^### 61 ' skills/task-planner/references/critical-rules.md
1
$ grep -c '^### 62 \|^### 59 ' skills/task-planner/references/critical-rules.md
2
```

### git diff --cached --stat (尾部)
```
116 files changed, 6616 insertions(+), 202 deletions(-)
```

### 残留冲突文件
```
$ git diff --name-only --diff-filter=U | wc -l
0
```

## 备注
- 未执行 git commit（留给主进程）
- 所有冲突文件已 git add 标记 resolved
- selftest-registry.tsv 中 master 侧的 selftest-periodic-review.sh 行按政策未保留（政策仅要求保留两行）
