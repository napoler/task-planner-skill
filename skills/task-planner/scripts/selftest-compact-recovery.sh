#!/usr/bin/env bash
# [2026-11-24 task-session-regression-20261124] selftest-compact-recovery.sh — 压缩恢复包全链回归
# What: 覆盖 lib/plan-recovery.sh 的 inflight/mustkeep/recover 与 zcode-sessionstart.sh 的
#       单行 JSON 注入契约：会话归属、无 TTL、终态豁免；恢复包=直接内联（任务核心状态取自权威源
#       plan-state.json 经 planctl recover + 技能正文 SKILL.md 全文），不再列文件路径；含必保字面、
#       Git基线行、限幅不吞技能正文、部署位薄壳形态，
#       以及「无在途计划时与 master 版 hook 逐字节一致」的零破坏对照。
# Why: 上下文压缩后正文规则失效，恢复包错注入他会话计划或漏掉必保项会直接导致既有设定被覆盖；
#       金样对照防止 hook 的无在途路径被顺手改动而无人察觉。
# 风格: set -u + mktemp 夹具 + t() 计数 + [PASS]/[FAIL] + Total；不依赖 Python。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="$SCRIPT_DIR/lib/plan-recovery.sh"
HOOK="$SCRIPT_DIR/zcode-sessionstart.sh"
GB="$SCRIPT_DIR/git-baseline.sh"
REPO="$(cd "$SCRIPT_DIR/../../.." && pwd)"  # <repo-root>: scripts → task-planner → skills → repo
T="$(mktemp -d /tmp/selftest-compact-recovery.XXXXXX)" || exit 2
trap 'rm -rf -- "$T"' EXIT
PASS=0; FAIL=0
OUT=""; RC=0
ok()  { PASS=$((PASS+1)); echo "[PASS] $1"; }
bad() { FAIL=$((FAIL+1)); echo "[FAIL] $1"; printf '%s\n' "$OUT" | sed 's/^/  | /'; }
run() { OUT="$("$@" 2>&1)"; RC=$?; }
t() { local name="$1"; shift; OUT="$("$@" 2>&1)"; RC=$?; [ "$RC" -eq 0 ] && ok "$name" || bad "$name (rc=$RC)"; }

mkroot() { # mkroot <name> → 回显项目根；根/plans/aa 为在途计划夹具
    local r="$T/$1"; mkdir -p "$r/plans/aa" "$r/plans/.active_plan_side"
    printf '# task plan\n### Phase 1: Alpha\n- **Status:** in_progress\n' > "$r/plans/aa/task_plan.md"
    for f in user-session-log.md findings.md knowledge-brief.md; do printf '%s fixture\n' "$f" > "$r/plans/aa/$f"; done
    cat > "$r/plans/aa/plan-state.json" <<'EOF'
{"goals":["限幅恢复夹具"],"phases":[{"name":"Phase 1: Alpha","status":"in_progress"}],"next_step":"继续 Phase 1","decisions":[{"id":"D1","decision":"保留 PostgreSQL 事实"}],"spec_baseline":[{"id":"MK1","verbatim":"数据库使用 PostgreSQL 15","rule":"target=facts.md|数据库使用 PostgreSQL 15|retain","anchor":"facts.md:2"},{"id":"MK-NA","verbatim":"无既有事实需保","rule":"target=n/a|none|retain","anchor":"-"}]}
EOF
    printf '%s' "$r"
}
point() { # point <root> <sidkey> <plan-id> — 写会话私有 side 指针
    printf '%s\n' "$3" > "$1/plans/.active_plan_side/$2.active_plan"
}
hook_run() { # hook_run <root> <sid> [hook-path] — stdin JSON → stdout 原始行
    local root="$1" sid="$2" hook="${3:-$HOOK}" out
    out="$(cd "$root" && printf '{"session_id":"%s"}' "$sid" | bash "$hook" 2>/dev/null)"
    printf '%s' "$out"
}

