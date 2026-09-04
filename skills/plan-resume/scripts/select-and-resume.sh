#!/usr/bin/env bash
# select-and-resume.sh — plan-resume v0.5 自主推进编排(v0.4 智能推进编排升级)
#
# v0.5: config 驱动默认自主(--dry-run/--auto-push 显式覆盖);新增 skip_states 硬排除与仓内范围守卫
#
# Usage: select-and-resume.sh [--repo-root PATH] [--auto-push | --dry-run]
#                              [--max-resume N] [--time-threshold SECONDS]
#                              [--report PATH] [--explain]
#
# 模式(优先级: flag > config.json autonomous_resume,SKILL.md §7.1):
#   --dry-run     强制只报告: 打印将推进的 Top N 候选,不修改任何文件
#   --auto-push   强制推进 Top 1 计划(向后兼容 cron 调用方)
#   无 flag       按 config autonomous_resume: true=auto-resume(默认) / false=dry-run
#   auto 模式在该 plan 的 task_plan.md 写 [auto-pushed-by-cron: <ts> mode=auto-resume ...]
#   (标记 token 沿用 v0.4,兼容旧过滤逻辑;payload mode 由 smart-resume 改为 auto-resume)
#
# v0.5 守卫(Top 1 选择前逐候选执行):
#   - skip_states(config,默认 blocked/awaiting-user/hold)任一命中 → 硬排除,报告记 "skip: <state>"
#     blocked → 匹配 "- **Status:** blocked"(大小写不敏感);其余 → 匹配 "[<state>]" 字面
#   - auto 模式下候选计划实际来源路径不在 --repo-root 之下 → 排除,报告记 "skip: outside-repo"
#     (来源按 plans/<tid>/task_plan.md → .zcode/plans/<tid>*.md → skills/*/plans/<tid>/task_plan.md 顺序
#      探测,readlink -f 物理解析;符号链接指向 repo-root 之外的候选同样排除;dry-run 仅报告不排除)
#
# 关键纪律(用户 2026-09-04 拍板,v0.5 沿用):
#   - circuit-break 一律熔断(不重试,立即停止)
#   - 单次最多推进 max_auto_plans_per_trigger(=1) 个 plan
#   - 推进前必须 Read plan 头 30 行确认 Goal 不变(防"plan 已被人工改向")
#   - 仅 [fresh] + 失败 < 3 + 无 [env-vanished] 才进候选
#
# 注意: 本脚本只产出"哪个 plan 该推进 + 在 plan 上写标记",**不实际执行 Phase 工作**
#   Phase 推进工作由调用方(主进程 / cron / subagent)按 task-planner 协议执行
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------- config 加载
# v0.5: 纯 grep/sed 解析 ../config.json(与仓内 extract-meta.sh"不依赖 jq/python"惯例一致)
# 缺文件/缺键时使用下方默认值兜底,不报错(SKILL.md §7.2)
CFG_AUTONOMOUS=1                              # autonomous_resume,默认 true
CFG_MAX_AUTO_PLANS=1                          # max_auto_plans_per_trigger,默认 1(仅取值记录,选 Top1 逻辑不变)
CFG_SKIP_STATES="blocked awaiting-user hold"  # skip_states,默认词表(空格分隔)
CONFIG_FILE="$SCRIPT_DIR/../config.json"
if [[ -f "$CONFIG_FILE" ]]; then
  # bool: autonomous_resume
  v="$(grep -E '^[[:space:]]*"autonomous_resume"' "$CONFIG_FILE" 2>/dev/null | head -1 \
       | sed 's/.*:[[:space:]]*//' | tr -d ' ,"' || true)"
  [[ "$v" == "false" ]] && CFG_AUTONOMOUS=0
  # int: max_auto_plans_per_trigger(本次只取值记录)
  v="$(grep -E '^[[:space:]]*"max_auto_plans_per_trigger"' "$CONFIG_FILE" 2>/dev/null | head -1 \
       | sed 's/.*:[[:space:]]*//' | tr -d ' ,"' || true)"
  [[ "$v" =~ ^[0-9]+$ ]] && CFG_MAX_AUTO_PLANS="$v"
  # 字符串数组: skip_states → 从数组行 sed 提取空格分隔词表
  arr_line="$(grep -E '^[[:space:]]*"skip_states"' "$CONFIG_FILE" 2>/dev/null | head -1 || true)"
  if [[ "$arr_line" == *'['*']'* ]]; then
    v="$(echo "$arr_line" | sed 's/.*\[\([^]]*\)\].*/\1/' | tr -d '"' | tr ',' ' ' \
         | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//')"
    [[ -n "$v" ]] && CFG_SKIP_STATES="$v"
  fi
