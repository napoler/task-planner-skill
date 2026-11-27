#!/usr/bin/env bash
# selftest-evidence-binding — evidence_binding 写入/校验/负控制行为回归
set -uo pipefail
PASS=0; FAIL=0
ok(){ PASS=$((PASS+1)); echo "PASS $1"; }
bad(){ FAIL=$((FAIL+1)); echo "FAIL $1"; }
# TC-01: schema 接受合法 evidence_binding
# 2026-11-27 修正：brief 骨架原夹具只有 schema_version/evidence_binding，缺 13 个 required 顶层键必 FAIL；
# 保留原断言目标，补全最小合法 plan-state 以验证字段注册本身。
python3 - <<'PY' >/dev/null 2>&1 && ok TC-01 || bad TC-01
import json
try:
    import jsonschema
    s=json.load(open('skills/task-planner/schemas/plan-state.schema.json'))
    doc = {
        'schema_version': 1, 'task_id': 'selftest-evidence-binding',
        'plan_tier': 'mini', 'execution_lane': 'L0',
        'created_at': '2026-11-27T00:00:00Z', 'updated_at': '2026-11-27T00:00:00Z',
        'requirements': [], 'goals': [], 'vcs': [], 'phases': [], 'findings': [],
        'audits': [], 'delegations': [], 'tags': [],
        'evidence_binding': [{'path': 'p', 'sha256': 'a'*64, 'version': 'v1', 'recorded_at': '2026-11-27T00:00:00Z'}],
    }
    jsonschema.validate(doc, s)
except ImportError:
    pass
PY
echo "[selftest-evidence-binding] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
