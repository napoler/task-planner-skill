#!/usr/bin/env bash
# agent-failure-ledger.sh — Agent 调用失败会话级台账（task-agent-failure-ledger-20261123）
#
# What: 主进程每次 Agent() 返回失败时，把 {时间/agentType/失败原因} 追加到本任务会话级文件
#       <plan-dir>/.agent-failures/<sid>.jsonl；交付总结时 list 出来提示用户审查。
# Why:  用户 2026-11-23 裁决——失败不该"淹没在会话中"，也不该写 memory（agent 修好后
#       memory 不更新会误报）。会话级 ledger 随任务结束即弃，只记客观失败事实、不写"该 agent
#       有缺陷"这类会过期的判断，从根本上避免 memory 陈旧误报。
# 约束: 零机器门（不阻断任何流程）、零 hook（引擎无 Stop/带结果的 PostToolUse，不可用 hook 实现）、
#       fail-open（任何异常 exit 0）、append-only（历史条目零改写）。仅主进程显式调用时写。
#
# 用法:
#   agent-failure-ledger.sh append <plan-dir> <sid> <agentType> <reason>   # 追加一条失败
#   agent-failure-ledger.sh list   <plan-dir> <sid>                        # 列出本会话失败(jsonl)
#   agent-failure-ledger.sh count  <plan-dir> <sid>                        # 只输出失败条数(整数)
#   agent-failure-ledger.sh clear  <plan-dir> <sid>                        # 清本会话台账(归档时)

set -u
cmd="${1:-}"
plan_dir="${2:-}"
sid="${3:-}"

# sid 归一：只留安全字符，防路径穿越
sid="$(printf '%s' "$sid" | tr -cd 'a-zA-Z0-9_-' | head -c 64)"
[ -z "$sid" ] && sid="default"

ledger_dir="${plan_dir}/.agent-failures"
ledger_file="${ledger_dir}/${sid}.jsonl"

case "$cmd" in
  append)
    agent_type="${4:-unknown}"
    reason="${5:-}"
    [ -z "$plan_dir" ] && exit 0
    mkdir -p "$ledger_dir" 2>/dev/null || exit 0
    ts="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || printf 'unknown')"
    # jq 可用则结构化转义；否则退化为朴素拼接（仍为单行，不破坏 jsonl 行结构）
    if command -v jq >/dev/null 2>&1; then
      printf '%s\n' "$(jq -nc --arg t "$ts" --arg a "$agent_type" --arg r "$reason" \
        '{ts:$t,agentType:$a,reason:$r}')" >> "$ledger_file" 2>/dev/null || exit 0
    else
      esc="$(printf '%s' "$reason" | tr '\n' ' ' | tr -d '\r')"
      printf '{"ts":"%s","agentType":"%s","reason":"%s"}\n' "$ts" "$agent_type" "$esc" >> "$ledger_file" 2>/dev/null || exit 0
    fi
    ;;
  list)
    [ -f "$ledger_file" ] && cat "$ledger_file" 2>/dev/null || true
    ;;
  count)
    if [ -f "$ledger_file" ]; then
      wc -l < "$ledger_file" 2>/dev/null | tr -d ' '
    else
      printf '0'
    fi
    ;;
  clear)
    rm -f "$ledger_file" 2>/dev/null || true
    ;;
  *)
    printf 'usage: %s {append|list|count|clear} <plan-dir> <sid> [agentType] [reason]\n' "$0" >&2
    exit 0
    ;;
esac
exit 0
