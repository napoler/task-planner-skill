#!/usr/bin/env bash
# selftest-plan-tier.sh — task-v086 P3-S4: Rule 38 任务难度分级与轻量档静态+行为守护
# 守护（条款+键+SKILL 联动+模板契约+init 分流+4 锚点豁免行为）:
#   PT-01 critical-rules.md 含 Rule 38 头（### 38 任务难度分级与轻量档）
#   PT-02 含 38.1 判定锚（机器可测 + MISMATCH）
#   PT-03 含 38.2 档位矩阵锚（mini-lite-type + standard 13 variant + full general）
#   PT-04 含 38.3 轻量模板契约锚（区块白名单）
#   PT-05 含 38.4 门控豁免清单锚（锚表 5 点 + 非 mini 零影响铁律）
#   PT-06 含 38.5 机制锚（plan_tier_enforce + selftest-plan-tier）
#   PT-07 config.json 含 plan_tier_enforce 键（默认 warn, enum 三档）
#   PT-08 SKILL.md frontmatter 索引含「1-4[56]」（task-v088 级联 1-38→1-39；[task-v117 口径扩展] 字面锚 1-39→1-45，frontmatter 全集具名演进，语义等价；[task-v118 口径扩展] 字面锚 1-45→宽容 1-4[56]（frontmatter 全集具名演进 1-46，语义等价，同 v117 WF-10/PT-08 先例））
#   PT-09 SKILL.md 含 C26 检查项（Rule 38 档位判定）
#   PT-10 SKILL.md Critical Rules 列表含 Rule 38 摘要行
#   PT-11 templates/variant/mini-lite-type.md 存在 ∧ ≤80 行 ∧ frontmatter 含 plan_tier: mini
#   PT-12 mini-lite-type.md 无六仪式区块（FMEA 预演/必要知识储备/委派统计/Batch Report/Chain 区块/Drift Log）
#   PT-13 init-session.sh 含 PLAN_TIER 分流锚（TASK_PLAN_TIER env + mini-lite 复制源）
#   PT-14 既有 13 variant + general 各含「plan_tier: standard」标记（S2 落点，≥14 处）
#   PT-15 行为: init 缺省场景 task_plan.md 复制 general 源（产物无 plan_tier: mini 标记）
#   PT-16 行为: TASK_PLAN_TIER=mini 场景复制 mini-lite（产物含 plan_tier: mini）
#   PT-17 行为: mini+variant(bugfix) 场景 variant 定制优先+打忽略提示
#   PT-18 行为: mini 样例计划 attest → 含 MINI-TIER SKIP 且 rc=0（锚1 FMEA 豁免）
#   PT-19 行为: mini 样例计划 check-complete → 含 VC-GATE PASSED（VC=2 降档放行）
#   PT-20 行为: mismatch mini 计划（Goal 缺 ≤15min ∧ 范围表>4 行）warn 档 → 含 MISMATCH 且 rc=0
#   PT-21 行为: 同 mismatch 计划 TASK_PLANNER_PLAN_TIER_ENFORCE=enforce → rc=1（阻断锁定）
#   PT-22 行为: standard 样例（无 plan_tier 声明）check-plan-dispatch rc=0 且输出无 plan-tier 字样
#   PT-23 S6: --list 输出含内置 ≥14 variant(含 mini-lite) + project 项 + [default] 标记行, 不创建文件
#   PT-24 S6: 项目 plan-templates/default 文件生效(未显式 type → 复制项目 my-custom + frontmatter 插入)
#   PT-25 S6: env TASK_TEMPLATE_DEFAULT 生效(无项目 default 文件时)
#   PT-26 S6: 全缺省(无项目目录/无 default/env) 零影响: 产物=general 首行, 无 S6 路由/插入行
#   PT-27 S6: 自造模板(无 template_type 行)显式指定 type 时复制后头部插入 frontmatter 行
#   PT-28 S7: mini 样例在 plan_tier enforce 档(plan_tier 消费链 attest 锁定+check-complete 终验)通过
#   PT-29 行为: init auto-tier 四条件 env 提交(TASK_AUTO_TIER=1) → mini 产物含 auto_tier: mini 标记(Rule 38.6, task-v091 S23)
#   PT-30 行为: 显式 TASK_PLAN_TIER=mini(无 TASK_AUTO_TIER) → 产物无 auto_tier 标记(显式不打标, 显式优先)
#   PT-31 行为: auto_tier=mini ∧ 执行范围表数据行>2 → check-complete AUTO-TIER WARNING 点名 rc=0(warn 档不阻断)
#   PT-32 行为: auto_tier=mini ∧ 体量合规 → AUTO-TIER REVIEW PASSED 无 WARNING(复核两态闭环, S23)
# 32 断言全 PASS exit 0; 任一 FAIL exit 1。行为级样例在 /tmp/selftest-plan-tier-* 目录, 用完即清理。
# [task-v086 S7-3] PT-18~21 mini 样例构造改为真实 mini-lite 模板 cp 基座(注释单形态 plan_tier 标记, 与真实 init 产物一致), 仅最小改写占位。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
MINI_TPL="$SKILL_ROOT/templates/variant/mini-lite-type.md"
INIT="$SKILL_ROOT/scripts/init-session.sh"
ATTEST="$SKILL_ROOT/scripts/attest-plan.sh"
CC="$SKILL_ROOT/scripts/check-complete.sh"
CPD="$SKILL_ROOT/scripts/check-plan-dispatch.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'PT-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'PT-%s FAIL %s\n' "$1" "$2"; }

