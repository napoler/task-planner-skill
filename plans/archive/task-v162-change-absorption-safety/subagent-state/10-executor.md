# S10 checkpoint — 级联清账修复 + 全量重跑至 ΣFAIL=0

- **任务**: task-v162-change-absorption-safety / Phase 6 / S10（10 脚本 12 断言修复 → 全量重跑 ΣFAIL=0）
- **执行体**: executor/sonnet-1
- **执行时间**: 2026-10-10
- **worktree（操作区）**: /home/terry/task-planner-skill-worktrees/v162-change-absorption-safety
- **修复目录**: <wt>/skills/task-planner/scripts/
- **执行范围约束遵守**: 只改 S9 FAIL 清单内的 10 个脚本；未触碰其他 worktree；未删减任何断言（每处 = 口径扩展或机械替换）
- **根因**: v162 落地的 Rule 74（变更吸收三判）使 SKILL.md 全集锚 `1-71`→`1-74`、头注括注 `Rule 40-74 全集`；10 个脚本的字面/宽容锚仍钉在 1-71 / 40-71 旧纪元 → 级联漏改。

## 修复对照表（10 文件 / 12 断言）

| # | 脚本 | 断言 | 类 | 修复前 → 修复后 | 位置 |
|---|------|------|----|-----------------|------|
| 1 | selftest-lane-advancement.sh | LA-12 | A 机械 | `grep -c 'Critical Rules 1-71'` → `'Critical Rules 1-74'`（+ 消息文本同步） | :135/:137 |
| 2 | selftest-tool-selection.sh | TS-05 | A 机械 | `grep -c 'Critical Rules 1-71'` → `'Critical Rules 1-74'` | :64/:66 |
| 3 | selftest-requirement-coverage.sh | RC-11 | A 机械 | `grep -c 'Critical Rules 1-71'` → `'Critical Rules 1-74'` | :131/:133/:135 |
| 4 | selftest-source-anchor-discipline.sh | SA-07 | A 机械 | `grep -cF '1-71'` → `'1-74'`（bullet+C50 锚不动） | :38/:39 |
| 5 | selftest-self-resolution.sh | SR-07 | A 机械 | `grep -c 'Critical Rules 1-71'` → `'Critical Rules 1-74'` | :81/:83 |
| 6 | selftest-self-resolution.sh | SR-08 | B 宽容 | `含 Rule 40-(5[3-9]\|6[0-9]\|7[0-1])` → `…\|7[0-4])`（^40\.=6 断言不动） | :90/:93 |
| 7 | selftest-context-pressure.sh | CP-07 | B 宽容 | `1-(69\|71)` → `1-(69\|71\|74)`（c1/c2 双锚 + 消息；C48/C49/C50 不动） | :100-108 |
| 8 | selftest-research-first.sh | RF-07 | B 宽容 | 头注 `Critical Rules 1-71（含 Rule 40-(65\|69\|71) 全集` → `1-74（含 Rule 40-(65\|69\|71\|74) 全集`（bullet 锚不动） | :76 |
| 9 | selftest-root-resolution.sh | RR-09 | B 宽容 | `Critical Rules 全集 1-(5[3-9]\|6[0-9])` → `…\|7[0-4])`（负断言 1-51/53/55=0 不动） | :110/:113/:115 |
| 10 | selftest-root-resolution.sh | RR-16 | B 宽容 | 索引行 `Rule 40-(5[3-9]\|6[0-9]\|7[0-1])` → `…\|7[0-4])`（兜底判定不动） | :177/:178/:182 |
| 11 | selftest-drift-check-subagent.sh | DCS-11 | C 条件 | `Rule 40-(69\|71) 全集` → `Rule 40-(69\|71\|74) 全集`（另两条件 Rule 61 锚本已满足） | :61 |
| 12 | selftest-execution-honesty.sh | EH-09 | 补修(B 宽容) | `Rule 40-(5[3-9]\|6[0-9]\|7[0-1])` → `…\|7[0-4])`（Rule 54/C38 锚不动） | :98/:100/:102 |

> 注：#12（EH-09）不在派发 prompt 的 A/B/C 三档枚举内，但属 S9 FAIL 清单第 10 脚本 selftest-execution-honesty.sh 的失败断言，为达成"10 脚本 12 断言 ΣFAIL=0"目标一并修复（同类 B 宽容锚演进）。

## 重跑结果（全量 72 脚本）

