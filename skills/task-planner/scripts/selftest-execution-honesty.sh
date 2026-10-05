#!/usr/bin/env bash
# selftest-execution-honesty.sh — task-v136 S4: Rule 54 执行诚实性与即时执行纪律静态守护（54.6 机制定稿指定的机器面脚本）
#
# ① What（做什么）: 静态断言 task-v136 全链落点在位（对齐 selftest-veto.sh / selftest-root-resolution.sh 范式）——
#    · critical-rules.md: Rule 54 七子条（54.0-54.6）逐条行首标题字面锚（EH-01..EH-07，各 =1 锁唯一落点）
#      + 54.0 有依据原则/54.5 落盘义务/54.6 零新键三关键短语（EH-08，各 ≥1）
#      + 负断言：54 块尾上下文（末条 54.6 行起至文件尾）无 "55.x" 子条被顺手创建（EH-13，语境锚定，RC-15 前移防线呼应）
#    · SKILL.md: 摘要行「Rule 54」≥1（实际 3 落点：C38 行/摘要 bullet/References 行）+ C38 合规行 =1 + 索引括注「Rule 40-54」=1（EH-09）
#    · 模板面: delivery-summary.md「54.1」≥1 且「54.4」≥1（EH-10，真实进展对照行双锚）
#    · companion 面: image/video-generation-executor.md「Rule 54 消费」指针行各 =1（EH-11/EH-12）
#    · config 面: 零新键负断言「"execution_honesty」=0（EH-14，54.6 零新 config 键声明的机器佐证）
#    共 EH-01..EH-14 十四个编号断言，逐条 grep 字面锚 + 期望命中数比对。
# ② Why（为什么）: 用户 R4「确保所有的东西都都有依据」+ R5「数据及时落盘」的机器守护面——
#    Rule 54 是 LLM 行为面条款（判定靠 LLM 自查），若 54 条款锚/SKILL 联动/模板消费入口被后续裁剪误删，
#    条款即变死文（51.1 零载体判例反向清账）；本脚本=条款死文探测器，锚丢即 FAIL 报警。
#    EH-13 语境锚定负断言（54 块尾后才扫 55.x，防裸全文匹配被子串误触，v127/RR-09 第 5 变体判例）；
#    EH-14 零新键负断言锁 54.6「与 43.4/49.5/53.5 同范式零 config 键」声明不回退为开关键式实现。
# ③ When（何时跑）: 任何改动下列文件时由 selftest 批跑（check-complete / 全量回归）触发——
#    critical-rules.md 54.x 段、SKILL.md C38 行/摘要 bullet/索引括注、templates/delivery-summary.md、
#    companion/agents/{image,video}-generation-executor.md、config.json；selftest-registry.tsv 登记行由后续 S-unit 追加
#    （root-resolution 同先例：新增未登记脚本→registry T02 FAIL，登记必须紧跟落地勿悬挂）。
# ④ How（如何判）: PASS/FAIL 计数 + 末行 `Total: N PASS=x FAIL=y`（供 Total 行求和消费，格式与
#    selftest-root-resolution.sh 同构）；全 PASS exit 0，任一 FAIL exit 1。
#    断言口径：正断言一律 `grep -cF` 固定字符串计数（`|| true` 兜 grep -c 零命中 exit 1 在 set -u 下的误传播）；
#    子条标题锚 =1（唯一落点，重复落点破坏 grep -c 口径故锁死）；关键短语/多落点锚用 ≥1（合法复现）；负断言命中必须 =0。
# 依赖：bash + grep + tail（零 jq 依赖，零 config 面——54.6 零新 config 键范式）；只读，零写入。
# 备注：本单元 scope 仅新建本脚本 1 文件（禁触碰其他文件，含 selftest-registry.tsv——登记归后续 S-unit）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
TPL="$SKILL_ROOT/templates/delivery-summary.md"
IMG="$SKILL_ROOT/companion/agents/image-generation-executor.md"
VID="$SKILL_ROOT/companion/agents/video-generation-executor.md"
CONFIG="$SKILL_ROOT/config.json"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'EH-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'EH-%s FAIL %s\n' "$1" "$2"; }

# EH-01 54.0 子条锚 `grep -cF '54.0 **有依据原则（evidence-first reporting）**'` =1
# Why: 54.0 有依据原则总则（R4 需求锚）是整条 Rule 54 的语义根——总则锚丢=子条 54.1-54.5 失去上位条款依据（体系脱根探测）。
n="$(grep -cF '54.0 **有依据原则（evidence-first reporting）**' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 01 "critical-rules.md 54.0「有依据原则」=1"; else bad 01 "critical-rules.md 54.0 锚命中=$n（应 =1）"; fi

