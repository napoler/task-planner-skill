#!/usr/bin/env bash
# fixtures-tier.sh — tier 升级链夹具（T1~T8）
# [task-tier-deadzone-fix-20261125]（R1）/ [R2 重写 2026-11-25]
# What: 对共享库 lib/tier-upgrade-lib.sh、通用检查脚本 tier-upgrade-check.sh、zcode host 做行为夹具。
# Why:  R1 critic 复检指出三处测试诚实性问题，R2 重写修掉：
#   ① 路径硬绑已删除的 worktree（合并后不可复跑）→ 改 WT=${TIER_FX_WT:-<主仓>}，默认主仓可复跑；
#   ② legacy 态放错目录（代码从不读该路径 → 断言恒真）→ 移到真实旧键位 <plans_root>/.tier_state/<sid>.state；
#   ③ `out=$(cmd; true)` 后取 $? 恒为 0（掩 rc）→ 直接调用后取 $?。
#   新增 T7（C-1 半升级死区回归锚）与 T8（I-2 脏 state 键不伪造 TU-1 + 单次 emit）。
# 用法: bash fixtures-tier.sh
#       预合并环境: TIER_FX_WT=<worktree 绝对路径> bash fixtures-tier.sh
set -uo pipefail

WT="${TIER_FX_WT:-/mnt/data/dev/task-planner-skill}"
LIB="$WT/skills/task-planner/scripts/lib/tier-upgrade-lib.sh"
PLANCTL="$WT/skills/task-planner/scripts/planctl.py"
CHECK="$WT/skills/task-planner/scripts/tier-upgrade-check.sh"
HOOK="$WT/skills/task-planner/scripts/zcode-posttooluse.sh"
SKILL_ROOT="$WT/skills/task-planner"
SANDBOX="/tmp/tierfx-$$"
FAIL=0
TOTAL=0
EMIT_CALLS=0

cleanup() { chmod -R u+rwx "$SANDBOX" 2>/dev/null || true; rm -rf "$SANDBOX"; }
trap cleanup EXIT
mkdir -p "$SANDBOX"

pass() { echo "$1-PASS"; }
fail() { echo "$1-FAIL $2"; FAIL=$((FAIL+1)); }

# tier_emit 计数包装：直接验证「一轮至多一次 emit」（F3/F9 结构性断言，不靠肉眼数行）
tier_emit() { EMIT_CALLS=$((EMIT_CALLS + 1)); printf '%s\n' "$1"; }
# shellcheck source=/dev/null
. "$LIB" || { echo "FIXTURES-DONE FAIL=99 (source failed: $LIB)"; exit 99; }

make_plan() {
  local root="$1" tid="$2" tier="${3:-mini}"
  local pdir="$root/plans/$tid"
  mkdir -p "$pdir"
  python3 "$PLANCTL" init --plan-dir "$pdir" --task-id "$tid" --tier "$tier" --lane L0 >/dev/null 2>&1 || return 1
  python3 "$PLANCTL" set --plan-dir "$pdir" --field created_at --value 2026-11-24T00:00:00Z >/dev/null 2>&1 || return 1
  python3 "$PLANCTL" add --plan-dir "$pdir" --section phases --json '{"id":"P1","name":"fx","status":"complete"}' >/dev/null 2>&1 || return 1
  echo "$pdir"
}

tier_of() { jq -r '.plan_tier' "$1/plan-state.json" 2>/dev/null; }
has_tu1() { jq -e '.decisions[]? | select(.id=="TU-1")' "$1/plan-state.json" >/dev/null 2>&1; }
# 单次调用包装：重置 emit 计数与升级标志，直接调用（不掩 rc）。
# 为什么不用 out=$(run_check ...)：$() 是子 shell，EMIT_CALLS/TIER_UPGRADED 的自增会丢在子 shell 里
# （R1 夹具 `; true` 掩 rc 的同类陷阱）→ 改为同 shell 调用 + 输出落盘再读，计数与标志在主 shell 可见。
OUTF="$SANDBOX/.last_out"
LAST_OUT=""
LAST_RC=0
run_check() {
  EMIT_CALLS=0
  unset TIER_UPGRADED
  : > "$OUTF"
  tier_upgrade_check "$@" >"$OUTF" 2>&1
  LAST_RC=$?          # 真实返回码（同 shell 捕获，不靠 $() 后的 $?）
  LAST_OUT="$(cat "$OUTF")"
  return 0
}

