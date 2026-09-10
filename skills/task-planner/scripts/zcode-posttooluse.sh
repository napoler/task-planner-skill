#!/usr/bin/env bash
# [2026-08-28] zcode-posttooluse.sh — PostToolUse 周期强制同步 hook（task-planner）
# 职责（对应「强制定期更新计划文件 + 原生 Todo 主动同步」）：
#   1. 按会话统计工具调用次数（状态文件 /tmp/task-planner-hook-<sid>.state）
#   2. 探测活跃计划：CWD/plans/*/task_plan.md 中 mtime 最新者（>24h 未更新视为历史遗留，静默）
#   0. 已完结计划（task_plan.md 含 outcome: COMPLETE/BLOCKED）→ 直接静默（防误报）
#   3. 计划文档超龄（config#plan_update_interval_minutes，默认 15 分钟）且不在冷却期 → 注入强制回写提醒，
#      随后进入 config#stale_remind_cooldown_calls（默认 10 次调用）冷却，防止未修复时每次调用重复轰炸
#   3b. [2026-09-05 Rule 19.7 升级] findings/progress 连续 compass_escalate_after 次（默认 2）提醒仍无回填
#       → emit 升级警告替代常规提醒（升级后重置连续计数，防止每轮刷屏；冷却逻辑不变）
#   4. 计数达到 config#todo_sync_interval_calls（默认 10）→ 注入轻量 Todo 同步提醒，计数清零
# 约束：fail-open —— 任何异常一律 exit 0 不阻塞工具调用；
#       ZCode 对 hook stdout 做严格 JSON 校验，有提醒时包装为 {"additionalContext": ...}（与
#       zcode-sessionstart.sh 同一约定），无提醒时输出空。

input="$(cat)"

CWD="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
CWD="${CWD:-$PWD}"
SID="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null | tr -cd 'a-zA-Z0-9' | head -c 40)"
SID="${SID:-default}"

# ─── 探测活跃计划（无则零开销静默退出）───────────────────────────────────────
plan=""
if [ -d "$CWD/plans" ]; then
  plan="$(ls -t "$CWD"/plans/*/task_plan.md 2>/dev/null | head -1)"
fi
# [2026-09-05 task-active-plan] 指针优先(resolve-plan-dir.sh:.active_plan→mtime→legacy)
RESOLVER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/resolve-plan-dir.sh"
# [2026-09-10 active-plan-race] 带会话 sid 二参 → .active_plan_side/<sid>.active_plan 优先,
# 并行会话各自解析本会话的计划,不再被全局 legacy 指针互顶
[ -f "$RESOLVER" ] && plan="$(bash "$RESOLVER" "$CWD" "$SID" 2>/dev/null || true)"
[ -z "$plan" ] && exit 0

now="$(date +%s)"
mt="$(stat -c %Y "$plan" 2>/dev/null || echo "$now")"
age=$(( now - mt ))
[ "$age" -gt 86400 ] && exit 0   # >24h 未更新 = 历史任务，不打扰

# ─── 完结计划静默（[2026-08-28] 防误报:outcome 已定局的任务不再催）────────────
if grep -qiE 'outcome: *(COMPLETE|BLOCKED)' "$plan" 2>/dev/null; then
  exit 0
fi

# ─── 读阈值（config.json；解析失败兜底默认值，保证 fail-open）────────────────
SKILL_ROOT="${OPENCODE_SKILL_ROOT:-$HOME/.zcode/skills/task-planner}"
todo_n="$(jq -r '.properties.todo_sync_interval_calls.default // 10' "$SKILL_ROOT/config.json" 2>/dev/null || true)"
plan_min="$(jq -r '.properties.plan_update_interval_minutes.default // 15' "$SKILL_ROOT/config.json" 2>/dev/null || true)"
cooldown="$(jq -r '.properties.stale_remind_cooldown_calls.default // 10' "$SKILL_ROOT/config.json" 2>/dev/null || true)"
# [2026-09-04 Rule 19.7] 新增 findings/progress 陈旧阈值；解析失败兜底默认。
findings_n="$(jq -r '.properties.findings_stale_minutes.default // 20' "$SKILL_ROOT/config.json" 2>/dev/null || true)"
progress_n="$(jq -r '.properties.progress_stale_minutes.default // 25' "$SKILL_ROOT/config.json" 2>/dev/null || true)"
# [2026-09-05 Rule 19.7 升级] 连续无响应提醒达 compass_escalate_after 次 → 升级警告；解析失败兜底默认 2。
esc_after="$(jq -r '.properties.compass_escalate_after.default // 2' "$SKILL_ROOT/config.json" 2>/dev/null || true)"
case "$todo_n" in ''|*[!0-9]*) todo_n=10 ;; esac
case "$plan_min" in ''|*[!0-9]*) plan_min=15 ;; esac
case "$cooldown" in ''|*[!0-9]*) cooldown=10 ;; esac
case "$findings_n" in ''|*[!0-9]*) findings_n=20 ;; esac
case "$progress_n" in ''|*[!0-9]*) progress_n=25 ;; esac
case "$esc_after" in ''|*[!0-9]*) esc_after=2 ;; esac

