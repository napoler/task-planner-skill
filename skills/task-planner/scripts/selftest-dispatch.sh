#!/usr/bin/env bash
# selftest-dispatch.sh — task-v057 S3: check-dispatch.sh + zcode-pretooluse Agent 分支自测
# [2026-09-09] T01 合规放行 / T02-T04 三缺项(enforce exit2+stderr 含缺项) / T05 warn 放行+stdout [dispatch-warn]
#   / T06 off 静默 / T07 无计划 fail-open / T08 check 缺 2 项 exit1+恰 2 行 / T09-T11 hook Agent 分支集成
#   / [p7fix] T12 PLAN_DIR 尾斜杠归一化(TASK_PLANNER_PLAN_DIR="$PLAN/" + 合规 prompt) → exit 0
# hermetic: 临时工作区, 不触真实 plans/。全 PASS exit 0; 任一 FAIL exit 1。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISPATCH="$SCRIPT_DIR/check-dispatch.sh"
HOOK="$SCRIPT_DIR/zcode-pretooluse.sh"

SID="selftest-$$"   # [p7fix] 唯一 sid: 所有 pretool 用例统一用之, trap 清 warn 计数文件防残留
rm -f "${TMPDIR:-/tmp}/task-planner-dispatch-warn-selftest-"*   # [p7fix] 清历史残留(含崩溃未走 trap 的旧 PID 文件)
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"; rm -f "${TMPDIR:-/tmp}/task-planner-dispatch-warn-${SID}"' EXIT
PLAN="$TMP/plans/task-t"
mkdir -p "$PLAN" "$TMP/nowhere"

PASS=0; FAIL=0

# 组装 prompt: 7 必检项(三文件路径 + status:/acceptance:/checkpoint: + subagent-state/), 按参数逐项去掉
mk_prompt() {
  local f="$1"; shift
  local out items
  out=$(cat <<EOF
计划三文件(必传):
- task_plan: $PLAN/task_plan.md
- findings: $PLAN/findings.md
- progress: $PLAN/progress.md
status:
acceptance:
checkpoint: $PLAN/subagent-state/01-x.md
EOF
)
  for items in "$@"; do
    if [ -n "$items" ]; then
      out=$(printf '%s\n' "$out" | grep -vF -- "$items" || true)
    fi
  done
  printf '%s\n' "$out" > "$f"
}

# run_case <mode|unset> <cwd> <cmd...> → 存 RC/COUT/CERR
# 档位: enforce 硬覆盖(契约缺项断言必须 enforce, 不被外层档位扰动);
#   warn/off/unset 沿用外层值, 外层未设时用用例 mode(保 hermetic; 外层=off 时 T05 反验 FAIL)
run_case() {
  local mode="$1" cwd="$2"; shift 2
  if [ "$mode" = "unset" ]; then
    ( unset TASK_PLANNER_PLAN_DIR TASK_PLANNER_DISPATCH_ENFORCE; cd "$cwd"; "$@" >"$TMP/out" 2>"$TMP/err" )
  else
    ( export TASK_PLANNER_PLAN_DIR="$PLAN"
      [ "$mode" = "enforce" ] && export TASK_PLANNER_DISPATCH_ENFORCE=enforce
      export TASK_PLANNER_DISPATCH_ENFORCE="${TASK_PLANNER_DISPATCH_ENFORCE:-$mode}"
      cd "$cwd"; "$@" >"$TMP/out" 2>"$TMP/err" )
  fi
  RC=$?; COUT="$(cat "$TMP/out")"; CERR="$(cat "$TMP/err")"
}

# assert <T名> <got-rc> <exp-rc> <needle|-> <stream:out|err|lines>
assert() {
  local name="$1" rc="$2" exp="$3" needle="$4" stream="$5" ok=1
  [ "$rc" = "$exp" ] || ok=0
  if [ "$needle" != "-" ]; then
    case "$stream" in
      out)  printf '%s' "$COUT" | grep -qF -- "$needle" || ok=0 ;;
      err)  printf '%s' "$CERR" | grep -qF -- "$needle" || ok=0 ;;
      *)    [ "$(printf '%s' "$COUT" | tr -d '\n' | wc -c)" -eq 0 ] || ok=0 ;;
    esac
  fi
  if [ "$ok" = 1 ]; then PASS=$((PASS+1)); printf 'T%s PASS %s (rc=%s)\n' "$name" "$name" "$rc"
  else FAIL=$((FAIL+1)); printf 'T%s FAIL %s (rc=%s exp=%s needle=%s)\n' "$name" "$name" "$rc" "$exp" "$needle"; fi
}

