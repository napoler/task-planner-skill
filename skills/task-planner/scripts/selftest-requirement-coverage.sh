#!/usr/bin/env bash
# selftest-requirement-coverage.sh — task-v129 S5: Rule 51 需求覆盖与完成声称门控静态守护
# 范式对齐 selftest-lane-advancement.sh（SCRIPT_DIR/SKILL_ROOT 定位、ok()/bad() 结构、Total 行、FAIL>0 exit 1 全同构），task-v129 S5 产出。
# 用途：静态断言 Rule 51 八子条（51.1-51.8，critical-rules.md）+ SKILL.md 摘要 bullet/C35 合规行 + delivery-summary.md 需求覆盖核对区块 [2026-10-05 task-v133] 51.8 新增, 七→八子条（51.1-51.8；51.8 未测试就声称完成禁令，级联 43.5/43.6+53.5-Q9+SKILL C37）
#      全部落点在位且既有主锚未破坏（36.5 纯增量守护），并确认零新 config 键（properties=40，与 43.4/44.4/47.4 同口径）。
# 输入：task-planner/references/critical-rules.md、task-planner/SKILL.md、task-planner/templates/delivery-summary.md、task-planner/config.json
#      （只读，grep/jq，零写入）。
# 输出：RC-01..RC-23 逐行 PASS/FAIL + 末行 Total；全 PASS exit 0，任一 FAIL exit 1（jq 缺失时 RC-13 打 SKIPPED 不 FAIL，
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

# RC-01 Rule 51 八子条（51.1-51.8）锚 `grep -c '^51\.'` ≥7
# What：断言 51.1-51.8 八条子条主体行（行首 '51.N'）在位。
# Why：锁 Rule 51 条款本体未被裁剪/重排——八子条（51.1-51.8，task-v132 增补 51.7 纠正=回锚重译；task-v133 增补 51.8 未测试就声称完成禁令）
#      是需求原文锚定/覆盖判据/核对表/自缩水禁令/前置盘点的唯一文本落点，
#      缺任一子条 = 需求覆盖门控条款失守（防后续任务改写 critical-rules.md 时误删 51.x 段）。
# [2026-10-05 task-v132/Phase4 P2] 口径 6→7: 51.7 增量后「六子条」枚举过期（P2-ALIGN-3），
#      断言阈值同步升 -ge 7 锁死新口径（实测 critical-rules.md 行首 51. 锚计数=8: 51.1/51.1a/51.2-51.7）。
n="$(grep -cE '^[[:space:]]*51\.' "$CRIT" || true)"
if [ "$n" -ge 7 ]; then ok 01 "critical-rules.md Rule 51 子条锚 $n ≥7"; else bad 01 "critical-rules.md Rule 51 子条数 $n（应 ≥7）"; fi

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

# RC-16..20 共用的被测对象定位（task-v132 G1/G2 产出脚本，均为 worktree 内本目录文件）
CC_SCRIPT="$SCRIPT_DIR/check-complete.sh"      # RC-18/19/20：worktree 版 check-complete.sh（R-COVERAGE 门载体）
LINT="$SCRIPT_DIR/check-window-consistency.sh" # RC-17：窗口口径 lint（G2 机制化产物）

# RC-16 51.7 文本锚（task-v132 R2 锚：纠正=回锚重译 + 72h 事故判例 + 报告路径）
# What：断言三锚各恰好命中 1 次——① '51.7 **纠正=回锚重译'（51.7 子条标题行，=1 防重复插入/误删）；
#      ② '一个月→72小时两次改写'（72h 事故判例锚，防判例被裁剪——判例是 51.7 的行为证据）；
#      ③ '2026-10-05-72h-instruction-mutation.md'（事故报告路径锚，防取证链断链——判例须可溯回事故报告）。
# Why：R 锚「51.7 文本锚」= 51.7 条款本体的最小文本守护（=1 口径同 RC-02 标题锚精确单点；
#      判例/报告路径成对守护防"条款在但证据没了"的脱锚）。
_rc16_a="$(grep -c '51\.7 \*\*纠正=回锚重译' "$CRIT" || true)"
_rc16_b="$(grep -c '一个月→72小时两次改写' "$CRIT" || true)"
_rc16_c="$(grep -c '2026-10-05-72h-instruction-mutation\.md' "$CRIT" || true)"
if [ "$_rc16_a" -eq 1 ] && [ "$_rc16_b" -eq 1 ] && [ "$_rc16_c" -eq 1 ]; then
  ok 16 "critical-rules.md 51.7「纠正=回锚重译」=1 且判例锚「一个月→72小时两次改写」=1 且事故报告路径 =1"
