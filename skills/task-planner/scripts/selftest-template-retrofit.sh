#!/bin/bash
# selftest-template-retrofit.sh — spec_version retrofit 扫描/改造 SOP 机制守护（S6）
# 覆盖：retrofit SOP 存在与关键锚/scan-template-spec.sh 行为级三条/kit 指针在位
set -euo pipefail

PASS=0
FAIL=0

ok()  { PASS=$((PASS + 1)); echo "  [PASS] $1"; }
bad() { FAIL=$((FAIL + 1)); echo "  [FAIL] $1" >&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT="$(cd "$SKILL_ROOT/../.." && pwd)"

SOP="$ROOT/skills/plan-template-kit/references/retrofit-sop.md"
SCAN="$ROOT/skills/plan-template-kit/scripts/scan-template-spec.sh"
KIT_SKILL="$ROOT/skills/plan-template-kit/SKILL.md"

echo "=== selftest-template-retrofit: spec_version retrofit SOP + scan ==="

# TR-01: SOP 存在
if [ -f "$SOP" ]; then
  ok "TR-01: retrofit-sop.md 存在"
else
  bad "TR-01: retrofit-sop.md 缺失: $SOP"
fi

# TR-02: SOP 六步流程锚
if [ -f "$SOP" ] && grep -Fq '六步流程' "$SOP" \
  && grep -Fq '1. **kit 规范版本递增**' "$SOP" \
  && grep -Fq '2. **注册表新增/修订原则行**' "$SOP" \
  && grep -Fq '3. **产出过时清单**' "$SOP" \
  && grep -Fq '4. **逐模板改造**' "$SOP" \
  && grep -Fq '5. **守卫复验**' "$SOP" \
  && grep -Fq '6. **登记与收口**' "$SOP"; then
  ok "TR-02: SOP 六步流程锚齐全(1-6)"
else
  bad "TR-02: SOP 六步流程锚缺失"
fi

# TR-03: SOP 版本历史表与判例锚
if [ -f "$SOP" ] && grep -Fq '版本历史' "$SOP" \
  && grep -Fq '| spec_version | 日期 | 变更 | 任务 |' "$SOP" \
  && grep -Fq 'task-antiregress-tplgov-20261120' "$SOP" \
  && grep -Fq 'task-variant-upgrade-20261113' "$SOP"; then
  ok "TR-03: SOP 版本历史表与 variant-upgrade 判例锚在位"
else
  bad "TR-03: SOP 版本历史表或判例锚缺失"
fi

# TR-04: scan 脚本存在且可执行
if [ -f "$SCAN" ] && [ -x "$SCAN" ]; then
  ok "TR-04: scan-template-spec.sh 存在且可执行"
else
  bad "TR-04: scan-template-spec.sh 缺失或不可执行: $SCAN"
fi

# TR-05: scan --target-spec 1 => OUTDATED: 0 且 rc=0（存量清零证据）
if [ -x "$SCAN" ]; then
  set +e
  out1="$(bash "$SCAN" --target-spec 1 2>&1)"
  rc1=$?
  set -e
  if [ $rc1 -eq 0 ] && printf '%s\n' "$out1" | grep -Fq 'OUTDATED: 0' && printf '%s\n' "$out1" | grep -Fq 'spec_version' && printf '%s\n' "$out1" | grep -Fq 'CURRENT-SPEC:'; then
    ok "TR-05: scan --target-spec 1 rc=0 且 OUTDATED: 0（含 spec_version/CURRENT-SPEC）"
  else
    bad "TR-05: scan --target-spec 1 异常 rc=$rc1 或输出缺关键行"
    printf '%s\n' "$out1" | sed -n '1,20p' >&2 || true
  fi
else
  bad "TR-05: 无法执行 scan --target-spec 1"
fi

# TR-06: scan --target-spec 2 => OUTDATED: 44 且 rc=1（清单功能/升级模拟）
if [ -x "$SCAN" ]; then
  set +e
  out2="$(bash "$SCAN" --target-spec 2 2>&1)"
  rc2=$?
  set -e
  if [ $rc2 -eq 1 ] && printf '%s\n' "$out2" | grep -Fq 'OUTDATED: 44' && printf '%s\n' "$out2" | grep -Fq 'spec_version'; then
    ok "TR-06: scan --target-spec 2 rc=1 且 OUTDATED: 44（升级模拟清单）"
  else
    bad "TR-06: scan --target-spec 2 异常 rc=$rc2 或 OUTDATED!=44"
    printf '%s\n' "$out2" | tail -n 10 >&2 || true
  fi
else
  bad "TR-06: 无法执行 scan --target-spec 2"
fi

# TR-07: scan 无参数 rc=0
if [ -x "$SCAN" ]; then
  set +e
  out0="$(bash "$SCAN" 2>&1)"
  rc0=$?
  set -e
  if [ $rc0 -eq 0 ] && printf '%s\n' "$out0" | grep -Fq 'OUTDATED: 0'; then
    ok "TR-07: scan 无参数 rc=0 且 OUTDATED: 0"
  else
    bad "TR-07: scan 无参数异常 rc=$rc0"
    printf '%s\n' "$out0" | tail -n 10 >&2 || true
  fi
else
  bad "TR-07: 无法执行 scan 无参数"
fi

# TR-08: kit 指针行在位（含 retrofit 与 spec_version）
if [ -f "$KIT_SKILL" ] && grep -Fq 'retrofit-sop.md' "$KIT_SKILL" && grep -Fq 'retrofit' "$KIT_SKILL" && grep -Fq 'spec_version' "$KIT_SKILL"; then
  ok "TR-08: kit SKILL.md 含 retrofit SOP 指针(含 retrofit 与 spec_version)"
else
  bad "TR-08: kit SKILL.md retrofit 指针或关键词缺失"
fi

echo ""
printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS + FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
