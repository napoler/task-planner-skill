# 16-executor-M-fixes — task-v156 alignment MINOR 修正（M1 + M3）

- **执行体**：task-v156 执行体（alignment MINOR 修正单元）
- **worktree**：`/mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment`，基线 HEAD=`a2bd2ba`
- **需求锚（51.1a）**：R5「歧义表述后带解释层，为犯错堵住漏洞」——消息文案=执行体解释层，滞后即歧义源
- **来源发现**：`plans/task-v156-drift-shield/subagent-state/15-alignment-review.md` M1/M3 段
- **K9 规格**：`design-draft.md` §6 K9 行（5 存量 selftest 正则已加 `(\+[0-9]+)?` 族，本单元只对齐消息文案+补注释，禁改正则）

## 改动明细（worktree 内，仅 6 目标文件，正则/负断言零改动）

1. `skills/task-planner/scripts/selftest-registry.tsv:73` — description 列「（静态 DD-01~22；task-v156）」→「（静态 DD-01~23，含 DD-14b 档位门控断言；task-v156）」
2. `skills/task-planner/scripts/selftest-drift-check-subagent.sh` — DCS-11 ok/bad 消息「40-69/40-71 全集」→「40-(69|71|73)(+N) 全集宽容锚」+ 断言行上方补 1 行演进注释
3. `skills/task-planner/scripts/selftest-reliability-institution.sh` — R-09 头部行+ok/bad「40-[567][0-9]」→「40-[4567][0-9](+N)」+ 演进注释
4. `skills/task-planner/scripts/selftest-root-resolution.sh` — RR-09 头部行+ok/bad「1-(5[3-9]|6[0-9])（现状 1-62）」→「1-[0-9]+(+N)（现状 1-71+73）」+ 演进注释
5. `skills/task-planner/scripts/selftest-parallel-scheduling.sh` — P-05 注释「Critical Rules 1-NN」→「1-NN(+N)」+ 演进注释
6. `skills/task-planner/scripts/selftest-research-first.sh` — RF-07 ok 消息「头注 1-71 全集」→「1-71(+N) 全集宽容锚」+ 演进注释

演进注释统一文案：`# [2026-10-10 task-v156 CR/M 级联] 锚随 SKILL 计数「1-71+73」插入形态宽容化:DCS-11/R-09/RF-07/RR-09/P-05 正则加 `(\+[0-9]+)?` 族（K9）,负断言保留`

## 复验证据（worktree，cwd=worktree 根）

- `grep -c 'DD-01~23' skills/task-planner/scripts/selftest-registry.tsv` → `1`
- `selftest-drift-check-subagent.sh` rc=0 → `Total: 20 PASS=20 FAIL=0`（DCS-11 PASS）
- `selftest-reliability-institution.sh` rc=0 → `Total: 16 PASS=16 FAIL=0`（R-09 PASS）
- `selftest-root-resolution.sh` rc=0 → `Total: 17 PASS=17 FAIL=0`（RR-09 PASS）
- `selftest-parallel-scheduling.sh` rc=0 → `Total: 9 PASS=9 FAIL=0`（P-05 PASS，上界 1-73=crit_max 73）
- `selftest-research-first.sh` rc=0 → `Total: 12 PASS=12 FAIL=0`（RF-07 PASS）
- `selftest-registry.sh` rc=0 → `Total: 5 PASS=5 FAIL=0 (registry rows=72, actual selftest=72)`
- `selftest-decision-drift.sh` rc=0 → `Total: 23 PASS=23 FAIL=0`
- 全量批跑：`ran=72 nonzero=0`
- `git diff --stat` → 6 文件 `+15/-10`；正则行/负断言行逐字未变（DCS-11 三条件、R-09 1-40 负断言、RR-09 m 负断言、P-05 `grep -oE`、RF-07 `cntE` 零改动）

## 最终结论

```
status: done
acceptance: 2/2 pass — [1:PASS 2:PASS]
files: /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment/skills/task-planner/scripts/selftest-registry.tsv(+1/-1); /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment/skills/task-planner/scripts/selftest-drift-check-subagent.sh(+2/-1); /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment/skills/task-planner/scripts/selftest-reliability-institution.sh(+3/-2); /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment/skills/task-planner/scripts/selftest-root-resolution.sh(+4/-3); /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment/skills/task-planner/scripts/selftest-parallel-scheduling.sh(+3/-2); /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment/skills/task-planner/scripts/selftest-research-first.sh(+2/-1)
evidence: grep -c 'DD-01~23' selftest-registry.tsv → 1; 5 selftest rc=0 Total FAIL=0 (DCS 20/20, R 16/16, RR 17/17, P 9/9, RF 12/12); selftest-registry 5/5 rows=72=actual; selftest-decision-drift 23/23; 全量 72/72 rc=0 nonzero=0; git diff --stat=6 文件 +15/-10 正则行逐字未变
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/subagent-state/16-executor-M-fixes.md (status: done)
findings_written: /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/findings.md #### [sub:16-executor] alignment MINOR 修正（M1 registry 描述 + M3 存量 selftest 消息/注释）（2026-10-10，Phase 6）
blockers: none
confidence: HIGH
```
