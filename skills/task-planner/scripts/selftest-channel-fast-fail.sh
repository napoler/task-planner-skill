#!/usr/bin/env bash
# [2026-10-14 task-v172 CA-6] selftest-channel-fast-fail.sh — Rule 83 通道不可用快速失败全链落点静态断言套件（CF-01..06）
# WHAT: 机械断言 Rule 83「通道不可用快速失败」全链守护面 6 组落点：
#      critical-rules 83.1-83.4 四子条（CF-01）→ SKILL.md 投诉响应协议段「通道不可用快速失败（Rule 83）」条目锚（CF-02）
#      → 零新 config 键 properties=53（CF-03；[task-v184-S2b] 键数 47→53 S1 引号形态级联漏网补齐）→ registry 自登记（CF-04）
#      → 83.3 禁 ≥2 次同法重试锚（CF-05）→ 83.2 快速失败三选项锚（CF-06）。
#      6 组断言全 PASS exit 0, 任一 FAIL exit 1。纯 grep/awk/jq 静态断言, 无 fixture。
# WHY: videop1 D6 判例（CreateWorkflow 无 Skill 工具 3 次重试全拦）+ R2 质量诉求；
#      Rule 83.4 要求 selftest 静态断言守护全链落点，防规则/SKILL 接线被后续改动静默移除。
# 口径: task-v172 CA-6 变更标注表；结构/style 照抄 selftest-session-log.sh 范式
#      （set -u / t() 计数器 / [PASS]/[FAIL] / Total / exit 语义）。
# 纪律: 本脚本只做只读静态断言 —— 禁写 config.json、禁 git 写操作。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."                    # <repo-root>/skills/task-planner
CRULES="$ROOT/references/critical-rules.md"
SKILL="$ROOT/SKILL.md"
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

# CF-01: critical-rules.md Rule 83 四子条文本锚（83.1-83.4）
t "CF-01 critical-rules Rule 83 四子条(83.1-83.4)文本锚" bash -c "
    [ \"\$(grep -c '83.1' '$CRULES')\" -ge 1 ] &&
    [ \"\$(grep -c '83.2' '$CRULES')\" -ge 1 ] &&
    [ \"\$(grep -c '83.3' '$CRULES')\" -ge 1 ] &&
    [ \"\$(grep -c '83.4' '$CRULES')\" -ge 1 ]
"

# CF-02: SKILL.md 投诉响应协议段「通道不可用快速失败（Rule 83）」条目锚
t "CF-02 SKILL.md 通道不可用快速失败(Rule 83)条目锚" bash -c "
    [ \"\$(grep -c '通道不可用快速失败（Rule 83）' '$SKILL')\" -ge 1 ]
"

# CF-03: 零新 config 键 properties=53（task-v172 CA-1/CA-2 后键数；P-01 新增 evidence_anchor_enforce 46→47；[task-v184-S2b] S1 引号形态级联漏网补齐 47→53）
t "CF-03 零新 config 键 properties=53" bash -c "
    [ \"\$(jq '.properties | keys | length' '$CONFIG' 2>/dev/null)\" = '53' ]
"  # [task-v184-S2b] 键数 47→53（S1 引号形态级联漏网补齐）

# CF-04: registry 自登记
t "CF-04 registry 自登记 selftest-channel-fast-fail.sh" bash -c "
    grep -q 'selftest-channel-fast-fail.sh' '$REG'
"

# CF-05: 83.3 禁 ≥2 次同法重试锚
t "CF-05 83.3 禁≥2次同法重试锚" bash -c "
    [ \"\$(grep -c '83.3 禁' '$CRULES')\" -ge 1 ] &&
    [ \"\$(grep -c '同法重试' '$CRULES')\" -ge 1 ]
"

# CF-06: 83.2 快速失败三选项锚
t "CF-06 83.2 快速失败三选项锚" bash -c "
    [ \"\$(grep -c '83.2 快速失败三选项' '$CRULES')\" -ge 1 ] &&
    [ \"\$(grep -c '换环境' '$CRULES')\" -ge 1 ] &&
    [ \"\$(grep -c 'Agent 替代授权' '$CRULES')\" -ge 1 ] &&
    [ \"\$(grep -c '主进程直执行授权' '$CRULES')\" -ge 1 ]
"

echo "---"
echo "Total: $((PASS + FAIL))  PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
