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
#   SR-07     SKILL.md `grep -c 'Critical Rules 1-67'` ≥1 且 `grep -c '1-39'` = 0（字面锚——关键负断言）
#             [2026-10-08 task-v144 合并级联: References 表行 label 演进为「Critical Rules 1-62」,锚断言同步演进,旧 'Rules 1-39'=2 变体改为负断言 1-39=0]
#             [2026-10-08 task-v147 合并级联: '1-62'→'1-63'，Rule 63 已由 task-v147 合法落地（63.1-63.6 实测六子条），锚同步演进]
#   SR-08     SKILL.md 含「含 Rule 40-(5[3-9]|6[0-9])」≥1 且 critical-rules.md `grep -c '^40\.'` = 6（Rule 40/41 共存零损伤）
#             [2026-10-05 task-v131 CR P1-2 级联: SKILL.md:266 括注演进→「（含 Rule 40-53 全集）」, 锚随之演进, 原锚「含 Rule 40/41」, 判例 SR-11 锚演进必同步; ^40\.=6 子条断言保留]
#             [2026-10-08 task-v149 Rule 65 落地演进: 括注演进→「含 Rule 40-65 全集」, 宽容正则 5[3-9]|6[0-9] 已覆盖 65, 锚同步演进]
#   SR-09     零新 config 键——config.json properties 键数 = 42（同 WF-12 口径；jq 缺失时打 SKIPPED 不 FAIL）
#             [2026-10-08 task-v144 合并级联: v145 已合法新增 2 键（FF 守护 selftest-four-file-dataflow FF-15 断言 42 为准）,键数 40→42]
#   SR-10     SKILL.md 摘要行锚：「升级四门槛」或「四门槛」≥1
#   SR-11     selftest-skill-split.sh 级联落地锚：「task-v099」≥1 且 `-le 4/5` 前缀断言行存在（不锁具体数值）[2026-09-30 task-v099 级联: 锚 token task-v098→task-v099]
#   SR-12     selftest-registry.tsv 含「selftest-self-resolution」≥1 且总行数 = 60（脚本数 59+表头 1）
#             [2026-09-30 task-v099 级联: 锚值 39→40][2026-10-08 task-v144 合并级联: 写定数按「补登后」事实=60（selftest 脚本 59+表头）,因 periodic-review 补登由后续单元执行,若未补登时总行数=59 本断言留 FAIL——blockers 注明依赖后续单元]
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
# SR-07 字面锚：「Critical Rules 1-65」≥1 且「1-39」= 0（关键负断言）[2026-10-08 task-v144 合并级联: References 表行 label 演进,旧 'Rules 1-39'=2 改为 '1-39'=0 负断言]
# [2026-10-08 task-v147 合并级联] '1-62'→'1-63'：Rule 63 已由 task-v147 合法落地（63.1-63.6 实测六子条），锚同步演进
# [2026-10-08 task-v147 第二代级联] '1-63'→'1-64'：Rule 64 已由 task-v148 落地（64.1-64.6），锚同步演进
# [2026-10-08 task-v149 Rule 65 落地演进] '1-64'→'1-65'：Rule 65 已由 task-v149 落地（65.1-65.8 实测八子条），锚同步演进
# [2026-10-09 task-v151 S4 钉值级联] '1-65'→'1-66'：Rule 66 已由 task-v151 落地（66.1-66.6），锚同步演进
# [2026-10-09 task-v152 Rule 67 落地] '1-65'→'1-67'：Rule 67 已由 task-v152 落地，锚同步演进
a="$(grep -c 'Critical Rules 1-67' "$SKILLMD" || true)"
b="$(grep -c '1-39' "$SKILLMD" || true)"
if [ "$a" -ge 1 ] && [ "$b" -eq 0 ]; then ok 07 "SKILL.md 字面锚 Critical Rules 1-67≥1 且 1-39=0"; else bad 07 "SKILL.md 字面锚漂移（Critical Rules 1-67=$a 应 ≥1 / 1-39=$b 应 0）"; fi
# SR-08 Rule 40/41 共存零损伤
# [2026-10-05 task-v131 CR P1-2 级联: 锚「含 Rule 40/41」→「含 Rule 40-53」(SKILL.md:266 括注演进), ^40\.=6 子条断言保留]
# [2026-10-08 task-v149 Rule 65 落地演进: 括注演进→「含 Rule 40-65 全集」, 宽容正则 5[3-9]|6[0-9] 已覆盖 65, 锚同步演进]
# [2026-10-05 task-v136 S2 级联: 括注演进「40-54 全集」, 锚宽容化 40-5[3-9]（宽容正则优先）, ^40\.=6 子条断言保留]
# [2026-10-05 task-v138 合并级联: 括注演进「40-55 全集」（Rule 55 落地），宽容正则 40-5[3-9] 仍覆盖 40-55，保持宽容锚不重新钉死（v136「宽容正则优先」先例；v138 侧 40-55 固定锚在合并面让位于宽容锚，命中 40-53/54/55 任一纪元即通过，语义强度不降）]
if [ "$(grep -cE '含 Rule 40-(5[3-9]|6[0-9])' "$SKILLMD" || true)" -ge 1 ] && [ "$(grep -c '^40\.' "$CRIT" || true)" -eq 6 ]; then
  ok 08 "SKILL.md「含 Rule 40-5x」宽容锚 + critical-rules.md Rule 40 六子条 = 6（共存零损伤）"
