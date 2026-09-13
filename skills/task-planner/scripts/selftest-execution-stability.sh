#!/usr/bin/env bash
# [2026-09-13 task-v068-execution-stability] selftest-execution-stability.sh — 环境级中断自愈面守护套件
# 守护 task-v068 自愈矩阵 6 行已落地机制清单 + 新键 config.json#hook_self_heal_enforce
# (check-scope memories 豁免 / plan-created 兜底清除 / PostToolUse 自动重锁 / attest-plan
#  attested_by_sid / UPS env sid 兜底 / check-delegation observe 节流 / config 键 / SKILL.md 条款
# / 跨文件键名一致 / v067 回归哨兵) 一致性。
# 10 组用例 T1-T10, 全 PASS exit 0, 任一 FAIL exit 1。纯 grep/python3 机械断言, 无 fixture。
# 结构/style 照抄 scripts/selftest-knowledge-brief.sh (set -u / t() 计数器 / [PASS]/[FAIL] / Total / exit)。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."                        # <repo-root>/skills/task-planner
SKILL="$ROOT/SKILL.md"
CONFIG="$ROOT/config.json"
SCOPE="$SCRIPT_DIR/check-scope.sh"
PLANCREATED="$SCRIPT_DIR/plan-created.cjs"
POSTTOOL="$SCRIPT_DIR/zcode-posttooluse.sh"
ATTEST="$SCRIPT_DIR/attest-plan.sh"
UPS="$SCRIPT_DIR/zcode-userpromptsubmit.sh"
DELEG="$SCRIPT_DIR/check-delegation.sh"
INIT="$SCRIPT_DIR/init-session.sh"
BRIEF="$ROOT/templates/knowledge-brief.md"

PASS=0; FAIL=0
t() { # t <name> <cond-expr...>
    local name="$1"; shift
    if "$@" >/dev/null 2>&1; then
        PASS=$((PASS+1)); echo "[PASS] $name"
    else
        FAIL=$((FAIL+1)); echo "[FAIL] $name"
    fi
}

# T1: check-scope.sh memory 写入豁免在位 (E1)
t "T1 check-scope.sh 'memories' 豁免 ≥1" bash -c "[ \"\$(grep -c 'memories' '$SCOPE')\" -ge 1 ]"

# T2: plan-created.cjs 无 sid 兜底清除在位 (E1'/KQ1) + 保留旧文案行为注释在位
#     现行为=零残留才打印旧文案('无残留哨兵需兜底清除'), 注释行 :211 处 grep '无残留哨兵' 锚定
t "T2a plan-created.cjs '兜底清除' ≥1" bash -c "[ \"\$(grep -c '兜底清除' '$PLANCREATED')\" -ge 1 ]"
t "T2b plan-created.cjs 假成功旧文案行为注释在位 ('无残留哨兵' ≥1)" bash -c "[ \"\$(grep -c '无残留哨兵' '$PLANCREATED')\" -ge 1 ]"

# T3: zcode-posttooluse.sh 本会话自动重锁分支在位 (E2)
t "T3 zcode-posttooluse.sh 'attested_by_sid|自动重锁' ≥1" bash -c "[ \"\$(grep -c 'attested_by_sid\|自动重锁' '$POSTTOOL')\" -ge 1 ]"

# T4: attest-plan.sh attested_by_sid 字段在位 (E2)
t "T4 attest-plan.sh 'attested_by_sid' ≥1" bash -c "[ \"\$(grep -c 'attested_by_sid' '$ATTEST')\" -ge 1 ]"

# T5: zcode-userpromptsubmit.sh env sid 兜底链在位 (E3)
t "T5 zcode-userpromptsubmit.sh 'CLAUDE_CODE_SESSION_ID' ≥1" bash -c "[ \"\$(grep -c 'CLAUDE_CODE_SESSION_ID' '$UPS')\" -ge 1 ]"

# T6: check-delegation.sh observe 会话级节流 flag 在位 (E3/E4)
t "T6 check-delegation.sh 'task-planner-observe' 节流 flag ≥1" bash -c "[ \"\$(grep -c 'task-planner-observe' '$DELEG')\" -ge 1 ]"

# T7: config.json hook_self_heal_enforce 存在 + default=warn + enum 三值
#     可移植性: 有 python3 走 JSON 断言; 无 python3 降级 grep 断言 (双路径风格照抄 selftest-knowledge-brief.sh T9)
if command -v python3 >/dev/null 2>&1; then
    t "T7 config hook_self_heal_enforce=warn (python3)" python3 -c "
import json
k = json.load(open('$CONFIG'))['properties']['hook_self_heal_enforce']
assert k['default'] == 'warn'
assert set(k['enum']) == {'enforce','warn','off'}"
else
    t "T7 config hook_self_heal_enforce=warn (grep-fallback)" bash -c "
        c=\$(sed -n '/\"hook_self_heal_enforce\"/,/^[[:space:]]*}/p' '$CONFIG')
        [ \$(grep -c '\"default\" *: *\"warn\"' <<<\"\$c\") -ge 1 ] &&
        [ \$(grep -c '\"enforce\"' <<<\"\$c\") -ge 1 ] &&
        [ \$(grep -c '\"off\"' <<<\"\$c\") -ge 1 ]"
fi

# T8: SKILL.md 「环境级中断自愈」条款在位 且 行数 ≤523 (基线 513, 净增 ≤10)
t "T8a SKILL.md '环境级中断自愈' ≥1" bash -c "[ \"\$(grep -c '环境级中断自愈' '$SKILL')\" -ge 1 ]"
t "T8b SKILL.md 行数 ≤523" bash -c "[ \"\$(wc -l < '$SKILL')\" -le 523 ]"

# T9: 跨文件键名一致: hook_self_heal_enforce 出现在 config.json + SKILL.md (各 ≥1, 共 ≥2 文件)
#     且无拼写变体 hook-self-heal (两文件全 0)
t "T9a hook_self_heal_enforce 出现在 config.json+SKILL.md ≥2 文件" bash -c "[ \"\$(grep -rln 'hook_self_heal_enforce' '$CONFIG' '$SKILL' | wc -l)\" -ge 2 ]"
t "T9b 无拼写变体 hook-self-heal (全 0)" bash -c "[ \"\$(grep -rc 'hook-self-heal' '$CONFIG' '$SKILL' | awk -F: '{s+=\$2} END{print s+0}')\" -eq 0 ]"

# T10: 回归哨兵 (v067 机制未被本次破坏): knowledge-brief 五段 = 5 且 init '6/6' ≥1
t "T10a knowledge-brief.md 五段 grep -c '^## §' = 5" bash -c "[ \"\$(grep -c '^## §' '$BRIEF')\" -eq 5 ]"
t "T10b init-session.sh '6/6' ≥1" bash -c "[ \"\$(grep -c '6/6' '$INIT')\" -ge 1 ]"

# ── 汇总 ──
TOTAL=$((PASS + FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
