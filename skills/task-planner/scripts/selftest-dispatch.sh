#!/usr/bin/env bash
# selftest-dispatch.sh — task-v057 S3: check-dispatch.sh + zcode-pretooluse Agent 分支自测
# [2026-09-09] T01 合规放行 / T02-T04 三缺项(enforce exit2+stderr 含缺项) / T05 warn 放行+stdout [dispatch-warn]
#   / T06 off 静默 / T07 无计划 fail-open / T08 check 缺 2 项 exit1+恰 2 行 / T09-T11 hook Agent 分支集成
# hermetic: 临时工作区, 不触真实 plans/。全 PASS exit 0; 任一 FAIL exit 1。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISPATCH="$SCRIPT_DIR/check-dispatch.sh"
HOOK="$SCRIPT_DIR/zcode-pretooluse.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
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
mk_prompt "$TMP/p01.md"; run_case enforce "$TMP" bash "$DISPATCH" pretool "$TMP/p01.md" t; assert 01 "$RC" 0 - out

# T02 缺 findings.md 路径, enforce → exit 2 且 stderr 含缺项名
mk_prompt "$TMP/p02.md" "$PLAN/findings.md"; run_case enforce "$TMP" bash "$DISPATCH" pretool "$TMP/p02.md" t; assert 02 "$RC" 2 'findings.md' err

# T03 缺 acceptance:, enforce → exit 2 且 stderr 含缺项名
mk_prompt "$TMP/p03.md" 'acceptance:'; run_case enforce "$TMP" bash "$DISPATCH" pretool "$TMP/p03.md" t; assert 03 "$RC" 2 'acceptance:' err

# T04 缺 subagent-state/, enforce → exit 2 且 stderr 含缺项名
mk_prompt "$TMP/p04.md" 'subagent-state/'; run_case enforce "$TMP" bash "$DISPATCH" pretool "$TMP/p04.md" t; assert 04 "$RC" 2 'subagent-state/' err

# T05 同 T02 缺项, warn → 放行且 stdout 含 [dispatch-warn]
mk_prompt "$TMP/p05.md" "$PLAN/findings.md"; run_case warn "$TMP" bash "$DISPATCH" pretool "$TMP/p05.md" t; assert 05 "$RC" 0 '[dispatch-warn]' out

# T06 off 档缺项 → 静默放行
mk_prompt "$TMP/p06.md" "$PLAN/findings.md" 'acceptance:'; run_case off "$TMP" bash "$DISPATCH" pretool "$TMP/p06.md" t; assert 06 "$RC" 0 - lines

# T07 unset PLAN_DIR + 无计划 cwd → fail-open 放行
mk_prompt "$TMP/p07.md"; run_case unset "$TMP/nowhere" bash "$DISPATCH" pretool "$TMP/p07.md" t; assert 07 "$RC" 0 - out

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
printf '{"tool_name":"Read","tool_input":{"file_path":"/x"}}' | bash "$HOOK" >"$TMP/out" 2>"$TMP/err"
RC=$?; COUT="$(cat "$TMP/out")"; assert 11 "$RC" 0 - out

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
