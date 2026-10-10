#!/usr/bin/env bash
# selftest-proactive-research.sh — task-v163: Rule 75「网络调研主动激活与外部数据依赖纪律」静态守护（75.7 机制面）
#
# What（守护对象 + 运行方式）:
#   静态断言 task-v163 全链落点在位（对齐 selftest-research-first.sh 范式），共 15 条编号断言 PR-01..PR-15：
#     · references/critical-rules.md（Rule 75 条款本体，PR-01..PR-09）:
#         PR-01 `^### 75 ` 节头=1
#         PR-02..PR-09 `^75\.0 `..`^75\.7 ` 八子条各≥1（防「节头在但子条被裁」死文变体）——
#           75.0 公理 / 75.1 计划期三态分析 / 75.2 反死磕主动激活 / 75.3 现成方案优先 /
#           75.4 GitHub 检索纪律 / 75.5 外部工具强制 / 75.6 模板层定制 / 75.7 机制（零新 config 键声明）
#     · 计划期载体（PR-10..PR-12）:
#         PR-10 templates/task_plan.md 含「## 🔍 调研需求与检索计划（Rule 75.1」区块锚
#         PR-11 companion/agents/plan-writer.md 含「调研需求区块（Rule 75.1）」契约行
#         PR-12 scripts/check-plan-dispatch.sh 含「Rule 75.1 调研需求区块 advisory」段锚
#     · 模板生成技能（PR-13）:
#         PR-13 skills/plan-template-kit/references/template-guide.md 含「2.6 新模板调研需求判定条目」锚
#     · registry 自登记（PR-14）: selftest-registry.tsv 含本脚本登记行 ≥1
#     · config.json 零新键（PR-15）: `"properties"` 计数=基线 4（Rule 75 未新增属性组）∧ Rule 75 键字面=0
#   运行方式：`bash scripts/selftest-proactive-research.sh`（只读 grep，零写入）；
#   逐行打印 `PASS PR-NN <说明>` / `FAIL PR-NN <说明> (got=..)`，末行 `Total: 15 PASS=x FAIL=y`；
#   全 PASS exit 0，任一 FAIL exit 1。被检文件路径全部相对 SCRIPT_DIR 解析，保证仓库/worktree/部署位三处均可直接跑。
#
# Why（Rule 75.7 机制锚，task-v163 2026-10-10）:
#   用户核心诉求=「当前的搜索不够主动，就是调研不够主动。遇到问题就在那里死磕」（R1）：
#   Rule 75 把「网络调研主动激活+外部数据依赖」立为 P0 纪律（计划期三态分析 / 执行期反死磕 /
#   GitHub 与浏览器等外部工具强制 / 模板层调研触点定制）。Rule 75 为纯行为面条款（判定面=LLM 行为），
#   无静态守护即死文（53.2 零载体判例）：本脚本锁「条款八子条文本 + 计划期三载体 + 模板生成条目 +
#   registry 自登记 + 零新键」五面配对，任一面被后续裁剪误删即 FAIL 报警（防复发，Rule 31.5 消费侧）。
#   [2026-10-10 S12] PR-14 registry 登记行由 S13 落盘——S12 期该断言为前向守护（待 S13 后转绿）。

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CR="$SCRIPT_DIR/../references/critical-rules.md"          # Rule 75 条款本体
TPL="$SCRIPT_DIR/../templates/task_plan.md"               # 计划期调研区块载体
PW="$SCRIPT_DIR/../companion/agents/plan-writer.md"       # plan-writer 产出契约
CPD="$SCRIPT_DIR/check-plan-dispatch.sh"                  # dispatch advisory 段
GUIDE="$SCRIPT_DIR/../../plan-template-kit/references/template-guide.md"  # 模板生成技能判定条目
REGISTRY="$SCRIPT_DIR/selftest-registry.tsv"              # selftest 分域 registry
CONFIG="$SCRIPT_DIR/../config.json"                       # 零新键守护对象

