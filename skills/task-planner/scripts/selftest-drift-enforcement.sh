#!/usr/bin/env bash
# selftest-drift-enforcement.sh — task-v148: Rule 64.5 机制守护面（静态 DCE-01~10 + 行为 DCE-11~16）
# What: 守护 Rule 64 五接线落点在位 + gate/posttooluse/ledger 行为级 fixture 四态
# Why: 防「守措辞不守行为」错位复发（53.2/59.6 范式）；用户 2026-10-08「需要进行时刻记得纠正」
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# [task-v171 回归修复 2026-10-12 规则分层搬迁] 现象: DCE-01/02 FAIL(Rule 64 块头/六子条在核心已不存在)、
#   DCE-06/07 FAIL(SKILL.md '64.1 留痕三件套'/'留痕三件套已落实' 字面随 S33 瘦身改写)｜
# 根因: P7 核心瘦身后 Rule 64 归属 task-drift-guard, 旧锚指核心 critical-rules.md; S33 后 SKILL.md 留痕三件套
#   接线并入 DRIFT CHECK 行/Completion Gate G4 行(去掉 64.1 前缀与"已落实"措辞)｜
# 修法: DCE-01/02 改锚 CRIT_DR(task-drift-guard/references/critical-rules-drift.md); DCE-06 改指 SKILL.md
#   '留痕三件套'(DRIFT CHECK 执行流程接线); DCE-07 改指 SKILL.md '留痕三件套齐'(G4 门控行)
CRIT_DR="$SCRIPT_DIR/../../task-drift-guard/references/critical-rules-drift.md"
CR="$SCRIPT_DIR/../references/critical-rules.md"
SKILL="$SCRIPT_DIR/../SKILL.md"
GATE="$SCRIPT_DIR/check-3file-gate.sh"
LEDGER="$SCRIPT_DIR/ledger-append.sh"
HOOK="$SCRIPT_DIR/zcode-posttooluse.sh"
AGENT="$SCRIPT_DIR/../companion/agents/drift-checker.md"
CONFIG="$SCRIPT_DIR/../config.json"
CHANGELOG="$SCRIPT_DIR/../../../CHANGELOG.md"
PASS=0; FAIL=0
ok()  { echo "PASS $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL $1 ($2)"; FAIL=$((FAIL+1)); }
cnt() { [ -f "$2" ] || { echo 0; return; }; grep -c -e "$1" "$2" 2>/dev/null || true; }
# ── 静态断言 DCE-01~10 ──
[ "$(cnt '^### 64 偏移检查留痕强制与节奏化触发纪律' "$CRIT_DR")" -ge 1 ] && ok "DCE-01 critical-rules-drift Rule 64 块头" || bad "DCE-01" "块头缺失"
[ "$(cnt '^64\.[1-6] \*\*' "$CRIT_DR")" -eq 6 ] && ok "DCE-02 六子条锚=6" || bad "DCE-02" "got=$(cnt '^64\.[1-6] \*\*' "$CRIT_DR") expect=6"
[ "$(cnt 'VALID_EVENTS=.*drift_check' "$LEDGER")" -ge 1 ] && ok "DCE-03 ledger VALID_EVENTS 含 drift_check" || bad "DCE-03" "枚举缺失"
[ "$(cnt 'Rule 64.2' "$GATE")" -ge 1 ] && ok "DCE-04 gate 含 Rule 64.2 条件段" || bad "DCE-04" "条件段缺失"
[ "$(cnt 'drift-rhythm' "$HOOK")" -ge 1 ] && ok "DCE-05 posttooluse 含 drift-rhythm" || bad "DCE-05" "注入段缺失"
[ "$(cnt '留痕三件套' "$SKILL")" -ge 1 ] && ok "DCE-06 SKILL.md 含留痕三件套接线（DRIFT CHECK 行）" || bad "DCE-06" "接线缺失"
[ "$(cnt '留痕三件套齐' "$SKILL")" -ge 1 ] && ok "DCE-07 SKILL G4 行含留痕三件套齐" || bad "DCE-07" "C4 追加缺失"
[ "$(cnt '判定输入' "$AGENT")" -ge 1 ] && ok "DCE-08 drift-checker.md 含判定输入锚" || bad "DCE-08" "判定输入缺失"
[ "$(cnt 'drift_enforce' "$CONFIG")" -eq 0 ] && ok "DCE-09 config.json 不含 drift_enforce（零新键）" || bad "DCE-09" "got=$(cnt 'drift_enforce' "$CONFIG") expect=0"
# [2026-10-08 task-v148] DCE-10 部署布局自适应：CHANGELOG 为仓级文件，部署位不存在——缺失时 SKIP 计 PASS（What=部署位跑 selftest 不因仓级文件缺席而红；Why=selftest 权威运行位是仓源，部署位布局差异 FAIL 会污染真实回归信号）
if [ -f "$CHANGELOG" ]; then
  [ "$(cnt 'Rule 64' "$CHANGELOG")" -ge 1 ] && ok "DCE-10 CHANGELOG 含 Rule 64" || bad "DCE-10" "条目缺失"
