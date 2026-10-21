#!/usr/bin/env bash
# kb-search.sh — 项目知识库 (knowledge/) 统一检索入口 | 2026-10-22
# What: 关键词检索 knowledge/ 下全部 .md（entries/、INDEX.md、README.md），按文件
#      分组输出「== 相对路径」+ frontmatter 摘要（title/tags/sources 各一行，
#      sources 列表项逐行）+ 命中行（rg -i -n --no-heading）；--tag 依据首个
#      frontmatter 的 tags 段落过滤。
# Why:  条目为 markdown+frontmatter，裸 grep 无法做 tag 过滤与结构化摘要；仓库根
#      探测与 CWD 无关（仓内/CI/任意 CWD 均可运行）；rg 优先、缺失回落 grep -inr
#      （检索环境未必装 rg，环境鲁棒性）。
# Usage: kb-search.sh <关键词> [--tag <tag>] [--limit N]；limit 默认 20；
#      缺关键词 → 打印用法 exit 2；空库/无命中 → 友好提示 exit 0
set -u
# 参数解析：首个位置参数=关键词，--tag/--limit 为选项；limit 非数字回落默认 20
KEYWORD=""; TAG=""; LIMIT=20
while [ $# -gt 0 ]; do
  case "$1" in
    --tag)   [ $# -ge 2 ] || { echo "选项 $1 缺值" >&2; exit 2; }; TAG="$2"; shift 2 ;;
    --limit) [ $# -ge 2 ] || { echo "选项 $1 缺值" >&2; exit 2; }; LIMIT="$2"; shift 2 ;;
    *) [ -z "$KEYWORD" ] && KEYWORD="$1"; shift ;;
  esac
done
case "$LIMIT" in '' | *[!0-9]*) LIMIT=20 ;; esac
if [ -z "$KEYWORD" ]; then  # 缺关键词 → 打印用法 exit 2（规格）
  echo "用法: kb-search.sh <关键词> [--tag <tag>] [--limit N]   # limit 默认 20"
  exit 2
fi
# 仓库根探测：脚本目录上级跑 git rev-parse（worktree 内也正确）；失败回落 pwd
REPO_ROOT="$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "$0")/.." && pwd)")"
KB_DIR="$REPO_ROOT/knowledge"
# 收集 knowledge/ 下全部 .md（entries/、INDEX.md、README.md 均在检索范围）
files=()
if [ -d "$KB_DIR" ]; then
  while IFS= read -r f; do files+=("$f"); done < <(find "$KB_DIR" -type f -name '*.md' | LC_ALL=C sort)
fi
# 空库短路：knowledge/ 不存在或无条目 → 友好输出 exit 0（空库冒烟友好）
if [ ${#files[@]} -eq 0 ]; then
  echo "知识库为空（knowledge/ 无条目）"
  exit 0
fi
# 检索后端：rg 优先（不区分大小写+行号+无文件头）；缺 rg 回落 grep -inr
#（单文件 grep -n 与 rg 同为「行号:内容」格式，两种后端显示一致）
if command -v rg >/dev/null 2>&1; then
  search() { rg -i -n --no-heading -e "$1" -- "$2" || true; }
else
  search() { grep -inr -e "$1" -- "$2" || true; }
fi
# tags 段落 = 首个 frontmatter 块内 tags: 行 + 紧随列表项（Why: --tag 只看首个
# frontmatter；tags 单行 [a,b] 或多行 - 形式均子串匹配；无 tags 输出空=不命中）
#（实测坑：POSIX ERE 中 [[:blank:]] 只匹配单个空白，列表缩进 2 空格时
# ^[[:blank:]]- 不命中，故用 ^ *- 等价写法）
tags_of() {
  awk 'NR==1 && $0!="---" {exit} NR>1 && /^---/ {exit}
       /^tags:/ {print; intags=1; next}
       intags && /^ *- */ {print; next}
       {intags=0}' "$1"
}
# frontmatter 摘要：title/tags/sources 各一行，sources 列表项逐行（保持原值仅缩进）
summary_of() {
  awk 'NR==1 && $0!="---" {exit} NR>1 && /^---/ {exit}
       /^title:/   {sub(/^title: */,"  title: "); print; next}
       /^tags:/    {sub(/^tags: */,"  tags: "); print; next}
       /^sources:/  {insrc=1; sub(/^sources: */,"  sources: "); print; next}
       insrc && /^ *- */ {sub(/^ */,"    "); print; next}
       {insrc=0}' "$1"
}
# 主循环：--tag 过滤（先判）→ 关键词检索 → 分组输出；输出文件数达 limit 截断
count=0; hit_files=0
for f in "${files[@]}"; do
  rel="${f#"$REPO_ROOT"/}"
  if [ -n "$TAG" ]; then
    printf '%s\n' "$(tags_of "$f")" | grep -qF -- "$TAG" || continue  # 不命中该 tag 跳过此文件
  fi
  hits="$(search "$KEYWORD" "$f")"
  [ -z "$hits" ] && continue
  hit_files=$((hit_files + 1))
  echo "== $rel"
  summary_of "$f"
  echo "$hits"
  count=$((count + 1))
  [ "$count" -ge "$LIMIT" ] && break
done
# 无命中 → 友好提示 exit 0（规格；空库已上方短路，不会走到这里）
if [ "$hit_files" -eq 0 ]; then
  echo "无命中: $KEYWORD"
  exit 0
fi
