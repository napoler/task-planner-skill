# Install task-planner

Two paths: **LLM Auto-Install** (copy a block into your AI's prompt) or **Manual Install** (you run the commands). Both end at the same place: `~/.claude/skills/task-planner/SKILL.md` (or a custom target).

> **What you get:** the `task-planner` Skill is auto-discovered by Claude Code / OpenCode from `~/.claude/skills/<name>/SKILL.md`. After install, just restart Claude Code and ask it to plan a multi-step task.

---

## LLM Auto-Install

**For AI agents (or humans asking their AI)**: copy-paste the block below into your LLM. It will install the skill in one shell call, validate, and report.

```bash
# Install the task-planner skill in one command.
# Run this in any shell; it installs to ~/.claude/skills/task-planner/ by default.
set -e
TMP=$(mktemp -d)
git clone --depth 1 https://github.com/napoler/task-planner-skill.git "$TMP/repo"
cd "$TMP/repo"
bash scripts/install.sh
cd ~
rm -rf "$TMP"
echo "Installed. Restart Claude Code, then ask it to 'plan a multi-step task'."
```

> To use a local clone (after you've already cloned the repo):
>
> ```bash
> bash /path/to/task-planner-skill/scripts/install.sh
> ```

**Variants the LLM should know:**

```bash
# Install to a custom target (e.g. for testing)
bash scripts/install.sh --target /tmp/test-skill

# Dry run (shows what would happen, makes no changes)
bash scripts/install.sh --dry-run

# Uninstall later
bash scripts/install.sh --uninstall
# or directly:
bash scripts/uninstall.sh

# Re-validate an existing install
bash scripts/validate.sh ~/.claude/skills/task-planner
```

If the LLM hit `Permission denied` for `~/.claude/skills/`, it should use `--target "$HOME/.local/share/claude/skills/task-planner"` or any user-writable directory inside `$HOME`, then symlink or move it to `~/.claude/skills/task-planner/`.

---

## Manual Install

### Prerequisites

| Tool | Why | Check |
|------|-----|-------|
| `bash` ≥ 4 | All installer scripts are bash | `bash --version` |
| `python3` ≥ 3.8 | session-catchup.py + JSON validation | `python3 --version` |
| `git` | Cloning the repo | `git --version` |
| Write access to `~/.claude/skills/` | Install target | `mkdir -p ~/.claude/skills && test -w ~/.claude/skills` |

Optional:
- `node` + `npx` + `@types/node` — only if you want full TypeScript type-checks on `sync-ide-folders.ts`
- `jsonschema` Python module — only if you want stricter config-schema validation (`pip install jsonschema`)

### Linux / macOS / WSL

```bash
# 1. Clone
git clone https://github.com/napoler/task-planner-skill.git
cd task-planner-skill

# 2. (Optional) inspect what install.sh will do
bash scripts/install.sh --dry-run

# 3. Install to default location
bash scripts/install.sh

# 4. Validate
bash scripts/validate.sh

# 5. Restart Claude Code, then:
#    Ask Claude to "plan a multi-step task" or use the Skill tool.
```

#### Custom target

```bash
# Install under a different path (useful for sandboxing / multi-version)
bash scripts/install.sh --target "$HOME/.local/share/claude/skills/task-planner"

# Overwrite an existing install without prompting
bash scripts/install.sh --force --target ~/.claude/skills/task-planner
```

#### Verify

```bash
# The skill files should be present and executable
ls -la ~/.claude/skills/task-planner/SKILL.md
ls -la ~/.claude/skills/task-planner/scripts/*.sh

# Run the validator explicitly
bash scripts/validate.sh ~/.claude/skills/task-planner
# expected: VALIDATION PASSED
```

### Windows (native PowerShell)

> PowerShell mirrors (`init-session.ps1`, `check-complete.ps1`) exist inside the skill. The repo-level installer is bash-first. On native Windows, use **WSL** (recommended) or Git Bash. If you must stay in PowerShell:

```powershell
# From PowerShell, after cloning the repo:
git clone https://github.com/napoler/task-planner-skill.git
cd task-planner-skill

# Use Git Bash to run the installer (Git Bash is bundled with Git for Windows)
& "C:\Program Files\Git\bin\bash.exe" scripts/install.sh --target $HOME\.claude\skills\task-planner

# Validate the same way
& "C:\Program Files\Git\bin\bash.exe" scripts\validate.sh "$HOME\.claude\skills\task-planner"
```

#### WSL (recommended for Windows users)

WSL is the smoothest path on Windows — the bash scripts work unchanged.

```powershell
# In PowerShell, install WSL if needed:
wsl --install -d Ubuntu
```

```bash
# Inside WSL:
git clone https://github.com/napoler/task-planner-skill.git
cd task-planner-skill
bash scripts/install.sh
```

Claude Code inside WSL will discover the skill via `$HOME/.claude/skills/task-planner/SKILL.md` automatically.

---

## Updating

To upgrade an existing install to a newer version:

```bash
# From inside your local clone of task-planner-skill
git pull
bash scripts/install.sh --force   # overwrites existing target
bash scripts/validate.sh          # confirm
```

This preserves nothing inside the skill directory itself (the skill is stateless). Your **plans** in `plans/` are untouched — they're in your project directory, not the skill install path.

---

## Uninstalling

```bash
# Default target
bash scripts/uninstall.sh

# Custom target
bash scripts/uninstall.sh --target /path/to/skill

# Dry run first
bash scripts/uninstall.sh --dry-run

# Skip the confirmation prompt
bash scripts/uninstall.sh --force
```

The uninstaller only touches the exact path you give it; other skills are untouched. If the parent directory becomes empty, you'll be asked whether to remove it too.

---

## Project Template Override

To override built-in templates for **this project only**, drop replacement markdown files in:

```
<your-project>/.claude/plan-templates/
    task_plan.md
    verification.md
    findings.md
    progress.md
    notepad-learnings.md
```

`init-session.sh` looks for the project-level folder first; falls back to the built-in templates if any are missing.

---

## Troubleshooting

### `Permission denied` writing to `~/.claude/skills/`

```bash
# Either pick a user-writable target:
bash scripts/install.sh --target "$HOME/.local/share/claude/skills/task-planner"

# Or fix the parent perms:
mkdir -p ~/.claude/skills
chmod u+rwX ~/.claude/skills
```

### `validate.sh` reports a TypeScript warning

This is expected if you don't have `@types/node` installed. The validator downgrades TS type errors to warnings; it does not block installation. To silence:

```bash
npm install --save-dev @types/node
```

### `bash: scripts/install.sh: No such file or directory`

You're not inside the cloned repo. `cd task-planner-skill` first, or pass an absolute path:

```bash
bash /absolute/path/to/task-planner-skill/scripts/install.sh
```

### Skill not discovered after install

1. Confirm the file exists: `ls ~/.claude/skills/task-planner/SKILL.md`
2. Restart Claude Code (or run `/clear`) — it scans the skills directory at startup
3. Verify the SKILL.md frontmatter has `name: task-planner` (case-sensitive)

### `config.json` schema validation fails

If you customized `config.json` and `validate.sh` reports schema errors:

```bash
python3 -c "
import json, jsonschema
schema = json.load(open('skills/task-planner/config.json'))
schema.pop('\$schema', None)
jsonschema.validate({}, schema)   # tests required/defaults
"
```

The schema enforces `additionalProperties: false` — extra keys break validation. Remove unknown keys or update the schema (with care).

---

## Verifying After Install (Smoke Test)

```bash
# 1. Skill present
test -f ~/.claude/skills/task-planner/SKILL.md && echo OK || echo MISSING

# 2. Scripts executable
for f in init-session.sh check-scope.sh sync-todos.sh check-complete.sh; do
  test -x ~/.claude/skills/task-planner/scripts/$f && echo "  $f: OK"
done

# 3. Validator passes
bash scripts/validate.sh ~/.claude/skills/task-planner

# 4. End-to-end: spin a test plan
mkdir -p /tmp/planner-smoke && cd /tmp/planner-smoke
bash ~/.claude/skills/task-planner/scripts/init-session.sh smoke-test
ls task_plan.md   # should exist
```

If any step fails, see Troubleshooting above.

---

## What Gets Installed, Exactly

```
~/.claude/skills/task-planner/
├── SKILL.md                       (entry point)
├── config.json                    (thresholds)
├── reference.md                   (Manus principles)
├── examples.md                    (worked examples)
├── scripts/
│   ├── init-session.sh            (bash + .ps1 mirror)
│   ├── init-session.ps1
│   ├── check-scope.sh
│   ├── sync-todos.sh
│   ├── check-complete.sh
│   ├── check-complete.ps1
│   ├── session-catchup.py
│   └── sync-ide-folders.ts
├── templates/
│   ├── task_plan.md
│   ├── verification.md
│   ├── findings.md
│   ├── progress.md
│   └── notepad-learnings.md
└── references/
    ├── critical-rules.md
    ├── completion-gate.md
    ├── goal-gate.md
    └── billing.md
```

Total: ~50 KB. Nothing else is written outside this directory.

---

## 中文版本

[中文安装指南](INSTALL_zh.md) · [中文版 README](README_zh.md)

---

## Next Steps

- See [`README.md`](README.md) for a feature overview and quick mental model.
- See [`examples/full-workflow.md`](examples/full-workflow.md) for an end-to-end walkthrough.
- See [`skills/task-planner/reference.md`](skills/task-planner/reference.md) for the design rationale.
