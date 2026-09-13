#!/usr/bin/env bash
# [2026-09-14 task-v069-context-hygiene] selftest-context-hygiene.sh — R29 上下文与工作文件主动维护面 hermetic 守护套件
# 守护 task-v069 落地物 (Rule 29 条款存在性 / 2 新脚本可跑性 / config 3 键注册 / exit code 语义):
#   T01 critical-rules.md 含 "### 29" 标题 + 29.1-29.6 六子条款 (各 grep ≥1)
#   T02 SKILL.md "Rule 29" 指针 ≥2
#   T03 check-context-hygiene.sh 对 clean fixture (findings 短/无删除线/progress 完成段 ≤10 行) exit 0
#   T04 check-context-hygiene.sh 对含 superseded(~~) + 同主题 ≥5 条 fixture exit 1
#   T05 check-context-hygiene.sh 对 findings>500 行 fixture exit 2
#   T06 check-context-hygiene.sh 对不存在的 plan-dir exit 0 (fail-open)
#   T07 plan-hygiene.sh --dry-run: 超龄 completed 目录出 ARCHIVE 行; in_progress 目录不出
#   T08 plan-hygiene.sh --execute: 超龄目录实际 mv 进 archive/; in_progress 不动; exit 0
#   T09 plan-hygiene.sh --age 参数生效: 3 天前 completed 目录在 --age 3 下出 ARCHIVE
#   T10 config.json 3 键注册 (context_hygiene_enforce/plan_hygiene_enforce=warn, plan_archive_age_days=7)
#   T11 config.json 合法 (json.load 不抛异常)
#   T12 check-context-hygiene.sh 只读 (运行前后 fixture find -newermt 无变化)
# hermetic: fixture = mktemp -d 下最小 plans/ 镜像 (1 个 completed 任务目录 task_plan.md 全 Phase
# complete + 旧 mtime `touch -d "10 days ago"` 模拟超龄 + 1 个 in_progress 任务目录(不可归档) +
# findings.md 含 >500 行样例(seq 生成) 与 `~~superseded~~` 条目样例)。
# 被测脚本一律用 $SCRIPT_DIR 解析 (worktree 内路径, 参考 selftest-methodology.sh 做法),
# 不依赖主仓/真实 plans/; trap 清理; 对真实文件只读。
# ≥12 断言全 PASS exit 0; 任一 FAIL exit 1。幂等: 连跑两遍结果一致 (fixture 每次重建)。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # <root>/skills/task-planner/scripts
REAL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"                     # <root>/skills/task-planner
CHECK="$SCRIPT_DIR/check-context-hygiene.sh"
HYG="$SCRIPT_DIR/plan-hygiene.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT INT TERM

PASS=0; FAIL=0
assert() {  # assert <num> <desc> <cond_rc: 0=pass>
  local num="$1" desc="$2" rc="$3"
  local tag
  case "$num" in
    [!0]*|0[0-9]) tag="T$num" ;;   # 无前导 0, 避免 bash 视为八进制
    *) tag="T$(printf '%02d' "$num")" ;;
  esac
  if [ "$rc" -eq 0 ]; then
    PASS=$((PASS+1)); printf '%s PASS %s\n' "$tag" "$desc"
  else
    FAIL=$((FAIL+1)); printf '%s FAIL %s\n' "$tag" "$desc"
  fi
}

# ── 夹具: 最小 plans/ 镜像 ──
PLANS="$TMP/plans"
T_DONE="$PLANS/task-20260801-completed"      # completed + 超龄 (可归档)
T_OPEN="$PLANS/task-20260910-inprogress"      # in_progress (不可归档)
mkdir -p "$T_DONE" "$T_OPEN"

