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
#   - task_plan.md 全部 `- **Status:**` 行非全 complete（含 0 行=异常）→ 拒绝
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
    # Status 全量判定：全部 `- **Status:**` 行均 complete 且总数>0；
    # 禁 grep -m1（早期 Phase 已 complete 会误放行）；0 行=异常文件，fail-closed 拒绝
    local tp="$src/task_plan.md" total ok
    [ -f "$tp" ] || { echo "no-task-plan"; return; }
    total="$(grep -cE '^[[:space:]]*[-*][[:space:]]+\*\*Status:\*\*' "$tp" 2>/dev/null)"
    ok="$(grep -c 'Status:\*\* complete' "$tp" 2>/dev/null)"
    total="${total:-0}"; ok="${ok:-0}"
    if [ "$total" -lt 1 ]; then
        echo "status-none"; return
    fi
    if [ "$total" != "$ok" ]; then
        echo "status-incomplete"; return
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
