# 提醒单元 checkpoint（pointer-lifecycle F1 机制化位）

status: done
时间: 2026-10-10

## 结论（供主进程验收）

两处 F1 机制化位均已落地于 worktree /mnt/data/dev/task-planner-skill-worktrees/v159-pointer-lifecycle，纯增量 13 行（12+1），零删除既有逻辑：

### 1. scripts/check-complete.sh（终验尾段，exit 0 前）
- 落位: `fi`（python_rc=0 大分支）内、warn count 段之后、`exit $python_rc` 之前（新行 ≈1278-1290）
- 逻辑: 读 `<PLAN_DIR_GUESS>/../.active_plan` 当前值（即 plans/.active_plan，与 set-active-plan.sh 的 PLAN_ROOT=${ROOT}/plans 布局一致，PLAN_DIR_GUESS=计划目录=plans/<task-id>），与本任务 id（basename PLAN_DIR_GUESS）相等 → 输出 `[plan] 移交提醒( pointer-lifecycle ): 全局指针仍指向本任务，完成后请移交（置空或指向在途任务；gc 亦会清理 stale）`（stderr，风格对齐同段 warn 行）
- warn 语义: 恒不改退出码（exit 码仍 = python_rc，零阻断）；指针缺失/不可读静默跳过（fail-open）
- Rule 45 注释齐备: 头注 6 行（2026-10-10 task-v159, D1 孤儿指针根因 Why + 读取路径 What + fail-open 语义）

### 2. SKILL.md:109（Phase 执行循环 6.4 drift-checker 行之后，`### 📄 产出落盘映射` 前）
- 新增一行移交纪律（原文）: `**指针移交（25 完成项）**：任务完成或移交时检查全局指针 plans/.active_plan 不再指向本计划（置空或指向在途任务；显式移交优先于 gc 兜底清理）；check-complete.sh 终验成功时若指针仍指向本任务会输出移交提醒 warn（恒 exit 0 不阻断）` + HTML 注释 Rule 45 标注（2026-10-10 task-v159, D1 根因, 不新增 Rule 编号）

## 验收证据
- `bash -n scripts/check-complete.sh` rc=0
- 夹具 /tmp/v159-s3-fixture（plans/task-v159-fixture/task_plan.md complete + .active_plan=task-v159-fixture）跑 check-complete:
  - 指针=本任务 id → 输出含提醒行原文, rc=0
  - 指针=other-task → 不输出, rc=0
  - 指针空串 → 不输出, rc=0（fail-open 静默）
- `grep -n '指针移交' SKILL.md` → 109 行命中原文
- 计数锚: 本单元不新增 Rule，未改任何计数锚（master 1-69 不变）

## 关键事实（负结果/边界）
- worktree HEAD（5280cb3, v154 合流后 1-69 基线）**缺少 task-v155 的 report-lint 段**，而 master 62b8b4b 已含 → `git diff master` 会显示约 59 行「删除」（实为基线代差，非本单元操作）；**本单元净改动以 `git diff HEAD` 为准 = 13 insertions(+), 0 deletions**
- 未提交: 工作树另有 init-session.sh / set-active-plan.sh 两处未提交改动（F4 等前序单元产物），本单元未触碰，git status 4 个 M 文件如实呈现
- 提醒行走 stderr（与同段所有 `[plan]`/warn 行一致）；warn count 先例同走 stderr，无口径冲突
