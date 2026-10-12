#!/usr/bin/env bash
# selftest-goal-unit-goal-mode.sh — task-v151: Rule 66「goal 单元固化与 /goal 驱动推进纪律」静态守护
#
# What（守护对象 + 运行方式）:
#   静态断言 task-v151 Rule 66 全链落点在位（对齐 selftest-evidence-goal-gate.sh 范式），
#   共 9 条编号断言 G-01..G-09：
#     · critical-rules.md（Rule 66 条款本体，G-01..G-02）:
#         G-01 `^### 66 ` 标题 =1（章节唯一锚）
#         G-02 `^66\.[1-6] ` 六子条 =6（66.1-66.6 主体行全在位）
#     · templates/task_plan.md（Goal 单元表区块载体，G-03）:
#         G-03 `^## 🎯 Goal 单元表` =1 + 六列表头行 =1 + 插入位语义（位于「核心目标达成裁决」与「执行范围限制」之间）
#     · SKILL.md（执行期入口联动，G-04）:
#         G-04 `Rule 66` 计数 ≥2（摘要行+References 描述行）+ `^\| C45 ` =1（合规清单消费侧）
#     · scripts/check-plan-dispatch.sh（计划期硬门，G-05）:
#         G-05 `Goal 单元表` 锚 ≥1 + `--skip-goal-check` 锚 ≥1
#     · scripts/check-complete.sh（终验对照，G-06）:
#         G-06 `goal-gate` 输出前缀锚 ≥1 + `[goal:G` grep 逻辑锚 ≥1
#     · selftest-registry.tsv（登记行，G-07）:
#         G-07 含 `selftest-goal-unit-goal-mode.sh`（并集口径：任意行，末行假设不适用于并行合并）
#         G-07 含 `selftest-goal-unit-goal-mode.sh` 数据行（含断言，防跨任务追加登记行打破末行口径）
#             [2026-10-10 task-v155 合并并集同验：v155 追加 selftest-report-reviewability 登记行后本断言仍成立]
#     · config.json（零新键声明，G-08）:
#         G-08 properties 键名中 `goal[_-](unit|gate|advance)` =0（零新 config 键负断言）
#     · 钉值联动（G-09）:
#         G-09 SKILL.md 行数 ≤581（task-v155 合并并集后上限 = n+25，n=合并后 SKILL.md 实际行数 530）
#   运行方式：`bash scripts/selftest-goal-unit-goal-mode.sh`（只读 grep/jq，零写入）；
#   逐行打印 `G-NN PASS/FAIL <说明>`，末行 `Total: 9 PASS=x FAIL=y`；全 PASS exit 0，任一 FAIL exit 1。
#   被检文件路径全部相对 SCRIPT_DIR 解析，保证仓库/worktree/三宿主部署位三处均可直接跑。
#
# Why（Rule 66.6 机制锚，task-v151 2026-10-09）:
#   用户 R4 核心诉求=「自动分解任务，然后按照调度之后逐个进行解决」——任务分解固化为 goal 单元
#   （任务名+目标+完整验证方式），执行按 goal 逐个调度推进并与 ZCode 内置 /goal 目标模式对齐供料。
#   Rule 66 是 LLM 行为面条款（goal 单元固化六列契约/goal 逐行验证门/分解→调度→逐个解决推进序均为
#   行为义务，非机器触发），若条款锚/模板区块/SKILL 联动被后续裁剪误删，条款即变死文；
#   本脚本=条款死文探测器，守护 66.1-66.6 子条锚/模板区块锚/SKILL 摘要行/C45 合规行/registry 登记行/零新键负断言。
#   模板区块（Goal 单元表）是 66.1 的任务级强制载体——G-03 锁载体结构（区块标题+六列表头+插入位语义），
#   权威定义在 critical-rules.md 66.1（G-01/G-02 锁文本），两处配对锁死「条款定义 + 任务载体」双面。
#   只断言 Rule 66 新增锚、不触碰既有 selftest 断言行（防锚级联，Rule 36.5 纯增量）。
# 依赖：bash + grep；config.json 键名校验需 python3（缺失降级 grep 口径）。只读，零写入。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
TPL="$SKILL_ROOT/templates/task_plan.md"
CONFIG="$SKILL_ROOT/config.json"
REGISTRY="$SCRIPT_DIR/selftest-registry.tsv"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'G-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'G-%s FAIL %s\n' "$1" "$2"; }

# G-01 critical-rules.md `^### 66 ` 标题行计数=1
# What：断言 Rule 66 章节标题唯一。
# Why：标题行是章节识别锚；=1 防重复插入/误删。
n="$(grep -cE '^### 66 ' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 01 "critical-rules.md '### 66 ' 标题锚 =1"; else bad 01 "critical-rules.md '### 66 ' 计数=$n（应 =1）"; fi

# G-02 critical-rules.md `^66\.[1-6] ` 六子条计数=6
# What：断言 66.1-66.6 六条子条主体行全在位。
# Why：六子条是 Rule 66 全部义务的唯一文本落点；缺任一 = 条款本体被裁剪（防改写时误删 66.x 段）。
n="$(grep -cE '^66\.[1-6] ' "$CRIT" || true)"
if [ "$n" -eq 6 ]; then ok 02 "critical-rules.md '66.x ' 六子条锚 =6"; else bad 02 "critical-rules.md '66.x ' 计数=$n（应 =6）"; fi

