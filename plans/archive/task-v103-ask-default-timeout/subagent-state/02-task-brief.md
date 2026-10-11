# P2-S2 任务书: SKILL C33 行 + Rule 44 摘要行 + 模板「自动超时默认项」行 + mini-lite 豁免行（task-v103）

任务: worktree 内 4 处锚行编辑。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v103-ask-default-timeout/（只读）
- progress.md: 同目录（子代理禁写）

## 目标文件（worktree 下,行号以内容锚定位）
1. skills/task-planner/SKILL.md（C33 行新增 + Rule 44 摘要行新增）
2. skills/task-planner/templates/task_plan.md（配置表+1「自动超时默认项」行）
3. skills/task-planner/templates/variant/mini-lite-type.md（+1 豁免行）

## 硬约束
- C29-C32 行、Rule 40/41/42/43 摘要行、「Rules 1-39」字面 2 处——全部零改动（C33 与 Rule 44 摘要行均为新增行）
- 禁「1-4x」越界字面;零新 config 键
- S1 已完成 CRIT 44 节（437→444 行）——本步不碰 CRIT

## 操作内容（逐字）
### ① SKILL.md C32 行（`| C32 |` 表行）之后追加 C33 行:
`| C33 | 用户选择点默认项与自动超时（Rule 44）：向用户提供 2+ 选项的每个询问点已指定默认选项（推荐项排第 1 位标注默认/推荐）+自动超时时长（默认 5 分钟,询问点可声明覆盖值,登记于「自动超时默认项」行）;低区分度选项（产出一致仅步骤/耗时差异）已按 41.3 直接裁决并登记理由而非打扰用户;用户超时未答复已按默认选项自动执行且登记自动裁决记录五要素（超时值/推荐项/触发时间/理由/被覆盖选项）;本任务无 2+ 选项询问点时登记豁免理由（机器面=selftest-ask-default-timeout RT 静态断言,消费过程人工核查;mini 档豁免） | ☐ |`
### ② SKILL.md Rule 43 摘要行（含「Rule 43（执行可靠性制度化 — task-v099）」的行）之后新增独立行:
`- **Rule 44（用户选择点默认项与自动超时裁决 — task-v103）**：给用户的所有选择点必设默认选项+自动超时（44.1 默认 5 分钟,询问点可声明覆盖值）;产出一致仅步骤/耗时差异的低区分度选项优先按 41.3 直接裁决登记而非打扰用户（44.2）;用户超时未答复→按推荐默认项自动执行+登记自动裁决记录五要素（44.3,不打断≠不留痕）;零新 config 键+C33 消费+RT 静态守护（44.4）`
### ③ templates/task_plan.md 配置表「对齐审查」行之后追加:
`| \`自动超时默认项\` | \`[询问点: 默认选项/超时值]\` | Rule 44 消费：本任务所有 2+ 选项询问点逐个登记默认选项（推荐项）与自动超时时长（默认 5 分钟,可覆盖）;低区分度选项（产出一致仅步骤/耗时差异）不询问、直接裁决并登记理由（44.2）;用户超时未答复按默认选项自动执行+登记自动裁决记录五要素（44.3）;mini 档豁免（44.4） |`
### ④ templates/variant/mini-lite-type.md 追加（对齐既有豁免行形态）:
`<!-- Rule 44 豁免声明（task-v103）: mini 档不含「自动超时默认项」配置行——Rule 38.3 轻量模板契约自然延伸（同 40.2/42.5/42.6 豁免行范式） -->`

## 级联义务（v102 六连实证教训:级联面先普查再动手）
- 完成后实测 `wc -l SKILL.md`（C33+摘要行 2 行新增,预期 440→442,**以实测为准**）;将实测值写入 checkpoint（主进程 S3/P3 时级联 T-主 行钉,本步不改脚本）

## acceptance: 验收标准
1) SKILL `grep -c '| C33 |'`=1 且 C30/C31/C32 各=1;`grep -c 'Rule 44（用户选择点默认项与自动超时裁决 — task-v103）'`=1
2) 模板 `grep -c '自动超时默认项' templates/task_plan.md`=1;mini-lite `grep -c 'Rule 44 豁免'=1
3) `grep -c 'Rules 1-39' SKILL.md`=2;`grep -nE '1-4[0-9]' SKILL.md templates/task_plan.md` 零命中
4) SKILL C32 行/Rule 40-43 摘要行零改动（git diff SKILL.md 仅 2 新增行）
5) `wc -l SKILL.md` 实测值入 checkpoint
6) `git -C <wt> diff --stat` 本步面=3 文件（SKILL.md+2 模板;CRIT 为 S1 存量）

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v103-ask-default-timeout/subagent-state/02-exec-p2s2.md（含 SKILL wc 实测值）。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S2
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
