#!/usr/bin/env bash
# selftest-delegation.sh — task-v055 委派门控自测
# [2026-09-07 task-v055] 执行期拦截组 5 文件 + 1 自测 = 6 项交付,本脚本覆盖:
#   T01 无计划放行 / T02 子代理 sid 放行 / T03 plans 白名单放行
#   T04 SKILL_ROOT 放行 / T05 trivial 3 行放行 / T06 4 行拦截(非 Edit 或 >3)
#   T07 enforce exit2 / T08 warn 注入 / T09 .allow-direct 放行+ledger
#   T10 过期 allow-direct 拦截 / T11 单会话二次 bypass 拒绝
#   T12 stats 占位检测 / T13 Handoff 交叉校验 / T14 jq 失败 fail-open
# 全部 PASS 才算任务完成。失败 → 整体 exit 1。
#
# 用法: bash selftest-delegation.sh  (默认打印 PASS/FAIL 表 + 退出码)
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK="$SCRIPT_DIR/check-delegation.sh"
ALLOW="$SCRIPT_DIR/allow-direct.sh"
CONFIG="$SCRIPT_DIR/../config.json"

# 临时测试工作区
TMPBASE="$(mktemp -d)"
trap 'rm -rf "$TMPBASE"' EXIT

PASS=0
FAIL=0
RESULTS=()

assert_exit() {
    local name="$1" expected="$2" got="$3"
    if [ "$got" = "$expected" ]; then
        PASS=$(( PASS + 1 ))
        RESULTS+=("PASS  $name  (exit=$got)")
    else
        FAIL=$(( FAIL + 1 ))
        RESULTS+=("FAIL  $name  (expected=$expected got=$got)")
    fi
}

assert_grep() {
    local name="$1" pattern="$2" text="$3"
    if printf '%s' "$text" | grep -qE "$pattern"; then
        PASS=$(( PASS + 1 ))
        RESULTS+=("PASS  $name  (grep hit)")
    else
        FAIL=$(( FAIL + 1 ))
        RESULTS+=("FAIL  $name  (pattern not found)")
    fi
}

# ── 准备测试 plan 目录 ────────────────────────────────────────────────────────
TEST_PLAN_DIR="$TMPBASE/plans/task-selftest"
mkdir -p "$TEST_PLAN_DIR"

cat > "$TEST_PLAN_DIR/task_plan.md" <<'EOF'
# Task Plan: Selftest

## Phases

### Phase 1: 读现状
- [ ] 子代理做
- **Status:** pending
- **Executor:** code-assistant（haiku-1）

### Phase 2: 实施
- [ ] 子代理做
- **Status:** pending
- **Executor:** executor（sonnet-1）

### Phase 3: 主进程直做(无理由)
- [ ] 主进程直做
- **Status:** pending
- **Executor:** 主进程

### Phase 4: 主进程直做(编排理由)
- [ ] 编排
- **Status:** pending
- **Executor:** 主进程（编排与交付属主进程白名单）

### Phase 5: 子代理做但无 Handoff 行
- [ ] 子代理做
- **Status:** pending
- **Executor:** debugger（sonnet-1）

## 🔗 Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标 | 状态 | 结论 | 证据 | 落点 | checkpoint | verify_done |
|---|------|--------------|----------|------|------|------|------|------------|-------------|
| 1 | 2026-09-07 | code-assistant | 读 | done | ok | x | x | x | x |
| 2 | 2026-09-07 | executor | 实施 | done | ok | x | x | x | x |
EOF

mkdir -p "$TMPBASE/plans"
# 模拟 plans/.active_plan 指针
printf '%s' "task-selftest" > "$TMPBASE/plans/.active_plan"

# ── T01 无计划放行(空目录) ───────────────────────────────────────────────────
empty_dir="$TMPBASE/empty"
mkdir -p "$empty_dir"
cd "$empty_dir" || exit 99
out="$(bash "$CHECK" pretool "/tmp/foo.ts" "main-sid" 5 2>/dev/null)"
rc=$?
assert_exit "T01 无计划放行" "0" "$rc"

