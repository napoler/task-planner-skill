#!/usr/bin/env bash
# selftest-evidence-binding — evidence_binding schema 接受 + 当前 hash 放行 / 旧 hash 拒绝 / mutation 判别
set -uo pipefail
PASS=0; FAIL=0; SKIP=0
ok(){ PASS=$((PASS+1)); echo "PASS $1"; }
bad(){ FAIL=$((FAIL+1)); echo "FAIL $1"; }
skip(){ SKIP=$((SKIP+1)); echo "SKIP $1"; }
# TC-01: schema 接受合法 evidence_binding
# 2026-11-27 修正：brief 骨架原夹具只有 schema_version/evidence_binding，缺 13 个 required 顶层键必 FAIL；
# 保留原断言目标，补全最小合法 plan-state 以验证字段注册本身。
# 2026-11-27 (Task 2 Minor)：jsonschema 不可用时显式 SKIP，禁止静默算 PASS。
TC01_RC=0
python3 - <<'PY' || TC01_RC=$?
import json,sys
try:
    import jsonschema
except ImportError:
    print('[selftest-evidence-binding] jsonschema unavailable -> TC-01 SKIP', file=sys.stderr)
    sys.exit(77)
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
PY
if [ "$TC01_RC" -eq 0 ]; then ok TC-01; elif [ "$TC01_RC" -eq 77 ]; then skip TC-01; else bad TC-01; fi
# TC-02 正例: 当前 hash 绑定 → PASS
D=$(mktemp -d); trap 'rm -rf "$D"' EXIT
printf '{"schema_version":1,"evidence_binding":[{"path":"a.md","sha256":"%s","version":"v1","recorded_at":"2026-11-27T00:00:00Z"}]}' "$(printf 'a%.0s' {1..64})" > "$D/plan-state.json"
bash skills/task-planner/scripts/check-evidence-binding.sh "$D" a.md "$(printf 'a%.0s' {1..64})" >/dev/null 2>&1 && ok TC-02 || bad TC-02
# TC-03 负控制: 旧 hash → 必须 rc1
# 2026-11-27 fix: 原 `&& bad || ok` 只判「非零」，门返回 rc2(参数错) 或 rc127(脚本缺失)
# 同样会被计为 ok 假 PASS；改为显式断言 rc==1，仅「绑定过期」才通过负控制。
bash skills/task-planner/scripts/check-evidence-binding.sh "$D" a.md "$(printf 'b%.0s' {1..64})" >/dev/null 2>&1
rc=$?
if [ "$rc" -eq 1 ]; then ok TC-03; else bad TC-03; fi
# TC-04 mutation: 删字段 → 必须 rc1（同一假 PASS 根因，同样显式断言 rc==1）
printf '{"schema_version":1}' > "$D/plan-state.json"
bash skills/task-planner/scripts/check-evidence-binding.sh "$D" a.md "$(printf 'a%.0s' {1..64})" >/dev/null 2>&1
rc=$?
if [ "$rc" -eq 1 ]; then ok TC-04; else bad TC-04; fi
# TC-05 判别性对照（2026-11-27 终审 P0）：同 path 两条绑定（旧 hash v1 / 新 hash v2）并存时，
# 旧 hash 必须 rc1、新 hash 必须 rc0。Why：TC-02/TC-03 只有单条绑定，无法暴露
# 「任意命中同 path+sha256 即放行」的旧 hash 放行缺陷；version/recorded_at 此前零消费。
# What：显式断言每个调用的 rc，不用 &&/|| 吞码。
OLD_HASH="$(printf 'a%.0s' {1..64})"
NEW_HASH="$(printf 'b%.0s' {1..64})"
printf '{"schema_version":1,"evidence_binding":[{"path":"a.md","sha256":"%s","version":"v1","recorded_at":"2026-11-27T00:00:00Z"},{"path":"a.md","sha256":"%s","version":"v2","recorded_at":"2026-11-27T01:00:00Z"}]}' "$OLD_HASH" "$NEW_HASH" > "$D/plan-state.json"
bash skills/task-planner/scripts/check-evidence-binding.sh "$D" a.md "$OLD_HASH" >/dev/null 2>&1
rc=$?
if [ "$rc" -eq 1 ]; then ok TC-05; else bad TC-05; fi
bash skills/task-planner/scripts/check-evidence-binding.sh "$D" a.md "$NEW_HASH" >/dev/null 2>&1
rc=$?
if [ "$rc" -eq 0 ]; then ok TC-05b; else bad TC-05b; fi
echo "[selftest-evidence-binding] Total: PASS=$PASS FAIL=$FAIL SKIP=$SKIP"
[ "$FAIL" -eq 0 ] || exit 1
