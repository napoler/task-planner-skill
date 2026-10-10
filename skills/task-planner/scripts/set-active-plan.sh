#!/usr/bin/env bash
# set-active-plan.sh — 设置/查看活跃计划指针
#   全局 fallback: plans/.active_plan   (原措辞"全局: 单会话/cron 场景;原行为,兼容旧调用方";
#     [2026-10-10 task-v164] 工作树内瞬态文件,路径随 $PWD 本地化,仅服务 sid-less/cron legacy 调用方)
#   会话: plans/.active_plan_side/<sid>.active_plan (2026-09-10 active-plan-race 新增,并行安全;
#     [2026-10-10 task-v164 补注] 2026-10-07 fix-pointer-race 后=权威层,正常路径优先)
# (移植适配自上游 planning-with-files v3;本仓无 .planning 布局,指针放 plans/ 下)
#
# [2026-10-10 task-v164] 头注释改述(原措辞"全局 legacy 指针"误导为跨树共享/需移交,实为
#   工作树内瞬态 fallback,改述之;解析链逻辑/参数/函数体零改动):
#   ① 路径本地化既成事实:全局指针路径 = $PWD/plans/.active_plan,随工作树各自一份(set-active-plan.sh:97)[2026-10-10 task-v164 CR-nit 修正：原锚因头注释新增漂移],
#      非跨树共享文件;旧叙事"全局"易被误读为全局单例。
#   ② 瞬态化(2026-10-10 task-v164):git rm --cached + .gitignore,与 .active_plan_side/ / .plan_required_side/ /
#      .drift-rhythm/ 同族(即写即弃运行态不入库)→ 跨树零共享、合并零冲突、git churn 止息(历史 8 次 chore 移交/收尾噪音)。
#   ③ 角色降级为 fallback:正常路径=side 会话私有指针(2026-10-07 fix-pointer-race 后权威层);
#      全局层仅服务 sid-less/cron legacy 调用方。退役"移交全局指针"叙事(该叙事=并行可见漂移来源)。
#
# 2026-09-10 active-plan-race: 原行为=单文件全局指针,多并行会话互顶(后写者赢,
#   09-09 实锤 7 次 check-dispatch 误拦)。新增:
#   set-active-plan.sh set <task-id> [--sid s] [project-root]   # 会话私有指针(mktemp+mv 原子写,推荐)
#   set-active-plan.sh <task-id> [project-root]                 # 全局 fallback(=原位置参数行为) [2026-10-10 task-v164 补注:原措辞"全局 legacy",改述为 fallback]
#   set-active-plan.sh --show [--sid s] [project-root]          # 带 sid 时同时展示 side 与全局
#   set-active-plan.sh --clear [--sid s] [project-root]         # 清全局;--sid 时连 side 一起清
#   set-active-plan.sh gc [project-root]                         # 清扫 .active_plan_side/ 中 mtime>24h 的残留
#   sid 缺省 = env CLAUDE_CODE_SESSION_ID → default(规范化=剥非字母数字取前 40,与 hook 状态文件命名一致)
#
# [2026-09-10 task-planrequired-race] norm_sid 追加剥 sess 前缀(与 task-plan-init.cjs / check-scope.sh /
#   resolve-plan-dir.sh 四处 canon 对齐,D8:uuid core,消灭 hook 侧 sess 前缀 vs env 裸 uuid 双命名空间分裂);
#   gc 同语义扩展清扫 plans/.plan_required_side/ 中 mtime>24h 的 *.plan_required(side 哨兵,TTL 对齐 resolve 侧)。
#
# 指针生效后 hook(zcode-userpromptsubmit/zcode-posttooluse)经 resolve-plan-dir.sh 解析
# (会话 side 优先 → 全局 fallback → mtime 最新),多计划并行时消除注入歧义。
#   [2026-10-10 task-v164 补注] 原措辞"全局 legacy",降级为 fallback(角色表述统一)。

set -u

