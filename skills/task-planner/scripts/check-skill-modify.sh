#!/usr/bin/env bash
# check-skill-modify.sh — task-v079 Rule 36 技能修改保守化门(pretool 守卫)
# [2026-09-17 task-v079 S5] 技能文件写入须登记于活跃计划「执行范围限制」表(36.7①)
# 调用(镜像 check-delegation.sh pretool): check-skill-modify.sh pretool <file> [sid]
# 退出码: 0=放行(非技能文件/已授权/off 档/warn 档放行但 stdout 输出
#   {"additionalContext":...} warn JSON; 内部错误 fail-open + stderr 一行警告)
#          2=阻断(enforce 档且未授权, zcode-pretooluse.sh 透传 exit 2)
# 设计要点: 主/子代理一致生效(不检查 sid 是否 .session-owner —— 补 check-delegation
#   子代理空档); 三档=env TASK_PLANNER_SKILL_MODIFY_ENFORCE > config.json
#   .properties.skill_modify_enforce.default > "warn"; 授权优先于档位(target 命中
#   计划「执行范围限制」表 token → 恒 exit 0); 无写操作(仅 /tmp 计数); 无 network
set -u

MODE="${1:-}"; TARGET="${2:-}"; SID="${3:-default}"
[ "$MODE" = "pretool" ] || { echo "usage: check-skill-modify.sh pretool <file> [sid]" >&2; exit 0; }
[ -n "$TARGET" ] || { echo "check-skill-modify: 缺 target 参数, fail-open" >&2; exit 0; }

# realpath -m 规范化(兼容 worktree/部署位/相对路径); 失败用原路径继续
T="$(realpath -m "$TARGET" 2>/dev/null)" || T="$TARGET"

# ① 技能文件模式: 含 /skills/ 段 且 (basename=SKILL.md 或 技能根后前缀∈受控目录/config.json/knowledge-brief.md)
is_skill_file() {
  case "$1" in */skills/*) ;; *) return 1 ;; esac
  local name="${1##*/skills/}"
  case "$name" in
    */*)
      local rest="${name#*/}"
      case "$rest" in
        SKILL.md|config.json|knowledge-brief.md|references/*|scripts/*|templates/*|agents/*|assets/*|companion/*) return 0 ;;
      esac
      return 1 ;;
    SKILL.md|config.json|knowledge-brief.md) return 0 ;;
  esac
  return 1
}
is_skill_file "$T" || exit 0

# ② 定位活跃计划(镜像 resolve-plan-dir 管线: 实仓 root → git-common-dir 根 → cwd;
#    会话归属=.session-owner 严格相等 或 side 指针指向本计划; 无归属 → 无授权, 跳分档)
SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_DEPLOY="$(realpath -m "$SKILL_ROOT" 2>/dev/null)" || _DEPLOY="$SKILL_ROOT"
REPO_ROOT="$(cd "$(dirname "$(dirname "$_DEPLOY")")" 2>/dev/null && pwd)"
GT="$(git -C "$_DEPLOY" rev-parse --git-common-dir 2>/dev/null)"
[ -n "$GT" ] && [ -d "$GT" ] && GT="$(cd "$GT" && pwd)"
[ -n "$GT" ] && GTROOT="$(cd "$(dirname "$GT")" 2>/dev/null && pwd)"
PLAN_FILE=""
for _ROOT in "${REPO_ROOT:-}" "${GTROOT:-}" "$PWD"; do
  [ -n "${_ROOT:-}" ] || continue
  _PF="$(bash "$SKILL_ROOT/resolve-plan-dir.sh" "$_ROOT" "$SID" 2>/dev/null || true)"
  [ -z "$_PF" ] && continue
  case "$SID" in
    default) PLAN_FILE="$_PF"; break ;;
    *)
      _SIDKEY="$(printf '%s' "$SID" | tr -cd 'a-zA-Z0-9' | head -c 40)"
      case "$_SIDKEY" in sess*) _SIDKEY="${_SIDKEY#sess}" ;; esac
      _DIR="$(dirname "$_PF")"
      _OWN="$(head -n 1 "$_DIR/.session-owner" 2>/dev/null | tr -cd 'a-zA-Z0-9' | head -c 40)"
      case "$_OWN" in sess*) _OWN="${_OWN#sess}" ;; esac
      if [ -n "$_OWN" ] && [ "$_OWN" = "$_SIDKEY" ]; then PLAN_FILE="$_PF"; break; fi
      if [ -f "$_ROOT/plans/.active_plan_side/${_SIDKEY}.active_plan" ]; then
        [ "$(tr -d ' \r\n\t' < "$_ROOT/plans/.active_plan_side/${_SIDKEY}.active_plan" 2>/dev/null)" = "$(basename "$_DIR")" ] && PLAN_FILE="$_PF" && break
      fi
      continue ;;
  esac
done

# ③ 授权判定: 计划「执行范围限制」段反引号 token, target 含任一 token 子串 → 已授权
if [ -n "$PLAN_FILE" ]; then
  AUTH="$(awk '/^## .*执行范围限制/{f=1; next} /^## /{f=0} f' "$PLAN_FILE" 2>/dev/null | grep -oE '`[^`]+`' | tr -d '`')"
  if [ -n "$AUTH" ]; then
    while IFS= read -r tok; do
      [ -n "$tok" ] && case "$T" in *"$tok"*) exit 0 ;; esac
    done <<< "$AUTH"
  fi
fi

# ④ 分档处置: env > config 默认 > warn
TIER="${TASK_PLANNER_SKILL_MODIFY_ENFORCE:-}"
[ -n "$TIER" ] || TIER="$(jq -r '.properties.skill_modify_enforce.default // "warn"' "$SKILL_ROOT/../config.json" 2>/dev/null)" || TIER="warn"
case "$TIER" in
  warn)
    n="$(cat "/tmp/task-planner-skillmod-${SID}.count" 2>/dev/null || echo 0)"
    case "$n" in ''|*[!0-9]*) n=0 ;; esac
    echo $((n + 1)) > "/tmp/task-planner-skillmod-${SID}.count" 2>/dev/null || true
    MSG="[skill-modify-warn] ⚠️ Rule 36: 技能文件写入未在当前计划执行范围授权: ${T##*/}（36.2 归因/36.4 删除确认/计划范围表登记后放行；enforce 升级=TASK_PLANNER_SKILL_MODIFY_ENFORCE）"
    printf '{"additionalContext": %s}\n' "$(printf '%s' "$MSG" | jq -Rs . 2>/dev/null || printf '"warn"')"
    exit 0 ;;
  enforce)
    echo "[skill-modify] BLOCKED (task-v079 Rule 36): ${T##*/} 未在活跃计划执行范围限制表登记（36.5 纯增量纪律/36.4 删除确认门；先归因 36.2 再走计划授权）" >&2
    exit 2 ;;
  *) exit 0 ;;
esac
