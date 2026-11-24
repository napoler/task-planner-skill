#!/usr/bin/env bash
# tier-upgrade-check.sh — 非 zcode 工具位 PostToolUse tier 升档检查（通用 plain-text 宿主）
# [task-tier-deadzone-fix-20261125]
# What: 供 claude/cursor/opencode PostToolUse 注册调用；stdin 解析 session_id/cwd → resolve-plan-dir.sh
#       定位活跃计划 → source lib/tier-upgrade-lib.sh → tier_upgrade_check。zcode 位不改注册（实位在用户
#       cli/config.json，改个人配置须授权），zcode 继续走 zcode-posttooluse.sh 内嵌宿主。
# Why: 死角#1 跨工具——三位 PostToolUse 原仅挂 check-doc-sync.sh，零 tier 逻辑，mini 计划永不升级。
# 输出契约：plain text 单行（tier_emit 默认 printf）；平台若忽略 stdout 亦无害——升级链幂等，下轮重试。
# fail-open：stdin/解析/jq 缺失/无活跃计划 → exit 0 静默，不阻塞工具调用。
# 零 home-dir 硬编码路径（部署位白名单外新文件）。

# [R2/F5] 有意不随仓内 `set -euo pipefail` 惯例：本脚本是 PostToolUse hook 体，fail-open 优先——
#   -e 会让任一步非零（jq 解析失败/无活跃计划）中断链路并向平台冒泡错误；-o pipefail 同理。
#   宽容仅在「不阻塞工具调用」这一已声明的 hook 契约下成立，非通用脚本范式。
set -u
# [R2/F5] 终端直跑防挂起：stdin 为 TTY 时 cat 会一直等 EOF（SKILL.md 声明本脚本可手动跑）。
# hook 场景 stdin 恒为 JSON 管道（非 TTY），两条路径互不干扰。
if [ -t 0 ]; then
  input=""
else
  input="$(cat 2>/dev/null || true)"
fi

SID="$(printf '%s' "$input" | jq -r '.session_id // .sessionId // empty' 2>/dev/null | tr -cd 'a-zA-Z0-9' | head -c 40)"
SID="${SID:-default}"
CWD="$(printf '%s' "$input" | jq -r '.cwd // .workspaceRoots[0] // empty' 2>/dev/null)"
CWD="${CWD:-$PWD}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOLVER="$SCRIPT_DIR/resolve-plan-dir.sh"
[ -f "$RESOLVER" ] || exit 0

plan="$(bash "$RESOLVER" "$CWD" "$SID" 2>/dev/null || true)"
[ -n "$plan" ] && [ -f "$plan" ] || exit 0
plan_dir="$(dirname "$plan")"
plans_root="$(dirname "$plan_dir")"

# plain-text tier_emit（默认已足够，显式声明便于审计）
tier_emit() { printf '%s\n' "$1"; }

LIB="$SCRIPT_DIR/lib/tier-upgrade-lib.sh"
[ -f "$LIB" ] || exit 0
# shellcheck source=lib/tier-upgrade-lib.sh
. "$LIB"

tier_upgrade_check "$plan" "$SID" "$plan_dir" "$plans_root"
exit 0
