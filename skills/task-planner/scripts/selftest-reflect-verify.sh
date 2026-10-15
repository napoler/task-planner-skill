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
#   RV-08 config.json reflect_verify_enforce 键（默认 enforce, enum 三档 enforce/warn/off）
#   RV-09 check-complete.sh 含 REFLECT-GATE 锚点（REFLECT-GATE / TASK_PLANNER_REFLECT_VERIFY_ENFORCE / - [reflect] 行计数 / SKIPPED 分支）
#   RV-10 SKILL.md 含 'Rules 1-3[56]' 宽容锚索引行（Rule 33/34/35/36/37 联动；[2026-09-17 task-v079] 严格 '1-35'→宽容 1-3[56]；[2026-09-20 task-v085] Rule 37 级联 1-3[56]→1-3[5-7]）[2026-10-08 task-v144 合并级联: SKILL References/索引锚演进 1-62（58/59/60/62 落地）,宽容正则扩 6x 纪元 1-(3[5-9]|[4-6][0-9])][2026-10-10 task-v158 扩 7x 纪元 1-(3[5-9]|[4-7]x)][2026-10-11 task-v169 扩 8x 纪元 1-(3[5-9]|[4-8][0-9])（Rule 80 落地, SKILL.md 索引锚演进 1-80）]
#   RV-11 SKILL.md 检查清单含 C21 行（Rule 33 [reflect] 反思+验证两行）
#   RV-12 SKILL.md 含「解决后反思-验证循环」联动段
# 12 断言全 PASS exit 0; 任一 FAIL exit 1。只读, 不修改任何文件。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
# [task-v171 纪律域搬迁 2026-10-12] Rule 33（解决→反思→验证迭代循环）属纪律域，原文已迁至
#   skills/task-discipline/references/critical-rules-discipline.md（核心 critical-rules.md 只剩 11 条核心规则），
#   RV-01..RV-07 的 CRIT 断言改指 CRIT_D；CRIT 保留指向核心。断言语义零改动。
CRIT_D="$SKILL_ROOT/../task-discipline/references/critical-rules-discipline.md"
CONFIG="$SKILL_ROOT/config.json"
CHK="$SKILL_ROOT/scripts/check-complete.sh"
SKILL="$SKILL_ROOT/SKILL.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'RV-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'RV-%s FAIL %s\n' "$1" "$2"; }

# RV-01
if grep -q '^### 33 解决→反思→验证迭代循环' "$CRIT_D"; then ok 01 "Rule 33 头"; else bad 01 "Rule 33 头缺失"; fi
# RV-02
if grep '^33\.1 ' "$CRIT_D" | grep -q '触发'; then ok 02 "33.1 触发"; else bad 02 "33.1 触发缺失"; fi
# RV-03
if grep '^33\.2 ' "$CRIT_D" | grep -q '反思四问'; then ok 03 "33.2 反思四问"; else bad 03 "33.2 反思四问缺失"; fi
# RV-04（33.3 写死落盘格式「前缀必须逐字为 - [reflect] 」;md 正文为反引号包裹变体, 锚=逐字 [reflect] 字样）
if grep '^33\.3 ' "$CRIT_D" | grep -qF '[reflect]'; then ok 04 "33.3 逐字 [reflect] 锚"; else bad 04 "33.3 缺逐字 [reflect] 锚"; fi
# RV-05
if grep '^33\.4 ' "$CRIT_D" | grep -q '≤3 轮' && grep '^33\.4 ' "$CRIT_D" | grep -q 'Rule 22.3'; then ok 05 "33.4 迭代边界（≤3 轮+升档）"; else bad 05 "33.4 迭代边界缺失"; fi
# RV-06
if grep '^33\.5 ' "$CRIT_D" | grep -q 'What Worked' && grep '^33\.5 ' "$CRIT_D" | grep -q 'notepad'; then ok 06 "33.5 notepad What Worked 联动"; else bad 06 "33.5 沉淀联动缺失"; fi
# RV-07
if grep '^33\.6 ' "$CRIT_D" | grep -q 'reflect_verify_enforce' && grep '^33\.6 ' "$CRIT_D" | grep -q 'REFLECT-GATE' && grep '^33\.6 ' "$CRIT_D" | grep -q 'selftest-reflect-verify'; then ok 07 "33.6 机制（开关键+REFLECT-GATE+selftest）"; else bad 07 "33.6 机制缺失"; fi
# RV-08 [2026-10-11 task-v168 设置层] reflect_verify_enforce 默认值 warn→enforce（用户 piv⊙ 设置修复），本钉同步演进；禁回退 warn。
# 原文（修前）: .default=="warn"，ok 消息「warn 默认+三档」，bad 消息「默认非 warn/enum 非三档」
if jq -e '.properties.reflect_verify_enforce | .default=="enforce" and ((.enum|sort)|. == ["enforce","off","warn"])' "$CONFIG" >/dev/null 2>&1; then
  ok 08 "config.json reflect_verify_enforce（enforce 默认+三档）"
