#!/usr/bin/env bash
# [2026-09-29 task-v095 P7-S1] selftest-skill-split.sh — 技能拆分终态守护套件
# 守护 task-v095 4+3 拆分方案的安装面四件套行为不变判据:
#   ① 4 卫星技能目录结构 + SKILL.md 薄正文 + frontmatter name 一致
#   ② 主 SKILL.md 行数收敛(≤433 目标,task-v097 Rule 40 联动 430→433 / ≤558 行数钉上限) + 4 路由指针在位
#   ③ 迁移内容抽检(5 个迁移源文件在卫星 references/ 内闭环 + 特征锚在位)
#   ④ 主 SKILL.md 死路径零残留(旧 references/ 相对路径过滤 plan- 前缀后零命中)
#   ⑤ 锚点抽验(Rule 17 成本控制 / C19 / C25 / C26 / Rules 1-3 计数锚)
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
t "T-主 行数 ≤490（task-v125 S3 净 +7（六族路由行插表尾 + Rule 52 摘要 bullet + 模板行尾联动；454→461）; task-v130 并行创作组节 +14（461→475）; task-v131 并行创作组回填 475 + Rule 53 六锚 477（475→477）; task-v133 C37 合规行 +1（477→478）; task-v138 Rule 55 索引演进 +1（478→479，钉随纪元上调 478→490）;演进 440→442→444→447→449→452→454→461→475→477→478→479，先例 v112/v122/v126/v127/v125/v131/v133/v138）且 ≤558 上限" bash -c "[ \"\$(wc -l < '$SKILL')\" -le 490 ] && [ \"\$(wc -l < '$SKILL')\" -le 558 ]" # task-v138 (2026-10-05): SKILL.md Rule 55 索引演进 478→479，钉随纪元上调（先例 v074 ≤523→≤540）
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
t "T-锚 Rules 1-3 计数锚 ≥1" bash -c "[ \"\$(grep -c 'Rules 1-3' '$SKILL')\" -ge 1 ]"

# T6 守卫 + registry 联动
for sat in plan-research-router plan-template-kit plan-cost-guard plan-collab-router; do
    t "T-守 check-skill-modify.sh 含 $sat" grep -q "$sat" "$CHECK"
done
t "T-reg registry.tsv 含 selftest-skill-split 行" bash -c "awk -F'\t' 'NR>1{print \$1}' '$TSV' | grep -q 'selftest-skill-split.sh'"

# ── 汇总 ──
TOTAL=$((PASS + FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
