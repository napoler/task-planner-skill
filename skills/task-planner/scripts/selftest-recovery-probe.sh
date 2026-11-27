#!/usr/bin/env bash
# selftest-recovery-probe.sh — 压缩注入无条件 + 探针四态结构化 + 只读纪律
# What: TC-01 无在途指针仍注入技能正文全文；TC-02 stage2 只读探针不建计划/不切分支/不改工作树；
#       TC-03 verdict 四态 READY/STALE/BLOCKED/DEGRADED 行为可达且 rc 0/1/2 兼容；
#       TC-04 mutation 抹掉 verdict 输出行后判别性失效（负控制）。
# Why: 2026-11-24 曾把技能正文绑在 inflight 条件上，压缩后技能体系缺失（TC-01 防回退）；
#       stage2 探针误执行建计划/切分支会劫持会话（TC-02）；二态判定无法区分陈旧、
#       用户门未决与工具降级（TC-03）。全部断言只读夹具，不改生产状态源。
# 边界: TC-02 只禁「探针实际执行的写操作」，不把探针打印给用户的 Rule 119 action 提示
#       （zcode-sessionstart.sh 的 lines.append 字符串）当写操作；同时用文件系统快照兜底。
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="$SCRIPT_DIR/lib/plan-recovery.sh"
HOOK="$SCRIPT_DIR/zcode-sessionstart.sh"
T="$(mktemp -d /tmp/selftest-recovery-probe.XXXXXX)" || exit 2
trap 'rm -rf -- "$T"' EXIT
PASS=0; FAIL=0
ok(){ PASS=$((PASS+1)); echo "PASS $1"; }
bad(){ FAIL=$((FAIL+1)); echo "FAIL $1"; }

# TC-01: 注入不绑 inflight — 无 side 指针仍必须注入技能正文全文（末行=结束标记）
R01="$T/tc01"
mkdir -p "$R01/plans"
printf '%s\n' '## 待处理' '- **task-x** | in_progress | 2026-11-27' > "$R01/plans/INDEX.md"
C01=""
if command -v jq >/dev/null 2>&1; then
  H01="$(cd "$R01" && printf '%s' '{"session_id":"sess-tc01-noptr"}' | bash "$HOOK" 2>/dev/null)"
  C01="$(printf '%s\n' "$H01" | jq -r '.additionalContext // ""' 2>/dev/null)"
fi
# 注意：pipefail 下 grep -q 会让大输出 printf 收到 SIGPIPE（rc141）造成假 FAIL，故用 grep -F >/dev/null 读全量
if printf '%s\n' "$C01" | grep -F '【技能正文·开始】' >/dev/null \
   && [ "$(printf '%s\n' "$C01" | tail -n 1)" = '【技能正文·结束】' ] \
   && grep -F 'recover-skill' "$HOOK" >/dev/null; then
  ok "TC-01 无在途指针仍无条件注入技能正文（防注入回退）"
else
  bad "TC-01 技能正文注入回退（无指针时缺失或未以结束标记收尾）"
fi

# TC-02: 只读纪律 — 探针段无「实际执行」的 mkdir / worktree add / switch / checkout，
#        且跑完 hook 后项目根文件系统零变化（含不建 task-x-rc 计划）。
R02="$T/tc02"
mkdir -p "$R02/plans"
printf '%s\n' '{"followup-of:task-x":["task-x"]}' > "$R02/plans/.tags-index.json"
# 排除 task-plan-init.cjs 自身的哨兵/ sidmap 写入（与 stage2 探针无关，不能算探针越界）
fs_snapshot(){ (cd "$R02" && find . -mindepth 1 | grep -v '\.plan_required_side' | grep -v '\.active_plan_side' | sort); }
BEFORE="$(fs_snapshot)"
PROBE="$(sed -n '/\[stage-advance\] marker: SessionStart probe/,/^PYPROBE$/p' "$HOOK")"
EXEC_WRITES="$(printf '%s\n' "$PROBE" | grep -E '^[[:space:]]*(mkdir|git[[:space:]]+(worktree[[:space:]]+add|switch|checkout))' || true)"
PY_WRITES="$(printf '%s\n' "$PROBE" | grep -E 'subprocess|Popen|os\.system|os\.mkdir|os\.makedirs|shutil\.|\.write\(|open\([^)]*["'"'"']w' || true)"
C02=""
if command -v jq >/dev/null 2>&1; then
  H02="$(cd "$R02" && printf '%s' '{"session_id":"sess-tc02-probe"}' | bash "$HOOK" 2>/dev/null)"
  C02="$(printf '%s\n' "$H02" | jq -r '.additionalContext // ""' 2>/dev/null)"
