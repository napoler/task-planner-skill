#!/usr/bin/env bash
# selftest-gate-degraded.sh — P-07「门降级可见化（[gate-degraded] 留痕）」行为级 + 静态守护（GD-01..GD-16）
#
# What（守护对象 + 运行方式）:
#   守护 P-07 全链落点，16 条编号断言，分四组：
#     · 静态锚（GD-01..GD-04）: check-gate-degraded.sh 在位/可执行/bash -n 通过 + 头注 What/Why 双层
#       （Rule 45）+ `[gate-degraded]` 输出前缀与 exit 0/1/2 语义锚 + registry 自登记 =1。
#     · 判定器行为级（GD-05..GD-14，mktemp 自建夹具，零外部依赖）:
#         GD-05 正例 门输出有实质判定词（PASS/✓）→ rc=0（门实际判过不报降级）
#         GD-06 负例 门痕迹仅 fail-open 降级标记（SKIPPED/fail-open 且无实质判定）→ rc=1 + 故障族原因
#         GD-07 正例 无门控痕迹（progress 无门标记 ∧ 无 verification 终验区块 ∧ 无 evidence/）→ rc=0（无降级面放行）
#         GD-08 负例 门痕迹仅信息行（无判定词且无降级标记）→ rc=1 + 无实质判定
#         GD-09 负例 豁免族跳过（SKIPPED + 非适用/豁免措辞，无故障词）→ rc=1 + 豁免类原因（故障/豁免分族）
#         GD-10 正例 判定优先：同门既有实质判定行又有 SKIPPED 行 → rc=0（正常跑过的门不误报降级）
#         GD-11 负例 verification.md「全量终验」区块在但无 Total: 判定行 → rc=1
#         GD-12 负例 evidence/*.out 缺 VC 编号头 → rc=1
#         GD-13 正例 evidence/*.out 头齐备（VC 编号 + ISO8601 时间戳）→ rc=0
#         GD-14 负例 evidence/*.out 缺 ISO8601 时间戳头 → rc=1
#     · 输入契约（GD-15）: 无参数 / 非目录 plan-dir → rc=2
#     · 负断言（GD-16）: 判定器零 python3 依赖且无 jq 调用（纯 shell 实现承诺）
#   运行方式: `bash scripts/selftest-gate-degraded.sh`；逐行打印 `GD-NN PASS/FAIL <说明>`，
#   末行 `Total: N PASS=x FAIL=y`；全 PASS exit 0，任一 FAIL exit 1。夹具全部 mktemp 于 /tmp 并跑毕即删。
#   注: GD-04 registry 自登记断言在 registry 行登记前恒 FAIL（交付批次内属预期，登记后即 PASS；
#       先例 selftest-check-drift / selftest-state-consistency 同批次登记模式）。
#
# Why（机制锚）:
#   根因（P-07）=check-* 门族 fail-open 降级时静默放行——「门没真正跑」与「门跑了且通过」不可区分。
#   本脚本锁三件事：
#     ① 判定器行为（正/负例双向：降级必报 rc=1、实质判定/无降级面不误报 rc=0——防把可见化做成误报面）；
#     ② 故障/豁免分族（GD-09：降级原因措辞区分「门控/环境故障」与「设计内合法跳过」，降级报告可读）；
#     ③ 判定面契约（GD-11..GD-14：verification 全量终验区块 + evidence/ 机器落盘头 = 本仓既有的
#        门控留痕两面，判定不可辨识 = 降级）。
# 依赖: bash + grep（夹具零外部依赖）。只读仓库 + 写 /tmp 夹具。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK="$SCRIPT_DIR/check-gate-degraded.sh"
REG="$SCRIPT_DIR/selftest-registry.tsv"
SELF="$SCRIPT_DIR/selftest-gate-degraded.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'GD-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'GD-%s FAIL %s\n' "$1" "$2"; }