run_t1() {
  local reason="" ok=1 root="$SANDBOX/t1" pA pB outA outB
  mkdir -p "$root/plans/.tier_state"
  # legacy 旧键 = 真实旧实现写入位（<plans_root>/.tier_state/<sid>.state），验证「新代码不读旧键、旧键不迁移」
  printf 'upgraded=1 upgraded_at=legacy\n' > "$root/plans/.tier_state/fxsid.state"
  pA=$(make_plan "$root" "fx-a") || { fail T1 "init A failed"; return; }
  pB=$(make_plan "$root" "fx-b") || { fail T1 "init B failed"; return; }
  run_check "$pA/task_plan.md" "fxsid" "$pA" "$root/plans"; outA="$LAST_OUT"; [ "$LAST_RC" -eq 0 ] || { ok=0; reason="A rc=$LAST_RC"; }
  run_check "$pB/task_plan.md" "fxsid" "$pB" "$root/plans"; outB="$LAST_OUT"; [ "$LAST_RC" -eq 0 ] || { ok=0; reason="${reason:+$reason; }B rc=$LAST_RC"; }
  [ "$(tier_of "$pA")" = "standard" ] || { ok=0; reason="${reason:+$reason; }A tier=$(tier_of "$pA")"; }
  [ -f "$root/plans/.tier_state/fxsid_fx-a.state" ] && grep -q '^upgraded=1' "$root/plans/.tier_state/fxsid_fx-a.state" || { ok=0; reason="${reason:+$reason; }A state missing/bad"; }
  [ "$(tier_of "$pB")" = "standard" ] || { ok=0; reason="${reason:+$reason; }B tier=$(tier_of "$pB")"; }
  [ -f "$root/plans/.tier_state/fxsid_fx-b.state" ] && grep -q '^upgraded=1' "$root/plans/.tier_state/fxsid_fx-b.state" || { ok=0; reason="${reason:+$reason; }B state missing/bad"; }
  # 旧键在真实 state 目录内 → 此断言有实际判别力（若代码误读旧键，B 的第二次调用会静默且 tier 不变）
  [ -f "$root/plans/.tier_state/fxsid.state" ] && grep -q 'upgraded_at=legacy' "$root/plans/.tier_state/fxsid.state" || { ok=0; reason="${reason:+$reason; }legacy missing/mutated"; }
  echo "$outA" | grep -q '已运行' || { ok=0; reason="${reason:+$reason; }A no emit"; }
  echo "$outB" | grep -q '已运行' || { ok=0; reason="${reason:+$reason; }B no emit"; }
  if [ "$ok" = 1 ]; then pass T1; else fail T1 "$reason"; fi
}

run_t2() {
  local reason="" ok=1 root="$SANDBOX/t2" pC outC
  pC=$(make_plan "$root" "fx-c") || { fail T2 "init failed"; return; }
  python3 "$PLANCTL" set --plan-dir "$pC" --field plan_tier --value standard >/dev/null 2>&1
  mkdir -p "$root/plans/.tier_state"
  printf 'upgrading=1 upgraded_at=crashed\n' > "$root/plans/.tier_state/fxsid_fx-c.state"
  run_check "$pC/task_plan.md" "fxsid" "$pC" "$root/plans"; outC="$LAST_OUT"
  [ "$(tier_of "$pC")" = "standard" ] || { ok=0; reason="tier=$(tier_of "$pC")"; }
  has_tu1 "$pC" || { ok=0; reason="${reason:+$reason; }no TU-1"; }
  grep -q '^upgraded=1' "$root/plans/.tier_state/fxsid_fx-c.state" || { ok=0; reason="${reason:+$reason; }state not upgraded"; }
  echo "$outC" | grep -q '半升级自愈' || { ok=0; reason="${reason:+$reason; }no repair emit"; }
  [ "${TIER_UPGRADED:-0}" = 1 ] || { ok=0; reason="${reason:+$reason; }TIER_UPGRADED!=1"; }
  [ "$EMIT_CALLS" -eq 1 ] || { ok=0; reason="${reason:+$reason; }emit=$EMIT_CALLS!=1"; }
  if [ "$ok" = 1 ]; then pass T2; else fail T2 "$reason"; fi
}

