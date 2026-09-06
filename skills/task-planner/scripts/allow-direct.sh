#!/usr/bin/env bash
# allow-direct.sh — task-v055 用户明文豁免主进程委派门控的脚本入口
# [2026-09-07 task-v055] B-1 约束版:仅允许 --confirm-user-requested 显式参数触发
# [2026-09-07 task-v055-fix-review] M-4:同 sid 仅一次(状态文件 /tmp/task-planner-bypass-<sid>);
#   计划目录 ledger 已记录过 bypass 时需额外 --force 才允许第二次(保留单会话语义收紧)
#
# 用法:
#   allow-direct.sh on --confirm-user-requested           # 写 30 分钟 .allow-direct 标记
#   allow-direct.sh on --confirm-user-requested --force   # 同 plan-dir 二次 bypass 需 --force
#   allow-direct.sh off                                   # 删标记
#   allow-direct.sh status                                # 显示当前状态
#
# 关键约束(B-1):
#   1. on 必须含 --confirm-user-requested 参数(无 → 拒绝并提示)
#   2. 同 sid 只能触发 1 次(状态文件 /tmp/task-planner-bypass-<sid>);同 plan-dir 二次 bypass → --force
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

# [2026-09-07 task-v055-fix-review] M-4:sid 规范化(仅 [a-zA-Z0-9_-],前 40 字节)
# 默认 "default"(命令行直接调用未带环境时)
detect_caller_sid() {
    local sid="${ZCODE_SID:-${UPS_SID:-default}}"
    sid="$(printf '%s' "$sid" | tr -cd 'a-zA-Z0-9_-' | head -c 40)"
    case "$sid" in "") sid="default" ;; esac
    printf '%s' "$sid"
}

# 检查 plan-dir ledger 中是否已有 bypass 事件
plan_dir_has_bypass() {
    local plan_dir="$1"
    [ -f "$plan_dir/ledger-delegation.jsonl" ] || return 1
    grep -q '"event":"bypass"' "$plan_dir/ledger-delegation.jsonl" 2>/dev/null
}

usage() {
    cat <<EOF
Usage: allow-direct.sh <on|off|status> [--confirm-user-requested] [--force]

Commands:
  on     开启主进程直接编辑授权窗口(30 分钟)
         必须含 --confirm-user-requested 参数
         同 sid 仅一次(/tmp/task-planner-bypass-<sid> 状态文件);
         若计划目录 ledger 已有 bypass 记录(同 plan-dir 二次),需额外 --force
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

    # 检查 --confirm-user-requested / --force
    local confirm=0
    local force=0
    for arg in "$@"; do
        [ "$arg" = "--confirm-user-requested" ] && confirm=1
        [ "$arg" = "--force" ] && force=1
    done
    if [ "$confirm" -ne 1 ]; then
        printf '{"error":"missing_confirm_flag","hint":"此操作仅限用户显式执行,请重新执行并加 --confirm-user-requested 参数(LLM 自助调用无效)"}\n' >&2
        exit 2
    fi

    # [2026-09-07 task-v055-fix-review] M-4:sid 维度单次闸门
    local sid
    sid="$(detect_caller_sid)"
    local sid_flag="/tmp/task-planner-bypass-${sid}"
    if [ -f "$sid_flag" ]; then
        printf '{"error":"sid_already_used","sid":"%s","hint":"同 sid 已用过 1 次(/tmp/task-planner-bypass-<sid> 存在);不再放行。新会话请清理 /tmp/task-planner-bypass-* 或重启会话。"}\n' "$sid" >&2
        exit 3
    fi

    # [2026-09-07 task-v055-fix-review] M-4:plan-dir 已有 bypass 记录 → 需 --force
    if plan_dir_has_bypass "$plan_dir"; then
        if [ "$force" -ne 1 ]; then
            printf '{"error":"plan_dir_already_bypassed","plan_dir":"%s","hint":"该计划目录 ledger-delegation.jsonl 已有 bypass 事件;如确需二次 bypass,加 --force 参数(将额外落 ledger)"}\n' "$plan_dir" >&2
            exit 4
        fi
        printf '[allow-direct] WARNING: plan-dir 二次 bypass(--force),plan_dir=%s sid=%s\n' "$plan_dir" "$sid" >&2
    fi

    # 写 .allow-direct 内容=now+1800 epoch
    local now; now="$(date +%s)"
    local stamp=$(( now + 1800 ))
    printf '%s' "$stamp" > "$plan_dir/.allow-direct"
    # [2026-09-07 task-v055-fix-review] sid 维度闸门:写状态文件
    printf '%s' "$sid" > "$sid_flag"
    # ledger 记录
    local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo 1970-01-01T00:00:00Z)"
    local force_tag=""
    [ "$force" -eq 1 ] && force_tag='"force":true,'
    printf '{"ts":"%s","event":"allow_direct_on","sid":"%s",%s"expires_at":%s,"user_requested":true}\n' \
        "$ts" "$sid" "$force_tag" "$stamp" >> "$plan_dir/ledger-delegation.jsonl"

    printf '{"status":"on","sid":"%s","expires_at":%s,"expires_in_sec":1800,"plan_dir":"%s","force":%s,"hint":"30 分钟内主进程白名单外 Write/Edit 放行,会被 ledger 记录并在终验展示;同 sid 已用,新会话前请清理 /tmp/task-planner-bypass-*"}\n' \
    "$sid" "$stamp" "$plan_dir" "$force"
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
        # sid 闸门 /tmp/task-planner-bypass-<sid> 保留(防止同会话重启 on)
        printf '{"status":"off","plan_dir":"%s"}\n' "$plan_dir"
    else
        printf '{"status":"already_off","plan_dir":"%s"}\n' "$plan_dir"
    fi
    exit 0
}

cmd_status() {
    local plan_dir
    plan_dir="$(resolve_plan_dir "$PWD" 2>/dev/null || true)"
    local sid; sid="$(detect_caller_sid)"
    local sid_flag="/tmp/task-planner-bypass-${sid}"
    if [ -z "$plan_dir" ]; then
        printf '{"status":"no_active_plan","cwd":"%s","sid":"%s","sid_used":%s}\n' "$PWD" "$sid" "$([ -f "$sid_flag" ] && echo true || echo false)"
        exit 0
    fi
    local f="$plan_dir/.allow-direct"
    if [ ! -f "$f" ]; then
        printf '{"status":"off","plan_dir":"%s","sid":"%s","sid_used":%s}\n' "$plan_dir" "$sid" "$([ -f "$sid_flag" ] && echo true || echo false)"
        exit 0
    fi
    local stamp; stamp="$(cat "$f" 2>/dev/null | tr -cd '0-9')"
    case "$stamp" in ''|*[!0-9]*) stamp=0 ;; esac
    local now; now="$(date +%s)"
    local remain=$(( stamp - now ))
    local ledger_bypass="false"
    plan_dir_has_bypass "$plan_dir" && ledger_bypass="true"
    if [ "$remain" -le 0 ]; then
        printf '{"status":"expired","plan_dir":"%s","expired_sec_ago":%d,"sid":"%s","sid_used":%s,"ledger_bypass":%s}\n' \
            "$plan_dir" "$((-remain))" "$sid" "$([ -f "$sid_flag" ] && echo true || echo false)" "$ledger_bypass"
    else
        printf '{"status":"on","plan_dir":"%s","remain_sec":%d,"sid":"%s","sid_used":%s,"ledger_bypass":%s}\n' \
            "$plan_dir" "$remain" "$sid" "$([ -f "$sid_flag" ] && echo true || echo false)" "$ledger_bypass"
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