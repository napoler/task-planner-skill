# 15-merge — Phase 8 执行体 checkpoint（executor/sonnet-1）

- **status: done**
- worktree: `/home/terry/task-planner-skill-worktrees/v162-change-absorption-safety`
- 分支: `wt/v162-change-absorption-safety`（base=master b6d1594）
- 任务: worktree 内 `git merge master` 的并集解 → 提交 → 重跑全量 selftest → 重跑 smart-merge-back

## 关键发现（偏离派发单的实况）
派发单称「9 个冲突文件」，实测 **11 个 UU**：9 个 selftest + `skills/task-planner/SKILL.md` + `skills/task-planner/references/critical-rules.md`。
后两者为派发单未列出的额外冲突，已一并并集解（否则 merge 无法完成）。

## 冲突解决对照表（11 文件，逐 hunk 并集解）

| # | 文件 | hunk | 解决 | 依据 |
|---|------|------|------|------|
| 1 | scripts/selftest-context-pressure.sh | 1（L100-108） | 保留双方注释（v160 合并级联 + v162 演进），代码取 HEAD `1-(69\|71\|74)` | 代码=最终态 1-74 |
| 2 | scripts/selftest-lane-advancement.sh | 1（L134-149） | 保留 HEAD v154 演进 + master v160 新纪元注释 + v162 注释；代码取 HEAD `grep -c 'Critical Rules 1-74'` | 代码=最终态 1-74 |
| 3 | scripts/selftest-registry.tsv | 1（L74-78） | 并集保留双方登记行（selftest-absorption-discipline.sh + selftest-subagent-return.sh） | registry 并集 |
| 4 | scripts/selftest-requirement-coverage.sh | 1（L130-149） | 保留 HEAD v154 + master v160 注释 + v162；代码取 HEAD `1-74` | 代码=最终态 1-74 |
| 5 | scripts/selftest-research-first.sh | 1（L75-81，2 行） | RF-06 代码同（取 HEAD），注释并集；RF-07 代码取 HEAD `Critical Rules 1-74（含 Rule 40-(65\|69\|71\|74) 全集`，注释并集 | 代码=最终态 1-74 |
| 6 | scripts/selftest-root-resolution.sh | 1（L109-123） | 保留 HEAD「现状=1-62」+ master v160 注记 + v162 注记；代码取 HEAD `1-(5[3-9]\|6[0-9]\|7[0-4])` | 代码=最终态 1-74 |
| 7 | scripts/selftest-self-resolution.sh | 1（L80-93） | 保留 HEAD v154 + master v160 S14d 注记 + v162；代码取 HEAD `Critical Rules 1-74` | 代码=最终态 1-74 |
| 8 | scripts/selftest-source-anchor-discipline.sh | 1（L38-44） | 取 HEAD SA-07（`1-74` 计数 ≥2） | 代码=最终态 1-74 |
| 9 | scripts/selftest-tool-selection.sh | 1（L63-76） | 保留 HEAD v154 + master v160 注记 + v162；代码取 HEAD `Critical Rules 1-74` | 代码=最终态 1-74 |
| 10 | SKILL.md | 5（L9-13 / L177-181 / L242-246 / L311-315 / L403-407） | 见下 | 并集 + 易位 |
| 11 | references/critical-rules.md | 1（L947-984） | HEAD 71.7（计数 1-74）+ master Rule 72 段（72.1-72.6）+ HEAD Rule 74 段（74.1-74.6） | 并集保留双规则 |

### SKILL.md 5 hunk 细节
1. **L9-13 frontmatter**：并集 = `Critical Rules 全集 1-74（67-72/74 均经并行任务合流落地；73 为编号预占空号…）`，条款枚举补入 `Rule 72 决策分级与用户打断纪律`（同时保留 Rule 71/74）。
2. **L177-181 终验段**：并集保留两行（Rule 74 吸收三判 + Rule 72 决策分级）。
3. **L242-246 合规清单**：C51=Rule 74（v162 本任务，HEAD）+ **新增 C52=Rule 72**（v160 master 行易位）。依据：`selftest-decision-grading.sh` DG-04 用**内容锚** `^| C[0-9]* | .*决策分级与用户打断`（编号让位不级联，DG-04 注释明示「编号是并集易位资源」），`selftest-absorption-discipline.sh` AD-04 检 `| C51 |` 字面 → 两测均 PASS。
4. **L311-315 「详见」行**：并集 = `Critical Rules 1-74（含 Rule 40-74 全集 … Rule 71 … / Rule 72 决策分级与用户打断纪律 / Rule 74 变更吸收三判纪律）`。
5. **L403-407 References 表**：并集 = `Critical Rules 1-74（… / Rule 70 …（task-v155）/ Rule 72 …（task-v160）/ Rule 74 …）`。

### 并集解统一原则（写入注释留痕）
- **注释行**（`# [date task-xxx …]` 形态）：保留双方演进注记，按时间序（v154 → v160 → v162）。
- **代码断言行**：取最终态 **1-74**（HEAD 本任务改动）。
- **superseded 决策注记**（master 侧 `# … 取 v160 宽容锚`）不保留：与最终态代码（1-74 字面锚）矛盾，保留即违反 Rule 71「禁虚假陈述」；其信息已由 v162 演进注记承载。
- 同一事件的双方注释（v154 的 `→1-71` vs `→1-69`）取与最终链一致者（HEAD `→1-71`），避免同事件双结论。

## 证据链
- 冲突标记清零：`grep -rn '^<<<<<<<\|^>>>>>>>' skills/` → 空；`git diff --name-only --diff-filter=U` → 空。
- 提交：`3b92369 merge: master(v152-154/v160-164) into wt/v162-change-absorption-safety — 并集解 11 冲突文件（9 selftest + SKILL.md + critical-rules.md）`；`MERGE COMPLETE`。
- **ΣFAIL=0（worktree，提交后复跑）**：74/74 selftest 脚本 FAIL=0；`selftest-user-instruction-priority.sh` 输出 `=== ALL PASS ===` exit=0（无 FAIL= token，人工核验）。
- **ΣFAIL=0（合并后 master 复跑）**：74 脚本，nonzero-fail=0，unparsed=none。
- **smart-merge-back 成功**：
  ```
  [V1] OK: worktree 在册 … base=master
  [V2] OK: worktree 干净
  [V3] OK: 主仓无 scope 重叠(merge-base b6d1594…)
  [V5] OK: master 未前进(HEAD == merge-base)
  [V6] MERGED: d45e8e287f59cd3e1b6185264d85123117c60eed
  [CLEANUP] 由主进程择机执行: git worktree remove … && git branch -d wt/v162-change-absorption-safety
  ```
- 合并后 master 核验：`d45e8e2 Merge branch 'wt/v162-change-absorption-safety'`；C51=Rule74 / C52=Rule72；critical-rules.md 含 71/74/Rule72 三段；SKILL.md `1-74` 计数=3；无冲突标记。

## 未决 / 交主进程
- **[CLEANUP] 未执行**：worktree + `wt/v162-change-absorption-safety` 分支仍在册（smart-merge-back 提示「由主进程择机执行」）。按 §11.4 不越权清理其他并行会话资源，留待主进程执行 `git worktree remove` + `git branch -d`。
- 派发单「9 冲突」与实际「11 冲突」的差异已如实记录（上表 #10/#11）。
- 说明：本任务约束「禁 rebase 强推」→ 全程 `merge --no-ff`（smart-merge-back 默认），未 rebase。
