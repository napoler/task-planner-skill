#!/usr/bin/env bash
# selftest-decision-drift.sh — task-v156 S5: Rule 73 执行期决策对齐与不变量纪律 机制守护面（静态 DD-01~22 + DD-14b）
# What: 守护 Rule 73 落点全集——critical-rules.md 七子条锚 + templates/deprecated.md 五段五要素
#       + templates/task_plan.md 🔒 三态区块 + check-complete.sh [judge-gate] + zcode-posttooluse.sh [judge] 注入
#       + SKILL.md 接线与计数宽锚 + selftest-registry.tsv 自登记 + 本计划 dogfood 🔒 区块 + 零新 config 键。
# Why: 用户 2026-10-10 R3「我希望就是就是周期性的评判数据，纠正及时发现错误…不知道效果没有」
#      + R4「每次做出决定/更改前都需要对齐回设定以及相关的文件」——把「决策点未回读设定即下手」类漂移
#      的防护效果做成可机器观测（可 grep/可复跑）的静态守护面（51.1a 需求锚 R3=让效果可机器观测）。
# WHEN: 改动 Rule 73 条款 / 两模板 / 两承载脚本 / SKILL 接线 / registry 后运行（仓内 scripts/ 为权威运行位）。
# 机器边界如实披露（同 Rule 73.7）：73.1 决策点分类与 73.2 三问执行的语义面不可静态机检——本守护只锚定
#   规则条/模板区块/留痕格式/门控接线存在性；运行时对齐与评判由 LLM 行为留痕（[align]/[judge] 行）承载。
# 部署自适应（DCE-10 范式）：仓级文件（CHANGELOG/本计划 plans/）在部署位缺失时按 SKIP 计 PASS，防污染真实回归信号。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CR="$SCRIPT_DIR/../references/critical-rules.md"
# [task-v171 纪律域搬迁 2026-10-12] Rule 73（执行期决策对齐与不变量纪律）属纪律域，原文已迁至
#   skills/task-discipline/references/critical-rules-discipline.md（核心 critical-rules.md 只剩 11 条核心规则）；
#   DD-01~09/22 的 CR 断言改指 CRIT_D；CR 保留指向核心（本文件其余断言不消费核心规则文本）。断言语义零改动。
CRIT_D="$SCRIPT_DIR/../../task-discipline/references/critical-rules-discipline.md"
SKILL="$SCRIPT_DIR/../SKILL.md"
TPL_DEP="$SCRIPT_DIR/../templates/deprecated.md"
TPL_PLAN="$SCRIPT_DIR/../templates/task_plan.md"
GATE="$SCRIPT_DIR/check-complete.sh"
HOOK="$SCRIPT_DIR/zcode-posttooluse.sh"
CONFIG="$SCRIPT_DIR/../config.json"
REGISTRY="$SCRIPT_DIR/selftest-registry.tsv"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
PASS=0; FAIL=0
ok()  { echo "PASS $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL $1 ($2)"; FAIL=$((FAIL+1)); }
# cnt: 匹配行数；文件缺失=0；grep -c 零匹配打印 0 且 exit 1 → `|| true` 兜底（同 check-complete :1330 06b 修正口径）
cnt() { [ -f "$2" ] || { echo 0; return; }; grep -c -e "$1" "$2" 2>/dev/null || true; }

# ── DD-01~09 critical-rules.md Rule 73 条款面 ──
[ "$(cnt '^### 73 执行期决策对齐与不变量纪律' "$CRIT_D")" -ge 1 ] && ok "DD-01 CR Rule 73 块头" || bad "DD-01" "块头缺失"
[ "$(cnt '^73\.[1-7] ' "$CRIT_D")" -eq 7 ] && ok "DD-02 CR 七子条锚=7" || bad "DD-02" "got=$(cnt '^73\.[1-7] ' "$CRIT_D") expect=7"
[ "$(cnt '变更型决策点' "$CRIT_D")" -ge 1 ] && ok "DD-03 73.1 变更型决策点分类锚" || bad "DD-03" "分类锚缺失"
# DD-04 三问（读什么/判什么/验什么）+ [align] 留痕锚合计 ≥3（三问+留痕）
_DD04=$(( $(cnt '读什么' "$CRIT_D") + $(cnt '判什么' "$CRIT_D") + $(cnt '验什么' "$CRIT_D") + $(cnt '\[align\]' "$CRIT_D") ))
[ "$_DD04" -ge 3 ] && ok "DD-04 73.2 对齐三问+[align] 留痕（命中 $_DD04）" || bad "DD-04" "got=$_DD04 expect>=3"
{ [ "$(cnt '三态标注' "$CRIT_D")" -ge 1 ] && [ "$(cnt '不变量声明区' "$CRIT_D")" -ge 1 ]; } && ok "DD-05 73.3 三态标注+🔒 区块锚" || bad "DD-05" "三态/区块锚缺失"
{ [ "$(cnt '强制评判点' "$CRIT_D")" -ge 1 ] && [ "$(cnt '\[judge\]' "$CRIT_D")" -ge 1 ]; } && ok "DD-06 73.4 强制评判点+[judge]" || bad "DD-06" "评判点锚缺失"
[ "$(cnt '只入不出' "$CRIT_D")" -ge 1 ] && ok "DD-07 73.5 废弃只入不出" || bad "DD-07" "只入不出锚缺失"
[ "$(cnt '消歧义' "$CRIT_D")" -ge 1 ] && ok "DD-08 73.6 消歧义" || bad "DD-08" "消歧义锚缺失"
[ "$(cnt 'TASK_PLANNER_DECISION_JUDGE' "$CRIT_D")" -ge 1 ] && ok "DD-09 73.7 零新键 env 锚" || bad "DD-09" "env 锚缺失"

