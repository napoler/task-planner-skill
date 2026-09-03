#!/usr/bin/env bash
# tests/smoke.sh — plan-resume skill 自检
#
# Usage:
#   bash tests/smoke.sh              # 默认: 扫 ~/.zcode
#   bash tests/smoke.sh <worktree>   # 用指定工作树作为扫描根(如 /mnt/data/dev/task-planner-skill-worktrees/xxx)
#
# 假设: 当前仓已 commit 到 plan-resume 技能,scripts/ 下已有 scan-plans.sh 与 extract-meta.sh
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCAN="$SKILL_DIR/scripts/scan-plans.sh"
EXTRACT="$SKILL_DIR/scripts/extract-meta.sh"
FAIL=0

check() {
  local desc="$1"; shift
  if "$@"; then
    echo "[OK] $desc"
  else
    echo "[FAIL] $desc: $*"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== plan-resume smoke ==="
echo "SKILL_DIR=$SKILL_DIR"

# 1. bash -n 语法(所有脚本)
check "bash -n scan-plans.sh" bash -n "$SCAN"
check "bash -n extract-meta.sh" bash -n "$EXTRACT"

# 2. --help 出口 0 且输出包含 USAGE
check "scan-plans.sh --help 工作" bash -c "\"$SCAN\" --help >/dev/null"
check "scan-plans.sh --time-threshold 帮助输出" grep -q 'time-threshold' <(bash -c "\"$SCAN\" --help" 2>&1)

# 3. 扫真实工作区: ~/.zcode 应至少产出一条(主仓的 plans/ 目录或 .zcode/plans/)
REAL_COUNT=$(bash -c "\"$SCAN\" /home/terry/.zcode" 2>/dev/null | grep -c '^/home' || true)
check "scan-plans.sh /home/terry/.zcode 产 >=1 条" [ "$REAL_COUNT" -ge 1 ]

# 4. --only 过滤生效(过滤到 0 或 < 全量)
FILTERED=$(bash -c "\"$SCAN\" /home/terry/.zcode --only 'NONEXISTENT_PATTERN_42'" 2>/dev/null | grep -c '^/home' || true)
check "--only 过滤到 0" [ "$FILTERED" -eq 0 ]

# 5. --only 过滤部分匹配(如 ts-migration 应有 1 条)
TS_COUNT=$(bash -c "\"$SCAN\" /home/terry/.zcode --only 'ts-migration'" 2>/dev/null | grep -c '^/home' || true)
check "--only ts-migration 产 >=1" [ "$TS_COUNT" -ge 1 ]

# 6. extract-meta.sh 对已知 task_plan.md 可提取 task_id
META=$(bash -c "\"$EXTRACT\" /home/terry/.zcode/plans/task-skillfix-bun-finish/task_plan.md" 2>/dev/null)
check "extract-meta 能提取 task_id" echo "$META" | grep -q '^task_id=task-skillfix-bun-finish$'
check "extract-meta 能提取 all_complete=0" echo "$META" | grep -q '^all_complete=0$'

# 7. plan-resume 文件清单(3 文件 + 1 README)
check "companion/skills/plan-resume/SKILL.md 存在" [ -f "$SKILL_DIR/../plan-resume/SKILL.md" ]
check "companion/skills/plan-resume/scripts/scan-plans.sh 存在" [ -f "$SCAN" ]
check "companion/skills/plan-resume/scripts/extract-meta.sh 存在" [ -f "$EXTRACT" ]
check "companion/skills/plan-resume/README.md 存在" [ -f "$SKILL_DIR/README.md" ]

echo ""
if [[ $FAIL -eq 0 ]]; then
  echo "[OK] plan-resume smoke 全部通过"
  exit 0
else
  echo "[FAIL] 通过: $(expr 10 - $FAIL) / 10"
  exit 1
fi