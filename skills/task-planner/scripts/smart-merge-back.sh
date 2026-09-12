#!/usr/bin/env bash
# smart-merge-back.sh — 合并回智能门 [task-v064-smart-merge-back]
#
# 用途: 把 worktree 隔离任务"合并回 master"升级为智能门:
#   V1-V6 结构化预检(目录/分支在册、worktree 干净、主仓 scope 重叠、已合并自动检测、
#   master 前进检测)+ --no-ff 合并执行 + 可选 --deploy 逐位重部署与 diff 对账。
#   机制化 v062 双窗口事故教训: 另一窗口已合并 → V4 ALREADY_MERGED 跳过合并转提示, 无需人工 git 考古。
#
# Usage:
#   smart-merge-back.sh <worktree-path> [--base master] [--deploy] [--force]
#
# 参数:
#   <worktree-path>  必填; worktree 绝对路径
#   --base <branch>  目标分支, 默认 master
#   --deploy         合并后对部署位执行既有 SOP(rm+cp -rL+diff -rq); 逐位 [DEPLOY] 判定, 任一 DRIFT exit 6
#   --force          V5 MASTER_AHEAD 时强制继续(默认中止; merge 冲突仍 exit 7 STOP)
#
# 接口规格(照 findings「smart-merge-back.sh 设计」):
#   - branch 由 `git -C <wt> branch --show-current` 取得, 须匹配 wt/<task-id> 且目录名 = task-id(双校验)
#   - 主仓路径从 `git -C <wt> worktree list` 解析(主仓 = 不带 branch 的工作树行), 禁止假设 CWD
#   - 每步一行结构化输出 `[Vn] VERDICT: 详情`(stdout, 机器可解析); 失败详情补充走 stderr
#
# 检查序列:
#   V1 前提(worktree 目录在册 + 分支名 wt/* 双校验)        → 失败 exit 2  PRECHECK_INVALID
#   V2 worktree 干净(git status --porcelain 为空)           → 失败 exit 3  PRECHECK_DIRTY(列出文件)
#   V3 主仓未提交文件 ∩ 分支变更文件(merge-base..branch)     → 非空 exit 4 SCOPE_OVERLAP(列出交集)
#   V4 已合并检测(merge-base --is-ancestor branch base)     → 真: [V4] ALREADY_MERGED, 跳过合并继续清理提示与 --deploy, 最终 exit 0
#   V5 master 前进检测(base HEAD ≠ merge-base)               → exit 5 MASTER_AHEAD(--force 才继续; 冲突仍 exit 7)
#   V6 合并执行(git -C <主仓> merge --no-ff branch)          → [V6] MERGED: <commit>; 冲突 exit 7 MERGE_CONFLICT(STOP 语义)
#
# 后续输出:
#   [CLEANUP] git worktree remove <path> && git branch -d <branch>   (只提示不执行 — 清理时机留主进程)
#   --deploy: 逐位 [DEPLOY] IDENTICAL|DRIFT: <位>; 任一 DRIFT → exit 6 DEPLOY_DRIFT
#   slot 列表由 env TASK_PLANNER_DEPLOY_SLOTS(冒号分隔)覆盖(供自测注入); 未设默认 3 真实位。
#
# 通用: set -u; 无 jq 依赖; 头注释块标注任务与用途; 退出码表如下。
#
# 退出码:
#   0 = 成功(MERGED 或 ALREADY_MERGED, 且 --deploy 全位 IDENTICAL)
#   2 = PRECHECK_INVALID      (worktree 目录不存在 / 分支名不合规 / 不在 worktree list 在册)
#   3 = PRECHECK_DIRTY        (worktree 有未提交变更, 列出文件)
#   4 = SCOPE_OVERLAP         (主仓未提交文件 ∩ 分支变更文件非空, 列出交集)
#   5 = MASTER_AHEAD          (base 前进于 merge-base, 建议先 merge base 入分支再重跑; --force 才继续)
#   6 = DEPLOY_DRIFT          (--deploy 任一位 diff -rq 有差异)
#   7 = MERGE_CONFLICT        (merge 冲突, STOP 语义 — 不自动解决, 报告用户)
#   1 = 参数/环境错误(缺参数、git 命令失败等未归类项)
set -u

# ---------- 参数解析 ----------
usage() {
    cat <<'EOF'
Usage: smart-merge-back.sh <worktree-path> [--base master] [--deploy] [--force]
退出码: 0 成功 | 2 PRECHECK_INVALID | 3 PRECHECK_DIRTY | 4 SCOPE_OVERLAP
        5 MASTER_AHEAD | 6 DEPLOY_DRIFT | 7 MERGE_CONFLICT
EOF
}

WT_PATH=""
BASE="master"
DO_DEPLOY=0
DO_FORCE=0

while [ $# -gt 0 ]; do
    case "$1" in
    --base)
        shift
        if [ $# -lt 1 ]; then
            echo "[V1] PRECHECK_INVALID: --base 缺参数" >&2; usage; exit 1
        fi
        BASE="$1"; shift ;;
    --deploy) DO_DEPLOY=1; shift ;;
    --force)  DO_FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*)
        echo "[V1] PRECHECK_INVALID: 未知选项 $1" >&2; usage; exit 1 ;;
    *)
        if [ -n "$WT_PATH" ]; then
            echo "[V1] PRECHECK_INVALID: 多余的位置参数 $1" >&2; usage; exit 1
        fi
        WT_PATH="$1"; shift ;;
    esac
