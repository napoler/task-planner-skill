#!/usr/bin/env bash
# selftest-evidence-anchor.sh — P-01「证据锚真实性检查」行为级 + 静态守护（EA-01..EA-20）
#
# What（守护对象 + 运行方式）:
#   守护 P-01 全链落点，26 条编号断言，分五组：
#     · 静态锚（EA-01..EA-04）: check-evidence-anchor.sh 在位/可执行/bash -n 通过 + 头注 What/Why 双层
#       （Rule 45）+ `[evidence-anchor]` 输出前缀与 exit 语义锚 + registry 自登记 =1。
#     · 判定器行为级（EA-05..EA-14，mktemp 自建夹具，零外部依赖）:
#         EA-05 负例 系统路径 `/etc/hostname` → rc=1 + provenance:system-prefix（关掉张冠李戴）
#         EA-06 负例 死路径 `/tmp/<不存在>.md` → rc=1 + 路径不存在
#         EA-07 负例 行号越界（plan-dir 内文件 :9999）→ rc=1 + 行号越界
#         EA-08 负例 否定字面尾随空格（`无 `）→ rc=1（trim 击穿修复，探测·产出质量 实测形态）
#         EA-09 正例 真实路径 + 合法行号 → rc=0
#         EA-10 负例 域外（仓内无关文件，不在 scope 表）→ rc=1 + 域外路径
#         EA-11 正例 域外但 scope 表已列 → rc=0（写法不同不误判）
#         EA-12 正例 /tmp scratch 豁免 → rc=0
#         EA-13 goal 源负例（progress.md [goal:G1] 指向 /etc/hostname）→ rc=1；同夹具 --source=coverage
#               → rc=0（源隔离：两源互不代偿）
#         EA-14 机器落盘证据（plan-dir/evidence/VC-1.out）：无 VC/时间戳头 → rc=1；补头 → rc=0
#     · 伴生 c 行为级（EA-15）: run-verification.sh 跑夹具 → <plan-dir>/evidence/VC-N.out 生成且头含
#       VC 编号 + ISO8601 时间戳（机器产出契约）。
#     · 接线端到端（EA-16..EA-20，check-complete.sh 真链）:
#         EA-16 缺陷夹具（R-COVERAGE 证据格=/etc/hostname）enforce 档 → rc=1 且 stderr 含 [evidence-anchor]
#               （P-01 verify ① 的机器锚：真实链端到端 exit 1，非仅新脚本自带夹具自绿）
#         EA-17 干净夹具 → stderr 不含 `EVIDENCE-ANCHOR FAILED`（正例不误拦）
#         EA-18 接线静态锚: `run_evidence_anchor coverage`/`run_evidence_anchor goal` 各 =1 +
#               shell-out 调用行不含 `2>/dev/null`（终审意见 3：接线不得挂起 + 诊断不得静默）+
#               config.json evidence_anchor_enforce 在位且 default=enforce
#         EA-19 warn 档不阻断（同缺陷夹具 warn → stderr 含 EVIDENCE-ANCHOR WARNING，且无 FAILED 行）
#         EA-20 负断言: 判定器零 python 依赖（`python3` 字面 =0，纯 bash 实现承诺）
#     · CLAIM_MATCH 内容核对层（CLAIM-01..CLAIM-06，task-v184-S7，mktemp 夹具）:
#         CLAIM-01 不符+默认 warn 档（声明 Total:90 PASS=90 vs 文件 Total:80 PASS=80）→ rc=0 + ⚠
#         CLAIM-02 同夹具 enforce 档 → rc=1 + ✗（✗ 计入 FAIL）
#         CLAIM-03 相符（声明与文件一致）→ 无 mismatch 行 rc=0
#         CLAIM-04 有声明串无路径 token → SKIP 不算误报 rc=0
#         CLAIM-05 off 档 → 整层跳过无 CLAIM 输出
#         CLAIM-06 零声明面夹具 → 输出与 CLAIM_MATCH 加入前等价（无新增行）
#   运行方式: `bash scripts/selftest-evidence-anchor.sh`；逐行打印 `EA-NN/CLAIM-NN PASS/FAIL <说明>`，
#   末行 `Total: N PASS=x FAIL=y`；全 PASS exit 0，任一 FAIL exit 1。夹具全部 mktemp 于 /tmp 并跑毕即删。
#
# Why（机制锚）:
#   根因（终审意见 7）=check-complete.sh 的 R-COVERAGE 证据格判定仅「字符串非空 ∧ 非否定字面」，
#   goal-gate 三要素可叙述代偿——证据格写 `/etc/hostname` 或死路径仍 exit=0，痛点属「发现不了」。
#   P-01 把证据锚升级为「可定位 + 可归属 + 机器可判」三层判定；本脚本锁三件事：
#     ① 判定器行为（正/负例双向：负例必拦、正例不误伤——防把痛点换成误报面）；
#     ② 接线不挂起（EA-16 走 check-complete 真链，复刻 periodic-review「脚本在位无人调用=发货即死」防线）；
#     ③ 机器产出契约（EA-14/EA-15：evidence/VC-N.out 头 = VC 编号 + 时间戳，让「无法伪造」有落点）。
#   断言面只锁 P-01 新增锚，不触碰既有 selftest 断言行（Rule 36.5 纯增量）。
# 依赖: bash + awk + grep/sed + jq（EA-18 读 config 键；jq 缺失该条打 SKIPPED 计 PASS，fail-open 非静默，
#       与 selftest-context-pressure CP-09 / selftest-decision-drift DD-20 先例一致）。只读仓库 + 写 /tmp 夹具。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$SKILL_ROOT/../.." && pwd)"
EA="$SCRIPT_DIR/check-evidence-anchor.sh"
CC="$SCRIPT_DIR/check-complete.sh"
REG="$SCRIPT_DIR/selftest-registry.tsv"
CONFIG="$SKILL_ROOT/config.json"
RUNV="$SKILL_ROOT/../verification-gate/scripts/run-verification.sh"
SELF="$SCRIPT_DIR/selftest-evidence-anchor.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'EA-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'EA-%s FAIL %s\n' "$1" "$2"; }

