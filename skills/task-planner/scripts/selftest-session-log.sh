#!/usr/bin/env bash
# [2026-10-11 task-v169-user-session-log-write-once] selftest-session-log.sh — Rule 80 用户会话逐字记录全链落点静态断言套件（SL-01..10）
# WHAT: 机械断言 Rule 80「用户会话逐字记录专档（只写不改 append-only）」全链守护面 10 组落点：
#      模板存在性/三关键词/条目格式/恢复协议（SL-01/02）→ task_plan.md 指针区块在案（SL-03）
#      → critical-rules 80.1-80.6 六子条（SL-04）→ SKILL.md 1-80 索引接线（SL-05）
#      → check-complete.sh SESSION-LOG GATE 三件套（SL-06）→ init-session.sh 建档块+6/6 字面（SL-07）
#      → 指针区块纯静态负断言（SL-08）→ 零新 config 键 properties=42（SL-09, 对齐 DD-20）
#      → registry 自登记（SL-10）。10 组断言全 PASS exit 0, 任一 FAIL exit 1。纯 grep/awk/jq 静态断言, 无 fixture。
# WHY: 需求锚 R4（用户任务需求与对话内容逐字记录进 Task Plan 文档）+ R5（记录性文档只写入不修改）
#      是用户原话铁律；Rule 80.6③ 要求 selftest 静态断言守护全链落点，防模板/规则/门控被后续改动静默移除。
# 口径: 任务书 task-v169 §2 十条断言判定口径表；结构/style 照抄 selftest-knowledge-brief.sh 范式
#      （set -u / t() 计数器 / [PASS]/[FAIL] / Total / exit 语义）。
# 纪律: 本脚本只做只读静态断言 —— 禁写 config.json、禁 git 写操作（Rule 80.6/80.2 同口径）。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."                    # <repo-root>/skills/task-planner
SLOG="$ROOT/templates/user-session-log.md"
TPL="$ROOT/templates/task_plan.md"
CRULES="$ROOT/references/critical-rules.md"
SKILL="$ROOT/SKILL.md"
INIT="$SCRIPT_DIR/init-session.sh"
CHECK="$SCRIPT_DIR/check-complete.sh"
CONFIG="$ROOT/config.json"
REG="$SCRIPT_DIR/selftest-registry.tsv"

PASS=0; FAIL=0
t() { # t <name> <cond-expr...>
    local name="$1"; shift
    if "$@" >/dev/null 2>&1; then
        PASS=$((PASS+1)); echo "[PASS] $name"
    else
        FAIL=$((FAIL+1)); echo "[FAIL] $name"
    fi
}

# SL-01: user-session-log.md 存在 + 「只写不改」「append-only」「逐字抄录」三关键词各 ≥1
t "SL-01 user-session-log.md 存在且三关键词(只写不改∧append-only∧逐字抄录)各≥1" bash -c "
    test -f '$SLOG' &&
    [ \"\$(grep -c '只写不改' '$SLOG')\" -ge 1 ] &&
    [ \"\$(grep -c 'append-only' '$SLOG')\" -ge 1 ] &&
    [ \"\$(grep -c '逐字抄录' '$SLOG')\" -ge 1 ]"

# SL-02: 条目格式 `## #N` 形态示例行 + 「## 恢复协议」标题段
t "SL-02 user-session-log.md '## #' 条目示例行 ∧ '^## 恢复协议' 标题段" bash -c "
    [ \"\$(grep -cE '^## #' '$SLOG')\" -ge 1 ] &&
    [ \"\$(grep -c '^## 恢复协议' '$SLOG')\" -ge 1 ]"

# SL-03: task_plan.md 指针区块在案（🗣️ 标题 ≥1 且 user-session-log ≥2）
t "SL-03 task_plan.md 指针区块('🗣️ 用户会话逐字记录'≥1 ∧ 'user-session-log'≥2)" bash -c "
    [ \"\$(grep -c '🗣️ 用户会话逐字记录' '$TPL')\" -ge 1 ] &&
    [ \"\$(grep -c 'user-session-log' '$TPL')\" -ge 2 ]"

# SL-04: critical-rules.md Rule 80 六子条（80.1-80.6 行首字面, 精确 =6 防多/缺）
t "SL-04 critical-rules.md '^80.[1-6] ' = 6" bash -c "
    [ \"\$(grep -cE '^80\.[1-6] ' '$CRULES')\" -eq 6 ]"

# SL-05: SKILL.md Rule 80 索引接线 '1-80' = 3（行计数口径，任务书 §2 表）
t "SL-05 SKILL.md '1-80' = 3" bash -c "
    [ \"\$(grep -c '1-80' '$SKILL')\" -eq 3 ]"

# SL-06: check-complete.sh SESSION-LOG GATE 三件套（[session-log-gate] 前缀 + env 开关名 + 零新 config 键/env-only 注释）
t "SL-06 check-complete.sh SESSION-LOG GATE('[session-log-gate]'∧TASK_PLANNER_SESSION_LOG_ENFORCE∧零新 config 键|env-only)" bash -c "
    [ \"\$(grep -cF '[session-log-gate]' '$CHECK')\" -ge 1 ] &&
    [ \"\$(grep -c 'TASK_PLANNER_SESSION_LOG_ENFORCE' '$CHECK')\" -ge 1 ] &&
    [ \"\$(grep -cE '零新 config 键|env-only' '$CHECK')\" -ge 1 ]"

# SL-07: init-session.sh 建档（copy_template 专档调用 ≥1 且 '6/6' 校验字面 =1）
t "SL-07 init-session.sh 'copy_template \"user-session-log.md\"'≥1 ∧ '6/6'=1" bash -c "
    [ \"\$(grep -cF 'copy_template \"user-session-log.md\"' '$INIT')\" -ge 1 ] &&
    [ \"\$(grep -c '6/6' '$INIT')\" -eq 1 ]"

# SL-08（负断言）: task_plan.md 指针区块纯静态 —— 无「当前条目数/最近一条」类可变计数（=0）
t "SL-08 task_plan.md 指针区块无可变计数('当前条目数|最近一条'=0, 纯静态)" bash -c "
    [ \"\$(grep -cE '当前条目数|最近一条' '$TPL')\" -eq 0 ]"

# SL-09: 零新 config 键（properties 键数恒 42）；jq 缺失 = SKIP 计 PASS（对齐 DD-20 先例）
if command -v jq >/dev/null 2>&1; then
    t "SL-09 config.json properties 键数 = 42（零新 config 键, jq）" bash -c "
        [ \"\$(jq '.properties|keys|length' '$CONFIG')\" -eq 42 ]"
else
    echo "[SKIP] SL-09 jq 不可用, 降级 SKIP 计 PASS（对齐 DD-20 先例）"
    PASS=$((PASS+1))
fi

# SL-10: registry 自登记（本脚本名在 selftest-registry.tsv 恰 1 行 且该行 4 列全非空）
t "SL-10 registry 自登记('selftest-session-log.sh'=1 行 ∧ 该行 NF=4 且四列非空)" bash -c "
    [ \"\$(grep -c 'selftest-session-log.sh' '$REG')\" -eq 1 ] &&
    awk -F'\t' '\$1 ~ /selftest-session-log\\.sh/ {ok = (NF==4 && \$1!=\"\" && \$2!=\"\" && \$3!=\"\" && \$4!=\"\"); found=found ok} END {exit !(found+0)}' '$REG'"

# ── 汇总（Total/exit 语义对齐 selftest-knowledge-brief.sh）──
TOTAL=$((PASS + FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
