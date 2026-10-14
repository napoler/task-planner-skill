#!/usr/bin/env bash
# selftest-tool-selection.sh — task-v097 P5-S1: Rule 40 harness 工具面主动选择静态守护
# 零新 config 键范式同 v087/v088（对齐 selftest-workflow-orchestration.sh WF 断言范式）：
# 本脚本仅做静态断言（grep/wc 为主），TS-01..12 全 PASS exit 0；任一 FAIL exit 1。
#   TS-01     critical-rules.md Rule 40 六子条锚 `grep -c '^40\.'` = 6
#   TS-02     40.3 /goal 披露措辞「不可代调」≥1
#   TS-03     40.4 行含「显式点名」≥1 且 40.6 行含「零新 config 键」≥1
#   TS-04     SKILL.md `grep -c 'Rule 40'` ≥3（四锚：协同路由行/C28/摘要行/References 括注）
#   TS-05     SKILL.md `grep -c 'Critical Rules 1-67'` ≥1 且 `grep -c '1-39'` = 0（对策 b 字面锚——关键负断言）
#             [2026-10-08 task-v144 合并级联: References 表行 label 演进为「Critical Rules 1-62」,锚断言同步演进,旧 'Rules 1-39'=2 变体改为负断言 1-39=0]
#             [2026-10-08 task-v147 合并级联: '1-62'→'1-63'，Rule 63 已由 task-v147 合法落地（63.1-63.6 实测六子条），锚同步演进]
#   TS-06     SKILL.md 三个既有锚子串各 ≥1：「Rule 39（动态工作流编排」「| C27 |」「dynamic-workflows（用户显式点名」
#   TS-07     SKILL.md 含「| C28 |」≥1
#   TS-08     templates/task_plan.md 含「🧰 工具选择与编排」≥1 且含「上游分析记录」≥1
#   TS-09     templates/variant/mini-lite-type.md 含「Rule 40.2 豁免声明」=1 且 wc -l ≤80
#   TS-10     templates/subagent_dispatch.md 含「工具面提示」≥1
#   TS-11     plan-template-kit 两文档 + plan-writer 契约：template-mapping.md 含「工具选择映射」≥1；
#             template-guide.md 含「工具选择与编排」≥1；companion/agents/plan-writer.md 含「工具选择与编排区块」=1
#   TS-12     零新 config 键——config.json 顶层 properties 键数 = 42（与 WF-12 同口径；jq 缺失时打 SKIPPED 不 FAIL）
#             [2026-10-08 task-v144 合并级联: v145 已合法新增 2 键（FF 守护 selftest-four-file-dataflow FF-15 断言 42 为准）,键数 40→42]
# 静态只读（grep/wc/jq），零仓库写入；无临时文件（无需 mktemp）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# [task-v171 回归修复 2026-10-12 协同域搬迁] Rule 40（计划期工具面主动选择）属 plan-collab-router 域，原文已迁至
#   skills/plan-collab-router/references/critical-rules-collab.md；本脚本 CRIT 全部 3 处用法（TS-01/02/03 条文本体）
#   均为 Rule 40 断言、无核心域用途（已逐行核实），CRIT 改指协同域文件，断言语义零改动。
CRIT="$SKILL_ROOT/../plan-collab-router/references/critical-rules-collab.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
TPL_TASKPLAN="$SKILL_ROOT/templates/task_plan.md"
TPL_MINI="$SKILL_ROOT/templates/variant/mini-lite-type.md"
TPL_DISPATCH="$SKILL_ROOT/templates/subagent_dispatch.md"
KIT_MAPPING="$(cd "$SKILL_ROOT/.." && pwd)/plan-template-kit/references/template-mapping.md"
KIT_GUIDE="$(cd "$SKILL_ROOT/.." && pwd)/plan-template-kit/references/template-guide.md"
PLAN_WRITER="$SKILL_ROOT/companion/agents/plan-writer.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'TS-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'TS-%s FAIL %s\n' "$1" "$2"; }

# TS-01 Rule 40 六子条锚
n="$(grep -c '^40\.' "$CRIT" || true)"
if [ "$n" -eq 6 ]; then ok 01 "critical-rules.md 六子条锚 = 6"; else bad 01 "critical-rules.md 六子条锚 $n（应 6）"; fi
# TS-02 40.3 /goal 披露措辞「不可代调」≥1
n="$(grep -c '不可代调' "$CRIT" || true)"
if [ "$n" -ge 1 ]; then ok 02 "40.3 披露措辞「不可代调」命中 $n"; else bad 02 "40.3 披露措辞「不可代调」缺失"; fi
# TS-03 40.4 行「显式点名」+ 40.6 行「零新 config 键」
if grep '^40\.4' "$CRIT" | grep -q '显式点名' && grep '^40\.6' "$CRIT" | grep -q '零新 config 键'; then
  ok 03 "40.4 显式点名 + 40.6 零新 config 键 行内锚在位"