else
  bad 16 "critical-rules.md 51.7 三锚计数异常: 标题=$_rc16_a 判例=$_rc16_b 报告路径=$_rc16_c（应各 =1）"
fi

# RC-17 窗口口径 lint 正/负例（task-v132 R2 锚：check-window-consistency.sh 行为守护）
# What：三断——① 脚本在位且可执行（-f + -x，G2 机制载体不得被删/去执行位）；
#      ② 正例：mktemp 夹具（锚 R 行=「一个月」月族；载荷含「30天」=同族异值）→ exit 0（同族转写差不警报）；
#      ③ 负例：同锚夹具，载荷换成「7 天」（周族跨族词）且行内无豁免语境词（判例/事故/incident-reports）
#      → exit 1（⚠ 跨族冲突警报）。夹具全部脚本内自建（mktemp 子目录），跑毕删除，零外部依赖。
# Why：R 锚「lint 正/负例」= lint 判定语义的行为级守护（防词表/判定被改写后正负例漂移）；
#      正例锁「同族异值不 exit 1」（warn 级起步口径=FMEA F2 兜底），负例锁「跨族+无豁免必警报」
#      （72h 事故主形态：锚=一个月、载荷被改写 7 天 → 必须拦）。
LINT_POS="$(mktemp -d "${TMPDIR:-/tmp}/wlint-selftest.XXXXXX")"
LINT_NEG="$(mktemp -d "${TMPDIR:-/tmp}/wlint-selftest.XXXXXX")"
for _d in "$LINT_POS" "$LINT_NEG"; do
  mkdir -p "$_d/subagent-state"
  printf '%s\n' \
    '# 窗口 lint 夹具 task_plan' \
    '' \
    '## 🎯 用户需求原文（Rule 51.1 锚定）' \
    '' \
    '- **R1**: 「交付周期以一个月为窗口口径（锚=月族）。」' \
    '' \
    '## Phases' \
    '' \
    '### Phase 1: 执行' \
    '- **Status:** complete' \
    > "$_d/task_plan.md"
done
# 正例载荷：锚族内异值「30天」（同族纠正候选=advisory，不 exit 1）；载荷面=subagent-state/*.md
# （lint 载荷扫描区，check-window-consistency.sh 只扫该目录+计划全文，载荷须落此才计数）
printf '%s\n' \
  '# 载荷（正例）：计量窗口=30天（月族异值，非跨族）' \
  '- [x] 跑批完成，窗口口径按 30天 归并登记。' \
  > "$LINT_POS/subagent-state/01-executor.md"
# 负例载荷：跨族词「7 天」无豁免语境（72h 事故改写形态的窗口词版）
printf '%s\n' \
  '# 载荷（负例）：计量窗口被改写' \
  '- [x] 跑批完成，窗口口径按 7 天 归并登记。' \
  > "$LINT_NEG/subagent-state/01-executor.md"
_lint_pos_rc=0; _lint_pos_out="$(bash "$LINT" "$LINT_POS" 2>&1)" || _lint_pos_rc=$?
_lint_neg_rc=0; _lint_neg_out="$(bash "$LINT" "$LINT_NEG" 2>&1)" || _lint_neg_rc=$?
rm -rf "$LINT_POS" "$LINT_NEG"
if [ -f "$LINT" ] && [ -x "$LINT" ] && [ "$_lint_pos_rc" -eq 0 ] && [ "$_lint_neg_rc" -eq 1 ] \
   && ! printf '%s\n' "$_lint_pos_out" | grep -q '⚠' \
   && printf '%s\n' "$_lint_neg_out" | grep -q '⚠'; then
  ok 17 "check-window-consistency.sh 在位可执行; 正例(锚=一个月 载荷=30天 同族) exit=0 无⚠; 负例(载荷=7天 无豁免) exit=1 有⚠"
else
  bad 17 "窗口 lint 守护异常: 在位=$([ -f "$LINT" ] && [ -x "$LINT" ] && echo yes || echo no) 正例exit=$_lint_pos_rc(应0) 负例exit=$_lint_neg_rc(应1)"
fi

