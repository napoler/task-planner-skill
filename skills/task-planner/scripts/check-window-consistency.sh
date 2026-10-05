#!/usr/bin/env bash
# check-window-consistency.sh — 通用窗口口径一致性 lint（Rule 51.1a/51.7 G2 机制化，task-v132 Phase 2 S1）
#
# 用途：从 <plan-dir>/task_plan.md「🎯 用户需求原文」区块的 R 行提取需求窗口词（锚族），
#   扫描 计划全文 + subagent-state/*.md 载荷计量窗口词，跨族口径不一致即警报。
#   需求锚 R2 原文（task_plan.md 🎯 R2，逐字）：「通用窗口口径一致性 lint（从🎯锚定行
#   提取需求窗口词→扫描计划与载荷计量窗口词，口径不一致即警报，不绑死 72h 字面；
#   负例须含『一个月→7 天』样张）」——词表族化（下方 *_FAMILY 词表变量）即「不绑死
#   字面」：新增窗口词（如「双周/14天」）= 追加一族或扩族，判定逻辑零改动。
#   判定口径（三档，对齐 task_plan.md FMEA F2 兜底「warn 级起步，exit 1 仅样张级
#   明确不一致」）：
#   - 锚族 = 🎯 区块 R 行（`- **R<n>**: …` / `- R<n>: …` / `**R<n>** …` 形态）命中的词族
#   - 跨族冲突 = 被扫行出现 非锚族 窗口词 且 行无豁免语境 → [window-lint] ⚠ 行 + exit 1
#     （负例样张：锚=「一个月」月族，载荷=「7 天」周族，无豁免 → 警报）
#   - 同族异值 = 被扫行出现 锚族内 非锚词 变体（锚=「30天」而文本含「一个月」）
#     → 只打印 [window-lint] · 纠正候选（配合 Rule 51.7「纠正=回锚重译，非设计增量」：
#     提示追加新 R 行，不改写旧 R 行）；不计入 exit 1（30天/一个月=粒度转写差，非口径矛盾）
#   - 豁免 = 行含「判例/事故/incident-reports」语境词（引用事故报告/判例原文，
#     转述历史数字非计量口径）→ 该行的跨族词不计数
#
# 输入：
#   - 位置参 1 = <plan-dir>（计划目录，内含 task_plan.md；subagent-state/ 不存在=无载荷）
#   - 读取文件：<plan-dir>/task_plan.md、<plan-dir>/subagent-state/*.md
#
# 输出（stdout 行，统一前缀 [window-lint]）：
#   ⚠ 行 = 跨族冲突（文件:行号 + 词 + 锚词清单），≥1 条 → exit 1
#   · 行 = 纠正候选 / 未识别已知族 提示（advisory，不影响 exit）
#   fail-open 行 = 跳过说明（缺参/无计划/无锚 时静默放行留痕）
# 退出码：
#   0 = 无跨族冲突 / fail-open（无参、task_plan.md 缺失不可读、无 🎯 区块 R 行、
#       R 行无已知窗口词——「无证据无指控」，lint 是增强检查非前置依赖）
#   1 = 存在跨族口径冲突
#
# 依赖：bash 4+（declare -A 关联数组）；外部命令 grep/find/sort/tr/basename/head
#   （coreutils/grep 标准件，与同目录 sibling 脚本 check-plan-dispatch.sh 等一致）
#
# Usage: bash check-window-consistency.sh <plan-dir>
#
# [2026-10-05 task-v132 P2-S1] 新建（G2 lint，Rule 45.3 头注释四要素 + 45.2 双层注释）

set -u

# ── 输入与 fail-open ────────────────────────────────────────────────────────
# What: 缺参 / task_plan.md 缺失不可读 → 静默放行
# Why: R2 规格第 4 条「无窗口词/无计划文件 → exit 0 静默（fail-open）」——
# lint 是增强检查非前置依赖，缺数据不构成口径不一致证据，防误伤无计划场景；
# 留一行可观测输出（非完全无声）供调用方登记跳过原因（check-plan-dispatch.sh
# 「fail-open: no readable task_plan.md」同范式）
PLAN_DIR="${1:-}"
PLAN_FILE="${PLAN_DIR:-}/task_plan.md"
if [ -z "$PLAN_DIR" ] || [ ! -f "$PLAN_FILE" ] || [ ! -r "$PLAN_FILE" ]; then
    echo "[window-lint] fail-open: 无可读 task_plan.md（${PLAN_FILE} 缺失/不可读），跳过窗口 lint"
    exit 0
