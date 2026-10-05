#!/usr/bin/env bash
# selftest-ask-default-timeout.sh — task-v103: Rule 44「用户选择点默认项与自动超时」静态守护
# 范式同 selftest-reliability-institution.sh（SCRIPT_DIR/SKILL_ROOT 解析、ok()/bad() 结构、Total 行、exit 语义同构）：
# 本脚本仅做静态断言（grep/jq 为主），RT-01..RT-11 全 PASS exit 0；任一 FAIL exit 1。
#   RT-01    critical-rules.md Rule 44 子条锚 `grep -c '^44\.'` = 5（44.1-44.5 五子条,task-v134 增 44.5 阻塞点展示限制）
#   RT-02    CRIT 44 节内用户原话锚：「默认选项」≥1 且「自动超时」≥1 且「5 分钟」≥1（仅 44 节内）
#   RT-03    44.2 行内「41.3」引用 ≥1（低区分度直接裁决衔接锚）
#   RT-04    SKILL.md `grep -c '| C33 |'` = 1（合规清单消费行）
#   RT-05    模板 task_plan.md `grep -c '自动超时默认项'` ≥1（配置行锚）
#   RT-06    mini-lite `grep -c 'Rule 44 豁免'` ≥1（豁免声明锚）
#   RT-07    registry `grep -c 'selftest-ask-default-timeout'` = 1（登记锚）
#   RT-08    越界负断言——CRIT 44 节与 SKILL.md `grep -E '1-4[0-9]'` 零命中（禁 1-4x 越界字面；[task-v118 口径扩展] 全集 1-46，1-4[56] 为合法形态加白 grep -vE 剔除）
#   RT-09    零新 config 键——config.json properties 键数 = 40（同 R-12/WF-12 口径；jq 缺失打 SKIPPED 不 FAIL）
#   RT-10    44.5 条款在位锚——critical-rules.md `grep -c '^44\.5'` = 1 且该行含「阻塞点展示限制」（task-v134 新增）
#   RT-11    44.5 关键词守护锚——critical-rules.md 全文「阻塞点展示限制」命中 ≥1（防 44.5 行被误删,与 RT-10 行锚双保险）
# 静态只读（grep/wc/jq），零仓库写入；无临时文件（无需 mktemp）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
TPL="$SKILL_ROOT/templates/task_plan.md"
MINILITE="$SKILL_ROOT/templates/variant/mini-lite-type.md"
REGISTRY="$SCRIPT_DIR/selftest-registry.tsv"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'RT-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'RT-%s FAIL %s\n' "$1" "$2"; }

# RT-01 Rule 44 五子条锚（44.1-44.5,task-v134 增 44.5 阻塞点展示限制;原行为=应 4,现级联 4→5）
n="$(grep -c '^44\.' "$CRIT" || true)"
if [ "$n" -eq 5 ]; then ok 01 "critical-rules.md Rule 44 子条锚 = 5"; else bad 01 "critical-rules.md Rule 44 子条数 $n（应 5）"; fi
# RT-02 CRIT 44 节内用户原话锚（仅 44 节内,防全文件锚误判）
S44="$(grep '^44\.' "$CRIT")"
a="$(printf '%s\n' "$S44" | grep -c '默认选项' || true)"
b="$(printf '%s\n' "$S44" | grep -c '自动超时' || true)"
c="$(printf '%s\n' "$S44" | grep -c '5 分钟' || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ] && [ "$c" -ge 1 ]; then
  ok 02 "CRIT 44 节用户原话锚「默认选项」$a /「自动超时」$b /「5 分钟」$c 均 ≥1"
else
  bad 02 "CRIT 44 节原话锚缺失（默认选项=$a 自动超时=$b 5 分钟=$c,均应 ≥1）"
