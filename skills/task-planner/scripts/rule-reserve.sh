#!/usr/bin/env bash
# rule-reserve.sh — Rule 编号预留登记账本（Rule 20.6 / task-v128 设计冻结 D2）
#
# 用途：新增 Rule 编号的所有权登记。计划声明 new_rule: <NN> 后、attest 前由
#   任务预留编号，合并后 land、废弃时 release；冲突/占位按「同 rule 取最后一条」判定。
#   账本 append-only（>> 原子追加，旧行永不被修改），查询取末条归并。
#   锚点：critical-rules.md Rule 20.6（attest-plan.sh 查重自动登记，task-v128 S2 实现）。
# 输入（位置参）：
#   reserve <N> <task-id> [--note "..."]   登记；被其他任务持有 → stderr 持有人详情 + exit 3
#   check <N>                               空闲 → stdout "free" + exit 0；被持有 → 持有人行 + exit 3
#   next                                    建议下一可用编号（> max landed 且跳过 reserved/contested 占位）
#   list                                    全景表格（rule/status/holder/note）
#   land <N> <task-id>                      置 landed（仅当前持有人；contested 时任一 claimant；否则 exit 4）
#   release <N> <task-id> [--note "..."]    置 abandoned（仅持有人；contested 需 --note；否则 exit 4）
# 输出 / exit 语义：
#   0 成功 / 空闲；3 编号被他人持有；4 land/release 越权（非持有人或无持有记录）；
#   5 账本路径三级解析全部失败；2 用法错误（缺参/非整数/contested release 缺 --note）。
# 依赖：bash + coreutils(grep/sed/tr/tail/sort/date)。JSON 解析优先用 jq；
#   无 jq 时自动降级 grep/sed（账本行均由本脚本/种子步骤机器产出，格式稳定）；
#   RULE_RESERVE_FORCE_NO_JQ=1 可强制走降级路径供自测。
#   账本路径三级解析：env RULE_RESERVE_LEDGER > 从 CWD 向上找含 plans/ 的祖先
#   （账本 = 该祖先/plans/.rule-reservations.jsonl）> 均失败 stderr 报错 exit 5。
#   自测台阶：一律 RULE_RESERVE_LEDGER=/tmp/xxx.jsonl 指临时账本，禁写仓库真账本。

set -u

LEDGER_BASENAME=".rule-reservations.jsonl"

# jq 探测（Why: 降级路径必须可测，故留 FORCE 开关）
have_jq=0
if [ "${RULE_RESERVE_FORCE_NO_JQ:-0}" != "1" ] && command -v jq >/dev/null 2>&1; then
  have_jq=1
fi

usage() {
  cat >&2 <<'EOF'
Usage: rule-reserve.sh <cmd> [args]
  reserve <N> <task-id> [--note "..."]  预留编号（冲突 → stderr 持有人详情 + exit 3）
  check <N>                             查询：空闲 → "free" exit 0；被持有 → 持有人行 exit 3
  next                                  建议下一可用编号
  list                                  全景表格（rule/status/holder/note）
  land <N> <task-id>                    置 landed（仅当前持有人；否则 exit 4）
  release <N> <task-id> [--note "..."]  置 abandoned（仅持有人；contested 需 --note；否则 exit 4）
Ledger path: env RULE_RESERVE_LEDGER > CWD 祖先含 plans/ 目录 > exit 5
EOF
}

# ---- 账本路径三级解析（D2 契约）----
resolve_ledger() {
  if [ -n "${RULE_RESERVE_LEDGER:-}" ]; then
    LEDGER="${RULE_RESERVE_LEDGER}"
    return 0
  fi
  local d
  d="$(pwd)"
  while :; do
    if [ -d "${d}/plans" ]; then
      LEDGER="${d}/plans/${LEDGER_BASENAME}"
      return 0
    fi
    [ "${d}" = "/" ] && break
    d="$(cd "${d}/.." && pwd)"
  done
  printf '[rule-reserve] 无法解析账本：CWD=%s 向上未找到含 plans/ 的祖先，且未设 RULE_RESERVE_LEDGER\n' "$(pwd)" >&2
  return 1
}

# ---- JSON 辅助（jq 优先，grep/sed 降级；格式稳定因账本行皆机器产出）----
json_escape() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | tr '\001-\037' ' '
}

sanitize_task() {
  # task-id 只留安全字符，防注入破坏 JSONL（同 ledger-append.sh 惯例）
  printf '%s' "$1" | tr -cd 'A-Za-z0-9_-'
}

