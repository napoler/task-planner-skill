#!/usr/bin/env bash
# analyze-splits.sh — task-v144 S-unit 拆分体检（Rule 59.6 机器面 / 吸收 task-v135 丢失的 analyze-splits 目标）
#
# 用途：读取 task_plan.md 中 S-unit 派发单元表的「粒度(三值)」列（`Nf/Nl/Nmin` 格式，
#   9 列表在「预估时长」之后=awk -F'|' 第 8 字段），逐行对照 config.json 三值上限
#   （subagent.step_max_files/step_max_lines/step_max_minutes，现行默认 2/100/15）：
#   任一行超限 → 输出「Phase N S<n> 粒度 Xf/Yl/Zmin 超限(files≤2/lines≤100/min≤15)
#   — 建议: 拆成 K 个子单元」（K = ceil(各值/对应上限) 三者取最大，保底 2）并 exit 1；
#   全部合规 → exit 0。
#
# 边界：
#   - 只读 S-unit 表数据行（`| S<n> |` 开头）；legacy 7 列表（无粒度列）的数据行打
#     SKIPPED 提示不计违规（fail-open，与 check-plan-dispatch.sh legacy 放行口径一致）；
#     粒度列值缺段/畸形 → 该行 SKIPPED 放行（同 check-plan-dispatch 「时长不可解析」先例）。
#   - 不修改输入文件；不做 git 操作；阈值仅取 config.json（不读 env 覆盖——
#     59.7 零新 config 键纪律的延伸，避免多一个可调入口）。
#
# Why：R1「子代理拆分不细致→单个子代理解决巨量任务」的机器面兜底——
#   check-dispatch.sh 粒度校验在派发组装面拦截，本脚本在计划期 S-unit 表面提前体检，
#   超限行直接给出拆分建议而非事后返工。task-v135 曾在仓内实现同类拆分分析脚本，
#   产出丢失未合 master（根源覆盖表「机制守护」行），v144 以本脚本重建并纳入 59.6
#   selftest 守护（selftest-subagent-granularity-skill-escort.sh），杜绝再次静默丢失。
#
# 判例：[task-v144 S7] 粒度列位置=表头含「粒度」即 $8，否则无粒度列（$7 为时长列=
#   旧 7 列格式）——列位随最近一次见到的表头行切换，与 check-plan-dispatch.sh 的
#   「Phase 段 `### Phase` 状态机」范式同源（同一 Phase 内可先后出现新旧表时以各表
#   自己的表头为准）。
#
# Usage: bash analyze-splits.sh <task_plan.md> [--config <config.json>]
#   --config 缺省 = 本脚本所在目录的 ../config.json（与 check-plan-dispatch.sh 同范式）。
#
# 退出码：
#   0 = 全合规 / fail-open（缺文件、无 S-unit 行、全部 legacy 跳过）
#   1 = 存在粒度超限 S-unit 行（stdout 逐行拆分建议）
#   2 = 用法错误（无参）
#
# 依赖：bash + grep/sed/awk/coreutils；jq 可选——缺失（或 config 键缺）时回退默认
#   2/100/15 并打一行提示（禁静默，同 check-plan-dispatch.sh :123-134 先例）。

set -u

# 位置参解析（单趟：非 --config 实参=计划文件；--config 后跟实参=config 路径）
PLAN_FILE=""
CFG_OVERRIDE=""
argc=$#
i=1
while [ "$i" -le "$argc" ]; do
  a="${!i}"
  case "$a" in
    --config)
      i=$(( i + 1 ))
      [ "$i" -le "$argc" ] && CFG_OVERRIDE="${!i}"
      ;;
    --config=*) CFG_OVERRIDE="${a#--config=}" ;;
    *) PLAN_FILE="$a" ;;
  esac
  i=$(( i + 1 ))
done

if [ -z "$PLAN_FILE" ]; then
  cat >&2 <<'EOF'
Usage: analyze-splits.sh <task_plan.md> [--config <config.json>]
  读 S-unit 表粒度三值列(Nf/Nl/Nmin)，超限行输出拆分建议。
  exit 0=全合规/fail-open；exit 1=存在超限行；exit 2=用法错误。
EOF
  exit 2
fi

# 文件不可读 → fail-open（与 check-plan-dispatch.sh :49-52 同范式；不误伤旧流程调用方）
if [ ! -f "$PLAN_FILE" ] || [ ! -r "$PLAN_FILE" ]; then
  echo "[analyze-splits] fail-open: task_plan.md 不可读: $PLAN_FILE"
  exit 0