# T01 合规 prompt, enforce → pretool 放行
mk_prompt "$TMP/p01.md"; run_case enforce "$TMP" bash "$DISPATCH" pretool "$TMP/p01.md" "$SID"; assert 01 "$RC" 0 - out

# T02 缺 findings.md 路径, enforce → exit 2 且 stderr 含缺项名
mk_prompt "$TMP/p02.md" "$PLAN/findings.md"; run_case enforce "$TMP" bash "$DISPATCH" pretool "$TMP/p02.md" "$SID"; assert 02 "$RC" 2 'findings.md' err

# T03 缺 acceptance:, enforce → exit 2 且 stderr 含缺项名
mk_prompt "$TMP/p03.md" 'acceptance:'; run_case enforce "$TMP" bash "$DISPATCH" pretool "$TMP/p03.md" "$SID"; assert 03 "$RC" 2 'acceptance:' err

# T04 缺 subagent-state/, enforce → exit 2 且 stderr 含缺项名
mk_prompt "$TMP/p04.md" 'subagent-state/'; run_case enforce "$TMP" bash "$DISPATCH" pretool "$TMP/p04.md" "$SID"; assert 04 "$RC" 2 'subagent-state/' err

# T05 同 T02 缺项, warn → 放行且 stdout 含 [dispatch-warn]
# [2026-09-12 task-v061] T05 前清锁: T01(enforce 放行路径)写下的新鲜锁残留, 会使 T05 的 warn 处置语义被串行槽守卫扰动;
# 串行锁场景全部归 TS-01..06 夹具(独立 plan-dir)专项覆盖, T 序列保持契约校验既有语义
rm -f "$PLAN/subagent-state/.dispatch-inflight"
mk_prompt "$TMP/p05.md" "$PLAN/findings.md"; run_case warn "$TMP" bash "$DISPATCH" pretool "$TMP/p05.md" "$SID"; assert 05 "$RC" 0 '[dispatch-warn]' out

# T06 off 档缺项 → 静默放行
mk_prompt "$TMP/p06.md" "$PLAN/findings.md" 'acceptance:'; run_case off "$TMP" bash "$DISPATCH" pretool "$TMP/p06.md" "$SID"; assert 06 "$RC" 0 - lines

# T07 unset PLAN_DIR + 无计划 cwd → fail-open 放行
mk_prompt "$TMP/p07.md"; run_case unset "$TMP/nowhere" bash "$DISPATCH" pretool "$TMP/p07.md" "$SID"; assert 07 "$RC" 0 - out

# T08 check 模式恰缺 2 项(progress.md 路径 + checkpoint: 标记)→ exit 1 且 stdout 恰 2 行
mk_prompt "$TMP/p08.md" "$PLAN/progress.md" 'checkpoint:'
printf 'state dir: %s/subagent-state/\n' "$PLAN" >> "$TMP/p08.md"   # 保 subagent-state/ 在,缺项恰 2
run_case off "$TMP" bash "$DISPATCH" check "$TMP/p08.md" "$PLAN"
assert 08 "$RC" 1 - out
[ "$RC" = 1 ] && [ "$(printf '%s\n' "$COUT" | wc -l | tr -d ' ')" -eq 2 ] && \
  printf '  (stdout 恰 2 行: %s | %s)\n' "$(printf '%s' "$COUT" | sed -n 1p)" "$(printf '%s' "$COUT" | sed -n 2p)"

# T09 hook 集成: Agent 工具 + 无契约 prompt, enforce, cwd=$TMP/nowhere 防哨兵 → exit 2
# (env 须 export 给 hook 子进程; 管道前缀只对 printf 生效)
run_case enforce "$TMP/nowhere" sh -c \
  'export TASK_PLANNER_DISPATCH_ENFORCE=enforce
   printf %s "{\"tool_name\":\"Agent\",\"session_id\":\"t\",\"tool_input\":{\"prompt\":\"goal only\"}}" | bash "$0"' "$HOOK"
assert 09 "$RC" 2 - out

# T10 hook 集成: prompt(jq -Rs 转义)含全部 7 项, PLAN_DIR 指向 $PLAN → exit 0
PROMPT10="plan: $PLAN/task_plan.md $PLAN/findings.md $PLAN/progress.md
status: acceptance: checkpoint: $PLAN/subagent-state/10.md"
export INPUT10
INPUT10=$(printf '%s' "$PROMPT10" | jq -Rs '{tool_name:"Agent",session_id:"t",tool_input:{prompt:.}}')
run_case enforce "$TMP/nowhere" sh -c 'printf %s "$INPUT10" | bash "$0"' "$HOOK"
assert 10 "$RC" 0 - out

