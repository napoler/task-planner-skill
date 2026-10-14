#!/bin/bash
# lane-detect.sh — 执行通道（execution_lane）机器判定（Rule 38.7 L0/L1/L2 分级机器面，task-v167）
# 用途: 计划创建期按 git diff 体量与变更性质判定执行通道；init-session.sh 接线写入计划头 execution_lane 行
# 输入: --diff BASE（须给，如 origin/master/HEAD~1） | --plan FILE（透传校验计划头既有 execution_lane 行）
# 输出/exit: stdout 单行 execution_lane: L0|L1|L2, stderr 判定依据; exit 0=成功, 2=无法判定（非 git 仓/BASE 无效/计划
#   无 lane 行）→ stdout 兜底 L1（fail-safe 向重侧）
# 判定（38.7）: L0=文件数≤3 ∧ 增删行≤20 ∧ 全 .md 无代码; L2=>8 文件 ∨ register-hooks-cj.ts ∨ 顶层
#   agents 定义 ∨ 跨 ≥2 顶层 skill 目录; L1=其余。禁滥用（任一命中即 L1）: ①新增文件（新机制信号）
#   ②critical-rules.md 新增 Rule 段（+ 行形态 编号条目/## Rule）③代码文件改动（.sh/.ts/.cjs/.js/.py/.json）
# 对照面: 文件面/新增面=name-status 两面并集（BASE 工作区面 ∪ BASE→HEAD 提交面）∪ 未追踪文件（plans/ 簿记面豁免）;
#   行数面=shortstat BASE 单侧 + 未追踪 wc -l（双侧面求和双算已提交部分, 11 行误算 22 行）

set -u

usage() { echo "usage: lane-detect.sh [--diff BASE] [--trivial] | [--plan FILE]" >&2; exit 2; }
fallback_l1() { # 无法判定兜底：stdout 给 L1（fail-safe 向重侧）+ stderr 说明，exit 2
    echo "execution_lane: L1"
    echo "[lane-detect] 无法判定: $1（兜底 L1=现行默认全流程）" >&2
    exit 2
}

PLAN_FILE=""
BASE=""
# [M1/M5-fix 2026-10-14] --trivial 模式：init-session.sh 在 TRIVIAL_CODE_TIER=1 时传入，
# 使「代码文件改动可进 L0」的 trivial 例外在 lane-detect 统一判定面内可审计（M5 消除两处分离），
# 同时 Rule 38.7 的 trivial 例外在 lane-detect.sh 内显式声明，消除与 critical-rules-template.md:49 禁令的矛盾（M1）。
TRIVIAL_MODE=0
while [ $# -gt 0 ]; do case "$1" in
    --plan) PLAN_FILE="${2:-}"; [ -n "$PLAN_FILE" ] || usage; shift 2 ;;
    --diff) BASE="${2:-}"; [ -n "$BASE" ] || usage; shift 2 ;;
    --trivial) TRIVIAL_MODE=1; shift ;;
    *) usage ;;
esac; done
# ── --plan 模式: 计划文件头读已有 execution_lane: 行原样透传校验（init-session 写入消费闭环）──
if [ -n "$PLAN_FILE" ]; then
    [ -f "$PLAN_FILE" ] || fallback_l1 "计划文件 $PLAN_FILE 不存在"
    lane_in="$(grep -m1 -oE 'execution_lane:[[:space:]]*L[012]' "$PLAN_FILE" 2>/dev/null | grep -oE 'L[012]')"
    [ -n "$lane_in" ] || fallback_l1 "$PLAN_FILE 无合法 execution_lane 行（缺省=未定级）"
    echo "execution_lane: $lane_in"
    echo "[lane-detect] --plan 模式: 透传 $PLAN_FILE 头部既有 execution_lane: $lane_in（原样校验通过）" >&2
    exit 0
fi