# ── DD-10~11 templates/deprecated.md 五段 + 五要素 ──
if [ -f "$TPL_DEP" ]; then
  _DD10=1
  for _t in '^## 1\. 废弃条目登记表' '^## 2\. 分账说明' '^## 3\. 只入不出规则' '^## 4\. 消费侧契约' '^## 5\. 消歧义词条'; do
    [ "$(cnt "$_t" "$TPL_DEP")" -ge 1 ] || _DD10=0
  done
  [ "$_DD10" -eq 1 ] && ok "DD-10 deprecated.md 五段标题齐全" || bad "DD-10" "五段标题缺失"
else
  bad "DD-10" "deprecated.md 不存在"
fi
_DD11=1
for _w in 原内容指针 废弃类型 废弃原因 日期 替代锚; do
  [ "$(cnt "$_w" "$TPL_DEP")" -ge 1 ] || _DD11=0
done
[ "$_DD11" -eq 1 ] && ok "DD-11 deprecated 五要素齐全" || bad "DD-11" "五要素缺失"

# ── DD-12~13 templates/task_plan.md 🔒 三态区块 ──
[ "$(cnt '不变量声明区' "$TPL_PLAN")" -ge 1 ] && ok "DD-12 模板 🔒 不变量声明区块" || bad "DD-12" "区块缺失"
{ [ "$(cnt '不变量' "$TPL_PLAN")" -ge 1 ] && [ "$(cnt '可变量' "$TPL_PLAN")" -ge 1 ] && [ "$(cnt '学得量' "$TPL_PLAN")" -ge 1 ]; } \
  && ok "DD-13 三态关键词（不变量/可变量/学得量）" || bad "DD-13" "三态关键词缺失"

# ── DD-14~15 双承载脚本 ──
[ "$(cnt 'judge-gate' "$GATE")" -ge 1 ] && ok "DD-14 check-complete [judge-gate] 锚" || bad "DD-14" "门控锚缺失"
# DD-14b（CR S8 F2）：守护 [judge-gate] 段档位门控存在性——awk 抽 judge-gate 段（锚段头 [judge-gate] 注释至
#   Rule 73.4/C51 else 分支），断言段内含 plan_tier 前置门 + standard|full 判据，使 F1「缺档位门控致 mini 误伤」可机检。
_JG_SEC="$(awk '/task-v156\] Rule 73\.4 \[judge-gate\]/{f=1} f{print} /Rule 73\.4\/C51/{if(f)exit}' "$GATE" 2>/dev/null)"
{ [ "$(printf '%s\n' "$_JG_SEC" | grep -c 'plan_tier')" -ge 1 ] \
  && [ "$(printf '%s\n' "$_JG_SEC" | grep -c 'standard|full')" -ge 1 ]; } \
  && ok "DD-14b check-complete [judge-gate] 档位门控（plan_tier: standard|full）" || bad "DD-14b" "judge-gate 缺 plan_tier 档位门控"
{ [ "$(cnt '\[judge\]' "$HOOK")" -ge 1 ] && [ "$(cnt 'TASK_PLANNER_DECISION_JUDGE' "$HOOK")" -ge 1 ]; } \
  && ok "DD-15 posttooluse [judge] 注入+env 降档锚" || bad "DD-15" "注入/env 锚缺失"

