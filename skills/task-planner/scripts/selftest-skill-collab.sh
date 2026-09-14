#!/usr/bin/env bash
# [2026-09-13 task-v066-skill-collab-routing] selftest-skill-collab.sh — 协同路由面守护套件
# 守护 references/skill-collaboration.md + SKILL.md 指针 + critical-rules.md 22.3.3/22.7
# + subagent-fallback.sh tier_order + config.json#skill_collab_enforce 一致性。
# 10 组用例 T1-T10，共 19 断言, 全 PASS exit 0, 任一 FAIL exit 1。纯 grep/python3 机械断言, 无 fixture。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."                       # <repo-root>/skills/task-planner
COLLAB="$ROOT/references/skill-collaboration.md"
SKILL="$ROOT/SKILL.md"
CRULES="$ROOT/references/critical-rules.md"
CONFIG="$ROOT/config.json"
FALLBACK="$SCRIPT_DIR/subagent-fallback.sh"

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

# T3: SKILL.md comet 规则语义保留（任意 3 项）
t "T3 SKILL.md 含 任意 3 项" grep -q '任意 3 项' "$SKILL"

# T4: critical-rules.md 行号序 22.3.1 < 22.3.3 < 22.4
L_2231=$(grep -n '^22\.3\.1' "$CRULES" | head -1 | cut -d: -f1)
L_2233=$(grep -n '^22\.3\.3' "$CRULES" | head -1 | cut -d: -f1)
L_224=$(grep -n '^22\.4 ' "$CRULES" | head -1 | cut -d: -f1)
t "T4 行号序 22.3.1($L_2231) < 22.3.3($L_2233) < 22.4($L_224)" bash -c "[ '$L_2231' -ne 0 ] && [ '$L_2233' -ne 0 ] && [ '$L_224' -ne 0 ] && [ '$L_2231' -lt '$L_2233' ] && [ '$L_2233' -lt '$L_224' ]"

# T5: 22.7 行含 22.3.3 协同接管评估（穷尽集合已扩）
t "T5 22.7 行含 22.3.3 协同接管评估" bash -c "grep -n '^22\.7 ' '$CRULES' | grep -q '22\.3\.3 协同接管评估'"

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
t "T8b SKILL.md 含 command -v comet" grep -q 'command -v comet' "$SKILL"

# T9: 键名跨文件一致 ≥2 文件, 无连字符变体
t "T9a skill_collab_enforce 出现在 ≥2 文件" bash -c "[ \"\$(grep -rl 'skill_collab_enforce' '$CONFIG' '$ROOT/references/' '$SKILL' | wc -l)\" -ge 2 ]"
t "T9b 无连字符变体 skill-collab-enforce" bash -c "! grep -rq 'skill-collab-enforce' '$CONFIG' '$ROOT/references/' '$SKILL'"

# T10: SKILL.md 行数 ≤523（task-v070 计划确认段扩充后 SKILL.md 519 行,上限同步 518→519）
t "T10 SKILL.md 行数 ≤523" bash -c "[ \"\$(wc -l < '$SKILL')\" -le 523 ]"

# ── 汇总 ──
TOTAL=$((PASS + FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