# ── 夹具构造器（两处复用：standalone 判定器夹具 + check-complete 端到端夹具）──────────
# make_fixture <dir> <R1证据区> [scope行]
#   task_plan.md = 🎯 R1/R2 + VC 表 5 行 + Phase(complete, V-N×2) + Decisions Made
#                 + （可选）「执行范围限制」段（scope行 非空时才写 → 空段 = 无 scope 表 = 域外层跳过）
#   delivery-summary.md = 需求覆盖核对表（R1=证据区参数, R2=covered 真实路径）
make_fixture() {
    local d="$1" ev="$2" scope="${3:-}"
    mkdir -p "$d"
    {
        printf '%s\n' \
            '# Task Plan: P-01 selftest fixture' \
            '' \
            '## 🎯 用户需求原文（Rule 51.1 锚定）' \
            '' \
            '- **R1**: 「需求一：证据锚真实性检查落地（covered，证据见 delivery-summary 核对表）。」' \
            '- **R2**: 「需求二：机器落盘证据契约（covered）。」' \
            '' \
            '## VC 表' \
            '| VC | 验证判据 |' \
            '|----|----------|' \
            '| VC-1 | 证据锚三层判定（存在/行界/provenance） |' \
            '| VC-2 | 否定字面 trim 后判定 |' \
            '| VC-3 | 域外路径归属判定 |' \
            '| VC-4 | 机器落盘 evidence/ 头契约 |' \
            '| VC-5 | 接线端到端不挂起 |' \
            '' \
            '## Phases' \
            '' \
            '### Phase 1: 夹具执行' \
            '- **Status:** complete' \
            '- **Executor:** 主进程（白名单②计划系统文件）' \
            '- [x] V-1.1: VC-1（证据=夹具跑批输出）' \
            '- [x] V-1.2: VC-2（证据=夹具跑批输出）' \
            '' \
            '## Decisions Made' \
            '| 时间 | 决策 | 依据 |' \
            '|------|------|------|' \
            '| selftest | 无额外决策 | 本夹具 |'
        if [ -n "$scope" ]; then
            printf '%s\n' \
                '' \
                '## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）' \
                '| 类别 | 允许的文件 | 禁止 |' \
                '|------|------------|------|' \
                "| 源码 | $scope | 其他 |"
        fi
    } > "$d/task_plan.md"
    # 证据区里的「:行号」用真文件行数内/越界由调用方控制；R2 恒为夹具内真实文件
    {
        printf '%s\n' \
            '# delivery-summary（P-01 fixture）' \
            '' \
            '## 需求覆盖核对（Rule 51.3）' \
            '| 需求# | 用户原话（摘） | 判定 | 证据路径 |' \
            '|-------|--------------|------|---------|' \
            "| R1 | 需求一 | **covered** | $ev |" \
            '| R2 | 需求二 | **covered** | artifact.md:1 |'
    } > "$d/delivery-summary.md"
    printf '%s\n' '# artifact' 'line2' 'line3' > "$d/artifact.md"
    {
        printf '%s\n' \
            '# findings（P-01 fixture）' \
            '' \
            '- 夹具目标：证据锚三层判定的正/负例双向锁定' \
            '- 负例面：系统路径/死路径/行号越界/否定字面/域外 五类' \
            '- 正例面：真实路径+合法行号/scope 表已列/tmp scratch/机器落盘头齐备'
    } > "$d/findings.md"
    {
        printf '%s\n' \
            '# progress（P-01 fixture）' \
            '' \
            '### Phase 1: 夹具执行' \
            '- [x] 完成：夹具构造与判定器跑批（证据=ea.out/ea.err 留证）'
    } > "$d/progress.md"
}

