# P1-S1 code-assistant 检查点（kb-search.sh 检索脚本）
状态：DONE（2026-10-22）

## 交付物
- CREATED /home/terry/task-planner-skill-worktrees/kb-persist-20261022/scripts/kb-search.sh（86 行，≤85 目标超 1 行，86 含注释纪律要求的双层注释，已通过 chmod +x，bash -n 语法通过）

## 关键实现
- 仓库根探测：git -C 上级目录 rev-parse --show-toplevel，失败回落 pwd（任意 CWD/CI 可运行）
- 空库短路：knowledge/ 不存在或无 .md → 「知识库为空（knowledge/ 无条目）」exit 0
- rg 优先、缺失回落 grep -inr（单文件输出格式同为「行号:内容」）
- 实测坑（GNU awk 5.2.1）：ERE `[[:blank:]]` 在 awk 正则中只匹配单个空白，列表缩进 2 空格时 `^[[:blank:]]-` 不命中 → tags_of/summary_of 列表项匹配统一改 `^ *- `（已验证修复），坑位注释已留在脚本内
- 输出：== 相对路径 + frontmatter 摘要（title/tags/sources 各一行，sources 列表逐行）+ 命中行
- --tag 过滤：仅首个 frontmatter 块内 tags 段落（单行 [a,b] 或多行 - 形式），不命中跳过该文件
- limit 默认 20，非数字回落 20；输出文件数达 limit 截断

## 自测记录（worktree 根执行）
1. `bash scripts/kb-search.sh test`（空库时）→ 「知识库为空（knowledge/ 无条目）」exit 0 PASS
2. fixture `knowledge/entries/_smoke-test.md`（frontmatter id/title/tags:[smoke,demo]/sources 两行列表 + 正文含「锚点」）：
   - `bash scripts/kb-search.sh 锚点` → 命中 _smoke-test.md 与既有 _draft-task-v122.md（含「锚点」），摘要+命中行完整输出 exit 0 PASS
   - `bash scripts/kb-search.sh smoke --tag smoke` → 仅命中 _smoke-test.md（_draft 无该 tag 被过滤）exit 0 PASS
   - `bash scripts/kb-search.sh 锚点 --limit 1` → 仅输出 1 个文件（LC_ALL=C 排序下 _draft 在前），截断生效 PASS
   - `bash scripts/kb-search.sh 不存在的词xyz` → 「无命中: 不存在的词xyz」exit 0 PASS
   - fixture 已 `rm`（自建自删）
3. `bash scripts/kb-search.sh`（无参数）→ 打印用法 exit 2 PASS

## 约束遵守
- 仅创建 1 个脚本文件；fixture 自建自删；`git status --short` 确认 worktree 内无其他被修改文件（knowledge/、scripts/ 为 untracked 新增，含本任务前已存在的 _draft-task-v122.md 条目）
- 未触碰主仓 /mnt/data/dev/task-planner-skill（本检查点为唯一例外写入）

## 风险/备注
- 脚本 86 行，略超「≤85 行」硬指标 1 行，因注释纪律（Rule 45 双层注释+坑位注释）未删注释；如需压回 85 行可删「实测坑」说明 1 行（不建议）
- rg --no-heading 与 grep -inr 输出格式一致已验证；但 rg 命中行无前导空格、grep -inr 亦无（单文件），格式对齐无差异
- 多行列表 tags（`tags:\n  - a`）经 tags_of 支持（子串匹配 - 项），fixture 仅测了单行形式，多行 tags 形式为 MEDIUM 置信
