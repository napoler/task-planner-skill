#!/usr/bin/env bash
# allow-direct.sh — task-v055 用户明文豁免主进程委派门控的脚本入口
# [2026-09-07 task-v055] B-1 约束版:仅允许 --confirm-user-requested 显式参数触发
#
# 用法:
#   allow-direct.sh on --confirm-user-requested  # 写 30 分钟 .allow-direct 标记
#   allow-direct.sh off                          # 删标记
#   allow-direct.sh status                       # 显示当前状态
#
# 关键约束(B-1):
#   1. on 必须含 --confirm-user-requested 参数(无 → 拒绝并提示)
#   2. 同会话只能触发 1 次;第二次 on → 拒绝并提示
#   3. bypass 事件落 ledger-delegation.jsonl 供终验展示
#   4. 用户必须用明文方式在终端执行(非 LLM 自助)

set -u

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 解析活跃 plan dir(共享自 check-delegation.sh,简化版)
resolve_plan_dir() {
    local cwd="${1:-$PWD}"
    local plan_file=""
    if [ -f "$SKILL_ROOT/resolve-plan-dir.sh" ]; then
        plan_file="$(bash "$SKILL_ROOT/resolve-plan-dir.sh" "$cwd" 2>/dev/null || true)"
    fi
    if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
        dirname "$plan_file"
        return 0
    fi
    return 1
}

# 同会话二次检测:通过 .allow-direct.bypass-count 或临时 .session-owner 关联
# 简化策略:用 .allow-direct 自带 once_only 标记(每写一次追加 .bypass-count=1;后续 on 直接拒绝)
mark_already_used() {
    local plan_dir="$1"
    local f="$plan_dir/.allow-direct.bypass-count"
    local n; n="$(cat "$f" 2>/dev/null || echo 0)"
    case "$n" in ''|*[!0-9]*) n=0 ;; esac
    n=$(( n + 1 ))
    echo "$n" > "$f"
    [ "$n" -gt 1 ]
}

usage() {
    cat <<EOF
Usage: allow-direct.sh <on|off|status> [--confirm-user-requested]

Commands:
  on     开启主进程直接编辑授权窗口(30 分钟)
         必须含 --confirm-user-requested 参数,且同会话仅一次
  off    删除授权标记
  status 查看当前授权状态

NOTE: 此脚本仅在用户终端显式调用时生效,LLM 自助调用无效(B-1 约束)。
EOF
}

cmd_on() {
    local plan_dir
    plan_dir="$(resolve_plan_dir "$PWD" 2>/dev/null || true)"
    if [ -z "$plan_dir" ]; then
        printf '{"error":"no_active_plan","cwd":"%s"}\n' "$PWD" >&2
        exit 1
    fi

    # 检查 --confirm-user-requested
    local confirm=0
    for arg in "$@"; do
        [ "$arg" = "--confirm-user-requested" ] && confirm=1
    done
    if [ "$confirm" -ne 1 ]; then
        printf '{"error":"missing_confirm_flag","hint":"此操作仅限用户显式执行,请重新执行并加 --confirm-user-requested 参数(LLM 自助调用无效)"}\n' >&2
        exit 2
    fi

    # 单会话上限:检测 .allow-direct.bypass-count
    if [ -f "$plan_dir/.allow-direct.bypass-count" ]; then
        local used; used="$(cat "$plan_dir/.allow-direct.bypass-count" 2>/dev/null || echo 0)"
        case "$used" in ''|*[!0-9]*) used=0 ;; esac
        if [ "$used" -ge 1 ]; then
            printf '{"error":"already_used_this_session","hint":"同会话已用过 1 次,不再放行。如确需继续,新建 plan 目录或用户显式要求重启会话。"}\n' >&2
            exit 3
        fi
    fi

    # 写 .allow-direct 内容=now+1800 epoch
    local now; now="$(date +%s)"
    local stamp=$(( now + 1800 ))
    printf '%s' "$stamp" > "$plan_dir/.allow-direct"
    # bypass 计数
    mark_already_used "$plan_dir" >/dev/null
    # ledger 记录
    local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo 1970-01-01T00:00:00Z)"
    printf '{"ts":"%s","event":"allow_direct_on","expires_at":%s,"user_requested":true}\n' \
        "$ts" "$stamp" >> "$plan_dir/ledger-delegation.jsonl"

    printf '{"status":"on","expires_at":%s,"expires_in_sec":1800,"plan_dir":"%s","hint":"30 分钟内主进程白名单外 Write/Edit 放行,会被 ledger 记录并在终验展示"}\n' \
        "$stamp" "$plan_dir"
    exit 0
}

cmd_off() {
    local plan_dir
    plan_dir="$(resolve_plan_dir "$PWD" 2>/dev/null || true)"
    if [ -z "$plan_dir" ]; then
        printf '{"error":"no_active_plan","cwd":"%s"}\n' "$PWD" >&2
        exit 1
    fi
    if [ -f "$plan_dir/.allow-direct" ]; then
        rm -f "$plan_dir/.allow-direct"
        # bypass-count 保留(防止同会话重启 on)
        printf '{"status":"off","plan_dir":"%s"}\n' "$plan_dir"
    else
        printf '{"status":"already_off","plan_dir":"%s"}\n' "$plan_dir"
    fi
    exit 0
}

cmd_status() {
    local plan_dir
    plan_dir="$(resolve_plan_dir "$PWD" 2>/dev/null || true)"
    if [ -z "$plan_dir" ]; then
        printf '{"status":"no_active_plan","cwd":"%s"}\n' "$PWD"
        exit 0
    fi
    local f="$plan_dir/.allow-direct"
    if [ ! -f "$f" ]; then
        printf '{"status":"off","plan_dir":"%s"}\n' "$plan_dir"
        exit 0
    fi
    local stamp; stamp="$(cat "$f" 2>/dev/null | tr -cd '0-9')"
    case "$stamp" in ''|*[!0-9]*) stamp=0 ;; esac
    local now; now="$(date +%s)"
    local remain=$(( stamp - now ))
    local used; used="$(cat "$plan_dir/.allow-direct.bypass-count" 2>/dev/null || echo 0)"
    case "$used" in ''|*[!0-9]*) used=0 ;; esac
    if [ "$remain" -le 0 ]; then
        printf '{"status":"expired","plan_dir":"%s","expired_sec_ago":%d,"used_count":%d}\n' "$plan_dir" "$((-remain))" "$used"
    else
        printf '{"status":"on","plan_dir":"%s","remain_sec":%d,"used_count":%d}\n' "$plan_dir" "$remain" "$used"
    fi
    exit 0
}

case "${1:-}" in
    on) shift; cmd_on "$@" ;;
    off) cmd_off ;;
    status) cmd_status ;;
    -h|--help|"") usage ;;
    *) printf '{"error":"unknown_subcommand","subcommand":"%s"}\n' "$1" >&2; usage; exit 2 ;;
esac