else
  bad 03 "40.4/40.6 行内锚缺失（显式点名 / 零新 config 键）"
fi
# TS-04 [task-v171 核心瘦身] SKILL.md Rule 40 锚 ≥1（卫星路由表 collab 行枚举 40）+ CRIT_C 40 标题锚
#   现象：SKILL.md 瘦身后 'Rule 40' 整串计数 3→0（摘要/C28/References 括注随瘦身退役；协同路由面仅存
#     卫星路由表 collab 行「（Rule 39,40）」区间/枚举形态，无整串），旧阈值 ≥3 恒 FAIL。
#   根因：Rule 40 属协同域；SKILL 侧联动=卫星路由表行+新指令段 L191 dynamic-workflows 行（含 (Rule 39)）。
#   修法：n=路由表 collab 行枚举 40（[0-9,-]* 宽容区间匹配）≥1 ∧ CRIT_C '^### 40 ' 标题=1。
n="$(grep -E '^\| plan-collab-router \|' "$SKILLMD" | grep -cE 'Rule [0-9,-]*40' || true)"
m="$(grep -cE '^### 40 ' "$CRIT" || true)"
if [ "$n" -ge 1 ] && [ "$m" -eq 1 ]; then ok 04 "SKILL.md 路由表 collab 行枚举 40=$n ≥1 ∧ CRIT_C 40 标题=$m"; else bad 04 "SKILL.md Rule 40 锚（路由行枚举=$n 应 ≥1 / CRIT_C 标题=$m 应 1）"; fi
# TS-05 对策 b 字面锚：「Critical Rules 1-65」≥1 且「1-39」= 0（关键负断言）[2026-10-08 task-v144 合并级联: References 表行 label 演进,旧 'Rules 1-39'=2 改为 '1-39'=0 负断言]
# [2026-10-08 task-v147 合并级联] '1-62'→'1-63'：Rule 63 已由 task-v147 合法落地（63.1-63.6 实测六子条），锚同步演进
# [2026-10-08 task-v147 第二代级联] '1-63'→'1-64'：Rule 64 已由 task-v148 落地（64.1-64.6），锚同步演进
# [2026-10-08 task-v149 Rule 65 落地演进] '1-64'→'1-65'：Rule 65 已由 task-v149 落地（65.1-65.8 实测八子条），锚同步演进
# [2026-10-09 task-v151 S4 钉值级联] '1-65'→'1-66'：Rule 66 已由 task-v151 落地（66.1-66.6），锚同步演进
# [2026-10-09 task-v152 Rule 67 落地] '1-65'→'1-67'：Rule 67 已由 task-v152 落地，锚同步演进
# [2026-10-09 task-v153 级联单元] '1-66'→'1-68'：Rule 68 已由 task-v153 落地（68.1-68.7 计划期并行调度），SKILL.md 计数锚级联 1-68，锚同步演进
# [2026-10-10 task-v154 合并并集演进] '1-68'→'1-71'：task-v153 Rule 68 与 task-v154 Rule 69 合流落地，SKILL 章节引言行最终态 1-71
# [2026-10-10 task-v160 合并并集演进] '1-69'→宽容形态 '1-(6[0-9]|7[0-2])'：task-v160 Rule 72 决策分级与用户打断纪律已落地，SKILL 章节引言行最终态 1-72；主锚由固定字面改宽容正则（覆盖 60-72 纪元，判据 ≥1 不减），负向检查 1-39=0 保留
# [2026-10-10 task-v162 合并并集演进] '1-71'→'1-7[4-9]'：task-v162 Rule 74（变更吸收三判）合流落地，字面锚同步（A 类机械替换）
# [2026-10-11 task-v166 纪元锚扩展] 旧锚→'1-7[4-9]'：Rule 76 落地后 SKILL.md 索引演进至 1-76，宽容锚覆盖 1-7X..1-7X 演进
# [2026-10-11 task-v169 Rule 80 落地纪元扩展] '1-7[4-9]'→'1-[7-8][0-9]'：Rule 80 已由 task-v169 落地，SKILL.md 全集索引演进至 1-80，宽容锚覆盖 1-7X..1-8X 纪元（判据 ≥1 不变，负断言 1-39=0 保留）
# [2026-10-12 task-v171 分层口径切换] SKILL.md 瘦身后全集声明演进为「Rules 1-80 全集索引」，旧主锚
#   'Critical Rules 1-[7-8][0-9]' 零命中；随动演进为 '1-8[013]' 全集口径锚（SR-07/TS-05/LA-12/RC-11 同批切换），1-39=0 负断言保留。
a="$(grep -cE '1-8[013]' "$SKILLMD" || true)"
b="$(grep -c '1-39' "$SKILLMD" || true)"
if [ "$a" -ge 1 ] && [ "$b" -eq 0 ]; then ok 05 "SKILL.md 字面锚 '1-8[013]' 全集口径≥1 且 1-39=0"; else bad 05 "SKILL.md 字面锚漂移（'1-80'=$a 应 ≥1 / 1-39=$b 应 0）"; fi
# [2026-10-10 task-v160 合并并集: 取 v160 宽容锚，Rule 72 落地 1-72 纪元]
# [2026-10-10 task-v163 级联: SKILL 计数演进 1-72→1-75（Rule 75 落地）, 主锚宽容正则扩 7[0-5] 纪元，判据 ≥1 不减]
# [2026-10-10 task-v162 合并并集演进] '1-71'→'1-74'：task-v162 Rule 74（变更吸收三判）合流落地，字面锚同步（A 类机械替换）——v163 主断言演进为宽容正则后保留本注释（AD-12 _pin_lit 'Critical Rules 1-74' 历史字面在位）
# TS-06 [task-v171 核心瘦身] SKILL.md 三个既有锚子串按现载体重锚（WF-07/08/09 锚保全）
#   现象：旧三字面（'Rule 39（动态工作流编排' bullet / '| C27 |' 合规行 / 'dynamic-workflows（用户显式点名'）
#     随瘦身全部退役（Rule 39/40 属协同域；SKILL 现存协同面=新指令段 L191 dynamic-workflows 行+卫星路由表 collab 行）。
#   修法：① Rule 39 载体=L191 行 '（Rule 39）' 引措；② C27 消费面=卫星路由表 collab 行；
#     ③ dynamic-workflows 措辞演进为 'dynamic-workflows 仅用户显式点名'。
if grep -qF 'dynamic-workflows 仅用户显式点名' "$SKILLMD" \
   && grep -qF '（Rule 39）' "$SKILLMD" \
   && grep -qE '^\| plan-collab-router \|' "$SKILLMD"; then
  ok 06 "SKILL.md 既有三锚现载体（dynamic-workflows 点名行/Rule 39 引措/卫星路由表 collab 行）保全"
