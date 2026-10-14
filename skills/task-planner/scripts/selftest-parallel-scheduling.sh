#!/usr/bin/env bash
# selftest-parallel-scheduling.sh — task-v153: Rule 68「计划期依赖分析、并行分组、组内异构分摊与组域写一致性纪律」静态守护
#
# What（守护对象 + 运行方式）:
#   静态断言 task-v153 Rule 68 全链落点在位（形态对齐邻族 selftest-goal-unit-goal-mode.sh 的
#   assert/计数/exit 语义，TAP 风格 P-01..P-09 九条编号断言；施工图 design-rule68.md §五 T1-T9）：
#     · critical-rules.md（Rule 68 条款本体，P-01/P-02）:
#         P-01 `^68\.[1-7] ` 七子条 =7（68.1-68.7 主体行全在位）
#         P-02 条款四关键词串 依赖分析/并行分组/异构分摊/组域写隔离 各 ≥1
#     · templates/task_plan.md（S-unit 表「前置依赖」列载体，P-03）:
#         P-03 S-unit 表头行含「前置依赖」≥1
#     · scripts/check-plan-dispatch.sh（计划期守卫，P-04，硬断言）:
#         P-04 Rule 68 校验段锚 + hard 串（依赖-同组，锚 add_violation 可执行行）+ advisory 串
#              （组内全同，锚 echo WARN 可执行行）各 ≥1；任一缺失=FAIL（2026-10-09 CR 收敛硬断言）
#     · SKILL.md（执行期入口联动，P-05，动态求值禁硬编码）:
#         P-05 C46 合规行 =1 + `Rule 68` 摘要引用 ≥1 + SKILL 内 `Critical Rules 1-NN(+N)` 上界
#              与 critical-rules.md 实测最大编号动态一致
#     · scripts/selftest-registry.tsv（登记行，P-06）:
#         P-06 含 selftest-parallel-scheduling.sh 行 ≥1
#     · config.json（零新键负断言，P-07）:
#         P-07 全文无 parallel/model-allocation 类新增 config 键（键名口径计数 =0）
#     · 既有语义回退负断言（P-08）:
#         P-08 21.4 段「未声明者默认串行」原文锚仍在（Rule 68 不回退 21.4 组间串行语义）
#     · references/split-pattern-library.md（模式库 P12 载体，P-09，硬断言）:
#         P-09 `P12` 与「依赖分批并行」双锚在位；任一缺失=FAIL（2026-10-09 CR 收敛硬断言）
#   运行方式：`bash scripts/selftest-parallel-scheduling.sh`（只读 grep/python3，零写入）；
#   逐行打印 `P-NN PASS/FAIL <说明>`，末行 `Total: 9 PASS=x FAIL=y`；
#   九条断言（P-01..P-09）任一 FAIL exit 1，全 PASS exit 0（2026-10-09 起 P-04/P-09 亦为硬断言）。
#   被检文件路径全部相对 SCRIPT_DIR 解析，保证仓库/worktree/三宿主部署位三处均可直接跑。
#
# Why（Rule 68.7 机制锚，task-v153 2026-10-09）:
#   用户 R3 诉求=机制固化长期生效面：计划初期显式依赖分析→推导并行分组→组内异构 agent/模型
#   分摊→组内写隔离防状态错乱。Rule 68 是 LLM 行为面条款（68.1 前置依赖列必填/68.2 组由依赖
#   推导/68.3 组内异构/68.4 组域写隔离均为行为义务，非机器触发），若条款锚/模板列/SKILL 联动
#   被后续裁剪误删，条款即变死文；本脚本=条款死文探测器。
#   P-04/P-09 硬断言收敛（2026-10-09 task-v153 CR F3）：原双层 SOFT 逻辑自指——判定「已落位」用的
#   锚正是被守护对象本身，anchor 被删即 SOFT（exit 不受影响）而非 FAIL，无法区分「未施工」与
#   「回归删除」。施工窗口已结束（守卫段/模式库均已落位），故收敛为硬断言：锚缺失=回归 FAIL。
#   P-04 探针锚定可执行代码行（2026-10-09 CR F4）：原探针（`依赖-同组|组内全同`）命中守卫自身注释头
#   文字，仅注释留存即 PASS，断言可腐化；改锚 add_violation/echo 调用行后，注释保留而代码删除即 FAIL。
#   只断言 Rule 68 新增锚 + 21.4 不回退负断言，不触碰既有 selftest 断言行（防锚级联，
#   Rule 36.5 纯增量）；计数锚一律动态求值（施工图 §八钉值级联三查③，禁硬编码当前态）。
# 依赖：bash + grep；P-05 动态上界对照需 awk（零新依赖，POSIX 口径）。只读，零写入。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
# [task-v171 回归修复 2026-10-12 派发域搬迁] Rule 68（计划期依赖分析/并行分组/组域写隔离）与 Rule 21.4
#   （未声明者默认串行）均属 task-dispatch 域，原文已迁至 skills/task-dispatch/references/critical-rules-dispatch.md；
#   本脚本 CRIT 全部用法（L67 68.x 子条/L75 P-02 关键词/L140 P-08 21.4 锚）均为派发域断言、无核心域用途
#   （已逐行核实），CRIT 改指派发域文件，断言语义零改动。CRIT_CORE 保留指向核心（P-05 上界对照用）。
CRIT_CORE="$CRIT"
CRIT="$SKILL_ROOT/../task-dispatch/references/critical-rules-dispatch.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
TPL="$SKILL_ROOT/templates/task_plan.md"
CONFIG="$SKILL_ROOT/config.json"
REGISTRY="$SCRIPT_DIR/selftest-registry.tsv"
DISPATCH="$SCRIPT_DIR/check-plan-dispatch.sh"
# [task-v171 回归修复 2026-10-12 派发域搬迁] 现象: P-09 FAIL(split-pattern-library.md P12 锚=0)｜
# 根因: 库文件随派发域迁至 skills/task-dispatch/references, 旧路径 $SKILL_ROOT/references 为空｜
# 修法: 改锚 $SKILL_ROOT/../task-dispatch/references/split-pattern-library.md
SPL="$SKILL_ROOT/../task-dispatch/references/split-pattern-library.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'P-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'P-%s FAIL %s\n' "$1" "$2"; }