# EH-02 54.1 子条锚 `grep -cF '54.1 **就绪语义（ready-state honesty）**'` =1
# Why: 54.1 是 F1 就绪语义越界 + F4 资源状态无验证断言的唯一新载体（knowledge-brief §2 差异面定稿）——锚丢=两缺陷面重回无条款状态。
n="$(grep -cF '54.1 **就绪语义（ready-state honesty）**' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 02 "critical-rules.md 54.1「就绪语义」=1"; else bad 02 "critical-rules.md 54.1 锚命中=$n（应 =1）"; fi

# EH-03 54.2 子条锚 `grep -cF '54.2 **阻塞影响矩阵（blocker impact matrix）**'` =1
# Why: 54.2 阻塞传播纪律是 F2 连带推迟的直接拦截面（与 49.2 lane 推进互补非替代）——锚丢=「单资源阻塞推全量」禁令消失。
n="$(grep -cF '54.2 **阻塞影响矩阵（blocker impact matrix）**' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 03 "critical-rules.md 54.2「阻塞影响矩阵」=1"; else bad 03 "critical-rules.md 54.2 锚命中=$n（应 =1）"; fi

# EH-04 54.3 子条锚 `grep -cF '54.3 **仪式性进展禁令（ceremonial progress ban）**'` =1
# Why: 54.3 是 F3 仪式动作冒充里程碑的唯一禁令载体（差异面=动作包装 vs 43.6 声称面）——锚丢=仪式进展重新可被呈报为里程碑。
n="$(grep -cF '54.3 **仪式性进展禁令（ceremonial progress ban）**' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 04 "critical-rules.md 54.3「仪式性进展禁令」=1"; else bad 04 "critical-rules.md 54.3 锚命中=$n（应 =1）"; fi

# EH-05 54.4 子条锚 `grep -cF '54.4 **推迟举证四要素（deferral evidence）**'` =1
# Why: 54.4 推迟举证是 F2「无举证整体押后」的决策面拦截（四要素缺一禁推迟）——锚丢=推迟决策退回无举证放行。
n="$(grep -cF '54.4 **推迟举证四要素（deferral evidence）**' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 05 "critical-rules.md 54.4「推迟举证四要素」=1"; else bad 05 "critical-rules.md 54.4 锚命中=$n（应 =1）"; fi

# EH-06 54.5 子条锚 `grep -cF '54.5 **决策依据落盘与引用义务（decision-basis persistence）**'` =1
# Why: 54.5 是用户 R5「数据及时落盘」的直接载体（查询数据先落盘后引用落盘锚，F5 前置使能面）——锚丢=R5 决策依据审计链断裂。
n="$(grep -cF '54.5 **决策依据落盘与引用义务（decision-basis persistence）**' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 06 "critical-rules.md 54.5「决策依据落盘」=1"; else bad 06 "critical-rules.md 54.5 锚命中=$n（应 =1）"; fi

# EH-07 54.6 子条锚 `grep -cF '54.6 **机制（零新 config 键'` =1（标题前缀锚，标题尾部含 Why 说明故锁前缀不锁全行）
# Why: 54.6 机制条是本脚本自身存在的条款依据（机器面=selftest 静态守护声明）——锚丢=脚本与条款双向引用断裂（守卫自引用失效）。
n="$(grep -cF '54.6 **机制（零新 config 键' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 07 "critical-rules.md 54.6「机制（零新 config 键」=1"; else bad 07 "critical-rules.md 54.6 锚命中=$n（应 =1）"; fi

# EH-08 三关键短语锚：54.0 有依据原则「evidence-first reporting」≥1 / 54.5 落盘义务「decision-basis persistence」≥1 / 54.6 零新键「零新 config 键」≥1
# Why: 子条标题锚（EH-01..07）只锁编号+标题字面，关键短语是各子条语义内核——防「标题还在但正文被裁空壳」的语义漂移（死文变体探测）。
a="$(grep -cF 'evidence-first reporting' "$CRIT" || true)"
b="$(grep -cF 'decision-basis persistence' "$CRIT" || true)"
c="$(grep -cF '零新 config 键' "$CRIT" || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ] && [ "$c" -ge 1 ]; then
  ok 08 "critical-rules.md 关键短语 evidence-first=$a≥1 / decision-basis=$b≥1 / 零新 config 键=$c≥1"
else
  bad 08 "critical-rules.md 关键短语 evidence-first=$a / decision-basis=$b / 零新 config 键=$c（各应 ≥1，语义内核被裁）"
fi

# EH-09 SKILL.md 联动面：「Rule 54」≥1（C38 行/摘要 bullet/References 行三落点）且「C38」=1 且「Rule 40-54」=1（索引括注）
# Why: SKILL.md 是 LLM 读条款的入口索引（RC-09/RR-07 同范式）——「Rule 54」漏联动=摘要与条款脱钩（条款扩到 54 但索引停摆）；
# C38 行=Rule 54 的合规清单消费点（丢行=合规面与 54 子条脱钩）；「Rule 40-54」=索引行全集括注（RR-16 同先例，级联漏改面）；
# C38/40-54 各 =1 锁唯一落点（重复落点=段落复制漂移）。
x="$(grep -cF 'Rule 54' "$SKILLMD" || true)"
y="$(grep -cF 'C38' "$SKILLMD" || true)"
z="$(grep -cF 'Rule 40-54' "$SKILLMD" || true)"
if [ "$x" -ge 1 ] && [ "$y" -eq 1 ] && [ "$z" -eq 1 ]; then
  ok 09 "SKILL.md Rule 54=$x≥1 且 C38 行=1 且索引括注「Rule 40-54」=1"
