# S12 回归检查点 — 全量 selftest 对照基线

- 执行时间: 2026-10-24
- 工作区: /mnt/data/dev/task-planner-skill-worktrees/task-tplrender-20261024
- HEAD: dc426c1 (S11 SKILL.md) / 前序 b983b3b (S12 render_template)
- 基线: Total: 93 PASS=93 FAIL=0
- 本次: **Total: 93 PASS=91 FAIL=2 (run=93 reused=0)** → **2 处回归**

## 1. 全量输出（tail -30，命令原文）

```
[FAIL]   selftest-session-log (rc=1)
[run]    selftest-shared-tracker (rc=0 PASS=11 FAIL=0)
[run]    selftest-skill-collab (rc=0 PASS=25 FAIL=0)
[run]    selftest-skill-modify (rc=0 PASS=7 FAIL=0)
[run]    selftest-skill-split (rc=0 PASS=40 FAIL=0)
[run]    selftest-smart-merge (rc=0 PASS=18 FAIL=0)
[run]    selftest-source-anchor-discipline (rc=0 PASS=0 FAIL=0)
[run]    selftest-split-pattern-library (rc=0 PASS=13 FAIL=0)
[run]    selftest-state-consistency (rc=0 PASS=5 FAIL=0)
[run]    selftest-step-placeholders (rc=0 PASS=10 FAIL=0)
[run]    selftest-subagent-activation (rc=0 PASS=15 FAIL=0)
[run]    selftest-subagent-granularity-skill-escort (rc=0 PASS=23 FAIL=0)
[run]    selftest-subagent-return (rc=0 PASS=12 FAIL=0)
[run]    selftest-summary-readability (rc=0 PASS=13 FAIL=0)
[run]    selftest-sync-index (rc=0 PASS=15 FAIL=0)
[run]    selftest-task-boundary (rc=0 PASS=11 FAIL=0)
[run]    selftest-template-lifecycle (rc=0 PASS=24 FAIL=0)
[run]    selftest-template-sense (rc=0 PASS=8 FAIL=0)
[run]    selftest-tier-b (rc=0 PASS=18 FAIL=0)
[run]    selftest-tier-consistency (rc=0 PASS=8 FAIL=0)
[run]    selftest-tool-selection (rc=0 PASS=12 FAIL=0)
[run]    selftest-user-instruction-priority (rc=0 PASS=0 FAIL=0)
[run]    selftest-vc-gate (rc=0 PASS=11 FAIL=0)
[run]    selftest-vc-nonvacuous (rc=0 PASS=13 FAIL=0)
[run]    selftest-verification-gate (rc=0 PASS=13 FAIL=0)
[run]    selftest-verify-io (rc=0 PASS=0 FAIL=0)
[run]    selftest-veto (rc=0 PASS=13 FAIL=0)
[run]    selftest-workflow-orchestration (rc=0 PASS=22 FAIL=0)
Total: 93 PASS=91 FAIL=2 (run=93 reused=0)
Failed: selftest-plan-tier selftest-session-log
```

完整日志: `/tmp/selftest-s12-full.log`（95 行，含全部 93 脚本行）

## 2. 与基线对照表

| 指标 | 基线 | 本次 | 差异 |
|------|------|------|------|
| 脚本总数 | 93 | 93 | 0 |
| 脚本 PASS | 93 | 91 | **-2** |
| 脚本 FAIL | 0 | 2 | **+2** |
| ΣFAIL（脚本级） | 0 | 2 | **非零回归** |

### 逐脚本差异（仅列异常）

| 脚本 | 基线 | 本次 | rc | 断言级 |
|------|------|------|----|--------|
| selftest-plan-tier | PASS | **FAIL** | 1 | 32 断言 → 31 PASS / 1 FAIL (PT-26) |
| selftest-session-log | PASS | **FAIL** | 1 | 12 断言 → 11 PASS / 1 FAIL (SL-07) |