fi

# ── 窗口词族表（词表变量化 = R2「不绑死 72h 字面」+ FMEA F2 兜底「词表族化」）──
# Why 族化判定: 判定按「族」而非字面——同族异值=纠正候选（advisory），跨族=口径冲突
# （⚠ 警报）；演进=增删族/扩族，判定代码零改动。族内词=换行分隔的纯词列表
# （每行一词，遍历用 while IFS= read——词内可含空格，如「7 天」空格写法；
# 2026-10-05 实测踩坑：空格分隔+无引号 for 展开会把「72 小时」裂成 72/小时
# 两个伪词致误报，故定死换行分隔）。UNRECOGNIZED_HINTS 同为换行分隔。
#   月族   一个月/30天/一月/月度
#   周族   一周/7天/7 天/七日（「7 天」空格写法并入族词——需求文档数字与单位
#          间常插空格，两写法语义同一，族词差集判定下互为同族纠正候选）
#   小时族 72小时/72 小时/48小时/24小时/小时级（同上空格变体）
#   季族   一季度/三个月
# 族外已知词（命中仅打「词表演进」提示，不计数不警报）：双周/半月/季度——
# 防词表滞后致新窗口词被静默漏检（F2 误报面的对偶=漏报面，显式提示而非静默）
# 每词一行（词内可含空格；遍历统一用 while IFS= read，见族表头注释）
MONTH_FAMILY='一个月
30天
一月
月度'
WEEK_FAMILY='一周
7天
7 天
七日'
HOUR_FAMILY='72小时
72 小时
48小时
24小时
小时级'
QUARTER_FAMILY='一季度
三个月'
UNRECOGNIZED_HINTS='双周
半月
季度'
# 族词遍历器：遍历指定族的每词（while-read 逐行，行内空格词完整保留）
# 用法：fam_words "月族名" | while ...（调用方管道内消费）
fam_words() {
    case "$1" in
        MONTH_FAMILY)     printf '%s\n' "$MONTH_FAMILY" ;;
        WEEK_FAMILY)      printf '%s\n' "$WEEK_FAMILY" ;;
        HOUR_FAMILY)      printf '%s\n' "$HOUR_FAMILY" ;;
        QUARTER_FAMILY)   printf '%s\n' "$QUARTER_FAMILY" ;;
        UNRECOGNIZED_HINTS) printf '%s\n' "$UNRECOGNIZED_HINTS" ;;
    esac
}
# 族名遍历器：固定顺序（判定顺序稳定=警报输出顺序稳定，selftest 断言友好）
fam_names() {
    printf '%s\n' MONTH_FAMILY WEEK_FAMILY HOUR_FAMILY QUARTER_FAMILY
}

# 豁免语境词（R2 规格：事故报告/判例引用不计数）——行级命中即整行豁免跨族计数
EXEMPT_W1="判例"; EXEMPT_W2="事故"; EXEMPT_W3="incident-reports"

# ── 词匹配工具（纯 bash 字符串包含，CJK 字面词精确匹配最稳，免 grep 转义）────
contains() { [[ "$1" == *"$2"* ]]; }

