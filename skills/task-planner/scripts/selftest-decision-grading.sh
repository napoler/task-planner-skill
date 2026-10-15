#!/usr/bin/env bash
# selftest-decision-grading.sh — task-v160: Rule 72「决策分级与用户打断纪律」静态守护（72.6 机制面）
#
# What（守护对象 + 运行方式）:
#   静态断言 task-v160 全链落点在位（对齐 selftest-report-reviewability.sh 范式）。
#   DG-01..DG-12 全量实现（S7 落 DG-01..DG-07；S8 补齐 DG-08..DG-12 触点分组锚 + DG-06 翻常驻 FAIL 档）：
#     · references/critical-rules.md（Rule 72 条款本体，DG-01..DG-03）:
#         DG-01 `^## Rule 72` 标题=1 且 `^### 72.[1-6]` 六子条>=6
#         DG-02 三级关键词齐备（A 级必须询问 / C 级禁止询问 / 基础质检硬门 各>=1）
#         DG-03 Rule 72 段内 ASCII 冒号紧邻数字的引用形态=0（防级联漂移，v148 判例）
#     · SKILL.md（消费侧接线，DG-04/DG-11）:
#         DG-04 `Rule 72` >=5 且合规清单行内容锚（`^| C<N> | ...决策分级与用户打断...`）在位，且该行含「A 级」与「C 级」字样
#         DG-11 SKILL 接线组：同 DG-04 口径（Rule 72>=5 + 合规行内容锚含 A 级/C 级），按触点分组再组织
#     · 触点文件清单（DG-05 总锚 + DG-08..DG-10 分组锚）:
#         DG-05 5 文件逐一 grep "Rule 72" 达阈值（critical-rules>=5 其余见阈值数组），任一缺失=FAIL
#         DG-08 引用面组：critical-rules.md `Rule 72`>=5
#         DG-09 模板面组：image-type.md>=1 且 multiview-ref-type.md>=1
#         DG-10 管线面组：article-batch-publisher.md>=2 且 article-field-fixer.md>=1
#     · registry + config（DG-06/DG-07）:
#         DG-06 registry 登记行>=1（常驻 FAIL 档，S8 翻档；env DG_REGISTRY_STRICT=0 可降档排查）
#         DG-07 config 零新键=0（恒 FAIL 档）
#     · 行为面（DG-12）: 占位跳过 WARN 档（不计 PASS）——行为面（LLM 决策分级实际行为）无静态可校验面，
#         fixture 回归执行期启用（TODO(DG-13)）；2026-10-16 修虚假覆盖：原「注释行在位即 PASS」自指断言废除
#   运行方式: `bash scripts/selftest-decision-grading.sh`（只读 grep，零写入）；
#   逐行打印 `DG-NN PASS/FAIL/WARN: <说明>`，末行 `Total: PASS=N FAIL=N WARN=N`；
#   FAIL>0 -> exit 1，否则 exit 0。
#   被检文件路径全部相对 SKILL_ROOT 解析，保证仓库/worktree/部署位三处均可直接跑。
#
# Why（Rule 72.6 机制锚，task-v160 2026-10-10）:
#   用户核心诉求（R1）=「他将一些无关紧要的东西交给用户去决策，重要的东西，然后毫不犹豫的就给恶意修改掉。
#   比如更换风格……这么重大的决定完全不能询问用户」——即决策点缺「影响权重」分级轴。
#   Rule 72 为纯行为面条款（判定面=LLM 行为），无脚本即死文（53.2 零载体判例）：
#   本脚本锁「条款六子条文本 + 三级关键词 + 行号锚禁令 + SKILL 接线 + 触点文件 + registry/config」
#   六面配对——任一面被后续裁剪误删即报警（防复发，Rule 31.5 消费侧）。
#   DG-02 关键词容错说明（2026-10-10 S7 实现记录）: 材料规格书写的字面串「A 级必须询问」「C 级禁止询问」
#   在条文实现中以全角括号分隔（「A 级（必须询问」「C 级（禁止询问」），故断言用 `（?` 容错括号，
#   既可命中材料字面形态，也可命中当前条文形态；语义不变（锁定 A 级/C 级「必须/禁止询问」关键词不被裁剪）。
#
# 消费方: 终验（VC-3 机器守护在位）与 CI 回归（全量 selftest 跑批）
# 断言面: Rule 72 决策分级静态锚（条款/接线/触点/registry/config 五面配对）
# 依据: plans/archive/task-v160-decision-grading/task_plan.md（守护断言清单 S7/S8 材料包；task-v160 已按 Rule 81 归档至 plans/archive/，2026-10-14）

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── 路径定义（相对技能根）──
CR="$SKILL_ROOT/references/critical-rules.md"
# [task-v171 纪律域搬迁 2026-10-12] Rule 72（决策分级与用户打断纪律）属纪律域，原文已迁至
#   skills/task-discipline/references/critical-rules-discipline.md（核心 critical-rules.md 只剩 11 条核心规则），
#   DG-01/02/03/05/08 断言改指 CRIT_D；CR 保留指向核心。卫星文件标题为统一「### 72 标题」格式
#   （核心旧格式 `## Rule 72`），标题行锚同步适配，断言语义（标题唯一+六子条+关键词+零行号引用）零改动。
CRIT_D="$SKILL_ROOT/../task-discipline/references/critical-rules-discipline.md"
SKILL="$SKILL_ROOT/SKILL.md"
REGISTRY="$SCRIPT_DIR/selftest-registry.tsv"
CONFIG="$SKILL_ROOT/config.json"

