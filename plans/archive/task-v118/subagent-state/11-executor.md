# 11-executor checkpoint — task-v118 CR 修复（check-dispatch.sh）

日期: 2026-10-03 | 状态: done | 文件: skills/task-planner/scripts/check-dispatch.sh（worktree /home/terry/task-planner-skill-worktrees/task-v118）

## 修复项 1【BLOCKER】全角标点盲区 → 共用提取器
- 新增函数 `extract_subagent_state_refs()`（L290-296 附近，fine_grain_checks 定义前）:
  - grep 字符类两侧扩全角定界 `[^[:space:]"「」『』“”（）(),，。：:；;、！!?？]*subagent-state/…`
  - 残余 CJK 粘连按字节剥: `LC_ALL=C sed -E 's/^[^[:print:]]*//; s/[^[:print:]]*$//'`（:print:=0x20-0x7E, 覆盖路径字符）
  - 归一 1 行 1 路径, sort -u, head -3
- 守卫②（fine_grain_checks 任务书打包分支）与守卫④（任务书步骤计数分支）内联提取全部替换为 `tb="$(extract_subagent_state_refs "$pf")"`，消除 ②剥「」④不剥 的不一致
- 修改处注释含 CR BLOCKER 原因 + 2026-10-03 task-v118 CR + 原行为（Rule 45.4）

## 修复项 2【SUGGESTION】行首序号幽灵计数
- count_step_markers tb 模式（L285 附近）: `[0-9]+` → `[0-9]{1,2}`（行首日期 2025.10.03 不再命中）；自由 prompt 单参口径零变化。注释同步。

## 验证结果
1. 提取器单测 6 形态全 PASS: 全角括号+冒号 / 全角书名号 / ASCII引号 / CJK粘连 / 行尾句号 / 多引用
2. 三态 fixture（/tmp 最小计划目录 + TASK_PLANNER_DISPATCH_ENFORCE=enforce + TASK_PLANNER_PLAN_DIR）:
   - F1 全角「（任务书：…/tb.md）」+ 任务书 2 S-id → exit 2, stderr 含 `⚠ 任务书检出 2 个 S-unit ID` 与阻断行 `任务书打包(2 个 S-unit ID)`（复跑确认「任务书检出」字样存在）
   - F2 同形态 + 任务书 6 个行首 markdown 编号 → exit 2, `步骤枚举超限(6>4)`
   - F3 任务书文件不存在 → exit 0, SKIPPED fail-open 不变
3. 幽灵计数 fixture: 任务书 `1.`-`4.` + 行首 `2025.10.03 修订记录` → exit 0 不误拦；对照 7 个编号仍 → exit 2 `步骤枚举超限(7>4)`
4. 回归: selftest-dispatch.sh **31/31 PASS**（FAIL=0）；selftest-fine-grain-steps.sh **11/11 PASS**（FAIL=0）

## 禁改约束核对
- git diff 仅 4 个 hunk: ① tb 位限+注释 ② 新增函数 ③ 守卫②调用点 ④ 守卫④调用点。自由 prompt else 分支（`sids=…` 段）零 diff；档位管线/缺项扫描/守卫①③零改动；只动 check-dispatch.sh
- bash -n 语法 OK；worktree git status 仅 `M skills/task-planner/scripts/check-dispatch.sh`

## 未提交说明
按流程 executor 不落 commit，变更留在 worktree 工作区待主进程验收合并。
