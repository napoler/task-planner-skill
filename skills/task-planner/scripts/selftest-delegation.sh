#!/usr/bin/env bash
# selftest-delegation.sh — task-v055 委派门控自测
# [2026-09-07 task-v055] 执行期拦截组 5 文件 + 1 自测 = 6 项交付,本脚本覆盖:
#   T01 无计划放行 / T02 子代理 sid 放行 / T03 plans 白名单放行
#   T04 SKILL_ROOT 放行 / T05 trivial 3 行放行 / T06 4 行拦截(非 Edit 或 >3)
#   T07 enforce exit2 / T08 warn 注入 / T09 .allow-direct 放行+ledger
#   T10 过期 allow-direct 拦截 / T11 单会话二次 bypass 拒绝
#   T12 stats 占位检测 / T13 Handoff 交叉校验 / T14 jq 失败 fail-open
#   T15 复合 Executor 全在 Handoff(不误报)/ T16 复合 Executor 部分缺失(unverified+reason)
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
# [2026-09-07 task-v055-fix-review] M-4:allow-direct 走 sid 维度闸门(/tmp/task-planner-bypass-<sid>),
# 用专属 sid 保证测试隔离;结束后清理
T11_SID="test-sid-t11"
rm -f "/tmp/task-planner-bypass-${T11_SID}"
# 清空所有 bypass 状态
rm -f "$TEST_PLAN_DIR/.allow-direct" "$TEST_PLAN_DIR/.allow-direct.bypass-count" "$TEST_PLAN_DIR/ledger-delegation.jsonl"
# 第一次 on 应成功
out1="$(ZCODE_SID="$T11_SID" bash "$ALLOW" on --confirm-user-requested 2>&1)"
rc1=$?
# 第二次 on 应拒绝(同 sid)
out2="$(ZCODE_SID="$T11_SID" bash "$ALLOW" on --confirm-user-requested 2>&1)"
rc2=$?
assert_exit "T11a 首次 on 成功" "0" "$rc1"
assert_exit "T11b 二次 on 拒绝" "3" "$rc2"
rm -f "/tmp/task-planner-bypass-${T11_SID}"
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

# ── T15 复合 Executor 全在 Handoff(不误报) ───────────────────────────────────
# [2026-09-07 task-v055-fix] 验证 stats 解析按 + 拆分后,「architect + critic」两类型
# 都登记在 Handoff 表时,不应误报 unverified_delegation
TMP_T15="$(mktemp -d)/plans/task-t15-composite-ok"
mkdir -p "$TMP_T15"
cat > "$TMP_T15/task_plan.md" <<'EOF'
# Task Plan: T15 composite ok

## Phases

### Phase 1: 复合 Executor 全在 Handoff
- [ ] 子代理做
- **Status:** pending
- **Executor:** architect + critic（方案挑刺）

## 🔗 Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标 | 状态 | 结论 | 证据 | 落点 | checkpoint | verify_done |
|---|------|--------------|----------|------|------|------|------|------------|-------------|
| 1 | 2026-09-07 | architect | 方案 | done | ok | x | x | x | x |
| 2 | 2026-09-07 | critic | 挑刺 | done | ok | x | x | x | x |
EOF
out="$(bash "$CHECK" stats "$TMP_T15" 2>/dev/null)"
# 复合 Executor 全登记 → 不应出现 unverified_delegation
if printf '%s' "$out" | grep -q 'unverified_delegation'; then
    FAIL=$(( FAIL + 1 ))
    RESULTS+=("FAIL  T15 复合Executor全在Handoff但仍误报unverified")
else
    PASS=$(( PASS + 1 ))
    RESULTS+=("PASS  T15 复合Executor全在Handoff不误报")
fi
# 但仍应是合法的 delegated(不被减回) — phases_delegated >= 1
if printf '%s' "$out" | grep -q '"phases_delegated":[[:space:]]*[1-9]'; then
    PASS=$(( PASS + 1 ))
    RESULTS+=("PASS  T15b 复合Executor仍计delegated")
else
    FAIL=$(( FAIL + 1 ))
    RESULTS+=("FAIL  T15b 复合Executor未计delegated")
fi
rm -rf "$(dirname "$TMP_T15")"

