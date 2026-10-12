#!/usr/bin/env bash
# [2026-09-13 task-v066-skill-collab-routing] selftest-skill-collab.sh — 协同路由面守护套件
# 守护 ../plan-collab-router/references/skill-collaboration.md + SKILL.md 指针 + critical-rules.md 22.3.3/22.7
# + subagent-fallback.sh tier_order + config.json#skill_collab_enforce 一致性。
# 10 组用例 T1-T10，共 19 断言, 全 PASS exit 0, 任一 FAIL exit 1。纯 grep/python3 机械断言, 无 fixture。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."                       # <repo-root>/skills/task-planner
# [task-v095 P5] skill-collaboration.md 迁至卫星 plan-collab-router，COLLAB 路径跟随迁移
COLLAB="$ROOT/../plan-collab-router/references/skill-collaboration.md"
SKILL="$ROOT/SKILL.md"
CRULES="$ROOT/references/critical-rules.md"
CONFIG="$ROOT/config.json"
# [task-v171 回归修复 2026-10-12 派发域搬迁] 现象: T6a/T6b FAIL(grep 目标文件不存在)｜
# 根因: subagent-fallback.sh 随派发域迁至 skills/task-dispatch/scripts, 旧写法 $SCRIPT_DIR/../task-dispatch
#   少一级, 解析到 skills/task-planner/task-dispatch(不存在)｜修法: 改锚 $ROOT/../task-dispatch/scripts
#   (ROOT=skills/task-planner, 再上溯一级到 skills/ 后进 task-dispatch)
FALLBACK="$ROOT/../task-dispatch/scripts/subagent-fallback.sh"

PASS=0; FAIL=0
t() { # t <name> <cond-expr...>
    local name="$1"; shift
    if "$@" >/dev/null 2>&1; then
        PASS=$((PASS+1)); echo "[PASS] $name"
    else
        FAIL=$((FAIL+1)); echo "[FAIL] $name"
    fi
}

# T1: skill-collaboration.md 存在, ≤300 行, 四关键词各 ≥1
t "T1a 文件存在" test -f "$COLLAB"
t "T1b 行数 ≤300" bash -c "[ \"\$(wc -l < '$COLLAB')\" -le 300 ]"
t "T1c 含 三族" grep -q '三族' "$COLLAB"
t "T1d 含 触发矩阵" grep -q '触发矩阵' "$COLLAB"
t "T1e 含 22.3.3" grep -q '22.3.3' "$COLLAB"
t "T1f 含 移交" grep -q '移交' "$COLLAB"

# T2: SKILL.md 有「专业技能协同路由」且引用 skill-collaboration.md ≥2
t "T2a SKILL.md 含 专业技能协同路由" grep -q '专业技能协同路由' "$SKILL"
t "T2b skill-collaboration.md 引用 ≥2" bash -c "[ \"\$(grep -c 'skill-collaboration.md' '$SKILL')\" -ge 2 ]"

# T3 [task-v171 核心瘦身] SKILL.md comet 规则语义保留（任意 3 项）——SKILL 协同路由段瘦身后措辞收敛，
#   '任意 3 项' 细则随条文归 skill-collaboration.md（collab 权威源，实测在位）；SKILL 侧保留 comet 主路由指针。
#   修法：改断言 SKILL 含 'comet' ∧ COLLAB 含 '任意 3 项'（语义双载体）。
t "T3 SKILL 含 comet 路由 ∧ COLLAB 含 任意 3 项" bash -c "grep -q 'comet' '$SKILL' && grep -q '任意 3 项' '$COLLAB'"

