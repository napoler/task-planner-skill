# fix-f1b (F1b-mix) checkpoint — C-5/C-8

- task: `task-tpl-sediment-20261115` 修复批次 F1b-mix（critic C-5/C-8）
- scope: only the two files below modified; no other files touched; did not touch `tmp/worktrees/task-clause-generalize-20261115`

## C-8 SKILL.md 路由表 advisor 行位次统一
- file: `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115/skills/task-planner/SKILL.md`
- change: moved satellite routing row `plan-template-advisor` (row content unchanged) from after `plan-template-kit` to after `media-planner` (new-domain group position, aligned with README/ARCH).
- evidence:
  - `grep -c 'plan-template-advisor' .../SKILL.md` => `1`
  - routing rows now: `media-planner` (211) -> `plan-template-advisor` (212) -> `plan-research-router` (213) -> `plan-template-kit` (214)
  - table columns/row count unchanged; only row order moved (106.1a: edit included adjacent anchor rows).

## C-5 候选模板路径与本地指针修正
- file: `/mnt/data/dev/task-planner-skill/plans/task-tpl-sediment-20261115/template-candidate/rule-clause-cascade-type.md`
- changes:
  1. repo-root nonexistent paths corrected to real paths: `README.md`/`docs/ARCHITECTURE.md` -> `skills/task-planner/README.md` / `skills/task-planner/docs/ARCHITECTURE.md` (VC-2 verify command, Phase 1 checklist, knowledge reserve).
  2. task-local `findings F11/F12` references replaced with mechanism-name anchors: `判例 F12` -> `机制：落位指针机制名锚定，禁任务本地编号引用`; `悬空指针(F12)、init/render 签名误用(F11)` -> `悬空指针（落位指针机制名锚定）、init/render 签名误用（init-session.sh 调用签名契约）`.
  3. kept machine-readable header + five structure blocks + total 39 lines (<=100).
- evidence:
  - `grep -n 'F11\|F12' ...rule-clause-cascade-type.md` => no matches
  - no bare repo-root README/ARCH backtick paths remain (all are `skills/task-planner/...`)
  - `wc -l` => `39`
  - mechanism anchors/paths present: lines 14,19,24,38,39 show corrected paths and anchors.

## Acceptance
- C-8: advisor row between media-planner and plan-research-router; `grep -c 'plan-template-advisor'` == 1; row content unchanged. PASS
- C-5: real skill paths in place; F11/F12 task-local refs removed; mechanism-name anchors used; header+5 blocks+<=100 preserved. PASS

## Issues
- none observed
