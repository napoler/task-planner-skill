#!/usr/bin/env bash
# selftest-iteration-persistence.sh — task-v141: Rule 57「迭代测试轮次落盘纪律」静态守护（自写 57.4 机器面）
#
# What（守护对象 + 运行方式）:
#   静态断言 task-v141 全链落点在位（对齐 selftest-execution-honesty.sh / selftest-capability-persistence.sh 范式），
#   共 18 条编号断言 IP-01..IP-18：
#     · critical-rules.md（Rule 57 条款本体，IP-01..IP-08）:
#         IP-01 `^### 57 ` 标题=1；IP-02 `^57\.[1-4] ` 四子条=4；IP-03 块首说明含 task-v141（来源任务锚）
#         IP-04..IP-07 四子条标题字面锚各 =1（57.1 每轮结果必落盘 / 57.2 落盘四要素 / 57.3 即时落盘防上下文分散 / 57.4 机制零新 config 键）
#         IP-08 落盘四要素锚（轮次编号 / 测试命令 / PASS/FAIL / 关键输出摘要）各 ≥1（57.2 schema 语义内核，防「标题在但正文被裁」死文变体）
#     · SKILL.md（执行循环 + 合规清单 + 索引联动，IP-09..IP-12）:
#         IP-09 执行循环 3e 锚「迭代落盘检查点（Rule 57」=1（57.4 声明的消费侧，防条款死文 53.2 反例）
#         IP-10 `Rule 57` ≥3（3e 行 / C40 行 / References 摘要行三落点联动）
#         IP-11 `^\| C40 ` 合规行 =1（57.4 声明的合规清单消费侧）
#         IP-12 全集声明宽容锚 `Rule 40-[5-8][0-9]` ≥1（纪元演进防钉死，task-v136 EH-09 先例）
#     · templates/progress.md（落盘载体，IP-13）:
#         IP-13 文件在位且含「Test Results」段（迭代轮次结果的落盘载体出口）；
#               四要素 schema 的权威定义在 critical-rules.md 57.2（由 IP-08 锁定文本），progress.md 为其消费载体——
#               本项锁载体存在（57.4「progress.md 落盘四要素/轮次编号锚」的载体侧机器佐证）
#     · 负断言（IP-14）:
#         IP-14 critical-rules.md 57 块尾上下文（末条 57.4 行起至文件尾）`^66\.[0-9] ` =0（RC-15 前向防线：66 号未被顺手创建；2026-10-07 task-v143 合并级联演进：58 号已被 task-v143 Rule 58 合法创建，负断言对象 58.x→59.x，口径扩展非回退）
#         [2026-10-08 task-v149 Rule 65 落地演进] 负断言对象 65.x→66.x（Rule 65 已由 task-v149 落地，65.1-65.8；防线前移至 66，同范式再演进）
#         [2026-10-08 task-v144 合并级联] 59 号已由 task-v144 Rule 59 合法创建（59.1-59.8），且 60=v142 Rule 60 / 62=v145 Rule 62 均已落地（61 为预留登记号），
#         63=首个全未占用号；负断言对象 59.x→63.x（保持「首个全未占用号」防顺手创建语义，口径扩展非回退）
#         [2026-10-08 task-v147 第二代级联] 63.x→64.x→65.x：Rule 63 已由 task-v147 落地、Rule 64 已由 task-v148 落地（64.1-64.6），防线前移至 65
#     · config.json（零新键声明，IP-15/IP-16）:
#         IP-15 .properties 键数=44（沿用 tsv 末列既有口径，零新 config 键）
#         IP-16 `iteration_persistence` / `iteration-persistence` 键字面 =0（57.4 零新键声明的机器佐证）
#     · 脚本自身（IP-17/IP-18）:
#         IP-17 SCRIPT_DIR 自定位行在位（仓库/worktree/三宿主部署位三处可跑结构锚）
#         IP-18 头注释 What+Why 齐备（Rule 45 双层注释）
#   运行方式：`bash scripts/selftest-iteration-persistence.sh`（只读 grep/jq，零写入）；
#   逐行打印 `IP-NN PASS/FAIL <说明>`，末行 `Total: N PASS=x FAIL=y`；全 PASS exit 0，任一 FAIL exit 1。
#   被检文件路径全部相对 SCRIPT_DIR 解析（`$SCRIPT_DIR/../references/...`、`$SCRIPT_DIR/../SKILL.md`、
#   `$SCRIPT_DIR/../templates/progress.md`、`$SCRIPT_DIR/../config.json`），保证仓库/worktree/三宿主部署位三处均可直接跑。
#
# Why（Rule 57.4 机制锚，task-v141 2026-10-06）:
#   用户 R1-R4 核心诉求=「执行中（尤其迭代测试/迭代更新）数据必须及时落盘，根除多轮迭代未落盘→上下文分散→错误累积」。
#   Rule 57 是 LLM 行为面条款（每轮结束自我审查是否已落盘，非机器触发，无需开关键），若条款锚/SKILL 联动/载体出口
#   被后续裁剪误删，条款即变死文（53.2 零载体判例反向清账）；本脚本=条款死文探测器，锚丢即 FAIL 报警。
#   四要素 schema（轮次编号/测试命令/PASS-FAIL/关键输出摘要）是「落盘事实可回溯」的最小充分集（57.2），
#   权威定义在 critical-rules.md 57.2（IP-08 锁文本），progress.md 为其消费载体（IP-13 锁载体）——
#   两者配对锁死「schema 定义 + 载体出口」双面，防任一面被裁导致落盘纪律无落点。
#   IP-14 语境锚定负断言（57 块尾后才扫 66.x，防裸全文匹配被子串误触，v127/RR-09 第 5 变体判例；2026-10-08 task-v149 级联演进至 66.x）。
#   只断言 Rule 57 新增锚、不触碰既有 selftest 断言行（防锚级联，Rule 36.5 纯增量）。
# 依赖：bash + grep；config.json 键数校验需 jq（缺失降级 python3，二者皆缺打 SKIPPED 不 FAIL，fail-open 非静默——
#       与 selftest-capability-persistence.sh CP-16 / selftest-reliability-institution.sh 先例一致）。只读，零写入。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
# [task-v171 纪律域搬迁 2026-10-12] Rule 57（迭代测试轮次落盘纪律）属纪律域，原文已迁至
#   skills/task-discipline/references/critical-rules-discipline.md（核心 critical-rules.md 只剩 11 条核心规则），
#   IP-01..IP-08/IP-14 的 CRIT 断言改指 CRIT_D；CRIT 保留指向核心。断言语义零改动（含 IP-14 的
#   57 区块语境负断言，discipline 文件中 57 块内 66.x=0 口径不变）。
CRIT_D="$SKILL_ROOT/../task-discipline/references/critical-rules-discipline.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
PROG="$SKILL_ROOT/templates/progress.md"
CONFIG="$SKILL_ROOT/config.json"
SELF="$SCRIPT_DIR/selftest-iteration-persistence.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'IP-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'IP-%s FAIL %s\n' "$1" "$2"; }

