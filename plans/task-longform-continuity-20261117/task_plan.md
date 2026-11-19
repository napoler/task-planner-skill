# Task Plan: task-longform-continuity-20261117
template_type: rule-enhancement
plan_tier: standard
execution_lane: L1
status: in_progress

## Goal
系统性修复长篇/连续创作（小说/剧集/长论文/长报告）的前后遗忘与设定漂移：增强 Rule 107 与派发契约，新增 longform-continuity 技能与方法论、长文专用模板与映射，要求项目级大纲/设定库/知识库/脑图先行与动笔前全局检索、禁止静默覆盖。

## Intent Switch / 授权记录
- [intent-switch] D 类：挂起 `task-skill-nopause-imperative-20261117`（本会话暂停推进，原计划保留），切换至本任务。依据：用户指令“我又开始在无限制的循环了，根本就不解决问题”+此前已选定方案[0]并要求用 worktree 落地。
- 实施范围（按方案[0]+补充）：Rule 107 增强；task-dispatch 22.4d + subagent_dispatch 模板；新增 `skills/longform-continuity/SKILL.md` 与 `skills/task-planner/references/longform-continuity-methodology.md`；新增 `templates/variant/longform-continuity-type.md`；更新 `plan-template-kit/references/template-mapping.md`；增强 `writing-type.md`/`script-dev-type.md`；必要索引/指针同步。worktree: `tmp/worktrees/task-longform-continuity-20261117` (wt/task-longform-continuity-20261117)。合并/部署待自检后用户另行确认。

## VC
- VC-1: Rule 107 含项目级资产（总纲/设定库/知识库/脑图）、大纲先行门、动笔前全局检索、冲突禁静默覆盖、恢复读序。
- VC-2: 22.4d 与派发模板携带项目级资产路径与先检索要求。
- VC-3: 新增长文连续性技能与方法论（含长文本优化策略）。
- VC-4: 新增长文专用模板并在 mapping 注册，写作/剧本模板要求调用技能与一致性检查。
- VC-5: 关键引用一致、git diff 可审计。

## Phases
- P1: 创建 worktree 与计划骨架 [done]
- P2: 规则与契约增强 (Rule 107, 22.4d, dispatch template) [in_progress]
- P3: 新增技能与方法论 reference [pending]
- P4: 新增模板、增强 writing/script-dev、更新 mapping/索引 [pending]
- P5: 自检与证据汇总 [pending]
