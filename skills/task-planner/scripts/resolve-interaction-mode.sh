#!/usr/bin/env bash
# [task-v062-interaction-modes] 交互模式解析(Rule 28.1)
# 解析交互模式 ask|silent，优先级(Rule 28.1):
#   ① env TASK_PLANNER_INTERACTION_MODE (合法值 ask/silent; 非法值忽略, 降级下一级)
#   ② 参数指定计划的配置表行: <plan_dir>/task_plan.md 或 <plan_file> 中
#      `| \`interaction_mode\` | <val> |` 的值列 (trim 反引号/空白; 非法/缺行降级下一级)
#   ③ config.json: 脚本所在目录的 ../config.json (skill 级 config),
#      先查 .properties.interaction_mode.default, 再查顶层 .interaction_mode (未来实例化键)
#   ④ 兜底默认 ask
# fail-open 语义: 任何异常(jq 缺失/文件不可读/解析失败) 一律静默降级, 最终输出 ask;
# 退出码恒 0; stdout 仅一行 ask|silent。
# D6 硬停点(连续失败 STOP / drift BLOCKED / Q3 / 破坏性操作确认) 两模式一致不可豁免,
# 本脚本不改变该约束, 仅输出模式值供调用方(主进程/selftest/hook)分流。
#
# Usage:
#   resolve-interaction-mode.sh [plan_dir 或 plan_file]
#   - plan_dir  目录 → 取 <dir>/task_plan.md 的配置表行
#   - plan_file 文件路径 → 直接取该文件
#   - 无参数     → 跳过 ② 层, 直接 ① → ③ → ④
#
# 退出码: 0(恒; stdout = ask|silent 单行)

set -u

is_valid_mode() {
  case "$1" in
    ask|silent) return 0 ;;
    *) return 1 ;;
  esac
}

emit() {
  # 最终出口: 合法则原样输出, 否则兜底 ask
  if is_valid_mode "$1"; then
    printf '%s\n' "$1"
  else
    printf 'ask\n'
  fi
  exit 0
}

# ---- ① env 层 ----
if [ -n "${TASK_PLANNER_INTERACTION_MODE:-}" ]; then
  if is_valid_mode "$TASK_PLANNER_INTERACTION_MODE"; then
    emit "$TASK_PLANNER_INTERACTION_MODE"
  fi
  # 非法值 → 忽略, 降级 ②
fi

# ---- ② 计划配置表层 ----
plan_cfg_row=""
if [ $# -ge 1 ]; then
  p="$1"
  if [ -d "$p" ]; then
    plan_cfg_row="${p}/task_plan.md"
  elif [ -f "$p" ]; then
    plan_cfg_row="$p"
  fi
fi
if [ -n "$plan_cfg_row" ] && [ -r "$plan_cfg_row" ]; then
  # 配置表行形如: | `interaction_mode` | silent | ... |
  # 取行内第二个管道后的值列, trim 反引号/空白
  row_val=$(grep -E '^\|\s*`?interaction_mode`?' "$plan_cfg_row" 2>/dev/null | head -n1 | \
    awk -F'|' '{print $3}' 2>/dev/null)
  row_val="${row_val//\`/}"
  row_val="${row_val#"${row_val%%[![:space:]]*}"}"
  row_val="${row_val%"${row_val##*[![:space:]]}"}"
  if [ -n "$row_val" ] && is_valid_mode "$row_val"; then
    emit "$row_val"
  fi
  # 缺行/非法值 → 降级 ③
fi

# ---- ③ config.json 层 (脚本同级 skill 目录 ../config.json) ----
self_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null) || self_dir=""
cfg="${self_dir}/../config.json"
if [ -n "$self_dir" ] && [ -r "$cfg" ]; then
  if command -v jq >/dev/null 2>&1; then
    cfg_val=""
    # 先查 .properties.interaction_mode.default, 再查顶层 .interaction_mode (实例化键)
    cfg_val=$(jq -r '.properties.interaction_mode.default // empty' "$cfg" 2>/dev/null)
    if [ -z "$cfg_val" ]; then
      cfg_val=$(jq -r '.interaction_mode // empty' "$cfg" 2>/dev/null)
    fi
    if [ -n "$cfg_val" ] && is_valid_mode "$cfg_val"; then
      emit "$cfg_val"
    fi
  fi
  # jq 缺失或值非法 → 降级 ④
fi

# ---- ④ 兜底 ----
emit "ask"
