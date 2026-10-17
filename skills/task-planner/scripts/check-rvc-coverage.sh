#!/usr/bin/env bash
# check-rvc-coverage.sh — R→VC 双向覆盖核对（P-08 审计提案实施, 2026-10-16）
#
# 背景（P-08 缺口）: task_plan.md 的「🎯 用户需求原文」R 行与「Verification Contract」VC 行
#   之间此前无任何机器校验 —— VC 设计是否覆盖 Goal 全靠模型自觉：「R 写了但无 VC 覆盖」
#   （R 孤儿）与「VC 写了但无 R 归属」（VC 孤儿）两类缺口都静默通过。本脚本把 R↔VC 双向
#   映射变成机器可判的不变量，堵住「VC 写了但没覆盖 Goal」。
#
# What（判定逻辑 + 输入输出契约）:
#   用法: bash check-rvc-coverage.sh <plan-dir>   （读 <plan-dir>/task_plan.md）
#   抽取（四个判定面）:
#     ① R 行: 「🎯 用户需求原文」^## 段内 `- **R<n>**: ...`（段 = 该 ^## 至下一 ^##，### 子节含在内）
#     ② 映射表行: 全文档 `| R<n> | <VC 列表> | ...` 数据行（cell2 支持区间写法 VC-a~b / VC-a.b / VC-a-b）
#     ③ VC 行: 「Verification Contract」或「VC 表」^## 段内, checkbox `- [ ] VC-N ...` / 表行 `| VC-N | ... |` 两形态
#     ④ Phase V 行: 全文档 `- [x] V-x.y: ...`（原始形态）与 `- **V-N:** ...`（v074 P8 D11 紧凑形态,
#       同 check-complete.sh 并集第二模式）——VC→R 兜底映射面
#   判定（双向, 全过 exit 0）:
#     ① R→VC: 每个 R<n> 须被 ≥1 个 VC 覆盖 —— 证据 = 映射表行 cell2 含 ≥1 VC 编号（区间展开）
#        ∪ 任一 VC 行文本引用该 R 编号
#     ② VC→R: 每个 VC-N 须映射到 ≥1 个 R（或 Phase V-N）—— 证据 = 映射表行 cell 含该 VC
#        ∪ 任一 VC 行文本引用任一 R 编号 ∪ 任一 Phase V 行文本含该 VC 编号
#   输出（stdout, 统一前缀 [rvc-coverage]）:
#     缺口逐条: `✗ R<n> 无 VC 覆盖（...）` / `✗ VC-N 无 R 映射（...）` + 尾部汇总行
#     通过: `✓ R→VC 双向覆盖完整（R=nR VC=nV 映射行=nM）`；无判定面: `SKIP (...)`
#   退出码: 0=双向覆盖完整（含无判定面 SKIP）；1=存在覆盖缺口；2=输入缺失（plan-dir 非目录 / task_plan.md 缺失）
#
# Why（设计取舍, 逐条给理由）:
#   · 为什么双向: 只做 R→VC 堵「Goal 无验证」, 堵不住「VC 验证了计划外的事」（VC 孤儿）——
#     覆盖度两头都靠自觉时, 任何一头漏掉都不报错; 双向判定把「R↔VC 映射」升格为机器不变量（P-08 根因）。
#   · 判定面收窄到「编号引用」: 规格中「VC 判据文本含 R 核心词」的语义级词面匹配无机器可判标准
#     （核心词怎么定 = 引入 NLP 猜测）, 强判 = 误拦合法计划的误报面 —— 核心词层 fail-open 不在本门
#     判定面（诚实边界, 同 check-evidence-anchor 非路径证据放行口径）; 编号引用是唯一硬判定面。
#   · R 段缺失 = 全局无判定面 → SKIP exit 0（同 check-evidence-anchor 无判定面范式）; 但 R 行存在
#     而 VC 行=0 不是「无判定面」而是「判定面全空」= 最强形态覆盖缺口 → exit 1。两态必须分开,
#     否则「计划忘了写 VC 段」会静默 PASS。
#   · VC→R 兜底加 Phase V 行面: 真实计划常把 VC 映射进 Phase 验证步骤（`- [x] V-1.1: VC-1` 形态）
#     而非在 VC 文本里写 R 编号 —— 不算这个面会误拦此类合法计划。
# 依赖: bash + awk + grep（无 python / 无 jq, 纯 bash 实现, 同 check-evidence-anchor 口径）
set -u

PLAN_DIR="${1:-}"
if [ -z "$PLAN_DIR" ] || [ ! -d "$PLAN_DIR" ]; then
    printf '[rvc-coverage] ERROR: plan-dir 缺失或非目录: %s\n' "${PLAN_DIR:-<empty>}" >&2
    exit 2
fi
PLAN_FILE="$(cd "$PLAN_DIR" && pwd)/task_plan.md"
if [ ! -f "$PLAN_FILE" ]; then
    printf '[rvc-coverage] ERROR: task_plan.md 缺失: %s\n' "$PLAN_FILE" >&2
    exit 2
fi

