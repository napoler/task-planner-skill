#!/usr/bin/env bash
# lib/backup.sh — Backup existing task-planner install (canonical + stubs)
#
# Usage:
#   backup_existing_install
#
# Side effects:
#   - Creates $TASK_PLANNER_ROOT/.backup/<tool>-stub-<timestamp>/ with:
#     - Full snapshot of the tool stub (excluding .backup/ and .git/)
#   - Logs to stdout
#
# Idempotent: skips already-backed-up stubs (existing .backup/<tool>-stub-<ts>/ dirs).
# Returns 0 on success/skip; returns 1 if tar backup fails.

set -u
set -o pipefail

# Stub for callers; populated by source
: "${TASK_PLANNER_ROOT:?TASK_PLANNER_ROOT must be set}"

BACKUP_TIMESTAMP="${BACKUP_TIMESTAMP:-$(date +%Y%m%d-%H%M%S)}"

backup_stub() {
  local tool_name="$1"
  local stub_dir="$2"
  local dest="${TASK_PLANNER_ROOT}/.backup/${tool_name}-stub-${BACKUP_TIMESTAMP}"

  if [ ! -d "$stub_dir" ]; then
    return 0
  fi

  # Idempotent: check if already backed up under this timestamp
  if [ -d "$dest" ]; then
    echo "[backup] $tool_name stub already backed up at $dest — skip"
    return 0
  fi

  mkdir -p "$dest"
  tar --exclude='./.backup' --exclude='./.git' -cf - -C "$stub_dir" . | tar -xf - -C "$dest"
  local tar_rc=${PIPESTATUS[0]:-0} untar_rc=${PIPESTATUS[1]:-0}
  if [ "$tar_rc" -ne 0 ] || [ "$untar_rc" -ne 0 ]; then
    echo "[backup] ERROR: $tool_name stub backup failed (tar=$tar_rc untar=$untar_rc) → $dest" >&2
    return 1
  fi
  echo "[backup] $tool_name stub backed up → $dest (excluded .backup/.git; existing .backup requires manual cleanup, this script only prevents new recursion)"
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
