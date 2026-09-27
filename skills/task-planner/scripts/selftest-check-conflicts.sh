#!/usr/bin/env bash
# selftest-check-conflicts.sh — task-v091 C-1f 前置: check-conflicts.sh 五类信号行为级自测
# 被测对象: check-conflicts.sh 两种模式(init 计划创建时 / --runtime Rule 23 运行时)。
# 每夹具在 /tmp 独立 mktemp 目录构造最小 hermetic git 仓(局部 -c user.* 身份, 不依赖全局
# config), 实跑被测脚本断言 stdout 关键行 + 退出码。这是 C-1f「9 处 git 调用合并」改前的
# 行为基线捕捉: 现行实现与期待不符时如实记 FAIL, 不迁就实现改期待; C-1f 改后必须全 PASS
# 且逐信号输出语义一致(五信号输出文本/计数/列表均锁定)。
#   CC-01 init 信号①+⑤: 未跟踪 hooks/ 目录 → ①未提交变更 1 个文件 + ⑤运行中基础设施行 + 列表行
#   CC-02 init 信号②: 附属 worktree → ②额外 worktree 计数 + 路径列表行
#   CC-03 init 信号③: 遗留 wt/leftover 分支 → ③wt/* 分支计数 + 分支列表行
#   CC-04 init 信号④: plans/INDEX.md 待处理区列表行(已提交) → ④在册未完成任务计数
#   CC-05 init 全绿: 干净仓无 INDEX → ✓ 无冲突信号行 + rc=0
#   CC-06 runtime 冲突 A: 两计划 scope 交集 → 🔴 冲突 A 行恰 1 条(报他计划, 自计划被跳过)
#   + 交集文件行(覆盖 --runtime 慢路径; task-v092/S7 起夹具 INDEX 改真实形态)
#   CC-07 runtime 自计划跳过: INDEX 在册唯一 in_progress=当前计划自身 → 零冲突 A + ✓ 通过行 + rc=0
# 历史限制注记(task-v092/S5 已修, 原「S16 已知既有限制」随之失效, 保留变更脉络):
#   check-conflicts.sh INDEX 解析管道旧 sed 区间 '/^| Task ID/,/^|-------/' 的 end 模式曾被真实
#   格式 INDEX(分隔行紧跟表头)的分隔行命中 → 区间提前终止、数据行恒不可达 → active_plans 恒空、
#   A/B/C 不触发; CC-06 当年按 S16 对拍先例以「分隔行置尾」畸形 INDEX 锁定旧行为。S5 修复(end
#   模式改 /^[^|]/ + 管道中段滤分隔行)后真实形态可解析, CC-06 夹具同步改造为真实形态并锁定修复
#   后行为; S6 修自计划跳过后增补 CC-07 断言。信号④解析用「## 待处理」区段列表行, 与表格 INDEX 互不相干。
# Total 行汇总, 任一 FAIL exit 1。只读被测脚本, 写入仅 /tmp 夹具, 退出清理。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CC="$SCRIPT_DIR/check-conflicts.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'CC-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'CC-%s FAIL %s\n' "$1" "$2"; }
diag() { printf '  detail: %s\n' "$1"; }

OUT=""; RC=0
# mk_sandbox <dir>: 最小干净 git 仓(一个空 commit 即 clean, 不依赖任何全局 config)
mk_sandbox() {
    local d="$1"
    mkdir -p "$d"
    git -C "$d" init -q
    git -C "$d" -c user.email=selftest@t -c user.name=selftest commit -q --allow-empty -m init
}
# run_cc <init|runtime> <root>: 实跑被测脚本, 仓在 $root/repo, stdout→OUT, rc→RC
#   (stderr 落 $root/stderr.txt 于仓外——重定向文件若落仓内会以 ?? 未跟踪行污染信号①)
run_cc() {
    local mode="$1" root="$2"
    if [ "$mode" = runtime ]; then
        OUT="$(bash "$CC" --runtime "$root/repo" 2>"$root/stderr.txt")"
    else
        OUT="$(bash "$CC" "$root/repo" 2>"$root/stderr.txt")"
    fi
    RC=$?
}

R1=""; R2=""; R3=""; R4=""; R5=""; R6=""; R7=""
cleanup() {
    local d
    for d in "$R1" "$R2" "$R3" "$R4" "$R5" "$R6" "$R7"; do
        [ -n "$d" ] && rm -rf "$d"
    done
    return 0
}
trap cleanup EXIT

