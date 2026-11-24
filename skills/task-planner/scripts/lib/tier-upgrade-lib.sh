#!/usr/bin/env bash
# tier-upgrade-lib.sh — mini→standard 升级链共享库（单一事实源）
# [task-tier-deadzone-fix-20261125]（R1 初版）/ [R2 返工 2026-11-25]
# What: 将 tier 升级链从 zcode-posttooluse.sh 抽为共享库，供 zcode hook（JSON additionalContext 宿主）与
#       非 zcode 通用检查脚本 tier-upgrade-check.sh（plain text 宿主）共用；单一事实源，禁双份逻辑。
# Why: 三死角修复——#1 跨工具（claude/cursor/opencode PostToolUse 无 tier 逻辑，计划永留 mini）；
#      #2 幂等粒度（旧 state 按 sid 单键 → 同会话第二个 mini 永不升级）改为 <sid>_<taskkey>.state；
#      #3 半升级静默（旧链 set/add/render/mkdir/mv 每步 || return 0 无痕）改为 state-first + repair 分支
#      + tier_emit FAIL 显性曝光（fail-open 不阻塞）；#5 完结守卫对象兼容（outcome 可为对象 {result:...}）。
# 不变语义：mini ∧（>15min ∧ 步骤门[phase complete ∨ findings/research 落盘 ∨ delegations 非空] ∨ >45min 硬兜底）
#   → set standard + TU-1 + render + stale 锁删除 + state + tier_emit；emit 文案保持原文（提案 #11 待批不动）。
# fail-open 哲学：缺依赖/步骤失败 → 曝光 FAIL + return 0，不阻塞工具调用；但**禁止假成功**（见 R2 ①）。
# init-standard 不归本链管：无 state 且 tier 非 mini → return 0，禁对 init 即 standard 的计划伪造 TU-1。
# 宿主契约：可预定义 tier_emit() 覆盖默认输出；升级成功设 TIER_UPGRADED=1；本轮有 tier 文案时 TIER_EMITTED=1
#   （宿主据此 exit 0 守 F9 单轮单 JSON）；一轮至多调用 tier_emit 一次（出口 tier_flush 统一发）。
#
# [R2 返工 2026-11-25] 按 critic R1 复检结论（1 CRITICAL + 3 IMPORTANT 实测复现）修四类缺陷：
# ① 【F1/C-1】repair 分支三条件门：仅 [tier==standard] ∧ [render rc=0] ∧ [TU-1 在位] 才删旧锁 +
#    写 upgraded=1 + 发「半升级自愈完成」；否则保持 upgrading=1（下轮续跑）、只发 FAIL。
#    原实现三步全 FAIL 仍写 upgraded=1 + 发成功文案 → 次轮静默永久 mini（#3 在 repair 分支复活）。
#    fresh 分支同理加「set 后档位回读」门：rc=0 但未真正落盘也不得发成功文案。
# ② 【F2】repair 入口收紧：仅 '^upgrading=1' 才进 repair；state 存在但既不 upgraded 也不 upgrading
#    （空文件/坏行/未知内容）→ rm -f 视为脏键，回落 fresh 判定（init-standard 依旧静默）。
#    原实现任何非 upgraded=1 内容都进 repair → 空 state + standard 计划伪造 TU-1 并谎报「自愈完成」（实测）。
# ③ 【F3】消息全部经 tier_note 入 TIER_MSGS 缓冲，tier_upgrade_check 尾部唯一出口 tier_flush 一次性 emit；
#    原实现 repair 三分支 + 成功文案各 emit 一次 → zcode 宿主单轮 4 行 JSON（违反自身 F9 约束，实测）。
# ④ 【F4】state 写恢复 tmp+mv 原子写（旧链「防并发半写」范式，R1 曾被降级为直接 `>`）；planctl 缺失
#    改为 FAIL 曝光（与 jq/python3 口径一致，原为静默 return 0）；$p 形参由悬空改为 plan-dir 兜底来源。

declare -F tier_emit >/dev/null 2>&1 || tier_emit() { printf '%s\n' "$1"; }

# 消息缓冲：累加所有待发文案（多行以换行连接），由 tier_flush 一次性交给 tier_emit。
# 为什么缓冲而不是直发：宿主对 hook stdout 做严格 JSON 校验（F9 单轮单 JSON），
# 一次 emit 内嵌 \n 合法，多次 emit 多行非法——缓冲是唯一能保证「任意路径至多一次」的形态。
TIER_MSGS=""
TIER_EMITTED=0

tier_note() {
  if [ -z "${TIER_MSGS:-}" ]; then
    TIER_MSGS="$1"
  else
    TIER_MSGS="${TIER_MSGS}
$1"
  fi
  return 0
}

