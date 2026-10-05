#!/usr/bin/env bash
# selftest-agent-coverage.sh — task-v125 S6: Rule 52 执行体专业化优先 + 覆盖矩阵静态守护（AC-01..09）
# 范式对齐 selftest-media-agents.sh（SCRIPT_DIR/SKILL_ROOT 定位、ok()/bad() 结构、双层注释、Total 行、FAIL>0 exit 1 全同构）。
# 用途：静态断言覆盖矩阵（references/agent-coverage.md）在位、SKILL.md 六族行在位、B 类旧字面登记面零残留、
#      矩阵 §一 agent 实体存在性（~/.zcode/agents，目录缺位 fail-open SKIPPED）、C 类 41 行处置覆盖、
#      Rule 52 四子条+标题在位、config 零新键（properties=40）、既有锚（^21.1b/^47.）守护、矩阵行数锚（=128 精确，task-v131 审计 L-3 对称守护）。
# 输入：references/agent-coverage.md、SKILL.md、../plan-template-kit/references/template-mapping.md、
#      companion/agents/、templates/、references/critical-rules.md、config.json、
#      $HOME/.zcode/agents/（仓外只读 test -f；目录缺位 fail-open SKIPPED，不硬 FAIL）。
# 输出：AC-01..AC-09 逐行 PASS/FAIL（AC-04 目录缺位时打 SKIPPED 不 FAIL，jq 缺失同先例）+ 末行 Total；
#      全 PASS exit 0，任一 FAIL exit 1。
# 依赖：bash + grep + awk；config 键数校验需 jq（缺失打 SKIPPED 不 FAIL，与 selftest-media-agents.sh MA-10 先例一致）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MATRIX="$SKILL_ROOT/references/agent-coverage.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
TMAP="$SKILL_ROOT/../plan-template-kit/references/template-mapping.md"
COMPANION="$SKILL_ROOT/companion/agents"
TEMPLATES="$SKILL_ROOT/templates"
CRITRULES="$SKILL_ROOT/references/critical-rules.md"
CONFIG="$SKILL_ROOT/config.json"
AGENTS_DIR="$HOME/.zcode/agents"

