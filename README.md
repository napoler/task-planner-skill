# task-planner

> **Filesystem-driven task planning for AI agents. Persist plans across context resets, parallelize across subagents, and gate completion with explicit verification contracts.**

A Claude Code / OpenCode Skill that replaces volatile context-window planning with markdown files on disk. Inspired by [Manus](https://manus.im)'s context-engineering principles, extended for multi-task parallelism, scope-guard hooks, and a verification contract (VC) gate that turns "done" into something falsifiable.

---

## Why?

LLMs forget. After ~50 tool calls the original goal drifts, instructions compete, and the agent starts "solving" problems that no longer exist. This skill makes the plan a first-class artifact on disk — so:

- **Plans survive `/clear`** — every phase, decision, error, and verification step lives in `plans/task-XXX/`
- **Phases are gated, not narrated** — each phase flips from `pending` → `in_progress` → `complete` only when its verification contract (VC) passes
- **Scope is enforced by hooks** — a PreToolUse hook blocks writes outside the active plan directory; you can't accidentally edit random files
- **Subagents are real, not narrated** — when a subagent reports "done", the skill verifies the file actually changed before accepting it
- **Multiple tasks run in parallel** — spawn N subagents, each with their own plan subdirectory, coordinated via a shared `plans/INDEX.md`

This is an upgrade of the original "Plan with Files" pattern with three concrete improvements: parallel-task support, scope-guard enforcement, and a hard verification gate.

---

## Features

| Feature | What it does |
|---------|-------------|
| **Phase-based planning** | `task_plan.md` tracks Phases with explicit status (pending/in_progress/complete) |
| **Verification Contract (VC)** | Objective, falsifiable success criteria; nothing is "done" until every VC passes |
| **Scope Guard hook** | PreToolUse blocks writes outside the active plan; non-interactive shells can't escape scope |
| **Persistent working memory** | `findings.md`, `progress.md`, `notepad-learnings.md` survive context resets |
| **Multi-task parallelism** | Spawn N subagents, each owns `plans/task-XXX-*`; coordinator tracks `plans/INDEX.md` |
| **Subagent verification** | "Done" from a subagent is verified by Read before acceptance (completion-gate rule) |
| **Config-driven thresholds** | `config.json` centralizes `max_vc`, `retry_count`, `escalation_threshold`, etc. |
| **Recovery via session-catchup** | Detects partial plans from a previous session and resumes |
| **Project template override** | Drop a `.claude/plan-templates/` in your project to override built-in templates |
| **Cross-platform** | Scripts work on Linux/macOS/WSL; PowerShell mirrors for native Windows |

---

## Quick Start

### 1. Install (one command)

```bash
git clone https://github.com/napoler/task-planner-skill.git
cd task-planner-skill
bash scripts/install.sh
```

Default target: `~/.claude/skills/task-planner/`. Override with `--target DIR`.

### 2. Verify the install

```bash
bash scripts/validate.sh
# expected: VALIDATION PASSED
```

### 3. Restart Claude Code, then invoke

Ask Claude to "plan a multi-step task" or use the Skill tool directly:

```
/skill task-planner
```

Claude will:
1. Run `session-catchup.py` (detect any leftover plans)
2. Create `plans/task-001/` and run `init-session.sh`
3. Show you the plan and wait for your "yes"
4. Execute phase by phase, marking progress in the plan file
5. At the end, verify each VC item and report COMPLETE / PARTIAL / BLOCKED

### 4. Want it installed automatically by your AI?

Point your LLM at `INSTALL.md`. It contains a single bash block any LLM can emit verbatim to install the skill — see the **LLM Auto-Install** section.

---

## Project Structure

```
task-planner-skill/
├── README.md                      ← you are here
├── INSTALL.md                     ← install instructions (LLM + manual)
├── CHANGELOG.md                   ← version history
├── CONTRIBUTING.md                ← dev setup & PR rules
├── LICENSE                        ← MIT
├── CLAUDE.md                      ← Claude Code guidance for this repo
│
├── scripts/                       ← installation / validation tooling
│   ├── install.sh                 ← one-click installer
│   ├── uninstall.sh               ← safe removal
│   └── validate.sh                ← post-install integrity check
│
├── examples/
│   └── full-workflow.md           ← end-to-end walkthrough
│
└── skills/task-planner/           ← the actual skill package (mirrored to ~/.claude/skills/)
    ├── SKILL.md                   ← entry point: frontmatter + workflow
    ├── config.json                ← all thresholds (max_vc, retry_count, ...)
    ├── reference.md               ← Manus principles + decision matrix
    ├── examples.md                ← worked examples
    ├── scripts/
    │   ├── init-session.sh        ← bootstrap plans/task-XXX/
    │   ├── check-scope.sh         ← PreToolUse hook: scope guard
    │   ├── sync-todos.sh          ← phase status ↔ TodoWrite sync
    │   ├── check-complete.sh      ← Stop hook: aggregate phase state
    │   ├── check-complete.ps1     ← Windows mirror
    │   ├── init-session.ps1       ← Windows mirror
    │   ├── session-catchup.py     ← cross-session recovery
    │   └── sync-ide-folders.ts    ← IDE workspace sync
    ├── templates/
    │   ├── task_plan.md           ← phase + VC template
    │   ├── verification.md        ← VC + phase gate template
    │   ├── findings.md            ← discoveries + decisions
    │   ├── progress.md            ← session log
    │   └── notepad-learnings.md
    └── references/
        ├── critical-rules.md      ← Rules 1-10 execution constraints
        ├── completion-gate.md     ← subagent verification protocol
        ├── goal-gate.md           ← COMPLETE / PARTIAL / BLOCKED criteria
        └── billing.md             ← cost model
```

---

## The Planning Loop (Quick Mental Model)

```
User task
   │
   ▼
session-catchup.py     ← resume if a previous session left partial plans
   │
   ▼
init-session.sh        ← creates plans/task-XXX/ with 5 template files
   │
   ▼
Fill task_plan.md      ← write Goal + Phases + VC + Scope
   │
   ▼
Show plan, wait "yes"  ← user confirms
   │
   ▼
For each phase:
   ├─ status: pending → in_progress
   ├─ execute
   ├─ status: in_progress → complete
   └─ sync-todos.sh --index (if multi-task)
   │
   ▼
After all phases:
   ├─ Re-verify each VC item
   └─ Output: COMPLETE / PARTIAL / BLOCKED
```

---

## Verification Contract (VC) — Why It Matters

Tasks are not done when the agent *says* they're done. They're done when an **objective** check passes. VC forces every plan to declare its completion criteria upfront:

```markdown
| # | Criterion | Verify | Evidence |
|---|-----------|--------|----------|
| VC-1 | README ≥3000 chars | wc -c README.md | README.md |
| VC-2 | install.sh exits 0 | bash install.sh --dry-run | stdout |
| VC-3 | validate.sh exits 0 | bash validate.sh | exit code |
| ... |
```

`max_vc` (default 5, in `config.json`) is the minimum count. `min_verification_per_phase` (default 2) ensures each phase has at least 2 sub-checks.

---

## Multi-Task Parallelism

For projects with multiple independent sub-features (e.g. "REST API with auth + CRUD + tests"):

```
plans/
├── INDEX.md                    ← coordinator tracks all tasks
├── task-001-auth/
│   ├── task_plan.md           ← auth agent owns this
│   ├── findings.md
│   └── ...
├── task-002-crud/
│   ├── task_plan.md           ← CRUD agent owns this
│   └── ...
└── task-003-tests/
    └── ...
```

Spawn one subagent per directory with the Skill tool; each runs its own phases; the coordinator reads `INDEX.md` to track aggregate progress. See `examples/full-workflow.md` for the orchestration pattern.

---

## 中文文档

[中文版 README](README_zh.md) · [中文版安装指南](INSTALL_zh.md) · [中文版贡献指南](CONTRIBUTING_zh.md)

---

## Documentation Map

| Doc | When to read |
|-----|-------------|
| `INSTALL.md` | Installing the skill — LLM auto-install block + manual instructions for Linux/macOS/WSL/Windows |
| `examples/full-workflow.md` | End-to-end walkthrough: from user request to COMPLETE |
| `skills/task-planner/examples.md` | Concrete examples inside the skill package |
| `skills/task-planner/reference.md` | Manus context-engineering principles + decision matrix |
| `skills/task-planner/references/critical-rules.md` | Rules 1-10 — must read before customizing |
| `skills/task-planner/references/goal-gate.md` | How VC gates work, COMPLETE/PARTIAL/BLOCKED rules |
| `skills/task-planner/references/completion-gate.md` | How subagent verification works |
| `CONTRIBUTING.md` | Dev setup, script rules, PR checklist |

---

## Configuration

All runtime thresholds live in `skills/task-planner/config.json`. Edit and re-install:

```json
{
  "max_vc": 5,                          // min VC items per plan
  "min_verification_per_phase": 2,      // min checks per phase
  "retry_count": 3,                     // max retries before escalate
  "max_tool_calls_before_refresh": 5,   // re-read task_plan.md after N calls
  "max_view_browser_before_save": 2,    // write findings.md every 2 view ops
  "escalation_threshold": 3,            // consecutive fails → AskUserQuestion
  "plan_dir_pattern": "plans/{task-id}/",
  "template_priority": ["project-level", "built-in"]
}
```

`$schema` enforces `additionalProperties: false` — typos break validation loudly.

---

## License

MIT — see [`LICENSE`](LICENSE).

---

## Contributing

PRs welcome. See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the dev loop. The skill logic lives in `skills/task-planner/`; the installer/validator/uninstaller live in `scripts/` at repo root. Do not modify either without reading its reference docs first.
