#!/usr/bin/env bash
# run-verification.sh — 统一验证执行入口（verification-gate 卫星，Rule 84.6）
#
# What: 解析 verification.md 的 VC 条目「**Verify command**:」字段，逐条作为 bash 命令执行，
#       汇总 PASS/FAIL/SKIP 计数并输出明细。任务终验 VC 复验 SOP（Rule 84.5 步骤③）的统一入口，
#       替代人工逐条手跑，防遗漏。
# Why: 用户 2026-10-14 裁决（task-v173 R1-R4，见 plans/.rule-reservations.jsonl）——VC 从描述性
#      占位升级为可执行命令（Rule 84.1），需要机器执行器收口；与 attest-plan.sh 的 VC 可执行性门
#      （计划期拒锁，校验"有没有写命令"）互补——本脚本是终验期执行器（校验"命令跑不跑得过"）。
# 用法: bash run-verification.sh <plan-dir>
# 输入: <plan-dir>/verification.md（Phase Gates/Goal Gate/质量门控统计段之外，只解析 VC 段的
#       "**Verify command**: <命令>" 行；模板占位/不可执行项自动 SKIP 不计 FAIL）
# 输出: 逐 VC 的 PASS/FAIL/SKIP 明细 + 汇总计数到 stdout
# 退出码: 0=全部 PASS（或仅 SKIP）；1=存在 FAIL；2=输入异常（plan-dir/verification.md 缺失）
# 依赖: bash + grep/sed + coreutils；无 jq 依赖（md 解析用状态机式行扫描，禁 gawk 区间式
#       ——记忆教训：plans/task-planner-skill 的 gawk 区间坍缩 bug，awk 区间提取一律状态机式）
set -u

PLAN_DIR="${1:-}"

if [ -z "$PLAN_DIR" ]; then
  echo "用法: bash run-verification.sh <plan-dir>" >&2
  exit 2
fi

VERIF_FILE="$PLAN_DIR/verification.md"
if [ ! -f "$VERIF_FILE" ]; then
  echo "[run-verification] ERROR: $VERIF_FILE 不存在" >&2
  echo "[run-verification] 提示: 终验前请在计划目录生成 verification.md（模板见 verification-gate/templates/verification.md）" >&2
  exit 2
fi

pass=0
fail=0
skip=0
current_vc=""
declare -a RESULT_LINES
declare -a FAIL_DETAIL

# [2026-10-16 P-01 伴生 c] 机器落盘目录：<plan-dir>/evidence/（每条 VC 一个 VC-<N>.out）
# What: EVID_DIR 是「机器产出证据」的固定落点——check-evidence-anchor.sh 的 provenance 层 c 认此目录，
#       并校验文件头（VC 编号 + ISO8601 时间戳）以防手写伪造。
# Why: 终审意见 7「证据锚必须指向落盘文件而非模型手写文本」；目录名是跨脚本契约，改名须同步
#       task-planner/scripts/check-evidence-anchor.sh 的 `"$PLAN_DIR"/evidence/*` 判定分支。
EVID_DIR="$PLAN_DIR/evidence"

