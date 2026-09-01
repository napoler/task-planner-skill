#!/usr/bin/env bash
# sync-companion.sh — 反向同步:把 ~/.zcode(或 ~/.claude)中的伴随文件修改拉回 companion/
#
# 用途:在 ~/.zcode/agents/plan-writer.md 等文件上做了修改后,运行本脚本把最新版
# 同步回 canonical 仓的 companion/ 目录,commit 后新机器即可一键安装到最新版。
#
# Usage:
#   bash scripts/sync-companion.sh [--dry-run] [--diff]
#
#   --dry-run   只显示差异,不写 companion/
#   --diff      对有差异的文件输出完整 diff
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(dirname "$SCRIPT_DIR")"
COMPAANION_DIR="${TASK_PLANNER_ROOT:-$SKILL_ROOT}/companion"
DRY_RUN=0
SHOW_DIFF=0

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --diff) SHOW_DIFF=1; shift ;;
    -h|--help) sed -n '2,14p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ -z "${TASK_PLANNER_ROOT:-}" ]; then
  # 源 root 探测:.zcode 优先(.claude 兜底)
  for cand in "$HOME/.zcode" "$HOME/.claude"; do
    [ -d "$cand" ] && TARGET_ROOT="$cand" && break
  done
fi
TARGET_ROOT="${TARGET_ROOT:-$HOME/.zcode}"

[ -d "$COMPAANION_DIR" ] || { echo "[sync] ERROR: companion dir missing: $COMPAANION_DIR" >&2; exit 1; }

echo "[sync] source root: $TARGET_ROOT"
echo "[sync] companion:   $COMPAANION_DIR"

changed=0; same=0; missing=0

# pull_one <companion-file> <src-file>
pull_one() {
  local cfile="$1" src="$2"
  if [ ! -f "$src" ]; then
    echo "  MISSING in source: $src (companion 保留不动)"; missing=$((missing+1)); return
  fi
  if cmp -s "$cfile" "$src"; then
    echo "  = ${cfile#$COMPAANION_DIR/} (no change)"
    same=$((same+1))
    return
  fi
  echo "  ← ${cfile#$COMPAANION_DIR/} (source newer/different)"
  [ "$SHOW_DIFF" -eq 1 ] && diff -u "$cfile" "$src" | head -60
  if [ "$DRY_RUN" -eq 0 ]; then
    cp "$src" "$cfile"
  fi
  changed=$((changed+1))
}

for f in "$COMPAANION_DIR"/agents/*.md; do
  [ -e "$f" ] || continue
  pull_one "$f" "$TARGET_ROOT/agents/$(basename "$f")"
done

for skill_dir in "$COMPAANION_DIR"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  for f in "$skill_dir"*; do
    [ -e "$f" ] || continue
    pull_one "$f" "$TARGET_ROOT/skills/$skill_name/$(basename "$f")"
  done
done

echo "[sync] summary: $changed pulled, $same unchanged, $missing missing-in-source (dry_run=$DRY_RUN)"
if [ "$changed" -gt 0 ] && [ "$DRY_RUN" -eq 0 ]; then
  echo "[sync] next: git add companion/ && git commit — 之后 install.sh 一键安装即为最新版"
fi
exit 0
