#!/usr/bin/env bash
# check-stop-guard.sh — Stop hook 停止护栏(五重 guard + stall 检测)
#
# What: 解析 Stop hook stdin JSON,判定是否拦截"任务未完成的停止"。
#   五重 guard 全部满足才 block(exit 1): ① task_plan.md 存在 in_progress phase
#   ② stop_hook_active=false(防 hook 循环) ③ block 计数 < cap(20) ④ progress.md
#   较上次 block 有前进(hash 变化 或 mtime 距今 ≥ $STALL_DELTA_S 秒, 否则=stall=放行)
#   ⑤ 距上次 block ≥ $GUARD_COOLDOWN 秒(冷却)。任一不满足 → stdout 给出放行原因, exit 0。
# Why: 移植上游 planning-with-files 五重 stop guard(默认放行铁律), 并叠加 stall 检测。
#   病灶=task-v167 实测 38.7h 悬挂: 任务跨 38.7h 仅 2 提交无进展(Phase 0/5 卡死),
#   旧 Stop hook 无 stall 检测、无 block 次数上限, runaway 会话被无限拦截或无人察觉。
#   cap(20) 封顶 + stall 即放行, 悬挂任务第 20 次 block 后自动放行, 不再无界拦截。
# Fail-open 铁律: 任何 guard 自身错误(文件缺失/读失败/JSON 畸形/依赖脚本缺失)一律放行,
#   绝不因护栏自身故障阻断用户停止——本 hook 是防护网而非门禁。
# 输入: stdin=Stop hook JSON(仅取 session_id / stop_hook_active 两字段, grep -oE 解析, 不依赖 jq)
# 输出: block → stdout "[stop-guard] block #N: ..." + exit 1;
#       放行 → stdout "[stop-guard] released: <原因>" + exit 0(原因=无活跃计划|无 in_progress phase|stop_hook_active|cap 已达|stall 无进展|冷却期内|读失败<细节>|fail-open<细节>)
# 可测性(env 覆盖, 供 fixture 使用): PLAN_DIR 活跃计划目录(默认调 resolve-plan-dir.sh 定位, 失败=无活跃计划放行);
#   STOP_COUNT_DIR 计数目录(默认 $HOME/.task-planner-stop-guard); GUARD_COOLDOWN 冷却秒(默认 30);
#   STALL_DELTA_S stall 判定窗口秒(默认 60, fixture 场景③用 1 加速)
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GUARD_COOLDOWN="${GUARD_COOLDOWN:-30}"
STALL_DELTA_S="${STALL_DELTA_S:-60}"
CAP=20                       # block 次数上限: 超出即放行(挂 20 次还停不下来=任务卡死, 不再拦截)
RELEASE_REASON=""           # 非空=放行理由; 空=block

fail_open() {               # fail-open 铁律落地: guard 自身故障绝不阻断用户
  echo "[stop-guard] released: ${RELEASE_REASON:-fail-open}"
  exit 0
}

plan_dir="${PLAN_DIR:-}"
if [ -z "$plan_dir" ]; then
  # 未覆盖 → 用仓内解析链定位活跃计划; 定位不到=无活跃计划=放行(与 fail-open 同向)
  plan_file="$(bash "$SCRIPT_DIR/resolve-plan-dir.sh" 2>/dev/null | head -n1 || true)"
  [ -n "$plan_file" ] && plan_dir="$(dirname "$plan_file")" || plan_dir=""
fi
[ -n "$plan_dir" ] || { RELEASE_REASON="无活跃计划"; fail_open; }

now="$(date +%s)" || fail_open
input="$(cat 2>/dev/null)" || input=""
input="$(printf '%s' "$input" | tr -d '\0')"   # 剔除 NUL, 防 bash 字符串赋值截断误报

sid="$(printf '%s' "$input" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -E 's/.*"([^"]*)"$/\1/' | head -n1)"
[ -n "$sid" ] || fail_open     # sid 缺失=无法定位计数文件=宁可放行
sha="$(printf '%s' "$input" | grep -oE '"stop_hook_active"[[:space:]]*:[[:space:]]*true' | head -n1)"
stop_active="$([ -n "$sha" ] && echo true || echo false)"
COUNT_DIR="${STOP_COUNT_DIR:-$HOME/.task-planner-stop-guard}"
mkdir -p "$COUNT_DIR" 2>/dev/null || fail_open
COUNT_FILE="$COUNT_DIR/$sid.count"; LASTTS_FILE="$COUNT_DIR/$sid.lastts"; LASTHASH_FILE="$COUNT_DIR/$sid.lasthash"

# guard① 存在 in_progress phase(目录/plan 缺失=无法判定=按"无活跃计划"放行, 不猜)
plan_md="$plan_dir/task_plan.md"
[ -f "$plan_md" ] || { RELEASE_REASON="无活跃计划"; fail_open; }
grep -qF '**Status:** in_progress' "$plan_md" 2>/dev/null || { RELEASE_REASON="无 in_progress phase"; fail_open; }

# guard② stop_hook_active=true → hook 自身循环中, 无条件放行(防无限 block 循环)
[ "$stop_active" = "false" ] || { RELEASE_REASON="stop_hook_active"; fail_open; }

# guard③ block 计数 < cap(读失败按 0=放行, fail-open)
count="$(cat "$COUNT_FILE" 2>/dev/null)" || count=""; case "$count" in ''|*[!0-9]*) count=0 ;; esac
[ "$count" -lt "$CAP" ] || { RELEASE_REASON="cap 已达"; fail_open; }

# guard④ stall 检测: progress.md 较上次 block 有前进才拦截;
#   无变化(hash 同且 mtime 距今 < STALL_DELTA_S)=任务悬挂=放行(病灶根因之一)
prog="$plan_dir/progress.md"
last_hash="$(cat "$LASTHASH_FILE" 2>/dev/null)" || last_hash=""
cur_hash="$( [ -f "$prog" ] && sha256sum "$prog" 2>/dev/null | awk '{print $1}' )" || cur_hash=""
if [ -n "$last_hash" ]; then
  if [ "$cur_hash" = "$last_hash" ]; then
    pm="$( [ -f "$prog" ] && stat -c %Y "$prog" 2>/dev/null )" || pm=""
    [ -n "$pm" ] && [ $(( now - pm )) -ge "$STALL_DELTA_S" ] || { RELEASE_REASON="stall 无进展"; fail_open; }
  fi
fi
lastts="$(cat "$LASTTS_FILE" 2>/dev/null)" || lastts=""

# guard⑤ 冷却: 距上次 block ≥ GUARD_COOLDOWN(首次/读失败=无 lastts=冷却已过, 放行倾向)
if [ -n "$lastts" ]; then
  case "$lastts" in
    *[!0-9]*) : ;;
    *) [ $(( now - lastts )) -ge "$GUARD_COOLDOWN" ] || { RELEASE_REASON="冷却期内"; fail_open; } ;;
  esac
fi

# 五重全过 → block: 计数+1, 记录本次 progress hash 与时间戳(供下次 ④⑤ 判定)
count=$(( count + 1 ))
printf '%s' "$count"  > "$COUNT_FILE"   2>/dev/null || fail_open
printf '%s' "${cur_hash:-}" > "$LASTHASH_FILE" 2>/dev/null || true
printf '%s' "$now"     > "$LASTTS_FILE"   2>/dev/null || true
echo "[stop-guard] block #$count: 计划仍有 in_progress phase（$plan_dir），progress 有更新；如确需停止请说明理由。"
exit 1