else
  bad 09 "SKILL.md Rule 54=$x（应 ≥1）或 C38=$y（应 =1）或「Rule 40-54」=$z（应 =1，级联漏改）"
fi

# EH-10 模板面：delivery-summary.md「54.1」≥1 且「54.4」≥1（真实进展对照行双锚）
# Why: 模板是 54 条款的消费者出口（交付总结必须按 54.1③ 出条目级真实对照+54.4 四要素举证）——锚丢=交付面脱钩 54（汇报面重回无对照包装）。
# 语境锚「54.1」锁 54.1③ 静默子句的对照义务、「54.4」锁推迟举证义务，双锚缺一=对照行被裁半。
n="$(grep -cF '54.1' "$TPL" || true)"
m="$(grep -cF '54.4' "$TPL" || true)"
if [ "$n" -ge 1 ] && [ "$m" -ge 1 ]; then
  ok 10 "delivery-summary.md「54.1」=$n≥1 且「54.4」=$m≥1（真实进展对照行双锚）"
else
  bad 10 "delivery-summary.md「54.1」=$n 或「54.4」=$m（各应 ≥1，对照行被裁）"
fi

# EH-11 companion image 面：image-generation-executor.md「Rule 54」=1
# Why: companion 执行体指针行（54.1 就绪语义+54.2 阻塞矩阵消费）是 54 在媒体执行面的入口——=1 锁唯一指针（多落点=双权威源漂移，丢=执行体脱钩 54）。
n="$(grep -cF 'Rule 54' "$IMG" || true)"
if [ "$n" -eq 1 ]; then ok 11 "image-generation-executor.md「Rule 54」指针行=1"; else bad 11 "image-generation-executor.md「Rule 54」命中=$n（应 =1）"; fi

# EH-12 companion video 面：video-generation-executor.md「Rule 54」=1
# Why: 同 EH-11，video 执行体对称面——两执行体任一脱钩=该执行面汇报/阻塞行为不受 54 约束（执行面部分失守）。
n="$(grep -cF 'Rule 54' "$VID" || true)"
if [ "$n" -eq 1 ]; then ok 12 "video-generation-executor.md「Rule 54」指针行=1"; else bad 12 "video-generation-executor.md「Rule 54」命中=$n（应 =1）"; fi

# EH-13 负断言（语境锚定）：critical-rules.md 54 块尾上下文（末条 54.6 行起至文件尾）「55.x」=0
# Why: RC-15 前移防线（'^55.'=0 防 55 号误占）的呼应面——扫「54 块之后」而非全文：裸全文匹配 "55.[0-9]" 会被子串误触
# （v127/RR-09 第 5 变体判例：负断言须语境锚定）；块尾后出现 55.x = Rule 55 未被本任务合法创建却被顺手写入（54 块编辑时越界扩号探测）。
last54line="$(grep -nE '^54\.[0-6] ' "$CRIT" | tail -1 | cut -d: -f1 || true)"
if [ -z "$last54line" ]; then
  bad 13 "critical-rules.md 未找到 54.x 末条行（块缺失，负断言无法语境锚定）"
else
  m="$(tail -n +"$last54line" "$CRIT" | grep -cE '55\.[0-9]' || true)"
  if [ "$m" -eq 0 ]; then
    ok 13 "critical-rules.md 54 块尾上下文（L${last54line}起）「55.x」=0（RC-15 前移防线呼应，55 号未被顺手创建）"
  else
    bad 13 "critical-rules.md 54 块尾上下文「55.x」命中=$m（应 =0，55 号被顺手写入）"
  fi
fi

# EH-14 零新键负断言：config.json「"execution_honesty」=0
# Why: 54.6 声明「零新 config 键（与 43.4/49.5/53.5 同范式）」——若后续有人给 54 加开关键（execution_honesty 或同义键），
# 即范式回退为 config 开关式（判定面=LLM 行为无需机器开关键）；负断言锁声明与 config 面一致。口径锁定键名字面前缀（「execution_honesty」），
# 非全 file "honesty" 裸匹配（防未来合法他键子串误伤——v127 判例）。
n="$(grep -c '"execution_honesty' "$CONFIG" || true)"
if [ "$n" -eq 0 ]; then
  ok 14 "config.json 零新键：「\"execution_honesty」命中=0（54.6 零 config 键声明成立）"
else
  bad 14 "config.json「\"execution_honesty」命中=$n（应 =0，54.6 零新键声明被破）"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
