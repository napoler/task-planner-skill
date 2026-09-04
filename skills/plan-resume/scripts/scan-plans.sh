#!/usr/bin/env bash
# scan-plans.sh — 扫描工作区所有 task-planner 计划位置
#
# Usage: scan-plans.sh [repo-root] [--only <pattern>] [--time-threshold <N>]
#
# Flags:
#   --only <pattern>        grep 任务名过滤(如 "ts-migration|fix|worktree")
#   --time-threshold <N>    时间衰减阈值(秒),<N 天的项才进"过期"判断
#                          默认 604800(7 天)
#
# Output: 每行一个 task_plan.md 绝对路径
set -euo pipefail

ROOT=$(pwd)
ONLY_PATTERN=""
TIME_THRESHOLD=604800

# 解析参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)
      [[ $# -lt 2 ]] && { echo "[scan-plans] --only 需要参数" >&2; exit 1; }
      ONLY_PATTERN="$2"; shift 2 ;;
    --time-threshold)
      [[ $# -lt 2 ]] && { echo "[scan-plans] --time-threshold 需要参数" >&2; exit 1; }
      TIME_THRESHOLD="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,12p' "$0"; exit 0 ;;
    --)
      shift; break ;;
    -*)
      echo "[scan-plans] 未知参数: $1 (help: -h)" >&2; exit 1 ;;
    *)
      if [[ -z "$ROOT" || "$ROOT" == "$(pwd)" ]]; then
        ROOT="$1"
      else
        echo "[scan-plans] 位置参数冲突: 已设 ROOT=$ROOT" >&2; exit 1
      fi
      shift ;;
  esac
done

# 自适应 LOCATIONS:ROOT 直接指向 plans/ 子目录时(简化)走子目录直扫
LOCATIONS=()
if [[ "$ROOT" == */plans ]]; then
  LOCATIONS+=("*/task_plan.md")
elif [[ -d "$ROOT/plans" ]]; then
  LOCATIONS+=("plans/*/task_plan.md")
fi
if [[ -d "$ROOT/.zcode/plans" ]]; then
  LOCATIONS+=(".zcode/plans/plan-sess_*.md")
fi
if [[ -d "$ROOT/skills" && "$ROOT" != */skills ]]; then
  LOCATIONS+=("skills/*/plans/task-*/task_plan.md")
fi

if [[ ${#LOCATIONS[@]} -eq 0 ]]; then
  # 回退默认
  LOCATIONS=(
    "plans/*/task_plan.md"
    ".zcode/plans/plan-sess_*.md"
    "skills/*/plans/task-*/task_plan.md"
  )
fi

FOUND=0
if [[ -d "$ROOT" ]]; then
  # cd 进 ROOT,相对路径直接可用(避免 ROOT 含 plans/ 时的双前缀)
  RAW_LINES=$(
    cd "$ROOT" 2>/dev/null && {
      for pattern in "${LOCATIONS[@]}"; do
        # shellcheck disable=SC2086
        for candidate in $pattern; do
          [[ -f "$candidate" ]] && echo "$ROOT/$candidate"
        done
      done
    }
  ) || true

  if [[ -n "$ONLY_PATTERN" ]]; then
    while IFS= read -r f; do
      if echo "$f" | grep -qE "$ONLY_PATTERN"; then
        echo "$f"
        FOUND=$((FOUND + 1))
      fi
    done <<< "$RAW_LINES"
  else
    while IFS= read -r f; do
      echo "$f"
      FOUND=$((FOUND + 1))
    done <<< "$RAW_LINES"
  fi
fi

# 过滤
if [[ -n "$ONLY_PATTERN" ]]; then
  MATCHED=0
  while IFS= read -r f; do
    if echo "$f" | grep -qE "$ONLY_PATTERN"; then
      echo "$f"
      MATCHED=$((MATCHED + 1))
    fi
  done
  if [[ $MATCHED -eq 0 ]]; then
    echo "[scan-plans] 过滤后无匹配 (--only=$ONLY_PATTERN)" >&2
  fi
else
  # 无过滤,直接 pass-through
  :
fi

# 阈值信息
echo "[scan-plans] 阈值: time=${TIME_THRESHOLD}s ($((TIME_THRESHOLD / 86400))d)" >&2
[[ -n "$ONLY_PATTERN" ]] && echo "[scan-plans] 过滤: pattern=$ONLY_PATTERN" >&2
echo "[scan-plans] 扫描源: $ROOT" >&2