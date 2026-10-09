#!/usr/bin/env bash
# selftest-error-fix-prompt-forge.sh — task-v157 S3: 顶层 error-fix-prompt-forge skill 静态守护
# [2026-10-10 task-v157 级联修复 S3 提前执行] 位置平移: skills/error-fix-prompt-forge/scripts/ →
# skills/task-planner/scripts/（仓库惯例: 全部 selftest 集中于 task-planner/scripts,
# iterative-optimizer 先例）; 路径解析同步修正为 SCRIPT_DIR(=task-planner/scripts) 相对范式, 无写死绝对路径。
# 范式同 selftest-iterative-optimizer.sh（SCRIPT_DIR 相对解析、ok()/bad() 结构、Total 行、exit 语义同构）：
# 本脚本仅做静态断言（grep/wc 为主），FP-01..FP-08 全 PASS exit 0；任一 FAIL exit 1。
# SCRIPT_DIR=skills/task-planner/scripts（平移后新位置）；SKILL_ROOT=$SCRIPT_DIR/..=skills/task-planner。
# 断言对象 = skills/error-fix-prompt-forge/{SKILL.md,templates/fix-prompt-template.md} + registry/config（相对解析，禁写死绝对路径 S75-D1）。
#   FP-01  SKILL.md 存在且 frontmatter name=目录名(与 SKILL.md 所在目录 basename 比对)+ description 非空
#   FP-02  六区块锚齐全：触发条件/输入契约/执行流程/门控铁律/输出合约/反模式 各 ≥1
#   FP-03  fail-closed 条款：「BLOCKED」与「根因未定位」共现（各 ≥1）
#   FP-04  QC-FP 自检表行（^| QC-FP-）≥6 且含机器可检查条款（「机器可检查」≥1）
#   FP-05  模板存在 + 八槽位锚，逐词各 ≥1：根因/复现/禁改区/验收/回滚/未验证假设区/DoD/验证命令
#   FP-06  模板槽位词与 SKILL Step 1 槽位表互现 ≥5（候选 7 词逐词 grep -qF：问题陈述/根因+证据/复现/禁改区/验证判据/回滚/参考材料）
#   FP-07  registry 含口径登记 error-fix-prompt-forge（数据行出现 ≥1 即 PASS）
#       [2026-10-10 合并级联修复 sub:09] 末行口径改含口径: 合并 master(v155 report-reviewability 登记行)后
#       跨任务追加登记行会打破末行断言, 对齐 G-07 含口径范式防复发
#   FP-08  config.json 零新键（grep error-fix-prompt-forge = 0）

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# 平移后 SKILL_ROOT=skills/task-planner, 断言对象改经 ../error-fix-prompt-forge 跨 skill 相对解析
SKILL="$SKILL_ROOT/../error-fix-prompt-forge/SKILL.md"
TPL="$SKILL_ROOT/../error-fix-prompt-forge/templates/fix-prompt-template.md"
REG="$SCRIPT_DIR/selftest-registry.tsv"
CFG="$SKILL_ROOT/config.json"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'FP-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'FP-%s FAIL %s\n' "$1" "$2"; }

# FP-01 SKILL.md 存在且 frontmatter name=目录名(Nit-1 做实: 与所在目录 basename 比对)+ description 非空
name_val="$(head -5 "$SKILL" 2>/dev/null | grep -m1 '^name:' | sed 's/^name: *//')"; dir_base="$(basename "$(dirname "$SKILL")")"
if [ -f "$SKILL" ] && [ "$name_val" = "$dir_base" ] \
   && [ -n "$(head -5 "$SKILL" | grep '^description:' || true)" ]; then
  ok 01 "SKILL.md 存在且 frontmatter name=目录名($name_val=$dir_base) + description 非空"
else
  bad 01 "SKILL.md 缺失或 name≠目录名/description 锚缺失（name=$name_val dir=$dir_base）"
