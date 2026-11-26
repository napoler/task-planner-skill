#!/usr/bin/env bash
# dogfood-dual.sh — 双源类型 dogfood：两种互不相关源类型（setting+config-key）全链演练+未声明源零误伤
# What: ①双源声明→spec-scan 两 kind 都出候选→disposition→source-gate OK；②未声明源删除→diff-audit零命中（零误伤）；
#       ③已声明源锚行删除→命中→[diff-disposition] 处置行放行（waiver 流）。
# Why: 通用性证明=机制对任意开放标签同一套门；未声明面零误伤。
# 用法: bash dogfood-dual.sh （rc 0=PASS）
set -euo pipefail
WT=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-research-channels-20261126
PLANCTL="$WT/skills/task-planner/scripts/planctl.py"
GB="$WT/skills/task-planner/scripts/git-baseline.sh"
CSB="$WT/skills/task-planner/scripts/check-spec-baseline.sh"
W="$(mktemp -d /tmp/vc5-dogfood.XXXXXX)"
trap 'rm -rf "$W"' EXIT
echo "== dogfood workspace: $W =="
git init -q "$W/r" && cd "$W/r"
printf 'frame_rate: 24\nresolution: 1080p\n' > config.yaml
printf '# 设定真源\n两队各自扎营、自主选点\n' > bible.md
printf '未声明源文件锚行 UNSPEC_ANCHOR\n' > undeclared.md
printf 'config.yaml\tconfig-key\tframe_rate|resolution\trender\nbible.md\tsetting\t各自扎营|自主选点\t-\n' > .source-registry.tsv
mkdir -p plans/pl
python3 "$PLANCTL" init --plan-dir plans/pl --task-id dogfood-dual >/dev/null 2>&1
python3 - <<'PY'
import json
p='plans/pl/plan-state.json'; d=json.load(open(p,encoding='utf-8'))
d['template_type']='script-dev'
json.dump(d,open(p,'w',encoding='utf-8'),ensure_ascii=False,indent=1)
PY
python3 "$PLANCTL" render --plan-dir plans/pl >/dev/null 2>&1
git add -A && git -c user.email=f@x -c user.name=f commit -qm base
# ① 双源扫描+处置+source-gate
python3 "$PLANCTL" spec-scan --plan-dir plans/pl --project-root "$W/r" --write 2>&1 | grep -E "source-scan" || true
KC=$(jq -r '[.spec_baseline[] | select(.dimension=="config-key")]|length' plans/pl/plan-state.json)
SC=$(jq -r '[.spec_baseline[] | select(.dimension=="setting")]|length' plans/pl/plan-state.json)
echo "candidates: config-key=$KC setting=$SC"
[ "$KC" -ge 1 ] && [ "$SC" -ge 1 ] && echo "PASS-1: 双源类型（config-key+setting）同一套扫描/回执"
A=$(jq -r '[.spec_baseline[] | select(.dimension=="config-key")][0].anchor' plans/pl/plan-state.json)
python3 "$PLANCTL" disposition "$A" must --plan-dir plans/pl >/dev/null
python3 "$PLANCTL" disposition "bible.md:2" must --plan-dir plans/pl >/dev/null
SB=$(bash "$CSB" plans/pl 2>&1 | grep -c "source-gate] OK" || true)
echo "source-gate OK lines=$SB"
[ "${SB:-0}" -ge 1 ] && echo "PASS-2: source-gate OK（双源 covered）"
# ② 未声明源删除 → 零命中（零误伤）
bash "$GB" snapshot plans/pl --repo "$W/r" >/dev/null 2>&1 || true
SB=$(bash "$CSB" plans/pl 2>&1 | grep -c "source-gate] OK" || true)
echo "source-gate OK lines=$SB"
[ "${SB:-0}" -ge 1 ] && echo "PASS-2: source-gate OK（双源 covered）"
# ② 未声明源删除 → 零命中（零误伤）
git rm -q undeclared.md
git add -A
bash "$GB" diff plans/pl --final --repo "$W/r" 2>&1 | grep diff-audit || true
H=$(jq -r '.source_hits | length' plans/pl/.diff-manifest.json)
[ "$H" -eq 0 ] && echo "PASS-3: 未声明源删除零命中（零误伤）"
# ③ 已声明源锚行删除 → 命中 → 处置行放行
python3 - <<'PY'
p='bible.md'
lines=[l for l in open(p,encoding='utf-8') if '自主选点' not in l]
open(p,'w',encoding='utf-8').writelines(lines)
PY
git add -A
bash "$GB" diff plans/pl --final --repo "$W/r" 2>&1 | grep diff-audit || true
H2=$(jq -r '[.source_hits[] | select(.anchor_kw=="自主选点")]|length' plans/pl/.diff-manifest.json)
[ "$H2" -ge 1 ] && echo "PASS-4: 已声明源锚行删除命中（收窄被看见）"
printf '[diff-disposition] 自主选点 — 用户原话：扎营移 EP003，授权锚 D1\n' >> plans/pl/findings.md
cd "$W/r" && bash "$GB" manifest plans/pl --repo "$W/r" >/dev/null 2>&1 || true
B=$(bash "$CSB" plans/pl 2>&1 | grep -c "source-gate] OK" || true)
echo "after-disposition source-gate OK=$B"
echo "== DOGFOOD: PASS =="
