#!/usr/bin/env bash
# plan-doctor.sh — 计划机制一键自检（移植适配自上游 planning-with-files v3 scripts/plan-doctor.sh）
# 上游: https://github.com/OthmanAdi/planning-with-files — 本移植适配本仓拓扑:
#   计划解析 = plans/*/task_plan.md(mtime 最新,无 .active_plan 指针);
#   hook 面 = 4 个 zcode-*.sh(SessionStart/PreToolUse/PostToolUse/UserPromptSubmit);
#   安装面 = ~/.zcode/skills/task-planner + ~/.claude/skills/task-planner(实体副本模型)。
#
# 回答: 计划解析到哪个? hook 是否发暗? attestation 在不在? 部署位漂没漂? hook 一次多少毫秒?
# 诊断 only,除自身探测外不写任何文件,恒 exit 0。
# 用法: bash scripts/plan-doctor.sh [project-root](默认 cwd)

set -u

ROOT="${1:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null)" || SCRIPT_DIR="."
SKILL_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

ok()   { printf 'PASS  %s\n' "$1"; }
warn() { printf 'WARN  %s\n' "$1"; }
fail() { printf 'FAIL  %s\n' "$1"; }
info() { printf 'info  %s\n' "$1"; }

echo '=== task-planner plan-doctor ==='
info "cwd: ${ROOT}"
info "uname: $(uname -s 2>/dev/null || echo unknown)"
[ "${PLANNING_DISABLED:-}" = "1" ] && warn "PLANNING_DISABLED=1 — 本环境所有 hook 立即退出"

# --- [1] canonicalizer 探测(上游同款) ----------------------------------------
CANON="$(realpath "${ROOT}" 2>/dev/null || readlink -f "${ROOT}" 2>/dev/null || true)"
case "${CANON}" in
    '') warn "无 realpath/readlink 可用 — 路径规范化能力受限" ;;
    *) info "canonicalizer: ${CANON}" ;;
esac

# --- [2] 计划解析 ------------------------------------------------------------
PLAN=""
RESOLVER="${SCRIPT_DIR}/resolve-plan-dir.sh"
if [ -f "${RESOLVER}" ]; then
    # [2026-09-05 task-active-plan] 指针优先,与 hook 同一解析逻辑
    PLAN="$(bash "${RESOLVER}" "${ROOT}" 2>/dev/null || true)"
else
    if [ -d "${ROOT}/plans" ]; then
        PLAN="$(ls -t "${ROOT}"/plans/*/task_plan.md 2>/dev/null | head -1 || true)"
    fi
fi
if [ -n "${PLAN}" ]; then
    AGE=$(( $(date +%s) - $(stat -c %Y "${PLAN}" 2>/dev/null || echo 0) ))
    ACTIVE_FILE="${ROOT}/plans/.active_plan"
    SRC="mtime 最新"
    [ -f "${ACTIVE_FILE}" ] && SRC="指针 $(tr -d ' \r\n\t' < "${ACTIVE_FILE}" 2>/dev/null)"
    if [ "${AGE}" -gt 86400 ]; then
        info "计划解析: ${PLAN}(>24h 未更新,hook 视为历史任务静默;来源: ${SRC})"
    else
        ok "计划解析: ${PLAN}(来源: ${SRC})"
    fi
    info "切换活跃计划: bash scripts/set-active-plan.sh <task-id>;查看: --show;清除回退 mtime: --clear"
else
    info "plans/ 下无 task_plan.md(运行 init-session.sh 创建)"
fi

# --- [3] hook 面(4 事件位存在性 + sessionstart 实跑) --------------------------
HOOKS=(zcode-sessionstart.sh zcode-pretooluse.sh zcode-posttooluse.sh zcode-userpromptsubmit.sh)
for h in "${HOOKS[@]}"; do
    f="${SKILL_ROOT}/scripts/${h}"
    if [ -f "${f}" ] && [ -x "${f}" ]; then
        ok "hook 在位: ${h}"
    elif [ -f "${f}" ]; then
        warn "hook 不可执行: ${h}(chmod +x 可修)"
    else
        fail "hook 缺失: ${h}"
    fi
done
if bash -n "${SKILL_ROOT}/scripts/zcode-sessionstart.sh" 2>/dev/null; then
    T0="$(date +%s%N 2>/dev/null || echo 0)"
    OUT="$(printf '{"cwd":"%s"}' "${ROOT}" | bash "${SKILL_ROOT}/scripts/zcode-sessionstart.sh" 2>/dev/null || true)"
    T1="$(date +%s%N 2>/dev/null || echo 0)"
    if [ -n "${OUT}" ]; then
        case "${OUT}" in
            *'PLAN TAMPERED'*)
                warn "注入: attestation 哈希不符 — 重跑 scripts/attest-plan.sh 重新锁定" ;;
            *)
                BYTES="$(printf '%s' "${OUT}" | wc -c | tr -d '[:space:]')"
                ok "注入实跑: sessionstart 输出 ${BYTES} 字节" ;;
        esac
    else
        info "注入实跑: 输出为空(无活跃计划时静默=正确行为)"
    fi
    if [ "${T0}" != "0" ] && [ "${T1}" != "0" ] && [ "${T1}" -gt "${T0}" ]; then
        info "hook 延迟: sessionstart 单次 $(( (T1 - T0) / 1000000 ))ms"
    fi
else
    fail "sessionstart.sh 语法错误(bash -n 失败)"
fi

# --- [4] attestation ---------------------------------------------------------
ATT=""
if [ -n "${PLAN}" ]; then
    PDIR="$(dirname "${PLAN}")"
    [ -f "${PDIR}/.plan-attestation" ] && ATT="${PDIR}/.plan-attestation"
fi
if [ -n "${ATT}" ]; then
    ok "attestation 在位: ${ATT}"
else
    info "attestation: 无(运行 attest-plan.sh 锁定计划,防篡改注入)"
fi

# --- [5] 安装面(实体副本模型,含漂移核对) --------------------------------------
SURFACES=0
for d in "${HOME}/.zcode/skills/task-planner" "${HOME}/.claude/skills/task-planner"; do
    if [ -L "${d}" ]; then
        warn "安装位仍是软链: ${d}(D7 后应为实体副本,建议重装)"
        SURFACES=$((SURFACES+1))
    elif [ -d "${d}" ]; then
        if diff -rq --exclude=.git --exclude=install.log "${SKILL_ROOT}" "${d}" >/dev/null 2>&1; then
            ok "安装位一致: ${d}"
        else
            warn "安装位漂移: ${d} 与仓内 ${SKILL_ROOT} 不一致(合并后需 rsync 重同步)"
        fi
        SURFACES=$((SURFACES+1))
    fi
done
[ "${SURFACES}" -eq 0 ] && info "无安装面(仅仓内使用)"

# --- [6] 宿主能力边界(上游完成门 Tier 对照) -----------------------------------
info "宿主能力: ZCode hooks 仅 SessionStart/PreToolUse/PostToolUse/UserPromptSubmit 4 事件,无 Stop — 上游五守卫完成门(gate-stop.sh --gate)的 Tier1 硬阻断在本宿主不可用;执行中强制 = posttooluse [plan-compass] 提醒/升级 + 契约要求 Phase 翻转前自跑 check-3file-gate.sh"

echo '=== plan-doctor done ==='
exit 0
