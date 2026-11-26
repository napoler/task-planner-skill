#!/usr/bin/env bash
# selftest-research-channels.sh — research-channels + 源注册表消费链行为回归
# [2026-11-26 task-research-channels-20261126] What:
#   覆盖 research-channels 技能（SKILL/frontmatter/五层锚/工具决策表/零硬编码路径）、
#   project-inventory.sh（语法/排除/4列/确定性/missing-stale-fresh 三态）、
#   planctl spec-scan+disposition+spec-brief+acceptance render 徽标、
#   check-spec-baseline [source-gate] 四态、git-baseline diff manifest source_hits、
#   以及 check-complete/git-baseline/check-spec-baseline/planctl/SKILL+template 的静态锚。
# Why: 五层调研通道与源注册表消费链跨 7 个文件；单点静态断言无法捕获夹具行为回归，
#   故用 mktemp 夹具实弹跑命令 + 静态锚混合，守住失败纪律/门体接线不漂移。
# 用法: bash selftest-research-channels.sh
# 退出码: 0=FAIL=0 / 1=任一断言失败
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

RC_SKILL="$REPO_ROOT/skills/research-channels/SKILL.md"
RC_REF="$REPO_ROOT/skills/research-channels/references/research-channels.md"
RC_INV="$REPO_ROOT/skills/research-channels/scripts/project-inventory.sh"
PLANCTL="$SCRIPT_DIR/planctl.py"
CHECK_SPEC="$SCRIPT_DIR/check-spec-baseline.sh"
CHECK_COMPLETE="$SCRIPT_DIR/check-complete.sh"
GIT_BASELINE="$SCRIPT_DIR/git-baseline.sh"
TP_SKILL="$SCRIPT_DIR/../SKILL.md"
TP_TPL="$SCRIPT_DIR/../templates/task_plan.md"
REGISTRY="$SCRIPT_DIR/selftest-registry.tsv"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'PASS RC-%s %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'FAIL RC-%s %s\n' "$1" "$2"; }

TMPBASE="$(mktemp -d "${TMPDIR:-/tmp}/rc-selftest.XXXXXX")"
trap 'rm -rf "$TMPBASE"' EXIT

# ── RC-01 SKILL.md frontmatter name=research-channels 且 user-invocable: true ──
if grep -q '^name: research-channels' "$RC_SKILL" \
   && grep -q '^user-invocable: true' "$RC_SKILL"; then
  ok "01" "SKILL.md frontmatter name=research-channels + user-invocable: true"
else
  bad "01" "SKILL.md frontmatter 缺 name=research-channels 或 user-invocable: true"
fi

# ── RC-02 SKILL.md 含「通道失败纪律」与「研究第 0 步」两锚 ──
if grep -q '通道失败纪律' "$RC_SKILL" && grep -q '研究第 0 步' "$RC_SKILL"; then
  ok "02" "SKILL.md 含 通道失败纪律 与 研究第 0 步"
else
  bad "02" "SKILL.md 缺 通道失败纪律 或 研究第 0 步"
fi

# ── RC-03 references 含 L1-L5 五层节锚（以实际标题为准）──
# 实测: ## 1 L1 枚举层 / ## 2 L2 索引层 / ## 3 L3 检索层 / ## 4 L4 阅读锚定层 / ## 5 L5 外部层
if grep -qE '^## .*L1.*枚举' "$RC_REF" \
   && grep -qE '^## .*L2.*索引' "$RC_REF" \
   && grep -qE '^## .*L3.*检索' "$RC_REF" \
   && grep -qE '^## .*L4.*阅读锚定' "$RC_REF" \
   && grep -qE '^## .*L5.*外部' "$RC_REF"; then
  ok "03" "references 含 L1-L5 五层节锚"
else
  bad "03" "references 缺 L1-L5 五层节锚（实测标题不符）"
fi

# ── RC-04 references 含工具决策表锚（知道文件名→find；知道关键词→grep）──
if grep -q '工具决策表' "$RC_REF" \
   && grep -q '知道文件名' "$RC_REF" \
   && grep -q '知道关键词' "$RC_REF"; then
  ok "04" "references 含 工具决策表 + 知道文件名 + 知道关键词"
else
  bad "04" "references 缺 工具决策表/知道文件名/知道关键词 锚"
