#!/usr/bin/env bash
# selftest-scope-boundary.sh — Rule 118 范围边界机器门行为回归
#
# 用法: bash selftest-scope-boundary.sh（无参，自建 mktemp 沙箱，退出时清理）
# 覆盖: TC-01 scope-set+render; TC-02 越界BLOCK; TC-03 include内放行;
#       TC-04 存量无字段WARN放行; TC-05 mutation 删门段后TC-02翻转FAIL;
#       TC-06 scope-extend 无--reason拒绝; TC-07 可移植性(无硬编码绝对路径)
# 输出: TC-N PASS|FAIL <说明>；末行 === TOTAL: PASS=N FAIL=M ===
# 退出码: 0=全过 / 1=任一FAIL

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
PLANCTL="$SCRIPT_DIR/planctl.py"
CHECK_SCOPE="$SCRIPT_DIR/check-scope.sh"
SELFTEST="$SCRIPT_DIR/selftest-scope-boundary.sh"

PASS=0
FAIL=0
FIXTURE="$(mktemp -d /tmp/selftest-scope-boundary.XXXXXX)"
trap 'rm -rf "$FIXTURE"' EXIT

ok()  { PASS=$((PASS + 1)); printf 'TC-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL + 1)); printf 'TC-%s FAIL %s\n' "$1" "$2"; }

# 构造最小 git worktree 夹具（避免 worktree-required 干扰 scope-boundary 断言）
init_repo() {
  local repo="$1"
  local base="$FIXTURE/base-$(basename "$repo")"
  rm -rf "$repo" "$base"
  mkdir -p "$base"
  git -C "$base" init -q
  git -C "$base" config user.email test@test
  git -C "$base" config user.name test
  echo init > "$base/README.txt"
  git -C "$base" add README.txt
  git -C "$base" commit -qm init
  git -C "$base" worktree add -q "$repo" -b "wt-$(basename "$repo")" >/dev/null 2>&1
  mkdir -p "$repo/plans/task-sb"
  cat > "$repo/plans/task-sb/task_plan.md" <<'MD'
# Task Plan: task-sb
MD
  cat > "$repo/plans/task-sb/plan-state.json" <<'JSON'
{
  "schema_version": 1,
  "task_id": "task-sb",
  "plan_tier": "standard",
  "execution_lane": "L1",
  "created_at": "2026-11-27T00:00:00Z",
  "updated_at": "2026-11-27T00:00:00Z",
  "requirements": [],
  "goals": [],
  "vcs": [],
  "phases": [],
  "findings": [],
  "audits": [],
  "delegations": [],
  "tags": []
}
JSON
  touch "$repo/plans/task-sb/task_plan.md"
  printf '%s\n' "$repo"
}

run_check() {
  local repo="$1" target="$2"
  (
    cd "$repo"
    TASK_PLANNER_SID="" bash "$CHECK_SCOPE" Write "$target" 2>&1
  )
}

# TC-01: scope-set 写字段 + render 含「执行范围限制」段
REPO1="$FIXTURE/r1"
init_repo "$REPO1" >/dev/null
python3 "$PLANCTL" scope-set --plan-dir "$REPO1/plans/task-sb" \
  --include "$REPO1/src/**" --exclude "$REPO1/src/secret/**" --declared-by plan+user >/dev/null 2>&1
rc=$?
has_field=$(python3 - "$REPO1/plans/task-sb/plan-state.json" <<'PY'
import json,sys
d=json.load(open(sys.argv[1],encoding='utf-8'))
sb=d.get('scope_boundary',{})
print('1' if sb.get('enabled') is True and 'src/**' in str(sb.get('include')) else '0')
PY
)
python3 "$PLANCTL" render --plan-dir "$REPO1/plans/task-sb" >/dev/null 2>&1
has_section=$(grep -c '执行范围限制' "$REPO1/plans/task-sb/task_plan.md" 2>/dev/null || echo 0)
if [ "$rc" -eq 0 ] && [ "$has_field" = "1" ] && [ "$has_section" -ge 1 ]; then
  ok 01 'scope-set 写字段且 render 含执行范围限制段'
else
  bad 01 "scope-set/render 异常 rc=$rc has_field=$has_field has_section=$has_section"
fi

# TC-02: include 外写 -> BLOCKED
REPO2="$FIXTURE/r2"
init_repo "$REPO2" >/dev/null
mkdir -p "$REPO2/src"
python3 "$PLANCTL" scope-set --plan-dir "$REPO2/plans/task-sb" \
  --include "$REPO2/src/**" --declared-by test >/dev/null 2>&1
out=$(run_check "$REPO2" "$REPO2/tmp/outside.md"); rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF '[scope-boundary] BLOCKED'; then
  ok 02 'include 外写被 [scope-boundary] BLOCKED'
else
  bad 02 "include 外写未被拦截 rc=$rc out=$out"
fi

# TC-03: include 内写 -> exit 0
out=$(run_check "$REPO2" "$REPO2/src/inside.md"); rc=$?
if [ "$rc" -eq 0 ]; then
  ok 03 'include 内写放行 exit 0'
else
  bad 03 "include 内写被误拦 rc=$rc out=$out"
fi

# TC-04: 存量计划无 scope_boundary 字段 -> WARN + exit 0
REPO4="$FIXTURE/r4"
init_repo "$REPO4" >/dev/null
# 确认无 scope_boundary
python3 - "$REPO4/plans/task-sb/plan-state.json" <<'PY'
import json,sys
p=sys.argv[1]; d=json.load(open(p,encoding='utf-8')); d.pop('scope_boundary',None); json.dump(d,open(p,'w',encoding='utf-8'))
PY
out=$(run_check "$REPO4" "$REPO4/anywhere.txt"); rc=$?
if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -qF '[scope-boundary] WARN 未声明范围边界，按存量计划放行'; then
  ok 04 '存量无字段 WARN+exit 0'
else
  bad 04 "存量兼容异常 rc=$rc out=$out"
fi

# TC-05: mutation - 删除 check-scope.sh 中 [scope-boundary] 比对段标记后 TC-02 应翻转
MUT="$FIXTURE/check-scope.mut.sh"
cp "$CHECK_SCOPE" "$MUT"
# 删除包含 [scope-boundary] BLOCKED 输出的关键行（比对段核心）
python3 - "$MUT" <<'PY'
import sys, re
p=sys.argv[1]
s=open(p,encoding='utf-8').read()
s2=s.replace("[scope-boundary] BLOCKED", "[scope-boundary-disabled] BLOCKED")
if s==s2:
    # fallback: remove the whole check call
    s2=s.replace('_scope_boundary_check "$abs_path" "$ROOT" || exit 1', '# mutation: scope boundary disabled')
open(p,'w',encoding='utf-8').write(s2)
print('mutated' if s!=s2 else 'nochange')
PY
REPO5="$FIXTURE/r5"
init_repo "$REPO5" >/dev/null
mkdir -p "$REPO5/src"
python3 "$PLANCTL" scope-set --plan-dir "$REPO5/plans/task-sb" \
  --include "$REPO5/src/**" --declared-by test >/dev/null 2>&1
out=$(cd "$REPO5" && TASK_PLANNER_SID="" bash "$MUT" Write "$REPO5/tmp/outside.md" 2>&1); rc=$?
if [ "$rc" -eq 0 ]; then
  ok 05 'mutation: 删门段后越界写不再被拦截（门有效性可证伪）'
else
  bad 05 "mutation 后仍拦截 rc=$rc out=$out（门可能不可证伪）"
fi

# TC-06: scope-extend 无 --reason -> exit 非0
REPO6="$FIXTURE/r6"
init_repo "$REPO6" >/dev/null
python3 "$PLANCTL" scope-set --plan-dir "$REPO6/plans/task-sb" --include "$REPO6/src/**" --declared-by test >/dev/null 2>&1
out=$(python3 "$PLANCTL" scope-extend --plan-dir "$REPO6/plans/task-sb" --path "$REPO6/other/**" --reason "" 2>&1); rc=$?
if [ "$rc" -ne 0 ]; then
  ok 06 'scope-extend 无 reason 拒绝 exit!=0'
else
  bad 06 "scope-extend 空 reason 应拒绝 rc=$rc out=$out"
fi

# TC-07: 可移植性 - 自测脚本无硬编码宿主绝对路径
# 自身检测模式分段拼接，避免字面量命中。
_p1='/home/'
_p2='[a-zA-Z0-9_]+'
_p3='/mnt/data/dev/task-planner-skill'
_p4='/tmp/worktrees/task-boundary-advance'
if grep -qE "${_p1}${_p2}|${_p3}${_p4}" "$SELFTEST" 2>/dev/null; then
  bad 07 '自测脚本含硬编码宿主绝对路径'
else
  ok 07 '自测脚本无硬编码宿主绝对路径'
fi

printf '=== TOTAL: PASS=%d FAIL=%d ===\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