usage() {
    printf 'Usage: %s {set <task-id>|<task-id>|--show|--clear|gc} [--sid s] [project-root]\n' "$0" >&2
    exit 2
}

norm_sid() {
    # [2026-09-10 task-planrequired-race] canon 四处对齐(D8):剥非字母数字取前 40,再剥 sess 前缀;
    # 与 task-plan-init.cjs normSidkey / check-scope.sh sidkey 段 / resolve-plan-dir.sh norm_sid 一致
    local s="$(printf '%s' "$1" | tr -cd 'a-zA-Z0-9' | head -c 40)"
    case "$s" in
        sess*) s="${s#sess}" ;;
    esac
    [ -n "$s" ] && printf '%s' "$s" || printf 'default'
}

ACTION="${1:-}"
case "$ACTION" in
    ''|-h|--help) usage ;;
esac
shift

# 剩余参数: --sid <val> 提取,余下为位置参数
# [2026-10-09 pointer-lifecycle] F3: --force flag 提取(与 --sid 同款参数解析)
# Why: side 写入所有权守卫需要显式覆盖入口(D3 缺陷修复);无 --force 时默认拒绝 trample。
# 基线行为: 无 --force 参数,set 无所有权检查。
SIDARG=""
FORCE_FLAG=""
positional=()
while [ $# -gt 0 ]; do
    case "$1" in
        --sid) SIDARG="${2:-}"; shift 2 ;;
        --force) FORCE_FLAG=1; shift ;;
        *) positional+=("$1"); shift ;;
    esac
done

# 各命令语义: set 模式位置参数=[task-id, root?];其余命令位置参数=[root?]
pid="${positional[0]:-}"
# [2026-10-09 pointer-lifecycle] F4: set 模式 ROOT 默认 $PWD
# Why: 原实现 positional[0] fallback 在计划目录内运行时把 task-id 当 root，
#   导致 PLAN_ROOT 双重要素→require_plan 误报 exit 2（D5 缺陷）。
#   改后: positional[1] 空时 fallback 到 $PWD；若 $PWD 本身即计划目录
#   （含 task_plan.md），则 ROOT 取 $PWD 上级，使 PLAN_ROOT=$PWD/plans 正确解析。
# 基线行为: ROOT="${positional[1]:-${positional[0]:-$PWD}}"（set 模式 positional[1] 空时 fallback 到 task-id）
ROOT="${positional[1]:-$PWD}"
# F4 补充: 若 $PWD 本身是计划目录（含 task_plan.md），ROOT 取上上级使 PLAN_ROOT=$PWD/../plans 正确
if [ -z "${positional[1]:-}" ] && [ -f "$PWD/task_plan.md" ]; then
    ROOT="$(dirname "$(dirname "$PWD")")"
fi
case "$ACTION" in
    set) ;;                       # pid=positional[0],ROOT=positional[1]|PWD
    --show|--clear|gc)           # 无 task-id;位置参数[0]=root
        [ -n "$pid" ] && ROOT="${positional[0]:-$PWD}"
        [ -n "$pid" ] && unset 'positional[0]'
        pid=""
        ;;
    *) ROOT="${positional[0]:-$PWD}"; pid="$ACTION" ;;   # 旧位置参数模式: task-id 在 $ACTION
esac

PLAN_ROOT="${ROOT}/plans"
ACTIVE_FILE="${PLAN_ROOT}/.active_plan"
SIDE_DIR="${PLAN_ROOT}/.active_plan_side"
SID="$(norm_sid "${SIDARG:-${CLAUDE_CODE_SESSION_ID:-}}")"

validate_slug() {
    case "$1" in
        ''|*[!A-Za-z0-9._-]*|[.]*) return 1 ;;
    esac
    return 0
}

require_plan() {  # <slug> → 计划目录存在,否则报错 exit 2
    if [ ! -f "${PLAN_ROOT}/${1}/task_plan.md" ]; then
        echo "[active-plan] 计划不存在: ${PLAN_ROOT}/${1}/task_plan.md" >&2
        exit 2
    fi
}

