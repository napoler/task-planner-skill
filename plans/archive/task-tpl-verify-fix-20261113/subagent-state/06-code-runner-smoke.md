# 06-code-runner-smoke 渲染冒烟+基线回归 checkpoint

- 时间戳: 2026-11-13T03:04:00+08:00 (approx)
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113
- smoke dir: plans/tmp-smoke-tplfix (已清理)

## Step 1 渲染
- 命令: `cd /mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113 && mkdir -p plans/tmp-smoke-tplfix && cd plans/tmp-smoke-tplfix && TASK_PLANNER_ROOT=/mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113/skills/task-planner bash /mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113/skills/task-planner/scripts/init-session.sh "冒烟-模板验证" 2>&1 | tail -20`
- 输出(尾部原文):
```
  └─ notepad-learnings.md (built-in)
    Created notepad-learnings.md
  └─ verification.md (built-in)
    Created verification.md
  └─ knowledge-brief.md (project-level)
    Created knowledge-brief.md
  └─ task_plan.md (built-in)
    Created task_plan.md
  └─ user-session-log.md (built-in)
    Created user-session-log.md (task-v169 Rule 80.1 第 7 计划文件, append-only 逐字记录专档)
    [init] .session-log-baseline created (task-v176 D4: first-entry-sha=-… entries=0, append-only 完整性基线)
[template-sense] ⚠ 任务类型空缺（general 兜底）——按 Rule 34.3②/34.7 评估沉淀，终验必查
    [template-sense] task_plan.md 末尾已追加「🔁 模板感知」区块
[init] INFO: task_plan.md 已含 🎯 用户需求原文 + 🧮 根源覆盖表 双区块（模板自带载体）— 注入跳过
[init] INFO: task_plan.md 已含 🔍 证据面清单 + 🎯 核心目标达成裁决 双区块（模板自带载体）— 注入跳过

[init] 6/6 planning files verified
[init] user-session-log.md verified (7th planning file, task-v169 Rule 80.1)
[init] active_plan side 指针已指向: tmp-smoke-tplfix(sid=subagentagentb5b3495d701f4eb086ef0c7)
Planning files initialized!
```
- 文件列表: findings.md, knowledge-brief.md, notepad-learnings.md, progress.md, task_plan.md, user-session-log.md, verification.md (7 files)
- token 检查: `grep -c '{{[A-Z_]*}}' task_plan.md` => 1 (仅 line 2 注释: `{{VAR}}` 渲染契约说明); verification.md 同类注释命中 1。功能模板体无机械 `{{UPPER}}` 泄漏。

## Step 2 最小语义填充
- task_plan.md: R1 改为「冒烟验证：新模板渲染后可一次过门」[目标]; Phase 1(explore)/Phase 3(general-coder)/Phase 4(code-runner-agent) 各补/修正 10 列 S-unit 数据行（含（A6）/（A7）前缀、10min、1f/Nl/10min 粒度、输入路径≤2）; Goal G1 填真实验证方式 `test -f plans/tmp-smoke-tplfix/task_plan.md`。
- verification.md: VC-1 改为 `**Verify command**: test -f /mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113/plans/tmp-smoke-tplfix/task_plan.md`（行首）。
- 过程: 首次 check-plan-dispatch 报 Phase 1 缺 S-unit 表、G1 占位符、Phase 3 S2 时长不可解析；迭代修正后通过。

## Step 3 过门校验 (check-plan-dispatch)
- 命令: `bash skills/task-planner/scripts/check-plan-dispatch.sh plans/tmp-smoke-tplfix/task_plan.md 2>&1 | tail -30; echo EXIT:$?`
- 输出原文:
```
[plan-dispatch] ✓ 3 个派发型 Phase 均有带执行体的 S-unit 表
EXIT:0
```
- ✗ 行: 0（无拒锁项）。首次尝试曾见 SKIPPED/✗ 已在 smoke 内修正，最终通过。

## Step 4 VC 结构校验
- 命令: `grep -c '^\*\*Verify command\*\*: test -f' /mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113/plans/tmp-smoke-tplfix/verification.md`
- 输出: `1` (>=1)

## Step 5 基线回归 (run-selftests)
- 命令: `bash skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -10` (后台完成, exit 0)
- 输出尾部原文:
```
[run]    selftest-tool-selection (rc=0 PASS=12 FAIL=0)
[run]    selftest-user-instruction-priority (rc=0 PASS=0 FAIL=0)
[run]    selftest-vc-gate (rc=0 PASS=11 FAIL=0)
[run]    selftest-vc-nonvacuous (rc=0 PASS=13 FAIL=0)
[run]    selftest-verification-gate (rc=0 PASS=13 FAIL=0)
[run]    selftest-verify-io (rc=0 PASS=0 FAIL=0)
[run]    selftest-veto (rc=0 PASS=13 FAIL=0)
[run]    selftest-workflow-orchestration (rc=0 PASS=22 FAIL=0)
Total: 97 PASS=94 FAIL=3 (run=97 reused=0)
Failed: selftest-active-plan selftest-execution-stability selftest-subagent-granularity-skill-escort
EXIT:0
```
- 期望对照: 期望 FAIL=2 {selftest-active-plan, selftest-execution-stability}; 实际 FAIL=3，额外 `selftest-subagent-granularity-skill-escort`。日志中未检出 `SA-19`/`selftest-subagent-activation` 字样（grep 无命中），无法从捕获文本确认 SA-19 PASS，仅确认未列入 Failed 清单。

## Step 6 清理
- 命令: `rm -rf /mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113/plans/tmp-smoke-tplfix && test ! -d .../plans/tmp-smoke-tplfix && git status --short`
- 结果: `REMOVED` / `SMOKE_DIR_ABSENT`
- git status (无 smoke 残留; 既有改动来自前序 phase):
```
 M skills/plan-template-kit/references/template-guide.md
 M skills/plan-template-kit/references/template-mapping.md
 M skills/task-dispatch/references/critical-rules-dispatch.md
 M skills/task-planner/scripts/selftest-subagent-activation.sh
 M skills/task-planner/templates/task_plan.md
 M skills/task-planner/templates/verification.md
```

## 风险/备注
- 自测 FAIL 清单与期望基线不一致（多出 selftest-subagent-granularity-skill-escort），SA-19 未在日志中显式定位；需后续确认。
- {{UPPER}} 计数=1/文件均为渲染契约注释行，非功能 token 泄漏。
