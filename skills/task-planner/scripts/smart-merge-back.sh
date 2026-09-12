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
#   --deploy: 逐位 [DEPLOY] REJECTED|IDENTICAL|DRIFT: <位>; 任一 REJECTED/DRIFT → exit 6 DEPLOY_DRIFT
#   slot 列表由 env TASK_PLANNER_DEPLOY_SLOTS(冒号分隔)覆盖(供自测注入); 未设默认 3 真实位。
#   slot 安全: IFS=':' 解析 + validate_slot 守卫(拒空/非绝对/含空白或 glob(*?[)/规范化后为
#     / $HOME $SKILL_ROOT $WT_PATH $MAIN_REPO 或其内部/.git 末组件 → REJECTED exit 6);
#     替换原子: cp -rL 至同目录 .tmp-new.$$ → rm -rf slot → mv tmp→slot; cp 失败原 slot 保留。
#
# 通用: set -u; 无 jq 依赖; 头注释块标注任务与用途; 退出码表如下。
#
# 退出码:
#   0 = 成功(MERGED 或 ALREADY_MERGED, 且 --deploy 全位 IDENTICAL)
#   2 = PRECHECK_INVALID      (worktree 目录不存在 / 分支名不合规 / 不在 worktree list 在册)
#   3 = PRECHECK_DIRTY        (worktree 有未提交变更, 列出文件)
#   4 = SCOPE_OVERLAP         (主仓未提交文件 ∩ 分支变更文件非空, 列出交集)
#   5 = MASTER_AHEAD          (base 前进于 merge-base, 建议先 merge base 入分支再重跑; --force 才继续)
#   6 = DEPLOY_DRIFT          (--deploy 任一位 DRIFT: diff -rq 有差异 / cp 失败 / slot 校验 REJECTED(危险路径))
#   7 = MERGE_CONFLICT        (merge 冲突, STOP 语义 — 不自动解决, 报告用户; 主仓残留 mid-merge, 恢复: git -C <主仓> merge --abort)
#   8 = MERGE_IN_PROGRESS     (V1 检测主仓存在未完成合并 MERGE_HEAD — 恢复: git -C <主仓> merge --abort 后重跑)
#   2 = ARG_INVALID           (参数错误: 未知选项/缺参/多余位置参数 — 与文档对齐, 原 exit 1 矛盾已修)
#   1 = 环境错误(缺参数已归 2; git 命令失败等未归类项)
#
# 已知偏差(记录在案): 目录名双校验为 "basename = task-id 或 *-$TASK_ID 后缀匹配" —
#   兼容 task-id 尾缀变体命名(如集中目录 <repo>-worktrees/<task-id> 或旧式 <repo>-wt-<task-id>);
#   属有意放宽, 非实现误差。slot 校验拒绝含空格/空白/glob 字符路径(REJECTED exit 6)。
# 2026-09-12 S2 修复轮(P0/P1/P2/P3 findings): --deploy 重写(IFS 解析 + validate_slot 守卫 + cp→rm→mv 原子替换)、
#   MAIN_REPO 改 worktree list --porcelain、V3 NUL 安全、MERGE_CONFLICT 恢复指引 + V1 MERGE_IN_PROGRESS exit 8、ARG_INVALID exit 2。
set -u

# ---------- 参数解析 ----------
usage() {
    cat <<'EOF'
Usage: smart-merge-back.sh <worktree-path> [--base master] [--deploy] [--force]
退出码: 0 成功 | 2 PRECHECK_INVALID/ARG_INVALID | 3 PRECHECK_DIRTY | 4 SCOPE_OVERLAP
        5 MASTER_AHEAD | 6 DEPLOY_DRIFT | 7 MERGE_CONFLICT | 8 MERGE_IN_PROGRESS
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
            echo "[V1] ARG_INVALID: --base 缺参数" >&2; usage; exit 2
        fi
        BASE="$1"; shift ;;
    --deploy) DO_DEPLOY=1; shift ;;
    --force)  DO_FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*)
        echo "[V1] ARG_INVALID: 未知选项 $1" >&2; usage; exit 2 ;;
    *)
        if [ -n "$WT_PATH" ]; then
            echo "[V1] ARG_INVALID: 多余的位置参数 $1" >&2; usage; exit 2
        fi
        WT_PATH="$1"; shift ;;
    esac
