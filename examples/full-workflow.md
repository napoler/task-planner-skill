# Full Workflow: From Request to COMPLETE

A concrete, end-to-end walkthrough of how `task-planner` goes from "user asks a question" to "verifiable deliverable".

---

## Scenario

> "Research the trade-offs between SQLite vs PostgreSQL for a small internal tool, then write a comparison document."

A 3-phase task: research → synthesize → write.

---

## Step 1: Install the Skill

```bash
git clone https://github.com/napoler/task-planner-skill.git
cd task-planner-skill
bash scripts/install.sh
```

Verify:

```bash
bash scripts/validate.sh
# → VALIDATION PASSED
```

Restart Claude Code.

---

## Step 2: Ask Claude to Plan

> "Plan a research task comparing SQLite vs PostgreSQL for an internal tool."

Claude (running the task-planner skill) does:

```
1. session-catchup.py — no leftover plans found.
2. mkdir -p plans/task-001/ && bash scripts/init-session.sh task-001
3. Write plans/task-001/task_plan.md with filled-in content
4. Present the plan to you
```

The plan looks like this:

```markdown
# Task Plan: SQLite vs PostgreSQL Comparison

## Goal
Produce a comparison document (findings.md + final_summary.md) with
SQLite vs PostgreSQL trade-offs for a small internal tool.

## Verification Contract
| # | Criterion | Verify | Evidence |
|---|-----------|--------|----------|
| VC-1 | findings.md ≥ 1500 chars | wc -c findings.md | plans/task-001/findings.md |
| VC-2 | final_summary.md exists with 5 sections | grep | plans/task-001/final_summary.md |
| VC-3 | at least 3 SQLite sources cited | grep | final_summary.md |
| VC-4 | at least 3 PostgreSQL sources cited | grep | final_summary.md |
| VC-5 | no hallucinated benchmarks | manual check | final_summary.md |

## Phases
### Phase 1: Research
- [ ] Search SQLite docs and community benchmarks
- [ ] Search PostgreSQL docs and community benchmarks
- [ ] Document findings in findings.md
- Status: in_progress

### Phase 2: Synthesize
- [ ] Compare features side-by-side
- [ ] Identify trade-offs relevant to small internal tool
- Status: pending

### Phase 3: Write
- [ ] Draft final_summary.md with 5 sections
- [ ] Verify VC-2 through VC-5
- Status: pending
```

Claude asks: **"Does this plan look correct? Reply yes to start."**

You: **yes**.

---

## Step 3: Execute Phase 1 (Research)

Claude:

```
phase: pending → in_progress
# runs research operations
# writes to findings.md
phase: in_progress → complete
```

The PreToolUse hook runs on every Write:

```bash
bash scripts/check-scope.sh Write "plans/task-001/findings.md" "plans/task-001/task_plan.md"
# exit 0 → write allowed
```

Claude writes findings.md:

```markdown
# Findings: SQLite vs PostgreSQL

## SQLite
- Embedded, zero-config, single-file DB
- Good for: local tools, offline apps, small datasets
- Source: https://sqlite.org/docs.html

## PostgreSQL
- Client-server, full SQL, advanced features
- Good for: multi-user, complex queries, replication
- Source: https://www.postgresql.org/docs/
...
```

---

## Step 4: Execute Phase 2 (Synthesize)

Claude compares, documents trade-offs in findings.md:

```markdown
## Trade-offs for Small Internal Tool

| Aspect | SQLite | PostgreSQL |
|--------|--------|------------|
| Setup | None | Install + config |
| Concurrency | Read-heavy OK | Full |
| Size limit | ~2 TB (pract. 100 GB) | Unlimited |
| Language binding | Built-in | libpq / drivers |
```

---

## Step 5: Execute Phase 3 (Write + Verify)

Claude drafts `final_summary.md` and runs VC checks:

```bash
wc -c plans/task-001/findings.md    # ≥ 1500 ✓
grep "## " plans/task-001/final_summary.md  # ≥ 5 sections ✓
grep -c "SQLite" plans/task-001/final_summary.md  # ≥ 3 ✓
grep -c "PostgreSQL" plans/task-001/final_summary.md  # ≥ 3 ✓
```

Claude then reads `verification.md` and marks each VC as PASS.

---

## Step 6: Deliver

Claude outputs:

```
outcome: COMPLETE

## Deliverables
- plans/task-001/task_plan.md      (this plan, now complete)
- plans/task-001/findings.md       (raw research)
- plans/task-001/final_summary.md  (final comparison document)
- plans/task-001/verification.md   (VC pass/fail evidence)
```

The user can inspect any of those files.

---

## What If Something Fails?

### A VC fails

Claude retries once, updates findings.md, re-checks. If the same VC still fails after 3 retries (`retry_count` in `config.json`), Claude marks it **BLOCKED** and asks the user for a decision.

### You say "no" to the plan

Claude revises the plan. The phase stays at `pending` — no execution happened yet, so nothing to roll back.

### You want to add a phase mid-execution

Claude halts, updates `task_plan.md` (adds phase), re-shows the plan, waits for a new "yes". All existing phases remain at their current status.

### Session crashes / `/clear` between phases

On the next session, Claude runs `session-catchup.py` first. It finds `plans/task-001/task_plan.md` with Phase 2 still `in_progress` and resumes from Phase 2. No duplicate work.

---

## Parallel Multi-Task Example

**User request:** "Build a REST API with auth, CRUD endpoints, and tests."

Claude creates three sub-tasks:

```
plans/
├── INDEX.md
├── task-001-auth/
│   ├── task_plan.md
│   ├── findings.md
│   └── verification.md
├── task-002-crud/
│   ├── task_plan.md
│   └── ...
└── task-003-tests/
    └── ...
```

Each subagent gets its own plan directory. The coordinator runs `sync-todos.sh --index` after each phase completes so `INDEX.md` stays current.

See `reference.md § Parallel Tasks` for the orchestration pattern.

---

## Files Produced by This Workflow

| File | Who writes it | What it contains |
|------|---------------|-----------------|
| `plans/task-XXX/task_plan.md` | Claude (at start) | Plan, phases, VC, scope |
| `plans/task-XXX/findings.md` | Claude (during research) | Discoveries, sources, decisions |
| `plans/task-XXX/progress.md` | Claude (continuously) | Session log with timestamps |
| `plans/task-XXX/verification.md` | Claude (after each phase) | VC pass/fail per phase |
| `plans/task-XXX/notepad-learnings.md` | Claude (as needed) | Retrospective notes |
| `plans/INDEX.md` | Coordinator (multi-task) | Status of all parallel tasks |
| `final_summary.md` | Claude (deliverable) | The actual output artifact |

---

## TL;DR

```
Request → plan → confirm → execute phase → verify VC → repeat → COMPLETE
                                  ↕
                          session-catchup resumes if interrupted
```

The plan is the single source of truth on disk. The agent never "forgets" because it reads `task_plan.md` at every phase boundary.
