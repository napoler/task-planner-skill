#!/usr/bin/env bash
# selftest-self-resolution.sh — task-v098 P3-S4: Rule 41 问题自主消解与升级纪律静态守护
# 范式同 selftest-tool-selection.sh（SCRIPT_DIR/SKILL_ROOT 解析、ok()/bad() 结构、Total 行、exit 语义同构）：
# 本脚本仅做静态断言（grep/wc/jq 为主），SR-01..SR-13 全 PASS exit 0；任一 FAIL exit 1。
#   SR-01     critical-rules.md Rule 41 六子条锚 `grep -cE '^41\.[0-9]+ \*\*'` = 6
#             [2026-10-10 task-v155 级联修复: 原锚 ^41\. 误计 Rule 70.5 行内「41.5 打包呈报补四要素」文本（行首 41.5 被 ^41\. 匹配），计数 7≠6。
#             根因=70.5 条文引用 41.5 时行首恰好为「41.5 」格式，与子条标题 41.x 行首同形。
#             修法=精确化为 ^41\.[0-9]+ \*\* 匹配子条标题加粗格式（41.x **标题**），排除 70.5 行内联引用。]
#   SR-02     41.2 升级四门槛区域锚：全文件「G1」「G4」各 ≥1
#   SR-03     消解清单措辞锚：「已尝试清单」≥1 且「D6 硬停点语义保留不弱化」≥1
#   SR-04     trivial 自主裁定措辞锚：「直接做」≥1 且「留用户裁决」≥1
#   SR-05     41.6 行内锚：「零新 config 键」≥1 且「selftest-self-resolution.sh」≥1
#   SR-06     SKILL.md `grep -c 'Rule 41'` ≥3 且 `grep -c '| C29 |'` = 1（合规清单 C29 项）
#   SR-07     SKILL.md `grep -c 'Critical Rules 1-67'` ≥1 且 `grep -c '1-39'` = 0（字面锚——关键负断言）
#             [2026-10-08 task-v144 合并级联: References 表行 label 演进为「Critical Rules 1-62」,锚断言同步演进,旧 'Rules 1-39'=2 变体改为负断言 1-39=0]
#             [2026-10-08 task-v147 合并级联: '1-62'→'1-63'，Rule 63 已由 task-v147 合法落地（63.1-63.6 实测六子条），锚同步演进]
#   SR-08     SKILL.md 含「含 Rule 40-(5[3-9]|6[0-9]|7[0-6]|80)」≥1 且 critical-rules.md `grep -c '^40\.'` = 6（Rule 40/41 共存零损伤）
#             [2026-10-11 task-v169 纪元锚扩展: 交替集末段 7[0-6]→7[0-6]|80（Rule 80 落地, 覆盖 40-80 全集；^40\.=6 子条断言保留）]
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
# [task-v171 纪律域搬迁 2026-10-12] Rule 41（问题自主消解与升级纪律）属纪律域，原文已迁至
#   skills/task-discipline/references/critical-rules-discipline.md（核心 critical-rules.md 只剩 11 条核心规则）；
#   SR-01..SR-05 的 CRIT 断言改指 CRIT_D；CRIT 保留指向核心。
#   注（批2/3 重定向本轮执行）：SR-08 的 ^40. 属 plan-collab-router 域（Rule 40 已迁 critical-rules-collab.md），
#   SR-13 的 22.3.0 属 task-dispatch 域（Rule 22 已迁 critical-rules-dispatch.md）——分别改指 CRIT_C/DISP_RULES。
CRIT_D="$SKILL_ROOT/../task-discipline/references/critical-rules-discipline.md"
CRIT_C="$SKILL_ROOT/../plan-collab-router/references/critical-rules-collab.md"
DISP_RULES="$SKILL_ROOT/../task-dispatch/references/critical-rules-dispatch.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
SPLIT="$SKILL_ROOT/scripts/selftest-skill-split.sh"
REGISTRY="$SKILL_ROOT/scripts/selftest-registry.tsv"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'SR-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'SR-%s FAIL %s\n' "$1" "$2"; }

