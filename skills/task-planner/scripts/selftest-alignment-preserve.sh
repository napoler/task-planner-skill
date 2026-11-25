#!/bin/bash
# selftest-alignment-preserve.sh — Rule 114 对齐任务内容保真铁律静态守护
# 覆盖：114 标题唯一性/114.1-114.5 五子条锚/core 路由表接线/判例锚/registry 自登记
# 判例：sess_830b75d5 把"参照物没有小说层"曲解为"小说层不合规范可排除"
set -euo pipefail

PASS=0
FAIL=0

ok()   { PASS=$((PASS + 1)); echo "  [PASS] $1"; }
bad()  { FAIL=$((FAIL + 1)); echo "  [FAIL] $1" >&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT="$(cd "$SKILL_ROOT/../.." && pwd)"

CRIT_D="$ROOT/skills/task-discipline/references/critical-rules-discipline.md"
CRIT="$SKILL_ROOT/references/critical-rules.md"
CRIT_P="$ROOT/skills/task-dispatch/references/critical-rules-dispatch.md"
REG="$SCRIPT_DIR/selftest-registry.tsv"

echo "=== selftest-alignment-preserve: Rule 114 对齐任务内容保真铁律 ==="

# AP-01: Rule 114 标题在 discipline 唯一，core/dispatch 无同号标题（防重复定义漂移）
n_d="$(grep -c '^114\. ' "$CRIT_D" 2>/dev/null || true)"
n_core="$(grep -c '^### 114 ' "$CRIT" 2>/dev/null || true)"
n_p="$(grep -c '^### 114 \|^114\. ' "$CRIT_P" 2>/dev/null || true)"
n_d="${n_d:-0}"; n_core="${n_core:-0}"; n_p="${n_p:-0}"
if [ "$n_d" -eq 1 ] && [ "$n_core" -eq 0 ] && [ "$n_p" -eq 0 ]; then
  ok "AP-01: Rule 114 标题唯一(discipline=1, core=$n_core, dispatch=$n_p)"
else
  bad "AP-01: Rule 114 标题唯一性不满足 (discipline=$n_d core=$n_core dispatch=$n_p)"
fi

# AP-02: 114.1-114.5 五子条各自的关键语义锚在位
sub_ok=1
grep -q '114\.1 \*\*参照规范=组织方式参照系，非内容白名单' "$CRIT_D" || sub_ok=0
grep -q '114\.2 \*\*差异三分型' "$CRIT_D" || sub_ok=0
grep -q '114\.3 \*\*显式登记与零丢失验证契约' "$CRIT_D" || sub_ok=0
grep -q '114\.4 \*\*与既有门的分工与叠加' "$CRIT_D" || sub_ok=0
grep -q '114\.5 \*\*禁止曲解口径与交付语义' "$CRIT_D" || sub_ok=0
if [ "$sub_ok" -eq 1 ]; then
  ok "AP-02: 114.1-114.5 五子条锚齐全"
else
  bad "AP-02: 114.x 子条锚缺失"
fi

# AP-03: 核心判据词在位（防条款被改成无牙齿的泛泛表述）
key_ok=1
for kw in '非内容白名单' '用户新增资产' '默认原样保留' '规范缺口' 'sha256sum' '逐字确认'; do
  grep -qF "$kw" "$CRIT_D" || key_ok=0
done
if [ "$key_ok" -eq 1 ]; then
  ok "AP-03: Rule 114 核心判据词齐全(白名单/新增资产/原样保留/规范缺口/哈希/逐字确认)"
else
  bad "AP-03: Rule 114 核心判据词缺失"
fi

# AP-04: 判例锚在位（禁把有来源的判例条款改成无据泛论）
if grep -qF 'sess_830b75d5' "$CRIT_D" && grep -qF '小说层' "$CRIT_D" && grep -qF '极品女钓手' "$CRIT_D"; then
  ok "AP-04: 判例锚在位(sess_830b75d5/小说层/极品女钓手)"
else
  bad "AP-04: 判例锚缺失"
fi

# AP-05: core 路由表 task-discipline 行含 114
# [2026-11-25 defect-fix] 原断言 grep '101,102,114' 字面连续串，与路由表 Rule 集合顺序强耦合；
# 路由表补全 105/106/107 后变为 '101,102,105,106,107,114' 导致本断言假 FAIL。
# 改为先取 task-discipline 路由行，再分别断言该行同时含 102 与 114（与相邻编号顺序解耦）。
_crit_td_line="$(grep '^\- \*\*task-discipline\*\*' "$CRIT" | head -1)"
if [ -n "$_crit_td_line" ] && printf '%s' "$_crit_td_line" | grep -qE '(^|[^0-9])114([^0-9]|$)' && printf '%s' "$_crit_td_line" | grep -qE '(^|[^0-9])102([^0-9]|$)'; then
  ok "AP-05: core 路由表 task-discipline 行含 114"
else
  bad "AP-05: core 路由表缺 114 接线"
fi

# AP-06: registry 自登记
if [ -f "$REG" ] && grep -q '^selftest-alignment-preserve\.sh	' "$REG"; then
  ok "AP-06: selftest-alignment-preserve.sh 已登记 registry"
else
  bad "AP-06: 本脚本未登记 selftest-registry.tsv"
fi

# [2026-11-25 defect-fix P1] AP-07: 入口 SKILL.md 的卫星路由表也须含 114（原 AP-05 只守 critical-rules.md，
# SKILL.md:224 路由表缺 114 导致从入口读规则看不到内容保真铁律——正是 Rule 114 判例要防的事故）。
# 断言 SKILL.md 的 task-discipline 路由行（含 critical-rules-discipline.md 路径）同时含 114。
if grep -q 'critical-rules-discipline.md' "$SKILL_ROOT/SKILL.md" && grep -q '105,106,107,114' "$SKILL_ROOT/SKILL.md"; then
  ok "AP-07: SKILL.md 卫星路由表 task-discipline 行含 114"
else
  bad "AP-07: SKILL.md 卫星路由表缺 114 接线"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS + FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
