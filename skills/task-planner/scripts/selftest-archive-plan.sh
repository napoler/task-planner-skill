#!/usr/bin/env bash
# selftest-archive-plan.sh — task-v170: Rule 81「完成→归档」机制守护（Phase 4 S8，CA-8 权威范围）
#
# What（守护对象 + 运行方式）:
#   对 archive-plan.sh（S2 产物，契约=task_plan Decisions「archive-plan.sh CLI 契约」）的动态行为断言，
#   共 16 条编号断言 AP-01..AP-16（断言编号/逐行 PASS-FAIL/Total 汇总/exit 0|1 约定同 selftest-iteration-persistence.sh）：
#     · CLI 面（AP-01..AP-04）: --help exit 0 / 无参 usage exit 1 / 未知参数 exit 1 / task-id 与 --batch 互斥 exit 1
#     · 守卫五类拒绝（AP-05..AP-10）: missing-src / active-pointer(全局 .active_plan) / active-pointer(side 指针) /
#         live-owner（.session-owner mtime<1440min）/ status-incomplete（非全 complete）/ status-none（0 行 Status，fail-closed）
#     · 幂等（AP-11）: 目标已在 archive → ALREADY_ARCHIVED exit 0（唯一放行特例）
#     · 执行双路径（AP-12/AP-13）: git 跟踪目录→git mv（git status rename 实证）/ 未跟踪→mv 兜底（含陈旧 owner 随目录迁移）
#     · 批量 dry-run（AP-14..AP-16）: 零移动（6 子目录全在 + archive 未创建）/ 汇总计数 total=6 ok=0 skip=6 fail=0 /
#         六类 SKIP 归类理由逐行命中（圆点隐藏/非 task- 前缀/无 task_plan.md/active-pointer/status-incomplete/candidate/none）
#   运行方式：`bash scripts/selftest-archive-plan.sh`；fixture 全部 mktemp -d 建于 /tmp（trap EXIT 统一清理），
#   逐行打印 `AP-NN PASS/FAIL <说明>`，末行 `Total: N PASS=x FAIL=y`；全 PASS exit 0，任一 FAIL exit 1。
#
# Why（task-v170 R2「这是严重缺陷，必须添加归档」的机器守护）:
#   archive-plan.sh 是「完成→归档」的唯一执行体（Rule 81 机制件）——守卫误放/漏拦=在途任务被误归档（数据面事故），
#   dry-run 计数漂移=存量批量（S15）对账失据，幂等失效=重跑变 FAIL 噪音。本脚本=行为回归探测器，契约面任一变即 FAIL 报警。
#   AP-13 特意验证「陈旧 owner（40h）不拦且随目录迁移」：守卫 TTL 口径（owner mtime<24h 才拦，与 side 指针 24h 惯例一致）
#   是 task_plan Decisions 定案——陈旧拦截会使约 53 个完成任务无法归档（违背 R3），该行为必须被机器锁住。
#   fixture 全 /tmp + trap 清理（禁在 worktree/主仓 plans/ 落 fixture）：守卫测试需伪造指针/owner/状态文件，
#   仓内伪造=数据面污染（S2 探针误归档 task-v060 事故闭环判例）；/tmp 隔离后失败态也无残留。
# 依赖: bash + git（AP-12 fixture git init）+ GNU coreutils（touch -d / find -mmin，linux 环境）。
#       git 缺失时 AP-12 显式 FAIL（不静默跳过，fail-closed 口径）；零写入被测脚本本体。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVE="$SCRIPT_DIR/archive-plan.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'AP-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'AP-%s FAIL %s\n' "$1" "$2"; }

# mk_plan <plans根> <task-id>: 建 fixture 任务目录，task_plan.md 恰 1 行 `- **Status:** complete`
# （Status 行形态与被测脚本 guard_reason 的两条 grep 口径对齐：行首 `**Status:**` + 行内 `Status:** complete`）
mk_plan() {
    local root="$1" id="$2"
    mkdir -p "$root/$id"
    printf -- '- **Status:** complete\n' > "$root/$id/task_plan.md"
}

if [ ! -f "$ARCHIVE" ]; then
    printf 'AP-99 FAIL 被测脚本缺失: %s\n' "$ARCHIVE"
    exit 1
