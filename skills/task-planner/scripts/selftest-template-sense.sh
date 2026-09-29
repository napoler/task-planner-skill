#!/usr/bin/env bash
# selftest-template-sense.sh — task-v096 P6-S1: 三时点模板感知网（Rule 34.7）行为级守护
# 守护面（T1 机器激活点 + T2 条款锚 + T3 终验 warn 兜底）:
#   case-1 T1 正例: init-session 类型空缺（general 兜底）→ 输出含 [template-sense] 且生成的 task_plan.md 末尾含「🔁 模板感知」区块
#   case-2 T1 正例: 未知类型 foobar → 输出含 [template-sense] 与「🔁 模板感知」
#   case-3 T1 负例: 已知类型 bugfix → [template-sense] 计 0（known-type 路径零触发）
#   case-4 条款锚: critical-rules.md 首列 34.7 恰 1 条且含「全自动生成合约」；SKILL.md C22 行含「34.7 全自动生成」
#   case-5 T3 warn: 计划含「🔁 模板感知」区块且无处置登记 → check-complete 输出含 [template-sense]；无区块计划零输出
#   case-6 registry 自检: selftest-registry.tsv 含本脚本登记行（含本 S-unit 写入的 dep_anchors）
#   case-7 T1 CR-fix 负例: mini 档（tier=mini + 空类型）→ 产物 mini-lite 带标记, 无「🔁 模板感知」区块、无 general 注释（无标记守卫消除 P1-1）
#   case-8 T1 CR-fix 负例: 重跑（先 bugfix 再空类型重跑）→ 产物类型标记仍 bugfix 且无感知区块（无标记守卫消除 P1-2, 来源守卫保留）
# 8 断言全 PASS exit 0; 任一 FAIL exit 1。行为级用例临时产物均在 mktemp -d 目录, 脚本退出前清理, 不写仓库内任何路径。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILL="$SKILL_ROOT/SKILL.md"
INIT="$SCRIPT_DIR/init-session.sh"
CHECK="$SCRIPT_DIR/check-complete.sh"
TSV="$SCRIPT_DIR/selftest-registry.tsv"
SELF_NAME="$(basename "${BASH_SOURCE[0]}")"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'case-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'case-%s FAIL %s\n' "$1" "$2"; }

T_DIRS=""
cleanup() { [ -n "$T_DIRS" ] && rm -rf $T_DIRS; }
trap cleanup EXIT

# 行为级公共: init-session 需在 plans/<task-id>/ 目录运行（CWD 守卫）;
# 清掉 env 类型兜底防干扰
run_init() { # $1=task-dir $2=type-arg(""=不传)
    local dir="$1" ttype="$2"
    ( cd "$dir/plans/demo" && TASK_TEMPLATE_TYPE= TASK_TEMPLATE_DEFAULT= bash "$INIT" proj ${ttype:+"$ttype"} ) 2>&1
}

# case-7/8 CR-fix 负例: 第 3 位置参 tier 直传 (init-session.sh proj "" mini)。
# 注意: ttype 为空时须显式传空串占位, 否则 tier 会前移落入第 2 位置参 (template_type),
# 本 helper 与 run_init 的区别正在此。清掉 env tier/类型兜底防干扰
run_init_tier() { # $1=task-dir $2=type-arg(""=显式传空串占位) $3=tier-arg(""=不传)
    local dir="$1" ttype="$2" tier="$3"
    ( cd "$dir/plans/demo" && TASK_TEMPLATE_TYPE= TASK_TEMPLATE_DEFAULT= TASK_PLAN_TIER= TASK_AUTO_TIER= bash "$INIT" proj "${ttype:-}" ${tier:+"$tier"} ) 2>&1
}