# RC-18 R-COVERAGE 门锚（task-v132 G1：check-complete.sh 内 rcov-gate 段在位）
# What：断言 check-complete.sh 含 'R-COVERAGE' 字面 ≥1（门段注释/文案锚）且含 'rcov-gate' 字面 ≥1
#      （门输出统一前缀锚=门行为存在的可 grep 证据）。
# Why：R 锚「R-COVERAGE 门锚」= 终验门控落点的静态守护（防后续任务重构 check-complete.sh 时
#      误删 R-COVERAGE 段——门没了=缺行/裸 uncovered 负例重新全链绿灯，72h 事故形态回归）；
#      双字面（语义名+输出前缀）对齐 03-executor 实测「锚字面量 rcov-gate 计数=5 行」口径的最低断言面。
_rc18_a="$(grep -c 'R-COVERAGE' "$CC_SCRIPT" || true)"
_rc18_b="$(grep -c 'rcov-gate' "$CC_SCRIPT" || true)"
if [ "$_rc18_a" -ge 1 ] && [ "$_rc18_b" -ge 1 ]; then
  ok 18 "check-complete.sh R-COVERAGE 门锚在位（R-COVERAGE=$_rc18_a rcov-gate=$_rc18_b，均 ≥1）"
else
  bad 18 "check-complete.sh R-COVERAGE 门锚缺失: R-COVERAGE=$_rc18_a rcov-gate=$_rc18_b（门段被删？）"
fi

# RC-19 R-COVERAGE 负例（task-v132 G1 机器守护）：夹具计划 R1 行+summary 缺行 → enforce 档 exit≠0
# What：mktemp 自建最小夹具（脚本内零外部依赖）——task_plan.md 含 🎯 区块 R1..R2 行+R→VC 映射表（VC 行 ≥5）
#      +1 Phase（Status complete+V-N 映射 2 条）+Decisions Made，delivery-summary.md 核对表缺 R2 行
#      （=R 锚「缺行」形态）；对 worktree 版 check-complete.sh 跑 TASK_PLANNER_VC_GATE_ENFORCE=enforce，
#      断言 exit≠0 且 stderr 含 [rcov-gate] 拒 COMPLETE 行。
# Why：R-COVERAGE 门（check-complete.sh :783-915）落地后的负例守护——缺行/裸 uncovered 无让步在 enforce 档
#      必须阻断 COMPLETE（72h 事故修复=完成声称机器化的直接收益）；夹具自建=防对 /tmp 既有实测夹具的隐式依赖。
#      构造法参考 plans/task-v132/subagent-state/03-executor.md 实测节 plan-b，最小化到单 R 缺行。
#      门控执行序实测（探针 /tmp/probe19）：VC-GATE 在 R-COVERAGE 前且 enforce 档违规即 exit 1（rcov-gate 永不
#      到达）——故夹具须让 VC-GATE PASS（VC 表 ≥5 行+每 Phase ≥2 条 V-N 映射），其余门逐门放行：
#      3-File Gate findings/progress 各 3 实质行（worktree 模板行剔除口径）；委派门 main_direct 白名单②豁免；
#      FMEA 门无「FMEA 预演」段→打行放行；Rescue 门无 failed/timeout 行→放行；SKILL-MODIFY 计划不含
#      'skills/task-planner/' 字样→SKIPPED；RefLECT 未声明 reflect_verify→SKIPPED；Learning Gate progress
#      无 Error Log 列→静默。故本次 exit 只能由 [rcov-gate] 贡献（与 03-executor 实测 plan-b 逐门同构）。
# RC-19 夹具（mktemp 自建，跑毕即删，零外部依赖）
RCOV_FIX="$(mktemp -d "${TMPDIR:-/tmp}/rcov-selftest.XXXXXX")"
{
  printf '%s\n' \
    '# Task Plan: RC-19 selftest fixture（R-COVERAGE 负例：summary 缺 R2 行）' \
    '' \
    '## 🎯 用户需求原文（Rule 51.1 锚定）' \
    '' \
    '- **R1**: 「需求一：修复自测守护（covered，证据见 delivery-summary 核对表）。」' \
    '- **R2**: 「需求二：本用例中被核对表缺行（缺行负例=不得 COMPLETE）。」' \
    '' \
    '## VC 表' \
    '| VC | 验证判据 |' \
    '|----|----------|' \
    '| VC-1 | 核对表缺行负例被 rcov-gate 拦截 |' \
    '| VC-2 | PARTIAL 放行语义实测 |' \
    '| VC-3 | 证据区口径（非空且非 无/—/N/A） |' \
    '| VC-4 | Decisions 让步登记判定 |' \
    '| VC-5 | 3-File Gate 非 stub 判定 |' \
    '' \
    '## Phases' \
    '' \
    '### Phase 1: 夹具执行' \
    '- **Status:** complete' \
    '- **Executor:** 主进程（白名单②计划系统文件）' \
    '- [x] V-1.1: VC-1（证据=rcov-gate 输出）' \
    '- [x] V-1.2: VC-2（证据=rcov-gate 输出）' \
    '' \
    '## Decisions Made' \
    '| 时间 | 决策 | 依据 |' \
    '|------|------|------|' \
    '| selftest | 无额外决策 | 本夹具 |' 
} > "$RCOV_FIX/task_plan.md"
{
  printf '%s\n' \
    '# delivery-summary（RC-19 负例：核对表缺 R2 行）' \
    '' \
    '## 需求覆盖核对（Rule 51.3）' \
    '| R | 覆盖 | 证据 |' \
    '|---|------|------|' \
    '| R1 | covered | selftest-requirement-coverage.sh RC-19 夹具（证据区=非空且非 无/—/N/A，口径见 03-executor issues 1） |' 
} > "$RCOV_FIX/delivery-summary.md"
{
  printf '%s\n' \
    '# findings（RC-19 fixture）' \
    '' \
    '- 夹具 R1 covered 证据=核对表 R1 行证据路径非空（证据区口径=非空且非无/—/N/A）' \
    '- 夹具 R2 缺行=本负例设计目标（enforce 档 rcov-gate 须 exit≠0）' \
    '- 跑批留痕：bash check-complete.sh 输出归档于本 selftest 夹具目录' 
} > "$RCOV_FIX/findings.md"
{
  printf '%s\n' \
    '# progress（RC-19 fixture）' \
    '' \
    '### Phase 1: 夹具执行' \
    '- [x] 完成：核对表缺行负例构造与终验跑批（证据=rcov.err 含 [rcov-gate] FAILED 行）' 
} > "$RCOV_FIX/progress.md"
# 跑 enforce 档终验（env 覆盖档位，零新 config 键承诺不变；R 锚「缺行→不得 COMPLETE」）。
# env VAR=x bash 写法：env 前置于命令=单命令原子传参，重定向顺序无歧义（stderr 落夹具内 rcov.err 留证）。
env TASK_PLANNER_VC_GATE_ENFORCE=enforce bash "$CC_SCRIPT" "$RCOV_FIX/task_plan.md" \
  < /dev/null > "$RCOV_FIX/rcov.out" 2> "$RCOV_FIX/rcov.err"