# ── T12 inflight：本会话指针 / 不看 TTL / 他会话 / 终态计划 ─────────────────
R12="$(mkroot t12)"
point "$R12" t12sid aa
run bash "$LIB" inflight "$R12" sess-t12sid
[ "$RC" -eq 0 ] && [ "$OUT" = "$R12/plans/aa" ] && ok "T12a 本会话 side 指针命中 → 在途" || bad "T12a 本会话在途 (rc=$RC out=$OUT)"
touch -d '3 days ago' "$R12/plans/.active_plan_side/t12sid.active_plan"
run bash "$LIB" inflight "$R12" sess-t12sid
[ "$RC" -eq 0 ] && [ "$OUT" = "$R12/plans/aa" ] && ok "T12b 指针 mtime 3 天前仍注入（不看 TTL）" || bad "T12b 陈旧指针 (rc=$RC out=$OUT)"
run bash "$LIB" inflight "$R12" other-session
[ "$RC" -eq 1 ] && [ -z "$OUT" ] && ok "T12c 他会话指针 → 不注入" || bad "T12c 他会话指针 (rc=$RC out=$OUT)"
printf 'complete plan\noutcome: COMPLETE\n' >> "$R12/plans/aa/task_plan.md"
run bash "$LIB" inflight "$R12" sess-t12sid
[ "$RC" -eq 1 ] && [ -z "$OUT" ] && ok "T12d 指针指向已 complete 计划 → 不注入" || bad "T12d 终态计划 (rc=$RC out=$OUT)"

# ── T13 hook 集成：单行 JSON + 恢复包内容 + 无在途时 master 金样逐字节一致 ──
R13="$(mkroot t13)"
point "$R13" recover123 aa
printf '%s\n' '## 待处理' '- **task-x** | in_progress | 2026-11-24' > "$R13/plans/INDEX.md"
H13="$(hook_run "$R13" sess-recover123)"
[ "$(printf '%s\n' "$H13" | wc -l)" -eq 1 ] && printf '%s\n' "$H13" | jq -e . >/dev/null 2>&1 \
  && ok "T13a stdout 单行且严格合法 JSON" || bad "T13a 单行 JSON"
CTX="$(printf '%s\n' "$H13" | jq -r '.additionalContext // ""' 2>/dev/null)"
printf '%s\n' "$CTX" | grep -qF '[compact-recovery]' && ok "T13b 含 [compact-recovery] 标记" || bad "T13b compact 标记"
# [2026-11-25 task-compact-recover-inline] 恢复包=直接内联内容：不再列派生视图路径叫模型自己 Read。
#   反证用夹具绝对路径（技能正文 SKILL.md 里本就可能出现同名文件的相对提法，不能拿裸文件名当反证）。
PATHLEAK=0
for f in user-session-log.md task_plan.md findings.md knowledge-brief.md .git-baseline-report.md; do
  printf '%s\n' "$CTX" | grep -qF "$R13/plans/aa/$f" && { PATHLEAK=$((PATHLEAK+1)); echo "[T13c-diag] leaked path=$f"; }
done
printf '%s\n' "$CTX" | grep -qF '强制读取指令' && PATHLEAK=$((PATHLEAK+1))
[ "$PATHLEAK" -eq 0 ] && ok "T13c 恢复包不再列派生视图路径/强制读取指令" || bad "T13c 仍在给路径（$PATHLEAK 处）"
SKILL_MD="$(cd "$SCRIPT_DIR/.." && pwd)/SKILL.md"
# 部署位的 SKILL.md 是宿主薄壳（只有 hook frontmatter + Canonical source 指针），注入的是 canonical
# 源仓技能正文。按薄壳的 Canonical source 行回溯，否则拿 43 行薄壳当正文比对会假 FAIL（部署位实测）。
if grep -qF 'Canonical source:' "$SKILL_MD" 2>/dev/null; then
  _canon="$(grep -m1 -F 'Canonical source:' "$SKILL_MD" | sed -n 's/.*TASK_PLANNER_ROOT:-\([^}]*\)}.*/\1/p')"
  if [ -n "$_canon" ] && [ -f "$_canon/SKILL.md" ]; then SKILL_MD="$_canon/SKILL.md"; fi
