# 10-runner-S7 — Phase 4 S7 全量回归跑批与基线对比（task-v156-drift-shield）

- 时间采样: 2026-10-10 16:03（跑批 cwd=/mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment 根）
- 被测版本: worktree HEAD=f6bf03e（wt/v156-decision-alignment；基线 a538a3a + v156 五 commits 917ff95/759f8cb/e91b6cc/68c446d/f6bf03e）
- 范围: 只读跑批+对比（worktree git status --porcelain 前后均空；无 git 写操作；未改任何源文件）
- 唯一写入: 主仓 plans/task-v156-drift-shield/regression-v156.log（契约允许）
- 写契约执行: findings.md 追加 `#### [sub:10-runner]`；progress.md 原无 Phase 4 段 → 依契约「禁创建 Phase 4 段头之外的结构」仅创建 Phase 4 段头+Status/Started/Actions taken 并追加 1 行四要素 Round 记录（Rule 57.2），未动其他段

## 逐项原文证据（禁自报汇总 — 命令 → 输出原文行）

[1] 跑批与 Σ 聚合（72 脚本）
  命令: `for f in skills/task-planner/scripts/selftest-*.sh; do out=$(timeout 180 bash "$f" 2>&1); rc=$?; total_line=$(printf "%s\n" "$out" | grep -E "^Total:" | tail -1); printf "%s rc=%s | %s\n" "$f" "$rc" "$total_line" >> /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/regression-v156.log; done`
  产物: `wc -l regression-v156.log` = 72 行（基线 71 行）；72/72 行均带 Total 行，无 timeout/无缺行
  Σ awk 逐行求和: 基线 `scripts=71 PASS=1039 FAIL=0` / 回归 `scripts=72 PASS=1056 FAIL=5`（自洽核: 1039+22 新脚本−5 失败=1056）

[2] 新脚本（rc=0 ✓）: `skills/task-planner/scripts/selftest-decision-drift.sh rc=0 | Total: 22 PASS=22 FAIL=0`

[3] rc 非零 5 条（原文，全部为基线 rc=0 的既有脚本反转）:
  skills/task-planner/scripts/selftest-drift-check-subagent.sh rc=1 | Total: 20 PASS=19 FAIL=1
  skills/task-planner/scripts/selftest-parallel-scheduling.sh rc=1 | Total: 9 PASS=8 FAIL=1
  skills/task-planner/scripts/selftest-reliability-institution.sh rc=1 | Total: 16 PASS=15 FAIL=1
  skills/task-planner/scripts/selftest-research-first.sh rc=1 | Total: 12 PASS=11 FAIL=1
  skills/task-planner/scripts/selftest-root-resolution.sh rc=1 | Total: 17 PASS=16 FAIL=1

[4] 基线同 5 行原文（baseline-selftest.log，全 `rc=0 | … FAIL=0`）:
  skills/task-planner/scripts/selftest-drift-check-subagent.sh rc=0 | Total: 20 PASS=20 FAIL=0
  skills/task-planner/scripts/selftest-parallel-scheduling.sh rc=0 | Total: 9 PASS=9 FAIL=0
  skills/task-planner/scripts/selftest-reliability-institution.sh rc=0 | Total: 16 PASS=16 FAIL=0
  skills/task-planner/scripts/selftest-research-first.sh rc=0 | Total: 12 PASS=12 FAIL=0
  skills/task-planner/scripts/selftest-root-resolution.sh rc=0 | Total: 17 PASS=17 FAIL=0

[5] 5 条 FAIL 原文（worktree 根独立复跑 5/5 复现 rc=1）:
  DCS-11 FAIL DCS-11 条件缺失
  P-05 FAIL SKILL.md C46=1（应 =1）/ Rule 68 引用=2（应 ≥1）/ 上界 skill=71 vs critical=73（应相等）
  R-09 FAIL SKILL.md 括注锚漂移（含 Rule 40-[567][0-9] 全集=0 应 ≥1 / 1-40=0 应 0）
  RF-07 FAIL RF-07 SKILL 双锚(bullet 全角括号+头注 1-71 全集) (got=(1,0) expect=(>=1,>=1))
  RR-09 FAIL SKILL.md 全集 1-(5[3-9]|6[0-9]) 命中=0（应 =1）或旧 1-51 残留=0（应 =0，级联漏改）

[6] 因果对照（`git show a538a3a:skills/task-planner/SKILL.md | grep` vs HEAD 同 pattern，逐断言）:
  DCS-11  `Rule 40-(69|71) 全集`                         OLD=1 → NEW=0
  RF-07   `Critical Rules 1-71（含 Rule 40-(65|69|71) 全集` OLD=1 → NEW=0
  R-09    `含 Rule 40-[567][0-9] 全集`                     OLD=1 → NEW=0
  RR-09   `Critical Rules 全集 1-(5[3-9]|6[0-9])`          OLD=1 → NEW=0（OLD 原文: `rules.md: Critical Rules 全集 1-69+70（67-70 均经`）
  P-05    skill_max/crit_max                              OLD 71==71 → NEW 71 vs 73（S1 新增 Rule 73 → crit_max=73）
  NEW 破坏源原文: SKILL.md:9 `Critical Rules 全集 1-71+73（67-71+73 均经并行任务合流落地）` / :300 `Critical Rules 1-71+73（含 Rule 40-71+73 全集，…`

[7] properties 复核: `jq -r '.properties|length' skills/task-planner/config.json` = 42（jq_rc=0）

## 最终结论（8 字段块）

status: done
acceptance: 2/3 pass — [1:PASS 2:FAIL 3:PASS]
files: /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/regression-v156.log(+72 new); /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/subagent-state/10-runner-S7.md(new); /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/findings.md(+1 小节); /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/progress.md(+Phase 4 段头+1 Round 行)
evidence: 一跑批 Σ awk 逐行: 基线 `71 PASS=1039 FAIL=0` → 回归 `72 PASS=1056 FAIL=5`（1039+22−5=1056 自洽）; 一rc 非零 5 条全文: `selftest-drift-check-subagent.sh rc=1 | Total: 20 PASS=19 FAIL=1` / `selftest-parallel-scheduling.sh rc=1 | Total: 9 PASS=8 FAIL=1` / `selftest-reliability-institution.sh rc=1 | Total: 16 PASS=15 FAIL=1` / `selftest-research-first.sh rc=1 | Total: 12 PASS=11 FAIL=1` / `selftest-root-resolution.sh rc=1 | Total: 17 PASS=16 FAIL=1`（基线对应 5 行全 rc=0）; 一因果: a538a3a→HEAD 同 pattern grep 5 断言全 1→0 + P-05 71 vs 73（破坏源=SKILL.md `1-71+73`/`40-71+73 全集` 的 +73 插入）; 一新脚本 `selftest-decision-drift.sh rc=0 | Total: 22 PASS=22 FAIL=0`; 一jq `.properties|length`=42
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/subagent-state/10-runner-S7.md (status: done)
findings_written: #### [sub:10-runner] (findings.md)
blockers: 回归不通过——5 个既有 selftest 因 SKILL.md 计数锚「1-71+73」/「40-71+73 全集」破坏既有宽容锚断言 rc=1（ΣFAIL=5 非零新增）；修复方向=级联更新 5 脚本宽容锚（或调整 SKILL 行文），修复后需重跑本 S7
confidence: HIGH
