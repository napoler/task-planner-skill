#!/usr/bin/env bash
# selftest-rescue-chain.sh — task-v065 S-1 F-1: check-rescue-chain.sh 自测（hermetic，夹具全在 $TMP，不触真实 plans/）
# [2026-09-13] T01 enforce 违规(缺 rescue 留痕/checkpoint) / T02 rescue+checkpoint 齐 → 放行 /
#   T03 无 failed|timeout 行 → 放行 / T04 off 档 → 放行 / T05 warn 档(默认) 仅警告 /
#   T06 --json 合同 / T07 rescue 列缺失 → 违规 / T08 timeout + {seq}-{agent_type}.md 模式命中 /
#   T09 参数错误 exit 2 / T10 无 task_plan.md fail-open
# 全 PASS exit 0;任一 FAIL exit 1。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK="$SCRIPT_DIR/check-rescue-chain.sh"
CONFIG_JSON="$SCRIPT_DIR/../config.json"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
PASS=0; FAIL=0

assert() {   # <T名> <实际rc> <期望rc> <stdout必含|-> <stderr必含|->
  local name="$1" rc="$2" exp="$3" no="$4" ne="$5" ok=1
  [ "$rc" = "$exp" ] || ok=0
  [ "$no" = "-" ] || printf '%s\n' "$COUT" | grep -qF -- "$no" || ok=0
  [ "$ne" = "-" ] || printf '%s\n' "$CERR" | grep -qF -- "$ne" || ok=0
  if [ "$ok" = 1 ]; then PASS=$((PASS+1)); printf 'T%s PASS\n' "$name"
  else FAIL=$((FAIL+1)); printf 'T%s FAIL (rc=%s exp=%s) out=[%s] err=[%s]\n' "$name" "$rc" "$exp" "$COUT" "$CERR"; fi
}

run() {   # run <dir> [args...] — 用 $TIER 控制档位（空=不覆盖，走 config 默认）
  local dir="${1:-}"; shift || true
  local out err rc
  if [ -n "$TIER" ]; then
    TASK_PLANNER_RESCUE_CHAIN_ENFORCE="$TIER" bash "$CHECK" "$dir" "$@" > "$TMP/out" 2> "$TMP/err"
  else
    env -u TASK_PLANNER_RESCUE_CHAIN_ENFORCE bash "$CHECK" "$dir" "$@" > "$TMP/out" 2> "$TMP/err"
  fi
  rc=$?
  COUT="$(cat "$TMP/out")"; CERR="$(cat "$TMP/err")"
  return "$rc"
}

HDR_STATUS='| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | checkpoint 路径 |'
HDR_SEP='|---|------|--------------|---------|------|---------|------|----------------|'
SEC='## 🔗 Subagent Handoff 登记表'

# ── 夹具 ─────────────────────────────────────────────────────────────────────
for d in a b c d e f g h; do mkdir -p "$TMP/$d"; done

# A: failed 行 + rescue 列存在但空 + checkpoint 空（T01/T05/T06 违规夹具）
printf '%s\n' '# task_plan' "$SEC" \
  '| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | checkpoint 路径 | rescue |' \
  '|---|------|--------------|---------|------|---------|------|----------------|--------|' \
  '| 3 | 2026-09-13 | executor | 写脚本 | failed | - | - |  |  |' > "$TMP/a/task_plan.md"

# B: failed 行 + rescue 留痕 + checkpoint 文件存在（T02 合规夹具）
printf '%s\n' '# task_plan' "$SEC" \
  '| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | checkpoint 路径 | rescue |' \
  '|---|------|--------------|---------|------|---------|------|----------------|--------|' \
  '| 5 | 2026-09-13 | executor | 写脚本 | failed | 子代理中断 | findings.md:12 | 05-executor.md | ①改派:done→②拆细:done |' > "$TMP/b/task_plan.md"
mkdir -p "$TMP/b/subagent-state"; : > "$TMP/b/subagent-state/05-executor.md"

# C: 无 failed/timeout 行（T03 合规夹具）
printf '%s\n' '# task_plan' "$SEC" "$HDR_STATUS" "$HDR_SEP" \
  '| 1 | 2026-09-13 | explore | 审计 | done | ok | x.md:1 | 01-explore.md |' > "$TMP/c/task_plan.md"