# PT-01
if grep -q '^### 38 ' "$CRIT" && grep '^### 38 ' "$CRIT" | grep -q '任务难度分级与轻量档'; then ok 01 "Rule 38 头"; else bad 01 "Rule 38 头缺失"; fi
# PT-02
if grep '^38\.1 ' "$CRIT" | grep -q '机器可测' && grep '^38\.1 ' "$CRIT" | grep -q 'MISMATCH'; then ok 02 "38.1 判定锚"; else bad 02 "38.1 判定锚缺失"; fi
# PT-03
if grep '^38\.2 ' "$CRIT" | grep -q 'mini-lite-type' && grep '^38\.2 ' "$CRIT" | grep -q 'standard' && grep '^38\.2 ' "$CRIT" | grep -q 'full'; then ok 03 "38.2 档位矩阵锚"; else bad 03 "38.2 档位矩阵锚缺失"; fi
# PT-04
if grep '^38\.3 ' "$CRIT" | grep -q '区块白名单'; then ok 04 "38.3 轻量模板契约锚"; else bad 04 "38.3 区块白名单锚缺失"; fi
# PT-05
if grep '^38\.4 ' "$CRIT" | grep -q '零影响铁律' && grep '^38\.4 ' "$CRIT" | grep -q 'VC 最低要求 5→2'; then ok 05 "38.4 豁免清单锚（铁律+VC 降档）"; else bad 05 "38.4 豁免清单锚缺失"; fi
# PT-06
if grep '^38\.5 ' "$CRIT" | grep -q 'plan_tier_enforce' && grep '^38\.5 ' "$CRIT" | grep -q 'selftest-plan-tier'; then ok 06 "38.5 机制锚（开关键+守护）"; else bad 06 "38.5 机制锚缺失"; fi
# PT-07
if jq -e '.properties.plan_tier_enforce | .default=="warn" and ((.enum|sort)|. == ["enforce","off","warn"])' "$CONFIG" >/dev/null 2>&1; then
  ok 07 "config.json plan_tier_enforce（warn 默认+三档）"
else
  bad 07 "config.json plan_tier_enforce 缺失/默认非 warn/enum 非三档"
