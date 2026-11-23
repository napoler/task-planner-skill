#!/usr/bin/env bash
# [2026-11-24 task-session-regression-20261124] selftest-git-baseline.sh — B9/B10/B11 机器面实弹回归
# What: 对 git-baseline.sh 的 snapshot/diff/dispose/restore/worktree/scope/numstat/attest 契约，
#       以及 check-3file-gate.sh / check-complete.sh 两处门接线，做真实 git 仓夹具 + 真实子进程断言。
#       T11/T12（2026-11-24 P1）：授权锚只认 snapshot 时快照、自补 D/原话无效；retained 必须含
#       被删原文；mustkeep_lost>0 即使处置齐全也 FAIL（原 T4e 口径随此规则调整）。
# Why: 新机制若只剩文档条款或静态 grep，删除必保事实仍可在验收全绿下溜过；本套件复演事故并
#       反向证明门会阻断、处置校验不可伪造、还原与基线证据链可逐字节回验。
# 风格: set -u（不用 -e，逐条控制 rc）+ mktemp 夹具 + t() 计数 + [PASS]/[FAIL] + Total 汇总；
#       不依赖 Python；所有仓库/索引/HEAD 指纹只取夹具路径，绝不触真实仓。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GB="$SCRIPT_DIR/git-baseline.sh"
G3="$SCRIPT_DIR/check-3file-gate.sh"
CC="$SCRIPT_DIR/check-complete.sh"
T="$(mktemp -d /tmp/selftest-git-baseline.XXXXXX)" || exit 2
trap 'rm -rf -- "$T"' EXIT
PASS=0; FAIL=0
OUT=""; RC=0

ok()  { PASS=$((PASS+1)); echo "[PASS] $1"; }
bad() { FAIL=$((FAIL+1)); echo "[FAIL] $1"; printf '%s\n' "$OUT" | sed 's/^/  | /'; }
t() { # t <name> <cmd...> — 命令 rc=0 计 PASS
    local name="$1"; shift
    OUT="$("$@" 2>&1)"; RC=$?
    [ "$RC" -eq 0 ] && ok "$name" || bad "$name (rc=$RC)"
}
run() { OUT="$("$@" 2>&1)"; RC=$?; }

mkcase() { # mkcase <name> → 回显 "<case-dir>"；夹具仓含 2 条 MK 必保事实 + 1 普通文件
    local c="$T/$1"
    mkdir -p "$c/repo" "$c/plan"
    git init -q "$c/repo"
    git -C "$c/repo" config user.name selftest
    git -C "$c/repo" config user.email selftest@localhost
    printf '# facts\n数据库使用 PostgreSQL 15\n缓存使用 Redis\n' > "$c/repo/facts.md"
    printf 'keep line\n' > "$c/repo/keep.txt"
    git -C "$c/repo" add -A
    git -C "$c/repo" commit -qm init
    cat > "$c/plan/plan-state.json" <<'EOF'
{"spec_baseline":[{"id":"MK1","verbatim":"数据库使用 PostgreSQL 15","rule":"target=facts.md|数据库使用 PostgreSQL 15|retain","anchor":"facts.md:2"},{"id":"MK2","verbatim":"缓存使用 Redis","rule":"target=facts.md|缓存使用 Redis|retain","anchor":"facts.md:3"},{"id":"MK-NA","verbatim":"无既有事实需保","rule":"target=n/a|none|retain","anchor":"-"}],"decisions":[{"id":"D1","decision":"授权删除 MK1 的事实：数据库使用 PostgreSQL 15","rationale":"用户逐字授权"}],"config":{"scope_files":["facts.md","keep.txt"]}}
EOF
    printf '# task plan\nplan_tier: mini\n' > "$c/plan/task_plan.md"
    # P1 修复后 authorized 只认 snapshot 时的授权锚：夹具必须在 snapshot 前备好 `> 引用行`，
    # 否则锚内 userlog 为空，合法授权断言会被误判为 REJECT（口径随新规则调整）。
    printf '> 确实允许删除 MK1\n' > "$c/plan/user-session-log.md"
    printf '%s' "$c"
}
base_sha() { jq -r '.baseline_sha // ""' "$1/plan/.git-baseline.json" 2>/dev/null; }
report() { printf '%s' "$1/plan/.git-baseline-report.md"; }
fingerprint() { # 真实索引 + HEAD + status 的 sha256 串联（snapshot/restore 非侵入判据）
    # 索引取 `git ls-files --stage` 的 sha256 而非索引文件字节：git status / git restore 会刷新
    # stat 缓存重写索引文件字节，但 staged 内容不变；契约要求的是索引语义不变（无意外 staged 改动）。
    local repo="$1"
    git -C "$repo" ls-files --stage | sha256sum | cut -d' ' -f1
    sha256sum "$repo/.git/HEAD" | cut -d' ' -f1
    git -C "$repo" status --porcelain=v1 | sha256sum | cut -d' ' -f1
}
del_line() { # del_line <file> <literal> — 删掉含字面的一行（awk 保序）
    local f="$1" lit="$2" tmp="${1}.tmp"
    awk -v lit="$lit" 'index($0, lit) == 0' "$f" > "$tmp" && mv -- "$tmp" "$f"
}