# D: rescue 列缺失的表头 + failed 行（T07 违规夹具）
printf '%s\n' '# task_plan' "$SEC" "$HDR_STATUS" "$HDR_SEP" \
  '| 7 | 2026-09-13 | code-assistant | 补用例 | failed | - | - | 07-code-assistant.md |' > "$TMP/d/task_plan.md"

# E: timeout 行 + checkpoint 列值不存在，靠 {seq}-{agent_type}.md 模式(001→01)命中（T08 合规夹具）
printf '%s\n' '# task_plan' "$SEC" \
  '| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | checkpoint 路径 | rescue |' \
  '|---|------|--------------|---------|------|---------|------|----------------|--------|' \
  '| 001 | 2026-09-13 | executor | 长任务 | timeout | 超时 | - | zz-missing.md | ①改派:done |' > "$TMP/e/task_plan.md"
mkdir -p "$TMP/e/subagent-state"; : > "$TMP/e/subagent-state/01-executor.md"

# F: plan-dir 存在但无 task_plan.md（T10 fail-open）
mkdir -p "$TMP/f"

# G: 违规夹具（T04 off 档复用 A）
cp "$TMP/a/task_plan.md" "$TMP/g/task_plan.md"

# H: 头两行（表头在第 3 行）→ 校验 Handoff 行号 = 物理行号（T06 断言 line 字段）
cp "$TMP/a/task_plan.md" "$TMP/h/task_plan.md"

# ── 用例 ─────────────────────────────────────────────────────────────────────
# T01 enforce 档: failed 行 + rescue 空 + checkpoint 空 → exit 1 + 三条违规原因
TIER=enforce; run "$TMP/a"; RC=$?
assert 01 "$RC" 1 'rescue列空' -

# T02 enforce 档: rescue 留痕 + checkpoint 文件存在 → exit 0
TIER=enforce; run "$TMP/b"; RC=$?
assert 02 "$RC" 0 '挽救链路完好' -

# T03 enforce 档: 无 failed/timeout 行 → exit 0（total_failed=0）
TIER=enforce; run "$TMP/c"; RC=$?
assert 03 "$RC" 0 'failed/timeout 行=0' -

# T04 off 档: 违规夹具也放行 exit 0
TIER=off; run "$TMP/g"; RC=$?
assert 04 "$RC" 0 'off 档' -

# T05 warn 档(不带 env 覆盖, 走 config.json 默认=warn): 违规仅警告 exit 0
TIER=""; run "$TMP/a"; RC=$?
assert 05 "$RC" 0 'warn 档' -

# T06 --json 合同: 违规 + enforce → rc 1；stdout 单行合法 JSON（含 total_failed/violations/verdict + line 行号）
TIER=enforce; run "$TMP/h" --json; RC=$?
json_ok=0
if [ "$RC" = 1 ] && printf '%s' "$COUT" | jq -e '.total_failed == 1 and (.violations | length) == 1 and .verdict == "violation" and .violations[0].line == 5' >/dev/null 2>&1; then
  json_ok=1
fi
assert 06a "$RC" 1 '{"total_failed":1' -
if [ "$json_ok" = 1 ]; then PASS=$((PASS+1)); printf 'T06b PASS (jq 解析 .violations[0].line==5)\n'
else FAIL=$((FAIL+1)); printf 'T06b FAIL --json 合同: %s | rc=%s\n' "$COUT" "$RC"; fi

# T07 rescue 列缺失 → 违规（enforce exit 1 + 专属文案）
TIER=enforce; run "$TMP/d"; RC=$?
assert 07 "$RC" 1 'rescue列缺失' -

# T08 timeout 行 + {seq}-{agent_type}.md 模式命中 → exit 0
TIER=enforce; run "$TMP/e"; RC=$?
assert 08 "$RC" 0 '挽救链路完好' -

# T09 参数错误（无参）→ exit 2（die2 文案在 stderr）
TIER=enforce; run; RC=$?
assert 09 "$RC" 2 - '参数错误'

# T10 plan-dir 无 task_plan.md → fail-open exit 0
TIER=enforce; run "$TMP/f"; RC=$?
assert 10 "$RC" 0 'fail-open' -

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
