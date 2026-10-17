#!/usr/bin/env bash
# check-vc-nonvacuous.sh — P-02「VC 非真空命令检查」：拦截「有命令但无检查力」的真空 VC 命令
# [2026-10-16 P-02 实施] Rule 84.1 要求 <plan-dir>/verification.md 每条 VC 含可执行「Verify command」，
#   但既有门只查「非占位」不查「非真空」（P-02 终审意见）：`true` / `:` / `echo ok` / `printf ''` /
#   `cat /dev/null` 等真空命令恒 exit 0，能通过「非占位」判定却零检查力 —— VC 被核而未真判。
#   本脚本静态拦截此类真空 VC。
#
# What（输入 / 抽取 / 判定 / 退出码契约）：
#   用法: bash check-vc-nonvacuous.sh <plan-dir>
#   输入: <plan-dir>/verification.md（缺失 → exit 2）
#   抽取: 对每条 VC 条目（`- [ ] VC-N` / `- [x] VC-N` / `- [X] VC-N` 行），取其后最近一条含
#     `**Verify command**:` 的行；中间出现其他 `- [` 列表项或 `#` 标题 → 绑定复位（该 VC 无命令行，
#     跳过：缺命令面属 Rule 84.1 / attest-plan VC 可执行门判定面，不在本门内）。
#   判定（真空 ⇔ 每个 `;`/`&` 语句的最后一个管道段主体命中真空字面集）：
#     · 归一化：剥反引号（markdown 内联码）；`;`/`&` → 语句边界，`|` → 管道段边界；每段剥掉首部
#       变量赋值（NAME=...）与 `env NAME=...` 前缀后，取首个可执行词的 basename 为「主体」；
#     · 真空字面集 = {true, :, echo, printf, cat, ok, 0}：
#       - true / : / ok / 0 → 无条件真空（ok、0 非真实可执行文件，属字面占位残留，规范集成员）；
#       - echo / printf → 全链无真实判定命令时真空（管道尾是 `grep -q x file` 等真实判定命令 =
#         有退出码判定力 = 非真空，fail-open）；
#       - cat → 仅当全部参数为 /dev/null（或无参数）时真空；其他参数有检查力；
#       - 空命令（`**Verify command**:` 后无文本）= 真空（无检查力）。
#   输出（stdout，供 caller 中继；caller 不得裹 2>/dev/null）：
#     命中: `[vc-nonvacuous] ✗ <file>:<行> VC-N 真空命令: <原文>`
#     跳过: `[vc-nonvacuous] SKIP (...)`
#     通过: `[vc-nonvacuous] ✓ ...`
#   退出码: 0=无真空 VC（或无判定面）；1=存在真空 VC（逐条打印后汇总）；
#           2=plan-dir 缺失 / 非目录 / 无 verification.md / 未知参数
#   依赖: bash + awk + tr/sed（无 python；jq 未消费、缺失时天然 fail-open；档位裁决与阻断由
#     caller 负责，本脚本是纯判定器，同 check-evidence-anchor.sh 口径）
#
# Why（设计取舍，逐条给理由）：
#   · 为什么拦真空：84.1 守「有命令」，真空命令正是「有命令但无检查力」面 —— 恒 exit 0 假绿，
#     等价于 VC 空转。本门把 84.1 的「非占位」升级为「非真空」。
#   · 为什么静态字面判定而非执行命令：执行有副作用且环境不可控（跑出来的结果不可复判）；
#     字面集判定零副作用、机器可判；不可判定形态（wrapper 层、变量间接、命令替换）一律 fail-open，
#     避免把痛点换成误报面（P-01 同口径：判定面收窄优于误伤合法交付）。
#   · 为什么管道只看尾段：管道整体退出码由尾段决定—— `echo x | grep -q y f` 的判定力全在
#     grep（有退出码判据），前段 echo/true 只是喂数据，整链非真空；全部语句尾段都命中
#     真空字面集（true/:/echo/printf/cat /dev/null）才判真空。语句边界（; &）逐句独立判定。
#   · 为什么不判 `bash -c "..."` 类 wrapper 命令：剥内层需解析 shell 语法，误报面大于收益 ——
#     诚实边界，字面集维护面可扩展（改动字面集前先跑 selftest-vc-nonvacuous.sh 双向回归）。
#
# 用法: bash check-vc-nonvacuous.sh <plan-dir>
# 输出前缀统一 `[vc-nonvacuous]`（机器中继锚）
set -u

PLAN_DIR="${1:-}"
if [ -n "${2:-}" ]; then
    printf '[vc-nonvacuous] ERROR: 未知参数 %s（用法: bash check-vc-nonvacuous.sh <plan-dir>）\n' "$2" >&2
    exit 2
fi
if [ -z "$PLAN_DIR" ] || [ ! -d "$PLAN_DIR" ]; then
    printf '[vc-nonvacuous] ERROR: plan-dir 缺失或非目录: %s\n' "${PLAN_DIR:-<empty>}" >&2
    exit 2
fi
PLAN_DIR="$(cd "$PLAN_DIR" && pwd)"
VFILE="$PLAN_DIR/verification.md"
if [ ! -f "$VFILE" ]; then
    printf '[vc-nonvacuous] ERROR: 无 verification.md（%s）\n' "$VFILE" >&2
    exit 2
fi

# ── 判定辅助 ──────────────────────────────────────────────────────────────────

