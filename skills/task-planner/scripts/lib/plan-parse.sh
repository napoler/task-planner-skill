#!/usr/bin/env bash
# [2026-09-27 task-v091 C-1c] plan-parse.sh — task-planner 计划文件解析公共库
#
# 目的: 统一「执行范围限制」scope 提取语义, 消除多处内联复制的语义漂移
# (先例: pretooluse 提取正则曾因复制走样恒空, S15/C-1a② 已修; 本库把修好后的
# 语义固化为唯一权威源, 后续调用方一律接入而非再复制)。
#
# 调用方(语义同步义务——改本库语义必须逐处核对并同步):
#   1. scripts/check-conflicts.sh — plan_scopes 与 current_scope 两处(task-v091 S16 已接入)
#   2. scripts/sync-todos.sh extract_plan_meta — 仍内联旧形态, task-v091 S17 接入
#   3. scripts/zcode-pretooluse.sh Rule 23 扫描 — 热路径保留 S15 内联单 awk 不 source 本库
#      (每计划 1 fork 是 C-1a③ 性能成果); 与本库互为语义锚, 任一处语义变更必须同步另一处
#   未纳入: scripts/check-drift.sh:205 另有独立旧形态(严格 ⚠️ 区间形), 待后续组统一
#
# 本文件仅被 source, 不直接执行(无 main 逻辑; source 侧须已 set -u 兼容)。

# plan_parse_scope <task_plan.md> — 提取 scope 条目, 一行一条打印到 stdout
# 语义权威源(2026-09-27 task-v091 C-1c 定格, 同 zcode-pretooluse.sh Rule23 注释锚):
#   - 区间: 「## …执行范围限制」标题(宽松匹配, 含/不含 ⚠️ 均命中——修复 v090 类表头
#     无 emoji 时旧严格形提取恒空的盲区)到下一个「## 」标题前
#   - 行:   仅表格行(行首 |), 排除 |--- 分隔行
#   - 条目: 第 3+ 字段(-F'|' 语义, 跳过序号/类别列)中含点分路径(/\.[a-zA-Z]/)的单元格,
#     去首尾空白后**整格**输出; 不做逗号拆分({a.sh,b.sh} 括号清单与带注 prose 均为一条,
#     对齐 pretooluse 子串匹配语义); 无点分内容(纯目录路径/中文描述/表头)自然滤除
#   - 文件不存在/无该区块: 输出空且 rc=0(fail-open)
# 实现注: 单 awk 等价「grep '^|' | grep -v '^|---' | awk -F'|' 点分过滤 | sed trim」
#   四级管线(2026-09-27 本仓 37 计划逐一对拍 byte-identical); 少 fork 供每用户消息
#   周期调用 check-conflicts --runtime 的 zcode-userpromptsubmit.sh 路径。
plan_parse_scope() {
  local plan="$1"
  [ -f "$plan" ] || return 0
  awk '
    /^## .*执行范围限制/ { inscope = 1; next }
    /^## /                { inscope = 0 }
    inscope && /^\|/ && !/^\|---/ {
      n = split($0, c, "|")
      for (i = 3; i <= n; i++) {
        s = c[i]
        gsub(/^[[:space:]]+/, "", s)
        gsub(/[[:space:]]+$/, "", s)
        if (s ~ /\.[a-zA-Z]/) print s
      }
    }
  ' "$plan" 2>/dev/null
}
