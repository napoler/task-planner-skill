#!/usr/bin/env bash
# selftest-evidence-goal-gate.sh — task-v143: Rule 58「调研分析证据纪律与核心目标达成门控」静态守护（自写 58.7 机器面）
#
# What（守护对象 + 运行方式）:
#   静态断言 task-v143 全链落点在位（对齐 selftest-iteration-persistence.sh / selftest-execution-honesty.sh 范式），
#   共 21 条编号断言 EG-01..EG-21：
#     · critical-rules.md（Rule 58 条款本体，EG-01..EG-09）:
#         EG-01 `^### 58 ` 标题=1 且含 task-v143（来源任务锚）
#         EG-02 `^58\.[1-7] ` 七子条=7（58.1-58.7 主体行全在位）
#         EG-03 58.1 子条标题锚 =1（适用判定与证据面清单 evidence-surface inventory）
#         EG-04 58.2 子条标题锚 =1 + 语义内核「无对标取证」「禁裸豁免」各 ≥1（对标取证强制，防标题在正文被裁的死文变体）
#         EG-05 58.3 子条标题锚 =1 + 语义内核「反证检查」「推测（未验证）」各 ≥1（结论-证据锚定与反证）
#         EG-06 58.4 子条标题锚 =1 + 语义内核「[手段]」「[目标]」各 ≥1（手段/目标二分）
#         EG-07 58.5 子条标题锚 =1 + 三态词 solved/partial/not-solved 各 ≥1（58 块内计数，语境锚定）
#         EG-08 58.6 子条标题锚 =1 + 语义内核「绕弯」≥1（手段-目标因果链，用户 R5 绕弯禁令载体）
#         EG-09 58.7 机制锚 `58.7 **机制（零新 config 键` =1（脚本与条款双向引用锚）
#     · templates/task_plan.md（计划模板双区块载体，EG-10..EG-12）:
#         EG-10 「🔍 证据面清单」锚 ≥1 + 三基线面「① 自身样本」「② 对标样本」「③ 外部约束」各 ≥1
#               （58.1 载体——init 全任务注入的强制面，区块丢=每次任务的证据面清单无落点）
#         EG-11 「🎯 核心目标达成裁决」锚 ≥1 + 裁决三态行 ≥1（58.5 载体——终验三态裁决的回填出口）
#         EG-12 需求区 [手段]/[目标] 标注引导 ≥1（58.4 计划期标注载体）
#     · SKILL.md（执行期入口联动，EG-13..EG-15）:
#         EG-13 `Rule 58` 计数 ≥2（Critical Rules 摘要行 / C41 合规行——58.7 声明的 SKILL 消费侧即此两处）
#         EG-14 `^\| C41 ` 合规行 =1（58.7 声明的合规清单消费侧）
#         EG-15 摘要行含 `selftest-evidence-goal-gate.sh` 机器面指称（SKILL 侧机器面可发现性）
#     · scripts/init-session.sh（variant 路由兜底注入，EG-21 — CR F-1 修复载体）:
#         EG-21 `inject_evidence_goal_block()` 定义 =1 且主流程调用行 =1（variant 产物缺锚时兜底注入双区块，镜像 51.1 注入范式）
#     · 负断言（EG-16）:
#         EG-16 critical-rules.md 58 块尾上下文（末条 58.7 行起至文件尾）`^65\.[0-9] ` =0
#               （RC-15 前向防线语境锚定变体：63 号未合法登记不得顺手创建；随下一编号落地时同步演进锚——
#                task-v127「RC-15 负断言 ^50→^52 演进」同范式，口径扩展非回退）
#               [2026-10-08 task-v144 合并级联] 负断言对象 '^59\.' → '^63\.'：Rule 59 已由 task-v144 合法落地
#               [2026-10-08 task-v147 首代级联] '^63\.'→'^64\.'：Rule 63 已由 task-v147 落地（63.1-63.6）
#               [2026-10-08 task-v147 第二代级联] '^64\.'→'^65\.'：Rule 64 已由 task-v148 落地（64.1-64.6），防线前移至 65
#               （59.1-59.8 在位，旧 ^59 负断言过时）；61 预留未落地/62 已落地，63 为首个全未占用编号，
#               演进后 =0 保持防顺手创建语义不弱化
#     · config.json（零新键声明，EG-17/EG-18）:
#         EG-17 .properties 键数=40（沿用 tsv 末列既有口径，零新 config 键）
#         EG-18 `evidence[_-]goal` 键字面 =0（58.7 零新键声明的机器佐证，键名字面口径防他键子串误伤）
#     · 脚本自身（EG-19/EG-20）:
#         EG-19 SCRIPT_DIR 自定位行在位（仓库/worktree/三宿主部署位三处可跑结构锚）
#         EG-20 头注释 What+Why 齐备（Rule 45 双层注释）
#   运行方式：`bash scripts/selftest-evidence-goal-gate.sh`（只读 grep/jq，零写入）；
#   逐行打印 `EG-NN PASS/FAIL <说明>`，末行 `Total: N PASS=x FAIL=y`；全 PASS exit 0，任一 FAIL exit 1。
#   被检文件路径全部相对 SCRIPT_DIR 解析，保证仓库/worktree/三宿主部署位三处均可直接跑。
#
# Why（Rule 58.7 机制锚，task-v143 2026-10-07）:
#   用户 R1-R5 核心诉求=「调研/分析类任务必须先取证后结论（竞品分析没做不许下结论）+ 以核心问题解决状态裁决完成
#   （报告交了≠问题解决），确保后期任何任务不偏离用户核心任务、不绕弯消耗资源」。
#   Rule 58 是 LLM 行为面条款（证据面编制/对标取证/锚定反证/三态裁决均为行为义务，非机器触发，无需开关键），
#   若条款锚/模板双区块/SKILL 联动被后续裁剪误删，条款即变死文（53.2 零载体判例反向清账）；本脚本=条款死文探测器。
#   模板双区块（证据面清单+核心目标达成裁决）是 58.1/58.5 的任务级强制载体（init 全任务注入=每次任务强制携带，
#   对应用户 R4「确保后期执行任何任务」）——EG-10/EG-11 锁载体结构（区块标题+三基线面/三态语义内核），
#   权威定义在 critical-rules.md 58.1/58.5（EG-03/EG-07 锁文本），两处配对锁死「条款定义 + 任务载体」双面。
#   EG-16 语境锚定负断言（58 块尾后才扫 59.x，防裸全文匹配被子串误触，v127/RR-09 第 5 变体判例）。
#   只断言 Rule 58 新增锚、不触碰既有 selftest 断言行（防锚级联，Rule 36.5 纯增量）。
# 依赖：bash + grep；config.json 键数校验需 jq（缺失降级 python3，二者皆缺打 SKIPPED 不 FAIL，fail-open 非静默——
#       与 selftest-iteration-persistence.sh IP-15 / selftest-capability-persistence.sh CP-16 先例一致）。只读，零写入。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
TPL="$SKILL_ROOT/templates/task_plan.md"
CONFIG="$SKILL_ROOT/config.json"
SELF="$SCRIPT_DIR/selftest-evidence-goal-gate.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'EG-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'EG-%s FAIL %s\n' "$1" "$2"; }

