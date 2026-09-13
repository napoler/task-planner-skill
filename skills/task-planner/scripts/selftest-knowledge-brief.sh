#!/usr/bin/env bash
# [2026-09-13 task-v067-knowledge-brief] selftest-knowledge-brief.sh — 任务知识简略要点(knowledge-brief)面守护套件
# 守护 templates/knowledge-brief.md 五段骨架 + 全链路接入面
# (SKILL.md / init-session.sh / check-scope.sh / check-3file-gate.sh / critical-rules.md /
#  subagent_dispatch.md / plan-writer.md / config.json#knowledge_brief_enforce) 一致性。
# 10 组用例 T1-T10, 全 PASS exit 0, 任一 FAIL exit 1。纯 grep/python3 机械断言, 无 fixture。
# 结构/style 照抄 scripts/selftest-skill-collab.sh (set -u / t() 计数器 / [PASS]/[FAIL] / Total / exit)。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."                        # <repo-root>/skills/task-planner
BRIEF="$ROOT/templates/knowledge-brief.md"
SKILL="$ROOT/SKILL.md"
INIT="$SCRIPT_DIR/init-session.sh"
SCOPE="$SCRIPT_DIR/check-scope.sh"
GATE="$SCRIPT_DIR/check-3file-gate.sh"
CRULES="$ROOT/references/critical-rules.md"
DISPATCH="$ROOT/templates/subagent_dispatch.md"
PLANWRITER="$ROOT/companion/agents/plan-writer.md"
CONFIG="$ROOT/config.json"

PASS=0; FAIL=0
t() { # t <name> <cond-expr...>
    local name="$1"; shift
    if "$@" >/dev/null 2>&1; then
        PASS=$((PASS+1)); echo "[PASS] $name"
    else
        FAIL=$((FAIL+1)); echo "[FAIL] $name"
    fi
}

# T1: knowledge-brief.md 存在 + 五段标题 + ≤150 行
t "T1a knowledge-brief.md 存在" test -f "$BRIEF"
t "T1b 五段标题 grep -c '^## §' = 5" bash -c "[ \"\$(grep -c '^## §' '$BRIEF')\" -eq 5 ]"
t "T1c 行数 ≤150" bash -c "[ \"\$(wc -l < '$BRIEF')\" -le 150 ]"

# T2: SKILL.md 引用 knowledge-brief ≥2 且行数 ≤520
t "T2a SKILL.md grep 'knowledge-brief' ≥2" bash -c "[ \"\$(grep -c 'knowledge-brief' '$SKILL')\" -ge 2 ]"
t "T2b SKILL.md 行数 ≤520" bash -c "[ \"\$(wc -l < '$SKILL')\" -le 520 ]"

# T3: init-session.sh grep 'knowledge-brief.md' ≥2 (建立循环 + 复核循环) 且 '6/6' 校验行 ≥1
t "T3a init-session.sh 'knowledge-brief.md' ≥2" bash -c "[ \"\$(grep -c 'knowledge-brief.md' '$INIT')\" -ge 2 ]"
t "T3b init-session.sh '6/6' ≥1" bash -c "[ \"\$(grep -c '6/6' '$INIT')\" -ge 1 ]"

# T4: check-scope.sh 白名单含 knowledge-brief.md ≥1
t "T4 check-scope.sh 'knowledge-brief.md' ≥1" bash -c "[ \"\$(grep -c 'knowledge-brief.md' '$SCOPE')\" -ge 1 ]"

# T5: check-3file-gate.sh 文案联动 '6 planning files' ≥1 且存在性循环首行不含 knowledge-brief (KQ3 裁定)
# [task-v067 S6] 现行 check-3file-gate.sh:42 有注释行提及 'knowledge-brief.md'（S1 文案联动 5→6 产物，
# 位于 for 循环块内），全文件 grep 非 0；KQ3 实质=存在性循环首行(:39 for f in ...)不含 brief，
# 故 T5b 断言锚定 for 行本身(整行 grep 计数=0)
t "T5a 3file-gate '6 planning files' ≥1" bash -c "[ \"\$(grep -c '6 planning files' '$GATE')\" -ge 1 ]"
t "T5b 3file-gate 存在性循环首行不含 knowledge-brief (=0, KQ3)" bash -c "[ \"\$(grep -c '^for f in .*knowledge-brief' '$GATE')\" -eq 0 ]"