done

if [ -z "$WT_PATH" ]; then
    echo "[V1] ARG_INVALID: 缺 <worktree-path>" >&2; usage; exit 2
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

# 主仓解析: `worktree list --porcelain` — 每块以 "worktree <path>" 开头, 后续 "HEAD <sha>" / "branch refs/heads/<name>"。
# 主仓识别规则(优先序): ① 该仓的关联主仓(主仓内存在 .git/worktrees/<hash> 元数据目录,
#   git worktree add 必生此元数据) — git 原生判据, 兼容主仓 detached/bare 任意形态(2026-09-12 S2 P2:
#   原"无 branch 行"判据误把带 branch 的独立 worktree 块当主仓);
#   ② 兜底: 无 branch 行的块(detached 主仓, 元数据缺失等边界);
#   ③ 兜底: branch 恰为 refs/heads/<base> 的块(典型 bare origin + worktree add, 主仓跟踪 base)。
#   三判据全不中 → PRECHECK_INVALID "主仓不在 base 上或 detached 且无关联元数据"。
#   hex/分支匹配不限定 7 位(原 awk 硬编码 {7,} 缺陷已除)。
WT_HASH="$(git -C "$WT_PATH" rev-parse --git-dir 2>/dev/null | awk -F/ '{print $NF}')"
WTLIST_P="$(git -C "$WT_PATH" worktree list --porcelain 2>/dev/null)" || {
    echo "[V1] PRECHECK_INVALID: git worktree list --porcelain 失败" >&2; exit 2
}
WT_PATH="$(cd "$WT_PATH" && pwd)"   # 规范化, 与 porcelain 输出(绝对路径)前缀比较口径一致
# 块清单: 每行 "块路径|branch(无 branch 行则为空)"
_P="$(printf '%s\n' "$WTLIST_P" | awk '
    /^worktree /{ wt=$2; br=""; if (wt != "") print wt "|" br; wt="" }
    /^branch refs\/heads\//{ br=$0; sub(/^branch /, "", br) }')"
# bash 循环按优先序取主仓: ① 关联主仓元数据(该仓 .git/worktrees/<wt_hash> 存在, git worktree add 必生)
#   ② 无 branch 的块(detached 主仓) ③ branch=refs/heads/<base> 的块(bare origin + 主仓跟踪 base 典型形态)
MAIN_REPO=""
while IFS='|' read -r p brx; do
    [ -n "$p" ] || continue
    if [ -n "$WT_HASH" ] && [ "$WT_HASH" != "HEAD" ] && [ -d "$p/.git/worktrees/$WT_HASH" ]; then
        MAIN_REPO="$p"; break
    fi
done <<< "$_P"
if [ -z "$MAIN_REPO" ]; then
    while IFS='|' read -r p brx; do
        [ -n "$p" ] || continue
        [ -z "$brx" ] && { MAIN_REPO="$p"; break; }
    done <<< "$_P"
fi
if [ -z "$MAIN_REPO" ]; then
    while IFS='|' read -r p brx; do
        [ -n "$p" ] || continue
        [ "$brx" = "refs/heads/$BASE" ] && { MAIN_REPO="$p"; break; }
    done <<< "$_P"
fi
if [ -z "$MAIN_REPO" ]; then
    echo "[V1] PRECHECK_INVALID: 无法从 worktree list --porcelain 解析主仓路径(主仓不在 $BASE 上, 或 detached 且无关联 worktrees 元数据)" >&2
    exit 2
fi
MAIN_REPO="$(cd "$MAIN_REPO" && pwd)"

# 在册校验: 分支 $BRANCH 出现在 worktree list(在 MAIN_REPO 查, 主仓视角完整)
WTLIST="$(git -C "$MAIN_REPO" worktree list 2>/dev/null)" || {
    echo "[V1] PRECHECK_INVALID: git worktree list 失败" >&2; exit 2
}

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

