#!/usr/bin/env bash
# lib/backup.sh — Backup existing task-planner install (canonical + stubs)
#
# Usage:
#   backup_existing_install
#
# Side effects:
#   - Creates $TASK_PLANNER_ROOT/.backup/<timestamp>/ with:
#     - claude-stub-<ts>/ (full snapshot of Claude stub)
#     - zcode-stub-<ts>/ (full snapshot of ZCode stub)
#     - etc.
#   - Logs to stdout
#
# Idempotent: skips already-backed-up stubs (existing .backup/<ts>-<tool>-<hash>/ dirs).
# Returns exit 0 always.

set -u

# Stub for callers; populated by source
: "${TASK_PLANNER_ROOT:?TASK_PLANNER_ROOT must be set}"

BACKUP_TIMESTAMP="${BACKUP_TIMESTAMP:-$(date +%Y%m%d-%H%M%S)}"

backup_stub() {
  local tool_name="$1"
  local stub_dir="$2"
  local dest="${TASK_PLANNER_ROOT}/.backup/claude-stub-${BACKUP_TIMESTAMP}"

  if [ ! -d "$stub_dir" ]; then
    return 0
  fi

  # Idempotent: check if already backed up under this timestamp
  if [ -d "$dest/$tool_name" ]; then
    echo "[backup] $tool_name stub already backed up at $dest/$tool_name — skip"
    return 0
  fi

  mkdir -p "$dest"
  cp -r "$stub_dir" "$dest/$tool_name"
  echo "[backup] $tool_name stub backed up → $dest/$tool_name"
}

backup_existing_install() {
  local backup_root="${TASK_PLANNER_ROOT}/.backup"
  mkdir -p "$backup_root"

  # Source detection to know which stubs exist
  # shellcheck disable=SC1091
  source "${TASK_PLANNER_ROOT}/lib/detect-tools.sh"

  for tool in "${TOOLS_DETECTED[@]}"; do
    backup_stub "$tool" "${TOOL_STUB_ROOT[$tool]}"
  done
}
