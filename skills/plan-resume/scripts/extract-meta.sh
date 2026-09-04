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
#   -- v0.4 新增字段(2026-09-04 smart-resume 升级) --
#   depends_on      plan 中所有 depends_on 引用,以 | 分隔
#   block_id        plan 的 block_id(自身标识)
#   vc_count        Verification Contract 表项数
#   p0_markers      含 P0/P1 优先级的行数(粗判重要度)
#   failure_count   progress.md Error Log 段条目数(0 表示从未失败)
#   git_last_commit 该 plan 文件 git 最后提交时间(秒),0 表示 untracked
#   real_age_days   基于 git_last_commit 的真实 age(天),untracked 用 mtime
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
# 注: 用 || true 防止空 CUR_PHASE 触发 set -e (有些 plan 没有该段)
CUR_PHASE="$(awk '/^## Current Phase/{flag=1;next} /^## /{flag=0} flag' "$FILE" 2>/dev/null \
  | grep -v '^<!--' 2>/dev/null | grep -v '^-->$' 2>/dev/null \
  | sed '/^$/d' 2>/dev/null \
  | head -5 2>/dev/null \
  | tr '\n' '|' 2>/dev/null)" || CUR_PHASE=""

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

# Phase Status: 所有 Status: 行(用 || true 防止空 pipeline 触发 set -e)
PHASE_STATUS="$(grep -E '^- \*\*Status:\*\*' "$FILE" 2>/dev/null \
  | sed 's/.*Status:\*\*[[:space:]]*//' 2>/dev/null \
  | tr '\n' '|')" || PHASE_STATUS=""

# 是否所有 phase 都是 complete
ALL_COMPLETE=0
if [[ -n "$PHASE_STATUS" ]] && ! echo "$PHASE_STATUS" | grep -qE 'pending|in_progress'; then
  ALL_COMPLETE=1
fi

# ---- v0.4 新增字段 ----

# depends_on: plan frontmatter 或正文里的 depends_on 引用
# 支持两种格式:
#   YAML frontmatter:  depends_on: [task-a, task-b]
#   Markdown 表格行:    | depends_on | ... |
DEPENDS_ON=""
# 1. frontmatter(简单 grep,因为 plan frontmatter 短)
FM_BLOCK="$(awk '/^---$/{n++; if(n==2) exit; next} n==1' "$FILE" 2>/dev/null || true)"
if [[ -n "$FM_BLOCK" ]]; then
  DEPENDS_ON="$(echo "$FM_BLOCK" | grep -E '^\s*depends_on:' 2>/dev/null | sed 's/.*depends_on:[[:space:]]*//' 2>/dev/null | tr -d '[]"' 2>/dev/null | tr ',' '\n' 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' 2>/dev/null | grep -v '^$' 2>/dev/null | tr '\n' '|' 2>/dev/null)" || DEPENDS_ON=""
fi
# 2. markdown 表格(粗)
if [[ -z "$DEPENDS_ON" ]]; then
  DEPENDS_ON="$(grep -E 'depends_on|^\|.*task-' "$FILE" 2>/dev/null | head -3 | sed 's/^|//' | tr '|' '\n' | grep -oE 'task-[a-zA-Z0-9_-]+' | sort -u | tr '\n' '|')" || DEPENDS_ON=""
fi
DEPENDS_ON="${DEPENDS_ON%|}"

# block_id: plan 自身 block_id(从 frontmatter)
BLOCK_ID=""
if [[ -n "$FM_BLOCK" ]]; then
  BLOCK_ID="$(echo "$FM_BLOCK" | grep -E '^\s*block_id:' 2>/dev/null | sed 's/.*block_id:[[:space:]]*//' 2>/dev/null | head -1 | tr -d '"' 2>/dev/null)" || BLOCK_ID=""
fi

# vc_count: Verification Contract 表行数
VC_COUNT="$(grep -cE '^\| VC-[0-9]+' "$FILE" 2>/dev/null)" || VC_COUNT=0
# 兼容旧格式 | VC-1 | ... |
if [[ "${VC_COUNT:-0}" -eq 0 ]]; then
  VC_COUNT="$(grep -cE '^\|.*[Vv][Cc]-' "$FILE" 2>/dev/null)" || VC_COUNT=0
