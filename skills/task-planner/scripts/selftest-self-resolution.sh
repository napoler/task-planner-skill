#!/usr/bin/env bash
# selftest-self-resolution.sh — task-v098 P3-S4: Rule 41 问题自主消解与升级纪律静态守护
# 范式同 selftest-tool-selection.sh（SCRIPT_DIR/SKILL_ROOT 解析、ok()/bad() 结构、Total 行、exit 语义同构）：
# 本脚本仅做静态断言（grep/wc/jq 为主），SR-01..SR-13 全 PASS exit 0；任一 FAIL exit 1。
#   SR-01     critical-rules.md Rule 41 六子条锚 `grep -c '^41\.'` = 6
#   SR-02     41.2 升级四门槛区域锚：全文件「G1」「G4」各 ≥1
#   SR-03     消解清单措辞锚：「已尝试清单」≥1 且「D6 硬停点语义保留不弱化」≥1
#   SR-04     trivial 自主裁定措辞锚：「直接做」≥1 且「留用户裁决」≥1
#   SR-05     41.6 行内锚：「零新 config 键」≥1 且「selftest-self-resolution.sh」≥1
#   SR-06     SKILL.md `grep -c 'Rule 41'` ≥3 且 `grep -c '| C29 |'` = 1（合规清单 C29 项）
#   SR-07     SKILL.md `grep -c 'Rules 1-39'` = 2 且 `grep -c '1-40'` = 0（字面锚——关键负断言）
#   SR-08     SKILL.md 含「含 Rule 40-5[3-9]」≥1 且 critical-rules.md `grep -c '^40\.'` = 6（Rule 40/41 共存零损伤）
#             [2026-10-05 task-v131 CR P1-2 级联: SKILL.md:266 括注演进→「（含 Rule 40-53 全集）」, 锚随之演进, 原锚「含 Rule 40/41」, 判例 SR-11 锚演进必同步; ^40\.=6 子条断言保留]
#   SR-09     零新 config 键——config.json properties 键数 = 40（同 WF-12 口径；jq 缺失时打 SKIPPED 不 FAIL）
#   SR-10     SKILL.md 摘要行锚：「升级四门槛」或「四门槛」≥1
#   SR-11     selftest-skill-split.sh 级联落地锚：「task-v099」≥1 且 `-le 4` 前缀断言行存在（不锁具体数值）[2026-09-30 task-v099 级联: 锚 token task-v098→task-v099]
#   SR-12     selftest-registry.tsv 含「selftest-self-resolution」≥1 且总行数 = 40（v099 登记后断言）[2026-09-30 task-v099 级联: 锚值 39→40]
# 静态只读（grep/wc/jq），零仓库写入；无临时文件（无需 mktemp）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
SPLIT="$SKILL_ROOT/scripts/selftest-skill-split.sh"
REGISTRY="$SKILL_ROOT/scripts/selftest-registry.tsv"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'SR-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'SR-%s FAIL %s\n' "$1" "$2"; }

# SR-01 Rule 41 六子条锚
n="$(grep -c '^41\.' "$CRIT" || true)"
if [ "$n" -eq 6 ]; then ok 01 "critical-rules.md 六子条锚 = 6"; else bad 01 "critical-rules.md 六子条锚 $n（应 6）"; fi
# SR-02 41.2 升级四门槛 G1/G4 锚（全文件各 ≥1）
if [ "$(grep -c 'G1' "$CRIT" || true)" -ge 1 ] && [ "$(grep -c 'G4' "$CRIT" || true)" -ge 1 ]; then
  ok 02 "critical-rules.md G1/G4 门槛锚各 ≥1"
else
  bad 02 "critical-rules.md G1/G4 门槛锚缺失"
fi
# SR-03 消解清单措辞锚
if [ "$(grep -c '已尝试清单' "$CRIT" || true)" -ge 1 ] && [ "$(grep -c 'D6 硬停点语义保留不弱化' "$CRIT" || true)" -ge 1 ]; then
  ok 03 "「已尝试清单」+「D6 硬停点语义保留不弱化」措辞锚在位"
else
  bad 03 "消解清单措辞锚缺失（已尝试清单 / D6 硬停点语义保留不弱化）"
fi
# SR-04 trivial 自主裁定措辞锚
if [ "$(grep -c '直接做' "$CRIT" || true)" -ge 1 ] && [ "$(grep -c '留用户裁决' "$CRIT" || true)" -ge 1 ]; then
  ok 04 "trivial 裁定措辞「直接做」+「留用户裁决」在位"
else
  bad 04 "trivial 裁定措辞锚缺失（直接做 / 留用户裁决）"
fi
# SR-05 41.6 行内锚（零新 config 键 + 守护脚本名）
if grep '^41\.6' "$CRIT" | grep -q '零新 config 键' && grep '^41\.6' "$CRIT" | grep -q 'selftest-self-resolution.sh'; then
  ok 05 "41.6 行内锚（零新 config 键 / selftest-self-resolution.sh）在位"
else
  bad 05 "41.6 行内锚缺失（零新 config 键 / selftest-self-resolution.sh）"