# SR-01 Rule 41 六子条锚（精确锚排除 70.5 行内联引用，2026-10-10 task-v155）
n="$(grep -cE '^41\.[0-9]+ \*\*' "$CRIT_D" || true)"
if [ "$n" -eq 6 ]; then ok 01 "critical-rules.md 六子条锚 = 6"; else bad 01 "critical-rules.md 六子条锚 $n（应 6）"; fi
# SR-02 41.2 升级四门槛 G1/G4 锚（全文件各 ≥1）
if [ "$(grep -c 'G1' "$CRIT_D" || true)" -ge 1 ] && [ "$(grep -c 'G4' "$CRIT_D" || true)" -ge 1 ]; then
  ok 02 "critical-rules.md G1/G4 门槛锚各 ≥1"
else
  bad 02 "critical-rules.md G1/G4 门槛锚缺失"
fi
# SR-03 消解清单措辞锚
if [ "$(grep -c '已尝试清单' "$CRIT_D" || true)" -ge 1 ] && [ "$(grep -c 'D6 硬停点语义保留不弱化' "$CRIT_D" || true)" -ge 1 ]; then
  ok 03 "「已尝试清单」+「D6 硬停点语义保留不弱化」措辞锚在位"
else
  bad 03 "消解清单措辞锚缺失（已尝试清单 / D6 硬停点语义保留不弱化）"
fi
# SR-04 trivial 自主裁定措辞锚
if [ "$(grep -c '直接做' "$CRIT_D" || true)" -ge 1 ] && [ "$(grep -c '留用户裁决' "$CRIT_D" || true)" -ge 1 ]; then
  ok 04 "trivial 裁定措辞「直接做」+「留用户裁决」在位"
else
  bad 04 "trivial 裁定措辞锚缺失（直接做 / 留用户裁决）"
fi
# SR-05 41.6 行内锚（零新 config 键 + 守护脚本名）
if grep '^41\.6' "$CRIT_D" | grep -q '零新 config 键' && grep '^41\.6' "$CRIT_D" | grep -q 'selftest-self-resolution.sh'; then
  ok 05 "41.6 行内锚（零新 config 键 / selftest-self-resolution.sh）在位"
else
  bad 05 "41.6 行内锚缺失（零新 config 键 / selftest-self-resolution.sh）"
