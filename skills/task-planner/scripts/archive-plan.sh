#!/usr/bin/env bash
# archive-plan.sh — 计划完成后归档器（task-v170，Rule 81 机制件）
#
# 用途: 把 Status 全 complete 且无在途标记的 plans/<task-id>/ 目录移入 plans/archive/<task-id>/。
#   单任务: archive-plan.sh <task-id>        实做 mv，输出 ARCHIVED/ALREADY_ARCHIVED/REJECT
#   批量:   archive-plan.sh --batch [--dry-run] [--root DIR]
#   默认 plans 根 = 脚本位置向上溯源仓根的 plans/；--root 直接指定 plans 根目录。
#
# 守卫（fail-closed，契约见 task-v170 progress.md Phase 2 定稿）:
#   - 源目录不存在 → REJECT exit 1
#   - active 指针（plans/.active_plan 或 .active_plan_side/*.active_plan 内容 == task-id）→ 拒绝
#   - .session-owner 在场且 mtime<24h（活会话标记）→ 拒绝；陈旧 owner 不拦（TTL 与 side 指针 24h 惯例一致）
#   - task_plan.md Status 列表行（行首列表符 `**Status:**` 锚）非全 complete 全词（含 0 行=异常）→ 拒绝
#     （status-incomplete / status-none；total 与 ok 共用同一列表锚行集，无锚正文行不参与两侧计数 — task-v176 D2 同口径修正）
#   - `### Phase` 标题数 ≠ Status 列表行数（Phase 覆盖不完整，翻转流程未走完）→ 拒绝 phase-uncovered，stderr 明示原因
#   - 目标 archive/<id> 已存在 → ALREADY_ARCHIVED exit 0（幂等，唯一放行特例）
#
# 执行: 目录被 git 跟踪（git ls-files 验证）→ git mv（可 revert）；未跟踪（如 v162 先例）→ mv 兜底。
# 退出码: 0=成功/幂等/--help/批量 dry-run；1=守卫拒绝/执行失败/参数错；批量实做任一 FAIL → 1。

set -u

PFX="[archive-plan]"

usage() {
    cat <<'USAGE'
Usage: bash scripts/archive-plan.sh <task-id>
       bash scripts/archive-plan.sh --batch [--dry-run]
       bash scripts/archive-plan.sh --help
Options:
  <task-id>    单任务归档 plans/<task-id> -> plans/archive/<task-id>
  --batch      批量归档 plans 根下全部合格计划目录
  --dry-run    批量模式下只列 CANDIDATE/SKIP 行，零移动
  --root DIR   覆盖 plans 根目录（缺省=脚本位置向上溯源仓根的 plans/）
  -h, --help   打印本帮助并 exit 0
Exit codes:
  0  归档成功 / ALREADY_ARCHIVED（幂等）/ --help / 批量 dry-run
  1  守卫拒绝 / 执行失败 / 参数错 / 批量实做存在 FAIL
USAGE
}

# --- 参数解析 ---------------------------------------------------------------
BATCH=0; DRY=0; TASK_ID=""; ROOT=""
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        --batch) BATCH=1; shift ;;
        --dry-run) DRY=1; shift ;;
        --root)
            if [ $# -lt 2 ] || [ -z "${2:-}" ]; then
                echo "${PFX} ERROR --root 需要非空目录参数" >&2; exit 1
            fi
            ROOT="$2"; shift 2 ;;
        -*)
            echo "${PFX} ERROR 未知参数: $1" >&2; exit 1 ;;
        *)
            if [ -n "$TASK_ID" ]; then
                echo "${PFX} ERROR 多个 task-id 冲突: ${TASK_ID} vs $1" >&2; exit 1
            fi
            TASK_ID="$1"; shift ;;
    esac
done

if [ "$BATCH" -eq 1 ] && [ -n "$TASK_ID" ]; then
    echo "${PFX} ERROR 单任务模式与 --batch 互斥" >&2; exit 1
fi
if [ "$BATCH" -eq 0 ] && [ -z "$TASK_ID" ]; then
    usage >&2; exit 1
fi

# --- plans 根推导：--root 覆盖 > 脚本位置向上找 .git（限 4 级，fuse 慢盘挂死先例同 plan-hygiene）
if [ -n "$ROOT" ]; then
    PLANS="$ROOT"
else
    d="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null)" || d="."
    depth=0
    while [ -n "$d" ] && [ "$d" != "/" ] && [ $depth -lt 4 ] && [ ! -e "$d/.git" ]; do
        d="$(dirname "$d")"; depth=$((depth + 1))
    done
    if [ -z "$d" ] || [ "$d" = "/" ] || [ ! -e "$d/.git" ]; then
        echo "${PFX} ERROR 无法向上溯源仓根，请用 --root <plans-dir>" >&2; exit 1
    fi
    PLANS="${d}/plans"
