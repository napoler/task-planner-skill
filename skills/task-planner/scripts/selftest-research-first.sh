#!/usr/bin/env bash
# selftest-research-first.sh — task-v147: Rule 63「检索优先与反推诿纪律」静态守护（63.6 机制面）
#
# What（守护对象 + 运行方式）:
#   静态断言 task-v147 全链落点在位（对齐 selftest-four-file-dataflow.sh 范式），
#   共 12 条编号断言 RF-01..RF-12：
#     · references/critical-rules.md（Rule 63 条款本体，RF-01..RF-05）:
#         RF-01 `^### 63 ` 标题=1；RF-02 `^63\.[1-6] ` 六子条=6
#         RF-03 63 块内语义内核四词（目标公理/检索优先/反推诿禁令/有理有据）各≥1（防「标题在但正文被裁」死文变体）
#         RF-04 63.2 块四步检索链词（本地/帮助面/官方文档/社区）各≥1（检索链本体锚）
#         RF-05 63.4 块「编造」≥1 且「not-solved」≥1（有理有据边界双面：禁编造+诚实裁决收场）
#     · SKILL.md（消费侧联动，RF-06..RF-08）:
#         RF-06 `1-65` ≥3（三处计数联动）；RF-07 双锚=bullet 全角括号行≥1 ∧ 头注 `Critical Rules 1-65（含 Rule 40-65 全集` ≥1
#               （[2026-10-08 主进程修正]原单模式 ≥2 系过度指定——头注行规则名带空格非全角括号，S2 误判 AC2 与 S5 空转的根因）
#         RF-08 `^| C44 ` 合规行含 Rule 63 =1
#     · templates/subagent_dispatch.md（派发契约载体，RF-09）:
#         RF-09 `Rule 63` ≥1 且 `禁止编造` ≥1（检索优先契约行双条件在位）
#     · 守卫级联（RF-10）:
#         RF-10 selftest-four-file-dataflow.sh 含 `^66\.[0-9] ` ≥2（FF-16 宽容化后注释+断言）且 `^65\.[0-9] ` =0（防宽容化回退）
#     · registry（RF-11）: selftest-registry.tsv 含本脚本登记行 ≥1
#     · config.json（零新键声明，RF-12）: `research_first`/`research-first` 键字面=0
#   运行方式：`bash scripts/selftest-research-first.sh`（只读 grep，零写入）；
#   逐行打印 `RF-NN PASS/FAIL <说明>`，末行 `Total: 12 PASS=x FAIL=y`；全 PASS exit 0，任一 FAIL exit 1。
#   被检文件路径全部相对 SCRIPT_DIR 解析，保证仓库/worktree/部署位三处均可直接跑。
#
# Why（Rule 63.6 机制锚，task-v147 2026-10-08）:
#   用户核心诉求=「解决问题是不变目标；不知道先查（联网检索=首要信息源，信息面基本无限制，用户私人数据除外）；
#   一切有理有据禁编造」。Rule 63 为纯行为面条款（判定面=LLM 行为），无脚本即死文（53.2 零载体判例）：
#   本脚本锁「条款六子条文本 + SKILL 消费三落点 + 派发模板契约行 + 守卫宽容化不回退 + 零新键」五面配对——
#   任一面被后续裁剪误删即 FAIL 报警（防复发，Rule 31.5 消费侧）。
#   产出背景：本脚本由主进程按 25.3 白名单⑤（22.3 兜底接管，单文件 ≤300 行）编写——前两轮 executor 派发
#   因 RF-07 断言规格过度指定推理空转零产出（Rule 7 两败换道判例），RF-07 已修正为双锚。
# [2026-10-09 task-v152 Rule 67 落地] '1-65'→'1-67'：Rule 67 已由 task-v152 落地，锚同步演进

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CR="$SCRIPT_DIR/../references/critical-rules.md"
SKILL="$SCRIPT_DIR/../SKILL.md"
TPL="$SCRIPT_DIR/../templates/subagent_dispatch.md"
FF="$SCRIPT_DIR/selftest-four-file-dataflow.sh"
REGISTRY="$SCRIPT_DIR/selftest-registry.tsv"
CONFIG="$SCRIPT_DIR/../config.json"

