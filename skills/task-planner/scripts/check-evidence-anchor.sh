#!/usr/bin/env bash
# check-evidence-anchor.sh — 证据锚真实性检查（存在性 + 行界 + 否定 trim + provenance 三层）
# [2026-10-16 P-01 实施] 本仓痛点根因（终审意见 7）：check-complete.sh:971 的 R-COVERAGE 证据格判定
#   仅「字符串非空 ∧ ∉{无,—,N/A}」，goal-gate 三要素可叙述代偿 —— 证据格写 `/etc/hostname` 或
#   死路径 `/tmp/不存在的文件.md` 仍 exit=0。本脚本把「证据锚」从「非空文本」升级为「可定位、可归属、
#   机器可判的锚」，消费侧 = check-complete.sh R-COVERAGE 段与 goal-gate 段前置 shell-out（伴生 a）。
#
# What（三层判定 + 输入输出契约）：
#   输入源（两条，--source 可选）：
#     ① coverage — <plan-dir>/delivery-summary.md「需求覆盖核对」表数据行的**证据区**（状态列之后的单元格）
#     ② goal     — <plan-dir>/progress.md 含 `[goal:G<n>]` 的证据行（整行视为证据文本）
#   抽取：从证据文本切词 → 只保留「无歧义路径锚」token（绝对路径 ≥2 实段；相对路径 ≥2 段且末段带
#     白名单扩展名）；可选 `:N` / `:N-M` 行号后缀。切词/过滤细则见下方 PATH_TOKEN_RULES 注释块。
#   判定（全过 exit 0，任一不中 exit 1）：
#     ① 否定 trim —— 证据区先 trim 首尾空白再判否定字面（无 / — / N/A / none / 待补），
#        修「无 」尾随空格击穿（探测·产出质量 实测：`ev != "无"` 因尾随空格恒真 → 空证据放行）；
#        covered/partial 行的证据区 trim 后命中否定字面 = 无证据锚 → FAIL（uncovered 行不要求证据，跳过）。
#     ② 存在性 + 行界 —— token 必须在解析链中命中真实文件/目录；带 `:N` 时 N ≤ 该文件行数（wc -l）。
#     ③ provenance —— 证据须归属本任务产出物（三层）：
#        a) 系统路径前缀（/etc /usr /bin /sbin /lib /lib64 /boot /proc /sys /dev /var /opt /root
#           /srv /run）命中 → FAIL（系统文件不构成任务证据，关掉 /etc/hostname 张冠李戴）；
#        b) 解析结果在 plan-dir 外且不在「执行范围限制」表内 → FAIL；豁免 = /tmp（任务 scratch 面）
#           与 plans/.rule-reservations.jsonl（Rule 20.6 跨任务共享账本）；计划无「执行范围限制」段
#           → 本层跳过（fail-open，同 check-complete.sh porcelain 预检「缺表头即跳过」范式）；
#        c) 解析结果落在 <plan-dir>/evidence/ 下（run-verification.sh 机器落盘产出，见伴生 c）→
#           文件头（前 3 行）须含 VC 编号（VC-N）与 ISO8601 时间戳，缺 = FAIL（机器产出不可伪造面）。
#
# Why（设计取舍，逐条给理由）：
#   · 为什么先 trim 再判否定：原判定 `ev != "无"` 是字面比较，尾随空格使「无 」≠「无」→ 空证据假过；
#     本脚本统一 trim 后比较，把「空证据」与「有证据」判然分开。
#   · 为什么只抽「无歧义路径锚」而非全量切词：存量证据文本混有大量斜杠散文（A/B/C、72.1/72.2、VC-2/3），
#     全量切词会把散文误判为路径 → 误拦合法交付（误报面 = 终审意见 7 反面的等价伤害）。判定面收窄到
#     「段数 + 扩展名白名单」后，146 存量计划基线实测误报从 63/90 降到 1/56（唯一残项为真阳性，
#     见文末「诚实边界」）。非路径形态的证据（如 v131 R7「同 R3」式引用）不在本门判定面。
#   · 为什么解析链有 6 层：仓内证据路径的书写形态实测有 6 种（绝对 / 相对 plan-dir / 相对仓根 /
#     相对技能根 / 相对 skills/ / 相对某个兄弟技能目录），任一形态都指向真实文件；只认前两层会把
#     「写法不同」误判成「死路径」。
#   · 为什么有「归档搬迁」兜底：计划归档后 plans/<id>/ 迁到 plans/archive/<id>/，历史证据行里的旧路径
#     字符串未变但文件已搬家 —— 不兜底会把「搬家」误判成「死引用」（146 基线实测该误报占 8 项）。
#   · 为什么 provenance 层 b 有豁免：/tmp 是任务自身 scratch（测试夹具/基线日志落盘面），
#     plans/.rule-reservations.jsonl 是 Rule 20.6 跨任务账本（任何落规则的任务都写它，不可能逐任务入
#     scope 表）——二者都属「本任务产出面」，拦它们纯属误伤；系统前缀与仓内无关文件才是「张冠李戴」
#     的真实风险面。
#
# 用法: bash check-evidence-anchor.sh <plan-dir> [--source=coverage|goal|all]
# 输出（**stdout**，供 caller 中继；caller 不得裹 2>/dev/null —— 见伴生 a）:
#   命中: `[evidence-anchor] ✗ <file>:<行号> <token> — <reason> ｜ 原文: <摘录>`
#   跳过: `[evidence-anchor] SKIP (...)`
#   通过: `[evidence-anchor] ✓ <n> 证据锚通过（coverage=<a> goal=<b>）`
# 退出码: 0=全过（或无判定面）；1=任一 token 不中；2=输入异常（plan-dir 缺失/未知参数）
# 依赖: bash + awk + grep/sed + wc（无 jq / 无 python，纯 bash 实现，同 check-delegation.sh 口径）
# 档位: 本脚本自身不读档位（纯判定器）；enforce|warn|off 由 caller（check-complete.sh）按
#       config.json#evidence_anchor_enforce / env TASK_PLANNER_EVIDENCE_ANCHOR_ENFORCE 裁决。
#
# 【诚实边界】（终审意见 7 的收敛面与未收敛面，如实披露）：
#   · 已收敛：路径**归属层**（存在 / 行界 / 系统前缀 / 域外 / 机器落盘头）——把「发现不了」变成「无法伪造」。
#   · 未收敛：**内容级**张冠李戴（文件真实存在但与需求无关）不在本门判定面；该面靠伴生 c 的
#     run-verification.sh 落盘（<plan-dir>/evidence/VC-N.out）+ P-02 产出物引用锚收敛。
#   · 未收敛：非路径形态证据（「同 R3」式引用 / 纯叙述）抽不出 token → 本门放行（fail-open，
#     与 R-COVERAGE 既有「放宽为实质证据引用」口径一致，见 check-complete.sh rcov_cov_awk 注释）。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$SKILL_ROOT/../.." && pwd)"