fi

# fixture 五根：R1 单任务守卫 / R2 幂等 / R3 git mv 路径 / R4 mv 兜底路径 / R5 批量 dry-run；
# 全部 /tmp（mktemp 默认模板 /tmp/tmp.XXXX），trap EXIT 一次清理——任一断言 FAIL 也不留脏 fixture。
R1="$(mktemp -d)"; R2="$(mktemp -d)"; R3="$(mktemp -d)"; R4="$(mktemp -d)"; R5="$(mktemp -d)"
trap 'rm -rf "$R1" "$R2" "$R3" "$R4" "$R5" 2>/dev/null' EXIT

# AP-01 --help exit 0 且打印 Usage
# What：`--help` 唯一合法零副作用出口（契约 Exit codes: 0=--help）。
# Why：help 被误改 exit 1 = 使用者误读脚本不可用（CLI 契约最小锚）。
out="$(bash "$ARCHIVE" --help 2>&1)"; rc=$?
if [ $rc -eq 0 ] && printf '%s\n' "$out" | grep -q 'Usage:'; then
    ok 01 "--help exit 0 且输出 Usage"
else
    bad 01 "--help rc=$rc（应 0，Usage 行在位=$(printf '%s\n' "$out" | grep -c 'Usage:')）"
fi

# AP-02 无参（非 --batch）= 参数错 exit 1 + usage 输出
# What：缺 task-id 且缺 --batch 时必须拒绝运行（L65-67 契约），不得空跑。
# Why：空跑放行 = 无人值守误触时脚本静默无动作且 exit 0，调用方误判成功。
out="$(bash "$ARCHIVE" 2>&1)"; rc=$?
if [ $rc -eq 1 ] && printf '%s\n' "$out" | grep -q 'Usage:'; then
    ok 02 "无参 exit 1 且打印 usage"
else
    bad 02 "无参 rc=$rc（应 1 + usage）"
fi

# AP-03 未知参数报错 exit 1
# What：`--bogus` 命中 `-*)` 分支 →「未知参数」error 行 + exit 1。
# Why：未知参数静默吞掉 = 拼错 CLI（如 --dryrun）时用户以为 dry-run 实际实做 mv（危险误执行面）。
out="$(bash "$ARCHIVE" --bogus 2>&1)"; rc=$?
if [ $rc -eq 1 ] && printf '%s\n' "$out" | grep -q '未知参数'; then
    ok 03 "未知参数 exit 1（未知参数报错行在位）"
else
    bad 03 "未知参数 rc=$rc（应 1 + 未知参数报错）"
fi

# AP-04 单任务 task-id 与 --batch 互斥报错 exit 1
# What：`task-x --batch` 命中互斥分支（L62-64）→ exit 1。
# Why：双模式同传若被静默偏向任一侧 = 批量实做候选集/单任务目标漂移（误归档面）。
out="$(bash "$ARCHIVE" task-x --batch 2>&1)"; rc=$?
if [ $rc -eq 1 ] && printf '%s\n' "$out" | grep -q '互斥'; then
    ok 04 "task-id 与 --batch 互斥 exit 1"
else
    bad 04 "互斥 rc=$rc（应 1 + 互斥报错）"
fi

# AP-05 守卫 missing-src：源目录不存在 → REJECT exit 1
# What：对不存在的 task-nope 单任务归档必须拒绝（L90 fail-closed 首关）。
# Why：typo task-id 若走 mv 分支 = mv 报错噪音或误建目标目录；REJECT 是「不存在的不要」的显式出口。
out="$(bash "$ARCHIVE" task-nope --root "$R1" 2>&1)"; rc=$?
if [ $rc -eq 1 ] && printf '%s\n' "$out" | grep -q 'REJECT task-nope: missing-src'; then
    ok 05 "missing-src 拒绝（REJECT exit 1）"
else
    bad 05 "missing-src rc=$rc（应 1 + REJECT missing-src）"
fi

