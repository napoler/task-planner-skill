#!/usr/bin/env bash
# selftest-mechanism-profile.sh — task-v085 S8: Rule 37 任务类型机制画像静态守护
# [task-v171 2026-10-12 锚修复] Rule 37 随模板域收编入 plan-template-kit：条款断言（MP-01..07）target=CRIT_T
#   （../plan-template-kit/references/critical-rules-template.md）；SKILL 联动断言 target=plan-template-kit SKILL.md
#   （MP-10/12）+ 核心 SKILL.md 卫星路由表行（MP-11）。守护面语义零改动，详见锚定义处注释。
# 守护（门控+指针范式, 画像终验消费为 check-complete.sh 末段抽查, 本脚本防条款/键/落点误删+行为级双档）:
#   MP-01 critical-rules-template.md 含 Rule 37 头（### 37 任务类型机制画像）
#   MP-02 含 37.1 画像表权威源锚（template-mapping.md §九 + 禁止双源复制）
#   MP-03 含 37.2 判定时点锚（计划创建期）
#   MP-04 含 37.3 三类机制组锚（代码组/内容组/通用组 + 内容组不适用 Code Review Gate）
#   MP-05 含 37.4 消费侧锚（委派检查点先查画像 + Code Review Gate 触发条件）
#   MP-06 含 37.5 机制锚（mechanism_profile_enforce 开关键）
#   MP-07 含 FMEA R1 兜底措辞「通用守卫对全部任务类型不变」
#   MP-08 template-mapping.md 含 §九 机制适用性矩阵（^## 九、）
#   MP-09 矩阵含 writing/research/publish 三行「不适用」
#   MP-10 SKILL.md 含「类型适配（Rule 37）」路由裁剪提示
#   MP-11 SKILL.md 检查清单含 | C25 | 行（Rule 37 画像核对）
#   MP-12 SKILL.md Critical Rules 列表含 Rule 37 行
#   MP-13 config.json 含 mechanism_profile_enforce 键（默认 warn, enum 三档）
#   MP-14 通用模板 task_plan.md 含「机制画像」≥2 处
#   MP-15 template-guide.md 含「机制画像」1 处
#   MP-16 check-complete.sh 含 mechanism-profile 抽查段锚（内容组触发 + 三档档位解析）
#   MP-17 行为: fake plan（writing + code_review required）默认档跑 check-complete.sh 不产生 exit 1
#   MP-18 行为: 同 fake plan 在 TASK_PLANNER_MECHANISM_PROFILE_ENFORCE=enforce 下 exit 1
#   MP-19 行为: off 档整段跳过（无 mechanism-profile 输出且 exit 0）
# 19 断言全 PASS exit 0; 任一 FAIL exit 1。行为级 3 条 fake plan 在 mktemp 目录, 用完即清理。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
# [task-v171 模板域收编 2026-10-12 锚修复] 现象: MP-01..07/10/11/12 FAIL（grep 目标核心 critical-rules.md/SKILL.md 已无 Rule 37 文本——76 条规则分层归属卫星，核心只留 12 条核心规则全文）｜
# 根因: Rule 37（任务类型机制画像）随模板域收编入 plan-template-kit（S25），Rule 37 全文已逐字迁至
#   skills/plan-template-kit/references/critical-rules-template.md；同时核心 SKILL.md 瘦身（S33）删除了
#   C25 合规行、「类型适配（Rule 37）」提示与 Critical Rules 列表 Rule 37 摘要行（非核心域规则勿在核心展开，Rule 82）｜
# 修法（只改断言 target，断言语义零改动——守护面=Rule 37 的条款层+SKILL 消费层在位）:
#   MP-01..07 条款断言改指 CRIT_T（逐字文本已在目标文件 verified: :23-33）；
#   MP-10 改指 plan-template-kit SKILL.md 调用条件段「机制画像（Rule 37）」（原核心 SKILL「类型适配」提示后继面）；
#   MP-11 改指核心 SKILL.md 卫星路由表 plan-template-kit 行（原 C25 合规检查行后继面）；
#   MP-12 改指 plan-template-kit SKILL.md 卫星路由段「Rule 37 任务类型机制画像」（原核心 Critical Rules 摘要行后继面）。
CRIT_T="$SKILL_ROOT/../plan-template-kit/references/critical-rules-template.md"
TPL_SKILL="$SKILL_ROOT/../plan-template-kit/SKILL.md"
TMAP="$SKILL_ROOT/../plan-template-kit/references/template-mapping.md"
TGUIDE="$SKILL_ROOT/../plan-template-kit/references/template-guide.md"
SKILL="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
TPL_TASK="$SKILL_ROOT/templates/task_plan.md"
CC="$SKILL_ROOT/scripts/check-complete.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'MP-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'MP-%s FAIL %s\n' "$1" "$2"; }