# IP-01 critical-rules.md `^### 57 ` 标题行计数=1
# What：断言 Rule 57 章节标题唯一（`### 57 迭代测试轮次落盘纪律…`）。
# Why：标题行是章节识别锚；=1 保证未被重复插入（多次追加=文件尾脏写）也未被误删（条款失主）。
n="$(grep -cE '^### 57 ' "$CRIT_D" || true)"
if [ "$n" -eq 1 ]; then ok 01 "critical-rules.md '### 57 ' 标题锚 =1"; else bad 01 "critical-rules.md '### 57 ' 计数=$n（应 =1）"; fi

# IP-02 critical-rules.md `^57\.[1-4] ` 四子条计数=4
# What：断言 57.1-57.4 四条子条主体行（行首 `57.N `）全在位。
# Why：四子条是 57.1 每轮必落盘/57.2 落盘四要素/57.3 即时落盘防上下文分散/57.4 机制的唯一文本落点；
#      缺任一条 = Rule 57 条款本体被裁剪（防后续改写 critical-rules.md 时误删 57.x 段）。
n="$(grep -cE '^57\.[1-4] ' "$CRIT_D" || true)"
if [ "$n" -eq 4 ]; then ok 02 "critical-rules.md '57.x ' 四子条锚 =4"; else bad 02 "critical-rules.md '57.x ' 计数=$n（应 =4）"; fi

# IP-03 Rule 57 块首说明行含 task-v141（来源任务锚）
# What：断言 `### 57 ` 标题行正文含来源任务代号 `task-v141`。
# Why：条款需可溯源（Rule 20.6 编号账本/任务代号可追溯）；缺 task 代号 = 条款失去来源登记，回归期无法对账。
if grep -E '^### 57 ' "$CRIT_D" | grep -q 'task-v141'; then
  ok 03 "Rule 57 块首说明行含 task-v141"
