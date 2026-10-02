#!/usr/bin/env bash
# selftest-dispatch-grain.sh — task-v118: Rule 46 子代理单任务专注度守护（单会话单 S-unit / 守卫豁免收窄 / 任务书口径）
# 校验面（静态锚 + check-dispatch.sh 守卫②④收窄行为 fixture；只读技能文件, 临时产物在 mktemp 目录内自清理）:
#   GR-01 critical-rules.md 46.1..46.5 五子条款在位（grep -c '^46.' = 5）
#   GR-02 critical-rules.md 含「### 46 子代理单任务专注度」条款头
#   GR-03 SKILL.md 委派检查点 2.5 含「单会话单 S-unit（Rule 46.1」措辞
#   GR-04 templates/subagent_dispatch.md Rule 46.1 引导行 ≥ 2（§1 目标段 + 检查点段两处）
#   GR-05 check-dispatch.sh 守卫②任务书收窄标记「任务书检出」在位
#   GR-06 check-dispatch.sh 守卫④任务书分支 tb 模式调用 `count_step_markers "$tb" tb` 在位
#   GR-07 [fixture] 任务书（subagent-state/ 落盘）含 2 个不同 S-id + prompt 引用它 → enforce exit 2 且 stderr 含「任务书检出」
#   GR-08 [fixture] 任务书含 6 个行首 markdown 编号动作 → enforce exit 2 且 stderr 含「步骤枚举超限」
#   GR-09 [fixture] 自由 prompt（无任务书双条件）含 6 个行首 markdown 编号 → exit 0（自由口径排除行首编号, 不拦）
#   GR-10 [fixture] 全角形态引用「执行（任务书：TB 路径）」（全角括号+全角冒号）+ 任务书含 2 个不同 S-id → enforce exit 2 且 stderr 含「任务书检出」
# 档位: 行为 fixture 实跑 check-dispatch.sh pretool, TASK_PLANNER_DISPATCH_ENFORCE=enforce + TASK_PLANNER_PLAN_DIR=<tmp 最小计划目录>
# 依据（字面锚, 不用行号——check-dispatch.sh 持续演进, 行号必漂移）:
#   critical-rules.md Rule 46 条款块（「### 46 子代理单任务专注度」及其 46.1..46.5 子条）
#   check-dispatch.sh 守卫②收窄注释（「任务书豁免收窄(Rule 46.2)」注释块）; ②实现=「任务书检出」分支
#     （双条件命中后 cat 合并任务书计 distinct S-id, ≥2 →「任务书检出 N 个 S-unit ID」计入 hits）;
#   ④=count_step_markers "$tb" tb 模式调用（fine_grain_checks ④ 任务书分支）;
#   提取器=extract_subagent_state_refs 共用函数（②④ 统一消费, 字符类含全角定界）
#   SKILL.md 委派检查点 2.5（「单会话单 S-unit（Rule 46.1」措辞）/ templates/subagent_dispatch.md Rule 46.1 引导行
# 9 断言全 PASS exit 0; 任一 FAIL exit 1。fixture prompt 含派发契约必备标签（三文件路径 + status:/acceptance:/checkpoint: +
# subagent-state/ 字面）避免缺项扫描（scan_missing）干扰——范式对照 selftest-fine-grain-steps.sh SG-06 PBOOK 构造
# （任务书引用行用 ASCII 括号闭合, 与 ②③ 的 sed 去尾标点类 `[),。，；;「”]` 对齐, 保证提取路径 -f 可命中）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GUARD="$SKILL_ROOT/scripts/check-dispatch.sh"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
TMPL="$SKILL_ROOT/templates/subagent_dispatch.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'GR-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'GR-%s FAIL %s\n' "$1" "$2"; }

# 行为 fixture 临时目录: RUN=脚本工作区, FP=最小计划目录(task_plan/findings/progress 三文件 + subagent-state/)
RUN="$(mktemp -d /tmp/tp-dg-XXXXXX)"
FP="$(mktemp -d /tmp/tp-dg-plan-XXXXXX)"
mkdir -p "$FP/subagent-state"
: > "$FP/task_plan.md"; : > "$FP/findings.md"; : > "$FP/progress.md"
cleanup() { rm -rf "$RUN" "$FP"; }
trap cleanup EXIT

