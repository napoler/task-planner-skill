#!/usr/bin/env bash
# selftest-four-file-dataflow.sh — task-v145: Rule 62「四文件罗盘数据流转与调研知识沉淀纪律」静态守护（62.6 机制面）
#
# What（守护对象 + 运行方式）:
#   静态断言 task-v145 全链落点在位（对齐 selftest-iteration-persistence.sh / selftest-execution-honesty.sh 范式），
#   共 18 条编号断言 FF-01..FF-18：
#     · references/critical-rules.md（Rule 62 条款本体，FF-01..FF-06）:
#         FF-01 `^### 62 ` 标题=1；FF-02 `^62\.[1-6] ` 六子条=6；FF-03 判例注释含 task-v145（来源任务锚）≥1
#         FF-04 62.2 语义内核锚「不可收窄」≥1 且「叠加义务」≥1（防「标题在但正文被裁」死文变体）
#         FF-05 62.3 双落盘语义锚「双落盘」≥1 且「kb:§N」≥1（Handoff 双锚 schema 内核）
#         FF-06 62.5 门控语义锚 `--require-kb` ≥1 且 `kb_distill` ≥1（机器面声明与实现配对）
#     · scripts/（机器面三脚本，FF-07..FF-09）:
#         FF-07 check-dispatch.sh `scan_contract_narrowing()`≥1 且 `[dispatch-contract]`≥1（62.2 lint 实现锚）
#         FF-08 check-3file-gate.sh `kb_distill_activity`(无括号,注释+定义+调用)≥3 且 `--require-kb`≥2（62.5 gate 实现锚，
#              [2026-10-08 CR-P2 加固]无括号计数锁调用点不被删）；FF-09 锚 `VALID_EVENTS=.*kb_distill` 行=1（锁枚举实改非注释）
#         FF-09 ledger-append.sh `kb_distill`≥2（VALID_EVENTS+注释，62.5 事件枚举锚）
#     · templates/subagent_dispatch.md（派发契约载体，FF-10）:
#         FF-10 `knowledge-brief: {plan_dir}`≥1（四文件契约第 4 文件行）且 `可写=仅追加`≥1（findings 可写契约行
#               仍在位——模板自身被收窄=守卫自盲，FF-10 双条件锁死）
#     · SKILL.md（消费侧联动，FF-11..FF-14）:
#         FF-11 `^\| C42 ` 合规行=1（C41 归 v143 Rule 58，C42=本任务顺延）；FF-12 `Rule 62（四文件罗盘` 摘要行=1
#         FF-13 映射表蒸馏行「主进程单写者蒸馏，Rule 62.3 双落盘」=1；FF-14 `Rule 62` 全文 ≥3（C41/摘要/映射三落点联动）
#     · config.json（零新键声明，FF-15）:
#         FF-15 `four_file`/`kb_distill`/`contract_narrow`/`require_kb` 键字面=0 且 .properties 键数=42
#         （42=task-v145 时点基线，v141/v142 演进后值；本任务零新 config 键的机器佐证）
#     · 负断言（FF-16）:
#         FF-16 critical-rules.md 62 块尾上下文（末条 62.6 行起至文件尾）`^66\.[0-9] ` =0（RC-15 前向防线：
#               61 号未被顺手创建；语境锚定负断言，v127/RR-09 第 5 变体判例范式）
#               [2026-10-08 task-v147 第二代级联] '^64\.'→'^65\.'：Rule 64 已由 task-v148 落地（64.1-64.6），防线前移至 65
#               [2026-10-08 task-v149 Rule 65 落地演进] '^65\.'→'^66\.'：Rule 65 已由 task-v149 落地，防线前移至 66
#     · 脚本自身（FF-17/FF-18）:
#         FF-17 SCRIPT_DIR 自定位行在位（仓库/worktree/三宿主部署位三处可跑结构锚）
#         FF-18 头注释 What+Why 齐备（Rule 45 双层注释）
#   运行方式：`bash scripts/selftest-four-file-dataflow.sh`（只读 grep/jq，零写入）；
#   逐行打印 `FF-NN PASS/FAIL <说明>`，末行 `Total: 18 PASS=x FAIL=y`；全 PASS exit 0，任一 FAIL exit 1。
#   被检文件路径全部相对 SCRIPT_DIR 解析，保证仓库/worktree/部署位三处均可直接跑。
#
# Why（Rule 62.6 机制锚，task-v145 2026-10-08）:
#   用户核心诉求=「四文件体系作为主子代理数据流转协议的地位强化 + 调研产出罗盘沉淀到知识库文件」。
#   Rule 62 是「行为面（62.2 契约纪律/62.3 双落盘/62.4 消费闭环）+ 机器面（lint/gate/ledger 三脚本扩展）」复合条款，
#   任一锚被后续裁剪误删即变死文（53.2 零载体判例反向清账）：本脚本锁「条款文本 + 三脚本实现 + 模板契约 + SKILL 消费」
#   四面配对——尤其 FF-10 双条件（kb 行在位 ∧ findings 可写行未被裁）防派发模板自身被收窄成「只写检查点」回潮。
#   FF-15 零新键断言沿用 tsv 口径（62.6 声明「零新 config 键」的机器佐证）；FF-16 前向防线防编号顺手占用。
#   判例背景：videop1 派发 prompt 手写「主进程回填，你只写检查点」收窄 22.4a 契约，30KB 调研知识只停检查点——
#   本守护确保 lint/gate/模板/条款任一面回退时 selftest 即 FAIL 报警（防复发，Rule 31.5 消费侧）。

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CR="$SCRIPT_DIR/../references/critical-rules.md"
SKILL="$SCRIPT_DIR/../SKILL.md"
TPL="$SCRIPT_DIR/../templates/subagent_dispatch.md"
CD_="$SCRIPT_DIR/check-dispatch.sh"
GATE="$SCRIPT_DIR/check-3file-gate.sh"
LEDGER="$SCRIPT_DIR/ledger-append.sh"
CONFIG="$SCRIPT_DIR/../config.json"