fi
# 结束标记须是末行（纪律提示行里本就含该字样，裸 grep 恒真——变异验证 M2 实证）
printf '%s\n' "$CTX" | grep -qF '【技能正文·开始】' && [ "$(printf '%s\n' "$CTX" | tail -n 1)" = '【技能正文·结束】' ] \
  && ok "T13c2 技能正文开始标记齐全且结束标记为末行" || bad "T13c2 技能正文标记缺失/结束标记非末行"
# 开始/结束标记之间的内容须与 SKILL.md 全文逐字节一致（sed -e '$a\' 统一末尾换行，消除无尾换行的 1 字节差）
printf '%s\n' "$CTX" | awk '/^【技能正文·开始】/{f=1;next} /^【技能正文·结束】/{f=0} f' > "$T/t13-skill-got.md"
diff <(sed -e '$a\' "$T/t13-skill-got.md") <(sed -e '$a\' "$SKILL_MD") > "$T/t13-skill.diff" 2>&1 \
  && ok "T13c3 hook 注入的技能正文与 SKILL.md 全文逐字节一致" \
  || bad "T13c3 技能正文与 SKILL.md 不一致 $(head -n 3 "$T/t13-skill.diff" | tr '\n' ' ')"
printf '%s\n' "$CTX" | grep -qF 'Phase 进度:' && printf '%s\n' "$CTX" | grep -qF '最近动作' \
  && ok "T13c4 hook 注入含 Phase 进度全貌与最近动作（RECOVER_FIELDS 已带新字段）" || bad "T13c4 进度全貌/最近动作未注入"
printf '%s\n' "$CTX" | grep -qF '数据库使用 PostgreSQL 15' && ok "T13d 必保项字面在注入内容中" || bad "T13d 必保项字面"
printf '%s\n' "$CTX" | grep -qF 'Git基线:' && ok "T13e 含 Git基线: 状态行" || bad "T13e Git基线行"
! printf '%s\n' "$CTX" | grep -qF '[task-resume]' && ! printf '%s\n' "$CTX" | grep -qF '初始化命令' \
  && ok "T13f 不含 [task-resume] / 初始化命令" || bad "T13f 旧开场白残留"

# 无在途：master 版 hook 现场生成金样（git archive，不依赖 /tmp 旧文件）
R13B="$(mkroot t13golden)"
printf 'not-me\n' > "$R13B/plans/.active_plan_side/othersid.active_plan"
printf '%s\n' '## 待处理' '- **task-x** | in_progress | 2026-11-24' > "$R13B/plans/INDEX.md"
mkdir -p "$T/golden"
# 部署位的 .git 是另一个历史仓（可能没有 master 分支），金样改从 canonical 源仓取（SKILL_MD 已回溯）
GOLD_REPO="$REPO"
if ! git -C "$GOLD_REPO" rev-parse --verify -q master >/dev/null 2>&1; then
  _canon_root="$(dirname "$(dirname "$(dirname "$SKILL_MD")")")"  # SKILL.md → task-planner → skills → repo
  if git -C "$_canon_root" rev-parse --verify -q master >/dev/null 2>&1; then GOLD_REPO="$_canon_root"; fi
fi
git -C "$GOLD_REPO" archive master skills/task-planner/scripts | tar -x -C "$T/golden"
GOLD_HOOK="$T/golden/skills/task-planner/scripts/zcode-sessionstart.sh"
if [ -f "$GOLD_HOOK" ]; then
  H_GOLD="$(hook_run "$R13B" sess-norecover "$GOLD_HOOK")"
  H_CUR="$(hook_run "$R13B" sess-norecover)"
  [ "$H_CUR" = "$H_GOLD" ] && ok "T13g 无在途时与 master 版 hook 金样逐字节一致" || bad "T13g master 金样对照"
else
  bad "T13g master 金样对照（git archive master 未生成 hook）"
fi

# ── T14 mustkeep：MK* 原始 TSV / MK-NA 在消费端跳过 / 无 plan-state.json ───
# 口径（2026-11-24 coordinator 裁决）：mustkeep 是 spec_baseline 的原始 TSV 输出面，MK-NA
#   （「无既有事实需保」占位说明）在恢复包里列出合理；真正跳过发生在消费端
#   git-baseline.sh mk_collect（sidecar.mustkeep.count 不计、diff 不报 LOST）。禁止因此改 lib。
R14="$(mkroot t14)"
run bash "$LIB" mustkeep "$R14/plans/aa"
N14="$(printf '%s\n' "$OUT" | grep -c '^MK' || true)"
NONMK14="$(printf '%s\n' "$OUT" | grep -c -v '^MK' || true)"
[ "$RC" -eq 0 ] && [ "$N14" -eq 2 ] && [ "$NONMK14" -eq 0 ] \
  && printf '%s\n' "$OUT" | grep -qF $'MK1\t数据库使用 PostgreSQL 15\tfacts.md\tfacts.md:2' \
  && printf '%s\n' "$OUT" | grep -qF $'MK-NA\t无既有事实需保\tn/a\t-' \
  && ok "T14a MK* 原始 TSV 过滤（MK-NA 作为占位列出，由消费端跳过）" || bad "T14a mustkeep 过滤 (rc=$RC out=$OUT)"
mkdir -p "$R14/skip/repo" "$R14/skip/plan"
git init -q "$R14/skip/repo"; git -C "$R14/skip/repo" config user.name selftest; git -C "$R14/skip/repo" config user.email selftest@localhost
printf 'facts\n' > "$R14/skip/repo/facts.md"; git -C "$R14/skip/repo" add -A; git -C "$R14/skip/repo" commit -qm init
cp -- "$R14/plans/aa/plan-state.json" "$R14/skip/plan/plan-state.json"
printf '# plan\n' > "$R14/skip/plan/task_plan.md"
run bash "$GB" snapshot "$R14/skip/plan" --repo "$R14/skip/repo"
[ "$RC" -eq 0 ] && [ "$(jq -r '.mustkeep.count' "$R14/skip/plan/.git-baseline.json")" -eq 1 ] \
  && ok "T14b MK-NA 在消费端 git-baseline.mk_collect 跳过（count=1）" || bad "T14b 消费端 MK-NA 跳过 (rc=$RC)"
mkdir -p "$R14/plans/no-state"
run bash "$LIB" mustkeep "$R14/plans/no-state"
[ "$RC" -eq 0 ] && [ -z "$OUT" ] && ok "T14c 无 plan-state.json → 空输出 rc=0" || bad "T14c 无状态文件 (rc=$RC out=$OUT)"

# ── T15 限幅：70 条 MK → ≤80 行 + 全文落盘 + Git基线行在截断点之前 ──────────
R15="$(mkroot t15)"
{
  printf '{"spec_baseline":['
  for i in $(seq 1 70); do
    [ "$i" -gt 1 ] && printf ','
    printf '{"id":"MK%03d","verbatim":"事实词%03d","rule":"target=facts.md|事实词%03d|retain","anchor":"facts.md:%d"}' "$i" "$i" "$i" "$i"
  done
  printf '],"decisions":['
  for i in $(seq 1 5); do
    [ "$i" -gt 1 ] && printf ','
    printf '{"id":"D%03d","decision":"决定%03d"}' "$i" "$i"
  done
  printf ']}'
} > "$R15/plans/aa/plan-state.json"
run bash "$LIB" recover "$R15/plans/aa" 80
L15="$(printf '%s\n' "$OUT" | wc -l)"
[ "$RC" -eq 0 ] && [ "$L15" -le 80 ] && printf '%s\n' "$OUT" | tail -n 1 | grep -qF '已截断（上限 80 行）' \
  && printf '%s\n' "$OUT" | tail -n 1 | grep -qF "$R15/plans/aa/.compact-recovery.md" \
  && ok "T15a 70 条 MK 默认 80 行限幅 + 末行提示全文路径" || bad "T15a 限幅 (rc=$RC lines=$L15)"
G15="$(printf '%s\n' "$OUT" | grep -n 'Git基线:' | head -1 | cut -d: -f1)"
[ -n "$G15" ] && [ "$G15" -lt 80 ] && ok "T15b Git基线: 行在截断点之前（line=$G15）" || bad "T15b Git基线行位置 line=${G15:-missing}"
[ -f "$R15/plans/aa/.compact-recovery.md" ] && grep -qF '事实词070' "$R15/plans/aa/.compact-recovery.md" \
  && ok "T15c .compact-recovery.md 落盘且含被截断内容" || bad "T15c 全文落盘"

# ── T16 planctl recover：核心数据获取能力收口到权威脚本 ─────────────────
# [2026-11-25 task-planctl-recover] What: 直接调 planctl.py recover 验证核心字段从权威源读出、
#   参数指定字段集、字段缺失不编造、SKILL.md 技能契约纳入重读面。
# Why: 旧方案核心数据获取散落在 lib/plan-recovery.sh 的 jq 拼接里且漏了 requirements 原话；
#   收口到 planctl 后升级只改一处，这里锁住该契约防止回退。
PLANCTL="$SCRIPT_DIR/planctl.py"
R16="$(mkroot t16)"
# mkroot 夹具补 requirements 用户原话 + MK 必保项（T16 专属，避免污染其它用例）
python3 - "$R16/plans/aa/plan-state.json" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p, encoding="utf-8"))
d["requirements"] = [{"id": "R1", "text": "常驻嘉宾必须是明星", "type": "目标", "vc": [], "tags": []}]
d["spec_baseline"] = [{"id": "MK1", "verbatim": "数据库使用 PostgreSQL 15",
                       "rule": "target=facts.md|数据库使用 PostgreSQL 15|retain", "anchor": "facts.md:2"}]
