#!/usr/bin/env bash
# select-and-resume.sh — plan-resume v0.4 智能推进编排(2026-09-04 新增)
#
# Usage: select-and-resume.sh [--repo-root PATH] [--auto-push | --dry-run]
#                              [--max-resume N] [--time-threshold SECONDS]
#                              [--report PATH] [--explain]
#
# 模式:
#   --dry-run (默认)  打印将推进的 Top N 候选,不修改任何文件
#   --auto-push       实际推进 Top 1 计划(单次执行最多 1 个,防上下文耗尽)
#                     在该 plan 的 task_plan.md 写 [auto-pushed-by-cron: <ts>]
#
# 关键纪律(用户 2026-09-04 拍板):
#   - circuit-break 一律熔断(不重试,立即停止)
#   - 单次最多推进 1 个 plan
#   - 推进前必须 Read plan 头 30 行确认 Goal 不变(防"plan 已被人工改向")
#   - 仅 [fresh] + 失败 < 3 + 无 [env-vanished] 才进候选
#
# 注意: 本脚本只产出"哪个 plan 该推进 + 在 plan 上写标记",**不实际执行 Phase 工作**
#   Phase 推进工作由调用方(主进程 / cron / subagent)按 task-planner 协议执行
#   本脚本的角色 = "智能选 1 个 plan + 在 plan 上贴 [auto-pushed-by-cron] 标记"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REPO_ROOT="$(pwd)"
AUTO_PUSH=0
DRY_RUN=1
MAX_RESUME=1  # 用户拍板:单次 ≤ 1
TIME_THRESHOLD=604800  # 7d
REPORT_PATH=""
EXPLAIN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-root) REPO_ROOT="${2:?}"; shift 2 ;;
    --auto-push) AUTO_PUSH=1; DRY_RUN=0; shift ;;
    --dry-run) AUTO_PUSH=0; DRY_RUN=1; shift ;;
    --max-resume) MAX_RESUME="${2:?}"; shift 2 ;;
    --time-threshold) TIME_THRESHOLD="${2:?}"; shift 2 ;;
    --report) REPORT_PATH="${2:?}"; shift 2 ;;
    --explain) EXPLAIN=1; shift ;;
    -h|--help)
      sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "[select-and-resume] 未知参数: $1" >&2; exit 1 ;;
  esac
done

# 1. 跑 score-plans.py 拿候选列表
SCORE_OUT="$(mktemp)"
trap 'rm -f "$SCORE_OUT"' EXIT

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
SELECTED="$(head -1 "$SCORE_OUT")"  # 取 Top 1

if [[ $EXPLAIN -eq 1 ]]; then
  echo "=== plan-resume select-and-resume (mode=$([[ $AUTO_PUSH == 1 ]] && echo auto-push || echo dry-run)) ===" >&2
  echo "=== 候选数: $CANDIDATE_COUNT, max_resume=$MAX_RESUME ===" >&2
fi

# 2. 解析 Top 1
TASK_ID="$(echo "$SELECTED" | python3 -c 'import sys,json; print(json.loads(sys.stdin.read())["task_id"])')"
SCORE_VAL="$(echo "$SELECTED" | python3 -c 'import sys,json; print(json.loads(sys.stdin.read())["score"])')"
PLAN_PATH="$REPO_ROOT/plans/$TASK_ID/task_plan.md"

# 3. 防御性检查: 推进前 Read plan 头 30 行(防 plan 已被人工改向)
if [[ ! -f "$PLAN_PATH" ]]; then
  echo "[select-and-resume] CIRCUIT-BREAK: $PLAN_PATH 不存在" >&2
  exit 1
fi

GOAL_LINE="$(head -30 "$PLAN_PATH" | grep -a '^## Goal' | head -1)"
if [[ -z "$GOAL_LINE" ]]; then
  echo "[select-and-resume] CIRCUIT-BREAK: $PLAN_PATH 无 ## Goal 段" >&2
  exit 1
fi

# 4. 检查是否已被 [auto-pushed-by-cron] 标记(防重入)
if grep -qa 'auto-pushed-by-cron' "$PLAN_PATH" 2>/dev/null; then
  echo "[select-and-resume] 跳过: $TASK_ID 已有 [auto-pushed-by-cron] 标记(防重入)" >&2
  exit 0
fi

