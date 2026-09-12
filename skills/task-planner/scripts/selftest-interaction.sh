#!/usr/bin/env bash
# selftest-interaction.sh — task-v062 Phase5/S1: resolve-interaction-mode.sh 解析优先级自测
# 守护 Rule 28.1 交互模式解析优先级 + fail-safe 兜底 (与 resolve 脚本 93 行接口严格对齐):
#   TI-01 默认链 (无env+无参数+无config) → ④ 兜底 ask
#   TI-02 env 合法覆盖 silent → silent (①层最高优先, 无参数)
#   TI-03 env 非法降级 (banana → 计划配置表 silent 行) → silent (非法值忽略, 降级 ②)
#   TI-04 计划配置表层生效 (无env+plan silent行, 传目录) → silent
#   TI-05 计划行非法值降级 (plan banana行 + 临时skill config default=ask) → ask
#   TI-06 临时config层生效 (无env+空plan参数无行+config default=silent) → silent
#   TI-07 fail-safe 兜底 (无env+无参数+无config) → ask, exit=0
#   TI-08 传文件路径直接 (非目录, 等价TI-04) → silent
# hermetic: mktemp 夹具 + trap 清理, 不触真实 plans/ 与真实 config.json;
# 各 config 层用例独立 <root> 目录 (resolve 读 <script_dir>/../config.json,
# 故 config.json 必须放 <root>/config.json 且 resolve copy 到 <root>/scripts/)。
# 全 PASS exit 0; 任一 FAIL exit 1。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOLVE="$SCRIPT_DIR/resolve-interaction-mode.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PASS=0; FAIL=0

# run_case <ti_num> <env_action: clear|silent|banana> <resolve_bin> <args...>
# 存 OUT/RC; clear = 清空 TASK_PLANNER_INTERACTION_MODE
run_case() {
  local num="$1" env_action="$2" bin="$3"; shift 3
  case "$env_action" in
    clear)
      OUT="$( (unset TASK_PLANNER_INTERACTION_MODE; bash "$bin" "$@" ) 2>/dev/null )"
      RC=$?
      ;;
    silent)
      OUT="$( TASK_PLANNER_INTERACTION_MODE=silent bash "$bin" "$@" 2>/dev/null )"
      RC=$?
      ;;
    banana)
      OUT="$( TASK_PLANNER_INTERACTION_MODE=banana bash "$bin" "$@" 2>/dev/null )"
      RC=$?
      ;;
  esac
  OUT="$(printf '%s' "$OUT" | tr -d '\n')"
}

assert_mode() {
  local num="$1" expected="$2"
  if [ "$OUT" = "$expected" ] && [ "$RC" -eq 0 ]; then
    PASS=$((PASS+1)); printf 'TI-%s PASS %s (out=%s rc=%s)\n' "$num" "$num" "$OUT" "$RC"
  else
    FAIL=$((FAIL+1)); printf 'TI-%s FAIL %s (out=%s exp=%s rc=%s)\n' "$num" "$num" "$OUT" "$expected" "$RC"
  fi
}

# 夹具: 临时计划目录 + task_plan.md 配置表
# resolve ②层解析格式: 行以 `| interaction_mode` 开头(允许反引号), awk -F'|' 取第3字段
# 即 `| `interaction_mode` | <val> |` 中 <val> 列
PLAN="$TMP/plans/task-t"
mkdir -p "$PLAN/subagent-state"
printf '计划A\n' > "$PLAN/task_plan.md"
printf '| `interaction_mode` | `silent` |\n' >> "$PLAN/task_plan.md"

# 计划行非法值夹具 (TI-05): task_plan5.md 行值 = banana
PLAN5="$TMP/plans/task-t5"
mkdir -p "$PLAN5"
printf '| `interaction_mode` | `banana` |\n' > "$PLAN5/task_plan.md"

# 空计划夹具 (TI-06): 传目录但无 interaction_mode 行 → 降级 ③
PLANEMPTY="$TMP/plans/task-t6"
mkdir -p "$PLANEMPTY"
printf '无配置表的计划\n' > "$PLANEMPTY/task_plan.md"

# --- config 层独立根目录 (resolve 读 <script_dir>/../config.json) ---
# case05: config default=ask
C05="$TMP/case05"; mkdir -p "$C05/scripts"; cp "$RESOLVE" "$C05/scripts/"
printf '{"properties":{"interaction_mode":{"default":"ask"}}}' > "$C05/config.json"
# case06: config default=silent
C06="$TMP/case06"; mkdir -p "$C06/scripts"; cp "$RESOLVE" "$C06/scripts/"
printf '{"properties":{"interaction_mode":{"default":"silent"}}}' > "$C06/config.json"
# case07: 无 config.json
C07="$TMP/case07"; mkdir -p "$C07/scripts"; cp "$RESOLVE" "$C07/scripts/"

# TI-01: 默认链 (无env+无参数+无config) → ④ 兜底 ask
run_case 01 clear "$C07/scripts/resolve-interaction-mode.sh"
assert_mode 01 ask

# TI-02: env 合法覆盖 silent → ① 层 silent
run_case 02 silent "$C07/scripts/resolve-interaction-mode.sh"
assert_mode 02 silent

# TI-03: env 非法降级 (banana 忽略 → ② 计划表 silent) → silent
run_case 03 banana "$RESOLVE" "$PLAN"
assert_mode 03 silent

# TI-04: 计划配置表层生效 (无env + 传 plan 目录) → silent
run_case 04 clear "$RESOLVE" "$PLAN"
assert_mode 04 silent

# TI-05: 计划行非法值降级 (banana 行 → ③ config default=ask) → ask
run_case 05 clear "$C05/scripts/resolve-interaction-mode.sh" "$PLAN5"
assert_mode 05 ask

# TI-06: 临时config层生效 (无env + 空plan目录无行 → ③ config default=silent) → silent
run_case 06 clear "$C06/scripts/resolve-interaction-mode.sh" "$PLANEMPTY"
assert_mode 06 silent

# TI-07: fail-safe 兜底 (无env + 无参数 + 无config) → ask, exit=0
run_case 07 clear "$C07/scripts/resolve-interaction-mode.sh"
assert_mode 07 ask

# TI-08: 传文件路径直接 (非目录, 等价TI-04) → silent
run_case 08 clear "$RESOLVE" "$PLAN/task_plan.md"
assert_mode 08 silent

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