else
  bad 03 "Rule 57 块首说明行缺 task-v141 来源锚"
fi

# IP-04 57.1 子条锚 =1（每轮结果必落盘）
# What：断言 `57.1 **每轮结果必落盘（per-round persistence）**` 字面锚恰 1 处。
# Why：57.1 是用户 R1-R4「每轮测试/迭代结果当次落盘」的核心禁令载体——锚丢=每轮落盘义务无条款依据。
n="$(grep -cF '57.1 **每轮结果必落盘（per-round persistence）**' "$CRIT_D" || true)"
if [ "$n" -eq 1 ]; then ok 04 "critical-rules.md 57.1「每轮结果必落盘」=1"; else bad 04 "critical-rules.md 57.1 锚命中=$n（应 =1）"; fi

# IP-05 57.2 子条锚 =1（落盘四要素）
# What：断言 `57.2 **落盘四要素（round record schema）**` 字面锚恰 1 处。
# Why：57.2 是四要素 schema 的权威定义点（IP-08 的语义根）——锚丢=四要素失去上位定义（体系脱根探测）。
n="$(grep -cF '57.2 **落盘四要素（round record schema）**' "$CRIT_D" || true)"
if [ "$n" -eq 1 ]; then ok 05 "critical-rules.md 57.2「落盘四要素」=1"; else bad 05 "critical-rules.md 57.2 锚命中=$n（应 =1）"; fi

# IP-06 57.3 子条锚 =1（即时落盘防上下文分散）
# What：断言 `57.3 **即时落盘防上下文分散（timely persistence）**` 字面锚恰 1 处。
# Why：57.3 是用户 R3「迭代中及时落盘才可救回」的直接载体（下一轮基于文件事实而非会话记忆）——锚丢=R3 诉求无落点。
n="$(grep -cF '57.3 **即时落盘防上下文分散（timely persistence）**' "$CRIT_D" || true)"
if [ "$n" -eq 1 ]; then ok 06 "critical-rules.md 57.3「即时落盘防上下文分散」=1"; else bad 06 "critical-rules.md 57.3 锚命中=$n（应 =1）"; fi

# IP-07 57.4 子条锚 =1（机制，标题前缀锚：标题尾部含 Why 说明故锁前缀不锁全行）
# What：断言 `57.4 **机制（零新 config 键` 字面锚恰 1 处。
# Why：57.4 机制条是本脚本自身存在的条款依据（机器面=selftest 静态守护声明）——锚丢=脚本与条款双向引用断裂（守卫自引用失效）。
n="$(grep -cF '57.4 **机制（零新 config 键' "$CRIT_D" || true)"
if [ "$n" -eq 1 ]; then ok 07 "critical-rules.md 57.4「机制（零新 config 键」=1"; else bad 07 "critical-rules.md 57.4 锚命中=$n（应 =1）"; fi

# IP-08 落盘四要素锚：轮次编号 / 测试命令 / PASS/FAIL / 关键输出摘要 各 ≥1（57.2 schema 语义内核）
# What：断言四要素关键短语在 critical-rules.md 中各自出现 ≥1（57.2 正文）。
# Why：子条标题锚（IP-04..07）只锁编号+标题字面，四要素短语是 57.2 的语义内核——
#      防「标题还在但正文被裁空壳」的语义漂移（死文变体探测）；四要素是落盘事实可回溯的最小充分集。
a="$(grep -cF '轮次编号' "$CRIT_D" || true)"
b="$(grep -cF '测试命令' "$CRIT_D" || true)"
c="$(grep -cF 'PASS/FAIL' "$CRIT_D" || true)"
d="$(grep -cF '关键输出摘要' "$CRIT_D" || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ] && [ "$c" -ge 1 ] && [ "$d" -ge 1 ]; then
  ok 08 "critical-rules.md 四要素锚 轮次编号=$a / 测试命令=$b / PASS-FAIL=$c / 关键输出摘要=$d（各 ≥1）"
else
  bad 08 "critical-rules.md 四要素锚 轮次编号=$a / 测试命令=$b / PASS-FAIL=$c / 关键输出摘要=$d（各应 ≥1，schema 内核被裁）"
fi

