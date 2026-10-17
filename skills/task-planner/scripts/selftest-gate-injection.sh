#!/usr/bin/env bash
# selftest-gate-injection.sh — task-v184-S5c 五门注入式行为回归（GI-01..GI-11）
#
# What（守护对象 + 运行方式）:
#   守护 Phase 2 接线的 5 个判定器在真实门链中的汇聚型行为回归，11 条编号断言：
#     · vc-nonvacuous（GI-01/02/11）: check-complete.sh 门链注入真空 VC 夹具 → rc≠0 含
#       [vc-nonvacuous]；改真实命令 → ✓；env=off → rc 转变不阻断。
#     · rvc-coverage（GI-03/04）: R 行无 R→VC 映射 → rc≠0 含 [rvc-coverage]；映射完整 → ✓。
#     · step-placeholder（GI-05/06）: 占位步骤 → 判定器直测 rc≠0 + attest 静态锚 task-v184-S3；
#       干净步骤 → rc=0。
#     · tier-consistency（GI-07/08）: mini 声明+3 Phase → 判定器直测 rc≠0 + attest 静态锚
#       task-v184-S4；干净 → rc=0。
#     · goal-cjk（GI-09/10）: 跑题夹具 → check-3file-gate.sh 输出含 [goal-cjk] 或 [drift-gate] ✗；
#       干净夹具 → 无 ✗/⚠（[goal-cjk] ✓）。
#   运行方式: `bash scripts/selftest-gate-injection.sh`；逐行打印 `GI-NN PASS/FAIL <说明>`，
#   末行 `Total: N PASS=x FAIL=y`；全 PASS exit 0，任一 FAIL exit 1。夹具全部 mktemp 于 /tmp
#   并跑毕即删（禁残留）。
#
# Why（机制锚）:
#   report §5.1 修订 3 要求验收=「注入缺陷计划→走真实门链 exit 1」可反复重跑。Phase 2 各单元
#   已自带夹具实证（检查点 subagent-state/S1..S5*.md 有配方），但缺汇聚型行为回归——检测器
#   接线进自动门链后，门链消费面（check-complete.sh / check-3file-gate.sh）的行为无回归守护，
#   一旦门链改动误删/误改接线，检测器将「发货即死」（接线断裂无人知）。本脚本锁五门在真实
#   门链中的注入-拦截-放行双向行为，防接线静默断裂。
# 依赖: bash + mktemp + grep + test（夹具零外部依赖，同 selftest-goal-cjk.sh 口径）。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CC="$SCRIPT_DIR/check-complete.sh"
CG="$SCRIPT_DIR/check-3file-gate.sh"
SP="$SCRIPT_DIR/check-step-placeholders.sh"
TC="$SCRIPT_DIR/check-tier-consistency.sh"
ATTEST="$SCRIPT_DIR/attest-plan.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'GI-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'GI-%s FAIL %s\n' "$1" "$2"; }

# 夹具根目录（/tmp 自建自清理，禁残留）
GI_TMP="$(mktemp -d "${TMPDIR:-/tmp}/gi-selftest.XXXXXX")"
trap 'rm -rf "$GI_TMP"' EXIT

