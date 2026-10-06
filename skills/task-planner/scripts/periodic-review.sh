#!/usr/bin/env bash
# periodic-review.sh — Rule 57 周期性回顾与前后对照检测
# task-v142 P2-S1
# 用途：检测 findings.md 与 progress.md 中的结论一致性，输出结构化报告（JSON）
# 退出码：0=无矛盾 / 1=发现矛盾 / 2=参数错误或文件缺失
# 只读，不修改任何文件

set -u

# 路径解析
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 参数解析
if [ $# -lt 1 ]; then
  echo "Usage: $0 <plan-dir>" >&2
  exit 2
fi

PLAN_DIR="$1"
if [ ! -d "$PLAN_DIR" ]; then
  echo "ERROR: plan-dir not found: $PLAN_DIR" >&2
  exit 2
fi

FINDINGS="$PLAN_DIR/findings.md"
PROGRESS="$PLAN_DIR/progress.md"
TASK_PLAN="$PLAN_DIR/task_plan.md"

for f in "$FINDINGS" "$PROGRESS" "$TASK_PLAN"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: required file not found: $f" >&2
    exit 2
  fi
done

# 计数器
CONTRADICTIONS=0
WARNINGS=0
FINDINGS_COUNT=0
PROGRESS_COUNT=0

# 检测结果收集
DETECTED="[]"

# 辅助函数：添加检测结果
add_finding() {
  local severity="$1"
  local code="$2"
  local msg="$3"
  DETECTED=$(echo "$DETECTED" | jq --arg sev "$severity" --arg code "$code" --arg msg "$msg" \
    '. + [{"severity": $sev, "code": $code, "message": $msg}]')
  if [ "$severity" = "CRITICAL" ]; then
    CONTRADICTIONS=$((CONTRADICTIONS + 1))
  else
    WARNINGS=$((WARNINGS + 1))
  fi
}

# 检测 1：提取 findings.md 中的结论条目
extract_findings_conclusions() {
  grep -n '^- \|^## ' "$FINDINGS" 2>/dev/null | head -50 || true
}

# 检测 2：提取 progress.md 中的 Action 结论
extract_progress_conclusions() {
  grep -n '结论\|确认\|发现\|验证\|测试' "$PROGRESS" 2>/dev/null | head -50 || true
}

# 检测 3：检查结论一致性
check_conclusion_consistency() {
  local findings_conclusions
  findings_conclusions=$(extract_findings_conclusions)
  
  if [ -z "$findings_conclusions" ]; then
    return 0
  fi
  
  FINDINGS_COUNT=$(echo "$findings_conclusions" | wc -l)
  
  while IFS= read -r line; do
    local lineno
    lineno=$(echo "$line" | cut -d: -f1)
    local content
    content=$(echo "$line" | cut -d: -f2-)
    
    local keyword
    keyword=$(echo "$content" | tr -d '*-#' | sed 's/^[[:space:]]*//' | cut -c1-20)
    
    if [ -z "$keyword" ]; then
      continue
    fi
    
    local negation
    negation=$(grep -n "$keyword" "$PROGRESS" 2>/dev/null | grep -i '不\|否\|错误\|失败\|问题' | head -3 || true)
    
    if [ -n "$negation" ]; then
      add_finding "CRITICAL" "CONCLUSION-CONTRADICTION" "findings.md:$lineno 结论可能在 progress.md 中被否定: $keyword"
    fi
  done <<< "$findings_conclusions"
}

# 检测 4：检查假设一致性
check_assumption_consistency() {
  local progress_conclusions
  progress_conclusions=$(extract_progress_conclusions)
  
  if [ -z "$progress_conclusions" ]; then
    return 0
  fi
  
  PROGRESS_COUNT=$(echo "$progress_conclusions" | wc -l)
  
  while IFS= read -r line; do
    local lineno
    lineno=$(echo "$line" | cut -d: -f1)
    local content
    content=$(echo "$line" | cut -d: -f2-)
    
    local keyword
    keyword=$(echo "$content" | tr -d '*-#' | sed 's/^[[:space:]]*//' | cut -c1-20)
    
    if [ -z "$keyword" ]; then
      continue
    fi
    
    local negation
    negation=$(grep -n "$keyword" "$FINDINGS" 2>/dev/null | grep -i '不\|否\|错误\|失败\|问题' | head -3 || true)
    
    if [ -n "$negation" ]; then
      add_finding "WARNING" "ASSUMPTION-CONTRADICTION" "progress.md:$lineno 结论可能在 findings.md 中被否定: $keyword"
    fi
  done <<< "$progress_conclusions"
}

# 检测 5：检查 Goal 一致性
check_goal_consistency() {
  local goal
  goal=$(grep -A 5 '## Goal' "$TASK_PLAN" 2>/dev/null | head -10 || true)
  
  if [ -z "$goal" ]; then
    return 0
  fi
  
  local goal_keywords
  goal_keywords=$(echo "$goal" | tr -d '*-#' | sed 's/^[[:space:]]*//' | tr ' ' '\n' | head -5 || true)
  
  while IFS= read -r keyword; do
    if [ -z "$keyword" ]; then
      continue
    fi
    
    local in_progress
    in_progress=$(grep -c "$keyword" "$PROGRESS" 2>/dev/null || true)
    
    if [ "$in_progress" -eq 0 ]; then
      add_finding "WARNING" "GOAL-DRIFT" "Goal 关键词在 progress.md 中未出现: $keyword"
    fi
  done <<< "$goal_keywords"
}

# 执行检测
check_conclusion_consistency
check_assumption_consistency
check_goal_consistency

# 输出结构化报告
jq -n \
  --arg plan_dir "$PLAN_DIR" \
  --argjson contradictions "$CONTRADICTIONS" \
  --argjson warnings "$WARNINGS" \
  --argjson findings_count "$FINDINGS_COUNT" \
  --argjson progress_count "$PROGRESS_COUNT" \
  --argjson detected "$DETECTED" \
  '{
    plan_dir: $plan_dir,
    summary: {
      contradictions: $contradictions,
      warnings: $warnings,
      findings_count: $findings_count,
      progress_count: $progress_count
    },
    detected: $detected
  }'

# 退出码
if [ "$CONTRADICTIONS" -gt 0 ]; then
  exit 1
fi

exit 0
