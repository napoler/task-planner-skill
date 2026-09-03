#!/usr/bin/env bash
# extract-meta.sh — 从计划文件提取元数据,支持三种格式后端
#
# Usage: extract-meta.sh [--json] <plan-file>
#
# 格式自动检测(按优先级):
#   1. 路径含 openspec/changes/ → openspec 后端
#   2. 路径含 specs/*/ 且同一目录有 spec.md/tasks.md → spec-kit 后端
#   3. 其他 → task-planner 后端(默认)
#
# 输出字段:
#   task_id         目录名或文件名
#   m_time          文件修改时间(秒)
#   goal            Goal 段首非空非注释行,截断到 200 字符
#   current_phase   当前 phase/分组摘要,截断 5 行
#   next_step       Next Step 段首非空非注释行,截断 200 字符
#   phase_status    所有 Status: 行的值,以 | 分隔(task-planner 专用)
#   all_complete    0/1(task-planner 专用)
#   format          task-planner / openspec / spec-kit
#   task_completion_pct  完成度百分比(仅 openspec / spec-kit 填)
#   is_archived     0/1(openspec 归档标记)
#   missing         1 当文件不存在
set -euo pipefail

FILE=""
JSON=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON=1; shift ;;
    -*)
      echo "[extract-meta] 未知参数: $1" >&2; exit 1 ;;
    *)
      FILE="${FILE:-$1}"; shift ;;
  esac
done

[[ -z "$FILE" ]] && { echo "usage: extract-meta.sh [--json] <plan-file>" >&2; exit 2; }

# ─── Helpers ──────────────────────────────────────────────────────────────────

# 格式判别
detect_format() {
  local f="$1"
  local BASE GRPARENT DIR_PATH
  BASE="$(basename "$f")"
  DIR_PATH="$(dirname "$f")"
  GRPARENT="$(basename "$(dirname "$DIR_PATH")")"  # 上两级: <repo>/specs/<feature>/tasks.md → specs

  if echo "$f" | grep -q 'openspec/changes/'; then
    echo "openspec"
  elif [[ "$GRPARENT" == "specs" && ( "$BASE" == "tasks.md" || "$BASE" == "spec.md" ) ]]; then
    # spec-kit: <repo>/specs/<feature>/{tasks.md, spec.md}
    echo "spec-kit"
  else
    echo "task-planner"
  fi
}

# ─── 公共字段提取 ─────────────────────────────────────────────────────────────