RCOV_RC=$?
_rcov_err="$RCOV_FIX/rcov.err"
if [ "$RCOV_RC" -ne 0 ] && grep -q 'rcov-gate' "$_rcov_err" && grep -q '拒 COMPLETE 只可 PARTIAL' "$_rcov_err"; then
  ok 19 "R-COVERAGE 负例（summary 缺行）enforce 档 exit=$RCOV_RC≠0 且 stderr 含 rcov-gate 拒 COMPLETE 文案"
else
  bad 19 "R-COVERAGE 缺行负例未拦截: exit=$RCOV_RC stderr 缺 rcov-gate 拒 COMPLETE（03-executor 实测 plan-b 应 FAILED exit=1）"
fi
rm -rf "$RCOV_FIX"

# RC-20 R-COVERAGE 负例/正例双断（裸 uncovered 无让步 vs uncovered+让步行）
# What：两个 mktemp 夹具（同 RC-19 最小化构造法，脚本内自建）：
#   (a) 负例：summary R1 状态=uncovered 且证据区=「无」（非否定值白名单口径下仍不计证据），
#       计划 Decisions Made 无 R1 让步登记 → enforce 档 exit≠0 且拒 COMPLETE 文案含「只可 PARTIAL」；
#   (b) 正例：summary R1=uncovered+Decisions Made 含 R1 让步行 → enforce 档 exit=0（放行语义=不阻断，
#       只打 PARTIAL 语义提示行「完成状态只可 PARTIAL」）。
# Why：R 锚「裸 uncovered 无让步→不得 COMPLETE」的机器对偶——(a) 锁违规必阻断；(b) 锁显式已登记让步
#      不阻断（PARTIAL 语义放行=不惩罚已合规声明的缩水，防门控误伤登记面）。证据区判定口径=非空且非
#      「无/—/N/A」（03-executor issues 1 放宽口径），(a) 用「无」占位=口径内仍判证据缺失。
#      夹具同 RC-19 须让 VC-GATE PASS（VC 表 ≥5 行+每 Phase ≥2 条 V-N 映射）——否则门控序上 VC-GATE
#      enforce 先 exit 1，rcov-gate 永不到达（执行序实测探针见 RC-19 注释）。
#      [踩坑 2026-10-05] 让步判定函数在「Decisions Made」区块内 grep 同含 R 编号+让步关键词的行——
#      负例 (a) 的 Decisions 行文案若出现 R1 字面或 让步/uncovered/partial 关键词且同行双命中即被误判
#      为已登记让步（exit 0 误放行），故负例行文案刻意全避开；正例 (b) 行则须同时含 R1+让步关键词
#      （=已登记语义，放行前提）。
_RC20_FIX="$(mktemp -d "${TMPDIR:-/tmp}/rcov20-selftest.XXXXXX")"
_RC20_POS="$(mktemp -d "${TMPDIR:-/tmp}/rcov20-selftest.XXXXXX")"
# 两夹具共用：VC 表 5 行 + Phase 段（V-N 映射 2 条，VC-GATE PASS 前提）
_RC20_VC_BLOCK='## VC 表
| VC | 验证判据 |
|----|----------|
| VC-1 | rcov-gate 拦截语义实测 |
| VC-2 | PARTIAL 放行语义实测 |
| VC-3 | 证据区口径（非空且非 无/—/N/A） |
| VC-4 | Decisions 让步登记判定 |
| VC-5 | 3-File Gate 非 stub 判定 |
'
_RC20_PHASE_BLOCK='## Phases

