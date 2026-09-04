#!/usr/bin/env bash
# set-active-plan.sh — 设置/查看活跃计划指针 plans/.active_plan
# (移植适配自上游 planning-with-files v3;本仓无 .planning 布局,指针放 plans/ 下)
#
# 用法:
#   set-active-plan.sh <task-id> [project-root]   # 设置指针
#   set-active-plan.sh --show [project-root]      # 查看当前解析结果
#   set-active-plan.sh --clear [project-root]     # 清除指针(回退 mtime 最新)
#
# 指针生效后 hook(zcode-userpromptsubmit/zcode-posttooluse)经 resolve-plan-dir.sh
# 优先解析指针计划,不再按 mtime 猜测——多计划并行时消除注入歧义。

set -u

usage() {
    printf 'Usage: %s <task-id>|--show|--clear [project-root]\n' "$0" >&2
    exit 2
}

ACTION="${1:-}"
case "$ACTION" in
    ''|-h|--help) usage ;;
esac
shift
ROOT="${1:-$PWD}"
PLAN_ROOT="${ROOT}/plans"
ACTIVE_FILE="${PLAN_ROOT}/.active_plan"

case "$ACTION" in
    --show)
        if [ -f "$ACTIVE_FILE" ]; then
            printf '指针: %s -> %s\n' "$ACTIVE_FILE" "$(tr -d ' \r\n\t' < "$ACTIVE_FILE")"
        else
            printf '指针: 无(回退 mtime 最新)\n'
        fi
        resolved="$(bash "$(cd "$(dirname "$0")" && pwd)/resolve-plan-dir.sh" "$ROOT" 2>/dev/null || true)"
        printf '解析: %s\n' "${resolved:-<无计划>}"
        exit 0
        ;;
    --clear)
        rm -f "$ACTIVE_FILE" && echo "[active-plan] 指针已清除,回退 mtime 最新"
        exit 0
        ;;
esac

# 设置模式:校验 task-id 与计划目录存在
pid="$ACTION"
case "$pid" in
    ''|*[!A-Za-z0-9._-]*|[.]*)
        echo "[active-plan] 非法 task-id: $pid" >&2
        exit 2
        ;;
esac
if [ ! -f "${PLAN_ROOT}/${pid}/task_plan.md" ]; then
    echo "[active-plan] 计划不存在: ${PLAN_ROOT}/${pid}/task_plan.md" >&2
    exit 2
fi
printf '%s\n' "$pid" > "$ACTIVE_FILE"
echo "[active-plan] 指针已设置: ${pid}(${ACTIVE_FILE})"
exit 0
