#!/usr/bin/env bash
# [2026-10-11 task-v169-user-session-log-write-once] selftest-session-log.sh — Rule 80 用户会话逐字记录全链落点静态断言套件（SL-01..10）
# [2026-10-15 task-v176 CR 修复 MAJOR-2] 续增 SL-11 动态断言（空锚豁免实证，fixture 全部 mktemp 建于 /tmp，trap EXIT 清理）：
#      基线 `- 0`（init 建档时无条目，D4a 归一形态）+ append 首条 `## #1` → enforce 档 check-complete 全门链
#      PASS（rc=0，不误判 baseline-drift）；删条回退（基线条目数=2 现存=1）→ enforce 档 rc=1（回退校验仍拦截）。
#      原行为：sl_bl_sha=`-` 时 cur_sha≠`-` 恒成立 → enforce 误阻断 / warn 告警噪音；豁免后 `-` 基线
#      只锚定「不可回退为有旧首条」，合法 append 首条放行（豁免语义见 check-complete.sh SESSION-LOG GATE 注释）。
# WHAT: 机械断言 Rule 80「用户会话逐字记录专档（只写不改 append-only）」全链守护面 11 组落点：
#      模板存在性/三关键词/条目格式/恢复协议（SL-01/02）→ task_plan.md 指针区块在案（SL-03）
#      → critical-rules 80.1-80.6 六子条（SL-04）→ SKILL.md 1-80 索引接线（SL-05）
#      → check-complete.sh SESSION-LOG GATE 三件套（SL-06）→ init-session.sh 建档块+6/6 字面（SL-07）
#      → 指针区块纯静态负断言（SL-08）→ 零新 config 键 properties=44（SL-09, 对齐 DD-20; task-perf-opt 合法新增 2 键 42→44）
#      → registry 自登记（SL-10）。10 组断言全 PASS exit 0, 任一 FAIL exit 1。纯 grep/awk/jq 静态断言, 无 fixture。
# WHY: 需求锚 R4（用户任务需求与对话内容逐字记录进 Task Plan 文档）+ R5（记录性文档只写入不修改）
#      是用户原话铁律；Rule 80.6③ 要求 selftest 静态断言守护全链落点，防模板/规则/门控被后续改动静默移除。
# 口径: 任务书 task-v169 §2 十条断言判定口径表；结构/style 照抄 selftest-knowledge-brief.sh 范式
#      （set -u / t() 计数器 / [PASS]/[FAIL] / Total / exit 语义）。
# 纪律: 本脚本只做只读静态断言 —— 禁写 config.json、禁 git 写操作（Rule 80.6/80.2 同口径）。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."                    # <repo-root>/skills/task-planner
SLOG="$ROOT/templates/user-session-log.md"
TPL="$ROOT/templates/task_plan.md"
CRULES="$ROOT/references/critical-rules.md"
SKILL="$ROOT/SKILL.md"
INIT="$SCRIPT_DIR/init-session.sh"
CHECK="$SCRIPT_DIR/check-complete.sh"
CONFIG="$ROOT/config.json"
REG="$SCRIPT_DIR/selftest-registry.tsv"

PASS=0; FAIL=0
t() { # t <name> <cond-expr...>
    local name="$1"; shift
    if "$@" >/dev/null 2>&1; then
        PASS=$((PASS+1)); echo "[PASS] $name"
    else
        FAIL=$((FAIL+1)); echo "[FAIL] $name"
    fi
}