PASS=0; FAIL=0; SKIP=0
ok()  { PASS=$((PASS+1)); printf 'AC-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'AC-%s FAIL %s\n' "$1" "$2"; }
skip(){ SKIP=$((SKIP+1)); printf 'AC-%s SKIPPED %s\n' "$1" "$2"; }

# AC-01 矩阵文件在位且含三锚
# What：断言 references/agent-coverage.md 非空且在位，且「三类缺口」「C 类」「零专用体领域」三锚各 ≥1。
# Why：矩阵是 Rule 52.1 选型单一事实源——文件被误删/重构丢锚 = 选型失去落仓事实源（防"矩阵被裁回草案"的逆向漂移；
#      三锚=§一/§二/§三/§四 四段的机器可核子集，锚在=段结构未塌陷）。
if [ -s "$MATRIX" ]; then
  a="$(grep -c '三类缺口' "$MATRIX" || true)"
  b="$(grep -c 'C 类' "$MATRIX" || true)"
  c="$(grep -c '零专用体领域' "$MATRIX" || true)"
  if [ "$a" -ge 1 ] && [ "$b" -ge 1 ] && [ "$c" -ge 1 ]; then
    ok 01 "矩阵在位 三类缺口=$a C 类=$b 零专用体领域=$c 各 ≥1"
  else
    bad 01 "矩阵三锚缺失（三类缺口=$a / C 类=$b / 零专用体领域=$c，应各 ≥1）"
  fi
else
  bad 01 "矩阵文件缺失/空: $MATRIX"
fi

# AC-02 SKILL.md 六族行锚各 ≥1
# What：断言 SKILL.md 六族行（质量审查族/Git 运维族/营销 SEO 族/数据研究族/文档 UI 族/文章管线补充族）各 ≥1。
# Why：六族行是 C 类 41 实体「找得到」的路由面（S3 产出）——任一族行被裁 = 该族实体退回「有体不用」（族行缺失即回退到
#      general-purpose 默认兜底的用户原投诉面；行数=1 的逐族计数使 FAIL 定位到具体族而非笼统"族行丢失"）。
famres=""
for fam in "质量审查族" "Git 运维族" "营销 SEO 族" "数据研究族" "文档 UI 族" "文章管线补充族"; do
  n="$(grep -c "$fam" "$SKILLMD" 2>/dev/null || true)"
  if [ "${n:-0}" -ge 1 ]; then famres="$famres $fam=$n"; else famres="$famres $fam=0(缺)"; fi
done
if [ "$(printf '%s' "$famres" | grep -c '缺' || true)" -eq 0 ]; then
  ok 02 "SKILL.md 六族行锚${famres} 各 ≥1"
else
  bad 02 "SKILL.md 六族行锚缺失:${famres}（应各 ≥1）"
fi

# AC-03 B 类反证（旧字面零残留 + 新字面在位，双侧）
# What：登记面（SKILL.md / template-mapping.md / companion/agents/ / templates/）内
#      ① `article-batch-publish`（无 er 形）② `ComplexProblemSolver` ③ mapping script-dev 行裸名
#      script-writer/script-auditor 均零命中；正面锚 complex-problem-solver 在 SKILL.md ≥1。
# Why：B 类=登记名指向不存在/名不符实体，Rule 52.2 零容忍——S3/S4 已做行内修正（B4 改名/B5 改小写/B1B2 兜底化），
#      本断言防"文档重构还原旧字面"的逆向漂移。扫描面刻意排除矩阵 agent-coverage.md 本身（其 §二 B 表按 52.3 口径
#      合法记载旧字面 B4/B5 条目与 AC-03 守护口径说明行，属文档记录面非登记面，纳入扫描会自证 FAIL）。
x="$(grep -rPc 'article-batch-publish(?!er)' "$SKILLMD" "$TMAP" "$COMPANION" "$TEMPLATES" 2>/dev/null | grep -v ':0$' || true)"
cpv="$(grep -rl 'ComplexProblemSolver' "$SKILLMD" "$TMAP" "$COMPANION" "$TEMPLATES" 2>/dev/null || true)"
sw="$(grep -E '^\|[[:space:]]*script-dev[[:space:]]*\|' "$TMAP" 2>/dev/null | grep -c 'script-writer\|script-auditor' || true)"
pos="$(grep -c 'complex-problem-solver' "$SKILLMD" 2>/dev/null || true)"
if [ -z "$x" ] && [ -z "$cpv" ] && [ "$sw" -eq 0 ] && [ "$pos" -ge 1 ]; then
  ok 03 "B 类反证通过: publish(无er)=0 ComplexProblemSolver=0 script-dev 行裸名=0；正面锚 complex-problem-solver=$pos ≥1"
else
  bad 03 "B 类残留: publish(无er)=[$(echo "$x" | tr '\n' ';')] CPS=[$cpv] script-dev 行裸名=$sw 正面锚=$pos（应旧字面全 0、正面 ≥1）"
fi

# AC-04 矩阵 §一 专用体列 agent 名实体存在性（$HOME/.zcode/agents/<name>.md）
# What：从矩阵 §一（「## 一、」到「## 二、」）表格编号行第 3 列提取小写连字符名 token，
#      减内置豁免名单（skill 类/SOP 资产/媒体工序描述符/版本后缀/复合名碎片/已由实体承接的承接名/修饰词，
#      25 项）后，对每个候选执行 `test -f $AGENTS_DIR/<name>.md`；目录缺位整体 SKIPPED
#      （fail-open，52.2 口径）；候选缺位即 FAIL。
# Why：B 类实证手段的机器化（52.2「所有登记名必须 test -f 于 agents 目录，目录缺位 fail-open SKIPPED」）——
#      防"登记面指向幽灵实体"复发；逐候选计数使 FAIL 直接点名缺失实体。
# 逐表行按 | 列切取第 4 字段=「专用体（登记面）」列（矩阵表 4 列：# / 类型族 / 专用体 / 登记状态）
awk 'BEGIN{FS="\\|"} /^## 一、/{f=1;next} /^## 二、/{f=0} f && /^\| *[0-9]+ *\|/ {print $4}' "$MATRIX" 2>/dev/null \
  | grep -oE '[a-z][a-z0-9]+(-[a-z0-9]+)*' | sort -u > /tmp/.ac04.toks.$$ || true
# 内置豁免名单（token 级，一行一项；依据逐注）：
#   skill 类/工具名   research-assistant（B3 实证 skill 非 agent，B3 修正为双列标注，brief 明示走豁免）
#   SOP/项目资产     videop1-video-fix / git（行 26 git 编排非 agent 名）
#   承接名           video-fix-executor（v124 未独立开体：video-fix 工序由 video-generation-executor 实体承接，
#                    依据=该 agent frontmatter「缺陷四级处置（剪辑补救→段级重生成→整件重生成）」；
#                    候选集含 video-generation-executor 本身，home 在位即证 §一 行 24 的承接实体存在，
#                    故本名不单独 test——矩阵改名/该承接体漂移时本行须随动）
#   媒体工序描述符   character-design multiview-ref storyboard prompt-struct video-prompt motion-camera
#                    physics-compliance qc-defect audio-voice final-assembly image（行 25 类族名非 agent 名）
#   版本后缀 token   v124 v122 v125
#   复合名碎片       gnes hase it xecutor web-search worktree（「Agnes 视频链路」「executor(fresh)」等复合词
#                    grep 碎切产物；完整复合名由主名单独立覆盖，碎片本身非实体）
#   修饰词           fresh（「executor(fresh)/verifier(D3)」执行模式修饰词，非 agent 名；完整体 executor 已在主名单）
EXEMPT_TOKENS='research-assistant
videop1-video-fix
git
video-fix-executor
character-design
multiview-ref
storyboard
prompt-struct
video-prompt
motion-camera
physics-compliance
qc-defect
audio-voice
final-assembly
image
v124
v122
v125
gnes
hase
it
xecutor
web-search
worktree
fresh'
printf '%s\n' "$EXEMPT_TOKENS" | sort -u > /tmp/.ac04.ex.$$
CANDS="$(comm -23 /tmp/.ac04.toks.$$ /tmp/.ac04.ex.$$)"
EXCNT="$(grep -c . /tmp/.ac04.ex.$$ || true)"
rm -f /tmp/.ac04.toks.$$ /tmp/.ac04.ex.$$
if [ ! -d "$AGENTS_DIR" ]; then
  skip 04 "agents 目录缺位 $AGENTS_DIR（fail-open，52.2 口径；安装后重跑）"
else
  HOMEOC=0; HOMEMISS=""
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    if [ -f "$AGENTS_DIR/$t.md" ]; then HOMEOC=$((HOMEOC+1)); else HOMEMISS="$HOMEMISS $t"; fi
  done <<< "$CANDS"
  CANDCNT="$(grep -c . <<< "$CANDS" || true)"
  if [ -z "$HOMEMISS" ]; then
    ok 04 "§一 候选 agent $CANDCNT（token 提取-豁免 $EXCNT）home 全在位；双缺位 0"
  else
    bad 04 "§一 候选 agent $CANDCNT 中缺位:$HOMEMISS（B 类复发，需补实体或修正矩阵名）"
  fi
fi

# AC-05 C 类 41 行处置覆盖（§三 C 表行数=41 且每行含 纳入|豁免）
# What：断言矩阵 §三 C 表编号行数=41（口径同 findings S1 验收 awk+grep），且无一行缺「纳入|豁免」列。
# Why：C 类=有体不用，处置表逐行可追溯是 52.3 维护责任矩阵面——行数回退 41 或丢处置列 = 部分实体退回未登记态
#      （行数与逐行双断言：只查行数会被"删行+改总数"绕过，逐行查处置列防"删处置列留实体名"的部分裁剪）。
c41="$(awk '/^## 三、/,/^## 四、/' "$MATRIX" 2>/dev/null | grep -cE '^\| [0-9]+ \|' || true)"
cmiss="$(awk '/^## 三、/,/^## 四、/' "$MATRIX" 2>/dev/null | grep -E '^\| [0-9]+ \|' | grep -vc '纳入\|豁免' || true)"
if [ "$c41" -eq 41 ] && [ "$cmiss" -eq 0 ]; then
  ok 05 "C 表行数=41 且每行含 纳入|豁免（缺处置列 0）"
else
  bad 05 "C 表行数=$c41（应 41）/ 缺处置列行=$cmiss（应 0）"
fi

# AC-06 Rule 52 四子条 + 标题
# What：断言 critical-rules.md `^52\.` 子条数=4 且 `^### 52 ` 标题锚 ≥1。
# Why：Rule 52 是 S2 产出条款本体——子条 52.1-52.4 各 1 条被删/被并 = 条款语义部分缺失（4 精确计数 vs ≥4：
#      多出的 ^52 行=异常拆分，同样需暴露；标题锚防"子条在但标题被裁"的结构性漂移）。
s52="$(grep -c '^52\.' "$CRITRULES" 2>/dev/null || true)"
t52="$(grep -c '^### 52 ' "$CRITRULES" 2>/dev/null || true)"
if [ "$s52" -eq 4 ] && [ "$t52" -ge 1 ]; then
  ok 06 "Rule 52 子条=4 标题=1 在位"
else
  bad 06 "Rule 52 锚漂移（^52. 子条=$s52 应 4 / ^### 52 标题=$t52 应 ≥1）"
fi

# AC-07 零新 config 键（properties=40）
# What：断言 config.json .properties 顶层键数保持 40（与 43.4/44.4/47/49/50/51 零新键同口径；jq 缺失打 SKIPPED 不 FAIL）。
# Why：Rule 52.4 承诺「零新 config 键——判定面=LLM 行为+静态守护，机器面不加新键」——键数膨胀=有人给执行体
#      选型加了机器门控键，属机制漂移（需走 Rule 36 条款流程）；jq 缺失=环境降级非内容漂移（MA-10 先例）。
if command -v jq >/dev/null 2>&1; then
  keys="$(jq -r '.properties|keys|length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "40" ]; then ok 07 "config.json properties 键数 40（零新增）"; else bad 07 "config.json properties 键数=$keys（应 40，零新键承诺被破坏）"; fi
else
  skip 07 "jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）"
fi

# AC-08 既有锚守护（^21.1b 与 ^47. ≥4 在位）
# What：断言 critical-rules.md 既有 Rule 21.1b 子条与 Rule 47 四子条（47.1-47.4）原锚未漂移。
# Why：Rule 52 声明「既有 21/25/37/47 原文零改动（Rule 36.5 纯增量）」——^21.1b 是拆分轴条款、^47 四子条是
#      媒体派发纪律（52 直接衔接的上位条款）；锚被改/被删=既有规则语义漂移（本条=纯增量承诺的机器面反证）。
a21="$(grep -c '^21\.1b' "$CRITRULES" 2>/dev/null || true)"
a47="$(grep -c '^47\.' "$CRITRULES" 2>/dev/null || true)"
if [ "$a21" -ge 1 ] && [ "$a47" -ge 4 ]; then
  ok 08 "既有锚在位 ^21.1b=$a21 ≥1 / ^47.=$a47 ≥4"
else
  bad 08 "既有锚漂移（^21.1b=$a21 应 ≥1 / ^47.=$a47 应 ≥4，既有 Rules 原文零改动被破坏）"
fi

# AC-09 矩阵行数锚（=128 精确，task-v131 审计 L-3 对称守护）
# What：断言 references/agent-coverage.md 行数=128（wc -l 精确锚，128 为 2026-10-05 task-v131 实测值）。
# Why：task-v131 审计 L-3 指出 SKILL.md 行数在 selftest-skill-split.sh 有阈值断言（461→477 演进史），
#      而矩阵 128 行锚此前无机器断言=文档瘦身/膨胀双侧漂移零守卫（矩阵被裁=选型事实源缩水，矩阵被灌水=维护成本膨胀）；
#      选精确=（非 ≤ 上限）：矩阵是选型单一事实源，行数=内容量的直接度量，精确锚使任何未走 Rule 52.3 增删同步流程的
#      加行/删行立即 FAIL——演进规则=Rule 52.3（增删同步：矩阵行数变化必须与 C 表行数 41 及 §一/§二 变更同 commit 联动，
#      同步更新本锚 128→新值并在此行注记演进史，格式先例 selftest-skill-split.sh T-主 440→…→477）。
ml="$(wc -l < "$MATRIX" 2>/dev/null || true)"
if [ "$ml" = "128" ]; then
  ok 09 "矩阵行数=128 精确锚在位（task-v131 审计 L-3 对称守护；演进=Rule 52.3 增删同步）"
else
  bad 09 "矩阵行数=$ml（应 128；增删须走 Rule 52.3 增删同步并更新本锚，演进史先例 skill-split T-主）"
fi

printf 'Total: %d PASS=%d FAIL=%d SKIPPED=%d\n' "$((PASS+FAIL+SKIP))" "$PASS" "$FAIL" "$SKIP"
exit $((FAIL > 0))