# IP-09 [task-v171 核心瘦身] 执行循环消费侧锚：「迭代落盘检查点（Rule 57」3e 标题随瘦身移除 → 回写计划步 progress 落盘载体锚
#   现象：SKILL.md 瘦身后执行循环 3e「迭代落盘检查点（Rule 57）」标题行不存在（3e 现为上下文卫生），字面命中=0，IP-09 恒 FAIL。
#   根因：Rule 57 属纪律域；执行循环瘦身后迭代落盘的 SKILL 侧落点=步 4「回写计划」行内含 progress Phase 段
#     回填（Actions/Files/Test Results）——即 57「每轮结果落盘」在执行循环的现存载体。
#   修法：改断言 'Actions/Files/Test Results' 落盘载体行 =1（§57 消费面语义等价）；Rule 57 全文锚由 IP-01..08 在 CRIT_D 守护。
n="$(grep -cF 'Actions/Files/Test Results' "$SKILLMD" || true)"
if [ "$n" -eq 1 ]; then ok 09 "SKILL.md 回写计划行含 progress 落盘载体 Actions/Files/Test Results=1（原 3e「迭代落盘检查点」瘦身后由步 4 承载）"; else bad 09 "SKILL.md 落盘载体锚命中=$n（应 =1）"; fi

# IP-10 [task-v171 核心瘦身] `Rule 57` SKILL 侧联动面 ≥3 → 卫星路由表 discipline 行（区间 53-57 覆盖 Rule 57）≥1 + CRIT_D 57.4 机制行机器面指称
#   现象：SKILL.md 瘦身后 'Rule 57' 计数 3→0（3e 行/C40 行/References 摘要行三处全随瘦身移除），IP-10 恒 FAIL。
#   根因：Rule 57 属纪律域已迁 CRIT_D；SKILL 侧编号联动仅剩卫星路由表 discipline 行（Rule 57 以区间 53-57 形态覆盖，无整串）。
#   修法：改断言路由表 discipline 行 =1 + CRIT_D 57.4 机制行含本 selftest 机器面指称（守护可发现性，双载体不丢）。
n="$(grep -cE '^\| task-discipline \|' "$SKILLMD" || true)"
m="$(grep -cF 'selftest-iteration-persistence.sh' "$CRIT_D" || true)"
if [ "$n" -ge 1 ] && [ "$m" -ge 1 ]; then ok 10 "SKILL.md 卫星路由表 discipline 行=$n（区间 53-57 覆盖 Rule 57）+ CRIT_D 57.4 机器面指称=$m"; else bad 10 "路由表 discipline 行=$n（应 ≥1）/ CRIT_D 机器面指称=$m（应 ≥1，联动面缺）"; fi

# IP-11 [task-v171 核心瘦身] 合规行 C40 → G 表 progress 回填合规行（G6：complete 前 progress 回填门控）
#   现象：合规清单 C40 行随瘦身移除（清单表→G1-G8 核心域表），命中=0，IP-11 恒 FAIL。
#   根因：Rule 57 属纪律域；core-domain 合规表中与「迭代落盘/进度回填」对应的现存合规行=G6（progress 回填+findings 增量门控）。
#   修法：改断言 G6 compliance 行 =1（合规消费点语义由 G6 承载）。
n="$(grep -cE '^\| G6 ' "$SKILLMD" || true)"
if [ "$n" -eq 1 ]; then ok 11 "SKILL.md G6 合规行（progress 回填门控）=1（C40 迭代落盘合规面瘦身后由 G6 承载）"; else bad 11 "SKILL.md G6 行命中=$n（应 =1）"; fi