# ── T16 复合 Executor 部分缺失(unverified+reason) ───────────────────────────
# [2026-09-07 task-v055-fix] 验证「architect + nonexistent」中 nonexistent 未登记
# → 应触发 unverified_delegation 且 reason 字段包含 nonexistent
TMP_T16="$(mktemp -d)/plans/task-t16-composite-miss"
mkdir -p "$TMP_T16"
cat > "$TMP_T16/task_plan.md" <<'EOF'
# Task Plan: T16 composite miss

## Phases

### Phase 1: 复合 Executor 部分缺失
- [ ] 子代理做
- **Status:** pending
- **Executor:** architect + nonexistent

## 🔗 Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标 | 状态 | 结论 | 证据 | 落点 | checkpoint | verify_done |
|---|------|--------------|----------|------|------|------|------|------------|-------------|
| 1 | 2026-09-07 | architect | 方案 | done | ok | x | x | x | x |
EOF
out="$(bash "$CHECK" stats "$TMP_T16" 2>/dev/null)"
# 应触发 unverified_delegation
if printf '%s' "$out" | grep -q 'unverified_delegation'; then
    PASS=$(( PASS + 1 ))
    RESULTS+=("PASS  T16 复合Executor部分缺失触发unverified")
else
    FAIL=$(( FAIL + 1 ))
    RESULTS+=("FAIL  T16 复合Executor部分缺失未触发unverified")
fi
# reason 字段应包含 "nonexistent"(缺失 token 名)
if printf '%s' "$out" | grep -q 'nonexistent'; then
    PASS=$(( PASS + 1 ))
    RESULTS+=("PASS  T16b reason字段含缺失token")
else
    FAIL=$(( FAIL + 1 ))
    RESULTS+=("FAIL  T16b reason字段未含缺失token")
fi
rm -rf "$(dirname "$TMP_T16")"

# ── T17 白名单规范措辞(白名单④：xxx)不触发 self_declared ─────────────────────
# [2026-09-07 task-v055-fix-review] B-1 验证:按 Rule 25.3 白名单编号格式填写的
# 「主进程（白名单④：xxx）」理由不应触发 self_declared_reason violation
# (旧 regex 会误报;新逻辑仅当 reason 含 ①-⑥/白名单[1-6] 时才认已登记)
TMP_T17="$(mktemp -d)/plans/task-t17-whitelist-ok"
mkdir -p "$TMP_T17"
cat > "$TMP_T17/task_plan.md" <<'EOF'
# Task Plan: T17 whitelist marker ok

## Phases

### Phase 1: 用户显式白名单④
- [ ] 主进程直做
- **Status:** pending
- **Executor:** 主进程（白名单④：用户明文要求主进程亲为）

### Phase 2: 纯 git 编排白名单①(数字格式)
- [ ] 主进程直做
- **Status:** pending
- **Executor:** 主进程（① 纯 git/worktree 编排）

## 🔗 Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标 | 状态 | 结论 | 证据 | 落点 | checkpoint | verify_done |
|---|------|--------------|----------|------|------|------|------|------------|-------------|
EOF
out="$(bash "$CHECK" stats "$TMP_T17" 2>/dev/null)"
# 应 verdict=ok(无 violations),且 main_direct 两项 self_declared=0
if printf '%s' "$out" | grep -q '"verdict":"violation"'; then
    FAIL=$(( FAIL + 1 ))
    RESULTS+=("FAIL  T17 白名单④标记理由仍被误报violation")
else
    PASS=$(( PASS + 1 ))
    RESULTS+=("PASS  T17 白名单④标记理由不触发violation")
fi
# 两项主进程直做应 self_declared=0
sd0_count="$(printf '%s' "$out" | grep -oE '"self_declared":0' | wc -l | tr -d ' ')"
if [ "$sd0_count" -ge 2 ]; then
    PASS=$(( PASS + 1 ))
    RESULTS+=("PASS  T17b 白名单标记main_direct全部self_declared=0")
else
    FAIL=$(( FAIL + 1 ))
    RESULTS+=("FAIL  T17b 白名单标记main_direct应self_declared=0 (got=$sd0_count)")
fi
rm -rf "$(dirname "$TMP_T17")"

# ── T18 无括注理由触发 missing_reason ─────────────────────────────────────────
# [2026-09-07 task-v055-fix-review] M-1 验证:Executor=主进程 但无括注理由
# → 应触发 missing_reason violation(而非静默放行)
TMP_T18="$(mktemp -d)/plans/task-t18-missing-reason"
mkdir -p "$TMP_T18"
cat > "$TMP_T18/task_plan.md" <<'EOF'
# Task Plan: T18 missing reason

