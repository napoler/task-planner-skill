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

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
