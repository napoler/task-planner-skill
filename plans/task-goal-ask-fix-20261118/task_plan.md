<!-- plan_tier: mini -->
# task-goal-ask-fix-20261118: goal 模式静默自治询问根治

## Goal
修正 goal/目标迭代语境下仍可能触发选择/确认询问的规则落点（28.2.2↔28.8 优先级、计划确认/D1/澄清环节）并对齐载体，根治 sess_ba603cf5 类阻塞空转。

## Scope
- skills/task-discipline/references/critical-rules-discipline.md (28.2.2 goal 优先覆盖)
- skills/task-planner/SKILL.md, skills/task-planner/references/critical-rules.md (goal 覆盖落点)
- 部署位 ~/.zcode/skills 与 ~/.agents/skills 对应文件同步（防漂移复发）

## VC
- [ ] VC1: goal 语境下 28.2.2/澄清/D1 不得向用户提问，歧义按推荐项静默自决留痕（文本锚在位）
- [ ] VC2: repo 与部署位关键载体一致/已同步，证据可复核