# ── EA-01 判定器在位 + 可执行 + bash -n ────────────────────────────────────────
if [ -f "$EA" ] && [ -x "$EA" ] && bash -n "$EA" 2>/dev/null; then
    ok 01 "check-evidence-anchor.sh 在位 + 可执行 + bash -n 通过"
else
    bad 01 "check-evidence-anchor.sh 缺失/不可执行/语法错（在位=$([ -f "$EA" ] && echo yes || echo no) 可执行=$([ -x "$EA" ] && echo yes || echo no)）"
fi

# ── EA-02 头注 What/Why 双层注释（Rule 45）────────────────────────────────────
if grep -q '^# What' "$EA" && grep -q '^# Why' "$EA"; then
    ok 02 "头注 What + Why 双层注释齐备（Rule 45）"
else
    bad 02 "头注缺 What 或 Why（Rule 45 双层注释不齐）"
fi

# ── EA-03 输出前缀 + exit 语义锚 ──────────────────────────────────────────────
if grep -q '\[evidence-anchor\] ✗' "$EA" && grep -qE '^[[:space:]]*exit 1' "$EA" && grep -qE '^[[:space:]]*exit 0' "$EA"; then
    ok 03 "输出前缀 [evidence-anchor] ✗ + exit 0/1 语义锚在位"
else
    bad 03 "输出前缀或 exit 语义锚缺失（门控输出契约不齐）"
fi

# ── EA-04 registry 自登记 =1 ─────────────────────────────────────────────────
_n="$(grep -c 'selftest-evidence-anchor.sh' "$REG" 2>/dev/null || true)"
if [ "${_n:-0}" -ge 1 ]; then
    ok 04 "selftest-registry.tsv 含本脚本登记行（n=$_n）"
else
    bad 04 "selftest-registry.tsv 缺 selftest-evidence-anchor.sh 登记行（回归不运行本守护）"
fi

# ── EA-05 负例 系统路径 /etc/hostname ────────────────────────────────────────
F5="$(mktemp -d "${TMPDIR:-/tmp}/ea5.XXXXXX")"
make_fixture "$F5" '/etc/hostname'
_o="$(bash "$EA" "$F5" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q 'system-prefix'; then
    ok 05 "负例 系统路径 /etc/hostname → rc=1 + provenance:system-prefix"
else
    bad 05 "系统路径未被拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F5"