fi

# p0_markers: 含 P0/P1 优先级的行数(粗判重要度,排除 P0 铁律引用)
P0_MARKERS="$(grep -cE '\bP[01]\b' "$FILE" 2>/dev/null)" || P0_MARKERS=0

# failure_count: progress.md Error Log 段条目数(0 表示从未失败)
FAILURE_COUNT=0
PROGRESS_FILE="$(dirname "$FILE")/progress.md"
if [[ -f "$PROGRESS_FILE" ]]; then
  FAILURE_COUNT="$(awk '/^## Error Log/{flag=1;next} /^## /{flag=0} flag' "$PROGRESS_FILE" 2>/dev/null | grep -cE '^\|' 2>/dev/null)" || FAILURE_COUNT=0
  if [[ "${FAILURE_COUNT:-0}" -eq 0 ]]; then
    FAILURE_COUNT="$(grep -cE 'circuit-break|CIRCUIT-BREAK|\[FAIL\]' "$PROGRESS_FILE" 2>/dev/null)" || FAILURE_COUNT=0
  fi
fi

# git_last_commit: 该 plan 文件 git 最后提交时间(秒)
GIT_LAST_COMMIT=0
if command -v git >/dev/null 2>&1; then
  SEARCH_DIR="$(dirname "$FILE")"
  while [[ "$SEARCH_DIR" != "/" ]]; do
    if [[ -d "$SEARCH_DIR/.git" ]] || git -C "$SEARCH_DIR" rev-parse --git-dir >/dev/null 2>&1; then
      REL_PATH="${FILE#$SEARCH_DIR/}"
      GIT_LAST_COMMIT="$(git -C "$SEARCH_DIR" log -1 --format=%ct -- "$REL_PATH" 2>/dev/null)" || GIT_LAST_COMMIT=0
      break
    fi
    SEARCH_DIR="$(dirname "$SEARCH_DIR")"
  done
fi

# real_age_days: 基于 git_last_commit 的真实 age(天),untracked 用 mtime
NOW="$(date +%s)"
if [[ "$GIT_LAST_COMMIT" -gt 0 ]]; then
  REAL_AGE_DAYS="$(( (NOW - GIT_LAST_COMMIT) / 86400 ))"
else
  REAL_AGE_DAYS="$(( (NOW - M_TIME) / 86400 ))"
fi

if [[ $JSON -eq 1 ]]; then
  printf '{"task_id":"%s","m_time":%s,"goal":"%s","current_phase":"%s","next_step":"%s","phase_status":"%s","all_complete":%s,"depends_on":"%s","block_id":"%s","vc_count":%s,"p0_markers":%s,"failure_count":%s,"git_last_commit":%s,"real_age_days":%s}\n' \
    "$TASK_ID" "$M_TIME" \
    "$(echo "$GOAL" | sed 's/"/\\"/g')" \
    "$(echo "$CUR_PHASE" | sed 's/"/\\"/g')" \
    "$(echo "$NEXT_STEP" | sed 's/"/\\"/g')" \
    "$(echo "$PHASE_STATUS" | sed 's/"/\\"/g')" \
    "$ALL_COMPLETE" \
    "$DEPENDS_ON" \
    "$BLOCK_ID" \
    "$VC_COUNT" \
    "$P0_MARKERS" \
    "$FAILURE_COUNT" \
    "$GIT_LAST_COMMIT" \
    "$REAL_AGE_DAYS"
else
  echo "task_id=$TASK_ID"
  echo "m_time=$M_TIME"
  echo "goal=$GOAL"
  echo "current_phase=$CUR_PHASE"
  echo "next_step=$NEXT_STEP"
  echo "phase_status=$PHASE_STATUS"
  echo "all_complete=$ALL_COMPLETE"
  echo "depends_on=$DEPENDS_ON"
  echo "block_id=$BLOCK_ID"
  echo "vc_count=$VC_COUNT"
  echo "p0_markers=$P0_MARKERS"
  echo "failure_count=$FAILURE_COUNT"
  echo "git_last_commit=$GIT_LAST_COMMIT"
  echo "real_age_days=$REAL_AGE_DAYS"
fi