# ─── 状态机式逐行扫描：VC 条目行（- [ ] VC-N / - [x] VC-N）设置 current_vc；───
# ─── "**Verify command**:" 行提取命令并关联 current_vc 执行；同一 VC 只取其首个命令（幂等）───
while IFS= read -r line; do
  # VC 条目行识别：行首（允许前导空白后）- [ ] 或 - [x] 后跟 VC-N
  if printf '%s\n' "$line" | grep -qE '^[[:space:]]*- \[[xX[:space:]]\] VC-[0-9]+'; then
    current_vc="$(printf '%s\n' "$line" | grep -oE 'VC-[0-9]+' | head -1)"
    continue
  fi

  # Verify command 行提取：冒号后的内容为命令主体
  cmd="$(printf '%s\n' "$line" | sed -n 's/^[[:space:]]*\*\*Verify command\*\*:[[:space:]]*\(.*\)$/\1/p')"
  if [ -z "$cmd" ] || [ -z "$current_vc" ]; then
    continue
  fi

  # 占位/不可执行检测：模板典型占位串（must be runnable / runnable command / path+key-line /
  # diff/evidence form / bash command OR）→ SKIP，不计 FAIL（模板未填 vs 真命令执行失败须区分）
  case "$cmd" in
    *"must be runnable"*|*"runnable command"*|*"path+key-line"*|*"diff/evidence"*|*"bash command OR"*|*"path + key"*)
      RESULT_LINES+=("SKIP  $current_vc  (模板占位未填命令)")
      skip=$((skip + 1))
      current_vc=""
      continue
      ;;
  esac

  # 执行命令（隔离子 shell；[2026-10-16 P-01 伴生 c] 起 stdout/stderr 不再丢弃，改为落盘
  # <plan-dir>/evidence/VC-N.out——机器产出证据；命令自身副作用由计划作者负责）
  # 落盘契约（供 check-evidence-anchor.sh provenance 层 c 校验）：
  #   第 1 行 `# [run-verification] VC-N | <ISO8601 UTC> | cmd: <命令>`（VC 编号 + 时间戳）
  #   第 2 行 `# ---- stdout/stderr ----`；其后为命令原始输出；末行 `# exit=<rc>`
  # fail-open: mkdir/重定向失败（目录不可写）→ 退回原「丢弃输出」行为，不因落盘失败改判定。
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo 1970-01-01T00:00:00Z)"
  ev_file="$EVID_DIR/${current_vc}.out"
  ev_ok=0
  if mkdir -p "$EVID_DIR" 2>/dev/null && printf '# [run-verification] %s | %s | cmd: %s\n# ---- stdout/stderr ----\n' \
        "$current_vc" "$ts" "$cmd" > "$ev_file" 2>/dev/null; then
    ev_ok=1
  fi
  rc=0
  if [ "$ev_ok" = 1 ]; then
    bash -c "$cmd" >>"$ev_file" 2>&1 || rc=$?
    printf '\n# exit=%s\n' "$rc" >>"$ev_file" 2>/dev/null
  else
    bash -c "$cmd" >/dev/null 2>&1 || rc=$?
  fi
  ev_note=""
  [ "$ev_ok" = 1 ] && ev_note="  [evidence=$ev_file]"
  if [ "$rc" -eq 0 ]; then
    RESULT_LINES+=("PASS  $current_vc  exit=0  :: $cmd$ev_note")
    pass=$((pass + 1))
  else
    RESULT_LINES+=("FAIL  $current_vc  exit=$rc  :: $cmd$ev_note")
    FAIL_DETAIL+=("$current_vc (exit=$rc): $cmd$ev_note")
    fail=$((fail + 1))
  fi
  # 同一 VC 只取其首个 Verify command（防 VC 下多命令行重复计数）
  current_vc=""
done < "$VERIF_FILE"

# ─── 汇总输出 ───
echo "[run-verification] Verification Contract 执行汇总 — $VERIF_FILE"
echo "----------------------------------------------------------------"
for r in "${RESULT_LINES[@]:-}"; do
  [ -z "$r" ] && continue
  echo "  $r"
done
[ ${#RESULT_LINES[@]} -eq 0 ] && echo "  (未解析到 VC Verify command 行——请检查 verification.md 格式)"
echo "----------------------------------------------------------------"
echo "[run-verification] Total: PASS=$pass FAIL=$fail SKIP=$skip"

if [ "$fail" -gt 0 ]; then
  echo "[run-verification] 存在 FAIL 项——终验 outcome 禁 COMPLETE（Rule 84.5），回炉修复后重跑:" >&2
  for f in "${FAIL_DETAIL[@]}"; do
    echo "  - $f" >&2
  done
  exit 1
fi

echo "[run-verification] 全部 VC 执行通过（或仅占位 SKIP）——可进入 Goal Gate 终验判定（Rule 84.5）"
exit 0
