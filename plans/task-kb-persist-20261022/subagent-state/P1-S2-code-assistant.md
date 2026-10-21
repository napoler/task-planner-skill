# 检查点 P1-S2 Code Assistant — kb-rebuild-index.sh

状态: PASS（全部自测通过，交付态已留）

## 交付物
- /home/terry/task-planner-skill-worktrees/kb-persist-20261022/scripts/kb-rebuild-index.sh (60 行, chmod +x, 可执行位 -rwxrwxr-x)
- /home/terry/task-planner-skill-worktrees/kb-persist-20261022/knowledge/INDEX.md (最终空表态: 仅表头 `| id | title | tags | sources | file |`, 条目计数 0)
- /home/terry/task-planner-skill-worktrees/kb-persist-20261022/knowledge/entries/ (目录保留, 含并行面既有 _draft-task-v122-rule47-media-dispatch.md, 未触碰其内容)

## 自测命令 + 输出
T1 空库: mv entries/ /tmp 后 rebuild → exit 0, grep -c '^| ' = 1 (仅表头), 头部含计数 0, mkdir -p 自动重建 entries/
T2 fixtures: zz-fixture-a.md (含 sources 两行 list) + zz-fixture-b.md (缺 sources)
  → WARN: zz-fixture-b.md 缺 sources, 仍收录 (stderr)
  → grep -c '^| ' = 3 ✓; fixture-a 行 sources 列 = `/tmp/a.md<br>https://example.com/a` ✓
  → --dry-run: stdout 输出同 3 行表, 前=后 md5 一致 (d6dded... 前后同) ✓
T3 draft: 复制 fixture 为 _draft-x.md → rebuild → grep -c '_draft-x' = 0 ✓ (被跳过)
清理: rm 三个自建 fixture, diff 确认 entries/ 恢复到测试前状态 (ENTRIES-RESTORED OK), 最终 rebuild 留空表 exit 0

## 缺陷与修复记录 (诚实披露)
1. awk 初版 line 33 正则 `/^updated: {` 缺闭合 `}` → gawk 编译失败 "unterminated regexp" (首跑 awk 报错被 `2>/dev/null` 外的 stderr 吞掉, 但 rc≠0 路径仍容错产出空表, 表面 exit 0 —— 属于静默降级陷阱, 已发现并修复)
2. awk 规则序 bug: 顶层 key 复位规则 `/^[^ \t-]/` 在 sources: 行自身触发把 insrc 置 0, 单行内 list 值被吞 → 排除条件 `!/^sources:/`
3. 初版对 updated 键无处理但保留了该行 —— 终版删除 (updated 不参与表格列, 避免死代码)

## git 面
worktree `git status --short` = 仅 `?? knowledge/` `?? scripts/` (untracked 新增), 无已跟踪文件被改; 未写主仓; 未 commit (交由上游决定)

## 风险/遗留
- 脚本假设 frontmatter 首个 `---` 在 line 1; entries/ 下无子目录递归扫描 (规格仅 *.md 单层, 符合)
- 并行面 kb-sync-from-plan.sh / kb-search.sh 存在 (本任务只读未改); 单写者约定=本脚本是 INDEX.md 唯一写者
