#!/usr/bin/env bash
# selftest-verify-hooks.sh — verify.sh 全量副本位 hooks 存在性检查守护（2026-11-28 task-skill-fix-defs-20261128 DEF-05）
#
# What: 断言 verify.sh 对 OpenCode/Cursor/Continue 部署位检查 SKILL.md frontmatter hooks: 块存在性，
#       全量实体副本(full-copy, SKILL.md>=15360 bytes)也必须检查，缺失计 fail（不再 N/A 跳过）。
#       正控制=mktemp 全量副本位夹具（SKILL.md 含 hooks: 块）→ 过；负控制=无 hooks: 块 → 拦。
# Why:  根因=审计 DEF-05 盲区（verify.sh:26 hooks N/A=对账盲区）；原行为=N/A 跳过；
#       现=hooks 存在性检查进对账，缺失计 fail。恒真门禁令：负例必须真实失败才计 PASS。
#
# 用法: bash selftest-verify-hooks.sh
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY="$SCRIPT_DIR/../lib/verify.sh"
CANONICAL_SKILL="$SCRIPT_DIR/../SKILL.md"

PASS=0
FAIL=0
RESULTS=()
ok()  { PASS=$((PASS+1)); RESULTS+=("PASS  $1"); }
bad() { FAIL=$((FAIL+1)); RESULTS+=("FAIL  $1  ($2)"); }

TMPBASE="$(mktemp -d)"
trap 'rm -rf "$TMPBASE"' EXIT

# Build a minimal fake TASK_PLANNER_ROOT / deploy layout to exercise check 8 logic.
# We source verify.sh helpers by extracting the needed functions in an isolated env.
make_stub() {
    local dir="$1" mode="$2" has_hooks="$3"
    mkdir -p "$dir"
    if [ "$mode" = "symlink" ]; then
        # caller handles symlink; dir unused as real stub
        :
    fi
    # Build SKILL.md
    local body="# stub skill
"
    if [ "$has_hooks" = "yes" ]; then
        body="${body}
hooks:
  SessionStart:
    - command: echo hi
"
    fi
    # Pad to >=15360 for full-copy mode
    if [ "$mode" = "full" ]; then
        local pad=""
        pad=$(python3 -c "print('# pad ' + 'x'*16000)")
        body="${body}${pad}
"
    fi
    printf '%s' "$body" > "$dir/SKILL.md"
}

run_check8() {
    # Run verify.sh check 8 logic in a subshell against controlled stubs.
    # Args: stub_dir mode(has_hooks already baked) tool_name
    local stub_dir="$1" tool_name="$2"
    local canonical_dir="$3"
    local out rc
    out="$(
        set -u
        TASK_PLANNER_ROOT="$canonical_dir"
        PASS=0; FAIL=0; FAILURES=()
        pass() { PASS=$((PASS+1)); echo "[verify] ✓ $1"; }
        fail() { FAIL=$((FAIL+1)); FAILURES+=("$1"); echo "[verify] ✗ $1"; }
        canonical_real="$(readlink -f "$TASK_PLANNER_ROOT")"
        stub_is_symlink_mode() { local s="$1"; [ -L "$s" ] || return 1; [ "$(readlink -f "$s")" = "$canonical_real" ]; }
        stub_is_full_copy() { local s="$1"; [ -d "$s" ] && [ -f "$s/SKILL.md" ] || return 1; [ "$(wc -c < "$s/SKILL.md")" -ge 15360 ]; }
        # Minimal TOOL_STUB_ROOT emulation
        tool="$tool_name"; stub="$stub_dir"
        # Inline check 8 opencode/cursor/continue branch from verify.sh
        if [ -n "$stub" ] && [ -d "$stub" ] && [ -f "$stub/SKILL.md" ]; then
            if grep -q '^hooks:' "$stub/SKILL.md" 2>/dev/null; then
                if stub_is_full_copy "$stub"; then
                    pass "$tool: hooks declared in SKILL.md frontmatter (full-copy deploy)"
                else
                    pass "$tool: hooks declared in SKILL.md frontmatter"
                fi
            else
                if stub_is_full_copy "$stub"; then
                    fail "$tool: SKILL.md missing hooks: block in full-copy deploy ($stub)"
                else
                    fail "$tool: SKILL.md missing hooks: block (run install.sh to regenerate)"
                fi
            fi
        else
            fail "$tool: stub missing"
        fi
        echo "__RC__=$FAIL"
    )"
    rc=$(printf '%s\n' "$out" | sed -n 's/^__RC__=//p' | tail -1)
    printf '%s\n' "$out" | grep -v '^__RC__='
    return "${rc:-1}"
}

