# P2-S2 任务书: 级联 3 处（RL-01/DIRS、CRIT 42.2 枚举、general-review 枚举）——task-v101

任务: worktree 内将兜底池从 10 扩到 11 的级联更新（3 处）。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v101-alignment-review/（只读）
- progress.md: 同目录（子代理禁写）

## 目标文件（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v101-alignment-review 下）
1. skills/task-planner/scripts/selftest-review-library.sh（:5 注释、:27 DIRS、:33-35 RL-01 断言与错误消息）
2. skills/task-planner/references/critical-rules.md（:420 42.2 行内枚举）
3. skills/task-planner/review-library/general-review/SKILL.md（:8 触发段枚举）

## 硬约束
- 仅上述 3 文件的指定片段;其余零改动;「Rules 1-39」字面 2 处不动;新增文本禁「1-4x」越界字面
- CRIT 42.2 行除枚举与类数字样外其余（①②③④层描述/「均未命中=缺口」/尾注）逐字保全

## 操作内容（逐字）
### ① selftest-review-library.sh（3 处小改,同文件内）
- :5 `RL-01     review-library/ 目录数 = 10（恰 10 目录）` → `RL-01     review-library/ 目录数 = 11（恰 11 目录）[2026-09-30 task-v101 +alignment-review]`
- :27 `DIRS="general-review code-quality-review test-quality-review security-review image-review content-quality-review documentation-review data-quality-review ui-quality-review release-review"` → 末尾追加 ` alignment-review`
- :33-35 断言行: `目录数 = 10`→`目录数 = 11`、`-eq 10`→`-eq 11`、`（应 10）`→`（应 11）`（逐字对照 :33-35 实文修改,错误消息文本同步）
### ② CRIT :420 42.2 行内两处
- `下 10 类通用质量审核技能：general/code-quality/test-quality/security/image/content-quality/documentation/data-quality/ui-quality/release）` → `下 11 类通用质量审核技能：general/code-quality/test-quality/security/image/content-quality/documentation/data-quality/ui-quality/release/alignment）`
- 行内既有尾注 `[2026-09-30 task-v100 B 类扩围: ...]` 保留,其后追加 `[2026-09-30 task-v101 扩展: +alignment-review（对齐/同步一致性审查）,10→11 类]`
### ③ general-review/SKILL.md :8 触发段枚举
- `（code/test/security/image/content/documentation/data/UI/release）` → `（code/test/security/image/content/documentation/data/UI/release/alignment）`

## acceptance: 验收标准
1) `bash scripts/selftest-review-library.sh` → `Total: 10 PASS=10 FAIL=0`（RL-01 计数 11 通过;RL-02 DIRS 含 alignment-review 通过;RL-04..07 循环自动覆盖新技能——其 SKILL.md 已满足 frontmatter/四要素/清单/合约）
2) `grep -c 'alignment-review' scripts/selftest-review-library.sh` ≥2（DIRS+注释）
3) CRIT `grep -c 'alignment'`=≥1 且 `grep -c '10 类通用'`=0 且 `grep -c '11 类通用'`=1
4) general-review `grep -c 'alignment'` ≥1
5) `git -C <wt> diff --numstat`: selftest=2 行级（注释+断言）或近似/CRIT=1/1/general-review=1/1——三文件外零改动
6) `grep -nE '1-4[0-9]'` 三文件零命中
7) worktree scripts/ 复跑 3 脚本 0 FAIL: selftest-review-library/selftest-self-resolution（SR-12 动态口径不受影响）/selftest-reliability-institution

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v101-alignment-review/subagent-state/02-exec-p2s2.md。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S2
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