### Phase 1: 夹具执行
- **Status:** complete
- **Executor:** 主进程（白名单②计划系统文件）
- [x] V-1.1: VC-1（证据=rcov-gate 输出）
- [x] V-1.2: VC-2（证据=rcov-gate 输出）
'
# (a) 负例夹具：R1 裸 uncovered 无让步
printf '%s\n' \
  '# Task Plan: RC-20 fixture (a) 裸 uncovered 无让步' \
  '' \
  '## 🎯 用户需求原文（Rule 51.1 锚定）' \
  '' \
  '- **R1**: 「需求一：本用例中未覆盖且无让步登记（裸 uncovered=拒 COMPLETE）。」' \
  '' \
  "$_RC20_VC_BLOCK" \
  '' \
  "$_RC20_PHASE_BLOCK" \
  '## Decisions Made' \
  '| 时间 | 决策 | 依据 |' \
  '|------|------|------|' \
  '| selftest | 本负例夹具无额外决策（本区块不设需求相关登记行=负例前提；本行文案刻意不嵌入需求编号字面与三个登记关键词——同行双命中会被让步判定函数误读为已登记而误放行，见上方踩坑注） | 本夹具 |' \
  > "$_RC20_FIX/task_plan.md"
{
  printf '%s\n' \
    '# delivery-summary（RC-20 负例：R1 裸 uncovered 无让步）' \
    '' \
    '## 需求覆盖核对（Rule 51.3）' \
    '| R | 覆盖 | 证据 |' \
    '|---|------|------|' \
    '| R1 | uncovered | 无 |' 
} > "$_RC20_FIX/delivery-summary.md"
# (b) 正例夹具：R1 uncovered+Decisions 让步行
printf '%s\n' \
  '# Task Plan: RC-20 fixture (b) uncovered+Decisions 让步行' \
  '' \
  '## 🎯 用户需求原文（Rule 51.1 锚定）' \
  '' \
  '- **R1**: 「需求一：本用例中未覆盖但已在 Decisions 登记显式让步（PARTIAL 放行）。」' \
  '' \
  "$_RC20_VC_BLOCK" \
  '' \
  "$_RC20_PHASE_BLOCK" \
  '## Decisions Made' \
  '| 时间 | 决策 | 依据 |' \
  '|------|------|------|' \
  '| selftest | R1 显式让步（uncovered 登记） | 用户确认降范围，本用例放行前提 |' \
  > "$_RC20_POS/task_plan.md"
{
  printf '%s\n' \
    '# delivery-summary（RC-20 正例：R1 uncovered+让步已登记）' \
    '' \
    '## 需求覆盖核对（Rule 51.3）' \
    '| R | 覆盖 | 证据 |' \
    '|---|------|------|' \
    '| R1 | uncovered | 无 |' 
} > "$_RC20_POS/delivery-summary.md"
# 3-File Gate 最小非 stub findings/progress 两夹具共用（3 实质行，经 worktree 模板行剔除口径）
for _d in "$_RC20_FIX" "$_RC20_POS"; do
  {
    printf '%s\n' \
      '# findings（RC-20 fixture）' \
      '' \
      '- 夹具 R1 uncovered 证据区=「无」（否定值白名单口径下不计证据）' \
      '- 负例 (a) Decisions 无 R1 让步→enforce 须拦截；正例 (b) 有让步行→PARTIAL 放行' \
      '- 跑批留痕：check-complete 输出归档于 selftest 夹具目录' 
  } > "$_d/findings.md"
  {
    printf '%s\n' \
      '# progress（RC-20 fixture）' \
      '' \
      '### Phase 1: 夹具执行' \
      '- [x] 完成：uncovered 双态构造与终验跑批（证据=rcov-gate PARTIAL/FAILED 行）' 
  } > "$_d/progress.md"