# ── EA-06 负例 死路径（/tmp 下不存在的 .md）──────────────────────────────────
DEAD="${TMPDIR:-/tmp}/ea-dead-$$-notexist.md"
rm -f "$DEAD"
F6="$(mktemp -d "${TMPDIR:-/tmp}/ea6.XXXXXX")"
make_fixture "$F6" "$DEAD"
_o="$(bash "$EA" "$F6" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q '路径不存在'; then
    ok 06 "负例 死路径 $DEAD → rc=1 + 路径不存在"
else
    bad 06 "死路径未被拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F6"

# ── EA-07 负例 行号越界（夹具内 artifact.md 共 3 行，引用 :9999）───────────────
F7="$(mktemp -d "${TMPDIR:-/tmp}/ea7.XXXXXX")"
make_fixture "$F7" 'artifact.md:9999'
_o="$(bash "$EA" "$F7" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q '行号越界'; then
    ok 07 "负例 行号越界 artifact.md:9999 → rc=1 + 行号越界"
else
    bad 07 "行号越界未被拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F7"

# ── EA-08 负例 否定字面尾随空格（`无 ` 击穿修复）──────────────────────────────
F8="$(mktemp -d "${TMPDIR:-/tmp}/ea8.XXXXXX")"
make_fixture "$F8" '无 '   # 尾随空格 = 探测·产出质量 实测击穿形态
_o="$(bash "$EA" "$F8" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q '否定字面'; then
    ok 08 "负例 证据格「无 」(尾随空格) → rc=1 + 否定字面（trim 后判定，击穿修复）"
else
    bad 08 "尾随空格否定字面未被拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F8"

# ── EA-09 正例 真实路径 + 合法行号 → rc=0 ───────────────────────────────────
F9="$(mktemp -d "${TMPDIR:-/tmp}/ea9.XXXXXX")"
make_fixture "$F9" 'artifact.md:2'
_o="$(bash "$EA" "$F9" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ]; then
    ok 09 "正例 真实路径+合法行号 → rc=0（摘要: $(printf '%s' "$_o" | tail -1)）"
else
    bad 09 "正例被误拦: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F9"

# ── EA-10 负例 域外（仓内无关文件，不在 scope 表）──────────────────────────
F10="$(mktemp -d "${TMPDIR:-/tmp}/ea10.XXXXXX")"
make_fixture "$F10" 'skills/task-planner/scripts/check-scope.sh' 'skills/task-planner/scripts/other.sh'
_o="$(bash "$EA" "$F10" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q '域外路径'; then
    ok 10 "负例 域外（仓内无关文件未入 scope 表）→ rc=1 + 域外路径"
else
    bad 10 "域外路径未被拦截: rc=$_rc（应 1）输出=$_o"
fi
rm -rf "$F10"

# ── EA-11 正例 域外但 scope 表已列 → rc=0（写法不同不误判）──────────────────
F11="$(mktemp -d "${TMPDIR:-/tmp}/ea11.XXXXXX")"
make_fixture "$F11" 'skills/task-planner/scripts/check-scope.sh' 'skills/task-planner/scripts/check-scope.sh'
_o="$(bash "$EA" "$F11" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ]; then
    ok 11 "正例 域外路径已在「执行范围限制」表 → rc=0"
else
    bad 11 "scope 表已列路径被误拦: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F11"

# ── EA-12 正例 /tmp scratch 豁免 → rc=0 ─────────────────────────────────────
SCRATCH="$(mktemp "${TMPDIR:-/tmp}/ea-scratch-XXXXXX.log" 2>/dev/null || true)"
F12="$(mktemp -d "${TMPDIR:-/tmp}/ea12.XXXXXX")"
if [ -n "$SCRATCH" ]; then
    make_fixture "$F12" "$SCRATCH" 'skills/task-planner/scripts/other.sh'
    _o="$(bash "$EA" "$F12" 2>&1)"; _rc=$?
    if [ "$_rc" -eq 0 ]; then
        ok 12 "正例 /tmp scratch 豁免 → rc=0"
    else
        bad 12 "/tmp scratch 被误拦: rc=$_rc（应 0）输出=$_o"
    fi
else
    ok 12 "SKIPPED：mktemp /tmp scratch 文件创建失败（环境降级非内容漂移）"