# ── DG-05 触点文件清单（相对技能根）+ 逐文件 Rule 72 命中阈值 ──
# [task-v171 纪律域搬迁 2026-10-12] Rule 72 条款本体已迁至 ../task-discipline/references/critical-rules-discipline.md，
#   触点清单第 1 项由 references/critical-rules.md 改指该文件（同 report-reviewability 的 batch-quality-gate 先例）；
#   阈值 5 不变（discipline 文件内 'Rule 72' 引用面实测 6 ≥5），断言语义零改动。
TOUCH_FILES=(
  "../task-discipline/references/critical-rules-discipline.md"
  "templates/variant/image-type.md"
  "templates/variant/multiview-ref-type.md"
  "companion/agents/article-batch-publisher.md"
  "companion/agents/article-field-fixer.md"
)
TOUCH_THRESH=(5 1 1 2 1)

# ── 计数器与输出 helper（风格同构于 selftest-report-reviewability.sh）──
PASS=0; FAIL=0; WARN=0
ok()   { echo "$1 PASS: $2"; PASS=$((PASS+1)); }
bad()  { echo "$1 FAIL: $2"; FAIL=$((FAIL+1)); }
warn() { echo "$1 WARN: $2"; WARN=$((WARN+1)); }

# ── 通用计数 helper（文件缺失计 0，非静默失败：计数即证据）──
# 2026-10-10 task-v160 S13b（修 S11 代码审查 Nit#3）: 原实现 `grep -c ... 2>/dev/null || true`
#   在「文件存在但不可读」时 stdout 为空 → 调用方 `[ "" -lt N ]` 触发 `integer expression expected`，
#   且 `2>/dev/null` 静默吞错（违反 §九 禁吞错）。改为显式捕获计数 + 空值兜底 0：
#     · 有匹配(rc=0)/无匹配(rc=1，stdout 已为 0)/读错误(rc=2，stdout 空) 三态均得合法整数；
#     · 不再 `2>/dev/null`，grep/ugrep 的权限/IO 报错仍可见（退出码不吞）。
cnt()  { [ -f "$2" ] || { echo 0; return; }; local n; n="$(grep -c -e "$1" "$2")"; printf '%s' "${n:-0}"; }
cntE() { [ -f "$2" ] || { echo 0; return; }; local n; n="$(grep -cE -- "$1" "$2")"; printf '%s' "${n:-0}"; }

# ── DG-01: Rule 72 条款锚（标题=1 六子条>=6）──
DG01_TITLE=$(cnt '^### 72 ' "$CRIT_D")
DG01_SUBS=$(cnt '^### 72\.[1-6]' "$CRIT_D")
if [ "$DG01_TITLE" -eq 1 ] && [ "$DG01_SUBS" -ge 6 ]; then
    ok "DG-01" "Rule 72 条款锚(标题=1 子条>=6)"
else
    bad "DG-01" "Rule 72 条款锚(got title=$DG01_TITLE subs=$DG01_SUBS expect==1,>=6)"
fi

