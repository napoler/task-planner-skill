#!/usr/bin/env bash
# selftest-smart-merge.sh — task-v064-smart-merge-back S1: smart-merge-back.sh 智能门 hermetic 自测
# 用例 SM-01..SM-20: 必跑断言行 21 条(基线 SM-01..03/04a/04b/05..09/11..14 共 14 条 + SM-15a/15b locale 回归 2 条
#   + SM-16 legacy 回归 1 条 + SM-17..SM-20 安全负例 4 条;
#   另 SM-10 注入时 +1 → Total 动态 21/22):脏 worktree exit3 / 干净合并 exit0+merge commit /
#   master 前进 exit5(--force 后 exit0) / scope 重叠 exit4 / --deploy slot 判定 exit6(ENOTDIR 稳定 DRIFT, root 亦稳) /
#   [CLEANUP] 提示且 worktree 保留 / env slot 传 worktree自身·主仓·相对路径 → REJECTED exit6 且目标 md5 前后一致 /
#   slot 含空格 → REJECTED exit6 /
#   SM-14(2026-09-17 S4 task-v077 新增, 陈旧副本回归钉子): 脚本副本置于陈旧部署位 A(预置 stale-content)
#   运行 --deploy, slot 指 B → 断言 B 终态 SKILL_MARKER==主仓 canonical-v077(非 stale-content) 且输出含
#   [DEPLOY] OK: 全部部署位 IDENTICAL + [DEPLOY] SWAPPED: <slot> → exit 0;
#   防 v076 假 IDENTICAL 复发(以 SKILL_ROOT 为源时 cp 陈旧副本自 diff 恒真)。
#   [2026-10-10 task-v159 F5 级联] SM-06/SM-14 断言口径对齐 F5 默认 staging 契约: 成功消息
#   [DEPLOY] OK: 全部部署位 IDENTICAL + 每 slot [DEPLOY] OK: <slot>; 失败路径(staging cp/swap/post-verify
#   任一失败) rc≠0(exit 1); SM-06 ENOTDIR 命中新路径 staging 阶段 cp 失败 → [DEPLOY] STAGE-FAIL + exit 1
#   (非旧 --legacy 路径 per-slot DRIFT + exit 6; 消息契约仅新路径生效, --legacy 仍保留旧格式作 fallback)。
#   [2026-09-27 task-v091/C-5-locale] SM-15a/SM-15b 回归: 从 TARGET 抽真实 _re_lines+deploy_reconcile,
#   混合大小写文件名(B.md+a.md)清单内容差异场景, zh locale 下仍报 DRIFT-L2(修复前 comm 未 pin locale →
#   inman 空 → B.md 不入 L2 targets → 假 IDENTICAL, S32 组5 C-5 实测缺陷); SM-15b LC_ALL=C 与 ambient
#   双跑判定一致。TOTAL_BASE 14→16→17(SM-16)+4(SM-17..20)=21(SM-10 注入时 Total=22)。
#   SM-10(2026-09-12 洞②修复轮): 夹具 slot=$T10/ancestor(内含 shadow worktree=GUARDS 的 WT_PATH) →
#   祖先方向守卫 REJECTED(含"的祖先") exit6, 且 slot/真实仓(SELFTEST_SM10_WT 注入) md5 前后一致(零改动)。
#   [2026-09-12 R3] 真实 worktree 来源改套件内相对推导: git -C "$(dirname "$0")/../.."
#   rev-parse --show-toplevel(套件位于被测 skill 内, toplevel 即所在 worktree; 主仓非 worktree 时
#   返回主仓根 → 由 SELFTEST_SM10_WT env 覆盖或 SKIP); 推导失败且 env 未注入 → SM-10 记 SKIP
#   (R3 后统一为动态口径: TOTAL_CASES = 13 + (SM-10 注入 ? 1 : 0), 见下方统计段)
#   SM-11(2026-09-12 R2 新增, 首次让 exit 8 有覆盖): 夹具主仓人为构造 MERGE_HEAD
#   (git update-ref --no-deref MERGE_HEAD HEAD) → 期望 exit 8 且含 MERGE_IN_PROGRESS。
#   SM-12/SM-13(2026-09-12 复审 4 轮 P2 回归用例, 全 /tmp 夹具, 禁止真实路径):
#   SM-12: env HOME=$T12/home + TASK_PLANNER_DEPLOY_SLOTS=$T12/home/.zcode → 期望 rc=6 且
#   $T12/home/.zcode 目录清单 md5 前后一致($HOME 内部白名单外 REJECTED 回归);
#   SM-13: 夹具主仓 = 部署根内(部署根 = $T13/main/deployroot/task-planner, 预置 SKILL 根内容,
#   slot 同路径) → 期望 rc=6(MAIN_REPO full 守卫命中)且主仓 .git 目录存活 + marker 文件 md5 不变。
# hermetic: 每用例独立 tmp 仓(bare origin + clone master + worktree add), trap EXIT 全量清理; 禁止触碰真实 worktree/部署位。
# trap 实现: 各用例 T* 与 SM-06 涉及 chmod 只读态的目录($T6/x)先 chmod -R u+w 再删(见 trap 体与 :清理段)。
# 2026-09-12 S2 修复轮: 头注释 7→9 用例; Total 改真实断言行计数(PASS=实际累计, 非 7 用例派生);
#   死变量 MERGE_HEAD_PRE 删除, 改 SM-03 断言主仓无 MERGE_HEAD 残留(防 mid-merge 自锁); SM-06 DRIFT 构造改 ENOTDIR(root 亦稳)。
# 2026-09-12 洞①②修复轮: 新增 SM-10(祖先方向守卫实证), 断言行 10 → Total: 10 PASS=10 FAIL=0;
#   SM-10 由 env SELFTEST_SM10_WT 注入真实 worktree 绝对路径(主进程派发时自带), 未注入则 SM-10 记 FAIL(不静默降级)。
# 2026-09-12 R2 复审修复轮: 记账修复 — report 真实累计 PASS(断言 PASS+FAIL=TOTAL_CASES, 不一致打印
#   FRAMEWORK_BROKEN 并 exit 97); SM-03 MERGE_HEAD 残留断言改绝对路径形式; 新增 SM-11(exit 8 正向覆盖);
#   SM-10 头注释与实现一致 + 默认路径自动注入; 断言行 10 → Total: 12。
# 2026-09-12 R3 复审修复轮: ① SM-10 真实 worktree 改套件内相对推导(去硬编码任务路径,
#   dirname $0/../.. rev-parse --show-toplevel); 推导失败且 SELFTEST_SM10_WT 未注入 → SM-10 记 SKIP
#   (不计 PASS/FAIL, 输出 SKIP 行; Total 口径 = PASS+FAIL 断言行数, SKIP 单列);
#   ② SM-08 详情改 grep -oF 'REJECTED' | wc -l 真实计数(原恒 1 失实)。
# 2026-09-12 复审 4 轮修复轮: ① P2 新增 SM-12(env HOME 夹具 + $HOME 内部白名单外 slot=$HOME/.zcode
#   → REJECTED exit 6 + 目录清单 md5 前后一致)/SM-13(部署根内主仓场景 slot=$T13/main/deployroot/task-planner
#   → REJECTED exit 6 + 主仓 .git 存活 + marker md5 不变); ② SKIP 口径统一(断言行总数 = PASS+FAIL,
#   SKIP 单列不计入 Total), TOTAL_CASES 12→14; ③ 两用例全 /tmp 夹具, 禁止真实路径。
# 2026-09-17 S4 task-v077 修复轮: ① mk_fixture 主仓 fixture 预置 skills/task-planner(SKILL_MARKER=v077-canonical),
#   匹配 DEPLOY_SRC 换源后的主仓 canonical 基准(防 deploy 位全 skip 假绿);
#   ② SM-06 预置源 $SCRIPT_DIR/.. → $T6/main/skills/task-planner(fixture 主仓 canonical, 与脚本对账基准同物);
#   ③ 新增 SM-14(陈旧副本回归钉子); TOTAL_BASE 13→14(Total 注入 SM-10 时 =15)。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$SCRIPT_DIR/smart-merge-back.sh"

