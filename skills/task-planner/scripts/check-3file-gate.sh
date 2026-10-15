#!/usr/bin/env bash
# check-3file-gate.sh — Rule 19.2 执行中 3-File 回填门控（Phase complete 翻转前必须调用）
#
# 用法: check-3file-gate.sh <plan-dir 或 task_plan.md 路径> [--require-kb]
# 退出码: 0 = 门控通过（可翻转 complete）; 1 = 违规/缺失（禁止翻转,先回填）
#
# 判定逻辑:
#   1. findings.md / progress.md 缺失 → exit 1（计划未正确初始化）
#   2. task_plan.md 无 in_progress Phase → exit 0（无活动 Phase,门控无对象）
#   3. 锚点 = progress.md 当前 in_progress Phase 段的 Started 时间戳;
#      锚点缺失/不可解析 → 退化为 stale 阈值（config.json#findings_stale_minutes /
#      #progress_stale_minutes,默认 20/25 分钟）: mtime 距今必须小于阈值
#   4. findings.md 与 progress.md 的 mtime 必须晚于锚点,任一不满足 → exit 1
#   5. [--require-kb] knowledge-brief.md 存在 且（mtime 晚于锚点 或 ledger-*.jsonl
#      含锚点后 event="kb_distill" 的行）; 否则 exit 1（Rule 62.5 知识增量门控）
#   6. [Rule 64.2] drift 痕迹门控: ledger 含锚点后 event="drift_check" 行 或
#      subagent-state/*-drift-checker.md mtime 晚于锚点 或 task_plan.md 含 drift_exempt:
#      声明且当前 Phase 命中豁免清单 或 plan_tier: mini 整体豁免; 否则按 env
#      TASK_PLANNER_DRIFT_ENFORCE 降档 (off=跳过/warn=stderr 提示不阻断/默认 exit 1)
#
# 设计取向: mtime 是代理指标,可被无关写入污染 —— 宁可误报（代价=多一次回填动作）,
# 不可漏报（漏报=三文件罗盘失效回潮,即本门控要杜绝的现象）。依赖 GNU stat/date。
#
# [2026-10-08 task-v145 S-2 Rule 62.5] 修改说明:（2026-10-15 task-v176 D9：Rule 60.5→62.5 编号随迁修正——60.x 在 task-v145 后重编号为 62.x，脚本注释漏级联）
#   What: 新增可选旗标 --require-kb（第 5 条判定）+ kb_distill_activity() 语义信号函数。
#   Why:  调研型 Phase 原只校验 findings/progress 增量,知识沉淀（knowledge-brief 蒸馏）
#         无门控 → 调研知识停检查点/会话记忆回潮（Rule 62.3/62.5 判例: 双落盘+知识增量门控）。本扩展把
#         「知识增量」纳入完成门控: 调研型 Phase 翻转 complete 前必须已有 kb 蒸馏动作。
#   兼容: 参数解析纯增量（--require-kb 剥离后再定位置参数,不传时 PLAN_ARG=$1 与改动前
#         逐字节一致; 既有 findings/progress 判定分支零改动）。

set -euo pipefail

# [2026-10-08 task-v145 S-2 Rule 62.5] 参数解析: 先剥离可选旗标 --require-kb,再取首个位置
# 参数为 PLAN_ARG。纯增量——不传旗标时 ARGS=("$@")、PLAN_ARG=$1,与改动前行为一致。
REQUIRE_KB=0
ARGS=()
for _a in "$@"; do
    if [ "$_a" = "--require-kb" ]; then
        REQUIRE_KB=1
    else
        ARGS+=("$_a")
    fi
done
PLAN_ARG="${ARGS[0]:-}"
if [ -z "$PLAN_ARG" ]; then
    echo "[3file-gate] usage: check-3file-gate.sh <plan-dir or task_plan.md> [--require-kb]"
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