fi

REPO_ROOT="$(pwd)"
MODE_EXPLICIT=0  # 是否显式给了 --dry-run/--auto-push(显式 flag 优先于 config)
AUTO_PUSH=0
DRY_RUN=1
MAX_RESUME=1  # 用户拍板:单次 ≤ 1
TIME_THRESHOLD=604800  # 7d
REPORT_PATH=""
EXPLAIN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-root) REPO_ROOT="${2:?}"; shift 2 ;;
    --auto-push) AUTO_PUSH=1; DRY_RUN=0; MODE_EXPLICIT=1; shift ;;
    --dry-run) AUTO_PUSH=0; DRY_RUN=1; MODE_EXPLICIT=1; shift ;;
    --max-resume) MAX_RESUME="${2:?}"; shift 2 ;;
    --time-threshold) TIME_THRESHOLD="${2:?}"; shift 2 ;;
    --report) REPORT_PATH="${2:?}"; shift 2 ;;
    --explain) EXPLAIN=1; shift ;;
    -h|--help)
      sed -n '2,29p' "$0"; exit 0 ;;
    *) echo "[select-and-resume] 未知参数: $1" >&2; exit 1 ;;
  esac
done

# v0.5 模式解析(优先级: flag > config): 无 flag 时按 autonomous_resume 默认自主
if [[ $MODE_EXPLICIT -eq 0 ]]; then
  if [[ $CFG_AUTONOMOUS -eq 1 ]]; then AUTO_PUSH=1; DRY_RUN=0; else AUTO_PUSH=0; DRY_RUN=1; fi
fi
MODE_STR="$([[ $AUTO_PUSH == 1 ]] && echo 'auto-resume' || echo 'dry-run')"

# REPO_ROOT 归一为物理绝对路径(供范围守卫 case 前缀匹配,与候选路径 readlink -f 解析口径一致)
REPO_ROOT="$(cd "$REPO_ROOT" 2>/dev/null && pwd -P)" || {
  echo "[select-and-resume] --repo-root 不存在: $REPO_ROOT" >&2
  exit 1
}

# 1. 跑 score-plans.py 拿候选列表
SCORE_OUT="$(mktemp)"
FILTERED_OUT="$(mktemp)"
SKIP_REPORT=""
trap 'rm -f "$SCORE_OUT" "$FILTERED_OUT"' EXIT

python3 "$SCRIPT_DIR/score-plans.py" \
  --repo-root "$REPO_ROOT" \
  --time-threshold "$TIME_THRESHOLD" \
  --json \
  > "$SCORE_OUT" 2>/dev/null || {
    echo "[select-and-resume] score-plans.py 失败" >&2
    exit 1
  }

if [[ ! -s "$SCORE_OUT" ]]; then
  echo "[select-and-resume] 无候选 plan(可能 0 满足过滤或 score 失败)" >&2
  exit 0
fi

CANDIDATE_COUNT="$(wc -l < "$SCORE_OUT")"

