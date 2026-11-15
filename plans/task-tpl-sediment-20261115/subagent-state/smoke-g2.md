# smoke-g2 checkpoint

- status: FAIL
- smoke_log: /mnt/data/dev/task-planner-skill/tmp/smoke-tpl-sediment-20261115-163115.log
- pointer_main: /mnt/data/dev/task-planner-skill/plans/.active_plan_side/22f3c779ec324332bea8c784eac3cb5e.active_plan (unchanged: task-tpl-sediment-20261115)

## Prescribed run (TASK_TEMPLATE_TYPE=rule-clause-cascade-type)
- cmd: `cd <smoke>/plans/tpl-smoke-g2 && TASK_TEMPLATE_TYPE=rule-clause-cascade-type bash /mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115/skills/task-planner/scripts/init-session.sh "tpl-smoke"`
- exit: 0
- outcome: init reported `unknown template_type 'rule-clause-cascade-type'` (valid includes `rule-clause-cascade`), fell back to generic `task_plan.md (built-in)` with `template_type: general` and appended template-sense block; did NOT select project-level candidate.
- residual: generated task_plan `grep -c '{{'` == 1 (init render gate/fail-closed not triggered; candidate itself has no `{{`).
- key blocks in generated generic: Goal/Phase present, but not candidate-specific VC/执行范围限制/必要知识储备 structure.
- pointer pollution: none in main side dir; smoke wrote side pointer only inside isolated smoke workspace (`<smoke>/plans/.active_plan_side/subagentagent0571fa630e68444ab4d8d35.active_plan -> tpl-smoke-g2`).
- cleanup: smoke dir removed, log preserved.

## Corrected-type probe (selection/name check)
- cmd: `TASK_TEMPLATE_TYPE=rule-clause-cascade bash <same-init> "tpl-smoke2"` in isolated workspace with same copied candidate at `.zcode/plan-templates/rule-clause-cascade-type.md`
- exit: 0
- outcome: selected project-level candidate; generated task_plan head shows `<!-- template_type: rule-clause-cascade-type -->` and `**template_type: rule-clause-cascade-type**`; `grep -c '{{'` == 0; key blocks present (Goal, VC 表, Phase 1-3, 执行范围限制, 必要知识储备).
- pointer pollution: main pointer unchanged.

## Diagnosis
- init derives project template type from filename stem by stripping `-type.md` (`rule-clause-cascade-type.md` -> `rule-clause-cascade`), but prescribed invocation and candidate internal `template_type` label use `rule-clause-cascade-type`; this mismatch prevents selection in prescribed form.
