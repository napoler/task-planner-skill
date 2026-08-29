# Task Plan: task-planner-skill v2 Polish & One-Click Install

## Goal
Take `/mnt/data/dev/task-planner-skill` from a bare skill copy to a distribution-ready, installable package: comprehensive README + INSTALL (LLM auto-install + manual) + one-click `install.sh` + validate/uninstall + supporting docs (CHANGELOG, CONTRIBUTING, full workflow example), so that any user (human or LLM) can install and use the skill in one command.

## Verification Contract (goal-completion criteria — all pass = COMPLETE)

| # | Criterion | How to verify | Evidence path / command |
|---|-----------|---------------|-------------------------|
| VC-1 | `README.md` exists at repo root, ≥3000 chars, covers intro/features/install links/usage/license | `wc -c README.md` + content check | `/mnt/data/dev/task-planner-skill/README.md` |
| VC-2 | `INSTALL.md` exists, contains both "LLM Auto-Install" and "Manual Install" sections with copy-pasteable commands for Linux/macOS/Windows + WSL | `grep -E "LLM Auto-Install\|Manual Install" INSTALL.md` | `/mnt/data/dev/task-planner-skill/INSTALL.md` |
| VC-3 | `scripts/install.sh` exists, `+x`, syntactically valid, supports `--target DIR` and `--dry-run`, exits 0 on simulated install | `bash -n` + dry-run test | `/mnt/data/dev/task-planner-skill/scripts/install.sh` |
| VC-4 | `scripts/validate.sh` exists, `+x`, syntactically valid, exits 0 when run against the repo itself | `bash -n` + self-run | `/mnt/data/dev/task-planner-skill/scripts/validate.sh` |
| VC-5 | `scripts/uninstall.sh` exists, `+x`, syntactically valid, `--dry-run` shows what would be removed | `bash -n` + dry-run test | `/mnt/data/dev/task-planner-skill/scripts/uninstall.sh` |
| VC-6 | `CHANGELOG.md` exists with version history; `CONTRIBUTING.md` exists with dev workflow; `examples/full-workflow.md` exists | `ls` each file + content size check | repo root |
| VC-7 | All existing skill files (SKILL.md, config.json, scripts/, templates/, references/) remain functionally identical — no skill logic changes | `diff -r` against pre-task snapshot | `diff -r /tmp/snapshot-pre/ skills/` |
| VC-8 | `validate.sh` end-to-end passes when run against the installed skill at `~/.claude/skills/task-planner` | execute validate against installed path | `bash scripts/validate.sh ~/.claude/skills/task-planner; echo $?` |
| VC-9 | A simulated LLM auto-install prompt block in INSTALL.md works: copy-paste into a fresh shell installs the skill and `ls -la ~/.claude/skills/task-planner/SKILL.md` succeeds | dry-run install to `/tmp/test-target/` + `ls` check | `/tmp/test-target/SKILL.md` |

**Exit rules**:
- All VC pass → **COMPLETE**
- VC pass but known gaps → **PARTIAL** (list + next-step suggestions)
- ≥1 VC fail after 3 retries → **BLOCKED** (escalate)

## Execution Scope (forced — only operate on listed files)

