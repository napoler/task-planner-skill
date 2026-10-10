#!/usr/bin/env bash
# auto-finalize.sh — 收尾引擎+清单（task-v167 波次4/5，42.7/38.7 消费面）
# 用法: bash auto-finalize.sh <plan-dir>
# WHAT: 一次跑完收尾簿记——INDEX 刷新/CHANGELOG 收口/四项证据校验，逐项 PASS/FAIL/WARN
#   清单+末行汇总；exit code = FAIL>0 ? 1 : 0。
# WHY : 移植 pwf「重机制收口为单次动作、完成后即弃」与 comet preset「一次初始化填好决策」——
#   收尾人工 4 项（CHANGELOG/delivery-summary/HANDOFF/goal-gate 证据）从多轮手工收口为单动作；
#   证据不代写=Rule 51/66 质量保留线：goal-gate 证据行/delivery-summary 正文必须人写，
#   机器只校验存在与形态（FAIL 仅提示人工补，绝不代填）。
# 依赖: plan-dir 含 task_plan.md/progress.md/delivery-summary.md；仓根 CHANGELOG.md；
#   sync-todos.sh 缺失或失败=WARN 不阻断（fail-open，收尾引擎不得被 INDEX 工具锁死）。

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAN_DIR="${1:?用法: auto-finalize.sh <plan-dir>}"
PLAN_DIR="$(cd "$PLAN_DIR" && pwd)"
P="$PLAN_DIR/task_plan.md"; PROG="$PLAN_DIR/progress.md"; DS="$PLAN_DIR/delivery-summary.md"
[ -f "$P" ] || { echo "FAIL 解析: task_plan.md 缺失（$PLAN_DIR）"; echo "finalize: 0 PASS / 1 FAIL"; exit 1; }
PASS=0; FAIL=0; WARN=0
mark() { # $1=状态 $2=项 $3=备注
  case "$1" in PASS) PASS=$((PASS+1));; FAIL) FAIL=$((FAIL+1));; *) WARN=$((WARN+1));; esac
  printf '[finalize] %-4s %s%s\n' "$1" "$2" "${3:+ — $3}"
}
# 1. 解析 task_id / outcome / template_type（frontmatter 或 task-vNNN；读不出=FAIL 继续余项）
TID="$(grep -m1 -oE 'task-v[0-9]+[0-9A-Za-z-]*' "$P" 2>/dev/null | head -1)"
TT="$(grep -m1 -oE '<!--[[:space:]]*template_type:[[:space:]]*[A-Za-z-]+' "$P" 2>/dev/null | grep -oE '[A-Za-z-]+$' || echo 无)"
OC="$(awk '/^##[[:space:]]*Goal/{f=1;next} f&&/^## /{exit} f&&NF{print;exit}' "$P" 2>/dev/null | head -1)"
[ -n "${TID:-}" ] && [ -n "${OC:-}" ] && mark PASS "解析" "task_id=$TID outcome='${OC:0:24}…' template_type=$TT" || mark FAIL "解析" "task_id/Goal 首行读不出（$TID）"
# 2. INDEX 刷新：调仓内 sync-todos.sh --index（plans 目录=PLAN_DIR 上级），失败 WARN 不阻断
PLANS_PARENT="$(dirname "$PLAN_DIR")"
ST="$SCRIPT_DIR/sync-todos.sh"
if [ -f "$ST" ]; then
  # 注: 命令替换后的 $? 语义=赋值语句自身（恒 0），故用 if 直接捕获被调命令退出码
  if SYNC_OUT="$(bash "$ST" --index "$PLANS_PARENT" 2>&1)"; then mark PASS "INDEX" "sync-todos --index 刷新完成"; else mark WARN "INDEX" "sync-todos 失败不阻断: ${SYNC_OUT:0:60}"; fi
else
  mark WARN "INDEX" "sync-todos.sh 缺失（skip，人工刷新）"