# T4 [task-v171 派发域搬迁] critical-rules.md → DISP_RULES（Rule 22.3.x/22.4 迁 critical-rules-dispatch.md）
CRULES_DISP="$ROOT/../task-dispatch/references/critical-rules-dispatch.md"
L_2231=$(grep -n '^22\.3\.1' "$CRULES_DISP" | head -1 | cut -d: -f1)
L_2233=$(grep -n '^22\.3\.3' "$CRULES_DISP" | head -1 | cut -d: -f1)
L_224=$(grep -n '^22\.4 ' "$CRULES_DISP" | head -1 | cut -d: -f1)
t "T4 行号序 22.3.1($L_2231) < 22.3.3($L_2233) < 22.4($L_224)" bash -c "[ '$L_2231' -ne 0 ] && [ '$L_2233' -ne 0 ] && [ '$L_224' -ne 0 ] && [ '$L_2231' -lt '$L_2233' ] && [ '$L_2233' -lt '$L_224' ]"

# T5 [task-v171 派发域搬迁] 22.7 行含 22.3.3 协同接管评估（CRULES→DISP_RULES，穷尽集合已扩）
t "T5 22.7 行含 22.3.3 协同接管评估" bash -c "grep -n '^22\.7 ' '$CRULES_DISP' | grep -q '22\.3\.3 协同接管评估'"

# T6: subagent-fallback.sh 含 skill_takeover, 两分支 tier_order 全串 ≥2 处
t "T6a skill_takeover ≥1" grep -q 'skill_takeover' "$FALLBACK"
t "T6b tier_order 全串 2 处(timeout+non_provider)" bash -c "[ \"\$(grep -c '\"dispatch_swap\",\"split\",\"model_downgrade\",\"main_takeover\",\"skill_takeover\",\"ask_user\"' '$FALLBACK')\" -ge 2 ]"

# T7: config.json 合法且 skill_collab_enforce default=warn + enum 三值
# [2026-09-13 task-v066 P2] 可移植性: 有 python3 走 JSON 断言; 无 python3 降级 grep 断言(键块内三值各 ≥1)
# 键块用 sed 行内提取(避免块文本跨 shell 边界/嵌套引号转义); 断言用 test 式 [ $(...) -ge 1 ]
if command -v python3 >/dev/null 2>&1; then
    t "T7 config skill_collab_enforce=warn (python3)" python3 -c "
