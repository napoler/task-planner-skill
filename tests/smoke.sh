#!/usr/bin/env bash
# tests/smoke.sh — Smoke test for multi-tool task-planner installation
#
# Usage:
#   bash tests/smoke.sh [--canonical <path>]
#
# What it checks (lightweight, no destructive ops):
#   1. Canonical source has SKILL.md, references/, templates/, scripts/
#   2. lib/ scripts exist and are syntactically valid (bash -n)
#   3. install.sh / uninstall.sh are syntactically valid
#   4. check-complete.sh runs without error in a clean state
#   5. verify.sh reports canonical health
#
# Returns exit 0 if all pass, non-zero otherwise.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASK_PLANNER_ROOT="${TASK_PLANNER_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
export TASK_PLANNER_ROOT

PASS=0
FAIL=0
fail_msg() { echo "[smoke] ✗ $1"; FAIL=$((FAIL + 1)); }
pass_msg() { echo "[smoke] ✓ $1"; PASS=$((PASS + 1)); }

# 1. Canonical structure
for required in SKILL.md config.json references templates scripts lib install.sh; do
  if [ -e "$TASK_PLANNER_ROOT/$required" ]; then
    pass_msg "canonical has $required"
  else
    fail_msg "canonical missing $required"
  fi
done

# 2. lib scripts syntax
for f in "$TASK_PLANNER_ROOT/lib/"*.sh; do
  if bash -n "$f" 2>/dev/null; then
    pass_msg "syntax OK: $(basename "$f")"
  else
    fail_msg "syntax FAIL: $(basename "$f")"
  fi
done

# 3. install/uninstall syntax
for f in "$TASK_PLANNER_ROOT/install.sh" "$TASK_PLANNER_ROOT/uninstall.sh"; do
  if [ -f "$f" ] && bash -n "$f" 2>/dev/null; then
    pass_msg "syntax OK: $(basename "$f")"
  else
    fail_msg "syntax FAIL: $(basename "$f")"
  fi
done

# 4. check-complete.sh runs
if bash "$TASK_PLANNER_ROOT/scripts/check-complete.sh" >/dev/null 2>&1; then
  pass_msg "check-complete.sh runs OK"
else
  fail_msg "check-complete.sh failed"
fi

# 5. verify.sh reports health
VERIFY_OUT=$(mktemp)
( export TASK_PLANNER_ROOT="$TASK_PLANNER_ROOT"
  source "$TASK_PLANNER_ROOT/lib/verify.sh" >/dev/null 2>&1
  verify_installation >"$VERIFY_OUT" 2>&1
) || true
if grep -q "\[verify\] ✓" "$VERIFY_OUT" 2>/dev/null; then
  pass_msg "verify_installation executes and reports"
else
  fail_msg "verify_installation did not run or did not report"
  cat "$VERIFY_OUT" 2>/dev/null | head -20 | sed 's/^/  VERIFY: /'
fi
rm -f "$VERIFY_OUT"

echo ""
echo "[smoke] summary: $PASS pass / $FAIL fail"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
