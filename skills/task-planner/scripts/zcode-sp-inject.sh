#!/usr/bin/env bash
# [2026-11-24 task-sp-driven-invocation H1] zcode-sp-inject.sh — ZCode SessionStart 技能入口注入
# What: 每次会话（含 clear/compact 触发的 SessionStart）注入一段固定文本，声明本会话以
#       using-superpowers 为技能入口；设计/头脑风暴用 brainstorming，规格/变更按需用 OpenSpec
#       命令；技能须被实际调用且留下承接物，不仅文本提及。
# Why: 方案 A 的 H1 缺口——原 SessionStart 只挂 zcode-sessionstart.sh（计划哨兵），全文无
#       SP/OS 注入；改由 SessionStart 事件强制注入，使「每次会话必触发」不依赖执行体记得调用。
# 契约: ZCode 对 hook stdout 做严格 JSON 校验，纯文本会被判失败；故输出与
#       zcode-sessionstart.sh:111 同构的单行 {"additionalContext": <jq -Rs 转义文本>}。
# 边界: 只读、幂等、无副作用；不读 stdin、不写文件、不跑重命令；fail-open 永远 exit 0。
#       与 zcode-sessionstart.sh 零耦合（独立脚本，互不调用、互不依赖其状态/哨兵）。
# 用法: bash zcode-sp-inject.sh [--dry-run|--help]；--dry-run 与无参输出一致（只读脚本仅显式表态）。
#       注入文本故意不含换行/双引号/反斜杠，jq 缺失时回退到直接包装仍为合法 JSON 字符串。

set -euo pipefail

case "${1:-}" in
  --help|-h)
    echo "Usage: bash zcode-sp-inject.sh [--dry-run]"
    echo "Emits a single-line SessionStart hook JSON with using-superpowers / brainstorming / OpenSpec injection."
    exit 0
    ;;
  --dry-run|'') : ;;
  *)
    printf '[sp-inject] warn: ignore unknown arg %s (fail-open)\n' "$1" >&2
    ;;
esac

# 固定注入文本：不含换行/双引号/反斜杠（jq 缺失回退时仍可安全包装为 JSON 字符串）。
inject='[skill-entry] 本会话以 using-superpowers 为技能入口：收到任务先扫描相关技能并通过 Skill 工具实际调用，不得仅在文本中提及。任务涉及设计、头脑风暴、方案选型时主动调用 brainstorming 技能，并产出选项/设计文档作为承接物；涉及规格、变更、需求规格化管理时按需调用 OpenSpec 命令（openspec propose / explore 等），并确保其产出物在计划或 actions 中有登记。判定标准：技能须被调用且有承接物，只文本提及不算。'

# jq 为既有依赖（zcode-sessionstart.sh 已用）；失败时回退直接包装，保证 stdout 恒为合法 JSON。
payload="$(printf '%s' "$inject" | jq -Rs . 2>/dev/null)" || payload=""
if [ -z "$payload" ]; then
  payload="\"$inject\""
fi

printf '{"additionalContext": %s}\n' "$payload"
exit 0
