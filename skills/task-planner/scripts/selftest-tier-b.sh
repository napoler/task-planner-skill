#!/usr/bin/env bash
# selftest-tier-b.sh — task-v094 Tier B 全 7 项守护（T-B1..T-B7 正反夹具）
# 每断言=机器可观察行为; 3 断言组失败 exit 1。写入仅 /tmp, 退出清理。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'TB-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'TB-%s FAIL %s\n' "$1" "$2"; }
T="$(mktemp -d /tmp/selftest-tier-b.XXXXXX)"
trap 'rm -rf "$T"' EXIT
CKD="$SCRIPT_DIR/check-delegation.sh"; CKDIS="$SCRIPT_DIR/check-dispatch.sh"
RIM="$SCRIPT_DIR/resolve-interaction-mode.sh"; CR="$SKILL_ROOT/references/critical-rules.md"

# ── T-B4 直做通道 ──
mkdir -p "$T/mini/plans/tm" "$T/std/plans/ts"
printf '# t\n<!-- plan_tier: mini -->\n' > "$T/mini/plans/tm/task_plan.md"
printf '# t\n<!-- plan_tier: standard -->\n' > "$T/std/plans/ts/task_plan.md"
printf 'x=1\n' > "$T/app.py"
( cd "$T/mini" && bash "$CKD" pretool "$T/app.py" default 5 ) 2>/dev/null; [ $? -eq 0 ] && ok 01 "mini 业务文件直做放行" || bad 01 "mini 业务文件未放行"
( cd "$T/mini" && bash "$CKD" pretool "/home/terry/.zcode/skills/task-planner/SKILL.md" default 5 ) 2>/dev/null; [ $? -eq 2 ] && ok 02 "mini 保护区仍拦截" || bad 02 "mini 保护区被放行(红线失守)"
( cd "$T/std" && bash "$CKD" pretool "$T/app.py" default 5 ) 2>/dev/null; [ $? -eq 2 ] && ok 03 "非 mini 不受通道影响" || bad 03 "非 mini 误放行"
grep -q '④ mini 直做通道' "$CR" && ok 04 "Rule 14 ④ 通道条款在位" || bad 04 "Rule 14 ④ 缺失"

# ── T-B3 mini silent ──
printf '# t\n<!-- plan_tier: mini -->\n' > "$T/m1.md"
[ "$(bash "$RIM" "$T/m1.md")" = "silent" ] && ok 05 "mini 无声明缺省 silent" || bad 05 "mini 缺省非 silent"
printf '# t\n<!-- plan_tier: mini -->\n| `interaction_mode` | `ask` |\n' > "$T/m2.md"
[ "$(bash "$RIM" "$T/m2.md")" = "ask" ] && ok 06 "mini 显式 ask 优先" || bad 06 "mini 显式被覆盖"
printf '# t\n' > "$T/s1.md"
[ "$(bash "$RIM" "$T/s1.md")" = "ask" ] && ok 07 "standard 档不受影响" || bad 07 "standard 被波及"

# ── T-B2 单 Phase 模板 ──
grep -q '固定 1：实施+验收合一' "$SKILL_ROOT/templates/variant/mini-lite-type.md" && ok 08 "mini-lite 单 Phase 锚" || bad 08 "模板仍 2 Phase"
grep -q '单 Phase 化（\[task-v094 T-B2\]）\|单 Phase（实施+验收合一' "$CR" && ok 09 "38.3 契约同步" || bad 09 "38.3 未同步"

# ── T-B5 / T-B7 / T-B6 文本锚 ──
grep -q '短任务豁免（\[task-v094 T-B5\]）' "$CR" && ok 10 "22.8.2 T5 豁免句" || bad 10 "T5 豁免句缺失"
grep -q '纯实施 Phase 一行声明豁免（\[task-v094 T-B7\]）' "$CR" && ok 11 "19.2 一行声明句" || bad 11 "T-B7 句缺失"
grep -q 'diff 分级（\[task-v094 T-B6\]）' "$SKILL_ROOT/SKILL.md" && ok 12 "SKILL CR 分级句" || bad 12 "T-B6 分级句缺失"
grep -q '轻 diff 合并（\[task-v094 T-B6\]）' "$SKILL_ROOT/SKILL.md" && ok 13 "验证流程合并句" || bad 13 "合并句缺失"

# ── T-B1 分槽并行 ──
mkdir -p "$T/p1/plans/pk/subagent-state"
printf '# p\n<!-- parallel_readonly: true -->\n### Phase 1\n- **Status:** in_progress\n- **Executor:** executor（sonnet-1）\n\n| ID | 目标 | 执行体 | 输入 | 验收 | 时长 | 状态 |\n|---|---|---|---|---|---|---|\n| S1 | x | explore(mini) | y | z | 5min | pending |\n' > "$T/p1/plans/pk/task_plan.md"
now=$(date +%s); echo $((now-30)) > "$T/p1/plans/pk/subagent-state/.dispatch-inflight"
cat > "$T/pr.txt" << EOF
只读探查 [readonly-parallel]
$T/p1/plans/pk/task_plan.md
$T/p1/plans/pk/findings.md
$T/p1/plans/pk/progress.md
checkpoint: $T/p1/plans/pk/subagent-state/ck.md
status: done
acceptance: n/total
EOF
cat > "$T/pw.txt" << EOF
写类实施
$T/p1/plans/pk/task_plan.md
$T/p1/plans/pk/findings.md
$T/p1/plans/pk/progress.md
checkpoint: $T/p1/plans/pk/subagent-state/ck.md
status: pending
acceptance: n/total
EOF
TASK_PLANNER_PLAN_DIR="$T/p1/plans/pk" bash "$CKDIS" pretool "$T/pr.txt" sid-a >/dev/null 2>&1; [ $? -eq 0 ] && ok 14 "只读声明+标记槽占用放行" || bad 14 "只读豁免未放行"
TASK_PLANNER_PLAN_DIR="$T/p1/plans/pk" bash "$CKDIS" pretool "$T/pw.txt" sid-b >/dev/null 2>&1; [ $? -eq 2 ] && ok 15 "写类槽占用仍拦截" || bad 15 "写类被误放行"
sed -i '/parallel_readonly: true/d' "$T/p1/plans/pk/task_plan.md"
TASK_PLANNER_PLAN_DIR="$T/p1/plans/pk" bash "$CKDIS" pretool "$T/pr.txt" sid-c >/dev/null 2>&1; [ $? -eq 2 ] && ok 16 "双条件缺声明仍拦" || bad 16 "单标记误放行"
rm -f "$T/p1/plans/pk/subagent-state/.dispatch-inflight"
TASK_PLANNER_PLAN_DIR="$T/p1/plans/pk" bash "$CKDIS" pretool "$T/pw.txt" sid-d >/dev/null 2>&1; [ $? -eq 0 ] && ok 17 "槽空闲写类正常" || bad 17 "槽空闲误拦"
grep -q '只读分槽豁免（\[task-v094 T-B1\]' "$CR" && ok 18 "21.4 豁免子条在位" || bad 18 "21.4 子条缺失"

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
