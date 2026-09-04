#!/usr/bin/env bash
# ledger-append.sh — 追加式工作账本（移植自上游 planning-with-files v3 scripts/ledger-append.sh）
# 上游: https://github.com/OthmanAdi/planning-with-files — 本移植为适配裁剪版（D4）:
#   保留上游已验证的 tick 全局单调/flock 并发/UTF-8 截断修复/事件枚举/JSON 转义;
#   变更: plan-dir 由上游的 resolver 链改为第一个位置参数显式传参（本仓脚本惯例,无 .active_plan）;
#         裁剪上游 od/dd 字节级 UTF-8 兜底(仅 busybox/无 iconv 场景,本仓部署为 Linux glibc)。
#
# 用法: ledger-append.sh <plan-dir> <event> <summary> [--agent NAME] [--phase N] [--files f1,f2]
#   <event> 枚举: progress | phase_complete | error | gate_block | attest | note
# 写入: <plan-dir>/ledger-<agent>.jsonl 单行 JSON:
#   {"tick":N,"ts":"ISO8601Z","agent":"...","phase":"...","event":"...","summary":"...","files":[...]}
# tick = 计划目录内全部 ledger-*.jsonl 的 max+1 —— 并发 agent 共享单调计数,
#        check-3file-gate.sh 的停滞判定据此看到同一条有序工作流。
#
# 为什么用账本而非 mtime: 上游完成门 G5 设计注记 —— "mtime moves on any file
# touch and is thus unreliable as a progress indicator"。ledger 行 = 语义化真实
# 工作记录,不可通过 touch 伪造。

set -u

VALID_EVENTS="progress phase_complete error gate_block attest note"

usage() {
    printf 'Usage: %s <plan-dir> <event> <summary> [--agent NAME] [--phase N] [--files f1,f2]\n' "$0" >&2
    printf '  event one of: %s\n' "${VALID_EVENTS}" >&2
}

PLAN_DIR="${1:-}"
[ -z "${PLAN_DIR}" ] && { usage; exit 2; }
shift
EVENT="${1:-}"
case "${EVENT}" in
    -h|--help|"") usage; [ -z "${EVENT}" ] && exit 2 || exit 0 ;;
esac
shift
SUMMARY="${1:-}"
if [ -z "${SUMMARY}" ]; then
    printf '[ledger] missing <summary> argument.\n' >&2; usage; exit 2
fi
shift

if [ ! -d "${PLAN_DIR}" ]; then
    printf '[ledger] plan dir not found: %s\n' "${PLAN_DIR}" >&2
    exit 2
fi

AGENT="main"
PHASE=""
FILES_CSV=""
while [ $# -gt 0 ]; do
    case "$1" in
        --agent)  AGENT="${2:-}";  shift 2 || { printf '[ledger] --agent needs a value.\n' >&2;  exit 2; } ;;
        --phase)  PHASE="${2:-}";  shift 2 || { printf '[ledger] --phase needs a value.\n' >&2;  exit 2; } ;;
        --files)  FILES_CSV="${2:-}"; shift 2 || { printf '[ledger] --files needs a value.\n' >&2; exit 2; } ;;
        *) printf "[ledger] unknown option: %s\n" "$1" >&2; usage; exit 2 ;;
    esac
done

valid=0
for e in ${VALID_EVENTS}; do
    [ "${EVENT}" = "${e}" ] && { valid=1; break; }
done
if [ "${valid}" -ne 1 ]; then
    printf "[ledger] invalid event '%s' (allowed: %s)\n" "${EVENT}" "${VALID_EVENTS}" >&2
    exit 2
fi

# 上游 sanitize: agent 名只留安全字符,空则回退 main。
clean="$(printf '%s' "${AGENT}" | tr -cd 'A-Za-z0-9_-')"
AGENT="${clean:-main}"

# JSON 字符串转义: 反斜杠/双引号 + 全部控制字符映射为空格(上游同款单 tr 处理,
# 与 PowerShell ConvertTo-JsonString 行为对齐,保证 JSONL 跨平台可解析)。
json_escape() {
    printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | tr '\001-\037' ' '
}

# summary 截断到 200 字符;GNU cut 按字节可能截断在多字节字符中间,
# iconv -c 修复尾部不完整序列,保证 JSONL 行始终是合法 UTF-8(上游同款)。
SUMMARY="$(printf '%s' "${SUMMARY}" | cut -c1-200 | iconv -f UTF-8 -t UTF-8 -c 2>/dev/null || printf '%s' "${SUMMARY}" | cut -c1-200)"

TS="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)"
TS="${TS:-1970-01-01T00:00:00Z}"

# files 逗号列表 → JSON 数组。
FILES_JSON="[]"
if [ -n "${FILES_CSV}" ]; then
    FILES_JSON="["
    first=1
    OLD_IFS="$IFS"; IFS=','
    for item in ${FILES_CSV}; do
        IFS="$OLD_IFS"
        [ -z "${item}" ] && { IFS=','; continue; }
        esc="$(json_escape "${item}")"
        if [ "${first}" -eq 1 ]; then FILES_JSON="${FILES_JSON}\"${esc}\""; first=0
        else FILES_JSON="${FILES_JSON},\"${esc}\""; fi
        IFS=','
    done
    IFS="$OLD_IFS"
    FILES_JSON="${FILES_JSON}]"
fi

SUMMARY_ESC="$(json_escape "${SUMMARY}")"
PHASE_ESC="$(json_escape "${PHASE}")"
LEDGER_FILE="${PLAN_DIR}/ledger-${AGENT}.jsonl"
LOCK_FILE="${PLAN_DIR}/.ledger_lock"

# tick = 目录内所有 ledger-*.jsonl 的最大 tick + 1(sed 提取,无 jq 依赖,上游同款)。
max_tick_in_dir() {
    max=0
    for f in "${PLAN_DIR}"/ledger-*.jsonl; do
        [ -f "${f}" ] || continue
        ticks="$(sed -n 's/.*"tick"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' "${f}" 2>/dev/null)"
        for t in ${ticks}; do
            if [ "${t}" -gt "${max}" ] 2>/dev/null; then max="${t}"; fi
        done
    done
    printf '%s' "${max}"
}

append_line() {
    tick="$(max_tick_in_dir)"
    tick=$((tick + 1))
    printf '{"tick":%s,"ts":"%s","agent":"%s","phase":"%s","event":"%s","summary":"%s","files":%s}\n' \
        "${tick}" "${TS}" "${AGENT}" "${PHASE_ESC}" "${EVENT}" "${SUMMARY_ESC}" "${FILES_JSON}" \
        >> "${LEDGER_FILE}"
    printf '%s' "${tick}"
}

# flock 在持锁期间同时计算 tick 并写入,防并发 appender 撞号(上游同款);
# 无 flock 时单 printf 追加 <4KB 近似原子。
if command -v flock >/dev/null 2>&1; then
    written_tick="$(
        (
            flock -w 5 9 || true
            append_line
        ) 9>"${LOCK_FILE}" 2>/dev/null
    )"
    rm -f "${LOCK_FILE}" 2>/dev/null || true
else
    written_tick="$(append_line)"
fi

printf '[ledger] tick %s -> %s (event=%s agent=%s)\n' \
    "${written_tick:-?}" "${LEDGER_FILE}" "${EVENT}" "${AGENT}"
exit 0