# P-01 critical-rules.md `^68\.[1-7] ` 七子条计数=7
# What：断言 68.1-68.7 七条子条主体行全在位（施工图 T1）。
# Why：七子条是 Rule 68 全部义务的唯一文本落点；缺任一=条款本体被裁剪（防改写时误删 68.x 段）。
n="$(grep -cE '^68\.[1-7] ' "$CRIT" || true)"
if [ "$n" -eq 7 ]; then ok 01 "critical-rules.md '68.x ' 七子条锚 =7"; else bad 01 "critical-rules.md '68.x ' 计数=$n（应 =7）"; fi

# P-02 条款四关键词串各 ≥1（施工图 T2）
# What：断言 依赖分析/并行分组/异构分摊/组域写隔离 四个条款核心词在 critical-rules.md 各出现 ≥1。
# Why：六则草案四关键词=68 标题语义分解；缺词=条款在裁剪/改写中被稀释成空壳。
miss=""
for kw in 依赖分析 并行分组 异构分摊 组域写隔离; do
  c="$(grep -c "$kw" "$CRIT" || true)"
  [ "$c" -ge 1 ] || miss="$miss $kw(=$c)"
done
if [ -z "$miss" ]; then ok 02 "critical-rules.md 四关键词串 依赖分析/并行分组/异构分摊/组域写隔离 各 ≥1"; else bad 02 "critical-rules.md 缺词:$miss（各应 ≥1）"; fi

# P-03 templates/task_plan.md S-unit 表头行含「前置依赖」≥1（施工图 T3）
# What：断言 S-unit 表头行（| ID | 目标… 开头）内含「前置依赖」列。
# Why：前置依赖列是 68.1 计划期依赖分析的任务级强制载体（模板承载面）；列丢=新计划无落点，
#      68.1「无依赖显式填 -」义务随之无承载。
n="$(grep -cE '^\| ID .*前置依赖.*状态' "$TPL" || true)"
if [ "$n" -ge 1 ]; then ok 03 "templates/task_plan.md S-unit 表头含「前置依赖」列 =${n}（≥1）"; else bad 03 "templates/task_plan.md S-unit 表头「前置依赖」列缺失（计数=$n，应 ≥1）"; fi

