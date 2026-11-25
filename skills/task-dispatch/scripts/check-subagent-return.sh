#!/usr/bin/env bash
# check-subagent-return.sh — 子代理 8 字段 + 可选第 9 行回执主进程侧机械校验器 (Rule 22.4b, task-v161 S3)
# What: 校验子代理返回块 — 判据一: 8 字段齐全(status/acceptance/files/evidence/checkpoint/
#   findings_written/blockers/confidence 各 ≥1 行命中, 行首锚定, 容忍行前空白; 前 8 字段逻辑原样不变) /
#   判据二: 无契约外字段(除 8 字段与可选第 9 行 spec_receipt: 外出现 ^[a-z_]+: 形态行即违规, 输出点名违规字段名) /
#   判据三: 块尾无附加(最后一个 ^confidence: 行之后只允许 ``` 围栏行、纯空白、以及最多一行
#   非空 spec_receipt:；该行须在 confidence 之后, 重复/空值/位置错误均违规) /
#   判据四: 值域(status ∈ done|partial|failed|timeout; confidence ∈ HIGH|MED|LOW)。
#   全过 → stdout "[return-guard] PASS" exit 0; 任一不过 → "[return-guard] VIOLATION <判据>" exit 1。
# Why: 契约文本不缺(subagent_dispatch.md §7 Rule 22.4b 8 字段严格 + 规范基线任务追加 spec_receipt 第 9 行),
#   缺的是执行层强制 — v152 实证 status 与 acceptance 之间混入 summary: 契约外字段
#   (plans/task-v152-proactive-context/subagent-state/2-executor-S1.md:32); 无机器判据时主进程
#   只能肉眼逐份看子代理返回, 漂移无法被曝光。
#   [2026-11-26 task-spec-consumption-chain C1] 现象: 模板 §7 要求 spec_receipt 写在 confidence 之后,
#   而本校验器旧版只认 8 字段并把 spec_receipt 判为契约外字段 + 块尾附加 → 合规回执必被误杀。
#   修法: 把 spec_receipt 列入白名单并显式允许「confidence 后最多一行非空」块尾形态; 前 8 字段判据不变,
#   「存在 SPEC 行的计划必填 / 无基线计划填 none」仍由派发侧文本契约承担(脚本只校验形态, 不读计划)。
#   零 config 键: 固定行为, 不读 config。
# Usage:
#   check-subagent-return.sh <file>      # 校验文件内容
#   check-subagent-return.sh             # 无参 → 读 stdin
#   check-subagent-return.sh --selftest  # 内置 12 夹具自检(内存构造, 不写临时文件; 任一夹具 FAIL → exit 1)
#   check-subagent-return.sh --require-spec-receipt <file|stdin>  # 基线计划模式: 缺第 9 行 → rc=1
#   check-subagent-return.sh --help
# 夹具: ① 合规 8 字段块 → rc0; ② status 后紧跟 summary: 契约外字段(v152 实证形态) → rc1 点名 summary;
#   ③ 合规块后追加「## 附:验收细节」+两行说明 → rc1; ④ 无任何 8 字段的自然语言段落 → rc1;
#   ⑤ CA-4 [task-v172]: checkpoint 值带「（待主进程代建）」注记 → rc0;
#   ⑥ 8 字段 + spec_receipt: none → rc0; ⑦ 8 字段 + 逐条核验表值 → rc0;
#   ⑧ spec_receipt 后再追加自由文本 → rc1; ⑨ spec_receipt 写在 confidence 之前 → rc1;
#   ⑩ spec_receipt 空值 → rc1; ⑪ 基线计划必填模式缺行 → rc1 点名; ⑫ 必填模式有行 → rc0。
set -u
export LC_ALL=C   # 字节级正则: [a-z_] / [:space:] 字符类不受多字节 locale 干扰

