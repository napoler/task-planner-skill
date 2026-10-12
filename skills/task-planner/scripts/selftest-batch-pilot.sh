#!/usr/bin/env bash
# selftest-batch-pilot.sh — task-v083: Rule 18 批量试点先行硬门静态守护
# 守护（行为裁决为 LLM 行为面无脚本可测，仅防条款误删/联动漂移）:
#   BP-01 critical-rules.md 含 18.9 试点先行硬门（锚: 试点先行硬门 + 禁止启动批量）
#   BP-02 含 18.10 单件失败禁批量（锚: 投毒红线 + Rule 31）
#   BP-03 含 18.11 宁慢勿错（锚: 宁慢勿错 + 自动无效）
#   BP-04 编号连续性: 18.1-18.11 各恰好 1 次（防重编号/重复/漏追加）
#   BP-05 SKILL.md Rule 18 摘要行含「试点先行」（联动防漏）
#   BP-06 batch-quality-gate.md §二表含 18.9/18.10/18.11 三行
#   BP-07 batch-quality-gate.md 含 §八试点先行硬门详解
#   BP-08 SKILL.md 行数 ≤275（行数回归钉; [2026-09-20 task-v085] 机制画像增量 548→549; [2026-09-20 task-v086] Rule 38 联动 549→551, 上限 549→552; [2026-09-22 task-v087] Rule 8.1 D 类联动 551→555, 上限 552→555; [2026-09-23 task-v088] Rule 39 联动 555→558, 上限 555→558; [2026-10-12 task-v171 S38] 技能专业化拆分后 SKILL.md 重写瘦身（分层至 10 卫星, 实值 214 行）, 上限 558→275=250+25 边距先例（同 task-v168 实值+25 口径, 设计文档 §6 BP-08 行数钉演进））
#   BP-09 batch-quality-gate.md 含「隶属 Rules 1-36..1-77」宽容正则（CD-19 宽容锚子串保护钉; [2026-10-12 task-v171 S38] 纪元锚扩: 76 既有规则按域分层至 10 卫星后全集跨 1-77, 仿 selftest-conclusion-discipline.sh CD-19「1-3[5-8]」宽容锚写法扩为「1-(3[6-9]|[4-6][0-9]|7[0-7])」——覆盖 1-77 全集（含 77 纪元）, 兼容当前在位字面 1-36 过渡, 设计文档 §6 rule-range 纪元锚扩）
#   BP-10 仓库根 CHANGELOG.md 含 task-v083 条目（非仓库部署环境显式 SKIP）
# 10 断言全 PASS（SKIP 不计 FAIL）exit 0; 任一 FAIL exit 1。只读, 不修改任何文件。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
# [task-v171 纪律域搬迁 2026-10-12] Rule 18（批量处理质量门控）属纪律域，原文已迁至
#   skills/task-discipline/references/critical-rules-discipline.md（核心 critical-rules.md 只剩 11 条核心规则），
#   BP-01/02/03/04 的 CRIT 断言改指 CRIT_D；CRIT 保留指向核心。断言语义零改动。
CRIT_D="$SKILL_ROOT/../task-discipline/references/critical-rules-discipline.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
# [task-v171 纪律域搬迁 2026-10-12] batch-quality-gate.md 归属纪律域，迁至 skills/task-discipline/references，
#   路径改锚；BP-06/07/09 断言语义零改动（CD-19 宽容锚保护钉不变，Rule 36.5 纯增量）
BGATE="$SKILL_ROOT/../task-discipline/references/batch-quality-gate.md"
CHANGELOG="$SKILL_ROOT/../../CHANGELOG.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'BP-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'BP-%s FAIL %s\n' "$1" "$2"; }

# BP-01
if grep -q '^18\.9 ' "$CRIT_D" && grep '^18\.9 ' "$CRIT_D" | grep -q '试点先行硬门' && grep '^18\.9 ' "$CRIT_D" | grep -q '禁止启动批量'; then ok 01 "18.9 试点先行硬门"; else bad 01 "18.9 缺失/锚不全"; fi
# BP-02
if grep -q '^18\.10 ' "$CRIT_D" && grep '^18\.10 ' "$CRIT_D" | grep -q '投毒红线' && grep '^18\.10 ' "$CRIT_D" | grep -q 'Rule 31'; then ok 02 "18.10 单件失败禁批量（投毒红线）"; else bad 02 "18.10 缺失/锚不全"; fi
# BP-03
if grep -q '^18\.11 ' "$CRIT_D" && grep '^18\.11 ' "$CRIT_D" | grep -q '宁慢勿错' && grep '^18\.11 ' "$CRIT_D" | grep -q '自动无效'; then ok 03 "18.11 宁慢勿错"; else bad 03 "18.11 缺失/锚不全"; fi
# BP-04
seq_ok=1; bad_n=""
for i in $(seq 1 11); do
  c=$(grep -c "^18\.$i " "$CRIT_D")
  if [ "$c" -ne 1 ]; then seq_ok=0; bad_n="18.$i=$c"; break; fi
