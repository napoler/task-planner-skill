#!/usr/bin/env bash
# [2026-11-24 task-session-regression-20261124] selftest-compact-recovery.sh — 压缩恢复包全链回归
# What: 覆盖 lib/plan-recovery.sh 的 inflight/mustkeep/recover 与 zcode-sessionstart.sh 的
#       单行 JSON 注入契约：会话归属、无 TTL、终态豁免、必读绝对路径、必保字面、Git基线行、限幅落盘，
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
MISS=0
for f in user-session-log.md task_plan.md findings.md knowledge-brief.md .git-baseline-report.md; do
  printf '%s\n' "$CTX" | grep -qF "$R13/plans/aa/$f" || { MISS=$((MISS+1)); echo "[T13c-diag] missing path=$f"; }
done
[ "$MISS" -eq 0 ] && ok "T13c 5 条必读文件绝对路径齐全" || bad "T13c 必读绝对路径缺 $MISS 条"
# [2026-11-25 压缩后强制读取核心文件] 强制指令 + 核心/按需分级断言
printf '%s\n' "$CTX" | grep -qF '强制读取指令' && ok "T13c2 含压缩后强制读取指令" || bad "T13c2 强制读取指令缺失"
printf '%s\n' "$CTX" | grep -qF '核心·强制读取' && ok "T13c3 含核心强制读取分级" || bad "T13c3 核心强制分级缺失"
printf '%s\n' "$CTX" | grep -qF '按需·非强制' && ok "T13c4 含按需非强制分级" || bad "T13c4 按需分级缺失"
CORE=0
printf '%s\n' "$CTX" | grep -qF '【核心·强制读取】' || CORE=$((CORE+1))
for f in user-session-log.md task_plan.md findings.md; do
  printf '%s\n' "$CTX" | grep -qF "$f" || CORE=$((CORE+1))
done
[ "$CORE" -eq 0 ] && ok "T13c5 三核心文件(原话/计划/结论)标为强制" || bad "T13c5 核心文件缺 $CORE 条"
printf '%s\n' "$CTX" | grep -qF '数据库使用 PostgreSQL 15' && ok "T13d 必保项字面在注入内容中" || bad "T13d 必保项字面"
printf '%s\n' "$CTX" | grep -qF 'Git基线:' && ok "T13e 含 Git基线: 状态行" || bad "T13e Git基线行"
! printf '%s\n' "$CTX" | grep -qF '[task-resume]' && ! printf '%s\n' "$CTX" | grep -qF '初始化命令' \
  && ok "T13f 不含 [task-resume] / 初始化命令" || bad "T13f 旧开场白残留"

# 无在途：master 版 hook 现场生成金样（git archive，不依赖 /tmp 旧文件）
R13B="$(mkroot t13golden)"
printf 'not-me\n' > "$R13B/plans/.active_plan_side/othersid.active_plan"
printf '%s\n' '## 待处理' '- **task-x** | in_progress | 2026-11-24' > "$R13B/plans/INDEX.md"
mkdir -p "$T/golden"
git -C "$REPO" archive master skills/task-planner/scripts | tar -x -C "$T/golden"
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

TOTAL=$((PASS+FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
