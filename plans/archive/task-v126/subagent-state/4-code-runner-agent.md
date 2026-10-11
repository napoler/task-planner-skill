# S4 检查点：全量 selftest 回归（task-v126 Phase 4）

- 执行体: code-runner-agent（sonnet-1 改派承接，见 Handoff 22.3①）
- 执行时间: 2026-10-04
- scope: 只读回归，零文件修改（worktree 内未做任何写入）

## 结果汇总

- 脚本数: 45（= 44 基线 + 1 新建 selftest-lane-advancement.sh，与任务书预期一致）
- 总 PASS: 701
- 总 FAIL: 1
- FAIL 脚本清单: selftest-skill-split.sh（PASS=40 FAIL=1 rc=1）

## 统计口径说明（易错点）

1. 循环提取以 `Total: ... PASS=n FAIL=n` 行为准，sed 取等号后数值（遵任务书口径）。
2. selftest-final-gate-hash.sh 末行格式为 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`（无 `Total:` 前缀），循环初次未能自动摘取；单独复跑确认后手工计入 PASS=22 FAIL=0（复跑输出原文见下，rc=0）。
3. 求和 = 44 脚本循环摘取 679/1 + final-gate-hash 22/0 = 701/1。

## 与预期对比结论

- 任务书预期「45 脚本、PASS=680 / FAIL=0」**未达成**：实际 701/1。
- PASS 数超出预期（680→701），因任务书 680 预期基于 lane-advancement 仅 +14 的估算，未计入 final-gate-hash（task-v091/S20 产物）等既有脚本的实际 22 条，属预期基数偏差，非新增异常。
- 唯一 FAIL 为 **既有回归失败**，非 S-unit 新改动产物：

```
[FAIL] T-主 行数 ≤447（task-v122 Rule 47 联动 +3;演进 440→442→444→447）且 ≤558 上限
Total: 41  PASS=40  FAIL=1
```

根因已定位（HIGH 置信，非推测）：worktree 内 `/home/terry/task-planner-skill-worktrees/task-v126/skills/task-planner/SKILL.md` 当前 `wc -l` = **449 行**，而 selftest-skill-split.sh:41 的行数锚为 `-le 447`（Rule 47 联动 440→442→444→447 演进），449>447 触发 T-主 FAIL。SKILL.md 行数由 task-v126 前序 Phase 写入推高，锚值未随之联动。

## FAIL 原文证据（skill-split 复跑 tail）

```
[PASS] T-锚 Rule 17 成本控制
[PASS] T-锚 C19 行在位
[PASS] T-锚 C25 行在位
[PASS] T-锚 C26 行在位
[PASS] T-reg registry.tsv 含 selftest-skill-split 行
Total: 41  PASS=40  FAIL=1
RC=1
```

## final-gate-hash 复跑输出（PASS=22 摘取依据，节选）

```
==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====
RC=0
```

## 负面结果声明（无 FAIL 项排除）

- 44/45 脚本（除 skill-split）全部 PASS、rc=0，未发现新增回归。
- selftest-lane-advancement.sh（本 Phase 新建）单独在循环内执行成功，已含于 679 PASS 摘取（Total 行摘取正常）。
- 未修改 worktree 内任何文件；检查点文件为任务书指定唯一写入物。

## next（建议，供主进程裁决）

1. skill-split 行数 FAIL：确认 worktree 内 SKILL.md 当前行数 → 二选一：(a) 更新 selftest-skill-split.sh 的 447 锚为新上限（Rule 47 联动），(b) 若属计划内增长，同步 knowledge-brief/Rule 47 文档锚值。
2. final-gate-hash 输出格式与循环口径不匹配：建议后续统计循环改为 `grep -oE 'PASS=[0-9]+' | tail -1` 类兜底或统一该脚本末行加 `Total:` 前缀（修脚本属后续 Phase，本回归只报不改）。