# T6: critical-rules.md 'knowledge-brief' 行号覆盖 21.2 与 22.4 段 (均 >100 且 <135)
L_212=$(grep -n "knowledge-brief" "$CRULES" | grep -F '21.2' | head -1 | cut -d: -f1)
L_224=$(grep -n "knowledge-brief" "$CRULES" | grep -F '22.4' | head -1 | cut -d: -f1)
t "T6 critical-rules 21.2($L_212)+22.4($L_224) 命中且 100<行号<135" bash -c "[ '$L_212' -gt 100 ] && [ '$L_212' -lt 135 ] && [ '$L_224' -gt 100 ] && [ '$L_224' -lt 135 ] && [ '$L_212' -ne 0 ] && [ '$L_224' -ne 0 ]"

# T7: subagent_dispatch.md 知识包表行含 knowledge-brief ≥1
t "T7 subagent_dispatch.md 'knowledge-brief' ≥1" bash -c "[ \"\$(grep -c 'knowledge-brief' '$DISPATCH')\" -ge 1 ]"

# T8: plan-writer.md 'knowledge-brief|知识简略要点' ≥3
t "T8 plan-writer.md 'knowledge-brief|知识简略要点' ≥3" bash -c "[ \"\$(grep -c 'knowledge-brief\|知识简略要点' '$PLANWRITER')\" -ge 3 ]"

# T9: config.json knowledge_brief_enforce 存在 + default=warn + enum 三值
# [task-v067] 可移植性: 有 python3 走 JSON 断言; 无 python3 降级 grep 断言 (双路径风格照抄 selftest-skill-collab.sh T7)
# 键块用 sed 行内提取(避免块文本跨 shell 边界/嵌套引号转义); 断言用 test 式 [ $(...) -ge 1 ]
if command -v python3 >/dev/null 2>&1; then
    t "T9 config knowledge_brief_enforce=warn (python3)" python3 -c "
import json
k = json.load(open('$CONFIG'))['properties']['knowledge_brief_enforce']
assert k['default'] == 'warn'
assert set(k['enum']) == {'enforce','warn','off'}"
else
    t "T9 config knowledge_brief_enforce=warn (grep-fallback)" bash -c "
        c=\$(sed -n '/\"knowledge_brief_enforce\"/,/^[[:space:]]*}/p' '$CONFIG')
        [ \$(grep -c '\"default\" *: *\"warn\"' <<<\"\$c\") -ge 1 ] &&
        [ \$(grep -c '\"enforce\"' <<<\"\$c\") -ge 1 ] &&
        [ \$(grep -c '\"off\"' <<<\"\$c\") -ge 1 ]"
fi

# T10: 跨文件键名一致: knowledge_brief_enforce 出现在 config.json + SKILL.md (各 ≥1, 共 ≥2 文件)
#      且无拼写变体 knowledge-brief-enforce (两文件全 0)
t "T10a knowledge_brief_enforce 出现在 config.json+SKILL.md ≥2 文件" bash -c "[ \"\$(grep -rln 'knowledge_brief_enforce' '$CONFIG' '$SKILL' | wc -l)\" -ge 2 ]"
t "T10b 无拼写变体 knowledge-brief-enforce (全 0)" bash -c "[ \"\$(grep -rc 'knowledge-brief-enforce' '$CONFIG' '$SKILL' | awk -F: '{s+=\$2} END{print s+0}')\" -eq 0 ]"

# ── 汇总 ──
TOTAL=$((PASS + FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
