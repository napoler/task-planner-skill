#!/usr/bin/env bash
# check-scope.sh — PreToolUse guard: verify Write/Edit against task_plan.md scope
#
# Usage (from PreToolUse hook):
#   check-scope.sh Write "/path/to/file" [plan_file]
#   check-scope.sh Edit "/path/to/file" [plan_file]
#
# Exit codes:
#   0 = file IS in scope (or no scope defined)
#   1 = file is OUT OF SCOPE (BLOCKED)
#   2 = no task_plan.md found (skip check)

set -eu

TOOL="${1:-}"
FILE_PATH="${2:-}"
PLAN_FILE="${3:-task_plan.md}"

# ─── No task_plan.md → allow plan-directory writes ────────────────────────────
if [[ ! -f "$PLAN_FILE" ]] && [[ -n "$FILE_PATH" ]]; then
    # task_plan.md missing — check if target is under plans/ directory
    abs_path="$(python3 -c "import os; print(os.path.abspath('$FILE_PATH'))" 2>/dev/null || echo "$FILE_PATH")"

    # Walk up from FILE_PATH to find a plans/ ancestor
    search_dir="$(dirname "$abs_path")"
    while [[ "$search_dir" != "/" && -n "$search_dir" ]]; do
        if [[ "$(basename "$search_dir")" == "plans" ]]; then
            exit 0
        fi
        search_dir="$(dirname "$search_dir")"
    done

    # Also allow known plan-initialization files anywhere
    basename="$(basename "$abs_path")"
    case "$basename" in
        task_plan.md|findings.md|progress.md|notepad-learnings.md)
            exit 0
            ;;
        init-session.sh|init-session.ps1|session-catchup.py)
            exit 0
            ;;
        check-complete.sh|check-complete.ps1|check-scope.sh|sync-todos.sh)
            exit 0
            ;;
    esac

    # Outside plans/ without a plan — block
    echo "[SCOPE GUARD] No task_plan.md found. Plan initialization required."
    echo "  Tool: $TOOL"
    echo "  File: $FILE_PATH"
    echo ""
    echo "Initialize with:"
    echo "  mkdir -p plans/{task-id}/ && bash ~/.claude/skills/task-planner/scripts/init-session.sh"
    exit 2
fi

# ─── Python-based parser: handles UTF-8, multi-byte chars, ** glob ──────────
python3 - "$FILE_PATH" "$PLAN_FILE" << 'PYEOF'
import sys
import re

file_path = sys.argv[1]
plan_file = sys.argv[2]

try:
    import os
    content = open(plan_file, 'r', encoding='utf-8').read()
except:
    sys.exit(0)

# Derive project root: plans/task-xxx/task_plan.md → plans/ parent
plans_dir = os.path.dirname(os.path.dirname(os.path.abspath(plan_file)))  # plans/{id}
project_root = os.path.dirname(plans_dir)  # project root

# Make file_path relative to project_root
file_path_abs = os.path.abspath(file_path)
if file_path_abs.startswith(project_root + '/'):
    file_path = file_path_abs[len(project_root) + 1:]
else:
    # Fall back: just use the filename if not under project_root
    file_path = os.path.basename(file_path_abs)

# Find the scope table: header row + data rows
# Header: | 类别 | 允许的文件 | 禁止 |  (in Chinese)
lines = content.split('\n')
header_idx = -1
for i, line in enumerate(lines):
    if '类别' in line and '允许' in line and '禁止' in line and line.startswith('|'):
        header_idx = i
        break

if header_idx < 0:
    sys.exit(0)

# Collect table rows (skip header, separator, empty rows)
patterns = []
for line in lines[header_idx + 1:]:
    # Stop at first non-table line after table rows
    if not line.startswith('|') and not line.startswith('|----'):
        break
    if line.startswith('|----'):
        continue
    if not line.strip():
        continue
    # Parse cells: | cat | allowed | forbid |
    cells = [c.strip() for c in line.split('|')[1:-1]]
    if len(cells) < 2:
        continue
    allowed = cells[1]
    if not allowed or allowed in ('允许的文件', '禁止'):
        continue
    # Split comma-separated patterns
    for p in allowed.split(','):
        p = p.strip()
        if p:
            patterns.append(p)

if not patterns:
    sys.exit(0)

def match_pattern(file_path, pat):
    import fnmatch

    # Direct match
    if file_path == pat:
        return True

    # ** glob: matches any directory depth
    if '**' in pat:
        parts = pat.split('/**/')
        if len(parts) == 2:
            prefix = parts[0]
            suffix_pat = parts[1]
            if not file_path.startswith(prefix + '/'):
                return False
            rest = file_path[len(prefix) + 1:]
            suffix_ext = suffix_pat.lstrip('*')
            if rest.endswith(suffix_ext) and rest.count('/') >= 0:
                filename = rest.split('/')[-1]
                if fnmatch.fnmatch(filename, suffix_pat):
                    return True
        return False

    # Simple * glob
    return fnmatch.fnmatch(file_path, pat)

for pat in patterns:
    if match_pattern(file_path, pat):
        sys.exit(0)

# OUT OF SCOPE
print("[SCOPE GUARD] ✗ FILE OUT OF SCOPE")
print(f"  Tool: {sys.argv[3] if len(sys.argv) > 3 else ''}")
print(f"  File: {file_path}")
print()
print("Allowed patterns:")
for p in patterns:
    print(f"  - {p}")
print()
print(f"Fix: Add this file to the scope table in {plan_file}, or get user approval to expand scope.")
sys.exit(1)
PYEOF