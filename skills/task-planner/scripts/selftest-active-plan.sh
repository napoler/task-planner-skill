#!/usr/bin/env bash
# selftest-active-plan.sh — task-v059 Phase 4: active-plan-race 会话私有指针自测
# [2026-09-10] T01 side 指针优先(side 有/无 sid 双验) / T02 无 sid legacy 兜底(零破坏回归) / T03 TTL 24h 过期
#   / T04 side 内容路径穿越拒绝 / T05 set 旧位置参数写 legacy + set --sid 写 side / T06 gc 清扫
#   / T07 --show 双视图 / T08 init-session sid 分支(有 sid 写 side / 无 sid 写 legacy) / T09 fail-open
# hermetic: 夹具全在 mktemp -d, 跑完 trap rm -rf; 不触真实 plans/。全 PASS exit 0; 任一 FAIL exit 1。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RES="$SCRIPT_DIR/resolve-plan-dir.sh"
SET="$SCRIPT_DIR/set-active-plan.sh"
INIT="$SCRIPT_DIR/init-session.sh"
SYNC="$SCRIPT_DIR/sync-todos.sh"
ATTEST="$SCRIPT_DIR/attest-plan.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
PASS=0; FAIL=0

pass() { PASS=$((PASS+1)); printf 'T%s PASS %s\n' "$1" "$1"; }
fail() { FAIL=$((FAIL+1)); printf 'T%s FAIL %s\n' "$1" "$2"; }

mk_root() {  # <name> → 建 plans/{aa,bb}/task_plan.md, 输出 root 路径
  local r="$TMP/$1"
  mkdir -p "$r/plans/aa" "$r/plans/bb"
  for d in aa bb; do printf '# plan %s\n' "$d" > "$r/plans/$d/task_plan.md"; done
  printf '%s' "$r"
}

call() {  # 清 CLAUDE_CODE_SESSION_ID 后跑命令 → RC/COUT/CERR(防外层 env 扰动, 保 hermetic)
  RC=0; COUT="$(env -u CLAUDE_CODE_SESSION_ID "$@" 2>"$TMP/err")"; RC=$?
  CERR="$(cat "$TMP/err")"
}

# T01 side 指针优先: side(s1)=bb 与 legacy=aa 并存 → 带 sid 返回 side 指向
R1="$(mk_root t01)"; P1="$R1/plans"
bash "$SET" aa "$R1" > /dev/null 2>&1                       # 旧位置参数写 legacy
bash "$SET" set bb --sid s1 "$R1" > /dev/null 2>&1           # 写 side
call bash "$RES" "$R1" s1
[ "$COUT" = "$P1/bb/task_plan.md" ] && pass 01 || fail 01 "got=$COUT exp=$P1/bb/task_plan.md"
call bash "$RES" "$R1" s2                                     # s2 无 side → 回落 legacy aa
[ "$COUT" = "$P1/aa/task_plan.md" ] && pass 01b || fail 01b "got=$COUT exp=$P1/aa/task_plan.md"

# T02 无 sid 回退: 只 legacy 存在, 无 sid 调用返回 legacy(旧版零破坏回归)
R2="$(mk_root t02)"; P2="$R2/plans"
bash "$SET" aa "$R2" > /dev/null 2>&1
call bash "$RES" "$R2"
[ "$COUT" = "$P2/aa/task_plan.md" ] && pass 02 || fail 02 "got=$COUT exp=$P2/aa/task_plan.md"

# T03 TTL 过期: side mtime>24h 被跳过, 走 legacy
R3="$(mk_root t03)"; P3="$R3/plans"
bash "$SET" aa "$R3" > /dev/null 2>&1
bash "$SET" set bb --sid s1 "$R3" > /dev/null 2>&1
touch -d '25 hours ago' "$P3/.active_plan_side/s1.active_plan"
call bash "$RES" "$R3" s1
[ "$COUT" = "$P3/aa/task_plan.md" ] && pass 03 || fail 03 "got=$COUT exp=$P3/aa/task_plan.md"