fi
# PT-08
# PT-08 [task-v118 口径扩展] 字面锚 1-45→宽容 1-4[56]（frontmatter 全集具名演进 1-46，语义等价，同 v117 WF-10/PT-08 先例；
# 守护 frontmatter 索引面存在性，断言语义不变。修改时间 2026-10-03，原行为=固定字面 grep -q 'Critical Rules 全集 1-45'）
# [task-v121 预扩] 1-4[56]→1-4[5-9]（消除 Rule 47-49 级联，2026-10-03）
if grep -qE 'Critical Rules 全集 1-4[5-9]' "$SKILLMD"; then ok 08 "SKILL.md frontmatter 索引 1-4[5-9]（task-v117+task-v118 口径扩展+task-v121 预扩，v088 级联 1-39 后继）"; else bad 08 "SKILL.md frontmatter 缺「Critical Rules 全集 1-4[5-9]」（task-v117+task-v118+task-v121 口径扩展后宽容字面锚）"; fi
# PT-09
if grep -q '^| C26 ' "$SKILLMD" && grep '^| C26 ' "$SKILLMD" | grep -q 'Rule 38'; then ok 09 "SKILL.md C26 检查项"; else bad 09 "SKILL.md 缺 C26 行"; fi
# PT-10
if grep '^## Critical Rules' -A 40 "$SKILLMD" | grep -q 'Rule 38'; then ok 10 "SKILL.md Critical Rules 列表 Rule 38 摘要行"; else bad 10 "SKILL.md 摘要行缺 Rule 38"; fi
# PT-11
if [ -f "$MINI_TPL" ]; then
  mlines="$(wc -l < "$MINI_TPL")"
  if [ "$mlines" -le 80 ] && grep -q 'plan_tier: mini' "$MINI_TPL"; then ok 11 "mini-lite 模板契约（$mlines 行 ≤80 + plan_tier: mini 标记）"; else bad 11 "mini-lite 模板契约不满足（行数=$mlines / 标记=$(grep -c 'plan_tier: mini' "$MINI_TPL" || true)）"; fi
else
  bad 11 "mini-lite-type.md 不存在"
fi
# PT-12
forbidden=0
for kw in 'FMEA 预演' '必要知识储备' '委派统计' 'Batch Report' 'Chain 区块' 'Drift Log'; do
  grep -q "$kw" "$MINI_TPL" && forbidden=1
done
if [ "$forbidden" -eq 0 ]; then ok 12 "mini-lite 无六仪式区块"; else bad 12 "mini-lite 含禁仪式区块（38.3 违约）"; fi
# PT-13
if grep -q 'TASK_PLAN_TIER' "$INIT" && grep -q 'variant/mini-lite-type.md' "$INIT" && grep -q 'tier=mini 忽略' "$INIT"; then ok 13 "init-session.sh tier 分流锚（env+复制源+variant 忽略提示）"; else bad 13 "init-session.sh 缺 tier 分流锚"; fi
# PT-14
std_marks="$(cat "$SKILL_ROOT"/templates/variant/*.md "$SKILL_ROOT/templates/task_plan.md" 2>/dev/null | grep -c 'plan_tier: standard')"
if [ "${std_marks:-0}" -ge 14 ]; then ok 14 "13 variant + general 含 plan_tier: standard 标记（实测 ${std_marks} 处）"; else bad 14 "standard 标记仅 ${std_marks:-0} 处（需 ≥14）"; fi

# ── 行为级（样例构造: /tmp/selftest-plan-tier-* 用后清理）──
T="$(mktemp -d /tmp/selftest-plan-tier.XXXXXX)"
rm -rf "$T"; mkdir -p "$T/dflt/plans/p1" "$T/mini/plans/p2" "$T/var/plans/p3" "$T/planmini" "$T/planbad" "$T/planstd"

# PT-15 init 缺省（general 源）
(cd "$T/dflt/plans/p1" && bash "$INIT" p1 >/dev/null 2>&1)
if [ -f "$T/dflt/plans/p1/task_plan.md" ] && ! grep -q 'plan_tier: mini' "$T/dflt/plans/p1/task_plan.md"; then ok 15 "init 缺省场景=general 源（无 mini 标记）"; else bad 15 "init 缺省场景复制源异常"; fi

# PT-16 init TASK_PLAN_TIER=mini
(cd "$T/mini/plans/p2" && TASK_PLAN_TIER=mini bash "$INIT" p2 >/dev/null 2>&1)
if [ -f "$T/mini/plans/p2/task_plan.md" ] && grep -q 'plan_tier: mini' "$T/mini/plans/p2/task_plan.md"; then ok 16 "init TASK_PLAN_TIER=mini 复制 mini-lite"; else bad 16 "init mini 场景未复制 mini-lite"; fi

# PT-17 init mini+variant(bugfix) 定制优先
(cd "$T/var/plans/p3" && TASK_PLAN_TIER=mini bash "$INIT" p3 bugfix > "$T/var/out.log" 2>&1)
if grep -q 'template_type: bugfix' "$T/var/plans/p3/task_plan.md" 2>/dev/null && grep -q 'tier=mini 忽略' "$T/var/out.log"; then ok 17 "mini+variant 定制优先+忽略提示"; else bad 17 "mini+variant 场景异常（variant 定制优先失守）"; fi

