#!/usr/bin/env bash
# selftest-planctl-shim.sh — 机器门 JSON 双读 shim 外契约回归（SHIM-01..15）
#
# What（守护对象 + 运行方式）:
#   守护 check-vc-nonvacuous.sh / check-rvc-coverage.sh / check-plan-audit-gate.sh 的「双读 shim」改造：
#     · 存量计划（无 plan-state.json）→ 原正则判定路径，stdout 前缀 + rc 与改造前逐字一致；
#     · 新计划（有 plan-state.json）→ 转调 planctl.py check <name>，结果翻译为旧 stdout 前缀 + rc。
#   每组均断言前缀子串与 rc 0/1/2；另含 stderr 透传断言（check-complete.sh 明令不得 2>/dev/null）
#   与三处配套改动的静态锚（evidence 迁移注释 / init-session init / attest 缓存键）。
#   运行: bash scripts/selftest-planctl-shim.sh；逐行 "SHIM-NN PASS/FAIL ..."，末行汇总；全 PASS exit 0。
#   夹具: mktemp 于 /tmp，跑毕即删；只读本仓脚本，不修改任何项目文件。
#
# Why（回归防线）:
#   shim 的价值全在「外契约不变」——attest-plan.sh / check-complete.sh 按路径 + stdout 前缀 + rc
#   消费这三个门，任何前缀漂移或 fallback 丢失都会让全量回归炸。本测试把双读两条路径都钉死，
#   并显式验证诊断流（stderr）未被 shim 吞掉，防止「假绿」回归。
# 依赖: bash + python3（planctl.py）+ mktemp/grep/sed；无 jq。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PC="$SCRIPT_DIR/planctl.py"
VV="$SCRIPT_DIR/check-vc-nonvacuous.sh"
RC="$SCRIPT_DIR/check-rvc-coverage.sh"
AG="$SCRIPT_DIR/check-plan-audit-gate.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'SHIM-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'SHIM-%s FAIL %s\n' "$1" "$2"; }

TMPROOT="$(mktemp -d /tmp/planctl-shim-selftest.XXXXXX)"
trap 'rm -rf "$TMPROOT"' EXIT

# run <script> <plan-dir> — 执行门并置全局 _O(stdout)/_E(stderr)/_RC(rc)
run() {
    bash "$1" "$2" >"$TMPROOT/out" 2>"$TMPROOT/err"
    _RC=$?
    _O="$(<"$TMPROOT/out")"
    _E="$(<"$TMPROOT/err")"
}

# expect <id> <desc> <want_rc> <want_substr> [O|E] — 校验 rc + 指定流的关键子串
expect() {
    local id="$1" desc="$2" wrc="$3" wsub="$4" stream="${5:-O}" val
    [ "$stream" = "E" ] && val="$_E" || val="$_O"
    if [ "$_RC" -eq "$wrc" ] && printf '%s' "$val" | grep -qF -- "$wsub"; then
        ok "$id" "$desc"
    else
        bad "$id" "$desc (rc=$_RC want=$wrc; stdout=$_O; stderr=$_E; want_sub=$wsub)"
    fi
}

new_dir() { mktemp -d "$TMPROOT/plan.XXXXXX"; }

# ── 夹具: 存量计划（无 plan-state.json）──────────────────────────────────────
legacy_vc() {  # $1=dir $2=command
    mkdir -p "$1"
    printf '%s\n' '# Verification Contract' '' '- [ ] VC-1 检查项' \
        "**Verify command**: $2" > "$1/verification.md"
}
legacy_rvc() {
    mkdir -p "$1"
    printf '%s\n' '## 🎯 用户需求原文' '- **R1**: 需求一' '' \
        '## Verification Contract' '- [ ] VC-1 校验项' '| R1 | VC-1 | 覆盖 |' > "$1/task_plan.md"
}
legacy_audit() {  # $1=dir $2=tier声明(空=legacy-no-decl)
    mkdir -p "$1"
    printf '%s\n' "$2" > "$1/task_plan.md"
    printf '%s\n' '## [plan-audit-R1] 独立审计' \
        '- 轮次: R1 | 审计体: reviewer | 结论: **APPROVED**' \
        '- 问题清单:' '  - 无' > "$1/progress.md"
}

# ── 夹具: 新计划（JSON 权威源）───────────────────────────────────────────────
json_base() {
    mkdir -p "$1"
    python3 "$PC" init --plan-dir "$1" --task-id "$(basename "$1")" \
        --tier standard --lane L1 >/dev/null 2>&1 || return 1
    : > "$1/verification.md"             # shim 保留原输入契约：MD 视图须在位
    : > "$1/progress.md"
    printf 'plan_tier: standard\n' > "$1/task_plan.md"
}
json_vc() {  # $1=dir $2=command
    python3 "$PC" add --plan-dir "$1" --section vcs \
        --json "{\"id\":\"VC-1\",\"criterion\":\"x\",\"command\":\"$2\",\"status\":\"pending\",\"evidence\":\"\"}" \
        >/dev/null 2>&1
}
json_rvc() {
    python3 "$PC" add --plan-dir "$1" --section requirements \
        --json '{"id":"R1","text":"需求一","type":"目标","vc":["VC-1"]}' >/dev/null 2>&1
    json_vc "$1" 'grep -q foo bar.txt'
}
json_audit() {  # $1=dir $2=verdict
    python3 "$PC" audit-add --plan-dir "$1" --round 1 --verdict "$2" \
        --by tester --c 0 --i 0 >/dev/null 2>&1
}