else
  ok "DCE-10 CHANGELOG 含 Rule 64（SKIP：部署布局无仓级 CHANGELOG）"
fi
# ── 行为 fixture DCE-11~16 ──
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
# fixture: 合法 plan（满足 gate 条件 1-5）
mkdir -p "$TMP/plan/subagent-state"
printf '### Phase 2: test\n- **Status:** in_progress\n' > "$TMP/plan/task_plan.md"
printf '## Phase 2: test\n- **Started:** %s\n' "$(date -d '-1 hour' '+%Y-%m-%d %H:%M')" > "$TMP/plan/progress.md"
printf '# Findings\n' > "$TMP/plan/findings.md"
touch "$TMP/plan/task_plan.md" "$TMP/plan/progress.md" "$TMP/plan/findings.md"
# DCE-11: 无 drift 痕迹 → exit 1
bash "$GATE" "$TMP/plan" >/dev/null 2>&1 && bad "DCE-11" "expect exit 1" || ok "DCE-11 gate 无痕迹 exit 1"
# DCE-12: 检查点 mtime 晚于 Started → exit 0
echo "check" > "$TMP/plan/subagent-state/01-drift-checker.md"
bash "$GATE" "$TMP/plan" >/dev/null 2>&1 && ok "DCE-12 gate 检查点兜底 exit 0" || bad "DCE-12" "expect exit 0"
rm "$TMP/plan/subagent-state/01-drift-checker.md"
# DCE-13: drift_exempt 声明 → exit 0
printf 'drift_exempt: 2\n' >> "$TMP/plan/task_plan.md"
bash "$GATE" "$TMP/plan" >/dev/null 2>&1 && ok "DCE-13 gate drift_exempt exit 0" || bad "DCE-13" "expect exit 0"
sed -i '/^drift_exempt:/d' "$TMP/plan/task_plan.md"
# DCE-14: env warn → exit 0
TASK_PLANNER_DRIFT_ENFORCE=warn bash "$GATE" "$TMP/plan" >/dev/null 2>&1 && ok "DCE-14 gate env warn exit 0" || bad "DCE-14" "expect exit 0"
# DCE-17: env off → exit 0
TASK_PLANNER_DRIFT_ENFORCE=off bash "$GATE" "$TMP/plan" >/dev/null 2>&1 && ok "DCE-17 gate env off exit 0" || bad "DCE-17" "expect exit 0"
# DCE-18: plan_tier: mini 豁免 → exit 0
printf 'plan_tier: mini\n' >> "$TMP/plan/task_plan.md"
bash "$GATE" "$TMP/plan" >/dev/null 2>&1 && ok "DCE-18 gate plan_tier=mini 豁免 exit 0" || bad "DCE-18" "expect exit 0"
sed -i '/^plan_tier:/d' "$TMP/plan/task_plan.md"
# DCE-15: ledger-append drift_check 写入成功
bash "$LEDGER" "$TMP/plan" drift_check "ALIGNED 测试" --phase 1 >/dev/null 2>&1 && grep -q 'drift_check' "$TMP/plan"/ledger-*.jsonl && ok "DCE-15 ledger drift_check 写入成功" || bad "DCE-15" "写入失败"
# DCE-16: posttooluse 干跑（state count=10 last_inject=0 + side 指针 + plan 三件套）
# SID 唯一化（dce16$$）：避免跨运行累积主计数器导致优先级 4 提前返回（F4）
DCE16_SID="dce16$$"
mkdir -p "$TMP/plans/.drift-rhythm" "$TMP/plans/.active_plan_side" "$TMP/plans/test-plan"
printf 'count 10\nlast_inject 0\n' > "$TMP/plans/.drift-rhythm/${DCE16_SID}.state"
printf 'test-plan\n' > "$TMP/plans/.active_plan_side/${DCE16_SID}.active_plan"
printf '### Phase 2: test\n- **Status:** in_progress\n' > "$TMP/plans/test-plan/task_plan.md"
printf '## Phase 2: test\n- **Started:** 2026-10-08 12:00\n' > "$TMP/plans/test-plan/progress.md"
printf '# Findings\n' > "$TMP/plans/test-plan/findings.md"
printf '{"cwd":"%s","session_id":"%s"}\n' "$TMP" "$DCE16_SID" | bash "$HOOK" 2>/dev/null | grep -q 'drift-rhythm' && ok "DCE-16 posttooluse drift-rhythm 注入" || bad "DCE-16" "注入缺失"
# DCE-19: 单轮单 JSON（F9 修复验证）——threshold-due + 优先级 4 同轮命中 → stdout 恰好 1 行
# SID 纯字母数字（hook 内 tr -cd 'a-zA-Z0-9' 会剥连字符，含 - 的 SID 致 state 文件路径不匹配）
DCE19_SID="dce19$$"
mkdir -p "$TMP/dce19/plans/.drift-rhythm" "$TMP/dce19/plans/.active_plan_side" "$TMP/dce19/plans/test-plan"
printf 'count 10\nlast_inject 0\n' > "$TMP/dce19/plans/.drift-rhythm/${DCE19_SID}.state"
printf 'test-plan\n' > "$TMP/dce19/plans/.active_plan_side/${DCE19_SID}.active_plan"
printf '### Phase 2: test\n- **Status:** in_progress\n' > "$TMP/dce19/plans/test-plan/task_plan.md"
printf '## Phase 2: test\n- **Started:** %s\n' "$(date -d '-1 hour' '+%Y-%m-%d %H:%M')" > "$TMP/dce19/plans/test-plan/progress.md"
printf '# Findings\n' > "$TMP/dce19/plans/test-plan/findings.md"
touch "$TMP/dce19/plans/test-plan/task_plan.md" "$TMP/dce19/plans/test-plan/progress.md" "$TMP/dce19/plans/test-plan/findings.md"
# 优先级 4 命中条件：主 state count=9（+1 后=10 >= todo_n=10）
printf '9 0 0 0 0 0 0 0 0\n' > "/tmp/task-planner-hook-${DCE19_SID}.state"
DCE19_OUT="$(printf '{"cwd":"%s","session_id":"%s"}\n' "$TMP/dce19" "$DCE19_SID" | bash "$HOOK" 2>/dev/null)"
# 行数计算：grep -c '' 计算匹配空模式的行数（命令替换去末尾换行符，wc -l 会误判为 0）
DCE19_LINES="$(printf '%s' "$DCE19_OUT" | grep -c '' || true)"
if [ "$DCE19_LINES" -eq 1 ] && printf '%s' "$DCE19_OUT" | jq -e . >/dev/null 2>&1; then
  ok "DCE-19 单轮单 JSON（F9 修复）"