# MP-01
if grep -q '^### 37 ' "$CRIT_T" && grep '^### 37 ' "$CRIT_T" | grep -q '任务类型机制画像'; then ok 01 "Rule 37 头"; else bad 01 "Rule 37 头缺失"; fi
# MP-02
if grep '^37\.1 ' "$CRIT_T" | grep -q 'template-mapping.md' && grep '^37\.1 ' "$CRIT_T" | grep -q '禁止在 critical-rules.md 复制'; then ok 02 "37.1 权威源锚"; else bad 02 "37.1 权威源缺失"; fi
# MP-03
if grep '^37\.2 ' "$CRIT_T" | grep -q '计划创建期' && grep '^37\.2 ' "$CRIT_T" | grep -q '立即'; then ok 03 "37.2 判定时点"; else bad 03 "37.2 判定时点缺失"; fi
# MP-04
r373="$(grep '^37\.3 ' "$CRIT_T")"
if printf '%s' "$r373" | grep -q '代码组' && printf '%s' "$r373" | grep -q '内容组' && printf '%s' "$r373" | grep -q '通用组' && printf '%s' "$r373" | grep -q '不适用 Code Review Gate'; then ok 04 "37.3 三类机制组"; else bad 04 "37.3 三类机制组缺失"; fi
# MP-05
if grep '^37\.4 ' "$CRIT_T" | grep -q '先查画像再定执行体' && grep '^37\.4 ' "$CRIT_T" | grep -q 'code_review: required'; then ok 05 "37.4 消费侧"; else bad 05 "37.4 消费侧缺失"; fi
# MP-06
if grep '^37\.5 ' "$CRIT_T" | grep -q 'mechanism_profile_enforce' && grep '^37\.5 ' "$CRIT_T" | grep -q 'selftest-mechanism-profile'; then ok 06 "37.5 机制（开关键+守护）"; else bad 06 "37.5 机制缺失"; fi
# MP-07
if grep -q '通用守卫对全部任务类型不变' "$CRIT_T"; then ok 07 "FMEA R1 兜底措辞"; else bad 07 "缺「通用守卫对全部任务类型不变」兜底"; fi
# MP-08
if grep -q '^## 九、' "$TMAP" && grep '^## 九、' "$TMAP" | grep -q '机制适用性矩阵'; then ok 08 "template-mapping.md §九 矩阵"; else bad 08 "template-mapping.md 缺 §九 矩阵"; fi
# MP-09
if grep -E 'writing' "$TMAP" | grep -q '不适用' && grep -E 'research' "$TMAP" | grep -q '不适用' && grep -E 'publish' "$TMAP" | grep -q '不适用'; then ok 09 "矩阵 writing/research/publish 三行不适用"; else bad 09 "矩阵缺内容组「不适用」行"; fi
# MP-10 [task-v171 2026-10-12 锚修复] 原行为=核心 SKILL.md grep「类型适配（Rule 37）」提示；S33 瘦身后该提示段删除，
# 后继权威面=plan-template-kit SKILL.md 调用条件段「按 template_type 裁剪机制画像（Rule 37）」。语义不变（SKILL 层 Rule 37 消费提示在位）。
if grep -q '机制画像（Rule 37）' "$TPL_SKILL"; then ok 10 "plan-template-kit SKILL.md「机制画像（Rule 37）」调用条件"; else bad 10 "plan-template-kit SKILL.md 缺机制画像（Rule 37）调用条件"; fi
# MP-11 [task-v171 2026-10-12 锚修复] 原行为=核心 SKILL.md grep「| C25 |」合规检查行含 Rule 37；C 清单机制随 S33 瘦身删除，
# 后继权威面=核心 SKILL.md 卫星路由表 plan-template-kit 行（Rule 16,34,37,38 落位）。语义不变（核心 SKILL 对 Rule 37 的路由落位在位）。
if grep 'plan-template-kit' "$SKILL" | grep -qE 'Rule 16,34,37,38'; then ok 11 "核心 SKILL.md 卫星路由表 plan-template-kit 行（Rule 37 落位）"; else bad 11 "核心 SKILL.md 卫星路由表缺 plan-template-kit 行（Rule 37 落位）"; fi
# MP-12 [task-v171 2026-10-12 锚修复] 原行为=核心 SKILL.md「## Critical Rules」列表 grep Rule 37 摘要行；非核心域规则已不在核心列表（Rule 82），
# 后继权威面=plan-template-kit SKILL.md 卫星路由段「Rule 37 任务类型机制画像」摘要。语义不变（Rule 37 摘要行在归属域 SKILL 在位）。
if grep -q 'Rule 37 任务类型机制画像' "$TPL_SKILL"; then ok 12 "plan-template-kit SKILL.md 卫星路由段 Rule 37 摘要"; else bad 12 "plan-template-kit SKILL.md 卫星路由段缺 Rule 37 摘要"; fi
# MP-13
if jq -e '.properties.mechanism_profile_enforce | .default=="warn" and ((.enum|sort)|. == ["enforce","off","warn"])' "$CONFIG" >/dev/null 2>&1; then
  ok 13 "config.json mechanism_profile_enforce（warn 默认+三档）"