done
# 负例/正例双跑（env 前置传 enforce 档位，同 RC-19 口径；stderr 落各夹具 rcov.err 留证）
env TASK_PLANNER_VC_GATE_ENFORCE=enforce bash "$CC_SCRIPT" "$_RC20_FIX/task_plan.md" \
  < /dev/null > "$_RC20_FIX/rcov.out" 2> "$_RC20_FIX/rcov.err"
rc20_neg_rc=$?
env TASK_PLANNER_VC_GATE_ENFORCE=enforce bash "$CC_SCRIPT" "$_RC20_POS/task_plan.md" \
  < /dev/null > "$_RC20_POS/rcov.out" 2> "$_RC20_POS/rcov.err"
rc20_pos_rc=$?
_rc20_neg_err="$_RC20_FIX/rcov.err"
_rc20_pos_err="$_RC20_POS/rcov.err"
if [ "$rc20_neg_rc" -ne 0 ] && grep -q 'rcov-gate' "$_rc20_neg_err" && grep -q '只可 PARTIAL' "$_rc20_neg_err" \
   && [ "$rc20_pos_rc" -eq 0 ] && grep -q 'rcov-gate' "$_rc20_pos_err"; then
  ok 20 "R-COVERAGE 双断: 裸 uncovered 无让步 enforce exit=$rc20_neg_rc≠0 拒 COMPLETE 含「只可 PARTIAL」; uncovered+让步行 exit=$rc20_pos_rc=0 PARTIAL 放行（rcov-gate 提示行在位）"
else
  bad 20 "R-COVERAGE 双断失败: 负例 exit=$rc20_neg_rc（应≠0 且含「只可 PARTIAL」拒 COMPLETE）/ 正例 exit=$rc20_pos_rc（应=0 PARTIAL 放行且 rcov-gate 提示行在位）"
fi
rm -rf "$_RC20_FIX" "$_RC20_POS"

# RC-21/22 共用被测对象：G3 三脚本均为 worktree 内本目录文件
UPS_HOOK="$SCRIPT_DIR/zcode-userpromptsubmit.sh" # RC-21：[PLAN TAMPERED] 处置文案载体（G3 重锁收紧）
INIT_SH="$SCRIPT_DIR/init-session.sh"            # RC-22：silent 路径 attestation 即时落盘载体（G3）