# make_vc_fixture <dir> <vacuous|real> — 最小计划四件套（S1 M4 配方：task_plan.md + verification.md
# 5 条 VC + findings/progress ≥3 行）。vacuous=全 `true` 真空命令；real=真实判定命令。
make_vc_fixture() {
    local d="$1" mode="$2"
    mkdir -p "$d"
    cat > "$d/task_plan.md" <<'EOF'
# Task Plan: GI vc-nonvacuous fixture
plan_tier: standard
## Goal
搭建可验证的最小交付链路。
## Phases
### Phase 1: Build
- [x] 实现核心逻辑
- [x] 编写验证脚本
- **V-N:** VC-1, VC-2
- **Status:** complete
## 执行范围限制
| 类别 | 允许的文件 |
|------|-----------|
| 代码 | skills/task-planner/scripts/gi-fixture.md |
## Verification Contract
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 核心逻辑在位 | 文件在位 | /abs/path/core.md |
| VC-2 | 验证脚本可执行 | 命令输出形态 | bash /abs/verify.sh |
| VC-3 | 边界条件通过 | 运行命令 | grep -c PASS out.txt |
| VC-4 | 计数=0 | 计数判据 | wc -l err.txt |
| VC-5 | 无回归破坏 | diff 判据 | git diff --stat |
EOF
    if [ "$mode" = "vacuous" ]; then
        cat > "$d/verification.md" <<'EOF'
# Verification Contract
## Verification Contract
- [ ] VC-1: 核心逻辑在位
  **Verify command**: true
  **Pass criteria**: PASS
  Evidence: /abs/path/core.md
- [ ] VC-2: 验证脚本可执行
  **Verify command**: true
  **Pass criteria**: PASS
  Evidence: /abs/verify.sh
- [ ] VC-3: 边界条件通过
  **Verify command**: true
  **Pass criteria**: PASS
  Evidence: out.txt
- [ ] VC-4: 计数=0
  **Verify command**: true
  **Pass criteria**: PASS
  Evidence: err.txt
- [ ] VC-5: 无回归破坏
  **Verify command**: true
  **Pass criteria**: PASS
  Evidence: git diff
EOF
    else
        # 真实命令（引用本夹具产出物；vc-nonvacuous 为静态字面判定，路径存在与否不影响判定）
        cat > "$d/verification.md" <<EOF
# Verification Contract
## Verification Contract
- [ ] VC-1: 核心逻辑在位
  **Verify command**: test -f "$d/task_plan.md"
  **Pass criteria**: PASS
  Evidence: $d/task_plan.md
- [ ] VC-2: 验证脚本可执行
  **Verify command**: test -f "$d/verification.md"
  **Pass criteria**: PASS
  Evidence: $d/verification.md
- [ ] VC-3: 边界条件通过
  **Verify command**: grep -c 'VC-1' "$d/task_plan.md"
  **Pass criteria**: PASS
  Evidence: $d/task_plan.md
- [ ] VC-4: 计数=0
  **Verify command**: grep -c 'VC-5' "$d/task_plan.md"
  **Pass criteria**: PASS
  Evidence: $d/task_plan.md
- [ ] VC-5: 无回归破坏
  **Verify command**: test -f "$d/findings.md"
  **Pass criteria**: PASS
  Evidence: $d/findings.md
EOF
    fi
    cat > "$d/findings.md" <<'EOF'
# Findings
- 发现1: 核心逻辑实现完成，覆盖主路径。
- 发现2: 验证脚本输出符合预期形态。
- 发现3: 边界条件测试通过，无回归。
EOF
    cat > "$d/progress.md" <<'EOF'
# Progress
- Phase 1 complete: 核心逻辑与验证脚本均已交付。
- [reflect] 反思一: 验证命令需真实引用产出物。
- [reflect] 反思二: 终验复验通过，证据链完整。
EOF
}