else
  bad 08 "Rule 40/41 共存锚损伤（含 Rule 40-5[3-9] 缺失或 ^40\. 子条数 ≠6）"
fi
# SR-09 零新 config 键——properties 键数 = 42（同 WF-12 口径；jq 缺失打 SKIPPED 不 FAIL）[2026-10-08 task-v144 合并级联: v145 已合法加 2 键,FF 守护断言 42 为准]
if command -v jq >/dev/null 2>&1; then
  keys="$(jq -r '.properties|keys|length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "42" ]; then ok 09 "config.json properties 键数 42（v145 已合法加 2 键）"; else bad 09 "config.json properties 键数=$keys（应 42）"; fi
else
  printf 'SR-09 SKIPPED jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）\n'
fi
# SR-10 SKILL.md 摘要行锚（升级四门槛 / 四门槛）
if grep -qF '升级四门槛' "$SKILLMD" || grep -qF '四门槛' "$SKILLMD"; then
  ok 10 "SKILL.md 摘要行锚「升级四门槛」在位"
else
  bad 10 "SKILL.md 缺摘要行锚（升级四门槛 / 四门槛）"
fi
# SR-11 skill-split 级联落地锚（task-vNNN label 宽容正则 + -le 4 前缀断言行；数值不锁定）[2026-09-30 task-v100 锚 v098→v099;2026-10-01 task-v102 B 类扩围根治: label token 随级联任务必变（v098→v099→v102 三连断）,改宽容正则 task-v099|task-v10x,断言语义不变;2026-10-02 task-v113 基线修复: f549958 上 selftest-skill-split.sh label 已演进至 task-v112 致 SR-11 断裂,正则扩 task-v11x,断言语义不变;2026-10-03 task-v122 锚演进: skill-split label 迁至 task-v122 越出 v11x，正则扩 v12x（[10-2] 覆盖 v100-v129），断言语义不变;2026-10-08 task-v144 合并级联: skill-split label 演进 task-v144 越出 v12x 且行数钉 490→500（-le 4→-le 5）,正则扩 [10-4] 覆盖 v100-v149+-le [45],断言语义不变]
if [ "$(grep -cE 'task-v099|task-v1[0-4][0-9]' "$SPLIT" || true)" -ge 1 ] && grep -q -e '-le [45]' "$SPLIT"; then
  ok 11 "selftest-skill-split.sh task-v099/task-v1x label + -le 4/5 前缀断言行在位"
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
