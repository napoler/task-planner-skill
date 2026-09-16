# p3-s5b checkpoint — T13 非密闭修复（唯一 sid）

## 状态
- 完成时间: 2026-09-17
- status: done
- 目标文件: /mnt/data/dev/task-planner-skill-worktrees/task-v078-guard-fp-fixes/skills/task-planner/scripts/selftest-execution-stability.sh

## 改动摘要（diff 13+/7-，相对 39ea338）
1. L172: 新增套件级变量 `ST13_SID="sfx${$}${RANDOM}"`（st13_exec 定义之前，T13a/T13b 共用同一 sid）
2. L175: st13_exec 的 stdin JSON session_id 由固定 `sess-sfx12345` 改为 `sess-${ST13_SID}`
3. L185/L198: st13_pos / st13_neg 末尾清理行 state 路径改为 `/tmp/task-planner-hook-${ST13_SID}.state`
4. L207: T13 段后 suite 级 rm 行同步改为含 `${ST13_SID}`
5. L151-154: T13 fixture 说明更新为「唯一 sid=ST13_SID（L172 每次运行生成）」
6. L160-163: 头注释补维护注记：sid 每次运行唯一，固定 sid 时 state 持久化会落入 plan-sync 冷却窗口（cd_left≠0）→ T13b 非密闭 FAIL（主进程复跑实证）

## 自验证据
- bash -n 通过
- 连续两遍运行 `bash skills/task-planner/scripts/selftest-execution-stability.sh 2>&1 | tail -1`：
  - 第一遍: `Total: 19  PASS=19  FAIL=0`
  - 第二遍: `Total: 19  PASS=19  FAIL=0`（密闭性证明：重跑不再 FAIL）
- T13a/T13b 两遍均 `[PASS]`
- git diff --stat: 仅该文件，13+/7-（在 39ea338 既有 T13 用例提交 +60/-1 之上追加，未提交）

## 根因回顾
T13a/T13b 共用固定 sid sess-sfx12345，hook state 文件 /tmp/task-planner-hook-sfx12345.state 跨 suite 运行持久：T13b 首跑写入 cd_left=10 后，重跑 T13b 落在 plan-sync 冷却窗口内不再提醒 → 首跑 PASS、重跑必 FAIL。

## 后续
- 变更未提交，由主进程（Rule 27 worktree 提交白名单）决定提交节奏
- 无 blockers
