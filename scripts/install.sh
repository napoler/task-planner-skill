#!/usr/bin/env bash
# install.sh — One-click installer for the task-planner skill
#
# What it does:
#   1. Locates the source skill (default: <repo>/skills/task-planner/)
#   2. Copies the entire skill directory to the target location
#      (default: $HOME/.claude/skills/task-planner)
#   3. Marks scripts executable
#   4. Optionally runs the validator
#
# Supports: Linux, macOS, WSL, Git Bash on Windows.
# (Native Windows PowerShell users: see INSTALL.md for the .ps1 mirror.)
#
# Usage:
#   install.sh                        # install to default target
#   install.sh --target DIR           # install to DIR
#   install.sh --dry-run              # show what would happen, do nothing
#   install.sh --force                # overwrite existing target without asking
#   install.sh --source DIR           # use a custom source directory
#   install.sh --no-validate          # skip post-install validation
#   install.sh --uninstall            # run the uninstaller instead
#   install.sh -h | --help
#
# Exit codes:
#   0  success
#   1  user error (bad args, missing files)
#   2  environment error (no source, no write permission, etc.)
#   3  post-install validation failed (skill installed but verify failed)
#
# This script is safe to re-run; it overwrites the target.
#
# NO_TOOL_CHECK: skill-chain-generator / skill-creator / sub-agents are for
# authoring skills; openspec-* for spec workflows; proxychains for network.
# None of them produce a packaging/install script for a self-hosted skill.

set -euo pipefail

# -------- Defaults --------
SCRIPT_NAME="$(basename "$0")"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_DIR="${REPO_ROOT}/skills/task-planner"
TARGET_DIR="${HOME}/.claude/skills/task-planner"
DRY_RUN=0
FORCE=0
DO_VALIDATE=1
DO_UNINSTALL=0

# -------- Helpers --------
log()  { printf '[%s] %s\n' "$SCRIPT_NAME" "$*"; }
warn() { printf '[%s] WARN: %s\n' "$SCRIPT_NAME" "$*" >&2; }
die()  { printf '[%s] ERROR: %s\n' "$SCRIPT_NAME" "$*" >&2; exit "${2:-1}"; }

usage() {
  sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

# -------- Arg parsing --------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)       TARGET_DIR="$2"; shift 2 ;;
    --source)       SOURCE_DIR="$2"; shift 2 ;;
    --dry-run)      DRY_RUN=1; shift ;;
    --force)        FORCE=1; shift ;;
    --no-validate)  DO_VALIDATE=0; shift ;;
    --uninstall)    DO_UNINSTALL=1; shift ;;
    -h|--help)      usage ;;
    *)              die "unknown argument: $1  (try --help)" 1 ;;
  esac
done

# -------- Delegate to uninstaller --------
if [[ "$DO_UNINSTALL" -eq 1 ]]; then
  UNINSTALL="${REPO_ROOT}/scripts/uninstall.sh"
  if [[ -x "$UNINSTALL" ]]; then
    shift_args=()
    [[ "$DRY_RUN" -eq 1 ]] && shift_args+=(--dry-run)
    [[ "$FORCE"   -eq 1 ]] && shift_args+=(--force)
    shift_args+=(--target "$TARGET_DIR")
    exec "$UNINSTALL" "${shift_args[@]}"
  else
    die "uninstall.sh not found at $UNINSTALL" 2
  fi
fi

# -------- Pre-flight --------
log "task-planner installer"
log "  source : $SOURCE_DIR"
log "  target : $TARGET_DIR"
log "  mode   : $([[ $DRY_RUN -eq 1 ]] && echo 'dry-run' || echo 'install')"

if [[ ! -d "$SOURCE_DIR" ]]; then
  die "source directory not found: $SOURCE_DIR  (use --source DIR or run from repo root)" 2
fi
if [[ ! -f "$SOURCE_DIR/SKILL.md" ]]; then
  die "source is not a valid skill package (SKILL.md missing in $SOURCE_DIR)" 2
fi

# Target parent must exist & be writable (we create target dir ourselves)
TARGET_PARENT="$(dirname "$TARGET_DIR")"
if [[ ! -d "$TARGET_PARENT" ]]; then
  log "creating target parent: $TARGET_PARENT"
  [[ "$DRY_RUN" -eq 0 ]] && mkdir -p "$TARGET_PARENT"
fi
if [[ ! -w "$TARGET_PARENT" ]] && [[ "$DRY_RUN" -eq 0 ]]; then
  die "target parent not writable: $TARGET_PARENT  (try --target DIR under your home)" 2
fi

# Existing target?
if [[ -e "$TARGET_DIR" ]]; then
  if [[ "$FORCE" -eq 0 ]] && [[ "$DRY_RUN" -eq 0 ]]; then
    warn "target already exists: $TARGET_DIR"
    warn "pass --force to overwrite, or Ctrl-C to abort"
    if [[ -t 0 ]]; then
      read -r -p "Overwrite? [y/N] " ans
      [[ "$ans" =~ ^[Yy]$ ]] || { log "aborted"; exit 1; }
    else
      die "refusing to overwrite without --force (non-interactive shell)" 1
    fi
  fi
  log "removing existing target"
  [[ "$DRY_RUN" -eq 0 ]] && rm -rf "$TARGET_DIR"
fi

# -------- Install --------
if [[ "$DRY_RUN" -eq 1 ]]; then
  log "[dry-run] would copy: $SOURCE_DIR -> $TARGET_DIR"
  log "[dry-run] would chmod +x on scripts/ and hooks scripts"
else
  log "copying skill package..."
  cp -R "$SOURCE_DIR" "$TARGET_DIR"
  log "marking scripts executable..."
  # chmod all .sh files inside the installed skill
  find "$TARGET_DIR" -type f -name '*.sh' -exec chmod +x {} +
  # chmod all .py files too (best-effort; harmless if none)
  find "$TARGET_DIR" -type f -name '*.py' -exec chmod +x {} + 2>/dev/null || true
  log "installed to $TARGET_DIR"
fi

# -------- Post-install validation --------
if [[ "$DO_VALIDATE" -eq 1 ]] && [[ "$DRY_RUN" -eq 0 ]]; then
  VALIDATE="${REPO_ROOT}/scripts/validate.sh"
  if [[ -x "$VALIDATE" ]]; then
    log "running validate.sh..."
    if bash "$VALIDATE" "$TARGET_DIR"; then
      log "validation: PASS"
    else
      die "post-install validation FAILED  (skill installed but did not pass validate.sh)" 3
    fi
  else
    warn "validate.sh not found at $VALIDATE; skipping validation"
  fi
fi

log "done."
log ""
log "Next steps:"
log "  1. Restart Claude Code (or run /clear) so it discovers the skill."
log "  2. Invoke via the Skill tool or ask Claude to use the 'task-planner' skill."
log "  3. See INSTALL.md and examples/full-workflow.md for usage."