# make_rvc_fixture <dir> <with-mapping> — R 行夹具（S2 M3 配方：3 R 行 + 5 VC 真实命令 +
# findings/progress ≥3 行）。with-mapping=补完整 R→VC 映射表。
make_rvc_fixture() {
    local d="$1" with_map="$2"
    mkdir -p "$d"
    {
        printf '%s\n' '# Task Plan: GI rvc-coverage fixture' 'plan_tier: standard' '' '## Goal' \
            '搭建可验证的最小交付链路。' '' '## 🎯 用户需求原文' \
            '- **R1**: 核心逻辑在位且可执行。' '- **R2**: 验证脚本输出符合预期形态。' \
            '- **R3**: 边界条件测试通过无回归。'
        if [ "$with_map" = "yes" ]; then
            printf '%s\n' '' '### R→VC 映射' '' '| R 编号 | 覆盖 VC | 说明 |' \
                '|--------|---------|------|' '| R1 | VC-1, VC-2 | 核心逻辑与验证脚本 |' \
                '| R2 | VC-3, VC-4 | 边界与计数 |' '| R3 | VC-5 | 无回归 |'
        fi
        printf '%s\n' '' '## Phases' '' '### Phase 1: Build' '- [x] 实现核心逻辑' \
            '- [x] 编写验证脚本' '- **V-N:** VC-1, VC-2' '- **Status:** complete' '' \
            '## 执行范围限制' '' '| 类别 | 允许的文件 |' '|------|-----------|' \
            '| 代码 | skills/task-planner/scripts/gi-fixture.md |' '' \
            '## Verification Contract' '' \
            '| # | 判定标准 | 验证方式 | 证据路径/命令 |' \
            '|---|----------|----------|---------------|' \
            '| VC-1 | 核心逻辑在位 | 文件在位 | /abs/path/core.md |' \
            '| VC-2 | 验证脚本可执行 | 命令输出形态 | bash /abs/verify.sh |' \
            '| VC-3 | 边界条件通过 | 运行命令 | grep -c PASS out.txt |' \
            '| VC-4 | 计数=0 | 计数判据 | wc -l err.txt |' \
            '| VC-5 | 无回归破坏 | diff 判据 | git diff --stat |'
    } > "$d/task_plan.md"
    # verification.md — 5 条真实命令（同 make_vc_fixture real 面）
    cat > "$d/verification.md" <<EOF
# Verification Contract
## Verification Contract
- [ ] VC-1: 核心逻辑在位
  **Verify command**: test -f "$d/task_plan.md"
  **Pass criteria**: PASS
  Evidence: $d/task_plan.md
- [ ] VC-2: 验证脚本可执行
  **Verify command**: test -f "$d/verification.md"
  **Pass criteria**: PASS
  Evidence: $d/verification.md
- [ ] VC-3: 边界条件通过
  **Verify command**: grep -c 'VC-1' "$d/task_plan.md"
  **Pass criteria**: PASS
  Evidence: $d/task_plan.md
- [ ] VC-4: 计数=0
  **Verify command**: grep -c 'VC-5' "$d/task_plan.md"
  **Pass criteria**: PASS
  Evidence: $d/task_plan.md
- [ ] VC-5: 无回归破坏
  **Verify command**: test -f "$d/findings.md"
  **Pass criteria**: PASS
  Evidence: $d/findings.md
EOF
    cat > "$d/findings.md" <<'EOF'
# Findings
- 发现1: 核心逻辑实现完成，覆盖主路径。
- 发现2: 验证脚本输出符合预期形态。
- 发现3: 边界条件测试通过，无回归。
EOF
    cat > "$d/progress.md" <<'EOF'
# Progress
- Phase 1 complete: 核心逻辑与验证脚本均已交付。
- [reflect] 反思一: 验证命令需真实引用产出物。
- [reflect] 反思二: 终验复验通过，证据链完整。
EOF
}

# make_gcj_fixture <dir> <with-drift-trace> — 跑题夹具（S5 M4 配方：in_progress Phase +
# 中文 Goal + progress/findings 内容不一致）。with-drift-trace=补 drift_check ledger 痕迹。
make_gcj_fixture() {
    local d="$1" with_trace="$2"
    mkdir -p "$d"
    cat > "$d/task_plan.md" <<'EOF'
# Task Plan: GI goal-cjk fixture
## Goal
搭建一个在线商城系统
## Phases
### Phase 1:
- [ ] 修复登录 bug
- **Status:** in_progress
EOF
    cat > "$d/findings.md" <<'EOF'
# Findings
- 发现1: 登录模块存在空指针缺陷。
- 发现2: 修复方案已验证。
- 发现3: 回归测试通过。
EOF
    cat > "$d/progress.md" <<'EOF'
# Progress
## Phase 1:
- **Started:** 2026-10-17 10:00
- 修复登录 bug 的根因已定位。
- 修复补丁已提交。
- 回归测试执行完毕。
EOF
    if [ "$with_trace" = "yes" ]; then
        cat > "$d/ledger-test.jsonl" <<'EOF'
{"ts":"2026-10-17T10:05:00Z","event":"drift_check","phase":"1","note":"偏移检查留痕"}
EOF
    fi
}

# ── GI-01 vc-nonvacuous 负例: 真空 VC 夹具走真实门链 → rc≠0 含 [vc-nonvacuous] ────────
F1="$(mktemp -d "${GI_TMP}/gi01.XXXXXX")"
make_vc_fixture "$F1" vacuous
_o="$(bash "$CC" "$F1/task_plan.md" 2>&1)"; _rc=$?
if [ "$_rc" -ne 0 ] && printf '%s' "$_o" | grep -q '\[vc-nonvacuous\]'; then
    ok 01 "负例 真空 VC 夹具走 check-complete.sh 门链 → rc=$_rc 含 [vc-nonvacuous]（注入缺陷被拦截）"
