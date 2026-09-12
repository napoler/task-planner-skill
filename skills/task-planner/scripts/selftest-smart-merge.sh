#!/usr/bin/env bash
# selftest-smart-merge.sh — task-v064-smart-merge-back S1: smart-merge-back.sh 智能门 hermetic 自测
# 7 用例(SM-01..07): 脏 worktree exit3 / 干净合并 exit0+merge commit / 已合并 exit0 ALREADY_MERGED /
#   master 前进 exit5(--force 后 exit0) / scope 重叠 exit4 / --deploy slot 判定 exit6 / [CLEANUP] 提示且 worktree 保留
# hermetic: 每用例独立 tmp 仓(bare origin + clone master + worktree add), trap 全量清理; 禁止触碰真实 worktree/部署位。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$SCRIPT_DIR/smart-merge-back.sh"

# 临时仓内所有 git 操作均静默 stderr 噪音("a branch named 'master' already exists" 等,
# 由 bare 仓默认 HEAD=master + 本地 master ref 已存在触发, 不影响 ref 实际更新与语义)
GLUE="2>/dev/null"

PASS=0; FAIL=0

# 夹具: mktemp -d + git init --bare origin.git + clone 出 <tmp>/main(master) + worktree add <tmp>/task-test -b wt/task-test
# 要点: 分支从 merge-base 分叉(非 master), 主仓 clone 出 master(不带 branch 的空行, 供脚本 awk 解析主仓路径);
#       测试仓须用小写 sha(core.abbrev), 否则 worktree list 行第 2 列不是 7+ 位 hex, 脚本主仓解析失败
mk_fixture() {
  local tmp="$1" main="$2" wt="$3" origin="$4"
  # 临时仓(非主仓)禁用全局 hooksPath, 防本地 hook 干扰(本环境全局 hooksPath 指向真实工作区 scripts)
  git -c core.hooksPath=/dev/null init --bare -q "$origin" 2>/dev/null
  git -c core.hooksPath=/dev/null clone -q "$origin" "$main" 2>/dev/null
  git -C "$main" config user.email selftest@local 2>/dev/null
  git -C "$main" config user.name selftest 2>/dev/null
  git -C "$main" config core.hooksPath /dev/null 2>/dev/null
  git -C "$main" config advice.detachedHead false 2>/dev/null
  git -C "$main" config advice.objectName false 2>/dev/null
  echo c1 > "$main/base.txt"
  git -C "$main" add . && git -C "$main" commit -qm c1 2>/dev/null
  git -C "$main" checkout -qb master 2>/dev/null
  # bare 仓默认 HEAD 指向 master, push 时若 origin 已有 master ref 会输出 "a branch named 'master' already exists"
  # 噪音; stderr 静默不影响 ref 更新
  git -C "$main" push -q origin master 2>/dev/null
  git -C "$main" worktree add -q "$wt" -b wt/task-test master 2>/dev/null
}

