# 05-s4-inject checkpoint (S4 variant lineage/spec_version 批量注入)
- start: 2026-11-20 (session init)

## Milestones
- 2026-11-20 04:48:14 start: checkpoint created
- 2026-11-20 04:51:20 milestone: created inject-template-lineage.sh and chmod +x
- 2026-11-20 04:51:56 milestone: created inject-template-lineage.sh (+x)
- 2026-11-20 04:52:52 milestone: fixed inject-template-lineage.sh write mode bug (missing w on 3 write opens)
- 2026-11-20 04:53:52 milestone: inject run complete (29 inserted, 2 exempt skipped, base+kit inserted); idempotent rerun ok
- 2026-11-20 04:54:47 milestone: VC-13/11/15 spot checks pass; check-template-type loop OK=31 FAIL=0; selftest-template-lifecycle 24/24 rc=0; selftest-antiregress 9/9 rc=0; 3-variant pruned audit all MATCH
- 2026-11-20 04:57:01 milestone: ran full run-selftests.sh (path skills/task-planner/scripts/run-selftests.sh) -> see /tmp/s4-run-selftests.log

## 抽检记录（≥3 variant：pruned vs 实际 heading 差集）
- 样本1 longform-continuity-type.md (大): MATCH=True, pruned_count=32, expected_count=32, sample_keys=['用户需求原文','根源覆盖表','不变量声明区','...','委派统计','SubagentHandoff登记表','Chain区块交接配置']
- 样本2 writing-type.md (中): MATCH=True, pruned_count=23, expected_count=23, sample_keys=['用户需求原文','根源覆盖表','不变量声明区','...','ErrorsEncountered','Notes','Chain区块交接配置']
- 样本3 bugfix-type.md (小): MATCH=True, pruned_count=16, expected_count=16, sample_keys=['用户需求原文','根源覆盖表','不变量声明区','...','收尾回读梳理记录','FMEA预演','Chain区块交接配置']
- 证据：python3 审计输出 `/tmp` 会话内（pruned 字段与 base `##` 标题差集逐项核对一致）

## 103.2 自审
- 变更范围：仅 worktree 内 kit SKILL(+spec_version 行)、base task_plan(首行 lineage)、29 variant(首行 lineage)、新建 inject-template-lineage.sh；mini-lite-type.md/l0-lite-type.md 未注入且首行未变；既有 scripts/规则/三份 SKILL/规则文件未改。
- 幂等性：`inject-template-lineage.sh --with-base` 二次运行→insert=0 replace=0 unchanged=29 skip-exempt=2, BASE/KIT unchanged。
- 兼容性：`check-template-type.sh` 循环 31 个 variant 全 OK(0 FAIL)；自测 lifecycle 24/24 rc=0、antiregress 9/9 rc=0。
- 回归：全量 run-selftests 101 PASS=92 FAIL=9，较 S3 后有效基线(101/93/8 同8集)新增 `selftest-plan-tier`(PT-26 断言首行 `# Task Plan: pp`，因 base 首行按规范插入 lineage 注释导致)。禁改既有 scripts 无法在本 S-unit 内修复该断言漂移，已如实登记。

