# subagent-state: 16-code-runner（S16 全量 selftest 回归）

- **Task**: task-v155 S16 — worktree 内全部 selftest 脚本回归（预期 65 个）
- **Date**: 2026-10-10
- **Worktree**: /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability
- **执行命令**（逐脚本独立 timeout 120 + 独立日志 /tmp/rrv-<脚本名>.log）:
  `cd /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts && for f in selftest-*.sh; do timeout 120 bash "$f" >"/tmp/rrv-$f.log" 2>&1; rc=$?; echo "$f rc=$rc" | tee -a /tmp/rrv-selftest-results.txt; done`
- **实测脚本数**: `ls selftest-*.sh | wc -l` = 65（与预期一致）

## 一、逐脚本 rc 原文行（65/65）

```
selftest-active-plan.sh rc=0
selftest-agent-coverage.sh rc=0
selftest-ask-default-timeout.sh rc=0
selftest-batch-pilot.sh rc=0
selftest-capability-persistence.sh rc=0
selftest-check-conflicts.sh rc=0
selftest-check-drift.sh rc=0
selftest-conclusion-discipline.sh rc=0
selftest-context-hygiene.sh rc=0
selftest-delegation.sh rc=0
selftest-dispatch-grain.sh rc=0
selftest-dispatch.sh rc=0
selftest-drift-check-subagent.sh rc=0
selftest-drift-enforcement.sh rc=0
selftest-error-loop.sh rc=0
selftest-evidence-goal-gate.sh rc=0
selftest-execution-honesty.sh rc=0
selftest-execution-stability.sh rc=0
selftest-fallback.sh rc=0
selftest-final-gate-hash.sh rc=0
selftest-fine-grain-steps.sh rc=0
selftest-four-file-dataflow.sh rc=0
selftest-goal-unit-goal-mode.sh rc=1
selftest-interaction.sh rc=0
selftest-iteration-persistence.sh rc=0
selftest-iterative-optimizer.sh rc=0
selftest-knowledge-brief.sh rc=0
selftest-lane-advancement.sh rc=0
selftest-mechanism-profile.sh rc=0
selftest-media-agents.sh rc=0
selftest-media-dispatch.sh rc=0
selftest-methodology.sh rc=0
selftest-periodic-review.sh rc=0
selftest-plan-dispatch.sh rc=0
selftest-plan-tier.sh rc=0
selftest-reflect-verify.sh rc=0
selftest-registry.sh rc=0
selftest-reliability-institution.sh rc=0
selftest-report-reviewability.sh rc=0
selftest-requirement-coverage.sh rc=0
selftest-requirement-grading.sh rc=0
selftest-rescue-chain.sh rc=0
selftest-research-first.sh rc=0
selftest-review-library.sh rc=0
selftest-root-resolution.sh rc=0
selftest-rule23-conflict-scan.sh rc=0
selftest-rule-reserve.sh rc=0
selftest-self-resolution.sh rc=1
selftest-shared-tracker.sh rc=0
selftest-skill-collab.sh rc=0
selftest-skill-modify.sh rc=0
selftest-skill-split.sh rc=1
selftest-smart-merge.sh rc=0
selftest-split-pattern-library.sh rc=0
selftest-subagent-granularity-skill-escort.sh rc=0
selftest-sync-index.sh rc=0
selftest-task-boundary.sh rc=0
selftest-template-lifecycle.sh rc=0
selftest-template-sense.sh rc=0
selftest-tier-b.sh rc=0
selftest-tool-selection.sh rc=0
selftest-user-instruction-priority.sh rc=0
selftest-vc-gate.sh rc=0
selftest-veto.sh rc=0
selftest-workflow-orchestration.sh rc=0
```

## 二、逐脚本 Total 行（63 个标准 Total + 2 个非标准格式）

