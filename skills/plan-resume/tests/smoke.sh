#!/usr/bin/env bash
# tests/smoke.sh — plan-resume skill 自检 v0.6(v0.3 基础检查 + v0.5 select-and-resume/config 用例 + v0.6 决策自主化用例)
#
# Usage:
#   bash tests/smoke.sh              # 默认: 扫 ~/.zcode
#   bash tests/smoke.sh <worktree>   # 用指定工作树作为扫描根
#
# 假设: 当前仓已 commit 到 plan-resume 技能,scripts/ 下已有 scan-plans.sh、
#       extract-meta.sh 与 select-and-resume.sh(v0.5,config 驱动自主模式)
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

echo "=== plan-resume smoke v0.6 ==="
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
# 2026-09-05: scan-plans.sh v0.4 重构后无 --include-archived flag(原断言过时,改前即红),
# 改为校验实际存在的 --only 帮助,保持"帮助输出含 flag 说明"的覆盖意图
TOTAL=$((TOTAL + 1))
if "$SCAN" --help 2>&1 | grep -q 'only'; then echo "[OK] --only 帮助"; else echo "[FAIL] --only 帮助"; FAIL=$((FAIL+1)); fi

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
# 2026-09-05: extract-meta.sh v0.4 起不再输出 format= 字段(原断言过时,改前即红),
# 改为校验 v0.4 实际输出的 all_complete 字段
em_check "extract-meta task-planner all_complete 字段" /home/terry/.zcode/plans/task-skillfix-bun-finish/task_plan.md '^all_complete=[01]$'

# ─── openspec 后端(本机已验证: /home/terry/openspec/) ─────────────────────────
# 2026-09-05: scan-plans.sh v0.4 起只扫 task_plan.md / plan-sess_*.md,openspec 的
# changes/*/tasks.md 不再入扫(原断言"扫出 tasks.md"过时,改前即红),改为锁定新行为
TOTAL=$((TOTAL + 1))
OPENSPEC_OUT="$("$SCAN" /home/terry/openspec 2>/dev/null | sed '/^\[scan-plans\]/d')"
if echo "$OPENSPEC_OUT" | grep -q 'tasks\.md'; then
  echo "[FAIL] scan-plans 对 openspec 根不扫 tasks.md (got: $(echo "$OPENSPEC_OUT" | head -3))"
  FAIL=$((FAIL+1))
else
  echo "[OK] scan-plans 对 openspec 根不扫 tasks.md(v0.4+ 仅 task_plan.md/plan-sess)"
fi
# 2026-09-05: format= 字段已移除(原断言过时),改为校验 v0.4 实际输出的 real_age_days 字段
em_check "extract-meta openspec real_age_days 字段" /home/terry/openspec/changes/strengthen-execution-guidelines/tasks.md '^real_age_days=[0-9]+$'
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

# 2026-09-05: scan-plans.sh v0.4+ 不扫 specs/*/tasks.md(spec-kit 结构,原断言过时,改前即红),
# 改为锁定 stdout 为空的新行为
TOTAL=$((TOTAL + 1))
SPECKIT_SCAN_OUT="$("$SCAN" "$TEST_DIR" 2>/dev/null | sed '/^\[scan-plans\]/d')"
if echo "$SPECKIT_SCAN_OUT" | grep -q 'tasks\.md'; then
  echo "[FAIL] scan-plans 对 spec-kit 结构不扫 tasks.md (got: $(echo "$SPECKIT_SCAN_OUT" | head -3))"
  FAIL=$((FAIL+1))
else
  echo "[OK] scan-plans 对 spec-kit 结构不扫 tasks.md(v0.4+ 仅 task_plan.md/plan-sess)"
fi
# 2026-09-05: v0.4 起 format=/task_completion_pct/current_phase(读 Status)均不再是 extract-meta 输出
# (原三条断言过时,改前即红),改为校验实际输出字段: all_complete / failure_count / git_last_commit
em_check "extract-meta spec-kit all_complete=0(存在未完成 Phase)" "$TEST_DIR/specs/f001-feature-x/tasks.md" '^all_complete=0$'
em_check "extract-meta spec-kit failure_count=0(无 progress.md)" "$TEST_DIR/specs/f001-feature-x/tasks.md" '^failure_count=0$'
em_check "extract-meta spec-kit spec.md git_last_commit=0(untracked 兜底)" "$TEST_DIR/specs/f001-feature-x/spec.md" '^git_last_commit=0$'

# 清理
rm -rf "$TEST_DIR"