# 主仓 mid-merge 检测(.git/MERGE_HEAD 残留 → V6 重跑会 self-lock: "fatal: You have not concluded your merge")
# [2026-09-12 S2 P2 新增; 独立退出码 8, 附恢复指引]
if [ -f "$(git -C "$MAIN_REPO" rev-parse --git-path MERGE_HEAD 2>/dev/null)" ]; then
    echo "[V1] MERGE_IN_PROGRESS: 主仓 $MAIN_REPO 有未完成合并(存在 MERGE_HEAD)"
    echo "[V1] 恢复: git -C $MAIN_REPO merge --abort" >&2
    exit 8
fi

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
# 主仓未提交文件(改动+暂存+untracked; -uall 展开未跟踪目录不坍缩), 相对主仓路径
# [2026-09-12 S2 P2: 原 `awk '{print $NF}'` 对"未跟踪目录坍缩行(?? dir/)与含空格路径"双漏;
#  改 -z NUL 安全解析: read -d '' 逐条, 剥前 3 字符状态码取路径]
MAIN_DIRTY="$(git -C "$MAIN_REPO" status --porcelain -z -uall 2>/dev/null |
    while IFS= read -r -d '' entry; do printf '%s\n' "${entry#???}"; done)"
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
        # [2026-09-12 S2 P2: 主仓可能残留 mid-merge 态, 重跑前须先 abort, 否则 V1 MERGE_HEAD 检测 exit 8 自锁]
        echo "[V6] 恢复: git -C $MAIN_REPO merge --abort (清除 mid-merge 态后重跑; 需保留合并结果则手工解冲突)" >&2
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
# [2026-09-12 S2 P0+P1 重写: 原实现"rm 先于 cp 验证 + 空格分词"可摧毁受保护路径(worktree/主仓/HOME)
#  且 exit 0 假绿。现: slot IFS 安全解析 + validate_slot 前缀守卫 + cp→rm→mv 原子替换(tmp 建同目录保 mv 原子)。]
if [ "$DO_DEPLOY" -eq 1 ]; then
    SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
    SLOTS="${TASK_PLANNER_DEPLOY_SLOTS:-$HOME/.zcode/skills/task-planner:$HOME/.claude/skills/task-planner:$HOME/.config/opencode/skills/task-planner}"
    # 受保护路径集合: 任一 slot 规范化后等于或位于其内部(纯字符串前缀比较, 不依赖 git)即拒绝
    GUARDS="$HOME|$SKILL_ROOT|$WT_PATH|$MAIN_REPO|/"
    # trap 清理本批次原子替换的残留 tmp: 各 slot 成功时已 mv 归位, 失败路径 cp/mv 前缀匹配可覆盖;
    # 残留清理对象统一为 .tmp-new.$$ 后缀(与 tmpdir 构造一致, 防跨进程误删他进程 .tmp-deploy.*)
    trap 'rm -rf "${SKILL_ROOT}"/.tmp-new.$$* 2>/dev/null || true' EXIT

    validate_slot() {   # <slot> → 合法 return 0; 任一命中打印 REJECTED 并 return 1
        local slot="$1"
        [ -n "$slot" ] || { echo "[DEPLOY] REJECTED: $slot (空串 — 危险路径)"; return 1; }
        case "$slot" in /*) ;; *) echo "[DEPLOY] REJECTED: $slot (非绝对路径 — 危险路径)"; return 1 ;; esac
        case "$slot" in *" "*|*$'\t'*|*$'\n'*|*'*'*|*'?'*|*'['*) echo "[DEPLOY] REJECTED: $slot (含空白/glob 字符 — 危险路径)"; return 1 ;; esac
        case "$slot" in .git|*/.git) echo "[DEPLOY] REJECTED: $slot (末尾组件 .git — 危险路径)"; return 1 ;; esac
        # 规范化(纯字符串, 不动磁盘): 去 leading ./ 与 trailing / 族; slot=/ 保留为 "/" 供下条 REJECTED
        local norm="${slot#./}"
        while [ "${norm%/}" != "$norm" ] && [ "$norm" != "/" ] && [ -n "$norm" ]; do norm="${norm%/}"; done
        [ -z "$norm" ] && { echo "[DEPLOY] REJECTED: $slot (规范化后为空 — 危险路径)"; return 1; }
        [ "$norm" = "/" ] && { echo "[DEPLOY] REJECTED: / (规范化后为根 — 危险路径)"; return 1; }
        local g guard_list
        IFS='|' read -r -a guard_list <<< "$GUARDS"
        # 规范化守卫(与 GUARDS 同格式: 去 leading ./ 与 trailing / 族), 防 "$HOME/" 与 "$HOME" 双形态误报
        for g in "${guard_list[@]}"; do
            [ -n "$g" ] || continue
            local gn="${g#./}"
            while [ "${gn%/}" != "$gn" ] && [ "$gn" != "/" ] && [ -n "$gn" ]; do gn="${gn%/}"; done
            [ "$norm" = "$gn" ] && { echo "[DEPLOY] REJECTED: $slot (= 受保护路径 $g)"; return 1; }
            # 前缀比较: 补尾 / 防根路径误匹配("/"+"/" → "//" 不会命中 "$g"/* 除非 g="" 已过滤)
            case "$norm/" in "$gn"/*) echo "[DEPLOY] REJECTED: $slot (属受保护路径 $g 内部 — 危险路径)"; return 1 ;; esac
        done
        return 0
    }
    # trap 清理本批次残留 tmp: 各 slot 成功时已 mv 归位, 失败路径(cp/mv)的 tmp 在 .tmp-new.$$ 族;
    # tmpdir 构造含前导点(隐藏文件), glob 需 . 前缀显式匹配
    trap 'rm -rf "${SKILL_ROOT}"/.tmp-new.$$* 2>/dev/null || true' EXIT
    DRIFT=0
    IFS=':' read -r -a slots <<< "$SLOTS"
    for slot in "${slots[@]}"; do
        [ -n "$slot" ] || continue
        if ! validate_slot "$slot"; then
            DRIFT=1
            continue
        fi
        slotdir="${slot%/}"                      # 末尾 / 归一(绝对路径, 已无空白)
        tmpdir="${slotdir%.tmp-new.$$}.tmp-new.$$"   # 归一: 若 slotdir 已残留本批 tmp 名则稳定收敛, 避免后缀叠加
        # 原子替换: cp 先验证, 成功后 rm 旧 + mv; cp 失败 → 原 slot 原样保留
        if ! cp -rL "$SKILL_ROOT" "$tmpdir" 2>/dev/null; then
            rm -rf "$tmpdir" 2>/dev/null || true
            echo "[DEPLOY] DRIFT: $slotdir (cp 失败 — 槽位不可写或路径不存在; 原 slot 保留未动)"
            DRIFT=1
            continue
        fi
        rm -rf "$slotdir" 2>/dev/null || true
        if ! mv "$tmpdir" "$slotdir" 2>/dev/null; then
            rm -rf "$tmpdir" 2>/dev/null || true
            echo "[DEPLOY] DRIFT: $slotdir (mv 失败 — 原 slot 保留未动)"
            DRIFT=1
            continue
        fi
        if diff -rq "$SKILL_ROOT" "$slotdir" >/dev/null 2>&1; then
            echo "[DEPLOY] IDENTICAL: $slotdir"
        else
            echo "[DEPLOY] DRIFT: $slotdir"
            DRIFT=1
        fi
    done
    if [ "$DRIFT" -eq 1 ]; then
        echo "[DEPLOY] DEPLOY_DRIFT: 至少一位部署位 DRIFT/REJECTED(详见上)" >&2
        exit 6
    fi
    echo "[DEPLOY] OK: 全部部署位 IDENTICAL"
fi

# 成功: MERGED 或 ALREADY_MERGED, 且 --deploy 全 IDENTICAL
exit 0
