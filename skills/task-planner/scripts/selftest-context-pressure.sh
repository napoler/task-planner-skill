#!/usr/bin/env bash
# selftest-context-pressure.sh — Rule 67 上下文压力主动评估与会话交接纪律静态守护
# task-v152 P3-S5
# 2026-10-09 task-v152 新建（design-draft.md §1 67.6 断言面 + §4#7 registry 行范式）
# 断言 ID：CP-01 到 CP-09
# 全 PASS exit 0; 任一 FAIL exit 1
# 只读，不修改任何文件

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CRIT="$SKILL_ROOT/references/critical-rules.md"
CONFIG="$SKILL_ROOT/config.json"
REGISTRY="$SCRIPT_DIR/selftest-registry.tsv"
SKILL_MD="$SKILL_ROOT/SKILL.md"
HANDOFF="$SKILL_ROOT/templates/session-handoff.md"
POSTTOOLUSE="$SCRIPT_DIR/zcode-posttooluse.sh"

PASS=0
FAIL=0

ok() {
  echo "$1 PASS $2"
  PASS=$((PASS + 1))
}

bad() {
  echo "$1 FAIL $2"
  FAIL=$((FAIL + 1))
}

# CP-01: 六子条锚 critical-rules ^67.[1-6] =6
count=$(grep -cE '^67\.[1-6] ' "$CRIT")
if [ "$count" -eq 6 ]; then
  ok "CP-01" "六子条锚=6"
else
  bad "CP-01" "六子条锚=$count≠6"
fi

# CP-02: 主动评估>=2 ∧ 主动优化>=1 于 critical-rules
c1=$(grep -c '主动评估' "$CRIT")
c2=$(grep -c '主动优化' "$CRIT")
if [ "$c1" -ge 2 ] && [ "$c2" -ge 1 ]; then
  ok "CP-02" "主动评估=$c1≥2 ∧ 主动优化=$c2≥1"
else
  bad "CP-02" "主动评估=$c1 主动优化=$c2"
fi

# CP-03: HEALTHY/PRESSURE/CONFUSED 各>=1 于 critical-rules ∧ hook 文件交叉断言>=1
c1=$(grep -c 'HEALTHY' "$CRIT")
c2=$(grep -c 'PRESSURE' "$CRIT")
c3=$(grep -c 'CONFUSED' "$CRIT")
c4=$(grep -cE 'HEALTHY|PRESSURE|CONFUSED' "$POSTTOOLUSE")
if [ "$c1" -ge 1 ] && [ "$c2" -ge 1 ] && [ "$c3" -ge 1 ] && [ "$c4" -ge 1 ]; then
  ok "CP-03" "HEALTHY=$c1 PRESSURE=$c2 CONFUSED=$c3 hook=$c4≥1"
else
  bad "CP-03" "HEALTHY=$c1 PRESSURE=$c2 CONFUSED=$c3 hook=$c4"
fi

# CP-04: 「不等 Phase complete」语义锚 ∈ critical-rules
if grep -q '不等 Phase complete' "$CRIT"; then
  ok "CP-04" "「不等 Phase complete」语义锚存在"
else
  bad "CP-04" "「不等 Phase complete」语义锚缺失"
fi

# CP-05: session-handoff.md 五段标题各=1 ∧ session-catchup>=1 ∧ plan-resume>=1 ∧ 62.1>=1
c1=$(grep -c '^## 1\. 目标锚' "$HANDOFF")
c2=$(grep -c '^## 2\. 已完成与证据' "$HANDOFF")
c3=$(grep -c '^## 3\. 当前断点' "$HANDOFF")
c4=$(grep -c '^## 4\. 未决问题' "$HANDOFF")
c5=$(grep -c '^## 5\. 新会话恢复指令' "$HANDOFF")
c6=$(grep -c 'session-catchup' "$HANDOFF")
c7=$(grep -c 'plan-resume' "$HANDOFF")
c8=$(grep -c '62\.1' "$HANDOFF")
if [ "$c1" -eq 1 ] && [ "$c2" -eq 1 ] && [ "$c3" -eq 1 ] && [ "$c4" -eq 1 ] && [ "$c5" -eq 1 ] && [ "$c6" -ge 1 ] && [ "$c7" -ge 1 ] && [ "$c8" -ge 1 ]; then
  ok "CP-05" "五段各=1 ∧ session-catchup=$c6 ∧ plan-resume=$c7 ∧ 62.1=$c8"
