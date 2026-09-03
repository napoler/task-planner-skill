#!/usr/bin/env bash
# scan-plans.sh — 扫描工作区所有计划位置(task-planner / spec-kit / openspec)
#
# Usage: scan-plans.sh [repo-root] [flags...]
#
# Flags:
#   --only <pattern>        grep 任务名过滤(如 "ts-migration|fix|worktree")
#   --time-threshold <N>    时间衰减阈值(秒),默认 604800(7 天)
#   --include-archived      包含已归档的计划(openspec archive 默认跳过)
#   -h|--help               打印帮助
#
# Output: 每行一个计划文件绝对路径(可能是 task_plan.md / tasks.md / spec.md)
#   stderr: 阈值 / 过滤 / 扫描源信息
set -euo pipefail

ROOT=$(pwd)
ONLY_PATTERN=""
TIME_THRESHOLD=604800
INCLUDE_ARCHIVED=0

# 解析参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)
      [[ $# -lt 2 ]] && { echo "[scan-plans] --only 需要参数" >&2; exit 1; }
      ONLY_PATTERN="$2"; shift 2 ;;
    --time-threshold)
      [[ $# -lt 2 ]] && { echo "[scan-plans] --time-threshold 需要参数" >&2; exit 1; }
      TIME_THRESHOLD="$2"; shift 2 ;;
    --include-archived)
      INCLUDE_ARCHIVED=1; shift ;;
    -h|--help)
      sed -n '2,14p' "$0"; exit 0 ;;
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

# 自适应 LOCATIONS
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

# openspec 位置
# 支持 ROOT 是 openspec 项目根(有 openspec/changes/) 或 ROOT 本身是 openspec 项目
if [[ -d "$ROOT/openspec/changes" ]]; then
  if [[ $INCLUDE_ARCHIVED -eq 1 ]]; then
    LOCATIONS+=("openspec/changes/*/tasks.md" "openspec/changes/archive/*/tasks.md")
  else
    LOCATIONS+=("openspec/changes/*/tasks.md")
  fi
fi
# 若 ROOT 直接是 openspec 项目(如 /home/terry/openspec),额外扫顶层 changes/
if [[ -d "$ROOT/changes" ]]; then
  if [[ $INCLUDE_ARCHIVED -eq 1 ]]; then
    LOCATIONS+=("changes/*/tasks.md" "changes/archive/*/tasks.md")
  else
    LOCATIONS+=("changes/*/tasks.md")
  fi
fi

# spec-kit 位置(实验性:本机未见过真实样例,基于官方模板约定)
# spec-kit 约定: specs/<NNN-feature>/ 含 spec.md + plan.md + tasks.md
# 或 .specify/specs/<NNN-feature>/ (旧约定)
if [[ -d "$ROOT/specs" ]]; then
  LOCATIONS+=("specs/*/tasks.md" "specs/*/spec.md")
fi
if [[ -d "$ROOT/.specify" && "$ROOT" != */.specify ]]; then
  LOCATIONS+=(".specify/specs/*/tasks.md" ".specify/specs/*/spec.md")
fi

if [[ ${#LOCATIONS[@]} -eq 0 ]]; then
  # 回退默认
  LOCATIONS=(
    "plans/*/task_plan.md"
    ".zcode/plans/plan-sess_*.md"
    "skills/*/plans/task-*/task_plan.md"
    "openspec/changes/*/tasks.md"
    "specs/*/tasks.md"
  )
fi

# 扫描
FOUND=0
if [[ -d "$ROOT" ]]; then
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
    if [[ $FOUND -eq 0 ]]; then
      echo "[scan-plans] 过滤后无匹配 (--only=$ONLY_PATTERN)" >&2
    fi
  else
    while IFS= read -r f; do
      echo "$f"
      FOUND=$((FOUND + 1))
    done <<< "$RAW_LINES"
  fi
fi

# 阈值信息
echo "[scan-plans] 阈值: time=${TIME_THRESHOLD}s ($((TIME_THRESHOLD / 86400))d)" >&2
[[ -n "$ONLY_PATTERN" ]] && echo "[scan-plans] 过滤: pattern=$ONLY_PATTERN" >&2
[[ $INCLUDE_ARCHIVED -eq 1 ]] && echo "[scan-plans] 包含已归档" >&2
echo "[scan-plans] 扫描源: $ROOT" >&2