# T04 非法 slug 内容: side 文件含路径穿越字符 → 拒绝, 走 legacy
R4="$(mk_root t04)"; P4="$R4/plans"
bash "$SET" aa "$R4" > /dev/null 2>&1
mkdir -p "$P4/.active_plan_side"
printf '%s\n' '../evil' > "$P4/.active_plan_side/s1.active_plan"
call bash "$RES" "$R4" s1
[ "$COUT" = "$P4/aa/task_plan.md" ] && pass 04 || fail 04 "got=$COUT exp=$P4/aa/task_plan.md"
printf '%s\n' '/abs/evil' > "$P4/.active_plan_side/s1.active_plan"   # 前导点/绝对路径同拒
call bash "$RES" "$R4" s1
[ "$COUT" = "$P4/aa/task_plan.md" ] && pass 04b || fail 04b "got=$COUT exp=$P4/aa/task_plan.md"

# T05 set 位置参数兼容: 旧签名 <task-id> [root] 写 legacy; set <task-id> [--sid s] [root] 写 side
R5="$(mk_root t05)"; P5="$R5/plans"
call bash "$SET" aa "$R5"
[ "$RC" = 0 ] && [ -f "$P5/.active_plan" ] && [ "$(cat "$P5/.active_plan")" = "aa" ] && pass 05a || \
  fail 05a "rc=$RC legacy 未写入或内容非 aa"
call bash "$SET" set bb --sid sX "$R5"
[ "$RC" = 0 ] && [ -f "$P5/.active_plan_side/sX.active_plan" ] && [ "$(cat "$P5/.active_plan_side/sX.active_plan")" = "bb" ] && pass 05b || \
  fail 05b "rc=$RC side/sX 未写入或内容非 bb"

# T06 gc 清扫: >24h side 文件被清, 新 side 文件保留 (root 为 gc 的位置参数)
R6="$(mk_root t06)"; P6="$R6/plans"
mkdir -p "$P6/.active_plan_side"
printf 'old\n' > "$P6/.active_plan_side/sold.active_plan"
touch -d '25 hours ago' "$P6/.active_plan_side/sold.active_plan"
printf 'new\n' > "$P6/.active_plan_side/snew.active_plan"
call bash "$SET" gc "$R6"
[ "$RC" = 0 ] && [ ! -f "$P6/.active_plan_side/sold.active_plan" ] && [ -f "$P6/.active_plan_side/snew.active_plan" ] && \
  printf '%s' "$COUT" | grep -qF 'gc 清除过期 side 指针: 1' && pass 06 || \
  fail 06 "rc=$RC out=$COUT (sold 应删 snew 应留 计数=1)"

# T07 --show 双视图: 同时展示 legacy 与 side 及解析结果
R7="$(mk_root t07)"; P7="$R7/plans"
bash "$SET" aa "$R7" > /dev/null 2>&1
bash "$SET" set bb --sid sZ "$R7" > /dev/null 2>&1
call bash "$SET" --show --sid sZ "$R7"
[ "$RC" = 0 ] && printf '%s\n' "$COUT" | grep -qF '全局指针:' && \
  printf '%s\n' "$COUT" | grep -qF 'side 指针(sid=sZ): bb' && \
  printf '%s\n' "$COUT" | grep -qF "$P7/bb/task_plan.md" && pass 07 || \
  fail 07 "rc=$RC out=$COUT"

# T08 init-session 分支: CLAUDE_CODE_SESSION_ID 有值→写 side 不碰 legacy; 无值→写 legacy
R8="$(mk_root t08)"; P8="$R8/plans"
mkdir -p "$P8/xx" "$P8/yy"
( cd "$P8/xx" && env CLAUDE_CODE_SESSION_ID=v059selft bash "$INIT" ) > "$TMP/err" 2>&1
RC=$?
[ "$RC" = 0 ] && [ -f "$P8/.active_plan_side/v059selft.active_plan" ] && \
  [ "$(cat "$P8/.active_plan_side/v059selft.active_plan")" = "xx" ] && [ ! -f "$P8/.active_plan" ] && pass 08a || \
  fail 08a "rc=$RC err=$(cat "$TMP/err" | tail -n 2)"
( cd "$P8/yy" && env -u CLAUDE_CODE_SESSION_ID bash "$INIT" ) > "$TMP/err" 2>&1
RC=$?
[ "$RC" = 0 ] && [ -f "$P8/.active_plan" ] && [ "$(cat "$P8/.active_plan")" = "yy" ] && \
  [ ! -e "$P8/.active_plan_side/yy.active_plan" ] && pass 08b || \
  fail 08b "rc=$RC err=$(cat "$TMP/err" | tail -n 2)"

