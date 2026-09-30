# P2-S3 任务书: RL-12/13 + 头注释级联（task-v104）

任务: worktree 内 selftest-review-library.sh 追加 RL-12/RL-13 两条断言 + 头注释 RL 计数级联（11→13）。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v104-align-gate-upgrade/（只读）
- progress.md: 同目录（子代理禁写）

## 目标文件
/mnt/data/dev/task-planner-skill-worktrees/task-v104-align-gate-upgrade/skills/task-planner/scripts/selftest-review-library.sh（当前 11 断言,Total: 11）

## 硬约束
- RL-01..RL-11 既有断言零改动（RL-11 三锚升级后仍全中,v102 用户原话锚保留）
- 头注释区「RL-01..RL-11」计数措辞→「RL-01..RL-13」;RL-02..RL-10 循环文案（「11 个」「11×N」）零改动（池成员数 11 未变）
- 只动该文件

## 操作内容
### ① 头注释区 RL-11 描述行之后追加 2 行描述:
`#   RL-12     alignment-review 闸门深化锚（task-v104）：「全文扫描」≥1 且「删除或归档」≥1 且「变更范围」≥1（alignment-review/SKILL.md）`
`#   RL-13     42.6.3 三要素升级锚（task-v104）：CRIT 42.6.3 行「三要素」≥1 且 SKILL.md C32 行「三要素」≥1`
### ② 断言区 RL-11 断言之后追加（照 RL-05/RL-11 单文件断言范式,alignment 文件路径变量沿用现文）:
RL-12: alignment-review/SKILL.md 内 `grep -c '全文扫描'`≥1 且 `grep -c '删除或归档'`≥1 且 `grep -c '变更范围'`≥1 → ok 12 否则 bad 12
RL-13: CRIT `grep '^42\.6\.3' | grep -c '三要素'`≥1 且 SKILL.md `grep '^| C32 |' | grep -c '三要素'`≥1 → ok 13 否则 bad 13
（CRIT/SKILLMD 变量名沿用现文既有变量;先 Read 现文确认变量名再写）
### ③ Total 行不变（`Total: 13 PASS=13 FAIL=0` 自然产出）

## acceptance: 验收标准
1) `bash scripts/selftest-review-library.sh` → `Total: 13 PASS=13 FAIL=0`
2) RL-01..RL-11 断言行零改动（git diff 该文件仅头注释 2 行+断言区 RL-12/13 新增,deletions 仅头注释计数措辞行）
3) `grep -c 'RL-13' scripts/selftest-review-library.sh` ≥2
4) `bash -n` 语法过
5) worktree 复跑 3 脚本 0 FAIL: selftest-review-library/selftest-reliability-institution/selftest-self-resolution
6) `git -C <wt> status --short` scripts/ 仅该文件 M（前序存量为 alignment SKILL/CRIT/SKILL.md）

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v104-align-gate-upgrade/subagent-state/03-exec-p2s3.md（含 Total 行原文）。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S3
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