```
selftest-active-plan.sh: Total: 29 PASS=29 FAIL=0
selftest-agent-coverage.sh: Total: 9 PASS=9 FAIL=0 SKIPPED=0
selftest-ask-default-timeout.sh: Total: 11 PASS=11 FAIL=0
selftest-batch-pilot.sh: Total: 10 PASS=10 FAIL=0
selftest-capability-persistence.sh: Total: 20 PASS=20 FAIL=0
selftest-check-conflicts.sh: Total: 7 PASS=7 FAIL=0
selftest-check-drift.sh: Total: 6 PASS=6 FAIL=0
selftest-conclusion-discipline.sh: Total: 24 PASS=24 FAIL=0
selftest-context-hygiene.sh: Total: 12 PASS=12 FAIL=0
selftest-delegation.sh: Total: 38    PASS=38  FAIL=0
selftest-dispatch-grain.sh: Total: 10 PASS=10 FAIL=0
selftest-dispatch.sh: Total: 31 PASS=31 FAIL=0
selftest-drift-check-subagent.sh: Total: 20 PASS=20 FAIL=0
selftest-drift-enforcement.sh: Total: 23 PASS=23 FAIL=0
selftest-error-loop.sh: Total: 16 PASS=16 FAIL=0
selftest-evidence-goal-gate.sh: Total: 21 PASS=21 FAIL=0
selftest-execution-honesty.sh: Total: 14 PASS=14 FAIL=0
selftest-execution-stability.sh: Total: 19  PASS=19  FAIL=0
selftest-fallback.sh: Total: 31  PASS=31  FAIL=0
selftest-final-gate-hash.sh: [非标准] ==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====
selftest-fine-grain-steps.sh: Total: 11 PASS=11 FAIL=0
selftest-four-file-dataflow.sh: Total: 18 PASS=18 FAIL=0
selftest-goal-unit-goal-mode.sh: Total: 9 PASS=7 FAIL=2
selftest-interaction.sh: Total: 11 PASS=11 FAIL=0
selftest-iteration-persistence.sh: Total: 18 PASS=18 FAIL=0
selftest-iterative-optimizer.sh: Total: 8 PASS=8 FAIL=0
selftest-knowledge-brief.sh: Total: 16  PASS=16  FAIL=0
selftest-lane-advancement.sh: Total: 14 PASS=14 FAIL=0
selftest-mechanism-profile.sh: Total: 19 PASS=19 FAIL=0
selftest-media-agents.sh: Total: 10 PASS=10 FAIL=0
selftest-media-dispatch.sh: Total: 9 PASS=9 FAIL=0
selftest-methodology.sh: Total: 16 PASS=16 FAIL=0
selftest-periodic-review.sh: Total: 10 PASS=10 FAIL=0
selftest-plan-dispatch.sh: Total: 12 PASS=12 FAIL=0
selftest-plan-tier.sh: Total: 32 PASS=32 FAIL=0
selftest-reflect-verify.sh: Total: 12 PASS=12 FAIL=0
selftest-registry.sh: Total: 5 PASS=5 FAIL=0 (registry rows=65, actual selftest=65)
selftest-reliability-institution.sh: Total: 16 PASS=16 FAIL=0
selftest-report-reviewability.sh: Total: PASS=13 FAIL=0 WARN=0
selftest-requirement-coverage.sh: Total: 23 PASS=23 FAIL=0
selftest-requirement-grading.sh: Total: 7 PASS=7 FAIL=0
selftest-rescue-chain.sh: Total: 11 PASS=11 FAIL=0
selftest-research-first.sh: Total: 12 PASS=12 FAIL=0
selftest-review-library.sh: Total: 15 PASS=15 FAIL=0
selftest-root-resolution.sh: Total: 17 PASS=17 FAIL=0
selftest-rule23-conflict-scan.sh: Total: 3 PASS=3 FAIL=0
selftest-rule-reserve.sh: Total: 10 PASS=10 FAIL=0
selftest-self-resolution.sh: Total: 13 PASS=12 FAIL=1
selftest-shared-tracker.sh: Total: 11 PASS=11 FAIL=0
selftest-skill-collab.sh: Total: 25  PASS=25  FAIL=0
selftest-skill-modify.sh: Total: 9 PASS=9 FAIL=0 (SKIP=0)
selftest-skill-split.sh: Total: 41  PASS=40  FAIL=1
selftest-smart-merge.sh: Total: 17 PASS=17 FAIL=0
selftest-split-pattern-library.sh: Total: 13 PASS=13 FAIL=0
selftest-subagent-granularity-skill-escort.sh: Total: 23 PASS=23 FAIL=0
selftest-sync-index.sh: Total: 13 PASS=13 FAIL=0
selftest-task-boundary.sh: Total: 11 PASS=11 FAIL=0
selftest-template-lifecycle.sh: Total: 24 PASS=24 FAIL=0
selftest-template-sense.sh: Total: 8 PASS=8 FAIL=0
selftest-tier-b.sh: Total: 18 PASS=18 FAIL=0
selftest-tool-selection.sh: Total: 12 PASS=12 FAIL=0
selftest-user-instruction-priority.sh: [非标准] === ALL PASS ===（7 个 ✓ 检查行）
selftest-vc-gate.sh: Total: 11 PASS=11 FAIL=0
selftest-veto.sh: Total: 13 PASS=13 FAIL=0
selftest-workflow-orchestration.sh: Total: 16 PASS=16 FAIL=0
```