json.dump(d, open(p, "w", encoding="utf-8"), ensure_ascii=False)
PY
run python3 "$PLANCTL" recover --plan-dir "$R16/plans/aa"
[ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -qF '常驻嘉宾必须是明星' \
  && ok "T16a planctl recover 从权威源读出 requirements 用户原话" || bad "T16a requirements 原话缺失"
printf '%s\n' "$OUT" | grep -qF '数据库使用 PostgreSQL 15' && ok "T16b 必保项 MK 从权威源读出" || bad "T16b MK 必保项缺失"
printf '%s\n' "$OUT" | grep -qF 'Goal:' && printf '%s\n' "$OUT" | grep -qF 'Current Phase:' \
  && printf '%s\n' "$OUT" | grep -qF 'Git基线:' && ok "T16c 核心字段 Goal/Phase/Git基线齐全" || bad "T16c 核心字段缺失"
# [2026-11-25 task-compact-recover-inline] skill_contract=内联技能正文全文（references/config 由 SKILL.md 指针按需加载）
printf '%s\n' "$OUT" | grep -qF '【技能正文·开始】' && [ "$(printf '%s\n' "$OUT" | tail -n 1)" = '【技能正文·结束】' ] \
  && ! printf '%s\n' "$OUT" | grep -qF '强制读取指令' \
  && ok "T16d skill_contract 内联技能正文全文（结束标记为末行）且不列派生视图路径" || bad "T16d 技能契约范围不符"
# 参数指定：只传 requirements，输出不应含 Goal:/Git基线:
run python3 "$PLANCTL" recover --plan-dir "$R16/plans/aa" --fields requirements
[ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -qF '常驻嘉宾必须是明星' \
  && ! printf '%s\n' "$OUT" | grep -qF 'Git基线:' && ok "T16e --fields 参数指定生效（只出 requirements）" || bad "T16e --fields 参数未生效"
# 字段缺失不编造
R16E="$(mkroot t16empty)"
# 删除 goals/next_step 键，构造真正的"字段缺失"夹具（mkroot 默认夹具这两项有值）
python3 - "$R16E/plans/aa/plan-state.json" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p, encoding="utf-8"))
d.pop("goals", None)
d.pop("next_step", None)
json.dump(d, open(p, "w", encoding="utf-8"), ensure_ascii=False)
PY
run python3 "$PLANCTL" recover --plan-dir "$R16E/plans/aa" --fields goal,next_step
[ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -qF 'Goal: -' && ok "T16f 字段缺失写-不编造" || bad "T16f 缺失字段编造"
# hook 集成输出含 requirements 原话（证明 hook 真的走了 planctl）
R16H="$(mkroot t16hook)"
point "$R16H" recover16h aa
python3 - "$R16H/plans/aa/plan-state.json" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p, encoding="utf-8"))
d["requirements"] = [{"id": "R1", "text": "常驻嘉宾必须是明星", "type": "目标", "vc": [], "tags": []}]
json.dump(d, open(p, "w", encoding="utf-8"), ensure_ascii=False)
PY
H16="$(hook_run "$R16H" sess-recover16h)"
CTX16="$(printf '%s\n' "$H16" | jq -r '.additionalContext // ""' 2>/dev/null)"
printf '%s\n' "$CTX16" | grep -qF '常驻嘉宾必须是明星' \
  && ok "T16g hook 集成输出含 planctl 读出的 requirements 原话" || bad "T16g hook 未走 planctl 权威源"

