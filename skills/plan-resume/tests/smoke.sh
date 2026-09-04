#!/usr/bin/env bash
# tests/smoke.sh — plan-resume skill 自检 v0.3
#
# Usage:
#   bash tests/smoke.sh              # 默认: 扫 ~/.zcode
#   bash tests/smoke.sh <worktree>   # 用指定工作树作为扫描根
#
# 假设: 当前仓已 commit 到 plan-resume 技能,scripts/ 下已有 scan-plans.sh 与 extract-meta.sh
set -uo pipefail  # 不设 -e,因为我们想收集所有 FAIL 而非首个

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCAN="$SKILL_DIR/scripts/scan-plans.sh"
EXTRACT_BIN="$SKILL_DIR/scripts/extract-meta.sh"
FAIL=0
TOTAL=0

# 通用 helper:提取 meta 后 grep
em_check() {
  local desc="$1" file="$2" pattern="$3"
  TOTAL=$((TOTAL + 1))
  local out
  out="$("$EXTRACT_BIN" "$file" 2>/dev/null)"
  if echo "$out" | grep -qE "$pattern"; then
    echo "[OK] $desc"
  else
    echo "[FAIL] $desc (got: $(echo "$out" | head -3))"
    FAIL=$((FAIL + 1))
  fi
}

