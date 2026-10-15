#!/usr/bin/env bash
# selftest-rule-reserve-pairing.sh — task-v176 S9: 规则编号账本 reserve↔land 配对不变量守护
#
# What（守护对象 + 运行方式）:
#   读 plans/.rule-reservations.jsonl（Rule 20.6 编号账本，v128 rule-reserve.sh 机制件），
#   共 3 条编号断言 PR-01..PR-03（断言编号/逐行 PASS-FAIL/Total 汇总/exit 0|1 约定同
#   selftest-archive-plan.sh，pass/fail 统计风格沿用既有 selftest-*.sh）：
#     · PR-01 配对方向一（landed 有 reserved）: 每条 status=landed 的 rule 必须存在对应
#         status=reserved 行；EXEMPT_LANDED 豁免表 = 46 47 48 49 50 75（历史旁路），非豁免 FAIL 并列缺失编号
#     · PR-02 配对方向二（reserved 有 landed）: 同 rule 有 reserved 但无 landed 的悬空项；
#         EXEMPT_DANGLING 豁免表 = 57 60 80 82（历史悬空预留），非豁免 FAIL
#     · PR-03 脚本自检: 两张豁免数组去重、无空格污染（数组元素全为纯数字）
#   运行方式：`bash scripts/selftest-rule-reserve-pairing.sh`（只读账本 grep/sed，零写入）；
#   逐行打印 `PR-NN PASS/FAIL <说明>`，末行 `Total: N PASS=x FAIL=y`；全 PASS exit 0，任一 FAIL exit 1。
#
# Why（2026-10-15 task-v176 D13 建）:
#   编号账本存在双向失真且无机器门：32 reserved vs 34 landed——6 条 landed 无 reserved
#   （46/47/48/49/50/75，属历史旁路）+ 4 条 reserved 无 landed（57/60/80/82，历史悬空预留：
#   57=v141 预留后 land 未配对；60=v143 仲裁改号；80=v169；82=v171），仓内无任何 selftest
#   校验该配对不变量。本脚本=双向配对不变量的机器守护，豁免表内历史存量冻结登记（新失配对
#   即 FAIL 报警）；豁免注释：2026-10-15 task-v176 D13：v128 建账本前历史 land，登记豁免。
# 依赖: bash + GNU sed/grep/sort/uniq（只读）。账本缺失=显式 FAIL（fail-closed，同 selftest-archive-plan.sh AP-99 口径）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# 账本在仓/工作树/部署位三处 plans/ 根（相对技能根的上上级；task-planner 位于 skills/task-planner）
LEDGER="$SKILL_ROOT/../../plans/.rule-reservations.jsonl"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'PR-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'PR-%s FAIL %s\n' "$1" "$2"; }

# ── 豁免表（历史存量冻结；新增失配对必须走仲裁改号或补登记，不得扩表静默放行）──
# PR-01 豁免：landed 无对应 reserved 的历史旁路编号
# 2026-10-15 task-v176 D13：v128 建账本前历史 land，登记豁免
EXEMPT_LANDED=(46 47 48 49 50 75)
# PR-02 豁免：reserved 无对应 landed 的历史悬空预留编号
# 57=v141 预留后 land 未配对；60=v143 仲裁改号；80=v169；82=v171（均为历史悬空预留，非在途）
EXEMPT_DANGLING=(57 60 80 82)

# 在位豁免表成员判真/假（供 FAIL 时判定豁免是否覆盖该编号）
is_exempt_landed() { local n="$1" e; for e in "${EXEMPT_LANDED[@]}"; do [ "$e" = "$n" ] && return 0; done; return 1; }
is_exempt_dangling() { local n="$1" e; for e in "${EXEMPT_DANGLING[@]}"; do [ "$e" = "$n" ] && return 0; done; return 1; }

# ── 解析账本：每行形如 {"rule": N, "status": "..."}（键序固定，rule 在前；容忍全/半角空格变体）──
# 输出 "N status" 两列；账本行无 rule/status 键则跳过（schema 畸变由 rule-reserve.sh 机制面负责，
# 本脚本只锁配对不变量，越界即被 PR-03 与 registry 交叉守护发现）。
parse_pairs() {
    grep -E '"rule"[[:space:]]*:[[:space:]]*[0-9]+' "$LEDGER" 2>/dev/null \
    | sed -E 's/^.*"rule"[[:space:]]*:[[:space:]]*([0-9]+),?[[:space:]]*"status"[[:space:]]*:[[:space:]]*"([a-z]+)".*/\1 \2/'
}