## 三、ΣFAIL 汇总行

`S16-SUMMARY: total=65 rc0=62 rc1=3 assertFAIL_sum=4`（goal-unit-goal-mode FAIL=2 + self-resolution FAIL=1 + skill-split FAIL=1）

## 四、FAIL 清单（脚本名 + FAIL 断言行原文）

1. **selftest-goal-unit-goal-mode.sh rc=1**（Total: 9 PASS=7 FAIL=2）
   - `G-07 FAIL selftest-registry.tsv 末行=selftest-report-reviewability.sh	Rule 70 用户呈报可审批性纪律守护 RRV-01..13（task-v155）	Rule 70 四要素条文锚(70.1-70.6)/SKILL 接线锚≥4+合规清单 C46/13 触点文件 Rule 70 引用/registry 自登记/config 零新键/report-lint 段锚	references/critical-rules.md;SKILL.md;reference.md;references/worktree-isolation.md;references/batch-quality-gate.md;templates/task_plan.md;templates/batch_report.md;templates/variant/image-type.md;templates/variant/multiview-ref-type.md;review-library/general-review/SKILL.md;review-library/alignment-review/SKILL.md;review-library/code-quality-review/SKILL.md;companion/agents/article-batch-publisher.md;companion/agents/article-field-fixer.md;companion/agents/plan-writer.md;scripts/check-complete.sh;config.json（应含 selftest-goal-unit-goal-mode.sh）`
   - `G-09 FAIL SKILL.md 行数=518 >515（超限）`
2. **selftest-self-resolution.sh rc=1**（Total: 13 PASS=12 FAIL=1）— **prompt 已预知，如实记录不修复**
   - `SR-01 FAIL critical-rules.md 六子条锚 7（应 6）`（根因：Rule 70.5 首行「41.5…」被 `^41\.` 计数 7>6 误计）
3. **selftest-skill-split.sh rc=1**（Total: 41  PASS=40  FAIL=1）
   - `[FAIL] T-主 行数 ≤515（task-v125 S3 净 +7（六族路由行插表尾 + Rule 52 摘要 bullet + 模板行尾联动；454→461）; task-v130 并行创作组节 +14（461→475）; task-v131 并行创作组回填 475 + Rule 53 六锚 477（475→477）; task-v133 C37 合规行 +1（477→478）; task-v136 S2 联动净增 +2（478→480）; task-v138 合并级联 Rule 54+55 并集净 +1（480→481，钉上调 480→490）; task-v144 合并级联 58/59/62 落地+C43/2.5/bullet 净 +11（481→492，钉上调 490→500）; task-v150 S10 合并级联 Rule 21.6 接线净 +4（498→502，钉上调 500→510）; task-v151 S4 合并级联 Rule 66 摘要+C45 净 +2（509→511，钉上调 510→515）;演进 440→442→444→447→449→452→454→461→475→477→478→480→481→492→502→511，先例 v112/v122/v126/v127/v125/v131/v133/v136/v138/v144/v150/v151）且 ≤558 上限`
   - 断言实现：`bash -c "[ \"\$(wc -l < '$SKILL')\" -le 515 ] && [ \"\$(wc -l < '$SKILL')\" -le 558 ]"`（selftest-skill-split.sh:47）；实测 `wc -l SKILL.md`=518

## 五、归因与假阳性甄别（只记录，未做任何修复）

- **G-09 与 T-主 同根因**：`wc -l /mnt/.../skills/task-planner/SKILL.md`=518 >515。v155 追加 Rule 70 摘要行 + C46 合规行等接线（S1-S3）后使 515 钉超限；两脚本钉值均为 515，需 Phase 7 后续单元统一处置（改钉或收敛行数）。
- **G-07 归因**：`selftest-registry.tsv` 末行现为 v155 新增的 `selftest-report-reviewability.sh` 登记行（S15 追加），把 v154 时代的「末行=selftest-goal-unit-goal-mode.sh」断言顶掉；goal-unit 登记行仍在（文件第 65 数据行），仅非末行。
- **假阳性甄别**（rc=0 日志中 "FAIL" 字样逐条核验，均为惰性文本，非真失败）：
  - selftest-iteration-persistence.sh:8 `IP-08 PASS critical-rules.md 四要素锚 轮次编号=2 / 测试命令=1 / PASS-FAIL=3 / 关键输出摘要=1（各 ≥1）`（"PASS-FAIL" 为断言文字）
  - selftest-rule-reserve.sh:10 `RR-10 PASS 负向自检: 缺锚副本使 RR-03 同款判定 FAIL（有牙齿实测...）`（负向自检描述）