# 唯一出口：非空才 emit 一次，并置 TIER_EMITTED 供宿主判定（空缓冲=本轮静默）
tier_flush() {
  if [ -n "${TIER_MSGS:-}" ]; then
    tier_emit "$TIER_MSGS"
    TIER_EMITTED=1
    TIER_MSGS=""
  fi
  return 0
}

# state 原子写（tmp+mv）：崩溃/并发半写不会留下半行被 repair 误读；失败返回 1 由调用方决定文案
tier_write_state() {
  local target="$1" content="$2" tmp
  [ -n "$target" ] || return 1
  mkdir -p "$(dirname "$target")" 2>/dev/null || return 1
  tmp="${target}.tmp.$$"
  printf '%s\n' "$content" > "$tmp" 2>/dev/null || { rm -f "$tmp" 2>/dev/null || true; return 1; }
  mv -f "$tmp" "$target" 2>/dev/null || { rm -f "$tmp" 2>/dev/null || true; return 1; }
  return 0
}

# 公共入口：清缓冲 → 主体 → 唯一出口 flush。任何 return 路径都经过 flush（单轮单 emit 由结构保证）。
tier_upgrade_check() {
  TIER_MSGS=""
  TIER_EMITTED=0
  _tier_upgrade_body "$@"
  tier_flush
  return 0
}