fi
# SR-06 [task-v171 核心瘦身] SKILL.md Rule 41 锚 ≥1（卫星路由表 discipline 行枚举 41）+ C29 合规行 → 路由行载体
#   现象：SKILL.md 瘦身后 'Rule 41' 计数 3→0（摘要 bullet/合规 C29 行/正文引措全随瘦身移除），SR-06 恒 FAIL。
#   根因：Rule 41 属纪律域；SKILL 侧入口=卫星路由表 discipline 行（41 以区间 41-45 形态覆盖，无整串）。
#   修法：n=路由表 discipline 行枚举 41（≥1）；c=CRIT_D '^### 41 ' 标题=1（C29 合规面对应条款本体在位）。
n="$(grep -E '^\| task-discipline \|' "$SKILLMD" | grep -cE 'Rule [0-9,-]*41' || true)"
c="$(grep -cE '^### 41 ' "$CRIT_D" || true)"
if [ "$n" -ge 1 ] && [ "$c" -eq 1 ]; then ok 06 "SKILL.md 路由表 discipline 行枚举 41=$n ≥1 ∧ CRIT_D Rule 41 标题=1"; else bad 06 "SKILL.md 路由表 41 枚举 $n（应 ≥1）或 CRIT_D 41 标题 $c（应 1）"; fi
# SR-07 字面锚：「Critical Rules 1-65」≥1 且「1-39」= 0（关键负断言）[2026-10-08 task-v144 合并级联: References 表行 label 演进,旧 'Rules 1-39'=2 改为 '1-39'=0 负断言]
# [2026-10-08 task-v147 合并级联] '1-62'→'1-63'：Rule 63 已由 task-v147 合法落地（63.1-63.6 实测六子条），锚同步演进
# [2026-10-08 task-v147 第二代级联] '1-63'→'1-64'：Rule 64 已由 task-v148 落地（64.1-64.6），锚同步演进
# [2026-10-08 task-v149 Rule 65 落地演进] '1-64'→'1-65'：Rule 65 已由 task-v149 落地（65.1-65.8 实测八子条），锚同步演进
# [2026-10-09 task-v151 S4 钉值级联] '1-65'→'1-66'：Rule 66 已由 task-v151 落地（66.1-66.6），锚同步演进
# [2026-10-09 task-v152 Rule 67 落地] '1-65'→'1-67'：Rule 67 已由 task-v152 落地，锚同步演进
# [2026-10-09 task-v153 级联单元] '1-66'→'1-68'：Rule 68 已由 task-v153 落地（68.1-68.7 计划期并行调度），SKILL.md 计数锚级联 1-68，锚同步演进
# [2026-10-10 task-v154 合并并集演进] '1-68'→'1-71'：task-v153 Rule 68 与 task-v154 Rule 69 合流落地，SKILL 章节引言行最终态 1-71
# [2026-10-10 task-v160 S14d 新纪元锚扩] 字面 '1-69'→宽容 '1-(6[0-9]|7[0-2])'：SKILL 索引现状三处「1-72」(:9/:295/:380)，Rule 72 已落地；判据不减，仅主锚扩 6x-7x 纪元
# [2026-10-10 task-v162 合并并集演进] '1-71'→宽容 7[4-9] 纪元：task-v162 Rule 74（变更吸收三判）合流落地，字面锚同步（A 类机械替换）；v166/v169 再扩至覆盖 1-80（见下行）
# [2026-10-11 task-v166→task-v169 纪元锚扩展] v166：SKILL.md 索引演进至 1-76（宽容 7[4-9] 纪元，AD-12 pin 目标形态）；v169：Rule 80 落地后 SKILL.md 全集索引演进至 1-80，宽容正则扩为 'Critical Rules 1-[7-8][0-9]'（覆盖 1-70..1-89 含 1-74..1-79 历史纪元与 1-80），判据 ≥1 不减、1-39=0 负断言不动
# [2026-10-12 task-v171 分层口径切换] SKILL.md 瘦身后全集声明演进为「Rules 1-80 全集索引」，旧主锚
#   'Critical Rules 1-[7-8][0-9]'（区间字面）零命中；随动演进为 '1-80' 全集口径锚（SR-07/TS-05/LA-12/RC-11 同批切换），1-39=0 负断言不动。
a="$(grep -cE '1-[89][0-9]' "$SKILLMD" || true)"
b="$(grep -c '1-39' "$SKILLMD" || true)"
if [ "$a" -ge 1 ] && [ "$b" -eq 0 ]; then ok 07 "SKILL.md 字面锚 '1-[89][0-9]' 全集口径≥1 且 1-39=0"; else bad 07 "SKILL.md 字面锚漂移（'1-80'=$a 应 ≥1 / 1-39=$b 应 0）"; fi
# [2026-10-10 task-v160 合并并集: 取 v160 宽容锚，Rule 72 落地 1-72 纪元]
# [2026-10-10 task-v163 级联: SKILL 计数演进 1-72→1-75（Rule 75 网络调研主动激活落地）, 主锚宽容正则扩 7[0-5] 纪元，判据 ≥1 不减]
# [2026-10-10 task-v162 合并并集演进] '1-71'→'1-74'：task-v162 Rule 74（变更吸收三判）合流落地，字面锚同步（A 类机械替换）——v163 主断言演进为宽容正则后保留本注释（AD-12 _pin_lit 'Critical Rules 1-74' 历史字面在位）
# SR-08 Rule 40/41 共存零损伤
# [2026-10-05 task-v131 CR P1-2 级联: 锚「含 Rule 40/41」→「含 Rule 40-53」(SKILL.md:266 括注演进), ^40\.=6 子条断言保留]
# [2026-10-08 task-v149 Rule 65 落地演进: 括注演进→「含 Rule 40-65 全集」, 宽容正则 5[3-9]|6[0-9] 已覆盖 65, 锚同步演进]
# [2026-10-05 task-v136 S2 级联: 括注演进「40-54 全集」, 锚宽容化 40-5[3-9]（宽容正则优先）, ^40\.=6 子条断言保留]
# [2026-10-05 task-v138 合并级联: 括注演进「40-55 全集」（Rule 55 落地），宽容正则 40-5[3-9] 仍覆盖 40-55，保持宽容锚不重新钉死（v136「宽容正则优先」先例；v138 侧 40-55 固定锚在合并面让位于宽容锚，命中 40-53/54/55 任一纪元即通过，语义强度不降）]
# [2026-10-10 task-v158 source-anchor-discipline: SKILL.md:288 实态=「含 Rule 40-71 全集」, 宽容正则扩 7x 纪元 5[3-9]|6[0-9]|7[0-1], ^40\. 子条数断言保留不动]
# [2026-10-10 task-v162 合并并集演进: 实态=「含 Rule 40-74 全集」, 7x 纪元上界 7[0-1]→7[0-4]（B 类宽容锚演进，覆盖 74；^40\. 子条数断言保留不动）]
# [2026-10-11 task-v166 纪元演进: 实态=「含 Rule 40-76 全集」, 7x 纪元上界 7[0-4]→7[0-6]（Rule 76 落地, 宽容正则覆盖 76；^40\. 子条数断言保留不动）]
# [2026-10-11 task-v169 纪元锚扩展: 实态=「含 Rule 40-80 全集」, 交替集末段 7[0-6]→7[0-6]|80（Rule 80 落地, 宽容交替集补 80 成员, 判据 ≥1 不减；^40\. 子条数断言保留不动）]
# [2026-10-12 task-v171 双迁移执行] SKILL 侧 '含 Rule 40-NN 全集' 括注随瘦身演进为 '1-80' 全集口径；
#   ^40\. 六子条本体随 Rule 40 迁 plan-collab-router（CRIT→CRIT_C）。宽容锚演进史（v131..v169）保留如上。
if [ "$(grep -cE '1-[89][0-9]' "$SKILLMD" || true)" -ge 1 ] && [ "$(grep -c '^40\.' "$CRIT_C" || true)" -eq 6 ]; then
  ok 08 "SKILL.md '1-[89][0-9]' 全集口径锚 + CRIT_C Rule 40 六子条 = 6（共存零损伤）"
