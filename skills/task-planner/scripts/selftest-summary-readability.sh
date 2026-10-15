#!/usr/bin/env bash
# selftest-summary-readability.sh — task-v166: Rule 76「总结阶段格式可读性与审查清单实体化纪律」静态守护
#
# What（守护对象 + 运行方式）:
#   静态断言 task-v166 全链落点在位（对齐 selftest-report-reviewability.sh 范式），
#   共 13 条编号断言 SRV-01..SRV-13：
#     · references/critical-rules.md（Rule 76 条款本体，SRV-01..SRV-02）:
#         SRV-01 `Rule 76（总结阶段格式可读性与审查清单实体化纪律 — task-v166）` 标题=1
#         SRV-02 `^76\.[1-6] ` 六子条≥6
#     · SKILL.md（消费侧联动，SRV-03..SRV-06）:
#         SRV-03 `1-(7[4-9]|8[01])` ≥3（2026-10-12 task-v170 S10n 纪元扩围：Rule 81 落地 1-81，锚扩 8[01]，负样本 1-82 不命中）；SRV-04 `Rule 76` ≥5；SRV-05 C55 行在位且含「Rule 76」+「总结格式可读性」；SRV-06 终验段 Rule 76 联动句在位
#     · templates/delivery-summary.md（SRV-07）:
#         SRV-07 审查清单表格段表头含「文件名」「路径」「描述」
#     · SRV-08..SRV-13（消费侧联动+负断言守护）:
#         SRV-08 image-type.md 装饰圈号=0；SRV-09 multiview-ref-type.md 装饰圈号=0；
#         SRV-10 check-complete.sh run_report_lint Rule 76≥1；SRV-11 registry 登记+registry.sh PASS；
#         SRV-12 9 级联脚本各自 PASS；SRV-13 用户面白名单载体装饰圈号=0
#   运行方式：`bash scripts/selftest-summary-readability.sh`（只读 grep，零写入）；
#   逐行打印 `SRV-NN PASS/FAIL/WARN: <说明>`，末行 `Total: PASS=N FAIL=N WARN=N`；
#   FAIL>0 → exit 1，否则 exit 0。
#   被检文件路径全部相对 SKILL_ROOT 解析，保证仓库/worktree/部署位三处均可直接跑。
#
# Why（Rule 76 机制锚，task-v166 2026-10-11）:
#   用户核心诉求=「让我审查内容，为什么不把那需要审查的内容列给我？」「用了一个圈1、圈2、圈3这种方式混在一起，让人看着非常头疼」。
#   Rule 76 为格式可读性+审查清单实体化条款（判定面=LLM 行为），无脚本即死文：
#   本脚本锁「条款六子条文本 + SKILL 接线 + delivery-summary 表格段」
#   三面配对——任一面被后续裁剪误删即 FAIL 报警（防复发，Rule 31.5 消费侧）。
#   产出背景：本脚本由主进程按 25.3 白名单⑤（22.3 兜底接管，单文件 ≤300 行）编写。

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── 路径定义（相对技能根）──
CR="$SKILL_ROOT/references/critical-rules.md"
# [task-v171 纪律域搬迁 2026-10-12] Rule 76（总结阶段格式可读性与审查清单实体化纪律）属纪律域，原文已迁至
#   skills/task-discipline/references/critical-rules-discipline.md（核心 critical-rules.md 只剩 11 条核心规则）；
#   SRV-01/02 断言改指 CRIT_D。卫星文件标题为统一「### 76 标题」格式（核心旧格式 `Rule 76（…）`），
#   SRV-01 标题行锚同步适配，断言语义（标题存在+六子条）零改动。CR 保留指向核心。
CRIT_D="$SKILL_ROOT/../task-discipline/references/critical-rules-discipline.md"
SKILL="$SKILL_ROOT/SKILL.md"
DS="$SKILL_ROOT/templates/delivery-summary.md"
IMG="$SKILL_ROOT/templates/variant/image-type.md"
MVR="$SKILL_ROOT/templates/variant/multiview-ref-type.md"
CC="$SKILL_ROOT/scripts/check-complete.sh"
REG="$SKILL_ROOT/scripts/selftest-registry.tsv"
REGSH="$SKILL_ROOT/scripts/selftest-registry.sh"