- **两非标准格式脚本均 rc=0 且无 FAIL**：final-gate-hash（PASS=22 FAIL=0）、user-instruction-priority（ALL PASS，7 ✓）。

## 「最终结论」段（8 字段块，同返回格式）

```
status: done
acceptance: 62/65 pass — 逐脚本 rc 原文行：
selftest-active-plan.sh rc=0
selftest-agent-coverage.sh rc=0
selftest-ask-default-timeout.sh rc=0
selftest-batch-pilot.sh rc=0
selftest-capability-persistence.sh rc=0
selftest-check-conflicts.sh rc=0
selftest-check-drift.sh rc=0
selftest-conclusion-discipline.sh rc=0
selftest-context-hygiene.sh rc=0
selftest-delegation.sh rc=0
selftest-dispatch-grain.sh rc=0
selftest-dispatch.sh rc=0
selftest-drift-check-subagent.sh rc=0
selftest-drift-enforcement.sh rc=0
selftest-error-loop.sh rc=0
selftest-evidence-goal-gate.sh rc=0
selftest-execution-honesty.sh rc=0
selftest-execution-stability.sh rc=0
selftest-fallback.sh rc=0
selftest-final-gate-hash.sh rc=0
selftest-fine-grain-steps.sh rc=0
selftest-four-file-dataflow.sh rc=0
selftest-goal-unit-goal-mode.sh rc=1
selftest-interaction.sh rc=0
selftest-iteration-persistence.sh rc=0
selftest-iterative-optimizer.sh rc=0
selftest-knowledge-brief.sh rc=0
selftest-lane-advancement.sh rc=0
selftest-mechanism-profile.sh rc=0
selftest-media-agents.sh rc=0
selftest-media-dispatch.sh rc=0
selftest-methodology.sh rc=0
selftest-periodic-review.sh rc=0
selftest-plan-dispatch.sh rc=0
selftest-plan-tier.sh rc=0
selftest-reflect-verify.sh rc=0
selftest-registry.sh rc=0
selftest-reliability-institution.sh rc=0
selftest-report-reviewability.sh rc=0
selftest-requirement-coverage.sh rc=0
selftest-requirement-grading.sh rc=0
selftest-rescue-chain.sh rc=0
selftest-research-first.sh rc=0
selftest-review-library.sh rc=0
selftest-root-resolution.sh rc=0
selftest-rule23-conflict-scan.sh rc=0
selftest-rule-reserve.sh rc=0
selftest-self-resolution.sh rc=1
selftest-shared-tracker.sh rc=0
selftest-skill-collab.sh rc=0
selftest-skill-modify.sh rc=0
selftest-skill-split.sh rc=1
selftest-smart-merge.sh rc=0
selftest-split-pattern-library.sh rc=0
selftest-subagent-granularity-skill-escort.sh rc=0
selftest-sync-index.sh rc=0
selftest-task-boundary.sh rc=0
selftest-template-lifecycle.sh rc=0
selftest-template-sense.sh rc=0
selftest-tier-b.sh rc=0
selftest-tool-selection.sh rc=0
selftest-user-instruction-priority.sh rc=0
selftest-vc-gate.sh rc=0
selftest-veto.sh rc=0
selftest-workflow-orchestration.sh rc=0
ΣFAIL 汇总行: S16-SUMMARY: total=65 rc0=62 rc1=3 assertFAIL_sum=4（goal-unit-goal-mode: G-07+G-09；self-resolution: SR-01 预知；skill-split: T-主）
files: /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/subagent-state/16-code-runner.md (new) | /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/findings.md (+3) | /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/progress.md (+4)
evidence: for f in selftest-*.sh; do timeout 120 bash "$f" >"/tmp/rrv-$f.log" 2>&1; echo "$f rc=$?"; done → 65 行 rc 清单（62×rc=0 / 3×rc=1）；grep -E "FAIL" 各日志 → 仅 goal-unit-goal-mode(3=Total+G-07+G-09)/self-resolution(2=Total+SR-01)/skill-split(2=Total+T-主) 含真 FAIL 断言，其余 62 日志 FAIL 字样均为 Total 行 "FAIL=0"（含 2 个惰性文本已甄别）；wc -l SKILL.md=518 → G-09/T-主 同根因；git status --short → 空（worktree 干净）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/subagent-state/16-code-runner.md (status: done)
findings_written: findings.md#Research Findings → #### [sub:16-code-runner] 全量 selftest 回归（S16 机械单元）
blockers: none
confidence: HIGH
```