run_t3() {
  local reason="" ok=1 root="$SANDBOX/t3" pD outD rc
  pD=$(make_plan "$root" "fx-d") || { fail T3 "init failed"; return; }
  chmod 555 "$pD"
  run_check "$pD/task_plan.md" "fxsid" "$pD" "$root/plans"; outD="$LAST_OUT"; rc=$LAST_RC
  chmod 755 "$pD"
  echo "$outD" | grep -q 'FAIL: set' || { ok=0; reason="no FAIL:set in [$outD]"; }
  [ "$rc" -eq 0 ] || { ok=0; reason="${reason:+$reason; }rc=$rc"; }
  [ -f "$root/plans/.tier_state/fxsid_fx-d.state" ] && grep -q '^upgrading=1' "$root/plans/.tier_state/fxsid_fx-d.state" || { ok=0; reason="${reason:+$reason; }state not upgrading"; }
  [ "$(tier_of "$pD")" = "mini" ] || { ok=0; reason="${reason:+$reason; }tier=$(tier_of "$pD")"; }
  echo "$outD" | grep -qE '已运行|半升级自愈完成' && { ok=0; reason="${reason:+$reason; }false success text"; }
  [ "${TIER_UPGRADED:-0}" = 0 ] || { ok=0; reason="${reason:+$reason; }TIER_UPGRADED set on failure"; }
  [ "$EMIT_CALLS" -eq 1 ] || { ok=0; reason="${reason:+$reason; }emit=$EMIT_CALLS!=1"; }
  if [ "$ok" = 1 ]; then pass T3; else fail T3 "$reason"; fi
}

run_t4() {
  local reason="" ok=1 g1 g2 g3 g4 g5 g6 g7 g7n g7ok g8 g9 v
  g1=$(grep -rn "tier_upgrade_check()" "$WT/skills/task-planner/scripts" --include='*.sh' | grep -v "lib/tier-upgrade-lib.sh" || true)
  [ -z "$g1" ] || { ok=0; reason="g1:$g1"; }
  g2=$(grep -c "tier-upgrade-check.sh" "$WT/skills/task-planner/lib/install-stub.sh" || true)
  [ "$g2" -ge 3 ] || { ok=0; reason="${reason:+$reason; }g2=$g2"; }
  g3=$(grep -n 'HOME/\.zcode\|HOME/\.claude' "$WT/skills/task-planner/scripts/lib/tier-upgrade-lib.sh" "$WT/skills/task-planner/scripts/tier-upgrade-check.sh" || true)
  [ -z "$g3" ] || { ok=0; reason="${reason:+$reason; }g3 hit"; }
  g4=$(grep -c "TIER_UPGRADED" "$WT/skills/task-planner/scripts/zcode-posttooluse.sh" || true)
  [ "$g4" -ge 2 ] || { ok=0; reason="${reason:+$reason; }g4=$g4"; }
  g5=$(grep -c "无 hook 工具位" "$WT/skills/task-planner/SKILL.md" || true)
  [ "$g5" -ge 1 ] || { ok=0; reason="${reason:+$reason; }g5=$g5"; }
  g6=$(grep -c "tier-upgrade-check.sh" "$WT/skills/task-planner/SKILL.md" || true)
  [ "$g6" -ge 1 ] || { ok=0; reason="${reason:+$reason; }g6=$g6"; }
  g7=$( (grep -ohE 'TASK_PLANNER_TIER_UPGRADE[A-Z_]*' "$WT/skills/task-planner/scripts/lib/tier-upgrade-lib.sh" "$WT/skills/task-planner/scripts/zcode-posttooluse.sh" 2>/dev/null || true) | sort -u )
  g7n=$(printf '%s\n' "$g7" | sed '/^$/d' | wc -l | tr -d ' ')
  g7ok=1
  [ "$g7n" -eq 2 ] || g7ok=0
  while IFS= read -r v; do [ -z "$v" ] && continue; echo "$v" | grep -q 'MINUTES$' || g7ok=0; done <<< "$g7"
  [ "$g7ok" = 1 ] || { ok=0; reason="${reason:+$reason; }g7=[$g7]"; }
  # [R2/F6] claude 注册器必须含 tier 条目（否则文档指定的安装路径装不出通道）
  g8=$(grep -c "tier-upgrade-check" "$WT/skills/task-planner/scripts/register-hooks-cj.ts" || true)
  [ "${g8:-0}" -ge 1 ] || { ok=0; reason="${reason:+$reason; }g8=$g8"; }
  # [R2/F3] 库内 tier_emit 调用点唯一（只在 tier_flush 出口；定义行 `tier_emit() {` 不匹配 `tier_emit "`）
  g9=$(grep -c 'tier_emit "' "$WT/skills/task-planner/scripts/lib/tier-upgrade-lib.sh" || true)
  [ "${g9:-0}" -eq 1 ] || { ok=0; reason="${reason:+$reason; }g9=$g9"; }
  [ -x "$WT/skills/task-planner/scripts/tier-upgrade-check.sh" ] || { ok=0; reason="${reason:+$reason; }check not executable"; }
  if [ "$ok" = 1 ]; then pass T4; else fail T4 "$reason"; fi
}