# ── T02 子代理 sid 放行 ──────────────────────────────────────────────────────
cd "$TEST_PLAN_DIR" || exit 99
# 写 .session-owner=main-sid
printf '%s' "main-sid" > "$TEST_PLAN_DIR/.session-owner"
# 调用 sid=subagent-sid 应放行
out="$(bash "$CHECK" pretool "/tmp/foo.ts" "subagent-sid" 5 2>/dev/null)"
rc=$?
assert_exit "T02 子代理 sid 放行" "0" "$rc"

# ── T03 plans 白名单放行 ─────────────────────────────────────────────────────
cd "$TEST_PLAN_DIR" || exit 99
out="$(bash "$CHECK" pretool "$TEST_PLAN_DIR/notes.md" "main-sid" 5 2>/dev/null)"
rc=$?
assert_exit "T03 plans 白名单放行" "0" "$rc"

# ── T04 SKILL_ROOT 放行 ──────────────────────────────────────────────────────
cd "$TEST_PLAN_DIR" || exit 99
out="$(bash "$CHECK" pretool "$SCRIPT_DIR/check-delegation.sh" "main-sid" 5 2>/dev/null)"
rc=$?
assert_exit "T04 SKILL_ROOT 放行" "0" "$rc"

# ── T05 trivial 3 行放行(Edit,lines=2) ───────────────────────────────────────
cd "$TEST_PLAN_DIR" || exit 99
out="$(bash "$CHECK" pretool "/tmp/foo.ts" "main-sid" 2 2>/dev/null)"
rc=$?
assert_exit "T05 trivial 3 行放行" "0" "$rc"

# ── T06 4 行拦截(>3) ────────────────────────────────────────────────────────
cd "$TEST_PLAN_DIR" || exit 99
out="$(bash "$CHECK" pretool "/tmp/foo.ts" "main-sid" 4 2>/dev/null)"
rc=$?
assert_exit "T06 4 行拦截" "2" "$rc"

# ── T07 enforce exit2(默认配置) ──────────────────────────────────────────────
cd "$TEST_PLAN_DIR" || exit 99
out="$(bash "$CHECK" pretool "/tmp/bar.ts" "main-sid" 10 2>/dev/null)"
rc=$?
assert_exit "T07 enforce exit2" "2" "$rc"

# ── T08 warn 注入 ────────────────────────────────────────────────────────────
cd "$TEST_PLAN_DIR" || exit 99
# 临时改 config 为 warn
cp "$CONFIG" "$CONFIG.bak"
jq '.properties.delegation_enforce.default="warn"' "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"
out="$(bash "$CHECK" pretool "/tmp/baz.ts" "main-sid" 10 2>/dev/null)"
rc=$?
mv "$CONFIG.bak" "$CONFIG"
assert_exit "T08 warn 不阻断" "0" "$rc"
assert_grep "T08 warn 注入" 'additionalContext' "$out"

# ── T09 .allow-direct 放行+ledger ─────────────────────────────────────────────
cd "$TEST_PLAN_DIR" || exit 99
# 模拟 bypass 已用一次 → bypass-count=1(先清)
rm -f "$TEST_PLAN_DIR/.allow-direct" "$TEST_PLAN_DIR/.allow-direct.bypass-count" "$TEST_PLAN_DIR/ledger-delegation.jsonl"
# 写新 .allow-direct 有效戳
now="$(date +%s)"
stamp=$(( now + 1800 ))
printf '%s' "$stamp" > "$TEST_PLAN_DIR/.allow-direct"
# 写 bypass-count=1(模拟已用过 1 次,但 allow-direct 仍生效)
printf '%s' "1" > "$TEST_PLAN_DIR/.allow-direct.bypass-count"
out="$(bash "$CHECK" pretool "/tmp/allow.ts" "main-sid" 10 2>/dev/null)"
rc=$?
assert_exit "T09 .allow-direct 放行" "0" "$rc"
# ledger 记录验证
if [ -f "$TEST_PLAN_DIR/ledger-delegation.jsonl" ] && grep -q '"event":"bypass"' "$TEST_PLAN_DIR/ledger-delegation.jsonl"; then
    PASS=$(( PASS + 1 ))
    RESULTS+=("PASS  T09b ledger 写入 bypass")
