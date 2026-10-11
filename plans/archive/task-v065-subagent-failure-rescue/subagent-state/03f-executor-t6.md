# 检查点: 03f-executor-t6 (task-v065 Phase 4 T-6 收尾一致性微改批)

worktree: /home/terry/task-planner-skill-worktrees/task-v065-subagent-failure-rescue
commit: b15d42a (7 files changed, 10 insertions, 8 deletions)

## T6-1 双平台化 ✅
- SKILL.md:67 定制入口行 → `.claude/plan-templates/`（Claude Code）或 `.zcode/plan-templates/`（ZCode）目录
- template-guide.md:77 注释: 方式 A 代码块首行补「ZCode 用 .zcode/plan-templates/，Claude Code 用 .claude/plan-templates/，以下以 .claude 为例」+ 块尾「ZCode 平台对应：将上述路径中 .claude/ 替换为 .zcode/」
- template-guide.md:102 方式 C 注释: 补「ZCode 平台目录为 .zcode/plan-templates/，Claude Code 为 .claude/plan-templates/，以下以 .claude 为例」
- 豁免行: SKILL.md:18/:65/:508 与 template-guide.md:12 已是双平台/架构描述豁免，未动

## T6-2 todo-sync 枚举 ✅
- todo-sync.md:21 映射表 `**Status:** complete → completed` 行补注：「注：脚本 JSON 输出（sync-todos.sh --json / check-complete.sh）归一为 complete，completed 为原生 Todo 状态词汇」
- 选择依据: 该表列头「原生 Todo」描述的是 ZCode 原生 TodoWrite/Task 状态词汇，保留 completed；补注对齐 sync-todos.sh 归一输出 complete

## T6-3 锁名统一 ✅
- check-delegation.sh:199 lock_file → `$plan_dir/.ledger_lock`
- allow-direct.sh:120 lock_file → `$plan_dir/.ledger_lock`
- ledger-append.sh:106 保持 `.ledger_lock`（既有范式）
- 三处 flock 语义等价: 均 `flock -w 5 9` + 子进程持锁（check-delegation 持锁计算+追加，allow-direct 持锁追加，ledger-append 持锁计算 tick+写入）；`grep -rn "ledger-delegation.jsonl.lock" scripts/` 零命中；`.ledger_lock` 恰 3 处使用点

## T6-4 no_health_file 22.3.2 对齐 ✅
- subagent-fallback.sh:264 escalation: main_takeover_or_askuser → split_then_takeover_or_askuser
- hint: 「先运行 probe 再 bind」→「无健康探测记录 → Rule 22.3 ④ 主进程接管 / ⑤ AskUser（任务>300行/多文件时先回计划层拆细到单文件≤300行再逐片 ④ 接管——22.3.2；也可先 probe 探测后重试 next）」
- selftest-fallback.sh 新增断言 T02c escalation=split_then_takeover_or_askuser（原 T02a/T02b 保留）

## 验收证据
- bash -n 4 脚本: SYNTAX_OK
- selftest-fallback.sh: Total 30 PASS=30 FAIL=0（基线 29 不回退 + 新增 T02c）
- selftest-delegation.sh: Total 38 PASS=38 FAIL=0
- grep ledger-delegation.jsonl.lock → 零命中（exit=1）
- grep -n ".ledger_lock" scripts/*.sh → 恰 3 处
- grep plan-templates → 全部双平台或豁免标注

## 风险
- 无（纯微改，selftest 全绿，锁语义等价）

## 结论: DONE