# ── 计数器与输出 helper ──
PASS=0; FAIL=0; WARN=0
ok()   { echo "$1 PASS: $2"; PASS=$((PASS+1)); }
bad()  { echo "$1 FAIL: $2"; FAIL=$((FAIL+1)); }
warn() { echo "$1 WARN: $2"; WARN=$((WARN+1)); }

# ── 通用计数 helper ──
cnt()  { [ -f "$2" ] || { echo 0; return; }; grep -c -e "$1" "$2" 2>/dev/null || true; }
cntf() { [ -f "$2" ] || { echo 0; return; }; grep -cF -- "$1" "$2" 2>/dev/null || true; }
cntE() { [ -f "$2" ] || { echo 0; return; }; grep -cE -- "$1" "$2" 2>/dev/null || true; }

# ── SRV-01: Rule 76 条款标题锚 ──
SRV01_TITLE=$(cnt '### 76 总结阶段格式可读性与审查清单实体化纪律' "$CRIT_D")
if [ "$SRV01_TITLE" -ge 1 ]; then
    ok "SRV-01" "Rule 76 条款标题锚(标题≥1)"
else
    bad "SRV-01" "Rule 76 条款标题锚(got title=$SRV01_TITLE expect>=1)"
fi

# ── SRV-02: Rule 76 六子条锚（76.1-76.6 各≥1）──
SRV02_SUBS=$(cnt '^76\.[1-6] ' "$CRIT_D")
if [ "$SRV02_SUBS" -ge 6 ]; then
    ok "SRV-02" "Rule 76 六子条锚(≥6)"
else
    bad "SRV-02" "Rule 76 六子条锚(got subs=$SRV02_SUBS expect>=6)"
fi

# [2026-10-11 task-v169 纪元再扩] '1-7[4-9]'→'1-[7-8][0-9]'：Rule 80 落地 1-80 纪元，锚扩覆盖 70..89（阈值 ≥3 不变）
# ── SRV-03: SKILL 接线锚（1-(7[4-9]|8[01])≥3，容 1-74..1-79/1-80/1-81 演进，防下次 epoch 再漂移）──
# [2026-10-12 task-v170 S10n 纪元扩围] '1-7[4-9]'→'1-(7[4-9]|8[01])'：Why=task-v170 落地 Rule 81（计划完成后归档纪律）使 SKILL.md 编号纪元 1-76→1-81，接线锚同步扩 8[01]（8[01] 形态先例=selftest-research-first.sh RF-06/RF-07 交替集）；负样本 '1-82' 不命中（越界值不放开，Rule 45 注释：What=扩围 81；Why=Rule 81 落地纪元漂移）
SRV03_EPOCH=$(cntE '1-(7[4-9]|8[0-9])' "$SKILL")
if [ "$SRV03_EPOCH" -ge 3 ]; then
    ok "SRV-03" "SKILL 接线锚(1-(7[4-9]|8[0-9])≥3)"
else
    bad "SRV-03" "SKILL 接线锚(got 1-(7[4-9]|8[0-9])=$SRV03_EPOCH expect>=3)"
fi

# ── SRV-04 [task-v171 核心瘦身]: SKILL 接线锚（Rule 76≥1 终验交付指针行 + CRIT_D Rule 76 条款本体锚）──
#   现象：SKILL.md 瘦身后 'Rule 76' 计数 5→1（仅存终验交付段「编号列表规范（Rule 76）按卫星 task-discipline 全文执行」），
#     旧阈值 ≥5（摘要/合规 C55/终验句/References/全集行五处）恒 FAIL。
#   根因：Rule 76 属纪律域（迁 CRIT_D）；SKILL 侧接线点收敛为终验交付指针行+卫星路由表行。
#   修法：阈值改 ≥1 ∧ CRIT_D '^### 76 ' 标题=1（条款本体在位，接线面强度经双载体保持）。
SRV04_RULE76=$(cnt 'Rule 76' "$SKILL")
SRV04_CRIT76=$(cntE '^### 76 ' "$CRIT_D")
if [ "$SRV04_RULE76" -ge 1 ] && [ "$SRV04_CRIT76" -ge 1 ]; then
    ok "SRV-04" "SKILL 接线锚(Rule 76=$SRV04_RULE76≥1 ∧ CRIT_D 76 标题=$SRV04_CRIT76)"
