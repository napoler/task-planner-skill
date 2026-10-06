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
#         IP-12 全集声明宽容锚 `Rule 40-5[5-9]` ≥1（纪元演进防钉死，task-v136 EH-09 先例）
#     · templates/progress.md（落盘载体，IP-13）:
#         IP-13 文件在位且含「Test Results」段（迭代轮次结果的落盘载体出口）；
#               四要素 schema 的权威定义在 critical-rules.md 57.2（由 IP-08 锁定文本），progress.md 为其消费载体——
#               本项锁载体存在（57.4「progress.md 落盘四要素/轮次编号锚」的载体侧机器佐证）
#     · 负断言（IP-14）:
#         IP-14 critical-rules.md 57 块尾上下文（末条 57.4 行起至文件尾）`^58\.[0-9] ` =0（RC-15 前向防线：58 号未被顺手创建）
#     · config.json（零新键声明，IP-15/IP-16）:
#         IP-15 .properties 键数=40（沿用 tsv 末列既有口径，零新 config 键）
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
#   IP-14 语境锚定负断言（57 块尾后才扫 58.x，防裸全文匹配被子串误触，v127/RR-09 第 5 变体判例）。
#   只断言 Rule 57 新增锚、不触碰既有 selftest 断言行（防锚级联，Rule 36.5 纯增量）。
# 依赖：bash + grep；config.json 键数校验需 jq（缺失降级 python3，二者皆缺打 SKIPPED 不 FAIL，fail-open 非静默——
#       与 selftest-capability-persistence.sh CP-16 / selftest-reliability-institution.sh 先例一致）。只读，零写入。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
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
n="$(grep -cE '^### 57 ' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 01 "critical-rules.md '### 57 ' 标题锚 =1"; else bad 01 "critical-rules.md '### 57 ' 计数=$n（应 =1）"; fi

# IP-02 critical-rules.md `^57\.[1-4] ` 四子条计数=4
# What：断言 57.1-57.4 四条子条主体行（行首 `57.N `）全在位。
# Why：四子条是 57.1 每轮必落盘/57.2 落盘四要素/57.3 即时落盘防上下文分散/57.4 机制的唯一文本落点；
#      缺任一条 = Rule 57 条款本体被裁剪（防后续改写 critical-rules.md 时误删 57.x 段）。
n="$(grep -cE '^57\.[1-4] ' "$CRIT" || true)"
if [ "$n" -eq 4 ]; then ok 02 "critical-rules.md '57.x ' 四子条锚 =4"; else bad 02 "critical-rules.md '57.x ' 计数=$n（应 =4）"; fi

# IP-03 Rule 57 块首说明行含 task-v141（来源任务锚）
# What：断言 `### 57 ` 标题行正文含来源任务代号 `task-v141`。
# Why：条款需可溯源（Rule 20.6 编号账本/任务代号可追溯）；缺 task 代号 = 条款失去来源登记，回归期无法对账。
if grep -E '^### 57 ' "$CRIT" | grep -q 'task-v141'; then
  ok 03 "Rule 57 块首说明行含 task-v141"
else
  bad 03 "Rule 57 块首说明行缺 task-v141 来源锚"
fi

# IP-04 57.1 子条锚 =1（每轮结果必落盘）
# What：断言 `57.1 **每轮结果必落盘（per-round persistence）**` 字面锚恰 1 处。
# Why：57.1 是用户 R1-R4「每轮测试/迭代结果当次落盘」的核心禁令载体——锚丢=每轮落盘义务无条款依据。
n="$(grep -cF '57.1 **每轮结果必落盘（per-round persistence）**' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 04 "critical-rules.md 57.1「每轮结果必落盘」=1"; else bad 04 "critical-rules.md 57.1 锚命中=$n（应 =1）"; fi

# IP-05 57.2 子条锚 =1（落盘四要素）
# What：断言 `57.2 **落盘四要素（round record schema）**` 字面锚恰 1 处。
# Why：57.2 是四要素 schema 的权威定义点（IP-08 的语义根）——锚丢=四要素失去上位定义（体系脱根探测）。
n="$(grep -cF '57.2 **落盘四要素（round record schema）**' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 05 "critical-rules.md 57.2「落盘四要素」=1"; else bad 05 "critical-rules.md 57.2 锚命中=$n（应 =1）"; fi