# [2026-10-05 task-v132/Phase4 CR-P2 修复] 带词边界的窗口词匹配（替代裸 contains 的判定路径）:
#   ① 命中前一字符为数字 → 不判命中（词是更长数字串的子串, 如「124小时」中的「24小时」、
#      「第7天」中的「7天」——里程碑「第N天」语境整体豁免）
#   ② 命中后一字符为同族计量单位延续（天/小时/日）→ 不判命中（更长数字串尾巴, 如
#      「124小时」按家族词判定）
#   实现: grep -qE 行级匹配 + sed 转义（族词含「7 天」空格/「小时级」等无特殊字符, 仍走转义
#   口径免硬编码词表变更时踩坑）; grep 失败→该词判未命中（fail-safe 方向=不警报, 与
#   无证据无指控口径一致）。需求锚负例样张「一个月→7 天」中「7 天」独立出现（前字符非数字、
#   非「第N天」形态）→ 仍命中警报（样张钉住, 验证 c 实测 rc=1）。
window_word_hit() {  # $1=行  $2=词; 命中且边界合规 exit 0, 否则 exit 1
    local pat
    pat="$(printf '%s' "$2" | sed -e 's/[].[\\^$*]/\\&/g')"
    # 前字符排除数字/「第」（「第」=「第N天」里程碑形态标记, 连同数字前缀整体豁免,
    # 覆盖任务书「第N天 形态整体豁免（里程碑语境）」口径）;
    # 后字符排除同族计量单位延续（「124小时」中的「24小时」尾巴不拆词）
    grep -qE "(^|[^0-9第])${pat}([^天小时日]|$)" <<< "$1"
}

# ── 提取：🎯 区块 R 行（需求锚）─────────────────────────────────────────────
# What: 从含「🎯」的标题行起，收集至下一个 markdown 标题（`#` 开头行）前，
# 形如 `^[[:space:]]*[-*]?[[:space:]]*\**R[0-9]+` 的 R 行（需求行）。
# Why: R2 规格=「从🎯锚定行提取需求窗口词」；限区块=防正文他处 R 字样污染锚集
# （R-COVERAGE/表行 `| R1 |` 首字符 `|` 天然排除）；R[0-9]+ 数字锚定排除
# `R-COVERAGE`（R 后跟 `-` 不匹配）。
anchor_text=""
in_block=0
while IFS= read -r line; do
    # 区块边界判定（标题行粒度）：含 🎯 的 markdown 标题开区块，其他标题关区块；
    # 非标题行（如 R2 正文内含「🎯」字样的需求行）不改区块状态——防正文 🎯 字样误开关
    case "$line" in
        "#"*🎯*) in_block=1 ;;
        "#"*)     in_block=0 ;;   # 其他 markdown 标题（##/###）关闭区块；# 须引号防 glob 解析
    esac
    if [ "$in_block" -eq 1 ] && \
       printf '%s' "$line" | grep -qE '^[[:space:]]*[-*]?[[:space:]]*\**R[0-9]+'; then
        anchor_text="${anchor_text}
${line}"
    fi
done < "$PLAN_FILE"

# 无 R 行 → fail-open（无锚可提=无判定依据；🎯 区块缺失/标题行后无 R 行同此）
if [ -z "$(printf '%s' "$anchor_text" | tr -d '[:space:]')" ]; then
    echo "[window-lint] fail-open: 🎯 区块未提取到 R 行（无需求窗口锚），跳过窗口 lint"
    exit 0
fi

# ── 锚族/锚词计算 ──────────────────────────────────────────────────────────
# What: 逐族逐词检查锚文本命中 → anchor_fam_hit（族命中标记，按词记）/
# anchor_word_hit（锚词清单）；ANCHOR_WORDS=锚词按族序拼接（警报行证据用）。
# Why 锚词清单单独存: 同族异值判定=锚族内「非锚词」变体，需差集（族内词 - 锚词）。
declare -A anchor_word_hit=()
anchor_family_count=0
ANCHOR_WORDS=""
for fam in $(fam_names); do
    while IFS= read -r w; do
        [ -n "$w" ] || continue
        if contains "$anchor_text" "$w"; then
            anchor_word_hit["$w"]=1
            anchor_family_count=$((anchor_family_count + 1))
            ANCHOR_WORDS="${ANCHOR_WORDS}${w} "
        fi
    done <<EOF_W
$(fam_words "$fam")
EOF_W
done

# 锚 R 行无已知窗口词 → 需求未涉窗口口径，lint 无物可检
# Why fail-open 而非报错: R2 规格「无窗口词 → exit 0 静默」；未知族词（双周/半月/季度）
# 的演进提示在下方扫描阶段统一打印（有扫描数据才提示，避免空转噪音）
if [ "$anchor_family_count" -eq 0 ]; then
    echo "[window-lint] 锚 R 行未含已知窗口词，跳过（需求未涉窗口口径）"
    exit 0
fi