### 其余 91 脚本
全部 `rc=0 FAIL=0`，无 PASS 数异常可探测（基线未提供逐脚本 PASS 明细，仅提供聚合 93/93）。
注：`PASS=0` 的 5 个脚本（absorption-discipline / channel-fast-fail / source-anchor-discipline / user-instruction-priority / verify-io）为纯 rc 型脚本，基线与本次同为 PASS=0 FAIL=0，非异常。

## 3. FAIL 明细（不修复，交 S13）

### FAIL-1: selftest-plan-tier PT-26

- 位置: `skills/task-planner/scripts/selftest-plan-tier.sh:365-374`（断言 line 368）
- FAIL 原文: `PT-26 FAIL 全缺省路径行为漂移(出现 S6 路由行或产物非 general)`
- 断言内容: 全缺省（无项目目录/无 default/无 env）时 `head -1 task_plan.md` 应匹配 `Task Plan: \[Brief Description\]`，且 out.log 无 S6 路由/插入行
- 期望 vs 实际:
  - 期望 head-1: `# Task Plan: [Brief Description]`
  - 实际 head-1: `# Task Plan: pp`（任务名被渲染替换）
  - out.log 两条负断言均通过（无「未显式给 template_type」「已插入 frontmatter」）
- 根因: `init-session.sh:231` 新增 `-e "s|\[Brief Description\]|${e_task_name}|g"`（b983b3b / S12 render_template），模板 `templates/task_plan.md:1` 的 `[Brief Description]` 被脚本渲染为任务名 → 旧断言的字面期望失效。属渲染契约的有意行为 vs 陈旧断言，非产物错误。
- 证据: `git show b983b3b^:skills/task-planner/templates/task_plan.md | head -1` = `# Task Plan: [Brief Description]`；blame line 231 = b983b3b2
- 置信度: HIGH

### FAIL-2: selftest-session-log SL-07

- 位置: `skills/task-planner/scripts/selftest-session-log.sh:79-82`（断言 `grep -c '6/6' -eq 1`）
- FAIL 原文: `[FAIL] SL-07 init-session.sh 'copy_template "user-session-log.md"'≥1 ∧ '6/6'=1`
- 断言内容: `copy_template "user-session-log.md"` 出现 ≥1 次 ∧ 字面 `6/6` 出现次数 **恰为 1**
- 期望 vs 实际:
  - 期望 `grep -c '6/6'` = 1
  - 实际 = **2**（`init-session.sh:986` 注释「③ 须在「6/6 verified」等最终 verify」+ `init-session.sh:1011` 实际 echo）
- 根因: b983b3b（S12）在 init-session.sh 新增位置理由注释时，注释文本含 `6/6 verified`，使字面计数 1→2；断言的「唯一性计数」语义被注释击穿。
- 证据: `grep -n '6/6' init-session.sh` 输出 986/1011 两行；blame 986 = b983b3b2；`git show b983b3b^:...init-session.sh | grep -c '6/6'` = 1
- 置信度: HIGH

## 4. 基线复现验证（父提交 b983b3b^ 独立跑）

用 `git archive b983b3b^ | tar -x -C /tmp/s12-baseline` 提取父提交，跑两个失败脚本：

```
selftest-plan-tier:  Total: 32 PASS=32 FAIL=0   PT_EXIT=0   (PT-26 PASS)
selftest-session-log: Total: 12 PASS=12 FAIL=0  SL_EXIT=0   (SL-07 PASS)
```

→ 证明两处 FAIL 均为 b983b3b 引入的**新回归**，非既有失败。

## 5. git status 结论

`git status --short` 输出为空 → worktree 干净，测试未产生仓库内副作用（selftest 均在 /tmp 或 mktemp 目录运行并自清理）。

## 6. 结论

- ΣFAIL = 2（脚本级），非零回归，**不满足 93/93 基线**
- 两个 FAIL 均为「S12 render 层改动 vs 陈旧断言」的断言失配，产物/功能行为本身符合新渲染契约
- 按任务分工：**不修复**，交 S13 处理（重建断言：PT-26 期望改为渲染后任务名首行；SL-07 的唯一性计数改为锚定实际 echo 行或排除注释区）