# ── 常量：词表（误报调优面，改动前先跑 146 存量基线，见 P-01 verify ②）─────────────
# 系统路径前缀：OS 自有目录，任何任务都不该拿它们当产出证据（provenance 层 a）
SYS_PREFIX_RE='^/(etc|usr|bin|sbin|lib|lib64|boot|proc|sys|dev|var|opt|root|srv|run)(/|$)'
# 扩展名白名单：只有白名单内扩展名才认作「文件路径末段」。用白名单而非通配 `\.[A-Za-z0-9]+`
# 的原因：`.claude` / `.zcode` 这类点开头目录名会被通配式误认成「带扩展名的文件」（实测误报）。
EXT_WHITELIST='md|sh|bash|ts|tsx|js|cjs|mjs|json|jsonl|log|txt|out|err|py|ps1|tsv|csv|yml|yaml|toml|ini|conf|cfg|html|css|png|jpg|jpeg|gif|svg|pdf|zip|gz|tar|patch|diff|sum|dat|xml'
# 否定字面集（trim 后比较）：空证据的显式写法
NEG_RE='^(无|—|–|-|N/A|n/a|NA|none|None|待补|待填)$'
# 机器落盘证据（run-verification.sh 产出）头部要求：VC 编号 + ISO8601 时间戳
EVID_VC_RE='VC-[0-9]+'
EVID_TS_RE='[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z'

PLAN_DIR="${1:-}"
SOURCE="all"
if [ -n "${2:-}" ]; then
    case "$2" in
        --source=coverage|--source=goal|--source=all) SOURCE="${2#--source=}" ;;
        -h|--help)
            printf 'Usage: %s <plan-dir> [--source=coverage|goal|all]\n' "$0"
            exit 0
            ;;
        *)
            printf '[evidence-anchor] ERROR: 未知参数 %s（支持 --source=coverage|goal|all）\n' "$2" >&2
            exit 2
            ;;
    esac