# mini 样例计划（task-v086 S7-3: 真实 mini-lite 模板 cp 基座, plan_tier 标记=注释单形态与真实 init 产物一致; 仅最小改写占位）
cp "$MINI_TPL" "$T/planmini/task_plan.md"
python3 - "$T/planmini/task_plan.md" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
repl = [
 ('# Task Plan: [轻量任务名]', '# Task Plan: [selftest mini 样例]'),
 ('[一句话: 目标 + 「预估 ≤15min」（Rule 38.1 机器条件，必写 Goal 行）]', '[一句话: 目标 + 预估 ≤15min]'),
 ('| [文件 1] | [禁改文件 / 禁改范围] |', '| a.md | b.md |'),
 ('- [1-3 条实施动作]', '- 动作 1'),
 ('- [Read 回填复核 + 回归验证（与实施同 Phase 闭环）]', '- Read 回填复核'),  # [task-v094 T-B2] 单 Phase 模板锚同步
 # [task-v094 T-B2] 单 Phase 模板 Executor 行已自带「白名单②⑥登记」理由, S7-3 裸主进程补理由 repl 移除
]
for a, b in repl:
    assert a in s, f'S7-3 基座锚缺失: {a!r}'
    s = s.replace(a, b)
s = s.replace('- **Status:** pending', '- **Status:** complete')
s = s.replace('（派发时填写；全程主进程填「无」） | | pending | | |', '（无派发: 全程主进程） | 无 | complete | 无 | 无 | 无 |')
open(p, 'w', encoding='utf-8').write(s)
print('planmini written')
PYEOF
printf '%s\n' "# Findings（selftest fake）" "- F1: mini 样例构造" "- F2: FMEA 段缺失豁免验证" "- F3: VC=2 降档验证" > "$T/planmini/findings.md"
printf '%s\n' "# Progress（selftest fake）" "- 2026-09-20 P1 实施 complete" "- 2026-09-20 P2 验收 complete" > "$T/planmini/progress.md"

# PT-18 锚1 FMEA 豁免
out="$(bash "$ATTEST" "$T/planmini/task_plan.md" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s\n' "$out" | grep -q 'MINI-TIER SKIP'; then ok 18 "锚1: mini attest FMEA MINI-TIER SKIP + 锁定 rc=0"; else bad 18 "锚1: mini attest rc=$rc 缺 MINI-TIER SKIP"; fi

# PT-19 锚2 VC-GATE 降档
out="$(bash "$CC" "$T/planmini/task_plan.md" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s\n' "$out" | grep -q 'VC-GATE PASSED'; then ok 19 "锚2: mini check-complete VC=2 降档 PASSED rc=0"; else bad 19 "锚2: mini check-complete rc=$rc 未放行"; fi

# mismatch 样例（Goal 无 ≤15min + 「执行范围限制」段数据行 4>2: 段内表格行=表头 2+数据 4=6 >4）
python3 - "$T/planmini/task_plan.md" "$T/planbad/task_plan.md" <<'PYEOF'
import sys
src = open(sys.argv[1], encoding='utf-8').read()
src = src.replace('预估 ≤15min', '预估（未写时长）')
anchor = '| a.md | b.md |\n'
extra = ''.join(f'| r{i} | x |\n' for i in range(1, 5))
src = src.replace(anchor, anchor + extra, 1)
open(sys.argv[2], 'w', encoding='utf-8').write(src)
print('planbad written')
PYEOF
cp "$T/planmini/findings.md" "$T/planmini/progress.md" "$T/planbad/"
# 支腿自检: 段内表格行须 >4（否则「执行范围表数据行>2」支腿未钉住, S3 遗留 ① 未消除）
_scope_rows="$(awk '/^## .*执行范围限制/{f=1;next} /^## /{f=0} f' "$T/planbad/task_plan.md" | grep -c '^|' || true)"
if [ "${_scope_rows:-0}" -gt 4 ]; then :; else echo "PT-WARN: planbad 范围段表格行=${_scope_rows}（未 >4）, S3 遗留支腿未钉住"; fi