## Phases

### Phase 1: 主进程直做无理由
- [ ] 主进程直做
- **Status:** pending
- **Executor:** 主进程

## 🔗 Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标 | 状态 | 结论 | 证据 | 落点 | checkpoint | verify_done |
|---|------|--------------|----------|------|------|------|------|------------|-------------|
EOF
out="$(bash "$CHECK" stats "$TMP_T18" 2>/dev/null)"
rc=$?
if printf '%s' "$out" | grep -q '"type":"missing_reason"'; then
    PASS=$(( PASS + 1 ))
    RESULTS+=("PASS  T18 无理由触发missing_reason violation")
else
    FAIL=$(( FAIL + 1 ))
    RESULTS+=("FAIL  T18 无理由未触发missing_reason violation")
fi
# 应 verdict=violation + exit 1
assert_exit "T18b verdict=violation exit=1" "1" "$rc"
rm -rf "$(dirname "$TMP_T18")"

# ── T19 owner 多行取首行(注入 sid 不放行) ─────────────────────────────────────
# [2026-09-07 task-v055-fix-review] M-2 验证:.session-owner 含多行/前导垃圾字符
# → read_session_owner 规范化后只取首行;注入 sid 应被识别为子代理 → 放行
TMP_T19="$(mktemp -d)/plans/task-t19-multiline-owner"
mkdir -p "$TMP_T19"
cat > "$TMP_T19/task_plan.md" <<'EOF'
# Task Plan: T19

## Phases
EOF
# 隔离解析:.active_plan 指向本测试目录
printf '%s' "task-t19-multiline-owner" > "$(dirname "$TMP_T19")/.active_plan"
# 写多行 owner:第一行 = 主进程 sid,第二行 = 注入 sid
printf 'main-sid\nattacker-sid\n' > "$TMP_T19/.session-owner"
# 用 attacker-sid 调用 → 严格比较后不等 → 应被判定为子代理 → 放行
cd "$TMP_T19" || exit 99
out="$(bash "$CHECK" pretool "/tmp/foo.ts" "attacker-sid" 10 2>/dev/null)"
rc=$?
assert_exit "T19 owner 多行注入 sid 放行(子代理语义)" "0" "$rc"
# 用 main-sid 调用 → 严格比较相等 → 主进程 → 走到白名单链后因非白名单被 enforce exit 2
out="$(bash "$CHECK" pretool "/tmp/foo.ts" "main-sid" 10 2>/dev/null)"
rc=$?
assert_exit "T19b owner 首行主进程+白名单外=exit2" "2" "$rc"
rm -rf "$(dirname "$TMP_T19")"
rm -f "$(dirname "$(dirname "$TMP_T19")")/.active_plan"

# ── T20 owner 缺失输出观察模式提示且 exit 0 ───────────────────────────────────
# [2026-09-07 task-v055-fix-review] M-2 验证:.session-owner 缺失 → 降级观察模式
# → stdout 输出 additionalContext 提示 + exit 0(不阻断首执行轮)
TMP_T20="$(mktemp -d)/plans/task-t20-no-owner"
mkdir -p "$TMP_T20"
cat > "$TMP_T20/task_plan.md" <<'EOF'
# Task Plan: T20

## Phases
EOF
# 隔离解析 + 确保 .session-owner 不存在
printf '%s' "task-t20-no-owner" > "$(dirname "$TMP_T20")/.active_plan"
rm -f "$TMP_T20/.session-owner"
cd "$TMP_T20" || exit 99
out="$(bash "$CHECK" pretool "/tmp/foo.ts" "any-sid" 2>/dev/null)"
rc=$?
assert_exit "T20 owner 缺失 exit 0" "0" "$rc"
assert_grep "T20b owner 缺失输出观察模式" 'delegation-observe|additionalContext' "$out"
rm -rf "$(dirname "$TMP_T20")"
rm -f "$(dirname "$(dirname "$TMP_T20")")/.active_plan"

# ── T21 plans 白名单 .ts 不放行 ────────────────────────────────────────────────
# [2026-09-07 task-v055-fix-review] M-5 验证:业务项目 plans/<...>/foo.ts 不应被放行
# → 仅 .md/.json 放行;其他扩展名继续走拦截链
TMP_T21="$(mktemp -d)/plans/task-t21-not-allowed-ext"
mkdir -p "$TMP_T21" "$TMP_T21/src"
cat > "$TMP_T21/task_plan.md" <<'EOF'
# Task Plan: T21

