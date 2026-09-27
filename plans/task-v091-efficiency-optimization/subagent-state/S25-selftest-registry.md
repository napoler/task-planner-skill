# S25-selftest-registry checkpoint (task-v091/S25 C-4)

## step 1 进场核对 ✅
- worktree HEAD = `40a18804b4aa51236c41c714c520e6fbdeeb80b4`（40a1880 开头 ✓）
- `git status --porcelain` 输出 0 行（clean ✓）
- 置信度 HIGH

## step 2 Read 提案+现状 ✅
- 提案 C-4（efficiency-proposal.md:155-162）原文要点：
  - 改动面：新增 `scripts/selftest-registry.tsv`（27 脚本×消费域）；Rule 36.6 增纯增子条「开发过程中间轮次跑改动域子集；交付终验必须全量 27 脚本 0 FAIL——全量总门不降」；registry 一致性自守护断言
  - 字段设计权威口径：`脚本名×消费域`（§157 原文「27 脚本×消费域」；守护=「registry 一致性断言」，实现形式未既定 → 最小实现=独立小脚本 check-selftest-registry.sh（非 selftest-* 命名，避免集合自递归）
  - 护栏：终验全量 0 FAIL 条款原文保留（36.6 原句 :316 一字不动，纯追加）
- 现状实测（2026-09-27）：
  - selftest-*.sh 实际 **31 个**（非提案撰写时 27；含 v091 新建 4 个：rule23-conflict-scan / check-conflicts / final-gate-hash / sync-index）→ registry 覆盖以 31 为准（§155 的「27」是撰写时快照）
  - Rule 36.6 = critical-rules.md:316；36.7 = :317 → 36.6a 插入于两行之间，纯追加 1 行
  - lib/plan-parse.sh 实际路径 = `scripts/lib/plan-parse.sh`（任务文本省略 scripts/ 前缀）
  - 附带授权核实：plan-parse.sh:10-11 第 2 项「sync-todos.sh extract_plan_meta — S17 已接入(head -10 上限…见 :196 一带)」确已过时——sync-todos.sh 内 `grep -n extract_plan_meta` 仅剩 3 处**注释**（:124/:165/:178），函数体已删；现状 = write_index 内联语义副本（sync-todos.sh:174 注释「scope 提取块 = lib/plan-parse.sh plan_parse_scope 的内联语义副本」、:244 语义锚注释）
  - 提案验证设计③「改名场景期待守护断言 FAIL」→ 守护必须双向（缺行 + 孤儿行）

## step 3 实施 ✅
- commit = `3cdab78`（worktree 分支 wt/task-v091-efficiency-optimization，基于 40a1880；commit 后 status clean）
- 文件（4 files changed, 89 insertions(+), 2 deletions(-)）：
  1. 新建 `skills/task-planner/scripts/selftest-registry.tsv`（33 行=表头+32 数据行；31 个既有 selftest + 守护自身 self-registered）
  2. 新建 `skills/task-planner/scripts/selftest-registry.sh`（T01-T05 五断言双向守护，755）
  3. `references/critical-rules.md` 316→317 行区间插入 36.6a 纯增补 1 行（36.6 原句零改；366→367 行）
  4. `scripts/lib/plan-parse.sh`:10-11 注释改写为「write_index 内联语义副本（S17 原 extract_plan_meta 已删, S25 修正）；见 sync-todos.sh :174/:244 语义锚注释」

## step 4 验收 ✅
- 覆盖数对齐：registry rows=32, actual selftest-*.sh=32（31 既有 + 守护自身）
- 守护实跑：`bash selftest-registry.sh` → T01-T05 全 PASS，`Total: 5 PASS=5 FAIL=0` rc=0
- 守护负例（/tmp 沙箱）：删 selftest-veto.sh → T02/T03 FAIL rc=1；改名 veto-renamed.sh → 孤儿 FAIL rc=1（提案验证设计③闭合）
- 子集计时（tier 域）：selftest-plan-tier.sh + selftest-final-gate-hash.sh → `real 0m23.678s`，两脚本 Total 均 0 FAIL（32+22 断言）——≤25s 达标
- bash -n：selftest-registry.sh / lib/plan-parse.sh 均通过
- commit message 与任务文本逐字一致：`feat(task-planner): task-v091/S25 C-4 — selftest 分域 registry.tsv+36.6 增补子条+一致性自守护`

## risks 登记
- TSV「27 脚本×消费域」为提案撰写时快照，现实际 31（v091 新增 4）→ 已按 31 全覆盖并在 TSV 注释/commit body 中说明
- critical-rules.md 行数 366→367（+1 行 36.6a）
- 守护命名取 selftest-registry.sh（非 check- 前缀）以落入 registry 自登记闭环；部署位全量 selftest 仍须包含此守护（C-5 特记「部署位 selftest 保持全量」语义不变）

## next
- S25 完成；若后续任务改任何 selftest-*.sh 增删/改名 → 必须同步 TSV（守护会 FAIL 咬住）

