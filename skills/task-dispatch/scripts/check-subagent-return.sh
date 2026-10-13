#!/usr/bin/env bash
# check-subagent-return.sh — 子代理 8 字段返回主进程侧机械校验器 (Rule 22.4b, task-v161 S3)
# What: 校验子代理返回块 — 判据一: 8 字段齐全(status/acceptance/files/evidence/checkpoint/
#   findings_written/blockers/confidence 各 ≥1 行命中, 行首锚定, 容忍行前空白) /
#   判据二: 无契约外字段(除 8 字段外出现 ^[a-z_]+: 形态行即违规, 输出点名违规字段名) /
#   判据三: 块尾无附加(最后一个 ^confidence: 行之后只允许 ``` 围栏行与纯空白) /
#   判据四: 值域(status ∈ done|partial|failed|timeout; confidence ∈ HIGH|MED|LOW)。
#   全过 → stdout "[return-guard] PASS" exit 0; 任一不过 → "[return-guard] VIOLATION <判据>" exit 1。
# Why: 契约文本不缺(subagent_dispatch.md:62-77 Rule 22.4b 8 字段严格+「8 字段之后不得有任何内容」),
#   缺的是执行层强制 — v152 实证 status 与 acceptance 之间混入 summary: 契约外字段
#   (plans/task-v152-proactive-context/subagent-state/2-executor-S1.md:32); 无机器判据时主进程
#   只能肉眼逐份看子代理返回, 漂移无法被曝光。零 config 键: 固定行为, 不读 config。
# Usage:
#   check-subagent-return.sh <file>      # 校验文件内容
#   check-subagent-return.sh             # 无参 → 读 stdin
#   check-subagent-return.sh --selftest  # 内置 5 夹具自检(内存构造, 不写临时文件; 任一夹具 FAIL → exit 1)
#   check-subagent-return.sh --help
# 5 夹具: ① 合规 8 字段块 → rc0; ② status 后紧跟 summary: 契约外字段(v152 实证形态) → rc1 点名 summary;
#   ③ 合规块后追加「## 附:验收细节」+两行说明 → rc1; ④ 无任何 8 字段的自然语言段落 → rc1;
#   ⑤ CA-4 [task-v172]: checkpoint 值带「（待主进程代建）」注记(22.8.6 返回侧形态) → rc0(注记不触发判据二)。
set -u
export LC_ALL=C   # 字节级正则: [a-z_] / [:space:] 字符类不受多字节 locale 干扰

FIELDS="status acceptance files evidence checkpoint findings_written blockers confidence"
FAILCNT=0         # selftest 汇总旗标(任一夹具 FAIL = 1, 供 --selftest 退出码)

# run <内容快照> — 四判据对同一字符串各读一次; 全过 → PASS rc0; 任一不过 → VIOLATION 行 rc1
# Why 同一快照: 文件/stdin 只读一次进内存作 $1, 各判据读快照 — 若各判据分读流, 第二个判据读到空流误判
run() {
    local input="$1" c v vals
    for c in $FIELDS; do  # 判据一: 8 字段各 ≥1 行命中(行首锚定, 容忍行前空白)
        printf '%s\n' "$input" | grep -qE "^[[:space:]]*${c}:" \
            || { echo "[return-guard] VIOLATION 判据一: 缺字段 ${c}:"; return 1; }
    done
    c="$(printf '%s\n' "$input" | grep -oE '^[[:space:]]*[a-z_]+:' | sed -E 's/^[[:space:]]*//; s/:$//' \
        | grep -vxE 'status|acceptance|files|evidence|checkpoint|findings_written|blockers|confidence' || true)"  # 判据二
    [ -z "$c" ] || { echo "[return-guard] VIOLATION 判据二: 契约外字段: $(printf '%s\n' "$c" | sort -u | tr '\n' ' ')"; return 1; }
    c="$(printf '%s\n' "$input" | awk '
        { lines[NR]=$0; if ($0 ~ /^[[:space:]]*confidence:/) last=NR }
        END { for (i=last+1; i<=NR; i++) {
            l=lines[i]
            if (l ~ /^[[:space:]]*$/) continue
            if (l ~ /^[[:space:]]*```/) continue
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

# selftest — 内置 5 夹具(printf 内存构造, 不写临时文件); 逐夹具断言, 任一 FAIL 置 FAILCNT → 退出码 1
# 夹具口径与头部注释一致: ①合规 rc0; ②summary: 契约外字段 rc1 且输出点名 summary; ③块尾附加 rc1; ④纯自然语言 rc1
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
    case "${1:-}" in
    --help|-h) sed -n '2,18p' "${BASH_SOURCE[0]}"; exit 0 ;;
    --selftest) selftest; exit "$?" ;;
    "") run "$(cat)" ;;
    *) [ -r "$1" ] || { echo "[return-guard] 文件不可读: $1" >&2; exit 1; }
       run "$(cat -- "$1")" ;;
    esac
}
main "$@"