import json
k = json.load(open('$CONFIG'))['properties']['skill_collab_enforce']
assert k['default'] == 'warn'
assert set(k['enum']) == {'enforce','warn','off'}"
else
    # grep -c 的退出码: 0 命中 ≥1 / 1 命中 = 0(并非"永远非零"); 用 test 式 [ $(...) -ge 1 ]
    # 避免把"命中"误读为"成功"——这是 P2 可移植性微修踩过的坑, 注释留档
    t "T7 config skill_collab_enforce=warn (grep-fallback)" bash -c "
        c=\$(sed -n '/\"skill_collab_enforce\"/,/^[[:space:]]*}/p' '$CONFIG')
        [ \$(grep -c '\"default\" *: *\"warn\"' <<<\"\$c\") -ge 1 ] &&
        [ \$(grep -c '\"enforce\"' <<<\"\$c\") -ge 1 ] &&
        [ \$(grep -c '\"off\"' <<<\"\$c\") -ge 1 ]"
fi

# T8: CLI 探针条款 command -v comet 在 collaboration.md 与 SKILL.md 各 ≥1
t "T8a collaboration.md 含 command -v comet" grep -q 'command -v comet' "$COLLAB"
# T8b [task-v171 核心瘦身] SKILL.md CLI 探针字面随协同路由段瘦身退役（'command -v comet' 细则归 COLLAB 权威源）；
#   SKILL 侧现存协同面=comet 主路由指针（L186 'comet/OpenSpec/superpowers/dynamic-workflows 权威源=skill-collaboration.md'）。
#   修法：改断言 SKILL 含 'comet' ∧ COLLAB 含 'command -v comet'（探针语义双载体）。
t "T8b SKILL 含 comet 指针 ∧ COLLAB 含 command -v comet" bash -c "grep -q 'comet' '$SKILL' && grep -q 'command -v comet' '$COLLAB'"

# T9: 键名跨文件一致 ≥2 文件, 无连字符变体
# [task-v171 核心瘦身] 原第二面（SKILL.md 引用键名）随瘦身退役；现存合法载体=config.json schema + plan-collab-router
#   两文件（SKILL.md 与 references/ 实测零命中），键名一致性面改扫 CONFIG + COLLAB_SKILL + COLLAB_REF。
t "T9a skill_collab_enforce 出现在 ≥2 文件" bash -c "[ \"\$(grep -rl 'skill_collab_enforce' '$CONFIG' '$ROOT/../plan-collab-router/SKILL.md' '$ROOT/../plan-collab-router/references/skill-collaboration.md' | wc -l)\" -ge 2 ]"
t "T9b 无连字符变体 skill-collab-enforce" bash -c "! grep -rq 'skill-collab-enforce' '$CONFIG' '$ROOT/references/' '$SKILL' '$ROOT/../plan-collab-router/'"

# T10: SKILL.md 行数 ≤558（task-v073 Rule 32 摘要行+C20+否决登记指针 联动后 SKILL.md 529 行,上限同步 530→538; [2026-09-17 task-v079] Rule 36 联动净增 3 行,上限 538→548(B 类扩围 Decisions ⑧); [2026-09-20 task-v085] 机制画像增量 548→549; [2026-09-22 task-v087] Rule 8.1 D 类联动 551→555, 上限 552→555; [2026-09-23 task-v088] Rule 39 联动 555→558, 上限 555→558)
t "T10 SKILL.md 行数 ≤558" bash -c "[ \"\$(wc -l < '$SKILL')\" -le 558 ]"

# T11: [2026-09-17 task-v080] 网络调研/网页访问路由显式化(SKILL.md 调研链 L458 注记+平台适配声明+路由表行)
# [task-v095 P2] 调研链正文已迁至卫星 plan-research-router/references/research-routing.md，T11 断言跟随迁移（修改原因见 plans/task-v095-skill-split）
RRT="$ROOT/../plan-research-router/references/research-routing.md"   # 卫星引用, 同级相对解析(保持脚本既有 $ROOT 解析风格)
# T11a [task-v171 核心瘦身] SKILL.md 调研链正文与 browser-use 字面随瘦身退役（调研 SOP=卫星 research-routing.md，SKILL L186 指针）；
#   修法：改断言 SKILL 含 research-routing.md 指针 ∧ RRT 含 browser-use ≥1（调研链可达性双载体）。
t "T11a SKILL 调研 SOP 指针 ∧ routing.md browser-use 路由" bash -c "grep -q 'research-routing.md' '$SKILL' && [ \"\$(grep -c 'browser-use' '$RRT')\" -ge 1 ]"
t "T11b 调研链 research-assistant 主通道定位" grep -q '网络调研主通道' "$RRT"
t "T11c 平台适配声明(禁假设不存在 MCP, 恰 1 行)" bash -c "[ \"\$(grep -c 'playwright' '$RRT')\" -eq 1 ]"
# T11d [task-v171 核心瘦身] SKILL.md 路由表网页访问行随瘦身退役（'网页访问（JS 渲染/登录态/交互页）' 细则归 COLLAB 权威源，实测在位）；
#   修法：改断言 COLLAB 含 '网页访问' ∧ SKILL 含 plan-collab-router 路由行（协同路由面在位可达）。
t "T11d COLLAB 网页访问行 ∧ SKILL 协同路由行" bash -c "grep -q '网页访问' '$COLLAB' && grep -q 'plan-collab-router' '$SKILL'"

# T12: [2026-09-17 task-v080] collaboration.md §二矩阵 research-assistant/browser-use 行
t "T12a collab 矩阵 research-assistant 行" grep -q 'research-assistant（嵌入，网络调研触发' "$COLLAB"
t "T12b collab 矩阵 browser-use 行" grep -q 'browser-use（嵌入，网页访问触发' "$COLLAB"

# ── 汇总 ──
TOTAL=$((PASS + FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
