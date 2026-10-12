#!/usr/bin/env bash
# selftest-task-boundary.sh — task-v087: Rule 8.1 新任务边界判定(D 类)静态守护
# 守护(门控+指针范式,裁决消费为 LLM 行为面无脚本可测,仅防条款误删):
#   TB-01 critical-rules.md 含 8.1 子条(行首 `8.1 ` 且含「新任务边界」语义锚)
#   TB-02 8.1 含 D 类判定三要素依据(Goal/scope_files/交付物)
#   TB-03 8.1 含处置语义锚: 开新计划目录 + 旧计划原样保留
#   TB-04 Rule 8 原文未改动(三分类判定语义锚在位: A 无影响照常执行 / B 扩展 / C 矛盾)
#   TB-05 SKILL.md 用户新指令表含 D 新任务边界行
#   TB-06 SKILL.md 含「新增任务边界判定（Rule 8.1）」特判段
#   TB-07 SKILL.md C12 检查项已扩为 D/A/B/C
#   TB-08 UPS hook [plan-note] 文案含 D 类判定指引
#   TB-09 UPS hook 职责 3 注释已联动 D 类
#   TB-10 todo-sync.md S5 hook 说明含 D 类分支(开新计划目录+旧计划映射保留)
#   TB-11 SKILL.md 高频漂移触发时机行仍兼容(A/B/C 判定提法未失效)
# 11 断言全 PASS exit 0; 任一 FAIL exit 1。只读, 不修改任何文件。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
# [task-v171 纪律域搬迁 2026-10-12] Rule 8（新请求强制重新规划）及其 8.1 子条属纪律域，原文已迁至
#   skills/task-discipline/references/critical-rules-discipline.md（核心 critical-rules.md 只剩 11 条核心规则）；
#   TB-01..TB-04 的 CRIT 断言改指 CRIT_D，CRIT 保留指向核心。断言语义零改动。
CRIT_D="$SKILL_ROOT/../task-discipline/references/critical-rules-discipline.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
TODOSYNC="$SKILL_ROOT/references/todo-sync.md"
UPS="$SKILL_ROOT/scripts/zcode-userpromptsubmit.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'TB-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'TB-%s FAIL %s\n' "$1" "$2"; }

# TB-01: 8.1 子条在位
if grep -q '^8\.1 ' "$CRIT_D" && grep '^8\.1 ' "$CRIT_D" | grep -q '新任务边界'; then
  ok 01 "8.1 新任务边界子条"
else
  bad 01 "8.1 子条缺失"
fi
# TB-02: 判定依据三要素
if grep '^8\.1 ' "$CRIT_D" | grep -q 'Goal' && grep '^8\.1 ' "$CRIT_D" | grep -q '交付物'; then
  ok 02 "8.1 判定依据三要素"
else
  bad 02 "8.1 缺判定依据"
fi
# TB-03: 处置语义(开新计划目录 + 旧计划原样保留)
if grep '^8\.1 ' "$CRIT_D" | grep -q '新计划目录' && grep '^8\.1 ' "$CRIT_D" | grep -q '原样保留'; then
  ok 03 "8.1 处置语义锚"
else
  bad 03 "8.1 处置锚缺失"
fi
# TB-04: Rule 8 原文未改动(三分类语义锚)
rule8="$(awk '/^### 8 新请求强制重新规划/,/^8\.1 /{print}' "$CRIT_D")"
if printf '%s' "$rule8" | grep -q 'A/B/C 影响判定' && printf '%s' "$rule8" | grep -q 'A 无影响照常执行'; then
  ok 04 "Rule 8 原文未改动"
else
  bad 04 "Rule 8 原文被改动"
fi
# TB-05: SKILL.md 用户新指令表 D 行
if grep -q '| D 新任务边界 |' "$SKILLMD"; then
  ok 05 "SKILL.md D 行"
else
  bad 05 "SKILL.md 缺 D 行"
fi
# TB-06 [task-v171 核心瘦身] SKILL.md D 特判段 → 「判定顺序：先 D 再 A/B/C」行（特判段瘦身后由判定顺序行承载）
#   现象：SKILL.md 瘦身后旧「新增任务边界判定（Rule 8.1 — task-v087）」特判段标题随重写退役，命中=0，TB-06 恒 FAIL。
#   根因：用户新指令处理表重写后，D 特判语义由「判定顺序：先 D 再 A/B/C（仅存在活跃计划时 D 类适用）」行承载。
#   修法：锚随现措辞演进为 '先 D 再 A/B/C'（≥1）。
if grep -q '先 D 再 A/B/C' "$SKILLMD"; then
  ok 06 "SKILL.md D 特判段（判定顺序行「先 D 再 A/B/C」承载）"
else
  bad 06 "SKILL.md 缺 D 特判段"
fi
# TB-07 [task-v171 核心瘦身] C12 检查项扩为 D/A/B/C → G8 合规行（合规清单表瘦身后 D/A/B/C 判定由 G8 行承载）
if grep -qE '^\| G8 ' "$SKILLMD" && grep -E '^\| G8 ' "$SKILLMD" | grep -q 'D/A/B/C'; then
  ok 07 "SKILL.md G8 行含 D/A/B/C（C12 检查项瘦身后由 G8 合规行承载）"
else
  bad 07 "SKILL.md G8 未含 D/A/B/C"
fi
# TB-08: UPS hook [plan-note] 文案含 D 类指引
if grep 'plan-note' "$UPS" | grep -q 'D 新任务边界' && grep 'plan-note' "$UPS" | grep -q '不相干内容禁止混入'; then
  ok 08 "UPS hook [plan-note] D 类指引"
else
  bad 08 "UPS hook [plan-note] 缺 D 类指引"
fi
# TB-09: UPS hook 职责 3 注释联动
if grep '职责 3' "$UPS" | grep -q 'D/A/B/C' && grep '职责 3' "$UPS" | grep -q 'task-v087'; then
  ok 09 "UPS hook 职责 3 注释联动"
else
  bad 09 "UPS hook 职责 3 注释未联动"
fi
# TB-10: todo-sync.md S5 说明 D 类分支
if grep -q 'D=新任务边界，Rule 8.1' "$TODOSYNC" && grep -q '旧计划的 Todo 映射原样保留' "$TODOSYNC"; then
  ok 10 "todo-sync.md S5 D 类分支"
else
  bad 10 "todo-sync.md S5 缺 D 类分支"
fi
# TB-11 [task-v171 核心瘦身] 高频漂移触发时机行提法未失效（措辞演进重锚）
#   现象：旧字面 'A/B/C 判定后做漂移检查' 随新指令段重写退役，命中=0，TB-11 恒 FAIL。
#   根因：B/C 处理后派 drift-checker 的语义现存措辞=「B/C 变更前过 Rule 73.2 对齐三问+[align] 行，处理完再派 drift-checker」。
#   修法：锚随现措辞演进为 '处理完再派 drift-checker'（≥1，提法兼容性语义保持）。
if grep -q '处理完再派 drift-checker' "$SKILLMD"; then
  ok 11 "SKILL.md 漂移触发时机行兼容（B/C 处理完再派 drift-checker 措辞）"
else
  bad 11 "SKILL.md 漂移触发时机行失效"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
