#!/usr/bin/env bash
# selftest-subagent-activation.sh — task-subagent-boost-20261023 S6: Rule 96 子代理激活默认档与并行推进强化静态守护
# 守护定位（Rule 96 为 LLM 行为面条款+零新机器门, 本脚本=防条款误删/半截落地/纪元级联残留的静态锚, 断言对象=技能源文件, 只读零副作用）:
#   SA-01 critical-rules-dispatch.md 含 Rule 96 段标题（^### 96 子代理激活默认档与并行推进强化）
#   SA-02 含 96.1 激活默认档矩阵（双键判定防半截落地）
#   SA-03 96.1 七类触发类别锚 ≥6 命中（制定计划/调研分析/多文件搜索/大文件/验证/审查/批量既定步骤/独立创作单元; 容忍 1 类措辞演进）
#   SA-04 96.1 主进程例外窄白名单三锚（单行命令/单事实查询/一句话理由）
#   SA-05 含 96.2 模型分档（中档 sonnet-1 锚; 轻档 haiku-1 为 21.3 既有不重锚）
#   SA-06 含 96.3 计划期并行硬标注（未声明且未按 68.2 论证=计划缺陷）
#   SA-07 含 96.4 执行期同消息并发（同一消息+并发）
#   SA-08 含 96.5 指标留痕（最大并行宽度）
#   SA-09 含 96.6 管辖边界（执行强化层）
#   SA-10 核心 critical-rules.md 卫星路由行枚举扩员（…,52,59,68,96）
#   SA-11 SKILL.md 纪元字面 1-96 ≥3 处（宽容正则 1-96([^0-9]|$); 基线 0 见 draft-rule96 E23, 级联后=frontmatter/正文全集索引/References 表三处）
#   SA-12 SKILL.md 卫星枚举 ,96 ≥2 处（frontmatter 卫星行+正文路由表 task-dispatch 行）∧ 其余 78 条 ≥2 处
#   SA-13 模板承载: task_plan.md（96.3 并行硬标注注释+96.5 并行宽度指标行）∧ subagent_dispatch.md（96.4 同一消息并发句）
#   SA-14 [负] 防改写/回删+旧纪元残留: 21.4「未声明者默认串行」≥1 ∧ 96.2 约束复述「超档拆细不升档」≥1 ∧ 59.4 原文「先拆细再派」≥1 ∧ SKILL.md「Rules 1-94」=0
#         （[S6 实现注] 设计稿 SA-14 把「超档拆细不升档」记为 59.4 在位锚; 实测 59.4 原文措辞=「先拆细再派，禁止派出去等失败再兜底」
#          （dispatch.md 59.4 段）, 四字串实际随 96.2「约束不变」句落地, 故补 59.4 真实原文锚「先拆细再派」——断言条数不变、守卫增强）
#   SA-15 [负] 防越界+登记闭环: dispatch.md 无 ^96.7 子条（六子条上限）∧ selftest-registry.tsv 已登记本脚本（selftest-registry.sh T02 双向配对兜底）
# 15 断言全 PASS exit 0; 任一 FAIL exit 1。只读, 不修改任何文件。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DISPATCH="$SKILL_ROOT/../task-dispatch/references/critical-rules-dispatch.md"
CRIT_C="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
TPL_PLAN="$SKILL_ROOT/templates/task_plan.md"
TPL_DISPATCH="$SKILL_ROOT/templates/subagent_dispatch.md"
REGISTRY="$SCRIPT_DIR/selftest-registry.tsv"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'SA-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'SA-%s FAIL %s\n' "$1" "$2"; }
cnt()  { grep -cF "$1" "$2" 2>/dev/null || true; }
cntE() { grep -cE "$1" "$2" 2>/dev/null || true; }

# SA-01 Rule 96 段标题
if grep -q '^### 96 子代理激活默认档与并行推进强化' "$DISPATCH"; then ok 01 "Rule 96 段标题在位"; else bad 01 "Rule 96 段标题缺失"; fi
# SA-02 96.1 激活默认档矩阵（双键）
if grep -q '96\.1' "$DISPATCH" && grep -qF '激活默认档矩阵' "$DISPATCH"; then ok 02 "96.1 激活默认档矩阵"; else bad 02 "96.1/激活默认档矩阵 缺失或半截落地"; fi
# SA-03 七类触发类别锚 ≥6（容忍 1 类措辞演进）
sa03=0
for kw in '制定计划' '调研分析' '多文件搜索' '大文件' '验证/审查' '批量既定步骤' '独立创作单元'; do
  grep -qF "$kw" "$DISPATCH" && sa03=$((sa03+1))
