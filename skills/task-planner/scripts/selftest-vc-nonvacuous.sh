#!/usr/bin/env bash
# selftest-vc-nonvacuous.sh — P-02「VC 非真空命令检查」行为级 + 静态守护（VNC-01..VNC-13）
#
# What（守护对象 + 运行方式）:
#   守护 P-02 全链落点，13 条编号断言，分三组：
#     · 静态锚（VNC-01..VNC-04）: check-vc-nonvacuous.sh 在位 + bash -n 通过（VNC-01）
#       + 头注 What/Why 双层（Rule 45，VNC-02）+ [vc-nonvacuous] 输出前缀与 exit 0/1/2
#       语义锚（VNC-03）+ registry 自登记 ≥1（VNC-04）。
#     · 负例（mktemp 夹具，VC 命令=真空命令，VNC-05..VNC-10）:
#         VNC-05 true / VNC-06 echo ok / VNC-07 ":" / VNC-08 printf 空串 /
#         VNC-09 cat /dev/null / VNC-10 变量赋值前缀 FOO=bar true → 均 rc=1
#         （前缀剥离后主体仍真空）。
#     · 输入契约 + 正例:
#         VNC-11 无参调用 → rc=2；VNC-12 plan-dir 缺失 / 空目录（无 verification.md）→ rc=2；
#         VNC-13 混合链正例（echo x | grep -q x，管道尾有真实判定命令 → rc=0 不误拦；
#         单命令真实判定如 grep -q foo bar.md 走同一 judge 路径，同族覆盖）。
#   运行方式: bash scripts/selftest-vc-nonvacuous.sh；逐行打印 "VNC-NN PASS/FAIL <说明>"，
#   末行 "Total: PASS=x FAIL=y"；全 PASS exit 0，任一 FAIL exit 1。夹具全部 mktemp 于 /tmp 并跑毕即删。
#
# Why（机制锚）:
#   根因（P-02 终审意见）=Rule 84.1 只查 VC 命令「非占位」不查「非真空」—— true/echo ok/
#   ":"/printf 空串 等真空命令恒 exit 0，能通过非占位判定却零检查力。P-02 静态拦截该面；
#   （本头注禁用反引号：bash 词法器在注释行内仍解析反引号做嵌套配对，奇数反引号会导致
#    「unexpected EOF while looking for matching backtick」，实测踩坑。）
#   本脚本锁两件事：① 判定器行为（负例必拦、正例不误伤——防把痛点换成误报面）；
#   ② 静态契约（前缀/exit 语义/registry 登记——防守护自身被误删或漂移）。
#   断言面只锁 P-02 新增锚，不触碰既有 selftest 断言行（Rule 36.5 纯增量）。
# 依赖: bash + awk + grep（无 jq / 无 python，与判定器同口径）。只读仓库 + 写 /tmp 夹具。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VV="$SCRIPT_DIR/check-vc-nonvacuous.sh"
REG="$SCRIPT_DIR/selftest-registry.tsv"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'VNC-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'VNC-%s FAIL %s\n' "$1" "$2"; }

# ── 夹具构造器: 生成 verification.md（单条 VC，命令=参数）────────────────────
make_fix() {
    local d="$1" cmd="$2"
    mkdir -p "$d"
    printf '%s\n' \
        '# Verification Contract (P-02 selftest fixture)' \
        '' \
        "- [ ] VC-1: $cmd" \
        "  **Verify command**: $cmd" \
        '  **Pass criteria**: PASS/FAIL' > "$d/verification.md"
}

# ── VNC-01 判定器在位 + bash -n ─────────────────────────────────────────────
if [ -f "$VV" ] && bash -n "$VV" 2>/dev/null; then
    ok 01 "check-vc-nonvacuous.sh 在位 + bash -n 通过"
else
    # Why 先取值再拼串：双引号消息内嵌套 $( ) 且相邻全角括号会触发 bash 5.2 解析器
    # 「unexpected EOF while looking for matching "」（本机实测踩坑，拆掉嵌套即可）
    _vp=$([ -f "$VV" ] && echo yes || echo no)
    _ve=$([ -x "$VV" ] && echo yes || echo no)
    bad 01 "check-vc-nonvacuous.sh 缺失或语法错 (在位=${_vp} 可执行=${_ve})"
fi

# ── VNC-02 头注 What/Why 双层（Rule 45）─────────────────────────────────────
if grep -q '^# What' "$VV" 2>/dev/null && grep -q '^# Why' "$VV" 2>/dev/null; then
    ok 02 "头注 What + Why 双层注释齐备（Rule 45）"
else
    bad 02 "头注缺 What 或 Why（Rule 45 双层注释不齐）"
fi

# ── VNC-03 输出前缀 + exit 语义锚（静态锚）──────────────────────────────────
if grep -q '\[vc-nonvacuous\] ✗' "$VV" && grep -qE '^[[:space:]]*exit 1' "$VV" \
   && grep -qE '^[[:space:]]*exit 0' "$VV" && grep -qE '^[[:space:]]*exit 2' "$VV"; then
    ok 03 "输出前缀 [vc-nonvacuous] ✗ + exit 0/1/2 语义锚在位"