PASS=0; FAIL=0
# 判定助手：eq(=N) / ge(>=N) / pair(两计数各>=1) / zero(=0)
ok()   { echo "PASS $1"; PASS=$((PASS+1)); }
bad()  { echo "FAIL $1 ($2)"; FAIL=$((FAIL+1)); }
eq()   { local d="$1" n="$2" e="$3"; [ "$n" -eq "$e" ] && ok "$d" || bad "$d" "got=$n expect==$e"; }
ge()   { local d="$1" n="$2" e="$3"; [ "$n" -ge "$e" ] && ok "$d" || bad "$d" "got=$n expect>=$e"; }
zero() { local d="$1" n="$2"; [ "$n" -eq 0 ] && ok "$d" || bad "$d" "got=$n expect==0"; }
pair() { # pair <desc> <n1> <n2> — 两锚各 ≥1（复合语义内核，单 grep 计数不足以免「半裁」漏检）
    local d="$1" a="$2" b="$3"
    if [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then ok "$d"; else bad "$d" "got=($a,$b) expect=(>=1,>=1)"; fi
}
cnt() { # [2026-10-08 CR-P2 修正] 缺失文件回显 0（防空串进整数比较报 bash 错）；-e 承载 -- 开头模式
    [ -f "$2" ] || { echo 0; return; }
    grep -c -e "$1" "$2" 2>/dev/null || true; }

# ── critical-rules.md Rule 62 条款本体 ──
eq   "FF-01 critical-rules ### 60 标题=1"                 "$(cnt '^### 62 ' "$CR")" 1
eq   "FF-02 critical-rules 62.1-62.6 六子条=6"            "$(cnt '^62\.[1-6] \*\*' "$CR")" 6
ge   "FF-03 判例注释 task-v145 来源锚"                     "$(cnt 'Rule 62 (task-v145 2026-10-08)' "$CR")" 1
pair "FF-04 62.2 语义内核(不可收窄+叠加义务)"               "$(cnt '不可收窄' "$CR")" "$(cnt '叠加义务' "$CR")"
pair "FF-05 62.3 双落盘语义(双落盘+kb:§N)"                 "$(cnt '双落盘' "$CR")" "$(cnt 'kb:§N' "$CR")"
pair "FF-06 62.5 门控语义(--require-kb+kb_distill)"        "$(cnt '--require-kb' "$CR")" "$(cnt 'kb_distill' "$CR")"

# ── scripts 机器面三脚本 ──
pair "FF-07 check-dispatch lint 实现(scan函数+[dispatch-contract]前缀)" "$(cnt 'scan_contract_narrowing()' "$CD_")" "$(cnt '\[dispatch-contract\]' "$CD_")"
# [2026-10-08 CR-P2 加固] FF-08 数无括号出现次数（注释+定义+调用≥3，锁调用点不被删）；FF-09 锚 VALID_EVENTS 行实改
if [ "$(cnt 'kb_distill_activity' "$GATE")" -ge 3 ] && [ "$(cnt '--require-kb' "$GATE")" -ge 2 ]; then
    ok "FF-08 check-3file-gate 实现(kb_distill_activity 定义调用≥3 + --require-kb≥2)"
else
    bad "FF-08 check-3file-gate 实现" "got=($(cnt 'kb_distill_activity' "$GATE"),$(cnt '--require-kb' "$GATE")) expect=(>=3,>=2)"
fi
ge   "FF-09 ledger-append VALID_EVENTS 行含 kb_distill"   "$(cnt 'VALID_EVENTS=.*kb_distill' "$LEDGER")" 1

# ── templates 派发契约载体 ──
pair "FF-10 dispatch 模板 kb 行+findings 可写行双在位"      "$(cnt 'knowledge-brief: {plan_dir}' "$TPL")" "$(cnt '可写=仅追加' "$TPL")"

# ── SKILL.md 消费侧 ──
# [task-v171 核心瘦身] FF-11/12 重定向：合规清单表（C41/C42 行）随瘦身替换为 G1-G8 核心域合规表，Rule 62 摘要行
#   措辞演进为 '**Rule 62 四文件罗盘数据流转**' 指针 bullet（Rule 62 属核心在位规则，瘦身后仍在 SKILL 正文三处）。
#   现象：'^| C42 |' 与旧摘要行字面 'Rule 62（四文件罗盘' 均零命中，FF-11/12 恒 FAIL。
#   根因：合规清单 C 行体系整体退役（G 表仅核心域）；摘要 bullet 去掉全角括号措辞。
#   修法：FF-11 合规消费点→G 表四文件相关行（G5 findings 落盘+G6 回填门控，=2，Rule 62 消费面的现存合规载体）；
#     FF-12 摘要行→Critical Rules 指针段 'Rule 62 四文件罗盘数据流转' bullet =1；FF-13/14 不变（实测在位）。
eq   "FF-11 SKILL G 表四文件合规行=2(G5+G6)"                  "$(cnt '^| G[56] ' "$SKILL")" 2
eq   "FF-12 SKILL Rule 62 指针 bullet=1"                      "$(cnt 'Rule 62 四文件罗盘数据流转' "$SKILL")" 1
eq   "FF-13 SKILL 映射表蒸馏行=1"                          "$(cnt '主进程单写者蒸馏，Rule 62.3 双落盘' "$SKILL")" 1
ge   "FF-14 SKILL Rule 62 全文≥3(三落点联动)"              "$(cnt 'Rule 62' "$SKILL")" 3

# ── config.json 零新键（复合双条件，单列断言）──
PROPS="$(jq '.properties | length' "$CONFIG" 2>/dev/null || echo -1)"
NEWKEY="$(jq -r '.properties | keys[]' "$CONFIG" 2>/dev/null | grep -c -e 'four_file' -e 'kb_distill' -e 'contract_narrow' -e 'require_kb')"
NEWKEY="${NEWKEY:-0}"
if [ "$NEWKEY" -eq 0 ] && [ "$PROPS" -eq 42 ]; then
    ok "FF-15 config 零新键(相关字面=0 ∧ properties=42 时点基线)"
else
    bad "FF-15 config 零新键" "got=(newkey=$NEWKEY,props=$PROPS) expect=(0,42)"
fi

# ── 负断言：Rule 62 块范围内无 66.x（语境锚定，防裸全文误触）──
# [2026-10-09 task-v151 S4 钉值级联/D2 同法] 语境锚定由「60.6 起至文件尾」收窄为「Rule 62 区块」（awk: ### 62 起至下一 ### 止）
#   ——Rule 66 已合法落地于 62 块之后，tail-to-EOF 口径下 66.x 计数=6 必红；收窄后保留「62 块内无 66 入侵」负断言。
FF16_BLOCK="$(awk '/^### 62 /{f=1;next} /^### /{f=0} f' "$CR" 2>/dev/null)"
TAIL61="$(printf '%s\n' "$FF16_BLOCK" | grep -c -e '^66\.[0-9] ' || true)"
TAIL61="${TAIL61:-0}"
zero "FF-16 62 块范围内无 66.x(前向防线)"                    "$TAIL61"

# ── 脚本自身结构 ──
ge   "FF-17 SCRIPT_DIR 自定位行"                          "$(cnt 'SCRIPT_DIR=' "$0")" 1
pair "FF-18 头注释 What+Why 齐备"                          "$(cnt '^# What' "$0")" "$(cnt '^# Why' "$0")"

echo "Total: 18 PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
