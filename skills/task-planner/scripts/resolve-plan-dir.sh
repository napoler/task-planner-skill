#!/usr/bin/env bash
# resolve-plan-dir.sh — 解析当前活跃计划的 task_plan.md 路径
# (移植裁剪自上游 planning-with-files v3 scripts/resolve-plan-dir.sh:
#  保留解析链+slug 校验;裁剪 PWF_PLAN_ROOT pin/Windows 规范化/python/perl 兜底/containment
#  —— 本仓部署为 Linux glibc,slug 校验已阻路径穿越)
#
# 解析链:
#   1. plans/.active_plan 指针 → 指向的有效计划(slug 校验+task_plan.md 存在)
#   2. mtime 最新的 plans/<dir>/task_plan.md(跳过隐藏目录与非 slug 名)
#   3. legacy: <root>/task_plan.md(项目根单文件模式)
#   4. 全部未命中 → 空 stdout(caller 自行静默)
#
# 用法: PLAN_FILE="$(bash resolve-plan-dir.sh [project-root])"   # 默认 $PWD
# 恒 exit 0,不干扰 hook 调用方。

set -u

ROOT="${1:-$PWD}"
PLAN_ROOT="${ROOT}/plans"
ACTIVE_FILE="${PLAN_ROOT}/.active_plan"

# slug 安全校验:拒空白/路径分隔符/前导点(防 .active_plan 内容腐烂或路径穿越,上游同款)
slug_is_valid() {
    case "$1" in
        '') return 1 ;;
        *[!A-Za-z0-9._-]*) return 1 ;;
        [A-Za-z0-9_]*) return 0 ;;
    esac
    return 1
}

# 1. 指针优先
if [ -f "$ACTIVE_FILE" ]; then
    pid="$(tr -d ' \r\n\t' < "$ACTIVE_FILE" 2>/dev/null || true)"
    if slug_is_valid "$pid" && [ -f "${PLAN_ROOT}/${pid}/task_plan.md" ]; then
        printf '%s\n' "${PLAN_ROOT}/${pid}/task_plan.md"
        exit 0
    fi
fi

# 2. mtime 最新(跳过隐藏目录/非法 slug/无 task_plan.md 的目录)
latest=""
latest_mt=0
for d in "${PLAN_ROOT}"/*/; do
    [ -f "${d}task_plan.md" ] || continue
    name="$(basename "${d}")"
    case "$name" in .*) continue ;; esac
    slug_is_valid "$name" || continue
    mt="$(stat -c %Y "${d}" 2>/dev/null || echo 0)"
    if [ "${mt}" -gt "${latest_mt}" ]; then
        latest_mt="${mt}"
        latest="${d}task_plan.md"
    fi
done
if [ -n "$latest" ]; then
    printf '%s\n' "$latest"
    exit 0
fi

# 3. legacy 根目录单文件
if [ -f "${ROOT}/task_plan.md" ]; then
    printf '%s\n' "${ROOT}/task_plan.md"
fi
exit 0
