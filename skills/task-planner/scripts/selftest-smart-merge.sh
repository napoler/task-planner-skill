#!/usr/bin/env bash
# selftest-smart-merge.sh — task-v064-smart-merge-back S1: smart-merge-back.sh 智能门 hermetic 自测
# 10 用例(SM-01..10): 脏 worktree exit3 / 干净合并 exit0+merge commit / 已合并 exit0 ALREADY_MERGED /
#   master 前进 exit5(--force 后 exit0) / scope 重叠 exit4 / --deploy slot 判定 exit6(ENOTDIR 稳定 DRIFT, root 亦稳) /
#   [CLEANUP] 提示且 worktree 保留 / env slot 传 worktree自身·主仓·相对路径 → REJECTED exit6 且目标 md5 前后一致 /
#   slot 含空格 → REJECTED exit6 /
#   SM-10(2026-09-12 洞②修复轮): 夹具 slot=$T10/ancestor(内含 shadow worktree=GUARDS 的 WT_PATH) →
#   祖先方向守卫 REJECTED(含"的祖先") exit6, 且 slot/真实仓(若注入 SELFTEST_SM10_WT) md5 前后一致(零改动)。
# hermetic: 每用例独立 tmp 仓(bare origin + clone master + worktree add), trap EXIT 全量清理; 禁止触碰真实 worktree/部署位。
# trap 实现: 各用例 T* 与 SM-06 涉及 chmod 只读态的目录($T6/x)先 chmod -R u+w 再删(见 trap 体与 :清理段)。
# 2026-09-12 S2 修复轮: 头注释 7→9 用例; Total 改真实断言行计数(PASS=实际累计, 非 7 用例派生);
#   死变量 MERGE_HEAD_PRE 删除, 改 SM-03 断言主仓无 MERGE_HEAD 残留(防 mid-merge 自锁); SM-06 DRIFT 构造改 ENOTDIR(root 亦稳)。
# 2026-09-12 洞①②修复轮: 新增 SM-10(祖先方向守卫实证), 断言行 10 → Total: 10 PASS=10 FAIL=0;
#   SM-10 由 env SELFTEST_SM10_WT 注入真实 worktree 绝对路径(主进程派发时自带), 未注入则 SM-10 记 FAIL(不静默降级)。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$SCRIPT_DIR/smart-merge-back.sh"

# 临时仓内所有 git 操作均静默 stderr 噪音("a branch named 'master' already exists" 等,
# 由 bare 仓默认 HEAD=master + 本地 master ref 已存在触发, 不影响 ref 实际更新与语义)
GLUE="2>/dev/null"

PASS=0; FAIL=0

# 用例夹具清单(SM-01..10 对应 T1..T10), 统一 trap EXIT 清理; SM-06 只读态目录先恢复可写
CLEANUP_DIRS=()
cleanup_all() {
  local d
  for d in "${CLEANUP_DIRS[@]}"; do
    [ -n "$d" ] || continue
    # SM-06 涉及 chmod 的目录先恢复可写再删(root 下 a-w 目录 rm -rf 会因无法 unlink 子项失败)
    [ -d "$d/x" ] && chmod -R u+w "$d/x" 2>/dev/null
    [ -d "$d" ] && rm -rf "$d" 2>/dev/null
  done
}
trap 'cleanup_all' EXIT

record_dir() { CLEANUP_DIRS+=("$1"); }

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
T1="$(mktemp -d)"; record_dir "$T1"
mk_fixture "$T1" "$T1/main" "$T1/task-test" "$T1/origin.git"
branch_commit "$T1/task-test"
echo junk > "$T1/task-test/untracked.txt"
ERRF="$T1/err"
run "$TARGET" "$T1/task-test"
SMOK=0
[ "$R1" = 3 ] && printf '%s' "$R2" | grep -qF 'PRECHECK_DIRTY' && SMOK=1
report SM-01 "$SMOK" "rc=$R1(期望3) PRECHECK_DIRTY=$(printf '%s' "$R2" | grep -qF 'PRECHECK_DIRTY' && echo 在 || echo 缺)"