else
    bad 01 "真空 VC 负例未拦截: rc=$_rc（应≠0）输出=$_o"
fi
rm -rf "$F1"

# ── GI-02 vc-nonvacuous 正例: 同夹具改真实命令 → [vc-nonvacuous] ✓ ────────────────────
F2="$(mktemp -d "${GI_TMP}/gi02.XXXXXX")"
make_vc_fixture "$F2" real
_o="$(bash "$CC" "$F2/task_plan.md" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && printf '%s' "$_o" | grep -q '\[vc-nonvacuous\] ✓'; then
    ok 02 "正例 真实命令夹具 → rc=0 含 [vc-nonvacuous] ✓（同输入双向锁定：缺陷消除即放行）"
else
    bad 02 "真实命令正例未通过: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F2"

# ── GI-03 rvc-coverage 负例: R 行无 R→VC 映射 → rc≠0 含 [rvc-coverage] ────────────────
F3="$(mktemp -d "${GI_TMP}/gi03.XXXXXX")"
make_rvc_fixture "$F3" no
_o="$(bash "$CC" "$F3/task_plan.md" 2>&1)"; _rc=$?
if [ "$_rc" -ne 0 ] && printf '%s' "$_o" | grep -q '\[rvc-coverage\]'; then
    ok 03 "负例 R 行无 R→VC 映射 → rc=$_rc 含 [rvc-coverage]（R 孤儿被拦截）"
else
    bad 03 "R→VC 映射缺口负例未拦截: rc=$_rc（应≠0）输出=$_o"
fi
rm -rf "$F3"

# ── GI-04 rvc-coverage 正例: 映射完整 → [rvc-coverage] ✓ ──────────────────────────────
F4="$(mktemp -d "${GI_TMP}/gi04.XXXXXX")"
make_rvc_fixture "$F4" yes
_o="$(bash "$CC" "$F4/task_plan.md" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && printf '%s' "$_o" | grep -q '\[rvc-coverage\] ✓'; then
    ok 04 "正例 R→VC 映射完整 → rc=0 含 [rvc-coverage] ✓（双向覆盖放行）"
else
    bad 04 "R→VC 映射完整正例未通过: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F4"

# ── GI-05 step-placeholder 负例: 占位步骤 → 判定器直测 rc≠0 + attest 静态锚 task-v184-S3 ─
F5="$(mktemp -d "${GI_TMP}/gi05.XXXXXX")"
mkdir -p "$F5"
cat > "$F5/task_plan.md" <<'EOF'
# Task Plan: GI step-placeholder fixture
## Phases
### Phase 1
- [ ] 优化一下性能
EOF
_o="$(bash "$SP" "$F5" 2>&1)"; _rc=$?
_n="$(grep -c 'task-v184-S3' "$ATTEST" 2>/dev/null || true)"
if [ "$_rc" -ne 0 ] && [ "${_n:-0}" -ge 1 ]; then
    ok 05 "负例 占位步骤「优化一下性能」→ 判定器直测 rc=$_rc + attest 静态锚 task-v184-S3 在位（n=$_n）"
else
    bad 05 "占位步骤负例未拦截: rc=$_rc（应≠0）attest 锚 n=${_n:-0}（应≥1）输出=$_o"
fi
rm -rf "$F5"

# ── GI-06 step-placeholder 正例: 干净步骤 → rc=0 ──────────────────────────────────────
F6="$(mktemp -d "${GI_TMP}/gi06.XXXXXX")"
mkdir -p "$F6"
cat > "$F6/task_plan.md" <<'EOF'
# Task Plan: GI step-placeholder clean fixture
## Phases
### Phase 1
- [ ] 实现 skills/task-planner/scripts/gi-foo.ts 的 parse function
EOF
_o="$(bash "$SP" "$F6" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ]; then
    ok 06 "正例 干净步骤（具体锚: 路径+ASCII 词）→ rc=0（不误拦可执行步骤）"
else
    bad 06 "干净步骤正例未通过: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F6"

