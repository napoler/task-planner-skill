#!/usr/bin/env bash
# selftest-plan-history-recall.sh — plan-history-recall 技能交付物完整性与护栏锚静态守护（HPR-01..HPR-09）
# 目的：验证 plan-history-recall skill、引用契约、伴飞执行体、task-planner 接线与 registry 自登记在位且关键护栏锚未漂移。
# 依赖锚清单：
#   - skills/plan-history-recall/SKILL.md: ^name: plan-history-recall / 候选任务 ≤8 / 每代理 ≤3 任务 / 简报 ≤150 行 / ≤60 行 / 分轮，按轮合并简报 / 行号锚必须 ≤ wc -l / Skill("plan-history-recall") 接线相关产物路径
#   - skills/plan-history-recall/references/experience-card-schema.md: 未查到 / 证据锚格式 / 行号 ≤ wc -l（越界=无效锚）
#   - skills/plan-history-recall/references/brief-template.md: 护栏自检 / 未覆盖面
#   - skills/task-planner/companion/agents/history-miner.md: ^name: history-miner / tools: [Read, Write, Bash, Grep, Glob] / 行号 ≤ wc -l（越界=无效锚）（模型一致性由 HPR-06 动态校验独占）
#   - skills/task-planner/SKILL.md: 可选前置（历史经验）**：L1+ 新任务主题涉同类改造 接线行
#   - skills/task-planner/scripts/selftest-registry.tsv: 首列 selftest-plan-history-recall.sh 自登记行
#   - skills/task-planner/companion/agents/{history-miner,drift-checker}.md: ^model: 行逐字相等（HPR-06）
#   - HPR-09 目标产物(HPR_DIR, 默认主仓 plans/task-history-recall-20261116/history-recall/): cards/*.md 与 history-brief.md 锚 .md:行号 可解析且路径存在/行号 ≤ wc -l
# 用例：HPR-01..HPR-09

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
HPR_DIR="${HPR_DIR:-$ROOT/plans/task-history-recall-20261116/history-recall}"
ANCHOR_ROOT="${ANCHOR_ROOT:-$ROOT}"

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

# HPR-05 history-miner 执行体锚（模型一致性由 HPR-06 动态校验独占）
if grep -q '^name: history-miner' "$MINER" \
  && grep -q 'tools: \[Read, Write, Bash, Grep, Glob\]' "$MINER"; then
  ok 05 "history-miner 含 name/tools 锚"
else
  bad 05 "history-miner 缺 name/tools 锚"
fi

# HPR-06 history-miner 与 drift-checker ^model: 行逐字相等
MINER_MODEL="$(grep '^model:' "$MINER" 2>/dev/null || true)"
DRIFT_MODEL="$(grep '^model:' "$DRIFT" 2>/dev/null || true)"
if [ -n "$MINER_MODEL" ] && [ "$MINER_MODEL" = "$DRIFT_MODEL" ]; then
  ok 06 "history-miner 与 drift-checker ^model: 行逐字相等"
else
  bad 06 "history-miner 与 drift-checker ^model: 行不一致或缺失"
fi

# HPR-07 task-planner 接线锚（收紧到可选前置接线行特征串）
if grep -Fq '可选前置（历史经验）**：L1+ 新任务主题涉同类改造' "$TP_SKILL"; then
  ok 07 "task-planner SKILL 含 plan-history-recall 可选前置接线"
else
  bad 07 "task-planner SKILL 缺 plan-history-recall 可选前置接线"
fi

# HPR-08 registry 自登记行锚
if grep -q '^selftest-plan-history-recall.sh' "$REG"; then
  ok 08 "registry 含 selftest-plan-history-recall.sh 自登记行"
else
  bad 08 "registry 缺 selftest-plan-history-recall.sh 自登记行"
fi

# HPR-09 锚可解析断言：对 HPR_DIR 下 cards/*.md 与 history-brief.md 提取 .md:行号 锚，路径存在且行号 ≤ wc -l
hpr09_skipped=0
hpr09_ok=1
hpr09_msg=""
if [ ! -d "$HPR_DIR" ]; then
  hpr09_skipped=1
  echo "WARN HPR-09 无可解析锚或 HPR_DIR 缺失，跳过（不计 PASS 不计 FAIL）"
else
  checked=0
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    # extract anchors like path/to/file.md:123, path/to/file.md:10-20, or multi-point path/to/file.md:1,5-7,9
    while IFS= read -r anchor; do
      [ -n "$anchor" ] || continue
      apath="${anchor%%:*}"
      ranges="${anchor#*:}"
      # resolve path relative to anchor root if not absolute
      if [[ "$apath" = /* ]]; then
        rpath="$apath"
      else
        rpath="$ANCHOR_ROOT/$apath"
      fi
      if [ ! -f "$rpath" ]; then
        hpr09_ok=0
        hpr09_msg="锚路径不存在: $anchor (in $(basename "$f"))"
        break 2
      fi
      total="$(wc -l < "$rpath")"
      IFS=',' read -r -a tokens <<< "$ranges"
      for tok in "${tokens[@]}"; do
        [ -n "$tok" ] || continue
        start="${tok%-*}"
        end="${tok#*-}"
        if ! [[ "$start" =~ ^[0-9]+$ && "$end" =~ ^[0-9]+$ ]]; then
          hpr09_ok=0
          hpr09_msg="锚行号格式非法: $anchor (in $(basename "$f"))"
          break 3
        fi
        if [ "$start" -lt 1 ] || [ "$end" -lt 1 ] || [ "$start" -gt "$end" ] || [ "$start" -gt "$total" ] || [ "$end" -gt "$total" ]; then
          hpr09_ok=0
          hpr09_msg="锚行号越界(>${total}): $anchor (in $(basename "$f"))"
          break 3
        fi
      done
      checked=$((checked+1))
    done < <(grep -oE '[A-Za-z0-9_./-]+\.md:[0-9]+(-[0-9]+)?(,[0-9]+(-[0-9]+)?)*' "$f" 2>/dev/null || true)
  done < <(find "$HPR_DIR" -maxdepth 2 -type f \( -path "$HPR_DIR/cards/*.md" -o -name 'history-brief.md' \) 2>/dev/null | sort)
  if [ "$hpr09_ok" -eq 1 ] && [ "$checked" -eq 0 ]; then
    hpr09_skipped=1
    echo "WARN HPR-09 无可解析锚或 HPR_DIR 缺失，跳过（不计 PASS 不计 FAIL）"
  fi
fi
if [ "$hpr09_skipped" -eq 0 ]; then
  if [ "$hpr09_ok" -eq 1 ]; then
    ok 09 "HPR_DIR 锚可解析且路径存在/行号≤wc -l"
  else
    bad 09 "$hpr09_msg"
  fi
fi

TOTAL=$((PASS+FAIL))
echo "Total: $TOTAL PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