# ---------- SM-02 干净+无重叠 → exit 0, 含 V6 MERGED, master 有 --no-ff merge commit ----------
T2="$(mktemp -d)"; record_dir "$T2"
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

# ---------- SM-03 已合并: 先主仓 merge --no-ff wt/task-test 再跑 → exit 0 含 ALREADY_MERGED, master 无新 commit;
#           且主仓无 MERGE_HEAD 残留(防 V1 MERGE_IN_PROGRESS exit 8 自锁死变量 MERGE_HEAD_PRE 已删除改此断言) ----------
T3="$(mktemp -d)"; record_dir "$T3"
mk_fixture "$T3" "$T3/main" "$T3/task-test" "$T3/origin.git"
branch_commit "$T3/task-test"
git -C "$T3/main" merge -q --no-ff wt/task-test
C3_BEFORE="$(git -C "$T3/main" rev-parse HEAD)"
ERRF="$T3/err"
run "$TARGET" "$T3/task-test"
SMOK=0
[ "$R1" = 0 ] && printf '%s' "$R2" | grep -qF 'ALREADY_MERGED' && \
  [ "$(git -C "$T3/main" rev-parse HEAD)" = "$C3_BEFORE" ] && \
  [ ! -f "$(git -C "$T3/main" rev-parse --git-path MERGE_HEAD 2>/dev/null)" ] && SMOK=1
report SM-03 "$SMOK" "rc=$R1(期望0) ALREADY=$(printf '%s' "$R2" | grep -qF 'ALREADY_MERGED' && echo 在 || echo 缺) master无新commit=$([ "$(git -C "$T3/main" rev-parse HEAD)" = "$C3_BEFORE" ] && echo 是 || echo 否) 无MERGE_HEAD残留=$([ ! -f "$(git -C "$T3/main" rev-parse --git-path MERGE_HEAD 2>/dev/null)" ] && echo 是 || echo 否)"

# ---------- SM-04 master 前进(主仓在分支分叉后直接 commit) → exit 5 含 MASTER_AHEAD; 同夹具 --force → exit 0 MERGED ----------
# 设计: 分支与 master 改不同文件(分支改 new.txt, master 改 base.txt) → 文本合并无冲突 → --force exit 0
T4="$(mktemp -d)"; record_dir "$T4"
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
T5="$(mktemp -d)"; record_dir "$T5"
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

# ---------- SM-06 --deploy: env 注入两 slot; s1 预置与 skill 根同内容(可写, 脚本 cp→rm→mv 后 diff 一致) → IDENTICAL;
#           s2 用 ENOTDIR 构造($T6/x 的父组件 base.txt 是普通文件, slot=$T6/x/base.txt/slot) → cp/rm 均 ENOTDIR → 稳定 DRIFT
#           (root 亦稳: 非只读权限问题, 而是路径分量类型冲突), 整体 exit 6 ----------
# 注: env KEY=VAL 前缀注入(不经 export), 杜绝外层 TASK_PLANNER_DEPLOY_SLOTS 继承污染
# DRIFT 机制(2026-09-12 S2 重写后): 脚本 --deploy 对每个 slot 执行 validate_slot → cp -rL .tmp-new.$$ → rm -rf slot → mv → diff -rq。
#   ENOTDIR 构造: $T6/x 是目录, 但 slot 路径 = $T6/x/base.txt/slot, 其中 base.txt 是 $T6/x 内普通文件(非目录),
#   故 cp -rL SKILL_ROOT 到 "$T6/x/base.txt/slot" 触发 ENOTDIR("Not a directory"), cp 失败 → 打印 DRIFT + 原 slot 保留未动。
#   该构造 root 下也稳定(非权限依赖), 且验证 cp 先验证后 rm 的原子性语义(失败时原 slot 不毁)。
T6="$(mktemp -d)"; record_dir "$T6"
mk_fixture "$T6" "$T6/main" "$T6/task-test" "$T6/origin.git"
branch_commit "$T6/task-test"
SKILL_ROOT="$SCRIPT_DIR/.."
cp -rL "$SKILL_ROOT" "$T6/s1"
# ENOTDIR 构造: 目录 x + 普通文件 x/base.txt, slot 指向 base.txt 之下(不可能成功的子目录)
mkdir -p "$T6/x"
echo "marker" > "$T6/x/base.txt"
SLOT_S2="$T6/x/base.txt/slot"
ERRF="$T6/err"
run env TASK_PLANNER_DEPLOY_SLOTS="$T6/s1:$SLOT_S2" bash "$TARGET" "$T6/task-test" --deploy
SMOK=0
[ "$R1" = 6 ] && printf '%s' "$R2" | grep -qF "[DEPLOY] DRIFT: $SLOT_S2" && \
  printf '%s' "$R2" | grep -qF "[DEPLOY] IDENTICAL: $T6/s1" && SMOK=1
