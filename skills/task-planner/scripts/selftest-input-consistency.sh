#!/usr/bin/env bash
# selftest-input-consistency.sh — task-v175: Rule 85「用户输入一致性纪律」静态守护
#
# What（守护对象 + 运行方式）:
#   静态断言 task-v175 Rule 85 全链落点在位（对齐 selftest-summary-readability.sh 范式），
#   共 5 条编号断言 IC-01..IC-05：
#     · references/critical-rules-discipline.md（Rule 85 条款本体，IC-01..IC-02）:
#         IC-01 `### 85 用户输入一致性纪律` 条款标题锚=1
#         IC-02 85.1-85.4 四子条锚（`**85.[1-4] `）各≥1（合计≥4）
#     · SKILL.md（消费侧联动，IC-03）:
#         IC-03 task-discipline 卫星行规则列表包含 85（`69-76,85` 纪元锚≥1）
#     · templates/subagent_dispatch.md（IC-04）:
#         IC-04 §2 输入段含 `用户输入一致性约束（Rule 85，P0）` 模板行≥1
#     · IC-05 零新 config 键负断言: config.json 无 `input_consist` 键
#   运行方式：`bash scripts/selftest-input-consistency.sh`（只读 grep，零写入）；
#   逐行打印 `IC-NN PASS/FAIL/WARN: <说明>`，末行 `Total: PASS=N FAIL=N WARN=N`；
#   FAIL>0 → exit 1，否则 exit 0。
#   被检文件路径全部相对 SKILL_ROOT 解析，保证仓库/worktree/部署位三处均可直接跑。
#
# Why（Rule 85 机制锚，task-v175 2026-10-15）:
#   用户核心诉求=防止子代理用与用户提供的输入（图片/文件/数据）无关的内容替换用户输入，
#   确保执行一致性与结果可信度。Rule 85 判定面=LLM 行为（无机器触发），零新 config 键：
#   本脚本锁「条款标题+四子条文本 + SKILL 卫星接线 + 派发模板约束模板」三面配对，
#   再加 config 零新键负断言——任一面被后续裁剪误删即 FAIL 报警（防复发，Rule 31.5 消费侧）。

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── 路径定义（相对技能根）──
# [task-v171 纪律域搬迁 2026-10-12] Rule 85 属纪律域，条款本体在卫星
#   skills/task-discipline/references/critical-rules-discipline.md（与 Rule 76 同载体）。
CRIT_D="$SKILL_ROOT/../task-discipline/references/critical-rules-discipline.md"
SKILL="$SKILL_ROOT/SKILL.md"
DISPATCH="$SKILL_ROOT/templates/subagent_dispatch.md"
CONFIG="$SKILL_ROOT/config.json"

# ── 计数器与输出 helper ──
PASS=0; FAIL=0; WARN=0
ok()   { echo "$1 PASS: $2"; PASS=$((PASS+1)); }
bad()  { echo "$1 FAIL: $2"; FAIL=$((FAIL+1)); }
warn() { echo "$1 WARN: $2"; WARN=$((WARN+1)); }

# ── 通用计数 helper ──
cnt()  { [ -f "$2" ] || { echo 0; return; }; grep -c -e "$1" "$2" 2>/dev/null || true; }
cntf() { [ -f "$2" ] || { echo 0; return; }; grep -cF -- "$1" "$2" 2>/dev/null || true; }
cntE() { [ -f "$2" ] || { echo 0; return; }; grep -cE -- "$1" "$2" 2>/dev/null || true; }

# ── IC-01: Rule 85 条款标题锚 ──
IC01_TITLE=$(cnt '### 85 用户输入一致性纪律' "$CRIT_D")
if [ "$IC01_TITLE" -ge 1 ]; then
    ok "IC-01" "Rule 85 条款标题锚(标题≥1)"
else
    bad "IC-01" "Rule 85 条款标题锚(got title=$IC01_TITLE expect>=1)"
fi

# ── IC-02: Rule 85 四子条锚（85.1-85.4 各≥1，子条行格式 `- **85.N …**`）──
IC02_SUBS=$(cntE '\*\*85\.[1-4] ' "$CRIT_D")
if [ "$IC02_SUBS" -ge 4 ]; then
    ok "IC-02" "Rule 85 四子条锚 85.1-85.4(≥4)"
else
    bad "IC-02" "Rule 85 四子条锚(got subs=$IC02_SUBS expect>=4)"
fi

# ── IC-03: SKILL 接线锚（task-discipline 卫星行规则列表包含 85）──
# 锚 `85` 限定在 task-discipline 行内（卫星技能摘要行 + 卫星路由表行两处 task-discipline
# 规则列表，阈值≥1）。注：行内全角/半角混合括号无法做字符类边界（grep -E 报 Invalid
# range end），改用裸字面 85 弱锚防误扩（纪元演进时 85 被并入区间如 69-85 则恒 PASS，
# 语义=「task-discipline 行含 85 规则」不漂移）。
IC03_85=$(grep -E 'task-discipline' "$SKILL" 2>/dev/null | grep -c '85' || true)
IC03_85=${IC03_85:-0}
if [ "$IC03_85" -ge 1 ]; then
    ok "IC-03" "SKILL task-discipline 规则列表含 85(got lines=$IC03_85 expect>=1)"
else
    bad "IC-03" "SKILL task-discipline 规则列表含 85(got lines=$IC03_85 expect>=1)"
fi

# ── IC-04: subagent_dispatch.md §2 输入段一致性约束模板行 ──
IC04_TPL=$(cntf '用户输入一致性约束（Rule 85，P0）' "$DISPATCH")
if [ "$IC04_TPL" -ge 1 ]; then
    ok "IC-04" "subagent_dispatch.md 一致性约束模板行(≥1)"
else
    bad "IC-04" "subagent_dispatch.md 一致性约束模板行(got $IC04_TPL expect>=1)"
fi

# ── IC-05: 零新 config 键负断言（config.json 无 input_consist 键）──
# Why: Rule 85 承诺零新 config 键（判定面=LLM 行为+静态守护）——键字面出现=有人给
#   输入一致性加了机器门控键（机制漂移，需走 Rule 36 流程）。config.json 缺失=部署位
#   未带 config，打 WARN 不 FAIL（fail-open，同 DCE-09 口径）。
if [ -f "$CONFIG" ]; then
    IC05_KEY=$(grep -cE 'input_consist' "$CONFIG" 2>/dev/null || true)
    IC05_KEY=${IC05_KEY:-0}
    if [ "$IC05_KEY" -eq 0 ]; then
        ok "IC-05" "零新 config 键：config.json 无 input_consist 键(=0)"
    else
        bad "IC-05" "零新 config 键被破（config.json input_consist 键 got=$IC05_KEY expect=0）"
    fi
else
    warn "IC-05" "config.json 不存在（部署位未带 config，跳过零新键断言）"
fi

echo "Total: PASS=$PASS FAIL=$FAIL WARN=$WARN"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
