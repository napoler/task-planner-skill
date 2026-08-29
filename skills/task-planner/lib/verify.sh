#!/usr/bin/env bash
# lib/verify.sh — Verify multi-tool task-planner installation
#
# Usage:
#   verify_installation
#
# Checks:
#   1. Canonical source exists and has git history
#   2. Each detected tool has a stub
#   3. Stub scripts have no hardcoded zcode/claude paths
#   4. Stub SKILL.md is thin shell (not full content)
#   5. check-complete.sh runs OK (no plan = exit 0/2 acceptable)
#   6. check-doc-sync.sh runs OK
#   7. External references use ${TASK_PLANNER_ROOT} form
#
# Returns exit 0 if all pass; non-zero with summary if any fail.

set -u

: "${TASK_PLANNER_ROOT:?TASK_PLANNER_ROOT must be set}"

PASS=0
FAIL=0
FAILURES=()

pass() { PASS=$((PASS + 1)); echo "[verify] ✓ $1"; }
fail() { FAIL=$((FAIL + 1)); FAILURES+=("$1"); echo "[verify] ✗ $1"; }

verify_installation() {
  # shellcheck disable=SC1091
  source "${TASK_PLANNER_ROOT}/lib/detect-tools.sh"

  # 1. Canonical source
  if [ -d "$TASK_PLANNER_ROOT/.git" ] && [ -f "$TASK_PLANNER_ROOT/SKILL.md" ]; then
    pass "canonical source exists at $TASK_PLANNER_ROOT"
  else
    fail "canonical source missing or not a git repo: $TASK_PLANNER_ROOT"
  fi

  # 2. Each detected tool has stub
  if [ ${#TOOLS_DETECTED[@]} -eq 0 ]; then
    fail "no agent tools detected (checked: claude-code, zcode, opencode, cursor, continue)"
  else
    for tool in "${TOOLS_DETECTED[@]}"; do
      local stub="${TOOL_STUB_ROOT[$tool]}"
      if [ -d "$stub" ] && [ -f "$stub/SKILL.md" ]; then
        pass "$tool stub exists at $stub"
      else
        fail "$tool stub missing or incomplete: $stub"
      fi
    done
  fi

  # 3. Stub scripts: no hardcoded zcode/claude paths
  # Note: check-doc-sync.sh intentionally keeps zcode/claude fallback chain
  # in its `for _c in` block (line 30-36) for standalone-script use. Whitelist it.
  for tool in "${TOOLS_DETECTED[@]}"; do
    local stub="${TOOL_STUB_ROOT[$tool]}"
    if [ -d "$stub/scripts" ]; then
      # Find files with hardcoded paths, excluding the whitelisted fallback chain in check-doc-sync.sh
      local hardcoded
      hardcoded=$(grep -rlnE '\$HOME/\.zcode/skills/task-planner|\$HOME/\.claude/skills/task-planner' "$stub/scripts/" 2>/dev/null \
        | grep -v 'check-doc-sync\.sh$' || true)
      if [ -z "$hardcoded" ]; then
        pass "$tool scripts: no hardcoded paths (check-doc-sync.sh fallback chain whitelisted)"
      else
        fail "$tool scripts: hardcoded paths in $(echo "$hardcoded" | wc -l) files"
      fi
    fi
  done

  # 4. Stub SKILL.md is thin (should be < 15KB, not full canonical 20KB)
  for tool in "${TOOLS_DETECTED[@]}"; do
    local stub="${TOOL_STUB_ROOT[$tool]}"
    if [ -f "$stub/SKILL.md" ]; then
      local size
      size=$(wc -c < "$stub/SKILL.md")
      if [ "$size" -lt 15360 ]; then
        pass "$tool SKILL.md is thin shell ($size bytes)"
      else
        fail "$tool SKILL.md too large ($size bytes) — should be < 15KB"
      fi
    fi
  done

  # 5. check-complete.sh runs OK
  if [ -x "$TASK_PLANNER_ROOT/scripts/check-complete.sh" ]; then
    if bash "$TASK_PLANNER_ROOT/scripts/check-complete.sh" >/dev/null 2>&1; then
      pass "check-complete.sh runs OK"
    else
      fail "check-complete.sh returned non-zero"
    fi
  else
    fail "check-complete.sh not executable"
  fi

  # 6. check-doc-sync.sh runs OK (no plan = exit 2 acceptable)
  if [ -x "$TASK_PLANNER_ROOT/scripts/check-doc-sync.sh" ]; then
    local rc=0
    bash "$TASK_PLANNER_ROOT/scripts/check-doc-sync.sh" >/dev/null 2>&1 || rc=$?
    if [ "$rc" -eq 0 ] || [ "$rc" -eq 2 ]; then
      pass "check-doc-sync.sh runs OK (exit=$rc)"
    else
      fail "check-doc-sync.sh returned unexpected exit=$rc"
    fi
  else
    fail "check-doc-sync.sh not executable"
  fi

  # 7. External references migrated
  local unmigrated
  unmigrated=$(grep -rln 'bash ~/\.claude/skills/task-planner\|bash ~/\.zcode/skills/task-planner' \
    "$HOME/.claude/CLAUDE.md" "$HOME/.claude/commands/" 2>/dev/null | head -3)
  if [ -z "$unmigrated" ]; then
    pass "external references migrated to env-var form"
  else
    fail "external references still hardcoded: $unmigrated"
  fi

  # 8. Hooks actually registered per platform
  # Claude Code: must have hooks block in settings.local.json
  local claude_settings="$HOME/.claude/settings.local.json"
  if [ -d "${TOOL_STUB_ROOT[claude-code]:-}" ] && [ -f "$claude_settings" ]; then
    if grep -q 'task-plan-init\.cjs' "$claude_settings" 2>/dev/null; then
      pass "Claude Code: hooks registered in $claude_settings"
    else
      fail "Claude Code: settings.local.json missing task-planner hooks (run register-hooks-cj.ts)"
    fi
  fi
  # ZCode/OpenCode/Cursor: SKILL.md frontmatter must contain hooks: block
  for tool in zcode opencode cursor continue; do
    local stub="${TOOL_STUB_ROOT[$tool]:-}"
    [ -n "$stub" ] && [ -d "$stub" ] && [ -f "$stub/SKILL.md" ] || continue
    if grep -q '^hooks:' "$stub/SKILL.md" 2>/dev/null; then
      pass "$tool: hooks declared in SKILL.md frontmatter"
    else
      fail "$tool: SKILL.md missing hooks: block (run install.sh to regenerate)"
    fi
  done

  # Summary
  echo ""
  echo "[verify] summary: $PASS pass / $FAIL fail"
  if [ "$FAIL" -gt 0 ]; then
    echo "[verify] FAILED checks:"
    for f in "${FAILURES[@]}"; do
      echo "  - $f"
    done
    return 1
  fi
  return 0
}
