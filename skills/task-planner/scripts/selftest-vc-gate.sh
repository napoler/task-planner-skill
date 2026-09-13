#!/usr/bin/env bash
# selftest-vc-gate.sh — task-v065 T-3 V-9: check-complete.sh 终验 VC/V-N 门控自测
# [2026-09-13] V-9 goal-gate.md 规 1/2 机制化：VC 表 ≥5 条 且 每 Phase 段 V-N 映射 ≥2 条
#   （映射目标须为已定义 VC 编号；模板 verification.md 占位行残留不计实质）。
# 档位：env TASK_PLANNER_VC_GATE_ENFORCE > config.json vc_gate_enforce(默认 warn) > fail-open warn
# 用例（hermetic，夹具全在 $TMP，不触真实 plans/；跑 check-complete.sh 全门链，
#   夹具均含合法 delegation/handoff 使前置门通过，VC-GATE 为唯一变量）：
#   T01 VC5+每 Phase 2 V-N(映射合规) → exit 0 + VC-GATE PASSED
#   T02 VC3 条(warn 档) → exit 0 + stderr VC-GATE WARNING + (需≥5)
#   T02b VC3 条(enforce 档) → exit 1 + stderr VC-GATE FAILED
#   T03 Phase 无 V-N(warn 档) → exit 0 + WARNING + Phase1(V-N 映射 0 < 2)
#   T03b Phase 无 V-N(enforce 档) → exit 1 + FAILED
#   T04 off 档(违规夹具) → exit 0 + 无 VC-GATE 输出
#   T05 V-N 映射目标引用未定义 VC-9 → 缺口(目标缺失/未定义)
#   T06 模板 verification.md 占位 V-N 行残留 → 不计实质 → 违规
#   T07 无 V-N 缺口夹具默认档位(config.json 无覆盖, 本仓默认=warn) → 仅警告不阻断
# 全 PASS exit 0；任一 FAIL exit 1。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CC="$SCRIPT_DIR/check-complete.sh"
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

# 前置门通过的通用底座：findings/progress 非 stub + Handoff 表(delegated phases 登记)
scaffold() {   # <dir>
  mkdir -p "$1/subagent-state"
  printf 'x\ny\nz\nw\n' > "$1/findings.md"
  printf 'a\nb\nc\nd\n' > "$1/progress.md"
  : > "$1/subagent-state/01-explore.md"
  : > "$1/subagent-state/02-code-assistant.md"
  printf '%s\n' '## 🔗 Subagent Handoff 登记表' \
    '| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | checkpoint 路径 | rescue |' \
    '|---|------|--------------|---------|------|---------|------|----------------|--------|' \
    '| 1 | 2026-09-13 | explore | 勘察 | done | ok | ok.md:1 | 01-explore.md | - |' \
    '| 2 | 2026-09-13 | code-assistant | 实现 | done | ok | ok.md:2 | 02-code-assistant.md | - |' >> "$1/task_plan.md"
}

vc_table() {   # <n> — 生成 n 条 VC 的表头+数据行
  local n="$1" i
  printf '%s\n' '| # | 判定标准 | 验证方式 | 证据路径 |' '|---|----------|----------|---------|'
  for i in $(seq 1 "$n"); do printf '| VC-%s | 标准%s | cmd | path |\n' "$i" "$i"; done
}

SU='| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
|----|------|--------|------|------|---------|------|
| S1 | 勘察 | 继承 | plan.md | 通过 | 10min | complete |'

# ── 夹具构造 ────────────────────────────────────────────────────────────────
for d in ok vc3 novn badtarget tplresidue; do mkdir -p "$TMP/$d"; done

mk_ok() {   # VC5 + 每 Phase 2 条合规 V-N
  { printf '# task_plan\n\n## ✅ Verification Contract\n'
    vc_table 5
    printf '\n## Phases\n\n### Phase 1: Alpha\n- **Status:** complete\n- **Executor:** explore（mini）\n%s\n' "$SU"
    printf -- '- [x] V-1.1: 勘察完成 (mapped to VC-1)\n- [x] V-1.2: 报告落盘 (mapped to VC-2)\n\n'
    printf '### Phase 2: Beta\n- **Status:** complete\n- **Executor:** code-assistant（haiku-1）\n%s\n' "$SU"
    printf -- '- [x] V-2.1: 实现通过 (mapped to VC-3, VC-4)\n- [x] V-2.2: 无回归 (mapped to VC-5)\n'
  } > "$TMP/ok/task_plan.md"
  scaffold "$TMP/ok"
}
mk_ok

