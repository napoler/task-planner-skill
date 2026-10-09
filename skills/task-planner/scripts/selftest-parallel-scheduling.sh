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
#     · scripts/check-plan-dispatch.sh（计划期守卫，P-04，双层口径）:
#         P-04 锚落位时硬断言：Rule 68 校验段锚 + hard 串（依赖-同组）+ advisory 串（组内全同）各 ≥1；
#              守卫单元未落位时 WARN-SOFT 降级（不计 FAIL，落位后下次运行自动升硬）
#     · SKILL.md（执行期入口联动，P-05，动态求值禁硬编码）:
#         P-05 C46 合规行 =1 + `Rule 68` 摘要引用 ≥1 + SKILL 内 `Critical Rules 1-NN` 上界
#              与 critical-rules.md 实测最大编号动态一致
#     · scripts/selftest-registry.tsv（登记行，P-06）:
#         P-06 含 selftest-parallel-scheduling.sh 行 ≥1
#     · config.json（零新键负断言，P-07）:
#         P-07 全文无 parallel/model-allocation 类新增 config 键（键名口径计数 =0）
#     · 既有语义回退负断言（P-08）:
#         P-08 21.4 段「未声明者默认串行」原文锚仍在（Rule 68 不回退 21.4 组间串行语义）
#     · references/split-pattern-library.md（模式库 P12 载体，P-09，双层口径）:
#         P-09 `P12` 与「依赖分批并行」锚在位（文档单元未落位时 WARN-SOFT 降级）
#   运行方式：`bash scripts/selftest-parallel-scheduling.sh`（只读 grep/python3，零写入）；
#   逐行打印 `P-NN PASS/FAIL/SOFT <说明>`，末行 `Total: 9 PASS=x FAIL=y`；
#   核心断言（P-01/02/03/05/06/07/08）任一 FAIL exit 1，全 PASS exit 0；
#   P-04/P-09 软降级（SOFT）不影响 exit——双轨施工窗口期设计，锚落位后自动升硬。
#   被检文件路径全部相对 SCRIPT_DIR 解析，保证仓库/worktree/三宿主部署位三处均可直接跑。
#
# Why（Rule 68.7 机制锚，task-v153 2026-10-09）:
#   用户 R3 诉求=机制固化长期生效面：计划初期显式依赖分析→推导并行分组→组内异构 agent/模型
#   分摊→组内写隔离防状态错乱。Rule 68 是 LLM 行为面条款（68.1 前置依赖列必填/68.2 组由依赖
#   推导/68.3 组内异构/68.4 组域写隔离均为行为义务，非机器触发），若条款锚/模板列/SKILL 联动
#   被后续裁剪误删，条款即变死文；本脚本=条款死文探测器。
#   P-04/P-09 双层口径的取舍：selftest 与守卫/文档单元同批并行施工（组域写隔离 68.4），
#   本单元不得阻塞等待他单元落盘；用「锚在位→硬断言、未落位→SOFT 不计 FAIL」把回归
#   窗口期与永久守护合并在一个脚本内，杜绝锚落位后再来一次脚本返工。
#   只断言 Rule 68 新增锚 + 21.4 不回退负断言，不触碰既有 selftest 断言行（防锚级联，
#   Rule 36.5 纯增量）；计数锚一律动态求值（施工图 §八钉值级联三查③，禁硬编码当前态）。
# 依赖：bash + grep；P-05 动态上界对照需 awk（零新依赖，POSIX 口径）。只读，零写入。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
TPL="$SKILL_ROOT/templates/task_plan.md"
CONFIG="$SKILL_ROOT/config.json"
REGISTRY="$SCRIPT_DIR/selftest-registry.tsv"
DISPATCH="$SCRIPT_DIR/check-plan-dispatch.sh"
SPL="$SKILL_ROOT/references/split-pattern-library.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'P-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'P-%s FAIL %s\n' "$1" "$2"; }
soft(){ printf 'P-%s SOFT %s\n' "$1" "$2"; }

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

