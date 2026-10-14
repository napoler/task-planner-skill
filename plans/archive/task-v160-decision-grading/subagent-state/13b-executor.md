# 13b-executor — task-v160 S13b 守卫修正检查点

- 任务: 修 worktree 内 `skills/task-planner/scripts/selftest-decision-grading.sh` 两处 Nit（① cnt() 空串防护；② C49 锚注释与实现一致性）
- worktree: /mnt/data/dev/task-planner-skill-worktrees/v160-decision-grading
- 依据: subagent-state/11-code-reviewer.md（Nit#3 + Nit#4）
- 范围: 仅本脚本；未碰其他 worktree/文件；无 git add/commit/checkout/reset/push

## 改动摘要
- Nit#3（:70 cnt/cntE）: 原 `grep -c ... 2>/dev/null || true` 在「文件存在但不可读」时 stdout 空 → `[ "" -lt N ]` 报 `integer expression expected` 且静默吞错。改为 `n="$(grep -c -e "$1" "$2")"; printf '%s' "${n:-0}"`（三态均得合法整数），并去掉 `2>/dev/null`（grep/ugrep 权限报错可见，禁吞错）。cntE 同构。
- Nit#4（DG-04/DG-11 + header 文档）: 由硬断言 `C49` 改内容锚 `^| C[0-9]* | .*决策分级与用户打断`（文本锚替代行号锚，v155 RRV-04 同款教训；DG-03 已立「文本锚替代行号锚是本仓硬纪律」）。DG-11 与文件头 DG-04/DG-11 说明同步为同口径内容锚，保持「与 DG-04 同口径」为真。

## 关键证据
- `bash scripts/selftest-decision-grading.sh` → `Total: PASS=12 FAIL=0 WARN=0`（exit 0），stderr 空。
- 不可读文件模拟（chmod 000）调脚本内 cnt/cntE：新实现输出 `0` 无整数告警；旧实现输出空串并报 `[: : integer expression expected`（已复现）。
- 内容锚 grep 命中=1（唯一合规行 SKILL.md:231）；renumber 模拟（C49→C77）旧锚 0 命中 / 新锚 1 命中 → 级联免疫。
- `bash -n` OK；`git diff --stat` 本文件 +29/-21，删除行全为被修行行。

## 最终结论
status: done
acceptance: 4/4 pass — [1:PASS `bash scripts/selftest-decision-grading.sh` exit0 Total PASS=12 FAIL=0 WARN=0; 2:PASS 不可读文件模拟无 `integer expression expected`(cnt→0), stderr 空; 3:PASS DG-04 注释/实现一致=内容锚 `^| C<N> | .*决策分级与用户打断` 命中=1 且 DG-04 PASS; 4:PASS diff 删除行仅限被修行(cnt/DG-04/DG-11/header)]
files: /mnt/data/dev/task-planner-skill-worktrees/v160-decision-grading/skills/task-planner/scripts/selftest-decision-grading.sh (+29/-21) | /mnt/data/dev/task-planner-skill/plans/task-v160-decision-grading/findings.md (+1 blk) | /mnt/data/dev/task-planner-skill/plans/task-v160-decision-grading/progress.md (+1 blk)
evidence: selftest-decision-grading.sh:70 cnt() → `n="$(grep -c -e "$1" "$2")"; printf '%s' "${n:-0}"`; :112-114 DG-04 内容锚; 运行→"Total: PASS=12 FAIL=0 WARN=0"(exit=0); 不可读模拟→cnt 输出[0] 无告警; renumber 模拟→旧锚 0/新锚 1
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v160-decision-grading/subagent-state/13b-executor.md (status: done)
findings_written: ## Research Findings → #### [sub:13b-executor] selftest-decision-grading.sh 两处 Nit 修正（cnt 空串防护 + DG-04 内容锚）
blockers: none
confidence: HIGH