# T02/T02b: VC 3 条（删 VC-4/VC-5 两行: 表头 2 行+数据 5 行, 4/5 数据行 = 第 6/7 行）
# 映射目标同步收窄到已定义 VC-1..3，隔离「VC 总数」单变量
sed '6,7d; s/(mapped to VC-3, VC-4)/(mapped to VC-1)/; s/(mapped to VC-5)/(mapped to VC-2)/' \
  "$TMP/ok/task_plan.md" > "$TMP/vc3/task_plan.md"
scaffold "$TMP/vc3"

# T03/T03b: 无 V-N 行（删掉 - [x] V- 行）
sed '/^- \[x\] V-/d' "$TMP/ok/task_plan.md" > "$TMP/novn/task_plan.md"
scaffold "$TMP/novn"

# T05: 映射目标引用未定义 VC-9
sed 's/(mapped to VC-1)/(mapped to VC-9)/' "$TMP/ok/task_plan.md" > "$TMP/badtarget/task_plan.md"
scaffold "$TMP/badtarget"

# T06: 模板 verification.md 占位行原样残留（V-1.1 行替换为模板字面占位；实质映射 1 < 2）
sed 's|- \[x\] V-1.1: 勘察完成 (mapped to VC-1)|- [ ] V-1.1: [mapped to VC-? or custom]|' \
  "$TMP/ok/task_plan.md" > "$TMP/tplresidue/task_plan.md"
scaffold "$TMP/tplresidue"

# ── 运行 ────────────────────────────────────────────────────────────────────
run() {   # run <tier|''> <dir> — 跑 check-complete.sh 全门链
  local tier="${1:-}" dir="$2"
  if [ -n "$tier" ]; then
    TASK_PLANNER_VC_GATE_ENFORCE="$tier" bash "$CC" "$dir/task_plan.md" > "$TMP/out" 2> "$TMP/err"
  else
    env -u TASK_PLANNER_VC_GATE_ENFORCE bash "$CC" "$dir/task_plan.md" > "$TMP/out" 2> "$TMP/err"
  fi
  rc=$?
  COUT="$(cat "$TMP/out")"; CERR="$(cat "$TMP/err")"
  return "$rc"
}

# T01 合规 → exit 0 + PASSED
run enforce "$TMP/ok"; RC=$?
assert 01 "$RC" 0 'ALL PHASES COMPLETE' 'VC-GATE PASSED'

# T02 VC3 条, warn 档 → exit 0 + WARNING(需≥5)
run warn "$TMP/vc3"; RC=$?
assert 02 "$RC" 0 - 'VC-GATE WARNING'

# T02b VC3 条, enforce 档 → exit 1 + FAILED
run enforce "$TMP/vc3"; RC=$?
assert 02b "$RC" 1 - 'VC-GATE FAILED'

# T03 无 V-N, warn 档 → exit 0 + WARNING + Phase 缺口
run warn "$TMP/novn"; RC=$?
assert 03 "$RC" 0 - 'Phase1(V-N 映射 0 < 2)'

# T03b 无 V-N, enforce 档 → exit 1
run enforce "$TMP/novn"; RC=$?
assert 03b "$RC" 1 - 'VC-GATE FAILED'

# T04 off 档, 违规夹具(novn) → exit 0 + 无任何 VC-GATE 输出
run off "$TMP/novn"; RC=$?
off_clean=1
printf '%s\n' "$CERR" | grep -qF 'VC-GATE' && off_clean=0
if [ "$RC" = 0 ] && [ "$off_clean" = 1 ]; then
  PASS=$((PASS+1)); printf 'T04 PASS\n'
else
  FAIL=$((FAIL+1)); printf 'T04 FAIL (rc=%s, off-clean=%s) err=[%s]\n' "$RC" "$off_clean" "$CERR"
fi

# T05 映射目标引用未定义 VC → 缺口
run enforce "$TMP/badtarget"; RC=$?
assert 05 "$RC" 1 - '未定义 VC'

# T06 模板占位残留不计实质（Phase1 实质=1 < 2 → 以映射数形式报缺）
run enforce "$TMP/tplresidue"; RC=$?
assert 06 "$RC" 1 - 'Phase1(V-N 映射 1 < 2)'

# T07 默认档位（不带 env, 走 config.json 默认 warn）: 违规夹具 novn → 仅警告不阻断
run "" "$TMP/novn"; RC=$?
assert 07 "$RC" 0 - 'VC-GATE WARNING'

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