# P-04 check-plan-dispatch.sh 守卫段：三锚全量硬断言（施工图 T4；2026-10-09 CR F3 收敛）
# What：断言 68 校验段三锚——段标识 `Rule 68` + hard 串（依赖-同组矛盾，锚 add_violation 可执行行）
#      + advisory 串（组内全同，锚 echo WARN 可执行行）；三锚任一缺失=FAIL。
# Why：① 双层 SOFT 收敛为硬断言（2026-10-09 task-v153 CR F3）——施工窗口已结束，守卫段已落位，
#      锚缺失即为「回归删除」而非「未施工」，必须 FAIL 拦截；② 探针锚定可执行代码行（CR F4）——
#      原探针命中守卫自身注释头文字，仅注释留存即 PASS，断言可腐化；改锚调用行后注释保留而代码删除即 FAIL。
seg="$(grep -cE 'Rule 68' "$DISPATCH" || true)"
hardc="$(grep -cE 'add_violation.*依赖-同组矛盾' "$DISPATCH" || true)"
advc="$(grep -cE '(echo|add_violation).*组内(全同|成员执行体全部为)' "$DISPATCH" || true)"
if [ "$seg" -ge 1 ] && [ "$hardc" -ge 1 ] && [ "$advc" -ge 1 ]; then
  ok 04 "check-plan-dispatch.sh 68 守卫段在位：段锚=$seg + hard 串(依赖-同组)=$hardc + advisory 串(组内全同)=$advc（均 ≥1）"
else
  bad 04 "check-plan-dispatch.sh 68 守卫段锚缺失：段锚=$seg / hard 串=$hardc / advisory 串=$advc（各应 ≥1；2026-10-09 已收敛硬断言）"
fi

# P-05 [task-v171 核心瘦身] C46 行 → 卫星路由表 task-dispatch 行；'Rule 68' 引用 → 路由行枚举；上界对照改分层口径
#   现象：SKILL.md 瘦身后 C46 合规行与 'Rule 68' 整串引用归零、'Critical Rules 1-NN' 主 label 演进为
#     「Rules 1-80 全集索引」（skill_max 提取式失配=空），P-05 恒 FAIL。
#   根因：Rule 68 属派发域；合规清单表→G1-G8 + 卫星路由表承载消费面；全集口径切换为核心 12 条+10 卫星。
#   修法：① c46=卫星路由表 task-dispatch 行 =1（68 消费面瘦身后载体）；② r68=路由行枚举 Rule 68 ≥1；
#     ③ 上界动态对照改分层口径：SKILL 声明 'Rules 1-81'（skill_max=81）+ 核心 CRIT_CORE 含 Rule 82
#     （crit_max=1，分层纪律为全集上界延伸）——声明面与条款面上界不漂移的判据强度保持（v152/v153 动态求值范式延续）。
c46="$(grep -cE '^\| task-dispatch \|' "$SKILLMD" || true)"
r68="$(grep -E '^\| task-dispatch \|' "$SKILLMD" | grep -cE 'Rule [0-9,]*68' || true)"
# [2026-10-10 task-v160/task-v163 上界动态对照演进史] 保留如上（旧口径=SKILL 'Critical Rules 1-NN' vs 核心 CR 最大编号）；
#   v171 分层后口径=SKILL 'Rules 1-80' 声明 + 核心 CRIT Rule 82（全集上界 82=80+82）。
#   [2026-10-14 task-v172 对齐 1-83] SKILL 全集声明演进为 'Rules 1-83'，skill_max=83（Rule 83 落地）。
#   [2026-10-14 task-v173 对齐 1-84] Rule 84（验证技能独立化）落地，skill_max=84。
skill_max="$(grep -oE 'Rules 1-84' "$SKILLMD" | head -1 | grep -oE '[0-9]+' | tail -1 || true)"
crit_max="$(grep -cE '^### 82 ' "$CRIT_CORE" || true)"
if [ "$c46" -eq 1 ] && [ "$r68" -ge 1 ] && [ "${skill_max:-0}" -eq 84 ] && [ "${crit_max:-0}" -eq 1 ]; then
  ok 05 "SKILL.md 路由表 task-dispatch 行=$c46（=1）+ 枚举 Rule 68=$r68（≥1）+ 全集声明 1-${skill_max} ∧ 核心 CRIT Rule 82=$crit_max（分层口径上界一致）"
