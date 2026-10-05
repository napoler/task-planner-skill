#!/usr/bin/env bash
# selftest-requirement-coverage.sh — task-v129 S5: Rule 51 需求覆盖与完成声称门控静态守护
# 范式对齐 selftest-lane-advancement.sh（SCRIPT_DIR/SKILL_ROOT 定位、ok()/bad() 结构、Total 行、FAIL>0 exit 1 全同构），task-v129 S5 产出。
# 用途：静态断言 Rule 51 六子条（critical-rules.md）+ SKILL.md 摘要 bullet/C35 合规行 + delivery-summary.md 需求覆盖核对区块
#      全部落点在位且既有主锚未破坏（36.5 纯增量守护），并确认零新 config 键（properties=40，与 43.4/44.4/47.4 同口径）。
# 输入：task-planner/references/critical-rules.md、task-planner/SKILL.md、task-planner/templates/delivery-summary.md、task-planner/config.json
#      （只读，grep/jq，零写入）。
# 输出：RC-01..RC-15 逐行 PASS/FAIL + 末行 Total；全 PASS exit 0，任一 FAIL exit 1（jq 缺失时 RC-13 打 SKIPPED 不 FAIL，
#      与 selftest-lane-advancement.sh LA-14 / reliability-institution R-12 先例一致）。
# 依赖：bash + grep + awk；registry 自登记校验 RC-14；config.json 键数校验需 jq（缺失降级 SKIPPED，fail-open 非静默——打印提示行）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
TDEL="$SKILL_ROOT/templates/delivery-summary.md"
CONFIG="$SKILL_ROOT/config.json"
REG="$SKILL_ROOT/scripts/selftest-registry.tsv"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'RC-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'RC-%s FAIL %s\n' "$1" "$2"; }

# RC-01 Rule 51 六子条锚 `grep -c '^51\.'` ≥6
# What：断言 51.1-51.6 六条子条主体行（行首 '51.N'）在位。
# Why：锁 Rule 51 条款本体未被裁剪/重排——六子条是需求原文锚定/覆盖判据/核对表/自缩水禁令/前置盘点的唯一文本落点，
#      缺任一子条 = 需求覆盖门控条款失守（防后续任务改写 critical-rules.md 时误删 51.x 段）。
n="$(grep -cE '^[[:space:]]*51\.' "$CRIT" || true)"
if [ "$n" -ge 6 ]; then ok 01 "critical-rules.md Rule 51 子条锚 $n ≥6"; else bad 01 "critical-rules.md Rule 51 子条数 $n（应 ≥6）"; fi

# RC-02 Rule 51 标题锚 `grep -q '^### 51 '`
# What：断言 '### 51 ' 章节标题行在位。
# Why：标题行是 44/45/46/47/49 范式（章节标题+子条）的识别锚——丢了标题，Rule 51 会退化为无主条款（防章节误删/标题降级为普通段落）。
if grep -q '^### 51 ' "$CRIT"; then
  ok 02 "critical-rules.md Rule 51 标题锚在位"
else
  bad 02 "critical-rules.md Rule 51 标题锚缺失（### 51 未命中）"
fi

# RC-03 需求原文锚定语义锚 `grep -q '需求原文锚定'`
# What：断言「需求原文锚定」核心语义在 critical-rules.md 在位。
# Why：需求原文锚定是 Rule 51 的第一原则（完成声称必须回到用户原始指令逐条核对）——语义锚缺失 = 门控失去判据源（防 51.x 降格为无锚泛文）。
if grep -q '需求原文锚定' "$CRIT"; then
  ok 03 "critical-rules.md「需求原文锚定」语义锚在位"
else
  bad 03 "critical-rules.md「需求原文锚定」缺失（Rule 51 核心判据失守）"
fi

# RC-04 覆盖判据语义锚 `grep -q '覆盖判据'`
# What：断言「覆盖判据」判定语义在 critical-rules.md 在位。
# Why：覆盖判据是 51.x 的判定标准（每条需求必须有可观察证据才算覆盖）——缺失 = 门控失去量化判据（防判定标准被裁剪成纯声明）。
if grep -q '覆盖判据' "$CRIT"; then
  ok 04 "critical-rules.md「覆盖判据」语义锚在位"
else
  bad 04 "critical-rules.md「覆盖判据」缺失（51.x 判定标准失守）"
fi

