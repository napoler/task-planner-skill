# 19-executor checkpoint — task-v131 Phase 5 S-unit 3（L-5 opencode 物理路径修正）

status: SUCCESS
时间: 2026-10-05
worktree: /home/terry/task-planner-skill-worktrees/task-v131

## 执行记录
1. Read knowledge-brief §2 + 定位文件：
   - detect-tools.sh 实际位于 `skills/task-planner/lib/detect-tools.sh`（任务包写 scripts/，以实存 lib/ 为准，全仓 find 唯一）
   - README 实际位于 `skills/task-planner/README.md`（根目录 README.md 不存在）
2. 第一手证据（readlink -f ~/.opencode）：`/home/terry/.opencode -> /home/terry/.config/opencode`（symlink 确认，物理路径 = ~/.config/opencode）
3. 修改 2 文件：
   - lib/detect-tools.sh:20 opencode 探针行 `~/.opencode` → `~/.config/opencode`（stub_dir + probe_path 两处），附 Rule 45 注释（原因/时间/原行为：symlink 缺失时探测误判未部署）
   - README.md:44-55 多工具架构图 `~/.opencode` 列 → `~/.config/opencode/skills/`，图后新增 L-5 修正注记（物理路径 + symlink 兼容入口 + 原行为）
4. 验证：
   - `bash -n lib/detect-tools.sh` → SYNTAX_OK
   - `grep -c "\.config/opencode"` → detect-tools.sh:2, README.md:2，合计 4 ≥ 2 ✅
   - `git diff --stat` 显示 4 文件：其中 INSTALL.md 与 install-stub.sh 的前置 diff 属本 worktree 更早 S-unit（M-1 口径修正，带 task-v131 标注），本 S-unit 未触碰；我的 2 文件 diff 已逐项 Read 复核

## 未 commit（按任务包要求）
恢复点：如需提交，仅 `git add skills/task-planner/README.md skills/task-planner/lib/detect-tools.sh`（勿 git add -A，M-1 的 2 文件由归并方统一处理）