# [H1-fix 2026-10-14] L0/trivial 档（Rule 38.7 + Change #7）三文件缩减豁免：
# init-session.sh 在 L0 档只创建 progress.md + verification.md（跳过 findings.md），
# 原 3-File Gate 要求 3 文件全存在 → L0 计划 Phase 永远无法翻转 complete（功能性 bug）。
# 修法：检测 task_plan.md 中 execution_lane: L0，L0 计划豁免 findings.md 存在性 + mtime 检查。
# 判定源：init-session.sh:643 在 L0 档写入 task_plan.md `execution_lane: L0` 行。
_l0_exempt=0
grep -qE '^[[:space:]]*execution_lane:[[:space:]]*L0' "$PLAN_FILE" 2>/dev/null && _l0_exempt=1

# 必查（全档位）：task_plan.md + progress.md
for f in "$PLAN_FILE" "$PROGRESS"; do
    if [ ! -f "$f" ]; then
        echo "[3file-gate] FAIL (Rule 19.2) — missing $f"
        echo "[3file-gate] Fix: run init-session.sh to initialize the planning files."
        exit 1
    fi
done
# findings.md 存在性：L0 档豁免（init-session.sh Change #7 三文件缩减不创建）
if [ "${_l0_exempt}" -ne 1 ] && [ ! -f "$FINDINGS" ]; then
    echo "[3file-gate] FAIL (Rule 19.2) — missing $FINDINGS"
    # [2026-09-13 task-v067] 5→6（init-session 现建 6 文件，含 knowledge-brief.md）
    echo "[3file-gate] Fix: run init-session.sh to initialize the 6 planning files."
    exit 1
fi

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
ANCHOR_UTC=""
if [ -n "$STARTED_RAW" ]; then
    ANCHOR_EPOCH="$(date -d "$STARTED_RAW" +%s 2>/dev/null || echo 0)"
    # 注意: 不能 date -u -d "<本地时间>" —— -u 会把输入当作 UTC 解析。
    # 正确做法: epoch(按本地解析) 中转,再格式化为 UTC ISO(与 ledger ts 同域比较)。
    ANCHOR_UTC="$(date -u -d "@${ANCHOR_EPOCH}" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || true)"
    [ "$ANCHOR_EPOCH" -gt 0 ] && ANCHORED=1
fi

# 主信号: ledger 语义证据(上游 planning-with-files 完成门 G5 原理——
# "mtime moves on any file touch and is thus unreliable",touch 伪造/无关写误报均不可判)。
# 计划目录内任意 ledger-*.jsonl 含 ts >= 锚点(UTC 字典序=时间序)的行 = 本 Phase 有真实工作流。
# 无 ledger 的存量计划自然退回 mtime fallback;伪造 ledger = Rule 26 无豁免违规,不靠脚本防。
ledger_activity() {
    [ -n "$ANCHOR_UTC" ] || return 1
    ls "${PLAN_DIR}"/ledger-*.jsonl >/dev/null 2>&1 || return 1
    awk -v a="${ANCHOR_UTC}" '
        { if (match($0, /"ts":"[^"]*"/)) {
            ts = substr($0, RSTART+6, RLENGTH-7)
            if (ts >= a) { found = 1; exit }
        } }
        END { exit !found }
    ' "${PLAN_DIR}"/ledger-*.jsonl
}

# [2026-10-08 task-v145 S-2 Rule 62.5] kb 蒸馏语义信号: 计划目录内任意 ledger-*.jsonl 含
# ts >= 锚点(UTC 字典序=时间序) 且 event="kb_distill" 的行 = 本 Phase 有知识沉淀动作。
# 与 ledger_activity 同范式（同锚点/同 awk 提取）,仅多一个 event 字段过滤;无锚点则退化
# 到 mtime 判定（与 check_file 一致,不在此处返回真）。
kb_distill_activity() {
    [ -n "$ANCHOR_UTC" ] || return 1
    ls "${PLAN_DIR}"/ledger-*.jsonl >/dev/null 2>&1 || return 1
    awk -v a="${ANCHOR_UTC}" '
        { if (match($0, /"ts":"[^"]*"/)) {
            ts = substr($0, RSTART+6, RLENGTH-7)
            if (ts >= a && $0 ~ /"event":"kb_distill"/) { found = 1; exit }
        } }
        END { exit !found }
    ' "${PLAN_DIR}"/ledger-*.jsonl
}

