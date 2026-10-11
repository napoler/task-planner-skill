# S32-g1-hooks — G9/C-1 hook 热路径改动·干净上下文独立验证检查点

- 验证者: 全新子代理（干净上下文）, 2026-09-27
- 验证对象: worktree /mnt/data/dev/task-planner-skill-worktrees/task-v091/skills/task-planner/ 内 C-1a/C-1b/C-1d/C-1e（commit de69956/6e79257/fb28b70/28221a7/aff5e06 及同链 S11-S19）
- 约束遵守: 只读 worktree 源码 + 跑验证命令 + /tmp 夹具；未写 worktree 任何文件
- 基线参照: efficiency-proposal.md §三 C-1「子代理干净上下文验证设计」+ progress.md S11-S20 各行

## 1. C-1b config 双层路径 jq（zcode-posttooluse.sh 6 键）— PASS

修复后表达式（worktree scripts/zcode-posttooluse.sh:111-117 实读原文）:
```
.todo_sync_interval_calls // .properties.todo_sync_interval_calls.default // 10
.plan_update_interval_minutes // .properties.plan_update_interval_minutes.default // 15
.stale_remind_cooldown_calls // .properties.stale_remind_cooldown_calls.default // 10
.findings_stale_minutes // .properties.findings_stale_minutes.default // 20
.progress_stale_minutes // .properties.progress_stale_minutes.default // 25
.compass_escalate_after // .properties.compass_escalate_after.default // 2
```
修改前（git show de69956^:…/zcode-posttooluse.sh:109-116 实读）: `.properties.X.default // 兜底` 单层（6 键全部单层，`compass_escalate_after` 位点较提案多 1 键与 progress S11 记载一致）。

三组 config 对拍（/tmp/c1b-verify 夹具）:
- a) 顶层覆盖 overrides.json（6 键各给不同值 99/7/3/5/6/9）: 新表达式 6 键全部读出覆盖值（`todo_sync_interval_calls => 99` 等）✅
- b) 原版 worktree config.json（无顶层覆盖）: 新 vs 旧逐值 SAME ×6（10/15/10/20/25/2 全部 new=old）✅ 与修改前行为逐值一致
- c) 空 {}: 新表达式全部落兜底（10/15/10/20/25/2）✅；额外文件缺失 case: 输出空串 → `case` 兜底默认值，fail-open 保持 ✅

## 2. C-1a①②③ PreToolUse 行为（fixture 仓 + fork 数）— PASS（含 1 项已登记偏差）

夹具: /tmp/c1a-fixture（git init 仓, ≥3 计划）: task-alpha（active 最新 mtime）/ task-beta（在途, scope 含 src/main.py）/ task-gamma（无指针过期在途, scope=gamma-only.txt）/ task-done（task_plan.md 无 outcome + verification.md `outcome: COMPLETE`）。

新脚本（worktree 现版）四场景结果:
- s1 Edit /tmp/c1a-fixture/src/main.py + cwd=夹具: `{"additionalContext": "[conflict] 文件 /tmp/c1a-fixture/src/main.py 可能与其他 plan(task-beta, session=sessB001)冲突,请确认 scope"}` ✅ 在途命中→stdout 含 [conflict]
- s2 Edit task-done scope 文件: stdout 空 ✅ COMPLETE 命中→不提醒
- s3 Edit gamma-only.txt（无指针过期在途）: `[conflict] … plan(task-gamma, session=sessG001)` ✅ 仍被扫到
- s4 cwd=/tmp: stdout 空 ✅ 不误扫 worktree（grep task-v091/worktrees 命中 0）
- C-1a① 兜底: 无 .cwd 时 `CWD="${CWD:-$PWD}"` 保留（zcode-pretooluse.sh:96-97 实读）

旧脚本（git show 6e79257^ / fb28b70^ 取回, 同四场景）: s1/s2/s3/s4 stdout 全部为空。s2/s4 两侧一致（空=空）；**s1/s3 旧版恒空 = 既有的 `\\.[a-zA-Z]` 字面反斜杠正则缺陷（R23-01/03 基线红，progress S13/S14/S15 已裁量登记：提取逻辑恢复属 36.4 清单已确认范围内，非 C-1a 引入的行为变更）**——新版 [conflict] 产出 = 提案 G9 三夹具期待（第二计划命中→提醒/COMPLETE→不提醒/无指针在途→仍扫到）逐条吻合。