# mk_prompt <输出文件> <正文文件> — 契约骨架: 目标 + 三文件路径 + 正文 + status/acceptance/checkpoint 等 8 字段标签。
# Why: checkpoint 行自带 subagent-state/ 字面, 且三文件绝对路径齐全 → 过 scan_missing 七项缺项扫描,
# 使 fixture 只测 ②④ 细粒度检测, 不被缺项路径（exit 2 缺项文案）干扰（SG-06 PBOOK 同源范式）。
mk_prompt() {
    { echo "目标：fixture"
      echo "计划三文件："
      echo "- $FP/task_plan.md"
      echo "- $FP/findings.md"
      echo "- $FP/progress.md"
      cat "$2"
      echo "返回严格 8 字段："
      echo "status: done"
      echo "acceptance: 1/1 pass"
      echo "checkpoint: $FP/subagent-state/gr-ck.md"
      echo "evidence: fixture"
      echo "files: none"
      echo "findings_written: none"
      echo "blockers: none"
      echo "confidence: HIGH"
    } > "$1"
}

# run_guard <prompt文件> — 清串行槽锁后 enforce 档实跑 pretool, 输出 "rc<TAB>stderr"
# Why: 清锁=防 SG 家族同坑（槽占用会先于 ②④ 触发 串行槽 exit 2 干扰归因）; RANDOM 后缀=防计数/锁文件跨断言串扰。
run_guard() {
    rm -f "$FP/subagent-state/.dispatch-inflight"
    local rc err
    err="$(TASK_PLANNER_DISPATCH_ENFORCE=enforce TASK_PLANNER_PLAN_DIR="$FP" bash "$GUARD" pretool "$1" "gr$$-$RANDOM" 2>&1 >/dev/null)"
    rc=$?
    printf '%s\t%s' "$rc" "$err"
}

# GR-01 critical-rules.md 46.x 子条款 5 条
n46="$(grep -c '^46\.' "$CRIT" 2>/dev/null || true)"
if [ "$n46" = "5" ]; then ok 01 "critical-rules.md 46.1..46.5 共 5 条"; else bad 01 "^46. 行数=$n46 (期望 5)"; fi
# GR-02 条款头锚
if grep -q '^### 46 子代理单任务专注度' "$CRIT"; then ok 02 "条款头「### 46 子代理单任务专注度」"; else bad 02 "条款头缺失: 缺「### 46 子代理单任务专注度」"; fi
# GR-03 SKILL.md 2.5 委派检查点单会话单 S-unit 措辞
if grep -qF '单会话单 S-unit（Rule 46.1' "$SKILLMD"; then ok 03 "SKILL.md 2.5 单会话单 S-unit"; else bad 03 "SKILL.md 缺「单会话单 S-unit（Rule 46.1」措辞"; fi
# GR-04 派发模板 Rule 46.1 引导行 ≥2
n146="$(grep -c 'Rule 46.1' "$TMPL" 2>/dev/null || true)"
if [ "${n146:-0}" -ge 2 ]; then ok 04 "subagent_dispatch.md Rule 46.1 引导行 x${n146}"; else bad 04 "Rule 46.1 行数=${n146:-0} (期望 ≥2)"; fi
# GR-05 守卫②任务书收窄标记
if grep -qF '任务书检出' "$GUARD"; then ok 05 "check-dispatch.sh 含「任务书检出」收窄标记"; else bad 05 "缺「任务书检出」收窄标记"; fi
# GR-06 守卫④任务书分支 tb 模式调用（实际实现 = fine_grain_checks ④任务书分支内 `count_step_markers "$tb" tb`）
if grep -qF 'count_step_markers "$tb" tb' "$GUARD"; then ok 06 "守卫④ tb 模式调用在位"; else bad 06 "缺 count_step_markers 第二参 tb 调用"; fi