run_t5() {
  local reason="" ok=1 root="$SANDBOX/t5" pE tmpj outE
  pE=$(make_plan "$root" "fx-e") || { fail T5 "init failed"; return; }
  tmpj="$pE/plan-state.json.tmp"
  jq '.outcome = {"result":"COMPLETE"}' "$pE/plan-state.json" > "$tmpj" && mv "$tmpj" "$pE/plan-state.json"
  run_check "$pE/task_plan.md" "fxsid" "$pE" "$root/plans"; outE="$LAST_OUT"
  [ "$(tier_of "$pE")" = "mini" ] || { ok=0; reason="tier=$(tier_of "$pE")"; }
  [ ! -f "$root/plans/.tier_state/fxsid_fx-e.state" ] || { ok=0; reason="${reason:+$reason; }state exists"; }
  has_tu1 "$pE" && { ok=0; reason="${reason:+$reason; }TU-1 present"; }
  [ -z "$outE" ] || { ok=0; reason="${reason:+$reason; }unexpected emit"; }
  # 表达式口径单测（与库内/宿主内表达式一致）：object COMPLETE / scalar COMPLETE 命中，object PARTIAL 不命中
  echo '{"outcome":{"result":"COMPLETE"}}' | jq -e '(.outcome // "") | (if type == "object" then (.result // "") else . end) | test("^(COMPLETE|BLOCKED)$")' >/dev/null 2>&1 || { ok=0; reason="${reason:+$reason; }expr obj COMPLETE failed"; }
  echo '{"outcome":"COMPLETE"}' | jq -e '(.outcome // "") | (if type == "object" then (.result // "") else . end) | test("^(COMPLETE|BLOCKED)$")' >/dev/null 2>&1 || { ok=0; reason="${reason:+$reason; }expr scalar COMPLETE failed"; }
  if echo '{"outcome":{"result":"PARTIAL"}}' | jq -e '(.outcome // "") | (if type == "object" then (.result // "") else . end) | test("^(COMPLETE|BLOCKED)$")' >/dev/null 2>&1; then ok=0; reason="${reason:+$reason; }expr PARTIAL should fail"; fi
  if [ "$ok" = 1 ]; then pass T5; else fail T5 "$reason"; fi
}

run_t6() {
  local reason="" ok=1 r="$SANDBOX/t6" outG
  mkdir -p "$r/plans/fx-g"
  python3 "$PLANCTL" init --plan-dir "$r/plans/fx-g" --task-id fx-g --tier mini --lane L0 >/dev/null 2>&1 || { fail T6 "init"; return; }
  python3 "$PLANCTL" set --plan-dir "$r/plans/fx-g" --field created_at --value 2026-11-24T00:00:00Z >/dev/null 2>&1
  python3 "$PLANCTL" add --plan-dir "$r/plans/fx-g" --section phases --json '{"id":"P1","name":"fx","status":"complete"}' >/dev/null 2>&1
  printf '# stub\nplan_tier: mini\n' > "$r/plans/fx-g/task_plan.md"
  printf 'fx-g\n' > "$r/plans/.active_plan"
  outG=$(printf '%s' '{"session_id":"fx7","cwd":"'"$r"'"}' | bash "$CHECK" 2>&1)
  [ "$(tier_of "$r/plans/fx-g")" = "standard" ] || { ok=0; reason="tier=$(tier_of "$r/plans/fx-g")"; }
  [ -f "$r/plans/.tier_state/fx7_fx-g.state" ] && grep -q '^upgraded=1' "$r/plans/.tier_state/fx7_fx-g.state" || { ok=0; reason="${reason:+$reason; }state missing"; }
  echo "$outG" | grep -q '已运行' || { ok=0; reason="${reason:+$reason; }no emit [$outG]"; }
  if [ "$ok" = 1 ]; then pass T6; else fail T6 "$reason"; fi
}

