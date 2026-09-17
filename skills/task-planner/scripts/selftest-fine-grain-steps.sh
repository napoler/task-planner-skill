#!/usr/bin/env bash
# selftest-fine-grain-steps.sh — task-v081: 步骤枚举门控（step_max_steps）行为级守护
# 守护（行为实测为主 + 静态锚为辅；只读技能文件，临时产物全部在 mktemp 目录内自清理）:
#   SG-01 count_step_markers: 13×StepN → 13
#   SG-02 count_step_markers: 跨风格序号归一去重（Step1/①/第3步/步骤4/step 5 → distinct=4）
#   SG-03 check-dispatch enforce: 13 步 prompt → exit 2 且 stderr 含「步骤枚举超限」
#   SG-04 check-dispatch enforce: 4 步 prompt → exit 0 且 stderr 为空
#   SG-05 check-dispatch warn: 13 步 prompt → exit 0 且 warn 计数文件含「步骤枚举超限」
#   SG-06 任务书防绕门: prompt 引用落盘任务书(内含 13 步) → exit 2（计数取任务书）
#   SG-07 config 缺键回退: 剥离 step_max_steps 的临时 config → SKIPPED 行 + 默认 4 仍拦 13 步
#   SG-08 check-plan-dispatch: S-unit 目标列 6 步枚举 → SKIPPED 提示行 + exit 0（advisory 不阻断）
#   SG-09 check-plan-dispatch 对照: 目标列无枚举 → 无步骤枚举提示 + exit 0
#   SG-10 静态锚: critical-rules 21.1b/22.4/22.6 + SKILL.md + 派发模板 含 step_max_steps/步骤枚举增量
#   SG-11 口径双侧一致性: 两守卫脚本各自的 count_step_markers 对同一输入计数相等（防口径漂移）
# sid 每次运行唯一（v078 教训: 固定 sid 的 hook state 跨运行持久）; FAIL=0 exit 0, 任一 FAIL exit 1。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GUARD="$SKILL_ROOT/scripts/check-dispatch.sh"
PGATE="$SKILL_ROOT/scripts/check-plan-dispatch.sh"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
TMPL="$SKILL_ROOT/templates/subagent_dispatch.md"
CONFIG="$SKILL_ROOT/config.json"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'SG-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'SG-%s FAIL %s\n' "$1" "$2"; }

RUN="$(mktemp -d /tmp/tp-fgs-XXXXXX)"
FP="$(mktemp -d /tmp/tp-fgs-plan-XXXXXX)"     # fixture 计划目录(三文件齐全)
mkdir -p "$FP/subagent-state"
: > "$FP/task_plan.md"; : > "$FP/findings.md"; : > "$FP/progress.md"
cleanup() { rm -rf "$RUN" "$FP"; }
trap cleanup EXIT

gen_steps() { local n=$1 i=1; while [ $i -le $n ]; do echo "Step$i 执行动作$i"; i=$((i+1)); done; }
mk_prompt() { # $1=输出 $2=步骤正文生成器输出
    { echo "目标：fixture"
      echo "计划三文件："
      echo "- $FP/task_plan.md"
      echo "- $FP/findings.md"
      echo "- $FP/progress.md"
      cat
      echo "返回严格 8 字段："
      echo "status: done"
      echo "acceptance: 1/1 pass"
      echo "files: none"
      echo "evidence: fixture"
      echo "checkpoint: $FP/subagent-state/ck.md"
      echo "findings_written: none"
      echo "blockers: none"
      echo "confidence: HIGH"
    } > "$1"
}

# 提取指定脚本内的 count_step_markers 函数体并 eval（两脚本不互 source,各自提取保证测的就是那份代码）
extract_counter() { sed -n '/^count_step_markers() {/,/^}/p' "$1"; }

# SG-01
f13="$RUN/f13.txt"; gen_steps 13 > "$f13"
n="$( { extract_counter "$GUARD"; echo 'count_step_markers "'"$f13"'"'; } | bash )"
if [ "$n" = "13" ]; then ok 01 "13×StepN → 13"; else bad 01 "计数=$n (期望 13)"; fi