# GR-07 任务书含 2 个不同 S-id + prompt 引用它 → ②收窄命中（原整体豁免 → 现计 S-unit 拦截）
TB7="$FP/subagent-state/taskbook-gr7.md"
printf 'S1 做动作甲\nS2 做动作乙\n' > "$TB7"
printf '按落盘任务书执行(任务书: %s)\n' "$TB7" > "$RUN/body7.txt"
P7="$RUN/p7.md"
mk_prompt "$P7" "$RUN/body7.txt"
r7="$(run_guard "$P7")"; rc7="${r7%%$'\t'*}"; err7="${r7#*$'\t'}"
if [ "$rc7" -eq 2 ] && printf '%s' "$err7" | grep -q '任务书检出'; then
  ok 07 "任务书 2 S-id → exit 2 + 任务书检出"
else bad 07 "rc=$rc7 err=$err7 (期望 exit 2 + 任务书检出)"; fi

# GR-08 任务书含 6 个行首 markdown 编号动作 → ④tb 模式计数 6 > step_max_steps(4) 命中
# （task-v116 实证形态: 行首 `1.`-`6.` 编号在原双模式统一口径下计数=0 全漏检, tb 模式收口后须拦）
TB8="$FP/subagent-state/taskbook-gr8.md"
{ for i in 1 2 3 4 5 6; do printf '%d. 任务书动作%s\n' "$i" "$i"; done; } > "$TB8"
printf '按落盘任务书执行(任务书: %s)\n' "$TB8" > "$RUN/body8.txt"
P8="$RUN/p8.md"
mk_prompt "$P8" "$RUN/body8.txt"
r8="$(run_guard "$P8")"; rc8="${r8%%$'\t'*}"; err8="${r8#*$'\t'}"
if [ "$rc8" -eq 2 ] && printf '%s' "$err8" | grep -q '步骤枚举超限'; then
  ok 08 "任务书 6 编号 → exit 2 + 步骤枚举超限"
else bad 08 "rc=$rc8 err=$err8 (期望 exit 2 + 步骤枚举超限)"; fi

# GR-09 自由 prompt（正文无「任务书」字面 → 双条件不命中）含 6 个行首 markdown 编号 → 自由口径不拦
# （46.2 边界: 自由 prompt 行首编号与验收清单难区分, 保持排除防误伤既有合法形态）
{ for i in 1 2 3 4 5 6; do printf '%d. 直接动作%s\n' "$i" "$i"; done; } > "$RUN/body9.txt"
P9="$RUN/p9.md"
mk_prompt "$P9" "$RUN/body9.txt"
r9="$(run_guard "$P9")"; rc9="${r9%%$'\t'*}"; err9="${r9#*$'\t'}"
if [ "$rc9" -eq 0 ] && ! printf '%s' "$err9" | grep -q '步骤枚举'; then
  ok 09 "自由 prompt 6 编号 → exit 0 不拦"
else bad 09 "rc=$rc9 err=$err9 (期望 exit 0 且无步骤枚举告警)"; fi

# GR-10 全角形态引用「执行（任务书：<TB 路径>）」（全角括号+全角冒号）→ 防 CR BLOCKER 盲区形态回退
# Why: 原内联提取字符类 [^[:space:]"] 不含（）：, 全角引用形态提取出含前后缀的整串 token, -f 判定失败
# fail-open（CR BLOCKER）; 现 ②④ 统一消费共用提取器 extract_subagent_state_refs（字符类含全角定界+
# 字节级剥残余非 ASCII 前后缀）, 该形态必须被 ②收窄拦截——本断言即回退防护（与 GR-07 半角形态互补）。
TB10="$FP/subagent-state/taskbook-gr10.md"
printf 'S3 做动作丙\nS4 做动作丁\n' > "$TB10"
printf '执行（任务书：%s）按序\n' "$TB10" > "$RUN/body10.txt"
P10="$RUN/p10.md"
mk_prompt "$P10" "$RUN/body10.txt"
r10="$(run_guard "$P10")"; rc10="${r10%%$'\t'*}"; err10="${r10#*$'\t'}"
if [ "$rc10" -eq 2 ] && printf '%s' "$err10" | grep -q '任务书检出'; then
  ok 10 "全角形态引用 + 2 S-id 任务书 → exit 2 + 任务书检出"
else bad 10 "rc=$rc10 err=$err10 (期望 exit 2 + 任务书检出)"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