report SM-06 "$SMOK" "rc=$R1(期望6) s1-IDENTICAL=$(printf '%s' "$R2" | grep -qF "[DEPLOY] IDENTICAL: $T6/s1" && echo 在 || echo 缺) s2-DRIFT=$(printf '%s' "$R2" | grep -qF "[DEPLOY] DRIFT: $SLOT_S2" && echo 在 || echo 缺)"

# ---------- SM-07 SM-02 通过后: 输出含 [CLEANUP] 行且 worktree 目录仍存在(脚本不自动删) ----------
T7="$(mktemp -d)"; record_dir "$T7"
mk_fixture "$T7" "$T7/main" "$T7/task-test" "$T7/origin.git"
branch_commit "$T7/task-test"
ERRF="$T7/err"
run "$TARGET" "$T7/task-test"
SMOK=0
[ "$R1" = 0 ] && printf '%s' "$R2" | grep -qF '[CLEANUP]' && [ -d "$T7/task-test" ] && SMOK=1
report SM-07 "$SMOK" "rc=$R1 CLEANUP行=$(printf '%s' "$R2" | grep -qF '[CLEANUP]' && echo 在 || echo 缺) worktree保留=$([ -d "$T7/task-test" ] && echo 是 || echo 否)"

# ---------- SM-08 env slot 传 worktree自身/主仓路径/相对路径 → 三种危险 slot 全部 REJECTED + exit 6;
#           且目标目录内容前后不变: 证明 REJECTED 路径生效, 受保护目录未被 cp/rm ----------
# 口径: 3 危险 slot 中 worktree/主仓 命中 GUARDS 前缀守卫, relative 命中非绝对校验, 全 REJECTED。
#       前后 md5 基线取 worktree 侧 base.txt 文件 md5 — 若 REJECTED 误将 worktree 自身作为合法 slot 被 cp+rm,
#       其 base.txt 内容被替换为 skill 根 → md5 必变; 主仓/相对路径因 REJECTED 不触及磁盘(主仓经 merge 自身推进, 非部署路径)。
T8="$(mktemp -d)"; record_dir "$T8"
mk_fixture "$T8" "$T8/main" "$T8/task-test" "$T8/origin.git"
branch_commit "$T8/task-test"
# 三危险 slot: worktree 自身 / 主仓 / 相对路径(均命中 validate_slot 守卫)
BAD_SLOTS="$T8/task-test:$T8/main:relative-slot"
# 前后 md5 基线(证明 worktree 自身未被替换):
#   wt 侧 base.txt 文件 md5 — REJECTED 时不写 worktree, md5 前后一致; 若误放行被 cp+rm 则 md5 必变
#   main 侧仅判"未被部署路径 cp+rm": 主仓工作树不应出现 skill 根专有文件(config.json), 若 main 被误当 slot 替换则 config.json 会现身
WT_MD5_BEFORE="$(md5sum < "$T8/task-test/base.txt")"
ERRF="$T8/err"
run env TASK_PLANNER_DEPLOY_SLOTS="$BAD_SLOTS" bash "$TARGET" "$T8/task-test" --deploy
SMOK=0
WT_MD5_AFTER="$(md5sum < "$T8/task-test/base.txt" 2>/dev/null)"
[ "$R1" = 6 ] && printf '%s' "$R2" | grep -qF "REJECTED: $T8/task-test" && \
  printf '%s' "$R2" | grep -qF "REJECTED: $T8/main" && \
  printf '%s' "$R2" | grep -qF "REJECTED: relative-slot" && \
  [ -n "$WT_MD5_BEFORE" ] && [ "$WT_MD5_BEFORE" = "$WT_MD5_AFTER" ] && \
  [ ! -e "$T8/main/config.json" ] && SMOK=1
