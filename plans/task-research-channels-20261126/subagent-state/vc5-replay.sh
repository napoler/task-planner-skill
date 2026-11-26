#!/usr/bin/env bash
# vc5-replay.sh — VC-5 真数据回放：用《钓友请就位》真实事故形态验证新门能拦（StoryLab 本体零写入）
# What: ①声明 StoryLab bible.md 为源（setting 维度）→ spec-scan 应出「各自扎营/自主选点」候选；
#       ②复刻 episode-map.md:46 收窄形态（删除扎营行）→ git-baseline diff --final 应出 source_hits（事故被拦证据）。
# Why: 判别性验收=用真实事故数据证明机制有效；复制到临时仓演练，StoryLab 只读。
# 用法: bash vc5-replay.sh   （本脚本属计划 plans/task-research-channels-20261126/，rc 0=PASS）
set -euo pipefail
STORYLAB=/mnt/data/dev/StoryLab
SRC_DIR="$STORYLAB/docs/series/diaoyou-qingjiuwei"
WT=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-research-channels-20261126
PLANCTL="$WT/skills/task-planner/scripts/planctl.py"
GB="$WT/skills/task-planner/scripts/git-baseline.sh"
WORK="$(mktemp -d /tmp/vc5-replay.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT
echo "== VC-5 replay workspace: $WORK =="

# ── ① 声明 bible.md 为源 → spec-scan 出设定候选 ──────────────────
git init -q "$WORK/repo1" && cd "$WORK/repo1"
cp "$SRC_DIR/bible.md" docs-bible.md 2>/dev/null || cp "$SRC_DIR/bible.md" bible.md
printf 'docs-bible.md\tsetting\t各自扎营|自主选点|分营\t-\n' > .source-registry.tsv
mkdir -p plans/pl && python3 "$PLANCTL" init --plan-dir plans/pl --task-id vc5-replay 2>&1 | tail -2
git add -A && git -c user.email=f@x -c user.name=f commit -qm base
python3 "$PLANCTL" spec-scan --plan-dir plans/pl --project-root "$WORK/repo1" --write 2>&1 | grep source-scan || true
python3 "$PLANCTL" spec-scan --plan-dir plans/pl --project-root "$WORK/repo1" --write >/dev/null 2>&1 || true
CAND=$(jq -r '[.spec_baseline[]? | select(.dimension=="setting")] | length' plans/pl/plan-state.json)
echo "candidates(setting)=$CAND"
[ "$CAND" -ge 1 ] || { echo "FAIL: bible 声明源扫描零候选"; exit 1; }
jq -r '.spec_baseline[] | select(.dimension=="setting") | .verbatim' plans/pl/各自 2>/dev/null || true
grep -q "自主选点" <(jq -r '.spec_baseline[].verbatim' plans/pl/plan-state.json) && echo "PASS-1: bible.md 声明源扫描出「自主选点」候选（当时若有此门即拦住事故）"

# ── ② 复刻收窄形态：删除扎营行 → diff-audit 命中 ──────────────────
git init -q "$WORK/repo2" && cd "$WORK/repo2"
cp "$SRC_DIR/bible.md" bible.md
# 基线 = 含扎营锚词的完整态
printf 'bible.md\tsetting\t各自扎营|自主选点|分营\t-\n' > .source-registry.tsv
mkdir -p plans/p1 && echo x > plans/p1/task_plan.md
git add -A && git -c user.email=f@x -c user.name=f commit -qm base
bash "$GB" snapshot plans/p1 --repo "$WORK/repo2" >/dev/null 2>&1
# 事故形态：把扎营/选点行从 bible.md 中删除（episode-map.md:46 的"只演发物料"收窄的等价形态）
python3 - <<'PY'
import re
p='bible.md'
lines=[l for l in open(p,encoding='utf-8') if ('扎营' not in l and '自主选点' not in l)]
open(p,'w',encoding='utf-8').writelines(lines)
PY
git add bible.md
bash "$GB" diff plans/p1 --final --repo "$WORK/repo2" 2>&1 | grep diff-audit || true
HITS=$(jq -r '.source_hits | length' plans/p1/.diff-manifest.json)
[ "$HITS" -ge 1 ] || { echo "FAIL: 收窄形态零命中"; exit 1; }
echo "PASS-2: 收窄形态被拦——删除行命中声明源锚 $(jq -r '.source_hits[0].anchor_kw' plans/p1/.diff-manifest.json)（无 [diff-disposition]/[source-waiver] 处置行则终验门 FAIL）"
echo "== VC-5 REPLAY: PASS =="