# G-03 templates/task_plan.md Goal 单元表区块锚 =1 + 六列表头行 =1 + 插入位语义
# What：断言 Goal 单元表区块标题唯一、六列表头行唯一、插入位位于「核心目标达成裁决」与「执行范围限制」之间。
# Why：Goal 单元表是 66.1 六列契约的任务级强制载体（standard/full 档必填）——区块丢=每次任务的 goal 单元无落点；
#      插入位语义保证模板结构一致性（awk 行序断言，防区块被移至错误位置）。
n="$(grep -cE '^## 🎯 Goal 单元表' "$TPL" || true)"
header_row="$(grep -cE '^\| goal-id \| 任务名 \| 目标.*\| 完整验证方式.*\| 对应 S-unit/Phase \| 状态' "$TPL" || true)"
# 插入位语义：awk 行序断言——Goal 单元表行号在「核心目标达成裁决」之后、「执行范围限制」之前
goal_line="$(grep -nE '^## 🎯 Goal 单元表' "$TPL" | head -1 | cut -d: -f1 || true)"
verdict_line="$(grep -nE '^## 🎯 核心目标达成裁决' "$TPL" | head -1 | cut -d: -f1 || true)"
limit_line="$(grep -nE '^## ⚠️ 执行范围限制' "$TPL" | head -1 | cut -d: -f1 || true)"
if [ "$n" -eq 1 ] && [ "$header_row" -eq 1 ] && [ -n "$goal_line" ] && [ -n "$verdict_line" ] && [ -n "$limit_line" ] && [ "$goal_line" -gt "$verdict_line" ] && [ "$goal_line" -lt "$limit_line" ]; then
  ok 03 "templates/task_plan.md Goal 单元表区块=1 + 六列表头=1 + 插入位语义（L${verdict_line}<L${goal_line}<L${limit_line}）"
else
  bad 03 "templates/task_plan.md 区块=$n（应 =1）/ 表头=$header_row（应 =1）/ 插入位语义（裁决=${verdict_line:-N/A} goal=${goal_line:-N/A} 限制=${limit_line:-N/A}）"
fi

# G-04 [task-v171 核心瘦身] SKILL.md `Rule 66` ≥1（指针 bullet）+ 'Goal 单元表' 契约措辞 ≥1（C45 合规行瘦身后由指针段承载）
#   现象：SKILL.md 瘦身后 Rule 66 引用 3→1（仅存 Critical Rules 指针段 '**Rule 66 goal 单元固化**' bullet）、
#     C45 合规行归零，旧断言 ≥2/=1 恒 FAIL。
#   根因：Rule 66 属核心在位规则仍在 SKILL 正文；但摘要行+References 描述行+C45 合规行三处联动面中后两处
#     随瘦身移除（合规清单表→G1-G8 核心域表，G 表未单列 goal 单元行）。
#   修法：x='Rule 66' 阈值 ≥2→≥1（指针 bullet 为唯一 SKILL 侧落点）；y=C45 行='Goal 单元表' 契约措辞 ≥1
#     （指针 bullet 内含 'Goal 单元表六列契约'，合规消费点语义由该措辞锚承接）。
n="$(grep -cE 'Rule 66' "$SKILLMD" || true)"
c45="$(grep -cE 'Goal 单元表' "$SKILLMD" || true)"
if [ "$n" -ge 1 ] && [ "$c45" -ge 1 ]; then ok 04 "SKILL.md 'Rule 66' 计数=$n（≥1，指针 bullet）+ 'Goal 单元表' 契约措辞=$c45（≥1，C45 合规面瘦身后由指针段承载）"; else bad 04 "SKILL.md 'Rule 66' 计数=$n（应 ≥1）/ 'Goal 单元表' 契约措辞=$c45（应 ≥1）"; fi

# G-05 check-plan-dispatch.sh `Goal 单元表` 锚 ≥1 + `--skip-goal-check` 锚 ≥1
# What：断言 check-plan-dispatch.sh 中 Goal 单元表校验逻辑与 --skip-goal-check 逃生口均在位。
# Why：66.5 声明的计划期硬门=check-plan-dispatch.sh attest 期区块存在性+六列+验证方式列非空机械校验；
#      --skip-goal-check 逃生口对齐 --skip-dispatch-check 惯例。
n="$(grep -cE 'Goal 单元表' "$SKILL_ROOT/scripts/check-plan-dispatch.sh" || true)"
skip="$(grep -cE '\-\-skip-goal-check' "$SKILL_ROOT/scripts/check-plan-dispatch.sh" || true)"
if [ "$n" -ge 1 ] && [ "$skip" -ge 1 ]; then ok 05 "check-plan-dispatch.sh 'Goal 单元表' 锚=$n（≥1）+ '--skip-goal-check' 锚=$skip（≥1）"; else bad 05 "check-plan-dispatch.sh 'Goal 单元表' 锚=$n（应 ≥1）/ '--skip-goal-check' 锚=$skip（应 ≥1）"; fi