else
  bad 08 "Rule 40/41 共存锚损伤（'1-[89][0-9]' 缺失或 CRIT_C ^40\. 子条数 ≠6）"
fi
# SR-09 零新 config 键——properties 键数 = 42（同 WF-12 口径；jq 缺失打 SKIPPED 不 FAIL）[2026-10-08 task-v144 合并级联: v145 已合法加 2 键,FF 守护断言 42 为准]
if command -v jq >/dev/null 2>&1; then
  keys="$(jq -r '.properties|keys|length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "48" ]; then ok 09 "config.json properties 键数 48（v145 2 键 + task-v172 合法新增 2 键；P-01 合法新增 evidence_anchor_enforce 1 键 46→47）"; else bad 09 "config.json properties 键数=$keys（应 48）"; fi
else
  printf 'SR-09 SKIPPED jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）\n'
fi
# SR-10 [task-v171 核心瘦身] SKILL.md 摘要行锚（升级四门槛/四门槛）→ CRIT_D 41.2 条款锚
#   现象：SKILL.md 瘦身后 Rule 41 摘要行（'升级四门槛' 字样）移除，双字面命中=0，SR-10 恒 FAIL。
#   根因：Rule 41 属纪律域；「四门槛」条款本体在 CRIT_D 41.2（实测 7 处命中）。
#   修法：改断言 CRIT_D 含 '四门槛' ≥1（摘要行瘦身后由条款本体锚承接）。
if grep -qF '升级四门槛' "$CRIT_D" || grep -qF '四门槛' "$CRIT_D"; then
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
# SR-13 [task-v171 派发域搬迁] task-v113 扩档级联锚：22.3.0 资料先行档 + 22.3.0b 换道义务（CRIT→DISP_RULES）
#   现象：Rule 22.3.0（资料先行档）随派发域迁 critical-rules-dispatch.md，核心 CRIT 命中=0，SR-13 恒 FAIL。
#   根因：22.3.0 属 task-dispatch 域（Rule 22 迁出）；四关键词锚（资料先行/换道评估顺序/官方文档）实测在 DISP_RULES。
#   修法：CRIT→DISP_RULES（四条件断言语义零改动）。
n2230="$(grep -c '^22\.3\.0 ' "$DISP_RULES" || true)"
k1="$(grep -c '资料先行' "$DISP_RULES" || true)"
k2="$(grep -c '换道评估顺序' "$DISP_RULES" || true)"
k3="$(grep -c '官方文档' "$DISP_RULES" || true)"
if [ "$n2230" -ge 1 ] && [ "$k1" -ge 1 ] && [ "$k2" -ge 1 ] && [ "$k3" -ge 1 ]; then
  ok 13 "22.3.0 资料先行档行存在 + 资料先行/换道评估顺序/官方文档 关键词在位"
else
  bad 13 "22.3.0 扩档锚缺失（^22.3.0 行=$n2230 应 ≥1 / 资料先行=$k1 / 换道评估顺序=$k2 / 官方文档=$k3）"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