else
    bad "SRV-04" "SKILL 接线锚(got Rule76=$SRV04_RULE76 CRIT_D 标题=$SRV04_CRIT76 expect 各≥1)"
fi

# ── SRV-05 [task-v171 核心瘦身]: C55 合规行退役 → 卫星路由表 task-discipline 行 + CRIT_D 76 段「编号列表」语义锚 ──
#   现象：合规清单 C55 行随清单表退役（表→G1-G8 核心域表），C55/k1/k2 三条件全失，SRV-05 恒 FAIL。
#   根因：Rule 76 属纪律域；非核心域合规项经卫星路由表行承载（Rule 82 禁回潮）。
#   修法：① 路由表 discipline 行 =1（C55 消费面载体）；② CRIT_D '^76\.[0-9]' 子条 ≥1（条款本体的「总结格式可读性」
#     语义承载，由子条文本锚承接原 k2 关键词断言）。
SRV05_C55=$(cntE '^\| task-discipline \|' "$SKILL")
SRV05_K2=$(cntE '^76\.[0-9]' "$CRIT_D")
if [ "$SRV05_C55" -ge 1 ] && [ "$SRV05_K2" -ge 1 ]; then
    ok "SRV-05" "SKILL 卫星路由表 discipline 行在位 ∧ CRIT_D 76.x 子条=$SRV05_K2（C55 合规面瘦身后由路由表+条文承载）"
else
    bad "SRV-05" "SKILL C55 合规面缺失(got 路由行=$SRV05_C55 CRIT_D 76.x=$SRV05_K2 expect all>=1)"
fi

# ── SRV-06 [task-v171 核心瘦身]: SKILL 终验段 Rule 76 联动句在位（措辞演进重锚）──
#   现象：瘦身后终验交付段旧联动句「用户面总结/呈报的列表一律编号列表」退役（细则归 CRIT_D 条文），
#     现存联动载体=终验交付段「编号列表规范（Rule 76）按卫星 task-discipline 全文执行」行。
#   修法：锚随现措辞演进为 '编号列表规范（Rule 76）'（≥1）。
SRV06_LINE=$(cnt '编号列表规范（Rule 76）' "$SKILL")
if [ "$SRV06_LINE" -ge 1 ]; then
    ok "SRV-06" "SKILL 终验段 Rule 76 联动句在位（编号列表规范措辞）"
else
    bad "SRV-06" "SKILL 终验段 Rule 76 联动句缺失(got line=$SRV06_LINE expect>=1)"
fi

# ── SRV-07: delivery-summary §3 审查清单表格段表头行三列 ──
# 锚定表头行：先定位「## 3. 审查清单」标题行，再抽取标题后首个表格首行（表头行）；
# 该形态缺失（整删 §3 表）即 FAIL——消除全文件 cnt 弱守卫（「路径」「文件名」在指引文亦存在）。
SRV07_HEADER=$(awk '/^## 3\. 审查清单/{found=1; next} found && /^\|/{print; exit}' "$DS")
SRV07_FN=$(echo "$SRV07_HEADER" | grep -c '文件名' || true)
SRV07_PATH=$(echo "$SRV07_HEADER" | grep -c '路径' || true)
SRV07_DESC=$(echo "$SRV07_HEADER" | grep -c '简单描述' || true)
if [ "$SRV07_FN" -ge 1 ] && [ "$SRV07_PATH" -ge 1 ] && [ "$SRV07_DESC" -ge 1 ]; then
    ok "SRV-07" "delivery-summary §3 审查清单表头行三列(文件名/路径/简单描述)"