else
    FAIL=$(( FAIL + 1 ))
    RESULTS+=("FAIL  T09b ledger 未写入 bypass")
fi
rm -f "$TEST_PLAN_DIR/.allow-direct" "$TEST_PLAN_DIR/.allow-direct.bypass-count"

# ── T10 过期 allow-direct 拦截 ───────────────────────────────────────────────
cd "$TEST_PLAN_DIR" || exit 99
# 写过期戳(now - 100)
old_stamp=$(( now - 100 ))
printf '%s' "$old_stamp" > "$TEST_PLAN_DIR/.allow-direct"
out="$(bash "$CHECK" pretool "/tmp/expired.ts" "main-sid" 10 2>/dev/null)"
rc=$?
assert_exit "T10 过期 allow-direct 拦截" "2" "$rc"
rm -f "$TEST_PLAN_DIR/.allow-direct"

# ── T11 单会话二次 bypass 拒绝(allow-direct.sh on) ───────────────────────────
cd "$TEST_PLAN_DIR" || exit 99
# 清空所有 bypass 状态
rm -f "$TEST_PLAN_DIR/.allow-direct" "$TEST_PLAN_DIR/.allow-direct.bypass-count" "$TEST_PLAN_DIR/ledger-delegation.jsonl"
# 第一次 on 应成功
out1="$(bash "$ALLOW" on --confirm-user-requested 2>&1)"
rc1=$?
# 第二次 on 应拒绝(同会话)
out2="$(bash "$ALLOW" on --confirm-user-requested 2>&1)"
rc2=$?
assert_exit "T11a 首次 on 成功" "0" "$rc1"
assert_exit "T11b 二次 on 拒绝" "3" "$rc2"
rm -f "$TEST_PLAN_DIR/.allow-direct" "$TEST_PLAN_DIR/.allow-direct.bypass-count" "$TEST_PLAN_DIR/ledger-delegation.jsonl"

# ── T12 stats 占位检测 ───────────────────────────────────────────────────────
cd "$TEST_PLAN_DIR" || exit 99
out="$(bash "$CHECK" stats "$TEST_PLAN_DIR" 2>/dev/null)"
rc=$?
# 我们的样例 plan 含 Phase 4 「编排」理由(自声明字样)→ 应触发 violation
assert_grep "T12 stats 占位/理由检测" 'self_declared_reason' "$out"
assert_exit "T12 stats 退出码非 0(violation)" "1" "$rc"

# ── T13 Handoff 交叉校验 ─────────────────────────────────────────────────────
# Phase 5 = debugger, Handoff 表无 debugger 行 → 应触发 unverified_delegation
cd "$TEST_PLAN_DIR" || exit 99
out="$(bash "$CHECK" stats "$TEST_PLAN_DIR" 2>/dev/null)"
assert_grep "T13 Handoff 交叉校验" 'unverified_delegation' "$out"

# ── T14 jq 失败 fail-open ─────────────────────────────────────────────────────
cd "$TEST_PLAN_DIR" || exit 99
# /tmp 在沙箱下可能 noexec;shim 目录放 $HOME
SHIM="$HOME/.task-planner-selftest-shim-$$"
mkdir -p "$SHIM"
cat > "$SHIM/jq" <<'EOSHIM'
#!/bin/sh
echo "fake_jq_failed" >&2
exit 1
EOSHIM
chmod +x "$SHIM/jq"
SAVE_PATH="$PATH"
# 让 fake jq 优先,但确保 /bin/sh 之类仍可用:用绝对 PATH 串
export PATH="$SHIM:/usr/bin:/bin"
out="$(bash "$CHECK" pretool "/tmp/foo.ts" "main-sid" 5 2>&1)"
rc=$?
export PATH="$SAVE_PATH"
rm -rf "$SHIM"
assert_exit "T14 jq 失败 fail-open" "0" "$rc"

# ── 输出 ─────────────────────────────────────────────────────────────────────
echo ""
echo "========================================"
echo "selftest-delegation results"
echo "========================================"
for r in "${RESULTS[@]}"; do
    echo "$r"
done
echo "----------------------------------------"
echo "Total: $(( PASS + FAIL ))    PASS=$PASS  FAIL=$FAIL"
echo "========================================"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
exit 0