else
  bad 06 "SKILL.md 既有锚子串断裂（dynamic-workflows 点名行 / (Rule 39) 引措 / 卫星路由表 collab 行）"
fi
# TS-07 [task-v171 核心瘦身] C28 清单项 → 卫星路由表 collab 行（C28 合规面瘦身后由路由表承载）
n="$(grep -cE '^\| plan-collab-router \|' "$SKILLMD" || true)"
if [ "$n" -ge 1 ]; then ok 07 "SKILL.md 卫星路由表 collab 行在位（C28 合规面载体）"; else bad 07 "SKILL.md 缺 C28 现载体（卫星路由表 collab 行）"; fi
# TS-08 general 模板「🧰 工具选择与编排」区块 + 定位声明
if grep -qF '🧰 工具选择与编排' "$TPL_TASKPLAN" && grep -q '上游分析记录' "$TPL_TASKPLAN"; then
  ok 08 "general 模板 🧰 区块与「上游分析记录」定位声明在位"
else
  bad 08 "general 模板缺 🧰 区块或定位声明"
fi
# TS-09 mini-lite 豁免声明 =1 且行数 ≤80（Rule 38.3 白名单延伸）
n="$(grep -c 'Rule 40.2 豁免声明' "$TPL_MINI" || true)"
lines="$(wc -l < "$TPL_MINI")"
if [ "$n" -eq 1 ] && [ "$lines" -le 80 ]; then ok 09 "mini-lite 豁免声明 =1 且 ${lines} 行 ≤80"; else bad 09 "mini-lite 豁免声明 $n（应 1）或行数 ${lines} >80"; fi
# TS-10 subagent_dispatch 工具面提示行
n="$(grep -c '工具面提示' "$TPL_DISPATCH" || true)"
if [ "$n" -ge 1 ]; then ok 10 "subagent_dispatch 工具面提示行在位"; else bad 10 "subagent_dispatch 缺工具面提示行"; fi
# TS-11 卫星两文档 + plan-writer 契约
if grep -q '工具选择映射' "$KIT_MAPPING" \
   && grep -q '工具选择与编排' "$KIT_GUIDE" \
   && [ "$(grep -c '工具选择与编排区块' "$PLAN_WRITER" || true)" -eq 1 ]; then
  ok 11 "卫星两文档 + plan-writer 契约锚在位"
else
  bad 11 "卫星 template-mapping/template-guide 或 plan-writer 契约锚缺失"
fi
# TS-12 零新 config 键——properties 键数 = 42（与 WF-12 同口径；jq 缺失打 SKIPPED 不 FAIL）[2026-10-08 task-v144 合并级联: v145 已合法加 2 键,FF 守护断言 42 为准]
if command -v jq >/dev/null 2>&1; then
  keys="$(jq -r '.properties|keys|length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "46" ]; then ok 12 "config.json properties 键数 46（v145 2 键 + task-v172 合法新增 2 键）"; else bad 12 "config.json properties 键数=$keys（应 46）"; fi
else
  printf 'TS-12 SKIPPED jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）\n'
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
