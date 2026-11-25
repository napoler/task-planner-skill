#!/usr/bin/env bash
# selftest-spec-baseline.sh — task-spec-consumption-chain S22 规范基线门行为回归（行为级，不碰 git）
# [2026-11-26 task-spec-consumption-chain S22] What:
#   以 mktemp 夹具实弹调用 check-spec-baseline.sh 与 check-tier-consistency.sh，覆盖以下断言组：
#   SB-01..04  正例：完整计划（基线表 9 列 + SPEC×4 kind 四槽 + applies 绑定全部非主进程 S-unit
#              + VC 正文点名 + .spec-scan.json must 全处置 + 核验表四 SPEC 全 PASS）→ 计划期/终验期 rc=0 且两枚 sidecar 落盘；
#   SB-05..09  事故形态负例：mini-lite 骨架（无基线表/无扫描收据/无 SPEC）→ rc=1 且 stderr 含 C1、C2；
#              plan-state.json template_ref=mini-lite + plan_tier=standard → 档位门 rc=1 且含「反向错配」；
#   SB-10..13  绑定/覆盖负例：去掉 S2 的 applies 绑定 → rc=1 含 C8；删正文 VC-4 点名行 → rc=1 含 C9；
#   SB-14..19  终验负例：核验表缺一行 → F2；观测列 TBD → F3；结论 FAIL → F4（各含 rc=1 + 编号断言）；
#   SB-20      末尾注册表自登记断言（T02 口径：TSV 首列恰有本脚本一行）；
#   SB-21..22  [2026-11-26 task-spec-consumption-chain 回归修复 B 段] 零 SPEC 终验 SKIP 正例：基线表存在但
#              无 SPEC-* 行 → rc=0 + 指定跳过提示 + .spec-final.json(status=PASS,spec=0)（A 段语义回归）。
#   SB-23      [2026-11-26 C2] 终验证据锚列留空 → rc=1 + stderr F5（观测/结论仍 PASS 也不放行）。
#   SB-24      [2026-11-26 C3] 非内容类计划零 SPEC → SKIP 正例仍 rc=0（收紧不误伤 legacy）。
#   SB-25      [2026-11-26 C3] 内容类计划零 SPEC → rc=1 + stderr F6（四槽 NA-only 不放行绕过）。
#   SB-26..30  [2026-11-26 task-spec-registry-generalization S3/S4] 注册表机制行为回归：
#              无项目注册表兼容 rc=0 / 项目级维度+执行体零代码扩展 rc=1 且带注册表来源 /
#              NA 行豁免 rc=0 / 种子注册表缺失回退内置四槽 rc 不变 / .spec-scan.tsv 归纳
#              opt-in 维度 rc=1（无扫描文件时不报该维度，正负双腿）。
# Why: 规范基线门是「规范从文本承诺升级为锁定/完成前置条件」的唯一机器落点；若只做静态文本断言，
#   夹具中人为放宽/漏绑/占位等真实事故形态不会被捕获，门被改坏时 selftest 仍假绿。
#   选择行为级 fixture + 复制变体（而非重放真实计划）：测试自包含、零仓库写入、零 git 操作（SPEC-3）。
#   断言风格仿 selftest-delegation.sh / selftest-ask-default-timeout.sh（ok/bad + Total 行 + FAIL>0 exit 1）。
# 用法: bash selftest-spec-baseline.sh  (打印 PASS/FAIL 明细 + Total 行)
# 退出码: 0=FAIL=0（PASS≥10） / 1=任一断言失败
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK="$SCRIPT_DIR/check-spec-baseline.sh"
TIER_CHECK="$SCRIPT_DIR/check-tier-consistency.sh"
REGISTRY="$SCRIPT_DIR/selftest-registry.tsv"
# What: 种子注册表路径与 SB-29 临时改名状态；Why: 门内种子加载路径为 <skill>/config/spec-registry.tsv，
#   断言必须挪同一份文件才能真实触发内置 fallback，且异常退出时不能把源码留在 .bak 状态。
SEED_REG="$SCRIPT_DIR/../config/spec-registry.tsv"
SEED_BAK="${SEED_REG}.selftest-bak"
SEED_MOVED=0
restore_seed() {
    if [ "$SEED_MOVED" = 1 ]; then
        mv "$SEED_BAK" "$SEED_REG" 2>/dev/null || printf '[selftest] ERROR: 种子注册表恢复失败（%s）\n' "$SEED_BAK" >&2
        SEED_MOVED=0
    fi
}

