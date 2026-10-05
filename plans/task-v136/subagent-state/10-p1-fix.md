# P1 修复检查点（task-v136 Phase 6 修复单元，executor）

## Step1 行号/字面量核对（HIGH）
- 09-alignment-review.md §二 行号与 worktree 实读一致，零漂移，无需报告偏差：
  - reliability-institution.sh:13 = `#   R-09     SKILL.md \`grep -c '含 Rule 40-53 全集'\` ≥1 且 \`grep -c '1-40'\` = 0（括注全集锚+越界负断言）`
  - self-resolution.sh:12 = `#   SR-08     SKILL.md 含「含 Rule 40-53」≥1 且 critical-rules.md \`grep -c '^40\.'\` = 6（Rule 40/41 共存零损伤）`
  - root-resolution.sh:159 = `# 「Rule 40/41/…/51」漏 50/52/53）已改简洁括注「含 Rule 40-53 全集」。断言：索引行（'（Rules 1-39' =1 定位）` ← v131 历史叙述，**禁改保留**
  - root-resolution.sh:160 = `# 须同时含「Rule 40-53」（或至少含 50 与 53 两个号=逐号式括注的兜底判定）——防下次全集扩张时索引行再次脱钩。`
  - root-resolution.sh:169 = `  bad 16 "SKILL.md 索引行命中=$idxn（应 =1）或索引行未含「Rule 40-53」（亦未同时含 50 与 53——级联漏改，CR P1-2 复发）"`
  - root-resolution.sh:173 = `# 口径：条款侧区块标题锚（与 RR-07 SKILL 侧摘要 bullet 对称）——SKILL 索引行声明「Rule 40-53 全集」但条款侧`

## 改前行原文（4 处）
1. reliability-institution.sh:13 → 见上（`含 Rule 40-53 全集`）
2. self-resolution.sh:12 → 见上（`含「含 Rule 40-53」≥1`）
3. root-resolution.sh:169 → 见上（`索引行未含「Rule 40-53」`）
4a. root-resolution.sh:160 → 见上（`须同时含「Rule 40-53」`）
4b. root-resolution.sh:173 → 见上（`声明「Rule 40-53 全集」`）

## 改后目标（用户 scope 指定）
1. `含 Rule 40-5[3-9] 全集`
2. `含「含 Rule 40-5[3-9]」≥1`
3. `索引行未含「Rule 40-5[3-9]」`
4a. `须同时含「Rule 40-5[3-9]」`
4b. `声明「Rule 40-54 全集」`

## Step3 3 脚本复跑
（待补）

## Step4 全量 52 脚本汇总
（待补）

## Step3 3 脚本复跑（2026-10-05，单脚本 timeout 90s）
- selftest-reliability-institution.sh → `Total: 16 PASS=16 FAIL=0` exit=0
- selftest-self-resolution.sh → `Total: 13 PASS=13 FAIL=0` exit=0
- selftest-root-resolution.sh → `Total: 17 PASS=17 FAIL=0` exit=0

## Step4 全量 52 脚本汇总（2026-10-05，单脚本 timeout 90s，/tmp/alltest-*.sh.log）
- scripts passed=52 / failed=0（无超时、无 SKIPPED）
- 各脚本 Total 行求和（PASS+FAIL，含 6 个非标准 Total 行格式脚本：delegation/exec-stability/fallback/final-gate-hash/knowledge-brief/skill-collab/skill-split，final-gate-hash 行格式 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`）
- **sum = 798 PASS / 0 FAIL = 798/0，与基线一致，无合法偏移**

## Step5 验证
- git diff --numstat: 3 文件共 5 行（1+3+1）:
  - selftest-reliability-institution.sh 1/1（:13）
  - selftest-self-resolution.sh 1/1（:12）
  - selftest-root-resolution.sh 3/3（:160/:169/:173）
- git status --short: 仅上述 3 文件 M，无其他改动
- grep 'Rule 40-53' 残留核对: 仅剩 5 处历史叙述/v131 级联日志行（root:159 明示保留；reliability:14,:76；self-resolution:13,:70）——全部为「[2026-10-05 task-v131 CR P1-2 级联」日志注释或 :159 历史叙述，不在 scope 指定 4 项内，正确保留
- 新字面量确认: :13 `含 Rule 40-5[3-9] 全集` / :12 `含「含 Rule 40-5[3-9]」` / :160 `须同时含「Rule 40-5[3-9]」` / :169 `索引行未含「Rule 40-5[3-9]」` / :173 `声明「Rule 40-54 全集」` —— 与 scope 逐项一致
