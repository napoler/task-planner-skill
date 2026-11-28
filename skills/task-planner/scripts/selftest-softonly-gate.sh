#!/usr/bin/env bash
# selftest-softonly-gate.sh — [2026-11-28 task-skill-fix-defs-20261128] DEF-01 SOFT_ONLY fail-closed 三向夹具
# What: 验证 attest-plan.sh SOFT_ONLY 空壳检测的三向行为：
#   ① 空壳夹具 + 默认 env → attest rc=1 且输出含「SOFT_ONLY」拒锁文案
#   ② 同夹具 + TASK_PLANNER_SOFT_ONLY_ENFORCE=off → 输出含 WARN 文案（rc 可能 1，判 WARN 文案）
#   ③ 正常夹具（业务数组非空）→ attest rc=0
# Why:  审计 DEF-01 warn-only 空壳全程绿灯（判例 sess_1d7e33d6）；本 selftest 钉住 fail-closed+逃生阀语义。
# 夹具: mktemp -d 临时计划目录；不修改门判定式，只调夹具满足门。
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ATTEST="$SCRIPT_DIR/attest-plan.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'SO-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'SO-%s FAIL %s\n' "$1" "$2"; }

TMP="$(mktemp -d /tmp/tp-softonly-XXXXXX)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

# ── 夹具构造 ──
# 空壳夹具：plan-state.json 业务数组全空 + task_plan.md > 2048B
make_empty_shell() {
  local d="$1"
  mkdir -p "$d/subagent-state"
  cat > "$d/plan-state.json" <<'JSON'
{
  "schema_version": 1,
  "plan_id": "task-softonly-empty",
  "template_ref": "skills/task-planner/templates/task_plan.md",
  "created_at": "2026-11-28T00:00:00Z",
  "updated_at": "2026-11-28T00:00:00Z",
  "title": "softonly-empty",
  "status": "drafting",
  "lifecycle": {"phase": "drafting"},
  "requirements": [],
  "goals": [],
  "acceptance": [],
  "vcs": [],
  "phases": [],
  "s_units": [],
  "findings": [],
  "decisions": [],
  "errors": [],
  "output_examples": [],
  "anchors": {"plan_file": "task_plan.md"}
}
JSON
  # task_plan.md > 2048B，含最小骨架以免其他解析器崩溃；内容为填充文本
  {
    echo "# Task Plan: softonly-empty"
    echo ""
    echo "## Goal"
    echo "Soft-only empty shell fixture for DEF-01."
    echo ""
    echo "## 用户需求原文"
    echo "- **R1**: placeholder"
    echo ""
    echo "### R→VC 映射"
    echo "| R | VC |"
    echo "|---|---|"
    echo "| R1 | VC1 |"
    echo ""
    echo "## 根源覆盖表"
    echo "| root | cover |"
    echo "|------|-------|"
    echo "| r1 | c1 |"
    echo ""
    echo "## Phases"
    echo "### Phase 1: placeholder"
    echo "- **Executor:** 主进程"
    echo ""
    # pad to > 2048B
    python3 - <<'PY'
print("# padding\n" + ("softonly padding line for size threshold > 2048 bytes\n" * 60))
PY
  } > "$d/task_plan.md"
  : > "$d/findings.md"
  : > "$d/progress.md"
  : > "$d/verification.md"
}

# 正常夹具：业务数组非空 + 满足主要门的最小合法面
make_normal() {
  local d="$1"
  mkdir -p "$d/subagent-state"
  cat > "$d/plan-state.json" <<'JSON'
{
  "schema_version": 1,
  "plan_id": "task-softonly-normal",
  "template_ref": "skills/task-planner/templates/task_plan.md",
  "created_at": "2026-11-28T00:00:00Z",
  "updated_at": "2026-11-28T00:00:00Z",
  "title": "softonly-normal",
  "status": "drafting",
  "lifecycle": {"phase": "drafting"},
  "template_type": "standard",
  "plan_tier": "mini",
  "requirements": [{"id":"R1","text":"r1","status":"open"}],
  "goals": [{"id":"G1","text":"g1","status":"open"}],
  "acceptance": [{"id":"A1","text":"a1","status":"open"}],
  "vcs": [{"id":"VC1","text":"vc1","command":"echo ok","status":"open"}],
  "phases": [{"id":"P1","title":"p1","status":"pending"}],
  "s_units": [],
  "findings": [],
  "decisions": [],
  "errors": [],
  "output_examples": [{"example":"这是一个完整可审查的示例内容，长度足够。","template":"这是一个完整可审查的模板内容，长度足够。"}],
  "anchors": {"plan_file": "task_plan.md"}
}
JSON
  {
    echo "# Task Plan: softonly-normal"
    echo ""
    echo "plan_tier: mini"
    echo ""
    echo "## Goal"
    echo "- G1: normal fixture (≤15min)"
    echo ""
    echo "## 用户需求原文"
    echo "- **R1**: placeholder requirement"
    echo ""
    echo "### R→VC 映射"
    echo "| R | VC |"
    echo "|---|---|"
    echo "| R1 | VC1 |"
    echo ""
    echo "## 根源覆盖表"
    echo "| root | cover |"
    echo "|------|-------|"
    echo "| r1 | c1 |"
    echo ""
    echo "## 执行范围限制"
    echo "| file | reason |"
    echo "|------|--------|"
    echo "| a.sh | test |"
    echo ""
    echo "## Phases"
    echo "### Phase 1: placeholder"
    echo "- **Executor:** 主进程"
    echo ""
    echo "## 需求变更日志"
    echo "| time | change |"
    echo "|------|--------|"
    echo "| - | - |"
  } > "$d/task_plan.md"
  cat > "$d/verification.md" <<'MD'
# Verification
| id | desc | command | status |
|----|------|---------|--------|
| VC1 | ok | echo ok | pending |
MD
  : > "$d/findings.md"
  : > "$d/progress.md"
}

