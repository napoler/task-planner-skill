# Fix-B2 检查点 — 行数钉值上调 515→526（G-09 / T-main）

- 时间: 2026-10-10 (task-v154 S8 回归修复第三批；串行槽 executor)
- 单元: Fix-B2（A: selftest-goal-unit-goal-mode.sh G-09；B: selftest-skill-split.sh T-main）
- 工作树: /mnt/data/dev/task-planner-skill-worktrees/v154-decision-arbiter (branch wt/v154-decision-arbiter, HEAD=3322259)
- 状态: done — 两脚本断言层全 PASS（G-09/T-main 转 PASS），G-07 预期残留（registry 末行，下单元 Fix-B3 修）

## 基线（编辑前）
- SKILL.md 实际 521 行（`wc -l`）
- selftest-goal-unit-goal-mode.sh: G-09 钉 515 → `FAIL ... 521 >515（超限）` / `Total: 9 PASS=7 FAIL=2`
- selftest-skill-split.sh: T-main 钉 515 → `[FAIL] T-主 行数 ≤515...` / `Total: 41 PASS=40 FAIL=1`

## 本单元改动
### A. skills/task-planner/scripts/selftest-goal-unit-goal-mode.sh（diff --stat 10 行 5 增 5 删）
- line 23 头注: `G-09 SKILL.md 行数 ≤515（D1 上调后上限，留 4 行余量）` → `≤526（D2 上调后上限，留 5 行余量）`
- line 120 上行注释: `≤515（D1 上调后上限）` → `≤526（D2 上调后上限）`
- line 121 What: `不超过 515 行` → `不超过 526 行`
- line 122 Why（改写演进史）: `Rule 69 路由表行+摘要 bullet+触发点标记 T1-T6 六行+C46 合规行+外部引用行 → 实际 521 行（515→521），钉值上调 515→526（留 5 行余量；v150/v151 判例：留缓冲）`
- line 124 断言: `-le 515` → `-le 526`；ok 文案 `≤515（D1 上调后上限）` → `≤526（D2 上调后上限）`；bad 文案 `>515（超限）` → `>526（超限）`
- 注: ok/bad 文案的决策标签 `D1` 一并改 `D2`（与 line 120/23 注释标签保持一致；任务书对 ok/bad 仅点名数字，此为一致性补正）

### B. skills/task-planner/scripts/selftest-skill-split.sh（diff --stat 3 行 2 增 1 删）
- line 47 新增演进史注释行（对齐既有格式）: `# [2026-10-10 task-v154 S5 接线级联] Rule 69 路由行+清单行+C46+T1-T6 六标记+外部引用行（1 改行）→ SKILL.md 实际 521 行（515→521），钉随内容演进同步上调 515→526（≤558 总上限不动；v151 上调 510→515 同款判例）`
- T-main 说明串: `T-主 行数 ≤515` → `≤526`；串内 v151 尾串后追加 `; task-v154 接线级联净 +11-1 改（515→521，钉上调 515→526）`；演进数字链尾部 `→511` → `→511→521`
- T-main 断言逻辑: `-le 515 ]` → `-le 526 ]`（`-le 558` 总上限不动）

## 验证（编辑后）
- `bash selftest-goal-unit-goal-mode.sh` → `G-09 PASS SKILL.md 行数=521 ≤526（D2 上调后上限）` / `Total: 9 PASS=8 FAIL=1` / exit=1（**G-07 唯一 FAIL=registry 末行仍指向 selftest-decision-arbiter.sh，系预期残留，下单元 Fix-B3 修**；G-09 转 PASS 且 G-01..G-06/G-08 无回退）
- `bash selftest-skill-split.sh` → `T-主 行数 ≤526 ... [PASS]` / `Total: 41 PASS=41 FAIL=0` / exit=0（T-main 转 PASS，其余 40 断言无回退）
- `git status --short`：仅 A/B 两目标脚本被本单元改动（另有 selftest-drift-check-subagent.sh / selftest-research-first.sh 为前序单元既有改动，本单元未触碰）
- `git diff --name-only -- skills/task-planner/SKILL.md` = 空（SKILL.md 零触碰）

## 515 残留核查（钉值断言字面 = 0）
- 钉值断言字面 `grep -c '\-le 515\|≤515\|>515\|不超过 515 行'`：A=0、B=0（全部清零）
- `grep -c 515` 原始计数：A=1、B=3 —— 全部落在**任务书明文要求的演进史注释字面**（`515→521` / `钉值上调 515→526` / 前序 v151 历史行 `510→515`），非钉值断言残留。任务书「grep -c 515=0」与「演进史字面含 515→521/515→526」两项要求互斥，按更具体的逐行指令保留演进史字面，钉值断言字面清零。

## 运行尾部原文
```
G-09 PASS SKILL.md 行数=521 ≤526（D2 上调后上限）
G-07 FAIL selftest-registry.tsv 末行=selftest-decision-arbiter.sh ...（应含 selftest-goal-unit-goal-mode.sh）
Total: 9 PASS=8 FAIL=1
goal_exit=1

[PASS] T-主 行数 ≤526（... task-v154 接线级联净 +11-1 改（515→521，钉上调 515→526）;演进 ...→502→511→521 ...）且 ≤558 上限
Total: 41  PASS=41  FAIL=0
split_exit=0
```