# ─── 会话级计数 + 冷却 + 升级链路 ───
# [2026-09-04 Rule 19.7] 状态格式扩展为 5 字段: <count> <epoch> <cd_plan> <cd_findings> <cd_progress>
# [2026-09-05 Rule 19.7 升级] 扩展为 9 字段，追加:
#   f_last / p_last = findings/progress 上次提醒时间戳（0 = 从未提醒过）
#   f_miss / p_miss = findings/progress 连续"提醒后无回填"次数
# 旧 5 字段文件第 6-9 字段缺失兜底 0（向后兼容）。
state="/tmp/task-planner-hook-${SID}.state"
count="$(cut -d' ' -f1 "$state" 2>/dev/null || true)"
cd_left="$(cut -d' ' -f3 "$state" 2>/dev/null || true)"
cd_findings="$(cut -d' ' -f4 "$state" 2>/dev/null || true)"
cd_progress="$(cut -d' ' -f5 "$state" 2>/dev/null || true)"
f_last="$(cut -d' ' -f6 "$state" 2>/dev/null || true)"
p_last="$(cut -d' ' -f7 "$state" 2>/dev/null || true)"
f_miss="$(cut -d' ' -f8 "$state" 2>/dev/null || true)"
p_miss="$(cut -d' ' -f9 "$state" 2>/dev/null || true)"
case "$count" in ''|*[!0-9]*) count=0 ;; esac
case "$cd_left" in ''|*[!0-9]*) cd_left=0 ;; esac
case "$cd_findings" in ''|*[!0-9]*) cd_findings=0 ;; esac
case "$cd_progress" in ''|*[!0-9]*) cd_progress=0 ;; esac
case "$f_last" in ''|*[!0-9]*) f_last=0 ;; esac
case "$p_last" in ''|*[!0-9]*) p_last=0 ;; esac
case "$f_miss" in ''|*[!0-9]*) f_miss=0 ;; esac
case "$p_miss" in ''|*[!0-9]*) p_miss=0 ;; esac
count=$(( count + 1 ))
[ "$cd_left" -gt 0 ] && cd_left=$(( cd_left - 1 ))
[ "$cd_findings" -gt 0 ] && cd_findings=$(( cd_findings - 1 ))
[ "$cd_progress" -gt 0 ] && cd_progress=$(( cd_progress - 1 ))

emit() {
  printf '{"additionalContext": %s}\n' "$(printf '%s' "$1" | jq -Rs .)"
}

# ─── 优先级 1：计划文档陈旧且不在冷却期 → 强制回写，随后进入冷却 ─────────────
# [2026-09-04 Rule 19.6/19.7] 提醒文案改为三文件分流版本，治理"一切塞 task_plan"。
age_min=$(( age / 60 ))
if [ "$age" -ge "$(( plan_min * 60 ))" ] && [ "$cd_left" -eq 0 ]; then
  echo "0 $(date +%s) $cooldown $cd_findings $cd_progress $f_last $p_last $f_miss $p_miss" > "$state"
  emit "[plan-sync] ⏰ 计划文档已 ${age_min} 分钟未更新（阈值 ${plan_min} 分钟）: ${plan}
回写分流（Rule 19.6/19.7，三文件各归其位）:
1. Edit task_plan.md 只回写状态与指针（Phase checkbox/Status/Errors 一行摘要）
2. 调研与结论 → findings.md；动作与测试 → progress.md（细节禁止塞进 task_plan.md）
3. TodoWrite / TaskUpdate 同步原生 Todo + bash ${SKILL_ROOT}/scripts/sync-todos.sh --index"
  exit 0
fi

# [2026-09-04 Rule 19.7] findings.md / progress.md 路径 = 活跃 plan 同目录同名文件
plan_dir="$(dirname "$plan")"
findings_file="${plan_dir}/findings.md"
progress_file="${plan_dir}/progress.md"