# T11 hook 非 Agent 工具(Read) → 不受影响放行
# [2026-09-12 task-v061] 清锁防互扰: T05 后残留的新鲜锁会撞 T10/T12 的 enforce 调用(串行槽守卫正确阻断 → 既有用例裸跑变红),
# 清 PLAN 夹具锁; TS-01..06 锁场景走独立 tscl 夹具, 互不干扰
rm -f "$PLAN/subagent-state/.dispatch-inflight"
printf '{"tool_name":"Read","tool_input":{"file_path":"/x"}}' | bash "$HOOK" >"$TMP/out" 2>"$TMP/err"
RC=$?; COUT="$(cat "$TMP/out")"; assert 11 "$RC" 0 - out

# T12 [p7fix] PLAN_DIR 尾斜杠: TASK_PLANNER_PLAN_DIR="$PLAN/" + 合规 prompt(路径不带尾斜杠) → exit 0
mk_prompt "$TMP/p12.md"
( export TASK_PLANNER_PLAN_DIR="$PLAN/"; export TASK_PLANNER_DISPATCH_ENFORCE=enforce
  cd "$TMP"; bash "$DISPATCH" pretool "$TMP/p12.md" "$SID" >"$TMP/out" 2>"$TMP/err" )
RC=$?; COUT="$(cat "$TMP/out")"; CERR="$(cat "$TMP/err")"; assert 12 "$RC" 0 - out

# TS-01..06 [task-v061] 串行槽守卫 serial_slot_check(经真实入口 pretool 触发):
# 独立夹具 plan-dir(禁触真实 plans/): 三文件 + 合规 prompt + subagent-state/; 用例间清锁防互扰
TSCL="$TMP/tscl"; TSCLP="$TSCL/plans/task-ts"; mkdir -p "$TSCLP/subagent-state"
printf 'ts task plan\n' > "$TSCLP/task_plan.md"
printf 'ts findings\n' > "$TSCLP/findings.md"
printf 'ts progress\n' > "$TSCLP/progress.md"
tscl_prompt() {   # 7 必检项齐备的合规 prompt(全部指向夹具目录)
  cat <<EOF > "$1"
- task_plan: $TSCLP/task_plan.md
- findings: $TSCLP/findings.md
- progress: $TSCLP/progress.md
status:
acceptance:
checkpoint: $TSCLP/subagent-state/ts01.md
EOF
}
LOCK="$TSCLP/subagent-state/.dispatch-inflight"

# TS-01 无锁 + enforce → 放行且锁已写入(内容为 unix 时间戳数字)
rm -f "$LOCK"; tscl_prompt "$TSCL/p1.md"
run_case off "$TMP" env TASK_PLANNER_PLAN_DIR="$TSCLP" TASK_PLANNER_DISPATCH_ENFORCE=enforce \
  bash "$DISPATCH" pretool "$TSCL/p1.md" "$SID"
[ "$RC" = 0 ] && [ -f "$LOCK" ] && head -n1 "$LOCK" | grep -qE '^[0-9]+$' \
  && { TSOK=1; } || { TSOK=0; }
[ "$TSOK" = 1 ] && { PASS=$((PASS+1)); printf 'TS-01 PASS (rc=%s, 锁写入=%s)\n' "$RC" "$(head -n1 "$LOCK" 2>/dev/null)"; } \
  || { FAIL=$((FAIL+1)); printf 'TS-01 FAIL (rc=%s exp=0, 锁=%s)\n' "$RC" "$(ls "$TSCLP/subagent-state/" 2>/dev/null | tr '\n' ' ')"; }

# TS-02 新鲜锁(<120s) + enforce → exit 2 且 stderr 含「串行」
printf '%s' "$(date +%s)" > "$LOCK"; tscl_prompt "$TSCL/p2.md"
run_case off "$TMP" env TASK_PLANNER_PLAN_DIR="$TSCLP" TASK_PLANNER_DISPATCH_ENFORCE=enforce \
  bash "$DISPATCH" pretool "$TSCL/p2.md" "$SID"
[ "$RC" = 2 ] && printf '%s' "$CERR" | grep -qF '串行' && { TSOK=1; } || { TSOK=0; }
[ "$TSOK" = 1 ] && { PASS=$((PASS+1)); printf 'TS-02 PASS (rc=2, stderr 含 串行)\n'; } \
  || { FAIL=$((FAIL+1)); printf 'TS-02 FAIL (rc=%s exp=2, stderr=%s)\n' "$RC" "$(printf '%s' "$CERR" | head -n1)"; }

