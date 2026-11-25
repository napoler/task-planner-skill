#!/usr/bin/env bash
# selftest-deploy-all-skills.sh — [2026-11-25 task-deploy-all-skills] smart-merge-back.sh --deploy F6 全量同步行为自测
# What: hermetic 端到端断言 — 最小 canonical git 仓 fixture + wt/<id> worktree, 临时 HOME 做部署位,
#   不注入 TASK_PLANNER_DEPLOY_SLOTS 直接跑 --deploy, 断言 task-planner 之外的 skill 与深层文件均落地,
#   并反向断言注入 slot 时 F6 被守卫跳过(不污染真实工具根)。
# Why: 原 --deploy 只发 task-planner 一个 skill, 其余 20 个完全不同步; maxdepth 2 又漏发
#   task-discipline/scripts/capabilities/agnes-quota.sh — 该回归钉子须由行为断言而非代码审阅守住。
# 夹具说明: default_deploy_slots() 是固定 5 路径(HOME/.zcode|.claude|.config/opencode|.cursor|.continue),
#   不注入 slot 时要让 F5 staging 全部成功, 5 个 slot 的父目录必须存在; 因此 5 个工具根都被
#   detect-tools.sh 探测到(全部位于临时 HOME 内, hermetic), 断言聚焦 .zcode 根即可。
#   (若仅建 .zcode, 另 4 个 slot 的 cp 会 ENOTDIR → staging exit 1, 根本走不到 F6。)
# 风格沿用 selftest-smart-merge.sh: bare origin + clone master + worktree add wt/*, trap EXIT 全量清理。
# 退出码: 0 = 全部断言 PASS; 1 = 任一 FAIL。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$SCRIPT_DIR/smart-merge-back.sh"
COMPANION_SRC="$SCRIPT_DIR/../lib/install-companion.sh"
DETECT_SRC="$SCRIPT_DIR/../lib/detect-tools.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PASS=0
FAIL=0
report() {   # <名称> <ok:0/1> <详情>
  if [ "$2" = 1 ]; then
    PASS=$((PASS+1)); printf 'PASS: %s %s\n' "$1" "$3"
  else
    FAIL=$((FAIL+1)); printf 'FAIL: %s %s\n' "$1" "$3"
  fi
}

# ---------- 夹具: 最小 canonical 仓(含被测脚本/companion/detect-tools 的真实副本) ----------
MAIN="$TMP/main"
WT="$TMP/deploy-all-test"   # 目录名须等于 task-id(否则 V1 双校验 PRECHECK_INVALID)
ORIGIN="$TMP/origin.git"
mkdir -p "$MAIN"

git -c core.hooksPath=/dev/null init --bare -q "$ORIGIN" 2>/dev/null
git -c core.hooksPath=/dev/null clone -q "$ORIGIN" "$MAIN" 2>/dev/null
git -C "$MAIN" config user.email selftest@local
git -C "$MAIN" config user.name selftest
git -C "$MAIN" config core.hooksPath /dev/null
git -C "$MAIN" config advice.detachedHead false
git -C "$MAIN" config advice.objectName false
echo c1 > "$MAIN/base.txt"

# canonical 布局: 仓根 CHANGELOG.md + skills/task-planner(companion/lib/scripts) + 两个外围 skill
mkdir -p "$MAIN/skills/task-planner/scripts" "$MAIN/skills/task-planner/lib" \
         "$MAIN/skills/task-planner/companion" \
         "$MAIN/skills/task-dispatch" "$MAIN/skills/task-discipline/scripts/capabilities"
echo "# fixture changelog" > "$MAIN/CHANGELOG.md"
echo "# task-planner" > "$MAIN/skills/task-planner/SKILL.md"
echo "fixture-canonical" > "$MAIN/skills/task-planner/SKILL_MARKER"
echo "# task-dispatch" > "$MAIN/skills/task-dispatch/SKILL.md"
echo "# task-discipline" > "$MAIN/skills/task-discipline/SKILL.md"
# 深层文件(相对 skill_dir 深度 3): maxdepth 2 漏发, maxdepth 5 必发
echo "#!/usr/bin/env bash" > "$MAIN/skills/task-discipline/scripts/capabilities/agnes-quota.sh"
cp "$TARGET" "$MAIN/skills/task-planner/scripts/smart-merge-back.sh"
cp "$COMPANION_SRC" "$MAIN/skills/task-planner/lib/install-companion.sh"
cp "$DETECT_SRC" "$MAIN/skills/task-planner/lib/detect-tools.sh"

