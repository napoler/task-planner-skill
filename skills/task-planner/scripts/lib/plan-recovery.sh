#!/usr/bin/env bash
# [2026-11-24 task-session-regression-20261124] plan-recovery.sh — 压缩恢复用的在途计划磁盘读取库
# What: 提供 mustkeep / inflight / recover 三个函数（可被 source，也可 `bash <file> <cmd>` 直接调用）
# Why: 上下文压缩后 SKILL.md 正文不在上下文，「先读计划」文字规则失效；实证某会话压缩后 6 分钟
#       未读计划专档并误删既有设定事实。本库把「在途判定 + 必读清单 + 必保项」固化为磁盘权威源，
#       供 SessionStart hook 与 git-baseline.sh 共用，避免两处各自复制语义走样。
# 约定: 不设 set -e/-u（source 侧可能已有）；jq 缺失 → stderr 一行 DEGRADED=no-jq + rc 2（调用方 fail-open）。

# mustkeep <plan-dir> — 打印 spec_baseline 中 id 以 MK 开头的条目
# 输出 TSV: id<TAB>verbatim<TAB>target<TAB>anchor（rule 形如 target=<path>|fixed-string|retain）
# 无条目或 plan-state.json 不存在 → 空输出 rc 0
mustkeep() {
  local plan_dir="${1:-}"
  [ -f "$plan_dir/plan-state.json" ] || return 0
  if ! command -v jq >/dev/null 2>&1; then
    printf 'DEGRADED=no-jq\n' >&2
    return 2
  fi
  jq -r '
    def txt($v): if $v == null then "" elif ($v | type) == "string" then $v else ($v | tostring) end;
    if ((.spec_baseline // []) | type) != "array" then empty
    else
      .spec_baseline[]
      | select((txt(.id)) | startswith("MK"))
      | [ txt(.id), txt(.verbatim),
          (txt(.rule) | split("|")[0] | sub("^target="; "")),
          txt(.anchor) ] | @tsv
    end
  ' "$plan_dir/plan-state.json" 2>/dev/null
}

# inflight <root> <sid> — 判定「本会话 side 指针指向的计划」是否在途
# sidkey 规范与 plan-created.cjs 的 normSidkey 一致：剥非字母数字→前 40 字符→剥开头 sess
# 在途 → stdout 打印计划目录绝对路径 rc 0；否则无输出 rc 1
# 刻意不看指针 mtime/TTL，也绝不做「最近改动的计划」兜底：那会把别的会话的计划塞进本会话恢复包
inflight() {
  local root="${1:-}" sid="${2:-}"
  [ -n "$root" ] && [ -n "$sid" ] || return 1
  local sidkey
  sidkey="$(printf '%s' "$sid" | tr -cd 'a-zA-Z0-9' | head -c 40)"
  sidkey="${sidkey#sess}"
  [ -n "$sidkey" ] || return 1
  local ptr="$root/plans/.active_plan_side/${sidkey}.active_plan"
  [ -f "$ptr" ] || return 1
  local pid
  pid="$(tr -d '[:space:]' < "$ptr" 2>/dev/null)"
  [ -n "$pid" ] || return 1
  # 拒路径穿越 / 隐藏目录，指针腐烂即视为无在途计划
  case "$pid" in */*|.*|*..*) return 1 ;; esac
  local plan_dir="$root/plans/$pid"
  [ -f "$plan_dir/task_plan.md" ] || return 1
  # 终态只认真实声明 `outcome: COMPLETE`；模板示例 `outcome: **COMPLETE**` 不算（星号隔开）
  if grep -Eq 'outcome:[[:space:]]*(COMPLETE|BLOCKED)([^[:alnum:]_]|$)' "$plan_dir/task_plan.md" 2>/dev/null; then
    return 1
  fi
  # 状态控制行锚定，兼容 `- **Status:** in_progress` 与裸 `Status: in_progress`；散文/注释中的字样不命中
  if grep -Eq '^[[:space:]]*([-*][[:space:]]*)?\*{0,2}Status\*{0,2}[[:space:]]*[:：]\*{0,2}[[:space:]]*(in_progress|pending)([^[:alnum:]_]|$)' "$plan_dir/task_plan.md" 2>/dev/null; then
    (cd "$plan_dir" && pwd)
    return 0
  fi
  return 1
}

# recover <plan-dir> [maxlines=80] — 打印恢复包；全文另写 <plan-dir>/.compact-recovery.md
# What: 首行标记 + 必读文件绝对路径（按序）+ 必保清单 + Goal / Current Phase / Next Step / Decisions
# Why: 压缩摘要会丢细节，必须强制重读磁盘专档；字段缺失写 `-`，不编造，确保恢复包可机器核对
recover() {
  local plan_dir="${1:-}"
  local maxlines="${2:-80}"
  [ -f "$plan_dir/task_plan.md" ] || return 1
  if ! command -v jq >/dev/null 2>&1; then
    printf 'DEGRADED=no-jq\n' >&2
    return 2
  fi
  case "$maxlines" in ''|*[!0-9]*) maxlines=80 ;; esac
  [ "$maxlines" -ge 2 ] || maxlines=80

  local state="$plan_dir/plan-state.json"
  local id
  id="$(basename "$plan_dir")"

  # goal 字段兼容真实结构 goals[] 与历史 goal 字符串/数组
  local goal
  goal="$(jq -r '
    def flat:
      if . == null then "-"
      elif type == "string" then (if length == 0 then "-" else . end)
      elif type == "array" then
        (map(if type == "object" then (.goal // .text // .name // .id // "") else tostring end)
         | join(" / "))
      elif type == "object" then (.goal // .text // .name // "-")
      else tostring end;
    (if has("goal") then .goal else (.goals // null) end) | flat
  ' "$state" 2>/dev/null)"
  [ -n "$goal" ] || goal="-"

  # 第一个 in_progress 的 Phase 取自 plan-state.json；缺栏时回读 task_plan.md 的 Phase 状态控制行
  local phase
  phase="$(jq -r '
    def nm: if type == "object" then (.name // .phase // .id // .title // "-") else tostring end;
    ([.phases[]? | select((.status // .state // "") == "in_progress")] | .[0]) as $p
    | if $p == null then "-" else ($p | nm) end
  ' "$state" 2>/dev/null)"
  [ -n "$phase" ] || phase="-"
  if [ "$phase" = "-" ]; then
    phase="$(awk '
      /^### Phase/ { ph = $0; sub(/^###[[:space:]]*/, "", ph); inph = 1; next }
      /^## / { inph = 0 }
      inph && /^[[:space:]]*([-*][[:space:]]*)?\*{0,2}Status\*{0,2}[[:space:]]*[:：]\*{0,2}[[:space:]]*in_progress/ { print ph; exit }
    ' "$plan_dir/task_plan.md" 2>/dev/null)"
    [ -n "$phase" ] || phase="-"
  fi

  local next_step
  next_step="$(jq -r '
    def flat:
      if . == null then "-"
      elif type == "string" then (if length == 0 then "-" else . end)
      elif type == "object" then (.text // .action // .step // .next // "-")
      else tostring end;
    (.next_step // .next // null) | flat
  ' "$state" 2>/dev/null)"
  [ -n "$next_step" ] || next_step="-"

  local decisions
  decisions="$(jq -r '
    def flat: if type == "object" then (.decision // .text // .summary // .id // tostring) else tostring end;
    (.decisions // .decisions_made // []) as $d
    | if ($d | type) == "array" then
        if ($d | length) == 0 then "-" else ($d[0:30][] | flat) end
      else ($d | flat) end
  ' "$state" 2>/dev/null)"
  [ -n "$decisions" ] || decisions="-"

  local full
  full="$({
    printf '[compact-recovery] 上下文恢复包（检测到在途计划 %s；数据来自磁盘，非会话记忆。摘要可能丢细节，以下列文件为准）\n' "$id"
    printf '必读（按序，绝对路径）:\n'
    printf '1. %s/user-session-log.md（全文）\n' "$plan_dir"
    printf '2. %s/task_plan.md（用户需求原文 / 🔒 规范基线(MK) / 变更标注表 / 验收契约）\n' "$plan_dir"
    printf '3. %s/findings.md（结论）\n' "$plan_dir"
    printf '4. %s/knowledge-brief.md（易错点）\n' "$plan_dir"
    printf '5. %s/.git-baseline-report.md（未处置偏移，若存在）\n' "$plan_dir"
    printf '必保清单:\n'
    local mk
    mk="$(mustkeep "$plan_dir")"
    if [ -n "$mk" ]; then
      printf '%s\n' "$mk" | awk -F '\t' '{ printf "%s | %s | target=%s | 真源=%s\n", $1, $2, $3, $4 }'
    else
      printf '必保清单=缺失（存量计划，非阻断提示）\n'
    fi
    printf 'Goal: %s\n' "$goal"
    printf 'Current Phase: %s\n' "$phase"
    printf 'Next Step: %s\n' "$next_step"
    printf 'Decisions（全部，一行一条）:\n'
    printf '%s\n' "$decisions"
  })"

  # 全文落盘供截断后追读；写入失败 fail-open，不影响恢复包输出
  printf '%s\n' "$full" > "$plan_dir/.compact-recovery.md" 2>/dev/null || :

  local total
  total="$(printf '%s\n' "$full" | wc -l)"
  if [ "$total" -gt "$maxlines" ]; then
    printf '%s\n' "$full" | head -n "$((maxlines - 1))"
    printf '…已截断（上限 %s 行）；全文见 %s/.compact-recovery.md\n' "$maxlines" "$plan_dir"
  else
    printf '%s\n' "$full"
  fi
}

# 直接执行分发（被 source 时不触发，供 hook / git-baseline.sh 以 `bash <file> <cmd>` 调用）
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  case "${1:-}" in
    mustkeep) mustkeep "${2:-}" ;;
    inflight) inflight "${2:-}" "${3:-}" ;;
    recover)  recover "${2:-}" "${3:-80}" ;;
    *) printf 'usage: plan-recovery.sh {mustkeep|inflight|recover} <args...>\n' >&2; exit 2 ;;
  esac
fi