_tier_upgrade_body() {
  local p="${1:-}" sid="${2:-default}" pdir="${3:-}" plans_root="${4:-}"
  # [R2/F4] $p 原为悬空形参（全函数未使用）→ 现作 plan-dir 兜底来源；4 参调用方零破坏
  if [ -z "$pdir" ] && [ -n "$p" ]; then pdir="$(dirname "$p")"; fi
  if [ -z "$plans_root" ] && [ -n "$pdir" ]; then plans_root="$(dirname "$pdir")"; fi
  [ -n "$pdir" ] && [ -n "$plans_root" ] || return 0

  local script_dir_tu planctl
  script_dir_tu="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" 2>/dev/null || return 0
  planctl="$script_dir_tu/../planctl.py"
  if [ ! -f "$planctl" ]; then
    # [R2/F4] 原静默 return 0（坏安装=死角静音）；与 jq/python3 缺失同口径曝光
    tier_note "[tier-upgrade] FAIL: planctl.py 缺失（$planctl），升级链不可用（曝光不阻塞）"
    return 0
  fi
  [ -f "$pdir/plan-state.json" ] || return 0
  if ! command -v jq >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1; then
    tier_note "[tier-upgrade] FAIL: jq|python3 缺失，升级链不可用（曝光不阻塞）"
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
    if grep -q '^upgrading=1' "$sfile" 2>/dev/null; then
      # repair 分支（仅 upgrading=1 中断态）：续跑剩余步骤，三条件门全过才判自愈完成
      local tu1_ok=1 render_rc=0
      if [ "$tier" != "standard" ]; then
        python3 "$planctl" set --plan-dir "$pdir" --field plan_tier --value standard >/dev/null 2>&1 \
          || tier_note "[tier-upgrade] FAIL: set plan_tier（保持 upgrading=1，下轮自动补偿）"
        # set 后回读真实档位：rc=0 不等于已落盘（并发改写/写盘失败都可能让 rc 与盘面不一致）
        tier="$(jq -r '.plan_tier // ""' "$pdir/plan-state.json" 2>/dev/null || true)"
      fi
      if ! jq -e '.decisions[]? | select(.id=="TU-1")' "$pdir/plan-state.json" >/dev/null 2>&1; then
        local repair_decision
        repair_decision="[tier-upgrade] 半升级自愈：补登记 TU-1（上轮升级链中断续接）"
        python3 "$planctl" add --plan-dir "$pdir" --section decisions --json \
          "{\"id\":\"TU-1\",\"decision\":\"${repair_decision}\",\"rationale\":\"task-tier-deadzone-fix-20261125: state-first repair\"}" >/dev/null 2>&1 \
          || tier_note "[tier-upgrade] FAIL: add TU-1（保持 upgrading=1，下轮自动补偿）"
      fi
      # 以盘面实际状态为准（add 报错但条目已在位、或 add 成功但落盘丢失，都以此判定）
      jq -e '.decisions[]? | select(.id=="TU-1")' "$pdir/plan-state.json" >/dev/null 2>&1 || tu1_ok=0
      python3 "$planctl" render --plan-dir "$pdir" >/dev/null 2>&1 \
        || { tier_note "[tier-upgrade] FAIL: render（保持 upgrading=1，下轮自动补偿）"; render_rc=1; }

      # [R2/F1] 三条件门：档位已 standard ∧ render 成功 ∧ TU-1 在位 → 才算自愈完成
      if [ "$tier" = "standard" ] && [ "$render_rc" = 0 ] && [ "$tu1_ok" = 1 ]; then
        rm -f "$pdir/.plan-attestation"
        if tier_write_state "$sfile" "upgraded=1 upgraded_at=${now_iso}"; then
          tier_note "[tier-upgrade] ⏫ 半升级自愈完成：TU-1/render/旧锁清理已补全（上轮升级链中断续接）→ standard 检查面恢复，后续按标准档执行"
          TIER_UPGRADED=1
        else
          tier_note "[tier-upgrade] FAIL: state 落盘失败（保持 upgrading=1，下轮自动补偿）"
        fi
      else
        # 禁发成功文案：明确保持中断态，避免「假自愈」把计划永久钉在 mini
        tier_note "[tier-upgrade] FAIL: 半升级自愈未完成（tier=${tier:-?} render_rc=${render_rc} tu1_ok=${tu1_ok}）— 保持 upgrading=1，下轮续跑，计划仍按当前档位执行"
      fi
      return 0
    fi
    # [R2/F2] 脏键（空文件/坏行/未知内容）：既非 upgraded 也非 upgrading → 清掉按无 state 重新判定。
    # 为什么删而不是当 repair 跑：没有「升级已开始」的证据，repair 会凭空补 TU-1（R1 实测伪造）。
    rm -f "$sfile" 2>/dev/null || true
  fi

  # state 不存在（或脏键已清）
  [ "$tier" = "mini" ] || return 0   # init-standard / 已是 standard 不归本链管

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
  tier_write_state "$sfile" "upgrading=1 upgraded_at=${now_iso}" || return 0

  python3 "$planctl" set --plan-dir "$pdir" --field plan_tier --value standard >/dev/null 2>&1 \
    || { tier_note "[tier-upgrade] FAIL: set plan_tier（保持 upgrading=1，下轮自动补偿）"; return 0; }

  if ! jq -e '.decisions[]? | select(.id=="TU-1")' "$pdir/plan-state.json" >/dev/null 2>&1; then
    local decision
    decision="[tier-upgrade] 运行 ${elapsed} 分钟，触发原因：${reason}（软阈值 ${threshold}min / 硬阈值 ${hard}min），自动升级 standard 检查面"
    python3 "$planctl" add --plan-dir "$pdir" --section decisions --json \
      "{\"id\":\"TU-1\",\"decision\":\"${decision}\",\"rationale\":\"用户 2026-11-24/25 裁决：软阈值15min须联合步骤门(phase complete/findings/delegations) 或 硬阈值45min兜底，零主观判断\"}" >/dev/null 2>&1 \
      || { tier_note "[tier-upgrade] FAIL: add TU-1（保持 upgrading=1，下轮自动补偿）"; return 0; }
  fi

  python3 "$planctl" render --plan-dir "$pdir" >/dev/null 2>&1 \
    || { tier_note "[tier-upgrade] FAIL: render（保持 upgrading=1，下轮自动补偿）"; return 0; }

  # [R2/F1] 成功前回读真实档位（rc=0 ≠ 已落盘），不满足则保持中断态、不发成功文案
  local tier_now
  tier_now="$(jq -r '.plan_tier // ""' "$pdir/plan-state.json" 2>/dev/null || true)"
  if [ "$tier_now" != "standard" ]; then
    tier_note "[tier-upgrade] FAIL: set 后档位回读=${tier_now:-?}（期望 standard）— 保持 upgrading=1，下轮自动补偿"
    return 0
  fi

  # stale 锁处理：mini 形态旧锁留存会在 attest --verify 误报 TAMPERED；TU-1 已登记机制变更
  rm -f "$pdir/.plan-attestation"
  tier_write_state "$sfile" "upgraded=1 upgraded_at=${now_iso}" \
    || { tier_note "[tier-upgrade] FAIL: state 落盘失败（保持 upgrading=1，下轮自动补偿）"; return 0; }

  tier_note "[tier-upgrade] ⏫ 本计划已运行 ${elapsed} 分钟，触发原因：${reason}（软阈值 ${threshold}min 须联合步骤门 / 硬阈值 ${hard}min 兜底；TASK_PLANNER_TIER_UPGRADE_MINUTES 与 TASK_PLANNER_TIER_UPGRADE_HARD_MINUTES 可调）→ 已自动升级 standard 检查面：委派门 floor 恢复 0.7、审计门按 L1 强制、VC 阈值恢复 standard、G4-G11 不再豁免、收尾回读恢复全量六文档。后续按标准档执行，无需重写计划文档。"
  TIER_UPGRADED=1
  return 0
}