fi
# FP-02 六区块锚齐全（触发条件/输入契约/执行流程/门控铁律/输出合约/反模式）
n=$(grep -c '触发条件\|输入契约\|执行流程\|门控铁律\|输出合约\|反模式' "$SKILL" || true)
if [ "$n" -ge 6 ]; then ok 02 "六区块锚齐全（命中 $n ≥6）"; else bad 02 "六区块锚漂移（命中 $n 应 ≥6）"; fi
# FP-03 fail-closed 条款：BLOCKED 与「根因未定位」共现
a="$(grep -c 'BLOCKED' "$SKILL" || true)"
b="$(grep -c '根因未定位' "$SKILL" || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then
  ok 03 "fail-closed 条款在位（BLOCKED $a 且 根因未定位 $b, 各 ≥1）"
else
  bad 03 "fail-closed 条款漂移（BLOCKED=$a 根因未定位=$b, 应各 ≥1）"
fi
# FP-04 QC-FP 自检表行（锚定表行 ^| QC-FP-, 防正文引用虚增）≥6 条且含机器可检查条款
a="$(grep -c '^| QC-FP-' "$SKILL" || true)"
b="$(grep -c '机器可检查' "$SKILL" || true)"
if [ "$a" -ge 6 ] && [ "$b" -ge 1 ]; then
  ok 04 "QC-FP 自检表在位（QC-FP 行 $a ≥6 且 机器可检查 $b ≥1）"
else
  bad 04 "QC-FP 自检表漂移（QC-FP=$a 应 ≥6 / 机器可检查=$b 应 ≥1）"
fi
# FP-05 模板存在 + 八槽位锚，逐词各 ≥1（宽 OR 累计已废弃: 8 词任一缺失即 FAIL）
n=0; for w in 根因 复现 禁改区 验收 回滚 未验证假设区 DoD 验证命令; do [ -f "$TPL" ] && grep -qF "$w" "$TPL" 2>/dev/null && n=$((n+1)); done
if [ -f "$TPL" ] && [ "$n" -eq 8 ]; then
  ok 05 "模板存在且八槽位锚在位（逐词命中 $n/8, 各 ≥1）"
else
  bad 05 "模板缺失或八槽位锚漂移（逐词命中 $n/8, 应 8/8）"
fi
# FP-06 模板槽位词与 SKILL Step 1 槽位表互现 ≥5（候选 7 词逐词 grep -qF, 短词子串前缀匹配已废弃）
mut=0; for w in 问题陈述 根因+证据 复现 禁改区 验证判据 回滚 参考材料; do grep -qF "$w" "$SKILL" && grep -qF "$w" "$TPL" && mut=$((mut+1)); done
if [ "$mut" -ge 5 ]; then
  ok 06 "模板与 SKILL Step 1 槽位词互现 $mut/7 ≥5"
else
  bad 06 "槽位词互现漂移（互现 $mut/7 应 ≥5）"
fi
# FP-07 registry 含口径登记 error-fix-prompt-forge（数据行出现 ≥1 即 PASS; 末行口径已废弃——
# 跨任务追加登记行会打破末行断言, 对齐 G-07 含口径范式）
n="$(grep -c 'error-fix-prompt-forge' "$REG" 2>/dev/null || true)"
if [ "$n" -ge 1 ]; then
  ok 07 "registry 含 error-fix-prompt-forge 数据行（命中 $n ≥1）"
else
  bad 07 "registry 未含 error-fix-prompt-forge 数据行（命中 $n 应 ≥1）"
fi
# FP-08 config.json 零新键（grep error-fix-prompt-forge = 0）
n="$(grep -c 'error-fix-prompt-forge' "$CFG" || true)"
if [ "$n" -eq 0 ]; then ok 08 "config.json 零新键（error-fix-prompt-forge 命中 0）"; else bad 08 "config.json 出现新键（命中 $n 应 0）"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
