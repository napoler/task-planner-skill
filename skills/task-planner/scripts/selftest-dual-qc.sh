#!/usr/bin/env bash
# selftest-dual-qc.sh — task-dualqc-20261104: Rule 103 双轮质检与同步完整性审护（DQ-01..DQ-14 静态守护）
# 守护定位：防 Rule 103 条款误删/半截落地、双向衔接遗漏、SKILL 接线残缺、统一收口序列缺口、模板承载缺失、契约保全破坏。
#   DQ-01 critical-rules-dispatch.md ^103.[1-8] 计数 = 8（cntE）
#   DQ-02 critical-rules-dispatch.md 含 ### 103 双轮质检与同步完整性审查 ≥1
#   DQ-03 critical-rules-dispatch.md 含 '同步完整性'≥1 ∧ '核对清单'≥2 ∧ '关联面'≥1
#   DQ-04 critical-rules-dispatch.md 含 '升一档'≥1 ∧ '封顶'≥1 ∧ 'decision-arbiter'≥1
#   DQ-05 critical-rules-dispatch.md 含 '只读不改'≥1 ∧ '不重做'≥1 ∧ '输出精简'≥1
#   DQ-06 critical-rules-dispatch.md 含 '复检升档衔接（Rule 103.4）' =1
#   DQ-07 verification-gate/references/critical-rules-verification.md 含 '衔接（Rule 103，task-dualqc-20261104）'=1 ∧ '84.7.2 为其先例面'=1
#   DQ-08 task-planner/SKILL.md 含纪元窗 '1-1[0-9][0-9]'≥3（宽容锚防纪元级联） ∧ '其余 8[0-9] 条'=2 ∧ 'Rule 103 双轮质检与同步完整性域'=1; [2026-11-05 task-subagent-markup-20261105] 演进注释追加在行 11 尾
#   DQ-09 task-planner/SKILL.md 含 '3h 双轮质检（Rule 103）'=1 ∧ '同步核对清单'≥2
#   DQ-10 task-planner/SKILL.md 含 '统一收口序列'=1 ∧ grep -A6 '统一收口序列' 输出含 'user-session-log'
#   DQ-11 templates/subagent_dispatch.md 含 '### 3b. 双轮质检与同步完整性'=1 ∧ '第一轮·自审'=1 ∧ '同步核对清单（103.6）'=1 ∧ 行首 '## 7. 返回格式' 仍在
#   DQ-12 templates/task_plan.md 含 '双轮质检与同步完整性声明'=1 ∧ '多文件变更集预判'=1
#   DQ-13 负断言：派发模板 '不得增删' ≥1（22.4b 八字段契约字面仍在）
#   DQ-14 scripts/selftest-registry.tsv 含 'selftest-dual-qc' ≥1
# 全 PASS exit 0; 任一 FAIL exit 1。只读，不修改任何文件。
# 输入: 无参数（断言对象路径自推导，范式同 selftest-anti-deferral.sh）
# 输出: stdout DQ-NN PASS/FAIL 逐行 + 末行 Total
# 依赖: bash+coreutils(grep/awk)

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TP_ROOT="$SKILL_ROOT"
DISPATCH_ROOT="$(cd "$TP_ROOT/../task-dispatch" && pwd)"
VG_ROOT="$(cd "$TP_ROOT/../verification-gate" && pwd)"

CR_DISPATCH="$DISPATCH_ROOT/references/critical-rules-dispatch.md"
CR_VERIF="$VG_ROOT/references/critical-rules-verification.md"
SKILLMD="$TP_ROOT/SKILL.md"
TPL_DISP="$TP_ROOT/templates/subagent_dispatch.md"
TPL_PLAN="$TP_ROOT/templates/task_plan.md"
REGISTRY="$SCRIPT_DIR/selftest-registry.tsv"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'DQ-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'DQ-%s FAIL %s\n' "$1" "$2"; }
cnt()  { grep -cF "$1" "$2" 2>/dev/null || true; }
cntE() { grep -cE "$1" "$2" 2>/dev/null || true; }

