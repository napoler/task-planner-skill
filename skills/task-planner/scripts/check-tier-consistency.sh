#!/usr/bin/env bash
# check-tier-consistency.sh — P-09「档位声明外部体量复核」（mini 四条件体量复核 + L0 禁滥用复核）
# [2026-10-16 P-09 实施] 审计提案 P-09 根因：task_plan.md 的 plan_tier（standard/mini）与
#   execution_lane（L0/L1/L2）由计划文件内自行声明，无外部体量复核——重计划可自声明 mini/L0
#   降档规避门控（38.4 五处豁免 + 38.7 轻量通道都被降档声明白拿）。本脚本把判定面落在计划文件
#   本体的机器可抽指标上，让「声明」与「体量」可机器对照。
#
# What（判定面 + 输入输出契约）：
#   输入: <plan-dir>/task_plan.md；抽取 frontmatter `plan_tier:` 与 `execution_lane:` 声明值
#     （行首锚定 ^plan_tier: / ^execution_lane:，排除 HTML 注释伪声明 `<!-- plan_tier: standard -->`）。
#   外部体量指标（全部由计划本体机器抽取，无外部输入）：
#     lines   = 计划行数（wc -l）
#     phases  = Phase 标题数（^#{2,4} Phase[数字] 行；容器标题「## Phases」不计——防计数虚增）
#     vc      = VC 去重数（VC-N 字面）
#     sunit   = S-unit 去重数（S-N 字面，词边界守护防 PASS-1 / VC-1 式误命中）
#     scope   = 「执行范围限制」表数据行数（无该段 = 0 且跳过文件数检查）
#   判定（仅当声明 mini 或 L0/L0-T 时触发；standard/full 声明不触发——降档声明才有复核面）：
#     · mini 体量复核（Rule 38.1 四条件的机器近似，任一命中 → 不一致）：
#         phases > 2 ∨ vc ≥ 5 ∨ sunit ≥ 3 ∨ lines > 150
#     · L0 禁滥用复核（Rule 38.7「禁止 L0/L0-T 滥用」，任一命中 → 不一致）：
#         多 Phase（phases ≥ 2；L0=单 Phase 执行）∨ 多文件（scope > 3；L0-T cap 12）
#         ∨ 重门控（sunit ≥ 3，多 S-unit 派发=超出轻量通道单 Phase 直做形态）
#   输出（**stdout**，供 caller 中继）前缀 `[tier-consistency]`：
#     不一致: `[tier-consistency] ✗ 声明 plan_tier=mini 但体量达 standard 级: <指标>`
#             `[tier-consistency] ✗ 声明 execution_lane=L0 但形态超出轻量通道: <指标>`
#     无声明: `[tier-consistency] SKIP (无档位声明 ...)` → exit 0（无判定面 fail-open）
#   退出码: 0=档位声明与体量一致（或无判定面）；1=存在不一致；2=输入缺失（plan-dir 缺失/非目录 / task_plan.md 缺失）
#
# Why（设计取舍，逐条给理由）：
#   · 判定面为何是计划本体指标而非「声明 vs 外部输入」：P-09 痛点恰是声明自洽（无外部输入可比对）——
#     唯一可机器对照的面 = 计划本体自身的体量形态（Phase/VC/S-unit/行数/scope 表），且该面重计划
#     自己填写、可被机器清点，构成「自声明」的外部复核闭环。
#   · 阈值为何取「达 standard 级才报」的保守单指标触发（无多数投票）：
#     phases ≤2 与 vc <5 精确对齐 38.2/38.4（mini=2 Phase；VC 门 standard=5 vs mini=2，
#     mini 计划 vc 达 5 = 体量已按 standard 仪式展开）；sunit ≥3 = 多单元派发已超出轻量档单 Phase
#     直做形态；lines=150 保守取值——容忍携带 standard 区块（51.1 用户需求原文/53.1 根源覆盖表
#     等标配段）的 mini 计划，阈值是「体量达 standard 级」的下界而非 mini 模板 80 行硬限。
#   · 无档位声明为何 exit 0 而非 2：对齐 38.1「未声明 plan_tier 的既有计划 → 全部按 standard 执行，
#     零影响」口径——无声明 = 无降档行为 = 无判定面（fail-open）；exit 2 仅留给输入缺失（无文件可判）。
#   · scope 表缺失为何跳过文件数检查：无表即无文件清单可清点（fail-open，同 check-evidence-anchor.sh
#     「缺表头即跳过」范式）；但多 Phase / 重门控两项与 scope 表无关，照常判定。
#   · L0-T 为何 cap 12 非 3：L0-T 纯文本档（2026-10-15 文本优先裁决，task-v177）文件数不设硬上限、
#     cap ≤12 防变相基建（38.7 L0-T 条款原文）；判定以计划内 `L0-T` 字面探测分流。
# 用法: bash check-tier-consistency.sh <plan-dir>
# 依赖: bash + grep/awk/sed/sort/wc（无 jq / 无 python，纯 bash 实现，同 check-evidence-anchor.sh 口径）
set -u

