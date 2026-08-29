#!/usr/bin/env bash
# lib/migrate-refs.sh — Migrate external references to use $TASK_PLANNER_ROOT
#
# Usage:
#   migrate_external_references
#
# Migrates hardcoded paths in:
#   - ~/.claude/CLAUDE.md
#   - ~/.claude/commands/*.md
#   - ~/.claude/prompts/*.md (if exists)
#   - ~/.zcode/CLAUDE.md or AGENTS.md (if exists)
#
# Idempotent: skips files already containing ${TASK_PLANNER_ROOT} near the path.

set -u

: "${HOME:?HOME must be set}"
: "${TASK_PLANNER_ROOT:?TASK_PLANNER_ROOT must be set}"

# Files to migrate: <glob> <sed-pattern>
MIGRATION_TARGETS=(
  "$HOME/.claude/CLAUDE.md"
  "$HOME/.claude/commands/*.md"
  "$HOME/.claude/prompts/*.md"
  "$HOME/.zcode/CLAUDE.md"
  "$HOME/.zcode/AGENTS.md"
  "$HOME/.config/ZCode/AGENTS.md"
  "$HOME/AGENTS.md"
)

# Patterns: hardcoded zcode path → env-var form
SED_RULES=(
  's|bash ~/.claude/skills/task-planner/scripts/|bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/|g'
  's|node ~/.claude/skills/task-planner/scripts/|node ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/|g'
  's|bash ~/.zcode/skills/task-planner/scripts/|bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/|g'
  's|node ~/.zcode/skills/task-planner/scripts/|node ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/|g'
)

migrate_external_references() {
  local changed=0
  local total=0

  for target in "${MIGRATION_TARGETS[@]}"; do
    # Expand glob (or use literal if no glob)
    for file in $target; do
      [ -f "$file" ] || continue
      total=$((total + 1))

      # Skip if already migrated (heuristic: no hardcoded path remaining)
      if ! grep -qE '\$HOME/\.claude/skills/task-planner|\$HOME/\.zcode/skills/task-planner|bash ~/.*\.claude/skills/task-planner|bash ~/.*\.zcode/skills/task-planner' "$file" 2>/dev/null; then
        continue
      fi

      # Apply all sed rules
      for rule in "${SED_RULES[@]}"; do
        sed -i "$rule" "$file"
      done

      echo "[migrate] $file"
      changed=$((changed + 1))
    done
  done

  echo "[migrate] summary: $changed / $total files changed"
}
