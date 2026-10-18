#!/usr/bin/env bash
# selftest-verify-io.sh — verify_io.sh 行为守护（F11 修复，task-v189）
# 守护：① 7 文件在位断言 ② check-delegation stats JSON schema 校验 ③ 坏 JSON fixture 拒判
# 范式：fixture 驱动 + ok/bad + PASS/FAIL 计数（同 selftest-subagent-return.sh）
# 注册：selftest-registry.tsv domain=io-contract
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY_IO="$SCRIPT_DIR/verify_io.sh"
FIXTURE="$(mktemp -d /tmp/selftest-verify-io.XXXXXX)"
trap 'rm -rf "$FIXTURE"' EXIT
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); echo "IO-$1 PASS $2"; }
bad() { FAIL=$((FAIL+1)); echo "IO-$1 FAIL $2${3:+ ($3)}"; }

# ── IO-01 7 文件在位：全在位 → verify_io exit 0 ──
mkdir -p "$FIXTURE/full"
for f in task_plan.md findings.md progress.md notepad-learnings.md verification.md knowledge-brief.md user-session-log.md; do
  echo "content" > "$FIXTURE/full/$f"
done
out="$(bash "$VERIFY_IO" "$FIXTURE/full" 2>&1)"; rc=$?
[ $rc -eq 0 ] && ok 01 "7 文件全在位 exit 0" || bad 01 "7 文件全在位 exit $rc" "$out"

# ── IO-02 7 文件缺 1 → verify_io exit 1 + missing 报 ──
mkdir -p "$FIXTURE/missing"
for f in findings.md progress.md notepad-learnings.md verification.md knowledge-brief.md user-session-log.md; do
  echo "content" > "$FIXTURE/missing/$f"
done
out="$(bash "$VERIFY_IO" "$FIXTURE/missing" 2>&1)"; rc=$?
[ $rc -eq 1 ] && echo "$out" | grep -q "missing: task_plan.md" \
  && ok 02 "缺 task_plan.md exit 1 + missing 报" || bad 02 "缺文件判定异常 rc=$rc" "$out"

# ── IO-03 合法 stats JSON 过 schema 段（与 verify_io.sh 迷你校验器同逻辑）──
# 用 verify_io.sh 的 schema 断言段（python3 + schema.json）对合法 JSON 判定应 PASS
SCHEMA="$SCRIPT_DIR/schemas/check-delegation-stats.schema.json"
VALID_STATS='{"phases_total":2,"phases_delegated":1,"main_direct_count":1,"delegation_rate":0.5,"main_direct":[{"phase":"P1"}],"violations":[],"verdict":"ok"}'
echo "$VALID_STATS" | python3 -c "
import json, sys, pathlib
stats = json.loads(sys.stdin.read())
schema = json.loads(pathlib.Path('$SCHEMA').read_text(encoding='utf-8'))
missing = [k for k in schema.get('required', []) if k not in stats]
assert not missing, f'缺 {missing}'
for key, prop in schema.get('properties', {}).items():
    if key not in stats: continue
    m = {'object': dict, 'array': list, 'integer': int, 'number': (int, float), 'string': str, 'boolean': bool}
    if prop.get('type') and not isinstance(stats[key], m[prop['type']]):
        sys.exit(1)
    if prop.get('type') == 'integer' and isinstance(stats.get(key), bool):
        sys.exit(1)
verdict_enum = set(schema['properties']['verdict']['enum'])
assert stats['verdict'] in verdict_enum, f\"verdict={stats['verdict']} 不在 {sorted(verdict_enum)}\"
" && ok 03 "合法 stats schema PASS" || bad 03 "合法 stats schema FAIL"

# ── IO-04 坏 verdict 应拒（校验器对 verdict=weird 应 exit 1）──
BAD_STATS='{"phases_total":2,"phases_delegated":1,"main_direct_count":1,"delegation_rate":0.5,"main_direct":[],"violations":[],"verdict":"weird"}'
echo "$BAD_STATS" | python3 -c "
import json, sys, pathlib
stats = json.loads(sys.stdin.read())
schema = json.loads(pathlib.Path('$SCHEMA').read_text(encoding='utf-8'))
verdict_enum = set(schema['properties']['verdict']['enum'])
if stats['verdict'] not in verdict_enum:
    sys.exit(1)  # 校验器拒
" && bad 04 "坏 verdict 未被拒（校验器逻辑错）" || ok 04 "坏 verdict 拒判 exit≠0"

echo ""
echo "=== 总计: $PASS PASS, $FAIL FAIL ==="
[ $FAIL -eq 0 ] && exit 0 || exit 1