# EG-01 critical-rules.md `^### 58 ` 标题行计数=1 且含 task-v143
# What：断言 Rule 58 章节标题唯一且可溯源。
# Why：标题行是章节识别锚；=1 防重复插入/误删；task-v143 是编号账本对账锚（Rule 20.6）。
n="$(grep -cE '^### 58 ' "$CRIT" || true)"
if [ "$n" -eq 1 ] && grep -E '^### 58 ' "$CRIT" | grep -q 'task-v143'; then
  ok 01 "critical-rules.md '### 58 ' 标题锚 =1 且含 task-v143"
else
  bad 01 "critical-rules.md '### 58 ' 计数=$n 或缺 task-v143 来源锚（应 =1+含来源）"
fi

# EG-02 critical-rules.md `^58\.[1-7] ` 七子条计数=7
# What：断言 58.1-58.7 七条子条主体行全在位。
# Why：七子条是 Rule 58 全部义务的唯一文本落点；缺任一 = 条款本体被裁剪（防改写时误删 58.x 段）。
n="$(grep -cE '^58\.[1-7] ' "$CRIT" || true)"
if [ "$n" -eq 7 ]; then ok 02 "critical-rules.md '58.x ' 七子条锚 =7"; else bad 02 "critical-rules.md '58.x ' 计数=$n（应 =7）"; fi

