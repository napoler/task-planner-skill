#!/usr/bin/env bash
# uninstall.sh — Remove multi-tool task-planner installation
#
# Usage:
#   bash uninstall.sh [--canonical <path>] [--keep-canonical] [--keep-backups] [--dry-run]
#
# What it does:
#   1. Removes per-tool stub directories
#   2. (Optional) Removes canonical source
#   3. (Optional) Removes backup directories
#   4. Reverts external reference migrations (best-effort)
#
# CAUTION: This is destructive. Backups are kept in .backup/ by default.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASK_PLANNER_ROOT="${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}"
KEEP_CANONICAL=0
KEEP_BACKUPS=0
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    --canonical) TASK_PLANNER_ROOT="$2"; shift 2 ;;
    --keep-canonical) KEEP_CANONICAL=1; shift ;;
    --keep-backups) KEEP_BACKUPS=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

log() { echo "[uninstall $(date +%H:%M:%S)] $*"; }
dry() { if [ "$DRY_RUN" -eq 1 ]; then echo "[dry-run] $*"; fi; }
run() { dry "$*"; [ "$DRY_RUN" -eq 0 ] && eval "$*"; }

log "starting uninstall. canonical: $TASK_PLANNER_ROOT"

# Detect tools
# shellcheck disable=SC1091
source "$TASK_PLANNER_ROOT/lib/detect-tools.sh" 2>/dev/null || {
  log "cannot detect tools (canonical not found); proceeding with hardcoded paths"
  TOOLS_DETECTED=("claude-code" "zcode")
  TOOL_STUB_ROOT[claude-code]="$HOME/.claude/skills/task-planner"
  TOOL_STUB_ROOT[zcode]="$HOME/.zcode/skills/task-planner"
}

# Phase 1: Remove stubs
log "Phase 1: remove per-tool stubs"
for tool in "${TOOLS_DETECTED[@]}"; do
  stub="${TOOL_STUB_ROOT[$tool]}"
  if [ -d "$stub" ]; then
    run "rm -rf '$stub'"
    log "  $tool stub removed: $stub"
  fi
done

# Phase 2: Remove canonical
if [ "$KEEP_CANONICAL" -eq 0 ]; then
  if [ -d "$TASK_PLANNER_ROOT" ]; then
    log "Phase 2: remove canonical source"
    run "rm -rf '$TASK_PLANNER_ROOT'"
    log "  canonical removed: $TASK_PLANNER_ROOT"
  fi
else
  log "Phase 2: SKIP canonical removal (--keep-canonical)"
fi

# Phase 3: Backups
if [ "$KEEP_BACKUPS" -eq 0 ] && [ -d "$TASK_PLANNER_ROOT/.backup" ]; then
  log "Phase 3: remove backups"
  run "rm -rf '$TASK_PLANNER_ROOT/.backup'"
fi

log "uninstall complete"
log "note: external reference migrations in CLAUDE.md/commands/*.md are NOT auto-reverted"
log "      (manual revert needed if you want to restore old paths)"
