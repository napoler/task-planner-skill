#!/usr/bin/env bash
# 2026-10-22 | P1-S3 | 项目知识库增量入库（knowledge/entries/）
# 用法: scripts/kb-sync-from-plan.sh <plan-dir>（绝对/相对路径均可）
# 职责: 机械提取 <plan-dir>/knowledge-brief.md 的 §2/§3/§4 三段原文；
#       kb 占位（缺失/含「（待填充」/行数<75 且三节提取为空）时 fallback 用
#       findings.md 的 ^## 标题+各标题下前 3 行生成骨架；两者皆无 → exit 1。
#       产出 knowledge/entries/_draft-<task-id>.md（task-id=basename 入参目录名）
#       供后续人/模型精炼。draft 是派生物：同名已存在直接覆盖（可随时重建）。
# Why: 归档 kb 中约半数（58/113）为模板占位，须先识别再蒸馏；零外部依赖
#       （仅 bash+awk+grep+date）保证任意 CWD 可运行。
set -euo pipefail

# 入参：缺参报用法 exit 2（区别于「无可蒸馏内容」的 exit 1）
[ $# -ge 1 ] || { echo "用法: $0 <plan-dir>" >&2; exit 2; }

# 仓库根探测：git -C 定位（约定脚本在 <root>/scripts/），失败回落 dirname/..
ROOT="$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel 2>/dev/null || dirname "$(cd "$(dirname "$0")" && pwd -P)" )"
KB_DIR="$ROOT/knowledge"

# 目录校验+规范化：cd 按 CWD 解析相对路径，pwd -P 解 symlink（sources 记真实路径；
# task-id 仍取入参目录名，允许以别名目录生成规范 id）
TASK_ID="$(basename "$1")"
P="$(cd "$1" 2>/dev/null && pwd -P)" || { echo "错误: plan 目录不存在: $1" >&2; exit 3; }
KB="$P/knowledge-brief.md"
FIND="$P/findings.md"
DRAFT="$KB_DIR/entries/_draft-$TASK_ID.md"

# 占位检测判据: kb 缺失 / 含「（待填充」特征 / 行数<75 且 §2-§4 提取为空
# Why: 短 kb（如 62 行）若三节有实质内容不算占位——行数仅作软判据，
#      与「提取为空」合取才降级，避免实质 kb 被误判
kb_sections() {
  [ -f "$KB" ] || return 0
  awk '/^##[[:space:]]/ { if ($2 == "§2" || $2 == "§3" || $2 == "§4") s = 1; else s = 0 } s { print }' "$KB"
}
is_placeholder() {
  [ -f "$KB" ] || return 0
  grep -q "（待填充" "$KB" && return 0
  [ "$(wc -l < "$KB")" -lt 75 ] && [ -z "$(kb_sections)" ] && return 0
  return 1
}

SECTION=""
SRC_DESC=""
if ! is_placeholder; then
  # 主源: §2/§3/§4 原文逐字保留（各段=该标题行到下一 ^## 前）
  SECTION="$(kb_sections)"
  SRC_DESC="$KB"
fi
if [ -z "$SECTION" ] && [ -f "$FIND" ]; then
  # fallback 骨架: ^## 标题 + 各标题下前 3 个非空行（Why: 占位 kb 无 § 结构可提）
  SECTION="$(awk '/^##[[:space:]]/ { print; c = 0; next } NF && c < 3 { print; c++ }' "$FIND")"
  SRC_DESC="$FIND (占位 fallback 骨架)"
fi
if [ -z "$SECTION" ]; then
  echo "错误: 无可蒸馏内容 — kb 缺失/占位且 $P 下无 findings.md" >&2
  exit 1
fi

mkdir -p "$KB_DIR/entries"
# draft 是派生物（可随时重建），同名覆盖不视为错误
[ -f "$DRAFT" ] && echo "注: 同名 draft 已存在，覆盖: $DRAFT"

# sources 记仓相对路径（Why: draft 随仓提交，worktree 合并回主仓并清理后绝对路径锚会失效；
# 仓相对路径在任何检出位置都指回同一归档文件——持久化要求 2026-10-22）
rel_to_repo() { # What: 把绝对路径规约为仓相对路径; Why: sources 持久锚
  case "$1" in
    "$ROOT"/*) printf '%s' "${1#"$ROOT"/}" ;;
    *) printf '%s' "$1" ;;
  esac
}
KB_REL="$(rel_to_repo "$KB")"
FIND_REL="$(rel_to_repo "$FIND")"
SRC_DESC="${SRC_DESC#"$ROOT"/}"  # 修(2026-10-22 task-kb-fix-draft-path 遗留①)：正文标题行同步去 ROOT 前缀——原 SRC_DESC 用绝对路径使 draft 重跑时内嵌 /home/... 致 tracked 文件变脏

# 生成 draft: frontmatter 五键 + 提取正文 + 末尾精炼指引 HTML 注释
{
  echo "---"
  echo "id: draft-$TASK_ID"
  echo "title: \"（draft）$TASK_ID 知识蒸馏待精炼\""
  echo "tags: [draft, 未精炼]"
  echo "sources: [$KB_REL, $FIND_REL]"
  echo "updated: $(date +%F)"
  echo "---"
  echo ""
  echo "# （draft）$TASK_ID 知识蒸馏（来源: $SRC_DESC）"
  echo ""
  printf '%s\n' "$SECTION"
  echo ""
  echo "<!-- 精炼指引: 合并去重 → 主题化 → 补证据锚行号 → 去除 draft 前缀改名后重跑 kb-rebuild-index.sh -->"
} > "$DRAFT"
echo "OK: 已生成 $DRAFT ($(wc -l < "$DRAFT") 行)"