# ── DG-02: 三级关键词齐备（A 级必须询问 / C 级禁止询问 / 基础质检硬门）──
# What: 容错全角括号（`（?`）匹配 A/C 级「必须/禁止询问」关键词。
# Why: 见文件头 Why 段——材料字面串与条文全角括号形态差异，容错后两形态均命中，语义不变。
DG02_A=$(cntE 'A 级（?必须询问' "$CRIT_D")
DG02_C=$(cntE 'C 级（?禁止询问' "$CRIT_D")
DG02_G=$(cnt '基础质检硬门' "$CRIT_D")
if [ "$DG02_A" -ge 1 ] && [ "$DG02_C" -ge 1 ] && [ "$DG02_G" -ge 1 ]; then
    ok "DG-02" "三级关键词齐备(A 级必须询问/C 级禁止询问/基础质检硬门)"
else
    bad "DG-02" "三级关键词缺失(got A=$DG02_A C=$DG02_C G=$DG02_G expect all>=1)"
fi

# ── DG-03: Rule 72 段无行号引用形态（防级联漂移，v148 判例）──
# What: 截取 `^## Rule 72` 起至文件尾的片段，片段内 ASCII 冒号紧邻数字=FAIL。
# Why: 条文引用行号会随文件增删级联漂移，v148 判例已证实；文本锚替代行号锚是本仓硬纪律。
BLOCK72="$(sed -n '/^### 72 /,$p' "$CRIT_D" 2>/dev/null || true)"
DG03_HITS=$(printf '%s' "$BLOCK72" | grep -cE ':\s?[0-9]+' 2>/dev/null || true)
if [ "$DG03_HITS" -eq 0 ]; then
    ok "DG-03" "Rule 72 段无行号引用形态"
else
    bad "DG-03" "Rule 72 段行号引用形态命中=$DG03_HITS"
fi

# ── DG-04 [task-v171 核心瘦身]: SKILL 接线锚（Rule 72>=1 终验段 + 卫星路由表 discipline 行 + CRIT_D 72 块 A 级/C 级锚）──
# What: 断言 SKILL.md 中 `Rule 72` 命中数>=1（瘦身后 SKILL 侧唯一接线点=终验交付段「决策分级（Rule 72）…按卫星
#       task-discipline 全文执行」行；原 >=5=Rules 全集行/References 表/终验段/索引段/合规清单五处，随瘦身合并为终验段+
#       卫星路由表两载体），并以卫星路由表 discipline 行为路由内容锚，以 CRIT_D Rule 72 段为分级语义锚（A 级/C 级）。
# Why: Rule 72 属纪律域已迁 CRIT_D；SKILL 侧不展开非核心规则条文（Rule 82 禁回潮），合规清单行（`^| C<N> | ...决策分级与用户打断...`）
#      随合规清单表瘦身移除。内容锚（行号锚替代纪律）保持：语义锚改钉 CRIT_D 72 段原文（DG-02 同测 CRIT_D 三级关键词，双保险）。
#      本处修法=现象（R72 5→1、合规行=0 致 DG-04 恒 FAIL）+根因（瘦身移除非核心域摘要/C 行）+修法（终验段+路由表+CRIT_D 语义锚三锚重定向）。
DG04_R72=$(cnt "Rule 72" "$SKILL")
DG04_ROWCNT=$(cnt '| task-discipline |' "$SKILL")
DG04_BLOCK72="$(sed -n '/^### 72 /,$p' "$CRIT_D" 2>/dev/null || true)"
DG04_A=$(printf '%s' "$DG04_BLOCK72" | grep -c "A 级")
DG04_C=$(printf '%s' "$DG04_BLOCK72" | grep -c "C 级")
if [ "$DG04_R72" -ge 1 ] && [ "$DG04_ROWCNT" -ge 1 ] && [ "$DG04_A" -ge 1 ] && [ "$DG04_C" -ge 1 ]; then
    ok "DG-04" "SKILL 接线锚(终验段 Rule 72>=1 ∧ 路由表 discipline 行>=1 ∧ CRIT_D 72 段语义锚含 A 级/C 级)"
else
    bad "DG-04" "SKILL 接线锚(got R72=$DG04_R72 ROW=$DG04_ROWCNT A=$DG04_A C=$DG04_C expect R72>=1,ROW>=1,A>=1,C>=1)"
fi