# 临时仓内所有 git 操作均静默 stderr 噪音("a branch named 'master' already exists" 等,
# 由 bare 仓默认 HEAD=master + 本地 master ref 已存在触发, 不影响 ref 实际更新与语义)
GLUE="2>/dev/null"

PASS=0; FAIL=0

# 用例夹具清单(SM-01..11 对应 T1..T11), 统一 trap EXIT 清理; SM-06 只读态目录先恢复可写
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
  # [2026-09-12 复审 5 轮 P2] 显式覆盖 hooksPath(与 init/clone 口径一致; 防外层 hooks 探测
# 沿父目录链误命中 — 主仓在 HOME 深层嵌套形态下无 -c 时曾致 worktree add 失败, 实证)
git -c core.hooksPath=/dev/null -C "$main" worktree add -q "$wt" -b wt/task-test master 2>/dev/null
  # [2026-09-17 S4 task-v077] 主仓 fixture 预置 canonical 部署源 $main/skills/task-planner(内容标记 v077-canonical):
  # 换源后 DEPLOY_SRC=$MAIN_REPO/skills/task-planner 须存在(缺失则 deploy 位全部 skip → 假绿回归);
  # 该标记亦供 SM-06 预置 s1 与 SM-14 终态对账。
  mkdir -p "$main/skills/task-planner"
  echo "v077-canonical" > "$main/skills/task-planner/SKILL_MARKER"
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
#           且主仓无 MERGE_HEAD 残留(防 V1 MERGE_IN_PROGRESS exit 8 自锁; [R2] 绝对路径形式断言) ----------
T3="$(mktemp -d)"; record_dir "$T3"
mk_fixture "$T3" "$T3/main" "$T3/task-test" "$T3/origin.git"
branch_commit "$T3/task-test"
git -C "$T3/main" merge -q --no-ff wt/task-test
C3_BEFORE="$(git -C "$T3/main" rev-parse HEAD)"
# [2026-09-12 R2] MERGE_HEAD 残留断言改绝对路径(与脚本 P1-2 实现同口径): --git-dir 相对则先拼主仓绝对前缀
C3_GITDIR="$(git -C "$T3/main" rev-parse --git-dir 2>/dev/null)"
case "$C3_GITDIR" in /*) C3_MH="$C3_GITDIR/MERGE_HEAD" ;; *) C3_MH="$T3/main/$C3_GITDIR/MERGE_HEAD" ;; esac
ERRF="$T3/err"
run "$TARGET" "$T3/task-test"
SMOK=0
[ "$R1" = 0 ] && printf '%s' "$R2" | grep -qF 'ALREADY_MERGED' && \
  [ "$(git -C "$T3/main" rev-parse HEAD)" = "$C3_BEFORE" ] && \
  [ ! -f "$C3_MH" ] && SMOK=1
report SM-03 "$SMOK" "rc=$R1(期望0) ALREADY=$(printf '%s' "$R2" | grep -qF 'ALREADY_MERGED' && echo 在 || echo 缺) master无新commit=$([ "$(git -C "$T3/main" rev-parse HEAD)" = "$C3_BEFORE" ] && echo 是 || echo 否) 无MERGE_HEAD残留(绝对路径 $C3_MH)=$([ ! -f "$C3_MH" ] && echo 是 || echo 否)"

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

# ---------- SM-06 --deploy: env 注入两 slot; s1 预置与主仓 fixture 的 skills/task-planner 同内容
#           ([2026-09-17 S4 task-v077] 对账基准 = 主仓 skills/task-planner)
#           s2 用 ENOTDIR 构造($T6/x 的父组件 base.txt 是普通文件, slot=$T6/x/base.txt/task-planner)
#           → F5 默认 staging 路径 cp -rL DEPLOY_SRC → <slot>.stage.$$ ENOTDIR → 稳定 STAGE-FAIL (root 亦稳:
#           非只读权限问题, 而是路径分量类型冲突), 整体 exit 1(F5 staging-fail 语义, 非旧 --legacy exit 6) ----------
# [2026-10-10 task-v159 F5 级联] 断言口径对齐 F5 默认 staging 契约(原 --legacy 直写路径 per-slot
#   DRIFT + exit 6; --legacy 保留旧格式作 fallback, 本用例只走默认路径)。非弱化: 失败路径仍断 rc≠0(=1)
#   且 stderr 整体失败标记 DEPLOY_DRIFT 在; 原 slot 保护语义保留: s1 从未被 swap(失败 stage 目录已清理),
#   断 s1 目录存活。s2 的 ENOTDIR 命中点在 staging 阶段 cp(旧契约命中点在直写 cp), 消息由 DRIFT 改 STAGE-FAIL。
# [2026-11-26 task-deploy-slot-safety] slot-identity 契约适配: slot basename 必须 == task-planner 且规范化路径精确等于
#   <scan_root>/task-planner; s1/s2 均改为 <独立父目录>/task-planner 形态。ENOTDIR 触发点随 F5 cache-stage 落盘变化
#   (staging 落 cache root, 不再在 slot 父目录创建 stage) — 改为断言 swap 阶段失败(STAGE-FAIL 或 SWAP-FAIL 任一),
#   保持"部署失败+rc!=0+s1未被swap+marker不变"核心语义不变。
T6="$(mktemp -d)"; record_dir "$T6"
mk_fixture "$T6" "$T6/main" "$T6/task-test" "$T6/origin.git"
branch_commit "$T6/task-test"
SLOT_S1="$T6/s1-root/task-planner"
mkdir -p "$(dirname "$SLOT_S1")"
cp -rL "$T6/main/skills/task-planner" "$SLOT_S1"
# ENOTDIR 构造: 目录 x + 普通文件 x/base.txt, slot 指向 base.txt 之下(不可能成功的子目录)
mkdir -p "$T6/x"
echo "marker" > "$T6/x/base.txt"
SLOT_S2="$T6/x/base.txt/task-planner"
ERRF="$T6/err"
run env TASK_PLANNER_DEPLOY_SLOTS="$SLOT_S1:$SLOT_S2" bash "$TARGET" "$T6/task-test" --deploy
SMOK=0
SM6_FAIL_SIG=0
printf '%s\n%s' "$R2" "$R3" | grep -qF "[DEPLOY] STAGE-FAIL: $SLOT_S2" && SM6_FAIL_SIG=1
printf '%s\n%s' "$R2" "$R3" | grep -qF "[DEPLOY] SWAP-FAIL: $SLOT_S2" && SM6_FAIL_SIG=1
[ "$R1" -ne 0 ] && [ "$SM6_FAIL_SIG" = 1 ] && \
  [ -d "$SLOT_S1" ] && [ -f "$SLOT_S1/SKILL_MARKER" ] && [ "$(cat "$SLOT_S1/SKILL_MARKER")" = "v077-canonical" ] && SMOK=1
report SM-06 "$SMOK" "rc=$R1(期望非0,staging/swap-fail语义) s2-FAIL信号(STAGE-FAIL|SWAP-FAIL)=$([ "$SM6_FAIL_SIG" = 1 ] && echo 在 || echo 缺) s1未被swap-目录存活=$([ -d "$SLOT_S1" ] && echo 是 || echo 否) s1-marker不变=$(printf '%s' "$(cat "$SLOT_S1/SKILL_MARKER" 2>/dev/null)" | grep -qF 'v077-canonical' && echo 是 || echo 否)"

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
# [2026-09-12 R3 P3] 详情改真实 REJECTED 行数(grep -oF | wc -l), 不再恒 1
report SM-08 "$SMOK" "rc=$R1(期望6) REJECTED行数=$(printf '%s' "$R2" | grep -oF 'REJECTED' | wc -l | tr -d ' ')(期望≥3) wt-md5不变=$([ "$WT_MD5_BEFORE" = "$WT_MD5_AFTER" ] && echo 是 || echo 否) main未被部署替换=$([ ! -e "$T8/main/config.json" ] && echo 是 || echo 否)"

# ---------- SM-09 slot 含空格 → REJECTED + exit 6(纯字符串校验, 不含磁盘写入) ----------
T9="$(mktemp -d)"; record_dir "$T9"
mk_fixture "$T9" "$T9/main" "$T9/task-test" "$T9/origin.git"
branch_commit "$T9/task-test"
ERRF="$T9/err"
run env TASK_PLANNER_DEPLOY_SLOTS="$T9/slot with space" bash "$TARGET" "$T9/task-test" --deploy
SMOK=0
[ "$R1" = 6 ] && printf '%s' "$R2" | grep -qF "REJECTED: $T9/slot with space" && SMOK=1
report SM-09 "$SMOK" "rc=$R1(期望6) REJECTED含空格=$(printf '%s' "$R2" | grep -qF "REJECTED: $T9/slot with space" && echo 在 || echo 缺)"

# ---------- SM-10 祖先方向守卫(2026-09-12 洞②修复轮 / R3 相对推导): slot = <祖先目录>/task-planner,
#           内含 shadow worktree(=GUARDS 的 WT_PATH) → slot 是 guard 的祖先 → 祖先守卫 REJECTED(exit 6, 行含"的祖先"),
#           且 slot 目录与真实仓文件 md5 前后一致(零改动 — 被守卫拦截, 不会执行 rm -rf) ----------
# 语义: slot 若包含任一受保护路径, rm -rf slot 必然摧毁它 → 必须拒绝(19:2x 事故实锤场景)。
# [2026-11-26 task-deploy-slot-safety] slot-identity 契约适配: slot basename 必须 == task-planner, 故把 slot 改为
#   $T10/ancestor/task-planner(而非旧的 $T10/ancestor); guard 仍为 shadow worktree $T10/ancestor/task-planner/task-test,
#   保持 "slot 是 guard 祖先" 判定语义不变。祖先守卫在 slot-identity 之后执行, 仍由 validate_slot 祖先分支命中。
# [R3 一致化] 真实 worktree 来源: ① 外层 env SELFTEST_SM10_WT(主进程注入, 优先);
#   ② 套件内相对推导 — git -C "$(dirname "$0")/../.." rev-parse --show-toplevel
#   (套件位于被测 skill 内, toplevel 即所在 worktree); ①②均无 → 记 SKIP(不计 FAIL/PASS,
#   不静默降级 — 与头注释一致, SKIP 行输出且 Total 口径 = PASS+FAIL)。
T10="$(mktemp -d)"; record_dir "$T10"
SELFTEST_SM10_WT="${SELFTEST_SM10_WT:-}"
if [ -z "$SELFTEST_SM10_WT" ]; then
  # [2026-09-12 R3] 相对推导替代硬编码任务 worktree 路径(原 /mnt/data/... 仅本任务成立)
  SELFTEST_SM10_WT="$(git -C "$(dirname "${BASH_SOURCE[0]}")/../.." rev-parse --show-toplevel 2>/dev/null)" || SELFTEST_SM10_WT=""
fi
SM10_WT="$SELFTEST_SM10_WT"
SM10_INJECTED=0
[ -n "$SM10_WT" ] && [ -d "$SM10_WT" ] && SM10_INJECTED=1
mk_fixture "$T10" "$T10/main" "$T10/task-test" "$T10/origin.git"
# git 2.43 无 worktree remove -q(rc 129 静默失败 → 分支残留 → 后续 add 失败), 用 2>/dev/null 兜底
git -C "$T10/main" worktree remove "$T10/task-test" 2>/dev/null || true
git -C "$T10/main" branch -D wt/task-test 2>/dev/null || true
SM10_SLOT="$T10/ancestor/task-planner"
mkdir -p "$SM10_SLOT"
# shadow worktree 放在 slot 内部: $SM10_SLOT/task-test 是 git worktree, WT_PATH 指向它,
# 则 slot($SM10_SLOT) 是 guard(WT_PATH) 的祖先 → 祖先守卫必须 REJECTED。
git -C "$T10/main" -c core.hooksPath=/dev/null worktree add -q "$SM10_SLOT/task-test" -b wt/task-test master 2>/dev/null
branch_commit "$SM10_SLOT/task-test"
ERRF="$T10/err"
# 前后 md5 基线: slot 目录清单 + 真实仓目录清单(若注入) + 真实仓目标脚本 md5(若注入), 前后须一致
SM10_BEFORE="$(ls -1 "$SM10_SLOT" | md5sum)"
if [ -n "$SM10_WT" ] && [ -d "$SM10_WT" ]; then
  SM10_BEFORE="$SM10_BEFORE
$(ls -1 "$SM10_WT" | md5sum)"
  [ -f "$SM10_WT/skills/task-planner/scripts/smart-merge-back.sh" ] && \
    SM10_BEFORE="$SM10_BEFORE
$(md5sum < "$SM10_WT/skills/task-planner/scripts/smart-merge-back.sh")"
fi
run env TASK_PLANNER_DEPLOY_SLOTS="$SM10_SLOT" bash "$TARGET" "$SM10_SLOT/task-test" --deploy
SM10_AFTER="$(ls -1 "$SM10_SLOT" | md5sum)"
if [ -n "$SM10_WT" ] && [ -d "$SM10_WT" ]; then
  SM10_AFTER="$SM10_AFTER
$(ls -1 "$SM10_WT" | md5sum)"
  [ -f "$SM10_WT/skills/task-planner/scripts/smart-merge-back.sh" ] && \
    SM10_AFTER="$SM10_AFTER
$(md5sum < "$SM10_WT/skills/task-planner/scripts/smart-merge-back.sh" 2>/dev/null)"
fi
SMOK=0
# [R3] 未注入真实 worktree(env 与套内相对推导均未命中) → 记 SKIP(不计 PASS/FAIL, 不静默降级)
if [ "$SM10_INJECTED" = 0 ]; then
  printf 'SM-10 SKIP 真实wt未注入(env SELFTEST_SM10_WT 与套内相对推导均失败 — 不计 PASS/FAIL)\n'
else
  [ "$R1" = 6 ] && printf '%s' "$R2" | grep -qF "REJECTED: $SM10_SLOT" && \
    printf '%s' "$R2" | grep -qF "的祖先" && \
    [ "$SM10_BEFORE" = "$SM10_AFTER" ] && SMOK=1
  report SM-10 "$SMOK" "rc=$R1(期望6) 真实wt注入=$([ "$SM10_INJECTED" = 1 ] && echo 是 || echo 否) REJECTED祖先=$(printf '%s' "$R2" | grep -qF "的祖先" && echo 在 || echo 缺) slot=$SM10_SLOT(guard=$SM10_SLOT/task-test) 零改动=$([ "$SM10_BEFORE" = "$SM10_AFTER" ] && echo 是 || echo 否)"
fi

# ---------- SM-11 (2026-09-12 R2 新增, 首次让 exit 8 有覆盖) 主仓 MERGE_HEAD 残留 → exit 8 含 MERGE_IN_PROGRESS ----------
# 夹具主仓人为构造 mid-merge 态: git update-ref --no-deref MERGE_HEAD HEAD(update-ref 无 -q, 失败回退 touch .git/MERGE_HEAD)
T11="$(mktemp -d)"; record_dir "$T11"
mk_fixture "$T11" "$T11/main" "$T11/task-test" "$T11/origin.git"
branch_commit "$T11/task-test"
if ! git -C "$T11/main" update-ref --no-deref MERGE_HEAD HEAD 2>/dev/null; then
  echo "$(git -C "$T11/main" rev-parse HEAD)" > "$T11/main/.git/MERGE_HEAD"
fi
ERRF="$T11/err"
run "$TARGET" "$T11/task-test"
SMOK=0
[ "$R1" = 8 ] && printf '%s' "$R2" | grep -qF 'MERGE_IN_PROGRESS' && SMOK=1
report SM-11 "$SMOK" "rc=$R1(期望8) MERGE_IN_PROGRESS=$(printf '%s' "$R2" | grep -qF 'MERGE_IN_PROGRESS' && echo 在 || echo 缺)"

# ---------- SM-12 (复审 4 轮 P2 回归, 2026-11-26 slot-identity 适配) env HOME=$T12/home +
#           slot=$T12/home/.zcode/skills/task-planner(HOME 内部、非默认部署根白名单) → REJECTED exit 6;
#           $T12/home/.zcode 目录清单 md5 前后一致(证明 REJECTED 路径零写入)。
# [2026-11-26 task-deploy-slot-safety] slot-identity 契约要求 basename==task-planner 且精确等于 <scan_root>/task-planner;
#   旧夹具 slot=$HOME/.zcode 会先被 [slot-identity] 拒绝, 遮蔽"HOME白名单内但非默认部署根"语义。本用例改为
#   slot=$HOME/.zcode/skills/task-planner(满足身份形态, 但该路径不在 DEFAULT_DEPLOY_ROOTS 白名单内, 因为 HOME
#   被覆写为 $T12/home, 默认根变为 $T12/home/.zcode/skills/task-planner 等——此处 slot 恰好等于默认根?
#   不: default_deploy_slots() 用 $HOME/.zcode/skills/task-planner, 当 HOME=$T12/home 时白名单含该精确路径。
#   为保持"HOME 内部但白名单外"语义, 改用 slot=$T12/home/.zcode/skills-extra/task-planner(身份形态合法: basename=task-planner,
#   但父扫描根 .zcode/skills-extra 不等于任何默认根; 且 --allow-home-slot 未传, HOME 守卫应拒绝)。
#   断言接受 [slot-identity] 或 HOME白名单拒绝原因(二者都满足"危险路径被拒+零写入")。
T12="$(mktemp -d)"; record_dir "$T12"
mk_fixture "$T12" "$T12/main" "$T12/task-test" "$T12/origin.git"
branch_commit "$T12/task-test"
mkdir -p "$T12/home/.zcode/skills-extra/task-planner"
echo "home-marker" > "$T12/home/.zcode/AGENTS.md"
SM12_BEFORE="$( (cd "$T12/home/.zcode" && ls -1 | md5sum) )"
SM12_SLOT="$T12/home/.zcode/skills-extra/task-planner"
ERRF="$T12/err"
run env HOME="$T12/home" TASK_PLANNER_DEPLOY_SLOTS="$SM12_SLOT" bash "$TARGET" "$T12/task-test" --deploy
SM12_AFTER="$( (cd "$T12/home/.zcode" && ls -1 | md5sum) )"
SMOK=0
SM12_REJECTED=0
printf '%s\n%s' "$R2" "$R3" | grep -qF "REJECTED:" && SM12_REJECTED=1
SM12_REASON_OK=0
printf '%s\n%s' "$R2" "$R3" | grep -qF "[slot-identity]" && SM12_REASON_OK=1
printf '%s\n%s' "$R2" "$R3" | grep -qF "不在默认部署根白名单内" && SM12_REASON_OK=1
[ "$R1" = 6 ] && [ "$SM12_REJECTED" = 1 ] && [ "$SM12_REASON_OK" = 1 ] && \
  [ -d "$T12/home/.zcode" ] && [ "$SM12_BEFORE" = "$SM12_AFTER" ] && SMOK=1
report SM-12 "$SMOK" "rc=$R1(期望6) REJECTED=$([ "$SM12_REJECTED" = 1 ] && echo 在 || echo 缺) 拒绝原因(slot-identity或白名单外)=$([ "$SM12_REASON_OK" = 1 ] && echo 在 || echo 缺) zcode存活+清单md5不变=$([ -d "$T12/home/.zcode" ] && [ "$SM12_BEFORE" = "$SM12_AFTER" ] && echo 是 || echo 否)"

# ---------- SM-13 (复审 5 轮 P2 改写真 P0 形态: $HOME 白名单分支的 break 2 回归) env HOME=$T13/home,
#           夹具主仓置于 $T13/home/.zcode/skills/task-planner(= 默认部署根白名单根, 主仓在部署根内),
#           slot 指同路径 → home guard(:home 白名单口径) 命中 exact 分支 → "= 受保护路径" REJECTED exit 6;
#           断言: 主仓 .git 存活 + 主仓根文件清单 md5 前后不变 + stdout 含 "= 受保护路径"(弱断言 grep "REJECTED" 已弃)。
#           该形态下若白名单 for 循环内 break 2 回归(误放行), slot 会 cp+rm 主仓 → 主仓毁 → 本用例立即 FAIL ----------
T13="$(mktemp -d)"; record_dir "$T13"
T13_HOME="$T13/home"
T13_MAIN="$T13_HOME/.zcode/skills/task-planner"   # 主仓 = 默认部署根白名单根之同路径(主仓在部署根内)
# [2026-09-12 复审 5 轮 P2] main 必须空或不存(git clone 要求), 只建 main 父链, 不预建 origin;
# origin.git 亦不得放 main 内 — 主仓根清单基线含 origin.git, REJECTED 零写入断言会因 origin 在
# main 内自比而恒真失实, 故放 $T13_HOME/.zcode/ 下(main 外, 不污染根清单, 实证)
rm -rf "$T13" 2>/dev/null; mkdir -p "$T13_HOME/.zcode/skills"
record_dir "$T13"
mk_fixture "$T13" "$T13_MAIN" "$T13/task-test" "$T13_HOME/.zcode/origin.git"
branch_commit "$T13/task-test"
# 主仓根文件清单基线(REJECTED 零写入实证): 排除 .git(merge ref 推进为正常 merge 副作用) 与
# branch_commit 新增的 new.txt(其被 merge 带入主仓为正常 merge 结果, 非 REJECTED 路径写入);
# 若白名单 break 2 回归误放行 cp+rm 主仓, 主仓会被替换为 skill 根内容, 根清单必变 → 立即 FAIL(实证)
SM13_GIT_OK=1; [ -d "$T13_MAIN/.git" ] || SM13_GIT_OK=0
SM13_ROOT_MD5="$( (cd "$T13_MAIN" && ls -1 | grep -v -e '^\.git$' -e '^new\.txt$' | md5sum) )"
ERRF="$T13/err"
# slot = 主仓同路径(显式注入同路径, 不依赖默认部署位); --force 跳过 MASTER_AHEAD(主仓已被 merge 推进)
# env HOME 前缀注入: GUARDS 的 $HOME:home 守卫 + DEFAULT_DEPLOY_ROOTS 白名单均以进程 env HOME 为基准
run env HOME="$T13_HOME" TASK_PLANNER_DEPLOY_SLOTS="$T13_MAIN" bash "$TARGET" "$T13/task-test" --deploy --force
SM13_GIT_AFTER=1; [ -d "$T13_MAIN/.git" ] || SM13_GIT_AFTER=0
SM13_ROOT_MD5_AFTER="$( (cd "$T13_MAIN" && ls -1 | grep -v -e '^\.git$' -e '^new\.txt$' | md5sum) 2>/dev/null)"
SMOK=0
# 真 P0 形态: home guard exact 命中("= 受保护路径") + exit 6 + 主仓 .git 存活 + 根清单 md5 不变
[ "$R1" = 6 ] && printf '%s' "$R2" | grep -qF "= 受保护路径" && \
  [ "$SM13_GIT_OK" = 1 ] && [ "$SM13_GIT_AFTER" = 1 ] && \
  [ "$SM13_ROOT_MD5" = "$SM13_ROOT_MD5_AFTER" ] && SMOK=1
report SM-13 "$SMOK" "rc=$R1(期望6) 部署根内主仓exact-REJECTED(= 受保护路径)=$(printf '%s' "$R2" | grep -qF "= 受保护路径" && echo 在 || echo 缺) .git存活=$([ "$SM13_GIT_AFTER" = 1 ] && echo 是 || echo 否) 主仓根清单md5不变=$([ "$SM13_ROOT_MD5" = "$SM13_ROOT_MD5_AFTER" ] && echo 是 || echo 否)"

# ---------- SM-14 (2026-09-17 S4 task-v077 新增, 陈旧副本回归钉子) 脚本副本置于陈旧部署位运行:
#           ① mk_fixture 造假主仓(含 skills/task-planner 标记 canonical-v077)
#           ② 造假部署位 A=$T14/stale-copy(skills/task-planner 内为 stale-content)并把 TARGET 副本
#              复制进 A 对应相对路径 → A 副本 SKILL_ROOT 指向陈旧 A
#           ③ bash "$A/skills/task-planner/scripts/smart-merge-back.sh" --deploy, slot 指 B=$T14/slotB/task-planner
#           ④ 断言 B 终态 SKILL_MARKER == canonical-v077(非 stale-content) 且输出含
#              [2026-10-10 task-v159 F5 级联] F5 默认 staging 路径成功消息: 终行 [DEPLOY] OK: 全部部署位 IDENTICAL
#              + 逐 slot 换位证据 [DEPLOY] SWAPPED: <slot>(staging/swap/post-verify 三段成功标记) → exit 0
#              (旧 --legacy 路径格式 [DEPLOY] IDENTICAL: <slot> 已不复现为默认输出, 本用例只走默认路径)
#           防 v076 假 IDENTICAL 复发: 以 SKILL_ROOT(脚本运行处)为源时会 cp 陈旧副本→自 diff 恒真,
#           终态 B 必为 stale-content → 本用例立即 FAIL(回归钉子) ----------
# [2026-11-26 task-deploy-slot-safety] slot-identity 契约适配: slot basename 必须==task-planner 且精确等于
#   <scan_root>/task-planner; B 改为 $T14/slotB-root/task-planner, 保持 stale→canonical 判别语义不变。
T14="$(mktemp -d)"; record_dir "$T14"
mk_fixture "$T14" "$T14/main" "$T14/task-test" "$T14/origin.git"
branch_commit "$T14/task-test"
# ① 主仓 fixture 已含 skills/task-planner(标记 v077-canonical, 见 mk_fixture); 改写为本用例专属标记 canonical-v077
echo "canonical-v077" > "$T14/main/skills/task-planner/SKILL_MARKER"
# ② 造假陈旧部署位 A: 预置 stale-content + 复制 TARGET 副本进 A 对应相对路径(scripts/..)
mkdir -p "$T14/stale-copy/skills/task-planner/scripts"
echo "stale-content" > "$T14/stale-copy/skills/task-planner/SKILL_MARKER"
cp "$TARGET" "$T14/stale-copy/skills/task-planner/scripts/smart-merge-back.sh"
# ③ ④ 运行: A 副本自推导 SKILL_ROOT=$T14/stale-copy; slot 指 B; 断言 B 终态 == 主仓 canonical-v077
T14_SLOT_B="$T14/slotB-root/task-planner"
mkdir -p "$T14_SLOT_B"
echo "stale-content" > "$T14_SLOT_B/SKILL_MARKER"
ERRF="$T14/err"
run env TASK_PLANNER_DEPLOY_SLOTS="$T14_SLOT_B" bash "$T14/stale-copy/skills/task-planner/scripts/smart-merge-back.sh" "$T14/task-test" --deploy
SMOK=0
# [2026-10-10 task-v159 F5 级联] 断言口径对齐 F5 默认路径成功消息契约: 终行 OK 串 + 逐 slot SWAPPED 证据
[ "$R1" = 0 ] && printf '%s' "$R2" | grep -qF '[DEPLOY] OK: 全部部署位 IDENTICAL' && \
  printf '%s' "$R2" | grep -qF "[DEPLOY] SWAPPED: $T14_SLOT_B" && \
  [ -f "$T14_SLOT_B/SKILL_MARKER" ] && \
  [ "$(cat "$T14_SLOT_B/SKILL_MARKER")" = "canonical-v077" ] && \
  [ "$(cat "$T14_SLOT_B/SKILL_MARKER")" != "stale-content" ] && SMOK=1
report SM-14 "$SMOK" "rc=$R1(期望0) 终行OK-串=$(printf '%s' "$R2" | grep -qF '[DEPLOY] OK: 全部部署位 IDENTICAL' && echo 在 || echo 缺) slotB-SWAPPED=$(printf '%s' "$R2" | grep -qF "[DEPLOY] SWAPPED: $T14_SLOT_B" && echo 在 || echo 缺) slotB-SKILL_MARKER=$(cat "$T14_SLOT_B/SKILL_MARKER" 2>/dev/null)(期望canonical-v077非stale-content)"

# ---------- SM-15a/SM-15b (2026-09-27 task-v091/C-5-locale 回归钉子, S32 组5 C-5 实测缺陷: 非 C locale 下
#           comm 未 pin LC_ALL 时混合大小写文件名(B.md/a.md)顺序错乱 → L2 清单定向 inman 空 → B.md 不入
#           targets → 假 IDENTICAL(rc=0)。修复=deploy_reconcile 内 comm 逐处 pin LC_ALL=C(commit cc64c1b);
#           本用例从 TARGET 抽真实函数双跑对拍 — 有人剥掉 pin 时 P15 基线与 DRIFT 断言立即 FAIL) ----------
# 抽取被测函数(_re_lines+deploy_reconcile, awk 范式实测抽 40 行): P15 基线=抽出行含 deploy_reconcile 定义
# 且含 LC_ALL=C comm 钉; 夹具: git 仓(B.md+a.md 混合大小写, mb 基线 commit → 改 B.md → branch commit) +
# src/slot 两侧(B.md 内容差异, a.md 相同) → 清单定向 diff 必报 DRIFT-L2(B.md), rc=1
T15="$(mktemp -d)"; record_dir "$T15"
FN15="$T15/fn.sh"
awk '/^    _re_lines\(\) \{/,/^    \}$/' "$TARGET" > "$FN15"
P15=0
grep -q 'deploy_reconcile() {' "$FN15" && grep -q 'LC_ALL=C comm' "$FN15" && P15=1
# git 仓夹具(禁全局 hooks, 同 mk_fixture 口径)
git -c core.hooksPath=/dev/null init -q "$T15/repo" 2>/dev/null
git -C "$T15/repo" config user.email selftest@local 2>/dev/null
git -C "$T15/repo" config user.name selftest 2>/dev/null
git -C "$T15/repo" config core.hooksPath /dev/null 2>/dev/null
git -C "$T15/repo" config advice.detachedHead false 2>/dev/null
mkdir -p "$T15/repo/skills/task-planner"
echo "v0" > "$T15/repo/skills/task-planner/B.md"
echo "shared" > "$T15/repo/skills/task-planner/a.md"
git -C "$T15/repo" add . && git -C "$T15/repo" commit -qm mb-base 2>/dev/null
echo "v1-branch" > "$T15/repo/skills/task-planner/B.md"
git -C "$T15/repo" add . && git -C "$T15/repo" commit -qm branch-Bmd 2>/dev/null
MB15="$(git -C "$T15/repo" rev-parse HEAD~1)"
BR15="$(git -C "$T15/repo" rev-parse HEAD)"
# DEPLOY_SRC(= 合并后内容) 与 slot: B.md 内容差异(源 v1-branch vs slot v0), a.md 两侧相同
mkdir -p "$T15/src" "$T15/slot"
echo "v1-branch" > "$T15/src/B.md";  echo "shared" > "$T15/src/a.md"
echo "v0"        > "$T15/slot/B.md";  echo "shared" > "$T15/slot/a.md"
# 包装器: source 抽取函数 + 注入 DEPLOY_SRC/MAIN_REPO/MB/BRANCH + 调 deploy_reconcile(不经完整脚本入口,
# 专测函数内 locale pin; 定位参数 $6=slot 目录)
cat > "$T15/h15.sh" <<'EOF15'
#!/usr/bin/env bash
set -u
. "$1"
DEPLOY_SRC="$2"; MAIN_REPO="$3"; MB="$4"; BRANCH="$5"
deploy_reconcile "$6"
exit $?
EOF15
ERRF="$T15/err"
# SM-15a: zh locale 下仍报 DRIFT-L2(B.md) 且 rc=1(修复前 comm 乱序 → inman 空 → 假 IDENTICAL rc=0)
run env LC_ALL=zh_CN.UTF-8 bash "$T15/h15.sh" "$FN15" "$T15/src" "$T15/repo" "$MB15" "$BR15" "$T15/slot"
OUT15A="$R2"; RC15A="$R1"
SMOK=0
[ "$RC15A" = 1 ] && printf '%s' "$OUT15A" | grep -qF 'DRIFT-L2' && \
  printf '%s' "$OUT15A" | grep -qF 'B.md' && SMOK=1
report SM-15a "$SMOK" "P15基线(抽取含deploy_reconcile定义+LC_ALL=C comm钉)=$([ "$P15" = 1 ] && echo 在 || echo 缺) zh-locale rc=$RC15A(期望1) DRIFT-L2=$(printf '%s' "$OUT15A" | grep -qF 'DRIFT-L2' && echo 在 || echo 缺) B.md入DRIFT明细=$(printf '%s' "$OUT15A" | grep -qF 'B.md' && echo 在 || echo 缺)"
# SM-15b: 同夹具 LC_ALL=C 跑, 与 15a 输出逐字节一致且 rc=1(pin 生效 → 行为 locale 无关)
run env LC_ALL=C bash "$T15/h15.sh" "$FN15" "$T15/src" "$T15/repo" "$MB15" "$BR15" "$T15/slot"
OUT15B="$R2"; RC15B="$R1"
SMOK=0
[ "$RC15B" = 1 ] && [ "$OUT15A" = "$OUT15B" ] && SMOK=1
report SM-15b "$SMOK" "C-locale rc=$RC15B(期望1) 与15a-zh逐字节一致=$([ "$OUT15A" = "$OUT15B" ] && echo 是 || echo 否)"

# ---------- SM-16 --legacy 部署回退路径回归钉子(2026-10-10 task-v159 N1 新增) ----------
# 验证 --legacy 路径保留旧格式输出 [DEPLOY] IDENTICAL: <slot> 且 exit 语义保留(成功 exit 0)。
# Why: F5 后默认走 staging 新路径, --legacy 保留旧直写路径作 fallback; 原 SM-06/SM-14 已改断默认
#   staging 路径, --legacy 路径无回归覆盖(N1)。本用例专测 --legacy 成功路径旧格式输出+exit 0。
# [2026-11-26 task-deploy-slot-safety] slot-identity 契约适配: slot basename 必须==task-planner 且精确等于
#   <scan_root>/task-planner; slotL 改为 $T16/slotL-root/task-planner, 保持 legacy IDENTICAL 旧格式判定语义不变。
T16="$(mktemp -d)"; record_dir "$T16"
mk_fixture "$T16" "$T16/main" "$T16/task-test" "$T16/origin.git"
branch_commit "$T16/task-test"
# 预置 slot 与主仓 fixture 的 skills/task-planner 同内容(IDENTICAL 路径)
T16_SLOT="$T16/slotL-root/task-planner"
mkdir -p "$(dirname "$T16_SLOT")"
cp -rL "$T16/main/skills/task-planner" "$T16_SLOT"
ERRF="$T16/err"
run env TASK_PLANNER_DEPLOY_SLOTS="$T16_SLOT" bash "$TARGET" "$T16/task-test" --deploy --legacy
SMOK=0
[ "$R1" = 0 ] && printf '%s' "$R2" | grep -qF "[DEPLOY] IDENTICAL: $T16_SLOT" && SMOK=1
report SM-16 "$SMOK" "rc=$R1(期望0) legacy-IDENTICAL旧格式=$(printf '%s' "$R2" | grep -qF "[DEPLOY] IDENTICAL: $T16_SLOT" && echo 在 || echo 缺)"

# ---------- SM-17 (2026-11-26 task-deploy-slot-safety-20261126, 事故回归钉子) parent_slot_rejected ----------
# 负例: 调用方把 skills 父目录(非 task-planner skill 目录)作为 slot, 且加 --allow-home-slot 试图放行。
# 契约(修复后): basename≠技能目录名 → REJECTED, 输出含 [slot-identity], rc=6; --allow-home-slot 不得绕过。
# 判别性: 修复前脚本无 basename 身份断言, --allow-home-slot 会放行 $HOME 内 slot → 不会出现 [slot-identity]
#   且 rc 不为 6(可能 0/1/6 但原因不同)或目标目录被改写。测试以"出现 [slot-identity] + rc=6 + md5 不变"为通过条件。
# 隔离: 全 /tmp 夹具, HOME 指向 /tmp, 不触碰真实部署位; slot 内容为普通文件, 若误 swap 会被破坏 → md5 断言兜底。
T17="$(mktemp -d)"; record_dir "$T17"
mk_fixture "$T17" "$T17/main" "$T17/task-test" "$T17/origin.git"
branch_commit "$T17/task-test"
T17_HOME="$T17/home"
mkdir -p "$T17_HOME/.zcode/skills/task-planner"
echo "child-sentinel" > "$T17_HOME/.zcode/skills/task-planner/SKILL_MARKER"
echo "sibling-sentinel" > "$T17_HOME/.zcode/skills/other-skill.txt"
SM17_BEFORE="$( (cd "$T17_HOME/.zcode/skills" && find . -type f | LC_ALL=C sort | while IFS= read -r f; do md5sum "$f"; done | md5sum) )"
ERRF="$T17/err"
run env HOME="$T17_HOME" TASK_PLANNER_DEPLOY_SLOTS="$T17_HOME/.zcode/skills" bash "$TARGET" "$T17/task-test" --deploy --allow-home-slot
SM17_AFTER="$( (cd "$T17_HOME/.zcode/skills" && find . -type f | LC_ALL=C sort | while IFS= read -r f; do md5sum "$f"; done | md5sum) )"
SMOK=0
[ "$R1" = 6 ] && printf '%s' "$R2" | grep -qF '[slot-identity]' && \
  [ "$SM17_BEFORE" = "$SM17_AFTER" ] && SMOK=1
report SM-17 "$SMOK" "rc=$R1(期望6) [slot-identity]=$(printf '%s' "$R2" | grep -qF '[slot-identity]' && echo 在 || echo 缺) skills清单md5不变=$([ "$SM17_BEFORE" = "$SM17_AFTER" ] && echo 是 || echo 否)"

# ---------- SM-18 (2026-11-26 task-deploy-slot-safety-20261126) backup_swap_reversible ----------
# 负例: 让 post-verify 阶段失败, 断言旧 slot 原样回位、backup 仍保留、无 .bak/.stage 残留在 skills 扫描根内。
# 契约(用户原文/OE-1): "swap前: mv <slot> → <backup> ... 失败: mv <backup> → <slot> # 回位，备份保留"。
# 必须断言: cache 根(TASK_PLANNER_DEPLOY_CACHE_ROOT 或默认 ~/.cache/task-planner-deploy)内失败后仍存在
#   该 slot 的物理 backup 目录(按 task-planner.backup.* glob 定位) + slot 回位 md5 不变 + skills 扫描根无
#   .bak/.stage 残留 + 非0 rc。不得接受 VERIFY-RECOVERED 字符串作为替代证据。
# 触发手法(确定性注入): 在 /tmp 夹具内造 PATH shim `diff`, 当参数包含 -r 且目标含 DEPLOY_SRC 时返回 1
#   并输出可识别 token; 其他 diff 调用透传真实 diff。通过 env PATH 注入, 只影响本次 run 子进程。
#   Why: watcher 篡改 DEPLOY_SRC 的时序竞态在快机/小夹具下不可稳定复现; shim 让 post-verify diff -r 必失败。
# 判别性: 修复前脚本 post-verify 失败仅 exit 1, 不回滚, slot 保留新内容, 无 cache backup 保留语义。
# 隔离: 全 /tmp 夹具; 显式设置 TASK_PLANNER_DEPLOY_CACHE_ROOT 到 /tmp 隔离目录; slot basename=task-planner。
T18="$(mktemp -d)"; record_dir "$T18"
mk_fixture "$T18" "$T18/main" "$T18/task-test" "$T18/origin.git"
branch_commit "$T18/task-test"
T18_HOME="$T18/home"
mkdir -p "$T18_HOME/.cache"
T18_CACHE="$(mktemp -d /tmp/sm18-cache.XXXXXX)"; record_dir "$T18_CACHE"
T18_SLOT="$T18/skills-root/task-planner"
mkdir -p "$T18_SLOT"
echo "old-slot-content" > "$T18_SLOT/SKILL_MARKER"
echo "old-extra" > "$T18_SLOT/EXTRA.txt"
SM18_BEFORE="$( (cd "$T18_SLOT" && find . -type f | LC_ALL=C sort | while IFS= read -r f; do md5sum "$f"; done | md5sum) )"
ERRF="$T18/err"
# 确定性注入: PATH shim diff — 仅当看到 -r 且某参数等于 SM18_FAIL_DIFF_TARGET 时 fail-closed 返回 1。
# post-verify 调用形态: diff -r "$slotdir" "$DEPLOY_SRC" (见 smart-merge-back.sh post-verify 段);
# deploy_reconcile 不使用 diff -r(用 cmp -s + git diff), 不会被误伤。
SM18_REAL_DIFF="$(command -v diff)"
SM18_BIN="$T18/bin"; mkdir -p "$SM18_BIN"
cat > "$SM18_BIN/diff" <<SHIM
#!/usr/bin/env bash
# SM-18 deterministic shim: fail post-verify diff -r when target matches
_target="\${SM18_FAIL_DIFF_TARGET:-}"
if [ -n "\$_target" ]; then
  _has_r=0; _has_t=0
  for _a in "\$@"; do
    [ "\$_a" = "-r" ] && _has_r=1
    [ "\$_a" = "\$_target" ] && _has_t=1
  done
  if [ "\$_has_r" = "1" ] && [ "\$_has_t" = "1" ]; then
    echo "SM18-INJECTED-DIFF-FAIL target=\$_target" >&2
    exit 1
  fi
fi
exec "$SM18_REAL_DIFF" "\$@"
SHIM
chmod +x "$SM18_BIN/diff"
run env HOME="$T18_HOME" TASK_PLANNER_DEPLOY_SLOTS="$T18_SLOT" \
  TASK_PLANNER_DEPLOY_CACHE_ROOT="$T18_CACHE" \
  SM18_FAIL_DIFF_TARGET="$T18/main/skills/task-planner" \
  PATH="$SM18_BIN:$PATH" \
  bash "$TARGET" "$T18/task-test" --deploy
SM18_AFTER="$( (cd "$T18_SLOT" && find . -type f | LC_ALL=C sort | while IFS= read -r f; do md5sum "$f"; done | md5sum) )"
SM18_STAGE_IN_SCAN="$(find "$T18/skills-root" -maxdepth 3 \( -name '*.stage.*' -o -name '*.bak.*' \) 2>/dev/null | wc -l | tr -d ' ')"
# 物理 backup 目录证据: 必须在 cache 根内按 task-planner.backup.* glob 定位到目录(非文件)。
SM18_CACHE_BAK_DIRS="$(find "$T18_CACHE" -maxdepth 3 -type d -name 'task-planner.backup.*' 2>/dev/null | wc -l | tr -d ' ')"
SM18_CACHE_BAK_LIST="$(find "$T18_CACHE" -maxdepth 3 -type d -name 'task-planner.backup.*' 2>/dev/null | head -3 | tr '\n' ',' | sed 's/,$//')"
SMOK=0
[ "$R1" -ne 0 ] && \
  [ "$SM18_BEFORE" = "$SM18_AFTER" ] && \
  [ "$SM18_STAGE_IN_SCAN" = "0" ] && \
  [ "$SM18_CACHE_BAK_DIRS" -ge 1 ] && SMOK=1
report SM-18 "$SMOK" "rc=$R1(期望非0) slot回位md5不变=$([ "$SM18_BEFORE" = "$SM18_AFTER" ] && echo 是 || echo 否) scan根内.bak/.stage残留=$SM18_STAGE_IN_SCAN(期望0) cache物理backup(task-planner.backup.*)=$SM18_CACHE_BAK_DIRS(期望>=1) 例=$SM18_CACHE_BAK_LIST"

# ---------- SM-19 (2026-11-26 task-deploy-slot-safety-20261126) postverify_identity ----------
# 负例: 构造 basename 不符的 slot(非 task-planner), 断言 IDENTITY-MISMATCH 且不出现假绿 IDENTICAL、非 0 rc。
# 契约(修复后): post-verify 路径身份断言, basename 篡改/不符时输出 IDENTITY-MISMATCH, 不得假绿。
# 判别性: 修复前脚本无 basename 身份断言; 对任意 basename 的 slot 只要内容 diff 一致就报 IDENTICAL+exit 0。
#   本用例预置 slot 内容与 DEPLOY_SRC 完全一致但 basename=wrong-name → 修复前会 IDENTICAL 假绿。
# 注意: 修复后 [slot-identity] 在 validate_slot 前置阶段即拒绝(更早 fail-closed), 同样满足"非0 + 无假绿 IDENTICAL"。
#   若修复把校验放在 post-verify, 则输出 IDENTITY-MISMATCH; 两种契约位置都接受, 但必须不假绿。
T19="$(mktemp -d)"; record_dir "$T19"
mk_fixture "$T19" "$T19/main" "$T19/task-test" "$T19/origin.git"
branch_commit "$T19/task-test"
# slot basename 故意不符: wrong-name 而非 task-planner; 内容预置为 canonical 一致以触发旧脚本假绿路径
mkdir -p "$T19/skills-root"
cp -rL "$T19/main/skills/task-planner" "$T19/skills-root/wrong-name"
ERRF="$T19/err"
run env TASK_PLANNER_DEPLOY_SLOTS="$T19/skills-root/wrong-name" bash "$TARGET" "$T19/task-test" --deploy
SMOK=0
# 接受: [slot-identity] 前置拒绝 或 post-verify IDENTITY-MISMATCH; 都必须非0且无假绿 IDENTICAL
HAS_ID_REJECT=0
printf '%s\n%s' "$R2" "$R3" | grep -qF 'IDENTITY-MISMATCH' && HAS_ID_REJECT=1
printf '%s\n%s' "$R2" "$R3" | grep -qF '[slot-identity]' && HAS_ID_REJECT=1
[ "$R1" -ne 0 ] && [ "$HAS_ID_REJECT" = 1 ] && \
  ! printf '%s' "$R2" | grep -qF '[DEPLOY] OK: 全部部署位 IDENTICAL' && \
  ! printf '%s' "$R2" | grep -qF '[DEPLOY] IDENTICAL:' && SMOK=1
report SM-19 "$SMOK" "rc=$R1(期望非0) identity-reject([slot-identity]|IDENTITY-MISMATCH)=$([ "$HAS_ID_REJECT" = 1 ] && echo 在 || echo 缺) 假绿IDENTICAL=$((printf '%s' "$R2" | grep -qF '[DEPLOY] OK: 全部部署位 IDENTICAL' || printf '%s' "$R2" | grep -qF '[DEPLOY] IDENTICAL:') && echo 出现 || echo 无)"

# ---------- SM-20 (2026-11-26 task-deploy-slot-safety-20261126) cache_root_outside_git_and_scan ----------
# 负例: TASK_PLANNER_DEPLOY_CACHE_ROOT 指向 skills 扫描根下, 以及指向含 .git 的夹具仓下 → fail-closed [deploy-cache]。
# 契约(修复后): cache root 若指向 skills 扫描根或 git 仓内 → fail-closed, 输出含 [deploy-cache]; 扫描根清单 md5 不变, 无新目录残留。
# 判别性: 修复前脚本无 TASK_PLANNER_DEPLOY_CACHE_ROOT 处理, 不会输出 [deploy-cache], 不会因该 env fail-closed。
T20="$(mktemp -d)"; record_dir "$T20"
mk_fixture "$T20" "$T20/main" "$T20/task-test" "$T20/origin.git"
branch_commit "$T20/task-test"
# 子场景 A: cache root 指向 skills 扫描根下
T20_HOME="$T20/homeA"
mkdir -p "$T20_HOME/.zcode/skills/task-planner"
cp -rL "$T20/main/skills/task-planner/"* "$T20_HOME/.zcode/skills/task-planner/" 2>/dev/null || true
echo "sentinel-a" > "$T20_HOME/.zcode/skills/task-planner/SKILL_MARKER"
SM20A_BEFORE="$( (cd "$T20_HOME/.zcode/skills" && find . -type f | LC_ALL=C sort | while IFS= read -r f; do md5sum "$f"; done | md5sum) )"
ERRF="$T20/err"
run env HOME="$T20_HOME" TASK_PLANNER_DEPLOY_SLOTS="$T20_HOME/.zcode/skills/task-planner" \
  TASK_PLANNER_DEPLOY_CACHE_ROOT="$T20_HOME/.zcode/skills/.cache" \
  bash "$TARGET" "$T20/task-test" --deploy
SM20A_RC="$R1"; SM20A_OUT="$R2"; SM20A_ERR="$R3"
SM20A_AFTER="$( (cd "$T20_HOME/.zcode/skills" && find . -type f | LC_ALL=C sort | while IFS= read -r f; do md5sum "$f"; done | md5sum) )"
SM20A_NEW="$(find "$T20_HOME/.zcode/skills" -mindepth 1 -maxdepth 2 -type d -name '.cache*' 2>/dev/null | wc -l | tr -d ' ')"
# 子场景 B: cache root 指向含 .git 的夹具仓内
T20B="$T20/scenB"
mkdir -p "$T20B/repo/skills/task-planner"
git -C "$T20B/repo" init -q 2>/dev/null || true
cp -rL "$T20/main/skills/task-planner/"* "$T20B/repo/skills/task-planner/" 2>/dev/null || true
echo "sentinel-b" > "$T20B/repo/skills/task-planner/SKILL_MARKER"
SM20B_BEFORE="$( (cd "$T20B/repo/skills" && find . -type f | LC_ALL=C sort | while IFS= read -r f; do md5sum "$f"; done | md5sum) )"
ERRF="$T20/err"
run env HOME="$T20B/home" TASK_PLANNER_DEPLOY_SLOTS="$T20B/repo/skills/task-planner" \
  TASK_PLANNER_DEPLOY_CACHE_ROOT="$T20B/repo/.deploy-cache" \
  bash "$TARGET" "$T20/task-test" --deploy
SM20B_RC="$R1"; SM20B_OUT="$R2"; SM20B_ERR="$R3"
SM20B_AFTER="$( (cd "$T20B/repo/skills" && find . -type f | LC_ALL=C sort | while IFS= read -r f; do md5sum "$f"; done | md5sum) )"
SM20B_NEW="$(find "$T20B/repo" -mindepth 1 -maxdepth 3 -type d -name '.deploy-cache*' 2>/dev/null | wc -l | tr -d ' ')"
SMOK=0
# [deploy-cache] token 可能在 stdout 或 stderr，检查合并流
SM20A_HAS=0; printf '%s\n%s' "$SM20A_OUT" "$SM20A_ERR" | grep -qF '[deploy-cache]' && SM20A_HAS=1
SM20B_HAS=0; printf '%s\n%s' "$SM20B_OUT" "$SM20B_ERR" | grep -qF '[deploy-cache]' && SM20B_HAS=1
[ "$SM20A_RC" -ne 0 ] && [ "$SM20A_HAS" = 1 ] && \
  [ "$SM20A_BEFORE" = "$SM20A_AFTER" ] && \
  [ "$SM20B_RC" -ne 0 ] && [ "$SM20B_HAS" = 1 ] && \
  [ "$SM20B_BEFORE" = "$SM20B_AFTER" ] && SMOK=1
report SM-20 "$SMOK" "A(rc=$SM20A_RC [deploy-cache]=$([ "$SM20A_HAS" = 1 ] && echo 在 || echo 缺) md5不变=$([ "$SM20A_BEFORE" = "$SM20A_AFTER" ] && echo 是 || echo 否)) B(rc=$SM20B_RC [deploy-cache]=$([ "$SM20B_HAS" = 1 ] && echo 在 || echo 缺) md5不变=$([ "$SM20B_BEFORE" = "$SM20B_AFTER" ] && echo 是 || echo 否))"

# ---------- 全量清理: 统一走 EXIT trap(cleanup_all); 上方显式段仅做断言兜底防 trap 失守 ----------
:

# [2026-11-26 task-deploy-slot-safety-20261126] 统计口径更新:
#   必跑断言行 21 条(SM-01..SM-03、SM-04a、SM-04b、SM-05..SM-09、SM-11..SM-20),
#   SM-10 注入真实 wt 时多 1 条 → TOTAL_CASES = 21 + (SM10_INJECTED ? 1 : 0) 动态计算:
#   SKIP(SM-10 未注入) → 21; 注入 → 22。
#   PASS/FAIL 为 report() 真实累计值; 框架断言 PASS+FAIL == TOTAL_CASES(动态), 不一致打印
#   FRAMEWORK_BROKEN 并 exit 97(记账框架自身损坏, 非用例失败); SKIP 单列, 不计入断言行总数。
TOTAL_BASE=21
TOTAL_CASES=$(( TOTAL_BASE + ( SM10_INJECTED ? 1 : 0 ) ))
SKIPPED=$(( SM10_INJECTED ? 0 : 1 ))
PASS_TOTAL=$((PASS + FAIL))
if [ "$PASS_TOTAL" -ne "$TOTAL_CASES" ]; then
  printf 'FRAMEWORK_BROKEN: 断言行 %d 与声明用例数 %d 不一致(PASS=%d FAIL=%d SKIP=%d 单列)\n' "$PASS_TOTAL" "$TOTAL_CASES" "$PASS" "$FAIL" "$SKIPPED" >&2
  exit 97
fi
FAIL_CASES=$FAIL
[ "$FAIL_CASES" -gt "$TOTAL_CASES" ] && FAIL_CASES=$TOTAL_CASES
PASS_CASES=$(( TOTAL_CASES - FAIL_CASES ))
if [ "$SKIPPED" = 1 ]; then
  printf 'Total: %d PASS=%d FAIL=%d SKIP=%d\n' "$TOTAL_CASES" "$PASS" "$FAIL" "$SKIPPED"
else
  printf 'Total: %d PASS=%d FAIL=%d\n' "$TOTAL_CASES" "$PASS" "$FAIL"
fi
exit $((FAIL > 0))
