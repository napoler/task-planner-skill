# P2-S3 任务书: SKILL C32 + Rule 42 摘要行追加 + 模板「对齐审查」行 + mini-lite 豁免行（task-v102）

任务: worktree 内 4 处锚行编辑。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v102-alignment-upgrade/（只读）
- progress.md: 同目录（子代理禁写）

## 目标文件（worktree 下,行号以内容锚定位）
1. skills/task-planner/SKILL.md（C31 行后+C32 行;Rule 42 摘要行行内追加）
2. skills/task-planner/templates/task_plan.md（配置表 interaction_mode 行后+1「对齐审查」行）
3. skills/task-planner/templates/variant/mini-lite-type.md（头部注释区+1 豁免行）

## 硬约束
- C29/C30/C31 行、Rule 40/41/42/43 摘要行本体、「Rules 1-39」字面 2 处、「质量审查工具」行——全部零改动（C32 为新增行;Rule 42 摘要行为行内追加）
- 禁「1-4x」越界字面;零新 config 键

## 操作内容（逐字）
### ① SKILL.md C31 行（含「| C31 |」的表行）之后追加:
`| C32 | 对齐审查标准流程（Rule 42.6）：文档/文件更新前已按 42.6.1 跑版本一致性校验（未经校验未直接追加）；任务完成前已按 42.6.2 对全部产出与更新文档跑 alignment-review 对齐审查（标准收尾流程）；对齐整理已输出变更记录（42.6.3 五要素）；本任务无文档更新或纯新增无联动时登记豁免理由（机器面=selftest-review-library RL-11 静态断言，校验过程人工核查；mini 档豁免） | ☐ |`
### ② SKILL.md Rule 42 摘要行（含「Rule 42（质量审查技能主动检测与补充 — task-v099）」的行）行内末尾（「（42.5）」之后、「零新 config 键」之前的位置需审视——以实际行文为准，在行末追加）:
`;对齐审查前置与收尾消费——写入前版本一致性校验闸门（42.6.1 未经校验不追加）+任务完成前对齐标准流程（42.6.2 全文档过 alignment-review）+变更记录输出（42.6.3）+零新键机制（42.6.4,task-v102）`
（即原摘要行末尾追加该片段,原摘要行其余内容零改动）
### ③ templates/task_plan.md 配置表 `interaction_mode` 行之后追加:
`| \`对齐审查\` | \`[登记]\` | Rule 42.6 消费：任务产出或更新的文档在完成前跑 alignment-review 对齐审查（标准收尾流程）;文档更新前跑版本一致性校验（未经校验不追加）;变更记录随交付物落盘;mini 档豁免（42.6.4） |`
### ④ templates/variant/mini-lite-type.md 头部注释区追加（对齐既有豁免行形态）:
`<!-- Rule 42.6 豁免声明（task-v102）: mini 档不含「对齐审查」配置行——Rule 38.3 轻量模板契约自然延伸（同 40.2/42.5 豁免行范式） -->`

## acceptance: 验收标准
1) SKILL `grep -c '| C32 |'`=1 且 C30/C31 计数不变（各 1）
2) Rule 42 摘要行含「42.6.1」「未经校验不追加」「对齐标准流程」各 ≥1;行内既有内容（42.1-42.5 措辞）零删改
3) 模板 `grep -c '对齐审查' templates/task_plan.md`=1;mini-lite `grep -c 'Rule 42.6 豁免'`=1
4) `grep -c 'Rules 1-39' SKILL.md`=2;`grep -nE '1-4[0-9]' SKILL.md` 零命中
5) worktree scripts/ 复跑 4 脚本 0 FAIL: selftest-review-library（10/0,RL-11 未加不影响）/selftest-self-resolution/selftest-reliability-institution/selftest-skill-split
6) `git -C <wt> diff --stat` 本步面=3 文件（SKILL.md+2 模板;CRIT/alignment 为前序存量）

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v102-alignment-upgrade/subagent-state/03-exec-p2s3.md。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S3
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
