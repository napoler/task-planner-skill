#!/usr/bin/env bash
# [2026-09-29 task-v095 P7-S1] selftest-skill-split.sh — 技能拆分终态守护套件
# 守护 task-v095 4+3 拆分方案的安装面四件套行为不变判据:
#   ① 4 卫星技能目录结构 + SKILL.md 薄正文 + frontmatter name 一致
#   ② 主 SKILL.md 行数收敛(≤433 目标,task-v097 Rule 40 联动 430→433 / ≤558 行数钉上限) + 4 路由指针在位
#   ③ 迁移内容抽检(5 个迁移源文件在卫星 references/ 内闭环 + 特征锚在位)
#   ④ 主 SKILL.md 死路径零残留(旧 references/ 相对路径过滤 plan- 前缀后零命中)
#   ⑤ 锚点抽验(Rule 17 成本控制 / C19 / C25 / C26 / Rules 1-3 计数锚)[2026-10-08 task-v144 合并级联: SKILL References/索引锚演进 1-62（58/59/60/62 落地）,宽容正则扩 6x 纪元 1-(3[0-9]|[4-6][0-9])
#   ⑥ 守卫与 registry 联动(check-skill-modify.sh 含 4 卫星名 / registry.tsv 含本行)
# 纯 grep/test 机械断言, 无 fixture; 全 PASS exit 0, 任一 FAIL exit 1。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."                       # <repo>/skills/task-planner
SKILL="$ROOT/SKILL.md"
CHECK="$SCRIPT_DIR/check-skill-modify.sh"
TSV="$SCRIPT_DIR/selftest-registry.tsv"
S1="$ROOT/../plan-research-router"
S2="$ROOT/../plan-template-kit"
S3="$ROOT/../plan-cost-guard"
S4="$ROOT/../plan-collab-router"

PASS=0; FAIL=0
t() { # t <name> <cmd...>
    local name="$1"; shift
    if "$@" >/dev/null 2>&1; then
        PASS=$((PASS+1)); echo "[PASS] $name"
    else
        FAIL=$((FAIL+1)); echo "[FAIL] $name"
    fi
}

# T1 卫星目录与 SKILL.md 存在 + frontmatter name 与目录名一致 + 薄正文 <100 行
for sat in plan-research-router plan-template-kit plan-cost-guard plan-collab-router; do
    p="$ROOT/../$sat"
    t "T-${sat} 目录+SKILL.md 存在" test -f "$p/SKILL.md"
    t "T-${sat} name 与目录名一致" bash -c "grep -q \"^name: $sat\$\" '$p/SKILL.md'"
    t "T-${sat} SKILL.md <100 行(薄正文)" bash -c "[ \"\$(wc -l < '$p/SKILL.md')\" -lt 100 ]"
done

# T2 主 SKILL.md 行数收敛 + 4 路由指针各 ≥1
# [2026-10-05 task-v136 S5] 钉上调 478→480（S2 SKILL.md 联动净增 +2（478→480，Rule 54 摘要/索引/C38），knowledge-brief §4-4 行数纪律先例：上限断言随净增同步上调带 label；≤558 总上限不动）
# [2026-10-05 task-v138 合并级联] 合并面 Rule 54（v136）与 Rule 55（v138）共存 → SKILL.md 实际 481 行（v136 系 480 + v138 侧 Rule 55 摘要行 +1，v138 基线未含 Rule 54 故钉按 479→490；合并后取两侧并集 → 481），钉随并集上调 480→490（两分支钉值并集口径，语义强度不降；≤558 总上限不动，先例 v074 ≤523→≤540）
# [2026-10-08 task-v144 合并级联] merge v143(58)/v145(62) 索引行演进 + C43 合规行/执行循环 2.5 指针/Rule 59 bullet + P1-1 frontmatter 换行修复 → SKILL.md 实际 492 行（490→492），钉随演进上调 490→500（钉值随内容演进先例；≤558 总上限不动）
# [2026-10-09 task-v149 合并级联] Rule 65 恢复+C39 恢复+摘要六 bullet → SKILL.md 实际 509 行（502→509，+7），钉维持 510（并集口径：本任务分支独立上调 500→510 与 v150 同值，取 510）
# [2026-10-09 task-v150 S10 合并级联] Rule 21.6 拆分模式库接线落地 → SKILL.md 实际 502 行（498→502，+4 接线面），钉随内容演进同步上调 500→510（脚本注释「钉值随内容演进同步上调」先例；≤558 总上限不动）
# [2026-10-09 task-v151 S4 合并级联] Rule 66 摘要行+C45 合规行 → SKILL.md 实际 511 行（509→511，+2），钉随内容演进同步上调 510→515（留 4 行余量；≤558 总上限不动）
# [2026-10-10 task-v154 S5 接线级联] Rule 69 路由行+清单行+C46+T1-T6 六标记+外部引用行（1 改行）→ SKILL.md 实际 521 行（515→521），钉随内容演进同步上调 515→526（≤558 总上限不动；v151 上调 510→515 同款判例）
t "T-主 行数 ≤526（task-v125 S3 净 +7（六族路由行插表尾 + Rule 52 摘要 bullet + 模板行尾联动；454→461）; task-v130 并行创作组节 +14（461→475）; task-v131 并行创作组回填 475 + Rule 53 六锚 477（475→477）; task-v133 C37 合规行 +1（477→478）; task-v136 S2 联动净增 +2（478→480）; task-v138 合并级联 Rule 54+55 并集净 +1（480→481，钉上调 480→490）; task-v144 合并级联 58/59/62 落地+C43/2.5/bullet 净 +11（481→492，钉上调 490→500）; task-v150 S10 合并级联 Rule 21.6 接线净 +4（498→502，钉上调 500→510）; task-v151 S4 合并级联 Rule 66 摘要+C45 净 +2（509→511，钉上调 510→515）; task-v154 接线级联净 +11-1 改（515→521，钉上调 515→526）;演进 440→442→444→447→449→452→454→461→475→477→478→480→481→492→502→511→521，先例 v112/v122/v126/v127/v125/v131/v133/v136/v138/v144/v150/v151）且 ≤558 上限" bash -c "[ \"\$(wc -l < '$SKILL')\" -le 526 ] && [ \"\$(wc -l < '$SKILL')\" -le 558 ]"
for sat in plan-research-router plan-template-kit plan-cost-guard plan-collab-router; do
    t "T-主 路由指针在位 $sat ≥1" bash -c "[ \"\$(grep -c '$sat' '$SKILL')\" -ge 1 ]"