# IP-12 SKILL.md 全集声明宽容锚 `Rule 40-[5-8][0-9]` ≥1
# What：断言 SKILL.md 出现 Rules 40-8x 全集声明（宽容正则覆盖 40-50..40-89 各纪元）。
# Why：全集声明随 Rule 号演进（当前 40-80，后续合法扩号仍不触发本锚）；固定字面会随纪元漂移误报，
#      故用宽容正则（task-v136 EH-09 / RR-16 先例：宽容正则优先，防下次全集演进再钉死）。
#      [2026-10-08 task-v144 合并级联] 宽容范围 5x→5x+6x：v142/v145 落地 Rule 60/62 后 SKILL.md 全集声明演进为
#      「Rule 40-62」，旧正则 `40-5[5-9]` 不再命中（级联漏改）；扩展为 `40-[56][0-9]` 同范式再演进。
#      [2026-10-10 task-v158 S-unit 级联] SKILL.md 全集声明演进为「Rule 40-71」(L288)，`40-[56][0-9]` 不再命中
#      （级联漏改）；随动 40-[56][0-9]→40-[567][0-9]（覆盖 40-50..40-79）同范式再演进，≥1 计数语义不变。
#      [2026-10-11 task-v169 级联] Rule 80 落地后 SKILL.md 全集声明演进为「Rule 40-80 全集」(L313)，`40-[567][0-9]`
#      （覆盖 40-50..40-79）不再命中（级联漏改）；随动 40-[567][0-9]→40-[5-8][0-9]（覆盖 40-50..40-89）同范式再演进，≥1 计数语义不变。
#      [2026-10-12 task-v171 分层口径切换] SKILL.md 重写瘦身后全集声明演进为「Rules 1-80 全集索引」（核心 12 条+10 卫星），
#      `40-[5-8][0-9]` 不再命中（级联漏改）；随动演进为 `1-8[013]` 全集口径锚（task-v170 并集 max 口径覆盖 1-81）（覆盖 1-80 全集，宽容正则优先范式保持，≥1 计数语义不变）。
n="$(grep -cE '1-8[013]' "$SKILLMD" || true)"
if [ "$n" -ge 1 ]; then ok 12 "SKILL.md 全集声明「1-8[013]」口径锚 ≥1（$n，v171 分层架构口径）"; else bad 12 "SKILL.md 全集声明「1-80」=$n（应 ≥1，级联漏改）"; fi

# IP-13 templates/progress.md 在位且含「Test Results」段（落盘载体出口）
# What：断言 progress.md 模板存在且含 `Test Results` 段（迭代轮次结果的落盘载体）。
# Why：57.4「progress.md 落盘四要素/轮次编号锚」的载体侧机器佐证——四要素 schema 权威定义在 57.2（IP-08 锁文本），
#      progress.md 是其消费载体；载体文件/落盘段丢失 = 落盘无出口（条款死文变体）。锁段名（载体结构锚）而非四要素字面
#      （四要素由 IP-08 锁权威定义处，避免同一语义双处钉死导致维护冲突）。
if [ -f "$PROG" ]; then
  n="$(grep -cF 'Test Results' "$PROG" || true)"
  if [ "$n" -ge 1 ]; then ok 13 "templates/progress.md 在位且含「Test Results」落盘段（$n）"; else bad 13 "templates/progress.md 缺「Test Results」落盘段（载体出口丢失）"; fi
else
  bad 13 "templates/progress.md 缺失（$PROG，落盘载体不存在）"
fi

# IP-14 负断言（语境锚定）：critical-rules.md 57 块尾上下文（末条 57.4 行起至文件尾）`^66\.[0-9] ` =0
# What：断言 57.4 之后不存在 66.x 子条行。
# Why：RC-15 前向防线（防下一编号被顺手创建）的语境锚定实现——扫「57 块之后」而非全文：裸全文匹配会被子串误触
#      （v127/RR-09 第 5 变体判例：负断言须语境锚定）；块尾后出现 66.x = 下一编号未经合法登记却被顺手写入（57 块编辑越界扩号探测）。
#      [2026-10-08 task-v149 Rule 65 落地演进] 负断言对象 65.x→66.x（Rule 65 已由 task-v149 落地，65.1-65.8；防线前移至 66，同范式再演进）
#      [2026-10-07 task-v143 合并级联] 58 号已被 task-v143 Rule 58 合法创建（58.1-58.7，判定面 58.7 机器面=selftest-evidence-goal-gate.sh）——
#      本条负断言对象相应演进：58.x→59.x（口径扩展非回退，task-v127「RC-15 负断言 ^50→^52 演进」同范式）。
#      [2026-10-08 task-v144 合并级联] 59 号已由 task-v144 Rule 59 合法创建（59.1-59.8），且 60=v142 / 62=v145 已落地、61 为预留号，
#      首个全未占用号=63；负断言对象 59.x→63.x（保持「首个全未占用号」防顺手创建语义，同范式再演进）。
# [2026-10-09 task-v151 S4 钉值级联/D2 同法] 语境锚定由「末条 57.x 行起至文件尾」收窄为「Rule 57 区块」
#   （awk: ### 57 起至下一 ### 止）——Rule 66 已合法落地于 57 块之后，tail-to-EOF 口径必红；收窄后保留
#   「57 块内无 66 入侵」负断言（编辑越界探测），全文件面 ^66.x 计数由 selftest-goal-unit-goal-mode.sh G-02（=6）承载。
block57="$(awk '/^### 57 /{f=1;next} /^### /{f=0} f' "$CRIT_D" 2>/dev/null)"
if [ -z "$block57" ]; then
  bad 14 "critical-rules.md 未找到 Rule 57 区块（### 57 标题行，负断言无法语境锚定）"