- **命令**: `cd <wt>/skills/task-planner/scripts && for f in selftest-*.sh; do timeout 120 bash "$f" > "/tmp/v162b-$f.log" 2>&1; rc=$?; printf '%s rc=%s\n' "$f" "$rc" >> /tmp/v162b-selftest-results.txt; done`
- **脚本总数**: 72（含 selftest-absorption-discipline.sh）
- **rc 分布**: `72 rc=0`（无 rc=1，无超时 rc=124）
- **ΣPASS = 1094，ΣFAIL = 0**（= S9 的 ΣPASS 1082 + 12 条修复转 PASS）
- **ΣFAIL 机械核验**:
  - `grep -hE '^Total:' *.log | grep -oE 'FAIL=[0-9]+'` 求和 = **0**
  - `grep -hE '^Total: [0-9]+ pass, [0-9]+ fail'` 的 fail 求和 = **0**
  - 仅剩 1 处 "FAIL" 字样 = `RR-10 PASS … 缺锚副本使 RR-03 同款判定 FAIL（有牙齿实测）`（负向自检 PASS 描述，非失败，与 S9 记录一致）
- **10 个修复脚本逐个 Total 行**:
  - lane-advancement `Total: 14 PASS=14 FAIL=0`（S9: 13/1）
  - self-resolution `Total: 13 PASS=13 FAIL=0`（S9: 11/2）
  - tool-selection `Total: 12 PASS=12 FAIL=0`（S9: 11/1）
  - requirement-coverage `Total: 23 PASS=23 FAIL=0`（S9: 22/1）
  - source-anchor-discipline `Total: 12 pass, 0 fail`（S9: 11/1）
  - context-pressure `Total: 9 PASS=9 FAIL=0`（S9: 8/1）
  - research-first `Total: 12 PASS=12 FAIL=0`（S9: 11/1）
  - root-resolution `Total: 17 PASS=17 FAIL=0`（S9: 15/2）
  - drift-check-subagent `Total: 20 PASS=20 FAIL=0`（S9: 19/1）
  - execution-honesty `Total: 14 PASS=14 FAIL=0`（S9: 13/1）
- **无断言删减核验**: 10 脚本 PASS 由 S9 的 134 → 146（+12），恰等于修复的 12 条；无 PASS 数下降。

## 三文件契约 / 证据

- 计划: /mnt/data/dev/task-planner-skill/plans/task-v162-change-absorption-safety/task_plan.md
- 调研: /mnt/data/dev/task-planner-skill/plans/task-v162-change-absorption-safety/findings.md（§吸收现状审计 A3 节）
- 进度: /mnt/data/dev/task-planner-skill/plans/task-v162-change-absorption-safety/progress.md
- S9 FAIL 清单: /mnt/data/dev/task-planner-skill/plans/task-v162-change-absorption-safety/subagent-state/09-code-runner.md
- 重跑 rc 清单: /tmp/v162b-selftest-results.txt（72 行）
- 逐脚本日志: /tmp/v162b-selftest-*.log（72 个）
- **worktree git status --short**（本步骤后）:
  `M skills/task-planner/SKILL.md / M references/critical-rules.md / M scripts/selftest-{context-pressure,drift-check-subagent,execution-honesty,lane-advancement,requirement-coverage,research-first,root-resolution,self-resolution,source-anchor-discipline,tool-selection}.sh / M scripts/selftest-registry.tsv / M templates/{subagent_dispatch.md,task_plan.md} / ?? scripts/selftest-absorption-discipline.sh`
  - 本步骤 S10 新增改动 = 上述 10 个 selftest-*.sh（diff --stat: 10 files, 40 insertions(+), 30 deletions(-)）；其余 M/?? 为前序 Phase 既有工作集，未由本步骤触碰。
- **bash -n 语法核验**: 10 个修复脚本全部 OK（无语法错误）。

## 负结果与排除记录

- 检查了 72/72 脚本 rc，未发现 rc≠0；排除超时风险（无 rc=124）。
- 排除隐藏失败：对全部日志做 `\bFAIL\b` 扫描，仅 RR-10 PASS 描述行含字样（负向自检），非失败。
- 排除断言删减：10 脚本 PASS 净增 +12，与修复数一致，无 PASS 减少。
- 排除范围越界：git status 确认仅 10 个目标脚本为本步骤新增改动，未触碰其他 worktree / 其他文件。
- 未发现需回滚的修复（每处修复均使对应断言由 FAIL 转 PASS 且未引入新 FAIL）。

## 返回契约（Rule 22.4b）

- status: done
- acceptance: 10 文件 / 12 断言全部修复（对照表见上）；全量 72 脚本重跑 rc=0，ΣPASS=1094，ΣFAIL=0（双路机械核验：uppercase FAIL= 求和=0、lowercase fail 求和=0）；bash -n 全 OK；无断言删减。
- checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v162-change-absorption-safety/subagent-state/10-executor.md