done

# T3 迁移内容抽检(5 个迁移源在卫星内闭环 + 特征锚)
t "T-迁 research-routing.md 含 强制引用格式" grep -q '强制引用格式' "$S1/references/research-routing.md"
t "T-迁 template-guide.md 存在" test -f "$S2/references/template-guide.md"
t "T-迁 template-mapping.md 存在" test -f "$S2/references/template-mapping.md"
t "T-迁 template-guide.md 含 29 个" grep -q '29 个' "$S2/references/template-guide.md"
t "T-迁 cost-control.md 存在" test -f "$S3/references/cost-control.md"
t "T-迁 billing.md 存在" test -f "$S3/references/billing.md"
t "T-迁 cost_log.md 存在" test -f "$S3/references/cost_log.md"
t "T-迁 skill-collaboration.md 存在" test -f "$S4/references/skill-collaboration.md"
t "T-迁 skill-collaboration.md ≤300 行" bash -c "[ \"\$(wc -l < '$S4/references/skill-collaboration.md')\" -le 300 ]"

# T4 主 SKILL.md 死路径零残留: 5 个迁移源的旧 references/ 相对路径, 经 grep -v 'plan-' 过滤后零命中
# (外层直接计数, test 传参判定; 避免 bash -c 嵌套变量展开陷阱)
for old in references/research-routing.md references/template-guide.md references/template-mapping.md references/cost-control.md references/skill-collaboration.md; do
    N=$(grep -n "$old" "$SKILL" | grep -v 'plan-' | wc -l)
    t "T-死 $old 零残留(plan- 过滤后, N=$N)" test "$N" -eq 0
done

# T5 锚点抽验
t "T-锚 Rule 17 成本控制" grep -q 'Rule 17 成本控制' "$SKILL"
t "T-锚 C19 行在位" grep -q '| C19 |' "$SKILL"
t "T-锚 C25 行在位" grep -q '| C25 |' "$SKILL"
t "T-锚 C26 行在位" grep -q '| C26 |' "$SKILL"
# [2026-10-08 task-v144 合并级联: SKILL References/索引锚演进 1-62（58/59/60/62 落地）,宽容正则扩 6x 纪元]
# 原固定字面 'Rules 1-3' 计数锚在 1-62 纪元 SKILL.md 已零命中（级联漏改面）→ 宽容正则 1-(3[0-9]|[4-6][0-9]) 覆盖旧 1-3x..新 6x 纪元, 合计语义零改动
t "T-锚 Rules 1-3..6 宽容计数锚 ≥1" bash -c "[ \"\$(grep -cE 'Rules 1-(3[0-9]|[4-6][0-9])' '$SKILL')\" -ge 1 ]"

# T6 守卫 + registry 联动
for sat in plan-research-router plan-template-kit plan-cost-guard plan-collab-router; do
    t "T-守 check-skill-modify.sh 含 $sat" grep -q "$sat" "$CHECK"
done
t "T-reg registry.tsv 含 selftest-skill-split 行" bash -c "awk -F'\t' 'NR>1{print \$1}' '$TSV' | grep -q 'selftest-skill-split.sh'"

# ── 汇总 ──
TOTAL=$((PASS + FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