# SG-02
fmix="$RUN/mix.txt"; printf 'Step1 a\n① b\n第3步 c\n步骤4 d\nstep 5 e\n' > "$fmix"
n="$( { extract_counter "$GUARD"; echo 'count_step_markers "'"$fmix"'"'; } | bash )"
if [ "$n" = "4" ]; then ok 02 "跨风格去重 distinct=4"; else bad 02 "计数=$n (期望 4)"; fi

# 公共 prompt 骨架（三文件路径齐备过 scan_missing; 无 S<n> 字面避 ②; 有 checkpoint 等字面 token）
gen_steps 13 > "$RUN/body13.txt"; gen_steps 4 > "$RUN/body04.txt"
P13="$RUN/p13.md"; P04="$RUN/p04.md"
mk_prompt "$P13" < "$RUN/body13.txt"
mk_prompt "$P04" < "$RUN/body04.txt"

# SG-03
rm -f "$FP/subagent-state/.dispatch-inflight"
err="$(TASK_PLANNER_DISPATCH_ENFORCE=enforce TASK_PLANNER_PLAN_DIR="$FP" bash "$GUARD" pretool "$P13" "fg$$-a" 2>&1 >/dev/null)"; rc=$?
if [ "$rc" -eq 2 ] && printf '%s' "$err" | grep -q '步骤枚举超限(13>4)'; then ok 03 "enforce 13 步 → exit 2"; else bad 03 "rc=$rc err=$err"; fi
# SG-04
rm -f "$FP/subagent-state/.dispatch-inflight"
err="$(TASK_PLANNER_DISPATCH_ENFORCE=enforce TASK_PLANNER_PLAN_DIR="$FP" bash "$GUARD" pretool "$P04" "fg$$-b" 2>&1 >/dev/null)"; rc=$?
if [ "$rc" -eq 0 ] && [ -z "$err" ]; then ok 04 "enforce 4 步 → exit 0 静默"; else bad 04 "rc=$rc err=$err"; fi
# SG-05
rm -f "$FP/subagent-state/.dispatch-inflight"
sid5="fg$$-$RANDOM"
err="$(TASK_PLANNER_DISPATCH_ENFORCE=warn TASK_PLANNER_PLAN_DIR="$FP" bash "$GUARD" pretool "$P13" "$sid5" 2>&1 >/dev/null)"; rc=$?
if [ "$rc" -eq 0 ] && [ -f "${TMPDIR:-/tmp}/task-planner-dispatch-warn-$sid5" ] \
   && grep -q '步骤枚举超限' "${TMPDIR:-/tmp}/task-planner-dispatch-warn-$sid5"; then
  ok 05 "warn 13 步 → exit 0 + 计数落盘"