# ── 抽取（awk 三段, 输出 TSV）────────────────────────────────────────────────
# 段切分口径: `^##[^#]` 命中即重设段; `###` 子节（如 `### R→VC 映射`）留在所属 ^## 段内
R_ROWS="$(awk '
    /^##[^#]/ { sec = ($0 ~ /用户需求原文/) ? "R" : "X" }
    sec == "R" && $0 ~ /^- *\*\*R[0-9]/ {
        line = $0
        sub(/^ *- +\*\*/, "", line)      # `- **R1**: ...` → `R1**: ...`
        r = line
        sub(/[:：].*$/, "", r); gsub(/\*/, "", r)
        if (r ~ /^R[0-9]+$/) printf "R\t%s\t%d\t%s\n", r, NR, $0
    }
' "$PLAN_FILE" 2>/dev/null)"

# 映射表数据行（全文档）: `| R<n> | <VC 列表> | ...` → MAP \t R编号 \t cell2 \t 行号 \t 原文
MAP_ROWS="$(awk '
    /^\|[[:space:]]*R[0-9]+[[:space:]]*\|/ {
        n = split($0, c, "|")
        if (n < 4) next
        r = c[2]; gsub(/[ \t*]/, "", r)
        if (r !~ /^R[0-9]+$/) next
        cell = c[3]; gsub(/[ \t]/, "", cell)
        printf "MAP\t%s\t%s\t%d\t%s\n", r, cell, NR, $0
    }
' "$PLAN_FILE" 2>/dev/null)"

# VC 段 VC 行: checkbox `- [ ] VC-N ...` / 表行 `| VC-N | ... |` → VC \t 编号 \t 行号 \t 原文
VC_ROWS="$(awk '
    /^##[^#]/ { sec = ($0 ~ /Verification Contract|VC 表/) ? "VC" : "X" }
    sec == "VC" {
        t = $0; v = ""
        if (t ~ /^- +\[[ xX]\]/) {
            sub(/^ *- +/, "", t); sub(/^\[[ xX]\][ \t]*/, "", t)
            if (t ~ /^VC-[0-9]/) { split(t, p, "-"); v = p[2]; sub(/[^0-9].*$/, "", v) }
        } else if (t ~ /^\|[[:space:]]*VC-[0-9]+[[:space:]]*\|/) {
            sub(/^\|[ \t]*/, "", t)
            if (t ~ /^VC-[0-9]/) { split(t, p, "-"); v = p[2]; sub(/[^0-9].*$/, "", v) }
        }
        if (v != "" && v + 0 > 0) printf "VC\t%s\t%d\t%s\n", v, NR, $0
    }
' "$PLAN_FILE" 2>/dev/null)"

# Phase V 行（全文档, 双形态）: `- [x] V-x.y: ...`（原始形态）与 `- **V-N:** ...`（v074 P8 D11
# 紧凑形态, check-complete.sh 并集第二模式——每 Phase 仅 1 条占位 V-N 映射多 VC）→ PH \t 行号 \t 原文
PH_ROWS="$(awk '/^- +\[[ xX]\][ \t]*V-[0-9]|^- +\*\*V-N:[ \t]*\*\*.*VC-[0-9]/ { printf "PH\t%d\t%s\n", NR, $0 }' "$PLAN_FILE" 2>/dev/null)"

# ── 工具函数 ─────────────────────────────────────────────────────────────────
# r_refers <文本> <R编号> —— 文本是否引用 R<n>（编号边界: 前置非字母数字 ∧ 后置非数字）
r_refers() {
    printf '%s' "$1" | grep -qE "(^|[^A-Za-z0-9])R$2([^0-9]|$)"
}

# vc_refers <文本> <VC编号> —— 文本是否引用 VC-n（边界: 前置非字母数字连字符 ∧ 后置非数字,
# 防 `VC-12` 误配 `VC-1`; 区间写法 `VC-1~5` 的 `VC-1` 合法命中 = 区间语义）
vc_refers() {
    printf '%s' "$1" | grep -qE "(^|[^A-Za-z0-9-])VC-$2([^0-9]|$)"
}

# vc_nums_in <文本> —— 输出文本覆盖的全部 VC 编号（区间 VC-a~b / VC-a.b / VC-a-b 展开, 跨度 ≤50）
vc_nums_in() {
    local t="$1" m n a b i
    local matches
    matches="$(printf '%s' "$t" | grep -oE 'VC-[0-9]+([~.-][0-9]+)?' 2>/dev/null || true)"
    [ -n "$matches" ] || return 1
    while IFS= read -r m; do
        [ -n "$m" ] || continue
        n="${m#VC-}"
        case "$n" in
            *[!0-9]*)
                a="${n%%[~.-]*}"; b="${n#*[~.-]}"
                if [ -n "$a" ] && [ -n "$b" ] && [ "$b" -ge "$a" ] 2>/dev/null && [ $((b - a)) -le 50 ]; then
                    i="$a"
                    while [ "$i" -le "$b" ]; do printf '%s\n' "$i"; i=$((i + 1)); done
                elif [ -n "$a" ]; then
                    printf '%s\n' "$a"
                fi
                ;;
            *) printf '%s\n' "$n" ;;
        esac
    done <<< "$matches"
    return 0
}

