#!/usr/bin/env bash
# selftest-skill-modify.sh — task-v079: Rule 36 技能修改保守化与功能删除防护静态守护
# 守护（selftest-veto.sh 范式，门控+指针+接线锚，只读不修改任何文件）:
#   SM-01 critical-rules.md 含 '### 36 技能修改保守化与功能删除防护' 标题
#   SM-02 七子条 36.1-36.7 锚齐全（grep -cE '^36\.[1-7] ' = 7）
#   SM-03 36.2 行含 31.3 衔接 + 36.4 行含 D6（合并一条断言）
#   SM-04 config.json skill_modify_enforce: 默认 warn 且 enum 三档（python3 json 校验）
#   SM-05 scripts/check-skill-modify.sh 存在、可执行、bash -n 语法通过
#   SM-06 zcode-pretooluse.sh 含 check-skill-modify 接线调用（grep ≥1）
#   SM-07 check-complete.sh 含 SKILL-MODIFY GATE 锚注释 与 resolve_skill_modify_tier（grep ≥1 各一）
#   SM-08 SKILL.md 联动锚（Rule 36 行 / '| C24 |'）——两段策略（KQ2 裁定）:
#          P4 联动前「存在则校验非空计入 PASS、不存在则打印 SKIP 不计 PASS/FAIL」；
#          P4 完成联动后本断言自动转为实体断言（无需改脚本）
# 7 断言 + SM-08 两子项（SKIP 态不计入统计）; FAIL=0 exit 0, 任一 FAIL exit 1。
# 统计输出 Total/PASS/FAIL，只读，不修改任何文件。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
GUARD="$SKILL_ROOT/scripts/check-skill-modify.sh"
PRETOOL="$SKILL_ROOT/scripts/zcode-pretooluse.sh"
COMPLETE="$SKILL_ROOT/scripts/check-complete.sh"

PASS=0; FAIL=0; SKIP=0
ok()  { PASS=$((PASS+1)); printf 'SM-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'SM-%s FAIL %s\n' "$1" "$2"; }
skip(){ SKIP=$((SKIP+1)); printf 'SM-%s SKIP %s\n' "$1" "$2"; }

# SM-01
if grep -q '^### 36 ' "$CRIT" && grep '^### 36 ' "$CRIT" | grep -q '技能修改保守化与功能删除防护'; then ok 01 "36 标题"; else bad 01 "36 标题缺失"; fi
# SM-02
N=$(grep -cE '^36\.[1-7] ' "$CRIT"); if [ "$N" -eq 7 ]; then ok 02 "36.1-36.7 七子条锚齐全"; else bad 02 "子条锚计数=$N (期望 7)"; fi
# SM-03
if grep '^36\.2 ' "$CRIT" | grep -q '31.3' && grep '^36\.4 ' "$CRIT" | grep -q 'D6'; then ok 03 "36.2 衔接 31.3 + 36.4 引 D6"; else bad 03 "36.2/36.4 衔接锚缺失"; fi
# SM-04
if grep -q '"skill_modify_enforce"' "$CONFIG" && python3 -c "
import json,sys
d=json.load(open('$CONFIG'))
k=d['properties']['skill_modify_enforce']
sys.exit(0 if k.get('default')=='warn' and k.get('enum')==['enforce','warn','off'] else 1)" 2>/dev/null; then
  ok 04 "config.json skill_modify_enforce（warn 默认+三档）"
else
  bad 04 "config.json skill_modify_enforce 缺失/默认非 warn"
fi
# SM-05
if [ -f "$GUARD" ] && [ -x "$GUARD" ] && bash -n "$GUARD" 2>/dev/null; then ok 05 "check-skill-modify.sh 存在+可执行+语法"; else bad 05 "check-skill-modify.sh 缺失/不可执行/语法错"; fi
# SM-06
if grep -qc 'check-skill-modify' "$PRETOOL"; then ok 06 "zcode-pretooluse.sh 接线"; else bad 06 "pretooluse 缺 check-skill-modify 接线"; fi
# SM-07
if grep -qc 'SKILL-MODIFY GATE' "$COMPLETE" && grep -qc 'resolve_skill_modify_tier' "$COMPLETE"; then ok 07 "check-complete.sh GATE 锚+tier 函数"; else bad 07 "GATE 锚/tier 函数缺失"; fi
# SM-08 两段策略: 存在则校验非空(计入 PASS)，不存在则 SKIP（不计 FAIL/PASS；P4 联动后自动转实断言）
A=$(grep -c 'Rule 36' "$SKILLMD"); B=$(grep -c '| C24 |' "$SKILLMD")
if [ "$A" -gt 0 ]; then ok 08 "SKILL.md Rule 36 行（P4 联动已实，A=$A B=$B）"; else skip 08 "SKILL.md Rule 36 行缺失（SKIP: P4 联动后自动转实断言, B=$B）"; fi
if [ "$B" -gt 0 ]; then ok 08 "SKILL.md C24 检查项（P4 联动已实, A=$A B=$B）"; else skip 08 "SKILL.md C24 检查项缺失（SKIP: P4 联动后自动转实断言, A=$A）"; fi

printf 'Total: %d PASS=%d FAIL=%d (SKIP=%d)\n' "$((PASS+FAIL+SKIP))" "$PASS" "$FAIL" "$SKIP"
exit $((FAIL > 0))
