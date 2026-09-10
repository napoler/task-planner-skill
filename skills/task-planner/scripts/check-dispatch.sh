#!/usr/bin/env bash
# check-dispatch.sh — Agent() 派发契约守卫 (Rule 22.4c / 22.8.1, task-v057 Phase 4)
# 校验派发 prompt 是否含: 计划三文件绝对路径(task_plan.md/findings.md/progress.md)
# + 8 字段返回 key 必检标记(status: / acceptance: / checkpoint:) + subagent-state/ 检查点路径。
# 缺项按档位处置: enforce=exit 2 阻断 / warn=exit 0 + 落盘告警 / off=跳过。
#
# Usage:
#   check-dispatch.sh pretool <prompt-file> [sid]     # hook 入口: exit 0 放行 / exit 2 enforce 阻断([dispatch-block]→stderr)
#   check-dispatch.sh check <prompt-file> <plan-dir>  # 纯检查: stdout 每行一个缺项名; exit 0 无缺项 / 1 有缺项(与档位无关)
#
# 环境覆盖: TASK_PLANNER_DISPATCH_ENFORCE=enforce|warn|off (档位;未设则 jq 读 config.json)
#           TASK_PLANNER_PLAN_DIR=<dir> (计划目录;未设则 resolve-plan-dir.sh "$PWD" 输出取 dirname)
#
# fail-open (exit 0 + stderr 记录): 无活跃计划 / 计划目录不存在 / prompt 文件不可读 / jq 缺失
# 退出码: 0=放行|无缺项|fail-open; 1=check 有缺项; 2=enforce 阻断
set -u

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# [task-v057] BASH_SOURCE 推导出的 SKILL_ROOT 是 scripts/ 目录;config.json 在 skill 根(上一级)
CONFIG_JSON="$SKILL_ROOT/../config.json"

# 缺项扫描: $1=prompt 文件 $2=计划目录 → stdout 每行一个缺项名(固定顺序 P1..P3,R1..R3,C1)
# [p7fix] 计划目录归一化: 去尾斜杠 + 三文件匹配同时接受符号链接解析后的真实路径(pd_real)
scan_missing() {
    local f="$1" pd="$2" pd_real item alt
    pd="${pd%/}"; pd_real="$(cd "$pd" 2>/dev/null && pwd -P)"; pd_real="${pd_real:-$pd}"
    for item in "$pd/task_plan.md" "$pd/findings.md" "$pd/progress.md" "status:" "acceptance:" "checkpoint:" "subagent-state/"; do
        case "$item" in
        */task_plan.md|*/findings.md|*/progress.md)
            alt="${pd_real}/${item#"$pd"/}"; { grep -qF -- "$item" "$f" 2>/dev/null || grep -qF -- "$alt" "$f" 2>/dev/null; } || case "$item" in */task_plan.md) printf 'task_plan.md\n' ;; */findings.md) printf 'findings.md\n' ;; */progress.md) printf 'progress.md\n' ;; esac ;;
        *)
            grep -qF -- "$item" "$f" 2>/dev/null || printf '%s\n' "$item" ;;
        esac
    done
}

# 档位解析: 环境变量优先;未设 → jq 读 .properties.dispatch_contract_enforce.default // "enforce"
# (config 缺失/jq 解析失败 → enforce;jq 二进制缺失 → "nojq" sentinel,调用方 fail-open)
get_mode() {
    local m="${TASK_PLANNER_DISPATCH_ENFORCE:-}"
    if [ -n "$m" ]; then
        case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'enforce' ;; esac
        return 0
    fi
    if ! command -v jq >/dev/null 2>&1; then
        printf 'nojq'; return 0
    fi
    if [ ! -f "$CONFIG_JSON" ]; then
        printf 'enforce'; return 0
    fi
    m="$(jq -r '.properties.dispatch_contract_enforce.default // "enforce"' "$CONFIG_JSON" 2>/dev/null)" || m="enforce"
    case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'enforce' ;; esac
}