# ── T1 snapshot 非侵入 / 未跟踪文件入树 / 幂等 ─────────────────────────────
C1="$(mkcase t1)"
printf 'untracked baseline content\n' > "$C1/repo/untracked.txt"
F1_BEFORE="$(fingerprint "$C1/repo")"
run bash "$GB" snapshot "$C1/plan" --repo "$C1/repo"
if [ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -q 'BASELINE refs/task-baseline/plan'; then ok "T1a snapshot 建基线"; else bad "T1a snapshot 建基线 (rc=$RC)"; fi
F1_AFTER="$(fingerprint "$C1/repo")"
[ "$F1_BEFORE" = "$F1_AFTER" ] && ok "T1b 真实索引/HEAD/status sha256 前后一致" || bad "T1b 真实索引/HEAD/status sha256 前后一致"
S1="$(base_sha "$C1")"
git -C "$C1/repo" ls-tree -r --name-only "$S1" | grep -qxF 'untracked.txt' && ok "T1c 未跟踪文件入基线树" || bad "T1c 未跟踪文件入基线树"
run bash "$GB" snapshot "$C1/plan" --repo "$C1/repo"
[ "$RC" -eq 0 ] && [ "$(base_sha "$C1")" = "$S1" ] && printf '%s\n' "$OUT" | grep -q 'idempotent' \
  && ok "T1d 重复 snapshot 幂等（同一 baseline_sha + idempotent）" || bad "T1d 重复 snapshot 幂等 (rc=$RC)"
[ "$(jq -r '.mustkeep.count' "$C1/plan/.git-baseline.json")" -eq 2 ] \
  && ok "T1e MK-NA 占位项在消费端 mk_collect 跳过（MK1+MK2=2）" || bad "T1e 消费端 MK-NA 跳过"

# ── T2 事故复演：删除必保事实 → D + MK LOST + 报告含被删行 ──────────────────
C2="$(mkcase t2)"
run bash "$GB" snapshot "$C2/plan" --repo "$C2/repo"
rm -f -- "$C2/repo/facts.md"
run bash "$GB" diff "$C2/plan" --final --repo "$C2/repo"
[ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q 'MK1 LOST' && grep -qF '| facts.md | D |' "$(report "$C2")" \
  && grep -qF -- '-数据库使用 PostgreSQL 15' "$(report "$C2")" \
  && ok "T2a 整文件删除 → rc=1 + MK1 LOST + 报告 D 行 + 被删行" || bad "T2a 整文件删除事故复演 (rc=$RC)"
C2B="$(mkcase t2b)"
run bash "$GB" snapshot "$C2B/plan" --repo "$C2B/repo"
del_line "$C2B/repo/facts.md" '数据库使用 PostgreSQL 15'
run bash "$GB" diff "$C2B/plan" --final --repo "$C2B/repo"
[ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q 'MK1 LOST' && grep -qF '| facts.md | M |' "$(report "$C2B")" \
  && grep -qF -- '-数据库使用 PostgreSQL 15' "$(report "$C2B")" \
  && ok "T2b 删单行必保事实 → rc=1 + MK1 LOST + 报告 M 行 + 被删行" || bad "T2b 删单行事故复演 (rc=$RC)"

# ── T3/T4 处置校验（虚假 retained / 虚假 authorized / 合法 authorized）─────
C3="$(mkcase t3)"
run bash "$GB" snapshot "$C3/plan" --repo "$C3/repo"
del_line "$C3/repo/facts.md" '数据库使用 PostgreSQL 15'
run bash "$GB" diff "$C3/plan" --final --repo "$C3/repo"   # 固化 mustkeep_lost 到 sidecar.last_diff
run bash "$GB" dispose "$C3/plan" --file facts.md --state retained --evidence '当前文件里没有的伪造片段' --repo "$C3/repo"
[ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q 'DISPOSE REJECT' && ok "T3a retained 假片段 → rc=1 REJECT" || bad "T3a retained 假片段 (rc=$RC)"
run bash "$GB" dispose "$C3/plan" --file facts.md --state retained --evidence '缓存使用 Redis' --repo "$C3/repo"
[ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q 'DISPOSE REJECT' && ok "T3b MK 原文被删时其它片段不能代偿 → REJECT" || bad "T3b retained 代偿片段 (rc=$RC)"
printf '可以删掉旧数据库那句（此行非 > 引用）\n> 确实允许删除 MK1\n' > "$C3/plan/user-session-log.md"
run bash "$GB" dispose "$C3/plan" --file facts.md --state authorized --evidence 'decisions:D999|用户原话:确实允许删除 MK1' --repo "$C3/repo"
[ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q 'DISPOSE REJECT' && ok "T4a 无关 D 编号 → REJECT" || bad "T4a 无关 D 编号 (rc=$RC)"
run bash "$GB" dispose "$C3/plan" --file facts.md --state authorized --evidence 'decisions:D1|用户原话:可以删掉旧数据库那句' --repo "$C3/repo"
[ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q 'DISPOSE REJECT' && ok "T4b 原话不在 > 引用行 → REJECT" || bad "T4b 非引用行原话 (rc=$RC)"
jq '.decisions += [{"id":"D2","decision":"同意","rationale":"无"}]' "$C3/plan/plan-state.json" > "$C3/plan/ps.tmp" && mv -- "$C3/plan/ps.tmp" "$C3/plan/plan-state.json"
run bash "$GB" dispose "$C3/plan" --file facts.md --state authorized --evidence 'decisions:D2|用户原话:确实允许删除 MK1' --repo "$C3/repo"
[ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q 'DISPOSE REJECT' && ok "T4c 决定未点名 MK 编号/原文 → REJECT" || bad "T4c 决定未点名 MK (rc=$RC)"
run bash "$GB" dispose "$C3/plan" --file facts.md --state authorized --evidence 'decisions:D1|用户原话:确实允许删除 MK1' --repo "$C3/repo"
[ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -q 'DISPOSE OK' && ok "T4d D 号+引用原话+MK 点名三齐全 → OK" || bad "T4d 合法授权 (rc=$RC)"
run bash "$GB" diff "$C3/plan" --final --repo "$C3/repo"
# P1 口径调整：授权只表示「有批准」；必保事实仍缺失，必须 FAIL（unresolved=0 && mustkeep_lost=1）。
[ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q 'FAIL unresolved=0 mustkeep_lost=1' \
  && grep -qF -- '- facts.md | authorized | decisions:D1|用户原话:确实允许删除 MK1' "$(report "$C3")" \
  && ok "T4e 报告可见授权；mustkeep_lost>0 即使 unresolved=0 仍 rc=1 FAIL" || bad "T4e 授权后仍 FAIL (rc=$RC)"

# ── T5 两门接线：无侧车 / 未处置阻断；warn 不阻断；off SKIP ─────────────────
C5="$(mkcase t5)"
cat > "$C5/plan/task_plan.md" <<'EOF'
plan_tier: mini
# task plan
## Goal
fixture goal
### Phase 1: Alpha
- **Status:** in_progress
EOF
printf '## Phase 1:\n- **Started:** %s\n' "$(date -d '2 minutes ago' '+%Y-%m-%d %H:%M')" > "$C5/plan/progress.md"
printf 'finding line\n' > "$C5/plan/findings.md"
run bash "$G3" "$C5/plan"
[ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q 'B9' && printf '%s\n' "$OUT" | grep -q 'git-baseline.sh snapshot' \
  && ok "T5a 3file 门无侧车 → rc=1 且输出含 B9 snapshot 命令" || bad "T5a 3file 门无侧车 (rc=$RC)"
run bash "$GB" snapshot "$C5/plan" --repo "$C5/repo"
del_line "$C5/repo/facts.md" '数据库使用 PostgreSQL 15'
run bash "$GB" diff "$C5/plan" --final --repo "$C5/repo"
run bash "$G3" "$C5/plan"
[ "$RC" -eq 1 ] && ok "T5b 3file 门有未处置 rc=1 → 门 exit 1" || bad "T5b 3file 门未处置 (rc=$RC)"
run env TASK_PLANNER_GIT_BASELINE_ENFORCE=warn bash "$G3" "$C5/plan"
[ "$RC" -eq 0 ] && ok "T5c 3file 门 warn 档不阻断" || bad "T5c 3file 门 warn 档 (rc=$RC)"
run env TASK_PLANNER_GIT_BASELINE_ENFORCE=off bash "$G3" "$C5/plan"
G3_OFF_RC=$RC; G3_OFF_OUT="$OUT"
# 门在 rc=0 时不透传 git-baseline stdout（门自身 rc=0 即不阻断），故 SKIP off 字面直取机器面验证
run env TASK_PLANNER_GIT_BASELINE_ENFORCE=off bash "$GB" diff "$C5/plan" --final --repo "$C5/repo"
[ "$G3_OFF_RC" -eq 0 ] && printf '%s\n' "$G3_OFF_OUT" | grep -q 'PASS — findings.md' \
  && [ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -q 'SKIP off' \
  && ok "T5d 3file 门 off 档不阻断 + 机器面 SKIP off" || bad "T5d 3file 门 off 档 (gate_rc=$G3_OFF_RC gb_rc=$RC)"

C5C="$(mkcase t5cc)"
mkdir -p "$C5C/plan/subagent-state"
cat > "$C5C/plan/task_plan.md" <<'EOF'
# task_plan
## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 标准1 | cmd | path |
### Phase 1: Alpha
- **Status:** complete
- **Executor:** explore（mini）
| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
|----|------|--------|------|------|---------|------|
| S1 | 勘察 | explore | e1/task_plan.md | PASS | 5min | complete |
## 🔗 Subagent Handoff 登记表
| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | checkpoint 路径 | rescue |
|---|------|--------------|---------|------|---------|------|----------------|--------|
| 1 | 2026-10-15 | explore | 勘察 | done | ok | ok.md:1 | 01-explore.md | - |
EOF
printf 'x\ny\nz\nw\n' > "$C5C/plan/findings.md"
printf 'a\nb\nc\nd\n' > "$C5C/plan/progress.md"
: > "$C5C/plan/subagent-state/01-explore.md"
run env TASK_PLANNER_SESSION_LOG_ENFORCE=warn bash "$CC" "$C5C/plan/task_plan.md"
[ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q 'B9' && ok "T5e check-complete 无侧车 → rc=1 + B9 提示" || bad "T5e check-complete 无侧车 (rc=$RC)"
run bash "$GB" snapshot "$C5C/plan" --repo "$C5C/repo"
del_line "$C5C/repo/facts.md" '数据库使用 PostgreSQL 15'
run bash "$GB" diff "$C5C/plan" --final --repo "$C5C/repo"
# 先确认夹具本体会过全门链（关掉 GIT 门 rc=0），避免把其它门失败误算到 GIT 门上
run env TASK_PLANNER_SESSION_LOG_ENFORCE=warn TASK_PLANNER_GIT_BASELINE_ENFORCE=off bash "$CC" "$C5C/plan/task_plan.md"
[ "$RC" -eq 0 ] && ok "T5f check-complete 夹具本体门链通过（GIT 门 off 对照）" || bad "T5f check-complete 夹具本体 (rc=$RC)"
run env TASK_PLANNER_SESSION_LOG_ENFORCE=warn bash "$CC" "$C5C/plan/task_plan.md"
[ "$RC" -eq 1 ] && ok "T5g check-complete 有未处置 rc=1 → 终验 exit 1" || bad "T5g check-complete 未处置 (rc=$RC)"
run env TASK_PLANNER_SESSION_LOG_ENFORCE=warn TASK_PLANNER_GIT_BASELINE_ENFORCE=warn bash "$CC" "$C5C/plan/task_plan.md"
[ "$RC" -eq 0 ] && ok "T5h check-complete warn 档不阻断" || bad "T5h check-complete warn 档 (rc=$RC)"
run env TASK_PLANNER_SESSION_LOG_ENFORCE=warn TASK_PLANNER_GIT_BASELINE_ENFORCE=off bash "$CC" "$C5C/plan/task_plan.md"
[ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -q 'SKIP off' && ok "T5i check-complete off 档 SKIP" || bad "T5i check-complete off 档 (rc=$RC)"

# ── T6 restore：逐字节还原 / 真索引与 HEAD 不变 / 自动 pre-restore 检查点 ────
C6="$(mkcase t6)"
run bash "$GB" snapshot "$C6/plan" --repo "$C6/repo"
S6="$(base_sha "$C6")"
F6_BEFORE="$(fingerprint "$C6/repo")"
del_line "$C6/repo/facts.md" '数据库使用 PostgreSQL 15'
run bash "$GB" restore "$C6/plan" --file facts.md --repo "$C6/repo"
[ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -q 'RESTORE OK' && ok "T6a restore --file rc=0" || bad "T6a restore --file (rc=$RC)"
git -C "$C6/repo" show "${S6}:facts.md" > "$C6/expected"
cmp -s "$C6/expected" "$C6/repo/facts.md" && ok "T6b 与基线 blob 逐字节 cmp 一致" || bad "T6b 与基线 blob 逐字节 cmp 一致"
F6_AFTER="$(fingerprint "$C6/repo")"
[ "$F6_BEFORE" = "$F6_AFTER" ] && ok "T6c 真实索引/HEAD/status 不变" || bad "T6c 真实索引/HEAD/status 不变 before=$(printf '%s' "$F6_BEFORE" | tr '\n' ',') after=$(printf '%s' "$F6_AFTER" | tr '\n' ',')"
[ "$(jq -r '.checkpoints|length' "$C6/plan/.git-baseline.json")" -eq 1 ] \
  && jq -r '.checkpoints[0].ref' "$C6/plan/.git-baseline.json" | grep -q 'pre-restore' \
  && ok "T6d 自动生成 pre-restore checkpoint" || bad "T6d 自动生成 pre-restore checkpoint"
run bash "$GB" diff "$C6/plan" --final --repo "$C6/repo"
[ "$RC" -eq 0 ] && ok "T6e 还原后 diff rc=0（该文件不再 unresolved）" || bad "T6e 还原后 diff (rc=$RC)"

# ── T7 worktree 模式：计划声明 worktree_path，侧车锚定 worktree ─────────────
C7="$T/t7"; mkdir -p "$C7/main" "$C7/plan"
git init -q "$C7/main"; git -C "$C7/main" config user.name selftest; git -C "$C7/main" config user.email selftest@localhost
printf '# facts\n数据库使用 PostgreSQL 15\n' > "$C7/main/facts.md"
git -C "$C7/main" add -A; git -C "$C7/main" commit -qm init
git -C "$C7/main" worktree add -q -b wt-probe "$C7/wt"
cat > "$C7/plan/plan-state.json" <<EOF
{"spec_baseline":[{"id":"MK1","verbatim":"数据库使用 PostgreSQL 15","rule":"target=facts.md|数据库使用 PostgreSQL 15|retain","anchor":"facts.md:2"}],"config":{"worktree_path":"$C7/wt","scope_files":["facts.md"]}}
EOF
printf '# task plan\n' > "$C7/plan/task_plan.md"
run bash -c "cd '$C7/main' && bash '$GB' snapshot '$C7/plan'"
[ "$RC" -eq 0 ] && [ "$(jq -r '.repo_root' "$C7/plan/.git-baseline.json")" = "$C7/wt" ] \
  && [ "$(jq -r '.mode' "$C7/plan/.git-baseline.json")" = worktree ] \
  && ok "T7a 主仓 CWD snapshot → sidecar.repo_root=worktree/mode=worktree" || bad "T7a worktree snapshot (rc=$RC)"
cp -- "$C7/wt/facts.md" "$C7/saved"
rm -f -- "$C7/wt/facts.md"
run bash -c "cd '$C7/main' && bash '$GB' diff '$C7/plan' --final"
[ "$RC" -eq 1 ] && grep -qF '| facts.md | D |' "$(report "$C7")" \
  && ok "T7b worktree 删文件 → diff 报 D + rc=1" || bad "T7b worktree diff (rc=$RC)"
cmp -s "$C7/saved" "$C7/main/facts.md" && ok "T7c 主仓工作树未被改动" || bad "T7c 主仓工作树未被改动"

# ── T8 scope_files 越界判定 ────────────────────────────────────────────────
C8="$(mkcase t8)"
run bash "$GB" snapshot "$C8/plan" --repo "$C8/repo"
printf 'outside scope\n' > "$C8/repo/outside.txt"
run bash "$GB" diff "$C8/plan" --final --repo "$C8/repo"
awk '/^## 越界文件/{f=1;next} /^## /{f=0} f' "$(report "$C8")" | grep -qxF -- '- outside.txt' \
  && [ "$RC" -eq 1 ] && ok "T8 scope 外新文件进入「越界文件」节且 unresolved>0" || bad "T8 越界判定 (rc=$RC)"

# ── T9 报告 +/- 列与 git diff --numstat 逐行一致（M / R / 二进制）───────────
C9="$(mkcase t9)"
printf '\000\001binary-old\n' > "$C9/repo/blob.bin"
run bash "$GB" snapshot "$C9/plan" --repo "$C9/repo"
printf 'extra line\n' >> "$C9/repo/facts.md"
git -C "$C9/repo" mv keep.txt renamed.txt
printf '\002\003binary-new\n' > "$C9/repo/blob.bin"
run bash "$GB" diff "$C9/plan" --final --repo "$C9/repo"
R9="$(report "$C9")"
T9_FROM="$(grep -oE '起点\(tree\): [0-9a-f]+' "$R9" | awk '{print $2}')"
T9_TO="$(grep -oE '当前\(tree\): [0-9a-f]+' "$R9" | awk '{print $2}')"
N9=0; BAD9=0
while IFS=$'\t' read -r a d p; do
    [ -n "$p" ] || continue
    case "$p" in *'=> '*) p="${p##*=> }" ;; esac
    if [ "$a" = "-" ] || [ "$d" = "-" ]; then exp='-/-'; else exp="+$a/-$d"; fi
    N9=$((N9+1))
    if grep -qF "| $p | " "$R9" && grep -qF "| $exp |" "$R9"; then :; else BAD9=$((BAD9+1)); echo "[T9-diag] path=$p expected=$exp"; fi
done < <(git -C "$C9/repo" diff --numstat -M "$T9_FROM" "$T9_TO")
[ "$N9" -eq 3 ] && [ "$BAD9" -eq 0 ] && grep -qF '| -/- |' "$R9" && grep -qF '| R |' "$R9" \
  && ok "T9 报告 3 行（普通 M / R / 二进制 -/-）与 numstat 逐行一致" || bad "T9 报告 +/- 列 (rows=$N9 bad=$BAD9)"

# ── T10 attest 联动：哈希一致放行 / 篡改阻断 / 无锁 WARN ───────────────────
C10="$(mkcase t10)"
run bash "$GB" snapshot "$C10/plan" --repo "$C10/repo"
H10="$(sha256sum "$C10/plan/task_plan.md" | cut -d' ' -f1)"
printf 'plan_sha256=%s\n' "$H10" > "$C10/plan/.plan-attestation"
run bash "$GB" diff "$C10/plan" --final --repo "$C10/repo"
[ "$RC" -eq 0 ] && ok "T10a attest 哈希一致 → diff 正常 rc=0" || bad "T10a attest 一致 (rc=$RC)"
printf '\n# tampered\n' >> "$C10/plan/task_plan.md"
run bash "$GB" diff "$C10/plan" --final --repo "$C10/repo"
[ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q 'PLAN TAMPERED' && ok "T10b 计划被改一字 → rc=1 PLAN TAMPERED" || bad "T10b 计划篡改 (rc=$RC)"
rm -f -- "$C10/plan/.plan-attestation"
run bash "$GB" diff "$C10/plan" --final --repo "$C10/repo"
[ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -q 'PLAN-NOT-ATTESTED' && ok "T10c 无锁文件 → WARN 不阻断" || bad "T10c 无锁 WARN (rc=$RC)"

# ── T11 P1 防自补授权：锚后新增 D/原话无效，anchor-auth 才生效 ────────────────
C11="$(mkcase t11)"
run bash "$GB" snapshot "$C11/plan" --repo "$C11/repo"
del_line "$C11/repo/facts.md" '数据库使用 PostgreSQL 15'
run bash "$GB" diff "$C11/plan" --final --repo "$C11/repo"
jq '.decisions += [{"id":"D9","decision":"同意删除 MK1","rationale":"用户授权"}]' \
  "$C11/plan/plan-state.json" > "$C11/ps.tmp" && mv -- "$C11/ps.tmp" "$C11/plan/plan-state.json"
printf '> 同意删除 MK1\n' > "$C11/plan/user-session-log.md"
run bash "$GB" dispose "$C11/plan" --file facts.md --state authorized \
  --evidence 'decisions:D9|用户原话:同意删除 MK1' --repo "$C11/repo"
[ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q '锚内 decisions 查无精确 D 编号 D9' \
  && ok "T11a 锚后自补 D9+原话 → authorized REJECT" || bad "T11a 自补授权 (rc=$RC)"
B11="$(base_sha "$C11")"; N11="$(jq -r '.checkpoints|length' "$C11/plan/.git-baseline.json")"
run bash "$GB" anchor-auth "$C11/plan" --repo "$C11/repo"
[ "$RC" -eq 0 ] && [ "$(base_sha "$C11")" = "$B11" ] \
  && [ "$(jq -r '.checkpoints|length' "$C11/plan/.git-baseline.json")" = "$N11" ] \
  && jq -e '.auth_anchor.decisions[] | select(.id=="D9")' "$C11/plan/.git-baseline.json" >/dev/null \
  && ok "T11b anchor-auth 只刷新锚，不动 baseline/checkpoint" || bad "T11b anchor-auth (rc=$RC)"
run bash "$GB" dispose "$C11/plan" --file facts.md --state authorized \
  --evidence 'decisions:D9|用户原话:同意删除 MK1' --repo "$C11/repo"
[ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -q 'DISPOSE OK' \
  && ok "T11c 显式 anchor-auth 后同一授权 → OK" || bad "T11c 锚后授权 (rc=$RC)"
run bash "$GB" diff "$C11/plan" --final --repo "$C11/repo"
[ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q 'FAIL unresolved=0 mustkeep_lost=1' \
  && ok "T11d 已授权但事实仍缺失 → diff rc=1 FAIL" || bad "T11d 授权后仍 FAIL (rc=$RC)"

# ── T12 retained 证据必须含被删原文（防任意存活片段洗白）─────────────────────
C12="$(mkcase t12)"
cat > "$C12/repo/facts.md" <<'EOF'
数据库使用 PostgreSQL 15
缓存使用 Redis
报告已归档
备注：报告已归档
EOF
run bash "$GB" snapshot "$C12/plan" --repo "$C12/repo"
awk '$0 != "报告已归档"' "$C12/repo/facts.md" > "$C12/f.tmp" && mv -- "$C12/f.tmp" "$C12/repo/facts.md"
run bash "$GB" diff "$C12/plan" --final --repo "$C12/repo"
[ "$RC" -eq 1 ] && jq -e '.last_diff.items[] | select(.kind=="deleted" and .path=="facts.md" and .verbatim=="报告已归档")' \
  "$C12/plan/.git-baseline.json" >/dev/null \
  && ok "T12a 删除行固化为 last_diff.items(kind=deleted)" || bad "T12a deleted 项 (rc=$RC)"
run bash "$GB" dispose "$C12/plan" --file facts.md --state retained --evidence '缓存使用 Redis' --repo "$C12/repo"
[ "$RC" -eq 1 ] && printf '%s\n' "$OUT" | grep -q '证据未包含被删原文' \
  && ok "T12b 任意存活片段 retained → REJECT" || bad "T12b 存活片段洗白 (rc=$RC)"
run bash "$GB" dispose "$C12/plan" --file facts.md --state retained --evidence '报告已归档' --repo "$C12/repo"
[ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -q 'DISPOSE OK' \
  && ok "T12c 证据含被删原文 → retained OK" || bad "T12c 合法 retained (rc=$RC)"
run bash "$GB" diff "$C12/plan" --final --repo "$C12/repo"
[ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -q 'PASS unresolved=0 mustkeep_lost=0' \
  && ok "T12d 删除已处置且无必保丢失 → diff PASS" || bad "T12d diff PASS (rc=$RC)"

TOTAL=$((PASS+FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