# RC-05 需求覆盖核对表语义锚 `grep -q '需求覆盖核对表'`
# What：断言「需求覆盖核对表」登记面语义在 critical-rules.md 在位。
# Why：核对表是完成声称的强制登记产物（delivery-summary.md 是其模板载体）——条款内未声明核对表 = 登记行为失去权威源锚定（防 51.x 登记语义被裁剪）。
if grep -q '需求覆盖核对表' "$CRIT"; then
  ok 05 "critical-rules.md「需求覆盖核对表」语义锚在位"
else
  bad 05 "critical-rules.md「需求覆盖核对表」缺失（完成声称登记面失守）"
fi

# RC-06 自缩水禁令语义锚 `grep -q '自缩水禁令'`
# What：断言「自缩水禁令」边界条款在 critical-rules.md 在位。
# Why：自缩水禁令是 Rule 51 相对既有规则（§四 防漂移）的独有增量语义（执行中禁止把需求范围越缩越小）——缺失 = 门控失去负向约束（防 51.x 被裁剪成正向声明）。
if grep -q '自缩水禁令' "$CRIT"; then
  ok 06 "critical-rules.md「自缩水禁令」语义锚在位"
else
  bad 06 "critical-rules.md「自缩水禁令」缺失（51.x 负向约束失守）"
fi

# RC-07 前置盘点语义锚 `grep -q '前置盘点'`
# What：断言「前置盘点」条款语义在 critical-rules.md 在位。
# Why：前置盘点是 Rule 51 的执行前置动作（动手前盘点需求全集与既有落点）——缺失 = 门控只查终态不查起点（防 51.x 前置段被裁剪）。
if grep -q '前置盘点' "$CRIT"; then
  ok 07 "critical-rules.md「前置盘点」语义锚在位"
else
  bad 07 "critical-rules.md「前置盘点」缺失（51.x 前置动作失守）"
fi

# RC-08 零新 config 键承诺锚 `grep -q '零新 config 键'`
# What：断言「零新 config 键」机制承诺文本在 critical-rules.md 在位。
# Why：Rule 51 判定面纯 LLM 行为 + 静态守护（与 43.4/44.4/47.4 同范式）——承诺文本缺失 = 机制层约束无据可依（防后续任务给 51 加机器触发键）。
if grep -q '零新 config 键' "$CRIT"; then
  ok 08 "critical-rules.md「零新 config 键」承诺锚在位"
else
  bad 08 "critical-rules.md「零新 config 键」缺失（机制承诺失守）"
fi

# RC-09 SKILL.md 摘要 bullet 锚 `grep -q 'Rule 51（需求覆盖与完成声称门控'`
# What：断言 SKILL.md Critical Rules 摘要段含 Rule 51 bullet。
# Why：摘要是 SKILL.md 内 Rule 51 的入口索引（LLM 读 SKILL.md 时先见摘要后查 critical-rules.md）——丢 bullet = 摘要与条款脱钩
#      （防"条款扩到 51 但摘要停摆 49"的级联断链）。
if grep -q 'Rule 51（需求覆盖与完成声称门控' "$SKILLMD"; then
  ok 09 "SKILL.md Rule 51 摘要 bullet 在位"
else
  bad 09 "SKILL.md Rule 51 摘要 bullet 缺失（Critical Rules 列表未联动）"
fi

# RC-10 SKILL.md 合规清单行锚 `grep -q '^| C35 |'`
# What：断言合规清单 C35 行（行首 '| C35 |'）在位。
# Why：C35 是 Rule 51 的合规清单消费点（完成声称前必须过需求覆盖核对）——丢 C35 行 = 合规检查面与条款脱钩（防 C34 后行被误删/插入错位）。
if grep -q '^| C35 |' "$SKILLMD"; then
  ok 10 "SKILL.md 合规清单 C35 行在位"
else
  bad 10 "SKILL.md 合规清单 C35 行缺失（Rule 51 消费点未联动）"
fi

# RC-11 SKILL.md 主锚守护 `grep -c 'Rules 1-39'` =2 且 `grep -c '1-40'` =0
# What：断言 SKILL.md 内 `Rules 1-39` 字面命中数保持 2（SR-07 既有锚），且 `1-40` 变体命中数为 0。
# Why：主锚字面是 selftest-self-resolution.sh SR-07 的断言对象——task-v129 全部联动采用"追加/括注"而非"改写"范式，
#      主锚计数变动或 1-40 变体出现 = 有人动了主锚或误写变体（与 selftest-lane-advancement.sh LA-12/LA-13 同口径）。
n="$(grep -c 'Rules 1-39' "$SKILLMD" || true)"
if [ "$n" -eq 2 ] && [ "$(grep -c '1-40' "$SKILLMD" || true)" -eq 0 ]; then
  ok 11 "SKILL.md 主锚 'Rules 1-39' 命中 =2 且 '1-40' 变体 0（SR-07 不变）"