else
  bad 13 "config.json mechanism_profile_enforce 缺失/默认非 warn/enum 非三档"
fi
# MP-14
mp_count="$(grep -c '机制画像' "$TPL_TASK")"
if [ "${mp_count:-0}" -ge 2 ]; then ok 14 "task_plan.md「机制画像」≥2 处（实测 ${mp_count}）"; else bad 14 "task_plan.md「机制画像」仅 ${mp_count:-0} 处（需 ≥2）"; fi
# MP-15
tg_count="$(grep -c '机制画像' "$TGUIDE")"
if [ "${tg_count:-0}" -ge 1 ]; then ok 15 "template-guide.md「机制画像」（实测 ${tg_count}）"; else bad 15 "template-guide.md 缺「机制画像」"; fi
# MP-16
if grep -q 'mechanism-profile' "$CC" && grep -q 'TASK_PLANNER_MECHANISM_PROFILE_ENFORCE' "$CC" && grep -q 'mechanism_profile_enforce' "$CC"; then ok 16 "check-complete.sh mechanism-profile 抽查段锚"; else bad 16 "check-complete.sh 缺抽查段锚"; fi
# MP-17/18/19 行为级双档（fake plan: writing + code_review required + 2 complete Phase + S-unit 表 + VC 表 5 行
# + findings/progress 非 stub, 放行前置 3-File/委派率/VC/PLAN-DISPATCH gate, 归因到 mechanism-profile 段; mktemp 用完即清理）
T="$(mktemp -d /tmp/mp-selftest.XXXXXX)"
cat > "$T/task_plan.md" <<'FAKE_EOF'
# 任务计划（selftest fake plan — 非真实任务）

| 字段 | 值 |
| --- | --- |
| template_type | writing |
| code_review | required |

### Phase 1: 写稿
- **Status:** complete
- **Executor:** article-writer
- **V-N:** VC-1, VC-2

| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
| --- | --- | --- | --- | --- | --- | --- |
| S1 | 完成初稿 | article-writer | task_plan.md | 初稿产出 | 10min | complete |

### Phase 2: 校对
- **Status:** complete
- **Executor:** article-writer
- **V-N:** VC-3, VC-4

| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
| --- | --- | --- | --- | --- | --- | --- |
| S1 | 完成校对 | article-writer | task_plan.md | 校对完成 | 10min | complete |

## Handoff

| 子代理类型 | 职责 |
| --- | --- |
| article-writer | 内容写作执行体 |

## Verification

| ID | 验证项 |
| --- | --- |
| VC-1 | 标题合规 |
| VC-2 | 结构完整 |
| VC-3 | 无错别字 |
| VC-4 | 链接有效 |
| VC-5 | 配图达标 |
FAKE_EOF
printf '%s\n' "# Findings（selftest fake）" "- F1: fake plan 静态构造" "- F2: 前置 gate 全放行验证" "- F3: mechanism-profile 段归因验证" > "$T/findings.md"
printf '%s\n' "# Progress（selftest fake）" "- 2026-09-20 P1 写稿 complete" "- 2026-09-20 P2 校对 complete" "- mechanism-profile 抽查段验证" > "$T/progress.md"
out="$(bash "$CC" "$T/task_plan.md" 2>&1)"
rc=$?
if [ "$rc" -eq 0 ] && printf '%s\n' "$out" | grep -q '^\[mechanism-profile\] ⚠'; then ok 17 "行为: 默认档 exit 0 且打 ⚠ 提示（基线不变）"; else bad 17 "行为: 默认档 rc=$rc（应 exit 0 且 ⚠ 提示）"; fi
out="$(TASK_PLANNER_MECHANISM_PROFILE_ENFORCE=enforce bash "$CC" "$T/task_plan.md" 2>&1)"
rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q '^\[mechanism-profile\] ✗'; then ok 18 "行为: enforce 档 exit 1 且打 ✗"; else bad 18 "行为: enforce 档 rc=$rc（应 exit 1 且 ✗）"; fi
out="$(TASK_PLANNER_MECHANISM_PROFILE_ENFORCE=off bash "$CC" "$T/task_plan.md" 2>&1)"
rc=$?
mp_lines="$(printf '%s\n' "$out" | grep -c 'mechanism-profile' || true)"
if [ "$rc" -eq 0 ] && [ "${mp_lines:-0}" -eq 0 ]; then ok 19 "行为: off 档整段跳过（exit 0, 无输出）"; else bad 19 "行为: off 档 rc=$rc lines=$mp_lines（应 exit 0 且 0 行）"; fi
rm -rf "$T"

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