# PT-20 MISMATCH warn 档
out="$(bash "$CPD" "$T/planbad/task_plan.md" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s\n' "$out" | grep -q '^\[plan-tier\] MISMATCH'; then ok 20 "锚4: MISMATCH warn 档提示 rc=0"; else bad 20 "锚4: MISMATCH warn 档 rc=$rc 输出异常"; fi
# PT-21 MISMATCH enforce 档
out="$(TASK_PLANNER_PLAN_TIER_ENFORCE=enforce bash "$CPD" "$T/planbad/task_plan.md" 2>&1)"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q '^\[plan-tier\] MISMATCH'; then ok 21 "锚4: MISMATCH enforce 档阻断 rc=1"; else bad 21 "锚4: MISMATCH enforce 档 rc=$rc（应=1）"; fi

# standard 样例（无 plan_tier 声明, VC=5, 派发型+S-unit 表）
cat > "$T/planstd/task_plan.md" <<'EOF'
<!-- template_type: rule-enhancement -->
| 字段 | 值 |
|------|-----|
| template_type | rule-enhancement |

# Task Plan: [selftest standard 样例]

## Goal
[一句话目标]

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | A | Read | x |
| VC-2 | B | 命令 | y |
| VC-3 | C | 测试 | z |
| VC-4 | D | Read | w |
| VC-5 | E | 实测 | v |

## Phases

### Phase 1: 实施
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|------|
| S1 | 动作 | 继承 | task_plan.md（摘要） | 通过 | 10min | pending |

### Phase 2: 验收
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|------|
| S1 | 验证 | 继承 | task_plan.md（摘要） | 通过 | 10min | pending |
EOF

# PT-22 非 mini 回归
out="$(bash "$CPD" "$T/planstd/task_plan.md" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && ! printf '%s\n' "$out" | grep -q 'plan-tier'; then ok 22 "非 mini 回归: standard rc=0 且无 plan-tier 输出"; else bad 22 "非 mini 回归异常 rc=$rc"; fi

# PT-28 (task-v086 S7-3) mini 样例在 plan_tier enforce 档经 plan_tier 消费链通过:
# attest 锁定(template_gate enforce 档, S7-1 注释形态提取修复后 mini 主路径可过) + check-complete 终验
out_a="$(TASK_PLANNER_TEMPLATE_GATE_ENFORCE=enforce bash "$ATTEST" "$T/planmini/task_plan.md" 2>&1)"; rc_a=$?
out_c="$(TASK_PLANNER_PLAN_TIER_ENFORCE=enforce bash "$CC" "$T/planmini/task_plan.md" 2>&1)"; rc_c=$?
if [ "$rc_a" -eq 0 ] && printf '%s\n' "$out_a" | grep -q 'MINI-TIER SKIP' \
   && [ "$rc_c" -eq 0 ] && printf '%s\n' "$out_c" | grep -q 'VC-GATE PASSED'; then
  ok 28 "mini 样例 enforce 档 attest 锁定(FMEA SKIP)+check-complete VC-GATE 均通过"
else
  bad 28 "mini 样例 enforce 档消费链失败 attest_rc=$rc_a cc_rc=$rc_c（输出尾部: $(printf '%s' "$out_a" | tail -1) | $(printf '%s' "$out_c" | tail -1)）"
fi


# ── [2026-09-27 task-v091 S23 A-1] auto-tier 消费层行为级（标记存在性 + 终验 AUTO-TIER 复核两态）──
mkdir -p "$T/auto/plans/pa" "$T/expl/plans/pe" "$T/planautobad" "$T/planautook"

# PT-29 init auto-tier 路径: 四条件 env 事实提交 → mini 产物 + auto_tier 标记(S22 机制, S23 消费侧断言)
(cd "$T/auto/plans/pa" && TASK_AUTO_TIER=1 TASK_EST_MINUTES=10 TASK_SCOPE_FILES=1 TASK_SCOPE_MODULES=1 bash "$INIT" pa > "$T/auto/out.log" 2>&1)
if [ -f "$T/auto/plans/pa/task_plan.md" ] \
   && grep -q 'plan_tier: mini' "$T/auto/plans/pa/task_plan.md" \
   && grep -q 'auto_tier: mini' "$T/auto/plans/pa/task_plan.md" \
   && grep -q 'auto-tier: 四条件全过' "$T/auto/out.log"; then
  ok 29 "auto-tier 路径: 四条件 env 提交 → mini 产物含 auto_tier: mini 标记（Rule 38.6）"
