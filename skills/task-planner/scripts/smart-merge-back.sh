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
#   --deploy         合并后对部署位执行 F5 staging 原子化部署 — 2026-10-10 task-v159 替代旧直写路径
#                    (D4 事故根因: 2026-10-10 04:45-04:49 claude 写入后 zcode 删除致技能全局停摆):
#                    ①staging: 全部 slot 先行 cp -rL 至 cache 根 <slot>.stage.$$(内容就位与指针切换分离,
#                    任 slot stage 失败=整体 exit 1 不进入 swap); ②swap: 先 mv 旧 slot 到 cache backup
#                    (旧技能立即退出扫描根) → mv stage→slot → post-verify PASS → 删除 backup; ③post-verify:
#                    身份断言(basename+规范化路径精确等于声明 slot)+存在性+diff -r 零差异, 任一失败 exit 1,
#                    禁止部分 slot 成功当整体成功; EXIT trap 清理 stage/恢复 backup。
#                    源=主仓 skills/task-planner — 2026-09-17 task-v077 修复假 IDENTICAL: 部署源/对账基准不再用
#                    SKILL_ROOT(脚本运行处), 从部署位运行亦以主仓 canonical 内容为源);
#                    slot 校验 REJECTED / 部署源缺失 → DRIFT exit 6(fail-closed);
#                    [2026-11-26 事故修复] slot 身份校验: basename 必须等于期望技能名且规范化路径精确等于
#                    已配置扫描根下 <root>/<skill-name>; 父目录级/祖先/后代/相对/worktree/主仓根一律
#                    [slot-identity] REJECTED, --allow-home-slot 不绕过身份校验(仅影响 $HOME 白名单)。
#                    [2026-11-26 事故修复] TASK_PLANNER_DEPLOY_CACHE_ROOT(默认 ${HOME}/.cache/task-planner-deploy):
#                    stage/backup 必须落在 cache 根, 绝不可落在 skills 扫描根或任何 git 仓目录; cache 根落在
#                    扫描根/仓内 → fail-closed [deploy-cache] exit 1。Why: .bak/.stage 留扫描根且含 SKILL.md
#                    时仍被加载器识别=重大漏洞; 备份放 .zcode(git 管理仓)会搞乱项目。
#                    --deploy 对账通过后自动执行池成员顶层枚举挂载(install_pool_links): <skills>/<member> 相对软链→task-planner/review-library/<member>;冲突跳过 LINK-WARN;增强段不改 exit 码 [task-v105]
#                    [2026-11-25 task-skill-deploy-fix] B2: 默认槽位扩为 5 位(+cursor/continue)，不加入 .agents
#                    (全局保护区,走 TASK_PLANNER_DEPLOY_SLOTS env 显式覆盖)；SLOTS/DEFAULT_DEPLOY_ROOTS 同源函数输出。
#                    [2026-11-25 task-deploy-all-skills] F6: --deploy 现含全量 skill 同步(末尾调 canonical install-companion.sh,
#                    把 task-planner 之外全部 skill 发到所有探测工具根); Why: 原路径只发 task-planner 一个 skill, 其余完全不同步;
#                    TASK_PLANNER_DEPLOY_SLOTS 已注入(selftest 临时 slot)或 TASK_PLANNER_DEPLOY_ALL=0 时跳过(防 companion 污染真实工具根)。
#                    守卫语义(2026-09-12 R3): $HOME 内部 slot = 白名单口径 — 仅当位于任一默认部署根
#                    ($HOME/.zcode/skills/task-planner、$HOME/.claude/skills/task-planner、
#                    $HOME/.config/opencode/skills/task-planner、$HOME/.cursor/skills/task-planner、
#                    $HOME/.continue/skills/task-planner)之内(或等于)才放行; 其余 $HOME 子路径
#                    (含 $HOME/.zcode 本身、$HOME/.ssh) → REJECTED;
#                    显式逃生口 --allow-home-slot(默认关): $HOME 内部任意子路径放行(风险自担, 无生产需要);
#                    SKILL_ROOT/WT_PATH/MAIN_REPO = exact + 内部 + 祖先全向
#   --legacy         仅 --deploy 相关: 走 F5 之前旧直写路径(cp→rm→mv 改名换位 + 两级对账 L1/L2);
#                    2026-10-10 task-v159 保留为 fallback(新路径默认启用; 旧路径失败语义 exit 6 不变)
#   --force          V5 MASTER_AHEAD 时强制继续(默认中止;  merge 冲突仍 exit 7 STOP)
#   --allow-home-slot  仅 --deploy 相关: $HOME 内部任意子路径放行(默认关; 生产三默认位均在白名单内, 无需要)
#   TASK_PLANNER_DEPLOY_CACHE_ROOT  仅 --deploy 相关: stage/backup 落盘根目录(默认 ${HOME}/.cache/task-planner-deploy);
#                    必须位于 skills 扫描根与 git 仓之外, 否则 [deploy-cache] fail-closed exit 1
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
#   V6 合并执行(git -C <主仓> merge --no-ff branch)          → [V6] MERGED: <commit>; 冲突 exit 7 MERGE_CONFLICT(收口义务语义, Rule 101.2)
#
# 后续输出:
#   [CLEANUP] git worktree remove <path> && git branch -d <branch>   (只提示不执行 — 清理时机留主进程)
#   --deploy: 逐位 [DEPLOY] REJECTED|IDENTICAL|DRIFT: <位>; 任一 REJECTED/DRIFT → exit 6 DEPLOY_DRIFT
#     (2026-09-17 task-v077: IDENTICAL 判定基准 = 主仓 skills/task-planner(DEPLOY_SRC); 部署源缺失亦 DRIFT exit 6)
#   slot 列表由 env TASK_PLANNER_DEPLOY_SLOTS(冒号分隔)覆盖(供自测注入); 未设默认 5 真实位(+cursor/continue,
#   .agents 不进默认、走 env 显式覆盖 — 全局保护区);
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
#     新语义: home 类型 slot 仅当 norm_path(slot) 位于 DEFAULT_DEPLOY_ROOTS 五默认部署根之一
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
#   0 = 成功(MERGED 或 ALREADY_MERGED, 且 --deploy 全位 IDENTICAL; 对账基准=主仓 skills/task-planner — task-v077)
#   2 = PRECHECK_INVALID      (worktree 目录不存在 / 分支名不合规 / 不在 worktree list 在册)
#   3 = PRECHECK_DIRTY        (worktree 有未提交变更, 列出文件)
#   4 = SCOPE_OVERLAP         (主仓未提交文件 ∩ 分支变更文件非空, 列出交集)
#   5 = MASTER_AHEAD          (base 前进于 merge-base, 建议先 merge base 入分支再重跑; --force 才继续)
#   6 = DEPLOY_DRIFT          (--deploy 任一位 DRIFT: 两级对账 L1 文件集合差/L2 内容定向 diff 有差异(基准=主仓 skills/task-planner) / cp 失败 / 部署源缺失 / slot 校验 REJECTED(危险路径))
#   7 = MERGE_CONFLICT        (merge 冲突状态报告 — 冲突=调用方收口义务(2026-11-04 Rule 101.2: LLM 侧走 41.1 消解链解决所有冲突+复验后重跑本脚本; 仅消解配额耗尽才真门 STOP 报告用户); 主仓残留 mid-merge, 恢复: git -C <主仓> merge --abort)
#   8 = MERGE_IN_PROGRESS     (V1 检测主仓存在未完成合并 MERGE_HEAD — 恢复: git -C <主仓> merge --abort 后重跑)
#   2 = ARG_INVALID           (参数错误: 未知选项/缺参/多余位置参数 — 与文档对齐, 原 exit 1 矛盾已修)
#   1 = 环境错误(缺参数已归 2; git 命令失败等未归类项)
#
# 已知偏差(记录在案): 目录名双校验为 "basename = task-id 或 *-$TASK_ID 后缀匹配" —
#   兼容 task-id 尾缀变体命名(2026-11-04 Rule 100 = <project-root>/tmp/worktrees/<task-id>; 旧集中目录 <repo>-worktrees/<task-id> / 旧式 <repo>-wt-<task-id>);
#   属有意放宽, 非实现误差。slot 校验拒绝含空格/空白/glob 字符路径(REJECTED exit 6)。
# 2026-09-12 S2 修复轮(P0/P1/P2/P3 findings): --deploy 重写(IFS 解析 + validate_slot 守卫 + cp→rm→mv 原子替换)、
#   MAIN_REPO 改 worktree list --porcelain、V3 NUL 安全、MERGE_CONFLICT 恢复指引 + V1 MERGE_IN_PROGRESS exit 8、ARG_INVALID exit 2。
set -u