else
    bad 03 "输出前缀或 exit 语义锚缺失（门控输出契约不齐）"
fi

# ── VNC-04 registry 自登记 ≥1 ───────────────────────────────────────────────
_n="$(grep -c 'selftest-vc-nonvacuous.sh' "$REG" 2>/dev/null || true)"
if [ "${_n:-0}" -ge 1 ]; then
    ok 04 "selftest-registry.tsv 含本脚本登记行（n=${_n:-0}）"
else
    bad 04 "selftest-registry.tsv 缺 selftest-vc-nonvacuous.sh 登记行（回归不运行本守护；P-02 验收时若该行未集中登记，本条 FAIL 属预期）"
fi

# ── 负例组: 真空命令 → rc=1（逐形态覆盖）────────────────────────────────────
# VNC-05 `true`
F5="$(mktemp -d "${TMPDIR:-/tmp}/vnc5.XXXXXX")"; make_fix "$F5" 'true'
_o="$(bash "$VV" "$F5" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q 'VC-1 真空命令'; then
    ok 05 "负例 命令=true → rc=1 + VC-1 真空命令命中行"
else
    bad 05 "true 未被拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F5"
# VNC-06 `echo ok`
F6="$(mktemp -d "${TMPDIR:-/tmp}/vnc6.XXXXXX")"; make_fix "$F6" 'echo ok'
_o="$(bash "$VV" "$F6" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ]; then
    ok 06 "负例 命令=echo ok → rc=1"
else
    bad 06 "echo ok 未被拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F6"
# VNC-07 `:`
F7="$(mktemp -d "${TMPDIR:-/tmp}/vnc7.XXXXXX")"; make_fix "$F7" ':'
_o="$(bash "$VV" "$F7" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ]; then
    ok 07 "负例 命令=: → rc=1"
else
    bad 07 ": 未被拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F7"
# VNC-08 `printf ''`
F8="$(mktemp -d "${TMPDIR:-/tmp}/vnc8.XXXXXX")"; make_fix "$F8" "printf ''"
_o="$(bash "$VV" "$F8" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ]; then
    ok 08 "负例 命令=printf '' → rc=1"
else
    bad 08 "printf '' 未被拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F8"
# VNC-09 `cat /dev/null`
F9="$(mktemp -d "${TMPDIR:-/tmp}/vnc9.XXXXXX")"; make_fix "$F9" 'cat /dev/null'
_o="$(bash "$VV" "$F9" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ]; then
    ok 09 "负例 命令=cat /dev/null → rc=1"
else
    bad 09 "cat /dev/null 未被拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F9"
# VNC-10 变量赋值前缀 `FOO=bar true`
F10="$(mktemp -d "${TMPDIR:-/tmp}/vnc10.XXXXXX")"; make_fix "$F10" 'FOO=bar true'
_o="$(bash "$VV" "$F10" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ]; then
    ok 10 "负例 命令=FOO=bar true（赋值前缀）→ rc=1（前缀剥离后主体真空）"
else
    bad 10 "FOO=bar true 未被拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F10"

# ── VNC-11 无参调用 → rc=2（plan-dir 缺失契约）─────────────────────────────
bash "$VV" >/dev/null 2>&1; _rc=$?
if [ "$_rc" -eq 2 ]; then
    ok 11 "无参调用 → rc=2（plan-dir 缺失契约）"
else
    bad 11 "无参调用 rc=$_rc（应 2）"
fi

# ── VNC-12 plan-dir 缺失 / 空目录无 verification.md → rc=2 ─────────────────
MISSING="/tmp/vnc-definitely-not-exist-$$"
bash "$VV" "$MISSING" >/dev/null 2>&1; _rc=$?
E="$(mktemp -d "${TMPDIR:-/tmp}/vnc12.XXXXXX")"
bash "$VV" "$E" >/dev/null 2>&1; _rc2=$?
rm -rf "$E"
if [ "$_rc" -eq 2 ] && [ "$_rc2" -eq 2 ]; then
    ok 12 "plan-dir 缺失 rc=2 + 空目录（无 verification.md）rc=2"
else
    bad 12 "exit 2 契约异常: 缺 dir rc=$_rc（应 2）空 dir rc=$_rc2（应 2）"
fi

# ── VNC-13 混合链正例: 首段真空 + 管道尾真实判定 → rc=0（不误拦）───────────
F13="$(mktemp -d "${TMPDIR:-/tmp}/vnc13.XXXXXX")"; make_fix "$F13" 'echo x | grep -q x'
_o="$(bash "$VV" "$F13" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ]; then
    ok 13 "正例 混合链 echo x | grep -q x（管道尾真实判定）→ rc=0（不误拦）"
else
    bad 13 "混合链被误拦: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F13"

echo "----------------------------------------------------------------"
echo "[selftest-vc-nonvacuous] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