# IP-06 57.3 子条锚 =1（即时落盘防上下文分散）
# What：断言 `57.3 **即时落盘防上下文分散（timely persistence）**` 字面锚恰 1 处。
# Why：57.3 是用户 R3「迭代中及时落盘才可救回」的直接载体（下一轮基于文件事实而非会话记忆）——锚丢=R3 诉求无落点。
n="$(grep -cF '57.3 **即时落盘防上下文分散（timely persistence）**' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 06 "critical-rules.md 57.3「即时落盘防上下文分散」=1"; else bad 06 "critical-rules.md 57.3 锚命中=$n（应 =1）"; fi

# IP-07 57.4 子条锚 =1（机制，标题前缀锚：标题尾部含 Why 说明故锁前缀不锁全行）
# What：断言 `57.4 **机制（零新 config 键` 字面锚恰 1 处。
# Why：57.4 机制条是本脚本自身存在的条款依据（机器面=selftest 静态守护声明）——锚丢=脚本与条款双向引用断裂（守卫自引用失效）。
n="$(grep -cF '57.4 **机制（零新 config 键' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 07 "critical-rules.md 57.4「机制（零新 config 键」=1"; else bad 07 "critical-rules.md 57.4 锚命中=$n（应 =1）"; fi

# IP-08 落盘四要素锚：轮次编号 / 测试命令 / PASS/FAIL / 关键输出摘要 各 ≥1（57.2 schema 语义内核）
# What：断言四要素关键短语在 critical-rules.md 中各自出现 ≥1（57.2 正文）。
# Why：子条标题锚（IP-04..07）只锁编号+标题字面，四要素短语是 57.2 的语义内核——
#      防「标题还在但正文被裁空壳」的语义漂移（死文变体探测）；四要素是落盘事实可回溯的最小充分集。
a="$(grep -cF '轮次编号' "$CRIT" || true)"
b="$(grep -cF '测试命令' "$CRIT" || true)"
c="$(grep -cF 'PASS/FAIL' "$CRIT" || true)"
d="$(grep -cF '关键输出摘要' "$CRIT" || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ] && [ "$c" -ge 1 ] && [ "$d" -ge 1 ]; then
  ok 08 "critical-rules.md 四要素锚 轮次编号=$a / 测试命令=$b / PASS-FAIL=$c / 关键输出摘要=$d（各 ≥1）"
else
  bad 08 "critical-rules.md 四要素锚 轮次编号=$a / 测试命令=$b / PASS-FAIL=$c / 关键输出摘要=$d（各应 ≥1，schema 内核被裁）"
fi

# IP-09 SKILL.md 执行循环 3e 锚「迭代落盘检查点（Rule 57」=1
# What：断言 SKILL.md 执行循环含 3e 迭代落盘检查点标题字面锚恰 1 处。
# Why：57.4 声明的消费侧=SKILL.md 执行循环「迭代落盘检查点（Rule 57）」；缺 = 条款只在 critical-rules 而执行期不可发现
#      （条款死文，53.2 反例 task-v131 判例）；=1 锁唯一落点（多落点=段落复制漂移）。
n="$(grep -cF '迭代落盘检查点（Rule 57' "$SKILLMD" || true)"
if [ "$n" -eq 1 ]; then ok 09 "SKILL.md 执行循环「迭代落盘检查点（Rule 57」锚=1"; else bad 09 "SKILL.md 3e 锚命中=$n（应 =1，条款死文或重复落点）"; fi

# IP-10 SKILL.md `Rule 57` 计数 ≥3（3e 行 / C40 行 / References 摘要行三处联动）
# What：断言 SKILL.md 中 `Rule 57` 出现 ≥3 次。
# Why：SKILL.md 是执行期入口；条款只在 critical-rules.md 而 SKILL 无联动 = 消费侧不可发现（53.2 条款死文反例）；
#      ≥3 与 3e/C40/摘要三处联动承诺对齐（防后续只改一处造成索引面失守）。
n="$(grep -c 'Rule 57' "$SKILLMD" || true)"
if [ "$n" -ge 3 ]; then ok 10 "SKILL.md 'Rule 57' 计数 $n ≥3"; else bad 10 "SKILL.md 'Rule 57' 计数=$n（应 ≥3，联动面缺）"; fi