# ── 夹具构造器 ───────────────────────────────────────────────────────────────────────
# make_gate_fixture <dir> <progress内容> [verification内容] [evidence形态: none|noVC|ok|noTS]
make_gate_fixture() {
    local d="$1" prog="$2" vrf="${3:-}" ev="${4:-none}"
    mkdir -p "$d"
    printf '%s\n' "$prog" > "$d/progress.md"
    if [ -n "$vrf" ]; then
        printf '%s\n' "$vrf" > "$d/verification.md"
    fi
    case "$ev" in
        noVC)
            mkdir -p "$d/evidence"
            printf '%s\n' 'raw output without header' > "$d/evidence/VC-1.out" ;;
        ok)
            mkdir -p "$d/evidence"
            printf '%s\n' \
                '# [run-verification] VC-1 | 2026-10-16T00:00:00Z | cmd: echo gd-ok' \
                '# ---- stdout/stderr ----' \
                'ok' > "$d/evidence/VC-1.out" ;;
        noTS)
            mkdir -p "$d/evidence"
            printf '%s\n' \
                '# [run-verification] VC-1 | 2026-10-16 | cmd: echo gd-nots' \
                '# ---- stdout/stderr ----' \
                'ok' > "$d/evidence/VC-1.out" ;;
    esac
}

NEUTRAL_PROGRESS='- 普通进度记录（无门标记）'

# ── GD-01 判定器在位 + 可执行 + bash -n ─────────────────────────────────────────────
if [ -f "$CHECK" ] && [ -x "$CHECK" ] && bash -n "$CHECK" 2>/dev/null; then
    ok 01 "check-gate-degraded.sh 在位 + 可执行 + bash -n 通过"
else
    bad 01 "check-gate-degraded.sh 缺失/不可执行/语法错（在位=$([ -f "$CHECK" ] && echo yes || echo no) 可执行=$([ -x "$CHECK" ] && echo yes || echo no)）"
fi

# ── GD-02 头注 What/Why 双层注释（Rule 45）──────────────────────────────────────────
if grep -q '^# What' "$CHECK" && grep -q '^# Why' "$CHECK"; then
    ok 02 "头注 What + Why 双层注释齐备（Rule 45）"
else
    bad 02 "头注缺 What 或 Why（Rule 45 双层注释不齐）"
fi

# ── GD-03 输出前缀 + exit 语义锚 ────────────────────────────────────────────────────
if grep -qF '[gate-degraded] ✗' "$CHECK" && grep -qF '[gate-degraded] ✓' "$CHECK" \
   && grep -qE '^[[:space:]]*exit 0' "$CHECK" && grep -qE '^[[:space:]]*exit 1' "$CHECK" \
   && grep -qE '^[[:space:]]*exit 2' "$CHECK"; then
    ok 03 "输出前缀 [gate-degraded] ✗/✓ + exit 0/1/2 三语义锚在位"
else
    bad 03 "输出前缀或 exit 语义锚缺失（门控输出契约不齐）"
fi

# ── GD-04 registry 自登记 =1 ────────────────────────────────────────────────────────
_n="$(grep -c 'selftest-gate-degraded.sh' "$REG" 2>/dev/null || true)"
if [ "${_n:-0}" -ge 1 ]; then
    ok 04 "selftest-registry.tsv 含本脚本登记行（n=$_n）"
else
    bad 04 "selftest-registry.tsv 缺 selftest-gate-degraded.sh 登记行（回归不运行本守护；登记后即 PASS）"
fi

# ── GD-05 正例 门输出有实质判定（PASS/✓）→ rc=0 ─────────────────────────────────────
F5="$(mktemp -d "${TMPDIR:-/tmp}/gd5.XXXXXX")"
make_gate_fixture "$F5" "- [plan] 终验链留痕
- [plan] VC-GATE PASSED (VC 表=5)
- [rcov-gate] R-COVERAGE 判定 ✓"
_o="$(bash "$CHECK" "$F5" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && printf '%s' "$_o" | grep -q '门链无降级'; then
    ok 05 "正例 门输出含实质判定（PASSED/✓）→ rc=0 门链无降级（不误报降级）"
