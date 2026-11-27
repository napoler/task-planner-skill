#!/usr/bin/env bash
# check-evidence-binding — VC 引用的证据必须绑定当前版本（旧 hash 不得推进）
# 用法: check-evidence-binding.sh <plan-dir> <artifact-path> <expected-sha256>
# rc0=绑定有效; rc1=缺失/过期; rc2=参数错
set -uo pipefail
PLAN_DIR="${1:-}"; ARTIFACT="${2:-}"; EXPECTED="${3:-}"
[ -n "$PLAN_DIR" ] && [ -n "$ARTIFACT" ] && [ -n "$EXPECTED" ] || { echo "[evidence-binding] rc2: missing args" >&2; exit 2; }
STATE="$PLAN_DIR/plan-state.json"
[ -f "$STATE" ] || { echo "[evidence-binding] rc1: no plan-state.json" >&2; exit 1; }
python3 - "$STATE" "$ARTIFACT" "$EXPECTED" <<'PY'
import json,sys
state,artifact,expected=sys.argv[1:4]
try:
    d=json.load(open(state))
    eb=d.get('evidence_binding') or []
    same=[x for x in eb if isinstance(x,dict) and str(x.get('path',''))==artifact]
    if not same:
        print('[evidence-binding] rc1: no current-version binding for %s'%artifact,file=sys.stderr)
        sys.exit(1)
    # Why（2026-11-27 终审 P0）：原实现按 (path, sha256) 任意命中即放行；同一 path 下 v1 旧 hash
    # 与 v2 新 hash 并存时传旧 hash 仍 rc0，违背 spec §5 Phase1「旧哈希只审计不得推进」。
    # version 字段此前全仓零消费。What：同 path 条目按 recorded_at 选当前（并列按 version 取靠后者），
    # 仅当前条目的 sha256 等于 expected 才 rc0；旧条目一律 rc1。
    # 结构异常沿用既有 rc1 契约（selftest TC-04 / review C4 显式断言 rc1），参数缺失仍为 rc2。
    def current_key(x):
        return (str(x.get('recorded_at') or ''),str(x.get('version') or ''))
    current=same[0]
    for x in same[1:]:
        if current_key(x)>current_key(current): current=x
    if current.get('sha256')!=expected:
        print('[evidence-binding] rc1: stale or no current-version binding for %s'%artifact,file=sys.stderr)
        sys.exit(1)
    print('[evidence-binding] OK: %s bound to %s'%(artifact,expected[:12]))
except Exception as e:
    print('[evidence-binding] rc1: %s'%e,file=sys.stderr); sys.exit(1)
PY
