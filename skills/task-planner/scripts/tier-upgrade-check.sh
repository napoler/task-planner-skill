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

set -u
input="$(cat 2>/dev/null || true)"

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
