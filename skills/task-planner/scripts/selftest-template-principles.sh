#!/bin/bash
# selftest-template-principles.sh — 原则→模板区块注册表与覆盖守卫机器守护（S5）
# 覆盖：注册表存在与关键词/守卫脚本/--selftest-smoke rc=0 与正反夹具行为/kit 指针(含双参照)
set -euo pipefail

PASS=0
FAIL=0

ok()  { PASS=$((PASS + 1)); echo "  [PASS] $1"; }
bad() { FAIL=$((FAIL + 1)); echo "  [FAIL] $1" >&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT="$(cd "$SKILL_ROOT/../.." && pwd)"

REGISTRY="$ROOT/skills/plan-template-kit/references/principle-template-registry.md"
GUARD="$SKILL_ROOT/scripts/check-template-principles.sh"
KIT_SKILL="$ROOT/skills/plan-template-kit/SKILL.md"

echo "=== selftest-template-principles: 原则注册表 + 覆盖守卫 ==="

# TP-01: 注册表存在
if [ -f "$REGISTRY" ]; then
  ok "TP-01: 注册表文件存在(principle-template-registry.md)"
else
  bad "TP-01: 注册表文件缺失: $REGISTRY"
fi

# TP-02: 注册表关键词覆盖（防倒退/验证/证据/理解迭代/双参照/spec_version）
kw_ok=1
for kw in 防倒退 验证 证据 理解迭代 双参照 spec_version; do
  if [ -f "$REGISTRY" ] && grep -Fq -- "$kw" "$REGISTRY"; then
    :
  else
    kw_ok=0
    bad "TP-02: 注册表缺关键词[$kw]"
  fi
done
if [ "$kw_ok" -eq 1 ]; then
  ok "TP-02: 注册表含必备关键词(防倒退/验证/证据/理解迭代/双参照/spec_version)"
fi

# TP-03: 守卫脚本存在且可执行
if [ -f "$GUARD" ] && [ -x "$GUARD" ]; then
  ok "TP-03: 守卫脚本存在且可执行(check-template-principles.sh)"
else
  bad "TP-03: 守卫脚本缺失或不可执行: $GUARD"
fi

# TP-04: 守卫 --selftest-smoke rc=0 且含 PASS
tmp_smoke="/tmp/_tp_smoke_selftest.$$"
if [ -x "$GUARD" ]; then
  set +e
  bash "$GUARD" --selftest-smoke >"$tmp_smoke" 2>&1
  rc=$?
  set -e
  if [ $rc -eq 0 ] && grep -q "SELFTEST-SMOKE PASS" "$tmp_smoke"; then
    ok "TP-04: 守卫 --selftest-smoke rc=0 且输出 SELFTEST-SMOKE PASS"
  else
    bad "TP-04: 守卫 --selftest-smoke 异常 rc=$rc"
    sed -n '1,40p' "$tmp_smoke" >&2 || true
  fi
else
  bad "TP-04: 无法执行守卫 --selftest-smoke（脚本不可执行）"
fi

# TP-05: 正反夹具行为级（缺块 FAIL / 全齐 PASS）——由 smoke 内 case 断言并输出
if [ -f "$tmp_smoke" ] && grep -q "\[smoke\]\[PASS\] all-ok" "$tmp_smoke" && grep -q "\[smoke\]\[PASS\] missing-block" "$tmp_smoke"; then
  ok "TP-05: 正反夹具行为级通过(all-ok PASS / missing-block FAIL)"
else
  bad "TP-05: 正反夹具行为级证据缺失（期望 smoke 输出 all-ok 与 missing-block PASS）"
fi
rm -f "$tmp_smoke"

# TP-06: kit 指针行（注册表路径 + 派生铁律含“双参照”）
if [ -f "$KIT_SKILL" ] && grep -Fq 'references/principle-template-registry.md' "$KIT_SKILL" && grep -Fq '双参照' "$KIT_SKILL"; then
  ok "TP-06: plan-template-kit SKILL.md 含注册表指针与派生铁律(双参照)"
else
  bad "TP-06: kit SKILL.md 指针或双参照关键词缺失"
fi

# TP-07: 派生铁律与 spec_version 在注册表显式可 grep
if [ -f "$REGISTRY" ] && grep -Fq '派生铁律' "$REGISTRY" && grep -Fq 'spec_version=1' "$REGISTRY" && grep -Fq '二级派生' "$REGISTRY"; then
  ok "TP-07: 注册表含 派生铁律/二级派生/spec_version=1"
else
  bad "TP-07: 注册表派生铁律或 spec_version=1 缺失"
fi

echo ""
printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS + FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