atomic_write() {  # <target-file> <slug>(mktemp+mv 原子写;调用方保证 slug 已校验)
    local target="$1" slug="$2" tmp
    tmp="$(mktemp "$(dirname "$target")/.tmp.XXXXXX" 2>/dev/null)" || {
        echo "[active-plan] 无法在 $(dirname "$target") 创建临时文件" >&2; return 1
    }
    if printf '%s\n' "$slug" > "$tmp" 2>/dev/null; then
        mv -f "$tmp" "$target" 2>/dev/null || { rm -f "$tmp"; return 1; }
        return 0
    fi
    rm -f "$tmp"
    return 1
}

case "$ACTION" in
    --show)
        if [ -f "$ACTIVE_FILE" ] && [ ! -d "$ACTIVE_FILE" ]; then
            printf '全局指针: %s -> %s\n' "$ACTIVE_FILE" "$(tr -d ' \r\n\t' < "$ACTIVE_FILE")"
        else
            printf '全局指针: 无(回退 mtime 最新)\n'
        fi
        SIDE_FILE="${SIDE_DIR}/${SID}.active_plan"
        if [ -f "$SIDE_FILE" ]; then
            printf 'side 指针(sid=%s): %s\n' "$SID" "$(tr -d ' \r\n\t' < "$SIDE_FILE")"
        else
            printf 'side 指针(sid=%s): 无\n' "$SID"
        fi
        resolved="$(bash "$(cd "$(dirname "$0")" && pwd)/resolve-plan-dir.sh" "$ROOT" "$SID" 2>/dev/null || true)"
        printf '解析: %s\n' "${resolved:-<无计划>}"
        exit 0
        ;;
    --clear)
        rm -f "$ACTIVE_FILE" 2>/dev/null && echo "[active-plan] 全局指针已清除,回退 mtime 最新"
        if [ -n "$SIDARG" ] || [ -n "${CLAUDE_CODE_SESSION_ID:-}" ]; then
            rm -f "${SIDE_DIR}/${SID}.active_plan" 2>/dev/null && echo "[active-plan] side 指针已清除(sid=${SID})"
        fi
        exit 0
        ;;
    gc)
        # 清扫过期会话指针(mtime>24h;与会话重启/机器重启后的残留对齐 resolve 侧 TTL)
        n=0
        if [ -d "$SIDE_DIR" ]; then
            while IFS= read -r f; do
                rm -f "$f" 2>/dev/null && n=$((n+1))
            done < <(find "$SIDE_DIR" -name '*.active_plan' -type f -mmin +1440 2>/dev/null)
        fi
        # [2026-09-10 task-planrequired-race] 同语义清扫 side 哨兵目录(D1/TTL 对齐)
        REQ_SIDE_DIR="${PLAN_ROOT}/.plan_required_side"
        m=0
        if [ -d "$REQ_SIDE_DIR" ]; then
            while IFS= read -r f; do
                rm -f "$f" 2>/dev/null && m=$((m+1))
            done < <(find "$REQ_SIDE_DIR" -name '*.plan_required' -type f -mmin +1440 2>/dev/null)
        fi
        # [2026-10-07 fix-pointer-race] 同语义清扫 sidmap 映射文件(env sid→hook sid,SessionStart 写;TTL 同 24h)
        k=0
        if [ -d "$REQ_SIDE_DIR" ]; then
            while IFS= read -r f; do
                rm -f "$f" 2>/dev/null && k=$((k+1))
            done < <(find "$REQ_SIDE_DIR" -name '*.sidmap' -type f -mmin +1440 2>/dev/null)
        fi
        # [2026-10-09 pointer-lifecycle] F1: gc 全局指针生命周期
        # Why: 原 gc 仅清扫 side 指针/哨兵/sidmap,全局 .active_plan 残留无人清理(D1 缺陷:
        #   v150 完成后指针残留→sid-less 消费者 PLAN TAMPERED)。新增:全局指针非空时检查目标:
        #   ①目标目录缺失=dead-ref;②目标 task_plan Status=complete 且指针 mtime>24h=completed-ttl。
        #   命中则置空(写空串,不删文件,slug 校验自然回退 mtime)并报告。
        # 基线行为: gc 分支不触碰 .active_plan。
        if [ -f "$ACTIVE_FILE" ]; then
            GLOBAL_PID="$(tr -d ' \r\n\t' < "$ACTIVE_FILE" 2>/dev/null || true)"
            if [ -n "$GLOBAL_PID" ]; then
                STALE_REASON=""
                if [ ! -d "$PLAN_ROOT/$GLOBAL_PID" ]; then
                    STALE_REASON="dead-ref"
                # [2026-10-10 CR2 修复 BLOCKER-B1+MAJOR-M1] 整体完成判定: 锚定真实状态行两子句
                # Why: 原 `grep -Ei 'Status.*in_progress'` 未锚定行首, 命中模板固定行
                #   「- Update phase status as you progress: pending → in_progress → complete」
                #   (templates/task_plan.md 默认生成) → 真·完成态计划被判「非整体完成」而永不清除(B1)。
                #   且未拦「部分完成」=1 阶段 complete + 其余 pending(M1)。
                #   修法=锚定真实状态行: ①has_complete=存在 `^\s*[-*]\s*\*\*Status:\*\*\s*complete` 行;
                #   ②no_active=无任何 `^\s*[-*]\s*\*\*Status:\*\*\s*(in_progress|pending)` 行;
                #   ③指针 mtime>24h 条件保持不变。禁裸 `Status.*in_progress`。
                elif [ -f "$PLAN_ROOT/$GLOBAL_PID/task_plan.md" ] \
                     && grep -Eq '^[[:space:]]*[-*][[:space:]]*\*\*Status:\*\*[[:space:]]*complete' "$PLAN_ROOT/$GLOBAL_PID/task_plan.md" 2>/dev/null \
                     && ! grep -Eq '^[[:space:]]*[-*][[:space:]]*\*\*Status:\*\*[[:space:]]*(in_progress|pending)' "$PLAN_ROOT/$GLOBAL_PID/task_plan.md" 2>/dev/null \
                     && [ -n "$(find "$ACTIVE_FILE" -mmin +1440 2>/dev/null)" ]; then
                    STALE_REASON="completed-ttl"
                fi
                if [ -n "$STALE_REASON" ]; then
                    : > "$ACTIVE_FILE"
                    echo "[active-plan] gc 全局指针 stale(${STALE_REASON})=${GLOBAL_PID} -> 已置空"
                fi
            fi
        fi
        # [2026-10-09 pointer-lifecycle] F2: 哨兵-side 缺口巡检
        # Why: 活跃哨兵(mtime<24h)存在但对应 side 指针缺失→该 sid 解析将回退全局/mtime,
        #   造成并行会话串台(D2 缺陷)。gc 巡检列名报告(advisory 只报告不代写,§十一 并行踩踏禁令)。
        # 基线行为: gc 仅清扫哨兵本身,不检查 side 指针对应关系。
        if [ -d "$REQ_SIDE_DIR" ]; then
            while IFS= read -r f; do
                sidkey="$(basename "$f" .plan_required)"
                # [2026-10-10 CR修复 MINOR-7] F2 双命名空间: 同时查 ${sidkey} 与 sess${sidkey} 两形态 side 指针
                # Why: 原实现仅查剥前缀 `<sidkey>.active_plan`, 而 resolve 双命名空间兼容读 `sess<sidkey>.active_plan`
                #   (历史写入方) → 遗留 sess 形态可能误报缺口(advisory 只读, 无写入)。
                if [ ! -f "${SIDE_DIR}/${sidkey}.active_plan" ] && [ ! -f "${SIDE_DIR}/sess${sidkey}.active_plan" ]; then
                    echo "[active-plan] gc 巡检: 哨兵 ${sidkey} 无 side 指针（该会话解析将回退全局/mtime，建议其跑 set-active-plan set --sid）"
                fi
            done < <(find "$REQ_SIDE_DIR" -name '*.plan_required' -type f -mmin -1440 2>/dev/null)
        fi
        echo "[active-plan] gc 清除过期 side 指针: ${n} 个"
        echo "[active-plan] gc 清除过期 side 哨兵(.plan_required_side): ${m} 个"
        echo "[active-plan] gc 清除过期 sidmap 映射: ${k} 个"
        exit 0
        ;;
    set)
        validate_slug "$pid" || { echo "[active-plan] 非法 task-id: ${pid:-<空>}" >&2; exit 2; }
        require_plan "$pid"
        mkdir -p "$SIDE_DIR" 2>/dev/null || { echo "[active-plan] 无法创建 ${SIDE_DIR}" >&2; exit 1; }
        # [2026-10-09 pointer-lifecycle] F3: side 写入所有权守卫
        # Why: side 键以 sess<SID> 为命名空间,多计划并行时后写者赢导致互踩(D3 缺陷:
        #   v156/v157 owner=sesscbab959f 与 v153 会话撞键)。写 side 键前扫 plans/*/.session-owner:
        #   ①claimant 存在且!=本计划且其 Status=in_progress→拒绝 trample,不写该键,WARN 含 claimant;
        #   ②claimant complete/不存在→fail-open 正常写仅提示。--force 显式覆盖。
        # 基线行为: set 无所有权检查,直接写 side 键。
        SKIP_SIDE_WRITE=0
        claimant=""
        if [ -d "$PLAN_ROOT" ]; then
            for ownfile in "$PLAN_ROOT"/*/.session-owner; do
                [ -f "$ownfile" ] || continue
                # [2026-10-10 CR修复 MAJOR-F3] owner 匹配兼容双形态 ^(sess)?${SID}$
                # Why: 原 `^sess${SID}` 仅匹配带 sess 前缀 owner; 裸 uuid owner 会话(无 sess 前缀)被漏判,
                #   守卫失效直接写入(trample)。修法=兼容双形态, 整行锚定($)实现 norm 后比较。
                if grep -qE "^(sess)?${SID}$" "$ownfile" 2>/dev/null; then
                    claimant="$(basename "$(dirname "$ownfile")")"
                    break
                fi
            done
        fi
        if [ -n "$claimant" ] && [ "$claimant" != "$pid" ]; then
            if [ -f "$PLAN_ROOT/$claimant/task_plan.md" ] \
               && grep -qi 'Status.*in_progress' "$PLAN_ROOT/$claimant/task_plan.md" 2>/dev/null; then
                if [ -n "$FORCE_FLAG" ]; then
                    echo "[active-plan] WARN: side 键 sid=${SID} 已被在途计划 ${claimant} 声明，--force 覆盖，继续写入" >&2
                else
                    echo "[active-plan] WARN: side 键 sid=${SID} 已被在途计划 ${claimant} 声明，skip 写入防沿袭互踩；--force 可覆盖" >&2
                    SKIP_SIDE_WRITE=1
                fi
            else
                echo "[active-plan] WARN: side 键 sid=${SID} 曾被计划 ${claimant} 声明（已 complete/不存在），fail-open 继续写入" >&2
            fi
        fi
        if [ "$SKIP_SIDE_WRITE" = "0" ]; then
            if atomic_write "${SIDE_DIR}/${SID}.active_plan" "$pid"; then
                echo "[active-plan] side 指针已设置: ${pid}(sid=${SID})"
            fi
            exit $?
        fi
        exit 0
        ;;
    *)
        validate_slug "$pid" || { echo "[active-plan] 非法 task-id: $pid" >&2; exit 2; }
        require_plan "$pid"
        if atomic_write "$ACTIVE_FILE" "$pid"; then
            echo "[active-plan] 全局指针已设置: ${pid}(${ACTIVE_FILE})"
        fi
        exit $?
        ;;
esac