fi

# ── 阈值解析（Why: 上限单一事实源=config.json，禁脚本内硬编码漂移；
#    jq 缺失/键缺 → 回退默认 + 显式提示，禁静默掩盖配置缺失——宪法 §九）─────
STEP_MAX_FILES=2
STEP_MAX_LINES=100
STEP_MAX_MIN=15
CFG="${CFG_OVERRIDE:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../config.json}"
if command -v jq >/dev/null 2>&1 && [ -n "$CFG" ] && [ -f "$CFG" ]; then
  v="$(jq -r '.subagent.step_max_files // .properties.subagent.properties.step_max_files.default // empty' "$CFG" 2>/dev/null)" || v=""
  [[ "$v" =~ ^[0-9]+$ ]] && STEP_MAX_FILES="$v"
  v="$(jq -r '.subagent.step_max_lines // .properties.subagent.properties.step_max_lines.default // empty' "$CFG" 2>/dev/null)" || v=""
  [[ "$v" =~ ^[0-9]+$ ]] && STEP_MAX_LINES="$v"
  v="$(jq -r '.subagent.step_max_minutes // .properties.subagent.properties.step_max_minutes.default // empty' "$CFG" 2>/dev/null)" || v=""
  [[ "$v" =~ ^[0-9]+$ ]] && STEP_MAX_MIN="$v"
else
  echo "[analyze-splits] 提示: jq 缺失或 config.json 不可读($CFG) — 阈值回退默认 files≤2/lines≤100/min≤15"
fi
# 兜底合法性（防 config 写了 0 导致除零）
[ "$STEP_MAX_FILES" -ge 1 ] || STEP_MAX_FILES=2
[ "$STEP_MAX_LINES" -ge 1 ] || STEP_MAX_LINES=100
[ "$STEP_MAX_MIN" -ge 1 ] || STEP_MAX_MIN=15

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

# ── 主扫描（bash while-read 状态机，禁 awk 区间模式——gawk 区间 bug 已知，
#    与 check-plan-dispatch.sh :197-268 同款范式）─────────────────────────
phase_no=0
seq=0
gran_col=0        # 0=未知(未见过表头) / 7=旧格式(无粒度列) / 8=新 9 列表(粒度列 $8)
checked=0
skipped_legacy=0
skipped_bad=0
violations=0

# 超限行逐行体检（在 while-read 主循环内联执行；bash 函数取外层变量值不可靠，
# 故不用函数体——check-grain 逻辑直接内联于数据行分支）

ceil_div() {  # ceil_div <a> <b> — 正整数 a/b 向上取整（a=0 → 0；超限分支才调用，a>b≥1）
  echo $(( ( $1 + $2 - 1 ) / $2 ))
}