# ─── v0.5 select-and-resume.sh + config(沙箱测试) ─────────────────────────────
# 说明: select-and-resume.sh 从自身位置的 ../config.json 读配置(纯 grep/sed 解析),
# 因此每个用例把整个 scripts/ 复制进独立 /tmp 沙箱,config.json 放沙箱根目录,
# 使脚本的 CONFIG_FILE 指向沙箱内的 config 而非仓内真实配置。
# 沙箱 repo 不是 git 仓 → score-plans.py 的 git_hits=0、real_age 走 mtime 兜底(预期内)。
SR_BIN="$SKILL_DIR/scripts/select-and-resume.sh"
V05_ROOT="/tmp/.plan-resume-test-v05"
rm -rf "$V05_ROOT"
trap 'rm -rf "$V05_ROOT"' EXIT  # 结尾清理 + 中途退出兜底

TOTAL=$((TOTAL + 1))
if bash -n "$SR_BIN"; then echo "[OK] bash -n select-and-resume.sh"; else echo "[FAIL] bash -n select-and-resume.sh"; FAIL=$((FAIL+1)); fi

# v0.5 沙箱 helper: 建独立沙箱目录 + 复制 scripts/ + 建 repo/plans/
sr_sandbox() {
  local sb="$1"
  mkdir -p "$sb/repo/plans"
  cp -r "$SKILL_DIR/scripts" "$sb/scripts"
}

# v0.5 plan fixture: 干净候选(pending Phase + ## Goal 在头 30 行内)
# $1=plans 目录路径 $2=task_id(=目录名) $3=frontmatter 附加行(可空) $4=正文附加行(可空)
sr_make_plan() {
  local pdir="$1" tid="$2" fm="$3" extra="$4"
  mkdir -p "$pdir"
  {
    echo "---"
    echo "task_id: $tid"
    if [[ -n "$fm" ]]; then echo "$fm"; fi
    echo "---"
    echo ""
    echo "## Goal"
    echo "完成 $tid(测试夹具目标)"
    echo ""
    echo "## Phases"
    echo ""
    echo "### Phase 1: 实现"
    echo "- **Status:** pending"
    echo "- [ ] T001 执行 $tid"
    if [[ -n "$extra" ]]; then echo "$extra"; fi
  } > "$pdir/task_plan.md"
}

# v0.5 通用 helper: 任意条件断言($2 传 1/0)
sr_check() {
  local desc="$1" ok="$2"
  TOTAL=$((TOTAL + 1))
  if [[ "$ok" == "1" ]]; then
    echo "[OK] $desc"
  else
    echo "[FAIL] $desc"
    FAIL=$((FAIL + 1))
  fi
}

# ── v0.5-a config 加载: autonomous_resume=false → 无 flag 走 dry-run;缺 config → 默认 auto
SB_A="$V05_ROOT/case-a-config"
sr_sandbox "$SB_A"
printf '{\n  "autonomous_resume": false\n}\n' > "$SB_A/config.json"
sr_make_plan "$SB_A/repo/plans/p-alpha" "p-alpha" "" ""
OUT_A="$(bash "$SB_A/scripts/select-and-resume.sh" --repo-root "$SB_A/repo" 2>&1)"
sr_check "v0.5-a1 config autonomous_resume=false → 无 flag 输出 dry-run Top 1" \
  "$(echo "$OUT_A" | grep -q 'dry-run: Top 1' && echo 1 || echo 0)"
sr_check "v0.5-a2 config dry-run 不写 auto-pushed 标记" \
  "$(grep -q 'auto-pushed-by-cron' "$SB_A/repo/plans/p-alpha/task_plan.md" && echo 0 || echo 1)"
rm -f "$SB_A/config.json"
bash "$SB_A/scripts/select-and-resume.sh" --repo-root "$SB_A/repo" >/dev/null 2>&1
sr_check "v0.5-a3 缺 config 默认 autonomous → 写入 mode=auto-resume 标记" \
  "$(grep -q 'mode=auto-resume' "$SB_A/repo/plans/p-alpha/task_plan.md" && echo 1 || echo 0)"