# AP-06 守卫 active-pointer（全局 .active_plan）：内容==task-id → 拒绝
# What：.active_plan 指向 task-a 时归档 task-a 必须 REJECT（L92 无例外硬拦）。
# Why：active 指针=在途任务铁证（R2 守卫契约第一类拒绝）；放行=在途计划目录被移走，会话恢复即断。
mk_plan "$R1" task-a
echo task-a > "$R1/.active_plan"
out="$(bash "$ARCHIVE" task-a --root "$R1" 2>&1)"; rc=$?
if [ $rc -eq 1 ] && printf '%s\n' "$out" | grep -q 'REJECT task-a: active-pointer'; then
    ok 06 "active-pointer（全局）拒绝（REJECT exit 1）"
else
    bad 06 "全局 active-pointer rc=$rc（应 1 + REJECT active-pointer）"
fi

# AP-07 守卫 active-pointer（side 指针）：.active_plan_side/*.active_plan 内容==task-id → 拒绝
# What：side 指针命中同样硬拦（L95-100 遍历匹配）；全局与 side 双口都测=守卫面完整。
# Why：并行会话用 side 指针隔离（set-active-plan 语义），只拦全局不拦 side = 并行场景误归档在途任务。
mkdir -p "$R1/.active_plan_side"
echo task-b > "$R1/.active_plan_side/s1.active_plan"
mk_plan "$R1" task-b
out="$(bash "$ARCHIVE" task-b --root "$R1" 2>&1)"; rc=$?
if [ $rc -eq 1 ] && printf '%s\n' "$out" | grep -q 'REJECT task-b: active-pointer'; then
    ok 07 "active-pointer（side）拒绝（REJECT exit 1）"
else
    bad 07 "side active-pointer rc=$rc（应 1 + REJECT active-pointer）"
fi

# AP-08 守卫 live-owner：.session-owner mtime<1440min → 拒绝
# What：新鲜 owner（刚创建）在场时 REJECT live-owner（L102-108 find -mmin -1440 口径）。
# Why：owner=活会话持有标记；新鲜拦截=防并发会话正在写的任务被移走（R2 第三类拒绝）。
mk_plan "$R1" task-c
: > "$R1/task-c/.session-owner"
out="$(bash "$ARCHIVE" task-c --root "$R1" 2>&1)"; rc=$?
if [ $rc -eq 1 ] && printf '%s\n' "$out" | grep -q 'REJECT task-c: live-owner'; then
    ok 08 "live-owner（mtime<1440min）拒绝（REJECT exit 1）"
else
    bad 08 "live-owner rc=$rc（应 1 + REJECT live-owner）"
fi

# AP-09 守卫 status-incomplete：含非 complete 的 Status 行 → 拒绝
# What：task_plan.md 两行 Status（complete + in_progress）→ total≠ok → REJECT status-incomplete（L113-121 全量判定）。
# Why：mid-task（早期 Phase complete、后续 in_progress）若用 grep -m1 会误放行；全量 equal 判定是定案口径，
#      此处锁「非全 complete 一律拒绝」行为（禁把部分完成当完成）。
mkdir -p "$R1/task-e"
printf -- '- **Status:** complete\n- **Status:** in_progress\n' > "$R1/task-e/task_plan.md"
out="$(bash "$ARCHIVE" task-e --root "$R1" 2>&1)"; rc=$?
if [ $rc -eq 1 ] && printf '%s\n' "$out" | grep -q 'REJECT task-e: status-incomplete'; then
    ok 09 "status-incomplete 拒绝（REJECT exit 1）"
else
    bad 09 "status-incomplete rc=$rc（应 1 + REJECT status-incomplete）"
fi

# AP-10 守卫 status-none：0 行 Status → 拒绝（fail-closed 异常态）
# What：task_plan.md 无 Status 行 → total=0 → REJECT status-none（L116-118）。
# Why：无 Status 行=异常文件（v146 判例），fail-closed 拒绝而非当 complete 放行（v146 先例固化进契约）。
mkdir -p "$R1/task-f"
printf -- '# fixture without status\n' > "$R1/task-f/task_plan.md"
out="$(bash "$ARCHIVE" task-f --root "$R1" 2>&1)"; rc=$?
if [ $rc -eq 1 ] && printf '%s\n' "$out" | grep -q 'REJECT task-f: status-none'; then
    ok 10 "status-none（0 行 Status）拒绝（REJECT exit 1）"