# TS-03 新鲜锁 + warn → 放行且 stderr 警告含「串行」
printf '%s' "$(date +%s)" > "$LOCK"; tscl_prompt "$TSCL/p3.md"
run_case off "$TMP" env TASK_PLANNER_PLAN_DIR="$TSCLP" TASK_PLANNER_DISPATCH_ENFORCE=warn \
  bash "$DISPATCH" pretool "$TSCL/p3.md" "$SID"
[ "$RC" = 0 ] && printf '%s' "$CERR" | grep -qF '串行' && { TSOK=1; } || { TSOK=0; }
[ "$TSOK" = 1 ] && { PASS=$((PASS+1)); printf 'TS-03 PASS (rc=0, stderr 含 串行警告)\n'; } \
  || { FAIL=$((FAIL+1)); printf 'TS-03 FAIL (rc=%s exp=0, stderr=%s)\n' "$RC" "$(printf '%s' "$CERR" | head -n1)"; }

# TS-04 陈旧锁(时间戳-200s ≥120s, 崩溃残留) + enforce → 放行且锁刷新为近新值
printf '%s' "$(( $(date +%s) - 200 ))" > "$LOCK"; tscl_prompt "$TSCL/p4.md"
run_case off "$TMP" env TASK_PLANNER_PLAN_DIR="$TSCLP" TASK_PLANNER_DISPATCH_ENFORCE=enforce \
  bash "$DISPATCH" pretool "$TSCL/p4.md" "$SID"
TSNEW="$(head -n1 "$LOCK" 2>/dev/null)"
[ "$RC" = 0 ] && [ -n "$TSNEW" ] && [ "$TSNEW" -gt "$(( $(date +%s) - 120 ))" ] \
  && { TSOK=1; } || { TSOK=0; }
[ "$TSOK" = 1 ] && { PASS=$((PASS+1)); printf 'TS-04 PASS (rc=%s, 锁刷新=%s)\n' "$RC" "$TSNEW"; } \
  || { FAIL=$((FAIL+1)); printf 'TS-04 FAIL (rc=%s exp=0, 锁=%s)\n' "$RC" "${TSNEW:-缺}"; }

# TS-05 新鲜锁 + off 档 → 静默放行且锁未被改写
printf '1234567890' > "$LOCK"; tscl_prompt "$TSCL/p5.md"
run_case off "$TMP" env TASK_PLANNER_PLAN_DIR="$TSCLP" TASK_PLANNER_DISPATCH_ENFORCE=off \
  bash "$DISPATCH" pretool "$TSCL/p5.md" "$SID"
[ "$RC" = 0 ] && [ "$(head -n1 "$LOCK" 2>/dev/null)" = '1234567890' ] && [ ! -s "$TMP/out" ] \
  && { TSOK=1; } || { TSOK=0; }
[ "$TSOK" = 1 ] && { PASS=$((PASS+1)); printf 'TS-05 PASS (rc=%s, 锁未改写)\n' "$RC"; } \
  || { FAIL=$((FAIL+1)); printf 'TS-05 FAIL (rc=%s exp=0, 锁=%s)\n' "$RC" "$(head -n1 "$LOCK" 2>/dev/null)"; }

# TS-06 清锁路径: 模拟 PostToolUse 清锁动作(rm)后, 再 enforce 调用 → 放行且无锁阻断
rm -f "$LOCK"; tscl_prompt "$TSCL/p6.md"
run_case off "$TMP" env TASK_PLANNER_PLAN_DIR="$TSCLP" TASK_PLANNER_DISPATCH_ENFORCE=enforce \
  bash "$DISPATCH" pretool "$TSCL/p6.md" "$SID"
rm -f "$LOCK"   # PostToolUse 清锁: 子代理验收通过后串行槽释放
[ "$RC" = 0 ] && [ ! -f "$LOCK" ] \
  && { TSOK=1; } || { TSOK=0; }
[ "$TSOK" = 1 ] && { PASS=$((PASS+1)); printf 'TS-06 PASS (rc=%s, 锁已清除)\n' "$RC"; } \
  || { FAIL=$((FAIL+1)); printf 'TS-06 FAIL (rc=%s, 锁=%s)\n' "$RC" "$([ -f "$LOCK" ] && echo 残留 || echo 无)"; }

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
