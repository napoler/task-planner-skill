#!/usr/bin/env bash
# check-worktree-required.sh — 判定是否需要 worktree（2026-11-27 用户裁决）
#
# 设计原则（What/Why）：
# - 文件扩展名不是隔离判据（.md 也可能是交付型小说/长文档）。
# - 判定按“改动量/影响面”：>2 行 或 delivery=1（交付型 Markdown）或多文件 => REQUIRED。
# - 仅“非交付型过程文档且 <=2 行 trivial”可 EXEMPT（需调用方自行确认非交付型并登记）。
# - 用户显式“直接改不用 worktree”仍按 AGENTS.md §11.5 处理，但不因 .md 后缀自动生效（由上层策略登记）。
#
# 用法：
#   check-worktree-required.sh --files <path[,path...]> --lines <N> --delivery <0|1> [--cwd <dir>]
#
# 输出（单行，便于机器/人读）：
#   REQUIRED worktree: <reason>
#   EXEMPT trivial: <reason>
#   SATISFIED worktree
#
# 退出码：
#   0 = 判定完成（REQUIRED / EXEMPT / SATISFIED）
#   2 = 参数缺失/非法（fail-closed）
#
# 判定语义（本脚本只做“是否需要隔离”的判定，不替代 AGENTS §11.5 的人工例外登记流程）：
# - 若当前已在 git worktree（.git 为文件且指向 worktrees）或已处于非主工作树上下文（通过 git rev-parse 判定）：
#     输出 SATISFIED worktree（rc=0）
# - 否则按规则判定：
#     files_count==0 且 lines==0 => EXEMPT trivial: no changes specified
#     files_count>=2 => REQUIRED worktree: multi-file change (files=<N>)
#     delivery==1 => REQUIRED worktree: delivery Markdown/doc change (delivery=1)
#     lines>2 => REQUIRED worktree: change lines > 2 (lines=<N>)
#     else => EXEMPT trivial: non-delivery and <=2 lines (lines=<N>, files=<M>)

set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage:
  check-worktree-required.sh --files <path[,path...]> --lines <N> --delivery <0|1> [--cwd <dir>]

Notes:
  - --files: comma-separated list (use empty string or "none" for zero files)
  - --lines: integer >= 0 (estimated/actual changed lines)
  - --delivery: 0|1 (1 means delivery-type Markdown/long doc/novel/writing artifact)
  - --cwd: optional working directory for git detection
USAGE
}

FILES_CSV=""
LINES=""
DELIVERY=""
CWD=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --files)
      FILES_CSV="${2:-}"
      shift 2
      ;;
    --lines)
      LINES="${2:-}"
      shift 2
      ;;
    --delivery)
      DELIVERY="${2:-}"
      shift 2
      ;;
    --cwd)
      CWD="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown arg: $1" >&2
      usage
      exit 2
      ;;
  esac
done

# --- validate ---
if [[ -z "$FILES_CSV" && "$FILES_CSV" != "" ]]; then
  :
fi
# allow empty meaning zero files
if [[ -z "$FILES_CSV" ]]; then
  FILES_CSV="none"
fi

if [[ -z "$LINES" ]]; then
  echo "ERROR: --lines is required (integer >= 0)" >&2
  exit 2
fi
if ! [[ "$LINES" =~ ^[0-9]+$ ]]; then
  echo "ERROR: --lines must be a non-negative integer, got: $LINES" >&2
  exit 2
fi

if [[ -z "$DELIVERY" ]]; then
  echo "ERROR: --delivery is required (0|1)" >&2
  exit 2
fi
if [[ "$DELIVERY" != "0" && "$DELIVERY" != "1" ]]; then
  echo "ERROR: --delivery must be 0 or 1, got: $DELIVERY" >&2
  exit 2
fi

# 解析检查上下文 cwd：--cwd 优先，其次 TASK_WORKTREE_CHECK_CWD，默认当前 cwd
_check_cwd="${CWD:-${TASK_WORKTREE_CHECK_CWD:-}}"
if [[ -n "$_check_cwd" ]]; then
  if [[ ! -d "$_check_cwd" ]]; then
    echo "ERROR: check cwd not a directory: $_check_cwd" >&2
    exit 2
  fi
  cd "$_check_cwd"
fi

# --- detect if already in a worktree ---
# Heuristic: if .git is a file (not dir), it's a worktree-linked checkout in many setups,
# but more robustly check git common dir vs git dir.
is_in_worktree="false"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_dir="$(git rev-parse --git-dir 2>/dev/null || true)"
  common_dir="$(git rev-parse --git-common-dir 2>/dev/null || true)"
  # In a linked worktree, git-dir points to .git/worktrees/<id>, common-dir points to main .git
  if [[ -n "$git_dir" && -n "$common_dir" && "$git_dir" != "$common_dir" ]]; then
    is_in_worktree="true"
  fi
  # Also treat case where .git is a file in cwd as worktree marker (common)
  if [[ -f ".git" ]]; then
    # .git file means linked worktree (typical)
    is_in_worktree="true"
  fi
fi

if [[ "$is_in_worktree" == "true" ]]; then
  echo "SATISFIED worktree"
  exit 0
fi

# --- parse files ---
files_count=0
if [[ "$FILES_CSV" == "none" || -z "$FILES_CSV" ]]; then
  files_count=0
else
  # count by splitting commas (simple, no spaces expected)
  # shellcheck disable=SC2001
  IFS=',' read -r -a _arr <<< "$FILES_CSV"
  # filter empty
  for f in "${_arr[@]}"; do
    f_trim="$(echo "$f" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    if [[ -n "$f_trim" ]]; then
      files_count=$((files_count + 1))
    fi
  done
fi

# --- decide ---
if [[ "$files_count" -eq 0 && "$LINES" -eq 0 ]]; then
  echo "EXEMPT trivial: no changes specified"
  exit 0
fi

if [[ "$files_count" -ge 2 ]]; then
  echo "REQUIRED worktree: multi-file change (files=${files_count})"
  exit 0
fi

if [[ "$DELIVERY" == "1" ]]; then
  echo "REQUIRED worktree: delivery Markdown/doc change (delivery=1)"
  exit 0
fi

if [[ "$LINES" -gt 2 ]]; then
  echo "REQUIRED worktree: change lines > 2 (lines=${LINES})"
  exit 0
fi

echo "EXEMPT trivial: non-delivery and <=2 lines (lines=${LINES}, files=${files_count})"
exit 0