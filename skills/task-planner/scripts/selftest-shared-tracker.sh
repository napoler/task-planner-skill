#!/usr/bin/env bash
# selftest-shared-tracker.sh — task-v071: Rule 30 共享内容认领追踪静态守护
# 守护（与 v063/v068 门控+指针范式一致，复述/追踪为 LLM 行为面无脚本可测，仅防条款误删）:
#   ST-01 critical-rules.md 含 30.1 识别条件条款（语义锚点: 识别 + 只认领一部分）
#   ST-02 含 30.2 创建/复用条款（语义锚点: 先查后写 / 不另造文件 / progress-tracker 权威源）
#   ST-03 含 30.3 认领登记条款（语义锚点: in_progress + done + effect + 禁悬挂）
#   ST-04 含 30.4 防冲突条款（语义锚点: 重复认领 / D4 询问）
#   ST-05 含 30.5 机制条款（语义锚点: shared_tracker_enforce 开关键）
#   ST-06 SKILL.md Critical Rules 摘要行含 Rule 30（防摘要漏联动）
#   ST-07 SKILL.md 设计期检查点含「共享内容追踪检查点」
#   ST-08 config.json 含 shared_tracker_enforce 键（默认 warn，enum 三档）
#   ST-09 templates/shared-tracker.md 存在
#   ST-10 skill-collaboration.md 协同矩阵含 progress-tracker 行
#   ST-11 progress-tracker 技能探针（~/.zcode/skills/progress-tracker/SKILL.md 存在；缺失 → 该用例 FAIL 提示先建技能）
# 11 断言全 PASS exit 0; 任一 FAIL exit 1。只读, 不修改任何文件。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
TPL="$SKILL_ROOT/templates/shared-tracker.md"
COLLAB="$SKILL_ROOT/references/skill-collaboration.md"
PT="/home/terry/.zcode/skills/progress-tracker/SKILL.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'ST-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'ST-%s FAIL %s\n' "$1" "$2"; }

# ST-01
if grep -q '^30\.1 ' "$CRIT" && grep '30\.1' "$CRIT" | grep -q '识别' ; then ok 01 "30.1 识别条件"; else bad 01 "30.1 识别条件缺失"; fi
# ST-02
if grep -q '^30\.2 ' "$CRIT" && grep '30\.2' "$CRIT" | grep -q 'progress-tracker'; then ok 02 "30.2 创建/复用（progress-tracker 权威源）"; else bad 02 "30.2 创建/复用缺失"; fi
# ST-03
if grep -q '^30\.3 ' "$CRIT" && grep '30\.3' "$CRIT" | grep -q '悬挂'; then ok 03 "30.3 认领登记（禁悬挂）"; else bad 03 "30.3 认领登记缺失"; fi
# ST-04
if grep -q '^30\.4 ' "$CRIT" && grep '30\.4' "$CRIT" | grep -q '重复认领'; then ok 04 "30.4 防冲突（重复认领 D4）"; else bad 04 "30.4 防冲突缺失"; fi
# ST-05
if grep -q '^30\.5 ' "$CRIT" && grep '30\.5' "$CRIT" | grep -q 'shared_tracker_enforce'; then ok 05 "30.5 机制（开关键）"; else bad 05 "30.5 机制缺失"; fi
# ST-06
if grep -q 'Rule 30' "$SKILLMD" && grep 'Rule 30' "$SKILLMD" | grep -q '共享内容认领追踪'; then ok 06 "SKILL.md 摘要行 Rule 30"; else bad 06 "SKILL.md 摘要行缺 Rule 30"; fi
# ST-07
if grep -q '共享内容追踪检查点' "$SKILLMD"; then ok 07 "SKILL.md 设计期检查点"; else bad 07 "SKILL.md 设计期检查点缺失"; fi
# ST-08
if grep -q '"shared_tracker_enforce"' "$CONFIG" && python3 -c "
import json,sys
d=json.load(open('$CONFIG'))
k=d['properties']['shared_tracker_enforce']
sys.exit(0 if k.get('default')=='warn' and k.get('enum')==['enforce','warn','off'] else 1)" 2>/dev/null; then
  ok 08 "config.json shared_tracker_enforce（warn 默认+三档）"
else
  bad 08 "config.json shared_tracker_enforce 缺失/默认非 warn"
fi
# ST-09
if [ -f "$TPL" ] && grep -q 'Rule 30' "$TPL"; then ok 09 "templates/shared-tracker.md 存在"; else bad 09 "templates/shared-tracker.md 缺失"; fi
# ST-10
if grep -q 'progress-tracker' "$COLLAB" && grep 'progress-tracker' "$COLLAB" | grep -q 'Rule 30'; then ok 10 "skill-collab 矩阵 progress-tracker 行"; else bad 10 "skill-collab 矩阵缺 progress-tracker 行"; fi
# ST-11
if [ -f "$PT" ]; then ok 11 "progress-tracker 技能探针（存在）"; else bad 11 "progress-tracker 技能缺失（先建 ~/.zcode/skills/progress-tracker/ 再重跑）"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
