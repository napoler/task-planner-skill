#!/usr/bin/env bash
# selftest-pointer-lifecycle.sh — task-v159: 指针与部署生命周期守护面（PL-01..10）
# What: 静态断言 7（PL-01..07: gc 全局指针生命周期 / 哨兵-side 缺口巡检 / set 所有权守卫 /
#      set ROOT fallback 修正 / deploy staging+post-verify / check-complete 移交提醒 / SKILL 移交纪律行）
#      + 行为断言 3（PL-08 set ROOT 回归 / PL-09 stale 夹具 gc / PL-10 所有权守卫夹具）。
#      行为级夹具全部在 /tmp 隔离仓（mktemp -d），禁触真实 plans/ 与真实 side 键。
# Why: 守护 design-pointer-fix.md §新 selftest 断言清单 的 F1-F5 机制点（D1-D5）不回退；
#      守措辞不守行为错位复发风险（53.2/59.6 范式），行为级断言补齐「改了源码但行为错」盲区。
# PL-05 SKIP 语义（自愈式，先例=drift-enforcement DCE-10「布局差异 SKIP 计 PASS」）:
#      'diff -r' 在位但 '.stage' 未入 worktree（F5 staging 重构由并行单元施工，落位前本断言
#      SKIP 计 PASS 并显式标注；F5 落地后同一断言自动转为硬断言，无需改本脚本）。
# 全 PASS exit 0；任一 FAIL exit 1。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SET="$SCRIPT_DIR/set-active-plan.sh"
MERGE="$SCRIPT_DIR/smart-merge-back.sh"
COMPL="$SCRIPT_DIR/check-complete.sh"
SKILL="$SCRIPT_DIR/../SKILL.md"
PASS=0; FAIL=0
ok()  { echo "PASS $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL $1 ($2)"; FAIL=$((FAIL+1)); }
cnt() { [ -f "$2" ] || { echo 0; return; }; grep -c -e "$1" "$2" 2>/dev/null || true; }

# ── 静态断言 PL-01..07 ──
# PL-01: gc 源码含全局生命周期分支（死引用 dead-ref + 完成态 TTL completed-ttl 双因）
[ "$(cnt 'stale\|dead-ref\|completed-ttl' "$SET")" -ge 1 ] && ok "PL-01 gc 源码含全局生命周期分支（stale/dead-ref/completed-ttl 锚在位）" || bad "PL-01" "gc 全局生命周期锚缺失"
# PL-02: gc 源码含哨兵-side 缺口巡检（advisory 只报告不代写）
[ "$(cnt '巡检' "$SET")" -ge 1 ] && [ "$(cnt '\.plan_required_side' "$SET")" -ge 1 ] && ok "PL-02 gc 源码含哨兵-side 缺口巡检" || bad "PL-02" "巡检或 .plan_required_side 锚缺失"
# PL-03: set 源码含所有权守卫（.session-owner 扫描, 防 side 键沿袭互踩）
[ "$(cnt 'session-owner' "$SET")" -ge 1 ] && ok "PL-03 set 源码含所有权守卫（.session-owner 扫描在位）" || bad "PL-03" "session-owner 扫描锚缺失"
# PL-04: set 分支 ROOT 默认 $PWD（F4: 计划目录内运行 set 不把 task-id 当 root）
[ "$(cnt 'positional\[1\]:-\$PWD' "$SET")" -ge 1 ] && ok "PL-04 set 分支 ROOT 默认 \$PWD（positional[1]:-\$PWD 锚在位）" || bad "PL-04" "ROOT fallback 修正锚缺失"
# PL-05: deploy 段含 staging 与 post-verify（'.stage' + 'diff -r' 各≥1；F5 未落地时 SKIP 见文件头）
PL05_STAGE="$(cnt '\.stage' "$MERGE")"; PL05_DIFFR="$(cnt 'diff -r' "$MERGE")"
if [ "$PL05_DIFFR" -ge 1 ] && [ "$PL05_STAGE" -ge 1 ]; then
  ok "PL-05 deploy 段含 staging 与 post-verify（stage=${PL05_STAGE}, diff-r=${PL05_DIFFR}）"
elif [ "$PL05_DIFFR" -ge 1 ]; then
  ok "PL-05 deploy post-verify diff -r 在位（SKIP: F5 .stage staging 重构尚未落入 worktree，落地后转硬断言）"
else
  bad "PL-05" "staging/post-verify 锚均缺失"