else
  bad "DCE-19" "lines=$DCE19_LINES expect=1"
fi
# DCE-20: F10 验证——task_plan.md 含 outcome: COMPLETE → stdout 0 字节且 due 清零
DCE20_SID="dce20$$"
mkdir -p "$TMP/dce20/plans/.drift-rhythm" "$TMP/dce20/plans/.active_plan_side" "$TMP/dce20/plans/test-plan"
printf 'count 10\nlast_inject 0\n' > "$TMP/dce20/plans/.drift-rhythm/${DCE20_SID}.state"
printf 'test-plan\n' > "$TMP/dce20/plans/.active_plan_side/${DCE20_SID}.active_plan"
# outcome 行格式对齐仓内约定与既有守卫正则 :150（`outcome: *(COMPLETE|BLOCKED)`）：
# 值须紧随 "outcome:"（`- **outcome: COMPLETE**`）；`**Outcome:** COMPLETE` 不匹配既有正则
printf '### Phase 2: test\n- **Status:** complete\n- **outcome: COMPLETE**\n' > "$TMP/dce20/plans/test-plan/task_plan.md"
printf '## Phase 2: test\n- **Started:** %s\n' "$(date -d '-1 hour' '+%Y-%m-%d %H:%M')" > "$TMP/dce20/plans/test-plan/progress.md"
printf '# Findings\n' > "$TMP/dce20/plans/test-plan/findings.md"
touch "$TMP/dce20/plans/test-plan/task_plan.md" "$TMP/dce20/plans/test-plan/progress.md" "$TMP/dce20/plans/test-plan/findings.md"
DCE20_OUT="$(printf '{"cwd":"%s","session_id":"%s"}\n' "$TMP/dce20" "$DCE20_SID" | bash "$HOOK" 2>/dev/null)"
DCE20_BYTES="$(printf '%s' "$DCE20_OUT" | wc -c)"
DCE20_DUE="$(sed -n 's/^due[[:space:]]\{1,\}//p' "$TMP/dce20/plans/.drift-rhythm/${DCE20_SID}.state" 2>/dev/null | head -1)"
if [ "$DCE20_BYTES" -eq 0 ] && [ "$DCE20_DUE" = "0" ]; then
  ok "DCE-20 F10 完结计划静默"