else
    bad "SRV-07" "delivery-summary §3 表头行三列(got fn=$SRV07_FN path=$SRV07_PATH desc=$SRV07_DESC expect all>=1)"
fi

# ── SRV-08: image-type.md 装饰圈号负断言 ──
SRV08_DECO=$(cntE 'Phase [0-9]+: [①-⑨]' "$IMG")
if [ "$SRV08_DECO" -eq 0 ]; then
    ok "SRV-08" "image-type.md 装饰圈号=0"
else
    bad "SRV-08" "image-type.md 装饰圈号(got $SRV08_DECO expect=0)"
fi

# ── SRV-09: multiview-ref-type.md 装饰圈号负断言 ──
SRV09_DECO=$(cntE 'Phase [0-9]+: [①-⑨]' "$MVR")
if [ "$SRV09_DECO" -eq 0 ]; then
    ok "SRV-09" "multiview-ref-type.md 装饰圈号=0"
else
    bad "SRV-09" "multiview-ref-type.md 装饰圈号(got $SRV09_DECO expect=0)"
fi

# ── SRV-10: check-complete.sh run_report_lint 含 Rule 76 ──
SRV10_R76=$(cnt 'Rule 76' "$CC")
if [ "$SRV10_R76" -ge 1 ]; then
    ok "SRV-10" "check-complete.sh run_report_lint Rule 76>=1"
else
    bad "SRV-10" "check-complete.sh run_report_lint Rule 76(got $SRV10_R76 expect>=1)"
fi

# ── SRV-11: registry 登记 + registry.sh PASS ──
SRV11_REG=$(cnt 'selftest-summary-readability.sh' "$REG")
if [ "$SRV11_REG" -ge 1 ] && bash "$REGSH" >/dev/null 2>&1; then
    ok "SRV-11" "registry 登记+registry.sh PASS"
else
    bad "SRV-11" "registry 登记(got $SRV11_REG expect>=1)+registry.sh PASS"
fi

# ── SRV-12: 9 级联脚本各自自跑 PASS ──
SRV12_PASS=0; SRV12_FAIL=0
for f in "$SCRIPT_DIR"/selftest-absorption-discipline.sh \
         "$SCRIPT_DIR"/selftest-context-pressure.sh \
         "$SCRIPT_DIR"/selftest-lane-advancement.sh \
         "$SCRIPT_DIR"/selftest-tool-selection.sh \
         "$SCRIPT_DIR"/selftest-requirement-coverage.sh \
         "$SCRIPT_DIR"/selftest-research-first.sh \
         "$SCRIPT_DIR"/selftest-self-resolution.sh \
         "$SCRIPT_DIR"/selftest-source-anchor-discipline.sh \
         "$SCRIPT_DIR"/selftest-root-resolution.sh; do
    if bash "$f" >/dev/null 2>&1; then
        SRV12_PASS=$((SRV12_PASS+1))
    else
        SRV12_FAIL=$((SRV12_FAIL+1))
    fi
done
if [ "$SRV12_FAIL" -eq 0 ] && [ "$SRV12_PASS" -eq 9 ]; then
    ok "SRV-12" "9 级联脚本各自 PASS(9/9)"
else
    bad "SRV-12" "9 级联脚本(pass=$SRV12_PASS fail=$SRV12_FAIL expect 9/9)"
fi

# ── SRV-13: 负断言守护——用户面白名单载体装饰圈号=0 ──
SRV13_DECO=0
for f in "$DS" "$IMG" "$MVR" "$SKILL"; do
    n=$(cntE 'Phase [0-9]+: [①-⑨]' "$f")
    SRV13_DECO=$((SRV13_DECO + n))
done
if [ "$SRV13_DECO" -eq 0 ]; then
    ok "SRV-13" "负断言守护: 用户面白名单载体装饰圈号=0"
else
    bad "SRV-13" "负断言守护: 用户面白名单载体装饰圈号(got $SRV13_DECO expect=0)"
fi

echo "Total: PASS=$PASS FAIL=$FAIL WARN=$WARN"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