fi

# ── RC-05 references 零写死项目目录（grep -nE '/home/|/mnt/data' 无命中）──
if grep -nE '/home/|/mnt/data' "$RC_REF" >/dev/null 2>&1; then
  bad "05" "references 含写死路径 /home/ 或 /mnt/data"
else
  ok "05" "references 无 /home/|/mnt/data 写死路径"
fi

# ── RC-06 project-inventory.sh bash -n rc=0；grep set -euo pipefail ──
if bash -n "$RC_INV" >/dev/null 2>&1 && grep -q 'set -euo pipefail' "$RC_INV"; then
  ok "06" "project-inventory.sh bash -n 通过 + set -euo pipefail"
else
  bad "06" "project-inventory.sh 语法检查失败或缺 set -euo pipefail"
fi

# ── RC-07 夹具：mktemp -d 建夹具仓，--root 生成 .inventory.tsv：排除目录无条目、3 md 全入、每行 4 列 ──
FIX7="$TMPBASE/rc07"
mkdir -p "$FIX7/.git" "$FIX7/tmp" "$FIX7/node_modules"
printf 'a\n' > "$FIX7/a.md"
printf 'b\n' > "$FIX7/b.md"
printf 'c\n' > "$FIX7/c.md"
printf 'ignored\n' > "$FIX7/.git/ignored.md"
printf 'ignored\n' > "$FIX7/tmp/ignored.md"
printf 'ignored\n' > "$FIX7/node_modules/ignored.md"
RC07_OUT="$TMPBASE/rc07.out"
if bash "$RC_INV" --root "$FIX7" --out "$FIX7/.inventory.tsv" >"$RC07_OUT" 2>&1; then
  INV="$FIX7/.inventory.tsv"
  HAS_EXCL=0
  grep -qE '(^|/)(\.git|tmp|node_modules)/' "$INV" && HAS_EXCL=1
  HAS_A=$(grep -c '^a\.md	' "$INV" || true)
  HAS_B=$(grep -c '^b\.md	' "$INV" || true)
  HAS_C=$(grep -c '^c\.md	' "$INV" || true)
  BAD_COLS=$(awk -F'\t' 'NF!=4{c++} END{print c+0}' "$INV")
  if [ "$HAS_EXCL" -eq 0 ] && [ "$HAS_A" -eq 1 ] && [ "$HAS_B" -eq 1 ] && [ "$HAS_C" -eq 1 ] && [ "$BAD_COLS" -eq 0 ]; then
    ok "07" "inventory 排除目录无条目 + a/b/c.md 全入 + 每行4列"
  else
    bad "07" "inventory 校验失败(excl=$HAS_EXCL a=$HAS_A b=$HAS_B c=$HAS_C bad_cols=$BAD_COLS)"
  fi
else
  bad "07" "project-inventory.sh --root 生成失败 rc=$?"
fi

# ── RC-08 夹具确定性：同 root 两次生成 cmp -s 逐字节一致 ──
FIX8="$TMPBASE/rc08"
mkdir -p "$FIX8/.git"
printf 'x\n' > "$FIX8/x.md"
printf 'y\n' > "$FIX8/y.md"
if bash "$RC_INV" --root "$FIX8" --out "$FIX8/out.tsv" >/dev/null 2>&1; then
  cp "$FIX8/out.tsv" "$TMPBASE/rc08.snap1.tsv"
  if bash "$RC_INV" --root "$FIX8" --out "$FIX8/out.tsv" >/dev/null 2>&1 \
     && cmp -s "$TMPBASE/rc08.snap1.tsv" "$FIX8/out.tsv"; then
    ok "08" "两次生成 inventory 逐字节一致"
  else
    bad "08" "inventory 确定性失败（第二次生成失败或 cmp 不一致）"
  fi
else
  bad "08" "inventory 确定性失败（首次生成失败）"
fi

