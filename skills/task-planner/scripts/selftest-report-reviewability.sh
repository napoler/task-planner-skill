#!/usr/bin/env bash
# selftest-report-reviewability.sh — task-v155: Rule 70「用户呈报可审批性」静态守护（70.6 机制面）
#
# What（守护对象 + 运行方式）:
#   静态断言 task-v155 全链落点在位（对齐 selftest-research-first.sh 范式），
#   共 13 条编号断言 RRV-01..RRV-13：
#     · references/critical-rules.md（Rule 70 条款本体，RRV-01..RRV-03）:
#         RRV-01 `^## Rule 70（` 标题=1；`^### 70\.[1-6]` 六子条≥6
#         RRV-02 四要素词（待审项清单/可定位地址/看点/动作）各≥1
#         RRV-03 Rule 70 段内 `:\s?[0-9]+` 行号引用形态=0（防级联漂移，v148 判例）
#     · SKILL.md（消费侧联动，RRV-04）:
#         RRV-04 `Rule 70` ≥4 且 合规行内容锚「用户呈报可审批性」≥1（该行含「待审项清单」与「可定位地址」字样）
#                —— 合规行内容锚（用户呈报可审批性），未来编号让位不再级联（2026-10-10 task-v155 合并并集 cardinality 教训）
#     · 13 触点文件清单（RRV-05）:
#         RRV-05 逐一 grep "Rule 70" ≥1，任一缺失=FAIL
#     · registry + config（RRV-06，常驻 FAIL 档）:
#         RRV-06 registry 登记行≥1（登记行与 lint 段已落位（S14/S15），2026-10-10 翻硬档）；
#               config 零新键=0（恒 FAIL 档）
#     · check-complete.sh（RRV-07，常驻 FAIL 档）:
#         RRV-07 report-lint 段≥1（登记行与 lint 段已落位（S14/S15），2026-10-10 翻硬档）
#     · RRV-08..RRV-12: 已落位真实断言（模板/管线/审查工具/主链/SKILL 触点面组）；
#       RRV-13: 占位跳过 WARN 档（不计 PASS）——部署位对账依赖 smart-merge-back.sh --deploy
#       （部署位同步待授权，TODO(RRVV-14)），2026-10-16 修虚假覆盖
#   运行方式：`bash scripts/selftest-report-reviewability.sh`（只读 grep，零写入）；
#   逐行打印 `RRV-NN PASS/FAIL/WARN: <说明>`，末行 `Total: PASS=N FAIL=N WARN=N`；
#   FAIL>0 → exit 1，否则 exit 0。
#   被检文件路径全部相对 SKILL_ROOT 解析，保证仓库/worktree/部署位三处均可直接跑。
#
# Why（Rule 70.6 机制锚，task-v155 2026-10-10）:
#   用户核心诉求=「以及类似其他的东西全部需要补全，不要让用户审查一个莫名其妙的东西」。
#   Rule 70 为纯行为面条款（判定面=LLM 行为），无脚本即死文（53.2 零载体判例）：
#   本脚本锁「条款六子条文本 + 四要素词 + 行号锚禁令 + SKILL 接线 + 13 触点 + registry/config/lint 段」
#   六面配对——任一面被后续裁剪误删即 FAIL 报警（防复发，Rule 31.5 消费侧）。
#   产出背景：本脚本由主进程按 25.3 白名单⑤（22.3 兜底接管，单文件 ≤300 行）编写。

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── 路径定义（相对技能根）──
CR="$SKILL_ROOT/references/critical-rules.md"
# [task-v171 纪律域搬迁 2026-10-12] Rule 70（用户呈报可审批性纪律）属纪律域，原文已迁至
#   skills/task-discipline/references/critical-rules-discipline.md（核心 critical-rules.md 只剩 11 条核心规则）；
#   RRV-01/02/03 断言改指 CRIT_D。卫星文件标题为统一「### 70 标题」格式（核心旧格式 `## Rule 70（`），
#   RRV-01 标题行锚与 RRV-03 段首 sed 锚同步适配（子条 `### 70.N` 与段尾 `### 71` 锚形态不变），
#   断言语义（标题唯一+六子条+四要素+段内零行号引用）零改动。CR 保留指向核心。
CRIT_D="$SKILL_ROOT/../task-discipline/references/critical-rules-discipline.md"
SKILL="$SKILL_ROOT/SKILL.md"
REGISTRY="$SCRIPT_DIR/selftest-registry.tsv"
CONFIG="$SKILL_ROOT/config.json"
CHECKCOMPLETE="$SCRIPT_DIR/check-complete.sh"