# T7 [R2/C-1 回归锚]：半升级态 + 步骤持续失败 → 禁假成功/禁翻 upgraded=1/次轮续跑；权限恢复后能真自愈
run_t7() {
  local reason="" ok=1 root="$SANDBOX/t7" pH out1 out2 out3
  pH=$(make_plan "$root" "fx-h") || { fail T7 "init failed"; return; }
  mkdir -p "$root/plans/.tier_state"
  printf 'upgrading=1 upgraded_at=crashed\n' > "$root/plans/.tier_state/fxsid_fx-h.state"
  chmod 555 "$pH"
  run_check "$pH/task_plan.md" "fxsid" "$pH" "$root/plans"; out1="$LAST_OUT"; [ "$LAST_RC" -eq 0 ] || { ok=0; reason="run1 rc=$LAST_RC"; }
  [ "$EMIT_CALLS" -eq 1 ] || { ok=0; reason="${reason:+$reason; }run1 emit=$EMIT_CALLS!=1"; }
  echo "$out1" | grep -q 'FAIL' || { ok=0; reason="${reason:+$reason; }run1 no FAIL"; }
  echo "$out1" | grep -qE '自愈完成|已运行' && { ok=0; reason="${reason:+$reason; }run1 false success"; }
  grep -q '^upgrading=1' "$root/plans/.tier_state/fxsid_fx-h.state" || { ok=0; reason="${reason:+$reason; }run1 state flipped"; }
  [ "$(tier_of "$pH")" = "mini" ] || { ok=0; reason="${reason:+$reason; }run1 tier=$(tier_of "$pH")"; }
  # 第二轮：仍在失败环境（未恢复 755）→ 必须继续曝光 FAIL，且状态仍 upgrading=1、仍 mini、仍无成功文案
  run_check "$pH/task_plan.md" "fxsid" "$pH" "$root/plans"; out2="$LAST_OUT"; [ "$LAST_RC" -eq 0 ] || { ok=0; reason="${reason:+$reason; }run2 rc=$LAST_RC"; }
  echo "$out2" | grep -q 'FAIL' || { ok=0; reason="${reason:+$reason; }run2 no FAIL (silent dead zone)"; }
  echo "$out2" | grep -qE '自愈完成|已运行' && { ok=0; reason="${reason:+$reason; }run2 false success"; }
  grep -q '^upgrading=1' "$root/plans/.tier_state/fxsid_fx-h.state" || { ok=0; reason="${reason:+$reason; }run2 state flipped"; }
  [ "$(tier_of "$pH")" = "mini" ] || { ok=0; reason="${reason:+$reason; }run2 tier=$(tier_of "$pH")"; }
  has_tu1 "$pH" && { ok=0; reason="${reason:+$reason; }run2 fabricated TU-1"; }
  # 第三轮：权限恢复 → 真自愈（证明不是永久死区）
  chmod 755 "$pH"
  run_check "$pH/task_plan.md" "fxsid" "$pH" "$root/plans"; out3="$LAST_OUT"
  [ "$(tier_of "$pH")" = "standard" ] || { ok=0; reason="${reason:+$reason; }run3 tier=$(tier_of "$pH")"; }
  has_tu1 "$pH" || { ok=0; reason="${reason:+$reason; }run3 no TU-1"; }
  grep -q '^upgraded=1' "$root/plans/.tier_state/fxsid_fx-h.state" || { ok=0; reason="${reason:+$reason; }run3 state not upgraded"; }
  echo "$out3" | grep -q '半升级自愈完成' || { ok=0; reason="${reason:+$reason; }run3 no success notice"; }
  [ "${TIER_UPGRADED:-0}" = 1 ] || { ok=0; reason="${reason:+$reason; }run3 TIER_UPGRADED!=1"; }
  if [ "$ok" = 1 ]; then pass T7; else fail T7 "$reason"; fi
}