# EG-03 58.1 子条锚 =1（适用判定与证据面清单）
# What：断言 `58.1 **适用判定与证据面清单（evidence-surface inventory）**` 字面锚恰 1 处。
# Why：58.1 是证据面清单义务的权威定义点（EG-10 模板载体的上位定义）——锚丢=清单义务失根（体系脱根探测）。
n="$(grep -cF '58.1 **适用判定与证据面清单（evidence-surface inventory）**' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 03 "critical-rules.md 58.1「适用判定与证据面清单」=1"; else bad 03 "critical-rules.md 58.1 锚命中=$n（应 =1）"; fi

# EG-04 58.2 子条锚 =1 + 语义内核（无对标取证 / 禁裸豁免）
# What：断言 58.2 标题锚恰 1 处，且「无对标取证」「禁裸豁免」语义短语各 ≥1。
# Why：58.2 是用户 R2 判例（竞品没做就下结论）的直接禁令载体——标题在而语义短语被裁 = 死文变体（IP-08 同范式）；
#      「无对标取证=无据结论」是 58.2 的核心裁决语，「禁裸豁免」防豁免通道被滥用掏空条款。
n="$(grep -cF '58.2 **对标取证强制（benchmark-evidence mandate）**' "$CRIT" || true)"
a="$(grep -cF '无对标取证' "$CRIT" || true)"
b="$(grep -cF '禁裸豁免' "$CRIT" || true)"
if [ "$n" -eq 1 ] && [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then
  ok 04 "critical-rules.md 58.2 锚=1 + 语义内核 无对标取证=$a / 禁裸豁免=$b（各 ≥1）"
else
  bad 04 "critical-rules.md 58.2 锚命中=$n（应 =1）/ 无对标取证=$a / 禁裸豁免=$b（各应 ≥1，语义内核被裁）"
fi

# EG-05 58.3 子条锚 =1 + 语义内核（反证检查 / 推测（未验证））
# What：断言 58.3 标题锚恰 1 处，且「反证检查」「推测（未验证）」各 ≥1。
# Why：58.3 是用户 R3「有理有据/真实性」的条款载体——反证检查是结论定稿前置义务的语义内核，
#      「推测（未验证）」是无据判断的唯一合法标注形态（43.1 口径），两者丢失 = 锚定条款退化。
n="$(grep -cF '58.3 **结论-证据锚定与反证检查（claim-evidence anchoring）**' "$CRIT" || true)"
a="$(grep -cF '反证检查' "$CRIT" || true)"
b="$(grep -cF '推测（未验证）' "$CRIT" || true)"
if [ "$n" -eq 1 ] && [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then
  ok 05 "critical-rules.md 58.3 锚=1 + 语义内核 反证检查=$a / 推测（未验证）=$b（各 ≥1）"
else
  bad 05 "critical-rules.md 58.3 锚命中=$n（应 =1）/ 反证检查=$a / 推测（未验证）=$b（各应 ≥1）"
fi

# EG-06 58.4 子条锚 =1 + 语义内核（[手段] / [目标]）
# What：断言 58.4 标题锚恰 1 处，且「[手段]」「[目标]」标注字面各 ≥1。
# Why：58.4 是手段/目标二分的权威定义点——「[目标]」标注是 58.5 裁决门的触发条件（无标注=裁决门永不触发，
#      条款被架空）；标注字面是 58.4→58.5 链路的机器可检接口。
n="$(grep -cF '58.4 **手段/目标二分与解决判据（means-goal bifurcation）**' "$CRIT" || true)"
a="$(grep -cF '[手段]' "$CRIT" || true)"
b="$(grep -cF '[目标]' "$CRIT" || true)"
if [ "$n" -eq 1 ] && [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then
  ok 06 "critical-rules.md 58.4 锚=1 + 标注字面 [手段]=$a / [目标]=$b（各 ≥1）"
else
  bad 06 "critical-rules.md 58.4 锚命中=$n（应 =1）/ [手段]=$a / [目标]=$b（各应 ≥1，二分标注面被裁）"
fi

# EG-07 58.5 子条锚 =1 + 三态词（solved / partial / not-solved 各 ≥1，58 块内计数）
# What：断言 58.5 标题锚恰 1 处，且三态词在 Rule 58 块上下文（`### 58 ` 标题行起至文件尾）内各 ≥1。
# Why：58.5 是用户 R2/R5「不解决问题就停」缺陷的完成裁决载体——三态是裁决语义的最小完备集；
#      任一态词丢失 = 裁决枚举不完整（partial/not-solved 消失则「未解决禁 COMPLETE」无从判定）。
#      [CR F-4 2026-10-07] 块内语境锚定（非全文计数）：三态词全文计数会被 51.x 等既有条款的
#      partial 字样稀释，58.5 正文被裁时头行残留字面仍可假 PASS——块内计数才是死文变体探测
#      （与 EG-16 语境锚定同范式）。
n="$(grep -cF '58.5 **完成裁决门（goal-achievement verdict gate）**' "$CRIT" || true)"
rule58head="$(grep -nE '^### 58 ' "$CRIT" | head -1 | cut -d: -f1 || true)"
ctx58="$(tail -n +"${rule58head:-1}" "$CRIT")"
a="$(printf '%s\n' "$ctx58" | grep -cF 'solved' || true)"
b="$(printf '%s\n' "$ctx58" | grep -cF 'partial' || true)"
c="$(printf '%s\n' "$ctx58" | grep -cF 'not-solved' || true)"
if [ "$n" -eq 1 ] && [ "$a" -ge 1 ] && [ "$b" -ge 1 ] && [ "$c" -ge 1 ]; then
  ok 07 "critical-rules.md 58.5 锚=1 + 58 块内三态词 solved=$a / partial=$b / not-solved=$c（各 ≥1）"
else
  bad 07 "critical-rules.md 58.5 锚命中=$n（应 =1）/ 58 块内三态词 solved=$a / partial=$b / not-solved=$c（各应 ≥1）"
fi

# EG-08 58.6 子条锚 =1 + 语义内核（绕弯）
# What：断言 58.6 标题锚恰 1 处，且「绕弯」≥1。
# Why：58.6 是用户 R5「别乱七八糟绕弯消耗资源」的直接条款载体——「绕弯活动禁执行」是因果链义务的裁决语。
n="$(grep -cF '58.6 **手段-目标因果链（means-goal causal chain）**' "$CRIT" || true)"
a="$(grep -cF '绕弯' "$CRIT" || true)"
if [ "$n" -eq 1 ] && [ "$a" -ge 1 ]; then
  ok 08 "critical-rules.md 58.6 锚=1 + 「绕弯」=$a（≥1）"
else
  bad 08 "critical-rules.md 58.6 锚命中=$n（应 =1）/「绕弯」=$a（应 ≥1，R5 载体被裁）"
fi

# EG-09 58.7 机制锚 =1（脚本与条款双向引用）
# What：断言 `58.7 **机制（零新 config 键` 前缀锚恰 1 处。
# Why：58.7 是本脚本自身存在的条款依据（机器面=selftest 静态守护声明）——锚丢=守卫自引用失效。
n="$(grep -cF '58.7 **机制（零新 config 键' "$CRIT" || true)"
if [ "$n" -eq 1 ]; then ok 09 "critical-rules.md 58.7「机制（零新 config 键」=1"; else bad 09 "critical-rules.md 58.7 锚命中=$n（应 =1）"; fi

# EG-10 模板「🔍 证据面清单」区块 + 三基线面语义内核
# What：断言 templates/task_plan.md 含「证据面清单（Rule 58.1」区块标题 ≥1，且「① 自身样本」「② 对标样本」「③ 外部约束」各 ≥1。
# Why：模板区块是 58.1 的任务级强制载体（init 全任务注入=每次任务携带，对应用户 R4）——
#      区块丢=证据面清单义务无落点；三基线面是清单的最小完备集（对标面缺失=58.2 被架空）。
a="$(grep -cF '证据面清单（Rule 58.1' "$TPL" || true)"
b="$(grep -cF '自身样本' "$TPL" || true)"
c="$(grep -cF '对标样本' "$TPL" || true)"
d="$(grep -cF '外部约束' "$TPL" || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ] && [ "$c" -ge 1 ] && [ "$d" -ge 1 ]; then
  ok 10 "模板「证据面清单」区块 ≥1 + 三基线面 自身=$b / 对标=$c / 外部=$d（各 ≥1）"
else
  bad 10 "模板证据面清单区块=$a（应 ≥1）/ 三基线面 自身=$b / 对标=$c / 外部=$d（各应 ≥1，载体缺失）"
fi

# EG-11 模板「🎯 核心目标达成裁决」区块 + 三态裁决行
# What：断言模板含「核心目标达成裁决（Rule 58.5」区块标题 ≥1，且裁决三态行（solved/partial/not-solved 同行）≥1。
# Why：模板裁决区块是 58.5 的终验回填出口——区块丢=三态裁决无落点（58.5③ 义务空转）。
a="$(grep -cF '核心目标达成裁决（Rule 58.5' "$TPL" || true)"
b="$(grep -cE 'solved.*/ *.partial.*/ *.*not-solved' "$TPL" || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then
  ok 11 "模板「核心目标达成裁决」区块=$a + 三态裁决行=$b（各 ≥1）"
else
  bad 11 "模板裁决区块=$a（应 ≥1）/ 三态裁决行=$b（应 ≥1，58.5 回填出口丢失）"
fi

# EG-12 模板需求区 [手段]/[目标] 标注引导 ≥1
# What：断言模板 R 行区含 [手段]/[目标] 标注引导 ≥1。
# Why：58.4 的计划期标注载体——无引导则计划期漏标 [目标]，58.5 裁决门永不触发（58.4→58.5 链路断）。
n="$(grep -cF '[手段]/[目标]' "$TPL" || true)"
if [ "$n" -ge 1 ]; then ok 12 "模板需求区 [手段]/[目标] 标注引导=$n（≥1）"; else bad 12 "模板 [手段]/[目标] 引导=$n（应 ≥1，58.4 载体缺失）"; fi

# EG-13 SKILL.md `Rule 58` 计数 ≥2（Critical Rules 摘要行 / C41 合规行）
# What：断言 SKILL.md 中 `Rule 58` 出现 ≥2 次。
# Why：SKILL.md 是执行期入口；58.7 声明的 SKILL 消费侧=Critical Rules 摘要行 + 合规清单 C41 两处
#      （第三载体=计划模板双区块，位于 templates/task_plan.md 由 EG-10/11 锁定，不在 SKILL.md 计数面）——
#      条款只在 critical-rules.md 而 SKILL 无联动 = 消费侧不可发现（53.2 条款死文反例）；≥2 与声明口径对齐。
n="$(grep -c 'Rule 58' "$SKILLMD" || true)"
if [ "$n" -ge 2 ]; then ok 13 "SKILL.md 'Rule 58' 计数 $n ≥2"; else bad 13 "SKILL.md 'Rule 58' 计数=$n（应 ≥2，联动面缺）"; fi

# EG-14 SKILL.md `^\| C41 ` 合规行 =1
# What：断言合规清单 C41 行恰 1 处。
# Why：58.7 声明消费侧=合规清单 C41（调研分析证据与目标裁决自查项）；丢行=合规面与 58 子条脱钩；=1 锁唯一落点。
n="$(grep -cE '^\| C41 ' "$SKILLMD" || true)"
if [ "$n" -eq 1 ]; then ok 14 "SKILL.md 合规行 C41 =1"; else bad 14 "SKILL.md C41 行命中=$n（应 =1）"; fi

# EG-15 SKILL.md 摘要行含机器面指称 selftest-evidence-goal-gate.sh
# What：断言 SKILL.md 含 `selftest-evidence-goal-gate.sh` ≥1。
# Why：SKILL 侧机器面可发现性——摘要/C41 声明的守卫脚本名必须在 SKILL.md 可检索（守卫三件套联动面）。
n="$(grep -cF 'selftest-evidence-goal-gate.sh' "$SKILLMD" || true)"
if [ "$n" -ge 1 ]; then ok 15 "SKILL.md 机器面指称 selftest-evidence-goal-gate.sh=$n（≥1）"; else bad 15 "SKILL.md 机器面指称=$n（应 ≥1）"; fi

# EG-16 负断言（语境锚定）：critical-rules.md 58 块尾上下文（末条 58.7 行起至文件尾）`^65\.[0-9] ` =0
# What：断言 58.7 之后不存在 63.x 子条行。
# Why：RC-15 前向防线（防下一编号被顺手创建）的语境锚定实现——扫「58 块之后」而非全文（v127/RR-09 第 5 变体判例）；
#      下一未占用编号合法落地时须同步演进本锚（task-v127「RC-15 负断言 ^50→^52 演进」同范式，口径扩展非回退）。
#      [2026-10-08 task-v144 合并级联] '^59\.' → '^63\.'：Rule 59 已合法落地 59.1-59.8（本仓在位），
#      [2026-10-08 task-v147 首代级联] '^63\.'→'^64\.'：Rule 63 已由 task-v147 落地（63.1-63.6 实测）；
#      旧 ^59 负断言实测 =8 FAIL；61 预留未落地、62 已落地，63 为首个全未占用编号，演进防误报且不弱化防线。
last58line="$(grep -nE '^58\.[1-7] ' "$CRIT" | tail -1 | cut -d: -f1 || true)"
if [ -z "$last58line" ]; then
  bad 16 "critical-rules.md 未找到 58.x 末条行（块缺失，负断言无法语境锚定）"
else
  tailctx="$(tail -n +"$last58line" "$CRIT")"
  n="$(printf '%s\n' "$tailctx" | grep -cE '^65\.[0-9] ' || true)"
  if [ "$n" -eq 0 ]; then ok 16 "critical-rules.md 58 块尾上下文（L${last58line}起）「63.x」=0（RC-15 前向防线；task-v144 级联 59.1-59.8 已合法落地）"; else bad 16 "critical-rules.md 58 块尾「63.x」=$n（应 =0，63 号被顺手创建）"; fi
fi

# EG-17 config.json .properties 键数 ≥40（零新 config 键声明锚 — 宽容下界口径）
# What：断言 config.json 顶层 properties 键数 ≥40（v142 前基线 40）。
# Why：58.7 承诺「零新 config 键」——本任务不加键。精确值断言（=40）在 master 已因 task-v142 遗留 2 个
#      periodic_review 孤儿键（40→42，其条款在后续合并中不在现行 critical-rules.md）而漂移 FAIL
#      （selftest-iteration-persistence.sh IP-15 在 master 现况 FAIL，属既有基线漂移面，已登记 deferred）；
#      本脚本不引入第二个精确值锚源与 IP-15 打架（双锚漂移=维护负担），故取宽容下界 ≥40 防基础键误删，
#      零新键义务由 EG-18 键名字面负断言（evidence[_-]goal=0）精确承载。
if command -v jq >/dev/null 2>&1; then
  keys="$(jq -r '.properties|keys|length' "$CONFIG" 2>/dev/null || true)"
  if [ "${keys:-0}" -ge 40 ]; then ok 17 "config.json properties 键数 ${keys} ≥40（下界守卫；零新键由 EG-18 键名断言承载）"; else bad 17 "config.json properties 键数=$keys（应 ≥40，基础键被误删）"; fi
elif command -v python3 >/dev/null 2>&1; then
  keys="$(python3 -c "import json;print(len(json.load(open('$CONFIG'))['properties']))" 2>/dev/null || true)"
  if [ "${keys:-0}" -ge 40 ]; then ok 17 "config.json properties 键数 ${keys} ≥40（python3 校验）"; else bad 17 "config.json properties 键数=$keys（应 ≥40）"; fi
else
  printf 'EG-17 SKIPPED jq/python3 均缺失，无法校验 config.json 键数（安装任一后重跑）\n'
fi

# EG-18 零新键负断言：config.json 无 `evidence` 前缀族键字面（=0）
# What：断言 config.json 不含 evidence_goal / evidence_surface / evidence_verdict 等 evidence 前缀族字面。
# Why：58.7 声明「零新 config 键」——若后续有人给 58 加开关键即范式回退；[CR F-5 2026-10-07]
#      键名字面从单键扩为前缀族（goal/surface/verdict 候选命名面），防「另起键名绕过单键负断言」；
#      前缀族口径仍限定 evidence 词根，防未来合法他键子串误伤（v127 判例）。
n="$(grep -cE 'evidence[_-](goal|surface|verdict)' "$CONFIG" || true)"
if [ "$n" -eq 0 ]; then ok 18 "config.json 零新键：「evidence[_-](goal|surface|verdict)」命中=0（58.7 零 config 键声明成立）"; else bad 18 "config.json「evidence[_-](goal|surface|verdict)」命中=$n（应 =0，58.7 零新键声明被破）"; fi

# EG-19 脚本自身 SCRIPT_DIR 自定位行在位（三处可跑结构锚）
# What：断言本脚本含 SCRIPT_DIR 自定位 idiom。
# Why：仓库/worktree/三宿主部署位路径深度不同；自定位行是相对解析的根——被硬编码路径替换则三处仅一处可跑。
if grep -qE 'SCRIPT_DIR="\$\(cd "\$\(dirname ' "$SELF"; then
  ok 19 "脚本 SCRIPT_DIR 自定位行在位"
else
  bad 19 "脚本缺 SCRIPT_DIR 自定位行（硬编码路径风险）"
fi

# EG-20 脚本头注释 What+Why 齐备（Rule 45 双层注释）
# What：断言本脚本头部注释含 `# What` 与 `# Why` 两个标记。
# Why：Rule 45 双层注释要求（What=做什么/Why=为何这样做）；守护脚本自身也须示范该纪律。
if grep -q '# What' "$SELF" && grep -q '# Why' "$SELF"; then
  ok 20 "脚本头注释 What+Why 齐备（Rule 45）"
else
  bad 20 "脚本头注释缺 What 或 Why（Rule 45）"
fi

# EG-21 init-session.sh 兜底注入在位（variant 路由覆盖 — CR F-1 修复载体）
# What：断言 init-session.sh 含 `inject_evidence_goal_block()` 函数定义 =1 且主流程调用行 =1。
# Why：variant 路由任务（cp variant/<x>-type.md 直拷，含 research-type——Rule 58 首要覆盖面）产物
#      不含主模板双区块；无兜底注入则 58.1/58.7「init 全任务注入」声明在 variant 路径为死文
#      （51.1 注入兜底 task-v131 先例同构）；定义与调用双向锁定（只定义不调用=假接线）。
n="$(grep -cE '^inject_evidence_goal_block\(\) \{' "$SKILL_ROOT/scripts/init-session.sh" || true)"
c="$(grep -cE '^inject_evidence_goal_block$' "$SKILL_ROOT/scripts/init-session.sh" || true)"
if [ "$n" -eq 1 ] && [ "$c" -eq 1 ]; then
  ok 21 "init-session.sh inject_evidence_goal_block 定义=1 + 调用=1（variant 兜底在位）"
else
  bad 21 "init-session.sh inject_evidence_goal_block 定义=$n（应 =1）/ 调用=$c（应 =1，兜底缺失或假接线）"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