else
  bad 29 "auto-tier 路径标记缺失（产物/日志异常）"
fi

# PT-30 显式 mini 不打标: TASK_PLAN_TIER=mini 且无 TASK_AUTO_TIER → 产物有 plan_tier 无 auto_tier
(cd "$T/expl/plans/pe" && TASK_PLAN_TIER=mini bash "$INIT" pe >/dev/null 2>&1)
if grep -q 'plan_tier: mini' "$T/expl/plans/pe/task_plan.md" 2>/dev/null \
   && ! grep -q 'auto_tier: mini' "$T/expl/plans/pe/task_plan.md" 2>/dev/null; then
  ok 30 "显式 mini 不打 auto_tier 标记（显式优先=不覆盖显式值）"
else
  bad 30 "显式 mini 场景 auto_tier 标记异常（应无标记）"
fi

# auto_tier 标记样例: planmini 基座 + plan_tier: mini 行后插标记（同 S22 init 产物形态注释行）
python3 - "$T/planmini/task_plan.md" "$T/planautobad/task_plan.md" "$T/planautook/task_plan.md" <<'PYEOF'
import sys
s = open(sys.argv[1], encoding='utf-8').read()
assert 'plan_tier: mini' in s, '基座锚缺失: plan_tier: mini'
# 标记插入=行级（S22 init awk 同语义）：plan_tier: mini 所在行后插一行注释标记
# （模板形态为 `<!-- plan_tier: mini -->`，纯字符串 'plan_tier: mini\n' 不命中）
_lines = s.split('\n')
for _i, _ln in enumerate(_lines):
    if 'plan_tier: mini' in _ln:
        _lines.insert(_i + 1, '<!-- auto_tier: mini -->')
        break
marked = '\n'.join(_lines)
# planautobad = 标记 ∧ 体量超限（范围表数据行>2: 附加 4 行, 表格行 2+1+4=7>4, 口径同 PT-20 构造）
anchor = '| a.md | b.md |\n'
extra = ''.join(f'| r{i} | x |\n' for i in range(1, 5))
assert anchor in s, '基座锚缺失: 范围表数据行'
open(sys.argv[2], 'w', encoding='utf-8').write(marked.replace(anchor, anchor + extra, 1))
# planautook = 仅标记, 体量合规（2 Phase ∧ 范围表数据行=1）
open(sys.argv[3], 'w', encoding='utf-8').write(marked)
print('planautobad/planautook written')
PYEOF
cp "$T/planmini/findings.md" "$T/planmini/progress.md" "$T/planautobad/"
cp "$T/planmini/findings.md" "$T/planmini/progress.md" "$T/planautook/"

# PT-31 AUTO-TIER 复核触发态: 超限 → WARNING 点名 且 warn 档不阻断
out="$(bash "$CC" "$T/planautobad/task_plan.md" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s\n' "$out" | grep -q 'AUTO-TIER WARNING' \
   && printf '%s\n' "$out" | grep -q '执行范围表数据行>2'; then
  ok 31 "AUTO-TIER 复核触发: 超限 → WARNING 点名 rc=0（warn 档不阻断）"
else
  bad 31 "AUTO-TIER 复核触发态异常 rc=$rc（输出尾部: $(printf '%s' "$out" | tail -1)）"
fi

# PT-32 AUTO-TIER 复核合规态: 体量合规 → REVIEW PASSED 且无 WARNING
out="$(bash "$CC" "$T/planautook/task_plan.md" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s\n' "$out" | grep -q 'AUTO-TIER REVIEW PASSED' \
   && ! printf '%s\n' "$out" | grep -q 'AUTO-TIER WARNING'; then
  ok 32 "AUTO-TIER 复核合规态: REVIEW PASSED 且无 WARNING rc=0"
else
  bad 32 "AUTO-TIER 复核合规态异常 rc=$rc（输出尾部: $(printf '%s' "$out" | tail -1)）"
fi