done
if [ "$sa03" -ge 6 ]; then ok 03 "七类触发类别锚命中 $sa03/7（≥6）"; else bad 03 "触发类别锚仅 $sa03/7（需 ≥6）"; fi
# SA-04 主进程例外窄白名单
if grep -qF '单行命令' "$DISPATCH" && grep -qF '单事实查询' "$DISPATCH" && grep -qF '一句话理由' "$DISPATCH"; then ok 04 "主进程窄白名单三锚（例外须登记一句话理由）"; else bad 04 "窄白名单锚缺失（单行命令/单事实查询/一句话理由）"; fi
# SA-05 96.2 模型分档
if grep -q '96\.2' "$DISPATCH" && grep -qF '模型分档' "$DISPATCH" && grep -qF 'sonnet-1' "$DISPATCH"; then ok 05 "96.2 模型分档（中档 sonnet-1 锚在位）"; else bad 05 "96.2/模型分档/sonnet-1 缺失"; fi
# SA-06 96.3 并行硬标注
if grep -q '96\.3' "$DISPATCH" && grep -qF '计划缺陷' "$DISPATCH"; then ok 06 "96.3 并行硬标注（未声明且未论证=计划缺陷）"; else bad 06 "96.3/计划缺陷 缺失"; fi
# SA-07 96.4 同消息并发
if grep -q '96\.4' "$DISPATCH" && grep -qF '同一消息' "$DISPATCH" && grep -qF '并发' "$DISPATCH"; then ok 07 "96.4 同一消息并发派发"; else bad 07 "96.4/同一消息/并发 缺失"; fi
# SA-08 96.5 指标留痕
if grep -q '96\.5' "$DISPATCH" && grep -qF '并行宽度' "$DISPATCH"; then ok 08 "96.5 指标留痕（最大并行宽度）"; else bad 08 "96.5/并行宽度 缺失"; fi
# SA-09 96.6 管辖边界
if grep -q '96\.6' "$DISPATCH" && grep -qF '执行强化层' "$DISPATCH"; then ok 09 "96.6 管辖边界（执行强化层）"; else bad 09 "96.6/执行强化层 缺失"; fi
# SA-10 核心卫星路由行枚举扩员
if grep -qF '52,59,68,96' "$CRIT_C"; then ok 10 "核心 critical-rules.md 卫星枚举扩员至 96"; else bad 10 "核心卫星枚举缺 96（task-dispatch 路由行）"; fi
# SA-11 SKILL.md 纪元字面 1-96 ≥3
sa11="$(cntE '1-96([^0-9]|$)' "$SKILLMD")"
if [ "${sa11:-0}" -ge 3 ]; then ok 11 "SKILL.md 纪元字面 1-96=${sa11:-0} 处（≥3）"; else bad 11 "SKILL.md 纪元字面 1-96 仅 ${sa11:-0} 处（需 ≥3: frontmatter/正文/References）"; fi
# SA-12 卫星枚举 ,96 + 其余 78 条（各 ≥2）
sa12a="$(cnt '52,59,68,96' "$SKILLMD")"; sa12b="$(cnt '其余 78 条' "$SKILLMD")"
if [ "${sa12a:-0}" -ge 2 ] && [ "${sa12b:-0}" -ge 2 ]; then ok 12 "SKILL.md 卫星枚举 ,96=${sa12a:-0} ∧ 其余 78 条=${sa12b:-0}（各 ≥2）"; else bad 12 "SKILL.md 级联随动缺失（,96=${sa12a:-0}/78 条=${sa12b:-0}, 各需 ≥2）"; fi
# SA-13 两模板承载锚
if grep -q '96\.3' "$TPL_PLAN" && grep -qF '并行组' "$TPL_PLAN" && grep -qF '并行宽度' "$TPL_PLAN" \
   && grep -q '96\.4' "$TPL_DISPATCH" && grep -qF '同一消息' "$TPL_DISPATCH"; then
  ok 13 "模板承载（task_plan 96.3/并行组/并行宽度 + subagent_dispatch 96.4/同一消息）"
else
  bad 13 "模板锚缺失（task_plan 或 subagent_dispatch）"
fi
# SA-14 [负] 防改写/回删 + 旧纪元残留
sa14a="$(cnt '未声明者默认串行' "$DISPATCH")"; sa14b="$(cnt '超档拆细不升档' "$DISPATCH")"
sa14c="$(cnt '先拆细再派' "$DISPATCH")"; sa14d="$(cnt 'Rules 1-94' "$SKILLMD")"
if [ "${sa14a:-0}" -ge 1 ] && [ "${sa14b:-0}" -ge 1 ] && [ "${sa14c:-0}" -ge 1 ] && [ "${sa14d:-0}" -eq 0 ]; then
  ok 14 "21.4/59.4 原文在位 ∧ 96.2 约束复述在位 ∧ 旧纪元 Rules 1-94 残留=0"
else
  bad 14 "防回删锚缺失或旧纪元残留（串行=${sa14a:-0}/超档复述=${sa14b:-0}/先拆细再派=${sa14c:-0}/Rules 1-94=${sa14d:-0} 应 0）"
fi
# SA-15 [负] 子条越界 + registry 登记
sa15a="$(cntE '^96\.7' "$DISPATCH")"; sa15b="$(cnt 'selftest-subagent-activation.sh' "$REGISTRY")"
if [ "${sa15a:-0}" -eq 0 ] && [ "${sa15b:-0}" -ge 1 ]; then ok 15 "无 96.7 越界子条 ∧ registry 已登记本脚本"; else bad 15 "越界或漏登记（96.7=${sa15a:-0} 应 0 / registry 行=${sa15b:-0} 应 ≥1）"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
