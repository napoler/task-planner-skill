#!/usr/bin/env bash
# tier-upgrade-lib.sh — mini→standard 升级链共享库（单一事实源）
# [task-tier-deadzone-fix-20261125]
# What: 将 tier 升级链从 zcode-posttooluse.sh 抽为共享库，供 zcode hook（JSON additionalContext 宿主）与
#       非 zcode 通用检查脚本 tier-upgrade-check.sh（plain text 宿主）共用；单一事实源，禁双份逻辑。
# Why: 三死角修复——#1 跨工具（claude/cursor/opencode PostToolUse 无 tier 逻辑，计划永留 mini）；
#      #2 幂等粒度（旧 state 按 sid 单键 → 同会话第二个 mini 永不升级）改为 <sid>_<taskkey>.state；
#      #3 半升级静默（旧链 set/add/render/mkdir/mv 每步 || return 0 无痕）改为 state-first + repair 分支
#      + tier_emit FAIL 显性曝光（fail-open 不阻塞）；#5 完结守卫对象兼容（outcome 可为对象 {result:...}）。
# 不变语义：mini ∧（>15min ∧ 步骤门[phase complete ∨ findings/research 落盘 ∨ delegations 非空] ∨ >45min 硬兜底）
#   → set standard + TU-1 + render + stale 锁删除 + state + tier_emit；emit 文案保持原文（提案 #11 待批不动）。
# fail-open 哲学升级：缺依赖/步骤失败 → tier_emit "[tier-upgrade] FAIL ..." 曝光 + return 0，不阻塞工具调用。
# init-standard 不归本链管：state 无 upgrading 标记且 tier 非 mini → return 0，禁对 init 即 standard 的计划伪造 TU-1。
# 宿主契约：可预定义 tier_emit() 覆盖默认输出；升级成功设 TIER_UPGRADED=1 供宿主决定是否 exit 0（F9 单轮单 JSON）。

declare -F tier_emit >/dev/null 2>&1 || tier_emit() { printf '%s\n' "$1"; }

tier_upgrade_check() {
  local p="$1" sid="${2:-default}" pdir="$3" plans_root="$4"
  [ -n "$pdir" ] && [ -n "$plans_root" ] || return 0
  local script_dir_tu planctl
  script_dir_tu="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" 2>/dev/null || return 0
  planctl="$script_dir_tu/../planctl.py"
  [ -f "$planctl" ] || return 0
  [ -f "$pdir/plan-state.json" ] || return 0
  if ! command -v jq >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1; then
    tier_emit "[tier-upgrade] FAIL: jq|python3 缺失，升级链不可用（曝光不阻塞）"
    return 0
  fi

  local task_id taskkey sfile
  task_id="$(jq -r '.task_id // ""' "$pdir/plan-state.json" 2>/dev/null || true)"
  [ -n "$task_id" ] && [ "$task_id" != "null" ] || task_id="$(basename "$pdir")"
  taskkey="$(printf '%s' "$task_id" | tr -cd 'a-zA-Z0-9_-')"
  [ -n "$taskkey" ] || taskkey="plan"
  sfile="$plans_root/.tier_state/${sid}_${taskkey}.state"

  # #5 完结守卫对象兼容：outcome 可能是字符串或对象 {result:...}
  jq -e '(.outcome // "") | (if type == "object" then (.result // "") else . end) | test("^(COMPLETE|BLOCKED)$")' \
    "$pdir/plan-state.json" >/dev/null 2>&1 && return 0

  local tier now_iso
  tier="$(jq -r '.plan_tier // ""' "$pdir/plan-state.json" 2>/dev/null || true)"
  now_iso="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  # 幂等/自愈路由
  if [ -f "$sfile" ]; then
    if grep -q '^upgraded=1' "$sfile" 2>/dev/null; then
      return 0
    fi
    # repair 分支：state 存在且非 upgraded=1（upgrading=1 中断标记）→ 续跑剩余步骤
    if [ "$tier" = "mini" ]; then
      python3 "$planctl" set --plan-dir "$pdir" --field plan_tier --value standard >/dev/null 2>&1 \
        || tier_emit "[tier-upgrade] FAIL: set plan_tier（下轮自动补偿）"
    fi
    if ! jq -e '.decisions[]? | select(.id=="TU-1")' "$pdir/plan-state.json" >/dev/null 2>&1; then
      local repair_decision
      repair_decision="[tier-upgrade] 半升级自愈：补登记 TU-1（上轮升级链中断续接）"
      python3 "$planctl" add --plan-dir "$pdir" --section decisions --json \
        "{\"id\":\"TU-1\",\"decision\":\"${repair_decision}\",\"rationale\":\"task-tier-deadzone-fix-20261125: state-first repair\"}" >/dev/null 2>&1 \
        || tier_emit "[tier-upgrade] FAIL: add TU-1（下轮自动补偿）"
    fi
    python3 "$planctl" render --plan-dir "$pdir" >/dev/null 2>&1 \
      || tier_emit "[tier-upgrade] FAIL: render（下轮自动补偿）"
    rm -f "$pdir/.plan-attestation"
    printf 'upgraded=1 upgraded_at=%s\n' "$now_iso" > "$sfile" 2>/dev/null || true
    tier_emit "[tier-upgrade] ⏫ 半升级自愈完成：TU-1/render/旧锁清理已补全（上轮升级链中断续接）→ standard 检查面恢复，后续按标准档执行"
    TIER_UPGRADED=1
    return 0
  fi

  # state 不存在
  [ "$tier" = "mini" ] || return 0   # init-standard 不归本链管

  # 双判据
  local threshold hard elapsed gate_signal reason
  threshold="${TASK_PLANNER_TIER_UPGRADE_MINUTES:-15}"
  case "$threshold" in ''|*[!0-9]*|0) threshold=15 ;; esac
  hard="${TASK_PLANNER_TIER_UPGRADE_HARD_MINUTES:-45}"
  case "$hard" in ''|*[!0-9]*|0) hard=45 ;; esac
  elapsed="$(python3 - "$pdir/plan-state.json" <<'PY' 2>/dev/null || true