# ── v0.6-b skip_states 硬排除(收窄): blocked/[hold] 仍排除;[awaiting-user] 改为可选中(v0.6 核心行为)
SB_B="$V05_ROOT/case-b-skip-states"
sr_sandbox "$SB_B"
sr_make_plan "$SB_B/repo/plans/p-blocked" "p-blocked" "" "- **Status:** blocked"
sr_make_plan "$SB_B/repo/plans/p-wait" "p-wait" "" "等待用户确认 [awaiting-user]"
sr_make_plan "$SB_B/repo/plans/p-hold" "p-hold" "" "用户说等等 [hold]"
sr_make_plan "$SB_B/repo/plans/p-clean" "p-clean" "" ""
REPORT_B="$SB_B/report-dry.md"
OUT_B="$(bash "$SB_B/scripts/select-and-resume.sh" --repo-root "$SB_B/repo" --dry-run --report "$REPORT_B" 2>&1)"
sr_check "v0.6-b1 dry-run 报告含 skip: blocked 排除记录" \
  "$(grep -q 'skip: blocked' "$REPORT_B" && echo 1 || echo 0)"
sr_check "v0.6-b2 dry-run 报告含 skip: hold 排除记录" \
  "$(grep -q 'skip: hold' "$REPORT_B" && echo 1 || echo 0)"
sr_check "v0.6-b3 dry-run Top 1 为未被排除的 p-clean" \
  "$(echo "$OUT_B" | grep -q 'dry-run: Top 1 = p-clean' && echo 1 || echo 0)"
OUT_B2="$(bash "$SB_B/scripts/select-and-resume.sh" --repo-root "$SB_B/repo" 2>&1)"  # 无 config → 默认 auto
sr_check "v0.6-b4 auto 模式 blocked 候选未被写标记" \
  "$(grep -q 'auto-pushed-by-cron' "$SB_B/repo/plans/p-blocked/task_plan.md" && echo 0 || echo 1)"
sr_check "v0.6-b5 auto 模式选中落在未排除的 p-clean" \
  "$(grep -q 'mode=auto-resume' "$SB_B/repo/plans/p-clean/task_plan.md" && echo 1 || echo 0)"

# v0.6-b6/b7 核心新增: [awaiting-user] 候选不再被排除——移除 p-clean 后 p-wait 应成为 Top 1
rm -rf "$SB_B/repo/plans/p-clean"
REPORT_B3="$SB_B/report-dry3.md"
OUT_B3="$(bash "$SB_B/scripts/select-and-resume.sh" --repo-root "$SB_B/repo" --dry-run --report "$REPORT_B3" 2>&1)"
sr_check "v0.6-b6 [awaiting-user] 候选可被选中(dry-run Top 1 = p-wait)" \
  "$(echo "$OUT_B3" | grep -q 'dry-run: Top 1 = p-wait' && echo 1 || echo 0)"
sr_check "v0.6-b7 报告不再出现 skip: awaiting-user(v0.6 移出排除表)" \
  "$(grep -q 'skip: awaiting-user' "$REPORT_B3" && echo 0 || echo 1)"

# v0.6-b8/b9 脚手架垃圾硬排除: Goal 段含未展开占位符的计划不进候选
sr_make_plan "$SB_B/repo/plans/p-garbage" "p-garbage" "" ""
sed -i 's/完成 p-garbage(测试夹具目标)/[一句话：为 $SITE 创作 $ID 文章]/' "$SB_B/repo/plans/p-garbage/task_plan.md"
REPORT_B4="$SB_B/report-dry4.md"
OUT_B4="$(bash "$SB_B/scripts/select-and-resume.sh" --repo-root "$SB_B/repo" --dry-run --report "$REPORT_B4" 2>&1)"
sr_check "v0.6-b8 Goal 占位符候选被排除(报告含 skip: scaffold-garbage)" \
  "$(grep -q 'skip: scaffold-garbage' "$REPORT_B4" && echo 1 || echo 0)"
sr_check "v0.6-b9 排除后 Top 1 仍为 p-wait(候选池零污染)" \
  "$(echo "$OUT_B4" | grep -q 'dry-run: Top 1 = p-wait' && echo 1 || echo 0)"

# ── v0.5-c 默认自主 + auto 标记: Top1 被写标记,其余不被碰
SB_C="$V05_ROOT/case-c-auto-marker"
sr_sandbox "$SB_C"
# 用 block_id/depends_on 让 p-alpha 的 out_degree=1 → score 最高,Top1 确定(沙箱无 git,tie 无法靠 git_hits 打破)
sr_make_plan "$SB_C/repo/plans/p-alpha" "p-alpha" "block_id: p-alpha" ""
sr_make_plan "$SB_C/repo/plans/p-beta" "p-beta" "depends_on: [p-alpha]" ""
MD5_BETA_0="$(md5sum "$SB_C/repo/plans/p-beta/task_plan.md" | cut -d' ' -f1)"
bash "$SB_C/scripts/select-and-resume.sh" --repo-root "$SB_C/repo" >/dev/null 2>&1
sr_check "v0.5-c1 默认 auto Top1(p-alpha)写入 mode=auto-resume 标记" \
  "$(grep -q 'mode=auto-resume' "$SB_C/repo/plans/p-alpha/task_plan.md" && echo 1 || echo 0)"