git -C "$MAIN" add .
git -C "$MAIN" commit -qm fixture-canonical
git -C "$MAIN" checkout -qb master 2>/dev/null || true   # bare HEAD 已是 master 时该分支存在, 无需重建
git -C "$MAIN" push -q origin master 2>/dev/null
git -c core.hooksPath=/dev/null -C "$MAIN" worktree add -q "$WT" -b wt/deploy-all-test master 2>/dev/null
echo branch-change > "$WT/branch.txt"
git -C "$WT" add .
git -C "$WT" commit -qm branch-change

FIXTURE_SCRIPT="$MAIN/skills/task-planner/scripts/smart-merge-back.sh"

# ---------- 临时 HOME: 5 个默认 slot 父目录全建(F5 staging 成功前提), 全部 hermetic ----------
HOME_DIR="$TMP/home"
mkdir -p "$HOME_DIR/.zcode/skills/task-planner" \
         "$HOME_DIR/.claude/skills" \
         "$HOME_DIR/.config/opencode/skills" \
         "$HOME_DIR/.cursor/skills" \
         "$HOME_DIR/.continue/skills"
FAKE_SLOT="$TMP/fake-slot"
mkdir -p "$FAKE_SLOT"

# ---------- 正向: 不注入 TASK_PLANNER_DEPLOY_SLOTS, 走默认 slot + F6 ----------
LAST_RC=0
if LAST_OUT="$(cd / && env -u TASK_PLANNER_DEPLOY_SLOTS -u TASK_PLANNER_DEPLOY_ALL \
    HOME="$HOME_DIR" bash "$FIXTURE_SCRIPT" "$WT" --deploy 2>&1)"; then
  LAST_RC=0
else
  LAST_RC=$?
fi
# 失败时打印原始输出(诊断用; 断言仍逐条报 PASS/FAIL, 不静默吞错)
if [ "$LAST_RC" -ne 0 ]; then
  printf '[DEBUG] 正向运行输出(rc=%s):\n%s\n' "$LAST_RC" "$LAST_OUT"
fi

ok=0
if [ "$LAST_RC" -eq 0 ]; then ok=1; fi
report DA-01 "$ok" "退出码=$LAST_RC(期望0)"

ok=0
if grep -qF '[DEPLOY-ALL] OK: all skills synced' <<< "$LAST_OUT"; then ok=1; fi
report DA-02 "$ok" "输出含 [DEPLOY-ALL] OK=$( [ "$ok" = 1 ] && echo 是 || echo 否)"

ok=0
if [ -f "$HOME_DIR/.zcode/skills/task-planner/SKILL_MARKER" ] && \
   [ "$(cat "$HOME_DIR/.zcode/skills/task-planner/SKILL_MARKER")" = "fixture-canonical" ]; then ok=1; fi
report DA-03 "$ok" "默认 slot task-planner 有内容=$( [ "$ok" = 1 ] && echo 是 || echo 否)"

ok=0
if [ -f "$HOME_DIR/.zcode/skills/task-dispatch/SKILL.md" ] && \
   [ -f "$HOME_DIR/.zcode/skills/task-discipline/SKILL.md" ]; then ok=1; fi
report DA-04 "$ok" "至少2个其他 skill 的 SKILL.md 落地=$( [ "$ok" = 1 ] && echo 是 || echo 否)"

ok=0
if [ -f "$HOME_DIR/.zcode/skills/task-discipline/scripts/capabilities/agnes-quota.sh" ]; then ok=1; fi
report DA-05 "$ok" "深层 agnes-quota.sh 落地(maxdepth 修复)=$( [ "$ok" = 1 ] && echo 是 || echo 否)"

# ---------- 负向: 注入 slot → F6 守卫跳过, 输出无 [DEPLOY-ALL], 外围 skill 不落该 slot ----------
LAST_NEG_RC=0
if NEG_OUT="$(cd / && env -u TASK_PLANNER_DEPLOY_ALL \
    HOME="$HOME_DIR" TASK_PLANNER_DEPLOY_SLOTS="$FAKE_SLOT" \
    bash "$FIXTURE_SCRIPT" "$WT" --deploy 2>&1)"; then
  LAST_NEG_RC=0
else
  LAST_NEG_RC=$?
fi

ok=0
if [ "$LAST_NEG_RC" -eq 0 ] && ! grep -qF '[DEPLOY-ALL]' <<< "$NEG_OUT"; then ok=1; fi
report DA-06 "$ok" "注入 slot 时 rc=$LAST_NEG_RC(期望0) 且无 [DEPLOY-ALL]=$( [ "$ok" = 1 ] && echo 是 || echo 否)"

ok=0
if [ ! -e "$FAKE_SLOT/task-dispatch" ] && [ ! -e "$FAKE_SLOT/task-discipline" ]; then ok=1; fi
report DA-07 "$ok" "注入 slot 未被 companion 写入外围 skill=$( [ "$ok" = 1 ] && echo 是 || echo 否)"

printf 'TOTAL: %d PASS / %d FAIL\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