else
  bad "CP-05" "五段=$c1/$c2/$c3/$c4/$c5 catchup=$c6 resume=$c7 62.1=$c8"
fi

# CP-06: bash -n zcode-posttooluse.sh 通过 ∧ TASK_PLANNER_CONTEXT_PRESSURE>=2 ∧ [context-pressure]>=1 ∧ emit 计数=常量基线
# hook emit 总数基线=12，本任务 hook 接线前后实测；变更须同步此常量与注释
emit_expect=12
bash -n "$POSTTOOLUSE" 2>/dev/null
bn_ok=$?
c1=$(grep -c 'TASK_PLANNER_CONTEXT_PRESSURE' "$POSTTOOLUSE")
c2=$(grep -c '\[context-pressure\]' "$POSTTOOLUSE")
emit_now=$(grep -c 'emit ' "$POSTTOOLUSE")
if [ "$bn_ok" -eq 0 ] && [ "$c1" -ge 2 ] && [ "$c2" -ge 1 ] && [ "$emit_now" -eq "$emit_expect" ]; then
  ok "CP-06" "bash -n OK ∧ env=$c1≥2 ∧ [context-pressure]=$c2 ∧ emit=$emit_now==$emit_expect"
else
  bad "CP-06" "bn=$bn_ok env=$c1 cp=$c2 emit=$emit_now/expect=$emit_expect"
fi

# CP-07: SKILL 短串 1-69=3 ∧ 整串 Critical Rules 1-69>=2 ∧ C48>=1（v155 Rule 70 行）∧ C49>=1（本任务 Rule 67 行，2026-10-10 三方并集后本任务行由 C46→C48→C49）
# [2026-10-10 task-v158 合并演进] 全集 1-69→1-71（Rule 71 落地）：计数锚宽容化 1-(69|71)；C50≥1（Rule 71 行）
# [2026-10-10 task-v160 合并级联] 全集 1-72 纪元：c2 锚宽容化 1-(69|71|72)
# [2026-10-10 task-v163 级联: SKILL 计数演进 1-72→1-75（Rule 75 落地）, c1 扩 1-(69|71|75)、c2 扩 1-(69|71|72|75)，判据 c1≥2/c2≥1 不减]
c1=$(grep -cE '1-(69|71|75)' "$SKILL_MD")
c2=$(grep -cE 'Critical Rules 1-(69|71|72|75)' "$SKILL_MD")
c3=$(grep -c 'C48' "$SKILL_MD")
c4=$(grep -c 'C49' "$SKILL_MD")
c5=$(grep -c 'C50' "$SKILL_MD")
if [ "$c1" -ge 2 ] && [ "$c2" -ge 1 ] && [ "$c3" -ge 1 ] && [ "$c4" -ge 1 ] && [ "$c5" -ge 1 ]; then
  ok "CP-07" "1-(69|71|75)=$c1≥2 ∧ CR1-(69|71|72|75)=$c2≥1 ∧ C48=$c3≥1 ∧ C49=$c4≥1 ∧ C50=$c5≥1"
else
  bad "CP-07" "1-(69|71|75)=$c1 CR=$c2 C48=$c3 C49=$c4 C50=$c5"
fi

# CP-08: registry 含 selftest-context-pressure（并集口径）∧ TAB 4 列
# [2026-10-10 task-v152 合并并集适配] 末行口径→含口径：并行合并后 registry 尾行为其他 selftest 行，
# 末行假设被跨任务打破；修法=含数据行同义断言（grep -q 全表匹配），与 G-07 演进同构。
if grep -q 'selftest-context-pressure' "$REGISTRY"; then
  cols=$(grep 'selftest-context-pressure' "$REGISTRY" | awk -F'\t' '{print NF}' | head -1)
  if [ "$cols" -eq 4 ]; then
    ok "CP-08" "registry 含 selftest-context-pressure ∧ 4 列"
  else
    bad "CP-08" "registry selftest-context-pressure 行列数=$cols≠4"
  fi
else
  bad "CP-08" "registry 不含 selftest-context-pressure"
fi

# CP-09: jq '.properties|length' config.json =42
props=$(jq '.properties|length' "$CONFIG" 2>/dev/null)
if [ "$props" -eq 42 ]; then
  ok "CP-09" "config properties=$props=42"
else
  bad "CP-09" "config properties=$props≠42"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS + FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