else
  bad 05 "SKILL.md 路由行=$c46（应 =1）/ Rule 68 枚举=$r68（应 ≥1）/ 全集 skill=${skill_max:-N/A}（应 84）vs 核心 82=$crit_max（应 1）"
fi

# P-06 selftest-registry.tsv 含本脚本登记行 ≥1（施工图 T6）
# What：断言 registry 内有 selftest-parallel-scheduling.sh 行。
# Why：registry 是全部 selftest 脚本的登记账本（selftest-registry.sh T02 无缺失核对）；
#      新脚本未登记=账本漏账，registry 守护 FAIL。
n="$(grep -c 'selftest-parallel-scheduling.sh' "$REGISTRY" || true)"
if [ "$n" -ge 1 ]; then ok 06 "selftest-registry.tsv 含 selftest-parallel-scheduling.sh 行 =${n}（≥1）"; else bad 06 "selftest-registry.tsv 缺 selftest-parallel-scheduling.sh 登记行（计数=$n，应 ≥1）"; fi

# P-07 config.json 无新增 parallel/model-allocation 类键（零新键负断言，施工图 T7）
# What：断言 config.json 全文中形如键名/键值出现的 parallel/model-allocation 模式 =0。
# Why：68.7 承诺零新 config 键（沿用 25.4/43.4/66.6 零新键纪律）；grep 口径覆盖任意位置
#      的键名引入（比 properties 子树口径更严，防止键藏在非 properties 区段被漏检）。
n="$(grep -cE 'parallel[a-z_-]*|model[ _-]allocat' "$CONFIG" || true)"
if [ "$n" -eq 0 ]; then ok 07 "config.json parallel/model-allocat 类键 =0（零新键）"; else bad 07 "config.json parallel/model-allocat 类键 =${n}（应 =0，零新键承诺被破）"; fi

# P-08 21.4 既有语义未回退负断言：「未声明者默认串行」原文锚仍在（施工图 T8）
# What：断言 critical-rules.md 中 21.4 声明制段「未声明者默认串行」原文锚 ≥1。
# Why：68.2 明写「21.4 组间串行语义不变，不回退」——并行分组只是声明制增强，未声明组
#      仍走串行槽；该原文行丢失=回退风险（并行默认化）无探测器。
n="$(grep -c '未声明者默认串行' "$CRIT" || true)"
if [ "$n" -ge 1 ]; then ok 08 "critical-rules.md 21.4「未声明者默认串行」原文锚 =${n}（≥1，语义未回退）"; else bad 08 "critical-rules.md「未声明者默认串行」锚缺失（计数=$n，应 ≥1；21.4 语义回退风险）"; fi

# P-09 split-pattern-library.md P12「依赖分批并行」锚：双锚硬断言（施工图 T9；2026-10-09 CR F3 收敛）
# What：断言模式库 `P12` 与「依赖分批并行」双锚均在位；任一缺失=FAIL。
# Why：双层 SOFT 收敛为硬断言（2026-10-09 task-v153 CR F3）——文档单元已落位，锚缺失即为回归删除；
#      P12 是 68.5 parallel playbook 的模式库承载面（施工图 §六草案）。
p12="$(grep -cE 'P12' "$SPL" 2>/dev/null || true)"
dep="$(grep -c '依赖分批并行' "$SPL" 2>/dev/null || true)"
if [ "$p12" -ge 1 ] && [ "$dep" -ge 1 ]; then
  ok 09 "split-pattern-library.md P12 锚=$p12 +「依赖分批并行」锚=$dep（均 ≥1）"
else
  bad 09 "split-pattern-library.md P12=$p12 / 依赖分批并行=$dep（各应 ≥1；2026-10-09 已收敛硬断言）"
fi

printf 'Total: 9 PASS=%d FAIL=%d\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