# 分支侧提交: 在 wt/task-test 内改 tracked 文件 + commit
# 用法: branch_commit <wt> [files...] — 指定文件则只改该集合(改前若文件不存在则创建)
branch_commit() {
  local wt="$1"; shift
  local files=("$@")
  if [ ${#files[@]} -eq 0 ]; then files=(base.txt new.txt); fi
  local f
  for f in "${files[@]}"; do
    if [ -f "$wt/$f" ]; then echo x-branch >> "$wt/$f"
    else echo new-branch > "$wt/$f"; fi
  done
  git -C "$wt" add . && git -C "$wt" commit -qm branch-changes 2>/dev/null
}

# 主仓侧提交(制造 master 前进): 主仓 master 上真 commit(不推 origin, 本地 master ref 严格前进一格)。
# 用法: main_commit <main> [files...] — 指定文件则只改该集合(默认 base.txt)
main_commit() {
  local main="$1"; shift
  local files=("$@")
  if [ ${#files[@]} -eq 0 ]; then files=(base.txt); fi
  local f
  for f in "${files[@]}"; do echo main-mod >> "$main/$f"; done
  git -C "$main" add . && git -C "$main" commit -qm main-ahead 2>/dev/null
}

# run <cmd...> → 全局: R1=exit码 R2=stdout(单行化) R3=stderr
# 可用 env KEY=VAL 前缀给目标进程注入 env(不经 export, 杜绝跨用例继承外层变量)
run() {
  local out err
  out="$(cd / && "$@" 2>"$ERRF")"; local rc=$?
  err="$(cat "$ERRF")"
  R1=$rc; R2="$(printf '%s\n' "$out" | tr '\n' '|')"; R3="$err"
}

report() {   # <名> <ok:0/1> <详情>
  if [ "$2" = 1 ]; then PASS=$((PASS+1)); printf '%s PASS %s\n' "$1" "$3"
  else FAIL=$((FAIL+1)); printf '%s FAIL %s\n' "$1" "$3"; fi
}

# ---------- SM-01 脏 worktree(未跟踪文件) → exit 3 且 stdout 含 PRECHECK_DIRTY ----------
T1="$(mktemp -d)"
mk_fixture "$T1" "$T1/main" "$T1/task-test" "$T1/origin.git"
branch_commit "$T1/task-test"
echo junk > "$T1/task-test/untracked.txt"
ERRF="$T1/err"
run "$TARGET" "$T1/task-test"
SMOK=0
[ "$R1" = 3 ] && printf '%s' "$R2" | grep -qF 'PRECHECK_DIRTY' && SMOK=1
report SM-01 "$SMOK" "rc=$R1(期望3) PRECHECK_DIRTY=$(printf '%s' "$R2" | grep -qF 'PRECHECK_DIRTY' && echo 在 || echo 缺)"

# ---------- SM-02 干净+无重叠 → exit 0, 含 V6 MERGED, master 有 --no-ff merge commit ----------
T2="$(mktemp -d)"
mk_fixture "$T2" "$T2/main" "$T2/task-test" "$T2/origin.git"
branch_commit "$T2/task-test"
ERRF="$T2/err"
run "$TARGET" "$T2/task-test"
SMOK=0
# 验收标准指定 "git rev-list --merges HEAD..master -c"。git 2.43 无 -c 短选项(仅 --count=<n>),
# 等价判定: merge 后 HEAD = master, HEAD 本身即 merge commit(--merges 过滤后应恰好 1 条)
[ "$R1" = 0 ] && printf '%s' "$R2" | grep -qF '[V6] MERGED' && \
  [ "$(git -C "$T2/main" rev-list --merges HEAD | wc -l)" -eq 1 ] && SMOK=1
report SM-02 "$SMOK" "rc=$R1(期望0) MERGED=$(printf '%s' "$R2" | grep -qF '[V6] MERGED' && echo 在 || echo 缺)"

# ---------- SM-03 已合并: 先主仓 merge --no-ff wt/task-test 再跑 → exit 0 含 ALREADY_MERGED, master 无新 commit ----------
T3="$(mktemp -d)"
mk_fixture "$T3" "$T3/main" "$T3/task-test" "$T3/origin.git"
branch_commit "$T3/task-test"
git -C "$T3/main" merge -q --no-ff wt/task-test
MERGE_HEAD_PRE="$T3/main"
C3_BEFORE="$(git -C "$T3/main" rev-parse HEAD)"
ERRF="$T3/err"
run "$TARGET" "$T3/task-test"
SMOK=0
[ "$R1" = 0 ] && printf '%s' "$R2" | grep -qF 'ALREADY_MERGED' && \
  [ "$(git -C "$T3/main" rev-parse HEAD)" = "$C3_BEFORE" ] && SMOK=1
report SM-03 "$SMOK" "rc=$R1(期望0) ALREADY=$(printf '%s' "$R2" | grep -qF 'ALREADY_MERGED' && echo 在 || echo 缺) master无新commit=$( [ "$(git -C "$T3/main" rev-parse HEAD)" = "$C3_BEFORE" ] && echo 是 || echo 否)"

# ---------- SM-04 master 前进(主仓在分支分叉后直接 commit) → exit 5 含 MASTER_AHEAD; 同夹具 --force → exit 0 MERGED ----------
# 设计: 分支与 master 改不同文件(分支改 new.txt, master 改 base.txt) → 文本合并无冲突 → --force exit 0
T4="$(mktemp -d)"
mk_fixture "$T4" "$T4/main" "$T4/task-test" "$T4/origin.git"
branch_commit "$T4/task-test" new.txt      # 分支只改 new.txt
main_commit "$T4/main" base.txt            # master 只改 base.txt(不同文件 → 无冲突)
ERRF="$T4/err"
run "$TARGET" "$T4/task-test"
SMOK=0
[ "$R1" = 5 ] && printf '%s' "$R2" | grep -qF 'MASTER_AHEAD' && SMOK=1
report SM-04a "$SMOK" "rc=$R1(期望5) MASTER_AHEAD=$(printf '%s' "$R2" | grep -qF 'MASTER_AHEAD' && echo 在 || echo 缺)"
run "$TARGET" "$T4/task-test" --force
SMOK=0
[ "$R1" = 0 ] && printf '%s' "$R2" | grep -qF '[V6] MERGED' && SMOK=1
report SM-04b "$SMOK" "--force rc=$R1(期望0) MERGED=$(printf '%s' "$R2" | grep -qF '[V6] MERGED' && echo 在 || echo 缺)"

# ---------- SM-05 scope 重叠: 主仓未提交文件 = 分支变更文件(相对 merge-base) → exit 4 含 SCOPE_OVERLAP ----------
# 设计: 分支未改 new.txt(用 base.txt 作分支变更); 主仓未提交修改 new.txt 且 base.txt 在分支变更集内
T5="$(mktemp -d)"
mk_fixture "$T5" "$T5/main" "$T5/task-test" "$T5/origin.git"
branch_commit "$T5/task-test" base.txt     # 分支变更集 = {base.txt}(+new.txt? 此处只传 base.txt → 分支仅改 base.txt)
# 注: branch_commit 默认改 base.txt+new.txt, 显式传 base.txt 则只改 base.txt → 分支变更集 = {base.txt}
echo main-dirty > "$T5/main/base.txt.tmp.$$"; cat "$T5/main/base.txt" >> "$T5/main/base.txt.tmp.$$"; echo main-dirty >> "$T5/main/base.txt.tmp.$$"; mv "$T5/main/base.txt.tmp.$$" "$T5/main/base.txt"   # 主仓未提交修改 base.txt
ERRF="$T5/err"
run "$TARGET" "$T5/task-test"
SMOK=0
[ "$R1" = 4 ] && printf '%s' "$R2" | grep -qF 'SCOPE_OVERLAP' && \
  printf '%s' "$R2" | grep -qF 'base.txt' && SMOK=1
report SM-05 "$SMOK" "rc=$R1(期望4) SCOPE_OVERLAP=$(printf '%s' "$R2" | grep -qF 'SCOPE_OVERLAP' && echo 在 || echo 缺) 交集含base.txt=$(printf '%s' "$R2" | grep -qF 'base.txt' && echo 在 || echo 缺)"

# ---------- SM-06 --deploy: env 注入两 slot; s1 预置与 skill 根同内容(可写, 脚本 rm+cp 后 diff 一致) → IDENTICAL;
#           s2 预置不同内容 + 置只读(cp -rL 失败路径) → DRIFT, 整体 exit 6 ----------
# 注: env KEY=VAL 前缀注入(不经 export), 杜绝外层 TASK_PLANNER_DEPLOY_SLOTS 继承污染
# DRIFT 机制说明: 脚本 --deploy 对每个 slot 执行 rm -rf → cp -rL skill-root → diff -rq。DRIFT 在以下路径产生:
#   (a) cp -rL 失败(只读目录) → 打印 [DEPLOY] DRIFT + (b) 重建后 diff -rq 有差异。s2 置只读触发 (a) 路径。
T6="$(mktemp -d)"
mk_fixture "$T6" "$T6/main" "$T6/task-test" "$T6/origin.git"
branch_commit "$T6/task-test"
SKILL_ROOT="$SCRIPT_DIR/.."
cp -rL "$SKILL_ROOT" "$T6/s1"
cp -rL "$SKILL_ROOT" "$T6/s2"
printf 'DRIFT-MARKER\n' > "$T6/s2/SELFTEST-DRIFT.txt"
chmod -R a-w "$T6/s2"
ERRF="$T6/err"
run env TASK_PLANNER_DEPLOY_SLOTS="$T6/s1:$T6/s2" bash "$TARGET" "$T6/task-test" --deploy
SMOK=0
[ "$R1" = 6 ] && printf '%s' "$R2" | grep -qF "[DEPLOY] DRIFT: $T6/s2" && \
  printf '%s' "$R2" | grep -qF "[DEPLOY] IDENTICAL: $T6/s1" && SMOK=1
report SM-06 "$SMOK" "rc=$R1(期望6) s1-IDENTICAL=$(printf '%s' "$R2" | grep -qF "[DEPLOY] IDENTICAL: $T6/s1" && echo 在 || echo 缺) s2-DRIFT=$(printf '%s' "$R2" | grep -qF "[DEPLOY] DRIFT: $T6/s2" && echo 在 || echo 缺)"

# ---------- SM-07 SM-02 通过后: 输出含 [CLEANUP] 行且 worktree 目录仍存在(脚本不自动删) ----------
T7="$(mktemp -d)"
mk_fixture "$T7" "$T7/main" "$T7/task-test" "$T7/origin.git"
branch_commit "$T7/task-test"
ERRF="$T7/err"
run "$TARGET" "$T7/task-test"
SMOK=0
[ "$R1" = 0 ] && printf '%s' "$R2" | grep -qF '[CLEANUP]' && [ -d "$T7/task-test" ] && SMOK=1
report SM-07 "$SMOK" "rc=$R1 CLEANUP行=$(printf '%s' "$R2" | grep -qF '[CLEANUP]' && echo 在 || echo 缺) worktree保留=$([ -d "$T7/task-test" ] && echo 是 || echo 否)"

# ---------- 全量清理: s2 可能处于只读态, 先恢复可写再删; 变量预置防未赋值报错 ----------
T1="${T1:-}"; T2="${T2:-}"; T3="${T3:-}"; T4="${T4:-}"; T5="${T5:-}"
T6="${T6:-}"; T7="${T7:-}"
[ -n "$T6" ] && [ -d "$T6/s2" ] && chmod -R u+w "$T6/s2" 2>/dev/null || true
rm -rf "$T1" "$T2" "$T3" "$T4" "$T5" "$T6" "$T7"

# 统计口径: 7 用例(SM-04 拆 a/b 两子断言, 其余 6 用例各 1 断言, 共 8 断言行输出)。
# Total 行恒按 7 用例口径: 全绿 → Total: 7 PASS=7 FAIL=0(与任务验收标准一致)
PASS_CASES=$(( 7 - FAIL ))
[ "$FAIL" -eq 0 ] && PASS_CASES=7
printf 'Total: 7 PASS=%d FAIL=%d\n' "$PASS_CASES" "$FAIL"
exit $((FAIL > 0))