# ── GI-07 tier-consistency 负例: mini 声明+3 Phase → 判定器直测 rc≠0 + attest 静态锚 ──
F7="$(mktemp -d "${GI_TMP}/gi07.XXXXXX")"
mkdir -p "$F7"
cat > "$F7/task_plan.md" <<'EOF'
# Task Plan: GI tier-consistency fixture
plan_tier: mini
## Phases
### Phase 1
- [ ] step one
### Phase 2
- [ ] step two
### Phase 3
- [ ] step three
EOF
_o="$(bash "$TC" "$F7" 2>&1)"; _rc=$?
_n="$(grep -c 'task-v184-S4' "$ATTEST" 2>/dev/null || true)"
if [ "$_rc" -ne 0 ] && [ "${_n:-0}" -ge 1 ]; then
    ok 07 "负例 mini 声明+3 Phase → 判定器直测 rc=$_rc + attest 静态锚 task-v184-S4 在位（n=$_n）"
else
    bad 07 "档位漂移负例未拦截: rc=$_rc（应≠0）attest 锚 n=${_n:-0}（应≥1）输出=$_o"
fi
rm -rf "$F7"

# ── GI-08 tier-consistency 正例: mini 声明+2 Phase → rc=0 ─────────────────────────────
F8="$(mktemp -d "${GI_TMP}/gi08.XXXXXX")"
mkdir -p "$F8"
cat > "$F8/task_plan.md" <<'EOF'
# Task Plan: GI tier-consistency clean fixture
plan_tier: mini
## Phases
### Phase 1
- [ ] step one
### Phase 2
- [ ] step two
EOF
_o="$(bash "$TC" "$F8" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ]; then
    ok 08 "正例 mini 声明+2 Phase → rc=0（体量一致不误拦）"
else
    bad 08 "档位一致正例未通过: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F8"

# ── GI-09 goal-cjk 负例: 跑题夹具 → check-3file-gate.sh 输出含 [goal-cjk] 或 [drift-gate] ✗ ─
F9="$(mktemp -d "${GI_TMP}/gi09.XXXXXX")"
make_gcj_fixture "$F9" no
_o="$(bash "$CG" "$F9" 2>&1)"; _rc=$?
if [ "$_rc" -ne 0 ] && { printf '%s' "$_o" | grep -q '\[goal-cjk\]' || printf '%s' "$_o" | grep -q '\[drift-gate\] ✗'; }; then
    ok 09 "负例 跑题夹具 → rc=$_rc 含 [goal-cjk] 或 [drift-gate] ✗（goal-cjk 段留痕+drift 门拦截）"
else
    bad 09 "跑题夹具负例未拦截: rc=$_rc（应≠0）输出=$_o"
fi
rm -rf "$F9"

# ── GI-10 goal-cjk 正例: 干净夹具 → 无 ✗/⚠（[goal-cjk] ✓）──────────────────────────
F10="$(mktemp -d "${GI_TMP}/gi10.XXXXXX")"
make_gcj_fixture "$F10" yes
_o="$(bash "$CG" "$F10" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && printf '%s' "$_o" | grep -q '\[goal-cjk\] ✓' \
   && ! printf '%s' "$_o" | grep -q '✗\|⚠'; then
    ok 10 "正例 干净夹具（含 drift_check 痕迹）→ rc=0 含 [goal-cjk] ✓ 且无 ✗/⚠"
else
    bad 10 "干净夹具正例未通过: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F10"

# ── GI-11 档位矩阵抽验: env=off 时 GI-01 夹具 rc 转变（vc-nonvacuous 段不阻断）────────
F11="$(mktemp -d "${GI_TMP}/gi11.XXXXXX")"
make_vc_fixture "$F11" vacuous
_o="$(TASK_PLANNER_VC_NONVACUOUS_ENFORCE=off bash "$CC" "$F11/task_plan.md" 2>&1)"; _rc=$?
if [ "$_rc" -eq 0 ] && ! printf '%s' "$_o" | grep -q '\[vc-nonvacuous\] ✗'; then
    ok 11 "档位矩阵 TASK_PLANNER_VC_NONVACUOUS_ENFORCE=off → rc=0（vc-nonvacuous 段不阻断，rc 1→0 转变）"
else
    bad 11 "env=off 档位未转变: rc=$_rc（应 0）输出=$_o"
fi
rm -rf "$F11"

echo "----------------------------------------------------------------"
echo "[selftest-gate-injection] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
