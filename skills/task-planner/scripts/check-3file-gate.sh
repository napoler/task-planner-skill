#!/usr/bin/env bash
# check-3file-gate.sh — Rule 19.2 执行中 3-File 回填门控（Phase complete 翻转前必须调用）
#
# 用法: check-3file-gate.sh <plan-dir 或 task_plan.md 路径>
# 退出码: 0 = 门控通过（可翻转 complete）; 1 = 违规/缺失（禁止翻转,先回填）
#
# 判定逻辑:
#   1. findings.md / progress.md 缺失 → exit 1（计划未正确初始化）
#   2. task_plan.md 无 in_progress Phase → exit 0（无活动 Phase,门控无对象）
#   3. 锚点 = progress.md 当前 in_progress Phase 段的 Started 时间戳;
#      锚点缺失/不可解析 → 退化为 stale 阈值（config.json#findings_stale_minutes /
#      #progress_stale_minutes,默认 20/25 分钟）: mtime 距今必须小于阈值
#   4. findings.md 与 progress.md 的 mtime 必须晚于锚点,任一不满足 → exit 1
#
# 设计取向: mtime 是代理指标,可被无关写入污染 —— 宁可误报（代价=多一次回填动作）,
# 不可漏报（漏报=三文件罗盘失效回潮,即本门控要杜绝的现象）。依赖 GNU stat/date。

set -euo pipefail

PLAN_ARG="${1:-}"
if [ -z "$PLAN_ARG" ]; then
    echo "[3file-gate] usage: check-3file-gate.sh <plan-dir or task_plan.md>"
    exit 1
fi

if [ -d "$PLAN_ARG" ]; then
    PLAN_DIR="$PLAN_ARG"
elif [ -f "$PLAN_ARG" ] && [ "$(basename "$PLAN_ARG")" = "task_plan.md" ]; then
    PLAN_DIR="$(dirname "$(cd "$PLAN_ARG" && pwd)")"
else
    echo "[3file-gate] invalid plan path: $PLAN_ARG"
    exit 1
fi

PLAN_FILE="$PLAN_DIR/task_plan.md"
FINDINGS="$PLAN_DIR/findings.md"
PROGRESS="$PLAN_DIR/progress.md"

for f in "$PLAN_FILE" "$FINDINGS" "$PROGRESS"; do
    if [ ! -f "$f" ]; then
        echo "[3file-gate] FAIL (Rule 19.2) — missing $f"
        echo "[3file-gate] Fix: run init-session.sh to initialize the 5 planning files."
        exit 1
    fi
done

# 当前 in_progress Phase 编号（取第一个 in_progress 块的 "### Phase N:" 编号）
CURRENT_PHASE="$(awk '
    /^#+ Phase [0-9]+:/ { gsub(":", "", $3); ph=$3 }
    /\*\*Status:\*\* in_progress/ { if (ph != "") { print ph; exit } }
' "$PLAN_FILE")"

if [ -z "$CURRENT_PHASE" ]; then
    # 无活动 Phase: 不在执行中,门控无对象
    exit 0
fi

NOW="$(date +%s)"
SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$SKILL_ROOT/config.json"
F_STALE="$(jq -r '.properties.findings_stale_minutes.default // 20' "$CONFIG" 2>/dev/null || echo 20)"
P_STALE="$(jq -r '.properties.progress_stale_minutes.default // 25' "$CONFIG" 2>/dev/null || echo 25)"

# 锚点: progress.md 中 "## Phase N:" 段内首个 Started 行的完整时间戳
# (awk 按段定位,防止 grep 跨段/命中标题行日期——2026-09-05 调试发现的提取漂移)
STARTED_LINE="$(awk -v ph="${CURRENT_PHASE}" '
    $0 ~ "^#+ Phase " ph ":" { insec=1; next }
    insec && /^#+ Phase [0-9]+:/ { exit }
    insec && /- \*\*Started:\*\*/ { print; exit }
' "$PROGRESS")"
STARTED_RAW="$(printf '%s' "$STARTED_LINE" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}([ T][0-9]{2}:[0-9]{2})?' || true)"

ANCHORED=0
ANCHOR_EPOCH=0
if [ -n "$STARTED_RAW" ]; then
    ANCHOR_EPOCH="$(date -d "$STARTED_RAW" +%s 2>/dev/null || echo 0)"
    [ "$ANCHOR_EPOCH" -gt 0 ] && ANCHORED=1
fi

VIOLATIONS=()
check_file() {
    local file="$1" label="$2" stale_min="$3"
    local mtime
    mtime="$(stat -c %Y "$file")"
    local ok=0
    if [ "$ANCHORED" -eq 1 ]; then
        [ "$mtime" -gt "$ANCHOR_EPOCH" ] && ok=1
    else
        [ "$(( NOW - mtime ))" -lt "$(( stale_min * 60 ))" ] && ok=1
    fi
    if [ "$ok" -ne 1 ]; then
        if [ "$ANCHORED" -eq 1 ]; then
            VIOLATIONS+=("$label 自 Phase $CURRENT_PHASE 开始($STARTED_RAW)从未更新")
        else
            VIOLATIONS+=("$label 已 $(( (NOW - mtime) / 60 )) 分钟未更新(阈值 ${stale_min})")
        fi
    fi
}

check_file "$FINDINGS" "findings.md" "$F_STALE"
check_file "$PROGRESS" "progress.md" "$P_STALE"

if [ "${#VIOLATIONS[@]}" -gt 0 ]; then
    for v in "${VIOLATIONS[@]}"; do
        echo "[3file-gate] FAIL (Rule 19.2) — $v"
    done
    echo "[3file-gate] Fix: 把本 Phase 的调研结论回填 findings.md、动作/文件/测试回填 progress.md 对应 Phase 段后重跑本门控。"
    exit 1
fi

echo "[3file-gate] PASS — findings.md/progress.md 在 Phase $CURRENT_PHASE 期间均已回填$( [ "$ANCHORED" -eq 1 ] && echo "（锚点 $STARTED_RAW）" || echo "（stale 阈值模式）" )"
exit 0