done
if [ "$seq_ok" -eq 1 ]; then ok 04 "18.1-18.11 编号连续各 1 次"; else bad 04 "编号连续性破坏($bad_n)"; fi
# BP-05 [task-v171 核心瘦身] SKILL.md Rule 18 联动面（瘦身后由卫星路由表 task-discipline 行承载）
#   现象：SKILL.md 瘦身后非核心域规则摘要 bullet 全部移除，旧锚 'Rule 18 批量处理质量门控' 摘要行零命中，BP-05 恒 FAIL。
#   根因：断言锚定旧 SKILL.md Critical Rules 指针段摘要行；Rule 18 属纪律域，瘦身后联动面=卫星路由表 task-discipline 行（Rule 82 禁回潮，摘要 bullet 不回填）。
#   修法：改断言 SKILL.md 卫星路由表 task-discipline 路由行含 Rule 18 编号（路由表是瘦身后 SKILL 侧唯一联动载体）；
#     「试点先行」条文锚由 BP-01（CRIT_D 18.9 硬门）与 BP-07（BGATE §八 详解）双断 assertion，强度不降。
if grep -E '^\| task-discipline \|' "$SKILLMD" | grep -qE 'Rule [0-9,]*18'; then ok 05 "SKILL.md 卫星路由表 task-discipline 行含 Rule 18（摘要行瘦身后由路由表承载）"; else bad 05 "SKILL.md 卫星路由表缺 Rule 18 编号"; fi
# BP-06
tbl_ok=1; bad_n=""
for i in 9 10 11; do
  c=$(grep -c "^| \*\*18\.$i\*\*" "$BGATE")
  if [ "$c" -lt 1 ]; then tbl_ok=0; bad_n="表行18.$i=$c"; break; fi
done
if [ "$tbl_ok" -eq 1 ]; then ok 06 "batch-quality-gate §二表 18.9-18.11 三行"; else bad 06 "详解表行缺失($bad_n)"; fi
# BP-07
if grep -q '## 八、试点先行硬门详解' "$BGATE"; then ok 07 "§八 试点先行硬门详解"; else bad 07 "缺 §八 详解段"; fi
# BP-08 [2026-10-12 task-v171 S38] 上限 558→275: Why=技能专业化拆分后 SKILL.md 重写瘦身（非核心 66 条规则分层至 10 卫星, 实值 214 行）, 原钉 558 贴线即破且失去回归意义; 新钉=目标 ≤250+25 边距（先例=task-v168 实值+25 口径, 设计文档 §6「BP-08 行数钉演进」: 558→275）
lines=$(wc -l < "$SKILLMD")
if [ "$lines" -le 275 ]; then ok 08 "SKILL.md 行数 $lines ≤275"; else bad 08 "SKILL.md 行数 $lines 超 275"; fi
# BP-09 [2026-10-12 task-v171 S38] 纪元锚扩至覆盖 1-77 全集: 原字面 grep '隶属 Rules 1-36' → 宽容正则
#   grep -qE '隶属 Rules 1-(3[6-9]|[4-6][0-9]|7[0-7])'（参照 selftest-conclusion-discipline.sh:101 CD-19「1-3[5-8]」宽容锚写法扩为含 77）;
#   覆盖 1-36..1-77 全部纪元（当前 BGATE 在位字面 1-36 命中, 77 纪元前瞻命中）, 全集过渡不断钉
if grep -qE '隶属 Rules 1-(3[6-9]|[4-6][0-9]|7[0-7])' "$BGATE"; then ok 09 "CD-19 宽容锚子串保护（隶属 Rules 1-36..1-77 全集宽容, 含 77）"; else bad 09 "CD-19 子串被破坏或纪元锚未覆盖 77"; fi
# BP-10
if [ -f "$CHANGELOG" ]; then
  if grep -q '批量试点先行硬门（task-v083）' "$CHANGELOG"; then ok 10 "CHANGELOG task-v083 条目"; else bad 10 "CHANGELOG 缺 task-v083 条目"; fi
else
  printf 'BP-10 SKIP 非仓库环境（无 %s）\n' "$CHANGELOG"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