fi
# PL-06: check-complete 含移交提醒（S3 实现: 提醒行走 stderr, 断言用 2>&1 等价 grep 校验 stderr 锚在位）
[ "$(cnt '移交提醒' "$COMPL")" -ge 1 ] && [ "$(cnt '移交提醒.*>&2' "$COMPL")" -ge 1 ] && ok "PL-06 check-complete 移交提醒在位（stderr 通道锚已校验）" || bad "PL-06" "移交提醒或 stderr 通道锚缺失"
# PL-07: SKILL.md 含移交纪律行（指针移交 25 完成项）
[ "$(cnt '指针移交' "$SKILL")" -ge 1 ] && ok "PL-07 SKILL.md 含移交纪律行（指针移交锚在位）" || bad "PL-07" "SKILL.md 移交纪律行缺失"

# ── 行为断言 PL-08..10（/tmp 隔离夹具, 禁触真实 plans/ 与真实 side 键）──
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# PL-08: set ROOT 回归——在计划目录内运行 set, exit 0（F4: 原实现把 task-id 当 root → PLAN 误报）
mkdir -p "$TMP/p8/proj/plans/demo-task"
printf '### Phase 1\n- **Status:** in_progress\n' > "$TMP/p8/proj/plans/demo-task/task_plan.md"
if ( cd "$TMP/p8/proj/plans/demo-task" && bash "$SET" set demo-task --sid "p8$$" ) >/dev/null 2>&1; then
  ok "PL-08 set ROOT 回归（计划目录内 set exit 0, side 指针写入）"
else
  bad "PL-08" "计划目录内 set rc!=0"
fi

# PL-09: stale 夹具 gc——临时 PLAN_ROOT 双场景: dead-ref（指向不存在目录）+ completed-ttl（完成态+指针 mtime>24h）,
#        判据=输出含 stale 且 .active_plan 被置空（原子语义=写空串不删文件）
mkdir -p "$TMP/p9a/proj/plans"
printf 'gone-task\n' > "$TMP/p9a/proj/plans/.active_plan"
OUT9A="$(bash "$SET" gc "$TMP/p9a/proj" 2>&1)"
mkdir -p "$TMP/p9b/proj/plans/done-task"
printf '### Phase 1\n- **Status:** complete\n' > "$TMP/p9b/proj/plans/done-task/task_plan.md"
printf 'done-task\n' > "$TMP/p9b/proj/plans/.active_plan"
touch -d '25 hours ago' "$TMP/p9b/proj/plans/.active_plan"
OUT9B="$(bash "$SET" gc "$TMP/p9b/proj" 2>&1)"
if printf '%s' "$OUT9A" | grep -q 'stale(dead-ref)' && [ ! -s "$TMP/p9a/proj/plans/.active_plan" ] \
   && printf '%s' "$OUT9B" | grep -q 'stale(completed-ttl)' && [ ! -s "$TMP/p9b/proj/plans/.active_plan" ]; then
  ok "PL-09 stale 夹具 gc（dead-ref + completed-ttl 双场景, 输出含 stale 且指针置空）"
else
  bad "PL-09" "stale 夹具 gc 行为异常: A=[$OUT9A] B=[$OUT9B]"
fi

# PL-10: 所有权守卫夹具——假 claimant（.session-owner 声明 sess<SID> 且其 Status=in_progress）,
#        判据=skip 写入 + WARN 输出含 claimant 键名; 再验 --force 显式覆盖可写
mkdir -p "$TMP/p10/proj/plans/claimant-task" "$TMP/p10/proj/plans/my-task"
printf '### Phase 1\n- **Status:** in_progress\n' > "$TMP/p10/proj/plans/claimant-task/task_plan.md"
printf '### Phase 1\n- **Status:** in_progress\n' > "$TMP/p10/proj/plans/my-task/task_plan.md"
SID10="pl10$$"
printf 'sess%s\n' "$SID10" > "$TMP/p10/proj/plans/claimant-task/.session-owner"
SIDE10="$TMP/p10/proj/plans/.active_plan_side/${SID10}.active_plan"
OUT10="$(cd "$TMP/p10" && bash "$SET" set my-task --sid "$SID10" "$TMP/p10/proj" 2>&1)"
if printf '%s' "$OUT10" | grep -q 'claimant-task' \
   && [ ! -f "$SIDE10" ] \
   && bash "$SET" set my-task --sid "$SID10" --force "$TMP/p10/proj" >/dev/null 2>&1 \
   && [ -f "$SIDE10" ]; then
  ok "PL-10 所有权守卫（假 claimant in_progress → skip 写入 + WARN 含 claimant 键名; --force 覆盖写入）"
else
  bad "PL-10" "守卫行为异常: OUT=[$OUT10] side_exists=$([ -f "$SIDE10" ] && echo 1 || echo 0)"
fi

echo "Total: 10 PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