fi
[ -d "$PLANS" ] || { echo "${PFX} ERROR plans 根不存在: $PLANS" >&2; exit 1; }

# --- 守卫判定 ----------------------------------------------------------------
# guard_reason <id> → stdout 输出 "candidate" 或跳过原因码；fail-closed：
# 任何拿不准一律给 skip 码（批量归类 SKIP / 单任务 REJECT exit 1），禁把异常当 complete。
guard_reason() {
    local id="$1" src="$PLANS/$1" f
    [ -d "$src" ] || { echo "missing-src"; return; }
    # active 指针硬拦（全局+side 无例外）：内容 == task-id 即视为在途
    if [ -f "$PLANS/.active_plan" ] && [ "$(cat "$PLANS/.active_plan" 2>/dev/null)" = "$id" ]; then
        echo "active-pointer"; return
    fi
    for f in "$PLANS/.active_plan_side/"*.active_plan; do
        [ -f "$f" ] || continue
        if [ "$(cat "$f" 2>/dev/null)" = "$id" ]; then
            echo "active-pointer"; return
        fi
    done
    # live owner 仅新鲜（mtime<24h）才拦：陈旧 owner=历史残留，永久拦截会使完成任务无法归档（违背 R3）
    if [ -f "$src/.session-owner" ]; then
        local fresh
        fresh="$(find "$src/.session-owner" -mmin -1440 2>/dev/null | wc -l | tr -d '[:space:]')"
        if [ "${fresh:-0}" -ge 1 ]; then
            echo "live-owner"; return
        fi
    fi
    # Status 全量判定（task-v176 D2 同口径修正 + 2026-10-15 task-v176 CR 修复 MAJOR-1 注记同梯）：
    # What: total 与 ok 共用同一行首列表锚 `^[[:space:]]*[-*][[:space:]]+\*\*Status:\*\*` 行集——
    #      total=列表 Status 行数（计数行本身，不剥注记）；ok=其中「剥（...）/(...) 括号注记后」
    #      值以完整词 complete 开头的行数（sed 先剥全角（...）与半角(...)注记，再全词判定，
    #      与 sync-todos.sh parse_status 的归一梯同口径：剥 ** 与括号注记→全词判定）；
    #      无列表符的游离文字行（如正文引用「完成态格式为 **Status:** complete」样例行）两侧均不参与计数。
    # Why: 原实现 total（列表锚 grep -cE）与 ok（无锚全文 `Status:\*\* complete` grep -c）口径不对称，
    #      双向失真实证（task-v176 findings D2：假 PASS=非 complete 列表行被补数放行；假 FAIL=正文引用
    #      多计使真完成任务被拒 status-incomplete）。本脚本是 Rule 81 归档唯一执行体，计数失真=在途任务
    #      被误归档（数据面事故）或完成任务被永久卡死，故 fail-closed 统一收口为「同一行集上判全词」。
    #      CR MAJOR-1（2026-10-15）：ok 侧旧正则 `complete([[:space:]]|$)` 未剥注记——存量 archive 中
    #      `- **Status:** complete（2026-10-15 完成）` 带注记形态（plans/archive/task-v146 实证）使
    #      total=1 但 ok=0 → status-incomplete 假 FAIL；而 sync-todos parse_status 对同输入判 complete，
    #      两侧口径分裂。故 ok 侧先剥 `（[^）]*）`/`([^)]*)` 注记再全词判定（sed 管道加一层）；
    #      total 侧口径不变（列表锚计数行本身，注记不影响行计数）。
    local tp="$src/task_plan.md" total ok
    [ -f "$tp" ] || { echo "no-task-plan"; return; }
    total="$(grep -cE '^[[:space:]]*[-*][[:space:]]+\*\*Status:\*\*' "$tp" 2>/dev/null)"
    ok="$(grep -E '^[[:space:]]*[-*][[:space:]]+\*\*Status:\*\*' "$tp" 2>/dev/null | sed 's/（[^）]*）//g; s/([^)]*)//g' | grep -cE '\*\*Status:\*\*[[:space:]]+complete([[:space:]]|$)')"
    total="${total:-0}"; ok="${ok:-0}"
    if [ "$total" -lt 1 ]; then
        echo "status-none"; return
    fi
    if [ "$total" != "$ok" ]; then
        echo "status-incomplete"; return
    fi
    # Phase 覆盖校验（task-v176 D2 缺陷4 修正）：
    # What: `### Phase` 标题数必须与 Status 列表行数相等；不等即拒绝（缺状态行=有 Phase 未走完翻转流程），
    #      stderr 明示缺失数量（原因码 phase-uncovered 供批量 SKIP 行对账）。
    # Why: 原实现只统计"已存在的 Status 行"——中途追加 Phase 忘写 Status 行时被整体忽略，照样判可归档，
    #      与 check-complete（按 Phase 条目判定 in_progress）结论分裂。覆盖校验把「每 Phase 必有 Status 行」
    #      设为归档前置条件，消除漏写放行通道（fail-closed）。
    local phases
    phases="$(grep -cE '^### Phase' "$tp" 2>/dev/null)"
    phases="${phases:-0}"
    if [ "$phases" -ne "$total" ]; then
        echo "${PFX} 拒绝归档 $id: Phase 覆盖不完整：$phases 个 Phase 仅 $total 个有 Status 行，缺状态行=计划未走完翻转流程" >&2
        echo "phase-uncovered"; return
    fi
    echo "candidate"
}