while IFS= read -r line; do
  # ① Phase 头：`### Phase N:`（N 缺省用扫描序号；同时复位表头状态——新 Phase 块
  #    不继承上一 Phase 的列位判定，与 check-plan-dispatch settle/reset 同源）
  if [[ "$line" =~ ^###[[:space:]]*Phase[[:space:]]*(.*)$ ]]; then
    seq=$(( seq + 1 ))
    if [[ "${BASH_REMATCH[1]}" =~ ([0-9]+) ]]; then phase_no="${BASH_REMATCH[1]}"; else phase_no="$seq"; fi
    gran_col=0
    continue
  fi
  # ② S-unit 表头：`| ID |` 开头 → 按「粒度」列名判定列位（9 列含粒度=$8 / 旧 7 列=无粒度列）
  if [[ "$line" == "| ID |"* || "$line" == "| ID|"* ]]; then
    if [[ "$line" == *"粒度"* ]]; then gran_col=8; else gran_col=7; fi
    continue
  fi
  # ③ S-unit 数据行：`| S<n> |` 开头（与 check-plan-dispatch.sh :229 同款正则）
  if [[ "$line" =~ ^\|[[:space:]]*S([0-9]+)[[:space:]]*\| ]]; then
    s_id="${BASH_REMATCH[1]}"
    # legacy/未知表头：无粒度列可解析 → SKIPPED 提示不计违规（fail-open，
    # 与 check-plan-dispatch legacy 放行口径一致——旧计划不误伤）
    if [ "$gran_col" -eq 7 ]; then
      skipped_legacy=$(( skipped_legacy + 1 ))
      echo "[analyze-splits] SKIPPED Phase ${phase_no} S${s_id} 无粒度列(旧 7 列表) — 不计违规"
      continue
    fi
    if [ "$gran_col" -eq 0 ]; then
      echo "[analyze-splits] SKIPPED Phase ${phase_no} S${s_id} 未见 S-unit 表头(列位未知) — 不计违规"
      continue
    fi
    # 解析粒度列（正则口径=check-plan-dispatch ⑤-c 统一 Nf/Nl/Nmin 无空格,task-v144 CR 复审建议2） $8：`Nf/Nl/Nmin`（三段；[2026-10-08 task-v144 S18 P2-3 注释修正: 原注「缺段按 0 计——
    # 部分填报也体检已报值」与实现相反——实际缺段/畸形走 SKIPPED 放行（不计违规, 与头注释口径一致）,
    # 仅当行尾 regex 三段全命中时逐段取数, 取数失败才 ${f:-0} 兜底）
    raw="$(printf '%s' "$line" | awk -F'|' -v c=8 '{print $c}')"
    raw="$(trim "$raw")"
    if ! [[ "$raw" =~ ^([0-9]+)f/([0-9]+)l/([0-9]+)min$ ]] \
       && ! [[ "$raw" =~ ^[0-9]+/[0-9]+/[0-9]+$ ]]; then
      skipped_bad=$(( skipped_bad + 1 ))
      echo "[analyze-splits] SKIPPED Phase ${phase_no} S${s_id} 粒度列不可解析('${raw}') — 不计违规"
      continue
    fi
    g1="$(printf '%s' "$raw" | cut -d'/' -f1)"
    g2="$(printf '%s' "$raw" | cut -d'/' -f2)"
    g3="$(printf '%s' "$raw" | cut -d'/' -f3)"
    f="$(printf '%s' "$g1" | grep -oE '[0-9]+' | head -n1)"
    l="$(printf '%s' "$g2" | grep -oE '[0-9]+' | head -n1)"
    m="$(printf '%s' "$g3" | grep -oE '[0-9]+' | head -n1)"
    f="${f:-0}"; l="${l:-0}"; m="${m:-0}"
    checked=$(( checked + 1 ))
    # 逐维超限判定；K = 各超限维度的 ceil(值/上限) 取最大（未超限维度不参与，
    # 保底 2：超限即至少拆二——单子单元原样保留=未拆，无修复意义）
    k=1
    over=0
    if [ "$f" -gt "$STEP_MAX_FILES" ]; then k="$(ceil_div "$f" "$STEP_MAX_FILES")"; over=1; fi
    if [ "$l" -gt "$STEP_MAX_LINES" ]; then kk="$(ceil_div "$l" "$STEP_MAX_LINES")"; [ "$kk" -gt "$k" ] && k="$kk"; over=1; fi
    if [ "$m" -gt "$STEP_MAX_MIN" ]; then kk="$(ceil_div "$m" "$STEP_MAX_MIN")"; [ "$kk" -gt "$k" ] && k="$kk"; over=1; fi
    if [ "$over" -eq 1 ]; then
      [ "$k" -lt 2 ] && k=2
      violations=$(( violations + 1 ))
      echo "[analyze-splits] ✗ Phase ${phase_no} S${s_id} 粒度 ${f}f/${l}l/${m}min 超限(files≤${STEP_MAX_FILES}/lines≤${STEP_MAX_LINES}/min≤${STEP_MAX_MIN}) — 建议: 拆成 ${k} 个子单元"
    fi
  fi
done < "$PLAN_FILE"

# ── 汇总输出 ─────────────────────────────────────────────────────────────
if [ "$violations" -gt 0 ]; then
  echo "[analyze-splits] ✗ 共 ${violations} 行 S-unit 粒度超限 — 请按建议拆分后重审(Rule 21.1b/59.1)"
  exit 1
fi
if [ "$checked" -eq 0 ]; then
  echo "[analyze-splits] fail-open: 无可解析粒度列的 S-unit 行(checked=0, legacy=${skipped_legacy}, unparseable=${skipped_bad})"
  exit 0
fi
echo "[analyze-splits] ✓ ${checked} 行 S-unit 粒度合规(files≤${STEP_MAX_FILES}/lines≤${STEP_MAX_LINES}/min≤${STEP_MAX_MIN}; 跳过 legacy=${skipped_legacy}/不可解析=${skipped_bad})"
exit 0