else
    bad 05 "含实质判定的门被误报降级: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F5"

# ── GD-06 负例 fail-open 降级标记且无实质判定 → rc=1（故障族）──────────────────────
F6="$(mktemp -d "${TMPDIR:-/tmp}/gd6.XXXXXX")"
make_gate_fixture "$F6" "- [evidence-anchor] SKIPPED (fail-open: 环境降级 缺 jq，证据锚检查未实际执行)
- [rcov-gate] 无输出（stats 异常，降级放行）"
_o="$(bash "$CHECK" "$F6" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -qF 'fail-open 降级放行' \
   && printf '%s' "$_o" | grep -qF '[rcov-gate]' \
   && printf '%s' "$_o" | grep -qF '[evidence-anchor]'; then
    ok 06 "负例 门痕迹仅 fail-open/SKIPPED 无实质判定 → rc=1 + 故障族原因 + 逐条 [gate-degraded] ✗ 留痕"
else
    bad 06 "fail-open 降级未被标记: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F6"

# ── GD-07 正例 无门控痕迹（无降级面）→ rc=0 ────────────────────────────────────────
F7="$(mktemp -d "${TMPDIR:-/tmp}/gd7.XXXXXX")"
make_gate_fixture "$F7" "$NEUTRAL_PROGRESS"
_o="$(bash "$CHECK" "$F7" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && printf '%s' "$_o" | grep -q '无门控痕迹面'; then
    ok 07 "正例 无门控痕迹（progress 无门标记 ∧ 无终验区块 ∧ 无 evidence/）→ rc=0 无降级面放行"
else
    bad 07 "无门控痕迹面被误判: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F7"

# ── GD-08 负例 门痕迹仅信息行（无判定无降级标记）→ rc=1 无实质判定 ─────────────────
F8="$(mktemp -d "${TMPDIR:-/tmp}/gd8.XXXXXX")"
make_gate_fixture "$F8" "- [plan] 门链运行记录（信息行，无判定词族命中）"
_o="$(bash "$CHECK" "$F8" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q '无实质判定'; then
    ok 08 "负例 门痕迹仅信息行（判定未落盘）→ rc=1 + 无实质判定"
else
    bad 08 "信息行痕迹未报降级: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F8"

# ── GD-09 负例 豁免族跳过（无故障词）→ rc=1 豁免类原因（故障/豁免分族）─────────────
F9="$(mktemp -d "${TMPDIR:-/tmp}/gd9.XXXXXX")"
make_gate_fixture "$F9" "- [plan] DELEGATION GATE SKIPPED (豁免: 非适用面，设计内跳过)
- [CR-GATE] SKIPPED (非 git 目录无 diff 面，设计内跳过)"
_o="$(bash "$CHECK" "$F9" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q '跳过未跑（标记词豁免/非适用族' \
   && ! printf '%s' "$_o" | grep -q 'fail-open 降级放行'; then
    ok 09 "负例 豁免族跳过（SKIPPED 无故障词）→ rc=1 + 豁免类原因（故障/豁免分族可区分）"
else
    bad 09 "豁免族未与故障族分族: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F9"

# ── GD-10 正例 判定优先（同门既有实质判定行又有 SKIPPED 行）→ rc=0 ──────────────────
F10="$(mktemp -d "${TMPDIR:-/tmp}/gd10.XXXXXX")"
make_gate_fixture "$F10" "- [goal-gate] ✓ PASS 判定在案
- [goal-gate] SKIPPED (存量计划，设计内跳过)"
_o="$(bash "$CHECK" "$F10" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && printf '%s' "$_o" | grep -q '均含实质判定'; then
    ok 10 "正例 判定优先: 同门判定行+SKIPPED 行共存 → rc=0（真跑过的门不被误报降级）"
else
    bad 10 "判定优先失效: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F10"