fi

if [ -z "$PLAN_DIR" ] || [ ! -d "$PLAN_DIR" ]; then
    printf '[evidence-anchor] ERROR: plan-dir 缺失或非目录: %s\n' "${PLAN_DIR:-<empty>}" >&2
    exit 2
fi
PLAN_DIR="$(cd "$PLAN_DIR" && pwd)"
PLAN_FILE="$PLAN_DIR/task_plan.md"

# ── 词表/解析辅助 ───────────────────────────────────────────────────────────────

# PATH_TOKEN_RULES（抽取规则，供维护者对照；实现在下方 awk 程序内）
#   切词: 先把全角/半角标点（（）()、，,；; " ' ` [] |）替换为空白 → 按空白切 → 逐词首尾剥非路径字符
#         （保留字符集 [A-Za-z0-9_/.@-]，剥掉 CJK/标点尾巴 —— `/tmp/不存在的文件.md（67 行）` 剥成
#         `/tmp/不存在的文件.md`）
#   拒收: 含 {} * ? < > $ # = & % ^ ! + ~ ` → 拒（花括号展开/占位符/散文粘接）
#         含 `...` → 拒（省略号缩写，如 `.../skills/...`）
#         含 `://` → 拒（URL）
#         剥掉行号后缀后仍含 `:` → 拒（`image-type.md:43-86/multiview-ref-type.md` 式粘接散文）
#         任一**非末段**带白名单扩展名 → 拒（`11-code-reviewer.md/12-align-reviewer.md` 式粘接散文）
#   准入: 实段数（非空段）≥2 且（末段带白名单扩展名 ∨ 绝对路径 + 系统前缀）
#   裸名: 单段且带白名单扩展名 → 回传 BARE，由 bash 侧「仅认 plan-dir 内同名文件」判定（域外无从归属，
#         不存在=散文裸名跳过；Rule 48.2 裸名非可定位路径，硬判=误报面）
#   行号: 末段 `:N` 或 `:N-M` 后缀 → 剥出行号（区间取首个数字）

# arch_rewrite — 归档搬迁兜底: plans/<id>/x → plans/archive/<id>/x
# Why: 计划归档后目录整体搬家，历史证据行里的旧路径字符串未变 → 不兜底会把「搬家」误判成「死引用」
arch_rewrite() {
    local t="$1"
    case "$t" in
        "$REPO_ROOT"/plans/archive/*) printf '%s' "$t" ;;
        "$REPO_ROOT"/plans/*)         printf '%s' "$REPO_ROOT/plans/archive/${t#"$REPO_ROOT"/plans/}" ;;
        plans/*)                      printf '%s' "$REPO_ROOT/plans/archive/${t#plans/}" ;;
        *) return 1 ;;
    esac
}

# resolve_anchor — 6 层解析链: 绝对 → plan-dir → 仓根 → 技能根 → skills/ → 兄弟技能目录 → 归档搬迁
# 命中输出绝对路径 + return 0；全不中 return 1
resolve_anchor() {
    local tok="$1" cand
    case "$tok" in
        /*)
            [ -e "$tok" ] && { printf '%s' "$tok"; return 0; }
            cand="$(arch_rewrite "$tok" 2>/dev/null)" && [ -e "$cand" ] && { printf '%s' "$cand"; return 0; }
            return 1
            ;;
    esac
    for cand in "$PLAN_DIR/$tok" "$REPO_ROOT/$tok" "$SKILL_ROOT/$tok" "$REPO_ROOT/skills/$tok"; do
        [ -e "$cand" ] && { printf '%s' "$cand"; return 0; }
    done
    for cand in "$REPO_ROOT"/skills/*/"$tok"; do
        [ -e "$cand" ] && { printf '%s' "$cand"; return 0; }
    done
    cand="$(arch_rewrite "$tok" 2>/dev/null)" && [ -e "$cand" ] && { printf '%s' "$cand"; return 0; }
    return 1
}

# scope_text — 计划「执行范围限制」段全文（剥 markdown 修饰），空 = 计划无该段
scope_text() {
    [ -f "$PLAN_FILE" ] || return 0
    awk '/^## .*执行范围限制/{f=1;next} /^## /{f=0} f' "$PLAN_FILE" 2>/dev/null | tr -d '`*'
}

