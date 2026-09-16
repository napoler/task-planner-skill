# S5 executor 检查点 — check-skill-modify.sh 新建 + zcode-pretooluse.sh 接线
> executor(sonnet-1) | task-v079 Phase2/S5 | 2026-09-17 | 状态: complete
> worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v079-skill-modify-conservatism

## 产出
1. 新建 skills/task-planner/scripts/check-skill-modify.sh（92 行 ≤100，-rwxrwxr-x，bash -n 通过；头注释块注明 task-v079 Rule 36 出处，风格对齐 check-delegation.sh）
2. 接线 skills/task-planner/scripts/zcode-pretooluse.sh Write|Edit|ApplyPatch 分支（git diff --stat: 6 insertions, 1 deletion；bash -n 通过；镜像既有 rc=2 透传惯例）

## 设计修正记录（相对 07-s5-design.md 的偏差与原因，主进程须知）
- **计划定位 root 链修正**：设计书第 4 步要求"镜像 check-delegation mode_pretool"纯 cwd 定位；实跑发现 worktree 自带陈旧 plans/*.active_plan（side 指针仅存于实仓），cwd 落 worktree 时 resolve 命中跨会话陈旧计划 → 未授权误判（E4 首跑 rc=2 根因）。修正为 root 链：实仓 REPO_ROOT（BASH_SOURCE 部署位 realpath 归一推仓根，兼容 ~/.zcode/skills symlink 部署）→ git-common-dir 根（worktree 共享主仓 .git 的场景）→ PWD 兜底，按序取首个可解析计划。
- **会话归属校验**：sid≠default 时仅采纳 .session-owner 严格相等（sess 前缀 canon 对齐 D11）或 side 指针指向本计划的计划；跨会话陈旧计划一律跳过；owner 缺失 = 保守放弃授权（保持分档判定，不阻断也不放行），与 check-delegation M-2 owner 语义对齐。设计书"不检查 sid 是否 .session-owner"指主/子代理守卫一致性（本脚本对子代理 sid 同样执行分档，不放行），非"不做会话归属"——无归属计划 = 无授权源 = 跳分档。
- **行控制**：设计书接线 ≤6 行，实做 6 insertions/1 deletion（注释 2 行 + 调用 1 行 + rc 捕获 2 行 + 尾注 1 行，净增 5 行，在 ≤6 语义内）。

## 六条自验证据（原样输出）
### E1 warn 档（默认，未授权假目标 /tmp/x/skills/fake/SKILL.md，testsid）
```
$ echo '{}' | bash check-skill-modify.sh pretool /tmp/x/skills/fake/SKILL.md testsid
rc=0
stdout: {"additionalContext": "[skill-modify-warn] ⚠️ Rule 36: 技能文件写入未在当前计划执行范围授权: SKILL.md（36.2 归因/36.4 删除确认/计划范围表登记后放行；enforce 升级=TASK_PLANNER_SKILL_MODIFY_ENFORCE）"}
stderr: []
count-file: /tmp/task-planner-skillmod-testsid.count = [1]
```
### E2 enforce 档（未授权）
```
$ TASK_PLANNER_SKILL_MODIFY_ENFORCE=enforce bash check-skill-modify.sh pretool /tmp/x/skills/fake/SKILL.md testsid
rc=2
stdout: []
stderr: [[skill-modify] BLOCKED (task-v079 Rule 36): SKILL.md 未在活跃计划执行范围限制表登记（36.5 纯增量纪律/36.4 删除确认门；先归因 36.2 再走计划授权）]
```
### E3 off 档
```
$ TASK_PLANNER_SKILL_MODIFY_ENFORCE=off bash check-skill-modify.sh pretool /tmp/x/skills/fake/SKILL.md testsid
rc=0
stdout: []
stderr: []
```
### E4 已授权实测（真实计划 scope token skills/task-planner/scripts/check-skill-modify.sh + worktree 真实路径，enforce 档；sid=1aae39dcc14547f3af0a23a86cccb610 对应 v079 side 指针）
```
$ cd <worktree 根> && TASK_PLANNER_SKILL_MODIFY_ENFORCE=enforce bash check-skill-modify.sh pretool \
    /mnt/data/dev/task-planner-skill-worktrees/task-v079-skill-modify-conservatism/skills/task-planner/scripts/check-skill-modify.sh \
    1aae39dcc14547f3af0a23a86cccb610
rc=0  stdout: []  stderr: []   ← 授权优先于档位，enforce 亦放行
$ 同命令去 env（warn 档）→ rc=0, stdout: []   ← 已授权时 warn 档亦静默
```
交叉验证：部署位 symlink 场景（cwd=/home/terry，目标 ~/.zcode/skills/task-planner/scripts/check-skill-modify.sh）enforce → rc=0；worktree 目标同 token 的 check-complete.sh/config.json/SKILL.md → rc=0。负向对照（testsid 无归属 v079）→ 上述文件 enforce 均 rc=2（非技能文件除外，见 E5）。
### E5 非技能文件
```
$ bash check-skill-modify.sh pretool /tmp/foo.txt testsid
rc=0
stdout: []
stderr: []
```
### E6 接线 grep
```
$ grep -n check-skill-modify skills/task-planner/scripts/zcode-pretooluse.sh
57:    bash "$SKILL_ROOT/check-skill-modify.sh" pretool "$file" "$sid"
60:    # rc=0 时 check-skill-modify 自身可能已输出 warn JSON(注入);不重复
```
（≥1 命中；接线位于 Write|Edit|ApplyPatch 分支内、check-delegation rc=2 处理之后、`;;` 之前；Agent 分支与 Rule 23 段零改动）

## 附：其他实跑
- 参数缺失 fail-open：`bash check-skill-modify.sh` → stderr "usage: ..." rc=0；`bash check-skill-modify.sh pretool` → stderr "缺 target 参数, fail-open" rc=0
- 计数增量：同一 sid 连跑 2 次 warn → count file = 2
- wc -l：check-skill-modify.sh = 92 行；zcode-pretooluse.sh = 110 行（改前 105，净 +5）
- jq 缺失模拟（最小 PATH 无 jq）：warn 档 rc=0（TIER 降级 warn，JSON 走 fallback '"warn"'，fail-open 不崩）
- bash -n 双脚本通过；git status worktree 仅 2 个文件变更（本 S5 范围）

## 负结果报告
- 未发现问题：E1-E6 全通过；非技能文件零干扰（E5 + 负向对照）；主/子代理一致性（子代理 sid 无 owner 时按分档处置，不被 check-delegation 空档放行）；接线在位且仅在目标分支内
- 已排除风险：worktree 陈旧 plans/*.active_plan 误命中（root 链 + 归属校验）；symlink 部署位计划定位失败（realpath 归一 + git-common-dir 兜底）

## 遗留提示（主进程决策，非本 S-unit 范围）
- 生产环境 v079 计划的 .session-owner 文件当前缺失（plans/task-v079-skill-modify-conservatism/.session-owner 不存在）；UserPromptSubmit hook 会在下一轮主进程交互时写入。在此之前，主进程侧（sid 匹配 owner 链失败）的授权判定走"保守放弃"路径，v079 scope 内写入在 enforce 档会被拦——warn 档默认下仅 warn JSON，不影响当前观察期
- 本 S5 自检时 E4 能命中 v079 计划，是因为 side 指针 plans/.active_plan_side/1aae39dcc14547f3af0a23a86cccb610.active_plan 存在且指向 v079
