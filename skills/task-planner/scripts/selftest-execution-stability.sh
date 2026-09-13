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

# T11: [2026-09-14 task-v068 Fix-C P2-2] 行为级断言 — 现有 T1-T10 全是 grep 字符串存在性,
#      P0 类行为 bug 在其面前全绿。此处真实执行 hook 子进程(bash 子进程,非 grep 源码)。
# T11=B1 (P0-1 回归: 相对含 slash 路径自动重锁 + 归属护栏):
#   临时目录 fixture: $T/plans/task-x/task_plan.md + .session-owner="sessabc123"(canon 剥除形态,
#   与 stdin sid "sess-abc123" 剥除后一致)。基线 attest(env 剥离 ZCODE_SESSION_ID → attested_by_sid 空)。
#   相对 file_path "plans/task-x/task_plan.md" 经 posttooluse P0-1 fix-B L62 CWD 直拼归一 → 重锁命中:
#   改 task_plan.md 内容后, .plan-attestation 更新为新 sha 且 attested_by_sid=sessabc123。
#   负例: 先改内容再把 .session-owner 换成 othersid999(剥除后仍非本 sid) → 重跑同 stdin,
#   归属护栏双条件: plan_sha256 仍为旧值(哈希不更新) 且 attested_by_sid 保持基线空串
#   (posttooluse 重锁未命中 → attest 未被调用, 不产生新归属写入, 不被洗白)。
#   每断言先跑一次真实 hook 再判定, 单条内 FAIL 可定位(正/负例分离计入 Total)。
b1_pos() {
    local T P
    T="$(mktemp -d)" || { echo "[B1] fixture mktemp failed"; return 1; }
    P="$T/plans/task-x"
    mkdir -p "$P"
    echo "goal" > "$P/task_plan.md"
    printf 'sessabc123' > "$P/.session-owner"
    rm -f "/tmp/task-planner-hook-sessabc123.state"
    env -u ZCODE_SESSION_ID bash "$ATTEST" "$P/task_plan.md" --skip-dispatch-check >/dev/null 2>&1
    local h1
    h1="$(sha256sum "$P/task_plan.md" | awk '{print $1}')"
    # 正例: 改内容 + 相对含 slash file_path 触发 posttooluse 自动重锁
    echo "goal v2" >> "$P/task_plan.md"
    printf '{"session_id":"sess-abc123","cwd":"%s","tool_name":"Edit","tool_input":{"file_path":"plans/task-x/task_plan.md"}}' "$T" \
        | env -u ZCODE_SESSION_ID bash "$POSTTOOL" >/dev/null 2>&1
    local h2
    h2="$(sha256sum "$P/task_plan.md" | awk '{print $1}')"
    local bysid
    bysid="$(grep '^attested_by_sid=' "$P/.plan-attestation" | cut -d= -f2)"
    local stored
    stored="$(grep '^plan_sha256=' "$P/.plan-attestation" | cut -d= -f2)"
    rm -rf "$T" "/tmp/task-planner-hook-sessabc123.state"
    [ "$h1" != "$h2" ] && [ "$bysid" = "sessabc123" ] && [ "$stored" = "$h2" ]
}
t "T11a B1 正例: 相对含 slash 路径 Edit → 自动重锁(attested_by_sid=sessabc123 且 plan_sha256=新文件哈希)" \
    b1_pos
b1_neg() {
    local T P
    T="$(mktemp -d)" || { echo "[B1-neg] fixture mktemp failed"; return 1; }
    P="$T/plans/task-x"
    mkdir -p "$P"
    echo "goal" > "$P/task_plan.md"
    printf 'sessabc123' > "$P/.session-owner"
    rm -f "/tmp/task-planner-hook-sessabc123.state"
    env -u ZCODE_SESSION_ID bash "$ATTEST" "$P/task_plan.md" --skip-dispatch-check >/dev/null 2>&1
    local h1
    h1="$(sha256sum "$P/task_plan.md" | awk '{print $1}')"
    # 负例: 先改内容, 再把 owner 换成他会话 → 同 stdin 重跑, 重锁必须不命中(归属护栏, P0-1 防洗白):
    #   plan_sha256 仍为旧值(不更新) 且 attested_by_sid 被 attest 重置为空串(非 sessabc123, 不被洗白)
    echo "goal v2" >> "$P/task_plan.md"
    printf 'othersid999' > "$P/.session-owner"
    printf '{"session_id":"sess-abc123","cwd":"%s","tool_name":"Edit","tool_input":{"file_path":"plans/task-x/task_plan.md"}}' "$T" \
        | env -u ZCODE_SESSION_ID bash "$POSTTOOL" >/dev/null 2>&1
    local stored bysid
    stored="$(grep '^plan_sha256=' "$P/.plan-attestation" | cut -d= -f2)"
    bysid="$(grep '^attested_by_sid=' "$P/.plan-attestation" | cut -d= -f2)"
    rm -rf "$T" "/tmp/task-planner-hook-sessabc123.state"
    [ "$stored" = "$h1" ] && [ "$bysid" = "" ]
}
t "T11b B1 负例: 改内容后 owner=othersid999 → 重锁不命中(plan_sha256 仍为旧值 且 attested_by_sid 重置为空, 不被洗白)" \
    b1_neg

# T12: [2026-09-14 task-v068 Fix-C P2-2] B2 (P0-2 回归: 跨脚本 canon 一致性) —
#   三侧 sid 规范化必须逐字节一致(pretooluse L17 / UPS L34 / 复刻管道), 否则 sid 含连字符等
#   真实值时 owner 写/读/比较三方失配。行为式断言: 同一 sid 样本过三条管道, 输出两两相等;
#   任一侧不一致 FAIL, 诊断时输出三侧实际值(本断言自带 echo, 不复用 t() 的静默输出)。
b2_canon() {
    local SID="sess-abc123"
    # 三侧 sid 规范化管道, 逐字节一致性断言:
    #   A: 复刻 zcode-pretooluse.sh L17 同款管道 (jq -r '.session_id // empty' | tr -cd 'a-zA-Z0-9' | head -c 40)
    #   B: 复刻 zcode-userpromptsubmit.sh L34 同款管道 (stdin sid 直入 tr -cd 'a-zA-Z0-9' | head -c 40)
    #   C: 全链路 (JSON stdin → jq 提取 → 剥除), 等价 pretooluse L17 完整输入路径
    local A B C
    A="$(printf '{"session_id":"%s"}' "$SID" | jq -r '.session_id // empty' 2>/dev/null | tr -cd 'a-zA-Z0-9' | head -c 40)"
    B="$(printf '%s' "$SID" | tr -cd 'a-zA-Z0-9' | head -c 40)"
    C="$(printf '{"session_id":"%s"}' "$SID" | bash -c "jq -r '.session_id // empty' | tr -cd 'a-zA-Z0-9' | head -c 40" 2>/dev/null)"
    if [ -n "$A" ] && [ "$A" = "$B" ] && [ "$A" = "$C" ]; then
        return 0
    fi
    echo "[B2-diag] pretooluse L17=$A UPS L34=$B jq-full-chain=$C"
    return 1
}
if b2_canon >/dev/null 2>&1; then
    PASS=$((PASS+1)); echo "[PASS] T12 B2 三侧 canon 一致 (pretooluse L17 / UPS L34 / jq 全链路, sid=sess-abc123)"
else
    FAIL=$((FAIL+1)); echo "[FAIL] T12 B2 三侧 canon 一致 (sid=sess-abc123)"
    b2_canon   # 诊断: 输出两侧实际值
fi

# ── 汇总 ──
TOTAL=$((PASS + FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