# in_scope — token 是否归属「执行范围限制」表白名单
# 三级匹配: ① token 原文子串 ② 仓根相对形式子串 ③ basename 全词命中
# Why 三级: scope 表里同一文件有绝对/相对/basename 三种写法（实测），只认原文子串会把「写法不同」
#   误判成「域外」——146 基线实测该误报占 10 项。
in_scope() {
    local tok="$1" rel base
    # 豁免: Rule 20.6 跨任务共享账本（任何落规则的任务都写它，不可能逐任务入 scope 表）
    case "$tok" in */.rule-reservations.jsonl|plans/.rule-reservations.jsonl) return 0 ;; esac
    printf '%s' "$SCOPE" | grep -qF -- "$tok" && return 0
    case "$tok" in
        "$REPO_ROOT"/*) rel="${tok#"$REPO_ROOT"/}"; printf '%s' "$SCOPE" | grep -qF -- "$rel" && return 0 ;;
    esac
    base="${tok##*/}"
    printf '%s' "$SCOPE" | grep -qE "(^|[^A-Za-z0-9_.-])${base//./\\.}([^A-Za-z0-9_.-]|$)" && return 0
    return 1
}

# ── 抽取器：awk 状态机逐源抽 token，输出 `kind \t 行号 \t payload \t lineno` ──────────
# kind=TOK 普通锚（payload=token）/ NEG 否定或空证据格（payload=`<空证据格>`）
# 证据原文另以 `TOK \t 行号 \t __EVAL__<原文> \t status` 回传，供 bash 侧做否定字面判定
extract_tokens() {
    local f="$1" mode="$2"
    awk -v mode="$mode" -v extlist="$EXT_WHITELIST" '
    # emit_tokens: 证据文本 → 逐 token 输出；line_no=源行号
    function emit_tokens(ev, line_no,   n, a, i, t, segs, nseg, k, last, nreal, glued, isabs, lnno, s) {
        # 标点 → 空白（注意：**不含** ASCII/全角冒号，`:N` 行号后缀要在后面单独剥）
        gsub(/[（）()、，,；;"'"'"'`\[\]|]+/, " ", ev)
        n = split(ev, a, /[[:space:]]+/)
        for (i = 1; i <= n; i++) {
            t = a[i]
            # 首尾剥非路径字符（保留集 [A-Za-z0-9_/.@-]）：剥掉 CJK 尾巴与标点
            while (t != "" && t !~ /[A-Za-z0-9_\/.@-]$/) t = substr(t, 1, length(t) - 1)
            while (t != "" && t !~ /^[\/A-Za-z0-9_.-]/)  t = substr(t, 2)
            if (t == "") continue
            if (t ~ /[{}*?<>$#=&%^!+~`]/) continue          # 花括号展开/占位符/散文粘接
            if (index(t, "...") > 0) continue               # 省略号缩写
            if (index(t, "://") > 0) continue               # URL
            lnno = ""
            if (match(t, /:[0-9]+(-[0-9]+)?$/)) {           # 行号后缀 :N / :N-M（区间取首数字）
                lnno = substr(t, RSTART + 1, RLENGTH - 1)
                t = substr(t, 1, RSTART - 1)
            }
            if (index(t, ":") > 0) continue                 # 剥完行号仍含 : = 粘接散文
            while (t ~ /\/$/) t = substr(t, 1, length(t) - 1)
            if (t == "") continue
            nseg = split(t, segs, "/")
            nreal = 0; last = ""
            for (k = 1; k <= nseg; k++) { if (segs[k] != "") { nreal++; last = segs[k] } }
            if (nreal < 2) {
                # 裸名（无斜杠）：只有带白名单扩展名才回传为 BARE，交由 bash 侧「仅认 plan-dir 内同名文件」判定；
                # 不存在则跳过不判（Rule 48.2 裸名非可定位路径，硬判=散文误报面）
                if (index(t, "/") == 0 && last ~ ("\\.(" extlist ")$")) {
                    if (lnno != "") lnno = lnno + 0
                    printf "BARE\t%d\t%s\t%s\n", line_no, t, lnno
                }
                continue
            }
            glued = 0
            for (k = 1; k < nseg; k++) {                    # 非末段带扩展名 = 粘接散文
                s = segs[k]
                if (s != "" && s ~ ("\\.(" extlist ")$")) glued = 1
            }
            if (glued) continue
            isabs = (t ~ /^\//)
            if (last !~ ("\\.(" extlist ")$")) {
                if (!isabs) continue
                if (t !~ /^\/(etc|usr|bin|sbin|lib|lib64|boot|proc|sys|dev|var|opt|root|srv|run)(\/|$)/) continue
            }
            if (lnno != "") lnno = lnno + 0
            printf "TOK\t%d\t%s\t%s\n", line_no, t, lnno
        }
    }
    mode == "coverage" {
        if ($0 ~ /需求覆盖核对/) { inb = 1; next }
        if (inb && $0 ~ /^##[[:space:]]/) { inb = 0 }
        if (!inb) next
        if ($0 !~ /^\|/) next
        n = split($0, c, "|")
        if (n < 3) next
        r = ""
        for (i = 1; i <= n; i++) { t = c[i]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", t); gsub(/\*/, "", t); if (t ~ /^R[0-9]+$/) { r = t; break } }
        if (r == "") next
        si = 0; st = ""; ev = ""
        for (j = 2; j <= n; j++) {
            t = c[j]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", t); gsub(/\*/, "", t)
            if (si == 0) {
                if (index(t, "uncovered") > 0) { si = j; st = "uncovered"; continue }
                if (index(t, "partial") > 0)   { si = j; st = "partial";   continue }
                if (index(t, "covered") > 0)   { si = j; st = "covered";   continue }
            } else { ev = ev " " t }
        }
        if (si == 0) next
        if (st == "uncovered") next                       # uncovered 行不要求证据锚（R-COVERAGE 同口径）
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", ev)       # ② 否定判定前 trim 首尾空白（修「无 」尾随空格击穿）
        if (ev == "") { printf "NEG\t%d\t<空证据格>\t%s\n", NR, st; next }
        printf "TOK\t%d\t%s\t%s\n", NR, "__EVAL__" ev, st  # 回传原文供 bash 侧做否定字面判定
        emit_tokens(ev, NR)
        next
    }
    mode == "goal" {
        if ($0 ~ /\[goal:G[0-9]+\]/) {
            printf "TOK\t%d\t%s\t%s\n", NR, "__EVAL__" $0, "goal"
            emit_tokens($0, NR)
        }
        next
    }
    ' "$f"
}

# ── 主判定 ──────────────────────────────────────────────────────────────────────
FAILS=0
TOK_N=0
COV_N=0
GOAL_N=0
SKIPPED=""
SCOPE="$(scope_text)"

# judge_token <file> <行号> <token> <lineno> <摘录>
# 三层判定，命中即打印 ✗ 行 + FAILS++
judge_token() {
    local file="$1" ln="$2" tok="$3" lineno="$4" excerpt="$5"
    local reason="" res="" nlines=""
    # ③a 系统路径前缀（先判，与存在性无关：/etc/hostname 即使存在也不构成任务证据）
    if printf '%s' "$tok" | grep -qE "$SYS_PREFIX_RE"; then
        reason="系统路径不构成任务证据(provenance:system-prefix)"
    fi
    res="$(resolve_anchor "$tok" 2>/dev/null)" || res=""
    if [ -z "$reason" ]; then
        if [ -z "$res" ]; then
            reason="路径不存在(解析链 6 层全不中)"
        else
            # ③b 域外: plan-dir 外 ∧ 非 /tmp scratch ∧ 不在「执行范围限制」表 → 证据不归属本任务产出物
            case "$res" in
                "$PLAN_DIR"/*) ;;
                /tmp/*) ;;
                *)
                    if [ -n "$SCOPE" ] && ! in_scope "$tok"; then
                        reason="域外路径(plan-dir 外且不在「执行范围限制」表内)"
                    fi
                    ;;
            esac
        fi
    fi
    # ② 行界: 带 :N 时 N ≤ 文件行数
    if [ -z "$reason" ] && [ -n "$lineno" ] && [ "${lineno:-0}" -gt 0 ] 2>/dev/null; then
        nlines="$(wc -l < "$res" 2>/dev/null || echo 0)"
        case "$nlines" in ''|*[!0-9]*) nlines=0 ;; esac
        if [ "$lineno" -gt "$nlines" ]; then
            reason="行号越界(:${lineno} > 文件行数 ${nlines})"
        fi
    fi
    # ③c 机器落盘证据: plan-dir/evidence/ 下引用须有 VC 编号 + 时间戳头
    if [ -z "$reason" ] && [ -n "$res" ]; then
        case "$res" in
            "$PLAN_DIR"/evidence/*)
                if ! head -n 3 "$res" 2>/dev/null | grep -qE "$EVID_VC_RE"; then
                    reason="机器落盘证据缺 VC 编号头(run-verification.sh 产出契约)"
                elif ! head -n 3 "$res" 2>/dev/null | grep -qE "$EVID_TS_RE"; then
                    reason="机器落盘证据缺 ISO8601 时间戳头(run-verification.sh 产出契约)"
                fi
                ;;
        esac
    fi
    if [ -n "$reason" ]; then
        FAILS=$((FAILS + 1))
        printf '[evidence-anchor] ✗ %s:%s %s — %s ｜ 原文: %s\n' "$file" "$ln" "$tok" "$reason" "$excerpt"
    fi
}

# run_source <mode> <file> — 逐源扫描并判定
run_source() {
    local mode="$1" file="$2" rows kind ln payload lineno excerpt ev
    if [ ! -f "$file" ]; then
        SKIPPED="${SKIPPED} ${mode}(缺 ${file##*/})"
        return 0
    fi
    rows="$(extract_tokens "$file" "$mode" 2>/dev/null || true)"
    if [ -z "$rows" ]; then
        SKIPPED="${SKIPPED} ${mode}(无判定面)"
        return 0
    fi
    while IFS=$'\t' read -r kind ln payload lineno; do
        [ -n "$kind" ] || continue
        case "$payload" in
            __EVAL__*)
                # 证据原文回传：否定字面判定（trim 已在 awk 侧完成）
                ev="${payload#__EVAL__}"
                if [ "$mode" = "coverage" ]; then
                    if printf '%s' "$ev" | grep -qE "$NEG_RE"; then
                        FAILS=$((FAILS + 1))
                        printf '[evidence-anchor] ✗ %s:%s <否定字面证据> — covered/partial 行证据区 trim 后为否定字面(%s)=无证据锚 ｜ 原文: %s\n' \
                            "$file" "$ln" "$ev" "$(printf '%s' "$ev" | cut -c1-120)"
                    fi
                    COV_N=$((COV_N + 1))
                else
                    GOAL_N=$((GOAL_N + 1))
                fi
                continue
                ;;
            '<空证据格>')
                FAILS=$((FAILS + 1))
                printf '[evidence-anchor] ✗ %s:%s <空证据格> — covered/partial 行证据区为空(trim 后无内容)=无证据锚 ｜ 原文: (空)\n' \
                    "$file" "$ln"
                COV_N=$((COV_N + 1))
                continue
                ;;
        esac
        [ "$kind" = "TOK" ] || [ "$kind" = "BARE" ] || continue
        if [ "$kind" = "BARE" ]; then
            # 裸名只认 plan-dir 内同名文件（域外无从归属；不存在=散文裸名，跳过不判——fail-open 面已在头注披露）
            [ -e "$PLAN_DIR/$payload" ] || continue
        fi
        TOK_N=$((TOK_N + 1))
        excerpt="$(sed -n "${ln}p" "$file" 2>/dev/null | tr -d '\t' | cut -c1-120)"
        judge_token "$file" "$ln" "$payload" "$lineno" "$excerpt"
    done <<< "$rows"
}

case "$SOURCE" in
    coverage|all) run_source coverage "$PLAN_DIR/delivery-summary.md" ;;
esac
case "$SOURCE" in
    goal|all) run_source goal "$PLAN_DIR/progress.md" ;;
esac

[ -n "$SKIPPED" ] && printf '[evidence-anchor] SKIP (%s )\n' "${SKIPPED# }"

if [ "$FAILS" -gt 0 ]; then
    printf '[evidence-anchor] ✗ %d 项证据锚不中（token 判定 %d 条; coverage 行 %d / goal 行 %d）— 修证据锚或补实跑落盘后重跑\n' \
        "$FAILS" "$TOK_N" "$COV_N" "$GOAL_N"
    exit 1
fi
printf '[evidence-anchor] ✓ 证据锚全过（token %d 条; coverage 行 %d / goal 行 %d）\n' "$TOK_N" "$COV_N" "$GOAL_N"
exit 0