# IP-11 SKILL.md `^\| C40 ` 合规行 =1
# What：断言 SKILL.md 合规清单 C40 行恰 1 处（行首 `| C40 `）。
# Why：57.4 声明消费侧=合规清单 C40（迭代落盘自查项）；丢行 = 合规面与 57 子条脱钩；=1 锁唯一落点（重复落点=段落复制漂移）。
n="$(grep -cE '^\| C40 ' "$SKILLMD" || true)"
if [ "$n" -eq 1 ]; then ok 11 "SKILL.md 合规行 C40 =1"; else bad 11 "SKILL.md C40 行命中=$n（应 =1）"; fi

# IP-12 SKILL.md 全集声明宽容锚 `Rule 40-5[5-9]` ≥1
# What：断言 SKILL.md 出现 Rules 40-5x 全集声明（宽容正则覆盖 40-55..40-59 各纪元）。
# Why：全集声明随 Rule 号演进（当前 40-55，Rule 57 落地后可能再演进）；固定字面会随纪元漂移误报，
#      故用宽容正则（task-v136 EH-09 / RR-16 先例：宽容正则优先，防下次全集演进再钉死）。
n="$(grep -cE 'Rule 40-5[5-9]' "$SKILLMD" || true)"
if [ "$n" -ge 1 ]; then ok 12 "SKILL.md 全集声明「Rule 40-5x」宽容锚 ≥1（$n）"; else bad 12 "SKILL.md 全集声明「Rule 40-5[5-9]」=$n（应 ≥1，级联漏改）"; fi

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

# IP-14 负断言（语境锚定）：critical-rules.md 57 块尾上下文（末条 57.4 行起至文件尾）`^58\.[0-9] ` =0
# What：断言 57.4 之后不存在 58.x 子条行。
# Why：RC-15 前向防线（防 58 号被顺手创建）的语境锚定实现——扫「57 块之后」而非全文：裸全文匹配会被子串误触
#      （v127/RR-09 第 5 变体判例：负断言须语境锚定）；块尾后出现 58.x = 58 号未经合法登记却被顺手写入（57 块编辑越界扩号探测）。
last57line="$(grep -nE '^57\.[1-4] ' "$CRIT" | tail -1 | cut -d: -f1 || true)"
if [ -z "$last57line" ]; then
  bad 14 "critical-rules.md 未找到 57.x 末条行（块缺失，负断言无法语境锚定）"
else
  tailctx="$(tail -n +"$last57line" "$CRIT")"
  n="$(printf '%s\n' "$tailctx" | grep -cE '^58\.[0-9] ' || true)"
  if [ "$n" -eq 0 ]; then ok 14 "critical-rules.md 57 块尾上下文（L${last57line}起）「58.x」=0（RC-15 前向防线）"; else bad 14 "critical-rules.md 57 块尾「58.x」=$n（应 =0，58 号被顺手创建）"; fi
fi

# IP-15 config.json .properties 键数=40（零新 config 键声明锚）
# What：断言 config.json 顶层 properties 键数保持 40。
# Why：57.4 承诺「零新 config 键」（与 43.4/54.6/55.6/56.5 同范式）——键数膨胀 = 有人给 Rule 57 加了机器门控键，
#      突破既定零新键范式（机制漂移，需走 Rule 36 流程）。沿用 tsv 末列既有口径 `config properties=40`。
if command -v jq >/dev/null 2>&1; then
  keys="$(jq -r '.properties|keys|length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "40" ]; then ok 15 "config.json properties 键数 40（零新增）"; else bad 15 "config.json properties 键数=$keys（应 40，零新键被破坏）"; fi
elif command -v python3 >/dev/null 2>&1; then
  keys="$(python3 -c "import json;print(len(json.load(open('$CONFIG'))['properties']))" 2>/dev/null || true)"
  if [ "$keys" = "40" ]; then ok 15 "config.json properties 键数 40（python3 校验）"; else bad 15 "config.json properties 键数=$keys（应 40）"; fi
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