# RC-21 hook 文案锚（task-v132 G3 R3：无 Decisions 登记的重锁视为篡改信号）
# What：断言 zcode-userpromptsubmit.sh 的 TAMPERED 处置句双锚各恰好命中 1 次——
#      ① '无登记的重锁视为篡改信号'（重锁前置登记语义锚，=1 防重复插入/误删）；
#      ② 'Rule 51.7'（条款引用锚，文案须回溯到 critical-rules 51.7 纠正=回锚重译条款）。
# Why：G3 收紧的机器守护——72h 事故同形态的「重规划→无登记重锁」逃生门须在 hook 文案层
#      有可 grep 证据；双锚成对=防"语义锚在但条款引用丢失"的脱锚（与 RC-16 三锚范式同构）。
_rc21_a="$(grep -c '无登记的重锁视为篡改信号' "$UPS_HOOK" || true)"
_rc21_b="$(grep -c 'Rule 51\.7' "$UPS_HOOK" || true)"
if [ "$_rc21_a" -eq 1 ] && [ "$_rc21_b" -eq 1 ]; then
  ok 21 "zcode-userpromptsubmit.sh TAMPERED 文案锚「无登记的重锁视为篡改信号」=1 且 Rule 51.7 引用 =1（G3 重锁前置收紧在位）"
else
  bad 21 "zcode-userpromptsubmit.sh TAMPERED 文案锚异常: 篡改信号锚=$_rc21_a Rule51.7引用=$_rc21_b（应各 =1，G3 收紧被回退？）"
fi

# RC-22 init 静态锚（task-v132 G3 R3：silent 路径 .plan-attestation 即时落盘 INFO 锚）
# What：断言 init-session.sh 含 G3 silent 落盘 INFO 锚双行各恰好 1 次（=1 口径：防重复
#      插入/误删；两级锁定策略 2026-10-05 实测后主锁+兜底锁各 1 行 INFO，双锚独立断言
#      避免并集计数误读）——
#      ① 'silent 路径已即时落盘 .plan-attestation'（主锁成功行，grep -c =1）；
#      ② 'silent 路径兜底锁已落盘 .plan-attestation'（dispatch/fmea 逃生锁成功行，grep -c =1；
#      51.1 需求四锚硬门仍 fail-closed 在位，--skip 仅限可跳过门）。
# Why：G3「防窗口期篡改」行为落点的静态守护——INFO 行是 silent 档 attest 即时锁定的可观察
#      证据面（实测节跑 silent init 时双行之一须出现）；双锚缺任一 = silent 路径落盘逻辑
#      被删（窗口期重新敞开）。
_rc22_a="$(grep -c 'silent 路径已即时落盘 .plan-attestation' "$INIT_SH" || true)"
_rc22_b="$(grep -c 'silent 路径兜底锁已落盘 .plan-attestation' "$INIT_SH" || true)"
if [ "$_rc22_a" -eq 1 ] && [ "$_rc22_b" -eq 1 ]; then
  ok 22 "init-session.sh silent 路径 INFO 锚双行各 =1（主锁+兜底锁，G3 即时落盘在位）"
else
  bad 22 "init-session.sh silent 路径 INFO 锚异常: 主锁=$_rc22_a 兜底锁=$_rc22_b（应各 =1，G3 即时落盘逻辑被删/重复插入？）"
fi

# RC-23 51.8 行锚 + SKILL.md 51.8 联动锚（task-v133：未测试就声称完成禁令）
# What：断言 ① '^51.8 ' 行在位且含语义锚「未测试就声称完成」② SKILL.md 内 '51.8' 命中 ≥1（摘要 bullet M5.4 或 C37 行任一）。
# Why：51.8 是 VC-1 的条款本体（覆盖判据属实测形态的需求条目无实测证据=uncovered，51.3 口径）——
#      行锚=1 防重复插入/误删（RC-16 三锚范式）；SKILL 联动锚=防「条款扩到 51.8 但 SKILL 停摆 51.7」级联断链（RC-09 语义）。
#      RC-01（≥7）与 RC-15（'^54.'=0）不受 51.8 影响（51.8 不产生 54 号、≥7 阈值向下兼容 9 计数）。
_rc23_a="$(grep -c '^51\.8 ' "$CRIT" || true)"
_rc23_b="$(grep '^51\.8 ' "$CRIT" | grep -c '未测试就声称完成' || true)"
_rc23_c="$(grep -c '51\.8' "$SKILLMD" || true)"
if [ "$_rc23_a" -eq 1 ] && [ "$_rc23_b" -eq 1 ] && [ "$_rc23_c" -ge 1 ]; then
  ok 23 "critical-rules.md 51.8 行锚=1 且语义锚「未测试就声称完成」在位 且 SKILL.md '51.8' 联动 $_rc23_c ≥1"
else
  bad 23 "51.8 守护异常: 行锚=$_rc23_a(应1) 语义锚=$_rc23_b(应1) SKILL联动=$_rc23_c(应≥1)"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
