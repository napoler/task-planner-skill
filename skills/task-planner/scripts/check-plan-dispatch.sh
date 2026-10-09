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
#   ⑤ 步骤枚举（task-v081 第三维,advisory）: $3 目标列 distinct 步骤枚举序号
#      （StepN/步骤N/第N步/①-⑮,按序号值去重,口径=count_step_markers,见函数注释）
#      > step_max_steps（jq 读 .properties.subagent.properties.step_max_steps.default,
#      缺失 → 回退默认 4 并打印一行 SKIPPED）→ 打 SKIPPED 提示拆分（不阻断）。

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

# ── [2026-09-20 task-v086 P2-S3 Rule 38.1/38.4④] mini 档: 判定前置 + S-unit 豁免 + MISMATCH ──
# 判定公共前置: grep 计划文件(init 复制产物 task_plan.md)「plan_tier: mini」; standard 模板
# 标记 plan_tier: standard 天然不命中 → 非 mini 路径零改动。
PLAN_TIER_MINI=0
MINI_EXEMPT=0
PTIER="warn"
if grep -qm1 'plan_tier: mini' "$PLAN_FILE" 2>/dev/null; then
    # 档位解析: env TASK_PLANNER_PLAN_TIER_ENFORCE > config.json plan_tier_enforce.default > warn
    ptcfg="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../config.json"
    m="${TASK_PLANNER_PLAN_TIER_ENFORCE:-}"
    case "$m" in enforce|warn|off) : ;; *)
        # [2026-09-26 task-v091 C-1b：双层路径修复，顶层覆盖优先] 原单层路径致覆盖静默失效
        m="$(jq -r '.plan_tier_enforce // .properties.plan_tier_enforce.default // "warn"' "$ptcfg" 2>/dev/null)" || m=""
        case "$m" in enforce|warn|off) : ;; *) m="warn" ;; esac ;;
    esac
    PTIER="$m"
    PLAN_TIER_MINI=1
    if [ "$PTIER" = "off" ]; then
        # off = mini 声明也走全量门控: 豁免关闭 + MISMATCH 不提示 (Rule 38.5)
        PLAN_TIER_MINI=0
    fi
fi
if [ "$PLAN_TIER_MINI" = 1 ]; then
    # S-unit 豁免(38.4④): 全 Phase Executor 均主进程(或无子代理 Executor 声明)→ 视为非派发型;
    # 仍声明子代理 Executor 的 Phase 不豁免(has_subagent=1 → MINI_EXEMPT 保持 0)
    has_subagent="$(grep -E '^- \*\*Executor:\*\*' "$PLAN_FILE" 2>/dev/null | grep -vc '主进程' || true)"
    [ "${has_subagent:-0}" -eq 0 ] && MINI_EXEMPT=1
    # MISMATCH(38.1): 声明 mini 但机器条件不满足(①Goal 行缺 ≤15min 字样 ②执行范围表数据行>2)
    mismatch_items=""
    goal_sec="$(awk '/^##[[:space:]]*Goal/{f=1;next} /^##[[:space:]]/{f=0} f' "$PLAN_FILE" 2>/dev/null)"
    printf '%s\n' "$goal_sec" | grep -qE '≤15min|<=15min' || mismatch_items="${mismatch_items}Goal 行缺 ≤15min 预估时长字样 "
    scope_sec="$(awk '/^##[[:space:]]*.*执行范围限制/{f=1;next} /^##[[:space:]]/{f=0} f' "$PLAN_FILE" 2>/dev/null)"
    scope_rows="$(printf '%s\n' "$scope_sec" | grep -c '^|' || true)"
    [ "${scope_rows:-0}" -gt 4 ] && mismatch_items="${mismatch_items}执行范围表数据行>2 (${scope_rows}行表格行) "
    if [ -n "$mismatch_items" ]; then
        if [ "$PTIER" = "enforce" ]; then
            echo "[plan-tier] MISMATCH: mini 判定条件不满足(${mismatch_items% }) — 阻断锁定(plan_tier_enforce=enforce, Rule 38.1); 改回 standard 或补齐条件" >&2
            exit 1
        else
            echo "[plan-tier] MISMATCH: mini 判定条件不满足(${mismatch_items% }) — 提示不阻断(plan_tier_enforce=warn 默认; 建议改回 standard, 或 TASK_PLANNER_PLAN_TIER_ENFORCE=enforce 升级阻断)"
        fi
    fi
fi

# ── S-unit 数值门控阈值（task-v075 P2-S1，仅派发型 Phase 数据行生效）────────
# [2026-09-16] jq 读 config.json（键参照 attest-plan.sh:80-97 tcfg 范式）；
# jq 缺失/键缺失 → 回退默认值（step_max_minutes=15 / step_max_files=2）
# 并打印一行 SKIPPED 说明（fail-open 显式化，同 attest-plan.sh:92-97 先例）
STEP_MAX_MIN=15
STEP_MAX_FILES=2
STEP_MAX_STEPS=4
cfg="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../config.json"
if command -v jq >/dev/null 2>&1 && [ -f "$cfg" ]; then
    # [2026-09-26 task-v091 C-1b：双层路径修复，顶层覆盖优先] 原 :115-116 缺第二层 .properties（键恒空只落字面兜底）；
    # 改为 .subagent.X // .properties.subagent.properties.X.default // 兜底（顶层覆盖优先，无覆盖时读 schema 默认，与 :118 step_max_steps 同构）