# ── 判定 ─────────────────────────────────────────────────────────────────────
# R_ROWS/VC_ROWS/PH_ROWS 首列 TSV tag（恒为 "R"/"VC"/"PH"）, 故取 $2 即编号本体
# （R 行原文在 $4 供后续扩展; 本判定只用编号+VC/PH 原文）
R_LIST="$(printf '%s\n' "$R_ROWS" | awk -F'\t' '$1 == "R" { print $2 }' | sort -n | uniq)"
VC_LIST="$(printf '%s\n' "$VC_ROWS" | awk -F'\t' '$1 == "VC" { print $2 }' | sort -n | uniq)"
N_R="$(awk 'NF' <<< "$R_LIST" | wc -l)"
N_V="$(awk 'NF' <<< "$VC_LIST" | wc -l)"
N_M="$(printf '%s\n' "$MAP_ROWS" | awk -F'\t' 'NF && $1 == "MAP" { c++ } END { print c + 0 }')"

# 无判定面: R 段缺失 / R 行=0 → 无 Goal 可覆盖, 双向核对不适用（SKIP 口径, 同 check-evidence-anchor）
if [ -z "$R_LIST" ]; then
    printf '[rvc-coverage] SKIP (无 R 判定面: task_plan.md 无「用户需求原文」段 R 行, 双向覆盖核对不适用)\n'
    exit 0
fi

ALL_MAP_CELLS="$(printf '%s\n' "$MAP_ROWS" | awk -F'\t' '$1 == "MAP" { print $3 }' | tr '\n' ' ')"
GAP_R=0
GAP_VC=0

# ① R→VC: 每个 R 行须被 ≥1 个 VC 覆盖
for rn in $R_LIST; do
    num="${rn#R}"
    covered=0
    cell="$(printf '%s\n' "$MAP_ROWS" | awk -F'\t' -v r="$rn" '$1 == "MAP" && $2 == r { print $3 }' | tr '\n' ' ')"
    if [ -n "$cell" ] && printf '%s' "$cell" | grep -qE 'VC-[0-9]+'; then
        covered=1
    elif [ "$covered" -eq 0 ]; then
        # 兜底面: VC 判据文本（checkbox/表行）引用该 R 编号
        while IFS=$'\t' read -r tag vv ln txt; do
            [ "$tag" = "VC" ] || continue
            if r_refers "$txt" "$num"; then covered=1; break; fi
        done <<< "$VC_ROWS"
    fi
    if [ "$covered" -eq 0 ]; then
        GAP_R=$((GAP_R + 1))
        printf '[rvc-coverage] ✗ %s 无 VC 覆盖（映射表行 cell2 无 VC 编号 且 无 VC 判据文本引用 %s）\n' "$rn" "$rn"
    fi
done

# ② VC→R: 每个 VC 须映射到 ≥1 个 R（或 Phase V-N）
for v in $VC_LIST; do
    mapped=0
    # 面 1: 映射表行 cell 含该 VC（区间展开）
    if [ -n "$ALL_MAP_CELLS" ] && vc_nums_in "$ALL_MAP_CELLS" | grep -qx -- "$v"; then
        mapped=1
    fi
    # 面 2: 任一 VC 行文本引用任一 R 编号
    if [ "$mapped" -eq 0 ]; then
        for rn in $R_LIST; do
            hit=0
            while IFS=$'\t' read -r tag vv ln txt; do
                [ "$tag" = "VC" ] || continue
                if r_refers "$txt" "$rn"; then hit=1; break; fi
            done <<< "$VC_ROWS"
            [ "$hit" -eq 1 ] && { mapped=1; break; }
        done
    fi
    # 面 3: Phase V 行（`- [x] V-x.y: ... VC-n ...`）含该 VC —— 兜底映射面
    if [ "$mapped" -eq 0 ]; then
        while IFS=$'\t' read -r tag ln txt; do
            [ "$tag" = "PH" ] || continue
            if vc_refers "$txt" "$v"; then mapped=1; break; fi
        done <<< "$PH_ROWS"
    fi
    if [ "$mapped" -eq 0 ]; then
        GAP_VC=$((GAP_VC + 1))
        printf '[rvc-coverage] ✗ VC-%s 无 R 映射（映射表行/VC 判据文本/Phase V 行均未引用该 VC）\n' "$v"
    fi
done

GAPS=$((GAP_R + GAP_VC))
if [ "$GAPS" -gt 0 ]; then
    printf '[rvc-coverage] ✗ 覆盖缺口 %d 项（R→VC 缺口 %d / VC→R 缺口 %d；R=%d VC=%d 映射行=%d）— 补映射或补 VC 后重跑\n' \
        "$GAPS" "$GAP_R" "$GAP_VC" "$N_R" "$N_V" "$N_M"
    exit 1
fi
printf '[rvc-coverage] ✓ R→VC 双向覆盖完整（R=%d VC=%d 映射行=%d）\n' "$N_R" "$N_V" "$N_M"
exit 0
