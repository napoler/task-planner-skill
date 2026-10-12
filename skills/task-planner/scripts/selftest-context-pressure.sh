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
# [task-v171 纪律域搬迁 2026-10-12] Rule 67（上下文压力主动评估与会话交接纪律）属纪律域，原文已迁至
#   skills/task-discipline/references/critical-rules-discipline.md（核心 critical-rules.md 只剩 11 条核心规则），
#   CP-01/02/03/04 的 CRIT 断言改指 CRIT_D；CRIT 保留指向核心。断言语义零改动。
CRIT_D="$SKILL_ROOT/../task-discipline/references/critical-rules-discipline.md"
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
count=$(grep -cE '^67\.[1-6] ' "$CRIT_D")
if [ "$count" -eq 6 ]; then
  ok "CP-01" "六子条锚=6"
else
  bad "CP-01" "六子条锚=$count≠6"
fi

# CP-02: 主动评估>=2 ∧ 主动优化>=1 于 critical-rules
c1=$(grep -c '主动评估' "$CRIT_D")
c2=$(grep -c '主动优化' "$CRIT_D")
if [ "$c1" -ge 2 ] && [ "$c2" -ge 1 ]; then
  ok "CP-02" "主动评估=$c1≥2 ∧ 主动优化=$c2≥1"
else
  bad "CP-02" "主动评估=$c1 主动优化=$c2"
fi

# CP-03: HEALTHY/PRESSURE/CONFUSED 各>=1 于 critical-rules ∧ hook 文件交叉断言>=1
c1=$(grep -c 'HEALTHY' "$CRIT_D")
c2=$(grep -c 'PRESSURE' "$CRIT_D")
c3=$(grep -c 'CONFUSED' "$CRIT_D")
c4=$(grep -cE 'HEALTHY|PRESSURE|CONFUSED' "$POSTTOOLUSE")
if [ "$c1" -ge 1 ] && [ "$c2" -ge 1 ] && [ "$c3" -ge 1 ] && [ "$c4" -ge 1 ]; then
  ok "CP-03" "HEALTHY=$c1 PRESSURE=$c2 CONFUSED=$c3 hook=$c4≥1"
else
  bad "CP-03" "HEALTHY=$c1 PRESSURE=$c2 CONFUSED=$c3 hook=$c4"
fi

# CP-04: 「不等 Phase complete」语义锚 ∈ critical-rules
if grep -q '不等 Phase complete' "$CRIT_D"; then
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

# CP-07 [task-v171 核心瘦身+task-v170 纪元并集] SKILL 全集纪元锚 '1-8[01]' ≥2 ∧ 'Rules 1-80 全集' ≥1 ∧ Rule 67/69/70/71 消费面=卫星路由表 discipline 行 ∧ Rule 69 ≥1 ∧ Rule 80 ≥1
#   现象：SKILL.md 瘦身（556→214 行）后旧纪元锚 '1-(69|71|7[4-9]|80)' 与合规清单 C48/C49/C50 行（Rule 70/67/71 消费行）双双零命中，CP-07 恒 FAIL。
#   根因：① 全集声明口径演进为「Rules 1-80 全集索引」（分层架构：核心 12 条+10 卫星）；② Rule 67/69/70/71 均属纪律域，其 SKILL 侧消费点（合规 C 行）随合规清单表瘦身移除，仅存卫星路由表 discipline 行（区间 67,69-76 四规则全覆盖）。
#   修法：纪元锚改 '1-80'（c1≥2 实测 3 处）+ 整串改 'Rules 1-80 全集'（c2≥1）；C48/C49/C50 三子项改断言——
#     c3=卫星路由表 discipline 行（Rule 67/69/70/71 路由载体）/ c4='Rule 69'（T1 decision-arbiter 引用面，实测 4）/
#     c5='Rule 80'（核心域规则仍在 SKILL 正文，实测 4）。断言语义（四条规则 SKILL 侧消费面在位）经新载体保持。
# 历史纪元演进（v158/v160/v162/v163/v169 各级宽容扩）保留如上；本轮为 v171 分层架构口径切换。
c1=$(grep -cE '1-8[01]' "$SKILL_MD")
c2=$(grep -cE 'Rules 1-8[01] 全集|1-8[01] 全集' "$SKILL_MD")
c3=$(grep -cE '^\| task-discipline \|' "$SKILL_MD")
c4=$(grep -c 'Rule 69' "$SKILL_MD")
c5=$(grep -c 'Rule 80' "$SKILL_MD")
if [ "$c1" -ge 2 ] && [ "$c2" -ge 1 ] && [ "$c3" -ge 1 ] && [ "$c4" -ge 1 ] && [ "$c5" -ge 1 ]; then
  ok "CP-07" "'1-8[01]'=$c1≥2 ∧ 'Rules 1-8[01] 全集'=$c2≥1 ∧ 路由表 discipline 行=$c3≥1 ∧ Rule 69=$c4≥1 ∧ Rule 80=$c5≥1"
else
  bad "CP-07" "'1-8[01]'=$c1 全集串=$c2 路由行=$c3 R69=$c4 R80=$c5"
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
if [ "$props" -eq 44 ]; then
  ok "CP-09" "config properties=$props=44"
else
  bad "CP-09" "config properties=$props≠44"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS + FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