mk_done_plan() {  # 全部 Phase Status complete
  cat > "$T_DONE/task_plan.md" <<'EOF'
# task-20260801-completed
### Phase 1
**Status:** complete
- [x] S1
### Phase 2
**Status:** complete
- [x] S2
EOF
}
mk_open_plan() {  # 含 in_progress Phase → 不可归档
  cat > "$T_OPEN/task_plan.md" <<'EOF'
# task-20260910-inprogress
### Phase 1
**Status:** in_progress
- [ ] S1
EOF
}
mk_done_plan; mk_open_plan
touch -d "10 days ago" "$T_DONE/task_plan.md"   # 模拟超龄 (≥ 默认 7 天)
touch "$T_OPEN/task_plan.md"

# T01: critical-rules.md "### 29" 标题 + 29.1-29.6 六子条款
T01_RC=1
CR="$REAL_ROOT/references/critical-rules.md"
if [ "$(grep -c '^### 29' "$CR" 2>/dev/null)" -ge 1 ]; then
  T01_RC=0
  for s in 29.1 29.2 29.3 29.4 29.5 29.6; do
    grep -q "^${s} " "$CR" 2>/dev/null || { T01_RC=1; break; }
  done
fi
assert 01 "critical-rules.md '### 29' 标题 + 29.1-29.6 六子条款" "$T01_RC"

# T02: SKILL.md "Rule 29" 指针 ≥2
T02_RC=1
N_R29="$(grep -c "Rule 29" "$REAL_ROOT/SKILL.md" 2>/dev/null)"
[ "${N_R29:-0}" -ge 2 ] && T02_RC=0
assert 02 "SKILL.md 'Rule 29' 指针 ≥2 (实测 ${N_R29:-0})" "$T02_RC"

# T03: check-context-hygiene.sh 对 clean fixture exit 0
P_CLEAN="$TMP/plans-clean"
mkdir -p "$P_CLEAN"
{
  echo "# findings"
  echo ""
  echo "## §1 结论"
  echo "- A 结论一"
  echo "- B 结论二"
} > "$P_CLEAN/findings.md"
{
  echo "# progress"
  echo "### Phase 1"
  echo "**Status:** complete"
  echo "- action 1"
  echo "- action 2"
} > "$P_CLEAN/progress.md"   # 完成段明细 ≤10 行 → 不触发折叠
out="$(bash "$CHECK" "$P_CLEAN" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] && printf '%s' "$out" | grep -q "clean"
assert 03 "check-context-hygiene.sh clean fixture exit 0" "$?"

# T04: 含 superseded(~~) + 同主题 ≥5 条 fixture exit 1 (无严重项)
P_SUP="$TMP/plans-super"
mkdir -p "$P_SUP"
{
  echo "# findings"
  echo ""
  echo "## §1 结论"
  echo "~~旧结论 X~~ (superseded by §2, 2026-09-13)"
  echo ""
  echo "## §2 同主题证据"
  for i in 1 2 3 4 5 6; do echo "- 证据条目 $i"; done
} > "$P_SUP/findings.md"
out="$(bash "$CHECK" "$P_SUP" 2>&1)"; rc=$?
[ "$rc" -eq 1 ] && printf '%s' "$out" | grep -q "superseded"
assert 04 "check-context-hygiene.sh superseded+同主题≥5 fixture exit 1" "$?"

# T05: findings>500 行 fixture exit 2 (严重)
P_BIG="$TMP/plans-big"
mkdir -p "$P_BIG"
{
  echo "# findings"
  seq -f '%f' 1 600    # 600 行 > 500
} > "$P_BIG/findings.md"
out="$(bash "$CHECK" "$P_BIG" 2>&1)"; rc=$?
[ "$rc" -eq 2 ] && printf '%s' "$out" | grep -q "严重"
assert 05 "check-context-hygiene.sh findings>500 行 fixture exit 2" "$?"

# T06: 不存在的 plan-dir exit 0 (fail-open)
out="$(bash "$CHECK" "$TMP/no-such-dir" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] && printf '%s' "$out" | grep -q "fail-open"
assert 06 "check-context-hygiene.sh 不存在 plan-dir exit 0 (fail-open)" "$?"