## 最终结论
status: partial
acceptance: 4/5 — [1:PASS 2:PASS 3:PASS 4:FAIL 5:PASS]
files: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/plan-template-kit/scripts/inject-template-lineage.sh(+165/-0); /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/plan-template-kit/SKILL.md(+2/-0); /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/task-planner/templates/task_plan.md(+1/-0); /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/task-planner/templates/variant/*-type.md(29 files, +1/-0 each; mini-lite-type.md,l0-lite-type.md exempt unchanged)
evidence: skills/task-planner/templates/task_plan.md:1→`<!-- template-lineage: level=base spec_version=1 -->`; skills/plan-template-kit/SKILL.md:8→`> 模板规范版本: spec_version=1...`; `grep -rl template-lineage skills/task-planner/templates/variant | wc -l`→29; `check-template-type.sh` loop→OK=31 FAIL=0 (/tmp/s4-check-template-type.log); `selftest-template-lifecycle.sh`→Total:24 PASS=24 FAIL=0 rc=0; `selftest-antiregress.sh`→Total:9 PASS=9 FAIL=0 rc=0; 3-sample pruned audit(longform-continuity/writing/bugfix)→MATCH True(32/23/16); `run-selftests.sh`→Total:101 PASS=92 FAIL=9 Failed含新增 selftest-plan-tier; `selftest-plan-tier.sh`→PT-26 FAIL 首行=`<!-- template-lineage: level=base spec_version=1 -->` 期望`# Task Plan: pp`
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/subagent-state/05-s4-inject.md (status: partial)
findings_written: #### [sub:05-s4]
blockers: 全量 selftest FAIL 集较基线8新增 selftest-plan-tier（PT-26 因 base 首行按规范插入 lineage 注释导致标题行断言失效）；既有 scripts 禁改，需后续 S-unit 修订 PT-26 或 init 渲染契约兼容
confidence: HIGH
- 2026-11-20 05:05:56 final: checkpoint finalized (status partial)
- 2026-11-20 05:07:51 rework-start: fixing placement to after H1 per返工指令
- 2026-11-20 05:09:08 rework: rewrote inject-template-lineage.sh with after-H1 placement logic
- 2026-11-20 05:12:51 rework: plan-tier 32/32, check-template-type 31/31, lifecycle 24/24, antiregress 9/9 all PASS; running full run-selftests

## 返工 #1（placement 修复）
- 原因：lineage 头插在第1行压住 H1/首行，触发 selftest-plan-tier PT-26（首行应为 `# Task Plan: ...`）。
- 修复：`inject-template-lineage.sh` 改为 upsert 到首个 H1(`# `)之后；base 额外在紧随 H1 的 `<!-- 渲染契约... -->` 注释行之后插入（保持幂等 replace，先移除旧 lineage 行再按目标位置插入）。
- 结果：`--with-base` rerun→variants replace=29, base replace, kit unchanged；base 1-3 行=`# Task Plan` / 渲染契约注释 / lineage 注释；variant(例 bugfix) lineage 在 H1 之后；mini-lite/l0-lite 未变；idempotent rerun 全 unchanged。
- 验证：`selftest-plan-tier.sh`→Total:32 PASS=32 FAIL=0 rc=0 (PT-26 PASS)；`check-template-type` loop OK=31 FAIL=0；`selftest-template-lifecycle.sh` 24/24 rc=0；`selftest-antiregress.sh` 9/9 rc=0；全量 `run-selftests.sh`→Total:101 PASS=93 FAIL=8, Failed={active-plan,batch-pilot,enumerate-first,execution-stability,registry,rule-reserve-pairing,self-resolution,summary-readability} ==基线8集零新增。3样本 pruned audit 仍 MATCH(32/23/16)。

## 最终结论（返工后）
status: done
acceptance: 5/5 — [1:PASS 2:PASS 3:PASS 4:PASS 5:PASS]
files: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/plan-template-kit/scripts/inject-template-lineage.sh(+165/-0, placement after H1; base after 渲染契约 comment); /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/plan-template-kit/SKILL.md(+2/-0); /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/task-planner/templates/task_plan.md(+1/-0, lineage at line3 after H1+渲染契约); /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/task-planner/templates/variant/*-type.md(29 files, +1/-0 each placed after H1; mini-lite-type.md,l0-lite-type.md exempt unchanged)
evidence: base `task_plan.md:1`→`# Task Plan: {{TASK_NAME}}`, `:2`→渲染契约注释, `:3`→`<!-- template-lineage: level=base spec_version=1 -->`; `skills/plan-template-kit/SKILL.md:8`→`> 模板规范版本: spec_version=1...`; `grep -rl template-lineage skills/task-planner/templates/variant|wc -l`→29; idempotent rerun→insert=0 replace=0 unchanged=29 skip-exempt=2, BASE/KIT unchanged; `check-template-type` loop→OK=31 FAIL=0 (/tmp/s4-rework-check-template-type.log); `selftest-plan-tier.sh`→Total:32 PASS=32 FAIL=0 PT-26 PASS rc=0 (/tmp/s4-rework-plan-tier.log); `selftest-template-lifecycle.sh`→24/24 rc=0; `selftest-antiregress.sh`→9/9 rc=0; pruned audit longform-continuity/writing/bugfix=32/23/16 MATCH; `run-selftests.sh`→Total:101 PASS=93 FAIL=8 Failed={active-plan,batch-pilot,enumerate-first,execution-stability,registry,rule-reserve-pairing,self-resolution,summary-readability} 零新增 (/tmp/s4-rework-run-selftests.log)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/subagent-state/05-s4-inject.md (status: done)
findings_written: #### [sub:05-s4]
blockers: none
confidence: HIGH
- 2026-11-20 05:16:33 rework-final: checkpoint finalized status done
