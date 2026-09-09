#!/usr/bin/env bash
# check-plan-dispatch.sh — task-v058 计划期子代理规划门控（Rule 22.6/25.1 机制化）
#
# 用途：校验 task_plan.md 中「派发型 Phase 必附带执行体的 S-unit 表」
#   - 派发型 = Phase 首个 **Executor:** 行不含「主进程」（无 Executor 行按派发型从严）
#   - 派发型 Phase 缺 S-unit 表 / 表无执行体列 / 数据行 0 / 某 S 行执行体列空 → 违规
#   - 主进程 Phase 不要求表
#   - legacy 兼容：全文无「执行体」字样 = 旧模板计划 → 跳过门控 exit 0
#   - 供 attest-plan.sh（锁定）与 check-complete.sh（终验）调用
#
# Usage: bash check-plan-dispatch.sh <task_plan.md>
#
# 退出码：
#   0 = 全合规 / fail-open（缺参、文件不可读、legacy、无派发型 Phase）
#   1 = 存在违规（stdout 每条一行 `[plan-dispatch] ✗ Phase N: <原因>`）
#
# 环境：无特殊 env 依赖；纯 bash while-read 状态机（禁用 awk 区间模式——gawk 区间 bug 已知）
# [2026-09-09 task-v058 P3-S1] 新建（D2 规格）；Phase 头只认 `### Phase` markdown 标题，
# 避免误配「## Current Phase」节内的裸 `Phase N` 行

set -u

PLAN_FILE="${1:-}"
if [ -z "$PLAN_FILE" ] || [ ! -f "$PLAN_FILE" ] || [ ! -r "$PLAN_FILE" ]; then
    echo "[plan-dispatch] fail-open: no readable task_plan.md"
    exit 0
fi

# ── legacy 判定（全文级）────────────────────────────────────────────────────
if ! grep -q "执行体" "$PLAN_FILE" 2>/dev/null; then
    echo "[plan-dispatch] legacy plan(无执行体列),跳过门控"
    exit 0
fi

violation_list=""
dispatch_count=0   # 见过的派发型 Phase 数（全合规时用于 ✓ 汇总）
seq=0
in_phase=0
phase_no=0
has_table=0
has_rows=0
have_executor=0
executor_main=0

trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

add_violation() {
    violation_list="${violation_list}[plan-dispatch] ✗ Phase $1: $2"$'\n'
}

# 结算当前 Phase 块（遇下一 ### Phase / ## 标题 / EOF 时调用）
settle_phase() {
    [ "$in_phase" -eq 1 ] || return 0
    in_phase=0
    if [ "$have_executor" -eq 1 ] && [ "$executor_main" -eq 1 ]; then
        return 0    # 主进程 Phase：不要求 S-unit 表
    fi
    dispatch_count=$(( dispatch_count + 1 ))
    if [ "$has_table" -eq 0 ] || [ "$has_rows" -eq 0 ]; then
        add_violation "$phase_no" "缺 S-unit 表或数据行(Rule 22.6)"
    fi
}

# 重置新 Phase 块标志
reset_phase() {
    has_table=0
    has_rows=0
    have_executor=0
    executor_main=0
}

while IFS= read -r line; do
    # ① 新 Phase 头：`### Phase N:`（N 缺省时用扫描序号）
    if [[ "$line" =~ ^###[[:space:]]*Phase[[:space:]]*(.*)$ ]]; then
        settle_phase
        seq=$(( seq + 1 ))
        if [[ "${BASH_REMATCH[1]}" =~ ([0-9]+) ]]; then
            phase_no="${BASH_REMATCH[1]}"
        else
            phase_no="$seq"
        fi
        reset_phase
        in_phase=1
        continue
    fi
    # ② `## ` 二级标题 → Phase 块结束
    if [[ "$line" =~ ^##[[:space:]] ]]; then
        settle_phase
        continue
    fi
    [ "$in_phase" -eq 1 ] || continue
    # ③ Executor 行（以首个为准；含「主进程」= 免检）
    if [[ "$line" == *'**Executor:**'* ]] && [ "$have_executor" -eq 0 ]; then
        have_executor=1
        [[ "$line" == *"主进程"* ]] && executor_main=1
    fi
    # ④ S-unit 表头：`| ID |` 开头且含「执行体」列才算
    case "$line" in
        "| ID |"*)
            [[ "$line" == *"执行体"* ]] && has_table=1
            ;;
    esac
    # ⑤ 数据行：`| S<n> |` 开头 → 计数 + 执行体列（awk -F'|' 第 4 字段）非空检查
    if [[ "$line" =~ ^\|[[:space:]]*S([0-9]+)[[:space:]]*\| ]]; then
        s_id="${BASH_REMATCH[1]}"
        has_rows=1
        col4="$(printf '%s' "$line" | awk -F'|' '{print $4}')"
        col4="$(trim "$col4")"
        if [ -z "$col4" ] || [ "$col4" = "-" ]; then
            add_violation "$phase_no" "行 S${s_id} 执行体为空"
        fi
    fi
done < "$PLAN_FILE"
settle_phase    # EOF 结算最后一个 Phase

# ── 输出 ─────────────────────────────────────────────────────────────────────
if [ -n "$violation_list" ]; then
    printf '%s' "$violation_list"
    exit 1
fi
if [ "$dispatch_count" -eq 0 ]; then
    echo "[plan-dispatch] fail-open: 无派发型 Phase"
    exit 0
fi
echo "[plan-dispatch] ✓ ${dispatch_count} 个派发型 Phase 均有带执行体的 S-unit 表"
exit 0