fi
AFTER="$(fs_snapshot)"
if printf '%s\n' "$C02" | grep -F '[stage2-pending]' >/dev/null \
   && printf '%s\n' "$C02" | grep -F 'task-x' >/dev/null \
   && [ -z "$EXEC_WRITES" ] && [ -z "$PY_WRITES" ] \
   && [ "$BEFORE" = "$AFTER" ]; then
  ok "TC-02 stage2 探针只读（无执行写命令/文件系统零变化，提示文本不算写操作）"
else
  bad "TC-02 只读纪律破坏（exec=[$EXEC_WRITES] py=[$PY_WRITES] fs_changed=$([ "$BEFORE" = "$AFTER" ] && echo no || echo yes) pending=$(printf '%s\n' "$C02" | grep -c stage2-pending))"
fi

# verdict 夹具：<root> <plan-id> <decisions-json> <status-line> <attest-mode>
# sid=sess-rp01 → sidkey=rp01（与 plan-recovery.sh / plan-created.cjs 的 normSidkey 一致）
mkplan(){
  local root="$1" pid="$2" decisions="$3" status_line="$4" attest="$5" plan="$1/plans/$2"
  mkdir -p "$root/plans/$pid" "$root/plans/.active_plan_side"
  printf '# task plan\n%s\n' "$status_line" > "$plan/task_plan.md"
  printf '{"decisions":%s}\n' "$decisions" > "$plan/plan-state.json"
  printf '%s\n' "$pid" > "$root/plans/.active_plan_side/rp01.active_plan"
  case "$attest" in
    valid) printf 'plan_sha256=%s\n' "$(sha256sum "$plan/task_plan.md" | cut -d' ' -f1)" > "$plan/.plan-attestation" ;;
    stale) printf 'plan_sha256=%s\n' '0000000000000000000000000000000000000000000000000000000000000000' > "$plan/.plan-attestation" ;;
  esac
  printf '%s' "$root"
}

# TC-03: 四态枚举行为可达（正例×4，含 rc 语义 0/1/2 向后兼容）
V_REDY="$(mkplan "$T/ready"  rp '[]' '- **Status:** in_progress' valid)"
V_STALE="$(mkplan "$T/stale" sp '[]' '- **Status:** in_progress' stale)"
V_BLOCK="$(mkplan "$T/block" bp '[{"id":"D1","decision":"等待用户裁决","blocking":true,"confirmed":false}]' '- **Status:** in_progress' valid)"
V_DEGR="$(mkplan "$T/degr"  dp '[]' '- **Status:** in_progress' valid)"
printf '%s\n' '{bad json' > "$V_DEGR/plans/dp/plan-state.json"
# 四态合并为 1 个断言（brief 口径 TC-01..04）；每态实测明细单独打印，不计入 PASS 数
V_FAIL=0; V_DIAG=""
check_verdict(){ # <fixture-name> <root> <期望status> <期望rc>
  local name="$1" root="$2" want="$3" wantrc="$4" out rc
  out="$(bash "$LIB" verdict "$root" sess-rp01 2>/dev/null)"; rc=$?
  if [ "$rc" -eq "$wantrc" ] && printf '%s\n' "$out" | tail -n 1 | grep -qx "status: $want"; then
    echo "  TC-03-$name OK status=$want rc=$rc"
  else
    V_FAIL=$((V_FAIL+1))
    V_DIAG="$V_DIAG $name(期望=$want/$wantrc 实测=$(printf '%s\n' "$out" | tail -n 1)/$rc)"
    echo "  TC-03-$name FAIL 期望 status=$want rc=$wantrc，实测 out=[$(printf '%s\n' "$out" | tail -n 1)] rc=$rc"
  fi
}
check_verdict READY "$V_REDY" READY 0
check_verdict STALE "$V_STALE" STALE 1
check_verdict BLOCKED "$V_BLOCK" BLOCKED 0
check_verdict DEGRADED "$V_DEGR" DEGRADED 2
if [ "$V_FAIL" -eq 0 ]; then
  ok "TC-03 四态结构化 READY/STALE/BLOCKED/DEGRADED 行为可达且 rc 0/1/2 兼容"
else
  bad "TC-03 四态判定失败 $V_FAIL/4:$V_DIAG"
fi

# TC-04: 负控制 — 抹掉 verdict 输出行的副本不得再报 READY（证明 TC-03 判别性）
MUT="$T/lib-mut.sh"
sed "s/printf 'status: %s\\\\n'/printf 'MUTATED: %s\\\\n'/" "$LIB" > "$MUT"
MUT_OUT="$(bash "$MUT" verdict "$V_REDY" sess-rp01 2>/dev/null)"
if printf '%s\n' "$MUT_OUT" | grep -q 'status: READY'; then
  bad "TC-04 mutation 未被检出（删 verdict 行仍报 READY，TC-03 为假绿）"
else
  ok "TC-04 mutation 判别性成立（删 verdict 行后不再报 READY）"
fi

echo "[selftest-recovery-probe] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