fi
rm -rf "$F12"; [ -n "$SCRATCH" ] && rm -f "$SCRATCH"

# ── EA-13 goal 源负例 + 源隔离（--source）───────────────────────────────────
F13="$(mktemp -d "${TMPDIR:-/tmp}/ea13.XXXXXX")"
make_fixture "$F13" 'artifact.md:1'
printf '%s\n' '- [goal:G1] 证据: /etc/hostname' >> "$F13/progress.md"
_o="$(bash "$EA" "$F13" --source=goal 2>&1)"; _rc=$?
_oc="$(bash "$EA" "$F13" --source=coverage 2>&1)"; _rcc=$?
if [ "$_rc" -eq 1 ] && [ "$_rcc" -eq 0 ]; then
    ok 13 "goal 源负例 rc=1 + 同夹具 --source=coverage rc=0（源隔离不互相代偿）"
else
    bad 13 "goal 源判定或源隔离异常: goal_rc=$_rc（应 1） coverage_rc=$_rcc（应 0）输出=$_o"
fi
rm -rf "$F13"

# ── EA-14 机器落盘 evidence/ 头契约（无头 → rc=1；补头 → rc=0）──────────────
F14="$(mktemp -d "${TMPDIR:-/tmp}/ea14.XXXXXX")"
make_fixture "$F14" 'evidence/VC-1.out'
mkdir -p "$F14/evidence"
printf '%s\n' 'raw output without header' > "$F14/evidence/VC-1.out"
_o="$(bash "$EA" "$F14" 2>&1)"; _rc=$?
printf '%s\n' '# [run-verification] VC-1 | 2026-10-16T00:00:00Z | cmd: x' '# ---- stdout/stderr ----' 'ok' > "$F14/evidence/VC-1.out"
_o2="$(bash "$EA" "$F14" 2>&1)"; _rc2=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -q '机器落盘证据缺' && [ "$_rc2" -eq 0 ]; then
    ok 14 "机器落盘证据头契约：无头 rc=1（缺 VC/时间戳）+ 补头 rc=0"
else
    bad 14 "机器落盘头契约异常: 无头_rc=$_rc（应 1）补头_rc=$_rc2（应 0）输出=$_o"
fi
rm -rf "$F14"

# ── EA-15 伴生 c：run-verification.sh 落盘 evidence/VC-N.out（头含 VC+时间戳）──
if [ -f "$RUNV" ]; then
    F15="$(mktemp -d "${TMPDIR:-/tmp}/ea15.XXXXXX")"
    {
        printf '%s\n' \
            '- [ ] VC-1' \
            '  **Verify command**: echo ea15-landed' \
            '' \
            '- [ ] VC-2' \
            '  **Verify command**: exit 3'
    } > "$F15/verification.md"
    bash "$RUNV" "$F15" >/dev/null 2>&1
    if [ -f "$F15/evidence/VC-1.out" ] \
       && head -n 3 "$F15/evidence/VC-1.out" | grep -q 'VC-1' \
       && head -n 3 "$F15/evidence/VC-1.out" | grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z' \
       && grep -q 'ea15-landed' "$F15/evidence/VC-1.out" \
       && [ -f "$F15/evidence/VC-2.out" ]; then
        ok 15 "run-verification.sh 落盘 evidence/VC-N.out（头含 VC 编号+ISO8601 时间戳+命令原文输出）"
    else
        bad 15 "run-verification.sh 未落盘合规 evidence/VC-N.out（VC-1 头= $(head -n1 "$F15/evidence/VC-1.out" 2>/dev/null)）"
    fi
    rm -rf "$F15"
else
    bad 15 "run-verification.sh 缺失（$RUNV）——伴生 c 落盘面无载体"
fi