# CC-01 init 信号①+⑤: 未跟踪 hooks/ → 计数 1 + 基础设施子信号 + porcelain 列表行
R1="$(mktemp -d "${TMPDIR:-/tmp}/cc-selftest-1-XXXXXX")"
mk_sandbox "$R1/repo"
mkdir -p "$R1/repo/hooks" && echo x > "$R1/repo/hooks/pre-tool.sh"
run_cc init "$R1"
if [ "$RC" -eq 1 ] \
   && printf '%s' "$OUT" | grep -qF '信号①: 未提交变更 1 个文件' \
   && printf '%s' "$OUT" | grep -qF '?? hooks/' \
   && printf '%s' "$OUT" | grep -qF '信号⑤: 其中 1 个是运行中基础设施'; then
  ok 01 "未提交变更计数+porcelain 列表+基础设施子信号, rc=1"
else
  bad 01 "信号①/⑤ 输出或 rc 不符(得 rc=$RC)"
  printf '%s\n' "$OUT" | sed 's/^/  out| /'
fi

# CC-02 init 信号②: 附属 worktree → 计数 1 + 路径列表行
R2="$(mktemp -d "${TMPDIR:-/tmp}/cc-selftest-2-XXXXXX")"
mk_sandbox "$R2/repo"
git -C "$R2/repo" worktree add -q "$R2/repo/wt-extra" -b feat-x
run_cc init "$R2"
if [ "$RC" -eq 1 ] \
   && printf '%s' "$OUT" | grep -qF '信号②: 存在 1 个额外 worktree' \
   && printf '%s' "$OUT" | grep -qF "$R2/repo/wt-extra"; then
  ok 02 "额外 worktree 计数+路径列表, rc=1"
else
  bad 02 "信号② 输出或 rc 不符(得 rc=$RC)"
  printf '%s\n' "$OUT" | sed 's/^/  out| /'
fi

# CC-03 init 信号③: 遗留 wt/leftover 分支 → 计数 1 + 分支列表行
R3="$(mktemp -d "${TMPDIR:-/tmp}/cc-selftest-3-XXXXXX")"
mk_sandbox "$R3/repo"
git -C "$R3/repo" branch wt/leftover
run_cc init "$R3"
if [ "$RC" -eq 1 ] \
   && printf '%s' "$OUT" | grep -qF '信号③: 遗留 wt/* 分支 1 个' \
   && printf '%s' "$OUT" | grep -qF 'wt/leftover'; then
  ok 03 "遗留 wt/* 分支计数+列表, rc=1"
else
  bad 03 "信号③ 输出或 rc 不符(得 rc=$RC)"
  printf '%s\n' "$OUT" | sed 's/^/  out| /'
fi

# CC-04 init 信号④: INDEX 待处理区 2 条列表行(已提交保干净) → 计数 2
R4="$(mktemp -d "${TMPDIR:-/tmp}/cc-selftest-4-XXXXXX")"
mk_sandbox "$R4/repo"
mkdir -p "$R4/repo/plans"
{
    printf '# plans index\n\n## 待处理\n'
    printf -- '- **task-aaa**: goal a\n- **task-bbb**: goal b\n'
    printf '\n## 已完成\n'
} > "$R4/repo/plans/INDEX.md"
git -C "$R4/repo" add plans/INDEX.md
git -C "$R4/repo" -c user.email=selftest@t -c user.name=selftest commit -q -m idx
run_cc init "$R4"
if [ "$RC" -eq 1 ] && printf '%s' "$OUT" | grep -qF '信号④: 2 个未完成任务在册'; then
  ok 04 "待处理区在册任务计数=2, rc=1"
else
  bad 04 "信号④ 输出或 rc 不符(得 rc=$RC)"
  printf '%s\n' "$OUT" | sed 's/^/  out| /'
fi

# CC-05 init 全绿: 干净仓无 INDEX → ✓ 行 + rc=0
R5="$(mktemp -d "${TMPDIR:-/tmp}/cc-selftest-5-XXXXXX")"
mk_sandbox "$R5/repo"
run_cc init "$R5"
if [ "$RC" -eq 0 ] && printf '%s' "$OUT" | grep -qF '✓ 未发现冲突信号'; then
  ok 05 "无冲突基线全绿输出, rc=0"
else
  bad 05 "全绿输出或 rc 不符(得 rc=$RC)"
  printf '%s\n' "$OUT" | sed 's/^/  out| /'
fi