# ── 13 触点文件清单（相对技能根；[task-v171 纪律域搬迁 2026-10-12] batch-quality-gate.md 迁至
#    ../task-discipline/references，即 skills/task-discipline 与 task-planner 平级）──
TOUCH_FILES=(
  "SKILL.md"
  "reference.md"
  "references/worktree-isolation.md"
  "../task-discipline/references/batch-quality-gate.md"
  "templates/task_plan.md"
  "templates/batch_report.md"
  "templates/variant/image-type.md"
  "templates/variant/multiview-ref-type.md"
  "review-library/general-review/SKILL.md"
  "review-library/alignment-review/SKILL.md"
  "review-library/code-quality-review/SKILL.md"
  "companion/agents/article-batch-publisher.md"
  "companion/agents/article-field-fixer.md"
)

# ── 计数器与输出 helper ──
PASS=0; FAIL=0; WARN=0
ok()   { echo "$1 PASS: $2"; PASS=$((PASS+1)); }
bad()  { echo "$1 FAIL: $2"; FAIL=$((FAIL+1)); }
warn() { echo "$1 WARN: $2"; WARN=$((WARN+1)); }

# ── 通用计数 helper ──
cnt()  { [ -f "$2" ] || { echo 0; return; }; grep -c -e "$1" "$2" 2>/dev/null || true; }
cntf() { [ -f "$2" ] || { echo 0; return; }; grep -cF -- "$1" "$2" 2>/dev/null || true; }

# ── RRV-01: Rule 70 条款锚（标题=1 六子条≥6）──
RRV01_TITLE=$(cnt '^### 70 ' "$CRIT_D")
RRV01_SUBS=$(cnt '^### 70\.[1-6]' "$CRIT_D")
if [ "$RRV01_TITLE" -eq 1 ] && [ "$RRV01_SUBS" -ge 6 ]; then
    ok "RRV-01" "Rule 70 条款锚(标题=1 子条≥6)"
else
    bad "RRV-01" "Rule 70 条款锚(got title=$RRV01_TITLE subs=$RRV01_SUBS expect==1,>=6)"
fi

# ── RRV-02: 四要素词齐备（待审项清单/可定位地址/看点/动作）──
RRV02_WORDS=("待审项清单" "可定位地址" "看点" "动作")
RRV02_MISSING=0
for w in "${RRV02_WORDS[@]}"; do
    if [ "$(cnt "$w" "$CRIT_D")" -lt 1 ]; then
        RRV02_MISSING=$((RRV02_MISSING+1))
    fi
done
if [ "$RRV02_MISSING" -eq 0 ]; then
    ok "RRV-02" "四要素词齐备(待审项清单/可定位地址/看点/动作)"
else
    bad "RRV-02" "四要素词缺失=$RRV02_MISSING/4"
fi

# ── RRV-03: Rule 70 段无行号引用形态（防级联漂移，v148 判例）──
BLOCK70="$(sed -n '/^### 70 /,/^### 71 无源不写/p' "$CRIT_D" 2>/dev/null || true)"  # 2026-10-10 task-v158 合并收窄：排除其后 Rule 71 段（71 段内 file:line 锚不属本断言范围）
RRV03_HITS=$(printf '%s' "$BLOCK70" | grep -cE ':\s?[0-9]+' 2>/dev/null || true)
if [ "$RRV03_HITS" -eq 0 ]; then
    ok "RRV-03" "Rule 70 段无行号引用形态"