[ -n "$BASE" ] || fallback_l1 "--diff 未给且 --plan 未给（至少二选一）"
# 非 git 仓 / BASE 不是有效 ref → 对照面不可得 → L1 兜底
git rev-parse --git-dir >/dev/null 2>&1 || fallback_l1 "非 git 仓（lane 判定依赖 git diff 对照面）"
git rev-parse --verify --quiet "${BASE}^{commit}" >/dev/null 2>&1 || fallback_l1 "BASE=$BASE 不是有效 commit ref"
# 并集: 工作区 vs BASE ∪ 提交面 BASE→HEAD（name-status 去重取文件面）——变更文件集两面可不同
nstat="$( { git diff --name-status "$BASE" 2>/dev/null || true; git diff --name-status "$BASE" HEAD 2>/dev/null || true; } )"
FILES="$(printf '%s\n' "$nstat" | awk 'NF>=2{print $2}' | sort -u)"
NFILES="$(printf '%s' "$FILES" | grep -c . || true)"
# 行数口径: shortstat BASE 单侧（工作区 diff 天然含 committed+uncommitted; 两面求和双算已提交部分, S1 11 行误算 22 行）
LINES_TOTAL="$(git diff --shortstat "$BASE" 2>/dev/null | grep -oE '[0-9]+ (insertion|deletion)' | grep -oE '^[0-9]+' | awk '{s+=$1} END{print s+0}')"
CODE_HIT="$(printf '%s\n' "$FILES" | grep -E '\.(sh|ts|cjs|js|py|mjs|json)$' || true)"
NEW_HIT="$(printf '%s\n' "$nstat" | awk '$1=="A"{print $2}' | sort -u || true)"
# 未追踪面并入（定数盲区修补: 未追踪文件不进 git diff——init 定级时点新文件多为未追踪态, 不并入则
# 行数漏计+新增文件禁滥用①漏报→L0 误判轻通道）; plans/ 下未追踪文件=init 会话簿记面非变更面
# （并入会使「init 在 plans/<id>/ 内跑 lane-detect」场景恒 L1/L2 失去 L0 可用性, 三面统一豁免）
RULE_NEW=0
UNTRACKED="$(printf '%s\n' "$(git ls-files --others --exclude-standard 2>/dev/null || true)" | grep -vE '^plans/' || true)"
if [ -n "$UNTRACKED" ]; then
    LINES_TOTAL=$((LINES_TOTAL + $(for _f in $UNTRACKED; do [ -f "$_f" ] && wc -l < "$_f" 2>/dev/null; done | awk '{s+=$1} END{print s+0}')))
    CODE_HIT="${CODE_HIT}$(printf '%s\n' "$UNTRACKED" | grep -E '\.(sh|ts|cjs|js|py|mjs|json)$' || true)"
    FILES="$(printf '%s\n%s\n' "$FILES" "$UNTRACKED" | sort -u)"   # 未追踪面并入文件面（定数/全 .md 判定可见）
    NFILES="$(printf '%s' "$FILES" | grep -c . || true)"
    NEW_HIT="$(printf '%s\n%s\n' "$NEW_HIT" "$UNTRACKED" | sort -u)"
    # 未追踪 critical-rules.md 整文件探测: 未追踪=新增面, 含编号条目即新 Rule 段（②）; grep -q（-c 零匹配输出 0 会误判）
    for _f in $UNTRACKED; do case "$_f" in *critical-rules.md) grep -qE '^([0-9]+\.[0-9][[:space:]]*\*\*|##[[:space:]]*Rule)' "$_f" 2>/dev/null && RULE_NEW=1 ;; esac; done
fi
# ② 探测（提交面）: critical-rules.md 在变更面内且提交面 + 行命中 Rule 段形态（未提交追加已命中①/上方未追踪探测, 无漏判）
if printf '%s\n' "$FILES" | grep -q 'critical-rules\.md$'; then
    _rule_new_commit="$(git diff "$BASE" HEAD -- '*critical-rules.md' 2>/dev/null | grep -cE '^\+([0-9]+\.[0-9]+[[:space:]]*\*\*|##[[:space:]]*Rule)' || true)"
    [ "${_rule_new_commit:-0}" -ge 1 ] && RULE_NEW=1
fi