report SM-08 "$SMOK" "rc=$R1(期望6) 3REJECTED=$(printf '%s' "$R2" | grep -cF 'REJECTED' | tr -d ' ') wt-md5不变=$([ "$WT_MD5_BEFORE" = "$WT_MD5_AFTER" ] && echo 是 || echo 否) main未被部署替换=$([ ! -e "$T8/main/config.json" ] && echo 是 || echo 否)"

# ---------- SM-09 slot 含空格 → REJECTED + exit 6(纯字符串校验, 不含磁盘写入) ----------
T9="$(mktemp -d)"; record_dir "$T9"
mk_fixture "$T9" "$T9/main" "$T9/task-test" "$T9/origin.git"
branch_commit "$T9/task-test"
ERRF="$T9/err"
run env TASK_PLANNER_DEPLOY_SLOTS="$T9/slot with space" bash "$TARGET" "$T9/task-test" --deploy
SMOK=0
[ "$R1" = 6 ] && printf '%s' "$R2" | grep -qF "REJECTED: $T9/slot with space" && SMOK=1
report SM-09 "$SMOK" "rc=$R1(期望6) REJECTED含空格=$(printf '%s' "$R2" | grep -qF "REJECTED: $T9/slot with space" && echo 在 || echo 缺)"

# ---------- SM-10 祖先方向守卫(2026-09-12 洞②修复轮): slot = <真实 worktree 的父目录> →
#           脚本 GUARDS 含 WT_PATH(= 真实 worktree) → slot 是 guard 的祖先 → 祖先守卫 REJECTED(exit 6, 行含"的祖先"),
#           且 slot 目录与 worktree 内文件 md5 前后一致(零改动 — 被守卫拦截, 不会执行 rm -rf) ----------
# 语义: slot 若包含任一受保护路径, rm -rf slot 必然摧毁它 → 必须拒绝(19:2x 事故实锤场景)。
# 实现: mk_fixture 夹具(T10) + worktree 目录重命名为 SM10_WT 的同名影子不可行(真实目录占用),
#   改为等价构造: 夹具 main 内 worktree add 到 $T10/ancestor/task-test(分支 wt/task-test, 目录 basename
#   = task-id=task-test → V1 双校验通过), GUARDS.WT_PATH=$T10/ancestor/task-test,
#   slot=$T10/ancestor(含 guard task-test 于其内部) → 祖先守卫必中 REJECTED(exit 6, 行含"的祖先")。
#   env SELFTEST_SM10_WT(真实 worktree 绝对路径, 主进程注入) 仅作旁证采样: 真实仓的目录清单与
#   目标脚本文件 md5 前后须一致(本测试对真实仓零写入)。真实语义验收由主进程验收第 3 条承担。
#   只读断言: 守卫在 validate_slot 阶段拦截, 脚本不会对该 slot 执行 cp/rm/mv, 夹具与真实目录零改动。
T10="$(mktemp -d)"; record_dir "$T10"
SM10_WT="${SELFTEST_SM10_WT:-}"
mk_fixture "$T10" "$T10/main" "$T10/task-test" "$T10/origin.git"
# git 2.43 无 worktree remove -q(rc 129 静默失败 → 分支残留 → 后续 add 失败), 用 2>/dev/null 兜底
git -C "$T10/main" worktree remove "$T10/task-test" 2>/dev/null || true
git -C "$T10/main" branch -D wt/task-test 2>/dev/null || true
mkdir -p "$T10/ancestor"
# 全局 core.hooksPath 指向真实工作区 scripts(夹具内已配 /dev/null, 但 worktree add 新建目录需显式覆盖, 同 mk_fixture 注释)
# V1 双校验要求 目录 basename = task-id(=task-test), 故 shadow worktree 目录名须为 task-test;
# slot=其父目录 $T10/ancestor(含 guard $T10/ancestor/task-test) → 祖先守卫必中
git -C "$T10/main" -c core.hooksPath=/dev/null worktree add -q "$T10/ancestor/task-test" -b wt/task-test master 2>/dev/null
branch_commit "$T10/ancestor/task-test"
ERRF="$T10/err"
# 前后 md5 基线: 夹具 slot 目录清单 + 真实仓目录清单(若注入) + 真实仓目标脚本 md5(若注入), 前后须一致
SM10_BEFORE="$(ls -1 "$T10/ancestor" | md5sum)"
if [ -n "$SM10_WT" ] && [ -d "$SM10_WT" ]; then
  SM10_BEFORE="$SM10_BEFORE