else
    bad "RRV-03" "Rule 70 段行号引用形态命中=$RRV03_HITS"
fi

# ── RRV-04 [task-v171 核心瘦身]: SKILL 接线锚（Rule 70≥1 + 计划确认行内容锚含「待审项清单」+ CRIT_D 70 段四要素）──
# What: Rule 70 合规行（'用户呈报可审批性' C 行）随瘦身退役——C 行体系整体退役，合规清单表→G1-G8 核心域表；
#       SKILL 侧现存认领点=「计划确认」行（附计划文件绝对路径+待审项清单+看点+动作（Rule 70 四要素））
#       与「终验交付」行（呈报四要素（Rule 70）），'Rule 70' 计数 4→2。
# Why: Rule 70 属纪律域（迁 CRIT_D）；四要素条款本体在 CRIT_D（RRV-02 已锁四要素词），SKILL 侧保留接线点+内容锚。
#       内容锚（非编号）纪律保持：改钉「计划确认」行的 '待审项清单' 字样 + CRIT_D 70 段 '可定位地址' 字样，编号让位不再级联。
RRV04_RULE70=$(cnt "Rule 70" "$SKILL")
RRV04_LIST=$(grep -F '待审项清单' "$SKILL" 2>/dev/null | grep -cF 'Rule 70' 2>/dev/null || true)
RRV04_ADDR=$(sed -n '/^### 70 /,/^### 71 /p' "$CRIT_D" 2>/dev/null | grep -c "可定位地址" 2>/dev/null || true)
if [ "$RRV04_RULE70" -ge 1 ] && [ "$RRV04_LIST" -ge 1 ] && [ "$RRV04_ADDR" -ge 1 ]; then
    ok "RRV-04" "SKILL 接线锚(Rule 70≥1 计划确认行内容锚含待审项清单 ∧ CRIT_D 70 段含可定位地址)"
else
    bad "RRV-04" "SKILL 接线锚(got Rule70=$RRV04_RULE70 list=$RRV04_LIST addr=$RRV04_ADDR)"
fi

# ── RRV-05 13 触点文件 Rule 70 锚齐备 ──
RRV05_MISSING=0
for f in "${TOUCH_FILES[@]}"; do
    if [ ! -f "$SKILL_ROOT/$f" ] || [ "$(cnt "Rule 70" "$SKILL_ROOT/$f")" -lt 1 ]; then
        RRV05_MISSING=$((RRV05_MISSING+1))
    fi
done
if [ "$RRV05_MISSING" -eq 0 ]; then
    ok "RRV-05" "13 触点文件 Rule 70 锚齐备"
else
    bad "RRV-05" "触点文件缺失=$RRV05_MISSING"
fi

# ── RRV-06: registry 登记 + config 零新键（常驻 FAIL 档）──
# registry 子项=常驻 FAIL 档：登记行与 lint 段已落位（S14/S15），2026-10-10 翻硬档，缺失即 FAIL
# config 零新键恒 FAIL 档（违反零新键=FAIL）
RRV06_REGISTRY=$(cnt "selftest-report-reviewability" "$REGISTRY")
RRV06_CONFIG=$(grep -c -e 'report_lint' -e 'reviewability_enforce' "$CONFIG" 2>/dev/null || true)
if [ "$RRV06_CONFIG" -gt 0 ]; then
    bad "RRV-06" "config 新键命中=$RRV06_CONFIG(恒 FAIL 档)"
elif [ "$RRV06_REGISTRY" -lt 1 ]; then
    bad "RRV-06" "registry 登记行缺失(常驻 FAIL 档)"
else
    ok "RRV-06" "registry 登记+config 零新键"
fi

