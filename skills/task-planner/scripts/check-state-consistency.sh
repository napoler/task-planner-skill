#!/usr/bin/env bash
# check-state-consistency.sh — 计划状态三源一致性检查（checkbox ↔ Status ↔ progress 交叉，误报面最小）
#
# 用途（P-04 提案）: 拦截「纸面证据链完整但现实未完成」的假 COMPLETE——caseB-textonly 型缺陷
#   （探测·完成声称：Phase 1 Status:complete 但 checkbox `- [ ]` 未勾、progress 段仍 in_progress）。
#   check-complete.sh:181-213 既有解析器只读 `- **Status:**` 行，无 checkbox↔Status、plan↔progress
#   交叉比对，本门补该盲区（纯计划内三源文本交叉，不依赖外部路径/词表——终审意见 3 判误报面最小者）。
#
# 三源（全部 <plan-dir> 内文本，无外部依赖）:
#   ① task_plan.md 每 Phase 段的 checkbox 态（`- [ ]`/`- [x]`/`- [X]` 逐行计）+ 紧随 `**Status:**` 行
#   ② task_plan.md 每 Phase 的 `**Status:**` 值
#   ③ progress.md 同名 Phase 段（`#+ Phase N`）的 `**Status:**` 值 + 段内「完成证据行」（`[goal:G..]`）
#
# 判定（任一命中 → [state-mismatch]）:
#   S-1a checkbox↔Status: Phase 存在未勾 `- [ ]`（un>0）而 Status=complete → 未勾却称完成
#   S-1b checkbox↔Status: Phase 全勾无未勾（ck>0∧un=0）而 Status=pending  → 已勾却仍挂起
#   S-2  plan↔progress:    plan Phase Status=complete 而 progress 同名段 Status=in_progress
#                          且该段其后无完成证据行（`[goal:G` 计数=0）→ 纸面 complete 现实 in_progress
#
# 输入: $1 = <plan-dir> 或 task_plan.md 路径（两者皆可，仿 check-3file-gate.sh 解析）
# 输出: [state-mismatch] 明细行 + 判定行 → stdout（调用方 shell-out 中继，仿 check-complete.sh :431 先例）
# 退出码: 0 = 三源一致（或 fail-open 无可判定面: 无 task_plan.md / 无 Phase 段 / progress.md 缺失只跳 S-2）
#         1 = 存在 ≥1 条 [state-mismatch]
# 依赖: bash + awk/sed 标准件（coreutils 同 sibling 脚本一致）
#
# Usage: bash check-state-consistency.sh <plan-dir or task_plan.md>
#
# [2026-10-16 P-04] 新建（计划状态三源一致性门；Rule 45.3 头注四要素 + 45.2 双层注释）

set -u

# 解析参数: <plan-dir> 或 task_plan.md（与 check-3file-gate.sh 同范式）
PLAN_ARG="${1:-}"
if [ -z "$PLAN_ARG" ]; then
    echo "[state-consistency] usage: check-state-consistency.sh <plan-dir or task_plan.md>"
    exit 1
fi
if [ -d "$PLAN_ARG" ]; then
    PLAN_DIR="$PLAN_ARG"
elif [ -f "$PLAN_ARG" ] && [ "$(basename "$PLAN_ARG")" = "task_plan.md" ]; then
    PLAN_DIR="$(cd "$(dirname "$PLAN_ARG")" && pwd)"
else
    echo "[state-consistency] invalid plan path: $PLAN_ARG"
    exit 1
fi
PLAN_FILE="$PLAN_DIR/task_plan.md"
PROGRESS_FILE="$PLAN_DIR/progress.md"

if [ ! -f "$PLAN_FILE" ]; then
    echo "[state-consistency] PASS (fail-open: 无 task_plan.md, 无可判定面)"
    exit 0
fi

# ── 解析 task_plan.md: 每 Phase 段输出 "P<TAB>name<TAB>un<TAB>ck<TAB>status" ──
# 段边界 = 下一 `###`(非 Phase)/`## `/`---`；checkbox 行 `- [ ]`/`- [x]`/`- [X]` 计数，
# `**Status:**` 取段内首个值（段内应恰一行；多行取最后，口径宽松不误伤）。
PLAN_ROWS="$(awk '
    function emit() { if (have) printf "P\t%s\t%d\t%d\t%s\n", pname, un, ck, st }
    /^###[[:space:]]+Phase[[:space:]]/ {
        emit(); have=1; un=0; ck=0; st=""
        s=$0; sub(/^###[[:space:]]+Phase[[:space:]]*/, "", s)
        if (match(s, /[0-9]+/)) pname=substr(s, RSTART, RLENGTH); else pname="?"
        next
    }
    /^###/              { emit(); have=0; next }
    /^##[[:space:]]/    { emit(); have=0; next }
    /^---[[:space:]]*$/ { emit(); have=0; next }
    # 步骤 checkbox 只计「工序步骤」行; 排除 V-N 验证项行（`- [ ] V-P.N:` / `- [x] V-P.N:`，
    # Rule 84 验收映射, 与工序完成态正交——V-N 未勾是验证未完成, 非本门判的「工序未勾」）。
    # 排除式先判后计: V-N 行不计 un/ck → 消除 T06 类误报(verification 占位 V-N 行被误当工序)。
    have && /^[-*][[:space:]]*\[[[:space:]]*\]/ && $0 !~ /\[[[:space:]]*\][[:space:]]*V-[0-9]/ { un++; next }
    have && /^[-*][[:space:]]*\[[xX]\]/ && $0 !~ /\[[xX]\][[:space:]]*V-[0-9]/           { ck++; next }
    have && index($0, "**Status:**") > 0 {
        s=$0; sub(/.*\*\*Status:\*\*[[:space:]]*/, "", s)
        split(s, a, /[[:space:]]/); if (a[1] != "") st=a[1]
        next
    }
    END { emit() }
