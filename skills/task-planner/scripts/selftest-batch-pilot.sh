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
#   BP-08 SKILL.md 行数 ≤549（行数回归钉; [2026-09-20 task-v085] 机制画像增量 548→549; task-v083 净增 0 后基线 543）
#   BP-09 batch-quality-gate.md 含「隶属 Rules 1-36」（CD-19 宽容锚子串保护钉）
#   BP-10 仓库根 CHANGELOG.md 含 task-v083 条目（非仓库部署环境显式 SKIP）
# 10 断言全 PASS（SKIP 不计 FAIL）exit 0; 任一 FAIL exit 1。只读, 不修改任何文件。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
BGATE="$SKILL_ROOT/references/batch-quality-gate.md"
CHANGELOG="$SKILL_ROOT/../../CHANGELOG.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'BP-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'BP-%s FAIL %s\n' "$1" "$2"; }

# BP-01
if grep -q '^18\.9 ' "$CRIT" && grep '^18\.9 ' "$CRIT" | grep -q '试点先行硬门' && grep '^18\.9 ' "$CRIT" | grep -q '禁止启动批量'; then ok 01 "18.9 试点先行硬门"; else bad 01 "18.9 缺失/锚不全"; fi
# BP-02
if grep -q '^18\.10 ' "$CRIT" && grep '^18\.10 ' "$CRIT" | grep -q '投毒红线' && grep '^18\.10 ' "$CRIT" | grep -q 'Rule 31'; then ok 02 "18.10 单件失败禁批量（投毒红线）"; else bad 02 "18.10 缺失/锚不全"; fi
# BP-03
if grep -q '^18\.11 ' "$CRIT" && grep '^18\.11 ' "$CRIT" | grep -q '宁慢勿错' && grep '^18\.11 ' "$CRIT" | grep -q '自动无效'; then ok 03 "18.11 宁慢勿错"; else bad 03 "18.11 缺失/锚不全"; fi
# BP-04
seq_ok=1; bad_n=""
for i in $(seq 1 11); do
  c=$(grep -c "^18\.$i " "$CRIT")
  if [ "$c" -ne 1 ]; then seq_ok=0; bad_n="18.$i=$c"; break; fi
done
if [ "$seq_ok" -eq 1 ]; then ok 04 "18.1-18.11 编号连续各 1 次"; else bad 04 "编号连续性破坏($bad_n)"; fi
# BP-05
if grep 'Rule 18 批量处理质量门控' "$SKILLMD" | grep -q '试点先行'; then ok 05 "SKILL.md Rule 18 摘要行联动"; else bad 05 "SKILL.md 摘要行缺试点先行"; fi
# BP-06
tbl_ok=1; bad_n=""
for i in 9 10 11; do
  c=$(grep -c "^| \*\*18\.$i\*\*" "$BGATE")
  if [ "$c" -lt 1 ]; then tbl_ok=0; bad_n="表行18.$i=$c"; break; fi
done
if [ "$tbl_ok" -eq 1 ]; then ok 06 "batch-quality-gate §二表 18.9-18.11 三行"; else bad 06 "详解表行缺失($bad_n)"; fi
# BP-07
if grep -q '## 八、试点先行硬门详解' "$BGATE"; then ok 07 "§八 试点先行硬门详解"; else bad 07 "缺 §八 详解段"; fi
# BP-08
lines=$(wc -l < "$SKILLMD")
if [ "$lines" -le 549 ]; then ok 08 "SKILL.md 行数 $lines ≤549"; else bad 08 "SKILL.md 行数 $lines 超 549"; fi
# BP-09
if grep -q '隶属 Rules 1-36' "$BGATE"; then ok 09 "CD-19 宽容锚子串保护（隶属 Rules 1-36）"; else bad 09 "CD-19 子串被破坏"; fi
# BP-10
if [ -f "$CHANGELOG" ]; then
  if grep -q '批量试点先行硬门（task-v083）' "$CHANGELOG"; then ok 10 "CHANGELOG task-v083 条目"; else bad 10 "CHANGELOG 缺 task-v083 条目"; fi
else
  printf 'BP-10 SKIP 非仓库环境（无 %s）\n' "$CHANGELOG"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