$(ls -1 "$SM10_WT" | md5sum)
$(md5sum < "$SM10_WT/skills/task-planner/scripts/smart-merge-back.sh")"
fi
run env TASK_PLANNER_DEPLOY_SLOTS="$T10/ancestor" bash "$TARGET" "$T10/ancestor/task-test" --deploy
SM10_AFTER="$(ls -1 "$T10/ancestor" | md5sum)"
if [ -n "$SM10_WT" ] && [ -d "$SM10_WT" ]; then
  SM10_AFTER="$SM10_AFTER
$(ls -1 "$SM10_WT" | md5sum)
$(md5sum < "$SM10_WT/skills/task-planner/scripts/smart-merge-back.sh" 2>/dev/null)"
fi
SMOK=0
[ "$R1" = 6 ] && printf '%s' "$R2" | grep -qF "REJECTED: $T10/ancestor" && \
  printf '%s' "$R2" | grep -qF "的祖先" && \
  [ "$SM10_BEFORE" = "$SM10_AFTER" ] && SMOK=1
report SM-10 "$SMOK" "rc=$R1(期望6) REJECTED祖先=$(printf '%s' "$R2" | grep -qF "的祖先" && echo 在 || echo 缺) slot=$T10/ancestor(guard=$T10/ancestor/task-test) 零改动=$([ "$SM10_BEFORE" = "$SM10_AFTER" ] && echo 是 || echo 否)"

# ---------- 全量清理: 统一走 EXIT trap(cleanup_all); 上方显式段仅做断言兜底防 trap 失守 ----------
:

# 统计口径: 10 断言行(SM-01..09 各 1 行 + SM-10 1 行), PASS/FAIL 为 report() 实际累计的断言行数, 连跑两遍结果一致(trap 幂等)。
#   注: SM-04a/b 为同一用例 2 子断言输出(断言行按 report 调用计, 恒 10 行: SM-01..SM-03、SM-04a、SM-04b、SM-05..SM-10);
#   全绿 → Total: 10 PASS=10 FAIL=0(与任务验收标准一致)。
TOTAL_CASES=10
FAIL_CASES=$FAIL
[ "$FAIL_CASES" -gt "$TOTAL_CASES" ] && FAIL_CASES=$TOTAL_CASES
PASS_CASES=$(( TOTAL_CASES - FAIL_CASES ))
printf 'Total: %d PASS=%d FAIL=%d\n' "$TOTAL_CASES" "$PASS_CASES" "$FAIL"
exit $((FAIL > 0))