fi
# SR-06 SKILL.md Rule 41 锚 ≥3 + C29 合规清单项 = 1
n="$(grep -c 'Rule 41' "$SKILLMD" || true)"
c="$(grep -c '| C29 |' "$SKILLMD" || true)"
if [ "$n" -ge 3 ] && [ "$c" -eq 1 ]; then ok 06 "SKILL.md Rule 41 锚 $n ≥3 且 C29 项 =1"; else bad 06 "SKILL.md Rule 41 锚 $n（应 ≥3）或 C29 项 $c（应 1）"; fi
# SR-07 字面锚：「Rules 1-39」= 2 且「1-40」= 0（关键负断言）
a="$(grep -c 'Rules 1-39' "$SKILLMD" || true)"
b="$(grep -c '1-40' "$SKILLMD" || true)"
if [ "$a" -eq 2 ] && [ "$b" -eq 0 ]; then ok 07 "SKILL.md 字面锚 Rules 1-39=2 且 1-40=0"; else bad 07 "SKILL.md 字面锚漂移（Rules 1-39=$a 应 2 / 1-40=$b 应 0）"; fi
# SR-08 Rule 40/41 共存零损伤
# [2026-10-05 task-v131 CR P1-2 级联: 锚「含 Rule 40/41」→「含 Rule 40-53」(SKILL.md:266 括注演进), ^40\.=6 子条断言保留]
# [2026-10-05 task-v136 S2 级联: 括注演进「40-54 全集」, 锚宽容化 40-5[3-9]（宽容正则优先）, ^40\.=6 子条断言保留]
if [ "$(grep -cE '含 Rule 40-5[3-9]' "$SKILLMD" || true)" -ge 1 ] && [ "$(grep -c '^40\.' "$CRIT" || true)" -eq 6 ]; then
  ok 08 "SKILL.md「含 Rule 40-5x」宽容锚 + critical-rules.md Rule 40 六子条 = 6（共存零损伤）"
else
  bad 08 "Rule 40/41 共存锚损伤（含 Rule 40-5[3-9] 缺失或 ^40\. 子条数 ≠6）"
fi
# SR-09 零新 config 键——properties 键数 = 40（同 WF-12 口径；jq 缺失打 SKIPPED 不 FAIL）
if command -v jq >/dev/null 2>&1; then
  keys="$(jq -r '.properties|keys|length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "40" ]; then ok 09 "config.json properties 键数 40（零新增）"; else bad 09 "config.json properties 键数=$keys（应 40）"; fi
else
  printf 'SR-09 SKIPPED jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）\n'
fi
# SR-10 SKILL.md 摘要行锚（升级四门槛 / 四门槛）
if grep -qF '升级四门槛' "$SKILLMD" || grep -qF '四门槛' "$SKILLMD"; then
  ok 10 "SKILL.md 摘要行锚「升级四门槛」在位"
else
  bad 10 "SKILL.md 缺摘要行锚（升级四门槛 / 四门槛）"
fi
# SR-11 skill-split 级联落地锚（task-vNNN label 宽容正则 + -le 4 前缀断言行；数值不锁定）[2026-09-30 task-v100 锚 v098→v099;2026-10-01 task-v102 B 类扩围根治: label token 随级联任务必变（v098→v099→v102 三连断）,改宽容正则 task-v099|task-v10x,断言语义不变;2026-10-02 task-v113 基线修复: f549958 上 selftest-skill-split.sh label 已演进至 task-v112 致 SR-11 断裂,正则扩 task-v11x,断言语义不变;2026-10-03 task-v122 锚演进: skill-split label 迁至 task-v122 越出 v11x，正则扩 v12x（[10-2] 覆盖 v100-v129），断言语义不变]
if [ "$(grep -cE 'task-v099|task-v1[0-2][0-9]' "$SPLIT" || true)" -ge 1 ] && grep -q -e '-le 4' "$SPLIT"; then
  ok 11 "selftest-skill-split.sh task-v099/task-v1x label + -le 4 前缀断言行在位"
else
  bad 11 "selftest-skill-split.sh 级联锚缺失（task-v099|task-v1x / -le 4 前缀断言行）"
fi
# SR-12 registry 双向登记：含 selftest-self-resolution 行 ≥1 且行数=脚本数+表头（动态口径）[2026-09-30 task-v100 B 类扩围根治: 硬编码行数随每次新脚本登记必然级联断裂（v099 改 39→40 后 v100 又断）,改动态比较——期望行数=ls selftest-*.sh 计数+1 表头,断言语义等价且免未来级联]
n="$(grep -c 'selftest-self-resolution' "$REGISTRY" || true)"
lines="$(wc -l < "$REGISTRY")"
expected=$(( $(ls "$(dirname "$REGISTRY")"/selftest-*.sh 2>/dev/null | wc -l) + 1 ))
if [ "$n" -ge 1 ] && [ "$lines" -eq "$expected" ]; then ok 12 "registry selftest-self-resolution 登记行 ≥1 且总行数 $lines=脚本数+表头（动态）"; else bad 12 "registry 漂移（selftest-self-resolution 命中 $n 应 ≥1 / 总行数 $lines 应 $expected=脚本数+表头）"; fi
# SR-13 task-v113 扩档级联锚：22.3.0 资料先行档 + 22.3.0b 换道义务 静态锚（零新 config 键维持）
n2230="$(grep -c '^22\.3\.0 ' "$CRIT" || true)"
k1="$(grep -c '资料先行' "$CRIT" || true)"
k2="$(grep -c '换道评估顺序' "$CRIT" || true)"
k3="$(grep -c '官方文档' "$CRIT" || true)"
if [ "$n2230" -ge 1 ] && [ "$k1" -ge 1 ] && [ "$k2" -ge 1 ] && [ "$k3" -ge 1 ]; then
  ok 13 "22.3.0 资料先行档行存在 + 资料先行/换道评估顺序/官方文档 关键词在位"
else
  bad 13 "22.3.0 扩档锚缺失（^22.3.0 行=$n2230 应 ≥1 / 资料先行=$k1 / 换道评估顺序=$k2 / 官方文档=$k3）"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
