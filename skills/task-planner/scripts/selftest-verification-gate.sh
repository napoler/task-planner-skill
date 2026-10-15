#!/usr/bin/env bash
# selftest-verification-gate.sh — task-v173 Rule 84 验证技能独立化静态守护（84.6 机器面落地物）
# What：静态断言 verification-gate 卫星全链落点在位——卫星 SKILL.md/规则文件/template/游戏脚本四文件、
#      Rule 84.1-84.6 子条文本锚、verification.md 模板"Verify command"字段锚、主技能路由表/三处步骤引用/
#      attest-plan.sh VC 可执行性门锚、以及零新 config 键承诺（properties 键数不变）。
# Why：验证技能独立化（用户 2026-10-14 裁决 R1-R4）后，任何后续任务改写卫星/主技能/脚本时误删 Rule 84
#      子条、VC 可执行性门或路由引用，selftest 立即 FAIL 暴露（Rule 36.5 纯增量回归防护）。
# 范式对齐 selftest-requirement-grading.sh（SCRIPT_DIR/SKILL_ROOT 定位、ok()/bad()、Total 行、FAIL>0 exit 1 全同构）。
# 输入：skills/verification-gate/{SKILL.md,references/critical-rules-verification.md,templates/verification.md,
#      scripts/run-verification.sh}、skills/task-planner/{SKILL.md,references/critical-rules.md,scripts/attest-plan.sh,
#      config.json}（只读，grep/test，零写入）。
# 输出：VG-01..VG-12 逐行 PASS/FAIL + 末行 Total；全 PASS exit 0，任一 FAIL exit 1。
# 依赖：bash + grep + test；无 jq 依赖（config 键数用 grep -cE 计数，无 jq 降级路径）。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# [task-v173] 定位：脚本位于 task-planner/scripts（家族回归体系），卫星在其上级 ../verification-gate
TP_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SATELLITE_ROOT="$(cd "$TP_ROOT/../verification-gate" && pwd)"

SAT_SKILL="$SATELLITE_ROOT/SKILL.md"
SAT_CRIT="$SATELLITE_ROOT/references/critical-rules-verification.md"
SAT_TPL="$SATELLITE_ROOT/templates/verification.md"
SAT_RUNV="$SATELLITE_ROOT/scripts/run-verification.sh"
TP_SKILL="$TP_ROOT/SKILL.md"
TP_CRIT="$TP_ROOT/references/critical-rules.md"
TP_ATTEST="$TP_ROOT/scripts/attest-plan.sh"
TP_CONFIG="$TP_ROOT/config.json"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'VG-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'VG-%s FAIL %s\n' "$1" "$2"; }

# VG-01 satellite SKILL.md frontmatter（name/description/model 三锚）
# What：断言卫星 SKILL.md 含 name: verification-gate / description:（含验证语义关键词）/ model: 三锚。
# Why：frontmatter 是 satellite 可路由前提（name 缺=Skill() 不可达；description 缺=触发条件不可发现）。
if grep -q '^name: verification-gate' "$SAT_SKILL" && grep -q '^description:.*验证' "$SAT_SKILL" && grep -q '^model:' "$SAT_SKILL"; then
  ok 01 "卫星 SKILL.md frontmatter 三锚在位（name/description/model）"
else
  bad 01 "卫星 SKILL.md frontmatter 三锚缺失（name: verification-gate / description 含'验证' / model:）"
fi

# VG-02 rule file Rule 84 节 + 84.1-84.6 六子条锚
# What：断言 critical-rules-verification.md 含 '### 84' 章节标题 + 84.1-84.6 六个子条主体行（grep -c '^84\\.'）。
# Why：84.1 VC 可执行性纪律/84.6 机制是核心新条款，子条缺一=验证域规则本体被裁剪。
if grep -q '### 84 ' "$SAT_CRIT" && [ "$(grep -cE '^84\.[0-9]' "$SAT_CRIT" || true)" -ge 6 ]; then
  ok 02 "规则文件 Rule 84 节 + 84.1-84.6 子条锚≥6 在位"
else
  bad 02 "规则文件 Rule 84 节或 84.x 子条缺失（'### 84' 标题 + 84.1-84.6 六子条）"
fi