# CC-06 runtime 冲突 A: 真实形态 INDEX(9 字段表头+紧邻 6 字段分隔行, 与主仓 plans/INDEX.md 同构;
#   task-v092/S7 改造, 原「分隔行置尾」畸形夹具随 S5 修复退役)+两计划 scope 交集
#   plans/task-cur(当前, glob 序在前) 与 plans/t-other(in_progress) 共享 src/shared.py
#   → 恰 1 条冲突 A 且报他计划 t-other(自计划 task-cur 被跳过, S6 修复后语义)
R6="$(mktemp -d "${TMPDIR:-/tmp}/cc-selftest-6-XXXXXX")"
mk_sandbox "$R6/repo"
mkdir -p "$R6/repo/plans/task-cur" "$R6/repo/plans/t-other"
{
    printf '# task_plan: task-cur\nsession_id: sess-cur\nworktree_path: n/a\n\n'
    printf '## ⚠️ 执行范围限制\n\n'
    printf '| # | 文件路径 | 操作 |\n|---|---------|------|\n'
    printf '| 1 | src/shared.py | 修改 |\n| 2 | src/cur.py | 修改 |\n'
} > "$R6/repo/plans/task-cur/task_plan.md"
{
    printf '# task_plan: t-other\nsession_id: sess-other\nworktree_path: n/a\n\n'
    printf '## ⚠️ 执行范围限制\n\n'
    printf '| # | 文件路径 | 操作 |\n|---|---------|------|\n'
    printf '| 1 | src/shared.py | 修改 |\n'
} > "$R6/repo/plans/t-other/task_plan.md"
{
    printf '# plans index\n\n'
    printf '| Task ID | Status | Phase 进度 | Goal | session_id | worktree | scope_files | 最后更新 | 待办 |\n'
    printf '|---------|--------|-----------|------|---------|------|\n'
    printf '| t-other | in_progress | 1/3 | other | sess-other |  | `src/shared.py` | 2026-09-27 |  |\n'
} > "$R6/repo/plans/INDEX.md"
git -C "$R6/repo" add plans/
git -C "$R6/repo" -c user.email=selftest@t -c user.name=selftest commit -q -m plans
run_cc runtime "$R6"
if [ "$RC" -eq 1 ] \
   && printf '%s' "$OUT" | grep -qF 'mode=runtime' \
   && [ "$(printf '%s' "$OUT" | grep -cF '🔴 冲突 A(同文件)')" -eq 1 ] \
   && printf '%s' "$OUT" | grep -qF '🔴 冲突 A(同文件): plan t-other session=sess-other' \
   && printf '%s' "$OUT" | grep -qF 'src/shared.py'; then
  ok 06 "runtime 同文件冲突 A(真实形态 INDEX)恰 1 条且报他计划 t-other, rc=1"
else
  bad 06 "冲突 A 输出/条数或 rc 不符(得 rc=$RC)"
  printf '%s\n' "$OUT" | sed 's/^/  out| /'
fi

# CC-07 runtime 自计划跳过: INDEX 在册唯一 in_progress=当前计划自身(task-v092/S6 修复后语义;
#   夹具构造复用 S6 checkpoint 思路)。若自计划跳过失效(worktree_path=n/a 抑制冲突 B,
#   scope 自交仍触发冲突 A)将自报冲突 A 且 rc=1 → 本用例即红, 非恒真
R7="$(mktemp -d "${TMPDIR:-/tmp}/cc-selftest-7-XXXXXX")"
mk_sandbox "$R7/repo"
mkdir -p "$R7/repo/plans/self-plan"
{
    printf '# task_plan: self-plan\nsession_id: sess-self\nworktree_path: n/a\n\n'
    printf '## ⚠️ 执行范围限制\n\n'
    printf '| # | 文件路径 | 操作 |\n|---|---------|------|\n'
    printf '| 1 | src/solo.py | 修改 |\n'
} > "$R7/repo/plans/self-plan/task_plan.md"
{
    printf '# plans index\n\n'
    printf '| Task ID | Status | Phase 进度 | Goal | session_id | worktree | scope_files | 最后更新 | 待办 |\n'
    printf '|---------|--------|-----------|------|---------|------|\n'
    printf '| self-plan | in_progress | 1/2 | self only | sess-self |  | `src/solo.py` | 2026-09-27 |  |\n'
} > "$R7/repo/plans/INDEX.md"
git -C "$R7/repo" add plans/
git -C "$R7/repo" -c user.email=selftest@t -c user.name=selftest commit -q -m plans
run_cc runtime "$R7"
if [ "$RC" -eq 0 ] \
   && printf '%s' "$OUT" | grep -qF '✓ 运行时并发冲突检测通过' \
   && [ "$(printf '%s' "$OUT" | grep -cF '🔴 冲突 A(同文件)')" -eq 0 ]; then
  ok 07 "仅自计划在册零冲突 A 全绿通过, rc=0"
else
  bad 07 "自计划被误报或 rc 不符(得 rc=$RC)"
  printf '%s\n' "$OUT" | sed 's/^/  out| /'
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
