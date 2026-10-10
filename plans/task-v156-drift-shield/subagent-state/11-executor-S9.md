# sub:11-executor S9 — 五脚本宽容锚随动修复（K9 落地）checkpoint

status: done
acceptance: 3/3 pass — [1:PASS 2:PASS 3:PASS]
files: /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment/skills/task-planner/scripts/selftest-drift-check-subagent.sh(+1/-1); /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment/skills/task-planner/scripts/selftest-reliability-institution.sh(+1/-1); /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment/skills/task-planner/scripts/selftest-root-resolution.sh(+1/-1); /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment/skills/task-planner/scripts/selftest-parallel-scheduling.sh(+1/-1); /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment/skills/task-planner/scripts/selftest-research-first.sh(+1/-1)
evidence:
  - 命令：`cd /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment && for f in selftest-drift-check-subagent selftest-reliability-institution selftest-root-resolution selftest-parallel-scheduling selftest-research-first; do out=$(timeout 120 bash "skills/task-planner/scripts/$f.sh" 2>&1); rc=$?; printf '%s rc=%s | %s\n' "$f" "$rc" "$(printf '%s\n' "$out" | grep -E '^Total:')"; done`
    输出（修复后）：
    `selftest-drift-check-subagent rc=0 | Total: 20 PASS=20 FAIL=0`
    `selftest-reliability-institution rc=0 | Total: 16 PASS=16 FAIL=0`
    `selftest-root-resolution rc=0 | Total: 17 PASS=17 FAIL=0`
    `selftest-parallel-scheduling rc=0 | Total: 9 PASS=9 FAIL=0`
    `selftest-research-first rc=0 | Total: 12 PASS=12 FAIL=0`
  - 命令（基线对照，修复前）：`... selftest-drift-check-subagent rc=1 | DCS-11 FAIL DCS-11 条件缺失 Total: 20 PASS=19 FAIL=1`；`selftest-reliability-institution rc=1 | R-09 FAIL SKILL.md 括注锚漂移（含 Rule 40-[567][0-9] 全集=0 应 ≥1 / 1-40=0 应 0） Total: 16 PASS=15 FAIL=1`；`selftest-root-resolution rc=1 | RR-09 FAIL SKILL.md 全集 1-(5[3-9]|6[0-9]) 命中=0（应 =1）或旧 1-51 残留=0（应 =0，级联漏改） Total: 17 PASS=16 FAIL=1`；`selftest-parallel-scheduling rc=1 | P-05 FAIL ... 上界 skill=71 vs critical=73（应相等） Total: 9 PASS=8 FAIL=1`；`selftest-research-first rc=1 | FAIL RF-07 SKILL 双锚(bullet 全角括号+头注 1-71 全集) (got=(1,0) expect=(>=1,>=1)) Total: 12 PASS=11 FAIL=1`
  - 全量回归：`for f in skills/task-planner/scripts/selftest-*.sh; do out=$(timeout 180 bash "$f" 2>&1); rc=$?; ...; done` → `SCRIPTS_RUN=72 NONZERO_RC=0`
  - 负断言保留（grep 核验，断言行仍在 + SKILL.md 命中=0）：root-resolution :111 `m="$(grep -cE '(全集|Rules) 1-(51|53|55)' "$SKILLMD" || true)"` 仍在，SKILL.md 命中=0；reliability :86 `b="$(grep -c '1-40' "$SKILLMD" || true)"` 仍在，SKILL.md 命中=0
  - 新锚命中实测（SKILL.md）：`Critical Rules 全集 1-[0-9]+(\+[0-9]+)?`=1；`(全集|Rules) 1-(51|53|55)`=0；`含 Rule 40-[4567][0-9](\+[0-9]+)? 全集`=1；`1-40`=0；P-05 抽数 max=73；RF-07 第二锚新 pattern=1
  - diff 核对：`git diff --numstat` = 5 文件各 `1  1`；`git status --short` = 仅 5 个 selftest 文件 M
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/subagent-state/11-executor-S9.md (status: done)
findings_written: /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/findings.md #### [sub:11-executor] S9 五脚本宽容锚随动修复（K9 落地）：1-71+73 插入形态全覆盖（2026-10-10，Phase 4）
blockers: none
confidence: HIGH

## 改动明细（5 文件各 1 行，纯 pattern 替换）
1. selftest-drift-check-subagent.sh:61 DCS-11 `Rule 40-(69|71) 全集` → `Rule 40-(69|71|73)(\+[0-9]+)? 全集`
2. selftest-reliability-institution.sh:85 R-09 `含 Rule 40-[567][0-9] 全集` → `含 Rule 40-[4567][0-9](\+[0-9]+)? 全集`
3. selftest-root-resolution.sh:110 RR-09 `Critical Rules 全集 1-(5[3-9]|6[0-9])` → `Critical Rules 全集 1-[0-9]+(\+[0-9]+)?`
4. selftest-parallel-scheduling.sh:107 P-05 `Critical Rules 1-[0-9]+` → `Critical Rules 1-[0-9]+(\+[0-9]+)?`
5. selftest-research-first.sh:76 RF-07 第二锚 `Critical Rules 1-71（含 Rule 40-(65|69|71) 全集` → `Critical Rules 1-71(\+[0-9]+)?（含 Rule 40-(65|69|71)(\+[0-9]+)? 全集`

## 负结果
- 未发现 5 脚本以外的文件被改动（git status 仅 5 selftest M）
- 未发现负断言被删除/放宽（root-resolution '1-51' 残留=0 与 reliability '1-40'=0 断言原样保留）
- 未发现全量回归（72 脚本）出现新非零 rc
- K9 中 reliability 条目的「RF-07 头注锚」父注实为 research-first RF-07 的跨文件引用；reliability 脚本内 `grep '1-71（含'` 无命中（该文件无 RF-07 锚），故 reliability 仅 R-09 一处需改