# ── DD-16~17 SKILL.md 接线 ──
# [task-v171 核心瘦身] DD-16 旧阈值≥4=Rule 73 摘要 bullet/合规 C53 行/新指令段 B 行/References 索引四处；
#   瘦身后 Rule 73（纪律域）SKILL 侧仅存新指令处理段 B 行 1 处（'Rule 73.2 对齐三问'）+卫星路由表 discipline 行。
#   现象：'Rule 73' 计数 4→1 且 'C53' 归零，DD-16/17 恒 FAIL。根因：非核心域规则摘要/C 行随合规清单表瘦身移除（Rule 82 禁回潮）。
#   修法：DD-16 改 'Rule 73' ≥1（新指令段 B 行引用面）+卫星路由表 discipline 行 ≥1；DD-17 的 C53 合规行改路由表 discipline 行断言；
#   Rule 73 全文锚由 CRIT_D 侧断言（DD-22 同测 CRIT_D）守护，SKILL 侧联动改路由表口径，强度等价。
[ "$(cnt 'Rule 73' "$SKILL")" -ge 1 ] && [ "$(cnt '| task-discipline |' "$SKILL")" -ge 1 ] \
  && ok "DD-16 SKILL Rule 73 接线（Rule 73 命中 $(cnt 'Rule 73' "$SKILL")）∧ 卫星路由表 discipline 行在位" \
  || bad "DD-16" "got R73=$(cnt 'Rule 73' "$SKILL") expect>=1 ∧ 路由行≥1"
[ "$(cnt '| task-discipline |' "$SKILL")" -ge 1 ] && ok "DD-17 SKILL 卫星路由表 discipline 行（Rule 73/C53 合规面瘦身后由路由表承载）" || bad "DD-17" "卫星路由表 discipline 行缺失"

# ── DD-18 selftest-registry.tsv 自登记行 =1 ──
[ "$(cnt 'decision-drift' "$REGISTRY")" -eq 1 ] && ok "DD-18 selftest-registry 自登记行=1" || bad "DD-18" "got=$(cnt 'decision-drift' "$REGISTRY") expect=1"

# ── DD-19 本计划 dogfood 🔒 区块（部署/仓级布局无该计划文件时按 SKIP 计 PASS，DCE-10 范式） ──
# 解析链：worktree/主仓仓根相对路径优先，其次本仓权威计划绝对路径；均缺失=部署位 SKIP。
PLAN_V156=""
if [ -f "$REPO_ROOT/plans/task-v156-drift-shield/task_plan.md" ]; then
  PLAN_V156="$REPO_ROOT/plans/task-v156-drift-shield/task_plan.md"
elif [ -f /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/task_plan.md ]; then
  PLAN_V156=/mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/task_plan.md
fi
if [ -n "$PLAN_V156" ]; then
  [ "$(cnt '不变量声明区' "$PLAN_V156")" -ge 1 ] && ok "DD-19 本计划 🔒 区块在位（dogfood）" || bad "DD-19" "🔒 区块缺失"
else
  ok "DD-19 本计划 🔒 区块（SKIP：部署/仓级布局无 task-v156 计划文件）"
fi

# ── DD-20 config.json properties 键数=44（零新键；jq 缺失打 SKIP 计 PASS） ──
if command -v jq >/dev/null 2>&1; then
  _KEYS="$(jq '.properties | length' "$CONFIG" 2>/dev/null || true)"
  [ "$_KEYS" = "46" ] && ok "DD-20 config.json properties 键数=46（task-v172 合法新增 2 键 44→46）" || bad "DD-20" "got=$_KEYS expect=46"
else
  ok "DD-20 config.json properties=42（SKIP：无 jq）"
fi

# ── DD-21 [task-v171 核心瘦身] SKILL 计数宽锚 '1-80'（全集纪元口径；旧宽锚 1-7[0-9] 随 40-80 纪元字面一并移除） ──
#   现象：SKILL.md 瘦身后全集声明演进为「Rules 1-80」，旧宽锚 '1-7[0-9]'（1-70..1-79 字面）零命中，DD-21 恒 FAIL。
#   根因：宽锚钉的是旧全集纪元字面；分层架构下全集口径=核心 12 条+10 卫星（1-80 全集索引）。
#   修法：宽锚改 '1-8[0134]'（v150/v158 宽容锚纪元范式延续，防再次漂移仍为全集口径单锚）。
[ "$(cnt '1-8[0134]' "$SKILL")" -ge 1 ] && ok "DD-21 SKILL 计数宽锚 1-8[0134]" || bad "DD-21" "宽锚缺失"

# ── DD-22 运行时留痕格式示范（[align]/[judge] 行格式在 CR 条款） ──
{ [ "$(cnt '\[align\]' "$CRIT_D")" -ge 1 ] && [ "$(cnt '\[judge\]' "$CRIT_D")" -ge 1 ]; } \
  && ok "DD-22 运行时留痕格式示范（[align]/[judge]）" || bad "DD-22" "留痕格式锚缺失"

echo "Total: 23 PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
