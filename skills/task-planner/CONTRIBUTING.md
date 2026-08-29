# Contributing to task-planner

Thanks for looking at this project. Here's how to work on it without stepping on the skill's runtime contract.

---

## Repo Layout

```
task-planner-skill/
├── CLAUDE.md                  # repo-level guidance (read this)
├── scripts/                   # installation / validation tooling (your entry point)
│   ├── install.sh
│   ├── uninstall.sh
│   └── validate.sh
├── examples/
│   └── full-workflow.md       # end-to-end walkthrough
├── skills/task-planner/       # THE SKILL — read-only reference during polish
│   ├── SKILL.md
│   ├── config.json
│   ├── scripts/               # existing scripts (do not add new ones here without reviewing)
│   ├── templates/
│   └── references/
└── plans/                     # workspace for planning your work (gitignored)
```

**Rule:** changes to the skill live in `skills/task-planner/`. Changes to packaging/install/validation live in repo-level `scripts/` and markdown files.

---

## Dev Loop

```bash
# 1. Set up
git clone <repo>
cd task-planner-skill

# 2. Quick sanity check on all scripts
bash -n scripts/*.sh
python3 -m py_compile skills/task-planner/scripts/session-catchup.py
node -e "require('typescript')" 2>/dev/null && npx tsc --noEmit scripts/sync-ide-folders.ts

# 3. Install the skill into your own environment for real testing
bash scripts/install.sh

# 4. Validate
bash scripts/validate.sh
# expected: VALIDATION PASSED

# 5. Make changes → re-install → re-validate
bash scripts/install.sh --force
bash scripts/validate.sh

# 6. Commit (conventional commits)
git add -p
git commit -m "feat(install): add --source flag to install.sh"
```

---

## Script Rules

### `scripts/*.sh`

- Bash, `set -euo pipefail` at the top.
- `--dry-run` is the safe default; `--force` overrides it.
- Exit codes: 0 success, 1 user error, 2 environment error, 3 validation failure.
- Never depend on Python or Node — shell scripts must run on a plain bash environment.
- After every edit: `bash -n path/to/script.sh` passes before committing.
- After every edit: test with `--dry-run` and `--force` before committing.

### `scripts/*.py`

- Python 3.8+ only. No third-party dependencies — the skill must install without `pip install`.
- If you need `jsonschema`, detect and warn; don't fail on ImportError.
- After every edit: `python3 -m py_compile path/to/script.py` passes before committing.

### `scripts/*.ts`

- Best-effort only. The skill runs without TypeScript; `sync-ide-folders.ts` is an optional enhancement.
- `@types/node` must not be a hard dependency.
- If CI has `tsc`, validate; otherwise skip silently.

### `templates/*.md`

- These are rendered into user workspaces by `init-session.sh`.
- Keep placeholders (`[task-id]`, `[Goal]`, etc.) but make them self-explanatory.
- Bilingual headings (English + Chinese) are encouraged for this project's audience.
- After every edit: run `bash scripts/install.sh` and spot-check the generated files.

### `references/*.md`

- Read-only reference docs that the skill agent reads during execution.
- Changing these may break existing plans — coordinate with a version bump.

---

## Commit Style

Conventional commits:

```
feat(install): add --dry-run flag to install.sh
fix(validate): downgrade TS type errors to warnings
docs: add CHANGELOG entry for v2.0.0
chore: update README quick-start block
```

Scope is one of: `install`, `validate`, `uninstall`, `skill`, `templates`, `docs`.

---

## PR Checklist

Before opening a PR:

- [ ] All new shell scripts pass `bash -n`.
- [ ] All new Python scripts pass `python3 -m py_compile`.
- [ ] `scripts/validate.sh` passes against the installed skill (exit 0).
- [ ] `scripts/install.sh --dry-run` and `--force` both succeed.
- [ ] `README.md` links to any new docs you added.
- [ ] `CHANGELOG.md` has an `[Unreleased]` entry describing your change.
- [ ] `CLAUDE.md` (if you change repo structure) stays consistent.
- [ ] No changes to `skills/task-planner/` unless explicitly part of the task (skill logic changes are in a separate concern).
- [ ] Commit message follows conventional commits.

---

## Testing End-to-End

The canonical test:

```bash
# Clean slate
rm -rf /tmp/test-skill-install
bash scripts/install.sh --target /tmp/test-skill-install
bash scripts/validate.sh /tmp/test-skill-install

# Spin a real task plan
mkdir -p /tmp/test-plan && cd /tmp/test-plan
bash /tmp/test-skill-install/scripts/init-session.sh test-task
cat task_plan.md | head -30
# should contain: Goal, VC table, Phases, Scope

# Cleanup
rm -rf /tmp/test-skill-install /tmp/test-plan
```

If this passes, the PR is installable.

---

## Backward Compatibility

The skill's external interface is **the skill directory layout and frontmatter**. Don't change:

- The presence of `SKILL.md`, `config.json`, `templates/`, `scripts/`, `references/`.
- The frontmatter fields: `name`, `model`, `description`, `allowed-tools`, `hooks`.
- The `config.json` schema (`additionalProperties: false`).
- Existing scripts' CLI flags (add new flags with defaults; don't drop old ones).

Breaking changes belong in a major version bump and must be in `CHANGELOG.md` under `### Breaking`.

---

## Issues & Help

- File issues on GitHub with tag `bug`, `feature`, or `docs`.
- If you hit a validation failure, paste the full `validate.sh` output — it lists every check.
- If a script behaves differently on your OS, note the OS + bash version in the issue.

---

## License

By contributing, you agree to license your contributions under the project's MIT license.