# ── EA-16/EA-17/EA-19 check-complete.sh 真链端到端（缺陷夹具 / 干净夹具 / warn 档）──
# 夹具沿用 RC-19 最小化构造法（VC 表 ≥5 + Phase V-N×2 让 VC-GATE PASS，门控序上才到达本门）；
# VC_GATE 档位置 warn（本组只验 evidence-anchor 的贡献，不让别的门抢先 exit 1）。
F16="$(mktemp -d "${TMPDIR:-/tmp}/ea16.XXXXXX")"
make_fixture "$F16" '/etc/hostname'
env TASK_PLANNER_VC_GATE_ENFORCE=warn TASK_PLANNER_EVIDENCE_ANCHOR_ENFORCE=enforce TASK_PLANNER_RVC_COVERAGE_ENFORCE=off \
    bash "$CC" "$F16/task_plan.md" < /dev/null > "$F16/cc.out" 2> "$F16/cc.err"  # [task-v184-S2b] RVC 单元隔离：本 selftest 测自身门，RVC 交互面由 check-rvc-coverage 注入夹具覆盖
_rc16=$?
if [ "$_rc16" -ne 0 ] && grep -q '\[evidence-anchor\]' "$F16/cc.err" && grep -q 'EVIDENCE-ANCHOR FAILED' "$F16/cc.err"; then
    ok 16 "端到端负例（R-COVERAGE 证据格=/etc/hostname）enforce 档 exit=$_rc16≠0 且 stderr 含 [evidence-anchor]"
else
    bad 16 "端到端负例未拦截: exit=$_rc16（应≠0）stderr 缺 [evidence-anchor]/FAILED（接线挂起？）stderr=$(tail -3 "$F16/cc.err")"
fi
# EA-17 干净夹具（证据=夹具内真实文件 + 合法行号）→ 本门不得报 FAILED
F17="$(mktemp -d "${TMPDIR:-/tmp}/ea17.XXXXXX")"
make_fixture "$F17" 'artifact.md:2'
env TASK_PLANNER_VC_GATE_ENFORCE=warn TASK_PLANNER_EVIDENCE_ANCHOR_ENFORCE=enforce TASK_PLANNER_RVC_COVERAGE_ENFORCE=off \
    bash "$CC" "$F17/task_plan.md" < /dev/null > "$F17/cc.out" 2> "$F17/cc.err"  # [task-v184-S2b] RVC 单元隔离：本 selftest 测自身门，RVC 交互面由 check-rvc-coverage 注入夹具覆盖
if ! grep -q 'EVIDENCE-ANCHOR FAILED' "$F17/cc.err"; then
    ok 17 "端到端正例（证据锚全真实）→ 本门无 FAILED 行（不误拦合法交付）"
else
    bad 17 "端到端正例被本门误拦: $(grep 'EVIDENCE-ANCHOR FAILED' "$F17/cc.err" | head -1)"
fi
# EA-19 warn 档不阻断（同 EA-16 缺陷夹具，档位降 warn）
env TASK_PLANNER_VC_GATE_ENFORCE=warn TASK_PLANNER_EVIDENCE_ANCHOR_ENFORCE=warn TASK_PLANNER_RVC_COVERAGE_ENFORCE=off \
    bash "$CC" "$F16/task_plan.md" < /dev/null > "$F16/ccw.out" 2> "$F16/ccw.err"  # [task-v184-S2b] RVC 单元隔离：本 selftest 测自身门，RVC 交互面由 check-rvc-coverage 注入夹具覆盖
if grep -q 'EVIDENCE-ANCHOR WARNING' "$F16/ccw.err" && ! grep -q 'EVIDENCE-ANCHOR FAILED' "$F16/ccw.err"; then
    ok 19 "warn 档不阻断：stderr 含 EVIDENCE-ANCHOR WARNING 且无 FAILED（三档语义在位）"
else
    bad 19 "warn 档语义异常: $(tail -3 "$F16/ccw.err")"
fi
rm -rf "$F16" "$F17"

# ── EA-18 接线静态锚（两调用点 + 无 2>/dev/null + config 键默认 enforce）────────
_c1="$(grep -c 'run_evidence_anchor coverage' "$CC" 2>/dev/null || true)"
_c2="$(grep -c 'run_evidence_anchor goal' "$CC" 2>/dev/null || true)"
_suppressed="$(grep -c 'check-evidence-anchor.sh.*2>/dev/null' "$CC" 2>/dev/null || true)"
_tier_ok=0
if command -v jq >/dev/null 2>&1; then
    [ "$(jq -r '.properties.evidence_anchor_enforce.default // empty' "$CONFIG" 2>/dev/null)" = "enforce" ] && _tier_ok=1
