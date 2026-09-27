# S13 C-1a① pretooluse stdin .cwd 修复 — 干净上下文验证检查点（终版）

- 验证者: 全新子代理（不信任遗留 diff，按提案实测）
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v091（branch wt/task-v091-efficiency-optimization）
- 目标文件: skills/task-planner/scripts/zcode-pretooluse.sh

## Step 1 — Read 提案 C-1a① ✅ completed
- 位置: efficiency-proposal.md L126/L135/L137
- 原文: 「a① `zcode-pretooluse.sh:94` `CWD="${PWD}"`→stdin JSON `.cwd`（正确性修复：本节点 xtrace 实证 cwd=/tmp 仍扫本仓）」；护栏「同输入快照对拍 stdout/rc 逐字节」「bash -n 全部改动脚本」

## Step 2 — 遗留 diff 审查 ✅ completed
- 会话开始时 worktree 有未提交 hunk（git diff 确认，仅 1 文件）；与本任务指定 commit 文案的内容一致
- 【重大事件】验证进行中该 diff 被外部提交：HEAD=6e79257「perf(task-planner): task-v091/S13 C-1a① — PreToolUse cwd 来源修复…」
  - 范围核验: `git show --stat 6e79257` = 仅 zcode-pretooluse.sh，+4/-1（满足"仅此文件"）
  - blob 130b18d..c171af9 与 Step 2 审查的遗留 diff 逐字节相同 → 审查结论覆盖已提交内容
  - 基线改用 6e79257^（2d5f791，确认 L94=`CWD="${PWD}"` 改前版）

## Step 3 — 夹具验证 a/b/c ✅ completed（5/5 PASS）
- 驱动: /tmp 夹具（已清理），old=镜像 scripts 目录+6e79257^ 版脚本，new=worktree HEAD 实文件
- 夹具门控安全设计: stdin 带非 default session_id（enforce 档下走观察模式/子代理放行 rc=0）；observe 注入用预置 /tmp flag 抑制；decoy 作用域行用反斜杠路径 `src\decoy_target.txt`（脚本 /\\.[a-zA-Z]/ 为字面反斜杠语义，普通斜杠行不命中）
- VERDICTS 原文:
  - a  (假cwd不误扫):     PASS  old_conflict=1 new_bytes=0 rc=0/0
  - b  (真实cwd行为一致): PASS  stdout_identical=yes rc=0 plan_trace=plans/task-v090-workflow-auto-activation
  - ci (无.cwd兜底$PWD):  PASS  stdout_identical=yes conflict_in_new=1
  - cii(jq不可用兜底等价): PASS stdout_identical=yes rc=0 unit=unit-fallback: CWD=/tmp/t091-c1a1/decoyA
  - ciii(空stdin等价):    PASS  stdout_identical=yes rc=0
- a-old stdout 原文: {"additionalContext": "[conflict] 文件 /tmp/t091-c1a1/else/decoy_target.txt 可能与其他 plan(task-aa-other, session=sess-aa-other)冲突,请确认 scope"}；a-new 0 字节
- trace 原文: a-old `+ CWD=/tmp/t091-c1a1/decoyA` + `+ plan=.../task-aa-main/task_plan.md`（误扫实锤）；a-new `+ CWD=/tmp` ×2 + `+ '[' -d /tmp/plans ']'`（不再扫宿主 PWD 仓库）；b-new `+ CWD=<worktree>` ×2 + `+ plan=.../task-v090-workflow-auto-activation/task_plan.md`（探测仍工作）；ci-new `+ CWD=` → `+ CWD=/tmp/t091-c1a1/decoyA`（兜底链）
- stderr 五案例 old/new 全 IDENTICAL；bash -n old/new 全过

## Step 4 — commit ✅（外部已完成，无需重复提交）
- 6e79257 范围=仅此文件、内容=审查通过的 diff；worktree `git status` clean；`git show HEAD:... | diff - <worktree file>` = IDENTICAL
- 裁决: 修复已提交且验证全过，不再制造重复 commit

## 风险/发现（移交协调者）
1. 6e79257 提交信息尾部模板变量误展开:「兜底 /mnt/data/dev/task-planner-skill-worktrees/task-v091」（应为「兜底 $PWD」语义）；内容无恙，是否 amend 由协调者裁决（改历史需谨慎）
2. 【越界发现，未修】Rule23 作用域提取正则 `\\.[a-zA-Z]` 为字面反斜杠语义（awk 单引号内 \\ 不折叠），真实计划表（斜杠路径）永不命中 → other_scope 恒空 → [conflict] 检测对真实数据实际失效。改前改后皆然，与本修复无关；提案 a②（Rule23 重设计+新 selftest 三夹具）正好覆盖，建议移交 a② 时带上本实证
3. 本会话内观察到的外部并行提交（S11/S12/S13 相继落账）与任务书「中断遗留 diff」描述一致——上一会话可能仍在活动，协调者注意去重