else
  n="$(printf '%s\n' "$block57" | grep -cE '^66\.[0-9] ' || true)"
  if [ "$n" -eq 0 ]; then ok 14 "critical-rules.md 57 块范围内「66.x」=0（57 块无 66 入侵；task-v151 钉值级联 D2 同法）"; else bad 14 "critical-rules.md 57 块范围内「66.x」=$n（应 =0，57 块被 66 入侵）"; fi
fi

# IP-15 config.json .properties 键数=44（零新 config 键声明锚）
# What：断言 config.json 顶层 properties 键数保持 42。
# Why：57.4 承诺「零新 config 键」（与 43.4/54.6/55.6/56.5 同范式）——键数膨胀 = 有人给 Rule 57 加了机器门控键，
#      突破既定零新键范式（机制漂移，需走 Rule 36 流程）。沿用 tsv 末列既有口径 `config properties=42`。
#      [2026-10-08 task-v144 合并级联] 键数锚值 40→42：task-v145（Rule 62 四文件罗盘）合法新增 2 键（FF 守护口径 42 为准，
#      见 selftest-four-file-dataflow.sh），Rule 57 自身仍零新键（IP-16 负断言锁），本条仅随全局基线演进，非 57 扩键。
if command -v jq >/dev/null 2>&1; then
  keys="$(jq -r '.properties|keys|length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "46" ]; then ok 15 "config.json properties 键数 46（v145 基线演进 + task-v172 合法新增 2 键）"; else bad 15 "config.json properties 键数=$keys（应 46，未授权新键）"; fi
elif command -v python3 >/dev/null 2>&1; then
  keys="$(python3 -c "import json;print(len(json.load(open('$CONFIG'))['properties']))" 2>/dev/null || true)"
  if [ "$keys" = "46" ]; then ok 15 "config.json properties 键数 46（python3 校验; task-v172 合法新增 2 键）"; else bad 15 "config.json properties 键数=$keys（应 46）"; fi
else
  printf 'IP-15 SKIPPED jq/python3 均缺失，无法校验 config.json 键数（安装任一后重跑）\n'
fi

# IP-16 零新键负断言：config.json 无 `iteration_persistence` / `iteration-persistence` 键字面（=0）
# What：断言 config.json 不含 iteration_persistence（下划线/连字符）字面。
# Why：57.4 声明「零新 config 键」——若后续有人给 57 加开关键，即范式回退为 config 开关式（判定面=LLM 行为无需开关键）；
#      负断言锁声明与 config 面一致。口径锁定键名字面（`iteration[_-]persistence`），非全 file 裸匹配（防未来合法他键子串误伤，v127 判例）。
n="$(grep -cE 'iteration[_-]persistence' "$CONFIG" || true)"
if [ "$n" -eq 0 ]; then ok 16 "config.json 零新键：「iteration[_-]persistence」命中=0（57.4 零 config 键声明成立）"; else bad 16 "config.json「iteration[_-]persistence」命中=$n（应 =0，57.4 零新键声明被破）"; fi

# IP-17 脚本自身 SCRIPT_DIR 自定位行在位（三处可跑结构锚）
# What：断言本脚本含 SCRIPT_DIR 自定位 idiom（`BASH_SOURCE[0]` 形式）。
# Why：仓库/worktree/三宿主部署位路径深度不同；自定位行是相对解析的根——被硬编码路径替换则三处仅一处可跑。
if grep -qE 'SCRIPT_DIR="\$\(cd "\$\(dirname ' "$SELF"; then
  ok 17 "脚本 SCRIPT_DIR 自定位行在位"
else
  bad 17 "脚本缺 SCRIPT_DIR 自定位行（硬编码路径风险）"
fi

# IP-18 脚本头注释 What+Why 齐备（Rule 45 双层注释）
# What：断言本脚本头部注释含 `# What` 与 `# Why` 两个标记。
# Why：Rule 45 双层注释要求（What=做什么/Why=为何这样做）；守护脚本自身也须示范该纪律（防只写代码不写取舍）。
if grep -q '# What' "$SELF" && grep -q '# Why' "$SELF"; then
  ok 18 "脚本头注释 What+Why 齐备（Rule 45）"
else
  bad 18 "脚本头注释缺 What 或 Why（Rule 45）"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