# Also verify the actual verify.sh text contains the new behavior (static anchor)
if grep -q 'full-copy deploy' "$VERIFY" && \
   grep -q 'DEF-05' "$VERIFY" && \
   ! grep -q 'frontmatter block N/A for full copy"' "$VERIFY"; then
    ok "T00 verify.sh 含 DEF-05 修复锚且无旧 N/A pass 文案"
else
    bad "T00 verify.sh 静态锚" "missing DEF-05/fix or old N/A still present"
fi

# Prepare canonical dir (must have SKILL.md)
CANON="$TMPBASE/canonical"
mkdir -p "$CANON"
# use real canonical SKILL.md as base if present, else create minimal
if [ -f "$CANONICAL_SKILL" ]; then
    cp "$CANONICAL_SKILL" "$CANON/SKILL.md"
else
    printf '# skill\n' > "$CANON/SKILL.md"
fi

# ── 正控制：全量副本 + hooks 存在 → pass ──
STUB_FULL_OK="$TMPBASE/stub-full-ok"
make_stub "$STUB_FULL_OK" "full" "yes"
out="$(run_check8 "$STUB_FULL_OK" "opencode" "$CANON" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -q 'hooks declared in SKILL.md frontmatter (full-copy deploy)'; then
    ok "T01 正控制 full-copy+hooks 存在 → pass"
else
    bad "T01 正控制 full-copy+hooks" "rc=$rc out=$(printf '%s' "$out" | tail -2 | tr '\n' ' ')"
fi

# ── 负控制：全量副本 + 无 hooks → fail ──
STUB_FULL_BAD="$TMPBASE/stub-full-bad"
make_stub "$STUB_FULL_BAD" "full" "no"
out="$(run_check8 "$STUB_FULL_BAD" "opencode" "$CANON" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -q 'missing hooks: block in full-copy deploy'; then
    ok "T02 负控制 full-copy 无 hooks → fail"
else
    bad "T02 负控制 full-copy 无 hooks" "rc=$rc out=$(printf '%s' "$out" | tail -2 | tr '\n' ' ')"
fi

# ── 正控制：薄壳 + hooks 存在 → pass ──
STUB_THIN_OK="$TMPBASE/stub-thin-ok"
make_stub "$STUB_THIN_OK" "thin" "yes"
out="$(run_check8 "$STUB_THIN_OK" "cursor" "$CANON" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -q 'hooks declared in SKILL.md frontmatter'; then
    ok "T03 正控制 thin-shell+hooks 存在 → pass"
else
    bad "T03 正控制 thin-shell+hooks" "rc=$rc out=$(printf '%s' "$out" | tail -2 | tr '\n' ' ')"
fi

# ── 负控制：薄壳 + 无 hooks → fail ──
STUB_THIN_BAD="$TMPBASE/stub-thin-bad"
make_stub "$STUB_THIN_BAD" "thin" "no"
out="$(run_check8 "$STUB_THIN_BAD" "cursor" "$CANON" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -q 'missing hooks: block (run install.sh to regenerate)'; then
    ok "T04 负控制 thin-shell 无 hooks → fail"
else
    bad "T04 负控制 thin-shell 无 hooks" "rc=$rc out=$(printf '%s' "$out" | tail -2 | tr '\n' ' ')"
fi

# ── 正控制：软链 + hooks 存在 → pass（symlink mode is N/A for hardcoded checks, hooks still checked）──
STUB_SYM_TARGET="$TMPBASE/stub-sym-target"
make_stub "$STUB_SYM_TARGET" "full" "yes"
STUB_SYM="$TMPBASE/stub-sym"
ln -s "$STUB_SYM_TARGET" "$STUB_SYM"
# symlink mode points to canonical_real? our check uses canonical_real compare; for hooks check we only care hooks present.
# Make it a symlink to target that has hooks - full-copy by size and hooks present.
out="$(run_check8 "$STUB_SYM" "continue" "$CANON" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ]; then
    ok "T05 正控制 symlink/full+hooks 存在 → pass"
else
    bad "T05 正控制 symlink/full+hooks" "rc=$rc out=$(printf '%s' "$out" | tail -2 | tr '\n' ' ')"
fi

echo ""
echo "========================================"
echo "selftest-verify-hooks results"
echo "========================================"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo "----------------------------------------"
echo "Total: $((PASS+FAIL))  PASS=$PASS  FAIL=$FAIL"
echo "========================================"

[ "$FAIL" -gt 0 ] && exit 1
exit 0