else
    bad 10 "status-none rc=$rc（应 1 + REJECT status-none）"
fi

# AP-11 幂等：目标 archive/<id> 已存在 → ALREADY_ARCHIVED exit 0
# What：已在 archive 的重跑直接放行（L141-144，唯一放行特例，先于守卫判定）。
# Why：批量跑到一半重跑（S15 场景）必须幂等而非 FAIL/误 mv 覆盖；exit 0 让调用链可无条件重试。
mkdir -p "$R2/archive/task-d"
out="$(bash "$ARCHIVE" task-d --root "$R2" 2>&1)"; rc=$?
if [ $rc -eq 0 ] && printf '%s\n' "$out" | grep -q 'ALREADY_ARCHIVED task-d'; then
    ok 11 "幂等 ALREADY_ARCHIVED exit 0"
else
    bad 11 "幂等 rc=$rc（应 0 + ALREADY_ARCHIVED）"
fi

# AP-12 执行路径①：git 跟踪目录 → git mv（git status rename 实证，可 revert 形态）
# What：git fixture 中已跟踪的 task-g 归档后：exit 0 + ARCHIVED 行 + 源目录消失 + 目标在位 +
#      git status --porcelain 出现 R（rename）行（git mv 而非裸 mv 的机器证据，L129-130 分支）。
# Why：git mv 保留 rename 历史=归档可 revert（Decisions「git 全跟踪→可 revert 回退」）；
#      只验目录移动不验 git 面 = 无法证明走的是 git mv 分支（mv 兜底误入 git 目录同样目录对）。
git -C "$R3" init -q
git -C "$R3" config user.email fixture@example.com
git -C "$R3" config user.name fixture
mk_plan "$R3" task-g
git -C "$R3" add -A
git -C "$R3" commit -qm init
out="$(bash "$ARCHIVE" task-g --root "$R3" 2>&1)"; rc=$?
ren="$(git -C "$R3" status --porcelain 2>/dev/null | grep -c '^R' || true)"
if [ $rc -eq 0 ] && printf '%s\n' "$out" | grep -q 'ARCHIVED task-g' \
   && [ -d "$R3/archive/task-g" ] && [ ! -d "$R3/task-g" ] && [ "${ren:-0}" -ge 1 ]; then
    ok 12 "git mv 路径：ARCHIVED exit 0 + 目录迁移 + git status rename 行在位（$ren）"
else
    bad 12 "git mv 路径 rc=$rc out=$(printf '%s\n' "$out" | grep 'task-g' | head -1) rename行=$ren（应 0 + 迁移 + R 行≥1）"
fi

# AP-13 执行路径②：未跟踪目录 → mv 兜底（v162 先例）+ 陈旧 owner（40h）不拦且随目录迁移
# What：无 git 的 R4 中 task-m（owner mtime 回溯 40h）归档：exit 0 + 源消失 + 目标在位 + owner 文件在目标内。
# Why：①未跟踪目录（v162 实证）无 git mv 可用，mv 兜底保证它们也能进 archive（R3 全归档不留死角）；
#      ②陈旧 owner 放行=Decisions TTL 口径（仅 <24h 拦截）——owner 随目录移入 archive 作历史记录，不拦不删。
mk_plan "$R4" task-m
: > "$R4/task-m/.session-owner"
touch -d '40 hours ago' "$R4/task-m/.session-owner"
out="$(bash "$ARCHIVE" task-m --root "$R4" 2>&1)"; rc=$?
if [ $rc -eq 0 ] && printf '%s\n' "$out" | grep -q 'ARCHIVED task-m' \
   && [ -d "$R4/archive/task-m" ] && [ ! -d "$R4/task-m" ] && [ -f "$R4/archive/task-m/.session-owner" ]; then
    ok 13 "mv 兜底路径：陈旧 owner 放行 + ARCHIVED + owner 随目录迁移"
else
    bad 13 "mv 兜底 rc=$rc（应 0 + 迁移 + owner 在目标内；陈旧 owner 应不拦）"
fi