lane=L1
reason=""
# L2 判定（先于 L0: 体量/跨目录超标直接 L2, 禁滥用不再细分降级）
l2_hits=""
[ "$NFILES" -gt 8 ] && l2_hits="${l2_hits}文件数=${NFILES}>8 "
printf '%s\n' "$FILES" | grep -q 'register-hooks-cj\.ts$' && l2_hits="${l2_hits}触及 hooks 注册(register-hooks-cj.ts) "
printf '%s\n' "$FILES" | grep -qE '^agents/[^/]+\.md$' && l2_hits="${l2_hits}触及 agents 定义 "
NSKILLS="$(printf '%s\n' "$FILES" | grep -oE '^skills/[^/]+' | sort -u | grep -c . || true)"
[ "$NSKILLS" -ge 2 ] && l2_hits="${l2_hits}跨 ${NSKILLS} 个顶层 skill 目录 "
[ -n "$l2_hits" ] && { lane=L2; reason="L2 命中: ${l2_hits% }（38.7: 全仓审查/跨系统/多任务面——在 L1 基础上加宽验证面）"; }
# L0 三条件 + 禁滥用机器化（任一命中 → L1 并注明理由；L2 已判定则保留 L2）
abuse=""
[ -n "$NEW_HIT" ] && abuse="${abuse}新增文件($(printf '%s\n' "$NEW_HIT" | tr '\n' ' ')等) "
[ "${RULE_NEW:-0}" = 1 ] && abuse="${abuse}critical-rules.md 新增 Rule 条目段 "
# [M1-fix 2026-10-14] CODE_HIT 在 --trivial 模式下不触发禁滥用③（trivial 代码修复是本模式前提）；
# 非 trivial 模式保持原行为（代码文件改动→禁滥用③→L1）
if [ -n "$CODE_HIT" ] && [ "${TRIVIAL_MODE}" -eq 0 ]; then
    abuse="${abuse}代码文件改动($(printf '%s\n' "$CODE_HIT" | tr '\n' ' ')等) "
fi
# [M1/M5-fix] trivial 代码修复 L0 判定（--trivial 模式专用）：
# 单文件 ∧ ≤3 行 ∧ 非新增 ∧ 无新 Rule 段 → L0；CODE_HIT 豁免（禁滥用③不生效）
# Rule 38.7 条文（critical-rules-template.md:49）显式开出「≤3 行 trivial 代码修复」例外，
# L0 仍保留 ①全量终验+②Phase翻转+③单commit 三道底线门。
if [ "${TRIVIAL_MODE}" -eq 1 ]; then
    if [ -z "$l2_hits" ] && [ -z "$abuse" ] && [ "$NFILES" -le 1 ] && [ "$LINES_TOTAL" -le 3 ]; then
        lane=L0
        reason="L0 trivial 代码修复（--trivial：单文件 ∧ ≤3行 ∧ 非新增 ∧ 无新 Rule 段，CODE_HIT 豁免禁滥用③）"
    elif [ -n "$l2_hits" ]; then
        [ -n "$abuse" ] && reason="${reason:-} | L2 命中: ${l2_hits% }"
        lane=L2
        [ -z "${reason:-}" ] && reason="L2 命中: ${l2_hits% }（--trivial 模式亦不可进 L0）"
    elif [ -n "$abuse" ]; then
        reason="L1: 禁滥用命中 — ${abuse% }（--trivial 模式：新增文件/新 Rule 段仍 L1，CODE_HIT 豁免）"
    else
        reason="L1: --trivial 模式 L0 条件未全命中（文件数=${NFILES}, 行数=${LINES_TOTAL}；须单文件 ∧ ≤3行）"
    fi
elif [ -z "$l2_hits" ] && [ -z "$abuse" ] && [ "$NFILES" -le 3 ] && [ "$LINES_TOTAL" -le 20 ] \
   && ! printf '%s\n' "$FILES" | grep -qvE '\.md$'; then
    lane=L0
    reason="L0 三条件全命中: 文件数=${NFILES}≤3 ∧ 增删行总数=${LINES_TOTAL}≤20 ∧ 全为 .md 且无禁滥用命中（38.7 微变更通道）"
elif [ -n "$l2_hits" ]; then
    [ -n "$abuse" ] && reason="$reason | 附禁滥用备查: ${abuse% }"
elif [ -n "$abuse" ]; then
    reason="L1: 禁滥用命中 — ${abuse% }（38.7: L0 只承载存量体系微修正: 纯文档/注释/定数级联/规范括注/口径句, 代码/新增文件/新 Rule 段一律 L1）"
else
    reason="L1: L0 三条件未全命中（文件数=${NFILES}, 增删行=${LINES_TOTAL}, 非全 .md=${CODE_HIT:+有代码}）, 按现行默认全流程"
fi

echo "execution_lane: $lane"
echo "[lane-detect] $reason" >&2
exit 0
