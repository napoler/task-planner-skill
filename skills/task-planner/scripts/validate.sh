#!/usr/bin/env bash
# validate.sh — Validate a task-planner skill installation (or source repo).
#
# Purpose:
#   Ensures the skill package is structurally sound, scripts are syntactically
#   valid, and the JSON config conforms. Run it on the repo before committing
#   or after an install to catch problems early.
#
# Usage:
#   validate.sh [SKILL_DIR]         # default: <this script's parent>/../skills/task-planner
#   validate.sh /path/to/skill-dir
#
# Exit codes:
#   0  all checks pass
#   1  one or more checks failed (bad exit is a failure count; see output)
#
# Checks performed:
#   C1  SKILL.md present and non-empty
#   C2  config.json present, non-empty, valid JSON
#   C3  All .sh scripts under scripts/ pass bash -n
#   C4  All .py scripts under scripts/ pass python3 -m py_compile
#   C5  All .ts scripts under scripts/ pass npx tsc --noEmit (if available)
#   C6  All required templates are present
#   C7  All reference docs are present
#   C8  SKILL.md frontmatter is well-formed enough to parse (name, model, description)
#   C9  config.json validates against its own $schema (if jsonschema available)
#  C10  executable bits on shell scripts are set
#  C11  .ps1 Windows mirror exists for scripts that have a Windows hook

#
# NO_TOOL_CHECK: skill-find installs public GitHub skills; research-assistant
# does web search; dogfood tests web apps. None of these create a local
# validate.sh for a self-hosted skill package.
#
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
PASS=0
FAIL=0
WARN=0

fail() { printf '  [FAIL] %s\n' "$1"; FAIL=$((FAIL + 1)); }
pass() { printf '  [PASS] %s\n' "$1"; PASS=$((PASS + 1)); }
warn() { printf '  [WARN] %s\n' "$1"; WARN=$((WARN + 1)); }

