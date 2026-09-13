#!/usr/bin/env bash
# plan-hygiene.sh — 工作文件整理器（Rule 29.4/29.5，task-v069）
#
# 用途: 扫描 plans-dir 下任务目录,输出归档/清理清单。诊断型(对齐 plan-doctor 风格)。
#   1. 含 task_plan.md 的目录: 全部 Phase 的 Status 均 complete(且无 in_progress/pending)
#      且 task_plan.md mtime 超过 age 天 → 归档清单(--execute 时 mv 入 archive/)
#   2. .plan_required_side/ 与 .active_plan_side/ 中 mtime>24h 隐藏指针残留
#      → 提示跑 set-active-plan.sh gc(不自动执行)
#   3. 仓根存在 .git 时: worktree 遗留(路径不存在的 worktree → 提示 git worktree prune;
#      wt/* 遗留分支仅提示不删)
#
# 用法: bash scripts/plan-hygiene.sh <plans-dir> [--dry-run|--execute] [--age N]
#   默认 --dry-run 只展示清单不执行;--execute 才实际 mv(目标已存在 → FAIL 该行跳过)。
#
# 归档年龄阈值: --age N 覆盖;缺省读 config.json#plan_archive_age_days
#   (jq -r '.properties.plan_archive_age_days.default';jq 缺失/读失败 → fail-open 默认 7)
#
# 退出码: 恒 exit 0(诊断型);--execute 时若有 FAIL 行 → exit 1

set -u

PFX="[plan-hygiene]"

if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
    echo "Usage: bash scripts/plan-hygiene.sh <plans-dir> [--dry-run|--execute] [--age N]" >&2
    exit 2
fi

PLANS_DIR="$1"; shift

MODE="dry-run"
AGE=""
while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) MODE="dry-run"; shift ;;
        --execute) MODE="execute"; shift ;;
        --age)
            if [ $# -lt 2 ] || ! [[ "${2:-}" =~ ^[0-9]+$ ]] || [ "${2}" -lt 1 ]; then
                echo "Usage: --age N(N 为正整数)" >&2
                exit 2
            fi
            AGE="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 <plans-dir> [--dry-run|--execute] [--age N]"
            exit 0 ;;
        *)
            echo "${PFX} 未知参数: $1" >&2
            exit 2 ;;
    esac
done

[ -d "$PLANS_DIR" ] || { echo "${PFX} plans-dir 不存在: $PLANS_DIR"; exit 1; }

# 归档年龄阈值: --age N > config.json#plan_archive_age_days > 默认 7(fail-open)
if [ -z "${AGE}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null)" || SCRIPT_DIR="."
    CFG="${SCRIPT_DIR}/../config.json"
    if command -v jq >/dev/null 2>&1 && [ -f "$CFG" ]; then
        AGE="$(jq -r '.properties.plan_archive_age_days.default // empty' "$CFG" 2>/dev/null || true)"
    fi
    case "${AGE}" in
        ''|*[!0-9]*) AGE=7 ;;
    esac
fi

FAIL_LINES=0
ARCHIVE_COUNT=0

echo "${PFX} === plan-hygiene(${MODE}, age=${AGE}d) ==="

# --- [1] 任务目录归档清单 ----------------------------------------------------
if [ "${MODE}" = "execute" ]; then
    mkdir -p "${PLANS_DIR}/archive" 2>/dev/null
fi # 仅 execute 创建;dry-run 保持只读
for dir in "${PLANS_DIR}"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    # 排除隐藏目录与已有 archive
    case "$name" in
        .*) continue ;;
        archive) continue ;;
    esac
    TASK_PLAN="${dir}task_plan.md"
    [ -f "$TASK_PLAN" ] || continue
    # completed 判定: Status complete ≥1 且 无 in_progress/pending
    ok_n=$(grep -c 'Status:\*\* complete' "$TASK_PLAN" 2>/dev/null || true)
    open_n=$(grep -cE 'Status:\*\* (in_progress|pending)' "$TASK_PLAN" 2>/dev/null || true)
    if [ "${ok_n:-0}" -lt 1 ] || [ "${open_n:-0}" -gt 0 ]; then
        continue  # 未全 completed → 跳过
    fi
    mtime="$(stat -c %Y "$TASK_PLAN" 2>/dev/null || echo 0)"
    now="$(date +%s)"
    age_days=$(( (now - mtime) / 86400 ))
    if [ "${age_days}" -ge "${AGE}" ]; then
        target="${PLANS_DIR}/archive/${name}"
        if [ "${MODE}" = "execute" ]; then
            if [ -e "$target" ]; then
                echo "${PFX} FAIL ${name}: 目标已存在 ${target}(不覆盖,跳过)"
                FAIL_LINES=$((FAIL_LINES + 1))
            else
                if mv "$dir" "$target" 2>/dev/null; then
                    echo "${PFX} MOVED ${name} -> archive/"
                    ARCHIVE_COUNT=$((ARCHIVE_COUNT + 1))
                else
                    echo "${PFX} FAIL ${name}: mv 失败(权限/锁?)"
                    FAIL_LINES=$((FAIL_LINES + 1))
                fi
            fi
        else
            echo "${PFX} ARCHIVE ${name} (age ${age_days}d)"
            ARCHIVE_COUNT=$((ARCHIVE_COUNT + 1))
        fi
    fi