# [2026-10-08 task-v148 S-2 Rule 64.2] drift 痕迹语义信号: 计划目录内任意 ledger-*.jsonl 含
# ts >= 锚点(UTC 字典序=时间序) 且 event="drift_check" 的行 = 本 Phase 有偏移检查留痕。
# 与 kb_distill_activity 同范式（同锚点/同 awk 提取）,仅多一个 event 字段过滤;无锚点则退化
# 到 mtime 判定（与 check_file 一致,不在此处返回真）。
drift_check_activity() {
    [ -n "$ANCHOR_UTC" ] || return 1
    ls "${PLAN_DIR}"/ledger-*.jsonl >/dev/null 2>&1 || return 1
    awk -v a="${ANCHOR_UTC}" '
        { if (match($0, /"ts":"[^"]*"/)) {
            ts = substr($0, RSTART+6, RLENGTH-7)
            if (ts >= a && $0 ~ /"event":"drift_check"/) { found = 1; exit }
        } }
        END { exit !found }
    ' "${PLAN_DIR}"/ledger-*.jsonl
}

# [2026-10-08 task-v148 S-2 Rule 64.2] drift 检查点 mtime 兜底: subagent-state/*-drift-checker.md
# 的 mtime 晚于锚点 = 本 Phase 有偏移检查留痕（ledger 缺失时的兜底信号）。
# 无锚点时退化到 stale 阈值（与 check_file 同范式）。
drift_checkpoint_activity() {
    local latest_mtime=0
    local f m
    for f in "${PLAN_DIR}"/subagent-state/*-drift-checker.md; do
        [ -f "$f" ] || continue
        m="$(stat -c %Y "$f")"
        [ "$m" -gt "$latest_mtime" ] && latest_mtime="$m"
    done
    [ "$latest_mtime" -eq 0 ] && return 1
    if [ "$ANCHORED" -eq 1 ]; then
        [ "$latest_mtime" -gt "$ANCHOR_EPOCH" ] && return 0
    else
        [ "$(( NOW - latest_mtime ))" -lt "$(( F_STALE * 60 ))" ] && return 0
    fi
    return 1
}

# [2026-10-08 task-v148 S-2 Rule 64.2] drift_exempt 豁免检查: task_plan.md 含 drift_exempt: 声明
# 且当前 Phase 号命中豁免清单 = 本 Phase 豁免 drift 痕迹门控。
drift_exempt_check() {
    local exempt_line phases p
    exempt_line="$(grep -E '^drift_exempt:' "$PLAN_FILE" 2>/dev/null || true)"
    [ -z "$exempt_line" ] && return 1
    phases="$(printf '%s' "$exempt_line" | sed -e 's/^drift_exempt:[[:space:]]*//' -e 's/[,[:space:]]\+/ /g')"
    for p in $phases; do
        [ "$p" = "$CURRENT_PHASE" ] && return 0
    done
    return 1
}

VIOLATIONS=()
check_file() {
    local file="$1" label="$2" stale_min="$3"
    # 主信号: ledger 语义证据 → 本 Phase 有真实工作,放行(降低 mtime 误报)
    if ledger_activity; then
        return 0
    fi
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
            VIOLATIONS+=("$label 自 Phase $CURRENT_PHASE 开始($STARTED_RAW)从未更新(无 ledger 工作记录,mtime 亦无增量)")
        else
            VIOLATIONS+=("$label 已 $(( (NOW - mtime) / 60 )) 分钟未更新(阈值 ${stale_min})")
        fi
    fi
}

# findings.md mtime 检查：L0 档豁免（Change #7 不创建 findings.md，mtime 无从谈起）
if [ "${_l0_exempt}" -ne 1 ]; then
    check_file "$FINDINGS" "findings.md" "$F_STALE"
fi
check_file "$PROGRESS" "progress.md" "$P_STALE"

if [ "${#VIOLATIONS[@]}" -gt 0 ]; then
    for v in "${VIOLATIONS[@]}"; do
        echo "[3file-gate] FAIL (Rule 19.2) — $v"
    done
    echo "[3file-gate] Fix: 把本 Phase 的调研结论回填 findings.md、动作/文件/测试回填 progress.md 对应 Phase 段后重跑本门控。"
    exit 1
fi