# [2026-10-08 task-v144 S17 P1-2] Rule 59.1 粒度三值列 enforce 门控落地（attest 侧,
# 对应用户 R1「单子代理巨量任务」——计划期硬门必须真实存在）:
#   S-unit 表 $8 粒度三值列（模板行格式 `1f/65l/13min`）trim 后匹配
#   ^([0-9]+)f/([0-9]+)l/([0-9]+)min$；三值逐一对 jq 读
#   .properties.subagent.properties.step_max_files/lines/minutes（缺失回退默认 2/100/15）
#   超限 → add_violation（enforce 拒锁, 超限 S-unit 回炉重拆, 59.1）；
#   列空或不匹配 = 旧格式计划 → 逐行 SKIPPED 提示「粒度三值未填报（Rule 59.1 强制）」
#   不阻断（fail-open, 旧格式兼容）。
STEP_MAX_MIN="$(jq -r '.subagent.step_max_minutes // .properties.subagent.properties.step_max_minutes.default // "15"' "$cfg" 2>/dev/null)" || STEP_MAX_MIN=""
STEP_MAX_FILES="$(jq -r '.subagent.step_max_files // .properties.subagent.properties.step_max_files.default // "2"' "$cfg" 2>/dev/null)" || STEP_MAX_FILES=""
# [2026-10-08 task-v144 S17 P1-2] step_max_lines 供 $8 粒度三值列校验（同双层路径范式）
STEP_MAX_LINES="$(jq -r '.subagent.step_max_lines // .properties.subagent.properties.step_max_lines.default // "100"' "$cfg" 2>/dev/null)" || STEP_MAX_LINES=""
    # [task-v081] 双层 properties 为 config 实际结构（.properties.subagent.properties.<key>.default）
    STEP_MAX_STEPS="$(jq -r '.properties.subagent.properties.step_max_steps.default // "4"' "$cfg" 2>/dev/null)" || STEP_MAX_STEPS=""
fi
if ! [[ "$STEP_MAX_MIN" =~ ^[0-9]+$ ]]; then
    STEP_MAX_MIN=15
    echo "[plan-dispatch] SKIPPED step_max_minutes 未解析(jq 缺失或键缺),回退默认 15"
fi
if ! [[ "$STEP_MAX_FILES" =~ ^[0-9]+$ ]]; then
    STEP_MAX_FILES=2
    echo "[plan-dispatch] SKIPPED step_max_files 未解析(jq 缺失或键缺),回退默认 2"
fi
if ! [[ "$STEP_MAX_LINES" =~ ^[0-9]+$ ]]; then
    STEP_MAX_LINES=100
    echo "[plan-dispatch] SKIPPED step_max_lines 未解析(jq 缺失或键缺),回退默认 100"
fi
if ! [[ "$STEP_MAX_STEPS" =~ ^[0-9]+$ ]]; then
    STEP_MAX_STEPS=4
    echo "[plan-dispatch] SKIPPED step_max_steps 未解析(jq 缺失或键缺),回退默认 4"
fi