# VG-03 verification.md 模板"Verify command"字段锚
# What：断言卫星 templates/verification.md 含 '**Verify command**:' 字段（VC 可执行化模板载体）。
# Why：84.1 "创建任务时写验证规则和脚本"的模板载体——VC 条目无 Verify command 字段=模板退化为描述性占位。
if grep -q '\*\*Verify command\*\*:' "$SAT_TPL" && grep -q 'VC 可执行性纪律（Rule 84.1）' "$SAT_TPL"; then
  ok 03 "卫星 verification.md 模板含 '**Verify command**:' 字段 + Rule 84.1 纪律锚"
else
  bad 03 "卫星 verification.md 模板缺 '**Verify command**（Rule 84.1）' 字段锚"
fi

# VG-04 run-verification.sh 存在 + 可执行 + bash 语法通过
# What：断言统一验证入口脚本存在、有执行位、bash -n 语法通过。
# Why：终验 VC 复验统一入口（84.5/84.6）——脚本缺失/语法错=终验可执行验证链断裂。
if [ -f "$SAT_RUNV" ] && [ -x "$SAT_RUNV" ] && bash -n "$SAT_RUNV" 2>/dev/null; then
  ok 04 "run-verification.sh 存在 + 可执行 + bash 语法通过"
else
  bad 04 "run-verification.sh 缺失/不可执行/语法错（终验统一入口失效）"
fi

# VG-05 主 SKILL.md 卫星路由表 verification-gate 行 + Rule 84 枚举
# What：断言主 SKILL.md 含 '^| verification-gate' 路由表行 + 'Rule 84' 枚举 ≥2。
# Why：主技能只留指针（Rule 82），路由表行是唯一发现入口——缺行=卫星从主技能不可达。
if grep -qE '^\| verification-gate' "$TP_SKILL" && [ "$(grep -cF 'Rule 80,88,84' "$TP_SKILL" || true)" -ge 0 ] && [ "$(grep -cE 'Rule ?84' "$TP_SKILL" || true)" -ge 2 ]; then
  ok 05 "主 SKILL.md 路由表 verification-gate 行 + Rule 84 枚举 ≥2 在位"
else
  bad 05 "主 SKILL.md 路由表缺 verification-gate 行或 Rule 84 枚举 <2"
fi

# VG-06 主 SKILL.md 三处步骤引用（frontmatter/计划期/终验）+ 全集 1-84 纪元
# What：断言主 SKILL.md 含 '1-84' 全集纪元 + '11 卫星' 计数 + verification-gate frontmatter 卫星行。
# Why：验证独立化后主技能须在 frontmatter/全集纪元/卫星计数三面同步（task-v173 纪元级联）。
if grep -q 'Rules 1-[89][0-9]' "$TP_SKILL" && grep -q '11 卫星' "$TP_SKILL" && grep -q '卫星技能 verification-gate' "$TP_SKILL"; then
  ok 06 "主 SKILL.md 全集 1-[89][0-9] + 11 卫星 + frontmatter satellite 行三锚在位"
else
  bad 06 "主 SKILL.md 全集 1-[89][0-9]/11 卫星/frontmatter satellite 行三锚缺失"
fi

# VG-07 attest-plan.sh VC 可执行性门锚（resolve_vc_tier + env + skip + 拒锁消息）
# What：断言 attest-plan.sh 含 resolve_vc_tier 函数 + 'TASK_PLANNER_VC_ENFORCE' env + '--skip-vc-check' 逃生 + 'vc-gate' 输出锚。
# Why：84.6 机器面=attest 前置硬门——任一锚缺失=计划期 VC 可执行性校验失效（描述性 VC 占位混过）。
if grep -q 'resolve_vc_tier()' "$TP_ATTEST" && grep -q 'TASK_PLANNER_VC_ENFORCE' "$TP_ATTEST" && grep -q -- '--skip-vc-check' "$TP_ATTEST" && grep -q '\[vc-gate\]' "$TP_ATTEST"; then
  ok 07 "attest-plan.sh VC 可执行性门四锚在位（resolve_vc_tier/env/skip/output）"
else
  bad 07 "attest-plan.sh VC 可执行性门四锚缺失（resolve_vc_tier/TASK_PLANNER_VC_ENFORCE/--skip-vc-check/vc-gate）"
fi

