# subagent-state 15-executor | task-v131 P4 S2（单 S-unit）
# 时间 2026-10-05 | worktree /home/terry/task-planner-skill-worktrees/task-v131
# 范围：只动 skills/task-planner/scripts/selftest-skill-split.sh

## Step 1 全锚扫描结果（改前全扫，锚级联第 3 次教训——只记录未改文件）

### 1a. `grep -rn "≤475\|<=475\|475" skills/task-planner/scripts/*.sh | grep -v selftest-root-resolution`
命中 2 处：
1. **主锚（本任务 S-unit 目标）** `selftest-skill-split.sh:41` T-主 行数断言 `≤475`（含 label 演进链 440→...→475，先例 v112/v122/v126/v127/v125）——断言体两处：`-le 475`（硬阈值）与 label 文字。
2. `selftest-active-plan.sh:153`：`created_epoch: 1789475721144` ——epoch 毫秒数字串内含 "475" 子串，**非行数锚，排除**（级联误报防护，不改动）。

### 1b. `grep -rn "Rules 1-5\|1-51\|1-52" skills/task-planner/scripts/*.sh`
命中全集数锚分布：
- `selftest-root-resolution.sh:7,12,98,99,101,103,105,107` — RR-09 全集 1-53 演进锁（负断言 1-51 残留=0），属 task-v131 并行 S1 产出，本任务禁触碰。
- `selftest-conclusion-discipline.sh:71` — 宽容锚「1-3[5-9]」+「1-4[5-9]|1-5[0-9]」（正则窗含 1-53，无需改）。
- `selftest-plan-tier.sh:78,79` — 宽容锚 1-4[5-9]|1-5[0-9]（正则窗已覆盖 1-53，无需改）。
- `selftest-agent-coverage.sh:163` / `selftest-requirement-coverage.sh:27,159,161` — Rule 51/52/53 子条锚（非全集数锚，与行数无关，无需改）。

### 1c. 旁证（越界观察，仅记录不处理）
`selftest-requirement-coverage.sh` RC-15 负断言 `grep -c '^53\.'` =0（task-v125 防编号冲突锁，见 166 行注释）。task-v131 已合法落地 Rule 53（critical-rules.md 现含 53 子条）→ 该负断言在后续全量跑批时预期 FAIL，需后续 S-unit/任务负责重锚 `^53\.`→`^54\.`（v125 S5 先例：'^52.'→'^53.'）。**不在本 S-unit 范围**（任务明令只动 selftest-skill-split.sh），列入 issues 上报。

## 扫描结论
- 本 S-unit 唯一需改锚：selftest-skill-split.sh:41（label + 断言 `-le 475` → `-le 477`）。
- SKILL.md 现值 477 行（wc -l 实测），演进 = 回填 475 + Phase3 净增 2（Rule 53 摘要 bullet + 合规清单 C36 行等）。
- worktree git status：`M selftest-registry.tsv`（并行 S1 已改，非本 S-unit）+ `?? selftest-root-resolution.sh`（S1 新文件，禁触碰）。本 S-unit 落盘后新增 `M selftest-skill-split.sh` 一行，不 commit。

## Step 2 落盘
selftest-skill-split.sh:41 三处 Edit（label ≤475→≤477 / 演进链插入「task-v131 并行创作组回填 475 + Rule 53 六锚 477（475→477）」+ 演进 440→...→475→477 + 先例追加 v131 / 断言体 `-le 475`→`-le 477`）。

## Step 3 验证
- `bash skills/task-planner/scripts/selftest-skill-split.sh`（worktree 相对路径 skills/task-planner/scripts/）：
  - 用例原文：`[PASS] T-主 行数 ≤477（...; task-v131 并行创作组回填 475 + Rule 53 六锚 477（475→477）;演进 440→442→444→447→449→452→454→461→475→477，先例 v112/v122/v126/v127/v125/v131）且 ≤558 上限`
  - **Total: 41  PASS=41  FAIL=0，exit=0**
- `wc -l skills/task-planner/SKILL.md` = **477**
- `git status --short`（不 commit）：`M selftest-registry.tsv`（S1）/ `M selftest-skill-split.sh`（本 S-unit）/ `?? selftest-root-resolution.sh`（S1）

## Step 4 终态
- 本 S-unit 完成，检查点已落盘，未 commit。
- 遗留上报（越界观察）：selftest-requirement-coverage.sh RC-15 负断言 `^53\.`=0 在 Rule 53 落地后预期 FAIL，需后续任务重锚 →`^54\.`（先例 v125 S5）。