done

if [ -z "$WT_PATH" ]; then
    echo "[V1] PRECHECK_INVALID: 缺 <worktree-path>" >&2; usage; exit 1
fi

# ---------- V1 前提检查 ----------
# worktree 目录存在
if [ ! -d "$WT_PATH" ]; then
    echo "[V1] FAIL: worktree 目录不存在 $WT_PATH"
    echo "[V1] PRECHECK_INVALID: 目录 $WT_PATH 不存在" >&2
    exit 2
fi

# 取 worktree 当前分支
BRANCH="$(git -C "$WT_PATH" branch --show-current 2>/dev/null)" || {
    echo "[V1] PRECHECK_INVALID: 无法在 $WT_PATH 读取当前分支(非 git 仓或 detached HEAD)" >&2
    exit 2
}

# 双校验: 分支名 = wt/<task-id> 且 目录名 = task-id
# (worktree 目录名按 §11.2 新规范为 <repo>-worktrees/<task-id>, basename 即 task-id;
#  若用户以 wt-<task-id> 等带前缀形式命名, 取末尾 segment 匹配, 前缀可选)
case "$BRANCH" in
wt/*) TASK_ID="${BRANCH#wt/}" ;;
*)
    echo "[V1] PRECHECK_INVALID: 分支名 '$BRANCH' 不匹配 wt/<task-id>" >&2
    exit 2 ;;
esac
WT_DIRNAME="$(basename "$WT_PATH")"
case "$WT_DIRNAME" in
"$TASK_ID"|*"-$TASK_ID") ;;          # 目录名 = task-id, 或 = 带前缀的 task-id 命名
*)
    echo "[V1] PRECHECK_INVALID: worktree 目录名 '$WT_DIRNAME' 与 task-id '$TASK_ID' 不匹配(分支 $BRANCH)" >&2
    exit 2 ;;
esac

# 主仓解析: 主仓在 worktree list 中"不带 branch"的工作树行
# 兼容两种主仓状态: (a) 主仓 detached — 输出行 [ ] 空; (b) 主仓跟踪 base 分支
# (典型 bare origin + worktree add 场景, 主仓行带 [master]) — 此时按"分支=base"识别主仓行
WTLIST="$(git -C "$WT_PATH" worktree list 2>/dev/null)" || {
    echo "[V1] PRECHECK_INVALID: git worktree list 失败" >&2; exit 2
}
MAIN_REPO="$(printf '%s\n' "$WTLIST" | awk -v base="$BASE" '
    $2 ~ /^[0-9a-f]{7,}$/ {
        # 主仓行: 方括号内为空, 或方括号内恰为 base(主仓跟踪 base 分支的典型形态)
        n = split($0, parts, "[")
        if (n >= 2) {
            inner = parts[2]
            sub(/\].*$/, "", inner)
            if (inner == "" || inner == base) { print $1; exit }
        }
    }')"
if [ -z "$MAIN_REPO" ]; then
    echo "[V1] PRECHECK_INVALID: 无法从 worktree list 解析主仓路径(无主仓行, 且 $BASE 分支行缺失)" >&2
    exit 2
fi

# 在册校验: 分支 $BRANCH 出现在 worktree list
if ! printf '%s\n' "$WTLIST" | grep -qF "[$BRANCH]"; then
    echo "[V1] PRECHECK_INVALID: 分支 $BRANCH 不在 worktree list 在册(主仓 $MAIN_REPO)" >&2
    exit 2
fi
# base 分支须存在
if ! git -C "$MAIN_REPO" rev-parse --verify "$BASE^{commit}" >/dev/null 2>&1; then
    echo "[V1] PRECHECK_INVALID: base 分支 '$BASE' 不存在于主仓" >&2
    exit 2
fi

echo "[V1] OK: worktree $WT_PATH 在册, branch=$BRANCH, main=$MAIN_REPO, base=$BASE"

# ---------- V2 worktree 干净 ----------
DIRTY="$(git -C "$WT_PATH" status --porcelain 2>/dev/null)"
if [ -n "$DIRTY" ]; then
    echo "[V2] PRECHECK_DIRTY: worktree 有未提交变更:"
    printf '%s\n' "$DIRTY"
    echo "[V2] PRECHECK_DIRTY: 先提交/还原再重跑" >&2
    exit 3
fi
echo "[V2] OK: worktree 干净"

# ---------- V3 scope 重叠 ----------
# 主仓未提交文件(改动+暂存+untracked), 相对主仓路径
MAIN_DIRTY="$(git -C "$MAIN_REPO" status --porcelain 2>/dev/null | awk '{print $NF}')"
# 分支相对 merge-base 的变更文件, 相对主仓路径
MB="$(git -C "$MAIN_REPO" merge-base "$BASE" "$BRANCH" 2>/dev/null)"
if [ -z "$MB" ]; then
    echo "[V3] PRECHECK_INVALID: 无法计算 merge-base($BASE...$BRANCH)" >&2
    exit 2
fi
BRANCH_FILES="$(git -C "$MAIN_REPO" diff --name-only "$MB" "$BRANCH" 2>/dev/null)"
OVERLAP=""
if [ -n "$MAIN_DIRTY" ] && [ -n "$BRANCH_FILES" ]; then
    OVERLAP="$(comm -12 <(printf '%s\n' "$MAIN_DIRTY" | sort -u) \
                              <(printf '%s\n' "$BRANCH_FILES" | sort -u))"
fi
if [ -n "$OVERLAP" ]; then
    echo "[V3] SCOPE_OVERLAP: 主仓未提交文件 ∩ 分支变更文件:"
    printf '%s\n' "$OVERLAP"
    echo "[V3] SCOPE_OVERLAP: 主仓有与任务范围重叠的未提交变更, 先处理主仓再重跑" >&2
    exit 4
fi
echo "[V3] OK: 主仓无 scope 重叠(merge-base $MB)"

# ---------- V4 已合并检测 ----------
CLEANUP_LINE=""
DO_MERGED=0
ALREADY=0
if git -C "$MAIN_REPO" merge-base --is-ancestor "$BRANCH" "$BASE" 2>/dev/null; then
    echo "[V4] ALREADY_MERGED: $BRANCH 已在 $BASE(merge-base $MB) — 跳过合并(另一窗口可能已合并)"
    ALREADY=1
    CLEANUP_LINE="git worktree remove $WT_PATH && git branch -d $BRANCH"
else
    # ---------- V5 master 前进检测 ----------
    BASE_HEAD="$(git -C "$MAIN_REPO" rev-parse --verify "$BASE" 2>/dev/null)"
    if [ "$BASE_HEAD" != "$MB" ]; then
        if [ "$DO_FORCE" -ne 1 ]; then
            echo "[V5] MASTER_AHEAD: $BASE HEAD $BASE_HEAD ≠ merge-base $MB — 建议先在 worktree 内 'git merge $BASE' 再重跑(--force 可强制)"
            echo "[V5] MASTER_AHEAD: 默认中止, 不代替用户做策略分叉" >&2
            exit 5
        fi
        echo "[V5] MASTER_AHEAD(警告): $BASE 已前进($MB → $BASE_HEAD), --force 继续; 冲突仍 STOP(exit 7)"
    else
        echo "[V5] OK: $BASE 未前进(HEAD == merge-base)"
    fi

    # ---------- V6 合并执行 ----------
    if ! merge_out="$(git -C "$MAIN_REPO" merge --no-ff "$BRANCH" 2>&1)"; then
        echo "[V6] MERGE_CONFLICT: merge --no-ff $BRANCH 失败:"
        printf '%s\n' "$merge_out"
        echo "[V6] MERGE_CONFLICT: STOP — 冲突不自动解决, 报告用户" >&2
        exit 7
    fi
    MERGE_COMMIT="$(git -C "$MAIN_REPO" rev-parse --verify HEAD 2>/dev/null)"
    echo "[V6] MERGED: $MERGE_COMMIT"
    DO_MERGED=1
    CLEANUP_LINE="git worktree remove $WT_PATH && git branch -d $BRANCH"
fi

# ---------- 清理提示(不自动执行) ----------
if [ -n "$CLEANUP_LINE" ]; then
    echo "[CLEANUP] 由主进程择机执行: $CLEANUP_LINE"
fi

# ---------- --deploy 逐位重部署对账 ----------
if [ "$DO_DEPLOY" -eq 1 ]; then
    SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
    SLOTS="${TASK_PLANNER_DEPLOY_SLOTS:-$HOME/.zcode/skills/task-planner:$HOME/.claude/skills/task-planner:$HOME/.config/opencode/skills/task-planner}"
    DRIFT=0
    for slot in $(printf '%s' "$SLOTS" | tr ':' ' '); do
        [ -n "$slot" ] || continue
        # SOP(memory deploy-flow): rm+cp -rL+diff -rq 三连; skill 根 = 脚本上级目录
        rm -rf "$slot" 2>/dev/null || true
        if ! cp -rL "$SKILL_ROOT" "$slot" 2>/dev/null; then
            echo "[DEPLOY] DRIFT: $slot (cp 失败 — 槽位不可写或路径不存在)"
            DRIFT=1
            continue
        fi
        if diff -rq "$SKILL_ROOT" "$slot" >/dev/null 2>&1; then
            echo "[DEPLOY] IDENTICAL: $slot"
        else
            echo "[DEPLOY] DRIFT: $slot"
            DRIFT=1
        fi
    done
    if [ "$DRIFT" -eq 1 ]; then
        echo "[DEPLOY] DEPLOY_DRIFT: 至少一位部署位 diff -rq 有差异" >&2
        exit 6
    fi
    echo "[DEPLOY] OK: 全部部署位 IDENTICAL"
fi

# 成功: MERGED 或 ALREADY_MERGED, 且 --deploy 全 IDENTICAL
exit 0