# ---------- 参数解析 ----------
usage() {
    cat <<'EOF'
Usage: smart-merge-back.sh <worktree-path> [--base master] [--deploy] [--force] [--allow-home-slot] [--legacy]
退出码: 0 成功 | 2 PRECHECK_INVALID/ARG_INVALID | 3 PRECHECK_DIRTY | 4 SCOPE_OVERLAP
        5 MASTER_AHEAD | 6 DEPLOY_DRIFT | 7 MERGE_CONFLICT | 8 MERGE_IN_PROGRESS
        1 环境错误/未归类项(含 --deploy F5 staging/swap/post-verify 阶段失败)
--allow-home-slot  $HOME 内部任意 slot 放行(默认关, 风险自担)
--legacy          --deploy 走 F5 前旧直写路径(fallback; 新路径默认)
EOF
}

WT_PATH=""
BASE="master"
DO_DEPLOY=0
DO_FORCE=0
ALLOW_HOME_SLOT=0
DO_LEGACY=0

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
    --legacy) DO_LEGACY=1; shift ;;
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
# (worktree 目录名 basename 即 task-id: 2026-11-04 Rule 100 新规范 = <project-root>/tmp/worktrees/<task-id>, 旧 §11.2 集中目录 <repo>-worktrees/<task-id> 亦 basename=task-id;
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
        echo "[V6] MERGE_CONFLICT — 冲突=收口义务(2026-11-04 Rule 101.2): 调用方走 41.1 消解链(并集/三方/手动解+复验)解决所有冲突后重跑本脚本; 仅消解配额耗尽才真门 STOP 报告用户" >&2
        # [2026-09-12 S2 P2: 主仓可能残留 mid-merge 态, 重跑前须先 abort, 否则 V1 MERGE_HEAD 检测 exit 8 自锁]
        echo "[V6] 恢复: git -C $MAIN_REPO merge --abort (清除 mid-merge 态后重跑; 需保留合并结果则手工解冲突)" >&2
        # [Rule 97.6 仲裁 / 2026-11-04 Rule 101.2] 主进程消费本 [V6] MERGE_CONFLICT exit 7 时先走 41.1 消解链配额（并集/三方/手动解冲突+复验）解决所有冲突后重跑本脚本；仅消解配额耗尽才真门（Rule 95.5）STOP 报告用户；本脚本 exit 7=机械状态报告不变，收口义务在 LLM 行为层（101.2），不改脚本行为
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
# [2026-09-17 task-v077: 部署源/对账基准由 SKILL_ROOT(脚本运行处)改为主仓 $MAIN_REPO/skills/task-planner
#  (DEPLOY_SRC) — 修复从部署位运行时的假 IDENTICAL(自 copy 自 diff 恒真); 源缺失 fail-closed DRIFT exit 6。]
if [ "$DO_DEPLOY" -eq 1 ]; then
    # [2026-09-12 R2 P0] SKILL_ROOT 推导消除 /scripts/.. 字面量: cd+pwd -P 输出规范化绝对路径
    # (dirname 比 ${BASH_SOURCE%/*} 语义更明确, 与脚本目录推导口径一致)
    SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
    # [2026-09-17 task-v077] DEPLOY_SRC 推导: 部署源 = 主仓 canonical 内容 $MAIN_REPO/skills/task-planner。
    # 修复 v076 实证的假 IDENTICAL: 原实现以 SKILL_ROOT(脚本运行处)为 cp 源与 diff 基准 — 从部署位运行时
    # 以陈旧副本自 copy 再自 diff, 恒真假绿。SKILL_ROOT 仅保留于守卫(GUARDS 行)与自位 REJECTED 提示。
    DEPLOY_SRC="$MAIN_REPO/skills/task-planner"
    # [2026-11-26 事故修复] 期望技能名=部署源 basename, 作为 slot 身份强校验的唯一真源。
    # Why: 2026-11-26 真实事故 — 调用方误传 skills 父目录并用 --allow-home-slot 放行,
    # validate_slot 仅校验路径形态不校验 basename, rm -rf slot 后把 stage 移入导致四位 skills 根被覆盖。
    EXPECTED_SKILL_NAME="$(basename "$DEPLOY_SRC")"
    # [2026-11-26 事故修复] 部署 cache 根: stage/backup 统一落盘于此, 绝不落 skills 扫描根或 git 仓内。
    # Why: .bak/.stage 留在 skills 扫描根且含 SKILL.md 时仍被技能加载器识别=重大漏洞;
    # 备份放 .zcode(git 管理仓)会搞乱项目。用户裁决: 固定放 ~/.cache/task-planner-deploy/。
    DEPLOY_CACHE_ROOT="${TASK_PLANNER_DEPLOY_CACHE_ROOT:-${HOME:-}/.cache/task-planner-deploy}"
    # [2026-09-17 task-v077] fail-closed: 主仓无 skills/task-planner(非标准仓布局) → 显式 DRIFT exit 6,
    # 禁静默回退 SKILL_ROOT(回退 = 假 IDENTICAL 根因复发)。DRIFT 置位延迟至下方 DRIFT 初始化之后
    # (防 R3 P3 类缺陷: 初始化置 0 吞掉标志 → 假绿回归)。
    # [2026-09-12 R3 P3] HOME 未设置且 env 未覆盖 → 显式 REJECTED + DRIFT=1(exit 6), 不静默继续。
    # SLOTS 三路均必赋值(防 set -u 下未初始化变量; 原 R3 缺陷: HOME 空分支漏赋 SLOTS,
    # read <<< "" 产出单空元素循环被跳过 → exit 0 假绿, 已实证修复)。DRIFT 必须先于分支初始化
    # (原 477 行循环前无条件 DRIFT=0 会把此处置的 DRIFT=1 重置 → 假绿回归, 已实证修复)
    # [2026-09-17 task-v077] DRIFT 初始化上移: 源缺失判定已置 DRIFT=1, 此处置 0 会吞掉标志(假绿回归,
    # 与 R3 P3 同类缺陷; 现源缺失→保持 DRIFT=1, HOME 未设分支仍自行置位)
    DRIFT=0
    [ -d "$DEPLOY_SRC" ] || {
        echo "[DEPLOY] DRIFT: (部署源不存在: $DEPLOY_SRC — 主仓布局缺失, 禁回退 SKILL_ROOT)"
        DRIFT=1
    }
	    # [2026-11-25 task-skill-deploy-fix] B2: 共享默认槽位函数，SLOTS/DEFAULT_DEPLOY_ROOTS 同源，避免再漂移。
	    # 不加入 .agents（全局保护区, 走 TASK_PLANNER_DEPLOY_SLOTS env 显式覆盖）。
	    default_deploy_slots() {
	        printf '%s' "$HOME/.zcode/skills/task-planner:$HOME/.claude/skills/task-planner:$HOME/.config/opencode/skills/task-planner:$HOME/.cursor/skills/task-planner:$HOME/.continue/skills/task-planner"
	    }
	    if [ -n "${TASK_PLANNER_DEPLOY_SLOTS:-}" ]; then
	        SLOTS="$TASK_PLANNER_DEPLOY_SLOTS"
	    elif [ -n "${HOME:-}" ]; then
	        SLOTS="$(default_deploy_slots)"
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
    # [2026-11-26 事故修复] 扫描根身份清单: 用于 slot 身份校验与 cache 根隔离检查。
    # Why: slot 必须精确等于 <scan_root>/<EXPECTED_SKILL_NAME>; cache 根若落在扫描根/仓内,
    # stage/backup 仍可被技能加载器识别或污染 git 仓, 必须 fail-closed。
    SCAN_ROOTS=()
    if [ -n "${HOME:-}" ]; then
        SCAN_ROOTS+=("$HOME/.zcode/skills" "$HOME/.claude/skills" "$HOME/.config/opencode/skills" "$HOME/.cursor/skills" "$HOME/.continue/skills")
    fi
    # TASK_PLANNER_DEPLOY_SLOTS 显式注入时, 其父目录也视为扫描根参与隔离检查(不放宽身份白名单)。
    if [ -n "${TASK_PLANNER_DEPLOY_SLOTS:-}" ]; then
        IFS=':' read -r -a _scan_extra <<< "$TASK_PLANNER_DEPLOY_SLOTS"
        for _se in "${_scan_extra[@]}"; do
            [ -n "$_se" ] || continue
            SCAN_ROOTS+=("$(dirname "$_se")")
        done
    fi
    # [2026-09-12 R2 P3] 本批次 tmpdir 数组累积, trap 逐个清理(原前缀 glob 匹配他进程 .tmp-deploy.*)
    BATCH_TMPDIRS=()
    # [task-v159 F5] staging 原子化路径用: slot 归一路径与对应 stage/backup 路径(并行数组, 下标对齐)
    SLOTDIRS=()
    STAGEDIRS=()
    SLOTBACKUPS=()
    SLOTNORMS=()
    # [2026-11-26 事故修复+用户裁决复核] trap 兜底: stage/backup 全部位于 DEPLOY_CACHE_ROOT(扫描根外)。
    # 异常中断时若 slot 缺席且 backup 存在 → 优先恢复(保持旧技能可用)。
    # 2026-11-26 用户裁决: "回位+备份保留""不希望得到任何伤害" — 任何失败回位在 backup→slot 成功后,
    # 必须在 cache 根保留该 backup 的物理副本(cp -a slotdir backupdir); cp 失败仅 stderr WARN, 绝不静默删 backup。
    slotbak=""
    slotdir=""
    cleanup_tmpdirs() {
        for _t in ${BATCH_TMPDIRS[@]+"${BATCH_TMPDIRS[@]}"}; do
            [ -n "$_t" ] && rm -rf "$_t" 2>/dev/null
        done
        # legacy 单槽位兼容变量兜底
        if [ -n "${slotbak:-}" ] && [ ! -e "${slotdir:-x}" ] && [ -e "${slotbak:-y}" ]; then
            if mv "$slotbak" "$slotdir" 2>/dev/null; then
                cp -a "$slotdir" "$slotbak" 2>/dev/null || echo "[deploy-cache] WARN: trap 回位后备份副本重建失败, backup 路径: $slotbak" >&2
            fi
        fi
        local _i _sd _sb _sl
        for _i in $( [ ${#SLOTDIRS[@]} -gt 0 ] && seq 0 $((${#SLOTDIRS[@]}-1)) ); do
            _sl="${SLOTDIRS[$_i]:-}"
            _sd="${STAGEDIRS[$_i]:-}"
            _sb="${SLOTBACKUPS[$_i]:-}"
            [ -n "$_sl" ] || continue
            # slot 缺席且 backup 存在 → 优先恢复(保持旧技能可用)；恢复成功后重建物理备份副本(用户裁决: 回位+备份保留)。
            if [ ! -e "$_sl" ] && [ -n "$_sb" ] && [ -e "$_sb" ]; then
                if mv "$_sb" "$_sl" 2>/dev/null; then
                    if ! cp -a "$_sl" "$_sb" 2>/dev/null; then
                        echo "[deploy-cache] WARN: trap 回位后备份副本重建失败, backup 路径: $_sb" >&2
                    fi
                    [ -n "$_sd" ] && [ -e "$_sd" ] && rm -rf "$_sd" 2>/dev/null
                    continue
                else
                    echo "[deploy-cache] WARN: trap 恢复失败, 保留 backup: $_sb" >&2
                fi
            fi
            # slot 已存在时清理残留 stage; backup 保留策略由调用点决定(成功后显式删除)
            [ -n "$_sd" ] && [ -e "$_sd" ] && rm -rf "$_sd" 2>/dev/null
        done
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

    # [2026-11-26 事故修复] cache 根安全断言: stage/backup 绝不可落在 skills 扫描根或任一 git 仓目录内。
    # Why: 扫描根内的 .stage/.bak 若含 SKILL.md 会被技能加载器识别=重大漏洞; git 仓内备份会搞乱项目。
    # fail-closed: 任何不安全命中 → [deploy-cache] stderr + exit 1。
    assert_cache_root_safe() {
        local cache_norm
        cache_norm="$(norm_path "$DEPLOY_CACHE_ROOT")"
        [ -n "$cache_norm" ] && [ "$cache_norm" != "/" ] || {
            echo "[deploy-cache] FATAL: cache 根无效: $DEPLOY_CACHE_ROOT" >&2
            exit 1
        }
        # 扫描根隔离: cache 根不得等于/位于任一扫描根内, 也不得是扫描根的祖先(防把扫描根整个纳入 cache)
        local sr srn
        for sr in ${SCAN_ROOTS[@]+"${SCAN_ROOTS[@]}"}; do
            [ -n "$sr" ] || continue
            srn="$(norm_path "$sr")"
            [ -n "$srn" ] || continue
            if [ "$cache_norm" = "$srn" ]; then
                echo "[deploy-cache] FATAL: cache 根等于扫描根: $cache_norm == $srn" >&2; exit 1
            fi
            case "$cache_norm/" in "$srn"/*)
                echo "[deploy-cache] FATAL: cache 根位于扫描根内: $cache_norm in $srn" >&2; exit 1 ;;
            esac
            case "$srn/" in "$cache_norm"/*)
                echo "[deploy-cache] FATAL: cache 根是扫描根祖先: $cache_norm ancestor-of $srn" >&2; exit 1 ;;
            esac
        done
        # git 仓隔离: cache 根不得位于任一 git 仓内(覆盖主仓/worktree/任意扫描根下的 git 仓)。
        # 同时做路径前缀兜底: 即使 git 元数据不可用, 位于 MAIN_REPO/WT_PATH 下也拒绝。
        local _git_probe
        for _git_probe in "$MAIN_REPO" "$WT_PATH" "$SKILL_ROOT"; do
            [ -n "$_git_probe" ] || continue
            local _gp_norm
            _gp_norm="$(norm_path "$_git_probe")"
            if [ "$cache_norm" = "$_gp_norm" ]; then
                echo "[deploy-cache] FATAL: cache 根等于仓库路径: $cache_norm == $_gp_norm" >&2; exit 1
            fi
            case "$cache_norm/" in "$_gp_norm"/*)
                echo "[deploy-cache] FATAL: cache 根位于仓库路径内: $cache_norm in $_gp_norm" >&2; exit 1 ;;
            esac
            [ -d "$_git_probe" ] || continue
            local _git_top
            _git_top="$(git -C "$_git_probe" rev-parse --show-toplevel 2>/dev/null || true)"
            [ -n "$_git_top" ] || continue
            _git_top="$(norm_path "$_git_top")"
            if [ "$cache_norm" = "$_git_top" ]; then
                echo "[deploy-cache] FATAL: cache 根位于 git 仓内: $cache_norm in $_git_top" >&2; exit 1
            fi
            case "$cache_norm/" in "$_git_top"/*)
                echo "[deploy-cache] FATAL: cache 根位于 git 仓内: $cache_norm in $_git_top" >&2; exit 1 ;;
            esac
        done
        mkdir -p "$cache_norm" || { echo "[deploy-cache] FATAL: 无法创建 cache 根: $cache_norm" >&2; exit 1; }
        # 额外: 若 cache 根本身在某个 git work tree 中, 也拒绝(覆盖用户自定义路径)
        if git -C "$cache_norm" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            echo "[deploy-cache] FATAL: cache 根位于 git work tree 内: $cache_norm" >&2; exit 1
        fi
        DEPLOY_CACHE_ROOT="$cache_norm"
    }

    # [2026-11-26 事故修复] slot 身份校验: basename 必须等于 EXPECTED_SKILL_NAME, 且规范化路径
    # 精确等于某个已配置扫描根下的 <root>/<EXPECTED_SKILL_NAME>。
    # Why: 2026-11-26 事故 — 父目录级 slot(basename=skills)被 validate_slot 放行,
    # 导致 rm -rf skills 根后四位 skills 根被覆盖。--allow-home-slot 不得绕过此身份校验。
    slot_identity_ok() {
        local norm="$1" raw="$2"
        local bn
        bn="$(basename "$norm")"
        if [ "$bn" != "$EXPECTED_SKILL_NAME" ]; then
            echo "[DEPLOY] REJECTED: $raw [slot-identity] basename '$bn' != expected '$EXPECTED_SKILL_NAME' (slot 必须是技能目录本身)"
            return 1
        fi
        local sr srn expected
        for sr in ${SCAN_ROOTS[@]+"${SCAN_ROOTS[@]}"}; do
            [ -n "$sr" ] || continue
            srn="$(norm_path "$sr")"
            expected="$srn/$EXPECTED_SKILL_NAME"
            if [ "$norm" = "$expected" ]; then
                return 0
            fi
        done
        echo "[DEPLOY] REJECTED: $raw [slot-identity] 规范化路径 '$norm' 不等于任一已配置扫描根下的 <root>/$EXPECTED_SKILL_NAME"
        return 1
    }

    # [2026-11-26 事故修复] post-verify 身份断言: 对账前确认 slot basename/规范化路径仍与声明值一致。
    # Why: 防止同源复制恒真或路径漂移导致假绿 IDENTICAL。
    assert_slot_identity_for_verify() {
        local slotdir="$1" declared_norm="$2"
        local actual_norm bn
        actual_norm="$(norm_path "$slotdir")"
        bn="$(basename "$actual_norm")"
        if [ "$bn" != "$EXPECTED_SKILL_NAME" ]; then
            echo "[DEPLOY] IDENTITY-MISMATCH: $slotdir (basename '$bn' != '$EXPECTED_SKILL_NAME')" >&2
            return 1
        fi
        if [ "$actual_norm" != "$declared_norm" ]; then
            echo "[DEPLOY] IDENTITY-MISMATCH: $slotdir (norm '$actual_norm' != declared '$declared_norm')" >&2
            return 1
        fi
        return 0
    }

    # [2026-11-26 事故修复] cache 内 per-slot 路径生成: 用 slot 规范化路径的 sha256 前缀隔离不同 slot。
    slot_cache_key() {
        local norm="$1"
        if command -v sha256sum >/dev/null 2>&1; then
            printf '%s' "$norm" | sha256sum | awk '{print substr($1,1,16)}'
        elif command -v shasum >/dev/null 2>&1; then
            printf '%s' "$norm" | shasum -a 256 | awk '{print substr($1,1,16)}'
        else
            # fallback: 可读但安全的转义 key
            printf '%s' "$norm" | sed 's#[^A-Za-z0-9._-]#_#g' | tail -c 64
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

	    # [2026-09-12 R3 P0] 默认部署根白名单: home 类型 slot 仅当位于任一部署根之内(或等于)才放行 — 其余 $HOME 子路径按 inside 规则 REJECTED
	    # [2026-11-25 task-skill-deploy-fix] B2: 与 SLOTS 同源（5 位），不加入 .agents（全局保护区, env 显式覆盖）。
	    if [ -n "${HOME:-}" ]; then
	        DEFAULT_DEPLOY_ROOTS="$(default_deploy_slots)"
	    else
	        DEFAULT_DEPLOY_ROOTS=""
	    fi
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
        # [2026-11-26 事故修复] slot 身份校验前置: basename 必须等于 EXPECTED_SKILL_NAME 且规范化路径
        # 精确等于已配置扫描根下 <root>/<EXPECTED_SKILL_NAME>。父目录级/祖先/后代/相对/worktree 自身/
        # 主仓根一律 REJECTED, 输出含 [slot-identity] token; --allow-home-slot 不得绕过此身份校验
        # (只影响 $HOME 白名单, 不放松 slot 身份)。前置于 guard 比较, 确保身份违规统一报 [slot-identity]。
        slot_identity_ok "$norm" "$slot" || return 1
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
            [ "$norm" = "$gn" ] && {
                _msg="[DEPLOY] REJECTED: $slot (= 受保护路径 ${guard_raw[$i]%:*})"
                case "${guard_raw[$i]%:*}" in
                "$SKILL_ROOT") _msg="$_msg(= 运行位自保护; 请改用主仓副本运行或手动 rm+cp 部署该位 — 部署源=主仓 skills/task-planner)" ;;
                esac
                echo "$_msg"; return 1; }
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
    # [2026-11-26 事故修复] cache 根 fail-closed 校验: 必须在任何 staging/swap 前完成。
    # Why: cache 根落在扫描根/仓内会让 stage/backup 被加载器识别或污染 git 仓。
    assert_cache_root_safe

    # [2026-09-12 R3] 部署循环恒执行(不再条件包裹): HOME 未设且 env 未覆盖时 SLOTS="" → 循环零次,
    # DRIFT=1 已在上方(SLOTS 分支, 先于循环初始化)置位 → 仍走 exit 6
    # (DRIFT=0 初始化已移至 SLOTS 分支之前; 条件包裹会吞掉 HOME 空的 DRIFT 标志, 均已实证修复 rc=0 假绿回归)
    # [2026-09-17 task-v077] 对账基准 = DEPLOY_SRC(主仓 skills/task-planner), 非脚本运行处
    # [2026-09-27 task-v091 C-5] 部署对账两级化：L1 确定性文件集合差（抓增/缺/改名）+ L2 内容定向 diff（git porcelain 清单）+≥3 抽检；残留面=清单外同名文件带外热改
    # C-5 两级对账(定义先于 deploy 循环; 原 :555 全树 diff -rq 改为两级, 省 2 次全树内容读取成本):
    #   L1 确定性文件集合差: find|sort 逐行 diff — 抓增(多余)/缺(缺失)/改名, 全树文件面保留(确定性断言)
    #   L2 内容定向 diff: git 程序化清单(git diff --name-only MB..BRANCH 限 skills/task-planner, 禁手填 — 来源恒为 git 输出)
    #      + ≥3 清单外同名文件内容抽检(清单外不足 3 则全取; 取排序前 3 保可复现, 不依赖 $RANDOM)
    #   保守回退: 清单为空/不可用(无 skill 变更 / 非 git 环境 / 清单命令失败) → 全交集内容对比
    #   (语义与旧全树 diff -rq 等价, 非静默降级)
    #   残留面(明示): 清单外同名文件的带外内容热改不在定向清单内, 靠 ≥3 概率抽检兜底(未抽中即漏检, 记录在案)
    # 返回 0=IDENTICAL / 1=DRIFT(DRIFT 明细行 DRIFT-L1/DRIFT-L2 先行打印; 判定行与退出码语义不变, 由调用方打印)
    _re_lines() { [ -n "${1-}" ] && printf '%s\n' "$1"; return 0; }   # 空安全行清单(空变量→零行, 防 comm 对单空行误匹配)
    deploy_reconcile() {
        local slotdir="$1"
        local src_list slot_list
        # L1: 两侧相对路径文件清单(skill 根内相对路径口径; find -L 与 cp -rL 实体化口径一致, %P 输出相对路径)
        src_list="$(find -L "$DEPLOY_SRC" -type f -printf '%P\n' 2>/dev/null | sed 's|^\./||' | LC_ALL=C sort)"
        slot_list="$(cd "$slotdir" 2>/dev/null && find -L . -type f -printf '%P\n' 2>/dev/null | sed 's|^\./||' | LC_ALL=C sort)"
        local missing extra
        # [2026-09-27 task-v091 C-5-locale] comm 输入已 LC_ALL=C sort, comm 本身未 pin → zh_CN.UTF-8 下 L2 清单内差异假 IDENTICAL/L1 乱序; 逐处包 LC_ALL=C
        missing="$(LC_ALL=C comm -23 <(_re_lines "$src_list") <(_re_lines "$slot_list") | head -n 5)"
        extra="$(LC_ALL=C comm -13 <(_re_lines "$src_list") <(_re_lines "$slot_list") | head -n 5)"
        if [ -n "$missing" ] || [ -n "$extra" ]; then
            echo "[DEPLOY] DRIFT-L1: $slotdir (文件集合差: 缺/多如下)"
            [ -n "$missing" ] && echo "  缺失: $missing"
            [ -n "$extra" ] && echo "  多余: $extra"
            return 1
        fi
        # L2: 内容定向 diff。git 程序化清单 = 本次合并 MB..BRANCH 变更的 skill 文件(剥 skill 根前缀, 禁手填)
        local manifest common inman outman targets T
        manifest="$(git -C "$MAIN_REPO" diff --name-only "$MB" "$BRANCH" -- skills/task-planner 2>/dev/null | sed 's|^skills/task-planner/||' | sed '/^$/d' | LC_ALL=C sort)"
        common="$(LC_ALL=C comm -12 <(_re_lines "$src_list") <(_re_lines "$slot_list"))"
        if [ -n "$manifest" ]; then
            inman="$(LC_ALL=C comm -12 <(_re_lines "$manifest") <(_re_lines "$common"))"
            # 抽检: 清单外同名文件(交集-清单), 取前 3 保可复现; 不足 3 则全取
            outman="$(LC_ALL=C comm -23 <(_re_lines "$common") <(_re_lines "$manifest") | head -n 3)"
            # 定向目标 = 清单内∩存在(删除文件不入 targets, 防假 DRIFT) + 清单外抽检; 均 ⊆ common(cmp 两侧必存在)
            targets="$(printf '%s\n%s' "$inman" "$outman" | sed '/^$/d' | LC_ALL=C sort -u)"
        else
            # 保守回退: 清单为空/不可用 → 全交集内容对比(与旧全树 diff -rq 语义等价, 非静默降级)
            targets="$common"
        fi
        while IFS= read -r T; do
            [ -n "$T" ] || continue
            if ! cmp -s "$DEPLOY_SRC/$T" "$slotdir/$T" 2>/dev/null; then
                echo "[DEPLOY] DRIFT-L2: $slotdir (内容差异: $T)"
                return 1
            fi
        done <<< "$targets"
        return 0
    }
    # [task-v105] 池成员顶层枚举挂载: 宿主 skill 发现面=顶层 <skills>/<member>/SKILL.md,
    # 池嵌套在 task-planner/review-library/ 下对宿主不可见 → 每成员建相对软链
    # <parent>/<m> → task-planner/review-library/<m>(单一维护源,池更新自动同步)。
    # 冲突语义: 顶层已有条目→跳过+LINK-WARN(独立 skill 不覆盖);挂载后校验失败→仅回滚本次新建的链。
    # 增强段: 失败不改 exit 码(部署判定已定),LINK-* 仅输出。
    install_pool_links() {
        local slotdir="$1" parent m link tgt
        parent="$(dirname "$slotdir")"
        [ -d "$parent" ] || { echo "[DEPLOY] LINK-SKIP: $slotdir (父目录缺失,跳过池挂载)"; return 0; }
        local members
        members="$(ls -d "$slotdir/review-library/"*/ 2>/dev/null | xargs -n1 basename 2>/dev/null | LC_ALL=C sort)"
        [ -n "$members" ] || { echo "[DEPLOY] LINK-SKIP: $slotdir (池目录缺失/空,跳过挂载)"; return 0; }
        for m in $members; do
            link="$parent/$m"
            tgt="task-planner/review-library/$m"
            if [ -e "$link" ] || [ -L "$link" ]; then
                if [ -L "$link" ] && [ "$(readlink "$link")" = "$tgt" ]; then
                    echo "[DEPLOY] LINK-OK: $link (既有挂载有效)"
                else
                    echo "[DEPLOY] LINK-WARN: $link (顶层已被独立条目占用,不触碰)"
                fi
                continue
            fi
            ln -s "$tgt" "$link" 2>/dev/null || { echo "[DEPLOY] LINK-WARN: $link (ln 失败,跳过)"; continue; }
            if [ -f "$link/SKILL.md" ] && grep -q '^name:' "$link/SKILL.md" 2>/dev/null; then
                echo "[DEPLOY] LINK-OK: $link → $tgt"
            else
                rm -f "$link"
                echo "[DEPLOY] LINK-WARN: $link (挂载后校验失败,已回滚)"
            fi
        done
        return 0
    }
    IFS=':' read -r -a slots <<< "$SLOTS"
    if [ "$DO_LEGACY" -eq 1 ]; then
        # [--legacy task-v159] 旧直写路径: 保留为 fallback, 但强制遵守 2026-11-26 事故修复约束。
        # Why: F5 之前唯一实现; 新路径默认启用, --legacy 仅用于对照/应急(失败语义 exit 6 不变)。
        # [2026-11-26 事故修复] legacy 路径同样: (a) stage/backup 落 DEPLOY_CACHE_ROOT, 不落扫描根/仓内;
        # (b) 恢复失败必须报错并保持备份, 不得吞错后删除; (c) post-verify 前做身份断言。
        for slot in "${slots[@]}"; do
            [ -n "$slot" ] || continue
            if ! validate_slot "$slot"; then
                DRIFT=1
                continue
            fi
            # [2026-09-17 task-v077] fail-closed: 源缺失时整位跳过(不 cp/diff/mv, slot 原样保留)。
            # 检查置于 validate_slot 之后 — REJECTED 危险 slot 仍走既有拒绝路径(诊断语义不变);
            # 此处不再置 DRIFT(上方 DRIFT 初始化已置 1 → exit 6), 防重复标志语义漂移。
            if [ ! -d "$DEPLOY_SRC" ]; then
                echo "[DEPLOY] DRIFT: $slot (部署源缺失, 跳过部署)"
                continue
            fi
            slotdir="${slot%/}"                      # 末尾 / 归一(绝对路径, 已无空白)
            slotnorm="$(norm_path "$slotdir")"
            slotkey="$(slot_cache_key "$slotnorm")"
            # [2026-11-26 事故修复] stage/backup 落 cache 根, 绝不落扫描根。
            tmpdir="$DEPLOY_CACHE_ROOT/${EXPECTED_SKILL_NAME}.legacy-stage.${slotkey}.$$"
            slotbak="$DEPLOY_CACHE_ROOT/${EXPECTED_SKILL_NAME}.legacy-backup.${slotkey}.$$"
            rm -rf "$tmpdir" "$slotbak" 2>/dev/null || true
            # 注册到 trap 数组, 保证异常中断时可恢复
            SLOTDIRS+=("$slotdir")
            STAGEDIRS+=("$tmpdir")
            SLOTBACKUPS+=("$slotbak")
            SLOTNORMS+=("$slotnorm")
            if ! cp -rL "$DEPLOY_SRC" "$tmpdir" 2>/dev/null; then
                rm -rf "$tmpdir" 2>/dev/null || true
                STAGEDIRS[${#STAGEDIRS[@]}-1]=""
                SLOTBACKUPS[${#SLOTBACKUPS[@]}-1]=""
                echo "[DEPLOY] DRIFT: $slotdir (cp 失败 — 槽位不可写或路径不存在; 原 slot 保留未动)"
                DRIFT=1
                continue
            fi
            if ! mv "$slotdir" "$slotbak" 2>/dev/null; then
                rm -rf "$tmpdir" 2>/dev/null || true
                STAGEDIRS[${#STAGEDIRS[@]}-1]=""
                SLOTBACKUPS[${#SLOTBACKUPS[@]}-1]=""
                echo "[DEPLOY] DRIFT: $slotdir (slot→backup 换位失败 — 原 slot 保留未动)"
                DRIFT=1
                continue
            fi
            if ! mv "$tmpdir" "$slotdir" 2>/dev/null; then
                # [2026-11-26 事故修复+用户裁决复核] 恢复失败必须报错并保持备份, 不得吞错后删除。
                # 2026-11-26 用户裁决: "回位+备份保留""不希望得到任何伤害" — backup→slot 成功后必须在 cache 根
                # 保留该 backup 的物理副本(cp -a slotdir backupdir); cp 失败仅 stderr WARN, 绝不静默删 backup。
                if ! mv "$slotbak" "$slotdir" 2>/dev/null; then
                    echo "[DEPLOY] DRIFT: $slotdir (tmp→slot 换位失败, 且恢复 backup→slot 失败 — backup 保留供人工核对: $slotbak)" >&2
                    STAGEDIRS[${#STAGEDIRS[@]}-1]=""
                    # backup 保留, 不清 SLOTBACKUPS
                    DRIFT=1
                    continue
                fi
                if ! cp -a "$slotdir" "$slotbak" 2>/dev/null; then
                    echo "[DEPLOY] WARN: legacy 回位后备份副本重建失败 — backup 路径保留但可能不完整: $slotbak" >&2
                fi
                STAGEDIRS[${#STAGEDIRS[@]}-1]=""
                echo "[DEPLOY] DRIFT: $slotdir (tmp→slot 换位失败 — 原 slot 已恢复原位, backup 已保留: $slotbak)"
                DRIFT=1
                continue
            fi
            # 部署成功: 清理 backup, 清空数组登记(stage 已 mv 成 slot)
            if [ -e "$slotbak" ]; then
                if ! rm -rf "$slotbak" 2>/dev/null; then
                    echo "[DEPLOY] DRIFT: $slotdir (backup 清理失败 — 保留供人工核对: $slotbak)" >&2
                    STAGEDIRS[${#STAGEDIRS[@]}-1]=""
                    DRIFT=1
                    continue
                fi
            fi
            SLOTBACKUPS[${#SLOTBACKUPS[@]}-1]=""
            STAGEDIRS[${#STAGEDIRS[@]}-1]=""
            # [2026-11-26 事故修复] post-verify 前身份断言: 防同源复制恒真/路径漂移假绿。
            if ! assert_slot_identity_for_verify "$slotdir" "$slotnorm"; then
                echo "[DEPLOY] DRIFT: $slotdir (身份断言失败 — IDENTITY-MISMATCH)" >&2
                DRIFT=1
                continue
            fi
            # [2026-09-17 task-v077] 对账基准 = DEPLOY_SRC(主仓 skills/task-planner), 非脚本运行处
            # [2026-09-27 task-v091 C-5] 全树 diff -rq → 两级对账(L1 集合差 + L2 定向 diff, 明细行 DRIFT-L1/DRIFT-L2
            # 先行打印; 判定行与 exit 码语义不变: 两级全过 = IDENTICAL)
            if deploy_reconcile "$slotdir"; then
                echo "[DEPLOY] IDENTICAL: $slotdir (基准=主仓 skills/task-planner)"
                install_pool_links "$slotdir"
            else
                DRIFT=1
            fi
        done
    else
        # [task-v159 F5] staging 原子化三段(替代旧直写路径; 默认启用)
        # Why(D4 事故根因=2026-10-10 04:45-04:49 claude 写入后 zcode 删除致技能全局停摆):
        #   旧路径 rm slot 后直写新内容, 写入中断=slot 缺席=全部会话技能停摆。新路径把"内容就位"
        #   与"指针切换"分离: staging 全部先行(任 slot stage 失败=整体 exit 1 不进入 swap);
        #   swap: 旧 slot mv→cache backup(旧技能立即退出扫描根) → stage mv→slot → post-verify PASS → 删 backup。
        # [2026-11-26 事故修复] stage/backup 必须落 DEPLOY_CACHE_ROOT, 绝不落扫描根/仓内;
        #   cache 根已在循环前 assert_cache_root_safe fail-closed 校验。
        # ---------- staging: 全部 slot 先行 cp -rL 至 cache 根 <name>.stage.<key>.$$ ----------
        for slot in "${slots[@]}"; do
            [ -n "$slot" ] || continue
            if ! validate_slot "$slot"; then
                DRIFT=1
                continue
            fi
            if [ ! -d "$DEPLOY_SRC" ]; then
                echo "[DEPLOY] DRIFT: $slot (部署源缺失, 跳过部署)"
                continue
            fi
            slotdir="${slot%/}"
            slotnorm="$(norm_path "$slotdir")"
            slotkey="$(slot_cache_key "$slotnorm")"
            stagedir="$DEPLOY_CACHE_ROOT/${EXPECTED_SKILL_NAME}.stage.${slotkey}.$$"
            backupdir="$DEPLOY_CACHE_ROOT/${EXPECTED_SKILL_NAME}.backup.${slotkey}.$$"
            rm -rf "$stagedir" "$backupdir" 2>/dev/null || true    # 防 PID 复用残留嵌套
            if ! cp -rL "$DEPLOY_SRC" "$stagedir" 2>/dev/null; then
                rm -rf "$stagedir" 2>/dev/null || true
                echo "[DEPLOY] STAGE-FAIL: $slotdir (cp 失败 — 整体退出, 不进入 swap)"
                # 清理本批已 stage 的残留(防半成品 stage 目录遗留 cache)
                for _sd in ${STAGEDIRS[@]+"${STAGEDIRS[@]}"}; do
                    [ -n "$_sd" ] && rm -rf "$_sd" 2>/dev/null || true
                done
                STAGEDIRS=()
                SLOTBACKUPS=()
                SLOTDIRS=()
                SLOTNORMS=()
                echo "[DEPLOY] DEPLOY_DRIFT: staging 阶段失败" >&2
                exit 1
            fi
            SLOTDIRS+=("$slotdir")
            STAGEDIRS+=("$stagedir")
            SLOTBACKUPS+=("$backupdir")
            SLOTNORMS+=("$slotnorm")
            echo "[DEPLOY] STAGED: $slotdir → $stagedir"
        done
        # ---------- swap: 旧 slot mv→cache backup, 再 stage mv→slot ----------
        # [2026-11-26 事故修复] 顺序强制: 先把旧 slot 整体 mv 到 backup(旧技能立即退出扫描根)
        # → 再把 stage mv 到 slot → post-verify PASS → 才删除 backup。
        # 任何一步失败: 把 backup 原样 mv 回 slot, 保留 backup 供人工核对, 不得静默删除;
        # 禁止 `|| true` 吞失败; 禁止无备份的 rm -rf slot。
        SWAP_FAIL=0
        for i in $( [ ${#SLOTDIRS[@]} -gt 0 ] && seq 0 $((${#SLOTDIRS[@]}-1)) ); do
            [ -n "${SLOTDIRS[$i]:-}" ] || continue
            slotdir="${SLOTDIRS[$i]}"
            stagedir="${STAGEDIRS[$i]}"
            backupdir="${SLOTBACKUPS[$i]}"
            # step 1: 旧 slot → backup (旧技能立即退出扫描根)
            if [ -e "$slotdir" ]; then
                if ! mv "$slotdir" "$backupdir" 2>/dev/null; then
                    echo "[DEPLOY] SWAP-FAIL: $slotdir (slot→backup 换位失败 — 原 slot 保留未动, backup=$backupdir)" >&2
                    SWAP_FAIL=1
                    continue
                fi
            else
                # slot 不存在: 记录为空 backup(后续回滚无需恢复旧内容)
                backupdir=""
                SLOTBACKUPS[$i]=""
            fi
            # step 2: stage → slot
            if ! mv "$stagedir" "$slotdir" 2>/dev/null; then
                echo "[DEPLOY] SWAP-FAIL: $slotdir (stage→slot 换位失败 — 尝试恢复 backup)" >&2
                if [ -n "$backupdir" ] && [ -e "$backupdir" ]; then
                    if mv "$backupdir" "$slotdir" 2>/dev/null; then
                        # [2026-11-26 用户裁决] 回位+备份保留: 恢复成功后在 cache 根保留 backup 物理副本。
                        if ! cp -a "$slotdir" "$backupdir" 2>/dev/null; then
                            echo "[DEPLOY] WARN: swap 回位后备份副本重建失败 — backup 路径保留但可能不完整: $backupdir" >&2
                        fi
                        echo "[DEPLOY] SWAP-RECOVERED: $slotdir (已从 backup 恢复原位, backup 已保留: $backupdir)"
                    else
                        echo "[DEPLOY] SWAP-FAIL: $slotdir (恢复 backup→slot 失败 — backup 保留供人工核对: $backupdir)" >&2
                    fi
                fi
                SWAP_FAIL=1
                continue
            fi
            echo "[DEPLOY] SWAPPED: $slotdir (backup=$backupdir)"
        done
        if [ "$SWAP_FAIL" -eq 1 ]; then
            echo "[DEPLOY] DEPLOY_DRIFT: swap 阶段失败(失败位已尝试恢复, backup 保留供人工核对)" >&2
            exit 1
        fi
        # ---------- post-verify: 身份断言 + 存在性 + diff -r 零差异 ----------
        # [2026-11-26 事故修复] 对账前先断言目标 slot 的 basename 与期望技能名一致且规范化路径
        # 精确等于声明值; 身份不符输出 IDENTITY-MISMATCH 并以非 0 退出, 不得因同源复制恒真而假绿。
        # 对账基准明确来自 canonical DEPLOY_SRC 与已校验身份后的 slot, 不拿父目录自身与源比。
        VERIFY_FAIL=0
        for i in $( [ ${#SLOTDIRS[@]} -gt 0 ] && seq 0 $((${#SLOTDIRS[@]}-1)) ); do
            [ -n "${SLOTDIRS[$i]:-}" ] || continue
            slotdir="${SLOTDIRS[$i]}"
            slotnorm="${SLOTNORMS[$i]:-$(norm_path "$slotdir")}"
            backupdir="${SLOTBACKUPS[$i]:-}"
            # 身份断言先于内容对账
            if ! assert_slot_identity_for_verify "$slotdir" "$slotnorm"; then
                echo "[DEPLOY] VERIFY-FAIL: $slotdir (IDENTITY-MISMATCH — 禁止假绿)" >&2
                VERIFY_FAIL=1
                # [2026-11-26 用户裁决] 回位+备份保留, 不希望得到任何伤害:
                # 先将当前 slot 移到 cache quarantine(保留现场), 再 restore backup; restore 失败则把 quarantine 移回 slot。
                if [ -n "$backupdir" ] && [ -e "$backupdir" ]; then
                    _quarantine="$DEPLOY_CACHE_ROOT/${EXPECTED_SKILL_NAME}.quarantine.${slotkey:-$(slot_cache_key "$slotnorm")}.$$.$i"
                    rm -rf "$_quarantine" 2>/dev/null || true
                    if [ -e "$slotdir" ]; then
                        if ! mv "$slotdir" "$_quarantine" 2>/dev/null; then
                            echo "[DEPLOY] VERIFY-FAIL: $slotdir (身份不符, quarantine 失败 — slot 保持原位, backup 保留: $backupdir)" >&2
                            continue
                        fi
                    else
                        _quarantine=""
                    fi
                    if mv "$backupdir" "$slotdir" 2>/dev/null; then
                        if ! cp -a "$slotdir" "$backupdir" 2>/dev/null; then
                            echo "[DEPLOY] WARN: verify 回位后备份副本重建失败 — backup 路径保留但可能不完整: $backupdir" >&2
                        fi
                        echo "[DEPLOY] VERIFY-RECOVERED: $slotdir (身份不符, 已从 backup 恢复, backup 已保留: $backupdir)"
                        [ -n "$_quarantine" ] && [ -e "$_quarantine" ] && rm -rf "$_quarantine" 2>/dev/null || true
                    else
                        echo "[DEPLOY] VERIFY-FAIL: $slotdir (身份不符且恢复失败 — 尝试回滚 quarantine, backup 保留: $backupdir)" >&2
                        if [ -n "$_quarantine" ] && [ -e "$_quarantine" ]; then
                            mv "$_quarantine" "$slotdir" 2>/dev/null || echo "[DEPLOY] VERIFY-FAIL: $slotdir (quarantine 回滚也失败 — 人工介入: $_quarantine)" >&2
                        fi
                    fi
                fi
                continue
            fi
            if [ ! -d "$slotdir" ]; then
                echo "[DEPLOY] VERIFY-FAIL: $slotdir (slot 缺失)"
                VERIFY_FAIL=1
                # [2026-11-26 用户裁决] 回位+备份保留: 恢复成功后保留 backup 物理副本。
                if [ -n "$backupdir" ] && [ -e "$backupdir" ]; then
                    if mv "$backupdir" "$slotdir" 2>/dev/null; then
                        if ! cp -a "$slotdir" "$backupdir" 2>/dev/null; then
                            echo "[DEPLOY] WARN: verify slot缺失回位后备份副本重建失败 — backup 路径保留但可能不完整: $backupdir" >&2
                        fi
                        echo "[DEPLOY] VERIFY-RECOVERED: $slotdir (slot 缺失, 已从 backup 恢复, backup 已保留: $backupdir)"
                    else
                        echo "[DEPLOY] VERIFY-FAIL: $slotdir (slot 缺失且恢复失败 — backup 保留: $backupdir)" >&2
                    fi
                fi
                continue
            fi
            # 对账基准: canonical DEPLOY_SRC vs 已校验身份的 slotdir
            if ! diff -r "$slotdir" "$DEPLOY_SRC" >/dev/null 2>&1; then
                echo "[DEPLOY] VERIFY-FAIL: $slotdir (diff -r 差异详情, 基准=$DEPLOY_SRC):"
                diff -r "$slotdir" "$DEPLOY_SRC" 2>&1 | head -n 10
                VERIFY_FAIL=1
                # [2026-11-26 用户裁决] 回位+备份保留, 不希望得到任何伤害:
                # 先将当前 slot 移到 cache quarantine, 再 restore backup; restore 失败则把 quarantine 移回 slot。
                if [ -n "$backupdir" ] && [ -e "$backupdir" ]; then
                    _quarantine="$DEPLOY_CACHE_ROOT/${EXPECTED_SKILL_NAME}.quarantine.${slotkey:-$(slot_cache_key "$slotnorm")}.$$.$i"
                    rm -rf "$_quarantine" 2>/dev/null || true
                    if [ -e "$slotdir" ]; then
                        if ! mv "$slotdir" "$_quarantine" 2>/dev/null; then
                            echo "[DEPLOY] VERIFY-FAIL: $slotdir (diff 失败, quarantine 失败 — slot 保持原位, backup 保留: $backupdir)" >&2
                            continue
                        fi
                    else
                        _quarantine=""
                    fi
                    if mv "$backupdir" "$slotdir" 2>/dev/null; then
                        if ! cp -a "$slotdir" "$backupdir" 2>/dev/null; then
                            echo "[DEPLOY] WARN: verify 回位后备份副本重建失败 — backup 路径保留但可能不完整: $backupdir" >&2
                        fi
                        echo "[DEPLOY] VERIFY-RECOVERED: $slotdir (diff 失败, 已从 backup 恢复, backup 已保留: $backupdir)"
                        [ -n "$_quarantine" ] && [ -e "$_quarantine" ] && rm -rf "$_quarantine" 2>/dev/null || true
                    else
                        echo "[DEPLOY] VERIFY-FAIL: $slotdir (diff 失败且恢复失败 — 尝试回滚 quarantine, backup 保留: $backupdir)" >&2
                        if [ -n "$_quarantine" ] && [ -e "$_quarantine" ]; then
                            mv "$_quarantine" "$slotdir" 2>/dev/null || echo "[DEPLOY] VERIFY-FAIL: $slotdir (quarantine 回滚也失败 — 人工介入: $_quarantine)" >&2
                        fi
                    fi
                fi
            fi
        done
        if [ "$VERIFY_FAIL" -eq 1 ]; then
            echo "[DEPLOY] DEPLOY_DRIFT: post-verify 阶段失败(身份/存在性/diff 零差异未过, backup 已尽量保留)" >&2
            exit 1
        fi
        # [2026-11-26 事故修复] post-verify PASS 后才删除 backup; 删除失败报错但不伪造成功后回滚已验证 slot。
        for i in $( [ ${#SLOTDIRS[@]} -gt 0 ] && seq 0 $((${#SLOTDIRS[@]}-1)) ); do
            backupdir="${SLOTBACKUPS[$i]:-}"
            [ -n "$backupdir" ] || continue
            if [ -e "$backupdir" ]; then
                if ! rm -rf "$backupdir" 2>/dev/null; then
                    echo "[DEPLOY] VERIFY-WARN: backup 删除失败(已验证 slot 保持不动, 请人工清理): $backupdir" >&2
                fi
            fi
            SLOTBACKUPS[$i]=""
        done
        # [task-v105] 池成员顶层枚举挂载(增强段, 失败不改 exit 码)
        for i in $( [ ${#SLOTDIRS[@]} -gt 0 ] && seq 0 $((${#SLOTDIRS[@]}-1)) ); do
            [ -n "${SLOTDIRS[$i]:-}" ] || continue
            install_pool_links "${SLOTDIRS[$i]}"
        done
        # [2026-10-10 CR修复 MINOR-6] OK 文案条件化: 仅当无 DRIFT/SWAP_FAIL/VERIFY_FAIL 且 slot 非空时才打印
        # Why: 原实现无条件打印 OK 文案, DRIFT=1(reconcile 失败但 post-verify 过)时先打印 OK 再 exit 6,
        #   成功文案误导(用户看到 OK 以为部署成功)。SWAP_FAIL/VERIFY_FAIL 虽已 exit 1 不到此,
        #   但条件包含它们作防御性断言(防未来控制流变更致 OK 文案在失败路径打印)。
        if [ "$DRIFT" -eq 0 ] && [ "${SWAP_FAIL:-0}" -eq 0 ] && [ "$VERIFY_FAIL" -eq 0 ] && [ "${#SLOTDIRS[@]}" -gt 0 ]; then
            echo "[DEPLOY] OK: 全部部署位 post-verify 零差异(基准=主仓 skills/task-planner)"
        fi
    fi
    if [ "$DRIFT" -eq 1 ]; then
        echo "[DEPLOY] DEPLOY_DRIFT: 至少一位部署位 DRIFT/REJECTED(详见上)" >&2
        exit 6
    fi
    echo "[DEPLOY] OK: 全部部署位 IDENTICAL(基准=主仓 skills/task-planner)"
    # [2026-11-25 task-deploy-all-skills] F6 全量 skill 同步。What: task-planner 逐位对账通过后调用 canonical 仓的
    #   lib/install-companion.sh(与 install.sh Phase 5.6 同源), 把 $MAIN_REPO/skills 下其余全部 skill 同步到
    #   detect-tools.sh 探测到的所有工具根; TASK_PLANNER_ROOT 显式指向 canonical(install-companion.sh:45-50 校验),
    #   防从部署位运行时把部署副本误当安装源。Why: 原 --deploy 只发 task-planner 一个 skill, 其余 20 个完全不同步。
    #   守卫: TASK_PLANNER_DEPLOY_SLOTS 已注入(selftest 用临时 slot, companion 会写真实工具根)或
    #   TASK_PLANNER_DEPLOY_ALL=0 时跳过本段; 失败 stderr 报 DEPLOY_DRIFT 并 exit 6(与既有部署失败语义一致)。
    if [ -z "${TASK_PLANNER_DEPLOY_SLOTS:-}" ] && [ "${TASK_PLANNER_DEPLOY_ALL:-1}" != "0" ]; then
        if ! TASK_PLANNER_ROOT="$MAIN_REPO/skills/task-planner" \
             bash "$MAIN_REPO/skills/task-planner/lib/install-companion.sh"; then
            echo "[DEPLOY-ALL] DEPLOY_DRIFT: 全量 skill 同步失败(canonical=$MAIN_REPO/skills)" >&2
            exit 6
        fi
        echo "[DEPLOY-ALL] OK: all skills synced"
    fi
fi

# 成功: MERGED 或 ALREADY_MERGED, 且 --deploy 全位 IDENTICAL(对账基准=主仓 skills/task-planner, task-v077)
exit 0