# ── PR-01: 每条 landed 必须存在对应 reserved（非豁免编号）──
if [ ! -f "$LEDGER" ]; then
    bad 01 "账本缺失: $LEDGER（fail-closed）"
else
    pairs="$(parse_pairs)"
    Landed_rules="$(printf '%s\n' "$pairs" | awk '$2=="landed"{print $1}' | sort -n | uniq)"
    Reserved_rules="$(printf '%s\n' "$pairs" | awk '$2=="reserved"{print $1}' | sort -n | uniq)"
    # 缺失=landed 集合 − reserved 集合（comm -23 file1 file2=file1 独有项）；再按豁免表剔除，剩余即 FAIL 对象
    raw_missing="$(comm -23 <(printf '%s\n' "$Landed_rules") <(printf '%s\n' "$Reserved_rules"))"
    non_exempt=""
    for n in $raw_missing; do
        is_exempt_landed "$n" || non_exempt="$non_exempt $n"
    done
    # 非豁免项为空即 PASS（raw_missing 非空但全在豁免表内=历史存量冻结放行并注明）；有非豁免项=FAIL
    if [ -z "$non_exempt" ]; then
        if [ -n "$raw_missing" ]; then
            ok 01 "landed 无 reserved 的缺失项=$(echo $raw_missing) 全在豁免表 ${EXEMPT_LANDED[*]} 内（历史旁路冻结）"
        else
            ok 01 "无缺失：所有 landed 均有对应 reserved 行"
        fi
    else
        bad 01 "landed 无对应 reserved（非豁免缺失编号:$(echo $non_exempt)；豁免表=${EXEMPT_LANDED[*]}，新增失配对须仲裁改号或补 reserved 登记，不得扩表）"
    fi

    # ── PR-02: 悬空项=reserved 集合 − landed 集合（comm -13 file1 file2=file2 独有项；再按豁免表剔除）──
    raw_dangling="$(comm -23 <(printf '%s\n' "$Reserved_rules") <(printf '%s\n' "$Landed_rules"))"
    non_exempt2=""
    for n in $raw_dangling; do
        is_exempt_dangling "$n" || non_exempt2="$non_exempt2 $n"
    done
    if [ -z "$non_exempt2" ]; then
        if [ -n "$raw_dangling" ]; then
            ok 02 "reserved 悬空项=$(echo $raw_dangling) 全在豁免表 ${EXEMPT_DANGLING[*]} 内（历史悬空冻结）"
        else
            ok 02 "无悬空：所有 reserved 均有对应 landed 行"
        fi
    else
        bad 02 "reserved 无对应 landed（非豁免悬空编号:$(echo $non_exempt2)；豁免表=${EXEMPT_DANGLING[*]}，历史悬空须 land 配对或仲裁作废，不得扩表）"
    fi
fi

# ── PR-03: 脚本自检——EXEMPT 数组去重、无空格污染（元素全为纯数字）──
# Why：豁免表是本守护的口径源，自身被空格/重复/非数字污染=失配对被静默豁免（越权面），
#      自检先于被检面可信是守护脚本的元不变量。
pr3_bad=0
for arr in EXEMPT_LANDED EXEMPT_DANGLING; do
    elems="${!arr[@]}"
    # 去重自检：元素数=去重后元素数
    [ "$(printf '%s\n' $elems | sort | uniq | grep -c .)" -eq "$(printf '%s\n' $elems | grep -c .)" ] || pr3_bad=1
    # 空格/非数字污染自检：每个元素必须全为数字
    for e in $elems; do
        case "$e" in
            ''|*[!0-9]*) pr3_bad=1 ;;
        esac
    done
done
if [ "$pr3_bad" -eq 0 ]; then
    ok 03 "豁免表自检通过（去重 + 无空格污染 + 元素全为纯数字）"
else
    bad 03 "豁免表自检失败（EXEMPT_LANDED/EXEMPT_DANGLING 存在重复或空格/非数字污染）"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
