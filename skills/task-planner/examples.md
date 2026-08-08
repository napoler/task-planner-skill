# Examples: Planning with Files in Action

## Example 1: Research Task

**User Request:** "Research the benefits of morning exercise and write a summary"

### Loop 1: Create Plan
```bash
Write task_plan.md
```

```markdown
# Task Plan: Morning Exercise Benefits Research

## Goal
Create a research summary on the benefits of morning exercise.

## Phases
- [ ] Phase 1: Create this plan ✓
- [ ] Phase 2: Search and gather sources
- [ ] Phase 3: Synthesize findings
- [ ] Phase 4: Deliver summary

## Key Questions
1. What are the physical health benefits?
2. What are the mental health benefits?
3. What scientific studies support this?

## Status
**Currently in Phase 1** - Creating plan
```

### Loop 2: Research
```bash
Read task_plan.md           # Refresh goals
Skill("research-assistant", "morning exercise benefits")
Write findings.md              # Store findings
Edit task_plan.md           # Mark Phase 2 complete
```

### Loop 3: Synthesize
```bash
Read task_plan.md           # Refresh goals
Read findings.md               # Get findings
Write morning_exercise_summary.md
Edit task_plan.md           # Mark Phase 3 complete
```

### Loop 4: Deliver
```bash
Read task_plan.md           # Verify complete
Deliver morning_exercise_summary.md
```

---

## Example 2: Bug Fix Task

**User Request:** "Fix the login bug in the authentication module"

### task_plan.md
```markdown
# Task Plan: Fix Login Bug

## Goal
Identify and fix the bug preventing successful login.

## Phases
- [x] Phase 1: Understand the bug report ✓
- [x] Phase 2: Locate relevant code ✓
- [ ] Phase 3: Identify root cause (CURRENT)
- [ ] Phase 4: Implement fix
- [ ] Phase 5: Test and verify

## Key Questions
1. What error message appears?
2. Which file handles authentication?
3. What changed recently?

## Decisions Made
- Auth handler is in src/auth/login.ts
- Error occurs in validateToken() function

## Errors Encountered
- [Initial] TypeError: Cannot read property 'token' of undefined
  → Root cause: user object not awaited properly

## Status
**Currently in Phase 3** - Found root cause, preparing fix
```

---

## Example 3: Feature Development

**User Request:** "Add a dark mode toggle to the settings page"

### The 3-File Pattern in Action

**task_plan.md:**
```markdown
# Task Plan: Dark Mode Toggle

## Goal
Add functional dark mode toggle to settings.

## Phases
- [x] Phase 1: Research existing theme system ✓
- [x] Phase 2: Design implementation approach ✓
- [ ] Phase 3: Implement toggle component (CURRENT)
- [ ] Phase 4: Add theme switching logic
- [ ] Phase 5: Test and polish

## Decisions Made
- Using CSS custom properties for theme
- Storing preference in localStorage
- Toggle component in SettingsPage.tsx

## Status
**Currently in Phase 3** - Building toggle component
```

**findings.md:**
```markdown
# Findings: Dark Mode Implementation

## Existing Theme System
- Located in: src/styles/theme.ts
- Uses: CSS custom properties
- Current themes: light only

## Files to Modify
1. src/styles/theme.ts - Add dark theme colors
2. src/components/SettingsPage.tsx - Add toggle
3. src/hooks/useTheme.ts - Create new hook
4. src/App.tsx - Wrap with ThemeProvider

## Color Decisions
- Dark background: #1a1a2e
- Dark surface: #16213e
- Dark text: #eaeaea
```

**dark_mode_implementation.md:** (deliverable)
```markdown
# Dark Mode Implementation

## Changes Made

### 1. Added dark theme colors
File: src/styles/theme.ts
...

### 2. Created useTheme hook
File: src/hooks/useTheme.ts
...
```

---

## Example 4: Error Recovery Pattern

When something fails, DON'T hide it:

### Before (Wrong)
```
Action: Read config.json
Error: File not found
Action: Read config.json  # Silent retry
Action: Read config.json  # Another retry
```

### After (Correct)
```
Action: Read config.json
Error: File not found

# Update task_plan.md:
## Errors Encountered
- config.json not found → Will create default config

Action: Write config.json (default config)
Action: Read config.json
Success!
```

---

## The Read-Before-Decide Pattern

**Always read your plan before major decisions:**

```
[Many tool calls have happened...]
[Context is getting long...]
[Original goal might be forgotten...]

→ Read task_plan.md          # This brings goals back into attention!
→ Now make the decision       # Goals are fresh in context
```

This is why Manus can handle ~50 tool calls without losing track. The plan file acts as a "goal refresh" mechanism.

---

## Example 5: Multi-task Parallel Pattern

When a project has multiple independent sub-features, spawn parallel agents — each manages its own plan subdirectory.

**User Request:** "Build a REST API with auth, CRUD endpoints, and tests"

```
├── plans/task-001-auth/     (subagent: auth agent)
│   ├── task_plan.md
│   ├── verification.md
│   └── findings.md
├── plans/task-002-crud/     (subagent: CRUD agent)
│   ├── task_plan.md
│   ├── verification.md
│   └── findings.md
└── plans/INDEX.md           (main coordinator tracks both)
```

### Coordinator flow:
```
1. Read plans/INDEX.md → confirm both plans created
2. Agent(subagent_type="code-assistant", prompt="Run plans/task-001-auth/init-session.sh")
3. Agent(subagent_type="code-assistant", prompt="Run plans/task-002-crud/init-session.sh")
4. Wait for both → Read INDEX.md → sync
5. Execute Phase 1 of task-001-auth
6. Execute Phase 1 of task-002-crud (concurrent)
7. Run sync-todos.sh --index after each completed phase
8. Completion Gate: Read each plan's verification.md, verify all [x]
```

### Index entry format:
```markdown
## Active Tasks
| ID | Plan Path | Phase | Status | Last Update |
|----|-----------|-------|--------|-------------|
| task-001 | plans/task-001-auth/task_plan.md | 2 | in_progress | 2026-08-01 |
| task-002 | plans/task-002-crud/task_plan.md | 1 | in_progress | 2026-08-01 |
```

Parallel tasks share the same INDEX.md — the coordinator runs `sync-todos.sh --index` after every phase completion to keep track.