## Phases
EOF
# 隔离解析 + owner=main-sid 才能继续走到白名单链
printf '%s' "task-t21-not-allowed-ext" > "$(dirname "$TMP_T21")/.active_plan"
printf '%s' "main-sid" > "$TMP_T21/.session-owner"
# 用大 lines_arg (>3) 排除 trivial 放行
cd "$TMP_T21" || exit 99
out="$(bash "$CHECK" pretool "$TMP_T21/src/foo.ts" "main-sid" 10 2>/dev/null)"
rc=$?
assert_exit "T21 plans/ 内 .ts 不放行" "2" "$rc"
# 同一目录下 .md 应放行
out="$(bash "$CHECK" pretool "$TMP_T21/notes.md" "main-sid" 10 2>/dev/null)"
rc=$?
assert_exit "T21b plans/ 内 .md 放行" "0" "$rc"
rm -rf "$(dirname "$TMP_T21")"
rm -f "$(dirname "$(dirname "$TMP_T21")")/.active_plan"

# ── T22 bypass 第二次(同 sid)拒绝 ──────────────────────────────────────────────
# [2026-09-07 task-v055-fix-review] M-4 验证:sid 维度闸门 /tmp/task-planner-bypass-<sid>
# 存在时,二次 on 拒绝;不同 sid 可分别放行(各 sid 维度独立)
TMP_T22="$(mktemp -d)/plans/task-t22-sid-bypass"
mkdir -p "$TMP_T22"
cat > "$TMP_T22/task_plan.md" <<'EOF'
# Task Plan: T22
EOF
printf '%s' "task-t22-sid-bypass" > "$(dirname "$TMP_T22")/.active_plan"
# 清干净所有 bypass 状态
rm -f "$TMP_T22/.allow-direct" "$TMP_T22/.allow-direct.bypass-count" "$TMP_T22/ledger-delegation.jsonl"
rm -f /tmp/task-planner-bypass-test-sid-a /tmp/task-planner-bypass-test-sid-b
cd "$TMP_T22" || exit 99
# 第一次 on 应成功
out1="$(ZCODE_SID=test-sid-a bash "$ALLOW" on --confirm-user-requested 2>&1)"
rc1=$?
# 第二次同 sid 应被 sid 闸门拒绝
out2="$(ZCODE_SID=test-sid-a bash "$ALLOW" on --confirm-user-requested 2>&1)"
rc2=$?
assert_exit "T22a 同 sid 首次 on 成功" "0" "$rc1"
assert_exit "T22b 同 sid 二次 on 拒绝" "3" "$rc2"
# 不同 sid 应放行(sid 维度独立)
out3="$(ZCODE_SID=test-sid-b bash "$ALLOW" on --confirm-user-requested 2>&1)"
rc3=$?
assert_exit "T22c 不同 sid on 放行" "0" "$rc3"
# 清理
rm -f /tmp/task-planner-bypass-test-sid-a /tmp/task-planner-bypass-test-sid-b
rm -rf "$(dirname "$TMP_T22")"
rm -f "$(dirname "$(dirname "$TMP_T22")")/.active_plan"

# ── T_MEM 记忆目录白名单放行 ────────────────────────────────────────────────
# [2026-09-09 task-v057] $HOME/.zcode/cli/memories/ 白名单:主进程直做记忆写入放行
MEM_TARGET="$HOME/.zcode/cli/memories/projects/x/memory/y.md"
out="$(bash "$CHECK" pretool "$MEM_TARGET" "main-sid" 10 2>/dev/null)"
rc=$?
assert_exit "T_MEM 记忆目录白名单放行" "0" "$rc"

# ── T_RATE_OK / T_RATE_LOW check-complete 比较方向防回归 ───────────────────
# [2026-09-09 task-v057] 原 exit !(r<f) 双重取反 bug 防再次反转
{ awk -v r=0.714 -v f=0.7 'BEGIN{exit (r+0 < f+0)}' && [ "$(grep -c "exit (r+0 < f+0)" "$SCRIPT_DIR/check-complete.sh")" = "1" ]; }
assert_exit "T_RATE_OK rate>=floor exit0 且比较式 1 处" "0" "$?"
awk -v r=0.5 -v f=0.7 'BEGIN{exit (r+0 < f+0)}'
assert_exit "T_RATE_LOW rate<floor exit1" "1" "$?"

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