# [sub:10-executor] 部署对账 checkpoint（task-v110 → e0527b6 三宿主 diff）
- start: 2026-10-02 | 范围: 只记录不修改 | 超时阈值 15min
- 变更面基准: git diff --stat e0527b6^..e0527b6 -- skills/ = 13 文件 73+/32-
  (critical-rules.md/SKILL.md/reference.md/completion-gate.md/methodology.md/
   subagent_dispatch.md/task_plan.md/rule-enhancement-type.md/template-guide.md/
   template-mapping.md/check-dispatch.sh/selftest-dispatch.sh/selftest-knowledge-brief.sh)
- M0: v110 变更面清单已取（git diff stat 实测 13 文件，与 prompt 焦点清单一致）
- M1: 宿主三处 task-planner 全在位；v110 变更面 13 文件三宿主 diff -q = 13/13 differ（全落后）
- M2: 探针实测——宿主 critical-rules.md:144 仍为 09-12 旧串行铁律原文（「至多 1 个活跃子代理」命中 1）；
  「子代理调度铁律」/「parallel_groups」/「并行默认允许」宿主命中全=0；主仓 e0527b6 基线=4/4/有
- M3: 三宿主互比仅 2 处 differ（companion/agents/plan-writer.md + scripts/selftest-template-lifecycle.sh），
  即三宿主基本同一旧版本快照；.zcode 宿主与主仓全树 differ=31 文件（漂移远超 v110 变更面 13，含 17 variant/README/companion）；
  .claude/.opencode 宿主 plan-template-kit 2 文件 diff 仅 15/19 行（较浅漂移），.zcode=27/77 行（较深漂移）

## 最终结论（8 字段块）
```
status: done
acceptance: 3/3 pass — 宿主1 ~/.zcode/skills=13/13 变更面落后，探针命中全 0，critical-rules.md:144 旧文在位→建议全树同步 e0527b6；宿主2 ~/.claude/skills=13/13 落后，探针全 0，.claude/skills/task-planner/references/critical-rules.md:144 旧文在位→建议全量同步；宿主3 ~/.opencode/skills=13/13 落后，探针全 0，.opencode/skills/task-planner/references/critical-rules.md:144 旧文在位→建议全量同步
files: /mnt/data/dev/task-planner-skill/plans/task-v110/findings.md(+13 行 [sub:10-executor] 段)/ /mnt/data/dev/task-planner-skill/plans/task-v110/progress.md(+1 行 [sub:10])/ /mnt/data/dev/task-planner-skill/plans/task-v110/subagent-state/10-executor.md(新建)
evidence: git diff --stat e0527b6^..e0527b6 -- skills/ → "13 files changed, 73 insertions(+), 32 deletions(-)"; diff -q 宿主三处 13 文件全 "differ"; grep -rl 'parallel_groups' 三宿主 task-planner → 0 命中（主仓基线=4）; .zcode/skills/task-planner/references/critical-rules.md:144 命中「至多 1 个活跃子代理」（09-12 原文）; diff -rq 主仓 vs .zcode → 31 differ（全树积压）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v110/subagent-state/10-executor.md (status: done)
findings_written: #### [sub:10-executor] 部署对账
blockers: none
confidence: HIGH
```
- 约束遵守: 三宿主零修改（只读 grep/diff）; 零 git 写操作; 计划三文件仅契约内追加