done

# --- [2] 隐藏指针残留(>24h) → 提示跑 set-active-plan.sh gc(不自动执行) ------
for side in .plan_required_side .active_plan_side; do
    sd="${PLANS_DIR}/${side}"
    [ -d "$sd" ] || continue
    # [perf] find 单遍计数(-print | wc -l 逐目录 stat 在大 plans 树会很慢),maxdepth 1 限本目录层
    old_files="$(find "$sd" -maxdepth 1 -type f -mmin +1440 2>/dev/null | wc -l | tr -d '[:space:]')"
    if [ "${old_files:-0}" -gt 0 ]; then
        echo "${PFX} ${side}: ${old_files} 个 mtime>24h 指针残留 → 建议跑 set-active-plan.sh gc(不自动执行)"
    fi
done

# --- [3] worktree 遗留(仅仓根存在 .git 时;只提示不删) -----------------------
# [perf 2026-09-14] 仓根查找限 4 级向上: 主仓 plans/ 距 .git 仅 2 级;外部仓最多 4 级。
# 再上走 / 在 fuse/NFS 慢盘上会挂死(实测 3m45s 无果,2m+ 后被 kill)。限 4 级后 fail-open 跳过,
# worktree 提示行只针对本机仓根可达的 plans-dir。
repo_root="$(cd "$PLANS_DIR" 2>/dev/null && pwd)"
depth=0
while [ -n "$repo_root" ] && [ "$repo_root" != "/" ] && [ $depth -lt 4 ] && [ ! -e "${repo_root}/.git" ]; do
    repo_root="$(dirname "$repo_root")"
    depth=$((depth + 1))
done
if [ -n "$repo_root" ] && [ -e "${repo_root}/.git" ]; then
    # 主仓 git worktree list 在外部 plans-dir(非本 worktree 仓根)下跑,
    # 用 --porcelain 逐行解析: 0 行=主 worktree,1 行=其他;路径以 1 行起始
    stale_paths="$(git -C "$repo_root" worktree list --porcelain 2>/dev/null | awk '
        $0 ~ /^worktree / { print substr($0, 10) }' || true)"
    while IFS= read -r p; do
        [ -n "$p" ] || continue
        # 跳过当前执行脚本所在仓的 worktree(路径不存在才提示 prune)
        if [ ! -d "$p" ]; then
            echo "${PFX} worktree 遗留(路径不存在): ${p} → 建议 git worktree prune"
        fi
    done <<< "$stale_paths"
    wt_branches="$(git -C "$repo_root" branch --list 'wt/*' 2>/dev/null | sed 's/^[* ]*//; s/^+ //; s/^+ //' || true)"
    if [ -n "$wt_branches" ]; then
        while IFS= read -r b; do
            [ -n "$b" ] || continue
            echo "${PFX} wt/* 遗留分支: ${b}(仅提示,不自动删除;确认无用后 git branch -d)"
        done <<< "$wt_branches"
    fi
fi

# --- 汇总 -------------------------------------------------------------------
echo "${PFX} 汇总: 归档清单 ${ARCHIVE_COUNT} 项(${MODE});FAIL ${FAIL_LINES} 行"
echo "${PFX} 归档后请重跑 sync-todos.sh --index 修正 INDEX 统计（Rule 29.4）"

if [ "${MODE}" = "execute" ] && [ "${FAIL_LINES}" -gt 0 ]; then
    exit 1
fi
exit 0