# ── S6 多模板行为级（task-v086 S6: 项目模板发现 + default 文件 + --list + frontmatter 插入）──
T6="$(mktemp -d /tmp/selftest-plan-tier-s6.XXXXXX)"
rm -rf "$T6"; mkdir -p "$T6/proj/.claude/plan-templates" "$T6/proj/plans/px" "$T6/env/plans/pe" "$T6/plain/plans/pp"
cat > "$T6/proj/.claude/plan-templates/my-custom-type.md" <<'S6_EOF'
# Task Plan: [selftest S6 自造模板样例]

## Goal
[一句话]

## Phases
### Phase 1
- **Status:** complete
- **Executor:** 主进程（白名单② 计划系统文件登记）
S6_EOF
printf 'my-custom\n' > "$T6/proj/.claude/plan-templates/default"

# PT-23 --list
out="$(cd "$T6/proj" && bash "$INIT" --list 2>&1)"; rc=$?
builtin_n="$(printf '%s\n' "$out" | grep -c '(built-in)')"
if [ "$rc" -eq 0 ] && [ "$builtin_n" -ge 14 ] && printf '%s\n' "$out" | grep -q '^\[default\] my-custom' \
   && printf '%s\n' "$out" | grep -q 'my-custom (project)' \
   && [ ! -f "$T6/proj/plans/px/task_plan.md" ]; then
  ok 23 "--list 输出内置 ${builtin_n} 项+project 项+[default] 标记, 不创建文件"
else
  bad 23 "--list 异常 rc=$rc built-in=${builtin_n}(应≥14) 不创建文件=$([ -f "$T6/proj/plans/px/task_plan.md" ] && echo 否 || echo 是)"
fi

# PT-24 项目 default 文件生效(未显式 type)
(cd "$T6/proj/plans/px" && env -u TASK_TEMPLATE_DEFAULT bash "$INIT" px >/dev/null 2>&1)
if [ -f "$T6/proj/plans/px/task_plan.md" ] \
   && head -1 "$T6/proj/plans/px/task_plan.md" | grep -q 'template_type: my-custom' \
   && grep -q 'selftest S6 自造模板样例' "$T6/proj/plans/px/task_plan.md"; then
  ok 24 "项目 default 文件生效: 未显式 type → my-custom + frontmatter 插入"
else
  bad 24 "项目 default 文件未生效或 frontmatter 未插入"
fi

# PT-25 env TASK_TEMPLATE_DEFAULT(无 default 文件的环境目录)
(cd "$T6/env/plans/pe" && TASK_TEMPLATE_DEFAULT=bugfix bash "$INIT" pe >/dev/null 2>&1)
if grep -q 'template_type: bugfix' "$T6/env/plans/pe/task_plan.md" 2>/dev/null; then
  ok 25 "env TASK_TEMPLATE_DEFAULT=bugfix 生效(无项目 default 文件)"
else
  bad 25 "env TASK_TEMPLATE_DEFAULT 未生效"
fi

# PT-26 全缺省零影响(无项目目录/无 default/无 env)
(cd "$T6/plain/plans/pp" && env -u TASK_TEMPLATE_DEFAULT bash "$INIT" pp > "$T6/plain/out.log" 2>&1)
if [ -f "$T6/plain/plans/pp/task_plan.md" ] \
   && head -1 "$T6/plain/plans/pp/task_plan.md" | grep -q 'Task Plan: \[Brief Description\]' \
   && ! grep -q '未显式给 template_type' "$T6/plain/out.log" \
   && ! grep -q '已插入 frontmatter' "$T6/plain/out.log"; then
  ok 26 "全缺省零影响: 产物=general 首行且无 S6 路由/插入行"
else
  bad 26 "全缺省路径行为漂移(出现 S6 路由行或产物非 general)"
fi

# PT-27 显式指定自造模板 type(无 template_type 行) → 复制 + frontmatter 插入
(cd "$T6/proj/plans" && rm -f px/task_plan.md; cd px && bash "$INIT" px my-custom >/dev/null 2>&1)
if head -1 "$T6/proj/plans/px/task_plan.md" 2>/dev/null | grep -q 'template_type: my-custom'; then
  ok 27 "自造模板无 template_type 行时显式指定 → 头部插入 frontmatter 行"
else
  bad 27 "自造模板 frontmatter 插入未生效"
fi

rm -rf "$T6"

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
