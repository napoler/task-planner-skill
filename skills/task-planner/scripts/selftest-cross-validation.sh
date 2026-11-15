#!/usr/bin/env bash
# selftest-cross-validation.sh — Rule 108 交叉验证纪律静态守护（CV-01..CV-06）
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TP_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SATELLITE_ROOT="$(cd "$TP_ROOT/../verification-gate" && pwd)"
SAT_CRIT="$SATELLITE_ROOT/references/critical-rules-verification.md"
SAT_SKILL="$SATELLITE_ROOT/SKILL.md"
TP_SKILL="$TP_ROOT/SKILL.md"
TP_TPL="$TP_ROOT/templates/verification.md"
REG_TSV="$SCRIPT_DIR/selftest-registry.tsv"
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'CV-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'CV-%s FAIL %s\n' "$1" "$2"; }

# CV-01 108.1-108.5 子条各≥1 且 ^### 108 块标题锚在位
if grep -q '^### 108 ' "$SAT_CRIT" \
  && grep -qE '^108\.1 ' "$SAT_CRIT" && grep -qE '^108\.2 ' "$SAT_CRIT" \
  && grep -qE '^108\.3 ' "$SAT_CRIT" && grep -qE '^108\.4 ' "$SAT_CRIT" \
  && grep -qE '^108\.5 ' "$SAT_CRIT"; then
  ok 01 "规则文 ^### 108 块标题及 108.1-108.5 子条锚在位"
else
  bad 01 "规则文 ^### 108 块标题或 108.1-108.5 子条锚缺失"
fi

# CV-02 判例锚在 ^### 108 块内
SEC108="$(sed -n '/^### 108 /,/^### /p' "$SAT_CRIT" 2>/dev/null || true)"
if printf '%s\n' "$SEC108" | grep -q 'subagent-verifier-fabricated-output-20261103'; then
  ok 02 "判例锚 subagent-verifier-fabricated-output-20261103 在 ^### 108 块内"
else
  bad 02 "判例锚缺失或不在 ^### 108 块内"
fi

# CV-03 verification-gate SKILL「调用时机」段内含 Rule 108
SEC_CALL="$(sed -n '/^## 调用时机/,/^## /p' "$SAT_SKILL" 2>/dev/null || true)"
if printf '%s\n' "$SEC_CALL" | grep -q 'Rule 108'; then
  ok 03 "verification-gate SKILL 调用时机段含 Rule 108"
else
  bad 03 "verification-gate SKILL 调用时机段缺 Rule 108"
fi

# CV-04 task-planner SKILL 含 Rule 108 且路由行含 108
if grep -q 'Rule 108' "$TP_SKILL" && grep -q 'Rule 84,108' "$TP_SKILL"; then
  ok 04 "task-planner SKILL 含 Rule 108 且路由行含 84,108"
else
  bad 04 "task-planner SKILL 缺 Rule 108 或路由 84,108"
fi

# CV-05 模板含交叉验证记录区块（标题锚）
if grep -q '^## 交叉验证记录（Rule 108）' "$TP_TPL"; then
  ok 05 "verification 模板含 ^## 交叉验证记录（Rule 108）"
else
  bad 05 "verification 模板缺 ^## 交叉验证记录（Rule 108）"
fi

# CV-06 registry.tsv 含 selftest-cross-validation 行
if grep -q '^selftest-cross-validation.sh' "$REG_TSV"; then
  ok 06 "registry.tsv 含 selftest-cross-validation 行"
else
  bad 06 "registry.tsv 缺 selftest-cross-validation 行"
fi

TOTAL=$((PASS+FAIL)); echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"; [ "$FAIL" -eq 0 ] && exit 0 || exit 1