run_attest() {
  local d="$1"; shift
  local out rc
  out="$(cd "$d" && bash "$ATTEST" "$@" "$d/task_plan.md" 2>&1)"; rc=$?
  printf '%s\n__RC__=%s\n' "$out" "$rc"
}

# ── ① 空壳 + 默认 env → rc=1 且含 SOFT_ONLY 拒锁文案 ──
D1="$TMP/empty1"; make_empty_shell "$D1"
# 跳过与 SOFT_ONLY 无关的重门，隔离被测面；SOFT_ONLY 在入口段最先执行
r1="$(run_attest "$D1" --skip-dispatch-check --skip-template-check --skip-fmea-check --skip-goal-check --skip-vc-check --skip-audit-check --skip-spec-gate)"
rc1="$(printf '%s\n' "$r1" | sed -n 's/^__RC__=//p' | tail -1)"
if [ "$rc1" = "1" ] && printf '%s\n' "$r1" | grep -q 'SOFT_ONLY' && printf '%s\n' "$r1" | grep -q '拒绝锁定'; then
  ok 01 "空壳默认env -> rc=1 + SOFT_ONLY拒锁文案"
else
  bad 01 "rc=$rc1 或缺 SOFT_ONLY 拒锁文案; out=$(printf '%s\n' "$r1" | grep -E 'SOFT_ONLY|__RC__' | head -3 | tr '\n' ' ')"
fi

# ── ② 同空壳 + TASK_PLANNER_SOFT_ONLY_ENFORCE=off → 含 WARN 文案（rc 不强制） ──
D2="$TMP/empty2"; make_empty_shell "$D2"
r2="$(cd "$D2" && TASK_PLANNER_SOFT_ONLY_ENFORCE=off bash "$ATTEST" --skip-dispatch-check --skip-template-check --skip-fmea-check --skip-goal-check --skip-vc-check --skip-audit-check --skip-spec-gate "$D2/task_plan.md" 2>&1)"; rc2=$?
if printf '%s\n' "$r2" | grep -q 'SOFT_ONLY' && printf '%s\n' "$r2" | grep -q 'WARN'; then
  ok 02 "空壳+SOFT_ONLY_ENFORCE=off -> WARN文案存在(rc=$rc2)"
else
  bad 02 "缺 SOFT_ONLY WARN文案 rc=$rc2; out=$(printf '%s\n' "$r2" | grep -E 'SOFT_ONLY|WARN' | head -3 | tr '\n' ' ')"
fi

# ── ③ 正常夹具（业务数组非空）→ attest rc=0 ──
D3="$TMP/normal"; make_normal "$D3"
# 正常夹具用 mini+跳过重门，聚焦 SOFT_ONLY 不误伤；若其他门拦截则本用例失败并打印原因，需修夹具而非放宽门。
r3="$(run_attest "$D3" --skip-dispatch-check --skip-template-check --skip-fmea-check --skip-goal-check --skip-vc-check --skip-audit-check --skip-spec-gate)"
rc3="$(printf '%s\n' "$r3" | sed -n 's/^__RC__=//p' | tail -1)"
if [ "$rc3" = "0" ]; then
  ok 03 "正常夹具(业务数组非空) -> rc=0"
else
  bad 03 "正常夹具 rc=$rc3 (应为0; 若其他门拦截需修夹具) out=$(printf '%s\n' "$r3" | grep -E '✗|ERROR|WARN|__RC__' | head -5 | tr '\n' ' ')"
fi

printf 'SOFTONLY_TOTAL: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