# ── SHIM-01..04: vc-nonvacuous 双读 ──────────────────────────────────────────
D="$(new_dir)"; legacy_vc "$D" 'grep -q foo bar.txt'
run "$VV" "$D"; expect 01 "存量 vc（真实判定命令）→ rc0 + ✓ 前缀" 0 '[vc-nonvacuous] ✓'
rm -rf "$D"

D="$(new_dir)"; legacy_vc "$D" 'true'
run "$VV" "$D"; expect 02 "存量 vc（真空命令 true）→ rc1 + ✗ 前缀" 1 '[vc-nonvacuous] ✗'
rm -rf "$D"

D="$(new_dir)"; json_base "$D"; json_vc "$D" 'grep -q foo bar.txt'
run "$VV" "$D"; expect 03 "JSON vc（真实判定命令）→ rc0 + ✓ 1 条" 0 '✓ 1 条 VC 无真空命令'
rm -rf "$D"

D="$(new_dir)"; json_base "$D"; json_vc "$D" 'true'
run "$VV" "$D"; expect 04 "JSON vc（真空命令）→ rc1 + ✗ + planctl reason" 1 '条 VC 命令真空: VC-1'
rm -rf "$D"

# ── SHIM-05..07: rvc-coverage 双读 ───────────────────────────────────────────
D="$(new_dir)"; legacy_rvc "$D"
run "$RC" "$D"; expect 05 "存量 rvc（R1↔VC-1 映射完整）→ rc0 + ✓ 前缀" 0 '✓ R→VC 双向覆盖完整（R=1 VC=1 映射行=1）'
rm -rf "$D"

D="$(new_dir)"; json_base "$D"; json_rvc "$D"
run "$RC" "$D"; expect 06 "JSON rvc（映射完整）→ rc0 + ✓ 旧文案形状" 0 '✓ R→VC 双向覆盖完整（R=1 VC=1 映射行=0）'
rm -rf "$D"

D="$(new_dir)"; json_base "$D"
python3 "$PC" add --plan-dir "$D" --section requirements \
    --json '{"id":"R1","text":"需求一","type":"目标","vc":[]}' >/dev/null 2>&1
run "$RC" "$D"; expect 07 "JSON rvc（R 无 VC 映射）→ rc1 + ✗ 前缀" 1 '[rvc-coverage] ✗'
rm -rf "$D"

# ── SHIM-08..11: audit-gate 双读（lane/skip 预判保留）────────────────────────
D="$(new_dir)"; legacy_audit "$D" 'plan_tier: standard'
run "$AG" "$D"; expect 08 "存量 audit（留痕 APPROVED）→ rc0 + PASS 前缀" 0 '[audit-gate] PASS: 末段审计留痕 [plan-audit-R1] APPROVED'
rm -rf "$D"

D="$(new_dir)"; legacy_audit "$D" '# 无档位声明'
run "$AG" "$D"; expect 09 "存量 audit（无声明）→ rc0 + SKIP legacy-no-decl 保留" 0 'SKIP legacy-no-decl'
rm -rf "$D"

D="$(new_dir)"; json_base "$D"; json_audit "$D" APPROVED
run "$AG" "$D"; expect 10 "JSON audit（末轮 APPROVED）→ rc0 + PASS 前缀" 0 '[audit-gate] PASS: 末段审计留痕 [plan-audit-R1] APPROVED'
rm -rf "$D"

D="$(new_dir)"; json_base "$D"; json_audit "$D" REJECTED
run "$AG" "$D"; expect 11 "JSON audit（末轮 REJECTED）→ rc1 + FAIL 前缀" 1 '[audit-gate] FAIL:'
rm -rf "$D"

# ── SHIM-12: rc2 + stderr 透传（不裹 2>/dev/null）────────────────────────────
D="$(new_dir)"; json_base "$D"; printf '%s\n' '{ broken json' > "$D/plan-state.json"
run "$VV" "$D"
if [ "$_RC" -eq 2 ] && printf '%s' "$_E" | grep -qF 'planctl:' \
   && printf '%s' "$_E" | grep -qF '[vc-nonvacuous] ERROR:'; then
    ok 12 "JSON 输入异常 → rc2 + planctl stderr 原样透传 + ERROR 前缀"
else
    bad 12 "rc2/stderr 透传异常 (rc=$_RC; stdout=$_O; stderr=$_E)"
fi
rm -rf "$D"

# ── SHIM-13..15: 配套改动静态锚 ─────────────────────────────────────────────
if grep -qF 'JSON 化迁移中，本门暂保留正则判定' "$SCRIPT_DIR/check-evidence-anchor.sh"; then
    ok 13 "evidence 门仅加迁移注释（未改判定）"
else
    bad 13 "evidence 门迁移注释缺失"
fi
if grep -qF 'planctl.py" init' "$SCRIPT_DIR/init-session.sh" \
   && grep -qF '[init] plan-state.json initialized (JSON mode)' "$SCRIPT_DIR/init-session.sh"; then
    ok 14 "init-session 幂等 planctl init + JSON mode 提示在位"
else
    bad 14 "init-session planctl init 锚缺失"
fi
if grep -qF '_attest_state_key' "$SCRIPT_DIR/attest-plan.sh" \
   && grep -qF 'sha256sum "$plan_dir/plan-state.json"' "$SCRIPT_DIR/attest-plan.sh"; then
    ok 15 "attest 缓存键纳入 plan-state.json sha256"
else
    bad 15 "attest 缓存键 JSON 锚缺失"
fi

echo "----------------------------------------------------------------"
echo "[selftest-planctl-shim] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