# ── RRV-07: check-complete report-lint 段（常驻 FAIL 档）──
# 登记行与 lint 段已落位（S14/S15），2026-10-10 翻硬档，缺失即 FAIL
# [2026-10-10 task-v155 修正] 原 `grep -c 'report-lint'` 命中 6 次（含 5 次注释行），
# 若删除 run_report_lint 可执行体仅留注释头，断言仍 PASS（守卫可腐化）。
# 修法：双锚精确化——锚可执行代码行（函数定义 + printf 输出行），排除注释行计入。
RRV07_FUNC=$(cnt 'run_report_lint()' "$CHECKCOMPLETE")
RRV07_PRINTF=$(cnt "printf '\[report-lint\]" "$CHECKCOMPLETE")
if [ "$RRV07_FUNC" -ge 1 ] && [ "$RRV07_PRINTF" -ge 1 ]; then
    ok "RRV-07" "check-complete report-lint 段在位(双锚: func=$RRV07_FUNC printf=$RRV07_PRINTF)"
else
    bad "RRV-07" "check-complete report-lint 段缺失(双锚: func=$RRV07_FUNC printf=$RRV07_PRINTF)"
fi

# ── RRV-08: 模板面组（FAIL 档）──
# templates/{task_plan.md×>=3, batch_report.md×>=1, variant/image-type.md×>=1, variant/multiview-ref-type.md×>=1}
RRV08_TP=$(cnt "Rule 70" "$SKILL_ROOT/templates/task_plan.md")
RRV08_BR=$(cnt "Rule 70" "$SKILL_ROOT/templates/batch_report.md")
RRV08_IT=$(cnt "Rule 70" "$SKILL_ROOT/templates/variant/image-type.md")
RRV08_MV=$(cnt "Rule 70" "$SKILL_ROOT/templates/variant/multiview-ref-type.md")
if [ "$RRV08_TP" -ge 3 ] && [ "$RRV08_BR" -ge 1 ] && [ "$RRV08_IT" -ge 1 ] && [ "$RRV08_MV" -ge 1 ]; then
    ok "RRV-08" "模板面组(task_plan>=3 batch_report>=1 image-type>=1 multiview>=1)"
else
    bad "RRV-08" "模板面组(got tp=$RRV08_TP br=$RRV08_BR it=$RRV08_IT mv=$RRV08_MV expect tp>=3 br>=1 it>=1 mv>=1)"
fi

# ── RRV-09: 管线面组（FAIL 档）──
# companion/agents/{article-batch-publisher.md×>=2, article-field-fixer.md×>=1, plan-writer.md×>=1}
RRV09_ABP=$(cnt "Rule 70" "$SKILL_ROOT/companion/agents/article-batch-publisher.md")
RRV09_AFF=$(cnt "Rule 70" "$SKILL_ROOT/companion/agents/article-field-fixer.md")
RRV09_PW=$(cnt "Rule 70" "$SKILL_ROOT/companion/agents/plan-writer.md")
if [ "$RRV09_ABP" -ge 2 ] && [ "$RRV09_AFF" -ge 1 ] && [ "$RRV09_PW" -ge 1 ]; then
    ok "RRV-09" "管线面组(batch-publisher>=2 field-fixer>=1 plan-writer>=1)"
else
    bad "RRV-09" "管线面组(got abp=$RRV09_ABP aff=$RRV09_AFF pw=$RRV09_PW expect abp>=2 aff>=1 pw>=1)"
fi

# ── RRV-10: 审查工具面组（FAIL 档）──
# review-library/{general-review,alignment-review,code-quality-review}/SKILL.md 各 grep -c "审查对象总清单（Rule 70" =1
RRV10_GR=$(cnt "审查对象总清单（Rule 70" "$SKILL_ROOT/review-library/general-review/SKILL.md")
RRV10_AR=$(cnt "审查对象总清单（Rule 70" "$SKILL_ROOT/review-library/alignment-review/SKILL.md")
RRV10_CQ=$(cnt "审查对象总清单（Rule 70" "$SKILL_ROOT/review-library/code-quality-review/SKILL.md")
if [ "$RRV10_GR" -eq 1 ] && [ "$RRV10_AR" -eq 1 ] && [ "$RRV10_CQ" -eq 1 ]; then
    ok "RRV-10" "审查工具面组(general=1 alignment=1 code-quality=1)"