' "$PLAN_FILE" 2>/dev/null)"

# 无任何 Phase 段 → 无可判定面 fail-open（同 check-complete.sh No phases 语义）
if [ -z "$PLAN_ROWS" ]; then
    echo "[state-consistency] PASS (fail-open: task_plan.md 无 `### Phase` 段)"
    exit 0
fi

# ── 解析 progress.md: 每 Phase 段输出 "Q<TAB>name<TAB>status<TAB>goalcount" ──
# progress.md 缺失 → PROGRESS_ROWS 空（S-2 整体 fail-open 跳过，不影响 S-1 纯计划内判定）。
if [ -f "$PROGRESS_FILE" ]; then
PROGRESS_ROWS="$(awk '
    function emit() { if (have) printf "Q\t%s\t%s\t%d\n", pname, st, gcount }
    /^#+[[:space:]]+Phase[[:space:]]/ {
        emit(); have=1; st=""; gcount=0
        s=$0; sub(/^#+[[:space:]]*Phase[[:space:]]*/, "", s)
        if (match(s, /[0-9]+/)) pname=substr(s, RSTART, RLENGTH); else pname="?"
        next
    }
    /^#/                 { emit(); have=0; next }   # 任意 #/##/###/#### 非 Phase 标题收段
    have && index($0, "**Status:**") > 0 && st=="" {
        s=$0; sub(/.*\*\*Status:\*\*[[:space:]]*/, "", s)
        split(s, a, /[[:space:]]/); if (a[1] != "") st=a[1]
        next
    }
    have && /\[goal:G/   { gcount++; next }
    END { emit() }
' "$PROGRESS_FILE" 2>/dev/null)"
fi
PROGRESS_ROWS="${PROGRESS_ROWS:-}"

# ── 判定: 逐 Phase 交叉三源 ──
MISMATCHES=0
while IFS=$'\t' read -r _tag pname pun pck pstat; do
    [ "$_tag" = "P" ] || continue
    # S-1a: 未勾（un>0）却 Status=complete
    if [ "$pstat" = "complete" ] && [ "$pun" -gt 0 ]; then
        echo "[state-mismatch] S-1a Phase ${pname}: 存在 ${pun} 个未勾「- [ ]」但 **Status:** complete（未勾却称完成, 需回填证据或改回 in_progress）"
        MISMATCHES=1
    fi
    # S-1b: 全勾（ck>0∧un=0）却 Status=pending
    if [ "$pstat" = "pending" ] && [ "$pck" -gt 0 ] && [ "$pun" -eq 0 ]; then
        echo "[state-mismatch] S-1b Phase ${pname}: 全 ${pck} 项已勾「- [x]」但 **Status:** pending（已勾却仍挂起, 需翻转 Status）"
        MISMATCHES=1
    fi
    # S-2: plan complete 但 progress 同名段 in_progress 且段内无 [goal:G 完成证据行
    if [ "$pstat" = "complete" ] && [ -n "$PROGRESS_ROWS" ]; then
        prow="$(printf '%s\n' "$PROGRESS_ROWS" | awk -F'\t' -v n="$pname" '$1=="Q" && $2==n {print; exit}')"
        p_pstat="$(printf '%s' "$prow" | cut -f3)"
        p_goal="$(printf '%s' "$prow" | cut -f4)"
        if [ "$p_pstat" = "in_progress" ] && [ "${p_goal:-0}" -eq 0 ]; then
            echo "[state-mismatch] S-2 Phase ${pname}: plan **Status:** complete 但 progress 同名段 in_progress 且无 [goal:G 完成证据行（纸面 complete 现实 in_progress）"
            MISMATCHES=1
        fi
    fi
done <<< "$PLAN_ROWS"

if [ "$MISMATCHES" -eq 1 ]; then
    echo "[state-consistency] ✗ FAIL — 计划状态三源不一致（上方 [state-mismatch] 逐条: 回填证据 / 翻转 Status / 补 progress 完成证据后重跑）"
    exit 1
fi
echo "[state-consistency] PASS — 三源一致（checkbox↔Status↔progress）"
exit 0