else
    _tier_ok=1   # jq 缺失：本子项 SKIPPED 计 PASS（环境降级非内容漂移，fail-open 非静默）
fi
if [ "${_c1:-0}" -ge 1 ] && [ "${_c2:-0}" -ge 1 ] && [ "${_suppressed:-0}" -eq 0 ] && [ "$_tier_ok" -eq 1 ]; then
    ok 18 "接线锚：coverage 调用=$_c1 / goal 调用=$_c2 / 2>/dev/null 抑制=${_suppressed}（应 0）/ config 键 default=enforce=$_tier_ok"
else
    bad 18 "接线锚异常：coverage=$_c1 goal=$_c2 抑制=${_suppressed}（应 0）tier_default_ok=$_tier_ok"
fi

# ── EA-20 负断言：判定器零 python 依赖（纯 bash 实现承诺）────────────────────
_np="$(grep -c 'python3' "$EA" 2>/dev/null || true)"
if [ "${_np:-0}" -eq 0 ]; then
    ok 20 "负断言：check-evidence-anchor.sh 无 python3 依赖（纯 bash 实现）"
else
    bad 20 "判定器含 python3 字面 n=$_np（违背纯 bash 实现承诺）"
fi

# ── CLAIM-01..06 CLAIM_MATCH 内容核对层行为级（task-v184-S7）────────────────────
# S6 在 check-evidence-anchor.sh 落地的 CLAIM_MATCH 层（声明串四形态 ↔ 被引证据文件内容核对）
# 在 selftest 侧补行为断言。夹具 /tmp 自建自清理：make_fixture 造 delivery-summary（R1 证据格=
# 声明串+路径 token），追加 ea.md（≥5 行）作被引文件；档位走 env -u（默认）/enforce/off
# （config claim_match_enforce.default=warn 已在 config.json 固化）。逐条期望对照 S6 M3。
okc()  { PASS=$((PASS+1)); printf 'CLAIM-%s PASS %s\n' "$1" "$2"; }
badc() { FAIL=$((FAIL+1)); printf 'CLAIM-%s FAIL %s\n' "$1" "$2"; }

# CLAIM-01 不符+默认 warn 档：R1 证据格声明 Total:90 PASS=90，被引 ea.md 内容为 Total:80 PASS=80
#   → 默认档（env -u，config default=warn）rc=0 且输出含 [claim-mismatch] ⚠
C01="$(mktemp -d "${TMPDIR:-/tmp}/c01.XXXXXX")"
make_fixture "$C01" 'ea.md:5 Total: 90 PASS=90'
printf '%s\n' '# ea fixture' 'line2' 'line3' 'line4' 'Total: 80 PASS=80' > "$C01/ea.md"
_o="$(env -u TASK_PLANNER_CLAIM_MATCH_ENFORCE bash "$EA" "$C01" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && printf '%s' "$_o" | grep -qF '[claim-mismatch] ⚠'; then
    okc 01 "不符+默认 warn 档：rc=0 且输出含 [claim-mismatch] ⚠（声明 90 vs 文件 80）"
else
    badc 01 "异常: rc=$_rc（应 0）/ 缺 [claim-mismatch] ⚠（输出: $(printf '%s' "$_o" | grep 'claim-mismatch' || echo 无)）"
fi

# CLAIM-02 不符+enforce 档：同夹具 env=enforce → rc=1 且含 [claim-mismatch] ✗（✗ 计入 FAIL）
_o="$(env TASK_PLANNER_CLAIM_MATCH_ENFORCE=enforce bash "$EA" "$C01" 2>&1)"; _rc=$?
if [ "$_rc" -eq 1 ] && printf '%s' "$_o" | grep -qF '[claim-mismatch] ✗'; then
    okc 02 "不符+enforce 档：rc=1 且输出含 [claim-mismatch] ✗（✗ 计入 FAIL）"
