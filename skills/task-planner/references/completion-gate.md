# Completion Gate & Parallel Task Synchronization

> 详见 SKILL.md 的 "## 2.4 Completion Gate Protocol" 和 "## 2.5 Parallel Task Synchronization"。
> 本节为高级用法，日常规划只需关注 Critical Rules 即可。

## 2.4 Completion Gate Protocol (CRITICAL)

### The Rule
**Trust but Verify**: After any subagent returns "done", you MUST verify before marking complete.

### Step-by-Step Protocol

#### Step 1: Wait for Completion Notification
- Do NOT poll or busy-wait
- Wait for system notification that task is complete
- Use `background_output()` only after notification arrives

#### Step 2: Read the Actual File Modified
- Read the file the subagent claimed to modify
- Verify the specific change claimed was actually made
- Example: If agent said "removed review-style content", grep for the old phrase

#### Step 3: Mark Complete Only After Verification
- If verified: Use `Edit` to update plan file checkbox `- [ ]` → `- [x]`
- If NOT verified: Resume subagent session with "fix: [specific issue]"

### Evidence Requirements
Claims of "done" without concrete evidence = FAILED verification.
Evidence must include:
- File path and line numbers of changes
- Verification output (command results, file contents)
- Before/after comparison when applicable

### Example Verification Commands

```bash
# Verify title length
python3 -c "import json; d=json.load(open('article.json')); print(len(d['title']))"

# Verify no Chinese characters
python3 -c "import json; d=json.load(open('article.json')); assert not any(ord(c) > 127 for c in d['content']), 'Chinese found'"

# Verify image added
grep -c "image" article.json

# Verify specific text removed
grep -v "old-phrase" article.json || echo "Not found (good)"
```

### Verification Checklist
Before marking any task complete:
- [ ] File exists at claimed path
- [ ] Specific change mentioned in subagent output is present in file
- [ ] No unintended modifications (check git diff)
- [ ] If verification fails: do NOT mark complete, instead resume subagent session

## 2.5 Parallel Task Synchronization

### Launching Parallel Tasks
When launching multiple parallel tasks:

```bash
# Launch ALL tasks with run_in_background=true
task(task_id="bg_task1", run_in_background=true, ...)
task(task_id="bg_task2", run_in_background=true, ...)
task(task_id="bg_task3", run_in_background=true, ...)
task(task_id="bg_task4", run_in_background=true, ...)
```

### Session ID Storage (CRITICAL)
- **Before starting ANY parallel task**: Store the current session_id for continuation
- **Never start a new task without storing previous session_id**
- Use session_id to retrieve results after background tasks complete
- Pattern: `session_id=<current-session>` passed to each background task

### Synchronization Barrier
After launching parallel tasks:

1. **Wait for ALL notifications** - Do NOT proceed until every `bg_*` task completes
2. **Collect results** - Use `background_output()` for each completed background task
3. **Verify each result** - Read files, run verification commands per task
4. **Update plan file** - Mark checkboxes only after verification for each task
5. **Only then proceed** - to dependent wave

### Wave Dependency Rule
```
Wave 1 (parallel) → [ALL verified complete] → Wave 2 (sequential)
                    ↑
           Cannot skip, cannot rush
```

### Wave Transition Checklist
Before starting Wave N tasks:
- [ ] All Wave N-1 tasks marked `[x]` in plan file
- [ ] Verification evidence documented for each completed task
- [ ] No pending `bg_*` notifications from previous wave

### Error Handling in Parallel Tasks
- If any Wave 1 task fails verification: DO NOT proceed to Wave 2
- Log failure details, attempt fix via subagent session
- Only proceed when ALL Wave 1 tasks pass verification