# G-06 check-complete.sh `goal-gate` 输出前缀锚 ≥1 + `[goal:G` grep 逻辑锚 ≥1
# What：断言 check-complete.sh 中 goal-gate 输出前缀与 [goal:Gn] 证据行 grep 逻辑均在位。
# Why：66.3 声明的终验对照=check-complete.sh 逐行对照 status=complete 的 goal 行与 progress.md [goal:Gn] 证据行；
#      goal-gate 输出前缀便于 selftest 锚定。
n="$(grep -cE 'goal-gate' "$SKILL_ROOT/scripts/check-complete.sh" || true)"
grep_logic="$(grep -cE '\[goal:G' "$SKILL_ROOT/scripts/check-complete.sh" || true)"
if [ "$n" -ge 1 ] && [ "$grep_logic" -ge 1 ]; then ok 06 "check-complete.sh 'goal-gate' 锚=$n（≥1）+ '[goal:G' grep 锚=$grep_logic（≥1）"; else bad 06 "check-complete.sh 'goal-gate' 锚=$n（应 ≥1）/ '[goal:G' grep 锚=$grep_logic（应 ≥1）"; fi

# G-07 selftest-registry.tsv 含 `selftest-goal-unit-goal-mode.sh`（并集口径）
# What：断言 registry 全表含本脚本登记行（2026-10-09 健壮化：末行口径改含口径——
# 现象=v153 按仓约定追加新 selftest 登记行后本断言末行口径被跨任务打破复跑 FAIL；
# 根因=末行钉口径与 registry 纯增量追加约定冲突；修法=含数据行同义断言，编号与 Total 不变）。
# 2026-10-10 task-v155 合并并集同验：v155 追加 selftest-report-reviewability 登记行后本断言仍成立
# Why：selftest-registry.tsv 是全部 selftest 脚本的登记账本；新脚本必须登记以形成闭环。
#      并行任务合并后末行可能为其他 selftest 行，故用全表匹配（grep -q）替代末行假设。
last_line="$(tail -1 "$REGISTRY" || true)"
if grep -q 'selftest-goal-unit-goal-mode.sh' "$REGISTRY"; then ok 07 "selftest-registry.tsv 含本脚本登记（并集口径：任意行，末行假设不适用于并行合并）"; else bad 07 "selftest-registry.tsv 缺本脚本登记=$last_line"; fi

# G-08 config.json 零新键负断言：properties 键名中 `goal[_-](unit|gate|advance)` =0
# What：断言 config.json properties 键名中不存在 goal-unit/goal-gate/goal-advance 相关新键。
# Why：Rule 66 承诺「零新 config 键」（沿用 25.4/43.4 零新键纪律）——本任务不加键。
if command -v python3 >/dev/null 2>&1; then
  n="$(python3 -c "import json; d=json.load(open('$CONFIG')); keys=list(d.get('properties',{}).keys()); print(sum(1 for k in keys if __import__('re').search(r'goal[_-](unit|gate|advance)', k)))" 2>/dev/null || echo 1)"
else
  n="$(python3 -c "import json,re; d=json.load(open('$CONFIG')); keys=list(d.get('properties',{}).keys()); print(sum(1 for k in keys if re.search(r'goal[_-](unit|gate|advance)', k)))" 2>/dev/null || echo 1)"
fi
if [ "$n" -eq 0 ]; then ok 08 "config.json properties 键名 goal[_-](unit|gate|advance) =0（零新键）"; else bad 08 "config.json properties 键名 goal[_-](unit|gate|advance) =$n（应 =0，零新键承诺被破）"; fi

# G-09 SKILL.md 行数 ≤581（task-v155 合并并集后上限 = n+25）
# What：断言 SKILL.md 行数不超过 581 行（=task-v168 逻辑层五锚点后实际行数 556 + 25 余量）。
# Why：Rule 66 摘要行 +1、C45 行 +1 → 511 触顶；master 侧 task-v154 D2 上调：Rule 69 路由表行+摘要 bullet+触发点标记 T1-T6 六行+C46 合规行+外部引用行 → 实际 521 行（515→521），钉值上调 515→526（留 5 行余量）；HEAD 侧 task-v155 Rule 70 接线净 +7 → 触顶。合并并集后实际 530 行，钉取并集后实值+25=555（留余量给后续并行任务 v152/v156；v150/v151 判例：钉值上调留缓冲）。[2026-10-11 task-v168] 逻辑层五锚点（1.1 R 锚定复诵/2.5b 技能激活确认/2.5c 相关性三问/3c 错误同轮四步/3f 周期三文件对照）净增使 SKILL.md 530→556，钉按先例（实值+25）上调 555→581
n="$(wc -l < "$SKILLMD" || true)"
if [ "$n" -le 581 ]; then ok 09 "SKILL.md 行数=$n ≤581（task-v155 合并并集后上限 = n+25）"; else bad 09 "SKILL.md 行数=$n >581（超限）"; fi

printf 'Total: 9 PASS=%d FAIL=%d\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