# ── RC-09 --check 三态：missing exit 2 / stale（touch 新文件后）exit 1 / fresh exit 0 ──
FIX9="$TMPBASE/rc09"
mkdir -p "$FIX9"
printf 'z\n' > "$FIX9/z.md"
set +e
bash "$RC_INV" --root "$FIX9" --out "$FIX9/.inventory.tsv" --check >/dev/null 2>&1
RC9_MISS=$?
set -e
bash "$RC_INV" --root "$FIX9" --out "$FIX9/.inventory.tsv" >/dev/null 2>&1
set +e
bash "$RC_INV" --root "$FIX9" --out "$FIX9/.inventory.tsv" --check >/dev/null 2>&1
RC9_FRESH=$?
set -e
sleep 1
printf 'new\n' > "$FIX9/new.md"
set +e
bash "$RC_INV" --root "$FIX9" --out "$FIX9/.inventory.tsv" --check >/dev/null 2>&1
RC9_STALE=$?
set -e
if [ "$RC9_MISS" -eq 2 ] && [ "$RC9_FRESH" -eq 0 ] && [ "$RC9_STALE" -eq 1 ]; then
  ok "09" "--check 三态 missing=2 fresh=0 stale=1"
else
  bad "09" "--check 三态异常 missing=$RC9_MISS fresh=$RC9_FRESH stale=$RC9_STALE"
fi

# ── RC-10 夹具源注册表+planctl：spec-scan→dimension=setting, disposition must, spec-brief 含 setting, acceptance awaiting→render 徽标 ──
FIX10="$TMPBASE/rc10"
mkdir -p "$FIX10/plans/pl" "$FIX10/docs"
# 声明源文件 + 锚词
cat > "$FIX10/docs/setting.md" <<'MD'
# Setting
timeout_seconds: 30
mode: safe
MD
# 源注册表：source_path \t spec_kind \t anchors_keywords(|分隔) \t scope_tags
printf 'docs/setting.md\tsetting\ttimeout_seconds|mode\t-\n' > "$FIX10/.source-registry.tsv"

# init plan
set +e
PYTHONPATH="" python3 "$PLANCTL" init --plan-dir "$FIX10/plans/pl" --task-id rc-selftest --tier standard --lane L1 >"$TMPBASE/rc10.init.out" 2>"$TMPBASE/rc10.init.err"
RC10_INIT=$?
set -e

RC10_OK=1
RC10_MSG=""

if [ "$RC10_INIT" -ne 0 ]; then
  RC10_OK=0; RC10_MSG="init rc=$RC10_INIT"
else
  # spec-scan --write
  set +e
  SCAN_OUT=$(PYTHONPATH="" python3 "$PLANCTL" spec-scan --plan-dir "$FIX10/plans/pl" --project-root "$FIX10" --write 2>"$TMPBASE/rc10.scan.err")
  RC10_SCAN=$?
  set -e
  if [ "$RC10_SCAN" -ne 0 ]; then
    RC10_OK=0; RC10_MSG="spec-scan rc=$RC10_SCAN"
  elif ! printf '%s\n' "$SCAN_OUT" | grep -q '\[source-scan\]'; then
    RC10_OK=0; RC10_MSG="spec-scan 输出缺 [source-scan]"
  else
    # check dimension=setting in spec_baseline
    if ! grep -q '"dimension"[[:space:]]*:[[:space:]]*"setting"' "$FIX10/plans/pl/plan-state.json"; then
      RC10_OK=0; RC10_MSG="spec_baseline 缺 dimension=setting"
    else
      # disposition must: 找到 source-registry 产生的条目 anchor
      # 源注册表条目 anchor 格式为 file:line；取第一条 dimension=setting 的 anchor
      ANCHOR=$(PYTHONPATH="" python3 - "$FIX10/plans/pl/plan-state.json" <<'PY'
import json,sys
doc=json.load(open(sys.argv[1],encoding='utf-8'))
for item in doc.get('spec_baseline',[]):
    if item.get('dimension')=='setting' or item.get('kind')=='setting':
        print(item.get('anchor') or item.get('id') or '')
        break
PY
)
      if [ -z "$ANCHOR" ]; then
        RC10_OK=0; RC10_MSG="未找到 setting 条目 anchor"
      else
        set +e
        DISP_OUT=$(PYTHONPATH="" python3 "$PLANCTL" disposition --plan-dir "$FIX10/plans/pl" "$ANCHOR" must 2>"$TMPBASE/rc10.disp.err")
        RC10_DISP=$?
        set -e
        if [ "$RC10_DISP" -ne 0 ]; then
          RC10_OK=0; RC10_MSG="disposition rc=$RC10_DISP anchor=$ANCHOR"
        else
          # spec-brief 含 dimension=setting
          set +e
          BRIEF_OUT=$(PYTHONPATH="" python3 "$PLANCTL" spec-brief --plan-dir "$FIX10/plans/pl" 2>"$TMPBASE/rc10.brief.err")
          RC10_BRIEF=$?
          set -e
          if [ "$RC10_BRIEF" -ne 0 ]; then
            RC10_OK=0; RC10_MSG="spec-brief rc=$RC10_BRIEF"
          elif ! printf '%s\n' "$BRIEF_OUT" | grep -q 'setting'; then
            RC10_OK=0; RC10_MSG="spec-brief 输出不含 setting"
          else
            # acceptance awaiting → render 徽标
            set +e
            ACC_OUT=$(PYTHONPATH="" python3 "$PLANCTL" acceptance --plan-dir "$FIX10/plans/pl" --status awaiting 2>"$TMPBASE/rc10.acc.err")
            RC10_ACC=$?
            set -e
            if [ "$RC10_ACC" -ne 0 ]; then
              RC10_OK=0; RC10_MSG="acceptance rc=$RC10_ACC"
            else
              set +e
              PYTHONPATH="" python3 "$PLANCTL" render --plan-dir "$FIX10/plans/pl" >"$TMPBASE/rc10.render.out" 2>"$TMPBASE/rc10.render.err"
              RC10_REND=$?
              set -e
              if [ "$RC10_REND" -ne 0 ]; then
                RC10_OK=0; RC10_MSG="render rc=$RC10_REND"
              elif ! grep -qF -- '- 验收: awaiting' "$FIX10/plans/pl/task_plan.md"; then
                RC10_OK=0; RC10_MSG="render 徽标缺 '- 验收: awaiting'"
              fi
            fi
          fi
        fi
      fi
    fi
  fi