FIELDS="status acceptance files evidence checkpoint findings_written blockers confidence"
FAILCNT=0         # selftest 汇总旗标(任一夹具 FAIL = 1, 供 --selftest 退出码)
# [2026-11-26 C1] REQUIRE_SPEC=1（--require-spec-receipt，主进程对存在 SPEC-* 基线行的计划启用）时
# 第 9 行由可选升级为必填；默认 0 保持既有 8 字段调用方行为不变（无基线计划填 spec_receipt: none）。
REQUIRE_SPEC=0

# run <内容快照> — 四判据对同一字符串各读一次; 全过 → PASS rc0; 任一不过 → VIOLATION 行 rc1
# Why 同一快照: 文件/stdin 只读一次进内存作 $1, 各判据读快照 — 若各判据分读流, 第二个判据读到空流误判
run() {
    local input="$1" c v vals
    for c in $FIELDS; do  # 判据一: 8 字段各 ≥1 行命中(行首锚定, 容忍行前空白)
        printf '%s\n' "$input" | grep -qE "^[[:space:]]*${c}:" \
            || { echo "[return-guard] VIOLATION 判据一: 缺字段 ${c}:"; return 1; }
    done
    # [2026-11-26 C1] 基线计划必填模式: 存在 SPEC-* 行的计划由主进程带 --require-spec-receipt 调用；
    # 缺第 9 行时给出点名字段的提示，避免「模板要求必填但校验器放行」再次形成绕过面。
    if [ "$REQUIRE_SPEC" -eq 1 ] && ! printf '%s\n' "$input" | grep -qE '^[[:space:]]*spec_receipt:'; then
        echo "[return-guard] VIOLATION 判据一: 缺字段 spec_receipt:（基线计划必填；无基线计划填 none）"
        return 1
    fi
    c="$(printf '%s\n' "$input" | grep -oE '^[[:space:]]*[a-z_]+:' | sed -E 's/^[[:space:]]*//; s/:$//' \
        | grep -vxE 'status|acceptance|files|evidence|checkpoint|findings_written|blockers|confidence|spec_receipt' || true)"  # 判据二(2026-11-26 C1: 可选第 9 行 spec_receipt 入白名单; 其余契约外字段仍点名)
    [ -z "$c" ] || { echo "[return-guard] VIOLATION 判据二: 契约外字段: $(printf '%s\n' "$c" | sort -u | tr '\n' ' ')"; return 1; }
    # 判据三(2026-11-26 C1): 前 8 字段收尾语义不变(confidence 后仅围栏/空白);
    # 额外允许 spec_receipt 作为唯一合法第 9 行, 且必须位于 confidence 之后、非空、只出现一次。
    c="$(printf '%s\n' "$input" | awk '
        { lines[NR]=$0; if ($0 ~ /^[[:space:]]*confidence:/) last=NR }
        END {
            n=0
            for (i=1; i<=NR; i++) {
                l=lines[i]
                if (l !~ /^[[:space:]]*spec_receipt:/) continue
                if (i <= last) { printf "[return-guard] VIOLATION 判据三: spec_receipt 须在 confidence 之后 L%d\n", i; continue }
                n++
                if (n > 1) { printf "[return-guard] VIOLATION 判据三: spec_receipt 重复 L%d\n", i; continue }
                if (l ~ /^[[:space:]]*spec_receipt:[[:space:]]*$/) printf "[return-guard] VIOLATION 判据三: spec_receipt 值空 L%d\n", i
            }
            for (i=last+1; i<=NR; i++) {
                l=lines[i]
                if (l ~ /^[[:space:]]*$/) continue
                if (l ~ /^[[:space:]]*```/) continue
                if (l ~ /^[[:space:]]*spec_receipt:/) continue
                printf "[return-guard] VIOLATION 判据三: 块尾附加行 L%d: %s\n", i, l } }')"  # 判据三
    [ -z "$c" ] || { printf '%s\n' "$c"; return 1; }
    for c in status confidence; do  # 判据四: 值域(每条字段行的值都须合法, 防多行重复字段夹带)
        vals="$(printf '%s\n' "$input" | grep -E "^[[:space:]]*${c}:" | sed -E 's/^[[:space:]]*'"$c"':[[:space:]]*//; s/[[:space:]]+$//')"
        [ -n "$vals" ] || { echo "[return-guard] VIOLATION 判据四: ${c} 值缺失"; return 1; }
        while IFS= read -r v; do
            case "$c|$v" in
                "status|done"|"status|partial"|"status|failed"|"status|timeout"|"confidence|HIGH"|"confidence|MED"|"confidence|LOW") ;;
                *) echo "[return-guard] VIOLATION 判据四: ${c} 值 $v 超出值域"; return 1 ;;
            esac
        done <<< "$vals"
    done
    echo "[return-guard] PASS"
}

# selftest — 内置 10 夹具(printf 内存构造, 不写临时文件); 逐夹具断言, 任一 FAIL 置 FAILCNT → 退出码 1
# 夹具口径与头部注释一致: ①合规 8 行 rc0; ②summary: 契约外字段 rc1 且输出点名 summary; ③块尾附加 rc1;
# ④纯自然语言 rc1; ⑤checkpoint 注记 rc0; ⑥~⑩ 为 2026-11-26 C1 追加的 9 行变体断言(非替换旧 8 行夹具)
selftest() {
    local f
    f="$(printf '%s\n' 'status: done' 'acceptance: 4/4 pass — [1:PASS 2:PASS 3:PASS 4:PASS]' 'files: none' 'evidence: bash -n 无语法错误' 'checkpoint: /p/subagent-state/3.md' 'findings_written: none' 'blockers: none' 'confidence: HIGH')"
    check_fixture 1 "$f" 0
    f="$(printf '%s\n' 'status: done' 'summary: S1 完成——契约外长文本字段(v152 实证形态)' 'acceptance: 1/1 pass — [1:PASS]' 'files: none' 'evidence: e' 'checkpoint: /p/3.md' 'findings_written: none' 'blockers: none' 'confidence: HIGH')"
    check_fixture 2 "$f" 1 summary
    f="$(printf '%s\n' 'status: done' 'acceptance: 2/2 pass — [1:PASS 2:PASS]' 'files: none' 'evidence: e' 'checkpoint: /p/3.md' 'findings_written: none' 'blockers: none' 'confidence: HIGH' '## 附:验收细节' '说明一' '说明二')"
    check_fixture 3 "$f" 1
    f="$(printf '%s\n' '子代理已完成任务, 向模块 x 新增三个函数, 测试全部通过, 无阻塞项。' '总体结论: 交付质量好, 自评估置信度高。')"
    check_fixture 4 "$f" 1
    # ⑤ CA-4 [task-v172]: checkpoint 值带「（待主进程代建）」中文注记(22.8.6 返回侧形态) → 仍判 PASS,
    #   证明注记不触发判据二 VIOLATION(注记在行内值域, 非 ^[a-z_]+: 形态契约外字段, 也不属 8 字段值域检查对象)
    f="$(printf '%s\n' 'status: done' 'acceptance: 1/1 pass — [1:PASS]' 'files: none' 'evidence: e' 'checkpoint: /p/3.md（待主进程代建）' 'findings_written: none' 'blockers: none' 'confidence: HIGH')"
    check_fixture 5 "$f" 0
    # [2026-11-26 task-spec-consumption-chain C1] 9 行变体断言: 追加而非替换上述 8 行夹具,
    # 证明「合规 8 字段 + 可选 spec_receipt」两侧形态都被接受, 且块尾口径收紧到唯一合法第 9 行。
    f="$(printf '%s\n' 'status: done' 'acceptance: 1/1 pass — [1:PASS]' 'files: none' 'evidence: e' 'checkpoint: /p/3.md' 'findings_written: none' 'blockers: none' 'confidence: HIGH' 'spec_receipt: none')"
    check_fixture 6 "$f" 0
    f="$(printf '%s\n' 'status: done' 'acceptance: 2/2 pass — [1:PASS 2:PASS]' 'files: none' 'evidence: e' 'checkpoint: /p/3.md' 'findings_written: none' 'blockers: none' 'confidence: MED' 'spec_receipt: 逐条核验表（SPEC-1 | 观测 | PASS）')"
    check_fixture 7 "$f" 0
    f="$(printf '%s\n' 'status: done' 'acceptance: 1/1 pass — [1:PASS]' 'files: none' 'evidence: e' 'checkpoint: /p/3.md' 'findings_written: none' 'blockers: none' 'confidence: HIGH' 'spec_receipt: none' '## 附:验收细节')"
    check_fixture 8 "$f" 1
    f="$(printf '%s\n' 'status: done' 'acceptance: 1/1 pass — [1:PASS]' 'files: none' 'evidence: e' 'checkpoint: /p/3.md' 'findings_written: none' 'blockers: none' 'spec_receipt: none' 'confidence: HIGH')"
    check_fixture 9 "$f" 1
    f="$(printf '%s\n' 'status: done' 'acceptance: 1/1 pass — [1:PASS]' 'files: none' 'evidence: e' 'checkpoint: /p/3.md' 'findings_written: none' 'blockers: none' 'confidence: HIGH' 'spec_receipt:')"
    check_fixture 10 "$f" 1
    # ⑪⑫ 必填模式(基线计划)变体: 缺行 rc=1 点名 spec_receipt; 有行 rc=0。夹具后复位全局旗标, 防污染后续调用。
    f8="$(printf '%s\n' 'status: done' 'acceptance: 1/1 pass — [1:PASS]' 'files: none' 'evidence: e' 'checkpoint: /p/3.md' 'findings_written: none' 'blockers: none' 'confidence: HIGH')"
    REQUIRE_SPEC=1; check_fixture 11 "$f8" 1 spec_receipt; REQUIRE_SPEC=0
    f9="$(printf '%s\n' 'status: done' 'acceptance: 1/1 pass — [1:PASS]' 'files: none' 'evidence: e' 'checkpoint: /p/3.md' 'findings_written: none' 'blockers: none' 'confidence: HIGH' 'spec_receipt: none')"
    REQUIRE_SPEC=1; check_fixture 12 "$f9" 0; REQUIRE_SPEC=0
    return "$FAILCNT"
}

# check_fixture <N> <内容> <期望 rc> [期望输出子串] — 单夹具断言, 失败置 FAILCNT=1
check_fixture() {
    local n="$1" f="$2" want="$3" sub="${4:-}" out rc ok=1
    out="$(run "$f")"; rc=$?
    [ "$rc" -eq "$want" ] || ok=0
    [ -z "$sub" ] || { case "$out" in *"$sub"*) ;; *) ok=0 ;; esac }
    if [ "$ok" = 1 ]; then echo "[selftest] fixture-$n PASS"
    else echo "[selftest] fixture-$n FAIL (want rc $want got rc $rc): $(printf '%s\n' "$out" | grep -m1 VIOLATION || true)"; FAILCNT=1
    fi
}

main() {
    # [2026-11-26 C1] 先摘除必填模式开关再走既有 case：无开关时参数序列与旧版完全一致（CLI 向后兼容）。
    local a args=()
    for a in "$@"; do
        case "$a" in
            --require-spec-receipt) REQUIRE_SPEC=1 ;;
            *) args+=("$a") ;;
        esac
    done
    set -- "${args[@]}"
    case "${1:-}" in
    --help|-h) sed -n '2,22p' "${BASH_SOURCE[0]}"; exit 0 ;;
    --selftest) selftest; exit "$?" ;;
    "") run "$(cat)" ;;
    *) [ -r "$1" ] || { echo "[return-guard] 文件不可读: $1" >&2; exit 1; }
       run "$(cat -- "$1")" ;;
    esac
}
main "$@"