# 计划目录解析: 环境变量 TASK_PLANNER_PLAN_DIR 优先,否则 resolve-plan-dir.sh 输出(= task_plan.md 路径)取 dirname
# [2026-09-10 active-plan-race] resolver 二参带会话 sid(zcode-pretooluse.sh Agent 分支 export TASK_PLANNER_SID
# 传入;未设则回 env CLAUDE_CODE_SESSION_ID/resolver 内置 default) → .active_plan_side/<sid>.active_plan
# 会话私有指针优先,并行会话的派发守卫各查各的计划,不再被互顶的全局 legacy 指针误拦
resolve_plan_dir() {
    local pd="${TASK_PLANNER_PLAN_DIR:-}" pfile
    if [ -n "$pd" ]; then
        printf '%s' "$pd"; return 0
    fi
    pfile="$(bash "$SKILL_ROOT/resolve-plan-dir.sh" "$PWD" "${TASK_PLANNER_SID:-}" 2>/dev/null || true)"
    if [ -n "$pfile" ] && [ -f "$pfile" ]; then
        printf '%s' "$(dirname "$pfile")"
    fi
}

join_missing() { printf '%s\n' "$1" | tr '\n' ',' | sed 's/,$//'; }

cmd_pretool() {
    local pf="${1:-}" sid="${2:-unknown}"
    if [ -z "$pf" ]; then
        echo "[dispatch-guard] pretool: 缺 <prompt-file> 参数, fail-open" >&2; exit 0
    fi
    if [ ! -f "$pf" ] || [ ! -r "$pf" ]; then
        echo "[dispatch-guard] prompt 文件不可读($pf), fail-open" >&2; exit 0
    fi
    local mode pd missing names
    mode="$(get_mode)"
    if [ "$mode" = "nojq" ]; then
        echo "[dispatch-guard] jq 缺失, 派发契约守卫 fail-open" >&2; exit 0
    fi
    [ "$mode" = "off" ] && exit 0
    pd="$(resolve_plan_dir)"
    [ -n "$pd" ] && [ -d "$pd" ] || exit 0   # 无活跃计划/目录不存在 → fail-open
    missing="$(scan_missing "$pf" "$pd")"
    [ -n "$missing" ] || exit 0
    names="$(join_missing "$missing")"
    if [ "$mode" = "warn" ]; then
        echo "[dispatch-warn] ⚠ 派发契约缺项: $names"
        wf="${TMPDIR:-/tmp}/task-planner-dispatch-warn-${sid}"
        [ -f "$wf" ] && [ -n "$(find "$wf" -mmin +1440 2>/dev/null)" ] && rm -f "$wf"   # [p7fix] 24h TTL: 过期计数先清
        printf '%s [dispatch-warn] %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$names" \
            >> "$wf" 2>/dev/null || true
        exit 0
    fi
    echo "[dispatch-block] 🚫 派发契约缺项(Rule 22.4a/b/22.8.1): $names — prompt 须含计划三文件绝对路径 + 8 字段返回模板 + subagent-state 检查点路径(templates/subagent_dispatch.md §2/§7/§8)" >&2
    exit 2
}

cmd_check() {
    local pf="${1:-}" pd="${2:-}"
    if [ -z "$pf" ] || [ ! -f "$pf" ] || [ ! -r "$pf" ]; then
        echo "[dispatch-guard] check: prompt 文件不可读, fail-open" >&2; exit 0
    fi
    if [ -z "$pd" ] || [ ! -d "$pd" ]; then
        echo "[dispatch-guard] check: plan-dir 为空/不存在, fail-open" >&2; exit 0
    fi
    local missing
    missing="$(scan_missing "$pf" "$pd")"
    if [ -n "$missing" ]; then
        printf '%s\n' "$missing"
        exit 1
    fi
    exit 0
}

case "${1:-}" in
    pretool) cmd_pretool "${2:-}" "${3:-}" ;;
    check)   cmd_check "${2:-}" "${3:-}" ;;
    *) echo "[dispatch-guard] usage: pretool <prompt-file> [sid] | check <prompt-file> <plan-dir>" >&2; exit 0 ;;
esac
