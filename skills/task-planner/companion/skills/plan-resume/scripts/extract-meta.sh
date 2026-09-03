#!/usr/bin/env bash
# extract-meta.sh — 从单个 task_plan.md 提取元数据
#
# Usage: extract-meta.sh <plan-file>
#
# Output: key=value 格式(默认) 或 --json 输出 JSON
#
# 字段:
#   task_id         目录名或文件名
#   m_time          文件修改时间(秒)
#   goal            Goal 段首非空非注释行,截断到 200 字符
#   current_phase   Current Phase 段,截断 5 行
#   next_step       Next Step 段首非空非注释行,截断 200 字符
#   phase_status    所有 Status: 行的值,以 | 分隔
#   all_complete    0/1
#   missing         1 当文件不存在
set -euo pipefail

FILE="${1:?usage: extract-meta.sh [--json] <plan-file>}"
JSON=0
if [[ "$FILE" == "--json" ]]; then
  JSON=1
  FILE="${2:?usage: extract-meta.sh --json <plan-file>}"
fi

if [[ ! -f "$FILE" ]]; then
  if [[ $JSON -eq 1 ]]; then
    printf '{"task_id":"%s","missing":true}\n' "$(basename "$(dirname "$FILE")")"
  else
    echo "task_id=$(basename "$(dirname "$FILE")")"
    echo "missing=1"
  fi
  exit 0
fi

DIR_NAME="$(basename "$(dirname "$FILE")")"
if [[ "$DIR_NAME" == ".zcode" || "$DIR_NAME" == "plans" || "$DIR_NAME" == "." ]]; then
  TASK_ID="$(basename "$FILE" .md)"
else
  TASK_ID="$DIR_NAME"
fi

M_TIME="$(stat -c %Y "$FILE" 2>/dev/null || echo 0)"

# Goal: 在 ## Goal 段后,直到下一个 ## 或 EOF,取第一个非空非注释非空行
GOAL=""
while IFS= read -r line; do
  case "$line" in
    "## Goal"|"# Goal") ;; # 忽略标记
    "## "*) break ;;
    "<!--"*|"<!--"*) break ;;
    ""|"  "*) continue ;;
    *)
      GOAL="$(echo "$line" | sed 's/^[[:space:]]*//' | head -c 200)"
      break
      ;;
  esac
done < <(awk '/^## Goal/{flag=1;next} /^##/{flag=0} flag' "$FILE")

# Current Phase: 整段,截 5 行
CUR_PHASE="$(awk '/^## Current Phase/{flag=1;next} /^## /{flag=0} flag' "$FILE" \
  | grep -v '^<!--' | grep -v '^-->$' \
  | sed '/^$/d' \
  | head -5 \
  | tr '\n' '|')"

# Next Step: 在 ## Next Step 段后,取第一个非空非注释行
NEXT_STEP=""
while IFS= read -r line; do
  case "$line" in
    "## Next Step"|"# Next Step") ;;
    "## "*) break ;;
    "<!--"*|"<!--"*) break ;;
    ""|"  "*) continue ;;
    *)
      NEXT_STEP="$(echo "$line" | sed 's/^[[:space:]]*//' | head -c 200)"
      break
      ;;
  esac
done < <(awk '/^## Next Step/{flag=1;next} /^## /{flag=0} flag' "$FILE")

# Phase Status: 所有 Status: 行
PHASE_STATUS="$(grep -E '^- \*\*Status:\*\*' "$FILE" \
  | sed 's/.*Status:\*\*[[:space:]]*//' \
  | tr '\n' '|')"

# 是否所有 phase 都是 complete
ALL_COMPLETE=0
if [[ -n "$PHASE_STATUS" ]] && ! echo "$PHASE_STATUS" | grep -qE 'pending|in_progress'; then
  ALL_COMPLETE=1
fi

if [[ $JSON -eq 1 ]]; then
  printf '{"task_id":"%s","m_time":%s,"goal":"%s","current_phase":"%s","next_step":"%s","phase_status":"%s","all_complete":%s}\n' \
    "$TASK_ID" "$M_TIME" \
    "$(echo "$GOAL" | sed 's/"/\\"/g')" \
    "$(echo "$CUR_PHASE" | sed 's/"/\\"/g')" \
    "$(echo "$NEXT_STEP" | sed 's/"/\\"/g')" \
    "$(echo "$PHASE_STATUS" | sed 's/"/\\"/g')" \
    "$ALL_COMPLETE"
else
  echo "task_id=$TASK_ID"
  echo "m_time=$M_TIME"
  echo "goal=$GOAL"
  echo "current_phase=$CUR_PHASE"
  echo "next_step=$NEXT_STEP"
  echo "phase_status=$PHASE_STATUS"
  echo "all_complete=$ALL_COMPLETE"
fi