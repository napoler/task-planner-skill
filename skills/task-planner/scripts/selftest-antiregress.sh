#!/bin/bash
# selftest-antiregress.sh — Rule 111 进度产出基线防倒退接线机器守护
# 覆盖：111 唯一性/106.8 与 22.4f 在位/主模板双区块与净效果关键词/SKILL-init-check-complete 接线/variant 抽样指针
set -euo pipefail

PASS=0
FAIL=0

ok()   { PASS=$((PASS + 1)); echo "  [PASS] $1"; }
bad()  { FAIL=$((FAIL + 1)); echo "  [FAIL] $1" >&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT="$(cd "$SKILL_ROOT/../.." && pwd)"

CRIT="$SKILL_ROOT/references/critical-rules.md"
CRIT_D="$ROOT/skills/task-discipline/references/critical-rules-discipline.md"
CRIT_P="$ROOT/skills/task-dispatch/references/critical-rules-dispatch.md"
TPL="$SKILL_ROOT/templates/task_plan.md"
SKILL="$SKILL_ROOT/SKILL.md"
INIT="$SKILL_ROOT/scripts/init-session.sh"
CC="$SKILL_ROOT/scripts/check-complete.sh"

echo "=== selftest-antiregress: Rule 111 进度产出防倒退接线 ==="

	# AR-01: Rule 111 在 core 唯一，discipline/dispatch 中无同号标题
	# [2026-11-28 FIX-1 锚更新] 标题归一为 `### Rule 111`（原 `### 111`），同步断言形态（mode A）
	n_core="$(grep -Ec '^### Rule 111( |$)' "$CRIT" 2>/dev/null || true)"
	n_d="$(grep -Ec '^### Rule 111( |$)' "$CRIT_D" 2>/dev/null || true)"
	n_p="$(grep -Ec '^### Rule 111( |$)' "$CRIT_P" 2>/dev/null || true)"
	n_core="${n_core:-0}"; n_d="${n_d:-0}"; n_p="${n_p:-0}"
	if [ "$n_core" -eq 1 ] && [ "$n_d" -eq 0 ] && [ "$n_p" -eq 0 ]; then
	  ok "AR-01: Rule 111 标题唯一(core=1, discipline=$n_d, dispatch=$n_p)"
	else
	  bad "AR-01: Rule 111 唯一性不满足 (core=$n_core discipline=$n_d dispatch=$n_p)"
	fi

# AR-02: Rule 111 关键语义锚在 core
if grep -q '拆东墙补西墙' "$CRIT" && grep -q '净效果' "$CRIT" && grep -q '51\.15' "$CRIT" && grep -q '74\.7' "$CRIT" && grep -q 'PROGRESS-REGRESSION' "$CRIT"; then
  ok "AR-02: core Rule 111 语义锚齐全(拆东墙补西墙/净效果/51.15/74.7/PROGRESS-REGRESSION)"
else
  bad "AR-02: core Rule 111 语义锚缺失"
fi

# AR-03: 106.8 在 discipline 在位
if grep -q '106\.8' "$CRIT_D" && grep -q '进度产出防倒退' "$CRIT_D"; then
  ok "AR-03: discipline 含 106.8 进度产出防倒退回归门"
else
  bad "AR-03: discipline 缺 106.8 接线"
fi

# AR-04: 22.4f 在 dispatch 在位
if grep -q '22\.4f' "$CRIT_P" && grep -q '进度产出基线' "$CRIT_P"; then
  ok "AR-04: dispatch 含 22.4f 进度产出基线强制携带"
else
  bad "AR-04: dispatch 缺 22.4f 接线"
fi

# AR-05: 主模板双区块 + 净效果关键词
if grep -q '📦 进度产出基线' "$TPL" && grep -q '🛡 防倒退终检' "$TPL" && grep -q '净效果' "$TPL"; then
  ok "AR-05: 主模板含 📦进度产出基线/🛡防倒退终检/净效果"
else
  bad "AR-05: 主模板双区块或净效果关键词缺失"
fi

# AR-06: SKILL.md 两处触发点接线
if grep -q '进度产出基线登记（Rule 111）' "$SKILL" && grep -q '防倒退终检（Rule 111/106.8）' "$SKILL"; then
  ok "AR-06: SKILL.md 含计划期基线登记与交付前防倒退终检触发点"
else
  bad "AR-06: SKILL.md 接线缺失"
fi

# AR-07: init-session.sh 提醒接线
if grep -q '进度产出基线（Rule 111）' "$INIT"; then
  ok "AR-07: init-session.sh 含 Rule 111 提醒输出"
else
  bad "AR-07: init-session.sh 缺 Rule 111 提醒"
fi

# AR-08: check-complete.sh warn 接线
if grep -q '\[anti-regress\]' "$CC" && grep -q '防倒退终检' "$CC"; then
  ok "AR-08: check-complete.sh 含 anti-regress warn 检查"
else
  bad "AR-08: check-complete.sh 缺 anti-regress warn 检查"
fi

# AR-09: 3 个 variant 抽样指针
vhit=0
for vf in "$SKILL_ROOT/templates/variant/rule-enhancement-type.md" "$SKILL_ROOT/templates/variant/bugfix-type.md" "$SKILL_ROOT/templates/variant/refactor-type.md"; do
  if [ -f "$vf" ] && grep -q 'Rule 111' "$vf"; then
    vhit=$((vhit + 1))
  fi
done
if [ "$vhit" -ge 3 ]; then
  ok "AR-09: 3 个 variant 含 Rule 111 轻量指针 (hit=$vhit)"
else
  bad "AR-09: variant 指针不足 (hit=$vhit, expect>=3)"
fi

echo ""
printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS + FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