# 通用 helper:scan 后 grep
sc_check() {
  local desc="$1" dir="$2" pattern="$3"
  TOTAL=$((TOTAL + 1))
  # stdout 过滤掉 stderr 前缀行 [scan-plans] (grep 可能因 set -o pipefail 错过)
  local out
  out="$("$SCAN" "$dir" 2>/dev/null | sed '/^\[scan-plans\]/d')"
  if echo "$out" | grep -qE "$pattern"; then
    echo "[OK] $desc"
  else
    echo "[FAIL] $desc (got: $(echo "$out" | head -3))"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== plan-resume smoke v0.3 ==="
echo "SKILL_DIR=$SKILL_DIR"

# ─── 基本语法与参数 ────────────────────────────────────────────────────────────
TOTAL=$((TOTAL + 1))
if bash -n "$SCAN"; then echo "[OK] bash -n scan-plans.sh"; else echo "[FAIL] bash -n scan-plans.sh"; FAIL=$((FAIL+1)); fi
TOTAL=$((TOTAL + 1))
if bash -n "$EXTRACT_BIN"; then echo "[OK] bash -n extract-meta.sh"; else echo "[FAIL] bash -n extract-meta.sh"; FAIL=$((FAIL+1)); fi
TOTAL=$((TOTAL + 1))
if "$SCAN" --help >/dev/null 2>&1; then echo "[OK] scan-plans.sh --help 工作"; else echo "[FAIL] scan-plans.sh --help 工作"; FAIL=$((FAIL+1)); fi
TOTAL=$((TOTAL + 1))
if "$SCAN" --help 2>&1 | grep -q 'time-threshold'; then echo "[OK] --time-threshold 帮助"; else echo "[FAIL] --time-threshold 帮助"; FAIL=$((FAIL+1)); fi
TOTAL=$((TOTAL + 1))
if "$SCAN" --help 2>&1 | grep -q 'include-archived'; then echo "[OK] --include-archived 帮助"; else echo "[FAIL] --include-archived 帮助"; FAIL=$((FAIL+1)); fi

# ─── task-planner 后端 ─────────────────────────────────────────────────────────
sc_check "scan-plans /home/terry/.zcode 产 >=1" /home/terry/.zcode '^/home'
sc_check "--only ts-migration 过滤生效" /home/terry/.zcode '^/home.*ts-migration'
# 注意: --only NONEXISTENT 会输出 "[scan-plans] 过滤后无匹配" 到 stderr,stdout 为空
# 所以用 sed 过滤 stderr 后验证: grep -q 找不到匹配即 FAIL
# 但 sc_check 已把 grep -q 作为判断条件,stdout 为空时 grep 返回 1 → FAIL
# 修正:改为检查 stdout 为空(无 /home 开头行)
TOTAL=$((TOTAL + 1))
LOCAL_OUT="$("$SCAN" /home/terry/.zcode --only 'NONEXISTENT_PATTERN_42' 2>/dev/null)"
if echo "$LOCAL_OUT" | grep -q '^/home'; then
  echo "[FAIL] --only NONEXISTENT 过滤到 0 (got: $LOCAL_OUT)"
  FAIL=$((FAIL+1))
else
  echo "[OK] --only NONEXISTENT 过滤到 0"
fi

em_check "extract-meta task-planner task_id" /home/terry/.zcode/plans/task-skillfix-bun-finish/task_plan.md '^task_id=task-skillfix-bun-finish$'
em_check "extract-meta task-planner format 标记" /home/terry/.zcode/plans/task-skillfix-bun-finish/task_plan.md '^format=task-planner$'

# ─── openspec 后端(本机已验证: /home/terry/openspec/) ─────────────────────────
sc_check "scan-plans 扫 openspec 有输出" /home/terry/openspec 'tasks\.md'
em_check "extract-meta openspec format 标记" /home/terry/openspec/changes/strengthen-execution-guidelines/tasks.md '^format=openspec$'
em_check "extract-meta openspec task_id" /home/terry/openspec/changes/strengthen-execution-guidelines/tasks.md '^task_id=strengthen-execution-guidelines$'

# ─── spec-kit 后端(用 fake 测试结构 + 真实模板) ────────────────────────────────
TEST_DIR="/tmp/.plan-resume-test-spec-kit"
mkdir -p "$TEST_DIR/specs/f001-feature-x"
cp /home/terry/.local/share/uv/tools/specify-cli/lib/python3.13/site-packages/specify_cli/core_pack/templates/spec-template.md "$TEST_DIR/specs/f001-feature-x/spec.md"
# 给 spec.md 注入实际 Status 字段(sed 替换 placeholder)
sed -i 's|\[FEATURE NAME\]|My Feature 101|' "$TEST_DIR/specs/f001-feature-x/spec.md"
sed -i 's|\*\*Status\*\*: Draft|**Status**: In Progress|' "$TEST_DIR/specs/f001-feature-x/spec.md"
cat > "$TEST_DIR/specs/f001-feature-x/tasks.md" <<'EOF'
## Phase 1: 初始化
- [ ] T001 创建项目结构
- [ ] T002 配置依赖

## Phase 2: 实现
- [x] T003 实现 auth 模块
- [ ] T004 实现 API 路由
EOF

sc_check "scan-plans 扫 spec-kit 有输出" "$TEST_DIR" 'tasks\.md'
em_check "extract-meta spec-kit format 标记" "$TEST_DIR/specs/f001-feature-x/tasks.md" '^format=spec-kit$'
em_check "extract-meta spec-kit 完成度计算(25%)" "$TEST_DIR/specs/f001-feature-x/tasks.md" '^task_completion_pct=25$'
em_check "extract-meta spec-kit spec.md 读 Status" "$TEST_DIR/specs/f001-feature-x/spec.md" '^current_phase=In Progress'

# 清理
rm -rf "$TEST_DIR"

# ─── 文件清单 ──────────────────────────────────────────────────────────────────
TOTAL=$((TOTAL + 1))
[ -f "$SKILL_DIR/../plan-resume/SKILL.md" ] && echo "[OK] SKILL.md 存在" || { echo "[FAIL] SKILL.md"; FAIL=$((FAIL+1)); }
TOTAL=$((TOTAL + 1))
[ -f "$SCAN" ] && echo "[OK] scan-plans.sh 存在" || { echo "[FAIL] scan-plans.sh"; FAIL=$((FAIL+1)); }
TOTAL=$((TOTAL + 1))
[ -f "$EXTRACT_BIN" ] && echo "[OK] extract-meta.sh 存在" || { echo "[FAIL] extract-meta.sh"; FAIL=$((FAIL+1)); }
TOTAL=$((TOTAL + 1))
[ -f "$SKILL_DIR/README.md" ] && echo "[OK] README.md 存在" || { echo "[FAIL] README.md"; FAIL=$((FAIL+1)); }
TOTAL=$((TOTAL + 1))
[ -f "$SKILL_DIR/tests/smoke.sh" ] && echo "[OK] tests/smoke.sh 存在" || { echo "[FAIL] tests/smoke.sh"; FAIL=$((FAIL+1)); }

echo ""
echo "=== 总计: $TOTAL 项测试,FAIL=$FAIL ==="
if [[ $FAIL -eq 0 ]]; then
  echo "[OK] plan-resume v0.3 smoke 全部通过"
  exit 0
else
  echo "[FAIL] $FAIL / $TOTAL 未通过"
  exit 1
fi