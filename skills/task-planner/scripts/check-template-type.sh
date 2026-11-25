#!/usr/bin/env bash
# [2026-09-15 task-v074 Rule 34] check-template-type.sh — 模板选取门控 (Rule 34.1)
# [2026-11-25 task-json-template P5] JSON 原生模板纳入白名单：
#   白名单 = general(恒合法) + templates/json/*.template.json 派生的类型名 + templates/variant/*-type.md（旧 MD 兼容）
# WHY: P1/P3 已切 JSON 模板为源；门控若只认 MD 会把 JSON-only 类型误判为非法。
# 提取顺序: frontmatter `^template_type:` → 表格行 `| template_type |` 第二列 → HTML 注释 `<!-- template_type: X -->`（task-v086 S7-1: mini-lite/init frontmatter 插入产物为注释形态, 第三形态补齐否则 gate 视角=缺失, enforce 档拒锁）
#   [2026-11-25 P5] → 第四形态：同目录 plan-state.json 的 template_type / template_ref（JSON 模板为源时 render 视图可能不带 MD 标记，缺此回退=误判失败）
# Usage: check-template-type.sh <task_plan.md>
# exit: 0=合法 1=缺失/非法/文件不存在 2=用法错误
set -u

[ "$#" -eq 1 ] || { echo "usage: check-template-type.sh <task_plan.md>" >&2; exit 2; }
plan_file="$1"
[ -f "$plan_file" ] || { echo "[template-gate] INVALID: 文件不存在: $plan_file" >&2; exit 1; }

SKILL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# 白名单动态派生: general + json 目录 <type>.template.json 去后缀 + variant 目录 <type>-type.md 去后缀 (Rule 34.1 禁硬编码副本)
# task_plan.template.json 的 meta.template_type=general，按文件名映射会多出 task_plan；显式剔除，general 已恒合法。
# tr '\n' ' ' 保证 VALID 单行, 供 grep 匹配
VALID="$( { ls "$SKILL_ROOT/templates/json/"*.template.json 2>/dev/null || true; \
            ls "$SKILL_ROOT/templates/variant/"*-type.md 2>/dev/null || true; } \
          | sed 's/.*\///;s/\.template\.json$//;s/-type\.md$//' \
          | grep -v '^task_plan$' | sort -u | tr '\n' ' ')"
# [2026-11-25 task-json-template-recommend] 项目级 JSON 权威源类型入白名单：
# 从 <task_plan.md> 所在目录向上找 .claude|zcode/plan-templates，只认该目录（含 json/ 子目录）内的
# *.template.json，禁任意路径 JSON 伪装；无项目 JSON 时本串为空，VALID 与改前逐字节一致。
_pj_types=""
_walk_dir="$(cd "$(dirname "$plan_file")" && pwd)"
while [ "$_walk_dir" != "/" ]; do
    _pj_root=""
    if [ -d "$_walk_dir/.claude/plan-templates" ]; then _pj_root="$_walk_dir/.claude/plan-templates"; fi
    if [ -z "$_pj_root" ] && [ -d "$_walk_dir/.zcode/plan-templates" ]; then _pj_root="$_walk_dir/.zcode/plan-templates"; fi
    if [ -n "$_pj_root" ]; then
        _pj_types="$( { ls "$_pj_root"/*.template.json 2>/dev/null; ls "$_pj_root"/json/*.template.json 2>/dev/null; } \
                      | sed 's/.*\///;s/\.template\.json$//' | grep -v '^task_plan$' | sort -u | tr '\n' ' ')"
        break
    fi
    _walk_dir="$(dirname "$_walk_dir")"
done
VALID="general $VALID $_pj_types"
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

# [2026-11-25 P5] 第四形态（JSON 权威源）：MD 三形态均缺时读同目录 plan-state.json 的 type/ref。
# WHY: planctl --template-json 生成的计划只在 JSON 里留 template_ref，render 视图不带 MD 标记；不回退会把合法 JSON 计划误判为缺失。
if [ -z "$tt" ]; then
  state_file="$(dirname "$plan_file")/plan-state.json"
  if [ -f "$state_file" ]; then
    tt="$(grep -m1 -oE '"template_type"[[:space:]]*:[[:space:]]*"[A-Za-z0-9-]+"' "$state_file" 2>/dev/null | sed 's/.*:[[:space:]]*"//;s/"$//')"
    if [ -z "$tt" ]; then
      ref="$(grep -m1 -oE '"template_ref"[[:space:]]*:[[:space:]]*"[^"]+"' "$state_file" 2>/dev/null | sed 's/.*:[[:space:]]*"//;s/"$//')"
      case "$(basename "$ref")" in
        task_plan.template.json) tt="general" ;;
        *.template.json) tt="${ref##*/}"; tt="${tt%.template.json}" ;;
        *-type.md) tt="${ref##*/}"; tt="${tt%-type.md}" ;;
      esac
    fi
  fi
fi

if [ -n "$tt" ] && printf ' %s ' "$VALID" | grep -q " $tt "; then
  echo "[template-gate] OK: template_type=$tt"
  exit 0
fi
if [ -z "$tt" ]; then
  echo "[template-gate] INVALID: 缺失 template_type (行首直书/表格行/注释/plan-state.json 四形态均未找到)" >&2
else
  echo "[template-gate] INVALID: template_type=$tt 不在白名单内" >&2
fi
echo "[template-gate] 合法值:$VALID" >&2
exit 1
