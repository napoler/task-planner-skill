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

# ─── [task-v061-serial-dispatch] 串行槽清锁(Rule 21.4 配对): Agent 返回即释放串行槽 ─────
# 触发: 工具=Agent; 动作: 复用 resolve-plan-dir.sh 解析链 → rm <plan-dir>/subagent-state/.dispatch-inflight
# fail-open: 解析失败/文件不存在 → 静默跳过(无 stdout 输出), 不阻塞后续逻辑
tool="$(printf '%s' "$input" | jq -r '.tool_name // .toolName // empty' 2>/dev/null)"
if [ "$tool" = "Agent" ]; then
  RESOLVER_C="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/resolve-plan-dir.sh"
  if [ -f "$RESOLVER_C" ]; then
    pc="$(bash "$RESOLVER_C" "$CWD" "$SID" 2>/dev/null || true)"
    [ -n "$pc" ] && rm -f "$(dirname "$pc")/subagent-state/.dispatch-inflight" 2>/dev/null || true
  fi
fi
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

# ─── [task-v148 Rule 64.3] [drift-rhythm] 节奏化偏移检查提醒 ──────────────────
# What: 活跃计划存在时维护会话级计数状态 <plans>/.drift-rhythm/<sidkey>.state
#       （三键 count/last_inject/due），每满 N 次工具调用（默认 10，env
#       TASK_PLANNER_DRIFT_RHYTHM_N 可覆盖）标记 due=1，由主流程末尾 end-emit
#       统一注入单行偏移检查提醒，并重置计数锚点（last_inject=count）与清 due。
#       due 位跨分支命中轮持久保留（N1 修复），由下一个无分支调用轮投递。
# Why: 用户 2026-10-08 反馈「防偏移容易失效，需要时刻记得纠正」；task-v141~v145
#      共 25 Phase drift-check 执行率 0%（软触发不可靠实证）。64.3 管「时刻」
#      （高频可见性），拦截力由 64.2 Phase complete 硬门控承载——两层分工。
# 容错: 缺文件/坏行按 0 处理；mkdir -p 幂等初始化；O(1) 状态读写，禁全仓扫描。
# fail-open: plan-dir 解析失败/目录不可写/无 jq → 全段静默跳过（零 stdout——平台对
#       hook stdout 做严格 JSON 校验，杂输出会污染所有会话的 hook 链）。
# [F5 前移] 函数定义与调用点均置于 plan 解析成功后、任何早退之前，确保优先级 1-4
# 命中 exit 0 时 drift 计数仍自增。函数体零改动，仅移动位置。
emit() {
  printf '{"additionalContext": %s}\n' "$(printf '%s' "$1" | jq -Rs .)"
}

drift_rhythm_check() {
  local plan_dir="$1" sid="$2"
  local n="${TASK_PLANNER_DRIFT_RHYTHM_N:-10}"
  case "$n" in ''|*[!0-9]*) n=10 ;; esac
  # fail-open 前置：目录必须存在且可写
  [ -d "$plan_dir" ] && [ -w "$plan_dir" ] || return 0
  # 无 jq → 静默跳过（emit 依赖 jq -Rs 包装 JSON 字符串）
  command -v jq >/dev/null 2>&1 || return 0
  local sdir="$(dirname "$plan_dir")/.drift-rhythm"
  mkdir -p "$sdir" 2>/dev/null || return 0
  local sfile="$sdir/${sid}.state"
  # 容错解析：缺文件/坏行按 0 处理
  local count=0 last_inject=0 v
  v="$(sed -n 's/^count[[:space:]]\{1,\}//p' "$sfile" 2>/dev/null | head -1)"
  case "$v" in ''|*[!0-9]*) ;; *) count="$v" ;; esac
  v="$(sed -n 's/^last_inject[[:space:]]\{1,\}//p' "$sfile" 2>/dev/null | head -1)"
  case "$v" in ''|*[!0-9]*) ;; *) last_inject="$v" ;; esac
  # [task-v148 Rule 64.3 N1 修复] 读回既有 due 位（读-改-写，防 clobber）
  # What: 早调用写 state 前先读回上一轮遗留的 due 位；阈值命中轮置 1，未命中轮原样保留。
  # Why: N1 投递饥饿——优先级 1-4 命中即 exit 0，永远到不了主流程末尾 end-emit，该轮
  #      due=1 残留；旧 else 分支无脑写 due 0 把残留位 clobber 掉，当 rhythm N 与
  #      todo_sync 周期相位锁定（默认均 10）时提醒永不投递（实测 30 调用 0 投递）。
  #      保留 due 后：分支命中轮 due 留存，下一（或下几个）无分支调用轮的 end-emit
  #      投递并清零——延迟数调用而非饥饿，分支消息零改动零吞没。
  # 容错: 三键 state {count, last_inject, due}（due=待投递持久位；缺 due 的旧 state）或坏行 → due 按 0 处理（向后兼容）。
  # Rule 64.3 + Rule 45（What+Why）
  local due=0 vdue
  vdue="$(sed -n 's/^due[[:space:]]\{1,\}//p' "$sfile" 2>/dev/null | head -1)"
  case "$vdue" in ''|*[!0-9]*) ;; *) due="$vdue" ;; esac
  count=$(( count + 1 ))
  # 第三键 due：0=无待注入，1=阈值命中待注入（end-emit 处统一 emit）
  # 写回 count（未触发时也写回，保持状态一致）；未达阈值时保留既有 due 不 clobber
  if [ "$(( count - last_inject ))" -ge "$n" ]; then
    printf 'count %s\nlast_inject %s\ndue 1\n' "$count" "$count" > "$sfile" 2>/dev/null || true
  else
    printf 'count %s\nlast_inject %s\ndue %s\n' "$count" "$last_inject" "$due" > "$sfile" 2>/dev/null || return 0
  fi
  return 0
}