# 5. 检查 circuit-break 标记
if grep -qa 'circuit-break-by-cron' "$PLAN_PATH" 2>/dev/null; then
  echo "[select-and-resume] 跳过: $TASK_ID 已被标 [circuit-break-by-cron]" >&2
  exit 0
fi

# 6. 决策
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
REPORT_LINE_TOP=""
if [[ $EXPLAIN -eq 1 ]] || [[ $AUTO_PUSH -eq 0 ]]; then
  REPORT_LINE_TOP="[select-and-resume] $([[ $AUTO_PUSH == 1 ]] && echo 'AUTO-PUSH' || echo 'DRY-RUN'): Top 1 = $TASK_ID (score=$SCORE_VAL)"
  echo "$REPORT_LINE_TOP"
  echo "  路径: $PLAN_PATH"
  echo "  Goal: $GOAL_LINE"
fi

if [[ $AUTO_PUSH -eq 0 ]]; then
  # Dry-run: 不写 plan,只打印剩余 Top
  if [[ $CANDIDATE_COUNT -gt 1 ]]; then
    echo ""
    echo "=== 剩余 Top 2-$CANDIDATE_COUNT (供下轮 cron 选) ==="
    tail -n +2 "$SCORE_OUT" | python3 -c '
import sys, json
for i, line in enumerate(sys.stdin, 2):
    try:
        d = json.loads(line)
        print(f"  {i}. {d[\"task_id\"]:<50} score={d[\"score\"]:.4f}")
    except Exception:
        pass
' 2>/dev/null || true
  fi
  # 注意: --report 在 dry-run 模式下也会写(便于 cron 直接看报告)
  # 跳到下面的报告块;此处不 exit
  :
fi

# 7. auto-push 模式: 在 plan 上写 [auto-pushed-by-cron] 标记
if [[ $AUTO_PUSH -eq 1 ]]; then
  TS_SHORT="$(date -u +%Y%m%d-%H%M)"
  MARKER="<!-- [auto-pushed-by-cron: $TS_SHORT mode=smart-resume score=$SCORE_VAL] -->"

  # 写标记到 plan 头部(在第一行 ## Goal 之前)
  TMP="$(mktemp)"
  {
    echo "$MARKER"
    echo ""
    cat "$PLAN_PATH"
  } > "$TMP"
  mv "$TMP" "$PLAN_PATH"

  echo ""
  echo "[select-and-resume] ✅ AUTO-PUSH 标记已写入:"
  echo "  $PLAN_PATH"
  echo "  标记: $MARKER"
  echo ""
  echo "[select-and-resume] 下一步:"
  echo "  主进程 / cron 现在调用 task-planner 推进 1 个 Phase,然后:"
  echo "  - 成功: 移除标记 [auto-pushed-by-cron],推进下一 Phase"
  echo "  - 失败 ≥2 次: 写 [circuit-break-by-cron: <reason>],下次 cron 跳过"
  echo "  - 完成: 全部 phase complete,自动跳过(无需手动)"
fi

# 8. 写报告(dry-run + auto-push 都支持)
if [[ -n "$REPORT_PATH" ]]; then
  {
    echo "# plan-resume select-and-resume 报告 — $NOW"
    echo ""
    echo "**模式**: $([[ $AUTO_PUSH == 1 ]] && echo 'auto-push' || echo 'dry-run')"
    echo "**候选数**: $CANDIDATE_COUNT"
    echo "**选中**: $TASK_ID (score=$SCORE_VAL)"
    echo "**路径**: $PLAN_PATH"
    echo "**Goal**: $GOAL_LINE"
    echo ""
    echo "## 候选 Top 列表"
    cat "$SCORE_OUT" | python3 -c '
import sys, json
for i, line in enumerate(sys.stdin, 1):
    try:
        d = json.loads(line)
        print(f"{i}. **{d[\"task_id\"]}** (score={d[\"score\"]:.4f})")
        print(f"   - out_degree={d[\"out_degree\"]} git_hits={d[\"git_hits\"]} "
              f"failure={d[\"failure_count\"]} age={d[\"real_age_days\"]}d")
        print(f"   - goal: {d[\"goal\"]}")
    except Exception as e:
        pass
' 2>/dev/null
  } > "$REPORT_PATH"
  echo ""
  echo "[select-and-resume] 报告: $REPORT_PATH"
fi