# [2026-10-08 task-v145 S-2 Rule 62.5] --require-kb: 调研型 Phase 知识增量门控（第 5 条件）。
# 通过判据 = knowledge-brief.md 存在 且（ledger 含锚点后 kb_distill 行 或 mtime 晚于锚点）。
# 无 Started 锚点时退化到 stale 阈值（复用 findings_stale_minutes,与 check_file 同范式）。
# 不满足 → exit 1,输出 Rule 62.5 指引（蒸馏归档 kb 或登记本 Phase 无调研产出的豁免一行）。
if [ "$REQUIRE_KB" -eq 1 ]; then
    KB_FILE="$PLAN_DIR/knowledge-brief.md"
    KB_OK=0
    if [ -f "$KB_FILE" ]; then
        if kb_distill_activity; then
            KB_OK=1
        else
            kb_mtime="$(stat -c %Y "$KB_FILE")"
            if [ "$ANCHORED" -eq 1 ]; then
                [ "$kb_mtime" -gt "$ANCHOR_EPOCH" ] && KB_OK=1
            else
                [ "$(( NOW - kb_mtime ))" -lt "$(( F_STALE * 60 ))" ] && KB_OK=1
            fi
        fi
    fi
    if [ "$KB_OK" -ne 1 ]; then
        echo "[3file-gate] kb 增量缺失（Rule 62.5：调研型 Phase 需 knowledge-brief 蒸馏或豁免登记）"
        exit 1
    fi
fi

# [2026-10-08 task-v148 S-2 Rule 64.2] drift 痕迹门控（第 6 条件）。
# 通过判据 = ledger 含锚点后 drift_check 行 或 subagent-state/*-drift-checker.md mtime 晚于锚点
# 或 task_plan.md 含 drift_exempt: 声明且当前 Phase 命中豁免清单。
# 无 Started 锚点时退化到 stale 阈值（复用 findings_stale_minutes,与 check_file 同范式）。
# 不满足 → 按 env TASK_PLANNER_DRIFT_ENFORCE 降档: off=跳过 / warn=stderr 提示不阻断 / 默认 exit 1。
DRIFT_ENFORCE="${TASK_PLANNER_DRIFT_ENFORCE:-enforce}"
DRIFT_OK=0
if drift_check_activity; then
    DRIFT_OK=1
elif drift_checkpoint_activity; then
    DRIFT_OK=1
elif drift_exempt_check; then
    DRIFT_OK=1
    echo "[3file-gate] drift_exempt 豁免放行（Phase $CURRENT_PHASE 已登记豁免）"
elif grep -qm1 'plan_tier: mini' "$PLAN_FILE" 2>/dev/null; then
    DRIFT_OK=1
    echo "[3file-gate] plan_tier=mini 豁免放行（Rule 64.2b）"
fi
if [ "$DRIFT_OK" -ne 1 ]; then
    case "$DRIFT_ENFORCE" in
        off)
            echo "[3file-gate] TASK_PLANNER_DRIFT_ENFORCE=off — 跳过 Rule 64.2 drift 痕迹门控"
            ;;
        warn)
            echo "[drift-gate] Rule 64.2: 本 Phase 窗口内无 drift_check 痕迹——派发 drift-checker（Rule 61 载体）并按 64.1 留痕三件套，或在 task_plan.md 登记 drift_exempt" >&2
            ;;
        *)
            echo "[drift-gate] Rule 64.2: 本 Phase 窗口内无 drift_check 痕迹——派发 drift-checker（Rule 61 载体）并按 64.1 留痕三件套，或在 task_plan.md 登记 drift_exempt" >&2
            exit 1
            ;;
    esac
fi

if [ "${_l0_exempt}" -eq 1 ]; then
    echo "[3file-gate] PASS（L0 豁免）— progress.md 在 Phase $CURRENT_PHASE 期间已回填$( ledger_activity && echo "（ledger 语义信号）" || echo "（mtime 判定）" )"
else
    echo "[3file-gate] PASS — findings.md/progress.md 在 Phase $CURRENT_PHASE 期间均已回填$( ledger_activity && echo "（ledger 语义信号）" || echo "（mtime 判定$( [ "$ANCHORED" -eq 1 ] && echo ":锚点 $STARTED_RAW" || echo ":stale 阈值模式" )）" )"
fi
exit 0