# DQ-01 ^103.[1-8] 计数 = 8
dq01="$(cntE '^103\.[1-8]' "$CR_DISPATCH")"
if [ "${dq01:-0}" -eq 8 ]; then ok 01 "^103.[1-8] 计数=${dq01:-0}"; else bad 01 "^103.[1-8] 计数=${dq01:-0} 应为 8"; fi

# DQ-02 ### 103 双轮质检与同步完整性审查 ≥1
dq02="$(cntE '^### 103 ' "$CR_DISPATCH")"
if [ "${dq02:-0}" -ge 1 ]; then ok 02 "### 103 段标题在位"; else bad 02 "### 103 段标题缺失"; fi

# DQ-03 '同步完整性'≥1 ∧ '核对清单'≥2 ∧ '关联面'≥1
dq03a="$(cnt '同步完整性' "$CR_DISPATCH")"
dq03b="$(cnt '核对清单' "$CR_DISPATCH")"
dq03c="$(cnt '关联面' "$CR_DISPATCH")"
if [ "${dq03a:-0}" -ge 1 ] && [ "${dq03b:-0}" -ge 2 ] && [ "${dq03c:-0}" -ge 1 ]; then
  ok 03 "同步完整性=${dq03a:-0}/核对清单=${dq03b:-0}/关联面=${dq03c:-0}"
else
  bad 03 "锚缺失（同步完整性=${dq03a:-0}/核对清单=${dq03b:-0}/关联面=${dq03c:-0}）"
fi

# DQ-04 '升一档'≥1 ∧ '封顶'≥1 ∧ 'decision-arbiter'≥1
dq04a="$(cnt '升一档' "$CR_DISPATCH")"
dq04b="$(cnt '封顶' "$CR_DISPATCH")"
dq04c="$(cnt 'decision-arbiter' "$CR_DISPATCH")"
if [ "${dq04a:-0}" -ge 1 ] && [ "${dq04b:-0}" -ge 1 ] && [ "${dq04c:-0}" -ge 1 ]; then
  ok 04 "升一档=${dq04a:-0}/封顶=${dq04b:-0}/decision-arbiter=${dq04c:-0}"
else
  bad 04 "锚缺失（升一档=${dq04a:-0}/封顶=${dq04b:-0}/decision-arbiter=${dq04c:-0}）"
fi

# DQ-05 '只读不改'≥1 ∧ '不重做'≥1 ∧ '输出精简'≥1
dq05a="$(cnt '只读不改' "$CR_DISPATCH")"
dq05b="$(cnt '不重做' "$CR_DISPATCH")"
dq05c="$(cnt '输出精简' "$CR_DISPATCH")"
if [ "${dq05a:-0}" -ge 1 ] && [ "${dq05b:-0}" -ge 1 ] && [ "${dq05c:-0}" -ge 1 ]; then
  ok 05 "只读不改=${dq05a:-0}/不重做=${dq05b:-0}/输出精简=${dq05c:-0}"
else
  bad 05 "锚缺失（只读不改=${dq05a:-0}/不重做=${dq05b:-0}/输出精简=${dq05c:-0}）"
fi

# DQ-06 '复检升档衔接（Rule 103.4）' =1
dq06="$(cnt '复检升档衔接（Rule 103.4）' "$CR_DISPATCH")"
if [ "${dq06:-0}" -eq 1 ]; then ok 06 "复检升档衔接（Rule 103.4）=${dq06:-0}"; else bad 06 "复检升档衔接（Rule 103.4）=${dq06:-0} 应为 1"; fi

# DQ-07 verification-gate
dq07a="$(cnt '衔接（Rule 103，task-dualqc-20261104）' "$CR_VERIF")"
dq07b="$(cnt '84.7.2 为其先例面' "$CR_VERIF")"
if [ "${dq07a:-0}" -ge 1 ] && [ "${dq07b:-0}" -ge 1 ]; then
  ok 07 "衔接（Rule 103）=${dq07a:-0}/84.7.2 为其先例面=${dq07b:-0}"
else
  bad 07 "锚缺失（衔接（Rule 103）=${dq07a:-0}/84.7.2 为其先例面=${dq07b:-0}）"
fi

