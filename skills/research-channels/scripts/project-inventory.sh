#!/usr/bin/env bash
# project-inventory.sh — 项目文件清单生成与陈旧判定（research-channels L2 索引层）
# What: 枚举 <root> 下文件产出确定性 TSV 索引（path\tbytes\tmtime\text），并提供 --check 陈旧判定。
# Why: 调研防遗漏的清单完整性保证——"没进索引=没被发现"；索引把"全局有什么"显形化，
#      让 L1 枚举/L3 检索有稳定基线，避免凭印象漏查。纯 bash+find/sort/stat/date/awk，零网络/零 python/jq。
# 修改注明原因/时间/原行为：初版 2026-11-26 新建。
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage: project-inventory.sh --root <dir> [--out <file>] [--check] [--exclude-add <glob>] [--quiet]
  --root <dir>         扫描根目录（必填）
  --out <file>         输出 TSV 路径（默认 <root>/.inventory.tsv）
  --check              陈旧判定：missing->exit 2, stale->exit 1, fresh->exit 0
  --exclude-add <glob> 追加排除 glob（可重复，匹配 basename）
  --quiet              减少非必要 stdout
USAGE
}

err() { printf '[project-inventory] ERROR: %s\n' "$*" >&2; }
info() { [ "$QUIET" = "1" ] || printf '[project-inventory] %s\n' "$*"; }

ROOT=""
OUT=""
CHECK=0
QUIET=0
declare -a EXTRA_EXCLUDES=()

while [ $# -gt 0 ]; do
  case "$1" in
    --root)
      [ $# -ge 2 ] || { err "--root requires a value"; usage; exit 1; }
      ROOT="$2"; shift 2 ;;
    --out)
      [ $# -ge 2 ] || { err "--out requires a value"; usage; exit 1; }
      OUT="$2"; shift 2 ;;
    --check)
      CHECK=1; shift ;;
    --exclude-add)
      [ $# -ge 2 ] || { err "--exclude-add requires a value"; usage; exit 1; }
      EXTRA_EXCLUDES+=("$2"); shift 2 ;;
    --quiet)
      QUIET=1; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      err "unknown argument: $1"; usage; exit 1 ;;
  esac
done

if [ -z "$ROOT" ]; then
  err "--root is required"; usage; exit 1
fi
if [ ! -d "$ROOT" ]; then
  err "root is not a directory: $ROOT"; exit 1
fi

# 规范化 root（去尾斜杠，保留 /）
ROOT="${ROOT%/}"
[ -n "$ROOT" ] || ROOT="/"

if [ -z "$OUT" ]; then
  OUT="$ROOT/.inventory.tsv"
fi

# 默认排除集（basename glob）；与 references/research-channels.md §6 一致
declare -a EXCLUDES=(
  ".git" "node_modules" "__pycache__" "*.pyc" "tmp" "dist" "build"
  ".venv" "venv" "target" ".zcode" ".plan-required" ".plan_required" "archive"
)