PLAN_DIR="${1:-}"
if [ -z "$PLAN_DIR" ] || [ ! -d "$PLAN_DIR" ]; then
    printf '[tier-consistency] ERROR: plan-dir 缺失或非目录: %s\n' "${PLAN_DIR:-<empty>}" >&2
    exit 2
fi
PLAN_FILE="$PLAN_DIR/task_plan.md"
if [ ! -f "$PLAN_FILE" ]; then
    printf '[tier-consistency] ERROR: task_plan.md 缺失: %s\n' "$PLAN_FILE" >&2
    exit 2
fi

# ── 声明抽取（行首锚定；排除 `<!-- plan_tier: standard -->` 注释伪声明与模板示例行）──
TIER="$(grep -m1 -E '^plan_tier:' "$PLAN_FILE" | sed -E 's/^plan_tier:[[:space:]]*//' | tr -d '[:space:]' | tr 'A-Z' 'a-z')"
# [L-2 修复 2026-10-23] 原行为: `grep -oE 'L[012]'` 把 L0-E/L0-T 前缀截成 L0 → L0-E 计划误入 L0 复核 false FAIL。
# 改为精确 token 解析（L0 / L0-T / L0-E / L1 / L2 原样；小写声明不命中 → LANE 空 = 无 lane 判定面, 走 SKIP fail-open）
LANE="$(grep -m1 -E '^execution_lane:' "$PLAN_FILE" | grep -oE 'L[012]([_-][A-Za-z0-9]+)*' | head -n 1)"
IS_L0T=0
grep -q 'L0-T' "$PLAN_FILE" && IS_L0T=1