# 2. v0.5 候选循环: 仓内范围守卫(auto 模式)+ skip_states 硬排除,再取过滤后 Top 1
while IFS= read -r cand; do
  [[ -z "$cand" ]] && continue
  tid="$(echo "$cand" | python3 -c 'import sys,json; print(json.loads(sys.stdin.read())["task_id"])' 2>/dev/null)" || tid=""
  [[ -z "$tid" ]] && continue
  cpath="$REPO_ROOT/plans/$tid/task_plan.md"
  # 仓内范围守卫(v0.5 修复 2026-09-05: 原实现直接 case 重构路径,恒匹配 "$REPO_ROOT"/* 永不触发):
  # 按 score-plans.py 扫描顺序探测候选实际来源路径,readlink -f 物理解析后判断前缀,
  # 符号链接指向 repo-root 之外的候选同样排除;仅 auto 模式执行,dry-run 只报告不排除。
  # 找不到实际来源文件时不做此守卫,交由后续 CIRCUIT-BREAK(plan 不存在)兜底。
  cand_src=""
  [[ -f "$cpath" ]] && cand_src="$cpath"
  if [[ -z "$cand_src" ]]; then
    for p in "$REPO_ROOT"/.zcode/plans/"$tid"*.md; do
      [[ -f "$p" ]] && { cand_src="$p"; break; }
    done
  fi
  if [[ -z "$cand_src" ]]; then
    for p in "$REPO_ROOT"/skills/*/plans/"$tid"/task_plan.md; do
      [[ -f "$p" ]] && { cand_src="$p"; break; }
    done
  fi
  cand_real=""
  if [[ -n "$cand_src" ]]; then
    cand_real="$(readlink -f "$cand_src" 2>/dev/null)" || cand_real="$cand_src"
  fi
  if [[ $AUTO_PUSH -eq 1 && -n "$cand_real" ]]; then
    case "$cand_real" in
      "$REPO_ROOT"/*) ;;
      *) SKIP_REPORT+="skip: outside-repo — $tid"$'\n'; continue ;;
    esac
  fi
  # skip_states 硬排除: blocked → "- **Status:** blocked"(大小写不敏感);其余 → "[<state>]" 字面
  hit=""
  for st in $CFG_SKIP_STATES; do
    if [[ "$st" == "blocked" ]]; then
      if grep -qiE -- '^[[:space:]]*- \*\*Status:\*\*[[:space:]]*blocked' "$cpath" 2>/dev/null; then
        hit="blocked"; break
      fi
    elif grep -qF -- "[$st]" "$cpath" 2>/dev/null; then
      hit="$st"; break
    fi
  done
  if [[ -n "$hit" ]]; then
    SKIP_REPORT+="skip: $hit — $tid"$'\n'
    continue
  fi
  echo "$cand" >> "$FILTERED_OUT"
done < "$SCORE_OUT"

FILTERED_COUNT="$(wc -l < "$FILTERED_OUT")"

if [[ -n "$SKIP_REPORT" ]]; then
  echo "[select-and-resume] 守卫排除明细:" >&2
  echo "$SKIP_REPORT" >&2
fi

if [[ ! -s "$FILTERED_OUT" ]]; then
  echo "[select-and-resume] 无可用候选(共 $CANDIDATE_COUNT 个,全部被守卫排除)" >&2
  if [[ -n "$REPORT_PATH" ]]; then
    {
      echo "# plan-resume select-and-resume 报告 — $(date -u +%Y-%m-%dT%H:%M:%SZ)"
      echo ""
      echo "**模式**: $MODE_STR"
      echo "**候选数**: $CANDIDATE_COUNT(守卫后可用 0)"
      echo "**config**: autonomous_resume=$([[ $CFG_AUTONOMOUS == 1 ]] && echo true || echo false) max_auto_plans_per_trigger=$CFG_MAX_AUTO_PLANS skip_states=[$CFG_SKIP_STATES]"
      echo ""
      echo "## 排除明细"
      if [[ -n "$SKIP_REPORT" ]]; then echo "$SKIP_REPORT"; else echo "(无)"; fi
    } > "$REPORT_PATH"
    echo "[select-and-resume] 报告: $REPORT_PATH" >&2
  fi
  exit 0
fi

SELECTED="$(head -1 "$FILTERED_OUT")"  # 取过滤后 Top 1

if [[ $EXPLAIN -eq 1 ]]; then
  echo "=== plan-resume select-and-resume (mode=$MODE_STR) ===" >&2
  echo "=== 候选数: $CANDIDATE_COUNT(守卫后 $FILTERED_COUNT), max_resume=$MAX_RESUME ===" >&2
  echo "=== config: autonomous_resume=$([[ $CFG_AUTONOMOUS == 1 ]] && echo true || echo false) max_auto_plans_per_trigger=$CFG_MAX_AUTO_PLANS skip_states=[$CFG_SKIP_STATES] ===" >&2
fi

# 3. 解析 Top 1
TASK_ID="$(echo "$SELECTED" | python3 -c 'import sys,json; print(json.loads(sys.stdin.read())["task_id"])')"
SCORE_VAL="$(echo "$SELECTED" | python3 -c 'import sys,json; print(json.loads(sys.stdin.read())["score"])')"
PLAN_PATH="$REPO_ROOT/plans/$TASK_ID/task_plan.md"

# 4. 防御性检查: 推进前 Read plan 头 30 行(防 plan 已被人工改向)
if [[ ! -f "$PLAN_PATH" ]]; then
  echo "[select-and-resume] CIRCUIT-BREAK: $PLAN_PATH 不存在" >&2
  exit 1
fi

GOAL_LINE="$(head -30 "$PLAN_PATH" | grep -a '^## Goal' | head -1)"
if [[ -z "$GOAL_LINE" ]]; then
  echo "[select-and-resume] CIRCUIT-BREAK: $PLAN_PATH 无 ## Goal 段" >&2
  exit 1
fi

# 5. 检查是否已被 [auto-pushed-by-cron] 标记(防重入)
if grep -qa 'auto-pushed-by-cron' "$PLAN_PATH" 2>/dev/null; then
  echo "[select-and-resume] 跳过: $TASK_ID 已有 [auto-pushed-by-cron] 标记(防重入)" >&2
  exit 0
fi

# 6. 检查 circuit-break 标记
if grep -qa 'circuit-break-by-cron' "$PLAN_PATH" 2>/dev/null; then
  echo "[select-and-resume] 跳过: $TASK_ID 已被标 [circuit-break-by-cron]" >&2
  exit 0
fi

# 7. 决策
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
if [[ $EXPLAIN -eq 1 ]] || [[ $AUTO_PUSH -eq 0 ]]; then
  echo "[select-and-resume] $MODE_STR: Top 1 = $TASK_ID (score=$SCORE_VAL)"
  echo "  路径: $PLAN_PATH"
  echo "  Goal: $GOAL_LINE"
fi

if [[ $AUTO_PUSH -eq 0 ]]; then
  # Dry-run: 不写 plan,只打印剩余 Top
  if [[ $FILTERED_COUNT -gt 1 ]]; then
    echo ""
    echo "=== 剩余 Top 2-$FILTERED_COUNT (供下轮 cron 选) ==="
    tail -n +2 "$FILTERED_OUT" | python3 -c '
import sys, json
for i, line in enumerate(sys.stdin, 2):
    try:
        d = json.loads(line)
        tid = d["task_id"]
        sc = d["score"]
        print(f"  {i}. {tid:<50} score={sc:.4f}")
    except Exception:
        pass
' 2>/dev/null || true
  fi
  # 注意: --report 在 dry-run 模式下也会写(便于 cron 直接看报告)
  # 跳到下面的报告块;此处不 exit
  :
fi

# 8. auto 模式: 在 plan 上写 [auto-pushed-by-cron] 标记(token 不变,payload mode=auto-resume)
if [[ $AUTO_PUSH -eq 1 ]]; then
  TS_SHORT="$(date -u +%Y%m%d-%H%M)"
  MARKER="<!-- [auto-pushed-by-cron: $TS_SHORT mode=auto-resume score=$SCORE_VAL] -->"

  # 写标记到 plan 头部(在第一行 ## Goal 之前)
  TMP="$(mktemp)"
  {
    echo "$MARKER"
    echo ""
    cat "$PLAN_PATH"
  } > "$TMP"
  mv "$TMP" "$PLAN_PATH"

  echo ""
  echo "[select-and-resume] ✅ AUTO-RESUME 标记已写入:"
  echo "  $PLAN_PATH"
  echo "  标记: $MARKER"
  echo ""
  echo "[select-and-resume] 下一步:"
  echo "  主进程 / cron 现在调用 task-planner 推进 1 个 Phase,然后:"
  echo "  - 成功: 移除标记 [auto-pushed-by-cron],推进下一 Phase"
  echo "  - 失败 ≥2 次: 写 [circuit-break-by-cron: <reason>],下次 cron 跳过"
  echo "  - 完成: 全部 phase complete,自动跳过(无需手动)"
fi

# 9. 写报告(dry-run + auto 都支持)
if [[ -n "$REPORT_PATH" ]]; then
  {
    echo "# plan-resume select-and-resume 报告 — $NOW"
    echo ""
    echo "**模式**: $MODE_STR"
    echo "**候选数**: $CANDIDATE_COUNT(守卫后可用 $FILTERED_COUNT)"
    echo "**config**: autonomous_resume=$([[ $CFG_AUTONOMOUS == 1 ]] && echo true || echo false) max_auto_plans_per_trigger=$CFG_MAX_AUTO_PLANS skip_states=[$CFG_SKIP_STATES]"
    echo "**选中**: $TASK_ID (score=$SCORE_VAL)"
    echo "**路径**: $PLAN_PATH"
    echo "**Goal**: $GOAL_LINE"
    echo ""
    if [[ -n "$SKIP_REPORT" ]]; then
      echo "## 排除明细"
      echo "$SKIP_REPORT"
      echo ""
    fi
    echo "## 候选 Top 列表(守卫过滤后)"
    cat "$FILTERED_OUT" | python3 -c '
import sys, json
for i, line in enumerate(sys.stdin, 1):
    try:
        d = json.loads(line)
        tid = d["task_id"]
        sc = d["score"]
        od = d["out_degree"]
        gh = d["git_hits"]
        fc = d["failure_count"]
        ag = d["real_age_days"]
        gl = d["goal"]
        print(f"{i}. **{tid}** (score={sc:.4f})")
        print(f"   - out_degree={od} git_hits={gh} failure={fc} age={ag}d")
        print(f"   - goal: {gl}")
    except Exception:
        pass
' 2>/dev/null
  } > "$REPORT_PATH"
  echo ""
  echo "[select-and-resume] 报告: $REPORT_PATH"
fi