else
  bad "DCE-20" "bytes=$DCE20_BYTES due=$DCE20_DUE expect=0/0"
fi
# DCE-21: F10 验证——task_plan.md mtime 超 24h → stdout 0 字节且 due 清零
DCE21_SID="dce21$$"
mkdir -p "$TMP/dce21/plans/.drift-rhythm" "$TMP/dce21/plans/.active_plan_side" "$TMP/dce21/plans/test-plan"
printf 'count 10\nlast_inject 0\n' > "$TMP/dce21/plans/.drift-rhythm/${DCE21_SID}.state"
printf 'test-plan\n' > "$TMP/dce21/plans/.active_plan_side/${DCE21_SID}.active_plan"
printf '### Phase 2: test\n- **Status:** in_progress\n' > "$TMP/dce21/plans/test-plan/task_plan.md"
printf '## Phase 2: test\n- **Started:** %s\n' "$(date -d '-25 hour' '+%Y-%m-%d %H:%M')" > "$TMP/dce21/plans/test-plan/progress.md"
printf '# Findings\n' > "$TMP/dce21/plans/test-plan/findings.md"
touch -d '-25 hour' "$TMP/dce21/plans/test-plan/task_plan.md" "$TMP/dce21/plans/test-plan/progress.md" "$TMP/dce21/plans/test-plan/findings.md"
DCE21_OUT="$(printf '{"cwd":"%s","session_id":"%s"}\n' "$TMP/dce21" "$DCE21_SID" | bash "$HOOK" 2>/dev/null)"
DCE21_BYTES="$(printf '%s' "$DCE21_OUT" | wc -c)"
DCE21_DUE="$(sed -n 's/^due[[:space:]]\{1,\}//p' "$TMP/dce21/plans/.drift-rhythm/${DCE21_SID}.state" 2>/dev/null | head -1)"
if [ "$DCE21_BYTES" -eq 0 ] && [ "$DCE21_DUE" = "0" ]; then
  ok "DCE-21 F10 超龄计划静默"
else
  bad "DCE-21" "bytes=$DCE21_BYTES due=$DCE21_DUE expect=0/0"