extract_common() {
  local FILE="$1" FORMAT="$2"
  local DIR_NAME TASK_ID M_TIME GOAL CUR_PHASE NEXT_STEP

  if [[ ! -f "$FILE" ]]; then
    DIR_NAME="$(basename "$(dirname "$FILE")")"
    if [[ "$DIR_NAME" == ".zcode" || "$DIR_NAME" == "plans" || "$DIR_NAME" == "." ]]; then
      TASK_ID="$(basename "$FILE" .md)"
    else
      TASK_ID="$DIR_NAME"
    fi
    if [[ $JSON -eq 1 ]]; then
      printf '{"task_id":"%s","missing":true,"format":"%s"}\n' "$TASK_ID" "$FORMAT"
    else
      echo "task_id=$TASK_ID"
      echo "format=$FORMAT"
      echo "missing=1"
    fi
    return
  fi

  DIR_NAME="$(basename "$(dirname "$FILE")")"
  if [[ "$DIR_NAME" == ".zcode" || "$DIR_NAME" == "plans" || "$DIR_NAME" == "." ]]; then
    TASK_ID="$(basename "$FILE" .md)"
  else
    TASK_ID="$DIR_NAME"
  fi

  M_TIME="$(stat -c %Y "$FILE" 2>/dev/null || echo 0)"

  # Goal: 按格式不同
  case "$FORMAT" in
    task-planner)
      GOAL=""
      while IFS= read -r line; do
        case "$line" in
          "## Goal"|"# Goal") ;;
          "## "*) break ;;
          "<!--"*|"<!--"*) break ;;
          ""|"  "*) continue ;;
          *)
            GOAL="$(echo "$line" | sed 's/^[[:space:]]*//' | head -c 200)"
            break ;;
        esac
      done < <(awk '/^## Goal/{flag=1;next} /^##/{flag=0} flag' "$FILE")
      ;;
    openspec)
      # 优先读 .openspec.yaml 的 goal;缺失则读 proposal.md 的 ## Why 段
      local DIR_PATH
      DIR_PATH="$(dirname "$FILE")"
      if [[ -f "$DIR_PATH/.openspec.yaml" ]]; then
        GOAL="$(grep -E '^goal:' "$DIR_PATH/.openspec.yaml" 2>/dev/null | head -1 | sed 's/^goal:[[:space:]]*//' || true)"
      fi
      # fallback: 从 proposal.md 的 ## Why 段取首非空行
      if [[ -z "$GOAL" && -f "$DIR_PATH/proposal.md" ]]; then
        GOAL="$(awk '/^## Why/{flag=1;next} /^##/{flag=0} flag && NF && !/<!--/{print; exit}' \
          "$DIR_PATH/proposal.md" | sed 's/^[[:space:]]*//' | head -c 200 || true)"
      fi
      [[ -z "$GOAL" ]] && GOAL="[no goal field detected]"
      ;;
    spec-kit)
      # spec.md 的 # Feature Specification: [NAME] 行
      # 或当前文件(tasks.md)的第一行 # 标题
      local SPEC_FILE="${FILE%tasks.md}spec.md"
      if [[ "$FILE" == */spec.md ]]; then
        SPEC_FILE="$FILE"
      fi
      GOAL=""
      if [[ -f "$SPEC_FILE" ]]; then
        GOAL="$(grep -E '^# Feature Specification:' "$SPEC_FILE" 2>/dev/null | head -1 \
          | sed 's/^# Feature Specification:[[:space:]]*//' || true)"
      fi
      [[ -z "$GOAL" ]] && GOAL="$(head -1 "$FILE" | sed 's/^#//;s/^[[:space:]]*//' | head -c 200 || true)"
      ;;
  esac

  # Current Phase: 按格式
  case "$FORMAT" in
    task-planner)
      CUR_PHASE="$(awk '/^## Current Phase/{flag=1;next} /^## /{flag=0} flag' "$FILE" \
        | grep -v '^<!--' | grep -v '^-->$' \
        | sed '/^$/d' \
        | head -5 \
        | tr '\n' '|')"
      ;;
    openspec)
      # 从 tasks.md 提取 ## N. 分组标题,截 3 组
      CUR_PHASE="$(grep -E '^## [0-9]+\.' "$FILE" 2>/dev/null | head -3 | tr '\n' '|')"
      [[ -z "$CUR_PHASE" ]] && CUR_PHASE="[no phase headers]"
      ;;
    spec-kit)
      # spec.md 的 **Status**: 字段或 tasks.md 的 ## Phase N: 分组
      local SPEC_FILE="${FILE%tasks.md}spec.md"
      CUR_PHASE=""
      if [[ "$FILE" != */spec.md && -f "$SPEC_FILE" ]]; then
        CUR_PHASE="$(grep -E '\*\*Status\*\*:' "$SPEC_FILE" 2>/dev/null | head -1 | sed 's/.*Status\*\*:[[:space:]]*//' || true)"
      fi
      if [[ -z "$CUR_PHASE" ]]; then
        # 从当前 spec.md 文件本身读 Status 字段(spec.md 作为入口)
        if echo "$FILE" | grep -q 'spec\.md$'; then
          CUR_PHASE="$(grep -E '\*\*Status\*\*:' "$FILE" 2>/dev/null | head -1 | sed 's/.*Status\*\*:[[:space:]]*//' || true)"
        fi
      fi
      if [[ -z "$CUR_PHASE" ]]; then
        CUR_PHASE="$(grep -E '^## Phase [0-9]+:' "$FILE" 2>/dev/null | head -3 | tr '\n' '|' || true)"
      fi
      [[ -z "$CUR_PHASE" ]] && CUR_PHASE="[no status field detected]"
      ;;
  esac

  # Next Step: task-planner 专用,其他留空
  NEXT_STEP=""
  if [[ "$FORMAT" == "task-planner" ]]; then
    while IFS= read -r line; do
      case "$line" in
        "## Next Step"|"# Next Step") ;;
        "## "*) break ;;
        "<!--"*|"<!--"*) break ;;
        ""|"  "*) continue ;;
        *)
          NEXT_STEP="$(echo "$line" | sed 's/^[[:space:]]*//' | head -c 200)"
          break ;;
      esac
    done < <(awk '/^## Next Step/{flag=1;next} /^## /{flag=0} flag' "$FILE")
  fi

  # is_archived(openspec 专用)
  local IS_ARCHIVED=0
  if [[ "$FORMAT" == "openspec" ]] && echo "$FILE" | grep -q '/archive/'; then
    IS_ARCHIVED=1
  fi

  # phase_status / all_complete(task-planner 专用)
  local PHASE_STATUS=""
  local ALL_COMPLETE=0
  if [[ "$FORMAT" == "task-planner" ]]; then
    PHASE_STATUS="$(grep -E '^- \*\*Status:\*\*' "$FILE" \
      | sed 's/.*Status:\*\*[[:space:]]*//' \
      | tr '\n' '|')"
    if [[ -n "$PHASE_STATUS" ]] && ! echo "$PHASE_STATUS" | grep -qE 'pending|in_progress'; then
      ALL_COMPLETE=1
    fi
  fi

  # task_completion_pct(openspec + spec-kit 专用)
  local COMPLETION_PCT=""
  case "$FORMAT" in
    openspec)
      local TOTAL DONE
      TOTAL="$(grep -cE '^\s*[-*]\s+\[[ x]\]' "$FILE" 2>/dev/null || true)"
      DONE="$(grep -ciE '^\s*[-*]\s+\[x\]' "$FILE" 2>/dev/null || true)"
      TOTAL="${TOTAL:-0}"; TOTAL="${TOTAL//[[:space:]]/}"
      DONE="${DONE:-0}"; DONE="${DONE//[[:space:]]/}"
      if [[ "$TOTAL" =~ ^[0-9]+$ ]] && [[ $TOTAL -gt 0 ]]; then
        COMPLETION_PCT="$(( DONE * 100 / TOTAL ))"
      fi
      ;;
    spec-kit)
      local TOTAL_DONE TOTAL_ALL
      TOTAL_DONE="$(grep -ciE '^\s*[-*]\s+\[x\]' "$FILE" 2>/dev/null || true)"
      TOTAL_ALL="$(grep -cE '^\s*[-*]\s+\[[ x]\]' "$FILE" 2>/dev/null || true)"
      TOTAL_DONE="${TOTAL_DONE:-0}"; TOTAL_DONE="${TOTAL_DONE//[[:space:]]/}"
      TOTAL_ALL="${TOTAL_ALL:-0}"; TOTAL_ALL="${TOTAL_ALL//[[:space:]]/}"
      if [[ "$TOTAL_ALL" =~ ^[0-9]+$ ]] && [[ $TOTAL_ALL -gt 0 ]]; then
        COMPLETION_PCT="$(( TOTAL_DONE * 100 / TOTAL_ALL ))"
      fi
      ;;
  esac

  # 输出
  if [[ $JSON -eq 1 ]]; then
    printf '{"task_id":"%s","m_time":%s,"goal":"%s","current_phase":"%s","next_step":"%s","phase_status":"%s","all_complete":%s,"format":"%s"' \
      "$TASK_ID" "$M_TIME" \
      "$(echo "$GOAL" | sed 's/"/\\"/g')" \
      "$(echo "$CUR_PHASE" | sed 's/"/\\"/g')" \
      "$(echo "$NEXT_STEP" | sed 's/"/\\"/g')" \
      "$(echo "$PHASE_STATUS" | sed 's/"/\\"/g')" \
      "$ALL_COMPLETE" "$FORMAT"
    # 可选字段
    if [[ -n "$COMPLETION_PCT" ]]; then
      printf ',"task_completion_pct":%s' "$COMPLETION_PCT"
    fi
    if [[ $IS_ARCHIVED -eq 1 ]]; then
      printf ',"is_archived":1'
    fi
    printf '}\n'
  else
    echo "task_id=$TASK_ID"
    echo "m_time=$M_TIME"
    echo "goal=$GOAL"
    echo "current_phase=$CUR_PHASE"
    echo "next_step=$NEXT_STEP"
    echo "phase_status=$PHASE_STATUS"
    echo "all_complete=$ALL_COMPLETE"
    echo "format=$FORMAT"
    [[ -n "$COMPLETION_PCT" ]] && echo "task_completion_pct=$COMPLETION_PCT"
    [[ $IS_ARCHIVED -eq 1 ]] && echo "is_archived=1"
  fi
}

# ─── Main ─────────────────────────────────────────────────────────────────────

FORMAT="$(detect_format "$FILE")"
extract_common "$FILE" "$FORMAT"