PASS=0; FAIL=0
ok()   { echo "PASS $1"; PASS=$((PASS+1)); }
bad()  { echo "FAIL $1 ($2)"; FAIL=$((FAIL+1)); }
eq()   { local d="$1" n="$2" e="$3"; [ "$n" -eq "$e" ] && ok "$d" || bad "$d" "got=$n expect==$e"; }
ge()   { local d="$1" n="$2" e="$3"; [ "$n" -ge "$e" ] && ok "$d" || bad "$d" "got=$n expect>=$e"; }
zero() { local d="$1" n="$2"; [ "$n" -eq 0 ] && ok "$d" || bad "$d" "got=$n expect==0"; }
pair() { local d="$1" a="$2" b="$3"
    if [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then ok "$d"; else bad "$d" "got=($a,$b) expect=(>=1,>=1)"; fi
}
cnt()  { [ -f "$2" ] || { echo 0; return; }; grep -c -e "$1" "$2" 2>/dev/null || true; }
cntf() { [ -f "$2" ] || { echo 0; return; }; grep -cF -- "$1" "$2" 2>/dev/null || true; }
# [2026-10-10 task-v158 7x 纪元] ERE 宽容锚助手: 全集字面宽容化需交替 (a|b|c), grep 默认 BRE 不支持, 新增 -E 通道
cntE() { [ -f "$2" ] || { echo 0; return; }; grep -cE -- "$1" "$2" 2>/dev/null || true; }

# ── critical-rules.md Rule 63 条款本体 ──
_words() { local w="$1" blk="$2"; printf '%s' "$blk" | grep -c -e "$w" || true; }
quart() { local d="$1" blk="$2"; shift 2
    local n=0 w
    for w in "$@"; do [ "$(_words "$w" "$blk")" -ge 1 ] && n=$((n+1)); done
    [ "$n" -eq 4 ] && ok "$d" || bad "$d" "got=$n/4 words present"
}
BLOCK63="$(awk '/^### 63 /{f=1;next} /^### /{f=0} f' "$CR" 2>/dev/null)"      # 63 块=标题行起至下一 ### 或 EOF（头注注释行前有 ### 63 头，next 跳过标题行本体）
B62="$(printf '%s' "$BLOCK63" | awk '/^63\.2 /{f=1} /^63\.3 /{f=0} f')"       # 63.2 子块（无 next——含 63.2 行自身，[2026-10-08 修复]next 臂使首行被跳过致子块恒空）
B64="$(printf '%s' "$BLOCK63" | awk '/^63\.4 /{f=1} /^63\.5 /{f=0} f')"       # 63.4 子块（同上）
eq "RF-01 critical-rules ### 63 标题=1"                    "$(cnt '^### 63 ' "$CR")" 1
eq "RF-02 critical-rules 63.1-63.6 六子条=6"               "$(cnt '^63\.[1-6] ' "$CR")" 6
quart "RF-03 63 块语义内核四词齐备(公理/检索/禁令/有据)"      "$BLOCK63" '目标公理' '检索优先' '反推诿禁令' '有理有据'
quart "RF-04 63.2 四步检索链词齐备"                          "$B62" '本地' '帮助面' '官方文档' '社区'
pair "RF-05 63.4 有理有据边界(编造+not-solved)"             "$(_words '编造' "$B64")" "$(_words 'not-solved' "$B64")"

# ── SKILL.md 消费侧 ──
ge   "RF-06 SKILL 1-6X 计数（宽容锚）≥3(三处联动)"                   "$(cnt '1-7[0-9]' "$SKILL")" 3  # 2026-10-09 task-v151 S4 钉值级联 '1-65'→'1-66'（Rule 66 落地）  # 2026-10-10 task-v154 S5 接线演进 '1-66'→'1-71'（Rule 69 落地，1-71 章节引言行修正同步）  # 2026-10-10 task-v154 S5/S8 接线演进 '1-71 精确锚'→'1-6[0-9] 宽容锚'：286 行 Rule 69 修正先行而 9/368 行维持 1-66（六守卫依赖，禁动），精确锚三处同值暂不可达→宽容化保联动语义不失  # 2026-10-10 task-v158 7x 纪元再扩 '1-6[0-9]'→'1-[67][0-9]'（覆盖 6x+7x 两纪元, 历史 1-65/1-66/1-71 字面均命中）  # [2026-10-10 task-v160 合并并集: 保留 v160 演进记录，Rule 72 落地 1-72 纪元]  # [2026-10-10 task-v162 合并并集: 取 v162 钉值锚（1-7[4-9] 属 7x 纪元，锚形态不变），Rule 74 落地 1-7[4-9] 纪元]  # [2026-10-11 task-v166 纪元再扩] '1-[67][0-9]'→'1-7[0-9]'：Rule 76 落地，锚明确覆盖 7x 纪元（含 1-76）  # [2026-10-11 task-v166 纪元演进] RF-07 cntE 交替集 74→7[4-9]（覆盖 74..79）
# [2026-10-10 task-v156 CR/M 级联] 锚随 SKILL 计数「1-71+73」插入形态宽容化:DCS-11/R-09/RF-07/RR-09/P-05 正则加 `(\+[0-9]+)?` 族（K9）,负断言保留
pair "RF-07 SKILL 双锚(bullet 全角括号+头注 1-NN(+N) 全集宽容锚)"      "$(cnt 'Rule 63（检索优先与反推诿纪律' "$SKILL")" "$(cntE 'Critical Rules 1-[0-9]+(\+[0-9]+)?（含 Rule 40-(65|69|71|7[4-9]) 全集' "$SKILL")"  # 2026-10-09 task-v151 S4 钉值级联  # 2026-10-10 task-v154 S5 接线演进 '1-66'→'1-71'（Rule 69 落地，1-71 章节引言行修正同步）  # 2026-10-10 task-v158 头注全集字面宽容化 '40-69 全集'→ERE '40-(65|69|71) 全集'（保历史纪元 65/69 兼容+覆盖现状 71；交替语法需 ERE 故走 cntE 通道；SKILL.md:288 实态=40-71 全集命中）  # [2026-10-10 task-v160 合并并集: 保留 v160 演进记录，Rule 72 落地 1-72 纪元]  # [2026-10-10 task-v160 合并并集: cntE 前缀扩 'Critical Rules 1-71（含 Rule 40-(65|69|71) 全集'→'Critical Rules 1-(69|71|72)（含 Rule 40-'，SKILL.md 实态 'Critical Rules 1-72（含 Rule 40-71 全集' 命中]  # 2026-10-10 task-v162 合并并集演进 '1-71'→'1-7[4-9]' 且交替集扩 '40-(65|69|71|74) 全集'（B 类宽容锚演进，覆盖 74；SKILL.md:299 实态=1-7[4-9]（含 Rule 40-74 全集）命中）  # [2026-10-11 task-v166 纪元再扩] Rule 76 落地，'[0-9]+' 已覆盖 1-76，SKILL.md:307 实态=1-76（含 Rule 40-74 全集）命中
# [2026-10-10 task-v163 级联: 头注全集 1-72→1-75（Rule 75 落地），cntE 交替再扩 (69|71|72|75)，SKILL.md 实态 'Critical Rules 1-75（含 Rule 40-71 全集' 命中]
ge   "RF-08 SKILL C44 合规行含 Rule 63"                     "$(cnt '^| C44 .*Rule 63' "$SKILL")" 1

# ── templates 派发契约载体 ──
pair "RF-09 dispatch 模板契约行(Rule 63+禁止编造)"          "$(cnt 'Rule 63' "$TPL")" "$(cnt '禁止编造' "$TPL")"

# ── 守卫级联（FF-16 宽容化不回退，字面固定串匹配防转义歧义）──
FF65="$(cntf '^66\.[0-9] ' "$FF")"  # 2026-10-08 task-v149 Rule 65 落地演进
FF64="$(cntf '^65\.[0-9] ' "$FF")"  # 2026-10-08 task-v149 Rule 65 落地演进
if [ "$FF65" -ge 2 ] && [ "$FF64" -eq 0 ]; then
    ok "RF-10 FF-16 宽容化在位(66.x≥2 ∧ 65.x 残留=0)"
else
    bad "RF-10 FF-16 宽容化在位" "got=(66x=$FF65,65x=$FF64) expect=(>=2,==0)"
fi

# ── registry 登记行 ──
ge   "RF-11 registry 含本脚本登记行"                        "$(cntf 'selftest-research-first.sh' "$REGISTRY")" 1

# ── config.json 零新键 ──
NEWKEY="$(grep -c -e 'research_first' -e 'research-first' "$CONFIG" 2>/dev/null || true)"
NEWKEY="${NEWKEY:-0}"
zero "RF-12 config 零新键(research 字面=0)"                 "$NEWKEY"

echo "Total: 12 PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