import json, sys
from datetime import datetime, timezone
try:
    with open(sys.argv[1], encoding="utf-8") as f:
        created = json.load(f).get("created_at", "")
    dt = datetime.fromisoformat(created.replace("Z", "+00:00"))
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    print(int((datetime.now(timezone.utc) - dt).total_seconds() // 60))
except Exception:
    pass
PY
)"
  case "$elapsed" in ''|*[!0-9]*) return 0 ;; esac

  gate_signal=""
  if [ "$elapsed" -gt "$threshold" ]; then
    gate_signal="$(jq -r '
      if ([.phases[]? | select(.status == "complete")] | length) > 0 then "phase:complete"
      elif (((.findings // []) | length > 0) or ((.research // []) | length > 0)) then "findings/research"
      elif ((.delegations // []) | length) > 0 then "delegations"
      else "" end
    ' "$pdir/plan-state.json" 2>/dev/null || true)"
    case "$gate_signal" in ''|null|'null') gate_signal="" ;; esac
  fi
  reason=""
  [ -n "$gate_signal" ] && reason="步骤门：${gate_signal}"
  if [ -z "$reason" ] && [ "$elapsed" -gt "$hard" ]; then
    reason="硬阈值兜底"
  fi
  [ -n "$reason" ] || return 0   # 双判据均未命中 → 静默；幂等 state 只在真升档时写

  # fresh 升级链（state-first）：先落 upgrading 标记再动计划，中断可由 repair 续
  mkdir -p "$plans_root/.tier_state" 2>/dev/null || return 0
  printf 'upgrading=1 upgraded_at=%s\n' "$now_iso" > "$sfile" 2>/dev/null || return 0

  python3 "$planctl" set --plan-dir "$pdir" --field plan_tier --value standard >/dev/null 2>&1 \
    || { tier_emit "[tier-upgrade] FAIL: set plan_tier（下轮自动补偿）"; return 0; }

  if ! jq -e '.decisions[]? | select(.id=="TU-1")' "$pdir/plan-state.json" >/dev/null 2>&1; then
    local decision
    decision="[tier-upgrade] 运行 ${elapsed} 分钟，触发原因：${reason}（软阈值 ${threshold}min / 硬阈值 ${hard}min），自动升级 standard 检查面"
    python3 "$planctl" add --plan-dir "$pdir" --section decisions --json \
      "{\"id\":\"TU-1\",\"decision\":\"${decision}\",\"rationale\":\"用户 2026-11-24/25 裁决：软阈值15min须联合步骤门(phase complete/findings/delegations) 或 硬阈值45min兜底，零主观判断\"}" >/dev/null 2>&1 \
      || { tier_emit "[tier-upgrade] FAIL: add TU-1（下轮自动补偿）"; return 0; }
  fi

  python3 "$planctl" render --plan-dir "$pdir" >/dev/null 2>&1 \
    || { tier_emit "[tier-upgrade] FAIL: render（下轮自动补偿）"; return 0; }

  # stale 锁处理：mini 形态旧锁留存会在 attest --verify 误报 TAMPERED；TU-1 已登记机制变更
  rm -f "$pdir/.plan-attestation"
  printf 'upgraded=1 upgraded_at=%s\n' "$now_iso" > "$sfile" 2>/dev/null || true

  tier_emit "[tier-upgrade] ⏫ 本计划已运行 ${elapsed} 分钟，触发原因：${reason}（软阈值 ${threshold}min 须联合步骤门 / 硬阈值 ${hard}min 兜底；TASK_PLANNER_TIER_UPGRADE_MINUTES 与 TASK_PLANNER_TIER_UPGRADE_HARD_MINUTES 可调）→ 已自动升级 standard 检查面：委派门 floor 恢复 0.7、审计门按 L1 强制、VC 阈值恢复 standard、G4-G11 不再豁免、收尾回读恢复全量六文档。后续按标准档执行，无需重写计划文档。"
  TIER_UPGRADED=1
  return 0
}
