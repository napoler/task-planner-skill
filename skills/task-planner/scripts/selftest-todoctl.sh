#!/usr/bin/env bash
# selftest-todoctl.sh — Rule 117 跨任务共用待办 CLI 行为回归（fixture + 正反例 + mutation）
#
# What:
#   用法: bash selftest-todoctl.sh（无参，自建 mktemp 沙箱，退出时清理）
#   守护: C1-C6 产出实物审查命令 + 幂等 add + mutation（删 status → check FAIL）
#         + 开放标签负控制（新 source.type 不被拒）+ 备份/原子写副作用 + 可移植性（无硬编码绝对路径）
#   输出: 每例 `TC-N PASS|FAIL <说明>`，末行 `=== TOTAL: PASS=N FAIL=M ===`（runner 按 PASS=/FAIL= 解析）
#   退出码: 0=全过 / 1=任一 FAIL
#
# Why:
#   规则文本与 CLI 若漂移（如 check 放宽、dedup 失效、手改 JSON 可骗过门），用户就无法
#   可靠统计未解决问题。参照 selftest-lazy-refs.sh 的 mutation 判别范式，任一守护点被改坏
#   都必须让门转 FAIL，防止「只写条款不守行为」。
#   [2026-11-26 task-shared-todo-20261126] 新增。

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
CLI="$SCRIPT_DIR/todoctl.py"
EXAMPLE="$REPO_ROOT/examples/shared-todo/todo.example.json"

if [ ! -f "$CLI" ] || [ ! -f "$EXAMPLE" ]; then
  printf 'TC-00 FAIL 前置缺失: CLI=%s EXAMPLE=%s\n' "$CLI" "$EXAMPLE"
  exit 1
fi

FIXTURE="$(mktemp -d /tmp/selftest-todoctl.XXXXXX)"
trap 'rm -rf "$FIXTURE"' EXIT
PASS=0
FAIL=0