# T07: plan-hygiene.sh --dry-run: 超龄 completed 出 ARCHIVE 行; in_progress 不出
out="$(bash "$HYG" "$PLANS" --dry-run 2>&1)"; rc=$?
printf '%s' "$out" | grep -q "ARCHIVE ${T_DONE##*/}" && ! printf '%s' "$out" | grep -q "ARCHIVE ${T_OPEN##*/}"
assert 07 "plan-hygiene.sh --dry-run: 超龄 completed 出 ARCHIVE 行, in_progress 不出" "$?"

# T08: plan-hygiene.sh --execute: 超龄目录实际 mv 进 archive/; in_progress 不动; exit 0
out="$(bash "$HYG" "$PLANS" --execute 2>&1)"; rc=$?
[ "$rc" -eq 0 ] && [ -d "$PLANS/archive/${T_DONE##*/}" ] && [ -f "$PLANS/archive/${T_DONE##*/}/task_plan.md" ] \
  && [ -d "$T_OPEN" ]
assert 08 "plan-hygiene.sh --execute: 超龄目录 mv 入 archive/, in_progress 不动, exit 0" "$?"

# T09: plan-hygiene.sh --age 参数生效 (3 天前 completed 目录在 --age 3 下出 ARCHIVE)
#     重建: execute 已消费 T_DONE, 用新 fixture 隔离 --age 语义
P_AGE="$TMP/plans-age"
mkdir -p "$P_AGE/task-age3"
cat > "$P_AGE/task-age3/task_plan.md" <<'EOF'
# task-age3
### Phase 1
**Status:** complete
EOF
touch -d "3 days ago" "$P_AGE/task-age3/task_plan.md"
# 对照组: 同 3 天前的目录在 --age 5 下应不出 ARCHIVE (证明阈值确实受 --age 控制)
P_AGE5="$TMP/plans-age5"
mkdir -p "$P_AGE5/task-age3"
cp "$P_AGE/task-age3/task_plan.md" "$P_AGE5/task-age3/"
touch -d "3 days ago" "$P_AGE5/task-age3/task_plan.md"
out3="$(bash "$HYG" "$P_AGE" --dry-run --age 3 2>&1)"
out5="$(bash "$HYG" "$P_AGE5" --dry-run --age 5 2>&1)"
printf '%s' "$out3" | grep -q "ARCHIVE task-age3" && ! printf '%s' "$out5" | grep -q "ARCHIVE task-age3"
assert 09 "plan-hygiene.sh --age 3 对 3 天前 completed 出 ARCHIVE; --age 5 不出" "$?"

# T10: config.json 3 键注册 (python3 json.load 断言 key 存在 + 默认值 warn/warn/7)
T10_RC=1
if command -v python3 >/dev/null 2>&1; then
  T10_RC="$(python3 - "$REAL_ROOT/config.json" <<'EOF'
import json, sys
props = json.load(open(sys.argv[1]))['properties']
assert props['context_hygiene_enforce']['default'] == 'warn'
assert props['plan_hygiene_enforce']['default'] == 'warn'
assert props['plan_archive_age_days']['default'] == 7
EOF
  echo $?)"
fi
[ "${T10_RC:-1}" = "0" ]
assert 10 "config.json 3 键注册 (context/plan hygiene=warn, plan_archive_age_days=7)" "$?"

# T11: config.json 合法 (json.load 不抛异常)
T11_RC=1
if command -v python3 >/dev/null 2>&1; then
  python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$REAL_ROOT/config.json" 2>/dev/null && T11_RC=0
fi
assert 11 "config.json 合法 (json.load 不抛异常)" "$T11_RC"

# T12: check-context-hygiene.sh 只读 (运行前后 fixture 目录 mtime 无变化)
SNAP_T="$(find "$P_CLEAN" -exec stat -c '%n %Y' {} \; | sort)"
out="$(bash "$CHECK" "$P_CLEAN" 2>&1)"
SNAP_A="$(find "$P_CLEAN" -exec stat -c '%n %Y' {} \; | sort)"
[ -n "$SNAP_T" ] && [ "$SNAP_T" = "$SNAP_A" ]
assert 12 "check-context-hygiene.sh 只读 (运行前后 fixture mtime 不变)" "$?"

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
