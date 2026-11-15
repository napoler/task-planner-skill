#!/usr/bin/env bash
# selftest-plan-history-recall.sh — plan-history-recall 技能交付物完整性与护栏锚静态守护（HPR-01..HPR-08）
# 目的：验证 plan-history-recall skill、引用契约、伴飞执行体、task-planner 接线与 registry 自登记在位且关键护栏锚未漂移。
# 依赖锚清单：
#   - skills/plan-history-recall/SKILL.md: ^name: plan-history-recall / 候选任务 ≤8 / 每代理 ≤3 任务 / 简报 ≤150 行 / ≤60 行
#   - skills/plan-history-recall/references/experience-card-schema.md: 未查到 / 证据锚格式
#   - skills/plan-history-recall/references/brief-template.md: 护栏自检 / 未覆盖面
#   - skills/task-planner/companion/agents/history-miner.md: ^name: history-miner / custom:9e221f47-3040-4ea7-b742-20b813fb79aa:haiku-1 / tools: [Read, Write, Bash, Grep, Glob]
#   - skills/task-planner/SKILL.md: plan-history-recall 接线行
#   - skills/task-planner/scripts/selftest-registry.tsv: 首列 selftest-plan-history-recall.sh 自登记行
#   - skills/task-planner/companion/agents/{history-miner,drift-checker}.md: ^model: 行逐字相等（HPR-06）

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

PHR_SKILL="$ROOT/skills/plan-history-recall/SKILL.md"
SCHEMA="$ROOT/skills/plan-history-recall/references/experience-card-schema.md"
BRIEF="$ROOT/skills/plan-history-recall/references/brief-template.md"
MINER="$ROOT/skills/task-planner/companion/agents/history-miner.md"
DRIFT="$ROOT/skills/task-planner/companion/agents/drift-checker.md"
TP_SKILL="$ROOT/skills/task-planner/SKILL.md"
REG="$ROOT/skills/task-planner/scripts/selftest-registry.tsv"

PASS=0
FAIL=0

ok()  { PASS=$((PASS+1)); printf 'HPR-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'HPR-%s FAIL %s\n' "$1" "$2"; }

# HPR-01 plan-history-recall SKILL 基本标识与候选/并行护栏
if grep -q '^name: plan-history-recall' "$PHR_SKILL" \
  && grep -q '候选任务 ≤8' "$PHR_SKILL" \
  && grep -q '每代理 ≤3 任务' "$PHR_SKILL"; then
  ok 01 "plan-history-recall SKILL 含 name/候选任务≤8/每代理≤3任务"
else
  bad 01 "plan-history-recall SKILL 缺 name/候选任务≤8/每代理≤3任务"
fi

# HPR-02 plan-history-recall SKILL 行数护栏锚
if grep -q '简报 ≤150 行' "$PHR_SKILL" \
  && grep -q '≤60 行' "$PHR_SKILL"; then
  ok 02 "plan-history-recall SKILL 含简报≤150行/≤60行护栏"
else
  bad 02 "plan-history-recall SKILL 缺简报≤150行或≤60行护栏"
fi

# HPR-03 experience-card-schema 契约锚
if grep -q '未查到' "$SCHEMA" \
  && grep -q '证据锚格式' "$SCHEMA"; then
  ok 03 "experience-card-schema 含未查到/证据锚格式"
else
  bad 03 "experience-card-schema 缺未查到或证据锚格式"
fi

# HPR-04 brief-template 契约锚
if grep -q '护栏自检' "$BRIEF" \
  && grep -q '未覆盖面' "$BRIEF"; then
  ok 04 "brief-template 含护栏自检/未覆盖面"
else
  bad 04 "brief-template 缺护栏自检或未覆盖面"
fi

# HPR-05 history-miner 执行体锚
if grep -q '^name: history-miner' "$MINER" \
  && grep -q 'custom:9e221f47-3040-4ea7-b742-20b813fb79aa:haiku-1' "$MINER" \
  && grep -q 'tools: \[Read, Write, Bash, Grep, Glob\]' "$MINER"; then
  ok 05 "history-miner 含 name/model/tools 锚"
else
  bad 05 "history-miner 缺 name/model/tools 锚"
fi

# HPR-06 history-miner 与 drift-checker ^model: 行逐字相等
MINER_MODEL="$(grep '^model:' "$MINER" 2>/dev/null || true)"
DRIFT_MODEL="$(grep '^model:' "$DRIFT" 2>/dev/null || true)"
if [ -n "$MINER_MODEL" ] && [ "$MINER_MODEL" = "$DRIFT_MODEL" ]; then
  ok 06 "history-miner 与 drift-checker ^model: 行逐字相等"
else
  bad 06 "history-miner 与 drift-checker ^model: 行不一致或缺失"
fi

# HPR-07 task-planner 接线锚
if grep -q 'plan-history-recall' "$TP_SKILL"; then
  ok 07 "task-planner SKILL 含 plan-history-recall 接线"
else
  bad 07 "task-planner SKILL 缺 plan-history-recall 接线"
fi

# HPR-08 registry 自登记行锚
if grep -q '^selftest-plan-history-recall.sh' "$REG"; then
  ok 08 "registry 含 selftest-plan-history-recall.sh 自登记行"
else
  bad 08 "registry 缺 selftest-plan-history-recall.sh 自登记行"
fi

echo "Total: 8 PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
