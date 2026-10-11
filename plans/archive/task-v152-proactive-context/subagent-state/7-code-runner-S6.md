# S6 检查点 — code-runner-agent（task-v152 proactive-context）
> 生成：2026-10-10 01:40 | 单元：S6（独立验证，四件顺序执行） | 模式：worktree 只读+跑批
> worktree：/mnt/data/dev/task-planner-skill-worktrees/v152-proactive-context（未改任何源文件内容）

## 一、全量 selftest 回归（worktree）
- 命令：cd <wt>/skills/task-planner; for s in scripts/selftest-*.sh; do out=$(timeout 180 bash "$s" 2>&1); rc=$?; 记录 "scripts/X.sh rc=N | <Total 行>" ; done
- 日志：plans/task-v152-proactive-context/regression-worktree.log（64 行 + 汇总块）
- 结果：scripts=64；rc_nonzero=0；FAIL_nonzero=0（总耗时 155s）
- 对比基线（baseline-selftest.log，63 脚本 pass=63 fail=0）：
  * 新增=+1 → selftest-context-pressure.sh（Total: 9 PASS=9 FAIL=0）；缺失=0
  * 重叠 63 脚本逐 PASS 计数 diff：无删改（仅出现新增行）⇒ **零新增 FAIL**
- registry 动态断言：selftest-registry.sh "registry rows=64, actual selftest=64" 一致
- 备注：selftest-final-gate-hash.sh / selftest-user-instruction-priority.sh 无 "Total:" 行，
  本日志以各自结果行代汇总（rc 均=0；基线对应行留空为采集格式差异，非行为差异）

## 二、hook 实弹冒烟（worktree scripts/zcode-posttooluse.sh）
- fixture 构造法：复用 selftest-drift-enforcement.sh DCE-16/DCE-22 范式 —— mktemp 下
  plans/.drift-rhythm/<sid>.state 置 "count 10 / last_inject 0"（本轮 due=1）+ .active_plan_side
  指针 + 新鲜三件套（避优先级 1-3）+ 主计数 /tmp/task-planner-hook-<sid>.state 清零（避优先级 4）
- run1（默认 env）原始 stdout（恰好 1 行）：
{"additionalContext": "[drift-rhythm] 距上次偏移检查已 ≥10 次工具调用：活跃执行期按 Rule 15 派发 drift-checker（Rule 61 载体）并按 Rule 64.1 留痕三件套\n[context-pressure] 主动评估（Rule 67.2）：四信号自评 → HEALTHY 继续 / PRESSURE 即压缩(67.3) / CONFUSED 写会话交接文档(67.4)"}
- run1 断言：lines=1 ∧ json_valid=1 ∧ 含 [drift-rhythm] ∧ 含 [context-pressure] → PASS
- run2（TASK_PLANNER_CONTEXT_PRESSURE=off；复跑前重置 fixture 至同初态，模拟下一次节奏触发轮）原始 stdout：
{"additionalContext": "[drift-rhythm] 距上次偏移检查已 ≥10 次工具调用：活跃执行期按 Rule 15 派发 drift-checker（Rule 61 载体）并按 Rule 64.1 留痕三件套"}
- run2 断言：lines=1 ∧ json_valid=1 ∧ 含 [drift-rhythm] ∧ 不含 [context-pressure] → PASS
- 总体：SMOKE RESULT: PASS（脚本 exit 0）
- 辅助产物：7-code-runner-S6-smoke.sh（可复跑）、7-code-runner-S6-run1.out、7-code-runner-S6-run2.out

## 三、config properties 复核
- 命令：cd <wt>/skills/task-planner && jq '.properties|length' config.json
- 输出：42（rc=0）⇒ 零新键
## 四、selftest-context-pressure.sh 复跑
- 命令：bash scripts/selftest-context-pressure.sh
- 输出：CP-01..CP-09 全 PASS，Total: 9 PASS=9 FAIL=0，exit 0

## 回归计数（脚本级）
- scripts=64 / pass=64 / fail=0（基线 63/63/0 ⇒ +1 新增脚本，零新增 FAIL）

## open risks / notes
1. config.json mtime 于 00:51:49 被回归批次碰过：selftest-final-gate-hash.sh:239-254 设计行为
   （jq 改写真实 config → 从 config.orig 恢复）；git diff 为空 = 内容与 HEAD 逐字节一致，非内容污染。
2. worktree git status 的 17 项变更为本任务既往 S 单元产出（mtime 21:15~22:47），非本次运行产生；
   本次运行新增产物仅存于计划目录（regression-worktree.log 与 subagent-state/S6 系列）。
3. run2 为「重置 fixture 后复跑」口径（due 已由 run1 消费并清零，需重新置 due 才可观察同轮投递）。
