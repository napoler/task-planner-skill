# checkpoint 021-code-assistant-s10h（task-v070 Phase 4 / S10h 机械级联单元：absorption/capability 两 selftest epoch 断言扩围 1-81）

任务锚: R2「必须添加归档。」；S-unit=S10h（parallel-group:g-cascade2，Rule 46.1 单任务只执行本单元）。
worktree 路径裁决（与 020-code-runner-s11 一致）：提示词给的 `/mnt/data/dev/task-planner-skill-worktrees/task-v070-archive-completed-plans` 不存在；实存 worktree = `/mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans`（派发时 HEAD d35553f，`git status --short` 空）。目标两文件按 S11 FAIL 明细 #1（AD-04）/#2（CP-05）定位于此实存 worktree。

## T1 里程碑（时间戳）
- T1.1 Read 两目标文件 + 范式先例（selftest-research-first.sh:75 宽容化注释行、selftest-self-resolution.sh:84-85 `1-7[4-9]|1-8[01]([^0-9]|$)` 负样本精化先例）+ 020 FAIL 证据（AD-04/CP-05 原文）
- T1.2 实测 SKILL.md 实态：`grep -nE '1-(7[4-9]|8[01])'` 命中 L9/L314/L406 三处（逐行 1 次，共 3 处，≥3 达成）；旧 `1-7[4-9]`=2（AD-04 失配根因确认）；CP 族 `40-(5[0-9]|6[0-9]|7[0-9]|8[01])`=1（命中 L314 'Critical Rules 1-81（含 Rule 40-81 全集'）、旧 `40-[567][0-9]`=0（CP-05 失配根因确认）
- T1.3 Edit selftest-absorption-discipline.sh AD-04（:31-34）：`1-7[4-9]`→`1-(7[4-9]|8[01])` + Rule 45 演进注释
- T1.4 Edit selftest-capability-persistence.sh CP-05（:79-84）：`40-[567][0-9]`→`40-(5[0-9]|6[0-9]|7[0-9]|8[01])` + Rule 45 演进注释
- T1.5 `bash -n` 两文件均通过；单跑 AD=13 pass/1 fail（AD-12 FAIL）、CP=20/20/0 rc=0
- T1.6 AD-12 FAIL 基线归因：`git show HEAD:…/selftest-absorption-discipline.sh`（d35553f 旧版，AD-04 未扩围态）单跑 → AD-12 同样 FAIL（且 AD-04 也 FAIL）→ 本 S-unit 引入前后 AD-12 失败态无差异 = 预存 FAIL（AD-12 pinning 锚 11 处对 1-7[4-9] 字面族 pin，属 S11 名单外其他 S-unit 的扩围面），非本单元回归
- T1.7 正/负样本实测：`echo '1-81'/'1-75'`→新 AD 正则=1；`echo '1-82'/'1-90'`→0；`echo '40-81'/'40-74'`→新 CP 正则=1；`echo '40-82'/'40-90'`→0（越界值未放开）
- T1.8 授权 git 写操作：`git add` 两目标文件 + `commit --only <两文件>`（第 1 次成功，未遇 index.lock）→ fdc56b5，恰 2 files changed +8/-6；message 逐字=`fix(selftest): task-v070/Phase 4 S10h — absorption/capability epoch 扩围 1-81`
- T1.9 并发观察：worktree 存在其他并行 S-unit 提交 987689a（S10j error-loop/execution-honesty）与工作树残留改动（summary-readability/tool-selection，属 S10j/SRV 其他单元范围）——本单元未 add/commit/触碰，按 Scope 禁改清单留在工作树

## 负结果与边界
- 未改本单元两文件之外任何文件（`git show --stat HEAD` 证实恰 2 文件）；未改 config.json；未在真实 plans/ 数据执行命令；未 add/commit 工作树中其他 S-unit 的未提交改动
- AD 脚本 Total=13 pass/1 fail 中的 AD-12 FAIL 为预存态（T1.6 基线证明），非本单元引入；不属 S10h 范围（AD-12 的 pin 字面族扩围属其他 S-unit）

## 最终结论（T5，=§7 同块）
status: done
acceptance: 2/2 pass
files: /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans/skills/task-planner/scripts/selftest-absorption-discipline.sh(+4/-2), /mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans/skills/task-planner/scripts/selftest-capability-persistence.sh(+4/-4)
evidence: 见上 T1.5-T1.8（commit fdc56b5 +8/-6；AD-04 PASS、CP-05 PASS、CP Total: 20 PASS=20 FAIL=0；负样本 1-82/1-90/40-82/40-90 全不命中）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v070-archive-completed-plans/subagent-state/021-code-assistant-s10h.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
