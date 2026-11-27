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
    hit=[x for x in eb if x.get('path')==artifact and x.get('sha256')==expected]
    if not hit:
        print('[evidence-binding] rc1: no current-version binding for %s'%artifact,file=sys.stderr)
        sys.exit(1)
    print('[evidence-binding] OK: %s bound to %s'%(artifact,expected[:12]))
except Exception as e:
    print('[evidence-binding] rc1: %s'%e,file=sys.stderr); sys.exit(1)
PY