PASS=0; FAIL=0
# 编号用字面 "01".."20" 传入；%s 而非 %02d（bash printf 会把 08/09 当非法八进制，编号被打成 SB-00）
ok()  { PASS=$((PASS+1)); printf 'SB-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'SB-%s FAIL %s\n' "$1" "$2"; }
# assert_rc <编号> <说明> <期望rc> <实测rc>
assert_rc() {
    if [ "$4" = "$3" ]; then ok "$1" "$2 (rc=$4)"; else bad "$1" "$2 (expected=$3 got=$4)"; fi
}
# assert_stderr <编号> <说明> <扩展正则> <stderr 文本>
assert_stderr() {
    if printf '%s\n' "$4" | grep -qE "$3"; then ok "$1" "$2"; else bad "$1" "$2（未命中 $3）"; fi
}

# ── 夹具：mktemp + trap 清理（SPEC-2 shell 规范；全程写 TMPBASE，零 git 触碰）──────
TMPBASE="$(mktemp -d "${TMPDIR:-/tmp}/spec-baseline-selftest.XXXXXX")"
trap 'restore_seed; rm -rf "$TMPBASE"' EXIT
BASE="$TMPBASE/fixture-fixed"

# run_check <plan-dir> [--final] → 全局 OUT/ERR/RC；ERR 只收 stderr（2>&1 在 >/dev/null 之前）
run_check() {
    local dir="$1" mode="${2:-}"
    if [ -n "$mode" ]; then
        ERR="$(bash "$CHECK" "$dir" "$mode" 2>&1 >/dev/null)"
    else
        ERR="$(bash "$CHECK" "$dir" 2>&1 >/dev/null)"
    fi
    RC=$?
}
# clone_fixture <目标目录>：复制正例夹具全部文件（含隐藏 sidecar 源），变体只改目标，不污染正例
clone_fixture() {
    mkdir -p "$1"
    cp "$BASE/task_plan.md" "$BASE/plan-state.json" "$BASE/verification.md" \
       "$BASE/.spec-scan.json" "$BASE/source.md" "$1/"
}

mkdir -p "$BASE"
# 来源锚文件：真实存在且参与 sha256 前 12 位验真（C6）
cat > "$BASE/source.md" <<'EOF'
# 规范来源片段（selftest 夹具）

alpha 约束段落。
beta 约束段落。
gamma 约束段落。
delta 约束段落。

## 槽位说明
naming/rhythm/language/reference 四槽均有对应 SPEC。
EOF
SHA="$(sha256sum "$BASE/source.md" | awk '{print substr($1,1,12)}')"

# 正例 task_plan.md：9 列基线表（前 5 列为历史门控消费面，后 4 列为槽/校验命令/适用单元/结果）
cat > "$BASE/task_plan.md" <<'EOF'
plan_tier: standard
template_type: code-edit

# Task Plan: spec-baseline selftest fixture

## Goal
G1 验证规范基线门（计划期九项 + 终验四项）

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
| SPEC-1 | 约束一：命名 | __ANCHOR__:12 | grep -c 'alpha' source.md = 0 | __SHA__ | naming | bash check.sh | S1,S2 | 待终验 |
| SPEC-2 | 约束二：节奏 | __ANCHOR__:13 | grep -c 'beta' source.md = 0 | __SHA__ | rhythm | bash check.sh | S1,S2 | 待终验 |
| SPEC-3 | 约束三：语言 | __ANCHOR__:14 | grep -c 'gamma' source.md = 0 | __SHA__ | language | bash check.sh | S1,S2 | 待终验 |
| SPEC-4 | 约束四：参考 | __ANCHOR__:15 | grep -c 'delta' source.md = 0 | __SHA__ | reference | bash check.sh | S1,S2 | 待终验 |

## Phases（S-unit 绑定面）
| # | S-unit | 执行体 | 任务 |
|---|--------|--------|------|
| S1 | 实施 | script-writer（sonnet-1） | 产出 |
| S2 | 复核 | Test Engineer（general-purpose 承载） | 核验 |
| S3 | 编排 | 主进程 | 编排（非绑定面） |
EOF

# 权威源：spec_baseline[] 逐条带 src（must 候选处置闭环 C4），对象闭括号独占行以匹配抽取器
cat > "$BASE/plan-state.json" <<'EOF'
{
  "schema_version": 1,
  "plan_tier": "standard",
  "template_type": "code-edit",
  "spec_baseline": [
    {
      "id": "SPEC-1",
      "verbatim": "约束一：命名",
      "anchor": "__ANCHOR__:12",
      "rule": "grep -c 'alpha' source.md = 0",
      "sha": "__SHA__",
      "kind": "naming",
      "check": "bash check.sh",
      "applies": "S1,S2",
      "src": "SCAN-1"
    },
    {
      "id": "SPEC-2",
      "verbatim": "约束二：节奏",
      "anchor": "__ANCHOR__:13",
      "rule": "grep -c 'beta' source.md = 0",
      "sha": "__SHA__",
      "kind": "rhythm",
      "check": "bash check.sh",
      "applies": "S1,S2",
      "src": "SCAN-2"
    },
    {
      "id": "SPEC-3",
      "verbatim": "约束三：语言",
      "anchor": "__ANCHOR__:14",
      "rule": "grep -c 'gamma' source.md = 0",
      "sha": "__SHA__",
      "kind": "language",
      "check": "bash check.sh",
      "applies": "S1,S2",
      "src": ""
    },
    {
      "id": "SPEC-4",
      "verbatim": "约束四：参考",
      "anchor": "__ANCHOR__:15",
      "rule": "grep -c 'delta' source.md = 0",
      "sha": "__SHA__",
      "kind": "reference",
      "check": "bash check.sh",
      "applies": "S1,S2",
      "src": ""
    }
  ],
  "scenarios": ["代码修改"]
}
EOF

# 扫描收据：两条 must 候选分别被 SPEC-1/SPEC-2 的 src 处置
cat > "$BASE/.spec-scan.json" <<'EOF'
{"id":"SCAN-1","cls":"must","rule":"必须：命名"}
{"id":"SCAN-2","cls":"must","rule":"必须：节奏"}
EOF

cat > "$BASE/verification.md" <<'EOF'
# Verification: spec-baseline selftest fixture

## 基线-产物逐条核验表（Rule 84.15）
| spec_id | 双向判定式 | 校验命令 | 观测 | 证据锚(path:line 或回执) | 结论 |
|---|---|---|---|---|---|
| SPEC-1 | grep -c 'alpha' source.md = 0 | bash check.sh | 0 hit | source.md:12 | PASS |
| SPEC-2 | grep -c 'beta' source.md = 0 | bash check.sh | 0 hit | source.md:13 | PASS |
| SPEC-3 | grep -c 'gamma' source.md = 0 | bash check.sh | 0 hit | source.md:14 | PASS |
| SPEC-4 | grep -c 'delta' source.md = 0 | bash check.sh | 0 hit | source.md:15 | PASS |
EOF

# 占位符替换：锚用绝对真实路径，sha 用当次夹具实测前 12 位（避免跨环境漂移）
sed -i "s|__ANCHOR__|$BASE/source.md|g; s|__SHA__|$SHA|g" "$BASE/task_plan.md" "$BASE/plan-state.json"

# ── ① 正例：计划期九项 + 终验四项 ─────────────────────────────────────────────
run_check "$BASE"
assert_rc 01 '正例 计划期九项 rc=0' '0' "$RC"
if [ -f "$BASE/.spec-baseline.json" ] && grep -q '"status":"PASS"' "$BASE/.spec-baseline.json"; then
    ok 02 '正例 .spec-baseline.json 生成且 status=PASS'
else
    bad 02 '正例 .spec-baseline.json 缺失或 status 非 PASS'
fi
run_check "$BASE" --final
assert_rc 03 '正例 终验四项 rc=0' '0' "$RC"
if [ -f "$BASE/.spec-final.json" ] && grep -q '"status":"PASS"' "$BASE/.spec-final.json"; then
    ok 04 '正例 .spec-final.json 生成且 status=PASS'
else
    bad 04 '正例 .spec-final.json 缺失或 status 非 PASS'
fi

# ── ② 事故形态负例：mini-lite 骨架（无基线/无扫描/无 SPEC）+ 反向档位错配 ─────────
ACC="$TMPBASE/fixture-mini-lite-skeleton"
mkdir -p "$ACC"
cat > "$ACC/task_plan.md" <<'EOF'
plan_tier: mini

# Task Plan: mini-lite 事故形态骨架

## Goal
G1 轻量任务（无规范基线表、无扫描收据、无 SPEC）

## Verification Contract
| VC | 判据 |
|---|---|
| VC-1 | 人工确认 |
EOF
run_check "$ACC"
assert_rc 05 'mini-lite 骨架 计划期 rc=1' '1' "$RC"
assert_stderr 06 'mini-lite 骨架 stderr 含 C1' 'C1\(' "$ERR"
assert_stderr 07 'mini-lite 骨架 stderr 含 C2' 'C2\(' "$ERR"

TIER="$TMPBASE/fixture-reverse-tier"
mkdir -p "$TIER"
cat > "$TIER/task_plan.md" <<'EOF'
plan_tier: standard

# Task Plan: 反向错配事故形态

## Goal
G1 轻量模板 + standard 标签（init 事故复现）
EOF
cat > "$TIER/plan-state.json" <<'EOF'
{
  "schema_version": 1,
  "template_ref": "skills/task-planner/templates/json/mini-lite.template.json"
}
EOF
# 档位门的失败行走 stdout（不同于 spec-baseline 门双写 stderr），此处捕获合并输出
TIER_OUT="$(bash "$TIER_CHECK" "$TIER" 2>&1)"
RC=$?
assert_rc 08 '反向错配 tier-consistency rc=1' '1' "$RC"
assert_stderr 09 '反向错配 输出含「反向错配」' '反向错配' "$TIER_OUT"

# ── ③ 绑定/覆盖负例：applies 漏绑 S2 + VC 正文漏点名 SPEC-4 ────────────────────
UNBOUND="$TMPBASE/fixture-unbound"
clone_fixture "$UNBOUND"
sed -i 's/S1,S2/S1/g' "$UNBOUND/task_plan.md" "$UNBOUND/plan-state.json"
rm -f "$UNBOUND/.spec-baseline.json"
run_check "$UNBOUND"
assert_rc 10 '漏绑 S2 rc=1' '1' "$RC"
assert_stderr 11 '漏绑 S2 stderr 含 C8' 'C8\(' "$ERR"

NOVC="$TMPBASE/fixture-no-vc-name"
clone_fixture "$NOVC"
# 只删正文 VC-4 点名行（基线表行以 | SPEC-4 | 开头，不会被本模式命中）
sed -i '/^| VC-4 |/d' "$NOVC/task_plan.md"
rm -f "$NOVC/.spec-baseline.json"
run_check "$NOVC"
assert_rc 12 'SPEC-4 未在 VC 点名 rc=1' '1' "$RC"
assert_stderr 13 'SPEC-4 未在 VC 点名 stderr 含 C9' 'C9\(' "$ERR"

# ── ④ 终验负例：缺行 F2 / 观测占位 F3 / 结论 FAIL F4 ───────────────────────────
F2DIR="$TMPBASE/fixture-final-missing-row"
clone_fixture "$F2DIR"
sed -i '/^| SPEC-3 |/d' "$F2DIR/verification.md"
rm -f "$F2DIR/.spec-final.json"
run_check "$F2DIR" --final
assert_rc 14 '核验表缺 SPEC-3 行 rc=1' '1' "$RC"
assert_stderr 15 '核验表缺行 stderr 含 F2' 'F2\(' "$ERR"

F3DIR="$TMPBASE/fixture-final-placeholder"
clone_fixture "$F3DIR"
sed -i "/^| SPEC-2 |/s/| 0 hit |/| TBD |/" "$F3DIR/verification.md"
rm -f "$F3DIR/.spec-final.json"
run_check "$F3DIR" --final
assert_rc 16 '观测列 TBD rc=1' '1' "$RC"
assert_stderr 17 '观测列 TBD stderr 含 F3' 'F3\(' "$ERR"

F4DIR="$TMPBASE/fixture-final-fail"
clone_fixture "$F4DIR"
sed -i "/^| SPEC-4 |/s/| PASS |/| FAIL |/" "$F4DIR/verification.md"
rm -f "$F4DIR/.spec-final.json"
run_check "$F4DIR" --final
assert_rc 18 '结论 FAIL rc=1' '1' "$RC"
assert_stderr 19 '结论 FAIL stderr 含 F4' 'F4\(' "$ERR"

# ── ⑤ 零 SPEC 终验 SKIP 正例（A 段语义：无可验基线不触发 F1..F4）──────────────────
# [2026-11-26 task-spec-consumption-chain 回归修复 B 段] What: 造仅有基线表头、无 SPEC-* 行的 legacy 夹具，
#   断言 --final 打印指定跳过提示且 rc=0，并落 status=PASS/spec=0 的 .spec-final.json。
# Why: 该夹具正是 14 条回归 FAIL 的共同形态；若 A 段被改坏（重新 fail-closed），下游门会再次成片红。
ZERO="$TMPBASE/fixture-zero-spec"
mkdir -p "$ZERO"
cat > "$ZERO/task_plan.md" <<'EOF'
plan_tier: standard
template_type: code-edit

# Task Plan: zero-spec legacy fixture

## 🔒 规范基线（Spec-Baseline）
| spec_id | 约束原文(verbatim) | 来源锚(path:line) | 双向判定式 | 来源 sha256 | 槽 | 校验命令 | 适用S-unit | 结果 |
|---|---|---|---|---|---|---|---|---|

## Verification Contract
| VC | 判据 |
|---|---|
| VC-1 | 人工确认 |
EOF
ZERO_OUT="$(bash "$CHECK" "$ZERO" --final 2>"$TMPBASE/zero.err")"
ZERO_RC=$?
if [ "$ZERO_RC" = '0' ] && printf '%s\n' "$ZERO_OUT" | grep -qF '[spec-baseline] ✓ 终验跳过（计划无 SPEC-* 行，无可验基线）'; then
    ok 21 '零 SPEC 终验 SKIP rc=0 且输出指定跳过提示'
else
    bad 21 "零 SPEC 终验 SKIP rc=$ZERO_RC 输出=$(printf '%s' "$ZERO_OUT" | head -n 2)"
fi
if [ -f "$ZERO/.spec-final.json" ] && grep -q '"status":"PASS"' "$ZERO/.spec-final.json" \
   && grep -q '"spec":0' "$ZERO/.spec-final.json"; then
    ok 22 '零 SPEC 终验 .spec-final.json status=PASS spec=0'
else
    bad 22 '零 SPEC 终验 .spec-final.json 缺失或 status/spec 不符'
fi

# ── ⑦ [C2] F5 证据锚非空非占位负例：观测/结论不动，仅清空 SPEC-3 证据锚 ──────────────
F5DIR="$TMPBASE/fixture-final-no-anchor"
clone_fixture "$F5DIR"
sed -i 's@| source.md:14 |@|  |@' "$F5DIR/verification.md"
rm -f "$F5DIR/.spec-final.json"
run_check "$F5DIR" --final
assert_rc 23 '证据锚列空 rc=1' '1' "$RC"
assert_stderr '23' '证据锚列空 stderr 含 F5' 'F5\(' "$ERR"

# ── ⑧ [C3] F6 内容类零 SPEC 阻断 + 非内容零 SPEC 保留 SKIP ─────────────────────────
ZERO_NC="$TMPBASE/fixture-zero-spec-noncontent"
mkdir -p "$ZERO_NC"
cp "$ZERO/task_plan.md" "$ZERO_NC/task_plan.md"
cat > "$ZERO_NC/plan-state.json" <<'EOF'
{"schema_version":1,"plan_tier":"standard","template_type":"code-edit","scenarios":["代码修改"]}
EOF
ZERO_NC_OUT="$(bash "$CHECK" "$ZERO_NC" --final 2>"$TMPBASE/zero-nc.err")"
ZERO_NC_RC=$?
if [ "$ZERO_NC_RC" = '0' ] && printf '%s\n' "$ZERO_NC_OUT" | grep -qF '[spec-baseline] ✓ 终验跳过（计划无 SPEC-* 行，无可验基线）'; then
    ok 24 '非内容类零 SPEC SKIP rc=0（收紧未误伤 legacy）'
else
    bad 24 "非内容类零 SPEC SKIP rc=$ZERO_NC_RC 输出=$(printf '%s' "$ZERO_NC_OUT" | head -n 2)"
fi

ZERO_CONTENT="$TMPBASE/fixture-zero-spec-content"
mkdir -p "$ZERO_CONTENT"
cp "$ZERO/task_plan.md" "$ZERO_CONTENT/task_plan.md"
sed -i 's/^template_type: code-edit$/template_type: writing/' "$ZERO_CONTENT/task_plan.md"
cat > "$ZERO_CONTENT/plan-state.json" <<'EOF'
{"schema_version":1,"plan_tier":"standard","template_type":"writing","scenarios":["小说创作"]}
EOF
ZERO_CONTENT_OUT="$(bash "$CHECK" "$ZERO_CONTENT" --final 2>"$TMPBASE/zero-content.err")"
ZERO_CONTENT_RC=$?
ZERO_CONTENT_ERR="$(cat "$TMPBASE/zero-content.err")"
assert_rc 25 '内容类零 SPEC rc=1' '1' "$ZERO_CONTENT_RC"
assert_stderr 25 '内容类零 SPEC stderr 含 F6' 'F6\(' "$ZERO_CONTENT_ERR"
if [ ! -f "$ZERO_CONTENT/.spec-final.json" ]; then ok '25' '内容类零 SPEC 未落 .spec-final.json'; else bad '25' '内容类零 SPEC 误落 .spec-final.json'; fi

# ── ⑥ 注册表自登记（T02 口径：实际脚本必须有且仅有一行首列匹配）──────────────────
REG_N="$(awk -F'\t' '$1 == "selftest-spec-baseline.sh" {n++} END{print n+0}' "$REGISTRY" 2>/dev/null || printf '0')"
if [ "$REG_N" = "1" ]; then
    ok 20 'registry 含 selftest-spec-baseline.sh 行 = 1（T02 无缺失）'
else
    bad 20 "registry 登记数 $REG_N（应 1，T02 无缺失）"
fi

# ── ⑨ [task-spec-registry-generalization S3/S4] 注册表机制（SB-26..30）──────────────
# What: 用嵌套夹具（plan-dir 两层之上即项目根，与门内 REPO_ROOT=plan-dir/../.. 对齐）实弹跑门，
#   覆盖项目级 .spec-registry.tsv 零代码扩展、NA 逃生口、种子缺失 fallback、.spec-scan.tsv 归纳
#   四条腿 + 无项目注册表兼容回归。
# Why: 注册表是「新项目类型不改门脚本即可扩展」的唯一机器落点；若只做静态文本断言，
#   加载/合并/fallback/归纳任一环被改坏仍会假绿，故沿用前文行为级 mktemp 夹具风格。
REGP="$TMPBASE/registry-proj"
REGPLAN="$REGP/plans/plan"
clone_fixture "$REGPLAN"
run_check "$REGPLAN"
assert_rc 26 '无项目级注册表 兼容回归 rc=0（种子四槽行为不变）' '0' "$RC"

# SB-27: 项目根 TSV 声明 dimension(project) + executor，基线仍四槽 → C7 缺维度并报注册表来源
printf '%s\n' \
  $'dimension\tworldbuilding\t世界观一致性\t世界观|设定集|力量体系\tproject' \
  $'executor\tmanga-writer\t漫画脚本撰写\t-\t-' > "$REGP/.spec-registry.tsv"
rm -f "$REGPLAN/.spec-baseline.json"
run_check "$REGPLAN"
if [ "$RC" = '1' ] && printf '%s\n' "$ERR" | grep -qF '维度覆盖缺 worldbuilding' \
   && printf '%s\n' "$ERR" | grep -qF '.spec-registry.tsv:'; then
    ok 27 '项目注册表扩展维度 rc=1 且 stderr 含缺 worldbuilding 与注册表来源'
else
    bad 27 "项目注册表扩展维度 rc=$RC / stderr=$(printf '%s' "$ERR" | head -n 2)"
fi

# SB-28: 同一注册表夹具补 NA 行（含维度字样+理由）→ 逃生口语义不变，rc=0
# What: NA 行放在 SPEC-4 之后仍在基线段内，10 列保持 9 列抽取判据；C5/C6/C9 只消费 SPEC-* 行。
sed -i '/^| SPEC-4 |/a | NA-1 | worldbuilding 世界观一致性 不适用（本计划无力量体系设定） | - | - | - | - | - | - | NA |' \
    "$REGPLAN/task_plan.md"
run_check "$REGPLAN"
assert_rc 28 'NA 含 worldbuilding+理由 豁免 rc=0（逃生口不变）' '0' "$RC"

# SB-29: 临时挪走种子注册表 → 门回内置四槽 fallback，rc 与改名前一致；trap 兜底恢复源码
FB="$TMPBASE/fallback-proj"
FBPLAN="$FB/plans/plan"
clone_fixture "$FBPLAN"
run_check "$FBPLAN"
RC_BEFORE="$RC"
if [ -f "$SEED_REG" ] && [ ! -e "$SEED_BAK" ] && mv "$SEED_REG" "$SEED_BAK"; then
    SEED_MOVED=1
else
    SEED_MOVED=0
fi
if [ "$SEED_MOVED" = 1 ]; then
    rm -f "$FBPLAN/.spec-baseline.json"
    run_check "$FBPLAN"
    RC_AFTER="$RC"
    # What: restore_seed 会把 SEED_MOVED 归零，判定前先快照本次是否真的挪过文件；
    # Why: 否则「从未改名」与「改名后已恢复」在末条断言里不可区分，产生假 FAIL。
    SEED_WAS_MOVED="$SEED_MOVED"
    restore_seed
else
    RC_AFTER='<未改名>'
    SEED_WAS_MOVED=0
fi
if [ "$SEED_WAS_MOVED" = 1 ] && [ "$RC_BEFORE" = '0' ] && [ "$RC_AFTER" = '0' ] \
   && [ -f "$SEED_REG" ] && [ ! -e "$SEED_BAK" ]; then
    ok 29 '种子注册表缺失回退内置四槽 rc 不变且文件已恢复'
else
    bad 29 "种子回退 before=$RC_BEFORE after=$RC_AFTER moved=$SEED_WAS_MOVED 恢复=$([ -f "$SEED_REG" ] && printf yes || printf no)"
fi

# SB-30: opt-in 维度经 .spec-scan.tsv 第二列归纳即强制；无该文件时同夹具不报 logic（负例）
IND="$TMPBASE/induction-proj"
INDPLAN="$IND/plans/plan"
clone_fixture "$INDPLAN"
run_check "$INDPLAN"
RC_NOSCAN="$RC"
ERR_NOSCAN="$ERR"
printf '%s\t%s\n' 'docs/bible.md' 'logic' > "$INDPLAN/.spec-scan.tsv"
rm -f "$INDPLAN/.spec-baseline.json"
run_check "$INDPLAN"
if [ "$RC_NOSCAN" = '0' ] && [ "$RC" = '1' ] \
   && printf '%s\n' "$ERR" | grep -qF '维度覆盖缺 logic' \
   && ! printf '%s\n' "$ERR_NOSCAN" | grep -qF '维度覆盖缺 logic'; then
    ok 30 '.spec-scan.tsv 归纳 logic rc=1 且无扫描文件时不报 logic'
else
    bad 30 "归纳腿 rc(无扫描=$RC_NOSCAN 有扫描=$RC) / stderr=$(printf '%s' "$ERR" | head -n 2)"
fi

echo "----------------------------------------"
printf 'Total: %d  PASS=%d  FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
if [ "$FAIL" -gt 0 ]; then exit 1; fi
exit 0
