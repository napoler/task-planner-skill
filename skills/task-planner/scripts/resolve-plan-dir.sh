#!/usr/bin/env bash
# resolve-plan-dir.sh — 解析当前活跃计划的 task_plan.md 路径
# (移植裁剪自上游 planning-with-files v3 scripts/resolve-plan-dir.sh:
#  保留解析链+slug 校验;裁剪 PWF_PLAN_ROOT pin/Windows 规范化/python/perl 兜底/containment
#  —— 本仓部署为 Linux glibc,slug 校验已阻路径穿越)
#
# [2026-10-10 task-v164] 头注释改述(原措辞"全局 legacy 指针"误导为跨树共享/需移交,实为
#   工作树内瞬态 fallback,改述之;解析链逻辑/参数/函数体零改动):
#   ① 路径本地化既成事实:全局指针路径 = $PWD/plans/.active_plan,随工作树各自一份(resolve-plan-dir.sh:41,109)[2026-10-10 task-v164 CR-nit 修正：原锚因头注释新增漂移],
#      非跨树共享文件;旧叙事"全局"易被误读为全局单例。
#   ② 瞬态化(2026-10-10 task-v164):git rm --cached + .gitignore,与 .active_plan_side/ / .plan_required_side/ /
#      .drift-rhythm/ 同族(即写即弃运行态不入库)→ 跨树零共享、合并零冲突、git churn 止息(历史 8 次 chore 移交/收尾噪音)。
#   ③ 角色降级为 fallback:正常路径=side 会话私有指针(2026-10-07 fix-pointer-race 后权威层);
#      全局层仅服务 sid-less/cron legacy 调用方。退役"移交全局指针"叙事(该叙事=并行可见漂移来源)。
#
# 解析链:
#   1. plans/.active_plan_side/<sidkey>.active_plan 会话私有指针(TTL 24h;2026-09-10 active-plan-race)
#   2. plans/.active_plan 全局 fallback → 指向的有效计划(slug 校验+task_plan.md 存在) [2026-10-10 task-v164 补注:原措辞"全局指针",降级为 fallback]
#   3. mtime 最新的 plans/<dir>/task_plan.md(跳过隐藏目录与非 slug 名)
#   4. legacy: <root>/task_plan.md(项目根单文件模式)
#   5. 全部未命中 → 空 stdout(caller 自行静默)
#
# 2026-09-10 active-plan-race: 新增第 2 可选参 SID(会话隔离)。原全局单文件 plans/.active_plan
#   被多个并行会话互相覆写(后写者赢 → hook 注入错计划/check-dispatch 误拦,09-09 实锤 7 次拦截)。
#   现拆两层:会话层 .active_plan_side/<sidkey>.active_plan(本会话私有,side 优先于全局陈旧指针)+
#   全局层 legacy 文件(cron/纯脚本单会话场景保留)。sidkey = sid 剥离非字母数字后取前 40(与 hook
#   各状态文件命名一致);第 2 参缺省 → env CLAUDE_CODE_SESSION_ID → default。side 文件 mtime >24h
#   视为会话已结束,跳过。无 side 且无 legacy 时行为=旧版(零破坏回归)。
#   [2026-10-10 task-v164 补注] 上段"全局层 legacy 文件…保留"即本文件所指 fallback 层;2026-10-10
#   起该文件已瞬态化(untracked+gitignore),角色表述统一为"全局 fallback",不再称"移交/指认全局指针"。
#
# 用法: PLAN_FILE="$(bash resolve-plan-dir.sh [project-root] [sid])"   # 默认 $PWD
# 恒 exit 0,不干扰 hook 调用方。
#
# [2026-09-10 task-planrequired-race D11] 兼容说明:side 指针文件名推导处的 sid 规范化同步剥 sess
#   前缀,与 task-plan-init.cjs / check-scope.sh / set-active-plan.sh 四处 canon 对齐(D8);
#   其余解析链(side→global→mtime→legacy)字节不变。

set -u

ROOT="${1:-$PWD}"
SID="${2:-${CLAUDE_CODE_SESSION_ID:-}}"
PLAN_ROOT="${ROOT}/plans"
SIDE_DIR="${PLAN_ROOT}/.active_plan_side"
SIDE_TTL=86400   # 会话指针 24h 过期(会话重启/机器重启后旧 sid 文件不应再生效)

# sidkey 规范化: 剥非字母数字 + 前 40 位(与 /tmp/task-planner-hook-<sid>.state 命名惯例一致)
# [2026-09-10 task-planrequired-race D11] 再剥可选 sess 前缀(D8 canon 四处对齐);
# 兼容:此前 Bash 侧(env 裸 uuid)写的 side 指针 hook 侧查不到,统一 canon 后跨源可命中
norm_sid() {
    local s="$(printf '%s' "$1" | tr -cd 'a-zA-Z0-9' | head -c 40)"
    case "$s" in
        sess*) s="${s#sess}" ;;
    esac
    [ -n "$s" ] && printf '%s' "$s" || printf 'default'
}
SID="$(norm_sid "$SID")"

# slug 安全校验:拒空白/路径分隔符/前导点(防指针内容腐烂或路径穿越,上游同款)
slug_is_valid() {
    case "$1" in
        '') return 1 ;;
        *[!A-Za-z0-9._-]*) return 1 ;;
        [A-Za-z0-9_]*) return 0 ;;
    esac
    return 1
}