# T09 (加分) fail-open: 不存在的 root 恒 exit 0 空输出
call bash "$RES" "$TMP/no-such-root-$$" ""
[ "$RC" = 0 ] && [ -z "$COUT" ] && pass 09 || fail 09 "rc=$RC out=$COUT"

# T10 [task-v065/V-5] 从 plan 子目录执行 sync-todos.sh --json 经向上解析收录自身
# (SKILL.md 标准流程 cd 进 plan 目录执行, 修复前报 no_plans_dir; 夹具 aa/bb 均含 Phase 块)
# 注意: ① 夹具 aa/bb 计划以 >> 追加 Goal + Phase 块(mk_root 生成的裸 '# plan aa' 无 Phase, 需补全)
#       ② 仅断言「向上解析命中 plans/ 且收录执行目录所属计划 aa」——bb 是 fixture 邻居,
#          sync-todos find 递归收录全 plans/ 为既有设计行为, 非 V-5 修复目标
R10="$(mk_root t10)"
printf '## Goal\nfixture\n\n### Phase 1: 诊断前置\n- [x] step\n- **Status:** complete（2026-09-13）\n' >> "$R10/plans/aa/task_plan.md"
printf '## Goal\nfixture\n\n### Phase 2: 实施\n- [ ] step\n- **Status:** pending\n' >> "$R10/plans/bb/task_plan.md"
RC=0; COUT="$( cd "$R10/plans/aa" && bash "$SYNC" --json 2>/dev/null )"; RC=$?
[ "$RC" = 0 ] && printf '%s' "$COUT" | grep -q '"task_id":"aa"' && \
  printf '%s' "$COUT" | grep -q 'aa/Phase 1: 诊断前置' && \
  printf '%s' "$COUT" | grep -q '"status":"complete"' && \
  ! printf '%s' "$COUT" | grep -q 'no_plans_dir' && pass 10 || fail 10 "rc=$RC out=$COUT"

# T11 [task-v065/V-8] attest-plan.sh 在 side 指针存在时锁定指针计划
# (side 指向 bb、legacy 指向 aa、且 touch aa 使 mtime 最新——attest 未接 resolver 前会锁错为 aa)
# 注意: ① 先建 aa/bb 计划文件再写指针(set-active-plan 的 require_plan 门控)
#       ② 显式注入 CLAUDE_CODE_SESSION_ID=s11(= side 文件名,与 T05b 口径一致)——
#          sid 缺失时 resolver 走 default side/legacy/mtime 链, T02 场景合法回落 legacy;
#          本用例断言的是「带会话 sid 时 side 指针锁死目标, 不被 mtime 最新计划顶掉」
R11="$(mk_root t11)"
bash "$SET" aa "$R11" > /dev/null 2>&1
bash "$SET" set bb --sid s11 "$R11" > /dev/null 2>&1
touch "$R11/plans/aa/task_plan.md"
( cd "$R11" && env CLAUDE_CODE_SESSION_ID=s11 bash "$ATTEST" --skip-dispatch-check > /dev/null 2>&1 )
RC=$?
[ "$RC" = 0 ] && [ -f "$R11/plans/bb/.plan-attestation" ] && \
  grep -q '^plan_file=.*bb/task_plan.md$' "$R11/plans/bb/.plan-attestation" && \
  [ ! -f "$R11/plans/aa/.plan-attestation" ] && pass 11 || \
  fail 11 "rc=$RC att_bb=$([ -f "$R11/plans/bb/.plan-attestation" ] && echo yes || echo no) att_aa=$([ -f "$R11/plans/aa/.plan-attestation" ] && echo no)"

# T12 [2026-09-16 task-v074 P10] sid 哨兵探测 fallback 行为级断言（env sid 与哨兵命名空间错位修复）
# T12a init-session: env sid(133bb…) 无对应哨兵 + 目录内存在 mtime 最新哨兵(sess038d…)
#   → side 指针文件名应为哨兵 stem 而非 env sid（对齐 SessionStart hook 命名空间）
ROOT12A="$(mk_root t12a)"
mkdir -p "$ROOT12A/plans/.plan_required_side" "$ROOT12A/plans/tt"
printf 'plan-required\ncreated_epoch: 1789475721144\n' > "$ROOT12A/plans/.plan_required_side/sess038ddeadbeef.plan_required"
( cd "$ROOT12A/plans/tt" && env CLAUDE_CODE_SESSION_ID=133bbenvdead1 bash "$INIT" ) > "$TMP/err" 2>&1
RC=$?
if [ "$RC" = 0 ] && [ -f "$ROOT12A/plans/.active_plan_side/sess038ddeadbeef.active_plan" ] && \
   [ "$(cat "$ROOT12A/plans/.active_plan_side/sess038ddeadbeef.active_plan")" = "tt" ] && \
   [ ! -e "$ROOT12A/plans/.active_plan_side/133bbenvdead1.active_plan" ]; then
    PASS=$((PASS+1)); echo "T12a PASS 12a"