fork 数（strace -f -e trace=clone 计数整脚本单次触发, s1 命中场景）:
- 旧（fb28b70^ 脚本）: 100 clone/fork
- 新（worktree 现版）: 73 clone/fork（s1）/ 70（s2 无循环内 jq）/ 58（s4 无 plans 早退）
- s4 场景旧=新=58（早退路径零变化）✅
- 整脚本计时 3 次中位: 新 269-285ms vs 旧 313-320ms（新 < 旧 < 500ms 提案 R1 目标）

## 3. C-1d check-scope realpath 化不变性 — PASS

- 全文件 diff（28221a7^ vs 现版）: 唯一代码行改动 = :51 `python3 -c "os.path.abspath"` → `realpath -m --`（+S17 注释块）。
- 10 组输入对拍（/tmp/c1d-verify, 绝对/相对/..×2/尾斜杠/不存在/plans 路径/memory 豁免/.plan-required/系统文件/豁免名）: 新旧 stdout+rc 逐条一致, 汇总文件 diff 为空 ✅
- 场景对拍: 哨兵 active+计划 mtime 早于哨兵+无 attestation → 两侧 rc=1 且 `[PLAN-GUARD] 🚫 本会话计划哨兵未满足 (.plan_required_side active: ZZZ.plan_required)` 逐字一致 ✅
- D10'' 篡改仲裁段: 现版 check-scope.sh:139-155 相对旧版 :132-148 仅 +7 行偏移（S17 注释插入）, 去注释代码段 byte-identical；逻辑=side 指针→.plan-attestation 锁定哈希 vs task_plan.md 实时 sha256sum 一致才放行（:149-157 实读），零改动 ✅
- check-scope 无独立 CLI 单测入口（依赖 PreToolUse 哨兵场景驱动）, 故按任务授权走「代码对拍+行为对拍」双轨, 仲裁段以逐字节 diff 证明零改动。

## 4. C-1e UPS 单 awk 不变性 — PASS

脚本集: old=aff5e06^ 全部脚本（/tmp/c1e-oldset）, new=worktree HEAD（/tmp/c1e-newset）；同 stdin JSON 各跑一次, 归一化 SKILLROOT 路径差异后 diff:
- s1 主夹具（对抗注释 decoy + 多 Phase + 注释区间 ip + Decisions 末 3 行）: DIFF EMPTY ✅
- s2 未闭合注释删到 EOF（`| 1 | x | y |` 落在注释内仍被原文 decisions 取到）: DIFF EMPTY ✅
- s3 同行 `<!-- … -->` 只开不闭（GNU sed 区间语义, progress S19 关键修正点）: DIFF EMPTY ✅
- s4 各节空值兜底: DIFF EMPTY ✅
- s5 注释内 `**Status:** in_progress` decoy（原文 RS 提取不剥注释→取 Phase1 done 记录, 两侧一致）: DIFF EMPTY ✅
- 差异仅 attest 提示行中 SKILL_ROOT 目录名（两套脚本集位于不同 /tmp 路径, 环境固有, 非行为差异）
- 备注: aff5e06^ 时 point 不存在 3 个 selftest-* 新增脚本（本侧 aff5e06^ 取回缺项）, 以 HEAD 版补齐 oldset——这 3 个脚本 UPS 运行路径零引用, 不影响对拍。

## 负结果/边界登记

1. 旧版 s1/s3 [conflict] 恒空 = 既有正则缺陷（S13/S15 裁量范围内）, 本验证如实记录两侧输出而非强行判"逐字节一致"——提案 C-1 验证设计原句「常规夹具逐字节一致」对 s1/s3 夹具不成立于基线红正则缺陷, 属提案 L129-130 TDD 红→绿预期内。
2. fork 数对比用 strace clone 计数（forksleep/forkcnt 工具不存在, 用 strace 替代, 裁量记录）；73 vs 100 量级符合「每计划 1 进程」设计方向, 但绝对数含 check-scope/check-delegation 公共段（两侧基数 58 相同, 差值 27 = Rule23 循环段净降幅）。
3. UPS 对拍 SKILLROOT 路径归一化：两套脚本集位于不同目录, attest 提示行内嵌 SKILL_ROOT 全路径, sed 归一后再 diff; 除该位外零差异。
4. 未验证项（不在本组任务范围）: C-1c lib 对拍、C-1f check-conflicts 9→6 git 合并、C-2 SKIP-BY-HASH 六夹具——由对应 S-unit 检查点承载, 本组只验 C-1a/b/d/e。
