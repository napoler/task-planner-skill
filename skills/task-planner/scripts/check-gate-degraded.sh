#!/usr/bin/env bash
# check-gate-degraded.sh — 门降级可见化检查（P-07: fail-open 降级放行留痕，[gate-degraded] 标记判定器）
# [2026-10-16 P-07 实施] 痛点根因：check-* 门族在 fail-open 降级时（jq 缺失 / 门脚本缺失 / stats 无输出）
#   静默 exit 0，与「检查通过」不可区分——门控故障与门通过同貌。本门判定「已落盘」的门控痕迹，
#   把每个「门没真正跑/没实质判定」落成可追踪的 [gate-degraded] 逐条留痕（P-07 要求=可见化，
#   独立判定器，不替代各门自身 enforce 档位的阻断判定）。
#
# What（判定模型 + 输入输出契约）:
#   输入: <plan-dir>（含 progress.md / verification.md / evidence/ 任一面即有判定面；全无非目录即 exit 2）
#   判定面（三）:
#     ① 门痕迹行（progress.md / verification.md 全文扫描）: 行内出现已知门标记前缀（GATE_PREFIXES 表:
#        [plan] 门链伞 / [rcov-gate] / [evidence-anchor] / [state-consistency] / [lane-L0] / [report-lint] /
#        [CR-GATE] / [fmea-gate] / [DRIFT-GATE] / [session-log-gate] / [compliance] / [goal-gate] /
#        [judge-gate] / [ARCHIVE-GATE]）。逐门前缀「判定优先」判定:
#           · 痕迹行含实质判定词族 (VERDICT_RE: PASS/FAILED/COMPLETE/WARN/OK/✓/✗/SKIP-BY-HASH) → 门实际判过，不报
#           · 无判定 ∩ 有降级标记 (SKIP_RE: SKIPPED/fail-open/降级/缺失/缺 jq/脚本缺失/无输出/异常/故障/未跑/missing)
#             → degraded；原因再分二类: 故障族（FAULT_RE 命中 = fail-open 降级放行）vs 豁免族（合法 skip 未跑）
#           · 无判定且无降级标记（仅信息行）→ degraded（判定未落盘 = 无法证明门真跑过）
#     ② verification.md「全量终验」区块: 区块在但无 Total: 判定行 → degraded（门链未跑完/判定未落盘，
#        LANE-L0 GATE ① 同口径，check-complete.sh task-v167 先例）
#     ③ evidence/*.out 机器落盘痕迹: 前 3 行须含 VC 编号 + ISO8601 时间戳（run-verification.sh 落盘契约，
#        check-evidence-anchor ③c 先例）；缺头 = 判定不可辨识 → degraded
#   输出（**stdout**，供 caller 中继；caller 不得裹 2>/dev/null — P-01 接线先例「诊断不得静默」）:
#     逐条: [gate-degraded] ✗ <门名> 降级/未跑: <原因（含故障/豁免族 + 痕迹摘录 file:line）>
#     汇总: [gate-degraded] ✗ N 项降级: ... / [gate-degraded] ✓ 门链无降级 (...)
#   退出码: 0=无降级（含「无门控痕迹=无降级面」放行）；1=存在降级门；2=输入缺失（plan-dir 缺失/非目录/未知参数）
#
# Why（设计取舍，逐条给理由）:
#   · 为什么「降级标记且无实质判定」=degraded：fail-open 降级放行（jq 缺失/门脚本缺失/stats 无输出）以 0 退出，
#     与「检查通过」同貌——这是 P-07 根因「门控故障与检查通过不可区分」；本门把每个「门没真正跑」落成
#     显式 [gate-degraded] 行，使终验读者一眼可查门链是否真实覆盖。
#   · 为什么判定优先（门痕迹同现判定词与 skip 行时，skip 行不报）：真跑门的痕迹常带判定+SKIP 信息行
#     （如 [evidence-anchor] SKIP (coverage(缺文件)) 与 ✓ 同出——check-evidence-anchor.sh 既有输出形态），
#     只判 skip 行会把正常跑过的门误报降级（误报面）；有判定词 = 门实际跑过，skip 是该次运行的信息细节。
#   · 为什么 SKIP-BY-HASH 视同实质判定：它引用 attest 锁定结果（四元内容键一致 = 哈希级保证，见
#     check-complete.sh task-v091 C-2 段）——「本轮不跑」但判定本体真实，非降级。
#   · 为什么 FAILED/✗ 也算实质判定（不报降级）：判定失败 = 门跑了且判了（门控在工作，结果是不过），
#     与「门没跑/降级放行」是两件事；阻断是各门 enforce 档位职责，本门只做可见化。
#   · 为什么降级原因分故障族/豁免族二类：二者都属「门没真正跑」（P-07 可见化要求均成立，同 exit 1），
#     但根因不同——故障族 = 门控/环境故障（jq 缺失、脚本缺失、无输出、异常）；豁免族 = 设计内合法跳过
#     （非适用/豁免/存量/非 git/未声明）。措辞区分让读者分清「故障」与「豁免」，避免降级报告一律当事故看。
#   · 为什么判定面限 progress/verification/evidence：check-complete 门输出走 stderr，落进 plan-dir 痕迹面
#     的前提是已留痕；无痕迹 = 门链输出未落盘（或未跑）→ 本门不判（无降级面 exit 0）——P-07 只把
#     「已留痕的」可见化，不承担强制落痕职责（那是 Rule 57 执行诚实族条款的领域，YAGNI 不越界）。
#   · 【诚实边界】(a) 发生在*未落盘*运行区间的门控故障本门不可见（判定面=留痕面，如实披露）；
#     (b) 判定词匹配为词族制：散文恰含判定词会被判「门判过」（方向=少报降级不误报，exit 码零误伤——
#     P-07 可见化门不做阻断判定，宁可少报不可误拦，与 R-COVERAGE「实质证据引用」放宽口径同源）。
#
# 用法: bash check-gate-degraded.sh <plan-dir>
# 依赖: bash + grep/head/cut（无 python、无 jq，纯 shell 实现，同 check-evidence-anchor.sh 口径）
set -u