ok()  { PASS=$((PASS + 1)); printf 'TC-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL + 1)); printf 'TC-%s FAIL %s\n' "$1" "$2"; }

reset_fixture() {
  cp "$EXAMPLE" "$FIXTURE/todo.json"
  rm -f "$FIXTURE/todo.json.bak"
}

# 从 CLI 的 JSON stdout 中取字段（heredoc，不用 python3 -c）
json_field() {
  python3 - "$1" "$2" <<'PY'
import json, sys
try:
    doc = json.load(open(sys.argv[1], encoding='utf-8'))
    val = doc
    for part in sys.argv[2].split('.'):
        val = val[part]
    if val is None:
        print('')
    else:
        print(val)
except Exception:
    print('')
PY
}

# TC-01/02/03: C1-C3
reset_fixture
if python3 -m json.tool "$FIXTURE/todo.json" >/dev/null 2>&1; then
  ok 01 'C1 示例 JSON 合法'
else
  bad 01 'C1 json.tool 应通过'
fi

out="$(python3 "$CLI" check --root "$FIXTURE" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -qF 'TODOCTL CHECK schema: PASS'; then
  ok 02 'C2 check PASS'
else
  bad 02 "C2 check 异常 rc=$rc out=$out"
fi

out="$(python3 "$CLI" stats --root "$FIXTURE" 2>&1)"
if [ "$out" = 'open=1 in_progress=0 done=1 cancelled=0' ]; then
  ok 03 'C3 stats 四态计数'
else
  bad 03 "C3 stats 异常: $out"
fi

# TC-04/05: C4 add + 幂等
out="$(python3 "$CLI" add --title '新增待办' --source-type scan --root "$FIXTURE" 2>&1)"; rc=$?
printf '%s' "$out" > "$FIXTURE/add.json"
new_id="$(json_field "$FIXTURE/add.json" 'item.id')"
if [ "$rc" -eq 0 ] && [ "$new_id" = 'TODO-0003' ]; then
  ok 04 'C4 add 分配新 id'
else
  bad 04 "C4 add 异常 rc=$rc id=$new_id"
fi

out2="$(python3 "$CLI" add --title '新增待办' --source-type scan --root "$FIXTURE" 2>&1)"
if printf '%s' "$out2" | grep -qF '"status": "dedup"'; then
  ok 05 '同标题未结项幂等返回既有 id'
else
  bad 05 "幂等失败: $out2"
fi

# TC-06: 备份副作用（原子写入前 copy2）
if [ -f "$FIXTURE/todo.json.bak" ]; then
  ok 06 '写入前生成 todo.json.bak 备份'
else
  bad 06 '缺少备份文件'
fi

# TC-07: C5 resolve（保留条目 + 终态字段）
out="$(python3 "$CLI" resolve TODO-0001 --note '已修于 commit xxx' --root "$FIXTURE" 2>&1)"
printf '%s' "$out" > "$FIXTURE/resolve.json"
status="$(json_field "$FIXTURE/resolve.json" 'item.status')"
resolved="$(json_field "$FIXTURE/resolve.json" 'item.resolved_at')"
if [ "$status" = 'done' ] && [ -n "$resolved" ]; then
  ok 07 'C5 resolve 置终态且 resolved_at 非空'
else
  bad 07 "C5 resolve 异常 status=$status resolved=$resolved"
fi

# TC-08: reopen 恢复未结
python3 "$CLI" reopen TODO-0001 --root "$FIXTURE" > "$FIXTURE/reopen.json" 2>&1
status="$(json_field "$FIXTURE/reopen.json" 'item.status')"
resolved="$(json_field "$FIXTURE/reopen.json" 'item.resolved_at')"
if [ "$status" = 'open' ] && [ -z "$resolved" ]; then
  ok 08 'reopen 恢复 open 且清空 resolved_at'
else
  bad 08 "reopen 异常 status=$status resolved=$resolved"
fi

# TC-09: C6 负控制——schema_version 改坏 → check FAIL
reset_fixture
python3 - "$FIXTURE/todo.json" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read().replace('"schema_version": 1', '"schema_version": "x"')
open(p, 'w', encoding='utf-8').write(s)
PY
out="$(python3 "$CLI" check --root "$FIXTURE" 2>&1)"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -qF 'TODOCTL CHECK schema: FAIL'; then
  ok 09 'C6 负控制 schema_version 改坏 → FAIL'
else
  bad 09 "C6 负控制未触发 rc=$rc out=$out"
fi

# TC-10: mutation——删除条目 status → check FAIL（判别性守护）
reset_fixture
python3 - "$FIXTURE/todo.json" <<'PY'
import json, sys
p = sys.argv[1]
doc = json.load(open(p, encoding='utf-8'))
del doc['items'][0]['status']
json.dump(doc, open(p, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
PY
out="$(python3 "$CLI" check --root "$FIXTURE" 2>&1)"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -qF 'TODOCTL CHECK schema: FAIL'; then
  ok 10 'mutation 删除 status → check FAIL'
else
  bad 10 "mutation 未触发 rc=$rc out=$out"
fi

# TC-11: 开放标签负控制——自定义 source.type 不被拒（机制零写死）
reset_fixture
out="$(python3 "$CLI" add --title '换项目的新问题' --source-type 'custom-domain-x' --tags 'alpha,beta' --root "$FIXTURE" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && python3 "$CLI" check --root "$FIXTURE" >/dev/null 2>&1; then
  ok 11 '开放 source.type/tags 不被拒'
else
  bad 11 "开放标签被拒 rc=$rc out=$out"
fi

# TC-12: init 在空目录建骨架
EMPTY="$FIXTURE/empty"; mkdir -p "$EMPTY"
out="$(python3 "$CLI" init --root "$EMPTY" 2>&1)"
if printf '%s' "$out" | grep -qF '"status": "created"' && [ -f "$EMPTY/todo.json" ]; then
  ok 12 'init 建空骨架'
else
  bad 12 "init 异常: $out"
fi

# TC-13: 可移植性——脚本无硬编码仓路径
if grep -Eq '/mnt/data|/home/terry' "$CLI"; then
  bad 13 'CLI 含硬编码绝对路径（破坏换项目成立）'
else
  ok 13 'CLI 无硬编码仓路径'
fi

# TC-14: next 选中（priority=high 的 TODO-0001）
FX14="$(mktemp -d "$FIXTURE/fx14.XXXXXX")"
cp "$EXAMPLE" "$FX14/todo.json"
python3 "$CLI" next --root "$FX14" > "$FX14/next.json" 2>&1; rc=$?
n_status="$(json_field "$FX14/next.json" 'status')"
n_id="$(json_field "$FX14/next.json" 'item.id')"
n_reason="$(json_field "$FX14/next.json" 'reason')"
if [ "$rc" -eq 0 ] && [ "$n_status" = 'selected' ] && [ "$n_id" = 'TODO-0001' ] && printf '%s' "$n_reason" | grep -qF 'priority=high'; then
  ok 14 'next 选中 TODO-0001 且 reason 含 priority=high'
else
  bad 14 "next 异常 rc=$rc status=$n_status id=$n_id reason=$n_reason"
fi

# TC-15: next 排除终态后返回 empty
python3 "$CLI" resolve TODO-0001 --note done --root "$FX14" >/dev/null 2>&1
python3 "$CLI" next --root "$FX14" > "$FX14/next2.json" 2>&1; rc=$?
n2_status="$(json_field "$FX14/next2.json" 'status')"
n2_count="$(json_field "$FX14/next2.json" 'count')"
if [ "$rc" -eq 0 ] && [ "$n2_status" = 'empty' ] && [ "$n2_count" = '0' ]; then
  ok 15 'next 排除终态后返回 empty count=0'
else
  bad 15 "next 终态排除异常 rc=$rc status=$n2_status count=$n2_count"
fi

# TC-16: review 陈旧阈值
FX16="$(mktemp -d "$FIXTURE/fx16.XXXXXX")"
cp "$EXAMPLE" "$FX16/todo.json"
python3 "$CLI" review --older-than-days 9999 --root "$FX16" > "$FX16/r1.json" 2>&1; rc1=$?
python3 "$CLI" review --older-than-days 0 --root "$FX16" > "$FX16/r2.json" 2>&1; rc2=$?
stale9999_len="$(python3 - "$FX16/r1.json" <<'PY'
import json, sys
doc = json.load(open(sys.argv[1], encoding='utf-8'))
print(len(doc.get('stale', [])))
PY
)"
stale0_has_t1="$(python3 - "$FX16/r2.json" <<'PY'
import json, sys
doc = json.load(open(sys.argv[1], encoding='utf-8'))
ids = [s.get('id') for s in doc.get('stale', [])]
print('yes' if 'TODO-0001' in ids else 'no')
PY
)"
if [ "$rc1" -eq 0 ] && [ "$rc2" -eq 0 ] && [ "$stale9999_len" = '0' ] && [ "$stale0_has_t1" = 'yes' ]; then
  ok 16 'review 陈旧阈值：9999 空、0 含 TODO-0001'
else
  bad 16 "review 异常 rc1=$rc1 rc2=$rc2 stale9999=$stale9999_len stale0_has_TODO-0001=$stale0_has_t1"
fi

# TC-17: retire 默认 dry-run 零移动
FX17="$(mktemp -d "$FIXTURE/fx17.XXXXXX")"
cp "$EXAMPLE" "$FX17/todo.json"
mkdir -p "$FX17/plans/task-demo-retire-20261126"
cat > "$FX17/plans/task-demo-retire-20261126/task_plan.md" <<'PLAN'
# Task Plan
### Phase 1
- **Status:** complete
PLAN
python3 "$CLI" retire --root "$FX17" > "$FX17/retire.json" 2>&1; rc=$?
r_mode="$(json_field "$FX17/retire.json" 'mode')"
r_has_demo="$(python3 - "$FX17/retire.json" <<'PY'
import json, sys
doc = json.load(open(sys.argv[1], encoding='utf-8'))
print('yes' if 'task-demo-retire-20261126' in doc.get('eligible', []) else 'no')
PY
)"
if [ "$rc" -eq 0 ] && [ "$r_mode" = 'dry-run' ] && [ "$r_has_demo" = 'yes' ] && [ ! -d "$FX17/plans/archive" ]; then
  ok 17 'retire dry-run 零移动且 eligible 含 demo plan'