ledger_lines() {
  # 无账本文件 = 空账本（D2：首次 reserve 自动创建），非错误
  [ -f "${LEDGER}" ] && cat "${LEDGER}" || true
}

last_entry() {
  # 「同 rule 取最后一条」归并（append-only 下末行即最新状态）
  local n="$1" line
  if [ "${have_jq}" -eq 1 ]; then
    line="$(ledger_lines | jq -c --argjson n "${n}" 'select(.rule == $n)' 2>/dev/null | tail -n 1)"
  else
    line="$(ledger_lines | grep -E "^[[:space:]]*{\"rule\":${n}," 2>/dev/null | tail -n 1 || true)"
  fi
  printf '%s' "${line}"
}

last_status() {
  local entry
  entry="$(last_entry "$1")"
  [ -n "${entry}" ] || return 0
  if [ "${have_jq}" -eq 1 ]; then
    printf '%s' "${entry}" | jq -r '.status // empty' 2>/dev/null
  else
    printf '%s' "${entry}" | sed -n 's/.*"status"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1
  fi
}

task_of() {
  if [ "${have_jq}" -eq 1 ]; then
    printf '%s' "$1" | jq -r '.task_id // empty' 2>/dev/null
  else
    printf '%s' "$1" | sed -n 's/.*"task_id":"\([^"]*\)".*/\1/p' | head -n 1
  fi
}

ts_of() {
  if [ "${have_jq}" -eq 1 ]; then
    printf '%s' "$1" | jq -r '.ts // empty' 2>/dev/null
  else
    printf '%s' "$1" | sed -n 's/.*"ts":"\([^"]*\)".*/\1/p' | head -n 1
  fi
}

note_of() {
  if [ "${have_jq}" -eq 1 ]; then
    printf '%s' "$1" | jq -r '.note // empty' 2>/dev/null
  else
    # note 恒为行内最后一个字段
    printf '%s' "$1" | sed -n 's/.*"note":"\(.*\)"}$/\1/p'
  fi
}

claimants_of() {
  # 逐行输出 claimants（降级路径依赖 claimants 数组内无嵌套括号——机器产出行保证）
  if [ "${have_jq}" -eq 1 ]; then
    printf '%s' "$1" | jq -r '(.claimants // [])[]' 2>/dev/null
  else
    printf '%s' "$1" | sed -n 's/.*"claimants":[[:space:]]*\[\([^]]*\)\].*/\1/p' \
      | tr ',' '\n' | tr -d ' "'
  fi
}

rule_numbers() {
  # 账本内全部出现过的 rule 号（升序去重）
  if [ "${have_jq}" -eq 1 ]; then
    ledger_lines | jq -r '.rule // empty' 2>/dev/null | sort -un
  else
    ledger_lines | grep -oE '"rule":[0-9]+' 2>/dev/null | sed 's/"rule"://' | sort -un
  fi
}

is_holder() {
  # $1=末条 entry $2=task $3=status → 0 当 task 是当前持有人（reserved/landed 同 task，或 contested 的 claimant）
  local entry="$1" task="$2" status="$3" holder c
  case "${status}" in
    reserved|landed)
      holder="$(task_of "${entry}")"
      [ -n "${holder}" ] && [ "${holder}" = "${task}" ] && return 0
      return 1
      ;;
    contested)
      for c in $(claimants_of "${entry}"); do
        [ "${c}" = "${task}" ] && return 0
      done
      return 1
      ;;
    *) return 1 ;;
  esac
}

holder_str() {
  # 持有人展示文本（list / 冲突详情用）
  local entry="$1" status="$2" c
  case "${status}" in
    reserved|landed) task_of "${entry}" ;;
    contested)
      c="$(claimants_of "${entry}" | tr '\n' ' ')"
      printf 'contested[%s]' "${c% }"
      ;;
  esac
}

ts_today() {
  date +%Y-%m-%d 2>/dev/null || printf '1970-01-01'
}

