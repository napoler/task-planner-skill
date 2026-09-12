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
#   --deploy         合并后对部署位执行既有 SOP(改名换位: slot→.bak.$$ → tmp→slot → rm .bak; diff -rq 对账);
#                    逐位 [DEPLOY] 判定, 任一 DRIFT exit 6
#                    守卫语义(2026-09-12 R3): $HOME 内部 slot = 白名单口径 — 仅当位于任一默认部署根
#                    ($HOME/.zcode/skills/task-planner、$HOME/.claude/skills/task-planner、
#                    $HOME/.config/opencode/skills/task-planner)之内(或等于)才放行; 其余 $HOME 子路径
#                    (含 $HOME/.zcode 本身、$HOME/.ssh) → REJECTED;
#                    显式逃生口 --allow-home-slot(默认关): $HOME 内部任意子路径放行(风险自担, 无生产需要);
#                    SKILL_ROOT/WT_PATH/MAIN_REPO = exact + 内部 + 祖先全向
#   --force          V5 MASTER_AHEAD 时强制继续(默认中止; merge 冲突仍 exit 7 STOP)
#   --allow-home-slot  仅 --deploy 相关: $HOME 内部任意子路径放行(默认关; 生产三默认位均在白名单内, 无需要)
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
#   slot 列表由 env TASK_PLANNER_DEPLOY_SLOTS(冒号分隔)覆盖(供自测注入); 未设默认 3 真实位;
#   HOME 未设置且 env 未覆盖 → [DEPLOY] REJECTED: (HOME 未设置 — 默认部署位不可解析) + exit 6。
#   slot 安全: IFS=':' 解析 + validate_slot 守卫(拒空/非绝对/含空白或 glob/规范化后为
#     / 或 .git 末组件 → REJECTED exit 6);
#     2026-09-12 洞①②修复轮: 新增祖先方向守卫 — 任一 guard 位于 slot 内部(slot 是 guard 的祖先)
#     即 REJECTED(slot 若包含任一受保护路径, rm -rf slot 必然摧毁它); GUARDS 移除失效的 "/" 条目
#     (洞①: gn="/" 时前缀模式退化为 "//"/* 双斜杠永不命中, "/" 守卫形同虚设; 根场景已由
#     norm="/" 显式拒绝 + $HOME 等祖先/内部双向守卫覆盖);
#     替换原子(改名换位): cp -rL 至同目录 .tmp-new.$$ → mv slot→.bak.$$ → mv tmp→slot → rm .bak;
#     常规退出/TERM/INT 由 EXIT trap 兜底恢复(.bak 尚在且 slot 缺席时 mv 回原位); SIGKILL 不可捕获,
#     残留 slot.bak.$$ 需人工 mv 回原位; slot 常规失败路径均恢复原位(SIGKILL 不可捕获, 见 R3 ②)
#   2026-09-12 R2 复审修复轮: ① 守卫比较前统一规范化(norm_path: realpath -m 优先, 失败回退纯串
#     归并 //→/、剥 .、.. 弹出) — //tmp/x、/tmp/./x、/tmp/y/../x 与 /tmp/x 同判;
#     ② 守卫语义分级(GUARDS 带 :type 后缀): $HOME:home 豁免 slot 位于
#     $HOME 内部(三默认部署位都在 $HOME 内, 全向则生产路径永不成功);
#     SKILL_ROOT/WT_PATH/MAIN_REPO:full = exact+inside+ancestor 全向;
#     ③ 原子替换改改名换位(slot→.bak.$$ → tmp→slot → rm .bak), 任一 mv 失败恢复原位,
#     slot 常规失败路径均恢复原位(SIGKILL 不可捕获, 残留 .bak 需人工 mv 回); cp 前 rm -rf tmpdir 防 PID 复用残留嵌套;
#     ④ 本批次 tmpdir 数组累积 trap 逐个清理(不再用前缀 glob 误删他进程);
#     ⑤ V3 rename 记录(R/C 双 NUL 记录)解析时额外消费下一条旧路径, 新路径计入重叠集;
#     ⑥ worktree list --porcelain awk 改 branch 行累积至下一块/END 输出, 保证 path|branch 配对
#     (兜底判据③ bare-origin+base-branch 形态真正可达);
#     ⑦ MERGE_HEAD 检测改绝对路径(--path-format=absolute; 不支持时回退 --git-dir 相对则 cd 主仓解析)。
#   2026-09-12 R3 复审修复轮: ① $HOME home 豁免改白名单口径 — 复审实证 slot=$HOME/.zcode 在旧
#     "home 类型整体豁免 inside"下 rc=0 假绿且 $HOME/.zcode/{skills,memories,AGENTS.md} 被摧毁;
#     新语义: home 类型 slot 仅当 norm_path(slot) 位于 DEFAULT_DEPLOY_ROOTS 三默认部署根之一
#     (之内或等于)才放行, 其余 $HOME 子路径按 inside 规则 REJECTED; 显式逃生口 --allow-home-slot
#     (默认关, 风险自担);
#     ② EXIT trap 体封成 cleanup_tmpdirs() 函数(顶层 local 报错), stderr 零输出; 正常退出/TERM/INT 由
#     EXIT trap 兜底恢复 slot(.bak 尚在且 slot 缺席 → mv 回原位); SIGKILL 不可捕获, 残留
#     slot.bak.$$ 需人工 mv 回原位;
#     ③ V3 两侧口径统一: MAIN_DIRTY 与 BRANCH_FILES 同加 -c core.quotePath=false + BRANCH_FILES
#     改 --name-only -z NUL 解析 — 非 ASCII 路径重叠可检出;
#     ④ P3: SLOTS 默认值 ${HOME:-} 口径 + HOME 空显式 REJECTED; 孤立注释删除/顶层缩进归零;
#     头注释替换序列改改名换位措辞。
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
Usage: smart-merge-back.sh <worktree-path> [--base master] [--deploy] [--force] [--allow-home-slot]
退出码: 0 成功 | 2 PRECHECK_INVALID/ARG_INVALID | 3 PRECHECK_DIRTY | 4 SCOPE_OVERLAP
        5 MASTER_AHEAD | 6 DEPLOY_DRIFT | 7 MERGE_CONFLICT | 8 MERGE_IN_PROGRESS