# count_step_markers <file> — [task-v081] distinct 步骤枚举序号计数（⑤-b 第三 advisory 维消费）
# 口径与 check-dispatch.sh count_step_markers 同款（StepN/步骤N/第N步/①-⑮,按序号值去重;
# 行首 markdown 编号列表与汉字数字不入口径防误伤,详见彼处注释）。两脚本独立运行不互 source,
# 口径漂移由 selftest-fine-grain-steps.sh 双侧用例钉住。
count_step_markers() {
    local f="$1"
    {
        grep -oiE 'step ?[0-9]{1,3}' "$f" 2>/dev/null | grep -oE '[0-9]{1,3}'
        grep -oE '步骤 ?[0-9]{1,3}' "$f" 2>/dev/null | grep -oE '[0-9]{1,3}'
        grep -oE '第[0-9]{1,3}步' "$f" 2>/dev/null | grep -oE '[0-9]{1,3}'
        grep -oE '①|②|③|④|⑤|⑥|⑦|⑧|⑨|⑩|⑪|⑫|⑬|⑭|⑮' "$f" 2>/dev/null | awk '{if($0=="①")print 1;else if($0=="②")print 2;else if($0=="③")print 3;else if($0=="④")print 4;else if($0=="⑤")print 5;else if($0=="⑥")print 6;else if($0=="⑦")print 7;else if($0=="⑧")print 8;else if($0=="⑨")print 9;else if($0=="⑩")print 10;else if($0=="⑪")print 11;else if($0=="⑫")print 12;else if($0=="⑬")print 13;else if($0=="⑭")print 14;else if($0=="⑮")print 15}'
    } | sort -n -u | grep -c . || true
}

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
    # [2026-09-20 task-v086 P2-S3 Rule 38.4④] mini 豁免: 全 Phase Executor=主进程 → 缺 S-unit 表视为合规;
    # MINI_EXEMPT=0(非 mini / off 档 / 含子代理 Executor)走原逻辑=零改动
    if [ "$MINI_EXEMPT" = 1 ] && [ "$has_table" -eq 0 ] && [ "$has_rows" -eq 0 ]; then
        return 0
    fi
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
        # ⑤-b S-unit 数值门控（task-v075 P2-S1，KQ1 口径见文件头注释；
        # [2026-09-16 P11 用户裁决「模型判断任务复杂度,复杂就拆分」放宽]
        # 现象=数值硬拒锁过严 / 原行为=超限 add_violation 拒锁 /
        # 新行为=超限打 SKIPPED 提示放行,复杂度由模型判断,门控只提醒；
        # 执行体为空仍为违规(S-unit 规划完整性=Rule 22.6 义务,不变)）：
        col5="$(printf '%s' "$line" | awk -F'|' '{print $5}')"
        col7="$(printf '%s' "$line" | awk -F'|' '{print $7}')"
        col5="$(trim "$col5")"
        col7="$(trim "$col7")"
        # 时长：NNmin 且超 step_max_minutes → 提示拆分（不阻断）；不可解析 → SKIPPED 行
        if [[ "$col7" =~ ^([0-9]+)min$ ]]; then
            dur="${BASH_REMATCH[1]}"
            if [ "$dur" -gt "$STEP_MAX_MIN" ]; then
                echo "[plan-dispatch] SKIPPED Phase ${phase_no} S${s_id} 时长 ${dur}min > step_max_minutes(${STEP_MAX_MIN}) — 建议拆细(提示不阻断,复杂度由模型判断)"
            fi
        else
            echo "[plan-dispatch] SKIPPED Phase ${phase_no} S${s_id} 时长不可解析"
        fi
        # 输入：路径 token 计数超 step_max_files → 提示拆分（不阻断）
        pcount="$(printf '%s\n' "$col5" | grep -oE '[^ ]+\.(sh|md|json|ts|js|py|cjs)' | wc -l)"
        if [ "$pcount" -gt "$STEP_MAX_FILES" ]; then
            echo "[plan-dispatch] SKIPPED Phase ${phase_no} S${s_id} 输入 ${pcount} 个文件路径 > step_max_files(${STEP_MAX_FILES}) — 建议拆分(提示不阻断,复杂度由模型判断)"
        fi
        # [2026-10-08 task-v144 S17 P1-2] ⑤-c 粒度三值列($8, Nf/Nl/Nmin, 模板行格式 1f/65l/13min)
        # Rule 59.1 enforce 硬门: 匹配 ^([0-9]+)f/([0-9]+)l/([0-9]+)min$ 且三值任一超
        # step_max_files/step_max_lines/step_max_minutes → add_violation（拒锁, 回炉重拆）；
        # 列空/不匹配 = 旧格式计划 → SKIPPED 提示（fail-open 兼容, 59.5 任务书豁免同口径）
        col8="$(printf '%s' "$line" | awk -F'|' '{print $8}')"
        col8="$(trim "$col8")"
        # [2026-10-08 task-v144 S17] 例外登记在案放行（留痕不阻断）：行内含「例外」
        # 标记（如 S15 同质批量清账「文件数例外登记」）= 超限已登记理由，超限降为
        # SKIPPED 提示不拒锁——防 59.1 硬门误杀登记过例外的存量批量工序
        if [[ "$line" == *"例外登记"* ]]; then  # [task-v144 CR 复审建议] 收窄:整行「例外」子串过宽(验收列「无例外」即旁路),锚定显式登记 token
            if [[ "$col8" =~ ^([0-9]+)f/([0-9]+)l/([0-9]+)min$ ]] && { [ "${BASH_REMATCH[1]}" -gt "$STEP_MAX_FILES" ] || [ "${BASH_REMATCH[2]}" -gt "$STEP_MAX_LINES" ] || [ "${BASH_REMATCH[3]}" -gt "$STEP_MAX_MIN" ]; }; then
                echo "[plan-dispatch] SKIPPED Phase ${phase_no} S${s_id} 粒度三值 ${col8} 超限但行内例外登记在案 — 留痕不阻断(Rule 59.1 例外放行)"
            fi
        elif [[ "$col8" =~ ^([0-9]+)f/([0-9]+)l/([0-9]+)min$ ]]; then
            gfiles="${BASH_REMATCH[1]}"; glines="${BASH_REMATCH[2]}"; gmin="${BASH_REMATCH[3]}"
            if [ "$gfiles" -gt "$STEP_MAX_FILES" ]; then
                add_violation "$phase_no" "行 S${s_id} 粒度三值 ${gfiles}f/${glines}l/${gmin}min: 文件数 ${gfiles} > step_max_files(${STEP_MAX_FILES})（Rule 59.1 粒度三值硬门）— 回炉重拆"
            fi
            if [ "$glines" -gt "$STEP_MAX_LINES" ]; then
                add_violation "$phase_no" "行 S${s_id} 粒度三值 ${gfiles}f/${glines}l/${gmin}min: 新增行数 ${glines} > step_max_lines(${STEP_MAX_LINES})（Rule 59.1 粒度三值硬门）— 回炉重拆"
            fi
            if [ "$gmin" -gt "$STEP_MAX_MIN" ]; then
                add_violation "$phase_no" "行 S${s_id} 粒度三值 ${gfiles}f/${glines}l/${gmin}min: 时长 ${gmin}min > step_max_minutes(${STEP_MAX_MIN})（Rule 59.1 粒度三值硬门）— 回炉重拆"
            fi
        elif [ -n "$col8" ]; then
            echo "[plan-dispatch] SKIPPED Phase ${phase_no} S${s_id} 粒度三值格式不可解析(${col8})（Rule 59.1 粒度三值未填报或格式漂移,Nf/Nl/Nmin）"
        else
            echo "[plan-dispatch] SKIPPED Phase ${phase_no} S${s_id} 粒度三值未填报（Rule 59.1 强制）— 旧格式计划兼容 fail-open"
        fi
        # 步骤枚举（task-v081 第三维,advisory）: 目标($3) distinct 步骤枚举序号 > step_max_steps
        # → 提示拆分（不阻断,与前两维同范式）; 计数口径=上方 count_step_markers
        col3="$(printf '%s' "$line" | awk -F'|' '{print $3}')"
        ssteps="$(printf '%s\n' "$(trim "$col3")" | count_step_markers /dev/stdin)"
        if [ "$ssteps" -gt "$STEP_MAX_STEPS" ]; then
            echo "[plan-dispatch] SKIPPED Phase ${phase_no} S${s_id} 步骤枚举 ${ssteps} > step_max_steps(${STEP_MAX_STEPS}) — 建议拆分(提示不阻断,复杂度由模型判断)"
        fi
    fi
