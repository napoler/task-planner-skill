#!/usr/bin/env bash
# resolve-plan-dir.sh — 解析当前活跃计划的 task_plan.md 路径
# (移植裁剪自上游 planning-with-files v3 scripts/resolve-plan-dir.sh:
#  保留解析链+slug 校验;裁剪 PWF_PLAN_ROOT pin/Windows 规范化/python/perl 兜底/containment
#  —— 本仓部署为 Linux glibc,slug 校验已阻路径穿越)
#
# 解析链:
#   1. plans/.active_plan_side/<sidkey>.active_plan 会话私有指针(TTL 24h;2026-09-10 active-plan-race)
#   2. plans/.active_plan 全局指针 → 指向的有效计划(slug 校验+task_plan.md 存在)
#   3. mtime 最新的 plans/<dir>/task_plan.md(跳过隐藏目录与非 slug 名)
#   4. legacy: <root>/task_plan.md(项目根单文件模式)
#   5. 全部未命中 → 空 stdout(caller 自行静默)
#
# 2026-09-10 active-plan-race: 新增第 2 可选参 SID(会话隔离)。原全局单文件 plans/.active_plan
#   被多个并行会话互相覆写(后写者赢 → hook 注入错计划/check-dispatch 误拦,09-09 实锤 7 次拦截)。
#   现拆两层:会话层 .active_plan_side/<sidkey>.active_plan(本会话私有,side 优先于全局陈旧指针)+
#   全局层 legacy 文件(cron/纯脚本单会话场景保留)。sidkey = sid 剥离非字母数字后取前 40(与 hook
#   各状态文件命名一致);第 2 参缺省 → env CLAUDE_CODE_SESSION_ID → default。side 文件 mtime >24h
#   视为会话已结束,跳过。无 side 且无 legacy 时行为=旧版(零破坏回归)。
#
# 用法: PLAN_FILE="$(bash resolve-plan-dir.sh [project-root] [sid])"   # 默认 $PWD
# 恒 exit 0,不干扰 hook 调用方。

set -u

ROOT="${1:-$PWD}"
SID="${2:-${CLAUDE_CODE_SESSION_ID:-}}"
PLAN_ROOT="${ROOT}/plans"
SIDE_DIR="${PLAN_ROOT}/.active_plan_side"
SIDE_TTL=86400   # 会话指针 24h 过期(会话重启/机器重启后旧 sid 文件不应再生效)

# sidkey 规范化: 剥非字母数字 + 前 40 位(与 /tmp/task-planner-hook-<sid>.state 命名惯例一致)
norm_sid() {
    local s="$(printf '%s' "$1" | tr -cd 'a-zA-Z0-9' | head -c 40)"
    [ -n "$s" ] && printf '%s' "$s" || printf 'default'
}
SID="$(norm_sid "$SID")"

# slug 安全校验:拒空白/路径分隔符/前导点(防指针内容腐烂或路径穿越,上游同款)
slug_is_valid() {
    case "$1" in
        '') return 1 ;;
        *[!A-Za-z0-9._-]*) return 1 ;;
        [A-Za-z0-9_]*) return 0 ;;
    esac
    return 1
}

# 1. 会话私有指针(side 优先于全局:本会话归属强于他人覆写的陈旧全局指针)
SIDE_FILE="${SIDE_DIR}/${SID}.active_plan"
if [ -f "$SIDE_FILE" ]; then
    now="$(date +%s)"
    mt="$(stat -c %Y "$SIDE_FILE" 2>/dev/null || echo "$now")"
    if [ $(( now - mt )) -le "$SIDE_TTL" ]; then
        pid="$(tr -d ' \r\n\t' < "$SIDE_FILE" 2>/dev/null || true)"
        if slug_is_valid "$pid" && [ -f "${PLAN_ROOT}/${pid}/task_plan.md" ]; then
            printf '%s\n' "${PLAN_ROOT}/${pid}/task_plan.md"
            exit 0
        fi
    fi
fi

# 2. 全局指针(legacy 文件形态;目录形态=迁移残留,忽略走 mtime)
ACTIVE_FILE="${PLAN_ROOT}/.active_plan"
if [ -f "$ACTIVE_FILE" ] && [ ! -d "$ACTIVE_FILE" ]; then
    pid="$(tr -d ' \r\n\t' < "$ACTIVE_FILE" 2>/dev/null || true)"
    if slug_is_valid "$pid" && [ -f "${PLAN_ROOT}/${pid}/task_plan.md" ]; then
        printf '%s\n' "${PLAN_ROOT}/${pid}/task_plan.md"
        exit 0
    fi
fi

# 3. mtime 最新(跳过隐藏目录/非法 slug/无 task_plan.md 的目录)
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

# 4. legacy 根目录单文件
if [ -f "${ROOT}/task_plan.md" ]; then
    printf '%s\n' "${ROOT}/task_plan.md"
fi
exit 0
