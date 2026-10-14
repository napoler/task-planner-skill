# task-v069 Phase 2 — executor subagent checkpoint

- status: SUCCESS
- acceptance: 全部 5 条通过
- evidence: 见下方实测输出
- checkpoint: 本文件
- summary: 在 worktree 内完成 S4(新建 scripts/check-context-hygiene.sh, 215 行)、S5(新建 scripts/plan-hygiene.sh, 190 行)、S6(在 worktree config.json 追加 3 键), 共改 3 文件。两处 perf 修复(参数循环无 shift 死循环、仓根 .git 查找限 4 级避免 fuse/NFS 卡 3m45s)已应用。两脚本 bash -n 通过、chmod +x 已设、json.tool 校验合法、grep 3 键计数=3。plan-hygiene.sh --dry-run 实测 25 行输出/21 行 ARCHIVE(主仓 35 completed 目录中 mtime≥7d 者入清单), 符合预期。check-context-hygiene.sh 对真实 task-v069 计划返回 exit 1(含非严重建议: findings.md ## Research Findings 5 条+## Resources 6 条同主题), 对缺失 plan-dir fail-open exit 0。改动面 3 文件, 未 git commit, 留 modified 状态给主编排。
- retry_count: 0
- rescued: false
- files_modified:
  - /home/terry/task-planner-skill-worktrees/task-v069-context-hygiene/skills/task-planner/scripts/check-context-hygiene.sh (新建, 215 行, +x)
  - /home/terry/task-planner-skill-worktrees/task-v069-context-hygiene/skills/task-planner/scripts/plan-hygiene.sh (新建, 190 行, +x)
  - /home/terry/task-planner-skill-worktrees/task-v069-context-hygiene/skills/task-planner/config.json (worktree 副本, +26 行 3 键)

## 实测输出

### check-context-hygiene.sh — 主仓 task-v069 计划
```
[context-hygiene] 建议: findings.md ## Research Findings (5) — 同主题 ≥5 条 → 折叠为 1 条带证据指针摘要
[context-hygiene] 建议: findings.md ## Resources (6) — 同主题 ≥5 条 → 折叠为 1 条带证据指针摘要
[context-hygiene] 汇总: 1 类非严重退场建议 → exit 1
EXIT=1
```

### check-context-hygiene.sh — 缺失 plan-dir (fail-open)
```
[context-hygiene] fail-open: plan-dir 不存在: /tmp/nonexistent-plan-dir
EXIT=0
```

### plan-hygiene.sh — 主仓 plans --dry-run (25 行 / 21 ARCHIVE)
关键行:
```
[plan-hygiene] === plan-hygiene(dry-run, age=7d) ===
[plan-hygiene] ARCHIVE task-3file-enforce (age 9d)
... (21 行 ARCHIVE 略)
[plan-hygiene] wt/* 遗留分支: wt/task-v069-context-hygiene(仅提示,不自动删除;确认无用后 git branch -d)
[plan-hygiene] 汇总: 归档清单 21 项(dry-run);FAIL 0 行
[plan-hygiene] 归档后请重跑 sync-todos.sh --index 修正 INDEX 统计（Rule 29.4）
EXIT=0
```

### 校验
- bash -n 两脚本通过; chmod -rwxrwxr-x 已设
- python3 -m json.tool config.json → JSON OK
- grep -c '"context_hygiene_enforce"\|"plan_archive_age_days"\|"plan_hygiene_enforce"' → 3
- git diff --stat: 1 file changed (config.json +26); 2 untracked (两个新脚本)
- git status: M skills/task-planner/config.json; ?? 两个脚本

## 排错日志(不影响交付, 仅记录防回归)
1. 初版 plan-hygiene.sh 参数解析循环漏写 shift, while 死循环 → 修复加 shift
2. 仓根 .git 查找 while 循环无深度限制, 主仓 plans/ 在 /mnt/data/dev/... (NFS 型 fuse 慢盘), 逐层 test -e .git 走到 / 卡 3m45s → 限 4 级向上
3. git branch --list 'wt/*' 输出前缀 `+ `(当前 checkout 分支 marker), sed 's/^[* ]*//' 没剥 `+ ` → 双 sed 链
4. 第一次 plan-hygiene 实测挂 3m45s 未出结果 → 已 kill 挂死进程

## 未做事项
- 未 git commit(主编排统一验收后提交)
- 未改主仓 /mnt/data/dev/task-planner-skill/skills/task-planner/config.json (主仓 3 键已预先加好)
- 未跑 plan-hygiene.sh --execute (验收规范只要求 --dry-run, 归档动作留主编排确认)