done < "$PLAN_FILE"
settle_phase    # EOF 结算最后一个 Phase

# ── [2026-10-09 task-v151 S2] Rule 66.5 Goal 单元表校验段 ──────────────────
# WHAT: 校验「🎯 Goal 单元表」区块存在性 + 六列表头锚 + 数据行 goal-id 连续性
#       + 完整验证方式列非空且非占位符
# WHY: Rule 66.5 模板区块承载与 mini 豁免——standard/full 档必填，mini 档豁免；
#      check-plan-dispatch.sh attest 期对 standard/full 档做区块存在性+六列+验证方式列非空机械校验，
#      缺失=拒锁（59.1 硬门同档）；--skip-goal-check 逃生口对齐 --skip-dispatch-check 惯例
# 挂点: S-unit 校验段之后、最终 exit 判定前
# 逃生口: --skip-goal-check（echo 登记行，对齐脚本内既有 --skip-* 实现方式）

# --skip-goal-check 逃生口登记
GOAL_CHECK_SKIP=0
for arg in "$@"; do
    if [ "$arg" = "--skip-goal-check" ]; then
        GOAL_CHECK_SKIP=1
        echo "[plan-dispatch] SKIPPED Rule 66.5 Goal 单元表校验（--skip-goal-check 逃生口登记）"
        break
    fi
done

