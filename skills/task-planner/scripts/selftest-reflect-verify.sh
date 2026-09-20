#!/usr/bin/env bash
# selftest-reflect-verify.sh — task-v074 P4-S2: Rule 33 解决→反思→验证迭代循环静态守护
# 守护（门控+指针范式, 33.2/33.3 执行为 LLM 行为面无脚本可测, 仅防条款误删）:
#   RV-01 critical-rules.md 含 Rule 33 头（### 33 解决→反思→验证迭代循环）
#   RV-02 含 33.1 触发条款（语义锚点: 触发）
#   RV-03 含 33.2 反思四问条款（语义锚点: 反思四问）
#   RV-04 含 33.3 独立验证条款, 逐字含 `- [reflect] ` 锚（REFLECT-GATE 机器判定锚, 33.3 写死格式）
#   RV-05 含 33.4 迭代边界条款（语义锚点: ≤3 轮 + Rule 22.3 升档）
#   RV-06 含 33.5 沉淀联动条款（语义锚点: notepad「What Worked」联动）
#   RV-07 含 33.6 机制条款（语义锚点: reflect_verify_enforce + REFLECT-GATE + selftest-reflect-verify）
#   RV-08 config.json reflect_verify_enforce 键（默认 warn, enum 三档 enforce/warn/off）
#   RV-09 check-complete.sh 含 REFLECT-GATE 锚点（REFLECT-GATE / TASK_PLANNER_REFLECT_VERIFY_ENFORCE / - [reflect] 行计数 / SKIPPED 分支）
#   RV-10 SKILL.md 含 'Rules 1-3[56]' 宽容锚索引行（Rule 33/34/35/36/37 联动；[2026-09-17 task-v079] 严格 '1-35'→宽容 1-3[56]；[2026-09-20 task-v085] Rule 37 级联 1-3[56]→1-3[5-7]）
#   RV-11 SKILL.md 检查清单含 C21 行（Rule 33 [reflect] 反思+验证两行）
#   RV-12 SKILL.md 含「解决后反思-验证循环」联动段
# 12 断言全 PASS exit 0; 任一 FAIL exit 1。只读, 不修改任何文件。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
CONFIG="$SKILL_ROOT/config.json"
CHK="$SKILL_ROOT/scripts/check-complete.sh"
SKILL="$SKILL_ROOT/SKILL.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'RV-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'RV-%s FAIL %s\n' "$1" "$2"; }

# RV-01
if grep -q '^### 33 解决→反思→验证迭代循环' "$CRIT"; then ok 01 "Rule 33 头"; else bad 01 "Rule 33 头缺失"; fi
# RV-02
if grep '^33\.1 ' "$CRIT" | grep -q '触发'; then ok 02 "33.1 触发"; else bad 02 "33.1 触发缺失"; fi
# RV-03
if grep '^33\.2 ' "$CRIT" | grep -q '反思四问'; then ok 03 "33.2 反思四问"; else bad 03 "33.2 反思四问缺失"; fi
# RV-04（33.3 写死落盘格式「前缀必须逐字为 - [reflect] 」;md 正文为反引号包裹变体, 锚=逐字 [reflect] 字样）
if grep '^33\.3 ' "$CRIT" | grep -qF '[reflect]'; then ok 04 "33.3 逐字 [reflect] 锚"; else bad 04 "33.3 缺逐字 [reflect] 锚"; fi
# RV-05
if grep '^33\.4 ' "$CRIT" | grep -q '≤3 轮' && grep '^33\.4 ' "$CRIT" | grep -q 'Rule 22.3'; then ok 05 "33.4 迭代边界（≤3 轮+升档）"; else bad 05 "33.4 迭代边界缺失"; fi
# RV-06
if grep '^33\.5 ' "$CRIT" | grep -q 'What Worked' && grep '^33\.5 ' "$CRIT" | grep -q 'notepad'; then ok 06 "33.5 notepad What Worked 联动"; else bad 06 "33.5 沉淀联动缺失"; fi
# RV-07
if grep '^33\.6 ' "$CRIT" | grep -q 'reflect_verify_enforce' && grep '^33\.6 ' "$CRIT" | grep -q 'REFLECT-GATE' && grep '^33\.6 ' "$CRIT" | grep -q 'selftest-reflect-verify'; then ok 07 "33.6 机制（开关键+REFLECT-GATE+selftest）"; else bad 07 "33.6 机制缺失"; fi
# RV-08
if jq -e '.properties.reflect_verify_enforce | .default=="warn" and ((.enum|sort)|. == ["enforce","off","warn"])' "$CONFIG" >/dev/null 2>&1; then
  ok 08 "config.json reflect_verify_enforce（warn 默认+三档）"
else
  bad 08 "config.json reflect_verify_enforce 缺失/默认非 warn/enum 非三档"
fi
# RV-09
if grep -q 'REFLECT-GATE' "$CHK" && grep -q 'TASK_PLANNER_REFLECT_VERIFY_ENFORCE' "$CHK" \
   && grep -qF -- '- [reflect] ' "$CHK" \
   && [ "$(grep -c 'REFLECT-GATE SKIPPED' "$CHK")" -ge 2 ] && [ "$(grep -c 'REFLECT-GATE' "$CHK")" -ge 4 ]; then
  ok 09 "check-complete.sh REFLECT-GATE 锚点（gate/env/[reflect] 计数/SKIPPED 双分支）"
else
  bad 09 "check-complete.sh 缺 REFLECT-GATE 锚点"
fi
# RV-10
if grep -qE 'Rules 1-3[5-8]' "$SKILL"; then ok 10 "SKILL.md 'Rules 1-3[5-8]' 宽容锚索引行（兼容 1-35/1-36/1-37/1-38 过渡）"; else bad 10 "SKILL.md 缺 'Rules 1-3[5-8]' 宽容锚"; fi
# RV-11
if grep -q '^| C21 ' "$SKILL"; then ok 11 "SKILL.md 检查清单 C21 行"; else bad 11 "SKILL.md 缺 C21 行"; fi
# RV-12
if grep -q '解决后反思-验证循环' "$SKILL"; then ok 12 "SKILL.md「解决后反思-验证循环」段"; else bad 12 "SKILL.md 缺「解决后反思-验证循环」段"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
