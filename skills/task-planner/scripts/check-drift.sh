#!/usr/bin/env bash
# check-drift.sh — 防漂移检测
#
# 用途：在 phase 完成后（或每 N 次工具调用后）对照原始计划校验执行是否偏航。
#
# 用法：
#   check-drift.sh [task_plan.md] [progress.md] [findings.md] [--json]
#
# 输出：
#   - 正常模式：人类可读报告，exit 0 = 未漂移/exit 1 = 检测到漂移需干预
#   - --json 模式：JSON 结构化输出（含 drift_score, findings[]）
#
# 判定规则：
#   1. 目标偏移：当前执行产出 ≠ task_plan.md Goal 描述的核心交付物
#   2. VC 缺失：Verification Contract 中某项未执行验证
#   3. Phase 越级：跳过 in_progress 直接标记后续 phase complete
#   4. Scope 扩张：修改了计划范围外的文件
#   5. 循环重试：同一错误在同一 phase 重复出现 ≥3 次

set -euo pipefail

PLAN_FILE="${2:-task_plan.md}"
PROGRESS_FILE="${3:-progress.md}"
FINDINGS_FILE="${4:-findings.md}"
JSON_OUTPUT=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --json) JSON_OUTPUT=true ;;
        *) ;; # ignore positional args other than plan/progress/findings
    esac
    shift
done