fi
# RT-03 44.2 行内 41.3 衔接锚
n="$(grep '^44\.2' "$CRIT" | grep -c '41\.3' || true)"
if [ "$n" -ge 1 ]; then ok 03 "44.2 行内「41.3」衔接引用 $n ≥1"; else bad 03 "44.2 行内「41.3」衔接引用缺失（$n 应 ≥1）"; fi
# RT-04 SKILL.md C33 合规清单消费行 = 1
n="$(grep -c '| C33 |' "$SKILLMD" || true)"
if [ "$n" -eq 1 ]; then ok 04 "SKILL.md C33 合规清单项 = 1"; else bad 04 "SKILL.md C33 项 $n（应 1）"; fi
# RT-05 模板 task_plan.md 自动超时默认项行锚
n="$(grep -c '自动超时默认项' "$TPL" || true)"
if [ "$n" -ge 1 ]; then ok 05 "模板 task_plan.md「自动超时默认项」行 $n ≥1"; else bad 05 "模板「自动超时默认项」行缺失（$n 应 ≥1）"; fi
# RT-06 mini-lite 豁免声明锚
n="$(grep -c 'Rule 44 豁免' "$MINILITE" || true)"
if [ "$n" -ge 1 ]; then ok 06 "mini-lite「Rule 44 豁免」声明行 $n ≥1"; else bad 06 "mini-lite 豁免声明行缺失（Rule 44 豁免 命中 $n 应 ≥1）"; fi
# RT-07 registry 登记锚
n="$(grep -c 'selftest-ask-default-timeout' "$REGISTRY" || true)"
if [ "$n" -eq 1 ]; then ok 07 "registry 含 selftest-ask-default-timeout 行 = 1"; else bad 07 "registry 登记数 $n（应 1）"; fi
# RT-08 越界负断言——CRIT 44 节与 SKILL.md 均零 1-4x 越界字面
# [task-v118 口径扩展] frontmatter 全集具名 1-45→1-46（task-v118 Phase 2 落地），1-4[56] 为合法形态→加白（grep -vE 剔除后计数），
# 越界口径=1-4x 字面中除 1-4[56] 外者（既有断言意图=防越界规则引用字面，语义零改动，同 v117 WF-10/PT-08 先例）
# [task-v118 口径扩展 2026-10-03] 原行为=grep -vcE '1-45'（仅 1-45 加白），现 1-4[56] 均加白；断言语义不反转（越界仍须零命中）
# [task-v118 fix-phase CR finding 3] 原行为=grep -E '1-4[0-9]' | grep -vcE '1-4[56]'（整行过滤：同一行 1-46 与 1-47
# 共现时 1-47 越界字面被合法 1-46 带着加白，漏报）。现改逐匹配粒度：grep -oE 每匹配独立成行，
# grep -vE '^1-4[5-9]$' 仅剔恰好等于 1-45..1-49 的匹配，余者计入越界计数。
# [task-v121 预扩 2026-10-03] 1-4[56]→1-4[5-9]（用户裁决采纳 task-v118 建议 3：预扩消除 Rule 47-49 级联；代价=Rule 47 落地前 1-47..49 越界字面暂被加白，窗口期已知）
a="$(printf '%s\n' "$S44" | grep -oE '1-4[0-9]' | grep -vE '^1-4[5-9]$' | wc -l)"
b="$(grep -oE '1-4[0-9]' "$SKILLMD" | grep -vE '^1-4[5-9]$' | wc -l)"
if [ "$a" -eq 0 ] && [ "$b" -eq 0 ]; then ok 08 "越界 1-4x 字面零命中（CRIT 44 节=$a / SKILL.md=$b，1-4[5-9] 已加白 task-v117+task-v118+task-v121）"; else bad 08 "越界 1-4x 字面命中（CRIT 44 节=$a / SKILL.md=$b，除 1-4[5-9] 外均应 0）"; fi
# RT-09 零新 config 键——properties 键数 = 40（同 R-12/WF-12 口径；jq 缺失打 SKIPPED 不 FAIL）
if command -v jq >/dev/null 2>&1; then
  keys="$(jq -r '.properties|keys|length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "40" ]; then ok 09 "config.json properties 键数 40（零新增）"; else bad 09 "config.json properties 键数=$keys（应 40）"; fi
else
  printf 'RT-09 SKIPPED jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）\n'
fi
# RT-10 44.5 条款在位锚（task-v134 新增：阻塞点展示限制条款行锚，grep -c 行级计数=1 防重复行）
n="$(grep -c '^44\.5' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 10 "critical-rules.md 44.5 阻塞点展示限制条款行 = 1"; else bad 10 "critical-rules.md 44.5 条款行数 $n（应 1）"; fi
# RT-11 44.5 关键词守护锚——「阻塞点展示限制」全文命中 ≥1（44.5 行标题锚；与 RT-10 行锚双保险防误删）
n="$(grep -c '阻塞点展示限制' "$CRIT" || true)"
if [ "$n" -ge 1 ]; then ok 11 "critical-rules.md「阻塞点展示限制」关键词命中 $n ≥1"; else bad 11 "critical-rules.md「阻塞点展示限制」关键词缺失（$n 应 ≥1）"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
