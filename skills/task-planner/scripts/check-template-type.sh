#!/usr/bin/env bash
# [2026-09-15 task-v074 Rule 34] check-template-type.sh — 模板选取门控 (Rule 34.1)
# 校验 task_plan.md 的 template_type ∈ 白名单(动态派生, 无硬编码副本):
#   白名单 = general(恒合法) + templates/variant/*-type.md 派生的类型名
# 提取顺序: frontmatter `^template_type:` → 表格行 `| template_type |` 第二列 → HTML 注释 `<!-- template_type: X -->`（task-v086 S7-1: mini-lite/init frontmatter 插入产物为注释形态, 第三形态补齐否则 gate 视角=缺失, enforce 档拒锁）
# Usage: check-template-type.sh <task_plan.md>
# exit: 0=合法 1=缺失/非法/文件不存在 2=用法错误
set -u

[ "$#" -eq 1 ] || { echo "usage: check-template-type.sh <task_plan.md>" >&2; exit 2; }
plan_file="$1"
[ -f "$plan_file" ] || { echo "[template-gate] INVALID: 文件不存在: $plan_file" >&2; exit 1; }

SKILL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# 白名单动态派生: general + variant 目录 <type>-type.md 去后缀 (Rule 34.1 禁硬编码副本)
# tr '\n' ' ' 保证 VALID 单行, 供 grep 匹配
VALID="general $(ls "$SKILL_ROOT/templates/variant/"*-type.md 2>/dev/null | sed 's/.*\///;s/-type\.md$//' | tr '\n' ' ')"
VALID="$(printf '%s' "$VALID" | tr -s ' ')"

tt="$(grep -m1 '^template_type:' "$plan_file" 2>/dev/null | sed 's/^template_type:[[:space:]]*//;s/[[:space:]]*$//')"
# frontmatter 值取首个空白/全角括号前 token (如 "general（沿用...）" → general)
tt="${tt%%[[:space:]（]*}"
if [ -z "$tt" ]; then
  tt="$(grep -m1 '|[[:space:]]*template_type[[:space:]]*|' "$plan_file" 2>/dev/null | awk -F'|' '{gsub(/[[:space:]]/,"",$3); print $3}' | sed 's/（.*//')"
fi

if [ -z "$tt" ]; then
  # 第三形态 (task-v086 S7-1): HTML 注释 form `<!-- template_type: X -->`（mini-lite 模板/init frontmatter 插入产物形态）
  tt="$(grep -m1 -oE '<!--[[:space:]]*template_type:[[:space:]]*[A-Za-z0-9-]+' "$plan_file" 2>/dev/null | sed 's/.*template_type:[[:space:]]*//')"
fi

if [ -n "$tt" ] && printf ' %s ' "$VALID" | grep -q " $tt "; then
  echo "[template-gate] OK: template_type=$tt"
  exit 0
fi
if [ -z "$tt" ]; then
  echo "[template-gate] INVALID: 缺失 template_type (行首直书/表格行/注释 form 三形态均未找到)" >&2
else
  echo "[template-gate] INVALID: template_type=$tt 不在白名单内" >&2
fi
echo "[template-gate] 合法值:$VALID" >&2
exit 1