# --- 归档执行：git 跟踪 → git mv（可 revert），否则 mv 兜底（v162 未跟踪先例） -------------
do_archive() {
    local id="$1" tgt="$PLANS/archive/$1"
    mkdir -p "$PLANS/archive" || return 1
    if git -C "$PLANS" ls-files --error-unmatch "$id" >/dev/null 2>&1; then
        git -C "$PLANS" mv "$id" "archive/$id" || return 1
    else
        mv "$PLANS/$id" "$tgt" || return 1
    fi
    return 0
}

# --- 单任务模式 ---------------------------------------------------------------
if [ -n "$TASK_ID" ]; then
    id="$TASK_ID"
    # 幂等先行：目标已存在 = 之前已归档成功，重跑直接放行 exit 0
    if [ -e "$PLANS/archive/$id" ]; then
        echo "${PFX} ALREADY_ARCHIVED $id"
        exit 0
    fi
    reason="$(guard_reason "$id")"
    if [ "$reason" != "candidate" ]; then
        echo "${PFX} REJECT $id: $reason"
        exit 1
    fi
    if do_archive "$id"; then
        echo "${PFX} ARCHIVED $id -> $PLANS/archive/$id"
        exit 0
    else
        echo "${PFX} FAIL $id: move 失败（权限/锁?）"
        exit 1
    fi
fi

# --- 批量模式 -----------------------------------------------------------------
TOTAL=0; OK=0; SKIP=0; FAIL=0
MODE="execute"; [ "$DRY" -eq 1 ] && MODE="dry-run"
echo "${PFX} === batch(${MODE}, root=${PLANS}) ==="

# 枚举 plans 根直接子目录：find -maxdepth 1 而非 glob，目的是圆点目录也显式归类 SKIP
# （glob 默认跳过 dot 目录，会导致"归类跳过"语义不可观测；圆点目录=指针/隐藏态，天然非计划目录）
while IFS= read -r name; do
    [ -n "$name" ] || continue
    TOTAL=$((TOTAL + 1))
    case "$name" in
        .*)
            echo "${PFX} SKIP $name (not-a-plan-dir: hidden)"
            SKIP=$((SKIP + 1)); continue ;;
        archive)
            echo "${PFX} SKIP $name (not-a-plan-dir: archive-target)"
            SKIP=$((SKIP + 1)); continue ;;
        task-*) : ;;
        *)
            echo "${PFX} SKIP $name (not-a-plan-dir: not task- prefixed)"
            SKIP=$((SKIP + 1)); continue ;;
    esac
    if [ ! -f "$PLANS/$name/task_plan.md" ]; then
        echo "${PFX} SKIP $name (not-a-plan-dir: no task_plan.md)"
        SKIP=$((SKIP + 1)); continue
    fi
    # 幂等：目标已存在 = 已在 archive（上次批量跑到一半重跑），归类 skip 不 FAIL
    if [ -e "$PLANS/archive/$name" ]; then
        echo "${PFX} SKIP $name (already-archived)"
        SKIP=$((SKIP + 1)); continue
    fi
    reason="$(guard_reason "$name")"
    if [ "$reason" != "candidate" ]; then
        echo "${PFX} SKIP $name ($reason)"
        SKIP=$((SKIP + 1)); continue
    fi
    # 契约：dry-run 逐目录输出 SKIP(candidate/<reason>)，零移动（find 计数前后一致）
    if [ "$DRY" -eq 1 ]; then
        echo "${PFX} SKIP $name (candidate/none)"
        SKIP=$((SKIP + 1)); continue
    fi
    if do_archive "$name"; then
        echo "${PFX} ARCHIVED $name -> $PLANS/archive/$name"
        OK=$((OK + 1))
    else
        echo "${PFX} FAIL $name: move 失败（权限/锁?）"
        FAIL=$((FAIL + 1))
    fi
done < <(find "$PLANS" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | xargs -n 1 basename 2>/dev/null | sort)

echo "${PFX} BATCH total=${TOTAL} ok=${OK} skip=${SKIP} fail=${FAIL} (${MODE})"
if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
exit 0