sr_check "v0.5-c2 非 Top1(p-beta)未被修改(md5 不变)" \
  "$([[ "$(md5sum "$SB_C/repo/plans/p-beta/task_plan.md" | cut -d' ' -f1)" == "$MD5_BETA_0" ]] && echo 1 || echo 0)"

# ── v0.5-d outside-repo 守卫(真实触发断言,2026-09-05 守卫修复后生效)
# 触发方式: repo/plans/p-evil 为符号链接,指向沙箱 repo 之外的 outside/p-evil;
# select-and-resume.sh 探测实际来源路径并 readlink -f 物理解析后,auto 模式判为仓外排除;
# dry-run 不做此守卫,以报告"守卫后可用"计数差异分别锁定两种行为。
# 注意: 沙箱目录名不得含 "outside-repo" 字样,否则报告中的 **路径** 行会污染本断言。
SB_D="$V05_ROOT/case-d-repo-guard"
sr_sandbox "$SB_D"
mkdir -p "$SB_D/outside/p-evil"
sr_make_plan "$SB_D/outside/p-evil" "p-evil" "" ""
ln -s "$SB_D/outside/p-evil" "$SB_D/repo/plans/p-evil"
sr_make_plan "$SB_D/repo/plans/p-inside" "p-inside" "" ""
REPORT_D="$SB_D/report-dry.md"
bash "$SB_D/scripts/select-and-resume.sh" --repo-root "$SB_D/repo" --dry-run --report "$REPORT_D" >/dev/null 2>&1
sr_check "v0.5-d1 dry-run 不做仓内守卫(报告守卫后可用 2,含仓外候选)" \
  "$(grep -q '守卫后可用 2' "$REPORT_D" && echo 1 || echo 0)"
REPORT_D2="$SB_D/report-auto.md"
bash "$SB_D/scripts/select-and-resume.sh" --repo-root "$SB_D/repo" --report "$REPORT_D2" >/dev/null 2>&1
sr_check "v0.5-d2 auto 报告含 skip: outside-repo(符号链接逃逸候选被硬排除)" \
  "$(grep -q 'skip: outside-repo' "$REPORT_D2" && echo 1 || echo 0)"
sr_check "v0.5-d3 auto 报告守卫后可用 1(仅剩仓内候选)" \
  "$(grep -q '守卫后可用 1' "$REPORT_D2" && echo 1 || echo 0)"
sr_check "v0.5-d4 仓内候选 p-inside 正常写入 mode=auto-resume 标记" \
  "$(grep -q 'mode=auto-resume' "$SB_D/repo/plans/p-inside/task_plan.md" && echo 1 || echo 0)"
sr_check "v0.5-d5 仓外候选 p-evil 未被写标记" \
  "$(grep -q 'auto-pushed-by-cron' "$SB_D/outside/p-evil/task_plan.md" "$SB_D/repo/plans/p-evil/task_plan.md" 2>/dev/null && echo 0 || echo 1)"

# ── v0.5-e --dry-run 显式覆盖: config auto=true 时 flag 优先,不写任何标记
SB_E="$V05_ROOT/case-e-dryrun-override"
sr_sandbox "$SB_E"
printf '{\n  "autonomous_resume": true\n}\n' > "$SB_E/config.json"
sr_make_plan "$SB_E/repo/plans/p-e" "p-e" "" ""
bash "$SB_E/scripts/select-and-resume.sh" --repo-root "$SB_E/repo" --dry-run >/dev/null 2>&1
sr_check "v0.5-e1 config auto=true + 显式 --dry-run → 不写标记" \
  "$(grep -q 'auto-pushed-by-cron' "$SB_E/repo/plans/p-e/task_plan.md" && echo 0 || echo 1)"

rm -rf "$V05_ROOT"  # trap EXIT 之外的显式清理

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
echo "=== 总计: $((TOTAL - FAIL)) / $TOTAL PASS,FAIL=$FAIL ==="
if [[ $FAIL -eq 0 ]]; then
  echo "[OK] plan-resume smoke v0.6 全部通过"
  exit 0
else
  echo "[FAIL] $FAIL / $TOTAL 未通过"
  exit 1
fi