else
    bad "RRV-10" "审查工具面组(got gr=$RRV10_GR ar=$RRV10_AR cq=$RRV10_CQ expect all=1)"
fi

# ── RRV-11: 主链面组（FAIL 档）──
# reference.md >=1、references/worktree-isolation.md >=4
RRV11_REF=$(cnt "Rule 70" "$SKILL_ROOT/reference.md")
RRV11_WT=$(cnt "Rule 70" "$SKILL_ROOT/references/worktree-isolation.md")
if [ "$RRV11_REF" -ge 1 ] && [ "$RRV11_WT" -ge 4 ]; then
    ok "RRV-11" "主链面组(reference>=1 worktree-isolation>=4)"
else
    bad "RRV-11" "主链面组(got ref=$RRV11_REF wt=$RRV11_WT expect ref>=1 wt>=4)"
fi

# ── RRV-12 [task-v171 核心瘦身]: SKILL 触点组（'Rule 70' 计数≥1 + 终验交付段「呈报四要素」句=1）──
# SKILL.md 瘦身后旧触点（呈报规格（Rule 70）×4 / 会话内一切其他呈报 终验句）随 556→214 行重写移除；
# 现存触点='Rule 70'×2（计划确认四要素行+终验交付指针行）+ 终验交付段「呈报四要素（Rule 70）按卫星 task-discipline 全文执行」句。
# 触点组守护语义保持（SKILL 侧呈报面接线在位），锚随现措辞演进。
RRV12_SPEC=$(cnt "Rule 70" "$SKILL")
RRV12_FINAL=$(cnt "呈报四要素" "$SKILL")
if [ "$RRV12_SPEC" -ge 1 ] && [ "$RRV12_FINAL" -eq 1 ]; then
    ok "RRV-12" "SKILL 触点组(Rule 70≥1 呈报四要素终验句=1)"
else
    bad "RRV-12" "SKILL 触点组(got spec=$RRV12_SPEC final=$RRV12_FINAL expect spec>=1 final=1)"
fi

# ── RRV-13: 占位跳过（诚实 WARN 档，不计 PASS）──
# What: 部署位对账断言（RRVV-14 原语义=对账仓库与部署位文件差异）的真实校验依赖部署位已同步——smart-merge-back.sh --deploy
#       逐位 [DEPLOY] 对账（L1 文件集合差/L2 内容定向 diff，基准=主仓 skills/task-planner，smart-merge-back.sh:52/545）；
#       部署位同步当前待用户授权（task-v178/v179 遗留），前置条件未成立，静态无可校验面。
# Why: 2026-10-16 修虚假覆盖——原断言「grep 自身文件 TODO(RRVV-14) 注释行在位即 PASS」为自指恒真，
#      对部署位对账零校验却计入 PASS 总数，回归门对该面给出错误绿灯。改为诚实 WARN 档：
#      被检面未启用时明确标注跳过+原因+启用条件，PASS/WARN/FAIL 档位语义与 Total 格式不变（exit 仍只看 FAIL）。
#      部署位同步授权并完成 --deploy 后，将 TODO(RRVV-14) 升级为真实对账断言并翻 ok 档（届时 PASS 回到 13）。
# TODO(RRVV-14): 部署位对账断言（合并回后启用；当前为 WARN 跳过档）
warn "RRV-13" "占位跳过：部署位对账未启用（部署位同步待授权，TODO RRVV-14），不计 PASS"

echo "Total: PASS=$PASS FAIL=$FAIL WARN=$WARN"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