# --- 批量 dry-run fixture（R5）：6 子目录覆盖全部 SKIP 归类 + 1 个 candidate/dry-run 行 --------------
mkdir -p "$R5/.active_plan_side"                       # 圆点目录 → SKIP hidden
echo task-act > "$R5/.active_plan"                      # 全局指针指向 task-act
echo task-act > "$R5/.active_plan_side/s1.active_plan"  # side 指针同指（守卫面双口在位）
mkdir -p "$R5/notes"                                    # 非 task- 前缀 → SKIP not task- prefixed
mkdir -p "$R5/task-noplan"
echo x > "$R5/task-noplan/readme"                        # 无 task_plan.md → SKIP no task_plan.md
mk_plan "$R5" task-act                                   # 命中 active-pointer → SKIP
mkdir -p "$R5/task-incomplete"
printf -- '- **Status:** complete\n- **Status:** in_progress\n' > "$R5/task-incomplete/task_plan.md"
mk_plan "$R5" task-ok                                     # 合格 candidate → dry-run 下 SKIP (candidate/none)

out="$(bash "$ARCHIVE" --batch --dry-run --root "$R5" 2>&1)"; rc=$?

# AP-14 批量 dry-run 零移动：6 子目录全在 + archive 目录未被创建
# What：dry-run 只列行不落盘（L195-198 SKIP candidate/none 后 continue，do_archive 未触达）；
#      判据=枚举的 6 类目录迁移前后不变 + $R5/archive 不存在（mkdir 只在 do_archive 内）。
# Why：dry-run 是 S13 双向对账的候选清单源，任何一次误 mv=对账基线污染+在途目录被移（危险误执行面）。
moved=0
for d in .active_plan_side notes task-noplan task-act task-incomplete task-ok; do
    [ -d "$R5/$d" ] || moved=1
done
if [ $rc -eq 0 ] && [ $moved -eq 0 ] && [ ! -e "$R5/archive" ]; then
    ok 14 "批量 dry-run 零移动（6 子目录全在 + archive 未创建 + exit 0）"
else
    bad 14 "批量 dry-run rc=$rc 移动迹象=$moved archive存在=$([ -e "$R5/archive" ] && echo yes || echo no)（应 0/无移动/未创建）"
fi

# AP-15 批量 dry-run 汇总计数：total=6 ok=0 skip=6 fail=0
# What：BATCH 行逐计数核对（dry-run 下 candidate 计 skip 不计 ok，ok=0 是 dry-run 语义锚）。
# Why：汇总计数是 S15 熔断（失败率>5%）与对账口径的数据源；任一计数漂移=批量治理判据失真。
if printf '%s\n' "$out" | grep -q 'BATCH total=6 ok=0 skip=6 fail=0 (dry-run)'; then
    ok 15 "批量 dry-run 汇总计数 total=6 ok=0 skip=6 fail=0"
else
    bad 15 "汇总行=$(printf '%s\n' "$out" | grep 'BATCH total=' | head -1)（应 total=6 ok=0 skip=6 fail=0）"
fi

# AP-16 批量 SKIP 归类理由：六类各 1 行命中（hidden / not task- prefixed / no task_plan.md / active-pointer / status-incomplete / candidate/none）
# What：每类跳过带机器可读理由码（L169-198 归类输出契约），供 S13 按理由分布对账。
# Why：归类跳过无理由=误跳过不可观测（圆点目录/辅助目录被静默吞掉）；六类齐备=「非计划目录为何不动」全可审计。
n_hit=0
for pat in 'SKIP .active_plan_side (not-a-plan-dir: hidden)' \
           'SKIP notes (not-a-plan-dir: not task- prefixed)' \
           'SKIP task-noplan (not-a-plan-dir: no task_plan.md)' \
           'SKIP task-act (active-pointer)' \
           'SKIP task-incomplete (status-incomplete)' \
           'SKIP task-ok (candidate/none)'; do
    if printf '%s\n' "$out" | grep -qF "$pat"; then
        n_hit=$((n_hit + 1))
    else
        bad 16 "SKIP 归类行缺失: $pat"
    fi
done
[ $n_hit -eq 6 ] && ok 16 "批量 SKIP 归类 6 类理由行全命中"

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
