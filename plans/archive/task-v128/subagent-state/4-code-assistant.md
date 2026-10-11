# S4 checkpoint — Code Assistant (task-v128)

status: done
时间: 2026-10-04

## 里程碑
1. findings §D4 两行原文定位（findings.md:68-69）— 完成
2. SKILL.md 两锚插入 — 完成（:75 计划确认区 +2 行内第 1 条；:158 终验交付区）
3. selftest-skill-split.sh :41 定数 449→451 + label 演进链 — 完成
4. 复跑 selftest-skill-split.sh rc=0, 41/41 PASS — 完成

## 产出清单
- /mnt/data/dev/task-planner-skill-worktrees/task-v128/skills/task-planner/SKILL.md (+2/-0)
  - :75 `- **规则编号预留（Rule 20.6）**：新增 Rule 编号时在计划声明 \`new_rule: <NN>\`；attest 自动查重登记（账本 \`plans/.rule-reservations.jsonl\`），冲突时按 \`next\` 建议改号。`（插于「计划确认」区交互模式行之后，行内新增，不挤占既有行）
  - :158 `- **编号账本**：任务合并后运行 \`bash scripts/rule-reserve.sh land <NN> <task-id>\`（无新增编号则跳过）。`（插于「终验交付」区 git 提交核验行之后）
- /mnt/data/dev/task-planner-skill-worktrees/task-v128/skills/task-planner/scripts/selftest-skill-split.sh (+1/-1)
  - :41 原文: `t "T-主 行数 ≤449（task-v126 Rule 49 联动 +2;演进 440→442→444→447→449）且 ≤558 上限" ... -le 449 ...`
  - 新文: `t "T-主 行数 ≤451（task-v128 Rule 20.6 文档联动 +2;演进 440→442→444→447→449→451）且 ≤558 上限" ... -le 451 ...`

## 验证证据
- `wc -l SKILL.md` = 451（原 449，净增恰 2）
- grep 双锚命中: :75 / :158（原文见上）
- `bash scripts/selftest-skill-split.sh` → `Total: 41  PASS=41  FAIL=0` rc=0
- `git status --short`（worktree）: `M SKILL.md`、`M selftest-skill-split.sh`（本 S-unit 变更=仅这两文件）
  - 注: 该 worktree 存在**先前 S-unit 遗留**的 `M attest-plan.sh`（+64 行，未提交，本 S-unit 未触碰、未回滚）——git status 共 3 行 M，属上游并行单元产物

## 最终结论
```
status: done
acceptance: 4/4 pass — [锚1: :75 `  - **规则编号预留（Rule 20.6）**：新增 Rule 编号时在计划声明 \`new_rule: <NN>\`；attest 自动查重登记（账本 \`plans/.rule-reservations.jsonl\`），冲突时按 \`next\` 建议改号。`；锚2: :158 `  - **编号账本**：任务合并后运行 \`bash scripts/rule-reserve.sh land <NN> <task-id>\`（无新增编号则跳过）。`；wc -l = 451；selftest Total: 41 PASS=41 FAIL=0 rc=0；新定数行: :41 `t "T-主 行数 ≤451（task-v128 Rule 20.6 文档联动 +2;演进 440→442→444→447→449→451）且 ≤558 上限" ...`]
files: /mnt/data/dev/task-planner-skill-worktrees/task-v128/skills/task-planner/SKILL.md (+2/-0); /mnt/data/dev/task-planner-skill-worktrees/task-v128/skills/task-planner/scripts/selftest-skill-split.sh (+1/-1)
evidence: grep -n 双锚→:75/:158 命中；wc -l SKILL.md→451；bash selftest-skill-split.sh→Total: 41 PASS=41 FAIL=0 rc=0；grep "T-主 行数"→:41 新定数 451
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v128/subagent-state/4-code-assistant.md (status: done)
findings_written: none
blockers: 本 S-unit 无；注意 worktree 有先前 S-unit 遗留未提交的 attest-plan.sh (+64 行)，git status 共 3 行 M（非本单元触碰，建议主进程验收时区分归属）
confidence: HIGH
```
