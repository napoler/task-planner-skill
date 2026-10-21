#!/usr/bin/env bash
# ============================================================================
# kb-rebuild-index.sh | 2026-10-22 | Author: Code Assistant (task-kb-persist-20261022 P1-S2)
# What: 扫描 knowledge/entries/*.md 首个 frontmatter 块 (id/title/tags/sources/updated)，
#       按文件名字典序生成 knowledge/INDEX.md；atomic 写 (tmp+mv)；entries/ 缺失 → 建空表
# Why:  INDEX.md 是派生聚合，本脚本是唯一写者（单写者原则），避免多批次并行写冲突
# 用法: kb-rebuild-index.sh [--dry-run]   # dry-run 仅打印将生成的 INDEX 到 stdout，不落盘
# 纪律: bash+awk 零外部依赖；inline 注释 What+Why 双层 (Rule 45)
# ============================================================================
set -uo pipefail        # Why: 条件分支全用显式 if，规避 set -e 与 && 列表的退出陷阱
LC_ALL=C; export LC_ALL # Why: C locale 字典序稳定排序，重 build 可复现 (diff 稳定)
# 仓库根探测：git 探测保证任意 CWD 可运行；非 git 环境回落到脚本目录的父级
REPO_ROOT="$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel 2>/dev/null)" || REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KB_DIR="$REPO_ROOT/knowledge"; ENTRIES="$KB_DIR/entries"
DRY=0; [ "${1:-}" = "--dry-run" ] && DRY=1
mkdir -p "$ENTRIES"    # Why: entries/ 不存在也要能生成空表，build 链路不断
ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
rows=""; n=0; warn=""
for f in "$ENTRIES"/*.md; do
  [ -e "$f" ] || continue # Why: 空目录时 glob 原样展开为字面路径，跳过
  base="$(basename "$f")"; name="${base%.md}"
  case "$base" in _draft-*) continue ;; esac  # Why: _draft- 是待精炼草稿，不入正式索引
  rel="${f#"$KB_DIR"/}"
  rc=0 # awk rc: 0=正常 / 2=缺 frontmatter / 3=缺 sources (两种均容忍收录, 仅 WARN)
  # 解析「首对 --- 之间」的 frontmatter 块，单次 awk 遍历零依赖
  row="$(awk -v rel="$rel" -v name="$name" '
    function trim(x) { gsub(/^[ \t]+|[ \t]+$/, "", x); return x }
    NR == 1 { if ($0 != "---") exit 2; next }
    $0 == "---" { ok = 1; exit }
    /^id:/     { id = trim(substr($0, 4)) }
    /^title:/  { ti = trim(substr($0, 7)) }
    /^tags:/   { tg = trim(substr($0, 6)) }
    /^sources:/ { insrc = 1; s = trim(substr($0, 9)); if (s != "") src = s }
    insrc && /^[ \t]*-[ \t]/ { s = trim($0); sub(/^-[ \t]*/, "", s); if (s != "") src = (src == "" ? s : src "<br>" s) }
    /^[^ \t-]/ && !/^sources:/ { insrc = 0 }  # Why: 新的顶层 key 结束 sources 多行列表; 排除 sources: 自身行 (避免同规则序内自灭)
    END {
      if (!ok) exit 2
      if (ti == "") ti = name  # Why: 缺 title 用文件名兜底，容忍半成品条目
      printf "| %s | %s | %s | %s | %s |\n", id, ti, tg, src, rel
      exit (src == "" ? 3 : 0)
    }
  ' "$f")" || rc=$?
  if [ "$rc" -eq 2 ]; then
    warn="${warn}WARN: ${base} 缺 frontmatter, title 回落文件名\n"; row="$(printf '|  | %s |  |  | %s |' "$name" "$rel")"
  elif [ "$rc" -eq 3 ]; then
    warn="${warn}WARN: ${base} 缺 sources, 仍收录\n"
  fi
  n=$((n + 1)); rows+="${row}"$'\n'
done
# 生成 INDEX 内容到 stdout；调用方决定落盘 (正式) 或仅打印 (--dry-run)
emit() { echo "# 知识库索引 (knowledge/INDEX.md)"; echo; echo "> 本文件由 scripts/kb-rebuild-index.sh 生成，勿手改 | 生成时间: ${ts} | 条目计数: ${n}"; echo; echo "| id | title | tags | sources | file |"; if [ -n "$rows" ]; then printf '%s' "$rows"; fi; }
if [ "$DRY" -eq 1 ]; then
  emit # dry-run: 只打印不落盘（规格要求）
else
  tmp="$KB_DIR/.INDEX.md.tmp.$$"
  emit > "$tmp"
  mv -f "$tmp" "$KB_DIR/INDEX.md"  # Why: 同目录 tmp+mv 原子替换，防半写损坏索引
fi
if [ -n "$warn" ]; then printf '%b' "$warn" >&2; fi
exit 0