else
    badc 02 "异常: rc=$_rc（应 1）/ 缺 [claim-mismatch] ✗（输出: $(printf '%s' "$_o" | grep 'claim-mismatch' || echo 无)）"
fi
rm -rf "$C01"

# CLAIM-03 相符：声明 Total:80 PASS=80 与 ea.md 内容一致 → 无 mismatch 行 rc=0
C03="$(mktemp -d "${TMPDIR:-/tmp}/c03.XXXXXX")"
make_fixture "$C03" 'ea.md:5 Total: 80 PASS=80'
printf '%s\n' '# ea fixture' 'line2' 'line3' 'line4' 'Total: 80 PASS=80' > "$C03/ea.md"
_o="$(env -u TASK_PLANNER_CLAIM_MATCH_ENFORCE bash "$EA" "$C03" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && ! printf '%s' "$_o" | grep -q 'claim-mismatch'; then
    okc 03 "相符：声明与文件一致 → 无 mismatch 行 rc=0"
else
    badc 03 "异常: rc=$_rc（应 0）/ 出现 claim-mismatch（输出: $(printf '%s' "$_o" | grep 'claim-mismatch' || echo 无)）"
fi
rm -rf "$C03"

# CLAIM-04 SKIP：R1 证据格有声明串但无路径 token → SKIP 不算误报 rc=0
C04="$(mktemp -d "${TMPDIR:-/tmp}/c04.XXXXXX")"
make_fixture "$C04" 'Total: 90 PASS=90'
_o="$(env -u TASK_PLANNER_CLAIM_MATCH_ENFORCE bash "$EA" "$C04" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && ! printf '%s' "$_o" | grep -q 'claim-mismatch'; then
    okc 04 "SKIP：有声明串无路径 token → 无 mismatch 行 rc=0（不算误报）"
else
    badc 04 "异常: rc=$_rc（应 0）/ 出现 claim-mismatch（输出: $(printf '%s' "$_o" | grep 'claim-mismatch' || echo 无)）"
fi
rm -rf "$C04"

# CLAIM-05 off 档：同 CLAIM-01 不符夹具 env=off → 整层跳过，无 CLAIM 输出 rc=0
C05="$(mktemp -d "${TMPDIR:-/tmp}/c05.XXXXXX")"
make_fixture "$C05" 'ea.md:5 Total: 90 PASS=90'
printf '%s\n' '# ea fixture' 'line2' 'line3' 'line4' 'Total: 80 PASS=80' > "$C05/ea.md"
_o="$(env TASK_PLANNER_CLAIM_MATCH_ENFORCE=off bash "$EA" "$C05" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && ! printf '%s' "$_o" | grep -q 'claim-mismatch'; then
    okc 05 "off 档：整层跳过 → 无 claim-mismatch 输出 rc=0"
else
    badc 05 "异常: rc=$_rc（应 0）/ 出现 claim-mismatch（输出: $(printf '%s' "$_o" | grep 'claim-mismatch' || echo 无)）"
fi
rm -rf "$C05"

# CLAIM-06 既有层零干扰：无声明串的干净夹具 → 输出与 CLAIM_MATCH 加入前等价（无新增行）
C06="$(mktemp -d "${TMPDIR:-/tmp}/c06.XXXXXX")"
make_fixture "$C06" 'artifact.md:2'
_o="$(env -u TASK_PLANNER_CLAIM_MATCH_ENFORCE bash "$EA" "$C06" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && ! printf '%s' "$_o" | grep -q 'claim-mismatch' \
   && printf '%s' "$_o" | grep -q '证据锚全过'; then
    okc 06 "零声明面夹具：无 claim-mismatch 且 ✓ 证据锚全过（输出与 CLAIM_MATCH 加入前等价）"
else
    badc 06 "异常: rc=$_rc（应 0）/ 输出漂移（claim-mismatch: $(printf '%s' "$_o" | grep -c 'claim-mismatch' || true) 条; 全过行: $(printf '%s' "$_o" | grep -c '证据锚全过' || true)）"
fi
rm -rf "$C06"

echo "----------------------------------------------------------------"
echo "[selftest-evidence-anchor] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