# ── T17 内联契约：部署位薄壳形态 / 进度全貌+最近动作 / 限幅不吞技能正文 ──────────
# [2026-11-25 task-compact-recover-inline] What: 锁住「恢复包直接内联内容」在真实运行形态下的契约。
# Why: 实际运行的 hook 在部署位（~/.zcode/skills/...，由 cli/config.json 以绝对路径注册），其 SKILL.md 是
#   宿主薄壳（只含 hook frontmatter + Canonical source 指针），技能正文在 canonical 源仓——必须在部署形态下
#   验证，否则「源仓自测全绿、线上什么都没注入」（2026-11-25 实证：源仓三轮改动均因停留在未部署的旧脚本而从未生效）。
# T17a 部署形态：scripts/ 整体拷到假部署位 + 薄壳 SKILL.md → hook 仍走通 planctl recover 并内联 canonical 正文
DEPLOY="$T/deploy/skills/task-planner"
mkdir -p "$DEPLOY"
cp -r "$SCRIPT_DIR" "$DEPLOY/scripts"
{
  printf '%s\n' '---' 'name: task-planner' '---' '# task-planner — 宿主薄壳（夹具）'
  printf '> Canonical source: `${TASK_PLANNER_ROOT:-%s}`.\n' "$REPO/skills/task-planner"
  printf '%s\n' 'STUB-ONLY-MARKER 薄壳无技能正文'
} > "$DEPLOY/SKILL.md"
R17A="$(mkroot t17a)"
point "$R17A" deploy17a aa
CTX17A="$(hook_run "$R17A" sess-deploy17a "$DEPLOY/scripts/zcode-sessionstart.sh" | jq -r '.additionalContext // ""' 2>/dev/null)"
printf '%s\n' "$CTX17A" | grep -qF '[compact-recovery]' && [ "$(printf '%s\n' "$CTX17A" | tail -n 1)" = '【技能正文·结束】' ] \
  && ok "T17a 部署位形态 hook 走通 planctl recover 并内联技能正文" || bad "T17a 部署位形态链路不通"
