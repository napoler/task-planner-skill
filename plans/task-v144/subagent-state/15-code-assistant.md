# checkpoint: sub:15-code-assistant（task-v144 S15 存量清账）
status: done

## 任务
7 个 selftest 的 config properties 键数断言 40→42（v145 已合法新增 2 键，FF 守护 42 为准）。

## 修改（全部三同步：断言 + docblock + 诊断串 + 头注释）
worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v144/skills/task-planner/scripts/
统一级联锚注释：`[2026-10-08 task-v144 合并级联: v145 新增 2 键(config=42),FF 守护 42 为准,旧定数 40→42]`

| 文件 | 断言 | 位置 |
|---|---|---|
| selftest-agent-coverage.sh | AC-07 | 头注释 L6 / 段注释 L173-174 / 断言 L180 |
| selftest-ask-default-timeout.sh | RT-09 | 头注释 L13 / 段注释 L72-73 / 断言 L76 |
| selftest-capability-persistence.sh | CP-16 | 头注释 L11 / 段注释 L147-149 / 断言 L152-156（jq+python3 双分支） |
| selftest-media-agents.sh | MA-10 | 头注释 L6 / 段注释 L139-140 / 断言 L146 |
| selftest-media-dispatch.sh | MD-08 | 头注释 L5 / 段注释 L75-76 / 断言 L82 |
| selftest-requirement-grading.sh | RG-07 | 头注释 L5 / 段注释 L97-98 / 断言 L104 |
| selftest-reliability-institution.sh | R-12 | 头注释 L17 / 段注释 L93-94 / 断言 L97 |

## 附带级联（超出 7 定数清单的既有 FAIL 消除，依据 IP-12 宽容正则先例 — SKILL.md L273 全集声明已演进为「Rule 40-62」）
- selftest-capability-persistence.sh：CP-05 `40-55`=1 → 宽容正则 `40-[56][0-9]`=1；CP-06 负断言对象 `40-53` → `40-5[3-9]`（覆盖 40-53..40-59 全部旧纪元，语义强度不降）；头注释 L7 与 Why 段 L24 同步
- selftest-reliability-institution.sh：R-09 宽容正则 `40-5[3-9]` → `40-[56][0-9]`；头注释 L13、断言 L83-85、ok/bad 串同步

## 验证（实跑原文行，7/7 FAIL=0）
- selftest-agent-coverage.sh → `Total: 9 PASS=9 FAIL=0 SKIPPED=0`
- selftest-ask-default-timeout.sh → `Total: 11 PASS=11 FAIL=0`
- selftest-capability-persistence.sh → `Total: 20 PASS=20 FAIL=0`
- selftest-media-agents.sh → `Total: 10 PASS=10 FAIL=0`
- selftest-media-dispatch.sh → `Total: 9 PASS=9 FAIL=0`
- selftest-requirement-grading.sh → `Total: 7 PASS=7 FAIL=0`
- selftest-reliability-institution.sh → `Total: 16 PASS=16 FAIL=0`

## 负结果
- 改前 git stash 对照：CP-16/R-12 FAIL「键数=42（应 40）」确认根因；stash pop 已恢复
- git diff --name-only：本 S-unit 改动仅 7 目标文件；worktree 中其余 M 文件（SKILL.md、selftest-evidence-goal-gate.sh、execution-stability、iteration-persistence、knowledge-brief、lane-advancement、registry.tsv、requirement-coverage、self-resolution、tool-selection、workflow-orchestration）为前序 S1-S14 单元既有产物，零触碰
- 未 git add/commit

## 计划三文件已更新
- findings.md：追加 `#### [sub:15-code-assistant]` 至 Research Findings 段末
- progress.md：Phase 3 Actions taken 追加 `[sub:15]` 摘要行