fi
# 3. CHANGELOG 收口：Goal 首行截 60 字+git log grep task_id 末条 merge sha，追加 [Unreleased] 段顶
REPO_ROOT="$(cd "$PLANS_PARENT" && git rev-parse --show-toplevel 2>/dev/null || true)"
CL="$REPO_ROOT/CHANGELOG.md"
if [ -n "$REPO_ROOT" ] && [ -n "$TID" ] && [ -n "$OC" ]; then
  CL_GOAL="$(printf '%s' "$OC" | cut -c1-60)"
  # Why: --grep 词边界（task-v168 不误配 task-v168d 前缀同族提交），log 为空取 HEAD short
  SHA="$(git -c core.quotepath=false -C "$REPO_ROOT" log --oneline -E --grep "${TID}([^0-9A-Za-z]|$)" 2>/dev/null | head -1 | awk '{print $1}')"
  [ -n "$SHA" ] || SHA="$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null)"
  ENTRY="- **${TID}**：${CL_GOAL}（merge ${SHA:-HEAD}）"
  [ -f "$CL" ] || { printf '# 变更日志\n\n## [Unreleased]\n' > "$CL"; }
  # 锚=已有 "### 变更" 小节首条 bullet 上方；无该小节=Unreleased 行上方（无 Unreleased 段则建）
  L="$(mktemp)"; awk -v cl="$CL" -v ent="$ENTRY" '
    $0=="### 变更" && !done {print; print ent; done=1; next}
    $0=="## [Unreleased]" && !done {print; print "### 变更"; print ent; done=1; next}
    {print} END{if(!done){print ""; print "## [Unreleased]"; print "### 变更"; print ent}}' "$CL" > "$L"
  cat "$L" > "$CL"; rm -f "$L"
  mark PASS "CHANGELOG" "追加条目（merge ${SHA:-HEAD}）"
else
  mark WARN "CHANGELOG" "非 git 仓或 Goal 缺失（skip 追加）"
fi
# 4. delivery-summary 五要素形态校验（Rule 48：说明/产出/审查/风险/下一步；缺区块=FAIL，正文不代写）
if [ -f "$DS" ]; then
  # 口径=五要素标题关键词各自 grep -q 计数（数字/中文数字/无编号三种形态容忍，锚见
  # templates/delivery-summary.md：## 1. 任务说明 / ## 2. 产出清单 / ## 3. 审查信息 / ## 4. 风险点 / ## 5. 下一步建议）
  DS_N=0
  for k in 任务说明 产出清单 审查信息 风险点 下一步建议; do
    grep -qE "^##[[:space:]]*([0-9]+[\.、]|[一二三四五]、)?[[:space:]]*${k}" "$DS" 2>/dev/null && DS_N=$((DS_N+1))
  done
  [ "${DS_N:-0}" -ge 5 ] && mark PASS "delivery-summary" "五要素区块 ${DS_N} 个在案" || mark FAIL "delivery-summary" "五要素区块仅 ${DS_N:-0}（需 5，Rule 48）"
else
  mark FAIL "delivery-summary" "缺失（人工按 templates/delivery-summary.md 补写，机器不代写）"
fi
# 5. goal-gate 证据：progress.md 含 [goal:N] 行≥1 且 Status: complete 行存在（Rule 66.3 证据行=人工补）
if [ -f "$PROG" ] && grep -qE '\[goal:[GN][0-9]*\]' "$PROG" && grep -qE '\*\*Status:\*\*[[:space:]]*complete' "$PROG"; then
  mark PASS "goal-gate 证据" "[goal:N] 行+complete 在案"
else
  mark FAIL "goal-gate 证据" "人工补 progress.md [goal:N] 证据行（验证命令+PASS+产物路径），机器不代填"
fi
# 6. HANDOFF：progress.md 若有 Handoff 表且 verify_done 列存在未勾（☐）=FAIL
# Why: 未勾判定保守化——只在 progress.md 出现 ☐（勾选框未勾）字面且文件含 verify_done 列时 FAIL；
# 无 Handoff 表=记 WARN 不 FAIL（N/A 豁免，机器只校验形态，勾全与否留人工面）
if [ -f "$PROG" ] && grep -qiE '^##[[:space:]]*.*Handoff' "$PROG"; then
  if grep -q 'verify_done' "$PROG" && grep -q '☐' "$PROG"; then
    mark FAIL "HANDOFF" "verify_done 列存在且仍有 ☐ 未勾，人工勾全后重跑"
  else
    mark PASS "HANDOFF" "verify_done 无未勾"
  fi
else
  mark WARN "HANDOFF" "无 Handoff 表（N/A 记 WARN）"
fi
# 7. 汇总清单（FAIL>0 → exit 1；WARN 不阻断）
printf '[finalize] 汇总: %d PASS / %d FAIL / %d WARN\n' "$PASS" "$FAIL" "$WARN"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