# ---- 账本追加（append-only：只 >> 新行，旧行逐字不动）----
append_rule_line() {
  # $1=rule $2=status $3=task_id $4=note $5=claimants(可空, 逗号分隔)
  local rule="$1" status="$2" task="$3" note="$4" claimants="$5"
  local ts; ts="$(ts_today)"
  if [ -n "${claimants}" ]; then
    local cj="[" first=1 c
    IFS=','
    for c in ${claimants}; do
      IFS=' '
      c="$(sanitize_task "${c}")"
      if [ "${first}" -eq 1 ]; then cj="${cj}\"${c}\""; first=0; else cj="${cj},${c}"; fi
      IFS=','
    done
    cj="${cj}]"
    IFS=' '
    printf '{"rule":%s,"status":"%s","claimants":%s,"ts":"%s","note":"%s"}\n' \
      "${rule}" "${status}" "${cj}" "${ts}" "$(json_escape "${note}")" >> "${LEDGER}"
  else
    printf '{"rule":%s,"status":"%s","task_id":"%s","ts":"%s","note":"%s"}\n' \
      "${rule}" "${status}" "$(sanitize_task "${task}")" "${ts}" "$(json_escape "${note}")" >> "${LEDGER}"
  fi
}

valid_int() {
  case "$1" in
    ''|*[!0-9]*) printf '[rule-reserve] 非法 rule 编号: %s\n' "$1" >&2; usage; exit 2 ;;
  esac
}

# ---- 六个命令 ----
do_reserve() {
  local N="" TASK="" NOTE=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --note) NOTE="${2:-}"; shift 2 || shift ;;
      -*) printf '[rule-reserve] 未知选项: %s\n' "$1" >&2; usage; exit 2 ;;
      *)
        if [ -z "${N}" ]; then N="$1"
        elif [ -z "${TASK}" ]; then TASK="$1"
        else printf '[rule-reserve] 多余位置参: %s\n' "$1" >&2; usage; exit 2
        fi
        shift ;;
    esac
  done
  valid_int "${N}"; [ -n "${TASK}" ] || { usage; exit 2; }

  local entry status holder detail
  entry="$(last_entry "${N}")"
  status=""
  [ -n "${entry}" ] && status="$(last_status "${N}")"
  case "${status}" in
    reserved|landed|contested)
      # 占位（含 contested 视为被占，D2 契约）
      if is_holder "${entry}" "${TASK}" "${status}"; then
        # 当前持有人重新登记 = 幂等追加一条 reserved（append-only 日志保留历史）
        append_rule_line "${N}" "reserved" "${TASK}" "${NOTE}" ""
        printf '[rule-reserve] rule %s reserved by %s (re-registered, was %s)\n' "${N}" "$(sanitize_task "${TASK}")" "${status}"
        exit 0
      fi
      holder="$(holder_str "${entry}" "${status}")"
      detail="${holder} (status=${status}, ts=$(ts_of "${entry}"))"
      printf '[rule-reserve] CONFLICT: rule %s 被持有: %s — 建议 `rule-reserve.sh next` 改号\n' "${N}" "${detail}" >&2
      exit 3
      ;;
    *)
      append_rule_line "${N}" "reserved" "${TASK}" "${NOTE}" ""
      printf '[rule-reserve] rule %s reserved by %s\n' "${N}" "$(sanitize_task "${TASK}")"
      exit 0
      ;;
  esac
}

do_check() {
  local N="${1:-}"
  valid_int "${N}"
  local entry status
  entry="$(last_entry "${N}")"
  status=""
  [ -n "${entry}" ] && status="$(last_status "${N}")"
  case "${status}" in
    reserved|landed|contested)
      # 被持有：持有人行 + exit 3（attest 挂点据此 WARN/STRICT）
      if [ "${status}" = "contested" ]; then
        printf 'rule %s contested: [%s]\n' "${N}" "$(holder_str "${entry}" "${status}")"
      else
        printf 'rule %s held by %s (%s)\n' "${N}" "$(task_of "${entry}")" "${status}"
      fi
      exit 3
      ;;
    *)
      printf 'free\n'
      exit 0
      ;;
  esac
}

do_next() {
  # 建议号 = > max(landed) 且跳过 occupied（reserved/landed/contested）占位
  local max_landed=0 occ="" r s m
  for r in $(rule_numbers); do
    s="$(last_status "${r}")"
    case "${s}" in
      landed) [ "${r}" -gt "${max_landed}" ] && max_landed="${r}" ;;
      reserved|landed|contested) occ="${occ} ${r}" ;;
    esac
  done
  local n=$((max_landed + 1))
  while :; do
    m=0
    for r in ${occ}; do
      [ "${r}" = "${n}" ] && { m=1; break; }
    done
    [ "${m}" -eq 1 ] && { n=$((n + 1)); continue; }
    break
  done
  printf '%s\n' "${n}"
  exit 0
}