else
  bad 17 "retire dry-run 异常 rc=$rc mode=$r_mode has_demo=$r_has_demo archive_exists=$([ -d "$FX17/plans/archive" ] && echo yes || echo no)"
fi

# TC-18: mutation 终态→未结后 retire 候选移除
FX18="$(mktemp -d "$FIXTURE/fx18.XXXXXX")"
cp "$EXAMPLE" "$FX18/todo.json"
mkdir -p "$FX18/plans/task-demo-retire-20261126"
cat > "$FX18/plans/task-demo-retire-20261126/task_plan.md" <<'PLAN'
# Task Plan
### Phase 1
- **Status:** complete
PLAN
python3 "$CLI" set TODO-0002 --field status --value open --root "$FX18" >/dev/null 2>&1
python3 "$CLI" retire --root "$FX18" > "$FX18/retire.json" 2>&1; rc=$?
r18_eligible_len="$(python3 - "$FX18/retire.json" <<'PY'
import json, sys
doc = json.load(open(sys.argv[1], encoding='utf-8'))
print(len(doc.get('eligible', [])))
PY
)"
if [ "$rc" -eq 0 ] && [ "$r18_eligible_len" = '0' ]; then
  ok 18 'set 终态→open 后 retire eligible 为空'
else
  bad 18 "retire mutation 异常 rc=$rc eligible_len=$r18_eligible_len"
fi

# TC-19: active-pointer 守卫
FX19="$(mktemp -d "$FIXTURE/fx19.XXXXXX")"
cp "$EXAMPLE" "$FX19/todo.json"
mkdir -p "$FX19/plans/task-demo-retire-20261126"
cat > "$FX19/plans/task-demo-retire-20261126/task_plan.md" <<'PLAN'
# Task Plan
### Phase 1
- **Status:** complete
PLAN
printf '%s' 'task-demo-retire-20261126' > "$FX19/plans/.active_plan"
python3 "$CLI" retire --root "$FX19" > "$FX19/retire.json" 2>&1; rc=$?
r19_eligible_len="$(python3 - "$FX19/retire.json" <<'PY'
import json, sys
doc = json.load(open(sys.argv[1], encoding='utf-8'))
print(len(doc.get('eligible', [])))
PY
)"
r19_skip="$(python3 - "$FX19/retire.json" <<'PY'
import json, sys
doc = json.load(open(sys.argv[1], encoding='utf-8'))
skipped = doc.get('skipped', [])
hit = any(s.get('id') == 'task-demo-retire-20261126' and s.get('reason') == 'active-pointer' for s in skipped)
print('yes' if hit else 'no')
PY
)"
if [ "$rc" -eq 0 ] && [ "$r19_eligible_len" = '0' ] && [ "$r19_skip" = 'yes' ]; then
  ok 19 'active-pointer 守卫：eligible 空且 skipped 含 active-pointer'
else
  bad 19 "active-pointer 异常 rc=$rc eligible_len=$r19_eligible_len skip_hit=$r19_skip"
fi

echo "=== TOTAL: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
