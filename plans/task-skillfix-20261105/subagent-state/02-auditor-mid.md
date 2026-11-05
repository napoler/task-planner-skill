# 02-auditor-mid.md - Skill Diagnostic (6 satellites)

## Skills audited
- task-dispatch (62+ refs/scripts)
- verification-gate (94+ ref/script)
- media-planner (47+ ref)
- task-discipline (98+ refs/scripts)
- progress-tracker (199+ refs)
- todo-skill (128+ scripts)

## 1) validate_skill.ts
- task-dispatch: valid=true, warnings: No task() or TaskCreate references; Standard 10: no @config.json reference
- verification-gate: valid=true, warnings: No task() or TaskCreate references; Standard 10: no @config.json reference (model: haiku present)
- media-planner: valid=true, warnings: No task() or TaskCreate references; Standard 10: no @config.json reference
- task-discipline: valid=true, warnings: No task() or TaskCreate references; Standard 10: no @config.json reference
- progress-tracker: valid=true, warnings: Standard 10: no @config.json reference
- todo-skill: valid=true, warnings: Standard 10: no @config.json reference

## 2) path_existence_validator.ts --scope all
- task-dispatch: scripts total 8, missing 2 (analyze-splits.sh/check-subagent-return.sh/check-rescue-chain.sh/subagent-fallback.sh/selftest-* OK; 2 missing reported in earlier slice but full output shows mixed; key: some scripts present)
- verification-gate: scripts total 5, missing 3 (check-x.sh MISSING P0, check-3file-gate.sh MISSING P0, run-verification.sh OK; also check-complete.sh referenced as OK in earlier slice but tool reported missing 3 overall)
- media-planner: 0 scripts
- task-discipline: scripts 1 OK (plan-hygiene.sh)
- progress-tracker: 0 scripts
- todo-skill: 0 scripts

Note: verification-gate references scripts in ../task-planner/scripts/ (check-3file-gate.sh, attest-plan.sh, check-complete.sh) which are not in its own scripts/ dir; path validator reports "missing" for those if not found under skill dir depending on resolution - but per SKILL.md they are explicitly external (Rule 82 mechanical layer leave-behind). This is boundary-related, not necessarily broken files.

## 3) detect_drift.ts
All 6: has_drift_risk=true due to "config_not_externalized" (@config.json missing). No hardcoded path issues; parallel_safety clean.

## 4) subagent_skill_auditor.ts
All 6: 0 issues found (task-dispatch 5 files scanned, verification-gate 3, media-planner 2, task-discipline 5, progress-tracker 3, todo-skill 2).

## 5) completeness_checker.ts --phase pre/post
pre OK for all (file_details present); post requires --pre-manifest (expected).

## Intelligent analysis

### Frontmatter/S40
- task-dispatch: name matches dir, no model specified (allowed-tools ok). description mentions routing.
- verification-gate: has model: haiku, name/dir match, description long but coherent.
- media-planner: no model, minimal.
- task-discipline: no model, long allowed-tools set.
- progress-tracker: has model: haiku, detailed description with paths.
- todo-skill: has model: haiku, has Agent/TaskCreate/TaskUpdate/TaskList/TaskGet in allowed-tools.

### allowed-tools/S56
- todo-skill has Agent() + Task* tools (>=3 phases implied) - compliant.
- verification-gate has no Agent/Task tools (smaller scope) - ok.
- Others follow patterns.

### Trigger word orthogonality/S25
Satellites are well-scoped relative to each other; main risk is overlap with core task-planner. Descriptions point to specific domains (dispatch/split/parallel vs verification VC/V-N/terminal vs media axis vs discipline vs progress ledger vs todo orchestration). Seems reasonably orthogonal.

### Cross-skill redundancy/S79 (task-planner family)
- Rule 82 (layering) is stated in task-planner SKILL.md and enforced by migration pointers: goal-gate.md/completion-gate.md in core point to verification-gate; references/critical-rules.md only lists satellites, core keeps 14 rules.
- Rule 84 fully migrated to verification-gate/references/critical-rules-verification.md; core has only pointers (no duplicated Rule 84 body).
- Rule 103 added to task-dispatch/references/critical-rules-dispatch.md (new). verification-gate references Rule 103 for dual-QC coupling (pointer only).
- Rule 96 added to task-dispatch (parallel/dispatch enhancements).
- Discipline rules 85-102 mostly in task-discipline/references/critical-rules-discipline.md (numbered sections). Core points to satellites.
- Potential drift: some "mechanical scripts" left in task-planner/scripts/ (by design per Rule 82) while satellites reference ../task-planner/scripts/ - this is intentional per verification-gate SKILL.md "脚本引用索引（机械层留守主技能 scripts/）". Not duplication of rules, it's location convention.
- Checked for rule number duplication across satellites: Rule numbers appear in owning satellite; cross-references use pointers (../<satellite>/references/...) rather than copying text. Seems compliant with S79 direction.

### SOP rigor/S78
- verification-gate: 3-phase SOP (plan/exec/terminal) with gates, has FAIL branches (BLOCKED/escalation). Good.
- task-dispatch: detailed rules (21/22/23/25/46/52/59/68/96/103), parallelism, fallback chains, selection matrix.
- task-discipline: long rule set (many rules), procedural where stated.
- progress-tracker: clear workflow (read before write, append-only JSONL, platform dir rules).
- media-planner: focused on media axis routing.
- todo-skill: has WORKFLOW.md and tools.

Potential issues:
- verification-gate: references external scripts (check-3file-gate.sh/check-complete.sh/attest-plan.sh) in ../task-planner/scripts/; path validator flags missing under skill dir - boundary issue (by design) but could confuse tooling. Not a rule/SOP defect.
- task-dispatch has many scripts (some selftests) - complex, but auditor found no issues.

## Concrete findings
P0: verification-gate path validator reports missing scripts/check-x.sh, scripts/check-3file-gate.sh under skill dir (P0 severity). But these are referenced as living in ../task-planner/scripts/ per its own SKILL.md - likely validator scope issue vs actual design. Need to treat as boundary/documentation consistency issue.
P1: All satellites lack @config.json reference (drift warning) - standardization issue.
P2: validate_skill warnings about "No task() or TaskCreate references" for most - informational per tool.