# 1. 会话私有指针(side 优先于全局:本会话归属强于他人覆写的陈旧全局指针)
SIDE_FILE="${SIDE_DIR}/${SID}.active_plan"
# [2026-10-07 fix-pointer-race RC-1] 双命名空间兼容读(对齐 check-scope.sh 同款补丁语义):
# 历史写入方(init-session.sh SIDKEY / userpromptsubmit 认领协议)曾以裸 sid(含 sess 前缀)落盘,
# 剥前缀形态 miss 时回查 sess<sidkey> 形态。否则本会话指针"写得出读不到" → 解析链跌入
# mtime 最新兜底 → 被并行会话活跃计划持续劫持(2026-10-07 指针抢占事故根因之一)。
if [ ! -f "$SIDE_FILE" ]; then
    SIDE_FILE="${SIDE_DIR}/sess${SID}.active_plan"
fi
# [2026-10-07 fix-pointer-race CR-fix] env-only 调用方 sidmap 转译: init-session 经 sidmap
# (SessionStart 写 <env_sidkey>.sidmap=hook sidkey)把指针落到 hook 键名下后, env-only 调用方
# (allow-direct / check-delegation / plan-doctor / posttooluse 清锁 / attest 回退)无第二参 sid、
# 只有 env CLAUDE_CODE_SESSION_ID(env 键), 双形态(裸/sess)皆 miss 时需经 sidmap 转译到映射键
# 才能命中。动机=防本会话指针"写得出读不到"再次跌入 mtime 兜底被他会话劫持。
# 读法与 init-session.sh 一致: 第一行剥非字母数字取前 40; 非空且 ≠SID 时追加映射键双形态候选,
# 顺序探测(先映射裸形态后映射 sess 形态, 存在即选定 break); TTL/slug 校验仍作用于最终 SIDE_FILE。
if [ ! -f "$SIDE_FILE" ]; then
    _sidmap="${PLAN_ROOT}/.plan_required_side/${SID}.sidmap"
    if [ -f "$_sidmap" ]; then
        _mapped_sid="$(head -n 1 < "$_sidmap" | tr -cd 'a-zA-Z0-9' | head -c 40)"
        if [ -n "$_mapped_sid" ] && [ "$_mapped_sid" != "$SID" ]; then
            for _cand in "${SIDE_DIR}/${_mapped_sid}.active_plan" "${SIDE_DIR}/sess${_mapped_sid}.active_plan"; do
                if [ -f "$_cand" ]; then SIDE_FILE="$_cand"; break; fi
            done
        fi
    fi
fi
if [ -f "$SIDE_FILE" ]; then
    now="$(date +%s)"
    mt="$(stat -c %Y "$SIDE_FILE" 2>/dev/null || echo "$now")"
    if [ $(( now - mt )) -le "$SIDE_TTL" ]; then
        pid="$(tr -d ' \r\n\t' < "$SIDE_FILE" 2>/dev/null || true)"
        if slug_is_valid "$pid" && [ -f "${PLAN_ROOT}/${pid}/task_plan.md" ]; then
            printf '%s\n' "${PLAN_ROOT}/${pid}/task_plan.md"
            exit 0
        fi
    fi
fi

# 2. 全局指针(legacy 文件形态;目录形态=迁移残留,忽略走 mtime)
ACTIVE_FILE="${PLAN_ROOT}/.active_plan"
if [ -f "$ACTIVE_FILE" ] && [ ! -d "$ACTIVE_FILE" ]; then
    pid="$(tr -d ' \r\n\t' < "$ACTIVE_FILE" 2>/dev/null || true)"
    if slug_is_valid "$pid" && [ -f "${PLAN_ROOT}/${pid}/task_plan.md" ]; then
        printf '%s\n' "${PLAN_ROOT}/${pid}/task_plan.md"
        exit 0
    fi
fi

# 3. mtime 最新(跳过隐藏目录/非法 slug/无 task_plan.md 的目录)
latest=""
latest_mt=0
for d in "${PLAN_ROOT}"/*/; do
    [ -f "${d}task_plan.md" ] || continue
    name="$(basename "${d}")"
    case "$name" in .*) continue ;; esac
    # task-v170/S5 [2026-10-11] 防御性跳过 archive/: 本 glob 仅匹配 plans/ 直接子目录,
    # archive 内任务(task_plan.md 位于 archive/<id>/, 深度 3)天然不被解析; 此处加显式
    # 判据防未来形态变化(如 glob 放宽深度/在 archive 旁建指向性目录)时误把已归档计划
    # 解析为活跃计划。Why=归档目录仅为历史记录, 活跃解析面只认根目录在途任务
    # (口径同 sync-todos.sh INDEX/findings Technical Decisions)。
    [ "$name" = "archive" ] && continue
    slug_is_valid "$name" || continue
    mt="$(stat -c %Y "${d}" 2>/dev/null || echo 0)"
    if [ "${mt}" -gt "${latest_mt}" ]; then
        latest_mt="${mt}"
        latest="${d}task_plan.md"
    fi
done
if [ -n "$latest" ]; then
    printf '%s\n' "$latest"
    exit 0
fi

# 4. legacy 根目录单文件
if [ -f "${ROOT}/task_plan.md" ]; then
    printf '%s\n' "${ROOT}/task_plan.md"
fi
exit 0