PLAN_DIR="${1:-}"
if [ -n "${2:-}" ]; then
    printf '[gate-degraded] ERROR: 未知参数 %s（用法: bash check-gate-degraded.sh <plan-dir>）\n' "$2" >&2
    exit 2
fi
if [ -z "$PLAN_DIR" ] || [ ! -d "$PLAN_DIR" ]; then
    printf '[gate-degraded] ERROR: plan-dir 缺失或非目录: %s\n' "${PLAN_DIR:-<empty>}" >&2
    exit 2
fi
PLAN_DIR="$(cd "$PLAN_DIR" && pwd)"

PROGRESS="$PLAN_DIR/progress.md"
VERIF="$PLAN_DIR/verification.md"
EVID_DIR="$PLAN_DIR/evidence"

# ── 词表（门标记前缀表 / 判定词族 / 降级标记词族；误报调优面，改动前须跑 selftest-gate-degraded GD 组）──
# 门标记前缀表：本仓 check-* 门族门链输出前缀实态（check-complete.sh 全链 + P-01/P-04 接线 shell-out）；
# 新门接入时追加本表。[plan-delegation] 摘要行不入表——[plan] 伞覆盖同链判定，单列会造成信息行误报
# （其唯一输出形态 phases=... verdict=... 无判定词族命中，恒报「判定未落盘」= 纯噪音面）。
GATE_PREFIXES="[plan]
[rcov-gate]
[evidence-anchor]
[state-consistency]
[lane-L0]
[report-lint]
[CR-GATE]
[fmea-gate]
[DRIFT-GATE]
[session-log-gate]
[compliance]
[goal-gate]
[judge-gate]
[ARCHIVE-GATE]"
# 实质判定词族：门跑过且判了（FAILED/✗ = 门在工作、结果是不过，非降级；WARN/WARNING = warn 档实质判定；
# SKIP-BY-HASH = 引用 attest 锁定结果视同实质，见 Why③）
VERDICT_RE='PASS|FAILED|COMPLETE|WARN|OK|✓|✗|SKIP-BY-HASH'
# 降级标记词族：fail-open / 降级 / 未跑 信号（grep -i；中文 缺失/降级/故障 按字面匹配）
SKIP_RE='SKIPPED|fail-open|降级|缺[[:space:]]*jq|jq[[:space:]]*缺失|脚本缺失|无输出|异常|故障|未[[:space:]]*跑|missing'
# 故障族子集：门控/环境故障信号（命中 = 降级原因措辞「fail-open 降级放行」；未命中 = 「豁免类跳过未跑」）
FAULT_RE='fail-open|missing|缺失|jq[[:space:]]*缺失|脚本缺失|无输出|异常|故障|未[[:space:]]*跑|降级'
# 机器落盘证据头要求（check-evidence-anchor ③c 先例同词）: VC 编号 + ISO8601 时间戳
EVID_VC_RE='VC-[0-9]+'
EVID_TS_RE='[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z'

FAILS=0
GATES_SEEN=0
EVID_N=0
VERIF_CHECKED=0

# report_degraded <门名> <原因> — 逐条留痕（P-07 [gate-degraded] 留痕契约；stdout 供 caller 中继）
report_degraded() {
    local gate="$1" reason="$2"
    FAILS=$((FAILS + 1))
    printf '[gate-degraded] ✗ %s 降级/未跑: %s\n' "$gate" "$reason"
}

