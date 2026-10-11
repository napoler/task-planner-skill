# 29-executor — task-v131/Phase 7 级联锚演进微修（2 文件）

- 状态: done（未 commit，按任务要求）
- worktree: /home/terry/task-planner-skill-worktrees/task-v131
- 范围: 仅 2 文件（selftest-reliability-institution.sh / selftest-self-resolution.sh），git status 确认无越界改动
- 根因: SKILL.md:266 括注已演进「（含 Rule 40/41/42/43/44/45/46/47/48/49/51）」→「（含 Rule 40-53 全集）」（CR P1-2，见 28-executor S1），两个 selftest 旧锚断言随之 FAIL（判例 SR-11 锚演进必同步，knowledge-brief §4）

## S1 selftest-reliability-institution.sh R-09 锚演进
- 位置: :13-14（头部注释，原锚行 1 行 → 2 行含演进注记）+ :76-79（断言块）
- 改前: `grep -c '含 Rule 40/41/42/43'` ≥1 且 `grep -c '1-40'` = 0
- 改后: `grep -c '含 Rule 40-53 全集'` ≥1 且 `grep -c '1-40'` = 0（负断言保留）
- 演进注记: `[2026-10-05 task-v131 CR P1-2 级联: SKILL.md:266 括注演进… 原锚「含 Rule 40/41/42/43」, 判例 SR-11 锚演进必同步]`（注释区+断言区双处）

## S2 selftest-self-resolution.sh SR-08 锚演进
- 位置: :12-13（头部注释）+ :69-74（断言块）
- 改前: `grep -c '含 Rule 40/41'` ≥1 且 `grep -c '^40\.'` = 6
- 改后: `grep -c '含 Rule 40-53'` ≥1 且 `grep -c '^40\.'` = 6（^40.=6 子条断言保留）
- 演进注记: 同款 `[2026-10-05 task-v131 CR P1-2 级联…原锚「含 Rule 40/41」, 判例 SR-11 锚演进必同步; ^40\.=6 子条断言保留]`（注释区+断言区双处）
- 说明: ok/bad 消息文本中「Rule 40/41 共存锚损伤」为断言语义描述（指 Rule 40/41 共存不变量），非锚 token，保留不动

## S3 验证（三脚本全 PASS，rc 均 0）
- selftest-reliability-institution.sh: `Total: 12 PASS=12 FAIL=0`，其中 `R-09 PASS SKILL.md「含 Rule 40-53 全集」锚 1 ≥1 且越界 1-40 =0`
- selftest-self-resolution.sh: `Total: 13 PASS=13 FAIL=0`，其中 `SR-08 PASS SKILL.md「含 Rule 40-53」锚 + critical-rules.md Rule 40 六子条 = 6（共存零损伤）`
- selftest-root-resolution.sh（不回归复验）: `Total: 17 PASS=17 FAIL=0`
- 负结果报告: 两脚本内 grep 旧锚 token `含 Rule 40/41` / `含 Rule 40/41/42/43` 作为 grep 模式已清零（仅剩演进注记原文引用与 SR-08 语义描述文字）；SKILL.md 侧 `含 Rule 40-53` 实测 =1、`1-40` =0、`^40.` =6，与断言口径一致；git status 仅 2 文件 M，无越界。

## 恢复点
- 无失败 checkpoint。如需回滚: worktree 内 `git restore skills/task-planner/scripts/selftest-reliability-institution.sh skills/task-planner/scripts/selftest-self-resolution.sh`。
