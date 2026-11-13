# task-skillfix-audit-20261109
plan_tier: mini
Status: complete
## Goal
修正当前项目 skills 规范性审计发现的全部问题（P1/P2/P3），只读审计后经用户授权执行修复。
## VC
- [x] workflow-model-tiers 跨技能 `references/` 引用改为显式相对路径 `../plan-collab-router/references/critical-rules-collab.md`（:11）
- [x] todo-skill `tools/...` 占位符改为 `tools/<cmd>.ts`，消除机械 broken_ref 误报（:42）
- [x] plan-resume 439→89 行（<400 warn），§7 详细内容迁移至 `references/autonomous-resume-detail.md`（162 行），关键信息/触发/§7.10 框架保留
## Scope
- `skills/workflow-model-tiers/SKILL.md` (modified)
- `skills/todo-skill/SKILL.md` (modified)
- `skills/plan-resume/SKILL.md` (rewritten, 438→89 lines)
- `skills/plan-resume/references/autonomous-resume-detail.md` (new)
