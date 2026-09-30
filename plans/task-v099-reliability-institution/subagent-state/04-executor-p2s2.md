# 04 Executor P2-S2 checkpoint — SKILL.md 三锚联动 + 行数级联（task-v099）

status: done
phase: P2-S2
worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v099-reliability-institution

## 写入面（本步恰 2 文件，禁 git commit/add 已遵守）
1. skills/task-planner/SKILL.md（+6 行净增 435→439）
   - C29 行（原 :194）后追加 C30+C31 两行（任务书逐字）
   - Rule 41 摘要行（原 :273）后追加 Rule 42/43 摘要两行（任务书逐字）
   - 索引行（原 :242）括注「（Rules 1-39（含 Rule 40/41）」→「（Rules 1-39（含 Rule 40/41/42/43）」（行数 +0）
   - References 表（原 :297）critical-rules.md 行枚举末追加「 / Rule 42 质量审查技能主动检测与补充 / Rule 43 执行可靠性制度化」（行数 +0）
2. skills/task-planner/scripts/selftest-skill-split.sh（仅 :41 一行）
   - `-le 435` → `-le 439`（N=wc 实测 439，非手估）
   - label →「T-主 行数 ≤439（task-v099 Rule 42/43 联动 435→439）且 ≤558 上限」；同函数 `-le 558` 未动

## 命令实际输出
- `wc -l skills/task-planner/SKILL.md` → 439（三锚完成后实测）
- `grep -nE '1-4[0-9]' SKILL.md` → 无命中（exit 1）
- acceptance grep（在 worktree skills/task-planner/ 下，S=SKILL.md）:
  - R42=3 R43=3 C30=1 C31=1
  - `Rules 1-39`=2, `1-40`=0, `1-41`=0
  - `| C29 |`=1, `Rule 41（问题自主消解与升级纪律`=1, `含 Rule 40/41/42/43`=1
- 4 脚本复跑（worktree scripts/）:
  - selftest-skill-split: Total: 41  PASS=41  FAIL=0
  - selftest-workflow-orchestration: Total: 16  PASS=16  FAIL=0
  - selftest-knowledge-brief: Total: 16  PASS=16  FAIL=0
  - selftest-skill-collab: Total: 25  PASS=25  FAIL=0
- `git -C <wt> diff --stat`:
  - skills/task-planner/SKILL.md | 8 ++++++--
  - skills/task-planner/references/critical-rules.md | 19 ++++++++...（S1 存量，非本步写入面，未动）
  - skills/task-planner/scripts/selftest-skill-split.sh | 2 +-
  - 3 files changed, 26 insertions(+), 3 deletions(-)

## 负结果检查
- `grep -c '1-40'`=0、`grep -c '1-41'`=0、`grep -nE '1-4[0-9]'` 零命中 —— 越界数字字面不存在（v097 对策 b 锁守住）
- 既有锚「| C29 |」「Rule 41（问题自主消解与升级纪律 — task-v098）」「| C28 |」「含 Rule 40/41」旧字面被扩写取代（1 处索引行），枚举面 Rule 40/41 字面保全在 References 表行内
- 零新 config 键：本步未触碰 config.json
- critical-rules.md（S1 存量 19 行）未做任何修改

## acceptance 逐条对照
1. R42≥2（3）✓ R43≥2（3）✓ C30=1 ✓ C31=1 ✓
2. `Rules 1-39`=2 ✓ `1-40`=0 ✓ `1-41`=0 ✓ `grep -nE '1-4[0-9]'` 无命中 ✓
3. C29=1 ✓ Rule 41 锚=1 ✓ `含 Rule 40/41/42/43`≥1（=1）✓
4. skill-split.sh:41 `-le 439`（N=wc 实测 439）且 label 含 task-v099 ✓（`-le 558` 保留）
5. 4 脚本 0 FAIL（Total 行原文已录上方）✓
6. `git diff --stat` 累计 3 文件，本步恰 2 文件（critical-rules.md 为 S1 存量）✓

next_step: 交 orchestrator 做 P2 阶段验收/后续 S-unit。
