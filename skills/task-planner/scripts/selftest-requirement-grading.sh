#!/usr/bin/env bash
# selftest-requirement-grading.sh — task-v127 S5: Rule 50 内容要求权重分级与评级静态守护（50.6 机器面落地物）
# What：静态断言 Rule 50 全部落点在位——critical-rules.md 章节标题/50.1-50.6 子条/泪痣双条目锚、
#      三个内容模板（image-type / character-design-type / qc-defect-type）的评级契约块、
#      goal-gate.md 分级联动、SKILL.md 摘要路由面，以及零新 config 键承诺（properties=40）。
# Why：Rule 50 消除「存在性约束被判定、程度约束被整体忽略」双断链（泪痣案例 findings §[sub:02-explore]）——
#      本脚本是 50.6 声明的机器面自守护：任何后续任务改写 critical-rules.md/SKILL.md/模板/goal-gate.md
#      时误删 50.x 条款、双条目锚或模板契约块，selftest 立即 FAIL 暴露（Rule 36.5 纯增量回归防护）；
#      零新键断言锁 50.6 与 43.4/44.4/47.4 同范式的 config 冻结承诺。
# 范式对齐 selftest-lane-advancement.sh（SCRIPT_DIR/SKILL_ROOT 定位、ok()/bad()、Total 行、FAIL>0 exit 1 全同构）。
# 输入：references/critical-rules.md、SKILL.md、references/goal-gate.md、templates/variant/{image-type,character-design-type,qc-defect-type}.md、
#      config.json（只读，grep/jq，零写入）。
# 输出：RG-01..RG-07 逐行 PASS/FAIL + 末行 Total；全 PASS exit 0，任一 FAIL exit 1
#      （config.json 键数校验需 jq，缺失时 RG-07 打 SKIPPED 不 FAIL——沿用 LA-14/MD-08/R-12 fail-open 先例，打印提示行非静默）。
# 依赖：bash + grep；jq（RG-07）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
GATE="$SKILL_ROOT/references/goal-gate.md"
TPL="$SKILL_ROOT/templates/variant"
CONFIG="$SKILL_ROOT/config.json"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'RG-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'RG-%s FAIL %s\n' "$1" "$2"; }

# RG-01 Rule 50 章节标题锚 `grep -q '### 50 内容要求权重分级与评级'`
# What：断言 critical-rules.md 内 '### 50 内容要求权重分级与评级' 章节标题行在位。
# Why：标题行是 44/45/46/47/49 范式（章节标题+子条）的识别锚——丢标题 Rule 50 退化为无主条款（防章节误删/标题降级为普通段落）。
if grep -q '### 50 内容要求权重分级与评级' "$CRIT"; then
  ok 01 "critical-rules.md '### 50 内容要求权重分级与评级' 标题锚在位"
else
  bad 01 "critical-rules.md '### 50 内容要求权重分级与评级' 标题锚缺失"
fi

# RG-02 Rule 50 子条锚 `grep -c '^50\.'` ≥6
# What：断言 50.1-50.6 六条子条主体行（行首 '50.N'）在位，计数 ≥6。
# Why：子条是 50.1 条目表/50.2 程度词显式成条/50.3 双向评级/50.4 双向判据/50.5 样式样例/50.6 机制的唯一文本落点，
#      缺任一子条 = 分级评级条款本体被裁剪（防后续改写 critical-rules.md 误删 50.x 段）。
n="$(grep -c '^50\.' "$CRIT" || true)"
if [ "$n" -ge 6 ]; then ok 02 "critical-rules.md Rule 50 子条锚 $n ≥6"; else bad 02 "critical-rules.md Rule 50 子条数 $n（应 ≥6）"; fi

# RG-03 泪痣双条目锚 `grep -q '人物脸上有泪痣'` ∧ `grep -q '泪痣不注意看不到'` ∧ `grep -q '双向'`
# What：断言泪痣案例 P 条目行（'人物脸上有泪痣'）、E 条目行（'泪痣不注意看不到'）与双向判定语义（'双向'）三者同时在 critical-rules.md 在位。
# Why：双条目样例是本条的起源案例（用户反馈直接针对「只判 P 忽略 E」）——P/E 双条目缺一 = 样例退化为单条目，
#      程度约束显式成条（50.2）失去示例锚；'双向' 缺失 = 50.3/50.4 双向判语义被裁剪为单向判（防核心缺陷场景被去样例化）。
if grep -q '人物脸上有泪痣' "$CRIT" && grep -q '泪痣不注意看不到' "$CRIT" && grep -q '双向' "$CRIT"; then
  ok 03 "critical-rules.md 泪痣双条目锚（P+E 行 + '双向'）在位"