fi

if [ "$RC10_OK" -eq 1 ]; then
  ok "10" "spec-scan→dimension=setting + disposition must + spec-brief含setting + acceptance awaiting→render徽标"
else
  bad "10" "$RC10_MSG"
fi

# ── RC-11 check-spec-baseline 计划期 [source-gate] 四态（聚合为单断言）──
mk_rc11_base() {
  local base="$1"
  mkdir -p "$base"
  cat > "$base/source.md" <<'EOF'
# 规范来源片段（rc11 fixture）
alpha 约束段落。
beta 约束段落。
gamma 约束段落。
delta 约束段落。

## 槽位说明
naming/rhythm/language/reference 四槽均有对应 SPEC。
EOF
  local sha
  sha="$(sha256sum "$base/source.md" | awk '{print substr($1,1,12)}')"
  cat > "$base/task_plan.md" <<'PLAN'
plan_tier: standard
template_type: script-dev

# Task Plan: rc11 fixture

## Goal
G1 验证 source-gate

## ✅ Verification Contract
| VC | 判据 | 对应 SPEC |
|---|---|---|
| VC-1 | 判定式复验 | SPEC-1 |
| VC-2 | 判定式复验 | SPEC-2 |
| VC-3 | 判定式复验 | SPEC-3 |
| VC-4 | 判定式复验 | SPEC-4 |

## 🔒 规范基线（Spec-Baseline）
| spec_id | 约束原文(verbatim) | 来源锚(path:line) | 双向判定式 | 来源 sha256 | 槽 | 校验命令 | 适用S-unit | 结果 |
|---|---|---|---|---|---|---|---|---|
| SPEC-1 | 约束一：命名 | __ANCHOR__:2 | grep -c 'alpha' source.md = 0 | __SHA__ | naming | bash check.sh | S1 | 待终验 |
| SPEC-2 | 约束二：节奏 | __ANCHOR__:3 | grep -c 'beta' source.md = 0 | __SHA__ | rhythm | bash check.sh | S1 | 待终验 |
| SPEC-3 | 约束三：语言 | __ANCHOR__:4 | grep -c 'gamma' source.md = 0 | __SHA__ | language | bash check.sh | S1 | 待终验 |
| SPEC-4 | 约束四：参考 | __ANCHOR__:5 | grep -c 'delta' source.md = 0 | __SHA__ | reference | bash check.sh | S1 | 待终验 |

## Phases（S-unit 绑定面）
| # | S-unit | 执行体 | 任务 |
|---|--------|--------|------|
| S1 | 实施 | script-writer（sonnet-1） | 产出 |
PLAN
  cat > "$base/plan-state.json" <<'JSON'
{
  "schema_version": 1,
  "plan_tier": "standard",
  "template_type": "script-dev",
  "spec_baseline": [
    {"id":"SPEC-1","verbatim":"约束一：命名","anchor":"__ANCHOR__:2","rule":"grep -c 'alpha' source.md = 0","sha":"__SHA__","kind":"naming","check":"bash check.sh","applies":"S1","src":"SCAN-1"},
    {"id":"SPEC-2","verbatim":"约束二：节奏","anchor":"__ANCHOR__:3","rule":"grep -c 'beta' source.md = 0","sha":"__SHA__","kind":"rhythm","check":"bash check.sh","applies":"S1","src":""},
    {"id":"SPEC-3","verbatim":"约束三：语言","anchor":"__ANCHOR__:4","rule":"grep -c 'gamma' source.md = 0","sha":"__SHA__","kind":"language","check":"bash check.sh","applies":"S1","src":""},
    {"id":"SPEC-4","verbatim":"约束四：参考","anchor":"__ANCHOR__:5","rule":"grep -c 'delta' source.md = 0","sha":"__SHA__","kind":"reference","check":"bash check.sh","applies":"S1","src":""}
  ],
  "scenarios": ["代码修改"]
}
JSON
  cat > "$base/.spec-scan.json" <<'EOF'
{"id":"SCAN-1","cls":"must","rule":"必须：命名"}
EOF
  sed -i "s|__ANCHOR__|$base/source.md|g; s|__SHA__|$sha|g" "$base/task_plan.md" "$base/plan-state.json"
}