# 项目级 .inventory-ignore：每行一个 glob，空行/注释忽略
IGNORE_FILE="$ROOT/.inventory-ignore"
if [ -f "$IGNORE_FILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    # 去掉首尾空白（简单处理）
    line="$(printf '%s' "$line" | awk '{$1=$1;print}')"
    [ -z "$line" ] && continue
    case "$line" in \#*) continue ;; esac
    EXCLUDES+=("$line")
  done < "$IGNORE_FILE"
fi

# 追加命令行排除
if [ ${#EXTRA_EXCLUDES[@]} -gt 0 ]; then
  for e in "${EXTRA_EXCLUDES[@]}"; do EXCLUDES+=("$e"); done
fi

# 构建 find 排除表达式：对任意匹配 basename 的路径 -prune（目录）或 -not -name（文件）
# Why: 用 -prune 避免 descend 进排除目录，保证性能与语义正确。
build_find_args() {
  local -n _args=$1
  _args=( "$ROOT" )
  if [ ${#EXCLUDES[@]} -gt 0 ]; then
    _args+=( "(" )
    local first=1
    for pat in "${EXCLUDES[@]}"; do
      if [ "$first" -eq 1 ]; then
        first=0
      else
        _args+=( -o )
      fi
      _args+=( -name "$pat" )
    done
    _args+=( ")" -prune -o )
  fi
  _args+=( -type f -print0 )
}

# 生成 TSV 行到 stdout（未排序）；格式 path\tbytes\tmtime\t ext
emit_rows() {
  local -a find_args=()
  build_find_args find_args
  # find -print0 | while read -d '' 安全处理特殊文件名
  find "${find_args[@]}" | while IFS= read -r -d '' f; do
    # 相对路径输出（相对 ROOT），便于索引可移植；root 本身用 .
    local rel
    if [ "$f" = "$ROOT" ]; then
      rel="."
    else
      rel="${f#"$ROOT"/}"
    fi
    local bytes mtime ext base
    bytes="$(stat -c '%s' -- "$f" 2>/dev/null)" || bytes=0
    local mt_epoch
    mt_epoch="$(stat -c '%Y' -- "$f" 2>/dev/null)" || mt_epoch=0
    mtime="$(date -u -d "@$mt_epoch" '+%Y-%m-%d %H:%M' 2>/dev/null)" || mtime="1970-01-01 00:00"
    base="${f##*/}"
    if [[ "$base" == *.* && "$base" != .* ]]; then
      ext="${base##*.}"
    elif [[ "$base" == .* && "$base" == *.*.* ]]; then
      ext="${base##*.}"
    else
      ext=""
    fi
    printf '%s\t%s\t%s\t%s\n' "$rel" "$bytes" "$mtime" "$ext"
  done
}

# 计算树内最新文件 mtime epoch（尊重排除）；无文件返回 0
latest_tree_epoch() {
  local -a find_args=()
  build_find_args find_args
  local latest=0
  while IFS= read -r -d '' f; do
    local mt
    mt="$(stat -c '%Y' -- "$f" 2>/dev/null)" || mt=0
    if [ "$mt" -gt "$latest" ]; then latest="$mt"; fi
  done < <(find "${find_args[@]}")
  printf '%s' "$latest"
}

if [ "$CHECK" -eq 1 ]; then
  if [ ! -f "$OUT" ]; then
    info "check: missing index: $OUT"
    exit 2
  fi
  idx_mtime="$(stat -c '%Y' -- "$OUT" 2>/dev/null)" || idx_mtime=0
  tree_latest="$(latest_tree_epoch)"
  if [ "$idx_mtime" -lt "$tree_latest" ]; then
    info "check: stale (index=$idx_mtime tree_latest=$tree_latest): $OUT"
    exit 1
  fi
  info "check: fresh: $OUT"
  exit 0
fi

# 生成模式：写临时文件后原子移动，保证中断不留半文件。
# Why: tmp 放在 OUT 同目录保证 mv 原子；同时把 tmp/out basename 加入排除，避免自包含。
tmp_out="$(mktemp "${OUT}.tmp.XXXXXX")"
cleanup() { rm -f -- "$tmp_out"; }
trap cleanup EXIT
tmp_base="${tmp_out##*/}"
out_base="${OUT##*/}"
# 仅当输出在 ROOT 内时排除自身，避免索引自包含导致非确定性/噪声
case "$OUT" in
  "$ROOT"/*|"$ROOT")
    EXCLUDES+=("$tmp_base" "$out_base")
    ;;
esac

# LC_ALL=C sort 全排序保证确定性输出
emit_rows | LC_ALL=C sort > "$tmp_out"
mv -- "$tmp_out" "$OUT"
trap - EXIT

# 统计行数用于 info
count="$(wc -l < "$OUT" | awk '{print $1}')"
info "wrote $count entries -> $OUT"