else
  bad 03 "critical-rules.md 泪痣双条目锚缺失（'人物脸上有泪痣'∧'泪痣不注意看不到'∧'双向' 三者须全命中）"
fi

# RG-04 三模板评级契约锚（image-type / character-design-type / qc-defect-type 各含三锚）
# What：断言三个内容类模板各含 '评级契约（Rule 50）' 契约块标题、'原子验收条目' 概念、'双向' 判定语义。
# Why：模板是 Rule 50 的消费面（生成计划时契约块驱动 LLM 落原子条目表+双向判）——任一模板契约块缺失 = 该任务类型
#      失去 50 的落地锚（防模板重写时整块裁掉评级契约；qc-defect 是执行期 QC 链消费点，缺 '双向' = QC 侧程度判退化为存在性判）。
RG04_FAIL=0; RG04_DETAIL=""
for f in image-type character-design-type qc-defect-type; do
  t="$TPL/$f.md"
  if grep -q '评级契约（Rule 50）' "$t" && grep -q '原子验收条目' "$t" && grep -q '双向' "$t"; then
    :
  else
    RG04_FAIL=1; RG04_DETAIL="$RG04_DETAIL $f.md;"
  fi
done
if [ "$RG04_FAIL" -eq 0 ]; then
  ok 04 "三模板（image/character-design/qc-defect）'评级契约（Rule 50）'∧'原子验收条目'∧'双向' 全在位"
else
  bad 04 "模板评级契约锚缺失：$RG04_DETAIL（'评级契约（Rule 50）'∧'原子验收条目'∧'双向' 须三者全命中）"
fi

# RG-05 goal-gate.md 分级联动锚 `grep -q '分级'` ∧ `grep -q 'Rule 50'`
# What：断言 goal-gate.md 同时含 '分级' 与 'Rule 50' 两锚。
# Why：goal-gate.md 是目标验收（VC）的判定面文档——Rule 50 计划期条目化/分级在 goal-gate 无引用 = 验收门控
#      与分级契约脱钩（防 50.1 条目表只写 critical-rules 未联动验收侧文档的级联断链）。
if grep -q '分级' "$GATE" && grep -q 'Rule 50' "$GATE"; then
  ok 05 "goal-gate.md '分级'∧'Rule 50' 双锚在位"
else
  bad 05 "goal-gate.md '分级'∧'Rule 50' 双锚缺失（验收门控未联动 Rule 50）"
fi

# RG-06 SKILL.md 路由面锚 `grep -q '1-50'` ∧ `grep -c 'Rule 50'` ≥2
# What：断言 SKILL.md 含全集行 '1-50'（Critical Rules 全集扩号到 50）且 'Rule 50' 命中 ≥2 处（摘要 bullet + 路由/正文消费点）。
# Why：'1-50' 缺失 = 全集行未扩号（LLM 读到 1-49 全集即认为 50 不存在）；'Rule 50' 命中 <2 = 摘要与消费点至少一处脱钩
#      （防 49 范式同类级联断链：条款扩到 50 但 SKILL.md 面停摆）。
if grep -q '1-5[0-9]' "$SKILLMD" && [ "$(grep -c 'Rule 50' "$SKILLMD" || true)" -ge 2 ]; then
  ok 06 "SKILL.md '1-5[0-9]' 在位 ∧ 'Rule 50' 命中 ≥2"
else
  n="$(grep -c 'Rule 50' "$SKILLMD" || true)"
  bad 06 "SKILL.md 路由面锚缺失（'1-5[0-9]' 或 'Rule 50' 命中=$n <2）"
fi

# RG-07 零新 config 键——properties 键数 = 40（同 43.4/44.4/47.4 口径；jq 缺失打 SKIPPED 不 FAIL）
# What：断言 config.json .properties 顶层键数保持 40（Rule 50 判定面=LLM 行为 + 静态守护，零机器触发面）。
# Why：50.6 承诺"零新 config 键"——键数膨胀 = 有人给分级评级加了机器门控键，突破 43.4/44.4/47.4 零新键范式，
#      属机制漂移（需走 Rule 36 条款流程）；jq 缺失 fail-open 打 SKIPPED（无 jq 属环境降级非内容漂移，不误报 FAIL）。
if command -v jq >/dev/null 2>&1; then
  keys="$(jq '.properties | length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "40" ]; then ok 07 "config.json properties 键数 40（零新增）"; else bad 07 "config.json properties 键数=$keys（应 40，Rule 50 零新键被破坏）"; fi
else
  printf 'RG-07 SKIPPED jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）\n'
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
