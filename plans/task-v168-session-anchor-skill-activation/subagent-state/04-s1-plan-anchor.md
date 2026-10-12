# 04-s1-plan-anchor 检查点（code-assistant 子代理）

## 里程碑日志
- 2026-10-11 09:10 [读材料] 已读 01-explore-drift-mechanisms.md §4/§5/§6（三重收窄与字段集反推）、set-active-plan.sh（--show 输出「解析:」行=活跃计划解析入口）、resolve-plan-dir.sh 解析链、worktree scripts/ 目录现状；确认 .gitignore 无 .anchor-card 条目
- 2026-10-11 09:40 [写脚本] 首版 plan-anchor.sh 写完；bash -n 在 L90 附近反复报「unexpected token (`)`」——多轮二分定位：根因 = 嵌套命令替换 `b="$(... '$0 ~ /re/')"; [ -n "$b" ]..."` 内单引号正则串 + 多字节 🔒 字面量组合使 bash 解析器在深层嵌套引号构造上误报/漂移；规避 = 该行改用 `b="$(... '$0 ~ /^\| 🔒/')"; [ ... ]`（提前闭合命令替换）并压缩注释至 ≤100 行
- 2026-10-11 11:20 [跑测] bash -n PASS；--test 全 5 断言 PASS exit 0（全节 fixture：5 字段头/多行 Goal 全文/R 条目全文/不变量 🔒 行在场+非 🔒 表行过滤；缺节 fixture：4 个（未找到）降级不报错）；缺失文件 exit 2；幂等双跑 diff 一致；stdout 与 .anchor-card 一致
- 2026-10-11 11:22 [真实计划] 对 /mnt/data/dev/task-planner-skill/plans/task-v168-session-anchor-skill-activation/task_plan.md 运行：5 字段齐全，R1-R5 全文含 <sub> 标注，Goal 多行完整（含 WHAT 注释行），缓存写入 plan-dir/.anchor-card（主仓 plan 目录，spec 定义的 plan-dir）；主仓 git status 无新增 tracked 变更（v168 plan 目录本就 untracked）

## 最终结论（8 字段块）
status: done
acceptance: 5/5 pass — [1:PASS 2:PASS 3:PASS 4:PASS 5:PASS]
files: /mnt/data/dev/task-planner-skill-worktrees/task-v168-session-anchor-skill-activation/skills/task-planner/scripts/plan-anchor.sh(+98/-0)
evidence: plan-anchor.sh:39(嵌套引号规避行) ; bash -n→exit 0 ; --test→"[plan-anchor] --test PASS (5/5)" exit 0 ; 缺失文件→exit 2 ; 真实计划→R1-R5 全文+Goal 多行入卡；worktree git status→仅 ?? 新脚本（另有 pre-existing M plans/.rule-reservations.jsonl，开工前首个 status 检查已存在，非本代理写入）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v168-session-anchor-skill-activation/subagent-state/04-s1-plan-anchor.md (status: done)
findings_written: 04-s1-plan-anchor#嵌套引号解析陷阱
blockers: none
confidence: HIGH

## 附注：嵌套引号解析陷阱（供 S2/S3 参考）
bash 5.2.21 中「嵌套命令替换 + 内层单引号 awk 正则含多字节 UTF-8 + 后接命令」形如
`b="$(cmd 'a b' '$0 ~ /^🔒/'); [ -n "$b" ]"` 的深层组合在 bash -n 上可出现位置漂移的误报
（报点不在出错行而在其后若干行）。规避模式（本脚本 L39 采用）：在嵌套命令替换内把正则串
单独成参 `'$0 ~ /^\| 🔒/'`、其后直接 `);` 闭合；避免同一命令行叠加第二层嵌套命令替换。
S2/S3 的 hook 改造脚本若出现同类「报点漂移」的语法错，优先按此模式重排引号而非逐字改动逻辑。