# ── ① 门痕迹行判定（判定优先 + 降级标记分族）──────────────────────────────────────────
# 痕迹文件：progress.md / verification.md（门输出的常规留痕面；缺失的文件跳过，不误报）
TRACE_FILES=""
[ -f "$PROGRESS" ] && TRACE_FILES="$TRACE_FILES $PROGRESS"
[ -f "$VERIF" ] && TRACE_FILES="$TRACE_FILES $VERIF"

while IFS= read -r gate; do
    [ -n "$gate" ] || continue
    # 收集该门前缀的全部痕迹行（file:line 定位，grep -F 固定串——前缀含 [] 元字符禁用模式匹配）
    hits=""
    for f in $TRACE_FILES; do
        hh="$(grep -nF -- "$gate" "$f" 2>/dev/null || true)"
        [ -n "$hh" ] && hits="${hits}${hh}"$'\n'
    done
    hits="${hits%$'\n'}"
    [ -n "$hits" ] || continue            # 该门未观察到痕迹 → 非降级面（见 Why⑤）
    GATES_SEEN=$((GATES_SEEN + 1))
    if printf '%s\n' "$hits" | grep -qE "$VERDICT_RE"; then
        continue                          # 判定优先：门实际判过，skip/信息行是该次运行的细节（Why②）
    fi
    first="$(printf '%s\n' "$hits" | head -1 | cut -c1-100)"
    if printf '%s\n' "$hits" | grep -qiE "$SKIP_RE"; then
        fault_n="$(printf '%s\n' "$hits" | grep -ciE "$FAULT_RE" || true)"
        if [ "${fault_n:-0}" -gt 0 ]; then
            report_degraded "$gate" "fail-open 降级放行（标记词故障族：fail-open/缺失/无输出 类，门控未实际执行）｜痕迹: ${first}"
        else
            report_degraded "$gate" "跳过未跑（标记词豁免/非适用族，门按设计跳过、未实际执行）｜痕迹: ${first}"
        fi
    else
        report_degraded "$gate" "痕迹无实质判定（仅信息行、判定未落盘，无法证明门真跑过）｜痕迹: ${first}"
    fi
done <<< "$GATE_PREFIXES"

# ── ② verification.md 全量终验区块：区块在但无 Total: 判定行 → degraded ──────────────
if [ -f "$VERIF" ] && grep -q '全量终验' "$VERIF" 2>/dev/null; then
    VERIF_CHECKED=1
    if ! grep -qE 'Total:' "$VERIF" 2>/dev/null; then
        report_degraded "verification.md 全量终验" "区块在但无 Total: 判定行（selftest 门链未跑完/判定未落盘，LANE-L0 GATE ① 同口径）"
    fi
fi

# ── ③ evidence/*.out 机器落盘痕迹：缺 VC 编号/时间戳头 = 判定不可辨识 → degraded ──────
if [ -d "$EVID_DIR" ]; then
    for ef in "$EVID_DIR"/*.out; do
        [ -e "$ef" ] || continue
        EVID_N=$((EVID_N + 1))
        h3="$(head -n 3 "$ef" 2>/dev/null || true)"
        en="$(basename "$ef")"
        if ! printf '%s\n' "$h3" | grep -qE "$EVID_VC_RE"; then
            report_degraded "evidence/${en}" "机器落盘痕迹缺 VC 编号头（run-verification.sh 落盘契约，check-evidence-anchor ③c 先例 → 判定不可辨识）"
        elif ! printf '%s\n' "$h3" | grep -qE "$EVID_TS_RE"; then
            report_degraded "evidence/${en}" "机器落盘痕迹缺 ISO8601 时间戳头（run-verification.sh 落盘契约 → 判定不可辨识）"
        fi
    done
fi

# ── 汇总 ──────────────────────────────────────────────────────────────────────────────
if [ "$FAILS" -gt 0 ]; then
    printf '[gate-degraded] ✗ %d 项降级: 门链不可信为全通过 — 重跑降级门或补实质判定后复验（P-07 可见化门: 逐条留痕即交付证据，不替代原门档位阻断判定）\n' "$FAILS"
    exit 1
fi
if [ "$GATES_SEEN" -eq 0 ] && [ "$EVID_N" -eq 0 ] && [ "$VERIF_CHECKED" -eq 0 ]; then
    printf '[gate-degraded] ✓ 门链无降级（无门控痕迹面: progress/verification 无门标记 ∧ evidence/ 无机器落盘 ∧ 无全量终验区块，exit 0 放行）\n'
else
    printf '[gate-degraded] ✓ 门链无降级（观察门 %d 个均含实质判定; 机器落盘 %d 项）\n' "$GATES_SEEN" "$EVID_N"
fi
exit 0
