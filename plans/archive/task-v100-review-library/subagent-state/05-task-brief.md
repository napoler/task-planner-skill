# P2-S5 任务书: Rule 42.2 四级化 + 「三级」级联措辞同步（task-v100,B 类扩围 4 处）

任务: worktree 内 Rule 42.2 检测链三级→四级化+「三级」级联措辞同步（共 4 处）。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/（只读）
- progress.md: 同目录（子代理禁写）

## 目标文件（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v100-review-library 下,行号以内容锚定位）
1. skills/task-planner/references/critical-rules.md :420（42.2 行）与 :423（42.5 行内「三级检测顺序锚」措辞）
2. skills/task-planner/SKILL.md :195（C30 行）与 :276（Rule 42 摘要行）

## 硬约束
- 42.2 改写仅限该行本身;①②③层原文保留;「均未命中=缺口」语义必须保留;Rule 42.1/42.3-42.5 主体与 Rule 1-41/43 零改动
- 「Rules 1-39」字面 2 处不动;新增文本禁「1-4x」越界字面
- SKILL C30 行内仅动「三级顺序检测」措辞与其层级列举,其余（登记要求/机器面/豁免措辞）保全

## 操作内容（4 处,逐字给出）
### ① CRIT :420 42.2 行整行替换为:
`42.2 **四级检测顺序（项目级→用户级→环境既有 agents→task-planner 内置兜底池，均未命中=缺口）**：① 项目级 skills（工作区级 \`.zcode/skills\`、\`.agents/skills\`）→ ② 用户级 skills（\`~/.zcode/skills\`、\`~/.agents/skills\`）→ ③ 环境既有 agents（code-reviewer/critic/quality-reviewer 类角色 agent）→ ④ **task-planner 内置 review-library 兜底池（\`skills/task-planner/review-library/\` 下 10 类通用质量审核技能：general/code-quality/test-quality/security/image/content-quality/documentation/data-quality/ui-quality/release）**——第④层命中即直接消费对应技能（Read/Skill 加载），无需补建；①②③④均未命中=缺口，缺口处置按 42.3 补充合约执行。检测结论（技能名/既有 agent 名/兜底池命中项/缺口判定）落 42.4 登记行，禁止跳过检测直接假设「项目已有审查技能」。[2026-09-30 task-v100 B 类扩围: 三级→四级,插入第④层兜底池（用户指令「10 个通用质量审核技能兜底」,池清单见 review-library/）;①②③原文零改动]`
### ② CRIT :423 42.5 行内「三级检测顺序锚」→「四级检测顺序锚」（仅此词组,行内其余零改动）
### ③ SKILL :195 C30 行内「已按 42.2 三级顺序检测（项目级→用户级→环境既有 agents）」→「已按 42.2 四级顺序检测（项目级→用户级→环境既有 agents→内置 review-library 兜底池）」（仅此片段）
### ④ SKILL :276 Rule 42 摘要行内「按三级顺序检测（42.1/42.2 项目级→用户级→环境 agents，均未命中=缺口）」→「按四级顺序检测（42.1/42.2 项目级→用户级→环境 agents→内置 review-library 兜底池，均未命中=缺口）」（仅此片段）

## acceptance: 验收标准
1) `grep -c '四级检测顺序' CRIT` ≥1（42.2 行）且 42.2 行含「④ task-planner 内置 review-library 兜底池」与「均未命中=缺口」
2) CRIT `grep -c '三级检测顺序'`=0;SKILL `grep -c '三级顺序'`=0
3) 42.2 行外 CRIT 零改动（`git diff --numstat` CRIT=1/1——仅该行改写）;42.5 行仅「三级→四级」一词
4) SKILL 改动仅 2 处片段（C30+摘要行）,C29/C31/其他摘要行零改动
5) `grep -c 'Rules 1-39' SKILL.md`=2;`grep -nE '1-4[0-9]'` 两文件零命中
6) `grep -c 'review-library' CRIT` ≥1 且 SKILL ≥1
7) worktree scripts/ 复跑 5 脚本 0 FAIL: selftest-reliability-institution（R-03 只锁「均未命中=缺口」应仍过）/selftest-skill-split/selftest-workflow-orchestration/selftest-knowledge-brief/selftest-skill-collab

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v100-review-library/subagent-state/05-exec-p2s5.md。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S5
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