do_list() {
  local printed=0 r entry status
  printf '%-6s  %-10s  %-28s  %s\n' "RULE" "STATUS" "HOLDER" "NOTE"
  for r in $(rule_numbers); do
    printed=1
    entry="$(last_entry "${r}")"
    status="$(last_status "${r}")"
    printf '%-6s  %-10s  %-28s  %s\n' "${r}" "${status}" "$(holder_str "${entry}" "${status}")" "$(note_of "${entry}")"
  done
  [ "${printed}" -eq 0 ] && printf '(no entries)\n'
  exit 0
}

do_land() {
  local N="${1:-}" TASK="${2:-}"
  valid_int "${N}"
  [ -n "${TASK}" ] || { usage; exit 2; }
  local entry status
  entry="$(last_entry "${N}")"
  status=""
  [ -n "${entry}" ] && status="$(last_status "${N}")"
  case "${status}" in
    reserved|landed|contested)
      if is_holder "${entry}" "${TASK}" "${status}"; then
        if [ "${status}" = "landed" ]; then
          printf '[rule-reserve] rule %s 已由 %s landed（幂等，不重复追加）\n' "${N}" "$(sanitize_task "${TASK}")"
          exit 0
        fi
        # 翻转：追加 landed 末条；contested 时即「置 landed 并清 claimants」（末条归并后占位消失，D2 契约）
        append_rule_line "${N}" "landed" "${TASK}" "" ""
        printf '[rule-reserve] rule %s landed by %s (was %s)\n' "${N}" "$(sanitize_task "${TASK}")" "${status}"
        exit 0
      fi
      ;;
  esac
  printf '[rule-reserve] DENIED: rule %s 非由 %s 持有（当前: %s / holder: %s）\n' \
    "${N}" "$(sanitize_task "${TASK}")" "${status:-none}" "$( [ -n "${entry}" ] && holder_str "${entry}" "${status:-}" || true )" >&2
  exit 4
}

do_release() {
  local N="" TASK="" NOTE=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --note) NOTE="${2:-}"; shift 2 || shift ;;
      -*) printf '[rule-reserve] 未知选项: %s\n' "$1" >&2; usage; exit 2 ;;
      *)
        if [ -z "${N}" ]; then N="$1"
        elif [ -z "${TASK}" ]; then TASK="$1"
        else printf '[rule-reserve] 多余位置参: %s\n' "$1" >&2; usage; exit 2
        fi
        shift ;;
    esac
  done
  valid_int "${N}"; [ -n "${TASK}" ] || { usage; exit 2; }
  local entry status
  entry="$(last_entry "${N}")"
  status=""
  [ -n "${entry}" ] && status="$(last_status "${N}")"
  case "${status}" in
    reserved)
      if is_holder "${entry}" "${TASK}" "${status}"; then
        append_rule_line "${N}" "abandoned" "${TASK}" "${NOTE}" ""
        printf '[rule-reserve] rule %s released by %s（abandoned，编号回池）\n' "${N}" "$(sanitize_task "${TASK}")"
        exit 0
      fi
      ;;
    contested)
      # D2：contested 的 release 需任一 claimant 且必须 --note 说明
      if ! is_holder "${entry}" "${TASK}" "${status}"; then
        printf '[rule-reserve] DENIED: rule %s contested 且 %s 不在 claimants\n' "${N}" "$(sanitize_task "${TASK}")" >&2
        exit 4
      fi
      if [ -z "${NOTE}" ]; then
        printf '[rule-reserve] DENIED: contested rule %s 的 release 必须附 --note 说明\n' "${N}" >&2
        exit 2
      fi
      append_rule_line "${N}" "abandoned" "${TASK}" "${NOTE}" ""
      printf '[rule-reserve] rule %s released by %s (contested, 已清占位)\n' "${N}" "$(sanitize_task "${TASK}")"
      exit 0
      ;;
  esac
  printf '[rule-reserve] DENIED: rule %s 非由 %s 持有（当前: %s）\n' \
    "${N}" "$(sanitize_task "${TASK}")" "${status:-none}" >&2
  exit 4
}

# ---- 主分发 ----
CMD="${1:-}"
[ $# -gt 0 ] && shift
case "${CMD}" in
  -h|--help) usage; exit 0 ;;
  "") usage; exit 2 ;;
  reserve|check|next|list|land|release) : ;;
  *) usage; exit 2 ;;
esac
resolve_ledger || exit 5
case "${CMD}" in
  reserve) do_reserve "$@" ;;
  check)   do_check "$@" ;;
  next)    do_next "$@" ;;
  list)    do_list "$@" ;;
  land)    do_land "$@" ;;
  release) do_release "$@" ;;
esac