FEATURE17="$(grep -m1 -F '四文件罗盘的唯一管理域' "$SKILL_MD")"
printf '%s\n' "$CTX17A" | grep -qF -- "$FEATURE17" && ! printf '%s\n' "$CTX17A" | grep -qF 'STUB-ONLY-MARKER' \
  && ok "T17b 薄壳 SKILL.md 回溯 canonical 正文（注入源仓全文，不注入薄壳内容）" || bad "T17b 薄壳未回溯 canonical"
printf '%s\n' "$CTX17A" | grep -qF "$REPO/skills/task-planner/SKILL.md" \
  && ok "T17c 注入的技能正文路径指向 canonical 源仓" || bad "T17c 技能正文路径非 canonical"
# T17d 进度全貌 + 最近动作（planctl 直调）：✓/▶/○ 三态 + 按 at 取尾部、无 at 排最前
R17D="$(mkroot t17d)"
python3 - "$R17D/plans/aa/plan-state.json" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p, encoding="utf-8"))
d["phases"] = [{"id": "P1", "name": "取证", "status": "complete"},
               {"id": "P2", "name": "实现", "status": "in_progress"},
               {"id": "P3", "name": "收口", "status": "pending"}]
# 11 条（A0 无时间 + A1..A10 按日递增），输入顺序故意打乱：验证按 at 排序而非按输入顺序
_acts = [{"id": "A0", "text": "无时间动作"}] + [
    {"id": "A%d" % i, "text": "动作%02d" % i, "at": "2026-01-%02dT00:00:00Z" % i} for i in range(1, 11)]
