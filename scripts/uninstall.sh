#!/usr/bin/env bash
# uninstall.sh — Remove a task-planner skill installation.
#
# Purpose:
#   Cleanly removes a previously installed task-planner skill directory.
#   Does NOT touch other skills; only operates on the exact target path.
#
# Usage:
#   uninstall.sh                        # removes default: ~/.claude/skills/task-planner
#   uninstall.sh --target DIR           # remove DIR instead
#   uninstall.sh --dry-run              # show what would be removed, do nothing
#   uninstall.sh --force                # skip confirmation prompt
#   uninstall.sh -h | --help
#
# Exit codes:
#   0  success
#   1  user error (bad args, not found, no permission)
#   2  environment error
#
# This script is safe to re-run; it does nothing if the target is already gone.
#
# NO_TOOL_CHECK: openspec-* manage spec-driven changes; proxychains configures
# network proxying. Neither creates a local uninstall.sh for a self-hosted skill.

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
TARGET_DIR="${HOME}/.claude/skills/task-planner"
DRY_RUN=0
FORCE=0

log()  { printf '[%s] %s\n' "$SCRIPT_NAME" "$*"; }
warn() { printf '[%s] WARN: %s\n' "$SCRIPT_NAME" "$*" >&2; }
die()  { printf '[%s] ERROR: %s\n' "$SCRIPT_NAME" "$*" >&2; exit "${2:-1}"; }

usage() {
  sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

# -------- Arg parsing --------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)  TARGET_DIR="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --force)   FORCE=1; shift ;;
    -h|--help) usage ;;
    *)         die "unknown argument: $1  (try --help)" 1 ;;
  esac
done

# -------- Pre-flight --------
log "task-planner uninstaller"
log "  target: $TARGET_DIR"
log "  mode  : $([[ $DRY_RUN -eq 1 ]] && echo 'dry-run' || echo 'remove')"

if [[ ! -e "$TARGET_DIR" ]]; then
  log "target does not exist; nothing to remove: $TARGET_DIR"
  exit 0
fi

if [[ "$FORCE" -eq 0 ]] && [[ "$DRY_RUN" -eq 0 ]]; then
  warn "this will remove: $TARGET_DIR"
  warn "all generated plans in that directory will be lost."
  warn "pass --force to skip this prompt, or Ctrl-C to abort."
  if [[ -t 0 ]]; then
    read -r -p "Proceed? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || { log "aborted"; exit 1; }
  else
    die "refusing to remove without --force (non-interactive shell)" 1
  fi
fi

# -------- Remove --------
if [[ "$DRY_RUN" -eq 1 ]]; then
  # Show what would be removed without removing.
  log "[dry-run] would remove: $TARGET_DIR"
  find "$TARGET_DIR" -type f | sed "s|^|[dry-run] would delete |"
  # Also show if the parent dir would become empty (optional parent cleanup)
  PARENT="$(dirname "$TARGET_DIR")"
  if [[ -d "$PARENT" ]] && [[ "$(ls -A "$PARENT" 2>/dev/null)" == "" ]]; then
    log "[dry-run] parent dir '$PARENT' would be empty (not auto-removed)"
  fi
else
  log "removing $TARGET_DIR ..."
  rm -rf "$TARGET_DIR"
  log "removed."

  # Optionally clean up empty parent.
  PARENT="$(dirname "$TARGET_DIR")"
  if [[ -d "$PARENT" ]] && [[ "$(ls -A "$PARENT" 2>/dev/null)" == "" ]]; then
    if [[ "$FORCE" -eq 1 ]] || [[ "$DRY_RUN" -eq 0 ]] && \
       [[ -t 0 ]] && read -r -p "Parent '$PARENT' is now empty. Remove it too? [y/N] " ans && \
       [[ "$ans" =~ ^[Yy]$ ]]; then
      rmdir "$PARENT"
      log "also removed empty parent: $PARENT"
    fi
  fi
fi

log "done."
log ""
log "Next steps:"
log "  1. Restart Claude Code to pick up changes."
log "  2. (Optional) Install a fresh copy with: bash scripts/install.sh"