else
  bad 11 "SKILL.md 主锚 'Rules 1-39' 命中=$n（应 =2）或 '1-40' 变体非 0（SR-07 主锚被改动）"
fi

# RC-12 delivery-summary.md 需求覆盖区块锚 `grep -q '需求覆盖核对'` 且 `^## [1-5].` 区块数 =5
# What：断言 delivery-summary.md 含「需求覆盖核对」区块，且既有 5 个编号区块（^## N.）未被新增/删除。
# Why：delivery-summary.md 是 51.x 核对表模板载体——区块缺失 = 模板与条款脱钩；区块数 ≠5 说明模板被重构增删区块（防模板面漂移）。
n="$(grep -cE '^## [1-5]\.' "$TDEL" || true)"
if grep -q '^## 需求覆盖核对（Rule 51.3' "$TDEL" && [ "$n" -eq 5 ]; then
  ok 12 "delivery-summary.md「需求覆盖核对」区块在位且编号区块数 =5"
else
  bad 12 "delivery-summary.md「需求覆盖核对」缺失或编号区块数=$n（应 =5）"
fi

# RC-13 零新 config 键——properties 键数 = 40（同 43.4/44.4/47.4 口径；jq 缺失打 SKIPPED 不 FAIL）
# What：断言 config.json .properties 顶层键数保持 40（Rule 51 判定面纯 LLM 行为 + 静态守护，零机器触发面，故不得新增 config 键）。
# Why：51.x 承诺"零新 config 键"——键数膨胀 = 有人给需求覆盖门控加了机器门控键，突破既定零新键范式，属机制漂移（需走 36 条款流程）。
#      jq 缺失 fail-open 打 SKIPPED（沿用 LA-14/R-12 先例：无 jq 属环境降级非内容漂移，不误报 FAIL；打印提示行非静默）。
if command -v jq >/dev/null 2>&1; then
  keys="$(jq '.properties | length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "40" ]; then ok 13 "config.json properties 键数 40（零新增）"; else bad 13 "config.json properties 键数=$keys（应 40，Rule 51 零新键被破坏）"; fi
else
  printf 'RC-13 SKIPPED jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）\n'
fi

# RC-14 registry 自登记锚：selftest-registry.tsv 第 1 字段含本脚本名
# What：断言 selftest-registry.tsv 数据行（NR>1）第 1 列含 'selftest-requirement-coverage.sh'。
# Why：本脚本自身必须在 registry 登记（selftest-registry.sh 会校验"未登记脚本"与"孤儿登记"双向一致）——
#      自引用断言 = 防止 registry 行被误删而 selftest-registry.sh 尚未覆盖本脚本期间的盲区（防登记面漏项）。
if awk -F'\t' 'NR>1{print $1}' "$REG" | grep -q 'selftest-requirement-coverage.sh'; then
  ok 14 "registry.tsv 已登记 selftest-requirement-coverage.sh"
else
  bad 14 "registry.tsv 未登记 selftest-requirement-coverage.sh（registry 漏项）"
fi

# RC-15 负断言 `grep -c '^54\.'` =0
# What：断言 critical-rules.md 内行首 '54.' 子条命中数为 0（54 号未被误占）。
# Why：53 号已由 task-v131 合法占用（53.1-53.5 已落地）——若 '54.' 出现说明他任务并行插入了 Rule 54，
#      本任务的编号假设被破坏，需重新对齐条款号（防编号冲突/并行任务踩踏）。
# [task-v125 S5 演进重锚] '^52.'→'^53.'（Rule 52 被 task-v125 S2 合法落地 52.1-52.4，负断言改锁后继号 53，语义不反转，先例同 v127 ^50→^52，2026-10-04）
# [task-v131 演进重锚] '^53.'→'^54.'：Rule 53 已落地（53.1-53.5），防线前移至 54（先例 v125 S5），2026-10-05
n="$(grep -c '^54\.' "$CRIT" || true)"
if [ "$n" -eq 0 ]; then ok 15 "critical-rules.md '54.' 子条命中 0（54 号未被误占，task-v131 演进重锚）"; else bad 15 "critical-rules.md '54.' 子条命中=$n（应 =0，编号假设被破坏）"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