# ─── 优先级 2：findings.md 陈旧且不在冷却期 → 提醒回写调研结论，随后进入冷却 ──
f_mt="$(stat -c %Y "$findings_file" 2>/dev/null || true)"
if [ -n "$f_mt" ]; then
  f_age_min=$(( (now - f_mt) / 60 ))
  if [ "$(( now - f_mt ))" -ge "$(( findings_n * 60 ))" ] && [ "$cd_findings" -eq 0 ]; then
    # [2026-09-05 Rule 19.7 升级] 上次提醒时间戳之后文件从未更新（mtime 早于 f_last）→ 连续无响应 +1；
    # 否则说明已回填过，重开计数链。达 compass_escalate_after 次 → 升级警告替代常规提醒。
    if [ "$f_last" -gt 0 ] && [ "$f_mt" -lt "$f_last" ]; then
      f_miss=$(( f_miss + 1 ))
    else
      f_miss=1
    fi
    f_last="$(date +%s)"
    if [ "$f_miss" -ge "$esc_after" ]; then
      esc_n="$f_miss"
      f_miss=0   # 升级后重置连续计数，避免每轮都升级刷屏（冷却逻辑不变）
      echo "0 $(date +%s) $cd_left $cooldown $cd_progress $f_last $p_last $f_miss $p_miss" > "$state"
      emit "[plan-compass] 🚨 升级警告：findings.md 已连续 ${esc_n} 次提醒未回填 — 违反 Rule 19.7（及时回填）
处置：按 Rule 26.3 本违规登记 progress.md Error Log，终验 outcome 最高 PARTIAL。
立即把近 2 次查看/搜索/子代理返回的结论 Edit 进 ${findings_file} 对应段落，再继续。"
      exit 0
    fi
    echo "0 $(date +%s) $cd_left $cooldown $cd_progress $f_last $p_last $f_miss $p_miss" > "$state"
    emit "[plan-compass] 🧭 findings.md 已 ${f_age_min} 分钟未更新（阈值 ${findings_n}）: ${findings_file}
2-Action Rule（Rule 3/19.7）：把最近 2 次查看/搜索/子代理返回的结论摘要+证据路径 Edit 进 findings.md 对应段落，再继续。"
    exit 0
  fi
fi

# ─── 优先级 3：progress.md 陈旧且不在冷却期 → 提醒留痕动作，随后进入冷却 ──────
p_mt="$(stat -c %Y "$progress_file" 2>/dev/null || true)"
if [ -n "$p_mt" ]; then
  p_age_min=$(( (now - p_mt) / 60 ))
  if [ "$(( now - p_mt ))" -ge "$(( progress_n * 60 ))" ] && [ "$cd_progress" -eq 0 ]; then
    # [2026-09-05 Rule 19.7 升级] 与 findings 链路对称：mtime 早于 p_last = 上次提醒后无留痕 → 连续 +1
    if [ "$p_last" -gt 0 ] && [ "$p_mt" -lt "$p_last" ]; then
      p_miss=$(( p_miss + 1 ))
    else
      p_miss=1
    fi
    p_last="$(date +%s)"
    if [ "$p_miss" -ge "$esc_after" ]; then
      esc_n="$p_miss"
      p_miss=0   # 升级后重置连续计数，避免每轮都升级刷屏（冷却逻辑不变）
      echo "0 $(date +%s) $cd_left $cd_findings $cooldown $f_last $p_last $f_miss $p_miss" > "$state"
      emit "[plan-compass] 🚨 升级警告：progress.md 已连续 ${esc_n} 次提醒未回填 — 违反 Rule 19.7（及时回填）
处置：按 Rule 26.3 本违规登记 progress.md Error Log，终验 outcome 最高 PARTIAL。
立即把近 2 次查看/搜索/子代理返回的结论 Edit 进 ${progress_file} 对应段落，再继续。"
      exit 0
    fi
    echo "0 $(date +%s) $cd_left $cd_findings $cooldown $f_last $p_last $f_miss $p_miss" > "$state"
    emit "[plan-compass] 🧭 progress.md 已 ${p_age_min} 分钟未更新（阈值 ${progress_n}）: ${progress_file}
动作留痕（Rule 19.2/19.7）：把关键动作/文件变更/测试结果/错误 Edit 进 progress.md 当前 Phase 段，再继续。"
    exit 0
  fi
fi

# ─── 优先级 4：调用次数达阈值 → 轻量 Todo 同步提醒 ───────────────────────────
if [ "$count" -ge "$todo_n" ]; then
  echo "0 $(date +%s) $cd_left $cd_findings $cd_progress $f_last $p_last $f_miss $p_miss" > "$state"
  emit "[plan-sync] 🔄 已 ${count} 次工具调用未同步：核对 ${plan} 的 Phase 状态，并用 TodoWrite/TaskUpdate 同步原生 Todo（S2/S3）。"
  exit 0
fi

# 未命中任何提醒 → 9 字段原样写回 state
echo "$count $(date +%s) $cd_left $cd_findings $cd_progress $f_last $p_last $f_miss $p_miss" > "$state"
exit 0