else
    FAIL=$((FAIL+1)); echo "T12a FAIL got_rc=$RC err=$(tail -n 3 "$TMP/err")"
fi
# T12b init-session 回归: env sid 有对应哨兵 → 指针名=env sid（语义红线：行为不变）
ROOT12B="$(mk_root t12b)"
mkdir -p "$ROOT12B/plans/.plan_required_side" "$ROOT12B/plans/tt"
printf 'plan-required\n' > "$ROOT12B/plans/.plan_required_side/aa11bb22cc33dd44ee55.plan_required"
( cd "$ROOT12B/plans/tt" && env CLAUDE_CODE_SESSION_ID=aa11bb22cc33dd44ee55 bash "$INIT" ) > "$TMP/err" 2>&1
RC=$?
if [ "$RC" = 0 ] && [ -f "$ROOT12B/plans/.active_plan_side/aa11bb22cc33dd44ee55.active_plan" ] && \
   [ "$(cat "$ROOT12B/plans/.active_plan_side/aa11bb22cc33dd44ee55.active_plan")" = "tt" ]; then
    PASS=$((PASS+1)); echo "T12b PASS 12b"
else
    FAIL=$((FAIL+1)); echo "T12b FAIL got_rc=$RC err=$(tail -n 3 "$TMP/err")"
fi
# T12c init-session 回归: 无哨兵目录 + 无 env sid → 维持 legacy 全局指针（零破坏回归）
ROOT12C="$(mk_root t12c)"
mkdir -p "$ROOT12C/plans/tt"
( cd "$ROOT12C/plans/tt" && env -u CLAUDE_CODE_SESSION_ID bash "$INIT" ) > "$TMP/err" 2>&1
RC=$?
if [ "$RC" = 0 ] && [ -f "$ROOT12C/plans/.active_plan" ] && [ "$(cat "$ROOT12C/plans/.active_plan")" = "tt" ] && \
   [ ! -d "$ROOT12C/plans/.active_plan_side" ]; then
    PASS=$((PASS+1)); echo "T12c PASS 12c"
else
    FAIL=$((FAIL+1)); echo "T12c FAIL got_rc=$RC err=$(tail -n 3 "$TMP/err")"
fi
# T12d plan-created.cjs: 哨兵(sess stem) + side 指针(sess stem) + 计划目录 + 无关 env sid
#   → 哨兵被清（双侧清除经 fallback sidkey 命中）；无 sid 兜底行为不回归
PCRE=$(command -v node >/dev/null 2>&1 && echo yes || echo no)
if [ "$PCRE" = "yes" ]; then
  ROOT12D="$(mk_root t12d)"
  mkdir -p "$ROOT12D/plans/.plan_required_side" "$ROOT12D/plans/zz"
  printf 'plan-required\ncreated_epoch: 1\n' > "$ROOT12D/plans/.plan_required_side/ffff0011aaaa2233.plan_required"
  mkdir -p "$ROOT12D/plans/.active_plan_side"
  printf 'zz\n' > "$ROOT12D/plans/.active_plan_side/ffff0011aaaa2233.active_plan"
  OUT12D="$( cd "$ROOT12D/plans/zz" && env -u TASK_PLANNER_SID CLAUDE_CODE_SESSION_ID=deadbeef44 node "$SCRIPT_DIR/plan-created.cjs" </dev/null 2>&1 )"
  RC=$?
  if [ "$RC" = 0 ] && [ ! -f "$ROOT12D/plans/.plan_required_side/ffff0011aaaa2233.plan_required" ] && \
     printf '%s' "$OUT12D" | grep -q '会话哨兵已清除'; then
      PASS=$((PASS+1)); echo "T12d PASS 12d"
  else
      FAIL=$((FAIL+1)); echo "T12d FAIL rc=$RC out=$OUT12D"
  fi
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
