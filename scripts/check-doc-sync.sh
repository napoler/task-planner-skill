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
MAX_AGE_MINUTES="${2:-}"

# Resolve absolute path
if [[ ! "$PLAN_FILE" = /* ]]; then
    PLAN_FILE="$(pwd)/$PLAN_FILE"
fi

if [[ ! -f "$PLAN_FILE" ]]; then
    echo "[doc-sync] SKIP: no task_plan.md at $PLAN_FILE"
    exit 2
fi

# ─── 读阈值：优先 CLI 参数，否则 config.json#plan_update_interval_minutes ────
# [2026-08-29] canonical：canonical source ($HOME/dev/task-planner) 优先；再尝试
# OPENCODE_SKILL_ROOT / zcode / claude stub 副本；均缺失时兜底 10 分钟。
CONFIG_FILE=""
for _c in "${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/config.json" \
          "${OPENCODE_SKILL_ROOT:-}/config.json" \
          "$HOME/.zcode/skills/task-planner/config.json" \
          "$HOME/.claude/skills/task-planner/config.json"; do
    if [ -n "$_c" ] && [ -f "$_c" ]; then CONFIG_FILE="$_c"; break; fi
done
CFG_MIN=""
if [ -n "$CONFIG_FILE" ]; then
    CFG_MIN="$(jq -r '.properties.plan_update_interval_minutes.default // 10' "$CONFIG_FILE" 2>/dev/null || true)"
fi
case "$CFG_MIN" in ''|*[!0-9]*) CFG_MIN=10 ;; esac
MAX_AGE_MINUTES="${MAX_AGE_MINUTES:-$CFG_MIN}"

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
