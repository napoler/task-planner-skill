#!/usr/bin/env bash
# install-companion.sh — 一键安装 task-planner 伴随文件(agents + 外部 skill)
#
# companion/ 目录存放 task-planner 运行所依赖、但位于 task-planner 目录之外的文件:
#   companion/agents/*.md                    → ~/.zcode/agents/  (或 ~/.claude/agents/)
#   companion/skills/task-drift-guard/*      → ~/.zcode/skills/task-drift-guard/
#
# Usage:
#   bash lib/install-companion.sh [--dry-run] [--force] [--target <tool-root>]
#
#   --dry-run        只显示将执行的动作,不写入
#   --force          内容不同时不备份直接覆盖(默认先备份到 companion/.backup-<date>/)
#   --target <dir>   工具根目录(默认自动探测: $HOME/.zcode → $HOME/.claude)
#
# 幂等:目标文件与 companion 内容一致时跳过;修改后想同步回仓,用 scripts/sync-companion.sh。
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(dirname "$SCRIPT_DIR")"
COMPAANION_DIR="${TASK_PLANNER_ROOT:-$SKILL_ROOT}/companion"
DRY_RUN=0
FORCE=0
TARGET_ROOT=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --force) FORCE=1; shift ;;
    --target) TARGET_ROOT="$2"; shift 2 ;;
    -h|--help) sed -n '2,16p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ ! -d "$COMPAANION_DIR" ]; then
  echo "[companion] ERROR: companion dir not found: $COMPAANION_DIR" >&2
  exit 1
fi

# 目标根探测:显式指定 > .zcode > .claude
if [ -z "$TARGET_ROOT" ]; then
  if [ -d "$HOME/.zcode" ]; then
    TARGET_ROOT="$HOME/.zcode"
  elif [ -d "$HOME/.claude" ]; then
    TARGET_ROOT="$HOME/.claude"
  else
    echo "[companion] ERROR: no tool root found (~/.zcode or ~/.claude); use --target" >&2
    exit 1
  fi
fi

BACKUP_DIR="$COMPAANION_DIR/.backup-$(date +%Y%m%d-%H%M%S)"
installed=0; skipped=0; updated=0

# sync_one <src> <dst>
sync_one() {
  local src="$1" dst="$2"
  local dst_dir; dst_dir="$(dirname "$dst")"
  if [ ! -f "$src" ]; then
    echo "[companion] WARN: companion file missing: $src"; return
  fi
  if [ ! -d "$dst_dir" ]; then
    echo "[companion] mkdir -p $dst_dir"
    [ "$DRY_RUN" -eq 0 ] && mkdir -p "$dst_dir"
  fi
  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
    echo "  = $(basename "$dst") (identical, skip)"
    skipped=$((skipped+1))
    return
  fi
  local action="install"
  if [ -f "$dst" ]; then
    action="update"
    if [ "$FORCE" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
      mkdir -p "$BACKUP_DIR/$(dirname "${dst#$TARGET_ROOT/}")"
      cp "$dst" "$BACKUP_DIR/$(basename "$dst")"
      echo "  backup: $(basename "$dst") → $BACKUP_DIR"
    fi
  fi
  echo "  $action: ${dst#$TARGET_ROOT/}"
  if [ "$DRY_RUN" -eq 0 ]; then
    cp "$src" "$dst"
  fi
  if [ "$action" = "install" ]; then installed=$((installed+1)); else updated=$((updated+1)); fi
}

echo "[companion] target root: $TARGET_ROOT"
echo "[companion] companion dir: $COMPAANION_DIR"

# 1. agents/*.md → <root>/agents/
if [ -d "$COMPAANION_DIR/agents" ]; then
  echo "[companion] agents:"
  for f in "$COMPAANION_DIR"/agents/*.md; do
    [ -e "$f" ] || continue
    sync_one "$f" "$TARGET_ROOT/agents/$(basename "$f")"
  done
fi

# 2. skills/<name>/ → <root>/skills/<name>/
if [ -d "$COMPAANION_DIR/skills" ]; then
  echo "[companion] skills:"
  for skill_dir in "$COMPAANION_DIR"/skills/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    for f in "$skill_dir"*; do
      [ -e "$f" ] || continue
      sync_one "$f" "$TARGET_ROOT/skills/$skill_name/$(basename "$f")"
    done
  done
fi

echo "[companion] summary: $installed installed, $updated updated, $skipped skipped (dry_run=$DRY_RUN)"
if [ "$DRY_RUN" -eq 0 ] && [ "$updated" -gt 0 ]; then
  echo "[companion] NOTE: 更新的文件需重启会话生效(frontmatter model/tools 为快照语义)"
fi
exit 0