| Category | Allowed files | Forbidden |
|----------|---------------|-----------|
| Docs (new) | `README.md`, `INSTALL.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `examples/full-workflow.md` | other docs |
| Scripts (new) | `scripts/install.sh`, `scripts/validate.sh`, `scripts/uninstall.sh` | other scripts |
| Skill package | `skills/task-planner/**` (read-only reference, copy to snapshot) | any modification |
| Test artifacts | `/tmp/test-target/`, `/tmp/snapshot-pre/` | any other path |

**Pre-execution self-check**:
- [ ] File in list above?
- [ ] Modification necessary for goal?
- [ ] User explicitly requested?
- All Yes → proceed | any No → ask user first

## Core Problem Definition

**Core problem**: This repo is a bare skill directory with a 200-byte README — a new user (human or LLM) has no clear path to install or use it. Fixing this = shipping the project.

- [x] Once the gap is filled, the project becomes installable and distributable.
- [x] If the gap remains unfilled, no other value can be delivered (no one can use what they can't install).
- [x] Solution path is clear: add the standard distribution files + install scripts.

## Current Phase
Phase 5 (Delivery — complete)

## Phases

### Phase 1: Requirements & Discovery
- [x] Anchor user intent (LLM auto-install + manual + one-click + thorough gaps)
- [x] Inventory current repo contents
- [x] Inspect installed skill at `~/.claude/skills/task-planner` for behavior reference
- [x] Document gaps in findings.md
- **Status:** complete

### Phase 2: Plan & Structure
- [x] Define file layout (README + INSTALL + 3 scripts + 3 docs)
- [x] Define install.sh contract (detect platform, validate target, copy, chmod, register, validate)
- [x] Record decisions in this file
- **Status:** complete

### Phase 3: Implementation
- [x] Snapshot current skill (read-only reference copy at `/tmp/snapshot-pre/`)
- [x] Write `README.md` (intro, features, install links, quick start, structure, license)
- [x] Write `INSTALL.md` (LLM Auto-Install prompt block + Manual for Linux/macOS/WSL/Windows + troubleshooting)
- [x] Write `scripts/install.sh` (--target, --dry-run, --force; Linux+macOS+WSL; copies to ~/.claude/skills/task-planner or custom)
- [x] Write `scripts/validate.sh` (checks all scripts syntax, JSON schema, file presence, executable bits, template integrity)
- [x] Write `scripts/uninstall.sh` (--target, --dry-run, --force; removes skill dir)
- [x] Write `CHANGELOG.md` (v2.0.0 entry describing this polish)
- [x] Write `CONTRIBUTING.md` (dev setup, script rules, PR checklist)
- [x] Write `examples/full-workflow.md` (end-to-end plan-execute-verify walkthrough)
- [x] Add `.gitignore` (pycache, OS noise, tool caches)
- **Status:** complete

### Phase 4: Testing & Verification
- [x] `bash -n` every new shell script
- [x] Dry-run install.sh to `/tmp/test-target/`, then `ls` files, diff structure
- [x] Run validate.sh against the repo itself (exit 0 expected)
- [x] Run validate.sh against installed path `~/.claude/skills/task-planner` (exit 0 expected)
- [x] Verify skill at `~/.claude/skills/task-planner` still matches snapshot (no logic change)
- [x] Walk through VC table; record evidence in progress.md
- **Status:** complete

### Phase 5: Delivery
- [x] Review all output files (cat + wc + grep)
- [x] `git status` + `git diff --stat` summary
- [x] Deliver summary to user with file list + verification evidence
- **Status:** complete

## Key Questions
1. What install methods must be supported? → Linux/macOS native + WSL + Windows PowerShell (mirror via .ps1 if time permits)
2. Should install.sh auto-detect Claude Code vs OpenCode skill paths? → Yes: default to `~/.claude/skills/`, allow override via `--target`
3. Should installer register the skill anywhere outside the file system? → No — Claude Code/OpenCode auto-discover skills in `~/.claude/skills/<name>/SKILL.md`
4. How does LLM auto-install work? → INSTALL.md contains a single copy-pasteable bash block an LLM can emit verbatim on request
5. Should we touch skill files? → NO — read-only snapshot only. Skill logic is out of scope for this polish pass.

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Add distribution files only; don't modify skill logic | User said "polish & install" — "install" means packaging, not altering the skill's runtime behavior |
| Use `~/.claude/skills/task-planner/` as default install target | Claude Code's official skill discovery path |
| Single `install.sh` (bash) + mirror `install.ps1` deferred | Bash covers Linux/macOS/WSL (most users); PowerShell mirror is a follow-up if requested |
| validate.sh runs against any path, defaults to repo root | Reusable both pre-install (validate source) and post-install (validate target) |
| uninstall.sh requires `--force` for non-dry-run | Prevents accidental removal; mirrors install.sh safety |
| README vs INSTALL split | README = project overview + quick link; INSTALL = complete install instructions (LLM + manual) per project convention |
| Snapshot skill to `/tmp/snapshot-pre/` before changes | Provide diff-able evidence skill files unchanged (VC-7) |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
| (none yet) | 1 | — |

## Notes
- Update phase status: pending → in_progress → complete
- Re-read this plan before each phase boundary
- Log ALL errors, even transient
- Don't repeat a failed action — mutate the approach
- Skill files (`skills/task-planner/**`) are READ-ONLY reference; touching them = scope drift