# T8 [R2/I-2 回归锚]：脏 state 键（空/垃圾）不伪造 TU-1；fresh 成功路径单次 emit
run_t8() {
  local reason="" ok=1 root="$SANDBOX/t8" pA pB pC outA outB outC hookout
  pA=$(make_plan "$root" "fx-s1" standard) || { fail T8 "init A failed"; return; }
  mkdir -p "$root/plans/.tier_state"
  : > "$root/plans/.tier_state/fxsid_fx-s1.state"          # A: 空文件
  run_check "$pA/task_plan.md" "fxsid" "$pA" "$root/plans"; outA="$LAST_OUT"
  [ -z "$outA" ] || { ok=0; reason="A unexpected emit [$outA]"; }
  has_tu1 "$pA" && { ok=0; reason="${reason:+$reason; }A fabricated TU-1"; }
  [ ! -f "$root/plans/.tier_state/fxsid_fx-s1.state" ] || { ok=0; reason="${reason:+$reason; }A dirty key kept"; }
  [ "$(tier_of "$pA")" = "standard" ] || { ok=0; reason="${reason:+$reason; }A tier=$(tier_of "$pA")"; }

  pB=$(make_plan "$root" "fx-s2" standard) || { fail T8 "init B failed"; return; }
  printf 'garbage line\nupgrad_at=nope\n' > "$root/plans/.tier_state/fxsid_fx-s2.state"   # B: 垃圾行
  run_check "$pB/task_plan.md" "fxsid" "$pB" "$root/plans"; outB="$LAST_OUT"
  [ -z "$outB" ] || { ok=0; reason="${reason:+$reason; }B unexpected emit [$outB]"; }
  has_tu1 "$pB" && { ok=0; reason="${reason:+$reason; }B fabricated TU-1"; }
  [ "$(tier_of "$pB")" = "standard" ] || { ok=0; reason="${reason:+$reason; }B tier=$(tier_of "$pB")"; }

  # C: fresh 成功路径（lib 层，单次 emit）+ 同场景过 zcode 宿主（单行 JSON，F9）
  pC=$(make_plan "$root" "fx-s3") || { fail T8 "init C failed"; return; }
  run_check "$pC/task_plan.md" "fxsid" "$pC" "$root/plans"; outC="$LAST_OUT"
  [ "$EMIT_CALLS" -eq 1 ] || { ok=0; reason="${reason:+$reason; }C emit=$EMIT_CALLS!=1"; }
  echo "$outC" | grep -q '已运行' || { ok=0; reason="${reason:+$reason; }C no emit"; }
  [ "$(tier_of "$pC")" = "standard" ] || { ok=0; reason="${reason:+$reason; }C tier=$(tier_of "$pC")"; }
  grep -q '^upgraded=1' "$root/plans/.tier_state/fxsid_fx-s3.state" || { ok=0; reason="${reason:+$reason; }C state not upgraded"; }
  printf 'fx-s3\n' > "$root/plans/.active_plan"
  printf '# stub\nplan_tier: mini\n' > "$pC/task_plan.md"
  [ -f "$HOOK" ] || { ok=0; reason="${reason:+$reason; }hook missing"; }
  # 先把 C 重置为 mini + 清新键，验证宿主端「单行 JSON」语义（F9）：解析出活跃计划并升档
  python3 "$PLANCTL" set --plan-dir "$pC" --field plan_tier --value mini >/dev/null 2>&1
  rm -f "$root/plans/.tier_state/fxh_fx-s3.state"
  hookout=$(printf '%s' '{"session_id":"fxh","cwd":"'"$root"'"}' | OPENCODE_SKILL_ROOT="$SKILL_ROOT" bash "$HOOK" 2>/dev/null)
  [ "$(printf '%s\n' "$hookout" | grep -c .)" -eq 1 ] || { ok=0; reason="${reason:+$reason; }hook lines=$(printf '%s\n' "$hookout" | grep -c .)!=1"; }
  echo "$hookout" | grep -q '已运行' || { ok=0; reason="${reason:+$reason; }hook no tier emit"; }
  [ "$(tier_of "$pC")" = "standard" ] || { ok=0; reason="${reason:+$reason; }hook tier=$(tier_of "$pC")"; }
  if [ "$ok" = 1 ]; then pass T8; else fail T8 "$reason"; fi
}

for t in run_t1 run_t2 run_t3 run_t4 run_t5 run_t6 run_t7 run_t8; do TOTAL=$((TOTAL + 1)); $t || true; done
echo "FIXTURES-DONE FAIL=$FAIL TOTAL=$TOTAL"
exit "$FAIL"