--allow-home-slot  $HOME 内部任意 slot 放行(默认关, 风险自担)
EOF
}

WT_PATH=""
BASE="master"
DO_DEPLOY=0
DO_FORCE=0
ALLOW_HOME_SLOT=0

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
    --allow-home-slot) ALLOW_HOME_SLOT=1; shift ;;
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
# [2026-09-12 R2 P2] branch 行累积到下一 worktree 行/END 才输出(保证 path|branch 配对;
#  原实现在 worktree 行即时输出时 branch 尚未累积 → 配对错位, 兜底判据③(主仓带 base branch
#  的 bare-origin 形态)真正不可达)
_P="$(printf '%s\n' "$WTLIST_P" | awk '
    /^worktree /{ if (wt != "") print wt "|" br; wt=$2; br="" }
    /^branch refs\/heads\//{ br=$0; sub(/^branch /, "", br) }
    END{ if (wt != "") print wt "|" br }')"
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

# [2026-09-12 R2 P1-2] MERGE_HEAD 检测改绝对路径: 首选 --path-format=absolute(部分 git 版本
# 不支持); 回退: rev-parse --git-dir, 相对路径时先 cd 主仓解析为绝对
mh_abs="$(git -C "$MAIN_REPO" rev-parse --path-format=absolute --git-path MERGE_HEAD 2>/dev/null)"
if [ -z "$mh_abs" ]; then
    gh_dir="$(git -C "$MAIN_REPO" rev-parse --git-dir 2>/dev/null)" || gh_dir=""
    if [ -n "$gh_dir" ]; then
        case "$gh_dir" in /*) mh_abs="$gh_dir/MERGE_HEAD" ;; *) mh_abs="$MAIN_REPO/$gh_dir/MERGE_HEAD" ;; esac
    fi
fi
[ -n "$mh_abs" ] && [ -f "$mh_abs" ] && {
    echo "[V1] MERGE_IN_PROGRESS: 主仓 $MAIN_REPO 有未完成合并(存在 MERGE_HEAD)"
    echo "[V1] 恢复: git -C $MAIN_REPO merge --abort" >&2
    exit 8
}

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
# [2026-09-12 R2 P2: V3 rename 记录: R/C 为两条 NUL 记录(新路径+旧路径), 状态首字符 R/C 时
#  额外消费下一条为旧路径; 重叠集取新路径(rename 会改写的目标)]
# [2026-09-12 R3 P2: 两侧口径统一 — 都走 -c core.quotePath=false 原始字节 + NUL 安全解析,
#  非 ASCII 路径(如 中文.txt)不再被 git 转义为 \344... 假阴性重叠漏检]
MAIN_DIRTY="$(git -C "$MAIN_REPO" -c core.quotePath=false status --porcelain -z -uall 2>/dev/null |
    while IFS= read -r -d '' entry; do
        st="${entry:0:3}"
        printf '%s\n' "${entry:3}"
        case "$st" in
        R??|C??) IFS= read -r -d '' _old || true ;;  # 第二条 NUL 记录 = 旧路径, 额外消费
        esac
    done)"
# 分支相对 merge-base 的变更文件, 相对主仓路径
MB="$(git -C "$MAIN_REPO" merge-base "$BASE" "$BRANCH" 2>/dev/null)"
if [ -z "$MB" ]; then
    echo "[V3] PRECHECK_INVALID: 无法计算 merge-base($BASE...$BRANCH)" >&2
    exit 2
fi
# [2026-09-12 R3 P2] BRANCH_FILES 与 MAIN_DIRTY 同口径: -c core.quotePath=false + --name-only -z
# NUL 解析(原换行解析对非 ASCII/含换行路径均失真); 两侧同为原始字节, 非 ASCII 路径重叠可检出
BRANCH_FILES="$(git -C "$MAIN_REPO" -c core.quotePath=false diff --name-only -z "$MB" "$BRANCH" 2>/dev/null |
    tr '\0' '\n')"
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
    # [2026-09-12 R2 P0] SKILL_ROOT 推导消除 /scripts/.. 字面量: cd+pwd -P 输出规范化绝对路径
    # (dirname 比 ${BASH_SOURCE%/*} 语义更明确, 与脚本目录推导口径一致)
    SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
    # [2026-09-12 R3 P3] HOME 未设置且 env 未覆盖 → 显式 REJECTED + DRIFT=1(exit 6), 不静默继续。
    # SLOTS 三路均必赋值(防 set -u 下未初始化变量; 原 R3 缺陷: HOME 空分支漏赋 SLOTS,
    # read <<< "" 产出单空元素循环被跳过 → exit 0 假绿, 已实证修复)。DRIFT 必须先于分支初始化
    # (原 477 行循环前无条件 DRIFT=0 会把此处置的 DRIFT=1 重置 → 假绿回归, 已实证修复)
    DRIFT=0
    if [ -n "${TASK_PLANNER_DEPLOY_SLOTS:-}" ]; then
        SLOTS="$TASK_PLANNER_DEPLOY_SLOTS"
    elif [ -n "${HOME:-}" ]; then
        SLOTS="$HOME/.zcode/skills/task-planner:$HOME/.claude/skills/task-planner:$HOME/.config/opencode/skills/task-planner"
    else
        SLOTS=""
        echo "[DEPLOY] REJECTED: (HOME 未设置 — 默认部署位不可解析)"
        DRIFT=1
    fi
    # 受保护路径集合(带类型, |:type 后缀):
    # [2026-09-12 R3 P0] $HOME:home 白名单口径(slot=$HOME/.zcode 假绿实证 — 摧毁 $HOME/.zcode/{skills,memories,AGENTS.md}):
    # home 类型 slot **仅当** norm_path(slot) 位于任一 DEFAULT_DEPLOY_ROOTS 默认部署根之内(或等于)才放行;
    # 其余 $HOME 子路径($HOME/.ssh、$HOME/.zcode 本身等) → 按 inside 规则 REJECTED。
    # 显式逃生口 --allow-home-slot(默认关): $HOME 内部任意子路径放行(风险自担, 文档注明)。
    # full=exact+inside+ancestor 全向(SKILL_ROOT/WT_PATH/MAIN_REPO)。
    # ${HOME:-} 防 env -u HOME 下 set -u 中止; 空 guard 在比较前已过滤。
    GUARDS="${HOME:-}:home|$SKILL_ROOT:full|$WT_PATH:full|$MAIN_REPO:full"
    # [2026-09-12 R2 P3] 本批次 tmpdir 数组累积, trap 逐个清理(原前缀 glob 匹配他进程 .tmp-deploy.*)
    BATCH_TMPDIRS=()
    # [2026-09-12 R3 P2] trap 体封成 cleanup_tmpdirs() 函数(原顶层 local 报错), stderr 零输出;
    # [2026-09-12 R3 P3] 正常退出/TERM/INT 由 EXIT trap 兜底恢复(.bak 尚在且 slot 缺席 → mv 回原位);
    # SIGKILL 不可捕获, 残留 slot.bak.$$ 需人工 mv 回原位
    slotbak=""
    slotdir=""
    cleanup_tmpdirs() {
        for _t in ${BATCH_TMPDIRS[@]+"${BATCH_TMPDIRS[@]}"}; do
            [ -n "$_t" ] && rm -rf "$_t" 2>/dev/null
        done
        [ -n "${slotbak:-}" ] && [ ! -e "${slotdir:-x}" ] && [ -e "${slotbak:-y}" ] && mv "$slotbak" "$slotdir" 2>/dev/null
        return 0
    }
    trap 'cleanup_tmpdirs' EXIT

    # [2026-09-12 R2 P0] 统一规范化: realpath -m 优先(不要求路径存在); 失败回退纯串归并
    # (循环 //→/、逐段剥 .、.. 弹出上一段, /.. → /)
    norm_path() {
        local p
        p="$(realpath -m -- "$1" 2>/dev/null)" && { printf '%s\n' "$p"; return 0; }
        p="${1#./}"
        local -a seg=()
        local s
        local IFS='/'
        local raw="$p"
        read -r -a seg <<< "$raw"
        local out=()
        for s in "${seg[@]}"; do
            if [ -z "$s" ] || [ "$s" = "." ]; then continue; fi
            if [ "$s" = ".." ]; then
                [ ${#out[@]} -gt 0 ] && unset 'out[${#out[@]}-1]'; continue
            fi
            out+=("$s")
        done
        if [ ${#out[@]} -eq 0 ]; then printf '/\n'; else
            printf '/%s\n' "$(IFS='/'; echo "${out[*]}")"
        fi
    }

    # [2026-09-12 R2 P0] 守卫一次性规范化(循环外算好 norm 后数组): GUARDS 每项 "path:type" → "normpath:type"
    IFS='|' read -r -a guard_raw <<< "$GUARDS"
    guard_norm=()
    guard_type=()
    for g in "${guard_raw[@]}"; do
        [ -n "$g" ] || continue
        case "$g" in *:*) guard_norm+=("$(norm_path "${g%:*}")"); guard_type+=("${g##*:}") ;;
                 *) guard_norm+=("$(norm_path "$g")"); guard_type+=("full") ;;
        esac
    done

    # [2026-09-12 R3 P0] 默认部署根白名单(三根, 冒号分隔): home 类型 slot 仅当位于
    # 任一部署根之内(或等于)才放行 — 其余 $HOME 子路径按 inside 规则 REJECTED
    DEFAULT_DEPLOY_ROOTS="${HOME:-}/.zcode/skills/task-planner:${HOME:-}/.claude/skills/task-planner:${HOME:-}/.config/opencode/skills/task-planner"
    # 白名单根逐条规范化(循环外算好, 空根 — HOME 未设 — 比较前跳过)
    default_roots_norm=()
    if [ -n "${HOME:-}" ]; then
        IFS=':' read -r -a _dr_raw <<< "$DEFAULT_DEPLOY_ROOTS"
        for _r in "${_dr_raw[@]}"; do
            [ -n "$_r" ] || continue
            default_roots_norm+=("$(norm_path "$_r")")
        done
    fi

    validate_slot() {   # <slot> → 合法 return 0; 任一命中打印 REJECTED 并 return 1
        local slot="$1"
        [ -n "$slot" ] || { echo "[DEPLOY] REJECTED: $slot (空串 — 危险路径)"; return 1; }
        case "$slot" in /*) ;; *) echo "[DEPLOY] REJECTED: $slot (非绝对路径 — 危险路径)"; return 1 ;; esac
        case "$slot" in *" "*|*$'\t'*|*$'\n'*|*'*'*|*'?'*|*'['*) echo "[DEPLOY] REJECTED: $slot (含空白/glob 字符 — 危险路径)"; return 1 ;; esac
        # [2026-09-12 R2 P0] 规范化先于守卫比较: //tmp/x、/tmp/./x、/tmp/y/../x 三种拼写与 /tmp/x 同判
        local norm="$(norm_path "$slot")"
        [ -z "$norm" ] && { echo "[DEPLOY] REJECTED: $slot (规范化后为空 — 危险路径)"; return 1; }
        [ "$norm" = "/" ] && { echo "[DEPLOY] REJECTED: / (规范化后为根 — 危险路径)"; return 1; }
        # .git 末组件按规范化后判定
        case "$norm" in .git|*/.git) echo "[DEPLOY] REJECTED: $slot (末组件 .git — 危险路径)"; return 1 ;; esac
        # [2026-09-12 R3 P0] 守卫比较按类型分支:
        #   home = 白名单口径(默认关): norm 位于任一 DEFAULT_DEPLOY_ROOTS 部署根内(或等于) → 放行
        #          (跳过其余 $HOME 检查, 生产三默认位均在 $HOME 下); 否则按 inside 规则 REJECTED
        #          (复审实证: 旧"home 整体豁免 inside"下 slot=$HOME/.zcode → rc=0 假绿,
        #           $HOME/.zcode/{skills,memories,AGENTS.md} 被摧毁)。
        #          显式逃生口 --allow-home-slot(默认关): $HOME 内部任意子路径放行, 风险自担。
        #   full = exact+inside+ancestor 全向(SKILL_ROOT/WT_PATH/MAIN_REPO)
        local i
        for i in $(seq 0 $((${#guard_norm[@]}-1))); do
            local gn="${guard_norm[$i]}" gt="${guard_type[$i]}"
            [ -n "$gn" ] || continue
            [ "$norm" = "$gn" ] && { echo "[DEPLOY] REJECTED: $slot (= 受保护路径 ${guard_raw[$i]%:*})"; return 1; }
            if [ "$gt" = "home" ]; then
                # inside: slot 位于 $HOME 内部
                if ! [ "$ALLOW_HOME_SLOT" -eq 1 ]; then
                    case "$norm/" in
                    "$gn"/*)
                        for r in ${default_roots_norm[@]+"${default_roots_norm[@]}"}; do
                            [ -n "$r" ] || continue
                            case "$norm/" in "$r"/*|"$r") continue 2 ;; esac
                        done
                        echo "[DEPLOY] REJECTED: $slot (属 \$HOME 内部且不在默认部署根白名单内 — 危险路径; --allow-home-slot 可显式放行, 风险自担)"
                        return 1 ;;
                    esac
                fi
            else
                # 内部方向: slot 位于 guard 内部(full 全向才拒; home 已由白名单分支处理)
                case "$norm/" in "$gn"/*) echo "[DEPLOY] REJECTED: $slot (属受保护路径 ${guard_raw[$i]%:*} 内部 — 危险路径)"; return 1 ;; esac
            fi
            # 祖先方向(两种类型均拒): guard 位于 slot 内部 → rm -rf slot 必然摧毁 guard
            case "$gn/" in "$norm"/*) echo "[DEPLOY] REJECTED: $slot (是受保护路径 ${guard_raw[$i]%:*} 的祖先 — 危险路径)"; return 1 ;; esac
        done
        # home guard 为空(HOME 未设)时白名单无基准 — slot 非 $HOME 内部则无家可避, 直接放行(无 $HOME 检查可做)
        return 0
    }
    # [2026-09-12 R3] 部署循环恒执行(不再条件包裹): HOME 未设且 env 未覆盖时 SLOTS="" → 循环零次,
    # DRIFT=1 已在上方(SLOTS 分支, 先于循环初始化)置位 → 仍走 exit 6
    # (DRIFT=0 初始化已移至 SLOTS 分支之前; 条件包裹会吞掉 HOME 空的 DRIFT 标志, 均已实证修复 rc=0 假绿回归)
    IFS=':' read -r -a slots <<< "$SLOTS"
    for slot in "${slots[@]}"; do
        [ -n "$slot" ] || continue
        if ! validate_slot "$slot"; then
            DRIFT=1
            continue
        fi
        slotdir="${slot%/}"                      # 末尾 / 归一(绝对路径, 已无空白)
        tmpdir="${slotdir%.tmp-new.$$}.tmp-new.$$"   # 归一: 若 slotdir 已残留本批 tmp 名则稳定收敛, 避免后缀叠加
        # 原子替换(改名换位): cp 先验证, 成功后 slot→.bak.$$ → tmp→slot → rm .bak —
        # [2026-09-12 R3 P3] 常规失败路径各 mv 失败处均恢复原位; 正常退出/TERM/INT 由 EXIT trap 兜底
        # 恢复(.bak 尚在且 slot 缺席 → mv 回原位); SIGKILL 不可捕获, 残留 slot.bak.$$ 需人工 mv 回
        # cp 前 rm -rf tmpdir([2026-09-12 R3 P3] 防 PID 复用残留嵌套)
        rm -rf "$tmpdir" 2>/dev/null || true
        if ! cp -rL "$SKILL_ROOT" "$tmpdir" 2>/dev/null; then
            rm -rf "$tmpdir" 2>/dev/null || true
            echo "[DEPLOY] DRIFT: $slotdir (cp 失败 — 槽位不可写或路径不存在; 原 slot 保留未动)"
            DRIFT=1
            continue
        fi
        BATCH_TMPDIRS+=("$tmpdir")
        slotbak="$slotdir.bak.$$"
        if ! mv "$slotdir" "$slotbak" 2>/dev/null; then
            rm -rf "$tmpdir" 2>/dev/null || true
            slotbak=""
            echo "[DEPLOY] DRIFT: $slotdir (slot→.bak 换位失败 — 原 slot 保留未动)"
            DRIFT=1
            continue
        fi
        if ! mv "$tmpdir" "$slotdir" 2>/dev/null; then
            mv "$slotbak" "$slotdir" 2>/dev/null || true   # 恢复原位(常规失败路径)
            rm -rf "$slotbak" 2>/dev/null
            slotbak=""
            echo "[DEPLOY] DRIFT: $slotdir (tmp→slot 换位失败 — 原 slot 已恢复原位)"
            DRIFT=1
            continue
        fi
        rm -rf "$slotbak" 2>/dev/null
        slotbak=""
        BATCH_TMPDIRS=("${BATCH_TMPDIRS[@]:1}")    # 归位后出队, trap 不再清(已变 slot)
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