# ── 扫描面组集：计划全文 + subagent-state/*.md 载荷 ───────────────────────
# Why 计划全文也扫（R2「扫描计划与载荷计量窗口词」）: 计划正文自相矛盾
# （R 行=一个月、Phase 描述=7 天）与载荷矛盾同构，一并纳入
files=("$PLAN_FILE")
if [ -d "$PLAN_DIR/subagent-state" ]; then
    while IFS= read -r f; do
        files+=("$f")
    done < <(find "$PLAN_DIR/subagent-state" -maxdepth 1 -name '*.md' -type f 2>/dev/null | sort)
fi

# 全局词出现表（纠正候选/未识别提示的「出现性」判定用，行号定位另行 grep）
declare -A term_plan=()     # 词 → 1：task_plan.md 内出现
declare -A term_payload=()   # 词 → 1：载荷内出现
declare -A hinted=()        # 族外已知词 → 1
for f in "${files[@]}"; do
    [ -r "$f" ] || continue
    while IFS= read -r line; do
        for fam in $(fam_names); do
            while IFS= read -r w; do
                [ -n "$w" ] || continue
                # [2026-10-05 task-v132/Phase4 CR-P2] 边界感知匹配: 数字前缀/单位尾巴不计入
                # 出现表（与判定①同口径, 防「第7天/124小时」伪计数）
                if window_word_hit "$line" "$w"; then
                    term_plan["$w"]=1
                    [ "$f" != "$PLAN_FILE" ] && term_payload["$w"]=1
                fi
            done <<EOF_W
$(fam_words "$fam")
EOF_W
        done
        while IFS= read -r uw; do
            [ -n "$uw" ] || continue
            contains "$line" "$uw" && hinted["$uw"]=1
        done <<EOF_U
$(fam_words UNRECOGNIZED_HINTS)
EOF_U
    done < "$f"
done

# ── 判定 ①：跨族冲突（⚠ 警报，exit 1 因子）──────────────────────────────
# What: 逐行扫 计划全文+载荷，行出现 非锚族 窗口词 且行无豁免语境词 → ⚠ 行。
# 行级豁免（非文件级）: 防同文件他行豁免误传 / 同行多词只豁免含语境词的行。
ALERTS=0

# 计划全文：逐行逐词全量报（单文件，证据密度优先）
line_no=0
while IFS= read -r line; do
    line_no=$((line_no + 1))
    # 豁免语境行（判例/事故/incident-reports 引用）不计数
    if contains "$line" "$EXEMPT_W1" || contains "$line" "$EXEMPT_W2" || contains "$line" "$EXEMPT_W3"; then
        continue
    fi
    for fam in $(fam_names); do
        fam_is_anchor=0
        while IFS= read -r w; do
            [ -n "$w" ] || continue
            [ -n "${anchor_word_hit["$w"]:-}" ] && fam_is_anchor=1
        done <<EOF_W
$(fam_words "$fam")
EOF_W
        [ "$fam_is_anchor" -eq 1 ] && continue   # 锚族词=合规口径，跳过
        while IFS= read -r w; do
            [ -n "$w" ] || continue
            # [2026-10-05 task-v132/Phase4 CR-P2] 跨族警报判定改边界感知匹配:
            # 裸 contains 下「第7天」(周族「7天」子串)/「124小时」(小时族「24小时」子串)
            # 被误升为阻断级 exit 1（FMEA F2 声明「exit 1 仅样张级明确不一致」, 越级误报）;
            # window_word_hit 前数字排除=「第N天」里程碑语境整体豁免, 后单位延续排除=长数字串
            # 不拆词。独立「7 天」样张（锚=一个月 月族, 载荷=周族）仍命中→警报保持。
            if window_word_hit "$line" "$w"; then
                echo "[window-lint] ⚠ task_plan.md:$line_no 出现『$w』，与锚定窗口词不一致（锚词: ${ANCHOR_WORDS% }；非锚族计量词）"
                ALERTS=$((ALERTS + 1))
            fi
        done <<EOF_W
$(fam_words "$fam")
EOF_W
    done
done < "$PLAN_FILE"