if [ "$GOAL_CHECK_SKIP" = 0 ]; then
    # [2026-10-09 task-v151 S4b 主进程 D2 裁决 方案①] 档位判定修正：
    #   What：原判定=「PLAN_TIER_MINI=1（仅显式 plan_tier: mini）才豁免，否则（含无 plan_tier 标记）
    #         一律按 standard/full 硬拒锁」。
    #   Why ：该口径对「无 plan_tier 标记」的 legacy 计划/合成夹具硬拒锁，破坏既有行为契约
    #         （selftest-plan-tier PT-22 明示无标记样例 check-plan-dispatch rc=0），波及 7 个行为级
    #         selftest（24 FAIL）。修正=向后兼容优先：仅**显式** plan_tier: standard|full 才执行 66.5
    #         硬拒锁；无标记=缺省档整体跳过（legacy/合成夹具兼容口径，不影响 exit）；显式 mini=跳过
    #         （66.5 mini 豁免原文义）。缺省档的 66.5 覆盖由模板兜底（新计划经 init 必有
    #         「🎯 Goal 单元表」区块），非由拒锁兜底。判定写法对齐脚本内既有 plan_tier grep 范式。
    if grep -qm1 -E 'plan_tier:[[:space:]]*(standard|full)' "$PLAN_FILE" 2>/dev/null; then
        # standard/full 档：区块存在性 + 六列表头锚 + 数据行校验（原逻辑保留）
        # awk 状态机抽「^## 🎯 Goal 单元表」区块（参照脚本行 92-94 既有状态机写法，禁区间 next 坍缩范式）
        goal_sec="$(awk '/^##[[:space:]]*🎯[[:space:]]*Goal[[:space:]]*单元表/{f=1;next} /^##[[:space:]]/{f=0} f' "$PLAN_FILE" 2>/dev/null)"
        
        # ① 区块存在性
        if [ -z "$goal_sec" ]; then
            add_violation "N/A" "Rule 66.5: 缺「🎯 Goal 单元表」区块（standard/full 档必填）"
        else
            # ② 六列表头锚 grep
            goal_header="$(printf '%s\n' "$goal_sec" | grep -E '^\|[[:space:]]*goal-id[[:space:]]*\|' | head -1)"
            if [ -z "$goal_header" ]; then
                add_violation "N/A" "Rule 66.5: Goal 单元表缺表头行（goal-id 列锚）"
            else
                # 检查六列关键词各命中
                for kw in "goal-id" "任务名" "目标" "完整验证方式" "对应 S-unit" "状态"; do
                    if ! printf '%s\n' "$goal_header" | grep -q "$kw"; then
                        add_violation "N/A" "Rule 66.5: Goal 单元表表头缺列「${kw}」"
                    fi
                done
            fi
            
            # ③ 数据行校验
            goal_data_rows="$(printf '%s\n' "$goal_sec" | grep -E '^\|[[:space:]]*G[0-9]+[[:space:]]*\|' || true)"
            if [ -z "$goal_data_rows" ]; then
                add_violation "N/A" "Rule 66.5: Goal 单元表无数据行（G1 起）"
            else
                # goal-id 连续性 + 完整验证方式列校验
                expected_g=1
                while IFS= read -r row; do
                    # 提取 goal-id（$2，awk -F'|'）
                    gid="$(printf '%s' "$row" | awk -F'|' '{print $2}')"
                    gid="$(trim "$gid")"
                    # 提取完整验证方式列（$5）
                    verify_col="$(printf '%s' "$row" | awk -F'|' '{print $5}')"
                    verify_col="$(trim "$verify_col")"
                    
                    # goal-id 匹配 ^G[0-9]+$ 且序号连续
                    if ! [[ "$gid" =~ ^G([0-9]+)$ ]]; then
                        add_violation "N/A" "Rule 66.5: goal-id「${gid}」不匹配 ^G[0-9]+$"
                    else
                        actual_g="${BASH_REMATCH[1]}"
                        if [ "$actual_g" -ne "$expected_g" ]; then
                            add_violation "N/A" "Rule 66.5: goal-id 序号不连续（期望 G${expected_g}，实际 ${gid}）"
                        fi
                        expected_g=$(( expected_g + 1 ))
                    fi
                    
                    # 完整验证方式列非空且不含未填占位（尖括号 < 起头）与黑名单词
                    if [ -z "$verify_col" ] || [ "$verify_col" = "-" ]; then
                        add_violation "N/A" "Rule 66.5: goal ${gid} 完整验证方式列为空"
                    elif [[ "$verify_col" == \<* ]]; then
                        add_violation "N/A" "Rule 66.5: goal ${gid} 完整验证方式列为占位符（< 起头）"
                    elif [[ "$verify_col" == *"检查没问题"* ]]; then
                        add_violation "N/A" "Rule 66.5: goal ${gid} 完整验证方式列含黑名单词「检查没问题」"
                    fi
                done <<< "$goal_data_rows"
            fi
        fi
    elif grep -qm1 'plan_tier: mini' "$PLAN_FILE" 2>/dev/null; then
        # mini 档豁免：缺区块仅 WARN 提示行不硬拒锁（66.5 mini 豁免原文义）
        goal_sec="$(awk '/^##[[:space:]]*🎯[[:space:]]*Goal[[:space:]]*单元表/{f=1;next} /^##[[:space:]]/{f=0} f' "$PLAN_FILE" 2>/dev/null)"
        if [ -z "$goal_sec" ]; then
            echo "[plan-dispatch] WARN Rule 66.5: mini 档豁免，Goal 单元表区块缺失（不拒锁）"
        fi
    else
        # 无 plan_tier 标记 = 缺省档（legacy/合成夹具）：66.5 段整体跳过，不影响 exit
        echo "[goal-check] 无 plan_tier 标记，66.5 goal 门缺省跳过（legacy/无档位兼容口径）"
    fi
fi

# ── [2026-10-09 task-v153 S4] Rule 68 依赖与并行分组校验段 ──────────────────
# WHAT: Rule 68 计划期两档校验（插于 66.5 Goal 单元表校验段之后、最终输出判定之前）：
#   hard 档（走既有 add_violation 管线 → 拒锁 exit 1）：
#     H1 「前置依赖」列存在性——任一 S-unit 表头须含「前置依赖」字样，S-unit 表存在但缺列即违规；
#     H2 逐行非空——S-unit 数据行「前置依赖」单元格为空（未显式填 -）即违规；
#        F8 列数漂移（2026-10-09 CR 补）：数据行按 | 切分列数≠表头列数 → 违规（格式漂移/裸管道，
#        design §二 H2 承诺「单元格含裸管道按 violation 提示」落地）；
#     H3 组标记存在性——frontmatter parallel_groups 声明的每个组名，计划内须有
#        [parallel-group:<组名>] 标记，声明无成员即违规；
#     H4 依赖-同组矛盾——行 R「前置依赖」含单元 D，且 R 与 D 同属一组即违规。
#   F1 组归属口径统一（2026-10-09 CR 补）：H4/W1/W2 的行组归属取值优先级=行内标记 >「并行组」列 >
#    注解行 `[parallel-group:X] = ID 列表`（模板无「并行组」列，真实计划以注解形态承载；见下方解析）。
#   advisory 档（echo `[plan-dispatch] WARN …` → 不拒锁）：
#     W1 组内全同——同组内执行体列值全部相同（提示 68.3 异构分摊）；
#     W2 组内成员执行体全部为「继承」。
# WHY: 68.1 前置依赖列空白=计划无效回炉（59.1 硬门同档）；68.2 依赖者与被依赖者禁同组、
#   组标记承载声明制；68.3 组内异构分摊（同组 subagent_type 或 model 至少一项不同）；
#   68.6 机器边界如实披露——守卫只消费表内显式字段，不做文件集交集自动推断（分析责任在计划者）。
# 档位接线: 与 66.5 段三分支口径一致——仅显式 plan_tier: standard|full 执行（hard 拒锁 +
#   advisory 提示）；mini 档/无标记档整体跳过（legacy/合成夹具兼容，66.5 D2 裁决先例）；
#   无 S-unit 表的计划整体跳过。全部走既有 add_violation 管线，零新 config 键。
# awk 状态机: 参照 66.5 段范式（flag 状态机；禁区间 next 坍缩范式——gawk 区间 bug 已知）。
#   F2 列位陈旧修复（2026-10-09 CR 补）：遇非 S-unit 表头（^| ID | 但无「执行体」）或空行即重置列位状态，
#   防连续无空行两表沿用陈旧 dep 列位→第二表数据行产生假 H2。