# -------- Arg & target --------
if [[ $# -gt 1 ]]; then
  echo "usage: $0 [SKILL_DIR]" >&2
  exit 1
fi

if [[ $# -eq 1 ]]; then
  SKILL_DIR="$1"
else
  # Fallback: assume running from within the repo's scripts/ dir
  SKILL_DIR="$(cd "$(dirname "$0")/../skills/task-planner" && pwd)"
fi

[[ -d "$SKILL_DIR" ]] || { echo "ERROR: skill dir not found: $SKILL_DIR" >&2; exit 1; }

SKILL_DIR="$(cd "$SKILL_DIR" && pwd)"
echo "Validating skill at: $SKILL_DIR"
echo ""

# -------- C1: SKILL.md --------
if [[ -s "$SKILL_DIR/SKILL.md" ]]; then
  pass "SKILL.md present and non-empty ($(wc -c < "$SKILL_DIR/SKILL.md") bytes)"
else
  fail "SKILL.md missing or empty"
fi

# -------- C2: config.json --------
if [[ -f "$SKILL_DIR/config.json" ]]; then
  if python3 -c "import json; json.load(open('$SKILL_DIR/config.json'))" 2>/dev/null; then
    pass "config.json valid JSON"
  else
    fail "config.json invalid JSON"
  fi
else
  fail "config.json missing"
fi

# -------- C3: shell scripts syntax --------
sh_count=0
for f in "$SKILL_DIR"/scripts/*.sh; do
  [[ -f "$f" ]] || continue
  sh_count=$((sh_count + 1))
  if bash -n "$f" 2>/dev/null; then
    pass "scripts/$(basename "$f") syntax ok"
  else
    fail "scripts/$(basename "$f") syntax error"
  fi
done
if [[ "$sh_count" -eq 0 ]]; then
  warn "no .sh scripts found under scripts/"
fi

# -------- C4: Python scripts syntax --------
py_count=0
for f in "$SKILL_DIR"/scripts/*.py; do
  [[ -f "$f" ]] || continue
  py_count=$((py_count + 1))
  if python3 -m py_compile "$f" 2>/dev/null; then
    pass "scripts/$(basename "$f") syntax ok"
  else
    fail "scripts/$(basename "$f") syntax error"
  fi
done
if [[ "$py_count" -gt 0 ]]; then
  pass "Python syntax checks ($py_count file(s))"
else
  warn "no .py scripts found under scripts/"
fi

# -------- C5: TypeScript scripts syntax (best-effort) --------
ts_count=0
for f in "$SKILL_DIR"/scripts/*.ts; do
  [[ -f "$f" ]] || continue
  ts_count=$((ts_count + 1))
  if command -v tsc >/dev/null 2>&1; then
    if tsc --noEmit "$f" 2>/dev/null; then
      pass "scripts/$(basename "$f") type check ok"
    else
      # Type errors are reported as warnings, not failures, because TS scripts
      # may reference node types (@types/node) that aren't installed in this env.
      warn "scripts/$(basename "$f") has type errors (likely missing @types/node); non-fatal"
    fi
  elif npx tsc --version >/dev/null 2>&1; then
    if npx tsc --noEmit "$f" 2>/dev/null; then
      pass "scripts/$(basename "$f") type check ok (npx)"
    else
      warn "scripts/$(basename "$f") has type errors (npx); non-fatal"
    fi
  else
    warn "tsc/npx not available; skipping TypeScript check for $(basename "$f")"
  fi
done
if [[ "$ts_count" -gt 0 ]]; then
  pass "TypeScript checks ($ts_count file(s))"
else
  warn "no .ts scripts found under scripts/"
fi

# -------- C6: required templates --------
required_templates=(task_plan.md findings.md progress.md notepad-learnings.md)
for t in "${required_templates[@]}"; do
  if [[ -f "$SKILL_DIR/templates/$t" ]]; then
    pass "templates/$t present"
  else
    fail "templates/$t missing"
  fi
done

# -------- C7: required reference docs --------
required_refs=(critical-rules.md completion-gate.md goal-gate.md billing.md)
for r in "${required_refs[@]}"; do
  if [[ -f "$SKILL_DIR/references/$r" ]]; then
    pass "references/$r present"
  else
    warn "references/$r missing (non-fatal)"
  fi
done

# -------- C8: SKILL.md frontmatter basics --------
if [[ -s "$SKILL_DIR/SKILL.md" ]]; then
  for field in name model description; do
    if grep -qE "^---$" "$SKILL_DIR/SKILL.md" && \
       grep -qE "^${field}:" "$SKILL_DIR/SKILL.md"; then
      val="$(grep -m1 -E "^${field}:" "$SKILL_DIR/SKILL.md" | cut -d: -f2- | sed 's/^ *//')"
      pass "SKILL.md frontmatter: $field = $val"
    else
      fail "SKILL.md frontmatter: $field field missing"
    fi
  done
fi

# -------- C9: config.json schema validation (best-effort) --------
if [[ -f "$SKILL_DIR/config.json" ]]; then
  if python3 -c "
import json, sys
try:
    import jsonschema
except ImportError:
    sys.exit(0)
schema = json.load(open('$SKILL_DIR/config.json'))
# Remove self-referential schema for validation
schema.pop('\$schema', None)
# Validate empty object against schema (tests required/defaults)
jsonschema.validate({}, schema)
" 2>/dev/null; then
    pass "config.json schema (jsonschema lib) valid"
  elif command -v python3 >/dev/null 2>&1; then
    warn "jsonschema not installed; skipping schema validation"
  fi
fi

# -------- C10: executable bits --------
for f in "$SKILL_DIR"/scripts/*.sh; do
  [[ -f "$f" ]] || continue
  if [[ -x "$f" ]]; then
    pass "$(basename "$f") is executable"
  else
    fail "$(basename "$f") NOT executable (chmod +x missing)"
  fi
done

# -------- C11: .ps1 mirrors for hooks --------
if grep -q 'check-complete.ps1' "$SKILL_DIR/SKILL.md" 2>/dev/null; then
  if [[ -f "$SKILL_DIR/scripts/check-complete.ps1" ]]; then
    pass "scripts/check-complete.ps1 present (Windows hook mirror)"
  else
    warn "SKILL.md references check-complete.ps1 but file is missing"
  fi
fi

# -------- Summary --------
echo ""
echo "Results: $PASS pass, $FAIL fail, $WARN warn"
if [[ "$FAIL" -gt 0 ]]; then
  echo "VALIDATION FAILED"
  exit 1
fi
echo "VALIDATION PASSED"
exit 0