else bad 05 "rc=$rc"; fi
# SG-06 任务书绕门
TB="$FP/subagent-state/taskbook-$$.md"; gen_steps 13 > "$TB"
PBOOK="$RUN/pbook.md"
{ echo "按落盘任务书执行(任务书: $TB)"
  echo "计划三文件："
  echo "- $FP/task_plan.md"
  echo "- $FP/findings.md"
  echo "- $FP/progress.md"
  echo "返回：status: done / acceptance: 1/1 pass / checkpoint: $FP/subagent-state/ck.md"
} > "$PBOOK"
rm -f "$FP/subagent-state/.dispatch-inflight"
err="$(TASK_PLANNER_DISPATCH_ENFORCE=enforce TASK_PLANNER_PLAN_DIR="$FP" bash "$GUARD" pretool "$PBOOK" "fg$$-c" 2>&1 >/dev/null)"; rc=$?
if [ "$rc" -eq 2 ] && printf '%s' "$err" | grep -q '步骤枚举超限(13>4)'; then ok 06 "任务书 13 步 → exit 2 防绕门"; else bad 06 "rc=$rc err=$err"; fi
# SG-07 回退双分支: (a) config 剥键 → jq `//` 兜底静默回 4 仍拦 13 步(家族口径,无 SKIPPED 行);
#                (b) config 文件缺失 → jq 失败 → SKIPPED 行 + 回退 4 仍拦
TS="$RUN/skillroot"; mkdir -p "$TS/scripts"; cp "$GUARD" "$TS/scripts/"
jq 'del(.properties.subagent.properties.step_max_steps)' "$CONFIG" > "$TS/config.json" 2>/dev/null
rm -f "$FP/subagent-state/.dispatch-inflight"
err="$(TASK_PLANNER_DISPATCH_ENFORCE=enforce TASK_PLANNER_PLAN_DIR="$FP" bash "$TS/scripts/check-dispatch.sh" pretool "$P13" "fg$$-d" 2>&1 >/dev/null)"; rc=$?
TS2="$RUN/skillroot2"; mkdir -p "$TS2/scripts"; cp "$GUARD" "$TS2/scripts/"
rm -f "$FP/subagent-state/.dispatch-inflight"
err2="$(TASK_PLANNER_DISPATCH_ENFORCE=enforce TASK_PLANNER_PLAN_DIR="$FP" bash "$TS2/scripts/check-dispatch.sh" pretool "$P13" "fg$$-e" 2>&1 >/dev/null)"; rc2=$?
if [ "$rc" -eq 2 ] && printf '%s' "$err" | grep -q '步骤枚举超限(13>4)' \
   && [ "$rc2" -eq 2 ] && printf '%s' "$err2" | grep -q 'SKIPPED step_max_steps' && printf '%s' "$err2" | grep -q '步骤枚举超限(13>4)'; then
  ok 07 "回退双分支: 剥键静默拦 / 缺 config SKIPPED+拦"
else bad 07 "rc=$rc rc2=$rc2 err2=$err2"; fi
# SG-08 计划侧 advisory
PA="$RUN/plan-a.md"
cat > "$PA" <<'EOF'
# Plan A
## Phases
### Phase 1: 演示
- **Executor:** executor(sonnet-1)
| ID | 目标(≤1 句) | 执行体 | 输入(路径) | 验收 | 预估时长 | 状态 |
|----|------------|--------|-----------|------|---------|------|
| S1 | 精修: Step1 收集 Step2 备份 Step3 禁用词 Step4 封面 Step5 定点修 Step6 一致性 | code-assistant(haiku-1) | data/a.json | 完成标记 | 10min | pending |
EOF
out="$(bash "$PGATE" "$PA" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -q '步骤枚举 6 > step_max_steps(4)'; then ok 08 "计划侧 6 步枚举 → SKIPPED 提示 exit 0"; else bad 08 "rc=$rc out=$out"; fi
# SG-09 对照
PB="$RUN/plan-b.md"
cat > "$PB" <<'EOF'
# Plan B
## Phases
### Phase 1: 演示
- **Executor:** executor(sonnet-1)
| ID | 目标(≤1 句) | 执行体 | 输入(路径) | 验收 | 预估时长 | 状态 |
|----|------------|--------|-----------|------|---------|------|
| S1 | focus_keyword + meta_title 定点修 | code-assistant(haiku-1) | data/b.json | 完成标记 | 8min | pending |
EOF
out="$(bash "$PGATE" "$PB" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && ! printf '%s' "$out" | grep -q '步骤枚举'; then ok 09 "对照无枚举 → 静默 exit 0"; else bad 09 "rc=$rc out=$out"; fi
# SG-10 静态锚
if grep -q 'step_max_steps' "$CRIT" && grep -q 'step_max_steps' "$SKILLMD" && grep -q '步骤枚举约束' "$TMPL" \
   && [ "$(grep -c 'task-v081' "$CRIT")" -ge 3 ]; then ok 10 "条款/SKILL/模板 静态锚齐"; else bad 10 "静态锚缺失"; fi
# SG-11 口径双侧一致性
c1="$( { extract_counter "$GUARD"; echo 'count_step_markers "'"$fmix"'"'; } | bash )"
c2="$( { extract_counter "$PGATE"; echo 'count_step_markers "'"$fmix"'"'; } | bash )"
if [ "$c1" = "$c2" ] && [ "$c1" = "4" ]; then ok 11 "双脚本口径一致(=4)"; else bad 11 "c1=$c1 c2=$c2"; fi

printf 'Total: %s PASS=%s FAIL=%s\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