# trim_text — 剥首尾空白
trim_text() {
    printf '%s' "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# judge_pg <管道段文本> — 该段是否真空：0=真空（主体 ∈ 真空字面集），1=有判定力
judge_pg() {
    local pg="$1"
    local -a ws
    read -ra ws <<< "$pg"
    local n=${#ws[@]} i=0 w
    # 剥首部变量赋值（FOO=bar 单词形态；多词赋值形态不在判定面 → fail-open）
    # Why 用 case 而非 [[ =~ ]]：正则字符串内的反引号会被 [[ ]] 解析为命令替换（bash 语法陷阱）
    while [ "$i" -lt "$n" ]; do
        w="${ws[$i]}"
        case "$w" in *=*) i=$((i + 1)) ;; *) break ;; esac
    done
    [ "$i" -eq "$n" ] && return 0       # 仅赋值无可执行命令 = 真空
    local head="${ws[$i]##*/}"
    # env 前缀（env FOO=bar <cmd>）
    if [ "$head" = "env" ]; then
        i=$((i + 1))
        while [ "$i" -lt "$n" ]; do
            w="${ws[$i]}"
            case "$w" in *=*) i=$((i + 1)) ;; *) break ;; esac
        done
        [ "$i" -eq "$n" ] && return 0
        head="${ws[$i]##*/}"
    fi
    case "$head" in
        true|:|ok|0|echo|printf)
            # echo/printf 仅产出文本，退出码恒 0 无判定力（判定力只能来自管道尾真实命令）
            return 0
            ;;
        cat)
            # cat：全部参数为 /dev/null（或无参数）= 真空；任何其他参数有检查力
            local j=$((i + 1))
            while [ "$j" -lt "$n" ]; do
                [ "${ws[$j]}" != "/dev/null" ] && return 1
                j=$((j + 1))
            done
            return 0
            ;;
        *)
            # 真实可执行（grep/test/diff/…）→ 非真空
            return 1
            ;;
    esac
}

# is_vacuous <命令文本> — 返回值: 0=真空（主循环 if 命中即计 FAIL），1=非真空
# Why 只看语句内「最后一个管道段」：管道整体退出码由尾段决定——
#   `echo x | grep -q y` 的判定力全在 grep（有参数/退出码判据）；前段 echo/true 只是喂数据，
#   整链有判定力=非真空。某语句尾段真空 → 整条命令标记真空（主循环逐语句取「全真空」语义）。
#   语句边界（; &）逐句独立判定。
is_vacuous() {
    local cmd="${1//\`/}"                       # 剥反引号（markdown 内联码形态）
    cmd="$(trim_text "$cmd")"
    [ -z "$cmd" ] && return 0                    # 空命令 = 无检查力
    local st
    # 末行无尾随换行时 read 返回非零但变量已填充 —— 必须 `|| [ -n "$st" ]` 兜住，
    # 否则循环体永不执行（实测踩坑：单语句命令全被跳过 → 混合链误判真空）
    while IFS= read -r st || [ -n "$st" ]; do
        st="$(trim_text "$st")"
        [ -z "$st" ] && continue
        local -a pgs
        IFS='|' read -ra pgs <<< "$st"
        local last="${pgs[${#pgs[@]}-1]}"
        last="$(trim_text "$last")"
        [ -z "$last" ] && continue               # 尾部空段（a | 残缺写法）→ 跳过（fail-open）
        if ! judge_pg "$last"; then
            return 1                             # 尾段有判定力 → 非真空
        fi
    done < <(printf '%s' "$cmd" | tr ';&' '\n\n')
    return 0                                     # 所有语句尾段均真空 → 真空
}

# ── 抽取：VC 条目 → 其 **Verify command** 行（输出 `VC-N <TAB> 行号 <TAB> 命令文本`）──────
extract_vc_cmds() {
    awk '
    /^ *- *\[[xX ]\] *VC-[0-9]+/ {
        match($0, /VC-[0-9]+/)
        vcid = substr($0, RSTART, RLENGTH)
        pending = 1
        next
    }
    pending && $0 ~ /\*\*Verify command\*\*[[:space:]]*:/ {
        s = $0
        sub(/^[[:space:]]*\*\*Verify command\*\*[[:space:]]*:[[:space:]]*/, "", s)
        sub(/[[:space:]]+$/, "", s)
        printf "%s\t%d\t%s\n", vcid, NR, s
        pending = 0
        next
    }
    /^#/ || /^ *- / { pending = 0 }
    ' "$VFILE"
}

# ── 主判定 ────────────────────────────────────────────────────────────────────
ROWS="$(extract_vc_cmds)"
if [ -z "$ROWS" ]; then
    printf '[vc-nonvacuous] SKIP (无 VC-Verify command 判定面: 无 VC 条目或无 **Verify command** 行)\n'
    exit 0
fi

FAILS=0
CHECKED=0
while IFS=$'\t' read -r vcid ln cmd; do
    [ -n "${vcid:-}" ] || continue
    CHECKED=$((CHECKED + 1))
    if is_vacuous "$cmd"; then
        FAILS=$((FAILS + 1))
        printf '[vc-nonvacuous] ✗ %s:%s %s 真空命令: %s\n' \
            "$VFILE" "$ln" "$vcid" "$(trim_text "$cmd" | cut -c1-120)"
    fi
done <<< "$ROWS"

if [ "$FAILS" -gt 0 ]; then
    printf '[vc-nonvacuous] ✗ %d/%d 条 VC 含真空命令 — 替换为真实判定命令（grep/test/diff 等）后重跑\n' \
        "$FAILS" "$CHECKED"
    exit 1
fi
printf '[vc-nonvacuous] ✓ %d 条 VC 无真空命令\n' "$CHECKED"
exit 0