# case-1 T1 general 空缺正例
T1D="$(mktemp -d /tmp/tsense-case1.XXXXXX)"; T_DIRS="$T_DIRS $T1D"
mkdir -p "$T1D/plans/demo"
out1="$(run_init "$T1D" "")"
if [ "$(grep -cF '[template-sense]' <<<"$out1")" -ge 1 ] \
   && [ "$(grep -cF '🔁 模板感知' "$T1D/plans/demo/task_plan.md")" -ge 1 ]; then
    ok 1 "general 空缺 → 输出含 [template-sense] 且 task_plan.md 含「🔁 模板感知」"
else
    bad 1 "general 空缺未触发 [template-sense]/区块: $(grep -F '[template-sense]' <<<"$out1" || true)"
fi

# case-2 T1 unknown 正例
T2D="$(mktemp -d /tmp/tsense-case2.XXXXXX)"; T_DIRS="$T_DIRS $T2D"
mkdir -p "$T2D/plans/demo"
out2="$(run_init "$T2D" "foobar")"
if [ "$(grep -cF '[template-sense]' <<<"$out2")" -ge 1 ] \
   && [ "$(grep -cF '🔁 模板感知' "$T2D/plans/demo/task_plan.md")" -ge 1 ]; then
    ok 2 "unknown 类型 foobar → 输出含 [template-sense] 且 task_plan.md 含「🔁 模板感知」"
else
    bad 2 "unknown 类型未触发 [template-sense]/区块: $(grep -F '[template-sense]' <<<"$out2" || true)"
fi

# case-3 T1 known 负例
T3D="$(mktemp -d /tmp/tsense-case3.XXXXXX)"; T_DIRS="$T_DIRS $T3D"
mkdir -p "$T3D/plans/demo"
out3="$(run_init "$T3D" "bugfix")"
n3="$(grep -cF '[template-sense]' <<<"$out3" || true)"
m3="$(grep -cF '🔁 模板感知' "$T3D/plans/demo/task_plan.md" 2>/dev/null || true)"
if [ "$n3" = 0 ] && [ "$m3" = 0 ]; then
    ok 3 "known 类型 bugfix → [template-sense] 计 0（输出与产物区块均零触发）"
else
    bad 3 "known 类型 bugfix 误触发: out=[template-sense] 计 $n3, 区块计 $m3"
fi

# case-4 条款锚（T2 静态守护）
r347="$(grep -c '^34\.7 ' "$CRIT" 2>/dev/null || echo 0)"
if [ "$r347" = 1 ] && grep '^34\.7 ' "$CRIT" | grep -q '全自动生成合约' \
   && grep '^| C22 ' "$SKILL" | grep -q '34\.7 全自动生成'; then
    ok 4 "critical-rules 34.7 恰 1 条且含「全自动生成合约」; SKILL.md C22 行含「34.7 全自动生成」"
else
    bad 4 "条款锚缺失/漂移: 34.7 条数=$r347, C22 行: $(grep '^| C22 ' "$SKILL" | head -1)"
fi

# case-5 T3 check-complete warn 行为
make_fake_plan() { # $1=dir $2=0|1(含区块与否)
    local d="$1" with="$2"
    mkdir -p "$d"
    printf '%s\n' "# demo fake plan" "" "## Phase 1: 执行" "- [ ] V-1.1: 示例验收行（占位）" > "$d/task_plan.md"
    if [ "$with" = 1 ]; then
        cat >> "$d/task_plan.md" <<'EOF'

## 🔁 模板感知
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）
EOF
    fi
    printf '%s\n' "# findings" "- fake 占位" "- fake 占位" > "$d/findings.md"
    printf '%s\n' "# progress" "- fake 占位" "- fake 占位" > "$d/progress.md"
}
T5A="$(mktemp -d /tmp/tsense-case5a.XXXXXX)"; T_DIRS="$T_DIRS $T5A"
T5B="$(mktemp -d /tmp/tsense-case5b.XXXXXX)"; T_DIRS="$T_DIRS $T5B"
make_fake_plan "$T5A" 1
make_fake_plan "$T5B" 0
out5a="$( (cd "$T5A" && bash "$CHECK" task_plan.md) 2>&1 )"
out5b="$( (cd "$T5B" && bash "$CHECK" task_plan.md) 2>&1 )"
if [ "$(grep -cF '[template-sense]' <<<"$out5a")" -ge 1 ] \
   && [ "$(grep -cF '[template-sense]' <<<"$out5b")" = 0 ]; then
    ok 5 "含区块且无登记 → [template-sense] warn; 无区块计划 → 零 [template-sense] 输出"
