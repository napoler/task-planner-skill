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

# ─── 平台 model 行适配(v2.2.2)─────────────────────────────────────────
# ZCode agent model 格式: custom:<provider-uuid>:<slug>(slug: sonnet-1/haiku-1/mini/opus-1/%2F 转义)
# Claude agent model 格式: 纯档位名(sonnet/haiku/opus/"mini"/"<自定义串>")
# companion/ 内文件统一存 ZCode 格式(修改源);安装到 Claude 平台时按此映射转换。
adapt_model_line() {
  # $1 = 目标文件(已 cp);仅当目标是 Claude 平台且文件含 ZCode 格式 model 行时改写
  local dst="$1"
  [[ "$TARGET_ROOT" == *.claude ]] || return 0
  grep -q '^model:.*custom:[0-9a-fA-F-]*:' "$dst" || return 0
  local slug pure
  slug="$(grep '^model:' "$dst" | head -1 | sed 's/^model:[[:space:]]*//; s/^"\(.*\)"$/\1/; s|^custom:[0-9a-fA-F-]*:||')"
  case "$slug" in
    sonnet-1) pure="sonnet" ;;
    haiku-1)  pure="haiku" ;;
    opus-1)   pure="opus" ;;
    mini)     pure="\"mini\"" ;;
    *)        pure="\"${slug//%2F//}\"" ;;  # 自定义模型:反转义 + 引号(Claude 侧惯例)
  esac
  sed -i "s|^model:.*|model: $pure|" "$dst"
  echo "  adapt: model → $pure (Claude 平台格式)"
}

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
  # 幂等比较需考虑平台适配:对 agents 文件先把 src 转成目标平台格式再比
  local cmp_src="$src" tmp_adapt=""
  if [[ "$dst" == */agents/*.md ]] && [[ "$TARGET_ROOT" == *.claude ]] && grep -q '^model:.*custom:[0-9a-fA-F-]*:' "$src"; then
    tmp_adapt="$(mktemp)"
    cp "$src" "$tmp_adapt"
    TARGET_ROOT="$TARGET_ROOT" adapt_model_line_quiet "$tmp_adapt"
    cmp_src="$tmp_adapt"
  fi
  if [ -f "$dst" ] && cmp -s "$cmp_src" "$dst"; then
    echo "  = $(basename "$dst") (identical, skip)"
    skipped=$((skipped+1))
    [ -n "$tmp_adapt" ] && rm -f "$tmp_adapt"
    return
  fi
  [ -n "$tmp_adapt" ] && rm -f "$tmp_adapt"
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
    case "$dst" in
      */agents/*.md) adapt_model_line "$dst" ;;
    esac
  fi
  if [ "$action" = "install" ]; then installed=$((installed+1)); else updated=$((updated+1)); fi
}

# 静默版(幂等比较用,不打印 adapt 行)
adapt_model_line_quiet() {
  local dst="$1"
  local slug pure
  slug="$(grep '^model:' "$dst" | head -1 | sed 's/^model:[[:space:]]*//; s/^"\(.*\)"$/\1/; s|^custom:[0-9a-fA-F-]*:||')"
  case "$slug" in
    sonnet-1) pure="sonnet" ;;
    haiku-1)  pure="haiku" ;;
    opus-1)   pure="opus" ;;
    mini)     pure="\"mini\"" ;;
    *)        pure="\"${slug//%2F//}\"" ;;
  esac
  sed -i "s|^model:.*|model: $pure|" "$dst"
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
    # 用 find -maxdepth 2 扫 skill 目录下一层子目录(支持 scripts/ 子目录结构)
    # 排除 .git / tests/ 等非同步内容
    while IFS= read -r -d '' f; do
      [ -e "$f" ] || continue
      rel="${f#$skill_dir}"          # scripts/scan-plans.sh
      sync_one "$f" "$TARGET_ROOT/skills/$skill_name/$rel"
    done < <(find "$skill_dir" -mindepth 1 -maxdepth 2 -type f -not -path '*/.git/*' \
                                -not -path '*/tests/*' \
                                -not -name '*.pyc' -not -name '*.md.bak' \
                                -print0)
  done
fi

echo "[companion] summary: $installed installed, $updated updated, $skipped skipped (dry_run=$DRY_RUN)"
if [ "$DRY_RUN" -eq 0 ] && [ "$updated" -gt 0 ]; then
  echo "[companion] NOTE: 更新的文件需重启会话生效(frontmatter model/tools 为快照语义)"
fi
exit 0