fi
# DCE-22: N1 修复——due 跨分支命中轮持久保留，下一干净轮投递（不吞没分支消息）
# 轮1: rhythm count=10 last_inject=0 → 本轮 due=1；主 state count=9 → 优先级4命中(10>=10)
#       → 分支 emit 恰好 1 行、due 保留=1（rhythm 延后，不与分支同轮双投）
# 轮2: 同会话续调；主 state 已被优先级4重置 count=0 → 无分支命中 → end-emit 投递 rhythm、due=0
DCE22_SID="dce22$$"
mkdir -p "$TMP/dce22/plans/.drift-rhythm" "$TMP/dce22/plans/.active_plan_side" "$TMP/dce22/plans/test-plan"
printf 'count 10\nlast_inject 0\n' > "$TMP/dce22/plans/.drift-rhythm/${DCE22_SID}.state"
printf 'test-plan\n' > "$TMP/dce22/plans/.active_plan_side/${DCE22_SID}.active_plan"
printf '### Phase 2: test\n- **Status:** in_progress\n' > "$TMP/dce22/plans/test-plan/task_plan.md"
printf '## Phase 2: test\n- **Started:** %s\n' "$(date -d '-1 hour' '+%Y-%m-%d %H:%M')" > "$TMP/dce22/plans/test-plan/progress.md"
printf '# Findings\n' > "$TMP/dce22/plans/test-plan/findings.md"
touch "$TMP/dce22/plans/test-plan/task_plan.md" "$TMP/dce22/plans/test-plan/progress.md" "$TMP/dce22/plans/test-plan/findings.md"
printf '9 0 0 0 0 0 0 0 0\n' > "/tmp/task-planner-hook-${DCE22_SID}.state"
DCE22_R1="$(printf '{"cwd":"%s","session_id":"%s"}\n' "$TMP/dce22" "$DCE22_SID" | bash "$HOOK" 2>/dev/null)"
DCE22_R1_DUE="$(sed -n 's/^due[[:space:]]\{1,\}//p' "$TMP/dce22/plans/.drift-rhythm/${DCE22_SID}.state" 2>/dev/null | head -1)"
DCE22_R1_LINES="$(printf '%s' "$DCE22_R1" | grep -c '' || true)"
DCE22_R2="$(printf '{"cwd":"%s","session_id":"%s"}\n' "$TMP/dce22" "$DCE22_SID" | bash "$HOOK" 2>/dev/null)"
DCE22_R2_DUE="$(sed -n 's/^due[[:space:]]\{1,\}//p' "$TMP/dce22/plans/.drift-rhythm/${DCE22_SID}.state" 2>/dev/null | head -1)"
if [ "$DCE22_R1_LINES" -eq 1 ] && [ "$DCE22_R1_DUE" = "1" ] \
   && printf '%s' "$DCE22_R2" | grep -q 'drift-rhythm' && [ "$DCE22_R2_DUE" = "0" ]; then
  ok "DCE-22 N1 due 跨分支轮持久化并投递"
else
  bad "DCE-22" "r1_lines=$DCE22_R1_LINES r1_due=$DCE22_R1_DUE r2_rhythm=$(printf '%s' "$DCE22_R2" | grep -c 'drift-rhythm') r2_due=$DCE22_R2_DUE"
fi
# DCE-23: N1 核心——rhythm N=10 与 todo_sync 10 相位锁定，30 次连续调用投递 >=2 次
# （修复前 else 分支 clobber 残留 due → 恒 0 投递；修复后阈值轮被优先级4占用，
#   due 留存至下一干净轮由 end-emit 投递）。每轮 touch 三文件隔离优先级 1-3。
DCE23_SID="dce23$$"
mkdir -p "$TMP/dce23/plans/.drift-rhythm" "$TMP/dce23/plans/.active_plan_side" "$TMP/dce23/plans/test-plan"
printf 'test-plan\n' > "$TMP/dce23/plans/.active_plan_side/${DCE23_SID}.active_plan"
printf '### Phase 2: test\n- **Status:** in_progress\n' > "$TMP/dce23/plans/test-plan/task_plan.md"
printf '## Phase 2: test\n- **Started:** %s\n' "$(date -d '-1 hour' '+%Y-%m-%d %H:%M')" > "$TMP/dce23/plans/test-plan/progress.md"
printf '# Findings\n' > "$TMP/dce23/plans/test-plan/findings.md"
DCE23_DELIVERED=0; DCE23_MAXLINES=0; DCE23_I=0
while [ "$DCE23_I" -lt 30 ]; do
  DCE23_I=$(( DCE23_I + 1 ))
  touch "$TMP/dce23/plans/test-plan/task_plan.md" "$TMP/dce23/plans/test-plan/progress.md" "$TMP/dce23/plans/test-plan/findings.md"
  DCE23_OUT="$(printf '{"cwd":"%s","session_id":"%s"}\n' "$TMP/dce23" "$DCE23_SID" | bash "$HOOK" 2>/dev/null)"
  printf '%s' "$DCE23_OUT" | grep -q 'drift-rhythm' && DCE23_DELIVERED=$(( DCE23_DELIVERED + 1 ))
  DCE23_L="$(printf '%s' "$DCE23_OUT" | grep -c '' || true)"
  [ "$DCE23_L" -gt "$DCE23_MAXLINES" ] && DCE23_MAXLINES="$DCE23_L"
done
if [ "$DCE23_DELIVERED" -ge 2 ] && [ "$DCE23_MAXLINES" -le 1 ]; then
  ok "DCE-23 N1 相位锁定 30 调用投递 >=2（实际 ${DCE23_DELIVERED}）"
else
  bad "DCE-23" "delivered=$DCE23_DELIVERED expect>=2 maxlines=$DCE23_MAXLINES expect<=1"
fi
echo "Total: 23 PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