# Resolve paths relative to CWD if not absolute
resolve_path() {
    local p="$1"
    if [[ "$p" = /* ]]; then echo "$p"; else echo "$(pwd)/$p"; fi
}

PLAN_FILE="$(resolve_path "$PLAN_FILE")"
PROGRESS_FILE="$(resolve_path "$PROGRESS_FILE")"
FINDINGS_FILE="$(resolve_path "$FINDINGS_FILE")"

DRIFT_SCORE=0
FINDINGS=""
WARNINGS=""

emit() {
    local severity="$1"  # CRITICAL/WARNING/INFO
    local code="$2"
    local msg="$3"
    FINDINGS="${FINDINGS}${FINDINGS:+
}{'severity':'$severity','code':'$code','message':'$msg'}"
    if $JSON_OUTPUT; then
        : # collected in FINDINGS, emitted at end
    else
        case "$severity" in
            CRITICAL) echo "[DRIFT-CRIT] $code: $msg" ;;
            WARNING)  echo "[DRIFT-WARN] $code: $msg" ;;
            INFO)     echo "[DRIFT-INFO] $code: $msg" ;;
        esac
    fi
}

# ─── Check 1: VC 验证缺失 ─────────────────────────────────────────────────────
# 扫描 task_plan.md 中所有 VC-N 行，检查 progress.md 中是否有对应验证记录
check_vc_coverage() {
    if [[ ! -f "$PLAN_FILE" ]]; then
        emit "WARNING" "VC-MISS" "task_plan.md 不存在，无法验证 VC 覆盖"
        return
    fi

    # Extract VC-N items from task_plan.md
    local vc_items
    vc_items=$(grep -oP 'VC-\d+' "$PLAN_FILE" 2>/dev/null || true)
    if [[ -z "$vc_items" ]]; then
        emit "INFO" "VC-NONE" "task_plan.md 无 VC 条目，跳过 VC 检查"
        return
    fi

    local missing=()
    while IFS= read -r vc_id; do
        [[ -z "$vc_id" ]] && continue
        if [[ -f "$PROGRESS_FILE" ]]; then
            if ! grep -qi "$vc_id" "$PROGRESS_FILE" 2>/dev/null; then
                missing+=("$vc_id")
            fi
        else
            missing+=("$vc_id")
        fi
    done <<< "$vc_items"

    if [[ ${#missing[@]} -gt 0 ]]; then
        emit "CRITICAL" "VC-UNVERIFIED" "VC 条目未验证: ${missing[*]}"
        DRIFT_SCORE=$((DRIFT_SCORE + ${#missing[@]} * 2))
    else
        emit "INFO" "VC-COVERED" "所有 VC 条目已在 progress.md 中验证"
    fi
}

# ─── Check 2: Phase 越级检测 ──────────────────────────────────────────────────
# 检测是否存在：前序 phase pending，后续 phase 却 marked complete
check_phase_order() {
    if [[ ! -f "$PLAN_FILE" ]]; then
        return
    fi

    local phases
    phases=$(awk '/^### Phase [0-9]+:/ {print NR": "$0}' "$PLAN_FILE" 2>/dev/null || true)
    if [[ -z "$phases" ]]; then
        return
    fi

    local prev_status="pending"
    local violated=false
    local violation_detail=""

    # Extract phase status sequence
    while IFS= read -r line; do
        local status=""
        if echo "$line" | grep -qF "**Status:** complete"; then
            status="complete"
        elif echo "$line" | grep -qF "**Status:** in_progress"; then
            status="in_progress"
        elif echo "$line" | grep -qF "**Status:** pending"; then
            status="pending"
        fi

        # Detect skip: any complete phase after a pending phase
        if [[ "$status" == "complete" && "$prev_status" == "pending" ]]; then
            violated=true
            violation_detail="发现 phase 越级：在 $prev_status phase 之后直接完成 phase"
            break
        fi
        if [[ -n "$status" ]]; then
            prev_status="$status"
        fi
    done < <(sed -n '/^## Phases/,/^## Key Questions/p' "$PLAN_FILE" 2>/dev/null)

    if $violated; then
        emit "CRITICAL" "PHASE-SKIP" "$violation_detail"
        DRIFT_SCORE=$((DRIFT_SCORE + 3))
    else
        emit "INFO" "PHASE-ORDER" "Phase 顺序正常"
    fi
}

# ─── Check 3: 目标偏移检测 ────────────────────────────────────────────────────
# 比较 progress.md 最后记录与 task_plan.md Goal 的核心关键词
check_goal_alignment() {
    if [[ ! -f "$PLAN_FILE" || ! -f "$PROGRESS_FILE" ]]; then
        return
    fi

    local goal
    # Extract non-comment, non-empty lines between ## Goal and next ## heading
    goal=$(awk '/^## Goal$/{found=1; next} /^## /{found=0} found && !/^<!--/ && !/^-->/ && NF>0{print}' "$PLAN_FILE" 2>/dev/null | head -3 | tr '\n' ' ' | sed 's/[[:space:]]*$//')
    if [[ -z "$goal" || ${#goal} -lt 10 ]]; then
        emit "INFO" "GOAL-EMPTY" "task_plan.md Goal 为空或过短，跳过目标对齐检查"
        return
    fi

    # Simple heuristic: check if progress.md references key concepts from goal
    local goal_words
    goal_words=$(echo "$goal" | grep -oP '\w+' | sort -u | head -20)
    local matched=0
    local total=0

    while IFS= read -r word; do
        [[ ${#word} -lt 3 ]] && continue
        total=$((total + 1))
        if grep -qi "$word" "$PROGRESS_FILE" 2>/dev/null; then
            matched=$((matched + 1))
        fi
    done <<< "$goal_words"

    if [[ $total -gt 0 ]]; then
        local ratio=$((matched * 100 / total))
        if [[ $ratio -lt 30 ]]; then
            emit "WARNING" "GOAL-DRIFT" "目标对齐度低: $matched/$total 关键概念未出现在 progress.md ($ratio%)"
            DRIFT_SCORE=$((DRIFT_SCORE + 2))
        else
            emit "INFO" "GOAL-OK" "目标对齐度: $matched/$total 关键概念匹配 ($ratio%)"
        fi
    fi
}

# ─── Check 4: Scope 扩张检测 ──────────────────────────────────────────────────
# 检查 progress.md 中记录的文件修改是否超出了 task_plan.md 的允许范围
check_scope_breach() {
    if [[ ! -f "$PLAN_FILE" || ! -f "$PROGRESS_FILE" ]]; then
        return
    fi

    # Extract allowed files from task_plan.md Scope Guard table
    local allowed_files
    allowed_files=$(awk '/^## ⚠️ 执行范围限制/,/^## /' "$PLAN_FILE" 2>/dev/null \
        | grep '|' \
        | grep -vE '(类别|允许|禁止|---)' \
        | sed 's/.*|//;s/|.*//' \
        | tr ',' '\n' \
        | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
        | grep -v '^$' || true)

    if [[ -z "$allowed_files" ]]; then
        emit "INFO" "SCOPE-NONE" "task_plan.md 无范围限制表，跳过 scope 检查"
        return
    fi

    # Check if progress.md mentions any file not in allowed list
    # This is a soft check - only flag if we can clearly identify out-of-scope references
    local progress_files
    progress_files=$(grep -oP '[\w./_-]+\.(ts|js|py|md|json|yaml|yml|toml|html|css)' "$PROGRESS_FILE" 2>/dev/null \
        | sort -u || true)

    if [[ -z "$progress_files" ]]; then
        emit "INFO" "SCOPE-OK" "progress.md 无文件引用，无法检测 scope 扩张"
        return
    fi

    local breach=false
    local breached_files=""
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        local in_scope=false
        while IFS= read -r allowed; do
            [[ -z "$allowed" ]] && continue
            if echo "$file" | grep -qF "$allowed" || echo "$allowed" | grep -qF "$(basename "$file")"; then
                in_scope=true
                break
            fi
        done <<< "$allowed_files"
        if ! $in_scope; then
            breach=true
            breached_files="${breached_files}${breached_files:+, }$file"
        fi
    done <<< "$progress_files"

    if $breach; then
        emit "WARNING" "SCOPE-BREACH" "疑似 scope 扩张: $breached_files"
        DRIFT_SCORE=$((DRIFT_SCORE + 1))
    else
        emit "INFO" "SCOPE-OK" "未发现 scope 扩张"
    fi
}

# ─── Check 5: 错误循环检测 ────────────────────────────────────────────────────
# 检查 Errors Encountered 表中同一错误是否重复出现 ≥3 次
check_error_loop() {
    if [[ ! -f "$PLAN_FILE" ]]; then
        return
    fi

    local error_count
    error_count=$(awk '/^## Errors Encountered$/,/^## /' "$PLAN_FILE" 2>/dev/null \
        | grep -cP '^\|' || true)

    if [[ $error_count -lt 3 ]]; then
        emit "INFO" "ERRORS-OK" "错误记录 $error_count 条，未达循环阈值"
        return
    fi

    # Count errors per type
    local error_types
    error_types=$(awk '/^## Errors Encountered$/,/^## /' "$PLAN_FILE" 2>/dev/null \
        | awk -F'|' 'NF>=3 {gsub(/^[[:space:]]+|[[:space:]]+$/,"",$2); print $2}' \
        | sort | uniq -c | sort -rn || true)

    local loop_detected=false
    while IFS= read -r line; do
        local count err_name
        count=$(echo "$line" | awk '{print $1}')
        err_name=$(echo "$line" | awk '{print $2}')
        if [[ ${count:-0} -ge 3 ]]; then
            loop_detected=true
            emit "CRITICAL" "ERROR-LOOP" "错误 '$err_name' 重复 ${count} 次，触发三击协议"
            DRIFT_SCORE=$((DRIFT_SCORE + 3))
        fi
    done <<< "$error_types"

    if ! $loop_detected; then
        emit "INFO" "ERRORS-OK" "未发现循环错误"
    fi
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
    check_vc_coverage
    check_phase_order
    check_goal_alignment
    check_scope_breach
    check_error_loop

    echo ""
    if $JSON_OUTPUT; then
        echo "{\"drift_score\":$DRIFT_SCORE,\"findings\":[$FINDINGS]}"
        if [[ $DRIFT_SCORE -gt 0 ]]; then
            exit 1
        fi
    else
        if [[ $DRIFT_SCORE -gt 0 ]]; then
            echo "[DRIFT] 检测到漂移，drift_score=$DRIFT_SCORE，需人工复核"
            exit 1
        else
            echo "[DRIFT] 无漂移，执行与计划对齐"
            exit 0
        fi
    fi
}

main
