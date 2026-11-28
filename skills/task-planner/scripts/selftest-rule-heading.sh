#!/usr/bin/env bash
# selftest-rule-heading.sh — 核心规则标题归一守护（2026-11-28 task-skill-fix-defs-20261128 DEF-06）
#
# What: 断言 critical-rules.md 核心规则标题统一为 `### Rule N ...` 形态：
#       grep -c '^### Rule' == 20 ∧ 零 `### <裸数字>` 残留 ∧ 零 `## Rule` h2 形态残留。
#       正控制=归一后真实文件过；负控制=mktemp 夹具（含 ### 99 裸数字标题）→ 判定拦截。
# Why:  审计 DEF-06 指出标题三形态混用（### N / ## Rule N / ### Rule N）导致计数与锚点漂移；
#       归一后用机器守护防回潮。恒真门禁令：负例必须真实失败才计 PASS。
#
# 用法: bash selftest-rule-heading.sh
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CR="$SCRIPT_DIR/../references/critical-rules.md"

PASS=0
FAIL=0
RESULTS=()

ok()   { PASS=$(( PASS + 1 )); RESULTS+=("PASS  $1"); }
bad()  { FAIL=$(( FAIL + 1 )); RESULTS+=("FAIL  $1  ($2)"); }

check_file() {
    local file="$1" label="$2" expect_count="$3" expect_rc="$4"
    local h3_rule bare_h3 h2_rule rc
    h3_rule=$(grep -c '^### Rule ' "$file" 2>/dev/null || true)
    bare_h3=$(grep -cE '^### [0-9]+[[:space:]（(]' "$file" 2>/dev/null || true)
    h2_rule=$(grep -c '^## Rule ' "$file" 2>/dev/null || true)
    rc=0
    if [ "$h3_rule" -ne "$expect_count" ]; then rc=1; fi
    if [ "$bare_h3" -ne 0 ]; then rc=1; fi
    if [ "$h2_rule" -ne 0 ]; then rc=1; fi

    if [ "$expect_rc" -eq 0 ]; then
        if [ "$rc" -eq 0 ]; then
            ok "$label count==${expect_count} bare==0 h2==0"
        else
            bad "$label" "h3_rule=$h3_rule expect=$expect_count bare_h3=$bare_h3 h2_rule=$h2_rule"
        fi
    else
        # negative control: expect detection (rc!=0 means guard would catch)
        if [ "$rc" -ne 0 ]; then
            ok "$label negative-detected (h3_rule=$h3_rule bare_h3=$bare_h3 h2_rule=$h2_rule)"
        else
            bad "$label" "expected detection but file looked clean"
        fi
    fi
}

# ── 正控制：真实 critical-rules.md ──
if [ -f "$CR" ]; then
    check_file "$CR" "T01 正控制 critical-rules.md" 20 0
else
    bad "T01 正控制 critical-rules.md" "missing $CR"
fi

# ── 负控制：mktemp 夹具含裸数字标题 ──
TMPDIR_FIX="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_FIX"' EXIT

# 夹具基于真实文件，但注入一个裸 ### 99 标题（应被拦截）
FIX_BAD="$TMPDIR_FIX/bad.md"
cp "$CR" "$FIX_BAD"
printf '\n### 99 负控制裸标题\n\n正文\n' >> "$FIX_BAD"
check_file "$FIX_BAD" "T02 负控制 含### 99裸标题应拦" 20 1

# 负控制2：含 ## Rule 80 h2 形态（应被拦截）
FIX_H2="$TMPDIR_FIX/bad_h2.md"
cp "$CR" "$FIX_H2"
# 把第一个 ### Rule 替换为 ## Rule 来构造 h2 违规
python3 - "$FIX_H2" <<'PY'
import sys
p=sys.argv[1]
s=open(p).read()
s=s.replace('### Rule 1 先规划，再执行', '## Rule 1 先规划，再执行', 1)
open(p,'w').write(s)
PY
check_file "$FIX_H2" "T03 负控制 含## Rule h2应拦" 19 1

# 负控制3：核心 Rule 数不足（删掉一条）
FIX_MISS="$TMPDIR_FIX/bad_miss.md"
grep -v '^### Rule 117 ' "$CR" > "$FIX_MISS"
check_file "$FIX_MISS" "T04 负控制 核心Rule数不足应拦" 20 1

echo ""
echo "========================================"
echo "selftest-rule-heading results"
echo "========================================"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo "----------------------------------------"
echo "Total: $((PASS+FAIL))  PASS=$PASS  FAIL=$FAIL"
echo "========================================"

[ "$FAIL" -gt 0 ] && exit 1
exit 0