else
  bad 08 "config.json reflect_verify_enforce 缺失/默认非 enforce/enum 非三档"
fi
# RV-09
if grep -q 'REFLECT-GATE' "$CHK" && grep -q 'TASK_PLANNER_REFLECT_VERIFY_ENFORCE' "$CHK" \
   && grep -qF -- '- [reflect] ' "$CHK" \
   && [ "$(grep -c 'REFLECT-GATE SKIPPED' "$CHK")" -ge 2 ] && [ "$(grep -c 'REFLECT-GATE' "$CHK")" -ge 4 ]; then
  ok 09 "check-complete.sh REFLECT-GATE 锚点（gate/env/[reflect] 计数/SKIPPED 双分支）"
else
  bad 09 "check-complete.sh 缺 REFLECT-GATE 锚点"
fi
# RV-10 [2026-10-08 task-v144 合并级联: SKILL References/索引锚演进 1-62（58/59/60/62 落地）,宽容正则扩 6x 纪元][2026-10-10 task-v158 扩 7x 纪元 1-(3[5-9]|[4-7]x)][2026-10-11 task-v169 扩 8x 纪元 1-(3[5-9]|[4-8][0-9])（Rule 80 落地, SKILL.md 索引锚演进 1-80）]
# [2026-10-10 task-v160 合并并集: 保留演进记录，Rule 72 落地 1-72 纪元]
if grep -qE 'Rules 1-(3[5-9]|[4-9][0-9])' "$SKILL"; then ok 10 "SKILL.md 'Rules 1-(3[5-9]|[4-9][0-9])' 宽容锚索引行（兼容 1-35..1-80 各纪元过渡, 8x 纪元）"; else bad 10 "SKILL.md 缺 'Rules 1-(3[5-9]|[4-9][0-9])' 宽容锚"; fi
# RV-11 [task-v171 核心瘦身] C21 合规行 → 卫星路由表 task-discipline 行（Rule 33 合规消费面瘦身后由路由表承载）
#   现象：SKILL.md 瘦身后合规清单 C21 行（Rule 33 [reflect] 反思+验证两行）随清单表退役，命中=0，RV-11 恒 FAIL。
#   根因：Rule 33 属纪律域；合规清单表→G1-G8 核心域表，非核心域合规项经卫星路由表行承载（Rule 82 禁回潮）。
#   修法：改断言路由表 discipline 行 =1；Rule 33 全文锚由 CRIT_D 侧断言守护。
if grep -qE '^\| task-discipline \|' "$SKILL"; then ok 11 "SKILL.md 卫星路由表 task-discipline 行（C21 合规面瘦身后由路由表承载）"; else bad 11 "SKILL.md 卫星路由表 task-discipline 行缺失"; fi
# RV-12 [task-v171 核心瘦身]「解决后反思-验证循环」联动段 → 派发与执行纪律指针段 '反思验证' 措辞 + CRIT_D Rule 33 标题锚
#   现象：SKILL.md 瘦身后「解决后反思-验证循环」专属段移除（Rule 33 条文归 CRIT_D），命中=0，RV-12 恒 FAIL。
#   根因：非核心域条文不在 SKILL 展开；现存联动载体=「派发与执行纪律指针」段反思验证路由行（SKILL.md L191）。
#   修法：改断言 SKILL 含 '反思验证' 措辞 ≥1 ∧ CRIT_D '^### 33 ' 标题=1（联动段+条文双载体）。
if grep -q '反思验证' "$SKILL" && grep -q '^### 33 ' "$CRIT_D"; then ok 12 "SKILL.md 反思验证指针行 ∧ CRIT_D Rule 33 标题（原联动段瘦身后由指针行+条文锚承载）"; else bad 12 "SKILL.md 缺反思验证联动面"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