# ── DG-05: 触点文件清单 Rule 72 锚齐备（逐文件阈值断言）──
DG05_MISSING=0
DG05_GOT=""
for i in "${!TOUCH_FILES[@]}"; do
    f="${TOUCH_FILES[$i]}"
    th="${TOUCH_THRESH[$i]}"
    got=$(cnt "Rule 72" "$SKILL_ROOT/$f")
    DG05_GOT="$DG05_GOT ${f##*/}=$got/$th"
    if [ "$got" -lt "$th" ]; then
        DG05_MISSING=$((DG05_MISSING+1))
    fi
done
if [ "$DG05_MISSING" -eq 0 ]; then
    ok "DG-05" "5 触点文件 Rule 72 锚齐备"
else
    bad "DG-05" "触点文件锚缺失=$DG05_MISSING (got$DG05_GOT)"
fi

# ── DG-06: registry 登记行（常驻 FAIL 档 — S8 翻档 2026-10-10）──
# What: registry.tsv 含本脚本登记行；缺失即 FAIL（登记纪律硬门）。
# Why: 登记行已落位（S8），2026-10-10 翻硬档——S7 的中间态宽限（默认 WARN）已收束为常驻 FAIL；
#      env DG_REGISTRY_STRICT 保留为降档开关：默认 1（FAIL），显式 0 可临时降档排查。
DG06_REG=$(cnt "selftest-decision-grading" "$REGISTRY")
if [ "$DG06_REG" -ge 1 ]; then
    ok "DG-06" "registry 登记行在位"
elif [ "${DG_REGISTRY_STRICT:-1}" = "1" ]; then
    bad "DG-06" "registry 登记行缺失(常驻 FAIL 档 DG_REGISTRY_STRICT=1)"
else
    warn "DG-06" "registry 登记行缺失(降档 DG_REGISTRY_STRICT=0；登记行已落位 S8)"
fi

# ── DG-07: config 零新键（恒 FAIL 档）──
# What: config.json 中决策分级专用新键名命中数=0。
# Why: Rule 72.6 明确「零新 config 键」，新增配置键=违反零新键纪律，恒 FAIL。
DG07_CFG=$(cnt "decision_grading_enforce" "$CONFIG")
if [ "$DG07_CFG" -eq 0 ]; then
    ok "DG-07" "config 零新键(decision_grading_enforce=0)"
else
    bad "DG-07" "config 新键命中=$DG07_CFG(恒 FAIL 档)"
fi

# ── DG-08..DG-12: 触点分组锚（S8 实现；分组=引用面/模板面/管线面/SKILL 接线/行为面预留）──
# What: 将 DG-04/DG-05 的单体断言按「触点分组」再组织——引用面(DG-08)/模板面(DG-09)/管线面(DG-10)/
#       SKILL 接线(DG-11) 各成一组，组内逐文件阈值齐备方 PASS；DG-12 为行为面 fixture 回归预留占位。
# Why: 分组锚使失败定位更精确（哪一面被裁剪一眼可见），阈值与 DG-04/DG-05 同源（单一权威口径，
#      防口径漂移）；行为面（LLM 决策分级实际行为）无法静态断言，留 TODO(DG-13) 占位待执行期启用。

# ── DG-08: 引用面组（critical-rules-discipline.md Rule 72 引用锚>=5，纪律域搬迁后改指 CRIT_D）──
DG08_CR=$(cnt "Rule 72" "$CRIT_D")
if [ "$DG08_CR" -ge 5 ]; then
    ok "DG-08" "引用面组(critical-rules.md Rule 72>=5 got=$DG08_CR)"
else
    bad "DG-08" "引用面组缺失(critical-rules.md Rule 72 got=$DG08_CR expect>=5)"
fi

# ── DG-09: 模板面组（image-type.md>=1 且 multiview-ref-type.md>=1）──
DG09_IMG=$(cnt "Rule 72" "$SKILL_ROOT/templates/variant/image-type.md")
DG09_MV=$(cnt "Rule 72" "$SKILL_ROOT/templates/variant/multiview-ref-type.md")
if [ "$DG09_IMG" -ge 1 ] && [ "$DG09_MV" -ge 1 ]; then
    ok "DG-09" "模板面组(image-type=$DG09_IMG multiview=$DG09_MV)"
