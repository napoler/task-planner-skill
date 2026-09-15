#!/usr/bin/env bash
# check-plan-dispatch.sh — task-v058 计划期子代理规划门控（Rule 22.6/25.1 机制化）
#
# 用途：校验 task_plan.md 中「派发型 Phase 必附带执行体的 S-unit 表」
#   - 派发型 = Phase 首个 **Executor:** 行不含「主进程」（无 Executor 行按派发型从严）
#   - 派发型 Phase 缺 S-unit 表 / 表无执行体列 / 数据行 0 / 某 S 行执行体列空 → 违规
#   - 主进程 Phase 不要求表
#   - legacy 兼容：全文无 `- **Executor:**` 行 = 旧模板计划 → 跳过门控 exit 0
#     [2026-09-13 task-v065 S-1 F-2] 判定键由字面量「执行体」修正为 `^- \*\*Executor:\*\*`：
#     旧键只出现在 S-unit 表头 → 现代计划（有 `- **Executor:**` 行、无 S-unit 表）被判 legacy
#     放行，恰好漏掉本门控唯一该拦的违规形态（已实测 rc=0）。canonical 计划格式见
#     templates/task_plan.md:144 与仓内全部 30 个真实计划（0 个裸 `**Executor:**` 行）。
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
# [2026-09-16 task-v075 P2-S1] S-unit 数值门控（Rule 21.1b 机制化，仅派发型 Phase 生效，
# 判定口径对应计划 KQ1，KQ1 裁定随本节注释定死）：
#   列序参照（与任务书/KQ1 口径一致）：`| S<n> | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 状态 |`
#   awk -F'|' 下 $5=输入列、$7=预估时长列。
#   ① 时长：$7 须匹配 ^[0-9]+min$ 且数值 ≤ step_max_minutes（jq 读 config.json
#      .properties.subagent.step_max_minutes.default，键参照 attest-plan.sh:80-97
#      tcfg 范式；jq 缺失或键缺失 → 回退默认 15 并打印一行 SKIPPED 说明）
#   ② 输入：$5 中路径样 token 计数 ≤ step_max_files（同上回退默认 2）。
#      KQ1 裁定口径（定死）：token = 以 .sh/.md/.json/.ts/.js/.py/.cjs 结尾的
#      非空白 token，grep -oE '[^ ]+\.(sh|md|json|ts|js|py|cjs)'（后缀锚定 token
#      尾部，避免任务书原式 `(^|[[:space:]])` 前缀形态在 grep -o 下误带前导
#      空白/分号被当独立 token 的计数漂移）；计数 > step_max_files → 违规。
#   ③ 时长列为空或不可解析（不匹配 NNmin）→ 逐行打印 `[plan-dispatch] SKIPPED
#      Phase N S<n> 时长不可解析`（v074 P10 fail-open 显式化先例，attest-plan.sh:92-97），
#      不阻断；时长校验本身跳过，但输入列校验仍执行。
#   ④ 违规 ≥1 → 沿用既有 add_violation 风格逐行打印后 exit 1；0 违规 → 既有行为
#      与退出码零变化。

set -u

PLAN_FILE="${1:-}"
if [ -z "$PLAN_FILE" ] || [ ! -f "$PLAN_FILE" ] || [ ! -r "$PLAN_FILE" ]; then
    echo "[plan-dispatch] fail-open: no readable task_plan.md"
    exit 0
fi

# ── legacy 判定（全文级）────────────────────────────────────────────────────
# [2026-09-13 task-v065 S-1 F-2] 判定键修正(原为字面量「执行体」，见文件头注释)：
#   有 `- **Executor:**` 行 = 现代计划 → 继续机械门控(缺 S-unit 表即违规)；
#   无该行 = 旧模板计划 → legacy 放行。
if ! grep -qE '^- \*\*Executor:\*\*' "$PLAN_FILE" 2>/dev/null; then
    echo "[plan-dispatch] legacy plan(无 \`- \*\*Executor:\*\*\` 行),跳过门控"
    exit 0
fi

# ── S-unit 数值门控阈值（task-v075 P2-S1，仅派发型 Phase 数据行生效）────────
# [2026-09-16] jq 读 config.json（键参照 attest-plan.sh:80-97 tcfg 范式）；
# jq 缺失/键缺失 → 回退默认值（step_max_minutes=15 / step_max_files=2）
# 并打印一行 SKIPPED 说明（fail-open 显式化，同 attest-plan.sh:92-97 先例）
STEP_MAX_MIN=15
STEP_MAX_FILES=2
cfg="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../config.json"
if command -v jq >/dev/null 2>&1 && [ -f "$cfg" ]; then
    STEP_MAX_MIN="$(jq -r '.properties.subagent.step_max_minutes.default // "15"' "$cfg" 2>/dev/null)" || STEP_MAX_MIN=""
    STEP_MAX_FILES="$(jq -r '.properties.subagent.step_max_files.default // "2"' "$cfg" 2>/dev/null)" || STEP_MAX_FILES=""
fi
if ! [[ "$STEP_MAX_MIN" =~ ^[0-9]+$ ]]; then
    STEP_MAX_MIN=15
    echo "[plan-dispatch] SKIPPED step_max_minutes 未解析(jq 缺失或键缺),回退默认 15"
fi
if ! [[ "$STEP_MAX_FILES" =~ ^[0-9]+$ ]]; then
    STEP_MAX_FILES=2
    echo "[plan-dispatch] SKIPPED step_max_files 未解析(jq 缺失或键缺),回退默认 2"
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
        # ⑤-b S-unit 数值门控（task-v075 P2-S1，KQ1 口径见文件头注释）：
        # 逐行校验 预估时长列($7) 与 输入列($5)
        col5="$(printf '%s' "$line" | awk -F'|' '{print $5}')"
        col7="$(printf '%s' "$line" | awk -F'|' '{print $7}')"
        col5="$(trim "$col5")"
        col7="$(trim "$col7")"
        # 时长校验：须匹配 ^[0-9]+min$ 且数值 ≤ step_max_minutes；
        # 空/不可解析 → SKIPPED 显式化（不阻断，v074 P10 先例）
        if [[ "$col7" =~ ^([0-9]+)min$ ]]; then
            dur="${BASH_REMATCH[1]}"
            if [ "$dur" -gt "$STEP_MAX_MIN" ]; then
                add_violation "$phase_no" "行 S${s_id} 预估时长 ${dur}min > step_max_minutes(${STEP_MAX_MIN})"
            fi
        else
            echo "[plan-dispatch] SKIPPED Phase ${phase_no} S${s_id} 时长不可解析"
        fi
        # 输入校验：路径样 token 计数 > step_max_files → 违规（KQ1 定死口径）。
        # [2026-09-16] 计数用 `grep -oE | wc -l` 而非 `grep -c`：`grep -c` 与
        # -o 同用时忽略 -o（按"命中行数"计 = 恒 1，实测），须逐 token 计数
        pcount="$(printf '%s\n' "$col5" | grep -oE '[^ ]+\.(sh|md|json|ts|js|py|cjs)' | wc -l)"
        if [ "$pcount" -gt "$STEP_MAX_FILES" ]; then
            add_violation "$phase_no" "行 S${s_id} 输入列 ${pcount} 个文件路径 > step_max_files(${STEP_MAX_FILES})"
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