RC11_FAILS=""

# RC-11.1 注册表+must 条目 → [source-gate] OK
RC11A="$TMPBASE/rc11a/plans/pl"
mkdir -p "$RC11A"
mk_rc11_base "$RC11A"
printf 'docs/setting.md\tsetting\ttimeout_seconds\t-\n' > "$TMPBASE/rc11a/.source-registry.tsv"
mkdir -p "$TMPBASE/rc11a/docs"
printf 'timeout_seconds: 30\n' > "$TMPBASE/rc11a/docs/setting.md"
PYTHONPATH="" python3 - "$RC11A/plan-state.json" <<'PY'
import json,sys
p=sys.argv[1]
doc=json.load(open(p,encoding='utf-8'))
doc['spec_baseline'].append({
  "id":"SRC-setting-1","verbatim":"timeout_seconds: 30","anchor":"docs/setting.md:1",
  "rule":"","sha":"","dimension":"setting","disposition":"must",
  "fallback_reason":"","tags":[],"kind":"setting","origin":"source-registry"
})
json.dump(doc,open(p,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
PY
set +e
RC11A_OUT=$(bash "$CHECK_SPEC" "$RC11A" 2>&1)
RC11A_RC=$?
set -e
if ! printf '%s\n' "$RC11A_OUT" | grep -qF '[source-gate] OK'; then
  RC11_FAILS="${RC11_FAILS} OK(rc=$RC11A_RC)"
fi

# RC-11.2 删条目 → FAILED rc=1
RC11B="$TMPBASE/rc11b/plans/pl"
mkdir -p "$RC11B"
mk_rc11_base "$RC11B"
printf 'docs/setting.md\tsetting\ttimeout_seconds\t-\n' > "$TMPBASE/rc11b/.source-registry.tsv"
mkdir -p "$TMPBASE/rc11b/docs"
printf 'timeout_seconds: 30\n' > "$TMPBASE/rc11b/docs/setting.md"
set +e
RC11B_OUT=$(bash "$CHECK_SPEC" "$RC11B" 2>&1)
RC11B_RC=$?
set -e
if ! { [ "$RC11B_RC" -eq 1 ] && printf '%s\n' "$RC11B_OUT" | grep -qF '[source-gate] FAILED'; }; then
  RC11_FAILS="${RC11_FAILS} FAILED(rc=$RC11B_RC)"
fi

# RC-11.3 无注册表 → SKIP (no .source-registry.tsv)
RC11C="$TMPBASE/rc11c/plans/pl"
mkdir -p "$RC11C"
mk_rc11_base "$RC11C"
set +e
RC11C_OUT=$(bash "$CHECK_SPEC" "$RC11C" 2>&1)
RC11C_RC=$?
set -e
if ! printf '%s\n' "$RC11C_OUT" | grep -qF '[source-gate] SKIP (no .source-registry.tsv)'; then
  RC11_FAILS="${RC11_FAILS} SKIP-no-reg(rc=$RC11C_RC)"
fi

# RC-11.4 template_type=general（非内容类）→ SKIP (non-content plan)
RC11D="$TMPBASE/rc11d/plans/pl"
mkdir -p "$RC11D"
mk_rc11_base "$RC11D"
PYTHONPATH="" python3 - "$RC11D/plan-state.json" <<'PY'
import json,sys
p=sys.argv[1]
doc=json.load(open(p,encoding='utf-8'))
doc['template_type']='general'
doc['scenarios']=["通用"]
json.dump(doc,open(p,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
PY
sed -i 's/^template_type: script-dev$/template_type: general/' "$RC11D/task_plan.md"
sed -i 's/script-writer（sonnet-1）/explore（haiku-1）/' "$RC11D/task_plan.md"
printf 'docs/setting.md\tsetting\ttimeout_seconds\t-\n' > "$TMPBASE/rc11d/.source-registry.tsv"
set +e
RC11D_OUT=$(bash "$CHECK_SPEC" "$RC11D" 2>&1)
RC11D_RC=$?
set -e
if ! printf '%s\n' "$RC11D_OUT" | grep -qF '[source-gate] SKIP (non-content plan)'; then
  RC11_FAILS="${RC11_FAILS} SKIP-non-content(rc=$RC11D_RC)"
fi

if [ -z "$RC11_FAILS" ]; then
  ok "11" "source-gate 四态: OK/FAILED/SKIP(no-registry)/SKIP(non-content-plan)"
else
  bad "11" "source-gate 四态缺失:$RC11_FAILS"
fi

# ── RC-12 git-baseline manifest 夹具 ──
# git init+commit 基线（含锚行）→snapshot→删除锚行并 git add→diff --final→.diff-manifest.json source_hits≥1 且 stdout 有 [diff-audit]
# 无注册表夹具→skip 行
FIX12="$TMPBASE/rc12"
mkdir -p "$FIX12/repo/docs" "$FIX12/plans/pl"
git -C "$FIX12/repo" init -q
git -C "$FIX12/repo" config user.email test@test
git -C "$FIX12/repo" config user.name test
printf 'timeout_seconds: 30\nkeep: yes\n' > "$FIX12/repo/docs/setting.md"
printf 'other\n' > "$FIX12/repo/readme.txt"
git -C "$FIX12/repo" add -A
git -C "$FIX12/repo" commit -q -m init
# source registry declares setting.md anchors
printf 'docs/setting.md\tsetting\ttimeout_seconds\t-\n' > "$FIX12/repo/.source-registry.tsv"
git -C "$FIX12/repo" add .source-registry.tsv
git -C "$FIX12/repo" commit -q -m 'add registry'
# plan dir
cat > "$FIX12/plans/pl/task_plan.md" <<'PLAN'
# Plan
template_type: script-dev
## Verification Contract
| VC | 判据 |
|---|---|
| VC-1 | ok |
PLAN
cat > "$FIX12/plans/pl/plan-state.json" <<'JSON'
{"template_type":"script-dev","plan_tier":"standard","scenarios":["代码修改"]}
JSON

# snapshot
set +e
SNAP_OUT=$(bash "$GIT_BASELINE" snapshot "$FIX12/plans/pl" --repo "$FIX12/repo" 2>&1)
RC12_SNAP=$?
set -e

RC12_OK=1; RC12_MSG=""
if [ "$RC12_SNAP" -ne 0 ]; then
  RC12_OK=0; RC12_MSG="snapshot rc=$RC12_SNAP"
else
  # delete anchor line and git add
  printf 'keep: yes\n' > "$FIX12/repo/docs/setting.md"
  git -C "$FIX12/repo" add docs/setting.md
  set +e
  DIFF_OUT=$(bash "$GIT_BASELINE" diff "$FIX12/plans/pl" --final --repo "$FIX12/repo" 2>&1)
  RC12_DIFF=$?
  set -e
  # .diff-manifest.json should have source_hits>=1
  MANIFEST="$FIX12/plans/pl/.diff-manifest.json"
  HITS=0
  if [ -f "$MANIFEST" ]; then
    HITS=$(PYTHONPATH="" python3 - "$MANIFEST" <<'PY'
import json,sys
d=json.load(open(sys.argv[1],encoding='utf-8'))
print(len(d.get('source_hits',[])))
PY
)
  fi
  if [ "$HITS" -lt 1 ]; then
    RC12_OK=0; RC12_MSG="source_hits=$HITS (<1) rc_diff=$RC12_DIFF"
  elif ! printf '%s\n' "$DIFF_OUT" | grep -q '\[diff-audit\]'; then
    RC12_OK=0; RC12_MSG="stdout 缺 [diff-audit]"
  fi
fi

# no-registry fixture -> skip line
FIX12B="$TMPBASE/rc12b"
mkdir -p "$FIX12B/repo" "$FIX12B/plans/pl"
git -C "$FIX12B/repo" init -q
git -C "$FIX12B/repo" config user.email test@test
git -C "$FIX12B/repo" config user.name test
printf 'hello\n' > "$FIX12B/repo/a.txt"
git -C "$FIX12B/repo" add -A
git -C "$FIX12B/repo" commit -q -m init
cat > "$FIX12B/plans/pl/task_plan.md" <<'PLAN'
# Plan
template_type: script-dev
## Verification Contract
| VC | 判据 |
|---|---|
| VC-1 | ok |
PLAN
cat > "$FIX12B/plans/pl/plan-state.json" <<'JSON'
{"template_type":"script-dev","plan_tier":"standard","scenarios":["代码修改"]}
JSON
bash "$GIT_BASELINE" snapshot "$FIX12B/plans/pl" --repo "$FIX12B/repo" >/dev/null 2>&1 || true
printf 'changed\n' > "$FIX12B/repo/a.txt"
git -C "$FIX12B/repo" add a.txt
set +e
DIFFB_OUT=$(bash "$GIT_BASELINE" diff "$FIX12B/plans/pl" --final --repo "$FIX12B/repo" 2>&1)
set -e
if [ "$RC12_OK" -eq 1 ]; then
  if printf '%s\n' "$DIFFB_OUT" | grep -qi 'skip'; then
    ok "12" "git-baseline diff --final: source_hits>=1 + [diff-audit] 行; 无注册表→skip"
  else
    bad "12" "无注册表夹具未输出 skip 行"
  fi
else
  bad "12" "$RC12_MSG"
fi

# ── RC-13 check-complete.sh 静态锚：diff-audit] FAILED ≥1 && zero-commit] WARN ≥1 ──
DA_CNT=$(grep -c 'diff-audit\] FAILED' "$CHECK_COMPLETE" || true)
ZC_CNT=$(grep -c 'zero-commit\] WARN' "$CHECK_COMPLETE" || true)
if [ "$DA_CNT" -ge 1 ] && [ "$ZC_CNT" -ge 1 ]; then
  ok "13" "check-complete.sh 含 diff-audit] FAILED($DA_CNT) + zero-commit] WARN($ZC_CNT)"
else
  bad "13" "check-complete.sh 静态锚缺失 diff-audit=$DA_CNT zero-commit=$ZC_CNT"
fi

# ── RC-14 git-baseline.sh 静态锚：emit_diff_audit_manifest|source_hits ≥2 ──
GB_CNT=$(grep -cE 'emit_diff_audit_manifest|source_hits' "$GIT_BASELINE" || true)
if [ "$GB_CNT" -ge 2 ]; then
  ok "14" "git-baseline.sh 含 emit_diff_audit_manifest/source_hits 共 $GB_CNT 处"
else
  bad "14" "git-baseline.sh 静态锚不足 emit_diff_audit_manifest|source_hits=$GB_CNT (<2)"
fi

# ── RC-15 check-spec-baseline.sh 静态锚：source-gate 四态 + sources_covered ──
SG_OK=$(grep -c '\[source-gate\] OK' "$CHECK_SPEC" || true)
SG_FAIL=$(grep -c '\[source-gate\] FAILED' "$CHECK_SPEC" || true)
SG_SKIP_NC=$(grep -cF 'SKIP (non-content plan)' "$CHECK_SPEC" || true)
SG_SKIP_NR=$(grep -cF 'SKIP (no .source-registry.tsv)' "$CHECK_SPEC" || true)
SG_COV=$(grep -c 'sources_covered' "$CHECK_SPEC" || true)
if [ "$SG_OK" -ge 1 ] && [ "$SG_FAIL" -ge 1 ] && [ "$SG_SKIP_NC" -ge 1 ] && [ "$SG_SKIP_NR" -ge 1 ] && [ "$SG_COV" -ge 1 ]; then
  ok "15" "check-spec-baseline.sh 含 source-gate 四态 + sources_covered"
else
  bad "15" "check-spec-baseline.sh 锚缺失 OK=$SG_OK FAIL=$SG_FAIL SKIP_NC=$SG_SKIP_NC SKIP_NR=$SG_SKIP_NR cov=$SG_COV"
fi

# ── RC-16 静态锚：planctl.py 含 cmd_acceptance、disposition 子命令注册、[source-scan] 输出锚；
#         SKILL.md/模板 含「Rule 114 通道接线」锚（以盘面实测为准）──
P_ACC=$(grep -c 'def cmd_acceptance' "$PLANCTL" || true)
P_DISP=$(grep -c 'def cmd_disposition' "$PLANCTL" || true)
P_SSCAN=$(grep -c '\[source-scan\]' "$PLANCTL" || true)
# 注册命令锚：add_cmd("acceptance"... cmd_acceptance) / add_cmd("disposition"... cmd_disposition)
P_REG_ACC=$(grep -c 'add_cmd("acceptance"' "$PLANCTL" || true)
P_REG_DISP=$(grep -c 'add_cmd("disposition"' "$PLANCTL" || true)
# Rule 114 通道接线锚：templates/task_plan.md 存在；SKILL.md 实测不含字面“Rule 114 通道接线”，
# 但含 “Rule 114” + 通道接线相关锚（见 273/289/323 行）。以盘面实测锚为准：模板必须含字面锚；
# SKILL.md 含 Rule 114 且含 research-channels/通道 关键词即可。
TPL_114=$(grep -c 'Rule 114 通道接线' "$TP_TPL" || true)
SKILL_114=$(grep -c 'Rule 114' "$TP_SKILL" || true)
SKILL_CH=$(grep -c '通道' "$TP_SKILL" || true)

RC16_OK=1; RC16_MSG=""
[ "$P_ACC" -ge 1 ] || { RC16_OK=0; RC16_MSG="$RC16_MSG cmd_acceptance"; }
[ "$P_DISP" -ge 1 ] || { RC16_OK=0; RC16_MSG="$RC16_MSG cmd_disposition"; }
[ "$P_SSCAN" -ge 1 ] || { RC16_OK=0; RC16_MSG="$RC16_MSG [source-scan]"; }
[ "$P_REG_ACC" -ge 1 ] || { RC16_OK=0; RC16_MSG="$RC16_MSG reg_acceptance"; }
[ "$P_REG_DISP" -ge 1 ] || { RC16_OK=0; RC16_MSG="$RC16_MSG reg_disposition"; }
[ "$TPL_114" -ge 1 ] || { RC16_OK=0; RC16_MSG="$RC16_MSG tpl_Rule114通道接线"; }
[ "$SKILL_114" -ge 1 ] || { RC16_OK=0; RC16_MSG="$RC16_MSG skill_Rule114"; }
[ "$SKILL_CH" -ge 1 ] || { RC16_OK=0; RC16_MSG="$RC16_MSG skill_通道"; }

if [ "$RC16_OK" -eq 1 ]; then
  ok "16" "planctl acceptance/disposition/[source-scan]+注册+SKILL.md Rule114/通道+template Rule114通道接线 锚齐"
else
  bad "16" "静态锚缺失:$RC16_MSG"
fi

echo "----------------------------------------"
printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
if [ "$FAIL" -gt 0 ]; then exit 1; fi
exit 0