else
    bad 5 "T3 warn 行为漂移: 含区块输出计 $(grep -cF '[template-sense]' <<<"$out5a" || true), 无区块输出计 $(grep -cF '[template-sense]' <<<"$out5b" || true)"
fi

# case-6 registry 自检（本 S-unit 登记行: 脚本名 + dep_anchors 四条）
if [ -f "$TSV" ] \
   && grep -F "$SELF_NAME" "$TSV" | grep -F 'init-session.sh;critical-rules.md;check-complete.sh;SKILL.md' >/dev/null; then
    ok 6 "selftest-registry.tsv 含本脚本登记行且 dep_anchors 四条在位"
else
    bad 6 "registry 缺本脚本行或 dep_anchors 漂移"
fi

# case-7 CR-fix 负例: mini 档 tier=mini + 空类型 → mini-lite 产物无感知区块、无 general 注释（P1-1 消除）
T7D="$(mktemp -d /tmp/tsense-case7.XXXXXX)"; T_DIRS="$T_DIRS $T7D"
mkdir -p "$T7D/plans/demo"
out7="$(run_init_tier "$T7D" "" "mini")"
p7="$(grep -cF 'mini-lite' "$T7D/plans/demo/task_plan.md" 2>/dev/null || true)"
s7="$(grep -cF '🔁 模板感知' "$T7D/plans/demo/task_plan.md" 2>/dev/null || true)"
g7="$(grep -cF 'template_type: general' "$T7D/plans/demo/task_plan.md" 2>/dev/null || true)"
n7="$(grep -cF '[template-sense]' <<<"$out7" || true)"
if [ "$p7" -ge 1 ] && [ "$s7" = 0 ] && [ "$g7" = 0 ] && [ "$n7" = 0 ]; then
    ok 7 "mini 档空类型 → mini-lite 产物带标记, 无感知区块、无 general 注释（CR P1-1 负例通过）"
else
    bad 7 "mini 档误触发/缺标记: mini-lite 计 $p7, 区块计 $s7, general 注释计 $g7, 输出 [template-sense] 计 $n7"
fi

# case-8 CR-fix 负例: 先 bugfix 再空类型重跑 → 产物标记仍 bugfix 且无感知区块（P1-2 消除, 幂等/来源双守卫）
T8D="$(mktemp -d /tmp/tsense-case8.XXXXXX)"; T_DIRS="$T_DIRS $T8D"
mkdir -p "$T8D/plans/demo"
out8a="$(run_init "$T8D" "bugfix")"
out8b="$(run_init "$T8D" "")"
b8="$(grep -cF 'template_type: bugfix' "$T8D/plans/demo/task_plan.md" 2>/dev/null || true)"
s8="$(grep -cF '🔁 模板感知' "$T8D/plans/demo/task_plan.md" 2>/dev/null || true)"
g8="$(grep -cF 'template_type: general' "$T8D/plans/demo/task_plan.md" 2>/dev/null || true)"
n8b="$(grep -cF '[template-sense]' <<<"$out8b" || true)"
if [ "$b8" -ge 1 ] && [ "$s8" = 0 ] && [ "$g8" = 0 ] && [ "$n8b" = 0 ]; then
    ok 8 "bugfix 后空类型重跑 → 产物标记仍 bugfix 且无感知区块（CR P1-2 负例通过）"
else
    bad 8 "重跑误追加: bugfix 标记计 $b8, 区块计 $s8, general 注释计 $g8, 二次输出 [template-sense] 计 $n8b"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