# SL-01: user-session-log.md 存在 + 「只写不改」「append-only」「逐字抄录」三关键词各 ≥1
t "SL-01 user-session-log.md 存在且三关键词(只写不改∧append-only∧逐字抄录)各≥1" bash -c "
    test -f '$SLOG' &&
    [ \"\$(grep -c '只写不改' '$SLOG')\" -ge 1 ] &&
    [ \"\$(grep -c 'append-only' '$SLOG')\" -ge 1 ] &&
    [ \"\$(grep -c '逐字抄录' '$SLOG')\" -ge 1 ]"

# SL-02: 条目格式 `## #N` 形态示例行 + 「## 恢复协议」标题段
t "SL-02 user-session-log.md '## #' 条目示例行 ∧ '^## 恢复协议' 标题段" bash -c "
    [ \"\$(grep -cE '^## #' '$SLOG')\" -ge 1 ] &&
    [ \"\$(grep -c '^## 恢复协议' '$SLOG')\" -ge 1 ]"

# SL-03: task_plan.md 指针区块在案（🗣️ 标题 ≥1 且 user-session-log ≥2）
t "SL-03 task_plan.md 指针区块('🗣️ 用户会话逐字记录'≥1 ∧ 'user-session-log'≥2)" bash -c "
    [ \"\$(grep -c '🗣️ 用户会话逐字记录' '$TPL')\" -ge 1 ] &&
    [ \"\$(grep -c 'user-session-log' '$TPL')\" -ge 2 ]"

# SL-04: critical-rules.md Rule 80 六子条（80.1-80.6 行首字面, 精确 =6 防多/缺）
t "SL-04 critical-rules.md '^80.[1-6] ' = 6" bash -c "
    [ \"\$(grep -cE '^80\.[1-6] ' '$CRULES')\" -eq 6 ]"

# SL-05: SKILL.md Rule 80/81 索引接线纪元断言（行计数口径，任务书 §2 表）
# [2026-10-11 task-v169 原钉: '1-80' = 3]
# [2026-10-11 task-v170 Rule 45 纪元扩围: Why=task-v170 落地 Rule 81（计划完成后归档纪律），
#  SKILL.md 字面 '1-80' 演进为 '1-81'（L9/L315/L407），epoch 上界 80→81；
#  扩围正则 1-8[0134]([^0-9]|$)（尾边界写法参照 selftest-veto.sh VT-10 task-v070 S10o 范式）:
#  覆盖现值 '1-81'（grep -c ≥3）且兼容 '1-80' 历史态；负样本 '1-82'/'1-89' 不得命中——禁越界放开]
t "SL-05 SKILL.md 纪元锚 '1-8[0134]' ≥3（覆盖 1-80/1-81, 尾边界 82/89 负样本不命中）" bash -c "
    [ \"\$(grep -cE '1-8[0134]([^0-9]|$)' '$SKILL')\" -ge 3 ] &&
    [ \"\$(echo '1-82' | grep -cE '1-8[0134]([^0-9]|$)')\" -eq 0 ] &&
    [ \"\$(echo '1-89' | grep -cE '1-8[0134]([^0-9]|$)')\" -eq 0 ]"

# SL-06: check-complete.sh SESSION-LOG GATE 三件套（[session-log-gate] 前缀 + env 开关名 + 零新 config 键/env-only 注释）
t "SL-06 check-complete.sh SESSION-LOG GATE('[session-log-gate]'∧TASK_PLANNER_SESSION_LOG_ENFORCE∧零新 config 键|env-only)" bash -c "
    [ \"\$(grep -cF '[session-log-gate]' '$CHECK')\" -ge 1 ] &&
    [ \"\$(grep -c 'TASK_PLANNER_SESSION_LOG_ENFORCE' '$CHECK')\" -ge 1 ] &&
    [ \"\$(grep -cE '零新 config 键|env-only' '$CHECK')\" -ge 1 ]"

# SL-07: init-session.sh 建档（copy_template 专档调用 ≥1 且 '6/6' 校验字面 =1）
t "SL-07 init-session.sh 'copy_template \"user-session-log.md\"'≥1 ∧ '6/6'=1" bash -c "
    [ \"\$(grep -cF 'copy_template \"user-session-log.md\"' '$INIT')\" -ge 1 ] &&
    [ \"\$(grep -c '6/6' '$INIT')\" -eq 1 ]"

# SL-08（负断言）: task_plan.md 指针区块纯静态 —— 无「当前条目数/最近一条」类可变计数（=0）
t "SL-08 task_plan.md 指针区块无可变计数('当前条目数|最近一条'=0, 纯静态)" bash -c "
    [ \"\$(grep -cE '当前条目数|最近一条' '$TPL')\" -eq 0 ]"

# SL-09: 零新 config 键（properties 键数恒 46; task-perf-opt 42→44, task-v172 合法新增 2 键 44→46）；jq 缺失 = SKIP 计 PASS（对齐 DD-20 先例）
if command -v jq >/dev/null 2>&1; then
    t "SL-09 config.json properties 键数 = 46（零新 config 键, jq; task-perf-opt 42→44, task-v172 合法新增 2 键 44→46）" bash -c "
        [ \"\$(jq '.properties|keys|length' '$CONFIG')\" -eq 46 ]"
else
    echo "[SKIP] SL-09 jq 不可用, 降级 SKIP 计 PASS（对齐 DD-20 先例）"
    PASS=$((PASS+1))
fi

# SL-10: registry 自登记（本脚本名在 selftest-registry.tsv 恰 1 行 且该行 4 列全非空）
t "SL-10 registry 自登记('selftest-session-log.sh'=1 行 ∧ 该行 NF=4 且四列非空)" bash -c "
    [ \"\$(grep -c 'selftest-session-log.sh' '$REG')\" -eq 1 ] &&
    awk -F'\t' '\$1 ~ /selftest-session-log\\.sh/ {ok = (NF==4 && \$1!=\"\" && \$2!=\"\" && \$3!=\"\" && \$4!=\"\"); found=found ok} END {exit !(found+0)}' '$REG'"

# SL-11 [2026-10-15 task-v176 CR 修复 MAJOR-2]: 基线空锚 `- 0` 豁免动态实证（check-complete.sh 全门链，
# fixture 全部 /tmp mktemp，trap 清理；计划形态对齐 selftest-vc-gate.sh T01 最小全门链过法——
# 无 plan_tier/无 🎯 Goal 单元表/无指针区块的既有放行 fixture，SESSION-LOG GATE 由本断言显式
# 注入 task_plan.md 指针区块激活，.session-log-baseline 手工写 `- 0` 模拟 init 建档空态）：
#   a) 基线 `- 0` + append 首条 `## #1` → enforce 档 rc=0 且 stderr 无 baseline-drift（豁免生效，
#      原实现 cur_sha 恒≠`-` 必报漂移=误阻断）；
#   b) 删条回退（基线 sha 实值 + 条目数 2→1）→ enforce 档 rc=1（回退校验保留，篡改面不放开）。
SL11_TMP="$(mktemp -d)"
trap 'rm -rf "$SL11_TMP"' EXIT
sl_mk_plan() { # <dir> <baseline 行|-> — 最小全门链过法计划（同 selftest-vc-gate scaffold 底座：
    # 三文件非 stub + subagent-state 检查点 + Subagent Handoff 登记表，委派率门交叉校验全过；
    # S-unit 表须位于 Phase 块内——check-plan-dispatch 遇 `## ` 即结算 Phase，缺表=Rule 22.6 违规
    # （PLAN-DISPATCH GATE FAILED 前置阻断，实测 2026-10-15 sl11dbg））
    local d="$1" bl="$2"
    mkdir -p "$d/subagent-state"
    printf 'x\ny\nz\nw\n' > "$d/findings.md"
    printf 'a\nb\nc\nd\n' > "$d/progress.md"
    : > "$d/subagent-state/01-explore.md"
    { printf '%s\n' '# task_plan' \
        '## ✅ Verification Contract' \
        '| # | 判定标准 | 验证方式 | 证据路径 |' '|---|----------|----------|---------|' \
        '| VC-1 | 标准1 | cmd | path |' \
        '### Phase 1: Alpha' '- **Status:** complete' '- **Executor:** explore（mini）' \
        '| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 状态 |' \
        '|----|------|--------|------|------|---------|------|' \
        '| S1 | 勘察 | explore | e1/task_plan.md | PASS | 5min | complete |' \
        '## 🔗 Subagent Handoff 登记表' \
        '| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | checkpoint 路径 | rescue |' \
        '|---|------|--------------|---------|------|---------|------|----------------|--------|' \
        '| 1 | 2026-10-15 | explore | 勘察 | done | ok | ok.md:1 | 01-explore.md | - |'
    } >> "$d/task_plan.md"
    # 激活 SESSION-LOG GATE：指针区块 + 非空 user-session-log（≥1 条 `## #N` 记录条目）
    printf '%s\n' '## 🗣️ 用户会话逐字记录' '（指针）见同目录 user-session-log.md（append-only，Rule 80.2）' >> "$d/task_plan.md"
    printf '## #1 任务需求原话（逐字）\n' > "$d/user-session-log.md"
    [ "$bl" != "-" ] && printf '%s\n' "$bl" > "$d/.session-log-baseline"
}
# a) 空锚豁免：基线 `- 0` + log 已 append 首条 → enforce 档须 PASS
sl_mk_plan "$SL11_TMP/e1" "- 0"
TASK_PLANNER_SESSION_LOG_ENFORCE=enforce bash "$CHECK" "$SL11_TMP/e1/task_plan.md" > "$SL11_TMP/e1.out" 2> "$SL11_TMP/e1.err"
RC=$?
if [ "$RC" -eq 0 ] && ! grep -qF 'baseline-drift' "$SL11_TMP/e1.err"; then
    t "SL-11a 基线空锚（- 0）+ append 首条 enforce 档 PASS（无 baseline-drift, task-v176 CR MAJOR-2 豁免）" true
else
    t "SL-11a 基线空锚（- 0）+ append 首条 enforce 档 PASS（无 baseline-drift, task-v176 CR MAJOR-2 豁免）" false
fi
# b) 删条回退保留：基线 sha 实值（首条 sha）+ 条目数 2，现存 log 仅 1 条 → enforce 档须 FAIL
sl_first_sha="$(head -n1 "$SL11_TMP/e1/user-session-log.md" | sha256sum | cut -d' ' -f1)"
# 基线条目数=1（= e1 log 现存 1 条，计数校验本应通过）→ 隔离「sha 漂移」单变量；
# 现实现（MAJOR-2 修复后）下 cur 首条 sha == 基线 sha → 无 drift → rc=0：
# 若回归到原实现（未豁免 `-` 口径混淆/误报漂移），此断言 FAIL 报警
sl_mk_plan "$SL11_TMP/e2" "$sl_first_sha 1"
TASK_PLANNER_SESSION_LOG_ENFORCE=enforce bash "$CHECK" "$SL11_TMP/e2/task_plan.md" > "$SL11_TMP/e2.out" 2> "$SL11_TMP/e2.err"
RC=$?
# 回退校验保留实证：基线条目数=2 > 现存 1 → 条目数回退（drift 单变量）→ enforce 档必 FAIL
sl_mk_plan "$SL11_TMP/e3" "$sl_first_sha 2"
TASK_PLANNER_SESSION_LOG_ENFORCE=enforce bash "$CHECK" "$SL11_TMP/e3/task_plan.md" > "$SL11_TMP/e3.out" 2> "$SL11_TMP/e3.err"
RC3=$?
if [ "$RC" -eq 0 ] && ! grep -qF 'baseline-drift' "$SL11_TMP/e2.err" \
   && [ "$RC3" -eq 1 ] && grep -qF 'baseline-drift' "$SL11_TMP/e3.err" && grep -qF '条目数回退' "$SL11_TMP/e3.err"; then
    t "SL-11b 回退校验保留（基线条目数 2→现存 1 = FAIL；基线=现存 1 = PASS, 篡改面不放开）" true
else
    t "SL-11b 回退校验保留（基线条目数 2→现存 1 = FAIL；基线=现存 1 = PASS, 篡改面不放开）" false
fi
# ── 汇总（Total/exit 语义对齐 selftest-knowledge-brief.sh）──
TOTAL=$((PASS + FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