# frontmatter parallel_groups 声明解析（行内 bracket 列表形态，对齐设计稿 `parallel_groups: [g1, g2]`）
rule68_groups=""
rule68_pg_line="$(grep -m1 -E '^[[:space:]]*parallel_groups:' "$PLAN_FILE" 2>/dev/null || true)"
if [ -n "$rule68_pg_line" ]; then
    rule68_groups="$(printf '%s' "$rule68_pg_line" \
        | sed -E 's/^[^:]*:[[:space:]]*//; s/^\[//; s/\][[:space:]]*$//' \
        | tr ',' '\n' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' | grep -v '^$' || true)"
fi

# 依赖列单元格展开：顿号/逗号分隔 + 同前缀区间（如 S1-S6 → S1 S2 ... S6；H4 消费）
rule68_expand_deps() {
    local cell="$1" tok pfx lo hi n out=""
    cell="${cell//、/ }"; cell="${cell//,/ }"; cell="${cell//，/ }"
    for tok in $cell; do
        if [[ "$tok" =~ ^([A-Za-z]+)([0-9]+)-([A-Za-z]+)([0-9]+)$ ]] && [ "${BASH_REMATCH[1]}" = "${BASH_REMATCH[3]}" ]; then
            pfx="${BASH_REMATCH[1]}"; lo="${BASH_REMATCH[2]}"; hi="${BASH_REMATCH[4]}"
            if [ "$lo" -le "$hi" ]; then
                n="$lo"; while [ "$n" -le "$hi" ]; do out="${out} ${pfx}${n}"; n=$(( n + 1 )); done
            fi
        else
            out="${out} ${tok}"
        fi
    done
    printf '%s' "$out"
}

