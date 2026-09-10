#!/usr/bin/env bash
# set-active-plan.sh — 设置/查看活跃计划指针
#   全局: plans/.active_plan            (单会话/cron 场景;原行为,兼容旧调用方)
#   会话: plans/.active_plan_side/<sid>.active_plan (2026-09-10 active-plan-race 新增,并行安全)
# (移植适配自上游 planning-with-files v3;本仓无 .planning 布局,指针放 plans/ 下)
#
# 2026-09-10 active-plan-race: 原行为=单文件全局指针,多并行会话互顶(后写者赢,
#   09-09 实锤 7 次 check-dispatch 误拦)。新增:
#   set-active-plan.sh set <task-id> [--sid s] [project-root]   # 会话私有指针(mktemp+mv 原子写,推荐)
#   set-active-plan.sh <task-id> [project-root]                 # 全局 legacy(=原位置参数行为)
#   set-active-plan.sh --show [--sid s] [project-root]          # 带 sid 时同时展示 side 与全局
#   set-active-plan.sh --clear [--sid s] [project-root]         # 清全局;--sid 时连 side 一起清
#   set-active-plan.sh gc [project-root]                         # 清扫 .active_plan_side/ 中 mtime>24h 的残留
#   sid 缺省 = env CLAUDE_CODE_SESSION_ID → default(规范化=剥非字母数字取前 40,与 hook 状态文件命名一致)
#
# 指针生效后 hook(zcode-userpromptsubmit/zcode-posttooluse)经 resolve-plan-dir.sh 解析
# (会话 side 优先 → 全局 legacy → mtime 最新),多计划并行时消除注入歧义。

set -u

usage() {
    printf 'Usage: %s {set <task-id>|<task-id>|--show|--clear|gc} [--sid s] [project-root]\n' "$0" >&2
    exit 2
}

norm_sid() {
    local s="$(printf '%s' "$1" | tr -cd 'a-zA-Z0-9' | head -c 40)"
    [ -n "$s" ] && printf '%s' "$s" || printf 'default'
}

ACTION="${1:-}"
case "$ACTION" in
    ''|-h|--help) usage ;;
esac
shift

# 剩余参数: --sid <val> 提取,余下为位置参数
SIDARG=""
positional=()
while [ $# -gt 0 ]; do
    case "$1" in
        --sid) SIDARG="${2:-}"; shift 2 ;;
        *) positional+=("$1"); shift ;;
    esac
done

# 各命令语义: set 模式位置参数=[task-id, root?];其余命令位置参数=[root?]
pid="${positional[0]:-}"
ROOT="${positional[1]:-${positional[0]:-$PWD}}"
case "$ACTION" in
    set) ;;                       # pid=positional[0],ROOT=positional[1]|PWD
    --show|--clear|gc)           # 无 task-id;位置参数[0]=root
        [ -n "$pid" ] && ROOT="${positional[0]:-$PWD}"
        [ -n "$pid" ] && unset 'positional[0]'
        pid=""
        ;;
    *) ROOT="${positional[0]:-$PWD}"; pid="$ACTION" ;;   # 旧位置参数模式: task-id 在 $ACTION
esac

PLAN_ROOT="${ROOT}/plans"
ACTIVE_FILE="${PLAN_ROOT}/.active_plan"
SIDE_DIR="${PLAN_ROOT}/.active_plan_side"
SID="$(norm_sid "${SIDARG:-${CLAUDE_CODE_SESSION_ID:-}}")"

validate_slug() {
    case "$1" in
        ''|*[!A-Za-z0-9._-]*|[.]*) return 1 ;;
    esac
    return 0
}

require_plan() {  # <slug> → 计划目录存在,否则报错 exit 2
    if [ ! -f "${PLAN_ROOT}/${1}/task_plan.md" ]; then
        echo "[active-plan] 计划不存在: ${PLAN_ROOT}/${1}/task_plan.md" >&2
        exit 2
    fi
}

atomic_write() {  # <target-file> <slug>(mktemp+mv 原子写;调用方保证 slug 已校验)
    local target="$1" slug="$2" tmp
    tmp="$(mktemp "$(dirname "$target")/.tmp.XXXXXX" 2>/dev/null)" || {
        echo "[active-plan] 无法在 $(dirname "$target") 创建临时文件" >&2; return 1
    }
    if printf '%s\n' "$slug" > "$tmp" 2>/dev/null; then
        mv -f "$tmp" "$target" 2>/dev/null || { rm -f "$tmp"; return 1; }
        return 0
    fi
    rm -f "$tmp"
    return 1
}

case "$ACTION" in
    --show)
        if [ -f "$ACTIVE_FILE" ] && [ ! -d "$ACTIVE_FILE" ]; then
            printf '全局指针: %s -> %s\n' "$ACTIVE_FILE" "$(tr -d ' \r\n\t' < "$ACTIVE_FILE")"
        else
            printf '全局指针: 无(回退 mtime 最新)\n'
        fi
        SIDE_FILE="${SIDE_DIR}/${SID}.active_plan"
        if [ -f "$SIDE_FILE" ]; then
            printf 'side 指针(sid=%s): %s\n' "$SID" "$(tr -d ' \r\n\t' < "$SIDE_FILE")"
        else
            printf 'side 指针(sid=%s): 无\n' "$SID"
        fi
        resolved="$(bash "$(cd "$(dirname "$0")" && pwd)/resolve-plan-dir.sh" "$ROOT" "$SID" 2>/dev/null || true)"
        printf '解析: %s\n' "${resolved:-<无计划>}"
        exit 0
        ;;
    --clear)
        rm -f "$ACTIVE_FILE" 2>/dev/null && echo "[active-plan] 全局指针已清除,回退 mtime 最新"
        if [ -n "$SIDARG" ] || [ -n "${CLAUDE_CODE_SESSION_ID:-}" ]; then
            rm -f "${SIDE_DIR}/${SID}.active_plan" 2>/dev/null && echo "[active-plan] side 指针已清除(sid=${SID})"
        fi
        exit 0
        ;;
    gc)
        # 清扫过期会话指针(mtime>24h;与会话重启/机器重启后的残留对齐 resolve 侧 TTL)
        n=0
        if [ -d "$SIDE_DIR" ]; then
            while IFS= read -r f; do
                rm -f "$f" 2>/dev/null && n=$((n+1))
            done < <(find "$SIDE_DIR" -name '*.active_plan' -type f -mmin +1440 2>/dev/null)
        fi
        echo "[active-plan] gc 清除过期 side 指针: ${n} 个"
        exit 0
        ;;
    set)
        validate_slug "$pid" || { echo "[active-plan] 非法 task-id: ${pid:-<空>}" >&2; exit 2; }
        require_plan "$pid"
        mkdir -p "$SIDE_DIR" 2>/dev/null || { echo "[active-plan] 无法创建 ${SIDE_DIR}" >&2; exit 1; }
        if atomic_write "${SIDE_DIR}/${SID}.active_plan" "$pid"; then
            echo "[active-plan] side 指针已设置: ${pid}(sid=${SID})"
        fi
        exit $?
        ;;
    *)
        validate_slug "$pid" || { echo "[active-plan] 非法 task-id: $pid" >&2; exit 2; }
        require_plan "$pid"
        if atomic_write "$ACTIVE_FILE" "$pid"; then
            echo "[active-plan] 全局指针已设置: ${pid}(${ACTIVE_FILE})"
        fi
        exit $?
        ;;
esac