PASS=0; FAIL=0
ok()   { echo "PASS $1"; PASS=$((PASS+1)); }
bad()  { echo "FAIL $1 ($2)"; FAIL=$((FAIL+1)); }
eq()   { local d="$1" n="$2" e="$3"; [ "$n" -eq "$e" ] && ok "$d" || bad "$d" "got=$n expect==$e"; }
ge()   { local d="$1" n="$2" e="$3"; [ "$n" -ge "$e" ] && ok "$d" || bad "$d" "got=$n expect>=$e"; }
cnt()  { [ -f "$2" ] || { echo 0; return; }; grep -c -e "$1" "$2" 2>/dev/null || true; }
cntF() { [ -f "$2" ] || { echo 0; return; }; grep -cF -- "$1" "$2" 2>/dev/null || true; }

# ── critical-rules.md Rule 75 条款本体 ──
eq "PR-01 critical-rules ### 75 节头=1"                     "$(cnt '^### 75 ' "$CR")" 1
ge "PR-02 critical-rules 75.0 公理子条"                     "$(cnt '^75\.0 ' "$CR")" 1
ge "PR-03 critical-rules 75.1 计划期三态分析子条"            "$(cnt '^75\.1 ' "$CR")" 1
ge "PR-04 critical-rules 75.2 反死磕主动激活子条"            "$(cnt '^75\.2 ' "$CR")" 1
ge "PR-05 critical-rules 75.3 现成方案优先子条"              "$(cnt '^75\.3 ' "$CR")" 1
ge "PR-06 critical-rules 75.4 GitHub 检索纪律子条"           "$(cnt '^75\.4 ' "$CR")" 1
ge "PR-07 critical-rules 75.5 外部工具强制子条"              "$(cnt '^75\.5 ' "$CR")" 1
ge "PR-08 critical-rules 75.6 模板层定制子条"                "$(cnt '^75\.6 ' "$CR")" 1
ge "PR-09 critical-rules 75.7 机制子条(零新键声明)"          "$(cnt '^75\.7 ' "$CR")" 1

# ── 计划期载体（模板区块 / plan-writer 契约 / dispatch advisory）──
ge "PR-10 task_plan 模板调研区块锚(Rule 75.1)"              "$(cntF '## 🔍 调研需求与检索计划（Rule 75.1' "$TPL")" 1
ge "PR-11 plan-writer 调研需求区块契约行(Rule 75.1)"         "$(cntF '调研需求区块（Rule 75.1）' "$PW")" 1
ge "PR-12 check-plan-dispatch advisory 段锚(Rule 75.1)"      "$(cntF 'Rule 75.1 调研需求区块 advisory' "$CPD")" 1

# ── 模板生成技能条目（plan-template-kit guide §2.6）──
ge "PR-13 template-guide 新模板调研需求判定条目(2.6)"        "$(cntF '2.6 新模板调研需求判定条目' "$GUIDE")" 1

# ── registry 自登记（PR-14；S12 期前向守护，S13 落盘后转绿）──
ge "PR-14 registry 含本脚本登记行"                           "$(cntF 'selftest-proactive-research.sh' "$REGISTRY")" 1

# ── config.json 零新键（properties 计数=基线 4 ∧ Rule 75 键字面=0）──
PROP="$(grep -c '"properties"' "$CONFIG" 2>/dev/null || true)"; PROP="${PROP:-0}"
NEWKEY="$(grep -c -e 'proactive_research' -e 'proactive-research' -e 'proactive_search' "$CONFIG" 2>/dev/null || true)"; NEWKEY="${NEWKEY:-0}"
if [ "$PROP" -eq 4 ] && [ "$NEWKEY" -eq 0 ]; then
    ok "PR-15 config 零新键(properties=4 ∧ Rule75 键字面=0)"
else
    bad "PR-15 config 零新键" "got=(props=$PROP,newkey=$NEWKEY) expect=(4,0)"
fi

echo "Total: 15 PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