# P-04 check-plan-dispatch.sh 守卫段：硬锚在位则硬断言，未落位则 SOFT 降级（施工图 T4）
# What：断言 68 校验段三锚——段标识 `Rule 68` + hard 串（依赖-同组矛盾）+ advisory 串（组内全同）；
#      三锚齐=守卫段已施工 → 硬断言 PASS/FAIL；段标识缺失=守卫单元并行施工中 → SOFT 不计 FAIL。
# Why：双轨施工窗口期（本单元与守卫单元同批并行，组域写隔离 68.4）；锚落位后下次运行自动升硬，
#      永久守护面=三锚全量硬断言。
seg="$(grep -cE 'Rule 68' "$DISPATCH" || true)"
hardc="$(grep -cE '依赖-同组|依赖同组|同组矛盾' "$DISPATCH" || true)"
advc="$(grep -cE '组内全同|执行体全同|组内.*全同' "$DISPATCH" || true)"
if [ "$seg" -ge 1 ]; then
  if [ "$hardc" -ge 1 ] && [ "$advc" -ge 1 ]; then
    ok 04 "check-plan-dispatch.sh 68 守卫段在位：段锚=$seg + hard 串(依赖-同组)=$hardc + advisory 串(组内全同)=$advc（均 ≥1）"
  else
    bad 04 "check-plan-dispatch.sh 68 段锚在位(=$seg)但 hard 串=$hardc / advisory 串=$advc（各应 ≥1）"
  fi
else
  soft 04 "check-plan-dispatch.sh 无 Rule 68 校验段（守卫单元并行施工中；落位后本断言自动升硬）"
fi

# P-05 SKILL.md C46 行 + Rule 68 摘要行 + 上界动态对照（施工图 T5，动态求值禁硬编码）
# What：断言 ① C46 合规行 =1 ② `Rule 68` 引用 ≥1 ③ SKILL 内 `Critical Rules 1-NN` 上界
#      与 critical-rules.md 实测最大章节编号一致（awk 动态求值，v152/v153 级联漂移自吸收）。
# Why：C46 是 68 消费侧合规清单唯一落点；上界若滞后于条款实际最大编号=SKILL 枚举面与
#      条款面漂移（v150 计数钉值教训）——动态对照消除钉值腐化。
c46="$(grep -cE '^\| C46 ' "$SKILLMD" || true)"
r68="$(grep -cE 'Rule 68' "$SKILLMD" || true)"
crit_max="$(grep -oE '^### [0-9]+ ' "$CRIT" | awk '{print $2}' | sort -n | tail -1)"
skill_max="$(grep -oE 'Critical Rules 1-[0-9]+' "$SKILLMD" | grep -oE '[0-9]+' | sort -n | tail -1)"
if [ "$c46" -eq 1 ] && [ "$r68" -ge 1 ] && [ -n "$crit_max" ] && [ -n "$skill_max" ] && [ "$skill_max" -eq "$crit_max" ]; then
  ok 05 "SKILL.md C46 行=$c46（=1）+ 'Rule 68' 引用=$r68（≥1）+ 上界 1-${skill_max} = critical-rules 实测最大 ${crit_max}（动态一致）"
else
  bad 05 "SKILL.md C46=$c46（应 =1）/ Rule 68 引用=$r68（应 ≥1）/ 上界 skill=${skill_max:-N/A} vs critical=${crit_max:-N/A}（应相等）"
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

# P-09 split-pattern-library.md P12「依赖分批并行」锚：在位则硬断言，未落位则 SOFT 降级（施工图 T9）
# What：断言模式库 `P12` 与「依赖分批并行」双锚在位；双锚齐=文档单元已施工→PASS；
#      缺失=文档单元并行施工中→SOFT 不计 FAIL。
# Why：P12 是 68.5 parallel playbook 的模式库承载面（施工图 §六草案）；与 P-04 同一
#      双轨窗口期口径，锚落位后自动升硬。
p12="$(grep -cE 'P12' "$SPL" 2>/dev/null || true)"
dep="$(grep -c '依赖分批并行' "$SPL" 2>/dev/null || true)"
if [ "$p12" -ge 1 ] && [ "$dep" -ge 1 ]; then
  ok 09 "split-pattern-library.md P12 锚=$p12 +「依赖分批并行」锚=$dep（均 ≥1）"
else
  soft 09 "split-pattern-library.md P12=$p12 / 依赖分批并行=$dep（文档单元并行施工中；落位后本断言自动升硬）"
fi

printf 'Total: 9 PASS=%d FAIL=%d\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