if grep -qm1 -E 'plan_tier:[[:space:]]*(standard|full)' "$PLAN_FILE" 2>/dev/null; then
    # 抽取各 S-unit 表：表头列位（前置依赖/执行体/并行组）+ 数据行四列 + 行内组标记 + 列数漂移标志。
    # 字段分隔符 = \037（单元分隔符，非空白 → 空单元格不坍缩；tab 属 IFS 空白会坍缩，故不用）。
    # 输出行：HDR\037dep_idx\037exec_idx\037grp_idx\037表头列数\037表头原文
    #         ROW\037id\037执行体\037前置依赖\037并行组\037行内组标记\037列数漂移标志
    # [2026-10-09 task-v153 CR-F2] awk 状态机列位陈旧修复：遇非 S-unit 表头（^| ID | 但无「执行体」，
    #   如 Goal 单元表）或空行即关闭表状态并清列位——原实现仅在「非 | 行」重置 in_tbl 而不清 dep/ex/gr，
    #   连续无空行分隔的两表会沿用陈旧列位，第二表数据行按旧 dep 列位解析产生假 H2。
    # [2026-10-09 task-v153 CR-F8] 裸管道列数漂移：记录表头列数 hdr_nf，数据行 NF≠hdr_nf 即标漂移
    #   （design §二 H2 承诺：单元格含裸管道按 violation 提示；本仓判例=管道未转义挤列）。
    #   [修复C 2026-10-09 CR二轮MINOR] 计列前先剔除转义管道「\|」：awk -F'|' 不区分裸/转义管道，
    #   合法 grep BRE 交替（如 grep A\|B）会把 NF 虚增导致假 F8；剔除后计数，裸管道仍触发（语义保持）。
    rule68_dump="$(awk -F'|' '
        /^\|[[:space:]]*ID[[:space:]]*\|/ {
            if (/执行体/) {
                in_tbl=1; dep=0; ex=0; gr=0
                ht=$0; gsub(/\\\|/, "", ht); hdr_nf=split(ht, htmp, "|")
                for (i=1;i<=NF;i++) {
                    c=$i; gsub(/^[[:space:]]+|[[:space:]]+$/, "", c)
                    if (c ~ /前置依赖/) dep=i
                    if (c ~ /执行体/)   ex=i
                    if (c ~ /并行组/)   gr=i
                }
                printf "HDR\037%d\037%d\037%d\037%d\037%s\n", dep, ex, gr, hdr_nf, $0
            } else {
                in_tbl=0; dep=0; ex=0; gr=0; hdr_nf=0
            }
            next
        }
        /^[[:space:]]*$/ { in_tbl=0; dep=0; ex=0; gr=0; hdr_nf=0; next }
        /^\|[[:space:]]*-+/ { next }
        in_tbl && /^\|[[:space:]]*[A-Za-z]+[0-9]+[[:space:]]*\|/ {
            id=$2; gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
            ev=""; dv=""; gv=""
            if (ex>0)  { ev=$ex;  gsub(/^[[:space:]]+|[[:space:]]+$/, "", ev) }
            if (dep>0) { dv=$dep; gsub(/^[[:space:]]+|[[:space:]]+$/, "", dv) }
            if (gr>0)  { gv=$gr;  gsub(/^[[:space:]]+|[[:space:]]+$/, "", gv) }
            mk=""
            if (match($0, /\[parallel-group:[^]]+\]/)) mk=substr($0, RSTART+16, RLENGTH-17)
            drift=0
            # [修复C 2026-10-09 CR二轮MINOR] 漂移比较前剔除「\|」转义对再计数（与 hdr_nf 同口径）；
            #   裸管道（未转义挤列）仍计入 → 真实漂移照样触发 F8。
            rt=$0; gsub(/\\\|/, "", rt)
            if (hdr_nf>0 && split(rt, rtmp, "|")!=hdr_nf) drift=1
            printf "ROW\037%s\037%s\037%s\037%s\037%s\037%d\n", id, ev, dv, gv, mk, drift
            next
        }
        { if (in_tbl && $0 !~ /^[[:space:]]*\|/) in_tbl=0 }
    ' "$PLAN_FILE" 2>/dev/null || true)"

    if [ -z "$rule68_dump" ]; then
        :   # 无 S-unit 表（mini/legacy）→ Rule 68 段整体跳过（对齐 66.5「无表整体跳过」口径）
    else
        # ── 注解形态组归属兜底（F1，2026-10-09 task-v153 CR）────────────────────────────
        # WHAT: 扫描计划内 `[parallel-group:<组名>]` 后随「= 单元ID 列表」（逗号/顿号/全角逗号分隔，
        #   支持 S1-S6 同前缀区间）的注解行，建立 单元ID→组名 映射（ANN\037id\037组名）。
        # WHY: 模板无「并行组」列（grep -c '并行组' templates/task_plan.md=0），21.4 允许注解行
        #   承载组标记——真实计划以「[parallel-group:X] = S1, S2, …」注解形态声明组归属。
        #   原实现 H4/W1/W2 的行组归属只取「并行组」列或行内标记，注解形态下全空 → H4(hard)/W1/W2
        #   静默失效。本兜底把注解解析并入同一 ID→组映射表，使注解形态可触发 H4 判定。
        #   消费优先级：行内标记 > 「并行组」列 > 注解兜底（列/行内已有归属不覆盖）。
        rule68_ann="$(awk '
            {
                s=$0
                while (match(s, /\[parallel-group:[^]]+\]/)) {
                    grpname=substr(s, RSTART+16, RLENGTH-17)
                    rest=substr(s, RSTART+RLENGTH)
                    seg=rest
                    sub(/^[[:space:]`*]*/, "", seg)
                    if (seg ~ /^=/) {
                        seg=substr(seg, 2)
                        sub(/[（(；;。*|].*$/, "", seg)
                        n=split(seg, arr, /[[:space:]]*[,、，][[:space:]]*/)
                        for (k=1;k<=n;k++) {
                            tok=arr[k]
                            gsub(/^[[:space:]`*]+|[[:space:]`*]+$/, "", tok)
                            if (tok ~ /^[A-Za-z]+[0-9]+-[A-Za-z]+[0-9]+$/) {
                                split(tok, rg, "-")
                                pfx=rg[1]; sub(/[0-9]+$/, "", pfx)
                                lo=rg[1]; sub(/^[A-Za-z]+/, "", lo)
                                hi=rg[2]; sub(/^[A-Za-z]+/, "", hi)
                                for (mm=lo+0; mm<=hi+0; mm++) printf "ANN\037%s%s\037%s\n", pfx, mm, grpname
                            } else if (tok ~ /^[A-Za-z]+[0-9]+$/) {
                                printf "ANN\037%s\037%s\n", tok, grpname
                            }
                        }
                    }
                    s=rest
                }
            }
        ' "$PLAN_FILE" 2>/dev/null || true)"
        declare -A rule68_ann_grp=()
        while IFS=$'\037' read -r rule68_at rule68_aid rule68_agrp; do
            [ "$rule68_at" = "ANN" ] || continue
            [ -n "$rule68_aid" ] || continue
            [ -n "$rule68_agrp" ] || continue
            rule68_ann_grp["$rule68_aid"]="$rule68_agrp"
        done <<< "$rule68_ann"

        # ── 第一遍：H1（表头列存在性）+ H2（数据行前置依赖非空）+ F8（列数漂移）+ 收集行数据 ──
        rule68_rows=""
        rule68_tbl=0
        rule68_dep_idx=0; rule68_ex_idx=0; rule68_grp_idx=0
        while IFS=$'\037' read -r rule68_tag rule68_f1 rule68_f2 rule68_f3 rule68_f4 rule68_f5 rule68_f6; do
            case "$rule68_tag" in
                HDR)
                    rule68_tbl=$(( rule68_tbl + 1 ))
                    rule68_dep_idx="$rule68_f1"; rule68_ex_idx="$rule68_f2"; rule68_grp_idx="$rule68_f3"
                    if [ "$rule68_dep_idx" -eq 0 ]; then
                        add_violation "N/A" "Rule 68.1: S-unit 表(第${rule68_tbl}表)缺「前置依赖」列（hard H1）"
                    fi
                    ;;
                ROW)
                    # f1=id f2=执行体 f3=前置依赖 f4=并行组 f5=行内组标记 f6=列数漂移标志
                    if [ "$rule68_dep_idx" -gt 0 ] && [ -z "$rule68_f3" ]; then
                        add_violation "N/A" "Rule 68.1: 行 ${rule68_f1} 「前置依赖」单元格为空（未显式填 -，hard H2）"
                    fi
                    if [ "${rule68_f6:-0}" = "1" ]; then
                        add_violation "N/A" "Rule 68.1: 行 ${rule68_f1} 列数漂移——数据行列数与表头列数不一致（格式漂移/裸管道，hard F8）"
                    fi
                    rule68_g="$rule68_f5"
                    if [ -z "$rule68_g" ] && [ -n "$rule68_f4" ] && [ "$rule68_f4" != "-" ]; then
                        rule68_g="$rule68_f4"
                    fi
                    if [ -z "$rule68_g" ]; then
                        rule68_g="${rule68_ann_grp[$rule68_f1]:-}"
                    fi
                    rule68_rows="${rule68_rows}${rule68_f1}"$'\037'"${rule68_f2}"$'\037'"${rule68_f3}"$'\037'"${rule68_g}"$'\n'
                    ;;
            esac
        done <<< "$rule68_dump"

        # id → 组 映射（H4 依赖-同组矛盾消费）
        declare -A rule68_id2grp=()
        while IFS=$'\037' read -r rule68_id rule68_ev rule68_dv rule68_gv; do
            [ -n "$rule68_id" ] || continue
            [ -n "$rule68_gv" ] && rule68_id2grp["$rule68_id"]="$rule68_gv"
        done <<< "$rule68_rows"

        # ── H4 依赖-同组矛盾（行 R 前置依赖含单元 D 且 R 与 D 同组）──
        while IFS=$'\037' read -r rule68_id rule68_ev rule68_dv rule68_gv; do
            [ -n "$rule68_id" ] || continue
            [ -n "$rule68_gv" ] || continue
            [ -n "$rule68_dv" ] || continue
            [ "$rule68_dv" = "-" ] && continue
            for rule68_d in $(rule68_expand_deps "$rule68_dv"); do
                [ "$rule68_d" = "$rule68_id" ] && continue
                if [ "${rule68_id2grp[$rule68_d]:-}" = "$rule68_gv" ]; then
                    add_violation "N/A" "Rule 68.2: 依赖-同组矛盾——行 ${rule68_id} 前置依赖含 ${rule68_d}，且二者同属并行组「${rule68_gv}」（hard H4）"
                fi
            done
        done <<< "$rule68_rows"

        # ── H3 组标记存在性（声明组须有计划内 [parallel-group:<组名>] 标记；全计划 grep 标记集）──
        while IFS= read -r rule68_g; do
            [ -n "$rule68_g" ] || continue
            if ! grep -qF "[parallel-group:${rule68_g}]" "$PLAN_FILE" 2>/dev/null; then
                add_violation "N/A" "Rule 68.2: parallel_groups 声明组「${rule68_g}」无对应 [parallel-group:${rule68_g}] 标记（hard H3）"
            fi
        done <<< "$rule68_groups"

        # ── W1/W2 组内异构（advisory，WARN 不拒锁；68.3）──
        rule68_glist=""
        while IFS=$'\037' read -r rule68_id rule68_ev rule68_dv rule68_gv; do
            [ -n "$rule68_gv" ] || continue
            case " ${rule68_glist} " in
                *" ${rule68_gv} "*) ;;
                *) rule68_glist="${rule68_glist} ${rule68_gv}" ;;
            esac
        done <<< "$rule68_rows"
        for rule68_g in $rule68_glist; do
            rule68_execs=""
            while IFS=$'\037' read -r rule68_id rule68_ev rule68_dv rule68_gv; do
                [ "$rule68_gv" = "$rule68_g" ] && rule68_execs="${rule68_execs}${rule68_ev}"$'\n'
            done <<< "$rule68_rows"
            rule68_n="$(printf '%s' "$rule68_execs" | grep -c . || true)"
            [ "${rule68_n:-0}" -ge 2 ] || continue
            rule68_inherit="$(printf '%s' "$rule68_execs" | grep -cx '继承' || true)"
            rule68_uniq="$(printf '%s' "$rule68_execs" | sort -u | grep -c . || true)"
            if [ "$rule68_inherit" -eq "$rule68_n" ]; then
                echo "[plan-dispatch] WARN Rule 68.3: 并行组「${rule68_g}」组内成员执行体全部为「继承」（${rule68_n} 成员）— 建议显式具体化执行体并异构分摊（agent 类型或模型档位至少一项不同）"
            elif [ "$rule68_uniq" -eq 1 ]; then
                echo "[plan-dispatch] WARN Rule 68.3: 并行组「${rule68_g}」组内全同执行体「$(printf '%s' "$rule68_execs" | head -1)」（${rule68_n} 成员）— 建议组内异构分摊（agent 类型或模型档位至少一项不同）"
            fi
        done
    fi
fi

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