# DQ-08 task-planner/SKILL.md
dq08a="$(cntE '1-1[0-9][0-9]' "$SKILLMD")"
dq08b="$(cntE '其余 8[0-9] 条' "$SKILLMD")"
dq08c="$(cnt 'Rule 103 双轮质检与同步完整性域' "$SKILLMD")"
if [ "${dq08a:-0}" -ge 3 ] && [ "${dq08b:-0}" -ge 2 ] && [ "${dq08c:-0}" -ge 1 ]; then
  ok 08 "纪元窗=${dq08a:-0}/其余 8[0-9] 条=${dq08b:-0}/Rule 103 双轮质检与同步完整性域=${dq08c:-0}"
else
  bad 08 "锚缺失（纪元窗=${dq08a:-0}/其余 8[0-9] 条=${dq08b:-0}/Rule 103 双轮质检与同步完整性域=${dq08c:-0}）"
fi

# DQ-09 task-planner/SKILL.md
dq09a="$(cnt '3h 双轮质检（Rule 103）' "$SKILLMD")"
dq09b="$(cnt '同步核对清单' "$SKILLMD")"
if [ "${dq09a:-0}" -ge 1 ] && [ "${dq09b:-0}" -ge 2 ]; then
  ok 09 "3h 双轮质检（Rule 103）=${dq09a:-0}/103.6 同步核对清单=${dq09b:-0}"
else
  bad 09 "锚缺失（3h 双轮质检（Rule 103）=${dq09a:-0}/103.6 同步核对清单=${dq09b:-0}）"
fi

# DQ-10 task-planner/SKILL.md
dq10a="$(cnt '统一收口序列' "$SKILLMD")"
dq10b="$(grep -A6 '统一收口序列' "$SKILLMD" 2>/dev/null | grep -c 'user-session-log' || true)"
if [ "${dq10a:-0}" -ge 1 ] && [ "${dq10b:-0}" -ge 1 ]; then
  ok 10 "统一收口序列=${dq10a:-0}/含 user-session-log"
else
  bad 10 "锚缺失（统一收口序列=${dq10a:-0}/user-session-log=${dq10b:-0}）"
fi

# DQ-11 templates/subagent_dispatch.md
dq11a="$(cnt '### 3b. 双轮质检与同步完整性' "$TPL_DISP")"
dq11b="$(cnt '第一轮·自审' "$TPL_DISP")"
dq11c="$(cnt '同步核对清单（103.6）' "$TPL_DISP")"
dq11d="$(grep -c '^## 7\. 返回格式' "$TPL_DISP" 2>/dev/null || true)"
if [ "${dq11a:-0}" -ge 1 ] && [ "${dq11b:-0}" -ge 1 ] && [ "${dq11c:-0}" -ge 1 ] && [ "${dq11d:-0}" -ge 1 ]; then
  ok 11 "双轮质检模板锚齐全/## 7. 返回格式在位"
else
  bad 11 "锚缺失（3b=${dq11a:-0}/第一轮·自审=${dq11b:-0}/同步核对清单（103.6）=${dq11c:-0}/## 7. 返回格式=${dq11d:-0}）"
fi

# DQ-12 templates/task_plan.md
dq12a="$(cnt '双轮质检与同步完整性声明' "$TPL_PLAN")"
dq12b="$(cnt '多文件变更集预判' "$TPL_PLAN")"
if [ "${dq12a:-0}" -ge 1 ] && [ "${dq12b:-0}" -ge 1 ]; then
  ok 12 "双轮质检声明区块/多文件变更集预判"
else
  bad 12 "锚缺失（双轮质检与同步完整性声明=${dq12a:-0}/多文件变更集预判=${dq12b:-0}）"
fi

# DQ-13 负断言：派发模板 '不得增删' ≥1
dq13="$(cnt '不得增删' "$TPL_DISP")"
if [ "${dq13:-0}" -ge 1 ]; then ok 13 "22.4b 八字段契约保全（不得增删）=${dq13:-0}"; else bad 13 "22.4b 契约保全缺失（不得增删=${dq13:-0}）"; fi

# DQ-14 registry
dq14="$(cnt 'selftest-dual-qc' "$REGISTRY")"
if [ "${dq14:-0}" -ge 1 ]; then ok 14 "registry 已登记 selftest-dual-qc"; else bad 14 "registry 未登记 selftest-dual-qc"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
