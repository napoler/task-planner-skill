# 检查点 21-merge-4way — task-v152 Phase 6 四方合并机械解决单元

**执行时间**: 2026-10-10
**Worktree**: /mnt/data/dev/task-planner-skill-worktrees/v152-proactive-context
**状态**: COMPLETE

## 逐文件策略与核验

| # | 文件 | 策略 | 核验 |
|---|------|------|------|
| 1 | selftest-research-first.sh | RF-06 取 cnt '1-69'; RF-07 整串 Critical Rules 1-69（含 Rule 40-69 全集; RF-08/RF-10 零改动 | 12 PASS=12 FAIL=0 exit=0 |
| 2 | selftest-lane-advancement.sh | LA-12 与文案取 1-69; 1-39 负断言零改动 | 14 PASS=14 FAIL=0 exit=0 |
| 3 | selftest-self-resolution.sh | SR-07 取 1-69; SR-12 零改动 | 13 PASS=13 FAIL=0 exit=0 |
| 4 | selftest-tool-selection.sh | TS-05 取 1-69 | 12 PASS=12 FAIL=0 exit=0 |
| 5 | selftest-requirement-coverage.sh | RC-11 取 1-69; RC-15 ^66\.=6 正钉原样保留 | 23 PASS=23 FAIL=0 exit=0 |
| 6 | selftest-workflow-orchestration.sh | WF-10 循环 grep 与文案取 1-69; 注释链保留全代 | 16 PASS=16 FAIL=0 exit=0 |
| 7 | selftest-skill-split.sh | T-主钉取 -le 526; 三代演进注释全留; C45->C48 | 41 PASS=41 FAIL=0 exit=0 |
| 8 | selftest-registry.tsv | 所有新行保留（context-pressure+goal-unit+parallel-scheduling+decision-arbiter）; TAB 4 列 | 68 行全部 4 列 |
| 9 | selftest-goal-unit-goal-mode.sh | G-07 并集全表口径（grep -q）; master 侧其他变更并入 | 9 PASS=9 FAIL=0 exit=0 |
| 10 | selftest-drift-check-subagent.sh | DCS-11 取 Rule 40-69 全集 | bash -n exit=0 |
| 11 | CLAUDE.md | 标签取 1-69; 注释链保留全代 | git diff --check 无冲突标记 |
| 12 | README_zh.md | 标签取 1-69; 注释链保留全代 | git diff --check 无冲突标记 |
| 13 | skills/task-planner/README.md | 标签取 1-69; 11 核心计数保留 | git diff --check 无冲突标记 |
| 14 | CHANGELOG.md | 保留全部条目（v152 Rule 67 + v153 Rule 68 + v154 Rule 69） | git diff --check 无冲突标记 |
| 15 | SKILL.md | 三处 1-69; 行数 525 <= 526 | wc -l = 525 |
| 16 | critical-rules.md | Rule 67 条款在位; 1-69 标签 | git diff --check 无冲突标记 |
| 17 | selftest-context-pressure.sh | CP-07 演进为 1-69=3/CR1-69>=2/C48>=1; CP-08 适配为并集口径（grep -q） | 9 PASS=9 FAIL=0 exit=0 |

## 验收汇总

- git diff --check: 无冲突标记
- 14 脚本 bash -n: 全部 OK
- 10 脚本单跑: 全部 exit 0
- registry: 68 行全部 4 列
- SKILL.md 行数: 525 <= 526

## 备注

- 所有 16 个冲突文件内容已按规则正确解决（无冲突标记），git add 后标记为 resolved
- selftest-context-pressure.sh 无冲突但需并集适配：CP-07 已为 1-69 版本；CP-08 从末行口径适配为含口径（与 G-07 演进同构）
- 合并尚未 commit，等待主进程确认后执行 git commit