# 载荷（subagent-state/*.md）：每文件至多 1 条 ⚠（首个命中行即证据，防词表多词刷屏）
idx=1
while [ "$idx" -lt "${#files[@]}" ]; do
    f="${files[$idx]}"
    idx=$((idx + 1))
    [ "$f" != "$PLAN_FILE" ] || continue
    [ -r "$f" ] || continue
    rel="subagent-state/$(basename "$f")"
    line_no=0
    hit_reported=0
    while IFS= read -r line; do
        line_no=$((line_no + 1))
        if [ "$hit_reported" -eq 1 ]; then
            continue
        fi
        if contains "$line" "$EXEMPT_W1" || contains "$line" "$EXEMPT_W2" || contains "$line" "$EXEMPT_W3"; then
            continue
        fi
        for fam in $(fam_names); do
            fam_is_anchor=0
            while IFS= read -r w; do
                [ -n "$w" ] || continue
                [ -n "${anchor_word_hit["$w"]:-}" ] && fam_is_anchor=1
            done <<EOF_W
$(fam_words "$fam")
EOF_W
            [ "$fam_is_anchor" -eq 1 ] && continue
            while IFS= read -r w; do
                [ -n "$w" ] || continue
                # [2026-10-05 task-v132/Phase4 CR-P2] 同判定①口径: 边界感知匹配（注释见计划全文扫描段）
                if window_word_hit "$line" "$w"; then
                    echo "[window-lint] ⚠ $rel:$line_no 出现『$w』，与锚定窗口词不一致（锚词: ${ANCHOR_WORDS% }；非锚族计量词）"
                    ALERTS=$((ALERTS + 1))
                    hit_reported=1
                    break
                fi
            done <<EOF_W
$(fam_words "$fam")
EOF_W
            [ "$hit_reported" -eq 1 ] && break
        done
    done < "$f"
done

# ── 判定 ②：同族异值（纠正候选，advisory；不计入 exit）──────────────────
# What: 锚族内「非锚词」变体在 计划/载荷 出现 → · 行提示按 Rule 51.7 追加新 R 行。
# Why advisory: FMEA F2「warn 级起步」；同族异值（30天 vs 一个月）多为转写/粒度差，
# 纠正动作=「回锚重译，非设计增量」（51.7）：提示追加 R 行，不改写旧 R 行。
for fam in $(fam_names); do
    fam_has_anchor=0
    while IFS= read -r w; do
        [ -n "$w" ] || continue
        [ -n "${anchor_word_hit["$w"]:-}" ] && fam_has_anchor=1
    done <<EOF_W
$(fam_words "$fam")
EOF_W
    [ "$fam_has_anchor" -eq 1 ] || continue
    while IFS= read -r w; do
        [ -n "$w" ] || continue
        [ -n "${anchor_word_hit["$w"]:-}" ] && continue   # 锚词本身不是候选
        if [ -n "${term_plan["$w"]:-}" ] || [ -n "${term_payload["$w"]:-}" ]; then
            # 定位首个出现处（files 计划在前 → 证据优先计划内；grep -nF 字面匹配）
            ev=""
            for f in "${files[@]}"; do
                [ -r "$f" ] || continue
                hit_line="$(grep -nF -- "$w" "$f" 2>/dev/null | head -1)"
                if [ -n "$hit_line" ]; then
                    ev="$(basename "$f"):${hit_line%%:*}"
                    break
                fi
            done
            echo "[window-lint] · 纠正候选：锚窗口族内异值『$w』出现（$ev）——按 Rule 51.7 追加新 R 行显式口径（不改写旧 R 行）"
        fi
    done <<EOF_W
$(fam_words "$fam")
EOF_W
done
# 族外已知词：提示在词表增族（词表演进点，防漏检静默）
while IFS= read -r uw; do
    [ -n "$uw" ] || continue
    [ -n "${hinted["$uw"]:-}" ] || continue
    echo "[window-lint] · 未识别已知族窗口词『$uw』出现——如需检测请在 check-window-consistency.sh 词表增族"
done <<EOF_U
$(fam_words UNRECOGNIZED_HINTS)
EOF_U

# ── 汇总 ──────────────────────────────────────────────────────────────────
if [ "$ALERTS" -gt 0 ]; then
    echo "[window-lint] 窗口口径不一致警报 ${ALERTS} 条（详见上 ⚠ 行；同族异值纠正候选见 · 行）"
    exit 1
fi
exit 0