_acts = [_acts[k] for k in (5, 0, 9, 1, 7, 3, 10, 2, 8, 4, 6)]
d["actions"] = _acts
json.dump(d, open(p, "w", encoding="utf-8"), ensure_ascii=False)
PY
run python3 "$PLANCTL" recover --plan-dir "$R17D/plans/aa" --fields phase,recent_actions
[ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -qF 'P1✓ P2▶ P3○' \
  && ok "T17d Phase 进度全貌三态标记" || bad "T17d 进度全貌缺失 (rc=$RC)"
printf '%s\n' "$OUT" | grep -qF 'Current Phase: 实现' && ok "T17e Current Phase 取 in_progress" || bad "T17e Current Phase 错误"
# 强断言：顺序（按 at 升序）+ 条数（恰 8 条）+ 截尾（最早的 A0/A1/A2 不得出现）
A_LINES="$(printf '%s\n' "$OUT" | grep '^\[A[0-9]* ' | sed 's/^\[\(A[0-9]*\) .*/\1/' | tr '\n' ' ')"
[ "$A_LINES" = "A3 A4 A5 A6 A7 A8 A9 A10 " ] \
  && ok "T17f 最近动作按时间升序取尾部 8 条（A3..A10，最早的被截掉）" || bad "T17f 最近动作顺序/条数不符: [$A_LINES]"
# T17g 限幅只截任务状态块：复用 T15 的 70 条 MK 夹具 + 上限 20 行 → 技能正文仍完整
run python3 "$PLANCTL" recover --plan-dir "$R15/plans/aa" --fields mustkeep,skill_contract --max-lines 20
L17G="$(printf '%s\n' "$OUT" | wc -l)"
[ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -qF '任务状态已截断（上限 20 行）' \
  && printf '%s\n' "$OUT" | tail -n 1 | grep -qF '【技能正文·结束】' \
  && [ "$L17G" -gt "$(wc -l < "$SKILL_MD")" ] \
  && ok "T17g 限幅只截任务状态块，技能正文完整保留（总 $L17G 行）" || bad "T17g 限幅吞了技能正文 (rc=$RC lines=$L17G)"

TOTAL=$((PASS+FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
