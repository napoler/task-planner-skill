# S5 设计任务书 — check-skill-modify.sh 新建 + zcode-pretooluse.sh 接线（Rule 36 36.7①）
> 主进程裁定。执行体=executor(sonnet-1)。目标行数：新脚本 ≤100 行；接线 ≤6 行改动。

## A. 新建 scripts/check-skill-modify.sh（worktree 内）

调用约定（镜像 check-delegation.sh pretool 模式）：
`check-skill-modify.sh pretool <target_file> <sid>`
退出码：0=放行（含 warn：放行但 stdout 输出 additionalContext JSON）；2=阻断（enforce 档命中未授权，stderr 给提示，适配器透传 exit 2）；其他内部错误=**fail-open exit 0** + stderr 一行警告（禁静默吞错）。

逻辑链（按序）：
1. `pretool` 模式参数校验；arg 缺失 → stderr 提示 + exit 0（fail-open）
2. realpath -m 规范化 target（兼容 worktree/部署位/相对路径；realpath 失败用原路径继续，不中断）
3. **技能文件模式命中**（任一即命中）：
   a. target 路径含 `/skills/` 路径段（覆盖 .zcode/.claude/.opencode 部署位、.agents/skills、worktree 副本），且
   b. basename=SKILL.md，或相对其技能根（`/skills/<name>/` 之后部分）前缀 ∈ {references/, scripts/, templates/, agents/, assets/, companion/}，或 =config.json / knowledge-brief.md（技能根直属）
   未命中 → exit 0（非技能文件，本守卫不管）
4. **定位活跃计划**：镜像 check-delegation.sh mode_pretool 的计划定位方式（先 Read 该脚本 L227-309 抄其管线：sid → .session-owner/.active_plan_side → plan dir）；无可解析计划 → 视为未授权，跳到第 6 步分档
5. **授权判定**：读该计划 task_plan.md 的「执行范围限制」段（`## ⚠️ 执行范围限制` 至下一个 `## ` 之间的行），提取其中反引号/表格里的路径 token（grep -oE '`[^`]+`' 拆分 + 裸路径词）；对每个 token：若 target realpath **包含**该 token 作为子串（token 如 `skills/task-planner/config.json` 或 `check-skill-modify.sh`）→ **已授权 exit 0**（放行，无输出）。全部 token 不匹配 → 未授权
6. **分档处置**（tier 解析镜像 house 范式）：env TASK_PLANNER_SKILL_MODIFY_ENFORCE（合法值优先）> `jq -r '.properties.skill_modify_enforce.default // "warn"'`（jq 缺失/config 缺失 → warn）
   - warn：stdout 输出单行 JSON `{"additionalContext":"[skill-modify-warn] ⚠️ Rule 36: 技能文件写入未在当前计划执行范围授权: <file>（36.2 归因/36.4 删除确认/计划范围表登记后放行；enforce 升级=TASK_PLANNER_SKILL_MODIFY_ENFORCE）"}`；同时 `/tmp/task-planner-skillmod-<sid>.count` 计数 +1；exit 0
   - enforce：stderr `[skill-modify] BLOCKED (task-v079 Rule 36): <file> 未在活跃计划执行范围限制表登记（36.5 纯增量纪律/36.4 删除确认门；先归因 36.2 再走计划授权）` + exit 2
   - off：exit 0 无输出
7. 关键约束：**不检查 sid 是否 .session-owner**（对主进程与子代理一致生效——这正是补 check-delegation 子代理空档的设计点，注释注明）；不做写操作；不调用 network
8. 头部注释块：职责/调用方/退出码/task-v079 Rule 36 出处/三档语义（对齐 check-delegation.sh 头注释风格）

## B. zcode-pretooluse.sh 接线（worktree 内，≤6 行改动）

在 `Write|Edit|ApplyPatch)` 分支内、现有 `check-delegation.sh pretool` 调用**之后**追加：
```bash
# [2026-09-17 task-v079] Rule 36 技能修改保守化门(36.7①):技能文件写入授权检查(主进程+子代理一致生效)
bash "$SKILL_ROOT/check-skill-modify.sh" pretool "$file" "$sid"
[ $? -eq 2 ] && { 输出阻断（镜像上方 check-delegation rc=2 的既有处理方式）; exit 2; }
```
（具体透传写法以 Read 该脚本后镜像其既有 rc 处理惯例为准，保持风格一致；不动其他分支/逻辑）

## C. 自验证据（写入检查点，主进程复跑抽查）

在 /tmp 造未授权假目标（如 /tmp/fake-skill/SKILL.md 或含 /skills/ 段的路径）三档实跑各一：
1. warn 档（默认）：`echo '{}' | bash check-skill-modify.sh pretool /tmp/x/skills/fake/SKILL.md testsid` → rc=0 + stdout 含 [skill-modify-warn]
2. enforce 档：env TASK_PLANNER_SKILL_MODIFY_ENFORCE=enforce 同上 → rc=2 + stderr 含 BLOCKED
3. off 档：env=…=off → rc=0 无输出
4. 已授权实测：用真实活跃计划（plans/task-v079-skill-modify-conservatism）的 scope token（如 skills/task-planner/scripts/check-complete.sh）+ worktree 真实路径 → enforce 档也应 rc=0 放行（授权优先于档位）
5. 非技能文件：/tmp/foo.txt → rc=0 无输出
6. 接线自验：`grep -n check-skill-modify zcode-pretooluse.sh` ≥1
注意：实跑时 sid 用假 sid 无活跃计划亦可测第 4 步分支；六条证据原样贴检查点。