# [task-v148 Rule 64.3] [drift-rhythm] 节奏提醒前移（F5）：置于 plan 解析成功后、
# 任何早退之前，确保优先级 1-4 命中 exit 0 时 drift 计数仍自增。
# fail-open：解析失败/目录不可写/无 jq → 全段静默跳过（零 stdout）。
drift_rhythm_check "$(dirname "$plan")" "$SID"

# ─── [task-v068 E2] TAMPERED 自愈: 本会话 Edit/Write 活跃计划 task_plan.md → 后台自动重锁 ───
# 触发(全部满足,廉价前置短路,未命中零子进程): tool ∈ {Write,Edit,MultiEdit}
#  且 .tool_input.file_path 归一后 == 本会话活跃计划 plan(上述探测结果)
#  且 <plan-dir>/.session-owner == 本会话 SID(归一口径与 L20 一致)——owner 缺失/他会话维持 TAMPERED
# 动作: 后台 attest-plan.sh <plan> --skip-dispatch-check(静默,失败不阻塞;重锁成功无输出)
#       attested_by_sid 注入: 非 default sid 时以 ZCODE_SESSION_ID 导出,attest 记录真实归属
fp="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .toolInput.file_path // empty' 2>/dev/null)"
plan_dir="$(dirname "$plan")"
case "$tool" in Write|Edit|MultiEdit)
  owner=""
  [ -n "$fp" ] || fp=""
  case "$fp" in
    /*) ;;   # 绝对路径: 不动
    */*)
      # [2026-09-14 task-v068 fix-B P0-1] 相对含 slash (Write/Edit 常态): CWD 直拼归一化;
      # 存在才采用(零子进程短路), 不存在保持原值 → 下方路径比对不命中, 静默跳过
      [ -n "$CWD" ] && [ -f "$CWD/$fp" ] && fp="$CWD/$fp"
      ;;
    *)
      # [2026-09-13 task-v068 E2-fix] 纯文件名: 先 CWD 直拼(常态), 再 <plans>/*/<fp>(plan 三件套常态);
      # 候选在 CWD 侧真实存在才采用
      found=""
      if [ -n "$CWD" ] && [ -f "$CWD/$fp" ]; then
        found="$CWD/$fp"
      else
        for cand in "$CWD"/plans/*/"$fp"; do
          [ -f "$cand" ] && { found="$cand"; break; }
        done
      fi
      [ -n "$found" ] && fp="$found"
      ;;
  esac
  if [ -n "$fp" ] && [ "$(cd "$(dirname "$fp")" 2>/dev/null && pwd)/$(basename "$fp")" = "$(cd "$(dirname "$plan")" && pwd)/$(basename "$plan")" ]; then
    # owner 缺失/他会话 → 不重锁(维持 TAMPERED);[ -f ] 短路保证缺失时不产生重定向报错
    if [ -f "$plan_dir/.session-owner" ]; then
      owner="$(tr -cd 'a-zA-Z0-9' < "$plan_dir/.session-owner" 2>/dev/null | head -c 40)"
    fi
    if [ -n "$owner" ] && [ "$owner" = "$SID" ] && [ "$SID" != "default" ]; then
      ATTEST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/attest-plan.sh"
      # [2026-09-13 task-v068 fix-B P1-2] 同步执行(attest 仅一次 sha256+写文件,极快),
      # 消除孤儿后台进程与 stderr fd 丢失; 外层已有 ZCODE_SESSION_ID 时尊重外层值
      # (更权威, 防静默覆盖污染 attested_by_sid 审计), 否则回落到本会话 SID
      [ -f "$ATTEST" ] && { env ZCODE_SESSION_ID="${ZCODE_SESSION_ID:-$SID}" bash "$ATTEST" "$plan" --skip-dispatch-check >/dev/null 2>/dev/null || echo "[attest] auto-relock failed: $plan" >&2; }
    fi
  fi
  ;;
esac

now="$(date +%s)"
mt="$(stat -c %Y "$plan" 2>/dev/null || echo "$now")"
age=$(( now - mt ))

# ─── [task-v148 Rule 64.3 F10] 完结/超龄计划 → 清 rhythm due ─────────────────
# What: 计划完结（task_plan.md 或同目录 verification.md 含 outcome: COMPLETE|BLOCKED）
#       或 task_plan.md mtime 超 24h → 把 .drift-rhythm/<sid>.state 的 due 标志清零。
# Why: F10——早调用已把 due=1 记入 state，但既有 :147/:150/:155 静默守卫会直接
#       exit 0，永远走不到主流程末尾的 end-emit；若不在早退前清 due，已完结/历史
#       计划会残留 due=1（state 脏，违背「不注入即清零」语义）。此处「同条件重查」
#       与既有守卫同口径（不修改既有分支），只做状态清理，不产生任何 stdout。
# Rule 64.3 + Rule 45（What+Why）
rhythm_f10="$(dirname "$plan_dir")/.drift-rhythm/${SID}.state"
if [ -f "$rhythm_f10" ]; then
  if [ "$age" -gt 86400 ] \
     || grep -qiE 'outcome: *(COMPLETE|BLOCKED)' "$plan" 2>/dev/null \
     || { [ -f "${plan_dir}/verification.md" ] && grep -qiE 'outcome: *(COMPLETE|BLOCKED)' "${plan_dir}/verification.md" 2>/dev/null; }; then
    f10_count="$(sed -n 's/^count[[:space:]]\{1,\}//p' "$rhythm_f10" 2>/dev/null | head -1)"
    f10_last="$(sed -n 's/^last_inject[[:space:]]\{1,\}//p' "$rhythm_f10" 2>/dev/null | head -1)"
    case "$f10_count" in ''|*[!0-9]*) f10_count=0 ;; esac
    case "$f10_last" in ''|*[!0-9]*) f10_last=0 ;; esac
    printf 'count %s\nlast_inject %s\ndue 0\n' "$f10_count" "$f10_last" > "$rhythm_f10" 2>/dev/null || true
  fi
fi

[ "$age" -gt 86400 ] && exit 0   # >24h 未更新 = 历史任务，不打扰

# ─── 完结计划静默（[2026-08-28] 防误报:outcome 已定局的任务不再催）────────────
if grep -qiE 'outcome: *(COMPLETE|BLOCKED)' "$plan" 2>/dev/null; then
  exit 0
fi
# [2026-09-17 task-v078] 兜底: 本仓约定 outcome 落盘在 verification.md(task_plan.md 不含) —
# 已交付计划(verification.md 含 outcome: COMPLETE|BLOCKED)同样豁免陈旧提醒(误报修复)
[ -f "${plan_dir}/verification.md" ] && grep -qiE 'outcome: *(COMPLETE|BLOCKED)' "${plan_dir}/verification.md" 2>/dev/null && exit 0

# ─── 读阈值（config.json；解析失败兜底默认值，保证 fail-open）────────────────
SKILL_ROOT="${OPENCODE_SKILL_ROOT:-$HOME/.zcode/skills/task-planner}"
# [2026-09-26 task-v091 C-1b：双层路径修复，顶层覆盖优先] config.json 顶层键=用户覆盖值、.properties.X.default=schema 默认值；
# 原单层路径致顶层用户覆盖静默失效 → 6 键统一改为 .X // .properties.X.default // 原兜底（无覆盖时行为与原值一致）
todo_n="$(jq -r '.todo_sync_interval_calls // .properties.todo_sync_interval_calls.default // 10' "$SKILL_ROOT/config.json" 2>/dev/null || true)"
plan_min="$(jq -r '.plan_update_interval_minutes // .properties.plan_update_interval_minutes.default // 15' "$SKILL_ROOT/config.json" 2>/dev/null || true)"
cooldown="$(jq -r '.stale_remind_cooldown_calls // .properties.stale_remind_cooldown_calls.default // 10' "$SKILL_ROOT/config.json" 2>/dev/null || true)"
# [2026-09-04 Rule 19.7] 新增 findings/progress 陈旧阈值；解析失败兜底默认。
findings_n="$(jq -r '.findings_stale_minutes // .properties.findings_stale_minutes.default // 20' "$SKILL_ROOT/config.json" 2>/dev/null || true)"
progress_n="$(jq -r '.progress_stale_minutes // .properties.progress_stale_minutes.default // 25' "$SKILL_ROOT/config.json" 2>/dev/null || true)"
# [2026-09-05 Rule 19.7 升级] 连续无响应提醒达 compass_escalate_after 次 → 升级警告；解析失败兜底默认 2。
esc_after="$(jq -r '.compass_escalate_after // .properties.compass_escalate_after.default // 2' "$SKILL_ROOT/config.json" 2>/dev/null || true)"
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

# ─── [task-v148 Rule 64.3] [drift-rhythm] 延迟 emit（F9/F10/N1 修复）────────
# What: 早调用只计数并记录 due 状态，此处统一 emit（保证单轮单 JSON）
# Why: F9 BLOCKER——早调用直接 emit 与后续优先级分支 emit 同轮并存 → 双行 JSON；
#      F10——end-emit 前置与 :147/:150 同语义守卫，禁绕过既有静默语义；
#      N1——due 由早调用读-改-写持久保留（跨优先级 1-4 exit 0 的分支命中轮不清），
#      故本块在无分支调用轮必见 due=1 并投递，投递后清 due（延迟数调用而非饥饿）。
# Rule 64.3 + Rule 45（What+Why 注释）
rhythm_sfile="$(dirname "$plan_dir")/.drift-rhythm/${SID}.state"
due="$(sed -n 's/^due[[:space:]]\{1,\}//p' "$rhythm_sfile" 2>/dev/null | head -1)"
case "$due" in ''|*[!0-9]*) due=0 ;; esac
if [ "$due" -eq 1 ]; then
  rhythm_n="${TASK_PLANNER_DRIFT_RHYTHM_N:-10}"
  case "$rhythm_n" in ''|*[!0-9]*) rhythm_n=10 ;; esac
  rhythm_count="$(sed -n 's/^count[[:space:]]\{1,\}//p' "$rhythm_sfile" 2>/dev/null | head -1)"
  rhythm_last="$(sed -n 's/^last_inject[[:space:]]\{1,\}//p' "$rhythm_sfile" 2>/dev/null | head -1)"
  case "$rhythm_count" in ''|*[!0-9]*) rhythm_count=0 ;; esac
  case "$rhythm_last" in ''|*[!0-9]*) rhythm_last=0 ;; esac
  # F10 前置守卫：与 :147/:150 同语义——计划完结或 mtime 超 24h → 不注入（due 清零）
  if grep -qiE 'outcome: *(COMPLETE|BLOCKED)' "$plan" 2>/dev/null; then
    printf 'count %s\nlast_inject %s\ndue 0\n' "$rhythm_count" "$rhythm_last" > "$rhythm_sfile" 2>/dev/null || true
  elif [ "$age" -gt 86400 ]; then
    printf 'count %s\nlast_inject %s\ndue 0\n' "$rhythm_count" "$rhythm_last" > "$rhythm_sfile" 2>/dev/null || true
  else
    emit "[drift-rhythm] 距上次偏移检查已 ≥${rhythm_n} 次工具调用：活跃执行期按 Rule 15 派发 drift-checker（Rule 61 载体）并按 Rule 64.1 留痕三件套"
    printf 'count %s\nlast_inject %s\ndue 0\n' "$rhythm_count" "$rhythm_last" > "$rhythm_sfile" 2>/dev/null || true
  fi
fi

# 未命中任何提醒 → 9 字段原样写回 state
echo "$count $(date +%s) $cd_left $cd_findings $cd_progress $f_last $p_last $f_miss $p_miss" > "$state"
exit 0
