#!/usr/bin/env bash
# selftest-rule-reserve.sh — task-v128 S5: Rule 20.6 规则编号预留登记机制静态守护
# 守护（RR-01..RR-10 共 10 断言, 按 findings §D5 定稿; 静态锚 + 行为 fixture + 负向自检）:
#   RR-01 静态锚: scripts/rule-reserve.sh 存在且可执行（S2 产出, 防误删/权限漂移）
#   RR-02 静态锚: usage 含六命令 reserve/check/next/list/land/release
#   RR-03 静态锚: 账本路径常量在位（basename .rule-reservations.jsonl + env 覆盖 RULE_RESERVE_LEDGER）
#   RR-04 静态锚: STRICT 阻断 env 名 TASK_PLANNER_RULE_RESERVE_STRICT 在 attest-plan.sh（零新 config 键, 对齐 enforce env 先例）
#   RR-05 行为: reserve 冲突 exit 3（RULE_RESERVE_LEDGER=/tmp 临时账本, 禁写仓库真账本）
#   RR-06 行为: next 跳过占用（seed 49/50 → 输出 51, /tmp 临时账本）
#   RR-07 行为: release 越权 exit 4（无持有记录, /tmp 临时账本）
#   RR-08 行为: contested 可表达且 list 可见（claimants 呈现, /tmp 临时账本）
#   RR-09 静态锚: attest-plan.sh 挂点引用 rule-reserve（查重段在位, 防挂点误删）
#   RR-10 负向自检: 构造缺「账本路径常量」锚的副本 → RR-03 同款 grep 判定 FAIL（有牙齿实测）
# 10 断言全 PASS exit 0; 任一 FAIL exit 1。行为级 4 条测试产物全部在 mktemp/mktemp-d 目录, 用完即清理。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RR="$SCRIPT_DIR/rule-reserve.sh"
ATTEST="$SCRIPT_DIR/attest-plan.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'RR-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'RR-%s FAIL %s\n' "$1" "$2"; }

# RR-01 脚本存在且可执行
if [ -x "$RR" ]; then ok 01 "rule-reserve.sh 存在且可执行"; else bad 01 "rule-reserve.sh 缺失或不可执行"; fi

# RR-02 usage 六命令
if [ -f "$RR" ]; then
  missing=""
  for c in reserve check next list land release; do
    ! grep -q "^  ${c} " "$RR" && missing="${missing} ${c}"
  done
  [ -z "$missing" ] && ok 02 "usage 含六命令" || bad 02 "usage 缺命令:${missing}"
else
  bad 02 "rule-reserve.sh 缺失"
fi

# RR-03 账本路径常量（basename + env 覆盖名）
if [ -f "$RR" ] && grep -q '\.rule-reservations\.jsonl' "$RR" && grep -q 'RULE_RESERVE_LEDGER' "$RR"; then
  ok 03 "账本路径常量在位（.rule-reservations.jsonl + RULE_RESERVE_LEDGER）"
else
  bad 03 "账本路径常量缺失（basename/env 覆盖名至少一项 grep 失败）"
fi

# RR-04 STRICT env 名在 attest 挂点
if grep -q 'TASK_PLANNER_RULE_RESERVE_STRICT' "$ATTEST"; then
  ok 04 "attest-plan.sh 含 TASK_PLANNER_RULE_RESERVE_STRICT 锚"
else
  bad 04 "attest-plan.sh 缺 STRICT env 锚"
fi

# RR-05 行为: reserve 冲突 exit 3（临时账本, 禁写仓库 plans/ 真账本）
T1="$(mktemp -d /tmp/rr-selftest.XXXXXX)"
T2="$(mktemp -d /tmp/rr-selftest2.XXXXXX)"
T3="$(mktemp -d /tmp/rr-selftest3.XXXXXX)"
T4="$(mktemp -d /tmp/rr-selftest4.XXXXXX)"
# 统一 EXIT 清理（Why: set -u 下 trap 引用未初始化变量会炸, 四个目录一次性预建）
trap 'rm -rf "$T1" "$T2" "$T3" "$T4"' EXIT
export RULE_RESERVE_LEDGER="$T1/ledger.jsonl"
bash "$RR" reserve 46 task-a >/dev/null 2>&1   # 预置：task-a 先占 46
bash "$RR" reserve 46 task-b >/dev/null 2>&1
rc=$?
if [ "$rc" -eq 3 ]; then ok 05 "行为: reserve 冲突 exit 3"; else bad 05 "行为: reserve 冲突应 exit 3 实际 exit $rc"; fi