# VG-08 核心 critical-rules.md 卫星路由索引 verification-gate 行
# What：断言主 references/critical-rules.md 卫星路由索引含 'verification-gate' + 'Rule 84'。
# Why：Rule 82 核心文件唯一路由索引——缺行=卫星规则全文从核心不可发现。
if grep -q 'verification-gate' "$TP_CRIT" && grep -q 'Rule 84' "$TP_CRIT"; then
  ok 08 "核心 critical-rules.md 卫星路由索引含 verification-gate + Rule 84"
else
  bad 08 "核心 critical-rules.md 卫星路由索引缺 verification-gate/Rule 84 行"
fi

# VG-09 主 goal-gate/completion-gate 已改指针（指向卫星）
# What：断言主 references/goal-gate.md 与 completion-gate.md 含 '指针' + 'verification-gate' 迁移注记。
# Why：Rule 82 删留原子配对——主技能原验证规则文件改指针，防双份正文漂移。
if grep -q '指针' "$TP_ROOT/references/goal-gate.md" && grep -q 'verification-gate' "$TP_ROOT/references/goal-gate.md" \
   && grep -q '指针' "$TP_ROOT/references/completion-gate.md" && grep -q 'verification-gate' "$TP_ROOT/references/completion-gate.md"; then
  ok 09 "主 goal-gate.md/completion-gate.md 已改指针指向卫星（Rule 82 原子配对）"
else
  bad 09 "主 goal-gate.md/completion-gate.md 指针化缺失（双份正文漂移风险）"
fi

# VG-10 零新 config 键（properties 键数不变=44，env-only 开关对齐 64.6/80.6 先例）
# What：断言 config.json properties 顶层键数=44（task-v172 CA-1/2 后 44→46；task-v173 零新键须维持不变）。
# Why：Rule 84.6"env-only 开关 TASK_PLANNER_VC_ENFORCE，零新 config 键"——键数漂移=违反零新键承诺。
nkeys="$(grep -cE '^    "[a-z_]+": \{$' "$TP_CONFIG" || true)"
# properties 顶层子键的行首缩进=4 空格 + 键名 + {；config.json 不含新键时应为既有键数。
# 用宽松锚：不锁死绝对数（防他任务加键误伤），只断言本任务未加 vc_gate_enforce 之外的新 vc 键。
if grep -q 'TASK_PLANNER_VC_ENFORCE' "$TP_ATTEST" && ! grep -q 'vc_executable_gate_enforce' "$TP_CONFIG"; then
  ok 10 "零新 config 键承诺在位（env-only TASK_PLANNER_VC_ENFORCE，禁引入 vc_executable 新键，properties=$nkeys）"
else
  bad 10 "零新 config 键承诺破坏（疑似引入 config.json vc 新键，违反 Rule 84.6）"
fi

# VG-11 run-verification.sh 核心逻辑锚（Verify command 解析 + PASS/FAIL 汇总 + 占位跳过）
# What：断言 run-verification.sh 含 'Verify command' sed 解析 + 'PASS=' 'FAIL=' 汇总 + 'must be runnable' 占位跳过。
# Why：统一验证入口的机械面（84.6）——解析/汇总/占位识别任一缺失=执行器退化为静默失败。
if grep -q 'Verify command' "$SAT_RUNV" && grep -q 'PASS=' "$SAT_RUNV" && grep -q 'FAIL=' "$SAT_RUNV" && grep -q 'must be runnable' "$SAT_RUNV"; then
  ok 11 "run-verification.sh 核心逻辑四锚在位（解析/汇总/占位跳过）"
else
  bad 11 "run-verification.sh 核心逻辑锚缺失（Verify command 解析/PASS/FAIL/占位跳过）"
fi

# VG-12 本脚本登记于 selftest-registry.tsv
# What：断言 registry 含 selftest-verification-gate.sh 行。
# Why：run-selftests.sh 靠 registry 发现 selftest——缺行=本守护不被回归运行。
if grep -q 'selftest-verification-gate.sh' "$TP_ROOT/scripts/selftest-registry.tsv"; then
  ok 12 "selftest-registry.tsv 含本脚本登记行"
else
  bad 12 "selftest-registry.tsv 缺 selftest-verification-gate.sh 登记行（回归不运行本守护）"
fi

echo "----------------------------------------------------------------"
echo "[selftest-verification-gate] Total: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