# ── GD-11 负例 verification「全量终验」区块在但无 Total: 判定行 → rc=1 ─────────────
F11="$(mktemp -d "${TMPDIR:-/tmp}/gd11.XXXXXX")"
make_gate_fixture "$F11" "$NEUTRAL_PROGRESS" "## 全量终验
- selftest 门链执行记录（无 Total 判定行）"
_o="$(bash "$CHECK" "$F11" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q 'Total:' && printf '%s' "$_o" | grep -q '全量终验'; then
    ok 11 "负例 verification 全量终验区块无 Total: 判定行 → rc=1（门链判定未落盘）"
else
    bad 11 "全量终验区块缺 Total 未被标记: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F11"

# ── GD-12 负例 evidence/*.out 缺 VC 编号头 → rc=1 ──────────────────────────────────
F12="$(mktemp -d "${TMPDIR:-/tmp}/gd12.XXXXXX")"
make_gate_fixture "$F12" "$NEUTRAL_PROGRESS" "" "noVC"
_o="$(bash "$CHECK" "$F12" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q 'VC 编号头'; then
    ok 12 "负例 evidence/VC-1.out 缺 VC 编号头 → rc=1（机器落盘头契约，run-verification 先例）"
else
    bad 12 "evidence 缺 VC 头未被标记: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F12"

# ── GD-13 正例 evidence/*.out 头齐备（VC + ISO8601）→ rc=0 ─────────────────────────
F13="$(mktemp -d "${TMPDIR:-/tmp}/gd13.XXXXXX")"
make_gate_fixture "$F13" "$NEUTRAL_PROGRESS" "" "ok"
_o="$(bash "$CHECK" "$F13" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && printf '%s' "$_o" | grep -q '机器落盘'; then
    ok 13 "正例 evidence/VC-1.out 头齐备（VC 编号 + ISO8601 时间戳）→ rc=0 不误报"
else
    bad 13 "头齐备的机器落盘被误报: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F13"

# ── GD-14 负例 evidence/*.out 缺 ISO8601 时间戳头 → rc=1 ───────────────────────────
F14="$(mktemp -d "${TMPDIR:-/tmp}/gd14.XXXXXX")"
make_gate_fixture "$F14" "$NEUTRAL_PROGRESS" "" "noTS"
_o="$(bash "$CHECK" "$F14" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q 'ISO8601 时间戳头'; then
    ok 14 "负例 evidence/VC-1.out 缺 ISO8601 时间戳头 → rc=1"
else
    bad 14 "evidence 缺时间戳头未被标记: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F14"

# ── GD-15 输入契约: 无参数 / 非目录 plan-dir → rc=2 ────────────────────────────────
_o15a="$(bash "$CHECK" 2>&1)"; _rc15a=$?
_o15b="$(bash "$CHECK" /tmp/gd15-notexist-$$ 2>&1)"; _rc15b=$?
if [ "$_rc15a" -eq 2 ] && [ "$_rc15b" -eq 2 ]; then
    ok 15 "输入契约: 无参数 rc=$_rc15a + 非目录 rc=$_rc15b（应均为 2）"
else
    bad 15 "输入契约异常: 无参数 rc=$_rc15a 非目录 rc=$_rc15b（应均 2）输出=$_o15a $_o15b"
fi

# ── GD-16 负断言: 判定器零 python3 依赖且无 jq 调用（纯 shell 实现承诺）────────────
_np="$(grep -c 'python3' "$CHECK" 2>/dev/null || true)"
_nj="$(grep -cE 'command -v jq|jq -r|jq -c' "$CHECK" 2>/dev/null || true)"
if [ "${_np:-0}" -eq 0 ] && [ "${_nj:-0}" -eq 0 ]; then
    ok 16 "负断言: check-gate-degraded.sh 无 python3/jq 调用（纯 shell 实现）"
else
    bad 16 "判定器含 python3 n=$_np / jq 调用 n=$_nj（违背纯 shell 实现承诺）"
fi

echo "----------------------------------------------------------------"
echo "[selftest-gate-degraded] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
