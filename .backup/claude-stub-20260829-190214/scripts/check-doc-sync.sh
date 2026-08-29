#!/usr/bin/env bash
# check-doc-sync.sh — Detect task_plan.md staleness and force-sync if needed
#
# Usage:
#   check-doc-sync.sh [task_plan_path] [max_age_minutes]
#
# Exit codes:
#   0 = plan is fresh (mtime within threshold)
#   1 = plan is STALE — caller MUST Edit task_plan.md to append progress entry
#   2 = no task_plan.md found — skip (no active planning session)
#
# Falls back to config.json#sync_interval_calls if max_age_minutes not given.

set -euo pipefail

PLAN_FILE="${1:-task_plan.md}"
MAX_AGE_MINUTES="${2:-10}"

# Resolve absolute path
if [[ ! "$PLAN_FILE" = /* ]]; then
    PLAN_FILE="$(pwd)/$PLAN_FILE"
fi

if [[ ! -f "$PLAN_FILE" ]]; then
    echo "[doc-sync] SKIP: no task_plan.md at $PLAN_FILE"
    exit 2
fi

# ─── Read sync_interval_calls from config.json ──────────────────────────────
CONFIG_FILE="${OPENCODE_SKILL_ROOT:-$HOME/.claude/skills/task-planner}/config.json"
DEFAULT_INTERVAL=5
if [[ -f "$CONFIG_FILE" ]]; then
    VAL=$(python3 -c "
import json, sys
try:
    c = json.load(open('$CONFIG_FILE'))
    print(c['properties']['sync_interval_calls']['default'])
except: print($DEFAULT_INTERVAL)
" 2>/dev/null || echo "$DEFAULT_INTERVAL")
    # Use time-based fallback: N tool calls ≈ N*30s → minutes = interval * 0.5
    # But if user passed max_age_minutes explicitly, prefer that.
fi

# Calculate threshold in seconds
THRESHOLD_SEC=$(( MAX_AGE_MINUTES * 60 ))

# Get file mtime in epoch seconds
FILE_MTIME=$(stat -c %Y "$PLAN_FILE" 2>/dev/null || stat -f %m "$PLAN_FILE" 2>/dev/null || echo "0")
NOW=$(date +%s)
AGE_SEC=$(( NOW - FILE_MTIME ))

if [[ "$AGE_SEC" -gt "$THRESHOLD_SEC" ]]; then
    AGE_MIN=$(( AGE_SEC / 60 ))
    echo "[doc-sync] STALE: last update ${AGE_MIN}min ago (threshold: ${MAX_AGE_MINUTES}min)"
    echo "[doc-sync] ACTION: Edit $PLAN_FILE to append progress entry"
    echo "[doc-sync] MTIME: $(date -d "@$FILE_MTIME" '+%Y-%m-%d %H:%M' 2>/dev/null || python3 -c "from datetime import datetime; print(datetime.fromtimestamp($FILE_MTIME).strftime('%Y-%m-%d %H:%M'))")"
    exit 1
else
    AGE_MIN=$(( AGE_SEC / 60 ))
    echo "[doc-sync] FRESH: last update ${AGE_MIN}min ago"
    exit 0
fi
