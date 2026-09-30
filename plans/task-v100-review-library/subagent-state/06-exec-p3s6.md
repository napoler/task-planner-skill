# P3-S6 checkpoint — selftest-review-library.sh + registry +1（task-v100）

完成时间: 2026-09-30 | 状态: 完成

## 已写文件
1. /mnt/data/dev/task-planner-skill-worktrees/task-v100-review-library/skills/task-planner/scripts/selftest-review-library.sh（新建, RL-01..10 静态断言, 范式照同构 selftest-self-resolution.sh）
2. /mnt/data/dev/task-planner-skill-worktrees/task-v100-review-library/skills/task-planner/scripts/selftest-registry.tsv（+1 行, 40→41）

## 断言锚实测确认（防假断言, v099 教训）
- 10 目录名与清单精确一致; 每目录 SKILL.md 存在; frontmatter name/desc 各 10/10
- APPROVED/CHANGES_REQUESTED/Rule 43.1 全 10 文件在位; 清单条目最少 11（均 ≥10）
- 四要素标题全 10 文件 1/1/1/1
- 主 SKILL.md: `| C30 |`=1, 「四级顺序」=2
- CRIT 42.2: 池主体 token「task-planner 内置 review-library 兜底池」=1;「均未命中=缺口」=1;「三级检测顺序」=0
- 锚修正: 原文 ④ 与池 token 之间有 `**` 强调符（`④ **task-planner 内置...`），故 RL-09 主体锚去 ④ 前缀直用池 token，避免假断言（脚本头注释已注明）
- 越界 `grep -nE '1-4[0-9]'` 全池 10 文件零命中（rc=1）

## 验收实测输出
- `bash scripts/selftest-review-library.sh` → `Total: 10 PASS=10 FAIL=0` rc=0
- `bash -n` rc=0
- `bash scripts/selftest-registry.sh` → `Total: 5 PASS=5 FAIL=0 (registry rows=40, actual selftest=40)` rc=0
- tsv `wc -l` = 41
- `git status --short` 本步面 = `M .../selftest-registry.tsv` + `?? .../selftest-review-library.sh`（review-library 为 P2 存量，无新踪迹）

## 未做/禁止项遵守
- 无 git commit/add；未写 progress.md；只读 task_plan.md / findings.md 契约遵守（本步未修改计划三文件）