else
    bad "DG-09" "模板面组缺失(image-type=$DG09_IMG multiview=$DG09_MV expect both>=1)"
fi

# ── DG-10: 管线面组（article-batch-publisher.md>=2 且 article-field-fixer.md>=1）──
DG10_PUB=$(cnt "Rule 72" "$SKILL_ROOT/companion/agents/article-batch-publisher.md")
DG10_FIX=$(cnt "Rule 72" "$SKILL_ROOT/companion/agents/article-field-fixer.md")
if [ "$DG10_PUB" -ge 2 ] && [ "$DG10_FIX" -ge 1 ]; then
    ok "DG-10" "管线面组(batch-publisher=$DG10_PUB field-fixer=$DG10_FIX)"
else
    bad "DG-10" "管线面组缺失(batch-publisher=$DG10_PUB expect>=2, field-fixer=$DG10_FIX expect>=1)"
fi

# ── DG-11 [task-v171 核心瘦身]: SKILL 接线组（终验段 Rule 72>=1 + 路由表 discipline 行 + CRIT_D 72 段 A 级/C 级）──
# What: 与 DG-04 同口径重定向后的触点分组再组织（SKILL 接线面单列一组）：SKILL.md `Rule 72`>=1（终验交付段唯一接线点），
#       路由内容锚=卫星路由表 discipline 行，分级语义锚=CRIT_D Rule 72 段（A 级必须询问/C 级禁止询问原文）。
# Why: 同 DG-04——Rule 72 迁纪律域后 SKILL 侧合规清单行随瘦身移除，>=5 五处接线合并为「终验段+路由表」两载体；
#      分组锚定位「接线面」被裁剪的能力保持（终验段 Rule 72 或路由表 discipline 行任一丢失即 FAIL）。
DG11_R72=$(cnt "Rule 72" "$SKILL")
DG11_ROWCNT=$(cnt '| task-discipline |' "$SKILL")
DG11_ROWLINE="$(sed -n '/^### 72 /,$p' "$CRIT_D" 2>/dev/null || true)"
DG11_A=$(printf '%s' "$DG11_ROWLINE" | grep -c "A 级")
DG11_C=$(printf '%s' "$DG11_ROWLINE" | grep -c "C 级")
if [ "$DG11_R72" -ge 1 ] && [ "$DG11_ROWCNT" -ge 1 ] && [ "$DG11_A" -ge 1 ] && [ "$DG11_C" -ge 1 ]; then
    ok "DG-11" "SKILL 接线组(终验段 Rule 72>=1 路由表 discipline 行>=1 CRIT_D 72 段含 A 级/C 级)"
else
    bad "DG-11" "SKILL 接线组缺失(R72=$DG11_R72 ROW=$DG11_ROWCNT A=$DG11_A C=$DG11_C expect R72>=1,ROW>=1,A>=1,C>=1)"
fi

# ── DG-12: 占位跳过（诚实 WARN 档，不计 PASS）──
# What: 行为面决策分级 fixture 回归（DG-13 原语义=对 LLM 决策分级实际行为跑 fixture 集并核对分级结果）；
#       判定面=LLM 实际决策行为，无脚本/文本载体可静态断言（53.2 零载体判例），真实校验只能执行期（fixture 设施就位后）启用。
# Why: 2026-10-16 修虚假覆盖——原断言「用 $0 对自身 grep TODO(DG-13) 注释行在位即 PASS」为自指恒真，
#      对行为面回归零校验却计入 PASS 总数，回归门对该面给出错误绿灯。改为诚实 WARN 档：
#      被检面未启用时明确标注跳过+原因+启用条件，PASS/WARN/FAIL 档位语义与 Total 格式不变（exit 仍只看 FAIL）；
#      warn 行本身即占位可见性锚点（Total 行 WARN=1 自证，预留不再静默，Rule 53.2 零载体判例延伸语义保持）。
#      执行期 fixture 回归启用后，将 TODO(DG-13) 升级为真实断言并翻 ok 档（届时 PASS 回到 12）。
# TODO(DG-13): 行为面决策分级 fixture 回归（执行期启用；当前为 WARN 跳过档）
warn "DG-12" "占位跳过：行为面决策分级无静态可校验面（TODO DG-13，执行期启用），不计 PASS"

echo "Total: PASS=$PASS FAIL=$FAIL WARN=$WARN"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