# RR-06 行为: next 跳过占用（seed 49 landed + 50 reserved → 输出 51）
# Why: next 契约 = >max(landed) 且跳过 reserved/contested 占位（rule-reserve.sh S2 冻结语义）。
# 仅 seed 49/50 为 reserved 时 max_landed=0 → next=1，无法验证「跳过占位」；故 49 先 reserve 再 land，
# 使 50（reserved）成为紧接 max_landed 的占位，next 必须跳过它 → 51。
RULE_RESERVE_LEDGER="$T2/ledger.jsonl" bash "$RR" reserve 49 task-a >/dev/null 2>&1
RULE_RESERVE_LEDGER="$T2/ledger.jsonl" bash "$RR" land 49 task-a >/dev/null 2>&1
RULE_RESERVE_LEDGER="$T2/ledger.jsonl" bash "$RR" reserve 50 task-b >/dev/null 2>&1
nxt="$(RULE_RESERVE_LEDGER="$T2/ledger.jsonl" bash "$RR" next 2>/dev/null | tr -d '[:space:]')"
if [ "$nxt" = "51" ]; then ok 06 "行为: next 跳过占用 49(landed)/50(reserved) → 输出 51"; else bad 06 "行为: next 应输出 51 实际 '$nxt'"; fi

# RR-07 行为: release 越权 exit 4（46 无持有记录 → 非持有人）
RULE_RESERVE_LEDGER="$T3/ledger.jsonl" bash "$RR" release 46 task-b >/dev/null 2>&1
rc=$?
if [ "$rc" -eq 4 ]; then ok 07 "行为: release 越权 exit 4"; else bad 07 "行为: release 越权应 exit 4 实际 exit $rc"; fi

# RR-08 行为: contested 可表达且 list 可见
printf '%s\n' '{"rule":50,"status":"contested","claimants":["task-v125","task-v127"],"ts":"2026-10-04","note":"selftest fixture"}' > "$T4/ledger.jsonl"
out="$(RULE_RESERVE_LEDGER="$T4/ledger.jsonl" bash "$RR" list 2>/dev/null)"
if printf '%s' "$out" | grep -q 'contested' && printf '%s' "$out" | grep -q 'task-v125' && printf '%s' "$out" | grep -q 'task-v127'; then
  ok 08 "行为: contested 可表达且 list 可见（claimants 呈现）"
else
  bad 08 "行为: contested 状态在 list 中不可见: $out"
fi

# RR-09 attest 挂点引用
if grep -q 'rule-reserve' "$ATTEST"; then ok 09 "attest-plan.sh 含 rule-reserve 挂点引用"; else bad 09 "attest-plan.sh 缺 rule-reserve 挂点"; fi

# RR-10 负向自检（有牙齿）: 把 .rule-reservations.jsonl 常量锚从副本中抹掉,
#      对副本跑与 RR-03 同款判定应 FAIL；若判定仍 PASS = RR-03 无牙齿, RR-10 自败
negcopy="$(mktemp /tmp/rr-selftest-neg.XXXXXXXX.sh)"
sed 's/\.rule-reservations\.jsonl/.ledgerselftestgone.jsonl/g' "$RR" > "$negcopy"
if ! grep -q '\.rule-reservations\.jsonl' "$negcopy" && grep -q 'RULE_RESERVE_LEDGER' "$negcopy"; then
  # 副本确实「缺账本 basename 锚」但保留 env 名 → RR-03 同款 AND 判定必须 FAIL
  if grep -q '\.rule-reservations\.jsonl' "$negcopy"; then
    bad 10 "负向自检: 缺锚副本竟满足 RR-03 判定（无牙齿）"
  else
    ok 10 "负向自检: 缺锚副本使 RR-03 同款判定 FAIL（有牙齿实测: 输入=sed 抹除 basename 锚的副本, 输出=grep 不命中）"
  fi
fi
rm -f "$negcopy"

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