# ── 体量指标抽取 ─────────────────────────────────────────────────────────────
# lines / phases（容器标题「## Phases」不计，只认带数字的 Phase 标题行）
LINES="$(wc -l < "$PLAN_FILE")"
PHASES="$(grep -cE '^#{2,4}[[:space:]]*Phase[[:space:]]*[0-9]' "$PLAN_FILE" || true)"
PHASES="${PHASES:-0}"
# vc / sunit 去重计数：前置词边界守护（前一字符非字母数字），防 PASS-1 / MISMATCH 等散文误命中
VC="$(grep -oE '(^|[^A-Za-z0-9])VC-[0-9]+' "$PLAN_FILE" | grep -oE 'VC-[0-9]+' | sort -u | wc -l)"
SUNIT="$(grep -oE '(^|[^A-Za-z0-9])S-[0-9]+' "$PLAN_FILE" | grep -oE 'S-[0-9]+' | sort -u | wc -l)"
# scope 表数据行数（「## ⚠️ 执行范围限制」段内 | 行，跳过表头与分隔行；无段=0 且 SCOPE_FOUND=0）
_SCOPE_OUT="$(awk '
    /^##[^#]/ { if (index($0, "执行范围限制") > 0) { insec = 1; found = 1 } else { insec = 0 } next }
    insec == 1 && /^\|/ {
        row = $0; gsub(/[*`]/, "", row)
        if (row ~ /^[[:space:]]*\|[[:space:]|-]+$/) next   # 分隔行 |----|
        if (!seen++) next                                    # 表头
        n++
    }
    END { printf "%d %d", n + 0, found + 0 }
' "$PLAN_FILE" 2>/dev/null)"
SCOPE="${_SCOPE_OUT%% *}"
SCOPE_FOUND="${_SCOPE_OUT#* }"
[ -n "$SCOPE" ] && [ -n "$SCOPE_FOUND" ] || { SCOPE=0; SCOPE_FOUND=0; }

# ── 无判定面：两档声明均缺 → SKIP exit 0（fail-open，对齐 38.1 legacy 零影响口径）──
if [ -z "$TIER" ] && [ -z "$LANE" ]; then
    printf '[tier-consistency] SKIP (无档位声明: plan_tier / execution_lane 均缺 → 无判定面, exit 0)\n'
    exit 0
fi

# ── 阈值常量（保守「达 standard 级」近似，单一指标触发；改动前须跑存量基线）────────
MINI_MAX_PHASES=2    # 38.2: mini = 2 Phase（实施+验收）
MINI_VC_LIMIT=5      # 38.4 VC 门: standard=5 vs mini=2；vc ≥5 = 体量达 standard 级
MINI_MAX_SUNIT=2     # sunit ≥3 = 多 S-unit 派发，超出轻量档单 Phase 直做形态
MINI_MAX_LINES=150   # 行数保守下界（容忍 standard 区块携带）
L0_MAX_FILES=3       # 38.7 L0: ≤3 文件
L0T_MAX_FILES=12     # 38.7 L0-T 纯文本档 cap ≤12（task-v177 文本优先裁决）
L0_MAX_PHASES=1      # 38.7 L0: 单 Phase 执行
L0_MAX_SUNIT=2       # L0 重门控: sunit ≥3 = 多单元派发

FAILS=0

# ── mini 体量复核（Rule 38.1 四条件外部近似）──
if [ "$TIER" = "mini" ]; then
    if [ "$PHASES" -gt "$MINI_MAX_PHASES" ]; then
        FAILS=$((FAILS + 1))
        printf '[tier-consistency] ✗ 声明 plan_tier=mini 但体量达 standard 级: Phase 数=%s（> %s, mini 应 ≤2 Phase）\n' "$PHASES" "$MINI_MAX_PHASES"
    fi
    if [ "$VC" -ge "$MINI_VC_LIMIT" ]; then
        FAILS=$((FAILS + 1))
        printf '[tier-consistency] ✗ 声明 plan_tier=mini 但体量达 standard 级: VC 数=%s（≥%s 达 standard 级, mini 阈值 ≤%s）\n' "$VC" "$MINI_VC_LIMIT" "$((MINI_VC_LIMIT - 1))"
    fi
    if [ "$SUNIT" -gt "$MINI_MAX_SUNIT" ]; then
        FAILS=$((FAILS + 1))
        printf '[tier-consistency] ✗ 声明 plan_tier=mini 但体量达 standard 级: S-unit 数=%s（> %s, 多单元派发超出轻量档形态）\n' "$SUNIT" "$MINI_MAX_SUNIT"
    fi
    if [ "$LINES" -gt "$MINI_MAX_LINES" ]; then
        FAILS=$((FAILS + 1))
        printf '[tier-consistency] ✗ 声明 plan_tier=mini 但体量达 standard 级: 计划行数=%s（> %s）\n' "$LINES" "$MINI_MAX_LINES"
    fi
fi

# ── L0 禁滥用复核（Rule 38.7: 多文件/多 Phase/重门控 → 不适用轻量通道）──
# L0-E 豁免: 纯执行档（权重 0 口径: 零受管变更 ∧ 产物落 gitignore 区, SKILL.md:187）, 套 L0 单 Phase cap 与其定义冲突 → 不进入本复核块
# L0-T 全量继承 L0 三项检查（单 Phase / cap 取 L0T_MAX_FILES / S-unit cap）; 仅 L0-E 整体豁免（修正轮 2026-10-23: L0-T 单 Phase cap 不回退, 主进程裁决）
if [ "$LANE" = "L0" ] || [ "$LANE" = "L0-T" ]; then
    CAP=$L0_MAX_FILES
    [ "$IS_L0T" -eq 1 ] && CAP=$L0T_MAX_FILES
    if [ "$PHASES" -gt "$L0_MAX_PHASES" ]; then
        FAILS=$((FAILS + 1))
        printf '[tier-consistency] ✗ 声明 execution_lane=%s 但形态超出轻量通道: 多 Phase（Phase 数=%s, L0 应单 Phase 执行）\n' "$LANE" "$PHASES"
    fi
    if [ "$SCOPE_FOUND" -eq 1 ] && [ "$SCOPE" -gt "$CAP" ]; then
        FAILS=$((FAILS + 1))
        printf '[tier-consistency] ✗ 声明 execution_lane=%s 但形态超出轻量通道: 多文件（scope 表文件数=%s > cap %s%s）\n' \
            "$LANE" "$SCOPE" "$CAP" "$([ "$IS_L0T" -eq 1 ] && printf '（L0-T 纯文本档）' || true)"
    fi
    if [ "$SUNIT" -gt "$L0_MAX_SUNIT" ]; then
        FAILS=$((FAILS + 1))
        printf '[tier-consistency] ✗ 声明 execution_lane=%s 但形态超出轻量通道: 重门控（S-unit 数=%s, 多单元派发超出轻量档形态）\n' "$LANE" "$SUNIT"
    fi
fi

if [ "$FAILS" -gt 0 ]; then
    printf '[tier-consistency] ✗ %d 项档位/体量不一致（plan_tier=%s execution_lane=%s; lines=%s phases=%s vc=%s sunit=%s scope=%s）— 改回 standard/L1 或按真实档位重列计划\n' \
        "$FAILS" "${TIER:-<无>}" "${LANE:-<无>}" "$LINES" "$PHASES" "$VC" "$SUNIT" "$SCOPE"
    exit 1
fi
printf '[tier-consistency] ✓ 档位声明与体量一致（plan_tier=%s execution_lane=%s; lines=%s phases=%s vc=%s sunit=%s scope=%s）\n' \
    "${TIER:-<无>}" "${LANE:-<无>}" "$LINES" "$PHASES" "$VC" "$SUNIT" "$SCOPE"
exit 0
