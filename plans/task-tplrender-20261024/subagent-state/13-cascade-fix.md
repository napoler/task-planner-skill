# S13 检查点：2 处级联 FAIL 断言适配（PT-26 / SL-07）

- 状态：**DONE**，全量 selftest 93/93 PASS
- 时间：2026-10-24
- 单元：S13（仅改 2 个 selftest 脚本，禁改 init-session.sh）
- 根因（S12 定位）：b983b3b 引入的渲染层是**新契约行为**，两处旧断言语义过期；基线复现已确认非既有失败。

## 修改 1：`skills/task-planner/scripts/selftest-plan-tier.sh` PT-26（+12/-3）

- 原断言：`head -1 task_plan.md | grep -q 'Task Plan: \[Brief Description\]'`（断言占位符原样保留）
- 现断言：`_pt26_title` 精确等于 `# Task Plan: pp`（传参任务名）∧ `! grep -qF '[Brief Description]'`
- 原因：模板 `[Brief Description]` 已被 render_template 渲染为任务名，旧断言必 FAIL
- 意图保持且更严：旧断言只证占位符在，新断言证填充值正确 + 无残留
- Rule 45 三要素注释已写入（原因/时间 2026-10-24/原行为）

## 修改 2：`skills/task-planner/scripts/selftest-session-log.sh` SL-07（+10/-3）

- 原断言：`grep -c '6/6' "$INIT"` = 1（全文计数）
- 现断言：`grep -cF 'echo "[init] 6/6 planning files verified"' "$INIT"` = 1（锚定 echo 语句字面）
- 原因：渲染接线块注释（init-session.sh L986）含「6/6 verified」字样 → 全文计数 1→2
- 意图保持：最终 verify 输出存在；仍 -eq 1（防重复回显）；免疫注释/文档撞词
- 实测 init-session.sh 内 `6/6` 共 2 处：L986 注释 + L1011 echo（锚定后仅后者命中）

## 测试结果

| 命令 | 结果 |
|---|---|
| `bash -n` 两文件 | OK |
| `bash selftest-plan-tier.sh` | **PT-26 PASS**，Total: 32 PASS=32 FAIL=0 |
| `bash selftest-session-log.sh` | **SL-07 PASS**，Total: 12 PASS=12 FAIL=0 |
| `bash run-selftests.sh`（全量） | **Total: 93 PASS=93 FAIL=0 (run=93 reused=0)，rc=0** |

## git diff 范围

`git status --short` 仅 2 行：
`M skills/task-planner/scripts/selftest-plan-tier.sh`（12/3）、`M skills/task-planner/scripts/selftest-session-log.sh`（10/3）。
init-session.sh 未改动（已在 b983b3b 提交）。

## 遗留风险

1. PT-26 用精确标题 `# Task Plan: pp` 硬编码任务名，若未来模板标题前缀文案变更（如 `# Task Plan:` → 其它）需同步；已用变量 `_pt26_title` 便于排查。
2. SL-07 锚定 echo 字面，若未来 verify 回显文案改动需同步（这是有意的：文案变更应触发断言复核）。
